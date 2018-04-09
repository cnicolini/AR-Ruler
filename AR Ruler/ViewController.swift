//
//  ViewController.swift
//  AR Ruler
//
//  Created by Christian Nicolini on 4/8/18.
//  Copyright © 2018 Christian Nicolini. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    
    var textNode : SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
            
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        let hitResultPosition = hitResult.worldTransform.columns.3
        
        dotNode.position = SCNVector3(hitResultPosition.x, hitResultPosition.y, hitResultPosition.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        calcDistance()
    }
    
    func calcDistance() {
        if dotNodes.count < 2 {
            return
        }
        
        let startNode = dotNodes[0]
        let endNode = dotNodes[1]
        
        let d = sqrt(
            pow(endNode.position.x - startNode.position.x, 2) +
                pow(endNode.position.y - startNode.position.y, 2) +
                pow(endNode.position.z - startNode.position.z, 2)
        )
        
        print("Distance \(d)")
        
        updateText(text: "\(d)", at: endNode.position)
        
    }
    
    func updateText(text: String, at position: SCNVector3) {
        
        removeTextNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode!.position = SCNVector3(position.x, position.y + 0.01, position.z)
        
        textNode!.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode!)
        
    }
    
    func removeTextNode() {
        
        textNode?.removeFromParentNode()
        
    }
    
    //MARK: - Actions
    @IBAction func clearAllDots(_ sender: UIBarButtonItem) {
        
        removeTextNode()
        
        if dotNodes.isEmpty {
            return
        }
        
        for dotNode in dotNodes {
            dotNode.removeFromParentNode()
        }
        
        dotNodes.removeAll()
        
    }
    
}
