//
//  LoopClock.swift
//  voyager
//
//  Created by 지우석 on 2022/07/26.
//

import Foundation

protocol LoopClockDelegate: AnyObject {
    func invoke(counter: Int)
}

class LoopClock {
    
    var timer: Timer?
    weak var delegate: LoopClockDelegate?
    
    let fps: Int
    let timeIntervalInSeconds: Double
    
    private(set) var counter = 0
    
    init(fps: Int) {
        self.fps = fps
        self.timeIntervalInSeconds = 1.0 / Double(fps)
    }
    
    func start() {
        print("starting timer")
        
        if let previousTimer = timer {
            print("trying to start timer when there is existing one. invalidating previous timer.")
            previousTimer.invalidate()
        }
        
        self.counter = 0
        
        self.timer = Timer.scheduledTimer(withTimeInterval: timeIntervalInSeconds, repeats: true) { [weak self] timer in
            self?.delegate?.invoke(counter: counter)
            self?.counter += 1
        }
    }
    
    func stop() {
        print("stopping timer")
        
        self.timer?.invalidate()
        self.timer = nil
    }
}
