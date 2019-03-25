//
//  MainChartView.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 16/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class MainChartView: UIView, BottomChartViewDelegate {
     
    private var chartContainer = UIView()
    private var chartView = ChartView()
    private var bottomChart = BottomChartView()
    private var xValuesView = XValuesView()
    
    init(chartData: ChartData) {
        super.init(frame: .zero)
        chartView.data = chartData
        chartView.isUserInteractionEnabled = false
        chartContainer.addSubview(chartView)
        chartView.frame = chartContainer.bounds
        chartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(chartContainer)
        
         bottomChart.chartView.data = chartData//DataSource.shared.charts.last!
        bottomChart.chartRange = ChartRange(fromX: 0.3, toX: 0.7)
        
        self.addSubview(bottomChart)
        
        xValuesView.chartRange = ChartRange(fromX: 0.3, toX: 0.7)
        xValuesView.valuesLayer.line = chartData.lines.last!
        self.addSubview(xValuesView)
        
        
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(userTapped(gesture:)))
        chartContainer.addGestureRecognizer(gesture)
        
        bottomChart.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartContainer.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height - 75)
        bottomChart.frame = CGRect(x: 0, y: self.bounds.size.height - 50, width: self.bounds.size.width, height: 50)
        xValuesView.frame = CGRect(x: 0, y: self.bounds.size.height - 75, width: self.bounds.size.width, height: 20)
    }
    
    func selectionChanged() {
        chartView.range = bottomChart.chartRange
        
        xValuesView.chartRange = bottomChart.chartRange
    }
    
    func update() {
        chartView.changeVisibility()
        bottomChart.chartView.changeVisibility()
    }
    
    @objc func userTapped(gesture: UITapGestureRecognizer) {
        struct PointDistance {
            var distance: CGFloat
            var point: ChartPoint
        }
        let x = gesture.location(in: chartView).x
        
        let points = chartView.data!.lines.first!.positions(fromX: chartView.range.fromX, toX: chartView.range.toX, maxValue: 1)

        let distances = points.map{PointDistance(distance: abs(CGFloat($0.x) * chartView.bounds.size.width - x), point: $0)}
        let sorted = distances.sorted{$0.distance < $1.distance}
        chartView.selectedTimestamp = sorted.first!.point.timstamp
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
