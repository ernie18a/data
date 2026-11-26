# SHK CCI RSI StochRSI Fisher Blended Oscillator divergence

- url: https://www.tradingview.com/script/jn89BVvO-SHK-CCI-RSI-StochRSI-Fisher-Blended-Oscillator-divergence/
- type: indicator
- pine_id: PUB;44de5b971f3b47f2b42f46a0b8871220
- version: 1.0

## Description

╔══════════════════════════════════════════════════════════════╗
         [b]SHK Blended Oscillator[/b]
         CCI + RSI + Stoch RSI + Fisher [Divergence + Signals]
╚══════════════════════════════════════════════════════════════╝

A professional-grade momentum oscillator that blends four powerful
indicators — CCI, RSI, Stochastic RSI, and Fisher Transform — into
one single weighted signal line. No clutter, no multiple panes.
Just one clean oscillator with maximum confluence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔷 HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Each indicator is normalized to the CCI scale (±100/±200) and
blended using user-defined weights. The result is a single line
that represents the combined momentum of all four indicators.
A signal MA line is plotted over the blended line for crossover
confirmation.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 4 BLENDED INDICATORS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
① CCI  — Commodity Channel Index (core base, always active)
② RSI  — Relative Strength Index (normalized to CCI scale)
③ Stoch RSI — Stochastic RSI K line (normalized to CCI scale)
④ Fisher Transform — Price distribution oscillator (normalized)

Each indicator can be enabled/disabled independently.
Each has its own blend weight (0.1 to 3.0) to control influence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 11 SIGNAL MA TYPES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Choose any of 11 moving average types for the signal line:

▸ SMA  — Simple MA
  Equal weight to all bars. Slowest. Best for clean baselines.

▸ EMA  — Exponential MA
  More weight on recent bars. Balanced lag. Best general purpose.

▸ WMA  — Weighted MA
  Linear weight to recent bars. Slightly faster than SMA.

▸ RMA  — Wilder's Smoothed MA
  Same smoothing method used inside RSI and ATR. Very smooth,
  minimal noise. Best for swing trades.

▸ HMA  — Hull MA
  Fastest MA with least lag. Reactive to price changes.
  Best for intraday Nifty/BankNifty options scalping.

▸ VWMA — Volume Weighted MA
  Weights bars by volume. Gives more importance to high-volume
  moves. Best for volume-heavy stocks like Reliance, TCS.

▸ SWMA — Symmetrically Weighted MA
  Fixed 4-bar symmetric weighting. No length setting needed.
  Smooth and balanced.

▸ DEMA — Double EMA
  2×EMA − EMA(EMA). Reduces lag significantly compared to EMA.
  Good for trend-following entries.

▸ TEMA — Triple EMA
  3×E1 − 3×E2 + E3. Very fast, aggressive lag reduction.
  Best for strong trending markets.

▸ LSMA — Least Squares MA (Linear Regression)
  Fits a regression line to price. Excellent for identifying
  clean trend direction. Best for daily/weekly charts.

▸ ALMA — Arnaud Legoux MA
  Gaussian-weighted MA with customizable Offset and Sigma.
  Low lag + low noise. Best for commodity options (Gold, Crude).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 SIGNAL SYSTEM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▲ Bull Signal — appears when:
  • Blended line is above signal MA (strength confirmed)
  • AND any one of these fires:
    - Blended crosses above zero
    - RSI exits oversold zone
    - StochRSI K exits oversold zone
    - Fisher exits oversold level

▼ Bear Signal — appears when:
  • Blended line is below signal MA (strength confirmed)
  • AND any one of these fires:
    - Blended crosses below zero
    - RSI exits overbought zone
    - StochRSI K exits overbought zone
    - Fisher exits overbought level

Only ONE ▲ and ONE ▼ symbol per bar — no clutter.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 DIVERGENCE DETECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✦ CCI Divergence — draws solid lines on the blended oscillator
  • Bullish: price lower low + blended higher low → Lime line
  • Bearish: price higher high + blended lower high → Red line

