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
    func removePoint(inside rectangle: CGRect) {
        for index in (0..<self.controlPoints.count) {
            if rectangle.contains(self.controlPoints[index]) {
                self.controlPoints.remove(at: index)
                break
            }
        }
    }
    
    //normalizing point to [-1, 1]
    func normalize(point: NSPoint) -> NSPoint{
        var normalizedPoint: NSPoint = point
        
        normalizedPoint.x = (((point.x - self.frame.width)*(1 - (-1)))/(self.frame.width)) - (-1)
        normalizedPoint.y = (((point.y - self.frame.height)*(1 - (-1)))/(self.frame.height)) - (-1)
        
        return normalizedPoint
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
    //called when left mouse button is clicked
    override func mouseDown(with event: NSEvent) {
        
        
        var theEvent: NSEvent
        var keepOn: Bool = true
        var isInside: Bool = false
        var mouseLoc: NSPoint
        var dragging: Bool = false
        
        while (keepOn) {
            theEvent = (self.window?.nextEvent(matching: NSEventMask(rawValue: UInt64(Int(NSEventMask.leftMouseUp.union(.leftMouseDragged).rawValue))))!)!
            mouseLoc = self.convert(theEvent.locationInWindow, from: nil)
            isInside = self.mouse(mouseLoc, in: self.bounds)
            //creating rect centered where user clicked
            let touchRect : CGRect = CGRect(x: mouseLoc.x-15, y: mouseLoc.y-15, width: 30, height: 30)
            
            switch (theEvent.type) {
            case NSEventType.leftMouseDragged:
                dragging = true
                for index in (0..<self.controlPoints.count) {
                    if touchRect.contains(self.controlPoints[index]) {
                        self.controlPoints[index] = mouseLoc
                        break
                    }
                }
                break;
            case NSEventType.leftMouseUp:
                if (isInside && !dragging) {
                    //converting screen to window coordinates
                    let touchPoint: NSPoint = self.convert(event.locationInWindow, from: nil)
                    
                    self.controlPoints.append(touchPoint)
                }
                //do something
                dragging = false
                keepOn = false
                break;
            default:
                /* Ignore any other kind of event. */
                break;
            }
            
        }
        
        return;
    }
    
    //called when right mouse button is clicked
    override func rightMouseDown(with event: NSEvent) {
        
        //converting screen to window coordinates
        let touchPoint : NSPoint = self.convert(event.locationInWindow, from: nil)
        
        //creating rect centered where user clicked
        let touchRect : CGRect = CGRect(x: touchPoint.x-5, y: touchPoint.y-5, width: 10, height: 10)
        
        self.removePoint(inside: touchRect)
    }
    
}






