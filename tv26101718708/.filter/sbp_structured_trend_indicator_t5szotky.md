# SBP Structured Trend Indicator

- url: https://www.tradingview.com/script/T5szoTky-SBP-Structured-Trend-Indicator/
- type: indicator
- pine_id: PUB;f45af42a366f443d864850ddce1e8640
- version: 6.0

## Description

# SBP Structured Trend Indicator

## Overview

SBP Structured Trend Indicator is a trend-following decision support tool designed to evaluate market structure through multiple layers of confirmation instead of relying on a single technical indicator.

Rather than generating signals from one moving average crossover or momentum oscillator, the indicator evaluates the agreement between several independent market characteristics before identifying a potential trading opportunity. The objective is to reduce low-quality signals while remaining responsive to changing market conditions.

The indicator automatically adapts its internal parameters for Scalping, Intraday and Swing trading modes so that the same methodology can be applied across different trading styles.

---

## Methodology

The indicator combines several analytical engines, each measuring a different aspect of market behaviour.

### 1. Structured Trend Engine

The primary trend is determined from a smoothed directional filter that measures both trend direction and trend slope. This establishes the dominant market bias before any trading signals are evaluated.

---

### 2. Adaptive Trend Smoothing

An adaptive moving average is used to smooth price movement while reducing lag during directional trends. The slope of this adaptive average is used as an additional confirmation of market direction instead of relying solely on price crossing a moving average.

---

### 3. Trend Consensus Engine

A fast and slow exponential average are evaluated together to estimate trend agreement. Rather than treating a crossover as a signal by itself, the distance between the averages is used to estimate trend strength.

This helps distinguish established trends from weak directional movement.

---

### 4. Volatility Assessment

Current market volatility is compared with its recent average using the Average True Range (ATR).

This allows the indicator to distinguish between expanding and contracting market conditions so that stronger trends receive greater confidence than periods of low activity.

---

### 5. Momentum Evaluation

Momentum is measured using the rate of price change together with recent candle direction.

Momentum confirmation is evaluated alongside the prevailing trend rather than acting as an independent entry trigger.

---

### 6. Trend Confidence Score

A confidence score is calculated from several independent observations, including:

• Momentum strength

• Trend persistence

• Trend strength

• Relative trading volume

The resulting confidence score allows traders to select Aggressive, Balanced or Conservative filtering depending on their preferred trading style.

---

### 7. Position State Logic

The indicator tracks the current directional state to avoid repeatedly issuing identical signals during the same market move.

A new Buy signal is generated only after market conditions support a new bullish transition, while Sell signals follow the same principle for bearish conditions.

This design aims to reduce repetitive alerts during sustained trends.

---

## Trading Modes

### Scalping

Uses shorter internal lookback periods to respond more quickly to short-term price movement.

### Intraday

Balances responsiveness and stability for session-based trading.

### Swing

Uses longer adaptive calculations intended to identify broader market trends while filtering short-term fluctuations.

---

## Dashboard

The optional dashboard summarizes the current analytical state, including:

• Selected trading mode

• Current trend direction

• Market regime

• Trend confidence score

• Latest signal status

The dashboard is intended as a quick reference and should not replace chart analysis.

---

## Suggested Usage

The indicator is designed to be used alongside price action, support and resistance, market structure and prudent risk management.

It is not intended to predict future prices or guarantee profitable trades. Instead, it provides a structured framework for evaluating trend quality and identifying higher-confidence trading opportunities.

As with any analytical tool, users should evaluate signals within the broader market context and test the indicator on instruments and timeframes appropriate to their trading approach.

## Source Code

````pine
//@version=6
indicator(
     "SBP Structured Trend Indicator",
     overlay = true,
     max_labels_count = 200)

string G_DISPLAY = "Display"
string G_SIGNAL  = "Signal Behaviour"
string G_VOLUME  = "Volume Participation"

bool showSignals =
     input.bool(true, "Show BUY / SALE", group = G_DISPLAY)

bool showTrendline =
     input.bool(true, "Show Structured Trendline", group = G_DISPLAY)

string responseMode =
     input.string(
          "Balanced",
          "Response Mode",
          options = ["Responsive", "Balanced", "Conservative"],
          group = G_SIGNAL)

bool useVolume =
     input.bool(true, "Use Volume Participation", group = G_VOLUME)

int volumeLength =
     input.int(
          20,
          "Volume Reference Length",
          minval = 5,
          maxval = 100,
          group = G_VOLUME)

float minimumRelativeVolume =
     input.float(
          0.85,
          "Minimum Relative Volume",
          minval = 0.25,
          maxval = 3.00,
          step = 0.05,
          group = G_VOLUME)

clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(v, hi))

