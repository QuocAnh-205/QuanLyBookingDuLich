-- =============================================================================
-- SEED 12: Profile & Personal Content (Module 12)
-- Mô tả: User Photos, Journeys (Albums), Settings, Security Logs
-- =============================================================================

-- 1. Cập nhật thông tin mở rộng cho Users (Bio, DOB, Gender)
UPDATE users SET
    bio = CASE 
        WHEN email = 'emily@example.com' THEN 'Love traveling and photography. Always looking for hidden gems.'
        WHEN email = 'minh.tran@example.com' THEN 'Digital nomad exploring Asia. Foodie and history buff.'
        ELSE bio 
    END,
    cover_url = CASE 
        WHEN email = 'emily@example.com' THEN 'https://images.pexels.com/photos/37294136/pexels-photo-37294136.jpeg'
        WHEN email = 'minh.tran@example.com' THEN 'https://images.pexels.com/photos/28993988/pexels-photo-28993988.jpeg'
        ELSE cover_url 
    END,
    date_of_birth = CASE 
        WHEN email = 'emily@example.com' THEN '1995-05-15'
        WHEN email = 'minh.tran@example.com' THEN '1990-11-20'
        ELSE date_of_birth 
    END,
    gender = CASE 
        WHEN email = 'emily@example.com' THEN 'Female'
        WHEN email = 'minh.tran@example.com' THEN 'Male'
        ELSE gender 
    END
WHERE email IN ('emily@example.com', 'minh.tran@example.com');

-- 2. Kho ảnh cá nhân (User Photos)
INSERT INTO user_photos (user_id, image_url, storage_provider, width, height, is_public, uploaded_at) VALUES
-- Emily's Photos (Da Nang Trip)
-- [USER ADD PHOTOS HERE]
((SELECT user_id FROM users WHERE email = 'emily@example.com'), 'https://images.pexels.com/photos/35466382/pexels-photo-35466382.jpeg', 'local', 1080, 1080, TRUE, CURRENT_TIMESTAMP - INTERVAL '10 days'),
((SELECT user_id FROM users WHERE email = 'emily@example.com'), 'https://images.pexels.com/photos/36890282/pexels-photo-36890282.jpeg', 'local', 1080, 1350, TRUE, CURRENT_TIMESTAMP - INTERVAL '8 days'),
((SELECT user_id FROM users WHERE email = 'emily@example.com'), 'https://images.pexels.com/photos/12491694/pexels-photo-12491694.jpeg', 'local', 1080, 1350, TRUE, CURRENT_TIMESTAMP - INTERVAL '8 days'),
((SELECT user_id FROM users WHERE email = 'emily@example.com'), 'https://images.pexels.com/photos/29399452/pexels-photo-29399452.jpeg', 'local', 1080, 1350, TRUE, CURRENT_TIMESTAMP - INTERVAL '8 days'),
-- Minh's Photos (Seoul Trip)
-- [USER ADD PHOTOS HERE]
((SELECT user_id FROM users WHERE email = 'minh.tran@example.com'), 'https://images.pexels.com/photos/37425324/pexels-photo-37425324.jpeg', 'local', 1080, 1080, TRUE, CURRENT_TIMESTAMP - INTERVAL '5 days'),
((SELECT user_id FROM users WHERE email = 'minh.tran@example.com'), 'https://images.pexels.com/photos/29399452/pexels-photo-29399452.jpeg', 'local', 1080, 1080, TRUE, CURRENT_TIMESTAMP - INTERVAL '5 days'),
((SELECT user_id FROM users WHERE email = 'minh.tran@example.com'), 'https://images.pexels.com/photos/12491694/pexels-photo-12491694.jpeg', 'local', 1080, 1080, TRUE, CURRENT_TIMESTAMP - INTERVAL '5 days')
ON CONFLICT (user_id, image_url) DO NOTHING;

-- 3. Nhật ký hành trình (User Journeys / Albums)
INSERT INTO user_journeys (user_id, title, location_name, description, likes_count, created_date)
SELECT user_id, 'Da Nang Memories 2024', 'Da Nang, Vietnam', 'An unforgettable trip with amazing food and views.', 234, CURRENT_DATE - INTERVAL '5 days' FROM users WHERE email = 'emily@example.com'
ON CONFLICT (user_id, title) DO UPDATE SET likes_count = EXCLUDED.likes_count;

INSERT INTO user_journeys (user_id, title, location_name, description, likes_count, created_date)
SELECT user_id, 'Seoul Autumn Vibes', 'Seoul, South Korea', 'Beautiful leaves and historic palaces.', 156, CURRENT_DATE - INTERVAL '2 days' FROM users WHERE email = 'minh.tran@example.com'
ON CONFLICT (user_id, title) DO UPDATE SET likes_count = EXCLUDED.likes_count;

