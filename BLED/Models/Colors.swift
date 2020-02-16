//
//  Colors.swift
//  BLED
//
//  Created by Roman Matusewicz on 12/01/2020.
//  Copyright © 2020 Roman Matusewicz. All rights reserved.
//

import UIKit
import Spring

struct Colors {
   var mode: Int? = nil
   var lightColor: UInt8? = nil
    
   mutating func getModeText()->String{
    var modeText:String = ""
        if mode != nil {
            let modeValue = mode!
            
            switch modeValue {
            case 1:
                modeText = "Light Off"
            case 2:
                modeText = "Color mode"
            case 3:
                modeText = "Yellow mode"
            case 4:
                modeText = "White mode"
            default:
                print("mode")
            }
        } else {
            modeText = "ON"
        }
        return modeText
    }
    
    mutating func colorValue (tagValue: Int)->UInt8 {
        var color: UInt8? = nil
        switch tagValue {
        case 1:
            color = 32
        case 2:
            color = 70
        case 3:
            color = 80
        case 4:
            color = 96
        case 5:
            color = 118
        case 6:
            color = 134
        case 7:
            color = 176
        case 8:
            color = 192
        case 9:
            color = 216
        case 10:
            color = 0
        case 11:
            color = 16
        case 12:
            color = 24
        default:
            print("...")
        }
        return color ?? 255
    }
    
    mutating func getColor (color: UInt8)->UIColor {
        let colorInt = Int(color)
        var sliderColor: UIColor? = nil

            switch colorInt {
                    case 0...7:
                        sliderColor = UIColor.systemRed
                    case 8...19:
                        sliderColor = UIColor(red: 235/255, green: 102/255, blue: 20/255, alpha: 1)
                    case 20...29:
                        sliderColor = UIColor.systemOrange
                    case 30...49:
                        sliderColor = UIColor(red: 247/255, green: 224/255, blue: 22/255, alpha: 1)
                    case 50...75:
                        sliderColor = UIColor(red: 137/255, green: 215/255, blue: 55/255, alpha: 1)
                    case 76...89:
                        sliderColor = UIColor.systemGreen
                    case 90...109:
                        sliderColor = UIColor(red: 37/255, green: 215/255, blue: 172/255, alpha: 1)
                    case 110...124:
                        sliderColor = UIColor.systemTeal
                    case 125...159:
                        sliderColor = UIColor.systemBlue
                    case 160...183:
                        sliderColor = UIColor.systemIndigo
                    case 184...204:
                        sliderColor = UIColor.systemPurple
                    case 205...224:
                        sliderColor = UIColor.systemPink
                    case 225...253:
                        sliderColor = UIColor.systemRed
                    case 254:
                        sliderColor = UIColor.lightGray
                    default:
                        print("...")
                    }
        return sliderColor ?? UIColor.systemYellow
    }
    
    func shakeButton(_ button: SpringButton) {
        button.animation = "shake"
        button.force = 0.5
        button.animate()
    }

}
