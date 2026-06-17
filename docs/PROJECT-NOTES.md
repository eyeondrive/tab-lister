# Tab Lister — Project Notes

## What It Is

A macOS menubar app that replaces the broken "Tab Finder" app. Started as a simple Safari tab switcher, evolving into a tab triage and save-for-later tool.

## Current State

### v2.0 — Safari + PDF source toggle (deployed to /Applications)
- Segmented **Safari | PDFs** control at top of the popover swaps the list source
- PDFs: lists open Preview documents (name + file path) via AppleScript over Preview's windows; click brings that PDF's window/tab to front
- First PDF query triggers a one-time TCC prompt to control Preview
- Files added: `PreviewDoc.swift` (model), `PreviewDocFetcher.swift` (AppleScript bridge); `TabListView` now renders a unified `DisplayRow` list driven by a `ListSource` enum
- Prior build archived at `old-versions/TabLister-v1.0.app` (convention: snapshot the installed app here before overwriting `/Applications`)

### v1.0 — Working MVP (deployed to /Applications)
- Menubar app with list icon
- Lists all open Safari tabs across all windows
- Search/filter by tab title or URL
- Click to activate a tab (brings window to front, switches to that tab)
- Built with Swift/SwiftUI, uses AppleScript to talk to Safari
- No sandboxing (needed for Apple Events)

### Tech Stack
- **Language:** Swift 5 (Swift 6.1.2 compiler, language mode 5)
- **UI:** SwiftUI with MenuBarExtra (.window style)
- **Safari integration:** NSAppleScript executing inline AppleScript
- **Deployment target:** macOS 14.0+
- **Xcode:** 16.4
- **Bundle ID:** com.eyeondrive.TabLister

### Files
- `TabLister/TabListerApp.swift` — App entry point, MenuBarExtra
- `TabLister/TabListView.swift` — Search field + tab list UI
- `TabLister/SafariTabFetcher.swift` — AppleScript bridge for fetching/activating tabs
- `TabLister/Tab.swift` — SafariTab data model
- `Safari_tab_lister_notes.scpt` — Original AppleScript (reference, creates Notes with tab list)
- `TabLister.pen` — UI design file (Pencil)

### Repo
- GitHub: https://github.com/eyeondrive/tab-lister
- Branch: main

## Vision — "Personal Google"

The real problem is **working memory externalization**. Safari tabs stay open not because they're being read, but because closing them feels like losing the thought. Every save-and-close tool fails because "out of sight, out of mind" kicks in immediately.

The solution is a system that:
- Stores everything in a local SQLite database — the ground truth
- Keeps important things *present and visible* without eating RAM
- Replaces Safari's tab pile with a dashboard that surfaces what needs doing
- Provides AI-powered search over your personal link archive ("personal Google") instead of relying on memory or browser search

### The Link Problem in Full

David has links spread across three historical tranches:
- **Bear** — most recent, highest signal quality
- **Safari On Deck folder** — middle era, mixed quality
- **Safari Bookmarks** — oldest, most link decay, most noise

Plus ~25% of open tabs are **management/service pages** (Supabase, Claude.ai, Google AI, billing sites) — not research links, but destinations visited repeatedly. These need to be instantly accessible, not buried.

---

## Architecture

### Components

**1. SQLite Database (local)**
The ground truth. Every link lives here.

Schema (draft):
- `url`, `title`, `summary` (AI-generated)
- `why_important` (user-written)
- `type` (YouTube, News, Tool, Account Mgmt, Billing, Reference, etc.)
- `classification` (Watch Later, Reference, Account Mgmt, Hot List, Triage)
- `tags` (hierarchical, reflecting source + topic)
- `source` (Bear, SafariOnDeck, Bookmarks, Manual)
- `safari_bookmark_folder` (if also written to Safari bookmarks — null if not)
- `date_saved`, `last_retrieved`
- `link_status` (live, dead, unchecked)
- `import_status` (processed, pending, skipped)
- `ai_relevance_score`, `ai_relevance_notes`

