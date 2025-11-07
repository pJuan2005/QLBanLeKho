var app = angular.module("AppRetailPos"); //lấy lại module đã khai báo
app.controller("QuanTriLoginCtrl", function ($scope, $http, AuthService) {
  $scope.model = { username: "", password: "" };
  $scope.loading = false;
  $scope.error = "";

  $scope.login = function () {
    $scope.loading = true;
    $scope.error = "";
    if (!$scope.model.username || !$scope.model.password) {
      $scope.error = "Please enter username and password!";
      $scope.loading = false;
      return;
    }

    // gọi api login cho nhân viên
    $http
      .post(current_url + "/api-user/auth/login", {
        username: $scope.model.username,
        password: $scope.model.password,
      })
      .then(function (res) {
        var data = res.data;
        // be trả về{token,username,role,email,phone}
        // lưu vào authservice
        AuthService.saveLogin({
          token: data.token,
          username: data.username,
          fullname: data.fullname,
          role: data.role,
          email: data.email,
          phone: data.phone,
        });

        // gắn auth header mặc định cho các request sau
        $http.defaults.headers.common["Authorization"] = "Bearer " + data.token;
        // điều hướng theo role
        var target = "../UserFE/homecustomer.html"; // default nếu không khớp
        switch (data.role) {
          case "Admin":
            target = "../AdminFE/dashboard.html";
            break;
          case "ThuNgan":
            target = "../AdminFE/pos.html";
            break;
          case "ThuKho":
            target = "../AdminFE/stockcard.html";
            break;
          case "KeToan":
            target = "../AdminFE/payments.html";
            break;
        }
        window.location.href = target;
      })
      .catch(function (err) {
        if (err && err.data && err.data.message) {
          $scope.error = err.data.message;
        } else {
          $scope.error = "Login fail. Please try again!";
        }
      })
      .finally(function () {
        $scope.loading = false;
      });
  };
});
