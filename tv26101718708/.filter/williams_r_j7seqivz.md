# Williams %R

- url: https://www.tradingview.com/script/J7seqiVZ-Williams-R/
- type: indicator
- pine_id: PUB;735b18d0adde410ea7d6064ee0c55739
- version: 1.0

## Description

williams %r god mode

williams %r god mode is a modern momentum oscillator designed for clean reversal detection, trend continuation timing, multi-timeframe reading, higher-timeframe confirmation, and filtered buy/sell signals.

the tool is built around williams %r, but it does not behave like a basic overbought/oversold oscillator. it adds smoothing, signal logic, mtf mode, score filtering, trend confirmation, htf confirmation, anti-spam protection, visual zones, glow effects, labels, and a compact dashboard.

main idea

williams %r is often used to detect when price is overbought or oversold.

the problem with a basic williams %r is that it can give too many early signals, especially during strong trends.

this indicator is designed to reduce that noise by combining:

williams %r flow
signal line confirmation
overbought and oversold exits
midline reclaim
trend filter
mtf mode
htf confirmation
impulse candle filter
precision score
signal cooldown
clean visual dashboard

how the oscillator works

the oscillator is displayed from 0 to 100.

low values show bearish pressure or oversold conditions.
high values show bullish pressure or overbought conditions.

important zones:

0 to 20 = oversold area
20 to 50 = lower momentum zone
50 = midline
50 to 80 = upper momentum zone
80 to 100 = overbought area

a bullish setup usually becomes stronger when the flow exits oversold, crosses above the signal line, and starts reclaiming higher zones.

a bearish setup usually becomes stronger when the flow exits overbought, crosses below the signal line, and starts losing higher zones.

mtf mode

the indicator includes a real multi-timeframe mode.

you can choose the timeframe used by the oscillator.

available display modes:

chart tf
true mtf
smooth mtf

chart tf

uses the current chart timeframe.

this is the fastest and most responsive mode.

true mtf

uses the selected higher timeframe directly.

this is the most exact mtf reading, but it can look stepped because higher-timeframe values update only when the higher-timeframe candle updates.

smooth mtf

uses the selected mtf source and applies fixed smoothing to make the line cleaner.

this mode is useful when you want a higher-timeframe oscillator view without a harsh stair-step appearance.

buy/sell signal source

the signal source can be selected separately.

you can choose:

display mode
chart tf
true mtf
smooth mtf

when set to display mode, the signals follow the same source used by the visible oscillator.

beginner recommendation:

use mtf mode on
use smooth mtf display
use display mode as signal source
use confirmed mtf candle on

htf confirmator

the htf confirmator is an additional higher-timeframe filter.

it helps block lower-quality buy and sell signals when the larger trend does not agree.

available htf modes:

ema
williams
ema + williams

ema mode

uses price and ema direction.

williams mode

uses higher-timeframe oscillator direction.

ema + williams mode

requires both the higher-timeframe ema direction and higher-timeframe williams direction to agree.

this is the strictest and cleanest option.

signal modes

aggressive

more signals, faster reaction, more noise.

best for experienced scalpers who want early entries.

balanced

medium filtering.

good for traders who want a mix between frequency and quality.

sniper

strictest mode.

fewer signals, cleaner confirmation, better for beginners and trend-following setups.

entry logic

reversal

focuses on exits from overbought and oversold zones.

example: flow leaves oversold and begins to turn up.

continuation

focuses on midline continuation and momentum reclaim.

example: flow crosses back above the midline during a bullish continuation.

hybrid

uses both reversal and continuation logic.

this is the most flexible mode.

precision score

every signal receives a score from 0 to 100.

the score is based on multiple conditions:

extreme reclaim
trend alignment
flow slope
adx regime
candle impulse
flow/signal cross

higher scores mean stronger confirmation.

beginner recommendation:

minimum precision score: 75 to 85

lower score = more signals
higher score = fewer but cleaner signals

how to use the indicator

step 1: choose the timeframe mode

for normal trading, start with smooth mtf.

example:

chart: 5m
mtf timeframe: 15m or 1h
htf confirmator: 4h

this gives a cleaner view than using the 5m alone.

step 2: read the oscillator zone

if the flow is below 20, the market is oversold.
if the flow is above 80, the market is overbought.
if the flow is above 50, momentum is stronger on the bullish side.
if the flow is below 50, momentum is stronger on the bearish side.

step 3: wait for confirmation

for a buy setup, look for:

flow leaving oversold
flow crossing above the signal line
bullish score above the minimum threshold
htf confirmator bullish
bullish impulse candle if enabled

