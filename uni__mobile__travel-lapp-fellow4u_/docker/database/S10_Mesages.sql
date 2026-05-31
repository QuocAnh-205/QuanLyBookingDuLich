-- =============================================================================
-- SEED 10: Messages & Chat Rooms (Module 10)
-- Mô tả: Dữ liệu mẫu cho hệ thống tin nhắn, hỗ trợ phân tách theo Booking
-- =============================================================================

-- 1. Tạo Phòng Chat (Chat Rooms)
-- Room 1: Emily <-> Anh Nguyen (Cho Booking #1 - Da Nang)
INSERT INTO chat_rooms (booking_id, participant_one_id, participant_two_id, last_message_preview, last_message_at)
SELECT 
    b.booking_id,
    LEAST(b.traveler_id, b.guide_id),
    GREATEST(b.traveler_id, b.guide_id),
    'Great! See you at the airport!',
    CURRENT_TIMESTAMP - INTERVAL '1 hour'
FROM bookings b
WHERE b.booking_id = 1
ON CONFLICT (booking_id) DO NOTHING;

-- Room 3: Emily <-> Anh Nguyen (Cho Booking #4 - Tour khác)
-- Giả sử Booking #4 tồn tại giữa Emily và Anh
INSERT INTO chat_rooms (booking_id, participant_one_id, participant_two_id, last_message_preview, last_message_at)
SELECT 
    b.booking_id,
    LEAST(b.traveler_id, b.guide_id),
    GREATEST(b.traveler_id, b.guide_id),
    'I have updated the meeting time for our trip.',
    CURRENT_TIMESTAMP - INTERVAL '10 minutes'
FROM bookings b
WHERE b.booking_id = 4
ON CONFLICT (booking_id) DO NOTHING;

-- Room 2: Minh Tran <-> Ji-won Park (Cho Booking #2 - Seoul)
INSERT INTO chat_rooms (booking_id, participant_one_id, participant_two_id, last_message_preview, last_message_at)
SELECT 
    b.booking_id,
    LEAST(b.traveler_id, b.guide_id),
    GREATEST(b.traveler_id, b.guide_id),
    'Can we change the meeting point?',
    CURRENT_TIMESTAMP - INTERVAL '30 minutes'
FROM bookings b
WHERE b.booking_id = 2
ON CONFLICT (booking_id) DO NOTHING;

-- 2. Thêm tin nhắn mẫu (Messages)

-- TIN NHẮN CHO BOOKING #1 (Da Nang)
INSERT INTO messages (room_id, sender_id, content, message_type, is_read, created_at)
SELECT cr.room_id, b.guide_id, 'Hello Emily! I will be waiting for you at Da Nang Airport Terminal 1 with a sign.', 'text', TRUE, CURRENT_TIMESTAMP - INTERVAL '2 hours'
FROM chat_rooms cr JOIN bookings b ON cr.booking_id = b.booking_id WHERE b.booking_id = 1
AND NOT EXISTS (SELECT 1 FROM messages m WHERE m.room_id = cr.room_id AND m.content LIKE 'Hello Emily%');

INSERT INTO messages (room_id, sender_id, content, message_type, is_read, created_at)
SELECT cr.room_id, b.traveler_id, 'Great! See you at the airport!', 'text', FALSE, CURRENT_TIMESTAMP - INTERVAL '1 hour'
FROM chat_rooms cr JOIN bookings b ON cr.booking_id = b.booking_id WHERE b.booking_id = 1
AND NOT EXISTS (SELECT 1 FROM messages m WHERE m.room_id = cr.room_id AND m.content = 'Great! See you at the airport!');

-- TIN NHẮN CHO BOOKING #4 (Trip Update)
INSERT INTO messages (room_id, sender_id, content, message_type, is_read, created_at)
SELECT cr.room_id, b.guide_id, 'Hello! I have updated the meeting time for our second trip.', 'text', TRUE, CURRENT_TIMESTAMP - INTERVAL '15 minutes'
FROM chat_rooms cr JOIN bookings b ON cr.booking_id = b.booking_id WHERE b.booking_id = 4
AND NOT EXISTS (SELECT 1 FROM messages m WHERE m.room_id = cr.room_id AND m.content LIKE 'Hello! I have updated%');

-- TIN NHẮN CHO BOOKING #2 (Seoul)
INSERT INTO messages (room_id, sender_id, content, message_type, is_read, created_at)
SELECT cr.room_id, b.guide_id, 'Sure, Myeongdong Station works for me. See you there for our Seoul tour!', 'text', FALSE, CURRENT_TIMESTAMP - INTERVAL '30 minutes'
FROM chat_rooms cr JOIN bookings b ON cr.booking_id = b.booking_id WHERE b.booking_id = 2
AND NOT EXISTS (SELECT 1 FROM messages m WHERE m.room_id = cr.room_id AND m.content LIKE 'Sure, Myeongdong%');

-- 3. Reset Sequences
SELECT setval('chat_rooms_room_id_seq', (SELECT MAX(room_id) FROM chat_rooms));
SELECT setval('messages_message_id_seq', (SELECT MAX(message_id) FROM messages));