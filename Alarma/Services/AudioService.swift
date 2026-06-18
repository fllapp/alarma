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

    func playAlarm(toneConfig: ToneConfig) {
        stopAll()
        setupAudioSession()
        isAlarmPlaying = true
        startContinuousPlayback(toneConfig: toneConfig)
    }

    func playUltimatumSound(toneConfig: ToneConfig) {
        stopAll()
        setupAudioSession()
        isAlarmPlaying = true
        startContinuousPlayback(toneConfig: toneConfig, isUltimatum: true)

        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    func playSoundGradual(toneConfig: ToneConfig, durationMinutes: Int) {
        guard durationMinutes > 0 else {
            playAlarm(toneConfig: toneConfig)
            return
        }
        stopAll()
        setupAudioSession()
        isAlarmPlaying = true

        let totalDuration = TimeInterval(durationMinutes * 60)
        let startTime = Date()
        lastGradualPlay = Date()
        gradualPlayCount = 0

        gradualTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, self.isAlarmPlaying else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / totalDuration, 1.0)
            let pauseInterval = max(1.0, 10.0 * (1.0 - progress))
            let now = Date()
            if now.timeIntervalSince(self.lastGradualPlay) >= pauseInterval {
                AudioServicesPlaySystemSound(1006)
                self.lastGradualPlay = now
                self.gradualPlayCount += 1
            }
            if progress >= 1.0 {
                timer.invalidate()
                self.gradualTimer = nil
                self.playAlarm(toneConfig: toneConfig)
            }
        }
    }

    private func startContinuousPlayback(toneConfig: ToneConfig, isUltimatum: Bool = false) {
        let soundID: UInt32 = isUltimatum ? 1007 : 1007
        playLoop(soundID: soundID)
    }

    private func playLoop(soundID: UInt32) {
        guard isAlarmPlaying else { return }
        AudioServicesPlaySystemSound(soundID)
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.playLoop(soundID: soundID)
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
