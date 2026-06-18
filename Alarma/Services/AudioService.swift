import AVFoundation
import AudioToolbox
import UIKit

final class AudioService {
    static let shared = AudioService()
    private var vibrationTimer: Timer?
    private var gradualTimer: Timer?
    private var gradualPlayCount = 0
    private var lastGradualPlay = Date()

    private init() {}

    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("Audio session setup error: \(error)")
        }
    }

    func playSound(_ soundName: String) {
        stopAll()
        if let sound = AlarmSound.allSounds.first(where: { $0.id == soundName }) {
            AudioServicesPlaySystemSound(sound.systemSoundID)
            AudioServicesPlaySystemSoundWithCompletion(sound.systemSoundID) { [weak self] in
                self?.playSound(soundName)
            }
        }
    }

    func playSoundGradual(_ soundName: String, durationMinutes: Int) {
        guard durationMinutes > 0 else {
            playSound(soundName)
            return
        }
        stopAll()
        guard let sound = AlarmSound.allSounds.first(where: { $0.id == soundName }) else { return }

        let totalDuration = TimeInterval(durationMinutes * 60)
        let startTime = Date()
        gradualPlayCount = 0
        lastGradualPlay = Date()

        gradualTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / totalDuration, 1.0)

            let pauseInterval = max(0.5, 8.0 * (1.0 - progress))
            let now = Date()
            if now.timeIntervalSince(self.lastGradualPlay) >= pauseInterval {
                AudioServicesPlaySystemSound(sound.systemSoundID)
                self.lastGradualPlay = now
                self.gradualPlayCount += 1
            }

            if progress >= 1.0 {
                timer.invalidate()
                self.gradualTimer = nil
                self.playSound(soundName)
            }
        }
    }

    func playUltimatumSound(_ soundName: String) {
        stopAll()
        let soundID: UInt32 = AlarmSound.allSounds.first(where: { $0.id == soundName })?.systemSoundID ?? 1007
        AudioServicesPlaySystemSound(soundID)
        AudioServicesPlaySystemSoundWithCompletion(soundID) { [weak self] in
            self?.playUltimatumSound(soundName)
        }

        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    func stopAll() {
        vibrationTimer?.invalidate()
        vibrationTimer = nil
        gradualTimer?.invalidate()
        gradualTimer = nil
    }
}
