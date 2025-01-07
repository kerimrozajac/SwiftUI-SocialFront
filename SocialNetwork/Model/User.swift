import Foundation

struct User: Identifiable, Decodable {
    let id: UUID          // Corresponds to `public_id`
    let username: String  // Corresponds to the username field in `CustomUser`
    let email: String     // Corresponds to the email field in `CustomUser`
    let profileImageUrl: String? // Optional field for profile images, not explicitly in your Django model but can be extended

    var avatarUrl: String {
        profileImageUrl ?? "https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50"
    }

    // Additional fields can be added here as needed
}