for a sell setup, look for:

flow leaving overbought
flow crossing below the signal line
bearish score above the minimum threshold
htf confirmator bearish
bearish impulse candle if enabled

step 4: use the dashboard

the dashboard shows:

current flow value
oscillator state
display mode
mtf timeframe
signal source
htf direction
buy score
sell score
last signal

this helps you understand why a signal is accepted or blocked.

step 5: manage risk

do not enter only because a label appears.

before taking a trade, define:

entry
stop loss
target
risk per trade
invalidation level

a clean oscillator signal is not a complete trading plan by itself.

beginner buy example

1. chart is on 5m
2. mtf mode is enabled
3. mtf timeframe is 15m
4. display mode is smooth mtf
5. htf confirmator is set to 4h
6. flow exits oversold
7. flow crosses above the signal line
8. buy score is above 75
9. htf direction is bullish
10. a buy label appears

this is a cleaner long condition than buying only because the oscillator touched oversold.

beginner sell example

1. chart is on 5m
2. mtf mode is enabled
3. mtf timeframe is 15m or 1h
4. display mode is smooth mtf
5. htf confirmator is enabled
6. flow exits overbought
7. flow crosses below the signal line
8. sell score is above 75
9. htf direction is bearish
10. a sell label appears

this helps avoid shorting too early while momentum is still strong.

best settings for scalping

mtf mode: on
mtf timeframe: 15m
display mode: smooth mtf
signal source: display mode
use confirmed mtf candle: on
htf confirmator: on
htf timeframe: 1h or 4h
htf mode: ema + williams
signal mode: balanced or sniper
minimum precision score: 70 to 80
cooldown: 8 to 15 bars

best settings for cleaner trend trades

mtf mode: on
mtf timeframe: 1h
display mode: smooth mtf
signal source: display mode
use confirmed mtf candle: on
htf confirmator: on
htf timeframe: 4h or daily
htf mode: ema + williams
signal mode: sniper
minimum precision score: 80 to 90
require flow / signal cross: on
signals on confirmed candle only: on

tips

use smooth mtf when you want a clean higher-timeframe oscillator view.

use true mtf only when you want the exact higher-timeframe value, even if the line looks stepped.

use sniper mode when the market is choppy.

use balanced mode when the market is moving cleanly.

raise the precision score when there are too many signals.

lower the precision score when signals are too rare.

keep htf confirmation enabled for safer entries.

avoid buying directly into strong resistance.

avoid selling directly into strong support.

the best signals usually happen when oscillator direction, trend direction, and htf confirmation all agree.

alerts

available alerts:

williams %r buy
williams %r sell

for cleaner alert behavior, use once per bar close.

risk warning

this indicator is designed to improve momentum reading and signal filtering, but no indicator can predict every market move.

always use risk management, position sizing, and confirmation from price structure.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("WILLIAMS %R", "W%R", overlay=false, max_bars_back=5000, max_labels_count=500)

//──────────────────────────────────────
// PALETTE
//──────────────────────────────────────
color C_BULL = #00FFD1
color C_BEAR = #FF3B5C
color C_GOLD = #FFD23F
color C_BLUE = #6CA8FF
color C_TXT  = #C9D1D9
color C_DIM  = #5B677A
color C_G0   = #0F1115
color C_G1   = #171A20
color C_G2   = #20242C
color C_G3   = #2B313B
color C_G4   = #7C8796

//──────────────────────────────────────
// INPUTS
//──────────────────────────────────────
g1 = "① WILLIAMS %R CORE"
wrLen      = input.int(21, "Williams %R Length", minval=2, maxval=500, group=g1)
smoothMode = input.string("ZLEMA", "Flow Smoothing", options=["None", "EMA", "RMA", "WMA", "HMA", "ZLEMA"], group=g1)
smoothLen  = input.int(5, "Flow Smooth Length", minval=1, maxval=200, group=g1)
signalMode = input.string("EMA", "Signal Smoothing", options=["EMA", "RMA", "WMA", "HMA", "ZLEMA"], group=g1)
signalLen  = input.int(9, "Signal Length", minval=1, maxval=200, group=g1)

g2 = "② REAL MTF MODE"
useMtfMode         = input.bool(true, "Enable MTF Mode", group=g2)
mtfTf              = input.timeframe("15", "MTF Timeframe", group=g2)
displayMode        = input.string("Smooth MTF", "Oscillator Display Mode", options=["Chart TF", "True MTF", "Smooth MTF"], group=g2)
signalSource       = input.string("Display Mode", "Buy/Sell Signal Source", options=["Display Mode", "Chart TF", "True MTF", "Smooth MTF"], group=g2)
confirmedMtf       = input.bool(true, "Use Confirmed MTF Candle", group=g2)
mtfDisplaySmoothLen = input.int(5, "Smooth MTF Display Length", minval=1, maxval=100, group=g2)

