# Level Markers - Disconnected By Lincoln Khan (V5)

- url: https://www.tradingview.com/script/V4XFQquy-Level-Markers-Disconnected-By-Lincoln-Khan-V5/
- type: indicator
- pine_id: PUB;89d5e576bbb9495f86f1b7566e1634ff
- version: 2.0

## Description

Overview
This TradingView Pine Script indicator displays 6 key intraday price levels commonly used by ES (E-mini S&P 500) and NQ (E-mini Nasdaq 100) day traders. Each level is a separate horizontal line that appears only during its designated time window, then disappears at day's end.

## Source Code

````pine
//@version=5
indicator("Level Markers - Disconnected", overlay=true)

// ─────────────────────────────
// SESSION TOGGLE INPUTS
// ─────────────────────────────
showPremarket = input.bool(defval=true, title="Show Premarket Session")
showFirstThirty = input.bool(defval=true, title="Show First 30 Minutes")
showInitialBalance = input.bool(defval=true, title="Show Initial Balance (1 Hour)")
showPrevDay = input.bool(defval=true, title="Show Previous Day Levels")

// ─────────────────────────────
// COLOR INPUTS
// ─────────────────────────────
pmHighColor = input.color(defval=color.rgb(255, 0, 127), title="Premarket High Color")
pmLowColor = input.color(defval=color.rgb(255, 0, 127), title="Premarket Low Color")
orHighColor = input.color(defval=color.rgb(255, 255, 255), title="First 30 Minutes High Color")
orLowColor = input.color(defval=color.rgb(255, 255, 255), title="First 30 Minutes Low Color")
ibHighColor = input.color(defval=color.rgb(255, 255, 0), title="Initial Balance (1 Hour) High Color")
ibLowColor = input.color(defval=color.rgb(255, 255, 0), title="Initial Balance (1 Hour) Low Color")
prevDayHighColor = input.color(defval=color.rgb(255, 0, 0), title="Previous Day High Color")
prevDayLowColor = input.color(defval=color.rgb(255, 0, 0), title="Previous Day Low Color")

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
inExtendedHours = not na(time(timeframe.period, "1600-2000"))
inOpeningRange = not na(time(timeframe.period, "0930-1000"))
inInitialBalance = not na(time(timeframe.period, "0930-1030"))
inTradingHours = not na(time(timeframe.period, "0930-1600"))

// Premarket + After-hours combined
inPremarketExtended = inPremarket or inExtendedHours

// ─────────────────────────────
// PREMARKET HIGH/LOW (4:00 AM - 9:30 AM + 4:00 PM - 8:00 PM After-Hours)
// ─────────────────────────────
var float pmHigh = 0.0
var float pmLow = 0.0

if ta.change(time("D"))
    pmHigh := 0.0
    pmLow := 0.0

if inPremarketExtended
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
// LINE LABEL OBJECTS
// ─────────────────────────────
var label pmHighLabel = na
var label pmLowLabel = na
var label orHighLabel = na
var label orLowLabel = na
var label ibHighLabel = na
var label ibLowLabel = na
var label prevDayHighLabel = na
var label prevDayLowLabel = na

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
// CREATE PREMARKET LINES (Extends right only, starts at post-market)
// ─────────────────────────────
if showPremarket and inPremarketExtended and na(pmHighLine)
    pmHighLine := line.new(bar_index, pmHigh, bar_index + 500, pmHigh, extend=extend.right, color=pmHighColor, width=pmHighWidth, style=getLineStyle(pmHighStyle))
    pmHighLabel := label.new(bar_index, pmHigh, "PreM-H", xloc=xloc.bar_index, yloc=yloc.price, color=pmHighColor, textcolor=color.black, style=label.style_label_right, size=size.small)
    pmLowLine := line.new(bar_index, pmLow, bar_index + 500, pmLow, extend=extend.right, color=pmLowColor, width=pmLowWidth, style=getLineStyle(pmLowStyle))
    pmLowLabel := label.new(bar_index, pmLow, "PreM-L", xloc=xloc.bar_index, yloc=yloc.price, color=pmLowColor, textcolor=color.black, style=label.style_label_right, size=size.small)

