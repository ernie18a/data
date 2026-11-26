# Absorption Range Ledger [JOAT]

- url: https://www.tradingview.com/script/Xc38gIpk-Absorption-Range-Ledger-JOAT/
- type: indicator
- pine_id: PUB;f5a5609dbe804c43a2953c5f1253c861
- version: 1.0

## Description

[b]Absorption Range Ledger [JOAT][/b]

[b]Introduction[/b]

Absorption Range Ledger is an open-source range and participation overlay built to detect high-participation ranges, estimate internal bull-vs-bear ownership, track weighted equilibrium, and monitor whether the market is being absorbed, contained, reclaimed, or broken. It is designed for traders who want richer range context than a basic support/resistance box.

The script identifies high-participation candles, merges overlapping activity into persistent range zones, tracks a weighted equilibrium line inside the zone, and then highlights whether that zone is acting as supportive absorption, resistant absorption, or a two-way transfer area. Optional TP/SL rails are created when weighted reclaims or range breaks occur on confirmed bars.

[image]https://www.tradingview.com/x/eRMPtxzn/[/image]

[b]Core Concepts[/b]

[b]1. High Participation Detection[/b]

The script compares current volume to a baseline moving average. When participation exceeds the threshold, the candle is eligible to build or extend an absorption range.

[b]2. Range Merging[/b]

New high-participation candles are merged into existing ranges when overlap conditions are satisfied. This creates broader institutional-style transfer zones rather than isolated candle markers.

[b]3. Ownership Split[/b]

Each active range tracks approximate bullish and bearish ownership internally. This is displayed visually using sub-boxes and summarized numerically in the dashboard.

[b]4. Weighted Equilibrium[/b]

A weighted equilibrium line is maintained inside the dominant active range. This level serves as a practical internal reference for reclaim and failure behavior.

[b]5. Range Events[/b]

The script distinguishes containment, weighted-line reclaims, and outright range breaks. These states are used for dashboard context and optional TP/SL scaffolding.

[b]Features[/b]

[list]
[*][b]High-participation range detection:[/b] Builds active ranges when volume exceeds the baseline threshold
[*][b]Range merging:[/b] Overlapping participation bars are combined into richer zones
[*][b]Bull/bear ownership split:[/b] Internal sub-boxes show approximate participation balance
[*][b]Weighted equilibrium line:[/b] A central reference inside the active range
[*][b]Dominant active range logic:[/b] Tracks the most relevant current range for context
[*][b]Range reclaim and break states:[/b] Distinguishes contained trade from directional escape
[*][b]Optional TP/SL ladder:[/b] Builds informational risk rails on confirmed reclaims and breaks
[*][b]Top-right dashboard:[/b] Shows state, active count, weighted level, balance, range width, and event condition
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Identify whether a dominant active range exists.

[b]Step 2:[/b] Check the ownership balance. Strong positive balance suggests bid-side absorption. Strong negative balance suggests offer-side absorption.

[b]Step 3:[/b] Watch how price behaves around the weighted equilibrium line. Reclaims and failures often provide better context than touching the raw box boundary alone.

[b]Step 4:[/b] Use confirmed breaks of the dominant range as state changes, not as guaranteed trend starts.

[b]Indicator Limitations[/b]

[list]
[*]Ownership balance is an internal estimate, not a true order-flow measurement
[*]Range merging depends on the chosen volume threshold and can be too broad or too narrow if poorly configured
[*]Old ranges expire by design and will not remain indefinitely on the chart
[*]The TP/SL ladder is informational and not an execution engine
[/list]

[b]Originality Statement[/b]

Absorption Range Ledger is original in the way it combines participation-based zone merging, internal ownership splitting, weighted equilibrium governance, and event-driven scaffolding into one open-source range tool. It is published as a contextual market-transfer indicator rather than a simple breakout box.

[b]Disclaimer[/b] 

This indicator is provided for educational and informational purposes only. It is not financial advice. Participation, ownership, and absorption states are inferred from historical price and volume behavior and may not reflect future outcomes. Use independent analysis and risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("ARL [JOAT]", shorttitle = "Absorption Range Ledger [JOAT]", overlay = true, max_bars_back = 2500, max_boxes_count = 360, max_lines_count = 260, max_labels_count = 40)

//------------------------------------------------------------------------------
// Absorption Range Ledger [JOAT]
// Detects high-participation ranges, merges overlapping activity into active
// absorption boxes, tracks internal bull/bear ownership, and renders weighted
// equilibrium lines with a medium top-right dashboard.
//------------------------------------------------------------------------------