✦ RSI Divergence — draws dashed lines on RSI (normalized)
  • Bullish divergence → Aqua dashed line
  • Bearish divergence → Orange dashed line

✦ Labels auto-printed:
  "CCI Bull Div" / "CCI Bear Div"
  "RSI Bull Div" / "RSI Bear Div"
  "CCI&RSI Bull Div" when both confirm together

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 VISUAL FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Strength Histogram — color-coded background bars behind the line
• Blended Line Color:
  Bright Lime  = above zero + above MA (strong bull)
  Faded Lime   = below zero but above MA (weak bull)
  Bright Red   = below zero + below MA (strong bear)
  Faded Red    = above zero but below MA (weak bear)
• Signal MA Color:
  Green = Heikin Ashi bullish candle
  Red   = Heikin Ashi bearish candle
• Extreme Zone BG Highlight:
  Green background = blended above +100 and above MA
  Red background   = blended below -100 and below MA
• Horizontal Levels: ±200 (OB/OS), ±100, Zero line
• Blue filled zone between +100 and -100 (normal range)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 30+ ALERT CONDITIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Blended Alerts:
• Strong Bullish / Strong Bearish
• Zero line cross up / down
• Above +100 / Below -100
• Hit Overbought / Oversold
• Exit Overbought / Exit Oversold

RSI Alerts:
• RSI above OB / below OS
• RSI cross above/below 50

StochRSI Alerts:
• K cross above oversold / below overbought
• K cross above / below D

Fisher Alerts:
• Fisher cross above/below oversold/overbought
• Fisher cross above/below zero

Combined:
• Any Bull Signal fired
• Any Bear Signal fired

Heikin Ashi:
• HA turned Bullish / Bearish

Divergence:
• CCI Bull/Bear Div
• RSI Bull/Bear Div
• CCI & RSI both confirmed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS GROUPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• CCI Settings — length, source, MA type, MA length, ALMA params
• Levels — OB/OS and ±100 levels fully adjustable
• RSI Settings — length, source, OB/OS, blend weight
• StochRSI Settings — RSI len, Stoch len, K/D smooth, OB/OS, weight
• Fisher Settings — length, OB/OS levels, blend weight
• Features — toggle divergences, histogram, signals, extremes
• Divergence — lookback bars and threshold sensitivity

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🇮🇳 BEST FOR INDIAN MARKETS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✔ Nifty 50 / BankNifty intraday options (HMA or TEMA)
✔ Sensex daily swing trades (ALMA or RMA)
✔ MCX Gold / Crude Oil options (ALMA or LSMA)
✔ NSE large-cap stocks (VWMA)
✔ All timeframes — 1m to Monthly

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT DISCLAIMER — READ BEFORE USE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FOR EDUCATIONAL PURPOSES ONLY
This indicator is not financial advice, investment advice, or
a recommendation to buy or sell any financial instrument.
All signals, alerts, and visual outputs are informational only.

NO GUARANTEE OF ACCURACY
Technical indicators are mathematical calculations based on
historical price data. They are lagging by nature and cannot
predict future price movements. Signals may be false, delayed,
or unreliable during high volatility, news events, or low
liquidity conditions.

RISK OF LOSS
Trading financial markets involves substantial risk. Options
and derivatives carry even higher risk due to leverage — you
can lose your entire invested capital. Never trade with money
you cannot afford to lose.

YOUR RESPONSIBILITY
• You are solely responsible for all your trading decisions.
• Never use this as your only reason to enter or exit a trade.
• Always apply stop-loss, proper position sizing, and risk
  management on every single trade.
• Consult a SEBI-registered advisor before making significant
  financial decisions.
• The author accepts NO liability for any losses incurred
  from the use or misuse of this indicator.

INDIA MARKET NOTE
NSE, BSE, and MCX markets are subject to SEBI regulations,
RBI policy decisions, Budget announcements, and circuit
breakers — all of which can cause sudden moves that no
indicator can anticipate. Always check news calendars.

Past performance shown on historical charts does NOT
guarantee future results under any circumstances.

