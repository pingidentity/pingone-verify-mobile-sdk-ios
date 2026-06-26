//
//  Face.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 8/31/21.
//  Copyright © 2021 com.shocard. All rights reserved.
//

import Foundation
import AVFoundation
import Vision
import UIKit

public class Face {
    
    private static let CENTER_RECT_MARGIN: CGFloat = 15
    private static let MAX_FACE_MARGIN_FROM_REFERENCE_FRAME: CGFloat = 25
    private static let MAX_FACEPITCH_ANGLE_IN_DEGREES: Double = 12.0
    private static let MAX_FACEROLL_ANGLE_IN_DEGREES: Double = 8.0
    private static let MAX_FACEYAW_ANGLE_IN_DEGREES: Double = 8.0
    private static let EYE_ASPECT_RATIO_THRESHOLD: CGFloat = 0.15
    private static let MOUTH_OPEN_THRESHOLD: CGFloat = 15
    
    private let landmarks: [LandmarkType: FaceLandmark]
    private let boundingBox: CGRect
    private let contourRect: CGRect
    private let medianLine: MedianLine
    
    public var pitch: Double = 0
    public var roll: Double = 0
    public var yaw: Double = 0
    
    @available(iOS 13.0, *)
    public init?(result: VNFaceObservation, in previewLayer: AVCaptureVideoPreviewLayer) {
        guard let landmarks = result.landmarks else {
//            print("No landmarks present in the result")
            return nil
        }
    
        self.landmarks = landmarks.getAllLandmarks()
        self.boundingBox = previewLayer.layerRectConverted(fromMetadataOutputRect: result.boundingBox)
                
        if let contourRect = self.landmarks[LandmarkType.faceContour]?.getPath(in: self.boundingBox).boundingBox {
//            print("Landmarks don't contain the face contour")
            self.contourRect = contourRect
        } else {
            self.contourRect = CGRect.zero
        }
        
        if let medianLineLandmark = landmarks.medianLine {
//            print("Landmarks don't contain a medianLine")
            self.medianLine = MedianLine(medianLandmark: medianLineLandmark, in: boundingBox)
        } else {
            self.medianLine = MedianLine(startPoint: CGPoint.zero, endPoint: CGPoint.zero, angle: 0)
        }
        
        self.updateAngles(from: result)
    }
    
    public func updateAngles(from observation: VNFaceObservation) {
        self.pitch = (observation.pitch?.doubleValue ?? 0) * (180.0/Double.pi)
        self.roll = (observation.roll?.doubleValue ?? 0) * (180.0/Double.pi)
        self.yaw = (observation.yaw?.doubleValue ?? 0) * (180.0/Double.pi)
    }
    
    public func getFaceBoundingBox() -> CGRect {
        return self.boundingBox
    }
        
    public func getFaceContourRect() -> CGRect {
        return self.contourRect
    }
    
    public func getMedianLine() -> MedianLine {
        return self.medianLine
    }
    
    public func getFacePitchDegrees() -> Double {
        return self.pitch
    }

    public func getFaceRollDegrees() -> Double {
        return self.roll
    }

    public func getFaceYawDegrees() -> Double {
        return self.yaw
    }

    public func getFaceBoxLayer() -> CAShapeLayer {
        let faceBoundingBoxPath = CGPath(rect: self.boundingBox, transform: nil)
        let faceBoundingBoxShape = CAShapeLayer()
        faceBoundingBoxShape.path = faceBoundingBoxPath
        faceBoundingBoxShape.cornerRadius = 5
        faceBoundingBoxShape.borderWidth = 3
        faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
        faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
        
        return faceBoundingBoxShape
    }
    
    public func getLandmark(of type: LandmarkType) -> FaceLandmark? {
        return self.landmarks[type]
    }
    
    public func getFaceLandmarkLayers() -> [CAShapeLayer] {
        return self.landmarks.values.map { $0.getLayer(in: self.boundingBox) }
    }
 
    public func isLandmarkVisible(_ landmark: LandmarkType, in rect: CGRect) -> Bool {
        guard let faceLandmark = self.landmarks[landmark] else {
            return false
        }
        
        return rect.contains(self.getEnclosingRectFor(landmark: faceLandmark))
    }
    
    public func checkLandmarksInFrame(in rect: CGRect) -> Bool {
        let checkLandmarkTypes: [LandmarkType] = [.leftEyebrow, .rightEyebrow, .leftEye, .rightEye, .nose, .outerLips]
        return self.landmarks.filter { checkLandmarkTypes.contains($0.key) && !rect.contains(self.getEnclosingRectFor(landmark: $0.value)) }.isEmpty
    }
    
    public func isCentered(in rect: CGRect) -> Bool {
        let centerRect = rect.getCenteredSubRectWith(xMargin: Face.CENTER_RECT_MARGIN, yMargin: 0)
        return centerRect.contains(medianLine.startPoint)
    }
    
    public func isLookingUpOrDown() -> Bool {
        let facePitch = self.getFacePitchDegrees()
        return !(0...Face.MAX_FACEPITCH_ANGLE_IN_DEGREES).contains(abs(facePitch))
    }
    
    public func isLookingLeftOrRight() -> Bool {
        let faceYaw = self.getFaceYawDegrees()
        return !(0...Face.MAX_FACEYAW_ANGLE_IN_DEGREES).contains(abs(faceYaw))
    }
    
