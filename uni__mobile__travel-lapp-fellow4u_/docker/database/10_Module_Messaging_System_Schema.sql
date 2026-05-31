-- =============================================================================
-- Dự án: Fellow4U
-- Module: 10 - Hệ thống Tin nhắn
-- Mô tả: Quản lý phòng chat, tin nhắn chi tiết và trạng thái đọc/chưa đọc.
-- =============================================================================

-- 1. Bảng Chat_Rooms (Phòng hội thoại)
CREATE TABLE IF NOT EXISTS chat_rooms (
    room_id SERIAL PRIMARY KEY,
    booking_id INT REFERENCES bookings(booking_id) ON DELETE SET NULL,
    
    -- Lưu ID của 2 người tham gia để truy vấn nhanh (Traveler & Guide)
    participant_one_id INT NOT NULL REFERENCES users(user_id),
    participant_two_id INT NOT NULL REFERENCES users(user_id),
    
    -- Metadata để tối ưu hóa hiển thị danh sách chat (Chat List)
    last_message_preview TEXT,
    last_message_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Đảm bảo không tạo 2 phòng chat cho cùng một booking
    UNIQUE(booking_id)
);

-- 2. Bảng Messages (Chi tiết tin nhắn)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'chat_message_type') THEN
        CREATE TYPE chat_message_type AS ENUM ('text', 'image', 'location');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS messages (
    message_id SERIAL PRIMARY KEY,
    room_id INT NOT NULL REFERENCES chat_rooms(room_id) ON DELETE CASCADE,
    sender_id INT NOT NULL REFERENCES users(user_id),
    
    content TEXT NOT NULL,
    message_type chat_message_type DEFAULT 'text',
    
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tối ưu hóa truy vấn (Performance & UI)
CREATE INDEX IF NOT EXISTS idx_chat_rooms_participants ON chat_rooms(participant_one_id, participant_two_id);
CREATE INDEX IF NOT EXISTS idx_messages_room_time ON messages(room_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON messages(room_id, is_read) WHERE is_read IS FALSE;

-- 4. Trigger tự động cập nhật Chat_Room khi có tin nhắn mới
CREATE OR REPLACE FUNCTION update_chat_room_last_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE chat_rooms
    SET last_message_preview = CASE 
                                    WHEN NEW.message_type = 'text' THEN LEFT(NEW.content, 100)
                                    ELSE '[Media/Location]'
                                END,
        last_message_at = NEW.created_at,
        updated_at = CURRENT_TIMESTAMP
    WHERE room_id = NEW.room_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_after_message_sent ON messages;
CREATE TRIGGER trg_after_message_sent
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE PROCEDURE update_chat_room_last_message();

-- 5. View hỗ trợ lấy Unread Count cho từng User
CREATE OR REPLACE VIEW view_user_unread_chats AS
SELECT 
    room_id,
    sender_id AS other_participant_id, -- Trong thực tế cần logic so sánh để lấy ID người kia
    COUNT(*) AS unread_count
FROM messages
WHERE is_read = FALSE
GROUP BY room_id, sender_id;