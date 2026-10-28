# TWB 5.30 Setup-Binod Rawani

- url: https://www.tradingview.com/script/fuCMS8ZW-TWB-5-30-Setup-Binod-Rawani/
- type: indicator
- pine_id: PUB;cdbd69f86a8b4a39a05c461be956d9b0
- version: 1.0

## Description

TWB 5.30 Setup is a non-repainting intraday breakout and retracement indicator designed for 5-minute charts. It uses the High and Low of the 5:30 AM IST (1-Hour) candle as the day's key reference levels and automatically plots Fibonacci-based entry, stop-loss, and target zones.

The indicator waits for the first valid breakout above or below the 5:30 candle range, then looks for a retracement to predefined Fibonacci levels before generating a trade signal. It supports one trade per day, includes 1:2 risk-reward target calculation, visual trade management zones, and alert conditions for setup activation, entries, targets, and stop-loss events.

Key Features:
• Uses 5:30 AM IST 1-Hour candle High/Low
• Automatic Fibonacci entry and stop-loss levels
• First breakout only logic
• Retracement-based trade entries
• Fixed 1:2 Risk-Reward targets
• One trade per day restriction
• Non-repainting calculations
• Complete alert support
• Visual Long/Short position style display

## Source Code

````pine
//@version=6
indicator("TWB 5.30 Setup", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

//==================================================================================================
// TWB 5.30 Setup
// Timeframe: Designed for 5 Minute Chart
// Reference Candle: 1 Hour candle starting at 05:30 AM IST
// Timezone: Asia/Kolkata
// No Repainting
//==================================================================================================

//--------------------------------------------------------------------------------------------------
// CONSTANTS
//--------------------------------------------------------------------------------------------------
string TZ = "Asia/Kolkata"

//--------------------------------------------------------------------------------------------------
// DAILY RESET DETECTION
//--------------------------------------------------------------------------------------------------
currDay = dayofmonth(time, TZ)
newDay  = ta.change(currDay) != 0

//--------------------------------------------------------------------------------------------------
// PERSISTENT VARIABLES
//--------------------------------------------------------------------------------------------------
var float setupHigh = na
var float setupLow  = na
var bool setupCaptured = false

// Breakout State
var bool buySetupActivated  = false
var bool sellSetupActivated = false
var bool breakoutLocked     = false

// Trade State
var bool tradeTaken = false

// Entry Levels
var float buyEntry  = na
var float buySL     = na
var float buyTP     = na

var float sellEntry = na
var float sellSL    = na
var float sellTP    = na

// Active Trade Tracking
var bool activeLong  = false
var bool activeShort = false

// Alerts
var bool buySetupAlert  = false
var bool sellSetupAlert = false
var bool buyEntryAlert  = false
var bool sellEntryAlert = false
var bool targetHitAlert = false
var bool stopHitAlert   = false

// Drawing Objects
var line highLine    = na
var line lowLine     = na
var line fib0Line    = na
var line fib025Line  = na
var line fib075Line  = na
var line fib1Line    = na

var line entryLine   = na
var line slLine      = na
var line tpLine      = na
var box  tradeBox    = na

//--------------------------------------------------------------------------------------------------
// RESET AT NEW DAY
//--------------------------------------------------------------------------------------------------
if newDay
    setupHigh := na
    setupLow := na
    setupCaptured := false

    buySetupActivated := false
    sellSetupActivated := false
    breakoutLocked := false

    tradeTaken := false

    activeLong := false
    activeShort := false

    buyEntry := na
    buySL := na
    buyTP := na

    sellEntry := na
    sellSL := na
    sellTP := na

    line.delete(highLine)
    line.delete(lowLine)
    line.delete(fib0Line)
    line.delete(fib025Line)
    line.delete(fib075Line)
    line.delete(fib1Line)

    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tpLine)

    box.delete(tradeBox)

    highLine := na
    lowLine := na
    fib0Line := na
    fib025Line := na
    fib075Line := na
    fib1Line := na

    entryLine := na
    slLine := na
    tpLine := na
    tradeBox := na

