(() => {
  "use strict";

  const cfg = window.PINLAND_CONFIG || {};
  const categoryIcons = window.PINLAND_CATEGORY_ICONS || {};
  const state = { products: [], query: "", category: "Todos" };

  const $ = (sel) => document.querySelector(sel);
  const grid = $("#productGrid");
  const empty = $("#emptyState");
  const count = $("#catalogCount");
  const chips = $("#categoryChips");
  const search = $("#searchInput");
  const modal = $("#productModal");

  const normalize = (value = "") => value
    .toString()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim();

  const money = new Intl.NumberFormat(cfg.locale || "es-DO", {
    style: "currency",
    currency: cfg.currency || "DOP",
    maximumFractionDigits: 2
  });

  const whatsappBase = () => {
    const number = (cfg.whatsappNumber || "").replace(/\D/g, "");
    return number ? `https://wa.me/${number}` : "#";
  };

  const productWhatsapp = (product) => {
    const soldOut = normalize(product.availability) === "agotado";
    const intro = soldOut ? "Hola, quiero pedir y reservar este artículo" : "Hola, me interesa este artículo";
    const text = `${intro}: ${product.description} (orden ${product.order}), ${money.format(product.price)}.`;
    const base = whatsappBase();
    return base === "#" ? "#" : `${base}?text=${encodeURIComponent(text)}`;
  };

  const whatsappIcon = () => `
    <svg class="button-icon" aria-hidden="true"><use href="#icon-whatsapp"></use></svg>
  `;

  function wireStaticLinks() {
    const instagram = cfg.instagramUrl || "#";
    ["#instagramTop", "#instagramFooter"].forEach((id) => {
      const el = $(id); if (el) el.href = instagram;
    });
    ["#whatsappTop", "#whatsappFooter"].forEach((id) => {
      const el = $(id); if (el) el.href = whatsappBase();
    });
    const canonical = $("#canonicalLink");
    if (canonical) {
      if (cfg.canonicalUrl) canonical.href = cfg.canonicalUrl;
      else canonical.remove();
    }
  }

  function categoryIcon(category) {
    const key = normalize(category);
    return categoryIcons[key] || categoryIcons.default || "./assets/category-icons/default.svg";
  }

  function renderCategories() {
    const categories = ["Todos", ...new Set(state.products.map(p => p.category).filter(Boolean))];
    chips.innerHTML = categories.map(category => `
      <button class="chip ${category === state.category ? "active" : ""}" data-category="${escapeHtml(category)}" aria-pressed="${category === state.category ? "true" : "false"}">
        <span class="chip-icon-wrap" aria-hidden="true">
          <img class="chip-icon" src="${encodeURI(categoryIcon(category))}" alt="" />
        </span>
        <span class="chip-label">${escapeHtml(category)}</span>
      </button>
    `).join("");

    chips.querySelectorAll(".chip").forEach(btn => btn.addEventListener("click", () => {
      state.category = btn.dataset.category;
      renderCategories();
      renderProducts();
    }));
  }

  function filteredProducts() {
    const q = normalize(state.query);
    return state.products.filter(product => {
      const categoryMatch = state.category === "Todos" || product.category === state.category;
      const text = normalize(`${product.description} ${product.category} ${product.order}`);
      return categoryMatch && (!q || text.includes(q));
    });
  }

  function renderProducts() {
    const products = filteredProducts();
    count.textContent = `${products.length} ${products.length === 1 ? "producto" : "productos"}`;
    empty.hidden = products.length > 0;
    grid.innerHTML = products.map(productCard).join("");

    grid.querySelectorAll("[data-detail]").forEach(btn => btn.addEventListener("click", () => {
      const product = state.products.find(p => String(p.order) === btn.dataset.detail);
      if (product) openModal(product);
    }));
  }

  function productCard(product) {
    const soldOut = normalize(product.availability) === "agotado";
    const availabilityClass = soldOut ? "soldout" : "available";
    const cta = soldOut ? "Pedir y reservarlo" : "Pedir por WhatsApp";
    const href = productWhatsapp(product);
    const safeOrder = escapeHtml(String(product.order));
    return `
      <article class="product-card">
        <button class="product-image-button" data-detail="${safeOrder}" aria-label="Ver detalle de ${escapeHtml(product.description)}">
          <img src="${encodeURI(product.image)}" alt="${escapeHtml(product.description)}" loading="lazy" />
        </button>
        <div class="product-body">
          <div class="product-meta">
            <span class="product-order">#${safeOrder}</span>
            <span class="product-category">${escapeHtml(product.category)}</span>
          </div>
          <button class="product-title-button" data-detail="${safeOrder}">${escapeHtml(product.description)}</button>
          <p class="product-price">${money.format(product.price)}</p>
          <p class="availability ${availabilityClass}">● ${escapeHtml(product.availability)}</p>
          <div class="product-actions">
            ${soldOut ? "" : `<button class="action-button detail" data-detail="${safeOrder}">Ver detalle</button>`}
            <a class="action-button whatsapp ${soldOut ? "soldout" : ""}" href="${href}" target="_blank" rel="noopener">${whatsappIcon()}<span>${cta}</span></a>
          </div>
        </div>
      </article>`;
  }

  function openModal(product) {
    const soldOut = normalize(product.availability) === "agotado";
    $("#modalImage").src = encodeURI(product.image);
    $("#modalImage").alt = product.description;
    $("#modalOrder").textContent = `#${product.order}`;
    $("#modalCategory").textContent = product.category;
    $("#modalTitle").textContent = product.description;
    $("#modalPrice").textContent = money.format(product.price);
    const status = $("#modalAvailability");
    status.textContent = `● ${product.availability}`;
    status.className = `availability ${soldOut ? "soldout" : "available"}`;
    const wa = $("#modalWhatsapp");
    wa.href = productWhatsapp(product);
    $("#modalWhatsappLabel").textContent = soldOut ? "Pedir y reservarlo" : "Pedir por WhatsApp";
    modal.showModal();
  }

  function escapeHtml(value = "") {
    return value.toString().replace(/[&<>'"]/g, ch => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;", "'": "&#39;", '"': "&quot;"
    }[ch]));
  }

  async function loadCatalog() {
    try {
      const response = await fetch(`./data/catalog.json?v=${Date.now()}`, { cache: "no-store" });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const data = await response.json();
      state.products = Array.isArray(data.products) ? data.products : [];
      state.products.sort((a, b) => Number(a.order) - Number(b.order));
      renderCategories();
      renderProducts();
    } catch (error) {
      console.error("No se pudo cargar el catálogo", error);
      count.textContent = "Catálogo no disponible";
      empty.hidden = false;
      empty.querySelector("h3").textContent = "No pudimos cargar el catálogo";
      empty.querySelector("p").textContent = "Intenta nuevamente en unos minutos.";
    }
  }

  search.addEventListener("input", () => {
    state.query = search.value;
    renderProducts();
  });

  $("#modalClose").addEventListener("click", () => modal.close());
  modal.addEventListener("click", (event) => {
    if (event.target === modal) modal.close();
  });

  wireStaticLinks();
  loadCatalog();
})();
