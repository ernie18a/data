# My VWAP Reversal + Pivot Points Standard

- url: https://www.tradingview.com/script/Sl8Kr0lk-My-VWAP-Reversal-Pivot-Points-Standard/
- type: indicator
- pine_id: PUB;uIN1sdqjyYRQk66PhY5pmT0DWg25FVqD
- version: 1.0

## Description

This indicator, with the addition of a standard VWAP indicator to the 5m chart, helps the operator when using a closing candle Price to initiate a VWAP Reversal strategy.

The strategy involves Price gapping up, look for a Close below the 1st 5m candle Low; else look for a Close above the 1st 5m candle High. On a break of VWAP, take the trade in the opposite direction of the gap, hence the VWAP Reversal. Not my own strat, credit to T3 Newsbeat, publicly posted on YouTube.

The Pivot Points Standard in the Pine 4 user manual, was the base source code, and leaving it here will allow me to remove the PP indicator I was using.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mikeram1971
// Add VWAP to the 5m chart and use a closing candle Price to initiate a VWAP Reversal strategy.
// Price gapping up, look for a Close below the 1st 5m candle Low; else look for a Close above the 1st 5m candle High.
// The Pivot Points Standard was the base source code, and leaving it here will allow me to remove the PP indicator I was using.

//@version=4
study("My VWAP Reversal + Pivot Points Standard", overlay=true)
higherTF = input("D", type=input.resolution)
prevCloseHTF = security(syminfo.tickerid, higherTF, close[1], lookahead=true)
prevOpenHTF = security(syminfo.tickerid, higherTF, open[1], lookahead=true)
prevHighHTF = security(syminfo.tickerid, higherTF, high[1], lookahead=true)
prevLowHTF = security(syminfo.tickerid, higherTF, low[1], lookahead=true)

pLevel = (prevHighHTF + prevLowHTF + prevCloseHTF) / 3
//r1Level = pLevel * 2 - prevLowHTF
//s1Level = pLevel * 2 - prevHighHTF

//var line r1Line = na
var line pLine = na
var label pLabel = na
//var line s1Line = na

var float open_price = na
var float high_price = na
var float low_price = na
var float gap_up = na

var label lHigh = na
var label lLow = na
var line PriceLine = na

if pLevel[1] != pLevel
//    line.set_x2(r1Line, bar_index)
    line.set_x2(pLine, bar_index)
//    line.set_x2(s1Line, bar_index)
//    line.set_extend(r1Line, extend.none)
    line.set_extend(pLine, extend.none)
//    line.set_extend(s1Line, extend.none)
//    r1Line := line.new(bar_index, r1Level, bar_index, r1Level, extend=extend.right)
    pLine := line.new(bar_index, pLevel, bar_index, pLevel, color=color.orange, width=3, extend=extend.right)
//    s1Line := line.new(bar_index, s1Level, bar_index, s1Level, extend=extend.right)
//    label.new(bar_index, r1Level, "R1", style=label.style_none)
    pLabel := label.new(bar_index, pLevel, "P", style=label.style_none)
//    label.new(bar_index, s1Level, "S1", style=label.style_none)
    label.delete(pLabel[1])
    line.delete(pLine[1])
    open_price := open
    high_price := high
    low_price := low
    gap_up := open > close [1] ? 1 : 0
    lLow := label.new(bar_index, low, tostring(low), style=label.style_label_up, yloc=yloc.belowbar, color=color.red)
    label.delete(lLow[1])
    lHigh := label.new(bar_index, high, tostring(high), style=label.style_label_down, yloc=yloc.abovebar, color=color.lime)
    label.delete(lHigh[1])
    label.delete(gap_up ? lHigh : lLow)
    PriceLine := line.new(bar_index, gap_up ? low_price : high_price, bar_index, gap_up ? low_price : high_price, color=gap_up ? color.red : color.black, style=line.style_dashed, width=2, extend=extend.right)
    line.delete(PriceLine[1])

if not na(pLine) and line.get_x2(pLine) != bar_index
//    line.set_x2(r1Line, bar_index)
    line.set_x2(pLine, bar_index)
    line.set_x2(PriceLine, bar_index)
//    line.set_x2(s1Line, bar_index)
// END
````
