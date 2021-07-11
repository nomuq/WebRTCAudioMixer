//
//  ViewController.swift
//  Agora Audio and Effect Streaming Demo
//
//  Created by Satish Babariya on 11/07/21.
//

import UIKit
import AgoraRtcKit

class ViewController: UIViewController {
    
    @IBOutlet weak var outputText: UITextView!
    
    var agoraKit: AgoraRtcEngineKit!
    var didJoinChannel: Bool = false
    var uid : UInt = .random(in: 1...10)
    
    var effect = "https://raw.githubusercontent.com/decentraland-scenes/shooting-range/master/sounds/shot.mp3"
    var audio = "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_5MG.mp3"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "d559ca4f8e694f45971654e0338e9222", delegate: self)
        agoraKit.setEnableSpeakerphone(true)
        
        agoraKit.preloadEffect(2, filePath: effect)
        
        
        joinChannel()
        
        self.title = "User ID: \(uid)"
        showPlayButtons()
    }
    
    func showPlayButtons() {
        
        let playButton = UIBarButtonItem.init(barButtonSystemItem: .play, target: self, action: #selector(play))
        let stopButton = UIBarButtonItem.init(barButtonSystemItem: .pause, target: self, action: #selector(stop))
        
        let playNoiceButton = UIBarButtonItem.init(barButtonSystemItem: .play, target: self, action: #selector(playNoice))
        let stopNoiceButton = UIBarButtonItem.init(barButtonSystemItem: .pause, target: self, action: #selector(stopNoice))
        
        
        self.navigationItem.rightBarButtonItems = [stopButton, playButton]
        self.navigationItem.leftBarButtonItems = [playNoiceButton, stopNoiceButton]
    }
    
    func hidePlayButtons()  {
        
        self.navigationItem.rightBarButtonItems = []
        self.navigationItem.leftBarButtonItems = []
    }
    
    @objc func play() {
        self.agoraKit.startAudioMixing(audio, loopback: false, replace: false, cycle: 1, startPos: 0)
        
    }
    
    @objc func stop() {
        self.agoraKit.stopAudioMixing()
    }
    
    @objc func playNoice() {
        self.agoraKit.playEffect(2, filePath: effect, loopCount: 1, pitch: 1, pan: 2, gain: 100, publish: true, startPos: 0)
        
    }
    
    @objc func stopNoice() {
        self.agoraKit.stopEffect(2)
    }
    
    
    
    func joinChannel() {
        agoraKit.joinChannel(byToken: "0068aff882a86744cc79788237f5e4875a9IADIa6gB4OGZ0cezdekqGuQengQBh/TanZxDz4ix386XcLfv3IMAAAAAEAAPHFzYfsjrYAEAAQB+yOtg", channelId: "1", info: nil, uid: uid) { [weak self] (sid, uid, elapsed) -> Void in
            self?.log("joinChannel sid: \(sid) uid: \(uid) elapsed: \(elapsed)")
        }
        agoraKit.adjustRecordingSignalVolume(0)
    }
    
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
    }
    
    func log(_ text: String) {
        print(text)
        DispatchQueue.main.async(execute: {
            let previousOutput = self.outputText.text ?? ""
            let nextOutput = previousOutput + text + "\n"
            self.outputText.text = nextOutput
            
            let range = NSRange(location:nextOutput.count,length:0)
            self.outputText.scrollRangeToVisible(range)
        })
    }
    
}

extension ViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        if uid == self.uid {
            didJoinChannel = true
            showPlayButtons()
        }
        log("Join \(channel) with uid \(uid) elapsed \(elapsed)ms")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        didJoinChannel = false
        hidePlayButtons()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        log("remote user join: \(uid) \(elapsed)ms")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        log("remote user left: \(uid) reason \(reason)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionStateType, reason: AgoraConnectionChangedReason) {
        switch state {
        
        case .disconnected:
            log("connectionChangedTo: disconnected")
        case .connecting:
            log("connectionChangedTo: connecting")
        case .connected:
            log("connectionChangedTo: connected")
        case .reconnecting:
            log("connectionChangedTo: reconnecting")
        case .failed:
            log("connectionChangedTo: failed")
        @unknown default:
            fatalError()
        }
    }
    
    func rtcEngineDidAudioEffectFinish(_ engine: AgoraRtcEngineKit, soundId: Int) {
        log("rtcEngineDidAudioEffectFinish: \(soundId)")
    }
}
