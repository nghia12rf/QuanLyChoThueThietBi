using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuanLyChoThueThietBi.DTOs;
using QuanLyChoThueThietBi.Models;

namespace QuanLyChoThueThietBi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ThongBaoController : ControllerBase
    {
        private readonly QuanLyChoThueThietBiContext _context;

        public ThongBaoController(QuanLyChoThueThietBiContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ThongBaoDto>>> GetThongBao()
        {
            var data = await _context.ThongBaos
                .OrderByDescending(x => x.NgayTao)
                .Select(x => new ThongBaoDto
                {
                    MaThongBao = x.MaThongBao,
                    TieuDe = x.TieuDe,
                    NoiDung = x.NoiDung,
                    LoaiThongBao = x.LoaiThongBao,
                    DaDoc = x.DaDoc,
                    NgayTao = x.NgayTao
                })
                .ToListAsync();

            return Ok(data);
        }

        [HttpGet("ThongKe")]
        public async Task<IActionResult> GetThongKe()
        {
            var tong = await _context.ThongBaos.CountAsync();
            var chuaDoc = await _context.ThongBaos.CountAsync(x => !x.DaDoc);
            var daDoc = await _context.ThongBaos.CountAsync(x => x.DaDoc);

            return Ok(new
            {
                tongThongBao = tong,
                thongBaoChuaDoc = chuaDoc,
                thongBaoDaDoc = daDoc
            });
        }

        [HttpPut("{id}/DaDoc")]
        public async Task<IActionResult> DanhDauDaDoc(int id)
        {
            var thongBao = await _context.ThongBaos.FindAsync(id);

            if (thongBao == null)
            {
                return NotFound(new { message = "Không tìm thấy thông báo" });
            }

            thongBao.DaDoc = true;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã đánh dấu đã đọc" });
        }

        [HttpPut("DocTatCa")]
        public async Task<IActionResult> DocTatCa()
        {
            var list = await _context.ThongBaos
                .Where(x => !x.DaDoc)
                .ToListAsync();

            foreach (var item in list)
            {
                item.DaDoc = true;
            }

            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã đọc tất cả thông báo" });
        }
    }
}