-- =============================================================================
-- SEED 11: Notification Center (Module 11)
-- Mô tả: Thông báo đẩy/trong app cho Booking, Payment, Chat, System
-- =============================================================================

-- 1. Thông báo về Trạng thái Booking (Booking Updates)
-- Emily nhận thông báo Guide Anh đã chấp nhận yêu cầu (Giả lập từ quy trình cũ hoặc mới)
INSERT INTO notifications (user_id, category, title, message, related_entity_type, related_entity_id, is_read, created_at)
SELECT * FROM (
    SELECT 
        u.user_id,
        'booking_update'::notification_category as category,
        'Yêu cầu đã được chấp nhận' as title,
        'Guide Anh Nguyen đã chấp nhận yêu cầu chuyến đi Da Nang của bạn.' as message,
        'booking' as related_entity_type,
        b.booking_id as related_entity_id,
        FALSE as is_read,
        CURRENT_TIMESTAMP - INTERVAL '3 days' as created_at
    FROM users u
    JOIN bookings b ON b.traveler_id = u.user_id
    WHERE u.email = 'emily@example.com' 
    AND b.guide_id = (SELECT user_id FROM users WHERE email = 'anh.nguyen@fellow4u.com')
    LIMIT 1
) sub
ON CONFLICT DO NOTHING;

-- Minh Tran nhận thông báo Bid được chọn
INSERT INTO notifications (user_id, category, title, message, related_entity_type, related_entity_id, is_read, created_at)
SELECT * FROM (
    SELECT 
        u.user_id,
        'booking_update'::notification_category as category,
        'Báo giá đã được chọn' as title,
        'Bạn đã chọn báo giá của Ji-won Park cho chuyến đi Seoul.' as message,
        'booking' as related_entity_type,
        b.booking_id as related_entity_id,
        TRUE as is_read,
        CURRENT_TIMESTAMP - INTERVAL '5 days' as created_at
    FROM users u
    JOIN bookings b ON b.traveler_id = u.user_id
    WHERE u.email = 'minh.tran@example.com' 
    AND b.status IN ('paid', 'unpaid')
    LIMIT 1
) sub
ON CONFLICT DO NOTHING;

-- 2. Thông báo về Thanh toán (Payment Status)
-- Emily nhận thông báo thanh toán thành công
INSERT INTO notifications (user_id, category, title, message, related_entity_type, related_entity_id, is_read, created_at)
SELECT * FROM (
    SELECT 
        u.user_id,
        'payment_status'::notification_category as category,
        'Thanh toán thành công' as title,
        'Chúng tôi đã nhận được thanh toán $150.00 cho đơn hàng #' || b.booking_id as message,
        'booking' as related_entity_type,
        b.booking_id as related_entity_id,
        TRUE as is_read,
        CURRENT_TIMESTAMP - INTERVAL '2 days' as created_at
    FROM users u
    JOIN bookings b ON b.traveler_id = u.user_id
    JOIN payments p ON p.booking_id = b.booking_id
    WHERE u.email = 'emily@example.com' 
    AND p.status = 'success'
    LIMIT 1
) sub
ON CONFLICT DO NOTHING;

-- 3. Thông báo nhắc nhở Đánh giá (Review Reminder)
-- Giả lập một booking đã hoàn thành (completed) để kích hoạt nhắc nhở
INSERT INTO notifications (user_id, category, title, message, related_entity_type, related_entity_id, is_read, created_at)
SELECT * FROM (
    SELECT 
        u.user_id,
        'review_reminder'::notification_category as category,
        'Kỷ niệm chuyến đi' as title,
        'Chuyến đi với Guide Anh Nguyen đã kết thúc. Hãy để lại đánh giá nhé!' as message,
        'booking' as related_entity_type,
        b.booking_id as related_entity_id,
        FALSE as is_read,
        CURRENT_TIMESTAMP - INTERVAL '1 day' as created_at
    FROM users u
    JOIN bookings b ON b.traveler_id = u.user_id
    WHERE u.email = 'emily@example.com' 
    AND b.status = 'completed'
    LIMIT 1
) sub
ON CONFLICT DO NOTHING;

-- Nếu chưa có booking completed, ta có thể cập nhật một booking cũ thành completed để test
-- Đảm bảo end_date >= start_date để không vi phạm check_booking_dates
UPDATE bookings 
SET status = 'completed', 
    start_date = CURRENT_DATE - INTERVAL '4 days',
    end_date = CURRENT_DATE - INTERVAL '2 days'
WHERE booking_id IN (
    SELECT booking_id FROM bookings
    WHERE traveler_id = (SELECT user_id FROM users WHERE email = 'emily@example.com')
    AND guide_id = (SELECT user_id FROM users WHERE email = 'anh.nguyen@fellow4u.com')
    AND status != 'completed'
    LIMIT 1
);

-- Chèn lại notification review reminder sau khi update status
INSERT INTO notifications (user_id, category, title, message, related_entity_type, related_entity_id, is_read, created_at)
SELECT * FROM (
    SELECT 
        u.user_id,
        'review_reminder'::notification_category as category,
        'Kỷ niệm chuyến đi' as title,
        'Chuyến đi với Guide Anh Nguyen đã kết thúc. Hãy để lại đánh giá nhé!' as message,
        'booking' as related_entity_type,
        b.booking_id as related_entity_id,
        FALSE as is_read,
        CURRENT_TIMESTAMP - INTERVAL '1 day' as created_at
    FROM users u
    JOIN bookings b ON b.traveler_id = u.user_id
    WHERE u.email = 'emily@example.com' 
    AND b.status = 'completed'
    LIMIT 1
) sub
ON CONFLICT DO NOTHING;

-- 4. Thông báo Hệ thống/Khuyến mãi (System/Promotion)
INSERT INTO notifications (user_id, category, title, message, related_entity_type, related_entity_id, is_read, extra_data, created_at)
VALUES
(
    (SELECT user_id FROM users WHERE email = 'emily@example.com'),
    'promotion'::notification_category,
    'Ưu đãi đặc biệt tháng này!',
    'Giảm 10% cho tất cả các tour tại Đà Nẵng khi đặt trước 7 ngày.',
    'news',
    NULL,
    FALSE,
    '{"banner_url": "https://example.com/promo.jpg"}'::jsonb,
    CURRENT_TIMESTAMP - INTERVAL '4 hours'
),
(
    (SELECT user_id FROM users WHERE email = 'jiwon.park@fellow4u.com'),
    'system_alert'::notification_category,
    'Cập nhật hồ sơ',
    'Vui lòng cập nhật ảnh đại diện để tăng độ tin cậy với khách hàng.',
    'profile',
    NULL,
    FALSE,
    NULL,
    CURRENT_TIMESTAMP - INTERVAL '1 hour'
)
ON CONFLICT DO NOTHING;

-- 5. Reset Sequences
SELECT setval('notifications_notif_id_seq', (SELECT MAX(notif_id) FROM notifications));