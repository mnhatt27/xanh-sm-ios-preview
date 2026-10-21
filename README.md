# Tạo IPA trên Windows bằng GitHub Actions

Đã chuyển giao diện Python sang ứng dụng SwiftUI gốc cho iPhone/iPad (iOS 16 trở lên).
Giữ màu đen/xanh, danh sách dịch vụ, bật/tắt từng dịch vụ, bật/tắt tất cả, đếm trạng thái,
lưu cấu hình và xóa nhật ký. Bố cục tự cuộn để dùng được trên màn hình iPhone.

Đây là bản xem giao diện. Các công tắc chỉ thay đổi dữ liệu nội bộ; không kết nối hoặc điều
khiển dịch vụ Xanh SM. Nút Lưu cấu hình lưu trên thiết bị, các thay đổi chưa lưu sẽ mất khi
ứng dụng khởi động lại. Nhật ký chỉ giữ trong phiên chạy (tối đa 200 dòng).

## 1. Đưa mã nguồn lên GitHub

1. Đăng nhập GitHub, tạo repository mới. Có thể dùng repository private; kiểm tra hạn mức
   và chi phí Actions của tài khoản trước khi chạy runner macOS.
2. Tải và giải nén `XanhSM-iOS-source.zip` vào một thư mục trên Windows.
3. Trong repository chọn **Add file → Upload files**. Kéo các thư mục `ios` và `.github`
   cùng file hướng dẫn này vào, giữ nguyên cấu trúc. Bật hiển thị file ẩn nếu chưa thấy `.github`.
4. Chọn **Commit changes**. Workflow phải nằm đúng tại `.github/workflows/build-ios.yml`,
   không nằm trong một thư mục cha khác.

## 2. Build và tải IPA

1. Mở tab **Actions** trong repository, bật Actions nếu GitHub yêu cầu.
2. Chọn **Build iOS IPA → Run workflow → Run workflow**.
3. Chờ lần chạy có dấu tích xanh. Mở lần chạy, kéo xuống **Artifacts**.
4. Tải **XanhSMPreview-unsigned-IPA**, giải nén để lấy `XanhSMPreview-unsigned.ipa`.
   Artifact được giữ 14 ngày; có thể chạy lại workflow để build mới.

Workflow chạy trên máy Mac của GitHub, sinh dự án Xcode bằng XcodeGen và biên dịch cho thiết
bị thật. Không cần nhập Apple ID hay chứng chỉ vào repository. Kết quả là IPA **chưa ký**,
không cài trực tiếp bằng cách mở file trên iPhone và không phải bản dành cho TestFlight.

## 3. Ký và cài từ Windows

Một lựa chọn là Sideloadly: https://sideloadly.io/ (có bản Windows).

1. Cài Sideloadly và các thành phần Apple mà hướng dẫn chính thức của công cụ yêu cầu.
2. Kết nối iPhone qua USB, mở khóa và chọn tin cậy máy tính.
3. Mở Sideloadly, chọn thiết bị và file IPA vừa tải.
4. Làm theo quy trình Apple ID sideload trong công cụ để ký và cài; chỉ nhập thông tin
   đăng nhập trực tiếp trong công cụ trên máy bạn, không đưa vào repository hay chat.
5. Nếu iPhone yêu cầu, tin cậy ứng dụng nhà phát triển trong Cài đặt → Cài đặt chung →
   VPN & Quản lý thiết bị; bật Chế độ nhà phát triển khi hệ thống yêu cầu.

Khả năng ký, thời hạn cài và nhu cầu ký lại phụ thuộc tài khoản Apple, phiên bản iOS và
công cụ. Nếu dùng chứng chỉ riêng, dùng quy trình ký tương ứng thay cho bước Apple ID.

## Mã nguồn và trạng thái kiểm tra

- `ios/Sources/XanhSMPreviewApp.swift`: toàn bộ giao diện và trạng thái cục bộ.
- `ios/Resources/config.json`: cấu hình ban đầu, sao chép từ bản desktop tại thời điểm chuyển.
- `ios/project.yml`: cấu hình dự án Xcode, bundle ID `com.minhnhat.xanhsmpreview`.
- `.github/workflows/build-ios.yml`: quy trình build IPA chưa ký.

Nguồn đã được chuẩn bị trên Windows. Chưa chạy Xcode, chưa kiểm tra hiển thị trên iPhone và
chưa tạo IPA thực tế trong phiên này. Lần chạy Actions đầu tiên là bước xác nhận biên dịch.
Nếu thất bại, mở bước màu đỏ để lấy thông báo lỗi.

Tham khảo chính thức:
- GitHub runner macOS: https://docs.github.com/en/actions/how-tos/write-workflows/choose-where-workflows-run/choose-the-runner-for-a-job
- XcodeGen: https://github.com/yonaskolb/XcodeGen
- Ký và phân phối iOS: https://developer.apple.com/documentation/xcode/distributing-your-app-to-registered-devices
