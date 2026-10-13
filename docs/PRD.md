# PRD — Tài Liệu Yêu Cầu Sản Phẩm
## Hệ Thống Thuyết Minh Tự Động Đa Ngôn Ngữ
> **Môn học:** Đồ Án Chuyên Ngành  
> **Giảng viên:** Thầy Nguyễn Quốc Huy  
> **Nhóm phụ trách:** Mục số 3 — BE Dev + Services + CI/CD  
> **Phiên bản:** 1.0 | Ngày: 10/2026
---
## 1. Tổng Quan Sản Phẩm
### 1.1 Mục Tiêu
Xây dựng hệ thống backend microservices và ứng dụng Android đơn giản cho phép du khách tự động nhận thuyết minh âm thanh đa ngôn ngữ khi tiếp cận các điểm tham quan du lịch, sử dụng GPS/Geofencing và mã QR.
### 1.2 Phạm Vi
| Trong Phạm Vi | Ngoài Phạm Vi |
|:---|:---|
| 3 Microservices Spring Boot | Thuật toán chỉ đường turn-by-turn |
| Ứng dụng Android (đơn giản) | Thiết kế UI/UX phức tạp |
| CI/CD với GitHub Actions | Thanh toán / thương mại điện tử |
| PostgreSQL + PostGIS + Redis + RabbitMQ + MinIO | Nhận dạng giọng nói (Speech Recognition) |
| CMS Admin Dashboard | Ứng dụng iOS |
### 1.3 Các Bên Liên Quan (Stakeholders)
| Vai Trò | Mô Tả |
|:---|:---|
| **Du Khách** | Người dùng cuối — sử dụng app Android |
| **Quản Trị Viên** | Nhân viên quản lý nội dung qua CMS |
| **Hệ Thống** | Các tiến trình tự động (Geofence, TTS, Cooldown) |
---
## 2. Yêu Cầu Chức Năng — 8 Use Cases
### UC01 — Xem Bản Đồ và Vị Trí GPS Thời Gian Thực
- **Actor:** Du Khách
- **Mô tả:** Người dùng mở app → thấy bản đồ hiển thị vị trí hiện tại + các điểm tham quan lân cận
- **Luồng chính:**
  1. App xin quyền GPS
  2. Lấy tọa độ từ GPS điện thoại
  3. Hiển thị vị trí trên Google Maps
  4. Gọi API lấy danh sách POI trong bán kính 500m
  5. Vẽ marker cho từng POI trên bản đồ
- **Điều kiện:** Có kết nối mạng, GPS bật
### UC02 — Nhận Thuyết Minh Tự Động qua Geofence
- **Actor:** Du Khách + Hệ Thống
- **Mô tả:** Khi du khách bước vào vùng bán kính 30m quanh POI, hệ thống tự động phát audio thuyết minh
- **Luồng chính:**
  1. App gửi tọa độ GPS lên tracking-service mỗi 3 giây
  2. tracking-service lọc tín hiệu nhiễu (accuracy > 25m → bỏ)
  3. trigger-engine kiểm tra khoảng cách đến POI (Redis GEO)
  4. Kiểm tra cooldown (đã nghe POI này trong 5 phút chưa?)
  5. Nếu đủ điều kiện → gửi lệnh phát audio về app
  2. Xem biểu đồ top 10 POI được nghe nhiều nhất
  3. Xem phân bổ theo ngôn ngữ
  4. Xem bản đồ nhiệt (heatmap) từ user_trajectories
  - **Luồng thay thế:** Nếu đang trong cooldown → bỏ qua, không phát lại
### UC03 — Nghe Nội Dung Thuyết Minh Đa Ngôn Ngữ
- **Actor:** Du Khách
- **Mô tả:** App phát file âm thanh .mp3 theo ngôn ngữ du khách đã chọn (vi/en/fr/ja/zh)
- **Luồng chính:**
  1. Nhận URL audio từ backend
  2. ExoPlayer stream file từ MinIO
  3. Hiển thị tên POI + hình ảnh trong khi nghe
  4. Ghi nhận lịch sử nghe vào usage_history
### UC04 — Quét Mã QR Kích Hoạt Thuyết Minh Tức Thì
- **Actor:** Du Khách
- **Mô tả:** Du khách quét mã QR tại biển hiệu trạm xe buýt → nghe thuyết minh ngay, không cần GPS
- **Luồng chính:**
  1. Mở camera quét QR
  2. Đọc token từ mã QR
  3. Gọi `GET /api/v1/pois/qr/{token}?lang=vi`
  4. Nhận URL audio → phát ngay
  5. Ghi `trigger_type = 'QR_CODE'` vào lịch sử
### UC05 — Xem Thống Kê và Phân Tích Lượt Nghe (Admin)
- **Actor:** Quản Trị Viên
- **Mô tả:** Admin xem dashboard thống kê: POI nào được nghe nhiều nhất, ngôn ngữ nào phổ biến, heatmap vị trí du khách
- **Luồng chính:**
  1. Admin đăng nhập CMS
  2. Xem biểu đồ top 10 POI được nghe nhiều nhất
  3. Xem phân bổ theo ngôn ngữ
  4. Xem bản đồ nhiệt (heatmap) từ user_trajectories