─────────────────────────────────────────
© SHK — All rights reserved.
Unauthorized copying or resale of this script is strictly
prohibited under TradingView House Rules.
─────────────────────────────────────────

## Source Code

````pine
//@version=6
// ============================================================================
// SHK CCI + RSI + StochRSI + Fisher — 2 Line Oscillator v8
// ============================================================================
indicator(
     title            = "SHK CCI+RSI+StochRSI+Fisher",
     shorttitle       = "CCI+RSI+SF",
     format           = format.price,
     precision        = 2,
     overlay          = false,
     max_lines_count  = 500,
     max_labels_count = 500
)

// ============================================================================
// INPUTS — CCI
// ============================================================================
cciLen     = input.int   (20,   minval=1, title="CCI Length",       group="CCI Settings")
src        = input       (hlc3,           title="Source",           group="CCI Settings")
maType     = input.string("EMA",          title="Signal MA Type",
              options=["SMA","EMA","WMA","RMA","HMA","VWMA","SWMA","DEMA","TEMA","LSMA","ALMA"],
              group="CCI Settings")
maLen      = input.int   (14,   minval=1, title="Signal MA Length", group="CCI Settings")
almaOffset = input.float (0.85, "ALMA Offset", minval=0.0, maxval=1.0,  step=0.05, group="CCI Settings")
almaSigma  = input.float (6.0,  "ALMA Sigma",  minval=1.0, maxval=10.0, step=0.5,  group="CCI Settings")

// ============================================================================
// INPUTS — LEVELS
// ============================================================================
customOB    = input.int( 100, "Overbought Level", group="Levels")
customOS    = input.int(-100, "Oversold Level",   group="Levels")
level100    = input.int( 100, "Upper Level",      group="Levels")
levelNeg100 = input.int(-100, "Lower Level",      group="Levels")

// ============================================================================
// INPUTS — RSI
// ============================================================================
rsiEnable = input.bool (true,  "Enable RSI",          group="RSI Settings")
rsiLength = input.int  (14,    "RSI Length",minval=1, group="RSI Settings")
rsiSrc    = input      (close, "RSI Source",          group="RSI Settings")
rsiOB     = input.int  (70,    "Overbought",          group="RSI Settings")
rsiOS     = input.int  (30,    "Oversold",            group="RSI Settings")
rsiWeight = input.float(1.0,   "RSI Blend Weight", minval=0.1, maxval=3.0, step=0.1, group="RSI Settings")

// ============================================================================
// INPUTS — STOCHASTIC RSI
// ============================================================================
stochEnable   = input.bool  (true,  "Enable StochRSI",          group="StochRSI Settings")
stochRsiLen   = input.int   (14,    "RSI Length",   minval=1,   group="StochRSI Settings")
stochLen      = input.int   (14,    "Stoch Length", minval=1,   group="StochRSI Settings")
stochSmooth_K = input.int   (3,     "Smooth K",     minval=1,   group="StochRSI Settings")
stochSmooth_D = input.int   (3,     "Smooth D",     minval=1,   group="StochRSI Settings")
stochOB       = input.float (80.0,  "Overbought",               group="StochRSI Settings")
stochOS       = input.float (20.0,  "Oversold",                 group="StochRSI Settings")
stochWeight   = input.float (1.0,   "StochRSI Blend Weight", minval=0.1, maxval=3.0, step=0.1, group="StochRSI Settings")

// ============================================================================
// INPUTS — FISHER
// ============================================================================
fishEnable = input.bool (true,  "Enable Fisher Transform",     group="Fisher Settings")
fishLen    = input.int  (9,     "Fisher Length",   minval=2,   group="Fisher Settings")
fishOB     = input.float(2.0,   "Overbought Level",            group="Fisher Settings")
fishOS     = input.float(-2.0,  "Oversold Level",              group="Fisher Settings")
fishWeight = input.float(1.0,   "Fisher Blend Weight", minval=0.1, maxval=3.0, step=0.1, group="Fisher Settings")

