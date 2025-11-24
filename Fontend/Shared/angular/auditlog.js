var app = angular.module("AppRetailPos");

app.controller("auditlogCtrl", function ($scope, $http, $timeout, AuthService, PermissionService, $window) {

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
    $scope.searchFromDate = "";
    $scope.searchToDate = "";
    $scope.searchUserID = "";
    $scope.searchOperation = ""; // CREATE, UPDATE, DELETE, LOGIN


    // ========== LOAD DỮ LIỆU AUDIT LOG TỪ API ==========
    $scope.loadAuditLogs = function (page) {
        if (!page || page < 1) page = 1;
        $scope.pager.page = page;

        var payload = {
            pageIndex: $scope.pager.page,
            pageSize: $scope.pager.size,
            userId: $scope.searchUserID ? parseInt($scope.searchUserID, 10) || null : null,
            actionKeyword: null,                    // bạn không dùng → để null là đúng
            operation: $scope.searchOperation || null,
            fromDate: $scope.searchFromDate ? $scope.searchFromDate : null,
            toDate: $scope.searchToDate ? $scope.searchToDate : null


        };
        // DÙNG POST → HOÀN HẢO VỚI [FromBody] CỦA BẠN
        $http.post(current_url + "/api-admin/auditlogs/search", payload)
            .then(function (res) {
                var body = res.data || {};

                $scope.auditLogs = body.data || [];
                $scope.pager.total = body.total || 0;
                $scope.pager.pages = Math.max(1, Math.ceil($scope.pager.total / $scope.pager.size));

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
        $scope.pager.page = 1; // Reset về trang 1 khi tìm kiếm
        $timeout.cancel(typingTimer);
        typingTimer = $timeout($scope.loadAuditLogs, 400); // delay nhẹ cho mượt
    }

    $scope.$watch("searchFromDate", triggerSearch);
    $scope.$watch("searchToDate", triggerSearch);
    $scope.$watch("searchUserID", triggerSearch);
    $scope.$watch("searchOperation", triggerSearch);

    // ========== PHÂN TRANG (giống hệt GoodsIssues) ==========
    $scope.go = function (p) {
        if (p < 1 || p > $scope.pager.pages) return;
        $scope.pager.page = p;
        $scope.loadAuditLogs();
    };

    $scope.changeSize = function () {
        $scope.pager.page = 1;
        $scope.loadAuditLogs();
    };

    // ========== KHỞI ĐỘNG BAN ĐẦU ==========
    $scope.loadAuditLogs(); // Load trang đầu tiên ngay khi vào

});