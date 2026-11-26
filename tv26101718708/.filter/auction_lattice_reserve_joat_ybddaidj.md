# Auction Lattice Reserve [JOAT]

- url: https://www.tradingview.com/script/YbddaIdj-Auction-Lattice-Reserve-JOAT/
- type: indicator
- pine_id: PUB;5555f1006c9e43318e0971c0ab74572f
- version: 1.0

## Description

[b]Auction Lattice Reserve [JOAT][/b]

[b]Introduction[/b]

Auction Lattice Reserve is an open-source auction-context indicator built to classify where price is trading relative to accepted value. It maps a fixed-lookback volume distribution, calculates Point of Control and Value Area boundaries, scores the current auction state, and then projects that information back onto the chart using profile slices, equilibrium bands, acceptance boxes, and an optional confirmed-bar TP/SL scaffold.

The main problem this script solves is location. Many directional tools can detect trend, but they do not explain whether price is trading above value, below value, or rotating around equilibrium. Auction Lattice Reserve provides that context directly from a rolling auction profile and combines it with trend and volume expansion scoring so the user can distinguish balance, markup, and distribution states.

[image]https://www.tradingview.com/x/s0AFISLl/[/image]

[b]Core Concepts[/b]

[b]1. Fixed-Range Auction Profile[/b]

The script scans a configurable lookback window, divides the price span into bins, and apportions each candle's volume into the bins it overlaps. This creates a rolling distribution of where volume was accepted:

[pine]
int firstBin = math.max(0, math.min(auctionBins - 1, math.floor((localLow - auctionLow) / auctionBin)))
int lastBin  = math.max(0, math.min(auctionBins - 1, math.floor((localHigh - auctionLow) / auctionBin)))
[/pine]

[b]2. Point of Control and Value Area[/b]

The highest-volume bin becomes the Point of Control. Value Area is expanded outward from the POC until the chosen percentage of total profile volume is captured. This makes the script useful for identifying accepted value and dislocation:

[pine]
auctionPoc := auctionLow + (auctionPocBin + 0.5) * auctionBin
auctionVaLow := auctionLow + leftBin * auctionBin
auctionVaHigh := auctionLow + (rightBin + 1.0) * auctionBin
[/pine]

[b]3. Auction State Scoring[/b]

The indicator does not rely on value alone. It blends distance from POC, trend spread, and short-vs-long volume expansion into an auction score. This creates a more robust state engine than simply checking whether price is above or below the value area.

[b]4. Acceptance and Rejection Context[/b]

Price trading outside the value area for consecutive confirmed bars is treated as accepted migration rather than a brief probe. When acceptance is confirmed, the script can project an acceptance box forward and optionally build a TP/SL ladder from the event.

[b]5. Institutional Visualization[/b]

The script uses right-side profile slices, layered clouds around value, an equilibrium band, candle-state coloring, and a compact top-right dashboard instead of retail-style arrows or decorative markers.

[b]Features[/b]

[list]
[*][b]Rolling auction profile:[/b] Fixed-lookback volume profile rendered at the right edge of the chart
[*][b]Point of Control and Value Area:[/b] POC, VA High, and VA Low plotted directly on price
[*][b]Auction score:[/b] Blends volume expansion, trend spread, and distance from equilibrium
[*][b]Equilibrium band:[/b] Mid-band around POC for visual balance context
[*][b]Acceptance boxes:[/b] Forward-projected boxes when price confirms value acceptance above or below the value area
[*][b]Optional TP/SL scaffold:[/b] Confirmed-bar entry, stop, TP1, TP2, TP3 rails with risk/reward fill
[*][b]Top-right dashboard:[/b] Shows current state, POC, value location, volume pressure, trend, and score
[*][b]Dark-mode visual design:[/b] Layered teal, rose, and gold tones tailored to auction concepts
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Check whether price is above value, below value, or inside value.

[b]Step 2:[/b] Review the auction score and dashboard state. Strong positive values indicate markup pressure. Strong negative values indicate distribution or liquidation pressure.

[b]Step 3:[/b] Watch for acceptance boxes. These show that price is no longer only probing value but may be migrating to a new area of acceptance.

[b]Step 4:[/b] Use the optional TP/SL scaffold only as a contextual planning aid. It is not a promise of outcome.

