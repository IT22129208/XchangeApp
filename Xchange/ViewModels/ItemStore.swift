//
//  ItemStore.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Item Catalog Store with Robust Disk Persistence & Debounced Search
//

import Foundation
import SwiftUI
import Combine

@MainActor
public class ItemStore: ObservableObject {
    @Published public var items: [Item] = []
    @Published public var selectedCategory: ItemCategory = .all
    @Published public var searchQuery: String = ""
    @Published public var selectedConditionFilter: ItemCondition? = nil
    @Published public var maxPriceFilter: Double = 500000
    @Published public var sortBy: ItemSortOption = .newest
    @Published public var selectedDistrictFilter: SriLankaDistrict = .all
    
    private let persistence = PersistenceService.shared
    private var cancellables = Set<AnyCancellable>()
    
    public enum ItemSortOption: String, CaseIterable, Identifiable {
        case newest = "Newest Listed"
        case valueHighToLow = "Value: High to Low"
        case valueLowToHigh = "Value: Low to High"
        
        public var id: String { rawValue }
    }
    
    public init() {
        loadItems()
        fetchRemoteItems()
    }
    
    // MARK: - Persistence & Cloud Sync
    
    public func fetchRemoteItems() {
        Task { @MainActor in
            let remote = await FirebaseDatabaseService.shared.fetchItems()
            if !remote.isEmpty {
                for remoteItem in remote {
                    if let index = self.items.firstIndex(where: { $0.id == remoteItem.id }) {
                        self.items[index] = remoteItem
                    } else {
                        self.items.insert(remoteItem, at: 0)
                    }
                }
                self.saveItems()
            }
        }
    }
    
    private func saveItems() {
        persistence.save(items, to: PersistenceService.FileKey.items)
    }
    
    private func loadItems() {
        if var stored: [Item] = persistence.load([Item].self, from: PersistenceService.FileKey.items),
           !stored.isEmpty,
           stored.contains(where: { $0.ownerLocation.contains("Sri Lanka") && $0.estimatedValue >= 1000 }) {
            var updated = false
            for i in 0..<stored.count {
                if stored[i].district == nil || stored[i].district?.isEmpty == true {
                    stored[i].district = SriLankaDistrict.detectDistrict(from: stored[i].ownerLocation) ?? "Colombo"
                    updated = true
                }
                if stored[i].ownerName.lowercased().contains("kasun") {
                    if stored[i].ownerId != UserStore.testUser1Id || stored[i].ownerEmail.isEmpty {
                        stored[i].ownerId = UserStore.testUser1Id
                        stored[i].ownerEmail = "testuser1@xchange.lk"
                        updated = true
                    }
                } else if stored[i].ownerName.lowercased().contains("dilini") {
                    if stored[i].ownerId != UserStore.testUser2Id || stored[i].ownerEmail.isEmpty {
                        stored[i].ownerId = UserStore.testUser2Id
                        stored[i].ownerEmail = "testuser2@xchange.lk"
                        updated = true
                    }
                }
            }
            
            let hasKasun = stored.contains(where: { $0.ownerName.lowercased().contains("kasun") })
            let hasDilini = stored.contains(where: { $0.ownerName.lowercased().contains("dilini") })
            if !hasKasun || !hasDilini {
                seedSampleData()
                saveItems()
                return
            }
            
            if updated {
                persistence.save(stored, to: PersistenceService.FileKey.items)
            }
            self.items = stored
        } else {
            seedSampleData()
            saveItems()
        }
    }
    
