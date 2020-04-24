//
//  Block.swift
//  Swiftris
//
//  Created by aiaiai on 4/22/20.
//  Copyright © 2020 aiaiai. All rights reserved.
//

import SpriteKit

//we define the number of colors available to Swiftris, six
let NumberOfColors: UInt32 = 6

//we declare the enumeration. Its type is Int and it implements the CustomStringConvertible protocol.
//https://docs.swift.org/swift-book/LanguageGuide/Protocols.html
//Classes, structures and enums that implement CustomStringConvertible are capable of generating human-readable strings when debugging or printing their value to the console.
enum BlockColor: Int, CustomStringConvertible {
    
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
    
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
    //we declare yet another computed property, description. Adhering to the CustomStringConvertible property requires us to provide this function. Without it, our code will fail to compile. It returns the spriteName of the color to describe the object.
    var description: String {
        return self.spriteName
    }
    
    //this function returns a random choice among the colors found in BlockColor. It creates a BlockColor using the rawValue:Int initializer to setup an enumeration which assigned to the numerical value passed into it, in our case numbers 0 through 5.
    static func random() -> BlockColor {
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
}

//we declare Block as a class which implements both the CustomStringConvertible and Hashable protocols. Hashable allows us to store Block in Array2D.
class Block: Hashable, CustomStringConvertible {
    
    let color: BlockColor
    
    var column: Int
    var row: Int
    // The SKSpriteNode will represent the visual element of the Block which GameScene will use to render and animate each Block.
    var sprite: SKSpriteNode?
    var spriteName: String {
        return color.spriteName
    }
    
    //we implemented the hashValue calculated property, which Hashable requires us to provide. We return the exclusive-or of our row and column properties to generate a unique integer for each Block.
    //** original is  var hashValue: Int {
    //            return self.column ^ self.row
    //        }
    func hash(into hasher: inout Hasher) {
        _ = self.column ^ self.row
    }
    
    //we implement description as we must do to adhere to the CustomStringConvertible protocol. We can place CustomStringConvertible object types in the middle of a string by surrounding them with \( and )
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column:Int, row:Int, color:BlockColor) {
        self.column = column
        self.row = row
        self.color = color
    }
}

// we create a custom operator, ==, when comparing one Block with another. It returns true if both Blocks are in the same location and of the same color. The Hashable protocol inherits from the Equatable protocol, which requires us to provide this operator.
func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}