if showPremarket and inPremarketExtended and not na(pmHighLine)
    line.set_y1(pmHighLine, pmHigh)
    line.set_y2(pmHighLine, pmHigh)
    label.set_y(pmHighLabel, pmHigh)
    line.set_y1(pmLowLine, pmLow)
    line.set_y2(pmLowLine, pmLow)
    label.set_y(pmLowLabel, pmLow)

// Keep premarket lines visible all day
if showPremarket and not na(pmHighLine)
    line.set_extend(pmHighLine, extend.right)
if showPremarket and not na(pmLowLine)
    line.set_extend(pmLowLine, extend.right)

// Delete premarket lines at day change
if ta.change(time("D")) and not na(pmHighLine)
    line.delete(pmHighLine)
    label.delete(pmHighLabel)
    line.delete(pmLowLine)
    label.delete(pmLowLabel)
    pmHighLine := na
    pmHighLabel := na
    pmLowLine := na
    pmLowLabel := na

// Delete premarket lines if toggled off
if not showPremarket and not na(pmHighLine)
    line.delete(pmHighLine)
    label.delete(pmHighLabel)
    line.delete(pmLowLine)
    label.delete(pmLowLabel)
    pmHighLine := na
    pmHighLabel := na
    pmLowLine := na
    pmLowLabel := na

// ─────────────────────────────
// CREATE OPENING RANGE LINES (First 30 Minutes)
// ─────────────────────────────
if showFirstThirty and inOpeningRange and na(orHighLine)
    orHighLine := line.new(bar_index, orHigh, bar_index + 500, orHigh, extend=extend.right, color=orHighColor, width=orHighWidth, style=getLineStyle(orHighStyle))
    orHighLabel := label.new(bar_index, orHigh, "30M-H", xloc=xloc.bar_index, yloc=yloc.price, color=orHighColor, textcolor=color.black, style=label.style_label_right, size=size.small)
    orLowLine := line.new(bar_index, orLow, bar_index + 500, orLow, extend=extend.right, color=orLowColor, width=orLowWidth, style=getLineStyle(orLowStyle))
    orLowLabel := label.new(bar_index, orLow, "30M-L", xloc=xloc.bar_index, yloc=yloc.price, color=orLowColor, textcolor=color.black, style=label.style_label_right, size=size.small)

if showFirstThirty and inOpeningRange and not na(orHighLine)
    line.set_y1(orHighLine, orHigh)
    line.set_y2(orHighLine, orHigh)
    label.set_y(orHighLabel, orHigh)
    line.set_y1(orLowLine, orLow)
    line.set_y2(orLowLine, orLow)
    label.set_y(orLowLabel, orLow)

// Delete opening range lines at day change (don't carry to next day)
if ta.change(time("D")) and not na(orHighLine)
    line.delete(orHighLine)
    label.delete(orHighLabel)
    line.delete(orLowLine)
    label.delete(orLowLabel)
    orHighLine := na
    orHighLabel := na
    orLowLine := na
    orLowLabel := na

// Delete opening range lines if toggled off
if not showFirstThirty and not na(orHighLine)
    line.delete(orHighLine)
    label.delete(orHighLabel)
    line.delete(orLowLine)
    label.delete(orLowLabel)
    orHighLine := na
    orHighLabel := na
    orLowLine := na
    orLowLabel := na

// ─────────────────────────────
// CREATE INITIAL BALANCE LINES (First Hour: 9:30-10:30 AM)
// ─────────────────────────────
if showInitialBalance and inInitialBalance and na(ibHighLine)
    ibHighLine := line.new(bar_index, ibHigh, bar_index + 500, ibHigh, extend=extend.right, color=ibHighColor, width=ibHighWidth, style=getLineStyle(ibHighStyle))
    ibHighLabel := label.new(bar_index, ibHigh, "1Hr-H", xloc=xloc.bar_index, yloc=yloc.price, color=ibHighColor, textcolor=color.black, style=label.style_label_right, size=size.small)
    ibLowLine := line.new(bar_index, ibLow, bar_index + 500, ibLow, extend=extend.right, color=ibLowColor, width=ibLowWidth, style=getLineStyle(ibLowStyle))
    ibLowLabel := label.new(bar_index, ibLow, "1Hr-L", xloc=xloc.bar_index, yloc=yloc.price, color=ibLowColor, textcolor=color.black, style=label.style_label_right, size=size.small)

