# 🥽 Part B: Innovative Application for VisionOS – Technical Prototype Report
**SLIIT Faculty of Computing – BSc (Hons) in Information Technology**  
*SE4041: Mobile Application Design and Development (MADD) – Assignment 02 (Part B: 10% of Marks)*  
**Project**: **Xchange Spatial (XChange Spatial for Apple Vision Pro)**

---

## 📑 Rubric Criteria Breakdown (Part B)
- **Concept Innovation (25 Marks)**: Novelty, market potential, problem-solving, and comparison with existing applications.
- **Prototype Functionality (25 Marks)**: Core feature demonstration, spatial computing, volumetric 3D windows.
- **User Experience Design (15 Marks)**: VisionOS HIG compliance, spatial eye/hand tracking, glassmorphism, depth.
- **Technical Proficiency (15 Marks)**: SwiftUI for visionOS architecture, volumetric window configuration, stability.
- **Pitch Presentation (20 Marks)**: Professional investor pitch deck, revenue model, go-to-market strategy.

---

## 💡 1. Innovative Concept Development (25 Marks)

### 1.1 The Concept
**Xchange Spatial** is the world’s first spatial computing cashless barter and trade showroom, custom-built for **Apple Vision Pro (visionOS)**. It reimagines physical goods exchange by transforming 2D marketplace listings into **interactive 3D holographic models** floating in the user’s physical room.

Users can place a physical-scale **3D Volumetric Dual-Pan Balance Scale** in their living room, physically pick up floating 3D items with hand pinch gestures, place them onto the virtual scale pans, and watch the scale physically tilt and balance in real-time according to estimated market value parity. Furthermore, trading partners can enter a **Shared Spatial Negotiation Room** (`ImmersiveSpace`) to inspect goods together and negotiate counter-offers across a shared virtual table with spatial audio.

### 1.2 Comparison with Existing Applications
| Application | Platform | Limitations Overcome by Xchange Spatial |
|-------------|----------|-----------------------------------------|
| **eBay / OfferUp** | iOS / Web | Flat 2D photos only; no depth perception, no spatial inspection of physical wear, heavy fiat transaction fees (12.9%), no barter parity. |
| **StockX / GOAT** | iOS / VisionOS | Strictly cash-based authenticated resale; limited to sneakers/apparel; no multi-item trade negotiation, no volumetric dual-pan scale. |
| **JigSpace** | VisionOS | Excellent 3D CAD viewer, but purely an industrial presentation tool; lacks marketplace dynamics, valuation parity, and counter-offer negotiation. |
| **Apple Freeform** | VisionOS | Spatial whiteboard without domain-specific barter logic, trading audit logs, or AI valuation integration. |

**Xchange Spatial** merges the spatial immersion of JigSpace with the peer-to-peer commerce engine of XChange, creating a completely novel spatial commerce category.

---

## 🛠️ 2. Advanced Prototype Development & Architecture (25 Marks)

The visionOS prototype codebase is organized within `XchangeSpatial/` and implements three core spatial scenes:

```
                               +-----------------------------+
                               |     XchangeSpatialApp      |
                               |  (@main Scene Coordinator)  |
                               +--------------+--------------+
                                              |
                +-----------------------------+-----------------------------+
                |                                                           |
+---------------v---------------+   +-----------------v-------------+   +---v---------------------------+
|      Primary 2.5D Window      |   |   3D Volumetric Window        |   |    Shared Immersive Space     |
|       SpatialMainView         |   | VolumetricBarterScaleView     |   | SpatialNegotiationRoomView    |
| - GlassBackgroundEffect       |   | - 0.6m x 0.6m x 0.6m Volume   |   | - Mixed Immersion Style       |
| - Bottom Spatial Ornaments    |   | - 3D Dual-Pan Balance Arm     |   | - Shared 3D Trade Table       |
| - Holographic 3D Grid         |   | - Dynamic 3D Spatial Tilt     |   | - Spatial Audio Negotiations  |
+-------------------------------+   +-------------------------------+   +-------------------------------+
```

### 2.1 Core Feature Implementation
1. **Primary 2.5D Spatial Window (`SpatialMainView.swift`)**:
   - NavigationSplitView rendered with `.glassBackgroundEffect()`.
   - Bottom floating spatial ornament toolbar housing fast-launch actions for the volumetric scale and immersive room.
   - Interactive 3D item cards with visionOS `.hoverEffect(.highlight)`.
2. **Volumetric 3D Dual-Pan Barter Scale (`VolumetricBarterScaleView.swift`)**:
   - Defined in `XchangeSpatialApp.swift` with `.windowStyle(.volumetric)` and bounding dimensions of $0.6\text{m} \times 0.6\text{m} \times 0.6\text{m}$.
   - Features a 3D fulcrum stand and tilting balance arm with two hanging spatial pan dishes.
   - Responds dynamically to interactive weight adjustments, providing immediate visual and numerical feedback on fair trade parity.
3. **3D Hologram Item Inspector (`SpatialItemInspectorView.swift`)**:
   - Renders 3D holographic models in volumetric space.
   - Users can drag with their fingers to rotate the model $360^\circ$ along the X and Y axes, and pinch to zoom in and out.
   - Displays real-time condition grading, USDZ compatibility, and AI valuation certificates.
4. **Shared Collaborative Negotiation Lounge (`SpatialNegotiationRoomView.swift`)**:
   - Immersive space with `.mixed` immersion, allowing users to see their physical room while floating a holographic negotiation table between trading partners.
   - Emits spatial audio cues when counter-offers are sent or deals are confirmed.

---

## 🎨 3. User Experience & Spatial Interaction Design (15 Marks)

### 3.1 VisionOS HIG Adherence
- **Gaze & Pinch Navigation**: All interactive buttons, cards, and ornaments support system eye-tracking hover states (`.hoverEffect()`), allowing users to look at an element and pinch their fingers to activate.
- **Glassmorphic Material**: Content floats using Apple’s official `.glassBackgroundEffect()`, allowing ambient real-world lighting from the user’s room to dynamically refract through the application windows.
- **Ergonomic Spatial Distance**: Default window positions are placed at a comfortable viewing distance (2 meters) within the user’s field of view, preventing visual fatigue.

---

## 💻 4. Technical Proficiency & Coding Standards (15 Marks)

- **Swift Concurrency**: Asynchronous opening and dismissing of immersive spaces (`openImmersiveSpace`, `dismissImmersiveSpace`) via Swift `Task` and `async/await`.
- **Modularity**: Clean separation of 2.5D windows, volumetric 3D volumes, and immersive scenes.
- **Performance Optimization**: Bounded volumetric scene dimensions prevent GPU memory spikes; light reflections and shadows utilize hardware-accelerated shaders.

---

## 📊 5. Conclusion
**Xchange Spatial** demonstrates that peer-to-peer commerce on Apple Vision Pro can transcend flat storefronts, offering tactile, engaging, and collaborative trading experiences that set a benchmark for future spatial computing applications.
