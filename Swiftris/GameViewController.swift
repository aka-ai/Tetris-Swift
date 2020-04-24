//
//  GameViewController.swift
//  Swiftris
//
//  Created by aiaiai on 4/22/20.
//  Copyright © 2020 aiaiai. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
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
        swiftris.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)
        
        // #we add nextShape to the game layer at the preview location. When that animation completes, we reposition the underlying Shape object at the starting row and starting column before we ask GameScene to move it from the preview location to its starting position. Once that completes, we ask Swiftris for a new shape, begin ticking, and add the newly established upcoming piece to the preview area.
        scene.addPreviewShapeToScene(shape: swiftris.nextShape!) {
            self.swiftris.nextShape?.moveTo(column: StartingColumn, row: StartingRow)
            self.scene.movePreviewShape(shape: self.swiftris.nextShape!) {
                let nextShapes = self.swiftris.newShape()
                self.scene.startTicking()
                self.scene.addPreviewShapeToScene(shape: nextShapes.nextShape!) {}
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //#15
    func didTick() {
        swiftris.fallingShape?.lowerShapeByOneRow()
        scene.redrawShape(shape: swiftris.fallingShape!, completion: {})
    }
}

