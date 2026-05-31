-- =============================================================================
-- Dự án: Fellow4U
-- Module: 05 - Tìm kiếm & Bộ lọc nâng cao
-- Mô tả: Quản lý lịch trống của Guide, Nhật ký tìm kiếm và Tối ưu hóa truy vấn.
-- =============================================================================

-- 1. Kích hoạt Extension hỗ trợ tìm kiếm mờ (Fuzzy Search)
-- Đã chuyển sang V1 để đảm bảo tính sẵn sàng toàn cục

-- 2. Bảng Guide_Availability (Lịch trống của Guide)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'guide_status') THEN
        CREATE TYPE guide_status AS ENUM ('available', 'booked', 'off');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS guide_availability (
    avail_id SERIAL PRIMARY KEY,
    guide_id INT NOT NULL REFERENCES guide_profiles(guide_id) ON DELETE CASCADE,
    available_date DATE NOT NULL,
    status guide_status DEFAULT 'available',
    note TEXT,
    UNIQUE(guide_id, available_date) -- Đảm bảo không trùng lặp ngày cho một Guide
);

-- 3. Bảng Search_Logs (Nhật ký tìm kiếm)
CREATE TABLE IF NOT EXISTS search_history (
    log_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE SET NULL, -- Null nếu khách vãng lai
    keyword VARCHAR(255),
    filters_applied JSONB, -- Lưu các bộ lọc đã dùng (giá, ngôn ngữ, ngày)
    search_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Tối ưu hóa hiệu suất tìm kiếm (Indexing Strategy)
CREATE INDEX IF NOT EXISTS idx_locations_name_trgm ON locations USING gin (city_name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_tours_title_trgm ON tours USING gin (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_guide_pricing_fee ON guide_pricing(price_per_hour);
CREATE INDEX IF NOT EXISTS idx_guide_availability_date ON guide_availability(available_date, status);

-- 5. View hỗ trợ tìm kiếm tổng hợp (Search Unified View)
CREATE OR REPLACE VIEW view_search_suggestions AS
SELECT 'location' AS type, city_name AS display_name, location_id AS target_id FROM locations
UNION ALL
SELECT 'tour' AS type, title AS display_name, tour_id AS target_id FROM tours;

-- 6. Function tự động cập nhật độ phổ biến của địa điểm
CREATE OR REPLACE FUNCTION update_location_popularity()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE locations 
    SET search_count = search_count + 1 
    WHERE city_name ILIKE '%' || NEW.keyword || '%';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_popularity ON search_history;
CREATE TRIGGER trg_update_popularity
    AFTER INSERT ON search_history
    FOR EACH ROW
    WHEN (NEW.keyword IS NOT NULL)
    EXECUTE PROCEDURE update_location_popularity();