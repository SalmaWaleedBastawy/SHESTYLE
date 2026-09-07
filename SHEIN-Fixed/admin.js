/* ==========================================================================
   SHESTYLE — admin.js
   A real (client-side demo) admin dashboard: stats, the Recent Orders
   table, Top Products, the Products table, and the Users table are all
   computed from the site's actual data —
     • PRODUCTS (products-data.js + products-data-extra.js) for the catalog
     • localStorage 'shestyle_orders', written by checkout.js when an order
       is placed
     • localStorage 'shestyle_users', written by auth.js on registration
   There's no real backend behind this demo, so there's nothing to fake:
   if no orders have been placed yet, the dashboard honestly shows that
   instead of made-up numbers.
   ========================================================================== */

var ORDERS_KEY = 'shestyle_orders';

function getOrders() {
  try {
    return JSON.parse(localStorage.getItem(ORDERS_KEY) || '[]');
  } catch (e) {
    return [];
  }
}

function saveOrders(list) {
  localStorage.setItem(ORDERS_KEY, JSON.stringify(list));
}

document.addEventListener('DOMContentLoaded', function () {

  var catalog = (typeof PRODUCTS !== 'undefined') ? PRODUCTS : [];

  function formatMoney(v) { return '$' + v.toFixed(2); }
  function formatDate(iso) {
    var d = new Date(iso);
    if (isNaN(d)) return iso;
    return d.toLocaleDateString('en-US', { day: '2-digit', month: 'short', year: 'numeric' });
  }
  function escapeHtml(str) {
    var div = document.createElement('div');
    div.textContent = str == null ? '' : str;
    return div.innerHTML;
  }
  function statusClass(status) {
    var s = (status || '').toLowerCase();
    if (s === 'delivered') return 'status-delivered';
    if (s === 'shipped') return 'status-shipped';
    if (s === 'cancelled') return 'status-cancelled';
    return 'status-processing';
  }

  /* ---------------- Tab switching ---------------- */

  var navLinks = document.querySelectorAll('.admin-nav-link');
  var panels = document.querySelectorAll('.admin-panel');

  function activateTab(tab) {
    navLinks.forEach(function (link) { link.classList.toggle('active', link.dataset.tab === tab); });
    panels.forEach(function (panel) { panel.classList.toggle('d-none', panel.id !== 'tab-' + tab); });
  }

  navLinks.forEach(function (link) {
    link.addEventListener('click', function () { activateTab(link.dataset.tab); });
  });

  document.querySelectorAll('[data-goto-tab]').forEach(function (btn) {
    btn.addEventListener('click', function () { activateTab(btn.dataset.gotoTab); });
  });

  /* ---------------- Logout ---------------- */

  var logoutBtn = document.getElementById('adminLogout');
  if (logoutBtn) {
    logoutBtn.addEventListener('click', function () {
      if (typeof logoutUser === 'function') logoutUser();
      window.location.href = 'login.html';
    });
  }

  /* ---------------- Dashboard ---------------- */

  function renderDashboard() {
    var orders = getOrders();
    var users = (typeof getUsers === 'function') ? getUsers() : [];

    var totalSales = orders.reduce(function (sum, o) { return sum + (o.total || 0); }, 0);

    document.getElementById('statOrders').textContent = orders.length;
    document.getElementById('statProducts').textContent = catalog.length;
    document.getElementById('statUsers').textContent = users.length;
    document.getElementById('statSales').textContent = '$' + totalSales.toFixed(2);

    /* Recent orders (latest 5) */
    var recentBody = document.getElementById('recentOrdersBody');
    var recentEmpty = document.getElementById('recentOrdersEmpty');
    var recent = orders.slice().reverse().slice(0, 5);

    if (recent.length === 0) {
      recentBody.innerHTML = '';
      recentEmpty.style.display = 'block';
    } else {
      recentEmpty.style.display = 'none';
      recentBody.innerHTML = recent.map(function (o) {
        return (
          '<tr>' +
            '<td>' + escapeHtml(o.id) + '</td>' +
            '<td>' + escapeHtml(o.customer || '—') + '</td>' +
            '<td>' + formatMoney(o.total || 0) + '</td>' +
            '<td>' + formatDate(o.date) + '</td>' +
            '<td><span class="status-badge ' + statusClass(o.status) + '">' + escapeHtml(o.status || 'Processing') + '</span></td>' +
          '</tr>'
        );
      }).join('');
    }

    /* Top products, aggregated from real order line items */
    var soldMap = {};
    orders.forEach(function (o) {
      (o.items || []).forEach(function (line) {
        soldMap[line.id] = (soldMap[line.id] || 0) + line.qty;
      });
    });

    var topIds = Object.keys(soldMap).sort(function (a, b) { return soldMap[b] - soldMap[a]; }).slice(0, 5);
    var topListEl = document.getElementById('topProductsList');
    var topEmptyEl = document.getElementById('topProductsEmpty');

    if (topIds.length === 0) {
      topListEl.innerHTML = '';
      topEmptyEl.style.display = 'block';
    } else {
      topEmptyEl.style.display = 'none';
      topListEl.innerHTML = topIds.map(function (id) {
        var product = catalog.filter(function (p) { return p.id === id; })[0];
        var img = product && product.images ? product.images[0] : '';
        var name = product ? product.name : id;
        return (
          '<div class="top-product-row">' +
            '<img src="' + img + '" alt="' + escapeHtml(name) + '">' +
            '<div class="top-product-info">' +
              '<span class="top-product-name">' + escapeHtml(name) + '</span>' +
              '<span class="top-product-sold">' + soldMap[id] + ' sold</span>' +
            '</div>' +
          '</div>'
        );
      }).join('');
    }
  }

  /* ---------------- Products tab ---------------- */

  function renderProducts(filterText) {
    var body = document.getElementById('productsBody');
    var q = (filterText || '').trim().toLowerCase();

    var list = catalog.filter(function (p) {
      return !q || p.name.toLowerCase().indexOf(q) !== -1 || (p.category || '').toLowerCase().indexOf(q) !== -1;
    });

    body.innerHTML = list.map(function (p) {
      var img = (p.images && p.images[0]) || '';
      return (
        '<tr>' +
          '<td><img class="admin-thumb" src="' + img + '" alt="' + escapeHtml(p.name) + '"></td>' +
          '<td>' + escapeHtml(p.name) + '</td>' +
          '<td>' + escapeHtml(p.category || '—') + '</td>' +
          '<td>' + formatMoney(p.price) + '</td>' +
        '</tr>'
      );
    }).join('');
  }

  var productSearch = document.getElementById('productSearch');
  if (productSearch) {
    productSearch.addEventListener('input', function () { renderProducts(productSearch.value); });
  }

  /* ---------------- Orders tab ---------------- */

  function renderOrders() {
    var orders = getOrders();
    var body = document.getElementById('ordersBody');
    var emptyEl = document.getElementById('ordersEmpty');

    if (orders.length === 0) {
      body.innerHTML = '';
      emptyEl.style.display = 'block';
      return;
    }
    emptyEl.style.display = 'none';

    body.innerHTML = orders.slice().reverse().map(function (o, idx) {
      var itemCount = (o.items || []).reduce(function (sum, i) { return sum + i.qty; }, 0);
      return (
        '<tr>' +
          '<td>' + escapeHtml(o.id) + '</td>' +
          '<td>' + escapeHtml(o.customer || '—') + '</td>' +
          '<td>' + escapeHtml(o.email || '—') + '</td>' +
          '<td>' + itemCount + '</td>' +
          '<td>' + formatMoney(o.total || 0) + '</td>' +
          '<td>' + formatDate(o.date) + '</td>' +
          '<td>' +
            '<select class="status-select ' + statusClass(o.status) + '" data-order-id="' + escapeHtml(o.id) + '">' +
              ['Processing', 'Shipped', 'Delivered', 'Cancelled'].map(function (s) {
                return '<option value="' + s + '"' + (o.status === s ? ' selected' : '') + '>' + s + '</option>';
              }).join('') +
            '</select>' +
          '</td>' +
        '</tr>'
      );
    }).join('');

    body.querySelectorAll('.status-select').forEach(function (select) {
      select.addEventListener('change', function () {
        var all = getOrders();
        var target = all.filter(function (o) { return o.id === select.dataset.orderId; })[0];
        if (target) {
          target.status = select.value;
          saveOrders(all);
          select.className = 'status-select ' + statusClass(select.value);
          renderDashboard(); // keep recent-orders badges + totals in sync
        }
      });
    });
  }

  /* ---------------- Users tab ---------------- */

  function renderUsers() {
    var users = (typeof getUsers === 'function') ? getUsers() : [];
    var body = document.getElementById('usersBody');
    var emptyEl = document.getElementById('usersEmpty');

    if (users.length === 0) {
      body.innerHTML = '';
      emptyEl.style.display = 'block';
      return;
    }
    emptyEl.style.display = 'none';

    body.innerHTML = users.map(function (u) {
      return '<tr><td>' + escapeHtml(u.fullName) + '</td><td>' + escapeHtml(u.email) + '</td></tr>';
    }).join('');
  }

  /* ---------------- Init ---------------- */

  renderDashboard();
  renderProducts('');
  renderOrders();
  renderUsers();

});
