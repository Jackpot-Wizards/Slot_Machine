/*
 File Name: ViewController.swift
 Author's Name: Huen Oh, Ignat Pechkurenko, Blair Desjardins
 StudentID: 301082798, 301091721, 301086973
 Date: 2020.01.14
 App description: Slot_Machine
 Version information: 1.0
 */

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var player = Player()
    var slotMachine = SlotMachine()
    
    var reelAnimationIsOver = 0
    var newRoundPlayed = false
    var betWasPressed = false
    var currentWinnings = 0
    var jackPotWon = false
    
    let emptyString = ""
    
    @IBOutlet weak var Bank: UILabel!
    @IBOutlet weak var Bet: UILabel!
    @IBOutlet weak var Bet1: UIButton!
    @IBOutlet weak var BetMax: UIButton!
    @IBOutlet weak var Spin: UIButton!
    @IBOutlet weak var Winnings: UILabel!
    @IBOutlet weak var Jackpot: UILabel!
    @IBOutlet weak var ResetButton: UIButton!
    
    
    
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
        
        
        // Initialize array for the slot image views
        arrSlotImgView = [imgViewSlotItem1, imgViewSlotItem2, imgViewSlotItem3]
        
        // Initialize Animation values
        InitSpinAnimation()
    }
    
    /// Exit button function
    @IBAction func ExitButton(_ sender: Any) {
        exit(0)
    }
    
    
    /// Reset button function
    @IBAction func ResetButton(_ sender: Any) {
        Reset()
    }
    
    
    /// Reset function
    private func Reset() -> Void
    {
        reelAnimationIsOver = 0
        newRoundPlayed = false
        betWasPressed = false
        currentWinnings = 0
        jackPotWon = false
        player.bank = 2000
        Bank.text = String(player.bank)
        Bet.text = ""
        
        arrSlotImgView = [imgViewSlotItem1, imgViewSlotItem2, imgViewSlotItem3]
        
        InitSpinAnimation()
    }
    
    /// Function to clear winnings and jackpot
    private func ClearWinnings() -> Void
    {
        Winnings.text = emptyString
        currentWinnings = 0
        Jackpot.text = emptyString
        jackPotWon = false
    }
    
    /// Function to disable buttons
    private func DisableButtons() -> Void
    {
        Bet1.isEnabled = false
        BetMax.isEnabled = false
        Spin.isEnabled = false
        ResetButton.isEnabled = false
    }
    
    /// Function to enable buttons
    private func EnableButtons() -> Void
    {
        Bet1.isEnabled = true
        BetMax.isEnabled = true
        Spin.isEnabled = true
        ResetButton.isEnabled = true
    }
    
    /// This function is called ones a reel animation is over
    /// and notification is raised
    /// - Parameter notification: <#notification description#>
    @objc func roundIsOver(_ notification: NSNotification) {
        reelAnimationIsOver += 1
        if (reelAnimationIsOver == 3)
        {
            reelAnimationIsOver = 0;
            
            Bank.text = player.bank == 0 ? emptyString : String(player.bank)
            
            if (player.bank == 0)
            {
                Bet.text = emptyString
                DisableButtons()
                return
            }
            
            Winnings.text = currentWinnings > 0 ? String(currentWinnings) : emptyString
            Jackpot.text = jackPotWon ? String(SlotMachine.JackPot) : emptyString
            
            // disable all buttons if bank is empty
            if (player.bank - SlotMachine.MinBet >= 0)
            {
                EnableButtons()
            }
            
            newRoundPlayed = true
            betWasPressed = false
        }
    }
    
    
    /// Handler of Spin button
    ///
    /// - Parameters:
    ///   - sender: <#sender description#>
    ///   - event: <#event description#>
    @IBAction func Spin(_ sender: UIButton, forEvent event: UIEvent) {
        ClearWinnings()
        
        // if no bet buttons were pressed
        if (!betWasPressed)
        {
            if (Bet.text!.isEmpty)
            {
                if (Int(Bank.text!)! - SlotMachine.MaxBet >= 0)
                {
                    Bet.text = String(SlotMachine.MaxBet)
                    Bank.text = String(Int(Bank.text!)! - SlotMachine.MaxBet)
                }
                else
                {
                    // cannot play with be greater than bank
                    return
                }
            }
            else
            {
                if (Int(Bank.text!)! - Int(Bet.text!)! >= 0)
                {
                    Bank.text = String(Int(Bank.text!)! - Int(Bet.text!)!)
                }
                else
                {
                    // cannot play with be greater than bank
                    return
                }
            }
        }
        
        DisableButtons()
        stopSignal = [false, false, false]  // Initialize stop signals
        SlotMachineRun()
    }
    
    
    /// Handler of BetOne button
    ///
    /// - Parameters:
    ///   - sender: <#sender description#>
    ///   - event: <#event description#>
    @IBAction func BetOne(_ sender: UIButton, forEvent event: UIEvent) {
        ClearWinnings()
        
        if Int(Bank.text!)! > 0 && Int(Bank.text!)! - SlotMachine.MinBet >= 0
        {
            if (newRoundPlayed)
            {
                Bet.text = String(SlotMachine.MinBet)
                Bank.text = String(Int(Bank.text!)! - SlotMachine.MinBet)
            }
            else  if Bet.text == emptyString || Int(Bet.text!)! < SlotMachine.MaxBet
            {
                let currentBet = Bet.text == emptyString ? 0 : Int(Bet.text!)!
                
                Bet.text = String(currentBet + SlotMachine.MinBet)
                Bank.text = String(Int(Bank.text!)! - SlotMachine.MinBet)
            }
            
            if (Int(Bank.text!)! == 0)
            {
                Bank.text = emptyString
            }
        }
        else
        {
            Bet1.isEnabled = false
            BetMax.isEnabled = false
        }
        
        betWasPressed = true;
        newRoundPlayed = false;
    }
    
    
    /// Handler of BetMax button
    ///
    /// - Parameters:
    ///   - sender: <#sender description#>
    ///   - event: <#event description#>
    @IBAction func BetMax(_ sender: UIButton, forEvent event: UIEvent) {
        ClearWinnings()
        
        var bet = SlotMachine.MaxBet
        
        if (!betWasPressed)
        {
            if Int(Bank.text!)! - SlotMachine.MaxBet >= 0
            {
                Bank.text = String(Int(Bank.text!)! - SlotMachine.MaxBet)
                
                if (Int(Bank.text!)! == 0)
                {
                    Bank.text = emptyString
                }
            }
            else
            {
                bet = Int(Bank.text!)!
                Bank.text = emptyString
            }
        }
        else
        {
            if (Int(Bank.text!)! + Int(Bet.text!)! - SlotMachine.MaxBet >= 0)
            {
                Bank.text = String(Int(Bank.text!)! + Int(Bet.text!)! - SlotMachine.MaxBet)
                
                if (Int(Bank.text!)! == 0)
                {
                    Bank.text = emptyString
                }
            }
            else
            {
                bet = Int(Bank.text!)! + Int(Bet.text!)!
                Bank.text = emptyString
            }
        }
        
        Bet.text = String(bet)
        
        DisableButtons()
        
        betWasPressed = true;
        stopSignal = [false, false, false]
        SlotMachineRun()
    }
    
    /// Function is called every round
    func SlotMachineRun() -> Void {
        player.bet = Int(Bet.text!)!
        player.bank = Bank.text == emptyString ? 0 : (Int)(Bank.text!)!
        
        do {
            let (betLine, winnings, jackpotwon) = try slotMachine.PlayRound(player)
            
            currentWinnings = winnings;
            jackPotWon = jackpotwon
            
            DisableButtons()
            
            stopSignal = [false, false, false]
            self.soundPlayerSpin = playSound("sound_slot_spin") //sound
            RunSpinAnimation(betLine)
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
                    
                    //sound
                    self.soundPlayerStop = self.playSound("sound_slot_stop")
                    if(2 == idxReel) {
                        self.soundPlayerSpin!.stop()
                    }
                    
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
    
    
    // Audio Player
    var soundPlayerStop: AVAudioPlayer? // Stop sound of the each spin
    var soundPlayerSpin: AVAudioPlayer? // Spin sound as background
    
    /**
     Playsound with audio plyer
     - Parameters:
      - fileName: File name of the sound
     - Returns: AVAudioPlayer
     */
    func playSound(_ fileName:String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return nil}

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            var soundPlayer: AVAudioPlayer?
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            soundPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let soundPlayerStop = soundPlayer else { return nil}

            soundPlayerStop.play()
            
            return soundPlayer

        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
}

