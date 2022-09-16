//
//  SpeechGuider.swift
//  voyager
//
//  Created by 지우석 on 2022/08/15.
//

import Foundation
import AVFAudio

class AudioGuider {
    let voice = AVSpeechSynthesisVoice(language: "ko-KR")
    let synthesizer = AVSpeechSynthesizer()
    
    func speak(string: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.rate = 0.6
        utterance.voice = voice
        synthesizer.speak(utterance)
    }
}
