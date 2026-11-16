import SwiftUI
import UIKit

struct APODDetailView: View {
    let entry: APODEntry
    @State private var descriptionText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(entry.title)
                    .font(.title.bold())

                Text(entry.date)
                    .foregroundStyle(.secondary)

                media

                Text(descriptionText)

                if let pageURL = entry.pageURL {
                    Link("Відкрити публікацію на сайті NASA", destination: pageURL)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Публікація")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            descriptionText = plainText(from: entry.explanation)
        }
    }

    @ViewBuilder
    private var media: some View {
        if entry.mediaType == "image", let imageURL = entry.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView("Завантаження зображення…")
                        .frame(maxWidth: .infinity, minHeight: 160)

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                case .failure:
                    Text("Не вдалося завантажити зображення.")
                        .foregroundStyle(.secondary)

                @unknown default:
                    EmptyView()
                }
            }
        } else if entry.mediaType == "image" {
            Text("До цієї публікації немає зображення.")
                .foregroundStyle(.secondary)
        } else {
            Text("Відео або інтерактивний матеріал можна переглянути на сайті NASA.")
                .foregroundStyle(.secondary)
        }
    }

    // NASA повертає опис із HTML-тегами. Залишаємо лише текст.
    @MainActor
    private func plainText(from html: String) -> String {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        let text = try? NSAttributedString(
            data: Data(html.utf8),
            options: options,
            documentAttributes: nil
        )

        return text?.string.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? "Не вдалося прочитати опис."
    }
}
