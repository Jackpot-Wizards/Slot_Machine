//
//  SlotMachine.swift
//  Slot_Machine
//
//  Created by Ignat Pechkurenko on 2020-01-11.
//  Copyright © 2020 Jackpot-Wizards. All rights reserved.
//

import Foundation

class SlotMachine
{
    private var betLine = [" ", " ", " "]

    private var grapes = 0;
    private var bananas = 0;
    private var oranges = 0;
    private var cherries = 0;
    private var bars = 0;
    private var bells = 0;
    private var sevens = 0;
    private var blanks = 0;

    private var player: Player!
    private var playerBet = 0
    
    private func ResetRound() -> Void
    {
        grapes = 0;
        bananas = 0;
        oranges = 0;
        cherries = 0;
        bars = 0;
        bells = 0;
        sevens = 0;
        blanks = 0;
        
        betLine = [" ", " ", " "]
    }
    
    private func CheckRange(_ value: Int, _ lowerBounds: Int, _ upperBounds: Int) -> Int
    {
        if (value >= lowerBounds && value <= upperBounds)
        {
            return value
        }
        
        return 0
    }
    
    private func DetermineWinnings() -> Void
    {
        var winnings = 0
        if (blanks == 0) {
            if (grapes == 3) {
                winnings = playerBet * 10;
            } else if (bananas == 3) {
                winnings = playerBet * 20;
            } else if (oranges == 3) {
                winnings = playerBet * 30;
            } else if (cherries == 3) {
                winnings = playerBet * 40;
            } else if (bars == 3) {
                winnings = playerBet * 50;
            } else if (bells == 3) {
                winnings = playerBet * 75;
            } else if (sevens == 3) {
                winnings = playerBet * 100;
            } else if (grapes == 2) {
                winnings = playerBet * 2;
            } else if (bananas == 2) {
                winnings = playerBet * 2;
            } else if (oranges == 2) {
                winnings = playerBet * 3;
            } else if (cherries == 2) {
                winnings = playerBet * 4;
            } else if (bars == 2) {
                winnings = playerBet * 5;
            } else if (bells == 2) {
                winnings = playerBet * 10;
            } else if (sevens == 2) {
                winnings = playerBet * 20;
            } else if (sevens == 1) {
                winnings = playerBet * 5;
            } else {
                winnings = playerBet * 1;
            }

            player.bank += winnings
        }
        else {
            player.bank -= playerBet
        }
        
        ResetRound()
    }

    public func PlayRound(player: Player) throws -> Void
    {
        if (player.bet < 0)
        {
            throw SlotException.exception("Bet cannot be negative")
        }
        
        if (player.bet > player.bank)
        {
            throw SlotException.exception("Bet cannot be greate than player's bank")
        }
        
        playerBet = player.bet
        var outCome = [0, 0, 0];
        
        for spin in 0...2
        {
            outCome[spin] = (Int)(floor(Double.random(in: 0.0..<1.0) * 65) + 1)
            
            switch (outCome[spin]) {
            case CheckRange(outCome[spin], 1, 27):  // 41.5% probability
                betLine[spin] = "blank";
                blanks += 1;
            case CheckRange(outCome[spin], 28, 37): // 15.4% probability
                betLine[spin] = "Grapes";
                grapes += 1;
            case CheckRange(outCome[spin], 38, 46): // 13.8% probability
                betLine[spin] = "Banana";
                bananas += 1;
            case CheckRange(outCome[spin], 47, 54): // 12.3% probability
                betLine[spin] = "Orange";
                oranges += 1;
            case CheckRange(outCome[spin], 55, 59): //  7.7% probability
                betLine[spin] = "Cherry";
                cherries += 1;
            case CheckRange(outCome[spin], 60, 62): //  4.6% probability
                betLine[spin] = "Bar";
                bars += 1;
            case CheckRange(outCome[spin], 63, 64): //  3.1% probability
                betLine[spin] = "Bell";
                bells += 1;
            case CheckRange(outCome[spin], 65, 65): //  1.5% probability
                betLine[spin] = "Seven";
                sevens += 1;
            default:
                print("Value is out of range")
            }
        }
    }
}
