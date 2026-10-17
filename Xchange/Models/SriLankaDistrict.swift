//
//  SriLankaDistrict.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Official 25 Administrative Districts of Sri Lanka with Province mapping
//  and intelligent town/city location detection
//

import Foundation

public enum SriLankaDistrict: String, CaseIterable, Identifiable, Codable, Hashable {
    case all = "All Sri Lanka"
    case ampara = "Ampara"
    case anuradhapura = "Anuradhapura"
    case badulla = "Badulla"
    case batticaloa = "Batticaloa"
    case colombo = "Colombo"
    case galle = "Galle"
    case gampaha = "Gampaha"
    case hambantota = "Hambantota"
    case jaffna = "Jaffna"
    case kalutara = "Kalutara"
    case kandy = "Kandy"
    case kegalle = "Kegalle"
    case kilinochchi = "Kilinochchi"
    case kurunegala = "Kurunegala"
    case mannar = "Mannar"
    case matale = "Matale"
    case matara = "Matara"
    case monaragala = "Monaragala"
    case mullaitivu = "Mullaitivu"
    case nuwaraEliya = "Nuwara Eliya"
    case polonnaruwa = "Polonnaruwa"
    case puttalam = "Puttalam"
    case ratnapura = "Ratnapura"
    case trincomalee = "Trincomalee"
    case vavuniya = "Vavuniya"
    
    public var id: String { rawValue }
    
    /// The 25 official administrative districts of Sri Lanka (excluding "All Sri Lanka")
    public static var allDistricts: [SriLankaDistrict] {
        allCases.filter { $0 != .all }
    }
    
    /// User-friendly label for UI pickers and headers
    public var displayLabel: String {
        switch self {
        case .all:
            return "All Sri Lanka (Entire Country)"
        default:
            return "\(rawValue) District"
        }
    }
    
    /// Province of Sri Lanka to which the district belongs
    public var province: String {
        switch self {
        case .all:
            return "Islandwide"
        case .colombo, .gampaha, .kalutara:
            return "Western Province"
        case .kandy, .matale, .nuwaraEliya:
            return "Central Province"
        case .galle, .matara, .hambantota:
            return "Southern Province"
        case .jaffna, .kilinochchi, .mannar, .mullaitivu, .vavuniya:
            return "Northern Province"
        case .batticaloa, .ampara, .trincomalee:
            return "Eastern Province"
        case .kurunegala, .puttalam:
            return "North Western Province"
        case .anuradhapura, .polonnaruwa:
            return "North Central Province"
        case .badulla, .monaragala:
            return "Uva Province"
        case .ratnapura, .kegalle:
            return "Sabaragamuwa Province"
        }
    }
    
    /// Matches or converts a string (like "colombo", "Kandy District", etc.) into a SriLankaDistrict
    public static func fromString(_ name: String) -> SriLankaDistrict {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if clean.isEmpty || clean.contains("all") || clean.contains("entire") || clean.contains("islandwide") {
            return .all
        }
        for district in allCases {
            if clean.contains(district.rawValue.lowercased()) {
                return district
            }
        }
        if let detected = detectDistrict(from: name),
           let match = allCases.first(where: { $0.rawValue.caseInsensitiveCompare(detected) == .orderedSame }) {
            return match
        }
        return .colombo
    }
    