// ============================================================================
// INPUTS — FEATURES
// ============================================================================
showCCIDiv    = input.bool(true, "Show CCI Divergences",    group="Features")
showRSIDiv    = input.bool(true, "Show RSI Divergences",    group="Features")
showStrength  = input.bool(true, "Show Strength Histogram", group="Features")
showZeroCross = input.bool(true, "Show Zero Line Crosses",  group="Features")
showExtremes  = input.bool(true, "Highlight Extreme Zones", group="Features")

// ============================================================================
// INPUTS — DIVERGENCE
// ============================================================================
divLookback  = input.int  (5,  "Divergence Lookback",      minval=1, maxval=20, group="Divergence")
cciDivThresh = input.float(10, "CCI Divergence Threshold", minval=1, maxval=50, group="Divergence")
rsiDivThresh = input.float(3,  "RSI Divergence Threshold", minval=1, maxval=20, group="Divergence")

// ============================================================================
// HEIKIN ASHI
// ============================================================================
haClose = (open + high + low + close) / 4.0
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2.0 : (haOpen[1] + haClose[1]) / 2.0
haBull  = haClose >= haOpen

// ============================================================================
// CCI
// ============================================================================
cciBasis = ta.sma(src, cciLen)
cci      = (src - cciBasis) / (0.015 * ta.dev(src, cciLen))

// ============================================================================
// RSI — normalized to CCI scale
// ============================================================================
rsi     = ta.rsi(rsiSrc, rsiLength)
rsiNorm = rsiEnable ? (rsi - 50.0) / float(rsiOB - 50) * float(level100) : na

// ============================================================================
// STOCHASTIC RSI — normalized to CCI scale
// ============================================================================
_stochRsi  = ta.rsi(close, stochRsiLen)
_stochLow  = ta.lowest (_stochRsi, stochLen)
_stochHigh = ta.highest(_stochRsi, stochLen)
_stochDen  = _stochHigh - _stochLow
_rawK      = _stochDen != 0 ? (_stochRsi - _stochLow) / _stochDen * 100.0 : 50.0
stochK     = ta.sma(_rawK, stochSmooth_K)
stochD     = ta.sma(stochK, stochSmooth_D)
stochKNorm = stochEnable ? (stochK - 50.0) / 50.0 * float(level100) : na

// ============================================================================
// FISHER — normalized to CCI scale
// ============================================================================
_fishHi    = ta.highest(high, fishLen)
_fishLo    = ta.lowest (low,  fishLen)
_fishRange = _fishHi - _fishLo
_fishVal   = _fishRange != 0 ? 2.0 * ((close - _fishLo) / _fishRange) - 1.0 : 0.0
_fishClamp = math.max(math.min(_fishVal, 0.999), -0.999)
var float _fishPrev = 0.0
fisher     = 0.5 * math.log((1.0 + _fishClamp) / (1.0 - _fishClamp)) + 0.5 * _fishPrev
_fishPrev := fisher
_fishScale = float(level100) / fishOB
fishNorm   = fishEnable ? fisher * _fishScale : na

// ============================================================================
// BLENDED LINE — weighted average
// ============================================================================
_cciW   = 1.0
_rsiW   = (rsiEnable   and not na(rsiNorm))   ? rsiWeight   : 0.0
_stochW = (stochEnable and not na(stochKNorm)) ? stochWeight : 0.0
_fishW  = (fishEnable  and not na(fishNorm))   ? fishWeight  : 0.0
_total  = _cciW + _rsiW + _stochW + _fishW

_rsiPart   = (rsiEnable   and not na(rsiNorm))   ? rsiNorm    * _rsiW   : 0.0
_stochPart = (stochEnable and not na(stochKNorm)) ? stochKNorm * _stochW : 0.0
_fishPart  = (fishEnable  and not na(fishNorm))   ? fishNorm   * _fishW  : 0.0

blended = (cci * _cciW + _rsiPart + _stochPart + _fishPart) / _total

// ============================================================================
// SIGNAL MA — all 11 types
// ============================================================================
var float blendMA = na
if maType == "SMA"
    blendMA := ta.sma(blended, maLen)
else if maType == "EMA"
    blendMA := ta.ema(blended, maLen)
