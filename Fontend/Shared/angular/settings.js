var app = angular.module("AppRetailPos");
app.controller("settingCtrl", function ($scope, $http, $timeout, AuthService, PermissionService, $window,TranslateService) {
  $scope.currentUser = AuthService.getCurrentUser(); // lấy user 
  $scope.settings = {};



  function applyLanguage(lang) {
        TranslateService.loadLanguage(lang).then(() => {
            $scope.t = TranslateService.t;
        });
    }




  $scope.savingAdd = false;

  $scope.editingProduct = null;
  $scope.savingEdit = false;

  $scope.showDelete = false;
  $scope.deleting = null;



  // ------Kiểm tra đăng nhập, logout và chia màn hình theo quyền---------
  if (!$scope.currentUser) {
    $window.location.href = "../AuthFE/login.html";
    return;
  }
  $scope.canShow = function (key) {
    return PermissionService.canShow(key);
  };




  // ============================
    // 1️⃣ GET SETTINGS (GATEWAY)
    // ============================
    $scope.loadSettings = function () {
        $http.get(current_url + "/api-admin/settings/get").then(
            function (res) {
                console.log("Settings loaded:", res.data);
                $scope.settings = res.data;

                applyLanguage($scope.settings.defaultLanguage);
            },
            function (err) {
                console.log("LOAD ERROR:", err);
                alert("Failed to load settings!");
            }
        );
    };

    // Gọi ngay khi vào trang
    $scope.loadSettings();

    // ============================
    // 2️⃣ UPDATE SETTINGS (GATEWAY)
    // ============================
    $scope.updateSettings = function () {
        $scope.isSaving = true;

        $http.put(current_url + "/api-admin/settings/update", $scope.settings).then(
            function () {
                alert("Settings updated successfully!");
                localStorage.setItem("appLang", $scope.settings.defaultLanguage);
                applyLanguage($scope.settings.defaultLanguage);
                $scope.isSaving = false;
            },
            function (err) {
                console.log("UPDATE ERROR:", err);
                alert("Update failed!");
                $scope.isSaving = false;
            }
        );
    };
})