//
// ImageTransformations.swift
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

import Foundation
import CoreImage
import UIKit

public struct ImageTransformations {

    public static func cropImage(_ originalImage: UIImage, cropRect:CGRect) -> UIImage {
        if let imageRef = originalImage.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        }
        return originalImage
    }
    
    public static func detectBoxInImage(_ image: UIImage) -> CGRect? {

        var bounds: CGRect? = nil
        let context: CIContext = CIContext(options:nil)
        let detectorOptions = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: context, options: detectorOptions)
        let ciImage = CIImage(cgImage: image.cgImage!)

        // find the largest box by area and return its bounds where the box is greater then 50% of the image
        let features = detector!.features(in: ciImage)
        var boundsArea : CGFloat = 0.0
        let minImageArea = (image.size.width * image.size.height) * 0.3
        for feature in features {
            let featureArea : CGFloat = feature.bounds.size.width * feature.bounds.size.height
            log("feature area \(featureArea) min area \(minImageArea)")

            if (featureArea > boundsArea) && (featureArea > minImageArea){
                bounds = feature.bounds
                boundsArea = featureArea
            }
        }
        return bounds
    }
    
    public static func adjustBoundsForImageProcessing(_ image:UIImage, bounds:CGRect) -> CGRect {

        var adjustedBounds = bounds
        adjustedBounds.origin.y = image.size.height - bounds.origin.y - bounds.size.height
        return adjustedBounds;
    }
    
    public static func cutCardBordersIn(_ image:UIImage) -> UIImage {
        //
        // get the bounds of the card on the screen and cut edges to box it in
        //
        if var cropRect = ImageTransformations.detectBoxInImage(image) {
            cropRect = ImageTransformations.adjustBoundsForImageProcessing(image, bounds: cropRect)
            if (cropRect.size.width > 0 && cropRect.size.height > 0 &&
                cropRect.origin.x > 0 && cropRect.origin.x < image.size.width &&
                cropRect.origin.y > 0 && cropRect.origin.y < image.size.height &&
                cropRect.size.width <= image.size.width &&
                cropRect.size.height <= image.size.height) {
                    return ImageTransformations.cropImage(image, cropRect:cropRect)
            }
        }
        return image
    }
    
    public static func getCardWithBordersRect(_ image:UIImage) -> CGRect {
        if var cropRect = ImageTransformations.detectBoxInImage(image) {
            cropRect = ImageTransformations.adjustBoundsForImageProcessing(image, bounds: cropRect)
            if (cropRect.size.width > 0 && cropRect.size.height > 0 &&
                cropRect.origin.x > 0 && cropRect.origin.x < image.size.width &&
                cropRect.origin.y > 0 && cropRect.origin.y < image.size.height &&
                cropRect.size.width <= image.size.width &&
                cropRect.size.height <= image.size.height) {
                return cropRect
            }
        }
        return CGRect.zero
    }
    
    public static func imageToBase64(image: UIImage) -> String {
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            return imageData.base64EncodedString()
        }
        return ""
    }
}

