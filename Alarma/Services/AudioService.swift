import AVFoundation
import AudioToolbox
import UIKit

final class AudioService {
    static let shared = AudioService()
    private var player: AVAudioPlayer?
    private var previewPlayer: AVAudioPlayer?
    private var vibrationTimer: Timer?
    private var gradualTimer: Timer?
    private var isAlarmPlaying = false

    private init() {}

    private func urlForSound(_ soundName: String) -> URL? {
        if let builtIn = AlarmSound.allSounds.first(where: { $0.id == soundName }), let fn = builtIn.fileName {
            return Bundle.main.url(forResource: fn, withExtension: "wav", subdirectory: "Sounds")
        }
        let customDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("CustomSounds", isDirectory: true)
        let url = customDir.appendingPathComponent(soundName)
        if FileManager.default.fileExists(atPath: url.path) { return url }
        for ext in ["mp3", "wav", "m4a", "caf"] {
            let alt = customDir.appendingPathComponent("\(soundName).\(ext)")
            if FileManager.default.fileExists(atPath: alt.path) { return alt }
        }
        return Bundle.main.url(forResource: "amanecer", withExtension: "wav", subdirectory: "Sounds")
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

    func playPreview(_ soundID: UInt32) {}

    func playPreviewSound(_ soundName: String) {
        guard let url = urlForSound(soundName) else { return }
        previewPlayer?.stop()
        do {
            previewPlayer = try AVAudioPlayer(contentsOf: url)
            previewPlayer?.volume = 0.7
            previewPlayer?.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.previewPlayer?.stop()
            }
        } catch {}
    }

    func playSound(_ soundName: String) {
        stopAll()
        setupAudioSession()
        isAlarmPlaying = true
        guard let url = urlForSound(soundName) else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 1.0
            player?.play()
        } catch {
            print("playSound error: \(error)")
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
        guard let url = urlForSound(soundName) else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
        } catch { return }

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
        guard let url = urlForSound(soundName) else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 1.0
            player?.play()
        } catch {}

        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    func stopAll() {
        isAlarmPlaying = false
        player?.stop()
        player = nil
        previewPlayer?.stop()
        previewPlayer = nil
        vibrationTimer?.invalidate()
        vibrationTimer = nil
        gradualTimer?.invalidate()
        gradualTimer = nil
    }
}
