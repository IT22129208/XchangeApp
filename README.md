# 🔄 Xchange – Native iOS & VisionOS Barter App
**SLIIT Faculty of Computing – BSc (Hons) in Information Technology**  
**Module**: SE4041 – Mobile Application Design and Development (MADD) – Assignment 02 (Swift)  
**Total Marks**: 25% (Part A: 15% Advanced iOS App | Part B: 10% VisionOS Prototype)

---

## 🚀 Executive Summary

**Xchange** is a 100% cashless, native iOS peer-to-peer barter and trade application built with **SwiftUI**, **Combine**, and Apple's **Human Interface Guidelines (HIG)**. It allows community members to list physical items they own (electronics, cameras, musical instruments, gaming gear, fashion) and trade them directly with other members using **real-time valuation parity balancing**, **multi-round counter-offer negotiation**, **Apple Vision / CoreML AI appraisal**, and **MapKit Safe Exchange Zones**.

The repository includes:
1. **Part A (15%)**: Fully functional advanced iOS 17+ application with custom Authentication (`LoginView` & `XchangeLogoView`), CoreML, MapKit, ARKit, atomic local disk persistence, gestures, custom animations, unit tests, and UI tests.
2. **Part B (10%)**: Novel spatial computing prototype application for **Apple Vision Pro (`XchangeSpatial/`)** featuring a 3D volumetric dual-pan barter scale and collaborative immersive spaces.

---

## 📱 Part A: Features & Rubric Alignment (15% of Marks)

| Rubric Requirement | Implementation in Xchange | Relevant Code Files |
|-------------------|---------------------------|---------------------|
| **1. Purpose & Target Audience** | Solves second-hand marketplace fees (12–15%) and fraud through cashless trade for university students and gearheads. | [AboutMissionView.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Views/Profile/AboutMissionView.swift), [USER_GUIDE.md](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/USER_GUIDE.md) |
| **2. Pixel-Perfect Authentication & Splash** | Animated 4-second pitch-black splash screen with hexagonal barter matrix & progress bar, followed by brand login and registration screens with dark capsule inputs, eye toggle, bidirectional navigation between Login & SignUp, and social login. | [SplashScreenView.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Views/Auth/SplashScreenView.swift), [LoginView.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Views/Auth/LoginView.swift), [SignUpView.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Views/Auth/SignUpView.swift), [XchangeLogoView.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Views/Auth/XchangeLogoView.swift) |
| **3. Advanced UI & Gestures** | Interactive drag gesture on the barter scale; two-finger pinch-to-zoom on item photos; particle confetti celebration; pulsing radar beacons. | [InteractiveBarterScaleGauge.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Views/Components/InteractiveBarterScaleGauge.swift), [ViewModifiers.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Theme/ViewModifiers.swift), [ConfettiView.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Views/Components/ConfettiView.swift) |
| **4. SwiftUI Components & Customization** | Custom GlassCard modifier, custom Canvas-drawn fulcrum & scale pans, shimmer loading skeletons, pressable bounce effects. | [InteractiveBarterScaleGauge.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Views/Components/InteractiveBarterScaleGauge.swift), [AppTheme.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Theme/AppTheme.swift) |
| **5. Navigation & Architecture** | MVVM architecture with `@MainActor` thread safety, 5-tab root interface, sheet coordinators, and NavigationStack flows. | [XchangeApp.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/App/XchangeApp.swift), [MainTabView.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Views/MainTabView.swift) |
| **6. Data Persistence & Networking** | Thread-safe atomic JSON disk persistence to `DocumentsDirectory`, background serial queues, auto-seed fallback, and `NWPathMonitor` network coordinator. | [PersistenceService.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Services/PersistenceService.swift), [NetworkService.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Services/NetworkService.swift) |
| **7. Emerging Technologies (ML & Maps)** | **CoreML / Apple Vision**: AI camera classification & hedonic valuation regression.<br>**MapKit**: Verified Safe Exchange Zones with Apple Maps annotations and route distance calculations.<br>**ARKit**: 1:1 scale augmented reality 3D item inspection. | [SmartAppraisalMLService.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Services/SmartAppraisalMLService.swift), [SafeZoneMapView.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Views/Explore/SafeZoneMapView.swift), [ARTradePreviewView.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Views/Components/ARTradePreviewView.swift) |
| **8. Visual Design & Accessibility** | Curated Electric Blue & Emerald Cyan design system, full Light & Dark mode support, Dynamic Type font scaling, haptics, and VoiceOver labels. | [AppTheme.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Theme/AppTheme.swift), [SettingsView.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/Xchange/Views/Profile/SettingsView.swift) |
| **9. Testing & Optimization** | Comprehensive unit testing suite covering store logic, trade lifecycle, parity math, and ML bounds; automated UI testing suite; `@MainActor` and lazy grid optimization. | [XchangeUnitTests.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/XchangeTests/XchangeUnitTests.swift), [XchangeUITests.swift](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/XchangeUITests/XchangeUITests.swift) |
| **10. Documentation & Reporting** | Complete User Guide, Technical Documentation, 12-section Academic Report, and AI-Assisted Development Log. | [USER_GUIDE.md](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/USER_GUIDE.md), [TECHNICAL_DOCUMENTATION.md](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/TECHNICAL_DOCUMENTATION.md), [PROJECT_REPORT.md](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/PROJECT_REPORT.md), [AI_ASSISTED_DEVELOPMENT_LOG.md](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/AI_ASSISTED_DEVELOPMENT_LOG.md) |

