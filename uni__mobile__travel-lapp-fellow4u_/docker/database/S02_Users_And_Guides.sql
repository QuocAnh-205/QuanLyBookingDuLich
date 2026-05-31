-- =============================================================================
-- SEED 02: Users, Guides & Pricing
-- Mô tả: Users, Social Accounts, Guide Profiles, Guide Languages, Guide Pricing
-- =============================================================================

-- 1. Người dùng (Users)
-- Nguồn gốc: V13
-- Password hash mẫu: '$2a$12$obyHHLqZ1.98KEZjg8ZSZ.Q/W710jX8.dm7UxWL4BmhZhDVdI85li' (mật khẩu: password)
INSERT INTO users (role, first_name, last_name, email, password_hash, country_id, avatar_url, bio) VALUES
('Traveler', 'Emily', 'Watson', 'emily@example.com', '$2a$12$obyHHLqZ1.98KEZjg8ZSZ.Q/W710jX8.dm7UxWL4BmhZhDVdI85li',
    (SELECT country_id FROM countries WHERE country_code = '+1' LIMIT 1), 
    'https://i.pravatar.cc/150?u=emily', 
    'Love traveling and photography.'),
('Guide', 'Anh', 'Nguyen', 'anh.nguyen@fellow4u.com', '$2a$12$obyHHLqZ1.98KEZjg8ZSZ.Q/W710jX8.dm7UxWL4BmhZhDVdI85li',
    (SELECT country_id FROM countries WHERE country_code = '+84' LIMIT 1), 
    'https://thanhnien.mediacdn.vn/Uploaded/ngocthanh/2016_03_23/9x01_YGEO.jpg?width=500',
    'Xin chào! Mình là Anh, một người đam mê ẩm thực đường phố Đà Nẵng.'),
('Guide', 'Ji-won', 'Park', 'jiwon.park@fellow4u.com', '$2a$12$obyHHLqZ1.98KEZjg8ZSZ.Q/W710jX8.dm7UxWL4BmhZhDVdI85li',
    (SELECT country_id FROM countries WHERE country_code = '+82' LIMIT 1), 
    'https://www.paratime.vn/wp-content/uploads/2019/09/timestudio.vn-headshot-eye-glasses-02.jpg',
    'Welcome to Seoul! I specialize in historical palace tours.'),
('Traveler', 'Minh', 'Tran', 'minh.tran@example.com', '$2a$12$obyHHLqZ1.98KEZjg8ZSZ.Q/W710jX8.dm7UxWL4BmhZhDVdI85li',
    (SELECT country_id FROM countries WHERE country_code = '+84' LIMIT 1), 
    'https://i.pravatar.cc/150?u=minh',
    NULL)
ON CONFLICT (email) DO NOTHING;

-- 2. Tài khoản Xã hội (Social Accounts)
-- Nguồn gốc: V13
INSERT INTO social_accounts (social_id, user_id, provider) VALUES
('fb_123456789', (SELECT user_id FROM users WHERE email = 'emily@example.com'), 'FB'),
('kakao_987654321', (SELECT user_id FROM users WHERE email = 'jiwon.park@fellow4u.com'), 'Kakao')
ON CONFLICT DO NOTHING;

-- 3. Hồ sơ Guide (Guide Profiles)
-- Nguồn gốc: V13
-- Lưu ý: Chỉ insert cho những user có role = 'Guide'
INSERT INTO guide_profiles (guide_id, bio, base_location_id, rating_avg, total_reviews, is_verified)
SELECT 
    u.user_id,
    u.bio, -- Lấy bio tạm từ users, sau đó có thể update riêng nếu cần chi tiết hơn
    NULL,  -- base_location_id sẽ được cập nhật sau khi có Locations ở Seed 03 hoặc dùng subquery nếu location đã có
    CASE WHEN u.email = 'anh.nguyen@fellow4u.com' THEN 4.9 ELSE 4.8 END,
    CASE WHEN u.email = 'anh.nguyen@fellow4u.com' THEN 120 ELSE 85 END,
    TRUE
FROM users u
WHERE u.email IN ('anh.nguyen@fellow4u.com', 'jiwon.park@fellow4u.com')
ON CONFLICT (guide_id) DO NOTHING;

-- Cập nhật base_location_id cho Guide (Giả sử Location đã có hoặc sẽ có, ở đây ta dùng subquery an toàn)
-- Nếu Location chưa có, trường này sẽ NULL. Ta sẽ update lại trong Seed 03 nếu cần, hoặc chạy seed theo thứ tự.
-- Để an toàn, ta chờ Seed 03 chạy xong locations, rồi update lại ở đây hoặc dùng script riêng. 
-- Tuy nhiên, để giữ tính module, ta sẽ insert Guide Profile trước, Location sau. 
-- *Điều chỉnh:* Tốt nhất là Seed 03 chạy trước Seed 02 phần Location? Không, User độc lập. 
-- Ta sẽ để base_location_id NULL tạm thời, hoặc update sau khi Seed 03 chạy.
-- Cách tốt hơn: Dùng subquery trực tiếp nếu location đã tồn tại. Nếu chưa, nó sẽ NULL.
UPDATE guide_profiles gp
SET base_location_id = l.location_id
FROM locations l, users u
WHERE gp.guide_id = u.user_id
AND l.city_name = CASE 
    WHEN u.email = 'anh.nguyen@fellow4u.com' THEN 'Da Nang'
    WHEN u.email = 'jiwon.park@fellow4u.com' THEN 'Seoul'
    ELSE NULL END
AND gp.base_location_id IS NULL;


-- 4. Ngôn ngữ của Guide (Guide Languages)
-- Nguồn gốc: V14
INSERT INTO guide_languages (guide_id, lang_id)
SELECT u.user_id, l.lang_id
FROM users u
CROSS JOIN languages l
WHERE u.email = 'anh.nguyen@fellow4u.com' AND l.lang_code IN ('vi', 'en')
UNION ALL
SELECT u.user_id, l.lang_id
FROM users u
CROSS JOIN languages l
WHERE u.email = 'jiwon.park@fellow4u.com' AND l.lang_code IN ('kr', 'en', 'jp')
ON CONFLICT DO NOTHING;

-- 5. Bảng giá Guide (Guide Pricing)
-- Nguồn gốc: V14
INSERT INTO guide_pricing (guide_id, min_travelers, max_travelers, price_per_hour)
SELECT u.user_id, 1, 2, 10.00 FROM users u WHERE u.email = 'anh.nguyen@fellow4u.com'
UNION ALL
SELECT u.user_id, 3, 5, 15.00 FROM users u WHERE u.email = 'anh.nguyen@fellow4u.com'
UNION ALL
SELECT u.user_id, 6, 10, 25.00 FROM users u WHERE u.email = 'anh.nguyen@fellow4u.com'
UNION ALL
SELECT u.user_id, 1, 3, 20.00 FROM users u WHERE u.email = 'jiwon.park@fellow4u.com'
UNION ALL
SELECT u.user_id, 4, 6, 35.00 FROM users u WHERE u.email = 'jiwon.park@fellow4u.com'
ON CONFLICT DO NOTHING;

-- 6. Reset Sequences
SELECT setval('users_user_id_seq', (SELECT MAX(user_id) FROM users));
-- Sequence not needed for guide_profiles
SELECT setval('guide_pricing_price_id_seq', (SELECT MAX(price_id) FROM guide_pricing));