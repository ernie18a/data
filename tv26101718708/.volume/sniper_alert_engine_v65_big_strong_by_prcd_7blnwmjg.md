# Sniper Alert Engine v6.5 BIG + STRONG by @prcd

- url: https://www.tradingview.com/script/7BlnWMJg-Sniper-Alert-Engine-v6-5-BIG-STRONG-by-prcd/
- type: indicator
- pine_id: PUB;b1c49c729b994be49829ea4d776b5ce4
- version: 3.0

## Description

Sniper Alert Engine v6.5 Big + Strong Market Bias by prcd
Overview

Sniper Alert Engine v6.5 Big + Strong Market Bias by prcd is a multi-layer momentum and market-bias indicator designed to help traders identify when the market is showing strong directional conditions and when those conditions develop into higher-quality expansion opportunities.

The indicator separates market context from trade alerts:

Strong Bull / Strong Bear = directional market bias and context.
Big Bull / Big Bear = premium momentum expansion signals.
Alerts are triggered only on Fresh Big Bull and Fresh Big Bear conditions.

Version 6.5 adds an optional RSI/MFI Hybrid Momentum Filter that combines price momentum and volume-supported money flow to improve signal quality.

Purpose

The purpose of this indicator is to help traders avoid treating every momentum move as equal.

Instead of simply plotting buy/sell signals, the script first identifies whether the market has a strong directional bias. It then waits for additional confirmation from:

Momentum
Trend strength
Volatility expansion
Relative volume
RSI/MFI hybrid momentum
Higher-timeframe alignment
Breakout quality
Room-to-run conditions
Extension control

The indicator is intended as a decision-support tool, not a standalone trading system.

Key Features
1. Strong Bull / Strong Bear Market Bias

The Strong layer identifies when market conditions are directionally aligned.

A Strong Bull condition looks for bullish alignment across:

Price above VWAP
Price above EMA
Rising EMA slope
Bullish MACD structure
RSI strength
ADX trend strength
Positive directional movement
Session filter confirmation
RSI/MFI hybrid momentum confirmation

A Strong Bear condition looks for the opposite bearish alignment.

These signals are shown on the chart and dashboard even when no Big signal is present.

2. Big Bull / Big Bear Premium Momentum Signals

The Big layer is more selective.

A Big Bull or Big Bear signal requires strong market bias plus additional confirmation from:

Higher-timeframe alignment
Compression-to-expansion behaviour
ATR expansion
MACD acceleration
Breakout through recent swing levels
Breakout quality relative to ATR
Relative volume confirmation
RSI/MFI hybrid momentum confirmation
Room to run
Not-too-extended filter

This makes Big signals less frequent but more selective than Strong conditions.

3. RSI/MFI Hybrid Momentum Filter

Version 6.5 introduces an optional hybrid momentum layer inspired by the idea of combining price momentum and money-flow momentum.

The hybrid momentum value averages:

RSI: price momentum
MFI: volume-supported money flow

This helps the indicator assess whether a move has both price strength and participation behind it.

The hybrid filter is used in two ways:

Strong layer: softer confirmation for market bias.
Big layer: stricter confirmation for premium expansion signals.

This filter can be switched on or off from the settings.

Momentum Signals Explained
Strong Bull

A Strong Bull state means bullish momentum and trend conditions are aligned.

This does not automatically mean “enter now”. It means the market context is bullish and traders may choose to focus only on long setups.

Example interpretation:

Strong Bull appears on the dashboard. The trader may now look for long continuation setups, pullbacks, or fresh Big Bull signals.

Strong Bear

A Strong Bear state means bearish momentum and trend conditions are aligned.

This does not automatically mean “enter now”. It means the market context is bearish and traders may choose to focus only on short setups.

Example interpretation:

Strong Bear appears on the dashboard. The trader may now look for short continuation setups, pullbacks, or fresh Big Bear signals.

Big Bull

A Big Bull signal is a premium bullish expansion condition.

It means the script has detected bullish bias plus stronger confirmation from volatility, trend, volume, breakout quality, higher-timeframe context, and RSI/MFI hybrid momentum.

Example interpretation:

The market is already in a Strong Bull context. Price breaks above a recent swing high with expansion, relative volume, hybrid momentum confirmation, and higher-timeframe confirmation. A Fresh Big Bull alert is triggered.

Big Bear

A Big Bear signal is a premium bearish expansion condition.

It means the script has detected a bearish bias, with stronger confirmation from volatility, trend, volume, breakout quality, higher-timeframe context, and an RSI/MFI hybrid momentum.

Example interpretation:

The market is already in a Strong Bear context. Price breaks below a recent swing low with expansion, relative volume, hybrid momentum confirmation, and higher-timeframe confirmation. A Fresh Big Bear alert is triggered.

Dashboard

The dashboard displays:

