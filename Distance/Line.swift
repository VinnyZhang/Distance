//
//  Line.swift
//  Distance
//
//  Created by Zhang xiaosong on 2018/4/24.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import ARKit

/// 长度单位 枚举
enum LengthUnit {
    case meter, cenitMeter, inch
    var factor: Float {
        switch self {
        case .meter:
            return 1.0
        case .cenitMeter:
            return 100.0
        case .inch:
            return 39.3700788
        }
    }
    
    var name: String {
        switch self {
        case .meter:
            return "m"
        case .cenitMeter:
            return "cm"
        case .inch:
            return "inch"
        }
    }
}


class Line {
    var color = UIColor.blue
    var startNode: SCNNode
    var endNode: SCNNode
    var textNode: SCNNode
    var text: SCNText
    var lineNode: SCNNode?
    let sceneView: ARSCNView
    let startVector: SCNVector3
    let unit: LengthUnit
    
    /// 初始化
    ///
    /// - Parameters:
    ///   - sceneView: AR视图
    ///   - startVector: 起点
    ///   - unit: 单位
    init(sceneView: ARSCNView,startVector: SCNVector3,unit: LengthUnit) {
        //创建节点(开始,结束,线,数字,单位)
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        
        let dot = SCNSphere(radius: 0.5)
        dot.firstMaterial?.diffuse.contents = color
        dot.firstMaterial?.lightingModel = .constant //光照,表面看起来都是一样的光亮,不会产生阴影
        dot.firstMaterial?.isDoubleSided = true //两面都很亮
        
        startNode = SCNNode(geometry: dot)
        startNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        startNode.position = startVector
        sceneView.scene.rootNode.addChildNode(startNode)
        
        endNode = SCNNode(geometry: dot)
        endNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        text = SCNText(string: "", extrusionDepth: 0.1)
        text.font = .systemFont(ofSize: 5)
        text.firstMaterial?.diffuse.contents = color
        text.firstMaterial?.lightingModel = .constant
        text.firstMaterial?.isDoubleSided = true
        text.alignmentMode = kCAAlignmentCenter
        text.truncationMode = kCATruncationMiddle
        
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)// 数字对着自己
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(textNode)
        
        
    }
    
    /// 更新目标点
    ///
    /// - Parameter vector: 目标点
    func update(to vector:SCNVector3) {
        lineNode?.removeFromParentNode()//移除掉所有线
        lineNode = startVector.line(to: vector, color: color)
        sceneView.scene.rootNode.addChildNode(lineNode!)
        
        text.string = distance(to: vector)
        
        textNode.position = SCNVector3((startVector.x + vector.x)/2.0, (startVector.y + vector.y)/2.0, (startVector.z + vector.z)/2.0)
        endNode.position = vector
        if endNode.parent == nil {
            sceneView.scene.rootNode.addChildNode(endNode)
        }
        
    }
    
    /// 返回距离描述
    ///
    /// - Parameter vector: 目标点
    /// - Returns: 返回距离描述
    func distance(to vector:SCNVector3) -> String {
        return String(format: "%.2f  %@", startVector.distance(to: vector)*unit.factor,unit.name) //乘以单位
    }
    
    
    /// 移除测量数据
    func removeAll() {
        startNode.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
    }
    
}

