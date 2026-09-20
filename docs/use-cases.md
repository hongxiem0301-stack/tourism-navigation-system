# FOCUSED USE CASES SPECIFICATION

## I. TRACEABILITY MATRIX (MA TRẬN TRUY XUẤT)

| Feature gốc | Use Case ID | Use Case Name | Actor chính | Mô tả ngắn |
| :--- | :--- | :--- | :--- | :--- |
| **Feature 1** | **UC01** | Explore Nearby POIs | Visitor | Tự động định vị GPS, tìm kiếm và hiển thị các điểm POI lân cận theo bán kính. |
| **Feature 2** | **UC02** | Plan & Customize Route | Visitor | Gợi ý tuyến đường qua nhiều POI, hỗ trợ kéo thả thay đổi thứ tự và chỉ đường. |
| **Feature 3** | **UC03** | Listen to Multilingual Audio Tour | Visitor | Chọn ngôn ngữ, phát audio thuyết minh tự động hoặc chủ động khi tiếp cận POI. |
| **Feature 4 & 3** | **UC04** | Manage POI Data & Trigger Pipeline | Admin / Staff | Thêm/sửa POI và kích hoạt bất đồng bộ Data Pipeline (dịch 15+ ngôn ngữ & sinh TTS). |
| **Feature 5** | **UC05** | Manage Operating Sessions | Admin / Staff | Tạo, lên lịch và quản lý các phiên hoạt động/tour tham quan cho khách hàng. |
| **Feature 6** | **UC06** | Monitor System Health & Usage | Admin / Staff | Theo dõi chỉ số hệ thống (CPU, RAM, Latency, Error Rate) theo thời gian thực. |

---

## II. ĐẶC TẢ CHI TIẾT CÁC USE CASES

---

### UC01: Explore Nearby POIs
* **Feature liên quan:** Feature 1 - Map Navigation & Proximity POIs
* **Actor chính:** Visitor / Khách du lịch
* **Mô tả:** Hệ thống sử dụng GPS của thiết bị để xác định vị trí hiện tại của khách du lịch, thực hiện truy vấn không gian (Spatial Query) để tìm và hiển thị danh sách các POI nằm trong bán kính quy định lên bản đồ.
* **Điều kiện tiên quyết (Preconditions):**
  1. Khách du lịch đã mở ứng dụng.
  2. Thiết bị đã bật dịch vụ vị trí (GPS) và cho phép ứng dụng truy cập quyền vị trí.
* **Kết quả đầu ra (Postconditions):**
  1. Các điểm POI lân cận được hiển thị dưới dạng Marker trên bản đồ.
  2. Thẻ tóm tắt thông tin (POI Card) hiển thị khi người dùng chạm vào Marker.

#### Luồng sự kiện chính (Main Flow)
1. Khách du lịch mở màn hình Bản đồ chính trên ứng dụng.
2. Hệ thống yêu cầu Tọa độ GPS hiện tại từ thiết bị (`latitude`, `longitude`).
3. Hệ thống gửi yêu cầu `GET /api/v1/pois/nearby?lat={lat}&lng={lng}&radius={r}` về Backend API.
4. Backend API thực hiện Spatial Query trên CSDL PostgreSQL/PostGIS để lấy danh sách POI nằm trong bán kính `r`.
5. Hệ thống nhận danh sách dữ liệu POI và vẽ các Marker lên bản đồ tương ứng với vị trí thực tế.
6. Khách du lịch chạm vào một Marker POI trên bản đồ.
7. Hệ thống hiển thị Thẻ xem trước (POI Preview Card) chứa: Tên POI, Hình ảnh thumbnail, Khoảng cách hiện tại, và nút "Xem chi tiết".

#### Luồng rẽ nhánh (Alternative Flows)
* **AF01: Người dùng thay đổi bán kính tìm kiếm**
  * Tại bước 5, người dùng kéo thanh lọc bán kính (ví dụ: từ 500m lên 2km).
  * Hệ thống gửi lại yêu cầu API với bán kính mới và cập nhật lại các Marker trên bản đồ.

#### Luồng ngoại lệ (Exception Flows)
* **EF01: Người dùng từ chối quyền GPS**
  * Tại bước 2, nếu người dùng không cấp quyền vị trí, hệ thống hiển thị thông báo: *"Vui lòng bật quyền truy cập vị trí để xem các điểm tham quan quanh bạn."*
  * Hệ thống hiển thị vị trí mặc định (trung tâm thành phố) và danh sách POI phổ biến.
* **EF02: Không tìm thấy POI nào trong bán kính**
  * Tại bước 4, nếu truy vấn không trả về kết quả, hệ thống hiển thị thông báo: *"Không tìm thấy điểm tham quan nào trong bán kính hiện tại"* và gợi ý mở rộng bán kính tìm kiếm.

---

