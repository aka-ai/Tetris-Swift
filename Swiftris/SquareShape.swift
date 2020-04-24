//
//  SquareShape.swift
//  Swiftris
//
//  Created by aiaiai on 4/23/20.
//  Copyright © 2020 aiaiai. All rights reserved.
//

class SquareShape:Shape {
     /*
// #9
         | 0•| 1 |
         | 2 | 3 |

     • marks the row/column indicator for the shape

     */

     // The square shape will not rotate

// #we've overridden the blockRowColumnPositions computed property to provide a full dictionary of tuple arrays. Each index of the arrays represents one of the four blocks ordered from block 0 to block 3
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero: [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.Ninety: [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.OneEighty: [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.TwoSeventy: [(0, 0), (1, 0), (0, 1), (1, 1)]
        ]
    }

// #we perform a similar override by providing a dictionary of bottom block arrays. A square shape does not rotate, so its bottom-most blocks are consistently the third and fourth blocks
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:  [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:     [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}
