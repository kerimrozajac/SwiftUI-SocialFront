import UIKit

struct ImageUploader {
    
    static func uploadImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Convert UIImage to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(ImageUploaderError.invalidImageData))
            return
        }
        
        // Define the backend URL
        guard let url = URL(string: "https://your-django-backend.com/api/upload/") else {
            completion(.failure(ImageUploaderError.invalidURL))
            return
        }
        
        // Create a multipart/form-data request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create the body
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(UUID().uuidString).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Perform the upload request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ImageUploaderError.noData))
                return
            }
            
            do {
                // Decode the response (assuming the backend returns JSON with an `imageUrl` field)
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let imageUrl = jsonResponse["imageUrl"] as? String {
                    completion(.success(imageUrl))
                } else {
                    completion(.failure(ImageUploaderError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Errors

enum ImageUploaderError: Error {
    case invalidImageData
    case invalidURL
    case noData
    case invalidResponse
}
