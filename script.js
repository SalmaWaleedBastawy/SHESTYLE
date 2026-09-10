/* =========================================================
   SHESTYLE — shared script (Home + Products pages)
   Cart storage itself now lives in cart-store.js (shared across every
   page, and joined against real products) — this file just wires up
   buttons and shows the little toast notification.
   ========================================================= */

/* small toast, no extra library needed */
function showToast(message) {
  let toast = document.getElementById("shestyle-toast");
  if (!toast) {
    toast = document.createElement("div");
    toast.id = "shestyle-toast";
    toast.style.cssText = `
      position:fixed; bottom:24px; left:50%; transform:translateX(-50%) translateY(20px);
      background:#201C1A; color:#fff; padding:12px 22px; border-radius:2px;
      font-family:'Jost',sans-serif; font-size:.85rem; letter-spacing:.02em;
      opacity:0; transition:opacity .25s ease, transform .25s ease; z-index:2000;
    `;
    document.body.appendChild(toast);
  }
  toast.textContent = message;
  requestAnimationFrame(() => {
    toast.style.opacity = "1";
    toast.style.transform = "translateX(-50%) translateY(0)";
  });
  clearTimeout(toast._timer);
  toast._timer = setTimeout(() => {
    toast.style.opacity = "0";
    toast.style.transform = "translateX(-50%) translateY(20px)";
  }, 1800);
}

document.addEventListener("DOMContentLoaded", () => {
  // initialize cart badge from shared storage
  if (typeof updateCartBadges === "function") updateCartBadges();

  // wire up "Add to cart" buttons on product cards
  // (data-add-to-cart now holds a product id everywhere it can)
  document.querySelectorAll("[data-add-to-cart]").forEach(btn => {
    if (btn._shestyleWired) return;
    btn._shestyleWired = true;
    btn.addEventListener("click", e => {
      e.preventDefault();
      const id = btn.getAttribute("data-add-to-cart");
      if (typeof addToCart === "function") addToCart(id, 1);
    });
  });

  // wire up wishlist heart buttons on the home page's featured cards
  document.querySelectorAll(".product-wish").forEach(btn => {
    if (btn._shestyleWired) return;
    btn._shestyleWired = true;
    btn.addEventListener("click", e => {
      e.preventDefault();
      const card = btn.closest(".product-card");
      const id = card ? card.dataset.id : null;
      const icon = btn.querySelector("i");
      const active = (id && typeof toggleWishlist === "function") ? toggleWishlist(id) : false;
      btn.classList.toggle("active", active);
      if (icon) {
        icon.classList.toggle("fa-regular", !active);
        icon.classList.toggle("fa-solid", active);
      }
    });
  });

  // hero slider dots (Home page) — purely cosmetic auto-advance
  const dots = document.querySelectorAll(".hero-dots span");
  if (dots.length) {
    let i = 0;
    setInterval(() => {
      dots[i].classList.remove("active");
      i = (i + 1) % dots.length;
      dots[i].classList.add("active");
    }, 3500);
  }

  // color swatch selection (Products page)
  document.querySelectorAll(".swatch").forEach(sw => {
    sw.addEventListener("click", () => {
      sw.parentElement.querySelectorAll(".swatch").forEach(s => s.classList.remove("active"));
      sw.classList.add("active");
    });
  });

  // if URL has ?category=, mark matching sidebar checkbox / heading (Products page)
  const params = new URLSearchParams(window.location.search);
  const category = params.get("category");
  const catHeading = document.getElementById("category-heading");
  if (category && catHeading) {
    catHeading.textContent = category.toUpperCase();
    const matchingCheckbox = document.querySelector(`.filter-block input[value="${category.toLowerCase()}"]`);
    if (matchingCheckbox) matchingCheckbox.checked = true;
  }

  // header search icon toggles the inline search box (Shein-style header)
  const searchToggle = document.getElementById("searchToggle");
  const searchInput = document.getElementById("searchInput");
  if (searchToggle && searchInput) {
    searchToggle.addEventListener("click", () => {
      searchInput.classList.toggle("d-none");
      if (!searchInput.classList.contains("d-none")) searchInput.focus();
    });
  }

  // mark the active tab in the top tab-nav based on ?category=
  const tabLinks = document.querySelectorAll(".tab-link");
  if (tabLinks.length && category) {
    tabLinks.forEach(link => {
      link.classList.remove("active");
      if (link.getAttribute("href") === `products.html?category=${category}`) {
        link.classList.add("active");
      }
    });
  }
});