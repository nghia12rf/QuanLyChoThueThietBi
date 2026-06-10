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
    public class ThongBaoController : ControllerBase
    {
        private readonly QuanLyChoThueThietBiContext _context;
        private readonly IMapper _mapper;

        public ThongBaoController(QuanLyChoThueThietBiContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/ThongBao
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ThongBaoDto>>> GetThongBaos()
        {
            try
            {
                var dtos = await _context.ThongBaos
                    .ProjectTo<ThongBaoDto>(_mapper.ConfigurationProvider)
                    .OrderByDescending(n => n.NgayTao)
                    .ToListAsync();
                return Ok(dtos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi lấy danh sách thông báo", Error = ex.Message });
            }
        }

        // GET: api/ThongBao/ThongKe
        [HttpGet("ThongKe")]
        public async Task<IActionResult> GetThongKe()
        {
            try
            {
                var tongThongBao = await _context.ThongBaos.CountAsync();
                var thongBaoChuaDoc = await _context.ThongBaos.CountAsync(t => !t.DaDoc);
                var thongBaoDaDoc = tongThongBao - thongBaoChuaDoc;

                return Ok(new
                {
                    tongThongBao,
                    thongBaoChuaDoc,
                    thongBaoDaDoc
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi thống kê thông báo", Error = ex.Message });
            }
        }

        // PUT: api/ThongBao/5/DaDoc
        [HttpPut("{id}/DaDoc")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            try
            {
                var entity = await _context.ThongBaos.FindAsync(id);
                if (entity == null) return NotFound(new { Message = $"Không tìm thấy thông báo ID: {id}" });

                entity.DaDoc = true;
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống khi cập nhật thông báo", Error = ex.Message });
            }
        }

        // PUT: api/ThongBao/DocTatCa
        [HttpPut("DocTatCa")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            try
            {
                var unread = await _context.ThongBaos.Where(t => !t.DaDoc).ToListAsync();
                foreach (var item in unread)
                {
                    item.DaDoc = true;
                }
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống khi cập nhật tất cả thông báo", Error = ex.Message });
            }
        }

        // DELETE: api/ThongBao/XoaDaDoc
        [HttpDelete("XoaDaDoc")]
        public async Task<IActionResult> DeleteReadNotifications()
        {
            try
            {
                var readNotifications = await _context.ThongBaos.Where(t => t.DaDoc).ToListAsync();
                if (readNotifications.Any())
                {
                    _context.ThongBaos.RemoveRange(readNotifications);
                    await _context.SaveChangesAsync();
                }
                return Ok(new { Message = $"Đã xóa {readNotifications.Count} thông báo đã đọc." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống khi xóa thông báo đã đọc", Error = ex.Message });
            }
        }

        // DELETE: api/ThongBao/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteNotification(int id)
        {
            try
            {
                var entity = await _context.ThongBaos.FindAsync(id);
                if (entity == null) return NotFound(new { Message = $"Không tìm thấy thông báo ID: {id}" });

                _context.ThongBaos.Remove(entity);
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống khi xóa thông báo", Error = ex.Message });
            }
        }
    }
}
