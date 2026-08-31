<!-- tradingview-pine-id: PUB;cb703affb89a44d396e371e4a0ce0338 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive Trend Pulse Pro [JPT]

Source: https://www.tradingview.com/script/yiBe8gPR-Adaptive-Trend-Pulse-Pro-JPT/

## Description

🔷 OVERVIEW

Adaptive Trend Pulse Pro [JPT] is a professional trend-following and trade-management indicator designed to help traders identify confirmed market direction, filter weaker setups, and structure potential trades with predefined Entry, Stop Loss, and Take Profit levels.

The system combines an adaptive trend engine, EMA confirmation, RSI momentum, volume analysis, candle momentum, signal scoring, ATR-based risk management, and multi-market monitoring into one streamlined TradingView indicator.

It is designed for traders who want a cleaner way to evaluate trend transitions without relying on a single indicator or isolated signal.

🔷 CORE CONCEPT

The indicator follows a simple principle:

Detect the trend → Confirm the setup → Score the signal → Define risk → Manage the trade.

Instead of treating every trend change as an immediate trading opportunity, the system applies additional confirmation filters before displaying a potential LONG or SHORT setup.

This helps make the signals more selective and provides a structured framework for discretionary trading.

🔷 SIGNAL ENGINE

The Adaptive Trend Engine continuously evaluates price movement and volatility to determine the current market direction.

🟢 LONG Environment

A bullish environment is identified when the adaptive trend structure shifts upward.

Additional confirmation can come from:

Price above the EMA
RSI bullish momentum
Above-average volume
Bullish candle momentum
Confirmed candle close

🔴 SHORT Environment

A bearish environment is identified when the adaptive trend structure shifts downward.

Additional confirmation can come from:

Price below the EMA
RSI bearish momentum
Above-average volume
Bearish candle momentum
Confirmed candle close

🔷 SIGNAL SCORE

The indicator includes a Signal Score designed to help distinguish stronger setups from weaker ones.

The score evaluates multiple conditions rather than relying on trend direction alone.

Higher score = stronger confirmation.

Users can adjust the Minimum Signal Score depending on their preferred trading style.

Suggested approach

3/4 — Balanced

More opportunities while still requiring confirmation.

4/4 — Strict

Fewer signals with stronger confirmation requirements.

🔷 ENTRY SYSTEM

When a confirmed LONG or SHORT setup appears, the indicator automatically establishes an approximate trading entry based on the confirmed signal candle.

LONG

LONG → Entry → Stop Loss → TP1 → TP2 → TP3

SHORT

SHORT → Entry → Stop Loss → TP1 → TP2 → TP3

The levels are dynamically calculated from current market volatility.

🔷 STOP LOSS

The Stop Loss is calculated using ATR-based volatility.

This allows the distance to adapt to the market rather than using one fixed number of points.

The Stop ATR Multiplier can be adjusted according to the market and timeframe.

A higher multiplier provides a wider volatility allowance.

A lower multiplier creates a tighter risk level.

🔷 TAKE PROFIT SYSTEM

The indicator provides three structured targets:

🎯 TP1 — 1R

First objective.

🎯 TP2 — 2R

Second objective.

🎯 TP3 — 3R

Extended objective.

The R-multiple is based on the distance between Entry and the initial Stop Loss.

Example:

Entry = 100
Stop = 98

Risk = 2 points.

Therefore:

TP1 = 102
TP2 = 104
TP3 = 106

🔷 BREAK-EVEN MANAGEMENT

After TP1 is reached, the indicator can move the active Stop Loss toward the original Entry level.

This allows traders to protect the position after the first objective has been reached.

TP1 → Break-Even → TP2 → TP3

This feature can be enabled or disabled from the settings.

🔷 ATR TRAILING STOP

After TP2, an optional ATR trailing mechanism can be activated.

The trailing stop dynamically follows price based on current volatility.

This is intended to help protect open profit while allowing the trend enough room to continue.

🔷 RISK / REWARD ZONES

