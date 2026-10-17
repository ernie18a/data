# Smart S/R Breakout Signals PX

- url: https://www.tradingview.com/script/XDi94EhW-Smart-S-R-Breakout-Signals-PX/
- type: indicator
- pine_id: PUB;389a4330a76244b88a9080a6a48c9148
- version: 2.0

## Description

[b]Smart S/R Breakout Signals[/b]

This a dynamic support/resistance breakout system that automatically plots evolving S/R lines from swing highs and swing lows, then signals a trade when price breaks through the opposite zone with confirmation.
How it works

The script tracks the lowest low (for Buy mode) or highest high (for Sell mode) and waits for a configurable number of consecutive closes (Num) above/below the prior bar's range before "fixing" that level as a support or resistance line.
Once a level is fixed, the script searches for the most significant opposing swing point and draws an S/R line from it.
When price closes through that opposing line, a new support/resistance cycle begins. After a chosen number of these S/R flips (Buyafter), the script arms itself to look for an entry.
An entry triggers on the breakout candle, plotting:

Entry label at the breakout level
Stop Loss — either the most recent S/R line or the last confirmed swing point (SL Mode)
Take Profit — calculated using your risk/reward multiple (rw)


Trade outcome is tracked live: TP/SL labels update with ✅ (hit), ❌ (missed), or 💔 (stopped out) so you can visually audit every signal on the chart.
A built-in fail-safe (Stop After X Fail) pauses new signals after a set number of consecutive losing trades, helping avoid chasing a choppy market.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartTrader-X

//version of indicator V1.1
//@version=6
indicator("Smart S/R Breakout Signals PX",shorttitle = "S/R Signal",overlay = true)

SignalType = input.string("Buy", title="Signal Type", options=["Buy","Sell"],confirm = true)
StartTime = input.time(timestamp("2 Jun 2025 00:00"), confirm=true, title="Start Time")

OrderAfter = input.int(3,tooltip = "Looking for signal after X S/R break")
StopAfterXFail = input.int(2)
Num = input.int(2)
rw = input.int(2,tooltip = "Reward To Risk")
SlMode = input.string("S/R Line",options = ["S/R Line","Last Swing"])
IsGreen = close > open
IsRed = close < open 

type HighPoint 
    HighestHigh = 0.0
    HighestHighIndex = 0
type LowPoint
    LowestLow = 0.0
    LowestLowIndex = 0
var HighestArr = array.new<HighPoint>() 
var LowestArr = array.new<LowPoint>()

