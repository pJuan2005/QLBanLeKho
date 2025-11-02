// 🧭 Khai báo phần tử cần dùng
const addBtn = document.getElementById("addBtn");


let editingProductId = null;

// 🧩 API URL
const API_BASE = `${current_url}/api-core/product`;

const tableBody = document.querySelector(".product-table tbody");
const totalElement = document.getElementById("totalProducts");

// 🔹 1. Load danh sách sản phẩm
async function loadProducts() {
    tableBody.innerHTML = "<tr><td colspan='12'>Đang tải dữ liệu...</td></tr>";
    try {
        const body = {
            page: 1,
            pageSize: 50,
            productID: null,
            sku: "",
            barcode: "",
            productName: "",
            categoryID: null,
            status: ""
        };
        

        const response = await fetch(`${API_BASE}/search-product`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body),
        });

        if (!response.ok) throw new Error("Lỗi tải danh sách sản phẩm");
        const result = await response.json();
        renderProducts(result.data);
        
        // ✅ Hiển thị tổng số sản phẩm
        if (totalElement) {
            totalElement.textContent = result.totalItems ?? result.data?.length ?? 0;
        }



        if (lowStockElement && outOfStockElement && inStockElement) {
            const lowStockCount = result.data.filter(p => p.quantity < p.minStock).length;
            const outOfStockCount = result.data.filter(p => p.quantity === 0).length;
            const inStockECount = result.data.filter(p => p.quantity > p.minStock).length;

            lowStockElement.textContent = lowStockCount;
            outOfStockElement.textContent = outOfStockCount;
            inStockElement.textContent = inStockECount;
        }




    } catch (error) {
        console.error("❌ Error:", error);
        tableBody.innerHTML = "<tr><td colspan='12' style='color:red;'>Không thể tải dữ liệu!</td></tr>";
    }
}

// 🔹 2. Render danh sách
function renderProducts(products) {
    if (!products || products.length === 0) {
        tableBody.innerHTML = "<tr><td colspan='12'>Không có sản phẩm nào</td></tr>";
        return;
    }

    tableBody.innerHTML = products.map(p => `
        <tr>
            <td><span class="all ">${p.productID}</td>
            <td><span class="all ">${p.sku || ""}</td>
            <td><span class="all ">${p.barcode || ""}</td>
            <td><span class="all ">${p.productName || ""}</td>
            <td><span class="all ">${p.categoryID ?? ""}</td>
            <td><span class="all ">${p.unit || ""}</td>
            <td><span class="all ">${p.minStock}</td>
            <td><span class="all "><span class="stock ${p.quantity <= p.minStock ? "low" : "good"}">${p.quantity}</span></td>
            <td><span class="all ">${p.vatRate ?? 0}</td>
            <td><span class="all "><span class="status ">${p.status}</span></td>
            <td>${p.image ? `<img src="${p.image}" 
     alt="${p.productName || 'Product Image'}" width="50">
` : ""}</td>
            <td class="actions">
                <button class="icon-btn view" title="Xem">&#128065;</button>
                <button class="icon-btn edit" title="Sửa">&#9998;</button>
                <button class="icon-btn delete" title="Xóa" data-id="${p.productID}">&#128465;</button>
            </td>
        </tr>
    `).join("");

    attachEventListeners();
}

// 🔹 3. Gắn sự kiện sau render
function attachEventListeners() {
    document.querySelectorAll('.icon-btn.view').forEach(btn => {
        btn.addEventListener('click', e => {
            const img = e.target.closest('tr').querySelector('img');
            if (img) showImageModal(img.src);
        });
    });

    

    document.querySelectorAll('.icon-btn.delete').forEach(btn => {
        btn.addEventListener('click', async e => {
            const id = e.target.dataset.id;
            if (confirm(`Bạn có chắc chắn muốn xóa sản phẩm ID: ${id}?`)) {
                await deleteProduct(id);
            }
        });
    });


    document.querySelectorAll('.icon-btn.edit').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const row = e.target.closest('tr');
            const id = row.querySelector('td').innerText; // cột đầu tiên là ProductID
            window.location.href = `update product.html?id=${id}`;
        });
    });
}

