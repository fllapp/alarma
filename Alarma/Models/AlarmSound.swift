import Foundation

struct AlarmSound: Identifiable, Equatable {
    let id: String
    let name: String
    let systemSoundID: UInt32

    static let allSounds: [AlarmSound] = [
        AlarmSound(id: "marimba", name: "Marimba", systemSoundID: 1006),
        AlarmSound(id: "alarm", name: "Alarma clasica", systemSoundID: 1007),
        AlarmSound(id: "bell", name: "Campana", systemSoundID: 1008),
        AlarmSound(id: "chime", name: "Carillon", systemSoundID: 1009),
        AlarmSound(id: "digital", name: "Digital", systemSoundID: 1010),
        AlarmSound(id: "radar", name: "Radar", systemSoundID: 1011),
        AlarmSound(id: "xylophone", name: "Xilofono", systemSoundID: 1012),
        AlarmSound(id: "bells", name: "Cascabeles", systemSoundID: 1013),
        AlarmSound(id: "horn", name: "Bocina", systemSoundID: 1014),
        AlarmSound(id: "siren", name: "Sirena", systemSoundID: 1015),
    ]
}
