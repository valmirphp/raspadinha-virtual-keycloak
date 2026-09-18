// Mostrar/ocultar senha. Um botão por campo: <button data-password-toggle="<id do input>">.
(function () {
  function setup(toggle) {
    var input = document.getElementById(toggle.getAttribute("data-password-toggle"));
    var show = toggle.querySelector(".rs-toggle-show");
    var hide = toggle.querySelector(".rs-toggle-hide");
    if (!input) return;
    toggle.addEventListener("click", function () {
      var visible = input.type === "text";
      input.type = visible ? "password" : "text";
      toggle.setAttribute("aria-pressed", String(!visible));
      toggle.setAttribute("aria-label", visible ? toggle.getAttribute("data-label-show") : toggle.getAttribute("data-label-hide"));
      if (show) show.hidden = !visible;
      if (hide) hide.hidden = visible;
      input.focus();
    });
  }
  function init() {
    var toggles = document.querySelectorAll("[data-password-toggle]");
    for (var i = 0; i < toggles.length; i++) setup(toggles[i]);
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
