import UserNotifications
import UIKit

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
    }

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func scheduleAlarm(_ alarm: Alarm, isUltimatum: Bool = false, isSnooze: Bool = false) {
        cancelAlarm(alarm)
        guard alarm.isEnabled else { return }
        if alarm.skipNext && !isSnooze { return }
        guard let fireDate = alarm.nextFireDate else { return }

        let soundName = isUltimatum ? alarm.ultimatumSoundName : alarm.soundName
        let content = UNMutableNotificationContent()
        content.title = alarm.title
        content.body = "Resuelve el problema para desactivar"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.userInfo = [
            "alarm_id": alarm.id.uuidString,
            "math_difficulty": alarm.mathDifficulty.rawValue,
            "snooze_minutes": alarm.snoozeMinutes,
            "max_snoozes": alarm.maxSnoozes,
            "has_ultimatum": alarm.hasUltimatum,
            "ultimatum_sound": alarm.ultimatumSoundName,
        ]

        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "alarm_\(alarm.id.uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Error scheduling alarm: \(error)")
            }
        }
    }

    func scheduleSnooze(alarm: Alarm, snoozeMinutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = "\(alarm.title) (pospuesta)"
        content.body = "Resuelve el problema para desactivar"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.userInfo = [
            "alarm_id": alarm.id.uuidString,
            "is_snooze": true,
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(snoozeMinutes * 60), repeats: false)
        let request = UNNotificationRequest(
            identifier: "snooze_\(alarm.id.uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Error scheduling snooze: \(error)")
            }
        }
    }

    func cancelAlarm(_ alarm: Alarm) {
        center.removePendingNotificationRequests(withIdentifiers: [
            "alarm_\(alarm.id.uuidString)",
            "snooze_\(alarm.id.uuidString)",
        ])
    }

    func setupNotificationCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Posponer",
            options: .foreground
        )
        let category = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner, .list])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let alarmID = userInfo["alarm_id"] as? String,
           let alarm = AlarmManager.shared.alarms.first(where: { $0.id.uuidString == alarmID }) {
            if response.actionIdentifier == "SNOOZE_ACTION" {
                AlarmManager.shared.snoozeAlarm(alarm)
            } else {
                AlarmManager.shared.triggerAlarm(alarm)
            }
        }
        completionHandler()
    }
}