g3 = "③ LEVELS"
osLevel     = input.float(20.0, "Oversold Level", minval=1, maxval=49, step=0.5, group=g3)
obLevel     = input.float(80.0, "Overbought Level", minval=51, maxval=99, step=0.5, group=g3)
midLevel    = input.float(50.0, "Midline", minval=1, maxval=99, step=0.5, group=g3)
extremeLow  = input.float(10.0, "Extreme Low", minval=0, maxval=49, step=0.5, group=g3)
extremeHigh = input.float(90.0, "Extreme High", minval=51, maxval=100, step=0.5, group=g3)

g4 = "④ SIGNAL ENGINE"
tradeMode         = input.string("Sniper", "Signal Mode", options=["Aggressive", "Balanced", "Sniper"], group=g4)
entryLogic        = input.string("Hybrid", "Entry Logic", options=["Reversal", "Continuation", "Hybrid"], group=g4)
scoreThreshold    = input.int(75, "Minimum Precision Score", minval=0, maxval=100, group=g4)
memoryBars        = input.int(14, "Extreme Memory Bars", minval=1, maxval=200, group=g4)
cooldownBars      = input.int(10, "Signal Anti-Spam Cooldown", minval=0, maxval=500, group=g4)
confirmedOnly     = input.bool(true, "Signals On Confirmed Candle Only", group=g4)
requireSignalX    = input.bool(true, "Require Flow / Signal Cross", group=g4)
requireMidReclaim = input.bool(false, "Require Midline Reclaim", group=g4)
useImpulse        = input.bool(true, "Impulse Candle Filter", group=g4)
impulseMin        = input.float(0.35, "Minimum Body Ratio", minval=0, maxval=1, step=0.05, group=g4)

g5 = "⑤ CHART TREND FILTER"
useTrendFilter = input.bool(true, "Use Chart Trend Filter", group=g5)
trendLen       = input.int(100, "Trend EMA Length", minval=2, maxval=1000, group=g5)
trendSlopeLen  = input.int(3, "Trend Slope Bars", minval=1, maxval=50, group=g5)

g6 = "⑥ HTF CONFIRMATOR"
useHtfConfirm   = input.bool(true, "Enable HTF Confirmator", group=g6)
htfTf           = input.timeframe("240", "HTF Timeframe", group=g6)
htfLen          = input.int(100, "HTF EMA Length", minval=2, maxval=1000, group=g6)
htfMode         = input.string("EMA + Williams", "HTF Mode", options=["EMA", "Williams", "EMA + Williams"], group=g6)
htfConfirmed    = input.bool(true, "Use Confirmed HTF Candle", group=g6)
allowNeutralHtf = input.bool(false, "Allow Neutral HTF", group=g6)

g7 = "⑦ SCORE WEIGHTS"
wExtreme = input.float(0.24, "Weight · Extreme Reclaim", minval=0, maxval=1, step=0.01, group=g7)
wTrend   = input.float(0.20, "Weight · Trend", minval=0, maxval=1, step=0.01, group=g7)
wSlope   = input.float(0.16, "Weight · Flow Slope", minval=0, maxval=1, step=0.01, group=g7)
wAdx     = input.float(0.14, "Weight · ADX", minval=0, maxval=1, step=0.01, group=g7)
wCandle  = input.float(0.14, "Weight · Candle Impulse", minval=0, maxval=1, step=0.01, group=g7)
wCross   = input.float(0.12, "Weight · Signal Cross", minval=0, maxval=1, step=0.01, group=g7)

g8 = "⑧ VISUALS"
showFlow       = input.bool(true, "Show Flow", group=g8)
showSignal     = input.bool(true, "Show Signal Line", group=g8)
showGlow       = input.bool(true, "Futuristic Glow", group=g8)
showRibbon     = input.bool(true, "Flow / Signal Fill", group=g8)
showZones      = input.bool(true, "Show OB / OS Zones", group=g8)
showBackground = input.bool(false, "Background Tint", group=g8)
colorCandles   = input.bool(false, "Color Chart Candles", group=g8)
lineWidth      = input.int(2, "Main Line Width", minval=1, maxval=5, group=g8)

