window.addEventListener("DOMContentLoaded", function(e) {
  Shiny.addCustomMessageHandler("blaze:push", function(msg) {
    if (msg.hash === undefined || msg.hash === null) {
      return;
    }

    window.history.pushState(null, null, msg.hash);
    window.dispatchEvent(new HashChangeEvent("hashchange"));
  });
});
