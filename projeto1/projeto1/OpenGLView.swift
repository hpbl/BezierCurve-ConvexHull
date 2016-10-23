//
//  OpenGLView.swift
//  projeto1
//
//  Created by Hilton Pintor Bezerra Leite on 19/10/16.
//  Copyright © 2016 Pintor&Chien. All rights reserved.
//

import Foundation
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
                self.setNeedsDisplay(self.frame)
            }
        }
    }
    
    
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
        glClearColor(0.2, 0.3, 0.3, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    
        self.drawControlPoints()

        //forcing execution of GL commands
        glFlush()
    }
    
    // OpengL routine to draw points
    func drawControlPoints() {
        glPointSize(5.0)
        glColor3f(1.0, 1.0, 0.0)
        glBegin(GLenum(GL_POINTS))
        
        for point in self.controlPoints {
            let normPoint = self.normalize(point: point)
            glVertex3fv([Float(normPoint.x), Float(normPoint.y), 0])
        }
        
        glEnd();
    }
    
    
    // MARK: - Mouse methods
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
    
}






