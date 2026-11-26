# Pressure Reversal Engine [JOAT]

- url: https://www.tradingview.com/script/Ydvl2cgU-Pressure-Reversal-Engine-JOAT/
- type: indicator
- pine_id: PUB;3f54c65a589d46c5b4242b4d2939e7a7
- version: 1.0

## Description

[b]Pressure Reversal Engine [JOAT][/b]

[b]Introduction[/b]

Pressure Reversal Engine is an open-source pressure and absorption indicator. It estimates buy and sell participation from candle location, body behavior, direction, and volume, then looks for cases where aggressive participation fails to produce continuation.

The script is designed for traders who want to identify absorption, pressure mismatch, reclaim/reject behavior, and stacked imbalance areas without relying on true bid/ask data.

[image]https://www.tradingview.com/x/rte7TpiW/[/image]

[b]Core Concepts[/b]

[b]1. Estimated Buy/Sell Pressure[/b]
The pressure model uses close position within the candle, candle body, direction, and volume. This creates a deterministic approximation that works on symbols where true bid/ask volume is not available.

[b]2. Absorption Detection[/b]
Absorption is identified when strong estimated pressure fails to move price in the expected direction. Demand absorption and supply absorption are tracked separately.

[b]3. Pressure Profile[/b]
A rolling profile divides the recent price range into rows and estimates where buy and sell pressure accumulated. The profile highlights skew, POC, value area, and imbalance zones.

[b]4. Reclaim and Reject Logic[/b]
Swing references help identify whether price reclaimed a prior level or rejected from it. These events can combine with pressure mismatch to create long or short setup states.

[b]5. Stacked Pressure Clusters[/b]
Consecutive bars with strong pressure and volume expansion create cluster boxes. These show areas where participation repeatedly appeared.

[b]Features[/b]

[list]
[*][b]Buy/sell pressure estimation:[/b] Uses candle anatomy and volume to approximate directional participation.
[*][b]Absorption states:[/b] Detects when demand or supply fails to follow through.
[*][b]Rolling pressure profile:[/b] Displays POC, value area, and pressure skew.
[*][b]Stacked pressure boxes:[/b] Highlights repeated pressure bursts over several bars.
[*][b]EMA regime filter:[/b] Optional trend filter for long and short setups.
[*][b]Entry and exit state zones:[/b] Shows confirmed pressure reversal and risk-off states.
[*][b]ATR stop/target rails:[/b] Uses volatility-adjusted projections for setup review.
[*][b]Pressure candle coloring:[/b] Bars can reflect active pressure state.
[*][b]Dashboard:[/b] Shows pressure state, profile skew, POC, value area, absorption, regime, volume, and stack status.
[*][b]Alerts:[/b] Long setup, short setup, long exit, short exit, demand absorption, and supply absorption.
[/list]

[b]Input Parameters[/b]

[b]Core:[/b] Pressure Profile Lookback, Profile Rows, Pressure Gate, Value Area.

[b]Signals:[/b] Entry / Exit State Zones, EMA Regime Filter, Fast EMA, Slow EMA, Swing Left, Swing Right, Projection Bars, Signal Cooldown Bars, Stored Trade Plans.

[b]Cluster, Risk, and Visuals:[/b] Stacked Pressure Boxes, Minimum Stack Bars, Stack Volume Boost, ATR Stop, Target 1 ATR, Target 2 ATR, Right Pressure Profile, Pressure Candle Color, Dashboard, Profile Right Offset.

[b]How to Use This Indicator[/b]

[b]Step 1: Read the pressure state[/b]
Use the dashboard to see whether bid pressure, ask pressure, absorption, or idle conditions dominate.

[b]Step 2: Watch for failed participation[/b]
The strongest reversal information appears when pressure is high but price fails to continue in that pressure direction.

[b]Step 3: Use value area and POC as context[/b]
Reversals near the pressure POC or value area edge can have different meaning than signals in empty areas.

[b]Indicator Limitations[/b]