[b]Indicator Limitations[/b]

[list]
[*]Because the profile is rolling, value levels adapt over time and are not static
[*]A short lookback can make the auction map overly sensitive in volatile markets
[*]Acceptance logic requires confirmed bars, so some moves will already be underway when the state changes
[*]The TP/SL scaffold is informational and does not execute trades
[/list]

[b]Originality Statement[/b]

Auction Lattice Reserve is original in the way it combines a rolling auction profile, an equilibrium band, value-acceptance migration logic, and an institutional-style execution scaffold into one open-source indicator. The publication is intended to provide a reusable context layer for traders who want value-based location rather than a standalone entry system.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Auction context and value-area behavior are derived from historical price and volume data and do not guarantee future results. Always use independent judgment and risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Auction Lattice Reserve [JOAT]", shorttitle = "ALR [JOAT]", overlay = true, max_bars_back = 3000, max_boxes_count = 320, max_lines_count = 220, max_labels_count = 50)

//------------------------------------------------------------------------------
// Auction Lattice Reserve [JOAT]
// Institutional-style fixed-range auction map with regime scoring, value area
// rails, POC equilibrium, profile rendering, candle bias shading, and a compact
// top-right dashboard. Designed to remain non-repainting by using confirmed-bar
// logic for state changes and by updating heavy objects only on the last bar.
//------------------------------------------------------------------------------

groupProfile = "Profile Engine"
lookbackBars = input.int(160, "Auction Lookback", minval = 50, maxval = 500, group = groupProfile)
profileBins = input.int(36, "Price Bins", minval = 16, maxval = 80, group = groupProfile)
valueAreaPct = input.float(70.0, "Value Area Percent", minval = 50.0, maxval = 95.0, step = 0.5, group = groupProfile)
profileOffset = input.int(32, "Profile Offset Bars", minval = 8, maxval = 120, group = groupProfile)
profileWidthBars = input.int(24, "Profile Width Bars", minval = 8, maxval = 60, group = groupProfile)

groupRegime = "Regime Engine"
fastVolumeLen = input.int(8, "Fast Volume Length", minval = 1, group = groupRegime)
slowVolumeLen = input.int(34, "Slow Volume Length", minval = 5, group = groupRegime)
trendFastLen = input.int(34, "Trend Fast Length", minval = 2, group = groupRegime)
trendSlowLen = input.int(89, "Trend Slow Length", minval = 5, group = groupRegime)
distanceAtrLen = input.int(21, "Distance ATR Length", minval = 2, group = groupRegime)
distanceAtrMult = input.float(1.6, "Distance Normalizer", minval = 0.2, step = 0.1, group = groupRegime)

groupVisual = "Visual Design"
showProfile = input.bool(true, "Render Right Profile", group = groupVisual)
showCloud = input.bool(true, "Render Auction Cloud", group = groupVisual)
showCandleBias = input.bool(true, "Color Candles", group = groupVisual)
showMidBand = input.bool(true, "Render Equilibrium Band", group = groupVisual)
showDashboard = input.bool(true, "Show Dashboard", group = groupVisual)

groupExecution = "Execution Furniture"
showAcceptanceBoxes = input.bool(true, "Show Acceptance Boxes", group = groupExecution)
showTargetLadder = input.bool(true, "Show TP SL Ladder", group = groupExecution)
acceptanceBars = input.int(2, "Acceptance Bars", minval = 1, maxval = 10, group = groupExecution)
stopAtrMult = input.float(1.4, "Stop ATR Multiplier", minval = 0.4, step = 0.1, group = groupExecution)
tpOneR = input.float(1.0, "TP1 R", minval = 0.4, step = 0.1, group = groupExecution)
tpTwoR = input.float(2.0, "TP2 R", minval = 0.8, step = 0.1, group = groupExecution)
tpThreeR = input.float(3.0, "TP3 R", minval = 1.0, step = 0.1, group = groupExecution)

