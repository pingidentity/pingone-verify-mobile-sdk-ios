//
// SCAVCaptureWrapper.swift
// ShoLib
//
// SHOCARD CONFIDENTIAL
// __________________
// (C) COPYRIGHT 2017 ShoCard, Inc. All Rights Reserved.
// NOTICE: All information contained herein is the property of ShoCard, Inc.
// The intellectual and technical concepts contained herein are proprietary to
// ShoCard, Inc., and may be covered by U.S. and Foreign Patents, patents
// in process, and are protected by trade secret or copyright law.
// Dissemination or reproduction of this material is strictly forbidden unless
// prior written permission is obtained from ShoCard, Inc.
//

import UIKit
import AVFoundation

public protocol SCImageProcessingDelegate {
    func capturedImage(_ image: UIImage, rect: CGRect)
    func capturedMetadata(_ metadata: String)
}

public enum CameraDevicePosition {
    case frontcamera, backcamera
    
    var cameraPosition: AVCaptureDevice.Position {
        switch self {
        case .frontcamera:
            return .front
        default:
            return .back
        }
    }
}

public enum FocusMode {
    
    case auto, continuousAuto, locked
    
    var focusMode: AVCaptureDevice.FocusMode {
        switch self {
        case .auto:
            return AVCaptureDevice.FocusMode.autoFocus
        case .continuousAuto:
            return AVCaptureDevice.FocusMode.continuousAutoFocus
        case .locked:
            return AVCaptureDevice.FocusMode.locked
        }
    }
    
}

public enum MetadataObjectType {
    
    case qr, pdf417, face,
         other(objectType: AVMetadataObject.ObjectType)
    
    var metadataObject: AVMetadataObject.ObjectType {
        switch self {
        case .qr:
            return AVMetadataObject.ObjectType.qr
        case .pdf417:
            return AVMetadataObject.ObjectType.pdf417
        case .face:
            return AVMetadataObject.ObjectType.face
        case .other(let objectType):
            return objectType
        }
    }
    
}

public enum FlashMode {
    case on, off, auto
    
    var flashMode: AVCaptureDevice.FlashMode {
        switch self {
        case .on:
            return AVCaptureDevice.FlashMode.on
        case .off:
            return AVCaptureDevice.FlashMode.off
        default:
            return AVCaptureDevice.FlashMode.auto
        }
    }
}

public enum TorchMode {
    case on, off, auto
    
    var torchMode: AVCaptureDevice.TorchMode {
        switch self {
        case .on:
            return AVCaptureDevice.TorchMode.on
        case .off:
            return AVCaptureDevice.TorchMode.off
        default:
            return AVCaptureDevice.TorchMode.auto
        }
    }
}

public enum CroppedOptions {
    case none, croppedToViewPort, croppedToEdges
}

public class CameraView: UIView {
    var session:AVCaptureSession!
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        if let session = self.session{
            if !session.isRunning{
                DispatchQueue.global(qos: .userInitiated).async {
                    session.startRunning()
                }
            }
        }
    }
    
}

