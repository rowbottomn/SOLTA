//
//  Imaging.swift
//  C
//
//  Created by Nathan Rowbottom on 2018-05-29.
//  Copyright © 2018 Guest User. All rights reserved.
//

import Foundation
import UIKit
import GLKit
import AVFoundation
import CoreMotion
import CoreGraphics
import PhotosUI

struct detectionEvent{
    
}


enum DetectionModes {
    case YUV420v
    case BGRA
}

enum OperationState {
    case TESTING
    case CALIBRATION
    case DETECTION
    case OTHER
}

class Imaging{
    
    @IBOutlet weak var cameraView: GLKView!
    //Singleton class to frontload burden or setup
    static let helper = Imaging()
    
    static var cameraView = GLKView()
    
    //this is an image which we start with when we start detecting, also alllows us to start other objects.
    static var lastImage = UIImage(named: "App Logo 167x167.png")
    static var cgimage = lastImage?.cgImage!
    static var ciimage = CIImage(cgImage: cgimage!)

    static var cgcontext = UIGraphicsGetCurrentContext()!

    //make the queue for the frames
    let imageQueue = DispatchQueue(label:"ca.hdsb.solta.queue")

    //MARK: glContext object construction
    lazy var glContext: EAGLContext = {
        let glContext = EAGLContext(api: .openGLES3)
        return glContext!
    }()
    
    //GLKView is used for views that use OpenGL ES
    //testing
    lazy var glView: GLKView = {
        let glView = GLKView(frame: CGRect(x: 0, y: 0, width: self.cameraView.bounds.width, height: self.cameraView.bounds.height), context: self.glContext)
        glView.bindDrawable() //bind the glView to the OpenGl instance.  Maybe need to switch this to the GLKViewController
        
        return glView
    }()
    
    //CIContext is used for image processing
    lazy var ciContext: CIContext = {
        let ciContext = CIContext(eaglContext: self.glContext)
        return ciContext
    }()
    
}
