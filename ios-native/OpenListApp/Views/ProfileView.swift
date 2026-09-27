import SwiftUI

/// 我的:用户信息 + 常用入口 + 退出登录。
struct ProfileView: View {
    @Environment(AppState.self) private var app
    @State private var serverVersion: String?
    @State private var toast: ToastMessage?

    private var api: APIClient {
        APIClient(baseURL: app.baseURL, token: app.token)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Text(String(app.username.prefix(1)).uppercased().isEmpty
                             ? "O" : String(app.username.prefix(1)).uppercased())
                            .font(.title.bold())
                            .foregroundStyle(.white)
                            .frame(width: 58, height: 58)
                            .background(
                                LinearGradient(colors: [.blue, .blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: .rect(cornerRadius: 18)
                            )
                        VStack(alignment: .leading, spacing: 3) {
                            Text(app.username.isEmpty ? "未登录" : app.username)
                                .font(.title3.bold())
                            Text(app.baseURL)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    Link(destination: URL(string: app.baseURL) ?? URL(string: "https://github.com/OpenListTeam")!) {
                        Label("在浏览器中打开", systemImage: "safari")
                    }
                    row("服务器版本", value: serverVersion ?? "…")
                } header: {
                    Text("服务器")
                }

                Section {
                    Button(role: .destructive) {
                        app.signOut()
                    } label: {
                        Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("我的")
            .task {
                if let settings = try? await api.publicSettings() {
                    serverVersion = settings.version
                }
            }
            .glassToast($toast)
        }
    }

    private func row(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
