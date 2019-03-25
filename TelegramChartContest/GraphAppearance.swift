//
//  GraphAppearance.swift
//  TelegramChartContest
//
//  Created by Andrey Snetkov on 22/03/2019.
//  Copyright © 2019 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

enum AppearanceMode {
    case day
    case night
}

class GraphAppearance {
    static let shared = GraphAppearance()
    
    var appearanceMode = AppearanceMode.day
    
    
    
    class var tableBackground: UIColor {
        get {
            if GraphAppearance.shared.appearanceMode == .day {
                return UIColor.init(red: 239.0/255, green: 239.0/255, blue: 243.0/255, alpha: 1)
            }
            else {
                return UIColor.init(red: 26.0/255, green: 34.0/255, blue: 44.0/255, alpha: 1)
            }
        }
    }
    
    class var tableCellBackground: UIColor {
        get {
            if GraphAppearance.shared.appearanceMode == .day {
                return UIColor.white
            }
            else {
                return UIColor.init(red: 36.0/255, green: 47.0/255, blue: 62.0/255, alpha: 1)

            }
        }
    }
    
    class var graphPopupBackground: UIColor {
        get {
            if GraphAppearance.shared.appearanceMode == .day {
                return UIColor.init(white: 0.96, alpha: 1)
            }
            else {
                return UIColor.init(red: 0.11, green: 0.16, blue: 0.21, alpha: 1)
                
            }
        }
    }
    
    class var graphPopupDateColor: UIColor {
        get {
            if GraphAppearance.shared.appearanceMode == .day {
                return UIColor.init(white: 0.43, alpha: 1)
            }
            else {
                return UIColor.white
                
            }
        }
    }
    
    

    
}
