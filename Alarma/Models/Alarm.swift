import Foundation

struct Alarm: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var hour: Int
    var minute: Int
    var daysOfWeek: Set<Int>
    var isEnabled: Bool
    var soundName: String
    var snoozeMinutes: Int
    var maxSnoozes: Int
    var hasUltimatum: Bool
    var ultimatumSoundName: String
    var mathEnabled: Bool
    var mathDifficulty: MathDifficulty
    var skipNext: Bool
    var snoozeStyle: SnoozeStyle
    var gradualWakeUpDuration: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String = "Alarma",
        hour: Int = 7,
        minute: Int = 0,
        daysOfWeek: Set<Int> = [],
        isEnabled: Bool = true,
        soundName: String = "marimba",
        snoozeMinutes: Int = 5,
        maxSnoozes: Int = 3,
        hasUltimatum: Bool = true,
        ultimatumSoundName: String = "alarm",
        mathEnabled: Bool = true,
        mathDifficulty: MathDifficulty = .medium,
        skipNext: Bool = false,
        snoozeStyle: SnoozeStyle = .button,
        gradualWakeUpDuration: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.hour = hour
        self.minute = minute
        self.daysOfWeek = daysOfWeek
        self.isEnabled = isEnabled
        self.soundName = soundName
        self.snoozeMinutes = snoozeMinutes
        self.maxSnoozes = maxSnoozes
        self.hasUltimatum = hasUltimatum
        self.ultimatumSoundName = ultimatumSoundName
        self.mathEnabled = mathEnabled
        self.mathDifficulty = mathDifficulty
        self.skipNext = skipNext
        self.snoozeStyle = snoozeStyle
        self.gradualWakeUpDuration = gradualWakeUpDuration
        self.createdAt = createdAt
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }

    var dayNames: String {
        let names = ["dom", "lun", "mar", "mie", "jue", "vie", "sab"]
        if daysOfWeek.count == 7 { return "Todos los dias" }
        if daysOfWeek == Set([1, 7]) { return "Fines de semana" }
        if daysOfWeek == Set([2, 3, 4, 5, 6]) { return "Dias de semana" }
        return daysOfWeek.sorted().map { names[$0 - 1] }.joined(separator: " ")
    }

    var nextFireDate: Date? {
        let cal = Calendar.current
        let now = Date()
        let todayComponents = cal.dateComponents([.year, .month, .day], from: now)
        guard var checkDate = cal.date(from: todayComponents) else { return nil }
        checkDate = cal.date(bySettingHour: hour, minute: minute, second: 0, of: checkDate) ?? checkDate

        for dayOffset in 0..<14 {
            let testDate = cal.date(byAdding: .day, value: dayOffset, to: checkDate)!
            let weekday = cal.component(.weekday, from: testDate)
            if daysOfWeek.contains(weekday) {
                if dayOffset == 0 && testDate <= now {
                    continue
                }
                return testDate
            }
        }
        return nil
    }
}

enum MathDifficulty: String, Codable, CaseIterable {
    case easy = "Facil"
    case medium = "Media"
    case hard = "Dificil"

    var level: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

enum SnoozeStyle: String, Codable, CaseIterable {
    case button = "Boton"
    case swipe = "Deslizar"

    var icon: String {
        switch self {
        case .button: return "hand.tap"
        case .swipe: return "hand.draw"
        }
    }
}
