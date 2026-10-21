import SwiftUI

struct Service: Codable, Identifiable {
    let id: String
    let name: String
    let desc: String
    let icon: String
    var enabled: Bool
}

struct Configuration: Codable {
    let app_title: String
    let version: String
    var services: [Service]
}

struct LogEntry: Identifiable {
    let id = UUID()
    let time = Date()
    let message: String
}

struct AppNotice: Identifiable {
    let id = UUID()
    let message: String
}

@MainActor final class ServiceStore: ObservableObject {
    @Published var configuration: Configuration
    @Published var logs: [LogEntry] = []
    @Published var notice: AppNotice?
    private static let storageKey = "xanhsm.configuration.v1"

    init() {
        let saved = UserDefaults.standard.data(forKey: Self.storageKey)
            .flatMap { try? JSONDecoder().decode(Configuration.self, from: $0) }
        let bundled = Bundle.main.url(forResource: "config", withExtension: "json")
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? JSONDecoder().decode(Configuration.self, from: $0) }
        configuration = saved ?? bundled ?? Configuration(
            app_title: "Mystic XanhSM", version: "v1.1", services: [])
        log("Đợi inject.")
        if saved == nil && bundled == nil { log("Không đọc được cấu hình dịch vụ.") }
    }

    var activeCount: Int { configuration.services.filter { $0.enabled }.count }

    func setEnabled(_ id: String, _ enabled: Bool) {
        guard let index = configuration.services.firstIndex(where: { $0.id == id }) else { return }
        configuration.services[index].enabled = enabled
        log("[\(configuration.services[index].name)] \(enabled ? "ĐÃ BẬT" : "ĐÃ TẮT")")
    }

    func setAll(_ enabled: Bool) {
        for index in configuration.services.indices {
            configuration.services[index].enabled = enabled
        }
        log(enabled ? "✓ Đã bật toàn bộ dịch vụ." : "✕ Đã tắt toàn bộ dịch vụ.")
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(configuration)
            UserDefaults.standard.set(data, forKey: Self.storageKey)
            log("💾 Đã lưu cấu hình trên thiết bị.")
            notice = AppNotice(message: "Đã lưu thành công")
        } catch {
            let message = "Không lưu được cấu hình: \(error.localizedDescription)"
            log(message)
            notice = AppNotice(message: message)
        }
    }

    func log(_ message: String) {
        logs.append(LogEntry(message: message))
        if logs.count > 200 { logs.removeFirst(logs.count - 200) }
    }
}

private enum Theme {
    static let background = Color(red: 9/255, green: 13/255, blue: 20/255)
    static let card = Color(red: 17/255, green: 24/255, blue: 39/255)
    static let border = Color(red: 30/255, green: 45/255, blue: 66/255)
    static let blue = Color(red: 56/255, green: 189/255, blue: 248/255)
    static let muted = Color(red: 148/255, green: 163/255, blue: 184/255)
}

@main struct XanhSMPreviewApp: App {
    var body: some Scene {
        WindowGroup { ContentView().preferredColorScheme(.dark) }
    }
}

