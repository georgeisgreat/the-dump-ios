import SwiftUI

struct SubscriptionSettingsSection: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @State private var showPaywall = false

    var body: some View {
        Section {
            // Current tier
            HStack {
                Text("Plan")
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                tierBadge
            }
            .listRowBackground(Theme.darkGray)

            // Token usage
            if let status = viewModel.usageStatus {
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    HStack {
                        Text("Usage")
                            .foregroundColor(Theme.textSecondary)
                        Spacer()
                        Text("\(status.tokensUsed.formatted()) / \(status.monthlyTokenLimit.formatted())")
                            .font(.system(size: Theme.fontSizeXS))
                            .foregroundColor(Theme.textSecondary)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.mediumGray)
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(usageBarColor)
                                .frame(width: geo.size.width * min(status.usagePercentage / 100, 1.0), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .listRowBackground(Theme.darkGray)

                // Reset date
                if let resetDate = viewModel.formattedResetDate {
                    HStack {
                        Text("Resets")
                            .foregroundColor(Theme.textSecondary)
                        Spacer()
                        Text(resetDate)
                            .foregroundColor(Theme.textPrimary)
                    }
                    .listRowBackground(Theme.darkGray)
                }

                // Trial end date
                if let trialEnd = viewModel.formattedTrialEnd {
                    HStack {
                        Text("Trial ends")
                            .foregroundColor(Theme.textSecondary)
                        Spacer()
                        Text(trialEnd)
                            .foregroundColor(Theme.accent)
                    }
                    .listRowBackground(Theme.darkGray)
                }
            }

            // Upgrade button (free/trial only)
            if viewModel.canUpgrade {
                Button("Upgrade to Pro") {
                    showPaywall = true
                }
                .foregroundColor(Theme.accent)
                .listRowBackground(Theme.darkGray)
            }

            // Manage subscription (paid only)
            if viewModel.tier == .paid {
                Button("Manage Subscription") {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }
                .foregroundColor(Theme.accent)
                .listRowBackground(Theme.darkGray)
            }
        } header: {
            Text("Subscription")
                .foregroundColor(Theme.textSecondary)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(viewModel: viewModel)
        }
    }

    private var tierBadge: some View {
        Text(tierLabel)
            .font(.system(size: Theme.fontSizeXS, weight: .semibold))
            .foregroundColor(tierColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tierColor.opacity(0.15))
            .cornerRadius(6)
    }

    private var tierLabel: String {
        switch viewModel.tier {
        case .free: return "Free"
        case .trial: return "Trial"
        case .paid: return "Pro"
        case .preApproved: return "Pro"
        }
    }

    private var tierColor: Color {
        switch viewModel.tier {
        case .free: return Theme.textSecondary
        case .trial: return .orange
        case .paid, .preApproved: return .green
        }
    }

    private var usageBarColor: Color {
        guard let percentage = viewModel.usageStatus?.usagePercentage else { return .green }
        if percentage >= 90 { return Theme.accent }
        if percentage >= 70 { return .orange }
        return .green
    }
}