//--------------------------------------------------------------------------------------------------
// GET 1H DATA
// Capture ONLY the candle that STARTS at 05:30 IST
//--------------------------------------------------------------------------------------------------
refHour  = request.security(
     syminfo.tickerid,
     "60",
     hour(time, TZ),
     lookahead = barmerge.lookahead_off)

refMin = request.security(
     syminfo.tickerid,
     "60",
     minute(time, TZ),
     lookahead = barmerge.lookahead_off)

refHigh = request.security(
     syminfo.tickerid,
     "60",
     high,
     lookahead = barmerge.lookahead_off)

refLow = request.security(
     syminfo.tickerid,
     "60",
     low,
     lookahead = barmerge.lookahead_off)

// Capture only after the 05:30 candle is fully closed
captureCondition = not setupCaptured and refHour == 5 and refMin == 30

if captureCondition
    setupHigh := refHigh
    setupLow  := refLow
    setupCaptured := true

//--------------------------------------------------------------------------------------------------
// FIBONACCI LEVELS
//--------------------------------------------------------------------------------------------------
rangeVal = setupHigh - setupLow

fibBuy0    = setupHigh
fibBuy025  = setupHigh - (rangeVal * 0.25)
fibBuy075  = setupHigh - (rangeVal * 0.75)
fibBuy1    = setupLow

// SELL FIB
fibSell0   = setupHigh
fibSell025 = setupHigh - (rangeVal * 0.25)
fibSell075 = setupHigh - (rangeVal * 0.75)
fibSell1   = setupLow

//--------------------------------------------------------------------------------------------------
// DRAW DAILY LEVELS
//--------------------------------------------------------------------------------------------------
if setupCaptured and na(highLine)
    highLine := line.new(bar_index, setupHigh, bar_index + 1, setupHigh, extend=extend.right, color=color.green, width=2)
    lowLine  := line.new(bar_index, setupLow,  bar_index + 1, setupLow,  extend=extend.right, color=color.red, width=2)

    fib0Line   := line.new(bar_index, fibBuy0,   bar_index + 1, fibBuy0,   extend=extend.right, color=color.blue)
    fib025Line := line.new(bar_index, fibBuy025, bar_index + 1, fibBuy025, extend=extend.right, color=color.orange)
    fib075Line := line.new(bar_index, fibBuy075, bar_index + 1, fibBuy075, extend=extend.right, color=color.orange)
    fib1Line   := line.new(bar_index, fibBuy1,   bar_index + 1, fibBuy1,   extend=extend.right, color=color.blue)

//--------------------------------------------------------------------------------------------------
// BREAKOUT LOGIC
// Only first breakout of the day
//--------------------------------------------------------------------------------------------------
buySetupAlert := false
sellSetupAlert := false
buyEntryAlert := false
sellEntryAlert := false
targetHitAlert := false
stopHitAlert := false

if setupCaptured and not breakoutLocked and not tradeTaken

    if close > setupHigh
        buySetupActivated := true
        sellSetupActivated := false
        breakoutLocked := true
        buySetupAlert := true

    else if close < setupLow
        sellSetupActivated := true
        buySetupActivated := false
        breakoutLocked := true
        sellSetupAlert := true

//--------------------------------------------------------------------------------------------------
// BUY ENTRY
// Touch Fib 0.25 + Bullish Candle
//--------------------------------------------------------------------------------------------------
buyTouch = low <= fibBuy025

buyEntryCondition =
     buySetupActivated and
     not tradeTaken and
     buyTouch and
     close > open

