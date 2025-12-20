# File Guide

## App
*   **TheDumpApp.swift**: 2025-12-20T14:31:40-05:00: App entry + auth gate; routes authenticated users into `MainTabView`. Imports SwiftUI, FirebaseCore. Imported by Xcode app target; imports `Views/MainTabView.swift`, `Views/AuthView.swift`, `State/AppState.swift`.

## Models
*   **Models/NoteModels.swift**: 2025-12-19: Defines Swift Codable structs (NoteCountsResponse, NoteListResponse, NoteDetailResponse) to map JSON responses from the Flask API for the Notes feature. Imported by NotesService.

## Services
*   **Services/NotesService.swift**: 2025-12-20T14:31:40-05:00: Handles authenticated requests to the Notes API (counts + pull_notes + pull_full_notes), including query-param filtering for Browse/List UI. Imported by `State/BrowseViewModel.swift` (and future Notes list/detail VMs). Imports Foundation, `Models/NoteModels.swift`, `Services/AuthService.swift`, `Models/APIError.swift`.

## State
*   **State/BrowseViewModel.swift**: 2025-12-20T14:31:40-05:00: Loads `/api/note_counts` and exposes sorted folder rows (categories/date groups/mime types) for `BrowseView`. Imported by `Views/BrowseView.swift`. Imports Foundation, `Services/NotesService.swift`.

## Views
*   **Views/MainTabView.swift**: 2025-12-20T14:31:40-05:00: Tab container that adds the new Browse tab alongside the existing Dump home. Imported by `TheDumpApp.swift`. Imports SwiftUI, `Views/ContentView.swift`, `Views/BrowseView.swift`.
*   **Views/BrowseView.swift**: 2025-12-20T14:31:40-05:00: Apple Notes–style folders screen showing counts for Categories/Date Groups/Mime Types. Imported by `Views/MainTabView.swift`. Imports SwiftUI, `State/BrowseViewModel.swift`, `Views/BrowseFolderDestinationView.swift`, `Theme.swift`.
*   **Views/BrowseFolderDestinationView.swift**: 2025-12-20T14:31:40-05:00: Placeholder destination screen for folder taps (verifies navigation + count wiring). Imported by `Views/BrowseView.swift`. Imports SwiftUI, `Theme.swift`.
*   **Views/DebugNotesView.swift**: 2025-12-19: A temporary debug view to test API connectivity. Updated to use real AuthService tokens and a specific test note ID. Accessible from SettingsView.