Current profile
Asset mode
Strong Bull status
Strong Bear status
Big Bull status
Big Bear status
Big Bull probability score
Big Bear probability score
RSI
MFI
Hybrid momentum
ADX
Relative volume
Higher-timeframe direction
EMA slope
Latest Bull SL / TP reference levels
Latest Bear SL / TP reference levels
Current state

The dashboard helps separate directional context from alertable momentum signals.

Profiles

The indicator includes three tuning profiles:

M1

Faster and stricter tuning for 1-minute trading.

M5

Slower and more patient tuning for 5-minute trading.

Custom

Allows the user to manually control the main input parameters.

Asset Modes
DAX40 (aka GER40)

Designed to be stricter and more fakeout-aware.

Adjustments include:

Higher ADX threshold
Higher relative volume requirement
More breakout quality required
Slightly more room-to-run required
Slightly stricter hybrid momentum requirements
NASDAQ100

Designed for smoother momentum behaviour.

Adjustments include:

Slightly looser ADX threshold
Slightly lower relative volume requirement
Slightly looser breakout conditions
Slightly more flexible hybrid momentum requirements
Generic

Neutral default mode for broader use.

How to Use

A simple workflow:

Choose the correct profile: M1, M5, or Custom.
Choose the correct asset mode: DAX40, NASDAQ100, or Generic.
Use Strong Bull / Strong Bear as directional context.
Use Big Bull / Big Bear as premium expansion signals.
Use the dashboard to confirm RSI, MFI, hybrid momentum, ADX, relative volume, HTF direction, and current state.
Use plotted SL / TP levels as reference levels, not guaranteed outcomes.
Alert Setup Examples
Option 1: Static TradingView Alert Conditions

To create a standard alert:

Add the indicator to your chart.
Click Alerts.
Select this indicator as the condition.
Choose either:
Fresh Big Bull
Fresh Big Bear
Set frequency to:
Once Per Bar Close

These alerts use the built-in alertcondition() messages.

Option 2: Dynamic Alert Messages

For richer alerts containing asset mode, profile, probability, close, SL, TP1, TP2, relative volume, and hybrid momentum:

Add the indicator to your chart.
Click Alerts.
Under condition, select this script.
Choose:
Any alert() function call
Set frequency to:
Once Per Bar Close

Dynamic Big Bull and Big Bear alert messages include:

Asset mode
Profile
Probability score
Close price
Stop loss reference
Target 1 reference
Target 2 reference
Relative volume
Hybrid momentum value
Important Notes

This indicator does not predict the future and does not guarantee profitable trades.

Signals should be used with:

Risk management
Market structure analysis
Session awareness
Spread and slippage awareness
Personal trading rules
Backtesting and forward testing

The plotted SL and TP levels are reference levels only.

The indicator is intended for educational and analytical use. It should not be considered financial advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// author © prcd March 2026
//@version=6
indicator("Sniper Alert Engine v6.6 BIG + STRONG by @prcd", overlay=true, max_labels_count=500)

// ============================================================================
// PURPOSE
// ============================================================================
// This script has two layers:
//
// 1) STRONG BULL / STRONG BEAR = directional context / market bias.
//    These are directional context states.
//    They should appear on the dashboard/grid even when there is no premium signal.
//
// 2) BIG BULL / BIG BEAR = premium expansion signals for alerts.
//    These are premium expansion signals.
//    They are more selective and intended for alerting.
//
// Alerts are only triggered on:
// - FRESH BIG BULL
// - FRESH BIG BEAR
//
// This version avoids multiline assignments to reduce TradingView parser issues.
//
// NEW IN v6.4:
// - Asset Mode switch:
//     * DAX40
//     * NASDAQ100
//     * Generic
//
// NEW IN v6.5:
// - Adds optional RSI/MFI Hybrid Momentum Filter.
// - STRONG layer uses softer hybrid momentum confirmation.
// - BIG layer uses stricter hybrid momentum confirmation.
// - Dashboard includes Hybrid Momentum.
// - Alert messages include Hybrid Momentum.
//
// NEW IN v6.6:
// - Adds explicit session timezone handling.
// - London and New York sessions can now be evaluated in UTC.
// - Session logic is independent of the user chart timezone.
// - Dashboard includes the active session timezone.
//
// Asset Mode adjusts thresholds to better match the personality of the market.
// ============================================================================



// ============================================================================
// PROFILE SELECTION
// ============================================================================
// Profile controls timeframe-style tuning:
//
// M1     = faster / stricter
// M5     = slower / more patient
// Custom = manual control
// ============================================================================
profile = input.string("M1", "Tuning Profile", options=["M1", "M5", "Custom"])



// ============================================================================
// ASSET MODE SELECTION
// ============================================================================
// Asset Mode controls market-personality tuning:
//
// DAX40      = stricter, more fakeout-aware
// NASDAQ100  = smoother trend-following, slightly looser
// Generic    = neutral/default
//
// This sits on top of the timeframe profile.
// ============================================================================
assetMode = input.string("Generic", "Asset Mode", options=["DAX40", "NASDAQ100", "Generic"])