[list]
[*]Pressure is estimated from candle and volume data; it is not true exchange order flow.
[*]Rolling profiles are approximations and depend on lookback and row settings.
[*]Signals can be delayed by confirmed-bar logic.
[*]Markets with poor volume data can reduce profile usefulness.
[/list]

[b]Originality Statement[/b]

Pressure Reversal Engine is original in the way it combines candle-derived pressure, rolling pressure profile rows, absorption logic, reclaim/reject behavior, stacked pressure clusters, and ATR risk projections into one open-source Pine Script v6 tool.

[b]Disclaimer[/b]

This script is provided for educational and informational purposes only. It is not financial advice or a recommendation to trade. Estimated pressure can be wrong, and all signals can fail. Use proper risk management.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Pressure Reversal Engine [JOAT]", shorttitle="PRE [JOAT]", overlay=true, max_lines_count=240, max_boxes_count=240, max_labels_count=140)

// ============================================================================
// Pressure Reversal Engine [JOAT]
// Original close-confirmed pressure engine for detecting failed participation:
// - Estimated buy/sell pressure profile by price row.
// - Absorption, mismatch, reclaim, and reject states.
// - Stacked pressure boxes with controlled cleanup.
// - Entry/exit-style state zones using labels, boxes, and risk lines.
// ============================================================================

// ============================================================================
// Palette
// ============================================================================
color colBull        = color.rgb(48, 214, 198)
color colBullStrong  = color.rgb(109, 255, 207)
color colBear        = color.rgb(255, 90, 158)
color colBearStrong  = color.rgb(255, 38, 129)
color colControl     = color.rgb(82, 185, 255)
color colViolet      = color.rgb(139, 111, 255)
color colNeutral     = color.rgb(132, 143, 165)
color colHud         = color.rgb(18, 24, 33)
color colHudSoft     = color.new(colHud, 76)

// ============================================================================
// Inputs
// ============================================================================
string groupCore = "Core"
int lookbackBars = input.int(160, "Pressure Profile Lookback", minval=50, maxval=500, group=groupCore)
int profileRows = input.int(28, "Profile Rows", minval=14, maxval=56, group=groupCore)
float pressureGate = input.float(0.18, "Pressure Gate", minval=0.05, maxval=0.60, step=0.01, group=groupCore)
float valueAreaPct = input.float(0.70, "Value Area", minval=0.50, maxval=0.90, step=0.01, group=groupCore)

string groupSignals = "Signals"
bool showTradeStates = input.bool(true, "Entry / Exit State Zones", group=groupSignals)
bool useTrendFilter = input.bool(true, "EMA Regime Filter", group=groupSignals)
int fastEmaLen = input.int(21, "Fast EMA", minval=2, maxval=100, group=groupSignals)
int slowEmaLen = input.int(55, "Slow EMA", minval=5, maxval=240, group=groupSignals)
int pivotLeft = input.int(3, "Swing Left", minval=1, maxval=10, group=groupSignals)
int pivotRight = input.int(3, "Swing Right", minval=1, maxval=10, group=groupSignals)
int projectionBars = input.int(20, "Projection Bars", minval=6, maxval=90, group=groupSignals)
int signalCooldownBars = input.int(10, "Signal Cooldown Bars", minval=0, maxval=100, group=groupSignals)
int maxSignalPlans = input.int(8, "Stored Trade Plans", minval=3, maxval=25, group=groupSignals)

string groupCluster = "Clusters"
bool showClusters = input.bool(true, "Stacked Pressure Boxes", group=groupCluster)
int clusterBars = input.int(3, "Minimum Stack Bars", minval=2, maxval=12, group=groupCluster)
float volumeBoost = input.float(1.10, "Stack Volume Boost", minval=1.0, maxval=3.0, step=0.05, group=groupCluster)

string groupRisk = "Risk"
float stopAtr = input.float(1.25, "ATR Stop", minval=0.25, maxval=5.0, step=0.05, group=groupRisk)
float targetOneAtr = input.float(1.35, "Target 1 ATR", minval=0.25, maxval=6.0, step=0.05, group=groupRisk)
float targetTwoAtr = input.float(2.30, "Target 2 ATR", minval=0.50, maxval=9.0, step=0.05, group=groupRisk)

