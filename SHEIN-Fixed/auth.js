/* ==========================================================================
   SHESTYLE — auth.js
   A real (client-side demo) account system: users are stored in
   localStorage, login checks credentials against them, and a session flag
   tracks who is currently signed in. There is no server, so this is not
   secure storage — it's meant to make the Login/Register pages behave like
   a real flow rather than a static mockup.
   ========================================================================== */

var USERS_KEY = 'shestyle_users';
var SESSION_KEY = 'shestyle_session';

function getUsers() {
  try {
    return JSON.parse(localStorage.getItem(USERS_KEY) || '[]');
  } catch (e) {
    return [];
  }
}

function saveUsers(list) {
  localStorage.setItem(USERS_KEY, JSON.stringify(list));
}

function findUserByEmail(email) {
  var users = getUsers();
  var target = email.trim().toLowerCase();
  for (var i = 0; i < users.length; i++) {
    if (users[i].email.toLowerCase() === target) return users[i];
  }
  return null;
}

function registerUser(fullName, email, password) {
  if (findUserByEmail(email)) {
    return { ok: false, error: 'An account with this email already exists.' };
  }
  var users = getUsers();
  users.push({ fullName: fullName.trim(), email: email.trim(), password: password });
  saveUsers(users);
  setSession(email.trim());
  return { ok: true };
}

function loginUser(email, password) {
  var user = findUserByEmail(email);
  if (!user) {
    return { ok: false, error: 'No account found with this email.' };
  }
  if (user.password !== password) {
    return { ok: false, error: 'Incorrect password. Please try again.' };
  }
  setSession(user.email);
  return { ok: true, user: user };
}

function setSession(email) {
  localStorage.setItem(SESSION_KEY, email);
}

function getSession() {
  return localStorage.getItem(SESSION_KEY);
}

function logoutUser() {
  localStorage.removeItem(SESSION_KEY);
}

function getCurrentUser() {
  var email = getSession();
  return email ? findUserByEmail(email) : null;
}

function showAuthAlert(el, message, type) {
  if (!el) return;
  el.textContent = message;
  el.className = 'auth-alert show ' + (type || 'error');
}

function setFieldValid(input, isValid) {
  input.classList.toggle('is-invalid', !isValid);
  var errorEl = input.parentElement.querySelector('.field-error');
  if (!errorEl && input.closest('.password-field')) {
    errorEl = input.closest('.password-field').parentElement.querySelector('.field-error');
  }
  if (errorEl) errorEl.style.display = isValid ? 'none' : 'block';
  return isValid;
}

document.addEventListener('DOMContentLoaded', function () {

  var isValidEmail = function (value) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value); };

  /* ---------- Password show/hide toggles ---------- */
  document.querySelectorAll('.password-toggle').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var input = btn.previousElementSibling;
      var isPassword = input.type === 'password';
      input.type = isPassword ? 'text' : 'password';
      btn.innerHTML = isPassword
        ? '<i class="fa-regular fa-eye-slash"></i>'
        : '<i class="fa-regular fa-eye"></i>';
    });
  });

  /* ---------- Login form ---------- */
  var loginForm = document.getElementById('loginForm');
  if (loginForm) {
    var alertEl = document.getElementById('loginAlert');
    var currentUser = getCurrentUser();
    if (currentUser) {
      showAuthAlert(alertEl, "You're already logged in as " + currentUser.fullName + '.', 'info');
    }

    loginForm.addEventListener('submit', function (e) {
      e.preventDefault();
      var emailInput = document.getElementById('loginEmail');
      var passwordInput = document.getElementById('loginPassword');

      var emailOk = setFieldValid(emailInput, isValidEmail(emailInput.value.trim()));
      var passwordOk = setFieldValid(passwordInput, passwordInput.value.length >= 6);

      if (!emailOk || !passwordOk) return;

      var result = loginUser(emailInput.value.trim(), passwordInput.value);
      if (!result.ok) {
        showAuthAlert(alertEl, result.error, 'error');
        return;
      }

      showAuthAlert(alertEl, 'Welcome back, ' + result.user.fullName + '! Redirecting…', 'success');
      window.setTimeout(function () { window.location.href = 'index.html'; }, 900);
    });
  }

  /* ---------- Register form ---------- */
  var registerForm = document.getElementById('registerForm');
  if (registerForm) {
    var regAlertEl = document.getElementById('registerAlert');

    registerForm.addEventListener('submit', function (e) {
      e.preventDefault();
      var nameInput     = document.getElementById('regName');
      var emailInput    = document.getElementById('regEmail');
      var passwordInput = document.getElementById('regPassword');
      var confirmInput  = document.getElementById('regConfirmPassword');

      var nameOk     = setFieldValid(nameInput, nameInput.value.trim().length > 1);
      var emailOk    = setFieldValid(emailInput, isValidEmail(emailInput.value.trim()));
      var passwordOk = setFieldValid(passwordInput, passwordInput.value.length >= 6);
      var matchOk    = setFieldValid(confirmInput, confirmInput.value.length >= 6 && confirmInput.value === passwordInput.value);

      if (!nameOk || !emailOk || !passwordOk || !matchOk) return;

      var result = registerUser(nameInput.value, emailInput.value, passwordInput.value);
      if (!result.ok) {
        showAuthAlert(regAlertEl, result.error, 'error');
        return;
      }

      showAuthAlert(regAlertEl, 'Account created! Redirecting…', 'success');
      window.setTimeout(function () { window.location.href = 'index.html'; }, 900);
    });
  }

});
