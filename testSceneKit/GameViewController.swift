//
//  GameViewController.swift
//  testSceneKit
//
//  Created by Maksim Kasyanenko on 12.02.2024.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    let board = Board()
    var gamePlayer = GamePlayer.x
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        let boardNode = board.node
        boardNode.position = SCNVector3(x: 0, y: 0, z: 7)
        board.node.eulerAngles = SCNVector3(x: .pi / 2.5, y: 0, z: 0)
        scene.rootNode.addChildNode(boardNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        scnView.pointOfView = cameraNode
    
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        //
        //        // create a new scene
        //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //
        //        // create and add a camera to the scene
        //        let cameraNode = SCNNode()
        //        cameraNode.camera = SCNCamera()
        //        scene.rootNode.addChildNode(cameraNode)
        //
        //        // place the camera
        //        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        //
        //        // create and add a light to the scene
        //        let lightNode = SCNNode()
        //        lightNode.light = SCNLight()
        //        lightNode.light!.type = .omni
        //        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        //        scene.rootNode.addChildNode(lightNode)
        //
        //        // create and add an ambient light to the scene
        //        let ambientLightNode = SCNNode()
        //        ambientLightNode.light = SCNLight()
        //        ambientLightNode.light!.type = .ambient
        //        ambientLightNode.light!.color = UIColor.darkGray
        //        scene.rootNode.addChildNode(ambientLightNode)
        //
        //        let board = Board()
        //         let boardNode = board.node
        //        boardNode.position = SCNVector3(x: 0, y: 0, z: 7)
        //        scene.rootNode.addChildNode(boardNode)
        //        // retrieve the ship node
        //       // let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        //
        //        // animate the 3d object
        //        //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        //
        //        // retrieve the SCNView
        //        let scnView = self.view as! SCNView
        //
        //        // set the scene to the view
        //        scnView.scene = scene
        //
        //        // allows the user to manipulate the camera
        //        scnView.allowsCameraControl = true
        //
        //        // show statistics such as fps and timing information
        //        scnView.showsStatistics = true
        //
        //        // configure the view
        //        scnView.backgroundColor = UIColor.black
        //
        //        // add a tap gesture recognizer
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        //        scnView.addGestureRecognizer(tapGesture)
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(didTap))
        scnView.addGestureRecognizer(tap)
    }
    @objc func didTap(_ sender:UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        
        let squareData = squareFrom(location: location)
        print(squareData)
        if let node = squareData?.1.childNodes.first {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            let euler = node.eulerAngles
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                node.eulerAngles = euler
                SCNTransaction.commit()
            }
            
            node.eulerAngles = SCNVector3(x: .pi , y: .pi , z: .pi )
            SCNTransaction.commit()
        } else {
            let figure = Figure.figure(for: gamePlayer)
            figure.eulerAngles = SCNVector3(x: .pi / 2, y:  0, z: 0)
            squareData?.1.addChildNode(figure)
            gamePlayer.toggle()
        }
        
        
    }
    
    private func squareFrom(location:CGPoint) -> ((Int, Int), SCNNode)? {
        // guard let _ = currentPlane else { return nil }
        let sceneView = self.view as! SCNView
        let hitResults = sceneView.hitTest(location, options: [SCNHitTestOption.firstFoundOnly: false,
                                                               SCNHitTestOption.rootNode:  board.node])
        
        for result in hitResults {
            if let square = board.nodeToSquare[result.node] {
                return (square, result.node)
            }
        }
        
        return nil
    }
    
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
}