string groupVisuals = "Visuals"
bool showProfile = input.bool(true, "Right Pressure Profile", group=groupVisuals)
bool colorCandles = input.bool(true, "Pressure Candle Color", group=groupVisuals)
bool showDashboard = input.bool(true, "Dashboard", group=groupVisuals)
int profileRightOffset = input.int(34, "Profile Right Offset", minval=12, maxval=120, group=groupVisuals)

// ============================================================================
// Helpers
// ============================================================================
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(x, hi))

f_range(float h, float l) =>
    math.max(h - l, syminfo.mintick)

// Pressure proxy from candle location and body. This keeps the script usable
// on symbols without true bid/ask volume while remaining deterministic.
f_buy_share(float o, float h, float l, float c) =>
    float rng = f_range(h, l)
    float closePos = (c - l) / rng
    float bodyShare = math.abs(c - o) / rng
    float direction = c >= o ? 1.0 : 0.0
    f_clamp(0.16 + closePos * 0.44 + bodyShare * 0.22 + direction * 0.18, 0.05, 0.95)

f_sum_float(float[] arr) =>
    float total = 0.0
    for i = 0 to array.size(arr) - 1
        total += array.get(arr, i)
    total

f_argmax_float(float[] arr) =>
    int best = 0
    float bestVal = array.get(arr, 0)
    for i = 1 to array.size(arr) - 1
        float v = array.get(arr, i)
        if v > bestVal
            bestVal := v
            best := i
    best

f_clear_boxes(box[] boxes) =>
    while array.size(boxes) > 0
        box.delete(array.pop(boxes))

f_trim_boxes(box[] boxes, int maxItems) =>
    while array.size(boxes) > maxItems
        box.delete(array.shift(boxes))

f_trim_lines(line[] lines, int maxItems) =>
    while array.size(lines) > maxItems
        line.delete(array.shift(lines))

f_trim_labels(label[] labels, int maxItems) =>
    while array.size(labels) > maxItems
        label.delete(array.shift(labels))

// ============================================================================
// Regime, candle anatomy, and pressure metrics
// ============================================================================
float atr = ta.atr(14)
float avgVol = ta.sma(volume, 20)
float volRatio = avgVol > 0.0 ? volume / avgVol : 1.0
float buyShare = f_buy_share(open, high, low, close)
float sellShare = 1.0 - buyShare
float pressure = buyShare - sellShare
bool bidPressure = pressure > pressureGate
bool askPressure = pressure < -pressureGate

float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float body = math.abs(close - open)
float rng = f_range(high, low)
bool compactBody = body / rng < 0.38
bool highParticipation = volRatio > 1.08

float emaFast = ta.ema(close, fastEmaLen)
float emaSlow = ta.ema(close, slowEmaLen)
bool bullRegime = emaFast > emaSlow
bool bearRegime = emaFast < emaSlow

// Absorption occurs when aggressive pressure fails to move the candle in the
// same direction. Mismatch catches directional disagreement without requiring
// a compact range.
bool demandAbsorb = askPressure and close > open and lowerWick > upperWick and compactBody and highParticipation
bool supplyAbsorb = bidPressure and close < open and upperWick > lowerWick and compactBody and highParticipation
bool bullMismatch = close > open and askPressure
bool bearMismatch = close < open and bidPressure

// ============================================================================
// Rolling pressure profile
// ============================================================================
float windowHigh = ta.highest(high, lookbackBars)
float windowLow = ta.lowest(low, lookbackBars)
float windowRange = math.max(windowHigh - windowLow, syminfo.mintick)
float rowSize = windowRange / profileRows

float[] rowBuy = array.new_float(profileRows, 0.0)
float[] rowSell = array.new_float(profileRows, 0.0)
float[] rowVol = array.new_float(profileRows, 0.0)

