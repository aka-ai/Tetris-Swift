//
//  GameScene.swift
//  Swiftris
//
//  Created by aiaiai on 4/22/20.
//  Copyright © 2020 aiaiai. All rights reserved.
//

import SpriteKit

//#we define the point size of each block sprite, in our case 20.0 x 20.0, the lower of the available resolution options for each block image. We also declare a layer position which will give us an offset from the edge of the screen.
let BlockSize:CGFloat = 33.5

//First, we define a new constant at #1, TickLengthLevelOne. This variable will represent the slowest speed at which our shapes will travel. We've set it to 600 milliseconds, which means that every 6/10ths of a second, our shape should descend by one row.
let TickLengthLevelOne = TimeInterval(600) //NSTimeInterval' has been renamed to 'TimeInterval'

class GameScene: SKScene {
    // #we've introduced a couple of SKNodes which act as superimposed layers of activity within our scene. The gameLayer sits above the background visuals and the shapeLayer sits atop that.
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let LayerPosition = CGPoint(x: 6, y: -6)
    
    // #tick is what's known as a closure in Swift. A closure is essentially a block of code that performs a function, and Swift refers to functions as closures. In defining tick, its type is (() -> ())? which means that it's a closure which takes no parameters and returns nothing. Its question mark indicates that it's optional and may be nil.
    //https://docs.swift.org/swift-book/LanguageGuide/Closures.html
    var tick:(() -> ())?
    var tickLengthMillis = TickLengthLevelOne
    var lastTick:NSDate?
    
    var textureCache = Dictionary<String, SKTexture>()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    //  OpenGL powers SpriteKit so its coordinate system is opposite to iOS' native Cocoa coordinates. (0, 0) in SpriteKit is the bottom-left corner. We will draw Swiftris from the top down so we anchor our game in the top-left corner of the screen: (0, 1.0). We then create an SKSpriteNode capable of representing our background image and we add it to the scene.
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        //  background is the variable's name, Swift infers its type to be that of SKSpriteNode and the keyword let indicates that it can not be re-assigned.
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x:0, y: 1.0)
        addChild(background)
        
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSize(width: (BlockSize) * CGFloat(NumColumns), height: (BlockSize) * CGFloat(NumRows)))
        
        //Ai changed gameBoard.anchorPoint
        gameBoard.anchorPoint = CGPoint(x:-0.1, y:1.25)
        gameBoard.position = LayerPosition
        
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
    //  set up a looping sound playback action of our theme song
        run(SKAction.repeatForever(SKAction.playSoundFileNamed("Sounds/theme.mp3", waitForCompletion: true)))
    }
    
//  add a method which GameViewController may use to play any sound file on demand
    func playSound(sound:String) {
        run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        //Swift's guard statement checks the conditions which follow it, let lastTick = lastTick in our case. If the conditions fail, guard executes the else block. If lastTick is missing, the game is in a paused state and not reporting elapsed ticks, so we return.
        guard let lastTick = lastTick else {
            return
        }
        //But if lastTick is present, we recover the time passed since the last execution of update by invoking timeIntervalSinceNow on our lastTick object. We multiply the result by -1000 to calculate a positive millisecond value. We invoke functions on objects using dot syntax in Swift.
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        
        //We then check if the time passed has exceeded our tickLengthMillis variable. If enough time has elapsed, we must report a tick. We do so by first updating our last known tick time to the present and then invoking our closure.
        if timePassed > tickLengthMillis {
            self.lastTick = NSDate()
            tick?()
        }
    }
    
    //we provide accessor methods to let external classes stop and start the ticking process, something we'll make use of later to keep pieces from falling at key moments.
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
    //#we've written GameScene's most important function, pointForColumn∫. This function returns the precise coordinate on the screen for where a block sprite belongs based on its row and column position. The math here looks funky but know that we anchor each sprite at its center, so we need to find the center coordinates before placing it in our shapeLayer object.
    // Ai changed x, y for game position
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize * 1.5)
        let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize * 5.5))
        return CGPoint(x: x, y: y)
    }
    
    func addPreviewShapeToScene(shape: Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            // #we've created a method which will add a shape for the first time to the scene as a preview shape. We use a dictionary to store copies of re-usable SKTexture objects since each shape will require more than one copy of the same image.
            var texture = textureCache[block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            let sprite = SKSpriteNode(texture: texture)
            // #we use our convenient pointForColumn∫ method to place each block's sprite in the proper location. We start it at row - 2, such that the preview piece animates smoothly into place from a higher location.
            sprite.position = pointForColumn(column: block.column, row: block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            //Animation
            sprite.alpha = 0
            // #we introduce SKAction objects which are responsible for visually manipulating SKNode objects. Each block will fade and move into place as it appears as part of the next piece. It will move two rows down and fade from complete transparency to 70% opacity.
            //Ai change position of preview shape here
            let moveAction = SKAction.move(to: pointForColumn(column: block.column - 4, row: block.row - 5), duration: TimeInterval(0.2))
            moveAction.timingMode = .easeOut
            let fadeInAction = SKAction.fadeAlpha(to: 0.7, duration: 0.4)
            fadeInAction.timingMode = .easeOut
            sprite.run(SKAction.group([moveAction, fadeInAction]))
        }
        run(SKAction.wait(forDuration: 0.4), completion: completion)
    }
    
    func movePreviewShape(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.2)
            moveToAction.timingMode = .easeOut
            sprite.run(
                SKAction.group([moveToAction, SKAction.fadeAlpha(to: 1.0, duration: 0.2)]), completion: {})
        }
        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    
    func redrawShape(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row: block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.05)
            moveToAction.timingMode = .easeOut
            if block == shape.blocks.last {
                sprite.run(moveToAction, completion: completion)
            } else {
                sprite.run(moveToAction)
            }
        }
    }
    
