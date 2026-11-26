# Tessera Execution Vault [JOAT]

- url: https://www.tradingview.com/script/HVxXs8ov-Tessera-Execution-Vault-JOAT/
- type: indicator
- pine_id: PUB;986e0023e69a49c6b3740419f5343d9f
- version: 1.0

## Description

[b]Tessera Execution Vault [JOAT][/b]

[b]Introduction[/b]

Tessera Execution Vault is an open-source confluence and execution-context indicator. It combines trend, volatility, pressure, VWAP location, structure sweeps, rejection behavior, and a compact transition model into a single score-based framework.

The script is intended to organize market context and display educational trade projections when confluence is high. It should not be treated as a certain signal system.

[image]https://www.tradingview.com/x/AwmR6Amf/[/image]

[b]Core Concepts[/b]

[b]1. Confluence Scoring[/b]

Long and short scores are built from independent evidence such as trend, VWAP, momentum, volume, pressure, CVD proxy, sweep events, and transition persistence.

[b]2. Auction Pressure[/b]

The script estimates bid/offer pressure from candle structure and volume. It then plots a pressure trace near VWAP.

[b]3. Sweep Memory Zones[/b]

When liquidity sweeps, expansion breaks, or auction reclaim conditions occur, the script stores short-lived memory zones.

[b]4. VWAP Deviation Field[/b]

VWAP bands show where price is trading relative to the current auction center.

[b]5. Educational Projection[/b]

When a setup qualifies, the script can draw entry, stop, and target levels based on ATR.

[b]Features[/b]

[list]
[*][b]Score-based long and short context:[/b] Multiple independent factors contribute to each side
[*][b]VWAP auction bands:[/b] Upper and lower deviation fields
[*][b]Pressure and score traces:[/b] Visualizes pressure and confluence around VWAP
[*][b]Sweep memory zones:[/b] Labels discount, premium, liquidity reclaim, and liquidity reject areas
[*][b]Confirmed-bar signals:[/b] Optional closed-bar signal gating
[*][b]Dashboard:[/b] Displays bias, scores, ATR, volume, pressure, CVD proxy, and auction state
[/list]

[b]Input Parameters[/b]

[list]
[*]Operating Preset changes sensitivity for scalping, intraday, swing, low-noise, or showcase modes
[*]Core lengths control EMA, RSI, volume baseline, and sweep window
[*]Risk settings control ATR stop and target projections
[*]Auction settings control pressure and VWAP deviation calculations
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the dashboard bias[/b]

The bias and score rows show which side currently has stronger confluence.

[b]Step 2: Watch memory zones[/b]

Memory zones highlight recent sweep or auction-location events that may remain relevant.

[b]Step 3: Treat projections as educational[/b]

ATR projections show a possible risk framework. They are not recommendations.

[b]Indicator Limitations[/b]

[list]
[*]Pressure and CVD are candle-derived approximations
[*]Confluence does not ensure continuation
[*]ATR projections can be too wide or narrow during sudden volatility changes
[/list]

[b]Originality Statement[/b]

Tessera Execution Vault combines confluence scoring, VWAP auction context, pressure traces, transition persistence, and labelled memory zones in one open-source script. Its purpose is to explain why one side has more contextual evidence than the other.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to trade. Always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Tessera Execution Vault [JOAT]", shorttitle="TEV [JOAT]", overlay=true, max_lines_count=300, max_labels_count=300, max_boxes_count=150, max_bars_back=2000)

// Original JOAT entry model. It scores trend, volatility, pressure, VWAP location,
// wick rejection, structure sweeps, and a compact transition model. Signals are
// close-confirmed by default and projected with ATR stop/target levels.

string gCore = "Core"
string preset = input.string("Intraday", "Operating Preset", options=["Scalping", "Intraday", "Swing", "Low-Noise", "Visual Showcase"], group=gCore)
int fastLenIn = input.int(9, "Fast EMA", minval=1, group=gCore)
int slowLenIn = input.int(21, "Slow EMA", minval=2, group=gCore)
int rsiLen = input.int(14, "RSI Length", minval=2, group=gCore)
int volLen = input.int(30, "Volume Baseline", minval=5, group=gCore)
int swingLen = input.int(12, "Structure Sweep Window", minval=3, maxval=100, group=gCore)

