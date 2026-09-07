/* ==========================================================================
   SHESTYLE — catalog.js
   Shared product-card renderer used by every category page (shoes, men,
   kids, beauty-health, baby-maternity, bags-luggage, office-school-supplies)
   so every page shows real products that link to their own detail page,
   and whose wishlist/cart buttons behave the same way everywhere.
   ========================================================================== */

function shestyleCardHTML(product) {
  var img = (product.images && product.images[0]) || '';
  var liked = (typeof isInWishlist === 'function') && isInWishlist(product.id);
  var wishClass = 'product-wish' + (liked ? ' active' : '');
  var heartIconClass = liked ? 'fa-solid' : 'fa-regular';
  return (
    '<div class="col-6 col-md-3">' +
      '<div class="product-card" data-id="' + product.id + '" data-category="' + product.category + '" data-price="' + product.price + '">' +
        '<div class="product-media">' +
          '<a href="product-details.html?id=' + product.id + '">' +
            '<img src="' + img + '" alt="' + product.name + '" loading="lazy">' +
          '</a>' +
          '<button class="' + wishClass + '" aria-label="Add to wishlist"><i class="' + heartIconClass + ' fa-heart"></i></button>' +
          '<button class="product-add-line border-0 w-100" data-add-to-cart="' + product.id + '">ADD TO CART</button>' +
        '</div>' +
        '<a href="product-details.html?id=' + product.id + '"><div class="product-name">' + product.name + '</div></a>' +
        '<div class="product-price">' +
          (product.originalPrice
            ? '<span class="price-original">$' + product.originalPrice.toFixed(2) + '</span> <span class="price-sale">$' + product.price.toFixed(2) + '</span>'
            : '$' + product.price.toFixed(2)) +
        '</div>' +
      '</div>' +
    '</div>'
  );
}

/* Wires add-to-cart / wishlist buttons inside `container` (defaults to the
   whole document). Safe to call more than once — already-wired buttons are
   skipped so listeners are never attached twice. */
function shestyleWireCards(container) {
  container = container || document;

  container.querySelectorAll('[data-add-to-cart]').forEach(function (btn) {
    if (btn._shestyleWired) return;
    btn._shestyleWired = true;
    btn.addEventListener('click', function (e) {
      e.preventDefault();
      var id = btn.getAttribute('data-add-to-cart');
      if (id && typeof addToCart === 'function') addToCart(id, 1);

      var originalText = btn.dataset.originalLabel || btn.textContent;
      btn.dataset.originalLabel = originalText;
      btn.textContent = 'ADDED ✓';
      btn.classList.add('is-added');

      window.clearTimeout(btn._resetTimer);
      btn._resetTimer = window.setTimeout(function () {
        btn.textContent = originalText;
        btn.classList.remove('is-added');
      }, 1400);
    });
  });

  container.querySelectorAll('.product-wish').forEach(function (btn) {
    if (btn._shestyleWired) return;
    btn._shestyleWired = true;
    btn.addEventListener('click', function (e) {
      e.preventDefault();
      var card = btn.closest('.product-card');
      var id = card ? card.dataset.id : null;
      var icon = btn.querySelector('i');
      var active = (id && typeof toggleWishlist === 'function') ? toggleWishlist(id) : false;
      btn.classList.toggle('active', active);
      if (icon) {
        icon.classList.toggle('fa-regular', !active);
        icon.classList.toggle('fa-solid', active);
      }
    });
  });
}

/* Renders every PRODUCTS item whose `sections` array includes `sectionKey`
   into the element matched by `gridSelector`, then wires its buttons. */
function shestyleRenderSection(gridSelector, sectionKey) {
  var grid = document.querySelector(gridSelector);
  if (!grid || typeof PRODUCTS === 'undefined') return;

  var list = PRODUCTS.filter(function (p) {
    return p.sections && p.sections.indexOf(sectionKey) !== -1;
  });

  grid.innerHTML = list.map(shestyleCardHTML).join('');
  shestyleWireCards(grid);
}
