-- =============================================================================
-- Dự án: Fellow4U
-- Module: 06 - Danh mục & Xem thêm
-- Mô tả: Quản lý Banner trang danh mục, Bộ sưu tập (Collections) và Phân trang.
-- =============================================================================

-- 1. Khởi tạo kiểu dữ liệu cho loại trang
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'page_category_type') THEN
        CREATE TYPE page_category_type AS ENUM ('Guides_More', 'Tours_More');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'collection_item_type') THEN
        CREATE TYPE collection_item_type AS ENUM ('guide', 'tour');
    END IF;
END $$;

-- 2. Bảng App_Banners (Quản lý ảnh bìa và tiêu đề trang danh sách)
CREATE TABLE IF NOT EXISTS app_banners (
    banner_id SERIAL PRIMARY KEY,
    page_type page_category_type NOT NULL,
    title_text VARCHAR(255) NOT NULL,
    subtitle_text TEXT, -- Ví dụ: "Plenty of amazing tours are waiting for you"
    image_url TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Bảng Collections (Nhóm nội dung/Bộ sưu tập)
CREATE TABLE IF NOT EXISTS collections (
    collection_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL, -- Dùng để lọc trên URL/API (VD: private-local)
    description TEXT,
    item_type collection_item_type NOT NULL, -- Phân loại bộ sưu tập này chứa gì
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Bảng trung gian Collection_Items (Gắn Tour/Guide vào Bộ sưu tập)
CREATE TABLE IF NOT EXISTS collection_guides (
    collection_id INT NOT NULL REFERENCES collections(collection_id) ON DELETE CASCADE,
    guide_id INT NOT NULL REFERENCES guide_profiles(guide_id) ON DELETE CASCADE,
    sort_order INT DEFAULT 0,
    PRIMARY KEY (collection_id, guide_id)
);

CREATE TABLE IF NOT EXISTS collection_tours (
    collection_id INT NOT NULL REFERENCES collections(collection_id) ON DELETE CASCADE,
    tour_id INT NOT NULL REFERENCES tours(tour_id) ON DELETE CASCADE,
    sort_order INT DEFAULT 0,
    PRIMARY KEY (collection_id, tour_id)
);

-- 5. Tối ưu hóa truy vấn Phân trang & Banner
CREATE INDEX IF NOT EXISTS idx_banners_type ON app_banners(page_type) WHERE is_active IS TRUE;
CREATE INDEX IF NOT EXISTS idx_collections_slug ON collections(slug);
CREATE INDEX IF NOT EXISTS idx_coll_guides_sort ON collection_guides(sort_order);
CREATE INDEX IF NOT EXISTS idx_coll_tours_sort ON collection_tours(sort_order);

-- 6. Trigger cập nhật updated_at cho Banners
DROP TRIGGER IF EXISTS update_banners_modtime ON app_banners;
CREATE TRIGGER update_banners_modtime
    BEFORE UPDATE ON app_banners
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- 7. Dữ liệu mẫu khởi tạo cho Module 6
INSERT INTO app_banners (page_type, title_text, subtitle_text, image_url) VALUES 
('Guides_More', 'Local Guides', 'Book your own private local Guide', 'https://cdn.fellow4u.com/banners/guides_bg.jpg'),
('Tours_More', 'Amazing Tours', 'Plenty of amazing tours are waiting for you', 'https://cdn.fellow4u.com/banners/tours_bg.jpg')
ON CONFLICT DO NOTHING;