// ============================================================================
// CUSTOM INPUTS
// ============================================================================
// These are used when profile = Custom.
// For M1/M5, profile-specific values override these.
// ============================================================================
emaLenInput = input.int(21, "EMA Length")
rsiLenInput = input.int(14, "RSI Length")
adxLenInput = input.int(14, "ADX Length")
adxSmoothingInput = input.int(14, "ADX Smoothing")
macdFastInput = input.int(12, "MACD Fast")
macdSlowInput = input.int(26, "MACD Slow")
macdSignalInput = input.int(9, "MACD Signal")
atrLenInput = input.int(14, "ATR Length")
pullbackBarsInput = input.int(5, "Breakout Lookback Bars")
bbLenInput = input.int(20, "BB Length")
bbMultInput = input.float(2.0, "BB Multiplier")
roomLookbackInput = input.int(20, "Room-to-Run Lookback")
htfTfInput = input.timeframe("5", "Higher Timeframe")
cooldownBarsInput = input.int(8, "Cooldown Bars")
minRelVolInput = input.float(1.20, "Min Relative Volume", step=0.05)

slAtrMultInput = input.float(1.2, "Stop Loss ATR Multiplier", step=0.1)
tp1AtrMultInput = input.float(1.5, "Target 1 ATR Multiplier", step=0.1)
tp2AtrMultInput = input.float(2.5, "Target 2 ATR Multiplier", step=0.1)


// ============================================================================
// HYBRID MOMENTUM FILTER
// ============================================================================
useHybridMomentum = input.bool(true, "Use RSI/MFI Hybrid Momentum Filter")
hybridBullStrongInput = input.float(55.0, "Hybrid Bull STRONG Level", step=0.5)
hybridBearStrongInput = input.float(45.0, "Hybrid Bear STRONG Level", step=0.5)
hybridBullBigInput = input.float(66.0, "Hybrid Bull BIG Level", step=0.5)
hybridBearBigInput = input.float(30.0, "Hybrid Bear BIG Level", step=0.5)



// ============================================================================
// SESSION FILTERS
// ============================================================================
sessionMode = input.string("London + NY", "Session Filter", options=["All", "London", "New York", "London + NY"])
sessionTimezone = input.string("Etc/UTC", "Session Timezone", options=["Etc/UTC", "Europe/London", "America/New_York", "Exchange"])
londonSession = input.session("0800-1630", "London Session")
nySession = input.session("1430-2100", "New York Session")



// ============================================================================
// VOLUME FILTERS
// ============================================================================
useVolumeFilter = input.bool(true, "Use Relative Volume Filter")
volLen = input.int(20, "Relative Volume Length")



// ============================================================================
// DISPLAY OPTIONS
// ============================================================================
showTable = input.bool(true, "Show Dashboard")
showLabels = input.bool(true, "Show Labels")
showBg = input.bool(true, "Show Background")
showLevels = input.bool(true, "Show SL / TP Levels")



// ============================================================================
// PROFILE PARAMETERS
// ============================================================================
// These values adapt the engine for M1 or M5.
// M1 = faster / stricter
// M5 = slower / wider / more patient
// ============================================================================
emaLenBase = profile == "M1" ? 21 : profile == "M5" ? 21 : emaLenInput
rsiLenBase = profile == "M1" ? 14 : profile == "M5" ? 14 : rsiLenInput
adxLenBase = profile == "M1" ? 14 : profile == "M5" ? 14 : adxLenInput
adxSmoothingBase = profile == "M1" ? 14 : profile == "M5" ? 14 : adxSmoothingInput
macdFastBase = profile == "M1" ? 12 : profile == "M5" ? 12 : macdFastInput
macdSlowBase = profile == "M1" ? 26 : profile == "M5" ? 26 : macdSlowInput
macdSignalBase = profile == "M1" ? 9 : profile == "M5" ? 9 : macdSignalInput
atrLenBase = profile == "M1" ? 14 : profile == "M5" ? 14 : atrLenInput
pullbackBarsBase = profile == "M1" ? 5 : profile == "M5" ? 7 : pullbackBarsInput
bbLenBase = profile == "M1" ? 20 : profile == "M5" ? 20 : bbLenInput
bbMultBase = profile == "M1" ? 2.0 : profile == "M5" ? 2.0 : bbMultInput
roomLookbackBase = profile == "M1" ? 20 : profile == "M5" ? 30 : roomLookbackInput
htfTfBase = profile == "M1" ? "5" : profile == "M5" ? "15" : htfTfInput
cooldownBarsBase = profile == "M1" ? 8 : profile == "M5" ? 4 : cooldownBarsInput
minRelVolBase = profile == "M1" ? 1.25 : profile == "M5" ? 1.10 : minRelVolInput

