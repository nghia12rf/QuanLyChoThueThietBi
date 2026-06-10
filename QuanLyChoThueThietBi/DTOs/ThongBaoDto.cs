using System;

namespace RentalEquipmentAPI.DTOs
{
    public class ThongBaoDto
    {
        public int MaThongBao { get; set; }
        public string TieuDe { get; set; } = null!;
        public string NoiDung { get; set; } = null!;
        public string LoaiThongBao { get; set; } = null!;
        public bool DaDoc { get; set; }
        public DateTime? NgayTao { get; set; }
    }
}
