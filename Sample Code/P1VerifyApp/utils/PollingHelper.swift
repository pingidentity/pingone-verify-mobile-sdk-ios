//
//  PollingHelper.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 12/04/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

class PollingHelper {
    
    public static let DEFAULT_POLLING_INTERVAL_SEC: TimeInterval = 2.0
    
    let pollingInterval: TimeInterval
    let pollingAction: (PollingHelper) -> Void

    private var timer: Timer?

    private var applicationWillEnterBackgroundObserver: NSObjectProtocol?
    private var applicationWillEnterForegroundObserver: NSObjectProtocol?
    private var applicationDidBecomeActiveObserver: NSObjectProtocol?
    
    init(withInterval pollingInterval: TimeInterval, action: @escaping (PollingHelper) -> Void) {
        self.pollingInterval = pollingInterval
        self.pollingAction = action
    }
    
    private func registerObservers() {
        if (self.applicationWillEnterBackgroundObserver == nil) {
            self.applicationWillEnterBackgroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: UIApplication.shared, queue: nil, using: { (notification) in
                print("Application Entering Background, stop polling")
                self.stopTimer()
            })
        }
        
        if (self.applicationWillEnterForegroundObserver == nil) {
            self.applicationWillEnterForegroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: UIApplication.shared, queue: nil, using: { (notification) in
                print("Application entering foreground, start polling")
                self.startPolling()
            })
        }
        
        if (self.applicationDidBecomeActiveObserver == nil) {
            self.applicationDidBecomeActiveObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: UIApplication.shared, queue: nil, using: { (notification) in
                print("Application becoming active, start polling")
                self.startPolling()
            })
        }
    }

    private func deRegisterObservers() {
        if let observer = self.applicationWillEnterBackgroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = self.applicationWillEnterForegroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = self.applicationDidBecomeActiveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
        
    func startPolling() {
        if (self.timer == nil || !self.timer!.isValid) {
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: self.pollingInterval, target: self, selector: #selector(PollingHelper.pollingAction(timer:)), userInfo: nil, repeats: true)
                self.registerObservers()
            }
        }
    }
    
    func stopPolling() {
        self.deRegisterObservers()
        self.stopTimer()
    }
    
    private func stopTimer() {
        guard self.timer?.isValid ?? false else {
            return
        }
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc private func pollingAction(timer: Timer) {
        self.pollingAction(self)
      }

    
}