groupPalette = "Dark Palette"
bullCore = input.color(color.rgb(0, 201, 167), "Bull Core", group = groupPalette)
bearCore = input.color(color.rgb(255, 90, 110), "Bear Core", group = groupPalette)
neutralCore = input.color(color.rgb(148, 163, 184), "Neutral Core", group = groupPalette)
accentCore = input.color(color.rgb(255, 196, 61), "Equilibrium Accent", group = groupPalette)
panelBg = input.color(color.rgb(11, 18, 32), "Panel Background", group = groupPalette)
panelFrame = input.color(color.rgb(58, 76, 109), "Panel Frame", group = groupPalette)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_blend(float value, float minValue, float maxValue, color c1, color c2) =>
    float span = math.max(maxValue - minValue, 1e-10)
    float raw = (value - minValue) / span
    float frac = f_clamp(raw, 0.0, 1.0)
    int red = math.round(color.r(c1) + (color.r(c2) - color.r(c1)) * frac)
    int green = math.round(color.g(c1) + (color.g(c2) - color.g(c1)) * frac)
    int blue = math.round(color.b(c1) + (color.b(c2) - color.b(c1)) * frac)
    color.rgb(red, green, blue)

f_formatPrice(float value) =>
    str.tostring(value, format.mintick)

f_regimeText(float score) =>
    score >= 40 ? "Markup" :
     score <= -40 ? "Distribution" :
     score >= 10 ? "Accumulation" :
     score <= -10 ? "Liquidation" : "Balance"

f_stateColor(float score) =>
    score >= 10 ? bullCore :
     score <= -10 ? bearCore : neutralCore

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
// Core Range Metrics
//------------------------------------------------------------------------------

var array<float> profile = array.new_float(profileBins, 0.0)
var array<box> profileBoxes = array.new_box()
var table dashboard = table.new(position.top_right, 2, 6, bgcolor = color.new(panelBg, 0), border_width = 1, border_color = panelFrame, frame_width = 1, frame_color = panelFrame)

enoughBars = bar_index >= lookbackBars

float rangeLow = na
float rangeHigh = na
float rangeSpan = na
float binSize = na
float pocPrice = na
float vaHigh = na
float vaLow = na
int pocBin = na
int vaLeft = na
int vaRight = na
float totalVolume = na

if enoughBars
    rangeLow := low
    rangeHigh := high
    for i = 0 to lookbackBars - 1
        rangeLow := math.min(rangeLow, low[i])
        rangeHigh := math.max(rangeHigh, high[i])

    rangeSpan := math.max(rangeHigh - rangeLow, syminfo.mintick)
    binSize := math.max(rangeSpan / profileBins, syminfo.mintick)
    array.fill(profile, 0.0)
    totalVolume := 0.0

    for i = 0 to lookbackBars - 1
        float localLow = low[i]
        float localHigh = high[i]
        float localVolume = volume[i]
        float candleSpan = math.max(localHigh - localLow, syminfo.mintick)
        int binStart = math.max(0, math.min(profileBins - 1, math.floor((localLow - rangeLow) / binSize)))
        int binStop = math.max(0, math.min(profileBins - 1, math.floor((localHigh - rangeLow) / binSize)))
        totalVolume += localVolume

        for b = binStart to binStop
            float lowerEdge = rangeLow + binSize * b
            float upperEdge = lowerEdge + binSize
            float overlap = math.max(0.0, math.min(localHigh, upperEdge) - math.max(localLow, lowerEdge))
            if overlap > 0
                float apportioned = localVolume * (overlap / candleSpan)
                array.set(profile, b, array.get(profile, b) + apportioned)

    float maxVol = 0.0
    pocBin := 0
    for b = 0 to profileBins - 1
        float bucket = array.get(profile, b)
        if bucket > maxVol
            maxVol := bucket
            pocBin := b

    pocPrice := rangeLow + (pocBin + 0.5) * binSize
    float targetVolume = totalVolume * valueAreaPct * 0.01
    float accumulated = array.get(profile, pocBin)
    vaLeft := pocBin
    vaRight := pocBin

    while accumulated < targetVolume and (vaLeft > 0 or vaRight < profileBins - 1)
        float leftVol = vaLeft > 0 ? array.get(profile, vaLeft - 1) : -1.0
        float rightVol = vaRight < profileBins - 1 ? array.get(profile, vaRight + 1) : -1.0
        if rightVol > leftVol
            vaRight += 1
            accumulated += rightVol
        else
            vaLeft -= 1
            accumulated += leftVol

    vaLow := rangeLow + vaLeft * binSize
    vaHigh := rangeLow + (vaRight + 1.0) * binSize

