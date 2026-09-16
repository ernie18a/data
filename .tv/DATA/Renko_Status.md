<!-- tradingview-pine-id: PUB;1fea6d1c033141df8750d1ce6cfc7e66 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Renko Status

Source: https://www.tradingview.com/script/tNbwuJZM-Renko-Status/

## Description

The indicator tracks dual-timeframe momentum and structural boundaries by requesting real-time traditional Renko data directly from the underlying asset's ticker via ticker.renko.

Dual-Box Engine: Calculates simultaneous data streams for both a Primary Renko Box (default 10.0 points) and a Secondary Renko Box (default 20.0 points) without requiring manual chart context switches.

Live Target Projections: Computes forward expansion targets (upTarget, downTarget) for both brick sizes. It projects live horizontal continuation/flip levels into future chart space (+2 to +8 offset for primary; +10 to +16 offset for secondary) to visually map higher-timeframe breakout boundaries before price hits them.

Recently Closed Range ("Zero Zone"): Generates shaded zero-zone fill areas between the previous brick's open and close levels, locking in confirmed structural support and resistance ranges directly on your execution chart.

Brick Change & Streak Tracking: Evaluates brick completion logic (ta.change(rkClose) != 0) and maintains a persistent counter (streak) to tally consecutive directional brick closes, measuring directional momentum intensity.

How to Use It in Trading:

Macro Filter & Bias Confirmation: Use the Secondary (20-box) target projections on lower-timeframe execution charts (like the 1m) as a trend-bias check. If the 20-box targets are expanding upward, avoid taking low-probability counter-trend short scalps.

Execution Timing: Use the Primary (10-box) projections to identify immediate micro-expansion triggers and structural flips during active setups.

Pullback / Level Trading: Treat the shaded "Zero Zone" lines as institutional support/resistance shelves. When price retests these dynamic boxes during a pullback, look for price action rejections to confirm entries in the direction of the dominant Renko streak.

Other Indicator Features

Unified Dashboard Table: Real-time price tracking for index ETFs (QQQ, SPY, DIA) positioned cleanly in the bottom-right corner.

Adaptive Moving Averages: Multiple linear regression and SMA curves scaled dynamically to match chart minute settings.

Daily Anchored VWAP (AVWAP): Automated volume-weighted average price line that resets sum calculations at the start of every daily trading session.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KinetiCapital

//@version=6
indicator("Renko Status", overlay=true)

// =============================================================================
// --- INPUTS ---
// =============================================================================
group_renko  = "Renko Settings"
boxSizeInput = input.float(10.0, "Primary Box Size", minval=0.0001, group=group_renko)

showBox20    = input.bool(true, "Secondary Box", inline = 'box20', group=group_renko)
boxSize20    = input.float(20.0, "", minval=0.0001, inline = 'box20', group=group_renko)

showProjLine = input.bool(true, "Continuation / Flip Lines?", group=group_renko)
showZeroZone = input.bool(true, "Recently closed Renko Range", inline = 'renko', group=group_renko)
fillZeroZone = input.bool(true, "Fill", inline = 'renko', group=group_renko)

grpToggle    = "Index Display Settings"
showQQQ      = input.bool(true, "Show QQQ", group = grpToggle)
showSPY      = input.bool(true, "Show SPY", group = grpToggle)
showDIA      = input.bool(true, "Show DIA", group = grpToggle)