for i = 0 to lookbackBars - 1
    float mid = hlc3[i]
    if not na(mid)
        int idxRaw = int(math.floor((mid - windowLow) / rowSize))
        int idx = int(f_clamp(idxRaw, 0, profileRows - 1))
        float share = f_buy_share(open[i], high[i], low[i], close[i])
        float v = nz(volume[i])
        array.set(rowVol, idx, array.get(rowVol, idx) + v)
        array.set(rowBuy, idx, array.get(rowBuy, idx) + v * share)
        array.set(rowSell, idx, array.get(rowSell, idx) + v * (1.0 - share))

float totalVol = f_sum_float(rowVol)
int pocIndex = f_argmax_float(rowVol)
float pocLevel = windowLow + (pocIndex + 0.5) * rowSize

int valIndex = pocIndex
int vahIndex = pocIndex
float vaAccum = array.get(rowVol, pocIndex)
if totalVol > 0.0
    int left = pocIndex - 1
    int right = pocIndex + 1
    while vaAccum < totalVol * valueAreaPct and (left >= 0 or right <= profileRows - 1)
        float leftVol = left >= 0 ? array.get(rowVol, left) : -1.0
        float rightVol = right <= profileRows - 1 ? array.get(rowVol, right) : -1.0
        if leftVol >= rightVol and left >= 0
            vaAccum += leftVol
            valIndex := left
            left -= 1
        else if right <= profileRows - 1
            vaAccum += rightVol
            vahIndex := right
            right += 1
        else
            break

float valLevel = windowLow + valIndex * rowSize
float vahLevel = windowLow + (vahIndex + 1) * rowSize
float profileBuy = f_sum_float(rowBuy)
float profileSell = f_sum_float(rowSell)
float profileSkew = totalVol > 0.0 ? (profileBuy - profileSell) / totalVol : 0.0

// ============================================================================
// Swing references for reclaim/reject logic
// ============================================================================
float swingHighPivot = ta.pivothigh(high, pivotLeft, pivotRight)
float swingLowPivot = ta.pivotlow(low, pivotLeft, pivotRight)
var float lastSwingHigh = na
var float lastSwingLow = na

if not na(swingHighPivot)
    lastSwingHigh := swingHighPivot
if not na(swingLowPivot)
    lastSwingLow := swingLowPivot

bool reclaimHigh = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh and bidPressure
bool rejectHigh = not na(lastSwingHigh) and high > lastSwingHigh and close < lastSwingHigh and askPressure
bool reclaimLow = not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow and askPressure
bool rejectLow = not na(lastSwingLow) and low < lastSwingLow and close > lastSwingLow and bidPressure

// ============================================================================
// Close-confirmed entry/exit state engine
// ============================================================================
bool trendAllowsLong = not useTrendFilter or bullRegime
bool trendAllowsShort = not useTrendFilter or bearRegime
bool longLocation = close > pocLevel and close > valLevel
bool shortLocation = close < pocLevel and close < vahLevel
bool rawLongSignal = barstate.isconfirmed and showTradeStates and trendAllowsLong and longLocation and (demandAbsorb or rejectLow or reclaimHigh) and profileSkew > -0.20
bool rawShortSignal = barstate.isconfirmed and showTradeStates and trendAllowsShort and shortLocation and (supplyAbsorb or rejectHigh or reclaimLow) and profileSkew < 0.20
var int lastPressureSignalBar = na
bool pressureSignalReady = na(lastPressureSignalBar) or bar_index - lastPressureSignalBar > signalCooldownBars
bool longSignal = rawLongSignal and pressureSignalReady
bool shortSignal = rawShortSignal and pressureSignalReady
if longSignal or shortSignal
    lastPressureSignalBar := bar_index
bool exitLong = barstate.isconfirmed and (supplyAbsorb or bearMismatch or close < emaFast or rejectHigh)
bool exitShort = barstate.isconfirmed and (demandAbsorb or bullMismatch or close > emaFast or rejectLow)

float longStop = close - atr * stopAtr
float longTargetOne = close + atr * targetOneAtr
float longTargetTwo = close + atr * targetTwoAtr
float shortStop = close + atr * stopAtr
float shortTargetOne = close - atr * targetOneAtr
float shortTargetTwo = close - atr * targetTwoAtr

