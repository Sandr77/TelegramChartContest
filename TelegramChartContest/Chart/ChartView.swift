//
//  ChartView.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 16/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class ChartView: UIView {
    
    private var maxValue: Double = 0
    
    var gridView = GridView()
    var lineWidth: CGFloat = 1.5
    
    var selectedTimestamp: Double? {
        didSet {
            popupLayer.setNeedsDisplay()
            vertLineLayer.setNeedsDisplay()
            layers!.forEach{$0.setNeedsDisplay()}
        }
    }
    var popupLayer = ChartViewPopupLayer()
    var vertLineLayer = ChartVertLineLayer()
    
    var data: ChartData? {
        didSet {

            gridView.data = data!
            
            self.layer.addSublayer(vertLineLayer)
            vertLineLayer.parentView = self

            
            layers = [ChartViewLayer]()
            for l in data!.lines {
                let ll = ChartViewLayer()
                if l.isVisible == false {
                    ll.isHidden = true
                }
                ll.line = l
                ll.lineWidth = lineWidth
                ll.parentView = self
                ll.frame = self.bounds
                self.layer.addSublayer(ll)
                layers!.append(ll)
            }
            layers!.forEach{$0.chartRange = range}
            self.layer.addSublayer(popupLayer)
            popupLayer.parentView = self
             self.adjustMaxValue(animate: false)
        }
    }
    
    func changeVisibility() {
        for i in 0..<data!.lines.count {
            layers![i].isHidden = !data!.lines[i].isVisible
        }
        self.layer.setNeedsDisplay()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.popupLayer.setNeedsDisplay()
            self.adjustMaxValue(animate: true)

        })
    }
    
    
    var range: ChartRange = ChartRange(fromX: 0.3, toX: 0.7) {
        didSet {
            if layers == nil {
                return
            }
            layers!.forEach{$0.chartRange = range}
            popupLayer.setNeedsDisplay()
            vertLineLayer.setNeedsDisplay()
            adjustMaxValue(animate: true)
        }
    }

    
    func calcMaxValue() -> Double {
        let v = (self.layers!.filter{$0.isHidden == false}).map{$0.line!.maxValue(fromX: range.fromX, toX: range.toX)}
        return v.max() ?? 0
    }
    
    func adjustMaxValue(animate: Bool) {
        let m = self.calcMaxValue()
        if fabs(m - self.maxValue) > self.maxValue * 0.05 {
            self.layers!.forEach{
                if animate {
                    let animation = CABasicAnimation()
                    animation.keyPath = "max"
                    let from = $0.presentation()?.max ?? $0.max
                    animation.fromValue = from
                    animation.toValue = m
                    animation.duration = 0.3
                    animation.isRemovedOnCompletion = true
                    animation.fillMode = CAMediaTimingFillMode.forwards
                    $0.add(animation, forKey: "maxchange")
                }
                $0.max = m
                
            }
            self.maxValue = m
            gridView.adjustMaxValue(m, animate: animate)
            
        }
    }
    
    var layers: [ChartViewLayer]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(gridView.layer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.isOpaque = false
        if layers != nil {
            for l in layers! {
                l.frame = self.bounds
                l.setNeedsDisplay()
            }
        }
        gridView.layer.frame = self.bounds
        popupLayer.frame = self.bounds
        vertLineLayer.frame = self.bounds
        popupLayer.setNeedsDisplay()
    }    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