g9 = "⑨ SIGNAL MARKERS"
showBuyMarkers  = input.bool(true, "Show Buy Markers", group=g9)
showSellMarkers = input.bool(true, "Show Sell Markers", group=g9)
showScoreText   = input.bool(true, "Show Score Labels", group=g9)
labelSizeOpt    = input.string("Tiny", "Label Size", options=["Tiny", "Small", "Normal"], group=g9)
labelTransp     = input.int(70, "Label Background Transparency", minval=0, maxval=100, group=g9)
autoCleanLabels = input.bool(true, "Auto Clean Labels", group=g9)
maxLabels       = input.int(120, "Max Visible Labels", minval=20, maxval=500, group=g9)
labelMaxAge     = input.int(800, "Delete Labels After X Bars", minval=50, maxval=10000, group=g9)

g10 = "⑩ DASHBOARD"
showDash  = input.bool(true, "Show Dashboard", group=g10)
dashPos   = input.string("Top Right", "Panel Position", options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=g10)
dashSize  = input.string("Tiny", "Panel Text Size", options=["Tiny", "Small", "Normal"], group=g10)
dashEmoji = input.bool(true, "Panel Emojis", group=g10)

//──────────────────────────────────────
// HELPERS
//──────────────────────────────────────
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

f_pos(string p) =>
    p == "Top Right" ? position.top_right :
     p == "Top Center" ? position.top_center :
     p == "Top Left" ? position.top_left :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Center" ? position.middle_center :
     p == "Middle Left" ? position.middle_left :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Center" ? position.bottom_center :
     position.bottom_left

f_hma(float src, int len) =>
    int half = math.max(1, int(len / 2))
    int root = math.max(1, int(math.sqrt(len)))
    float w1 = ta.wma(src, half)
    float w2 = ta.wma(src, len)
    float raw = 2.0 * w1 - w2
    ta.wma(raw, root)

f_zlema(float src, int len) =>
    int lag = math.max(1, int((len - 1) / 2))
    float adj = src + (src - nz(src[lag], src))
    ta.ema(adj, len)

f_smooth(float src, int len, string mode) =>
    float emaV = ta.ema(src, len)
    float rmaV = ta.rma(src, len)
    float wmaV = ta.wma(src, len)
    float hmaV = f_hma(src, len)
    float zlemaV = f_zlema(src, len)

    mode == "None"  ? src :
     mode == "EMA"   ? emaV :
     mode == "RMA"   ? rmaV :
     mode == "WMA"   ? wmaV :
     mode == "HMA"   ? hmaV :
     mode == "ZLEMA" ? zlemaV :
     src

f_wr_raw() =>
    float hh = ta.highest(high, wrLen)
    float ll = ta.lowest(low, wrLen)
    float den = math.max(hh - ll, syminfo.mintick)
    100.0 * (close - ll) / den

f_flow() =>
    float raw = f_wr_raw()
    f_smooth(raw, smoothLen, smoothMode)

f_signal_line() =>
    float f = f_flow()
    f_smooth(f, signalLen, signalMode)

f_flow_prev() =>
    float f = f_flow()
    f[1]

f_signal_prev() =>
    float s = f_signal_line()
    s[1]

f_htf_dir() =>
    float f = f_flow()
    float s = f_signal_line()
    float e = ta.ema(close, htfLen)

    int emaDir = close > e and e >= e[1] ? 1 : close < e and e <= e[1] ? -1 : 0
    int wrDir = f > s and f > midLevel ? 1 : f < s and f < midLevel ? -1 : 0

    htfMode == "EMA" ? emaDir : htfMode == "Williams" ? wrDir : emaDir == wrDir ? emaDir : 0

f_htf_dir_prev() =>
    int d = f_htf_dir()
    nz(d[1], d)

//──────────────────────────────────────
// CHART TF OSCILLATOR
//──────────────────────────────────────
float chartFlow = f_flow()
float chartSig  = f_smooth(chartFlow, signalLen, signalMode)

//──────────────────────────────────────
// TRUE MTF OSCILLATOR
//──────────────────────────────────────
float mtfFlowLive = request.security(syminfo.tickerid, mtfTf, f_flow(), lookahead=barmerge.lookahead_off)
float mtfSigLive  = request.security(syminfo.tickerid, mtfTf, f_signal_line(), lookahead=barmerge.lookahead_off)

float mtfFlowConf = request.security(syminfo.tickerid, mtfTf, f_flow_prev(), lookahead=barmerge.lookahead_off)
float mtfSigConf  = request.security(syminfo.tickerid, mtfTf, f_signal_prev(), lookahead=barmerge.lookahead_off)

