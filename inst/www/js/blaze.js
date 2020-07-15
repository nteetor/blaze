(function($, Shiny) {
  var sendState = function(value) {
    Shiny.setInputValue(".clientdata_url_state", value, { priority: "event" });
  };

  var getURLComponents = function() {
    const params = new URLSearchParams(window.location.search);
    params.delete('redirect');
    return {
      params,
      pathname: window.location.pathname,
      hash: window.location.hash
    };
  };

  var pathURI = function(redirect, {params, hash} = getURLComponents()) {
    if (!redirect || redirect == window.location.pathname) {
      return false;
    }
    if (params.toString()) redirect = redirect + '?' + params;
    return redirect + hash;
  };

  (function() {
    const params = new URLSearchParams(window.location.search);
    const redirect = params.get("redirect") || "/";

    if (redirect !== "/") {
      redirectURI = pathURI(redirect);
      history.replaceState(redirectURI, null, redirectURI);
    }

    window.addEventListener("DOMContentLoaded", function() {
      $(document).one("shiny:sessioninitialized", function() {
        sendState(redirect);
      });
    });
  })();

  window.addEventListener("DOMContentLoaded", function() {
    var _path = function(path, mode) {
      const uri = pathURI(path);
      if (uri) {
        if ((mode || "push") === "push") {
          history.pushState({uri, pathname: path}, null, uri);
        } else if (mode === "replace") {
          history.replaceState({uri, pathname: path}, null, uri);
        } else {
          throw `Unknown blaze::pushPath() mode: ${mode}`;
        }
        sendState(path);
      }
    };

    document.addEventListener("click", function(event) {
      const target = event.target;

      if (!target.hasAttribute("data-blaze") || target.tagName !== "A") {
        return true;
      }

      if (target !== event.currentTarget) {
        event.preventDefault();

        var uri = target.getAttribute("href");

        if (uri !== window.location.pathname) {
          _path(uri);
        }
      }

      event.stopPropagation();
    });

    Shiny.addCustomMessageHandler("blaze:pushstate", function(msg) {
      if (msg.path) {
        _path(msg.path, msg.mode || "push");
      }
    });
  });

  window.addEventListener("popstate", function(event) {
    let {pathname} = event.state || window.location;
    sendState(pathname || "/");
  });
})(window.jQuery, window.Shiny);
