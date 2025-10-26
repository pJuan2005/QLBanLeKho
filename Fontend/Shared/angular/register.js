var app = angular.module("AppRetailPos", []);
app.controller("registerCtrl", function ($scope, $http) {
  $scope.model = {
    fullname: "",
    username: "",
    password: "",
    confirmpass: "",
  };
  $scope.error = "";
  $scope.loading = false;

  $scope.create = function () {
    $scope.error = "";
    //kiểm tra trùng mật khẩu
    if ($scope.model.password !== $scope.model.confirmpass) {
      //   $scope.error = "Password do not match!";
      alert("Password do not match!");
      return;
    }

    //gọi api nếu hợp lệ
    $scope.loading = true;
    $http
      .post(current_url + "/api-user/auth/register", {
        fullname: $scope.model.fullname,
        username: $scope.model.username,
        passwordHash: $scope.model.password,
        role: "User",
      })
      .then(function (res) {
        alert("Register successful! Please login to continue.");
        window.location.href = "../AuthFE/login.html";
      })
      .catch(function (err) {
        if (err && err.data && err.data.message) {
          $scope.error = err.data.message;
        } else {
          $scope.error = "Error while register! Please try again.";
        }
      })
      .finally(function () {
        $scope.loading = false;
      });
  };
});
