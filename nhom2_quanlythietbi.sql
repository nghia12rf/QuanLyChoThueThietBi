-- Tao Database
CREATE DATABASE QuanLyChoThueThietBiDB;
GO

USE QuanLyChoThueThietBiDB;
GO

-- =============================================
-- 1. BANG NGUOI DUNG
-- =============================================
CREATE TABLE NguoiDung (
    MaNguoiDung INT IDENTITY(1,1) PRIMARY KEY,
    TenDangNhap NVARCHAR(50) UNIQUE NOT NULL,
    MatKhauHash NVARCHAR(255) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    VaiTro NVARCHAR(20) CHECK (VaiTro IN ('Admin', 'Employee')) NOT NULL,
    TrangThaiHoatDong BIT DEFAULT 1,
    NgayTao DATETIME DEFAULT GETDATE()
);

-- =============================================
-- 2. BANG DANH MUC THIET BI
-- =============================================
CREATE TABLE DanhMucThietBi (
    MaDanhMuc INT IDENTITY(1,1) PRIMARY KEY,
    TenDanhMuc NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(255)
);

-- =============================================
-- 3. BANG KHACH HANG
-- =============================================
CREATE TABLE KhachHang (
    MaKhachHang INT IDENTITY(1,1) PRIMARY KEY,
    MaDinhDanhKhachHang NVARCHAR(50) UNIQUE NOT NULL,
    TenCongTy NVARCHAR(200) NOT NULL,
    NguoiDaiDien NVARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(20) NOT NULL,
    Email VARCHAR(100),
    DiaChi NVARCHAR(255),
    MaSoThue VARCHAR(50),
    NgayTao DATETIME DEFAULT GETDATE()
);

-- =============================================
-- 4. BANG THIET BI
-- =============================================
CREATE TABLE ThietBi (
    MaThietBi INT IDENTITY(1,1) PRIMARY KEY,
    MaDinhDanhThietBi NVARCHAR(50) UNIQUE NOT NULL,
    TenThietBi NVARCHAR(200) NOT NULL,
    MaDanhMuc INT FOREIGN KEY REFERENCES DanhMucThietBi(MaDanhMuc),
    HangSanXuat NVARCHAR(100),
    Model NVARCHAR(100),
    SoSeri NVARCHAR(100) UNIQUE NOT NULL,
    GiaThueNgay DECIMAL(18, 2) NOT NULL DEFAULT 0,
    GiaTriTaiSan DECIMAL(18, 2),
    TrangThai NVARCHAR(20) CHECK (TrangThai IN ('SanSang', 'DangChoThue', 'BaoTri', 'NgungSuDung')) DEFAULT 'SanSang',
    ThongSoKyThuat NVARCHAR(MAX),
    HinhAnhUrl NVARCHAR(500),
    NgayTao DATETIME DEFAULT GETDATE()
);

-- =============================================
-- 5. BANG HOP DONG THUE
-- =============================================
CREATE TABLE HopDong (
    MaHopDong INT IDENTITY(1,1) PRIMARY KEY,
    MaDinhDanhHopDong NVARCHAR(50) UNIQUE NOT NULL,
    MaKhachHang INT NOT NULL FOREIGN KEY REFERENCES KhachHang(MaKhachHang),
    NgayBatDau DATE NOT NULL,
    NgayKetThucDuKien DATE NOT NULL,
    NgayKetThucThucTe DATE NULL,
    TongTien DECIMAL(18, 2) NOT NULL,
    TienCoc DECIMAL(18, 2) DEFAULT 0,
    TrangThai NVARCHAR(20) CHECK (TrangThai IN ('DangHieuLuc', 'DaKetThuc', 'QuaHan', 'GiaHan')) DEFAULT 'DangHieuLuc',
    MaNguoiTao INT NOT NULL FOREIGN KEY REFERENCES NguoiDung(MaNguoiDung),
    NgayTao DATETIME DEFAULT GETDATE(),
    GhiChu NVARCHAR(500)
);

-- =============================================
-- 6. BANG CHI TIET HOP DONG
-- =============================================
CREATE TABLE ChiTietHopDong (
    MaChiTietHopDong INT IDENTITY(1,1) PRIMARY KEY,
    MaHopDong INT NOT NULL FOREIGN KEY REFERENCES HopDong(MaHopDong) ON DELETE CASCADE,
    MaThietBi INT NOT NULL FOREIGN KEY REFERENCES ThietBi(MaThietBi),
    GiaThueThoiDiem DECIMAL(18, 2) NOT NULL,
    ThanhTien DECIMAL(18, 2) NOT NULL,
    GhiChu NVARCHAR(200)
);

