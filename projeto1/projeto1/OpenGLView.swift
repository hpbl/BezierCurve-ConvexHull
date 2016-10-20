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
        
        for point in controlPoints {
            glVertex3fv([Float(point.x), Float(point.y), 0])
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
        
        self.controlPoints.append(normalizedTouchPoint)
        
        //calling draw again
        self.setNeedsDisplay(self.frame)
    }
    
    
    //normalizing point to [-1, 1]
    func normalize(point: NSPoint) -> NSPoint{
        var normalizedPoint : NSPoint = point
       
        normalizedPoint.x = (((point.x - self.frame.width)*(1 - (-1)))/(self.frame.width)) - (-1)
        normalizedPoint.y = (((point.y - self.frame.height)*(1 - (-1)))/(self.frame.height)) - (-1)
        
        return normalizedPoint
    }
    

    
}
