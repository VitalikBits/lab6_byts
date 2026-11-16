import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject private var viewModel = APODViewModel()
    @State private var showSettings = false
    @AppStorage("appTheme") private var theme = "system"
    @AppStorage("useLargeText") private var useLargeText = false
    @Environment(\.dynamicTypeSize) private var systemTextSize

    private var selectedColorScheme: ColorScheme? {
        switch theme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private var selectedTextSize: DynamicTypeSize {
        useLargeText ? max(systemTextSize, .xxxLarge) : systemTextSize
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("NASA APOD")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showSettings = true
                        } label: {
                            Label("Налаштування", systemImage: "gearshape")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .task {
                    if case .idle = viewModel.state {
                        await viewModel.loadEntries()
                    }
                }
        }
        .preferredColorScheme(selectedColorScheme)
        .dynamicTypeSize(selectedTextSize)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Завантаження публікацій…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let entries):
            if entries.isEmpty {
                Text("Публікацій не знайдено.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(entries) { entry in
                    NavigationLink {
                        APODDetailView(entry: entry)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title)
                                .font(.headline)

                            Text(entry.date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

        case .failed(let message):
            VStack(spacing: 12) {
                Text("Не вдалося завантажити публікації")
                    .font(.headline)

                Text(message)
                    .foregroundStyle(.secondary)

                Button("Спробувати ще раз") {
                    Task {
                        await viewModel.loadEntries()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
