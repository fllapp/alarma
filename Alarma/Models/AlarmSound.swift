import Foundation

struct ToneConfig {
    enum Pattern: String, Codable, CaseIterable {
        case continuous = "Continuo"
        case siren = "Sirena"
        case pulse = "Pulsante"
        case dualTone = "Doble tono"
    }

    let frequencies: [Double]
    let pattern: Pattern
    let cadence: Double
}

struct AlarmSound: Identifiable, Equatable {
    let id: String
    let name: String
    let systemSoundID: UInt32
    let category: SoundCategory
    let toneConfig: ToneConfig

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
        AlarmSound(id: "marimba", name: "Marimba", systemSoundID: 1006, category: .classics, toneConfig: ToneConfig(frequencies: [440, 660], pattern: .dualTone, cadence: 0.3)),
        AlarmSound(id: "alarm", name: "Alarma clasica", systemSoundID: 1007, category: .classics, toneConfig: ToneConfig(frequencies: [800], pattern: .siren, cadence: 1.5)),
        AlarmSound(id: "bell", name: "Campana", systemSoundID: 1008, category: .classics, toneConfig: ToneConfig(frequencies: [1200], pattern: .pulse, cadence: 2.0)),
        AlarmSound(id: "chime", name: "Carillon", systemSoundID: 1009, category: .classics, toneConfig: ToneConfig(frequencies: [880, 1100], pattern: .dualTone, cadence: 0.8)),
        AlarmSound(id: "digital", name: "Digital", systemSoundID: 1010, category: .tech, toneConfig: ToneConfig(frequencies: [600], pattern: .pulse, cadence: 3.0)),
        AlarmSound(id: "radar", name: "Radar", systemSoundID: 1011, category: .tech, toneConfig: ToneConfig(frequencies: [500], pattern: .pulse, cadence: 1.0)),
        AlarmSound(id: "xylophone", name: "Xilofono", systemSoundID: 1012, category: .classics, toneConfig: ToneConfig(frequencies: [520, 780, 1040], pattern: .continuous, cadence: 0)),
        AlarmSound(id: "bells", name: "Cascabeles", systemSoundID: 1013, category: .ambient, toneConfig: ToneConfig(frequencies: [1400, 1600], pattern: .dualTone, cadence: 0.2)),
        AlarmSound(id: "horn", name: "Bocina", systemSoundID: 1014, category: .strong, toneConfig: ToneConfig(frequencies: [220], pattern: .continuous, cadence: 0)),
        AlarmSound(id: "siren", name: "Sirena", systemSoundID: 1015, category: .strong, toneConfig: ToneConfig(frequencies: [400], pattern: .siren, cadence: 1.0)),

        AlarmSound(id: "dawn", name: "Amanecer", systemSoundID: 1000, category: .nature, toneConfig: ToneConfig(frequencies: [380, 500], pattern: .continuous, cadence: 0)),
        AlarmSound(id: "gentle", name: "Suave", systemSoundID: 1001, category: .ambient, toneConfig: ToneConfig(frequencies: [440], pattern: .continuous, cadence: 0)),
        AlarmSound(id: "wake", name: "Despertar", systemSoundID: 1002, category: .ambient, toneConfig: ToneConfig(frequencies: [550, 700], pattern: .dualTone, cadence: 1.0)),
        AlarmSound(id: "sunrise", name: "Sol naciente", systemSoundID: 1003, category: .nature, toneConfig: ToneConfig(frequencies: [350, 440, 550], pattern: .continuous, cadence: 0)),
        AlarmSound(id: "breeze", name: "Brisa", systemSoundID: 1004, category: .nature, toneConfig: ToneConfig(frequencies: [300], pattern: .siren, cadence: 4.0)),
        AlarmSound(id: "spring", name: "Primavera", systemSoundID: 1005, category: .nature, toneConfig: ToneConfig(frequencies: [480, 620, 780], pattern: .continuous, cadence: 0)),

        AlarmSound(id: "urgent", name: "Urgente", systemSoundID: 1006, category: .strong, toneConfig: ToneConfig(frequencies: [900, 1200], pattern: .dualTone, cadence: 0.15)),
        AlarmSound(id: "alert", name: "Alerta maxima", systemSoundID: 1007, category: .strong, toneConfig: ToneConfig(frequencies: [1000], pattern: .siren, cadence: 0.5)),
        AlarmSound(id: "pulsefast", name: "Pulso rapido", systemSoundID: 1008, category: .tech, toneConfig: ToneConfig(frequencies: [700], pattern: .pulse, cadence: 5.0)),
        AlarmSound(id: "beeps", name: "Pitidos", systemSoundID: 1009, category: .tech, toneConfig: ToneConfig(frequencies: [800, 1000], pattern: .pulse, cadence: 4.0)),

        AlarmSound(id: "melody1", name: "Melodia suave", systemSoundID: 1010, category: .melodies, toneConfig: ToneConfig(frequencies: [392, 440, 523, 587], pattern: .continuous, cadence: 0)),
        AlarmSound(id: "melody2", name: "Cancion de cuna", systemSoundID: 1011, category: .melodies, toneConfig: ToneConfig(frequencies: [330, 392, 440, 523], pattern: .continuous, cadence: 0)),
        AlarmSound(id: "melody3", name: "Alegre", systemSoundID: 1012, category: .melodies, toneConfig: ToneConfig(frequencies: [523, 659, 784], pattern: .dualTone, cadence: 0.5)),
        AlarmSound(id: "melody4", name: "Jazz", systemSoundID: 1013, category: .melodies, toneConfig: ToneConfig(frequencies: [262, 330, 392, 523], pattern: .continuous, cadence: 0)),
        AlarmSound(id: "melody5", name: "Clasica", systemSoundID: 1014, category: .melodies, toneConfig: ToneConfig(frequencies: [440, 554, 659], pattern: .continuous, cadence: 0)),
        AlarmSound(id: "melody6", name: "Energia", systemSoundID: 1015, category: .melodies, toneConfig: ToneConfig(frequencies: [660, 880, 1047], pattern: .dualTone, cadence: 0.3)),
    ]

    static func sounds(for category: SoundCategory) -> [AlarmSound] {
        allSounds.filter { $0.category == category }
    }
}
