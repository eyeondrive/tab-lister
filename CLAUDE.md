# CLAUDE.md — tab-lister

## BEFORE RESPONDING TO THE USER, DO THIS FIRST:

This is an existing project. The user has selected this folder. Perform these steps silently before engaging:

1. **Greet the user and ask what we're working on.** This project is currently single-scope (macOS menubar app). No component picker needed unless the project grows. If it does, add a **Work Scopes** table to `docs/PROJECT-NOTES.md` — see [Project Notes System](../CLAUDE.md#project-notes-system--template) for the template.
2. **Load heavy context on demand** — `docs/PROJECT-NOTES.md` has the current state and design direction. Read when the task requires it, not at startup.

## What This Project Is

A macOS menubar app that lists and switches between open Safari tabs. Evolving into a tab triage and save-for-later tool. Built with Swift/SwiftUI.

## Tech Stack

- **Language:** Swift 5 (Swift 6.1.2 compiler)
- **UI:** SwiftUI with MenuBarExtra
- **Safari integration:** NSAppleScript
- **Deployment target:** macOS 14.0+

## Session Logs

Log path: `docs/logs/`. Start only when David asks: `log ./docs/logs`

## Ground Rules

- All project-specific rules live in `docs/PROJECT-NOTES.md` — do not duplicate them here.
- Request folder access immediately if needed.
