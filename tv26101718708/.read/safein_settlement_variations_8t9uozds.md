# SafeIN - Settlement & Variations

- url: https://www.tradingview.com/script/8T9uozdS/
- type: indicator
- pine_id: PUB;2b18780e44ca469fb3c91bb0c68b2022
- version: 1.0

## Description

This indicator calculates a custom daily "Settlement" (or anchor price) specifically optimized for trading XAUUSD (Gold). Instead of relying on the standard daily open or close, it establishes a daily pivot based on a specific 1-minute high-volume window.

**Why this indicator was created:**
Unlike Gold Futures (GC) on the CME, which have an official exchange-mandated daily settlement price, spot Gold (XAUUSD) is traded as a CFD over-the-counter (OTC) without a centralized daily close. This indicator bridges that gap by generating a highly reliable daily anchor—simulating a futures-style settlement on your standard XAUUSD chart.

**What it does:**
In the Forex and commodities markets, specific times of the day experience a massive influx of liquidity (such as market overlaps or specific fixing times). This script isolates a specific 1-minute time window (13:29 to 13:30 by default, based on the selected timezone) and calculates a Volume Weighted Average Price (VWAP) using historical data for that exact minute. This creates a highly reliable daily anchor price, plotting a continuous horizontal line for the rest of the trading session.

**Key Features:**
* **Custom VWAP Anchor:** Computes a daily anchor price using a specific 1-minute volume-weighted window, avoiding the noise of standard daily candle closes.
* **Percentage Variations:** Automatically projects up to 5% positive and negative zones originating from the settlement price. These bands act as major intraday support and resistance levels for Gold traders.
* **Manual Override:** Allows users to input a custom settlement price manually if they wish to anchor the percentage bands to a different key price level or historical pivot.
* **Clean Visuals:** Lines and labels are dynamically plotted for the current day only, keeping your XAUUSD charts clean and easy to read without historical clutter.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("SafeIN - Settlement & Variations", overlay=true, max_lines_count=50, max_labels_count=50)

// --- Fixed Time (Hidden from settings) ---
startTime = "1329"
endTime   = "1330"

// --- Visible Input Parameters ---
groupSettlement = "Settlement Settings"
showSettlement = input.bool(true, "Show Settlement and Variations?", group=groupSettlement)
settlementName = input.string("SETTLEMENT", "Settlement Label Name", group=groupSettlement)
manualSettlement = input.float(0.0, "Force Manual Settlement (0 = Auto)", tooltip="Insert a custom settlement here. Leave 0 for automatic calculation.", group=groupSettlement)

useChartTimezone = input.bool(true, "Use Chart Timezone?", group=groupSettlement)
manualTimezone = input.string("America/Sao_Paulo", "Manual Timezone", group=groupSettlement)
finalTimezone = useChartTimezone ? syminfo.timezone : manualTimezone

// --- Gradient Color Arrays ---
var color[] upColors = array.from(
     color.rgb(180,255,180), color.rgb(150,255,150), color.rgb(120,255,120), 
     color.rgb(90,255,90), color.rgb(60,255,60), color.rgb(30,220,30), 
     color.rgb(0,190,0), color.rgb(0,160,0), color.rgb(0,130,0), color.rgb(0,100,0)
     )
     
var color[] downColors = array.from(
     color.rgb(255,180,180), color.rgb(255,150,150), color.rgb(255,120,120), 
     color.rgb(255,90,90), color.rgb(255,60,60), color.rgb(220,30,30), 
     color.rgb(190,0,0), color.rgb(160,0,0), color.rgb(130,0,0), color.rgb(100,0,0)
     )

// --- SETTLEMENT CALCULATION FUNCTION ---
sessionStr = startTime + "-" + endTime
f_calc_settlement() =>
    // OPTIMIZATION: Only calculates for the last 48 hours (86400000 ms = 1 day)
    // This prevents the 1-minute chart from processing years of historical data.
    isRecent = time >= (timenow - (86400000 * 2))
    
    inSession = isRecent and not na(time(timeframe.period, sessionStr, finalTimezone))
    isNewSession = inSession and not inSession[1]
    
    var float sumPV = 0.0
    var float sumV = 0.0
    var float currentValue = na
    
    if isNewSession
        sumPV := 0.0
        sumV := 0.0
    if inSession
        sumPV += (close * volume)
        sumV += volume
        currentValue := sumV > 0 ? (sumPV / sumV) : close
    else if not na(currentValue[1])
        currentValue := currentValue[1]
        
    currentValue 

calcSettlementValue = request.security(syminfo.tickerid, "1", f_calc_settlement())
finalSettlement = manualSettlement > 0.0 ? manualSettlement : calcSettlementValue

// =====================================================================
// === PRICE SCALE LABELS (Y-AXIS) =====================================
// =====================================================================
plot(showSettlement ? finalSettlement : na, title="Settlement", color=color.orange, display=display.price_scale)