else if maType == "WMA"
    blendMA := ta.wma(blended, maLen)
else if maType == "RMA"
    blendMA := ta.rma(blended, maLen)
else if maType == "HMA"
    blendMA := ta.hma(blended, maLen)
else if maType == "VWMA"
    blendMA := ta.vwma(blended, maLen)
else if maType == "SWMA"
    blendMA := ta.swma(blended)
else if maType == "DEMA"
    float _e1 = ta.ema(blended, maLen)
    float _e2 = ta.ema(_e1, maLen)
    blendMA   := 2.0 * _e1 - _e2
else if maType == "TEMA"
    float _t1 = ta.ema(blended, maLen)
    float _t2 = ta.ema(_t1, maLen)
    float _t3 = ta.ema(_t2, maLen)
    blendMA   := 3.0 * _t1 - 3.0 * _t2 + _t3
else if maType == "LSMA"
    blendMA := ta.linreg(blended, maLen, 0)
else if maType == "ALMA"
    blendMA := ta.alma(blended, maLen, almaOffset, almaSigma)

// ============================================================================
// SIGNAL CLASSIFICATION
// ============================================================================
strongBullish = blended >  level100    and blended >= blendMA
strongBearish = blended <  levelNeg100 and blended <  blendMA

// ============================================================================
// STRENGTH FILTER
// ============================================================================
bullStrong = blended >= blendMA
bearStrong = blended <  blendMA

// ============================================================================
// COLORS
// ============================================================================
var color blendColor = na
if blended >= blendMA and blended > 0
    blendColor := color.new(color.lime, 0)
else if blended >= blendMA and blended <= 0
    blendColor := color.new(color.lime, 50)
else if blended < blendMA and blended < 0
    blendColor := color.new(color.red, 0)
else
    blendColor := color.new(color.red, 50)

var color histColor = na
if blended > 0
    histColor := blended > level100 ? color.new(color.lime, 30) : color.new(color.lime, 70)
else
    histColor := blended < levelNeg100 ? color.new(color.red, 30) : color.new(color.red, 70)

var color maColor = na
maColor := haBull ? color.new(color.green, 0) : color.new(color.red, 0)

// ============================================================================
// DIVERGENCE — PIVOTS
// ============================================================================
blendPivHigh = ta.pivothigh(blended, divLookback, divLookback)
blendPivLow  = ta.pivotlow (blended, divLookback, divLookback)
priceHigh    = ta.pivothigh(high,    divLookback, divLookback)
priceLow     = ta.pivotlow (low,     divLookback, divLookback)

rsiPivHigh     = ta.pivothigh(rsi, divLookback, divLookback)
rsiPivLow      = ta.pivotlow (rsi, divLookback, divLookback)
rsiPivHighNorm = not na(rsiPivHigh) ? (rsiPivHigh - 50.0) / float(rsiOB - 50) * float(level100) : na
rsiPivLowNorm  = not na(rsiPivLow)  ? (rsiPivLow  - 50.0) / float(rsiOB - 50) * float(level100) : na

// ============================================================================
// DIVERGENCE — STATE VARIABLES
// ============================================================================
var float lastBLow        = na
var float lastPrcLow      = na
var float lastBHigh       = na
var float lastPrcHigh     = na
var int   lastBLowBar     = na
var int   lastBHighBar    = na
var float lastRSILow      = na
var float lastRSILowNorm  = na
var float lastRSIPrcLow   = na
var int   lastRSILowBar   = na
var float lastRSIHigh     = na
var float lastRSIHighNorm = na
var float lastRSIPrcHigh  = na
var int   lastRSIHighBar  = na

var bool  cciBullFired = false
var bool  rsiBullFired = false
var bool  cciBearFired = false
var bool  rsiBearFired = false
var float bullDivY     = na
var float bearDivY     = na
var float rsiBullY     = na
var float rsiBearY     = na

cciBullFired := false
rsiBullFired := false
cciBearFired := false
rsiBearFired := false
bullDivY     := na
bearDivY     := na
rsiBullY     := na
rsiBearY     := na

