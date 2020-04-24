//
//  GameViewController.swift
//  Swiftris
//
//  Created by aiaiai on 4/22/20.
//  Copyright © 2020 aiaiai. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {
    
    //  Swift typically enforces instantiation either in-line where you declare the variable or during the initializer, init…. To avoid this rule, we've added an ! after the type.
    var scene: GameScene!
    var swiftris: Swiftris!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure the view.
        //The as! operator is a forced downcast. The view object is of type SKView, but before downcasting, our code treated it like a basic UIView. Without downcasting, we are unable to access SKView methods and properties, such as presentScene(SKScene)
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        //#we've set a closure for the tick property of GameScene.swift. Remember that functions are closures with names. In our case, we've used a function named didTick(). We define didTick(). All it does is lower the falling shape by one row and then asks GameScene to redraw the shape at its new location.
        scene.tick = didTick
        
        swiftris = Swiftris()
        swiftris.delegate = self
        swiftris.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func didTick() {
        swiftris.letShapeFall()
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(shape: newShapes.nextShape!) {}
        self.scene.movePreviewShape(shape: fallingShape) {

        //  we introduced a boolean which allows us to shut down interaction with the view. Regardless of what the user does to the device at this point, they will not be able to manipulate Switris in any way. This is useful during intermediate states when we animate or shift blocks, and perform calculations. Otherwise, a well-timed user interaction may cause an unpredictable game state to occur.
            self.view.isUserInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        // The following is false when restarting a new game
        if swiftris.nextShape != nil &&
            swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(shape: swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        view.isUserInteractionEnabled = false
        scene.stopTicking()
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        nextShape()
    }
    
    //gestureRecognizer will invoke this function when it recognizes a tap.
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }
    //  all that is necessary to do after a shape has moved is to redraw its representative sprites at their new locations.
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(shape: swiftris.fallingShape!) {}
    }
}