    /// Intelligent district extraction from a location string (e.g. "Malabe, Colombo", "Negombo, Sri Lanka", "Galle Fort")
    public static func detectDistrict(from location: String) -> String? {
        let lower = location.lowercased()
        
        // 1. Check direct district name match
        for district in allDistricts {
            let distLower = district.rawValue.lowercased()
            if lower.contains(distLower) {
                return district.rawValue
            }
        }
        
        // 2. Comprehensive mapping of well-known Sri Lankan cities, suburbs, and towns to their respective districts
        let townMapping: [(towns: [String], district: SriLankaDistrict)] = [
            // Colombo District
            ([
                "malabe", "dehiwala", "mount lavinia", "nugegoda", "maharagama",
                "rajagiriya", "battaramulla", "kotte", "sri jayawardenepura",
                "moratuwa", "homagama", "kaduwela", "kesbewa", "piliyandala",
                "boralesgamuwa", "kolonnawa", "wellawatte", "bambalapitiya",
                "kollupitiya", "cinamon gardens", "borella", "maradana", "pettah",
                "fort", "havelock", "kirulapone", "narahenpita", "dematagoda",
                "sliit", "thimbirigasyaya", "panagoda", "godagama", "padukka",
                "meegoda", "hanwella", "avissawella"
            ], .colombo),
            
            // Gampaha District
            ([
                "negombo", "kelaniya", "wattala", "ja-ela", "kadawatha",
                "minuwangoda", "mirigama", "ragama", "biyagama", "kiribathgoda",
                "seeduwa", "divulapitiya", "katunayake", "peliyagoda", "delgoda",
                "veyangoda", "dompe", "nittambuwa"
            ], .gampaha),
            
            // Kalutara District
            ([
                "panadura", "horana", "beruwala", "matugama", "aluthgama",
                "wadduwa", "bandaragama", "ingiriya", "bulathsinhala", "dodangoda"
            ], .kalutara),
            
            // Kandy District
            ([
                "peradeniya", "gampola", "katugastota", "kundasale", "gelioya",
                "digana", "nawalapitiya", "kadugannawa", "akurana", "wattegama",
                "teldeniya", "pilimathalawa"
            ], .kandy),
            
            // Matale District
            ([
                "dambulla", "sigiriya", "ukuwela", "rattota", "galewela", "pallepola"
            ], .matale),
            
            // Nuwara Eliya District
            ([
                "hatton", "talawakelle", "gregory lake", "maskeliya", "nallathanniya",
                "kotagala", "ginigathhena", "ragala", "walapane"
            ], .nuwaraEliya),
            
            // Galle District
            ([
                "galle fort", "hikkaduwa", "karapitiya", "ambalangoda", "bentota",
                "unawatuna", "baddegama", "elpitiya", "ahungalla", "koggala"
            ], .galle),
            
            // Matara District
            ([
                "weligama", "mirissa", "dikwella", "akuressa", "deniyaya",
                "kamburupitiya", "hakmana", "devinuwara", "dondra"
            ], .matara),
            
            // Hambantota District
            ([
                "tangalle", "beliatta", "tissamaharama", "ambalantota", "kataragama",
                "weeraketiya", "walasmulla", "sooriyawewa"
            ], .hambantota),
            
            // Jaffna District
            ([
                "chavakachcheri", "point pedro", "valvettithurai", "nallur", "kopay",
                "karainagar", "chunnakam", "manipay", "vaddukoddai"
            ], .jaffna),
            
            // Kilinochchi District
            ([
                "pallai", "paranthan", "poonakary"
            ], .kilinochchi),
            
            // Mannar District
            ([
                "pesalai", "talaimannar", "madhu", "murunkan"
            ], .mannar),
            
            // Vavuniya District
            ([
                "cheddekulam", "nedunkeni"
            ], .vavuniya),
            
            // Mullaitivu District
            ([
                "pudukudiyiruppu", "oddusuddan", "mankulam"
            ], .mullaitivu),
            
            // Batticaloa District
            ([
                "kattankudy", "eravur", "valachchenai", "kalkudah", "pasikudah"
            ], .batticaloa),
            
            // Ampara District
            ([
                "kalmunai", "sainthamaruthu", "akkaraipattu", "sammanthurai", "arugam bay",
                "dehiattakandiya", "pothuvil"
            ], .ampara),
            
            // Trincomalee District
            ([
                "kinniya", "muttur", "nilaveli", "uppuveli", "kantale"
            ], .trincomalee),
            
            // Kurunegala District
            ([
                "kuliyapitiya", "narammala", "pannala", "wariyapola", "bingiriya",
                "polgahawela", "alawwa", "giriulla", "maho", "ibbagamuwa"
            ], .kurunegala),
            
            // Puttalam District
            ([
                "chilaw", "marawila", "wennappuwa", "dankotuwa", "an繁amaduwa",
                "kalpitiya", "nattandiya", "mahawewa"
            ], .puttalam),
            
            // Anuradhapura District
            ([
                "mihintale", "kekirawa", "medawachchiya", "tambuttegama", "eppawala",
                "galnewa", "noctchiyagama"
            ], .anuradhapura),
            
            // Polonnaruwa District
            ([
                "kaduruwela", "medirigiriya", "hingurakgoda", "habarana"
            ], .polonnaruwa),
            
            // Badulla District
            ([
                "bandarawela", "ella", "welimada", "haputale", "diyatalawa",
                "hali ela", "passara", "mahiyanganaya"
            ], .badulla),
            
            // Monaragala District
            ([
                "wellawaya", "buttala", "bibile", "kataragama road", "moneragala"
            ], .monaragala),
            
            // Ratnapura District
            ([
                "balangoda", "embilipitiya", "pelmadulla", "kuruwita", "eheliyagoda",
                "kithulgala", "rakwana"
            ], .ratnapura),
            
            // Kegalle District
            ([
                "mawanella", "warakapola", "ruwanwella", "yatiyantota", "deraniyagala",
                "rambukkana", "galigamuwa", "aranayaka"
            ], .kegalle)
        ]
        
        for mapping in townMapping {
            if mapping.towns.contains(where: { lower.contains($0) }) {
                return mapping.district.rawValue
            }
        }
        
        return nil
    }
}
