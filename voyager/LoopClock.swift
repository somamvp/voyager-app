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

/// 서비스의 메인 클럭 객체.
/// 내부적으로 `Timer` 객체를 가지고, `fps` 값에 따라 초당 n번 트리거
/// 트리거 시 `LoopClockDelegate.invoke()` 호출
class LoopClock {
    
    var timer: Timer?
    weak var delegate: LoopClockDelegate?
    
    let fps: Int
    let timeIntervalInSeconds: Double
    
    private(set) var counter: Int = 0
    
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
            if let counter = self?.counter {
                
                self?.delegate?.invoke(counter: counter)
                self?.counter += 1
            }
        }
    }
    
    func stop() {
        print("stopping timer")
        
        self.timer?.invalidate()
        self.timer = nil
    }
}
