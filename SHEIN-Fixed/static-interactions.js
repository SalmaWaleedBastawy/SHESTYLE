/* SHESTYLE — interactions for legacy/static product cards */
document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.product-card[data-id]').forEach(function (card) {
    var id = card.dataset.id;
    var add = card.querySelector('[data-add-to-cart]');
    var wish = card.querySelector('.product-wish');

    if (add && !add._shestyleWired) {
      add._shestyleWired = true;
      add.setAttribute('data-add-to-cart', id);
      add.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        if (typeof addToCart === 'function') addToCart(id, 1);
        var original = add.dataset.originalLabel || 'ADD TO CART';
        add.dataset.originalLabel = original;
        add.textContent = 'ADDED ✓';
        add.classList.add('is-added');
        clearTimeout(add._resetTimer);
        add._resetTimer = setTimeout(function () {
          add.textContent = original;
          add.classList.remove('is-added');
        }, 1400);
      });
    }

    if (wish && !wish._shestyleWired) {
      wish._shestyleWired = true;
      var icon = wish.querySelector('i');
      var active = typeof isInWishlist === 'function' && isInWishlist(id);
      wish.classList.toggle('active', active);
      if (icon) {
        icon.classList.toggle('fa-regular', !active);
        icon.classList.toggle('fa-solid', active);
      }
      wish.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        var now = typeof toggleWishlist === 'function' ? toggleWishlist(id) : !wish.classList.contains('active');
        wish.classList.toggle('active', now);
        if (icon) {
          icon.classList.toggle('fa-regular', !now);
          icon.classList.toggle('fa-solid', now);
        }
      });
    }
  });
  if (typeof updateCartBadges === 'function') updateCartBadges();
});
