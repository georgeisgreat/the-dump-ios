import SwiftUI

struct DebugNotesView: View {
    @State private var log: String = "Ready to test...\nUsing AuthService Token."
    @State private var isBusy = false
    @State private var categoryName: String = "Test Category"

    var body: some View {
        VStack(spacing: 20) {
            Text("API Connectivity Test")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Button("1. Get Counts") {
                    runTest {
                        return try await rawFetchCounts()
                    }
                }
                .buttonStyle(DebugButtonStyle())

                Button("2. Get List") {
                    runTest {
                        return try await rawFetchList()
                    }
                }
                .buttonStyle(DebugButtonStyle())
            }

            Button("3. Get Details (Real ID)") {
                runTest {
                    return try await rawFetchDetails()
                }
            }
            .buttonStyle(DebugButtonStyle())

            Divider()
                .background(Color.white.opacity(0.3))

            Text("Categories API Test")
                .font(.headline)
                .foregroundColor(.white)

            TextField("Category name", text: $categoryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("4. Update Category") {
                runTest {
                    return try await rawUpdateCategory()
                }
            }
            .buttonStyle(DebugButtonStyle())
            .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            ScrollView {
                Text(log)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color.black.opacity(0.5))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
    
    func runTest(action: @escaping () async throws -> String) {
        guard !isBusy else { return }
        isBusy = true
        log = "⏳ Requesting..."
        
        Task {
            do {
                let successMessage = try await action()
                await MainActor.run {
                    log = successMessage
                    isBusy = false
                }
            } catch {
                await MainActor.run {
                    log = "❌ Error: \(error.localizedDescription)\n\nDetails: \(error)"
                    isBusy = false
                }
            }
        }
    }
    
    // MARK: - Raw Requests using AuthService Token
    
    // Need to match the URL in NotesService
    private let baseURL = "https://thedump.ai" // ⚠️ User must update this manually if needed
    
    private func getFreshToken() async throws -> String {
        return try await AuthService.shared.getIDToken()
    }
    
    private func rawFetchCounts() async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/note_counts") else { return "Invalid URL" }
        let token = try await getFreshToken()
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response)
    }
    
    private func rawFetchList() async throws -> String {
        // NOTE: Documentation says /pull_notes, but other endpoints are /api/... 
        // If this fails with 404, try adding /api prefix
        guard let url = URL(string: "\(baseURL)/api/pull_notes?limit=5") else { return "Invalid URL" }
        let token = try await getFreshToken()
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response)
    }
    
    private func rawFetchDetails() async throws -> String {
         guard let url = URL(string: "\(baseURL)/api/pull_full_notes") else { return "Invalid URL" }
         let token = try await getFreshToken()

         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         // Updated with the specific ID provided by user
         request.httpBody = try JSONSerialization.data(withJSONObject: ["note_ids": ["0182ddfc-1279-4d74-977b-c04b577600ae"]])

         let (data, response) = try await URLSession.shared.data(for: request)
         return try handleResponse(data: data, response: response)
    }

    private func rawUpdateCategory() async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/categories/update") else { return "Invalid URL" }
        let token = try await getFreshToken()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        let body: [String: Any] = [
            "categories": [
                [
                    "name": trimmedName,
                    "definition": "Debug test category",
                    "keywords": ["debug", "test"],
                    "source": "user"
                ]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleCategoryResponse(data: data, response: response)
    }

    private func handleCategoryResponse(data: Data, response: URLResponse) throws -> String {
        guard let http = response as? HTTPURLResponse else { return "No Response" }

        let body = String(data: data, encoding: .utf8) ?? "(no body)"

        if http.statusCode == 200 {
            // Try to parse and display nicely
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = json["status"] as? String,
               let count = json["updated_count"] as? Int,
               let categories = json["categories"] as? [[String: Any]] {
                var result = "✅ Status 200\n"
                result += "Status: \(status)\n"
                result += "Updated count: \(count)\n\n"
                result += "Saved categories:\n"
                for cat in categories {
                    let id = cat["category_id"] ?? "?"
                    let name = cat["name"] ?? "?"
                    let dateAdded = cat["date_added"] ?? "?"
                    result += "  • \(name) (id=\(id))\n"
                    result += "    Added: \(dateAdded)\n"
                }
                return result
            }
            return "✅ Status 200:\n\(body)"
        } else {
            return "❌ HTTP Error \(http.statusCode):\n\(body)"
        }
    }

    private func handleResponse(data: Data, response: URLResponse) throws -> String {
        guard let http = response as? HTTPURLResponse else { return "No Response" }
        
        let body = String(data: data, encoding: .utf8) ?? "(no body)"
        
        if http.statusCode == 200 {
            return "✅ Status 200:\n\(body)"
        } else {
            return "❌ HTTP Error \(http.statusCode):\n\(body)"
        }
    }
}

struct DebugButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
