import Foundation

struct Comment: Identifiable, Decodable {
    let id: UUID          // Corresponds to `public_id`
    let body: String      // Corresponds to `body` in `Comment`
    let edited: Bool      // Corresponds to `edited` in `Comment`
    let author: User      // Links to the `author` of the comment (Foreign Key to `CustomUser`)
    let post: UUID        // Corresponds to the `post` field (Foreign Key to `Post`)
    let timestamp: Date   // Corresponds to `created` in `AbstractModel`

    var isEdited: Bool {
        return edited
    }
}
