-- =============================================================================
-- Dự án: Fellow4U
-- Module: 01 - Xác thực & Nhập môn (Authentication & Onboarding)
-- Mô tả: Khởi tạo cấu trúc bảng cho người dùng, quốc gia và định danh mạng xã hội.
-- =============================================================================

-- 1. Khởi tạo các kiểu dữ liệu ENUM (Custom Types)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'role_type') THEN
        CREATE TYPE role_type AS ENUM ('Traveler', 'Guide');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'social_provider') THEN
        CREATE TYPE social_provider AS ENUM ('FB', 'Kakao', 'Line');
    END IF;
END $$;

-- Khởi tạo Extension hỗ trợ tìm kiếm mờ (Fuzzy Search)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 2. Bảng Countries (Quốc gia)
CREATE TABLE IF NOT EXISTS countries (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    country_code VARCHAR(10) UNIQUE NOT NULL, -- Ví dụ: +84, +1, +82
    flag_url TEXT, -- Link ảnh icon quốc kỳ
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Bảng Users (Người dùng trung tâm)
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    role role_type NOT NULL DEFAULT 'Traveler',
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255), -- Nullable nếu chỉ dùng Social Login
    country_id INT REFERENCES countries(country_id) ON DELETE SET NULL,
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Bảng Social_Accounts (Liên kết mạng xã hội)
CREATE TABLE IF NOT EXISTS social_accounts (
    social_id VARCHAR(255) PRIMARY KEY, -- ID định danh từ bên thứ 3
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    provider social_provider NOT NULL,
    linked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, provider) -- Một user không thể liên kết 2 tài khoản cùng 1 provider
);

-- 5. Bảng Password_Resets (Quản lý mã khôi phục)
CREATE TABLE IF NOT EXISTS password_resets (
    email VARCHAR(100) NOT NULL,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    PRIMARY KEY (email, token)
);

-- 6. Tạo Indexes để tối ưu tốc độ tìm kiếm
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_social_user_id ON social_accounts(user_id);

-- 7. Trigger tự động cập nhật updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_users_modtime ON users;
CREATE TRIGGER update_users_modtime
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- LƯU Ý: Dữ liệu mẫu (Countries) đã được chuyển sang file Seed riêng.