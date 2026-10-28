# Daily ATR Percentage Reached - Enhanced 

- url: https://www.tradingview.com/script/WziGtZpn-Daily-ATR-Percentage-Reached-Enhanced/
- type: indicator
- pine_id: PUB;a490d3beb6fa4cfaa6f27686b5550c8c
- version: 1.0

## Description

📊 Daily ATR Percentage Reached - Enhanced Indicator
Trading Tool for Volatility Analysis 

. 📌 Overview
What is the Daily ATR Percentage Reached Indicator?
A comprehensive volatility analysis tool that measures how much of the daily Average True Range (ATR) has been fulfilled by the current day's price movement.

Core Concept
"Know exactly where price stands within today's expected volatility range"

The Problem It Solves
❌ Trading without context of daily volatility

❌ Missing breakout/breakdown opportunities

❌ Poor stop loss placement

❌ Not knowing when moves are exhausted

The Solution
✅ Real-time volatility context

✅ Clear visual signals on chart

✅ Comprehensive dashboard with key metrics

✅ Actionable trading suggestions 


 ⭐ Key Features
🎯 Core Functionality
Feature	Description
Fixed Daily ATR	ATR value stays constant throughout the trading day
Multi-Timeframe Compatible	Works on any timeframe (1min to Monthly)
Real-time Price Updates	Price fulfillment updates on lower timeframes
Visual Labels	ATR % displayed directly on the price chart
Separate Indicator Pane	Histogram shows ATR % history

📊 Advanced Metrics
Metric	What It Shows
ATR % Reached	Percentage of daily ATR already used
Price Fulfillment %	Current price position within ATR range
Volume Ratio	Current volume vs 20-day average
Day Progress	Percentage of trading day completed
ATR Trend	Whether ATR is expanding or contracting
Price vs Average %	Price deviation from 20-day average 

📊 Dashboard Metrics

Complete Dashboard Breakdown
#	Metric	Label Color	Interpretation
1	Daily ATR	White	Current day's ATR value
2	Daily Range	Yellow	Today's high-low range
3	Today's ATR %	Green/Red/Gray	% of ATR used today
4	Avg ATR %	Orange	50-day average ATR %
5	Price Fulfillment %	Blue	Price position in ATR
6	Volume Ratio	Cyan	Volume vs average
7	Day Progress	Purple	Time elapsed today
8	Time Remaining	Purple	Time left today
9	ATR Trend	Green/Red	Expanding/Contracting
10	Price vs Avg %	Green/Red/Gray	Deviation from average
11	💡 Suggestion	Color-coded	Trading recommendation

 💰 Trading Applications

Entry Signals
Scenario	Signal	Action
Low ATR % + Bullish	Room to run	Consider long entry
Low ATR % + Bearish	Room to fall	Consider short entry
High ATR % + Bullish	Exhaustion	Consider taking profits
High ATR % + Bearish	Exhaustion	Consider taking profits

Exit Signals
Metric	Signal	Action
ATR % > 100%	Extended move	Tighten stops
ATR % > 150%	Extreme move	Consider exit
Price Fulfillment > 80%	Near top	Take partial profits
Price Fulfillment < 20%	Near bottom	Look for bounce 

 🕐 Use Cases by Timeframe


🟢 1-Minute Chart (Scalping)
Best For: Quick entries/exits

Monitor Price Fulfillment % in real-time

Enter when fulfillment < 20% with momentum

Exit when fulfillment > 80%

🟡 5-Minute Chart (Day Trading)
Best For: Intraday swing trades

Watch for breakouts when ATR % < 50%

Volume confirmation with Volume Ratio > 1.5x

Use ATR for stop placement

🟠 15-Minute Chart (Swing Trading)
Best For: Multi-hour positions

ATR Trend (Expanding) = Volatility increasing

Price vs Avg % for trend strength

Day Progress to know time left

🔴 1-Hour Chart (Position Trading)
Best For: Full-day positions

Daily context for larger moves

ATR % to gauge daily potential

Volume confirmation 



⚠️ Alert System
Built-in Alerts

Alert	Trigger	Message
ATR Exceeded 100%	dailyATRReached > 100	"Daily ATR has exceeded 100%!"
ATR Exceeded 150%	dailyATRReached > 150	"Extreme volatility detected!"
High Volume	volumeRatio > 2	"Volume is 2x above average!"

 🎯 Benefits for Traders

