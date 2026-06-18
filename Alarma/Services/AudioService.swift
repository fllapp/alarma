import AVFoundation
import AudioToolbox
import UIKit

final class AudioService {
    static let shared = AudioService()

    private var vibrationTimer: Timer?
    private var gradualTimer: Timer?
    private var gradualPlayCount = 0
    private var lastGradualPlay = Date()

    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var isAlarmPlaying = false

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
        startTone(config: toneConfig)
    }

    func playUltimatumSound(toneConfig: ToneConfig) {
        stopAll()
        setupAudioSession()
        isAlarmPlaying = true
        startUltimatumTone(config: toneConfig)

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

    private func startTone(config: ToneConfig) {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        guard let engine = audioEngine, let player = playerNode else { return }

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let sampleRate = 44100
        let bufferDuration = 2.0
        let frameCount = AVAudioFrameCount(bufferDuration * Double(sampleRate))
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(buffer.format.channelCount))

        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / Double(sampleRate)
            var value: Double = 0

            switch config.pattern {
            case .continuous:
                let freq = config.frequencies[0]
                value = sin(2.0 * .pi * freq * t)
            case .siren:
                let period = config.cadence > 0 ? config.cadence : 2.0
                let freq = config.frequencies[0] + sin(2.0 * .pi * t / period) * config.frequencies[0] * 0.3
                value = sin(2.0 * .pi * freq * t)
            case .pulse:
                let rate = config.cadence > 0 ? config.cadence : 1.0
                let envelope = max(0, sin(2.0 * .pi * rate * t))
                let freq = config.frequencies[0]
                value = sin(2.0 * .pi * freq * t) * envelope
            case .dualTone:
                let freq1 = config.frequencies[0]
                let freq2 = config.frequencies.count > 1 ? config.frequencies[1] : freq1 * 1.5
                let switchInterval = config.cadence > 0 ? config.cadence : 0.5
                let useSecond = Int(t / switchInterval) % 2 == 1
                value = sin(2.0 * .pi * (useSecond ? freq2 : freq1) * t)
            }

            for channel in 0..<Int(buffer.format.channelCount) {
                channels[channel][frame] = Float(value * 0.35)
            }
        }

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)

        do {
            try engine.start()
            player.play()
        } catch {
            print("Audio engine error: \(error)")
            fallbackPlay()
        }
    }

    private func startUltimatumTone(config: ToneConfig) {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        guard let engine = audioEngine, let player = playerNode else { return }

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let sampleRate = 44100
        let bufferDuration = 1.0
        let frameCount = AVAudioFrameCount(bufferDuration * Double(sampleRate))
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(buffer.format.channelCount))
        let baseFreq = config.frequencies.first ?? 800
        let harmonics: [(Double, Double)] = [(1.0, 1.0), (2.0, 0.5), (3.0, 0.25)]

        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / Double(sampleRate)
            var value: Double = 0
            for (mult, amp) in harmonics {
                value += sin(2.0 * .pi * baseFreq * mult * t) * amp
            }
            let pulse = max(0, sin(2.0 * .pi * 4.0 * t))
            value *= pulse

            for channel in 0..<Int(buffer.format.channelCount) {
                channels[channel][frame] = Float(value * 0.4)
            }
        }

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)

        do {
            try engine.start()
            player.play()
        } catch {
            fallbackPlay()
        }
    }

    private func fallbackPlay() {
        guard isAlarmPlaying else { return }
        let soundID: UInt32 = 1007
        AudioServicesPlaySystemSound(soundID)
        AudioServicesPlaySystemSoundWithCompletion(soundID) { [weak self] in
            guard let self = self, self.isAlarmPlaying else { return }
            self.fallbackPlay()
        }
    }

    func stopAll() {
        isAlarmPlaying = false

        vibrationTimer?.invalidate()
        vibrationTimer = nil
        gradualTimer?.invalidate()
        gradualTimer = nil

        playerNode?.stop()
        audioEngine?.stop()
        audioEngine = nil
        playerNode = nil
    }
}
