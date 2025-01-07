import Foundation

struct Device: Identifiable, Decodable {
    let id: UUID          // Corresponds to `public_id`
    let name: String      // Corresponds to `name` in `Device`
    let uid: String       // Corresponds to `uid` in `Device`
    let ipAddress: String // Corresponds to `ip_address` in `Device`
    let isOnline: Bool    // Corresponds to `is_online` in `Device`

    var status: String {
        return isOnline ? "Online" : "Offline"
    }
}
