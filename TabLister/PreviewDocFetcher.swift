import Foundation

class PreviewDocFetcher: ObservableObject {
    @Published var docs: [PreviewDoc] = []

    func fetchDocs() {
        let script = """
        set output to ""
        tell application "Preview"
            set winCount to number of windows
            repeat with i from 1 to winCount
                try
                    set doc to document of window i
                    set docName to name of doc
                    set docPath to path of doc
                    set output to output & i & "\\t" & docName & "\\t" & docPath & linefeed
                end try
            end repeat
        end tell
        return output
        """

        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else { return }
        let result = appleScript.executeAndReturnError(&error)
        guard let output = result.stringValue else { return }

        docs = output
            .split(separator: "\n")
            .compactMap { line -> PreviewDoc? in
                let parts = line.split(separator: "\t", maxSplits: 2)
                guard parts.count == 3,
                      let windowIndex = Int(parts[0]) else { return nil }
                return PreviewDoc(
                    windowIndex: windowIndex,
                    name: String(parts[1]),
                    path: String(parts[2])
                )
            }
    }

    func activateDoc(_ doc: PreviewDoc) {
        let script = """
        tell application "Preview"
            set index of window \(doc.windowIndex) to 1
            activate
        end tell
        """

        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }
    }
}