safeDiv(float a, float b) =>
    math.abs(b) <= 0.0000001 ? 0.0 : a / b

bool responsive = responseMode == "Responsive"
bool conservative = responseMode == "Conservative"

int fastLength      = responsive ? 6  : conservative ? 11 : 8
int slowLength      = responsive ? 15 : conservative ? 30 : 21
int phaseLength     = responsive ? 10 : conservative ? 20 : 14
int pressureLength  = responsive ? 10 : conservative ? 20 : 14
int normalizeLength = responsive ? 24 : conservative ? 45 : 30
int momentumLength  = responsive ? 4  : conservative ? 9  : 6
int atrLength       = responsive ? 10 : conservative ? 20 : 14
int extremeLength   = responsive ? 7  : conservative ? 16 : 10
int setupLife       = responsive ? 5  : conservative ? 10 : 7

float entryScore =
     responsive ? 4.0 :
     conservative ? 6.0 :
     5.25

float reversalScore =
     responsive ? 4.5 :
     conservative ? 6.5 :
     5.75

float phaseDistanceRequired =
     responsive ? 0.03 :
     conservative ? 0.12 :
     0.07

float barRange = math.max(high - low, syminfo.mintick)
float body = math.abs(close - open)
float bodyRatio = clamp(safeDiv(body, barRange), 0.0, 1.0)
float closePos = clamp(safeDiv(close - low, barRange), 0.0, 1.0)

float upperWick = math.max(high - math.max(open, close), 0.0)
float lowerWick = math.max(math.min(open, close) - low, 0.0)
float upperWickRatio = safeDiv(upperWick, barRange)
float lowerWickRatio = safeDiv(lowerWick, barRange)

bool bullBar = close > open
bool bearBar = close < open

float atr = ta.atr(atrLength)
float safeAtr = math.max(atr, syminfo.mintick)
float atrAverage = ta.sma(atr, normalizeLength)
float atrRatio = clamp(safeDiv(atr, atrAverage), 0.65, 1.60)

float averageRange = ta.sma(barRange, normalizeLength)
float expansion = clamp(safeDiv(barRange, averageRange), 0.0, 3.0)

float fastEMA = ta.ema(close, fastLength)
float slowEMA = ta.ema(close, slowLength)
float phaseLine = ta.hma(hlc3, phaseLength)

float phaseSlope = phaseLine - nz(phaseLine[2], phaseLine)
float phaseSlopeATR = safeDiv(phaseSlope, safeAtr)
float phaseDistance = safeDiv(close - phaseLine, safeAtr)

float momentum = ta.ema(ta.change(close), momentumLength)
float momentumATR = safeDiv(momentum, safeAtr)
float momentumDelta = momentumATR - nz(momentumATR[1], momentumATR)

[plusDI, minusDI, adx] = ta.dmi(14, 14)
float diPressure = safeDiv(plusDI - minusDI, math.max(plusDI + minusDI, 1.0))
float diDelta = diPressure - nz(diPressure[1], diPressure)

int structureState =
     fastEMA > slowEMA and close > phaseLine and phaseSlope > 0.0 ? 1 :
     fastEMA < slowEMA and close < phaseLine and phaseSlope < 0.0 ? -1 :
     0

float wickPressure =
     clamp(
          safeDiv(lowerWick - upperWick, barRange),
          -1.0,
          1.0)

float bullRaw =
     (bullBar ? bodyRatio : 0.0) * 35.0 +
     closePos * 30.0 +
     math.max(wickPressure, 0.0) * 20.0 +
     math.max(expansion - 1.0, 0.0) * 15.0

float bearRaw =
     (bearBar ? bodyRatio : 0.0) * 35.0 +
     (1.0 - closePos) * 30.0 +
     math.max(-wickPressure, 0.0) * 20.0 +
     math.max(expansion - 1.0, 0.0) * 15.0

float pressure =
     ta.ema(
          ta.ema(bullRaw, pressureLength) -
          ta.ema(bearRaw, pressureLength),
          responsive ? 3 : conservative ? 7 : 5)

float pressurePeak = ta.highest(math.abs(pressure), normalizeLength)

float pressureIndex =
     pressurePeak > 0.0 ?
     clamp(pressure / pressurePeak, -1.0, 1.0) :
     0.0

float pressureDelta =
     pressureIndex -
     nz(pressureIndex[1], pressureIndex)

bool volumeAvailable = not na(volume) and volume > 0.0
float averageVolume = ta.sma(volume, volumeLength)

float relativeVolume =
     volumeAvailable and averageVolume > 0.0 ?
     volume / averageVolume :
     1.0

float directionalVolume =
     volumeAvailable ?
     volume * (closePos * 2.0 - 1.0) :
     0.0

