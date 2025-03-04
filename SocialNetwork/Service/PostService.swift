import Foundation

struct PostService {
    
    private let baseURL = "http://localhost:8000/api/v1/" // Replace with your backend URL
    
    func uploadPost(caption: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getUserToken())", forHTTPHeaderField: "Authorization")
        
        let data: [String: Any] = [
            "caption": caption
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            print("Failed to serialize post data: \(error)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to upload post: \(error)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                print("Failed to upload post: Invalid response")
                completion(false)
                return
            }
            
            completion(true)
        }.resume()
    }

    func fetchPosts(forUserId userId: UUID, completion: @escaping ([Post]) -> Void) {
        guard let url = URL(string: "\(baseURL)/posts/\(userId)") else { return }  // Assuming userId is needed in the URL
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(getUserToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch posts: \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("No data returned")
                completion([])
                return
            }
            
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                completion(posts)
            } catch {
                print("Failed to decode posts: \(error)")
                completion([])
            }
        }.resume()
    }

    
    /*
    func fetchLikedPosts(forUserId userId: UUID, completion: @escaping ([Post]) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(userId)/liked-posts/") else {
            print("Invalid URL for fetching liked posts")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(getUserToken())", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch liked posts: \(error)")
                completion([])
                return
            }

            guard let data = data else {
                print("No data received for liked posts")
                completion([])
                return
            }

            do {
                let likedPosts = try JSONDecoder().decode([Post].self, from: data)
                completion(likedPosts)
            } catch {
                print("Failed to decode liked posts: \(error)")
                completion([])
            }
        }.resume()
    }
    */

    
    func likePost(postId: String, completion: @escaping () -> Void) {
        guard let url = URL(string: "\(baseURL)/\(postId)/like/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(getUserToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Failed to like post: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Failed to like post: Invalid response")
                return
            }
            
            completion()
        }.resume()
    }
    
    func unlikePost(postId: String, completion: @escaping () -> Void) {
        guard let url = URL(string: "\(baseURL)/\(postId)/remove_like/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(getUserToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Failed to unlike post: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Failed to unlike post: Invalid response")
                return
            }
            
            completion()
        }.resume()
    }
    
    /*
    func checkIsUserLikedPost(postId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/posts/\(postId)/is-liked/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(getUserToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to check if user liked post: \(error)")
                completion(false)
                return
            }
            
            guard let data = data else {
                completion(false)
                return
            }
            
            do {
                let response = try JSONDecoder().decode([String: Bool].self, from: data)
                completion(response["liked"] ?? false)
            } catch {
                print("Failed to decode liked status: \(error)")
                completion(false)
            }
        }.resume()
    }
     */
    
    private func getUserToken() -> String {
        // Replace with your logic to retrieve the user's JWT or session token
        return "user-token"
    }
}
