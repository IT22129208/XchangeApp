//
//  XchangeUnitTests.swift
//  XchangeTests
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Comprehensive Unit Testing Suite (Rubric Section 8)
//

import XCTest
import CoreLocation
@testable import Xchange

@MainActor
final class XchangeUnitTests: XCTestCase {
    var itemStore: ItemStore!
    var tradeStore: TradeProposalStore!
    var userStore: UserStore!
    var chatStore: ChatStore!
    var safeZoneStore: SafeZoneStore!
    
    override func setUp() async throws {
        try await super.setUp()
        // Initialize fresh stores for isolated testing
        itemStore = ItemStore()
        tradeStore = TradeProposalStore()
        userStore = UserStore()
        chatStore = ChatStore()
        safeZoneStore = SafeZoneStore()
    }
    
    override func tearDown() async throws {
        itemStore = nil
        tradeStore = nil
        userStore = nil
        chatStore = nil
        safeZoneStore = nil
        try await super.tearDown()
    }
    
    // MARK: - 1. ItemStore Catalog & Filtering Tests
    
    func testItemStoreInitialSeedDataNotEmpty() {
        XCTAssertFalse(itemStore.items.isEmpty, "ItemStore should contain initial seed items")
        XCTAssertGreaterThanOrEqual(itemStore.items.count, 5, "Seed catalog must contain at least 5 marketplace items")
    }
    
    func testAddItemIncreasesCountAndPersists() {
        let initialCount = itemStore.items.count
        let newItem = Item(
            title: "Test Shure SM7B Dynamic Mic",
            description: "Studio vocal microphone in box",
            category: .musicalInstruments,
            condition: .likeNew,
            estimatedValue: 399.0,
            preferredTrades: "Looking for audio interface",
            images: ["guitars.fill"],
            ownerId: userStore.currentUser.id,
            ownerName: userStore.currentUser.displayName,
            ownerLocation: "Malabe, Sri Lanka"
        )
        
        itemStore.addItem(newItem)
        XCTAssertEqual(itemStore.items.count, initialCount + 1, "Adding item should increment items count by 1")
        XCTAssertEqual(itemStore.items.first?.title, "Test Shure SM7B Dynamic Mic", "New item should be inserted at index 0")
        
        // Clean up
        itemStore.deleteItem(byId: newItem.id)
        XCTAssertEqual(itemStore.items.count, initialCount, "Deleting item should restore count")
    }
    
    func testCategoryFilterReturnsOnlyMatchingCategory() {
        itemStore.selectedCategory = .gaming
        let gamingItems = itemStore.marketplaceItems
        for item in gamingItems {
            XCTAssertEqual(item.category, .gaming, "Filtered items must match selected .gaming category")
        }
    }
    
    func testSearchQueryFiltersByTitleAndTags() {
        itemStore.searchQuery = "Sony"
        let matchingItems = itemStore.marketplaceItems
        XCTAssertFalse(matchingItems.isEmpty, "Searching for 'Sony' should return matching items")
        for item in matchingItems {
            let matches = item.title.localizedCaseInsensitiveContains("Sony") ||
                          item.description.localizedCaseInsensitiveContains("Sony") ||
                          item.tags.contains(where: { $0.localizedCaseInsensitiveContains("Sony") })
            XCTAssertTrue(matches, "Item must match search query in title, description, or tags")
        }
    }
    
    func testToggleFavoriteUpdatesState() {
        guard let firstItem = itemStore.items.first else {
            XCTFail("Items list is empty")
            return
        }
        let originalStatus = firstItem.isFavorite
        itemStore.toggleFavorite(for: firstItem.id)
        let updated = itemStore.getItem(byId: firstItem.id)
        XCTAssertNotEqual(updated?.isFavorite, originalStatus, "Toggle favorite should flip the boolean state")
    }
    
    // MARK: - 2. Trade Proposal Lifecycle & Counter-Offer Engine Tests
    
