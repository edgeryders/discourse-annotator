
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


