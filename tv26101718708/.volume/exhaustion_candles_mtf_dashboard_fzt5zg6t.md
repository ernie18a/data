# Exhaustion Candles MTF Dashboard

- url: https://www.tradingview.com/script/fzt5zg6t-Exhaustion-Candles-MTF-Dashboard/
- type: indicator
- pine_id: PUB;45320faf9894442cac75dc1ff1acc60f
- version: 1.0

## Description

Exhaustion Candles (MTF) + Table

OVERVIEW
This indicator detects "exhaustion candles" — climactic bars that frequently appear where a move runs out of momentum and price reverses or stalls. It detects them on the chart timeframe and also reports the same logic across three higher timeframes (5m, 15m, 1h) in an on-chart table, so you get multi-timeframe context from a single pane.

WHAT IS AN EXHAUSTION CANDLE
An exhaustion candle represents a climactic push followed by rejection: an outsized bar on heavy participation that gets faded by the close, leaving a long wick. This script defines one precisely so the signal is objective rather than discretionary.

HOW IT WORKS (CALCULATIONS)
A bar is flagged as exhaustion only when ALL three conditions are true on that bar:
1. Range spike — the bar's range (high minus low) is greater than its average range over the lookback period multiplied by the Range Spike Multiplier. Average range = SMA(high - low, Lookback).
2. Volume spike — volume is greater than its average over the lookback period multiplied by the Volume Spike Multiplier. Average volume = SMA(volume, Lookback). This check can be disabled for symbols without reliable volume.
3. Rejection wick — the rejection wick is larger than the candle body times the Wick > Body Ratio, AND it is the dominant wick of the bar.

Direction is then assigned:
• Bullish exhaustion (potential top) = the UPPER wick is the dominant rejection wick.
• Bearish exhaustion (potential bottom) = the LOWER wick is the dominant rejection wick.

