Ứng dụng **Fellow4U**, dưới đây là mô tả chi tiết về chức năng, phong cách thiết kế và cấu trúc dữ liệu dự kiến cho **Module 1 (Xác thực & Nhập môn)**.

---

## 1. Mô tả Chức năng (Functionality)
Module 1 tập trung vào trải nghiệm người dùng mới và quản lý truy cập. Các chức năng chính bao gồm:

* **Onboarding (Giới thiệu):** Chuỗi màn hình giới thiệu giá trị cốt lõi của ứng dụng (Tìm hướng dẫn viên địa phương, lên kế hoạch chuyến đi, khám phá thế giới).
* **Đăng ký (Sign Up):** * Phân loại người dùng ngay từ đầu: **Traveler** (Khách du lịch) hoặc **Guide** (Hướng dẫn viên).
    * Thu thập thông tin cơ bản: Họ tên, Quốc gia, Email và Mật khẩu.
* **Đăng nhập (Sign In):** * Đăng nhập bằng tài khoản Email/Password.
    * Tích hợp đăng nhập nhanh qua bên thứ ba (Social Login): Facebook, KakaoTalk, Line.
* **Quản lý mật khẩu (Forgot Password):** * Yêu cầu khôi phục mật khẩu qua Email.
    * Màn hình xác nhận kiểm tra hộp thư (Check Email).

---

## 2. Phong cách UI (UI Style)
Ứng dụng đi theo xu hướng thiết kế **Clean & Minimalist** (Sạch sẽ và Tối giản), tạo cảm giác thân thiện và hiện đại:

* **Màu sắc:** * *Màu chủ đạo (Primary Color):* Xanh Mint (Teal) mang lại cảm giác tươi mới, an toàn và chuyên nghiệp.
    * *Màu bổ trợ:* Vàng (Yellow) được dùng trong minh họa để tạo sự năng động, nổi bật.
    * *Nền (Background):* Sử dụng màu trắng chủ đạo để làm nổi bật nội dung và các nút bấm.
* **Typography:** Sử dụng font Sans-serif (không chân) hiện đại, độ dày chữ được phân cấp rõ ràng giữa tiêu đề (Bold) và nội dung (Regular/Medium).
* **Hình ảnh minh họa (Illustrations):** Sử dụng phong cách **Flat Design** (Thiết kế phẳng) với các biểu tượng du lịch (máy bay, mây, danh lam thắng cảnh) giúp người dùng dễ dàng liên tưởng đến mục đích của ứng dụng.
* **Components:** * Nút bấm (Buttons) bo góc lớn, đổ bóng nhẹ (soft shadow) tạo chiều sâu.
    * Input fields dạng đường kẻ dưới (Underline) tinh tế, không gây rối mắt.

---

## 3. Các bảng SQL dự kiến (Database Schema - Module 1)

Để vận hành các chức năng trên, hệ thống cần các bảng dữ liệu cơ bản sau:

### Bảng `Users` (Người dùng)
Đây là bảng quan trọng nhất để lưu trữ thông tin định danh.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `user_id` | INT (PK) | Auto Increment | ID duy nhất của người dùng |
| `role_type` | ENUM | 'Traveler', 'Guide' | Vai trò người dùng |
| `first_name` | VARCHAR(50) | Not Null | Tên |
| `last_name` | VARCHAR(50) | Not Null | Họ |
| `country_id` | INT (FK) | Not Null | Liên kết với bảng Countries |
| `email` | VARCHAR(100) | Unique, Not Null | Email đăng nhập |
| `password_hash`| VARCHAR(255) | Not Null | Mật khẩu đã mã hóa |
| `created_at` | TIMESTAMP | Default Now() | Thời gian tạo tài khoản |

### Bảng `Countries` (Quốc gia)
Dùng để hiển thị danh sách chọn trong màn hình Sign Up.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `country_id` | INT (PK) | Auto Increment | ID quốc gia |
| `country_name` | VARCHAR(100) | Not Null | Tên quốc gia |
| `country_code` | VARCHAR(5) | Unique | Mã quốc gia (VN, US,...) |

### Bảng `Social_Accounts` (Liên kết mạng xã hội)
Lưu thông tin nếu người dùng đăng nhập bằng FB, Line, Kakao.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `social_id` | VARCHAR(255) | PK | ID từ bên thứ 3 cung cấp |
| `user_id` | INT (FK) | Not Null | Liên kết tới bảng Users |
| `provider` | ENUM | 'FB', 'Line', 'Kakao'| Nguồn đăng nhập |

### Bảng `Password_Resets` (Khôi phục mật khẩu)
Quản lý các yêu cầu quên mật khẩu.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `email` | VARCHAR(100) | Not Null | Email yêu cầu |
| `token` | VARCHAR(255) | Not Null | Mã xác thực gửi qua email |
| `created_at` | TIMESTAMP | Not Null | Thời gian yêu cầu (để tính hết hạn) |

---
**Module 1** này đóng vai trò là "cánh cửa" đầu tiên, đảm bảo việc thu thập dữ liệu người dùng chính xác để cá nhân hóa trải nghiệm ở các module tìm kiếm và đặt tour tiếp theo.



**Module 2 (Khám phá & Gợi ý du lịch)**.

---

## 1. Mô tả Chức năng (Functionality)
Module này đóng vai trò là "trung tâm thông tin" giúp người dùng tìm kiếm nguồn cảm hứng và các dịch vụ du lịch:

* **Tìm kiếm & Định vị (Search & Location):** * Tích hợp thông tin thời tiết theo vị trí thời gian thực (ví dụ: Da Nang 26°C).
    * Thanh tìm kiếm thông minh cho phép tra cứu điểm đến hoặc hoạt động.
* **Gợi ý hành trình (Top Journeys):** Hiển thị các gói tour phổ biến theo dạng thẻ ngang (Card), bao gồm giá cả, thời gian và đánh giá.
* **Đội ngũ hướng dẫn viên (Best Guides):** Giới thiệu các hướng dẫn viên hàng đầu kèm ảnh đại diện, xếp hạng sao và khu vực hoạt động.
* **Trải nghiệm đặc sắc (Top Experiences):** Tập trung vào các hoạt động ngắn hạn (ví dụ: tour xe đạp 2 giờ) gắn liền với một hướng dẫn viên cụ thể.
* **Tour nổi bật (Featured Tours):** Danh sách các tour dài ngày hoặc tour đặc biệt, có chức năng "Yêu thích" (Lưu lại) qua biểu tượng trái tim/bookmark.
* **Tin tức du lịch (Travel News):** Cung cấp các bài viết blog, cập nhật điểm đến mới và mẹo du lịch để tăng tính tương tác (Retention) cho ứng dụng.

---

## 2. Phong cách UI (UI Style)
Module 2 tiếp tục duy trì sự nhất quán với hệ thống thiết kế (Design System) của ứng dụng:

* **Bố cục (Layout):** Sử dụng cấu trúc **Multi-scrolling**. Kết hợp giữa cuộn dọc (Vertical) cho toàn trang và cuộn ngang (Horizontal) cho các danh mục nhỏ (Top Journeys, Best Guides).
* **Thiết kế thẻ (Card Design):** Các đối tượng (Tours, Guides) được đặt trong các thẻ có bo góc và đổ bóng nhẹ, giúp tách biệt nội dung rõ ràng trên nền trắng.
* **Hệ thống Icon:** Sử dụng các icon mảnh (Outline) cho thanh điều hướng phía dưới (Bottom Navigation) tạo cảm giác thanh thoát.
* **Màu sắc:** Sử dụng màu Xanh Mint đặc trưng cho các nút "See All", giá tiền và các chỉ báo hành động.
* **Phân cấp thông tin (Visual Hierarchy):** Tiêu đề mục (Heading) to, đậm. Thông tin phụ (địa điểm, ngày tháng) nhỏ hơn và có màu xám nhạt để tránh gây nhiễu thị giác.

