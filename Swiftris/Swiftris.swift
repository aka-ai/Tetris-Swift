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

 class Swiftris {
     var blockArray:Array2D<Block>
     var nextShape:Shape?
     var fallingShape:Shape?

     init() {
         fallingShape = nil
         nextShape = nil
         blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
     }

     func beginGame() {
         if (nextShape == nil) {
            nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
         }
     }

// #we have a method which assigns nextShape, our preview shape, as fallingShape. fallingShape is the moving Tetromino. newShape() then creates a new preview shape before moving fallingShape to the starting row and column. This method returns a tuple of optional Shape objects
     func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
         fallingShape = nextShape
        nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(column: StartingColumn, row: StartingRow)
         return (fallingShape, nextShape)
     }
 }
