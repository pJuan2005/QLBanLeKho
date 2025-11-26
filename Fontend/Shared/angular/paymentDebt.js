// paymentDebt.js
var app = angular.module("AppRetailPos");

app.controller(
  "paymentCtrl",
  function ($scope, $http, AuthService, PermissionService, $window) {
    // ==========================================================
    // 0. AUTH & MENU
    // ==========================================================
    $scope.currentUser = AuthService.getCurrentUser();
    if (!$scope.currentUser) {
      $window.location.href = "../AuthFE/login.html";
      return;
    }

    $scope.canShow = function (key) {
      return PermissionService.canShow(key);
    };

    // Helper format tiền VND
    $scope.formatVnd = function (n) {
      if (n == null) return "0 ₫";
      return (
        Number(n).toLocaleString("vi-VN", { maximumFractionDigits: 0 }) + " ₫"
      );
    };

    // ==========================================================
    // 1. STATE CHUNG
    // ==========================================================
    $scope.mode = "customer"; // 'customer' | 'supplier'

    // bộ lọc search text
    $scope.searchCustomerText = "";
    $scope.searchSupplierText = "";

    // filter theo status + date range (dùng chung)
    $scope.filter = {
      status: "", // '', 'unpaid', 'partial'
      fromDate: null,
      toDate: null,
    };

    // danh sách hoá đơn / phiếu nhập còn nợ
    $scope.arInvoices = []; // từ sp_ar_open_invoices
    $scope.apBills = []; // từ sp_ap_open_bills

    // tổng cho 2 card
    $scope.totalCustomerDebt = 0; // sum Remaining của AR
    $scope.totalSupplierPayable = 0; // sum Remaining của AP

    // PAGER dùng chung
    $scope.pager = {
      page: 1,
      size: 10,
      total: 0,
      pages: 1,
    };

    // STATE SETTLED
    $scope.settledThisMonthCustomer = 0;
    $scope.settledThisMonthSupplier = 0;

    // STATE FORM (OVERLAY)
    $scope.showOverlay = false; // bật / tắt lớp mờ
    $scope.activeForm = null; // 'customer' | 'supplier'
    $scope.formMode = null; // 'view' | 'pay'

    $scope.selectedInvoice = null; // hóa đơn AR đang xem
    $scope.selectedBill = null; // phiếu AP đang xem

    // model form payment
    $scope.customerPayment = {
      amount: null,
      paymentDate: null,
      method: "Cash",
      description: "",
    };

    $scope.supplierPayment = {
      amount: null,
      paymentDate: null,
      method: "Cash",
      description: "",
    };

    // ==========================================================
    // 2. HELPER BUILD REQUEST (cho AR/AP open list)
    // ==========================================================
    $scope.buildRequest = function () {
      return {
        page: $scope.pager.page,
        pageSize: $scope.pager.size,
        search:
          $scope.mode === "customer"
            ? $scope.searchCustomerText || ""
            : $scope.searchSupplierText || "",
        fromDate: $scope.filter.fromDate,
        toDate: $scope.filter.toDate,
        // hiện tại BE chưa nhận status
      };
    };

    // ==========================================================
    // 3. ĐỔI TAB
    // ==========================================================
    $scope.setMode = function (m) {
      if ($scope.mode === m) return;
      $scope.mode = m;

      // reset filter khi đổi tab
      $scope.pager.page = 1;
      $scope.filter.status = "";
      $scope.filter.fromDate = null;
      $scope.filter.toDate = null;

      $scope.reload();
    };

    // ==========================================================
    // 4. LOAD AR – HÓA ĐƠN BÁN CÒN NỢ
    // ==========================================================
    $scope.loadArOpenInvoices = function () {
      var req = $scope.buildRequest();

      $http
        .post(current_url + "/api-core/payments/ar-open-invoices", req)
        .then(function (resp) {
          var res = resp.data || {};
          var list = res.data || res.Data || [];

          // Gắn status tính từ paidAmount/remaining
          list.forEach(function (x) {
            if (!x.paidAmount || x.paidAmount === 0) {
              x._status = "unpaid";
            } else {
              x._status = "partial";
            }
          });

          $scope.arInvoices = list;

          // paging
          $scope.pager.total = res.totalItems || res.TotalItems || 0;
          $scope.pager.pages = Math.max(
            1,
            Math.ceil($scope.pager.total / $scope.pager.size)
          );

          // total debts = sum remaining
          var sum = 0;
          list.forEach(function (x) {
            sum += x.remaining || 0;
          });
          $scope.totalCustomerDebt = sum;
        })
        .catch(function (err) {
          console.error("loadArOpenInvoices error", err);
        });
    };

    // Tổng tiền đã thu trong tháng hiện tại (Customer)
    $scope.loadCustomerSettledThisMonth = function () {
      var now = new Date();
      var firstDay = new Date(now.getFullYear(), now.getMonth(), 1);

      var req = {
        page: 1,
        pageSize: 1000, // tạm đủ lớn
        customerID: null,
        supplierID: null,
        saleID: null,
        receiptID: null,
        method: "", // tránh lỗi "Method field is required"
        fromDate: firstDay,
        toDate: now,
      };

      $http
        .post(current_url + "/api-core/payments/search-payment", req)
        .then(function (resp) {
          var res = resp.data || {};
          var list = res.data || res.Data || [];

          var sum = 0;
          list.forEach(function (p) {
            // chỉ tính payment cho customer
            if (p.customerID != null || p.CustomerID != null) {
              sum += p.amount || p.Amount || 0;
            }
          });

          $scope.settledThisMonthCustomer = sum;
        })
        .catch(function (err) {
          console.error("loadCustomerSettledThisMonth error", err);
        });
    };

    // ==========================================================
    // 5. LOAD AP – PHIẾU NHẬP CÒN NỢ
    // ==========================================================
    $scope.loadApOpenBills = function () {
      var req = $scope.buildRequest();

      $http
        .post(current_url + "/api-core/payments/ap-open-bills", req)
        .then(function (resp) {
          var res = resp.data || {};
          var list = res.data || res.Data || [];

          list.forEach(function (x) {
            if (!x.paidAmount || x.paidAmount === 0) {
              x._status = "unpaid";
            } else {
              x._status = "partial";
            }
          });

          $scope.apBills = list;

          // paging
          $scope.pager.total = res.totalItems || res.TotalItems || 0;
          $scope.pager.pages = Math.max(
            1,
            Math.ceil($scope.pager.total / $scope.pager.size)
          );

          // total payables = sum remaining
          var sum = 0;
          list.forEach(function (x) {
            sum += x.remaining || 0;
          });
          $scope.totalSupplierPayable = sum;
        })
        .catch(function (err) {
          console.error("loadApOpenBills error", err);
        });
    };

    // Tổng tiền đã trả trong tháng hiện tại (Supplier)
    $scope.loadSupplierSettledThisMonth = function () {
      var now = new Date();
      var firstDay = new Date(now.getFullYear(), now.getMonth(), 1);

      var req = {
        page: 1,
        pageSize: 1000,
        customerID: null,
        supplierID: null,
        saleID: null,
        receiptID: null,
        method: "",
        fromDate: firstDay,
        toDate: now,
      };

      $http
        .post(current_url + "/api-core/payments/search-payment", req)
        .then(function (resp) {
          var res = resp.data || {};
          var list = res.data || res.Data || [];

          var sum = 0;
          list.forEach(function (p) {
            // chỉ tính payment cho supplier
            if (p.supplierID != null || p.SupplierID != null) {
              sum += p.amount || p.Amount || 0;
            }
          });

          $scope.settledThisMonthSupplier = sum;
        })
        .catch(function (err) {
          console.error("loadSupplierSettledThisMonth error", err);
        });
    };

    // ==========================================================
    // 6. FILTER THEO STATUS (client-side)
    // ==========================================================
    $scope.filterByStatus = function (row) {
      if (!$scope.filter.status) return true; // All

      if ($scope.filter.status === "unpaid") {
        return !row.paidAmount || row.paidAmount === 0;
      }

      if ($scope.filter.status === "partial") {
        return (
          row.paidAmount > 0 && (row.remaining == null || row.remaining > 0)
        );
      }

      if ($scope.filter.status === "paid") {
        return row.remaining === 0;
      }

      return true;
    };

    $scope.onStatusChange = function () {
      // hiện tại filter theo status chỉ client-side,
      // nhưng ta vẫn reload để list/pager sync
      $scope.pager.page = 1;
      $scope.reload();
    };

    // ==========================================================
    // 7. SEARCH + DATE
    // ==========================================================
    $scope.searchCustomers = function () {
      $scope.pager.page = 1;
      $scope.reload();
    };

    $scope.searchSuppliers = function () {
      $scope.pager.page = 1;
      $scope.reload();
    };

    // Cho đúng với HTML: ng-keypress="... && searchArInvoices()"
    $scope.searchArInvoices = function () {
      $scope.pager.page = 1;
      $scope.reload();
    };

    // Cho đúng với HTML: ng-keypress="... && searchApBills()"
    $scope.searchApBills = function () {
      $scope.pager.page = 1;
      $scope.reload();
    };

    $scope.onDateChange = function () {
      $scope.pager.page = 1;
      $scope.reload();
    };

    // ==========================================================
    // 8. PAGER
    // ==========================================================
    $scope.reload = function () {
      if ($scope.mode === "customer") {
        $scope.loadArOpenInvoices();
      } else {
        $scope.loadApOpenBills();
      }
    };

    $scope.changeSize = function () {
      $scope.pager.page = 1;
      $scope.reload();
    };

    $scope.go = function (p) {
      if (p < 1 || p > $scope.pager.pages) return;
      $scope.pager.page = p;
      $scope.reload();
    };

    // ==========================================================
    // 9. FORM: VIEW / PAY CUSTOMER
    // ==========================================================
    $scope.openInvoiceDetail = function (inv) {
      $scope.selectedInvoice = inv;
      $scope.formMode = "view";
      $scope.activeForm = "customer";
      $scope.showOverlay = true;
    };

    $scope.openCustomerPay = function (inv) {
      $scope.selectedInvoice = inv;
      $scope.formMode = "pay";
      $scope.activeForm = "customer";
      $scope.showOverlay = true;

      // reset model form, gợi ý amount = remaining
      $scope.customerPayment = {
        amount: inv.remaining || 0,
        paymentDate: new Date(), // Angular sẽ serialize thành ISO
        method: "Cash",
        description: "",
      };
    };

    // ==========================================================
    // 10. FORM: VIEW / PAY SUPPLIER
    // ==========================================================
    $scope.openBillDetail = function (bill) {
      $scope.selectedBill = bill;
      $scope.formMode = "view";
      $scope.activeForm = "supplier";
      $scope.showOverlay = true;
    };

    $scope.openSupplierPay = function (bill) {
      $scope.selectedBill = bill;
      $scope.formMode = "pay";
      $scope.activeForm = "supplier";
      $scope.showOverlay = true;

      $scope.supplierPayment = {
        amount: bill.remaining || 0,
        paymentDate: new Date(),
        method: "Cash",
        description: "",
      };
    };

    // ==========================================================
    // 11. ĐÓNG FORM
    // ==========================================================
    $scope.closeOverlay = function () {
      $scope.showOverlay = false;
      $scope.activeForm = null;
      $scope.formMode = null;
      $scope.selectedInvoice = null;
      $scope.selectedBill = null;
    };

    // ==========================================================
    // 12. LƯU PAYMENT CUSTOMER
    // ==========================================================
    $scope.saveCustomerPayment = function () {
      if (!$scope.selectedInvoice) return;

      var p = $scope.customerPayment;

      if (!p.amount || !p.paymentDate || !p.method) {
        alert("Please fill Amount, Payment Date and Method.");
        return;
      }

      var payload = {
        customerID:
          $scope.selectedInvoice.customerID ||
          $scope.selectedInvoice.CustomerID,
        saleID: $scope.selectedInvoice.saleID || $scope.selectedInvoice.SaleID,
        amount: p.amount,
        paymentDate: p.paymentDate,
        method: p.method,
        description: p.description,
      };

      $http
        .post(
          current_url + "/api-core/payments/create-payment-customer",
          payload
        )
        .then(function () {
          // reload lại dữ liệu
          $scope.closeOverlay();
          $scope.reload();
          $scope.loadCustomerSettledThisMonth();
        })
        .catch(function (err) {
          console.error("saveCustomerPayment error", err);
          alert("Cannot save payment for customer.");
        });
    };

    // ==========================================================
    // 13. LƯU PAYMENT SUPPLIER
    // ==========================================================
    $scope.saveSupplierPayment = function () {
      if (!$scope.selectedBill) return;

      var p = $scope.supplierPayment;

      if (!p.amount || !p.paymentDate || !p.method) {
        alert("Please fill Amount, Payment Date and Method.");
        return;
      }

      var payload = {
        supplierID:
          $scope.selectedBill.supplierID || $scope.selectedBill.SupplierID,
        receiptID:
          $scope.selectedBill.receiptID || $scope.selectedBill.ReceiptID,
        amount: p.amount,
        paymentDate: p.paymentDate,
        method: p.method,
        description: p.description,
      };

      $http
        .post(
          current_url + "/api-core/payments/create-payment-supplier",
          payload
        )
        .then(function () {
          $scope.closeOverlay();
          $scope.reload();
          $scope.loadSupplierSettledThisMonth();
        })
        .catch(function (err) {
          console.error("saveSupplierPayment error", err);
          alert("Cannot save payment for supplier.");
        });
    };

    // ==========================================================
    // 14. INIT
    // ==========================================================
    $scope.reload();
    $scope.loadCustomerSettledThisMonth();
    $scope.loadSupplierSettledThisMonth();
  }
);
