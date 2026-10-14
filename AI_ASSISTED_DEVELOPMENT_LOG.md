# 🤖 AI-Assisted Development Log & Declaration
**SLIIT Faculty of Computing – BSc (Hons) in Information Technology**  
*SE4041: Mobile Application Design and Development (MADD) – Assignment 02*  
*Student Name*: Sashik M. | *Student ID*: IT21XXXXXX  

---

## 📋 Statement of Compliance
In accordance with the **Submission Guidelines** on page 5 of the SE4041 Assignment 02 specification:
> *"AI-Assisted Development: If you use AI tools like GitHub Copilot or ChatGPT, document the interactions, including prompts and responses, and explain how they assisted your development process."*

This log provides full transparency regarding all AI interactions, prompts, model outputs, verification processes, and developer refinements utilized during the conception, architecture, implementation, and testing of **XChange (Xchange)**.

---

## 🛠️ Summary of AI Tools Used
- **Tool / Platform**: Advanced Agentic Coding Assistant (Antigravity IDE / Gemini 3.7 Flash)
- **Primary Roles**:
  1. Requirement decomposition against the SLIIT rubric
  2. Architecture scaffolding (MVVM, NavigationStack, protocol boundaries)
  3. Vision framework (`VNClassifyImageRequest`) and CoreML heuristic implementation
  4. MapKit integration for Safe Exchange Zones
  5. Generating comprehensive unit tests and automated UI tests
  6. Drafting VisionOS spatial computing prototype architecture

---

## 📝 Chronological Interaction Log

### Session 1: Requirements Analysis & Architectural Planning
- **Prompt**:
  > *"Analyze the SLIIT SE4041 Assignment 02 PDF rubric. Identify all required criteria for Part A (Advanced iOS App - 15%) and Part B (Innovative Application for VisionOS/tvOS - 10%). Create an architectural plan for an iOS app called XChange that satisfies every single requirement."*
- **AI Response Summary**:
  - Outlined the 10 rubric sections: Purpose & Target Audience, Advanced UI (animations, gestures, adaptive layouts), SwiftUI Customization, NavigationStack, Data Persistence, Emerging Technologies (CoreML, MapKit, ARKit), Visual Design & Accessibility (Dark Mode, Dynamic Type), Testing (Unit & UI Tests), Documentation & Reporting, and VisionOS prototyping.
  - Recommended integrating BOTH CoreML (Vision item appraisal) AND MapKit (Safe Exchange Zones) to achieve maximum marks in Emerging Technologies.
- **Developer Review & Modifications**:
  - Accepted the recommendation to implement both CoreML and MapKit. Adjusted the theme tokens to align with high-contrast electric blue and emerald cyan brand colors.

---

### Session 2: Local Data Persistence Layer Scaffolding
- **Prompt**:
  > *"Implement a thread-safe persistence service in Swift that saves and loads Codable models to the sandboxed DocumentsDirectory using JSONEncoder/JSONDecoder, with atomic file writing and background queue dispatching to prevent UI stutter."*
- **AI Response Summary**:
  - Provided `PersistenceService.swift` with generic `save<T: Encodable>` and `load<T: Decodable>`, utilizing a serial utility queue (`com.Xchange.persistenceQueue`) and `.atomicWrite`.
- **Developer Review & Modifications**:
  - Verified that all models (`Item`, `TradeProposal`, `Message`, `User`, `SafeZone`) conform to `Codable`. Added fallback seed loading so that fresh installs automatically populate with rich sample data.

---

### Session 3: Emerging Technologies Integration (Vision & MapKit)
- **Prompt**:
  > *"How can we implement an AI camera appraisal tool that uses Apple's Vision framework (`VNClassifyImageRequest`) to inspect item photos, predict the category and condition, and calculate an estimated barter value range?"*
- **AI Response Summary**:
  - Developed `SmartAppraisalMLService.swift` utilizing `VNClassifyImageRequest` and a hedonic regression engine based on condition wear multipliers and category base valuations.
  - Created `SmartAppraisalModalView.swift` with an animated laser scanning UI.
- **Developer Review & Modifications**:
  - Added confidence interval margins ($95\%$ bounds) and auto-population hooks into `AddItemView.swift` so user listings are populated with one tap.

- **Prompt**:
  > *"Implement Apple MapKit interactive safe exchange zones showing police station lots and campus safe hubs with distance calculations from the user."*
- **AI Response Summary**:
  - Provided `LocationService.swift` and `SafeZoneMapView.swift` with custom map annotations, amenity chips, and distance formatting.
- **Developer Review & Modifications**:
  - Added specific SLIIT Computing Malabe Campus coordinate fixtures to demonstrate academic context during viva demonstrations.

---

### Session 4: Advanced UI Elements & Gesture Recognizers
- **Prompt**:
  > *"Create custom SwiftUI gesture recognizers for: (1) an interactive balance scale gauge where the user drags the scale beam to simulate trade parity; and (2) a pinch-to-zoom and pan modifier for item detail imagery."*
- **AI Response Summary**:
  - Created `InteractiveBarterScaleGauge.swift` using `DragGesture` and custom `Shape` paths.
  - Created `.pinchToZoom()` modifier in `ViewModifiers.swift` combining `MagnificationGesture` and `DragGesture`.
- **Developer Review & Modifications**:
  - Tuned spring damping parameters to achieve natural tactile responsiveness and added haptic feedback triggers on drag gestures.

---

### Session 5: Unit & UI Testing Suites
- **Prompt**:
  > *"Write comprehensive unit tests in XCTest covering ItemStore, TradeProposalStore lifecycle, trade parity math, CoreML valuation bounds, and persistence file writing."*
- **AI Response Summary**:
  - Delivered `XchangeUnitTests.swift` covering 10 distinct test scenarios with assertions for each store and service.
  - Delivered `XchangeUITests.swift` validating 5-tab navigation, modal presentation, and interactive components.
- **Developer Review & Modifications**:
  - Verified assertions and ensured test isolation by instantiating fresh store instances in `setUp()`.

---

### Session 6: Part B VisionOS Prototype & Investor Pitch
- **Prompt**:
  > *"Design a VisionOS prototype for Apple Vision Pro called Xchange Spatial. Include a 2.5D main showroom with glassBackgroundEffect, a 3D volumetric dual-pan scale window, and a shared immersive space for collaborative negotiation."*
- **AI Response Summary**:
  - Created `XchangeSpatial/` codebase (`XchangeSpatialApp.swift`, `SpatialMainView.swift`, `VolumetricBarterScaleView.swift`, `SpatialItemInspectorView.swift`, `SpatialNegotiationRoomView.swift`).
  - Generated complete investor pitch deck and viva defense report.
- **Developer Review & Modifications**:
  - Verified visionOS Human Interface Guidelines compliance and prepared viva demonstration scripts.

---

## 🔍 Critical Reflection on AI Assistance
The use of AI tools significantly accelerated the scaffolding of boilerplate serialization logic, test case drafting, and complex geometry calculations for the balance beam shapes. However, all domain logic—including barter parity thresholds, trade status transitions, safety hub curation, and UI aesthetics—required deliberate architectural structuring, human judgment, and manual testing to ensure total alignment with the SLIIT assignment rubric.
