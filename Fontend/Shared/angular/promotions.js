var app = angular.module("AppRetailPos");
app.controller(
    "promotionCtrl",
    function ($scope, $http, $timeout, AuthService, PermissionService, $window) {
        $scope.currentUser = AuthService.getCurrentUser(); // lấy user hiện tại
        // ------Kiểm tra đăng nhập, logout và chia màn hình theo quyền---------
        if (!$scope.currentUser) {
            $window.location.href = "../AuthFE/login.html";
            return;
        }
        $scope.canShow = function (key) {
            return PermissionService.canShow(key);
        };

        // ======== DATA ========
        $scope.promotions = [];
        $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };

        // thống kê cho 3 card
        $scope.stats = { totalPromotion: 0, totalActive: 0, totalExpired: 0 };

        // bộ lọc tìm kiếm (theo ngày và status)
        $scope.search = {
            fromDate: null,
            toDate: null,
            status: ""
        };

        function syncBodyClass() {
            if ($scope.showAdd || $scope.showEdit || $scope.showDelete) {
                document.body.classList.add("modal-open");
            } else {
                document.body.classList.remove("modal-open");
            }
        }

        // load dữ liệu từ api search
        $scope.LoadPromotions = function () {
            $http({
                method: "POST",
                url: current_url + "/api-core/promotions/search",
                data: {
                    pageIndex: $scope.pager.page,
                    pageSize: $scope.pager.size,
                    fromDate: $scope.search.fromDate || null,
                    toDate: $scope.search.toDate || null,
                    status: $scope.search.status || null
                },
            }).then(
                function (res) {
                    var body = res.data || {};
                    $scope.promotions = body.data || body.Data || [];
                    var total = body.totalItems || body.TotalItems || 0;
                    $scope.pager.total = total;
                    $scope.pager.pages = Math.max(
                        1,
                        Math.ceil(total / $scope.pager.size)
                    );
                    $scope.CalculateStats();
                },
                function (err) {
                    console.log(err);
                    $scope.promotions = [];
                    $scope.pager.total = 0;
                    $scope.pager.pages = 1;
                }
            );
        };

        // tối ưu khi tìm kiếm
        var typingTimer;
        function triggerSearch() {
            $scope.pager.page = 1;
            $timeout.cancel(typingTimer);
            typingTimer = $timeout($scope.LoadPromotions, 300);
        }

        // theo dõi thay đổi của bộ lọc
        $scope.$watch("search.fromDate", triggerSearch);
        $scope.$watch("search.toDate", triggerSearch);
        $scope.$watch("search.status", triggerSearch);

        // phân trang
        $scope.go = function (p) {
            if (p < 1 || p > $scope.pager.pages) return;
            $scope.pager.page = p;
            $scope.LoadPromotions();
        };

        // thay đổi số bản ghi trên trang
        $scope.changeSize = function () {
            $scope.pager.page = 1;
            $scope.LoadPromotions();
        };

        // tính thống kê cho 3 card
        $scope.CalculateStats = function () {
            if (!$scope.promotions || $scope.promotions.length === 0) {
                $scope.stats = { totalPromotion: 0, totalActive: 0, totalExpired: 0 };
                return;
            }

            // tổng số promotion
            $scope.stats.totalPromotion = $scope.promotions.length;

            // số promotion active
            let activeCount = 0;
            let expiredCount = 0;

            for (let p of $scope.promotions) {
                let status = (p.status || p.Status || "").toLowerCase();
                if (status === "active") activeCount++;
                if (status === "expired") expiredCount++;
            }

            $scope.stats.totalActive = activeCount;
            $scope.stats.totalExpired = expiredCount;
        };

        // model cho form add Promotion
        $scope.newPromotion = {
            promotionName: "",
            type: "percent",   // mặc định percent
            value: null,
            startDate: null,
            endDate: null,
            categoryID: null
        };
        $scope.savingAdd = false;

        // ======== trạng thái modal ========
        $scope.showAdd = false;

        $scope.openAdd = function () {
            $scope.resetAddForm();
            $scope.showAdd = true;
            syncBodyClass();
        };

        $scope.closeAddOnOverlay = function (e) {
            if (e.target.classList.contains("form-add")) {
                $scope.cancelAdd();
                $scope.$applyAsync();
            }
        };

        $scope.cancelAdd = function () {
            $scope.showAdd = false;
            syncBodyClass();
        };

        // ======== thêm Promotion ========
        $scope.addPromotion = function () {
            // kiểm tra value hợp lệ
            var val = parseFloat($scope.newPromotion.value);
            if (isNaN(val) || val <= 0) {
                alert("Promotion value không hợp lệ!");
                return;
            }

            var model = {
                PromotionName: $scope.newPromotion.promotionName,
                Type: $scope.newPromotion.type,
                Value: val,
                StartDate: $scope.newPromotion.startDate,
                EndDate: $scope.newPromotion.endDate,
                CategoryID: $scope.newPromotion.categoryID
                // Status không cần gửi, SQL mặc định Active
            };

            $scope.savingAdd = true;

            $http({
                method: "POST",
                url: current_url + "/api-core/promotions/create",
                data: model
            }).then(
                function () {
                    $scope.savingAdd = false;
                    alert("Thêm promotion mới thành công!");
                    $scope.resetAddForm();
                    $scope.showAdd = false;
                    syncBodyClass();
                    $scope.pager.page = 1;
                    $scope.LoadPromotions(); // reload bảng
                },
                function (err) {
                    $scope.savingAdd = false;
                    console.log(err);
                    alert("Thêm promotion không thành công!");
                }
            );
        };

        // ======== reset form ========
        $scope.resetAddForm = function () {
            $scope.newPromotion = {
                promotionName: "",
                type: "percent",
                value: null,
                startDate: null,
                endDate: null,
                categoryID: null
            };
            if ($scope.frmAddPromotion) {
                $scope.frmAddPromotion.$setPristine();
                $scope.frmAddPromotion.$setUntouched();
            }
        };

        // ----------edit Promotion-------
        $scope.editingPromotion = null;
        $scope.savingEdit = false;

        // ======== trạng thái modal ========
        $scope.showEdit = false;

        // ======== EDIT =========
        $scope.edit = function (p) {
            function toDate(val) {
                if (!val) return null;
                if (val instanceof Date) return val;
                if (typeof val === "string") {
                    // cắt chuỗi ISO "2024-11-13T00:00:00"
                    return new Date(val);
                }
                return null;
            }

            $scope.editingPromotion = {
                PromotionID: p.promotionID || p.PromotionID,
                PromotionName: p.promotionName || p.PromotionName,
                Type: p.type || p.Type,
                Value: p.value || p.Value,
                StartDate: toDate(p.startDate || p.StartDate),
                EndDate: toDate(p.endDate || p.EndDate),
                CategoryID: p.categoryID || p.CategoryID,
                Status: p.status || p.Status || "Active"
            };


            if ($scope.frmEditPromotion) {
                $scope.frmEditPromotion.$setPristine();
                $scope.frmEditPromotion.$setUntouched();
            }

            $scope.showEdit = true;
            syncBodyClass();
        };


        $scope.closeEditOnOverlay = function (e) {
            if (e.target.classList.contains("form-edit")) {
                $scope.cancelEdit();
                $scope.$applyAsync();
            }
        };

        $scope.cancelEdit = function () {
            $scope.showEdit = false;
            syncBodyClass();
        };

        $scope.updatePromotion = function () {
            if (!$scope.editingPromotion) return;

            var val = parseFloat($scope.editingPromotion.Value);
            if (isNaN(val) || val <= 0) {
                alert("Promotion value không hợp lệ!");
                return;
            }

            var model = {
                PromotionID: $scope.editingPromotion.PromotionID,
                PromotionName: $scope.editingPromotion.PromotionName,
                Type: $scope.editingPromotion.Type,
                Value: val,
                StartDate: $scope.editingPromotion.StartDate,
                EndDate: $scope.editingPromotion.EndDate,
                CategoryID: $scope.editingPromotion.CategoryID,
                Status: $scope.editingPromotion.Status
            };

            $scope.savingEdit = true;

            $http({
                method: "POST",
                url: current_url + "/api-core/promotions/update",
                data: model
            }).then(
                function () {
                    $scope.savingEdit = false;
                    alert("Cập nhật promotion thành công!");
                    $scope.showEdit = false;
                    syncBodyClass();
                    $scope.LoadPromotions(); // reload bảng
                },
                function (err) {
                    $scope.savingEdit = false;
                    console.log(err);
                    alert("Cập nhật promotion không thành công!");
                }
            );
        };

        // ======== DELETE PROMOTION =========
        $scope.deleting = null;

        $scope.remove = function (p) {
            $scope.deleting = {
                promotionID: p.promotionID || p.PromotionID,
                promotionName: p.promotionName || p.PromotionName
            };
            $scope.showDelete = true;
            syncBodyClass();
        };

        $scope.closeDeleteOnOverlay = function (e) {
            if (e.target.classList.contains("form-delete")) {
                $scope.cancelDelete(e);
                $scope.$applyAsync();
            }
        };

        $scope.cancelDelete = function (e) {
            if (e) e.stopPropagation();
            $scope.showDelete = false;
            syncBodyClass();
        };

        $scope.confirmDelete = function () {
            if (!$scope.deleting) return;
            var id = $scope.deleting.promotionID;

            $http({
                method: "POST",
                url: current_url + "/api-core/promotions/delete",
                data: { PromotionID: id }
            }).then(
                function () {
                    alert("Xóa promotion thành công!");
                    $scope.showDelete = false;
                    syncBodyClass();
                    $scope.LoadPromotions();
                },
                function (err) {
                    console.log(err);
                    alert("Xóa promotion không thành công!");
                }
            );
        };



        // khởi tạo
        $scope.LoadPromotions();
    }
);
