[CmdletBinding()]
param(
    [string]$ConfigPath = (Join-Path (Split-Path -Parent $PSScriptRoot) ".catalog-sync.local.json")
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path $RepoRoot "logs"
$LogFile = Join-Path $LogDir "catalog-sync.log"
$LockFile = Join-Path $LogDir "catalog-sync.lock"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$PythonCommand = if (Get-Command python -ErrorAction SilentlyContinue) {
    "python"
} elseif (Get-Command py -ErrorAction SilentlyContinue) {
    "py"
} else {
    throw "No se encontró Python en PATH."
}
$PythonLauncherArgs = if ($PythonCommand -eq "py") { @("-3") } else { @() }

function Write-Log([string]$Message) {
    $line = "{0} {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
    Write-Host $line
}

if (Test-Path $LockFile) {
    Write-Log "SKIPPED: otra sincronización parece estar en ejecución."
    exit 0
}
New-Item -ItemType File -Path $LockFile -Force | Out-Null

try {
    if (-not (Test-Path $ConfigPath)) { throw "No existe la configuración local: $ConfigPath" }
    $cfg = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    $Source = [string]$cfg.sourceFolder
    $Repo = [string]$cfg.localRepoPath
    $Branch = if ($cfg.branch) { [string]$cfg.branch } else { "main" }
    $Dest = Join-Path $Repo "productos"

    if (-not (Test-Path $Source)) { throw "No existe la carpeta OneDrive canónica: $Source" }
    if (-not (Test-Path (Join-Path $Repo ".git"))) { throw "La carpeta local no es un repositorio Git: $Repo" }

    Push-Location $Repo
    try {
        # productos/ is a mirror of the canonical OneDrive source. Clean only that path
        # so a previous rejected/invalid sync cannot block the next git pull.
        & git restore --staged --worktree -- productos 2>$null
        & git clean -fd -- productos | ForEach-Object { Write-Log $_ }

        Write-Log "Actualizando repositorio local desde origin/$Branch..."
        & git pull --rebase origin $Branch | ForEach-Object { Write-Log $_ }
        if ($LASTEXITCODE -ne 0) { throw "git pull falló con código $LASTEXITCODE" }

        New-Item -ItemType Directory -Path $Dest -Force | Out-Null
        Write-Log "Sincronizando OneDrive -> productos..."
        & robocopy $Source $Dest /MIR /FFT /Z /R:2 /W:2 /NP /NFL /NDL | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy falló con código $LASTEXITCODE" }

        Write-Log "Validando nombres de archivos..."
        & $PythonCommand @PythonLauncherArgs (Join-Path $Repo "scripts\generate_catalog.py") --products $Dest --validate-only
        if ($LASTEXITCODE -ne 0) {
            Write-Log "ABORTED: hay nombres de archivo inválidos. No se hará push."
            & git restore --staged --worktree -- productos 2>$null
            & git clean -fd -- productos | ForEach-Object { Write-Log $_ }
            exit 2
        }

        & git add -A productos
        & git diff --cached --quiet
        if ($LASTEXITCODE -eq 0) {
            Write-Log "NO_CHANGES: no hay cambios para subir."
            exit 0
        }

        $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        & git commit -m "catalog: actualización automática $stamp" | ForEach-Object { Write-Log $_ }
        if ($LASTEXITCODE -ne 0) { throw "git commit falló con código $LASTEXITCODE" }

        & git push origin $Branch | ForEach-Object { Write-Log $_ }
        if ($LASTEXITCODE -ne 0) { throw "git push falló con código $LASTEXITCODE" }

        Write-Log "SUCCESS: catálogo subido a GitHub."
    }
    finally {
        Pop-Location
    }
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}
finally {
    Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
}
