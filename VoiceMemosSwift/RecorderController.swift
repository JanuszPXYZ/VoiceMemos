//
//  RecorderController.swift
//  VoiceMemosSwift
//
//  Created by Janusz Polowczyk on 16/08/2023.
//

import Foundation
import AVFoundation


protocol RecorderControllerDelegate: AnyObject {
    func interruptionBegan()
}




final class RecorderController: NSObject, AVAudioRecorderDelegate {

    let formattedCurrentTime: String = "00:00:00"
    weak var delegate: RecorderControllerDelegate?

    private var player: AVAudioPlayer = AVAudioPlayer()
    private var recorder: AVAudioRecorder = AVAudioRecorder()

    var completionHandler: ((Bool) -> Void)?

    init(delegate: RecorderControllerDelegate? = nil) {

        self.delegate = delegate

        let tmpDir = FileManager.default.temporaryDirectory

        let filePath = tmpDir.appending(path: "memo.caf")
        if !FileManager.default.fileExists(atPath: filePath.absoluteString) {
            FileManager.default.createFile(atPath: filePath.absoluteString, contents: nil)
        } else {
            print("Exists")
        }

        print(filePath)

        let settings = [
            AVFormatIDKey: kAudioFormatAppleIMA4,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitDepthHintKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.high
        ] as [String: Any]

        super.init()

        do {
            self.recorder = try AVAudioRecorder(url: filePath, settings: settings)
            print(self.recorder.url)
            self.recorder.delegate = self
            self.recorder.prepareToRecord()
        } catch {
            print(error.localizedDescription)
        }
    }

    func record() {
        self.recorder.record()
    }

    func pause() {
        self.recorder.pause()
    }

    func stopWithCompletionHandler(handler: @escaping(Bool) -> Void) {
        handler(true)
        self.recorder.stop()
    }

    func saveRecordingWithName(name: String, completionHandler: (Bool, VoiceMemo) -> Void) {
        let timeStamp = Date.timeIntervalSinceReferenceDate
        let filename = String(format: "\(name)-\(timeStamp).caf")

        guard let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let destPath = docDir.appendingPathComponent(filename)
        let sourceURL = self.recorder.url
        print(sourceURL)
        print(destPath)
        let destURL = URL(filePath: destPath.absoluteString)


        do {
            try FileManager.default.copyItem(at: sourceURL, to: destPath)
            let memo = VoiceMemo(title: name, url: destURL)
            completionHandler(true, memo)
            self.recorder.prepareToRecord()
        } catch {
            print(error.localizedDescription)
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let completionHandler = self.completionHandler {
            completionHandler(flag)
        }
    }


    func playbackMemo(memo: VoiceMemo) -> Bool {
        return false
    }
}