🚀 For Day Traders
Benefit	Impact
Real-time Context	Know if moves are significant
Volume Confirmation	Validate breakouts
Time Awareness	Know if there's time left
Stop Placement	Use ATR for stops

📈 For Swing Traders
Benefit	Impact
Volatility Trend	ATR expanding = good for swings
Daily Context	Know the day's potential
Support/Resistance	Price fulfillment levels
Trend Strength	Price vs Average %

💼 For Position Traders
Benefit	Impact
Daily View	Understand daily volatility
Risk Management	ATR-based sizing
Entry Timing	Wait for pullbacks
Exit Planning	Take profits near extremes
🎓 For Beginners

Benefit	Impact
Visual Clarity	Easy to understand labels
Dashboard	All metrics in one place
Suggestions	Built-in trading ideas
Customizable	Show only what you need 

🔒 Risk Disclaimer
⚠️ Important Notice

This indicator is a tool for analysis, not a guarantee of results. Always:

Use proper risk management

Consider market conditions

Combine with other analysis methods

Never risk more than you can afford to lose

Backtest before live trading 

ONLY FOR EDUCATIONAL PURPOSES 
NOT A FINANCIAL ADVICE

## Source Code

````pine
//@version=6
indicator("Daily ATR Percentage Reached - Enhanced", overlay=true, precision=2)

// Inputs
atrLength = input.int(14, "ATR Length", minval=1)
//startDate = input.time(timestamp("2026-01-01"), "Start Date")
//endDate = input.time(timestamp("2026-12-31"), "End Date")
showVolume = input.bool(true, "Show Volume Metrics")
showTime = input.bool(true, "Show Time Metrics")
showStats = input.bool(true, "Show Statistical Metrics")

// Table layout options
tableLayout = input.string("Vertical", "Table Layout", options=["Vertical", "Horizontal"])
tablePosition = input.string("Top Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"])
tableSize = input.string("Normal", "Table Size", options=["Small", "Normal", "Large"])
tableBgColor = input.color(color.black, "Table Background Color")
tableHeaderColor = input.color(color.gray, "Header Background Color")
tableBorderColor = input.color(color.gray, "Border Color")

// Map table position to position constant
tablePos = switch tablePosition
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Top Right" => position.top_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right" => position.middle_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right" => position.bottom_right

// Map table size to size constant
tableFontSize = switch tableSize
    "Small" => size.small
    "Normal" => size.normal 
    "Large" => size.large

// Calculate daily values
[dailyATR, dailyHigh, dailyLow, dailyClose, dailyOpen, dailyVolume] = request.security(syminfo.tickerid, "D", 
    [ta.atr(atrLength), high, low, close, open, volume], lookahead=barmerge.lookahead_on)

atrValue = dailyATR
dailyHighPrice = dailyHigh
dailyLowPrice = dailyLow
dailyClosePrice = dailyClose
dailyOpenPrice = dailyOpen
dailyVol = dailyVolume

//isInRange = time >= startDate and time <= endDate

// Core metrics
dailyRange = dailyHighPrice - dailyLowPrice
dailyATRReached = not na(atrValue) and atrValue > 0 ? (dailyRange / atrValue) * 100 : na
currentPriceFulfillment = not na(atrValue) and atrValue > 0 ? ((close - dailyLowPrice) / atrValue) * 100 : na
pricePositionInRange = dailyRange > 0 ? ((close - dailyLowPrice) / dailyRange) * 100 : na

// Volume metrics
avgVolume = request.security(syminfo.tickerid, "D", ta.sma(volume, 20), lookahead=barmerge.lookahead_on)
volumeRatio = avgVolume > 0 ? dailyVol / avgVolume : na
volumeAboveAvg = volumeRatio > 1.5

// Time metrics
sessionStart = timenow - (timenow % 86400000)  // Start of day in milliseconds
sessionProgress = ((timenow - sessionStart) / 86400000) * 100
timeRemaining = 100 - sessionProgress

// ATR trend metrics
atr5 = request.security(syminfo.tickerid, "D", ta.atr(atrLength), lookahead=barmerge.lookahead_on)
atr5Prev = request.security(syminfo.tickerid, "D", ta.atr(atrLength)[1], lookahead=barmerge.lookahead_on)
atrTrend = atr5 > atr5Prev ? "Expanding" : "Contracting"
atrTrendColor = atr5 > atr5Prev ? color.green : color.red

// Statistical metrics
dailyCloseAvg = request.security(syminfo.tickerid, "D", ta.sma(close, 20), lookahead=barmerge.lookahead_on)
priceVsAvg = close - dailyCloseAvg
priceVsAvgPercent = dailyCloseAvg > 0 ? (priceVsAvg / dailyCloseAvg) * 100 : na

