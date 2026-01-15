
// Minimal UJS handler for data-remote links (avoids full page reloads)
(function() {
  if (window.Rails || (window.jQuery && window.jQuery.rails)) { return; }
  document.addEventListener('click', function (event) {
    var link = event.target && (event.target.closest ? event.target.closest('a[data-remote="true"]') : null);
    if (!link) { return; }
    if (link.getAttribute('data-method')) { return; }
    event.preventDefault();
    var xhr = new XMLHttpRequest();
    xhr.open('GET', link.href, true);
    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4) {
        if (xhr.status >= 200 && xhr.status < 300) {
          (0, eval)(xhr.responseText);
        }
      }
    };
    xhr.send();
  }, false);
})();

// Minimal UJS handler for data-remote forms (submits via AJAX and evaluates JS)
(function() {
  if (window.Rails || (window.jQuery && window.jQuery.rails)) { return; }
  var onSubmit = function (event) {
    var form = event.target && (event.target.closest ? event.target.closest('form[data-remote="true"]') : null);
    if (!form) { return; }
    event.preventDefault();
    var action = form.getAttribute('action') || window.location.href;
    var method = (form.getAttribute('method') || 'POST').toUpperCase();
    // Rails forms for PATCH/PUT/DELETE use POST + hidden _method param; keep POST
    if (method !== 'GET' && method !== 'POST') { method = 'POST'; }
    var xhr = new XMLHttpRequest();
    xhr.open(method, action, true);
    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    var csrf = document.querySelector('meta[name="csrf-token"]');
    if (csrf && csrf.content) {
      xhr.setRequestHeader('X-CSRF-Token', csrf.content);
    }
    // Prefer JS; Rails responds with update.js.erb
    xhr.setRequestHeader('Accept', 'text/javascript, application/javascript, application/ecmascript, application/x-ecmascript');
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4) {
        if (xhr.status >= 200 && xhr.status < 300) {
          // Execute server-delivered JS (e.g., update.js.erb)
          (0, eval)(xhr.responseText);
        }
      }
    };
    var formData = new FormData(form);
    xhr.send(formData);
  };
  // Use capture to reliably intercept submit
  document.addEventListener('submit', onSubmit, true);
})();


