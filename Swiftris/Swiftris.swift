//
//  Swiftris.swift
//  Swiftris
//
//  Created by aiaiai on 4/23/20.
//  Copyright © 2020 aiaiai. All rights reserved.
//

// #we've defined the total number of rows and columns on the game board, the location of where each piece starts and the location of where the preview piece belongs.
let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

let PointsPerLine = 10
let LevelThreshold = 500

protocol SwiftrisDelegate {
    //Invoked when the current round of Swiftris ends
    func gameDidEnd(swiftris: Swiftris)
    
    //Invoked after a new game has begun
    func gameDidBegin(swiftris: Swiftris)
    
    //Invoked when the falling shape has become part of the game board
    func gameShapeDidLand(swiftris: Swiftris)
    
    //Invoked when the falling shape has changed its location
    func gameShapeDidMove(swiftris: Swiftris)
    
    //Invoked when the falling shape has changed its location after beign dropped
    func gameShapeDidDrop(swiftris: Swiftris)
    
    //Invoked when the game has reached a new level
    func gameDidLevelUp(swiftris: Swiftris)
}

class Swiftris {
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    
    // #Swiftris notifies the delegate of events throughout the course of the game. In our case, GameViewController will attach itself as the delegate to update the user interface and react to game state changes whenever something occurs inside of the Swiftris class. Swiftris will work on a trial-and-error basis. The user interface, GameViewController, will ask Swiftris to move its falling shape either down, left, or right. Swiftris will accept this request, move the shape and then detect whether its new position is legal. If so, the shape will remain, otherwise it will revert to its original location.
    var delegate: SwiftrisDelegate?
    
    var score = 0
    var level = 1
    
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    func beginGame() {
        if (nextShape == nil) {
            nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(swiftris: self)
    }
    
    // #we have a method which assigns nextShape, our preview shape, as fallingShape. fallingShape is the moving Tetromino. newShape() then creates a new preview shape before moving fallingShape to the starting row and column. This method returns a tuple of optional Shape objects
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(column: StartingColumn, row: StartingRow)
        
        // #The game ends when a new shape located at the designated starting location collides with existing blocks. This is the case where the player no longer has room to move the new shape, and we must destroy their tower of terror.
        guard detectIllegalPlacement() == false else {
            nextShape = fallingShape
            nextShape!.moveTo(column: PreviewColumn, row: PreviewRow)
            endGame()
            return (nil, nil)
        }
        return (fallingShape, nextShape)
    }
    
    // #we added a function for checking both block boundary conditions. This first determines whether a block exceeds the legal size of the game board. The second determines whether a block's current location overlaps with an existing block. Remember, Swiftris will function by trial-and-error. We'll send our shapes to all sorts of bizarre places before we check whether they are legally allowed to be there.
    func detectIllegalPlacement() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for block in shape.blocks {
            if block.column < 0 || block.column >= NumColumns ||
                block.row < 0 || block.row >= NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
        return false
    }
    
    //  we've defined a function to call once every tick. This attempts to lower the shape by one row and ends the game if it fails to do so without finding legal placement for it
    func letShapeFall() {
        guard let shape = fallingShape else {
            return
        }
        shape.lowerShapeByOneRow()
        if detectIllegalPlacement() {
            shape.raiseShapeByOneRow()
            if detectIllegalPlacement() {
                endGame()
            } else {
                settleShape()
            }
        } else {
            delegate?.gameShapeDidMove(swiftris: self)
            if detectTouch() {
                settleShape()
            }
        }
    }
    
    //  Our user interface will allow the player to rotate the shape clockwise as it falls and the function at rotateShape() implements that behavior. Swiftris attempts to rotate the shape clockwise. If its new block positions violate the boundaries of the game or overlap with settled blocks, we revert the rotation and return. Otherwise, we let the delegate know that the shape has moved.
    func rotateShape() {
        guard let shape = fallingShape else {
            return
        }
        shape.rotateClockWise()
        guard detectIllegalPlacement() == false else {
            shape.rotateCounterClockwise()
            return
        }
        delegate?.gameShapeDidMove(swiftris: self)
    }
    
    //  Lastly, the player will enjoy the privilege of moving the shape either leftwards or rightwards. moveShapeLeft(), moveShapeRight() permit such behavior and follow the same pattern found in rotateShape().