groupDetection = "Detection"
volumeLen = input.int(34, "Volume Baseline Length", minval = 5, maxval = 150, group = groupDetection)
volumeMult = input.float(1.8, "High Participation Multiplier", minval = 1.0, step = 0.1, group = groupDetection)
atrLen = input.int(14, "ATR Length", minval = 2, group = groupDetection)
mergeToleranceAtr = input.float(0.35, "Merge Tolerance ATR", minval = 0.0, step = 0.05, group = groupDetection)
zoneLifeBars = input.int(260, "Zone Life Bars", minval = 50, maxval = 500, group = groupDetection)

groupDisplay = "Display"
showProportions = input.bool(true, "Show Ownership Split", group = groupDisplay)
showWeightedLine = input.bool(true, "Show Weighted Equilibrium", group = groupDisplay)
showDashboard = input.bool(true, "Show Dashboard", group = groupDisplay)
showCandleColor = input.bool(true, "Color Candles", group = groupDisplay)

groupExecution = "Execution Furniture"
showEventBackdrop = input.bool(true, "Show Event Backdrop", group = groupExecution)
showTargetLadder = input.bool(true, "Show TP SL Ladder", group = groupExecution)
stopAtrMult = input.float(1.5, "Stop ATR Multiplier", minval = 0.4, step = 0.1, group = groupExecution)
tpOneR = input.float(1.0, "TP1 R", minval = 0.4, step = 0.1, group = groupExecution)
tpTwoR = input.float(2.0, "TP2 R", minval = 0.8, step = 0.1, group = groupExecution)
tpThreeR = input.float(3.0, "TP3 R", minval = 1.0, step = 0.1, group = groupExecution)

groupTheme = "Dark Palette"
bullCore = input.color(color.rgb(0, 205, 170), "Bull Core", group = groupTheme)
bearCore = input.color(color.rgb(255, 93, 112), "Bear Core", group = groupTheme)
neutralCore = input.color(color.rgb(148, 163, 184), "Neutral Core", group = groupTheme)
eqCore = input.color(color.rgb(244, 196, 84), "Weighted Line", group = groupTheme)
panelBg = input.color(color.rgb(11, 18, 32), "Panel Background", group = groupTheme)
panelFrame = input.color(color.rgb(58, 76, 109), "Panel Frame", group = groupTheme)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_zone_overlap(float topA, float botA, float topB, float botB) =>
    math.min(topA, topB) - math.max(botA, botB)

f_bull_share(float c, float o, float h, float l) =>
    float span = math.max(h - l, syminfo.mintick)
    float bodyPos = (math.max(c, o) - l) / span
    c >= o ? math.max(0.55, bodyPos) : math.min(0.45, bodyPos)

f_bias_color(float balance) =>
    balance > 0.08 ? bullCore : balance < -0.08 ? bearCore : neutralCore

f_bias_text(float balance) =>
    balance > 0.08 ? "Absorbing Bid" : balance < -0.08 ? "Absorbing Offer" : "Two-Way Transfer"

f_clear_trade_lines(line a, line b, line c, line d, line e, linefill rf, linefill pf) =>
    if not na(a)
        line.delete(a)
    if not na(b)
        line.delete(b)
    if not na(c)
        line.delete(c)
    if not na(d)
        line.delete(d)
    if not na(e)
        line.delete(e)
    if not na(rf)
        linefill.delete(rf)
    if not na(pf)
        linefill.delete(pf)

//------------------------------------------------------------------------------
// Core state
//------------------------------------------------------------------------------
volumeBaseline = ta.sma(volume, volumeLen)
atrValue = ta.atr(atrLen)
highParticipation = volume > volumeBaseline * volumeMult

var array<float> zoneTop = array.new_float()
var array<float> zoneBottom = array.new_float()
var array<int> zoneStart = array.new_int()
var array<bool> zoneActive = array.new_bool()
var array<float> bullVolume = array.new_float()
var array<float> bearVolume = array.new_float()
var array<float> weightedPrice = array.new_float()
var array<box> zoneBoxes = array.new_box()
var array<box> bullBoxes = array.new_box()
var array<box> bearBoxes = array.new_box()
var array<line> eqLines = array.new_line()
var table dashboard = table.new(position.top_right, 2, 6, bgcolor = color.new(panelBg, 0), border_color = panelFrame, border_width = 1, frame_color = panelFrame, frame_width = 1)

