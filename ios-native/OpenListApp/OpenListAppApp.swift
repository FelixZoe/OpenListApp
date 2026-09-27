import SwiftUI

@main
struct OpenListApp: App {
    @State private var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            if appState.isSignedIn {
                RootTabView()
            } else {
                LoginView()
            }
            .environment(appState)
            .tint(.blue)
            .animation(.spring(duration: 0.4), value: appState.isSignedIn)
        }
    }
}
