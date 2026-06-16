import Foundation

final class PersistenceService {
    static let shared = PersistenceService()
    private let key = "saved_alarms"

    private init() {}

    func save(alarms: [Alarm]) {
        do {
            let data = try JSONEncoder().encode(alarms)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error saving alarms: \(error)")
        }
    }

    func load() -> [Alarm] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([Alarm].self, from: data)
        } catch {
            print("Error loading alarms: \(error)")
            return []
        }
    }
}
