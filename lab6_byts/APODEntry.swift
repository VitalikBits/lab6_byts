import Foundation

struct APODEntry: Identifiable, Codable {
    let id: Int
    let title: String
    let date: String
    let explanation: String
    let mediaType: String
    let pageURL: URL?
    let imageURL: URL?

    // Зіставляємо назви полів JSON із властивостями Swift.
    enum CodingKeys: String, CodingKey {
        case id = "post_id"
        case title, date, explanation
        case mediaType = "media_type"
        case pageURL = "permalink"
        case imageURL = "hdurl"
    }
}