//------------------------------------------------------------------------------
// Zone creation and merging
//------------------------------------------------------------------------------
if highParticipation
    float candidateTop = high
    float candidateBottom = low
    float tolerance = atrValue * mergeToleranceAtr
    int mergeIndex = na
    if array.size(zoneTop) > 0
        for i = 0 to array.size(zoneTop) - 1
            if array.get(zoneActive, i)
                float overlap = f_zone_overlap(array.get(zoneTop, i) + tolerance, array.get(zoneBottom, i) - tolerance, candidateTop, candidateBottom)
                if overlap >= 0
                    mergeIndex := i
                    break

    float bullShare = f_bull_share(close, open, high, low)
    float newBullVol = volume * bullShare
    float newBearVol = volume * (1.0 - bullShare)
    float priceVolume = hlc3 * volume

    if na(mergeIndex)
        array.push(zoneTop, candidateTop)
        array.push(zoneBottom, candidateBottom)
        array.push(zoneStart, bar_index)
        array.push(zoneActive, true)
        array.push(bullVolume, newBullVol)
        array.push(bearVolume, newBearVol)
        array.push(weightedPrice, priceVolume / math.max(volume, 1.0))
        array.push(zoneBoxes, box.new(bar_index, candidateTop, bar_index + 1, candidateBottom, xloc = xloc.bar_index, bgcolor = color.new(neutralCore, 84), border_color = color.new(neutralCore, 10), extend = extend.right))
        array.push(bullBoxes, box.new(bar_index, candidateTop, bar_index + 1, candidateBottom, xloc = xloc.bar_index, bgcolor = na, border_color = na))
        array.push(bearBoxes, box.new(bar_index, candidateTop, bar_index + 1, candidateBottom, xloc = xloc.bar_index, bgcolor = na, border_color = na))
        array.push(eqLines, line.new(bar_index, hlc3, bar_index + 1, hlc3, xloc = xloc.bar_index, extend = extend.right, color = color.new(eqCore, 10), width = 2))
    else
        int idx = mergeIndex
        float topNow = math.max(array.get(zoneTop, idx), candidateTop)
        float bottomNow = math.min(array.get(zoneBottom, idx), candidateBottom)
        float bullNow = array.get(bullVolume, idx) + newBullVol
        float bearNow = array.get(bearVolume, idx) + newBearVol
        float totalNow = bullNow + bearNow
        float weightedNow = (array.get(weightedPrice, idx) * (array.get(bullVolume, idx) + array.get(bearVolume, idx)) + priceVolume) / math.max(totalNow, 1.0)
        array.set(zoneTop, idx, topNow)
        array.set(zoneBottom, idx, bottomNow)
        array.set(bullVolume, idx, bullNow)
        array.set(bearVolume, idx, bearNow)
        array.set(weightedPrice, idx, weightedNow)

//------------------------------------------------------------------------------
// Zone maintenance and rendering
//------------------------------------------------------------------------------
int activeCount = 0
float dominantBalance = 0.0
float dominantEq = na
float dominantTop = na
float dominantBottom = na

