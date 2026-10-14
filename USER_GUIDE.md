# 📖 XChange (Xchange) – Official User Guide
**SLIIT Faculty of Computing – BSc (Hons) in Information Technology**  
*SE4041: Mobile Application Design and Development (MADD) – Assignment 02*

---

## 🌟 1. Introduction & Overview

**XChange** is a 100% cashless, peer-to-peer barter and trade iOS application built natively with **SwiftUI**, **Combine**, Apple **CoreML / Vision**, **MapKit**, and **ARKit**.

Unlike conventional secondhand marketplaces that impose high cash transaction fees (10–15%) and expose users to payment scams, XChange enables community members to swap physical gear (electronics, cameras, musical instruments, gaming consoles, fashion, outdoor equipment) directly using **algorithmic valuation parity**.

---

## 📱 2. Core Feature Walkthrough

### 2.1 Exploring the Marketplace Feed (Explore Tab)
1. **Browse Listings**: Scroll through the responsive grid feed showcasing verified community listings.
2. **Category Filters**: Tap category pills (*Electronics, Gaming, Cameras, Musical Instruments, Fashion, Books & Vinyl*) to instantly filter items.
3. **Keyword & Tag Search**: Use the search bar to locate gear by brand name, model, condition, or trader trade preferences.
4. **Sort & Value Slider**: Tap the filter button (top right) to sort by *Newest Listed*, *Value: Low to High*, or *Value: High to Low*, and adjust the maximum valuation slider.
5. **Pull-to-Refresh**: Swipe down on the marketplace feed to trigger a network sync with the cloud trade registry.

```
+-----------------------------------------------------------+
|  [⚡ XChange]             📍 Malabe / SF Hub        [🔔 2] |
|  [ 🔍 Search items, keyboards, cameras... ]        [ ⚙️ ] |
|  [ ✨ AI Smart Appraisal ]      [ 🛡️ Safe Zones Map ]     |
|  [ 100% CASHLESS: Trade What You Own. Get What You Love. ] |
|  (All)  (Electronics)  (Gaming)  (Cameras)  (Music)       |
+-----------------------------------------------------------+
```

---

### 2.2 Inspecting Items & Emerging Tech Features
Tap on any item card to open the **Item Detail View**:
1. **Interactive Pinch-to-Zoom**: Pinch with two fingers to zoom into the hero visual up to 3.5x magnification. Double-tap to instantly snap back.
2. **AR 3D Physical Inspection**: Tap **"AR 3D Inspect"** to launch Apple ARKit / QuickLook mode. You can inspect the holographic device at 1:1 real-world scale and rotate it in 3D physical space.
3. **AI Valuation Breakdown**: Tap **"AI Valuation"** to see machine learning appraisal metrics, confidence margin intervals, and condition wear telemetry.
4. **Owner Barter Wishlist**: Review what specific items the owner is actively searching for before submitting an offer.
5. **Verified Safe Zone Badge**: View the recommended mutual Safe Meetup Zone nearby.

---

### 2.3 Listing an Item & AI Auto-Appraisal (My Closet Tab)
1. Navigate to the **"My Closet"** tab and tap **"+ List Item"** in the top navigation bar.
2. Tap the **"✨ AI Auto-Appraise Item"** button at the top of the listing form:
   - The camera scanner runs **Apple Vision (`VNClassifyImageRequest`)** and a CoreML neural valuation regression heuristic.
   - The laser scanner analyzes the item image and automatically detects the category (e.g., *Electronics: 96% Confidence*).
   - The service estimates the fair trade valuation range (e.g., *$280 USD*) and suggests SEO tags.
   - Tap **"Apply Appraisal to Listing"** to automatically populate the title, category, condition, valuation, and tags into your listing form!
3. Tap **"List Item"** to publish. The item is atomically saved to local disk storage via `PersistenceService`.

---

### 2.4 Creating & Negotiating Barter Proposals (Trades Tab)
1. On any item detail view, tap **"Propose Barter Trade"**.
2. **Multi-Item Builder**: Select 1 or more items from your closet to offer in exchange for the requested item.
3. **Interactive Parity Scale**:
   - The dual-pan balance scale calculates total offered value vs. total requested value.
   - If the valuation difference is within 12%, the indicator confirms a **"⚖️ Fair Trade Balance"**.
   - You can physically drag the balance beam with your finger to test different tilt angles!
4. **Designated Safe Zone**: Choose an official police-monitored or campus-verified meetup spot for physical handoff.
5. Tap **"Send Barter Proposal"**.

---

### 2.5 Multi-Round Counter-Offer Engine
When receiving a trade proposal, navigate to **Trades → Incoming**:
1. **Review Proposal**: Examine the partner's offered items side-by-side with your requested items.
2. **Three Action Choices**:
   - **Accept**: Agrees to terms and transitions status to *Deal Accepted*. Launches celebratory confetti particles!
   - **Decline**: Rejects the trade terms.
   - **Counter**: Opens the interactive **Counter-Offer Modal**. Add or remove items from either side, adjust the balance parity meter, write a counter note, and send back.
3. **Audit History Log**: Both parties can view Round 1, Round 2, and ongoing negotiation audit logs.

---

### 2.6 MapKit Safe Exchange Zones (Safe Zones Tab)
1. Tap the **"Safe Zones"** tab in the main tab bar.
2. View Apple Maps annotations for verified exchange spots:
   - **SLIIT Computing Hub Safe Trade Booth** (Faculty of Computing, Malabe)
   - **Mission Police Station Barter Lot** (San Francisco, CA)
   - **Powell Station Transit Security Mezzanine**
   - **UC Berkeley ASUC Student Union Safe Hub**
3. Tap any marker to view walking/driving distance from your current location, CCTV surveillance features, security personnel hours, and contact phone numbers.
4. Tap **"Select Zone"** to assign that safe location directly to your active trade!

---

### 2.7 In-Trade Chat & Completed Trades
1. In any proposal detail view, tap **"In-Trade Discussion"** to launch the proposal-linked real-time messaging chat.
2. Coordinate meetup times, parking stalls, or item testing without leaving the app.
3. Once items have been physically swapped at the Safe Zone, tap **"Confirm Handoff & Complete Trade"**.
4. Both traders can submit star ratings and written reviews, which appear on the public **Trust Profile**.

---

### 2.8 App Settings & Persistence Management
1. Tap the **Profile** tab and tap the **Gear icon** (top right).
2. **Appearance Mode**: Toggle between *System Auto*, *Dark Mode*, and *Light Mode*.
3. **Accessibility**: Toggle haptic feedback engine and enhanced high contrast mode.
4. **Data Persistence Management**: View total storage size in bytes and reset to default seed catalog if desired.
5. **Network Connectivity**: View live connection status and trigger force cloud synchronization.