The chart can display visual risk/reward areas around an active setup.

The zones help traders immediately see:

🟢 Potential reward area
🔴 Risk area
⚪ Entry level

This makes it easier to visually evaluate the trade structure before taking action.

🔷 MULTI-ASSET SCANNER

The dashboard can monitor multiple markets simultaneously.

Example:

BTCUSDT — LONG
ETHUSDT — LONG
SOLUSDT — NEUTRAL
EURUSD — SHORT
XAUUSD — LONG

This allows traders to quickly compare market conditions without opening multiple charts.

🔷 PERFORMANCE DASHBOARD

The indicator includes a compact dashboard showing information such as:

Signal Score
Win Rate
Wins
Losses
Break-Even trades
Closed Trades
Current Trade Status

The dashboard is intended as a reference tool rather than a guarantee of future performance.

🔷 ALERT SYSTEM

Alerts are available for important events including:

🔔 LONG confirmation
🔔 SHORT confirmation
🔔 TP1 reached
🔔 TP2 reached
🔔 TP3 reached
🔔 Stop level reached

This allows traders to monitor setups without constantly watching the chart.

🔷 CONFIRMED SIGNAL LOGIC

The indicator uses confirmed-bar logic for its primary LONG and SHORT signals.

Signals are therefore intended to be confirmed at candle close rather than triggering from an unfinished candle.

However, this does not eliminate normal market risk or guarantee that every historical signal will behave the same way in live trading.

🔷 RECOMMENDED MARKETS

The system can be tested on a variety of liquid markets, including:

🥇 XAUUSD / Gold
₿ BTCUSDT
♦️ ETHUSDT
🟣 SOLUSDT
💵 EURUSD
📈 Major indices

The optimal settings can vary significantly between instruments and timeframes.

🔷 RECOMMENDED SETUP
Balanced Configuration

Amplitude: 12
ATR Length: 100
Channel Multiplier: 2.0
EMA: 200
RSI: 14
Minimum Score: 3/4
Cooldown: 5 bars
Stop ATR: 1.5
TP1: 1R
TP2: 2R
TP3: 3R
Break-Even: ON
ATR Trailing: ON

These are starting settings, not guaranteed optimal settings. Backtesting and forward testing should be performed for each market/timeframe.

🔷 HOW TO USE

🟢 LONG
Wait for the adaptive trend to turn bullish.
Wait for the confirmation score to meet your minimum requirement.
Wait for the confirmed LONG signal.
Review Entry and Stop Loss.
Evaluate the risk/reward structure.
Monitor TP1, TP2 and TP3.
Use Break-Even and trailing management if desired.

🔴 SHORT
Wait for the adaptive trend to turn bearish.
Wait for the confirmation score.
Wait for the confirmed SHORT signal.
Review Entry and Stop Loss.
Evaluate risk/reward.
Monitor TP1, TP2 and TP3.
Manage the position according to your risk plan.

🔷 IMPORTANT

Adaptive Trend Pulse Pro [JPT] is a technical analysis tool, not a guaranteed-profit system.

No indicator can guarantee a specific win rate or eliminate losing trades. Market conditions, volatility, spreads, liquidity and timeframe can all affect results.

Always test the indicator on your preferred market and timeframe and use appropriate risk management.

Adaptive Trend Pulse Pro [JPT]
Detect the trend • Confirm the setup • Define the risk • Manage the move

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Adaptive Trend Pulse Pro [JPT]", shorttitle="ATP Pro [JPT]", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpCore = "01 • Adaptive Trend Engine"
amplitude = input.int(12, "Trend Amplitude", minval=2, maxval=100, group=grpCore)
atrLength = input.int(100, "ATR Length", minval=5, group=grpCore)
channelMult = input.float(2.0, "Channel Multiplier", minval=0.25, step=0.25, group=grpCore)

grpConfirm = "02 • Signal Confirmation"
useEMA = input.bool(true, "EMA Confirmation", group=grpConfirm)
emaLength = input.int(200, "EMA Length", minval=10, group=grpConfirm)

