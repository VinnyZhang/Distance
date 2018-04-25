//
//  ViewController.swift
//  Distance
//
//  Created by Zhang xiaosong on 2018/4/24.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController , ARSCNViewDelegate{
    
    var sceneView: ARSCNView!
    var infoLabel: UILabel!
    var targetImageView: UIImageView!
    var session = ARSession()
    var configuration = ARWorldTrackingConfiguration()
    var isMeasuring = false //默认为非测量状态
    
    var vectorZero = SCNVector3()//0,0,0
    var vectorStart = SCNVector3()
    var vectorEnd = SCNVector3()
    var lines = [Line]()
    var currentLine: Line?
    var unit = LengthUnit.cenitMeter //cm
    
    var resetBtn: UIButton!
    
    //    MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpMySubViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK: - 触控方法
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isMeasuring {
            reset()
            targetImageView.image = UIImage(named: "center_green")
        }
        else {
            isMeasuring = false
            if let line = currentLine {
                lines.append(line)
                currentLine = nil
                targetImageView.image = UIImage(named: "center_white")
            }
        }
    }
    
    
    //    MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.scanWorld()
        }
    }
    
    
    //    MARK: - private methods
    
    /// 初始化子视图
    private func setUpMySubViews() {
        sceneView = ARSCNView()
        self.view.addSubview(sceneView)
        sceneView.frame = self.view.frame
        sceneView.delegate = self
        
        sceneView.session = session
        
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        
        infoLabel = UILabel()
        self.view.addSubview(infoLabel)
        infoLabel.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 30)
        infoLabel.textAlignment = .center
        infoLabel.textColor = UIColor.blue
        infoLabel.text = "初始化中"
        
        targetImageView = UIImageView()
        self.view.addSubview(targetImageView)
        targetImageView.frame = CGRect(x: (self.view.frame.size.width - 35)/2, y: (self.view.frame.size.height - 35)/2.0, width: 35, height: 35)
        
        resetBtn = UIButton()
        resetBtn.setTitle("RESET", for: .normal)
        resetBtn.setTitleColor(UIColor.blue, for: .normal)
        self.view.addSubview(resetBtn)
        resetBtn.frame = CGRect(x: 0, y: self.view.frame.size.height - 40, width: self.view.frame.size.width, height: 40)
        resetBtn.backgroundColor = UIColor.clear
        resetBtn.addTarget(self, action: #selector(resetClick), for: UIControlEvents.touchUpInside)
        
    }
    
    private func scanWorld() {
        guard let worldPosition = sceneView.worldVector(with: view.center) else {
            return
        }
        if lines.isEmpty {
            infoLabel.text = "点击画面"
        }
        if isMeasuring {//如果处于测量状态
            if vectorStart == vectorZero {
                vectorStart = worldPosition//把现在的位置设置为开始
                currentLine = Line(sceneView: sceneView, startVector: vectorStart, unit: unit)
            }
            
            vectorEnd = worldPosition
            currentLine?.update(to: vectorEnd)
            infoLabel.text = currentLine?.distance(to: vectorEnd) ?? "..."
        }
    }
    
    /// 重置
    private func reset() {
        isMeasuring = true
        vectorStart = SCNVector3()
        vectorEnd = SCNVector3()
    }
    
    @objc func resetClick() {
        for line in lines {
            line.removeAll()
        }
        lines.removeAll()
    }


}

