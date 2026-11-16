import Combine
import Foundation

@MainActor
final class APODViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case loaded([APODEntry])
        case failed(String)
    }
    
    @Published private(set) var state: State = .idle
    private let service = NASAAPIService()
    private let fileStore = APODFileStore()
    
    func loadEntries() async {
        if case .loading = state { return }
        state = .loading
        
        do {
            let entries = try await service.fetchEntries()
            let sortedEntries = entries.sorted { $0.date > $1.date }
            
            // Помилка запису не заважає показати дані, отримані від NASA.
            do {
                try fileStore.save(sortedEntries)
                print("APOD: публікації збережено в apod-cache.json")
            } catch {
                print("APOD: не вдалося записати кеш — \(error.localizedDescription)")
            }
            
            state = .loaded(sortedEntries)
        } catch {
            // Якщо запит не вдався, пробуємо прочитати локальну копію.
            if let cachedEntries = try? fileStore.load() {
                state = .loaded(cachedEntries)
                print("APOD: публікації завантажено з локального файла")
            } else {
                state = .failed(error.localizedDescription)
            }
        }
    }
}