useRSI = input.bool(true, "RSI Confirmation", group=grpConfirm)
rsiLength = input.int(14, "RSI Length", minval=2, group=grpConfirm)

useVolume = input.bool(true, "Volume Confirmation", group=grpConfirm)
volumeLength = input.int(20, "Volume Average", minval=2, group=grpConfirm)

minScore = input.int(3, "Minimum Signal Score", minval=1, maxval=4, group=grpConfirm)
cooldownBars = input.int(5, "Signal Cooldown", minval=0, maxval=100, group=grpConfirm)

grpRisk = "03 • Trade Levels"
riskATR = input.float(1.5, "Stop ATR Multiplier", minval=0.25, step=0.25, group=grpRisk)
tp1RR = input.float(1.0, "TP1 R:R", minval=0.25, step=0.25, group=grpRisk)
tp2RR = input.float(2.0, "TP2 R:R", minval=0.5, step=0.25, group=grpRisk)
tp3RR = input.float(3.0, "TP3 R:R", minval=1.0, step=0.25, group=grpRisk)

moveBE = input.bool(true, "Move Stop To Break-Even After TP1", group=grpRisk)
useTrail = input.bool(true, "ATR Trailing Stop After TP2", group=grpRisk)
trailATR = input.float(1.0, "Trailing ATR", minval=0.25, step=0.25, group=grpRisk)

grpVisual = "04 • Visuals"
showBands = input.bool(true, "Show Adaptive Bands", group=grpVisual)
showEMA = input.bool(false, "Show EMA", group=grpVisual)
showTradeLevels = input.bool(true, "Show Entry / SL / TP", group=grpVisual)
showZones = input.bool(true, "Show Risk / Reward Zones", group=grpVisual)
showLabels = input.bool(true, "Show Signal Labels", group=grpVisual)

bullColor = input.color(color.lime, "Bullish Color", group=grpVisual)
bearColor = input.color(color.red, "Bearish Color", group=grpVisual)
entryColor = input.color(color.white, "Entry Color", group=grpVisual)
tpColor = input.color(color.aqua, "Target Color", group=grpVisual)
slColor = input.color(color.red, "Stop Color", group=grpVisual)

grpDash = "05 • Dashboard"
showDashboard = input.bool(true, "Show Performance Dashboard", group=grpDash)
showScanner = input.bool(true, "Show Multi-Asset Scanner", group=grpDash)

sym1 = input.symbol("BINANCE:BTCUSDT", "Asset 1", group=grpDash)
sym2 = input.symbol("BINANCE:ETHUSDT", "Asset 2", group=grpDash)
sym3 = input.symbol("BINANCE:SOLUSDT", "Asset 3", group=grpDash)
sym4 = input.symbol("OANDA:EURUSD", "Asset 4", group=grpDash)
sym5 = input.symbol("OANDA:XAUUSD", "Asset 5", group=grpDash)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE TREND ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atr = ta.atr(atrLength)
halfATR = atr * 0.5
channel = atr * channelMult

highestIndex = math.abs(ta.highestbars(high, amplitude))
lowestIndex = math.abs(ta.lowestbars(low, amplitude))

highSwing = high[highestIndex]
lowSwing = low[lowestIndex]

highAverage = ta.sma(high, amplitude)
lowAverage = ta.sma(low, amplitude)

var int trend = 0
var int nextTrend = 0

var float maxLow = na
var float minHigh = na

var float bullLine = na
var float bearLine = na

if barstate.isfirst
    maxLow := low
    minHigh := high
    bullLine := low
    bearLine := high

if nextTrend == 1
    maxLow := math.max(maxLow, lowSwing)

    if highAverage < maxLow and close < nz(low[1], low)
        trend := 1
        nextTrend := 0
        minHigh := highSwing
else
    minHigh := math.min(minHigh, highSwing)

    if lowAverage > minHigh and close > nz(high[1], high)
        trend := 0
        nextTrend := 1
        maxLow := lowSwing

