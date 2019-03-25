//
//  AlphaMaskView.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 22/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class AlphaMaskView: UIView {
    
    var leftMaskWidth = CGFloat(0) {
        didSet {
            self.setNeedsLayout()
        }
    }
    var rightMaskWidth = CGFloat(0) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private var leftMaskView = UIView()
    private var rightMaskView = UIView()
    private var middleView = UIView()
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leftMaskView.frame = CGRect(x: 0, y: 0, width: leftMaskWidth, height: self.bounds.size.height)
        rightMaskView.frame = CGRect(x: self.bounds.size.width - rightMaskWidth, y: 0, width: rightMaskWidth, height: self.bounds.size.height)
        middleView.frame = CGRect(x: leftMaskWidth, y: 0, width: self.bounds.size.width - rightMaskWidth - leftMaskWidth, height: self.bounds.size.height)
        
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(leftMaskView)
        self.addSubview(rightMaskView)
        self.addSubview(middleView)
        middleView.backgroundColor = .white
        leftMaskView.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
        rightMaskView.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
