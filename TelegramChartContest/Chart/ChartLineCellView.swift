//
//  ChartLineCellView.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 22/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class ChartLineCellView: UITableViewCell {
    var chartLine: ChartLine? {
        didSet {
            adjustState()
        }
    }
    
    @IBOutlet weak var colorView: UIView?
    @IBOutlet weak var label: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorView?.layer.cornerRadius = 5
        colorView?.clipsToBounds = true
        self.adjustState()
    }
    
    func adjustState() {
        if chartLine != nil {
            colorView?.backgroundColor = UIColor.init(cgColor: chartLine!.color!)
            self.accessoryType = chartLine!.isVisible ? .checkmark : .none
        }
        label?.text = chartLine?.name
        label?.textColor = GraphAppearance.graphPopupDateColor
    }
}