if trend == 0
    if trend[1] != 0
        bullLine := nz(bearLine[1], low)
    else
        bullLine := math.max(maxLow, nz(bullLine[1], maxLow))
else
    if trend[1] != 1
        bearLine := nz(bullLine[1], high)
    else
        bearLine := math.min(minHigh, nz(bearLine[1], minHigh))

adaptiveLine = trend == 0 ? bullLine : bearLine

upperBand = adaptiveLine + channel
lowerBand = adaptiveLine - channel

bullTrend = trend == 0
bearTrend = trend == 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONFIRMATION ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ema = ta.ema(close, emaLength)
rsi = ta.rsi(close, rsiLength)

volumeAverage = ta.sma(volume, volumeLength)
volumeOK = volume > volumeAverage

emaLongOK = close > ema
emaShortOK = close < ema

rsiLongOK = rsi > 52
rsiShortOK = rsi < 48

// Momentum confirmation
bullMomentum = close > close[1] and close > open
bearMomentum = close < close[1] and close < open

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL SCORE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longScore = 0
shortScore = 0

if bullTrend
    longScore += 1

if bearTrend
    shortScore += 1

if useEMA and emaLongOK
    longScore += 1

if useEMA and emaShortOK
    shortScore += 1

if useRSI and rsiLongOK
    longScore += 1

if useRSI and rsiShortOK
    shortScore += 1

if useVolume and volumeOK
    if bullTrend
        longScore += 1
    if bearTrend
        shortScore += 1

// Momentum can act as an additional quality filter.
longQuality = bullMomentum
shortQuality = bearMomentum

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RAW TREND CHANGES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullFlip = bullTrend and trend[1] == 1
bearFlip = bearTrend and trend[1] == 0

var int lastSignalBar = na

cooldownOK = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars

longSignal =
     bullFlip and
     longScore >= minScore and
     longQuality and
     cooldownOK and
     barstate.isconfirmed

shortSignal =
     bearFlip and
     shortScore >= minScore and
     shortQuality and
     cooldownOK and
     barstate.isconfirmed

if longSignal or shortSignal
    lastSignalBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int tradeState = 0
var float entryPrice = na
var float initialStop = na
var float activeStop = na

var float tp1 = na
var float tp2 = na
var float tp3 = na

var bool tp1Hit = false
var bool tp2Hit = false

var int entryBar = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PERFORMANCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int totalTrades = 0
var int wins = 0
var int losses = 0
var int breakeven = 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW LONG
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if longSignal

    tradeState := 1

    entryPrice := close

    initialStop := close - atr * riskATR
    activeStop := initialStop

    riskDistance = entryPrice - initialStop

    tp1 := entryPrice + riskDistance * tp1RR
    tp2 := entryPrice + riskDistance * tp2RR
    tp3 := entryPrice + riskDistance * tp3RR

    tp1Hit := false
    tp2Hit := false

    entryBar := bar_index

    totalTrades += 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW SHORT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if shortSignal

    tradeState := -1

    entryPrice := close

    initialStop := close + atr * riskATR
    activeStop := initialStop

    riskDistance = initialStop - entryPrice

    tp1 := entryPrice - riskDistance * tp1RR
    tp2 := entryPrice - riskDistance * tp2RR
    tp3 := entryPrice - riskDistance * tp3RR

    tp1Hit := false
    tp2Hit := false

    entryBar := bar_index

    totalTrades += 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TARGET EVENTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longTP1 =
     tradeState == 1 and
     not tp1Hit and
     bar_index > entryBar and
     high >= tp1

longTP2 =
     tradeState == 1 and
     tp1Hit and
     not tp2Hit and
     high >= tp2

longTP3 =
     tradeState == 1 and
     tp2Hit and
     high >= tp3

shortTP1 =
     tradeState == -1 and
     not tp1Hit and
     bar_index > entryBar and
     low <= tp1

shortTP2 =
     tradeState == -1 and
     tp1Hit and
     not tp2Hit and
     low <= tp2

