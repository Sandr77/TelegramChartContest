//
//  ViewController.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 16/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSource.shared.charts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init()
        cell.textLabel?.text = "Chart number \(indexPath.row + 1)"
        cell.textLabel?.textColor = GraphAppearance.shared.appearanceMode == .day ? .black : .white
        cell.backgroundColor = GraphAppearance.tableCellBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChartViewController()
        vc.chartData = DataSource.shared.charts[indexPath.row]
        vc.chartTitle = "Chart number \(indexPath.row + 1)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = GraphAppearance.tableCellBackground
        tableView.backgroundColor = GraphAppearance.tableCellBackground
        tableView.reloadData()

    }
    
   


}

