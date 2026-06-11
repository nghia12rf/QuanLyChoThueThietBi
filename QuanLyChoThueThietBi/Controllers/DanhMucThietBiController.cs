using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuanLyChoThueThietBi.Models;
using RentalEquipmentAPI.DTOs;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.AspNetCore.Authorization;

namespace RentalEquipmentAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Yêu cầu đăng nhập (Bearer Token)
    public class DanhMucThietBiController : ControllerBase
    {
        private readonly QuanLyChoThueThietBiContext _context;
        private readonly IMapper _mapper;

        public DanhMucThietBiController(QuanLyChoThueThietBiContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/DanhMucThietBi
        [HttpGet]
        public async Task<ActionResult<IEnumerable<DanhMucThietBiDto>>> GetDanhMucs()
        {
            // Lấy danh sách Máy ảnh, Ống kính... từ SQL
            return await _context.DanhMucThietBis
                .ProjectTo<DanhMucThietBiDto>(_mapper.ConfigurationProvider)
                .ToListAsync();
        }

        // GET: api/DanhMucThietBi/5
        [HttpGet("{id}")]
        public async Task<ActionResult<DanhMucThietBiDto>> GetDanhMuc(int id)
        {
            var dto = await _context.DanhMucThietBis
                .Where(x => x.MaDanhMuc == id)
                .ProjectTo<DanhMucThietBiDto>(_mapper.ConfigurationProvider)
                .FirstOrDefaultAsync();

            if (dto == null) 
                return NotFound(new { Message = $"Không tìm thấy danh mục ID: {id}" });

            return Ok(dto);
        }

        // POST: api/DanhMucThietBi
        [HttpPost]
        [Authorize(Roles = "Admin")] // Chỉ Admin mới được thêm
        public async Task<ActionResult<DanhMucThietBiDto>> PostDanhMuc([FromBody] DanhMucThietBiDto dto)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(dto.TenDanhMuc))
                    return BadRequest(new { Message = "Tên danh mục không được để trống!" });

                var entity = _mapper.Map<DanhMucThietBi>(dto);

                _context.DanhMucThietBis.Add(entity);
                await _context.SaveChangesAsync();

                var result = _mapper.Map<DanhMucThietBiDto>(entity);
                return CreatedAtAction(nameof(GetDanhMuc), new { id = entity.MaDanhMuc }, result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống", Error = ex.Message });
            }
        }

        // PUT: api/DanhMucThietBi/5
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")] // Chỉ Admin mới được sửa
        public async Task<IActionResult> PutDanhMuc(int id, [FromBody] DanhMucThietBiDto dto)
        {
            if (id != dto.MaDanhMuc) 
                return BadRequest(new { Message = $"ID trên URL ({id}) và ID trong dữ liệu ({dto.MaDanhMuc}) không khớp nhau!" });

            if (string.IsNullOrWhiteSpace(dto.TenDanhMuc))
                return BadRequest(new { Message = "Tên danh mục không được để trống!" });

            var entity = await _context.DanhMucThietBis.FindAsync(id);
            if (entity == null) 
                return NotFound(new { Message = "Không tìm thấy danh mục để cập nhật" });

            _mapper.Map(dto, entity);

            try
            {
                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = "Không thể cập nhật", Error = ex.Message });
            }
        }

        // DELETE: api/DanhMucThietBi/5
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")] // Chỉ Admin mới được xóa
        public async Task<IActionResult> DeleteDanhMuc(int id)
        {
            var entity = await _context.DanhMucThietBis.FindAsync(id);
            if (entity == null) 
                return NotFound(new { Message = "Không tìm thấy danh mục" });

            // Kiểm tra xem danh mục có đang chứa thiết bị nào không (tránh lỗi khóa ngoại)
            var coThietBi = await _context.ThietBis.AnyAsync(t => t.MaDanhMuc == id);
            if (coThietBi) 
                return BadRequest(new { Message = "Không thể xóa danh mục đang có thiết bị!" });

            _context.DanhMucThietBis.Remove(entity);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}