//------------------------------------------------------------------------------
// Regime And Equilibrium Metrics
//------------------------------------------------------------------------------

fastVolume = ta.sma(volume, fastVolumeLen)
slowVolume = ta.sma(volume, slowVolumeLen)
volumeRatio = fastVolume / math.max(slowVolume, 0.000001)

trendFast = ta.ema(close, trendFastLen)
trendSlow = ta.ema(close, trendSlowLen)
trendSpread = trendFast - trendSlow
distanceAtr = ta.atr(distanceAtrLen)
distanceToPoc = enoughBars and not na(pocPrice) ? close - pocPrice : 0.0
distanceScore = distanceToPoc / math.max(distanceAtr * distanceAtrMult, syminfo.mintick)
volumeScore = (volumeRatio - 1.0) * 55.0
trendScore = trendSpread / math.max(distanceAtr, syminfo.mintick) * 30.0
auctionScore = enoughBars ? f_clamp(volumeScore + trendScore + distanceScore * 22.0, -100.0, 100.0) : 0.0

insideValue = enoughBars and not na(vaHigh) and close <= vaHigh and close >= vaLow
aboveValue = enoughBars and not na(vaHigh) and close > vaHigh
belowValue = enoughBars and not na(vaLow) and close < vaLow
confirmedBias = barstate.isconfirmed ? (auctionScore >= 12 ? 1 : auctionScore <= -12 ? -1 : 0) : 0
acceptedAbove = aboveValue and aboveValue[1]
acceptedBelow = belowValue and belowValue[1]
freshAcceptedAbove = acceptedAbove and not acceptedAbove[1]
freshAcceptedBelow = acceptedBelow and not acceptedBelow[1]

float balanceBandHalf = enoughBars ? math.max((vaHigh - vaLow) * 0.10, syminfo.mintick * 5.0) : na
float eqUpper = enoughBars and showMidBand ? pocPrice + balanceBandHalf : na
float eqLower = enoughBars and showMidBand ? pocPrice - balanceBandHalf : na

//------------------------------------------------------------------------------
// Plots
//------------------------------------------------------------------------------

pVaHigh = plot(vaHigh, "Value Area High", color = color.new(bullCore, 0), linewidth = 2)
pVaLow = plot(vaLow, "Value Area Low", color = color.new(bearCore, 0), linewidth = 2)
pPoc = plot(pocPrice, "Point Of Control", color = color.new(accentCore, 0), linewidth = 2, style = plot.style_linebr)
pTrendFast = plot(showCloud ? trendFast : na, "Trend Fast", color = color.new(bullCore, 75), linewidth = 1)
pTrendSlow = plot(showCloud ? trendSlow : na, "Trend Slow", color = color.new(bearCore, 75), linewidth = 1)
pEqUpper = plot(eqUpper, "Equilibrium Upper", color = color.new(accentCore, 60), linewidth = 1)
pEqLower = plot(eqLower, "Equilibrium Lower", color = color.new(accentCore, 60), linewidth = 1)

fill(pVaHigh, pPoc, color = showCloud and enoughBars ? color.new(bullCore, 86) : na, title = "Upper Auction Cloud")
fill(pPoc, pVaLow, color = showCloud and enoughBars ? color.new(bearCore, 86) : na, title = "Lower Auction Cloud")
fill(pTrendFast, pTrendSlow, color = showCloud ? color.new(f_stateColor(auctionScore), 86) : na, title = "Trend Bias Cloud")
fill(pEqUpper, pEqLower, color = showMidBand and enoughBars ? color.new(accentCore, 92) : na, title = "Equilibrium Band")

barcolor(showCandleBias ? color.new(f_stateColor(auctionScore), insideValue ? 55 : 20) : na)
bgcolor(enoughBars and aboveValue ? color.new(bullCore, 93) : enoughBars and belowValue ? color.new(bearCore, 93) : na, title = "Auction Dislocation")

//------------------------------------------------------------------------------
// Profile Rendering
//------------------------------------------------------------------------------

