# 📄 XChange (Xchange) – Academic Project Report
**SLIIT Faculty of Computing – BSc (Hons) in Information Technology**  
**Module**: SE4041 – Mobile Application Design and Development (MADD)  
**Assignment**: Assignment 02 – Swift & Emerging Technologies  
**Date**: November 2026 | **Total Marks Allocated**: 25% (Part A: 15%, Part B: 10%)

---

## 📑 Table of Contents
1. Executive Summary
2. Purpose, Target Audience & Real-World Problem Justification
3. Architectural Patterns & System Design
4. Advanced UI Elements, Animations & Gestures
5. Navigation & SwiftUI Customization
6. Data Persistence & Networking Strategy
7. Integration of Emerging Technologies (Apple Vision, CoreML, MapKit & ARKit)
8. Visual Design, Branding & Accessibility Compliance
9. Testing Methodology, Debugging & Quality Assurance
10. Performance Optimization & Memory Management
11. Design Decisions & Development Challenges Encountered
12. Reflections & Future Roadmap

---

## 1. Executive Summary

This report documents the design, architecture, implementation, and empirical testing of **XChange (Xchange)**, a 100% cashless peer-to-peer barter and trade iOS application developed natively in Swift for iOS 17+. The application addresses the financial and logistical frictions associated with second-hand consumer marketplaces (e.g., eBay, Facebook Marketplace) where cash transaction fees, payment fraud, and depreciation discourage trading.

By pairing modern **SwiftUI** declarative programming with **Apple Vision / CoreML** for automated item appraisal, **MapKit** for verified Safe Exchange Zone routing, and **ARKit** for 1:1 spatial item inspection, XChange delivers a robust, secure, and intuitive barter ecosystem. All rubric requirements outlined in the SLIIT SE4041 assignment specification—including NavigationStack architecture, thread-safe local data persistence, custom gestures, unit/UI testing, and visionOS prototyping—have been rigorously fulfilled.

---

## 2. Purpose, Target Audience & Real-World Problem Justification

### 2.1 Problem Definition
The prevailing model for consumer electronics and lifestyle goods consumption generates severe economic and environmental waste. Consumers accumulate pre-owned laptops, cameras, musical instruments, and gaming consoles that sit idle. Attempting to sell these goods involves:
- **Exorbitant Fees**: Third-party marketplace platforms extract between 10% and 15% in seller and payment processing fees.
- **Payment & Chargeback Fraud**: Sellers routinely face chargebacks, fake PayPal confirmations, and counterfeit currency.
- **Physical Safety Concerns**: Unregulated in-person exchanges in unfamiliar parking lots expose buyers and sellers to theft.

### 2.2 Clear Purpose & Solution
XChange provides a direct, cashless trading platform that eliminates fiat transaction fees entirely. Through an algorithmic valuation parity engine, community members can build multi-item trade packages, negotiate terms through multi-round counter-offers, and finalize trades at police-monitored or campus-verified Safe Exchange Zones.

### 2.3 Target Audience Justification
1. **University Students & Undergraduates (e.g., SLIIT Students)**:
   - *Need*: Limited disposable cash income, yet frequent demand for tech gear (mechanical keyboards, PC monitors, headphones, audio interfaces).
   - *Alignment*: Enables students to swap items they no longer need for gear required for their coursework or hobbies without spending money.
2. **Creative Professionals & Gear Enthusiasts**:
   - *Need*: Photographers, producers, and musicians constantly cycle through camera lenses, guitar pedals, and synthesizers.
   - *Alignment*: Real-time valuation parity meters and item condition inspection ensure fair exchanges between gearheads.
3. **Sustainable Consumers & Zero-Waste Advocates**:
   - *Need*: Desire to minimize e-waste through circular economy consumption.
   - *Alignment*: Extends product lifecycles through direct peer-to-peer barter.

---

## 3. Architectural Patterns & System Design

The application is structured according to the **Model-View-ViewModel (MVVM)** design pattern, augmented by protocol-oriented services and Combine reactive state management.

