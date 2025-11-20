var app = angular.module("AppRetailPos");
app.controller(
    "goodsissuesCtrl",
    function ($scope, $http, $timeout, AuthService, PermissionService, $window) {

        // ========== KIỂM TRA ĐĂNG NHẬP ==========
        $scope.currentUser = AuthService.getCurrentUser();
        if (!$scope.currentUser) {
            $window.location.href = "../AuthFE/login.html";
            return;
        }
        $scope.canShow = function (key) {
            return PermissionService.canShow(key);
        };
        function syncBodyClass() {
            if ($scope.showAddIssue || $scope.showEdit || $scope.showDelete) {
                document.body.classList.add("modal-open");
            } else {
                document.body.classList.remove("modal-open");
            }
        }

        // ========== DỮ LIỆU ==========
        $scope.goodsIssues = [];
        $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };
        $scope.stats = {
            totalIssues: 0
        };


        // ========== FILTER TÌM KIẾM ==========
        $scope.searchFromDate = "";
        $scope.searchToDate = "";
        $scope.searchMinAmount = "";
        $scope.searchMaxAmount = "";
        $scope.searchUserID = "";

        // ========== LOAD DỮ LIỆU TỪ API ==========
        $scope.LoadGoodIssues = function () {
            $http({
                method: "POST",
                url: current_url + "/api-core/goodsissues/search",
                data: {
                    pageIndex: $scope.pager.page,
                    pageSize: $scope.pager.size,
                    fromDate: $scope.searchFromDate || null,
                    toDate: $scope.searchToDate || null,
                    minTotalAmount: $scope.searchMinAmount || null,
                    maxTotalAmount: $scope.searchMaxAmount || null,
                    userId: $scope.searchUserID ? parseInt($scope.searchUserID, 10) : null
                }
            }).then(
                function (res) {
                    var body = res.data || {};
                    $scope.goodsIssues = body.data || [];
                    var total = body.totalItems || 0;

                    $scope.pager.total = total;
                    $scope.pager.pages = Math.max(1, Math.ceil(total / $scope.pager.size));
                    $scope.CalculateStats();
                },
                function (err) {
                    console.error("Lỗi load Goods Issues:", err);
                    $scope.goodsIssues = [];
                    $scope.pager.total = 0;
                    $scope.pager.pages = 1;
                }
            );
        };

        // ========== TỰ ĐỘNG TÌM KIẾM KHI NHẬP ==========
        var typingTimer;
        function triggerSearch() {
            $scope.pager.page = 1;
            $timeout.cancel(typingTimer);
            typingTimer = $timeout($scope.LoadGoodIssues, 300);
        }

        $scope.$watch("searchFromDate", triggerSearch);
        $scope.$watch("searchToDate", triggerSearch);
        $scope.$watch("searchMinAmount", triggerSearch);
        $scope.$watch("searchMaxAmount", triggerSearch);
        $scope.$watch("searchUserID", triggerSearch);  // ← theo dõi UserID

        // ========== PHÂN TRANG ==========
        $scope.go = function (p) {
            if (p < 1 || p > $scope.pager.pages) return;
            $scope.pager.page = p;
            $scope.LoadGoodIssues();
        };

        $scope.changeSize = function () {
            $scope.pager.page = 1;
            $scope.LoadGoodIssues();
        };

        // ========== TÍNH TOÁN THỐNG KÊ (CHỈ TOTAL) ==========
        $scope.CalculateStats = function () {
            $scope.stats.totalIssues = $scope.goodsIssues.length;
        };

        // ======== COMMON: TẠO CHI TIẾT (DÙNG CHUNG) =========
        $scope.createGoodsIssueDetails = function (details) {
            return $http.post(current_url + "/api-core/goodsissuedetails/create", details)
                .then(function (res) {
                    // Luôn trả về một giá trị hợp lệ
                    return res.data || true;
                })
                .catch(function (err) {
                    throw err;  // Ném lỗi để catch bên ngoài
                });
        };

        // ======== MODEL ADD GOODS ISSUE =========
        $scope.newIssue = { UserID: "" };
        $scope.newIssueDetails = [];
        $scope.savingAddIssue = false;

        // ======== TRẠNG THÁI MODAL =========
        $scope.showAddIssue = false;

        // ======== MỞ FORM =========
        $scope.openAddIssue = function () {
            $scope.resetAddIssueForm();
            $scope.showAddIssue = true;
            syncBodyClass();
        };

        // ======== ĐÓNG FORM KHI CLICK OVERLAY =========
        $scope.closeAddIssueOnOverlay = function (e) {
            if (e.target.classList.contains("form-add")) {
                $scope.cancelAddIssue();
                $scope.$applyAsync();
            }
        };

        // ======== CANCEL =========
        $scope.cancelAddIssue = function () {
            $scope.showAddIssue = false;
            syncBodyClass();
        };

        // ======== THÊM DÒNG CHI TIẾT =========
        $scope.addDetailRowForNewIssue = function () {
            $scope.newIssueDetails.push({
                ProductID: null,
                Quantity: null,
                UnitPrice: null
            });
        };

        // ======== XÓA DÒNG CHI TIẾT =========
        $scope.removeDetailRowForNewIssue = function (index) {
            $scope.newIssueDetails.splice(index, 1);
        };

        // ======== ADD GOODS ISSUE + DETAILS =========
        $scope.addGoodsIssue = function () {
            if (!$scope.newIssue.UserID) {
                alert("UserID là bắt buộc!");
                return;
            }
            if ($scope.newIssueDetails.length === 0) {
                alert("Vui lòng thêm ít nhất 1 sản phẩm.");
                return;
            }

            $scope.savingAddIssue = true;

            $http.post(current_url + "/api-core/goodsissues/create", $scope.newIssue)
                .then(function (res) {
                    var issueID = res.data.issueID;
                    if (!issueID) throw new Error("Không nhận được IssueID");

                    var details = $scope.newIssueDetails.map(function (item) {
                        return {
                            IssueID: issueID,
                            ProductID: item.ProductID,
                            Quantity: item.Quantity,
                            UnitPrice: item.UnitPrice
                        };
                    });

                    return $scope.createGoodsIssueDetails(details);  // ← TRẢ VỀ PROMISE
                })
                .then(function (result) {  // ← result có thể là true hoặc res.data
                    $scope.savingAddIssue = false;
                    alert("Thêm phiếu xuất và chi tiết thành công!");
                    $scope.resetAddIssueForm();
                    $scope.showAddIssue = false;
                    syncBodyClass();
                    $scope.pager.page = 1;
                    $scope.LoadGoodIssues();

                })
                .catch(function (err) {
                    $scope.savingAddIssue = false;
                    console.error("Lỗi khi thêm phiếu xuất:", err);
                    alert("Thêm phiếu xuất không thành công: " + (err.message || err.statusText));
                });
        };

        // ======== RESET FORM =========
        $scope.resetAddIssueForm = function () {
            $scope.newIssue = { UserID: "" };
            $scope.newIssueDetails = [];
            if ($scope.frmAddGI) {
                $scope.frmAddGI.$setPristine();
                $scope.frmAddGI.$setUntouched();
            }
        };

        // ==================== THÊM SẢN PHẨM VÀO CHI TIẾT PHIẾU XUẤT (trong modal Detail) ====================
        $scope.newDetail = {}; // ĐỔI TÊN CHO ĐÚNG VỚI HTML (bạn đang dùng newDetail, không phải newIssueDetail)
        $scope.savingAddDetail = false;

        $scope.addGoodsIssueDetail = function () {
            // Validate
            if (!$scope.newDetail.ProductID || !$scope.newDetail.Quantity || !$scope.newDetail.UnitPrice) {
                alert("Vui lòng nhập đầy đủ Product ID, Quantity và Unit Price!");
                return;
            }

            if ($scope.newDetail.Quantity <= 0 || $scope.newDetail.UnitPrice < 0) {
                alert("Số lượng phải > 0, đơn giá phải ≥ 0!");
                return;
            }

            var payload = [{
                IssueID: $scope.detailIssue.IssueID,
                ProductID: parseInt($scope.newDetail.ProductID),
                Quantity: parseInt($scope.newDetail.Quantity),
                UnitPrice: parseFloat($scope.newDetail.UnitPrice)
            }];

            $scope.savingAddDetail = true;

            // DÙNG CHUNG HÀM BẠN ĐÃ VIẾT SẴN – SIÊU SẠCH!
            $scope.createGoodsIssueDetails(payload)
                .then(function () {
                    $scope.savingAddDetail = false;
                    alert("Thêm sản phẩm thành công!");

                    // Reset form nhập
                    $scope.newDetail = {};

                    // Reload lại chi tiết (cập nhật bảng + TotalAmount)
                    $scope.detail($scope.detailIssue);  // ← load lại dữ liệu mới nhất

                    // Cập nhật lại danh sách phiếu xuất ở bảng chính (để TotalAmount mới nhất)
                    $scope.LoadGoodIssues();
                })
                .catch(function (err) {
                    $scope.savingAddDetail = false;
                    console.error("Lỗi thêm chi tiết:", err);
                    var msg = err?.data?.message || err?.message || "Lỗi không xác định";
                    alert("Thêm sản phẩm thất bại: " + msg);
                });
        };

        $scope.toggleActionMenu = function (gi) {
            // Đóng tất cả menu khác
            $scope.goodsIssues.forEach(function (item) {
                item.showMenu = false;
            });
            // Mở menu dòng hiện tại
            gi.showMenu = true;
        };

        // Đóng menu khi click ngoài – mượt hơn
        document.addEventListener("click", function (e) {
            if (!e.target.closest(".action-menu")) {
                $scope.$apply(function () {
                    $scope.goodsIssues.forEach(function (item) {
                        item.showMenu = false;
                    });
                });
            }
        });

        // ==================== BIẾN CHO DETAIL GOODS ISSUES ====================
        $scope.showDetailIssue = false;          // Hiển thị form detail
        $scope.detailIssue = null;               // Thông tin header phiếu xuất
        $scope.issueDetails = [];                // Danh sách chi tiết sản phẩm
        $scope.newIssueDetail = {};              // Form thêm sản phẩm mới (dùng sau)


        // ==================== MỞ FORM DETAIL ====================
        $scope.detail = function (gi) {
            $scope.detailIssue = {
                IssueID: gi.issueID || gi.IssueID,
                IssueDate: gi.issueDate || gi.IssueDate,
                UserID: gi.userID || gi.UserID,
                TotalAmount: gi.totalAmount || gi.TotalAmount
            };

            $scope.showDetailIssue = true;
            syncBodyClass();

            var issueID = $scope.detailIssue.IssueID;

            $http.get(current_url + "/api-core/goodsissuedetails/get-by-id/" + issueID)
                .then(function (res) {
                    var rawData = res.data || [];

                    // ÉP CHUYỂN TỪ PascalCase → camelCase HOẶC GIỮ NGUYÊN PascalCase
                    // → ĐẢM BẢO LUÔN CÓ DỮ LIỆU DÙ BACKEND TRẢ THẾ NÀO
                    $scope.issueDetails = rawData.map(function (item) {
                        return {
                            ProductID: item.ProductID || item.productID,
                            ProductName: item.ProductName || item.productName || '—',
                            Quantity: item.Quantity || item.quantity || 0,
                            UnitPrice: item.UnitPrice || item.unitPrice || 0
                        };
                    });
                })
                .catch(function (err) {
                    console.error("Lỗi load chi tiết phiếu xuất:", err);
                    $scope.issueDetails = [];
                    alert("Không thể tải chi tiết phiếu xuất!");
                });
        };

        // ==================== ĐÓNG FORM KHI CLICK NGOÀI ====================
        $scope.closeDetailIssueOnOverlay = function (e) {
            if (e.target.classList.contains("form-detail")) {
                $scope.closeDetailIssue();
                $scope.$applyAsync();
            }
        };

        // ==================== ĐÓNG FORM DETAIL ====================
        $scope.closeDetailIssue = function () {
            $scope.showDetailIssue = false;
            $scope.detailIssue = null;
            $scope.issueDetails = [];
            $scope.newIssueDetail = {};
            syncBodyClass();
        };

        // ==================== XÓA CHI TIẾT SẢN PHẨM TRONG PHIẾU XUẤT ====================
        $scope.deleteGoodsIssueDetail = function (detailItem) {
            // Tạo message confirm đẹp
            var productName = detailItem.ProductName || "sản phẩm này";
            var confirmMsg = `Bạn có chắc muốn xóa sản phẩm:\n\n` +
                `• Mã SP: ${detailItem.ProductID}\n` +
                `• Tên SP: ${productName}\n` +
                `• SL: ${detailItem.Quantity} | Giá: ${detailItem.UnitPrice.toLocaleString()}đ\n\n` +
                `Hành động này không thể hoàn tác!`;

            if (!confirm(confirmMsg)) {
                return; // Người dùng bấm Cancel
            }

            var payload = {
                IssueID: $scope.detailIssue.IssueID,
                ProductID: detailItem.ProductID
                // Chỉ cần 2 trường này là đủ (theo model backend của bạn)
            };

            $scope.deletingDetail = true;

            $http.post(current_url + "/api-core/goodsissuedetails/delete", payload)
                .then(function (res) {
                    $scope.deletingDetail = false;
                    alert("Xóa sản phẩm thành công!");

                    // Reload lại chi tiết + cập nhật bảng chính
                    $scope.detail($scope.detailIssue);  // load lại dữ liệu mới nhất
                    $scope.LoadGoodIssues();            // cập nhật TotalAmount ở bảng danh sách
                })
                .catch(function (err) {
                    $scope.deletingDetail = false;
                    console.error("Lỗi xóa chi tiết:", err);
                    var msg = err?.data?.message || "Xóa thất bại!";
                    alert("Lỗi: " + msg);
                });
        };


        // ========== KHỞI TẠO ==========
        $scope.LoadGoodIssues();
    }
);