bullRsiMinBase = profile == "M1" ? 58 : profile == "M5" ? 55 : 55
bullRsiMaxBase = profile == "M1" ? 72 : profile == "M5" ? 75 : 72
bearRsiMaxBase = profile == "M1" ? 42 : profile == "M5" ? 45 : 45
bearRsiMinBase = profile == "M1" ? 28 : profile == "M5" ? 25 : 28

bullRsiExhaustBase = profile == "M1" ? 76 : profile == "M5" ? 80 : 78
bearRsiExhaustBase = profile == "M1" ? 24 : profile == "M5" ? 20 : 22

adxThresholdBase = profile == "M1" ? 27 : profile == "M5" ? 23 : 25
bodyMultBase = profile == "M1" ? 1.25 : profile == "M5" ? 1.15 : 1.20
rangeMultBase = profile == "M1" ? 1.15 : profile == "M5" ? 1.05 : 1.10
roomThresholdBase = profile == "M1" ? 1.0 : profile == "M5" ? 1.5 : 1.0
vwapDistThresholdBase = profile == "M1" ? 0.25 : profile == "M5" ? 0.20 : 0.25

slAtrMultBase = profile == "M1" ? 1.1 : profile == "M5" ? 1.4 : slAtrMultInput
tp1AtrMultBase = profile == "M1" ? 1.5 : profile == "M5" ? 2.0 : tp1AtrMultInput
tp2AtrMultBase = profile == "M1" ? 2.5 : profile == "M5" ? 3.5 : tp2AtrMultInput



// ============================================================================
// ASSET MODE ADJUSTMENTS
// ============================================================================
// These fine-tune the base profile values according to the selected instrument.
//
// DAX40:
// - stricter ADX
// - stricter breakout quality
// - higher relative volume requirement
// - slightly wider VWAP distance requirement
// - slightly more room required
//
// NASDAQ100:
// - smoother trend market
// - slightly looser ADX and breakout conditions
// - lower volume threshold
//
// Generic:
// - no extra shift from the profile values
// ============================================================================

// Multipliers / offsets
adxThresholdAdjust = assetMode == "DAX40" ? 2.0 : assetMode == "NASDAQ100" ? -1.0 : 0.0
minRelVolAdjust = assetMode == "DAX40" ? 0.10 : assetMode == "NASDAQ100" ? -0.05 : 0.0
roomThresholdAdjust = assetMode == "DAX40" ? 0.20 : assetMode == "NASDAQ100" ? 0.00 : 0.0
vwapDistAdjust = assetMode == "DAX40" ? 0.05 : assetMode == "NASDAQ100" ? -0.03 : 0.0
bodyMultAdjust = assetMode == "DAX40" ? 0.05 : assetMode == "NASDAQ100" ? -0.03 : 0.0
rangeMultAdjust = assetMode == "DAX40" ? 0.05 : assetMode == "NASDAQ100" ? -0.03 : 0.0
breakQualityThreshold = assetMode == "DAX40" ? 0.15 : assetMode == "NASDAQ100" ? 0.08 : 0.10

hybridBullStrongAdjust = assetMode == "DAX40" ? 1.0 : assetMode == "NASDAQ100" ? -1.0 : 0.0
hybridBearStrongAdjust = assetMode == "DAX40" ? -1.0 : assetMode == "NASDAQ100" ? 1.0 : 0.0
hybridBullBigAdjust = assetMode == "DAX40" ? 1.0 : assetMode == "NASDAQ100" ? -1.0 : 0.0
hybridBearBigAdjust = assetMode == "DAX40" ? -1.0 : assetMode == "NASDAQ100" ? 1.0 : 0.0

// ============================================================================
// FINAL PARAMETERS
// ============================================================================
emaLen = emaLenBase
rsiLen = rsiLenBase
adxLen = adxLenBase
adxSmoothing = adxSmoothingBase
macdFast = macdFastBase
macdSlow = macdSlowBase
macdSignal = macdSignalBase
atrLen = atrLenBase
pullbackBars = pullbackBarsBase
bbLen = bbLenBase
bbMult = bbMultBase
roomLookback = roomLookbackBase
htfTf = htfTfBase
cooldownBars = cooldownBarsBase

minRelVol = minRelVolBase + minRelVolAdjust
bullRsiMin = bullRsiMinBase
bullRsiMax = bullRsiMaxBase
bearRsiMax = bearRsiMaxBase
bearRsiMin = bearRsiMinBase

bullRsiExhaust = bullRsiExhaustBase
bearRsiExhaust = bearRsiExhaustBase

adxThreshold = adxThresholdBase + adxThresholdAdjust
bodyMult = bodyMultBase + bodyMultAdjust
rangeMult = rangeMultBase + rangeMultAdjust
roomThreshold = roomThresholdBase + roomThresholdAdjust
vwapDistThreshold = vwapDistThresholdBase + vwapDistAdjust

