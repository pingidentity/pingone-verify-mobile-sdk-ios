//
//  TimeInterval+format.swift
//  VerifyUI
//

import Foundation

extension TimeInterval {

    public var stringDescription: String {
        let secondsString = "idv_time_sec".localized(String(describing: self.seconds))
        let minutesString = "idv_time_min".localized(String(describing: self.minutes))
        return (self.minutes > 0) ? minutesString.appending(" \(secondsString)") : secondsString
    }

}