string gRisk = "Risk"
int atrLenIn = input.int(14, "ATR Length", minval=1, group=gRisk)
float minAtrPctIn = input.float(0.12, "Minimum ATR %", minval=0.0, step=0.01, group=gRisk)
float stopAtr = input.float(1.4, "Stop ATR Multiple", minval=0.25, step=0.05, group=gRisk)
float targetOneAtr = input.float(2.0, "Target 1 ATR Multiple", minval=0.25, step=0.05, group=gRisk)
float targetTwoAtr = input.float(3.2, "Target 2 ATR Multiple", minval=0.25, step=0.05, group=gRisk)
int projectionBars = input.int(34, "Projection Bars", minval=5, maxval=300, group=gRisk)

string gSignals = "Signals"
int scoreThresholdIn = input.int(72, "Setup Score Threshold", minval=40, maxval=95, group=gSignals)
int cooldownIn = input.int(10, "Signal Cooldown Bars", minval=0, maxval=200, group=gSignals)
bool requireTrend = input.bool(true, "Require Trend Agreement", group=gSignals)
bool requireVolume = input.bool(false, "Require Volume Expansion", group=gSignals)
bool closeOnly = input.bool(true, "Confirmed-Bar Signals", group=gSignals)

string gVisual = "Visuals"
bool paintCandles = input.bool(true, "Color Candles", group=gVisual)
bool showTrendCloud = input.bool(true, "Show Trend Cloud", group=gVisual)
bool showAuctionBands = input.bool(true, "Show VWAP Deviation Field", group=gVisual)
bool showSweepMemory = input.bool(true, "Show Sweep Memory Zones", group=gVisual)
bool showLedger = input.bool(true, "Show Trade Projection", group=gVisual)
bool showDashboard = input.bool(true, "Show Dashboard", group=gVisual)
int glowTransp = input.int(84, "Glow Transparency", minval=40, maxval=98, group=gVisual)

string gAuction = "Auction Pressure"
int pressureLen = input.int(64, "Pressure Window", minval=8, maxval=400, group=gAuction)
int cvdLen = input.int(21, "CVD Signal Length", minval=2, maxval=200, group=gAuction)
float vwapBandAtr = input.float(1.20, "VWAP Band ATR", minval=0.25, maxval=6.0, step=0.05, group=gAuction)
int memoryZones = input.int(10, "Stored Sweep Zones", minval=1, maxval=30, group=gAuction)

color C_BULL = color.rgb(0, 212, 255)
color C_BEAR = color.rgb(255, 51, 102)
color C_STRONG_BULL = color.rgb(0, 255, 170)
color C_STRONG_BEAR = color.rgb(255, 0, 136)
color C_GOLD = color.rgb(255, 215, 0)
color C_VIOLET = color.rgb(123, 47, 255)
color C_NEUTRAL = color.rgb(140, 150, 165)
color C_PANEL = color.rgb(12, 15, 24, 8)
color C_PANEL_2 = color.rgb(22, 27, 42, 12)
color C_TEXT = color.rgb(230, 236, 245)
color C_DIM = color.rgb(120, 130, 150)
color C_CLEAR = color.rgb(0, 0, 0, 100)

f_clamp(float value, float floor, float ceiling) =>
    math.max(floor, math.min(ceiling, value))

f_scoreColor(float score, bool bullSide) =>
    color.from_gradient(score, 0.0, 100.0, color.new(C_NEUTRAL, 15), bullSide ? C_STRONG_BULL : C_STRONG_BEAR)

f_sideText(int side) =>
    side == 1 ? "LONG" : side == -1 ? "SHORT" : "WAIT"

f_buyShare(float o, float h, float l, float c) =>
    float barRange = math.max(h - l, syminfo.mintick)
    float closePosition = (c - l) / barRange
    float bodyDirection = c > o ? 1.0 : c < o ? 0.0 : 0.5
    float bodyPower = math.abs(c - o) / barRange
    f_clamp(closePosition * 0.54 + bodyDirection * 0.30 + bodyPower * (bodyDirection - 0.5) * 0.32 + 0.14, 0.0, 1.0)

