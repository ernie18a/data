# Covenant Participation Lattice [JOAT]

- url: https://www.tradingview.com/script/3fncwDHL-Covenant-Participation-Lattice-JOAT/
- type: indicator
- pine_id: PUB;36ec392608994d52809d360460529ea0
- version: 1.0

## Description

[b]Covenant Participation Lattice [JOAT][/b]

[b]Introduction[/b]

Covenant Participation Lattice is an open-source participation-axis engine that builds a rolling price-distribution profile, stabilizes the point of control, and maps value-area structure around that axis. It is designed to show where price is accepted, where it is stretched, and whether current auction conditions are balanced, premium, or discounted.

[image]https://www.tradingview.com/x/WImB2yaw/[/image]

[b]Core Concepts[/b]

[b]1. Rolling profile construction[/b]

A distribution of volume by price is rebuilt over a configurable lookback and row count. The profile identifies a raw point of control and the surrounding value area used to classify current price position.

[b]2. Stabilized axis logic[/b]

Rather than plotting the raw POC directly, Covenant stabilizes the axis using staged adjustments constrained by ATR. This reduces noisy jumps while preserving meaningful auction shifts.

[b]3. Premium, discount, and acceptance diagnostics[/b]

The script calculates how much volume sits above, below, and inside value. This allows the chart to distinguish accepted trade inside value from premium or discount extension away from it.

[b]4. Corridor rendering[/b]

Guide lines and corridor fills visually connect the participation axis with the value-area bounds so the trader can see auction balance without reading the dashboard first.

[b]Features[/b]

[list]
[*][b]Rolling profile and stabilized participation axis[/b]
[*][b]Value-area high, low, and midpoint structure[/b]
[*][b]Premium/discount share analysis[/b]
[*][b]Balance tilt and tail-skew diagnostics[/b]
[*][b]Ribbon and top-right dashboard[/b]
[*][b]Confirmed alerts for axis reclaim, value-area breaks, and deep extension[/b]
[/list]

[b]Disclaimer[/b]

This indicator is educational and informational only. Participation and value-area relationships describe auction context; they do not guarantee reversal or continuation.

- made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Covenant Participation Lattice [JOAT]", overlay = true, max_lines_count = 240, max_labels_count = 120)

//------------------------------------------------------------------------------
// Covenant Participation Lattice
// Rolling participation axis with a stabilized POC, value-area envelope,
// premium/discount tracking, and an institutional dashboard.
//------------------------------------------------------------------------------

string groupProfile = "Profile"
string groupStability = "Stability"
string groupStyle = "Style"
string groupDashboard = "Dashboard"
string groupAlerts = "Alerts"

int lookbackBars = input.int(240, "Lookback", minval = 40, maxval = 1500, group = groupProfile)
int profileRows = input.int(56, "Profile Rows", minval = 20, maxval = 120, group = groupProfile)
float valueAreaPct = input.float(68.0, "Value Area %", minval = 50.0, maxval = 95.0, step = 0.5, group = groupProfile)
int smoothLength = input.int(8, "Smoothing Length", minval = 1, maxval = 50, group = groupStability)
float stabilityAtr = input.float(1.8, "Stability ATR Band", minval = 0.2, step = 0.1, group = groupStability)
float deviationCap = input.float(4.0, "Deviation Clamp", minval = 1.0, maxval = 8.0, step = 0.5, group = groupStability)
int recentHighlight = input.int(80, "Recent Highlight Bars", minval = 10, maxval = 400, group = groupStability)
bool showValueArea = input.bool(true, "Show Value Area", group = groupStability)
bool showBackground = input.bool(true, "Show Background", group = groupStability)
bool showSyntheticCandles = input.bool(false, "Plot Synthetic Candles", group = groupStability)

color coreLineCol = input.color(color.rgb(42, 206, 188), "Core Axis", group = groupStyle, inline = "c1")
color recentLineCol = input.color(color.rgb(255, 185, 58), "", group = groupStyle, inline = "c1")
color upperCloudCol = input.color(color.rgb(60, 120, 255), "Upper Cloud", group = groupStyle, inline = "c2")
color lowerCloudCol = input.color(color.rgb(235, 96, 121), "", group = groupStyle, inline = "c2")
color valueAreaCol = input.color(color.rgb(138, 149, 181), "Value Area", group = groupStyle)
int cloudOpacity = input.int(86, "Cloud Transparency", minval = 10, maxval = 95, group = groupStyle)
bool recolorCandles = input.bool(true, "Recolor Candles", group = groupStyle)