shortTP3 =
     tradeState == -1 and
     tp2Hit and
     low <= tp3

if longTP1 or shortTP1
    tp1Hit := true

if longTP2 or shortTP2
    tp2Hit := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAK-EVEN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if moveBE and tp1Hit

    if tradeState == 1
        activeStop := math.max(activeStop, entryPrice)

    if tradeState == -1
        activeStop := math.min(activeStop, entryPrice)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRAILING STOP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if useTrail and tp2Hit

    trailDistance = atr * trailATR

    if tradeState == 1
        trailingLevel = close - trailDistance
        activeStop := math.max(activeStop, trailingLevel)

    if tradeState == -1
        trailingLevel = close + trailDistance
        activeStop := math.min(activeStop, trailingLevel)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXIT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longStopHit =
     tradeState == 1 and
     bar_index > entryBar and
     low <= activeStop

shortStopHit =
     tradeState == -1 and
     bar_index > entryBar and
     high >= activeStop

longFinished =
     tradeState == 1 and
     tp2Hit and
     high >= tp3

shortFinished =
     tradeState == -1 and
     tp2Hit and
     low <= tp3

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE RESULT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if longFinished

    wins += 1
    tradeState := 0

if shortFinished

    wins += 1
    tradeState := 0

if longStopHit

    if tp1Hit
        breakeven += 1
    else
        losses += 1

    tradeState := 0

if shortStopHit

    if tp1Hit
        breakeven += 1
    else
        losses += 1

    tradeState := 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT PERFORMANCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

closedTrades = wins + losses + breakeven

winRate =
     closedTrades > 0 ?
     wins / closedTrades * 100 :
     0.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendColor = bullTrend ? bullColor : bearColor

plot(
     adaptiveLine,
     "Adaptive Trend",
     color=trendColor,
     linewidth=3)

pUpper = plot(
     showBands ? upperBand : na,
     "Upper Adaptive Band",
     color=color.new(bearColor, 65),
     linewidth=1)

pLower = plot(
     showBands ? lowerBand : na,
     "Lower Adaptive Band",
     color=color.new(bullColor, 65),
     linewidth=1)

fill(
     pUpper,
     pLower,
     color=color.new(trendColor, 93),
     title="Trend Channel")

