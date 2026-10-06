```mermaid
graph TB
    subgraph ClientDevice ["Thiết Bị Di Động (Android Client)"]
        AndroidApp["Ứng Dụng Android<br/>(Google Maps, ExoPlayer, QR Scanner)"]
    end

    subgraph ServerHost ["Môi Trường Máy Chủ / Docker Container"]
        subgraph Services ["Spring Boot Microservices"]
            CMS["cms-service<br/>(Port: 8081)"]
            Tracking["tracking-service<br/>(Port: 8082)"]
            Trigger["trigger-engine<br/>(Port: 8083)"]
        end

        subgraph Infra ["Hạ Tầng Dữ Liệu & Lưu Trữ"]
            PostgreSQL["PostgreSQL + PostGIS<br/>(Dữ liệu POI & Spatial)"]
            Redis["Redis<br/>(GEO Cache + Cooldown TTL)"]
            RabbitMQ["RabbitMQ<br/>(Message Broker)"]
            MinIO["MinIO<br/>(S3-compatible Audio Storage .mp3)"]
        end
    end

    %% Các luồng kết nối giao tiếp
    AndroidApp -- "HTTP / REST<br/>(GPS định kỳ mỗi 3s)" --> Tracking
    AndroidApp -- "HTTP / REST<br/>(QR Token, CRUD POI, Dashboard)" --> CMS
    AndroidApp -- "HTTP Stream<br/>(Phát Audio .mp3)" --> MinIO

    Tracking -- "Publish Location Event" --> RabbitMQ
    RabbitMQ -- "Consume Event" --> Trigger
    Trigger -- "Kiểm tra GEO & Cooldown" --> Redis
    Trigger -- "Gọi nội bộ / Truy vấn" --> CMS
    CMS -- "Đọc / Ghi dữ liệu" --> PostgreSQL