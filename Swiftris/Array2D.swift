//
//  Array2D.swift
//  Swiftris
//
//  Created by aiaiai on 4/22/20.
//  Copyright © 2020 aiaiai. All rights reserved.
//

import Foundation

//<T> allows our array to store any data type and remain a general-purpose tool.
class Array2D<T> {
    let columns: Int
    let rows: Int
    
    //A ? in Swift symbolizes an optional value.
    //  An optional value is just that, optional. Optional variables may or may not contain data, and they may in fact be nil, or empty. nil locations found on our game board will represent empty spots where no block is present.
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        
        //tutorial told to do this array = Array<T?>(count:rows * columns, repeatedValue: nil)
        //} but there's an error "Incorrect argument labels in call (have 'count:repeatedValue:', expected 'unsafeUninitializedCapacity:initializingWith:')" so we changed it to repeating: nil, count:rows * columns
        
        // we instantiate our internal array structure with a size of rows x columns. This guarantees that Array2D can store all the objects our game board requires, 200 in our case.
        array = Array<T?>(repeating: nil, count:rows * columns)
    }
    
    //we create a custom subscript for Array2D. We wanted to have a subscript capable of supporting array[column, row], this accomplishes that. The getter is self-explanatory. To get the value at a given location we need to multiply the provided row by the class variable columns, then add the column number to reach the final destination.
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}