### UC02: Plan and Customize Route
* **Feature liên quan:** Feature 2 - Route Recommendation Engine
* **Actor chính:** Visitor / Khách du lịch
* **Mô tả:** Hệ thống đề xuất tuyến đường tham quan tối ưu kết nối các điểm POI dựa trên danh mục lựa chọn của người dùng. Người dùng có thể thêm/bớt điểm dừng, thay đổi thứ tự và nhận chỉ dẫn di chuyển.
* **Điều kiện tiên quyết (Preconditions):**
  1. Khách du lịch đã ở trong ứng dụng và có vị trí GPS hợp lệ.
* **Kết quả đầu ra (Postconditions):**
  1. Tuyến đường được vẽ hoàn chỉnh trên bản đồ.
  2. Danh sách các điểm dừng (Itinerary) được sắp xếp theo đúng thứ tự tùy chỉnh.

#### Luồng sự kiện chính (Main Flow)
1. Khách du lịch chọn chức năng "Gợi ý lộ trình" (Plan Route).
2. Khách du lịch chọn các sở thích (Danh mục POI, Thời gian tham quan dự kiến, Phương tiện di chuyển).
3. Hệ thống tính toán và trả về Lộ trình được đề xuất gồm tập hợp các điểm POI xếp theo thứ tự tối ưu.
4. Hệ thống vẽ đường nối (Polyline) giữa các điểm POI trên bản đồ kèm tổng quãng đường và thời gian dự kiến.
5. Khách du lịch nhấn "Bắt đầu di chuyển" để khởi chạy chế độ chỉ đường theo thời gian thực.

#### Luồng rẽ nhánh (Alternative Flows)
* **AF01: Tùy chỉnh thứ tự các điểm dừng (Drag & Drop)**
  * Tại bước 4, người dùng mở danh sách điểm dừng, kéo thả để đổi thứ tự điểm POI A và POI B.
  * Hệ thống tính toán lại tuyến đường mới, cập nhật lại đường vẽ (Polyline), quãng đường và thời gian dự kiến trên giao diện.
* **AF02: Thêm/Xóa điểm POI khỏi lộ trình**
  * Người dùng tìm kiếm một POI mới và nhấn "Thêm vào lộ trình" hoặc nhấn "Xóa" tại một điểm dừng hiện tại.
  * Hệ thống tự động vẽ lại lộ trình tối ưu mới.

#### Luồng ngoại lệ (Exception Flows)
* **EF01: Không thể tính toán đường đi giữa 2 điểm (Không có dữ liệu bản đồ)**
  * Tại bước 3, nếu dịch vụ chỉ đường không tìm thấy tuyến đường kết nối giữa hai POI (ví dụ: điểm nằm ở đảo/khu vực cấm), hệ thống hiển thị thông báo: *"Không tìm thấy tuyến đường di chuyển đến điểm này"*.

---

### UC03: Listen to Multilingual Audio Tour
* **Feature liên quan:** Feature 3 - Multilingual Audio & Translation Pipeline
* **Actor chính:** Visitor / Khách du lịch
* **Mô tả:** Cho phép người dùng chọn ngôn ngữ mong muốn (trong 15+ ngôn ngữ) để nghe thuyết minh tự động khi bước vào bán kính của POI hoặc chủ động bấm nghe bản audio của POI đó.
* **Điều kiện tiên quyết (Preconditions):**
  1. POI đã có dữ liệu bản dịch và file âm thanh TTS tương ứng với ngôn ngữ người dùng chọn.
* **Kết quả đầu ra (Postconditions):**
  1. Audio thuyết minh được phát thành công qua trình phát Audio Player.

#### Luồng sự kiện chính (Main Flow)
1. Khách du lịch vào mục Cài đặt và chọn Ngôn ngữ thuyết minh (ví dụ: Tiếng Anh, Tiếng Nhật, Tiếng Việt...).
2. Khách du lịch di chuyển đến gần một điểm POI trong thực tế.
3. Khi khoảng cách giữa vị trí GPS của thiết bị và POI $\le$ `proximity_range` (bán kính kích hoạt), hệ thống phát hiện sự kiện Geofence Trigger.
4. Hệ thống gửi yêu cầu lấy thông tin bản dịch và file audio tương ứng: `GET /api/v1/pois/{id}/audio?lang={code}`.
5. Trình phát nhạc (Audio Player) hiển thị ở góc màn hình và tự động phát bài thuyết minh bằng ngôn ngữ đã chọn.
6. Người dùng có thể điều khiển: Tạm dừng (Pause), Tua lại (Rewind 10s), hoặc Đọc nội dung văn bản (Transcript).

#### Luồng rẽ nhánh (Alternative Flows)
* **AF01: Người dùng chủ động phát audio thủ công**
  * Người dùng bấm vào nút "Nghe thuyết minh" trên thẻ thông tin POI mà không cần di chuyển tới gần.
  * Hệ thống phát file audio ngay lập tức.

