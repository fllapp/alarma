import SwiftUI

struct ContentView: View {
    @EnvironmentObject var alarmManager: AlarmManager

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
        }
        .animation(.easeInOut(duration: 0.3), value: alarmManager.showAlarmView)
    }
}
