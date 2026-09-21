# Database ERD - Hệ thống định vị du lịch

## 1. Conceptual Level

Hệ thống gồm các entity chính:

- User
- Category
- POI
- Translation
- AudioFile
- Route
- Session
- SystemMetrics

### Các quan hệ chính

- Category có nhiều POI.
- Một POI có nhiều bản dịch.
- Một bản dịch có thể có nhiều file audio.
- Một Route có nhiều POI và một POI có thể thuộc nhiều Route.
- Một User có thể tạo nhiều Admin Session.

---

## 2. Logical Level

### Các bảng chính

| Bảng | Mục đích |
|---|---|
| users | Lưu thông tin người dùng |
| categories | Lưu danh mục địa điểm |
| pois | Lưu thông tin địa điểm |
| poi_translations | Lưu nội dung POI theo từng ngôn ngữ |
| audio_files | Lưu thông tin file âm thanh |
| routes | Lưu thông tin tuyến đường |
| route_pois | Bảng trung gian giữa Route và POI |
| admin_sessions | Lưu phiên làm việc của Admin |
| system_metrics | Lưu các chỉ số hoạt động của hệ thống |

### Quan hệ

- `categories` 1-N `pois`
- `pois` 1-N `poi_translations`
- `poi_translations` 1-N `audio_files`
- `routes` N-N `pois`
- `users` 1-N `admin_sessions`

Quan hệ N-N giữa `routes` và `pois` được triển khai thông qua bảng trung gian `route_pois`.

---

## 3. ER Diagram

```mermaid
erDiagram

    USERS ||--o{ ADMIN_SESSIONS : creates

    CATEGORIES ||--o{ POIS : contains

    POIS ||--o{ POI_TRANSLATIONS : has

    POI_TRANSLATIONS ||--o{ AUDIO_FILES : has

    ROUTES ||--o{ ROUTE_POIS : contains

    POIS ||--o{ ROUTE_POIS : included_in

    USERS {
        int id PK
        varchar username
        varchar email
        varchar password_hash
        varchar role
        timestamp created_at
    }

    CATEGORIES {
        int id PK
        varchar name
        text description
    }

    POIS {
        int id PK
        int category_id FK
        varchar name
        geometry coordinates
        float proximity_range
        text thumbnail_url
        timestamp created_at
    }

    POI_TRANSLATIONS {
        int id PK
        int poi_id FK
        varchar language_code
        text translated_text
        text audio_url
    }

    AUDIO_FILES {
        int id PK
        int translation_id FK
        text file_url
        float duration_seconds
        varchar format
        timestamp created_at
    }

    ROUTES {
        int id PK
        varchar name
        geometry start_point
        geometry end_point
        geometry route_geometry
        float distance_meters
        int estimated_time_minutes
        timestamp created_at
    }

    ROUTE_POIS {
        int route_id PK, FK
        int poi_id PK, FK
        int sequence_order
    }

    ADMIN_SESSIONS {
        int session_id PK
        int created_by FK
        varchar status
        timestamp start_time
        timestamp end_time
    }

    SYSTEM_METRICS {
        int id PK
        varchar metric_name
        float metric_value
        timestamp recorded_at
    }
```

---

## 4. Physical Level

Database sử dụng PostgreSQL kết hợp PostGIS để hỗ trợ dữ liệu không gian.

Các trường tọa độ được lưu bằng kiểu:

`GEOMETRY(Point, 4326)`

Các bảng chính được triển khai trong file:

`schema.sql`

### Spatial Index

Hệ thống sử dụng GiST Index cho dữ liệu không gian nhằm hỗ trợ truy vấn POI theo vị trí.

---
