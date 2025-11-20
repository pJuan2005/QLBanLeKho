var current_url = "http://localhost:5000";

makeScript = function (url) {
  var script = document.createElement("script");
  script.setAttribute("src", url);
  script.setAttribute("type", "text/javascript");
  document.getElementById("mainDiv").appendChild(script);
};

// khai báo module chính
var app = angular.module("AppRetailPos", []);

// ========service lưu/ đọc thông tin user + token==================
app.factory("AuthService", function ($window) {
  var TOKEN_KEY = "jwt";
  var USER_KEY = "currentUser";
  return {
    saveLogin: function (data) {
      // data:token, username,fullname,role,email,phone
      $window.localStorage.setItem(TOKEN_KEY, data.token);
      $window.localStorage.setItem(
        USER_KEY,
        JSON.stringify({
          username: data.username,
          fullname: data.fullname,
          role: data.role,
          email: data.email,
          phone: data.phone,
        })
      );
    },
    getCurrentUser: function () {
      var json = $window.localStorage.getItem(USER_KEY);
      return json ? JSON.parse(json) : null;
    },
    getToken: function () {
      return $window.localStorage.getItem(TOKEN_KEY);
    },
    logOut: function () {
      $window.localStorage.removeItem(TOKEN_KEY);
      $window.localStorage.removeItem(USER_KEY);
    },
  };
});

// ======== Service phân quyền menu theo role ==================
app.factory("PermissionService", function (AuthService) {
  var permissionsMatrix = {
    Admin: {
      dashboard: true,
      pos: true,
      products: true,
      categories: true,
      promotions: true,
      customers: true,
      suppliers: true,
      purchaseOrders: true,
      greceipts: true,
      gissues: true,
      sales: true,
      returns: true,
      payments: true,
      reports: true,
      auditLog: true,
      users: true,
      settings: true,
    },
    ThuNgan: {
      dashboard: false,
      pos: true,
      products: false,
      categories: false,
      promotions: true,
      customers: true,
      suppliers: false,
      purchaseOrders: false,
      greceipts: false,
      gissues: false,
      sales: true,
      returns: true,
      payments: true,
      reports: false,
      auditLog: false,
      users: false,
      settings: false,
    },
    ThuKho: {
      dashboard: false,
      pos: false,
      products: true,
      categories: true,
      promotions: false,
      customers: false,
      suppliers: true,
      purchaseOrders: true,
      greceipts: true,
      gissues: true,
      sales: false,
      returns: false,
      payments: false,
      reports: false,
      auditLog: false,
      users: false,
      settings: false,
    },
    KeToan: {
      dashboard: false,
      pos: false,
      products: false,
      categories: false,
      promotions: false,
      customers: false,
      suppliers: false,
      purchaseOrders: false,
      greceipts: false,
      gissues: false,
      sales: false,
      returns: false,
      payments: true,
      reports: true,
      auditLog: false,
      users: false,
      settings: false,
    },
    User: {
      dashboard: false,
      pos: false,
      products: false,
      categories: false,
      promotions: false,
      customers: false,
      suppliers: false,
      purchaseOrders: false,
      greceipts: false,
      gissues: false,
      sales: false,
      returns: false,
      payments: false,
      reports: false,
      auditLog: false,
      users: false,
      settings: false,
    },
  };

  return {
    getPermissions: function () {
      var currentUser = AuthService.getCurrentUser();
      if (!currentUser || !currentUser.role) return {};
      return permissionsMatrix[currentUser.role] || {};
    },
    canShow: function (key) {
      var currentUser = AuthService.getCurrentUser();
      if (!currentUser || !currentUser.role) return false;
      var matrix = permissionsMatrix[currentUser.role] || {};
      return !!matrix[key];
    },
  };
});

app.run([
  "$http",
  "AuthService",
  function ($http, AuthService) {
    var token = AuthService.getToken(); // đọc từ localStorage
    if (token) {
      // KHÔNG được gán đè $http.defaults.headers
      // Chỉ set thêm thuộc tính Authorization
      $http.defaults.headers.common["Authorization"] = "Bearer " + token;
    }
  },
]);
