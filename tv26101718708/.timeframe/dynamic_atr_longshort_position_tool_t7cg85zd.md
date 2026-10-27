# Dynamic ATR Long/Short Position Tool

- url: https://www.tradingview.com/script/t7Cg85ZD-Dynamic-ATR-Long-Short-Position-Tool/
- type: indicator
- pine_id: PUB;4a583fcd84f9464d8cb8d582510f2abd
- version: 1.0

## Description

This indicator provides a dynamic visual (R/R) projection that enables operators to systematically formulate their risk management setups. By anchoring the tool to any specific chart candle, it automatically renders take-profit and stop-loss zones tied directly to objective market volatility. 

Rather than relying on arbitrary, fixed price levels, the script mathematically calibrates the stop-loss distance using the (ATR), ensuring parameters adapt accurately to changing market variance.

Key Mechanics:

- ATR-Based Risk: Stop loss is dynamically calculated using a user-defined ATR multiple (Wilder's RMA) from the anchored candle.

- Ratio-Based Reward: Take profit is strictly projected using a defined Risk/Reward ratio against the initial ATR risk distance.

- Auto-Directional Logic: Position direction can be manually set to Long/Short or set to "Auto," which determines the direction based on the anchored candle's polarity (Bullish = Long, Bearish = Short).

- Multi-Timeframe Integration: Allows extraction of higher timeframe ATR values to inform lower timeframe position structures.

## Source Code

````pine
//@version=6
indicator("Dynamic ATR Long/Short Position Tool", shorttitle="ATR Pos Tool", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =======================================================================================================
// 1. USER INPUTS & CONFIGURATION
// =======================================================================================================
groupInteractive = "1. Chart Click & Anchor Selection"
selectedTime     = input.time(0, "Anchor Bar", confirm=true, inline="anchor", tooltip="Click any bar on the chart to anchor the calculation. Hardcoded to anchor at bar close.")

groupTrade       = "2. Position & ATR Configuration"
posType          = input.string("Auto", "Position Direction", options=["Auto", "Long", "Short"], tooltip="Select Long, Short, or Auto. In Auto mode, direction is derived from the anchored candle's polarity (Bullish = Long, Bearish = Short).", group=groupTrade)
slAtrMult        = input.float(1.5, "Stop Loss (ATR Multiple)", minval=0.1, step=0.25, tooltip="Stop loss distance in ATR multiples.", group=groupTrade)
tpRrRatio        = input.float(3.0, "Take Profit (RR Multiple)", minval=0.1, step=0.25, tooltip="Take profit target relative to initial risk distance.", group=groupTrade)
atrTfOption      = input.string("Chart", "ATR Timeframe", options=["Chart", "5 Minutes", "15 Minutes", "1 Hour", "2 Hours", "4 Hours", "8 Hours", "1 Day", "1 Week"], tooltip="Select ATR timeframe. Excludes ticks, seconds, months, 1m, 3m, 30m, 45m, and 3h.", group=groupTrade)
atrLength        = input.int(14, "ATR Period", minval=1, tooltip="Lookback period for Wilder's RMA ATR.", group=groupTrade)

groupVisual      = "3. Visual Appearance & Box Styling"
boxWidthBars     = input.int(30, "Projection Width (Bars)", minval=1, maxval=500, tooltip="Horizontal length of the projection boxes in number of bars.", group=groupVisual)
longTpColor      = input.color(color.new(#089981, 78), "Long TP Zone Color", group=groupVisual)
longSlColor      = input.color(color.new(#f23645, 78), "Long SL Zone Color", group=groupVisual)
shortTpColor     = input.color(color.new(#089981, 78), "Short TP Zone Color", group=groupVisual)
shortSlColor     = input.color(color.new(#f23645, 78), "Short SL Zone Color", group=groupVisual)
entryLineColor   = input.color(color.new(#787b86, 0), "Entry Line Color", group=groupVisual)

// =======================================================================================================
// 2. MATHEMATICAL CALCULATION ENGINE (DEFAULT WILDER'S RMA ATR)
// =======================================================================================================
// ATR must calculate continuously on every bar to maintain accurate smoothing state
chartAtr = ta.rma(ta.tr(true), atrLength)

// Resolve HTF ATR resolution string
atrTfResolution = switch atrTfOption
    "5 Minutes"  => "5"
    "15 Minutes" => "15"
    "1 Hour"     => "60"
    "2 Hours"    => "120"
    "4 Hours"    => "240"
    "8 Hours"    => "480"
    "1 Day"      => "1D"
    "1 Week"     => "1W"
    => ""

currentAtr = atrTfResolution != "" ? request.security(syminfo.tickerid, atrTfResolution, ta.rma(ta.tr(true), atrLength), gaps=barmerge.gaps_off) : chartAtr

// =======================================================================================================
// 3. ANCHOR RESOLUTION & RISK DERIVATION
// =======================================================================================================
// Persistent anchor metrics
var int   anchorBarIndex  = na
var float entryPrice      = na
var float stopLossPrice   = na
var float takeProfitPrice = na
var bool  isLongPosition  = true

// Identify the clicked bar
bool isSelectedBar = false
if selectedTime > 0
    isSelectedBar := (time <= selectedTime and time_close > selectedTime) or (time == selectedTime)
else
    isSelectedBar := (bar_index == math.max(0, last_bar_index - 30))

if isSelectedBar
    anchorBarIndex := bar_index
    entryPrice     := close // Hardcoded to Bar Close
    isLongPosition := posType == "Auto" ? (close >= open) : (posType == "Long")
    
    // Calculate Risk/Reward strictly once upon anchoring to eliminate redundant per-bar recalculations
    float riskDistance   = slAtrMult * currentAtr
    float rewardDistance = tpRrRatio * riskDistance
    
    stopLossPrice   := isLongPosition ? (entryPrice - riskDistance) : (entryPrice + riskDistance)
    takeProfitPrice := isLongPosition ? (entryPrice + rewardDistance) : (entryPrice - rewardDistance)

// =======================================================================================================
// 4. DRAWING OBJECTS RENDERING (CLEAN SOLID VISUALS)
// =======================================================================================================
var box  tpBox        = box.new(na, na, na, na, xloc=xloc.bar_index, border_color=color.new(color.gray, 100))
var box  slBox        = box.new(na, na, na, na, xloc=xloc.bar_index, border_color=color.new(color.gray, 100))
var line entryLineObj = line.new(na, na, na, na, xloc=xloc.bar_index, style=line.style_solid, width=1)

if barstate.islast and not na(anchorBarIndex)
    int rightEdge = anchorBarIndex + boxWidthBars
    
    // Set dynamically derived colors
    box.set_bgcolor(tpBox, isLongPosition ? longTpColor : shortTpColor)
    box.set_bgcolor(slBox, isLongPosition ? longSlColor : shortSlColor)
    line.set_color(entryLineObj, entryLineColor)

    // Render Take Profit Box
    box.set_left(tpBox, anchorBarIndex)
    box.set_right(tpBox, rightEdge)
    box.set_top(tpBox, isLongPosition ? takeProfitPrice : entryPrice)
    box.set_bottom(tpBox, isLongPosition ? entryPrice : takeProfitPrice)
    
    // Render Stop Loss Box
    box.set_left(slBox, anchorBarIndex)
    box.set_right(slBox, rightEdge)
    box.set_top(slBox, isLongPosition ? entryPrice : stopLossPrice)
    box.set_bottom(slBox, isLongPosition ? stopLossPrice : entryPrice)

    // Render Central Entry Separator Line
    line.set_xy1(entryLineObj, anchorBarIndex, entryPrice)
    line.set_xy2(entryLineObj, rightEdge, entryPrice)
````