    func moveShapeLeft() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftLeftByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftRightByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(swiftris: self)
    }
    
    func moveShapeRight() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftRightByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftLeftByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(swiftris: self)
    }
    
    //  settleShape() adds the falling shape to the collection of blocks maintained by Swiftris. Once the falling shape's blocks are part of the game board, we nullify fallingShape and notify the delegate of a new shape settling onto the game board.
    func settleShape() {
        guard let shape = fallingShape else {
            return
        }
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        fallingShape = nil
        delegate?.gameShapeDidLand(swiftris: self)
    }
    
    //  Swiftris needs to be able to tell when a shape should settle. This happens under two conditions: when one of the shapes' bottom blocks touches a block on the game board or when one of those same blocks has reached the bottom of the game board. detectTouch() properly detects this occurrence and returns true when detected.
    func detectTouch() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for bottomBlock in shape.bottomBlocks {
            if bottomBlock.row == NumRows - 1 ||
            blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                return true
            }
        }
        return false
    }
    
    func endGame() {
        score = 0
        level = 1
        delegate?.gameDidEnd(swiftris: self)
    }
    
    //  we defined a function which returns yet another tuple. This time it's composed of two arrays: linesRemoved and fallenBlocks. linesRemoved maintains each row of blocks which the user has filled in.
         func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
             var removedLines = Array<Array<Block>>()
             for row in (1..<NumRows).reversed() {
                 var rowOfBlocks = Array<Block>()
    
                //  we use a for loop which iterates from 0 all the way up to, but not including NumColumns, 0 to 9. This for loop adds every block in a given row to a local array variable named rowOfBlocks. If it ends up with a full set, 10 blocks in total, it counts that as a removed line and adds it to the return variable.
                 for column in 0..<NumColumns {
                     guard let block = blockArray[column, row] else {
                         continue
                     }
                     rowOfBlocks.append(block)
                 }
                 if rowOfBlocks.count == NumColumns {
                     removedLines.append(rowOfBlocks)
                     for block in rowOfBlocks {
                         blockArray[block.column, block.row] = nil
                     }
                 }
             }

        //   we check and see if we recovered any lines at all, if not, we return empty arrays.
             if removedLines.count == 0 {
                 return ([], [])
             }
        //  we add points to the player's score based on the number of lines they've created and their level. If their points exceed their level times 1000, they level up and we inform the delegate.
             let pointsEarned = removedLines.count * PointsPerLine * level
             score += pointsEarned
             if score >= level * LevelThreshold {
                 level += 1
                delegate?.gameDidLevelUp(swiftris: self)
             }

             var fallenBlocks = Array<Array<Block>>()
             for column in 0..<NumColumns {
                 var fallenBlocksArray = Array<Block>()
                
                //  we count upwards towards the top of the game board. As we do so, we take each remaining block we find on the game board and lower it as far as possible. fallenBlocks is an array of arrays, we've filled each sub-array with blocks that fell to a new position as a result of the user clearing lines beneath them.
                 for row in (1..<removedLines[0][0].row).reversed() {
                     guard let block = blockArray[column, row] else {
                         continue
                     }
                     var newRow = row
                     while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                         newRow += 1
                     }
                     block.row = newRow
                     blockArray[column, row] = nil
                     blockArray[column, newRow] = block
                     fallenBlocksArray.append(block)
                 }
                 if fallenBlocksArray.count > 0 {
                     fallenBlocks.append(fallenBlocksArray)
                 }
             }
             return (removedLines, fallenBlocks)
         }
    
//  This function loops through and creates rows of blocks in order for the game scene to animate them off the game board. Meanwhile, it nullifies each location in the block array to empty it entirely, preparing it for a new game.
    func removeAllBlocks() -> Array<Array<Block>> {
        var allBlocks = Array<Array<Block>>()
        for row in 0..<NumRows {
            var rowOfBlocks = Array<Block>()
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
                blockArray[column, row] = nil
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
    
    
    //  Dropping a shape is the act of sending it plummeting towards the bottom of the game board. The user will elect to do this when their patience for the slow-moving Tetromino wears thin. dropShape() provides a convenient function to achieve this. It will continue dropping the shape by a single row until it detects an illegal placement state, at which point it will raise it and then notify the delegate that a drop has occurred.

    //  These functions use conditional assignments before taking action, this guarantees that regardless of what state the user interface is in, Swiftris will never operate on invalid shapes.
    func dropShape() {
        guard let shape = fallingShape else {
            return
        }
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDidDrop(swiftris: self)
    }
}