float trueMtfFlow = confirmedMtf ? mtfFlowConf : mtfFlowLive
float trueMtfSig  = confirmedMtf ? mtfSigConf : mtfSigLive

//──────────────────────────────────────
// SMOOTH MTF DISPLAY — FIXED LENGTH, NO SERIES INT
//──────────────────────────────────────
float smoothMtfFlow = ta.ema(trueMtfFlow, mtfDisplaySmoothLen)
float smoothMtfSig  = ta.ema(trueMtfSig, mtfDisplaySmoothLen)

//──────────────────────────────────────
// DISPLAY SOURCE
//──────────────────────────────────────
string effectiveDisplay = not useMtfMode ? "Chart TF" : displayMode

float displayFlow = effectiveDisplay == "True MTF" ? trueMtfFlow : effectiveDisplay == "Smooth MTF" ? smoothMtfFlow : chartFlow
float displaySig  = effectiveDisplay == "True MTF" ? trueMtfSig  : effectiveDisplay == "Smooth MTF" ? smoothMtfSig  : chartSig

//──────────────────────────────────────
// SIGNAL SOURCE
//──────────────────────────────────────
string effectiveSignalSource = signalSource == "Display Mode" ? effectiveDisplay : signalSource
effectiveSignalSource := not useMtfMode ? "Chart TF" : effectiveSignalSource

float sigFlow = effectiveSignalSource == "True MTF" ? trueMtfFlow : effectiveSignalSource == "Smooth MTF" ? smoothMtfFlow : chartFlow
float sigLine = effectiveSignalSource == "True MTF" ? trueMtfSig  : effectiveSignalSource == "Smooth MTF" ? smoothMtfSig  : chartSig

//──────────────────────────────────────
// GLOBAL SIGNAL CALCULATIONS
//──────────────────────────────────────
bool xUp = ta.crossover(sigFlow, sigLine)
bool xDn = ta.crossunder(sigFlow, sigLine)
bool xOs = ta.crossover(sigFlow, osLevel)
bool xOb = ta.crossunder(sigFlow, obLevel)
bool xMidUp = ta.crossover(sigFlow, midLevel)
bool xMidDn = ta.crossunder(sigFlow, midLevel)

int barsSinceOs = ta.barssince(sigFlow < osLevel)
int barsSinceOb = ta.barssince(sigFlow > obLevel)

bool osMemory = not na(barsSinceOs) and barsSinceOs <= memoryBars
bool obMemory = not na(barsSinceOb) and barsSinceOb <= memoryBars

bool slopeUp = sigFlow > sigFlow[1] and sigLine >= sigLine[1]
bool slopeDn = sigFlow < sigFlow[1] and sigLine <= sigLine[1]

float trendEma = ta.ema(close, trendLen)
bool trendBull = close > trendEma and trendEma >= trendEma[trendSlopeLen]
bool trendBear = close < trendEma and trendEma <= trendEma[trendSlopeLen]

[diPlus, diMinus, adxV] = ta.dmi(14, 14)

float candleRange = math.max(high - low, syminfo.mintick)
float bodyRatio = math.abs(close - open) / candleRange

bool bullImpulse = close > open and bodyRatio >= impulseMin
bool bearImpulse = close < open and bodyRatio >= impulseMin

bool crossLongOk = not requireSignalX or xUp or sigFlow > sigLine
bool crossShortOk = not requireSignalX or xDn or sigFlow < sigLine

bool midLongOk = not requireMidReclaim or sigFlow > midLevel or xMidUp
bool midShortOk = not requireMidReclaim or sigFlow < midLevel or xMidDn

bool trendLongOk = not useTrendFilter or trendBull
bool trendShortOk = not useTrendFilter or trendBear

bool impulseLongOk = not useImpulse or bullImpulse
bool impulseShortOk = not useImpulse or bearImpulse

bool reversalBuy = xOs or (osMemory and xUp and sigFlow > osLevel)
bool reversalSell = xOb or (obMemory and xDn and sigFlow < obLevel)

bool contBuy = xMidUp or (sigFlow > midLevel and xUp)
bool contSell = xMidDn or (sigFlow < midLevel and xDn)

bool baseBuy = entryLogic == "Reversal" ? reversalBuy : entryLogic == "Continuation" ? contBuy : reversalBuy or contBuy
bool baseSell = entryLogic == "Reversal" ? reversalSell : entryLogic == "Continuation" ? contSell : reversalSell or contSell

