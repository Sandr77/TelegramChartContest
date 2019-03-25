//
//  ChartViewController.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 22/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class ChartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var chartTitle: String = ""
    
    var chartData: ChartData!
    
    var chart: MainChartView!
    
    var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        UINavigationBar.appearance().barStyle = UIBarStyle.black
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        
        tableView = UITableView.init(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = GraphAppearance.tableBackground
        tableView.separatorColor = UIColor.init(red: 0.22, green: 0.27, blue: 0.34, alpha: 0.7)
        
        self.view.addSubview(tableView)
        
        chart = MainChartView.init(chartData: chartData)
        chart.frame = CGRect(x: 20, y: 0, width: self.view.bounds.size.width - 40, height: self.view.bounds.size.width - 40)
        
        tableView.register(UINib.init(nibName: "ChartLineCellView", bundle: Bundle.main), forCellReuseIdentifier: "SelectionCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableScrolling), name: Notification.Name("EnableScrolling"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableScrolling), name: Notification.Name("DisableScrolling"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = GraphAppearance.tableCellBackground
        tableView.backgroundColor = GraphAppearance.tableBackground
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return chartData.lines.count + 1
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return chart.bounds.size.height
            }
            else {
                return 50
            }
        }
        else {
            return 50
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? chartTitle : nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "GraphCell")
                if cell == nil {
                    cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "GraphCell")
                    cell.addSubview(chart)
                    cell.separatorInset = UIEdgeInsets.init(top: 0, left: 1000, bottom: 0, right: 0)
                    cell.selectionStyle = .none
                }
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell")
                (cell as! ChartLineCellView).chartLine = self.chartData.lines[indexPath.row - 1]
            }
        }
        else {
            cell = UITableViewCell.init()
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .blue
            cell.textLabel?.text = GraphAppearance.shared.appearanceMode == .day ? "Switch To Night Mode" : "Switch to Day Mode"
        }
        cell.backgroundColor = GraphAppearance.tableCellBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0 {
            if indexPath.row > 0 {
                let line = chartData.lines[indexPath.row - 1]
                line.isVisible = !line.isVisible
                var haveVisibleLines = false
                for l in chartData.lines {
                    if l.isVisible {
                        haveVisibleLines = true
                        break
                    }
                }
                if haveVisibleLines == false {
                    line.isVisible = true
                }
                tableView.cellForRow(at: indexPath)?.accessoryType = line.isVisible ? .checkmark : .none
                chart.update()
            }
        }
        else {
            if GraphAppearance.shared.appearanceMode == .day {
                GraphAppearance.shared.appearanceMode = .night
            }
            else {
                GraphAppearance.shared.appearanceMode = .day
            }
            tableView.reloadData()
            adjustBackground()
        }
        
    }
    
    func adjustBackground() {
        self.navigationController?.navigationBar.barTintColor = GraphAppearance.tableCellBackground
        tableView.backgroundColor = GraphAppearance.tableBackground
        chart.update()
    }
    
    @objc func disableScrolling() {
        tableView.isScrollEnabled = false
    }
    
    @objc func enableScrolling() {
        tableView.isScrollEnabled = true
    }
    
}
