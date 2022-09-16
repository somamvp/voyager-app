//
//  SessionController.swift
//  voyager
//
//  Created by 지우석 on 2022/09/16.
//

protocol SessionController {
    
    var delegate: ARDataReceiver? { get set }
    
    func createView() -> SceneView
    
    func start()
    
    func stop()
}
