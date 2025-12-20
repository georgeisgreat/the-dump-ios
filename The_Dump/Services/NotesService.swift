import Foundation

class NotesService {
    static let shared = NotesService()
    
    // ⚠️ Update this URL to match your deployment or local dev environment
    private let baseURL = "https://thedump.ai" 
    
    private init() {}
    
    // Helper to create an authorized request with the Firebase ID Token
    private func createRequest(endpoint: String, method: String = "GET") async throws -> URLRequest {
        // 1. Get the fresh Firebase token from existing AuthService
        let token = try await AuthService.shared.getIDToken()
        
        // 2. Construct the URL
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        // 3. Build the request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    // Fetch the sidebar counts
    func fetchCounts() async throws -> NoteCountsResponse {
        let request = try await createRequest(endpoint: "/api/note_counts")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(underlying: URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: "Failed to fetch counts")
            }
            
            return try JSONDecoder().decode(NoteCountsResponse.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingFailed(underlying: error)
        } catch {
            throw APIError.networkError(underlying: error)
        }
    }
    
    // Fetch the list of notes (with pagination & filtering)
    func fetchNotes(limit: Int = 30, cursorTime: String? = nil, category: String? = nil) async throws -> NoteListResponse {
        // Build query parameters
        var components = URLComponents(string: "\(baseURL)/api/pull_notes")!
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        
        if let cursorTime = cursorTime {
            queryItems.append(URLQueryItem(name: "cursor_time", value: cursorTime))
        }
        if let category = category {
            queryItems.append(URLQueryItem(name: "category_name", value: category))
        }
        components.queryItems = queryItems
        
        // Create request manually since we used URLComponents
        let token = try await AuthService.shared.getIDToken()
        guard let url = components.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(underlying: URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: "Failed to fetch notes")
            }
            
            return try JSONDecoder().decode(NoteListResponse.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingFailed(underlying: error)
        } catch {
            throw APIError.networkError(underlying: error)
        }
    }
    
    // Fetch full content for specific notes
    func fetchFullNote(ids: [String]) async throws -> [NoteDetail] {
        var request = try await createRequest(endpoint: "/api/pull_full_notes", method: "POST")
        
        let body = ["note_ids": ids]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(underlying: URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: "Failed to fetch note details")
            }
            
            let responseObj = try JSONDecoder().decode(NoteDetailResponse.self, from: data)
            return responseObj.notes
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingFailed(underlying: error)
        } catch {
            throw APIError.networkError(underlying: error)
        }
    }
}