// ============================================================================
// Stacked pressure cluster tracking
// ============================================================================
var int stackDir = 0
var int stackStart = na
var int stackCount = 0
var float stackHigh = na
var float stackLow = na
var box[] clusterBoxes = array.new_box()

int stackSignal = bidPressure and volRatio > volumeBoost ? 1 : askPressure and volRatio > volumeBoost ? -1 : 0

if stackSignal != 0
    if stackSignal == stackDir
        stackCount += 1
        stackHigh := math.max(stackHigh, high)
        stackLow := math.min(stackLow, low)
    else
        if showClusters and stackCount >= clusterBars and not na(stackStart)
            color clusterFill = stackDir == 1 ? color.new(colBullStrong, 84) : color.new(colBearStrong, 84)
            color clusterBorder = stackDir == 1 ? color.new(colBullStrong, 18) : color.new(colBearStrong, 18)
            array.push(clusterBoxes, box.new(stackStart, stackHigh, bar_index - 1, stackLow, xloc=xloc.bar_index, bgcolor=clusterFill, border_color=clusterBorder))
        stackDir := stackSignal
        stackStart := bar_index
        stackCount := 1
        stackHigh := high
        stackLow := low
else
    if showClusters and stackCount >= clusterBars and not na(stackStart)
        color clusterFill = stackDir == 1 ? color.new(colBullStrong, 84) : color.new(colBearStrong, 84)
        color clusterBorder = stackDir == 1 ? color.new(colBullStrong, 18) : color.new(colBearStrong, 18)
        array.push(clusterBoxes, box.new(stackStart, stackHigh, bar_index - 1, stackLow, xloc=xloc.bar_index, bgcolor=clusterFill, border_color=clusterBorder))
    stackDir := 0
    stackStart := na
    stackCount := 0
    stackHigh := na
    stackLow := na

f_trim_boxes(clusterBoxes, 18)

// ============================================================================
// Visual layers
// ============================================================================
plot(emaFast, "Fast Regime", color=color.new(colBull, bullRegime ? 10 : 75), linewidth=1)
plot(emaSlow, "Slow Regime", color=color.new(colBear, bearRegime ? 10 : 75), linewidth=1)
plot(pocLevel, "Pressure POC", color=colControl, linewidth=2, style=plot.style_linebr)
plot(vahLevel, "Pressure VAH", color=color.new(colBull, 10), linewidth=1, style=plot.style_linebr)
plot(valLevel, "Pressure VAL", color=color.new(colBear, 10), linewidth=1, style=plot.style_linebr)
valueAreaTopPlot = plot(vahLevel, "Pressure Value Area Top Fill", display=display.none)
valueAreaBotPlot = plot(valLevel, "Pressure Value Area Bottom Fill", display=display.none)
fill(valueAreaTopPlot, valueAreaBotPlot, color=color.new(colControl, 92))

color candleColor = na
candleColor := colorCandles and longSignal ? color.new(colBullStrong, 0) : colorCandles and shortSignal ? color.new(colBearStrong, 0) : colorCandles and demandAbsorb ? color.new(colBullStrong, 8) : colorCandles and supplyAbsorb ? color.new(colBearStrong, 8) : colorCandles and bullMismatch ? color.new(colBear, 18) : colorCandles and bearMismatch ? color.new(colBull, 18) : na
barcolor(barstate.isconfirmed ? candleColor : na)

// ============================================================================
// Managed profile and trade-state objects
// ============================================================================
var box[] profileBoxes = array.new_box()
var box[] signalBoxes = array.new_box()
var line[] signalLines = array.new_line()
var label[] signalLabels = array.new_label()