---

## 3. Các bảng SQL dự kiến (Database Schema - Module 2)

Tiếp nối Module 1, Module 2 cần các bảng dữ liệu sau để quản lý nội dung động:

### Bảng `Tours` (Danh sách tour/hành trình)
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `tour_id` | INT (PK) | Auto Increment | ID tour |
| `title` | VARCHAR(255)| Not Null | Tên tour |
| `location_id` | INT (FK) | Not Null | Địa điểm diễn ra |
| `price` | DECIMAL | Not Null | Giá tiền |
| `duration_days` | INT | | Số ngày diễn ra |
| `thumbnail_url` | TEXT | | Link ảnh đại diện tour |
| `is_featured` | BOOLEAN | Default False | Đánh dấu tour nổi bật |

### Bảng `Guide_Profiles` (Thông tin chi tiết Guide)
*Mở rộng từ bảng Users ở Module 1*
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `guide_id` | INT (PK) | FK to Users | Liên kết ID người dùng (Guide) |
| `bio` | TEXT | | Giới thiệu bản thân |
| `rating_avg` | FLOAT | Default 0 | Điểm đánh giá trung bình |
| `total_reviews` | INT | Default 0 | Tổng số lượt đánh giá |
| `base_location` | INT (FK) | | Khu vực hoạt động chính |

### Bảng `Experiences` (Hoạt động/Trải nghiệm)
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `exp_id` | INT (PK) | Auto Increment | ID trải nghiệm |
| `guide_id` | INT (FK) | Not Null | Hướng dẫn viên phụ trách |
| `title` | VARCHAR(255)| | Tên hoạt động |
| `duration_hours`| FLOAT | | Số giờ thực hiện |

### Bảng `Travel_News` (Tin tức du lịch)
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `news_id` | INT (PK) | Auto Increment | ID bài viết |
| `title` | VARCHAR(255)| Not Null | Tiêu đề tin tức |
| `content` | LONGTEXT | | Nội dung bài viết |
| `image_url` | TEXT | | Link ảnh minh họa |
| `published_at` | TIMESTAMP | | Ngày đăng bài |

### Bảng `Wishlist` (Danh sách yêu thích)
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `wish_id` | INT (PK) | Auto Increment | ID bản ghi |
| `user_id` | INT (FK) | Not Null | Người dùng lưu |
| `tour_id` | INT (FK) | | Tour được lưu (Nullable) |
| `exp_id` | INT (FK) | | Trải nghiệm được lưu (Nullable) |

---
**Module 2** tập trung vào việc hiển thị dữ liệu (Read-only) và thu thập hành vi quan tâm của người dùng (Wishlist), chuẩn bị cho Module 3 về Đặt tour (Booking) và Thanh toán.


**Module 3 (Chi tiết Dịch vụ & Quản lý Điểm đến)**.

---

## 1. Mô tả Chức năng (Functionality)
Module này tập trung vào việc xây dựng lòng tin, cung cấp thông tin minh bạch và cho phép người dùng tùy chỉnh lộ trình:

* **Hồ sơ chi tiết Hướng dẫn viên (Guide Detail Profile):**
    * Hiển thị thông tin chuyên sâu: Ngôn ngữ (Vietnamese, English, Korean), giới thiệu bản thân (Bio), và video clip giới thiệu để tăng tính trực quan.
    * **Bảng giá phân tầng (Tiered Pricing):** Hiển thị mức giá linh hoạt dựa trên số lượng khách (ví dụ: 1-3 khách: $10/giờ, 4-6 khách: $14/giờ).
    * **Kho trải nghiệm (Experiences Portfolio):** Hiển thị các tour/hoạt động thực tế mà hướng dẫn viên đã thực hiện kèm lượt yêu thích (Likes).
* **Đánh giá & Phản hồi (Reviews & Feedback):** Hệ thống hiển thị các bình luận từ khách hàng cũ kèm số sao và thời gian đánh giá để đảm bảo uy tín.
* **Thêm địa điểm/Điểm tham quan (Add New Attractions):**
    * Chức năng tìm kiếm địa điểm thông minh (Autocomplete): Khi người dùng gõ từ khóa, hệ thống gợi ý các địa điểm liên quan (Cong Coffee, Cong Church...).
    * Lựa chọn và quản lý điểm đến: Cho phép người dùng chọn nhiều địa điểm để thêm vào hành trình (hiển thị dưới dạng Grid với dấu tích chọn).

---

## 2. Phong cách UI (UI Style)
UI của Module 3 chú trọng vào việc trình bày lượng dữ liệu lớn một cách khoa học:

* **Tính minh bạch (Transparency):** Sử dụng bảng (Table) đơn giản cho phần giá cả, giúp khách hàng so sánh và tính toán chi phí nhanh chóng.
* **Multimedia Integration:** Sử dụng video player ngay giữa màn hình hồ sơ để tạo sự gắn kết cá nhân giữa Hướng dẫn viên và Khách du lịch.
* **Trải nghiệm Tìm kiếm (Search UX):** Thanh tìm kiếm tối giản nhưng mạnh mẽ, kết hợp với danh sách gợi ý đổ xuống (Dropdown) giúp giảm bớt thao tác gõ phím.
* **Hệ thống Phản hồi thị giác (Visual Feedback):** Sử dụng các badge màu xanh (checkmark) trên hình ảnh để xác nhận các địa điểm đã được chọn, giúp người dùng dễ dàng theo dõi lựa chọn của mình.
* **Social Proof Layout:** Các đánh giá được thiết kế dạng danh sách dọc với avatar người dùng, tạo cảm giác khách quan như các trang thương mại điện tử lớn.

---

## 3. Các bảng SQL dự kiến (Database Schema - Module 3)

Để hỗ trợ các tính năng chi tiết này, hệ thống cần bổ sung các bảng sau:

### Bảng `Languages` & `Guide_Languages` (Ngôn ngữ)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `lang_id` | INT (PK) | ID ngôn ngữ |
| `lang_name` | VARCHAR(50) | Tên ngôn ngữ (English, Korean,...) |

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `guide_id` | INT (FK) | Liên kết tới Guide |
| `lang_id` | INT (FK) | Liên kết tới Language |

### Bảng `Guide_Pricing` (Cấu hình giá)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `price_id` | INT (PK) | ID bảng giá |
| `guide_id` | INT (FK) | Hướng dẫn viên sở hữu mức giá này |
| `min_travelers` | INT | Số khách tối thiểu (1) |
| `max_travelers` | INT | Số khách tối đa (3) |
| `price_per_hour`| DECIMAL | Giá tiền mỗi giờ |

### Bảng `Reviews` (Đánh giá)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `review_id` | INT (PK) | ID đánh giá |
| `target_id` | INT (FK) | ID của Guide được đánh giá |
| `author_id` | INT (FK) | ID của khách du lịch viết bài |
| `rating` | INT | Số sao (1-5) |
| `comment` | TEXT | Nội dung nhận xét |
| `created_at` | TIMESTAMP | Ngày đánh giá |

