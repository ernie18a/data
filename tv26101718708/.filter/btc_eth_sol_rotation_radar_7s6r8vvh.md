# BTC ETH SOL Rotation Radar

- url: https://www.tradingview.com/script/7s6R8VVH-BTC-ETH-SOL-Rotation-Radar/
- type: indicator
- pine_id: PUB;2c636b606bfc43bcbb175e281ee4dc12
- version: 1.0

## Description

# BTC–ETH–SOL Rotation Radar

**Follow the strongest trend. Rotate with the market. Stay out when nothing deserves your capital.**

The **BTC–ETH–SOL Rotation Radar** is a dynamic asset-ranking indicator designed to identify where momentum is flowing across the three largest crypto leaders. Instead of analyzing a single chart in isolation, it continuously compares **Bitcoin, Ethereum and Solana** to determine which asset currently offers the strongest probability of outperforming.

Rather than relying on a single metric, the Rotation Radar builds a composite score from multiple market characteristics:

• Multi-timeframe relative strength (fast, medium and slow performance)
• Momentum acceleration
• RSI quality (rewarding healthy momentum while penalising extremes)
• EMA trend structure
• Volume confirmation
• Exhaustion detection using RSI and distance from the long-term EMA

Each asset receives a score between **0 and 100**, allowing you to instantly identify the current market leader.

## Rotation Logic

A rotation signal is only generated when all of the following conditions are satisfied:

* The leading asset exceeds the minimum required score.
* It has a sufficient score advantage over your current holding.
* The signal passes the cooldown filter.
* Optional candle-close confirmation is satisfied.

This prevents unnecessary switching during noisy market conditions and focuses only on meaningful leadership changes.

When all tracked assets weaken simultaneously and fall below their long-term trend, the indicator can optionally recommend moving to **Cash**, helping traders avoid periods where capital preservation is statistically preferable.

## Dashboard

The built-in dashboard displays:

* Current score of BTC, ETH and SOL
* Relative ranking
* Short-term performance
* Momentum acceleration
* RSI
* Current market state
* Current holding
* Suggested destination
* Rotation edge
* Final decision

This provides a quick institutional-style overview of market leadership without having to switch between multiple charts.

## Why use Rotation Radar?

Markets rarely move uniformly.

Capital constantly rotates between major assets.

Often Bitcoin leads.
Later Ethereum catches up.
Sometimes Solana becomes the strongest performer.

The goal of this indicator is to identify these rotations objectively instead of relying on emotion or narrative.

## Features

• Composite scoring model
• Relative strength ranking
• Momentum acceleration analysis
• Trend quality assessment
• Volume confirmation
• Exhaustion penalty
• Defensive Cash mode
• Rotation alerts
• Fully configurable weights
• Dashboard summary
• Automatic or manual holding selection

This indicator is designed for swing traders, position traders and investors looking to systematically allocate capital toward the strongest major crypto asset while reducing exposure during periods of broad market weakness.

**Note:** Like all technical indicators, Rotation Radar should be used alongside sound risk management and additional market analysis. It is designed to identify improving relative strength and leadership—not to predict future prices with certainty.
:::

## Source Code

````pine
//@version=6
indicator("BTC–ETH–SOL Rotation Radar", shorttitle="Rotation Radar", overlay=false, max_labels_count=500)

//──────────────────────────────────────────────────────────────────────────────
// PURPOSE
// Ranks BTC, ETH and SOL using relative strength, acceleration, RSI, trend,
// volume and exhaustion. It then identifies the strongest destination asset
// and prints a rotation signal only when the new leader has a sufficient edge.
//──────────────────────────────────────────────────────────────────────────────

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────
groupSymbols = "1. Symbols"
btcSymbol = input.symbol("BINANCE:BTCUSDT", "BTC symbol", group=groupSymbols)
ethSymbol = input.symbol("BINANCE:ETHUSDT", "ETH symbol", group=groupSymbols)
solSymbol = input.symbol("BINANCE:SOLUSDT", "SOL symbol", group=groupSymbols)