#### Luồng ngoại lệ (Exception Flows)
* **EF01: POI chưa hỗ trợ ngôn ngữ đã chọn**
  * Tại bước 4, nếu CSDL chưa có bản dịch cho ngôn ngữ người dùng chọn, hệ thống tự động fallback về **Tiếng Anh (EN)** hoặc ngôn ngữ mặc định của POI và hiển thị thông báo nhỏ: *"Audio chưa hỗ trợ ngôn ngữ này, đang phát bản Tiếng Anh"*.
* **EF02: Lỗi kết nối mạng khi tải file Audio**
  * Hệ thống hiển thị thông báo lỗi mạng và cho phép người dùng bấm nút "Thử lại".

---

### UC04: Manage POI Data & Trigger Pipeline
* **Feature liên quan:** Feature 4 (Database & Spatial) & Feature 3 (Translation Pipeline)
* **Actor chính:** Admin / Staff (Nhân viên quản trị)
* **Mô tả:** Nhân viên nhập thông tin POI mới (hoặc cập nhật POI cũ) trên trang Dashboard. Khi lưu, hệ thống tự động đẩy sự kiện vào Message Queue để kích hoạt Data Pipeline bất đồng bộ thực hiện dịch tự động sang 15+ ngôn ngữ và sinh file âm thanh TTS.
* **Điều kiện tiên quyết (Preconditions):**
  1. Admin / Staff đã đăng nhập thành công vào hệ thống Admin Dashboard với quyền hợp lệ.
* **Kết quả đầu ra (Postconditions):**
  1. Thông tin POI gốc được lưu vào bảng `pois`.
  2. Data Pipeline tự động tạo ra 15+ bản ghi trong bảng `poi_translations` chứa nội dung dịch và URL file `.mp3`.

#### Luồng sự kiện chính (Main Flow)
1. Admin truy cập trang Quản lý POI trên Admin Dashboard và nhấn "Thêm POI mới".
2. Admin nhập thông tin: Tên POI, Tọa độ GPS (`latitude`, `longitude`), Bán kính kích hoạt (`proximity_range`), Danh mục và Mô tả bằng ngôn ngữ gốc.
3. Admin nhấn nút "Lưu POI".
4. Backend API lưu dữ liệu POI gốc vào bảng `pois` trong PostgreSQL DB với trạng thái ban đầu là `PROCESSING`.
5. Backend API đẩy một Event `POI_CREATED` chứa `poi_id` vào Message Queue (RabbitMQ / Kafka).
6. Backend API trả về thông báo thành công cho Admin: *"Thêm POI thành công. Đang xử lý dịch tự động và tạo audio..."*.
7. **[Luồng xử lý bất đồng bộ Background Worker]**:
   * Worker lắng nghe Event từ Message Queue.
   * Với mỗi ngôn ngữ trong danh sách 15+ ngôn ngữ hỗ trợ:
     1. Gọi **Translation API** để dịch mô tả POI.
     2. Gửi văn bản đã dịch tới **Text-to-Speech (TTS) Engine** để sinh file audio `.mp3`.
     3. Tải file `.mp3` lên Cloud Storage (S3/GCS) và lấy public URL.
     4. Ghi thông tin bản dịch và URL audio vào bảng `poi_translations`.
8. Sau khi hoàn thành đủ các ngôn ngữ, Worker cập nhật trạng thái POI thành `COMPLETED`.

#### Luồng rẽ nhánh (Alternative Flows)
* **AF01: Cập nhật POI hiện có (Edit POI)**
  * Admin chọn một POI có sẵn và sửa lại đoạn mô tả.
  * Hệ thống lưu thay đổi và phát sự kiện `POI_UPDATED` để Data Pipeline chạy lại quy trình dịch & TTS cho đoạn mô tả mới.

#### Luồng ngoại lệ (Exception Flows)
* **EF01: Tiến trình Pipeline bị lỗi giữa chừng (ví dụ: Lỗi API TTS)**
  * Worker đánh dấu bản dịch của ngôn ngữ đó là `FAILED` và thực hiện cơ chế Retry (thử lại 3 lần).
  * Nếu vẫn thất bại, hệ thống gửi cảnh báo về Dashboard cho Admin biết để xử lý thủ công.

---

### UC05: Manage Operating Sessions
* **Feature liên quan:** Feature 5 - Admin Session & Content Management Dashboard
* **Actor chính:** Admin / Staff (Nhân viên quản trị)
* **Mô tả:** Cho phép nhân viên tạo và quản lý các phiên hoạt động (Sessions) dành cho các đoàn tham quan/tour du lịch, thiết lập thời gian bắt đầu, kết thúc và gắn các lộ trình/POI áp dụng cho phiên đó.
* **Điều kiện tiên quyết (Preconditions):**
  1. Admin / Staff đã đăng nhập thành công vào Admin Portal.