### Bảng `Attractions` (Điểm tham quan)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `attraction_id` | INT (PK) | ID địa điểm |
| `name` | VARCHAR(255) | Tên địa điểm (Cộng Cà Phê,...) |
| `address` | TEXT | Địa chỉ chi tiết |
| `image_url` | TEXT | Ảnh minh họa địa điểm |
| `location_id` | INT (FK) | Thuộc thành phố nào |

---
**Module 3** là bước đệm quan trọng để chuyển đổi từ việc "Xem thông tin" sang "Ra quyết định đặt dịch vụ" (Booking), bằng cách cung cấp mọi thông tin cần thiết về giá cả, uy tín và khả năng tùy chỉnh hành trình.


**Module 4 (Chi tiết Hành trình & Đặt chỗ)**.

---

## 1. Mô tả Chức năng (Functionality)
Module này là bước cuối cùng trong việc cung cấp thông tin chi tiết trước khi người dùng thực hiện giao dịch:

* **Thông tin tổng quan (Tour Header):** Hiển thị bộ sưu tập ảnh (Carousel), tên tour, giá ưu đãi (có gạch chân giá cũ), đánh giá và tên đơn vị cung cấp (Provider).
* **Tiện ích tương tác (Social & Save):** * **Share:** Chia sẻ tour qua các nền tảng mạng xã hội (Facebook, Google, Kakao, WhatsApp, Twitter).
    * **Favorite & Bookmark:** Cho phép người dùng lưu nhanh hoặc đưa vào danh sách quan tâm.
* **Tóm tắt hành trình (Summary):** Cung cấp các thông tin "mì ăn liền" như: Lộ trình, thời gian (ví dụ: 2 ngày 2 đêm), ngày khởi hành và điểm đón khách.
* **Lịch trình chi tiết (Schedule Timeline):**
    * Phân chia theo ngày (Day 1, Day 2) bằng hệ thống Tab.
    * Hiển thị chi tiết các mốc thời gian (6:00 AM, 10:00 AM,...) kèm mô tả hoạt động dưới dạng dòng thời gian (Timeline).
* **Bảng giá chi tiết (Detailed Pricing):** Phân loại giá tour theo độ tuổi (Người lớn, Trẻ em 5-10 tuổi, Trẻ em dưới 5 tuổi) để người dùng tự tính toán chi phí.
* **Nút kêu gọi hành động (CTA):** Nút "BOOK THIS TOUR" nổi bật ở cuối màn hình để dẫn tới luồng thanh toán.

---

## 2. Phong cách UI (UI Style)
UI của Module 4 tập trung vào trải nghiệm đọc thông tin dài (Long-form content) mà không gây mệt mỏi:

* **Cấu trúc phân lớp (Card-based Layout):** Các phần như Summary, Schedule, Price được đặt trong các khối trắng có bo góc nhẹ, tách biệt rõ ràng trên nền xám nhạt.
* **Hệ thống Timeline:** Sử dụng các chấm tròn màu xanh (Teal) và đường kẻ dọc nối liền các mốc thời gian, giúp người dùng dễ dàng theo dõi trình tự hoạt động.
* **Tương tác Modal:** Cửa sổ "Share on" được thiết kế dạng Bottom Sheet hoặc Pop-up trung tâm với các icon màu sắc đặc trưng của các hãng (Brand colors), giúp người dùng dễ nhận diện.
* **Typography:** Sử dụng màu sắc để phân cấp: Màu Teal cho giá tiền và các điểm nhấn hành động; màu Xám cho thông tin bổ trợ; màu Đen đậm cho các tiêu đề lớn.
* **Sticky Button:** Nút "Book This Tour" thường được thiết kế để luôn hiển thị hoặc nằm ở vị trí dễ tiếp cận nhất sau khi đọc hết thông tin.

---

## 3. Các bảng SQL dự kiến (Database Schema - Module 4)

Module này yêu cầu các bảng để quản lý nội dung chi tiết của từng chuyến đi:

### Bảng `Providers` (Đơn vị cung cấp tour)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `provider_id` | INT (PK) | ID đơn vị cung cấp |
| `name` | VARCHAR(255) | Tên đơn vị (dulichviet,...) |
| `website` | VARCHAR(255) | Website đơn vị |
| `rating_avg` | FLOAT | Đánh giá trung bình của đơn vị |

### Bảng `Tour_Schedules` (Lịch trình chi tiết)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `schedule_id` | INT (PK) | ID lịch trình |
| `tour_id` | INT (FK) | Liên kết với tour nào |
| `day_number` | INT | Ngày thứ mấy (1, 2,...) |
| `start_time` | TIME | Mốc thời gian (06:00:00) |
| `activity_title` | VARCHAR(255) | Tên hoạt động ngắn gọn |
| `description` | TEXT | Mô tả chi tiết hoạt động |

### Bảng `Tour_Age_Pricing` (Giá theo độ tuổi)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `price_id` | INT (PK) | ID bản ghi giá |
| `tour_id` | INT (FK) | Liên kết với tour |
| `age_group` | VARCHAR(50) | Nhóm tuổi (Adult, Child 5-10,...) |
| `price` | DECIMAL | Giá tiền (0 nếu là Free) |

### Bảng `Tour_Images` (Thư viện ảnh tour)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `image_id` | INT (PK) | ID ảnh |
| `tour_id` | INT (FK) | Thuộc tour nào |
| `image_url` | TEXT | Đường dẫn ảnh trên storage |
| `display_order` | INT | Thứ tự hiển thị trong Carousel |

---
**Module 4** hoàn thiện luồng trải nghiệm người dùng từ việc tìm kiếm, xem chi tiết và chuẩn bị cho thao tác **Booking**. Đây là module có mật độ dữ liệu văn bản cao nhất trong ứng dụng.


**Module 5 (Tìm kiếm & Bộ lọc nâng cao)** của ứng dụng Fellow4U.

---

## 1. Mô tả Chức năng (Functionality)
Module này đóng vai trò là "bộ máy điều hướng", giúp người dùng thu hẹp phạm vi tìm kiếm để tìm đúng dịch vụ mong muốn:

* **Khởi tạo tìm kiếm (Search Initiation):**
    * Cung cấp thanh nhập liệu với gợi ý "Where you want to explore".
    * Hiển thị **Popular Destinations** (Điểm đến phổ biến) dưới dạng các thẻ (Chips) để người dùng chọn nhanh mà không cần gõ (ví dụ: Danang, Ho Chi Minh, Venice).
* **Bộ lọc đa năng (Advanced Filtering):**
    * Phân loại đối tượng tìm kiếm: Chuyển đổi giữa **Guides** (Hướng dẫn viên) và **Tours** thông qua hệ thống Tab.
    * Lọc theo thời gian: Chọn ngày cụ thể (Date picker) để kiểm tra tính khả dụng.
    * Lọc theo ngôn ngữ: Chọn một hoặc nhiều ngôn ngữ mà Hướng dẫn viên có thể giao tiếp.
    * Lọc theo ngân sách (Fee): Nhập mức giá tối đa mỗi giờ ($/hour).
* **Hiển thị kết quả (Search Results):**
    * Phân cấp kết quả rõ ràng: Hiển thị danh sách Hướng dẫn viên trước, sau đó đến các Tour liên quan tại địa điểm đó.
    * Tích hợp nút "See More" để mở rộng danh sách cho từng hạng mục.

---

## 2. Phong cách UI (UI Style)
Giao diện Module 5 tập trung vào sự tinh gọn và tối ưu hóa thao tác chạm (Touch-friendly):

