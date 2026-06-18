import Foundation

struct AlarmSound: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let fileName: String?
    let category: SoundCategory
    var isCustom: Bool { fileName == nil }

    enum SoundCategory: String, CaseIterable, Codable {
        case classics = "Melodías"
        case ambient = "Ambientes"
        case strong = "Fuertes"
        case custom = "Mis sonidos"

        var icon: String {
            switch self {
            case .classics: return "music.note"
            case .ambient: return "wind"
            case .strong: return "exclamationmark.2"
            case .custom: return "music.mic"
            }
        }
    }

    static let allSounds: [AlarmSound] = [
        AlarmSound(id: "amanecer", name: "Amanecer", fileName: "amanecer", category: .classics),
        AlarmSound(id: "melodia", name: "Melodía", fileName: "melodia", category: .classics),
        AlarmSound(id: "bosque", name: "Bosque", fileName: "bosque", category: .ambient),
        AlarmSound(id: "suave", name: "Suave", fileName: "suave", category: .ambient),
        AlarmSound(id: "energia", name: "Energía", fileName: "energia", category: .strong),
        AlarmSound(id: "clasico", name: "Clásico", fileName: "clasico", category: .classics),
    ]

    static func sounds(for category: SoundCategory) -> [AlarmSound] {
        if category == .custom { return AlarmManager.shared.customSounds }
        return allSounds.filter { $0.category == category }
    }

    static func sound(id: String) -> AlarmSound? {
        allSounds.first { $0.id == id }
        ?? AlarmManager.shared.customSounds.first { $0.id == id }
    }
}
