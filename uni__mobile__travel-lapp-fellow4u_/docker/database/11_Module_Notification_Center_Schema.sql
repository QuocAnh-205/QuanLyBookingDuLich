-- =============================================================================
-- MODULE 11: Notification Center Schema
-- =============================================================================

-- 1. Định nghĩa kiểu ENUM cho phân loại thông báo
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_category') THEN
        CREATE TYPE notification_category AS ENUM (
            'booking_update',
            'chat_arrival',
            'payment_status',
            'review_reminder',
            'promotion',
            'system_alert'
        );
    END IF;
END $$;

-- 2. Bảng mẫu thông báo (Templates) - Để quản lý nội dung linh hoạt
CREATE TABLE IF NOT EXISTS notification_templates (
    template_id SERIAL PRIMARY KEY,
    category notification_category NOT NULL,
    template_key VARCHAR(100) UNIQUE NOT NULL, -- Ví dụ: 'BOOKING_ACCEPTED'
    title_pattern TEXT NOT NULL, -- Ví dụ: 'Yêu cầu được chấp nhận'
    body_pattern TEXT NOT NULL,  -- Ví dụ: 'Guide {guide_name} đã đồng ý...'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Bảng chính lưu trữ thông báo
CREATE TABLE IF NOT EXISTS notifications (
    notif_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    category notification_category NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    
    -- Deep-linking support
    related_entity_type VARCHAR(50), -- 'booking', 'chat', 'payment', 'news'
    related_entity_id INTEGER,
    
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Dữ liệu bổ sung (JSON)
    extra_data JSONB,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Chỉ mục (Indexes) để tối ưu truy vấn
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id) WHERE is_read = FALSE;
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- 5. Tự động hóa bằng Trigger (Automated Triggers)

-- A. Trigger thông báo khi cập nhật trạng thái Booking
CREATE OR REPLACE FUNCTION func_notify_booking_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Chỉ tạo thông báo khi có sự thay đổi trạng thái
    IF (OLD.status IS NULL OR OLD.status <> NEW.status) THEN
        
        -- Kiểm tra tránh trùng lặp thông báo trong 1 phút qua
        IF NOT EXISTS (
            SELECT 1 FROM notifications 
            WHERE user_id = NEW.traveler_id 
            AND category = 'booking_update' 
            AND related_entity_id = NEW.booking_id
            AND message LIKE '%' || NEW.status || '%'
            AND created_at > CURRENT_TIMESTAMP - INTERVAL '1 minute'
        ) THEN
            INSERT INTO notifications (user_id, category, title, message, related_entity_type, related_entity_id)
            VALUES (
                NEW.traveler_id,
                'booking_update',
                'Cập nhật chuyến đi',
                'Đơn đặt chỗ #' || NEW.booking_id || ' của bạn đã chuyển sang trạng thái: ' || NEW.status,
                'booking',
                NEW.booking_id
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_booking_update ON bookings;
CREATE TRIGGER trg_notify_booking_update
AFTER UPDATE ON bookings
FOR EACH ROW
EXECUTE FUNCTION func_notify_booking_update();

-- B. Trigger thông báo khi có tin nhắn mới
CREATE OR REPLACE FUNCTION func_notify_new_message()
RETURNS TRIGGER AS $$
DECLARE
    recipient_id INTEGER;
    room_record RECORD;
BEGIN
    -- Tìm người nhận tin nhắn (người còn lại trong phòng chat)
    SELECT * INTO room_record FROM chat_rooms WHERE room_id = NEW.room_id;
    
    IF room_record IS NULL THEN
        RETURN NEW;
    END IF;

    IF NEW.sender_id = room_record.participant_one_id THEN
        recipient_id := room_record.participant_two_id;
    ELSE
        recipient_id := room_record.participant_one_id;
    END IF;

    -- Kiểm tra tránh trùng lặp thông báo tin nhắn trong 1 phút qua cho cùng một phòng
    IF NOT EXISTS (
        SELECT 1 FROM notifications 
        WHERE user_id = recipient_id 
        AND category = 'chat_arrival' 
        AND related_entity_id = NEW.room_id
        AND created_at > CURRENT_TIMESTAMP - INTERVAL '1 minute'
    ) THEN
        INSERT INTO notifications (user_id, category, title, message, related_entity_type, related_entity_id)
        VALUES (
            recipient_id,
            'chat_arrival',
            'Tin nhắn mới',
            'Bạn có tin nhắn mới từ ' || (SELECT COALESCE(first_name || ' ' || last_name, 'ai đó') FROM users WHERE user_id = NEW.sender_id),
            'chat',
            NEW.room_id
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_new_message ON messages;
CREATE TRIGGER trg_notify_new_message
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION func_notify_new_message();