// Plot labels on main chart
if  not na(dailyATRReached)
    isUp = dailyClosePrice > dailyOpenPrice
    isDown = dailyClosePrice < dailyOpenPrice
    labelColor = isUp ? color.new(color.green, 80) : isDown ? color.new(color.red, 80) : color.new(color.gray, 80)
    
    if ta.change(time("D")) != 0 or barstate.islast
        labelText = "ATR: " + str.tostring(dailyATRReached, "#.#") + "%"
        if showVolume and not na(volumeRatio)
            labelText := labelText + "\nVol: " + str.tostring(volumeRatio, "#.##") + "x"
        if showTime
            labelText := labelText + "\nDay: " + str.tostring(sessionProgress, "#.#") + "%"
            
        label.new(
            bar_index, 
            dailyHighPrice + (atrValue * 0.3), 
            text=labelText,
            style=label.style_label_down,
            color=labelColor,
            textcolor=color.white,
            size=size.small
        )

// Plots
plot(dailyATRReached, "Daily ATR % Reached", color=color.purple, linewidth=2, style=plot.style_columns)
plot(100, "100% Line", color=color.red, linewidth=1)
plot(50, "50% Line", color=color.orange, linewidth=1)
plot(0, "Zero Line", color=color.new(color.gray, 30), linewidth=1)

// Plot ATR trend
plot(showStats ? atrTrend == "Expanding" ? 120 : 80 : na, "ATR Trend", color=atrTrendColor, linewidth=2, style=plot.style_line)

// Determine table dimensions based on layout
getTableDimensions() =>
    // Count how many rows we'll have
    rowCount = 7  // Base metrics (headers + 6 rows)
    if showVolume
        rowCount := rowCount + 1
    if showTime
        rowCount := rowCount + 2
    if showStats
        rowCount := rowCount + 2
    
    if tableLayout == "Vertical"
        [2, rowCount]  // [columns, rows]
    else
        [rowCount, 2]  // [columns, rows] - horizontal layout

// Create table with dynamic dimensions
[cols, rows] = getTableDimensions()
var table atrTable = table.new(tablePos, cols, rows, bgcolor=tableBgColor, border_width=1, border_color=tableBorderColor)

// Helper function to add cell
addCell(table, col, row, label, value, labelColor, valueColor, bgColor) =>
    table.cell(table, col, row, label, bgcolor=bgColor, text_color=labelColor, text_size=tableFontSize)
    table.cell(table, col + 1, row, value, bgcolor=bgColor, text_color=valueColor, text_size=tableFontSize)

