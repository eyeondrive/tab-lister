import SwiftUI

enum ListSource: String, CaseIterable {
    case safari = "Safari"
    case preview = "PDFs"
}

/// A flattened row for display, regardless of source.
private struct DisplayRow: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let activate: () -> Void
}

struct TabListView: View {
    @StateObject private var safariFetcher = SafariTabFetcher()
    @StateObject private var previewFetcher = PreviewDocFetcher()
    @State private var source: ListSource = .safari
    @State private var searchText = ""

    private var rows: [DisplayRow] {
        switch source {
        case .safari:
            return safariFetcher.tabs.map { tab in
                DisplayRow(id: tab.id, title: tab.title, subtitle: tab.url) {
                    safariFetcher.activateTab(tab)
                }
            }
        case .preview:
            return previewFetcher.docs.map { doc in
                DisplayRow(id: doc.id, title: doc.name, subtitle: doc.path) {
                    previewFetcher.activateDoc(doc)
                }
            }
        }
    }

    private var filteredRows: [DisplayRow] {
        if searchText.isEmpty { return rows }
        return rows.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var searchPrompt: String {
        source == .safari ? "Search tabs..." : "Search PDFs..."
    }

    private var emptyTitle: String {
        if !searchText.isEmpty { return "No Results" }
        return source == .safari ? "No Tabs" : "No PDFs"
    }

    private var emptyIcon: String {
        if !searchText.isEmpty { return "magnifyingglass" }
        return source == .safari ? "safari" : "doc.richtext"
    }

    private var emptyDescription: String {
        if !searchText.isEmpty { return "Nothing matching \"\(searchText)\"" }
        return source == .safari ? "Open some tabs in Safari" : "Open some PDFs in Preview"
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Source", selection: $source) {
                ForEach(ListSource.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 8)
            .padding(.top, 8)

            TextField(searchPrompt, text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(8)

            if filteredRows.isEmpty {
                ContentUnavailableView(
                    emptyTitle,
                    systemImage: emptyIcon,
                    description: Text(emptyDescription)
                )
                .frame(maxHeight: .infinity)
            } else {
                List(filteredRows) { row in
                    Button(action: row.activate) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.title)
                                .lineLimit(1)
                            Text(row.subtitle)
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
        .onAppear { refresh() }
        .onChange(of: source) { _, _ in refresh() }
    }

    private func refresh() {
        switch source {
        case .safari: safariFetcher.fetchTabs()
        case .preview: previewFetcher.fetchDocs()
        }
    }
}
