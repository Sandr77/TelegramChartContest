//
//  BottomSideShadowView.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 22/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class BottomSideShadowView: UIView {
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leftMaskView.frame = CGRect(x: 0, y: 0, width: leftMaskWidth, height: self.bounds.size.height)
        rightMaskView.frame = CGRect(x: self.bounds.size.width - rightMaskWidth, y: 0, width: rightMaskWidth, height: self.bounds.size.height)
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(leftMaskView)
        self.addSubview(rightMaskView)
        
        leftMaskView.backgroundColor = UIColor.init(red: 0.10, green: 0.13, blue: 0.17, alpha: 0.2)//UIColor.init(white: 0.5, alpha: 0.2)
        rightMaskView.backgroundColor = UIColor.init(red: 0.10, green: 0.13, blue: 0.17, alpha: 0.2)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
