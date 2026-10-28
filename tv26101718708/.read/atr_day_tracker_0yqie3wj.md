# ATR Day Tracker

- url: https://www.tradingview.com/script/0YQIE3WJ-ATR-Day-Tracker/
- type: indicator
- pine_id: PUB;3a278db25d2a41019ddc4796dbfb1d71
- version: 1.0

## Description

This indicator displays a small box on your chart with three daily metrics: the daily ATR (default 14-period), how much of that range has been Used so far today (current day's high minus low, with the percentage of ATR consumed), and how much range is Left (ATR minus used, floored at zero). The box position, text size, and colors are all configurable. It's a context gauge for how much of a typical day's move has already played out.

## Source Code

````pine
//@version=6
indicator("ATR Day Tracker", overlay=true)

// --- Inputs ---
atrLen      = input.int(14, "ATR Length", minval=1)
atrTf       = input.timeframe("D", "ATR Timeframe")
boxPos      = input.string("Top Right", "Box Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"])
txtSize     = input.string("Normal", "Text Size", options=["Tiny","Small","Normal","Large","Huge"])
bgCol       = input.color(color.new(color.black, 10), "Box Background")
txtCol      = input.color(color.white, "Text Color")
usedCol     = input.color(color.orange, "Used Color")
leftCol     = input.color(color.lime, "Left Color")

// --- ATR on chosen timeframe (daily by default) ---
atrVal = request.security(syminfo.tickerid, atrTf, ta.atr(atrLen))

// --- Today's range used (high - low of current day) ---
dayHigh = request.security(syminfo.tickerid, "D", high)
dayLow  = request.security(syminfo.tickerid, "D", low)
usedRange = dayHigh - dayLow

// --- Range left for the day (cannot go below 0) ---
leftRange = math.max(atrVal - usedRange, 0)
usedPct   = atrVal > 0 ? (usedRange / atrVal) * 100 : 0

// --- Position mapping ---
pos = boxPos == "Top Right" ? position.top_right : boxPos == "Top Left" ? position.top_left : boxPos == "Bottom Right" ? position.bottom_right : boxPos == "Bottom Left" ? position.bottom_left : boxPos == "Middle Right" ? position.middle_right : position.middle_left

sz = txtSize == "Tiny" ? size.tiny : txtSize == "Small" ? size.small : txtSize == "Normal" ? size.normal : txtSize == "Large" ? size.large : size.huge

// --- Table ---
var table t = table.new(pos, 2, 4, bgcolor=bgCol, border_width=1, border_color=color.new(color.gray, 50))

if barstate.islast
    table.cell(t, 0, 0, "ATR ("+str.tostring(atrLen)+")", text_color=txtCol, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 0, str.tostring(atrVal, format.mintick), text_color=txtCol, text_size=sz, text_halign=text.align_right)

    table.cell(t, 0, 1, "Used", text_color=usedCol, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 1, str.tostring(usedRange, format.mintick)+"  ("+str.tostring(usedPct, "#.0")+"%)", text_color=usedCol, text_size=sz, text_halign=text.align_right)

    table.cell(t, 0, 2, "Left", text_color=leftCol, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 2, str.tostring(leftRange, format.mintick), text_color=leftCol, text_size=sz, text_halign=text.align_right)
````