plot(showSettlement ? finalSettlement * 1.010 : na, title="+1.0%", color=array.get(upColors, 1), display=display.price_scale)
plot(showSettlement ? finalSettlement * 1.020 : na, title="+2.0%", color=array.get(upColors, 3), display=display.price_scale)
plot(showSettlement ? finalSettlement * 1.030 : na, title="+3.0%", color=array.get(upColors, 5), display=display.price_scale)
plot(showSettlement ? finalSettlement * 1.040 : na, title="+4.0%", color=array.get(upColors, 7), display=display.price_scale)
plot(showSettlement ? finalSettlement * 1.050 : na, title="+5.0%", color=array.get(upColors, 9), display=display.price_scale)

plot(showSettlement ? finalSettlement * 0.990 : na, title="-1.0%", color=array.get(downColors, 1), display=display.price_scale)
plot(showSettlement ? finalSettlement * 0.980 : na, title="-2.0%", color=array.get(downColors, 3), display=display.price_scale)
plot(showSettlement ? finalSettlement * 0.970 : na, title="-3.0%", color=array.get(downColors, 5), display=display.price_scale)
plot(showSettlement ? finalSettlement * 0.960 : na, title="-4.0%", color=array.get(downColors, 7), display=display.price_scale)
plot(showSettlement ? finalSettlement * 0.950 : na, title="-5.0%", color=array.get(downColors, 9), display=display.price_scale)

// =====================================================================
// === LINES STARTING POINT (OPENING CORRECTION) =======================
// =====================================================================
var int linesStartIndex = bar_index
if ta.change(time("D")) != 0 
    linesStartIndex := bar_index

// =====================================================================
// === CHART LINES DRAWING (CURRENT DAY ONLY) ==========================
// =====================================================================
var line settlementLine = line.new(na, na, na, na, color=color.orange, width=2, style=line.style_solid)
var label lblSettlement = label.new(na, na, "", style=label.style_label_left, textcolor=color.orange, color=color.new(color.white, 100))

var line[] upLines = array.new_line()
var line[] downLines = array.new_line()
var label[] upLabels = array.new_label()
var label[] downLabels = array.new_label()

if barstate.isfirst
    transparentColor = color.new(color.white, 100)
    for i = 0 to 9
        array.push(upLines, line.new(na, na, na, na, style=line.style_solid))
        array.push(downLines, line.new(na, na, na, na, style=line.style_solid))
        if (i + 1) % 2 == 0 
            array.push(upLabels, label.new(na, na, "", style=label.style_label_left, color=transparentColor))
            array.push(downLabels, label.new(na, na, "", style=label.style_label_left, color=transparentColor))

// Moves and stretches lines continuously
if barstate.islast
    if showSettlement and not na(finalSettlement)
        int rightOffset = bar_index + 6 
        
        line.set_xy1(settlementLine, linesStartIndex, finalSettlement)
        line.set_xy2(settlementLine, rightOffset, finalSettlement)
        label.set_xy(lblSettlement, rightOffset, finalSettlement)
        label.set_text(lblSettlement, settlementName)
        
        int labelIndex = 0
        for i = 0 to 9
            int k = i + 1
            float priceUp = finalSettlement * (1.0 + (0.005 * k))
            float priceDown = finalSettlement * (1.0 - (0.005 * k))
            
            color colorU = array.get(upColors, i)
            color colorD = array.get(downColors, i)
            
            line lU = array.get(upLines, i)
            line.set_xy1(lU, linesStartIndex, priceUp)
            line.set_xy2(lU, rightOffset, priceUp)
            line.set_color(lU, colorU)
            
            line lD = array.get(downLines, i)
            line.set_xy1(lD, linesStartIndex, priceDown)
            line.set_xy2(lD, rightOffset, priceDown)
            line.set_color(lD, colorD)
            
            if k % 2 == 0
                label lblU = array.get(upLabels, labelIndex)
                label.set_xy(lblU, rightOffset, priceUp)
                label.set_text(lblU, "+" + str.tostring(k / 2.0, "#.0") + "%")
                label.set_textcolor(lblU, colorU)
                
                label lblD = array.get(downLabels, labelIndex)
                label.set_xy(lblD, rightOffset, priceDown)
                label.set_text(lblD, "-" + str.tostring(k / 2.0, "#.0") + "%")
                label.set_textcolor(lblD, colorD)
                
                labelIndex += 1
    else
        line.set_xy1(settlementLine, na, na)
        line.set_xy2(settlementLine, na, na)
        label.set_xy(lblSettlement, na, na)
        for i = 0 to 9
            line.set_xy1(array.get(upLines, i), na, na)
            line.set_xy2(array.get(upLines, i), na, na)
            line.set_xy1(array.get(downLines, i), na, na)
            line.set_xy2(array.get(downLines, i), na, na)
        for i = 0 to array.size(upLabels) - 1
            label.set_xy(array.get(upLabels, i), na, na)
            label.set_xy(array.get(downLabels, i), na, na)
````