groupHolding = "2. Rotation Decision"
currentHolding = input.string(
     "Auto",
     "Current holding",
     options=["Auto", "BTC", "ETH", "SOL", "Cash"],
     group=groupHolding,
     tooltip="Auto tries to infer the holding from the chart ticker. Choose BTC, ETH, SOL or Cash when using the indicator on another chart.")

minimumScoreEdge = input.float(
     6.0,
     "Minimum score advantage",
     minval=0.0,
     step=0.5,
     group=groupHolding,
     tooltip="The leader must exceed the current holding by at least this many score points before a rotation is suggested.")

minimumLeaderScore = input.float(
     55.0,
     "Minimum leader score",
     minval=0.0,
     maxval=100.0,
     step=1.0,
     group=groupHolding)

signalCooldown = input.int(
     8,
     "Signal cooldown bars",
     minval=0,
     group=groupHolding)

confirmOnClose = input.bool(
     true,
     "Confirm rotation on candle close",
     group=groupHolding)

allowRotateToCash = input.bool(
     true,
     "Allow defensive CASH signal",
     group=groupHolding,
     tooltip="Suggests cash when all three assets have weak scores and bearish trends.")

cashThreshold = input.float(
     38.0,
     "Cash threshold",
     minval=0.0,
     maxval=100.0,
     step=1.0,
     group=groupHolding)

groupPeriods = "3. Calculation Periods"
fastLookback = input.int(8, "Fast performance lookback", minval=2, group=groupPeriods)
mediumLookback = input.int(24, "Medium performance lookback", minval=3, group=groupPeriods)
slowLookback = input.int(72, "Slow performance lookback", minval=5, group=groupPeriods)
rsiLength = input.int(14, "RSI length", minval=2, group=groupPeriods)
emaFastLength = input.int(21, "Fast EMA", minval=1, group=groupPeriods)
emaSlowLength = input.int(55, "Slow EMA", minval=2, group=groupPeriods)
volumeLength = input.int(20, "Volume average", minval=2, group=groupPeriods)
accelerationLookback = input.int(5, "Acceleration comparison", minval=1, group=groupPeriods)

groupWeights = "4. Score Weights"
weightFast = input.float(20.0, "Fast relative strength", minval=0.0, group=groupWeights)
weightMedium = input.float(20.0, "Medium relative strength", minval=0.0, group=groupWeights)
weightSlow = input.float(10.0, "Slow relative strength", minval=0.0, group=groupWeights)
weightAcceleration = input.float(15.0, "Momentum acceleration", minval=0.0, group=groupWeights)
weightRsi = input.float(10.0, "RSI quality", minval=0.0, group=groupWeights)
weightTrend = input.float(15.0, "EMA trend", minval=0.0, group=groupWeights)
weightVolume = input.float(10.0, "Volume confirmation", minval=0.0, group=groupWeights)

groupRisk = "5. Exhaustion Controls"
useExhaustionPenalty = input.bool(true, "Penalise overextended leaders", group=groupRisk)
rsiOverbought = input.float(75.0, "RSI overbought level", minval=50.0, maxval=100.0, group=groupRisk)
maxEmaExtensionPct = input.float(8.0, "Maximum extension above slow EMA (%)", minval=0.1, step=0.5, group=groupRisk)
maximumPenalty = input.float(18.0, "Maximum exhaustion penalty", minval=0.0, maxval=50.0, step=1.0, group=groupRisk)

groupDisplay = "6. Display"
showScores = input.bool(true, "Plot asset scores", group=groupDisplay)
showTable = input.bool(true, "Show rotation table", group=groupDisplay)
showBackground = input.bool(true, "Highlight current leader", group=groupDisplay)
showSignals = input.bool(true, "Show rotation markers", group=groupDisplay)
showLeaderLine = input.bool(false, "Plot leader score only", group=groupDisplay)

