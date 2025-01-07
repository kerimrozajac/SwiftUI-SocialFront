import SwiftUI

struct UserStatsView: View {
    @State private var followingCount: Int = 0
    @State private var followersCount: Int = 0
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        HStack(spacing: 24) {
            HStack(spacing: 4) {
                Text("\(followingCount)")
                    .font(.subheadline).bold()
                Text("Following")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            HStack {
                Text("\(followersCount)")
                    .font(.subheadline).bold()
                Text("Followers")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            fetchUserStats()
        }
    }

    private func fetchUserStats() {
        $viewModel.getUserStats { following, followers in
            self.followingCount = following
            self.followersCount = followers
        }
    }
}

struct UserStatsView_Previews: PreviewProvider {
    static var previews: some View {
        UserStatsView()
    }
}
