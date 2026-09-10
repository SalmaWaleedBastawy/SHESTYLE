/* ==========================================================================
   SHESTYLE — products.js
   Renders products from DATABASE + existing PRODUCTS data.
   Keeps the existing design, filters, wishlist, cart and sorting.
   ========================================================================== */

document.addEventListener('DOMContentLoaded', async function () {

  /* ---------- Elements ---------- */
  var cartCountEl    = document.querySelector('.cart-count');
  var productGrid    = document.querySelector('.col-lg-9 .row.g-4');
  var toolbarLabel   = document.querySelector('.toolbar span');
  var sortSelect     = document.querySelector('.sort-select');
  var searchInput    = document.querySelector('.search-box');
  var categoryRadios = document.querySelectorAll('input[name="cat"]');
  var swatches       = document.querySelectorAll('.swatch');
  var newsletterBtn  = document.querySelector('.site-footer .btn-light');
  var catHeading     = document.getElementById('category-heading');

  var cartCount = parseInt(
    (cartCountEl && cartCountEl.textContent) || '0',
    10
  ) || 0;


  /* ---------- URL Category ---------- */

  var params      = new URLSearchParams(window.location.search);
  var urlCategory = params.get('category');


  /* ---------- Existing Frontend Products ---------- */

  var frontendProducts =
    (typeof PRODUCTS !== 'undefined') ? PRODUCTS : [];

  var baseList = [];


  /* ==========================================================
     GET PRODUCTS FROM DATABASE
     ========================================================== */

  try {

    var response = await fetch('backend/products.php');

    var result = await response.json();

    if (!result.ok) {
      console.log(result.error);
      return;
    }


    /* ----------------------------------------------------------
       Merge Database data with existing frontend data
       ---------------------------------------------------------- */

    baseList = result.products.map(function (dbProduct) {

      /*
       * Find the same product inside products-data.js
       * using ProductName.
       */

      var frontendProduct = frontendProducts.find(function (p) {

        return p.name.toLowerCase().trim() ===
               dbProduct.ProductName.toLowerCase().trim();

      });


      /*
       * If the product exists in frontend data,
       * keep all its images, colors, sizes, etc.
       */

      if (frontendProduct) {

        frontendProduct.dbId = dbProduct.ProductID;

        frontendProduct.name = dbProduct.ProductName;

        frontendProduct.description =
          dbProduct.Description;

        frontendProduct.price =
          Number(dbProduct.Price);

        frontendProduct.originalPrice =
          dbProduct.OriginalPrice !== null
            ? Number(dbProduct.OriginalPrice)
            : null;

        frontendProduct.stock =
          Number(dbProduct.Stock);

        return frontendProduct;
      }


      /*
       * If the product is in the database but not
       * in products-data.js, create a basic product.
       */

      return {

        id: 'db-' + dbProduct.ProductID,

        dbId: dbProduct.ProductID,

        name: dbProduct.ProductName,

        description: dbProduct.Description,

        price: Number(dbProduct.Price),

        originalPrice:
          dbProduct.OriginalPrice !== null
            ? Number(dbProduct.OriginalPrice)
            : null,

        stock: Number(dbProduct.Stock),

        category: '',

        sections: [],

        images: [],

        colors: [],

        sizes: [],

        rating: 0,

        reviewCount: 0,

        details: ''

      };

    });


  }
  catch (error) {

    console.error(
      'Error loading products from database:',
      error
    );

    return;
  }


  /* ==========================================================
     FILTER BY URL CATEGORY
     ========================================================== */

  if (urlCategory && urlCategory !== 'all') {

    baseList = baseList.filter(function (p) {

      return p.sections &&
             p.sections.indexOf(urlCategory) !== -1;

    });

  }


  /* ---------- Category Heading ---------- */

  if (catHeading) {

    catHeading.textContent =
      urlCategory
        ? urlCategory.toUpperCase()
        : 'ALL PRODUCTS';

  }


  /* ---------- Highlight Navigation ---------- */

  document.querySelectorAll(
    '.nav-link, .tab-link'
  ).forEach(function (link) {

    link.classList.remove('active');

    var href =
      link.getAttribute('href') || '';

    if (
      urlCategory &&
      href.indexOf(
        'category=' + urlCategory
      ) !== -1
    ) {

      link.classList.add('active');

    }

  });


  /* ==========================================================
     PRODUCT CARD
     ========================================================== */

  function cardHTML(product) {

    var img =
      (product.images && product.images[0]) || '';

    var liked =
      (typeof isInWishlist === 'function') &&
      isInWishlist(product.id);

    var wishClass =
      'product-wish' +
      (liked ? ' active' : '');

    var heartIconClass =
      liked ? 'fa-solid' : 'fa-regular';


    return (

      '<div class="col-6 col-md-4">' +

        '<div class="product-card"' +
          ' data-id="' + product.id + '"' +
          ' data-db-id="' + (product.dbId || '') + '"' +
          ' data-category="' + (product.category || '') + '"' +
          ' data-price="' + product.price + '">' +

          '<div class="product-media">' +

            '<a href="product-details.html?id=' +
              product.id +
            '">' +

              '<img src="' +
                img +
              '" alt="' +
                product.name +
              '">' +

            '</a>' +

            '<button class="' +
              wishClass +
              '" aria-label="Add to wishlist">' +

              '<i class="' +
                heartIconClass +
                ' fa-heart"></i>' +

            '</button>' +

            '<button class="product-add-line border-0 w-100"' +
              ' data-add-to-cart="' +
                product.id +
              '">' +

              'ADD TO CART' +

            '</button>' +

          '</div>' +

          '<a href="product-details.html?id=' +
            product.id +
          '">' +

            '<div class="product-name">' +
              product.name +
            '</div>' +

          '</a>' +

          '<div class="product-price">' +

            (
              product.originalPrice
                ?

                '<span class="price-original">$' +
                  product.originalPrice.toFixed(2) +
                '</span> ' +

                '<span class="price-sale">$' +
                  product.price.toFixed(2) +
                '</span>'

                :

                '$' +
                product.price.toFixed(2)
            ) +

          '</div>' +

        '</div>' +

      '</div>'

    );

  }


  /* ==========================================================
     RENDER GRID
     ========================================================== */

  function renderGrid(list) {

    if (!productGrid) return;

    productGrid.innerHTML =
      list.map(cardHTML).join('');

    wireCardEvents();

    updateToolbarLabel(
      list.length,
      list.length === baseList.length
    );

    toggleEmptyState(
      list.length === 0
    );

  }


  /* ==========================================================
     CART / WISHLIST
     ========================================================== */

  function wireCardEvents() {

    document.querySelectorAll(
      '[data-add-to-cart]'
    ).forEach(function (btn) {

      btn.addEventListener(
        'click',
        function (e) {

          e.preventDefault();

          var id =
            btn.getAttribute(
              'data-add-to-cart'
            );

          if (
            id &&
            typeof addToCart === 'function'
          ) {

            addToCart(id, 1);

          }


          var originalText =
            btn.dataset.originalLabel ||
            btn.textContent;

          btn.dataset.originalLabel =
            originalText;

          btn.textContent =
            'ADDED ✓';

          btn.classList.add(
            'is-added'
          );


          window.clearTimeout(
            btn._resetTimer
          );

          btn._resetTimer =
            window.setTimeout(
              function () {

                btn.textContent =
                  originalText;

                btn.classList.remove(
                  'is-added'
                );

              },
              1400
            );

        }
      );

    });


    /* ---------- Wishlist ---------- */

    document.querySelectorAll(
      '.product-wish'
    ).forEach(function (btn) {

      btn.addEventListener(
        'click',
        function (e) {

          e.preventDefault();

          var card =
            btn.closest('.product-card');

          var id =
            card
              ? card.dataset.id
              : null;

          var icon =
            btn.querySelector('i');

          var active;


          if (
            id &&
            typeof toggleWishlist === 'function'
          ) {

            active =
              toggleWishlist(id);

          }
          else {

            active =
              !btn.classList.contains(
                'active'
              );

          }


          btn.classList.toggle(
            'active',
            active
          );


          if (icon) {

            icon.classList.toggle(
              'fa-regular',
              !active
            );

            icon.classList.toggle(
              'fa-solid',
              active
            );

          }

        }
      );

    });

  }


  /* ==========================================================
     CATEGORY FILTER
     ========================================================== */

  categoryRadios.forEach(
    function (radio) {

      radio.addEventListener(
        'change',
        applyFilters
      );

    }
  );


  /* ==========================================================
     SEARCH
     ========================================================== */

  if (searchInput) {

    searchInput.addEventListener(
      'input',
      applyFilters
    );

  }


  function getActiveSubCategory() {

    var checked =
      document.querySelector(
        'input[name="cat"]:checked'
      );

    return checked
      ? checked.value
      : 'all';

  }


  function applyFilters() {

    var subCategory =
      getActiveSubCategory();

    var query =
      searchInput
        ? searchInput.value
            .trim()
            .toLowerCase()
        : '';


    var filtered =
      baseList.filter(
        function (p) {

          var matchesSub =
            subCategory === 'all' ||
            p.category === subCategory;


          var matchesQuery =
            query === '' ||
            p.name
              .toLowerCase()
              .indexOf(query) !== -1;


          return (
            matchesSub &&
            matchesQuery
          );

        }
      );


    renderGrid(filtered);

  }


  /* ==========================================================
     TOOLBAR
     ========================================================== */

  function updateToolbarLabel(
    visibleCount,
    isFullBaseList
  ) {

    if (!toolbarLabel) return;


    if (isFullBaseList) {

      toolbarLabel.textContent =
        'Showing 1–' +
        visibleCount +
        ' of ' +
        visibleCount +
        ' results';

    }
    else {

      toolbarLabel.textContent =
        'Showing ' +
        visibleCount +
        ' of ' +
        visibleCount +
        ' results';

    }

  }


  /* ==========================================================
     EMPTY STATE
     ========================================================== */

  function toggleEmptyState(
    isEmpty
  ) {

    var empty =
      document.querySelector(
        '.no-results'
      );


    if (!empty && productGrid) {

      empty =
        document.createElement(
          'div'
        );

      empty.className =
        'no-results';

      empty.textContent =
        'No products match your search or filters.';

      productGrid.parentNode.insertBefore(
        empty,
        productGrid.nextSibling
      );

    }


    if (empty) {

      empty.classList.toggle(
        'show',
        isEmpty
      );

    }

  }


  /* ==========================================================
     COLOR SWATCH
     ========================================================== */

  swatches.forEach(
    function (swatch) {

      swatch.addEventListener(
        'click',
        function () {

          swatches.forEach(
            function (s) {

              s.classList.remove(
                'active'
              );

            }
          );


          swatch.classList.add(
            'active'
          );

        }
      );

    }
  );


  /* ==========================================================
     SORT
     ========================================================== */

  if (
    sortSelect &&
    productGrid
  ) {

    sortSelect.addEventListener(
      'change',
      function () {

        var mode =
          sortSelect.value;

        var cols =
          Array.prototype.slice.call(
            productGrid.children
          );


        cols.sort(
          function (a, b) {

            var cardA =
              a.querySelector(
                '.product-card'
              );

            var cardB =
              b.querySelector(
                '.product-card'
              );


            var priceA =
              parseFloat(
                cardA.dataset.price
              ) || 0;

            var priceB =
              parseFloat(
                cardB.dataset.price
              ) || 0;


            if (
              mode.indexOf(
                'Low to High'
              ) !== -1
            ) {

              return priceA - priceB;

            }


            if (
              mode.indexOf(
                'High to Low'
              ) !== -1
            ) {

              return priceB - priceA;

            }


            return 0;

          }
        );


        cols.forEach(
          function (col) {

            productGrid.appendChild(
              col
            );

          }
        );

      }
    );

  }


  /* ==========================================================
     NEWSLETTER
     ========================================================== */

  if (newsletterBtn) {

    newsletterBtn.addEventListener(
      'click',
      function (e) {

        e.preventDefault();

        var input =
          newsletterBtn.parentElement
            .querySelector(
              'input[type="email"]'
            );


        if (
          !input ||
          !input.value.trim()
        ) {

          if (input) {
            input.focus();
          }

          return;

        }


        var originalLabel =
          newsletterBtn.textContent;

        newsletterBtn.textContent =
          'Joined ✓';

        input.value = '';


        window.setTimeout(
          function () {

            newsletterBtn.textContent =
              originalLabel;

          },
          1800
        );

      }
    );

  }


  /* ==========================================================
     PAGINATION
     ========================================================== */

  document.querySelectorAll(
    '.pagination-min a'
  ).forEach(
    function (link) {

      link.addEventListener(
        'click',
        function (e) {

          e.preventDefault();

          if (
            link.textContent.trim() ===
            '…'
          ) {
            return;
          }


          document.querySelectorAll(
            '.pagination-min a'
          ).forEach(
            function (a) {

              a.classList.remove(
                'active'
              );

            }
          );


          link.classList.add(
            'active'
          );


          window.scrollTo({
            top: 0,
            behavior: 'smooth'
          });

        }
      );

    }
  );


  /* ==========================================================
     INITIAL RENDER
     ========================================================== */

  renderGrid(baseList);

document.addEventListener("wishlistUpdated", function () {
    renderGrid(baseList);
});
});