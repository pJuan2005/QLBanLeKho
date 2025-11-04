// ==================== 1. KHAI BÁO BIẾN ====================
const tableBody = document.querySelector(".product-table tbody");
const searchBtn = document.querySelector(".btn-search");

// Lấy input filter
const minAmountInput = document.getElementById("minAmount");
const maxAmountInput = document.getElementById("maxAmount");

const statusSelect = document.getElementById("statusSelect");     
const fromDateInput = document.getElementById("fromDate");      
const toDateInput = document.getElementById("toDate");   
        
// DỰA TRÊN current_url TỪ FILE GLOBAL
const API_BASE = `${current_url}/api-core/purchaseorder`;

// ==================== 2. LOAD + TÌM KIẾM ====================
async function loadPurchaseOrders() {
    tableBody.innerHTML = "<tr><td colspan='6'>Đang tải dữ liệu...</td></tr>";

    // Tạo query string từ input
    const params = new URLSearchParams();

    // Chỉ thêm nếu có giá trị (tránh gửi rỗng)
    const min = minAmountInput.value.trim();
    const max = maxAmountInput.value.trim();
    const status = statusSelect.value;
    const from = fromDateInput.value;
    const to = toDateInput.value;

    if (min) params.append("minTotalAmount", min);
    if (max) params.append("maxTotalAmount", max);
    if (status && status !== "All Status") params.append("status", status);
    if (from) params.append("fromDate", from);
    if (to) params.append("toDate", to);

    try {
        // GỌI GET /search?minTotalAmount=...&status=...
        const response = await fetch(`${API_BASE}/search?${params.toString()}`);
        
        if (!response.ok) throw new Error(`HTTP ${response.status}`);

        const pos = await response.json(); // Mảng PO từ SP
        renderPurchaseOrders(pos);
        updateStats(pos); // CẬP NHẬT THỐNG KÊ
    } catch (error) {
        console.error("Lỗi:", error);
        tableBody.innerHTML = "<tr><td colspan='6' style='color:red;'>Không thể tải dữ liệu!</td></tr>";
    }
}

// ==================== 3. RENDER BẢNG ====================
function renderPurchaseOrders(pos) {
    if (!pos || pos.length === 0) {
        tableBody.innerHTML = `
            <tr>
                <td colspan="6" class="empty-state">
                    <p>No purchase orders found</p>
                    <small>Try adjusting your filters or add a new PO</small>
                </td>
            </tr>
        `;
        return;
    }

    tableBody.innerHTML = pos.map(po => `
        <tr data-poid="${po.poid}">
            <td>${po.poid}</td>
            <td>${po.supplierID}</td>
            <td>${formatDate(po.orderDate)}</td>
            <td>$${parseFloat(po.totalAmount).toFixed(2)}</td>
            <td><span class="status ${getStatusClass(po.status)}">${po.status}</span></td>
            <td class="actions">
                <button class="icon-btn detail" title="Xem chi tiết" onclick="openDetail(${po.poid})">
                <i class="fas fa-eye"></i>
            </button>
                <button class="icon-btn update" title="Sửa" onclick="openUpdate(${po.poid})">
                <i class="fas fa-edit"></i>
            </button>
            <button class="icon-btn delete" title="Xóa" onclick="deletePO(${po.poid})">
                <i class="fas fa-trash-alt"></i>
                </button>
            </td>
        </tr>
    `).join("");
}

// ==================== 4. HỖ TRỢ ====================
function formatDate(orderDate) {
    return new Date(orderDate).toLocaleDateString("vi-VN");
}

function getStatusClass(status) {
    return status === 'Approved' ? 'active' : status === 'Pending' ? 'low' : '';
}

// ==================== 5. SỰ KIỆN ====================
// Chỉ tìm khi nhấn nút Search
searchBtn?.addEventListener("click", loadPurchaseOrders);

// Load lần đầu khi mở trang
window.addEventListener("DOMContentLoaded", loadPurchaseOrders);

// CẬP NHẬT 3 Ô THỐNG KÊ
function updateStats(pos) {
    const total = pos.length;

    const pending = pos.filter(po => po.status === "Pending").length;
    const approved = pos.filter(po => po.status === "Approved").length;

    // Cập nhật lên HTML
    document.getElementById("totalPOs").textContent = total;
    document.getElementById("pendingPOs").textContent = pending;
    document.getElementById("approvedPOs").textContent = approved;
}



// MỞ CỬA SỔ NHỎ
function openAddModal() {
    const width = 450;
    const height = 500;
    const left = (screen.width / 2) - (width / 2);
    const top = (screen.height / 2) - (height / 2);

    window.open(
        "/AuthFE/AddPurchase.html", 
        "AddPO", 
        `width=${width},height=${height},left=${left},top=${top},resizable=yes,scrollbars=yes`
    );
}
// THÊM VÀO CUỐI FILE
window.refreshPOTable = function() {
    console.log("Đang cập nhật bảng từ popup...");
    loadPurchaseOrders(); // TẢI LẠI DỮ LIỆU
};

// GẮN SỰ KIỆN (nếu muốn dùng JS thay onclick)
document.getElementById("addPOBtn")?.addEventListener("click", openAddModal);
// OPEN DETAIL
function openDetail(poid) {
    const width = 900;
    const height = 600;
    const left = (screen.width / 2) - (width / 2);
    const top = (screen.height / 2) - (height / 2);

    // SỬA: TÊN DUY NHẤT CHO MỖI POID
    const popupName = `DetailPO_${poid}_${Date.now()}`;

    const popup = window.open(
        `/AuthFE/detail-po.html?poid=${poid}`,
        popupName,  
        `width=${width},height=${height},left=${left},top=${top},resizable=yes,scrollbars=yes`
    );

    if (popup) popup.focus();
}


//Open Update 
function openUpdate(poid) {
    const width = 550;
    const height = 600;
    const left = (screen.width / 2) - (width / 2);
    const top = (screen.height / 2) - (height / 2);

    const popupName = `UpdatePO_${poid}_${Date.now()}`;

    const popup = window.open(
        `/AuthFE/update-po.html?poid=${poid}`,
        popupName,
        `width=${width},height=${height},left=${left},top=${top},resizable=yes,scrollbars=yes`
    );

    if (popup) popup.focus();
}

//Open Delete
async function deletePO(poid) {
    // XÁC NHẬN TRƯỚC KHI XÓA
    const confirmDelete = confirm(`Bạn có chắc chắn muốn xóa đơn mua hàng POID = ${poid}?`);
    if (!confirmDelete) return;

    try {
        const response = await fetch(`${API_BASE}/delete`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ POID: poid }) // GỬI ĐÚNG TÊN TRƯỜNG
        });

        if (!response.ok) {
            const err = await response.text();
            throw new Error(err || "Xóa thất bại");
        }

        alert("Xóa thành công!");
        loadPurchaseOrders(); // TẢI LẠI BẢNG CHÍNH

    } catch (error) {
        alert("Lỗi: " + error.message);
    }
}