/* ==========================================================================
   SHESTYLE — admin.js
   Admin Dashboard + Products Management
   ========================================================================== */

document.addEventListener('DOMContentLoaded', function () {

  var catalog = (typeof PRODUCTS !== 'undefined') ? PRODUCTS : [];

  var adminData = null;
  var dbProducts = [];
  var categories = [];


  /* ==========================================================
     Helpers
     ========================================================== */

  function formatMoney(value) {

    return '$' + Number(value || 0).toFixed(2);

  }


  function formatDate(date) {

    var d = new Date(date);

    if (isNaN(d)) {
      return date;
    }

    return d.toLocaleDateString('en-US', {
      day: '2-digit',
      month: 'short',
      year: 'numeric'
    });

  }


  function escapeHtml(str) {

    var div = document.createElement('div');

    div.textContent = str == null ? '' : str;

    return div.innerHTML;

  }


  function statusClass(status) {

    var s = (status || '').toLowerCase();

    if (s === 'delivered') {
      return 'status-delivered';
    }

    if (s === 'shipped') {
      return 'status-shipped';
    }

    if (s === 'cancelled') {
      return 'status-cancelled';
    }

    return 'status-processing';

  }


  /* ==========================================================
     Tab Switching
     ========================================================== */

  var navLinks =
    document.querySelectorAll('.admin-nav-link');

  var panels =
    document.querySelectorAll('.admin-panel');


  function activateTab(tab) {

    navLinks.forEach(function (link) {

      link.classList.toggle(
        'active',
        link.dataset.tab === tab
      );

    });


    panels.forEach(function (panel) {

      panel.classList.toggle(
        'd-none',
        panel.id !== 'tab-' + tab
      );

    });

  }


  navLinks.forEach(function (link) {

    link.addEventListener('click', function () {

      activateTab(link.dataset.tab);

    });

  });


  document
    .querySelectorAll('[data-goto-tab]')
    .forEach(function (button) {

      button.addEventListener('click', function () {

        activateTab(button.dataset.gotoTab);

      });

    });


  /* ==========================================================
     Logout
     ========================================================== */

  var logoutBtn =
    document.getElementById('adminLogout');


  if (logoutBtn) {

    logoutBtn.addEventListener('click', function () {

      if (typeof logoutUser === 'function') {

        logoutUser();

      }

      window.location.href = 'login.html';

    });

  }


  /* ==========================================================
     Dashboard
     ========================================================== */

  function renderDashboard() {

    if (!adminData) {
      return;
    }


    var stats =
      adminData.stats;


    /* ---------- Statistics ---------- */

    var statOrders =
      document.getElementById('statOrders');

    var statProducts =
      document.getElementById('statProducts');

    var statUsers =
      document.getElementById('statUsers');

    var statSales =
      document.getElementById('statSales');


    if (statOrders) {
      statOrders.textContent = stats.orders;
    }


    if (statProducts) {
      statProducts.textContent = stats.products;
    }


    if (statUsers) {
      statUsers.textContent = stats.users;
    }


    if (statSales) {
      statSales.textContent =
        formatMoney(stats.sales);
    }


    /* ---------- Recent Orders ---------- */

    var recentBody =
      document.getElementById('recentOrdersBody');

    var recentEmpty =
      document.getElementById('recentOrdersEmpty');


    var recentOrders =
      adminData.recentOrders || [];


    if (recentOrders.length === 0) {

      if (recentBody) {
        recentBody.innerHTML = '';
      }

      if (recentEmpty) {
        recentEmpty.style.display = 'block';
      }

    }

    else {

      if (recentEmpty) {
        recentEmpty.style.display = 'none';
      }


      if (recentBody) {

        recentBody.innerHTML =
          recentOrders.map(function (order) {

            return (

              '<tr>' +

                '<td>' +
                  escapeHtml(order.OrderNumber) +
                '</td>' +

                '<td>' +
                  escapeHtml(
                    order.FullName || '—'
                  ) +
                '</td>' +

                '<td>' +
                  formatMoney(order.TotalAmount) +
                '</td>' +

                '<td>' +
                  formatDate(order.OrderDate) +
                '</td>' +

                '<td>' +

                  '<span class="status-badge ' +
                  statusClass(order.Status) +
                  '">' +

                    escapeHtml(
                      order.Status || 'Pending'
                    ) +

                  '</span>' +

                '</td>' +

              '</tr>'

            );

          }).join('');

      }

    }


    /* ---------- Top Products ---------- */

    var topListEl =
      document.getElementById('topProductsList');

    var topEmptyEl =
      document.getElementById('topProductsEmpty');


    var topProducts =
      adminData.topProducts || [];


    if (topProducts.length === 0) {

      if (topListEl) {
        topListEl.innerHTML = '';
      }

      if (topEmptyEl) {
        topEmptyEl.style.display = 'block';
      }

    }

    else {

      if (topEmptyEl) {
        topEmptyEl.style.display = 'none';
      }


      if (topListEl) {

        topListEl.innerHTML =
          topProducts.map(function (productData) {

            var product =
              catalog.filter(function (item) {

                return (
                  item.name &&
                  productData.ProductName &&
                  item.name.toLowerCase() ===
                  productData.ProductName.toLowerCase()
                );

              })[0];


            var img =
              product &&
              product.images
                ? product.images[0]
                : '';


            return (

              '<div class="top-product-row">' +

                '<img src="' +
                  img +
                  '" alt="' +
                  escapeHtml(
                    productData.ProductName
                  ) +
                '">' +

                '<div class="top-product-info">' +

                  '<span class="top-product-name">' +
                    escapeHtml(
                      productData.ProductName
                    ) +
                  '</span>' +

                  '<span class="top-product-sold">' +
                    productData.SoldQuantity +
                    ' sold' +
                  '</span>' +

                '</div>' +

              '</div>'

            );

          }).join('');

      }

    }

  }


  /* ==========================================================
     Categories
     ========================================================== */

  function getCategoryName(categoryID) {

    var category =
      categories.find(function (item) {

        return Number(item.CategoryID) ===
               Number(categoryID);

      });


    if (category) {

      return category.CategoryName;

    }


    return '—';

  }


  /* ==========================================================
     Products
     ========================================================== */

  function renderProducts(filterText) {

    var body =
      document.getElementById('productsBody');


    if (!body) {
      return;
    }


    var q =
      (filterText || '')
      .trim()
      .toLowerCase();


    var list =
      dbProducts.filter(function (product) {

        var productName =
          (product.ProductName || '')
          .toLowerCase();


        var categoryName =
          getCategoryName(product.CategoryID)
          .toLowerCase();


        return (
          !q ||
          productName.indexOf(q) !== -1 ||
          categoryName.indexOf(q) !== -1
        );

      });


    body.innerHTML =
      list.map(function (product) {

        return (

          '<tr>' +

            '<td>—</td>' +

            '<td>' +
              escapeHtml(
                product.ProductName
              ) +
            '</td>' +

            '<td>' +
              escapeHtml(
                getCategoryName(
                  product.CategoryID
                )
              ) +
            '</td>' +

            '<td>' +
              formatMoney(product.Price) +
            '</td>' +

            '<td>' +
              escapeHtml(product.Stock) +
            '</td>' +

            '<td>' +

              '<button ' +
                'type="button" ' +
                'class="btn btn-sm btn-primary edit-product" ' +
                'data-id="' +
                  product.ProductID +
              '">' +
                'Edit' +
              '</button> ' +

              '<button ' +
                'type="button" ' +
                'class="btn btn-sm btn-danger delete-product" ' +
                'data-id="' +
                  product.ProductID +
              '">' +
                'Deactivate' +
              '</button>' +

            '</td>' +

          '</tr>'

        );

      }).join('');


    /* ---------- Edit Buttons ---------- */

    document
      .querySelectorAll('.edit-product')
      .forEach(function (button) {

        button.addEventListener('click', function () {

          var productID =
            Number(button.dataset.id);

          openEditProduct(productID);

        });

      });


    /* ---------- Deactivate Buttons ---------- */

    document
      .querySelectorAll('.delete-product')
      .forEach(function (button) {

        button.addEventListener('click', function () {

          var productID =
            Number(button.dataset.id);

          deactivateProduct(productID);

        });

      });

  }


  /* ==========================================================
     Load Products From Database
     ========================================================== */

  function loadProducts() {

    return fetch('backend/admin-products.php')

      .then(function (response) {

        return response.json();

      })

      .then(function (result) {

        if (!result.ok) {

          alert(result.error);

          return;

        }


        dbProducts =
          result.products || [];


        var search =
          document.getElementById('productSearch');


        renderProducts(
          search ? search.value : ''
        );

      })

      .catch(function (error) {

        console.log(
          'Products error:',
          error
        );

      });

  }


  /* ==========================================================
     Load Categories From Database
     ========================================================== */

  function loadCategories() {

    return fetch('backend/admin-categories.php')

      .then(function (response) {

        return response.json();

      })

      .then(function (result) {

        if (!result.ok) {

          alert(result.error);

          return;

        }


        categories =
          result.categories || [];


        var select =
          document.getElementById('productCategory');


        if (select) {

          select.innerHTML =
            '<option value="">Select Category</option>';


          categories.forEach(function (category) {

            var option =
              document.createElement('option');


            option.value =
              category.CategoryID;


            option.textContent =
              category.CategoryName;


            select.appendChild(option);

          });

        }


        var search =
          document.getElementById('productSearch');


        renderProducts(
          search ? search.value : ''
        );

      })

      .catch(function (error) {

        console.log(
          'Categories error:',
          error
        );

      });

  }


  /* ==========================================================
     Product Search
     ========================================================== */

  var productSearch =
    document.getElementById('productSearch');


  if (productSearch) {

    productSearch.addEventListener(
      'input',
      function () {

        renderProducts(
          productSearch.value
        );

      }
    );

  }


  /* ==========================================================
     Product Form
     ========================================================== */

  var addProductBtn =
    document.getElementById('addProductBtn');

  var productFormCard =
    document.getElementById('productFormCard');

  var productForm =
    document.getElementById('productForm');

  var cancelProductBtn =
    document.getElementById('cancelProductBtn');


  /* ---------- Add Product ---------- */

  if (addProductBtn) {

    addProductBtn.addEventListener(
      'click',
      function () {

        if (productForm) {
          productForm.reset();
        }


        document.getElementById(
          'productID'
        ).value = '';


        document.getElementById(
          'productFormTitle'
        ).textContent = 'Add Product';


        if (productFormCard) {

          productFormCard.classList.remove(
            'd-none'
          );

        }

      }
    );

  }


  /* ---------- Cancel ---------- */

  if (cancelProductBtn) {

    cancelProductBtn.addEventListener(
      'click',
      function () {

        if (productForm) {
          productForm.reset();
        }


        if (productFormCard) {

          productFormCard.classList.add(
            'd-none'
          );

        }

      }
    );

  }


  /* ==========================================================
     Edit Product
     ========================================================== */

  function openEditProduct(productID) {

    var product =
      dbProducts.find(function (item) {

        return Number(item.ProductID) ===
               Number(productID);

      });


    if (!product) {

      alert('Product not found');

      return;

    }


    document.getElementById(
      'productID'
    ).value = product.ProductID;


    document.getElementById(
      'productName'
    ).value = product.ProductName || '';


    document.getElementById(
      'productDescription'
    ).value = product.Description || '';


    document.getElementById(
      'productPrice'
    ).value = product.Price;


    document.getElementById(
      'productOriginalPrice'
    ).value =
      product.OriginalPrice || '';


    document.getElementById(
      'productStock'
    ).value = product.Stock;


    document.getElementById(
      'productCategory'
    ).value = product.CategoryID;


    document.getElementById(
      'productFormTitle'
    ).textContent = 'Edit Product';


    if (productFormCard) {

      productFormCard.classList.remove(
        'd-none'
      );

    }

  }


  /* ==========================================================
     Save Product
     ========================================================== */

  if (productForm) {

    productForm.addEventListener(
      'submit',
      function (event) {

        event.preventDefault();


        var productID =
          document.getElementById(
            'productID'
          ).value;


        var action =
          productID
            ? 'update'
            : 'add';


        var formData =
          new FormData();


        formData.append(
          'action',
          action
        );


        if (productID) {

          formData.append(
            'productID',
            productID
          );

        }


        formData.append(
          'productName',
          document.getElementById(
            'productName'
          ).value
        );


        formData.append(
          'description',
          document.getElementById(
            'productDescription'
          ).value
        );


        formData.append(
          'price',
          document.getElementById(
            'productPrice'
          ).value
        );


        formData.append(
          'originalPrice',
          document.getElementById(
            'productOriginalPrice'
          ).value
        );


        formData.append(
          'stock',
          document.getElementById(
            'productStock'
          ).value
        );


        formData.append(
          'categoryID',
          document.getElementById(
            'productCategory'
          ).value
        );


        fetch(
          'backend/admin-products.php',
          {
            method: 'POST',
            body: formData
          }
        )

        .then(function (response) {

          return response.json();

        })

        .then(function (result) {

          if (!result.ok) {

            alert(result.error);

            return;

          }


          alert(result.message);


          productForm.reset();


          if (productFormCard) {

            productFormCard.classList.add(
              'd-none'
            );

          }


          loadProducts();

        })

        .catch(function (error) {

          console.log(
            'Save product error:',
            error
          );

        });

      }
    );

  }


  /* ==========================================================
     Deactivate Product
     ========================================================== */

  function deactivateProduct(productID) {

    var confirmed =
      confirm(
        'Are you sure you want to deactivate this product?'
      );


    if (!confirmed) {
      return;
    }


    var formData =
      new FormData();


    formData.append(
      'action',
      'delete'
    );


    formData.append(
      'productID',
      productID
    );


    fetch(
      'backend/admin-products.php',
      {
        method: 'POST',
        body: formData
      }
    )

    .then(function (response) {

      return response.json();

    })

    .then(function (result) {

      if (!result.ok) {

        alert(result.error);

        return;

      }


      alert(result.message);


      loadProducts();

    })

    .catch(function (error) {

      console.log(
        'Deactivate error:',
        error
      );

    });

  }


  /* ==========================================================
     Orders
     ========================================================== */

  function renderOrders() {

    if (!adminData) {
      return;
    }


    var orders =
      adminData.recentOrders || [];


    var body =
      document.getElementById('ordersBody');

    var emptyEl =
      document.getElementById('ordersEmpty');


    if (!body) {
      return;
    }


    if (orders.length === 0) {

      body.innerHTML = '';

      if (emptyEl) {
        emptyEl.style.display = 'block';
      }

      return;

    }


    if (emptyEl) {
      emptyEl.style.display = 'none';
    }


    body.innerHTML =
      orders.map(function (order) {

        return (

          '<tr>' +

            '<td>' +
              escapeHtml(
                order.OrderNumber
              ) +
            '</td>' +

            '<td>' +
              escapeHtml(
                order.FullName || '—'
              ) +
            '</td>' +

            '<td>' +
              escapeHtml(
                order.Email || '—'
              ) +
            '</td>' +

            '<td>—</td>' +

            '<td>' +
              formatMoney(
                order.TotalAmount
              ) +
            '</td>' +

            '<td>' +
              formatDate(
                order.OrderDate
              ) +
            '</td>' +

            '<td>' +

              '<span class="status-badge ' +
              statusClass(order.Status) +
              '">' +

                escapeHtml(
                  order.Status || 'Pending'
                ) +

              '</span>' +

            '</td>' +

          '</tr>'

        );

      }).join('');

  }


  /* ==========================================================
   Users
   ========================================================== */

function loadUsers() {

  return fetch('backend/admin-users.php')

    .then(function (response) {

      return response.json();

    })

    .then(function (result) {

      var body =
        document.getElementById('usersBody');

      var emptyEl =
        document.getElementById('usersEmpty');


      if (!body) {
        return;
      }


      if (!result.ok) {

        body.innerHTML = '';

        if (emptyEl) {
          emptyEl.style.display = 'block';
        }

        return;

      }


      var users =
        result.users || [];


      if (users.length === 0) {

        body.innerHTML = '';

        if (emptyEl) {
          emptyEl.style.display = 'block';
        }

        return;

      }


      if (emptyEl) {
        emptyEl.style.display = 'none';
      }


      body.innerHTML =
        users.map(function (user) {

          return (

            '<tr>' +

              '<td>' +
                escapeHtml(
                  user.FullName || '—'
                ) +
              '</td>' +

              '<td>' +
                escapeHtml(
                  user.Email || '—'
                ) +
              '</td>' +

              '<td>' +
                escapeHtml(
                  user.Phone || '—'
                ) +
              '</td>' +

              '<td>' +
                escapeHtml(
                  user.Address || '—'
                ) +
              '</td>' +

              '<td>' +

                '<select ' +
                  'class="user-role" ' +
                  'data-id="' +
                    user.UserID +
                '">' +

                  '<option value="User" ' +
                    (
                      user.Role === 'User'
                        ? 'selected'
                        : ''
                    ) +
                  '>User</option>' +

                  '<option value="Admin" ' +
                    (
                      user.Role === 'Admin'
                        ? 'selected'
                        : ''
                    ) +
                  '>Admin</option>' +

                '</select>' +

              '</td>' +

            '</tr>'

          );

        }).join('');


      /* ---------- Role Change ---------- */

      document
        .querySelectorAll('.user-role')
        .forEach(function (select) {

          select.addEventListener(
            'change',
            function () {

              updateUserRole(
                select.dataset.id,
                select.value
              );

            }
          );

        });

    })

    .catch(function (error) {

      console.log(
        'Users error:',
        error
      );

    });

}


/* ==========================================================
   Update User Role
   ========================================================== */

function updateUserRole(userID, role) {

  var formData =
    new FormData();


  formData.append(
    'action',
    'updateRole'
  );


  formData.append(
    'userID',
    userID
  );


  formData.append(
    'role',
    role
  );


  fetch(
    'backend/admin-users.php',
    {
      method: 'POST',
      body: formData
    }
  )

  .then(function (response) {

    return response.json();

  })

  .then(function (result) {

    if (!result.ok) {

      alert(result.error);

      loadUsers();

      return;

    }


    alert(result.message);


    loadUsers();

  })

  .catch(function (error) {

    console.log(
      'Update user error:',
      error
    );

  });

}
  /* ==========================================================
     LOAD ADMIN DATA
     ========================================================== */

  fetch('backend/admin.php')

    .then(function (response) {

      return response.json();

    })

    .then(function (result) {

      if (!result.ok) {

        alert(result.error);

        window.location.href =
          'login.html';

        return;

      }


      adminData = result;


      renderDashboard();

      renderOrders();


      loadCategories()
        .then(function () {

          return loadProducts();

        });


      loadUsers();

    })

    .catch(function (error) {

      console.log(
        'Admin error:',
        error
      );

    });

});