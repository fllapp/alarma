import SwiftUI

struct AlarmDetailView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @Environment(\.dismiss) private var dismiss

    let editAlarm: Alarm?
    @State private var title: String
    @State private var hour: Int
    @State private var minute: Int
    @State private var daysOfWeek: Set<Int>
    @State private var selectedSound: String
    @State private var snoozeMinutes: Int
    @State private var maxSnoozes: Int
    @State private var hasUltimatum: Bool
    @State private var ultimatumSound: String
    @State private var mathDifficulty: MathDifficulty
    @State private var skipNext: Bool
    @State private var showSoundPicker = false
    @State private var showUltimatumSoundPicker = false

    private var isEditing: Bool { editAlarm != nil }

    init(alarm: Alarm?) {
        editAlarm = alarm
        _title = State(initialValue: alarm?.title ?? "Alarma")
        _hour = State(initialValue: alarm?.hour ?? 7)
        _minute = State(initialValue: alarm?.minute ?? 0)
        _daysOfWeek = State(initialValue: alarm?.daysOfWeek ?? [])
        _selectedSound = State(initialValue: alarm?.soundName ?? "marimba")
        _snoozeMinutes = State(initialValue: alarm?.snoozeMinutes ?? 5)
        _maxSnoozes = State(initialValue: alarm?.maxSnoozes ?? 3)
        _hasUltimatum = State(initialValue: alarm?.hasUltimatum ?? true)
        _ultimatumSound = State(initialValue: alarm?.ultimatumSoundName ?? "alarm")
        _mathDifficulty = State(initialValue: alarm?.mathDifficulty ?? .medium)
        _skipNext = State(initialValue: alarm?.skipNext ?? false)
    }

    var body: some View {
        NavigationView {
            Form {
                timeSection
                daysSection
                soundSection
                mathSection
                snoozeSection
                ultimatumSection
                skipSection
            }
            .navigationTitle(isEditing ? "Editar Alarma" : "Nueva Alarma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") { saveAlarm() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showSoundPicker) {
                SoundPickerView(selectedSound: $selectedSound)
            }
            .sheet(isPresented: $showUltimatumSoundPicker) {
                SoundPickerView(selectedSound: $ultimatumSound)
            }
        }
    }

    private var timeSection: some View {
        Section {
            HStack {
                Spacer()
                DatePicker(
                    "",
                    selection: Binding(
                        get: {
                            Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
                        },
                        set: { date in
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                            hour = comps.hour ?? 7
                            minute = comps.minute ?? 0
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                Spacer()
            }
        } header: {
            Label("Hora", systemImage: "clock")
        }
    }

    private var daysSection: some View {
        Section {
            DaySelectorView(days: $daysOfWeek)
        } header: {
            Label("Repetir", systemImage: "calendar")
        }
    }

    private var soundSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading) {
                    Text(AlarmSound.allSounds.first(where: { $0.id == selectedSound })?.name ?? "Seleccionar")
                        .foregroundColor(.white)
                }
                Spacer()
                Button("Cambiar") { showSoundPicker = true }
                    .font(.subheadline)
            }
        } header: {
            Label("Sonido", systemImage: "music.note")
        }
    }

    private var mathSection: some View {
        Section {
            Picker("Dificultad", selection: $mathDifficulty) {
                ForEach(MathDifficulty.allCases, id: \.self) { diff in
                    Text(diff.rawValue).tag(diff)
                }
            }
        } header: {
            Label("Seguridad matemática", systemImage: "function")
        } footer: {
            Text("Deberás resolver un problema matemático para desactivar la alarma")
        }
    }

    private var snoozeSection: some View {
        Section {
            Stepper("Posponer cada \(snoozeMinutes) min", value: $snoozeMinutes, in: 1...30)
            Stepper("Máx \(maxSnoozes) veces", value: $maxSnoozes, in: 0...10)
        } header: {
            Label("Posponer", systemImage: "pause.circle")
        }
    }

    private var ultimatumSection: some View {
        Section {
            Toggle("Alarma de ultimátum", isOn: $hasUltimatum)
            if hasUltimatum {
                HStack {
                    Text("Sonido final")
                    Spacer()
                    Text(AlarmSound.allSounds.first(where: { $0.id == ultimatumSound })?.name ?? "Seleccionar")
                        .foregroundColor(.secondary)
                    Button("Cambiar") { showUltimatumSoundPicker = true }
                        .font(.subheadline)
                }
            }
        } header: {
            Label("Ultimátum", systemImage: "exclamationmark.triangle")
        } footer: {
            if hasUltimatum {
                Text("Cuando se alcance el límite de posponer, sonará esta alarma final")
            }
        }
    }

    private var skipSection: some View {
        Section {
            Toggle("Saltar próxima alarma", isOn: $skipNext)
        } header: {
            Label("Saltar", systemImage: "forward")
        } footer: {
            Text("La próxima vez que suene se saltará y luego volverá a la normalidad")
        }
    }

    private func saveAlarm() {
        let alarm = Alarm(
            id: editAlarm?.id ?? UUID(),
            title: title,
            hour: hour,
            minute: minute,
            daysOfWeek: daysOfWeek,
            isEnabled: editAlarm?.isEnabled ?? true,
            soundName: selectedSound,
            snoozeMinutes: snoozeMinutes,
            maxSnoozes: maxSnoozes,
            hasUltimatum: hasUltimatum,
            ultimatumSoundName: ultimatumSound,
            mathDifficulty: mathDifficulty,
            skipNext: skipNext,
            createdAt: editAlarm?.createdAt ?? Date()
        )
        if isEditing {
            alarmManager.updateAlarm(alarm)
        } else {
            alarmManager.addAlarm(alarm)
        }
        dismiss()
    }
}
