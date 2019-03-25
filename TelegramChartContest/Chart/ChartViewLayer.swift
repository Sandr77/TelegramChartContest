//
//  ChartViewLayer.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 16/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit


class ChartViewLayer: CALayer {
    

    weak var parentView: ChartView?
    
    var lineWidth: CGFloat = 2
    
    var overscale: CGFloat = 1
    
    @objc dynamic var max: Double = 1
    
    var currentMax: Double?
    
    var chartRange = ChartRange(fromX: 0, toX: 1) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var line: ChartLine?
    
    override init() {
        super.init()
        self.contentsScale = UIScreen.main.scale
        self.drawsAsynchronously = true

    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        if let l = layer as? ChartViewLayer {
            self.chartRange = l.chartRange
            self.line = l.line
            self.max = l.max
            self.lineWidth = l.lineWidth
            self.parentView = l.parentView
         }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "max" {
            return true
        }
        
        return super.needsDisplay(forKey: key)
    }
    
    
    override func draw(in ctx: CGContext) {
        if line == nil {
            return
        }

        let points = line!.positions(fromX: chartRange.fromX, toX: chartRange.toX, maxValue: max)
        if points.count < 2 {
            return
        }
        
        ctx.translateBy(x: 0, y: self.bounds.size.height)
        ctx.scaleBy(x: 1, y: -1)

        
        ctx.setStrokeColor(line!.color!)
        ctx.setLineWidth(lineWidth)
        ctx.setLineJoin(.round)
        
        let  firstPoint = CGPoint(x: points.first!.x * Double(self.bounds.size.width), y: points.first!.y * Double(self.bounds.size.height * 0.9) * Double(overscale))
        ctx.move(to: firstPoint)
        for i in 1..<points.count {
            ctx.addLine(to: CGPoint(x: points[i].x * Double(self.bounds.size.width), y: points[i].y * Double(self.bounds.size.height * 0.9) * Double(overscale)))
        }
        
        ctx.strokePath()
        self.drawSelectedPoint(ctx: ctx, points: points)

    }
    
    
    func drawSelectedPoint(ctx: CGContext, points: [ChartPoint]) {
        if parentView == nil || parentView!.selectedTimestamp == nil {
            return
        }
        
        let p = (points.filter{$0.timstamp == parentView!.selectedTimestamp!}).first
        if p == nil {
            return
        }
            ctx.setBlendMode(.clear)
            ctx.addArc(center: CGPoint(x: p!.x * Double(self.bounds.size.width), y: p!.y * Double(self.bounds.size.height * 0.9)), radius: 3, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            ctx.drawPath(using: .fill)
            ctx.setBlendMode(.normal)
            
            ctx.addArc(center: CGPoint(x: p!.x * Double(self.bounds.size.width), y: p!.y * Double(self.bounds.size.height * 0.9)), radius: 3, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            ctx.strokePath()
    }
    
    
}
