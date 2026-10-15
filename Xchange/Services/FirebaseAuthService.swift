//
//  FirebaseAuthService.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Direct Firebase Authentication Integration for project: xchange-52865
//

import Foundation
import Combine

/// Response payload from Firebase Identity Toolkit REST API
public struct FirebaseAuthResponse: Codable, Sendable {
    public let idToken: String?
    public let email: String?
    public let refreshToken: String?
    public let expiresIn: String?
    public let localId: String? // Firebase UID
    public let registered: Bool?
    public var displayName: String?
}

/// Firebase Auth error payload
public struct FirebaseErrorDetail: Codable, Sendable {
    public let message: String
    public let domain: String?
    public let reason: String?
}

public struct FirebaseErrorContainer: Codable, Sendable {
    public let code: Int?
    public let message: String?
    public let errors: [FirebaseErrorDetail]?
}

public struct FirebaseErrorResponse: Codable, Sendable {
    public let error: FirebaseErrorContainer?
}

/// Detailed error mapping for user-friendly UI display
public enum FirebaseAuthError: LocalizedError, Sendable {
    case invalidApiKey
    case userNotFound
    case invalidPassword
    case emailExists
    case weakPassword
    case userDisabled
    case networkError(String)
    case serverError(String)
    case missingCredentials
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidApiKey:
            return "Firebase API Key is invalid or not yet configured. Please check your project settings."
        case .userNotFound:
            return "No registered account found with this email. Please check your spelling or sign up."
        case .invalidPassword:
            return "The password entered is incorrect. Please try again."
        case .emailExists:
            return "An account with this email address already exists. Please log in instead."
        case .weakPassword:
            return "Password is too weak. Please use at least 6 characters."
        case .userDisabled:
            return "This user account has been disabled by an administrator."
        case .networkError(let msg):
            return "Network connection issue: \(msg)"
        case .serverError(let msg):
            return "Firebase authentication error: \(msg)"
        case .missingCredentials:
            return "Please enter both email and password."
        case .unknown(let msg):
            return msg
        }
    }
}

/// Test user credential definition for evaluator convenience
public struct TestAccount: Identifiable, Sendable {
    public var id: String { email }
    public let email: String
    public let password: String
    public let displayName: String
    public let location: String
    public let avatar: String
    public let rating: Double
    public let completedTrades: Int
}

/// Live Firebase Authentication Service communicating with project: xchange-52865
@MainActor
public final class FirebaseAuthService: ObservableObject {
    public static let shared = FirebaseAuthService()
    
    // Project Metadata
    public static let projectId = "xchange-52865"
    public static let bundleId = "com.xchange.ios"
    public static let defaultApiKey = "AIzaSyAoMJTOPNtDB1qw8HOoUU0TY1fBCYxp6jI"
    public static let storageBucket = "xchange-52865.firebasestorage.app"
    public static let googleAppId = "1:964247139296:ios:faa9efcfd0b1b67b667185"
    
    // Persistent API Key storage
    private let apiKeyStorageKey = "firebase_web_api_key"
    
    @Published public var currentApiKey: String {
        didSet {
            UserDefaults.standard.set(currentApiKey, forKey: apiKeyStorageKey)
        }
    }
    
    @Published public var activeFirebaseUser: FirebaseAuthResponse?
    @Published public var isConfigured: Bool = true
    
    // Default 2 Test Users configured for the project
    public static let testUser1 = TestAccount(
        email: "testuser1@xchange.lk",
        password: "Pass1234!",
        displayName: "Kasun Perera",
        location: "Malabe, Colombo",
        avatar: "person.crop.circle.fill",
        rating: 4.9,
        completedTrades: 14
    )
    
    public static let testUser2 = TestAccount(
        email: "testuser2@xchange.lk",
        password: "Pass1234!",
        displayName: "Dilini Fernando",
        location: "Kandy City, Central Province",
        avatar: "person.crop.circle.fill.badge.checkmark",
        rating: 5.0,
        completedTrades: 21
    )
    
    public static let allTestUsers = [testUser1, testUser2]
    
    private init() {
        // Attempt to load from UserDefaults, fallback to plist or bundled config
        let storedKey = UserDefaults.standard.string(forKey: apiKeyStorageKey) ?? ""
        if !storedKey.isEmpty {
            self.currentApiKey = storedKey
            self.isConfigured = true
        } else if let plistKey = Self.loadApiKeyFromPlist(), !plistKey.isEmpty {
            self.currentApiKey = plistKey
            self.isConfigured = true
        } else {
            self.currentApiKey = Self.defaultApiKey
            self.isConfigured = true
        }
    }
    
    /// Update API Key dynamically and persist
    public func setApiKey(_ key: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        self.currentApiKey = trimmed
        self.isConfigured = !trimmed.isEmpty
        UserDefaults.standard.set(trimmed, forKey: apiKeyStorageKey)
    }
    
    // MARK: - Plist Inspector
    
