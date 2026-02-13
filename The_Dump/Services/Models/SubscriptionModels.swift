import Foundation

enum SubscriptionTier: String, Codable {
    case free
    case trial
    case paid
    case preApproved = "pre_approved"
}

struct UsageStatusResponse: Codable {
    let subscriptionTier: SubscriptionTier
    let tokensUsed: Int
    let monthlyTokenLimit: Int
    let tokensRemaining: Int
    let usagePercentage: Double
    let isBlocked: Bool
    let trialEndsAt: String?
    let resetsAt: String

    enum CodingKeys: String, CodingKey {
        case subscriptionTier = "subscription_tier"
        case tokensUsed = "tokens_used"
        case monthlyTokenLimit = "monthly_token_limit"
        case tokensRemaining = "tokens_remaining"
        case usagePercentage = "usage_percentage"
        case isBlocked = "is_blocked"
        case trialEndsAt = "trial_ends_at"
        case resetsAt = "resets_at"
    }
}

struct VerifyPurchaseResponse: Codable {
    let success: Bool
    let subscriptionTier: SubscriptionTier

    enum CodingKeys: String, CodingKey {
        case success
        case subscriptionTier = "subscription_tier"
    }
}
