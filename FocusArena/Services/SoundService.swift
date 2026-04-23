import Foundation
import AVFoundation

final class SoundService {
    static let shared = SoundService()
    private var player: AVAudioPlayer?

    func startAmbient() {
        configureSession()
        guard player == nil else {
            player?.play()
            return
        }
        guard let url = Bundle.main.url(forResource: "focus_loop", withExtension: "m4a") else {
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0.4
            player.prepareToPlay()
            player.play()
            self.player = player
        } catch {
            #if DEBUG
            print("SoundService failed: \(error)")
            #endif
        }
    }

    func stopAmbient() {
        player?.stop()
        player = nil
    }

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            #if DEBUG
            print("Audio session error: \(error)")
            #endif
        }
    }
}