hybridBullStrongLevel = hybridBullStrongInput + hybridBullStrongAdjust
hybridBearStrongLevel = hybridBearStrongInput + hybridBearStrongAdjust
hybridBullBigLevel = hybridBullBigInput + hybridBullBigAdjust
hybridBearBigLevel = hybridBearBigInput + hybridBearBigAdjust

slAtrMult = slAtrMultBase
tp1AtrMult = tp1AtrMultBase
tp2AtrMult = tp2AtrMultBase



// ============================================================================
// SESSION LOGIC
// ============================================================================
activeSessionTimezone = sessionTimezone == "Exchange" ? syminfo.timezone : sessionTimezone
inLondon = not na(time(timeframe.period, londonSession, activeSessionTimezone))
inNY = not na(time(timeframe.period, nySession, activeSessionTimezone))
sessionAllowed = sessionMode == "All" ? true : sessionMode == "London" ? inLondon : sessionMode == "New York" ? inNY : inLondon or inNY



// ============================================================================
// CORE INDICATORS
// ============================================================================
ema21 = ta.ema(close, emaLen)
rsi = ta.rsi(close, rsiLen)
mfi = ta.mfi(hlc3, rsiLen)
hybridMomentum = math.avg(rsi, mfi)

[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSignal)
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxSmoothing)
atr = ta.atr(atrLen)
vwapVal = ta.vwap(close)

// ============================================================================
// HYBRID MOMENTUM CONDITIONS
// ============================================================================
hybridStrongBull = not useHybridMomentum or hybridMomentum > hybridBullStrongLevel and hybridMomentum > hybridMomentum[1]
hybridStrongBear = not useHybridMomentum or hybridMomentum < hybridBearStrongLevel and hybridMomentum < hybridMomentum[1]
hybridBigBull = not useHybridMomentum or hybridMomentum > hybridBullBigLevel and hybridMomentum > hybridMomentum[1]
hybridBigBear = not useHybridMomentum or hybridMomentum < hybridBearBigLevel and hybridMomentum < hybridMomentum[1]

hybridBullCross = hybridMomentum[1] < hybridBullBigLevel and hybridMomentum > hybridBullBigLevel
hybridBearCross = hybridMomentum[1] > hybridBearBigLevel and hybridMomentum < hybridBearBigLevel

// ============================================================================
// HIGHER TIMEFRAME CONTEXT
// ============================================================================
htfClose = request.security(syminfo.tickerid, htfTf, close)
htfEma21 = request.security(syminfo.tickerid, htfTf, ta.ema(close, emaLen))
htfRsi = request.security(syminfo.tickerid, htfTf, ta.rsi(close, rsiLen))
[htfMacdLine, htfSignalLine, _] = request.security(syminfo.tickerid, htfTf, ta.macd(close, macdFast, macdSlow, macdSignal))

htfBull = htfClose > htfEma21 and htfMacdLine > htfSignalLine and htfRsi > 50
htfBear = htfClose < htfEma21 and htfMacdLine < htfSignalLine and htfRsi < 50



// ============================================================================
// RELATIVE VOLUME
// ============================================================================
volMA = ta.sma(volume, volLen)
relVol = volMA > 0 ? volume / volMA : 1.0
volOkay = not useVolumeFilter or relVol >= minRelVol



// ============================================================================
// VOLATILITY / COMPRESSION / EXPANSION
// ============================================================================
bbBasis = ta.sma(close, bbLen)
bbDev = ta.stdev(close, bbLen)
bbUpper = bbBasis + bbMult * bbDev
bbLower = bbBasis - bbMult * bbDev
bbWidth = bbBasis != 0 ? (bbUpper - bbLower) / bbBasis : 0.0
bbWidthMA = ta.sma(bbWidth, bbLen)

compressed = bbWidth < bbWidthMA * 0.8
expandingNow = bbWidth > bbWidth[1]
atrRising = atr > atr[1]
atrAboveAvg = atr > ta.sma(atr, atrLen)



// ============================================================================
// TREND / MOMENTUM / SLOPE
// ============================================================================
aboveVWAP = close > vwapVal
belowVWAP = close < vwapVal
aboveEMA = close > ema21
belowEMA = close < ema21

emaSlopeUp = ema21 > ema21[1] and ema21[1] > ema21[2]
emaSlopeDown = ema21 < ema21[1] and ema21[1] < ema21[2]

macdBull = macdLine > signalLine
macdBear = macdLine < signalLine
macdAboveZero = macdLine > 0
macdBelowZero = macdLine < 0
macdAccelBull = histLine > histLine[1]
macdAccelBear = histLine < histLine[1]

rsiBull = rsi > bullRsiMin and rsi < bullRsiMax and rsi > rsi[1]
rsiBear = rsi < bearRsiMax and rsi > bearRsiMin and rsi < rsi[1]

notExhaustedBull = rsi < bullRsiExhaust
notExhaustedBear = rsi > bearRsiExhaust

diSpreadBull = diPlus - diMinus
diSpreadBear = diMinus - diPlus

