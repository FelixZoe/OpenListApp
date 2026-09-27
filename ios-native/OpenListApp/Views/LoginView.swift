import SwiftUI

/// 登录页:液态玻璃卡片表单。
struct LoginView: View {
    @Environment(AppState.self) private var app
    @State private var serverURL: String = ""
    @State private var username: String = "admin"
    @State private var password: String = ""
    @State private var busy = false
    @State private var toast: ToastMessage?

    private enum Field: Hashable {
        case server, username, password
    }
    @FocusState private var focused: Field?

    var body: some View {
        ZStack {
            // 彩色渐变墙,为玻璃提供折射内容。
            LinearGradient(
                colors: [.blue.opacity(0.4), .purple.opacity(0.35), .teal.opacity(0.35), .pink.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    brand
                    form
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .glassToast($toast)
        .onAppear {
            if serverURL.isEmpty {
                serverURL = app.baseURL
            }
        }
    }

    private var brand: some View {
        VStack(spacing: 10) {
            Image(systemName: "internaldrive.fill")
                .font(.system(size: 54, weight: .semibold))
                .foregroundStyle(.white)
                .padding(24)
                .glassEffect(.regular.tint(.blue.opacity(0.35)).interactive(), in: .rect(cornerRadius: 32))
            Text("OpenList")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Text("AList / OpenList 客户端")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.top, 24)
    }

    private var form: some View {
        GlassEffectContainer(spacing: 14) {
            VStack(spacing: 14) {
                field("服务器地址", systemImage: "link", text: $serverURL, kind: .server)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                field("用户名", systemImage: "person.fill", text: $username, kind: .username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                field("密码", systemImage: "lock.fill", text: $password, kind: .password, secure: true)

                Button {
                    Task { await signIn() }
                } label: {
                    HStack {
                        if busy {
                            ProgressView().controlSize(.small).tint(.white)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        Text("登录")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.glassProminent)
                .disabled(busy)
                .padding(.top, 6)

                Button("跳过登录") {
                    Task { await skipLogin() }
                }
                .buttonStyle(.glass)
                .disabled(busy)
            }
        }
    }

    private func field(_ placeholder: String, systemImage: String, text: Binding<String>, kind: Field, secure: Bool = false) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
            Group {
                if secure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassEffect(.regular, in: .rect(cornerRadius: 18))
        .focused($focused, equals: kind)
        .onSubmit {
            switch kind {
            case .server: focused = .username
            case .username: focused = .password
            case .password: Task { await signIn() }
            }
        }
    }

    private func signIn() async {
        focused = nil
        let base = APIClient.normalizedBaseURL(serverURL)
        guard !base.isEmpty, !username.isEmpty, !password.isEmpty else {
            toast = ToastMessage(message: "请填写服务器地址、用户名和密码", isError: true)
            return
        }
        busy = true
        defer { busy = false }
        let api = APIClient(baseURL: base)
        do {
            let token = try await api.login(username: username, password: password)
            var name = username
            if let me = try? await APIClient(baseURL: base, token: token).me() {
                name = me.username ?? username
            }
            app.signIn(baseURL: base, token: token, username: name)
        } catch {
            toast = ToastMessage(message: error.localizedDescription, isError: true)
        }
    }

    private func skipLogin() async {
        let base = APIClient.normalizedBaseURL(serverURL)
        guard !base.isEmpty else {
            toast = ToastMessage(message: "请先填写服务器地址", isError: true)
            return
        }
        app.signIn(baseURL: base, token: "", username: "")
    }
}
