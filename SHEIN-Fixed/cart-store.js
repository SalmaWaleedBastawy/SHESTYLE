/* ==========================================================================
   SHESTYLE — cart-store.js
   Shared cart storage helpers (localStorage), used on every page.
   Cart is stored as an array of { id, qty } and joined against PRODUCTS
   (products-data.js) whenever it needs to be displayed in full.
   ========================================================================== */
const CART_KEY = "shestyle_cart";

function getCart() {
  try {
    return JSON.parse(localStorage.getItem(CART_KEY) || "[]");
  } catch (e) {
    return [];
  }
}

function saveCart(list) {
  localStorage.setItem(CART_KEY, JSON.stringify(list));
  updateCartBadges();
}

/* Adds qty of a product id to the cart (merging with any existing line). */
function addToCart(id, qty) {
  qty = qty || 1;
  var list = getCart();
  var item = null;
  for (var i = 0; i < list.length; i++) {
    if (list[i].id === id) { item = list[i]; break; }
  }
  if (item) {
    item.qty += qty;
  } else {
    list.push({ id: id, qty: qty });
  }
  saveCart(list);

  if (typeof showToast === 'function') {
    var product = (typeof PRODUCTS !== 'undefined') ? PRODUCTS.filter(function (p) { return p.id === id; })[0] : null;
    showToast((product ? product.name : 'Item') + ' added to cart');
  }

  // Notify any page UI that the cart changed immediately.
  try { window.dispatchEvent(new CustomEvent('shestyle:cart-updated', { detail: list })); } catch (e) {}
  return list;
}

function removeFromCart(id) {
  var list = getCart().filter(function (item) { return item.id !== id; });
  saveCart(list);
}

function setCartQty(id, qty) {
  var list = getCart();
  for (var i = 0; i < list.length; i++) {
    if (list[i].id === id) {
      list[i].qty = Math.max(1, qty);
      break;
    }
  }
  saveCart(list);
}

function getCartCount() {
  return getCart().reduce(function (sum, item) { return sum + item.qty; }, 0);
}

function updateCartBadges() {
  var n = getCartCount();
  document.querySelectorAll('.cart-count').forEach(function (el) { el.textContent = n; });
}

document.addEventListener('DOMContentLoaded', updateCartBadges);
