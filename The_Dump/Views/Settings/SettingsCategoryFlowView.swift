import SwiftUI

struct SettingsCategoryFlowView: View {
    let existingCategories: [(name: String, count: Int)]
    let onComplete: () -> Void

    @StateObject private var viewModel = OnboardingViewModel(isSettingsMode: true)
    @State private var currentScreen: Screen = .categories
    @Environment(\.dismiss) private var dismiss

    enum Screen {
        case categories
        case definitions
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                switch currentScreen {
                case .categories:
                    OnboardingCategoriesView(
                        viewModel: viewModel,
                        onBack: { dismiss() },
                        onContinue: { currentScreen = .definitions },
                        isSettingsMode: true,
                        existingCategories: existingCategories
                    )

                case .definitions:
                    OnboardingDefinitionsView(
                        viewModel: viewModel,
                        onBack: { currentScreen = .categories },
                        onComplete: {
                            onComplete()
                        },
                        isSettingsMode: true
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            viewModel.loadExistingCategories(existingCategories.map { $0.name })
        }
    }
}

#Preview {
    SettingsCategoryFlowView(
        existingCategories: [
            (name: "Work", count: 5),
            (name: "Personal", count: 3)
        ],
        onComplete: {}
    )
}
