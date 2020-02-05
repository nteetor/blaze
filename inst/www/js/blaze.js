(function($, Shiny) {
  var sendState = function(value) {
    Shiny.setInputValue(".clientdata_url_state", value, { priority: "event" });
  };

  (function() {
    const params = new URLSearchParams(window.location.search);
    const redirect = params.get("redirect") || "/";

    if (redirect !== "/") {
      history.replaceState(redirect, null, redirect);
    }

    window.addEventListener("DOMContentLoaded", function() {
      $(document).one("shiny:sessioninitialized", function() {
        sendState(redirect);
      });
    });
  })();

  window.addEventListener("DOMContentLoaded", function() {
    document.addEventListener("click", function(event) {
      const target = event.target;

      if (!target.hasAttribute("data-blaze") || target.tagName !== "A") {
        return true;
      }

      if (target !== event.currentTarget) {
        event.preventDefault();

        var uri = target.getAttribute("href");

        if (uri !== window.location.pathname) {
          sendState(uri);
          history.pushState(uri, null, uri);
        }
      }

      event.stopPropagation();
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
    sendState(event.state || "/");
  });
})(window.jQuery, window.Shiny);
