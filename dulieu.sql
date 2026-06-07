-- ============================================================
-- SCRIPT TẠO DỮ LIỆU MẪU HOÀN CHỈNH
-- Cho đồ án Quản Lý Cho Thuê Thiết Bị (Máy ảnh, Ống kính, Flycam)
-- ============================================================

USE QuanLyChoThueThietBiDB;
GO

-- 1. TẠO TÀI KHOẢN ADMIN & EMPLOYEE (nếu chưa có)
IF NOT EXISTS (SELECT 1 FROM NguoiDung WHERE TenDangNhap = 'admin')
    INSERT INTO NguoiDung (TenDangNhap, MatKhauHash, HoTen, Email, VaiTro)
    VALUES ('admin', 'admin123', N'Quản Trị Viên', 'admin@rental.com', 'Admin');

IF NOT EXISTS (SELECT 1 FROM NguoiDung WHERE TenDangNhap = 'employee')
    INSERT INTO NguoiDung (TenDangNhap, MatKhauHash, HoTen, Email, VaiTro)
    VALUES ('employee', 'employee123', N'Nhân Viên Test', 'employee@rental.com', 'Employee');

-- Lấy ID thực tế của admin và employee
DECLARE @adminId INT = (SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'admin');
DECLARE @empId INT   = (SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'employee');

-- 2. DANH MỤC THIẾT BỊ
IF NOT EXISTS (SELECT 1 FROM DanhMucThietBi WHERE TenDanhMuc = N'Máy ảnh')
    INSERT INTO DanhMucThietBi (TenDanhMuc, MoTa) VALUES (N'Máy ảnh', N'Máy ảnh DSLR, Mirrorless');
IF NOT EXISTS (SELECT 1 FROM DanhMucThietBi WHERE TenDanhMuc = N'Ống kính')
    INSERT INTO DanhMucThietBi (TenDanhMuc, MoTa) VALUES (N'Ống kính', N'Các loại ống kính rời');
IF NOT EXISTS (SELECT 1 FROM DanhMucThietBi WHERE TenDanhMuc = N'Flycam / Drone')
    INSERT INTO DanhMucThietBi (TenDanhMuc, MoTa) VALUES (N'Flycam / Drone', N'Máy bay không người lái quay phim');
IF NOT EXISTS (SELECT 1 FROM DanhMucThietBi WHERE TenDanhMuc = N'Phụ kiện quay phim')
    INSERT INTO DanhMucThietBi (TenDanhMuc, MoTa) VALUES (N'Phụ kiện quay phim', N'Tripod, Gimbal, Đèn LED...');

-- 3. THIẾT BỊ (chỉ thêm nếu chưa có mã)
INSERT INTO ThietBi (MaDinhDanhThietBi, TenThietBi, MaDanhMuc, HangSanXuat, Model, SoSeri, GiaThueNgay, GiaTriTaiSan, TrangThai)
SELECT * FROM (VALUES
    ('CAM001', N'Sony A7M4', 1, 'Sony', 'ILCE-7M4', 'SN-CAM-00001', 350000, 45000000, N'SanSang'),
    ('CAM002', N'Canon EOS R5', 1, 'Canon', 'EOS R5', 'SN-CAM-00002', 500000, 65000000, N'SanSang'),
    ('CAM003', N'Nikon Z6 II', 1, 'Nikon', 'Z6 II', 'SN-CAM-00003', 300000, 38000000, N'DangChoThue'),
    ('LENS001', N'Canon EF 24-70mm f/2.8L', 2, 'Canon', 'EF 24-70mm f/2.8L II USM', 'SN-LENS-00001', 200000, 32000000, N'SanSang'),
    ('LENS002', N'Sony FE 70-200mm f/2.8 GM', 2, 'Sony', 'SEL70200GM', 'SN-LENS-00002', 280000, 45000000, N'SanSang'),
    ('LENS003', N'Sigma 50mm f/1.4 Art', 2, 'Sigma', '50mm F1.4 DG HSM', 'SN-LENS-00003', 150000, 18000000, N'BaoTri'),
    ('DRONE001', N'DJI Mavic 3 Pro', 3, 'DJI', 'Mavic 3 Pro', 'SN-DRONE-00001', 800000, 35000000, N'SanSang'),
    ('DRONE002', N'DJI Air 3', 3, 'DJI', 'Air 3', 'SN-DRONE-00002', 500000, 22000000, N'DangChoThue'),
    ('ACC001', N'DJI Ronin RS 3 Pro', 4, 'DJI', 'Ronin RS 3 Pro', 'SN-ACC-00001', 250000, 18000000, N'SanSang'),
    ('ACC002', N'Đèn LED Aputure Amaran 200D', 4, 'Aputure', 'Amaran 200D', 'SN-ACC-00002', 120000, 6500000, N'SanSang')
) AS T(Ma, Ten, DanhMuc, Hang, Model, Seri, GiaThue, GiaTri, Status)
WHERE NOT EXISTS (SELECT 1 FROM ThietBi WHERE MaDinhDanhThietBi = T.Ma);