f_pressureText(float value) =>
    value > 12.0 ? "Bid Control" : value < -12.0 ? "Offer Control" : value > 3.0 ? "Bid Lean" : value < -3.0 ? "Offer Lean" : "Balanced"

int fastLen = preset == "Scalping" ? math.max(5, fastLenIn - 2) : preset == "Swing" ? fastLenIn + 4 : fastLenIn
int slowLen = preset == "Scalping" ? math.max(fastLen + 2, slowLenIn - 4) : preset == "Swing" ? slowLenIn + 13 : slowLenIn
int atrLen = preset == "Scalping" ? math.max(5, atrLenIn - 3) : preset == "Swing" ? atrLenIn + 7 : atrLenIn
float minAtrPct = preset == "Low-Noise" ? minAtrPctIn * 1.35 : preset == "Visual Showcase" ? minAtrPctIn * 0.65 : minAtrPctIn
int scoreThreshold = preset == "Scalping" ? math.max(55, scoreThresholdIn - 5) : preset == "Low-Noise" ? math.min(95, scoreThresholdIn + 8) : scoreThresholdIn
int cooldownBars = preset == "Scalping" ? math.max(2, cooldownIn - 4) : preset == "Swing" ? cooldownIn + 8 : cooldownIn

float emaFast = ta.ema(close, fastLen)
float emaSlow = ta.ema(close, slowLen)
bool trendUp = emaFast > emaSlow and close > emaFast
bool trendDown = emaFast < emaSlow and close < emaFast
float atr = ta.atr(atrLen)
float atrPct = close != 0.0 ? atr / close * 100.0 : 0.0
bool enoughRange = atrPct >= minAtrPct
[plusDI, minusDI, adx] = ta.dmi(14, 14)
bool directionalTape = adx > 14
float rsi = ta.rsi(close, rsiLen)
bool momentumUp = rsi > 50 and rsi >= rsi[1]
bool momentumDown = rsi < 50 and rsi <= rsi[1]
float vwap = ta.vwap(hlc3)
bool aboveVwap = close >= vwap
bool belowVwap = close <= vwap
float volBase = ta.sma(volume, volLen)
float volDev = ta.stdev(volume, volLen)
float volZ = volDev > 0.0 ? (volume - volBase) / volDev : 0.0
bool volumeExpansion = volume > volBase * 1.25 or volZ > 1.0
float buyShare = f_buyShare(open, high, low, close)
float buyVol = volume * buyShare
float sellVol = volume * (1.0 - buyShare)
float pressureDenom = math.sum(buyVol + sellVol, pressureLen)
float pressureDelta = pressureDenom > 0.0 ? math.sum(buyVol - sellVol, pressureLen) / pressureDenom * 100.0 : 0.0
float cvd = ta.cum(buyVol - sellVol)
float cvdSignal = ta.ema(cvd, cvdLen)
bool cvdBull = cvd > cvdSignal and cvdSignal >= cvdSignal[1]
bool cvdBear = cvd < cvdSignal and cvdSignal <= cvdSignal[1]
float vwapAtrDistance = atr > 0.0 ? (close - vwap) / atr : 0.0
bool auctionDiscount = vwapAtrDistance < -vwapBandAtr and close > open
bool auctionPremium = vwapAtrDistance > vwapBandAtr and close < open

float rng = math.max(high - low, syminfo.mintick)
float body = math.abs(close - open)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
bool bullRejection = lowerWick > math.max(body, syminfo.mintick) * 1.4 and close > open and close > low + rng * 0.65
bool bearRejection = upperWick > math.max(body, syminfo.mintick) * 1.4 and close < open and close < low + rng * 0.35
float priorLow = ta.lowest(low[1], swingLen)
float priorHigh = ta.highest(high[1], swingLen)
bool downsideSweep = low < priorLow and close > priorLow and close > open
bool upsideSweep = high > priorHigh and close < priorHigh and close < open
float rangePct = close != 0.0 ? (ta.highest(high, 24) - ta.lowest(low, 24)) / close * 100.0 : 0.0
bool compression = rangePct < atrPct * 8.0 and math.abs(emaFast - emaSlow) < atr * 1.7
bool expansionBreakLong = compression[1] and close > ta.highest(high[1], 8) and volumeExpansion
bool expansionBreakShort = compression[1] and close < ta.lowest(low[1], 8) and volumeExpansion

