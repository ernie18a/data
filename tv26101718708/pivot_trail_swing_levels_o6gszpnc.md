# Pivot Trail - Swing Levels

- url: https://www.tradingview.com/script/o6gSzPnc-Pivot-Trail-Swing-Levels/
- type: indicator
- pine_id: PUB;7d4567b317114a07977d49d852dc9944
- version: 1.0

## Description

PIVOT TRAIL - SWING LEVELS

Pivot Trail plots confirmed swing highs and swing lows as dotted horizontal levels that follow price. It also shows how often swings tend to form on your chart.

HOW IT WORKS
A swing high is a bar whose high is the highest among the chosen number of bars on both sides of it. A swing low is the same idea for lows. Each swing is confirmed only after those bars have closed, so confirmed levels never repaint.

Each level starts at the actual pivot candle, not the candle where it was confirmed. It then holds until the next swing of the same type forms. A short live segment keeps the newest level reaching the current bar.

FEATURES
- Red dotted trail for swing highs, cyan dotted trail for swing lows
- Separate strength settings for highs and lows
- Selectable source for each side (default: High for highs, Low for lows)
- Info table showing the average number of bars between two consecutive swing highs and two consecutive swing lows
- Table can sit on the left or right side of the chart

SETTINGS
- Swing high strength (default 11): bars required on each side to confirm a swing high
- Swing low strength (default 5): bars required on each side to confirm a swing low
- Swing high source / Swing low source: price series used for detection
- Show Info Table: turns the table on or off
- Table Position: Left Side or Right Side

HOW TO USE
- Treat the levels as support and resistance zones: swing highs often act as resistance, swing lows as support.
- A close beyond a level can point to a break of structure or a trend change.
- Use the table to gauge swing rhythm. A high average means slower, wider swings; a low average means faster, tighter ones.
- Higher strength values give fewer, more significant swings. Lower values give more frequent, more sensitive ones.

NOTES
- Swings are confirmed with a delay equal to the strength setting, which is how pivots avoid repainting.
- Works on any symbol and timeframe.
- This is a charting tool, not financial advice. Always combine it with your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator("Pivot Trail - Swing Levels", shorttitle="Pivot Trail", overlay=true)

// ───────────── Inputs ─────────────
highLen   = input.int(11, "Swing high strength", minval=1)
lowLen    = input.int(5,  "Swing low strength",  minval=1)
highSrc   = input.source(high, "Swing high source")
lowSrc    = input.source(low,  "Swing low source")
showTable = input.bool(true, "Show Info Table")
tablePosS = input.string("Left Side", "Table Position", options=["Left Side", "Right Side"])

// ───────────── Pivot detection ─────────────
// A pivot is confirmed `strength` bars after it forms.
ph = ta.pivothigh(highSrc, highLen, highLen)
pl = ta.pivotlow(lowSrc, lowLen, lowLen)

// Hold the latest confirmed level until the next pivot of the same type appears
var float swingHigh = na
var float swingLow  = na
if not na(ph)
    swingHigh := ph
if not na(pl)
    swingLow := pl

// ───────────── Average bars between swings ─────────────
var int   lastHiIdx = na
var int   lastLoIdx = na
var float hiSum = 0.0
var float loSum = 0.0
var int   hiCnt = 0
var int   loCnt = 0

if not na(ph)
    hiIdx = bar_index - highLen
    if not na(lastHiIdx)
        hiSum += hiIdx - lastHiIdx
        hiCnt += 1
    lastHiIdx := hiIdx

if not na(pl)
    loIdx = bar_index - lowLen
    if not na(lastLoIdx)
        loSum += loIdx - lastLoIdx
        loCnt += 1
    lastLoIdx := loIdx

avgHigh = hiCnt > 0 ? math.round(hiSum / hiCnt) : na
avgLow  = loCnt > 0 ? math.round(loSum / loCnt) : na

// ───────────── Plots ─────────────
// Offset plots start each level at the actual pivot bar (not the confirmation bar).
// The non-offset plots only fill the last few bars so the live level reaches the current bar.
highColor = #F23645
lowColor  = #00BCD4

nearEnd(len) => bar_index > last_bar_index - len

plot(swingHigh, "Swing High", color=highColor, style=plot.style_circles, linewidth=2, offset=-highLen)
plot(nearEnd(highLen) ? swingHigh : na, "Swing High (live)", color=highColor, style=plot.style_circles, linewidth=2)
plot(swingLow, "Swing Low", color=lowColor, style=plot.style_circles, linewidth=2, offset=-lowLen)
plot(nearEnd(lowLen) ? swingLow : na, "Swing Low (live)", color=lowColor, style=plot.style_circles, linewidth=2)

// ───────────── Info table ─────────────
tablePos = tablePosS == "Left Side" ? position.middle_left : position.middle_right
var table infoTable = table.new(tablePos, 2, 3, border_width=1, border_color=color.white)

if barstate.islast and showTable
    table.cell(infoTable, 0, 0, "Avg bars between 2", text_color=color.white, bgcolor=color.new(#6C8CFF, 15), text_halign=text.align_left, text_size=size.small)
    table.merge_cells(infoTable, 0, 0, 1, 0)
    table.cell(infoTable, 0, 1, "swing high", text_color=color.black, bgcolor=color.new(#FF8A8A, 20), text_halign=text.align_left, text_size=size.small)
    table.cell(infoTable, 1, 1, na(avgHigh) ? "-" : str.tostring(avgHigh), text_color=color.black, bgcolor=color.new(#FF8A8A, 40), text_size=size.small)
    table.cell(infoTable, 0, 2, "swing low", text_color=color.black, bgcolor=color.new(#8AF08A, 20), text_halign=text.align_left, text_size=size.small)
    table.cell(infoTable, 1, 2, na(avgLow) ? "-" : str.tostring(avgLow), text_color=color.black, bgcolor=color.new(#8AF08A, 40), text_size=size.small)
````
