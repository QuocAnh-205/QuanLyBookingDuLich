-- =============================================================================
-- SEED 07: Trip Requests & Bidding (Module 8)
-- Mô tả: Yêu cầu chuyến đi tùy chỉnh, Địa điểm chọn lọc, Ngôn ngữ yêu cầu
-- =============================================================================

-- 1. Yêu cầu chuyến đi (Trip Requests)
-- Nguồn gốc: Logic Module 8
-- Emily muốn một tour Đà Nẵng ngắn ngày
INSERT INTO trip_requests (user_id, destination_name, location_id, start_date, start_time, end_time, travelers_count, budget_per_hour, status, description)
SELECT 
    u.user_id,
    'Da Nang City Tour',
    l.location_id,
    CURRENT_DATE + INTERVAL '5 days',
    '09:00:00',
    '17:00:00',
    2,
    15.00,
    'active',
    'I want to visit Dragon Bridge and have coffee at a local spot. Prefer English speaking guide.'
FROM users u, locations l
WHERE u.email = 'emily@example.com' AND l.city_name = 'Da Nang'
ON CONFLICT DO NOTHING;

-- Minh Tran muốn một tour Seoul văn hóa
INSERT INTO trip_requests (user_id, destination_name, location_id, start_date, start_time, end_time, travelers_count, budget_per_hour, status, description)
SELECT 
    u.user_id,
    'Seoul Cultural Experience',
    l.location_id,
    CURRENT_DATE + INTERVAL '10 days',
    '10:00:00',
    '16:00:00',
    1,
    25.00,
    'active',
    'Interested in Palaces and Hanok Village. Need Korean/English guide.'
FROM users u, locations l
WHERE u.email = 'minh.tran@example.com' AND l.city_name = 'Seoul'
ON CONFLICT DO NOTHING;

-- 2. Địa điểm yêu thích trong Request (Request Attractions)
-- Gắn các Attractions đã tạo ở Seed 03 vào Request tương ứng
INSERT INTO request_attractions (request_id, attraction_id, sort_order)
SELECT 
    tr.request_id,
    a.attraction_id,
    1
FROM trip_requests tr
JOIN attractions a ON a.name = 'Cầu Rồng (Dragon Bridge)'
WHERE tr.destination_name = 'Da Nang City Tour'
AND tr.user_id = (SELECT user_id FROM users WHERE email = 'emily@example.com')
ON CONFLICT DO NOTHING;

INSERT INTO request_attractions (request_id, attraction_id, sort_order)
SELECT 
    tr.request_id,
    a.attraction_id,
    1
FROM trip_requests tr
JOIN attractions a ON a.name = 'Gyeongbokgung Palace'
WHERE tr.destination_name = 'Seoul Cultural Experience'
AND tr.user_id = (SELECT user_id FROM users WHERE email = 'minh.tran@example.com')
UNION ALL
SELECT 
    tr.request_id,
    a.attraction_id,
    2
FROM trip_requests tr
JOIN attractions a ON a.name = 'Bukchon Hanok Village'
WHERE tr.destination_name = 'Seoul Cultural Experience'
AND tr.user_id = (SELECT user_id FROM users WHERE email = 'minh.tran@example.com')
ON CONFLICT DO NOTHING;

-- 3. Ngôn ngữ yêu cầu (Request Languages)
-- Emily yêu cầu tiếng Anh
INSERT INTO request_languages (request_id, lang_id)
SELECT 
    tr.request_id,
    l.lang_id
FROM trip_requests tr
CROSS JOIN languages l
WHERE tr.destination_name = 'Da Nang City Tour'
AND tr.user_id = (SELECT user_id FROM users WHERE email = 'emily@example.com')
AND l.lang_code = 'en'
ON CONFLICT DO NOTHING;

-- Minh yêu cầu tiếng Hàn và Tiếng Anh
INSERT INTO request_languages (request_id, lang_id)
SELECT 
    tr.request_id,
    l.lang_id
FROM trip_requests tr
CROSS JOIN languages l
WHERE tr.destination_name = 'Seoul Cultural Experience'
AND tr.user_id = (SELECT user_id FROM users WHERE email = 'minh.tran@example.com')
AND l.lang_code IN ('kr', 'en')
ON CONFLICT DO NOTHING;

-- 4. Reset Sequences
SELECT setval('trip_requests_request_id_seq', (SELECT MAX(request_id) FROM trip_requests));