trendStrongBull = adx > adxThreshold and adx > adx[1] and diPlus > diMinus and diSpreadBull > 5
trendStrongBear = adx > adxThreshold and adx > adx[1] and diMinus > diPlus and diSpreadBear > 5



// ============================================================================
// STRUCTURE / BREAKOUT QUALITY
// ============================================================================
recentSwingHigh = ta.highest(high[1], pullbackBars)
recentSwingLow = ta.lowest(low[1], pullbackBars)

breakSwingHigh = close > recentSwingHigh
breakSwingLow = close < recentSwingLow

breakQualityBull = atr > 0 ? (close - recentSwingHigh) / atr : 0.0
breakQualityBear = atr > 0 ? (recentSwingLow - close) / atr : 0.0



// ============================================================================
// STRONG BULL / STRONG BEAR
// ============================================================================
// These are the context states that should always be shown on the grid.
// ============================================================================
strongBullBar = aboveVWAP and aboveEMA and emaSlopeUp and macdBull and macdAboveZero and rsiBull and trendStrongBull and notExhaustedBull and sessionAllowed and hybridStrongBull
strongBearBar = belowVWAP and belowEMA and emaSlopeDown and macdBear and macdBelowZero and rsiBear and trendStrongBear and notExhaustedBear and sessionAllowed and hybridStrongBear

prevStrongBull = bar_index > 0 ? strongBullBar[1] : false
prevStrongBear = bar_index > 0 ? strongBearBar[1] : false

strongBull = strongBullBar and prevStrongBull
strongBear = strongBearBar and prevStrongBear



// ============================================================================
// BIG BULL / BIG BEAR PREMIUM FILTERS
// ============================================================================
prevCompressed = bar_index > 0 ? compressed[1] : false

expansionBull = prevCompressed and expandingNow and atrRising and atrAboveAvg and macdAccelBull
expansionBear = prevCompressed and expandingNow and atrRising and atrAboveAvg and macdAccelBear

vwapDistBull = atr > 0 ? (close - vwapVal) / atr : 0.0
vwapDistBear = atr > 0 ? (vwapVal - close) / atr : 0.0

emaDistBull = atr > 0 ? (close - ema21) / atr : 0.0
emaDistBear = atr > 0 ? (ema21 - close) / atr : 0.0

notTooExtendedBull = emaDistBull < 1.8 and vwapDistBull < 2.0
notTooExtendedBear = emaDistBear < 1.8 and vwapDistBear < 2.0

recentHigh = ta.highest(high, roomLookback)
recentLow = ta.lowest(low, roomLookback)

roomUp = atr > 0 ? (recentHigh - close) / atr : 0.0
roomDown = atr > 0 ? (close - recentLow) / atr : 0.0

bigBullRaw = strongBull and htfBull and macdAccelBull and expansionBull and vwapDistBull > vwapDistThreshold and roomUp > roomThreshold and breakSwingHigh and breakQualityBull > breakQualityThreshold and volOkay and notTooExtendedBull and hybridBigBull
bigBearRaw = strongBear and htfBear and macdAccelBear and expansionBear and vwapDistBear > vwapDistThreshold and roomDown > roomThreshold and breakSwingLow and breakQualityBear > breakQualityThreshold and volOkay and notTooExtendedBear and hybridBigBear



// ============================================================================
// COOLDOWN + FRESH SIGNALS
// ============================================================================
barsSinceBigBull = ta.barssince(bigBullRaw)
barsSinceBigBear = ta.barssince(bigBearRaw)

bigBullCooldownOK = na(barsSinceBigBull[1]) or barsSinceBigBull[1] > cooldownBars
bigBearCooldownOK = na(barsSinceBigBear[1]) or barsSinceBigBear[1] > cooldownBars

bigBull = bigBullRaw and bigBullCooldownOK
bigBear = bigBearRaw and bigBearCooldownOK

prevBigBull = bar_index > 0 ? bigBull[1] : false
prevBigBear = bar_index > 0 ? bigBear[1] : false

freshBigBull = bigBull and not prevBigBull
freshBigBear = bigBear and not prevBigBear



// ============================================================================
// PROBABILITY SCORES
// ============================================================================
bigBullProb = 0.0
bigBearProb = 0.0

if strongBull
    bigBullProb += 16
if strongBear
    bigBearProb += 16

if htfBull
    bigBullProb += 14
if htfBear
    bigBearProb += 14

if emaSlopeUp
    bigBullProb += 8
if emaSlopeDown
    bigBearProb += 8

if macdAccelBull
    bigBullProb += 9
if macdAccelBear
    bigBearProb += 9

if expansionBull
    bigBullProb += 14
if expansionBear
    bigBearProb += 14

if atrRising and atrAboveAvg
    bigBullProb += strongBull ? 7 : 0
    bigBearProb += strongBear ? 7 : 0

if vwapDistBull > vwapDistThreshold
    bigBullProb += 7
