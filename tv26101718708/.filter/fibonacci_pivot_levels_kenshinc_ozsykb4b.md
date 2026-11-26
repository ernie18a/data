# Fibonacci Pivot Levels (KenshinC)

- url: https://www.tradingview.com/script/OzSykb4B-Fibonacci-Pivot-Levels-KenshinC/
- type: indicator
- pine_id: PUB;5842352b015947ff906c035419f0ce36
- version: 1.0

## Description

══════════════════════════════════════════════════════════════════════════════
                          [b]FIBONACCI PIVOT LEVELS (KenshinC)[/b]
══════════════════════════════════════════════════════════════════════════════

A powerful technical tool that merges classic Pivot Points with Fibonacci ratios 
to reveal high-probability support and resistance zones.

By calculating the central Pivot Point (P) from the Highest, Lowest, and Close 
prices over your selected period, the indicator automatically projects 10 custom 
Fibonacci levels both above and below the pivot — creating clear, precise 
horizontal levels that often act as strong price magnets.

Perfect for swing trading, day trading, breakout strategies, and spotting 
potential reversals across Forex, Stocks, Crypto, and Commodities.

✨ Additional Feature:
Includes an advanced RSI Predictor that forecasts potential overbought and 
oversold zones ahead of time, helping you anticipate momentum shifts.

══════════════════════════════════════════════════════════════════════════════
                             [b] HOW TO USE[/b]
══════════════════════════════════════════════════════════════════════════════

1. Settings Overview
   • Start Date & End Date     : Choose the period to calculate High, Low & Close
   • Use Close Value of End Date? : Use actual close or enter custom value
   • Decimal Places            : Display precision for price labels
   • Fibonacci Rates (1–10)    : Customize the 10 Fibonacci ratios
   • Show RSI Calculations?    : Enable/disable the RSI Predictor lines

2. Understanding the Levels
   • P  → Central Pivot Point (Black, bold line)
   • S1–S10 → Support Levels (Red)
   • R1–R10 → Resistance Levels (Green)

   Formula:
   Pivot (P) = (Highest + Lowest + Close) / 3
   Support    = P - (Fib Rate × Range)
   Resistance = P + (Fib Rate × Range)

3. Information Table
   Displays key data in the top-right corner:
   - Start & End Date
   - Highest & Lowest prices
   - Close value used
   - Data status

4. RSI Predictor
   Plots forward-looking support & resistance based on RSI (length 8, 16, 24) 
   with customizable overbought/oversold thresholds.

══════════════════════════════════════════════════════════════════════════════
                              [b]TRADING TIPS[/b]
══════════════════════════════════════════════════════════════════════════════

• Price above P → Generally bullish bias (focus on Support levels)
• Price below P → Generally bearish bias (focus on Resistance levels)
• Higher ratios (1.618, 2.000, 2.618, 3.000) often act as major turning zones
• Combine with candlestick patterns or volume for stronger confluences

══════════════════════════════════════════════════════════════════════════════
                              [b]IMPORTANT DISCLAIMER[/b]
══════════════════════════════════════════════════════════════════════════════

This indicator is for educational and informational purposes only. 
It is NOT financial advice, investment advice, or a recommendation to buy, 
sell, or hold any securities or assets.

Trading involves substantial risk of loss and is not suitable for everyone. 
Past performance does not guarantee future results. 

Always conduct your own research and consult with a qualified financial advisor 
before making any trading or investment decisions.

Use this tool at your own risk.

Created with passion by KenshinC

## Source Code

````pine
//@version=6
indicator("Fibonacci Pivot Levels (KenshinC)", overlay=true, max_lines_count=500, max_labels_count=500)

// ==================== INPUTS ====================
startDate = input.time(timestamp("2024-04-12 00:00 +0000"), title="Start Date")
endDate   = input.time(timestamp("2025-10-10 00:00 +0000"), title="End Date")

decimalPlaces = input.int(2, title="Decimal Places", minval=0)

useCloseValue = input.bool(true, title="Use Close Value of End Date?")
customClose   = input.float(0.0, title="Custom Close Value", step=0.01)

// Fibonacci Rates
rate1  = input.float(0.382, title="Rate 1",  step=0.001)
rate2  = input.float(0.618, title="Rate 2",  step=0.001)
rate3  = input.float(0.786, title="Rate 3",  step=0.001)
rate4  = input.float(1.000, title="Rate 4",  step=0.001)
rate5  = input.float(1.382, title="Rate 5",  step=0.001)
rate6  = input.float(1.618, title="Rate 6",  step=0.001)
rate7  = input.float(2.000, title="Rate 7",  step=0.001)
rate8  = input.float(2.382, title="Rate 8",  step=0.001)
rate9  = input.float(2.618, title="Rate 9",  step=0.001)
rate10 = input.float(3.000, title="Rate 10", step=0.001)

