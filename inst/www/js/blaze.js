(function() {
  const params = new URLSearchParams(window.location.search);
  var redirect = params.get("redirect");

  if (redirect !== null) {
    rediret = "/" + redirect;
    history.pushState(redirect, null, redirect);

    window.addEventListener("DOMContentLoaded", function() {
      $(document).one("shiny:sessioninitialized", function(event) {
        Shiny.setInputValue(".clientdata_url_state", redirect);
      });
    });
  }
})();

window.addEventListener("DOMContentLoaded", function(event) {
  document.addEventListener("click", function(e) {
    if (!e.target.hasAttribute("data-blaze") || e.target.tagName !== "A") {
      return true;
    }

    if (e.target !== e.currentTarget) {
      e.preventDefault();

      var uri = e.target.getAttribute("href");

      Shiny.setInputValue(".clientdata_url_state", uri);
      history.pushState(uri, null, uri);
    }

    e.stopPropagation();
  });

  Shiny.addCustomMessageHandler("blaze:pushstate", function(msg) {
    var _path = function(path) {
      history.pushState(path, null, path);
    };

    if (msg.path) {
      _path(msg.path);
    }
  });
});

window.addEventListener("popstate", function(event) {
  const state = event.state || "";

  Shiny.setInputValue(".clientdata_url_state", state);
});