bool showDashboard = input.bool(true, "Show Dashboard", group = groupDashboard)
string dashSize = input.string("Normal", "Dashboard Size", options = ["Small", "Normal", "Large"], group = groupDashboard)
bool showRibbon = input.bool(true, "Show Ribbon", group = groupDashboard)

bool enableAlerts = input.bool(true, "Enable Alerts", group = groupAlerts)

f_clamp(float value, float lo, float hi) =>
    math.min(math.max(value, lo), hi)

f_size(string sizeName) =>
    switch sizeName
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_color_from_deviation(float deviation) =>
    deviation >= 0 ? color.from_gradient(deviation, 0.0, deviationCap, coreLineCol, upperCloudCol) : color.from_gradient(deviation, -deviationCap, 0.0, lowerCloudCol, coreLineCol)

//------------------------------------------------------------------------------
// Profile construction
//------------------------------------------------------------------------------
float rangeHigh = ta.highest(high, lookbackBars)
float rangeLow = ta.lowest(low, lookbackBars)
float priceStep = math.max((rangeHigh - rangeLow) / profileRows, syminfo.mintick)

var array<float> profile = array.new_float()
if barstate.isfirst or array.size(profile) != profileRows
    array.clear(profile)
    for i = 0 to profileRows - 1
        array.push(profile, 0.0)
else
    array.clear(profile)
    for i = 0 to profileRows - 1
        array.push(profile, 0.0)

for i = 0 to lookbackBars - 1
    float barClose = close[i]
    if not na(barClose)
        int idx = int(math.floor((barClose - rangeLow) / priceStep))
        idx := int(f_clamp(idx, 0, profileRows - 1))
        array.set(profile, idx, array.get(profile, idx) + volume[i])

float totalVolume = 0.0
float maxVolume = 0.0
int pocIndex = 0
for i = 0 to profileRows - 1
    float binVol = array.get(profile, i)
    totalVolume += binVol
    if binVol > maxVolume
        maxVolume := binVol
        pocIndex := i

float rawPoc = rangeLow + priceStep * (pocIndex + 0.5)
float atrBase = ta.atr(55)

//------------------------------------------------------------------------------
// Stabilized axis engine
//------------------------------------------------------------------------------
var float stage1 = na
var float stage2 = na
var float stage3 = na

if na(stage1)
    stage1 := rawPoc
    stage2 := rawPoc
    stage3 := rawPoc

float jump = f_clamp(rawPoc - stage1, -atrBase * stabilityAtr, atrBase * stabilityAtr)
stage1 := ta.ema(stage1 + jump, smoothLength)
stage2 := math.abs(stage1 - nz(stage2[1], stage1)) > atrBase * stabilityAtr ? stage1 : nz(stage2[1], stage1)
stage3 := math.abs(stage2 - nz(stage3[1], stage2)) > atrBase * stabilityAtr ? stage2 : nz(stage3[1], stage2)

float coreAxis = stage3
float axisSlope = coreAxis - coreAxis[1]
float deviation = (close - coreAxis) / math.max(atrBase, syminfo.mintick)
float deviationClamped = f_clamp(deviation, -deviationCap, deviationCap)
color axisColor = f_color_from_deviation(deviationClamped)

//------------------------------------------------------------------------------
// Value area and distribution metrics
//------------------------------------------------------------------------------
float targetVolume = totalVolume * valueAreaPct / 100.0
int leftIdx = pocIndex
int rightIdx = pocIndex
float valueAreaVolume = array.size(profile) > 0 ? array.get(profile, pocIndex) : 0.0
int expansionSteps = 0
while valueAreaVolume < targetVolume and expansionSteps < profileRows * 2
    float nextLeft = leftIdx > 0 ? array.get(profile, leftIdx - 1) : na
    float nextRight = rightIdx < profileRows - 1 ? array.get(profile, rightIdx + 1) : na
    bool canLeft = leftIdx > 0
    bool canRight = rightIdx < profileRows - 1
    bool takeLeft = canLeft and canRight ? nz(nextLeft, 0.0) >= nz(nextRight, 0.0) : canLeft
    if takeLeft and canLeft
        leftIdx -= 1
        valueAreaVolume += array.get(profile, leftIdx)
    else if canRight
        rightIdx += 1
        valueAreaVolume += array.get(profile, rightIdx)
    else
        break
    expansionSteps += 1

float vah = rangeLow + priceStep * (rightIdx + 1)
float val = rangeLow + priceStep * leftIdx
float valueMid = math.avg(vah, val)
float profileScore = totalVolume > 0 ? maxVolume / totalVolume * 100.0 : 0.0
float acceptanceScore = totalVolume > 0 ? valueAreaVolume / totalVolume * 100.0 : 0.0
float profileWidth = vah - val
float rangeWidth = math.max(rangeHigh - rangeLow, syminfo.mintick)
float rangeFill = profileWidth / rangeWidth * 100.0