MULTI-TIMEFRAME TABLE
The same calculation is requested for the 5m, 15m and 1h timeframes and shown in a table:
• "Now" = whether that timeframe's latest bar is currently an exhaustion candle.
• "Last Signal" = the direction of the most recent exhaustion and how many bars ago it occurred (counted in that timeframe's own bars).
The table header shows a CONFIRMED / LIVE banner indicating the current data mode (see below).

CONFIRMED vs LIVE (REPAINTING) MODE
• CONFIRMED (default, non-repainting): each timeframe's value is taken from its last closed bar, so values do not change on the currently forming bar. Recommended for decisions and for honest historical behavior.
• LIVE: values reflect the still-forming higher-timeframe bar. They update in real time but can change before that bar closes. Use only as an early, tentative read.

HOW TO USE
Treat exhaustion as a context and confluence tool rather than a standalone entry. Signals are strongest when they occur into support/resistance or when multiple timeframes show exhaustion in the same direction (for example 5m aligning with 15m). Use the table for higher-timeframe context while trading a lower timeframe. Increase the range and volume multipliers and the wick-to-body ratio for fewer but stronger signals, and tune them to the symbol and timeframe you trade.

SETTINGS
• Detection: Average Lookback, Range Spike Multiplier, Volume Spike Multiplier, Wick > Body Ratio, Require Volume Spike, Non-repainting (confirmed bars only).
• Colors: separate bullish and bearish exhaustion colors for the 5m and 15m charts, plus an "Other" color set for any other timeframe.
• Table: show/hide, placement, and text size.
• Alerts: bullish exhaustion and bearish exhaustion conditions are included.

LIMITATIONS
Bar coloring can only be applied to the chart's own timeframe (a Pine Script limitation), which is why the cross-timeframe view is provided through the table. Exhaustion is a context signal and does not guarantee a reversal.

This script is published for educational purposes only and is not financial advice. Always test and manage risk before trading.

## Source Code

````pine
//@version=6
indicator("Exhaustion Candles (MTF) + Table", overlay = true)

// =============================================================
// What is an exhaustion candle?
// A climactic bar that often marks the end of a move:
//   - Large range (a spike vs the recent average range)
//   - Abnormally high volume (a volume spike)
//   - A long rejection wick (buyers/sellers exhausted)
// Bullish exhaustion (top)   = long UPPER wick rejection
// Bearish exhaustion (bottom)= long LOWER wick rejection
// =============================================================

// ---------------- Inputs: Detection ----------------
gDet       = "Detection Settings"
length     = input.int(20,  "Average Lookback",        minval = 2,  group = gDet, tooltip = "Bars used for average range & volume")
rangeMult  = input.float(1.5, "Range Spike Multiplier", minval = 1.0, step = 0.1, group = gDet)
volMult    = input.float(1.5, "Volume Spike Multiplier",minval = 1.0, step = 0.1, group = gDet)
wickRatio  = input.float(1.0, "Wick > Body Ratio",      minval = 0.1, step = 0.1, group = gDet, tooltip = "Wick must be at least this many times the body")
useVolume  = input.bool(true, "Require Volume Spike",   group = gDet, tooltip = "Disable for symbols without reliable volume")
nonRepaint = input.bool(true, "Non-repainting (confirmed bars only)", group = gDet, tooltip = "ON  = table updates only when each timeframe's bar CLOSES (reliable, no flicker).\nOFF = table shows the live, still-forming HTF bar (updates in real time but can change/repaint).")

// ---------------- Inputs: Candle Colors ----------------
// Users pick their own exhaustion candle colors here (bright defaults).
gCol         = "Exhaustion Candle Colors"
col5minBull  = input.color(#2979FF, "5 min  • Bullish",  group = gCol, inline = "5m")
col5minBear  = input.color(#00E5FF, "Bearish",           group = gCol, inline = "5m")
col15minBull = input.color(#FFEA00, "15 min • Bullish",  group = gCol, inline = "15m")
col15minBear = input.color(#FF6D00, "Bearish",           group = gCol, inline = "15m")
colOtherBull = input.color(#00E676, "Other • Bullish",   group = gCol, inline = "ot", tooltip = "Used on any timeframe that is not 5 or 15 min")
colOtherBear = input.color(#FF1744, "Bearish",           group = gCol, inline = "ot")

// ---------------- Detection logic ----------------
// Returns: 1 = bullish exhaustion (top), -1 = bearish exhaustion (bottom), 0 = none
exhaustionState() =>
    rng       = high - low
    avgRange  = ta.sma(rng, length)
    body      = math.abs(close - open)
    upperWick = high - math.max(close, open)
    lowerWick = math.min(close, open) - low
    avgVol    = ta.sma(volume, length)

    bigRange  = not na(avgRange) and rng > avgRange * rangeMult
    volSpike  = not useVolume or (not na(volume) and not na(avgVol) and volume > avgVol * volMult)
    bodyRef   = body == 0 ? syminfo.mintick : body

    bullExh   = bigRange and volSpike and upperWick > bodyRef * wickRatio and upperWick > lowerWick
    bearExh   = bigRange and volSpike and lowerWick > bodyRef * wickRatio and lowerWick > upperWick

    state = bullExh ? 1 : bearExh ? -1 : 0
    state

// ---------------- Current chart detection & coloring ----------------
curState = exhaustionState()

// Pick the bar color based on the chart's timeframe AND direction
tfMin     = timeframe.in_seconds() / 60
bullCol   = tfMin == 5 ? col5minBull : tfMin == 15 ? col15minBull : colOtherBull
bearCol   = tfMin == 5 ? col5minBear : tfMin == 15 ? col15minBear : colOtherBear
barCol    = curState == 1 ? bullCol : curState == -1 ? bearCol : na

barcolor(barCol, title = "Exhaustion Bar Color")

// Plot small markers so it is also visible when bar coloring is hard to see
plotshape(curState ==  1, title = "Bull Exhaustion (top)",    style = shape.triangledown, location = location.abovebar, color = color.red,  size = size.tiny)
plotshape(curState == -1, title = "Bear Exhaustion (bottom)", style = shape.triangleup,   location = location.belowbar, color = color.green,size = size.tiny)

// ---------------- Multi-timeframe values for the table ----------------
// Returns current state plus the LAST exhaustion direction and how many bars ago.
exhInfo() =>
    s         = exhaustionState()
    bullSince = ta.barssince(s == 1)
    bearSince = ta.barssince(s == -1)
    lastDir   = na(bullSince) and na(bearSince) ? 0 : nz(bullSince, 1e9) <= nz(bearSince, 1e9) ? 1 : -1
    ago       = lastDir == 1 ? bullSince : lastDir == -1 ? bearSince : na
    [s, lastDir, ago]

// Raw security values (these reflect the live, still-forming HTF bar)
[s5r,  last5r,  ago5r]  = request.security(syminfo.tickerid, "5",  exhInfo(), lookahead = barmerge.lookahead_off)
[s15r, last15r, ago15r] = request.security(syminfo.tickerid, "15", exhInfo(), lookahead = barmerge.lookahead_off)
[s60r, last60r, ago60r] = request.security(syminfo.tickerid, "60", exhInfo(), lookahead = barmerge.lookahead_off)

// Non-repainting = use the value from the last CLOSED bar (offset by 1), so it never
// changes on the currently forming bar. Repainting = use the live value as-is.
s5    = nonRepaint ? s5r[1]    : s5r
last5 = nonRepaint ? last5r[1] : last5r
ago5  = nonRepaint ? ago5r[1]  : ago5r
s15    = nonRepaint ? s15r[1]    : s15r
last15 = nonRepaint ? last15r[1] : last15r
ago15  = nonRepaint ? ago15r[1]  : ago15r
s60    = nonRepaint ? s60r[1]    : s60r
last60 = nonRepaint ? last60r[1] : last60r
ago60  = nonRepaint ? ago60r[1]  : ago60r

// Current status text/color (what the most recent bar is doing)
stateText(s) =>
    s == 1 ? "BULL EXH" : s == -1 ? "BEAR EXH" : "—"

stateColor(s) =>
    s == 1 ? color.new(color.red, 0) : s == -1 ? color.new(color.green, 0) : color.new(#333333, 0)

// Last-signal text: direction + bars ago
lastText(dir, ago) =>
    dir == 0 or na(ago) ? "none" : (dir == 1 ? "Bull " : "Bear ") + str.tostring(ago) + " bars ago"

lastColor(dir) =>
    dir == 1 ? color.new(color.red, 70) : dir == -1 ? color.new(color.green, 70) : color.new(#333333, 0)

// ---------------- Inputs: Table ----------------
gTbl      = "Table Settings"
showTable = input.bool(true, "Show Exhaustion Table", group = gTbl)
tablePos  = input.string("Top Right", "Table Placement", group = gTbl, options = ["Top Right","Top Center","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Center","Bottom Left"])
tblSize   = input.string("Small", "Table Text Size", group = gTbl, options = ["Tiny","Small","Normal","Large"])

posMap = tablePos == "Top Right" ? position.top_right : tablePos == "Top Center" ? position.top_center : tablePos == "Top Left" ? position.top_left : tablePos == "Middle Right" ? position.middle_right : tablePos == "Middle Left" ? position.middle_left : tablePos == "Bottom Right" ? position.bottom_right : tablePos == "Bottom Center" ? position.bottom_center : position.bottom_left

txtSize = tblSize == "Tiny" ? size.tiny : tblSize == "Small" ? size.small : tblSize == "Normal" ? size.normal : size.large

var table exhTable = table.new(posMap, 3, 5, border_width = 1, border_color = color.new(color.gray, 50))

hdrBg = color.new(#1565C0, 0)

// Mode banner: shows whether the table is in confirmed (non-repaint) or live mode
modeTxt = nonRepaint ? "● CONFIRMED" : "○ LIVE"
modeBg  = nonRepaint ? color.new(#2E7D32, 0) : color.new(#C62828, 0)

if showTable and barstate.islast
    // Title / mode banner row
    table.cell(exhTable, 0, 0, "EXHAUSTION", text_color = color.white, bgcolor = modeBg, text_size = txtSize)
    table.cell(exhTable, 1, 0, modeTxt,      text_color = color.white, bgcolor = modeBg, text_size = txtSize)
    table.cell(exhTable, 2, 0, "",           text_color = color.white, bgcolor = modeBg, text_size = txtSize)
    // Header row
    table.cell(exhTable, 0, 1, "TF",          text_color = color.white, bgcolor = hdrBg, text_size = txtSize)
    table.cell(exhTable, 1, 1, "Now",         text_color = color.white, bgcolor = hdrBg, text_size = txtSize)
    table.cell(exhTable, 2, 1, "Last Signal", text_color = color.white, bgcolor = hdrBg, text_size = txtSize)
    // 5 min
    table.cell(exhTable, 0, 2, "5 min", text_color = color.white, bgcolor = color.new(#000000, 0), text_size = txtSize)
    table.cell(exhTable, 1, 2, stateText(s5), text_color = color.white, bgcolor = stateColor(s5), text_size = txtSize)
    table.cell(exhTable, 2, 2, lastText(last5, ago5), text_color = color.white, bgcolor = lastColor(last5), text_size = txtSize)
    // 15 min
    table.cell(exhTable, 0, 3, "15 min", text_color = color.white, bgcolor = color.new(#000000, 0), text_size = txtSize)
    table.cell(exhTable, 1, 3, stateText(s15), text_color = color.white, bgcolor = stateColor(s15), text_size = txtSize)
    table.cell(exhTable, 2, 3, lastText(last15, ago15), text_color = color.white, bgcolor = lastColor(last15), text_size = txtSize)
    // 1 hr
    table.cell(exhTable, 0, 4, "1 hr", text_color = color.white, bgcolor = color.new(#000000, 0), text_size = txtSize)
    table.cell(exhTable, 1, 4, stateText(s60), text_color = color.white, bgcolor = stateColor(s60), text_size = txtSize)
    table.cell(exhTable, 2, 4, lastText(last60, ago60), text_color = color.white, bgcolor = lastColor(last60), text_size = txtSize)

// ---------------- Alerts ----------------
alertcondition(curState ==  1, "Bullish Exhaustion", "Bullish exhaustion candle detected")
alertcondition(curState == -1, "Bearish Exhaustion", "Bearish exhaustion candle detected")
````
