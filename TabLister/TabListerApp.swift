import SwiftUI

@main
struct TabListerApp: App {
    var body: some Scene {
        MenuBarExtra("Tab Lister", systemImage: "list.bullet.rectangle") {
            TabListView()
        }
        .menuBarExtraStyle(.window)
    }
}
