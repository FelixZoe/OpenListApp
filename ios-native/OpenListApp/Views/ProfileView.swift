import SwiftUI

/// 我的:用户信息 + 原生服务器设置 + 登录/退出。
struct ProfileView: View {
    @Environment(AppState.self) private var app
    @State private var serverVersion: String?
    @State private var showServerSettings = false
    @State private var toast: ToastMessage?

    private var api: APIClient {
        APIClient(baseURL: app.baseURL, token: app.token)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Text(initialLetter)
                            .font(.title.bold())
                            .foregroundStyle(.white)
                            .frame(width: 58, height: 58)
                            .background(
                                LinearGradient(colors: [.blue, .blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: .rect(cornerRadius: 18)
                            )
                        VStack(alignment: .leading, spacing: 3) {
                            Text(app.hasToken ? (app.username.isEmpty ? "已登录" : app.username) : "访客模式")
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
                    Button {
                        showServerSettings = true
                    } label: {
                        Label("服务器设置", systemImage: "network")
                    }
                    row("服务器版本", value: serverVersion ?? "…")
                } header: {
                    Text("服务器")
                }

                Section {
                    Button(role: app.hasToken ? .destructive : nil) {
                        app.signOut()
                    } label: {
                        Label(app.hasToken ? "退出登录" : "去登录", systemImage: "rectangle.portrait.and.arrow.right")
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
            .sheet(isPresented: $showServerSettings) {
                ServerSettingsSheet()
            }
            .glassToast($toast)
        }
    }

    private var initialLetter: String {
        let first = app.username.prefix(1).uppercased()
        return first.isEmpty ? "O" : first
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

/// 原生服务器设置:修改目标服务器地址。
struct ServerSettingsSheet: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @State private var url = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("http://127.0.0.1:5244", text: $url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } footer: {
                    Text("修改后立即生效,客户端会连接新的服务器。")
                }
            }
            .navigationTitle("服务器设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let normalized = APIClient.normalizedBaseURL(url)
                        if !normalized.isEmpty {
                            app.baseURL = normalized
                        }
                        dismiss()
                    }
                }
            }
            .onAppear { url = app.baseURL }
        }
        .presentationDetents([.medium])
    }
}