bool buySetup = tradeMode == "Aggressive" ? baseBuy :
     tradeMode == "Balanced" ? baseBuy and crossLongOk and slopeUp :
     baseBuy and crossLongOk and trendLongOk and midLongOk and slopeUp

bool sellSetup = tradeMode == "Aggressive" ? baseSell :
     tradeMode == "Balanced" ? baseSell and crossShortOk and slopeDn :
     baseSell and crossShortOk and trendShortOk and midShortOk and slopeDn

//──────────────────────────────────────
// SCORE
//──────────────────────────────────────
float buyExtremeScore = reversalBuy ? 1.0 : sigFlow <= extremeLow ? 0.65 : sigFlow < osLevel ? 0.55 : 0.20
float sellExtremeScore = reversalSell ? 1.0 : sigFlow >= extremeHigh ? 0.65 : sigFlow > obLevel ? 0.55 : 0.20

float buyTrendScore = trendBull ? 1.0 : not useTrendFilter ? 0.70 : close > trendEma ? 0.45 : 0.0
float sellTrendScore = trendBear ? 1.0 : not useTrendFilter ? 0.70 : close < trendEma ? 0.45 : 0.0

float buySlopeScore = slopeUp ? 1.0 : sigFlow > sigFlow[1] ? 0.50 : 0.0
float sellSlopeScore = slopeDn ? 1.0 : sigFlow < sigFlow[1] ? 0.50 : 0.0

float adxScore = f_clamp((adxV - 14.0) / 22.0, 0.0, 1.0)

float buyCandleScore = bullImpulse ? 1.0 : close > open ? 0.50 : 0.0
float sellCandleScore = bearImpulse ? 1.0 : close < open ? 0.50 : 0.0

float buyCrossScore = xUp ? 1.0 : sigFlow > sigLine ? 0.55 : 0.0
float sellCrossScore = xDn ? 1.0 : sigFlow < sigLine ? 0.55 : 0.0

float wSum = wExtreme + wTrend + wSlope + wAdx + wCandle + wCross

float buyScore = wSum > 0 ? 100.0 * (wExtreme * buyExtremeScore + wTrend * buyTrendScore + wSlope * buySlopeScore + wAdx * adxScore + wCandle * buyCandleScore + wCross * buyCrossScore) / wSum : 0.0
float sellScore = wSum > 0 ? 100.0 * (wExtreme * sellExtremeScore + wTrend * sellTrendScore + wSlope * sellSlopeScore + wAdx * adxScore + wCandle * sellCandleScore + wCross * sellCrossScore) / wSum : 0.0

//──────────────────────────────────────
// HTF CONFIRMATOR
//──────────────────────────────────────
int htfDirLive = request.security(syminfo.tickerid, htfTf, f_htf_dir(), lookahead=barmerge.lookahead_off)
int htfDirConf = request.security(syminfo.tickerid, htfTf, f_htf_dir_prev(), lookahead=barmerge.lookahead_off)

int htfDir = htfConfirmed ? htfDirConf : htfDirLive

bool htfBuyOk = not useHtfConfirm or htfDir == 1 or (allowNeutralHtf and htfDir == 0)
bool htfSellOk = not useHtfConfirm or htfDir == -1 or (allowNeutralHtf and htfDir == 0)

bool signalConfirmed = not confirmedOnly or barstate.isconfirmed

//──────────────────────────────────────
// FINAL SIGNALS
//──────────────────────────────────────
var int lastBuyBar = na
var int lastSellBar = na

bool buyCooldownOk = na(lastBuyBar) or bar_index - lastBuyBar >= cooldownBars
bool sellCooldownOk = na(lastSellBar) or bar_index - lastSellBar >= cooldownBars

bool rawBuy = buySetup and impulseLongOk and buyScore >= scoreThreshold
bool rawSell = sellSetup and impulseShortOk and sellScore >= scoreThreshold

bool buySignal = rawBuy and not rawBuy[1] and htfBuyOk and buyCooldownOk and signalConfirmed
bool sellSignal = rawSell and not rawSell[1] and htfSellOk and sellCooldownOk and signalConfirmed

if buySignal
    lastBuyBar := bar_index

if sellSignal
    lastSellBar := bar_index

//──────────────────────────────────────
// LABEL MANAGER
//──────────────────────────────────────
var label[] labs = array.new_label()
var int[] labBars = array.new_int()

