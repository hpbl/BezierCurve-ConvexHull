//
//  Extensions.swift
//  projeto1
//
//  Created by Hilton Pintor Bezerra Leite on 21/10/16.
//  Copyright © 2016 Pintor&Chien. All rights reserved.
//

import Foundation

extension NSPoint {
    func round(places: Int) -> NSPoint {
        
        var roundedPoint : NSPoint = NSPoint()
        roundedPoint.x = CGFloat(Double(String(format: "%.2f", self.x))!)
        roundedPoint.y = CGFloat(Float(String(format: "%.2f", self.y))!)
        
        return roundedPoint
    }
}