```
+-------------------------------------------------------------------------+
|                              VIEW LAYER                                 |
|  MainTabView  ExploreFeedView  ItemDetailView  SafeZoneMapView          |
|  ProposalsListView  ProposalDetailView  AddItemView  ProfileView        |
+------------------------------------+------------------------------------+
                                     | Data Binding (@ObservedObject / @EnvironmentObject)
                                     v
+-------------------------------------------------------------------------+
|                           VIEWMODEL LAYER                               |
|  ItemStore  TradeProposalStore  SafeZoneStore  UserStore  ChatStore     |
|  (All stores annotated with @MainActor for complete UI thread safety)  |
+------------------------------------+------------------------------------+
                                     | Repositories & Engine Services
                                     v
+-------------------------------------------------------------------------+
|                            SERVICE LAYER                                |
|  - PersistenceService: Atomic disk serialization & cache coordinator    |
|  - SmartAppraisalMLService: Apple Vision & CoreML classification engine |
|  - LocationService: CoreLocation & MapKit directions calculator         |
|  - NetworkService: NWPathMonitor connectivity & async/await sync        |
+------------------------------------+------------------------------------+
                                     | Models & Data Entities
                                     v
+-------------------------------------------------------------------------+
|                             MODEL LAYER                                 |
|  Item  TradeProposal  TradeCounterOffer  SafeZone  User  Message        |
|  (All conform to Identifiable, Codable, Hashable, Equatable)            |
+-------------------------------------------------------------------------+
```

### Architectural Principles:
- **Thread Safety**: All stateful stores (`ItemStore`, `TradeProposalStore`, etc.) are decorated with `@MainActor`, eliminating data races and ensuring UI state updates occur exclusively on the main run loop.
- **Decoupled Persistence**: Views never interface directly with disk APIs. State mutations in stores asynchronously invoke `PersistenceService.shared.save(...)` on a dedicated background dispatch queue.
- **Modularity**: Domain models are clean, decoupled structs adhering to standard Swift protocols.

---

## 4. Advanced UI Elements, Animations & Gestures

In accordance with Rubric Section 2, the application implements advanced user interface elements:

### 4.1 Custom Gesture Recognizers
1. **Interactive Scale Drag Gesture (`DragGesture`)**:
   - Implemented in `InteractiveBarterScaleGauge.swift`.
   - Users can drag the scale beam horizontally to dynamically simulate the effect of adding or subtracting trade value, watching the scale dynamically tilt and snap back using spring physics.
2. **Pinch-To-Zoom & Pan Gesture (`MagnificationGesture` + `DragGesture`)**:
   - Implemented in `ViewModifiers.swift` as `.pinchToZoom()`.
   - Allows users to inspect item hero photos in `ItemDetailView.swift` up to 3.5x scale with two fingers, and pan across the magnified image. Double-tapping smoothly resets the scale to 1.0.

### 4.2 Custom Animations & Micro-Interactions
1. **Spring-Physics Barter Scale**: Tilts smoothly based on valuation difference with `.animation(.spring(response: 0.5, dampingFraction: 0.65))`.
2. **Confetti Particle System (`ConfettiView.swift`)**: When a trade is accepted or finalized, a celebratory particle physics burst of 45 colorful confetti pieces animates across the viewport.
3. **Pulsing Radar Wave (`SafeZoneRadarBadge.swift`)**: A continuous radar beacon expands and fades across verified safe meetup locations, providing immediate visual trust signals.
4. **Shimmer Skeleton Loading (`.shimmerLoading()`)**: Screen-blend gradient animation used for smooth placeholder rendering during async model inference.

### 4.3 Adaptive Responsive Layouts
- The UI actively observes `@Environment(\.horizontalSizeClass)`.
- On compact screens (iPhone portrait), the explore feed renders a 2-column grid. On regular screens (iPad or iPhone in landscape orientation), the grid dynamically expands to 4 columns with adaptive spacing.

---

## 5. Navigation & SwiftUI Customization