---

## 🥽 Part B: VisionOS Prototype (10% of Marks)

Located in `XchangeSpatial/`:
- **Volumetric 3D Dual-Pan Scale**: A $0.6\text{m} \times 0.6\text{m} \times 0.6\text{m}$ 3D volumetric scale floating in room space that tilts in real-time according to trade parity.
- **2.5D Showroom Window**: Native visionOS window styled with `.glassBackgroundEffect()` and bottom spatial ornament toolbars.
- **Collaborative Negotiation Lounge**: Immersive mixed space where traders negotiate across a shared 3D spatial table with spatial audio cues.
- **Documentation & Investor Pitch**:
  - [PART_B_VISIONOS_PROTOTYPE_REPORT.md](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/PART_B_VISIONOS_PROTOTYPE_REPORT.md)
  - [PART_B_PITCH_PRESENTATION.md](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/PART_B_PITCH_PRESENTATION.md) (Slide-by-slide investor deck with financial forecasts and viva defense questions).

---

## 🏗️ Repository Architecture

```
IOS APP/
├── Xchange/                             # Native iOS Application Target
│   ├── App/                             # XchangeApp.swift (Root scene & auth routing)
│   ├── Models/                          # Item, TradeProposal, SafeZone, User, Message, AppraisalResult
│   ├── Services/                        # PersistenceService, SmartAppraisalMLService, LocationService, NetworkService
│   ├── ViewModels/                      # ItemStore, TradeProposalStore, SafeZoneStore, UserStore, ChatStore
│   ├── Theme/                           # AppTheme.swift, ViewModifiers.swift
│   ├── Views/                           # Auth, Explore, Proposals, Inventory, Chat, Profile, Components
│   │   ├── Auth/                        # SplashScreenView.swift, LoginView.swift, SignUpView.swift, XchangeLogoView.swift
│   └── Resources/                       # Info.plist (Permissions), Assets.xcassets
├── XchangeSpatial/                      # Part B: VisionOS Prototype Target
│   ├── XchangeSpatialApp.swift          # VisionOS @main coordinator (Window, Volumetric & ImmersiveSpace)
│   ├── Views/                           # SpatialMainView, VolumetricBarterScaleView, SpatialItemInspectorView, SpatialNegotiationRoomView
│   └── Resources/                       # Info.plist
├── XchangeTests/                        # Automated Unit Testing Suite
│   └── XchangeUnitTests.swift           # Unit tests for stores, ML valuation, parity math, persistence
├── XchangeUITests/                      # Automated UI Testing Suite
│   └── XchangeUITests.swift             # UI tests for login, tab navigation, gestures, modal sheets
├── Xchange.xcodeproj/                   # Xcode project configuration
├── USER_GUIDE.md                        # Step-by-step illustrated user guide
├── TECHNICAL_DOCUMENTATION.md           # System architecture, data flow, frameworks spec
├── PROJECT_REPORT.md                    # Academic report fulfilling assignment criteria
├── AI_ASSISTED_DEVELOPMENT_LOG.md       # SLIIT compliance disclosure log of AI interactions
├── PART_B_VISIONOS_PROTOTYPE_REPORT.md  # VisionOS technical prototype documentation
└── PART_B_PITCH_PRESENTATION.md         # Investor pitch deck & viva defense preparation
```

---

## 🚀 How to Build & Run

### 1. iOS Application (Part A)
1. Open `Xchange.xcodeproj` in **Xcode 15+** on macOS.
2. Select the target **Xchange** and an **iOS 17+ Simulator** (e.g., iPhone 15 Pro, iPhone 16) or connected device.
3. Press `Cmd + R` to build and run.
4. Experience the official **Xchange Login Screen** with email/password auth and social sign-in, or tap **LOG IN** to transition smoothly into the 5-tab main application.
5. **Run Unit & UI Tests**: Press `Cmd + U` to execute all unit tests and automated UI tests.

### 2. VisionOS Prototype (Part B)
1. In Xcode, select the **XchangeSpatial** target.
2. Select the **Apple Vision Pro (visionOS 1.0+) Simulator**.
3. Press `Cmd + R` to launch into the spatial computing environment.
4. Use visionOS eye-look and pinch controls to interact with the 2.5D showroom, 3D volumetric scale, and shared spatial room.

---

## 📄 Academic Integrity Declaration
All source code, designs, and documentation were created specifically for SLIIT SE4041 Assignment 02. External frameworks used (Apple Vision, MapKit, ARKit) are native iOS SDKs. In accordance with university policy, all AI design interactions are fully disclosed in [AI_ASSISTED_DEVELOPMENT_LOG.md](file:///c:/Users/EBC-IT-SASHIK/Desktop/IOS%20APP/AI_ASSISTED_DEVELOPMENT_LOG.md).
