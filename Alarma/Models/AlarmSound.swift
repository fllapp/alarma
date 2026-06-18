import Foundation

struct AlarmSound: Identifiable, Equatable {
    let id: String
    let name: String
    let systemSoundID: UInt32
    let category: SoundCategory

    enum SoundCategory: String, CaseIterable {
        case classics = "Clasicos"
        case ambient = "Ambientes"
        case strong = "Fuertes"
        case melodies = "Melodias"
        case nature = "Naturaleza"
        case tech = "Tecnologia"

        var icon: String {
            switch self {
            case .classics: return "music.note.list"
            case .ambient: return "wind"
            case .strong: return "exclamationmark.2"
            case .melodies: return "music.quarternote.3"
            case .nature: return "leaf"
            case .tech: return "gearshape.2"
            }
        }
    }

    static let allSounds: [AlarmSound] = [
        AlarmSound(id: "marimba", name: "Marimba", systemSoundID: 1006, category: .classics),
        AlarmSound(id: "alarm", name: "Alarma clasica", systemSoundID: 1007, category: .classics),
        AlarmSound(id: "bell", name: "Campana", systemSoundID: 1008, category: .classics),
        AlarmSound(id: "chime", name: "Carillon", systemSoundID: 1009, category: .classics),
        AlarmSound(id: "digital", name: "Digital", systemSoundID: 1010, category: .tech),
        AlarmSound(id: "radar", name: "Radar", systemSoundID: 1011, category: .tech),
        AlarmSound(id: "xylophone", name: "Xilofono", systemSoundID: 1012, category: .classics),
        AlarmSound(id: "bells", name: "Cascabeles", systemSoundID: 1013, category: .ambient),
        AlarmSound(id: "horn", name: "Bocina", systemSoundID: 1014, category: .strong),
        AlarmSound(id: "siren", name: "Sirena", systemSoundID: 1015, category: .strong),

        AlarmSound(id: "dawn", name: "Amanecer", systemSoundID: 1000, category: .nature),
        AlarmSound(id: "gentle", name: "Suave", systemSoundID: 1001, category: .ambient),
        AlarmSound(id: "wake", name: "Despertar", systemSoundID: 1002, category: .ambient),
        AlarmSound(id: "sunrise", name: "Sol naciente", systemSoundID: 1003, category: .nature),
        AlarmSound(id: "breeze", name: "Brisa", systemSoundID: 1004, category: .nature),
        AlarmSound(id: "spring", name: "Primavera", systemSoundID: 1005, category: .nature),
    ]

    static func sounds(for category: SoundCategory) -> [AlarmSound] {
        allSounds.filter { $0.category == category }
    }
}
