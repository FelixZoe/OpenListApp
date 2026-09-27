import SwiftUI

/// 任务页:未完成 / 已完成,玻璃分段控件切换。
struct TasksView: View {
    @Environment(AppState.self) private var app
    @State private var segment = 0
    @State private var tasks: [TaskItem] = []
    @State private var loading = false
    @State private var toast: ToastMessage?

    private var api: APIClient {
        APIClient(baseURL: app.baseURL, token: app.token)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Picker("任务类型", selection: $segment) {
                    Text("未完成").tag(0)
                    Text("已完成").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                content
            }
            .padding(.top, 8)
            .navigationTitle("任务")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await load() }
                    } label: {
                        Label("刷新", systemImage: "arrow.clockwise")
                    }
                }
            }
            .refreshable { await load() }
            .task(id: segment) { await load() }
            .glassToast($toast)
        }
    }

    @ViewBuilder
    private var content: some View {
        if loading && tasks.isEmpty {
            ProgressView()
        } else if tasks.isEmpty {
            ContentUnavailableView(
                segment == 0 ? "没有未完成任务" : "没有已完成任务",
                systemImage: "checkmark.circle"
            )
        } else {
            List {
                ForEach(tasks) { task in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(task.displayName)
                                .font(.subheadline.weight(.medium))
                                .lineLimit(2)
                            Spacer()
                            Text(task.displayState)
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(stateColor(task).opacity(0.16), in: .capsule)
                                .foregroundStyle(stateColor(task))
                        }
                        ProgressView(value: task.progressFraction)
                            .tint(stateColor(task))
                        HStack {
                            Spacer()
                            Text("\(Int(task.progressFraction * 100))%")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    private func stateColor(_ task: TaskItem) -> Color {
        switch task.displayState {
        case "running": return .blue
        case "succeed": return .green
        case "errored", "failed", "canceled": return .red
        default: return .orange
        }
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            tasks = try await api.tasks(undone: segment == 0)
        } catch {
            toast = ToastMessage(message: error.localizedDescription, isError: true)
        }
    }
}
