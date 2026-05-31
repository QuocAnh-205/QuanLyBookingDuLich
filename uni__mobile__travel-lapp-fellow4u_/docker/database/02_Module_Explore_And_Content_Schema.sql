-- =============================================================================
-- Dự án: Fellow4U
-- Module: 02 - Khám phá & Gợi ý (Explore & Recommendations)
-- Mô tả: Quản lý địa điểm, Tour, Trải nghiệm, Tin tức và Danh sách yêu thích.
-- =============================================================================

-- 1. Bảng Locations (Địa điểm chi tiết)
-- Mở rộng từ bảng Countries ở Module 1
CREATE TABLE IF NOT EXISTS locations (
    location_id SERIAL PRIMARY KEY,
    country_id INT NOT NULL REFERENCES countries(country_id),
    city_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    is_popular BOOLEAN DEFAULT FALSE,
    search_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng Guide_Profiles (Hồ sơ chuyên sâu của Guide)
-- Quan hệ 1:1 với bảng Users (Module 1)
CREATE TABLE IF NOT EXISTS guide_profiles (
    guide_id INT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    bio TEXT,
    base_location_id INT REFERENCES locations(location_id),
    rating_avg FLOAT DEFAULT 0.0,
    total_reviews INT DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Bảng Tours (Chuyến đi dài ngày)
CREATE TABLE IF NOT EXISTS tours (
    tour_id SERIAL PRIMARY KEY,
    title VARCHAR(255) UNIQUE NOT NULL,
    location_id INT NOT NULL REFERENCES locations(location_id),
    price DECIMAL(12, 2) NOT NULL, -- Độ chính xác cao cho tiền tệ
    duration_days INT DEFAULT 1,
    thumbnail_url TEXT,
    description TEXT,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Bảng Experiences (Trải nghiệm ngắn hạn)
CREATE TABLE IF NOT EXISTS experiences (
    exp_id SERIAL PRIMARY KEY,
    guide_id INT NOT NULL REFERENCES guide_profiles(guide_id) ON DELETE CASCADE,
    title VARCHAR(255) UNIQUE NOT NULL,
    location_id INT NOT NULL REFERENCES locations(location_id),
    price DECIMAL(12, 2) NOT NULL,
    duration_hours FLOAT DEFAULT 1.0,
    thumbnail_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Bảng Travel_News (Tin tức & Blog)
CREATE TABLE IF NOT EXISTS travel_news (
    news_id SERIAL PRIMARY KEY,
    title VARCHAR(255) UNIQUE NOT NULL,
    content TEXT, -- Nội dung chính
    metadata JSONB, -- Lưu trữ thông tin linh hoạt (tags, author_name, read_time)
    image_url TEXT,
    is_published BOOLEAN DEFAULT TRUE,
    published_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Bảng Wishlist (Danh sách yêu thích)
-- Liên kết người dùng với Tour hoặc Experience
CREATE TABLE IF NOT EXISTS wishlist (
    wish_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    tour_id INT REFERENCES tours(tour_id) ON DELETE CASCADE,
    exp_id INT REFERENCES experiences(exp_id) ON DELETE CASCADE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    -- Đảm bảo không lưu trùng lặp cùng một tour cho một user
    CONSTRAINT unique_user_tour UNIQUE (user_id, tour_id),
    CONSTRAINT unique_user_exp UNIQUE (user_id, exp_id),
    -- Kiểm tra: Phải có ít nhất tour_id hoặc exp_id được điền
    CONSTRAINT check_target_exists CHECK (tour_id IS NOT NULL OR exp_id IS NOT NULL)
);

-- 7. Tối ưu hóa hiệu suất
CREATE INDEX IF NOT EXISTS idx_locations_city ON locations(city_name);
CREATE INDEX IF NOT EXISTS idx_tours_featured ON tours(is_featured) WHERE is_featured IS TRUE;
CREATE INDEX IF NOT EXISTS idx_news_jsonb_tags ON travel_news USING gin (metadata);

-- 8. Trigger cập nhật thời gian cho Guide_Profiles & Tours
DROP TRIGGER IF EXISTS update_guide_profile_modtime ON guide_profiles;
CREATE TRIGGER update_guide_profile_modtime
    BEFORE UPDATE ON guide_profiles
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_tours_modtime ON tours;
CREATE TRIGGER update_tours_modtime
    BEFORE UPDATE ON tours
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();