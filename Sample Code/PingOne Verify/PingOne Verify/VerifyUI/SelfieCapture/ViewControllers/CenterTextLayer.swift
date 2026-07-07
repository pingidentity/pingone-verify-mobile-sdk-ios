//
//  CenterTextLayer.swift
//  ShoLib
//
//  Created by Bhavya Chauhan on 8/31/21.
//  Copyright © 2021 com.shocard. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public class CenterTextLayer: CATextLayer {
    
    public override func draw(in ctx: CGContext) {
        let height = self.bounds.size.height
        let fontSize = 20.0
        let lines = CGFloat(calculateNumberOfLines())
        let dy = (height - (lines * fontSize)) / 2
        
        ctx.saveGState()
        ctx.translateBy(x: 0, y: dy)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
    
    func calculateNumberOfLines() -> Int {
        guard let font = self.font,
              let charSize = font.lineHeight else {
            return 0
        }
        
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let text = (self.string ?? "") as! NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let linesRoundedUp = Int(floor(textSize.height / charSize))
        return linesRoundedUp
    }
    
}
