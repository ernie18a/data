# Universal ATR Position Sizer + Volatility Context

- url: https://www.tradingview.com/script/u5PorsIZ-Universal-ATR-Position-Sizer-Volatility-Context/
- type: indicator
- pine_id: PUB;0c5ca7df62174977baab28af19783003
- version: 2.0

## Description

Overview
The Universal ATR Position Sizer Pro is a comprehensive risk management tool designed for traders who need precision across multiple asset classes. Unlike standard position sizers, this indicator automatically detects symbol point values to provide accurate sizing for Futures, Forex, Stocks, and Crypto.

In addition to sizing, it provides a "Volatility Weather Report," comparing current market conditions to historical averages to help you decide if the market environment is currently high-risk or optimal.

Key Features
1. Triple-Timeframe Analysis
The table provides a bird's-eye view of volatility across three distinct layers:

Current Timeframe: Real-time sizing based on your active chart.

Custom Timeframe: A selectable higher timeframe (e.g., 1H or 4H) to help you align your risk with macro trends.

Daily Context: A deep dive into the daily range to see how "today" compares to the monthly average.

2. Smart "Vol Status" Context
Stop trading in the dark. The indicator calculates an ATR Relative Ratio to categorize the market:

LOW VOL (Blue): Market is tightening; watch for breakouts but beware of "chop."

NORMAL (Green): Volatility is within historical norms; standard strategy parameters apply.

HIGH VOL (Orange): Volatility is 20%+ above average; expect violent swings and consider reducing size.

3. Multi-Asset Logic
Built-in syminfo.pointvalue detection means you don't have to change settings when switching from ES (Futures) to EURUSD (Forex) or NVDA (Stocks). The math adjusts itself automatically.

How to Read the Table
Stop Distance: The physical distance of your stop loss based on your ATR multiplier.

Suggested Size: The exact number of units/contracts to trade to maintain your fixed dollar risk (e.g., $100 per trade).

% of Price: Shows the Daily ATR as a percentage of the asset's price. This helps you understand the "personality" and relative risk of the ticker.

Settings
ATR Settings: Customize the length and multiplier.

Custom TF: Set your preferred higher timeframe for secondary sizing.

Risk Amount: Enter the total dollar amount you are willing to lose if your stop is hit.

Round Down: A must-have for Futures and Stocks to ensure you never accidentally over-leverage due to fractional math.

Disclaimer: This indicator is a tool to assist in risk calculation. Always verify your position size with your broker's margin requirements before entering a trade.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Terrinca

//@version=5
indicator("Universal ATR Quad-Sizer + VIX Context", overlay=true)

// --- Inputs ---
atrLength   = input.int(14, title="ATR Length", group="ATR Settings")
multiplier  = input.float(1.5, title="ATR Multiplier", step=0.1, group="ATR Settings")
customTF    = input.timeframe("60", title="Custom TF", group="ATR Settings")
maLength    = input.int(20, title="Volatility Avg Length", group="ATR Settings")

riskAmount  = input.float(100.0, title="Risk Amount ($)", minval=1.0, group="Risk Settings")
roundDown   = input.bool(true, title="Round Down", group="Risk Settings")

boxColor    = input.color(color.new(color.black, 20), title="Background", group="UI")
txtColor    = input.color(color.white, title="Text Color", group="UI")

// --- Calculations ---
pointValue = syminfo.pointvalue
atrBase    = ta.atr(atrLength)

// Sizing Function
f_calcSize(_atr) =>
    _stopDist = _atr * multiplier
    _size = _stopDist > 0 ? riskAmount / (_stopDist * pointValue) : 0
    [_stopDist, roundDown ? math.floor(_size) : _size]

// 1. Current & Custom Sizing
[curStop, curSize]   = f_calcSize(atrBase)
customAtr            = request.security(syminfo.tickerid, customTF, atrBase)
[custStop, custSize] = f_calcSize(customAtr)

// 2. Daily Context Logic
[dailyAtr, dailyAvg] = request.security(syminfo.tickerid, "D", [ta.atr(atrLength), ta.sma(ta.atr(atrLength), maLength)])
atrRelativeRatio     = dailyAtr / dailyAvg 

// 3. VIX Logic (External Data)
vixValue = request.security("CBOE:VIX", "D", close)
vixColor = vixValue > 25 ? color.new(color.red, 30) : vixValue > 15 ? color.new(color.orange, 30) : color.new(color.green, 40)
vixStatus = vixValue > 25 ? "FEAR" : vixValue > 15 ? "ALERT" : "CALM"

// --- Table UI (6 Rows, 3 Columns) ---
var table atrTable = table.new(position.top_right, 3, 6, border_width = 1, frame_color=color.new(color.gray, 50))

if barstate.islast
    table.cell(atrTable, 0, 0, "Volatility Source", bgcolor=color.gray, text_color=txtColor)
    table.cell(atrTable, 1, 0, "Stop / Value", bgcolor=color.gray, text_color=txtColor)
    table.cell(atrTable, 2, 0, "Size / Status", bgcolor=color.gray, text_color=txtColor)

    // Row 1: Current TF
    table.cell(atrTable, 0, 1, "Current (" + timeframe.period + ")", bgcolor=boxColor, text_color=txtColor, text_halign=text.align_left)
    table.cell(atrTable, 1, 1, str.tostring(curStop, format.mintick), bgcolor=boxColor, text_color=txtColor)
    table.cell(atrTable, 2, 1, str.tostring(curSize, "#.###"), bgcolor=color.new(color.blue, 40), text_color=txtColor)

    // Row 2: Custom TF
    table.cell(atrTable, 0, 2, "Custom (" + customTF + ")", bgcolor=boxColor, text_color=txtColor, text_halign=text.align_left)
    table.cell(atrTable, 1, 2, str.tostring(custStop, format.mintick), bgcolor=boxColor, text_color=txtColor)
    table.cell(atrTable, 2, 2, str.tostring(custSize, "#.###"), bgcolor=color.new(color.blue, 60), text_color=txtColor)

    // Row 3: Daily Context (Asset Specific)
    volStatus = atrRelativeRatio > 1.2 ? "HIGH" : atrRelativeRatio < 0.8 ? "LOW" : "NORMAL"
    table.cell(atrTable, 0, 3, "Asset Vol (D)", bgcolor=boxColor, text_color=txtColor, text_halign=text.align_left)
    table.cell(atrTable, 1, 3, str.tostring(dailyAtr, format.mintick), bgcolor=boxColor, text_color=txtColor)
    table.cell(atrTable, 2, 3, volStatus + " (" + str.tostring(atrRelativeRatio, "0.00") + "x)", bgcolor=color.new(color.gray, 50), text_color=txtColor)

    // Row 4: Market VIX (Fear Index)
    table.cell(atrTable, 0, 4, "Market VIX", bgcolor=boxColor, text_color=txtColor, text_halign=text.align_left)
    table.cell(atrTable, 1, 4, str.tostring(vixValue, "#.##"), bgcolor=boxColor, text_color=txtColor)
    table.cell(atrTable, 2, 4, vixStatus, bgcolor=vixColor, text_color=txtColor)
````
