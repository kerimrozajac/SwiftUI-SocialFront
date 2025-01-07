import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var userSession: String? // JWT token representing the current session
    @Published var didAuthenticateUser = false
    @Published var currentUser: User?
    private var tempUserSession: String? // Temporary session token for newly registered user
    
    private let service = UserService() // User service for fetching user data
    
    // MARK: - Initializer
    init() {
        self.userSession = UserDefaults.standard.string(forKey: "userToken")
        if let token = userSession {
            self.fetchUser(withToken: token)
        }
    }
    
    // MARK: - Login
    func login(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: "https://your-django-backend-url/api/login/") else { return }

        // Create the request body
        let requestBody: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        // Convert to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Perform the network request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(false, NSError(domain: "InvalidResponse", code: -1, userInfo: nil))
                }
                return
            }
            
            do {
                // Decode the response (assuming it contains a token and user data)
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = jsonResponse["token"] as? String,
                   let userData = jsonResponse["user"] as? [String: Any] {
                    
                    // Save the token and user session (update as needed for your app)
                    DispatchQueue.main.async {
                        self?.userSession = token // Save token or other session details
                        //self?.fetchUser() // Optionally fetch user data
                        completion(true, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, NSError(domain: "InvalidData", code: -1, userInfo: nil))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }.resume()
    }

    
    // MARK: - Register
    func register(withEmail email: String, password: String, fullname: String, username: String) {
        guard let url = URL(string: "https://your-django-backend-url/api/register/") else { return }

        // Create the request body
        let requestBody: [String: Any] = [
            "email": email,
            "password": password,
            "fullname": fullname,
            "username": username
        ]
        
        // Convert to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Perform the network request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("DEBUG: Registration error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                print("DEBUG: Invalid response or status code during registration")
                return
            }
            
            do {
                // Decode the response (adjust this depending on your backend's response)
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = jsonResponse["token"] as? String {
                    
                    // Save the token and update the state
                    DispatchQueue.main.async {
                        self?.userSession = token
                        self?.didAuthenticateUser = true
                    }
                } else {
                    print("DEBUG: Invalid response data during registration")
                }
            } catch {
                print("DEBUG: Error decoding registration response: \(error.localizedDescription)")
            }
        }.resume()
    }

    
    // MARK: - Logout
    func logout() {
        guard let token = userSession else { return }
        
        guard let url = URL(string: "https://your-django-backend.com/api/logout/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            DispatchQueue.main.async {
                self?.userSession = nil
                self?.currentUser = nil
                UserDefaults.standard.removeObject(forKey: "userToken")
                print("DEBUG: Logged out successfully.")
            }
        }.resume()
    }
    
    // MARK: - Upload Profile Image
    func uploadProfileImage(_ image: UIImage) {
        guard let token = tempUserSession ?? userSession else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        guard let url = URL(string: "https://your-django-backend.com/api/upload-profile-image/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("DEBUG: Failed to upload profile image with error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let imageUrl = json["profileImageUrl"] as? String else { return }
            
            DispatchQueue.main.async {
                self?.fetchUser(withToken: token)
                print("DEBUG: Profile image uploaded successfully: \(imageUrl)")
            }
        }.resume()
    }
    
    // MARK: - Fetch User
    func fetchUser(withToken token: String) {
        guard let url = URL(string: "https://your-django-backend.com/api/user/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let data = data,
                  let user = try? JSONDecoder().decode(User.self, from: data) else { return }
            
            DispatchQueue.main.async {
                self?.currentUser = user
                print("DEBUG: Fetched user: \(user.username)")
            }
        }.resume()
    }
}
