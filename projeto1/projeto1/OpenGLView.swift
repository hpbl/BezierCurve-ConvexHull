//
//  OpenGLView.swift
//  projeto1
//
//  Created by Hilton Pintor Bezerra Leite on 19/10/16.
//  Copyright © 2016 Pintor&Chien. All rights reserved.
//

import Foundation
import AppKit
import Cocoa
import OpenGL
import GLKit
import GLUT

class OpenGLView: NSOpenGLView {
    
    //MARK: - Class properties
    var controlPoints: [NSPoint] = [] {
        //updates interface when new value is attributed
        didSet {
            if controlPoints != oldValue {
                if controlPoints.count > 1{
                    self.bezierCurve()
                    self.convexHull(of: controlPoints)
                }
                self.setNeedsDisplay(self.frame)
            }
        }
    }
    
    var curvePoints : [NSPoint] = [] {
        //updates interface when new value is attributed
        didSet {
            if curvePoints != oldValue {
                self.setNeedsDisplay(self.frame)
            }
        }
    }
    
    var convexHull : [NSPoint] = []
    
    var shouldDrawHull : Bool = false {
        didSet {
            self.setNeedsDisplay(self.frame)
        }
    }
    
    override var acceptsFirstResponder: Bool { return true }


    
    //MARK: - Point methods
    //normalizing point to [-1, 1]
    func normalize(point: NSPoint) -> NSPoint{
        var normalizedPoint: NSPoint = point
        
        normalizedPoint.x = (((point.x - self.frame.width)*(1 - (-1)))/(self.frame.width)) - (-1)
        normalizedPoint.y = (((point.y - self.frame.height)*(1 - (-1)))/(self.frame.height)) - (-1)
        
        return normalizedPoint
    }
    
    func foundPoint(on mouseClick: NSPoint) -> Int? {
        
        //creating rect centered where user clicked
        let touchRect : CGRect = CGRect(x: mouseClick.x-15, y: mouseClick.y-15, width: 30, height: 30)
        
        for index in (0..<self.controlPoints.count) {
            if touchRect.contains(self.controlPoints[index]) {
                return index
            }
        }
        return nil
    }
    

    // MARK: - Drawing methods
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        //clearing the color buffer and setting bg color
        glClearColor(40/255, 43/255, 53/255, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    
        self.draw(points: self.controlPoints)
        if self.controlPoints.count > 1 {
           // self.drawCurve(points: self.curvePoints)
            self.drawCurveLines()
        }
        
        if self.controlPoints.count > 2 && self.shouldDrawHull {
            self.drawConvexHull(from: self.convexHull)
        }
        
        //forcing execution of GL commands
        glFlush()
    }
    
    // OpengL routine to draw points
    func draw(points: [NSPoint]) {
        glPointSize(6.0)
        glColor3f(225/255, 61/255, 121/255)
        glBegin(GLenum(GL_POINTS))
        
        for point in points {
            let normPoint = self.normalize(point: point)
            glVertex3fv([Float(normPoint.x), Float(normPoint.y), 0])
        }
        
        glEnd();
    }
    
    // OpengL routine to draw curve
    func drawCurve(from points: [NSPoint]) {
        glPointSize(2.0)
        glColor3f(0, 170/255, 202/255)
        glBegin(GLenum(GL_POINTS))
        
        for point in points {
            let normPoint = self.normalize(point: point)
            glVertex3fv([Float(normPoint.x), Float(normPoint.y), 0])
        }
        
        glEnd();
    }

    
    func drawCurveLines() {
        
        glLineWidth(0.5);
        glColor3f(0, 170/255, 202/255);
        glBegin(GLenum(GL_LINES));
        
        if(curvePoints.count > 1){
            for index in (0..<(self.curvePoints.count)) {
                let point = self.normalize(point: curvePoints[index])
                var nextPoint : NSPoint
                
                if(index == self.curvePoints.count-1){
                    nextPoint = self.normalize(point: controlPoints[self.controlPoints.endIndex-1])
                }
                else{
                    nextPoint = self.normalize(point: curvePoints[index+1])
                }

                glVertex3fv([Float(point.x), Float(point.y), 0])
                glVertex3fv([Float(nextPoint.x), Float(nextPoint.y), 0])
                
            }
        }
        
        glEnd();
        
    }
    func drawConvexHull(from points: [NSPoint]) {
        glLineWidth(2.5)
        glColor3f(77/255, 192/255, 86/255)
        glBegin(GLenum(GL_LINES))
        
        for index in (0..<self.convexHull.count) {
            let normPoint = self.normalize(point: self.convexHull[index])
            var nextNormPoint : NSPoint
            if index == self.convexHull.count-1 {
                nextNormPoint = self.normalize(point: self.convexHull[0])
            } else {
                nextNormPoint = self.normalize(point: self.convexHull[index+1])
            }
            glVertex3fv([Float(normPoint.x), Float(normPoint.y), 0])
            glVertex3fv([Float(nextNormPoint.x), Float(nextNormPoint.y), 0])

        }
        
        glEnd();
    }
    
    
    // MARK: - Mouse and Keyboard methods
    override func mouseDown(with event: NSEvent) {
        //loop control variables
        var keepOn: Bool = true
        var isDragging: Bool = false
        
        let mouseDragOrUp : NSEventMask = NSEventMask(rawValue: UInt64(Int(NSEventMask.leftMouseUp.union(.leftMouseDragged).rawValue)))
        
        while (keepOn) {
            
            let nextEvent : NSEvent = (self.window?.nextEvent(matching: mouseDragOrUp))!
            let mouseLocation: NSPoint = self.convert(nextEvent.locationInWindow, from: nil)
            let isInsideWindow: Bool = self.mouse(mouseLocation, in: self.bounds)
            
            switch (nextEvent.type) {
                
            case NSEventType.leftMouseDragged:
                isDragging = true
                if let index = self.foundPoint(on: mouseLocation) {
                    //move point to mouse location
                    self.controlPoints[index] = mouseLocation
                }
                break
                
            case NSEventType.leftMouseUp:
                if (isInsideWindow && !isDragging) {
                    //create new point
                    self.controlPoints.append(mouseLocation)
                }
                isDragging = false
                keepOn = false
                break
                
            default:
                // Ignoring any other type of event
                break
            }
        }
        return
    }
    
