//
//  StorageManager.swift
//  KiWiTales
//
//  Created by Yungi Jeong on 9/18/24.
//

//import Foundation
//import FirebaseStorage
//import UIKit
//
//final class StorageManager {
//    static let shared = StorageManager()
//    private let storage = Storage.storage()
//
//    private init() { }
//
//    func uploadImage(image: UIImage, path: String) async throws -> URL {
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//            throw NSError(domain: "ImageConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to JPEG data"])
//        }
//
//        let storageRef = storage.reference().child(path)
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//
//        return try await withCheckedThrowingContinuation { continuation in
//            storageRef.putData(imageData, metadata: metadata) { metadata, error in
//                if let error = error {
//                    continuation.resume(throwing: error)
//                } else {
//                    storageRef.downloadURL { url, error in
//                        if let error = error {
//                            continuation.resume(throwing: error)
//                        } else if let url = url {
//                            continuation.resume(returning: url)
//                        } else {
//                            continuation.resume(throwing: NSError(domain: "StorageManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error getting download URL"]))
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func downloadImage(from urlString: String) async throws -> UIImage {
//        guard let url = URL(string: urlString) else {
//            throw NSError(domain: "StorageManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
//        }
//        
//        let (data, response) = try await URLSession.shared.data(from: url)
//        
//        guard let httpResponse = response as? HTTPURLResponse,
//              (200...299).contains(httpResponse.statusCode) else {
//            throw NSError(domain: "StorageManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
//        }
//        
//        guard let image = UIImage(data: data) else {
//            throw NSError(domain: "StorageManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
//        }
//        
//        return image
//    }
//}

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage()

    private init() {}

    func uploadImage(image: UIImage, path: String) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to JPEG data"])
        }

        let storageRef = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        return try await withCheckedThrowingContinuation { continuation in
            storageRef.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let url = url {
                            continuation.resume(returning: url)
                        } else {
                            continuation.resume(throwing: NSError(domain: "StorageManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error getting download URL"]))
                        }
                    }
                }
            }
        }
    }

    func downloadImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "StorageManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "StorageManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
        }

        guard let image = UIImage(data: data) else {
            throw NSError(domain: "StorageManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }

        return image
    }
}
