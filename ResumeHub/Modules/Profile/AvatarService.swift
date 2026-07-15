//
//  AvatarService.swift
//  ResumeHub
//
//  Created by Никита Морозов on 15.07.2026.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

final class AvatarService {
    static let shared = AvatarService()
    
    private init() {}
    
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    // MARK: - Firebase Storage (старый способ)
    func uploadAvatar(userId: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "AvatarService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])))
            return
        }
        
        let path = "avatars/\(userId).jpg"
        let storageRef = storage.reference().child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            storageRef.downloadURL() { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let url = url else {
                    completion(.failure(NSError(domain: "AvatarService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No download URL"])))
                    return
                }
                self.db.collection(FirestoreCollections.users).document(userId).updateData(["avatarURL": url.absoluteString]) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(url.absoluteString))
                }
            }
        }
    }
    
    // MARK: - ImageBan API (новый способ)
    func uploadAvatarToImageBan(_ image: UIImage, completion: @escaping (String?) -> Void) {
        let clientId = "Nt9wqlh1JiZik4cklMHo"
        let secretKey = "PdxgFEj4lrMyKpLOL4yKQDbkM6YGJ38SfDC"
        
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Не удалось сжать изображение")
            completion(nil)
            return
        }
        
        guard let url = URL(string: "https://api.imageban.ru/v1") else {
            
            print("❌ Неверный URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("TOKEN \(clientId)", forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"avatar.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка загрузки: \(error)")
                DispatchQueue.main.async {
                    
                    completion(nil)
                }
                return
            }
            
            guard let data = data else {
                print("❌ Нет данных в ответе")
                DispatchQueue.main.async {
                    
                    completion(nil)
                }
                return
            }
            
            // ✅ Парсим JSON ответ
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        // ✅ Проверяем success как Int (1 = успех)
                    if let success = json["success"] as? Int, success == 1,
                               let dataObject = json["data"] as? [String: Any],  // ← объект, не массив!
                               let imageLink = dataObject["link"] as? String {
                                
                                print("✅ Аватарка загружена: \(imageLink)")
                        DispatchQueue.main.async {
                            
                            completion(imageLink)
                        }
                                return
                            }
                    
                    // Обработка ошибки от сервера
                    if let errorInfo = json["error"] as? [String: Any],
                               let errorCode = errorInfo["code"] as? String,
                               let errorMessage = errorInfo["message"] as? String {
                                print("❌ Ошибка API (код \(errorCode)): \(errorMessage)")
                            } else {
                                print("❌ Неизвестный ответ сервера: \(json)")
                            }
                    DispatchQueue.main.async {
                        
                        completion(nil)
                    }
                }
            } catch {
                print("❌ Ошибка парсинга ответа: \(error)")
                DispatchQueue.main.async {
                    
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
}
