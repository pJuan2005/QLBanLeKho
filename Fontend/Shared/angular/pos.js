var app = angular.module("AppRetailPos");

app.controller(
  "posCtrl",
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
    // 1. STATE CUSTOMER
    // ==========================================================
    $scope.phoneInput = "";
    // { CustomerID, CustomerName, CustomerPhone, DebtLimit, CurrentDebt, IsOverLimit }
    $scope.selectedCustomer = null;
    $scope.hasSearched = false;

    // Modal Add Customer
    $scope.showAdd = false;
    $scope.savingAdd = false;
    $scope.newCustomer = {
      CustomerName: "",
      CustomerPhone: "",
      CustomerEmail: "",
      CustomerAddress: "",
    };

    // ---------- 1.1 Search customer theo phone ----------
    $scope.searchCustomer = function () {
      if (!$scope.phoneInput) return;

      var body = {
        pageIndex: 1,
        pageSize: 1,
        search: $scope.phoneInput.trim(),
      };

      $http
        .post(current_url + "/api-core/ar_customer/search-customers", body)
        .then(function (res) {
          $scope.hasSearched = true;
          var data = res.data || {};

          var total = data.totalItems || data.TotalItems || 0;
          var list = data.data || data.Data || [];

          if (!total || !list || list.length === 0) {
            $scope.selectedCustomer = null;
            return;
          }

          var c = list[0];

          $scope.selectedCustomer = {
            CustomerID: c.customerID || c.CustomerID,
            CustomerName: c.customerName || c.CustomerName,
            CustomerPhone: c.phone || c.Phone || $scope.phoneInput,
            DebtLimit: c.debtLimit || c.DebtLimit || 0,
            CurrentDebt: c.currentDebt || c.CurrentDebt || 0,
            IsOverLimit: !!(c.isOverLimit || c.IsOverLimit),
          };
        })
        .catch(function (err) {
          console.error("Error search customer", err);
          $scope.selectedCustomer = null;
          $scope.hasSearched = true;
        });
    };

    // Chip trạng thái khách
    $scope.getCustomerChipText = function () {
      if (!$scope.selectedCustomer) return "";

      var c = $scope.selectedCustomer;

      if (!c.DebtLimit || c.DebtLimit <= 0) {
        return "Khách thường – Không được nợ";
      }

      return (
        "Loyal customer – Limit " +
        $scope.formatVnd(c.DebtLimit) +
        " – Debt " +
        $scope.formatVnd(c.CurrentDebt)
      );
    };

    // ---------- 1.2 Open / close Add Customer modal ----------
    $scope.openAddCustomer = function () {
      $scope.newCustomer = {
        CustomerName: "",
        CustomerPhone: $scope.phoneInput || "",
        CustomerEmail: "",
        CustomerAddress: "",
      };
      $scope.showAdd = true;
    };

    $scope.closeAddOnOverlay = function (event) {
      if (event.target === event.currentTarget) {
        $scope.cancelAdd();
      }
    };

    $scope.cancelAdd = function () {
      $scope.showAdd = false;
      $scope.savingAdd = false;
    };

    // ---------- 1.3 Submit Add Customer ----------
    $scope.add = function () {
      if (
        !$scope.newCustomer.CustomerName ||
        !$scope.newCustomer.CustomerPhone
      ) {
        return;
      }

      $scope.savingAdd = true;

      var payload = {
        CustomerName: $scope.newCustomer.CustomerName,
        Phone: $scope.newCustomer.CustomerPhone,
        Email: $scope.newCustomer.CustomerEmail || "",
        Address: $scope.newCustomer.CustomerAddress || "",
        DebtLimit: 0, // khách mới trên POS luôn không được nợ
      };

      $http
        .post(current_url + "/api-core/customer/create-customer", payload)
        .then(function (res) {
          var c = res.data || payload;

          $scope.selectedCustomer = {
            CustomerID: c.customerID || c.CustomerID,
            CustomerName: c.customerName || c.CustomerName,
            CustomerPhone: c.phone || c.Phone || payload.Phone,
            DebtLimit: c.debtLimit || c.DebtLimit || 0,
            CurrentDebt: 0,
            IsOverLimit: false,
          };

          $scope.phoneInput = $scope.selectedCustomer.CustomerPhone;
          $scope.hasSearched = true;
          $scope.showAdd = false;
        })
        .catch(function (err) {
          console.error("Error create customer", err);
          alert("Tạo khách hàng thất bại, vui lòng thử lại.");
        })
        .finally(function () {
          $scope.savingAdd = false;
        });
    };

    // ==========================================================
    // 2. STATE PRODUCTS & CART
    // ==========================================================

    $scope.productSearch = "";

    $scope.products = [];
    $scope.productPager = {
      page: 1,
      pageSize: 500,
      totalItems: 0,
      totalPages: 1,
    };

    // cart: item = { ProductID, ProductName, UnitPrice, VATRate, Quantity, LineTotal, LineVat }
    $scope.cartItems = [];
    $scope.subtotal = 0;
    $scope.vatTotal = 0;
    $scope.orderTotal = 0;

    // ---------- 2.1 Load products ----------
    $scope.loadProducts = function (page) {
      page = page || 1;

      var keyword = ($scope.productSearch || "").trim();

      var body = {
        page: page,
        pageSize: $scope.productPager.pageSize,
        productID: null,
        sku: "",
        barcode: "",
        productName: "",
        categoryID: null,
        status: "",
        minPrice: null,
        maxPrice: null,
      };

      if (keyword) {
        // Nếu bắt đầu bằng "SKU" thì vẫn coi là SKU
        if (/^SKU/i.test(keyword)) {
          body.sku = keyword;

          // Nếu toàn là số (không ký tự chữ nào) thì là barcode
        } else if (/^\d+$/.test(keyword)) {
          body.barcode = keyword;

          // Còn lại coi là tìm theo tên
        } else {
          body.productName = keyword;
        }
      }

      $http
        .post(current_url + "/api-core/product/search-product", body)
        .then(function (res) {
          var data = res.data || {};

          var total = data.totalItems || data.TotalItems || 0;
          var list = data.data || data.Data || [];

          $scope.products = list || [];
          $scope.productPager.page = page;
          $scope.productPager.totalItems = total;
          $scope.productPager.totalPages = total
            ? Math.ceil(total / $scope.productPager.pageSize)
            : 1;
        })
        .catch(function (err) {
          console.error("Error load products", err);
        });
    };

    // gọi 1 lần khi mở POS
    $scope.loadProducts(1);

    // ---------- 2.2 Cart helpers ----------
    function recalcCart() {
      var subtotal = 0;
      var vat = 0;

      $scope.cartItems.forEach(function (item) {
        var price = Number(item.UnitPrice) || 0;
        var qty = Number(item.Quantity) || 0;
        var vatRate = Number(item.VATRate) || 0;

        var base = price * qty;
        var lineVat = base * (vatRate / 100);

        item.LineTotal = base;
        item.LineVat = lineVat;

        subtotal += base;
        vat += lineVat;
      });

      $scope.subtotal = subtotal;
      $scope.vatTotal = vat;

      // Làm tròn tổng tiền về số nguyên VND
      var total = subtotal + vat;
      $scope.orderTotal = Math.round(total);
    }

    // ---------- 2.3 Add product to cart ----------
    $scope.addToCart = function (p) {
      if (!p) return;

      var id = p.productID || p.ProductID;

      var existing = $scope.cartItems.find(function (x) {
        return x.ProductID === id;
      });

      if (existing) {
        existing.Quantity += 1;
      } else {
        $scope.cartItems.push({
          ProductID: id,
          ProductName: p.productName || p.ProductName,
          UnitPrice: p.unitPrice || p.UnitPrice || 0,
          VATRate: p.vatRate || p.VATRate || 0,
          Quantity: 1,
          LineTotal: 0,
          LineVat: 0,
        });
      }

      recalcCart();
    };

    // ---------- 2.4 Update quantity / remove ----------
    $scope.increaseQty = function (item, $event) {
      if ($event) $event.stopPropagation();
      item.Quantity += 1;
      recalcCart();
    };

    $scope.decreaseQty = function (item, $event) {
      if ($event) $event.stopPropagation();
      if (item.Quantity > 1) {
        item.Quantity -= 1;
      } else {
        var idx = $scope.cartItems.indexOf(item);
        if (idx >= 0) $scope.cartItems.splice(idx, 1);
      }
      recalcCart();
    };

    $scope.removeItem = function (item, $event) {
      if ($event) $event.stopPropagation();
      var idx = $scope.cartItems.indexOf(item);
      if (idx >= 0) $scope.cartItems.splice(idx, 1);
      recalcCart();
    };

    // ==========================================================
    // 3. PAYMENT & SUCCESS POPUP
    // ==========================================================
    $scope.payment = {
      customerPays: null,
      method: "Cash",
      remainingDebt: 0,
    };

    $scope.showPaymentSuccess = false;

    $scope.successData = {
      orderId: "",
      dateTime: null,
      cashier: "",
      customerName: "",
      customerPhone: "",
      beforeDebt: 0,
      prepay: 0,
      remainingDebt: 0,
      debtLimit: 0,
      orderTotal: 0,
      method: "",
      items: [],
    };

    // Hàm dùng chung để tính lại nợ còn lại
    function calcRemainingDebt() {
      var pay = Number($scope.payment.customerPays) || 0;
      var total = Number($scope.orderTotal) || 0; // giờ đã là số nguyên

      var beforeDebt = 0;
      var debtLimit = 0;
      if ($scope.selectedCustomer) {
        beforeDebt = Number($scope.selectedCustomer.CurrentDebt) || 0;
        debtLimit = Number($scope.selectedCustomer.DebtLimit) || 0;
      }

      // nợ phát sinh = max(0, total - pay)
      var orderDebt = Math.max(0, total - pay);

      // Nếu chỉ lệch < 1đ (do làm tròn) thì coi như 0
      if (orderDebt < 1) orderDebt = 0;

      var newDebt = beforeDebt + orderDebt;

      $scope.payment.remainingDebt = newDebt;

      return {
        pay: pay,
        total: total,
        beforeDebt: beforeDebt,
        debtLimit: debtLimit,
        orderDebt: orderDebt,
        newDebt: newDebt,
      };
    }

    // Recalc nợ khi người dùng nhập tiền
    $scope.recalcRemainingDebt = function () {
      calcRemainingDebt();
    };

    // Cờ chống double-click
    $scope.isPaying = false;

    // ---------- 3.1 Hoàn tất thanh toán ----------
    $scope.completePayment = function () {
      if ($scope.isPaying) return;

      // ===== 0. VALIDATE CƠ BẢN =====
      if ($scope.cartItems.length === 0) {
        alert("Giỏ hàng đang trống.");
        return;
      }

      if (!$scope.selectedCustomer) {
        alert("Vui lòng chọn hoặc thêm khách hàng trước khi thanh toán.");
        return;
      }

      if ($scope.payment.customerPays == null) {
        alert("Vui lòng nhập số tiền khách thanh toán.");
        return;
      }

      // ===== 1. TÍNH NỢ, ÁP DỤNG RULE =====
      var info = calcRemainingDebt();
      var pay = info.pay;
      var total = info.total;
      var beforeDebt = info.beforeDebt;
      var debtLimit = info.debtLimit;
      var orderDebt = info.orderDebt;
      var newDebt = info.newDebt;

      // 1.1 KHÁCH KHÔNG ĐƯỢC NỢ → bắt buộc trả đủ
      if (debtLimit <= 0 && orderDebt > 0) {
        alert("Khách này không được nợ, vui lòng yêu cầu thanh toán đủ.");
        return;
      }

      // 1.2 KHÁCH ĐƯỢC NỢ → nợ mới không vượt hạn mức
      if (debtLimit > 0 && newDebt > debtLimit) {
        alert(
          "Thanh toán này sẽ vượt quá hạn mức nợ cho phép. Vui lòng giảm số nợ."
        );
        return;
      }

      // ===== 2. BUILD DTO GỬI BACKEND (PosOrderDto) =====
      var dto = {
        customerId: $scope.selectedCustomer.CustomerID,
        // userId sẽ được BE gán từ claim UserId trong token; FE gửi cũng không sao
        userId: $scope.currentUser.userId || $scope.currentUser.UserID || 0,
        items: $scope.cartItems.map(function (it) {
          return {
            saleID: 0,
            productID: it.ProductID,
            productName: it.ProductName,
            quantity: it.Quantity,
            unitPrice: it.UnitPrice,
            discount: 0,
          };
        }),
        prepay: pay,
        paymentMethod: $scope.payment.method,
        paymentDate: new Date(),
        clientTotal: total,
      };

      $scope.isPaying = true;

      // ===== 3. GỌI API TẠO ĐƠN BÁN HÀNG =====
      $http
        .post(current_url + "/api-core/sales/create-from-pos", dto)
        .then(function (res) {
          var r = res.data || {};
          var sale = r.sale || r.Sale || {};

          var finalBeforeDebt =
            r.beforeDebt != null ? r.beforeDebt : r.BeforeDebt ?? beforeDebt;
          var finalNewDebt =
            r.newRemainingDebt != null
              ? r.newRemainingDebt
              : r.NewRemainingDebt ?? newDebt;

          var finalTotal =
            sale.totalAmount != null
              ? sale.totalAmount
              : sale.TotalAmount ?? total;

          var saleDate = sale.saleDate || sale.SaleDate || new Date();
          var saleId = sale.saleID || sale.SaleID || 0;

          // Fill data cho popup thành công
          $scope.successData = {
            orderId: saleId ? "S-" + saleId : "",
            dateTime: saleDate,
            cashier: $scope.currentUser.fullname || "Cashier",

            customerName: $scope.selectedCustomer.CustomerName,
            customerPhone: $scope.selectedCustomer.CustomerPhone,

            beforeDebt: finalBeforeDebt,
            prepay: pay,
            remainingDebt: finalNewDebt,
            debtLimit: debtLimit,

            orderTotal: finalTotal,
            method: $scope.payment.method,

            items: angular.copy($scope.cartItems),
          };

          // cập nhật nợ hiện tại của khách trên FE
          $scope.selectedCustomer.CurrentDebt = finalNewDebt;
          $scope.payment.remainingDebt = finalNewDebt;

          $scope.showPaymentSuccess = true;
        })
        .catch(function (err) {
          console.error("Lỗi thanh toán POS", err);
          var msg =
            (err.data && err.data.message) ||
            (err.data && err.data.Message) ||
            "Thanh toán thất bại.";
          alert(msg);
        })
        .finally(function () {
          $scope.isPaying = false;
        });
    };

    // ---------- 3.2 Bắt đầu đơn mới ----------
    $scope.startNewSale = function () {
      $scope.cartItems = [];
      recalcCart();

      $scope.selectedCustomer = null;
      $scope.phoneInput = "";
      $scope.hasSearched = false;

      $scope.payment = {
        customerPays: null,
        method: "Cash",
        remainingDebt: 0,
      };

      $scope.showPaymentSuccess = false;
    };
    // ---------- 3.3 In hoá đơn ----------
    $scope.printInvoice = function ($event) {
      if ($event) $event.preventDefault();
      if (!$scope.showPaymentSuccess) {
        alert("Vui lòng hoàn tất thanh toán trước khi in hoá đơn.");
        return;
      }

      // Chuẩn bị data in hoá đơn
      var data = angular.copy($scope.successData);

      // Tính tiền thừa (nếu có)
      var orderTotal = Number(data.orderTotal) || 0;
      var prepay = Number(data.prepay) || 0;
      data.changeToReturn = Math.max(0, prepay - orderTotal);

      // Lưu vào localStorage
      try {
        localStorage.setItem("RetailPro_LastInvoice", JSON.stringify(data));
      } catch (e) {
        console.error("Không thể lưu invoice vào localStorage", e);
      }

      // Điều hướng sang trang in
      window.location.href = "../AdminFE/printInvoice.html";
    };
  }
);