f_add_label(float y, string txt, bool bull) =>
    color bg = bull ? color.new(C_BULL, labelTransp) : color.new(C_BEAR, labelTransp)
    color tc = bull ? C_BULL : C_BEAR
    st = bull ? label.style_label_up : label.style_label_down
    label lb = label.new(bar_index, y, txt, style=st, color=bg, textcolor=tc, size=f_size(labelSizeOpt))
    array.push(labs, lb)
    array.push(labBars, bar_index)

    if autoCleanLabels
        while array.size(labs) > maxLabels
            label.delete(array.shift(labs))
            array.shift(labBars)

f_clean_labels() =>
    if autoCleanLabels and array.size(labs) > 0
        int i = 0
        while i < array.size(labs)
            int b = array.get(labBars, i)
            if bar_index - b > labelMaxAge
                label.delete(array.get(labs, i))
                array.remove(labs, i)
                array.remove(labBars, i)
            else
                i += 1

if showBuyMarkers and buySignal and showScoreText
    f_add_label(osLevel - 6.0, "buy " + str.tostring(buyScore, "#"), true)

if showSellMarkers and sellSignal and showScoreText
    f_add_label(obLevel + 6.0, "sell " + str.tostring(sellScore, "#"), false)

f_clean_labels()

//──────────────────────────────────────
// VISUALS
//──────────────────────────────────────
color flowCol = displayFlow >= displaySig ? C_BULL : C_BEAR

hTop = hline(100, "100", color=color.new(C_DIM, 85))
hOB = hline(obLevel, "overbought", color=color.new(C_BEAR, 35))
hMid = hline(midLevel, "mid", color=color.new(C_DIM, 65), linestyle=hline.style_dotted)
hOS = hline(osLevel, "oversold", color=color.new(C_BULL, 35))
hBot = hline(0, "0", color=color.new(C_DIM, 85))

fill(hTop, hOB, color=showZones ? color.new(C_BEAR, 90) : na, title="Overbought Zone")
fill(hOS, hBot, color=showZones ? color.new(C_BULL, 90) : na, title="Oversold Zone")

plot(showGlow ? displayFlow : na, "Glow 3", color=color.new(flowCol, 88), linewidth=lineWidth + 8)
plot(showGlow ? displayFlow : na, "Glow 2", color=color.new(flowCol, 78), linewidth=lineWidth + 5)
plot(showGlow ? displayFlow : na, "Glow 1", color=color.new(flowCol, 65), linewidth=lineWidth + 2)

pFlow = plot(showFlow ? displayFlow : na, "Williams Flow", color=color.new(flowCol, 0), linewidth=lineWidth)
pSig = plot(showSignal ? displaySig : na, "Signal", color=color.new(C_BLUE, 10), linewidth=1)

fill(pFlow, pSig, color=showRibbon ? color.new(flowCol, 82) : na, title="Flow Fill")

plotshape(showBuyMarkers and buySignal ? osLevel - 6.0 : na, "Buy Pulse", shape.diamond, location.absolute, color.new(C_BULL, 0), size=size.tiny)
plotshape(showSellMarkers and sellSignal ? obLevel + 6.0 : na, "Sell Pulse", shape.diamond, location.absolute, color.new(C_BEAR, 0), size=size.tiny)

barcolor(colorCandles ? flowCol : na)
bgcolor(showBackground ? color.new(flowCol, 94) : na, title="Regime Background")

//──────────────────────────────────────
// DASHBOARD
//──────────────────────────────────────
var table dash = na
var string dashKey = ""

curDashKey = dashPos + "|" + dashSize + "|" + str.tostring(dashEmoji)
posSel = f_pos(dashPos)
sz = f_size(dashSize)

var string lastSig = "—"
var color lastSigCol = C_DIM

if buySignal
    lastSig := "buy " + str.tostring(buyScore, "#")
    lastSigCol := C_BULL

if sellSignal
    lastSig := "sell " + str.tostring(sellScore, "#")
    lastSigCol := C_BEAR

