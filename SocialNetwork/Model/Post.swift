import Foundation

struct Post: Identifiable, Decodable {
    let id: UUID          // Corresponds to `public_id`
    let title: String     // Corresponds to `title` in `Post`
    let body: String      // Corresponds to `body` in `Post`
    let timestamp: Date   // Corresponds to `created` in `AbstractModel`
    let edited: Bool      // Corresponds to `edited` in `Post`
    var author: User?     // Links to the `author` of the post (Foreign Key to `CustomUser`)

    var isEdited: Bool {
        return edited
    }
}