    // Filtered items available on the explore marketplace
    public var marketplaceItems: [Item] {
        items.filter { item in
            // Filter by Category
            let matchesCategory = (selectedCategory == .all || item.category == selectedCategory)
            
            // Filter by Search Query
            let matchesSearch = searchQuery.isEmpty ||
                item.title.localizedCaseInsensitiveContains(searchQuery) ||
                item.description.localizedCaseInsensitiveContains(searchQuery) ||
                item.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchQuery) }) ||
                item.preferredTrades.localizedCaseInsensitiveContains(searchQuery)
            
            // Filter by Condition
            let matchesCondition = (selectedConditionFilter == nil || item.condition == selectedConditionFilter)
            
            // Filter by Max Value
            let matchesValue = item.estimatedValue <= maxPriceFilter
            
            // Filter by District
            let matchesDistrict = (selectedDistrictFilter == .all || item.matchesDistrict(selectedDistrictFilter))
            
            // Only available or in negotiation
            let matchesStatus = item.status != .traded
            
            return matchesCategory && matchesSearch && matchesCondition && matchesValue && matchesStatus && matchesDistrict
        }.sorted { a, b in
            switch sortBy {
            case .newest:
                return a.createdAt > b.createdAt
            case .valueHighToLow:
                return a.estimatedValue > b.estimatedValue
            case .valueLowToHigh:
                return a.estimatedValue < b.estimatedValue
            }
        }
    }
    
    // Items owned by the active user
    public func userItems(for user: User) -> [Item] {
        return items.filter { $0.isOwnedBy(user: user) }
    }
    
    public func userItems(for userId: UUID) -> [Item] {
        return items.filter { $0.ownerId == userId }
    }
    
    // Current user's available items that can be offered in a trade
    public func availableItemsToOffer(for user: User) -> [Item] {
        return items.filter { $0.isOwnedBy(user: user) && $0.status == .available }
    }
    
    public func availableItemsToOffer(for userId: UUID) -> [Item] {
        return items.filter { $0.ownerId == userId && $0.status == .available }
    }
    
    public func toggleFavorite(for itemId: UUID) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            items[index].isFavorite.toggle()
            saveItems()
            AppTheme.triggerHaptic(style: .light)
        }
    }
    
    public func addItem(_ item: Item) {
        items.insert(item, at: 0)
        saveItems()
        AppTheme.triggerNotificationHaptic(type: .success)
    }
    
    public func updateItem(_ item: Item, image: UIImage? = nil) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveItems()
            Task {
                await FirebaseDatabaseService.shared.publishItem(item, image: image)
            }
        }
    }
    
    /// Updates owner details (name, avatar, phone, location, district) across all items owned by the user and syncs with Firebase
    public func updateOwnerProfileForItems(user: User) {
        var didUpdate = false
        for i in 0..<items.count {
            if items[i].isOwnedBy(user: user) || items[i].ownerId == user.id {
                items[i].ownerName = user.displayName
                items[i].ownerAvatar = user.avatar
                items[i].ownerPhone = user.phoneNumber
                items[i].district = user.district
                items[i].ownerLocation = user.location
                didUpdate = true
                
                let updatedItem = items[i]
                Task {
                    await FirebaseDatabaseService.shared.publishItem(updatedItem)
                }
            }
        }
        if didUpdate {
            saveItems()
        }
    }
    
    public func deleteItem(byId id: UUID) {
        items.removeAll { $0.id == id }
        saveItems()
        Task {
            await FirebaseDatabaseService.shared.deleteItem(id: id)
        }
    }
    
    public func setItemStatus(id: UUID, status: ItemStatus) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].status = status
            saveItems()
        }
    }
    
    public func getItem(byId id: UUID) -> Item? {
        items.first(where: { $0.id == id })
    }
    
    public func resetToDefaults() {
        seedSampleData()
        saveItems()
    }
    
    // MARK: - Sample Seed Data
    private func seedSampleData() {
        let currentUserId = UserStore.currentUserId
        let testUser1Id = UserStore.testUser1Id
        let testUser2Id = UserStore.testUser2Id
        let alexId = UserStore.alexUserId
        let sophiaId = UserStore.sophiaUserId
        let marcusId = UserStore.marcusUserId
        let elenaId = UserStore.elenaUserId
        
        let sampleItems: [Item] = [
            // Test User 1 (Kasun Perera) active listing
            Item(
                id: UUID(uuidString: "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d")!,
                title: "Sony WH-1000XM5 Wireless Headphones",
                description: "Mint condition with original carrying case, auxiliary cable and USB-C cord. Premium active noise cancellation, used for 2 months.",
                category: .electronics,
                condition: .likeNew,
                estimatedValue: 85000,
                preferredTrades: "Looking for iPad Mini 6 or Fujifilm X-mount prime lens.",
                images: ["headphones"],
                ownerId: testUser1Id,
                ownerName: "Kasun Perera",
                ownerEmail: "testuser1@xchange.lk",
                ownerAvatar: "person.crop.circle.fill",
                ownerRating: 4.9,
                ownerLocation: "Malabe, Colombo, Sri Lanka",
                status: .available,
                tags: ["Electronics", "Audio", "Sony", "ANC"],
                createdAt: Calendar.current.date(byAdding: .minute, value: -1, to: Date()) ?? Date()
            ),
            
            // Test User 2 (Dilini Fernando) active listing
            Item(
                id: UUID(uuidString: "b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e")!,
                title: "Vintage Olympus OM-1 35mm SLR Camera",
                description: "Clean mechanical body with Zuiko 50mm f/1.8 lens. Working light meter, new light seals installed. Perfect for analog film photography enthusiasts.",
                category: .collectibles,
                condition: .gentlyUsed,
                estimatedValue: 55000,
                preferredTrades: "Mirrorless body or Sony E-mount optics.",
                images: ["camera.viewfinder"],
                ownerId: testUser2Id,
                ownerName: "Dilini Fernando",
                ownerEmail: "testuser2@xchange.lk",
                ownerAvatar: "person.crop.circle.fill.badge.checkmark",
                ownerRating: 5.0,
                ownerLocation: "Kandy City, Sri Lanka",
                status: .available,
                tags: ["Collectibles", "Photography", "Vintage", "Olympus"],
                createdAt: Calendar.current.date(byAdding: .minute, value: -2, to: Date()) ?? Date()
            ),
            
            // 1. Road Bike (matches screenshot Row 1 Left)
            Item(
                title: "Road Bike",
                description: "Vintage restored light-blue road bicycle with lightweight steel frame, polished drop bars, and leather saddle. Smooth gearing and tuned brakes.",
                category: .vehicles,
                condition: .gentlyUsed,
                estimatedValue: 75000,
                preferredTrades: "Looking for camera lenses, synthesizers, or high-end mechanical keyboards.",
                images: ["item_road_bike"],
                ownerId: alexId,
                ownerName: "Alex Rivera",
                ownerEmail: "alex@xchange.lk",
                ownerAvatar: "bicycle.circle.fill",
                ownerRating: 4.95,
                ownerLocation: "Colombo 03, Sri Lanka",
                status: .available,
                tags: ["Bike", "RoadBike", "Vintage", "Vehicles"],
                createdAt: Calendar.current.date(byAdding: .minute, value: -3, to: Date()) ?? Date()
            ),
            
            // 2. Smartphone (matches screenshot Row 1 Right)
            Item(
                title: "Smartphone",
                description: "Flagship 5G smartphone with OLED edge-to-edge display, dual cameras, 256GB storage, and all-day battery life. Flawless condition with screen protector.",
                category: .electronics,
                condition: .likeNew,
                estimatedValue: 145000,
                preferredTrades: "Trade for MacBook Air M1/M2, Sony mirrorless camera, or iPad Air.",
                images: ["item_smartphone"],
                ownerId: sophiaId,
                ownerName: "Sophia Chen",
                ownerAvatar: "phone.circle.fill",
                ownerRating: 4.92,
                ownerLocation: "Kandy, Sri Lanka",
                status: .available,
                tags: ["Smartphone", "Phone", "Electronics", "5G"],
                createdAt: Calendar.current.date(byAdding: .minute, value: -2, to: Date()) ?? Date()
            ),
            
            // 3. Vinyl Collection (matches screenshot Row 2 Left)
            Item(
                title: "Vinyl Collection",
                description: "Curated collection of classic 33 RPM LP vinyl records including vintage soul, jazz, and rock pressings in mint and excellent condition.",
                category: .booksMedia,
                condition: .vintageSalvage,
                estimatedValue: 35000,
                preferredTrades: "Looking for vintage turntable cartridge, audio monitors, or guitar pedals.",
                images: ["item_vinyl_collection"],
                ownerId: elenaId,
                ownerName: "Elena Rostova",
                ownerAvatar: "music.note.tv.fill",
                ownerRating: 4.94,
                ownerLocation: "Galle Fort, Sri Lanka",
                status: .available,
                tags: ["Vinyl", "Records", "Music", "Collectibles"],
                createdAt: Calendar.current.date(byAdding: .minute, value: -3, to: Date()) ?? Date()
            ),
            
            // 4. Acoustic Guitar (matches screenshot Row 2 Right)
            Item(
                title: "Acoustic Guitar",
                description: "Handcrafted dreadnought acoustic guitar with solid spruce top, mahogany back and sides. Warm balanced tone with low action and padded gig bag.",
                category: .musicalInstruments,
                condition: .likeNew,
                estimatedValue: 68000,
                preferredTrades: "Trade for electric guitar, tube amp, audio interface, or condenser microphone.",
                images: ["item_acoustic_guitar"],
                ownerId: marcusId,
                ownerName: "Marcus Vance",
                ownerAvatar: "guitars.circle.fill",
                ownerRating: 4.88,
                ownerLocation: "Negombo, Sri Lanka",
                status: .available,
                tags: ["Guitar", "Acoustic", "Music", "Instruments"],
                createdAt: Calendar.current.date(byAdding: .minute, value: -4, to: Date()) ?? Date()
            ),
            
            // 5. Polaroid Camera (matches screenshot Row 3 Left)
            Item(
                title: "Polaroid Camera",
                description: "Original vintage Polaroid instant film camera. Fully serviced rollers, clean viewfinder, and sharp instant prints. Includes genuine strap.",
                category: .cameras,
                condition: .vintageSalvage,
                estimatedValue: 28000,
                preferredTrades: "Looking for 35mm film rolls, vintage analog lenses, or retro games.",
                images: ["item_polaroid_camera"],
                ownerId: sophiaId,
                ownerName: "Sophia Chen",
                ownerAvatar: "camera.circle.fill",
                ownerRating: 4.92,
                ownerLocation: "Malabe, Sri Lanka",
                status: .available,
                tags: ["Polaroid", "Camera", "Vintage", "Photography"],
                createdAt: Calendar.current.date(byAdding: .minute, value: -5, to: Date()) ?? Date()
            ),
            
            // 6. Antique Map (matches screenshot Row 3 Right)
            Item(
                title: "Antique Map",
                description: "19th century antique world parchment map with brass desktop globe. Detailed illustrations and gilded cartography in excellent archival state.",
                category: .collectibles,
                condition: .vintageSalvage,
                estimatedValue: 42000,
                preferredTrades: "Trade for rare first edition books, vintage compass, or brass telescopes.",
                images: ["item_antique_map"],
                ownerId: marcusId,
                ownerName: "Marcus Vance",
                ownerAvatar: "book.circle.fill",
                ownerRating: 4.88,
                ownerLocation: "Colombo 07, Sri Lanka",
                status: .available,
                tags: ["Antique", "Map", "Globe", "Collectibles", "Vintage"],
                createdAt: Calendar.current.date(byAdding: .minute, value: -6, to: Date()) ?? Date()
            ),
            
            // 7. Services listing for the Services filter chip
            Item(
                title: "Studio Photography",
                description: "Professional 2-hour portrait or product photography session with 15 retouched high-res deliverables and studio lighting.",
                category: .services,
                condition: .brandNew,
                estimatedValue: 35000,
                preferredTrades: "Looking for graphic design branding, video editing, or audio mixing.",
                images: ["camera.fill"],
                ownerId: sophiaId,
                ownerName: "Sophia Chen",
                ownerAvatar: "camera.circle.fill",
                ownerRating: 4.98,
                ownerLocation: "Colombo 04, Sri Lanka",
                status: .available,
                tags: ["Services", "Photography", "Studio", "Creative"],
                createdAt: Calendar.current.date(byAdding: .minute, value: -7, to: Date()) ?? Date()
            ),
            
            // Seed Listings
            Item(
                title: "MacBook Pro",
                description: "Apple MacBook Pro 14-inch (M3 Pro chip, 18GB unified memory, 512GB SSD). Space Black, battery health 100%. Includes 70W MagSafe charger and original packaging.",
                category: .electronics,
                condition: .likeNew,
                estimatedValue: 320000,
                preferredTrades: "Looking for Sony FX3 / A7S III or Leica Q2, or Gibson Les Paul Standard.",
                images: ["laptopcomputer"],
                ownerId: currentUserId,
                ownerName: "Sashik Silva",
                ownerEmail: "sashik@xchange.lk",
                ownerAvatar: "person.crop.circle.fill",
                ownerRating: 4.95,
                ownerLocation: "Malabe, Colombo, Sri Lanka",
                status: .available,
                tags: ["Apple", "MacBook", "M3", "Laptop", "Creative"],
                createdAt: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
            ),
            Item(
                title: "Graphic Tablet",
                description: "Wacom Intuos Pro Medium Graphic Tablet with Pro Pen 2. Barely used, pristine drawing surface with 8192 levels of pressure sensitivity. USB-C and Bluetooth.",
                category: .electronics,
                condition: .likeNew,
                estimatedValue: 55000,
                preferredTrades: "Trade for iPad 10th Gen or AirPods Max or mechanical keyboard.",
                images: ["ipad.and.iphone"],
                ownerId: currentUserId,
                ownerName: "Sashik Silva",
                ownerEmail: "sashik@xchange.lk",
                ownerAvatar: "person.crop.circle.fill",
                ownerRating: 4.95,
                ownerLocation: "Malabe, Colombo, Sri Lanka",
                status: .available,
                tags: ["Wacom", "Drawing", "Design", "DigitalArt"],
                createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            ),
            
            // Community Listings matching design
            Item(
                title: "Vintage Bike",
                description: "Restored French 10-speed Vintage Road Bicycle with classic steel lugged frame, Brooks England B17 honey leather saddle, polished drop bars, and gumwall tires.",
                category: .vehicles,
                condition: .gentlyUsed,
                estimatedValue: 75000,
                preferredTrades: "Looking for mirrorless camera body, synth gear, or DJ controllers.",
                images: ["bicycle"],
                ownerId: alexId,
                ownerName: "Alex Rivera",
                ownerAvatar: "bicycle.circle.fill",
                ownerRating: 4.94,
                ownerLocation: "Kurunegala, Sri Lanka",
                status: .available,
                tags: ["Bicycle", "Vintage", "SteelFrame", "Commuter"],
                createdAt: Calendar.current.date(byAdding: .hour, value: -4, to: Date()) ?? Date()
            ),
            Item(
                title: "DSLR Camera",
                description: "Canon EOS 90D DSLR Camera with EF-S 18-135mm f/3.5-5.6 IS USM Lens. 32.5 MP APS-C sensor, 4K video, dual batteries, 128GB SanDisk Extreme card.",
                category: .cameras,
                condition: .likeNew,
                estimatedValue: 165000,
                preferredTrades: "Looking for Sony A7 III or Fujifilm X100V.",
                images: ["camera.fill"],
                ownerId: sophiaId,
                ownerName: "Sophia Chen",
                ownerAvatar: "camera.circle.fill",
                ownerRating: 4.92,
                ownerLocation: "Matara, Sri Lanka",
                status: .available,
                tags: ["Canon", "DSLR", "Photography", "Camera", "Lens"],
                createdAt: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date()
            ),
            Item(
                title: "Rare Book",
                description: "1894 Antique Illustrated Edition of Jules Verne's 'Twenty Thousand Leagues Under the Sea'. Gilded leather-bound spine, marbled endpapers, pristine woodcut plates.",
                category: .collectibles,
                condition: .vintageSalvage,
                estimatedValue: 45000,
                preferredTrades: "Looking for vintage watches (Seiko mechanical / Omega) or first edition literature.",
                images: ["books.vertical.fill"],
                ownerId: marcusId,
                ownerName: "Marcus Vance",
                ownerAvatar: "book.circle.fill",
                ownerRating: 4.88,
                ownerLocation: "Gampaha, Sri Lanka",
                status: .available,
                tags: ["Antique", "RareBook", "Collectibles", "FirstEdition", "JulesVerne"],
                createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
            ),
            Item(
                title: "Fujifilm X-T30 II Mirrorless Camera (Silver)",
                description: "Includes XC 15-45mm lens, 2 original Fuji batteries, dual bay charger, Peak Design strap lugs, and original box. Sensor is pristine.",
                category: .cameras,
                condition: .likeNew,
                estimatedValue: 185000,
                preferredTrades: "Will trade for DJI Mini 4 Pro Fly More, or Sony FE 24-70mm f/2.8 GM lens, or M2 Mac Mini.",
                images: ["camera_fuji"],
                ownerId: alexId,
                ownerName: "Alex Rivera",
                ownerAvatar: "camera.circle.fill",
                ownerRating: 4.88,
                ownerLocation: "Colombo 05, Sri Lanka",
                status: .available,
                tags: ["Fujifilm", "Camera", "Mirrorless", "Photography"],
                createdAt: Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date()
            ),
            Item(
                title: "Analogue Pocket Handheld Console (Black)",
                description: "FPGA handheld that plays original Game Boy, GBC, and GBA cartridges. Comes with hard plastic cover, dock, and 128GB MicroSD.",
                category: .gaming,
                condition: .brandNew,
                estimatedValue: 62000,
                preferredTrades: "Trade for teenage engineering OP-Z synthesizer or Fender electric guitar neck/body.",
                images: ["console_pocket"],
                ownerId: sophiaId,
                ownerName: "Sophia Chen",
                ownerAvatar: "gamecontroller.circle.fill",
                ownerRating: 5.0,
                ownerLocation: "Dehiwala, Sri Lanka",
                status: .available,
                tags: ["Retro", "Analogue", "GameBoy", "Gaming", "FPGA"],
                createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            ),
            Item(
                title: "Teenage Engineering OP-1 Field Synthesizer",
                description: "Portable synthesizer, sampler and 4-track tape recorder. Aluminum chassis, stereo signal chain, Bluetooth MIDI. Mint with case.",
                category: .musicalInstruments,
                condition: .likeNew,
                estimatedValue: 290000,
                preferredTrades: "Looking for Roland SP-404MKII + Cash or Sequential Prophet 6 / Elektron Syntakt bundle.",
                images: ["synth_op1"],
                ownerId: elenaId,
                ownerName: "Elena Rostova",
                ownerAvatar: "music.note.tv.fill",
                ownerRating: 4.92,
                ownerLocation: "Rajagiriya, Sri Lanka",
                status: .available,
                tags: ["Synthesizer", "TeenageEngineering", "Music", "Sampler", "Studio"],
                createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
            ),
            Item(
                title: "Roland SP-404MKII Creative Sampler & Effector",
                description: "The ultimate beatmaker sampler. Updated to latest 4.0 firmware with preloaded vinyl drum kits. Includes power supply and 64GB high speed SD card.",
                category: .musicalInstruments,
                condition: .gentlyUsed,
                estimatedValue: 95000,
                preferredTrades: "Looking for MPC One+ or Gibson Epiphone Les Paul or Sony RX100 VII.",
                images: ["sampler_sp404"],
                ownerId: marcusId,
                ownerName: "Marcus Vance",
                ownerAvatar: "figure.hiking.circle.fill",
                ownerRating: 4.79,
                ownerLocation: "Battaramulla, Sri Lanka",
                status: .available,
                tags: ["Roland", "Sampler", "Beatmaker", "LoFi", "HipHop"],
                createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
            ),
            Item(
                title: "Vintage 1978 Pioneer PL-518 Direct Drive Turntable",
                description: "Restored vintage Japanese turntable with walnut veneer finish. Fitted with brand new Audio-Technica VM95E cartridge. Sounds warm and deep.",
                category: .booksMedia,
                condition: .vintageSalvage,
                estimatedValue: 58000,
                preferredTrades: "Looking for vintage analog tube amplifiers, Bose 901 speakers, or rare jazz LP collections.",
                images: ["turntable_pioneer"],
                ownerId: elenaId,
                ownerName: "Elena Rostova",
                ownerAvatar: "music.note.tv.fill",
                ownerRating: 4.92,
                ownerLocation: "Mount Lavinia, Sri Lanka",
                status: .available,
                tags: ["Vintage", "Vinyl", "Audiophile", "Turntable", "Pioneer"],
                createdAt: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date()
            ),
            Item(
                title: "Dyson V12 Detect Slim Cordless Vacuum (Fluffy Optic)",
                description: "Laser illuminates invisible dust. Includes digital motorbar head, hair screw tool, combination tool, wall mount dock and two filters.",
                category: .homeGarden,
                condition: .gentlyUsed,
                estimatedValue: 88000,
                preferredTrades: "Looking for espresso machine (Breville Barista Touch/Pro) or Dyson Airwrap.",
                images: ["vacuum_dyson"],
                ownerId: alexId,
                ownerName: "Alex Rivera",
                ownerAvatar: "camera.circle.fill",
                ownerRating: 4.88,
                ownerLocation: "Nugegoda, Sri Lanka",
                status: .available,
                tags: ["Dyson", "Home", "Appliances", "Clean"],
                createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
            ),
            Item(
                title: "Patagonia Black Hole MLC 45L Travel Backpack",
                description: "Iconic carry-on compliant duffel/backpack. Smolder Blue colorway. High-durability 100% recycled ripstop fabric with TPU laminate.",
                category: .fashion,
                condition: .brandNew,
                estimatedValue: 38000,
                preferredTrades: "Trade for Arc'teryx Atom LT Hoody (Men's M) or camping gear.",
                images: ["backpack_patagonia"],
                ownerId: marcusId,
                ownerName: "Marcus Vance",
                ownerAvatar: "figure.hiking.circle.fill",
                ownerRating: 4.79,
                ownerLocation: "Maharagama, Sri Lanka",
                status: .available,
                tags: ["Patagonia", "Backpack", "Travel", "Outdoor"],
                createdAt: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            )
        ]
        
        self.items = sampleItems
    }
}
