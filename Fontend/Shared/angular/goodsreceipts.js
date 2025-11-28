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

    function syncBodyClass() {
      if (
        $scope.showAddReceipt ||
        $scope.showEdit ||
        $scope.showDelete ||
        $scope.showDetail
      ) {
        document.body.classList.add("modal-open");
      } else {
        document.body.classList.remove("modal-open");
      }
    }

    // dữ liệu
    $scope.goodsReceipts = [];
    $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };
    $scope.stats = {
      totalReceipts: 0,
      totalAmount: 0,
      totalPaid: 0,
      totalUnpaid: 0,
      totalPartial: 0,
    };

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
        $scope.stats.totalPaid = 0;
        $scope.stats.totalUnpaid = 0;
        $scope.stats.totalPartial = 0;
        return;
      }

      let paid = 0,
        unpaid = 0,
        partial = 0;
      for (let gr of $scope.goodsReceipts) {
        let status = (gr.status || gr.Status || "").toLowerCase();
        if (status === "paid") paid++;
        else if (status === "unpaid") unpaid++;
        else if (status === "partial") partial++;
      }

      $scope.stats.totalReceipts = $scope.goodsReceipts.length;
      $scope.stats.totalPaid = paid;
      $scope.stats.totalUnpaid = unpaid;
      $scope.stats.totalPartial = partial;
    };

    // ========== HÀM CHUNG: TẠO CHI TIẾT PHIẾU NHẬP (DÙNG CHO CẢ ADD VÀ DETAIL) ==========
    $scope.createGoodsReceiptDetails = function (details) {
      return $http
        .post(current_url + "/api-core/goodsreceiptdetails/create", details)
        .then(function (res) {
          return res.data || true;
        })
        .catch(function (err) {
          throw err;
        });
    };

    // ======== MODEL ADD GOODS RECEIPT =========
    $scope.newReceipt = {
      POID: "",
      UserID: "",
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
        $scope.showAddReceipt = false;
        syncBodyClass();
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
        ExpiryDate: null,
      });
    };

    // ======== XÓA DÒNG CHI TIẾT =========
    $scope.removeDetailRowForNewReceipt = function (index) {
      $scope.newReceiptDetails.splice(index, 1);
    };

    // ======== ADD GOODS RECEIPT + DETAILS =========
    $scope.addGoodsReceipt = function () {
      if (!$scope.newReceipt.POID || !$scope.newReceipt.UserID)
        return alert("POID và UserID là bắt buộc!");
      if ($scope.newReceiptDetails.length === 0)
        return alert("Vui lòng thêm ít nhất 1 sản phẩm!");

      $scope.savingAddReceipt = true;

      $http
        .post(current_url + "/api-core/goodsreceipts/create", $scope.newReceipt)
        .then(function (res) {
          var receiptID = res.data.receiptID;
          if (!receiptID) throw new Error("Không nhận được ReceiptID");

          var details = $scope.newReceiptDetails.map(function (d) {
            return {
              ReceiptID: receiptID,
              ProductID: d.ProductID,
              Quantity: d.Quantity,
              UnitPrice: d.UnitPrice,
              ExpiryDate: d.ExpiryDate || null,
            };
          });

          return $scope.createGoodsReceiptDetails(details);
        })
        .then(function () {
          alert("Thêm phiếu nhập thành công!");
          $scope.showAddReceipt = false;
          $scope.resetAddReceiptForm();
          syncBodyClass();
          $scope.LoadGoodReceipts();
        })
        .catch(function (err) {
          console.error(err);
          alert("Thêm thất bại!");
        })
        .finally(function () {
          $scope.savingAddReceipt = false;
        });
    };

    // ======== RESET FORM =========
    $scope.resetAddReceiptForm = function () {
      $scope.newReceipt = { POID: "", UserID: "" };
      $scope.newReceiptDetails = [];
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
        UserID: gr.userID || gr.UserID,
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
        UserID: $scope.editingReceipt.UserID,
      };

      $scope.savingEdit = true;

      $http({
        method: "POST", // Controller đang dùng [HttpPost]
        url: current_url + "/api-core/goodsreceipts/update",
        data: model,
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
        BatchNo: gr.batchNo || gr.BatchNo,
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
        ReceiptID: $scope.deleting.ReceiptID,
      };

      $http({
        method: "POST",
        url: current_url + "/api-core/goodsreceipts/delete",
        data: model,
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

    // ==================== DETAIL PHIẾU NHẬP ====================
    $scope.showDetail = false;
    $scope.detailReceipt = null;
    $scope.receiptDetails = [];
    $scope.newDetail = {};
    $scope.savingAddDetail = false;

    $scope.detail = function (gr) {
      $scope.detailReceipt = {
        ReceiptID: gr.receiptID || gr.ReceiptID,
        BatchNo: gr.batchNo || gr.BatchNo,
        POID: gr.poid || gr.POID,
        ReceiptDate: gr.receiptDate || gr.ReceiptDate,
        UserID: gr.userID || gr.UserID,
      };

      $scope.showDetail = true;
      syncBodyClass();

      $http
        .get(
          current_url +
            "/api-core/goodsreceiptdetails/get-by-id/" +
            $scope.detailReceipt.ReceiptID
        )
        .then(function (res) {
          var data = res.data || [];
          $scope.receiptDetails = data.map(function (item) {
            return {
              productID: item.ProductID || item.productID,
              productName: item.ProductName || item.productName || "—",
              quantity: item.Quantity || item.quantity,
              unitPrice: item.UnitPrice || item.unitPrice,
              expiryDate: item.ExpiryDate || item.expiryDate,
            };
          });
        })
        .catch(function () {
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
      $scope.detailReceipt = null;
      $scope.receiptDetails = [];
      $scope.newDetail = {};
      syncBodyClass();
    };

    // Thêm chi tiết vào phiếu cũ
    $scope.addGoodsReceiptDetail = function () {
      if (
        !$scope.newDetail.ProductID ||
        !$scope.newDetail.Quantity ||
        !$scope.newDetail.UnitPrice
      ) {
        return alert("Vui lòng nhập đầy đủ thông tin!");
      }

      var payload = [
        {
          ReceiptID: $scope.detailReceipt.ReceiptID,
          ProductID: $scope.newDetail.ProductID,
          Quantity: $scope.newDetail.Quantity,
          UnitPrice: $scope.newDetail.UnitPrice,
          ExpiryDate: $scope.newDetail.ExpiryDate || null,
        },
      ];

      $scope.savingAddDetail = true;

      $scope
        .createGoodsReceiptDetails(payload)
        .then(function () {
          alert("Thêm sản phẩm thành công!");
          $scope.newDetail = {};
          $scope.detail($scope.detailReceipt);
          $scope.LoadGoodReceipts();
        })
        .catch(function (err) {
          console.error(err);
          alert("Thêm thất bại!");
        })
        .finally(function () {
          $scope.savingAddDetail = false;
        });
    };

    // Xóa chi tiết
    $scope.deleteGoodsReceiptDetail = function (d) {
      if (!confirm(`Xóa sản phẩm ${d.productID} - ${d.productName || ""}?`))
        return;

      $http
        .post(current_url + "/api-core/goodsreceiptdetails/delete", {
          ReceiptID: $scope.detailReceipt.ReceiptID,
          ProductID: d.productID,
        })
        .then(function () {
          alert("Xóa thành công!");
          $scope.detail($scope.detailReceipt);
          $scope.LoadGoodReceipts();
        })
        .catch(function () {
          alert("Xóa thất bại!");
        });
    };

    //Export
    $scope.exportExcel = function () {
      if (
        !$scope.selectedReceipt?.ReceiptID &&
        !$scope.selectedReceipt?.receiptID
      ) {
        alert("Vui lòng chọn một phiếu nhập để xuất Excel.");
        return;
      }

      var receiptID =
        $scope.selectedReceipt.ReceiptID || $scope.selectedReceipt.receiptID;

      $http
        .get(
          current_url + "/api-core/goodsreceipts/export-excel/" + receiptID,
          {
            responseType: "blob",
          }
        )
        .then(
          function (res) {
            var blob = new Blob([res.data], {
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            });
            var link = document.createElement("a");
            link.href = window.URL.createObjectURL(blob);
            link.download = "GoodsReceipt_" + receiptID + ".xlsx";
            link.click();
          },
          function (err) {
            console.error(err);
            alert("Xuất Excel không thành công!");
          }
        );
    };
    $scope.selectedReceipt = null;

    // Action menu
    $scope.toggleActionMenu = function (gr) {
      $scope.goodsReceipts.forEach(function (item) {
        item.showMenu = false;
      });
      gr.showMenu = true;
    };

    document.addEventListener("click", function (e) {
      if (!e.target.closest(".action-menu")) {
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

      $http
        .get(
          current_url + "/api-core/goodsreceipts/export-excel/" + receiptID,
          {
            responseType: "blob",
          }
        )
        .then(
          function (res) {
            var blob = new Blob([res.data], {
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            });

            var link = document.createElement("a");
            link.href = window.URL.createObjectURL(blob);
            link.download = "GoodsReceipt_" + receiptID + ".xlsx";
            link.click();
          },
          function (err) {
            console.error("Lỗi khi xuất Excel:", err);
            alert("Xuất Excel không thành công!");
          }
        );
    };

    // ==================== THANH TOÁN NHÀ CUNG CẤP ====================
    $scope.showPaymentModal = false;
    $scope.paymentReceipt = null;
    $scope.paymentHistory = [];
    $scope.newPayment = {};
    $scope.savingPayment = false;

    $scope.payment = function (gr) {
      var receiptID = gr.receiptID || gr.ReceiptID;

      // GỌI API THANH TOÁN ĐỂ LẤY SUPPLIERID (VÌ NÓ CÓ CHẮC CHẮN!)
      $http
        .post(current_url + "/api-core/payments/search-payment", {
          page: 1,
          pageSize: 100,
          ReceiptID: receiptID,
          CustomerID: null,
          SupplierID: null,
          SaleID: null,
          Method: "",
          FromDate: null,
          ToDate: null,
        })
        .then(function (res) {
          var payments = res.data.data || [];
          var supplierID = payments.length > 0 ? payments[0].supplierID : null;

          // GÁN ĐÚNG SUPPLIERID TỪ BẢNG PAYMENTS
          $scope.paymentReceipt = {
            ReceiptID: receiptID,
            POID: gr.poid || gr.POID,
            TotalAmount: gr.totalAmount || gr.TotalAmount || 0,
            SupplierID: supplierID, // ← ĐÚNG RỒI ĐÂY!
            SupplierName: supplierID ? "Nhà cung cấp #" + supplierID : "—",
          };

          // Gán luôn lịch sử thanh toán
          $scope.paymentHistory = payments;

          // Mở modal
          $scope.showPaymentModal = true;
          $scope.newPayment = { Amount: null, Method: "", Description: "" };
          syncBodyClass();
        })
        .catch(function (err) {
          console.error("Lỗi load payment history:", err);

          // Trường hợp chưa có thanh toán nào → vẫn mở modal, nhưng SupplierID = null
          $scope.paymentReceipt = {
            ReceiptID: receiptID,
            POID: gr.poid || gr.POID,
            TotalAmount: gr.totalAmount || gr.TotalAmount || 0,
            SupplierID: null,
            SupplierName: "—",
          };
          $scope.paymentHistory = [];
          $scope.showPaymentModal = true;
          $scope.newPayment = { Amount: null, Method: "", Description: "" };
          syncBodyClass();
        });
    };

    $scope.closePaymentModal = function () {
      $scope.showPaymentModal = false;
      $scope.paymentReceipt = null;
      $scope.paymentHistory = [];
      $scope.newPayment = {};
      syncBodyClass();
    };

    $scope.addPayment = function () {
      if (!$scope.newPayment.Amount || $scope.newPayment.Amount <= 0) {
        alert("Vui lòng nhập số tiền hợp lệ!");
        return;
      }
      if (!$scope.newPayment.Method) {
        alert("Vui lòng chọn hình thức thanh toán!");
        return;
      }

      var payload = {
        ReceiptID: $scope.paymentReceipt.ReceiptID,
        SupplierID: $scope.paymentReceipt.SupplierID,
        Amount: parseFloat($scope.newPayment.Amount),
        Description: $scope.newPayment.Description || null,
        Method: $scope.newPayment.Method,
      };

      $scope.savingPayment = true;

      $http
        .post(
          current_url + "/api-core/payments/create-payment-supplier",
          payload
        )
        .then(function () {
          alert("Thanh toán thành công!");

          // XÓA FORM NHẬP
          $scope.newPayment = { Amount: null, Method: "", Description: "" };

          // RELOAD LẠI TOÀN BỘ LỊCH SỬ THANH TOÁN → HIỂN THỊ NGAY TRONG MODAL!
          $http
            .post(current_url + "/api-core/payments/search-payment", {
              page: 1,
              pageSize: 100,
              ReceiptID: $scope.paymentReceipt.ReceiptID,
              CustomerID: null,
              SupplierID: null,
              SaleID: null,
              Method: "", // Đảm bảo backend chấp nhận
              FromDate: null,
              ToDate: null,
            })
            .then(function (res) {
              var newData = (res.data && res.data.data) || [];

              // GÁN LẠI DỮ LIỆU MỚI → BẢNG TỰ CẬP NHẬT NGAY LẬP TỨC!
              $scope.paymentHistory = newData;

              // BONUS: Nếu lần đầu thanh toán → cập nhật SupplierID (nếu chưa có)
              if (!$scope.paymentReceipt.SupplierID && newData.length > 0) {
                $scope.paymentReceipt.SupplierID = newData[0].supplierID;
              }
            })
            .catch(function () {
              alert("Thanh toán thành công nhưng không tải lại được lịch sử!");
            });

          // Cập nhật lại danh sách phiếu nhập (nếu bạn có cột "Đã thanh toán" ở bảng chính)
          $scope.LoadGoodReceipts();
        })
        .catch(function (err) {
          console.error("Lỗi thanh toán:", err);
          alert(
            "Thanh toán thất bại: " +
              (err.data?.message || "Lỗi không xác định")
          );
        })
        .finally(function () {
          $scope.savingPayment = false;
        });
    };

    // khởi tạo
    $scope.LoadGoodReceipts();
  }
);
