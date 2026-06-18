import Foundation

struct AlarmSound: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let fileName: String?
    let category: SoundCategory
    var isCustom: Bool { fileName == nil }

    enum SoundCategory: String, CaseIterable, Codable {
        case classics = "Clasicos"
        case ambient = "Ambientes"
        case strong = "Fuertes"
        case melodies = "Melodias"
        case nature = "Naturaleza"
        case tech = "Tecnologia"
        case custom = "Mis sonidos"

        var icon: String {
            switch self {
            case .classics: return "music.note.list"
            case .ambient: return "wind"
            case .strong: return "exclamationmark.2"
            case .melodies: return "music.quarternote.3"
            case .nature: return "leaf"
            case .tech: return "gearshape.2"
            case .custom: return "music.mic"
            }
        }
    }

    static let allSounds: [AlarmSound] = [
        AlarmSound(id: "alarma_clasica", name: "Alarma clasica", fileName: "alarma_clasica", category: .classics),
        AlarmSound(id: "timbre_antiguo", name: "Timbre antiguo", fileName: "timbre_antiguo", category: .classics),
        AlarmSound(id: "campana", name: "Campana", fileName: "campana", category: .classics),
        AlarmSound(id: "carillon", name: "Carillon", fileName: "carillon", category: .classics),
        AlarmSound(id: "despertador", name: "Despertador", fileName: "despertador", category: .classics),
        AlarmSound(id: "pulso", name: "Pulso", fileName: "pulso", category: .classics),

        AlarmSound(id: "bosque", name: "Bosque", fileName: "bosque", category: .ambient),
        AlarmSound(id: "lluvia", name: "Lluvia", fileName: "lluvia", category: .ambient),
        AlarmSound(id: "olas", name: "Olas", fileName: "olas", category: .ambient),
        AlarmSound(id: "brisa", name: "Brisa", fileName: "brisa", category: .ambient),
        AlarmSound(id: "murmullo", name: "Murmullo", fileName: "murmullo", category: .ambient),

        AlarmSound(id: "emergencia", name: "Emergencia", fileName: "emergencia", category: .strong),
        AlarmSound(id: "sirena", name: "Sirena", fileName: "sirena", category: .strong),
        AlarmSound(id: "alarma_fuerte", name: "Alarma fuerte", fileName: "alarma_fuerte", category: .strong),
        AlarmSound(id: "bocina", name: "Bocina", fileName: "bocina", category: .strong),
        AlarmSound(id: "martillo", name: "Martillo", fileName: "martillo", category: .strong),
        AlarmSound(id: "alarma_max", name: "Alarma max", fileName: "alarma_max", category: .strong),

        AlarmSound(id: "melodia", name: "Melodia", fileName: "melodia", category: .melodies),
        AlarmSound(id: "tono_suave", name: "Tono suave", fileName: "tono_suave", category: .melodies),
        AlarmSound(id: "piano", name: "Piano", fileName: "piano", category: .melodies),
        AlarmSound(id: "arpa", name: "Arpa", fileName: "arpa", category: .melodies),
        AlarmSound(id: "alegre", name: "Alegre", fileName: "alegre", category: .melodies),

        AlarmSound(id: "amanecer", name: "Amanecer", fileName: "amanecer", category: .nature),
        AlarmSound(id: "sol_naciente", name: "Sol naciente", fileName: "sol_naciente", category: .nature),
        AlarmSound(id: "naturaleza", name: "Naturaleza", fileName: "naturaleza", category: .nature),
        AlarmSound(id: "rio", name: "Rio", fileName: "rio", category: .nature),
        AlarmSound(id: "viento", name: "Viento", fileName: "viento", category: .nature),

        AlarmSound(id: "digital_1", name: "Digital", fileName: "digital_1", category: .tech),
        AlarmSound(id: "radar", name: "Radar", fileName: "radar", category: .tech),
        AlarmSound(id: "laser", name: "Laser", fileName: "laser", category: .tech),
        AlarmSound(id: "sensor", name: "Sensor", fileName: "sensor", category: .tech),
        AlarmSound(id: "codigo", name: "Codigo", fileName: "codigo", category: .tech),
    ]

    static func sounds(for category: SoundCategory) -> [AlarmSound] {
        allSounds.filter { $0.category == category }
    }

    static func sound(id: String) -> AlarmSound? {
        allSounds.first { $0.id == id }
    }
}
