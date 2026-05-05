(function () {
  if (localStorage.getItem('macrolog_cookie_consent') === 'accepted') return;

  const banner = document.createElement('div');
  banner.id = 'cookie-banner';
  banner.setAttribute('role', 'dialog');
  banner.setAttribute('aria-label', 'Cookie consent');
  banner.innerHTML = `
    <p class="cookie-banner__text">
      We use cookies to improve your experience.
      <a href="cookie-policy.html" class="cookie-banner__link">Cookie Policy</a>
    </p>
    <button id="cookie-accept" class="cookie-banner__btn">Accept &amp; Dismiss</button>
  `;
  document.body.appendChild(banner);

  document.getElementById('cookie-accept').addEventListener('click', function () {
    localStorage.setItem('macrolog_cookie_consent', 'accepted');
    banner.classList.add('cookie-banner--hidden');
    setTimeout(() => banner.remove(), 400);
  });
})();
