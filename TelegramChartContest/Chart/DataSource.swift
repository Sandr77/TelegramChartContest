//
//  DataSource.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 16/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation

class DataSource {
    static let shared = DataSource()
    var charts = [ChartData]()
    init() {
        let path = Bundle.main.path(forResource: "chart_data", ofType: "json")
        let jsonData = try! Data.init(contentsOf: URL.init(fileURLWithPath: path!))
        let json = try! JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        
        let arr = json as! Array<Any>
        for v in arr {
            charts.append(ChartData.init(v as! [String: Any]))
        }
    }
}
