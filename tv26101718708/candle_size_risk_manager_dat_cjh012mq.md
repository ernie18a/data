# Candle Size & Risk Manager - D.A.T

- url: https://www.tradingview.com/script/CJH012mQ-Candle-Size-Risk-Manager-D-A-T/
- type: indicator
- pine_id: PUB;6b6d1e5332604513b8391afc80c454ee
- version: 2.0

## Description

בכיף! הנה תיאור מקצועי, ברור ומסודר באנגלית שתוכל פשוט להעתיק ולהדביק כשאתה מפרסם או שומר את האינדיקטור ב-TradingView:

Candle Size & Risk Manager

Overview
The Candle Size & Risk Manager is a clean, non-intrusive tool designed to help traders calculate their exact position size instantly based on a predefined dollar risk. Instead of cluttering your chart with annoying floating labels, this indicator uses a smart Table UI and TradingView's built-in Status Line to give you the exact data you need, exactly when you need it.

Key Features

Dynamic Position Sizing: Automatically calculates how many contracts/shares to buy or sell based on your specific Risk (USD) and the High-Low range of the candle (Entry at one end, Stop Loss at the other).

Smart Table UI (Prev & Curr): A minimal, customizable table displays the statistics for the previously closed candle side-by-side with the current live candle. The live candle data is slightly transparent, allowing you to focus on the confirmed, closed candle for precise execution.

Hover for Historical Data: Want to backtest or check a previous setup? Simply hover your crosshair over any historical candle. The exact Quantity (Qty), Stop Distance, and Candle Value will instantly update in the Status Line and Data Window at the top of your screen.

Auto Point Value Detection: Built-in automatic detection for popular futures tickers (e.g., NQ, MNQ, ES, MES), with an option to manually override the point value for other instruments or stocks.

Long/Short Toggle: Easily switch between Long (Entry at High/Low, Stop at the opposite) and Short scenarios directly from the settings to adapt your risk calculation on the fly.

How to Use

Set your fixed Risk per Trade in USD.

Choose your intended position direction (Long or Short).

Check the corner table for immediate execution sizing on the last closed candle, or hover over past price action to study your setups cleanly.

## Source Code

````pine
//@version=6
indicator("Candle Size & Risk Manager", shorttitle="RiskMgr", overlay=true)

// ======== Inputs ========
riskUsd      = input.float(100, "Risk per Trade (USD)", step=1, group="Risk Settings")
positionSide = input.string("Long", "Position Direction", options=["Long", "Short"], tooltip="Long: Entry at Low, Stop at High. Short: Entry at High, Stop at Low", group="Risk Settings")

showTable    = input.bool(true, "Show Info Table on Chart", group="Table UI")
tablePosStr  = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Table UI")

overridePV   = input.bool(false, "Override point value manually", group="Instrument Settings")
manualPV     = input.float(1.0, "Manual point value (USD per point)", step=0.01, group="Instrument Settings")

// ======== Instrument / point value detection ========
float detectedPV = na
if not na(syminfo.pointvalue) and syminfo.pointvalue > 0
    detectedPV := syminfo.pointvalue
else
    rootSym = str.upper(syminfo.root)
    detectedPV := switch rootSym
        "NQ"  => 20.0
        "MNQ" => 2.0
        "ES"  => 50.0
        "MES" => 5.0
        => 1.0

pointValue = overridePV ? manualPV : detectedPV

// ======== Candle Calculations ========
rangePoints = high - low
rangeDollars = rangePoints * pointValue

// Entry/Stop logic
float entryPrice = na
float stopPrice  = na
if positionSide == "Long"
    entryPrice := low
    stopPrice  := high
else
    entryPrice := high
    stopPrice  := low

stopDistancePoints = math.abs(stopPrice - entryPrice)
stopDistanceDollars = stopDistancePoints * pointValue

// Position size calculation
positionSize = stopDistanceDollars > 0 ? math.floor(riskUsd / stopDistanceDollars) : na

// Actual Risk calculation (Position Size * Dollar Risk per Contract)
actualRiskDollars = not na(positionSize) ? positionSize * stopDistanceDollars : na

// ======== Hover Outputs (Status Line / Data Window) ========
// הערכים למעלה בגרף - יעבדו על כל נר שתצביע עליו
plot(positionSize, title="Qty", color=color.new(color.green, 0), display=display.status_line + display.data_window)
plot(actualRiskDollars, title="Actual Risk ($)", color=color.new(color.red, 0), display=display.status_line + display.data_window)
plot(stopDistancePoints, title="Stop Dist (Pts)", color=color.new(color.gray, 0), display=display.status_line + display.data_window)

// ======== Table UI ========
var tablePos = position.top_right
if tablePosStr == "Top Left"
    tablePos := position.top_left
else if tablePosStr == "Bottom Right"
    tablePos := position.bottom_right
else if tablePosStr == "Bottom Left"
    tablePos := position.bottom_left

// יצירת טבלה עם 3 עמודות ו-5 שורות (הגדלנו ב-1)
var table infoTable = table.new(tablePos, 3, 5, bgcolor=color.new(#1e222d, 10), border_color=color.new(#787b86, 50), border_width=1, frame_color=color.new(#787b86, 50), frame_width=1)

if showTable and barstate.islast
    // Header - כותרות
    table.cell(infoTable, 0, 0, "מדד", text_color=#787b86, text_size=size.small)
    table.cell(infoTable, 1, 0, "קודם (Prev)", text_color=#787b86, text_size=size.small)
    table.cell(infoTable, 2, 0, "עכשווי (Curr)", text_color=#787b86, text_size=size.small)
    
    // Row 1: Qty - כמות
    table.cell(infoTable, 0, 1, "Qty (" + positionSide + ")", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 1, na(positionSize[1]) ? "N/A" : str.tostring(positionSize[1]), text_color=color.green)
    table.cell(infoTable, 2, 1, na(positionSize) ? "N/A" : str.tostring(positionSize), text_color=color.new(color.green, 40)) // קצת שקוף יותר
    
    // Row 2: Actual Risk - סיכון בפועל (חדש)
    table.cell(infoTable, 0, 2, "Actual Risk", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 2, na(actualRiskDollars[1]) ? "N/A" : "$" + str.tostring(actualRiskDollars[1], format.mintick), text_color=#f23645) // צבע אדום
    table.cell(infoTable, 2, 2, na(actualRiskDollars) ? "N/A" : "$" + str.tostring(actualRiskDollars, format.mintick), text_color=color.new(#f23645, 40)) // אדום שקוף יותר
    
    // Row 3: Candle Range - גודל נר
    table.cell(infoTable, 0, 3, "Candle Range", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 3, str.tostring(rangePoints[1], format.mintick) + " pts ($" + str.tostring(rangeDollars[1], format.mintick) + ")", text_color=color.white)
    table.cell(infoTable, 2, 3, str.tostring(rangePoints, format.mintick) + " pts ($" + str.tostring(rangeDollars, format.mintick) + ")", text_color=color.new(color.white, 40)) // קצת שקוף יותר
    
    // Row 4: Point Value - ערך לנקודה
    table.cell(infoTable, 0, 4, "Point Value", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 4, "$" + str.tostring(pointValue[1]), text_color=color.white)
    table.cell(infoTable, 2, 4, "$" + str.tostring(pointValue), text_color=color.new(color.white, 40)) // קצת שקוף יותר
````