-- 4. Gắn ảnh vào Hành trình (Journey Media)
-- Clear old media to avoid confusion if needed, but since it's a seed, we can just insert with ON CONFLICT
-- Gắn ảnh của Emily vào album Da Nang
-- [USER LINK PHOTOS TO JOURNEY HERE]
INSERT INTO journey_media (journey_id, photo_id, display_order)
SELECT 
    j.journey_id,
    p.photo_id,
    1
FROM user_journeys j
JOIN user_photos p ON p.user_id = j.user_id
JOIN users u ON u.user_id = j.user_id
WHERE u.email = 'emily@example.com'
AND j.title = 'Da Nang Memories 2024'
AND p.image_url = 'https://ik.imagekit.io/tvlk/blog/2022/09/dia-diem-check-in-da-nang-cover.jpeg'
ON CONFLICT (journey_id, photo_id) DO NOTHING;

INSERT INTO journey_media (journey_id, photo_id, display_order)
SELECT 
    j.journey_id,
    p.photo_id,
    2
FROM user_journeys j
JOIN user_photos p ON p.user_id = j.user_id
JOIN users u ON u.user_id = j.user_id
WHERE u.email = 'emily@example.com'
AND j.title = 'Da Nang Memories 2024'
AND p.image_url = 'https://hoangphuan.com/wp-content/uploads/2024/07/tat-tan-tat-kinh-nghiem-du-lich-tour-da-nang-ma-ban-phai-biet.jpg'
ON CONFLICT (journey_id, photo_id) DO NOTHING;

INSERT INTO journey_media (journey_id, photo_id, display_order)
SELECT 
    j.journey_id,
    p.photo_id,
    3
FROM user_journeys j
JOIN user_photos p ON p.user_id = j.user_id
JOIN users u ON u.user_id = j.user_id
WHERE u.email = 'emily@example.com'
AND j.title = 'Da Nang Memories 2024'
AND p.image_url = 'https://danangfantasticity.com/wp-content/uploads/2018/10/co-mot-da-nang-that-dep-qua-goc-nhin-cua-cac-nhiep-anh-gia-cuoc-thi-anh-dep-du-lich-da-nang-tuyet-voi-da-nang-oi-mua-2-006.jpg'
ON CONFLICT (journey_id, photo_id) DO NOTHING;

-- 5. Cài đặt người dùng (User Settings)
INSERT INTO user_settings (user_id, preferred_language, preferred_currency, enable_push_notifications, enable_email_notifications, theme_mode) VALUES
((SELECT user_id FROM users WHERE email = 'emily@example.com'), 'en', 'USD', TRUE, TRUE, 'light'),
((SELECT user_id FROM users WHERE email = 'minh.tran@example.com'), 'vi', 'VND', TRUE, FALSE, 'dark'),
((SELECT user_id FROM users WHERE email = 'anh.nguyen@fellow4u.com'), 'vi', 'VND', TRUE, TRUE, 'system'),
((SELECT user_id FROM users WHERE email = 'jiwon.park@fellow4u.com'), 'kr', 'KRW', TRUE, TRUE, 'light')
ON CONFLICT (user_id) DO UPDATE SET
    preferred_language = EXCLUDED.preferred_language,
    preferred_currency = EXCLUDED.preferred_currency;

-- 6. Nhật ký bảo mật (Security Logs)
INSERT INTO security_logs (user_id, action_type, ip_address, device_info, created_at) VALUES
((SELECT user_id FROM users WHERE email = 'emily@example.com'), 'LOGIN_ATTEMPT', '192.168.1.100', 'iPhone 14 Pro / iOS 17', CURRENT_TIMESTAMP - INTERVAL '1 hour'),
((SELECT user_id FROM users WHERE email = 'minh.tran@example.com'), 'PASSWORD_CHANGE', '192.168.1.101', 'Samsung Galaxy S23 / Android 14', CURRENT_TIMESTAMP - INTERVAL '24 hours'),
((SELECT user_id FROM users WHERE email = 'anh.nguyen@fellow4u.com'), 'LOGIN_ATTEMPT', '10.0.0.5', 'Windows 11 / Chrome', CURRENT_TIMESTAMP - INTERVAL '30 minutes')
ON CONFLICT DO NOTHING;

-- 7. Reset Sequences
SELECT setval('user_photos_photo_id_seq', (SELECT MAX(photo_id) FROM user_photos));
SELECT setval('user_journeys_journey_id_seq', (SELECT MAX(journey_id) FROM user_journeys));
SELECT setval('security_logs_log_id_seq', (SELECT MAX(log_id) FROM security_logs));