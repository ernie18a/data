# David Custom Watermark

- url: https://www.tradingview.com/script/2UvsIQxq-David-Custom-Watermark/
- type: indicator
- pine_id: PUB;539352287e3246cfa4fef21a0ce3bbe3
- version: 1.0

## Description

This description is structured specifically for the TradingView Community. It uses Markdown formatting that looks great on the platform and highlights the "Professional HUD" nature of your script.

Description
David Custom Watermark (DWM) is a high-utility, professional-grade heads-up display (HUD) designed to provide traders with instant technical and fundamental context. Instead of cluttering your chart with multiple indicators, DWM consolidates essential data into a clean, customizable table.

Whether you are day trading or swing trading, this indicator ensures you never lose sight of the "Big Picture" trend and volatility.

Key Features
⚡ Multi-Timeframe ATR Monitor: Track volatility on any timeframe (Daily, Weekly, etc.) regardless of your current chart. Includes a percentage-based "Traffic Light" system (🟢, 🟡, 🔴) to alert you when a stock is becoming overextended.

📈 Dynamic Moving Average Suite: Toggleable status for the 20, 50, 150, and 200 MAs. The specialized MTF engine allows you to see if the price is above or below Daily/Weekly trend lines while you are scalping on intraday timeframes.

🏢 Fundamental Insights: Displays Company Name, Sector, Industry, and live Market Cap (automatically formatted to Millions, Billions, or Trillions).

📅 Earnings Countdown: A built-in logic that calculates exactly how many days are left until the next earnings report, helping you manage risk ahead of high-volatility events.

🎨 Fully Customizable UI: * Adjust location (Top/Middle/Bottom and Left/Center/Right).

Fine-tune vertical offsets to avoid overlapping with price action.

Customizable colors and text sizes (Small to Huge).

Why use this?
Most indicators take up valuable screen real estate. DWM is designed to be a "Single Source of Truth." In one glance, you know exactly what the company does, how volatile it is, where the major trend stands, and when the next catalyst (Earnings) is coming.

How to use
For Volatility: Use the ATR % to determine if the stock is too "hot" to enter. (Adjust your thresholds in the settings).

For Trend: Watch the MA row—when the 200, 150, 50, and 20 are all green, you are in a confirmed bullish momentum phase.

For Risk: Check the Earnings row to ensure you aren't accidentally holding a position through a binary event.

## Source Code

````pine
//@version=5
indicator("David Custom Watermark", shorttitle = 'DWM', overlay = true)

// --- User Inputs ---
// Group 1: Position
yPos        = input.string("Top", "Watermark Vertical Location", options = ["Top", "Middle", "Bottom"], inline = '1')
xPos        = input.string("Left", "Watermark Horizontal Location", options = ["Left", "Center", "Right"], inline = '1')
offsetY     = input.int(0, "Vertical Offset (%)", minval=0, maxval=100, tooltip = "Adjusts the empty space above the text") 

// Group 2: Style
txtCol      = input.color(color.rgb(164, 167, 180, 30), 'Text Color', inline = '2')
txtSize     = input.string('Huge', 'Text Size', options = ['Huge', 'Large', 'Normal', 'Small'], inline = '2')

// Group 3: Data Toggles
symTime     = input.bool(true, 'Symbol & Time Frame')
compName    = input.bool(true, 'Company Name')
indSec      = input.bool(false, 'Industry & Sector')
mCap        = input.bool(true, 'Show Market Cap')
showATR     = input.bool(true, "Show ATR & %") 
atrTF       = input.timeframe("D", "ATR Timeframe")

// Group 4: Moving Averages (Multi-Timeframe)
maTF        = input.timeframe("D", "MA Timeframe", tooltip="Select 'D' for Daily, 'W' for Weekly, or leave blank/current for Chart TF")
showMA200   = input.bool(true, "Show 200 MA", inline="ma1")
showMA150   = input.bool(true, "Show 150 MA", inline="ma1")
showMA50    = input.bool(false, "Show 50 MA", inline="ma2")
showMA20    = input.bool(false, "Show 20 MA", inline="ma2")

// Group 5: Earnings & Thresholds
showRemainingDaysInput = input.bool(true, "Show Days Until Earnings")
showEarningsRow     = input.bool(true, "Show Earnings Info")
atrRedThreshold     = input.float(6.0, "ATR Red Threshold (%)", minval=0)
atrYellowThreshold  = input.float(3.0, "ATR Yellow Threshold (%)", minval=0)

