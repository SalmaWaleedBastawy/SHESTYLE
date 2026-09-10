/* ==========================================================================
   SHESTYLE — auth.js
   A real (client-side demo) account system: users are stored in
   localStorage, login checks credentials against them, and a session flag
   tracks who is currently signed in. There is no server, so this is not
   secure storage — it's meant to make the Login/Register pages behave like
   a real flow rather than a static mockup.
   ========================================================================== */



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

  loginForm.addEventListener('submit', function (e) {

    e.preventDefault();

    var emailInput = document.getElementById('loginEmail');
    var passwordInput = document.getElementById('loginPassword');

    var emailOk = setFieldValid(
      emailInput,
      isValidEmail(emailInput.value.trim())
    );

    var passwordOk = setFieldValid(
      passwordInput,
      passwordInput.value.length >= 6
    );

    if (!emailOk || !passwordOk) {
      return;
    }

    fetch('backend/login.php', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        email: emailInput.value.trim(),
        password: passwordInput.value
      })
    })

    .then(function (response) {
      return response.json();
    })

    .then(function (result) {

      if (!result.ok) {

        showAuthAlert(
          alertEl,
          result.error,
          'error'
        );

        return;
      }

      showAuthAlert(
        alertEl,
        'Welcome back, ' + result.user.fullName + '! Redirecting…',
        'success'
      );

      window.setTimeout(function () {
        window.location.href = 'index.html';
      }, 900);

    })

    .catch(function (error) {

      console.error(error);

      showAuthAlert(
        alertEl,
        'Something went wrong. Please try again.',
        'error'
      );

    });

  }); 
}




 /* ---------- Register form ---------- */
var registerForm = document.getElementById('registerForm');

if (registerForm) {

    var regAlertEl = document.getElementById('registerAlert');

    registerForm.addEventListener('submit', function (e) {

        e.preventDefault();

        var nameInput = document.getElementById('regName');
        var emailInput = document.getElementById('regEmail');
        var passwordInput = document.getElementById('regPassword');
        var confirmInput = document.getElementById('regConfirmPassword');

        var nameOk = setFieldValid(
            nameInput,
            nameInput.value.trim().length > 1
        );

        var emailOk = setFieldValid(
            emailInput,
            isValidEmail(emailInput.value.trim())
        );

        var passwordOk = setFieldValid(
            passwordInput,
            passwordInput.value.length >= 6
        );

        var matchOk = setFieldValid(
            confirmInput,
            confirmInput.value.length >= 6 &&
            confirmInput.value === passwordInput.value
        );

        if (!nameOk || !emailOk || !passwordOk || !matchOk) {
            return;
        }

        fetch('backend/register.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: new URLSearchParams({
                uname: nameInput.value.trim(),
                uemail: emailInput.value.trim(),
                upass: passwordInput.value,
                cupass: confirmInput.value,
                register: '1'
            })
        })
        .then(function (response) {
            return response.json();
        })
        .then(function (result) {

            if (!result.ok) {

                showAuthAlert(
                    regAlertEl,
                    result.error,
                    'error'
                );

                return;
            }

            showAuthAlert(
                regAlertEl,
                result.message,
                'success'
            );

            registerForm.reset();

        })
        .catch(function (error) {

            console.error(error);

            showAuthAlert(
                regAlertEl,
                'Something went wrong. Please try again.',
                'error'
            );

        });

    });

}});