//
//  SelfieQAResult.swift
//  PingOneVerify_iOS
//
//  Created by Bhavya Chauhan on 7/19/22.
//

import Foundation
import UIKit

public struct SelfieQAResult {

    public var isSuccessful: Bool
    public var error: SelfieQAError?
    public var outlineColor: UIColor

    public init(isSuccessful: Bool, error: SelfieQAError?, outlineColor: UIColor) {
        self.isSuccessful = isSuccessful
        self.error = error
        self.outlineColor = outlineColor
    }

    public static func getResultFor(face: Face, in rect: CGRect, shouldCheckFacialFeature: Bool) -> SelfieQAResult {
        let faceDistance = face.checkDistance(in: rect)
        let isFaceCentered = face.isCentered(in: rect)
        let isFaceLookingUpOrDown = face.isLookingUpOrDown()
        let isFaceLookingLeftOrRight = face.isLookingLeftOrRight()
        let isFaceTilting = face.isTilting()
        let allLandmarksInFrame = face.checkLandmarksInFrame(in: rect)
        let isLeftEyeClosed = face.isLeftEyeClosed()
        let isRightEyeClosed = face.isRightEyeClosed()
        let isMouthOpen = face.isMouthOpen()

        let error: SelfieQAError?
        
        if (faceDistance == .near) {
            error = .faceTooClose
        } else if (faceDistance == .far) {
            error = .faceTooFar
        } else if (!allLandmarksInFrame) {
            error = .allLandmarksNotInFrame
        } else if (!isFaceCentered) {
            error = .faceNotCentered
        } else if (isFaceLookingUpOrDown) {
            error = .faceLookingUpOrDown
        } else if (isFaceLookingLeftOrRight) {
            error = .faceLookingLeftOrRight
        } else if (isFaceTilting) {
            error = .faceNotStraight
        } else if (isLeftEyeClosed && shouldCheckFacialFeature) {
            error = .leftEyeClosed
        } else if (isRightEyeClosed && shouldCheckFacialFeature) {
            error = .rightEyeClosed
        } else if (isMouthOpen && shouldCheckFacialFeature) {
            error = .mouthOpen
        } else {
            error = nil
        }
        
        return SelfieQAResult(isSuccessful: error == nil, error: error, outlineColor: error == nil ? .green : .red)
    }
}

