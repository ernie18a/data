# gobucs1314 indicator

- url: https://www.tradingview.com/script/HJl4b1k7-gobucs1314-indicator/
- type: indicator
- pine_id: PUB;5285495b36064f1a953f00f485c13d20
- version: 3.0

## Description

Here's the order execution logic from gobucs the 🐐! Gobucs1314 is an elliot wave trader and top analyst in the webull community. 
Basic logic
•	The indicator is for order execution / confirmation, not for regime detection or beta work (user must handle that separately).
•	It watches EMA 9, EMA 21, and VWAP.
•	A LONG signal prints only when, on the same bar:
1.	Price is above VWAP,
2.	Price is above the 9 EMA,
3.	The 9 EMA crosses above the 21 EMA.
•	A SHORT signal prints only when, on the same bar:
1.	Price is below VWAP,
2.	Price is below the 9 EMA,
3.	The 9 EMA crosses below the 21 EMA.
All three must be true; otherwise no signal

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Wild_Will_Stewart
//@version=6
indicator("gobucs1314 indicator", overlay = true)

//--------------------------------------------------------------------
// High‑level notes:
//
// - Basic indicator for order execution / signal confirmation
// - NOT a complete system: user must do market regime and beta analysis
// - Timeframe guidance from gobucs1314:
//     • Works on any intraday TF
//     • Common use: trade on 1‑minute and use 5‑minute for confirmation
//--------------------------------------------------------------------

//========================
// Inputs
//========================
showVWAP    = input.bool(true,  "Show VWAP")
showExits   = input.bool(false, "Show Exit Signals / Alerts")  // default OFF
emaLenFast  = input.int(9,   "Fast EMA Length", minval = 1)
emaLenSlow  = input.int(21,  "Slow EMA Length", minval = 1)

//========================
// Core series: EMAs + VWAP
//========================
ema9      = ta.ema(close, emaLenFast)
ema21     = ta.ema(close, emaLenSlow)
vwapValue = ta.vwap(hlc3)

// One‑bar cross detection
bullCross = ta.crossover(ema9, ema21)
bearCross = ta.crossunder(ema9, ema21)

//========================
// Persistent cross regimes
//========================
var bool bullCrossed = false
var bool bearCrossed = false

if barstate.isconfirmed
    if bullCross
        bullCrossed := true
        bearCrossed := false
    else if bearCross
        bearCrossed := true
        bullCrossed := false

//========================
// Regime for clouds (independent of trades)
//========================
bullishRegime = close > vwapValue and ema9 > ema21
bearishRegime = close < vwapValue and ema9 < ema21

//========================
// Raw entry *conditions* (using persistent cross regime)
//========================
// LONG condition: bullish cross regime + price above VWAP + price above 9 EMA
longCond  = bullCrossed  and close > vwapValue and close > ema9

// SHORT condition: bearish cross regime + price below VWAP + price below 9 EMA
shortCond = bearCrossed and close < vwapValue and close < ema9

//========================
// Position state
//========================
var bool inLong   = false
var bool inShort  = false
var bool wasLong  = false
var bool wasShort = false

// lastSide: 0 = none yet, +1 = last completed trade was long, -1 = last completed trade was short
var int  lastSide = 0

// Save previous bar state
if barstate.isnew
    wasLong  := inLong
    wasShort := inShort

//========================
// Exit logic (always calculated)
//========================
// Exit long when:
// - inLong
// - EITHER price loses VWAP
// - OR (price < EMA9 AND bearish cross happens)
rawExitLong =    inLong and (
        close < vwapValue or
        (close < ema9 and bearCross)
    )

// Exit short when:
// - inShort
// - EITHER price regains VWAP
// - OR (price > EMA9 AND bullish cross happens)
rawExitShort =    inShort and (
        close > vwapValue or
        (close > ema9 and bullCross)
    )

exitLong  = rawExitLong
exitShort = rawExitShort

//========================
// Entry logic with mode‑dependent gating
//========================

// Base requirement: previous bar flat
flatPrev = not wasLong and not wasShort

// When exits are ON → allow every valid LONG/SHORT after an exit
enterLong_full  = longCond  and flatPrev
enterShort_full = shortCond and flatPrev