if showInitialBalance and inInitialBalance and not na(ibHighLine)
    line.set_y1(ibHighLine, ibHigh)
    line.set_y2(ibHighLine, ibHigh)
    label.set_y(ibHighLabel, ibHigh)
    line.set_y1(ibLowLine, ibLow)
    line.set_y2(ibLowLine, ibLow)
    label.set_y(ibLowLabel, ibLow)

// Delete initial balance lines at day change
if ta.change(time("D")) and not na(ibHighLine)
    line.delete(ibHighLine)
    label.delete(ibHighLabel)
    line.delete(ibLowLine)
    label.delete(ibLowLabel)
    ibHighLine := na
    ibHighLabel := na
    ibLowLine := na
    ibLowLabel := na

// Delete initial balance lines if toggled off
if not showInitialBalance and not na(ibHighLine)
    line.delete(ibHighLine)
    label.delete(ibHighLabel)
    line.delete(ibLowLine)
    label.delete(ibLowLabel)
    ibHighLine := na
    ibHighLabel := na
    ibLowLine := na
    ibLowLabel := na

// ─────────────────────────────
// CREATE PREVIOUS DAY LINES (Extends right only, stops at previous day)
// ─────────────────────────────
if showPrevDay and inTradingHours and na(prevDayHighLine)
    prevDayHighLine := line.new(bar_index, prevDayHigh, bar_index + 500, prevDayHigh, extend=extend.right, color=prevDayHighColor, width=prevDayHighWidth, style=getLineStyle(prevDayHighStyle))
    prevDayHighLabel := label.new(bar_index, prevDayHigh, "PreD-H", xloc=xloc.bar_index, yloc=yloc.price, color=prevDayHighColor, textcolor=color.black, style=label.style_label_right, size=size.small)
    prevDayLowLine := line.new(bar_index, prevDayLow, bar_index + 500, prevDayLow, extend=extend.right, color=prevDayLowColor, width=prevDayLowWidth, style=getLineStyle(prevDayLowStyle))
    prevDayLowLabel := label.new(bar_index, prevDayLow, "PreD-L", xloc=xloc.bar_index, yloc=yloc.price, color=prevDayLowColor, textcolor=color.black, style=label.style_label_right, size=size.small)

// Keep previous day lines visible all day and update label positions
if showPrevDay and inTradingHours and not na(prevDayHighLine)
    line.set_extend(prevDayHighLine, extend.right)
    line.set_y1(prevDayHighLine, prevDayHigh)
    line.set_y2(prevDayHighLine, prevDayHigh)
    label.set_y(prevDayHighLabel, prevDayHigh)
if showPrevDay and inTradingHours and not na(prevDayLowLine)
    line.set_extend(prevDayLowLine, extend.right)
    line.set_y1(prevDayLowLine, prevDayLow)
    line.set_y2(prevDayLowLine, prevDayLow)
    label.set_y(prevDayLowLabel, prevDayLow)

// Delete previous day lines at day change
if ta.change(time("D")) and not na(prevDayHighLine)
    line.delete(prevDayHighLine)
    label.delete(prevDayHighLabel)
    line.delete(prevDayLowLine)
    label.delete(prevDayLowLabel)
    prevDayHighLine := na
    prevDayHighLabel := na
    prevDayLowLine := na
    prevDayLowLabel := na

// Delete previous day lines if toggled off
if not showPrevDay and not na(prevDayHighLine)
    line.delete(prevDayHighLine)
    label.delete(prevDayHighLabel)
    line.delete(prevDayLowLine)
    label.delete(prevDayLowLabel)
    prevDayHighLine := na
    prevDayHighLabel := na
    prevDayLowLine := na
    prevDayLowLabel := na
````