showRSI = input.bool(true, title="Show RSI Calculations?")

// ==================== CALCULATE HIGH / LOW / CLOSE ====================
var float highestPrice = na
var float lowestPrice  = na
var float closeValue   = na
var bool  dataReady    = false

if time >= startDate and time <= endDate
    dailyHigh = request.security(syminfo.tickerid, "D", high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    dailyLow  = request.security(syminfo.tickerid, "D", low,  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    
    highestPrice := na(highestPrice) ? dailyHigh : math.max(highestPrice, dailyHigh)
    lowestPrice  := na(lowestPrice)  ? dailyLow  : math.min(lowestPrice, dailyLow)

if na(closeValue) and time >= endDate
    dailyClose = request.security(syminfo.tickerid, "D", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    closeValue := useCloseValue ? dailyClose : customClose
    dataReady  := not na(highestPrice) and not na(lowestPrice) and not na(closeValue)

// ==================== FIND BAR_INDEX OF START AND END DATE ====================
var int startBar = na
var int endBar   = na

if na(startBar) and time >= startDate
    startBar := bar_index

if na(endBar) and time >= endDate
    endBar := bar_index

// ==================== DRAWING MANAGEMENT ====================
var line[]  allLines  = array.new_line()
var label[] allLabels = array.new_label()

clearDrawings() =>
    if array.size(allLines) > 0
        for i = array.size(allLines) - 1 to 0
            line.delete(array.get(allLines, i))
        array.clear(allLines)
    if array.size(allLabels) > 0
        for i = array.size(allLabels) - 1 to 0
            label.delete(array.get(allLabels, i))
        array.clear(allLabels)

// ==================== DRAW FIBONACCI LEVELS (ONLY BETWEEN START → END) ====================
var bool levelsDrawn = false

if dataReady and not levelsDrawn and not na(startBar) and not na(endBar)
    clearDrawings()
    
    P = (highestPrice + lowestPrice + closeValue) / 3

    // Store rates in array
    rateArr = array.new_float(10)
    array.set(rateArr, 0, rate1)
    array.set(rateArr, 1, rate2)
    array.set(rateArr, 2, rate3)
    array.set(rateArr, 3, rate4)
    array.set(rateArr, 4, rate5)
    array.set(rateArr, 5, rate6)
    array.set(rateArr, 6, rate7)
    array.set(rateArr, 7, rate8)
    array.set(rateArr, 8, rate9)
    array.set(rateArr, 9, rate10)

    // Draw Pivot (P)
    pLine = line.new(startBar, P, endBar, P, xloc=xloc.bar_index, color=color.black, width=2)
    pLabel = label.new(startBar, P, 
             text="P: " + str.tostring(P, "#,##0." + str.repeat("0", decimalPlaces)), 
             color=color.black, style=label.style_label_down, textcolor=color.white, xloc=xloc.bar_index)
    array.push(allLines, pLine)
    array.push(allLabels, pLabel)

    // Draw 10 Support & Resistance Levels
    for i = 0 to 9
        rate = array.get(rateArr, i)
        diff = highestPrice - lowestPrice
        support    = P - (rate * diff)
        resistance = P + (rate * diff)

        // Support
        sLine = line.new(startBar, support, endBar, support, xloc=xloc.bar_index, color=color.red, width=1)
        sLabel = label.new(startBar, support, 
                 text="S" + str.tostring(i + 1) + " (" + str.tostring(rate, "0.###") + "): " + 
                      str.tostring(support, "#,##0." + str.repeat("0", decimalPlaces)),
                 color=color.red, style=label.style_label_down, textcolor=color.white, xloc=xloc.bar_index)
        array.push(allLines, sLine)
        array.push(allLabels, sLabel)

        // Resistance
        rLine = line.new(startBar, resistance, endBar, resistance, xloc=xloc.bar_index, color=color.green, width=1)
        rLabel = label.new(startBar, resistance, 
                 text="R" + str.tostring(i + 1) + " (" + str.tostring(rate, "0.###") + "): " + 
                      str.tostring(resistance, "#,##0." + str.repeat("0", decimalPlaces)),
                 color=color.green, style=label.style_label_up, textcolor=color.white, xloc=xloc.bar_index)
        array.push(allLines, rLine)
        array.push(allLabels, rLabel)

    levelsDrawn := true

// ==================== INFORMATION TABLE ====================
var table infoTable = table.new(position.top_right, 2, 6, 
     bgcolor = color.new(color.yellow, 85), 
     border_width = 1, 
     border_color = color.gray, 
     frame_color = color.black, 
     frame_width = 2)

if dataReady and barstate.islast
    startStr = str.format_time(startDate, "yyyy-MM-dd")
    endStr   = str.format_time(endDate,   "yyyy-MM-dd")

    table.cell(infoTable, 0, 0, "Start Date", text_color=color.black, bgcolor=color.new(color.white, 70))
    table.cell(infoTable, 1, 0, startStr, text_color=color.black)

    table.cell(infoTable, 0, 1, "End Date", text_color=color.black, bgcolor=color.new(color.white, 70))
    table.cell(infoTable, 1, 1, endStr, text_color=color.black)

    table.cell(infoTable, 0, 2, "Highest", text_color=color.black, bgcolor=color.new(color.white, 70))
    table.cell(infoTable, 1, 2, str.tostring(highestPrice, "#,##0.##"), text_color=color.red)

    table.cell(infoTable, 0, 3, "Lowest", text_color=color.black, bgcolor=color.new(color.white, 70))
    table.cell(infoTable, 1, 3, str.tostring(lowestPrice, "#,##0.##"), text_color=color.green)

    table.cell(infoTable, 0, 4, "Close", text_color=color.black, bgcolor=color.new(color.white, 70))
    table.cell(infoTable, 1, 4, str.tostring(closeValue, "#,##0.##"), text_color=color.blue)

    table.cell(infoTable, 0, 5, "Ready", text_color=color.black, bgcolor=color.new(color.white, 70))
    table.cell(infoTable, 1, 5, str.tostring(dataReady), text_color = dataReady ? color.green : color.red)

// ==================== RSI SECTION ====================
rsiSourceInput   = input.source(close, "RSI Source", group="RSI Settings")
rsiLengthInput1  = input.int(8,  minval=1, title="RSI Length 1", group="RSI Settings")
rsiLengthInput2  = input.int(16, minval=1, title="RSI Length 2", group="RSI Settings")
rsiLengthInput3  = input.int(24, minval=1, title="RSI Length 3", group="RSI Settings")

up_level1   = input.float(90, "Overbought Level RSI 1", maxval=99, minval=50, group="RSI Predictor Settings")
down_level1 = input.float(15, "Oversold Level RSI 1",   maxval=50, minval=1, group="RSI Predictor Settings")

up_level2   = input.float(85, "Overbought Level RSI 2", maxval=99, minval=50, group="RSI Predictor Settings")
down_level2 = input.float(20, "Oversold Level RSI 2",   maxval=50, minval=1, group="RSI Predictor Settings")

up_level3   = input.float(80, "Overbought Level RSI 3", maxval=99, minval=50, group="RSI Predictor Settings")
down_level3 = input.float(25, "Oversold Level RSI 3",   maxval=50, minval=1, group="RSI Predictor Settings")

// RSI 1
up1   = ta.rma(math.max(ta.change(rsiSourceInput), 0), rsiLengthInput1)
down1 = ta.rma(-math.min(ta.change(rsiSourceInput), 0), rsiLengthInput1)
X1_1 = up_level1 / (100 - up_level1)
X2_1 = (100 - down_level1) / down_level1
resistance1 = rsiSourceInput + (rsiLengthInput1 - 1) * (X1_1 * down1 - up1)
support1    = rsiSourceInput - (rsiLengthInput1 - 1) * (X2_1 * up1 - down1)

// RSI 2
up2   = ta.rma(math.max(ta.change(rsiSourceInput), 0), rsiLengthInput2)
down2 = ta.rma(-math.min(ta.change(rsiSourceInput), 0), rsiLengthInput2)
X1_2 = up_level2 / (100 - up_level2)
X2_2 = (100 - down_level2) / down_level2
resistance2 = rsiSourceInput + (rsiLengthInput2 - 1) * (X1_2 * down2 - up2)
support2    = rsiSourceInput - (rsiLengthInput2 - 1) * (X2_2 * up2 - down2)

// RSI 3
up3   = ta.rma(math.max(ta.change(rsiSourceInput), 0), rsiLengthInput3)
down3 = ta.rma(-math.min(ta.change(rsiSourceInput), 0), rsiLengthInput3)
X1_3 = up_level3 / (100 - up_level3)
X2_3 = (100 - down_level3) / down_level3
resistance3 = rsiSourceInput + (rsiLengthInput3 - 1) * (X1_3 * down3 - up3)
support3    = rsiSourceInput - (rsiLengthInput3 - 1) * (X2_3 * up3 - down3)

// Plot RSI Predictor Lines
plot(showRSI ? resistance1 : na, "Resistance 8",  color=color.blue,   offset=1)
plot(showRSI ? support1    : na, "Support 8",     color=color.blue,   offset=1)
plot(showRSI ? resistance2 : na, "Resistance 16", color=color.orange, offset=1)
plot(showRSI ? support2    : na, "Support 16",    color=color.orange, offset=1)
plot(showRSI ? resistance3 : na, "Resistance 24", color=color.green,  offset=1)
plot(showRSI ? support3    : na, "Support 24",    color=color.green,  offset=1)
````
