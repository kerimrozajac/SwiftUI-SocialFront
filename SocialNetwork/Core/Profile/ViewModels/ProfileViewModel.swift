import Foundation

class ProfileViewModel: ObservableObject {
    @Published var posts = [Post]()
    @Published var likedPosts = [Post]()
    private let service = PostService()
    private let userService = UserService()
    
    let user: User
    private let loggedInUserId: String? // Logged-in user's ID
    
    init(user: User, loggedInUserId: String?) {
        self.user = user
        self.loggedInUserId = loggedInUserId
        self.fetchUserPosts()
        //self.fetchLikedPosts()
    }
    
    var actionButtonTitle: String {
        return isCurrentUser ? "Edit Profile" : "Follow"
    }
    
    var isCurrentUser: Bool {
        guard let loggedInUserId = loggedInUserId, let loggedInUserUUID = UUID(uuidString: loggedInUserId) else {
            return false
        }
        return user.id == loggedInUserUUID
    }

    func posts(forFilter filter: PostFilterViewModel) -> [Post] {
        switch filter {
        case .posts:
            return posts  // Fixed: Changed from `post` to `posts`
        case .replies:
            return [] // Placeholder: Define how replies are fetched if needed
        case .likes:
            return likedPosts
        }
    }

    func fetchUserPosts() {
        // Assuming user.id is a non-optional UUID, you can directly use it
        let userId = user.id
        
        service.fetchPosts(forUserId: userId) { fetchedPosts in
            DispatchQueue.main.async {
                self.posts = fetchedPosts.map { post in
                    var mutablePost = post
                    mutablePost.author = self.user // Assigning `author`
                    return mutablePost
                }
            }
        }
    }


    /*
    func fetchLikedPosts() {
        service.fetchLikedPosts(forUserId: user.id) { fetchedLikedPosts in
            DispatchQueue.main.async {
                self.likedPosts = fetchedLikedPosts
                for index in 0..<fetchedLikedPosts.count {
                    if let postAuthor = fetchedLikedPosts[index].author {
                        self.likedPosts[index].author = postAuthor
                    } else {
                        let postId = fetchedLikedPosts[index].id
                        self.userService.fetchUser(withId: postId.uuidString) { fetchedUser in
                            DispatchQueue.main.async {
                                self.likedPosts[index].author = fetchedUser
                            }
                        }
                    }
                }
            }
        }
    }
    */
}