if buyEntryCondition

    tradeTaken := true
    activeLong := true

    buyEntry := fibBuy025
    buySL    := fibBuy075

    risk = math.abs(buyEntry - buySL)
    buyTP := buyEntry + (risk * 2.0)

    buyEntryAlert := true

    label.new(
         bar_index,
         low,
         "BUY",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white)

    label.new(bar_index, buyEntry, "Entry\n" + str.tostring(buyEntry, format.mintick))
    label.new(bar_index, buySL, "SL\n" + str.tostring(buySL, format.mintick))
    label.new(bar_index, buyTP, "TP\n" + str.tostring(buyTP, format.mintick))

    entryLine := line.new(bar_index, buyEntry, bar_index + 50, buyEntry, color=color.green, width=2)
    slLine    := line.new(bar_index, buySL, bar_index + 50, buySL, color=color.red, width=2)
    tpLine    := line.new(bar_index, buyTP, bar_index + 50, buyTP, color=color.blue, width=2)

    tradeBox := box.new(
         left=bar_index,
         top=buyTP,
         right=bar_index + 50,
         bottom=buySL,
         bgcolor=color.new(color.green, 90),
         border_color=color.green)

//--------------------------------------------------------------------------------------------------
// SELL ENTRY
// Touch Fib 0.75 + Bearish Candle
//--------------------------------------------------------------------------------------------------
sellTouch = high >= fibSell075

sellEntryCondition =
     sellSetupActivated and
     not tradeTaken and
     sellTouch and
     close < open

if sellEntryCondition

    tradeTaken := true
    activeShort := true

    sellEntry := fibSell075
    sellSL    := fibSell025

    risk = math.abs(sellSL - sellEntry)
    sellTP := sellEntry - (risk * 2.0)

    sellEntryAlert := true

    label.new(
         bar_index,
         high,
         "SELL",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white)

    label.new(bar_index, sellEntry, "Entry\n" + str.tostring(sellEntry, format.mintick))
    label.new(bar_index, sellSL, "SL\n" + str.tostring(sellSL, format.mintick))
    label.new(bar_index, sellTP, "TP\n" + str.tostring(sellTP, format.mintick))

    entryLine := line.new(bar_index, sellEntry, bar_index + 50, sellEntry, color=color.red, width=2)
    slLine    := line.new(bar_index, sellSL, bar_index + 50, sellSL, color=color.orange, width=2)
    tpLine    := line.new(bar_index, sellTP, bar_index + 50, sellTP, color=color.blue, width=2)

    tradeBox := box.new(
         left=bar_index,
         top=sellSL,
         right=bar_index + 50,
         bottom=sellTP,
         bgcolor=color.new(color.red, 90),
         border_color=color.red)

//--------------------------------------------------------------------------------------------------
// TARGET / STOPLOSS MONITORING
//--------------------------------------------------------------------------------------------------
if activeLong

    if high >= buyTP
        targetHitAlert := true
        activeLong := false

    else if low <= buySL
        stopHitAlert := true
        activeLong := false

if activeShort

    if low <= sellTP
        targetHitAlert := true
        activeShort := false

    else if high >= sellSL
        stopHitAlert := true
        activeShort := false

//--------------------------------------------------------------------------------------------------
// PLOTS
//--------------------------------------------------------------------------------------------------
plot(setupCaptured ? setupHigh : na, "5:30 High", color=color.green, linewidth=2)
plot(setupCaptured ? setupLow  : na, "5:30 Low", color=color.red, linewidth=2)

plot(setupCaptured ? fibBuy0   : na, "Fib 0", color=color.blue)
plot(setupCaptured ? fibBuy025 : na, "Fib 0.25", color=color.orange)
plot(setupCaptured ? fibBuy075 : na, "Fib 0.75", color=color.orange)
plot(setupCaptured ? fibBuy1   : na, "Fib 1", color=color.blue)

//--------------------------------------------------------------------------------------------------
// ALERTS
//--------------------------------------------------------------------------------------------------
alertcondition(buySetupAlert,  "BUY Setup Activated",  "BUY Setup Activated")
alertcondition(sellSetupAlert, "SELL Setup Activated", "SELL Setup Activated")

alertcondition(buyEntryAlert,  "BUY Entry",  "BUY Entry Triggered")
alertcondition(sellEntryAlert, "SELL Entry", "SELL Entry Triggered")

alertcondition(targetHitAlert, "Target Hit", "Target Hit")
alertcondition(stopHitAlert,   "Stoploss Hit", "Stoploss Hit")
````
