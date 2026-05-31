---

# 🚀 Hướng Dẫn Cài Đặt Dự Án Fellow4U

Chào mừng bạn đến với dự án **Fellow4U** - Ứng dụng kết nối khách du lịch và hướng dẫn viên địa phương.

---

## 📋 Mục lục

1. [Chuẩn bị công cụ](https://www.google.com/search?q=%231-chu%E1%BA%A9n-b%E1%BB%8B-c%C3%B4ng-c%E1%BB%A5)
2. [Cài đặt Cơ sở dữ liệu (Database)](https://www.google.com/search?q=%232-c%C3%A0i-%C4%91%E1%BA%B7t-c%C6%A1-s%E1%BB%9F-d%E1%BB%AF-li%E1%BB%87u-database)
3. [Cài đặt và Chạy Backend](https://www.google.com/search?q=%233-c%C3%A0i-%C4%91%E1%BA%B7t-v%C3%A0-ch%E1%BA%A1y-backend)
4. [Cài đặt và Chạy ứng dụng Mobile (Flutter)](https://www.google.com/search?q=%234-c%C3%A0i-%C4%91%E1%BA%B7t-v%C3%A0-ch%E1%BA%A1y-%E1%BB%A9ng-d%E1%BB%A5ng-mobile-flutter)
5. [Các lỗi thường gặp](https://www.google.com/search?q=%235-c%C3%A1c-l%E1%BB%97i-th%C6%B0%E1%BB%9Dng-g%E1%BA%B7p)

---

## 1. Chuẩn bị công cụ

Trước khi bắt đầu, bạn cần cài đặt các phần mềm sau vào máy tính:

1. **Node.js**: Để chạy mã nguồn Backend. [Tải tại đây](https://nodejs.org/) (Chọn bản LTS).
2. **Flutter SDK**: Để chạy ứng dụng Mobile. [Xem hướng dẫn cài đặt](https://docs.flutter.dev/get-started/install).
3. **Docker Desktop**: Cách nhanh nhất để cài đặt Cơ sở dữ liệu mà không cần cấu hình phức tạp. [Tải tại đây](https://www.docker.com/products/docker-desktop/).
4. **Git**: Để quản lý mã nguồn. [Tải tại đây](https://git-scm.com/).
5. **VS Code**: Trình chỉnh sửa mã nguồn khuyên dùng.

---

## 2. Cài đặt Cơ sở dữ liệu (Database)

Dự án sử dụng **PostgreSQL**. Dùng Docker để khởi chạy nhanh.

1. Mở terminal (Command Prompt hoặc PowerShell).
2. Di chuyển vào thư mục `docker` của dự án:
```bash
cd docker

```


3. Khởi chạy database bằng lệnh:
```bash
docker compose down -v

docker compose up -d (x2)

docker ps

```

*Đảm bảo fellow4u_db, và fellow4u_api cùng chạy. Dùng docker ps để kiểm tra. Nếu API chưa chạy thì chạy docker compose up -d lần nữa.

*Lệnh này sẽ tự động tạo một máy chủ dữ liệu chạy ngầm trong máy.*

---


## 3. Cài đặt và Chạy Backend
Backend được viết bằng Node.js.

1. Mở một cửa sổ terminal mới và di chuyển vào thư mục `backend`:
```bash
cd backend

```


2. Cài đặt các thư viện cần thiết:
```bash
npm install

npm run migrate

```


3. **Cấu hình biến môi trường**:
* Tạo một file tên là `.env` trong thư mục `backend`.
* Sao chép nội dung sau vào file `.env`:
```env
PORT=3000
DB_NAME=fellow4u
DB_USER=admin
DB_PASS=P@sswordd
DB_HOST=localhost
DB_PORT=5432
JWT_SECRET=fellow4u_secret_key_2024

```


4. **Khởi tạo dữ liệu (Migrations & Seeding)**:
* Chạy lệnh để tạo các bảng trong database:
```bash
node src/utils/runMigrations.js

```


5. **Chạy server**:
```bash
npm start // hoặc npm run dev

```

*Nếu thấy dòng chữ "Server is running on port 3000", bạn đã thành công!*

---


## 4. Cài đặt và Chạy ứng dụng Mobile (Flutter)

Ứng dụng Mobile dành cho Android và iOS.

1. Mở một cửa sổ terminal mới và di chuyển vào thư mục `mobile`:
```bash
cd mobile

flutter clean

```

2. Tải các thư viện Flutter:
```bash
flutter pub get

```

3. **Kiểm tra thiết bị**:
* Mở trình giả lập Android (Emulator) hoặc iOS (Simulator).
* Hoặc cắm điện thoại thật của bạn vào máy tính qua cáp USB.


4. **Chạy ứng dụng**:
```bash
flutter run

```



---

## 5. Các lỗi thường gặp và cách xử lý

| Lỗi | Nguyên nhân | Cách xử lý |
| --- | --- | --- |
| `Connection refused` | Database chưa chạy | Kiểm tra xem Docker Desktop đã bật chưa và đã chạy lệnh `docker-compose up` chưa. |
| `flutter: command not found` | Chưa cài Flutter | Hãy cài đặt Flutter và thêm nó vào "Path" trong cài đặt máy tính. |
| Mobile không kết nối được Backend | Sai địa chỉ IP | Nếu chạy Android Emulator, trong file `api_client.dart`, hãy đổi `localhost` thành `10.0.2.2`. |
| Lỗi khi cài `npm install` | Phiên bản Node.js cũ | Cập nhật Node.js lên bản mới nhất (LTS). |

---

### 💡 Lưu ý cho người mới:

* **Backend** là "bộ não" lưu trữ dữ liệu, phải luôn chạy thì **Mobile** mới hoạt động được.
* Mỗi khi chạy dự án, hãy bật **Docker** trước, sau đó chạy lệnh khởi động **Backend**, cuối cùng mới mở **Mobile**.


## Thông tin đăng nhập

Tài khoản admin: [emily@example.com] / Password: Admin@123
