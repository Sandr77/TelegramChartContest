//
//  BottomChartView.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 16/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit


protocol BottomChartViewDelegate: class {
    func selectionChanged()
}

class BottomChartView: UIView  {
    
    var minDelta: Double = 0.1
    let minDeltaX: CGFloat = 50
    
    enum DragPointType {
        case left
        case middle
        case right
        case none
    }
    
    weak var delegate: BottomChartViewDelegate?
    
    private enum LeftOrRight {
        case left
        case right
    }
    
    var chartRange = ChartRange(fromX: 0, toX: 1) {
        didSet {
            self.delegate?.selectionChanged()
        }
    }
    
    
    private class SideView: UIView {
        
        var position: LeftOrRight!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor.init(red: 0.22, green: 0.27, blue: 0.34, alpha: 0.7)
            self.clipsToBounds = true
            self.layer.cornerRadius = 5
        }
        
        override func draw(_ rect: CGRect) {
            let ctx = UIGraphicsGetCurrentContext()!
            let delta: CGFloat = position == .left ? 5 : -5
            ctx.setLineWidth(2)
            ctx.setStrokeColor(UIColor.white.cgColor)
            ctx.move(to: CGPoint(x: self.bounds.size.width / 2 + delta / 2, y: self.bounds.size.height / 2 - 6))
            ctx.addLine(to: CGPoint(x: self.bounds.size.width / 2 - delta / 2, y: self.bounds.size.height / 2))
            ctx.addLine(to: CGPoint(x: self.bounds.size.width / 2 + delta / 2, y: self.bounds.size.height / 2 + 6))
            ctx.strokePath()
        }
        
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private class LineView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor =  UIColor.init(red: 0.22, green: 0.27, blue: 0.34, alpha: 0.7)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var chartView = ChartView()
    var chartContainer = UIView()
    private var leftView = SideView()
    private var rightView = SideView()
    private var topLine = LineView()
    private var bottomLine = LineView()
    
    private var alphaMaskView = AlphaMaskView()
    private var sideShadowView = BottomSideShadowView()
    private var startTouchX: CGFloat = 0
    
    
    private var startRange = ChartRange(fromX: 0.3, toX: 0.7)
    private var dragType: DragPointType = .none
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        chartView.range = chartRange
        chartView.frame = chartContainer.bounds
        chartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(chartContainer)
        chartContainer.addSubview(chartView)
        chartContainer.addSubview(sideShadowView)

        chartView.gridView.removeFromSuperview()
        chartView.lineWidth = 1
        leftView.position = .left
        rightView.position = .right
        self.addSubview(chartView)
        self.addSubview(leftView)
        self.addSubview(rightView)
        self.addSubview(topLine)
        self.addSubview(bottomLine)
        
        leftView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
        rightView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMaxXMaxYCorner]
        
        chartView.mask = alphaMaskView
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        minDelta = self.bounds.size.width > 0 ? Double(minDeltaX / self.bounds.size.width) : 0.5
        leftView.frame = CGRect(x: chartRange.fromX * Double(self.bounds.size.width), y: 0.0, width: 10.0, height: Double(self.bounds.size.height))
        rightView.frame = CGRect(x: chartRange.toX * Double(self.bounds.size.width) - 10, y: 0, width: 10, height: Double(self.bounds.size.height))
        
        alphaMaskView.frame = self.bounds
        

        alphaMaskView.leftMaskWidth = leftView.frame.origin.x
        alphaMaskView.rightMaskWidth = self.bounds.size.width - (rightView.frame.origin.x + rightView.bounds.size.width)
                topLine.frame = CGRect(x: leftView.frame.origin.x + leftView.frame.size.width, y: 0, width: self.bounds.size.width - (leftView.bounds.size.width + rightView.bounds.size.width + alphaMaskView.leftMaskWidth + alphaMaskView.rightMaskWidth), height: 2)
        bottomLine.frame = CGRect(x: topLine.frame.origin.x, y: self.bounds.size.height - 2, width: topLine.bounds.size.width, height: 2)

        chartContainer.frame = CGRect(x: 0, y: 2, width: self.bounds.size.width, height: self.bounds.size.height - 4)
        
        sideShadowView.frame = chartContainer.bounds
        sideShadowView.leftMaskWidth = alphaMaskView.leftMaskWidth
        sideShadowView.rightMaskWidth = alphaMaskView.rightMaskWidth
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        startTouchX = point.x
        NotificationCenter.default.post(name: Notification.Name("DisableScrolling"), object: nil)
        
        let distance = rightView.frame.origin.x - leftView.frame.origin.x - leftView.bounds.size.width
        var delta: CGFloat = (distance - minDeltaX) / 2
        if delta > 20 {
            delta = 20
        }
        
        if CGRect(x: leftView.frame.origin.x - 20, y: 0, width: leftView.bounds.size.width + 20 + delta, height: self.bounds.size.height).contains(point) {
            dragType = .left
        }
        else if CGRect(x: rightView.frame.origin.x - delta, y: 0, width: rightView.bounds.size.width + 20 + delta, height: self.bounds.size.height).contains(point) {
            dragType = .right
        }
        else if CGRect(x: leftView.frame.origin.x, y: 0.0, width: rightView.frame.origin.x - leftView.frame.origin.y, height: self.bounds.size.height).contains(point) {
            dragType = .middle
        }
        else {
            dragType = .none
        }
        startRange = ChartRange(fromX: chartRange.fromX, toX: chartRange.toX)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dragType == .none {
            return
        }
        let x = touches.first!.location(in: self).x
        
        if dragType == .middle {
            var newFromX = Double(startRange.fromX) + Double((x - startTouchX) / self.bounds.size.width)
            var newToX = newFromX + (startRange.toX - startRange.fromX)
            if newFromX < 0 {
                newFromX = 0
                newToX = newFromX + (startRange.toX - startRange.fromX)
            }
            if newToX > 1 {
                newToX = 1
                newFromX = newToX - (startRange.toX - startRange.fromX)
            }
            chartRange = ChartRange(fromX: newFromX, toX: newToX)
        }
        else if dragType == .left {
            var newFromX = Double(startRange.fromX) + Double((x - startTouchX) / self.bounds.size.width)
            if newFromX < 0 {
                newFromX = 0
            }
            if newFromX > startRange.toX - minDelta  {
                newFromX = startRange.toX - minDelta
            }
            chartRange.fromX = newFromX
        }
        else if dragType == .right {
            var newToX = Double(startRange.toX) + Double((x - startTouchX) / self.bounds.size.width)
            if newToX > 1 {
                newToX = 1
            }
            if newToX < startRange.fromX + minDelta  {
                newToX = startRange.fromX + minDelta
            }
            chartRange.toX = newToX
        }
          self.setNeedsLayout()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(name: Notification.Name("EnableScrolling"), object: nil)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(name: Notification.Name("EnableScrolling"), object: nil)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