* **Kết quả đầu ra (Postconditions):**
  1. Bản ghi Session mới được lưu vào bảng `admin_sessions`.
  2. Khách du lịch tham gia Session có thể truy cập các thông tin cấu hình riêng của tour.

#### Luồng sự kiện chính (Main Flow)
1. Admin chọn menu "Quản lý Session" trên Admin Dashboard.
2. Admin nhấn nút "Tạo Session mới".
3. Admin nhập các thông tin:
   * Tên phiên (Session Name - ví dụ: "Tour Tham Quan Sáng Thứ 7").
   * Thời gian bắt đầu (Start Time) và Thời gian kết thúc (End Time).
   * Chọn Lộ trình / Danh sách POI áp dụng cho Session.
4. Admin nhấn nút "Xác nhận tạo".
5. Hệ thống kiểm tra tính hợp lệ của dữ liệu đầu vào.
6. Hệ thống lưu bản ghi vào bảng `admin_sessions` trong CSDL với trạng thái `SCHEDULED` (hoặc `ACTIVE` nếu thời gian khớp với hiện tại).
7. Hệ thống tạo Mã Session (Session Code / QR Code) để chia sẻ cho khách du lịch.

#### Luồng rẽ nhánh (Alternative Flows)
* **AF01: Đóng/Kết thúc Session sớm hơn dự kiến**
  * Admin chọn Session đang hoạt động và nhấn "Kết thúc ngay".
  * Hệ thống chuyển trạng thái Session thành `ENDED`.

#### Luồng ngoại lệ (Exception Flows)
* **EF01: Thời gian kết thúc nhỏ hơn thời gian bắt đầu**
  * Tại bước 5, hệ thống phát hiện dữ liệu thời gian không hợp lệ.
  * Hệ thống hiển thị thông báo lỗi: *"Thời gian kết thúc phải diễn ra sau thời gian bắt đầu"* và yêu cầu nhập lại.

---

### UC06: Monitor System Health and Usage
* **Feature liên quan:** Feature 6 - Real-time System Monitoring Dashboard
* **Actor chính:** Admin / System Administrator / DevOps
* **Mô tả:** Cung cấp bảng điều khiển hiển thị các chỉ số vận hành thời gian thực của hệ thống (mức sử dụng CPU, RAM, độ trễ API, tỷ lệ lỗi, số lượng truy cập đồng thời) và phát cảnh báo khi chỉ số vượt ngưỡng an toàn.
* **Điều kiện tiên quyết (Preconditions):**
  1. User đăng nhập bằng tài khoản Quản trị hệ thống (System Administrator).
* **Kết quả đầu ra (Postconditions):**
  1. Các biểu đồ giám sát được cập nhật liên tục theo thời gian thực (Real-time charts).
  2. Cảnh báo (Alerts) được hiển thị hoặc gửi thông báo khi phát hiện sự cố.

#### Luồng sự kiện chính (Main Flow)
1. Admin truy cập vào trang "System Monitoring Dashboard".
2. Hệ thống thiết lập kết nối gián tiếp/thời gian thực (WebSocket / Polling) với dịch vụ giám sát hệ thống.
3. Hệ thống liên tục truy vấn dữ liệu từ bảng `system_metrics` hoặc dịch vụ Prometheus/Metrics Collector.
4. Màn hình Dashboard hiển thị các biểu đồ trực quan:
   * Biểu đồ phần trăm sử dụng CPU & RAM của Server.
   * Biểu đồ độ trễ trung bình của các request API (API Latency ms).
   * Biểu đồ Tỷ lệ lỗi (Error Rate / HTTP 5xx Status).
   * Số lượng người dùng active đồng thời (Concurrent Users).
5. Dữ liệu trên biểu đồ tự động làm mới sau mỗi 5 giây.

#### Luồng rẽ nhánh (Alternative Flows)
* **AF01: Lọc dữ liệu giám sát theo mốc thời gian**
  * Admin chọn xem lịch sử chỉ số trong quá khứ (ví dụ: "24 giờ qua", "7 ngày qua").
  * Hệ thống truy vấn CSDL và vẽ lại biểu đồ lịch sử tương ứng.

#### Luồng ngoại lệ (Exception Flows)
* **EF01: Chỉ số hệ thống vượt ngưỡng an toàn (System Overload Alert)**
  * Nếu CPU > 90% hoặc Error Rate > 5% kéo dài quá 1 phút, hệ thống đổi màu biểu đồ sang đỏ và hiển thị hộp thoại cảnh báo nổi (Toast/Pop-up notification): *"CẢNH BÁO: Tải hệ thống đang quá ngưỡng cho phép!"*.