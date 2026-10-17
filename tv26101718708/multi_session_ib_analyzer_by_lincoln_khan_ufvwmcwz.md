# Multi Session IB Analyzer By Lincoln Khan

- url: https://www.tradingview.com/script/UfVwMCwz-Multi-Session-IB-Analyzer-By-Lincoln-Khan/
- type: indicator
- pine_id: PUB;f454fad7039d43d29a2e0a5e86b33764
- version: 1.0

## Description

[b]Multi Session IB Analyzer[/b]
A comprehensive TradingView indicator designed for ES and NQ day traders. This tool tracks and displays 8 key price levels across multiple trading sessions:
Premarket Session (4:00-9:30 AM) - Orange lines marking premarket high and low
First 30 Minutes (9:30-10:00 AM) - White lines capturing opening range breakout levels
Initial Balance - 1 Hour (9:30-10:30 AM) - Yellow lines defining the first hour range
Previous Day Levels - Red lines showing yesterday's high and low for support/resistance
Key Features:

Fully customizable colors, line width, and styles (solid/dashed/dotted)
Each level displays only during its time window, then auto-resets daily
Perfect for breakout trading, liquidity sweep identification, and mean reversion strategies
Clean, disconnected lines with no carryover between days

Ideal For: Day traders, scalpers, and backtesting strategies using session-based price action.

## Source Code

````pine
//@version=5
indicator("Level Markers - Disconnected", overlay=true)

// ─────────────────────────────
// COLOR INPUTS
// ─────────────────────────────
pmHighColor = input.color(defval=color.new(color.orange, 0), title="Premarket High Color")
pmLowColor = input.color(defval=color.new(color.orange, 0), title="Premarket Low Color")
orHighColor = input.color(defval=color.new(color.white, 0), title="First 30 Minutes High Color")
orLowColor = input.color(defval=color.new(color.white, 0), title="First 30 Minutes Low Color")
ibHighColor = input.color(defval=color.new(color.yellow, 0), title="Initial Balance (1 Hour) High Color")
ibLowColor = input.color(defval=color.new(color.yellow, 0), title="Initial Balance (1 Hour) Low Color")
prevDayHighColor = input.color(defval=color.new(color.red, 0), title="Previous Day High Color")
prevDayLowColor = input.color(defval=color.new(color.red, 0), title="Previous Day Low Color")

// ─────────────────────────────
// LINE WIDTH INPUTS
// ─────────────────────────────
pmHighWidth = input.int(defval=2, title="Premarket High Width", minval=1, maxval=5)
pmLowWidth = input.int(defval=2, title="Premarket Low Width", minval=1, maxval=5)
orHighWidth = input.int(defval=2, title="First 30 Minutes High Width", minval=1, maxval=5)
orLowWidth = input.int(defval=2, title="First 30 Minutes Low Width", minval=1, maxval=5)
ibHighWidth = input.int(defval=2, title="Initial Balance High Width", minval=1, maxval=5)
ibLowWidth = input.int(defval=2, title="Initial Balance Low Width", minval=1, maxval=5)
prevDayHighWidth = input.int(defval=2, title="Previous Day High Width", minval=1, maxval=5)
prevDayLowWidth = input.int(defval=2, title="Previous Day Low Width", minval=1, maxval=5)

// ─────────────────────────────
// LINE STYLE INPUTS
// ─────────────────────────────
pmHighStyle = input.string(defval="Solid", title="Premarket High Style", options=["Solid", "Dashed", "Dotted"])
pmLowStyle = input.string(defval="Solid", title="Premarket Low Style", options=["Solid", "Dashed", "Dotted"])
orHighStyle = input.string(defval="Solid", title="First 30 Minutes High Style", options=["Solid", "Dashed", "Dotted"])
orLowStyle = input.string(defval="Solid", title="First 30 Minutes Low Style", options=["Solid", "Dashed", "Dotted"])
ibHighStyle = input.string(defval="Solid", title="Initial Balance High Style", options=["Solid", "Dashed", "Dotted"])
ibLowStyle = input.string(defval="Solid", title="Initial Balance Low Style", options=["Solid", "Dashed", "Dotted"])
prevDayHighStyle = input.string(defval="Solid", title="Previous Day High Style", options=["Solid", "Dashed", "Dotted"])
prevDayLowStyle = input.string(defval="Solid", title="Previous Day Low Style", options=["Solid", "Dashed", "Dotted"])

// ─────────────────────────────
// CONVERT STYLE STRING TO LINE STYLE
// ─────────────────────────────
getLineStyle(styleStr) =>
    styleStr == "Dashed" ? line.style_dashed : styleStr == "Dotted" ? line.style_dotted : line.style_solid

// ─────────────────────────────
// GET PREVIOUS DAY HIGH/LOW
// ─────────────────────────────
prevDayHigh = request.security(syminfo.tickerid, "D", high[1])
prevDayLow = request.security(syminfo.tickerid, "D", low[1])

// ─────────────────────────────
// SESSION DETECTION (using chart's native time, no offset needed)
// ─────────────────────────────
inPremarket = not na(time(timeframe.period, "0400-0930"))
inOpeningRange = not na(time(timeframe.period, "0930-1000"))
inInitialBalance = not na(time(timeframe.period, "0930-1030"))
inTradingHours = not na(time(timeframe.period, "0930-1600"))

// ─────────────────────────────
// PREMARKET HIGH/LOW (4:00 AM - 9:30 AM)
// ─────────────────────────────
var float pmHigh = 0.0
var float pmLow = 0.0

if ta.change(time("D"))
    pmHigh := 0.0
    pmLow := 0.0

