<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Create Account — SHESTYLE</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@500;600;700&family=Jost:wght@300;400;500;600&display=swap" rel="stylesheet">

<link rel="stylesheet" href="style.css">
<link rel="stylesheet" href="login.css">
<link rel="stylesheet" href="register.css">
</head>
<body>

<div class="announce-bar">Free shipping on orders over $59!</div>

<!-- Header -->
<header class="site-header">
  <div class="container-page">
    <div class="navbar-top">
      <button class="icon-btn menu-btn" type="button" data-bs-toggle="offcanvas" data-bs-target="#sideMenu" aria-controls="sideMenu" aria-label="Open menu">
        <i class="fa-solid fa-bars"></i>
      </button>
      <a class="brand-logo" href="index.html">SHESTYLE</a>
      <div class="header-icons">
        <a href="search.html" class="icon-btn" aria-label="Search"><i class="fa-solid fa-magnifying-glass"></i></a>
        <a href="wishlist.html" class="icon-btn" aria-label="Wishlist"><i class="fa-regular fa-heart"></i></a>
        <a href="cart.html" class="icon-btn" aria-label="Cart">
          <i class="fa-solid fa-bag-shopping"></i>
          <span class="cart-count">0</span>
        </a>
      </div>
    </div>

    <nav class="tab-nav">
      <ul class="tab-nav-list">
        <li><a class="tab-link" href="index.html">Home</a></li>
        <li><a class="tab-link" href="women.html">Women</a></li>
        <li><a class="tab-link" href="products.html?category=men">Men</a></li>
        <li><a class="tab-link" href="products.html?category=kids">Kids</a></li>
        <li><a class="tab-link" href="accessories.html">Accessories</a></li>
        <li><a class="tab-link text-rose" href="products.html?category=sale">Sale</a></li>
      </ul>
    </nav>
  </div>
</header>

<!-- Side menu (offcanvas) -->
<div class="offcanvas offcanvas-start side-menu" tabindex="-1" id="sideMenu" aria-labelledby="sideMenuLabel">
  <div class="offcanvas-header">
    <span class="brand-logo" id="sideMenuLabel">SHESTYLE</span>
    <button type="button" class="btn-close-custom" data-bs-dismiss="offcanvas" aria-label="Close">
      <i class="fa-solid fa-xmark"></i>
    </button>
  </div>
  <div class="offcanvas-body p-0">
    <ul class="sidemenu-cat-list list-unstyled m-0">
      <li><a href="products.html?category=just-for-you">Just For You</a></li>
      <li><a href="products.html?category=sale" class="text-rose">Sale</a></li>
      <li><a href="women.html">Women</a></li>
      <li><a href="products.html?category=men">Men</a></li>
      <li><a href="products.html?category=kids">Kids</a></li>
      <li><a href="accessories.html">Accessories</a></li>
    </ul>
  </div>
  <div class="sidemenu-bottom-nav">
    <a href="index.html"><i class="fa-solid fa-house"></i><span>Home</span></a>
    <a href="wishlist.html"><i class="fa-regular fa-heart"></i><span>Wishlist</span></a>
    <a href="#"><i class="fa-solid fa-headset"></i><span>Support</span></a>
    <a href="login.html" class="active"><i class="fa-solid fa-user"></i><span>Account</span></a>
  </div>
</div>

<!-- Register -->
<section class="auth-section">
  <div class="auth-wrapper auth-wrapper-register">

    <div class="auth-media">
      <img src="https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?q=80&w=1200&auto=format&fit=crop" alt="Shestyle closet">
    </div>

    <div class="auth-panel">
      <div class="auth-card">
        <h1>Create Account</h1>
        <p class="auth-sub">Join us and start shopping!</p>

        <form id="registerForm" method="POST" action="backend/register.php" novalidate>
          <div class="mb-3">
            <label for="regName" class="form-label">Full Name</label>
            <input type="text" class="form-control auth-input" id="regName" name="uname" placeholder="Enter your name" required>
            <div class="field-error">Please enter your full name.</div>
          </div>

          <div class="mb-3">
            <label for="regEmail" class="form-label">Email</label>
            <input type="email" class="form-control auth-input" id="regEmail" name="uemail" placeholder="Enter your email" required>
            <div class="field-error">Please enter a valid email address.</div>
          </div>

          <div class="mb-3">
            <label for="regPassword" class="form-label">Password</label>
            <div class="password-field">
              <input type="password" class="form-control auth-input" id="regPassword" name="upass" placeholder="Create password" minlength="6" required>
              <button type="button" class="password-toggle" aria-label="Show password">
                <i class="fa-regular fa-eye"></i>
              </button>
            </div>
            <div class="field-error">Password must be at least 6 characters.</div>
          </div>

          <div class="mb-3">
            <label for="regConfirmPassword" class="form-label">Confirm Password</label>
            <div class="password-field">
             <input type="password" class="form-control auth-input" id="regConfirmPassword" name="cupass" placeholder="Confirm your password" minlength="6" required>
              <button type="button" class="password-toggle" aria-label="Show password">
                <i class="fa-regular fa-eye"></i>
              </button>
            </div>
            <div class="field-error">Passwords do not match.</div>
          </div>

          <div class="auth-alert" id="registerAlert"></div>

          <button type="submit" name="register" class="btn btn-ink w-100 auth-submit">
    REGISTER
</button>
        </form>

        <p class="auth-footer-link">Already have an account? <a href="login.html">Login</a></p>
      </div>
    </div>

  </div>
</section>

<!-- Footer -->
<footer class="site-footer">
  <div class="container-page">
    <div class="footer-bottom text-center">© 2026 SHESTYLE. All rights reserved.</div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="cart-store.js"></script>
<script src="auth.js"></script>
</body>
</html>
