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
    
//  keep track of the last point on the screen at which a shape movement occurred or where a pan begins
    var panPointReference: CGPoint?
    
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
    
//  gestureRecognizer will invoke this function when it recognizes a tap.
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }
    
//  Our pan detection logic is straight-forward. Every time the user's finger moves more than 90% of BlockSize points across the screen, we'll move the falling shape in the corresponding direction of the pan.
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        
    //  we recover a point which defines the translation of the gesture relative to where it began. This is not an absolute coordinate, just a measure of the distance that the user's finger has traveled.
        let currentPoint = sender.translation(in: self.view)
        if let originalPoint = panPointReference {
            
        //  we check whether the x translation has crossed our threshold - 90% of BlockSize - before proceeding.
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {

            //  we check the velocity of the gesture. Velocity will give us direction, in this case a positive velocity represents a gesture moving towards the right side of the screen, negative towards the left. We then move the shape in the corresponding direction and reset our reference point.
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .began {
            panPointReference = currentPoint
        }
    }
    
    //  all that is necessary to do after a shape has moved is to redraw its representative sprites at their new locations.
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(shape: swiftris.fallingShape!) {}
    }
}

