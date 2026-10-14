# ⚙️ XChange (Xchange) – Technical Documentation
**SLIIT Faculty of Computing – BSc (Hons) in Information Technology**  
*SE4041: Mobile Application Design and Development (MADD) – Assignment 02*

---

## 🏛️ 1. Architecture Overview

XChange adheres to modern **MVVM (Model-View-ViewModel)** architectural patterns, leveraging **Combine** reactive publishers, Swift Concurrency (`async/await`, `@MainActor`), and Apple's **Human Interface Guidelines (HIG)**.

```
                           +---------------------------+
                           |     SwiftUI Views         |
                           | (Explore, Trades, Maps,   |
                           |  Closet, Profile, AR/ML)  |
                           +-------------+-------------+
                                         |
                                 @EnvironmentObject
                                         |
                           +-------------v-------------+
                           |  @MainActor ViewModels    |
                           |  - ItemStore              |
                           |  - TradeProposalStore     |
                           |  - SafeZoneStore          |
                           |  - UserStore              |
                           |  - ChatStore              |
                           +------+-------------+------+
                                  |             |
                 +----------------v--+       +--v------------------+
                 | Domain Models     |       | Core Services       |
                 | - Item            |       | - PersistenceService|
                 | - TradeProposal   |       | - SmartAppraisalML  |
                 | - SafeZone        |       | - LocationService   |
                 | - User & Review   |       | - NetworkService    |
                 +-------------------+       +---------------------+
```

---

## 📂 2. Directory & Module Structure

```
Xchange/
├── App/
│   └── XchangeApp.swift                    # Application entry point with store injections
├── Models/
│   ├── Item.swift                           # Item, ItemCategory, ItemCondition, ItemStatus
│   ├── User.swift                           # User, UserBadge, UserReview domain models
│   ├── TradeProposal.swift                  # TradeProposal, TradeCounterOffer, TradeStatus
│   ├── Message.swift                        # In-trade negotiation chat message model
│   ├── SafeZone.swift                       # MapKit verified safe exchange hub model
│   └── AppraisalResult.swift                # CoreML & Vision classification telemetry model
├── Services/
│   ├── PersistenceService.swift             # Thread-safe disk serialization & backup manager
│   ├── SmartAppraisalMLService.swift        # Apple Vision & ML heuristic valuation engine
│   ├── LocationService.swift                # CoreLocation & MapKit MKDirections routing coordinator
│   └── NetworkService.swift                 # Network connectivity monitor & async cloud sync
├── ViewModels/
│   ├── ItemStore.swift                      # Catalog state, search query debouncing, filtering
│   ├── TradeProposalStore.swift             # Proposal lifecycle, counter-offer audit history
│   ├── SafeZoneStore.swift                  # Verified safe meetup zones & proximity sorting
│   ├── UserStore.swift                      # User trust profiles, ratings, wishlist state
│   └── ChatStore.swift                      # In-trade real-time message stream coordinator
├── Theme/
│   ├── AppTheme.swift                       # Curated color tokens, gradients, corner radii, haptics
│   └── ViewModifiers.swift                  # Shimmer skeleton, pressable spring, pinch-to-zoom
├── Views/
│   ├── MainTabView.swift                    # 5-tab root interface with badge counts & adaptive layout
│   ├── Explore/
│   │   ├── ExploreFeedView.swift            # 2/4-column adaptive grid, hero banner, search
│   │   ├── ItemDetailView.swift             # Detail stage with pinch gesture, AR inspect & AI valuation
│   │   ├── FilterSheetView.swift            # Value slider, condition picker, sort options
│   │   ├── SafeZoneMapView.swift            # Apple Maps view with custom pins & route calculation
│   │   └── SmartAppraisalModalView.swift    # CoreML scanning sheet with animated laser & margin readouts
│   ├── Proposals/
│   │   ├── CreateProposalView.swift         # Multi-item trade builder with balance gauge
│   │   ├── ProposalDetailView.swift         # Proposal breakdown, audit trail, confetti completion
│   │   ├── CounterOfferModalView.swift      # Interactive counter-offer negotiation modal
│   │   └── ProposalsListView.swift          # Segmented tabs: Incoming, Outgoing, Active, History
│   ├── Inventory/
│   │   ├── MyItemsView.swift                # Portfolio valuation, closet inventory, list actions
│   │   └── AddItemView.swift                # New listing form with AI Auto-Appraisal button
│   ├── Chat/
│   │   └── TradeChatView.swift              # In-trade chat with system safety badges
│   ├── Profile/
│   │   ├── ProfileView.swift                # Trust badges, reviews, wishlist, settings link
│   │   ├── AboutMissionView.swift           # Academic purpose & target audience justification
│   │   └── SettingsView.swift               # Persistence cache management, appearance & accessibility
│   └── Components/
│       ├── ItemCard.swift                   # High-density item card with category gradient
│       ├── TradeCard.swift                  # Side-by-side trade comparison card (Offered ⇋ Requested)
│       ├── ValueBalanceBadge.swift          # Parity progress bar indicator
│       ├── InteractiveBarterScaleGauge.swift# Custom Canvas-rendered scale with DragGesture
│       ├── ConfettiView.swift               # Particle celebration physics animation
│       ├── SafeZoneRadarBadge.swift         # Pulsing animated beacon for verified locations
│       └── ARTradePreviewView.swift         # Augmented Reality 1:1 holographic model inspector
└── Resources/
    ├── Info.plist                           # Camera, Photo Library & Location permissions
    └── Assets.xcassets                      # AppIcon & AccentColor asset catalogs
```

---

## 🤖 3. Integration of Emerging Technologies (Rubric Section 6)

