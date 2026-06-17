import Foundation

struct PreviewDoc: Identifiable, Hashable {
    let id = UUID()
    let windowIndex: Int
    let name: String
    let path: String
}