// When exits are OFF (quiet mode) → require full opposite‑side trade before same‑side re‑entry
canLongSideQuiet  = lastSide != +1   // last completed trade was NOT long
canShortSideQuiet = lastSide != -1   // last completed trade was NOT short

enterLong_quiet  = longCond  and flatPrev and canLongSideQuiet
enterShort_quiet = shortCond and flatPrev and canShortSideQuiet

// Select which entry logic to use based on showExits
enterLong  = showExits ? enterLong_full  : enterLong_quiet
enterShort = showExits ? enterShort_full : enterShort_quiet

//========================
// State machine – confirmed bar
//========================
if barstate.isconfirmed
    // Entries
    if enterLong
        inLong  := true
        inShort := false

    else if enterShort
        inShort := true
        inLong  := false

    // Exits (always update state & lastSide)
    else if exitLong
        inLong   := false
        lastSide := +1  // completed long cycle

    else if exitShort
        inShort  := false
        lastSide := -1  // completed short cycle

//========================
// VWAP
//========================
plot(showVWAP ? vwapValue : na, title = "VWAP",
     color = color.new(#2962FF, 0), linewidth = 2)

//========================
// EMA 9/21: base pair + regime clouds
//========================
// Base EMAs (thin, always visible)
plot(ema9,  title = "EMA 9 Base",  color = color.new(color.gray, 60), linewidth = 1)
plot(ema21, title = "EMA 21 Base", color = color.new(color.gray, 40), linewidth = 1)

// Bullish cloud (green) – based on bullishRegime
bullCloudColor = color.new(color.lime, 60)
ema9Bull       = bullishRegime ? ema9  : na
ema21Bull      = bullishRegime ? ema21 : na
ema9BullPlot   = plot(ema9Bull,  title = "EMA 9 Bullish Cloud",  color = na, linewidth = 1)
ema21BullPlot  = plot(ema21Bull, title = "EMA 21 Bullish Cloud", color = na, linewidth = 1)
fill(ema9BullPlot, ema21BullPlot, color = bullCloudColor)

// Bearish cloud (red) – based on bearishRegime
bearCloudColor = color.new(color.red, 60)
ema9Bear       = bearishRegime ? ema9  : na
ema21Bear      = bearishRegime ? ema21 : na
ema9BearPlot   = plot(ema9Bear,  title = "EMA 9 Bearish Cloud",  color = na, linewidth = 1)
ema21BearPlot  = plot(ema21Bear, title = "EMA 21 Bearish Cloud", color = na, linewidth = 1)
fill(ema9BearPlot, ema21BearPlot, color = bearCloudColor)

//========================
// Signal markers
//========================
plotshape(enterLong,  title = "Enter Long",
          location = location.belowbar, style = shape.triangleup,
          size = size.small, color = color.new(color.lime, 0), text = "LONG")

plotshape(enterShort, title = "Enter Short",
          location = location.abovebar, style = shape.triangledown,
          size = size.small, color = color.new(color.red, 0), text = "SHORT")

plotshape(showExits and exitLong,  title = "Exit Long",
          location = location.belowbar, style = shape.triangleup,
          size = size.tiny, color = color.new(color.yellow, 0), text = "XL")

plotshape(showExits and exitShort, title = "Exit Short",
          location = location.abovebar, style = shape.triangledown,
          size = size.tiny, color = color.new(color.orange, 0), text = "XS")

//========================
// Alerts – respect exit toggle
//========================
alertcondition(
     enterLong,
     "gobucs1314 ENTER LONG",
     "ENTER LONG: Bullish cross regime, Price > VWAP, Price > 9 EMA"
)

alertcondition(
     showExits and exitLong,
     "gobucs1314 EXIT LONG",
     "EXIT LONG: Price < VWAP OR (price < 9 EMA AND bearish cross)"
)

alertcondition(
     enterShort,
     "gobucs1314 ENTER SHORT",
     "ENTER SHORT: Bearish cross regime, Price < VWAP, Price < 9 EMA"
)

alertcondition(
     showExits and exitShort,
     "gobucs1314 EXIT SHORT",
     "EXIT SHORT: Price > VWAP OR (price > 9 EMA AND bullish cross)"
)
````