// ============================================================================
// DIVERGENCE — CCI BULL
// ============================================================================
if not na(blendPivLow)
    if not na(lastBLow)
        float pl = na(priceLow) ? low[divLookback] : priceLow
        if pl < lastPrcLow and blendPivLow > lastBLow and (blendPivLow - lastBLow) > cciDivThresh
            cciBullFired := true
            bullDivY     := blendPivLow
            if showCCIDiv
                line.new(lastBLowBar, lastBLow, bar_index[divLookback], blendPivLow, color=color.new(color.lime, 0), width=2)
    lastBLow    := blendPivLow
    lastPrcLow  := na(priceLow) ? low[divLookback] : priceLow
    lastBLowBar := bar_index[divLookback]

// ============================================================================
// DIVERGENCE — CCI BEAR
// ============================================================================
if not na(blendPivHigh)
    if not na(lastBHigh)
        float ph = na(priceHigh) ? high[divLookback] : priceHigh
        if ph > lastPrcHigh and blendPivHigh < lastBHigh and (lastBHigh - blendPivHigh) > cciDivThresh
            cciBearFired := true
            bearDivY     := blendPivHigh
            if showCCIDiv
                line.new(lastBHighBar, lastBHigh, bar_index[divLookback], blendPivHigh, color=color.new(color.red, 0), width=2)
    lastBHigh    := blendPivHigh
    lastPrcHigh  := na(priceHigh) ? high[divLookback] : priceHigh
    lastBHighBar := bar_index[divLookback]

// ============================================================================
// DIVERGENCE — RSI BULL
// ============================================================================
if not na(rsiPivLow) and rsiEnable
    if not na(lastRSILow)
        float pl = na(priceLow) ? low[divLookback] : priceLow
        if pl < lastRSIPrcLow and rsiPivLow > lastRSILow and (rsiPivLow - lastRSILow) > rsiDivThresh
            rsiBullFired := true
            rsiBullY     := rsiPivLowNorm
            if showRSIDiv
                line.new(lastRSILowBar, lastRSILowNorm, bar_index[divLookback], rsiPivLowNorm, color=color.new(color.aqua, 0), width=2, style=line.style_dashed)
    lastRSILow     := rsiPivLow
    lastRSILowNorm := rsiPivLowNorm
    lastRSIPrcLow  := na(priceLow) ? low[divLookback] : priceLow
    lastRSILowBar  := bar_index[divLookback]

// ============================================================================
// DIVERGENCE — RSI BEAR
// ============================================================================
if not na(rsiPivHigh) and rsiEnable
    if not na(lastRSIHigh)
        float ph = na(priceHigh) ? high[divLookback] : priceHigh
        if ph > lastRSIPrcHigh and rsiPivHigh < lastRSIHigh and (lastRSIHigh - rsiPivHigh) > rsiDivThresh
            rsiBearFired := true
            rsiBearY     := rsiPivHighNorm
            if showRSIDiv
                line.new(lastRSIHighBar, lastRSIHighNorm, bar_index[divLookback], rsiPivHighNorm, color=color.new(color.orange, 0), width=2, style=line.style_dashed)
    lastRSIHigh     := rsiPivHigh
    lastRSIHighNorm := rsiPivHighNorm
    lastRSIPrcHigh  := na(priceHigh) ? high[divLookback] : priceHigh
    lastRSIHighBar  := bar_index[divLookback]

