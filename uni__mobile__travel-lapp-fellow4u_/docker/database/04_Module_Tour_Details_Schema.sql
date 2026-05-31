-- =============================================================================
-- Dự án: Fellow4U
-- Module: 04 - Chi tiết Hành trình & Đặt chỗ
-- Mô tả: Đơn vị cung cấp, Lịch trình chi tiết, Giá theo độ tuổi và Thư viện ảnh.
-- =============================================================================

-- 1. Bảng Providers (Đơn vị cung cấp tour)
CREATE TABLE IF NOT EXISTS tour_providers (
    provider_id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    website_url TEXT,
    logo_url TEXT,
    rating_avg FLOAT DEFAULT 0.0,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Cập nhật bảng Tours (Module 2) để liên kết với Provider
ALTER TABLE tours ADD COLUMN IF NOT EXISTS provider_id INT REFERENCES tour_providers(provider_id) ON DELETE SET NULL;
ALTER TABLE tours ADD COLUMN IF NOT EXISTS pickup_point TEXT; -- Điểm đón khách

-- 2. Bảng Tour_Images (Thư viện ảnh cho Carousel)
CREATE TABLE IF NOT EXISTS tour_images (
    image_id SERIAL PRIMARY KEY,
    tour_id INT NOT NULL REFERENCES tours(tour_id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    display_order INT DEFAULT 0, -- Thứ tự hiển thị trong Carousel
    caption VARCHAR(255)
);

-- 3. Bảng Tour_Schedules (Lịch trình chi tiết - Timeline)
-- Hỗ trợ giao diện Day 1, Day 2 và Timeline dọc
CREATE TABLE IF NOT EXISTS tour_schedules (
    schedule_id SERIAL PRIMARY KEY,
    tour_id INT NOT NULL REFERENCES tours(tour_id) ON DELETE CASCADE,
    day_number INT NOT NULL, -- Ngày thứ 1, 2...
    start_time TIME NOT NULL, -- 06:00, 10:00...
    activity_title VARCHAR(255) NOT NULL,
    description TEXT,
    attraction_id INT REFERENCES attractions(attraction_id), -- Nếu hoạt động gắn liền với 1 địa danh
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Bảng Tour_Age_Pricing (Giá chi tiết theo nhóm tuổi)
CREATE TABLE IF NOT EXISTS tour_age_pricing (
    price_id SERIAL PRIMARY KEY,
    tour_id INT NOT NULL REFERENCES tours(tour_id) ON DELETE CASCADE,
    age_group_label VARCHAR(50) NOT NULL, -- 'Adult', 'Child (5-10)', 'Child < 5'
    price DECIMAL(12, 2) NOT NULL DEFAULT 0.0,
    is_free BOOLEAN GENERATED ALWAYS AS (price = 0) STORED, -- Tự động đánh dấu nếu miễn phí
    currency VARCHAR(10) DEFAULT 'USD'
);

-- 5. Tối ưu hóa & Index
CREATE INDEX IF NOT EXISTS idx_tour_images_tour ON tour_images(tour_id);
CREATE INDEX IF NOT EXISTS idx_tour_schedules_composite ON tour_schedules(tour_id, day_number, start_time);
CREATE INDEX IF NOT EXISTS idx_tour_pricing_tour ON tour_age_pricing(tour_id);

-- 6. Trigger cập nhật Rating cho Provider (Gợi ý logic)
-- Khi một tour thuộc provider được đánh giá, provider_rating cũng nên được cập nhật
-- (Phần này sẽ xử lý sâu hơn ở logic tích hợp)