# MES 5-Min ORB

- url: https://www.tradingview.com/script/CZamnoZS-MES-5-Min-ORB/
- type: indicator
- pine_id: PUB;86992cda27a347db9570a263c5d44c8b
- version: 1.0

## Description

yolo. built using edgeful data. this is my first script, don't trust me

## Source Code

````pine
//@version=5
indicator("MES 5-Min ORB", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
maxORBPct    = input.float(0.55, "Max ORB Size (%)", step=0.01) / 100
tpMulti      = input.float(0.50, "Profit Target (% of ORB)", step=0.05)
slMulti      = input.float(1.00, "Stop Loss (% of ORB)",     step=0.05)
maxDollarLoss= input.float(700,  "Max Dollar Loss ($)")
sessionStart = input.session("0930-1600", "Session")

// ─────────────────────────────────────────
// SESSION & TIME LOGIC
// ─────────────────────────────────────────
isNewDay     = ta.change(time("D")) != 0
isTuesday    = dayofweek == dayofweek.tuesday

// 09:30 candle = first 5-min candle of the session
orbTime      = time("5", "0930-0935")
isORBCandle  = not na(orbTime)

// ─────────────────────────────────────────
// ORB HIGH / LOW — captured from 09:30–09:35 candle
// ─────────────────────────────────────────
var float orbHigh = na
var float orbLow  = na
var bool  orbSet  = false

if isNewDay
    orbHigh := na
    orbLow  := na
    orbSet  := false

if isORBCandle
    orbHigh := high
    orbLow  := low
    orbSet  := true

// ─────────────────────────────────────────
// ORB SIZE FILTER (0.55% of price)
// ─────────────────────────────────────────
orbSize      = orbHigh - orbLow
orbPct       = orbSize / orbLow
orbValid     = orbPct <= maxORBPct

// ─────────────────────────────────────────
// ENTRY CONDITIONS
// First candle AFTER the ORB that closes outside the range
// ─────────────────────────────────────────
afterORB     = orbSet and na(orbTime)  // ORB is set but current bar is not the ORB candle
inSession    = not na(time("5", "0935-1600"))

longSignal   = afterORB and inSession and orbValid and
               close > orbHigh and close[1] <= orbHigh and
               not isTuesday

shortSignal  = afterORB and inSession and orbValid and
               close < orbLow and close[1] >= orbLow

// ─────────────────────────────────────────
// LEVELS (TP & SL per trade)
// ─────────────────────────────────────────
longTP  = longSignal  ? close + (orbSize * tpMulti) : na
longSL  = longSignal  ? close - (orbSize * slMulti) : na
shortTP = shortSignal ? close - (orbSize * tpMulti) : na
shortSL = shortSignal ? close + (orbSize * slMulti) : na

// ─────────────────────────────────────────
// DRAW ORB HIGH / LOW LINES (extend across the day)
// ─────────────────────────────────────────
var line lineHigh = na
var line lineLow  = na

// Redraw lines when ORB is freshly set
orbJustSet = isORBCandle and not isORBCandle[1]

if orbJustSet
    if not na(lineHigh)
        line.delete(lineHigh)
    if not na(lineLow)
        line.delete(lineLow)
    lineHigh := line.new(bar_index, orbHigh, bar_index + 200, orbHigh,
                         color=color.new(color.aqua, 0), width=1, style=line.style_dashed, extend=extend.right)
    lineLow  := line.new(bar_index, orbLow,  bar_index + 200, orbLow,
                         color=color.new(color.orange, 0), width=1, style=line.style_dashed, extend=extend.right)

// ─────────────────────────────────────────
// SIGNAL ARROWS
// ─────────────────────────────────────────
plotshape(longSignal,  title="Long Entry",  location=location.belowbar, style=shape.triangleup,
          color=color.new(color.lime, 0), size=size.small, text="LONG")
plotshape(shortSignal, title="Short Entry", location=location.abovebar, style=shape.triangledown,
          color=color.new(color.red, 0),  size=size.small, text="SHORT")

// ─────────────────────────────────────────
// TP / SL LABELS ON SIGNAL BARS
// ─────────────────────────────────────────
if longSignal
    label.new(bar_index, longTP, "TP: " + str.tostring(math.round(longTP, 2)),
              color=color.new(color.lime, 80), textcolor=color.white, style=label.style_label_down, size=size.small)
    label.new(bar_index, longSL, "SL: " + str.tostring(math.round(longSL, 2)),
              color=color.new(color.red, 80), textcolor=color.white, style=label.style_label_up, size=size.small)

if shortSignal
    label.new(bar_index, shortTP, "TP: " + str.tostring(math.round(shortTP, 2)),
              color=color.new(color.lime, 80), textcolor=color.white, style=label.style_label_up, size=size.small)
    label.new(bar_index, shortSL, "SL: " + str.tostring(math.round(shortSL, 2)),
              color=color.new(color.red, 80), textcolor=color.white, style=label.style_label_down, size=size.small)

// ─────────────────────────────────────────
// INFO TABLE — shows ORB stats on current day
// ─────────────────────────────────────────
var table infoTable = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 70), border_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "ORB High",  text_color=color.aqua,   text_size=size.small)
    table.cell(infoTable, 1, 0, orbSet ? str.tostring(math.round(orbHigh, 2)) : "—", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 1, "ORB Low",   text_color=color.orange, text_size=size.small)
    table.cell(infoTable, 1, 1, orbSet ? str.tostring(math.round(orbLow, 2)) : "—",  text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 2, "ORB Size",  text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 1, 2, orbSet ? str.tostring(math.round(orbSize, 2)) : "—", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 3, "ORB Valid", text_color=color.gray,   text_size=size.small)
    table.cell(infoTable, 1, 3, orbSet ? (orbValid ? "✓ YES" : "✗ TOO WIDE") : "—",
               text_color=orbValid ? color.lime : color.red, text_size=size.small)
````