// Update table
if barstate.islast
    table.set_position(atrTable, tablePos)
    table.set_bgcolor(atrTable, tableBgColor)
    table.set_border_color(atrTable, tableBorderColor)
    
    todayIsUp = dailyClosePrice > dailyOpenPrice
    todayIsDown = dailyClosePrice < dailyOpenPrice
    todayColor = todayIsUp ? color.green : todayIsDown ? color.red : color.gray
    
    avgATRPercent = request.security(syminfo.tickerid, "D", ta.sma((high - low) / ta.atr(atrLength) * 100, 50), lookahead=barmerge.lookahead_on)
    
    // Generate suggestion
    suggestion = ""
    suggestionColor = color.white
    
    if not na(dailyATRReached) and not na(avgATRPercent) and not na(currentPriceFulfillment)
        highVolatility = dailyATRReached > avgATRPercent * 1.5
        nearTop = currentPriceFulfillment > 80
        nearBottom = currentPriceFulfillment < 20
        
        if todayIsUp
            if highVolatility and nearTop
                suggestion := "🚀 Strong Bullish - Breakout"
                suggestionColor := color.green
            else if highVolatility
                suggestion := "📈 Bullish Momentum"
                suggestionColor := color.green
            else if nearTop
                suggestion := "⚠️ Near Resistance"
                suggestionColor := color.orange
            else
                suggestion := "📊 Consolidation"
                suggestionColor := color.gray
        else if todayIsDown
            if highVolatility and nearBottom
                suggestion := "🔥 Strong Bearish - Breakdown"
                suggestionColor := color.red
            else if highVolatility
                suggestion := "📉 Bearish Momentum"
                suggestionColor := color.red
            else if nearBottom
                suggestion := "⚠️ Near Support"
                suggestionColor := color.orange
            else
                suggestion := "📊 Consolidation"
                suggestionColor := color.gray
        else
            suggestion := "⏸️ Sideways"
            suggestionColor := color.gray
    else
        suggestion := "📊 Insufficient Data"
        suggestionColor := color.gray
    
    if tableLayout == "Vertical"
        // VERTICAL LAYOUT - metrics as rows
        row = 0
        // Headers
        table.cell(atrTable, 0, row, "📊 METRIC", bgcolor=tableHeaderColor, text_color=color.white, text_size=tableFontSize)
        table.cell(atrTable, 1, row, "📈 VALUE", bgcolor=tableHeaderColor, text_color=color.white, text_size=tableFontSize)
        row := row + 1
        
        // Core Metrics
        table.cell(atrTable, 0, row, "Daily ATR", bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
        table.cell(atrTable, 1, row, str.tostring(atrValue, "#.##"), bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
        row := row + 1
        
        table.cell(atrTable, 0, row, "Daily Range", bgcolor=tableBgColor, text_color=color.yellow, text_size=tableFontSize)
        table.cell(atrTable, 1, row, str.tostring(dailyRange, "#.##"), bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
        row := row + 1
        
        table.cell(atrTable, 0, row, "Today's ATR %", bgcolor=tableBgColor, text_color=todayColor, text_size=tableFontSize)
        table.cell(atrTable, 1, row, str.tostring(dailyATRReached, "#.#") + "%", bgcolor=tableBgColor, text_color=todayColor, text_size=tableFontSize)
        row := row + 1
        
        table.cell(atrTable, 0, row, "Avg ATR %", bgcolor=tableBgColor, text_color=color.orange, text_size=tableFontSize)
        table.cell(atrTable, 1, row, str.tostring(avgATRPercent, "#.#") + "%", bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
        row := row + 1
        
        table.cell(atrTable, 0, row, "Price Fulfillment %", bgcolor=tableBgColor, text_color=color.silver , text_size=tableFontSize)
        table.cell(atrTable, 1, row, str.tostring(currentPriceFulfillment, "#.#") + "%", bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
        row := row + 1
        
        // Additional metrics
        if showVolume and not na(volumeRatio)
            table.cell(atrTable, 0, row, "Volume Ratio", bgcolor=tableBgColor, text_color=color.silver , text_size=tableFontSize)
            volColor = volumeRatio > 1.5 ? color.green : volumeRatio > 1 ? color.yellow : color.red
            table.cell(atrTable, 1, row, str.tostring(volumeRatio, "#.##") + "x", bgcolor=tableBgColor, text_color=volColor, text_size=tableFontSize)
            row := row + 1
        
        if showTime
            table.cell(atrTable, 0, row, "Day Progress", bgcolor=tableBgColor, text_color=color.purple, text_size=tableFontSize)
            table.cell(atrTable, 1, row, str.tostring(sessionProgress, "#.#") + "%", bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
            row := row + 1
            
            table.cell(atrTable, 0, row, "Time Remaining", bgcolor=tableBgColor, text_color=color.purple, text_size=tableFontSize)
            table.cell(atrTable, 1, row, str.tostring(timeRemaining, "#.#") + "%", bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
            row := row + 1
        
        if showStats
            table.cell(atrTable, 0, row, "ATR Trend", bgcolor=tableBgColor, text_color=atrTrendColor, text_size=tableFontSize)
            table.cell(atrTable, 1, row, atrTrend, bgcolor=tableBgColor, text_color=atrTrendColor, text_size=tableFontSize)
            row := row + 1
            
            if not na(priceVsAvgPercent)
                table.cell(atrTable, 0, row, "Price vs Avg %", bgcolor=tableBgColor, text_color=color.orange, text_size=tableFontSize)
                avgColor = priceVsAvgPercent > 5 ? color.green : priceVsAvgPercent < -5 ? color.red : color.gray
                table.cell(atrTable, 1, row, str.tostring(priceVsAvgPercent, "#.#") + "%", bgcolor=tableBgColor, text_color=avgColor, text_size=tableFontSize)
                row := row + 1
        
        // Suggestion row
        table.cell(atrTable, 0, row, "💡 SUGGESTION", bgcolor=tableHeaderColor, text_color=color.white, text_size=tableFontSize)
        table.cell(atrTable, 1, row, suggestion, bgcolor=tableHeaderColor, text_color=suggestionColor, text_size=tableFontSize)
    
    else
        // HORIZONTAL LAYOUT - metrics as columns
        col = 0
        // Headers row
        table.cell(atrTable, col, 0, "📊 METRIC", bgcolor=tableHeaderColor, text_color=color.white, text_size=tableFontSize)
        table.cell(atrTable, col, 1, "📈 VALUE", bgcolor=tableHeaderColor, text_color=color.white, text_size=tableFontSize)
        col := col + 1
        
        // Core Metrics - Column 1
        table.cell(atrTable, col, 0, "Daily ATR", bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
        table.cell(atrTable, col, 1, str.tostring(atrValue, "#.##"), bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
        col := col + 1
        
        table.cell(atrTable, col, 0, "Daily Range", bgcolor=tableBgColor, text_color=color.yellow, text_size=tableFontSize)
        table.cell(atrTable, col, 1, str.tostring(dailyRange, "#.##"), bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
        col := col + 1
        
        table.cell(atrTable, col, 0, "Today's ATR %", bgcolor=tableBgColor, text_color=todayColor, text_size=tableFontSize)
        table.cell(atrTable, col, 1, str.tostring(dailyATRReached, "#.#") + "%", bgcolor=tableBgColor, text_color=todayColor, text_size=tableFontSize)
        col := col + 1
        
        table.cell(atrTable, col, 0, "Avg ATR %", bgcolor=tableBgColor, text_color=color.orange, text_size=tableFontSize)
        table.cell(atrTable, col, 1, str.tostring(avgATRPercent, "#.#") + "%", bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
        col := col + 1
        
        table.cell(atrTable, col, 0, "Price Fulfillment %", bgcolor=tableBgColor, text_color=color.blue, text_size=tableFontSize)
        table.cell(atrTable, col, 1, str.tostring(currentPriceFulfillment, "#.#") + "%", bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
        col := col + 1
        
        // Additional metrics
        if showVolume and not na(volumeRatio)
            table.cell(atrTable, col, 0, "Volume Ratio", bgcolor=tableBgColor, text_color=color.blue, text_size=tableFontSize)
            volColor = volumeRatio > 1.5 ? color.green : volumeRatio > 1 ? color.yellow : color.red
            table.cell(atrTable, col, 1, str.tostring(volumeRatio, "#.##") + "x", bgcolor=tableBgColor, text_color=volColor, text_size=tableFontSize)
            col := col + 1
        
        if showTime
            table.cell(atrTable, col, 0, "Day Progress", bgcolor=tableBgColor, text_color=color.purple, text_size=tableFontSize)
            table.cell(atrTable, col, 1, str.tostring(sessionProgress, "#.#") + "%", bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
            col := col + 1
            
            table.cell(atrTable, col, 0, "Time Remaining", bgcolor=tableBgColor, text_color=color.purple, text_size=tableFontSize)
            table.cell(atrTable, col, 1, str.tostring(timeRemaining, "#.#") + "%", bgcolor=tableBgColor, text_color=color.white, text_size=tableFontSize)
            col := col + 1
        
        if showStats
            table.cell(atrTable, col, 0, "ATR Trend", bgcolor=tableBgColor, text_color=atrTrendColor, text_size=tableFontSize)
            table.cell(atrTable, col, 1, atrTrend, bgcolor=tableBgColor, text_color=atrTrendColor, text_size=tableFontSize)
            col := col + 1
            
            if not na(priceVsAvgPercent)
                table.cell(atrTable, col, 0, "Price vs Avg %", bgcolor=tableBgColor, text_color=color.orange, text_size=tableFontSize)
                avgColor = priceVsAvgPercent > 5 ? color.green : priceVsAvgPercent < -5 ? color.red : color.gray
                table.cell(atrTable, col, 1, str.tostring(priceVsAvgPercent, "#.#") + "%", bgcolor=tableBgColor, text_color=avgColor, text_size=tableFontSize)
                col := col + 1
        
        // Suggestion column
        table.cell(atrTable, col, 0, "💡 SUGGESTION", bgcolor=tableHeaderColor, text_color=color.white, text_size=tableFontSize)
        table.cell(atrTable, col, 1, suggestion, bgcolor=tableHeaderColor, text_color=suggestionColor, text_size=tableFontSize)

// Alert conditions
alertcondition(dailyATRReached > 100, title="ATR Exceeded 100%", message="Daily ATR has exceeded 100%!")
alertcondition(dailyATRReached > 150, title="ATR Exceeded 150%", message="Extreme volatility detected!")
alertcondition(volumeRatio > 2, title="High Volume", message="Volume is 2x above average!")
````
