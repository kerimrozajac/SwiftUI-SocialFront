import SwiftUI
import Kingfisher

struct UserRowView: View {
    let user: User
    @State private var image: Image? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            // Display image
            KFImage(URL(string: user.avatarUrl))
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 48, height: 48)

            
            // Display username
            VStack(alignment: .leading, spacing: 4) {
                Text(user.username)
                    .font(.subheadline).bold()
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct UserRowView_Previews: PreviewProvider {
    static var previews: some View {
        UserRowView(user: User(id: UUID(),
                               username: "kerim",
                               email: "kerimr@email.com",
                               profileImageUrl: ""))
    }
}