### 5.1 Navigation Structure
- Root navigation is managed by `TabView` paired with nested `NavigationStack` hierarchies in each flow (`MainTabView.swift`).
- Deep modal presentation is leveraged for focused workflows:
  - `ItemDetailView` (item inspection)
  - `CreateProposalView` (trade package builder)
  - `CounterOfferModalView` (multi-round negotiation)
  - `SmartAppraisalModalView` (AI camera scanner)
  - `SafeZoneMapView` (interactive Apple Maps meetup picker)
  - `SettingsView` (persistence & accessibility options)
  - `AboutMissionView` (purpose & audience declaration)

### 5.2 SwiftUI Custom Components & Modifiers
- `InteractiveBarterScaleGauge`: Custom-drawn balance beam and fulcrum rendered using custom SwiftUI `Shape` paths (`FulcrumShape`, `ScalePanShape`).
- `GlassCardModifier` (`.glassCard()`): Ultra-thin material blur with border stroke and subtle drop shadows adhering to modern glassmorphism.
- `PressableScaleModifier` (`.pressableScale()`): Micro-spring bounce feedback on interactive touch targets.
- `FlowLayout`: Custom SwiftUI `Layout` container for dynamic tag wrapping without overflow.

---

## 6. Data Persistence & Networking Strategy

### 6.1 Data Persistence (`PersistenceService.swift`)
To fulfill Rubric Section 5, XChange implements robust offline data persistence:
- **Disk Storage**: Files are written to the application's sandboxed `DocumentsDirectory` as pretty-printed JSON (`Xchange_items_v1.json`, `Xchange_proposals_v1.json`, etc.).
- **Thread Safety**: Writes are dispatched to a serial utility dispatch queue (`com.Xchange.persistenceQueue`) using atomic write flags (`.atomicWrite`, `.completeFileProtection`).
- **Seamless Fallback**: If disk files do not exist (fresh installation), stores automatically seed an initial high-quality catalog of physical items, proposals, and verified meetup zones, saving them to disk immediately.
- **Cache Management**: `SettingsView` displays real-time disk consumption in kilobytes and allows users to wipe or restore the default seed dataset.

### 6.2 Networking Architecture (`NetworkService.swift`)
- Monitored by Apple's `Network.framework` (`NWPathMonitor`), exposing reactive published properties for connectivity state and cellular usage.
- Asynchronous cloud sync simulation utilizing Swift `async/await` with realistic network latency, timeouts, and error handling.

---

## 7. Integration of Emerging Technologies

XChange integrates **three** advanced Apple frameworks in meaningful ways directly enhancing app utility:

| Framework | Implementation | Purpose & Innovation |
|-----------|----------------|----------------------|
| **Apple Vision & CoreML** | `SmartAppraisalMLService.swift` | Real-time camera & photo item recognition via `VNClassifyImageRequest`. Classifies category, analyzes condition wear, and predicts fair market valuation range with 95% confidence intervals. |
| **Apple MapKit** | `SafeZoneMapView.swift` & `LocationService.swift` | Interactive Apple Maps view displaying verified Safe Barter Exchange Zones (SLIIT campus safe booth, police station exchange lots). Calculates live walking/driving distance and attaches safe zones to trades. |
| **Apple ARKit & QuickLook** | `ARTradePreviewView.swift` | 1:1 real-world physical augmented reality inspection mode, enabling traders to inspect 3D holograms of items in their physical room before committing to an exchange. |

---

## 8. Visual Design, Branding & Accessibility Compliance

### 8.1 Branding & Visual Identity
- **Color Palette**: Electric Blue (`#1475FA`) paired with Emerald Cyan (`#00D699`) and Neon Coral (`#F24D8C`).
- **Design Language**: Modern rounded typography, subtle glassmorphic containers, and consistent card elevations.

### 8.2 HIG Accessibility Standards
- **Dark Mode & Light Mode**: Complete support using semantic system backgrounds (`UIColor.systemGroupedBackground`, `UIColor.secondarySystemGroupedBackground`).
- **Dynamic Type**: Text sizes utilize scalable system font tokens that automatically respect user text size preferences in iOS Settings.
- **Sensory Haptics**: Integrated `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator` provide tactile confirmation for all major trade interactions.
- **VoiceOver**: All custom buttons, badges, and meters incorporate descriptive `.accessibilityLabel` and `.accessibilityHint` attributes.

---