    private static func loadApiKeyFromPlist() -> String? {
        guard let url = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return nil
        }
        return plist["API_KEY"] as? String
    }
    
    // MARK: - Firebase Auth Endpoints
    
    private var signInURL: URL? {
        guard !currentApiKey.isEmpty else { return nil }
        return URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(currentApiKey)")
    }
    
    private var signUpURL: URL? {
        guard !currentApiKey.isEmpty else { return nil }
        return URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=\(currentApiKey)")
    }
    
    private var updateProfileURL: URL? {
        guard !currentApiKey.isEmpty else { return nil }
        return URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:update?key=\(currentApiKey)")
    }
    
    private var passwordResetURL: URL? {
        guard !currentApiKey.isEmpty else { return nil }
        return URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=\(currentApiKey)")
    }
    
    // MARK: - Authentication Actions
    
    /// Sign in with Email and Password live against Firebase Auth
    public func signIn(email: String, password: String) async throws -> FirebaseAuthResponse {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty && !password.isEmpty else {
            throw FirebaseAuthError.missingCredentials
        }
        
        guard let url = signInURL else {
            throw FirebaseAuthError.invalidApiKey
        }
        
        let payload: [String: Any] = [
            "email": trimmedEmail,
            "password": password,
            "returnSecureToken": true
        ]
        
        let response = try await performRequest(url: url, payload: payload)
        self.activeFirebaseUser = response
        return response
    }
    
    /// Sign up with Email and Password live against Firebase Auth
    public func signUp(email: String, password: String, displayName: String? = nil) async throws -> FirebaseAuthResponse {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty && !password.isEmpty else {
            throw FirebaseAuthError.missingCredentials
        }
        
        guard let url = signUpURL else {
            throw FirebaseAuthError.invalidApiKey
        }
        
        let payload: [String: Any] = [
            "email": trimmedEmail,
            "password": password,
            "returnSecureToken": true
        ]
        
        var response = try await performRequest(url: url, payload: payload)
        
        // If displayName is supplied and we received an idToken, update profile
        if let name = displayName, !name.isEmpty, let token = response.idToken {
            try? await updateDisplayName(token: token, displayName: name)
            response.displayName = name
        }
        
        let finalResponse = response
        self.activeFirebaseUser = finalResponse
        return finalResponse
    }
    
    /// Update display name on Firebase user
    public func updateDisplayName(token: String, displayName: String) async throws {
        guard let url = updateProfileURL else { return }
        let payload: [String: Any] = [
            "idToken": token,
            "displayName": displayName,
            "returnSecureToken": true
        ]
        _ = try await performRequest(url: url, payload: payload)
    }
    
    /// Trigger password reset email from Firebase
    public func sendPasswordReset(email: String) async throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            throw FirebaseAuthError.missingCredentials
        }
        guard let url = passwordResetURL else {
            throw FirebaseAuthError.invalidApiKey
        }
        let payload: [String: Any] = [
            "requestType": "PASSWORD_RESET",
            "email": trimmedEmail
        ]
        _ = try await performRequest(url: url, payload: payload)
    }
    
    /// Ensures that both test accounts exist in Firebase Authentication so they appear in Firebase Console
    @discardableResult
    public func bootstrapTestAccounts() async -> [String: String] {
        var status: [String: String] = [:]
        guard isConfigured else {
            status["error"] = "API key not configured"
            return status
        }
        
        for user in Self.allTestUsers {
            do {
                _ = try await signUp(email: user.email, password: user.password, displayName: user.displayName)
                status[user.email] = "Created successfully in Firebase"
            } catch FirebaseAuthError.emailExists {
                status[user.email] = "Already exists in Firebase"
            } catch {
                status[user.email] = "Status: \(error.localizedDescription)"
            }
        }
        return status
    }
    
    // MARK: - Network Execution Helper
    
    private func performRequest(url: URL, payload: [String: Any]) async throws -> FirebaseAuthResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Self.bundleId, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            throw FirebaseAuthError.serverError("JSON serialization failed: \(error.localizedDescription)")
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw FirebaseAuthError.networkError(error.localizedDescription)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FirebaseAuthError.unknown("Invalid server response")
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            do {
                return try JSONDecoder().decode(FirebaseAuthResponse.self, from: data)
            } catch {
                throw FirebaseAuthError.serverError("Failed to parse Firebase Auth response: \(error.localizedDescription)")
            }
        } else {
            // Parse Firebase error code
            if let errorObj = try? JSONDecoder().decode(FirebaseErrorResponse.self, from: data),
               let msg = errorObj.error?.message {
                throw mapFirebaseErrorCode(msg)
            }
            throw FirebaseAuthError.serverError("Firebase returned HTTP \(httpResponse.statusCode)")
        }
    }
    
    private func mapFirebaseErrorCode(_ code: String) -> FirebaseAuthError {
        if code.contains("EMAIL_NOT_FOUND") {
            return .userNotFound
        } else if code.contains("INVALID_PASSWORD") || code.contains("INVALID_LOGIN_CREDENTIALS") {
            return .invalidPassword
        } else if code.contains("EMAIL_EXISTS") {
            return .emailExists
        } else if code.contains("WEAK_PASSWORD") {
            return .weakPassword
        } else if code.contains("USER_DISABLED") {
            return .userDisabled
        } else if code.contains("API_KEY_INVALID") || code.contains("INVALID_API_KEY") {
            return .invalidApiKey
        } else {
            return .serverError(code)
        }
    }
}