plot(
     showEMA ? ema : na,
     "EMA Filter",
     color=color.orange,
     linewidth=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if longSignal and showLabels

    label.new(
         bar_index,
         low,
         "LONG\n" + str.tostring(longScore) + "/4",
         style=label.style_label_up,
         color=bullColor,
         textcolor=color.black,
         size=size.small)

if shortSignal and showLabels

    label.new(
         bar_index,
         high,
         "SHORT\n" + str.tostring(shortScore) + "/4",
         style=label.style_label_down,
         color=bearColor,
         textcolor=color.white,
         size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

activeTrade = tradeState != 0

plot(
     showTradeLevels and activeTrade ? entryPrice : na,
     "Entry",
     color=entryColor,
     linewidth=2,
     style=plot.style_linebr)

plot(
     showTradeLevels and activeTrade ? activeStop : na,
     "Active Stop",
     color=slColor,
     linewidth=2,
     style=plot.style_linebr)

plot(
     showTradeLevels and activeTrade ? tp1 : na,
     "TP1",
     color=color.new(tpColor, 50),
     linewidth=1,
     style=plot.style_linebr)

plot(
     showTradeLevels and activeTrade ? tp2 : na,
     "TP2",
     color=color.new(tpColor, 25),
     linewidth=1,
     style=plot.style_linebr)

plot(
     showTradeLevels and activeTrade ? tp3 : na,
     "TP3",
     color=tpColor,
     linewidth=2,
     style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RISK / REWARD ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box rewardBox = na
var box riskBox = na

if longSignal and showZones

    box.delete(rewardBox)
    box.delete(riskBox)

    rewardBox := box.new(
         bar_index,
         tp3,
         bar_index + 30,
         entryPrice,
         bgcolor=color.new(bullColor, 88),
         border_color=color.new(bullColor, 65))

    riskBox := box.new(
         bar_index,
         entryPrice,
         bar_index + 30,
         initialStop,
         bgcolor=color.new(slColor, 88),
         border_color=color.new(slColor, 65))

if shortSignal and showZones

    box.delete(rewardBox)
    box.delete(riskBox)

    rewardBox := box.new(
         bar_index,
         entryPrice,
         bar_index + 30,
         tp3,
         bgcolor=color.new(bullColor, 88),
         border_color=color.new(bullColor, 65))

    riskBox := box.new(
         bar_index,
         initialStop,
         bar_index + 30,
         entryPrice,
         bgcolor=color.new(slColor, 88),
         border_color=color.new(slColor, 65))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TARGET LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if longTP1
    label.new(
         bar_index,
         tp1,
         "✓ TP1",
         style=label.style_label_down,
         color=tpColor,
         textcolor=color.black,
         size=size.tiny)

if longTP2
    label.new(
         bar_index,
         tp2,
         "✓ TP2",
         style=label.style_label_down,
         color=tpColor,
         textcolor=color.black,
         size=size.tiny)

if longTP3
    label.new(
         bar_index,
         tp3,
         "✓ TP3",
         style=label.style_label_down,
         color=bullColor,
         textcolor=color.black,
         size=size.tiny)

if shortTP1
    label.new(
         bar_index,
         tp1,
         "✓ TP1",
         style=label.style_label_up,
         color=tpColor,
         textcolor=color.black,
         size=size.tiny)

if shortTP2
    label.new(
         bar_index,
         tp2,
         "✓ TP2",
         style=label.style_label_up,
         color=tpColor,
         textcolor=color.black,
         size=size.tiny)

if shortTP3
    label.new(
         bar_index,
         tp3,
         "✓ TP3",
         style=label.style_label_up,
         color=bullColor,
         textcolor=color.black,
         size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MULTI-ASSET TREND FUNCTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_marketState() =>
    e = ta.ema(close, emaLength)
    r = ta.rsi(close, rsiLength)
    a = ta.atr(atrLength)

    upper = ta.highest(high, amplitude)
    lower = ta.lowest(low, amplitude)

    fast = ta.ema(close, math.max(2, amplitude))
    mid = ta.ema(close, math.max(3, amplitude * 2))

    bull = close > e and fast > mid and r > 50
    bear = close < e and fast < mid and r < 50

    bull ? 1 : bear ? -1 : 0

state1 = request.security(sym1, timeframe.period, f_marketState())
state2 = request.security(sym2, timeframe.period, f_marketState())
state3 = request.security(sym3, timeframe.period, f_marketState())
state4 = request.security(sym4, timeframe.period, f_marketState())
state5 = request.security(sym5, timeframe.period, f_marketState())

f_stateText(s) =>
    s == 1 ? "LONG" :
     s == -1 ? "SHORT" :
     "NEUTRAL"

f_stateColor(s) =>
    s == 1 ? bullColor :
     s == -1 ? bearColor :
     color.gray

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PERFORMANCE DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table performance = table.new(
     position.bottom_right,
     2,
     8,
     border_width=1)

if barstate.islast and showDashboard

    table.cell(
         performance,
         0,
         0,
         "PERFORMANCE",
         bgcolor=color.new(color.gray, 55),
         text_color=color.white)

    table.cell(
         performance,
         1,
         0,
         "DATA",
         bgcolor=color.new(color.gray, 55),
         text_color=color.white)

    table.cell(
         performance,
         0,
         1,
         "Signal Score")

    table.cell(
         performance,
         1,
         1,
         str.tostring(longScore > shortScore ? longScore : shortScore) + "/4")

    table.cell(
         performance,
         0,
         2,
         "Win Rate")

    table.cell(
         performance,
         1,
         2,
         str.tostring(winRate, "#.0") + "%",
         text_color=winRate >= 50 ? bullColor : bearColor)

    table.cell(
         performance,
         0,
         3,
         "Wins")

    table.cell(
         performance,
         1,
         3,
         str.tostring(wins),
         text_color=bullColor)

    table.cell(
         performance,
         0,
         4,
         "Losses")

    table.cell(
         performance,
         1,
         4,
         str.tostring(losses),
         text_color=bearColor)

    table.cell(
         performance,
         0,
         5,
         "Break Even")

    table.cell(
         performance,
         1,
         5,
         str.tostring(breakeven))

    currentText =
         tradeState == 1 ? "LONG" :
         tradeState == -1 ? "SHORT" :
         "WAIT"

    currentColor =
         tradeState == 1 ? bullColor :
         tradeState == -1 ? bearColor :
         color.gray

    table.cell(
         performance,
         0,
         6,
         "Current Trade")

    table.cell(
         performance,
         1,
         6,
         currentText,
         text_color=currentColor)

    table.cell(
         performance,
         0,
         7,
         "Closed Trades")

    table.cell(
         performance,
         1,
         7,
         str.tostring(closedTrades))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MULTI-ASSET SCANNER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table scanner = table.new(
     position.top_right,
     2,
     6,
     border_width=1)

if barstate.islast and showScanner

    table.cell(
         scanner,
         0,
         0,
         "MARKET",
         bgcolor=color.new(color.gray, 55),
         text_color=color.white)

    table.cell(
         scanner,
         1,
         0,
         "BIAS",
         bgcolor=color.new(color.gray, 55),
         text_color=color.white)

    table.cell(
         scanner,
         0,
         1,
         sym1,
         text_color=color.white)

    table.cell(
         scanner,
         1,
         1,
         f_stateText(state1),
         text_color=f_stateColor(state1))

    table.cell(
         scanner,
         0,
         2,
         sym2,
         text_color=color.white)

    table.cell(
         scanner,
         1,
         2,
         f_stateText(state2),
         text_color=f_stateColor(state2))

    table.cell(
         scanner,
         0,
         3,
         sym3,
         text_color=color.white)

    table.cell(
         scanner,
         1,
         3,
         f_stateText(state3),
         text_color=f_stateColor(state3))

    table.cell(
         scanner,
         0,
         4,
         sym4,
         text_color=color.white)

    table.cell(
         scanner,
         1,
         4,
         f_stateText(state4),
         text_color=f_stateColor(state4))

    table.cell(
         scanner,
         0,
         5,
         sym5,
         text_color=color.white)

    table.cell(
         scanner,
         1,
         5,
         f_stateText(state5),
         text_color=f_stateColor(state5))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     longSignal,
     title="ATP PRO LONG",
     message="Adaptive Trend Pulse Pro: LONG confirmed")

alertcondition(
     shortSignal,
     title="ATP PRO SHORT",
     message="Adaptive Trend Pulse Pro: SHORT confirmed")

alertcondition(
     longTP1,
     title="ATP LONG TP1",
     message="Adaptive Trend Pulse Pro: LONG TP1 reached")

alertcondition(
     longTP2,
     title="ATP LONG TP2",
     message="Adaptive Trend Pulse Pro: LONG TP2 reached")

alertcondition(
     longTP3,
     title="ATP LONG TP3",
     message="Adaptive Trend Pulse Pro: LONG TP3 reached")

alertcondition(
     shortTP1,
     title="ATP SHORT TP1",
     message="Adaptive Trend Pulse Pro: SHORT TP1 reached")

alertcondition(
     shortTP2,
     title="ATP SHORT TP2",
     message="Adaptive Trend Pulse Pro: SHORT TP2 reached")

alertcondition(
     shortTP3,
     title="ATP SHORT TP3",
     message="Adaptive Trend Pulse Pro: SHORT TP3 reached")

alertcondition(
     longStopHit or shortStopHit,
     title="ATP STOP",
     message="Adaptive Trend Pulse Pro: Stop level reached")
````
