# Trend-Health Filter (Traffic Light)

- url: https://www.tradingview.com/script/CvfJDS3t-Trend-Health-Filter-Traffic-Light/
- type: indicator
- pine_id: PUB;4fce19b25a2b4c5b8147258e24f7f99c
- version: 1.0

## Description

This indicator will help to know the breakout health

## Source Code

````pine
//@version=5
indicator("Trend-Health Filter (Traffic Light)", overlay=true)

// ==========================================
// 1. INPUTS
// ==========================================
adxLen      = input.int(14, "ADX Length", minval=1)
adxThresh   = input.int(20, "ADX Threshold", minval=1)
emaLen      = input.int(20, "EMA Length", minval=1)
slopeThresh = input.float(0.0005, "EMA Slope Threshold", step=0.0001, tooltip="Minimum price change per bar to consider EMA 'angled'")
bbLen       = input.int(20, "BB Length", minval=1)
bbMult      = input.float(2.0, "BB StdDev", step=0.1)
showTable   = input.bool(true, "Show Status Dashboard")

// ==========================================
// 2. CALCULATIONS
// ==========================================

// --- ADX Energy Check ---
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
adxRising = adxVal > adxVal[1]
adxGreen  = adxVal > adxThresh and adxRising

// --- EMA Slope/Angle ---
emaVal = ta.ema(close, emaLen)
emaSlope = (emaVal - emaVal[1]) / emaVal[1] // Normalized slope
emaAngledUp = emaSlope > slopeThresh
emaAngledDn = emaSlope < -slopeThresh

// --- Volatility Squeeze (BB Width) ---
[basis, upper, lower] = ta.bb(close, bbLen, bbMult)
bbWidth = (upper - lower) / basis
isSqueeze = bbWidth == ta.lowest(bbWidth, 20)

// --- Price Context ---
aboveEMA = close > emaVal
belowEMA = close < emaVal

// ==========================================
// 3. BINARY TRADE ZONE LOGIC
// ==========================================

// GREEN ZONE: Price above EMA + ADX strong/rising + EMA angled up + No Squeeze
isGreenZone = aboveEMA and adxGreen and emaAngledUp and not isSqueeze

// RED ZONE (Chop): ADX weak/falling OR Price crossing EMA OR Squeeze
// We use Gray for Squeeze/Neutral and Red for general "Do Not Trade" chop
isNeutral = isSqueeze or (adxVal < adxThresh)
isRedZone = not isGreenZone and not isNeutral

// ==========================================
// 4. VISUALS & BACKGROUND
// ==========================================

// Background coloring
bgColor = isGreenZone ? color.new(color.green, 85) : 
          isNeutral   ? color.new(color.gray, 85)  : 
          color.new(color.red, 85)

bgcolor(bgColor)

// EMA Plot
plot(emaVal, "EMA 20", color=emaAngledUp ? color.green : emaAngledDn ? color.red : color.gray, linewidth=2)

// Labels
if barstate.islast
    if adxVal < adxThresh
        label.new(bar_index, high, "DO NOT TRADE: Low Energy", yloc=yloc.abovebar, color=color.red, textcolor=color.white, style=label.style_label_down)
    else if isSqueeze
        label.new(bar_index, high, "VOLATILITY SQUEEZE", yloc=yloc.abovebar, color=color.gray, textcolor=color.white, style=label.style_label_down)

// ==========================================
// 5. STATUS DASHBOARD
// ==========================================
var table statusTable = table.new(position.top_right, 2, 4, border_width=1)
if showTable and barstate.islast
    table.cell(statusTable, 0, 0, "Filter", bgcolor=color.gray, text_color=color.white)
    table.cell(statusTable, 1, 0, "Status", bgcolor=color.gray, text_color=color.white)
    
    // ADX Row
    table.cell(statusTable, 0, 1, "ADX (" + str.tostring(adxVal, "#.#") + ")", text_color=color.white)
    table.cell(statusTable, 1, 1, adxGreen ? "STRONG" : "WEAK", bgcolor=adxGreen ? color.green : color.red)
    
    // EMA Row
    table.cell(statusTable, 0, 2, "EMA Slope", text_color=color.white)
    table.cell(statusTable, 1, 2, emaAngledUp ? "UP" : emaAngledDn ? "DOWN" : "FLAT", bgcolor=emaAngledUp ? color.green : emaAngledDn ? color.red : color.gray)
    
    // Volatility Row
    table.cell(statusTable, 0, 3, "Volatility", text_color=color.white)
    table.cell(statusTable, 1, 3, isSqueeze ? "SQUEEZE" : "NORMAL", bgcolor=isSqueeze ? color.orange : color.blue)

// ==========================================
// 6. ALERTS
// ==========================================
alertcondition(isGreenZone and not isGreenZone[1], "Enter Green Zone", "Trend became tradeable (Green Light)")
alertcondition((isRedZone or isNeutral) and isGreenZone[1], "Enter Red/Gray Zone", "Trend lost momentum or squeeze detected (Stop Trading)")
````
