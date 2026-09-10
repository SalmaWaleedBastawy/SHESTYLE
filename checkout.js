/* ==========================================================================
   SHESTYLE — checkout.js
   Real multi-step checkout wired to the same cart (cart-store.js) and
   product catalog (PRODUCTS) the Cart page uses, with real validation and
   an order-placement flow that clears the cart at the end.
   ========================================================================== */
document.addEventListener('DOMContentLoaded', function () {

  var SHIPPING_FLAT = 5.99;
  var FREE_SHIPPING_THRESHOLD = 59;

  var checkoutLayout   = document.getElementById('checkoutLayout');
  var checkoutSteps    = document.getElementById('checkoutSteps');
  var checkoutEmpty    = document.getElementById('checkoutEmpty');
  var checkoutForm     = document.getElementById('checkoutForm');
  var checkoutConfirm  = document.getElementById('checkoutConfirmation');
  var primaryBtn       = document.getElementById('checkoutPrimaryBtn');

  var summaryItemsEl   = document.getElementById('summaryItems');
  var summarySubtotal  = document.getElementById('summarySubtotal');
  var summaryShipping  = document.getElementById('summaryShipping');
  var summaryTotal     = document.getElementById('summaryTotal');

  var panels = {
    1: document.getElementById('panelShipping'),
    2: document.getElementById('panelPayment'),
    3: document.getElementById('panelReview')
  };

  var stepButtons = checkoutSteps ? checkoutSteps.querySelectorAll('.checkout-step') : [];

  var currentStep = 1;
  var maxStepReached = 1;
  var rows = [];
  var totals = { subtotal: 0, shipping: 0, total: 0 };
  var shippingData = null;
  var paymentData = null;

  function formatMoney(value) { return '$' + value.toFixed(2); }

  function escapeHtml(str) {
    var div = document.createElement('div');
    div.textContent = str == null ? '' : str;
    return div.innerHTML;
  }

  /* ---------------- Cart loading + summary rendering ---------------- */

  function loadRows() {
    var cartItems = (typeof getCart === 'function') ? getCart() : [];
    var catalog = (typeof PRODUCTS !== 'undefined') ? PRODUCTS : [];

    var out = [];

    cartItems.forEach(function (item) {
      var product = null;

      for (var i = 0; i < catalog.length; i++) {
        if (catalog[i].id === item.id) {
          product = catalog[i];
          break;
        }
      }

      if (product) {
        out.push({ item: item, product: product });
      }
    });

    return out;
  }

  function renderSummary() {
    if (!summaryItemsEl) return;

    summaryItemsEl.innerHTML = rows.map(function (r) {

      var img = (r.product.images && r.product.images[0]) || '';

      return (
        '<div class="checkout-item">' +
          '<img class="checkout-item-thumb" src="' + img + '" alt="' + escapeHtml(r.product.name) + '">' +
          '<div class="checkout-item-info">' +
            '<span class="checkout-item-name">' + escapeHtml(r.product.name) + '</span>' +
            '<span class="checkout-item-qty">x' + r.item.qty + '</span>' +
          '</div>' +
          '<span class="checkout-item-price">' + formatMoney(r.product.price * r.item.qty) + '</span>' +
        '</div>'
      );

    }).join('');

    var subtotal = rows.reduce(function (sum, r) {
      return sum + r.product.price * r.item.qty;
    }, 0);

    var shipping =
      (subtotal === 0 || subtotal >= FREE_SHIPPING_THRESHOLD)
        ? 0
        : SHIPPING_FLAT;

    var total = subtotal + shipping;

    totals = {
      subtotal: subtotal,
      shipping: shipping,
      total: total
    };

    if (summarySubtotal) {
      summarySubtotal.textContent = formatMoney(subtotal);
    }

    if (summaryShipping) {
      summaryShipping.textContent =
        shipping === 0 ? 'FREE' : formatMoney(shipping);
    }

    if (summaryTotal) {
      summaryTotal.textContent = formatMoney(total);
    }
  }

  /* ---------------- Step navigation ---------------- */

  var stepLabels = {
    1: 'CONTINUE TO PAYMENT',
    2: 'CONTINUE TO REVIEW',
    3: 'PLACE ORDER'
  };

  function showStep(step) {

    currentStep = step;

    if (step > maxStepReached) {
      maxStepReached = step;
    }

    Object.keys(panels).forEach(function (key) {

      panels[key].style.display =
        (Number(key) === step) ? '' : 'none';

    });

    stepButtons.forEach(function (btn) {

      var btnStep = Number(btn.dataset.step);

      btn.classList.toggle('active', btnStep === step);
      btn.classList.toggle('done', btnStep < step);

    });

    if (primaryBtn) {
      primaryBtn.textContent =
        stepLabels[step] || 'CONTINUE';
    }

    window.scrollTo({
      top: checkoutForm.offsetTop - 100,
      behavior: 'smooth'
    });
  }

  stepButtons.forEach(function (btn) {

    btn.addEventListener('click', function () {

      var target = Number(btn.dataset.step);

      if (target <= maxStepReached && target < currentStep) {
        showStep(target);
      }

    });

  });

  checkoutForm.querySelectorAll('.checkout-back-btn, .review-edit')
    .forEach(function (btn) {

      btn.addEventListener('click', function () {
        showStep(Number(btn.dataset.backTo));
      });

    });

  /* ---------------- Field validation helpers ---------------- */

  function setFieldValid(input, isValid) {

    input.classList.toggle('is-invalid', !isValid);

    var errorEl =
      input.parentElement.querySelector('.field-error');

    if (errorEl) {
      errorEl.style.display =
        isValid ? 'none' : 'block';
    }

    return isValid;
  }

  function validateShipping() {

    var fullName   = document.getElementById('fullName');
    var email      = document.getElementById('email');
    var address    = document.getElementById('address');
    var city       = document.getElementById('city');
    var postalCode = document.getElementById('postalCode');
    var phone      = document.getElementById('phone');

    var emailOk =
      /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim());

    var phoneDigits =
      phone.value.replace(/\D/g, '');

    var ok = true;

    ok = setFieldValid(
      fullName,
      fullName.value.trim().length > 1
    ) && ok;

    ok = setFieldValid(
      email,
      emailOk
    ) && ok;

    ok = setFieldValid(
      address,
      address.value.trim().length > 3
    ) && ok;

    ok = setFieldValid(
      city,
      city.value.trim().length > 1
    ) && ok;

    ok = setFieldValid(
      postalCode,
      postalCode.value.trim().length > 1
    ) && ok;

    ok = setFieldValid(
      phone,
      phoneDigits.length >= 7
    ) && ok;

    if (ok) {

      shippingData = {
        fullName: fullName.value.trim(),
        email: email.value.trim(),
        address: address.value.trim(),
        city: city.value.trim(),
        postalCode: postalCode.value.trim(),
        phone: phone.value.trim()
      };

    }

    return ok;
  }

  function validatePayment() {

    var cardName   = document.getElementById('cardName');
    var cardNumber = document.getElementById('cardNumber');
    var cardExpiry = document.getElementById('cardExpiry');
    var cardCvv    = document.getElementById('cardCvv');

    var digits =
      cardNumber.value.replace(/\D/g, '');

    var expiryMatch =
      /^(\d{2})\/(\d{2})$/.exec(cardExpiry.value.trim());

    var expiryOk = false;

    if (expiryMatch) {

      var month =
        parseInt(expiryMatch[1], 10);

      var year =
        parseInt(expiryMatch[2], 10) + 2000;

      if (month >= 1 && month <= 12) {

        expiryOk =
          new Date(year, month) > new Date();

      }
    }

    var ok = true;

    ok = setFieldValid(
      cardName,
      cardName.value.trim().length > 1
    ) && ok;

    ok = setFieldValid(
      cardNumber,
      digits.length === 16
    ) && ok;

    ok = setFieldValid(
      cardExpiry,
      expiryOk
    ) && ok;

    ok = setFieldValid(
      cardCvv,
      /^\d{3}$/.test(cardCvv.value.trim())
    ) && ok;

    if (ok) {

      paymentData = {
        cardName: cardName.value.trim(),
        last4: digits.slice(-4),
        expiry: cardExpiry.value.trim()
      };

    }

    return ok;
  }

  function populateReview() {

    var reviewShipping =
      document.getElementById('reviewShipping');

    var reviewPayment =
      document.getElementById('reviewPayment');

    var reviewItems =
      document.getElementById('reviewItems');

    if (reviewShipping && shippingData) {

      reviewShipping.innerHTML =
        escapeHtml(shippingData.fullName) + '<br>' +
        escapeHtml(shippingData.address) + ', ' +
        escapeHtml(shippingData.city) + ' ' +
        escapeHtml(shippingData.postalCode) + '<br>' +
        escapeHtml(shippingData.email) + ' · ' +
        escapeHtml(shippingData.phone);

    }

    if (reviewPayment && paymentData) {

      reviewPayment.innerHTML =
        escapeHtml(paymentData.cardName) +
        '<br>Card ending in ' +
        escapeHtml(paymentData.last4) +
        ' · Expires ' +
        escapeHtml(paymentData.expiry);

    }

    if (reviewItems) {

      reviewItems.innerHTML = rows.map(function (r) {

        var img =
          (r.product.images && r.product.images[0]) || '';

        return (
          '<div class="checkout-item">' +
            '<img class="checkout-item-thumb" src="' + img + '" alt="' + escapeHtml(r.product.name) + '">' +
            '<div class="checkout-item-info">' +
              '<span class="checkout-item-name">' + escapeHtml(r.product.name) + '</span>' +
              '<span class="checkout-item-qty">x' + r.item.qty + '</span>' +
            '</div>' +
            '<span class="checkout-item-price">' +
              formatMoney(r.product.price * r.item.qty) +
            '</span>' +
          '</div>'
        );

      }).join('');

    }
  }

  /* ---------------- Place Order ---------------- */

  function placeOrder() {

    fetch('backend/checkout.php', {

      method: 'POST',

      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },

      body: new URLSearchParams({

        action: 'create',

        fullName: shippingData.fullName,
        email: shippingData.email,
        address: shippingData.address,
        city: shippingData.city,
        postalCode: shippingData.postalCode,
        phone: shippingData.phone

      })

    })

    .then(function (response) {
      return response.json();
    })

    .then(function (result) {

      if (!result.ok) {

        alert(result.error);
        return;

      }

      var orderNumber =
        '#' + result.order.orderId;

      document.getElementById('confirmOrderNumber').textContent =
        orderNumber;

      document.getElementById('confirmEmail').textContent =
        shippingData.email;

      /* Use the total calculated by the backend */
      document.getElementById('confirmTotal').textContent =
        formatMoney(Number(result.order.total));

      /* Clear the cart from localStorage */
      localStorage.removeItem('shestyle_cart');

      /* Update cart badge if the function exists */
      if (typeof updateCartBadges === 'function') {
        updateCartBadges();
      }

      checkoutLayout.style.display = 'none';
      checkoutSteps.style.display = 'none';
      checkoutForm.closest('.col-lg-8').style.display = 'none';
      checkoutConfirm.style.display = 'block';

    })

    .catch(function (error) {

      console.error(error);

      alert('Something went wrong while placing your order.');

    });

  }

  /* ---------------- Live input formatting ---------------- */

  var cardNumberInput =
    document.getElementById('cardNumber');

  if (cardNumberInput) {

    cardNumberInput.addEventListener('input', function () {

      var digits =
        cardNumberInput.value
          .replace(/\D/g, '')
          .slice(0, 16);

      cardNumberInput.value =
        digits.replace(/(.{4})/g, '$1 ').trim();

    });

  }

  var cardExpiryInput =
    document.getElementById('cardExpiry');

  if (cardExpiryInput) {

    cardExpiryInput.addEventListener('input', function () {

      var digits =
        cardExpiryInput.value
          .replace(/\D/g, '')
          .slice(0, 4);

      cardExpiryInput.value =
        digits.length > 2
          ? digits.slice(0, 2) + '/' + digits.slice(2)
          : digits;

    });

  }

  var cardCvvInput =
    document.getElementById('cardCvv');

  if (cardCvvInput) {

    cardCvvInput.addEventListener('input', function () {

      cardCvvInput.value =
        cardCvvInput.value
          .replace(/\D/g, '')
          .slice(0, 3);

    });

  }

  /* ---------------- Form submit drives the wizard ---------------- */

  checkoutForm.addEventListener('submit', function (e) {

    e.preventDefault();

    if (currentStep === 1) {

      if (validateShipping()) {
        showStep(2);
      }

      return;
    }

    if (currentStep === 2) {

      if (validatePayment()) {

        populateReview();
        showStep(3);

      }

      return;
    }

    if (currentStep === 3) {
      placeOrder();
    }

  });

  /* ---------------- Init ---------------- */

  rows = loadRows();

  if (rows.length === 0) {

    checkoutLayout.style.display = 'none';
    checkoutSteps.style.display = 'none';
    checkoutEmpty.style.display = 'block';

  } else {

    renderSummary();
    showStep(1);

  }

});