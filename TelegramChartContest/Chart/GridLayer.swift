//
//  GridLayer.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 21/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class GridLayer: CALayer {
    
    @objc dynamic var progress: CGSize = CGSize(width: 1, height: 1) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var fromMaxValue: Double = 1 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var isAppearing = true {
        didSet {
            self.presentation()?.isAppearing = isAppearing
        }
    }
    
    override init() {
        super.init()
        self.contentsScale = UIScreen.main.scale
        self.shouldRasterize = true
        self.rasterizationScale = UIScreen.main.scale
        self.drawsAsynchronously = true
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        if let l = layer as? GridLayer {
            self.isAppearing = l.isAppearing
            self.fromMaxValue = l.fromMaxValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" {
            return true
        }
        
        return super.needsDisplay(forKey: key)
    }
    
    override func draw(in ctx: CGContext) {
        UIGraphicsPushContext(ctx)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 12.0),
            .foregroundColor: UIColor.init(white: 0.64, alpha: 1)
        ]
        
        let maxValue = Double(progress.width)
        let alpha = Double(progress.height)
        
        let origStep = CGFloat(50)
//        ctx.setAlpha(CGFloat(isAppearing ? alpha * 0.8 : (1.0 - alpha) * 0.6))
        ctx.setAlpha(CGFloat(isAppearing ? alpha * 1 : (1.0 - alpha) * 1))
        var y = CGFloat(0)
        
        ctx.setStrokeColor(UIColor.gray.cgColor)
        ctx.setLineWidth(0.5)
        let step = CGFloat(Double(origStep) * (fromMaxValue / maxValue))
        
        let valueStep = (fromMaxValue / (Double(self.bounds.size.height) * 0.9)) * Double(origStep)
        var val = 0.0
        while y < self.bounds.size.height {
            ctx.move(to: CGPoint(x: 0, y: self.bounds.size.height - y * 0.9))
            ctx.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height - y * 0.9))
            
            let text = String(Int(val))
            
            (text as NSString).draw(at: CGPoint(x: 0, y: (self.bounds.size.height - y * 0.9) - 16), withAttributes: attributes)
            y += step
            val += Double(valueStep)
        }
        ctx.strokePath()
        UIGraphicsPopContext()
    }
    
}