float volumeBaseline =
     ta.sma(
          math.abs(directionalVolume),
          volumeLength)

float volumeFlow =
     volumeAvailable and volumeBaseline > 0.0 ?
     clamp(
          ta.ema(directionalVolume, 7) / volumeBaseline,
          -2.0,
          2.0) :
     0.0

float priceProgress =
     safeDiv(
          math.abs(close - close[1]),
          safeAtr)

float effortResult =
     safeDiv(
          relativeVolume,
          math.max(priceProgress, 0.10))

bool bullVolume =
     not useVolume or
     not volumeAvailable or
     (
          relativeVolume >= minimumRelativeVolume and
          volumeFlow > 0.0
     )

bool bearVolume =
     not useVolume or
     not volumeAvailable or
     (
          relativeVolume >= minimumRelativeVolume and
          volumeFlow < 0.0
     )

bool bullEffort =
     not useVolume or
     not volumeAvailable or
     (
          bullBar and
          volumeFlow > 0.0 and
          (
               effortResult <= 3.75 or
               bodyRatio >= 0.42
          )
     )

bool bearEffort =
     not useVolume or
     not volumeAvailable or
     (
          bearBar and
          volumeFlow < 0.0 and
          (
               effortResult <= 3.75 or
               bodyRatio >= 0.42
          )
     )

float priorHigh = ta.highest(high[1], extremeLength)
float priorLow = ta.lowest(low[1], extremeLength)

bool newHigh =
     barstate.isconfirmed and
     not na(priorHigh) and
     high >= priorHigh

bool newLow =
     barstate.isconfirmed and
     not na(priorLow) and
     low <= priorLow

float averageBody = ta.sma(body, responsive ? 3 : conservative ? 6 : 4)

bool bodyShrinking =
     body <
     nz(averageBody[1], body)

bool phaseFading =
     math.abs(phaseSlopeATR) < 0.025 or
     math.abs(phaseSlopeATR) <
     math.abs(nz(phaseSlopeATR[1], phaseSlopeATR))

int topExhaustion =
     (bodyShrinking ? 1 : 0) +
     (phaseFading ? 1 : 0) +
     (momentumDelta < 0.0 ? 1 : 0) +
     (diDelta < 0.0 ? 1 : 0) +
     (upperWickRatio >= 0.25 ? 1 : 0) +
     (adx >= 15.0 and adx <= nz(adx[1], adx) ? 1 : 0)

int bottomExhaustion =
     (bodyShrinking ? 1 : 0) +
     (phaseFading ? 1 : 0) +
     (momentumDelta > 0.0 ? 1 : 0) +
     (diDelta > 0.0 ? 1 : 0) +
     (lowerWickRatio >= 0.25 ? 1 : 0) +
     (adx >= 15.0 and adx <= nz(adx[1], adx) ? 1 : 0)

const int SETUP_NONE = 0
const int SETUP_TOP = -1
const int SETUP_BOTTOM = 1

var int setup = SETUP_NONE
var int setupBar = na
var int setupScore = 0

if barstate.isconfirmed
    if structureState == 1 and newHigh
        setup := SETUP_TOP
        setupBar := bar_index
        setupScore := topExhaustion
    else if structureState == -1 and newLow
        setup := SETUP_BOTTOM
        setupBar := bar_index
        setupScore := bottomExhaustion
    else if setup == SETUP_TOP
        setupScore := math.max(setupScore, topExhaustion)
    else if setup == SETUP_BOTTOM
        setupScore := math.max(setupScore, bottomExhaustion)

if setup != SETUP_NONE and
   not na(setupBar) and
   bar_index - setupBar > setupLife
    setup := SETUP_NONE
    setupBar := na
    setupScore := 0

bool topArmed =
     setup == SETUP_TOP and
     setupScore >= (responsive ? 3 : conservative ? 5 : 4)

bool bottomArmed =
     setup == SETUP_BOTTOM and
     setupScore >= (responsive ? 3 : conservative ? 5 : 4)

float buyEvidence =
     (close > fastEMA ? 1.0 : 0.0) +
     (close > phaseLine ? 1.0 : 0.0) +
     (phaseSlope > 0.0 ? 1.0 : 0.0) +
     (momentumDelta > 0.0 ? 1.0 : 0.0) +
     (diDelta > 0.0 ? 1.0 : 0.0) +
     (pressureIndex > 0.0 ? 1.0 : 0.0) +
     (pressureDelta > 0.0 ? 0.75 : 0.0) +
     (bullVolume ? 0.75 : 0.0) +
     (bullEffort ? 0.75 : 0.0) +
     (bullBar and closePos >= 0.55 ? 0.75 : 0.0)