if inPremarket
    pmHigh := pmHigh == 0.0 ? high : math.max(pmHigh, high)
    pmLow := pmLow == 0.0 ? low : math.min(pmLow, low)

// ─────────────────────────────
// OPENING RANGE (9:30 AM - 10:00 AM)
// ─────────────────────────────
var float orHigh = 0.0
var float orLow = 0.0

if ta.change(time("D"))
    orHigh := 0.0
    orLow := 0.0

if inOpeningRange
    orHigh := orHigh == 0.0 ? high : math.max(orHigh, high)
    orLow := orLow == 0.0 ? low : math.min(orLow, low)

// ─────────────────────────────
// INITIAL BALANCE (9:30 AM - 10:30 AM - First Hour)
// ─────────────────────────────
var float ibHigh = 0.0
var float ibLow = 0.0

if ta.change(time("D"))
    ibHigh := 0.0
    ibLow := 0.0

if inInitialBalance
    ibHigh := ibHigh == 0.0 ? high : math.max(ibHigh, high)
    ibLow := ibLow == 0.0 ? low : math.min(ibLow, low)

// ─────────────────────────────
// LINE OBJECTS
// ─────────────────────────────
var line pmHighLine = na
var line pmLowLine = na
var line orHighLine = na
var line orLowLine = na
var line ibHighLine = na
var line ibLowLine = na
var line prevDayHighLine = na
var line prevDayLowLine = na

// ─────────────────────────────
// CREATE PREMARKET LINES
// ─────────────────────────────
if inPremarket and na(pmHighLine)
    pmHighLine := line.new(bar_index, pmHigh, bar_index + 500, pmHigh, extend=extend.right, color=pmHighColor, width=pmHighWidth, style=getLineStyle(pmHighStyle))
    pmLowLine := line.new(bar_index, pmLow, bar_index + 500, pmLow, extend=extend.right, color=pmLowColor, width=pmLowWidth, style=getLineStyle(pmLowStyle))

if inPremarket and not na(pmHighLine)
    line.set_y1(pmHighLine, pmHigh)
    line.set_y2(pmHighLine, pmHigh)
    line.set_y1(pmLowLine, pmLow)
    line.set_y2(pmLowLine, pmLow)

// Keep premarket lines visible all day
if not na(pmHighLine)
    line.set_extend(pmHighLine, extend.right)
if not na(pmLowLine)
    line.set_extend(pmLowLine, extend.right)

// Delete premarket lines at day change
if ta.change(time("D")) and not na(pmHighLine)
    line.delete(pmHighLine)
    line.delete(pmLowLine)
    pmHighLine := na
    pmLowLine := na

// ─────────────────────────────
// CREATE OPENING RANGE LINES
// ─────────────────────────────
if inOpeningRange and na(orHighLine)
    orHighLine := line.new(bar_index, orHigh, bar_index + 500, orHigh, extend=extend.right, color=orHighColor, width=orHighWidth, style=getLineStyle(orHighStyle))
    orLowLine := line.new(bar_index, orLow, bar_index + 500, orLow, extend=extend.right, color=orLowColor, width=orLowWidth, style=getLineStyle(orLowStyle))

if inOpeningRange and not na(orHighLine)
    line.set_y1(orHighLine, orHigh)
    line.set_y2(orHighLine, orHigh)
    line.set_y1(orLowLine, orLow)
    line.set_y2(orLowLine, orLow)

// Delete opening range lines at day change (don't carry to next day)
if ta.change(time("D")) and not na(orHighLine)
    line.delete(orHighLine)
    line.delete(orLowLine)
    orHighLine := na
    orLowLine := na

// ─────────────────────────────
// CREATE INITIAL BALANCE LINES (First Hour: 9:30-10:30 AM)
// ─────────────────────────────
if inInitialBalance and na(ibHighLine)
    ibHighLine := line.new(bar_index, ibHigh, bar_index + 500, ibHigh, extend=extend.right, color=ibHighColor, width=ibHighWidth, style=getLineStyle(ibHighStyle))
    ibLowLine := line.new(bar_index, ibLow, bar_index + 500, ibLow, extend=extend.right, color=ibLowColor, width=ibLowWidth, style=getLineStyle(ibLowStyle))

if inInitialBalance and not na(ibHighLine)
    line.set_y1(ibHighLine, ibHigh)
    line.set_y2(ibHighLine, ibHigh)
    line.set_y1(ibLowLine, ibLow)
    line.set_y2(ibLowLine, ibLow)

// Delete initial balance lines at day change
if ta.change(time("D")) and not na(ibHighLine)
    line.delete(ibHighLine)
    line.delete(ibLowLine)
    ibHighLine := na
    ibLowLine := na

// ─────────────────────────────
// CREATE PREVIOUS DAY LINES
// ─────────────────────────────
if inTradingHours and na(prevDayHighLine)
    prevDayHighLine := line.new(bar_index, prevDayHigh, bar_index + 500, prevDayHigh, extend=extend.right, color=prevDayHighColor, width=prevDayHighWidth, style=getLineStyle(prevDayHighStyle))
    prevDayLowLine := line.new(bar_index, prevDayLow, bar_index + 500, prevDayLow, extend=extend.right, color=prevDayLowColor, width=prevDayLowWidth, style=getLineStyle(prevDayLowStyle))

// Keep previous day lines visible all day
if inTradingHours and not na(prevDayHighLine)
    line.set_extend(prevDayHighLine, extend.right)
if inTradingHours and not na(prevDayLowLine)
    line.set_extend(prevDayLowLine, extend.right)

// Delete previous day lines at day change
if ta.change(time("D")) and not na(prevDayHighLine)
    line.delete(prevDayHighLine)
    line.delete(prevDayLowLine)
    prevDayHighLine := na
    prevDayLowLine := na
````