int regimeNow = trendUp and aboveVwap ? 1 : trendDown and belowVwap ? -1 : 0
var int prevRegime = 0
var int bullHold = 1
var int bullTurn = 1
var int bearHold = 1
var int bearTurn = 1
var int flatBull = 1
var int flatBear = 1
if barstate.isconfirmed
    if prevRegime == 1
        bullHold += regimeNow == 1 ? 1 : 0
        bullTurn += regimeNow == -1 ? 1 : 0
    if prevRegime == -1
        bearHold += regimeNow == -1 ? 1 : 0
        bearTurn += regimeNow == 1 ? 1 : 0
    if prevRegime == 0
        flatBull += regimeNow == 1 ? 1 : 0
        flatBear += regimeNow == -1 ? 1 : 0
    prevRegime := regimeNow

float pBullContinue = bullHold + bullTurn > 0 ? bullHold / (bullHold + bullTurn) * 100.0 : 50.0
float pBearContinue = bearHold + bearTurn > 0 ? bearHold / (bearHold + bearTurn) * 100.0 : 50.0
float pFlatBreak = flatBull + flatBear > 0 ? math.max(flatBull, flatBear) / (flatBull + flatBear) * 100.0 : 50.0

float longScore = 0.0
longScore += trendUp ? 20.0 : 0.0
longScore += aboveVwap ? 10.0 : 0.0
longScore += enoughRange ? 8.0 : 0.0
longScore += directionalTape and plusDI > minusDI ? 8.0 : 0.0
longScore += momentumUp ? 12.0 : 0.0
longScore += volumeExpansion ? 12.0 : 0.0
longScore += pressureDelta > 10.0 ? 8.0 : pressureDelta > 0.0 ? 4.0 : 0.0
longScore += cvdBull ? 7.0 : 0.0
longScore += auctionDiscount ? 5.0 : 0.0
longScore += bullRejection ? 10.0 : 0.0
longScore += downsideSweep ? 12.0 : 0.0
longScore += expansionBreakLong ? 8.0 : 0.0
longScore += pBullContinue > 58 ? 8.0 : pFlatBreak > 60 and regimeNow == 1 ? 5.0 : 0.0
longScore := f_clamp(longScore, 0.0, 100.0)

float shortScore = 0.0
shortScore += trendDown ? 20.0 : 0.0
shortScore += belowVwap ? 10.0 : 0.0
shortScore += enoughRange ? 8.0 : 0.0
shortScore += directionalTape and minusDI > plusDI ? 8.0 : 0.0
shortScore += momentumDown ? 12.0 : 0.0
shortScore += volumeExpansion ? 12.0 : 0.0
shortScore += pressureDelta < -10.0 ? 8.0 : pressureDelta < 0.0 ? 4.0 : 0.0
shortScore += cvdBear ? 7.0 : 0.0
shortScore += auctionPremium ? 5.0 : 0.0
shortScore += bearRejection ? 10.0 : 0.0
shortScore += upsideSweep ? 12.0 : 0.0
shortScore += expansionBreakShort ? 8.0 : 0.0
shortScore += pBearContinue > 58 ? 8.0 : pFlatBreak > 60 and regimeNow == -1 ? 5.0 : 0.0
shortScore := f_clamp(shortScore, 0.0, 100.0)

bool canConfirm = closeOnly ? barstate.isconfirmed : true
var int lastSignalBar = na
bool cooldownReady = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars
bool longSignal = canConfirm and cooldownReady and enoughRange and (not requireTrend or trendUp) and (not requireVolume or volumeExpansion) and longScore >= scoreThreshold and longScore > shortScore + 5.0
bool shortSignal = canConfirm and cooldownReady and enoughRange and (not requireTrend or trendDown) and (not requireVolume or volumeExpansion) and shortScore >= scoreThreshold and shortScore > longScore + 5.0
if longSignal or shortSignal
    lastSignalBar := bar_index

