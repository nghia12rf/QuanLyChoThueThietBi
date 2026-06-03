namespace QuanLyChoThueThietBi.DTOs
{
    public class ThongBaoDto
    {
        public int MaThongBao { get; set; }
        public string TieuDe { get; set; } = string.Empty;
        public string NoiDung { get; set; } = string.Empty;
        public string LoaiThongBao { get; set; } = string.Empty;
        public bool DaDoc { get; set; }
        public DateTime NgayTao { get; set; }
    }
}