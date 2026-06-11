using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuanLyChoThueThietBi.Models;
using RentalEquipmentAPI.DTOs;
using AutoMapper;
using System.Security.Claims;

namespace RentalEquipmentAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PhieuThuHoiController : ControllerBase
    {
        private readonly QuanLyChoThueThietBiContext _context;
        private readonly IMapper _mapper;

        public PhieuThuHoiController(QuanLyChoThueThietBiContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/PhieuThuHoi
        [HttpGet]
        public async Task<ActionResult> GetPhieuThuHois()
        {
            try
            {
                var phieuThuHois = await _context.PhieuThuHois
                    .Include(p => p.MaHopDongNavigation)
                        .ThenInclude(h => h.MaKhachHangNavigation)
                    .Include(p => p.MaNguoiNhanNavigation)
                    .OrderByDescending(p => p.NgayTao)
                    .Select(p => new
                    {
                        p.MaPhieuThuHoi,
                        p.MaHopDong,
                        MaDinhDanhHopDong = p.MaHopDongNavigation.MaDinhDanhHopDong,
                        TenKhachHang = p.MaHopDongNavigation.MaKhachHangNavigation != null 
                            ? p.MaHopDongNavigation.MaKhachHangNavigation.TenCongTy 
                            : "Khách lẻ",
                        p.NgayTra,
                        SoNgayTre = p.SoNgayTre ?? 0,
                        TienPhatTre = p.TienPhatTre ?? 0,
                        PhiHuHong = p.PhiHuHong ?? 0,
                        TongTienPhaiThanhToan = p.TongTienPhaiThanhToan ?? 0,
                        CoHuHong = p.CoHuHong ?? false,
                        p.GhiChuHuHong,
                        p.DanhSachAnhHuHong,
                        p.MaNguoiNhan,
                        TenNguoiNhan = p.MaNguoiNhanNavigation.HoTen,
                        p.NgayTao
                    })
                    .ToListAsync();

                return Ok(phieuThuHois);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi truy vấn danh sách phiếu thu hồi", detail = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult> PostPhieuThuHoi(PhieuThuHoiCreateDto dto)
        {
            int currentUserId = GetCurrentUserId();
            if (currentUserId == 0) return Unauthorized(new { message = "Bạn cần đăng nhập lại!" });

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 1. Chốt Hợp Đồng & Tính toán chi tiết phiếu thu
                var hopDong = await _context.HopDongs
                    .Include(h => h.ChiTietHopDongs)
                    .FirstOrDefaultAsync(h => h.MaHopDong == dto.MaHopDong);

                if (hopDong == null)
                {
                    return NotFound(new { message = $"Không tìm thấy hợp đồng ID: {dto.MaHopDong}" });
                }

                // Tính toán ngày trễ và tiền phạt trễ
                int soNgayTre = 0;
                decimal tienPhatTre = 0m;
                if (dto.NgayTra > hopDong.NgayKetThucDuKien)
                {
                    soNgayTre = (int)Math.Ceiling((dto.NgayTra - hopDong.NgayKetThucDuKien).TotalDays);
                    // Tính tổng đơn giá thuê ngày của tất cả thiết bị trong hợp đồng
                    decimal tongGiaThueNgay = hopDong.ChiTietHopDongs.Sum(ct => ct.GiaThueThoiDiem);
                    // Phạt trễ hạn = số ngày trễ * (tổng giá thuê ngày * 1.5)
                    tienPhatTre = soNgayTre * (tongGiaThueNgay * 1.5m);
                }

                // Tính toán tổng tiền phải thanh toán
                decimal basePrice = hopDong.TongTien;
                decimal deposit = hopDong.TienCoc ?? 0m;
                decimal damageFine = dto.PhiHuHong;
                decimal total = basePrice + tienPhatTre + damageFine - deposit;
                decimal tongTienPhaiThanhToan = total > 0m ? total : 0m;

                // 2. Tạo Phiếu Thu Hồi
                var phieu = _mapper.Map<PhieuThuHoi>(dto);
                phieu.MaNguoiNhan = currentUserId;
                phieu.NgayTao = DateTime.Now;
                phieu.SoNgayTre = soNgayTre;
                phieu.TienPhatTre = tienPhatTre;
                phieu.TongTienPhaiThanhToan = tongTienPhaiThanhToan;

                _context.PhieuThuHois.Add(phieu);

                // 🔥 THAY THẾ TRIGGER 3: Thông báo lập phiếu thu hồi
                var thongBaoPhieu = new ThongBao
                {
                    TieuDe = "Phiếu thu hồi mới",
                    NoiDung = $"Có phiếu thu hồi vừa được lập cho hợp đồng ID: {dto.MaHopDong}",
                    LoaiThongBao = "PhieuThuHoi",
                    NgayTao = DateTime.Now
                };
                _context.ThongBaos.Add(thongBaoPhieu);

                hopDong.TrangThai = "DaKetThuc";
                hopDong.NgayKetThucThucTe = DateTime.Now;

                // 3. Xử lý Trạng thái Máy & Thông báo bảo trì
                foreach (var ct in hopDong.ChiTietHopDongs)
                {
                    var thietBi = await _context.ThietBis.FindAsync(ct.MaThietBi);
                    if (thietBi != null)
                    {
                        string trangThaiCu = thietBi.TrangThai;
                        string trangThaiMoi = dto.CoHuHong ? "BaoTri" : "SanSang";

                        thietBi.TrangThai = trangThaiMoi;

                        // 🔥 THAY THẾ TRIGGER 2: Thông báo thiết bị hỏng cần bảo trì
                        if (trangThaiMoi == "BaoTri")
                        {
                            var thongBaoBaoTri = new ThongBao
                            {
                                TieuDe = "Thiết bị bảo trì",
                                NoiDung = $"Thiết bị '{thietBi.TenThietBi}' đã chuyển sang trạng thái bảo trì",
                                LoaiThongBao = "BaoTri",
                                NgayTao = DateTime.Now
                            };
                            _context.ThongBaos.Add(thongBaoBaoTri);
                        }

                        // Ghi nhận lịch sử nhập kho
                        _context.LichSuLuanChuyens.Add(new LichSuLuanChuyen
                        {
                            MaThietBi = thietBi.MaThietBi,
                            LoaiLuanChuyen = trangThaiMoi == "BaoTri" ? "DiBaoTri" : "NhapHoi",
                            MaHopDongLienQuan = hopDong.MaHopDong,
                            TrangThaiTruoc = trangThaiCu,
                            TrangThaiSau = trangThaiMoi,
                            MaNguoiThucHien = currentUserId,
                            GhiChu = dto.GhiChuHuHong,
                            NgayTao = DateTime.Now
                        });
                    }
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                var resultDto = _mapper.Map<PhieuThuHoiDto>(phieu);
                return Ok(resultDto);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return StatusCode(500, new { detail = ex.InnerException?.Message ?? ex.Message });
            }
        }

        // Hàm Helper lấy ID người dùng từ Token
        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (userIdClaim == null) return 0;
            return int.Parse(userIdClaim);
        }
    }
}