int activeSide = longScore > shortScore + 5.0 ? 1 : shortScore > longScore + 5.0 ? -1 : 0
plotFast = plot(showTrendCloud ? emaFast : na, "Fast Ledger Mean", color=color.new(C_BULL, 25), linewidth=1)
plotSlow = plot(showTrendCloud ? emaSlow : na, "Slow Ledger Mean", color=color.new(C_BEAR, 25), linewidth=1)
fill(plotFast, plotSlow, color=showTrendCloud ? color.new(activeSide == 1 ? C_BULL : activeSide == -1 ? C_BEAR : C_NEUTRAL, 88) : na, title="Regime Cloud")
plot(vwap, "VWAP Control", color=color.new(C_VIOLET, 15), linewidth=2)
auctionUpper = plot(showAuctionBands ? vwap + atr * vwapBandAtr : na, "Upper Auction Band", color=color.new(C_STRONG_BEAR, 58), linewidth=1)
auctionLower = plot(showAuctionBands ? vwap - atr * vwapBandAtr : na, "Lower Auction Band", color=color.new(C_STRONG_BULL, 58), linewidth=1)
auctionOuterUpper = plot(showAuctionBands ? vwap + atr * vwapBandAtr * 2.0 : na, "Outer Upper Auction Band", color=color.new(C_STRONG_BEAR, 82), linewidth=2)
auctionOuterLower = plot(showAuctionBands ? vwap - atr * vwapBandAtr * 2.0 : na, "Outer Lower Auction Band", color=color.new(C_STRONG_BULL, 82), linewidth=2)
fill(auctionUpper, auctionOuterUpper, color=showAuctionBands ? color.new(C_STRONG_BEAR, 91) : na, title="Upper Auction Glow")
fill(auctionLower, auctionOuterLower, color=showAuctionBands ? color.new(C_STRONG_BULL, 91) : na, title="Lower Auction Glow")
float pressureTrace = vwap + atr * f_clamp(pressureDelta / 35.0, -1.75, 1.75)
float scoreTrace = vwap + atr * f_clamp((longScore - shortScore) / 45.0, -1.75, 1.75)
color pressureTraceColor = pressureDelta >= 0.0 ? color.new(C_STRONG_BULL, 18) : color.new(C_STRONG_BEAR, 18)
color scoreTraceColor = activeSide == 1 ? color.new(C_BULL, 8) : activeSide == -1 ? color.new(C_BEAR, 8) : color.new(C_NEUTRAL, 34)
plot(showAuctionBands ? pressureTrace : na, "Auction Pressure Trace", color=pressureTraceColor, linewidth=2)
plot(showAuctionBands ? scoreTrace : na, "Confluence Spread Trace", color=scoreTraceColor, linewidth=1)
bgcolor(showAuctionBands and math.abs(pressureDelta) > 18.0 ? color.new(pressureDelta > 0.0 ? C_STRONG_BULL : C_STRONG_BEAR, 96) : na)
barcolor(paintCandles ? (activeSide == 1 ? f_scoreColor(longScore, true) : activeSide == -1 ? f_scoreColor(shortScore, false) : color.new(C_NEUTRAL, 25)) : na)

var box[] sweepBoxes = array.new<box>()
f_pruneSweepBoxes() =>
    while array.size(sweepBoxes) > memoryZones
        box.delete(array.shift(sweepBoxes))

bool bullishMemoryEvent = showSweepMemory and canConfirm and (downsideSweep or expansionBreakLong or auctionDiscount)
bool bearishMemoryEvent = showSweepMemory and canConfirm and (upsideSweep or expansionBreakShort or auctionPremium)
if bullishMemoryEvent
    int zoneReach = math.max(6, int(math.round(projectionBars * 0.5)))
    color zoneColor = color.new(C_STRONG_BULL, downsideSweep ? 86 : 91)
    string zoneText = downsideSweep ? "TEV LIQUIDITY RECLAIM" : auctionDiscount ? "TEV DISCOUNT VAULT" : "TEV BID MEMORY"
    array.push(sweepBoxes, box.new(bar_index, math.min(open, close), bar_index + zoneReach, low, xloc=xloc.bar_index, border_color=color.new(C_STRONG_BULL, 36), bgcolor=zoneColor, text=zoneText, text_color=C_TEXT, text_size=size.tiny))
    f_pruneSweepBoxes()
