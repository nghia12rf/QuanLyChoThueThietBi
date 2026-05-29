using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuanLyChoThueThietBi.Models;
using RentalEquipmentAPI.DTOs;
using AutoMapper;
using AutoMapper.QueryableExtensions;

namespace RentalEquipmentAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
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
    }
}