if array.size(zoneTop) > 0
    int zoneCount = array.size(zoneTop)
    for i = 0 to zoneCount - 1
        int idx = zoneCount - 1 - i
        bool active = array.get(zoneActive, idx)
        float topPrice = array.get(zoneTop, idx)
        float bottomPrice = array.get(zoneBottom, idx)
        float bullVol = array.get(bullVolume, idx)
        float bearVol = array.get(bearVolume, idx)
        float totalVol = bullVol + bearVol
        float balance = totalVol > 0 ? (bullVol - bearVol) / totalVol : 0.0
        float eqPrice = array.get(weightedPrice, idx)
        bool expired = bar_index - array.get(zoneStart, idx) > zoneLifeBars
        bool brokenUp = close > topPrice and balance >= 0
        bool brokenDown = close < bottomPrice and balance <= 0
        bool stillActive = active and not expired and not brokenUp and not brokenDown
        array.set(zoneActive, idx, stillActive)

        box mainBox = array.get(zoneBoxes, idx)
        box bullBox = array.get(bullBoxes, idx)
        box bearBox = array.get(bearBoxes, idx)
        line eqLine = array.get(eqLines, idx)

        if stillActive
            activeCount += 1
            if na(dominantEq) or math.abs(balance) > math.abs(dominantBalance)
                dominantBalance := balance
                dominantEq := eqPrice
                dominantTop := topPrice
                dominantBottom := bottomPrice

            int rightEdge = math.min(bar_index + 1, array.get(zoneStart, idx) + zoneLifeBars)
            color zoneColor = color.new(f_bias_color(balance), 84)
            box.set_left(mainBox, array.get(zoneStart, idx))
            box.set_right(mainBox, rightEdge)
            box.set_top(mainBox, topPrice)
            box.set_bottom(mainBox, bottomPrice)
            box.set_bgcolor(mainBox, zoneColor)
            box.set_border_color(mainBox, color.new(f_bias_color(balance), 10))

            if showWeightedLine
                line.set_xy1(eqLine, array.get(zoneStart, idx), eqPrice)
                line.set_xy2(eqLine, rightEdge, eqPrice)
                line.set_color(eqLine, color.new(eqCore, 10))
            else
                line.set_color(eqLine, na)

            if showProportions and totalVol > 0
                float bullPct = bullVol / totalVol
                int splitX = array.get(zoneStart, idx) + int(math.round((rightEdge - array.get(zoneStart, idx)) * bullPct))
                box.set_left(bullBox, array.get(zoneStart, idx))
                box.set_right(bullBox, splitX)
                box.set_top(bullBox, topPrice)
                box.set_bottom(bullBox, bottomPrice)
                box.set_bgcolor(bullBox, color.new(bullCore, 82))
                box.set_border_color(bullBox, na)
                box.set_left(bearBox, splitX)
                box.set_right(bearBox, rightEdge)
                box.set_top(bearBox, topPrice)
                box.set_bottom(bearBox, bottomPrice)
                box.set_bgcolor(bearBox, color.new(bearCore, 82))
                box.set_border_color(bearBox, na)
            else
                box.set_bgcolor(bullBox, na)
                box.set_bgcolor(bearBox, na)
                box.set_border_color(bullBox, na)
                box.set_border_color(bearBox, na)
        else
            box.set_bgcolor(mainBox, na)
            box.set_border_color(mainBox, na)
            box.set_bgcolor(bullBox, na)
            box.set_bgcolor(bearBox, na)
            box.set_border_color(bullBox, na)
            box.set_border_color(bearBox, na)
            line.set_color(eqLine, na)

//------------------------------------------------------------------------------
// Bias layer
//------------------------------------------------------------------------------
dominantActive = activeCount > 0 and not na(dominantEq)
confirmedAbsorptionBid = dominantActive and barstate.isconfirmed and dominantBalance > 0.08 and close > dominantEq and close <= dominantTop
confirmedAbsorptionOffer = dominantActive and barstate.isconfirmed and dominantBalance < -0.08 and close < dominantEq and close >= dominantBottom
rangeBreakUp = dominantActive and barstate.isconfirmed and close > dominantTop
rangeBreakDown = dominantActive and barstate.isconfirmed and close < dominantBottom
eqReclaimUp = dominantActive and barstate.isconfirmed and ta.crossover(close, dominantEq)
eqReclaimDown = dominantActive and barstate.isconfirmed and ta.crossunder(close, dominantEq)

barColor =
     confirmedAbsorptionBid ? color.new(bullCore, 0) :
     confirmedAbsorptionOffer ? color.new(bearCore, 0) :
     dominantActive ? color.new(f_bias_color(dominantBalance), 35) :
     na
barcolor(showCandleColor ? barColor : na)
bgcolor(showEventBackdrop and rangeBreakUp ? color.new(bullCore, 93) : showEventBackdrop and rangeBreakDown ? color.new(bearCore, 93) : showEventBackdrop and dominantActive ? color.new(f_bias_color(dominantBalance), 96) : na)

plot(dominantEq, "Dominant Equilibrium", color = dominantActive and showWeightedLine ? color.new(eqCore, 0) : na, linewidth = 2, style = plot.style_linebr)
plot(dominantTop, "Dominant Top", color = dominantActive ? color.new(bearCore, 70) : na, linewidth = 1, style = plot.style_linebr)
plot(dominantBottom, "Dominant Bottom", color = dominantActive ? color.new(bullCore, 70) : na, linewidth = 1, style = plot.style_linebr)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "Ledger", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 0, dominantActive ? f_bias_text(dominantBalance) : "No Active Range", text_color = dominantActive ? f_bias_color(dominantBalance) : neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 1, "Active", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 1, str.tostring(activeCount), text_color = dominantActive ? f_bias_color(dominantBalance) : neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 2, "Eq Price", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 2, dominantActive ? str.tostring(dominantEq, format.mintick) : "Waiting", text_color = eqCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 3, "Balance", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 3, dominantActive ? str.tostring(dominantBalance * 100.0, "#.0") + "%" : "0%", text_color = dominantActive ? f_bias_color(dominantBalance) : neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 4, "Range", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 4, dominantActive ? str.tostring(dominantTop - dominantBottom, format.mintick) : "Waiting", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 5, "State", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 5, confirmedAbsorptionBid ? "Bid Control" : confirmedAbsorptionOffer ? "Offer Control" : dominantActive ? "Contained" : "Idle", text_color = dominantActive ? f_bias_color(dominantBalance) : neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)