-- 4. KHÁCH HÀNG
IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH001')
    INSERT INTO KhachHang (MaDinhDanhKhachHang, TenCongTy, NguoiDaiDien, SoDienThoai, Email, DiaChi, MaSoThue)
    VALUES ('KH001', N'Studio Ảnh Cưới Lavender', N'Nguyễn Thị Hương', '0901234567', 'huong@lavenderstudio.vn', N'123 Nguyễn Huệ, Quận 1', '0312345678');
IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH002')
    INSERT INTO KhachHang (MaDinhDanhKhachHang, TenCongTy, NguoiDaiDien, SoDienThoai, Email, DiaChi, MaSoThue)
    VALUES ('KH002', N'Công ty Truyền thông MediaMax', N'Trần Văn Minh', '0912345678', 'minh.tv@mediamax.vn', N'456 Lê Lợi, Quận 3', '0312345679');
IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH003')
    INSERT INTO KhachHang (MaDinhDanhKhachHang, TenCongTy, NguoiDaiDien, SoDienThoai, Email, DiaChi)
    VALUES ('KH003', N'Ê-kíp làm phim tự do', N'Lê Hoàng Nam', '0923456789', 'nam.freelancer@gmail.com', N'77 Hoàng Diệu, Quận 4');

-- 5. HỢP ĐỒNG
-- Lấy ID khách hàng
DECLARE @kh1 INT = (SELECT MaKhachHang FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH001');
DECLARE @kh2 INT = (SELECT MaKhachHang FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH002');

-- Hợp đồng 1 (đã thu hồi)
IF NOT EXISTS (SELECT 1 FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0001')
    INSERT INTO HopDong (MaDinhDanhHopDong, MaKhachHang, NgayBatDau, NgayKetThucDuKien, TongTien, TienCoc, TrangThai, MaNguoiTao, GhiChu)
    VALUES ('HD-2026-0001', @kh1, '2026-04-01', '2026-04-05', 1750000, 500000, N'DaKetThuc', @adminId, N'Thuê máy ảnh chụp sự kiện cưới');

-- Hợp đồng 2 (đang hiệu lực)
IF NOT EXISTS (SELECT 1 FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0002')
    INSERT INTO HopDong (MaDinhDanhHopDong, MaKhachHang, NgayBatDau, NgayKetThucDuKien, TongTien, TienCoc, TrangThai, MaNguoiTao, GhiChu)
    VALUES ('HD-2026-0002', @kh2, '2026-04-10', '2026-04-15', 0, 1000000, N'DangHieuLuc', @adminId, N'Thuê flycam và máy ảnh quay TVC');

-- Lấy ID hợp đồng
DECLARE @hd1 INT = (SELECT MaHopDong FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0001');
DECLARE @hd2 INT = (SELECT MaHopDong FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0002');

-- 6. CHI TIẾT HỢP ĐỒNG
-- Hợp đồng 1: thuê máy ảnh Sony A7M4 (5 ngày)
IF NOT EXISTS (SELECT 1 FROM ChiTietHopDong WHERE MaHopDong = @hd1 AND MaThietBi = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'CAM001'))
    INSERT INTO ChiTietHopDong (MaHopDong, MaThietBi, GiaThueThoiDiem, ThanhTien, GhiChu)
    VALUES (@hd1, (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'CAM001'), 350000, 1750000, N'Máy ảnh Sony A7M4');

-- Hợp đồng 2: thuê flycam (5 ngày)
IF NOT EXISTS (SELECT 1 FROM ChiTietHopDong WHERE MaHopDong = @hd2 AND MaThietBi = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'DRONE001'))
    INSERT INTO ChiTietHopDong (MaHopDong, MaThietBi, GiaThueThoiDiem, ThanhTien, GhiChu)
    VALUES (@hd2, (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'DRONE001'), 800000, 4000000, N'Flycam DJI Mavic 3 Pro');

-- Hợp đồng 2: thuê thêm máy ảnh Sony A7M4 (5 ngày)
IF NOT EXISTS (SELECT 1 FROM ChiTietHopDong WHERE MaHopDong = @hd2 AND MaThietBi = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'CAM002'))
    INSERT INTO ChiTietHopDong (MaHopDong, MaThietBi, GiaThueThoiDiem, ThanhTien, GhiChu)
    VALUES (@hd2, (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'CAM002'), 500000, 2500000, N'Máy ảnh Canon EOS R5');

-- Cập nhật tổng tiền hợp đồng
UPDATE HopDong SET TongTien = (SELECT SUM(ThanhTien) FROM ChiTietHopDong WHERE MaHopDong = @hd1) WHERE MaHopDong = @hd1;
UPDATE HopDong SET TongTien = (SELECT SUM(ThanhTien) FROM ChiTietHopDong WHERE MaHopDong = @hd2) WHERE MaHopDong = @hd2;

-- 7. PHIẾU THU HỒI cho hợp đồng 1 (có hỏng hóc)
IF NOT EXISTS (SELECT 1 FROM PhieuThuHoi WHERE MaHopDong = @hd1)
    INSERT INTO PhieuThuHoi (MaHopDong, NgayTra, SoNgayTre, TienPhatTre, PhiHuHong, TongTienPhaiThanhToan, CoHuHong, GhiChuHuHong, DanhSachAnhHuHong, MaNguoiNhan)
    VALUES (@hd1, '2026-04-06', 1, 100000, 200000, 300000, 1, N'Ống kính bị xước nhẹ, nắp che không kín', NULL, @empId);

-- 8. CẬP NHẬT TRẠNG THÁI THIẾT BỊ THEO HỢP ĐỒNG ĐANG HIỆU LỰC
-- Thiết bị trong hợp đồng 2 đang thuê -> chuyển thành 'DangChoThue'
UPDATE ThietBi SET TrangThai = N'DangChoThue' 
WHERE MaThietBi IN (
    SELECT MaThietBi FROM ChiTietHopDong 
    WHERE MaHopDong = @hd2
);

-- Thiết bị trong hợp đồng 1 đã trả, Sony A7M4 bị hỏng -> 'BaoTri'
UPDATE ThietBi SET TrangThai = N'BaoTri' WHERE MaDinhDanhThietBi = 'CAM001';

PRINT N'✅ Đã thêm dữ liệu mẫu thành công!';

-- Xem số lượng thiết bị theo trạng thái
SELECT TrangThai, COUNT(*) AS SoLuong FROM ThietBi GROUP BY TrangThai;

-- Xem hợp đồng và tổng tiền
SELECT MaDinhDanhHopDong, TrangThai, TongTien FROM HopDong;

-- Xem phiếu thu hồi
SELECT * FROM PhieuThuHoi;


USE QuanLyChoThueThietBiDB;
GO

-- =============================================
-- 1. BỔ SUNG DANH MỤC (nếu thiếu)
-- =============================================
IF NOT EXISTS (SELECT 1 FROM DanhMucThietBi WHERE TenDanhMuc = N'Máy ảnh')
    INSERT INTO DanhMucThietBi (TenDanhMuc, MoTa) VALUES (N'Máy ảnh', N'DSLR, Mirrorless');
IF NOT EXISTS (SELECT 1 FROM DanhMucThietBi WHERE TenDanhMuc = N'Ống kính')
    INSERT INTO DanhMucThietBi (TenDanhMuc, MoTa) VALUES (N'Ống kính', N'Các loại ống kính rời');
IF NOT EXISTS (SELECT 1 FROM DanhMucThietBi WHERE TenDanhMuc = N'Flycam / Drone')
    INSERT INTO DanhMucThietBi (TenDanhMuc, MoTa) VALUES (N'Flycam / Drone', N'Máy bay không người lái quay phim');
IF NOT EXISTS (SELECT 1 FROM DanhMucThietBi WHERE TenDanhMuc = N'Phụ kiện quay phim')
    INSERT INTO DanhMucThietBi (TenDanhMuc, MoTa) VALUES (N'Phụ kiện quay phim', N'Tripod, Gimbal, Đèn LED...');

-- =============================================
-- 2. BỔ SUNG THIẾT BỊ MỚI (Quay phim / Chụp ảnh)
-- =============================================
INSERT INTO ThietBi (MaDinhDanhThietBi, TenThietBi, MaDanhMuc, HangSanXuat, Model, SoSeri, GiaThueNgay, GiaTriTaiSan, TrangThai)
SELECT * FROM (VALUES
    ('CAM004', N'Canon EOS R6 Mark II', (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Máy ảnh'), 'Canon', 'EOS R6 Mark II', 'SN-CAM-00004', 450000, 55000000, N'SanSang'),
    ('CAM005', N'Sony FX3', (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Máy ảnh'), 'Sony', 'FX3', 'SN-CAM-00005', 600000, 72000000, N'SanSang'),
    ('LENS004', N'Sony FE 16-35mm f/2.8 GM', (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Ống kính'), 'Sony', 'SEL1635GM', 'SN-LENS-00004', 250000, 40000000, N'SanSang'),
    ('LENS005', N'Canon EF 70-200mm f/2.8L IS III', (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Ống kính'), 'Canon', 'EF 70-200mm f/2.8L', 'SN-LENS-00005', 220000, 35000000, N'BaoTri'),
    ('DRONE003', N'DJI Mini 3 Pro', (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Flycam / Drone'), 'DJI', 'Mini 3 Pro', 'SN-DRONE-00003', 350000, 15000000, N'SanSang'),
    ('ACC003', N'Gimbal DJI RS 3 Mini', (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Phụ kiện quay phim'), 'DJI', 'RS 3 Mini', 'SN-ACC-00003', 150000, 8000000, N'SanSang'),
    ('ACC004', N'Đèn LED Godox SL60W', (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Phụ kiện quay phim'), 'Godox', 'SL60W', 'SN-ACC-00004', 100000, 5000000, N'DangChoThue')
) AS T(Ma, Ten, DanhMuc, Hang, Model, Seri, GiaThue, GiaTri, Status)
WHERE NOT EXISTS (SELECT 1 FROM ThietBi WHERE MaDinhDanhThietBi = T.Ma);

-- =============================================
-- 3. BỔ SUNG KHÁCH HÀNG MỚI
-- =============================================
IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH004')
    INSERT INTO KhachHang (MaDinhDanhKhachHang, TenCongTy, NguoiDaiDien, SoDienThoai, Email, DiaChi)
    VALUES ('KH004', N'Công ty Tổ chức Sự kiện Sài Gòn', N'Phạm Minh Tuấn', '0933456789', 'tuan.pm@saigonevent.vn', N'88 Hoàng Sa, Q3');
IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH005')
    INSERT INTO KhachHang (MaDinhDanhKhachHang, TenCongTy, NguoiDaiDien, SoDienThoai, Email, DiaChi)
    VALUES ('KH005', N'Nhiếp ảnh gia Nguyễn Hoàng', N'Nguyễn Hoàng', '0944567890', 'hoangphoto@gmail.com', N'12 Trần Hưng Đạo, Q5');

-- =============================================
-- 4. BỔ SUNG HỢP ĐỒNG (Đa dạng trạng thái)
-- =============================================
DECLARE @adminId INT = (SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'admin');
DECLARE @empId INT = (SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'employee');

-- Hợp đồng 3: đang hiệu lực (thuê flycam, máy ảnh)
IF NOT EXISTS (SELECT 1 FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0003')
BEGIN
    INSERT INTO HopDong (MaDinhDanhHopDong, MaKhachHang, NgayBatDau, NgayKetThucDuKien, TongTien, TienCoc, TrangThai, MaNguoiTao, GhiChu)
    VALUES ('HD-2026-0003', (SELECT MaKhachHang FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH004'), '2026-04-12', '2026-04-18', 0, 2000000, N'DangHieuLuc', @adminId, N'Quay sự kiện hội nghị');
END

-- Hợp đồng 4: quá hạn
IF NOT EXISTS (SELECT 1 FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0004')
BEGIN
    INSERT INTO HopDong (MaDinhDanhHopDong, MaKhachHang, NgayBatDau, NgayKetThucDuKien, TongTien, TienCoc, TrangThai, MaNguoiTao, GhiChu)
    VALUES ('HD-2026-0004', (SELECT MaKhachHang FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH005'), '2026-03-25', '2026-04-02', 900000, 500000, N'QuaHan', @adminId, N'Thuê ống kính chụp cưới');
END

-- Hợp đồng 5: đã kết thúc (đã thu hồi)
IF NOT EXISTS (SELECT 1 FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0005')
BEGIN
    INSERT INTO HopDong (MaDinhDanhHopDong, MaKhachHang, NgayBatDau, NgayKetThucDuKien, TongTien, TienCoc, TrangThai, MaNguoiTao, GhiChu)
    VALUES ('HD-2026-0005', (SELECT MaKhachHang FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH001'), '2026-04-05', '2026-04-08', 1050000, 300000, N'DaKetThuc', @adminId, N'Thuê máy ảnh cho sự kiện nhỏ');
END

-- =============================================
-- 5. BỔ SUNG CHI TIẾT HỢP ĐỒNG
-- =============================================
DECLARE @hd3 INT = (SELECT MaHopDong FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0003');
DECLARE @hd4 INT = (SELECT MaHopDong FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0004');
DECLARE @hd5 INT = (SELECT MaHopDong FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0005');

-- Chi tiết HD3: Flycam và máy ảnh Sony FX3
IF NOT EXISTS (SELECT 1 FROM ChiTietHopDong WHERE MaHopDong = @hd3 AND MaThietBi = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'DRONE003'))
    INSERT INTO ChiTietHopDong (MaHopDong, MaThietBi, GiaThueThoiDiem, ThanhTien, GhiChu)
    VALUES (@hd3, (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'DRONE003'), 350000, 2450000, N'Flycam DJI Mini 3 Pro');

IF NOT EXISTS (SELECT 1 FROM ChiTietHopDong WHERE MaHopDong = @hd3 AND MaThietBi = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'CAM005'))
    INSERT INTO ChiTietHopDong (MaHopDong, MaThietBi, GiaThueThoiDiem, ThanhTien, GhiChu)
    VALUES (@hd3, (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'CAM005'), 600000, 4200000, N'Sony FX3');

-- Chi tiết HD4: một ống kính
IF NOT EXISTS (SELECT 1 FROM ChiTietHopDong WHERE MaHopDong = @hd4 AND MaThietBi = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'LENS004'))
    INSERT INTO ChiTietHopDong (MaHopDong, MaThietBi, GiaThueThoiDiem, ThanhTien, GhiChu)
    VALUES (@hd4, (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'LENS004'), 250000, 2000000, N'Sony FE 16-35mm f/2.8 GM');

-- Chi tiết HD5: máy ảnh Sony A7M4
IF NOT EXISTS (SELECT 1 FROM ChiTietHopDong WHERE MaHopDong = @hd5 AND MaThietBi = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'CAM001'))
    INSERT INTO ChiTietHopDong (MaHopDong, MaThietBi, GiaThueThoiDiem, ThanhTien, GhiChu)
    VALUES (@hd5, (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'CAM001'), 350000, 1050000, N'Sony A7M4');

-- Cập nhật tổng tiền cho các hợp đồng mới
UPDATE HopDong SET TongTien = (SELECT SUM(ThanhTien) FROM ChiTietHopDong WHERE MaHopDong = @hd3) WHERE MaHopDong = @hd3;
UPDATE HopDong SET TongTien = (SELECT SUM(ThanhTien) FROM ChiTietHopDong WHERE MaHopDong = @hd4) WHERE MaHopDong = @hd4;
UPDATE HopDong SET TongTien = (SELECT SUM(ThanhTien) FROM ChiTietHopDong WHERE MaHopDong = @hd5) WHERE MaHopDong = @hd5;

-- Cập nhật trạng thái thiết bị đã được thuê trong các hợp đồng đang hiệu lực/quá hạn
UPDATE ThietBi SET TrangThai = N'DangChoThue' WHERE MaDinhDanhThietBi IN ('DRONE003', 'CAM005', 'LENS004');

-- =============================================
-- 6. BỔ SUNG PHIẾU THU HỒI cho hợp đồng đã kết thúc (HD-0005)
-- =============================================
IF NOT EXISTS (SELECT 1 FROM PhieuThuHoi WHERE MaHopDong = @hd5)
BEGIN
    INSERT INTO PhieuThuHoi (MaHopDong, NgayTra, SoNgayTre, TienPhatTre, PhiHuHong, TongTienPhaiThanhToan, CoHuHong, GhiChuHuHong, DanhSachAnhHuHong, MaNguoiNhan)
    VALUES (@hd5, '2026-04-08', 0, 0, 0, 0, 0, N'Trả đúng hạn, thiết bị tốt', NULL, @empId);
    -- Cập nhật trạng thái thiết bị trong HD5 về SanSang
    UPDATE ThietBi SET TrangThai = N'SanSang' WHERE MaThietBi = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'CAM001');
END

-- Bổ sung phiếu thu hồi cho HD-0002 (giả sử đã quá hạn nhưng chưa thu hồi, tạo phiếu thu hồi với phí trễ)
-- Nếu chưa có phiếu thu hồi cho HD-0002, tạo
IF NOT EXISTS (SELECT 1 FROM PhieuThuHoi WHERE MaHopDong = (SELECT MaHopDong FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0002'))
BEGIN
    DECLARE @hd2 INT = (SELECT MaHopDong FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0002');
    INSERT INTO PhieuThuHoi (MaHopDong, NgayTra, SoNgayTre, TienPhatTre, PhiHuHong, TongTienPhaiThanhToan, CoHuHong, GhiChuHuHong, DanhSachAnhHuHong, MaNguoiNhan)
    VALUES (@hd2, '2026-04-18', 3, 300000, 0, 300000, 0, N'Trả trễ 3 ngày', NULL, @empId);
    -- Cập nhật trạng thái thiết bị về SanSang
    UPDATE ThietBi SET TrangThai = N'SanSang' WHERE MaThietBi IN (SELECT MaThietBi FROM ChiTietHopDong WHERE MaHopDong = @hd2);
END

-- =============================================
-- 7. BỔ SUNG GIA HẠN (Minh họa)
-- =============================================
-- Gia hạn cho hợp đồng HD-0003 (đang hiệu lực) kéo dài thêm 2 ngày
IF NOT EXISTS (SELECT 1 FROM GiaHanHopDong WHERE MaHopDong = @hd3)
BEGIN
    DECLARE @ngayCu DATE = (SELECT NgayKetThucDuKien FROM HopDong WHERE MaHopDong = @hd3);
    DECLARE @ngayMoi DATE = DATEADD(DAY, 2, @ngayCu);
    DECLARE @tienThem DECIMAL(18,2) = 2 * (350000 + 600000); -- tổng giá ngày của 2 thiết bị
    INSERT INTO GiaHanHopDong (MaHopDong, NgayKetThucCu, NgayKetThucMoi, SoTienBoSung, LyDoGiaHan, MaNguoiThucHien)
    VALUES (@hd3, @ngayCu, @ngayMoi, @tienThem, N'Khách hàng yêu cầu thêm ngày quay', @adminId);
    -- Cập nhật ngày kết thúc dự kiến của hợp đồng
    UPDATE HopDong SET NgayKetThucDuKien = @ngayMoi, TrangThai = N'GiaHan' WHERE MaHopDong = @hd3;
END

--Trigger Khi thêm hợp đồng mới
CREATE TRIGGER trg_ThongBao_ThemHopDong
ON HopDong
AFTER INSERT
AS
BEGIN
    INSERT INTO ThongBao (TieuDe, NoiDung, LoaiThongBao)
    SELECT 
        N'Hợp đồng mới',
        N'Có hợp đồng mới vừa được tạo: ' + ISNULL(MaDinhDanhHopDong, N''),
        N'HopDong'
    FROM inserted;
END;

--Trigger Khi thiết bị chuyển sang bảo trì
CREATE TRIGGER trg_ThongBao_ThietBiBaoTri
ON ThietBi
AFTER UPDATE
AS
BEGIN
    INSERT INTO ThongBao (TieuDe, NoiDung, LoaiThongBao)
    SELECT 
        N'Thiết bị bảo trì',
        N'Thiết bị "' + i.TenThietBi + N'" đã chuyển sang trạng thái bảo trì',
        N'BaoTri'
    FROM inserted i
    INNER JOIN deleted d ON i.MaThietBi = d.MaThietBi
    WHERE i.TrangThai = 'BaoTri' AND d.TrangThai <> 'BaoTri';
END; 

--Trigger Khi thu hồi thiết bị 
CREATE TRIGGER trg_ThongBao_ThemPhieuThuHoi
ON PhieuThuHoi
AFTER INSERT
AS
BEGIN
    INSERT INTO ThongBao (TieuDe, NoiDung, LoaiThongBao)
    SELECT 
        N'Thu hồi thiết bị',
        N'Có phiếu thu hồi thiết bị mới được tạo.',
        N'ThuHoi'
    FROM inserted;
END;