if barstate.islast
    if showDash
        if na(dash) or dashKey != curDashKey
            if not na(dash)
                table.delete(dash)

            dash := table.new(posSel, 2, 10, bgcolor=color.new(C_G0, 4), border_color=color.new(C_G4, 45), border_width=1, frame_color=color.new(C_G4, 35), frame_width=1)
            dashKey := curDashKey

        string eFlow = dashEmoji ? "🌊 " : ""
        string eMtf = dashEmoji ? "📡 " : ""
        string eHtf = dashEmoji ? "🧭 " : ""
        string eScore = dashEmoji ? "🎯 " : ""
        string eMode = dashEmoji ? "⚙ " : ""
        string eSig = dashEmoji ? "🔔 " : ""

        string flowState = displayFlow > obLevel ? "overbought" : displayFlow < osLevel ? "oversold" : displayFlow >= midLevel ? "bull zone" : "bear zone"
        color flowStateCol = displayFlow > obLevel ? C_BEAR : displayFlow < osLevel ? C_BULL : displayFlow >= midLevel ? C_BULL : C_BEAR

        string htfTxt = not useHtfConfirm ? "off" : htfDir == 1 ? "▲ bull" : htfDir == -1 ? "▼ bear" : "— neutral"
        color htfCol = not useHtfConfirm ? C_DIM : htfDir == 1 ? C_BULL : htfDir == -1 ? C_BEAR : C_DIM

        table.cell(dash, 0, 0, "W%R GOD MODE", text_color=C_TXT, bgcolor=C_G3, text_size=sz, text_halign=text.align_center)
        table.cell(dash, 1, 0, "MTF", text_color=C_TXT, bgcolor=C_G3, text_size=sz, text_halign=text.align_center)

        table.cell(dash, 0, 1, eFlow + "FLOW", text_color=C_TXT, bgcolor=C_G1, text_size=sz, text_halign=text.align_left)
        table.cell(dash, 1, 1, str.tostring(displayFlow, "#.0"), text_color=flowCol, bgcolor=C_G1, text_size=sz, text_halign=text.align_right)

        table.cell(dash, 0, 2, eFlow + "STATE", text_color=C_TXT, bgcolor=C_G2, text_size=sz, text_halign=text.align_left)
        table.cell(dash, 1, 2, flowState, text_color=flowStateCol, bgcolor=C_G2, text_size=sz, text_halign=text.align_right)

        table.cell(dash, 0, 3, eMtf + "DISPLAY", text_color=C_TXT, bgcolor=C_G1, text_size=sz, text_halign=text.align_left)
        table.cell(dash, 1, 3, effectiveDisplay, text_color=useMtfMode ? C_GOLD : C_DIM, bgcolor=C_G1, text_size=sz, text_halign=text.align_right)

        table.cell(dash, 0, 4, eMtf + "MTF TF", text_color=C_TXT, bgcolor=C_G2, text_size=sz, text_halign=text.align_left)
        table.cell(dash, 1, 4, useMtfMode ? str.upper(mtfTf) : "off", text_color=useMtfMode ? C_GOLD : C_DIM, bgcolor=C_G2, text_size=sz, text_halign=text.align_right)

        table.cell(dash, 0, 5, eMode + "SIGNAL SRC", text_color=C_TXT, bgcolor=C_G1, text_size=sz, text_halign=text.align_left)
        table.cell(dash, 1, 5, effectiveSignalSource, text_color=C_GOLD, bgcolor=C_G1, text_size=sz, text_halign=text.align_right)

        table.cell(dash, 0, 6, eHtf + "HTF " + str.upper(htfTf), text_color=C_TXT, bgcolor=C_G2, text_size=sz, text_halign=text.align_left)
        table.cell(dash, 1, 6, htfTxt, text_color=htfCol, bgcolor=C_G2, text_size=sz, text_halign=text.align_right)

        table.cell(dash, 0, 7, eScore + "BUY SCORE", text_color=C_TXT, bgcolor=C_G1, text_size=sz, text_halign=text.align_left)
        table.cell(dash, 1, 7, str.tostring(buyScore, "#") + " / 100", text_color=buyScore >= scoreThreshold ? C_BULL : C_DIM, bgcolor=C_G1, text_size=sz, text_halign=text.align_right)

        table.cell(dash, 0, 8, eScore + "SELL SCORE", text_color=C_TXT, bgcolor=C_G2, text_size=sz, text_halign=text.align_left)
        table.cell(dash, 1, 8, str.tostring(sellScore, "#") + " / 100", text_color=sellScore >= scoreThreshold ? C_BEAR : C_DIM, bgcolor=C_G2, text_size=sz, text_halign=text.align_right)

        table.cell(dash, 0, 9, eSig + "LAST SIG", text_color=C_TXT, bgcolor=C_G1, text_size=sz, text_halign=text.align_left)
        table.cell(dash, 1, 9, lastSig, text_color=lastSigCol, bgcolor=C_G1, text_size=sz, text_halign=text.align_right)
    else
        if not na(dash)
            table.delete(dash)
            dash := na
            dashKey := ""

//──────────────────────────────────────
// ALERTS
//──────────────────────────────────────
alertcondition(buySignal, "Williams %R Buy", "W%R buy signal confirmed")
alertcondition(sellSignal, "Williams %R Sell", "W%R GOD sell signal confirmed")
````