if bearishMemoryEvent
    int zoneReach = math.max(6, int(math.round(projectionBars * 0.5)))
    color zoneColor = color.new(C_STRONG_BEAR, upsideSweep ? 86 : 91)
    string zoneText = upsideSweep ? "TEV LIQUIDITY REJECT" : auctionPremium ? "TEV PREMIUM VAULT" : "TEV OFFER MEMORY"
    array.push(sweepBoxes, box.new(bar_index, high, bar_index + zoneReach, math.max(open, close), xloc=xloc.bar_index, border_color=color.new(C_STRONG_BEAR, 36), bgcolor=zoneColor, text=zoneText, text_color=C_TEXT, text_size=size.tiny))
    f_pruneSweepBoxes()

var line entryLine = na
var line stopLine = na
var line t1Line = na
var line t2Line = na
var box riskBox = na
var box rewardBox = na
var label setupLabel = na

if showLedger and (longSignal or shortSignal)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(t1Line)
        line.delete(t1Line)
    if not na(t2Line)
        line.delete(t2Line)
    if not na(riskBox)
        box.delete(riskBox)
    if not na(rewardBox)
        box.delete(rewardBox)
    if not na(setupLabel)
        label.delete(setupLabel)
    int side = longSignal ? 1 : -1
    float entry = close
    float stop = side == 1 ? entry - atr * stopAtr : entry + atr * stopAtr
    float t1 = side == 1 ? entry + atr * targetOneAtr : entry - atr * targetOneAtr
    float t2 = side == 1 ? entry + atr * targetTwoAtr : entry - atr * targetTwoAtr
    color sideColor = side == 1 ? C_STRONG_BULL : C_STRONG_BEAR
    int x2 = bar_index + projectionBars
    entryLine := line.new(bar_index, entry, x2, entry, color=C_TEXT, width=2)
    stopLine := line.new(bar_index, stop, x2, stop, color=C_BEAR, width=2)
    t1Line := line.new(bar_index, t1, x2, t1, color=C_STRONG_BULL, width=1)
    t2Line := line.new(bar_index, t2, x2, t2, color=C_STRONG_BULL, width=2)
    riskBox := box.new(bar_index, math.max(entry, stop), x2, math.min(entry, stop), border_color=color.new(C_BEAR, 65), bgcolor=color.new(C_BEAR, glowTransp))
    rewardBox := box.new(bar_index, math.max(entry, t2), x2, math.min(entry, t2), border_color=color.new(sideColor, 72), bgcolor=color.new(sideColor, glowTransp))
    setupLabel := label.new(bar_index, side == 1 ? low - atr * 0.35 : high + atr * 0.35, f_sideText(side) + "\nScore " + str.tostring(side == 1 ? longScore : shortScore, "#") + "\nEntry " + str.tostring(entry, format.mintick) + "\nStop " + str.tostring(stop, format.mintick) + "\nTP1 " + str.tostring(t1, format.mintick) + "\nTP2 " + str.tostring(t2, format.mintick), style=side == 1 ? label.style_label_up : label.style_label_down, textcolor=color.rgb(5, 8, 12), color=color.new(sideColor, 0), size=size.small)

var table dash = table.new(position.top_right, 2, 11, border_width=1, border_color=color.new(C_VIOLET, 55), frame_color=color.new(C_VIOLET, 30), bgcolor=C_PANEL)
var bool dashMerged = false
f_cell(int col, int row, string cellText, color txtColor, color bgColor) =>
    table.cell(dash, col, row, cellText, text_color=txtColor, bgcolor=bgColor, text_size=size.small)