* **Chip-based Design:** Sử dụng các "Chips" (viên thuốc) cho điểm đến phổ biến và lựa chọn ngôn ngữ, giúp giao diện thoáng đãng và dễ tương tác bằng một tay.
* **Segmented Control (Tab):** Hệ thống chuyển đổi giữa Guides/Tours trong bộ lọc được thiết kế rõ ràng với màu Xanh Mint làm điểm nhấn cho trạng thái đang chọn (Active).
* **Clean Input Fields:** Các trường nhập liệu trong bộ lọc (Date, Fee) sử dụng đường kẻ mảnh và icon minh họa (lịch, biểu tượng đô la), đồng nhất với phong cách tối giản của toàn ứng dụng.
* **Phân cấp lưới (Grid vs. List):**
    * **Guides:** Hiển thị dạng lưới 2 cột (Grid) giúp người dùng so sánh nhanh diện mạo và đánh giá của nhiều hướng dẫn viên.
    * **Tours:** Hiển thị dạng danh sách dọc (List) với hình ảnh lớn hơn để phô diễn vẻ đẹp của điểm đến.
* **Visual Consistency:** Nút "APPLY FILTERS" to, bản rộng, màu Teal rực rỡ ở cuối màn hình tạo ra một điểm kết thúc hành trình lọc dữ liệu một cách chắc chắn.

---

## 3. Các bảng SQL dự kiến (Database Schema - Module 5)

Module này chủ yếu truy vấn dữ liệu từ các Module trước, nhưng cần thêm các bảng sau để tối ưu hóa việc tìm kiếm:

### Bảng `Locations` (Địa điểm/Thành phố)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `location_id` | INT (PK) | ID địa điểm |
| `city_name` | VARCHAR(100) | Tên thành phố (Danang, Venice,...) |
| `country_name` | VARCHAR(100) | Tên quốc gia |
| `is_popular` | BOOLEAN | Đánh dấu để hiển thị ở mục "Popular" |
| `search_count` | INT | Số lượt tìm kiếm (dùng để xếp hạng độ phổ biến) |

### Bảng `Guide_Availability` (Lịch trống của Guide)
Dùng để xử lý bộ lọc "Date".
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `avail_id` | INT (PK) | ID bản ghi |
| `guide_id` | INT (FK) | Liên kết tới Guide |
| `available_date`| DATE | Ngày mà Guide có thể nhận khách |
| `status` | ENUM | 'Available', 'Booked', 'Off' |

### Bảng `Search_Logs` (Nhật ký tìm kiếm)
Dùng để phân tích hành vi người dùng và gợi ý.
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `log_id` | INT (PK) | ID nhật ký |
| `user_id` | INT (FK) | ID người thực hiện (nếu đã đăng nhập) |
| `keyword` | VARCHAR(255) | Từ khóa người dùng đã gõ |
| `search_at` | TIMESTAMP | Thời điểm tìm kiếm |

### Truy vấn Logic (Ví dụ cho bộ lọc Guide):
Để lấy ra các Guide tại Đà Nẵng, nói tiếng Anh, giá dưới $15:
```sql
SELECT g.* FROM Guide_Profiles g
JOIN Users u ON g.user_id = u.user_id
JOIN Guide_Languages gl ON g.guide_id = gl.guide_id
JOIN Languages l ON gl.lang_id = l.lang_id
WHERE g.base_location = [DaNang_ID]
  AND l.lang_name = 'English'
  AND g.price_per_hour <= 15;
```

---
**Module 5** là một phần cực kỳ quan trọng về UX, giúp kết nối nhu cầu cụ thể của khách du lịch với nguồn lực sẵn có của hệ thống một cách nhanh chóng và chính xác nhất.


Dựa trên hình ảnh về danh sách mở rộng của Hướng dẫn viên (Guides) và các Chuyến đi (Tours), dưới đây là mô tả chi tiết cho **Module 6 (Danh mục & Xem thêm)**.

---

## 1. Mô tả Chức năng (Functionality)
Module này là phần mở rộng từ màn hình Explore, cho phép người dùng đi sâu vào từng danh mục cụ thể:

* **Xem danh sách toàn diện (Extended Browsing):** Cho phép người dùng xem tất cả các Hướng dẫn viên hoặc các Tour có sẵn thay vì chỉ xem các gợi ý giới hạn ở trang chủ.
* **Tìm kiếm ngữ cảnh (Contextual Search):** Tích hợp thanh tìm kiếm ngay dưới tiêu đề giúp người dùng lọc nhanh thông tin trong khi vẫn đang ở trong danh mục đó.
* **Phân loại danh mục (Categorization):** * Mục Guides tập trung vào: "Book your own private local Guide".
    * Mục Tours tập trung vào: "Plenty of amazing of tours are waiting for you".
* **Phân trang/Chuyển trang (Navigation & Pagination):** * Sử dụng nút "Back" (mũi tên) để quay lại trang Explore.
    * Có hệ thống chỉ báo trang (Dấu chấm ở cuối màn hình) gợi ý việc phân trang hoặc cuộn để xem thêm kết quả.

---

## 2. Phong cách UI (UI Style)
Giao diện Module 6 nhấn mạnh vào việc hiển thị nội dung lặp lại một cách trật tự:

* **Visual Banner:** Cả hai màn hình đều sử dụng ảnh Banner lớn ở phía trên cùng, có độ mờ nhẹ (Overlay) để làm nổi bật dòng chữ trắng phía trên, tạo cảm giác chuyên nghiệp và thu hút.
* **Hệ thống Thẻ (Card System):**
    * **Đối với Guide:** Sử dụng thẻ hình chữ nhật đứng (Vertical Card), ưu tiên ảnh chân dung lớn chiếm 70% diện tích thẻ để tạo sự tin tưởng. Thông tin tên, số sao và vị trí được đặt gọn gàng phía dưới.
    * **Đối với Tour:** Sử dụng thẻ ngang (Horizontal Card) hoặc thẻ danh sách lớn. Hình ảnh điểm đến chiếm chiều rộng tối đa của thẻ, các thông tin giá, ngày tháng, thời gian được căn lề hai bên (Justified) để tận dụng diện tích.
* **Tính nhất quán (Consistency):** Màu xanh Teal được dùng xuyên suốt cho các biểu tượng vị trí (Location pin), giá tiền và các chỉ báo quan trọng.
* **Khoảng trắng (White Space):** Giữa các thẻ có khoảng cách vừa đủ, giúp người dùng không cảm thấy bị ngợp khi xem danh sách dài.

---

## 3. Các bảng SQL dự kiến (Database Schema - Module 6)

Module này chủ yếu khai thác dữ liệu từ các bảng của Module 2 và 5, nhưng cần thêm các bảng quản lý nội dung hiển thị ở Banner và Phân nhóm:

### Bảng `App_Banners` (Quản lý ảnh bìa và tiêu đề)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `banner_id` | INT (PK) | ID banner |
| `page_type` | ENUM | 'Guides_More', 'Tours_More' |
| `title_text` | VARCHAR(255) | Dòng chữ hiển thị trên banner |
| `image_url` | TEXT | Link ảnh nền banner |

### Bảng `Collections` (Nhóm nội dung)
Dùng để nhóm các Tour hoặc Guide vào các mục như "Private Local", "Amazing Tours".
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `collection_id`| INT (PK) | ID bộ sưu tập |
| `name` | VARCHAR(100) | Tên bộ sưu tập |
| `description` | TEXT | Mô tả ngắn |

