import Foundation
import SwiftUI
import UIKit
import AVFoundation

final class AlarmManager: ObservableObject {
    static let shared = AlarmManager()

    @Published var alarms: [Alarm] = [] {
        didSet { PersistenceService.shared.save(alarms: alarms) }
    }
    @Published var activeAlarm: Alarm?
    @Published var showAlarmView = false
    @Published var currentMathProblem: MathProblem?
    @Published var isUltimatum = false
    @Published var snoozeCount: [UUID: Int] = [:]

    private let notificationService = NotificationService.shared
    private let audioService = AudioService.shared
    private var alarmTimers: [UUID: Timer] = [:]

    private init() {
        loadAlarms()
        notificationService.setupNotificationCategories()
        checkPendingAlarms()
        startBackgroundTimer()
    }

    func requestNotificationPermission() {
        notificationService.requestPermission()
    }

    func setupAudioSession() {
        audioService.setupAudioSession()
    }

    // MARK: - CRUD

    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        alarms.sort { $0.createdAt < $1.createdAt }
        notificationService.scheduleAlarm(alarm)
    }

    func updateAlarm(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index] = alarm
        notificationService.scheduleAlarm(alarm)
    }

    func deleteAlarm(_ alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }
        notificationService.cancelAlarm(alarm)
        alarmTimers[alarm.id]?.invalidate()
        alarmTimers.removeValue(forKey: alarm.id)
    }

    func toggleAlarm(_ alarm: Alarm) {
        var updated = alarm
        updated.isEnabled.toggle()
        updateAlarm(updated)
    }

    func toggleSkipNext(_ alarm: Alarm) {
        var updated = alarm
        updated.skipNext.toggle()
        updateAlarm(updated)
    }

    // MARK: - Alarm Firing

    func triggerAlarm(_ alarm: Alarm) {
        DispatchQueue.main.async {
            if alarm.skipNext {
                var updated = alarm
                updated.skipNext = false
                self.updateAlarm(updated)
                self.scheduleNextAlarm(alarm)
                return
            }

            self.isUltimatum = false
            self.currentMathProblem = MathService.shared.generateProblem(difficulty: alarm.mathDifficulty)
            self.activeAlarm = alarm
            self.showAlarmView = true

            if alarm.hasUltimatum {
                let count = self.snoozeCount[alarm.id] ?? 0
                if count >= alarm.maxSnoozes {
                    self.isUltimatum = true
                    self.audioService.playUltimatumSound(alarm.ultimatumSoundName)
                    return
                }
            }

            self.audioService.playSound(alarm.soundName)
        }
    }

    func triggerAlarmView(_ alarm: Alarm) {
        triggerAlarm(alarm)
    }

    // MARK: - Dismiss & Snooze

    func dismissAlarm() {
        guard let alarm = activeAlarm else { return }
        audioService.stopAll()
        snoozeCount[alarm.id] = 0
        activeAlarm = nil
        showAlarmView = false
        currentMathProblem = nil
        isUltimatum = false
        notificationService.scheduleAlarm(alarm)
    }

    func snoozeAlarm(_ alarm: Alarm? = nil) {
        let target = alarm ?? activeAlarm
        guard let target = target else { return }

        audioService.stopAll()
        let count = (snoozeCount[target.id] ?? 0) + 1
        snoozeCount[target.id] = count

        if target.hasUltimatum && count >= target.maxSnoozes {
            activeAlarm = target
            isUltimatum = true
            currentMathProblem = MathService.shared.generateProblem(difficulty: target.mathDifficulty)
            showAlarmView = true
            audioService.playUltimatumSound(target.ultimatumSoundName)
            return
        }

        notificationService.scheduleSnooze(alarm: target, snoozeMinutes: target.snoozeMinutes)

        if activeAlarm?.id == target.id {
            showAlarmView = false
            activeAlarm = nil
            currentMathProblem = nil
        }
    }

    func checkMathAnswer(_ answer: Int) -> Bool {
        guard let problem = currentMathProblem else { return false }
        let correct = MathService.shared.checkAnswer(problem, userAnswer: answer)
        if correct {
            var updated = activeAlarm
            if isUltimatum {
                snoozeCount[activeAlarm?.id ?? UUID()] = 0
            }
            dismissAlarm()
        }
        return correct
    }

    // MARK: - Background

    private func startBackgroundTimer() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.checkPendingAlarms()
        }
    }

    func checkPendingAlarms() {
        for alarm in alarms where alarm.isEnabled {
            let now = Date()
            let cal = Calendar.current
            let nowComponents = cal.dateComponents([.year, .month, .day, .hour, .minute], from: now)
            let alarmComponents = DateComponents(year: nowComponents.year, month: nowComponents.month, day: nowComponents.day, hour: alarm.hour, minute: alarm.minute)
            guard let alarmDate = cal.date(from: alarmComponents) else { continue }

            if alarmDate <= now && alarmDate > now.addingTimeInterval(-120) {
                let weekday = cal.component(.weekday, from: now)
                if alarm.daysOfWeek.isEmpty || alarm.daysOfWeek.contains(weekday) {
                    triggerAlarm(alarm)
                }
            }
        }
    }

    private func scheduleNextAlarm(_ alarm: Alarm) {
        notificationService.scheduleAlarm(alarm)
    }

    private func loadAlarms() {
        alarms = PersistenceService.shared.load()
    }
}
