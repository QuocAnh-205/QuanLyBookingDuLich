-- =============================================================================
-- SEED 05: Collections & Interactions
-- Mô tả: Reviews, Portfolio Media, Collections, Collection Items
-- =============================================================================

-- 1. Đánh giá (Reviews)
-- Nguồn gốc: V14
-- Phụ thuộc: Users (Authors), Guide Profiles
INSERT INTO reviews (guide_id, author_id, rating, comment)
SELECT 
    g.guide_id,
    u_author.user_id,
    r.rating,
    r.comment
FROM guide_profiles g
JOIN users u_guide ON g.guide_id = u_guide.user_id
CROSS JOIN (
    VALUES 
        ('emily@example.com', 5, 'Anh is the best! She showed us places we could never find on Google Maps. The food was amazing!'),
        ('minh.tran@example.com', 4, 'Rất nhiệt tình, am hiểu lịch sử địa phương. Highly recommend!')
) AS r(author_email, rating, comment)
JOIN users u_author ON u_author.email = r.author_email
WHERE u_guide.email = 'anh.nguyen@fellow4u.com'
ON CONFLICT DO NOTHING;

INSERT INTO reviews (guide_id, author_id, rating, comment)
SELECT 
    g.guide_id,
    u_author.user_id,
    r.rating,
    r.comment
FROM guide_profiles g
JOIN users u_guide ON g.guide_id = u_guide.user_id
CROSS JOIN (
    VALUES 
        ('emily@example.com', 5, 'Perfect palace tour. Her English is excellent and she knows all the best photo spots.')
) AS r(author_email, rating, comment)
JOIN users u_author ON u_author.email = r.author_email
WHERE u_guide.email = 'jiwon.park@fellow4u.com'
ON CONFLICT DO NOTHING;

-- 2. Kho tư liệu Guide (Portfolio Media)
-- Nguồn gốc: V14
INSERT INTO guide_portfolio_media (guide_id, media_url, media_type, title, display_order)
SELECT 
    u.user_id,
    m.url,
    m.type::portfolio_media_type,
    m.title,
    m.ord
FROM users u
CROSS JOIN (
    VALUES 
        ('https://thanhnien.mediacdn.vn/Uploaded/ngocthanh/2016_03_23/9x01_YGEO.jpg?width=500', 'image', 'Street Food Tour with US guests', 1),
        ('https://cdn.fellow4u.com/portfolio/anh_video_intro.mp4', 'video', 'Introduction to Da Nang', 2)
) AS m(url, type, title, ord)
WHERE u.email = 'anh.nguyen@fellow4u.com'
ON CONFLICT DO NOTHING;

INSERT INTO guide_portfolio_media (guide_id, media_url, media_type, title, display_order)
SELECT 
    u.user_id,
    m.url,
    m.type::portfolio_media_type,
    m.title,
    m.ord
FROM users u
CROSS JOIN (
    VALUES 
        ('https://www.paratime.vn/wp-content/uploads/2019/09/timestudio.vn-headshot-eye-glasses-02.jpg', 'image', 'Traditional Hanbok Experience', 1)
) AS m(url, type, title, ord)
WHERE u.email = 'jiwon.park@fellow4u.com'
ON CONFLICT DO NOTHING;

-- 3. Bộ sưu tập (Collections)
-- Nguồn gốc: V16
INSERT INTO collections (name, slug, description, item_type, is_public) VALUES
('Best Guides in Da Nang', 'best-guides', 'Discover the most experienced and high-rated local guides in your destination.', 'guide', TRUE),
('Featured Tours 2026', 'featured-tours', 'Explore our hand-picked selection of the most amazing journeys across the country.', 'tour', TRUE),
('Top Rated Guides', 'top-rated-guides', 'Our most loved local experts based on traveler reviews.', 'guide', TRUE),
('Culture Experts', 'culture-experts', 'Guides who specialize in history, art, and local traditions.', 'guide', TRUE),
('Best Beach Tours', 'best-beach-tours', 'Explore the most beautiful coastlines in Vietnam and beyond.', 'tour', TRUE),
('Hidden Gems', 'hidden-gems', 'Uncover secrets that typical tourists never see.', 'tour', TRUE)
ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description;

-- 4. Gắn Guide vào Bộ sưu tập (Collection Guides)
-- Nguồn gốc: V16
INSERT INTO collection_guides (collection_id, guide_id, sort_order)
SELECT DISTINCT c.collection_id, u.user_id, m.ord
FROM collections c
CROSS JOIN (
    VALUES 
        ('best-guides', 'anh.nguyen@fellow4u.com', 1),
        ('best-guides', 'jiwon.park@fellow4u.com', 2),
        ('top-rated-guides', 'anh.nguyen@fellow4u.com', 1),
        ('top-rated-guides', 'jiwon.park@fellow4u.com', 2),
        ('culture-experts', 'jiwon.park@fellow4u.com', 1)
) AS m(slug, email, ord)
JOIN users u ON u.email = m.email
WHERE c.slug = m.slug
ON CONFLICT DO NOTHING;

-- 5. Gắn Tour vào Bộ sưu tập (Collection Tours)
-- Nguồn gốc: V16
INSERT INTO collection_tours (collection_id, tour_id, sort_order)
SELECT DISTINCT c.collection_id, t.tour_id, m.ord
FROM collections c
CROSS JOIN (
    VALUES 
        ('featured-tours', 'Da Nang - Hoi An 3 Days Adventure', 1),
        ('featured-tours', 'Explore Seoul Like a Local', 2),
        ('best-beach-tours', 'Da Nang - Hoi An 3 Days Adventure', 1),
        ('hidden-gems', 'Explore Seoul Like a Local', 1),
        ('hidden-gems', 'Street Food Paradise in Saigon', 2)
) AS m(slug, tour_title, ord)
JOIN tours t ON t.title = m.tour_title
WHERE c.slug = m.slug
ON CONFLICT DO NOTHING;

-- 6. Reset Sequences
SELECT setval('reviews_review_id_seq', (SELECT MAX(review_id) FROM reviews));
SELECT setval('guide_portfolio_media_media_id_seq', (SELECT MAX(media_id) FROM guide_portfolio_media));
SELECT setval('collections_collection_id_seq', (SELECT MAX(collection_id) FROM collections));