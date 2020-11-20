(function($, Shiny) {
  let URLSearchObject = function(search) {
    let params = new URLSearchParams(search);
    return Array.from(params).map(p => ({ [p[0]]: p[1] }));
  };

  // Original author garrick, see #1
  var getURLComponents = function() {
    const params = new URLSearchParams(window.location.search);
    params.delete("redirect");
    return {
      params: params,
      pathname: window.location.pathname,
      hash: window.location.hash
    };
  };

  // Original author garrick, see #1
  var pathURI = function(redirect) {
    if (!redirect || redirect == window.location.pathname) {
      return false;
    }

    let {params, hash} = getURLComponents();

    if (params.toString()) {
      redirect += `?${ params }`;
    }

    return `${ redirect }${ hash }`;
  };

  var pushState = function(path) {
    path = pathURI(path);
    history.pushState(path, null, path);
  };

  var replaceState = function(path) {
    path = pathURI(path);
    history.replaceState(path, null, path);
  };

  var sendState = function(path) {
    Shiny.setInputValue(".clientdata_url_state", path, { priority: "event" });
  };

  let sendParams = function(search) {
    const o = URLSearchObject(search);
    console.log(o);
    Shiny.setInputValue(".clientdata_url_search_object", o, { priority: "event" });
  };

  (function() {
    const params = new URLSearchParams(window.location.search);
    const redirect = params.get("redirect") || "/";

    if (redirect !== "/") {
      replaceState(redirect);
    }

    window.addEventListener("DOMContentLoaded", function() {
      $(document).one("shiny:sessioninitialized", function() {
        sendState(redirect);
        sendParams(window.location.search);
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

        let href = target.getAttribute("href");
        let uri = new URL(href, window.location.origin);

        if (uri.pathname !== window.location.pathname) {
          sendState(uri.pathname);
          sendParams(uri.search);
          history.pushState(href, null, href);
        }
      }

      event.stopPropagation();
    });

    Shiny.addCustomMessageHandler("blaze:pushstate", function(msg) {
      if (msg.path) {
        pushState(msg.path);
      }
    });
  });

  window.addEventListener("popstate", function(event) {
    sendState(event.state || "/");
    sendParams(window.location.search);
  });
})(window.jQuery, window.Shiny);
