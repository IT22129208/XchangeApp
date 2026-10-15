//
//  FirebaseDatabaseService.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Live Firebase Realtime Database Synchronization for project: xchange-52865
//

import Foundation
import UIKit
import Combine

/// Realtime Database Service synchronizing Users and Barter Items with Firebase
@MainActor
public final class FirebaseDatabaseService: ObservableObject {
    public static let shared = FirebaseDatabaseService()
    
    public static let projectId = "xchange-52865"
    public static let databaseBaseUrl = "https://xchange-52865-default-rtdb.firebaseio.com"
    
    @Published public var isSyncing: Bool = false
    @Published public var lastSyncError: String? = nil
    @Published public var remoteItemsCount: Int = 0
    
    private init() {}
    
    // MARK: - User Profile Synchronization
    
    /// Resolves the appropriate Firebase Realtime Database key for a user
    public func resolveUserId(for user: User, overrideId: String? = nil) -> String {
        if let override = overrideId, !override.isEmpty {
            return override
        }
        if let activeUid = FirebaseAuthService.shared.activeFirebaseUser?.localId, !activeUid.isEmpty {
            return activeUid
        }
        if user.email.lowercased() == FirebaseAuthService.testUser1.email.lowercased() {
            return "7FHWqF6yFrYcaxhcbW7h0dNuwR32"
        }
        if user.email.lowercased() == FirebaseAuthService.testUser2.email.lowercased() {
            return "wYuobctTnKPRIHv6ojg8gbjjzkX2"
        }
        return user.id.uuidString
    }
    
    /// Saves or updates a User profile in Firebase Realtime Database (/users/{userId}.json)
    public func saveUserProfile(_ user: User, avatarImage: UIImage? = nil, userIdOverride: String? = nil, authProvider: String? = nil) async {
        isSyncing = true
        lastSyncError = nil
        
        let targetId = resolveUserId(for: user, overrideId: userIdOverride)
        
        var provider = authProvider ?? "password"
        if user.avatar == "apple.logo" || user.email.contains("appleid") || user.email.contains("icloud.com") {
            provider = "apple"
        } else if user.email.contains("gmail.com") {
            provider = "google"
        }
        
        var payload: [String: Any] = [
            "id": targetId,
            "displayName": user.displayName,
            "username": user.username,
            "email": user.email,
            "location": user.location,
            "bio": user.bio,
            "rating": user.rating,
            "tradesCompleted": user.tradesCompleted,
            "memberSince": user.memberSince,
            "isVerified": user.isVerified,
            "phoneNumber": user.phoneNumber,
            "avatar": user.avatar,
            "authProvider": provider,
            "updatedAt": ISO8601DateFormatter().string(from: Date())
        ]
        
        if let image = avatarImage, let jpegData = image.jpegData(compressionQuality: 0.6) {
            payload["avatarBase64"] = jpegData.base64EncodedString()
        }
        
        let urlString = "\(Self.databaseBaseUrl)/users/\(targetId).json"
        guard let url = URL(string: urlString) else {
            isSyncing = false
            return
        }
        
        do {
            _ = try await performRequest(url: url, httpMethod: "PUT", payload: payload)
            print("Successfully updated user profile in Firebase Realtime Database: \(user.displayName) (ID: \(targetId))")
        } catch {
            print("Firebase Realtime Database user sync note: \(error.localizedDescription)")
            lastSyncError = error.localizedDescription
        }
        
        isSyncing = false
    }
    