    func testCreateTradeProposalLifecycle() {
        let dummyOffered = [itemStore.items[0]]
        let dummyRequested = [itemStore.items[1]]
        
        let proposal = tradeStore.createProposal(
            initiator: userStore.currentUser,
            receiverId: UserStore.alexUserId,
            receiverName: "Alex Rivera",
            receiverAvatar: "camera.circle.fill",
            receiverRating: 4.88,
            offeredItems: dummyOffered,
            requestedItems: dummyRequested,
            note: "Let's trade gear!",
            meetingLocation: "SLIIT Computing Hub Safe Trade Booth"
        )
        
        XCTAssertEqual(proposal.status, .pending, "Newly created proposal must be in .pending state")
        XCTAssertEqual(proposal.initiatorId, userStore.currentUser.id)
        XCTAssertEqual(proposal.meetingLocation, "SLIIT Computing Hub Safe Trade Booth")
        
        // Accept proposal
        tradeStore.acceptProposal(proposalId: proposal.id)
        let accepted = tradeStore.getProposal(byId: proposal.id)
        XCTAssertEqual(accepted?.status, .accepted, "Proposal status should transition to .accepted")
        
        // Complete trade
        tradeStore.completeTrade(proposalId: proposal.id)
        let completed = tradeStore.getProposal(byId: proposal.id)
        XCTAssertEqual(completed?.status, .completed, "Proposal status should transition to .completed")
    }
    
    func testCounterOfferAppendsToAuditHistory() {
        let dummyOffered = [itemStore.items[0]]
        let dummyRequested = [itemStore.items[1]]
        
        let proposal = tradeStore.createProposal(
            initiator: userStore.currentUser,
            receiverId: UserStore.alexUserId,
            receiverName: "Alex Rivera",
            receiverAvatar: "camera.circle.fill",
            receiverRating: 4.88,
            offeredItems: dummyOffered,
            requestedItems: dummyRequested,
            note: "Initial proposal"
        )
        
        XCTAssertTrue(proposal.counterHistory.isEmpty)
        
        let counterOffered = [itemStore.items[0], itemStore.items[2]]
        tradeStore.submitCounterOffer(
            proposalId: proposal.id,
            proposingUserId: UserStore.alexUserId,
            proposingUserName: "Alex Rivera",
            newOffered: counterOffered,
            newRequested: dummyRequested,
            counterNote: "Counter offer: please include item 2 as well."
        )
        
        let counteredProposal = tradeStore.getProposal(byId: proposal.id)
        XCTAssertEqual(counteredProposal?.status, .countered, "Proposal status must be .countered")
        XCTAssertEqual(counteredProposal?.counterHistory.count, 1, "Counter history must record Round 1")
        XCTAssertEqual(counteredProposal?.counterHistory.first?.note, "Counter offer: please include item 2 as well.")
    }
    
    // MARK: - 3. Valuation Parity Calculations
    
    func testTradeValuationParityMathematics() {
        let itemA = Item(title: "A", description: "", category: .electronics, condition: .likeNew, estimatedValue: 300, preferredTrades: "", images: [], ownerId: UUID(), ownerName: "")
        let itemB = Item(title: "B", description: "", category: .cameras, condition: .likeNew, estimatedValue: 300, preferredTrades: "", images: [], ownerId: UUID(), ownerName: "")
        
        let pEqual = TradeProposal(initiatorId: UUID(), initiatorName: "UserA", receiverId: UUID(), receiverName: "UserB", offeredItems: [itemA], requestedItems: [itemB], note: "")
        XCTAssertEqual(pEqual.totalOfferedValue, 300)
        XCTAssertEqual(pEqual.totalRequestedValue, 300)
        XCTAssertEqual(pEqual.valueDifference, 0.0, "Equal value trade should have zero difference")
        XCTAssertTrue(pEqual.isFairTrade, "Equal value trade should qualify as fair")
        
        let itemOver = Item(title: "C", description: "", category: .electronics, condition: .brandNew, estimatedValue: 600, preferredTrades: "", images: [], ownerId: UUID(), ownerName: "")
        let pUnbalanced = TradeProposal(initiatorId: UUID(), initiatorName: "UserA", receiverId: UUID(), receiverName: "UserB", offeredItems: [itemOver], requestedItems: [itemB], note: "")
        XCTAssertEqual(pUnbalanced.valueDifference, 300.0)
        XCTAssertFalse(pUnbalanced.isFairTrade, "Trade with 100% disparity should not qualify as fair without balance")
    }
    
