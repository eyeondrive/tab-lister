import SwiftUI

struct TabListView: View {
    @StateObject private var fetcher = SafariTabFetcher()
    @State private var searchText = ""

    var filteredTabs: [SafariTab] {
        if searchText.isEmpty {
            return fetcher.tabs
        }
        return fetcher.tabs.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.url.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search tabs...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(8)

            if filteredTabs.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "No Tabs" : "No Results",
                    systemImage: searchText.isEmpty ? "safari" : "magnifyingglass",
                    description: Text(
                        searchText.isEmpty
                            ? "Open some tabs in Safari"
                            : "No tabs matching \"\(searchText)\""
                    )
                )
                .frame(maxHeight: .infinity)
            } else {
                List(filteredTabs) { tab in
                    Button(action: { fetcher.activateTab(tab) }) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tab.title)
                                .lineLimit(1)
                            Text(tab.url)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(width: 400, height: 500)
        .onAppear { fetcher.fetchTabs() }
    }
}
