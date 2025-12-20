# File Guide

## Models
*   **Models/NoteModels.swift**: 2025-12-19: Defines Swift Codable structs (NoteCountsResponse, NoteListResponse, NoteDetailResponse) to map JSON responses from the Flask API for the Notes feature. Imported by NotesService.

## Services
*   **Services/NotesService.swift**: 2025-12-19: Handles network requests to the Flask API, managing authentication via AuthService and mapping responses to NoteModels. Imports NoteModels and APIError.

## Views
*   **Views/DebugNotesView.swift**: 2025-12-19: A temporary debug view to test API connectivity. Updated to use real AuthService tokens and a specific test note ID. Accessible from SettingsView.
