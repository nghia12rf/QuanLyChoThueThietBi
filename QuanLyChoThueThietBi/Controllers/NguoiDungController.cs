using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuanLyChoThueThietBi.Models;
using RentalEquipmentAPI.DTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace RentalEquipmentAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class NguoiDungController : ControllerBase
    {
        private readonly QuanLyChoThueThietBiContext _context;
        private readonly IMapper _mapper;

        public NguoiDungController(QuanLyChoThueThietBiContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/NguoiDung
        [HttpGet]
        public async Task<ActionResult<IEnumerable<NguoiDungDto>>> GetNguoiDungs()
        {
            try
            {
                var dtos = await _context.NguoiDungs
                    .ProjectTo<NguoiDungDto>(_mapper.ConfigurationProvider)
                    .ToListAsync();
                return Ok(dtos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi lấy danh sách người dùng", Error = ex.Message });
            }
        }

        // POST: api/NguoiDung
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<NguoiDungDto>> PostNguoiDung([FromBody] NguoiDungCreateDto dto)
        {
            try
            {
                var exists = await _context.NguoiDungs.AnyAsync(u => u.TenDangNhap == dto.TenDangNhap);
                if (exists)
                {
                    return BadRequest(new { Message = "Tên đăng nhập đã tồn tại!" });
                }

                var entity = _mapper.Map<NguoiDung>(dto);
                entity.TrangThaiHoatDong = true;
                entity.NgayTao = DateTime.Now;

                _context.NguoiDungs.Add(entity);
                await _context.SaveChangesAsync();

                var result = _mapper.Map<NguoiDungDto>(entity);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống khi tạo người dùng", Error = ex.Message });
            }
        }

        // PUT: api/NguoiDung/5
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> PutNguoiDung(int id, [FromBody] NguoiDungUpdateDto dto)
        {
            try
            {
                var entity = await _context.NguoiDungs.FindAsync(id);
                if (entity == null) return NotFound(new { Message = $"Không tìm thấy người dùng ID: {id}" });

                entity.HoTen = dto.HoTen;
                entity.Email = dto.Email;
                entity.VaiTro = dto.VaiTro;

                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống khi cập nhật người dùng", Error = ex.Message });
            }
        }

        // PUT: api/NguoiDung/5/TrangThai
        [HttpPut("{id}/TrangThai")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> PutTrangThai(int id, [FromBody] NguoiDungUpdateStatusDto dto)
        {
            try
            {
                var entity = await _context.NguoiDungs.FindAsync(id);
                if (entity == null) return NotFound(new { Message = $"Không tìm thấy người dùng ID: {id}" });

                entity.TrangThaiHoatDong = dto.TrangThaiHoatDong;

                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống khi cập nhật trạng thái người dùng", Error = ex.Message });
            }
        }

        // PUT: api/NguoiDung/5/ResetMatKhau
        [HttpPut("{id}/ResetMatKhau")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ResetMatKhau(int id, [FromBody] NguoiDungResetPasswordDto dto)
        {
            try
            {
                var entity = await _context.NguoiDungs.FindAsync(id);
                if (entity == null) return NotFound(new { Message = $"Không tìm thấy người dùng ID: {id}" });

                entity.MatKhauHash = dto.MatKhauMoi;

                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống khi đặt lại mật khẩu", Error = ex.Message });
            }
        }
    }
}
