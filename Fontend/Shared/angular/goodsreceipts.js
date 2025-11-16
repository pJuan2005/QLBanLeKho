var app = angular.module("AppRetailPos");
app.controller(
    "goodsreceiptsCtrl",
    function ($scope, $http, $timeout, AuthService, PermissionService, $window) {
        $scope.currentUser = AuthService.getCurrentUser(); // lấy user hiện tại
        if (!$scope.currentUser) {
            $window.location.href = "../AuthFE/login.html";
            return;
        }
        $scope.canShow = function (key) {
            return PermissionService.canShow(key);
        };

        // dữ liệu
        $scope.goodsReceipts = [];
        $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };
        $scope.stats = {
            totalReceipts: 0,
            totalAmount: 0,
            totalCompleted: 0,
            totalPending: 0,
            totalProcessing: 0,
        };
        function syncBodyClass() {
            if ($scope.showAdd || $scope.showEdit || $scope.showDelete) {
                document.body.classList.add("modal-open");
            } else {
                document.body.classList.remove("modal-open");
            }
        }



        // filter tìm kiếm
        $scope.searchFromDate = "";
        $scope.searchToDate = "";
        $scope.searchMinAmount = "";
        $scope.searchMaxAmount = "";
        $scope.searchPOID = "";

        // load dữ liệu từ API search
        $scope.LoadGoodReceipts = function () {
            $http({
                method: "POST",
                url: current_url + "/api-core/goodsreceipts/search",
                data: {
                    pageIndex: $scope.pager.page,
                    pageSize: $scope.pager.size,
                    fromDate: $scope.searchFromDate || null,
                    toDate: $scope.searchToDate || null,
                    minTotalAmount: $scope.searchMinAmount || null,
                    maxTotalAmount: $scope.searchMaxAmount || null,
                    POID: $scope.searchPOID || "",
                },
            }).then(
                function (res) {
                    var body = res.data || {};
                    // BE hiện tại trả về Data và TotalItems (chữ hoa đầu)
                    $scope.goodsReceipts = body.data || [];
                    var total = body.totalItems || 0;

                    $scope.pager.total = total;
                    $scope.pager.pages = Math.max(
                        1,
                        Math.ceil(total / $scope.pager.size)
                    );
                    $scope.CalculateStats();
                },
                function (err) {
                    console.log(err);
                    $scope.goodsReceipts = [];
                    $scope.pager.total = 0;
                    $scope.pager.pages = 1;
                }
            );
        };


        // tối ưu khi tìm kiếm: auto trigger khi thay đổi filter
        var typingTimer;
        function triggerSearch() {
            $scope.pager.page = 1;
            $timeout.cancel(typingTimer);
            typingTimer = $timeout($scope.LoadGoodReceipts, 300);
        }
        $scope.$watch("searchFromDate", triggerSearch);
        $scope.$watch("searchToDate", triggerSearch);
        $scope.$watch("searchMinAmount", triggerSearch);
        $scope.$watch("searchMaxAmount", triggerSearch);
        $scope.$watch("searchPOID", triggerSearch);

        // phân trang
        $scope.go = function (p) {
            if (p < 1 || p > $scope.pager.pages) return;
            $scope.pager.page = p;
            $scope.LoadGoodReceipts();
        };

        // thay đổi số bản ghi trên trang
        $scope.changeSize = function () {
            $scope.pager.page = 1;
            $scope.LoadGoodReceipts();
        };

        // tính toán thống kê
        $scope.CalculateStats = function () {
            if (!$scope.goodsReceipts || $scope.goodsReceipts.length === 0) {
                $scope.stats.totalReceipts = 0;
                $scope.stats.totalCompleted = 0;
                $scope.stats.totalPending = 0;
                $scope.stats.totalProcessing = 0;
                return;
            }

            let completed = 0, pending = 0, processing = 0;
            for (let gr of $scope.goodsReceipts) {
                let status = (gr.status || gr.Status || "").toLowerCase();
                if (status === "completed") completed++;
                else if (status === "pending") pending++;
                else if (status === "processing") processing++;
            }

            $scope.stats.totalReceipts = $scope.goodsReceipts.length;
            $scope.stats.totalCompleted = completed;
            $scope.stats.totalPending = pending;
            $scope.stats.totalProcessing = processing;
        };

        // ======== MODEL ADD GOODS RECEIPT =========
        $scope.newReceipt = {
            POID: "",
            UserID: ""
        };
        $scope.newReceiptDetails = [];
        $scope.savingAddReceipt = false;

        // ======== TRẠNG THÁI MODAL =========
        $scope.showAddReceipt = false;

        // ======== MỞ FORM =========
        $scope.openAddReceipt = function () {
            $scope.resetAddReceiptForm();
            $scope.showAddReceipt = true;
            syncBodyClass();
        };

        // ======== ĐÓNG FORM KHI CLICK OVERLAY =========
        $scope.closeAddReceiptOnOverlay = function (e) {
            if (e.target.classList.contains("form-add")) {
                $scope.cancelAddReceipt();
                $scope.$applyAsync();
            }
        };

        // ======== CANCEL =========
        $scope.cancelAddReceipt = function () {
            $scope.showAddReceipt = false;
            syncBodyClass();
        };

        // ======== THÊM DÒNG CHI TIẾT =========
        $scope.addDetailRowForNewReceipt = function () {
            $scope.newReceiptDetails.push({
                ProductID: null,
                Quantity: null,
                UnitPrice: null,
                ExpiryDate: null
            });
        };

        // ======== XÓA DÒNG CHI TIẾT =========
        $scope.removeDetailRowForNewReceipt = function (index) {
            $scope.newReceiptDetails.splice(index, 1);
        };

        // ======== ADD GOODS RECEIPT + DETAILS =========
        $scope.addGoodsReceipt = function () {
            if (!$scope.newReceipt.POID || !$scope.newReceipt.UserID) {
                alert("POID và UserID là bắt buộc!");
                return;
            }
            if ($scope.newReceiptDetails.length === 0) {
                alert("Vui lòng thêm ít nhất 1 sản phẩm vào chi tiết phiếu nhập.");
                return;
            }

            $scope.savingAddReceipt = true;

            $http.post(current_url + "/api-core/goodsreceipts/create", $scope.newReceipt)
                .then(function (res) {
                    var receiptID = res.data.receiptID;
                    if (!receiptID) throw new Error("Không nhận được ReceiptID từ API goodsreceipts/create");

                    var details = $scope.newReceiptDetails.map(function (item) {
                        return {
                            ReceiptID: receiptID,
                            ProductID: item.ProductID,
                            Quantity: item.Quantity,
                            UnitPrice: item.UnitPrice,
                            ExpiryDate: item.ExpiryDate
                        };
                    });

                    return $http.post(current_url + "/api-core/goodsreceiptdetails/create", details);
                })
                .then(function () {
                    $scope.savingAddReceipt = false;
                    alert("Thêm phiếu nhập và chi tiết thành công!");
                    $scope.resetAddReceiptForm();
                    $scope.showAddReceipt = false;
                    syncBodyClass();
                    $scope.pager.page = 1;
                    $scope.LoadGoodReceipts();
                })
                .catch(function (err) {
                    $scope.savingAddReceipt = false;
                    console.error("Lỗi khi thêm phiếu nhập:", err);
                    alert("Thêm phiếu nhập không thành công!");
                });
        };

        // ======== RESET FORM =========
        $scope.resetAddReceiptForm = function () {
            $scope.newReceipt = {
                POID: "",
                UserID: ""
            };
            $scope.newReceiptDetails = [];
            if ($scope.frmAddGR) {
                $scope.frmAddGR.$setPristine();
                $scope.frmAddGR.$setUntouched();
            }
        };


        // ----------edit-------
        $scope.editingReceipt = null;
        $scope.savingEdit = false;

        // ======== trạng thái modal ========
        $scope.showEdit = false;

        // ======== EDIT =========
        $scope.edit = function (gr) {
            $scope.editingReceipt = {
                ReceiptID: gr.receiptID || gr.ReceiptID,
                ReceiptDate: gr.receiptDate || gr.ReceiptDate,
                UserID: gr.userID || gr.UserID
            };

            if ($scope.frmEditGR) {
                $scope.frmEditGR.$setPristine();
                $scope.frmEditGR.$setUntouched();
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

        $scope.updateGoodsReceipt = function () {
            if (!$scope.editingReceipt) return;

            var model = {
                ReceiptID: $scope.editingReceipt.ReceiptID,
                ReceiptDate: $scope.editingReceipt.ReceiptDate,
                UserID: $scope.editingReceipt.UserID
            };

            $scope.savingEdit = true;

            $http({
                method: "POST", // Controller đang dùng [HttpPost]
                url: current_url + "/api-core/goodsreceipts/update",
                data: model
            }).then(
                function () {
                    $scope.savingEdit = false;
                    alert("Cập nhật phiếu nhập thành công!");
                    $scope.showEdit = false;
                    syncBodyClass();
                    $scope.LoadGoodReceipts(); // reload danh sách
                },
                function (err) {
                    $scope.savingEdit = false;
                    console.error(err);
                    alert("Cập nhật phiếu nhập không thành công!");
                }
            );
        };

        // ----------delete---------
        $scope.showDelete = false;
        $scope.deleting = null;

        // ======== trạng thái modal ========
        $scope.showDelete = false;

        // ======== DELETE =========
        $scope.deleting = null;

        $scope.remove = function (gr) {
            $scope.deleting = {
                ReceiptID: gr.receiptID || gr.ReceiptID,
                BatchNo: gr.batchNo || gr.BatchNo
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

            var model = {
                ReceiptID: $scope.deleting.ReceiptID
            };

            $http({
                method: "POST",
                url: current_url + "/api-core/goodsreceipts/delete",
                data: model
            }).then(
                function () {
                    alert("Xóa phiếu nhập thành công!");
                    $scope.showDelete = false;
                    syncBodyClass();
                    $scope.LoadGoodReceipts();
                },
                function (err) {
                    console.error(err);
                    alert("Xóa phiếu nhập không thành công!");
                }
            );
        };

        //Detail

        $scope.showDetail = false;
        $scope.detailReceipt = null;
        $scope.receiptDetails = [];

        // Mở form detail
        $scope.detail = function (gr) {
            $scope.detailReceipt = {
                ReceiptID: gr.receiptID || gr.ReceiptID,
                BatchNo: gr.batchNo || gr.BatchNo,
                POID: gr.poid || gr.POID,
                ReceiptDate: gr.receiptDate || gr.ReceiptDate,
                UserID: gr.userID || gr.UserID,
                Status: gr.status || gr.Status
            };
            $scope.showDetail = true;
            syncBodyClass();

            var receiptID = $scope.detailReceipt.ReceiptID;

            $http.get(current_url + "/api-core/goodsreceiptdetails/get-by-id/" + receiptID)
                .then(function (res) {
                    $scope.receiptDetails = res.data || [];
                }, function (err) {
                    console.error(err);
                    $scope.receiptDetails = [];
                });
        };



        // Đóng form khi click overlay
        $scope.closeDetailOnOverlay = function (e) {
            if (e.target.classList.contains("form-detail")) {
                $scope.closeDetail();
                $scope.$applyAsync();
            }
        };

        // Đóng form detail
        $scope.closeDetail = function () {
            $scope.showDetail = false;
            syncBodyClass();
        };


        // Model cho form add chi tiết
        $scope.newDetail = {
            ProductID: null,
            Quantity: null,
            UnitPrice: null,
            ExpiryDate: null
        };
        $scope.savingAddDetail = false;

        // Thêm chi tiết vào phiếu nhập đã có
        $scope.addGoodsReceiptDetail = function () {
            var receiptID = $scope.detailReceipt?.ReceiptID;
            if (!receiptID) {
                alert("Không xác định được ReceiptID.");
                return;
            }

            if (!$scope.newDetail.ProductID || !$scope.newDetail.Quantity || !$scope.newDetail.UnitPrice) {
                alert("Vui lòng nhập đầy đủ ProductID, Quantity và UnitPrice.");
                return;
            }

            var model = [{
                ReceiptID: receiptID,
                ProductID: $scope.newDetail.ProductID,
                Quantity: $scope.newDetail.Quantity,
                UnitPrice: $scope.newDetail.UnitPrice,
                ExpiryDate: $scope.newDetail.ExpiryDate
            }];

            $scope.savingAddDetail = true;

            $http.post(current_url + "/api-core/goodsreceiptdetails/create", model)
                .then(function () {
                    $scope.savingAddDetail = false;
                    alert("Thêm chi tiết thành công!");
                    $scope.newDetail = {}; // reset form
                    $scope.detail($scope.detailReceipt); // reload lại chi tiết
                    $scope.LoadGoodReceipts(); // 🔁 reload lại bảng danh sách phiếu nhập
                })
                .catch(function (err) {
                    $scope.savingAddDetail = false;
                    console.error("Lỗi khi thêm chi tiết:", err);
                    alert("Thêm chi tiết không thành công!");
                });
        };

        $scope.deleteGoodsReceiptDetail = function (detail) {
            var receiptID = $scope.detailReceipt?.ReceiptID;
            var productID = detail?.productID;

            if (!receiptID || !productID) {
                alert("Không xác định được bản ghi cần xóa.");
                return;
            }

            if (!confirm("Bạn có chắc muốn xóa sản phẩm này khỏi phiếu nhập?")) return;

            $http.post(current_url + "/api-core/goodsreceiptdetails/delete", {
                ReceiptID: receiptID,
                ProductID: productID
            }).then(function () {
                alert("Xóa chi tiết thành công!");
                $scope.detail($scope.detailReceipt); // reload lại bảng chi tiết
                $scope.LoadGoodReceipts(); // reload lại bảng GR
            }, function (err) {
                console.error(err);
                alert("Xóa chi tiết không thành công!");
            });
        };

        //Export
        $scope.exportExcel = function () {
            if (!$scope.selectedReceipt?.ReceiptID && !$scope.selectedReceipt?.receiptID) {
                alert("Vui lòng chọn một phiếu nhập để xuất Excel.");
                return;
            }

            var receiptID = $scope.selectedReceipt.ReceiptID || $scope.selectedReceipt.receiptID;

            $http.get(current_url + "/api-core/goodsreceipts/export-excel/" + receiptID, {
                responseType: 'blob'
            }).then(function (res) {
                var blob = new Blob([res.data], {
                    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                });
                var link = document.createElement("a");
                link.href = window.URL.createObjectURL(blob);
                link.download = "GoodsReceipt_" + receiptID + ".xlsx";
                link.click();
            }, function (err) {
                console.error(err);
                alert("Xuất Excel không thành công!");
            });
        };
        $scope.selectedReceipt = null;

        $scope.toggleActionMenu = function (gr) {
            // Đóng tất cả menu khác trước khi mở
            $scope.goodsReceipts.forEach(function (item) {
                item.showMenu = false;
            });

            gr.showMenu = true;
        };
        document.addEventListener("click", function (e) {
            var isMenuClick = e.target.closest(".action-menu");
            if (!isMenuClick) {
                $scope.$apply(function () {
                    $scope.goodsReceipts.forEach(function (item) {
                        item.showMenu = false;
                    });
                });
            }
        });

        $scope.exportExcel = function (gr) {
            if (!gr || !gr.receiptID) {
                alert("Không xác định được phiếu nhập cần xuất.");
                return;
            }

            var receiptID = gr.receiptID;

            $http.get(current_url + "/api-core/goodsreceipts/export-excel/" + receiptID, {
                responseType: 'blob'
            }).then(function (res) {
                var blob = new Blob([res.data], {
                    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                });

                var link = document.createElement("a");
                link.href = window.URL.createObjectURL(blob);
                link.download = "GoodsReceipt_" + receiptID + ".xlsx";
                link.click();
            }, function (err) {
                console.error("Lỗi khi xuất Excel:", err);
                alert("Xuất Excel không thành công!");
            });
        };

        // khởi tạo
        $scope.LoadGoodReceipts();
    }
);