### 3.1 Apple Vision & CoreML Item Appraisal (`SmartAppraisalMLService.swift`)
- **Framework**: `Vision`, `CoreML`, `UIKit`.
- **API**: Uses Apple's `VNClassifyImageRequest` with a `VNImageRequestHandler` to process input image data directly on the Apple Neural Engine (ANE).
- **Hedonic Regression Valuation Engine**:
  $$\text{Fair Value} = \text{Base Price}(\text{Category}) \times \text{Multiplier}(\text{Condition})$$
  Where:
  - $\text{Brand New} = 1.00$
  - $\text{Like New} = 0.88$
  - $\text{Gently Used} = 0.72$
  - $\text{Fair Condition} = 0.48$
  - $\text{Vintage/Salvage} = 0.65$
- **Confidence Interval**: Predicts standard valuation margin $[ \text{Min}, \text{Max} ]$ with $95\%$ confidence bounds.
- **Form Auto-Fill**: In `AddItemView.swift`, users can tap **"AI Auto-Appraise Item"**; the model processes the image and automatically populates the title, category, condition, estimated value, and descriptive tags.

### 3.2 Apple MapKit Safe Exchange Zones (`SafeZoneMapView.swift`)
- **Framework**: `MapKit`, `CoreLocation`.
- **API**: Modern SwiftUI `Map(position:selection:)` with custom map annotations and `MKDirections`.
- **Functionality**:
  - Displays curated, verified Safe Barter Exchange Zones (police station designated exchange lots, university security desks, well-lit transit hubs).
  - Calculates real-time walking and driving distance from the trader's coordinates (`CLLocationCoordinate2D`).
  - Allows traders to select a designated Safe Zone and link it directly to their trade proposal meeting location.

### 3.3 Augmented Reality Physical Inspection (`ARTradePreviewView.swift`)
- **Framework**: `ARKit`, `RealityKit`, `SwiftUI`.
- **Functionality**:
  - Provides a 1:1 real-world physical scale AR preview mode.
  - Allows prospective traders to view holographic representations of items before agreeing to physical meetups.
  - Supports interactive spatial rotation and pinch-to-resize gestures.

---

## 💾 4. Data Persistence & Networking Architecture (Rubric Section 5)

### 4.1 Persistence Service (`PersistenceService.swift`)
- **Engine**: Local filesystem storage within `FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)`.
- **Serialization**: `JSONEncoder` and `JSONDecoder` with `.iso8601` date strategies.
- **Safety**: Asynchronous file I/O dispatched onto a dedicated serial background queue (`com.Xchange.persistenceQueue`) with `.atomicWrite` and `.completeFileProtection` flags to ensure zero UI freezes or corrupted writes.
- **Fallback Guarantee**: If disk storage is empty (first launch), stores automatically load sample seed data and persist it to disk immediately.
- **Storage Management**: Includes utility methods for cache size measurement (`totalPersistedBytes()`), file deletion, and a complete catalog reset option in `SettingsView`.

### 4.2 Network Service (`NetworkService.swift`)
- **Engine**: Modern Swift Concurrency (`async/await`) paired with Apple's `Network.framework` (`NWPathMonitor`).
- **Features**: Real-time detection of WiFi vs. Cellular vs. Offline states, background simulation of round-trip cloud latency, and graceful error handling (`NetworkError`).

---

## 🎨 5. Advanced UI Elements & SwiftUI Customization (Rubric Sections 2 & 3)

### 5.1 Interactive Gesture Recognizers
1. **Interactive Scale Drag Gesture (`DragGesture`)**:
   - Implemented in `InteractiveBarterScaleGauge.swift`.
   - Allows users to drag the balance scale beam horizontally to test how adding or subtracting value tilts the parity needle.
2. **Pinch-To-Zoom (`MagnificationGesture`) & Pan (`DragGesture`)**:
   - Implemented as a reusable view modifier in `ViewModifiers.swift` (`.pinchToZoom()`).
   - Attached to `ItemDetailView.swift` hero imagery for detailed inspection of item condition.
   - Includes double-tap reset gesture.

### 5.2 Custom Animations & Transitions
1. **Spring-Physics Barter Scale**: Oscillates with smooth spring physics (`.spring(response: 0.5, dampingFraction: 0.65)`).
2. **Particle Confetti Burst (`ConfettiView.swift`)**: Emits 45 physics-based confetti particles across random Cartesian vectors when a trade deal is confirmed.
3. **Pulsing Radar Wave (`SafeZoneRadarBadge.swift`)**: Concentric radar circles expand and fade continuously to signal active security monitoring.
4. **Shimmer Skeleton Loading (`.shimmerLoading()`)**: Screen-blend linear gradient sweeping across view boundaries during async data fetching.

### 5.3 Adaptive Responsive Layouts
- Monitors `@Environment(\.horizontalSizeClass)`.
- Automatically shifts between a 2-column grid on compact iPhones and a 4-column wide grid on iPads or landscape orientations.

---

## ♿ 6. Accessibility & Human Interface Guidelines (HIG) Compliance

- **Dark Mode & Light Mode**: Built entirely with semantic system colors (`systemGroupedBackground`, `secondarySystemBackground`, `label`, `secondaryLabel`). Tested and verified in both color schemes.
- **Dynamic Type**: Text sizes utilize scalable rounded typography (`.font(.system(size:..., design: .rounded))`), scaling fluidly with user accessibility font settings.
- **Haptic Feedback**: High-definition haptics (`UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator`) are integrated into all trade actions, buttons, and state changes.
- **VoiceOver Support**: Descriptive `.accessibilityLabel` and `.accessibilityHint` modifiers are attached to all custom controls, badges, and icon buttons.
