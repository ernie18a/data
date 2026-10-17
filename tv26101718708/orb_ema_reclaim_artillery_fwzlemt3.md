# ORB EMA Reclaim [Artillery]

- url: https://www.tradingview.com/script/fwZLEmt3-ORB-EMA-Reclaim-Artillery/
- type: indicator
- pine_id: PUB;cce516408c9e49cf8430f0d20cc7d682
- version: 1.0

## Description

ORB EMA Reclaim is an opening-range breakout (ORB) tool that waits for a pullback instead of chasing the breakout candle. It combines three parts that each do one job: the opening range sets the levels, a higher-timeframe close confirms direction, and a 20 EMA reclaim times the entry.

HOW IT WORKS

1. Opening range (ORB): the high and low of the first 30 minutes of the New York session (09:30–10:00 ET, adjustable). It is drawn as a box over that window, with dashed ORB HIGH / ORB LOW lines and prices carried across the session.

2. Bias: set only when a 10-minute candle CLOSES outside the opening range. A close above the range sets a long bias, a close below sets a short bias. Wicks through the range do not count. The 10-minute close is detected on the chart's own bars, so the chart timeframe must divide 10 (1m, 2m or 5m).

3. Pullback and reclaim: with a bias set, price must first close on the wrong side of the 20 EMA (the pullback), then close back on the bias side (the reclaim). That bar prints a BUY or SELL tag.

4. Levels: entry is the next bar's open. The stop sits beyond the pullback's extreme plus a tick buffer and an optional ATR buffer (default 1.0 × ATR 14). The target is either a fixed R multiple (default 1R) or the high/low of day at the time of the signal.

5. Exit tag: each setup is followed until it hits the stop, hits the target, or reaches the time exit (default 12:00 ET). The exit is tagged SELL (closing a long) or BUY (covering a short) with the result in R. If the stop and target are both touched in the same bar, the stop is assumed first.

New signals are only allowed inside the signal window (default 10:00–11:30 ET), one setup at a time, with a daily maximum (default 3).

ON THE CHART
• ORB box with high / low lines
• 20 EMA colored by bias, with a soft band between price and the EMA
• Light tint during the signal window
• BUY / SELL tags (hover for stop and target prices)
• Red stop zone and green target zone for each setup
• Exit tags with the result in R
• Dashboard: bias, ORB high/low, window status, setups today, active setup, timeframe check

HOW TO USE
Apply it to a 1m, 2m or 5m chart of an index future (ES, NQ, YM or their micros) during the New York session. Wait for the bias, let the pullback form, and use the BUY / SELL tag and drawn levels as a plan rather than an automatic order. Every session time, the EMA length, stop buffers, target mode and colors can be changed in the settings. Alerts are available for buy and sell setups.

NOTES
• The W/L and R count in the dashboard only covers the bars loaded on your chart. It is not a backtest and does not predict future results.
• Signals are confirmed on bar close and do not repaint.
• This script is for educational purposes only and is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ArtilleryTrades

//@version=6
// ORB EMA Reclaim [Artillery]
//
// An opening-range breakout model that waits for a pullback instead of chasing the break.
//   1. Opening range (ORB) = high/low of the first 30 minutes of the New York session.
//   2. Bias is set when a 10-minute candle closes outside that range.
//   3. Price must pull back through the EMA, then close back on the bias side (the reclaim).
//   4. The setup is plotted with BUY / SELL entry tags, stop and target zones,
//      and an exit tag showing where the setup closed: target, stop, or time exit.
// Built for 1m, 2m and 5m charts on index futures.
indicator("ORB EMA Reclaim [Artillery]", shorttitle = "ORB EMA", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─── Inputs ─────────────────────────────────────────────────────────────────
grpS = "Session"
tz          = input.string("America/New_York", "Timezone", group = grpS)
orSess      = input.session("0930-1000", "Opening range", group = grpS)
tradeSess   = input.session("1000-1130", "Signal window", group = grpS)
rthSess     = input.session("0930-1600", "Regular session", group = grpS)
flatHour    = input.int(12, "Time exit (hour)", minval = 0, maxval = 23, group = grpS, inline = "flat")
flatMinute  = input.int(0, "minute", minval = 0, maxval = 59, group = grpS, inline = "flat")

grpR = "Setup rules"
confTf      = input.int(10, "Breakout confirmation timeframe (minutes)", minval = 1, group = grpR)
emaLen      = input.int(20, "EMA length", minval = 1, group = grpR)
maxSetups   = input.int(3, "Max setups per day", minval = 1, group = grpR)
allowLong   = input.bool(true, "Longs", group = grpR, inline = "dir")
allowShort  = input.bool(true, "Shorts", group = grpR, inline = "dir")

grpK = "Stop & target"
stopTicks   = input.int(2, "Stop buffer beyond pivot (ticks)", minval = 0, group = grpK)
atrBuf      = input.float(1.0, "Extra stop buffer (x ATR 14)", minval = 0, step = 0.25, group = grpK,
     tooltip = "Widens the stop beyond the pullback pivot. 0 = stop sits just past the pivot.")
tgtMode     = input.string("Fixed R", "Target", options = ["Fixed R", "High/low of day"], group = grpK)
fixedR      = input.float(1.0, "Fixed target (R)", minval = 0.25, step = 0.25, group = grpK)
minRR       = input.float(0.0, "Min reward:risk (high/low of day mode)", minval = 0, step = 0.1, group = grpK)

grpV = "Style"
bullCol     = input.color(#00C2A8, "Bullish", group = grpV, inline = "col")
bearCol     = input.color(#FF4D6D, "Bearish", group = grpV, inline = "col")
neutCol     = input.color(#8C93A8, "Neutral", group = grpV, inline = "col")
showOR      = input.bool(true, "ORB box with high / low lines", group = grpV)
showEma     = input.bool(true, "EMA ribbon and bias cloud", group = grpV)
showBg      = input.bool(true, "Tint the signal window", group = grpV)
showLevels  = input.bool(true, "Entry / stop / target zones and exit tags", group = grpV)
showDash    = input.bool(true, "Dashboard", group = grpV)
dashPos     = input.string("Top right", "Dashboard position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = grpV)

// ─── Core ───────────────────────────────────────────────────────────────────
inSess(s) => not na(time(timeframe.period, s, tz))

chartMin = timeframe.in_seconds() / 60.0
tfOk = timeframe.isintraday and chartMin <= confTf and confTf % math.max(1, int(chartMin)) == 0

emaV = ta.ema(close, emaLen)
atrV = ta.atr(14)
useFixedR = tgtMode == "Fixed R"

// A confirmation-TF candle closes on the chart bar whose close time sits on a confTf boundary.
confClose = math.floor(time_close / 60000) % confTf == 0

// ─── Daily state ────────────────────────────────────────────────────────────
var float orHigh  = na
var float orLow   = na
var float dayHigh = na
var float dayLow  = na
var int   bias    = 0
var bool  armed   = false
var float pivot   = na
var int   setups  = 0
var box   orBox   = na
var line  orHiLn  = na
var line  orLoLn  = na
var label orHiLb  = na
var label orLoLb  = na

inOr  = inSess(orSess)
inRth = inSess(rthSess)
inWin = inSess(tradeSess)
newDay = inRth and (not inRth[1] or dayofmonth(time, tz) != dayofmonth(time[1], tz))

if newDay
    orHigh  := na
    orLow   := na
    dayHigh := na
    dayLow  := na
    bias    := 0
    armed   := false
    pivot   := na
    setups  := 0
    orBox   := na
    orHiLn  := na
    orLoLn  := na
    orHiLb  := na
    orLoLb  := na
    if showOR and tfOk
        orBox  := box.new(bar_index, high, bar_index, low, border_color = color.new(neutCol, 10), border_width = 2,
             bgcolor = color.new(neutCol, 82), text = "ORB", text_size = size.normal,
             text_color = color.white, text_halign = text.align_center, text_valign = text.align_center)
        orHiLn := line.new(bar_index, high, bar_index, high, color = color.new(neutCol, 20), style = line.style_dashed, width = 1)
        orLoLn := line.new(bar_index, low, bar_index, low, color = color.new(neutCol, 20), style = line.style_dashed, width = 1)
        orHiLb := label.new(bar_index, high, "", style = label.style_label_left, color = color.new(neutCol, 100),
             textcolor = neutCol, size = size.small)
        orLoLb := label.new(bar_index, low, "", style = label.style_label_left, color = color.new(neutCol, 100),
             textcolor = neutCol, size = size.small)

if inRth
    dayHigh := na(dayHigh) ? high : math.max(dayHigh, high)
    dayLow  := na(dayLow)  ? low  : math.min(dayLow, low)

if inOr
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow, low)

orDone = not na(orHigh) and not inOr and inRth

if orDone and confClose
    newBias = close > orHigh ? 1 : close < orLow ? -1 : bias
    if newBias != bias
        bias  := newBias
        armed := false
        pivot := na

biasCol = bias == 1 ? bullCol : bias == -1 ? bearCol : neutCol

// ORB box covers only the opening-range window; its high / low lines run across the session.
if not na(orBox) and inRth and not na(orHigh)
    if inOr
        box.set_right(orBox, bar_index)
        box.set_top(orBox, orHigh)
        box.set_bottom(orBox, orLow)
    line.set_xy2(orHiLn, bar_index, orHigh)
    line.set_y1(orHiLn, orHigh)
    line.set_xy2(orLoLn, bar_index, orLow)
    line.set_y1(orLoLn, orLow)
    label.set_xy(orHiLb, bar_index, orHigh)
    label.set_xy(orLoLb, bar_index, orLow)
    label.set_text(orHiLb, "ORB HIGH  " + str.tostring(orHigh, format.mintick))
    label.set_text(orLoLb, "ORB LOW  " + str.tostring(orLow, format.mintick))
    if orDone
        box.set_border_color(orBox, color.new(biasCol, 10))
        box.set_bgcolor(orBox, color.new(biasCol, 82))
        line.set_color(orHiLn, color.new(bullCol, 20))
        line.set_color(orLoLn, color.new(bearCol, 20))
        label.set_textcolor(orHiLb, bullCol)
        label.set_textcolor(orLoLb, bearCol)

// ─── Setup tracking ─────────────────────────────────────────────────────────
var int   tDir   = 0     // active setup: +1 long, -1 short
var float tEntry = na
var float tStop  = na
var float tTgt   = na
var int   pDir   = 0     // signal fired, entry on this bar's open
var float pStop  = na
var float pTgt   = na
var box   rBox   = na
var box   gBox   = na
var int   wins   = 0
var int   losses = 0
var float netR   = 0.0

if pDir != 0
    tDir   := pDir
    tEntry := open
    tStop  := pStop
    tTgt   := pTgt
    pDir   := 0
    if showLevels
        rBox := box.new(bar_index, math.max(tEntry, tStop), bar_index, math.min(tEntry, tStop),
             border_color = color.new(bearCol, 50), bgcolor = color.new(bearCol, 80))
        gBox := box.new(bar_index, math.max(tEntry, tTgt), bar_index, math.min(tEntry, tTgt),
             border_color = color.new(bullCol, 50), bgcolor = color.new(bullCol, 82))

flatMins = flatHour * 60 + flatMinute
pastFlat = hour(time_close, tz) * 60 + minute(time_close, tz) >= flatMins

if tDir != 0
    float exitPx = na
    exitTxt = ""
    hitStop = tDir == 1 ? low <= tStop : high >= tStop
    hitTgt  = tDir == 1 ? high >= tTgt : low <= tTgt
    // Stop is checked first when both are touched in one bar (conservative).
    if hitStop
        exitPx  := tStop
        exitTxt := "STOP"
    else if hitTgt
        exitPx  := tTgt
        exitTxt := "TARGET"
    else if pastFlat
        exitPx  := close
        exitTxt := "TIME"
    if not na(rBox)
        box.set_right(rBox, bar_index)
        box.set_right(gBox, bar_index)
    if not na(exitPx)
        risk = math.abs(tEntry - tStop)
        r = risk > 0 ? tDir * (exitPx - tEntry) / risk : 0.0
        netR += r
        if r > 0
            wins += 1
        else if r < 0
            losses += 1
        if showLevels
            // Exiting a long is a SELL, covering a short is a BUY.
            exitSide = tDir == 1 ? "SELL" : "BUY"
            sideCol  = tDir == 1 ? bearCol : bullCol
            label.new(bar_index, exitPx, exitSide + " · " + exitTxt + "  " + (r >= 0 ? "+" : "") + str.tostring(r, "0.0") + "R",
                 style = label.style_label_left, color = color.new(sideCol, 5), textcolor = color.white, size = size.small)
        tDir := 0
        rBox := na
        gBox := na

// ─── Pullback / reclaim ─────────────────────────────────────────────────────
longSig  = false
shortSig = false

if tfOk and orDone and bias == 1
    if close < emaV
        armed := true
        pivot := na(pivot) ? low : math.min(pivot, low)
    else if armed
        pivot := math.min(pivot, low)
        longSig := close > emaV
else if tfOk and orDone and bias == -1
    if close > emaV
        armed := true
        pivot := na(pivot) ? high : math.max(pivot, high)
    else if armed
        pivot := math.max(pivot, high)
        shortSig := close < emaV

canTrade = inWin and tDir == 0 and pDir == 0 and setups < maxSetups
validLong  = false
validShort = false

if longSig
    stopPx = pivot - stopTicks * syminfo.mintick - atrBuf * atrV
    risk   = close - stopPx
    tgtPx  = useFixedR ? close + fixedR * risk : dayHigh
    reward = tgtPx - close
    if allowLong and canTrade and risk > 0 and reward > 0 and (useFixedR or reward >= minRR * risk)
        validLong := true
        pDir  := 1
        pStop := stopPx
        pTgt  := tgtPx
        setups += 1
        label.new(bar_index, low, "BUY", yloc = yloc.belowbar, style = label.style_label_up, color = bullCol,
             textcolor = color.white, size = size.normal,
             tooltip = "Entry: next bar open\nStop: " + str.tostring(stopPx, format.mintick) + "\nTarget: " + str.tostring(tgtPx, format.mintick))
        alert("ORB Reclaim BUY on " + syminfo.ticker + " | stop " + str.tostring(stopPx, format.mintick) + " | target " + str.tostring(tgtPx, format.mintick), alert.freq_once_per_bar_close)
    armed := false
    pivot := na

if shortSig
    stopPx = pivot + stopTicks * syminfo.mintick + atrBuf * atrV
    risk   = stopPx - close
    tgtPx  = useFixedR ? close - fixedR * risk : dayLow
    reward = close - tgtPx
    if allowShort and canTrade and risk > 0 and reward > 0 and (useFixedR or reward >= minRR * risk)
        validShort := true
        pDir  := -1
        pStop := stopPx
        pTgt  := tgtPx
        setups += 1
        label.new(bar_index, high, "SELL", yloc = yloc.abovebar, style = label.style_label_down, color = bearCol,
             textcolor = color.white, size = size.normal,
             tooltip = "Entry: next bar open\nStop: " + str.tostring(stopPx, format.mintick) + "\nTarget: " + str.tostring(tgtPx, format.mintick))
        alert("ORB Reclaim SELL on " + syminfo.ticker + " | stop " + str.tostring(stopPx, format.mintick) + " | target " + str.tostring(tgtPx, format.mintick), alert.freq_once_per_bar_close)
    armed := false
    pivot := na

// ─── Visuals ────────────────────────────────────────────────────────────────
pEma = plot(showEma ? emaV : na, "EMA", color = biasCol, linewidth = 2)
plot(showEma ? emaV : na, "EMA glow", color = color.new(biasCol, 82), linewidth = 7, display = display.pane)
pPx  = plot(close, "Cloud anchor", display = display.none)
fill(pPx, pEma, color = showEma and bias != 0 ? color.new(biasCol, 91) : na, title = "Bias cloud")
bgcolor(showBg and tfOk and inWin and bias != 0 ? color.new(biasCol, 95) : na, title = "Signal window")

// ─── Dashboard ──────────────────────────────────────────────────────────────
tablePos = dashPos == "Top right" ? position.top_right : dashPos == "Bottom right" ? position.bottom_right :
     dashPos == "Top left" ? position.top_left : position.bottom_left
var table dash = table.new(tablePos, 2, 8, bgcolor = color.new(#0B0F17, 8), frame_color = color.new(#2A2F3A, 0),
     frame_width = 1, border_color = color.new(#1C212B, 0), border_width = 1)

row(r, k, v, vCol) =>
    table.cell(dash, 0, r, k, text_color = color.new(#C9CED8, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, v, text_color = vCol, text_size = size.small, text_halign = text.align_right)

if showDash and barstate.islast
    hdr = color.new(biasCol, 20)
    table.cell(dash, 0, 0, "ORB · EMA RECLAIM", text_color = color.white, text_size = size.small, bgcolor = hdr, text_halign = text.align_left)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color = color.white, text_size = size.small, bgcolor = hdr, text_halign = text.align_right)
    biasTxt = bias == 1 ? "▲ Long" : bias == -1 ? "▼ Short" : inOr ? "Building range" : "Waiting"
    row(1, "Bias", biasTxt, biasCol)
    row(2, "ORB high / low", na(orHigh) ? "—" : str.tostring(orHigh, format.mintick) + " / " + str.tostring(orLow, format.mintick), color.white)
    row(3, "Signal window", inWin ? "Open" : "Closed", inWin ? bullCol : neutCol)
    row(4, "Setups today", str.tostring(setups) + " / " + str.tostring(maxSetups), color.white)
    activeTxt = tDir == 1 ? "Bought @ " + str.tostring(tEntry, format.mintick) : tDir == -1 ? "Sold @ " + str.tostring(tEntry, format.mintick) : pDir != 0 ? "Entry next bar" : "—"
    row(5, "Active setup", activeTxt, tDir == 1 ? bullCol : tDir == -1 ? bearCol : color.white)
    row(6, "Chart history", str.tostring(wins) + "W  " + str.tostring(losses) + "L  " + (netR >= 0 ? "+" : "") + str.tostring(netR, "0.0") + "R", netR >= 0 ? bullCol : bearCol)
    row(7, tfOk ? "Timeframe" : "⚠ Timeframe", tfOk ? "OK" : "Use 1m, 2m or 5m", tfOk ? neutCol : bearCol)

// ─── Alerts ─────────────────────────────────────────────────────────────────
alertcondition(validLong,  "Buy setup",  "ORB Reclaim: BUY setup on {{ticker}} ({{interval}})")
alertcondition(validShort, "Sell setup", "ORB Reclaim: SELL setup on {{ticker}} ({{interval}})")
````