if barstate.islast and showDashboard
    if not dashMerged
        table.merge_cells(dash, 0, 0, 1, 0)
        dashMerged := true
    table.cell(dash, 0, 0, "Tessera Execution Vault", text_color=C_TEXT, bgcolor=color.new(C_VIOLET, 20), text_size=size.small)
    f_cell(0, 1, "Bias", C_DIM, C_PANEL)
    f_cell(1, 1, f_sideText(activeSide), activeSide == 1 ? C_BULL : activeSide == -1 ? C_BEAR : C_NEUTRAL, C_PANEL)
    f_cell(0, 2, "Long Score", C_DIM, C_PANEL_2)
    f_cell(1, 2, str.tostring(longScore, "#"), f_scoreColor(longScore, true), C_PANEL_2)
    f_cell(0, 3, "Short Score", C_DIM, C_PANEL)
    f_cell(1, 3, str.tostring(shortScore, "#"), f_scoreColor(shortScore, false), C_PANEL)
    f_cell(0, 4, "ATR %", C_DIM, C_PANEL_2)
    f_cell(1, 4, str.tostring(atrPct, "#.##"), enoughRange ? C_GOLD : C_DIM, C_PANEL_2)
    f_cell(0, 5, "Volume Z", C_DIM, C_PANEL)
    f_cell(1, 5, str.tostring(volZ, "#.##"), volumeExpansion ? C_GOLD : C_DIM, C_PANEL)
    f_cell(0, 6, "Hold Prob", C_DIM, C_PANEL_2)
    f_cell(1, 6, activeSide == 1 ? str.tostring(pBullContinue, "#") + "%" : activeSide == -1 ? str.tostring(pBearContinue, "#") + "%" : str.tostring(pFlatBreak, "#") + "%", activeSide == 1 ? C_BULL : activeSide == -1 ? C_BEAR : C_NEUTRAL, C_PANEL_2)
    f_cell(0, 7, "VWAP ATR", C_DIM, C_PANEL)
    f_cell(1, 7, str.tostring(atr > 0 ? (close - vwap) / atr : 0, "#.##"), close >= vwap ? C_BULL : C_BEAR, C_PANEL)
    f_cell(0, 8, "Pressure", C_DIM, C_PANEL_2)
    f_cell(1, 8, f_pressureText(pressureDelta), pressureDelta >= 0 ? C_BULL : C_BEAR, C_PANEL_2)
    f_cell(0, 9, "CVD", C_DIM, C_PANEL)
    f_cell(1, 9, cvdBull ? "Rising" : cvdBear ? "Falling" : "Flat", cvdBull ? C_STRONG_BULL : cvdBear ? C_STRONG_BEAR : C_NEUTRAL, C_PANEL)
    f_cell(0, 10, "Auction", C_DIM, C_PANEL_2)
    f_cell(1, 10, auctionDiscount ? "Discount Reclaim" : auctionPremium ? "Premium Reject" : "Midfield", auctionDiscount ? C_STRONG_BULL : auctionPremium ? C_STRONG_BEAR : C_DIM, C_PANEL_2)

alertcondition(longSignal, "TEV Long Setup [JOAT]", "Tessera Execution Vault [JOAT]: confirmed long setup.")
alertcondition(shortSignal, "TEV Short Setup [JOAT]", "Tessera Execution Vault [JOAT]: confirmed short setup.")
alertcondition(longSignal or shortSignal, "TEV Any Setup [JOAT]", "Tessera Execution Vault [JOAT]: confirmed setup.")
alertcondition(bullishMemoryEvent, "TEV Bullish Memory Zone [JOAT]", "Tessera Execution Vault [JOAT]: bullish sweep or discount memory zone confirmed.")
alertcondition(bearishMemoryEvent, "TEV Bearish Memory Zone [JOAT]", "Tessera Execution Vault [JOAT]: bearish sweep or premium memory zone confirmed.")
alertcondition(auctionDiscount and canConfirm, "TEV Discount Reclaim [JOAT]", "Tessera Execution Vault [JOAT]: VWAP discount reclaim confirmed.")
alertcondition(auctionPremium and canConfirm, "TEV Premium Reject [JOAT]", "Tessera Execution Vault [JOAT]: VWAP premium rejection confirmed.")
alertcondition(pressureDelta > 18.0 and canConfirm, "TEV Bid Pressure Expansion [JOAT]", "Tessera Execution Vault [JOAT]: bid pressure expansion confirmed.")
alertcondition(pressureDelta < -18.0 and canConfirm, "TEV Offer Pressure Expansion [JOAT]", "Tessera Execution Vault [JOAT]: offer pressure expansion confirmed.")
````
