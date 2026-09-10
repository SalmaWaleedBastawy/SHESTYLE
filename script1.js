/* =========================================================
   SHESTYLE — shared category-page script
   Cart storage itself now lives in cart-store.js (shared across every
   page); this file just wires up buttons that aren't already wired by
   catalog.js and shows the little toast notification.
   ========================================================= */

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
  // refresh cart badge from shared storage
  if (typeof updateCartBadges === "function") updateCartBadges();

  // wire up any "Add to cart" buttons not already wired by catalog.js
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

  // header search icon toggles the inline search box
  const searchToggle = document.getElementById("searchToggle");
  const searchInput = document.getElementById("searchInput");
  if (searchToggle && searchInput) {
    searchToggle.addEventListener("click", () => {
      searchInput.classList.toggle("d-none");
      if (!searchInput.classList.contains("d-none")) searchInput.focus();
    });
  }
});
