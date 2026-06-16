import AVFoundation
import AudioToolbox
import UIKit

final class AudioService {
    static let shared = AudioService()
    private var audioPlayer: AVAudioPlayer?
    private var vibrationTimer: Timer?

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

    func playUltimatumSound(_ soundName: String) {
        stopAll()

        let systemSoundID: UInt32
        if let sound = AlarmSound.allSounds.first(where: { $0.id == soundName }) {
            systemSoundID = sound.systemSoundID
        } else {
            systemSoundID = 1007
        }

        AudioServicesPlaySystemSound(systemSoundID)
        AudioServicesPlaySystemSoundWithCompletion(systemSoundID) { [weak self] in
            self?.playUltimatumSound(soundName)
        }

        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    func stopAll() {
        audioPlayer?.stop()
        audioPlayer = nil
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
}
