import Foundation

struct UserService {
    
    // Base URL of your Django backend
    private let baseURL = "https://your-django-backend.com/api/users/"
    
    /// Fetch a user by their UID
    func fetchUser(withUid uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(uid)/") else {
            completion(.failure(UserServiceError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(UserServiceError.noData))
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Fetch all users (with optional pagination support)
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(UserServiceError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(UserServiceError.noData))
                return
            }
            
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Errors

enum UserServiceError: Error {
    case invalidURL
    case noData
}
