//
//  ViewController.swift
//  Slot_Machine
//
//  Created by Ignat Pechkurenko on 2020-01-11.
//  Copyright © 2020 Jackpot-Wizards. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var player = Player()
    var slotMachine = SlotMachine()
    
    var reelAnimationIsOver = 0
    var newRoundPlayed = false
    var betWasPressed = false
    
    @IBOutlet weak var Bank: UILabel!
    @IBOutlet weak var Bet: UILabel!
    @IBOutlet weak var JackPot: UILabel!
    @IBOutlet weak var Bet1: UIButton!
    @IBOutlet weak var BetMax: UIButton!
    @IBOutlet weak var Spin: UIButton!
    
    var stopSignal : [Bool] = [false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.roundIsOver(_:)), name: NSNotification.Name(rawValue: "roundIsOver"), object: nil)
        
        Bank.text = String(player.bank)
        Bet.text = "0"
        JackPot.text = "0"
    }
    
    @objc func roundIsOver(_ notification: NSNotification) {
        reelAnimationIsOver += 1
        if (reelAnimationIsOver == 3)
        {
            reelAnimationIsOver = 0;
            Bet1.isEnabled = true;
            BetMax.isEnabled = true;
            Spin.isEnabled = true;
            
            newRoundPlayed = true;
            betWasPressed = false;
        }
    }
    
    @IBAction func Spin(_ sender: UIButton, forEvent event: UIEvent) {
        // if no bet buttons were pressed
        if (!betWasPressed)
        {
            Bank.text = String(Int(Bank.text!)! - Int(Bet.text!)!)
        }
    }
    
    @IBAction func BetOne(_ sender: UIButton, forEvent event: UIEvent) {
        betWasPressed = true;
        
        if (newRoundPlayed)
        {
            Bet.text = "1"
            Bank.text = String(Int(Bank.text!)! - 1)
        } else if Int(Bet.text!)! < 3
        {
            Bet.text = String(Int(Bet.text!)! + 1)
            Bank.text = String(Int(Bank.text!)! - 1)
        }
        
        newRoundPlayed = false;
    }
    
    @IBAction func BetMax(_ sender: UIButton, forEvent event: UIEvent) {
        
        if (!betWasPressed)
        {
            Bank.text = String(Int(Bank.text!)! - 3)
        }
        else
        {
            Bank.text = String(Int(Bank.text!)! + Int(Bet.text!)! - 3)
        }
        
        Bet.text = "3"
        betWasPressed = true;
        Bet1.isEnabled = false;
        BetMax.isEnabled = false;
        Spin.isEnabled = false;
        stopSignal = [false, false, false]
        
        player.bank = Int(Bank.text!)!
        player.bet = Int(Bet.text!)!
        
        do {
            let (betLine, winnings) = try slotMachine.PlayRound(player)
            
            Bet1.isEnabled = false;
            BetMax.isEnabled = false;
            Spin.isEnabled = false;
            stopSignal = [false, false, false]
            Animate();
        } catch {
            print("Error!")
        }
    }
    
    
    @IBOutlet weak var textWithTimer: UILabel!
    
    @IBOutlet weak var imgViewSlotItem1: UIImageView!
    
    @IBOutlet weak var imgViewSlotItem2: UIImageView!
    
    @IBOutlet weak var imgViewSlotItem3: UIImageView!
    // Parameters for the movement of the reel
    let posStop : CGFloat = 300     // Position of the line
    let moveDist :CGFloat = 25      // Resolution of each movement : the bigger the faster movement.
    let spinSpeed : CGFloat = 0.01  // Duration of the each movement : the bigger the slower the movement.
    let spinTime : Double = 1       // Time(sec.) to spin a reel before make the stop
    
    // Parameters for slot reel
    var reelWidth : CGFloat = 100   // Width of the reel
    var reelHeight : CGFloat = 1000 // Height of the reel
    var reelStartPos : CGFloat = 0  // Start y position of the reel
    var reelStopPos : CGFloat = 0   // Stop y position of the reel
    
    var posItems : [CGFloat] = [0,0,0,0,0,0,0]
    
    func Animate() -> Void
    {
        // Initialize parameters for slot reel
        reelWidth = imgViewSlotItem1.frame.width
        reelHeight = reelWidth * 10
        reelStartPos = posStop - reelHeight + reelWidth * 2 // remon bottom
        reelStopPos = reelStartPos + reelWidth * 7 // remon top
        
        let posCherry : CGFloat = reelStopPos - reelWidth * 6
        let posDiamond : CGFloat = reelStopPos - reelWidth * 5
        let posGrape : CGFloat = reelStopPos - reelWidth * 4
        let posHart : CGFloat = reelStopPos - reelWidth * 3
        let posBar : CGFloat = reelStopPos - reelWidth * 2
        let posBell : CGFloat = reelStopPos - reelWidth * 1
        let posRemon : CGFloat = reelStopPos - reelWidth * 0
        
        for idx in 0...6 {
            posItems[idx] = reelStopPos - reelWidth * CGFloat(idx)
        }
        
        var posRndEmpty = posItems[Int.random(in: 1..<6)] - reelWidth/2
        /*
         cherry : - reelWidth * 6
         diamond : - reelWidth * 5
         grape : - reelWidth * 4
         hart : - reelWidth * 3
         bar : - reelWidth * 2
         bell : - reelWidth
         remon : reelStopPos
         */
        
        imgViewSlotItem1.frame.origin.x = 100
        imgViewSlotItem2.frame.origin.x = 205
        imgViewSlotItem3.frame.origin.x = 310
        
        imgViewSlotItem1.frame.origin.y = reelStartPos
        imgViewSlotItem2.frame.origin.y = reelStartPos
        imgViewSlotItem3.frame.origin.y = reelStartPos
        
        //
        //        runSpin(imgViewSlotItem1, spinSpeed, posCherry, 0)
        //        runSpin(imgViewSlotItem1, spinSpeed, posDiamond)
        //        runSpin(imgViewSlotItem1, spinSpeed, posGrape)
        //        runSpin(imgViewSlotItem1, spinSpeed, posHart)
        //        runSpin(imgViewSlotItem1, spinSpeed, posBar)
        //        runSpin(imgViewSlotItem1, spinSpeed, posRemon)
        
        
        // Empty Items
        //        runSpin(imgViewSlotItem1, spinSpeed, posCherry-reelWidth/2)
        //        runSpin(imgViewSlotItem1, spinSpeed, posDiamond-reelWidth/2)
        //        runSpin(imgViewSlotItem1, spinSpeed, posGrape-reelWidth/2)
        //        runSpin(imgViewSlotItem1, spinSpeed, posHart-reelWidth/2)
        //        runSpin(imgViewSlotItem1, spinSpeed, posBar-reelWidth/2)
        //        runSpin(imgViewSlotItem1, spinSpeed, posRemon-reelWidth/2)
        
        posRndEmpty = posItems[Int.random(in: 1..<6)] - reelWidth/2
        runSpin(imgViewSlotItem1, spinSpeed, posRndEmpty, 0)
        
        posRndEmpty = posItems[Int.random(in: 1..<6)] - reelWidth/2
        runSpin(imgViewSlotItem2, spinSpeed, posDiamond, 1)
        
        posRndEmpty = posItems[Int.random(in: 1..<6)] - reelWidth/2
        runSpin(imgViewSlotItem3, spinSpeed, posRemon, 2)
        
        textWithTimer.text = "first"
    }
    
    func runSpin(_ imageView: UIImageView,_ speed:CGFloat, _ posStop:CGFloat, _ idxReel:Int) {
        let spinTimeWithIdx = self.spinTime * Double(idxReel + 1)
        Timer.scheduledTimer(withTimeInterval: spinTimeWithIdx, repeats: false, block: { timer in
            self.stopSignal[idxReel] = true
        })
        
        spinReel(imageView, speed, posStop, idxReel)
    }
    
    
    func spinReel(_ imageView: UIImageView,_ speed:CGFloat, _ posStop:CGFloat, _ idxReel:Int) {
        var speeds = speed
        
        // To slow it down
        if ((imageView.frame.origin.y == posStop - self.moveDist*2)
            && (true == self.stopSignal[idxReel])){
            speeds = speed * 5
        }
        if ((imageView.frame.origin.y == posStop - self.moveDist)
            && (true == self.stopSignal[idxReel])){
            speeds = speed * 5
        }
        
        UIView.animate(withDuration: TimeInterval(speeds), delay: 0.0, options:.curveLinear, animations: {
            imageView.frame.origin.y = imageView.frame.origin.y + self.moveDist
        }, completion: { (_) in
            
            if (imageView.frame.origin.y == posStop) {
                if ((true == self.stopSignal[idxReel])) {
                    imageView.layer.removeAllAnimations()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "roundIsOver"), object: nil)
                } else {
                    if(imageView.frame.origin.y == self.reelStopPos) {
                        // Start again
                        imageView.frame.origin.y = self.reelStartPos
                        self.spinReel(imageView, speeds, posStop, idxReel)
                    } else {
                        self.spinReel(imageView, speeds, posStop, idxReel)
                    }
                }
            } else {
                if(imageView.frame.origin.y == self.reelStopPos) {
                    // Start again
                    imageView.frame.origin.y = self.reelStartPos
                    self.spinReel(imageView, speeds, posStop, idxReel)
                } else {
                    self.spinReel(imageView, speeds, posStop, idxReel)
                }
            }
        })
    }
    
}

