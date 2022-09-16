//
//  SceneView.swift
//  voyager
//
//  Created by 지우석 on 2022/09/16.
//

import UIKit
import AVFoundation
import ARKit

protocol SceneView: UIView {}

extension ARSCNView: SceneView {}

