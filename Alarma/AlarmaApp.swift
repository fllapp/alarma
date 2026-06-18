import SwiftUI

@main
struct AlarmaApp: App {
    @StateObject private var alarmManager = AlarmManager.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alarmManager)
                .preferredColorScheme(.dark)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        AlarmManager.shared.requestNotificationPermission()
        AlarmManager.shared.setupAudioSession()

        if let localNote = launchOptions?[.localNotification] as? UILocalNotification,
           let userInfo = localNote.userInfo,
           let alarmID = userInfo["alarm_id"] as? String,
           let alarm = AlarmManager.shared.alarms.first(where: { $0.id.uuidString == alarmID }) {
            AlarmManager.shared.triggerAlarm(alarm)
        }

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AlarmManager.shared.setupAudioSession()
        AlarmManager.shared.checkPendingAlarms()
    }
}
