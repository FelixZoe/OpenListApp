import SwiftUI

struct ToastMessage: Equatable, Identifiable {
    let id = UUID()
    let message: String
    let isError: Bool
}

/// 顶部悬浮的原生液态玻璃轻提示。
struct GlassToastView: View {
    let toast: ToastMessage

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: toast.isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundStyle(toast.isError ? Color.red : Color.green)
            Text(toast.message)
                .font(.subheadline.weight(.medium))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: .capsule)
    }
}

/// `.glassToast($toast)` —— 顶部弹出、自动消失。
struct GlassToastModifier: ViewModifier {
    @Binding var toast: ToastMessage?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast {
                    GlassToastView(toast: toast)
                        .padding(.top, 6)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .task {
                            try? await Task.sleep(for: .seconds(2.4))
                            withAnimation(.spring(duration: 0.35)) {
                                if self.toast?.id == toast.id {
                                    self.toast = nil
                                }
                            }
                        }
                }
            }
            .animation(.spring(duration: 0.35), value: toast)
    }
}

extension View {
    func glassToast(_ toast: Binding<ToastMessage?>) -> some View {
        modifier(GlassToastModifier(toast: toast))
    }
}
