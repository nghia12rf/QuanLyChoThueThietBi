using System;
using System.Collections.Generic;

namespace QuanLyChoThueThietBi.Models;

public partial class ThongBao
{
    public int MaThongBao { get; set; }

    public string TieuDe { get; set; } = null!;

    public string NoiDung { get; set; } = null!;

    public string LoaiThongBao { get; set; } = null!;

    public bool DaDoc { get; set; }

    public DateTime? NgayTao { get; set; }
}
