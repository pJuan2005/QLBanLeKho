var app = angular.module("AppRetailPos");

app.controller(
  "auditlogCtrl",
  function ($scope, $http, $timeout, AuthService, PermissionService, $window, TranslateService) {
    function applyLanguage(lang) {
      TranslateService.loadLanguage(lang).then(() => {
        $scope.t = TranslateService.t;
      });
    }
    applyLanguage(localStorage.getItem("appLang") || "EN");
    $scope.$on("languageChanged", function () {
      applyLanguage(localStorage.getItem("appLang") || "EN");
    });
    // ========== KIỂM TRA ĐĂNG NHẬP ==========
    $scope.currentUser = AuthService.getCurrentUser();
    if (!$scope.currentUser) {
      $window.location.href = "../AuthFE/login.html";
      return;
    }

    $scope.canShow = function (key) {
      return PermissionService.canShow(key);
    };

    // ========== DỮ LIỆU ==========
    $scope.auditLogs = [];
    $scope.pager = { page: 1, size: 15, total: 0, pages: 1 };

    // ========== FILTER TÌM KIẾM  ==========
    $scope.searchFromDate = ""; // bind với input type="date"
    $scope.searchToDate = "";
    $scope.searchUserID = "";
    $scope.searchOperation = ""; // CREATE, UPDATE, DELETE, LOGIN

    // Helper: convert Date / string -> "YYYY-MM-DD" hoặc null
    function toDateOnlyString(d) {
      if (!d) return null;

      // Nếu đã là string (ví dụ "2025-12-01") thì trả về luôn
      if (angular.isString(d)) {
        return d;
      }

      // Nếu là Date object → convert sang "YYYY-MM-DD"
      if (d instanceof Date && !isNaN(d.getTime())) {
        var year = d.getFullYear();
        var month = (d.getMonth() + 1).toString().padStart(2, "0");
        var day = d.getDate().toString().padStart(2, "0");
        return year + "-" + month + "-" + day;
      }

      // Trường hợp khác (lỡ tay gán linh tinh) → bỏ qua
      return null;
    }

    // ========== LOAD DỮ LIỆU AUDIT LOG TỪ API ==========
    $scope.loadAuditLogs = function (page) {
      if (!page || page < 1) page = 1;
      $scope.pager.page = page;

      var payload = {
        pageIndex: $scope.pager.page,
        pageSize: $scope.pager.size,
        userId: $scope.searchUserID
          ? parseInt($scope.searchUserID, 10) || null
          : null,
        actionKeyword: null, // hiện tại chưa dùng keyword
        operation: $scope.searchOperation || null,

        // QUAN TRỌNG: gửi "YYYY-MM-DD" để tránh lệch timezone
        fromDate: toDateOnlyString($scope.searchFromDate),
        toDate: toDateOnlyString($scope.searchToDate),
      };

      $http
        .post(current_url + "/api-admin/auditlogs/search", payload)
        .then(function (res) {
          var body = res.data || {};

          $scope.auditLogs = body.data || [];
          $scope.pager.total = body.total || 0;
          $scope.pager.pages = Math.max(
            1,
            Math.ceil($scope.pager.total / $scope.pager.size)
          );
        })
        .catch(function (err) {
          console.error("Lỗi load AuditLog:", err);
          $scope.auditLogs = [];
          $scope.pager.total = 0;
          $scope.pager.pages = 1;
        });
    };

    // ========== TỰ ĐỘNG TÌM KIẾM KHI NHẬP ==========
    var typingTimer;
    function triggerSearch() {
      $scope.pager.page = 1; // Reset về trang 1 khi filter đổi
      $timeout.cancel(typingTimer);
      typingTimer = $timeout($scope.loadAuditLogs, 400); // delay nhẹ cho mượt
    }

    $scope.$watch("searchFromDate", triggerSearch);
    $scope.$watch("searchToDate", triggerSearch);
    $scope.$watch("searchUserID", triggerSearch);
    $scope.$watch("searchOperation", triggerSearch);

    // ========== PHÂN TRANG ==========
    $scope.go = function (p) {
      if (p < 1 || p > $scope.pager.pages) return;
      $scope.loadAuditLogs(p);
    };

    $scope.changeSize = function () {
      $scope.pager.page = 1;
      $scope.loadAuditLogs();
    };

    // ========== KHỞI ĐỘNG BAN ĐẦU ==========
    $scope.loadAuditLogs(); // Load trang đầu tiên khi vào
  }
);