    /// Fetches a user profile from Firebase Realtime Database (/users/{userId}.json)
    public func fetchUserProfile(userId: String) async -> [String: Any]? {
        let urlString = "\(Self.databaseBaseUrl)/users/\(userId).json"
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return nil
            }
            return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        } catch {
            return nil
        }
    }
    
    // MARK: - Barter Items Synchronization
    
    /// Publishes a newly added item to Firebase Realtime Database (/items/{itemId}.json)
    public func publishItem(_ item: Item, image: UIImage? = nil) async {
        isSyncing = true
        lastSyncError = nil
        
        var payload: [String: Any] = [
            "id": item.id.uuidString,
            "title": item.title,
            "description": item.description,
            "category": item.category.rawValue,
            "condition": item.condition.rawValue,
            "estimatedValue": item.estimatedValue,
            "preferredTrades": item.preferredTrades,
            "ownerId": item.ownerId.uuidString,
            "ownerName": item.ownerName,
            "ownerEmail": item.ownerEmail,
            "ownerPhone": item.ownerPhone,
            "ownerAvatar": item.ownerAvatar,
            "ownerRating": item.ownerRating,
            "ownerLocation": item.ownerLocation,
            "status": item.status.rawValue,
            "images": item.images,
            "tags": item.tags,
            "createdAt": ISO8601DateFormatter().string(from: item.createdAt)
        ]
        
        // Encode photo to Base64 so all devices and users receive the real image
        if let img = image, let jpeg = img.jpegData(compressionQuality: 0.6) {
            payload["imageBase64"] = jpeg.base64EncodedString()
        } else if let firstImgName = item.images.first,
                  let localImg = PersistenceService.shared.resolveImage(nameOrPath: firstImgName),
                  let jpeg = localImg.jpegData(compressionQuality: 0.6) {
            payload["imageBase64"] = jpeg.base64EncodedString()
        }
        
        let urlString = "\(Self.databaseBaseUrl)/items/\(item.id.uuidString).json"
        guard let url = URL(string: urlString) else {
            isSyncing = false
            return
        }
        
        do {
            _ = try await performRequest(url: url, httpMethod: "PUT", payload: payload)
            print("Successfully published item to Firebase Realtime Database: \(item.title)")
        } catch {
            print("Firebase Realtime Database item publish error: \(error.localizedDescription)")
            lastSyncError = error.localizedDescription
        }
        
        isSyncing = false
    }
    
    /// Fetches all barter items published across all users from Firebase Realtime Database
    public func fetchItems() async -> [Item] {
        isSyncing = true
        let urlString = "\(Self.databaseBaseUrl)/items.json"
        guard let url = URL(string: urlString) else {
            isSyncing = false
            return []
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                isSyncing = false
                return []
            }
            
            // Realtime Database returns [String: [String: Any]] or null
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] {
                var parsedItems: [Item] = []
                for (_, itemDict) in json {
                    if let item = parseItem(from: itemDict) {
                        parsedItems.append(item)
                    }
                }
                
                // Sort by creation date descending
                parsedItems.sort { $0.createdAt > $1.createdAt }
                self.remoteItemsCount = parsedItems.count
                self.isSyncing = false
                return parsedItems
            }
        } catch {
            print("Firebase fetch items error: \(error.localizedDescription)")
            lastSyncError = error.localizedDescription
        }
        
        isSyncing = false
        return []
    }
    
    // MARK: - Barter Trade Proposals Synchronization
    
    /// Publishes or updates a Trade Proposal in Firebase Realtime Database (/proposals/{proposalId}.json)
    public func publishProposal(_ proposal: TradeProposal) async {
        let urlString = "\(Self.databaseBaseUrl)/proposals/\(proposal.id.uuidString).json"
        guard let url = URL(string: urlString) else { return }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(proposal)
            if let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                _ = try await performRequest(url: url, httpMethod: "PUT", payload: payload)
                print("Successfully published proposal to Firebase: \(proposal.initiatorName) -> \(proposal.receiverName) (ID: \(proposal.id.uuidString))")
            }
        } catch {
            print("Firebase proposal publish error: \(error.localizedDescription)")
            lastSyncError = error.localizedDescription
        }
    }
    
    /// Updates the status of an existing proposal in Firebase Realtime Database
    public func updateProposalStatus(id: UUID, status: TradeStatus) async {
        let urlString = "\(Self.databaseBaseUrl)/proposals/\(id.uuidString).json"
        guard let url = URL(string: urlString) else { return }
        
        let payload: [String: Any] = [
            "status": status.rawValue,
            "updatedAt": ISO8601DateFormatter().string(from: Date())
        ]
        
        do {
            _ = try await performRequest(url: url, httpMethod: "PATCH", payload: payload)
            print("Successfully updated proposal status in Firebase: \(id.uuidString) -> \(status.rawValue)")
        } catch {
            print("Firebase proposal status update error: \(error.localizedDescription)")
        }
    }
    
    /// Fetches all barter trade proposals from Firebase Realtime Database (/proposals.json)
    public func fetchProposals() async -> [TradeProposal] {
        let urlString = "\(Self.databaseBaseUrl)/proposals.json"
        guard let url = URL(string: urlString) else { return [] }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return []
            }
            
            guard let rootDict = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
                return []
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { d in
                let container = try d.singleValueContainer()
                let str = try container.decode(String.self)
                let formatter = ISO8601DateFormatter()
                if let date = formatter.date(from: str) {
                    return date
                }
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: str) {
                    return date
                }
                if let sec = Double(str) {
                    return Date(timeIntervalSince1970: sec)
                }
                return Date()
            }
            
            var proposals: [TradeProposal] = []
            for (_, proposalDict) in rootDict {
                if let itemData = try? JSONSerialization.data(withJSONObject: proposalDict, options: []),
                   let proposal = try? decoder.decode(TradeProposal.self, from: itemData) {
                    proposals.append(proposal)
                }
            }
            
            proposals.sort { $0.updatedAt > $1.updatedAt }
            return proposals
        } catch {
            print("Firebase fetch proposals error: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Parsing Helper
    
    private func parseItem(from dict: [String: Any]) -> Item? {
        guard let title = dict["title"] as? String else { return nil }
        
        let idString = dict["id"] as? String ?? UUID().uuidString
        let itemId = UUID(uuidString: idString) ?? UUID()
        
        let desc = dict["description"] as? String ?? ""
        let catRaw = dict["category"] as? String ?? ItemCategory.electronics.rawValue
        let category = ItemCategory(rawValue: catRaw) ?? .electronics
        
        let condRaw = dict["condition"] as? String ?? ItemCondition.gentlyUsed.rawValue
        let condition = ItemCondition(rawValue: condRaw) ?? .gentlyUsed
        
        let estimatedValue = dict["estimatedValue"] as? Double ?? 25000.0
        let preferredTrades = dict["preferredTrades"] as? String ?? "Open to trades"
        
        let ownerName = dict["ownerName"] as? String ?? "Trader"
        let ownerEmail = dict["ownerEmail"] as? String ?? {
            if ownerName.lowercased().contains("kasun") { return "testuser1@xchange.lk" }
            if ownerName.lowercased().contains("dilini") { return "testuser2@xchange.lk" }
            return ""
        }()
        
        let ownerPhone = dict["ownerPhone"] as? String ?? {
            if ownerEmail == "testuser1@xchange.lk" || ownerName.lowercased().contains("kasun") { return "+94 77 123 4567" }
            if ownerEmail == "testuser2@xchange.lk" || ownerName.lowercased().contains("dilini") { return "+94 71 987 6543" }
            if ownerName.lowercased().contains("sashik") { return "+94 76 555 1234" }
            return ""
        }()
        
        let ownerIdString = dict["ownerId"] as? String ?? UUID().uuidString
        let ownerId: UUID = {
            if ownerEmail == "testuser1@xchange.lk" || ownerIdString == "7FHWqF6yFrYcaxhcbW7h0dNuwR32" {
                return UserStore.testUser1Id
            }
            if ownerEmail == "testuser2@xchange.lk" || ownerIdString == "wYuobctTnKPRIHv6ojg8gbjjzkX2" {
                return UserStore.testUser2Id
            }
            if let parsed = UUID(uuidString: ownerIdString) {
                return parsed
            }
            return User.deterministicId(for: ownerIdString)
        }()
        
        let ownerAvatar = dict["ownerAvatar"] as? String ?? "person.crop.circle.fill"
        let ownerRating = dict["ownerRating"] as? Double ?? 4.9
        let ownerLocation = dict["ownerLocation"] as? String ?? "Colombo, Sri Lanka"
        
        let statusRaw = dict["status"] as? String ?? ItemStatus.available.rawValue
        let status = ItemStatus(rawValue: statusRaw) ?? .available
        
        var images = dict["images"] as? [String] ?? []
        
        // Decode base64 image if present and save to disk
        if let base64String = dict["imageBase64"] as? String,
           let imageData = Data(base64Encoded: base64String),
           let uiImage = UIImage(data: imageData) {
            let savedFilename = "remote_item_\(itemId.uuidString).jpg"
            if PersistenceService.shared.saveImage(uiImage, filename: savedFilename) {
                if !images.contains(savedFilename) {
                    images.insert(savedFilename, at: 0)
                }
            }
        }
        
        if images.isEmpty {
            images = [category.systemIcon]
        }
        
        let tags = dict["tags"] as? [String] ?? [category.rawValue]
        
        var createdAt = Date()
        if let ts = dict["createdAt"] as? String {
            createdAt = ISO8601DateFormatter().date(from: ts) ?? Date()
        }
        
        return Item(
            id: itemId,
            title: title,
            description: desc,
            category: category,
            condition: condition,
            estimatedValue: estimatedValue,
            preferredTrades: preferredTrades,
            images: images,
            ownerId: ownerId,
            ownerName: ownerName,
            ownerEmail: ownerEmail,
            ownerPhone: ownerPhone,
            ownerAvatar: ownerAvatar,
            ownerRating: ownerRating,
            ownerLocation: ownerLocation,
            status: status,
            tags: tags,
            createdAt: createdAt
        )
    }
    
    // MARK: - Network Request Helper
    
    private func performRequest(url: URL, httpMethod: String, payload: [String: Any]) async throws -> [String: Any] {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorText = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
            throw NSError(domain: "FirebaseDatabaseError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorText])
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json ?? [:]
    }
}