if barstate.islast
    while array.size(profileBoxes) < profileBins
        array.push(profileBoxes, box.new(na, na, na, na, border_width = 0, bgcolor = color.new(neutralCore, 100)))
    while array.size(profileBoxes) > profileBins
        box stale = array.pop(profileBoxes)
        box.delete(stale)

    float maxBucket = 0.0
    if enoughBars
        for b = 0 to profileBins - 1
            maxBucket := math.max(maxBucket, array.get(profile, b))

    for b = 0 to profileBins - 1
        box slice = array.get(profileBoxes, b)
        if enoughBars and showProfile and maxBucket > 0
            float sliceValue = array.get(profile, b)
            int width = sliceValue > 0 ? math.round(sliceValue / maxBucket * profileWidthBars) : 0
            float topPrice = rangeLow + binSize * (b + 1)
            float bottomPrice = rangeLow + binSize * b
            color sliceColor = b == pocBin ? color.new(accentCore, 20) : b >= vaLeft and b <= vaRight ? color.new(f_blend(b, vaLeft, vaRight + 1.0, bullCore, neutralCore), 42) : color.new(neutralCore, 82)
            box.set_left(slice, bar_index + profileOffset - width)
            box.set_right(slice, bar_index + profileOffset)
            box.set_top(slice, topPrice)
            box.set_bottom(slice, bottomPrice)
            box.set_bgcolor(slice, sliceColor)
            box.set_border_width(slice, 0)
        else
            box.set_left(slice, bar_index)
            box.set_right(slice, bar_index)
            box.set_top(slice, close)
            box.set_bottom(slice, close)
            box.set_bgcolor(slice, color.new(neutralCore, 100))
            box.set_border_width(slice, 0)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------

if barstate.islast and showDashboard
    color stateColor = f_stateColor(auctionScore)
    string valueState = aboveValue ? "Above VA" : belowValue ? "Below VA" : "Inside VA"
    string regimeText = f_regimeText(auctionScore)
    string pressureText = volumeRatio >= 1.2 ? "Expansion" : volumeRatio <= 0.88 ? "Compression" : "Balanced"
    string trendText = trendFast >= trendSlow ? "Positive" : "Negative"

    table.cell(dashboard, 0, 0, "Reserve", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 0, regimeText, text_color = stateColor, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 1, "POC", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 1, enoughBars ? f_formatPrice(pocPrice) : "Waiting", text_color = accentCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 2, "Value", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 2, valueState, text_color = stateColor, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 3, "Volume", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 3, str.tostring(volumeRatio, "#.##") + " | " + pressureText, text_color = stateColor, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 4, "Trend", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 4, trendText, text_color = trendFast >= trendSlow ? bullCore : bearCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 5, "Score", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 5, str.tostring(auctionScore, "#.0"), text_color = stateColor, bgcolor = color.new(panelBg, 0), text_size = size.normal)
else if barstate.islast and not showDashboard
    for col = 0 to 1
        for row = 0 to 5
            table.cell(dashboard, col, row, "", text_color = color.new(neutralCore, 100), bgcolor = color.new(panelBg, 100), text_size = size.normal)

//------------------------------------------------------------------------------
// Commentary
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Acceptance boxes and target ladder
//------------------------------------------------------------------------------
var box acceptanceBox = na
var line acceptanceMid = na
if freshAcceptedAbove and showAcceptanceBoxes
    if not na(acceptanceBox)
        box.delete(acceptanceBox)
    if not na(acceptanceMid)
        line.delete(acceptanceMid)
    acceptanceBox := box.new(bar_index - acceptanceBars, rangeHigh, bar_index + 80, vaHigh, bgcolor = color.new(bullCore, 90), border_color = color.new(bullCore, 30))
    acceptanceMid := line.new(bar_index - acceptanceBars, (rangeHigh + vaHigh) * 0.5, bar_index + 80, (rangeHigh + vaHigh) * 0.5, color = color.new(accentCore, 10), style = line.style_dashed)

if freshAcceptedBelow and showAcceptanceBoxes
    if not na(acceptanceBox)
        box.delete(acceptanceBox)
    if not na(acceptanceMid)
        line.delete(acceptanceMid)
    acceptanceBox := box.new(bar_index - acceptanceBars, vaLow, bar_index + 80, rangeLow, bgcolor = color.new(bearCore, 90), border_color = color.new(bearCore, 30))
    acceptanceMid := line.new(bar_index - acceptanceBars, (rangeLow + vaLow) * 0.5, bar_index + 80, (rangeLow + vaLow) * 0.5, color = color.new(accentCore, 10), style = line.style_dashed)

