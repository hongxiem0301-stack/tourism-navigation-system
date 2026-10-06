```mermaid
graph TD
    subgraph Actors ["Người Dùng (Actors)"]
        DuKhach["Du Khách"]
        Admin["Quản Trị Viên (Admin)"]
    end

    subgraph System ["Hệ Thống Thuyết Minh Tự Động Đa Ngôn Ngữ"]
        UC01["UC01: Xem Bản Đồ & Vị Trí GPS"]
        UC02["UC02: Nhận Thuyết Minh qua Geofence"]
        UC03["UC03: Nghe Thuyết Minh Đa Ngôn Ngữ"]
        UC04["UC04: Quét Mã QR Kích Hoạt Tức Thì"]
        UC05["UC05: Xem Thống Kê & Phân Tích Lượt Nghe"]
        UC06["UC06: Quản Lý Nội Dung Điểm Tham Quan (CMS)"]
        UC07["UC07: Chọn Ngôn Ngữ Thuyết Minh"]
        UC08["UC08: Xem Chi Tiết & Lịch Sử POI"]
    end

    %% Du khách interactions
    DuKhach --> UC01
    DuKhach --> UC02
    DuKhach --> UC03
    DuKhach --> UC04
    DuKhach --> UC07
    DuKhach --> UC08

    %% Admin interactions
    Admin --> UC05
    Admin --> UC06