public class SCAVCaptureWrapper: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    private let captureView: CameraView?
    private let session: AVCaptureSession = AVCaptureSession()
    public var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var captureDevice: AVCaptureDevice!
    
    private var flashMode: AVCaptureDevice.FlashMode = .auto
    private var cropped: CroppedOptions = .none

    private var delegate: SCImageProcessingDelegate!
    private var capturedImage: UIImage!
    private var videoLayerOrientation: UIInterfaceOrientation!
    
    private var input: AVCaptureDeviceInput?
    private let highlightLayer = CALayer()
    
    public var qrburst:Bool = false
    public var flipImage:Bool = false
    private var fps: Int32 = 10
    private let context = CIContext(options: nil)
    
    private var lastVideoFrameBuffer: CMSampleBuffer?
    private var onFrameReceived: ((CMSampleBuffer?) -> Void)?

    private lazy var focusBoxLayer: CALayer = {
        let box = CALayer()
        box.bounds = CGRect(x: 0, y: 0, width: 75, height: 75)
        box.borderWidth = 2
        box.borderColor = UIColor.white.cgColor
        box.opacity = 0
        box.cornerRadius = 15
        return box
    }()
    
    public init(captureView: CameraView?, delegate: SCImageProcessingDelegate? = nil, videoOrientation: UIInterfaceOrientation) {
        self.captureView = captureView
        self.delegate = delegate
        self.videoLayerOrientation = videoOrientation
        self.captureView?.session = self.session
        super.init()
        guard self.captureView != nil else {
            logerror("SCAVCaptureWrapper: captureView is nil — XIB outlet not connected")
            return
        }
        self.initCapture()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SCAVCaptureWrapper.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func initCapture() {
        //Capture Session
        self.session.sessionPreset = AVCaptureSession.Preset.high
        do {
            try self.addSessionInput(preferredCamera: .back, mediaType: .video)
        } catch {
            logerror("Failed to add input: \(error.localizedDescription)")
            return
        }
        
        //Preview Layer
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        
        // TODO: setup previewlayer orientation
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.captureView?.layer.addSublayer(self.previewLayer)
        self.changeOrientation(self.videoLayerOrientation)
        
        self.setFlashAuto()
        self.setTorchMode(.auto)
        self.addTapToCaptureView()
        self.setFocus(focusMode: .continuousAuto)
        self.addCameraResolutionAppEvent()
    }
    
    private func addTapToCaptureView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(SCAVCaptureWrapper.captureViewTapped))
        self.captureView?.isUserInteractionEnabled = true
        self.captureView?.layer.addSublayer(self.focusBoxLayer)
        self.captureView?.addGestureRecognizer(tap)
    }
    
    @objc public func captureViewTapped(sender: UITapGestureRecognizer? = nil) {
        if (!self.session.isRunning) {
            self.start()
            self.highlightLayer.removeFromSuperlayer()
        }
        guard let device = self.captureDevice,
              let touchLocation = sender?.location(ofTouch: 0, in: self.captureView),
              device.isFocusModeSupported(.autoFocus), device.isFocusPointOfInterestSupported else {
            return
        }
        
        do {
            let focusPoint: CGPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: touchLocation)
            log("Focusing point \(focusPoint.debugDescription)")
            try device.lockForConfiguration()
            device.focusMode = .autoFocus
            device.focusPointOfInterest = focusPoint
            device.exposurePointOfInterest = focusPoint
            device.exposureMode = .continuousAutoExposure
            device.unlockForConfiguration()
            self.showFocusSquare(at: touchLocation)
        } catch {
            logerror("failed to focus. \(error.localizedDescription)")
        }
        
    }
    
    private func showFocusSquare(at location: CGPoint) {
        self.focusBoxLayer.removeAllAnimations()
        let scaleKey = "zoom in focus box"
        let fadeInKey = "fade in focus box"
        let pulseKey = "pulse focus box"
        let fadeOutKey = "fade out focus box"
        guard self.focusBoxLayer.animation(forKey: scaleKey) == nil,
              self.focusBoxLayer.animation(forKey: fadeInKey) == nil,
              self.focusBoxLayer.animation(forKey: pulseKey) == nil,
              self.focusBoxLayer.animation(forKey: fadeOutKey) == nil
        else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.focusBoxLayer.position = location
        CATransaction.commit()
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1
        scale.toValue = 0.375
        scale.duration = 0.3
        scale.isRemovedOnCompletion = false
        scale.fillMode = .forwards
        
        let opacityFadeIn = CABasicAnimation(keyPath: "opacity")
        opacityFadeIn.fromValue = 0
        opacityFadeIn.toValue = 1
        opacityFadeIn.duration = 0.3
        opacityFadeIn.isRemovedOnCompletion = false
        opacityFadeIn.fillMode = .forwards
        
        let pulsing = CABasicAnimation(keyPath: "borderColor")
        pulsing.toValue = UIColor(white: 1, alpha: 0.5).cgColor
        pulsing.repeatCount = 2
        pulsing.duration = 0.2
        pulsing.beginTime = CACurrentMediaTime() + 0.3
        
        let opacityFadeOut = CABasicAnimation(keyPath: "opacity")
        opacityFadeOut.fromValue = 1
        opacityFadeOut.toValue = 0
        opacityFadeOut.duration = 0.5
        opacityFadeOut.beginTime = CACurrentMediaTime() + 1 // seconds
        opacityFadeOut.isRemovedOnCompletion = false
        opacityFadeOut.fillMode = .forwards
        
        self.focusBoxLayer.add(scale, forKey: scaleKey)
        self.focusBoxLayer.add(opacityFadeIn, forKey: fadeInKey)
        self.focusBoxLayer.add(pulsing, forKey: pulseKey)
        self.focusBoxLayer.add(opacityFadeOut, forKey: fadeOutKey)
    }
    
    fileprivate func getCamera(_ preferredCamera: AVCaptureDevice.Position, mediaType: AVMediaType = .video) -> AVCaptureDevice? {
        if let device: AVCaptureDevice = AVCaptureDevice.default(for: mediaType) {
            return device
        }
        
        var deviceTypes: [AVCaptureDevice.DeviceType] = []
        deviceTypes.append(.builtInWideAngleCamera)
        deviceTypes.append(.builtInTripleCamera)
        deviceTypes.append(.builtInDualCamera)
        deviceTypes.append(.builtInTrueDepthCamera)
        deviceTypes.append(.builtInTelephotoCamera)
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: mediaType, position: preferredCamera)
        let devices = discoverySession.devices
        guard !devices.isEmpty else {
            return nil
        }
        return devices.first { $0.position == preferredCamera }
    }
    
    private func isInputPresent(preferredCamera: AVCaptureDevice.Position, mediaType: AVMediaType) -> Bool {
        return self.input != nil &&
            self.session.inputs.count > 0 &&
            preferredCamera == self.input!.device.position &&
            self.input!.device.hasMediaType(mediaType)
    }
    
    private func addSessionInput(preferredCamera: AVCaptureDevice.Position, mediaType: AVMediaType = .video) throws {
        if (self.session.isRunning) {
            self.session.stopRunning()
        }
        
        if self.isInputPresent(preferredCamera: preferredCamera, mediaType: mediaType) {
            return
        }
        
        if let input = self.input {
            self.session.removeInput(input)
        }
        
        guard let device: AVCaptureDevice = self.getCamera(preferredCamera, mediaType: mediaType) else {
            logerror("Could not get preferred camera")
            return
        }
        self.captureDevice = device
        log("Selected Camera: \(self.captureDevice.localizedName)")
        
        self.input = try AVCaptureDeviceInput(device: self.captureDevice)
        if let input = self.input,
            self.session.canAddInput(input) {
            self.session.addInput(input)
        } else {
            logerror("Unable to add device input")
            return
        }
    }
    
    public func addStillCameraOutput(_ preferredCamera: CameraDevicePosition) {
        do {
            //Input
            try self.addSessionInput(preferredCamera: preferredCamera.cameraPosition)
            self.setFocus(focusMode: .continuousAuto)

            //Output
            if (!self.isOutputOfTypePresent(output: AVCapturePhotoOutput.self)) {
                let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
                if (self.session.canAddOutput(photoOutput)) {
                    self.session.addOutput(photoOutput)
                    self.photoOutput = photoOutput
                } else {
                    logerror("Unable to add still image output")
                    return
                }
            } else {
                log("Still Image Output already present")
            }
        } catch {
            logerror(error)
        }
    }
    
    private func isOutputOfTypePresent<T>(output: T.Type) -> Bool {
        let outputs = self.session.outputs
        for o in outputs {
            if (o is T) {
                return true
            }
        }
        return false
    }
    
    public func hasObjectRect() -> Bool {
        return self.highlightLayer.superlayer != nil
    }
    
    public func drawObjectRect(rect: CGRect, borderColor: CGColor = UIColor.green.cgColor, cornerRadius: CGFloat = 0, borderWidth: CGFloat = 3) {
        DispatchQueue.main.async {
            self.clearObjectRects()
            self.highlightLayer.frame = rect
            self.highlightLayer.cornerRadius = cornerRadius
            self.highlightLayer.borderWidth = borderWidth
            self.highlightLayer.borderColor = borderColor
            self.captureView?.layer.addSublayer(self.highlightLayer)
        }
    }
    
    public func updateObjectRectBounds(rect: CGRect) {
        guard self.hasObjectRect() else {
            return
        }
        
        self.highlightLayer.frame = rect
    }
    
    public func updateObjectRectColor(color: CGColor) {
        guard self.hasObjectRect() else {
            return
        }
        
        self.highlightLayer.borderColor = color
    }
    
    public func clearObjectRects() {
        self.highlightLayer.removeFromSuperlayer()
    }
    
    var faceRectangles: [Int: CALayer] = [:]
    private func drawFaceRect(_ face: SCFace) {
        DispatchQueue.main.async {
            let faceRectLayer: CALayer
            if let layer = self.faceRectangles[face.faceId] {
                faceRectLayer = layer
            } else {
                faceRectLayer = CALayer()
                faceRectLayer.cornerRadius = 10
                faceRectLayer.borderWidth = 3
                faceRectLayer.borderColor = UIColor.green.cgColor
                self.captureView?.layer.addSublayer(faceRectLayer)
                self.faceRectangles[face.faceId] = faceRectLayer
            }
            faceRectLayer.frame = face.boundingBox
        }
    }
    
    private func clearFaceRects() {
        self.faceRectangles.forEach{ $0.value.removeFromSuperlayer() }
    }
    
    public enum FaceDetectionEvent {
        case noFaceInFrame
        case faceFoundInFrame(face: SCFace)
        case multipleFacesInFrame(faces: [SCFace])
    }
    
    var onFaceDetectionEvent: ((_ event: FaceDetectionEvent) -> Void)?
    var drawFaceRect: Bool = false
    
    public func addFaceDetection(_ preferredCamera: CameraDevicePosition, onFaceDetectionEvent: ((_ event: FaceDetectionEvent) -> Void)?, drawFaceRect: Bool = false, onFrameCaptured: ((CMSampleBuffer?) -> Void)?) {
        do {
            try self.addSessionInput(preferredCamera: preferredCamera.cameraPosition, mediaType: .metadata)
        } catch {
            logerror(error)
            return
        }
        
        let output = AVCaptureMetadataOutput()
        if (self.session.canAddOutput(output)) {
            self.session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.face]
            self.drawFaceRect = drawFaceRect
            self.onFaceDetectionEvent = onFaceDetectionEvent
            
            if let onVideoFrame = onFrameCaptured {
                self.addVideoFrameOutput(preferredCamera, onFrameReceived: onVideoFrame)
            }
        } else {
            log("Cannot add output.")
        }
    }
    var prevFaceId: Int = -1
    // This is called when we find a known barcode type with the camera.
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        var highlightViewRect = CGRect.zero
        if (output.metadataObjectTypes.contains(.face)) {
            if (metadataObjects.count == 0) {
                if (self.prevFaceId != -1) {
//                    log("Face moved out of frame")
                }
                self.prevFaceId = -1
                self.onFaceDetectionEvent?(FaceDetectionEvent.noFaceInFrame)
            } else {
                var faceIds: [Int] = []
                let faces: [SCFace] = metadataObjects.reduce(into: [SCFace]()) { (result, metadata) in
                    guard let face = metadata as? AVMetadataFaceObject else {
                        return
                    }
                    highlightViewRect = self.previewLayer.transformedMetadataObject(for: face)?.bounds ?? face.bounds
                    let scFace = SCFace(faceId: face.faceID, boundingBox: highlightViewRect, hasSmile: false, isLeftEyeClosed: false, isRightEyeClosed: false, headTiltAngle: Float(face.rollAngle))
                    
                    if (self.drawFaceRect) {
                        self.drawFaceRect(scFace)
                    }
                    faceIds.append(scFace.faceId)
                    result.append(scFace)
                }
                DispatchQueue.main.async {
                    self.faceRectangles.filter {!faceIds.contains($0.key)}.forEach{
                        $0.value.removeFromSuperlayer()
                        self.faceRectangles.removeValue(forKey: $0.key)
                    }
                }
                
                if faces.count == 1, let face = faces.first {
                    if (self.prevFaceId != face.faceId) {
//                        log("Found face with id: \(face.faceId)")
                    }
                    self.prevFaceId = face.faceId
                    self.onFaceDetectionEvent?(FaceDetectionEvent.faceFoundInFrame(face: face))
                } else if faces.count > 1 {
                    if (self.prevFaceId != -1) {
//                        log("Multiple faces found")
                    }
                    self.prevFaceId = -1
                    self.onFaceDetectionEvent?(FaceDetectionEvent.multipleFacesInFrame(faces: faces))
                } else {
//                    log("Control shouldn't reach here ever")
                    self.onFaceDetectionEvent?(FaceDetectionEvent.noFaceInFrame)
                }
            }
            
            return
        }
        
        var detectionString : String!
        
        if (!self.qrburst) {
            self.session.stopRunning()
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        // The scanner is capable of capturing multiple captures in one scan.
        for metadata in metadataObjects {
            // is it something machine-readable?...
            if let object = metadata as? AVMetadataMachineReadableCodeObject {
                // ...a barcode, perhaps?
                if let barCodeObject : AVMetadataObject = self.previewLayer.transformedMetadataObject(for: object) {
                    
                    if (!self.qrburst) {
                        highlightViewRect = barCodeObject.bounds // or is it bounds
                        self.drawObjectRect(rect: CGRect(x: highlightViewRect.origin.x-3, y: highlightViewRect.origin.y-3,
                                                         width: highlightViewRect.size.width+6,height: highlightViewRect.size.height+6))
                    }
                    // takeStillImage(false)
                    //
                    // let cropCGImage:CGImageRef = CGImageCreateWithImageInRect(self.capturedImage.CGImage, highlightViewRect)!
                    // self.capturedImage = UIImage(CGImage:cropCGImage, scale:1, orientation:self.capturedImage.imageOrientation)
                    // if (self.delegate != nil) {
                    //       self.delegate.capturedImage(self.capturedImage)
                    // }
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    if (self.delegate != nil) {
                        self.delegate.capturedMetadata(detectionString)
                    }
                }
            }
            break
        }
    }
    
    public func takeStillImage(_ cropped: CroppedOptions = .none) {
        self.cropped = cropped
        guard let previewLayerConnection = self.previewLayer.connection else {
            logerror("Error getting connection from preview layer")
            return
        }
        let videoOrientation =  previewLayerConnection.videoOrientation
        guard let photoOutput = self.photoOutput else {
            logerror("Error getting photoOutput")
            return
        }
        guard let photoOutputConnection = photoOutput.connection(with: .video) else {
            logerror("Error getting photoOutput connection")
            return
        }
        photoOutputConnection.videoOrientation = videoOrientation
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
        if photoOutput.supportedFlashModes.contains(self.flashMode) {
            settings.flashMode = self.flashMode
        }
        self.photoOutput.capturePhoto(with: settings, delegate: self)
        
        /*
        self.photoOutput!.captureStillImageAsynchronously(from: photoOutputConnection, completionHandler: {
            (imageDataSampleBuffer: CMSampleBuffer?, error: Error?) in
            
            if error == nil {
                guard let imageDataSampleBuffer = imageDataSampleBuffer else {
                    log ("No image data returned")
                    return
                }
                guard let imageData:Data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: imageDataSampleBuffer, previewPhotoSampleBuffer: nil) else {
                    log("Unable to get image data from sample buffer")
                    return
                }
                if let takenImage = UIImage(data: imageData) {
                    // let cornerRadius = 0
                    // let interpolationQuality = CGInterpolationQuality.High
                    // let transparentBorder = 5
                    // let resizedImage = ImageTransformations.thumbnailImage(capturedImage, thumbnailSize:Int(self.previewLayer.bounds.height*2), transparentBorder:transparentBorder, cornerRadius:cornerRadius, interpolationQuality:interpolationQuality)
                    
                    var cropRect = CGRect.zero
                    if (cropped != .none) {
                        let outputRect:CGRect = self.previewLayer.metadataOutputRectConverted(fromLayerRect: self.previewLayer.bounds)
                        let takenCGImage:CGImage? = takenImage.cgImage
                        let width:CGFloat = CGFloat(takenCGImage!.width)
                        let height:CGFloat = CGFloat(takenCGImage!.height)
                        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)
                        
                        let cropCGImage:CGImage = takenImage.cgImage!.cropping(to: cropRect)!
                        //log ("\(self.videoLayerOrientation.rawValue), \(takenImage.imageOrientation.rawValue)")
                        if (self.flipImage) {
                            self.capturedImage = UIImage(cgImage: cropCGImage, scale: 1, orientation: self.getFlippedOrientation(current: takenImage.imageOrientation))
                        } else {
                            self.capturedImage = UIImage(cgImage:cropCGImage, scale:1, orientation:takenImage.imageOrientation)
                        }
                    }
                    if (cropped == .croppedToEdges) {
                        cropRect = ImageTransformations.getCardWithBordersRect(self.capturedImage)
                        // self.capturedImage = ImageTransformations.cutCardBordersIn(self.capturedImage)
                    }
                    if (cropped == .none) {
                        self.capturedImage = takenImage
                    }
                    
                    if (self.delegate != nil) {
                        self.delegate.capturedImage(self.capturedImage, rect: cropRect)
                    }
                }
            } else {
                log("Error taking picture: \(String(describing: error?.localizedDescription))")
            }
        })*/
    }
    
    private func getFlippedOrientation(xAxis: Bool = false, current: UIImage.Orientation) -> UIImage.Orientation {
        if (xAxis) {
            log("Not Implemented.")
            return current
        }
        
        switch current {
        case .up:           return .downMirrored
        case .down:         return .upMirrored
        case .left:         return .rightMirrored
        case .right:        return .leftMirrored
        case .upMirrored:   return .down
        case .downMirrored: return .up
        case .leftMirrored: return .right
        case .rightMirrored: return .left
        @unknown default:   return current
        }
    }
    
    public func disableMetadataCapture() {
        if (self.session.isRunning) {
            self.session.stopRunning()
        }
    
        var metadataOutput: AVCaptureMetadataOutput?
        self.session.outputs.forEach { (output) in
            if let op = output as? AVCaptureMetadataOutput {
                metadataOutput = op
            }
        }
        
        guard let output = metadataOutput else {
            return
        }
        
        self.session.removeOutput(output)
    }
    
    public func addMetadataCapture(_ types: [MetadataObjectType] = []) {
        do {
            try self.addSessionInput(preferredCamera: .back, mediaType: .metadataObject)
        } catch {
            logerror(error)
            return
        }
        
        let output = AVCaptureMetadataOutput()
        if (self.session.canAddOutput(output)) {
            self.session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            if (types.count == 0) {
                output.metadataObjectTypes = output.availableMetadataObjectTypes
            } else {
                output.metadataObjectTypes = types.map { $0.metadataObject }
            }
        }
    }
    
    public func addVideoFrameCapture(_ preferredCamera: CameraDevicePosition, onFrameReceived: ((CMSampleBuffer?) -> Void)? = nil) {
        do {
            //Input
            try addSessionInput(preferredCamera: preferredCamera.cameraPosition)
            
            //Output
            self.addVideoFrameOutput(preferredCamera, onFrameReceived: onFrameReceived)
        } catch {
            logerror(error)
        }
    }
    
    private func addVideoFrameOutput(_ preferredCamera: CameraDevicePosition, onFrameReceived: ((CMSampleBuffer?) -> Void)?) {
        if (!self.isOutputOfTypePresent(output: AVCaptureVideoDataOutput.self)) {
            let videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            if (self.session.canAddOutput(videoOutput)) {
                self.session.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoFrameQueue"))
                
                if let connection = videoOutput.connection(with: AVMediaType.video),
                   let previewLayerConnection = self.previewLayer.connection,
                   connection.isVideoOrientationSupported {
                    connection.videoOrientation = previewLayerConnection.videoOrientation
                }
                
                self.addStillCameraOutput(preferredCamera)
                
            } else {
                logerror("Unable to add video data output")
                return
            }
        } else {
            log("Video Data Output already present")
        }
        self.onFrameReceived = onFrameReceived
    }
    
    public func addQRCodeCapture() {
        self.addMetadataCapture([MetadataObjectType.qr])
    }
    
    public func switchToMetadataCapture(_ types: [MetadataObjectType] = []) {
        self.addMetadataCapture(types)
    }
    
    public func setFlashMode(_ flashMode: FlashMode) {
        self.flashMode = flashMode.flashMode
    }
    
    public func setTorchMode (_ torchMode: TorchMode) {
        guard let device = self.captureDevice,
              device.hasTorch && device.isTorchModeSupported(torchMode.torchMode) else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = torchMode.torchMode
            device.unlockForConfiguration()
        } catch {
            logerror("Failed to set torchmode: \(error)")
        }
    }
    
    public func setTorchOn() {
        self.setTorchMode(.on)
    }
    
    public func setTorchOff() {
        self.setTorchMode(.off)
    }
    
    public func setFlashOn() {
        self.flashMode = .on
    }
    
    public func setFlashOff() {
        self.flashMode = .off
    }
    
    public func setFlashAuto() {
        self.flashMode = .auto
    }
    
    public func setFocus(focusMode: FocusMode) {
        guard let device = self.captureDevice,
              device.isFocusModeSupported(focusMode.focusMode) else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.focusMode = focusMode.focusMode
            device.unlockForConfiguration()
            
            let cameraConfigFocusModeAppEvent = AppEvent(key: AppEventConstants.CAMERA_CONFIG_FOCUS_MODE, value: String(describing: focusMode))
            AppEventStorage.shared.addAppEvents(events: cameraConfigFocusModeAppEvent, eventType: .CAMERA)
        } catch {
            logerror("Failed to set torchmode: \(error)")
        }
    }
    
    public func toggleFlash() -> FlashMode {
        switch self.captureDevice?.torchMode {
        case .auto:
            self.setTorchMode(.on)
            return .on
        case .on:
            self.setTorchMode(.off)
            return .off
        default:
            self.setTorchMode(.auto)
            return .auto
        }
    }
    
    public func hideQRBox() {
        self.highlightLayer.borderWidth = 0.0
    }
    
    public func changeOrientation(_ orientation: UIInterfaceOrientation) {
        switch (orientation) {
        case .portraitUpsideDown:
            self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
        case .portrait:
            self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        case .landscapeLeft:
            self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        default:
            self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        }
    }
    
    @objc public func orientationChanged() {
        //        switch UIDevice.current.orientation {
        //        case .landscapeLeft:
        //            self.videoLayerOrientation = .landscapeRight
        //        case .landscapeRight:
        //            self.videoLayerOrientation = .landscapeLeft
        //        case .portrait:
        //            self.videoLayerOrientation = .portrait
        //        case .portraitUpsideDown:
        //            self.videoLayerOrientation = .portraitUpsideDown
        //        default:
        //            ()//Don't modify the orientation
        //        }
        self.changeOrientation(self.videoLayerOrientation)
        self.previewLayer.frame = self.captureView?.bounds ?? .zero
    }
    
    public func stop() {
        self.setTorchOff()
        self.setFlashOff()
        self.lastVideoFrameBuffer = nil
        self.session.stopRunning()
    }
    
    public func start() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    public static func isCameraPermissionGranted() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    public static func requestCameraPermission(onComplete: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: onComplete)
    }
    
    public static func showCameraPermissionRationale(parentViewController: UIViewController, message: String, onCanceled: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            guard !isCameraPermissionGranted() else {
                return
            }
            
            let message = "\(message)\n\nPlease update the permissions for your app in device settings to be able to use this feature."

            let alert = UIAlertController(title: "Permission Not Granted", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (_) in
                onCanceled?()
            }))
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { (_) in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
            }))
            parentViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    public func getContext() -> CIContext {
        return self.context
    }
}

