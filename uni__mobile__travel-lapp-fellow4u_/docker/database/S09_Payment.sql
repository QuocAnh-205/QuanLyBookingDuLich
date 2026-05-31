-- =============================================================================
-- SEED 09: Payments & Checkout (Module 9)
-- Mô tả: Phương thức thanh toán, Giao dịch (Upfront/Full), và Cập nhật trạng thái Booking
-- =============================================================================

-- 1. Phương thức thanh toán của người dùng (User Payment Methods)
-- Giả lập thẻ Visa/Mastercard cho Emily và Minh
INSERT INTO user_payment_methods (user_id, gateway_customer_id, payment_token, card_brand, last_4, exp_month, exp_year, is_default) VALUES
(
    (SELECT user_id FROM users WHERE email = 'emily@example.com'),
    'cus_stripe_emily_123',
    'tok_visa_4242',
    'Visa',
    '4242',
    12,
    2028,
    TRUE
),
(
    (SELECT user_id FROM users WHERE email = 'minh.tran@example.com'),
    'cus_stripe_minh_456',
    'tok_master_5555',
    'Mastercard',
    '5555',
    06,
    2027,
    TRUE
)
ON CONFLICT DO NOTHING;

-- 2. Giao dịch thanh toán (Payments)
-- Lưu ý: Trigger 'trg_after_payment_success' trong V9 sẽ tự động cập nhật booking status sang 'paid' khi status = 'success'

-- A. Thanh toán cho Tour "Da Nang - Hoi An" của Emily (Thanh toán full)
INSERT INTO payments (booking_id, user_id, amount, currency, type, status, transaction_ref, paid_at)
SELECT 
    b.booking_id,
    b.traveler_id,
    b.total_price,
    'USD',
    'full',
    'success',
    'txn_danang_full_001',
    CURRENT_TIMESTAMP - INTERVAL '2 days' -- Đã thanh toán cách đây 2 ngày
FROM bookings b
JOIN users u ON b.traveler_id = u.user_id
WHERE u.email = 'emily@example.com' 
AND b.status = 'waiting' -- Trạng thái hiện tại trước khi thanh toán
LIMIT 1
ON CONFLICT (transaction_ref) DO NOTHING;

-- B. Thanh toán đặt cọc (Upfront) cho Tour tùy chỉnh Seoul của Minh
-- Giả sử tổng giá 120$, đặt cọc 30%
INSERT INTO payments (booking_id, user_id, amount, currency, type, status, transaction_ref, paid_at)
SELECT 
    b.booking_id,
    b.traveler_id,
    b.total_price * 0.3,
    'USD',
    'upfront',
    'success',
    'txn_seoul_deposit_001',
    CURRENT_TIMESTAMP - INTERVAL '1 day'
FROM bookings b
JOIN users u ON b.traveler_id = u.user_id
WHERE u.email = 'minh.tran@example.com' 
AND b.status = 'unpaid' -- Trạng thái sau khi chấp nhận Bid
LIMIT 1
ON CONFLICT (transaction_ref) DO NOTHING;

-- C. Một giao dịch thất bại (Failed) để test UI xử lý lỗi
INSERT INTO payments (booking_id, user_id, amount, currency, type, status, transaction_ref, gateway_response)
SELECT 
    b.booking_id,
    b.traveler_id,
    150.00,
    'USD',
    'full',
    'failed',
    'txn_failed_test_001',
    '{"error_code": "card_declined", "message": "Insufficient funds"}'::jsonb
FROM bookings b
JOIN users u ON b.traveler_id = u.user_id
WHERE u.email = 'emily@example.com' 
AND b.status = 'paid' -- Chọn một booking bất kỳ của Emily để gắn log lỗi (hoặc tạo booking mới nếu cần)
LIMIT 1
ON CONFLICT (transaction_ref) DO NOTHING;

-- 3. Reset Sequences
SELECT setval('user_payment_methods_method_id_seq', (SELECT MAX(method_id) FROM user_payment_methods));
SELECT setval('payments_payment_id_seq', (SELECT MAX(payment_id) FROM payments));