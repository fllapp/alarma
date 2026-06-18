import AVFoundation
import AudioToolbox
import UIKit

final class AudioService {
    static let shared = AudioService()
    private var player: AVAudioPlayer?
    private var vibrationTimer: Timer?
    private var gradualTimer: Timer?
    private var gradualPlayCount = 0
    private var lastGradualPlay = Date()
    private var isAlarmPlaying = false

    private init() {
        setupPlayer()
    }

    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: "alarm_tone", withExtension: "wav") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.prepareToPlay()
        } catch {
            print("Audio player setup error: \(error)")
        }
    }

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
        player?.currentTime = 0
        player?.volume = 1.0
        player?.play()
    }

    func playSoundGradual(_ soundName: String, durationMinutes: Int) {
        guard durationMinutes > 0 else {
            playSound(soundName)
            return
        }
        stopAll()
        setupAudioSession()
        isAlarmPlaying = true

        let totalDuration = TimeInterval(durationMinutes * 60)
        let startTime = Date()

        player?.currentTime = 0
        player?.volume = 0.05
        player?.play()

        gradualTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, self.isAlarmPlaying else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / totalDuration, 1.0)
            self.player?.volume = Float(0.05 + 0.95 * progress)
            if progress >= 1.0 {
                timer.invalidate()
                self.gradualTimer = nil
            }
        }
    }

    func playUltimatumSound(_ soundName: String) {
        stopAll()
        setupAudioSession()
        isAlarmPlaying = true
        player?.currentTime = 0
        player?.volume = 1.0
        player?.play()

        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    func stopAll() {
        isAlarmPlaying = false
        player?.stop()
        player?.currentTime = 0
        vibrationTimer?.invalidate()
        vibrationTimer = nil
        gradualTimer?.invalidate()
        gradualTimer = nil
    }
}
