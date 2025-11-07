var app = angular.module("AppRetailPos");
app.controller(
  "dashboardCtrl",
  function ($scope, $http, AuthService, PermissionService, $window) {
    $scope.currentUser = AuthService.getCurrentUser(); //lấy user hiện tại
    // ------Kiểm tra đăng nhập, logout và chia màn hình theo quyền---------
    if (!$scope.currentUser) {
      $window.location.href = "../AuthFE/login.html";
      return;
    }
    $scope.canShow = function (key) {
      return PermissionService.canShow(key);
    };
  }
);
