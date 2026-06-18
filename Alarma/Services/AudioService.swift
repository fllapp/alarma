import AVFoundation
import AudioToolbox
import UIKit

final class AudioService {
    static let shared = AudioService()
    private var vibrationTimer: Timer?
    private var gradualTimer: Timer?
    private var gradualPlayCount = 0
    private var lastGradualPlay = Date()
    private var isAlarmPlaying = false
    private var playbackTimer: Timer?

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

    func playPreview(_ soundID: UInt32) {
        AudioServicesPlaySystemSound(soundID)
    }

    func playSound(_ soundName: String) {
        stopAll()
        setupAudioSession()
        isAlarmPlaying = true
        guard let sound = AlarmSound.allSounds.first(where: { $0.id == soundName }) else { return }
        playWithLoop(soundID: sound.systemSoundID)
    }

    private func playWithLoop(soundID: UInt32) {
        guard isAlarmPlaying else { return }
        AudioServicesPlaySystemSound(soundID)
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.playWithLoop(soundID: soundID)
        }
    }

    func playSoundGradual(_ soundName: String, durationMinutes: Int) {
        guard durationMinutes > 0 else {
            playSound(soundName)
            return
        }
        stopAll()
        setupAudioSession()
        isAlarmPlaying = true
        guard let sound = AlarmSound.allSounds.first(where: { $0.id == soundName }) else { return }

        let totalDuration = TimeInterval(durationMinutes * 60)
        let startTime = Date()
        gradualPlayCount = 0
        lastGradualPlay = Date()

        gradualTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, self.isAlarmPlaying else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / totalDuration, 1.0)
            let pauseInterval = max(1.0, 10.0 * (1.0 - progress))
            let now = Date()
            if now.timeIntervalSince(self.lastGradualPlay) >= pauseInterval {
                AudioServicesPlaySystemSound(sound.systemSoundID)
                self.lastGradualPlay = now
                self.gradualPlayCount += 1
            }
            if progress >= 1.0 {
                timer.invalidate()
                self.gradualTimer = nil
                self.playWithLoop(soundID: sound.systemSoundID)
            }
        }
    }

    func playUltimatumSound(_ soundName: String) {
        stopAll()
        setupAudioSession()
        isAlarmPlaying = true
        let soundID: UInt32 = AlarmSound.allSounds.first(where: { $0.id == soundName })?.systemSoundID ?? 1007
        playWithLoop(soundID: soundID)

        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    func stopAll() {
        isAlarmPlaying = false
        vibrationTimer?.invalidate()
        vibrationTimer = nil
        gradualTimer?.invalidate()
        gradualTimer = nil
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}