if time >=  StartTime 
    if SignalType == "Buy"
        var BuyafterCount = 0
        var LowCounter = 0
        var int LowestLowIndex = bar_index
        var LowestLow = low
        var HighestHighIndex = bar_index
        var HighestHigh = low
        var FindLowest = false  
        var LookForLow = true 
        var LookForHigh = false 
        var RefHighOfLow = high  
        var MainLow = low 
        var line HighLine = na
        var line LowLine = na
        var MainLowIndex = bar_index
        var XSuportPassed = 0
        var Onlyone_buy = 0 
        var label ENtryBuy = na
        var float TpBuy = na 
        var line TpBuyLine = na 
        var label TpBuyLabel = na 
        var float SlBuy = na 
        var line SlBuyLine = na 
        var label SlBuyLabel = na 
        var firstHighLine = true 
        var firstLowLine = false
        var LowFixed = false
        var countFailed = 0

        var Res = 0
        if low < LowestLow or na(LowestLow)
            LowestLow := low 
            LowestLowIndex := bar_index
            if not na(LowLine) and LowFixed == false
                LowLine.delete()
                LowLine := line.new(LowestLowIndex,LowestLow,bar_index+3,LowestLow,color = color.green)
                Res := 0
        if LookForLow == false
            if close > RefHighOfLow
                RefHighOfLow := high 
                MainLowIndex := bar_index
                LowCounter := LowCounter +1
            if LowCounter == Num
                LowFixed := true 
                LowCounter := 0 
                LookForHigh := true   
                if na(LowLine)
                    LowLine := line.new(LowestLowIndex,LowestLow,bar_index,LowestLow,color = color.green)
                    Res := 0
        if LookForLow 
            if close > high[1] 
                if LowCounter == 0
                    LowCounter := 1
                    RefHighOfLow := high 
                    LookForLow := false
        if close < low[1]
            LowCounter := 0
            LookForLow := true

        if LookForHigh and close < LowLine.get_y2()
            maxHigh = 0.0
            maxHighIndex = 0
            if HighestArr.size() > 0 
                for [i,v] in HighestArr
                    if i== 0
                        maxHigh := v.HighestHigh
                        maxHighIndex := v.HighestHighIndex
                    else 
                        if v.HighestHigh >  maxHigh
                            maxHigh := v.HighestHigh
                            maxHighIndex := v.HighestHighIndex
            HighLine := line.new(maxHighIndex,maxHigh,bar_index,maxHigh,color = color.orange)
            HighestArr.clear()
            XSuportPassed := XSuportPassed + 1 
            LowLine.set_x2(bar_index)
            LowFixed := false 
            LowestLow := low
            LowestLowIndex := bar_index
            LowLine := line.new(LowestLowIndex,LowestLow,bar_index,LowestLow,color = color.green)
            LookForHigh := false 
            LookForLow := true
            LowCounter := 0
            Onlyone_buy := 0
            HighestHigh := high 
            HighestHighIndex := bar_index
            BuyafterCount += 1
        
        if Res == 0
            if HighestArr.size() > 0 
                for [i,v] in HighestArr
                    if v.HighestHighIndex < LowLine.get_x1()
                        HighestArr.remove(i)
            Res := 1
        h = HighPoint.new(0.0,0)
        h.HighestHigh := high 
        h.HighestHighIndex := bar_index
        array.push(HighestArr,h)
        var NewPos = false 
        var LastSWingLow = 0.0
        var LastSWingLowIndex = 0
        if low[1] < low[2] and low[1] < low 
            LastSWingLow := low[1]
            LastSWingLowIndex := bar_index[1]
        if not na(HighLine) and Onlyone_buy == 0 and BuyafterCount >= OrderAfter and countFailed < StopAfterXFail
            if close > HighLine.get_y2() and close[1] < HighLine.get_y2()
                HighLine.set_x2(bar_index)
                LowLine := line.new(LowestLowIndex,LowestLow,bar_index,LowestLow)
                SlBuy := LowLine.get_y2()
                SlBuyLine := line.new(bar_index-3,SlBuy,bar_index,SlBuy,color = color.red)
                
                if SlMode == "S/R Line"
                    SlBuyLabel := label.new(SlBuyLine.get_x2(), SlBuy, "SL: " + str.tostring(SlBuy)+ " ⌛️", style=label.style_label_left, color=#121203, textcolor=color.white)
                else 
                    SlBuyLabel := label.new(LastSWingLowIndex, LastSWingLow, "SL: " + str.tostring(LowestLow)+ " ⌛️", style=label.style_label_left, color=#121203, textcolor=color.white)
                    SlBuy := LastSWingLow
                TpBuy := HighLine.get_y2() + (rw*math.abs(HighLine.get_y2() - SlBuy))
                alert("BUY")
                TpBuyLine := line.new(bar_index-3,TpBuy,bar_index,TpBuy,color = color.green)
                TpBuyLabel := label.new(TpBuyLine.get_x2(), TpBuy, "TP: " + str.tostring(TpBuy) + " ⌛️", style=label.style_label_left, color=color.green, textcolor=color.white)
                ENtryBuy := label.new(HighLine.get_x2(),HighLine.get_y2(),"Entry: "+str.tostring(HighLine.get_y2()),style = label.style_label_left,color = #4a0000)
                Onlyone_buy := 1
                NewPos := true
            
        if NewPos 
            if high > TpBuyLabel.get_y()
                TpBuyLabel.set_text("TP: " + str.tostring(TpBuy) + " ✅")
                TpBuyLine.set_x2(bar_index)
                TpBuyLabel.set_x(TpBuyLine.get_x2())
                SlBuyLabel.set_text("SL: " + str.tostring(SlBuy)+ " ❌")
                NewPos := false 
            if low < SlBuyLabel.get_y()
                TpBuyLabel.set_text("TP: " + str.tostring(TpBuy) + " ❌")
                SlBuyLabel.set_text("SL: " + str.tostring(SlBuy)+ " 💔")
                NewPos := false 
                countFailed += 1
    else
        var SellAfterCount = 0
        var HighCounter = 0
        var int HighestHighIndexS = bar_index
        var HighestHighS = high
        var LowestLowIndexS = bar_index
        var LowestLowS = high
        var FindHighestS = false
        var LookForHighS = true
        var LookForLowS = false
        var RefLowOfHighS = low
        var MainHighS = high
        var line LowLineS = na
        var line HighLineS = na
        var MainHighIndexS = bar_index
        var XResistPassed = 0
        var Onlyone_sell = 0
        var label EntrySell = na
        var float TpSell = na
        var line TpSellLine = na
        var label TpSellLabel = na
        var float SlSell = na
        var line SlSellLine = na
        var label SlSellLabel = na
        var firstLowLineS = true
        var firstHighLineS = false
        var HighFixedS = false
        var countFailedS = 0

        var ResS = 0
        if high > HighestHighS or na(HighestHighS)
            HighestHighS := high
            HighestHighIndexS := bar_index
            if not na(HighLineS) and HighFixedS == false
                HighLineS.delete()
                HighLineS := line.new(HighestHighIndexS,HighestHighS,bar_index+3,HighestHighS,color = color.red)
                ResS := 0
        if LookForHighS == false
            if close < RefLowOfHighS
                RefLowOfHighS := low
                MainHighIndexS := bar_index
                HighCounter := HighCounter + 1
            if HighCounter == Num
                HighFixedS := true
                HighCounter := 0
                LookForLowS := true
                if na(HighLineS)
                    HighLineS := line.new(HighestHighIndexS,HighestHighS,bar_index,HighestHighS,color = color.red)
                    ResS := 0
        if LookForHighS
            if close < low[1]
                if HighCounter == 0
                    HighCounter := 1
                    RefLowOfHighS := low
                    LookForHighS := false
        if close > high[1]
            HighCounter := 0
            LookForHighS := true

        if LookForLowS and close > HighLineS.get_y2()
            minLow = 0.0
            minLowIndex = 0
            if LowestArr.size() > 0
                for [i,v] in LowestArr
                    if i == 0
                        minLow := v.LowestLow
                        minLowIndex := v.LowestLowIndex
                    else
                        if v.LowestLow < minLow
                            minLow := v.LowestLow
                            minLowIndex := v.LowestLowIndex
            LowLineS := line.new(minLowIndex,minLow,bar_index,minLow,color = color.blue)
            LowestArr.clear()
            XResistPassed := XResistPassed + 1
            HighLineS.set_x2(bar_index)
            HighFixedS := false
            HighestHighS := high
            HighestHighIndexS := bar_index
            HighLineS := line.new(HighestHighIndexS,HighestHighS,bar_index,HighestHighS,color = color.red)
            LookForLowS := false
            LookForHighS := true
            HighCounter := 0
            Onlyone_sell := 0
            LowestLowS := low
            LowestLowIndexS := bar_index
            SellAfterCount += 1

        if ResS == 0
            if LowestArr.size() > 0
                for [i,v] in LowestArr
                    if v.LowestLowIndex < HighLineS.get_x1()
                        LowestArr.remove(i)
            ResS := 1
        lp = LowPoint.new(0.0,0)
        lp.LowestLow := low
        lp.LowestLowIndex := bar_index
        array.push(LowestArr,lp)
        var NewPosS = false
        var LastSWingHighS = 0.0
        var LastSWingHighIndexS = 0
        if high[1] > high[2] and high[1] > high
            LastSWingHighS := high[1]
            LastSWingHighIndexS := bar_index[1]
        if not na(LowLineS) and Onlyone_sell == 0 and SellAfterCount >= OrderAfter and countFailedS < StopAfterXFail
            if close < LowLineS.get_y2() and close[1] > LowLineS.get_y2()
                LowLineS.set_x2(bar_index)
                HighLineS := line.new(HighestHighIndexS,HighestHighS,bar_index,HighestHighS)
                SlSell := HighLineS.get_y2()
                SlSellLine := line.new(bar_index-3,SlSell,bar_index,SlSell,color = color.red)

                if SlMode == "S/R Line"
                    SlSellLabel := label.new(SlSellLine.get_x2(), SlSell, "SL: " + str.tostring(SlSell)+ " ⌛️", style=label.style_label_left, color=#121203, textcolor=color.white)
                else
                    SlSellLabel := label.new(LastSWingHighIndexS, LastSWingHighS, "SL: " + str.tostring(HighestHighS)+ " ⌛️", style=label.style_label_left, color=#121203, textcolor=color.white)
                    SlSell := LastSWingHighS
                TpSell := LowLineS.get_y2() - (rw*math.abs(SlSell - LowLineS.get_y2()))
                alert("SELL")
                TpSellLine := line.new(bar_index-3,TpSell,bar_index,TpSell,color = color.green)
                TpSellLabel := label.new(TpSellLine.get_x2(), TpSell, "TP: " + str.tostring(TpSell) + " ⌛️", style=label.style_label_left, color=color.green, textcolor=color.white)
                EntrySell := label.new(LowLineS.get_x2(),LowLineS.get_y2(),"Entry: "+str.tostring(LowLineS.get_y2()),style = label.style_label_left,color = #4a0000)
                Onlyone_sell := 1
                NewPosS := true

        if NewPosS
            if low < TpSellLabel.get_y()
                TpSellLabel.set_text("TP: " + str.tostring(TpSell) + " ✅")
                TpSellLine.set_x2(bar_index)
                TpSellLabel.set_x(TpSellLine.get_x2())
                SlSellLabel.set_text("SL: " + str.tostring(SlSell)+ " ❌")
                NewPosS := false
            if high > SlSellLabel.get_y()
                TpSellLabel.set_text("TP: " + str.tostring(TpSell) + " ❌")
                SlSellLabel.set_text("SL: " + str.tostring(SlSell)+ " 💔")
                NewPosS := false
                countFailedS += 1
````
