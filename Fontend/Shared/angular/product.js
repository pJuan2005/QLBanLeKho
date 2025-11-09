var app = angular.module("AppRetailPos");
app.controller("productCtrl", function ($scope, $http, $timeout, AuthService, PermissionService, $window) {
  $scope.currentUser = AuthService.getCurrentUser(); // lấy user 
  $scope.products = [];
  $scope.pager = { page: 1, size: 0, total: 0, pages: 1 };
  $scope.stats = { total: 0, instock: 0, outstock: 0 };
  $scope.searchProduct = "";
  $scope.searchSKU = "";

  $scope.newProduct = {
    ProductName: "",
    SKU: "",
    Barcode: "",
    CategoryID: null,
    Unit: "",
    MinStock: 0,
    Quantity: 0,
    VATRate: null,
    Status: "Active",
    Image: null

  };
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


  $scope.LoadProducts = function () {
  // chuẩn hóa SKU & tên sản phẩm để tránh lỗi null
  var skuExact = $scope.searchSKU ? $scope.searchSKU.trim() : "";
  var productName = $scope.searchProduct ? $scope.searchProduct.trim() : "";

  $http({
    method: "POST",
    url: current_url + "/api-core/product/search-product",
    data: {
      page: $scope.pager.page,
      pageSize: $scope.pager.size,
      ProductID: null,
      SKU: skuExact,
      Barcode: "",
      ProductName: productName,
      CategoryID: null,
      Status: ""
    },
  }).then(
    function (res) {
      var body = res.data || {};

      // ✅ Chuẩn hóa danh sách sản phẩm
      $scope.products = (body.data || body.Data || []).map(p => ({
      productID: p.ProductID || p.productID,
      productName: p.ProductName || p.productName,
      sku: p.SKU || p.sku,
      barcode: p.Barcode || p.barcode,
      categoryID: (p.CategoryID !== undefined && p.CategoryID !== null)
                    ? p.CategoryID
                    : (p.categoryID !== undefined ? p.categoryID : ""),
      unit: p.Unit || p.unit,
      minStock: p.MinStock || p.minStock || 0,
      quantity: p.Quantity || p.quantity || 0,
      vatRate: p.VATRate || p.vatRate || 0,
      status: p.Status || p.status || "Active",
      image: p.Image || p.image || ""
    }));


      // ✅ Tính tổng số bản ghi & phân trang
      $scope.pager.total = body.totalItems || body.TotalItems || 0;
      $scope.pager.pages = Math.max(1, Math.ceil($scope.pager.total / $scope.pager.size));

      // ✅ Tính thống kê tồn kho
      $scope.CalculateStats();
    },
    function (err) {
      console.error("❌ Lỗi LoadProducts:", err);
      $scope.products = [];
      $scope.pager.total = 0;
      $scope.pager.pages = 1;
    }
  );

};

  $scope.CalculateStats = function () {
  if (!$scope.products || $scope.products.length === 0) {
    $scope.stats = { total: 0, instock: 0, outstock: 0 };
    return;
  }

  // Tổng sản phẩm
  const total = $scope.products.length;

  // Đếm tồn kho
  let instock = 0;
  for (let p of $scope.products) {
    let qty = parseFloat(p.quantity || 0);
    if (qty > 0) instock++;
  }

  $scope.stats = {
    total: total,
    instock: instock,
    outstock: total - instock
  };
};

  // ====== THÊM MỚI SẢN PHẨM ======
$scope.add = function () {
  if ($scope.savingAdd) return;

  const formData = new FormData();
  formData.append("ProductName", $scope.newProduct.productName);
  formData.append("SKU", $scope.newProduct.sku);
  formData.append("Barcode", $scope.newProduct.barcode);
  formData.append("CategoryID", $scope.newProduct.categoryID);
  formData.append("Unit", $scope.newProduct.unit);
  formData.append("MinStock", $scope.newProduct.minStock);
  formData.append("Status", $scope.newProduct.status);
  formData.append("VATRate", $scope.newProduct.vatRate);
  formData.append("Quantity", $scope.newProduct.quantity);
  const imageInput = document.getElementById("imageInputAdd");
  if (imageInput.files.length > 0) {
    formData.append("imageFile", imageInput.files[0]);
  }


  $http.post(current_url + "/api-core/product/create-product", formData, {
    transformRequest: angular.identity,
    headers: { "Content-Type": undefined }, // để browser tự set multipart/form-data
  })
  .then(function (res) {
      $scope.savingAdd = false;
      alert("✅ Thêm sản phẩm thành công!");
      $scope.newProduct = {
        ProductName: "", SKU: "", Barcode: "", CategoryID: null,
        Unit: "", MinStock: 0, Quantity: 0, VATRate: null, Status: "Active",
      };
      $scope.pager.page = 1;
      $scope.LoadProducts();
  })
  .catch(function (err) {
      $scope.savingAdd = false;
      console.error("❌ Lỗi khi thêm sản phẩm:", err);
      alert("Thêm sản phẩm không thành công!");
  });
};

// ====== MỞ FORM EDIT VÀ ĐỔ DỮ LIỆU ======
$scope.edit = function (row) {
  $scope.editingProduct = angular.copy(row);
  if ($scope.editingProduct.categoryID != null) {
    $scope.editingProduct.categoryID = Number($scope.editingProduct.categoryID);
  }

  const openForm = function() {
    // force digest cycle để Angular render ng-options trước khi mở modal
    $timeout(() => {
      console.log("🧩 CategoryID hiện tại:", $scope.editingProduct.categoryID);
      console.log("🧩 Categories:", $scope.categories);
      openEditModal();
    }, 150);
  };

  if (!$scope.categories || $scope.categories.length === 0) {
    $scope.LoadCategories().finally(openForm);
  } else {
    openForm();
  }
};


// ====== CẬP NHẬT SẢN PHẨM ======
$scope.updateProduct = function () {
  if (!$scope.editingProduct || $scope.savingEdit) return;
  $scope.savingEdit = true;

  const id = $scope.editingProduct.productID;
  const formData = new FormData();
  formData.append("ProductID", id);
  formData.append("ProductName", $scope.editingProduct.productName);
  formData.append("SKU", $scope.editingProduct.sku);
  formData.append("Barcode", $scope.editingProduct.barcode);
  formData.append("CategoryID", $scope.editingProduct.categoryID);
  formData.append("Unit", $scope.editingProduct.unit);
  formData.append("MinStock", $scope.editingProduct.minStock);
  formData.append("Status", $scope.editingProduct.status);
  formData.append("VATRate", $scope.editingProduct.vatRate);
  formData.append("Quantity", $scope.editingProduct.quantity);
  const imageInput = document.getElementById("imageInputEdit");
  if (imageInput.files.length > 0) {
    formData.append("imageFile", imageInput.files[0]);
  }

  $http.put(current_url + "/api-core/product/update-product/" + id, formData, {
    transformRequest: angular.identity,
    headers: { "Content-Type": undefined },
  }).then(function (res) {
      $scope.savingEdit = false;
      alert("✅ Cập nhật sản phẩm thành công!");
      closeEditModal();
      $scope.editingProduct = null;
      $scope.LoadProducts();
  }, function (err) {
      $scope.savingEdit = false;
      console.error("❌ Lỗi khi cập nhật sản phẩm:", err);
      alert("Cập nhật sản phẩm không thành công!");
  });
};


$scope.previewImageAdd = function (input) {
  if (input.files && input.files[0]) {
    const reader = new FileReader();
    reader.onload = function (e) {
      $scope.$apply(() => $scope.newProduct.image = e.target.result);
    };
    reader.readAsDataURL(input.files[0]);
  }
};

$scope.previewImageEdit = function (input) {
  if (input.files && input.files[0]) {
    const reader = new FileReader();
    reader.onload = function (e) {
      $scope.$apply(() => $scope.editingProduct.image = e.target.result);
    };
    reader.readAsDataURL(input.files[0]);
  }
};


$scope.categories = [];
$scope.LoadCategories = function () {
  return $http({
    method: "POST",
    url: current_url + "/api-core/category/search",
    data: { page: 1, pageSize: 1000, CategoryName: "", vatExact: null, option: "" },
  }).then(function (res) {
    var body = res.data || {};
    var raw = body.data || body.Data || [];
    $scope.categories = raw.map(c => ({
      categoryID: Number(c.CategoryID || c.categoryID),
      categoryName: c.CategoryName || c.categoryName
    }));
  }).catch(function (err) {
    console.error("❌ Load categories error:", err);
    $scope.categories = [];
  })};


  // ================== DELETE PRODUCT ==================
$scope.showDelete = false;
$scope.deleting = null;
$scope.deletingBusy = false;

// Khi bấm nút 🗑 Delete trong bảng
$scope.remove = function (p) {
  $scope.deleting = angular.copy(p);
  $scope.showDelete = true;
};

// Bấm Cancel (đóng popup)
$scope.cancelDelete = function (e) {
  if (e) e.preventDefault();
  $scope.showDelete = false;
  $scope.deleting = null;
  $scope.deletingBusy = false;
};

// Khi click ra ngoài vùng modal → đóng
$scope.closeDeleteOnOverlay = function (event) {
  if (event.target.classList.contains("form-delete")) {
    $scope.cancelDelete(event);
  }
};

// ✅ Xác nhận xoá sản phẩm
$scope.confirmDelete = function ($event) {
  if ($event) $event.stopPropagation(); // 🚫 chặn click lan ra overlay
  if ($scope.deletingBusy) return; // ngăn double click
  if (!$scope.deleting || !$scope.deleting.productID) return;

  $scope.deletingBusy = true;
  const id = $scope.deleting.productID;

  console.log("🧩 confirmDelete() CALLED, deleting ID:", id);

  $http({
    method: "DELETE",
    url: current_url + "/api-core/product/delete-product/" + id,
  })
    .then(function (res) {
      alert("🗑 Xoá sản phẩm thành công!");
      $scope.cancelDelete();
      // chờ 300ms để backend cập nhật rồi reload
      $timeout(() => $scope.LoadProducts(), 300);
    })
    .catch(function (err) {
      console.error("❌ Lỗi khi xoá sản phẩm:", err);
      alert("Xoá sản phẩm không thành công!");
    })
    .finally(function () {
      $scope.deletingBusy = false;
    })};

  
  //tối ưu khi search
    var typingTimer;
    function triggerSearch() {
      $scope.pager.page = 1;
      $timeout.cancel(typingTimer);
      typingTimer = $timeout($scope.LoadProducts, 300);
    }
    $scope.$watch("searchProduct", triggerSearch);
    $scope.$watch("searchSKU", triggerSearch);

    // phân trang
    $scope.go = function (p) {
      if (p < 1 || p > $scope.pager.pages) return;
      $scope.pager.page = p;
      $scope.LoadProducts();
    };
    //thay đổi số bản ghi trên trang
    $scope.changeSize = function () {
      $scope.pager.page = 1;
      $scope.LoadProducts();
    };



  $scope.exportExcel = function () {
  if (!$scope.products || $scope.products.length === 0) {
    alert("⚠️ Không có dữ liệu để xuất!");
    return;
  }

  // 1️⃣ Chuẩn hóa dữ liệu (lọc các cột cần export)
  const data = $scope.products.map(p => ({
    ProductID: p.productID,
    ProductName: p.productName,
    SKU: p.sku,
    Barcode: p.barcode,
    CategoryID: p.categoryID,
    Unit: p.unit,
    MinStock: p.minStock,
    Quantity: p.quantity,
    VATRate: p.vatRate,
    Status: p.status
  }));

  // 2️⃣ Tạo worksheet và workbook
  const worksheet = XLSX.utils.json_to_sheet(data);
  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, "Products");

  // 3️⃣ Tạo style header (tuỳ chọn)
  const header = Object.keys(data[0]);
  const range = XLSX.utils.decode_range(worksheet["!ref"]);
  for (let C = range.s.c; C <= range.e.c; ++C) {
    const cell = worksheet[XLSX.utils.encode_cell({ r: 0, c: C })];
    if (cell) cell.s = { font: { bold: true } };
  }

  // 4️⃣ Xuất file
  const excelBuffer = XLSX.write(workbook, { bookType: "xlsx", type: "array" });
  const blob = new Blob([excelBuffer], {
    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  });
  saveAs(blob, "Products_" + new Date().toISOString().slice(0, 10) + ".xlsx");
};

// ====== IMPORT EXCEL ======

$scope.triggerImportFile = function () {
  // mở cửa sổ chọn file
  document.getElementById("fileImport").click();
};

$scope.handleImportFile = function (input) {
  const file = input.files[0];
  if (!file) {
    alert("⚠️ Vui lòng chọn file Excel!");
    return;
  }

  const reader = new FileReader();
  reader.onload = function (e) {
    const data = new Uint8Array(e.target.result);
    const workbook = XLSX.read(data, { type: "array" });
    const firstSheet = workbook.Sheets[workbook.SheetNames[0]];
    const rows = XLSX.utils.sheet_to_json(firstSheet, { defval: "" });

    if (!rows || rows.length === 0) {
      alert("⚠️ File không có dữ liệu!");
      return;
    }

    // 🔹 Lấy danh sách mã hiện có để kiểm tra trùng
    const existingIDs = new Set($scope.products.map(p => Number(p.productID)));
    const existingSKUs = new Set($scope.products.map(p => (p.sku || "").toUpperCase()));
    const existingBarcodes = new Set($scope.products.map(p => (p.barcode || "").toUpperCase()));

    // 🔹 Hàm tạo mã duy nhất (SKU, Barcode)
    function generateUniqueCode(prefix, usedSet, startNum, padLen = 3) {
      let num = startNum;
      let code = prefix + String(num).padStart(padLen, "0");
      while (usedSet.has(code.toUpperCase())) {
        num++;
        code = prefix + String(num).padStart(padLen, "0");
      }
      usedSet.add(code.toUpperCase());
      return code;
    }

    // 🔹 Sinh ProductID tiếp theo
    let nextId = ($scope.products.length > 0)
      ? Math.max(...$scope.products.map(p => Number(p.productID) || 0)) + 1
      : 1;

    // 🔹 Duyệt từng dòng Excel và gửi lên SQL
    let successCount = 0;
    let failCount = 0;

    async function importNextRow(index) {
      if (index >= rows.length) {
        // ✅ Hoàn tất
        $scope.$apply(() => {
          alert(`✅ Import hoàn tất! ${successCount} sản phẩm thêm thành công, ${failCount} sản phẩm lỗi.`);
          localStorage.setItem("products", JSON.stringify($scope.products));
          location.reload();
        });
        return;
      }

      const r = rows[index];
      while (existingIDs.has(nextId)) nextId++;
      const id = nextId++;
      existingIDs.add(id);

      const sku = generateUniqueCode("SKU", existingSKUs, index + 1, 3);
      const barcode = generateUniqueCode("BC", existingBarcodes, index + 1, 3);

      const product = {
        productID: id,
        productName: r.ProductName || "",
        sku: sku,
        barcode: barcode,
        categoryID: r.CategoryID || null,
        unit: r.Unit || "",
        minStock: r.MinStock || 0,
        quantity: r.Quantity || 0,
        vatRate: r.VATRate || 0,
        status: r.Status || "Active"
      };

      // 🔹 Gửi dữ liệu lên API create-product
      const formData = new FormData();
      formData.append("ProductName", product.productName);
      formData.append("SKU", product.sku);
      formData.append("Barcode", product.barcode);
      formData.append("CategoryID", product.categoryID);
      formData.append("Unit", product.unit);
      formData.append("MinStock", product.minStock);
      formData.append("Status", product.status);
      formData.append("VATRate", product.vatRate);
      formData.append("Quantity", product.quantity);

      try {
        const res = await $http.post(current_url + "/api-core/product/create-product", formData, {
          transformRequest: angular.identity,
          headers: { "Content-Type": undefined },
        });

        console.log(`✅ [${index + 1}/${rows.length}] Đã lưu: ${product.productName}`);
        successCount++;
        $scope.products.push(product);
      } catch (err) {
        console.error(`❌ [${index + 1}] Lỗi khi lưu sản phẩm:`, err);
        failCount++;
      }

      // Gọi tiếp sản phẩm kế tiếp
      importNextRow(index + 1);
    }

    // 🔹 Bắt đầu import tuần tự
    if (confirm("Bạn có chắc chắn muốn import và lưu tất cả sản phẩm vào SQL?")) {
      importNextRow(0);
    }

    input.value = "";
  };

  reader.readAsArrayBuffer(file);
};

// ========== IMAGE MODAL VIEWER ==========
$scope.showImageModal = false;
$scope.selectedImage = null;

// Mở modal xem ảnh
$scope.openImageModal = function (imgUrl) {
  $scope.selectedImage = imgUrl;
  $scope.showImageModal = true;
};

// Đóng modal khi click ra ngoài
$scope.closeImageModal = function (event) {
  if (event.target.classList.contains('image-viewer')) {
    $scope.showImageModal = false;
    $scope.selectedImage = null;
  }
};

  $scope.LoadCategories();
  $scope.LoadProducts();
});





