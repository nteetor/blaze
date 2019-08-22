window.addEventListener("DOMContentLoaded", function(e) {
  // do not fire hashchange event initially, setting default hash state
  window.history.pushState(null, null, "#/");

  Shiny.addCustomMessageHandler("blaze:push", function(msg) {
    if (msg.hash === undefined || msg.hash === null) {
      return;
    }

    window.history.pushState(null, null, msg.hash);
    window.dispatchEvent(new HashChangeEvent("hashchange"));
  });
});