if barstate.islast
    f_clear_boxes(profileBoxes)
    if showProfile and totalVol > 0.0
        float maxRowVol = 0.0
        for i = 0 to profileRows - 1
            maxRowVol := math.max(maxRowVol, array.get(rowVol, i))
        int leftAnchor = bar_index + profileRightOffset
        int rightAnchor = bar_index + profileRightOffset + 10
        for i = 0 to profileRows - 1
            float v = array.get(rowVol, i)
            float b = array.get(rowBuy, i)
            float buyFrac = v > 0.0 ? b / v : 0.5
            float intensity = maxRowVol > 0.0 ? v / maxRowVol : 0.0
            color base = color.from_gradient(buyFrac, 0.0, 1.0, colBearStrong, colBullStrong)
            int alpha = int(f_clamp(94.0 - intensity * 76.0, 14.0, 94.0))
            color border = i == pocIndex ? color.new(colControl, 0) : i >= valIndex and i <= vahIndex ? color.new(colControl, 46) : color.new(colNeutral, 88)
            float top = windowLow + (i + 1) * rowSize
            float bot = windowLow + i * rowSize
            array.push(profileBoxes, box.new(leftAnchor, top, rightAnchor, bot, xloc=xloc.bar_index, bgcolor=color.new(base, alpha), border_color=border))