### Bảng `Collection_Items` (Chi tiết các mục trong nhóm)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `collection_id`| INT (FK) | Thuộc bộ sưu tập nào |
| `item_id` | INT | ID của Tour hoặc Guide |
| `item_type` | ENUM | 'Guide', 'Tour' |
| `sort_order` | INT | Thứ tự hiển thị |

### Truy vấn Logic (Ví dụ cho việc lấy danh sách Guide kèm phân trang):
```sql
SELECT g.guide_id, u.first_name, u.last_name, g.rating_avg, l.city_name
FROM Guide_Profiles g
JOIN Users u ON g.user_id = u.user_id
JOIN Locations l ON g.base_location = l.location_id
ORDER BY g.rating_avg DESC
LIMIT 10 OFFSET 0; -- Lấy 10 kết quả đầu tiên (Trang 1)
```

---
**Module 6** hoàn thiện trải nghiệm "Duyệt nội dung" (Browsing Experience), đảm bảo người dùng có thể tiếp cận toàn bộ kho dữ liệu của ứng dụng một cách khoa học và đẹp mắt trước khi đi đến quyết định cuối cùng.


**Module 7 (Quản lý Chuyến đi & Trạng thái Đặt chỗ)**.

---

## 1. Mô tả Chức năng (Functionality)
Module này đóng vai trò là trình quản lý lộ trình (Itinerary Manager) dành cho người dùng, giúp theo dõi toàn bộ vòng đời của các dịch vụ đã đặt:

* **Phân loại trạng thái chuyến đi (Trip Categorization):**
    * **Current Trips:** Chuyến đi đang diễn ra, cho phép người dùng xác nhận hoàn thành bằng nút "Mark Finished".
    * **Next Trips:** Danh sách các chuyến đi đã đặt nhưng chưa diễn ra. Tại đây tích hợp quy trình xử lý đặt chỗ (Booking Workflow):
        * *Waiting/Bidding:* Trạng thái đang chờ Guide xác nhận hoặc đang nhận báo giá.
        * *Payment:* Nút "Pay" xuất hiện khi Guide đã đồng ý và chờ khách thanh toán.
        * *Rejection Handling:* Nếu Guide từ chối, hệ thống cung cấp tùy chọn "Choose another Guide".
    * **Past Trips:** Lưu trữ lịch sử các chuyến đi đã hoàn thành để xem lại hoặc đánh giá.
    * **Wish List:** Lưu các tour/hành trình mà người dùng quan tâm nhưng chưa đặt.
* **Tương tác thời gian thực:** Tích hợp nút **Chat** trực tiếp với Guide để trao đổi trước chuyến đi và nút **Detail** để xem lộ trình chi tiết.
* **Lập kế hoạch nhanh:** Nút **(+) Floating Action Button** cho phép người dùng tạo nhanh một yêu cầu chuyến đi mới ở bất kỳ tab nào.

---

## 2. Phong cách UI (UI Style)
Giao diện của Module 7 tập trung vào sự mạch lạc và quản lý trạng thái (State Management):

* **Top Tab Navigation:** Sử dụng thanh điều hướng ngang ở phía trên với màu Xanh Mint để làm nổi bật danh mục đang chọn.
* **Hệ thống thẻ (Card UI) đa năng:**
    * Mỗi thẻ chuyến đi bao gồm: Ảnh địa danh (Cover), trạng thái (Badges như Waiting, Bidding), thông tin thời gian, tên Guide và Avatar có viền màu thương hiệu.
    * Avatar của Guide trong thẻ "Next Trips" có thể hiển thị dạng chồng lên nhau (Stack) nếu đang trong trạng thái đấu thầu (Bidding) từ nhiều Guide.
* **Nút bấm hành động (Action Buttons):** Các nút hành động chính (Pay, Chat, Choose another Guide) được thiết kế dạng Outlined hoặc Filled với màu Xanh Mint, phân bổ theo ngữ cảnh của từng trạng thái chuyến đi.
* **Phân cấp hình ảnh:** Sử dụng ảnh chụp thực tế các địa danh nổi tiếng (Cầu Rồng, Tháp Rùa, Nhà thờ Đức Bà...) làm nền cho thẻ để người dùng dễ dàng nhận diện chuyến đi qua thị giác thay vì chỉ đọc chữ.

---

## 3. Các bảng SQL dự kiến (Database Schema - Module 7)

Để quản lý logic phức tạp của trạng thái chuyến đi, cần các bảng sau:

### Bảng `Bookings` (Quản lý đặt chỗ)
Đây là bảng trung tâm lưu trữ mọi giao dịch đặt tour.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `booking_id` | INT (PK) | Auto Increment | ID đơn đặt chỗ |
| `user_id` | INT (FK) | Not Null | ID khách du lịch |
| `guide_id` | INT (FK) | Nullable | ID Guide (null nếu đang Bidding) |
| `tour_id` | INT (FK) | Not Null | ID hành trình/tour |
| `start_date` | DATETIME | Not Null | Ngày giờ bắt đầu |
| `end_date` | DATETIME | Not Null | Ngày giờ kết thúc |
| `status` | ENUM | 'waiting', 'bidding', 'paid', 'current', 'finished', 'rejected' | Trạng thái của chuyến đi |
| `total_price` | DECIMAL | | Tổng số tiền thanh toán |

### Bảng `Booking_Bids` (Đấu thầu Guide)
Lưu thông tin khi có nhiều Guide cùng chào giá cho một yêu cầu của khách.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `bid_id` | INT (PK) | Auto Increment | ID lượt chào giá |
| `booking_id` | INT (FK) | Not Null | Liên kết tới đơn đặt chỗ |
| `guide_id` | INT (FK) | Not Null | Guide gửi báo giá |
| `bid_price` | DECIMAL | | Giá mà Guide đề xuất |
| `created_at` | TIMESTAMP | | Thời gian gửi báo giá |

### Bảng `Wishlist` (Danh sách yêu thích)
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `wish_id` | INT (PK) | Auto Increment | ID bản ghi yêu thích |
| `user_id` | INT (FK) | Not Null | ID người dùng |
| `tour_id` | INT (FK) | Not Null | ID tour được lưu |
| `added_at` | TIMESTAMP | | Ngày thêm vào wishlist |

### Bảng `Chat_Sessions` (Phiên hội thoại)
Liên kết giữa nút Chat và dữ liệu thực tế.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `session_id` | INT (PK) | Auto Increment | ID phiên chat |
| `booking_id` | INT (FK) | Unique | Mỗi booking có 1 luồng chat riêng |
| `last_message` | TEXT | | Nội dung tin nhắn cuối cùng |
| `updated_at` | TIMESTAMP | | Thời gian cập nhật gần nhất |

---
**Module 7** hoàn thiện quy trình từ lúc người dùng nảy sinh ý tưởng (Wishlist), tiến hành đặt chỗ (Next Trips), thực hiện chuyến đi (Current) và lưu giữ kỷ niệm (Past Trips).


**Module 8 (Khởi tạo yêu cầu dịch vụ - Trip Request Builder)**.

---

## 1. Mô tả Chức năng (Functionality)
Đây là "trái tim" của hệ thống phía người dùng, nơi họ cấu hình yêu cầu để gửi đến cộng đồng hướng dẫn viên (Guide). Các chức năng cốt lõi:

* **Cấu hình tham số chuyến đi:** Người dùng nhập các thông tin mang tính định lượng:
    * **Địa điểm & Thời gian:** Xác định phạm vi không gian và thời gian của hành trình.
    * **Quy mô nhóm:** Bộ đếm số lượng hành khách (`Number of travelers`) giúp Guide tính toán chi phí phù hợp.
    * **Dự toán ngân sách:** Trường `Fee ($/hour)` cho phép người dùng chủ động đặt mức giá kỳ vọng.
    * **Yêu cầu kỹ năng:** Chọn ngôn ngữ cần thiết (`Guide’s Language`) để lọc Guide phù hợp.
