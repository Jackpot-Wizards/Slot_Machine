/*
 File Name: CustomButton.swift
 Author's Name: Huen Oh, Ignat Pechkurenko, Blair Desjardins
 StudentID: 301082798, 301091721, 301086973
 Date: 2020.01.14
 App description: Slot_Machine
 Version information: 1.0
 */

import UIKit

class CustomButton: UIButton {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    var defaultBackgroundColor: UIColor?
    var defaultTintColor: UIColor?
    
    
    /// Border width inspectable
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    
    /// Border colour inspectable
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    // Corner radius inspectable
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
}
