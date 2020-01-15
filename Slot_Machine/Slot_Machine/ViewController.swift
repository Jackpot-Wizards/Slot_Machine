//
//  ViewController.swift
//  Slot_Machine
//
//  Created by Ignat Pechkurenko on 2020-01-11.
//  Copyright © 2020 Jackpot-Wizards. All rights reserved.
//
/*
File Name: ViewController.swift
Author's Name: Huen Oh
StudentID: 301082798
Date: 2020.01.14
App description: Slot_Machine
Version information: 1.0
*/

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
    
    
    // Slot images
    @IBOutlet weak var imgViewSlotItem1: UIImageView!
    @IBOutlet weak var imgViewSlotItem2: UIImageView!
    @IBOutlet weak var imgViewSlotItem3: UIImageView!
    
    // Parameters for the movement of the reel
    let posStop : CGFloat = 325     // Position of the line
    let moveDist : CGFloat = 25     // Resolution of each movement : the bigger the faster movement.
    let spinSpeed : CGFloat = 0.01  // Duration of the each movement : the bigger the slower the movement.
    let spinTime : Double = 1       // Time(sec.) to spin a reel before make the stop
    
    // Parameters for slot reel
    var reelWidth : CGFloat = 100   // Width of the reel
    var reelHeight : CGFloat = 1000 // Height of the reel
    var reelStartPos : CGFloat = 0  // Start y position of the reel
    var reelStopPos : CGFloat = 0   // Stop y position of the reel
    
    // Stop signal for the reels : It should be initialized as false before starting spin
    var stopSignal : [Bool] = [false, false, false]
    
    // Position of the Blank items, which is between object items.
    var posItemsForRandBlank : [CGFloat] = [0,0,0,0,0,0,0]

    // Position of the object items in Dictionary
    var posItemsDict = ["Grapes":CGFloat(0), "Hart":CGFloat(0), "Lemon":CGFloat(0), "Cherry":CGFloat(0), "Bar":CGFloat(0), "Bell":CGFloat(0), "Diamond":CGFloat(0)]
    
    // Array for the slot image views
    var arrSlotImgView : [UIImageView]?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.roundIsOver(_:)), name: NSNotification.Name(rawValue: "roundIsOver"), object: nil)
        
        Bank.text = String(player.bank)
        Bet.text = "0"
        JackPot.text = "0"
        
        
        // Initialize array for the slot image views
        arrSlotImgView = [imgViewSlotItem1, imgViewSlotItem2, imgViewSlotItem3]
        
        // Initialize Animation values
        InitSpinAnimation()
    }
    
    
    @objc func roundIsOver(_ notification: NSNotification) {
        reelAnimationIsOver += 1
        if (reelAnimationIsOver == 3)
        {
            reelAnimationIsOver = 0;
            Bank.text = String(player.bank)
            
            // disable all buttons if bank is empty
            if (player.bank - 1 >= 0)
            {
                Bet1.isEnabled = true;
                BetMax.isEnabled = true;
                Spin.isEnabled = true;
                
                newRoundPlayed = true;
                betWasPressed = false;
            }
        }
    }
    
    @IBAction func Spin(_ sender: UIButton, forEvent event: UIEvent) {
        // if no bet buttons were pressed
        if (!betWasPressed)
        {
            Bank.text = String(Int(Bank.text!)! - Int(Bet.text!)!)
        }
        
        Bet1.isEnabled = false;
        BetMax.isEnabled = false;
        Spin.isEnabled = false;
        stopSignal = [false, false, false]  // Initialize stop signals
        slotMachineRun()
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
        
        slotMachineRun()
    }
    
    func slotMachineRun() -> Void {
        player.bet = Int(Bet.text!)!
        
        do {
            let (betLine, winnings) = try slotMachine.PlayRound(player)
            
            Bet1.isEnabled = false;
            BetMax.isEnabled = false;
            Spin.isEnabled = false;
            stopSignal = [false, false, false]
            RunSpinAnimation(betLine);
        } catch {
            print("Error!")
        }
    }
    
    
    /**
     Initialize parameters for the spin animation
     - Parameters: None
     - Returns: None
     */
    func InitSpinAnimation() -> Void {
        // Initialize parameters for slot reel
        reelWidth = imgViewSlotItem1.frame.width
        reelHeight = reelWidth * 10
        reelStartPos = posStop - reelHeight + reelWidth * 2 // remon bottom
        reelStopPos = reelStartPos + reelWidth * 7 // remon top
        
        // Initialize position of slot image views
        imgViewSlotItem1.frame.origin.x = 15
        imgViewSlotItem2.frame.origin.x = 136
        imgViewSlotItem3.frame.origin.x = 260
        imgViewSlotItem1.frame.origin.y = reelStartPos
        imgViewSlotItem2.frame.origin.y = reelStartPos
        imgViewSlotItem3.frame.origin.y = reelStartPos
        
        
        // Initialize position of the Blank items, which is between object items.
        for idx in 0...6 {
            posItemsForRandBlank[idx] = reelStopPos - reelWidth * CGFloat(idx) - reelWidth/2
        }
        
        /*
         cherry : - reelWidth * 6
         diamond : - reelWidth * 5
         grape : - reelWidth * 4
         hart : - reelWidth * 3
         bar : - reelWidth * 2
         bell : - reelWidth
         remon : reelStopPos
         */
        // Initialize position of the object items in Dictionary
        posItemsDict.updateValue(CGFloat(reelStopPos - reelWidth * 6), forKey:"Cherry")
        posItemsDict.updateValue(CGFloat(reelStopPos - reelWidth * 5), forKey:"Diamond")
        posItemsDict.updateValue(CGFloat(reelStopPos - reelWidth * 4), forKey:"Grapes")
        posItemsDict.updateValue(CGFloat(reelStopPos - reelWidth * 3), forKey:"Hart")
        posItemsDict.updateValue(CGFloat(reelStopPos - reelWidth * 2), forKey:"Bar")
        posItemsDict.updateValue(CGFloat(reelStopPos - reelWidth * 1), forKey:"Bell")
        posItemsDict.updateValue(CGFloat(reelStopPos - reelWidth * 0), forKey:"Lemon")
    }
    
    /**
     Run the spin animation
     - Parameters:
      - betLine: Array of three Strings - the result of slot machine logic
     - Returns: None
     */
    func RunSpinAnimation(_ betLine : [String]) -> Void
    {
        // Position of item to stop
        var posItemToStop = CGFloat(0)
        
        // For slot 1, 2 and 3
        for idx in 0...2 {
            if(betLine[idx] == "Blank") {
                // If "Blank" select random among the positions of "Blank"
                posItemToStop = posItemsForRandBlank[Int.random(in: 1..<6)]
            } else {
                // Get the positon of the object item
                posItemToStop = posItemsDict[betLine[idx]]!
            }
            // Run the spin
            runSpin(arrSlotImgView![idx], spinSpeed, posItemToStop, idx)
        }
    }
    
    /**
     Run each of the spin with timer
     - Parameters:
      - imageView: Image view of the reel to spin
      - speed: Speed of the spin
      - posStop: Position to stop the spin
      - idxReel: Index of the reel - 0, 1, or 2
     - Returns: None
     */
    func runSpin(_ imageView: UIImageView, _ speed:CGFloat, _ posStop:CGFloat, _ idxReel:Int) {
        // Timer to spin before stop
        let spinTimeWithIdx = self.spinTime * Double(idxReel + 1)
        
        // Set timer to run spin before stop
        Timer.scheduledTimer(withTimeInterval: spinTimeWithIdx, repeats: false, block: { timer in
            self.stopSignal[idxReel] = true
        })
        
        // Spin the reel
        spinReel(imageView, speed, posStop, idxReel)
    }
    
    /**
     Spin a reel with conditions to stop
     - Parameters:
      - imageView: Image view of the reel to spin
      - speed: Speed of the spin
      - posStop: Position to stop the spin
      - idxReel: Index of the reel - 0, 1, or 2
     - Returns: None
     */
    func spinReel(_ imageView: UIImageView,_ speed:CGFloat, _ posStop:CGFloat, _ idxReel:Int) {
        // Speed of the spin - it is adjustable in the function to slow the spin down before stop.
        var speeds = speed
        
        // To slow it down
        if ((imageView.frame.origin.y == posStop - self.moveDist*3)
            && (true == self.stopSignal[idxReel])){
            speeds = speed * 4
        }
        if ((imageView.frame.origin.y == posStop - self.moveDist*2)
            && (true == self.stopSignal[idxReel])){
            speeds = speed * 4
        }
        if ((imageView.frame.origin.y == posStop - self.moveDist)
            && (true == self.stopSignal[idxReel])){
            speeds = speed * 4
        }
        
        // Animate the spin
        UIView.animate(withDuration: TimeInterval(speeds), delay: 0.0, options:.curveLinear, animations: {
            // Move only by moveDist
            imageView.frame.origin.y = imageView.frame.origin.y + self.moveDist
        }, completion: { (_) in
            
            // Stop condition1 - the position
            if (imageView.frame.origin.y == posStop) {
                
                // Stop condition2 - stop signal
                if ((true == self.stopSignal[idxReel])) {
                    // Stop
                    imageView.layer.removeAllAnimations()
                    
                    // In case of "Lemon-bottom" move to reelStartPos("Lemon-top") unless it would never spin again!!!
                    if(imageView.frame.origin.y == self.posItemsDict["Lemon"]!) {
                        imageView.frame.origin.y = self.reelStartPos
                    }
                    
                    // Notify to indicate the run is overed
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "roundIsOver"), object: nil)
                } else {
                    // Roll over to the top or continue to move by moveDist to spin
                    if(imageView.frame.origin.y == self.reelStopPos) {
                        // Roll over to the top when it reached to the last item("Lemon")
                        imageView.frame.origin.y = self.reelStartPos
                        self.spinReel(imageView, speeds, posStop, idxReel)
                    } else {
                        // Continue to move by moveDist to spin
                        self.spinReel(imageView, speeds, posStop, idxReel)
                    }
                }
            } else {
                // Roll over to the top or continue to move by moveDist to spin
                if(imageView.frame.origin.y == self.reelStopPos) {
                    // Roll over to the top when it reached to the last item("Lemon")
                    imageView.frame.origin.y = self.reelStartPos
                    self.spinReel(imageView, speeds, posStop, idxReel)
                } else {
                    // Continue to move by moveDist to spin
                    self.spinReel(imageView, speeds, posStop, idxReel)
                }
            }
        })
    }
    
}