    public func isTilting() -> Bool {
        let faceRoll = self.getMedianLine().angle
        return !(0...Face.MAX_FACEROLL_ANGLE_IN_DEGREES).contains(abs(faceRoll))
    }
    
    public func checkDistance(in rect: CGRect) -> FaceDistance {
        let faceContourRect = self.getFaceContourRect()
        let faceContourStartPoint: CGPoint = faceContourRect.origin
        let faceContourEndPoint: CGPoint = CGPoint(x: faceContourRect.origin.x + faceContourRect.width, y: faceContourRect.origin.y)
        
        let referenceViewStartPoint: CGPoint = rect.origin
        let referenceViewEndPoint: CGPoint = CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y)
        
        let deltaFaceStartPoint = referenceViewStartPoint.x - faceContourStartPoint.x
        let deltaFaceEndPoint = referenceViewEndPoint.x - faceContourEndPoint.x
        
        let isFaceInsideFrame = deltaFaceStartPoint <= 0 && deltaFaceEndPoint >= 0
        
        if ((0...Face.MAX_FACE_MARGIN_FROM_REFERENCE_FRAME).contains(abs(deltaFaceStartPoint)) &&
            (0...Face.MAX_FACE_MARGIN_FROM_REFERENCE_FRAME).contains(abs(deltaFaceEndPoint))) {
            return .matchesFrame
        } else {
            return isFaceInsideFrame ? .far : .near
        }
    }
    
    public func getEnclosingRectFor(landmark: FaceLandmark) -> CGRect {
        return landmark.getPath(in: self.boundingBox).boundingBox
    }
    
    public func getLeftEyeAspectRatio() -> CGFloat {
        return self.getEyeSizeAspectRatio(.leftEye)
    }
    
    public func getRightEyeAspectRatio() -> CGFloat {
        return self.getEyeSizeAspectRatio(.rightEye)
    }
    
    private func getEyeSizeAspectRatio(_ eyeLandmark: LandmarkType) -> CGFloat {
        guard let eyePoints = self.getLandmark(of: eyeLandmark)?.landmark.normalizedPoints,
              eyePoints.count >= 6 else {
            return 0.0
        }
        let p1 = eyePoints[1].distanceFrom(point: eyePoints[5])
        let p2 = eyePoints[2].distanceFrom(point: eyePoints[4])
        let p3 = eyePoints[0].distanceFrom(point: eyePoints[3])
        
        return (p1 + p2) / (2 * p3)
    }
    
    public func isLeftEyeClosed() -> Bool {
        let leftEyeAspectRatio = self.getLeftEyeAspectRatio()
        return leftEyeAspectRatio > 0 && leftEyeAspectRatio < Face.EYE_ASPECT_RATIO_THRESHOLD
    }

    public func isRightEyeClosed() -> Bool {
        let rightEyeAspectRatio = self.getRightEyeAspectRatio()
        return rightEyeAspectRatio > 0 && rightEyeAspectRatio < Face.EYE_ASPECT_RATIO_THRESHOLD
    }

    public func isMouthOpen() -> Bool {
        if let mouthRect = self.getLandmark(of: .innerLips)?.getPath(in: self.boundingBox).boundingBox {
            return mouthRect.height > Face.MOUTH_OPEN_THRESHOLD
        }
        return false
    }
    
    public func distanceBetweenEyesAndNose() -> CGFloat {
        guard let nose = self.landmarks[.nose],
              let leftEye = self.landmarks[.leftEye],
              let rightEye = self.landmarks[.rightEye] else {
            return 0
        }
        
        guard let leftEyeRect = leftEye.getLayer(in: self.boundingBox).path?.boundingBox,
              let rightEyeRect = rightEye.getLayer(in: self.boundingBox).path?.boundingBox,
              let noseRect = nose.getLayer(in: self.boundingBox).path?.boundingBox else {
            return 0
        }
        
        let leftEyeEndPoint = CGPoint(x: leftEyeRect.origin.x + leftEyeRect.width, y: leftEyeRect.origin.y)
        let rightEyeStartPoint = rightEyeRect.origin
        let eyeMidPoint = CGPoint(x: (leftEyeEndPoint.x + rightEyeStartPoint.x) / 2, y: (leftEyeEndPoint.y + rightEyeStartPoint.y) / 2)
        
        let noseBottomPoint = CGPoint(x: noseRect.midX, y: noseRect.origin.y + noseRect.height)
        
        if let medianLine = self.landmarks[.medianLine],
           let medianLineRect = medianLine.getLayer(in: self.boundingBox).path?.boundingBox {
            let _ = CGPoint(x: medianLineRect.midX, y: medianLineRect.origin.y)
            let _ = CGPoint(x: medianLineRect.midX, y: medianLineRect.origin.y + medianLineRect.height)
//            print("medianLineTopPoint: \(medianLineTopPoint)")
//            print("medianLineBottomPoint: \(medianLineBottomPoint)")
//            print("eyesMidPoint: \(eyeMidPoint)")
//            print("noseBottomPoint: \(noseBottomPoint)")
//            print("\(medianLineTopPoint.distanceFrom(point: medianLineBottomPoint))")
        }
        
        return noseBottomPoint.distanceFrom(point: eyeMidPoint)
    }
    
}

public enum FaceDistance {

    case far
    case near
    case matchesFrame

}