var line entryLine = na
var line stopLine = na
var line tpOneLine = na
var line tpTwoLine = na
var line tpThreeLine = na
var linefill riskFill = na
var linefill rewardFill = na

if freshAcceptedAbove and showTargetLadder
    f_clear_trade_lines(entryLine, stopLine, tpOneLine, tpTwoLine, tpThreeLine, riskFill, rewardFill)
    float entryPrice = close
    float stopPrice = math.min(pocPrice, close - distanceAtr * stopAtrMult)
    float risk = math.max(entryPrice - stopPrice, syminfo.mintick * 5.0)
    float tpOne = entryPrice + risk * tpOneR
    float tpTwo = entryPrice + risk * tpTwoR
    float tpThree = entryPrice + risk * tpThreeR
    entryLine := line.new(bar_index, entryPrice, bar_index + 1, entryPrice, color = color.new(bullCore, 0), width = 2, extend = extend.right)
    stopLine := line.new(bar_index, stopPrice, bar_index + 1, stopPrice, color = color.new(bearCore, 0), width = 1, style = line.style_dashed, extend = extend.right)
    tpOneLine := line.new(bar_index, tpOne, bar_index + 1, tpOne, color = color.new(bullCore, 20), width = 1, extend = extend.right)
    tpTwoLine := line.new(bar_index, tpTwo, bar_index + 1, tpTwo, color = color.new(bullCore, 20), width = 1, extend = extend.right)
    tpThreeLine := line.new(bar_index, tpThree, bar_index + 1, tpThree, color = color.new(bullCore, 20), width = 1, style = line.style_dotted, extend = extend.right)
    riskFill := linefill.new(entryLine, stopLine, color.new(bearCore, 90))
    rewardFill := linefill.new(entryLine, tpTwoLine, color.new(bullCore, 90))

if freshAcceptedBelow and showTargetLadder
    f_clear_trade_lines(entryLine, stopLine, tpOneLine, tpTwoLine, tpThreeLine, riskFill, rewardFill)
    float entryPrice = close
    float stopPrice = math.max(pocPrice, close + distanceAtr * stopAtrMult)
    float risk = math.max(stopPrice - entryPrice, syminfo.mintick * 5.0)
    float tpOne = entryPrice - risk * tpOneR
    float tpTwo = entryPrice - risk * tpTwoR
    float tpThree = entryPrice - risk * tpThreeR
    entryLine := line.new(bar_index, entryPrice, bar_index + 1, entryPrice, color = color.new(bearCore, 0), width = 2, extend = extend.right)
    stopLine := line.new(bar_index, stopPrice, bar_index + 1, stopPrice, color = color.new(bearCore, 0), width = 1, style = line.style_dashed, extend = extend.right)
    tpOneLine := line.new(bar_index, tpOne, bar_index + 1, tpOne, color = color.new(bullCore, 20), width = 1, extend = extend.right)
    tpTwoLine := line.new(bar_index, tpTwo, bar_index + 1, tpTwo, color = color.new(bullCore, 20), width = 1, extend = extend.right)
    tpThreeLine := line.new(bar_index, tpThree, bar_index + 1, tpThree, color = color.new(bullCore, 20), width = 1, style = line.style_dotted, extend = extend.right)
    riskFill := linefill.new(entryLine, stopLine, color.new(bearCore, 90))
    rewardFill := linefill.new(entryLine, tpTwoLine, color.new(bullCore, 90))

// Reserve thesis:
// 1. The profile describes where trade was accepted.
// 2. The POC marks equilibrium.
// 3. Volume expansion plus distance from equilibrium creates regime scoring.
// 4. Value-area location helps distinguish balance from dislocation.
// 5. Trend EMA spread provides directional context without using future bars.
// 6. Heavy box rendering is restricted to the last bar for performance.

alertcondition(freshAcceptedAbove, "Auction Acceptance Up", "Auction Lattice Reserve [JOAT]: confirmed value acceptance above the upper value area")
alertcondition(freshAcceptedBelow, "Auction Acceptance Down", "Auction Lattice Reserve [JOAT]: confirmed value acceptance below the lower value area")
````