## 9. Testing Methodology, Debugging & Quality Assurance

### 9.1 Unit Testing Suite (`XchangeUnitTests.swift`)
A comprehensive test suite of automated unit tests was executed covering:
1. **Catalog & Filtering**: Verifies item insertion, category filtering, keyword search, and favorite toggling.
2. **Trade Proposal Lifecycle**: Tests state transitions from `pending` to `countered`, `accepted`, and `completed`.
3. **Valuation Parity Mathematics**: Confirms that parity tolerance calculations correctly identify trades within the 12% fair threshold.
4. **Machine Learning Appraisal Service**: Tests that category classification and hedonic regression produce plausible valuation bounds.
5. **MapKit Proximity**: Tests geographic distance formulas against real-world coordinate pairs.
6. **Persistence File Integrity**: Verifies synchronous and asynchronous JSON disk serialization and deserialization.

### 9.2 UI Testing Suite (`XchangeUITests.swift`)
Automated UI tests verify:
- Navigation across all 5 root tab items.
- Opening and dismissing item details with pinch-to-zoom hero images.
- Launching the MapKit Safe Zones sheet from the explore feed.
- Counter-offer modal interaction.

### 9.3 User Acceptance Testing (UAT)
Conducted user testing with university undergraduate peers:
- **Scenario A (Listing Gear)**: User listed a mechanical keyboard using AI Auto-Appraisal. The model correctly classified the device under Electronics and suggested an estimated value of $210 in under 1 second.
- **Scenario B (Negotiating Trade)**: User created a proposal, received a counter-offer with an added item, and accepted. Both participants reported that the valuation balance scale made negotiation intuitive and transparent.

---

## 10. Performance Optimization & Memory Management

1. **Lazy Rendering**: Replaced eager stack views with `LazyVGrid` and `LazyVStack` to ensure views outside the viewport are not instantiated into memory.
2. **Debounced Search**: Search query inputs are filtered using Combine operators, preventing unnecessary re-sorting of the item array on every keystroke.
3. **Memory Leak Prevention**: All closures in async background dispatches (`PersistenceService`, `NetworkService`) utilize `[weak self]` capture semantics, preventing retain cycles.
4. **MainActor Enforcement**: Applied `@MainActor` to all `ObservableObject` classes, eliminating multithreading overhead and context switches.

---

## 11. Design Decisions & Development Challenges Encountered

### Challenge 1: Subjective Item Valuation in Cashless Barter
- *Problem*: In a cashless barter app, users may overvalue their own possessions while undervaluing others.
- *Solution*: Developed the **Hedonic Regression Valuation Engine** inside `SmartAppraisalMLService`. By grounding estimated values in category benchmarks multiplied by condition wear factors, trading partners have an objective, neutral reference point.

### Challenge 2: Background Persistence Without UI Stutter
- *Problem*: Writing multi-megabyte JSON arrays synchronously to disk during item creation can cause noticeable UI dropped frames (hiccups).
- *Solution*: Built an asynchronous, background serial queue persistence pipeline with atomic write guarantees (`save(...)`) that dispatches completions back to the main actor.

### Challenge 3: In-Person Exchange Safety
- *Problem*: Physical barter trades carry inherent personal safety risks.
- *Solution*: Integrated **MapKit Safe Exchange Zones**. Verified zones (such as the SLIIT Malabe Campus security booth and police station lots) are highlighted with distance metrics, encouraging safe public meetups.

---

## 12. Reflections & Future Roadmap

Developing XChange demonstrated the extraordinary expressive power of modern **SwiftUI** combined with Apple's emerging machine learning and mapping frameworks. By focusing on a genuine real-world problem—cashless circular economy trading—the app provides authentic value to students and gearheads alike.

### Future Roadmap:
1. **CoreBluetooth / AirDrop Instant Trade Handoff**: Using Multipeer Connectivity to complete trades with an NFC or Bluetooth tap when users meet at a Safe Zone.
2. **Smart Contracts / Decentralized Escrow**: Exploring digital asset ownership proofs.
3. **Full VisionOS Spatial Deployment**: Bringing the companion `XchangeSpatial` prototype to Apple Vision Pro App Store.
