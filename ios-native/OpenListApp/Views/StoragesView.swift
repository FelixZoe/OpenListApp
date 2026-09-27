import SwiftUI

/// 存储空间列表:系统 List/滑动操作,玻璃由系统渲染。
struct StoragesView: View {
    @Environment(AppState.self) private var app
    @State private var storages: [Storage] = []
    @State private var loading = false
    @State private var showAdd = false
    @State private var errorText: String?
    @State private var pendingDelete: Storage?

    private var api: APIClient {
        APIClient(baseURL: app.baseURL, token: app.token)
    }

    var body: some View {
        NavigationStack {
            Group {
                if loading && storages.isEmpty {
                    ProgressView()
                } else if storages.isEmpty {
                    ContentUnavailableView(
                        "还没有存储空间",
                        systemImage: "internaldrive",
                        description: Text("点击右上角 + 添加存储")
                    )
                } else {
                    storageList
                }
            }
            .navigationTitle("存储")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAdd = true
                    } label: {
                        Label("添加存储", systemImage: "plus")
                    }
                }
            }
            .refreshable { await load() }
            .task { await load() }
            .sheet(isPresented: $showAdd) {
                AddStorageSheet(api: api) {
                    await load()
                }
            }
            .confirmationDialog(
                "删除存储 \(pendingDelete?.mountPath ?? "")?",
                isPresented: Binding(
                    get: { pendingDelete != nil },
                    set: { if !$0 { pendingDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("删除", role: .destructive) {
                    guard let storage = pendingDelete else { return }
                    pendingDelete = nil
                    Task { await delete(storage) }
                }
                Button("取消", role: .cancel) {}
            }
            .errorAlert($errorText)
        }
    }

    private var storageList: some View {
        List {
            ForEach(storages) { storage in
                row(storage)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            pendingDelete = storage
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                        Button {
                            Task { await toggle(storage) }
                        } label: {
                            Label(storage.isDisabled ? "启用" : "停用", systemImage: "power")
                        }
                        .tint(storage.isDisabled ? .green : .orange)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func row(_ storage: Storage) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "internaldrive")
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 3) {
                Text(storage.mountPath)
                    .font(.headline)
                Text(storage.remark ?? storage.driverName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(storage.driverName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(statusText(storage))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(statusColor(storage))
            }
        }
        .padding(.vertical, 2)
    }

    private func statusText(_ storage: Storage) -> String {
        if storage.isDisabled { return "停用" }
        return storage.isWorking ? "工作" : (storage.status ?? "未知")
    }

    private func statusColor(_ storage: Storage) -> Color {
        if storage.isDisabled { return .orange }
        return storage.isWorking ? .green : .gray
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            storages = try await api.storages()
        } catch {
            errorText = error.localizedDescription
        }
    }

    private func toggle(_ storage: Storage) async {
        do {
            try await api.setStorageEnabled(storage.isDisabled, id: storage.id)
            await load()
        } catch {
            errorText = error.localizedDescription
        }
    }

    private func delete(_ storage: Storage) async {
        do {
            try await api.deleteStorage(id: storage.id)
            await load()
        } catch {
            errorText = error.localizedDescription
        }
    }
}
