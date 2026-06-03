using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuanLyChoThueThietBi.Models;
using System;

[Route("api/[controller]")]
[ApiController]
public class NguoiDungController : ControllerBase
{
    private readonly QuanLyChoThueThietBiContext _context;

    public NguoiDungController(QuanLyChoThueThietBiContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var data = await _context.NguoiDungs
            .OrderByDescending(x => x.MaNguoiDung)
            .Select(x => new
            {
                x.MaNguoiDung,
                x.TenDangNhap,
                x.HoTen,
                x.Email,
                x.VaiTro,
                x.TrangThaiHoatDong,
                x.NgayTao
            })
            .ToListAsync();

        return Ok(data);
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateNguoiDungDto dto)
    {
        var exists = await _context.NguoiDungs
            .AnyAsync(x => x.TenDangNhap == dto.TenDangNhap);

        if (exists)
        {
            return BadRequest(new { message = "Tên đăng nhập đã tồn tại" });
        }

        var nguoiDung = new NguoiDung
        {
            TenDangNhap = dto.TenDangNhap,
            MatKhauHash = dto.MatKhau,
            HoTen = dto.HoTen,
            Email = dto.Email,
            VaiTro = dto.VaiTro,
            TrangThaiHoatDong = true,
            NgayTao = DateTime.Now
        };

        _context.NguoiDungs.Add(nguoiDung);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Tạo tài khoản thành công" });
    }

    [HttpPut("{id}/TrangThai")]
    public async Task<IActionResult> UpdateStatus(
        int id,
        UpdateTrangThaiNguoiDungDto dto
    )
    {
        var nguoiDung = await _context.NguoiDungs.FindAsync(id);

        if (nguoiDung == null)
        {
            return NotFound(new { message = "Không tìm thấy người dùng" });
        }

        nguoiDung.TrangThaiHoatDong = dto.TrangThaiHoatDong;
        await _context.SaveChangesAsync();

        return Ok(new { message = "Cập nhật trạng thái thành công" });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, UpdateNguoiDungDto dto)
    {
        var nguoiDung = await _context.NguoiDungs.FindAsync(id);

        if (nguoiDung == null)
        {
            return NotFound(new { message = "Không tìm thấy người dùng" });
        }

        nguoiDung.HoTen = dto.HoTen;
        nguoiDung.Email = dto.Email;
        nguoiDung.VaiTro = dto.VaiTro;

        await _context.SaveChangesAsync();

        return Ok(new { message = "Cập nhật tài khoản thành công" });
    }

    [HttpPut("{id}/ResetMatKhau")]
    public async Task<IActionResult> ResetPassword(int id, ResetMatKhauNguoiDungDto dto)
    {
        var nguoiDung = await _context.NguoiDungs.FindAsync(id);

        if (nguoiDung == null)
        {
            return NotFound(new { message = "Không tìm thấy người dùng" });
        }

        if (string.IsNullOrWhiteSpace(dto.MatKhauMoi) || dto.MatKhauMoi.Length < 6)
        {
            return BadRequest(new { message = "Mật khẩu mới phải có ít nhất 6 ký tự" });
        }

        nguoiDung.MatKhauHash = dto.MatKhauMoi;

        await _context.SaveChangesAsync();

        return Ok(new { message = "Reset mật khẩu thành công" });
    }
}