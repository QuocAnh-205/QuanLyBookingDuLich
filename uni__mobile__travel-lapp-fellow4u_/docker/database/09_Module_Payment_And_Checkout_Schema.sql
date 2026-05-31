-- =============================================================================
-- Dự án: Fellow4U
-- Module: 09 - Thanh toán & Checkout
-- Mô tả: Quản lý phương thức thanh toán, giao dịch (Upfront/Final) và bảo mật.
-- =============================================================================

-- 1. Khởi tạo kiểu dữ liệu ENUM cho thanh toán
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
        CREATE TYPE payment_status AS ENUM ('pending', 'success', 'failed', 'refunded');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_type') THEN
        CREATE TYPE payment_type AS ENUM ('upfront', 'final', 'full');
    END IF;
END $$;

-- 2. Bảng User_Payment_Methods (Phương thức thanh toán của người dùng)
CREATE TABLE IF NOT EXISTS user_payment_methods (
    method_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    gateway_customer_id VARCHAR(255), -- ID khách hàng trên hệ thống thanh toán (Stripe Customer ID)
    payment_token VARCHAR(255) NOT NULL, -- Token đại diện cho thẻ
    card_brand VARCHAR(50), -- Visa, Mastercard, ...
    last_4 CHAR(4), -- 4 số cuối để hiển thị trên UI
    exp_month INT,
    exp_year INT,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Bảng Payments (Quản lý giao dịch thực tế)
CREATE TABLE IF NOT EXISTS payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(user_id), -- Người thực hiện thanh toán
    
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(10) DEFAULT 'USD',
    
    type payment_type NOT NULL DEFAULT 'upfront',
    status payment_status DEFAULT 'pending',
    
    transaction_ref VARCHAR(255) UNIQUE, -- Mã giao dịch từ Gateway (Stripe Transaction ID)
    gateway_response JSONB, -- Lưu toàn bộ phản hồi từ API để đối soát khi có lỗi
    
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Bảng Refund_Requests (Xử lý hoàn tiền - Mở rộng cho nghiệp vụ thực tế)
CREATE TABLE IF NOT EXISTS refund_requests (
    refund_id SERIAL PRIMARY KEY,
    payment_id INT NOT NULL REFERENCES payments(payment_id),
    amount DECIMAL(12, 2) NOT NULL,
    reason TEXT,
    status payment_status DEFAULT 'pending',
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Tối ưu hóa truy vấn và bảo mật
CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_user_payment_methods_user ON user_payment_methods(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_ref ON payments(transaction_ref);

-- 6. Trigger tự động cập nhật updated_at
DROP TRIGGER IF EXISTS update_payments_modtime ON payments;
CREATE TRIGGER update_payments_modtime
    BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- 7. Logic tự động cập nhật trạng thái Booking sau khi thanh toán
CREATE OR REPLACE FUNCTION update_booking_after_payment()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.status = 'success') THEN
        -- Nếu là thanh toán đặt cọc hoặc toàn bộ, chuyển trạng thái đơn hàng
        IF (NEW.type IN ('upfront', 'full')) THEN
            UPDATE bookings SET status = 'paid' WHERE booking_id = NEW.booking_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_after_payment_success ON payments;
CREATE TRIGGER trg_after_payment_success
    AFTER UPDATE OF status ON payments
    FOR EACH ROW
    WHEN (OLD.status = 'pending' AND NEW.status = 'success')
    EXECUTE PROCEDURE update_booking_after_payment();