    override func rightMouseDown(with event: NSEvent) {
        
        //converting screen to window coordinates
        let touchPoint : NSPoint = self.convert(event.locationInWindow, from: nil)
        
        if let index = self.foundPoint(on: touchPoint) {
            self.controlPoints.remove(at: index)
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 8 {
            self.shouldDrawHull = !self.shouldDrawHull
        }
    }
    
    
    // MARK: - deCasteljau
    func linearInterpolation(of pointA: NSPoint, and pointB: NSPoint, by t: Double) -> NSPoint {
        var interpolation: NSPoint = NSPoint()
        
        // Interpolation of X coordinates
        let pointAInterX = (1-t)*Double((pointA.x))
        let pointBInterX = Double(pointB.x)*t
        interpolation.x = CGFloat(pointAInterX + pointBInterX)
    
        // Interpolation of X coordinates
        let pointAInterY = (1-t)*Double((pointA.y))
        let pointBInterY = Double(pointB.y)*t
        interpolation.y = CGFloat(pointAInterY + pointBInterY)
        
        return interpolation
    }
    
    func curvePoint(from controlPoints: [NSPoint], t: Double) -> NSPoint {
        var controlPointsAux : [NSPoint] = controlPoints
        
        for column in (1..<controlPointsAux.count) {
            for index in (0..<controlPointsAux.count-column) {
                controlPointsAux[index] = linearInterpolation(of: controlPointsAux[index], and: controlPointsAux[index+1], by: t)
            }
        }
        return controlPointsAux[0]
    }
    
    func bezierCurve() {
        self.curvePoints = []
        var factor = 0.0
        while factor < 1 {
            
            self.curvePoints.append(curvePoint(from: controlPoints, t: factor))
            factor = factor + 0.05
        }
    }
    
    
    // MARK: - Convex Hull
    func convexHull(of controlPoints: [NSPoint]) {
        //Sorting the points by x-coordinate (in case of a tie, sorting by y-coordinate)
        let sortedPoints = controlPoints.sorted { (pointA, pointB) -> Bool in
            return (pointA.x == pointB.x) ? (pointA.y > pointB.y) : (pointA.x > pointB.x)
        }
        
        var upperHull : [NSPoint] = []
        var lowerHull : [NSPoint] = []

        /*while L contains at least two points and the sequence of last two points
        of L and the point P[i] does not make a counter-clockwise turn:
        remove the last point from L*/
        for point in sortedPoints {
            while (lowerHull.count >= 2) &&
                  (self.crossProduct(pointO: lowerHull[lowerHull.count-2],
                                     pointA: lowerHull[lowerHull.count-1],
                                     pointB: point) <= 0) {
                lowerHull.removeLast()
            }
            lowerHull.append(point)
        }
        
        /*for i = n, n-1, ..., 1:
         while U contains at least two points and the sequence of last two points
         of U and the point P[i] does not make a counter-clockwise turn:
         remove the last point from U
         append P[i] to U*/
        for point in sortedPoints.reversed() {
            while (upperHull.count >= 2) &&
                (self.crossProduct(pointO: upperHull[upperHull.count-2],
                                   pointA: upperHull[upperHull.count-1],
                                   pointB: point) <= 0) {
                                    upperHull.removeLast()
            }
            upperHull.append(point)
        }
 
        //removing duplicates
        //lowerHull.removeLast()
        upperHull.removeLast()
 
        self.convexHull = lowerHull + upperHull
    }
 
    func crossProduct(pointO: NSPoint, pointA: NSPoint, pointB: NSPoint) -> Double {
        /*  2D cross product of OA and OB vectors, i.e. z-component of their 3D cross product.
         Returns a positive value, if OAB makes a counter-clockwise turn,
         negative for clockwise turn, and zero if the points are collinear.*/
        let part1 = (pointA.x - pointO.x) * (pointB.y - pointO.y)
        let part2 = (pointA.y - pointO.y) * (pointB.x - pointO.x)
        return  Double(part1 - part2)
    }
    
}