// --- Logic & Calculations ---

sizer = switch txtSize
    'Huge'   => size.huge
    'Large'  => size.large
    'Normal' => size.normal
    'Small'  => size.small

rounder(float val) =>
    if val >= 1000000000000
        str.tostring(math.round(val / 1000000000000, 2)) + 'T'
    else if val >= 1000000000
        str.tostring(math.round(val / 1000000000, 2)) + 'B'
    else 
        str.tostring(math.round(val / 1000000, 2)) + 'M'

// Market Data
sector      = syminfo.sector
ind         = syminfo.industry
tick        = syminfo.ticker
name        = syminfo.description
marketcap   = syminfo.shares_outstanding_total * close 
mCapStr     = rounder(marketcap)

tfDisplay   = timeframe.period == 'D' ? '1D' : 
              timeframe.period == 'W' ? '1W' : 
              timeframe.period == 'M' ? '1M' : 
              timeframe.isintraday ? (math.floor(timeframe.multiplier / 60) > 0 ? str.tostring(math.floor(timeframe.multiplier / 60)) + 'H' : str.tostring(timeframe.multiplier) + 'm') : 
              timeframe.period

// --- Data Fetching ---

// ATR Fetching
[atrValue, tfClose] = request.security(syminfo.tickerid, atrTF, [ta.atr(14), close])
atrPercent  = (atrValue / tfClose) * 100
atrEmoji    = atrPercent >= atrRedThreshold ? "🔴" : atrPercent >= atrYellowThreshold ? "🟡" : "🟢"

// Moving Average Fetching (Now using user-selected 'maTF')
[ma200, ma150, ma50, ma20] = request.security(syminfo.tickerid, maTF, [ta.sma(close, 200), ta.sma(close, 150), ta.sma(close, 50), ta.sma(close, 20)])

// Helper function for MA Status string - modified to include TF name
getMAStatus(float maVal, int length, string tf) =>
    not na(maVal) ? (close > maVal ? str.tostring(length) + "(" + tf + ") 🟢" : str.tostring(length) + "(" + tf + ") 🔴") : ""

// Earnings Calculation
earningsTime = earnings.future_time
earningsText = ""
if not na(earningsTime) and showEarningsRow
    msPerDay = 86400000
    timeDiff = math.max(0, math.round((earningsTime - timenow) / msPerDay))
    earningsText := "Earnings: " + str.tostring(timeDiff) + " days remaining"

// --- Table Rendering ---

posTable = str.lower(yPos) + '_' + str.lower(xPos)
var table sec = table.new(posTable, 1, 15, border_width = 0)

if barstate.islast
    rowIndex = 0
    table.cell(sec, 0, rowIndex, "", height = offsetY, text_color = color.new(color.white, 100)) 
    rowIndex += 1
    
    if compName
        txt = mCap ? name + ' (' + mCapStr + ')' : name
        table.cell(sec, 0, rowIndex, txt, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1
    
    if symTime
        table.cell(sec, 0, rowIndex, tick + ', ' + tfDisplay, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1
    
    if indSec
        txt = not na(sector) ? sector + ', ' + ind : ''
        table.cell(sec, 0, rowIndex, txt, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1
    
    if showATR
        txt = "ATR (" + atrTF + "): " + str.tostring(atrValue, "#.##") + " (" + str.tostring(atrPercent, "#.##") + "%) " + atrEmoji
        table.cell(sec, 0, rowIndex, txt, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1
    
    // MA Display Logic
    maList = ""
    maTfDisplay = maTF == "" ? tfDisplay : maTF // Show '1D' etc if set to chart
    
    if showMA200
        maList += getMAStatus(ma200, 200, maTfDisplay) + "  "
    if showMA150
        maList += getMAStatus(ma150, 150, maTfDisplay) + "  "
    if showMA50
        maList += getMAStatus(ma50, 50, maTfDisplay) + "  "
    if showMA20
        maList += getMAStatus(ma20, 20, maTfDisplay)
        
    if maList != ""
        table.cell(sec, 0, rowIndex, maList, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1
    
    if showEarningsRow and earningsText != ""
        table.cell(sec, 0, rowIndex, earningsText, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1
````