* **Tùy chỉnh lộ trình (Attractions Management):**
    * Chức năng **Add New**: Mở rộng hoặc thay đổi các điểm tham quan.
    * **Trạng thái chọn (Selection State):** Sử dụng cơ chế checkbox/check-mark để người dùng xác nhận các địa điểm đã chọn vào tour.
* **Xác nhận yêu cầu (Submit Request):** Nút **DONE** để kích hoạt quy trình đẩy yêu cầu lên hệ thống, bắt đầu giai đoạn "Bidding" (đấu thầu từ các Guide).

---

## 2. Phong cách UI (UI Style)
Giao diện được tối ưu hóa để người dùng nhập liệu nhanh chóng và không bị quá tải thông tin:

* **Layout dạng Form:** Sử dụng cấu trúc danh sách dọc (Vertical Form) với các nhãn (Labels) rõ ràng, giúp luồng mắt người dùng đi từ trên xuống dưới một cách logic.
* **Nhập liệu tối giản (Input Field UI):**
    * Sử dụng *Input dưới dạng đường kẻ đơn* kết hợp với Icon minh họa (Calendar, Clock, Coin, Globe), giúp không gian trông thoáng và hiện đại.
    * **Stepper UI:** Bộ chọn số lượng khách có nút +/- đơn giản, thân thiện với thao tác ngón tay trên di động.
* **Giao diện lưới (Grid/Card System):** Phần `Attractions` sử dụng thiết kế dạng lưới (Grid), mỗi địa điểm là một thẻ ảnh thu nhỏ.
    * **Visual Indicators:** Sử dụng vòng tròn check-mark màu xanh lục trên ảnh để phản hồi ngay lập tức cho người dùng biết địa điểm nào đã được chọn.
* **CTA nổi bật:** Nút **DONE** chiếm toàn bộ chiều ngang, bo góc, màu xanh mint đồng bộ với thương hiệu, tạo điểm dừng chân cuối cùng cho luồng thao tác.

---

## 3. Các bảng SQL dự kiến (Database Schema - Module 8)

Module này chịu trách nhiệm lưu trữ dữ liệu đầu vào của một đơn đặt tour mới:

### Bảng `Trip_Requests` (Lưu thông tin yêu cầu)
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `request_id` | INT (PK) | Auto Increment | ID yêu cầu |
| `user_id` | INT (FK) | Not Null | Người tạo yêu cầu |
| `location` | VARCHAR(255)| | Địa điểm dự kiến |
| `date_start` | DATE | | Ngày dự kiến |
| `time_start` | TIME | | Giờ bắt đầu |
| `time_end` | TIME | | Giờ kết thúc |
| `travelers_count`| INT | | Số lượng khách |
| `budget_per_hour`| DECIMAL | | Mức giá đề xuất ($/h) |
| `status` | ENUM | 'pending', 'active' | Trạng thái yêu cầu |

### Bảng `Trip_Attractions` (Lưu danh sách điểm tham quan được chọn)
Cần bảng trung gian (Junction Table) để quản lý mối quan hệ "Nhiều - Nhiều" giữa Yêu cầu và Địa điểm.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `request_id` | INT (FK) | Not Null | Liên kết tới yêu cầu |
| `attraction_id` | INT (FK) | Not Null | Liên kết tới bảng Attractions |

### Bảng `Request_Languages` (Ngôn ngữ yêu cầu)
| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `request_id` | INT (FK) | Not Null | Liên kết tới yêu cầu |
| `lang_id` | INT (FK) | Not Null | ID ngôn ngữ |

---
**Module 8** chuyển đổi ý định của người dùng thành một "hợp đồng đặt chỗ" sơ khởi, cung cấp đủ dữ liệu để các Guide có thể dựa vào đó đưa ra báo giá hoặc chấp nhận thực hiện tour.


**Module 9 (Chi tiết đơn đặt & Thanh toán - Trip Detail & Checkout)**.

---

## 1. Mô tả Chức năng (Functionality)
Module này là bước cuối cùng trong luồng giao dịch, nơi người dùng kiểm tra lại thông tin và thực hiện nghĩa vụ tài chính:

* **Xem chi tiết lịch trình (Trip Detail View):** * Hiển thị tóm tắt toàn bộ thông tin đã thỏa thuận: Thời gian, Hướng dẫn viên (Guide), số lượng khách.
    * **Attraction Tags:** Các điểm tham quan được hiển thị dưới dạng thẻ (tags) giúp người dùng điểm lại nhanh lộ trình.
* **Quy trình thanh toán đa bước (Payment Workflow):** Sử dụng hệ thống Stepper để chia nhỏ quá trình:
    * **Bước 1 - Payment Method:** Thu thập thông tin thẻ thanh toán (Tên chủ thẻ, số thẻ, ngày hết hạn, mã CVV).
    * **Bước 2 - Preview & Check out:** Xác nhận lại thông tin chuyến đi lần cuối trước khi trừ tiền.
* **Logic thanh toán đặt cọc (Upfront Payment Logic):** * Hệ thống tự động tính toán số tiền cần trả trước (ví dụ: 50% upfront). 
    * Hiển thị minh bạch: Tổng tiền ($20.00) vs. Số tiền cần thanh toán ngay ($10.00).
* **Điều hướng nhanh:** Tích hợp nút **Chat** để người dùng có thể hỏi nhanh Guide trước khi nhấn **Pay**.

---

## 2. Phong cách UI (UI Style)
Giao diện Module 9 đề cao sự an toàn, tin cậy và minh bạch:

* **Stepper Navigation:** Một thanh tiến trình (progress line) với các nút tròn ở phía trên giúp người dùng biết mình đang ở đâu trong quá trình thanh toán, giảm tỷ lệ bỏ rơi giỏ hàng.
* **Hệ thống Thẻ & Tag (Card & Chips):** * Thông tin chuyến đi được đóng gói trong một thẻ lớn với ảnh bìa bo góc.
    * Địa danh sử dụng các **Chips (Rounded Tags)** với icon định vị màu xanh, giúp giao diện không bị khô khan bởi các dòng văn bản thuần túy.
* **Phân cấp tài chính (Financial Hierarchy):** Số tiền cần thanh toán được viết to, màu xanh mint đậm để gây chú ý, trong khi các dòng giải thích (Ví dụ: "You just need to pay upfront 50%") sử dụng màu xám nhạt để hỗ trợ.
* **Form nhập liệu:** Giữ phong cách tối giản với các đường kẻ (Underline inputs) và gợi ý (Placeholder) mờ, tạo cảm giác chuyên nghiệp và hiện đại.

---

## 3. Các bảng SQL quan trọng (Database Schema - Module 9)

Đây là phần quan trọng nhất để quản lý dòng tiền và tính bảo mật của giao dịch:

### Bảng `Payments` (Quản lý giao dịch)
Lưu trữ thông tin về từng đợt thanh toán (đặt cọc hoặc thanh toán hết).

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `payment_id` | INT (PK) | Auto Increment | ID duy nhất của giao dịch |
| `booking_id` | INT (FK) | Not Null | Liên kết tới đơn đặt chỗ (Module 7) |
| `amount` | DECIMAL | Not Null | Số tiền thực hiện thanh toán lần này |
| `payment_type` | ENUM | 'upfront', 'final' | Loại thanh toán (đặt cọc/còn lại) |
| `status` | ENUM | 'pending', 'success', 'failed' | Trạng thái giao dịch |
| `transaction_ref`| VARCHAR(255)| Unique | Mã tham chiếu từ cổng thanh toán (Stripe/Paypal) |
| `created_at` | TIMESTAMP | | Thời gian thanh toán |

