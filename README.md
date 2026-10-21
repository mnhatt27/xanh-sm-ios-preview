# Xanh SM iOS Preview

Ứng dụng SwiftUI xem giao diện trên iPhone/iPad, iOS 16 trở lên. Bao gồm 5 dịch vụ, công tắc, bật/tắt tất cả, lưu cấu hình trên thiết bị và nhật ký. Đây là bản giao diện cục bộ, không kết nối dịch vụ Xanh SM.

## Tải IPA

Mở Actions → Build iOS IPA → chọn lần chạy thành công → Artifacts → XanhSMPreview-unsigned-IPA. Giải nén để lấy IPA chưa ký. Có thể chạy lại qua Run workflow.

Dùng Sideloadly trên Windows (https://sideloadly.io/) để ký và cài lên iPhone theo hướng dẫn chính thức của công cụ. Apple ID miễn phí thường cần ký lại sau 7 ngày. Không đưa Apple ID, mật khẩu hoặc chứng chỉ vào repository.

## Mã nguồn

- XanhSMPreviewApp.swift: giao diện và trạng thái cục bộ.
- config.json: cấu hình ban đầu từ bản desktop.
- project.yml: XcodeGen sinh dự án Xcode.
- .github/workflows/build-ios.yml: build IPA trên macOS của GitHub.

Nút Lưu cấu hình giữ trạng thái qua các lần mở ứng dụng. Nhật ký chỉ giữ trong phiên chạy, tối đa 200 dòng. IPA chưa ký không mở trực tiếp để cài và không dùng cho TestFlight.
