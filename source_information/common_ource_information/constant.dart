//Người dùng api
const String API_NGUOI_DUNG = "/api/nguoidung/get/page?";
//Trạng thái của thực tập sinh
const String TTS_TRANG_THAI = "/api/tts-trangthai/get/page?";
//Đơn hang thực tập sinh tiến cử
const String DON_HANG_TTS_TIEN_CU_GET = "/api/donhang-tts-tiencu/get/page?";
const String DON_HANG_TTS_TIEN_CU_POST = '/api/donhang-tts-tiencu/post/save';
//Đơn hàng
const String DON_HANG_GET_PAGE = '/api/donhang/get/page?';
//Quốc gia
const String API_QUOC_GIA_GET = '/api/quocgia/get/page?';
//Bằng cấp chứng chỉ
const String API_BANG_CAP_CHUNG_CHI_GET = '/api/bangcap-chungchi/get/page?';
//Dân tộc
const String API_DAN_TOC_GET = '/api/dantoc/get/page?';
//Form chi tiết
const String API_FORM_CHI_TIET_GET = '/api/tts-form-chitiet/get/page?';
const String API_FORM_CHI_TIET_POST = '/api/tts-form-chitiet/post/save';
//Kinh nghiệm làm việc
const String API_TTS_KINH_NGHIEM_LAM_VIEC_GET = '/api/tts-kinhnghiemlamviec/get/page?';
//QUá trình học tập
const String API_QUA_TRINH_HOC_TAP_SAVEALL_POST = "/api/tts-quatrinhhoctap/post/saveAll";

//----------------api bắn đi thông báo-----------
//Thông báo đến phòng ban
const String API_THONG_BAO_PHONG_BAN_POST = '/api/push/tags/depart_id/';
//Thông báo cho từng cá nhân
const String API_THONG_BAO_CA_NHAN_POST = '/api/push/tags/user_code/';
//Thông báo cho trưởng phòng giám đôc các cấp
const String API_THONG_BAO_CAP_TREN = '/api/push/duty/';//Gửi thông báo cho trưởng phòng giám đốc theo điều kiện

//-------------------------------- URL-----------------------------------
const String THONG_TIN_NGUON = "/thong-tin-nguon";
// Thực tập sinh url
const String QUAN_LY_THONG_TIN_TTS = "/quan-ly-thong-tin-thuc-tap-sinh"; //Trang chính thực tập sinh
const String THEM_MOI_CAP_NHAT_TTS = "/them-moi-cap-nhat-thuc-tap-sinh"; //Thêm mới cập nhật thực tập sinh
const String VIEW_THONG_TIN_TTS = "/view-thong-tin-thuc-tap-sinh"; //Xem chi tiết thông tin thực tập sinh

//-------------------------------CTV---------------------------------
//Cộng tác viên url
const String QUAN_LY_CTV = '/quan-ly-cong-tac-vien'; //Trang chính cộng tác viên
//Cập nhật cộng tác viên
const String URL_CAP_NHAT_CTV = '/cap-nhat-cong-tac-vien';
//Thông tin cộng tác viên
const String URL_XEM_CHI_TIET_THONG_TIN = '/thong-tin-cong-tac-vien';

//-------------------------------DON HANG---------------------------------
//Đơn hàng thông tin nguon
const String DANH_SACH_DON_HANG_TTN = '/danh-sach-don-hang-ttn'; //Danh sách đơn hàng
//Quản lý chương trình khuyến mãi
const String QUAN_LY_CHUONG_TRINH_KHUYEN_MAI = '/quan-ly-chuong-trinh-khuyen-mai'; //Quản lý chương trình khuyến mãi
//Cấu hình tính thưởng
const String CAU_HINH_TINH_THUONG_TTN = '/cau-hinh-tinh-thuong-ttn'; //Cấu hình tính thưởng
//Báo cáo thống kê
const String BAO_CAO_THONG_KE_TTN = '/bao-cao-thong-ke-ttn'; //Báo cáo thống kê thông tin nguồn

//----------------------------------Thông báo---------------
const String ER_CAP_NHAT_THANH_CONG = "Cập nhật thành công";
const String ER_CAP_NHAT_THAT_BAI = "Cập nhật thất bại";
const String ER_THEM_MOI_THANH_CONG = "Thêm mới thành công";
const String ER_THEM_MOI_THAT_BAI = "Thêm mới thất bại";
const String TOOLIP_XEM_CHI_TIET = "Xem chi tiết";
const String TOOLIP_CAP_NHAT = "Cập nhật thông tin";
const String TOOLIP_XOA = "Xóa thông tin";
const String TOOLIP_XOA_NGUOI_DUNG = "Xóa";
const String TOOLIP_TTS_TAM_DUNG_XL = "TTS Tạm dừng xử lý";
const String TOOLIP_TTS_DUNG_XL = " TTS Đã dừng xử lý";

//--------------------Thông báo hệ thống------------------
const String TIEU_DE_THONG_BAO = "Hệ thống thông báo";
const String TIEU_DE_THONG_BAO_TU_THONG_TIN_NGUON = "Thông báo từ Thông tin nguồn";
const String TIEU_DE_THONG_BAO_TU_AAM = "Thông báo từ AAM";
