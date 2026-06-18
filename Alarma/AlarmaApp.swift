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
        return true
    }
}