**2. Safari Web Extension (capture)**
- Toolbar button in Safari
- "Save this page" → AI generates summary, detects type, suggests tags
- User confirms/edits in a quick popup, assigns classification
- Saves to DB; optionally writes to Safari bookmarks in the right folder
- Fast path: 2-3 seconds for the common case

**3. Menubar App (tab-lister evolved)**
- Lists open Safari tabs (existing functionality)
- Checkbox-select multiple tabs for batch save
- Shows "needs doing" count as badge
- Quick access to hot list and active queue
- Working memory surface — open it and see what's on deck

**4. Local Web App ("Personal Google")**
- Runs on localhost, always-on background service
- AI-powered natural language search over the DB
- Triage queue interface — review imports in digestible batches (10-20 at a time)
- Daily dashboard: hot list, pending actions, recently saved
- Added as first Favorite in Safari — one click from anywhere
- Effectively becomes the Safari new-tab experience via the Favorites bar

### Safari Bookmarks Integration

Safari bookmarks become a **curated tier**, not a dump. The app manages them:
- DB is the full archive — everything
- Save process optionally writes high-value links into specific Safari bookmark folders
- Bookmarks bar stays clean and intentional, managed by the tool not by hand
- Favorites folder = hot list (management pages, billing, daily-use tools)

This empties out the existing bookmarks cruft and reclaims bookmarks as a useful fast-access layer.

---

## Sub-Projects

### Importer
Background job that ingests existing link sources into the DB.

**Sources (in priority order):**
1. Bear — newest, highest signal. Extract links from notes; treat as first-class items with note context attached.
2. Safari On Deck folder — middle era. Parse from `~/Library/Safari/Bookmarks.plist`.
3. Safari Bookmarks — oldest, most decay. Parse full plist; folder structure becomes initial tags.

**Per-link processing:**
1. HTTP check — is the link alive?
2. Dead links → auto-archived, flagged for review
3. Live links → fetch content, AI generates summary + relevance score
4. Low-confidence relevance → triage queue
5. High-confidence → auto-categorized, written to DB

**Triage design:**
- AI does the cognitive heavy lifting — presents batches with recommendation + reasoning
- David approves/rejects, doesn't decide from scratch
- Rule accumulation: "anything from domain X is always keep/discard" — same judgment doesn't repeat
- Daily budget cap on AI processing; job tracks progress and resumes next day

---

## Build Order

1. **DB schema** — get this right first, everything else depends on it
2. **Safari extension + capture flow** — proves the save + AI metadata pipeline (single page)
3. **Batch save from menubar** — builds on capture flow, adds multi-tab selection
4. **Local web app** — search UI, triage queue, dashboard
5. **Importer** — background job, starts with Bear, works backward through tranches
6. **Safari bookmarks sync** — write curated links back into Safari folders

---

## Current State

### v1.0 — Working MVP (deployed to /Applications)
- Menubar app with list icon
- Lists all open Safari tabs across all windows
- Search/filter by tab title or URL
- Click to activate a tab (brings window to front, switches to that tab)
- Built with Swift/SwiftUI, uses AppleScript to talk to Safari
- No sandboxing (needed for Apple Events)

### Tech Stack
- **Language:** Swift 5 (Swift 6.1.2 compiler, language mode 5)
- **UI:** SwiftUI with MenuBarExtra (.window style)
- **Safari integration:** NSAppleScript executing inline AppleScript
- **Deployment target:** macOS 14.0+
- **Xcode:** 16.4
- **Bundle ID:** com.eyeondrive.TabLister
- **AI:** Claude via local bridge (dev), direct API (prod)

### Files
- `TabLister/TabListerApp.swift` — App entry point, MenuBarExtra
- `TabLister/TabListView.swift` — Search field + tab list UI
- `TabLister/SafariTabFetcher.swift` — AppleScript bridge for fetching/activating tabs
- `TabLister/Tab.swift` — SafariTab data model
- `Safari_tab_lister_notes.scpt` — Original AppleScript (reference)
- `TabLister.pen` — UI design file (Pencil)

### Repo
- GitHub: https://github.com/eyeondrive/tab-lister
- Branch: main
