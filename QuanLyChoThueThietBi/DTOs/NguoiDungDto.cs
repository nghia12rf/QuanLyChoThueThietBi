using System;

namespace RentalEquipmentAPI.DTOs
{
    public class NguoiDungDto
    {
        public int MaNguoiDung { get; set; }
        public string TenDangNhap { get; set; } = null!;
        public string HoTen { get; set; } = null!;
        public string? Email { get; set; }
        public string VaiTro { get; set; } = null!;
        public bool TrangThaiHoatDong { get; set; }
        public DateTime? NgayTao { get; set; }
    }

    public class NguoiDungCreateDto
    {
        public string TenDangNhap { get; set; } = null!;
        public string MatKhau { get; set; } = null!;
        public string HoTen { get; set; } = null!;
        public string? Email { get; set; }
        public string VaiTro { get; set; } = null!;
    }

    public class NguoiDungUpdateDto
    {
        public string HoTen { get; set; } = null!;
        public string? Email { get; set; }
        public string VaiTro { get; set; } = null!;
    }

    public class NguoiDungUpdateStatusDto
    {
        public bool TrangThaiHoatDong { get; set; }
    }

    public class NguoiDungResetPasswordDto
    {
        public string MatKhauMoi { get; set; } = null!;
    }
}
