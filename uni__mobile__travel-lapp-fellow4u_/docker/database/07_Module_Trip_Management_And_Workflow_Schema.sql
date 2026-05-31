-- =============================================================================
-- Dự án: Fellow4U
-- Module: 07 - Quản lý Chuyến đi & Trạng thái Đặt chỗ
-- Mô tả: Quản lý vòng đời Booking, Đấu thầu (Bidding) và Lịch sử trạng thái.
-- =============================================================================

-- 1. Khởi tạo kiểu dữ liệu ENUM cho trạng thái Booking
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'booking_status') THEN
        CREATE TYPE booking_status AS ENUM (
            'waiting',      -- Chờ Guide xác nhận
            'bidding',      -- Đang nhận báo giá từ nhiều Guide
            'unpaid',       -- Chờ khách thanh toán
            'paid',         -- Đã thanh toán, chờ ngày khởi hành
            'ongoing',      -- Chuyến đi đang diễn ra (Current Trips)
            'completed',    -- Đã hoàn thành (Past Trips)
            'cancelled',    -- Bị hủy bởi khách hoặc hệ thống
            'rejected'      -- Guide từ chối yêu cầu
        );
    END IF;
END $$;

-- 2. Bảng Bookings (Trái tim của quản lý chuyến đi)
CREATE TABLE IF NOT EXISTS bookings (
    booking_id SERIAL PRIMARY KEY,
    traveler_id INT NOT NULL REFERENCES users(user_id),
    guide_id INT REFERENCES guide_profiles(guide_id), -- Có thể NULL nếu đang ở trạng thái Bidding
    tour_id INT REFERENCES tours(tour_id),           -- Có thể NULL nếu là tour tùy chỉnh (Mod 8)
    
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    
    status booking_status DEFAULT 'waiting',
    total_price DECIMAL(12, 2) DEFAULT 0.00,
    deposit_amount DECIMAL(12, 2) DEFAULT 0.00,
    
    meeting_point TEXT,
    special_requests TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT check_booking_dates CHECK (end_date >= start_date)
);

-- 3. Bảng Booking_Bids (Quản lý đấu thầu từ Guide)
CREATE TABLE IF NOT EXISTS booking_bids (
    bid_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
    guide_id INT NOT NULL REFERENCES guide_profiles(guide_id) ON DELETE CASCADE,
    offered_price DECIMAL(12, 2) NOT NULL,
    message TEXT,
    is_selected BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(booking_id, guide_id) -- Mỗi Guide chỉ được bid 1 lần cho 1 đơn
);

-- 4. Bảng Booking_Status_History (Nhật ký thay đổi trạng thái)
CREATE TABLE IF NOT EXISTS booking_status_history (
    history_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
    from_status booking_status,
    to_status booking_status NOT NULL,
    changed_by INT REFERENCES users(user_id), -- Ai thực hiện thay đổi
    reason TEXT,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Tối ưu hóa truy vấn cho các Tab UI (Next, Current, Past)
CREATE INDEX IF NOT EXISTS idx_bookings_traveler_status ON bookings(traveler_id, status);
CREATE INDEX IF NOT EXISTS idx_bookings_guide_status ON bookings(guide_id, status);
CREATE INDEX IF NOT EXISTS idx_bookings_dates ON bookings(start_date, end_date);

-- 6. Trigger tự động cập nhật updated_at
DROP TRIGGER IF EXISTS update_bookings_modtime ON bookings;
CREATE TRIGGER update_bookings_modtime
    BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- 7. Function tự động ghi log khi trạng thái thay đổi
CREATE OR REPLACE FUNCTION log_booking_status_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.status IS DISTINCT FROM NEW.status) THEN
        INSERT INTO booking_status_history(booking_id, from_status, to_status, changed_at)
        VALUES (NEW.booking_id, OLD.status, NEW.status, CURRENT_TIMESTAMP);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_status_change ON bookings;
CREATE TRIGGER trg_log_status_change
    AFTER UPDATE ON bookings
    FOR EACH ROW EXECUTE PROCEDURE log_booking_status_changes();