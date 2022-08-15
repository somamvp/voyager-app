//
//  SpeechGuider.swift
//  voyager
//
//  Created by 지우석 on 2022/08/15.
//

import Foundation
import AVFAudio

class SpeechGuider {
    let voice = AVSpeechSynthesisVoice(language: "ko-KR")
    let synthesizer = AVSpeechSynthesizer()
    
    func speak(string: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = voice
        synthesizer.speak(utterance)
    }
}
