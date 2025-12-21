import SwiftUI

struct BrowseFolderDestinationView: View {
    enum Kind {
        case category
        case dateGroup
        case mimeType
        
        var titlePrefix: String {
            switch self {
            case .category: return "Category"
            case .dateGroup: return "Date Group"
            case .mimeType: return "Mime Type"
            }
        }
    }
    
    let kind: Kind
    let name: String
    let count: Int
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: Theme.spacingMD) {
                Text("\(kind.titlePrefix): \(name)")
                    .font(.system(size: Theme.fontSizeLG, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                
                Text("Notes: \(count)")
                    .font(.system(size: Theme.fontSizeSM))
                    .foregroundColor(Theme.textSecondary)
                
                Text("Next step: wire this screen to `/api/pull_notes` using the selected filter.")
                    .font(.system(size: Theme.fontSizeSM))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, Theme.spacingSM)
                
                Spacer()
            }
            .padding(Theme.spacingLG)
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        BrowseFolderDestinationView(kind: .category, name: "Work", count: 12)
    }
}



