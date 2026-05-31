-- =============================================================================
-- SEED 08: Bookings, Bids & Workflow (Module 7)
-- Mô tả: Đặt chỗ, Đấu thầu (Bidding), Lịch sử trạng thái
-- =============================================================================

-- 1. Tạo Booking mẫu (Chờ xác nhận - Waiting)
-- Emily đặt tour "Da Nang - Hoi An 3 Days Adventure" (Tour có sẵn)
INSERT INTO bookings (traveler_id, guide_id, tour_id, start_date, end_date, status, total_price, meeting_point)
SELECT 
    (SELECT user_id FROM users WHERE email = 'emily@example.com'),
    (SELECT user_id FROM users WHERE email = 'anh.nguyen@fellow4u.com'), -- Chỉ định luôn Guide cho nhanh
    (SELECT tour_id FROM tours WHERE title = 'Da Nang - Hoi An 3 Days Adventure'),
    CURRENT_DATE + INTERVAL '20 days',
    CURRENT_DATE + INTERVAL '23 days',
    'waiting',
    150.00,
    'Da Nang Airport'
ON CONFLICT DO NOTHING;

-- 2. Tạo Booking từ Request (Quy trình Bidding)
-- Minh Tran tạo booking dựa trên Request "Seoul Cultural Experience"
-- Ban đầu chưa có guide_id vì đang chờ bid
INSERT INTO bookings (traveler_id, guide_id, source_request_id, start_date, end_date, status, total_price, meeting_point, special_requests)
SELECT 
    (SELECT user_id FROM users WHERE email = 'minh.tran@example.com'),
    NULL, -- Chưa có guide
    tr.request_id,
    tr.start_date,
    tr.start_date + INTERVAL '1 day', -- Tour 1 ngày
    'bidding', -- Trạng thái đấu thầu
    0.00, -- Giá chưa xác định
    'My Hotel Lobby',
    tr.description
FROM trip_requests tr
WHERE tr.destination_name = 'Seoul Cultural Experience'
AND tr.user_id = (SELECT user_id FROM users WHERE email = 'minh.tran@example.com')
ON CONFLICT DO NOTHING;

-- 3. Guide Ji-won gửi Bid (Báo giá) cho booking của Minh
INSERT INTO booking_bids (booking_id, guide_id, offered_price, message, is_selected)
SELECT 
    b.booking_id,
    (SELECT user_id FROM users WHERE email = 'jiwon.park@fellow4u.com'),
    120.00,
    'Hello! I would love to show you the real Seoul. This price includes entrance fees.',
    FALSE
FROM bookings b
JOIN users u ON b.traveler_id = u.user_id
WHERE u.email = 'minh.tran@example.com' AND b.status = 'bidding'
ON CONFLICT DO NOTHING;

-- 4. Minh Tran chấp nhận Bid của Ji-won
-- Cập nhật Booking: Chọn Guide, Cập nhật giá, Đổi trạng thái sang 'unpaid'
UPDATE bookings b
SET 
    guide_id = (SELECT user_id FROM users WHERE email = 'jiwon.park@fellow4u.com'),
    total_price = 120.00,
    status = 'unpaid'
WHERE b.traveler_id = (SELECT user_id FROM users WHERE email = 'minh.tran@example.com')
AND b.status = 'bidding';

-- Đánh dấu Bid là được chọn
UPDATE booking_bids bb
SET is_selected = TRUE
FROM bookings b
JOIN users u ON b.traveler_id = u.user_id
WHERE bb.booking_id = b.booking_id
AND u.email = 'minh.tran@example.com'
AND bb.guide_id = (SELECT user_id FROM users WHERE email = 'jiwon.park@fellow4u.com');

-- 5. Mô phỏng thanh toán thành công (Cập nhật trạng thái Paid)
-- Giả lập rằng Minh đã thanh toán
UPDATE bookings 
SET status = 'paid'
WHERE traveler_id = (SELECT user_id FROM users WHERE email = 'minh.tran@example.com')
AND status = 'unpaid';

-- 6. Mô phỏng Booking đã hoàn thành (Completed)
INSERT INTO bookings (traveler_id, guide_id, tour_id, start_date, end_date, status, total_price, meeting_point)
SELECT 
    (SELECT user_id FROM users WHERE email = 'minh.tran@example.com'),
    (SELECT user_id FROM users WHERE email = 'anh.nguyen@fellow4u.com'),
    (SELECT tour_id FROM tours WHERE title = 'Street Food Paradise in Saigon'),
    CURRENT_DATE - INTERVAL '10 days',
    CURRENT_DATE - INTERVAL '9 days',
    'completed',
    80.00,
    'Ben Thanh Market'
ON CONFLICT DO NOTHING;

-- 7. Mô phỏng Booking Đang diễn ra (Ongoing - Current Trip)
-- Emily đang tham gia tour "Da Nang - Hoi An" ngay hôm nay
INSERT INTO bookings (traveler_id, guide_id, tour_id, start_date, end_date, status, total_price, meeting_point)
SELECT 
    (SELECT user_id FROM users WHERE email = 'emily@example.com'),
    (SELECT user_id FROM users WHERE email = 'anh.nguyen@fellow4u.com'),
    (SELECT tour_id FROM tours WHERE title = 'Da Nang - Hoi An 3 Days Adventure'),
    CURRENT_DATE - INTERVAL '1 day',
    CURRENT_DATE + INTERVAL '1 day',
    'ongoing',
    150.00,
    'Dragon Bridge'
ON CONFLICT DO NOTHING;

-- 8. Reset Sequences
SELECT setval('bookings_booking_id_seq', (SELECT MAX(booking_id) FROM bookings));
SELECT setval('booking_bids_bid_id_seq', (SELECT MAX(bid_id) FROM booking_bids));
SELECT setval('booking_status_history_history_id_seq', (SELECT MAX(history_id) FROM booking_status_history));