string regime = deviationClamped > 2.5 ? "Expansion Above" : deviationClamped > 0.75 ? "Firm Above" : deviationClamped < -2.5 ? "Expansion Below" : deviationClamped < -0.75 ? "Firm Below" : "Balanced"
color regimeColor = deviationClamped > 0 ? color.from_gradient(deviationClamped, 0.0, deviationCap, coreLineCol, upperCloudCol) : color.from_gradient(deviationClamped, -deviationCap, 0.0, lowerCloudCol, coreLineCol)

//------------------------------------------------------------------------------
// Distribution diagnostics
//------------------------------------------------------------------------------
float premiumVolume = 0.0
float discountVolume = 0.0
float insideValueVolume = 0.0
float upperTailVolume = 0.0
float lowerTailVolume = 0.0
for i = 0 to profileRows - 1
    float binPrice = rangeLow + priceStep * (i + 0.5)
    float binVol = array.get(profile, i)
    if binPrice > vah
        premiumVolume += binVol
        upperTailVolume += binVol
    else if binPrice < val
        discountVolume += binVol
        lowerTailVolume += binVol
    else
        insideValueVolume += binVol

float premiumShare = totalVolume > 0 ? premiumVolume / totalVolume * 100.0 : 0.0
float discountShare = totalVolume > 0 ? discountVolume / totalVolume * 100.0 : 0.0
float insideShare = totalVolume > 0 ? insideValueVolume / totalVolume * 100.0 : 0.0
float tailSkew = totalVolume > 0 ? (upperTailVolume - lowerTailVolume) / totalVolume * 100.0 : 0.0
float balanceTilt = premiumShare - discountShare
float magnetDistance = math.abs(close - valueMid) / math.max(atrBase, syminfo.mintick)
float axisDistance = math.abs(close - coreAxis) / math.max(atrBase, syminfo.mintick)
float compressionScore = math.max(0.0, 100.0 - math.min(100.0, rangeFill))

var int aboveAxisStreak = 0
var int belowAxisStreak = 0
var int valueAreaStreak = 0
var int axisCrossCount = 0
if barstate.isconfirmed
    if close > coreAxis
        aboveAxisStreak += 1
        belowAxisStreak := 0
    else if close < coreAxis
        belowAxisStreak += 1
        aboveAxisStreak := 0
    else
        aboveAxisStreak := math.max(aboveAxisStreak - 1, 0)
        belowAxisStreak := math.max(belowAxisStreak - 1, 0)
    if close >= val and close <= vah
        valueAreaStreak += 1
    else
        valueAreaStreak := 0
    if ta.cross(close, coreAxis)
        axisCrossCount += 1

string phase = close > vah ? "Premium Auction" : close < val ? "Discount Auction" : valueAreaStreak >= 10 ? "Accepted" : compressionScore > 55 ? "Rotating" : "Balanced"
string axisTone = aboveAxisStreak > belowAxisStreak ? "Above Axis" : belowAxisStreak > aboveAxisStreak ? "Below Axis" : "Axis Shared"
color phaseColor = close > vah ? upperCloudCol : close < val ? lowerCloudCol : valueAreaStreak >= 10 ? coreLineCol : regimeColor

//------------------------------------------------------------------------------
// Visual structure
//------------------------------------------------------------------------------
float innerBand = atrBase * 1.1
float outerBand = atrBase * 2.5
float upperInner = coreAxis + innerBand
float lowerInner = coreAxis - innerBand
float upperOuter = coreAxis + outerBand
float lowerOuter = coreAxis - outerBand

var line axisGuide = na
var line vahGuide = na
var line valGuide = na
var linefill premiumCorridor = na
var linefill discountCorridor = na
if na(axisGuide)
    axisGuide := line.new(bar_index, coreAxis, bar_index + 1, coreAxis, extend = extend.right, color = color.new(coreLineCol, 0), width = 3)
    vahGuide := line.new(bar_index, vah, bar_index + 1, vah, extend = extend.right, color = color.new(upperCloudCol, 0), width = 1, style = line.style_dashed)
    valGuide := line.new(bar_index, val, bar_index + 1, val, extend = extend.right, color = color.new(lowerCloudCol, 0), width = 1, style = line.style_dashed)
    premiumCorridor := linefill.new(axisGuide, vahGuide, color.new(upperCloudCol, 88))
    discountCorridor := linefill.new(valGuide, axisGuide, color.new(lowerCloudCol, 88))