// 🔹 4. Xóa sản phẩm
async function deleteProduct(id) {
    try {
        const res = await fetch(`${API_BASE}/delete-product/${id}`, { method: "DELETE" });
        if (!res.ok) throw new Error("Xóa sản phẩm thất bại");
        alert("✅ Đã xóa sản phẩm thành công!");
        loadProducts();
    } catch {
        alert("❌ Lỗi khi xóa sản phẩm!");
    }
}

// 🔹 5. Modal xem ảnh
function showImageModal(src) {
    const imageModal = document.getElementById('imageModal');
    const modalImg = document.getElementById('modalImage');
    imageModal.style.display = 'flex';
    modalImg.src = src;

    const closeImageModal = document.getElementById('closeModal');
    closeImageModal.addEventListener('click', () => imageModal.style.display = 'none');

    imageModal.addEventListener('click', e => {
        if (e.target === imageModal) imageModal.style.display = 'none';
    });
}







// 🔹 10. Tải danh sách khi mở trang
window.addEventListener("DOMContentLoaded", loadProducts);



// ✅ Hàm chống gọi API liên tục khi người dùng gõ nhanh
function debounce(func, delay) {
    let timer;
    return function (...args) {
        clearTimeout(timer);
        timer = setTimeout(() => func.apply(this, args), delay);
    };
}



const apiCategory = "http://localhost:5000/api-core/category/search";

// =====================================================
// 🗂️ Load danh sách Category từ SQL qua API
// =====================================================
async function loadCategories() {
  
  const select = document.getElementById("searchCategory");

  try {
    // Gọi API lấy toàn bộ danh mục (pageSize = 0 để lấy hết)
    const response = await fetch(apiCategory, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        page: 1,
        pageSize: 9999999,         // ✅ lấy tất cả danh mục
        CategoryID: null,
        CategoryName: "",
        option: ""
      }),
    });

    if (!response.ok) throw new Error("Không thể tải danh mục!");

    const result = await response.json();
    const categories = result.data;

    // Làm sạch dropdown
    select.innerHTML = '<option value="">Select</option>';

    // Đổ danh sách danh mục vào dropdown
    categories.forEach(c => {
      const option = document.createElement("option");
      option.value = c.categoryID;        // ✅ backend trả "CategoryID"
      option.textContent = c.categoryName; // ✅ backend trả "CategoryName"
      select.appendChild(option);
    });


    new Choices(select, {
        searchEnabled: true,
        itemSelectText: "",
        shouldSort: false,
        allowHTML: true
    });



  } catch (error) {
    console.error("❌ Lỗi khi tải danh mục:", error);
    select.innerHTML = '<option value="">(Không tải được dữ liệu)</option>';
  }
}

// Gọi hàm khi trang load xong
window.addEventListener("DOMContentLoaded", loadCategories);