//------------------------------------------------------------------------------
// Trade ladder and event lines
//------------------------------------------------------------------------------
var line eventEntry = na
var line eventStop = na
var line eventTp1 = na
var line eventTp2 = na
var line eventTp3 = na
var linefill eventRiskFill = na
var linefill eventRewardFill = na

if (rangeBreakUp or eqReclaimUp) and showTargetLadder
    f_clear_trade_lines(eventEntry, eventStop, eventTp1, eventTp2, eventTp3, eventRiskFill, eventRewardFill)
    float entryPrice = close
    float stopPrice = math.min(dominantBottom, close - atrValue * stopAtrMult)
    float risk = math.max(entryPrice - stopPrice, syminfo.mintick * 5.0)
    float tp1 = entryPrice + risk * tpOneR
    float tp2 = entryPrice + risk * tpTwoR
    float tp3 = entryPrice + risk * tpThreeR
    eventEntry := line.new(bar_index, entryPrice, bar_index + 1, entryPrice, color = color.new(bullCore, 0), width = 2, extend = extend.right)
    eventStop := line.new(bar_index, stopPrice, bar_index + 1, stopPrice, color = color.new(bearCore, 0), width = 1, style = line.style_dashed, extend = extend.right)
    eventTp1 := line.new(bar_index, tp1, bar_index + 1, tp1, color = color.new(bullCore, 20), width = 1, extend = extend.right)
    eventTp2 := line.new(bar_index, tp2, bar_index + 1, tp2, color = color.new(bullCore, 20), width = 1, extend = extend.right)
    eventTp3 := line.new(bar_index, tp3, bar_index + 1, tp3, color = color.new(bullCore, 20), width = 1, style = line.style_dotted, extend = extend.right)
    eventRiskFill := linefill.new(eventEntry, eventStop, color.new(bearCore, 90))
    eventRewardFill := linefill.new(eventEntry, eventTp2, color.new(bullCore, 90))

if (rangeBreakDown or eqReclaimDown) and showTargetLadder
    f_clear_trade_lines(eventEntry, eventStop, eventTp1, eventTp2, eventTp3, eventRiskFill, eventRewardFill)
    float entryPrice = close
    float stopPrice = math.max(dominantTop, close + atrValue * stopAtrMult)
    float risk = math.max(stopPrice - entryPrice, syminfo.mintick * 5.0)
    float tp1 = entryPrice - risk * tpOneR
    float tp2 = entryPrice - risk * tpTwoR
    float tp3 = entryPrice - risk * tpThreeR
    eventEntry := line.new(bar_index, entryPrice, bar_index + 1, entryPrice, color = color.new(bearCore, 0), width = 2, extend = extend.right)
    eventStop := line.new(bar_index, stopPrice, bar_index + 1, stopPrice, color = color.new(bearCore, 0), width = 1, style = line.style_dashed, extend = extend.right)
    eventTp1 := line.new(bar_index, tp1, bar_index + 1, tp1, color = color.new(bullCore, 20), width = 1, extend = extend.right)
    eventTp2 := line.new(bar_index, tp2, bar_index + 1, tp2, color = color.new(bullCore, 20), width = 1, extend = extend.right)
    eventTp3 := line.new(bar_index, tp3, bar_index + 1, tp3, color = color.new(bullCore, 20), width = 1, style = line.style_dotted, extend = extend.right)
    eventRiskFill := linefill.new(eventEntry, eventStop, color.new(bearCore, 90))
    eventRewardFill := linefill.new(eventEntry, eventTp2, color.new(bullCore, 90))

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(confirmedAbsorptionBid, "Absorption Bid", "Absorption Range Ledger [JOAT]: confirmed bid control inside dominant range")
alertcondition(confirmedAbsorptionOffer, "Absorption Offer", "Absorption Range Ledger [JOAT]: confirmed offer control inside dominant range")
alertcondition(rangeBreakUp, "Absorption Range Lift", "Absorption Range Ledger [JOAT]: confirmed lift through the dominant range")
alertcondition(rangeBreakDown, "Absorption Range Break", "Absorption Range Ledger [JOAT]: confirmed break below the dominant range")
````
