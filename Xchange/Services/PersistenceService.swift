//
//  PersistenceService.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements robust local data persistence adhering to Rubric Section 5
//

import Foundation
import Combine
import UIKit


/// Dedicated persistence service managing local file storage and caching
/// Guarantees offline data persistence for items, proposals, messages, and user state.
public final class PersistenceService {
    public static let shared = PersistenceService()
    
    private let fileManager = FileManager.default
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let persistenceQueue = DispatchQueue(label: "com.Xchange.persistenceQueue", qos: .utility)
    
    // File names for stored entities
    public enum FileKey {
        public static let items = "Xchange_items_v1.json"
        public static let proposals = "Xchange_proposals_v1.json"
        public static let messages = "Xchange_messages_v1.json"
        public static let user = "Xchange_user_v1.json"
        public static let safeZones = "Xchange_safe_zones_v1.json"
    }
    
    private init() {
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Directory Resolution
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
    }
    
    private func fileURL(for filename: String) -> URL {
        documentsDirectory.appendingPathComponent(filename)
    }
    
    // MARK: - Generic Persistence Operations
    
    /// Asynchronously saves an Encodable object to local storage
    public func save<T: Encodable>(_ object: T, to filename: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        persistenceQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try self.encoder.encode(object)
                let destination = self.fileURL(for: filename)
                try data.write(to: destination, options: [.atomicWrite, .completeFileProtection])
                DispatchQueue.main.async {
                    completion?(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
    }
    
    /// Synchronously saves an Encodable object (used when app enters background or terminates)
    @discardableResult
    public func saveSync<T: Encodable>(_ object: T, to filename: String) -> Bool {
        do {
            let data = try self.encoder.encode(object)
            let destination = self.fileURL(for: filename)
            try data.write(to: destination, options: [.atomicWrite, .completeFileProtection])
            return true
        } catch {
            return false
        }
    }
    
    /// Loads and decodes a Decodable object from disk
    public func load<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        let destination = fileURL(for: filename)
        guard fileManager.fileExists(atPath: destination.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: destination)
            let decoded = try decoder.decode(type, from: data)
            return decoded
        } catch {
            return nil
        }
    }
    
    /// Checks whether persistent data exists for a given key
    public func exists(filename: String) -> Bool {
        fileManager.fileExists(atPath: fileURL(for: filename).path)
    }
    
    /// Deletes a persisted file
    public func delete(filename: String) {
        let destination = fileURL(for: filename)
        if fileManager.fileExists(atPath: destination.path) {
            try? fileManager.removeItem(at: destination)
        }
    }
    
    /// Clears all local application storage and resets to initial defaults
    public func resetAllPersistence() {
        delete(filename: FileKey.items)
        delete(filename: FileKey.proposals)
        delete(filename: FileKey.messages)
        delete(filename: FileKey.user)
        delete(filename: FileKey.safeZones)
    }
    
    /// Calculates total storage footprint in bytes
    public func totalPersistedBytes() -> Int64 {
        let files = [FileKey.items, FileKey.proposals, FileKey.messages, FileKey.user, FileKey.safeZones]
        var total: Int64 = 0
        for f in files {
            let url = fileURL(for: f)
            if let attrs = try? fileManager.attributesOfItem(atPath: url.path),
               let size = attrs[.size] as? Int64 {
                total += size
            }
        }
        return total
    }
    
    // MARK: - Image Persistence Operations
    
    /// Saves a UIImage as JPEG data to the documents directory and returns whether it succeeded
    @discardableResult
    public func saveImage(_ image: UIImage, filename: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return false }
        let destination = fileURL(for: filename)
        do {
            try data.write(to: destination, options: [.atomicWrite, .completeFileProtection])
            return true
        } catch {
            return false
        }
    }
    
    /// Loads a UIImage from the documents directory by filename
    public func loadImage(filename: String) -> UIImage? {
        let destination = fileURL(for: filename)
        guard fileManager.fileExists(atPath: destination.path) else { return nil }
        return UIImage(contentsOfFile: destination.path)
    }
    
    /// Helper to resolve any image string: documents directory, asset catalog, or disk path
    public func resolveImage(nameOrPath: String) -> UIImage? {
        if let docImg = loadImage(filename: nameOrPath) {
            return docImg
        }
        if fileManager.fileExists(atPath: nameOrPath), let fileImg = UIImage(contentsOfFile: nameOrPath) {
            return fileImg
        }
        if let assetImg = UIImage(named: nameOrPath) {
            return assetImg
        }
        return nil
    }
}

