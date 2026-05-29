using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using QuanLyChoThueThietBi.Models;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using RentalEquipmentAPI.DTOs;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class PhieuThuHoiController : ControllerBase
{
    private readonly QuanLyChoThueThietBiContext _context;
    private readonly IMapper _mapper;
    private const decimal TIEN_PHAT_MOI_NGAY = 100000;

    public PhieuThuHoiController(QuanLyChoThueThietBiContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;

    }
    private int GetCurrentUserId()
    {
        // Lấy ID người dùng từ Claim "nameidentifier" trong Token JWT
        var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (userIdClaim == null) return 0;
        return int.Parse(userIdClaim);
    }

    [HttpPost]
    public async Task<ActionResult> PostPhieuThuHoi(PhieuThuHoiCreateDto dto)
    {
        using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            // 1. Tạo phiếu thu hồi
            var phieu = _mapper.Map<PhieuThuHoi>(dto);
            phieu.MaNguoiNhan = GetCurrentUserId(); // Lấy từ Token
            _context.PhieuThuHois.Add(phieu);

            // 2. Cập nhật Hợp đồng
            var hopDong = await _context.HopDongs.Include(h => h.ChiTietHopDongs).FirstOrDefaultAsync(h => h.MaHopDong == dto.MaHopDong);
            if (hopDong != null)
            {
                hopDong.TrangThai = "DaKetThuc";
                hopDong.NgayKetThucThucTe = DateTime.Now;
            }

            // 3. TỰ ĐỘNG CẬP NHẬT TRẠNG THÁI MÁY
            foreach (var ct in hopDong.ChiTietHopDongs)
            {
                var thietBi = await _context.ThietBis.FindAsync(ct.MaThietBi);
                if (thietBi != null)
                {
                    // Nếu nhân viên báo hỏng -> Bảo trì, nếu không -> Sẵn sàng
                    thietBi.TrangThai = dto.CoHuHong ? "BaoTri" : "SanSang";
                }
            }

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();
            return Ok(new { message = "Thu hồi thành công!" });
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync();
            return StatusCode(500, ex.Message);

        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<PhieuThuHoiDto>> GetPhieuThuHoi(int id)
    {
        var phieu = await _context.PhieuThuHois.FindAsync(id);
        if (phieu == null) return NotFound();
        return Ok(_mapper.Map<PhieuThuHoiDto>(phieu));
    }
}