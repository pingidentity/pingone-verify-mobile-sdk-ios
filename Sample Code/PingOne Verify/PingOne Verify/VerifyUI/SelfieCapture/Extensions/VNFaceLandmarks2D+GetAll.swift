//
//  VNFaceLandmarks2D+GetAll.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 8/31/21.
//  Copyright © 2021 com.shocard. All rights reserved.
//

import Foundation
import Vision

@available(iOS 13.0, *)
extension VNFaceLandmarks2D {
    
    func getAllLandmarks() -> [LandmarkType: FaceLandmark] {
        var landmarkRegions: [FaceLandmark?] = []

        landmarkRegions.append(FaceLandmark(landmark: self.leftEye, type: .leftEye) ?? nil)
        landmarkRegions.append(FaceLandmark(landmark: self.leftPupil, type: .leftPupil) ?? nil)
        landmarkRegions.append(FaceLandmark(landmark: self.leftEyebrow, type: .leftEyebrow) ?? nil)

        landmarkRegions.append(FaceLandmark(landmark: self.rightEye, type: .rightEye) ?? nil)
        landmarkRegions.append(FaceLandmark(landmark: self.rightPupil, type: .rightPupil) ?? nil)
        landmarkRegions.append(FaceLandmark(landmark: self.rightEyebrow, type: .rightEyebrow) ?? nil)

        landmarkRegions.append(FaceLandmark(landmark: self.nose, type: .nose) ?? nil)
        landmarkRegions.append(FaceLandmark(landmark: self.noseCrest, type: .noseCrest, closePath: false) ?? nil)

        landmarkRegions.append(FaceLandmark(landmark: self.innerLips, type: .innerLips) ?? nil)
        landmarkRegions.append(FaceLandmark(landmark: self.outerLips, type: .outerLips) ?? nil)
        
        landmarkRegions.append(FaceLandmark(landmark: self.faceContour, type: .faceContour, closePath: false) ?? nil)
        landmarkRegions.append(FaceLandmark(landmark: self.medianLine, type: .medianLine) ?? nil)
        
        return landmarkRegions.compactMap{$0}.reduce(into: [LandmarkType: FaceLandmark](), { $0[$1.type] = $1 })
    }
    
}