// =============================================================================
// --- RENKO TICKER DATA ---
// =============================================================================
// Primary Renko
renkoTicker1 = ticker.renko(syminfo.tickerid, "Traditional", boxSizeInput)
[rkClose, rkOpen] = request.security(renkoTicker1, timeframe.period, [close, open], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// Secondary Renko (Size 20)
renkoTicker20 = ticker.renko(syminfo.tickerid, "Traditional", boxSize20)
[rkClose20, rkOpen20] = request.security(renkoTicker20, timeframe.period, [close, open], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

isGreenBrick  = rkClose > rkOpen
isRedBrick    = rkClose < rkOpen
actualBoxSize = math.abs(rkClose - rkOpen)

isGreenBrick20  = rkClose20 > rkOpen20
isRedBrick20    = rkClose20 < rkOpen20
actualBoxSize20 = math.abs(rkClose20 - rkOpen20)

// Brick Confirmation Signals
bool newBrick   = ta.change(rkClose) != 0
bool greenClose = newBrick and isGreenBrick
bool redClose   = newBrick and isRedBrick

// Consecutive Count Tracker (Primary)
var int streak = 0
if newBrick
    if isGreenBrick
        streak := (streak > 0) ? streak + 1 : 1
    else if isRedBrick
        streak := (streak < 0) ? streak - 1 : -1

colorGreen  = color.rgb(38, 166, 154)
colorRed    = color.rgb(239, 83, 80)
closedColor = isGreenBrick ? colorGreen : colorRed
streakText  = str.tostring(math.abs(streak))

// Target Projections
float upTarget   = isGreenBrick ? rkClose + actualBoxSize : rkOpen + actualBoxSize
float downTarget = isRedBrick   ? rkClose - actualBoxSize : rkOpen - actualBoxSize

float upTarget20   = isGreenBrick20 ? rkClose20 + actualBoxSize20 : rkOpen20 + actualBoxSize20
float downTarget20 = isRedBrick20   ? rkClose20 - actualBoxSize20 : rkOpen20 - actualBoxSize20

// =============================================================================
// --- INDEX DATA REQUESTS ---
// =============================================================================
t_qqq = ticker.new("NASDAQ", "QQQ", session.extended)
t_spy = ticker.new("AMEX", "SPY", session.extended)
t_dia = ticker.new("AMEX", "DIA", session.extended)

assetPriceQQQ = request.security(t_qqq, timeframe.period, close, ignore_invalid_symbol = true)
assetPriceSPY = request.security(t_spy, timeframe.period, close, ignore_invalid_symbol = true)
assetPriceDIA = request.security(t_dia, timeframe.period, close, ignore_invalid_symbol = true)

// =============================================================================
// --- ZERO ZONE & TARGET PROJECTION LINES (Live Bar Projections) ---
// =============================================================================
var line lineUp      = na
var line lineDown    = na
var line lineUp20    = na
var line lineDown20  = na

var line lineOpen    = na
var line lineClose   = na
var linefill zFill   = na

var line lineOpen20  = na
var line lineClose20 = na
var linefill zFill20 = na

if barstate.islast
    line.delete(lineUp)
    line.delete(lineDown)
    line.delete(lineUp20)
    line.delete(lineDown20)
    
    line.delete(lineOpen)
    line.delete(lineClose)
    linefill.delete(zFill)

    line.delete(lineOpen20)
    line.delete(lineClose20)
    linefill.delete(zFill20)

    if showZeroZone
        // Primary Box (+2 to +8)
        lineOpen  := line.new(x1 = bar_index + 2, y1 = rkOpen, x2 = bar_index + 8, y2 = rkOpen, color = color.gray, style = line.style_solid, width = 3)
        lineClose := line.new(x1 = bar_index + 2, y1 = rkClose, x2 = bar_index + 8, y2 = rkClose, color = color.gray, style = line.style_solid, width = 3)

        if fillZeroZone
            zFill := linefill.new(lineOpen, lineClose, color.new(color.gray, 85))

        // Secondary Box 20 (+10 to +16)
        if showBox20
            lineOpen20  := line.new(x1 = bar_index + 10, y1 = rkOpen20, x2 = bar_index + 16, y2 = rkOpen20, color = color.gray, style = line.style_solid, width = 3)
            lineClose20 := line.new(x1 = bar_index + 10, y1 = rkClose20, x2 = bar_index + 16, y2 = rkClose20, color = color.gray, style = line.style_solid, width = 3)

            if fillZeroZone
                zFill20 := linefill.new(lineOpen20, lineClose20, color.new(color.gray, 85))

    if showProjLine
        // Primary Targets (+2 to +8)
        lineUp   := line.new(x1 = bar_index + 2, y1 = upTarget, x2 = bar_index + 8, y2 = upTarget, color = colorGreen, style = line.style_solid, width = 3)
        lineDown := line.new(x1 = bar_index + 2, y1 = downTarget, x2 = bar_index + 8, y2 = downTarget, color = colorRed, style = line.style_solid, width = 3)

        // Secondary Targets (+10 to +16)
        if showBox20
            lineUp20   := line.new(x1 = bar_index + 10, y1 = upTarget20, x2 = bar_index + 16, y2 = upTarget20, color = colorGreen, style = line.style_solid, width = 3)
            lineDown20 := line.new(x1 = bar_index + 10, y1 = downTarget20, x2 = bar_index + 16, y2 = downTarget20, color = colorRed, style = line.style_solid, width = 3)

// =============================================================================
// --- UNIFIED DASHBOARD TABLE (Bottom Right, No Borders, All Small Text) ---
// =============================================================================
var table dashboard = table.new(position = position.bottom_right, columns = 2, rows = 5, border_width = 0)

if barstate.islast
    table.clear(dashboard, 0, 0, 1, 4)

    int curRow = 2

    if showQQQ
        table.cell(dashboard, 0, curRow, "QQQ", bgcolor = color.rgb(174, 171, 171), text_color = color.black, text_size = size.small)
        table.cell(dashboard, 1, curRow, str.tostring(assetPriceQQQ, "#.##"), bgcolor = color.rgb(174, 171, 171), text_color = color.black, text_size = size.small)
        curRow += 1

    if showSPY
        table.cell(dashboard, 0, curRow, "SPY", bgcolor = color.rgb(174, 171, 171), text_color = color.black, text_size = size.small)
        table.cell(dashboard, 1, curRow, str.tostring(assetPriceSPY, "#.##"), bgcolor = color.rgb(174, 171, 171), text_color = color.black, text_size = size.small)
        curRow += 1

    if showDIA
        table.cell(dashboard, 0, curRow, "DIA", bgcolor = color.rgb(174, 171, 171), text_color = color.black, text_size = size.small)
        table.cell(dashboard, 1, curRow, str.tostring(assetPriceDIA, "#.##"), bgcolor = color.rgb(174, 171, 171), text_color = color.black, text_size = size.small)
        curRow += 1

// =============================================================================
// --- MOVING AVERAGES ---
// =============================================================================
chartMinutes = timeframe.period == '30S' ? 0.5 : timeframe.isseconds ? str.tonumber(timeframe.period) / 60 : str.tonumber(timeframe.period)

magroup = "MA Setting"
showMA1  = input.bool(true, "" , inline = 'ma1', group = magroup)
lenMA1   = input.int(30, "mins", minval=1, inline = 'ma1', group = magroup)
timeMA1c = chartMinutes > lenMA1 ? na : math.round(lenMA1 / chartMinutes)
colorMA1 = input.color(color.rgb(10, 89, 154), "", inline = 'ma1', group = magroup)
widthMA1 = input.int(1, "", minval=1, maxval=4, inline = 'ma1', group = magroup)

validlenMA1 = not na(timeMA1c) and timeMA1c >= 1
lineSMA1  = (showMA1 and validlenMA1) ? ta.linreg(close, timeMA1c, 0) : na
plot(showMA1 ? lineSMA1 : na, title="MA 1", color=colorMA1, linewidth=widthMA1)

showMA2  = input.bool(false, "S", inline = 'ma1', group = magroup)
lenMA2   = lenMA1
timeMA2c = chartMinutes > lenMA2 ? na : math.round(lenMA2 / chartMinutes)
colorMA2 = color.new(colorMA1, 50)
widthMA2 = widthMA1

validlenMA2 = not na(timeMA2c) and timeMA2c >= 1
lineSMA2  = (showMA2 and validlenMA2) ? ta.sma(close, timeMA2c) : na
plot(showMA2 ? lineSMA2 : na, title="MA 2", color=colorMA2, linewidth=widthMA2)

showMA3  = input.bool(false, "", inline = 'ma3', group = magroup)
lenMA3   = input.int(120, "mins", minval=1, inline = 'ma3', group = magroup)
timeMA3c = chartMinutes > lenMA3 ? na : math.round(lenMA3 / chartMinutes)
colorMA3 = input.color(color.rgb(10, 89, 154,0), "", inline = 'ma3', group = magroup)
widthMA3 = input.int(1, "", minval=1, maxval=4, inline = 'ma3', group = magroup)

validlenMA3 = not na(timeMA3c) and timeMA3c >= 1
lineSMA3  = (showMA3 and validlenMA3) ? ta.linreg(close, timeMA3c, 0) : na
plot(showMA3 ? lineSMA3 : na, title="MA 3", color=colorMA3, linewidth=widthMA3)

showMA4  = input.bool(false, "S", inline = 'ma3', group = magroup)
lenMA4   = lenMA3
timeMA4c = chartMinutes > lenMA4 ? na : math.round(lenMA4 / chartMinutes)
colorMA4 = color.new(colorMA3, 50)
widthMA4 = widthMA3

validlenMA4 = not na(timeMA4c) and timeMA4c >= 1
lineSMA4  = (showMA4 and validlenMA4) ? ta.sma(close, timeMA4c) : na
plot(showMA4 ? lineSMA4 : na, title="MA 4", color=colorMA4, linewidth=widthMA4)

showMA5  = input.bool(false, "", inline = 'MA5', group = magroup)
lenMA5   = input.int(360, "mins", minval=1, inline = 'MA5', group = magroup)
timeMA5c = chartMinutes > lenMA5 ? na : math.round(lenMA5 / chartMinutes)
colorMA5 = input.color(color.rgb(215, 77, 42), "", inline = 'MA5', group = magroup)
widthMA5 = input.int(1, "", minval=1, maxval=4, inline = 'MA5', group = magroup)

validlenMA5 = not na(timeMA5c) and timeMA5c >= 1
lineSMA5  = (showMA5 and validlenMA5) ? ta.linreg(close, timeMA5c, 0) : na
plot(showMA5 ? lineSMA5 : na, title="MA 5", color=colorMA5, linewidth=widthMA5)


// =============================================================================
// --- DAILY ANCHORED VWAP (AVWAP) ---
// =============================================================================
grp_avwap   = "Daily AVWAP Settings"
showAVWAP   = input.bool(true, "Daily AVWAP", inline = 'vwap', group = grp_avwap)
colorAVWAP  = input.color(color.rgb(132, 33, 190, 23), "", inline = 'vwap', group = grp_avwap)
widthAVWAP  = input.int(1, "", minval = 1, maxval = 4, inline = 'vwap', group = grp_avwap)

// Detect the start of a new session/day
bool isNewDay = ta.change(time("D")) != 0

// Reset PV and Volume sums at the start of every daily session
var float sumPV  = 0.0
var float sumVol = 0.0

if isNewDay
    sumPV  := hlc3 * volume
    sumVol := volume
else
    sumPV  += hlc3 * volume
    sumVol += volume

float dailyAVWAP = sumVol > 0 ? sumPV / sumVol : na

// Plot line
plot(showAVWAP ? dailyAVWAP : na, title = "Daily AVWAP", color = colorAVWAP, linewidth = widthAVWAP)
````
