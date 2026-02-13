import SwiftUI

struct PaywallView: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.spacingXL) {
                        headerSection
                        featuresSection
                        pricingSection

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: Theme.fontSizeSM))
                                .foregroundColor(Theme.accent)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Theme.spacingMD)
                        }

                        actionButtons
                    }
                    .padding(.horizontal, Theme.spacingLG)
                    .padding(.vertical, Theme.spacingXL)
                }
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onChange(of: viewModel.tier) { _, newTier in
                if newTier == .paid {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(Theme.accent)

            Text("Unlock Full Access")
                .font(.system(size: Theme.fontSizeXL, weight: .bold))
                .foregroundColor(Theme.textPrimary)

            Text("Unlimited dumps, unlimited organization.")
                .font(.system(size: Theme.fontSizeMD))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Theme.spacingLG)
    }

    private var featuresSection: some View {
        VStack(spacing: Theme.spacingSM) {
            featureRow(icon: "mic.fill", text: "Unlimited voice memos")
            featureRow(icon: "camera.fill", text: "Unlimited photo captures")
            featureRow(icon: "doc.fill", text: "Unlimited file uploads")
            featureRow(icon: "brain", text: "AI-powered organization")
            featureRow(icon: "magnifyingglass", text: "Full search across all notes")
        }
        .padding(Theme.spacingMD)
        .background(Theme.darkGray)
        .cornerRadius(Theme.cornerRadius)
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: Theme.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Theme.accent)
                .frame(width: 24)

            Text(text)
                .font(.system(size: Theme.fontSizeMD))
                .foregroundColor(Theme.textPrimary)

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.green)
        }
        .padding(.vertical, Theme.spacingXS)
    }

    private var pricingSection: some View {
        VStack(spacing: Theme.spacingSM) {
            Text(viewModel.formattedPrice)
                .font(.system(size: Theme.fontSizeXXL, weight: .bold))
                .foregroundColor(Theme.textPrimary)

            Text("per month")
                .font(.system(size: Theme.fontSizeSM))
                .foregroundColor(Theme.textSecondary)

            if let usageStatus = viewModel.usageStatus {
                Text("You've used \(Int(usageStatus.usagePercentage))% of your free limit")
                    .font(.system(size: Theme.fontSizeXS))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, Theme.spacingXS)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: Theme.spacingMD) {
            Button {
                Task { await viewModel.purchase() }
            } label: {
                Group {
                    if viewModel.isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.textPrimary))
                    } else {
                        Text("Subscribe")
                    }
                }
                .font(.system(size: Theme.fontSizeMD, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.spacingMD)
                .background(Theme.accent)
                .cornerRadius(Theme.cornerRadius)
            }
            .disabled(viewModel.isPurchasing)

            Button {
                Task { await viewModel.restore() }
            } label: {
                Text("Restore Purchases")
                    .font(.system(size: Theme.fontSizeSM, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
            .disabled(viewModel.isPurchasing)
        }
    }
}
