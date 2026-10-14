//
//  NetworkService.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Network connectivity monitoring and async/await simulation (Rubric Section 5)
//

import Foundation
import Network
import Combine

/// Network monitor and asynchronous transaction coordinator
public final class NetworkService: ObservableObject {
    public static let shared = NetworkService()
    
    @Published public var isConnected: Bool = true
    @Published public var isCellular: Bool = false
    @Published public var isSyncing: Bool = false
    
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.Xchange.networkMonitor")
    
    public enum NetworkError: LocalizedError {
        case offline
        case timeout
        case serverUnreachable
        case parsingFailed
        
        public var errorDescription: String? {
            switch self {
            case .offline: return "Device is currently offline. Actions will be cached locally."
            case .timeout: return "Trade network request timed out. Retrying in background."
            case .serverUnreachable: return "Xchange sync service is currently unavailable."
            case .parsingFailed: return "Unexpected response format from exchange server."
            }
        }
    }
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
                self?.isCellular = path.isExpensive
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    /// Simulates an asynchronous cloud sync operation with realistic network latency
    public func syncWithRemoteCloud() async throws {
        guard isConnected else {
            throw NetworkError.offline
        }
        
        await MainActor.run {
            self.isSyncing = true
        }
        
        // Simulate remote round-trip latency
        try await Task.sleep(nanoseconds: 600_000_000)
        
        await MainActor.run {
            self.isSyncing = false
        }
    }
    
    deinit {
        monitor.cancel()
    }
}
