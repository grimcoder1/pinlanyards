[CmdletBinding()]
param(
    [string]$SourceFolder,
    [string]$RepositoryUrl,
    [string]$LocalRepoPath,
    [string]$Branch = "main",
    [string]$TaskName = "PinLandYards Catalog Sync",
    [int]$IntervalMinutes = 5
)

$ErrorActionPreference = "Stop"

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "No se encontró '$Name' en PATH. Instálalo antes de continuar."
    }
}

Require-Command git
if (-not (Get-Command python -ErrorAction SilentlyContinue) -and -not (Get-Command py -ErrorAction SilentlyContinue)) {
    throw "No se encontró Python en PATH. Instala Python 3 antes de continuar."
}

if (-not $SourceFolder) {
    $SourceFolder = Read-Host "Ruta local EXACTA de la carpeta OneDrive que será la fuente CANÓNICA de productos"
}
if (-not $RepositoryUrl) {
    $RepositoryUrl = Read-Host "URL HTTPS del repositorio GitHub (ej. https://github.com/usuario/repo.git)"
}
if (-not $LocalRepoPath) {
    $default = Join-Path $env:USERPROFILE "GRIMATS\pinlandyards-catalogo"
    $typed = Read-Host "Carpeta local del repositorio [$default]"
    $LocalRepoPath = if ([string]::IsNullOrWhiteSpace($typed)) { $default } else { $typed }
}

if (-not (Test-Path $SourceFolder)) {
    throw "La carpeta OneDrive no existe: $SourceFolder"
}
if ($IntervalMinutes -lt 2) {
    throw "Usa un intervalo de 2 minutos o más. Recomendado: 5."
}

$Parent = Split-Path -Parent $LocalRepoPath
New-Item -ItemType Directory -Path $Parent -Force | Out-Null

if (-not (Test-Path (Join-Path $LocalRepoPath ".git"))) {
    Write-Host "Clonando repositorio..."
    & git clone --branch $Branch $RepositoryUrl $LocalRepoPath
    if ($LASTEXITCODE -ne 0) {
        throw "No se pudo clonar el repositorio. Verifica la URL y la autenticación GitHub."
    }
} else {
    Write-Host "Repositorio local existente detectado."
    Push-Location $LocalRepoPath
    try {
        $origin = (& git remote get-url origin).Trim()
        if ($origin -ne $RepositoryUrl) {
            Write-Host "Actualizando origin: $origin -> $RepositoryUrl"
            & git remote set-url origin $RepositoryUrl
        }
    } finally { Pop-Location }
}

$Config = [ordered]@{
    sourceFolder = $SourceFolder
    repositoryUrl = $RepositoryUrl
    localRepoPath = $LocalRepoPath
    branch = $Branch
    taskName = $TaskName
    intervalMinutes = $IntervalMinutes
}
$ConfigPath = Join-Path $LocalRepoPath ".catalog-sync.local.json"
$Config | ConvertTo-Json | Set-Content -Path $ConfigPath -Encoding UTF8

$SyncScript = Join-Path $LocalRepoPath "scripts\Sync-CatalogToGitHub.ps1"
if (-not (Test-Path $SyncScript)) {
    throw "No existe el script de sincronización en el repositorio: $SyncScript"
}

$TaskCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$SyncScript`" -ConfigPath `"$ConfigPath`""
Write-Host "Creando tarea programada '$TaskName' cada $IntervalMinutes minutos..."
& schtasks.exe /Create /TN $TaskName /TR $TaskCommand /SC MINUTE /MO $IntervalMinutes /F | Out-Host
if ($LASTEXITCODE -ne 0) {
    throw "No se pudo crear la tarea programada. Ejecuta PowerShell con los permisos necesarios y vuelve a intentar."
}

Write-Host "Ejecutando primera sincronización..."
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $SyncScript -ConfigPath $ConfigPath
if ($LASTEXITCODE -ne 0) {
    throw "El setup terminó, pero la sincronización inicial falló. Revisa logs\catalog-sync.log."
}

Write-Host ""
Write-Host "SETUP COMPLETO"
Write-Host "Fuente canónica: $SourceFolder"
Write-Host "Repositorio local: $LocalRepoPath"
Write-Host "Repositorio remoto: $RepositoryUrl"
Write-Host "Tarea: $TaskName cada $IntervalMinutes minutos"
Write-Host "Config local (gitignored): $ConfigPath"
