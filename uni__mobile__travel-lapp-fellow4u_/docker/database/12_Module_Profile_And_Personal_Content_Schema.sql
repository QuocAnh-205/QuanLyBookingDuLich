-- =============================================================================
-- Dự án: Fellow4U
-- Module: 12 - Quản lý Hồ sơ & Nội dung Cá nhân
-- Mô tả: Lưu trữ kho ảnh, nhật ký hành trình, cài đặt người dùng và nhật ký bảo mật.
-- =============================================================================

-- 1. Cập nhật bảng Users (Bổ sung các trường phục vụ Profile cá nhân)
ALTER TABLE users ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS date_of_birth DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS gender VARCHAR(20);

-- 2. Bảng User_Photos (Kho lưu trữ ảnh cá nhân)
CREATE TABLE IF NOT EXISTS user_photos (
    photo_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    storage_provider VARCHAR(50) DEFAULT 'local', -- 's3', 'cloudinary', 'local'
    width INT,
    height INT,
    is_public BOOLEAN DEFAULT TRUE,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, image_url)
);

-- 3. Bảng User_Journeys (Nhật ký hành trình/Album kỷ niệm)
CREATE TABLE IF NOT EXISTS user_journeys (
    journey_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL, -- Ví dụ: "A memory in Danang"
    location_name VARCHAR(255),
    description TEXT,
    likes_count INT DEFAULT 0,
    created_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, title)
);

-- 4. Bảng trung gian Journey_Media (Liên kết Ảnh vào Hành trình)
CREATE TABLE IF NOT EXISTS journey_media (
    journey_id INT NOT NULL REFERENCES user_journeys(journey_id) ON DELETE CASCADE,
    photo_id INT NOT NULL REFERENCES user_photos(photo_id) ON DELETE CASCADE,
    display_order INT DEFAULT 0,
    PRIMARY KEY (journey_id, photo_id)
);

-- 5. Bảng User_Settings (Cấu hình ứng dụng)
CREATE TABLE IF NOT EXISTS user_settings (
    user_id INT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    preferred_language VARCHAR(10) DEFAULT 'en',
    preferred_currency CHAR(3) DEFAULT 'USD',
    enable_push_notifications BOOLEAN DEFAULT TRUE,
    enable_email_notifications BOOLEAN DEFAULT TRUE,
    theme_mode VARCHAR(20) DEFAULT 'light', -- 'light', 'dark', 'system'
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Bảng Security_Logs (Nhật ký bảo mật/Đổi mật khẩu)
CREATE TABLE IF NOT EXISTS security_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    action_type VARCHAR(100) NOT NULL, -- 'PASSWORD_CHANGE', 'EMAIL_CHANGE', 'LOGIN_ATTEMPT'
    ip_address VARCHAR(45),
    device_info TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Tối ưu hóa truy vấn
CREATE INDEX IF NOT EXISTS idx_user_photos_user ON user_photos(user_id);
CREATE INDEX IF NOT EXISTS idx_user_journeys_user ON user_journeys(user_id);
CREATE INDEX IF NOT EXISTS idx_security_logs_user ON security_logs(user_id, created_at DESC);

-- 8. Trigger cập nhật updated_at cho Journeys và Settings
DROP TRIGGER IF EXISTS update_journeys_modtime ON user_journeys;
CREATE TRIGGER update_journeys_modtime
    BEFORE UPDATE ON user_journeys
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_settings_modtime ON user_settings;
CREATE TRIGGER update_user_settings_modtime
    BEFORE UPDATE ON user_settings
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();