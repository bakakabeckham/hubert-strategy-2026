(function () {
  var PASSWORD = "yuanqi20181818";
  var STORAGE_KEY = "strategy_pages_auth_v1";
  var MAX_ATTEMPTS = 3;

  function setAuthorized() {
    try {
      sessionStorage.setItem(STORAGE_KEY, "ok");
    } catch (e) {
      // ignore sessionStorage errors
    }
  }

  function isAuthorized() {
    try {
      return sessionStorage.getItem(STORAGE_KEY) === "ok";
    } catch (e) {
      return false;
    }
  }

  function clearAuthorized() {
    try {
      sessionStorage.removeItem(STORAGE_KEY);
    } catch (e) {
      // ignore
    }
  }

  function mountAuthDialog(attempt) {
    return new Promise(function (resolve) {
      var overlay = document.createElement("div");
      overlay.style.cssText = [
        "position:fixed",
        "inset:0",
        "z-index:999999",
        "display:flex",
        "align-items:center",
        "justify-content:center",
        "background:rgba(9,14,23,.45)",
        "padding:16px"
      ].join(";");

      var modal = document.createElement("div");
      modal.style.cssText = [
        "width:min(520px,100%)",
        "background:#fff",
        "border-radius:14px",
        "padding:18px",
        "box-shadow:0 14px 45px rgba(0,0,0,.28)",
        "font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,'PingFang SC','Microsoft YaHei',sans-serif",
        "color:#18243d"
      ].join(";");

      var title = document.createElement("div");
      title.textContent = "请输入访问密码";
      title.style.cssText = "font-size:18px;font-weight:700;margin-bottom:8px;";

      var hint = document.createElement("div");
      hint.textContent = "第 " + attempt + " / " + MAX_ATTEMPTS + " 次尝试";
      hint.style.cssText = "font-size:13px;color:#5a6781;margin-bottom:12px;";

      var input = document.createElement("input");
      input.type = "password";
      input.autocomplete = "off";
      input.placeholder = "请输入密码";
      input.style.cssText = [
        "width:100%",
        "height:44px",
        "border:1px solid #c9d3ea",
        "border-radius:10px",
        "padding:0 12px",
        "font-size:16px",
        "outline:none"
      ].join(";");

      var footer = document.createElement("div");
      footer.style.cssText = "display:flex;justify-content:flex-end;gap:10px;margin-top:14px;";

      var cancelBtn = document.createElement("button");
      cancelBtn.type = "button";
      cancelBtn.textContent = "取消";
      cancelBtn.style.cssText = [
        "height:38px",
        "padding:0 16px",
        "border-radius:999px",
        "border:1px solid #cfdaef",
        "background:#f1f5ff",
        "color:#2d4676",
        "cursor:pointer"
      ].join(";");

      var okBtn = document.createElement("button");
      okBtn.type = "button";
      okBtn.textContent = "确定";
      okBtn.style.cssText = [
        "height:38px",
        "padding:0 18px",
        "border-radius:999px",
        "border:1px solid #1f5bd6",
        "background:#2563eb",
        "color:#fff",
        "cursor:pointer"
      ].join(";");

      function done(result) {
        if (overlay.parentNode) {
          overlay.parentNode.removeChild(overlay);
        }
        resolve(result);
      }

      cancelBtn.onclick = function () {
        done({ canceled: true, value: "" });
      };

      okBtn.onclick = function () {
        done({ canceled: false, value: input.value || "" });
      };

      input.onkeydown = function (event) {
        if (event.key === "Enter") {
          event.preventDefault();
          okBtn.click();
        } else if (event.key === "Escape") {
          event.preventDefault();
          cancelBtn.click();
        }
      };

      footer.appendChild(cancelBtn);
      footer.appendChild(okBtn);
      modal.appendChild(title);
      modal.appendChild(hint);
      modal.appendChild(input);
      modal.appendChild(footer);
      overlay.appendChild(modal);
      (document.body || document.documentElement).appendChild(overlay);

      setTimeout(function () {
        input.focus();
      }, 0);
    });
  }

  function denyAccess() {
    window.alert("未授权访问，页面将关闭。");
    window.location.replace("about:blank");
    throw new Error("Unauthorized");
  }

  async function verifyAccess() {
    for (var i = 1; i <= MAX_ATTEMPTS; i += 1) {
      var result = await mountAuthDialog(i);
      if (result.canceled) {
        break;
      }
      if (result.value === PASSWORD) {
        setAuthorized();
        return true;
      }
      window.alert("密码错误，请重试。");
    }
    return false;
  }

  window.__strategyAuthLogout = function () {
    clearAuthorized();
    window.location.reload();
  };

  if (isAuthorized()) {
    return;
  }

  document.documentElement.style.visibility = "hidden";
  verifyAccess()
    .then(function (ok) {
      if (!ok) {
        denyAccess();
        return;
      }
      document.documentElement.style.visibility = "";
    })
    .catch(function () {
      denyAccess();
    });
})();
