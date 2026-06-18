import SwiftUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @State private var permissionDenied = false

    var body: some View {
        ZStack {
            AlarmListView()
                .environmentObject(alarmManager)

            if alarmManager.showAlarmView, let alarm = alarmManager.activeAlarm {
                AlarmActiveView(alarm: alarm, isUltimatum: alarmManager.isUltimatum)
                    .environmentObject(alarmManager)
                    .transition(.move(edge: .bottom))
                    .zIndex(100)
            }

            if permissionDenied {
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.slash.fill")
                            .foregroundColor(.white)
                        Text("Permisos de notificacion desactivados")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Button("Abrir Ajustes") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    }
                    .padding()
                    .background(AppColors.accentRed.opacity(0.9))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    Spacer()
                }
                .zIndex(50)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: alarmManager.showAlarmView)
        .onAppear {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    permissionDenied = settings.authorizationStatus == .denied
                }
            }
        }
    }
}
