//
//  ChartData.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 16/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class ChartPoint: Equatable {
    static func == (lhs: ChartPoint, rhs: ChartPoint) -> Bool {
        return lhs.globalX == rhs.globalX
    }
    
    var x: Double = 0
    var y: Double = 0
    var xLabel = ""
    var priority: Double = 0
    
    var globalX: Double = 0
    var globalY: Double = 0
    
    var timstamp: Double = 0
    
//    var image: CGImage!
    
    init(x: Double, y: Double, xLabel: String, image: CGImage? = nil) {
        self.x = x
        self.y = y
        self.xLabel = xLabel
        self.globalX = x
        self.globalY = y
//        if image == nil {
//            let label = UILabel.init()
//            label.textColor = .black
//            label.text = xLabel
//            label.sizeToFit()
//            UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
//            label.layer.render(in: UIGraphicsGetCurrentContext()!)
//            let im = UIGraphicsGetImageFromCurrentImageContext()
//            self.image = im!.cgImage
//            UIGraphicsEndImageContext()
//
//        }
    }
    
    func copy() -> ChartPoint {
        let p = ChartPoint.init(x: globalX, y: globalY, xLabel: xLabel)
        p.xLabel = self.xLabel
        p.timstamp = self.timstamp
        return p
    }
}

fileprivate enum LineType: String {
    case line = "line"
    case x = "x"
}

class ChartLine {
    var values = [Double]()
    
    var points = [ChartPoint]()
    
    func positions(fromX: Double, toX: Double, maxValue: Double) -> [ChartPoint] {
        let filtered = points.filter{$0.globalX >= (fromX - (toX - fromX) / 5) && $0.globalX <= (toX + (toX - fromX)/5)}
        let newPoints = filtered.map{$0.copy()}
        newPoints.forEach{
            $0.x = ($0.globalX - fromX)/(toX - fromX)
            $0.y = $0.globalY / maxValue
        }
        return newPoints
    }
    
    fileprivate var type = LineType.line
    var identity = ""
    var name = ""
    var isVisible = true
    var color: CGColor?
    
    func maxValue(fromX: Double, toX: Double) -> Double {
        var filteredPoints = points.filter{$0.globalX >= fromX && $0.globalX <= toX}
        if let first = filteredPoints.first {
            let index = points.index(of: first)
            if index! > 0 {
                filteredPoints.insert(points[index!], at: 0)
            }
        }
        if let last = filteredPoints.last {
            let index = points.index(of: last)
            if index! < points.count - 1 {
                filteredPoints.append(points[index!])
            }
        }

        
        return (filteredPoints.map{$0.y}).max() ?? 0
    }
    
    fileprivate var xValues: [Double]? {
        didSet {
            let maxV = xValues!.max()
            let minV = xValues!.min()
            xs = xValues!.map{($0 - minV!)/(maxV! - minV!)}
            for i in 0..<xs!.count {
                let p = ChartPoint.init(x: xs![i], y: values[i], xLabel: xValues![i].date())
                p.timstamp = xValues![i]
                points.append(p)
            }
            
            var sum = 3
            while sum < points.count {
                sum = (sum - 1) * 2 + 1
            }
            
            points[0].priority = 1
            
            self.fillPriority(from: 1, to: sum - 2, points: points, priority: 2)
            
        }
    }
    
    private func fillPriority(from: Int, to: Int, points: [ChartPoint], priority: Double) {
        if from == to {
            if from < points.count {
                points[from].priority = priority
            }
            return
        }
        let index = (from + to) / 2
        if index < points.count {
            let middle = points[Int(index)]
            middle.priority = priority
        }
        self.fillPriority(from: from, to: index - 1, points: points, priority: priority + 1)
        self.fillPriority(from: index + 1, to: to, points: points, priority: priority + 1)

    }
    
    private var xs: [Double]?
    
    init(_ values: [Any]) {
        identity = values.first! as! String
        for i in 1..<values.count {
            self.values.append(values[i] as! Double)
        }
    }
}




struct ChartData {
    
    var lines = [ChartLine]()
    var xLine: ChartLine!
    
    init(_ data: [String: Any]) {
        let cols = data["columns"] as! [Any]
        
        var order = [String]()
        var linesDict = [String: ChartLine]()
        for c in cols {
            let l = ChartLine.init(c as! [Any])
            linesDict[l.identity] = l
            order.append(l.identity)
        }
        let types = data["types"] as! [String: String]
        for t in types.keys {
            linesDict[t]!.type = LineType.init(rawValue: types[t]!)!
        }
        let names = data["names"] as! [String: String]
        for n in names.keys {
            linesDict[n]!.name = names[n]!
        }
        
        let colors = data["colors"] as! [String: String]
        for c in colors.keys {
            linesDict[c]?.color = UIColor.init(hexString: colors[c]!).cgColor
        }
        
        xLine = linesDict.values.filter{$0.type == .x}.first!
        
        for k in order {
            let l = linesDict[k]
            if l!.type == .line {
                lines.append(l!)
            }
        }
        lines.forEach{$0.xValues = xLine.values}
        
    }
}
