//
//  SceneViewController.swift
//  testSceneKit
//
//  Created by Maksim Kasyanenko on 12.02.2024.
//

import UIKit
import SceneKit

class SceneViewController: UIViewController {
    
    var ballNode: SCNNode!
    var selfieStickNode: SCNNode!
    var motionVextor: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    let sceneView: SCNView = {
        let view = SCNView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        self.view.addSubview(sceneView)
        sceneView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height)
        let scene = SCNScene(named: "MainScene.scnassets/MainScene.scn")
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.scene?.physicsWorld.contactDelegate = self
        setupNodes()
       // sceneView.allowsCameraControl = true
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ballTap)))
        sceneView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ballPan)))
    }
    
    private func setupNodes() {
        ballNode = sceneView.scene?.rootNode.childNode(withName: "ball", recursively: true)
        ballNode.physicsBody?.contactTestBitMask = 2
        selfieStickNode = sceneView.scene?.rootNode.childNode(withName: "stick", recursively: true)
    }
    var startPoint: CGPoint = .zero
    @objc private func ballPan(recognaizer: UIPanGestureRecognizer) {
        
        switch recognaizer.state {
        case .began:
            startPoint = recognaizer.location(in: sceneView)
           
        case .changed:
           
           let changedPoint = recognaizer.location(in: sceneView)
            
            let diferencePoint = CGPoint(x: changedPoint.x - startPoint.x,
                                         y: changedPoint.y - startPoint.y )
            print( diferencePoint)
            let diferenceVector = SCNVector3(x: Float(diferencePoint.x), y: 0, z: Float(diferencePoint.y))
            guard let curent = ballNode.physicsBody?.velocity else { return }
            
            let resultVectore = SCNVector3(curent.x + diferenceVector.x * 0.0001,
                                           0,
                                           curent.z + diferenceVector.z * 0.0001)
            ballNode.physicsBody?.velocity = resultVectore
            
        case .ended:
            startPoint = .zero
            return
        @unknown default:
            return
        }
        }
    
    @objc private func ballTap(recognaizer: UITapGestureRecognizer) {
        let location = recognaizer.location(in: sceneView)
        
        let hitResult = sceneView.hitTest(location)
        if hitResult.count > 0 {
            let result = hitResult.first
            guard let node = result?.node else { return }
            if node.name == "ball" {
                node.physicsBody?.applyForce(SCNVector3(x: 0.5, y: 1, z: -1), asImpulse: true)
            }
           
            
        }
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    

    

}

extension SceneViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let ball = ballNode.presentation
        let ballPosition = ball.position
        
        let targetPosition = SCNVector3(x: ballPosition.x,
                                       y: ballPosition.y + 5,
                                       z: ballPosition.z + 5)
        var cameraPosition = selfieStickNode.position
        
        let cameraDamping: Float = 0.3
        
        let xComponent = cameraPosition.x * (1 - cameraDamping) + targetPosition.x * cameraDamping
        let yComponent = cameraPosition.y * (1 - cameraDamping) + targetPosition.y * cameraDamping
        let zComponent = cameraPosition.z * (1 - cameraDamping) + targetPosition.z * cameraDamping
        
        cameraPosition = SCNVector3(x: xComponent, y: yComponent, z: zComponent)
        selfieStickNode.position = cameraPosition
    }
}

extension SceneViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let contactNode: SCNNode!
        
        if contact.nodeA.name == "ball" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        if contactNode.physicsBody?.categoryBitMask == 2 {
           // contactNode.isHidden = true
            contactNode.removeFromParentNode()
        }
        
    }
}
