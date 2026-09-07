/* ==========================================================================
   SHESTYLE — cart.js
   Renders the real cart (stored via cart-store.js) by joining the saved
   {id, qty} lines against PRODUCTS. So this always shows exactly what
   was added — a different product every time, not fixed sample rows.
   ========================================================================== */

const SHIPPING_FLAT = 5.99;
const FREE_SHIPPING_THRESHOLD = 59;

function cartRowHTML(item, product) {
  var meta = [];
  if (product.colors && product.colors[0]) meta.push('Color: ' + product.colors[0].name);
  if (product.sizes && product.sizes[0] && product.sizes[0] !== 'One Size') meta.push('Size: ' + product.sizes[0]);
  var metaText = meta.length ? meta.join(' · ') : (product.category || '');
  var img = (product.images && product.images[0]) || '';
  var lineTotal = product.price * item.qty;

  return (
    '<div class="cart-row" data-id="' + product.id + '" data-price="' + product.price + '">' +
      '<div class="cart-col cart-col-product">' +
        '<img class="cart-thumb" src="' + img + '" alt="' + product.name + '">' +
        '<div>' +
          '<a class="cart-item-name" href="product-details.html?id=' + product.id + '">' + product.name + '</a>' +
          '<p class="cart-item-meta">' + metaText + '</p>' +
        '</div>' +
      '</div>' +
      '<div class="cart-col cart-col-price" data-label="Price">$' + product.price.toFixed(2) + '</div>' +
      '<div class="cart-col cart-col-qty" data-label="Quantity">' +
        '<div class="cart-qty">' +
          '<button type="button" class="cart-qty-btn cart-qty-minus" aria-label="Decrease quantity">−</button>' +
          '<input type="text" class="cart-qty-value" value="' + item.qty + '" readonly>' +
          '<button type="button" class="cart-qty-btn cart-qty-plus" aria-label="Increase quantity">+</button>' +
        '</div>' +
      '</div>' +
      '<div class="cart-col cart-col-total" data-label="Total">$' + lineTotal.toFixed(2) + '</div>' +
      '<div class="cart-col cart-col-remove">' +
        '<button type="button" class="cart-remove" aria-label="Remove item">×</button>' +
      '</div>' +
    '</div>'
  );
}

function renderCart() {
  var cartRowsEl = document.getElementById('cartRows');
  var cartTableEl = document.getElementById('cartTable');
  var cartEmptyEl = document.getElementById('cartEmpty');
  var continueLink = document.querySelector('.continue-shopping');
  if (!cartRowsEl) return;

  var cartItems = getCart();
  var list = (typeof PRODUCTS !== 'undefined') ? PRODUCTS : [];

  var rows = [];
  cartItems.forEach(function (item) {
    var product = null;
    for (var i = 0; i < list.length; i++) {
      if (list[i].id === item.id) { product = list[i]; break; }
    }
    if (product) rows.push({ item: item, product: product });
  });

  if (rows.length === 0) {
    if (cartTableEl) cartTableEl.style.display = 'none';
    if (continueLink) continueLink.style.display = 'none';
    if (cartEmptyEl) cartEmptyEl.classList.add('show');
    updateSummary(0);
    return;
  }

  if (cartTableEl) cartTableEl.style.display = '';
  if (continueLink) continueLink.style.display = '';
  if (cartEmptyEl) cartEmptyEl.classList.remove('show');

  cartRowsEl.innerHTML = rows.map(function (r) { return cartRowHTML(r.item, r.product); }).join('');

  var subtotal = rows.reduce(function (sum, r) { return sum + (r.product.price * r.item.qty); }, 0);
  updateSummary(subtotal);
  wireCartRows();
}

function updateSummary(subtotal) {
  var subtotalEl = document.getElementById('summarySubtotal');
  var shippingEl = document.getElementById('summaryShipping');
  var totalEl = document.getElementById('summaryTotal');

  var shipping = (subtotal === 0 || subtotal >= FREE_SHIPPING_THRESHOLD) ? 0 : SHIPPING_FLAT;
  var total = subtotal + shipping;

  if (subtotalEl) subtotalEl.textContent = '$' + subtotal.toFixed(2);
  if (shippingEl) shippingEl.textContent = shipping === 0 ? 'FREE' : '$' + shipping.toFixed(2);
  if (totalEl) totalEl.textContent = '$' + total.toFixed(2);
}

function wireCartRows() {
  document.querySelectorAll('#cartRows .cart-row').forEach(function (row) {
    var id = row.dataset.id;

    var minusBtn = row.querySelector('.cart-qty-minus');
    var plusBtn = row.querySelector('.cart-qty-plus');
    var removeBtn = row.querySelector('.cart-remove');

    if (minusBtn) {
      minusBtn.addEventListener('click', function () {
        var cartItems = getCart();
        var current = cartItems.filter(function (i) { return i.id === id; })[0];
        if (!current) return;
        if (current.qty <= 1) {
          removeFromCart(id);
        } else {
          setCartQty(id, current.qty - 1);
        }
        renderCart();
      });
    }

    if (plusBtn) {
      plusBtn.addEventListener('click', function () {
        var cartItems = getCart();
        var current = cartItems.filter(function (i) { return i.id === id; })[0];
        var newQty = current ? current.qty + 1 : 1;
        setCartQty(id, newQty);
        renderCart();
      });
    }

    if (removeBtn) {
      removeBtn.addEventListener('click', function () {
        row.classList.add('is-removing');
        window.setTimeout(function () {
          removeFromCart(id);
          renderCart();
        }, 150);
      });
    }
  });
}

document.addEventListener('DOMContentLoaded', renderCart);
