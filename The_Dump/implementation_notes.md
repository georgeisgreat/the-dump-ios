Here is the consolidated **Implementation Guide & Constraints Document**. You can save this as `Implementation_Notes.md` or just keep it as our "contract" for the work ahead.

***

# Implementation Guidelines: API Integration & Notes Browser

## 1. Project Goal
Integrate the Flask API (`api_documenation.txt`) into the iOS app to create a "Browse" tab. The UX will mimic Apple Notes with a 3-level hierarchy:
1.  **Folders** (API: `/note_counts`)
2.  **Note List** (API: `/pull_notes`)
3.  **Note Detail** (API: `/pull_full_notes`)

## 2. Agreed Scope & Limitations (V1)
*   **Online-Only**: No local database (CoreData/SwiftData). The app requires an active internet connection to view notes.
*   **Basic Markdown**: We will use SwiftUI's native `Text(markdown:)`. It supports bold, italics, and links, but **not** images, tables, or complex code blocks.
*   **Read-Only**: This update allows viewing notes. Editing or deleting notes is out of scope for this step.

## 3. "No Landmines" Technical Rules

### A. Architecture & State
*   **Consistency**: strictly use `ObservableObject` and `@StateObject` to match the existing app. **Do not** introduce the iOS 17 `@Observable` macro to avoid state conflicts.
*   **Thread Safety**: All ViewModels must be marked with `@MainActor` to prevent background thread UI crashes.
*   **Separation**: Logic lives in ViewModels. Views only observe state and trigger actions.

### B. Networking & Resilience
*   **Error Handling**: Every network request must handle:
    *   HTTP Errors (non-200 status codes).
    *   Decoding Errors (invalid JSON).
    *   Network Timeouts.
*   **Authentication**: Never store tokens in variables. Always call `AuthService.shared.getIDToken()` immediately before a request to ensure freshness.
*   **Pagination**: Implement a strict `isLoadingMore` boolean lock to prevent "bouncing" (duplicate API calls) when scrolling.

### C. Design & Style
*   **Theme**: Use `Theme.swift` for all colors and fonts. No hardcoded colors (e.g., `.black`, `.white`) or magic numbers.
*   **Components**: Use `NavigationStack` (current standard), avoiding the deprecated `NavigationView`.

### D. Xcode & Workflow
*   **File Registration**: AI cannot interact with the Xcode UI. **User Must Verify** that newly created files appear in the Project Navigator and are checked for the "The_Dump" target.
*   **Imports**: Ensure `import SwiftUI` and `import Foundation` are present where needed.

---

## 4. Execution Plan
1.  **Data Layer**: Create `NoteModels.swift` and `NotesService.swift`.
2.  **View Models**: Create `NotesViewModel.swift` (handles fetching & state).
3.  **UI Construction**:
    *   `FoldersView` (Sidebar)
    *   `NoteListView` (Feed)
    *   `NoteDetailView` (Content)
4.  **Integration**: Add the Tab Bar logic to `ContentView` / `MainTabView`.

***

**Ready to build?** Switch to **Agent Mode** and I will begin with Step 1: The Data Layer.