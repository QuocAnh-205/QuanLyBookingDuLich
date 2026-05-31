-- =============================================================================
-- Dự án: Fellow4U
-- Module: 03 - Chi tiết Dịch vụ & Quản lý Điểm đến
-- Mô tả: Ngôn ngữ, Bảng giá phân tầng, Đánh giá và Địa điểm tham quan.
-- =============================================================================

-- 1. Quản lý Ngôn ngữ
CREATE TABLE IF NOT EXISTS languages (
    lang_id SERIAL PRIMARY KEY,
    lang_name VARCHAR(50) UNIQUE NOT NULL,
    lang_code CHAR(2) UNIQUE -- Ví dụ: 'en', 'vi', 'kr'
);

-- Bảng trung gian Guide - Ngôn ngữ
CREATE TABLE IF NOT EXISTS guide_languages (
    guide_id INT NOT NULL REFERENCES guide_profiles(guide_id) ON DELETE CASCADE,
    lang_id INT NOT NULL REFERENCES languages(lang_id) ON DELETE CASCADE,
    PRIMARY KEY (guide_id, lang_id)
);

-- 2. Bảng giá phân tầng (Tiered Pricing)
-- Giúp tính toán giá dựa trên số lượng khách (Module 3 - Mục 1)
CREATE TABLE IF NOT EXISTS guide_pricing (
    price_id SERIAL PRIMARY KEY,
    guide_id INT NOT NULL REFERENCES guide_profiles(guide_id) ON DELETE CASCADE,
    min_travelers INT NOT NULL DEFAULT 1,
    max_travelers INT NOT NULL,
    price_per_hour DECIMAL(12, 2) NOT NULL,
    CONSTRAINT check_traveler_range CHECK (max_travelers >= min_travelers)
);

-- 3. Hệ thống Đánh giá & Phản hồi (Reviews)
CREATE TABLE IF NOT EXISTS reviews (
    review_id SERIAL PRIMARY KEY,
    guide_id INT NOT NULL REFERENCES guide_profiles(guide_id) ON DELETE CASCADE,
    author_id INT NOT NULL REFERENCES users(user_id), -- Khách du lịch viết bài
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Danh mục Địa điểm tham quan (Attractions)
-- Dùng cho chức năng tìm kiếm thông minh và quản lý hành trình
CREATE TABLE IF NOT EXISTS attractions (
    attraction_id SERIAL PRIMARY KEY,
    location_id INT NOT NULL REFERENCES locations(location_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    description TEXT,
    image_url TEXT,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Kho tư liệu Guide (Portfolio Media)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'portfolio_media_type') THEN
        CREATE TYPE portfolio_media_type AS ENUM ('image', 'video');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS guide_portfolio_media (
    media_id SERIAL PRIMARY KEY,
    guide_id INT NOT NULL REFERENCES guide_profiles(guide_id) ON DELETE CASCADE,
    media_url TEXT NOT NULL,
    media_type portfolio_media_type DEFAULT 'image',
    title VARCHAR(100),
    display_order INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Tối ưu hóa & Index
CREATE INDEX IF NOT EXISTS idx_reviews_guide_id ON reviews(guide_id);
CREATE INDEX IF NOT EXISTS idx_attractions_location ON attractions(location_id);
CREATE INDEX IF NOT EXISTS idx_attractions_name_trgm ON attractions USING gin (name gin_trgm_ops); -- Hỗ trợ Autocomplete nhanh

-- LƯU Ý: Dữ liệu mẫu (Languages) đã được chuyển sang file Seed riêng.