if longSignal
    float rewardTop = math.max(close, longTargetTwo)
    float rewardBot = math.min(close, longTargetTwo)
    float riskTop = math.max(close, longStop)
    float riskBot = math.min(close, longStop)
    array.push(signalBoxes, box.new(bar_index, rewardTop, bar_index + projectionBars, rewardBot, xloc=xloc.bar_index, bgcolor=color.new(colBullStrong, 88), border_color=color.new(colBullStrong, 18)))
    array.push(signalBoxes, box.new(bar_index, riskTop, bar_index + projectionBars, riskBot, xloc=xloc.bar_index, bgcolor=color.new(colBearStrong, 88), border_color=color.new(colBearStrong, 18)))
    array.push(signalLines, line.new(bar_index, close, bar_index + projectionBars, close, xloc=xloc.bar_index, color=color.white, width=2))
    array.push(signalLines, line.new(bar_index, longStop, bar_index + projectionBars, longStop, xloc=xloc.bar_index, color=colBearStrong, width=2))
    array.push(signalLines, line.new(bar_index, longTargetOne, bar_index + projectionBars, longTargetOne, xloc=xloc.bar_index, color=color.new(colBullStrong, 5), width=1))
    array.push(signalLines, line.new(bar_index, longTargetTwo, bar_index + projectionBars, longTargetTwo, xloc=xloc.bar_index, color=colBullStrong, width=2))
    array.push(signalLabels, label.new(bar_index + projectionBars, close, "BUY REVERSAL\nEntry " + str.tostring(close, format.mintick) + "\nStop " + str.tostring(longStop, format.mintick) + "\nTP1 " + str.tostring(longTargetOne, format.mintick) + "\nTP2 " + str.tostring(longTargetTwo, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.rgb(8, 12, 18), color=color.new(colBullStrong, 6), size=size.small))

if shortSignal
    float rewardTop = math.max(close, shortTargetTwo)
    float rewardBot = math.min(close, shortTargetTwo)
    float riskTop = math.max(close, shortStop)
    float riskBot = math.min(close, shortStop)
    array.push(signalBoxes, box.new(bar_index, rewardTop, bar_index + projectionBars, rewardBot, xloc=xloc.bar_index, bgcolor=color.new(colBullStrong, 88), border_color=color.new(colBullStrong, 18)))
    array.push(signalBoxes, box.new(bar_index, riskTop, bar_index + projectionBars, riskBot, xloc=xloc.bar_index, bgcolor=color.new(colBearStrong, 88), border_color=color.new(colBearStrong, 18)))
    array.push(signalLines, line.new(bar_index, close, bar_index + projectionBars, close, xloc=xloc.bar_index, color=color.white, width=2))
    array.push(signalLines, line.new(bar_index, shortStop, bar_index + projectionBars, shortStop, xloc=xloc.bar_index, color=colBearStrong, width=2))
    array.push(signalLines, line.new(bar_index, shortTargetOne, bar_index + projectionBars, shortTargetOne, xloc=xloc.bar_index, color=color.new(colBullStrong, 5), width=1))
    array.push(signalLines, line.new(bar_index, shortTargetTwo, bar_index + projectionBars, shortTargetTwo, xloc=xloc.bar_index, color=colBullStrong, width=2))
    array.push(signalLabels, label.new(bar_index + projectionBars, close, "SELL REVERSAL\nEntry " + str.tostring(close, format.mintick) + "\nStop " + str.tostring(shortStop, format.mintick) + "\nTP1 " + str.tostring(shortTargetOne, format.mintick) + "\nTP2 " + str.tostring(shortTargetTwo, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(colBearStrong, 6), size=size.small))

f_trim_boxes(signalBoxes, maxSignalPlans * 2)
f_trim_lines(signalLines, maxSignalPlans * 4)
f_trim_labels(signalLabels, maxSignalPlans)

// ============================================================================
// Dashboard and alerts
// ============================================================================
if showDashboard and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, border_width=1, frame_color=color.new(colNeutral, 65), frame_width=1)
    string stateText = longSignal ? "Buy Reversal" : shortSignal ? "Sell Reversal" : bidPressure ? "Bid Pressure" : askPressure ? "Ask Pressure" : "Balanced"
    color stateColor = longSignal ? colBullStrong : shortSignal ? colBearStrong : bidPressure ? colBull : askPressure ? colBear : colNeutral
    table.cell(dash, 0, 0, "Pressure State", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 0, stateText, text_color=stateColor, bgcolor=colHudSoft)
    table.cell(dash, 0, 1, "Profile Skew", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 1, str.tostring(profileSkew * 100.0, "#.0") + "%", text_color=profileSkew >= 0.0 ? colBullStrong : colBearStrong, bgcolor=colHudSoft)
    table.cell(dash, 0, 2, "POC", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 2, str.tostring(pocLevel, format.mintick), text_color=colControl, bgcolor=colHudSoft)
    table.cell(dash, 0, 3, "Value Area", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 3, str.tostring(valLevel, format.mintick) + " / " + str.tostring(vahLevel, format.mintick), text_color=colControl, bgcolor=colHudSoft)
    table.cell(dash, 0, 4, "Absorption", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 4, demandAbsorb ? "Demand" : supplyAbsorb ? "Supply" : "None", text_color=demandAbsorb ? colBullStrong : supplyAbsorb ? colBearStrong : colNeutral, bgcolor=colHudSoft)
    table.cell(dash, 0, 5, "Regime", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 5, bullRegime ? "Bull" : bearRegime ? "Bear" : "Flat", text_color=bullRegime ? colBullStrong : bearRegime ? colBearStrong : colNeutral, bgcolor=colHudSoft)
    table.cell(dash, 0, 6, "Volume", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 6, str.tostring(volRatio, "#.00") + "x", text_color=volRatio > volumeBoost ? colControl : colNeutral, bgcolor=colHudSoft)
    table.cell(dash, 0, 7, "Stack", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 7, stackDir == 1 ? "Bid Stack" : stackDir == -1 ? "Ask Stack" : "Idle", text_color=stackDir == 1 ? colBullStrong : stackDir == -1 ? colBearStrong : colNeutral, bgcolor=colHudSoft)

alertcondition(longSignal, "PRE Long Setup [JOAT]", "Pressure Reversal Engine [JOAT]: close-confirmed long pressure reversal.")
alertcondition(shortSignal, "PRE Short Setup [JOAT]", "Pressure Reversal Engine [JOAT]: close-confirmed short pressure reversal.")
alertcondition(exitLong, "PRE Long Exit State [JOAT]", "Pressure Reversal Engine [JOAT]: long exit/risk-off state.")
alertcondition(exitShort, "PRE Short Exit State [JOAT]", "Pressure Reversal Engine [JOAT]: short exit/risk-off state.")
alertcondition(demandAbsorb, "PRE Demand Absorption [JOAT]", "Pressure Reversal Engine [JOAT]: demand absorption state.")
alertcondition(supplyAbsorb, "PRE Supply Absorption [JOAT]", "Pressure Reversal Engine [JOAT]: supply absorption state.")
````
