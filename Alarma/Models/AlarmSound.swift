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

        var icon: String {
            switch self {
            case .classics: return "music.note.list"
            case .ambient: return "wind"
            case .strong: return "exclamationmark.2"
            case .melodies: return "music.quarternote.3"
            }
        }
    }

    static let allSounds: [AlarmSound] = [
        AlarmSound(id: "marimba", name: "Marimba", systemSoundID: 1006, category: .classics),
        AlarmSound(id: "alarm", name: "Alarma clasica", systemSoundID: 1007, category: .classics),
        AlarmSound(id: "bell", name: "Campana", systemSoundID: 1008, category: .classics),
        AlarmSound(id: "chime", name: "Carillon", systemSoundID: 1009, category: .classics),

        AlarmSound(id: "bells", name: "Cascabeles", systemSoundID: 1013, category: .ambient),
        AlarmSound(id: "xylophone", name: "Xilofono", systemSoundID: 1012, category: .ambient),
        AlarmSound(id: "radar", name: "Radar", systemSoundID: 1011, category: .ambient),
        AlarmSound(id: "digital", name: "Digital", systemSoundID: 1010, category: .ambient),

        AlarmSound(id: "horn", name: "Bocina", systemSoundID: 1014, category: .strong),
        AlarmSound(id: "siren", name: "Sirena", systemSoundID: 1015, category: .strong),
        AlarmSound(id: "doorbell", name: "Timbre", systemSoundID: 1016, category: .strong),
        AlarmSound(id: "smoke", name: "Alarma humo", systemSoundID: 1017, category: .strong),

        AlarmSound(id: "fanfare", name: "Fanfarria", systemSoundID: 1018, category: .melodies),
        AlarmSound(id: "harpsichord", name: "Clavecin", systemSoundID: 1019, category: .melodies),
        AlarmSound(id: "piano", name: "Piano", systemSoundID: 1020, category: .melodies),
        AlarmSound(id: "guitar", name: "Guitarra", systemSoundID: 1021, category: .melodies),
    ]

    static func sounds(for category: SoundCategory) -> [AlarmSound] {
        allSounds.filter { $0.category == category }
    }
}