struct ContentView: View {
    @StateObject private var store = ServiceStore()
    @State private var isInjecting = false
    @State private var isReady = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                injectButton
                HStack {
                    Text("Đang hoạt động: \(store.activeCount)/\(store.configuration.services.count) dịch vụ")
                        .font(.subheadline.weight(.semibold)).foregroundStyle(Theme.blue)
                    Spacer(minLength: 0)
                }
                .padding(16).background(Theme.card, in: RoundedRectangle(cornerRadius: 12))

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) { actions }
                    VStack(spacing: 8) { actions }
                }

                ForEach(store.configuration.services) { service in
                    serviceCard(service)
                }
                console
            }
            .padding(20).frame(maxWidth: 680).frame(maxWidth: .infinity)
        }
        .background(Theme.background).tint(Theme.blue)
        .overlay {
            if isInjecting {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView().tint(Theme.blue).scaleEffect(1.3)
                        Text("Đang Inject...").font(.headline)
                        Text("Green SM Driver").font(.subheadline).foregroundStyle(Theme.muted)
                    }
                    .padding(32).background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .task(id: isInjecting) {
            guard isInjecting else { return }
            do { try await Task.sleep(nanoseconds: 5_000_000_000) }
            catch { return }
            guard !Task.isCancelled else { return }
            isReady = true
            isInjecting = false
            store.log("Inject thành công. Sẵn sàng.")
            store.notice = AppNotice(message: "Inject thành công")
        }
        .alert(item: $store.notice) { notice in
            Alert(title: Text("Mystic XanhSM"), message: Text(notice.message), dismissButton: .default(Text("OK")))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("CONTROL CENTER").font(.caption2.bold()).tracking(2)
                .foregroundStyle(Theme.blue).padding(.horizontal, 10).padding(.vertical, 6)
                .background(Theme.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 5))
            Text("Mystic XanhSM").font(.largeTitle.bold())
            Text("Quản lý & Điều phối Dịch vụ Thông minh")
                .font(.subheadline).foregroundStyle(Theme.muted)
            Label(isInjecting ? "ĐANG INJECT" : (isReady ? "SẴN SÀNG" : "ĐỢI INJECT"), systemImage: "circle.fill")
                .font(.caption2.bold()).foregroundStyle(Theme.blue)
                .padding(.top, 4)
        }.padding(.vertical, 8)
    }

    private var injectButton: some View {
        Button {
            guard !isInjecting else { return }
            isReady = false
            isInjecting = true
            store.log("Đang Inject Green SM Driver...")
        } label: {
            VStack(spacing: 4) {
                Text("Inject").font(.headline)
                Text("Green SM Driver").font(.headline.bold())
            }
            .frame(maxWidth: .infinity, minHeight: 64)
            .foregroundStyle(Color.white)
            .background(Theme.blue.opacity(0.65), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(isInjecting)
        .accessibilityLabel("Inject Green SM Driver")
    }

    @ViewBuilder private var actions: some View {
        action("Bật tất cả", icon: "checkmark", primary: false) { store.setAll(true) }
        action("Tắt tất cả", icon: "xmark", primary: false) { store.setAll(false) }
        action("Lưu cấu hình", icon: "square.and.arrow.down", primary: true) { store.save() }
    }

    private func action(_ title: String, icon: String, primary: Bool, perform: @escaping () -> Void) -> some View {
        Button(action: perform) {
            Label(title, systemImage: icon).font(.caption.weight(.semibold))
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal, 10)
                .foregroundStyle(primary ? Color.white : Theme.blue)
                .background(primary ? Color(red: 2/255, green: 132/255, blue: 199/255) : Theme.card,
                            in: RoundedRectangle(cornerRadius: 9))
        }.buttonStyle(.plain)
    }

    private func serviceCard(_ service: Service) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(service.icon).font(.system(size: 26)).frame(width: 48, height: 48)
                .background(Theme.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 8) {
                Text(service.name).font(.headline).fixedSize(horizontal: false, vertical: true)
                Text(service.desc).font(.caption).foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Text(service.enabled ? "● ĐANG BẬT" : "○ ĐÃ TẮT")
                        .font(.caption2.bold())
                        .foregroundStyle(service.enabled ? Theme.blue : Theme.muted)
                    Spacer()
                    Toggle(service.name, isOn: Binding(
                        get: { store.configuration.services.first(where: { $0.id == service.id })?.enabled ?? false },
                        set: { store.setEnabled(service.id, $0) }
                    )).labelsHidden()
                }
            }
        }
        .padding(15).background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(service.enabled ? Theme.blue.opacity(0.6) : Theme.border, lineWidth: 1))
    }

    private var console: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("⚡ NHẬT KÝ HOẠT ĐỘNG").font(.caption.bold()).foregroundStyle(Theme.blue)
                Spacer()
                Button("Xóa log") { store.logs.removeAll() }
                    .font(.caption).frame(minHeight: 44)
            }
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(store.logs) { entry in
                            (Text(entry.time, style: .time) + Text("  " + entry.message))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(Theme.muted).id(entry.id)
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(12)
                }
                .frame(height: 150)
                .background(Color.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
                .onChange(of: store.logs.count) { _ in
                    if let last = store.logs.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }
}
