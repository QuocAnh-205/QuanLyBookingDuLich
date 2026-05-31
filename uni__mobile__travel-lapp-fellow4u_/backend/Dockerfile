# Dockerfile for Fellow4U backend application
# Sử dụng node image bản nhẹ
FROM node:18-alpine

# Thiết lập thư mục làm việc trong container
WORKDIR /app

# Copy file package và cài đặt dependencies
COPY package*.json ./
RUN npm install

# Copy toàn bộ source code vào container
COPY . .

# Mở port 3000
EXPOSE 3000

# Lệnh khởi chạy server
CMD ["npm", "start"]