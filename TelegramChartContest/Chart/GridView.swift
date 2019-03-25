//
//  GridView.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 21/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class GridView: UIView {
    
    var maxValue: Double = 1
    
    var currentLayer: GridLayer!
    
    var layers = [GridLayer]()
    
    var data: ChartData? {
        didSet {
            currentLayer = GridLayer()
            self.layer.addSublayer(currentLayer)
        }
    }
    
    
    func adjustMaxValue(_ m: Double, animate: Bool) {
 
        
        if m != self.maxValue {
            self.layers.forEach{
                $0.isAppearing = false
            }
            if animate {

                let newLayer = GridLayer()
                self.layers.append(newLayer)
                newLayer.progress = CGSize(width: m, height: 0)
                newLayer.frame = self.bounds
                self.layer.addSublayer(newLayer)
                
                CATransaction.begin()
                
                currentLayer.fromMaxValue = self.maxValue
                newLayer.fromMaxValue = m

                let duration = 0.3
                let a1 = createAnimation(from1: self.maxValue, to1: m, from2: 0, to2: 1, time: duration, key: "progress")
                CATransaction.setCompletionBlock({
                    let index = self.layers.index(of: newLayer)
                    self.layers.remove(at: index!)
                    if newLayer.isAppearing == false {
                        newLayer.removeFromSuperlayer()
                    }
                    else {
                        self.currentLayer.removeFromSuperlayer()
                        self.currentLayer = newLayer
                        self.currentLayer.fromMaxValue = self.maxValue
                        self.currentLayer.progress = CGSize(width: self.maxValue, height: 1)
                    }
                })
                currentLayer.add(a1, forKey: nil)
                currentLayer.isAppearing = false
                let a2 = createAnimation(from1: self.maxValue, to1: m, from2: 0, to2: 1, time: duration, key: "progress")
                newLayer.isAppearing = true
                newLayer.add(a2, forKey: nil)
                CATransaction.commit()
            }
            else {
                currentLayer.progress = CGSize(width: m, height: 1)
                currentLayer.fromMaxValue = m
                currentLayer.setNeedsDisplay()
            }
        }
        
        self.maxValue = m
    }
    

    private func createAnimation(from1: Double, to1: Double, from2: Double, to2: Double, time: Double, key: String) -> CABasicAnimation {
        let a = CABasicAnimation()
        a.keyPath = key
        
        a.fromValue = CGSize(width: from1, height: from2)
        a.toValue = CGSize(width: to1, height: to2)
        a.duration = time
        a.isRemovedOnCompletion = true
        a.fillMode = CAMediaTimingFillMode.forwards
        return a
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        currentLayer.frame = self.bounds
        currentLayer.setNeedsLayout()
    }
    
}
