-- ============================================
-- DATABASE SCHEMA
-- HỆ THỐNG ĐỊNH VỊ DU LỊCH
-- PostgreSQL + PostGIS
-- ============================================

CREATE EXTENSION IF NOT EXISTS postgis;


-- ============================================
-- 1. USERS
-- ============================================

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) UNIQUE,
    password_hash TEXT,
    role VARCHAR(30) NOT NULL DEFAULT 'visitor',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================
-- 2. CATEGORIES
-- ============================================

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);


-- ============================================
-- 3. POIS
-- ============================================

CREATE TABLE pois (
    id SERIAL PRIMARY KEY,

    category_id INT,

    name VARCHAR(255) NOT NULL,

    coordinates GEOMETRY(Point, 4326) NOT NULL,

    proximity_range DOUBLE PRECISION DEFAULT 100,

    thumbnail_url TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_poi_category
        FOREIGN KEY (category_id)
        REFERENCES categories(id)
);


-- ============================================
-- 4. POI TRANSLATIONS
-- ============================================

CREATE TABLE poi_translations (
    id SERIAL PRIMARY KEY,

    poi_id INT NOT NULL,

    language_code VARCHAR(10) NOT NULL,

    translated_text TEXT NOT NULL,

    audio_url TEXT,

    CONSTRAINT fk_translation_poi
        FOREIGN KEY (poi_id)
        REFERENCES pois(id)
        ON DELETE CASCADE,

    CONSTRAINT unique_poi_language
        UNIQUE (poi_id, language_code)
);


-- ============================================
-- 5. AUDIO FILES
-- ============================================

CREATE TABLE audio_files (
    id SERIAL PRIMARY KEY,

    translation_id INT NOT NULL,

    file_url TEXT NOT NULL,

    duration_seconds DOUBLE PRECISION,

    format VARCHAR(20),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audio_translation
        FOREIGN KEY (translation_id)
        REFERENCES poi_translations(id)
        ON DELETE CASCADE
);


-- ============================================
-- 6. ROUTES
-- ============================================

CREATE TABLE routes (
    id SERIAL PRIMARY KEY,

    name VARCHAR(255),

    start_point GEOMETRY(Point, 4326),

    end_point GEOMETRY(Point, 4326),

    route_geometry GEOMETRY(LineString, 4326),

    distance_meters DOUBLE PRECISION,

    estimated_time_minutes INT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================
-- 7. ROUTE_POIS
-- Many-to-Many: ROUTES <-> POIS
-- ============================================

CREATE TABLE route_pois (
    route_id INT NOT NULL,

    poi_id INT NOT NULL,

    sequence_order INT NOT NULL,

    PRIMARY KEY (route_id, poi_id),

    CONSTRAINT fk_route_pois_route
        FOREIGN KEY (route_id)
        REFERENCES routes(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_route_pois_poi
        FOREIGN KEY (poi_id)
        REFERENCES pois(id)
        ON DELETE CASCADE
);


-- ============================================
-- 8. ADMIN SESSIONS
-- ============================================

CREATE TABLE admin_sessions (
    session_id SERIAL PRIMARY KEY,

    created_by INT NOT NULL,

    status VARCHAR(50) NOT NULL,

    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    end_time TIMESTAMP,

    CONSTRAINT fk_session_user
        FOREIGN KEY (created_by)
        REFERENCES users(id)
);


-- ============================================
-- 9. SYSTEM METRICS
-- ============================================

CREATE TABLE system_metrics (
    id SERIAL PRIMARY KEY,

    metric_name VARCHAR(100) NOT NULL,

    metric_value DOUBLE PRECISION,

    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================
-- SPATIAL INDEX
-- ============================================

CREATE INDEX idx_pois_coordinates
ON pois
USING GIST (coordinates);


CREATE INDEX idx_routes_geometry
ON routes
USING GIST (route_geometry);
