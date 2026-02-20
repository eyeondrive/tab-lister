import Foundation

class SafariTabFetcher: ObservableObject {
    @Published var tabs: [SafariTab] = []

    func fetchTabs() {
        let script = """
        set output to ""
        tell application "Safari"
            set windowCount to number of windows
            repeat with x from 1 to windowCount
                set tabcount to number of tabs of window x
                repeat with y from 1 to tabcount
                    set tabName to name of tab y of window x
                    set tabURL to URL of tab y of window x
                    set output to output & x & "\\t" & y & "\\t" & tabName & "\\t" & tabURL & linefeed
                end repeat
            end repeat
        end tell
        return output
        """

        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else { return }
        let result = appleScript.executeAndReturnError(&error)
        guard let output = result.stringValue else { return }

        tabs = output
            .split(separator: "\n")
            .compactMap { line -> SafariTab? in
                let parts = line.split(separator: "\t", maxSplits: 3)
                guard parts.count == 4,
                      let windowIndex = Int(parts[0]),
                      let tabIndex = Int(parts[1]) else { return nil }
                return SafariTab(
                    windowIndex: windowIndex,
                    tabIndex: tabIndex,
                    title: String(parts[2]),
                    url: String(parts[3])
                )
            }
    }

    func activateTab(_ tab: SafariTab) {
        let script = """
        tell application "Safari"
            set index of window \(tab.windowIndex) to 1
            set current tab of window 1 to tab \(tab.tabIndex) of window 1
            activate
        end tell
        """

        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }
    }
}
