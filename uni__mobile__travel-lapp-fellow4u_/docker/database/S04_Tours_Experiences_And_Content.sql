-- =============================================================================
-- SEED 04: Tours, Experiences & Content
-- Mô tả: Providers, Tours, Tour Details (Images, Schedules, Pricing), Experiences, News
-- =============================================================================

-- 1. Đơn vị cung cấp Tour (Providers)
-- Nguồn gốc: V15
-- Dọn dẹp bản ghi trùng lặp nếu đã chạy nhiều lần trước khi có ràng buộc UNIQUE
DELETE FROM tour_providers a USING tour_providers b 
WHERE a.provider_id < b.provider_id AND a.name = b.name;

INSERT INTO tour_providers (name, website_url, logo_url, rating_avg, description) VALUES
('VietTraveler Co.', 'https://viettraveler.com', 'https://i.pravatar.cc/150?u=viettraveler', 4.9, 'Top rated local tour agency in Da Nang with 10 years of experience.'),
('Sea Sun Tours', 'https://seasuntours.com', 'https://i.pravatar.cc/150?u=seasun', 4.7, 'Specializing in beach and island adventures.')
ON CONFLICT (name) DO NOTHING;

-- 2. Tour dài ngày (Tours)
-- Nguồn gốc: V13 & V15
-- Lưu ý: Cần Location ID từ SEED 03 và Provider ID vừa tạo ở trên.
INSERT INTO tours (title, location_id, price, duration_days, is_featured, thumbnail_url, provider_id, pickup_point)
SELECT DISTINCT
    'Da Nang - Hoi An 3 Days Adventure',
    l.location_id,
    150.00,
    3,
    TRUE,
    'https://truongsatour.com/uploads/images/%5BDownloader_la%5D-6593cb5ce65c7.jpg',
    p.provider_id,
    'Da Nang International Airport (Terminal 1)'
FROM locations l, tour_providers p
WHERE l.city_name = 'Da Nang' AND p.name = 'VietTraveler Co.'
ON CONFLICT (title) DO UPDATE SET
    provider_id = EXCLUDED.provider_id,
    pickup_point = EXCLUDED.pickup_point;

INSERT INTO tours (title, location_id, price, duration_days, is_featured, thumbnail_url)
SELECT 
    'Explore Seoul Like a Local',
    l.location_id,
    299.00,
    5,
    TRUE,
    'https://skyticket.com/guide/wp-content/uploads/2017/12/iStock-502607495-e1534733959975.jpg'
FROM locations l
WHERE l.city_name = 'Seoul'
ON CONFLICT (title) DO NOTHING;

INSERT INTO tours (title, location_id, price, duration_days, is_featured, thumbnail_url)
SELECT 
    'Street Food Paradise in Saigon',
    l.location_id,
    80.00,
    1,
    FALSE,
    'https://image.vietnam.travel/sites/default/files/styles/top_banner/public/2022-12/shutterstock_1939037803_0.jpg?itok=ljeHfUg9'
FROM locations l
WHERE l.city_name = 'Ho Chi Minh City'
ON CONFLICT (title) DO NOTHING;

-- 3. Thư viện ảnh Tour (Tour Images)
-- Nguồn gốc: V15
-- Giả định Tour "Da Nang - Hoi An 3 Days Adventure" đã có ID. Dùng subquery để lấy ID động.
INSERT INTO tour_images (tour_id, image_url, display_order, caption)
SELECT DISTINCT t.tour_id, img.url, img.ord, img.cap
FROM tours t
CROSS JOIN (
    VALUES 
        ('https://truongsatour.com/uploads/images/%5BDownloader_la%5D-6593cb5ce65c7.jpg', 1, 'Da Nang - Hoi An Overview'),
        ('https://images2.thanhnien.vn/528068263637045248/2025/6/18/the-legend-danang-1-17502421275011965589401.jpg', 2, 'Dragon Bridge'),
        ('https://cdn.vntrip.vn/cam-nang/wp-content/uploads/2017/08/Nui-Ngu-Hanh-Son.png', 3, 'Marble Mountains')
) AS img(url, ord, cap)
WHERE t.title = 'Da Nang - Hoi An 3 Days Adventure'
ON CONFLICT DO NOTHING;

