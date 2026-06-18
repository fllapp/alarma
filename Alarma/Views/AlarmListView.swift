import SwiftUI

struct AlarmListView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @State private var showingAddSheet = false
    @State private var editingAlarm: Alarm?

    var body: some View {
        NavigationView {
            List {
                if alarmManager.alarms.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "alarm")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.textSecondary.opacity(0.3))
                        VStack(spacing: 8) {
                            Text("Sin alarmas")
                                .font(.title2.bold())
                                .foregroundColor(AppColors.textSecondary)
                            Text("Crea tu primera alarma")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 100)
                    .listRowBackground(Color.clear)
                }

                ForEach(alarmManager.alarms) { alarm in
                    AlarmRowView(alarm: alarm)
                        .environmentObject(alarmManager)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture { editingAlarm = alarm }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                alarmManager.deleteAlarm(alarm)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                alarmManager.toggleAlarm(alarm)
                            } label: {
                                Label(alarm.isEnabled ? "Desactivar" : "Activar", systemImage: alarm.isEnabled ? "bell.slash" : "bell")
                            }
                            .tint(alarm.isEnabled ? .orange : .green)
                        }
                }
            }
            .listStyle(.plain)
            .background(AppColors.background)
            .navigationTitle("Alarmas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AlarmDetailView(alarm: nil)
                    .environmentObject(alarmManager)
            }
            .sheet(item: $editingAlarm) { alarm in
                AlarmDetailView(alarm: alarm)
                    .environmentObject(alarmManager)
            }
        }
    }
}

struct AlarmRowView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    let alarm: Alarm

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(alarm.timeString)
                    .font(AppFonts.timeFont(size: 42))
                    .foregroundColor(alarm.isEnabled ? .white : .gray)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(alarm.title)
                        .font(.subheadline.bold())
                        .foregroundColor(alarm.isEnabled ? .white.opacity(0.9) : .gray)

                    if !alarm.daysOfWeek.isEmpty {
                        Text("* \(alarm.dayNames)")
                            .font(.caption)
                            .foregroundColor(alarm.isEnabled ? .gray : .gray.opacity(0.5))
                    }

                    if alarm.skipNext {
                        Text("SALTAR")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.accentOrange.opacity(0.8))
                            .cornerRadius(4)
                    }

                    if alarm.gradualWakeUpDuration > 0 {
                        Image(systemName: "speaker.wave.2")
                            .font(.caption2)
                            .foregroundColor(AppColors.accentBlue)
                    }

                    if alarm.snoozeStyle == .swipe {
                        Image(systemName: "hand.draw")
                            .font(.caption2)
                            .foregroundColor(AppColors.accentOrange)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(alarm.isEnabled ? AppColors.accentBlue.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )

            Spacer()

            Menu {
                Button {
                    alarmManager.toggleSkipNext(alarm)
                } label: {
                    Label(
                        alarm.skipNext ? "No saltar siguiente" : "Saltar siguiente",
                        systemImage: alarm.skipNext ? "forward.fill" : "forward"
                    )
                }

                Divider()

                Button(role: .destructive) {
                    alarmManager.deleteAlarm(alarm)
                } label: {
                    Label("Eliminar", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(8)
            }

            CustomToggle(isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in alarmManager.toggleAlarm(alarm) }
            ))
            .padding(.trailing, 16)
        }
        .padding(.horizontal)
    }
}

struct CustomToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        ZStack {
            Capsule()
                .fill(isOn ? AppColors.accentBlue : Color.gray.opacity(0.4))
                .frame(width: 52, height: 30)

            Circle()
                .fill(Color.white)
                .frame(width: 26, height: 26)
                .offset(x: isOn ? 11 : -11)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isOn)
        }
        .onTapGesture {
            isOn.toggle()
        }
    }
}
