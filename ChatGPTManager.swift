import Foundation

class ChatGPTManager {
    static let shared = ChatGPTManager()
    private let apiKey = "sk-proj-SmFpSSKPuOdYOs0gpZ2sT3BlbkFJak674U1veJAmxJPaV6HL"
    
    private init() {}
    
    func processCommand(_ command: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/engines/text-davinci-003/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "prompt": command,
            "max_tokens": 150
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let text = firstChoice["text"] as? String {
                    
                    let processedResponse = self.processResponse(text)
                    completion(.success(processedResponse))
                } else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func processResponse(_ response: String) -> [String: Any] {
        let lowercaseResponse = response.lowercased()
        var action = "unknown"
        var contact: [String: Any] = [:]
        
        if lowercaseResponse.contains("add") {
            action = "add"
            contact = [
                "name": "New Contact",
                "position": "Developer",
                "organization": "New Org",
                "phone": "123-456-7890",
                "email": "newcontact@example.com",
                "socialMedia": "@new_contact",
                "description": "A new developer."
            ]
        } else if lowercaseResponse.contains("update") {
            action = "update"
            contact = [
                "id": "existing_contact_id",
                "name": "Updated Contact",
                "position": "Senior Developer",
                "organization": "Updated Org",
                "phone": "987-654-3210",
                "email": "updatedcontact@example.com",
                "socialMedia": "@updated_contact",
                "description": "An updated developer."
            ]
        } else if lowercaseResponse.contains("delete") {
            action = "delete"
            contact = [
                "id": "existing_contact_id"
            ]
        }
        
        return ["action": action, "contact": contact]
    }
}