else
    line.set_xy1(axisGuide, bar_index, coreAxis)
    line.set_xy2(axisGuide, bar_index + 1, coreAxis)
    line.set_xy1(vahGuide, bar_index, vah)
    line.set_xy2(vahGuide, bar_index + 1, vah)
    line.set_xy1(valGuide, bar_index, val)
    line.set_xy2(valGuide, bar_index + 1, val)
    linefill.set_color(premiumCorridor, color.new(upperCloudCol, insideShare > 60 ? 84 : 90))
    linefill.set_color(discountCorridor, color.new(lowerCloudCol, insideShare > 60 ? 84 : 90))

plotCore = plot(coreAxis, "Participation Axis", color = color.new(coreLineCol, 0), linewidth = 4, style = plot.style_stepline)
plotRecent = plot(coreAxis, "Recent Highlight", color = color.new(recentLineCol, 0), linewidth = 6, style = plot.style_stepline, show_last = recentHighlight)
plotPOC = plot(rawPoc, "Raw POC", color = color.new(valueAreaCol, 30), linewidth = 2, style = plot.style_linebr)
plotVAH = plot(showValueArea ? vah : na, "Value Area High", color = color.new(valueAreaCol, 0), linewidth = 2, style = plot.style_linebr)
plotVAL = plot(showValueArea ? val : na, "Value Area Low", color = color.new(valueAreaCol, 0), linewidth = 2, style = plot.style_linebr)
plotUpperInner = plot(showValueArea ? upperInner : na, "Upper Inner", color = color.new(upperCloudCol, 70))
plotLowerInner = plot(showValueArea ? lowerInner : na, "Lower Inner", color = color.new(lowerCloudCol, 70))
plotUpperOuter = plot(showValueArea ? upperOuter : na, "Upper Outer", color = color.new(upperCloudCol, 92))
plotLowerOuter = plot(showValueArea ? lowerOuter : na, "Lower Outer", color = color.new(lowerCloudCol, 92))

fill(plotCore, plotVAH, color.new(upperCloudCol, cloudOpacity))
fill(plotCore, plotVAL, color.new(lowerCloudCol, cloudOpacity))
fill(plotVAH, plotPOC, color.new(valueAreaCol, 88))
fill(plotVAL, plotPOC, color.new(valueAreaCol, 88))
fill(plotUpperInner, plotUpperOuter, color.new(upperCloudCol, 94))
fill(plotLowerInner, plotLowerOuter, color.new(lowerCloudCol, 94))

bgcolor(showBackground ? color.new(axisColor, 92) : na, title = "Participation Background")

color candleColor = recolorCandles ? axisColor : na
barcolor(candleColor)

plotcandle(showSyntheticCandles ? open : na, showSyntheticCandles ? high : na, showSyntheticCandles ? low : na, showSyntheticCandles ? close : na, color = axisColor, wickcolor = axisColor, bordercolor = axisColor)

plot(showValueArea ? valueMid : na, "Value Mid", color = color.new(valueAreaCol, 45), linewidth = 1, style = plot.style_linebr)
plot(showValueArea ? coreAxis + atrBase * 0.5 : na, "Axis Upper Guide", color = color.new(upperCloudCol, 92), linewidth = 1, style = plot.style_linebr)
plot(showValueArea ? coreAxis - atrBase * 0.5 : na, "Axis Lower Guide", color = color.new(lowerCloudCol, 92), linewidth = 1, style = plot.style_linebr)

//------------------------------------------------------------------------------
// Ribbon and dashboard
//------------------------------------------------------------------------------
var table ribbon = table.new(position.bottom_center, 15, 2, frame_color = color.new(chart.fg_color, 85), frame_width = 1)
if showRibbon and barstate.islast
    int center = 7
    int active = int(math.round(center + deviationClamped / deviationCap * center))
    active := int(f_clamp(active, 0, 14))
    for col = 0 to 14
        float dist = math.abs(col - center) / float(center)
        color cellCol = col < center ? color.new(lowerCloudCol, int(22 + dist * 55)) : color.new(upperCloudCol, int(22 + dist * 55))
        table.cell(ribbon, col, 0, col == center ? "Axis" : "", bgcolor = col == center ? color.new(coreLineCol, 75) : color.new(chart.bg_color, 100), text_color = chart.fg_color)
        table.cell(ribbon, col, 1, col == active ? " " : "", bgcolor = cellCol)