// ============================================================================
// DIVERGENCE LABELS
// ============================================================================
_anyBullDiv = (showCCIDiv and cciBullFired) or (showRSIDiv and rsiBullFired)
if _anyBullDiv
    bool   _bothBull = showCCIDiv and cciBullFired and showRSIDiv and rsiBullFired
    bool   _cciOnly  = showCCIDiv and cciBullFired and not (showRSIDiv and rsiBullFired)
    string _bullTxt  = _bothBull ? "CCI&RSI Bull Div" : _cciOnly ? "CCI Bull Div" : "RSI Bull Div"
    float  _lblY     = not na(bullDivY) ? bullDivY : rsiBullY
    color  _lblCol   = _bothBull ? color.new(#00C853, 10) : color.new(#2196F3, 10)
    label.new(bar_index[divLookback], _lblY, _bullTxt, style=label.style_label_up, color=_lblCol, textcolor=color.white, size=size.tiny)

_anyBearDiv = (showCCIDiv and cciBearFired) or (showRSIDiv and rsiBearFired)
if _anyBearDiv
    bool   _bothBear = showCCIDiv and cciBearFired and showRSIDiv and rsiBearFired
    bool   _cciOnly2 = showCCIDiv and cciBearFired and not (showRSIDiv and rsiBearFired)
    string _bearTxt  = _bothBear ? "CCI&RSI Bear Div" : _cciOnly2 ? "CCI Bear Div" : "RSI Bear Div"
    float  _lblY2    = not na(bearDivY) ? bearDivY : rsiBearY
    color  _lblCol2  = _bothBear ? color.new(#D50000, 10) : color.new(#FF6D00, 10)
    label.new(bar_index[divLookback], _lblY2, _bearTxt, style=label.style_label_down, color=_lblCol2, textcolor=color.white, size=size.tiny)

// ============================================================================
// COMBINED BULL SIGNAL ▲ — MA aligned + any sub-trigger
// ============================================================================
_bullTrigger = (showZeroCross and ta.crossover(blended, 0))      or
               (rsiEnable     and ta.crossover(rsi,    rsiOS))   or
               (stochEnable   and ta.crossover(stochK, stochOS)) or
               (fishEnable    and ta.crossover(fisher, fishOS))

anyBullSignal = bullStrong and _bullTrigger

plotshape(anyBullSignal, "Bull Signal",
     style    = shape.triangleup,
     location = location.bottom,
     color    = color.new(color.lime, 0),
     size     = size.small)

// ============================================================================
// COMBINED BEAR SIGNAL ▼ — MA aligned + any sub-trigger
// ============================================================================
_bearTrigger = (showZeroCross and ta.crossunder(blended, 0))      or
               (rsiEnable     and ta.crossunder(rsi,    rsiOB))   or
               (stochEnable   and ta.crossunder(stochK, stochOB)) or
               (fishEnable    and ta.crossunder(fisher, fishOB))

anyBearSignal = bearStrong and _bearTrigger

plotshape(anyBearSignal, "Bear Signal",
     style    = shape.triangledown,
     location = location.top,
     color    = color.new(color.red, 0),
     size     = size.small)

// ============================================================================
// MAIN PLOTS — 2 LINES + HISTOGRAM
// ============================================================================
plot(showStrength ? blended : na, "Strength",   style=plot.style_histogram, color=histColor,  linewidth=1)
plot(blended,                     "CCI+RSI+SF", color=blendColor, linewidth=3)
plot(blendMA,                     "Signal MA",  color=maColor,    linewidth=2)

// ============================================================================
// HORIZONTAL LEVELS
// ============================================================================
hline(customOB,    "OB",   color=color.new(color.red,   30), linestyle=hline.style_dashed, linewidth=2)
h_up = hline(level100,    "+100", color=color.new(#787B86, 50), linestyle=hline.style_dashed)
hline(0,           "Zero", color=color.new(color.gray,  30), linewidth=2)
h_dn = hline(levelNeg100, "-100", color=color.new(#787B86, 50), linestyle=hline.style_dashed)
hline(customOS,    "OS",   color=color.new(color.green, 30), linestyle=hline.style_dashed, linewidth=2)
fill(h_up, h_dn, color=color.new(#2196F3, 92), title="Normal Zone")

// ============================================================================
// BGCOLOR
// ============================================================================
bgcolor(showExtremes and strongBullish ? color.new(color.lime, 92) :
        showExtremes and strongBearish  ? color.new(color.red,  92) : na,
        title="Extreme Zone")

// ============================================================================
// ALERTS — BLENDED
// ============================================================================
alertcondition(strongBullish,                        "Strong Bullish",     "CCI+RSI+SF above +100 & above MA")
alertcondition(strongBearish,                        "Strong Bearish",     "CCI+RSI+SF below -100 & below MA")
alertcondition(ta.crossover (blended, 0),            "Bullish Zero Cross", "Blended crossed above zero")
alertcondition(ta.crossunder(blended, 0),            "Bearish Zero Cross", "Blended crossed below zero")
alertcondition(ta.crossover (blended, level100),     "Above +100",         "Blended crossed above +100")
alertcondition(ta.crossunder(blended, levelNeg100),  "Below -100",         "Blended crossed below -100")
alertcondition(ta.cross     (blended, customOB),     "Overbought",         "Blended hit overbought zone")
alertcondition(ta.cross     (customOS, blended),     "Oversold",           "Blended hit oversold zone")
alertcondition(ta.crossunder(blended, customOB),     "Exit Overbought",    "Blended exiting overbought")
alertcondition(ta.crossover (blended, customOS),     "Exit Oversold",      "Blended exiting oversold")

// ============================================================================
// ALERTS — RSI
// ============================================================================
alertcondition(rsiEnable and ta.crossover (rsi, rsiOB), "RSI Overbought",  "RSI crossed above overbought")
alertcondition(rsiEnable and ta.crossunder(rsi, rsiOS), "RSI Oversold",    "RSI crossed below oversold")
alertcondition(rsiEnable and ta.crossover (rsi, 50),    "RSI Bullish Mid", "RSI crossed above 50")
alertcondition(rsiEnable and ta.crossunder(rsi, 50),    "RSI Bearish Mid", "RSI crossed below 50")

// ============================================================================
// ALERTS — STOCHASTIC RSI
// ============================================================================
alertcondition(stochEnable and ta.crossover (stochK, stochOS), "Stoch Cross Up",   "Stoch K crossed above oversold")
alertcondition(stochEnable and ta.crossunder(stochK, stochOB), "Stoch Cross Down", "Stoch K crossed below overbought")
alertcondition(stochEnable and ta.crossover (stochK, stochD),  "Stoch K > D Bull", "Stoch K crossed above D")
alertcondition(stochEnable and ta.crossunder(stochK, stochD),  "Stoch K < D Bear", "Stoch K crossed below D")

// ============================================================================
// ALERTS — FISHER
// ============================================================================
alertcondition(fishEnable and ta.crossover (fisher, fishOS), "Fisher CrossUp",   "Fisher crossed above oversold")
alertcondition(fishEnable and ta.crossunder(fisher, fishOB), "Fisher CrossDown", "Fisher crossed below overbought")
alertcondition(fishEnable and ta.crossover (fisher, 0),      "Fisher Bull Zero", "Fisher crossed above zero")
alertcondition(fishEnable and ta.crossunder(fisher, 0),      "Fisher Bear Zero", "Fisher crossed below zero")

// ============================================================================
// ALERTS — COMBINED
// ============================================================================
alertcondition(anyBullSignal, "Any Bull Signal", "One or more bullish signals fired")
alertcondition(anyBearSignal, "Any Bear Signal", "One or more bearish signals fired")

// ============================================================================
// ALERTS — HA FLIP
// ============================================================================
alertcondition(haBull  and not haBull[1], "HA Turned Bullish", "Heikin Ashi flipped bullish")
alertcondition(not haBull and haBull[1],  "HA Turned Bearish", "Heikin Ashi flipped bearish")

// ============================================================================
// ALERTS — DIVERGENCES
// ============================================================================
alertcondition(cciBullFired and rsiBullFired, "CCI&RSI Bull Div", "Both CCI and RSI bullish divergence confirmed")
alertcondition(cciBearFired and rsiBearFired, "CCI&RSI Bear Div", "Both CCI and RSI bearish divergence confirmed")
alertcondition(cciBullFired,                  "CCI Bull Div",     "CCI bullish divergence")
alertcondition(cciBearFired,                  "CCI Bear Div",     "CCI bearish divergence")
alertcondition(rsiBullFired,                  "RSI Bull Div",     "RSI bullish divergence")
alertcondition(rsiBearFired,                  "RSI Bear Div",     "RSI bearish divergence")
````