-- 4. Lịch trình Tour (Tour Schedules)
-- Nguồn gốc: V15
INSERT INTO tour_schedules (tour_id, day_number, start_time, activity_title, description)
SELECT DISTINCT t.tour_id, s.day_num, s.start_tm::TIME, s.title, s.description
FROM tours t
CROSS JOIN (
    VALUES 
        (1, '08:00:00', 'Airport Pickup', 'Our guide will meet you at the arrival hall with a Fellow4U sign.'),
        (1, '10:30:00', 'Hotel Check-in', 'Check-in at Furama Resort Da Nang and rest.'),
        (1, '15:00:00', 'Marble Mountains Visit', 'Explore the mystical caves and ancient pagodas.'),
        (2, '09:00:00', 'Bana Hills Adventure', 'Full day exploring the French Village and Golden Bridge.'),
        (2, '18:00:00', 'Seafood Dinner', 'Fresh seafood feast at a local restaurant by the beach.'),
        (3, '08:00:00', 'Hoi An Ancient Town', 'A walking tour through the beautiful lanterns and old houses.'),
        (3, '14:00:00', 'Souvenir Shopping', 'Free time to buy local gifts before heading to the airport.')
) AS s(day_num, start_tm, title, description)
WHERE t.title = 'Da Nang - Hoi An 3 Days Adventure'
ON CONFLICT DO NOTHING;

-- 5. Giá theo độ tuổi (Tour Age Pricing)
-- Nguồn gốc: V15
INSERT INTO tour_age_pricing (tour_id, age_group_label, price)
SELECT DISTINCT t.tour_id, p.label, p.price
FROM tours t
CROSS JOIN (
    VALUES 
        ('Adult (12+ years)', 150.00),
        ('Child (5-11 years)', 95.00),
        ('Infant (Under 5)', 0.00)
) AS p(label, price)
WHERE t.title = 'Da Nang - Hoi An 3 Days Adventure'
ON CONFLICT DO NOTHING;

-- 6. Trải nghiệm ngắn hạn (Experiences)
-- Nguồn gốc: V13
-- Cần Guide ID và Location ID
INSERT INTO experiences (guide_id, title, location_id, price, duration_hours, thumbnail_url)
SELECT DISTINCT
    u.user_id,
    'Morning Coffee & Dragon Bridge Walk',
    l.location_id,
    15.00,
    2.5,
    'https://images2.thanhnien.vn/528068263637045248/2025/6/18/the-legend-danang-1-17502421275011965589401.jpg'
FROM users u, locations l
WHERE u.email = 'anh.nguyen@fellow4u.com' AND l.city_name = 'Da Nang'
ON CONFLICT (title) DO NOTHING;

INSERT INTO experiences (guide_id, title, location_id, price, duration_hours, thumbnail_url)
SELECT DISTINCT
    u.user_id,
    'Han River Night Picnic with Chimaek',
    l.location_id,
    35.00,
    3.0,
    'https://static.wixstatic.com/media/0505b9_a4f9859e88774a7a84071de78b228270~mv2.jpg/v1/fill/w_640,h_496,al_c,q_80,usm_0.66_1.00_0.01,enc_avif,quality_auto/0505b9_a4f9859e88774a7a84071de78b228270~mv2.jpg'
FROM users u, locations l
WHERE u.email = 'jiwon.park@fellow4u.com' AND l.city_name = 'Seoul'
ON CONFLICT (title) DO NOTHING;

-- 7. Tin tức du lịch (Travel News)
-- Nguồn gốc: V13
INSERT INTO travel_news (title, content, metadata, image_url) VALUES
('Top 10 Coffee Shops in Da Nang', 'Da Nang is famous for its unique coffee culture...', '{"tags": ["coffee", "lifestyle"], "author": "Fellow4U Team"}',
'https://hoangphuan.com/wp-content/uploads/2024/06/tour-du-lich-da-nang-1.jpg'),
('Moving to Seoul: A Travel Guide', 'Everything you need to know before visiting South Korea...', '{"tags": ["korea", "guide"], "author": "Ji-won"}',
'https://letseoul.com/_next/image?url=%2Fimages%2Fhero-seoul-night.jpg&w=3840&q=75')
ON CONFLICT (title) DO NOTHING;

-- 8. Reset Sequences
SELECT setval('tour_providers_provider_id_seq', (SELECT MAX(provider_id) FROM tour_providers));
SELECT setval('tours_tour_id_seq', (SELECT MAX(tour_id) FROM tours));
SELECT setval('tour_images_image_id_seq', (SELECT MAX(image_id) FROM tour_images));
SELECT setval('tour_schedules_schedule_id_seq', (SELECT MAX(schedule_id) FROM tour_schedules));
SELECT setval('tour_age_pricing_price_id_seq', (SELECT MAX(price_id) FROM tour_age_pricing));
SELECT setval('experiences_exp_id_seq', (SELECT MAX(exp_id) FROM experiences));
SELECT setval('travel_news_news_id_seq', (SELECT MAX(news_id) FROM travel_news));