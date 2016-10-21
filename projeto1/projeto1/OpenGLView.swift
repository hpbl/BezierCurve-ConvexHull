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
    
    var controlPoints : [NSPoint] = []

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        //Defining size of rendering window
        //glViewport(0, 0, GLsizei(self.frame.size.width), GLsizei(self.frame.size.height))
        
        //clearing the color buffer and setting bg color
        glClearColor(0.2, 0.3, 0.3, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    
        //drawing points
        glPointSize(5.0)
        glColor3f(1.0, 1.0, 0.0)
        glBegin(GLenum(GL_POINTS))
        
        for point in self.controlPoints {
            let normPoint = self.normalize(point: point)
            glVertex3fv([Float(normPoint.x), Float(normPoint.y), 0])
        }
        
        glEnd();

        //forcing execution of GL commands
        glFlush()
    
        
    }
    
    
    //called when mouse is clicked
    override func mouseDown(with event: NSEvent) {
        
        //converting screen to window coordinates
        let eventLocation : NSPoint = event.locationInWindow
        let touchPoint : NSPoint = self.convert(eventLocation, from: nil)
        let normalizedTouchPoint : NSPoint = self.normalize(point: touchPoint)
        
        self.controlPoints.append(touchPoint)
        
        //calling draw again
        self.setNeedsDisplay(self.frame)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        
        //converting screen to window coordinates
        let eventLocation : NSPoint = event.locationInWindow
        let touchPoint : NSPoint = self.convert(eventLocation, from: nil)
        let normalizedTouchPoint : NSPoint = self.normalize(point: touchPoint)
        
        var touchRect : CGRect = CGRect(x: touchPoint.x-5, y: touchPoint.y-5, width: 10, height: 10)
        
        self.remove(point: normalizedTouchPoint, within: touchRect)
        
        self.setNeedsDisplay(self.frame)
        
        
    }
    
    func remove(point: NSPoint, within: CGRect) {
        
        
        
        for index in (0..<self.controlPoints.count) {
            if within.contains(self.controlPoints[index]) {
                self.controlPoints.remove(at: index)
                break
            }
        }
    }
    
    
    //normalizing point to [-1, 1]
    func normalize(point: NSPoint) -> NSPoint{
        var normalizedPoint : NSPoint = point
       
        normalizedPoint.x = (((point.x - self.frame.width)*(1 - (-1)))/(self.frame.width)) - (-1)
        normalizedPoint.y = (((point.y - self.frame.height)*(1 - (-1)))/(self.frame.height)) - (-1)
        
        return normalizedPoint
    }
    

    
}
