/* ==========================================================================
   SHESTYLE — products-details.js
   Loads the product matching ?id= from PRODUCTS (products-data.js +
   products-data-extra.js) and renders its own gallery, price, rating,
   colors, sizes and details — so every product opens its own page instead
   of always showing the same one.
   ========================================================================== */
document.addEventListener('DOMContentLoaded', function () {

  var params = new URLSearchParams(window.location.search);
  var productId = params.get('id');

  var list = (typeof PRODUCTS !== 'undefined') ? PRODUCTS : [];
  var product = null;
  for (var i = 0; i < list.length; i++) {
    if (list[i].id === productId) { product = list[i]; break; }
  }

  var pdInfo = document.querySelector('.pd-info');
  var pdGallery = document.querySelector('.pd-gallery');

  if (!product) {
    if (pdInfo) {
      pdInfo.innerHTML = '<h1 class="pd-title">Product not found</h1>' +
        '<p>Sorry, we couldn\'t find that product.</p>' +
        '<a class="btn-add-to-cart d-inline-block text-decoration-none text-center" href="index.html">BACK TO HOME</a>';
    }
    if (pdGallery) pdGallery.style.display = 'none';
    return;
  }

  /* ---------- Elements ---------- */
  var pageTitle      = document.getElementById('pdPageTitle');
  var currentProduct  = document.getElementById('current-product');
  var pdTitle         = document.getElementById('pdTitle');
  var pdPrice         = document.getElementById('pdPrice');
  var pdStars         = document.getElementById('pdStars');
  var pdRatingCount   = document.getElementById('pdRatingCount');
  var pdColorGroup    = document.getElementById('pdColorGroup');
  var pdColorList     = document.getElementById('pdColorList');
  var selectedColorName = document.getElementById('selectedColorName');
  var pdSizeGroup     = document.getElementById('pdSizeGroup');
  var pdSizeList      = document.getElementById('pdSizeList');
  var sizeWarning     = document.getElementById('sizeWarning');
  var pdThumbList     = document.getElementById('pdThumbList');
  var mainImage       = document.getElementById('pdMainImage');
  var pdDescription   = document.getElementById('pdDescription');
  var pdDetailsList   = document.getElementById('pdDetailsList');
  var qtyMinus        = document.getElementById('qtyMinus');
  var qtyPlus         = document.getElementById('qtyPlus');
  var qtyValue        = document.getElementById('qtyValue');
  var addToCartBtn    = document.getElementById('addToCartBtn');
  var wishlistBtn     = document.getElementById('wishlistBtn');
  var cartConfirm     = document.getElementById('cartConfirm');
  var deliveryToggle  = document.getElementById('deliveryToggle');
  var deliveryPanel   = document.getElementById('deliveryPanel');

  var MIN_QTY = 1;
  var MAX_QTY = 10;
  var selectedSize = null;
  var selectedColor = (product.colors && product.colors[0]) || null;

  /* ---------- Basic text/price/rating ---------- */
  if (pageTitle) pageTitle.textContent = product.name + ' — SHESTYLE';
  if (currentProduct) currentProduct.textContent = product.name;
  if (pdTitle) pdTitle.textContent = product.name;

  if (pdPrice) {
    pdPrice.innerHTML = product.originalPrice
      ? '<span class="price-original">$' + product.originalPrice.toFixed(2) + '</span> <span class="price-sale">$' + product.price.toFixed(2) + '</span>'
      : '$' + product.price.toFixed(2);
  }

  if (pdStars) {
    var rating = product.rating || 4.5;
    var full = Math.floor(rating);
    var half = (rating - full) >= 0.5;
    var starsHTML = '';
    for (var s = 0; s < full; s++) starsHTML += '<i class="fa-solid fa-star"></i>';
    if (half) starsHTML += '<i class="fa-solid fa-star-half-stroke"></i>';
    var remaining = 5 - full - (half ? 1 : 0);
    for (var s2 = 0; s2 < remaining; s2++) starsHTML += '<i class="fa-regular fa-star"></i>';
    pdStars.innerHTML = starsHTML;
  }
  if (pdRatingCount) pdRatingCount.textContent = '(' + (product.reviewCount || 0) + ')';

  /* ---------- Gallery ---------- */
  var images = (product.images && product.images.length) ? product.images : [''];
  if (pdThumbList) {
    pdThumbList.innerHTML = images.map(function (img, idx) {
      return '<button class="pd-thumb' + (idx === 0 ? ' active' : '') + '" data-full="' + img + '">' +
        '<img src="' + img + '" alt="' + product.name + '">' +
        '</button>';
    }).join('');
  }
  if (mainImage) {
    mainImage.src = images[0];
    mainImage.alt = product.name;
  }
  if (pdThumbList) {
    pdThumbList.querySelectorAll('.pd-thumb').forEach(function (thumb) {
      thumb.addEventListener('click', function () {
        pdThumbList.querySelectorAll('.pd-thumb').forEach(function (t) { t.classList.remove('active'); });
        thumb.classList.add('active');
        if (mainImage && thumb.dataset.full) mainImage.src = thumb.dataset.full;
      });
    });
  }

  /* ---------- Colors ---------- */
  if (product.colors && product.colors.length) {
    if (selectedColorName) selectedColorName.textContent = selectedColor ? selectedColor.name : '';
    if (pdColorList) {
      pdColorList.innerHTML = product.colors.map(function (c, idx) {
        return '<button class="pd-color' + (idx === 0 ? ' active' : '') + '" style="background:' + c.hex + '" data-color="' + c.name + '" aria-label="' + c.name + '"></button>';
      }).join('');
      pdColorList.querySelectorAll('.pd-color').forEach(function (btn) {
        btn.addEventListener('click', function () {
          pdColorList.querySelectorAll('.pd-color').forEach(function (b) { b.classList.remove('active'); });
          btn.classList.add('active');
          if (selectedColorName) selectedColorName.textContent = btn.dataset.color || '';
        });
      });
    }
  } else if (pdColorGroup) {
    pdColorGroup.style.display = 'none';
  }

  /* ---------- Sizes ---------- */
  var sizes = product.sizes || [];
  if (sizes.length) {
    if (pdSizeList) {
      pdSizeList.innerHTML = sizes.map(function (sz) {
        return '<button class="pd-size" data-size="' + sz + '">' + sz + '</button>';
      }).join('');
      pdSizeList.querySelectorAll('.pd-size').forEach(function (btn) {
        btn.addEventListener('click', function () {
          pdSizeList.querySelectorAll('.pd-size').forEach(function (b) { b.classList.remove('active'); });
          btn.classList.add('active');
          selectedSize = btn.dataset.size;
          if (sizeWarning) sizeWarning.classList.remove('show');
        });
      });
    }
    /* Auto-select the first size so ADD TO CART works immediately.
       The shopper can still change it before adding. */
    if (pdSizeList) {
      var firstSizeBtn = pdSizeList.querySelector('.pd-size');
      if (firstSizeBtn) {
        firstSizeBtn.classList.add('active');
        selectedSize = firstSizeBtn.dataset.size;
      }
    }
  } else if (pdSizeGroup) {
    pdSizeGroup.style.display = 'none';
    selectedSize = 'One Size';
  }

  /* ---------- Description & details ---------- */
  if (pdDescription) pdDescription.textContent = product.description || '';
  if (pdDetailsList) {
    pdDetailsList.innerHTML = (product.details || []).map(function (d) {
      return '<li>' + d + '</li>';
    }).join('');
  }

  /* ---------- Quantity stepper ---------- */
  function setQty(value) {
    var clamped = Math.min(MAX_QTY, Math.max(MIN_QTY, value));
    if (qtyValue) qtyValue.value = clamped;
    return clamped;
  }

  if (qtyMinus) {
    qtyMinus.addEventListener('click', function () {
      var current = parseInt(qtyValue.value, 10) || MIN_QTY;
      setQty(current - 1);
    });
  }

  if (qtyPlus) {
    qtyPlus.addEventListener('click', function () {
      var current = parseInt(qtyValue.value, 10) || MIN_QTY;
      setQty(current + 1);
    });
  }

  /* ---------- Add to cart ---------- */
  if (addToCartBtn) {
    addToCartBtn.addEventListener('click', function () {
      if (!selectedSize) {
        if (sizeWarning) sizeWarning.classList.add('show');
        var sizeGroupEl = document.querySelector('.pd-size-list');
        if (sizeGroupEl) sizeGroupEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
        return;
      }

      var qty = parseInt((qtyValue && qtyValue.value) || '1', 10) || 1;
      if (typeof addToCart === 'function') addToCart(product.id, qty);

      if (cartConfirm) cartConfirm.classList.add('show');

      addToCartBtn.textContent = 'ADDED ✓';
      window.clearTimeout(addToCartBtn._resetTimer);
      addToCartBtn._resetTimer = window.setTimeout(function () {
        addToCartBtn.textContent = 'ADD TO CART';
      }, 1600);
    });
  }

  /* ---------- Wishlist toggle ---------- */
  if (wishlistBtn) {
    var alreadyLiked = (typeof isInWishlist === 'function') && isInWishlist(product.id);
    function renderWishlistState(active) {
      var icon = wishlistBtn.querySelector('i');
      wishlistBtn.classList.toggle('active', active);
      if (icon) {
        icon.classList.toggle('fa-regular', !active);
        icon.classList.toggle('fa-solid', active);
      }
      var label = wishlistBtn.childNodes[wishlistBtn.childNodes.length - 1];
      if (label) {
        label.textContent = active ? ' ADDED TO WISHLIST' : ' ADD TO WISHLIST';
      }
    }
    renderWishlistState(alreadyLiked);

    wishlistBtn.addEventListener('click', function () {
      var active = (typeof toggleWishlist === 'function') ? toggleWishlist(product.id) : !wishlistBtn.classList.contains('active');
      renderWishlistState(active);
    });
  }

  /* ---------- Delivery & Return accordion ---------- */
  if (deliveryToggle && deliveryPanel) {
    deliveryToggle.addEventListener('click', function () {
      var isOpen = deliveryToggle.getAttribute('aria-expanded') === 'true';
      deliveryToggle.setAttribute('aria-expanded', String(!isOpen));

      if (isOpen) {
        deliveryPanel.style.maxHeight = null;
      } else {
        deliveryPanel.style.maxHeight = deliveryPanel.scrollHeight + 'px';
      }
    });
  }

});