### Bảng `User_Payment_Methods` (Phương thức thanh toán)
Lưu thông tin thẻ để tái sử dụng (thường chỉ lưu Token hoặc thông tin ẩn danh để bảo mật).

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `method_id` | INT (PK) | Auto Increment | ID phương thức |
| `user_id` | INT (FK) | Not Null | Người sở hữu thẻ |
| `card_holder` | VARCHAR(100) | | Tên in trên thẻ |
| `card_last_4` | CHAR(4) | | 4 số cuối của thẻ (để hiển thị) |
| `expiry_date` | VARCHAR(5) | | MM/YY |
| `payment_token` | TEXT | | Token an toàn từ nhà cung cấp thanh toán |

### Bảng `Pricing_Policies` (Chính sách giá - Nếu có)
Dùng để cấu hình tỷ lệ đặt cọc (ví dụ 50%) tùy theo loại tour.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `policy_id` | INT (PK) | | ID chính sách |
| `deposit_percentage`| INT | Default 50 | Tỷ lệ phần trăm cần trả trước |
| `is_active` | BOOLEAN | | Trạng thái áp dụng |

---
**Module 9** hoàn tất chu trình kinh doanh bằng cách chuyển đổi từ "Yêu cầu dịch vụ" thành "Dịch vụ đã được đảm bảo bằng tài chính", giúp bảo vệ quyền lợi cho cả Guide và Traveler.


**Module 10 (Hệ thống tin nhắn - Messaging System)**.

---

## 1. Mô tả Chức năng (Functionality)
Module này đóng vai trò cầu nối giao tiếp trực tiếp giữa khách du lịch và hướng dẫn viên, hỗ trợ thương thảo và cập nhật thông tin chuyến đi:

* **Danh sách trò chuyện (Chat List):** Hiển thị danh sách các hội thoại đang diễn ra, sắp xếp theo thời gian tin nhắn cuối cùng được gửi/nhận.
* **Tìm kiếm hội thoại (Search Chat):** Thanh tìm kiếm cho phép người dùng nhanh chóng tìm lại hội thoại với một hướng dẫn viên cụ thể hoặc theo nội dung trao đổi.
* **Trạng thái hội thoại (Conversation Status):**
    * **Tin nhắn chưa đọc:** Hiển thị số lượng tin nhắn mới (badge màu đỏ, ví dụ: "2" cho Emmy).
    * **Xem trước tin nhắn:** Hiển thị nội dung tin nhắn cuối cùng để người dùng nắm bắt ngữ cảnh mà không cần mở toàn bộ đoạn chat.
    * **Thời gian (Timestamp):** Hiển thị thời điểm tin nhắn gần nhất được gửi để quản lý tiến độ liên lạc.
* **Tích hợp sâu:** Hội thoại không chỉ là tán gẫu mà còn gắn liền với các sự kiện trong `Booking_ID` (trao đổi về giờ bắt đầu tour, địa điểm tập trung, giá cả).

---

## 2. Phong cách UI (UI Style)
Giao diện tin nhắn tuân thủ sự tối giản để ưu tiên tốc độ đọc và khả năng phản hồi:

* **Danh sách dọc (Vertical List):** Sử dụng danh sách theo hàng dọc với khoảng cách (padding) hợp lý, giúp người dùng không bị rối mắt.
* **Thông tin cá nhân hóa:** Mỗi hàng hội thoại bắt đầu bằng ảnh đại diện tròn của Guide, giúp người dùng nhận diện ngay lập tức người họ đang làm việc cùng.
* **Phản hồi thị giác (Visual Cues):** * Badge số lượng tin nhắn (Unread Count) sử dụng màu đỏ nổi bật trên nền trắng để thu hút sự chú ý.
    * Phông chữ: Tên người gửi được in đậm (Bold), nội dung tin nhắn và thời gian sử dụng phông chữ nhạt hơn (Light/Regular) để phân cấp thông tin.
* **Thanh tìm kiếm:** Thanh tìm kiếm thiết kế bo tròn, nằm tách biệt ở phần đầu, tạo cảm giác chuyên nghiệp giống như các ứng dụng nhắn tin hàng đầu (Messenger, Zalo).

---

## 3. Các bảng SQL quan trọng (Database Schema - Module 10)

Để vận hành hệ thống tin nhắn, cần cấu trúc bảng hỗ trợ lưu trữ hội thoại và tin nhắn theo thời gian thực:

### Bảng `Chat_Rooms` (Phòng hội thoại)
Quản lý các phiên kết nối giữa Traveler và Guide.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `room_id` | INT (PK) | ID của phòng hội thoại |
| `booking_id` | INT (FK) | Liên kết với đơn đặt chỗ (để đóng/mở chat) |
| `participant1_id`| INT (FK) | ID của Traveler |
| `participant2_id`| INT (FK) | ID của Guide |
| `last_message_id`| INT (FK) | ID tin nhắn cuối cùng để hiển thị preview |
| `updated_at` | TIMESTAMP | Thời gian hoạt động cuối cùng |

### Bảng `Messages` (Chi tiết tin nhắn)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `message_id` | INT (PK) | ID tin nhắn |
| `room_id` | INT (FK) | Thuộc về phòng chat nào |
| `sender_id` | INT (FK) | Ai là người gửi |
| `content` | TEXT | Nội dung tin nhắn |
| `is_read` | BOOLEAN | Trạng thái đọc (True/False) |
| `created_at` | TIMESTAMP | Thời gian gửi |

### Bảng `Unread_Counts` (Tối ưu hóa hiển thị)
*Gợi ý: Dùng để lưu trữ số lượng tin nhắn chưa đọc nhằm giảm truy vấn COUNT phức tạp trên bảng Messages.*

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `room_id` | INT (FK) | ID phòng chat |
| `user_id` | INT (FK) | ID người dùng đang bị tính chưa đọc |
| `unread_count` | INT | Số lượng tin nhắn mới |

---
**Module 10** hoàn thiện trải nghiệm dịch vụ bằng cách cung cấp kênh liên lạc an toàn, minh bạch, cho phép người dùng và hướng dẫn viên thống nhất các chi tiết cuối cùng trước khi khởi hành chuyến đi.


**Module 11 (Trung tâm Thông báo - Notification Center)**.

---

## 1. Mô tả Chức năng (Functionality)
Module này đóng vai trò là "trợ lý nhắc việc" (Push & In-app notifications), đảm bảo người dùng không bỏ lỡ các cập nhật quan trọng về trạng thái đơn hàng và hành trình:

* **Cập nhật trạng thái chuyến đi (Status Updates):** Thông báo khi có thay đổi quan trọng như: "Guide chấp nhận yêu cầu" hoặc "Guide gửi báo giá mới".
* **Kêu gọi hành động (Call-to-Action - CTA):** Nhắc nhở người dùng thực hiện các bước tiếp theo trong quy trình trải nghiệm:
    * Ví dụ: "Kết thúc chuyến đi, hãy để lại đánh giá cho hướng dẫn viên".
    * Tích hợp nút **Leave Review** trực tiếp trên thông báo giúp giảm số lượng thao tác cần thiết.
