var app = angular.module("AppRetailPos", []);
app.controller("loginCtrl", function ($scope, $http) {
  $scope.model = { username: "", password: "" };
  $scope.loading = false;
  $scope.error = "";

  $scope.login = function () {
    $scope.loading = true;
    $scope.error = "";
    //gọi api login
    $http
      .post(current_url + "/api-user/auth/login", {
        username: $scope.model.username,
        password: $scope.model.password,
      })
      .then(function (res) {
        var data = res.data;
        //lưu token vào localstorage
        localStorage.setItem("jwt", data.token);
        localStorage.setItem(
          "currentUser",
          JSON.stringify({
            userId: data.userId,
            username: data.username,
            fullName: data.fullName,
          })
        );

        //gắn auth header mặc định cho các request sau
        $http.defaults.headers.common["Authorization"] = "Bearer " + data.token;
        //chuyển về trang chủ
        window.location.href = "../UserFE/homecustomer.html";
      })
      .catch(function (err) {
        if (err && err.data && err.data.message) {
          $scope.error = err.data.message;
        } else {
          $scope.error = "Login failed. Please try again!";
        }
      })
      .finally(function () {
        $scope.loading = false;
      });
  };
});
