//
//  ChartVertLineLayer.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 22/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class ChartVertLineLayer: CALayer {
    
    weak var parentView: ChartView?
    
    override func draw(in ctx: CGContext) {
        if parentView == nil || parentView?.selectedTimestamp == nil {
            return
        }
        let points = parentView!.data!.lines.first!.positions(fromX: parentView!.range.fromX, toX: parentView!.range.toX, maxValue: 1)
        
        let p = (points.filter{$0.timstamp == parentView!.selectedTimestamp!}).first
        if p == nil {
            return
        }
        ctx.setLineWidth(0.5)
        ctx.setStrokeColor(UIColor.gray.cgColor)
        ctx.move(to: CGPoint(x: CGFloat(p!.x) * self.bounds.size.width, y: self.bounds.size.height))
        ctx.addLine(to: CGPoint(x: CGFloat(p!.x) * self.bounds.size.width, y: 10))
        ctx.strokePath()
    }
}
