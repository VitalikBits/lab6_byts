import Foundation

enum NASAAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некоректна адреса API."
        case .invalidResponse:
            return "NASA повернула неочікувану відповідь."
        case .httpError(let statusCode):
            return "Сервер NASA повернув помилку HTTP \(statusCode)."
        }
    }
}

struct NASAAPIService {
    func fetchEntries() async throws -> [APODEntry] {
        let address = "https://science.nasa.gov/wp-json/wp/v2/apod-basic?page=1&per_page=12"

        guard let url = URL(string: address) else {
            throw NASAAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)

        // Перевіряємо HTTP-статус перед декодуванням JSON.
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NASAAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NASAAPIError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode([APODEntry].self, from: data)
    }
}
