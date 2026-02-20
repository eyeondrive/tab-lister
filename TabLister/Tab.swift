import Foundation

struct SafariTab: Identifiable, Hashable {
    let id = UUID()
    let windowIndex: Int
    let tabIndex: Int
    let title: String
    let url: String
}