// ======================================================
// 📤 EXPORT SẢN PHẨM RA FILE EXCEL
// ======================================================
document.getElementById("btnExport").addEventListener("click", async () => {
  try {

    const sku = document.getElementById("searchInput").value.trim();
    const barcode = document.getElementById("searchBarcode").value.trim();
    const categoryID = document.getElementById("searchCategory").value
      ? parseInt(document.getElementById("searchCategory").value)
      : null;



    const response = await fetch(`${API_BASE}/search-product`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        page: 1,
        pageSize: 9999,
        productID: null,
        sku: sku || "",
        barcode: barcode || "",
        productName: "",
        categoryID: categoryID,
        status: ""
      }),
    });

    if (!response.ok) throw new Error("Không thể tải dữ liệu sản phẩm!");

    const result = await response.json();
    const products = result.data || [];

    if (products.length === 0) {
      alert("⚠️ Không có dữ liệu để xuất!");
      return;
    }

    // Định dạng dữ liệu cho Excel
    const exportData = products.map(p => ({
      ProductID: p.productID,
      SKU: p.sku,
      Barcode: p.barcode,
      ProductName: p.productName,
      CategoryID: p.categoryID,
      Unit: p.unit,
      MinStock: p.minStock,
      Quantity: p.quantity,
      VATRate: p.vatRate,
      Status: p.status,
    }));

    // Dùng SheetJS để xuất file Excel
    const wb = XLSX.utils.book_new();
    const ws = XLSX.utils.json_to_sheet(exportData);
    XLSX.utils.book_append_sheet(wb, ws, "Products");
    XLSX.writeFile(wb, "Products.xlsx");

    alert("✅ Đã xuất danh sách sản phẩm thành công!");
  } catch (error) {
    console.error("❌ Lỗi xuất file:", error);
    alert("❌ Lỗi khi xuất danh sách sản phẩm!");
  }
});


// ======================================================
// 🔍 LỌC SẢN PHẨM THEO SKU + BARCODE + CATEGORY CÙNG LÚC
// ======================================================

const searchInput = document.getElementById("searchInput");      // SKU
const searchBarcode = document.getElementById("searchBarcode");  // Barcode
const categorySelect = document.getElementById("searchCategory");// Category


const categoryIdInput = document.getElementById("CategoryID");

// ✅ Cập nhật số lượng sản phẩm tồn kho
const lowStockElement = document.getElementById("lowStock");
const outOfStockElement = document.getElementById("outOfStock");
const inStockElement = document.getElementById("inStock");


// ✅ Gọi API chung
async function applyFilters() {
    const sku = searchInput.value.trim();
    const barcode = searchBarcode.value.trim();
    const categoryID = categorySelect.value ? parseInt(categorySelect.value) : null;

    tableBody.innerHTML = "<tr><td colspan='12'>🔎 Đang lọc sản phẩm...</td></tr>";

    try {
        const response = await fetch(`${API_BASE}/search-product`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                page: 1,
                pageSize: 50,
                productID: null,
                sku: sku || "",         // ✅ nếu trống vẫn truyền rỗng
                barcode: barcode || "",
                productName: "",
                categoryID: categoryID, // ✅ có thể null
                status: ""
            }),
        });

        if (!response.ok) throw new Error("Không thể lọc sản phẩm!");

        const result = await response.json();
        renderProducts(result.data);

        // ✅ Cập nhật số lượng thống kê
        if (totalElement) {
            totalElement.textContent = result.totalItems ?? result.data?.length ?? 0;
        }


        if (lowStockElement && outOfStockElement && inStockElement) {
            const lowStockCount = result.data.filter(p => p.quantity < p.minStock).length;
            const outOfStockCount = result.data.filter(p => p.quantity === 0).length;
            const inStockECount = result.data.filter(p => p.quantity > p.minStock).length;

            lowStockElement.textContent = lowStockCount;
            outOfStockElement.textContent = outOfStockCount;
            inStockElement.textContent = inStockECount;
        }



    } catch (error) {
        console.error("❌ Lỗi khi lọc:", error);
        tableBody.innerHTML = "<tr><td colspan='12' style='color:red;'>❌ Lỗi khi lọc sản phẩm!</td></tr>";
        if (totalElement) totalElement.textContent = "0";
    }
}

// ✅ Gắn sự kiện lọc đồng bộ
searchInput.addEventListener("input", debounce(applyFilters, 400));
searchBarcode.addEventListener("input", debounce(applyFilters, 400));
categorySelect.addEventListener("change", function () {
    // ✅ Gán CategoryID vào ô input
    categoryIdInput.value = categorySelect.value || "";

    // ✅ Gọi lại bộ lọc (nếu đang dùng applyFilters)
    applyFilters();
});