var table dash = table.new(position.top_right, 2, 12, bgcolor = color.new(color.rgb(8, 10, 17), 0), frame_color = color.new(chart.fg_color, 75), frame_width = 1, border_color = color.new(chart.fg_color, 90), border_width = 1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Covenant", text_color = chart.fg_color, bgcolor = color.new(color.rgb(25, 30, 44), 0), text_size = f_size(dashSize))
    table.cell(dash, 1, 0, phase, text_color = phaseColor, bgcolor = color.new(color.rgb(25, 30, 44), 0), text_size = f_size(dashSize))
    table.cell(dash, 0, 1, "Axis", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 1, str.tostring(coreAxis, format.mintick), text_color = coreLineCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 2, "POC / VA", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 2, str.tostring(rawPoc, format.mintick), text_color = valueAreaCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 3, "VAH", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 3, str.tostring(vah, format.mintick), text_color = upperCloudCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 4, "VAL", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 4, str.tostring(val, format.mintick), text_color = lowerCloudCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 5, "Deviation", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 5, str.tostring(deviationClamped, "#.##") + " ATR", text_color = axisColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 6, "Acceptance", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 6, str.tostring(acceptanceScore, "#.0") + "%", text_color = valueAreaCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 7, "Profile", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 7, str.tostring(profileScore, "#.0") + "% | " + str.tostring(rangeFill, "#.0") + "%", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 0, 8, "Premium", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 8, str.tostring(premiumShare, "#.0") + "%", text_color = upperCloudCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 9, "Discount", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 9, str.tostring(discountShare, "#.0") + "%", text_color = lowerCloudCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 10, "Tilt / Tail", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 10, str.tostring(balanceTilt, "#.0") + " | " + str.tostring(tailSkew, "#.0"), text_color = balanceTilt >= 0 ? upperCloudCol : lowerCloudCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 11, "Streaks", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 11, str.tostring(aboveAxisStreak) + " / " + str.tostring(belowAxisStreak) + " / " + str.tostring(axisCrossCount), text_color = chart.fg_color, text_size = f_size(dashSize))

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
bool axisReclaimUp = enableAlerts and barstate.isconfirmed and ta.crossover(close, coreAxis)
bool axisReclaimDown = enableAlerts and barstate.isconfirmed and ta.crossunder(close, coreAxis)
bool premiumExt = enableAlerts and barstate.isconfirmed and deviationClamped >= deviationCap * 0.85
bool discountExt = enableAlerts and barstate.isconfirmed and deviationClamped <= -deviationCap * 0.85
bool valueAreaBreakUp = enableAlerts and barstate.isconfirmed and ta.crossover(close, vah)
bool valueAreaBreakDown = enableAlerts and barstate.isconfirmed and ta.crossunder(close, val)
bool axisSlopeFlip = enableAlerts and barstate.isconfirmed and (ta.crossover(axisSlope, 0) or ta.crossunder(axisSlope, 0))
bool acceptanceUp = enableAlerts and barstate.isconfirmed and ta.crossover(close, valueMid)
bool acceptanceDown = enableAlerts and barstate.isconfirmed and ta.crossunder(close, valueMid)
bool premiumBalanceFlip = enableAlerts and barstate.isconfirmed and ta.crossover(balanceTilt, 0)
bool discountBalanceFlip = enableAlerts and barstate.isconfirmed and ta.crossunder(balanceTilt, 0)
bool compressionRelease = enableAlerts and barstate.isconfirmed and compressionScore < 35 and compressionScore[1] >= 35

alertcondition(axisReclaimUp, "Covenant Axis Reclaim Up", "Price has reclaimed the participation axis upward.")
alertcondition(axisReclaimDown, "Covenant Axis Reclaim Down", "Price has reclaimed the participation axis downward.")
alertcondition(premiumExt, "Covenant Deep Premium", "Price is deeply extended above the participation axis.")
alertcondition(discountExt, "Covenant Deep Discount", "Price is deeply discounted below the participation axis.")
alertcondition(valueAreaBreakUp, "Covenant Value Area Break Up", "Price has broken above the value area.")
alertcondition(valueAreaBreakDown, "Covenant Value Area Break Down", "Price has broken below the value area.")
alertcondition(axisSlopeFlip, "Covenant Axis Slope Flip", "The participation axis slope has changed direction.")
alertcondition(acceptanceUp, "Covenant Acceptance Up", "Price has reclaimed the value midpoint.")
alertcondition(acceptanceDown, "Covenant Acceptance Down", "Price has lost the value midpoint.")
alertcondition(premiumBalanceFlip, "Covenant Premium Balance Flip", "Participation has rotated into premium balance.")
alertcondition(discountBalanceFlip, "Covenant Discount Balance Flip", "Participation has rotated into discount balance.")
alertcondition(compressionRelease, "Covenant Compression Release", "The participation profile has expanded out of compression.")
````