if vwapDistBear > vwapDistThreshold
    bigBearProb += 7

if roomUp > roomThreshold
    bigBullProb += 7
if roomDown > roomThreshold
    bigBearProb += 7

if volOkay
    bigBullProb += strongBull ? 8 : 0
    bigBearProb += strongBear ? 8 : 0

if notTooExtendedBull
    bigBullProb += 7
if notTooExtendedBear
    bigBearProb += 7

if hybridBigBull
    bigBullProb += 10
if hybridBigBear
    bigBearProb += 10

bigBullProb := math.min(bigBullProb, 100)
bigBearProb := math.min(bigBearProb, 100)



// ============================================================================
// SL / TP MEMORY
// ============================================================================
var float bullStop = na
var float bullTP1 = na
var float bullTP2 = na
var float bearStop = na
var float bearTP1 = na
var float bearTP2 = na

if freshBigBull
    bullStop := close - atr * slAtrMult
    bullTP1 := close + atr * tp1AtrMult
    bullTP2 := close + atr * tp2AtrMult

if freshBigBear
    bearStop := close + atr * slAtrMult
    bearTP1 := close - atr * tp1AtrMult
    bearTP2 := close - atr * tp2AtrMult

plot(showLevels ? bullTP1 : na, "Bull TP1", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)
plot(showLevels ? bullTP2 : na, "Bull TP2", color=color.new(color.teal, 0), linewidth=2, style=plot.style_linebr)
plot(showLevels ? bullStop : na, "Bull SL", color=color.new(color.red, 30), linewidth=2, style=plot.style_linebr)

plot(showLevels ? bearTP1 : na, "Bear TP1", color=color.new(color.red, 0), linewidth=2, style=plot.style_linebr)
plot(showLevels ? bearTP2 : na, "Bear TP2", color=color.new(color.maroon, 0), linewidth=2, style=plot.style_linebr)
plot(showLevels ? bearStop : na, "Bear SL", color=color.new(color.green, 30), linewidth=2, style=plot.style_linebr)



// ============================================================================
// STATE SUMMARY
// ============================================================================
stateText = "WAIT"
if strongBull
    stateText := "STG BULL"
if strongBear
    stateText := "STG BEAR"
if bigBull
    stateText := "BIG BULL"
if bigBear
    stateText := "BIG BEAR"



// ============================================================================
// VISUALS
// ============================================================================
plot(ema21, "EMA 21", color=color.yellow, linewidth=2)
plot(vwapVal, "VWAP", color=color.blue, linewidth=2)

bgCol = color.new(color.gray, 95)
if strongBull
    bgCol := color.new(color.green, 92)
if strongBear
    bgCol := color.new(color.red, 92)
if bigBull
    bgCol := color.new(color.teal, 75)
if bigBear
    bgCol := color.new(color.maroon, 75)

bgcolor(showBg ? bgCol : na)

plotshape(showLabels and strongBull, title="Strong Bull", style=shape.labelup, location=location.belowbar, color=color.green, text="STG\nBULL", textcolor=color.black, size=size.small)
plotshape(showLabels and strongBear, title="Strong Bear", style=shape.labeldown, location=location.abovebar, color=color.red, text="STG\nBEAR", textcolor=color.black, size=size.small)
plotshape(showLabels and freshBigBull, title="Fresh Big Bull", style=shape.labelup, location=location.belowbar, color=color.teal, text="BIG\nBULL", textcolor=color.white, size=size.small)
plotshape(showLabels and freshBigBear, title="Fresh Big Bear", style=shape.labeldown, location=location.abovebar, color=color.maroon, text="BIG\nBEAR", textcolor=color.white, size=size.small)



// ============================================================================
// DASHBOARD / GRID
// ============================================================================
var table t = table.new(position.top_right, 2, 21, border_width=1)