* **Lịch sử thông báo:** Lưu trữ các thông tin liên quan đến các chuyến đi trước đó theo trình tự thời gian (Timestamp).

---

## 2. Phong cách UI (UI Style)
Giao diện thông báo được thiết kế để phân biệt rõ ràng giữa "Thông tin" và "Hành động":

* **Danh sách trực quan (Icon-based List):** Mỗi loại thông báo có một icon riêng biệt (vị trí địa lý, tài liệu, bút chì) để người dùng nhận diện nhanh loại nội dung mà không cần đọc hết văn bản.
* **Layout rõ ràng:** * Ảnh đại diện của người liên quan (Guide) được đặt ở cạnh trái giúp tạo sự kết nối cá nhân.
    * Nội dung thông báo được căn lề thẳng hàng với timestamp ngay bên dưới.
* **Phân cấp thị giác:** Đối với các thông báo cần hành động (Leave Review), phần văn bản được in đậm hơn và nút **Leave Review** có màu xanh mint nổi bật, tạo sự tương phản mạnh mẽ để người dùng không bỏ lỡ.
* **Minimalist Look:** Sử dụng đường kẻ mỏng (divider) giữa các thông báo để tạo sự ngăn nắp mà không làm giao diện trở nên nặng nề.

---

## 3. Các bảng SQL quan trọng (Database Schema - Module 11)

Để hệ thống hoạt động chính xác, cần các bảng sau để lưu trữ và quản lý thông báo:

### Bảng `Notifications` (Lưu thông báo)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `notif_id` | INT (PK) | ID thông báo |
| `user_id` | INT (FK) | Người nhận thông báo |
| `type` | ENUM | 'booking_accepted', 'new_offer', 'review_reminder' |
| `content` | TEXT | Nội dung thông báo |
| `related_id` | INT | ID liên quan (booking_id hoặc review_id) |
| `is_read` | BOOLEAN | Trạng thái đã xem |
| `created_at` | TIMESTAMP | Thời gian tạo thông báo |

### Bảng `Notification_Templates` (Cấu hình mẫu)
Dùng để quản lý các mẫu tin nhắn hệ thống (giúp chuẩn hóa nội dung).

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `template_id` | INT (PK) | ID mẫu |
| `type` | VARCHAR(50) | Loại thông báo |
| `message_template`| TEXT | Nội dung mẫu (VD: "{name} accepted your request...") |

---
**Module 11** đóng vai trò là "chất keo" kết nối các module khác (Booking, Chat, Review), giúp luồng trải nghiệm của người dùng trở nên liên tục và không bị đứt đoạn.



**Module 12 (Quản lý Hồ sơ & Nội dung Cá nhân)**.

---

## 1. Mô tả Chức năng (Functionality)
Module này là không gian riêng tư của người dùng (Traveler/Guide), nơi họ quản lý danh tính và lưu trữ kỷ niệm:

* **Quản lý Hồ sơ (Profile Management):** Xem và chỉnh sửa thông tin cá nhân (Họ tên, ảnh đại diện, ảnh bìa).
* **Bảo mật:** Chức năng đổi mật khẩu (yêu cầu mật khẩu hiện tại để xác thực).
* **Quản lý Hình ảnh (My Photos):** Kho lưu trữ ảnh cá nhân từ các chuyến đi. Hỗ trợ tải lên nhiều ảnh cùng lúc hoặc chụp ảnh mới.
* **Nhật ký hành trình (My Journeys):** Tạo các "album" kỷ niệm theo địa điểm. Mỗi hành trình bao gồm tên, địa danh và tập hợp các ảnh liên quan.
* **Cài đặt ứng dụng (Settings):** Tùy chỉnh thông báo, ngôn ngữ, phương thức thanh toán, xem chính sách và đăng xuất.

---

## 2. Phong cách UI (UI Style)
UI tập trung vào tính cá nhân hóa và trải nghiệm hình ảnh:
* **Visual-Heavy:** Sử dụng ảnh bìa (Cover photo) lớn và các lưới ảnh (Grid) sát cạnh nhau để làm nổi bật các khoảnh khắc du lịch.
* **Action-Oriented:** Các nút "Add Journey" hay "Add Photos" được thiết kế dạng Outline hoặc nút lớn với icon `+`, khuyến khích người dùng tạo nội dung.
* **Sạch sẽ & Phân cấp:** Trang Settings sử dụng các dòng đơn bản rộng kèm icon mảnh (Line icons) và mũi tên điều hướng, giúp danh sách tùy chọn không bị rối.
* **Trạng thái tương tác:** Trong màn hình chọn ảnh, các ảnh được chọn hiển thị dấu tích (Checkmark) xanh Mint đặc trưng để người dùng biết mình đang chọn bao nhiêu mục.

---

## 3. Thiết kế Cơ sở dữ liệu (SQL Schema) - Trọng tâm

Để vận hành module này, hệ thống cần cấu trúc dữ liệu liên kết chặt chẽ giữa người dùng và các thực thể nội dung:

### A. Bảng `Users` (Cập nhật/Mở rộng)
Lưu trữ thông tin cơ bản và định danh.
```sql
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255),
    avatar_url TEXT,            -- Ảnh đại diện
    cover_url TEXT,             -- Ảnh bìa profile
    role ENUM('Traveler', 'Guide'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### B. Bảng `User_Photos` (Kho ảnh cá nhân)
Lưu trữ tất cả ảnh người dùng tải lên hệ thống.
```sql
CREATE TABLE User_Photos (
    photo_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    image_path TEXT NOT NULL,    -- Đường dẫn lưu trữ ảnh
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_public BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
```

### C. Bảng `User_Journeys` (Hành trình/Kỷ niệm)
Quản lý các folder kỷ niệm như "A memory in Danang".
```sql
CREATE TABLE User_Journeys (
    journey_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    journey_name VARCHAR(255) NOT NULL,
    location_name VARCHAR(255),  -- Địa danh cụ thể
    description TEXT,
    created_date DATE,
    likes_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
```

### D. Bảng `Journey_Media` (Bảng trung gian liên kết Ảnh - Hành trình)
Một hành trình (Journey) có thể chứa nhiều ảnh từ kho ảnh (`User_Photos`).
```sql
CREATE TABLE Journey_Media (
    journey_id INT,
    photo_id INT,
    PRIMARY KEY (journey_id, photo_id),
    FOREIGN KEY (journey_id) REFERENCES User_Journeys(journey_id) ON DELETE CASCADE,
    FOREIGN KEY (photo_id) REFERENCES User_Photos(photo_id) ON DELETE CASCADE
);
```

### E. Bảng `User_Settings` (Cấu hình ứng dụng)
Lưu trữ tùy chỉnh cá nhân.
```sql
CREATE TABLE User_Settings (
    user_id INT PRIMARY KEY,
    enable_notifications BOOLEAN DEFAULT TRUE,
    preferred_language VARCHAR(10) DEFAULT 'en',
    currency_unit VARCHAR(5) DEFAULT 'USD',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
```

### F. Bảng `Password_Change_Logs` (Nhật ký bảo mật)
Theo dõi lịch sử đổi mật khẩu để bảo mật.
```sql
CREATE TABLE Password_Change_Logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
```

---
**Module 12** chuyển đổi ứng dụng từ một công cụ tìm kiếm đơn thuần thành một mạng xã hội du lịch thu nhỏ, nơi người dùng không chỉ tiêu thụ nội dung mà còn tự tạo ra giá trị và lưu trữ kỷ niệm của chính mình.