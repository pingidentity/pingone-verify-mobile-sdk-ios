//
//  SampleBufferUtils.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 6/13/17.
//  Copyright © 2017 com.shocard. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

open class SampleBufferUtils {
    
    //Converts CMSampleBuffer to CIImage and crops it to fit AVCaptureVideoPreviewLayer's rect of interest
    //Works for Landscape and Portrait orientations
    class func getCIImageFromSampleBuffer(sampleBuffer: CMSampleBuffer, for previewLayer: AVCaptureVideoPreviewLayer?) -> CIImage? {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            logerror("Error: Cannot get Image Buffer")
            return nil
        }
        
        let width = CGFloat(CVPixelBufferGetWidth(buffer))
        let height = CGFloat(CVPixelBufferGetHeight(buffer))
        let isLandscape: Bool = width > height
        
        let cropRect: CGRect
        if let capturePreviewLayer = previewLayer {
            let viewPortRect = capturePreviewLayer.metadataOutputRectConverted(fromLayerRect: capturePreviewLayer.bounds)
            let scaleX: CGFloat = isLandscape ? viewPortRect.origin.x : viewPortRect.origin.y
            let scaleY: CGFloat = isLandscape ? viewPortRect.origin.y : viewPortRect.origin.x
            let scaleWidth: CGFloat = isLandscape ? viewPortRect.size.width : viewPortRect.size.height
            let scaleHeight: CGFloat = isLandscape ? viewPortRect.size.height : viewPortRect.size.width
            
            cropRect = CGRect(x: scaleX * width, y: scaleY * height, width: scaleWidth * width, height: scaleHeight * height)
        } else {
            cropRect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        }
        
        let ciImage = CIImage(cvPixelBuffer: buffer).cropped(to: cropRect)
        return ciImage
    }
    
    //Converts CIImage generated in "getCIImageFromSampleBuffer" method to CGImage
    class func getCGImageFromSampleBuffer(context: CIContext, sampleBuffer: CMSampleBuffer, for previewLayer: AVCaptureVideoPreviewLayer?) -> CGImage? {
        guard let ciImage = getCIImageFromSampleBuffer(sampleBuffer: sampleBuffer, for: previewLayer) else {
            return nil
        }
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
    
    //Crops CMSampleBuffer to fit AVCaptureVideoPreviewLayer's rect of interest and converts the generated CGImage back to CMSampleBuffer
    public class func getCroppedSmapleBuffer(context: CIContext, sampleBuffer: CMSampleBuffer, for previewLayer: AVCaptureVideoPreviewLayer?) -> CMSampleBuffer? {
        guard let cgImage = getCGImageFromSampleBuffer(context: context, sampleBuffer: sampleBuffer, for: previewLayer) else {
            return sampleBuffer
        }
        return getSampleBufferFromCGImage(cgImage: cgImage)
    }
    
    //Returns CMSampleBuffer for passed CGImage
    //Gets CVPixelBuffer from CGImage and converts it to CMSampleBuffer
    class func getSampleBufferFromCGImage(cgImage: CGImage) -> CMSampleBuffer? {
        guard let pixelBuffer = getPixelBufferFromCGImage(cgImage: cgImage) else {
            return nil
        }
        var sampleBuffer: CMSampleBuffer? = nil
        var timingInfo: CMSampleTimingInfo = CMSampleTimingInfo.invalid
        var videoInfo: CMVideoFormatDescription? = nil;
        let status = CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: pixelBuffer, formatDescriptionOut: &videoInfo)
        
        guard status == noErr, let videoFormatDescription = videoInfo else {
            return nil
        }
        
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: videoFormatDescription, sampleTiming: &timingInfo, sampleBufferOut: &sampleBuffer)
        
        return sampleBuffer
    }
    
    //Returns CVPixelBuffer for passed CGImage
    class func getPixelBufferFromCGImage(cgImage: CGImage) -> CVPixelBuffer? {
        let frameSize = CGSize(width: cgImage.width, height: cgImage.height)
        
        let options: [AnyHashable: Any] = [kCVPixelBufferCGImageCompatibilityKey as AnyHashable: NSNumber(booleanLiteral: true),
                                           kCVPixelBufferCGBitmapContextCompatibilityKey as AnyHashable: NSNumber(booleanLiteral: true)]
        
        var pixelBuffer: CVPixelBuffer? = nil
        let status: CVReturn = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let baseAddress = CVPixelBufferGetBaseAddress(buffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let colorSpace = CGColorSpaceCreateDeviceCMYK()
        
        guard let context = CGContext(data: baseAddress, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: frameSize.width, height: frameSize.height))
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue:0))
        
        return pixelBuffer
    }
    
    //Returns CMSampleBuffer for passed UIImage
    open class func getSampleBufferFromUIImage(image: UIImage) -> CMSampleBuffer? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        return getSampleBufferFromCGImage(cgImage: cgImage)
    }
    
    //Converts CGImage generated in "getCGImageFromSampleBuffer" method to UIImage
    open class func getUIImageFromSampleBuffer(context: CIContext, sampleBuffer: CMSampleBuffer, for previewLayer: AVCaptureVideoPreviewLayer? = nil) -> UIImage? {
        guard let cgImage = self.getCGImageFromSampleBuffer(context: context, sampleBuffer: sampleBuffer, for: previewLayer) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    open class func getImageFromSampleBuffer(context: CIContext, sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        defer {
            context.clearCaches()
        }
        return UIImage(cgImage: cgImage)
    }
    
    
}