//  we take in precisely the tuple data which Swiftris returns each time it removes a line. This will ensure that GameViewController will pass those elements to GameScene for them to animate properly.
    func animateCollapsingLines(linesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion:@escaping () -> ()) {
        
        var longestDuration: TimeInterval = 0

    //  For the blocks which must now fall to their new locations, we cascade them from left to right. We begin by iterating column by column, block by block.
    //  We also established a longestDuration variable which will determine precisely how long we should wait before calling the completion closure.
        for (columnIdx, column) in fallenBlocks.enumerated() {
            for (blockIdx, block) in column.enumerated() {
                let newPosition = pointForColumn(column: block.column, row: block.row)
                let sprite = block.sprite!
                
            //  To keep the blocks from looking robotic, they will fall after one another rather than all at once. We wrote code which will produce this pleasing effect for eye balls to enjoy. Based on the block and column indices, we introduce a directly proportional delay.
                let delay = (TimeInterval(columnIdx) * 0.05) + (TimeInterval(blockIdx) * 0.05)
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.1)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay), moveAction]))
                longestDuration = max(longestDuration, duration + delay)
            }
        }
        
        for rowToRemove in linesToRemove {
            for block in rowToRemove {
                
            //  When removing lines, we make their blocks shoot off the screen like explosive debris. To achieve this we will use a UIBezierPath. Our arch requires a radius and we've chosen to generate one randomly to introduce a natural variance among the explosive paths. Furthermore, we've randomized whether the block flies left or right.
                let randomRadius = CGFloat(UInt(arc4random_uniform(400) + 100))
                let goLeft = arc4random_uniform(100) % 2 == 0
                
                var point = pointForColumn(column: block.column, row: block.row)
                point = CGPoint(x: point.x + (goLeft ? -randomRadius: randomRadius), y: point.y)
                
                let randomDuration = TimeInterval(arc4random_uniform(2)) + 0.5
        
            //  we choose beginning and starting angles. The angles are in radians and if your trigonometry is as rough as ours was when we wrote this, a circle in radian degrees, or unit circle, looks like this:
    //  http://bloc-books.s3.amazonaws.com/swiftris/10-miserable-and-magical-unit-circle.gif
            //  When going left, we begin at 0 radians and end at π. When going right, we go from π to 2π.
                var startAngle = CGFloat.pi
                var endAngle = startAngle * 2
                if goLeft {
                    endAngle = startAngle
                    startAngle = 0
                }
                let archPath = UIBezierPath(arcCenter: point, radius: randomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: goLeft)
                let archAction = SKAction.follow(archPath.cgPath, asOffset: false, orientToPath: true, duration: randomDuration)
                archAction.timingMode = .easeIn
                let sprite = block.sprite!
            
            //  we place the block sprite above the others such that they animate above the other blocks and begin the sequence of actions which concludes with removing the sprite from the scene.
                sprite.zPosition = 100
                sprite.run(
                    SKAction.sequence([
                        SKAction.group([archAction,
                        SKAction.fadeOut(withDuration: TimeInterval(randomDuration))]),
                        SKAction.removeFromParent()
                    ]))
            }
        }
    //  we run the completion action after a duration matching the time it will take to drop the last block to its new resting place.
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
}