//──────────────────────────────────────────────────────────────────────────────
// Data
//──────────────────────────────────────────────────────────────────────────────
btcClose = request.security(btcSymbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
ethClose = request.security(ethSymbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
solClose = request.security(solSymbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

btcVolume = request.security(btcSymbol, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off)
ethVolume = request.security(ethSymbol, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off)
solVolume = request.security(solSymbol, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off)

//──────────────────────────────────────────────────────────────────────────────
// Helpers
//──────────────────────────────────────────────────────────────────────────────
clamp(value, low, high) =>
    math.max(low, math.min(high, value))

pctChange(src, length) =>
    na(src[length]) or src[length] == 0.0 ? na : 100.0 * (src / src[length] - 1.0)

safeDiv(numerator, denominator, fallback) =>
    denominator == 0.0 or na(denominator) ? fallback : numerator / denominator

rankScore(value, valueB, valueC) =>
    value > valueB and value > valueC ? 100.0 :
     value < valueB and value < valueC ? 0.0 :
     50.0

fmt(value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0")

fmtPct(value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "%"

assetColor(asset) =>
    asset == "BTC" ? color.orange :
     asset == "ETH" ? color.purple :
     asset == "SOL" ? color.aqua :
     color.silver

//──────────────────────────────────────────────────────────────────────────────
// Raw metrics
//──────────────────────────────────────────────────────────────────────────────
btcFast = pctChange(btcClose, fastLookback)
ethFast = pctChange(ethClose, fastLookback)
solFast = pctChange(solClose, fastLookback)

btcMedium = pctChange(btcClose, mediumLookback)
ethMedium = pctChange(ethClose, mediumLookback)
solMedium = pctChange(solClose, mediumLookback)

btcSlow = pctChange(btcClose, slowLookback)
ethSlow = pctChange(ethClose, slowLookback)
solSlow = pctChange(solClose, slowLookback)

btcAcceleration = btcFast - nz(btcFast[accelerationLookback])
ethAcceleration = ethFast - nz(ethFast[accelerationLookback])
solAcceleration = solFast - nz(solFast[accelerationLookback])

btcRsi = ta.rsi(btcClose, rsiLength)
ethRsi = ta.rsi(ethClose, rsiLength)
solRsi = ta.rsi(solClose, rsiLength)

btcEmaFast = ta.ema(btcClose, emaFastLength)
ethEmaFast = ta.ema(ethClose, emaFastLength)
solEmaFast = ta.ema(solClose, emaFastLength)

btcEmaSlow = ta.ema(btcClose, emaSlowLength)
ethEmaSlow = ta.ema(ethClose, emaSlowLength)
solEmaSlow = ta.ema(solClose, emaSlowLength)

btcVolumeRatio = safeDiv(btcVolume, ta.sma(btcVolume, volumeLength), 1.0)
ethVolumeRatio = safeDiv(ethVolume, ta.sma(ethVolume, volumeLength), 1.0)
solVolumeRatio = safeDiv(solVolume, ta.sma(solVolume, volumeLength), 1.0)

btcExtension = 100.0 * safeDiv(btcClose - btcEmaSlow, btcEmaSlow, 0.0)
ethExtension = 100.0 * safeDiv(ethClose - ethEmaSlow, ethEmaSlow, 0.0)
solExtension = 100.0 * safeDiv(solClose - solEmaSlow, solEmaSlow, 0.0)

//──────────────────────────────────────────────────────────────────────────────
// Component scores
// Relative-performance components are ranked against the other two assets.
// RSI, trend and volume components measure the quality of each move.
//──────────────────────────────────────────────────────────────────────────────
btcFastScore = rankScore(btcFast, ethFast, solFast)
ethFastScore = rankScore(ethFast, btcFast, solFast)
solFastScore = rankScore(solFast, btcFast, ethFast)

btcMediumScore = rankScore(btcMedium, ethMedium, solMedium)
ethMediumScore = rankScore(ethMedium, btcMedium, solMedium)
solMediumScore = rankScore(solMedium, btcMedium, ethMedium)

btcSlowScore = rankScore(btcSlow, ethSlow, solSlow)
ethSlowScore = rankScore(ethSlow, btcSlow, solSlow)
solSlowScore = rankScore(solSlow, btcSlow, ethSlow)

btcAccelerationScore = rankScore(btcAcceleration, ethAcceleration, solAcceleration)
ethAccelerationScore = rankScore(ethAcceleration, btcAcceleration, solAcceleration)
solAccelerationScore = rankScore(solAcceleration, btcAcceleration, ethAcceleration)

// RSI quality rewards constructive momentum but does not reward extreme RSI indefinitely.
rsiQuality(rsiValue) =>
    rsiValue <= 30.0 ? 15.0 :
     rsiValue < 50.0 ? 15.0 + (rsiValue - 30.0) * 1.75 :
     rsiValue <= 68.0 ? 50.0 + (rsiValue - 50.0) * 2.5 :
     rsiValue <= rsiOverbought ? 95.0 - (rsiValue - 68.0) * 2.0 :
     clamp(81.0 - (rsiValue - rsiOverbought) * 4.0, 0.0, 81.0)

btcRsiScore = rsiQuality(btcRsi)
ethRsiScore = rsiQuality(ethRsi)
solRsiScore = rsiQuality(solRsi)

trendQuality(price, emaFast, emaSlow) =>
    price > emaFast and emaFast > emaSlow ? 100.0 :
     price > emaSlow ? 65.0 :
     emaFast > emaSlow ? 45.0 :
     10.0

btcTrendScore = trendQuality(btcClose, btcEmaFast, btcEmaSlow)
ethTrendScore = trendQuality(ethClose, ethEmaFast, ethEmaSlow)
solTrendScore = trendQuality(solClose, solEmaFast, solEmaSlow)

volumeQuality(volumeRatio, priceReturn) =>
    base = clamp((volumeRatio - 0.70) / 0.90 * 100.0, 0.0, 100.0)
    priceReturn >= 0.0 ? base : 100.0 - base

btcVolumeScore = volumeQuality(btcVolumeRatio, btcFast)
ethVolumeScore = volumeQuality(ethVolumeRatio, ethFast)
solVolumeScore = volumeQuality(solVolumeRatio, solFast)

weightTotal = weightFast + weightMedium + weightSlow + weightAcceleration + weightRsi + weightTrend + weightVolume

rawScore(
     fastScore,
     mediumScore,
     slowScore,
     accelerationScore,
     rsiScore,
     trendScore,
     volumeScore) =>
    weighted =
         fastScore * weightFast +
         mediumScore * weightMedium +
         slowScore * weightSlow +
         accelerationScore * weightAcceleration +
         rsiScore * weightRsi +
         trendScore * weightTrend +
         volumeScore * weightVolume
    safeDiv(weighted, weightTotal, 50.0)

exhaustionPenalty(rsiValue, extensionPct) =>
    rsiPenalty = rsiValue > rsiOverbought ? clamp((rsiValue - rsiOverbought) / (100.0 - rsiOverbought), 0.0, 1.0) : 0.0
    extensionPenalty = extensionPct > maxEmaExtensionPct ? clamp((extensionPct - maxEmaExtensionPct) / maxEmaExtensionPct, 0.0, 1.0) : 0.0
    useExhaustionPenalty ? math.max(rsiPenalty, extensionPenalty) * maximumPenalty : 0.0

btcScore = clamp(rawScore(btcFastScore, btcMediumScore, btcSlowScore, btcAccelerationScore, btcRsiScore, btcTrendScore, btcVolumeScore) - exhaustionPenalty(btcRsi, btcExtension), 0.0, 100.0)
ethScore = clamp(rawScore(ethFastScore, ethMediumScore, ethSlowScore, ethAccelerationScore, ethRsiScore, ethTrendScore, ethVolumeScore) - exhaustionPenalty(ethRsi, ethExtension), 0.0, 100.0)
solScore = clamp(rawScore(solFastScore, solMediumScore, solSlowScore, solAccelerationScore, solRsiScore, solTrendScore, solVolumeScore) - exhaustionPenalty(solRsi, solExtension), 0.0, 100.0)

//──────────────────────────────────────────────────────────────────────────────
// Leadership and destination
//──────────────────────────────────────────────────────────────────────────────
leader =
     btcScore >= ethScore and btcScore >= solScore ? "BTC" :
     ethScore >= btcScore and ethScore >= solScore ? "ETH" :
     "SOL"

leaderScore =
     leader == "BTC" ? btcScore :
     leader == "ETH" ? ethScore :
     solScore

secondScore =
     leader == "BTC" ? math.max(ethScore, solScore) :
     leader == "ETH" ? math.max(btcScore, solScore) :
     math.max(btcScore, ethScore)

leaderEdge = leaderScore - secondScore

allBearish =
     btcClose < btcEmaSlow and
     ethClose < ethEmaSlow and
     solClose < solEmaSlow

cashRegime =
     allowRotateToCash and
     leaderScore < cashThreshold and
     allBearish

destination = cashRegime ? "CASH" : leader

chartHolding =
     str.contains(str.upper(syminfo.ticker), "BTC") ? "BTC" :
     str.contains(str.upper(syminfo.ticker), "ETH") ? "ETH" :
     str.contains(str.upper(syminfo.ticker), "SOL") ? "SOL" :
     "Cash"

holding = currentHolding == "Auto" ? chartHolding : currentHolding

holdingScore =
     holding == "BTC" ? btcScore :
     holding == "ETH" ? ethScore :
     holding == "SOL" ? solScore :
     0.0

destinationScore = destination == "CASH" ? 100.0 - leaderScore : leaderScore
rotationAdvantage = destination == "CASH" ? cashThreshold - leaderScore : destinationScore - holdingScore

differentAsset = destination != holding
leaderQualified = destination == "CASH" or leaderScore >= minimumLeaderScore
edgeQualified = destination == "CASH" ? cashRegime : rotationAdvantage >= minimumScoreEdge
confirmed = not confirmOnClose or barstate.isconfirmed

var int lastSignalBar = na
cooldownReady = na(lastSignalBar) or bar_index - lastSignalBar > signalCooldown

rawRotationSignal =
     differentAsset and
     leaderQualified and
     edgeQualified and
     cooldownReady

rotationSignal = rawRotationSignal and confirmed

if rotationSignal
    lastSignalBar := bar_index

rotateToBtc = rotationSignal and destination == "BTC"
rotateToEth = rotationSignal and destination == "ETH"
rotateToSol = rotationSignal and destination == "SOL"
rotateToCash = rotationSignal and destination == "CASH"

//──────────────────────────────────────────────────────────────────────────────
// Asset states
//──────────────────────────────────────────────────────────────────────────────
state(score, acceleration, asset) =>
    score >= 70.0 and acceleration > 0.0 and asset == leader ? "LEADER ↑" :
     score >= 60.0 and acceleration > 0.0 ? "IMPROVING ↑" :
     score >= 55.0 ? "STRONG" :
     score >= 45.0 and acceleration > 0.0 ? "RECOVERING" :
     score >= 45.0 ? "NEUTRAL" :
     acceleration > 0.0 ? "WEAK ↑" :
     "WEAKENING ↓"

btcState = state(btcScore, btcAcceleration, "BTC")
ethState = state(ethScore, ethAcceleration, "ETH")
solState = state(solScore, solAcceleration, "SOL")

decisionText =
     not differentAsset ? "HOLD " + holding :
     not leaderQualified ? "WAIT — LEADER TOO WEAK" :
     not edgeQualified ? "WAIT — EDGE TOO SMALL" :
     destination == "CASH" ? "REDUCE RISK → CASH" :
     "ROTATE " + holding + " → " + destination

//──────────────────────────────────────────────────────────────────────────────
// Plots
//──────────────────────────────────────────────────────────────────────────────
hline(70.0, "Strong", color=color.new(color.gray, 70))
hline(50.0, "Neutral", color=color.new(color.gray, 80))
hline(30.0, "Weak", color=color.new(color.gray, 70))

plot(showScores ? btcScore : na, "BTC score", color=color.orange, linewidth=2)
plot(showScores ? ethScore : na, "ETH score", color=color.purple, linewidth=2)
plot(showScores ? solScore : na, "SOL score", color=color.aqua, linewidth=2)
plot(showLeaderLine ? leaderScore : na, "Leader score", color=color.white, linewidth=3)

bgcolor(
     showBackground ?
     cashRegime ? color.new(color.gray, 86) :
     leader == "BTC" ? color.new(color.orange, 90) :
     leader == "ETH" ? color.new(color.purple, 90) :
     color.new(color.aqua, 90) :
     na)

plotshape(
     showSignals and rotateToBtc,
     title="Rotate to BTC",
     style=shape.labelup,
     location=location.bottom,
     text="→BTC",
     color=color.orange,
     textcolor=color.black,
     size=size.tiny)

plotshape(
     showSignals and rotateToEth,
     title="Rotate to ETH",
     style=shape.labelup,
     location=location.bottom,
     text="→ETH",
     color=color.purple,
     textcolor=color.white,
     size=size.tiny)

plotshape(
     showSignals and rotateToSol,
     title="Rotate to SOL",
     style=shape.labelup,
     location=location.bottom,
     text="→SOL",
     color=color.aqua,
     textcolor=color.black,
     size=size.tiny)

plotshape(
     showSignals and rotateToCash,
     title="Rotate to cash",
     style=shape.labeldown,
     location=location.top,
     text="→CASH",
     color=color.gray,
     textcolor=color.white,
     size=size.tiny)

// Data Window diagnostics
plot(btcFast, "BTC fast return", display=display.data_window)
plot(ethFast, "ETH fast return", display=display.data_window)
plot(solFast, "SOL fast return", display=display.data_window)
plot(btcAcceleration, "BTC acceleration", display=display.data_window)
plot(ethAcceleration, "ETH acceleration", display=display.data_window)
plot(solAcceleration, "SOL acceleration", display=display.data_window)
plot(leaderEdge, "Leader edge over second place", display=display.data_window)
plot(rotationAdvantage, "Destination advantage over holding", display=display.data_window)

//──────────────────────────────────────────────────────────────────────────────
// Alerts
//──────────────────────────────────────────────────────────────────────────────
alertcondition(rotateToBtc, "Rotate to BTC", "BTC has become the qualified rotation leader.")
alertcondition(rotateToEth, "Rotate to ETH", "ETH has become the qualified rotation leader.")
alertcondition(rotateToSol, "Rotate to SOL", "SOL has become the qualified rotation leader.")
alertcondition(rotateToCash, "Reduce risk to cash", "All tracked assets are weak and below their slow trends.")
alertcondition(rotationSignal, "Any rotation signal", "The Rotation Radar has detected a qualified leadership change.")

//──────────────────────────────────────────────────────────────────────────────
// Dashboard
//──────────────────────────────────────────────────────────────────────────────
var table dashboard = table.new(position.top_right, 7, 7, border_width=1)

rankOf(score, otherA, otherB) =>
    score >= otherA and score >= otherB ? "1" :
     score <= otherA and score <= otherB ? "3" :
     "2"

if barstate.islast and showTable
    headerBg = color.new(color.gray, 35)

    table.cell(dashboard, 0, 0, "Asset", text_color=color.white, bgcolor=headerBg)
    table.cell(dashboard, 1, 0, "Score", text_color=color.white, bgcolor=headerBg)
    table.cell(dashboard, 2, 0, "Rank", text_color=color.white, bgcolor=headerBg)
    table.cell(dashboard, 3, 0, "Fast", text_color=color.white, bgcolor=headerBg)
    table.cell(dashboard, 4, 0, "Accel.", text_color=color.white, bgcolor=headerBg)
    table.cell(dashboard, 5, 0, "RSI", text_color=color.white, bgcolor=headerBg)
    table.cell(dashboard, 6, 0, "State", text_color=color.white, bgcolor=headerBg)

    table.cell(dashboard, 0, 1, "BTC", text_color=color.orange)
    table.cell(dashboard, 1, 1, fmt(btcScore), text_color=color.orange)
    table.cell(dashboard, 2, 1, rankOf(btcScore, ethScore, solScore), text_color=color.orange)
    table.cell(dashboard, 3, 1, fmtPct(btcFast), text_color=color.orange)
    table.cell(dashboard, 4, 1, fmtPct(btcAcceleration), text_color=btcAcceleration >= 0 ? color.lime : color.red)
    table.cell(dashboard, 5, 1, fmt(btcRsi), text_color=color.orange)
    table.cell(dashboard, 6, 1, btcState, text_color=btcState == "LEADER ↑" ? color.lime : color.orange)

    table.cell(dashboard, 0, 2, "ETH", text_color=color.purple)
    table.cell(dashboard, 1, 2, fmt(ethScore), text_color=color.purple)
    table.cell(dashboard, 2, 2, rankOf(ethScore, btcScore, solScore), text_color=color.purple)
    table.cell(dashboard, 3, 2, fmtPct(ethFast), text_color=color.purple)
    table.cell(dashboard, 4, 2, fmtPct(ethAcceleration), text_color=ethAcceleration >= 0 ? color.lime : color.red)
    table.cell(dashboard, 5, 2, fmt(ethRsi), text_color=color.purple)
    table.cell(dashboard, 6, 2, ethState, text_color=ethState == "LEADER ↑" ? color.lime : color.purple)

    table.cell(dashboard, 0, 3, "SOL", text_color=color.aqua)
    table.cell(dashboard, 1, 3, fmt(solScore), text_color=color.aqua)
    table.cell(dashboard, 2, 3, rankOf(solScore, btcScore, ethScore), text_color=color.aqua)
    table.cell(dashboard, 3, 3, fmtPct(solFast), text_color=color.aqua)
    table.cell(dashboard, 4, 3, fmtPct(solAcceleration), text_color=solAcceleration >= 0 ? color.lime : color.red)
    table.cell(dashboard, 5, 3, fmt(solRsi), text_color=color.aqua)
    table.cell(dashboard, 6, 3, solState, text_color=solState == "LEADER ↑" ? color.lime : color.aqua)

    table.cell(dashboard, 0, 4, "Holding", text_color=color.white, bgcolor=color.new(color.gray, 75))
    table.cell(dashboard, 1, 4, holding, text_color=assetColor(holding), bgcolor=color.new(color.gray, 75))
    table.cell(dashboard, 2, 4, "Leader", text_color=color.white, bgcolor=color.new(color.gray, 75))
    table.cell(dashboard, 3, 4, destination, text_color=assetColor(destination), bgcolor=color.new(color.gray, 75))
    table.cell(dashboard, 4, 4, "Edge", text_color=color.white, bgcolor=color.new(color.gray, 75))
    table.cell(dashboard, 5, 4, fmt(rotationAdvantage), text_color=rotationAdvantage >= minimumScoreEdge ? color.lime : color.yellow, bgcolor=color.new(color.gray, 75))
    table.cell(dashboard, 6, 4, destination == "CASH" ? "DEFENSIVE" : "RISK ON", text_color=destination == "CASH" ? color.silver : color.lime, bgcolor=color.new(color.gray, 75))

    table.cell(dashboard, 0, 5, "Decision", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(dashboard, 1, 5, decisionText, text_color=rotationSignal ? color.lime : color.white, bgcolor=color.new(color.gray, 50))
    table.merge_cells(dashboard, 1, 5, 6, 5)

    table.cell(dashboard, 0, 6, "Requirement", text_color=color.white)
    table.cell(dashboard, 1, 6, "Leader ≥ " + fmt(minimumLeaderScore), text_color=leaderQualified ? color.lime : color.red)
    table.cell(dashboard, 2, 6, "Edge ≥ " + fmt(minimumScoreEdge), text_color=edgeQualified ? color.lime : color.red)
    table.cell(dashboard, 3, 6, "Leader edge", text_color=color.white)
    table.cell(dashboard, 4, 6, fmt(leaderEdge), text_color=color.white)
    table.cell(dashboard, 5, 6, "Cooldown", text_color=color.white)
    table.cell(dashboard, 6, 6, cooldownReady ? "READY" : "WAIT", text_color=cooldownReady ? color.lime : color.yellow)

if barstate.islast and not showTable
    table.clear(dashboard, 0, 0, 6, 6)
````