-- =============================================
-- 7. BANG GIA HAN HOP DONG
-- =============================================
CREATE TABLE GiaHanHopDong (
    MaGiaHan INT IDENTITY(1,1) PRIMARY KEY,
    MaHopDong INT NOT NULL FOREIGN KEY REFERENCES HopDong(MaHopDong),
    NgayKetThucCu DATE NOT NULL,
    NgayKetThucMoi DATE NOT NULL,
    SoTienBoSung DECIMAL(18, 2) NOT NULL,
    LyDoGiaHan NVARCHAR(500),
    MaNguoiThucHien INT NOT NULL FOREIGN KEY REFERENCES NguoiDung(MaNguoiDung),
    NgayTao DATETIME DEFAULT GETDATE()
);

-- =============================================
-- 8. BANG PHIEU THU HOI (DA BO SUNG ANH HU HONG)
-- =============================================
CREATE TABLE PhieuThuHoi (
    MaPhieuThuHoi INT IDENTITY(1,1) PRIMARY KEY,
    MaHopDong INT NOT NULL FOREIGN KEY REFERENCES HopDong(MaHopDong),
    NgayTra DATE NOT NULL,
    SoNgayTre INT DEFAULT 0,
    TienPhatTre DECIMAL(18, 2) DEFAULT 0,
    PhiHuHong DECIMAL(18, 2) DEFAULT 0,
    TongTienPhaiThanhToan DECIMAL(18, 2),
    CoHuHong BIT DEFAULT 0,
    GhiChuHuHong NVARCHAR(500),
    DanhSachAnhHuHong NVARCHAR(MAX) NULL, -- <<< BO SUNG THEO YEU CAU
    MaNguoiNhan INT NOT NULL FOREIGN KEY REFERENCES NguoiDung(MaNguoiDung),
    NgayTao DATETIME DEFAULT GETDATE()
);

-- =============================================
-- 9. BANG LICH SU LUAN CHUYEN
-- =============================================
CREATE TABLE LichSuLuanChuyen (
    MaLuanChuyen INT IDENTITY(1,1) PRIMARY KEY,
    MaThietBi INT NOT NULL FOREIGN KEY REFERENCES ThietBi(MaThietBi),
    LoaiLuanChuyen NVARCHAR(20) CHECK (LoaiLuanChuyen IN ('XuatThue', 'NhapHoi', 'DiBaoTri', 'GiaHan')),
    MaHopDongLienQuan INT NULL FOREIGN KEY REFERENCES HopDong(MaHopDong),
    TrangThaiTruoc NVARCHAR(20),
    TrangThaiSau NVARCHAR(20),
    GhiChu NVARCHAR(500),
    MaNguoiThucHien INT NOT NULL FOREIGN KEY REFERENCES NguoiDung(MaNguoiDung),
    NgayTao DATETIME DEFAULT GETDATE()
);
use QuanLyChoThueThietBiDB
go
INSERT INTO DanhMucThietBi (TenDanhMuc) VALUES (N'Máy ảnh'), (N'Ống kính'), (N'Máy quay');

USE QuanLyChoThueThietBiDB;
GO

ALTER TABLE ThietBi
ADD CongSuat NVARCHAR(100),
    TrongLuong NVARCHAR(100),
    DienAp NVARCHAR(100);
GO

--Tạo bảng THONGBAO
CREATE TABLE ThongBao (
    MaThongBao INT IDENTITY(1,1) PRIMARY KEY,
    TieuDe NVARCHAR(200) NOT NULL,
    NoiDung NVARCHAR(500) NOT NULL,
    LoaiThongBao NVARCHAR(50) NOT NULL,
    DaDoc BIT NOT NULL DEFAULT 0,
    MaNguoiDung INT NULL,
    NgayTao DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_ThongBao_NguoiDung 
    FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)
);
GO

INSERT INTO ThongBao (TieuDe, NoiDung, LoaiThongBao, DaDoc, MaNguoiDung)
VALUES
(N'Thiết bị đang bảo trì', N'Có thiết bị đang trong trạng thái bảo trì.', N'BaoTri', 0, NULL),
(N'Hợp đồng mới', N'Có hợp đồng thuê thiết bị vừa được tạo.', N'HopDong', 0, NULL),
(N'Thiết bị quá hạn', N'Có thiết bị thuê đã quá hạn trả.', N'QuaHan', 0, NULL);

select *from ThongBao
SELECT * FROM NguoiDung