extension SCAVCaptureWrapper: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.lastVideoFrameBuffer = sampleBuffer
        self.onFrameReceived?(sampleBuffer)
    }
    
    public func getLastVideoFrameBuffer(cropped: Bool = true) -> CMSampleBuffer? {
        guard let sampleBuffer = self.lastVideoFrameBuffer else {
            return nil
        }
        
        return cropped ? SampleBufferUtils.getCroppedSmapleBuffer(context: self.context, sampleBuffer: sampleBuffer, for: self.previewLayer) : sampleBuffer
    }
    
    public func getLastVideoFrame(cropped: Bool = true) -> UIImage? {
        guard let imageBuffer = self.lastVideoFrameBuffer else {
            log("No last frame")
            return nil
        }
        
        defer {
            self.context.clearCaches()
        }
        return SampleBufferUtils.getUIImageFromSampleBuffer(context: self.context, sampleBuffer: imageBuffer, for: cropped ? self.previewLayer : nil)
    }
    
    private func getImageCroppedToViewPort(_ image: UIImage) -> UIImage? {
        let outputRect: CGRect = self.previewLayer.metadataOutputRectConverted(fromLayerRect: self.previewLayer.bounds)
        guard let capturedCgImage = image.cgImage else {
            return nil
        }
        
        let width: CGFloat = CGFloat(capturedCgImage.width)
        let height: CGFloat = CGFloat(capturedCgImage.height)
        
        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)
        guard let croppedCgImage: CGImage = capturedCgImage.cropping(to: cropRect) else {
            return nil
        }
     
        return self.flipImage ? UIImage(cgImage: croppedCgImage, scale: 1, orientation: self.getFlippedOrientation(current: image.imageOrientation)) : UIImage(cgImage:croppedCgImage, scale:1, orientation:image.imageOrientation)
    }
    
    private func addCameraResolutionAppEvent() {
        guard let formatDescription = self.input?.device.activeFormat.formatDescription else { return }
        let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
        let cameraConfigResolutionAppEvent = AppEvent(key: AppEventConstants.CAMERA_CONFIG_RESOLUTION, value: "\(dimensions.width) x \(dimensions.height)")
        AppEventStorage.shared.addAppEvents(events: cameraConfigResolutionAppEvent, eventType: .CAMERA)
    }
    
}

extension SCAVCaptureWrapper: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            logerror("Error taking picture: \(error?.localizedDescription ?? "No description")")
            return
        }
        guard let imageData = photo.fileDataRepresentation(),
              let capturedImage = UIImage(data: imageData) else {
            logerror("Failed to get jpeg image from buffer")
            return
        }

        var cropRect = CGRect.zero

        guard self.cropped != .none,
              let croppedImage = getImageCroppedToViewPort(capturedImage) else {
            self.capturedImage = capturedImage
            self.delegate?.capturedImage(self.capturedImage, rect: cropRect)
            return
        }

        if self.cropped == .croppedToViewPort {
            self.capturedImage = croppedImage
        } else {
            cropRect = ImageTransformations.getCardWithBordersRect(capturedImage)
            self.capturedImage = ImageTransformations.cutCardBordersIn(croppedImage)
        }

        self.delegate?.capturedImage(self.capturedImage, rect: cropRect)
    }
    
}