    // MARK: - 4. Machine Learning & Vision Valuation Service Tests
    
    func testSmartAppraisalMLServiceReturnsPlausibleValuation() {
        let mlService = SmartAppraisalMLService.shared
        let result = mlService.quickAppraise(
            title: "Apple M2 MacBook Air",
            category: .electronics,
            condition: .likeNew
        )
        
        XCTAssertEqual(result.predictedCategory, .electronics)
        XCTAssertEqual(result.predictedCondition, .likeNew)
        XCTAssertGreaterThan(result.estimatedFairValue, 100, "Estimated fair value must be positive")
        XCTAssertLessThanOrEqual(result.valueRangeMin, result.estimatedFairValue)
        XCTAssertGreaterThanOrEqual(result.valueRangeMax, result.estimatedFairValue)
        XCTAssertGreaterThan(result.categoryConfidence, 0.8, "Confidence score should exceed 80%")
    }
    
    // MARK: - 5. MapKit Safe Exchange Zone Distance & Filtering Tests
    
    func testSafeZoneProximityCalculation() {
        guard let sliitZone = safeZoneStore.safeZones.first(where: { $0.isCampusPartner }) else {
            XCTFail("SLIIT Safe zone fixture missing")
            return
        }
        
        let userCoord = CLLocationCoordinate2D(latitude: 6.9147, longitude: 79.9729)
        let distanceMeters = sliitZone.distance(from: userCoord)
        XCTAssertLessThan(distanceMeters, 50.0, "Zero distance test should be under 50 meters")
    }
    
    func testSafeZoneFilters() {
        safeZoneStore.filterCampusOnly = true
        let campusZones = safeZoneStore.filteredZones
        for z in campusZones {
            XCTAssertTrue(z.isCampusPartner, "All filtered zones must be campus partners")
        }
        safeZoneStore.filterCampusOnly = false
        
        safeZoneStore.filterPoliceVerifiedOnly = true
        let policeZones = safeZoneStore.filteredZones
        for z in policeZones {
            XCTAssertTrue(z.isVerifiedByPolice, "All filtered zones must be verified by police")
        }
        safeZoneStore.filterPoliceVerifiedOnly = false
    }
    
    // MARK: - 6. Persistence Service Integrity
    
    func testPersistenceServiceSaveAndLoad() {
        let testFilename = "test_persistence_unit_test.json"
        let testItems = [
            Item(title: "Persisted Drone", description: "DJI Mini 3", category: .cameras, condition: .brandNew, estimatedValue: 450, preferredTrades: "None", images: [], ownerId: UUID(), ownerName: "Test")
        ]
        
        let saved = PersistenceService.shared.saveSync(testItems, to: testFilename)
        XCTAssertTrue(saved, "PersistenceService saveSync must return true")
        
        let loaded = PersistenceService.shared.load([Item].self, from: testFilename)
        XCTAssertNotNil(loaded, "Loaded items should not be nil")
        XCTAssertEqual(loaded?.first?.title, "Persisted Drone")
        
        // Clean up
        PersistenceService.shared.delete(filename: testFilename)
        XCTAssertFalse(PersistenceService.shared.exists(filename: testFilename), "File should be deleted")
    }
}