### UC06 — Quản Lý Nội Dung Điểm Tham Quan (CMS)
- **Actor:** Quản Trị Viên
- **Mô tả:** Admin thêm/sửa/xóa POI và nội dung thuyết minh đa ngôn ngữ
- **Luồng chính:**
  1. Admin nhập thông tin POI (tên, tọa độ, bán kính, ảnh)
  2. Upload file audio .mp3 cho từng ngôn ngữ lên MinIO
  3. Nhập kịch bản TTS (tts_script) nếu không có file audio
  4. Bật/tắt POI
  5. Sắp xếp POI vào tuyến tham quan (tour)
### UC07 — Chọn Ngôn Ngữ Thuyết Minh
- **Actor:** Du Khách
- **Mô tả:** Người dùng chọn ngôn ngữ mong muốn trong phần Settings
- **Luồng chính:**
  1. Vào màn hình Cài đặt
  2. Chọn ngôn ngữ: Tiếng Việt / English / Français / 日本語 / 中文
  3. App lưu lựa chọn vào SharedPreferences
  4. Tất cả audio/nội dung sau đó phát theo ngôn ngữ đã chọn
### UC08 — Xem Chi Tiết và Lịch Sử Điểm Tham Quan
- **Actor:** Du Khách
- **Mô tả:** Nhấn vào marker POI trên bản đồ để xem thông tin chi tiết và nghe lại
- **Luồng chính:**
  1. Nhấn vào marker POI trên bản đồ
  2. Hiện popup: tên, ảnh, mô tả ngắn, nút "Nghe thuyết minh"
  3. Xem màn hình Lịch sử: danh sách POI đã nghe
---
## 3. Yêu Cầu Phi Chức Năng
| Tiêu Chí | Yêu Cầu |
|:---|:---|
| **Độ trễ GPS trigger** | < 5 giây từ lúc vào vùng đến khi phát audio |
| **Tìm kiếm POI** | Redis GEOSEARCH < 10ms |
| **Đọc Database** | PostgreSQL query < 100ms |
| **Đồng thời** | Hỗ trợ 50 người dùng cùng lúc (demo) |
| **Độ chính xác GPS** | Lọc bỏ tín hiệu accuracy > 25m |
| **Chống spam** | Cooldown 5 phút / POI / người dùng |
---
## 4. Kiến Trúc Hệ Thống
```
[Android App]
     │ GPS every 3s          │ QR Token          │ Stream audio
     ▼                       ▼                   ▼
[tracking-service:8082] [cms-service:8081]   [MinIO:9000]
     │ RabbitMQ
     ▼
[trigger-engine:8083]
     │ Redis (GEO + TTL)
     │ REST → cms-service
     ▼
[Android: Phát audio]
```
  ### 4.1 Các Service và Trách Nhiệm
| Service | Cổng | Trách Nhiệm Chính |
|:---|:---:|:---|
| `cms-service` | 8081 | Quản lý POI, bản dịch, CMS dashboard |
| `tracking-service` | 8082 | Nhận GPS, lọc nhiễu, publish sự kiện |
| `trigger-engine` | 8083 | Geofence check, cooldown, audio resolve |
### 4.2 Hạ Tầng
| Thành Phần | Vai Trò |
|:---|:---|
| PostgreSQL + PostGIS | Lưu trữ dữ liệu không gian POI |
| Redis | GEO cache POI + Cooldown TTL |
| RabbitMQ | Async message giữa tracking → trigger |
| MinIO | Lưu trữ file audio .mp3 (S3-compatible) |
---
## 5. Danh Sách API Chính
### cms-service (8081)
```
GET    /api/v1/pois                    # Lấy danh sách POI
GET    /api/v1/pois/{id}               # Chi tiết POI
GET    /api/v1/pois/qr/{token}         # Lấy POI qua QR code
POST   /api/v1/admin/pois              # Thêm POI mới (Admin)
PUT    /api/v1/admin/pois/{id}         # Cập nhật POI (Admin)
DELETE /api/v1/admin/pois/{id}         # Xóa POI (Admin)
GET    /api/v1/admin/analytics/top-pois # Top POI nghe nhiều nhất
GET    /api/v1/admin/analytics/heatmap  # Dữ liệu heatmap
```
### tracking-service (8082)
```
POST   /api/v1/locations               # Nhận tọa độ GPS từ app
```
### trigger-engine (8083)
```
# Internal service — không expose ra ngoài
# Nhận từ RabbitMQ, gọi nội bộ
```
---
## 6. Lịch Trình
| Tuần | Mục Tiêu |
|:---:|:---|
| 1-2 | Setup Docker, Database schema, Spring Boot skeleton |
| 3-4 | cms-service: CRUD POI API hoàn chỉnh |
| 5-6 | tracking-service + trigger-engine: Luồng Geofence |
| 7 | **Kiểm tra giữa kỳ** — Demo luồng GPS → Audio |
| 8-9 | Android App: Map, GPS, Audio Player |
| 10-11 | QR Code, CMS Dashboard, CI/CD |
| 11-12 | **Báo cáo cuối kỳ** — Demo đầy đủ |