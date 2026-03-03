(function () {
  var PASSWORD = "Hubert@2026";
  var STORAGE_KEY = "strategy_pages_auth_v1";
  var MAX_ATTEMPTS = 3;

  try {
    if (sessionStorage.getItem(STORAGE_KEY) === "ok") {
      return;
    }
  } catch (e) {
    // ignore sessionStorage errors
  }

  var passed = false;
  for (var i = 0; i < MAX_ATTEMPTS; i += 1) {
    var value = window.prompt("请输入访问密码");
    if (value === null) {
      break;
    }
    if (value === PASSWORD) {
      passed = true;
      break;
    }
    window.alert("密码错误，请重试。");
  }

  if (!passed) {
    window.alert("未授权访问，页面将关闭。");
    window.location.replace("about:blank");
    throw new Error("Unauthorized");
  }

  try {
    sessionStorage.setItem(STORAGE_KEY, "ok");
  } catch (e) {
    // ignore sessionStorage errors
  }

  window.__strategyAuthLogout = function () {
    try {
      sessionStorage.removeItem(STORAGE_KEY);
    } catch (e) {
      // ignore
    }
    window.location.reload();
  };
})();
