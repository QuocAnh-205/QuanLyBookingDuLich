-- =============================================================================
-- SEED 01: Base Configuration Data
-- Mô tả: Countries, Languages, Notification Templates, Default Banners
-- =============================================================================

-- 1. Dữ liệu Quốc gia (Countries)
-- Nguồn gốc: V1 & V13
INSERT INTO countries (country_name, country_code, flag_url) VALUES
('Vietnam', '+84', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Flag_of_Vietnam.svg/960px-Flag_of_Vietnam.svg.png'),
('South Korea', '+82', 'https://upload.wikimedia.org/wikipedia/commons/0/09/Flag_of_South_Korea.svg'),
('Japan', '+81', 'https://upload.wikimedia.org/wikipedia/en/thumb/9/9e/Flag_of_Japan.svg/1280px-Flag_of_Japan.svg.png'),
('USA', '+1', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Flag_of_the_United_States_%28DDD-F-416E_specifications%29.svg/1280px-Flag_of_the_United_States_%28DDD-F-416E_specifications%29.svg.png'),
('Thailand', '+66', NULL) -- Thêm Thái Lan từ V1 gốc nếu cần
ON CONFLICT (country_code) DO UPDATE
SET country_name = EXCLUDED.country_name, 
    flag_url = COALESCE(EXCLUDED.flag_url, countries.flag_url);

-- 2. Dữ liệu Ngôn ngữ (Languages)
-- Nguồn gốc: V3
INSERT INTO languages (lang_name, lang_code) VALUES
('Vietnamese', 'vi'),
('English', 'en'),
('Korean', 'kr'),
('Japanese', 'jp')
ON CONFLICT (lang_code) DO NOTHING;

-- 3. Mẫu Thông báo (Notification Templates)
-- Nguồn gốc: V11
INSERT INTO notification_templates (category, template_key, title_pattern, body_pattern) VALUES
('booking_update', 'BOOKING_REJECTED', 'Yêu cầu bị từ chối', 'Rất tiếc, Guide đã từ chối yêu cầu của bạn.'),
('review_reminder', 'LEAVE_REVIEW', 'Kỷ niệm chuyến đi', 'Chuyến đi đã kết thúc, hãy để lại đánh giá cho {guide_name} nhé!'),
('booking_update', 'BOOKING_ACCEPTED', 'Yêu cầu đã được chấp nhận', 'Guide {guide_name} đã chấp nhận yêu cầu chuyến đi của bạn.'),
('payment_status', 'PAYMENT_SUCCESS', 'Thanh toán thành công', 'Chúng tôi đã nhận được thanh toán cho đơn hàng #{booking_id}.')
ON CONFLICT (template_key) DO UPDATE
SET title_pattern = EXCLUDED.title_pattern,
    body_pattern = EXCLUDED.body_pattern;

-- 4. Banner Mặc định (App Banners)
-- Nguồn gốc: V6 & V16
INSERT INTO app_banners (page_type, title_text, subtitle_text, image_url, is_active) VALUES
('Guides_More', 'Private Local Guides', 'Find the perfect companion for your journey', 'https://www.agoda.com/wp-content/uploads/2019/05/Gyeongbokgung-palace-Seoul-architecture-view.jpg', TRUE),
('Tours_More', 'Discovery Tours', 'Authentic experiences curated by locals', 'https://ohdidi.vn/uploads/static/NEWS/blog/du%20lich%20da%20nang%20hoi%20an/du_lich_da_nang_hoi_an_2.png', TRUE)
ON CONFLICT DO NOTHING;

-- 5. Reset Sequences cho các bảng trên
SELECT setval('countries_country_id_seq', (SELECT MAX(country_id) FROM countries));
SELECT setval('languages_lang_id_seq', (SELECT MAX(lang_id) FROM languages));
SELECT setval('notification_templates_template_id_seq', (SELECT MAX(template_id) FROM notification_templates));
SELECT setval('app_banners_banner_id_seq', (SELECT MAX(banner_id) FROM app_banners));