if showTable and barstate.islast
    table.cell(t, 0, 0, "Metric", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 0, "Value", bgcolor=color.black, text_color=color.white)

    table.cell(t, 0, 1, "Profile")
    table.cell(t, 1, 1, profile)

    table.cell(t, 0, 2, "Asset Mode")
    table.cell(t, 1, 2, assetMode)

    table.cell(t, 0, 3, "Strong Bull")
    table.cell(t, 1, 3, strongBull ? "YES" : "NO", text_color=strongBull ? color.green : color.gray)

    table.cell(t, 0, 4, "Strong Bear")
    table.cell(t, 1, 4, strongBear ? "YES" : "NO", text_color=strongBear ? color.red : color.gray)

    table.cell(t, 0, 5, "Big Bull")
    table.cell(t, 1, 5, bigBull ? "YES" : "NO", text_color=bigBull ? color.teal : color.gray)

    table.cell(t, 0, 6, "Big Bear")
    table.cell(t, 1, 6, bigBear ? "YES" : "NO", text_color=bigBear ? color.maroon : color.gray)

    table.cell(t, 0, 7, "Big Bull Prob")
    table.cell(t, 1, 7, str.tostring(bigBullProb, "#.0") + "%", text_color=color.teal)

    table.cell(t, 0, 8, "Big Bear Prob")
    table.cell(t, 1, 8, str.tostring(bigBearProb, "#.0") + "%", text_color=color.maroon)

    table.cell(t, 0, 9, "RSI")
    table.cell(t, 1, 9, str.tostring(rsi, "#.0"))

    table.cell(t, 0, 10, "MFI")
    table.cell(t, 1, 10, str.tostring(mfi, "#.0"))

    table.cell(t, 0, 11, "Hybrid Mom")
    table.cell(t, 1, 11, str.tostring(hybridMomentum, "#.0"), text_color=hybridMomentum > hybridBullStrongLevel ? color.green : hybridMomentum < hybridBearStrongLevel ? color.red : color.orange)

    table.cell(t, 0, 12, "ADX")
    table.cell(t, 1, 12, str.tostring(adx, "#.0"))

    table.cell(t, 0, 13, "Rel Vol")
    table.cell(t, 1, 13, str.tostring(relVol, "#.00"), text_color=relVol >= minRelVol ? color.green : color.orange)

    table.cell(t, 0, 14, "HTF")
    table.cell(t, 1, 14, htfBull ? "BULL" : htfBear ? "BEAR" : "NEUTRAL", text_color=htfBull ? color.green : htfBear ? color.red : color.orange)

    table.cell(t, 0, 15, "Session TZ")
    table.cell(t, 1, 15, activeSessionTimezone)

    table.cell(t, 0, 16, "Session Active")
    table.cell(t, 1, 16, sessionAllowed ? "YES" : "NO", text_color=sessionAllowed ? color.green : color.orange)

    table.cell(t, 0, 17, "EMA Slope")
    table.cell(t, 1, 17, emaSlopeUp ? "UP" : emaSlopeDown ? "DOWN" : "FLAT", text_color=emaSlopeUp ? color.green : emaSlopeDown ? color.red : color.orange)

    table.cell(t, 0, 18, "Bull SL / TP1 / TP2")
    table.cell(t, 1, 18, na(bullStop) ? "-" : str.tostring(bullStop, format.mintick) + " / " + str.tostring(bullTP1, format.mintick) + " / " + str.tostring(bullTP2, format.mintick), text_color=color.teal)

    table.cell(t, 0, 19, "Bear SL / TP1 / TP2")
    table.cell(t, 1, 19, na(bearStop) ? "-" : str.tostring(bearStop, format.mintick) + " / " + str.tostring(bearTP1, format.mintick) + " / " + str.tostring(bearTP2, format.mintick), text_color=color.maroon)

    table.cell(t, 0, 20, "State")
    table.cell(t, 1, 20, stateText, text_color=freshBigBull ? color.teal : freshBigBear ? color.maroon : strongBull ? color.green : strongBear ? color.red : color.orange)



// ============================================================================
// OPTIONAL STATIC BACKUP ALERTS
// ============================================================================
alertcondition(freshBigBull, title="Fresh Big Bull", message="Fresh Big Bull detected")
alertcondition(freshBigBear, title="Fresh Big Bear", message="Fresh Big Bear detected")



// ============================================================================
// DYNAMIC ALERT() MESSAGES
// ============================================================================
// In TradingView, create alert using:
// - Condition: This script
// - Type: Any alert() function call
// - Frequency: Once Per Bar Close
// ============================================================================
bullMsg = "BIG BULL | Asset=" + assetMode + " | Profile=" + profile + " | SessionTZ=" + activeSessionTimezone + " | Prob=" + str.tostring(bigBullProb, "#.0") + "%" + " | Close=" + str.tostring(close, format.mintick) + " | SL=" + str.tostring(bullStop, format.mintick) + " | TP1=" + str.tostring(bullTP1, format.mintick) + " | TP2=" + str.tostring(bullTP2, format.mintick) + " | RelVol=" + str.tostring(relVol, "#.00") + " | HybridMom=" + str.tostring(hybridMomentum, "#.0")
bearMsg = "BIG BEAR | Asset=" + assetMode + " | Profile=" + profile + " | SessionTZ=" + activeSessionTimezone + " | Prob=" + str.tostring(bigBearProb, "#.0") + "%" + " | Close=" + str.tostring(close, format.mintick) + " | SL=" + str.tostring(bearStop, format.mintick) + " | TP1=" + str.tostring(bearTP1, format.mintick) + " | TP2=" + str.tostring(bearTP2, format.mintick) + " | RelVol=" + str.tostring(relVol, "#.00") + " | HybridMom=" + str.tostring(hybridMomentum, "#.0")

if freshBigBull
    alert(bullMsg, alert.freq_once_per_bar_close)

if freshBigBear
    alert(bearMsg, alert.freq_once_per_bar_close)
````