float saleEvidence =
     (close < fastEMA ? 1.0 : 0.0) +
     (close < phaseLine ? 1.0 : 0.0) +
     (phaseSlope < 0.0 ? 1.0 : 0.0) +
     (momentumDelta < 0.0 ? 1.0 : 0.0) +
     (diDelta < 0.0 ? 1.0 : 0.0) +
     (pressureIndex < 0.0 ? 1.0 : 0.0) +
     (pressureDelta < 0.0 ? 0.75 : 0.0) +
     (bearVolume ? 0.75 : 0.0) +
     (bearEffort ? 0.75 : 0.0) +
     (bearBar and closePos <= 0.45 ? 0.75 : 0.0)

bool trendBuy =
     structureState == 1 and
     phaseDistance >= phaseDistanceRequired and
     buyEvidence >= entryScore and
     buyEvidence > saleEvidence + 1.0

bool trendSale =
     structureState == -1 and
     phaseDistance <= -phaseDistanceRequired and
     saleEvidence >= entryScore and
     saleEvidence > buyEvidence + 1.0

bool reversalBuy =
     bottomArmed and
     bullBar and
     close > fastEMA and
     momentumDelta > 0.0 and
     buyEvidence >= reversalScore

bool reversalSale =
     topArmed and
     bearBar and
     close < fastEMA and
     momentumDelta < 0.0 and
     saleEvidence >= reversalScore

bool rawBuy =
     barstate.isconfirmed and
     (trendBuy or reversalBuy)

bool rawSale =
     barstate.isconfirmed and
     (trendSale or reversalSale)

var int signalState = 0

float switchAdvantage =
     responsive ? 0.50 :
     conservative ? 1.50 :
     1.15

bool finalBuy =
     rawBuy and
     not rawSale and
     signalState != 1 and
     buyEvidence >= saleEvidence + switchAdvantage

bool finalSale =
     rawSale and
     not rawBuy and
     signalState != -1 and
     saleEvidence >= buyEvidence + switchAdvantage

if finalBuy
    signalState := 1
    setup := SETUP_NONE
    setupBar := na
    setupScore := 0
else if finalSale
    signalState := -1
    setup := SETUP_NONE
    setupBar := na
    setupScore := 0

bool isIndex = syminfo.type == "index"
bool isStock =
     syminfo.type == "stock" or
     syminfo.type == "dr" or
     syminfo.type == "fund"
bool isFuture = syminfo.type == "futures"

int lineFast =
     isIndex ? 9 :
     isFuture ? 7 :
     isStock ? 11 :
     10

int lineSlow =
     isIndex ? 21 :
     isFuture ? 17 :
     isStock ? 26 :
     23

int lineSmooth =
     isIndex ? 5 :
     isFuture ? 4 :
     isStock ? 6 :
     5

float pressureFactor =
     isIndex ? 0.72 :
     isFuture ? 0.92 :
     isStock ? 0.80 :
     0.84

float volatilityWeight =
     clamp(
          safeDiv(atrRatio - 0.65, 0.95),
          0.0,
          1.0)

float lineRaw =
     ta.ema(hlc3, slowLength) +
     safeAtr *
     pressureFactor *
     pressureIndex

float lineFastValue = ta.ema(lineRaw, lineFast)
float lineSlowValue = ta.ema(lineRaw, lineSlow)

float lineBlend =
     lineFastValue * (1.0 - volatilityWeight) +
     lineSlowValue * volatilityWeight

float lineStage = ta.ema(lineBlend, lineSmooth)

float structuredTrendline =
     ta.ema(
          2.0 * lineBlend - lineStage,
          lineSmooth)

color lineColor =
     structuredTrendline >= nz(structuredTrendline[2], structuredTrendline) ?
     color.green :
     color.red

plot(
     showTrendline ? structuredTrendline : na,
     "Structured Trendline",
     lineColor,
     2,
     editable = false)

plotshape(
     showSignals and finalBuy,
     "BUY",
     shape.labelup,
     location.belowbar,
     color.green,
     text = "BUY",
     textcolor = color.white,
     size = size.tiny,
     editable = false)

plotshape(
     showSignals and finalSale,
     "SALE",
     shape.labeldown,
     location.abovebar,
     color.red,
     text = "SALE",
     textcolor = color.white,
     size = size.tiny,
     editable = false)

alertcondition(
     finalBuy,
     "SBP Structured Trend Indicator - BUY",
     "SBP Structured Trend Indicator: confirmed BUY on {{ticker}} at {{close}} | {{interval}}.")

alertcondition(
     finalSale,
     "SBP Structured Trend Indicator - SALE",
     "SBP Structured Trend Indicator: confirmed SALE on {{ticker}} at {{close}} | {{interval}}.")
````
