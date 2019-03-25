//
//  XValuesView.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 19/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

struct ChartRange {
    var fromX: Double = 0
    var toX: Double = 0
}


class XValuesView: UIView {
    
    class XValuesLayer: CALayer {
        
        @objc dynamic var alpha: CGFloat = 1
        
        
        let minInterval: Double = 50

        override init() {
            super.init()
            self.contentsScale = UIScreen.main.scale
            self.drawsAsynchronously = true
            self.shouldRasterize = true
            self.rasterizationScale = UIScreen.main.scale
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override init(layer: Any) {
            super.init(layer: layer)
            if let l = layer as? XValuesLayer {
                self.isAnimatingLayer = true
                self.appearingPoints = l.appearingPoints
                self.disappearingPoints = l.disappearingPoints
                self.range = l.range
                self.line = l.line
            }
        }
        
        override class func needsDisplay(forKey key: String) -> Bool {
            if key == "alpha" {
                return true
            }
            
            return super.needsDisplay(forKey: key)
        }
        
        var isAnimatingLayer = false
        var appearingPoints = [ChartPoint]()
        var disappearingPoints = [ChartPoint]()
        
        var previosRange: ChartRange?
        var previousPoints = [ChartPoint]()
        
        var range = ChartRange(fromX: 0, toX: 0) {
            didSet {
                let filteredPoints = selectPoints().last!
                
                if previosRange != nil && isAnimatingLayer == false && range.toX - range.fromX != previosRange!.toX - previosRange!.fromX {

 //                   let selectedPoints = arr.first!
 //                   let candidates = (chooseCandidates(main: filteredPoints, all: selectedPoints)).map{appearingPoints?.contains($0) == false && disappearingPoints?.contains($0) == false}
                    var toAppear: [ChartPoint]?
                    var toDisappear: [ChartPoint]?
                    if range.toX - range.fromX < previosRange!.toX - previosRange!.fromX {
                        let newPoints = filteredPoints.filter{previousPoints.contains($0) == false}
                        if newPoints.count > 0 {
                            toAppear = newPoints
                            appearingPoints.append(contentsOf: toAppear!)
                        }
                    }
                    else {
                        let oldPoints = previousPoints.filter{filteredPoints.contains($0) == false}
                        if oldPoints.count > 0 {
                            toDisappear = oldPoints
                            disappearingPoints.append(contentsOf: toDisappear!)
                        }
                    }
                    if toAppear != nil || toDisappear != nil {
                        
                        CATransaction.begin()
                        let a = CABasicAnimation()
                        a.fromValue = toAppear != nil ? CGFloat(0) : CGFloat(1)
                        a.toValue = toAppear != nil ? CGFloat(1) : CGFloat(0)
                        a.keyPath = "alpha"
                        a.duration = 0.2
                        a.isRemovedOnCompletion = true
                        a.fillMode = CAMediaTimingFillMode.forwards
                        
                        CATransaction.setCompletionBlock({
                            if toAppear != nil {
                                self.appearingPoints.removeAll(where: { point in
                                    toAppear!.contains(point)
                                })
                            }
                            else {
                                self.disappearingPoints.removeAll(where: { point in
                                    toDisappear!.contains(point)
                                })
                            }
                        })
                        self.add(a, forKey: nil)
                    }
                }
                previousPoints = filteredPoints
                previosRange = range
                self.setNeedsDisplay()
            }
        }
        var line: ChartLine!
        
        
        override func draw(in ctx: CGContext) {
            
            UIGraphicsPushContext(ctx)
            
            let arr = self.selectPoints()
            let filteredPoints = arr.last!
            let selectedPoints = isAnimatingLayer ? arr.first! : arr.last!
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            var attributes: [NSAttributedString.Key : Any] = [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 12.0),
                .foregroundColor: UIColor.init(white: 0.64, alpha: 1)//UIColor.gray.withAlphaComponent(0.8)
            ]
 
            for p in selectedPoints {
                if self.isAnimatingLayer {
                    if appearingPoints.contains(p) || disappearingPoints.contains(p) {
                        attributes[.foregroundColor] = UIColor.init(white: 0.64, alpha: self.alpha)//UIColor.gray.withAlphaComponent(self.alpha * 0.8)
                    }
                    else if filteredPoints.contains(p) {
                        attributes[.foregroundColor] = UIColor.init(white: 0.64, alpha: 1)//UIColor.gray.withAlphaComponent(0.8)
                    }
                    else {
                        continue
                    }
                }
                let rect = CGRect(x: p.x * Double(self.bounds.size.width) - 50, y: 5, width: 100, height: 50)
                p.xLabel.draw(in: rect, withAttributes: attributes)
            }
            UIGraphicsPopContext()

        }
        
        func selectPoints() -> [[ChartPoint]] {
            if line == nil {
                return [[], []]
            }
            let screenPoints =  (line.points.filter{$0.globalX >= range.fromX - (range.toX - range.fromX) / 4 && $0.globalX <= range.toX + (range.toX - range.fromX) / 4})
            screenPoints.forEach{$0.x = ($0.globalX - range.fromX)/(range.toX - range.fromX)}
            let sortedPoints = screenPoints.sorted{$0.priority < $1.priority}
            var selectedPoints = [ChartPoint]()
            for i in 0..<30 {
                if sortedPoints.count <= i {
                    break
                }
                selectedPoints.append(sortedPoints[i])
            }
            selectedPoints = selectedPoints.sorted{$0.x < $1.x}
            let filtered = filterPoints(selectedPoints)
            return [selectedPoints, filtered]
        }
        
        func filterPoints(_ pointss: [ChartPoint]) -> [ChartPoint] {
            var points = pointss
            var x = points.first!.x
            
            for i in 1..<points.count {
                if (points[i].x - x) * Double(self.bounds.size.width) < minInterval {
                    if points[i].priority < points[i-1].priority {
                        points.remove(at: i-1)
                    }
                    else {
                        points.remove(at: i)
                    }
                    return filterPoints(points)
                }
                x = points[i].x
             }
            return points
        }
        
        func chooseCandidates(main: [ChartPoint], all: [ChartPoint]) -> [ChartPoint] {
            var candidates = [ChartPoint]()
            if main.count == 0 || main.count == all.count {
                return candidates
            }
            var x0 = main.first!.x
            for i in 1..<main.count {
                let x1 = main[i].x
                let arr = (all.filter{$0.x > x0 && $0.x < x1}).sorted{$0.priority > $1.priority}
                if arr.count > 0 {
                    candidates.append(arr.first!)
                }
                x0 = x1
            }
            return candidates
        }
        
    }
    
    var valuesLayer: XValuesLayer!
    override init(frame: CGRect) {
        super.init(frame: frame)
        valuesLayer = XValuesLayer()
        self.layer.addSublayer(valuesLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    var chartRange = ChartRange(fromX: 0, toX: 1) {
        didSet {
           valuesLayer.range = chartRange
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        valuesLayer.frame = self.bounds
        valuesLayer.setNeedsLayout()
    }
    
    

}


