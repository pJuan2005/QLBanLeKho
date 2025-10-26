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
        // Log kỹ để debug
        console.group("Register error");
        console.log("URL   :", err && err.config && err.config.url);
        console.log("Status:", err && err.status, err && err.statusText);
        console.log("Data  :", err && err.data);
        console.groupEnd();

        var msg = "Register failed. Please try again!";

        // 1) Lỗi mạng/CORS, server không trả về gì
        if (!err || err.status === 0) {
          msg = "Cannot reach server (network/CORS).";
        }
        // 2) Server trả text thuần
        else if (typeof err.data === "string" && err.data.trim()) {
          msg = err.data;
        }
        // 3) Dạng có { message }
        else if (err.data && err.data.message) {
          msg = err.data.message;
        }
        // 4) ASP.NET Core ProblemDetails: { title, detail, errors: { Field: [..] } }
        else if (err.data && (err.data.title || err.data.errors)) {
          var parts = [];
          if (err.data.title) parts.push(err.data.title);
          if (err.data.detail) parts.push(err.data.detail);
          if (err.data.errors) {
            // gom model-state errors
            var errs = [];
            Object.keys(err.data.errors).forEach(function (k) {
              var arr = err.data.errors[k];
              if (Array.isArray(arr) && arr.length) {
                errs.push(k + ": " + arr.join(", "));
              }
            });
            if (errs.length) parts.push(errs.join("\n"));
          }
          msg = parts.join("\n");
        }
        // 5) fallback theo status
        else if (err.status === 400) {
          msg = "Bad Request (400). Check payload/fields.";
        } else if (err.status === 401) {
          msg = "Unauthorized (401).";
        } else if (err.status === 502 || err.status === 504) {
          msg = "Gateway error (" + err.status + ").";
        }

        $scope.error = msg;
      })

      .finally(function () {
        $scope.loading = false;
      });
  };
});
