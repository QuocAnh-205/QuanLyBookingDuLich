-- =============================================================================
-- SEED 03: Locations & Attractions
-- Mô tả: Cities, Tourist Spots, và cập nhật liên kết với Guide Profile
-- =============================================================================

-- 1. Địa điểm (Locations)
-- Nguồn gốc: V13
INSERT INTO locations (country_id, city_name, description, thumbnail_url, is_popular) VALUES
((SELECT country_id FROM countries WHERE country_code = '+84' LIMIT 1), 'Da Nang', 'Thành phố đáng sống nhất Việt Nam với những bãi biển tuyệt đẹp.',
'https://danangfantasticity.com/wp-content/uploads/2019/01/telegraph-co-uk-tai-sao-ban-nen-ghe-tham-da-nang-viet-nam-nam-2019-nay-012.jpg', TRUE),
((SELECT country_id FROM countries WHERE country_code = '+84' LIMIT 1), 'Ho Chi Minh City', 'Trung tâm kinh tế năng động và giàu văn hóa.',
'https://image.vietnam.travel/sites/default/files/styles/top_banner/public/2022-12/shutterstock_1939037803_0.jpg?itok=ljeHfUg9', TRUE),
((SELECT country_id FROM countries WHERE country_code = '+82' LIMIT 1), 'Seoul', 'Sự pha trộn hoàn hảo giữa cung điện cổ kính và công nghệ hiện đại.',
'https://www.agoda.com/wp-content/uploads/2024/04/Featured-image-Han-River-at-night-in-Seoul-South-Korea.jpg', TRUE),
((SELECT country_id FROM countries WHERE country_code = '+81' LIMIT 1), 'Kyoto', 'Cố đô thanh bình với hàng ngàn ngôi đền rực rỡ.',
'https://duhocvietnhat.edu.vn/wp-content/uploads/Slide3.jpg', FALSE)
ON CONFLICT (city_name) DO NOTHING;

-- 2. Cập nhật lại base_location_id cho Guide Profiles (Nếu chưa có ở Seed 02)
-- Đảm bảo Guide Anh Nguyen gắn với Da Nang, Ji-won gắn với Seoul
UPDATE guide_profiles gp
SET base_location_id = l.location_id
FROM users u
JOIN locations l ON l.city_name = CASE 
    WHEN u.email = 'anh.nguyen@fellow4u.com' THEN 'Da Nang'
    WHEN u.email = 'jiwon.park@fellow4u.com' THEN 'Seoul'
END
WHERE gp.guide_id = u.user_id
AND gp.base_location_id IS NULL;

-- 3. Điểm tham quan (Attractions)
-- Nguồn gốc: V14
-- Đà Nẵng Attractions
INSERT INTO attractions (location_id, name, address, description, image_url)
SELECT l.location_id, 'Cầu Rồng (Dragon Bridge)', 'An Hải Tây, Sơn Trà, Đà Nẵng', 'Biểu tượng của sự thịnh vượng, phun lửa và nước vào cuối tuần.', 'https://images2.thanhnien.vn/528068263637045248/2025/6/18/the-legend-danang-1-17502421275011965589401.jpg'
FROM locations l WHERE l.city_name = 'Da Nang'
UNION ALL
SELECT l.location_id, 'Ngũ Hành Sơn (Marble Mountains)', 'Hòa Hải, Ngũ Hành Sơn, Đà Nẵng', 'Quần thể 5 ngọn núi đá vôi với các hang động và chùa chiền cổ kính.', 'https://cdn.vntrip.vn/cam-nang/wp-content/uploads/2017/08/Nui-Ngu-Hanh-Son.png'
FROM locations l WHERE l.city_name = 'Da Nang'
UNION ALL
SELECT l.location_id, 'Cộng Cà Phê', '98-96 Bạch Đằng, Đà Nẵng', 'Quán cà phê phong cách bao cấp nổi tiếng, view sông Hàn.', 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/10/b2/1f/5a/come-at-night-with-less.jpg?w=900&h=500&s=1'
FROM locations l WHERE l.city_name = 'Da Nang'
ON CONFLICT DO NOTHING;

-- Seoul Attractions
INSERT INTO attractions (location_id, name, address, description, image_url)
SELECT l.location_id, 'Gyeongbokgung Palace', '161 Sajik-ro, Jongno-gu, Seoul', 'Cung điện lớn nhất và quan trọng nhất của triều đại Joseon.', 'https://www.agoda.com/wp-content/uploads/2019/05/Gyeongbokgung-palace-Seoul-architecture-view.jpg'
FROM locations l WHERE l.city_name = 'Seoul'
UNION ALL
SELECT l.location_id, 'Bukchon Hanok Village', 'Jongno-gu, Seoul', 'Làng cổ lưu giữ hàng trăm ngôi nhà truyền thống Hàn Quốc.', 'https://vj-prod-website-cms.s3.ap-southeast-1.amazonaws.com/t1-1715750175103.jpg'
FROM locations l WHERE l.city_name = 'Seoul'
ON CONFLICT DO NOTHING;

-- 4. Reset Sequences
SELECT setval('locations_location_id_seq', (SELECT MAX(location_id) FROM locations));
SELECT setval('attractions_attraction_id_seq', (SELECT MAX(attraction_id) FROM attractions));