//
//  ChartViewPopupLayer.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 22/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class ChartViewPopupLayer: CALayer {
    
    weak var parentView: ChartView?
    
    struct LineLabel {
        var text: String
        var color: UIColor
    }
    
    override func draw(in ctx: CGContext) {
        if parentView == nil || parentView!.selectedTimestamp == nil {
            return
        }
        
        
        
        let visibleLines = (parentView!.layers!.filter{$0.line!.isVisible == true}).map{$0.line!}
        if visibleLines.count == 0 {
            return
        }
        
        var attributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 14.0),
            .foregroundColor: UIColor.black]
        
        
        var labels = [LineLabel]()
        var sizes = [CGSize]()
        
        var dateText: String?
        var point: ChartPoint?
        for l in visibleLines {
            
            let points = l.positions(fromX: parentView!.range.fromX, toX: parentView!.range.toX, maxValue: 1)
            
            let p = (points.filter{$0.timstamp == parentView!.selectedTimestamp!}).first
            if p == nil {
                return
            }
            if dateText == nil {
                point = p
                dateText = p!.timstamp.date()
            }
            let str = String(Int(p!.globalY))
            let s = str.size(withAttributes: attributes)
            labels.append(LineLabel(text: str, color: UIColor.init(cgColor: l.color!)))
            sizes.append(s)
         }
        
        let labelsMaxWidth = (sizes.map{$0.width}).max()!
        
        var h = visibleLines.count * 20 + 15
        
        if h < 45 + 20 {
            h = 45 + 20
        }
        
        let top = CGFloat(10)
        
        let lw: CGFloat = 60
        
        let rectWidth = labelsMaxWidth + lw + 20
        var rectCenterX = CGFloat(point!.x) * self.bounds.size.width
        if rectCenterX < 15 || rectCenterX > self.bounds.size.width - 15 {
            parentView!.selectedTimestamp = nil
            return
        }
        if rectCenterX < rectWidth / 2 + 10 {
            rectCenterX = rectWidth / 2 + 10
        }
        if rectCenterX > self.bounds.size.width - rectWidth / 2 - 15 {
            rectCenterX = self.bounds.size.width - rectWidth / 2 - 15
        }
        let left = rectCenterX - rectWidth / 2

        
        
        let rectanglePath = UIBezierPath.init(roundedRect: CGRect(x: left, y: top, width: rectWidth, height: CGFloat(h)), cornerRadius: 5)
        ctx.setFillColor(GraphAppearance.graphPopupBackground.cgColor)
        ctx.addPath(rectanglePath.cgPath)
        ctx.fillPath()
        
        UIGraphicsPushContext(ctx)
        var offset: CGFloat = 10
        
        for l in labels {
            attributes[NSAttributedString.Key.foregroundColor] = l.color
            l.text.draw(at: CGPoint(x: left + 10 + lw, y: top + offset), withAttributes: attributes)
            offset += 20
        }
        attributes[NSAttributedString.Key.foregroundColor] = GraphAppearance.graphPopupDateColor
        attributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 14)

        dateText!.draw(at: CGPoint(x: left + 10, y: top + 10), withAttributes: attributes)
        attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 14)

        let formatter = DateFormatter.init()
        formatter.dateFormat = "YYYY"
        
        let date = Date.init(timeIntervalSince1970: point!.timstamp/1000)

        formatter.string(from: date).draw(at: CGPoint(x: left + 10, y: top + 30), withAttributes: attributes)

        UIGraphicsPopContext()
        
        

        
    }
    
    
    override init() {
        super.init()
        self.contentsScale = UIScreen.main.scale
        self.drawsAsynchronously = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
