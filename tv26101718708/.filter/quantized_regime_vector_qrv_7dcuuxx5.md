# Quantized Regime Vector (QRV)

- url: https://www.tradingview.com/script/7dcUuxX5-Quantized-Regime-Vector-QRV/
- type: indicator
- pine_id: PUB;c3ffd883450a4fe1a5b85e9e5c177832
- version: 4.0

## Description

# Quantized Regime Vector (QRV)

## Professional Market Regime & Directional Confluence Overlay

Quantized Regime Vector (QRV) is a multi-factor empirical state-classification engine designed to filter high-frequency market noise into a structured, deterministic directional confluence matrix.

The script systematically evaluates trend structure, higher-timeframe alignment, adaptive moving average behavior, relative volume expansion, volatility dynamics, momentum exhaustion, confirmed divergence, and wick-adjusted order-flow proxy bias. These independent inputs are mapped into an objective, quantitative scoring framework that establishes active market regime classification and directional conviction in real time.

QRV is not a predictive forecasting model. It functions as an objective decision-support framework designed to systematically mitigate adverse selection during low-efficiency market regimes, helping operators evaluate when edge is mathematically present and when conditions are too noisy for execution.

The purpose of QRV is to reduce low-quality signals, organize continuous market context into discrete states, and display aggregate directional strength directly on the interface.

---

## Why “Quantized Regime Vector”?

* **Quantized:** QRV takes continuous, chaotic market inputs and maps them into a structured, finite confluence score. Instead of treating every signal equally, the engine calculates an aggregate value to evaluate whether independent conditions are aligned strongly enough to clear a strict execution floor.
* **Regime:** The system classifies the underlying structural environment via localized trend alignment, multi-timeframe correlation, volatility state tracking, and algorithmic alpha grading.
* **Vector:** QRV evaluates both direction and magnitude. The model calculates long-side and short-side scores completely independently, outputting the active side alongside the raw mathematical strength of the current setup.

---

## Core Algorithmic Components

### 1. Trend Structure

QRV evaluates localized price action in relation to both a mid-term structural moving average and a long-term trend average. This isolates the baseline market state into clear bullish, bearish, or neutral structural regimes.

### 2. Higher-Timeframe Alignment

The framework includes an institutional multi-timeframe trend filter that utilizes **only the previously completed higher-timeframe bar** to ensure zero real-time repainting or forward-looking bias.

* **Timeframe Inversion Protection:** If the selected higher timeframe is less than or equal to the current chart timeframe, the system triggers a `CHECK TF` warning on the dashboard and completely blocks the higher-timeframe contribution from the scoring model to preserve data integrity.

### 3. Adaptive Moving Average Behavior

The engine incorporates a Kaufman Adaptive Moving Average (KAMA) driven by a localized Efficiency Ratio. By adjusting its internal smoothing factor based on trend efficiency, it reduces lag during true expansion legs and flattens out during mean-reverting chop, acting as a dynamic structural barrier for reclaim and breakdown validation.

### 4. Statistical Relative Volume Expansion

Current volume is normalized against historical lookback distributions using a Gaussian Z-score framework:

$$Z = \frac{V - \mu}{\sigma}$$

Elevated Z-scores validate baseline participation necessary to sustain structural breakouts. This metric does not attempt to track specific participants or imply unprovable order-flow mechanics; it is a strict statistical measurement of volume expansion relative to recent historical norms.

### 5. Volatility Expansion Gate

Directional triggers are volatility-gated, requiring localized Average True Range (ATR) expansion to validate execution momentum and filter out mean-reverting noise. If range expansion fails to clear the volatility gate, execution parameters remain locked.

### 6. Momentum Exhaustion Tracking

The system cross-references localized RSI positioning with MACD histogram peaks to flag potential momentum exhaustion points. These conditions indicate exhaustive retail chasing into liquidity pools and should be treated as structural context rather than absolute reversal signals.

### 7. Confirmed Pivot Divergence

The engine includes a non-backplotting divergence system driven by structural pivot points. Divergence labels are printed strictly on the live bar where the pivot confirmation becomes statistically knowable in real time, eliminating retrospective signal placement.

### 8. Wick-Adjusted Flow Bias

A localized volume pressure proxy calculates intra-bar delta based on wick adjustments, categorizing near-term order-flow accumulation or distribution states.

---

## System Risk & Filtration Defaults

The default parameters are intentionally restrictive, prioritizing high-selectivity alignment over high-frequency trading in noisy conditions.

```text
======================================================================
QUANTIZED REGIME VECTOR (QRV) SYSTEM DEFAULTS
======================================================================
• Score Activation Floor      : 82 / 110 Total Points
• Volatility Gate Limit       : 1.85 × ATR (Noise Isolation)
• Baseline Volume Alpha       : ≥ 1.50σ Z-Score
• Major Volume Expansion      : ≥ 2.75σ Z-Score
• Signal Cooldown Array       : 20 Bars (Cluster Prevention)
• Real-Time Protection        : Confirm-on-Close [Enabled]
======================================================================

```

### The QRV Score Engine Matrix

The directional scoring model aggregates weighted confirmations across all core components to assign an objective alpha grade to the live market state:

* **Grade A ($\ge$ 85):** Maximum-probability structural and volume confluence.
* **Grade B ($\ge$ 75):** Strong directional continuation context.
* **Grade C ($\ge$ 65):** Developing structural context.
* **Grade F (< 65):** Insufficient confluence; execution restricted.

---

## The Visual Interface Architecture

### Candle Color System

* **Gold Candle:** High-conviction long execution trigger occurring simultaneous with major relative volume expansion ($Z \ge 2.75$).
* **Crimson Candle:** High-conviction short execution trigger occurring simultaneous with major relative volume expansion ($Z \ge 2.75$).
* **Lime Candle:** Standard long execution trigger meeting all baseline trend, adaptive MA, volume, volatility, and scoring floors.
* **Magenta Candle:** Standard short execution trigger meeting all baseline trend, adaptive MA, volume, volatility, and scoring floors.
* **White Candle:** Isolated Major Relative Volume Expansion ($Z \ge 2.75$). Indicates substantial institutional participation block-clearing or absorption without firing a directional entry signal.
* **Orange Candle:** Momentum exhaustion warning (potential fading structure or near-term reversal context).
* **Dark Green Candle:** Strong bullish structural baseline.
* **Dark Purple Candle:** Strong bearish structural baseline.
* **Gray Candle:** Neutral, compressed, or inactive market condition.

### Telemetry Dashboard

The real-time heads-up display reports live engine metadata including:

* **Entropy State:** `EXPANDING`, `CONTRACTING`, or `TRANSITION` volatility behavior.
* **Bias State:** Real-time accumulation vs. distribution proxy tracking.
* **Command State:** Operational mode tracking (`FIRE`, `STALKING...`, or `SCANNING...`).
* **Bi-Directional Scores:** Independent real-time long and short point values.
* **Core System Metrics:** Volume Z-score tracking, HTF confirmation, and divergence status.

---

## Operational Protocol: How to Use QRV

### For Long Setups

1. Ensure the baseline trend structure and higher-timeframe status report bullish alignment.
2. Monitor the dashboard for an improving, accelerating long score vector.
3. Prioritize Grade-A executions where standard long triggers overlap with dynamic volatility expansion.
4. Utilize localized momentum exhaustion and divergence labels as structural exit or profit-taking context, rather than raw entry signals.

### For Short Setups

1. Ensure the baseline trend structure and higher-timeframe status report bearish alignment.
2. Monitor the dashboard for an improving, accelerating short score vector.
3. Prioritize Grade-A executions where standard short triggers overlap with dynamic volatility expansion.
4. Utilize localized momentum exhaustion and divergence labels as structural exit or profit-taking context, rather than raw entry signals.

### Timeframe Configuration Examples

* **Scalping/Intraday:** 5-Minute Chart with a 30-Minute or 1-Hour HTF Input.
* **Day Trading/Breakouts:** 15-Minute Chart with a 1-Hour or 4-Hour HTF Input.
* **Swing Trading:** 1-Hour or 4-Hour Chart with a Daily HTF Input.

---

## Important Limitations & System Restrictions

* **No Predictive Claims:** QRV evaluates current mathematical alignment based on historical lookback arrays. It does not predict future structural direction or guarantee profitable outcomes.
* **Context vs. Proof:** Statistical relative volume expansion indicates an increase in participation velocity relative to recent norms. It cannot identify specific entity intent or guarantee institutional follow-through.
* **Macro/Event Exclusion:** The engine operates strictly on technical metadata. It cannot account for, protect against, or evaluate incoming economic indicators, earnings releases, central bank decisions, or sudden exogenous liquidity shocks.
* **Chop Regimes:** While the volatility gate and signal cooldown arrays are engineered to systematically mitigate adverse selection, extended low-volume, mean-reverting consolidations can result in performance decay.

---

## Risk Disclaimer

Trading financial instruments, including index futures, commodities, equities, and derivatives, involves a substantial risk of capital loss and is not suitable for every investor. No automated scoring matrix, indicator, or technical framework can eliminate market risk or ensure capital preservation. QRV is provided strictly as an analytical decision-support tool. It should be paired with independent risk management, strict position sizing protocols, robust historical backtesting, and discretionary trader judgment. This material does not constitute financial, legal, or investment advice. Single-point failure mitigation and execution validation remain the sole responsibility of the operator.

## Source Code

````pine
//@version=6
indicator("Quantized Regime Vector v2.6.2", shorttitle="QRV v2.6.2", overlay=true, max_labels_count=500)
i_releaseMarker = input.bool(false, "Release Marker v2.6.2", group="Release Notes")
// ==================================================================
// QUANTIZED REGIME VECTOR - v2.6.1 DEPLOYMENT BUILD
// ------------------------------------------------------------------
// Static QA hardening:
//   * Uses Pine v6.
//   * Fixes incomplete bearDiv label block / line-209 style syntax error.
//   * Keeps color namespace valid and removes duplicated/orphaned candleColor lines.
//   * Calls request.security() globally, then gates HTF contribution afterward.
//   * Actively blocks HTF contribution when timeframe inversion is detected.
//   * Removes unsafe dynamic RSI history indexing from divergence logic.
//   * Divergence labels print on confirmation bar only, not back-plotted.
//   * Uses major relative-volume terminology.
//   * Keeps confirm-on-close protection enabled by default.
// ==================================================================

// ==================================================================
// SYSTEM INPUTS & PARAMETERS
// ==================================================================
grpTrend  = "1. Core Trend & Structure Architecture"
i_smaFast = input.int(50, "Fast Structural SMA", minval=1, group=grpTrend)
i_smaSlow = input.int(200, "Slow Structural SMA", minval=1, group=grpTrend)
i_kamaLen = input.int(10, "KAMA Efficiency Length", minval=2, group=grpTrend)

grpHtf    = "2. Multi-Timeframe Filter"
i_useHtf  = input.bool(true, "Require HTF Alignment?", tooltip="When enabled, directional scores and triggers require alignment with the selected higher timeframe. If the selected timeframe is invalid, HTF contribution is blocked.", group=grpHtf)
i_htfTime = input.timeframe("60", "Higher Timeframe (HTF)", group=grpHtf)

grpVol       = "3. Statistical Z-Score Volume Engine"
i_volLen     = input.int(20, "Volume Lookback Baseline", minval=10, group=grpVol)
i_sigZ       = input.float(1.50, "Signal Volume Z-Score Min", minval=0.1, step=0.05, group=grpVol)
i_majorVolZ  = input.float(2.75, "Major Relative Volume Expansion Z-Score", minval=1.0, step=0.05, tooltip="Statistical threshold for major relative volume expansion.", group=grpVol)

grpGate   = "4. Volatility Gating & Entropy Engine"
i_atrLen  = input.int(14, "ATR Volatility Length", minval=1, group=grpGate)
i_atrMult = input.float(1.85, "Volatility Gate Floor (ATR Mult)", minval=0.5, step=0.05, group=grpGate)

grpRisk     = "5. System Risk & Cooldown"
i_cooldown  = input.int(20, "Signal Cooldown (Bars)", minval=1, maxval=300, group=grpRisk)
i_confirm   = input.bool(true, "Confirm-on-Close (Real-Time Protection)", tooltip="When enabled, triggers, alerts, and labels confirm only after the candle closes.", group=grpRisk)
i_minScore  = input.int(82, "Minimum Trigger Score", minval=0, maxval=110, group=grpRisk)

grpScore = "6. QRV Score Engine"
i_showScore = input.bool(true, "Show QRV Score Matrix", group=grpScore)
i_aGrade    = input.int(85, "A Grade Threshold", minval=1, maxval=110, group=grpScore)
i_bGrade    = input.int(75, "B Grade Threshold", minval=1, maxval=110, group=grpScore)
i_cGrade    = input.int(65, "C Grade Threshold", minval=1, maxval=110, group=grpScore)

grpUi       = "7. Interface & Telemetry Dashboard"
i_dashColor = input.color(color.new(color.black, 15), "Dashboard Background", group=grpUi)
i_showMA    = input.bool(true, "Show Structural Moving Averages", group=grpUi)
i_showDiv   = input.bool(true, "Show Confirmed Divergence Labels", group=grpUi)
i_showExh   = input.bool(true, "Show Exhaustion Labels", group=grpUi)

// ==================================================================
// REAL-TIME SAFETY GATE
// ==================================================================
barConfirmed = i_confirm ? barstate.isconfirmed : true

// ==================================================================
// STATISTICAL VOLUME Z-SCORE ENGINE
// ==================================================================
volMean = ta.sma(volume, i_volLen)
volStd  = ta.stdev(volume, i_volLen)
volZ    = not na(volStd) and volStd > 0 and not na(volMean) ? (volume - volMean) / volStd : 0.0

sigVol      = volZ >= i_sigZ
majorVolExp = volZ >= i_majorVolZ

// ==================================================================
// VOLATILITY RANGE EXPANSION GATE & ENTROPY STATE
// ==================================================================
atrVal    = ta.atr(i_atrLen)
trueRange = ta.tr(true)
highRange = not na(atrVal) and not na(trueRange) and trueRange >= (atrVal * i_atrMult)

atrMa      = ta.sma(atrVal, 20)
entropyStr = not na(atrMa) and atrVal > atrMa * 1.05 ? "EXPANDING" : not na(atrMa) and atrVal < atrMa * 0.95 ? "CONTRACTING" : "TRANSITION"
entropyCol = entropyStr == "EXPANDING" ? color.new(color.orange, 20) : entropyStr == "CONTRACTING" ? color.new(color.blue, 40) : color.new(color.yellow, 30)

// ==================================================================
// KAUFMAN ADAPTIVE MOVING AVERAGE ENGINE
// ==================================================================
dirMove   = not na(close[i_kamaLen]) ? math.abs(close - close[i_kamaLen]) : 0.0
totalMove = nz(math.sum(nz(ta.tr(true), 0.0), i_kamaLen), 0.0)
effRatio  = totalMove > 0 ? dirMove / totalMove : 0.0

var float kamaLine = na
fastSC = 2.0 / (2.0 + 1.0)
slowSC = 2.0 / (30.0 + 1.0)
sc     = math.pow((effRatio * (fastSC - slowSC)) + slowSC, 2.0)
kamaLine := na(kamaLine[1]) ? close : kamaLine[1] + sc * (close - kamaLine[1])

// ==================================================================
// LOCAL STRUCTURAL TREND ENGINE
// ==================================================================
sma50  = ta.sma(close, i_smaFast)
sma200 = ta.sma(close, i_smaSlow)

trendBullCore = not na(sma50) and not na(sma200) and close > sma50 and sma50 > sma200
trendBearCore = not na(sma50) and not na(sma200) and close < sma50 and sma50 < sma200

kamaBull = not na(kamaLine) and close > kamaLine
kamaBear = not na(kamaLine) and close < kamaLine

// ==================================================================
// WICK-ADJUSTED DIRECTIONAL BIAS PROXY
// ==================================================================
candleBody = math.abs(close - open)
upperWick  = high - math.max(open, close)
lowerWick  = math.min(open, close) - low

buyForce   = close > open ? candleBody + lowerWick : lowerWick
sellForce  = close < open ? candleBody + upperWick : upperWick

biasBull = buyForce > sellForce
biasBear = sellForce > buyForce
biasStr  = biasBull ? "ACCUMULATION" : biasBear ? "DISTRIBUTION" : "NEUTRAL"

// ==================================================================
// MULTI-TIMEFRAME INTEGRATION & TIMEFRAME INVERSION PROTECTION
// ==================================================================
chartTfSeconds = timeframe.in_seconds(timeframe.period)
inputTfSeconds = timeframe.in_seconds(i_htfTime)

tfInversionError = i_useHtf and not na(chartTfSeconds) and not na(inputTfSeconds) and chartTfSeconds >= inputTfSeconds

[htfCloseRaw, htfSmaRaw] = request.security(
     syminfo.tickerid,
     i_htfTime,
     [close[1], ta.sma(close, i_smaFast)[1]],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on
)

htfBullRaw = not na(htfCloseRaw) and not na(htfSmaRaw) and htfCloseRaw > htfSmaRaw
htfBearRaw = not na(htfCloseRaw) and not na(htfSmaRaw) and htfCloseRaw < htfSmaRaw

htfOkLong  = not i_useHtf or (not tfInversionError and htfBullRaw)
htfOkShort = not i_useHtf or (not tfInversionError and htfBearRaw)

// ==================================================================
// MOMENTUM EXHAUSTION FRAMEWORK
// ==================================================================
rsiVal = ta.rsi(close, 14)
[_, _, macdHist] = ta.macd(close, 12, 26, 9)

exhaustionUpRaw = not na(macdHist[1]) and rsiVal > 70 and macdHist < macdHist[1] and macdHist[1] > 0
exhaustionDnRaw = not na(macdHist[1]) and rsiVal < 30 and macdHist > macdHist[1] and macdHist[1] < 0

exhaustionUp = barConfirmed and exhaustionUpRaw
exhaustionDn = barConfirmed and exhaustionDnRaw

// ==================================================================
// NON-REPAINTING PIVOT DIVERGENCE TRACKER - CONFIRMATION BAR ONLY
// ==================================================================
pHi = ta.pivothigh(high, 4, 2)
pLo = ta.pivotlow(low, 4, 2)

var float lastPH = na
var float lastPH_RSI = na
var float lastPL = na
var float lastPL_RSI = na

bullDivRaw = false
bearDivRaw = false

if barConfirmed and not na(pHi)
    pivotHighRsi = rsiVal[2]
    if not na(lastPH) and not na(lastPH_RSI) and not na(pivotHighRsi) and pHi > lastPH and pivotHighRsi < lastPH_RSI
        bearDivRaw := true
    lastPH := pHi
    lastPH_RSI := pivotHighRsi

if barConfirmed and not na(pLo)
    pivotLowRsi = rsiVal[2]
    if not na(lastPL) and not na(lastPL_RSI) and not na(pivotLowRsi) and pLo < lastPL and pivotLowRsi > lastPL_RSI
        bullDivRaw := true
    lastPL := pLo
    lastPL_RSI := pivotLowRsi

bullDiv = barConfirmed and bullDivRaw
bearDiv = barConfirmed and bearDivRaw

// ==================================================================
// QRV SCORING MATRIX - 110 POINT MAXIMUM
// ==================================================================
volScore        = sigVol ? 12 : 0
majorVolScore   = majorVolExp ? 8 : 0
gateScore       = highRange ? 15 : 0
candleBull      = close > open
candleBear      = close < open

longScore =
     (trendBullCore ? 20 : 0) +
     (htfOkLong ? 20 : 0) +
     volScore +
     majorVolScore +
     gateScore +
     (kamaBull ? 15 : 0) +
     (biasBull ? 10 : 0) +
     (candleBull ? 10 : 0)

shortScore =
     (trendBearCore ? 20 : 0) +
     (htfOkShort ? 20 : 0) +
     volScore +
     majorVolScore +
     gateScore +
     (kamaBear ? 15 : 0) +
     (biasBear ? 10 : 0) +
     (candleBear ? 10 : 0)

activeSide  = longScore > shortScore ? "LONG" : shortScore > longScore ? "SHORT" : "NEUTRAL"
activeScore = longScore >= shortScore ? longScore : shortScore

activeGrade = "F"
if activeScore >= i_aGrade
    activeGrade := "A"
else if activeScore >= i_bGrade
    activeGrade := "B"
else if activeScore >= i_cGrade
    activeGrade := "C"

scoreCol = activeGrade == "A" ? color.yellow : activeGrade == "B" ? color.orange : activeGrade == "C" ? color.white : color.new(color.gray, 20)

// ==================================================================
// EXECUTION ENGINE & SIGNAL FILTRATION
// ==================================================================
var int lastSignalBar = na
cooldownActive = not na(lastSignalBar) and (bar_index - lastSignalBar) < i_cooldown

rawLongTrigger  = activeSide == "LONG" and activeScore >= i_minScore and htfOkLong and highRange and sigVol and kamaBull and trendBullCore and not cooldownActive
rawShortTrigger = activeSide == "SHORT" and activeScore >= i_minScore and htfOkShort and highRange and sigVol and kamaBear and trendBearCore and not cooldownActive

longTrigger  = barConfirmed and rawLongTrigger
shortTrigger = barConfirmed and rawShortTrigger

if longTrigger or shortTrigger
    lastSignalBar := bar_index

// ==================================================================
// VISUAL INTERFACE ARCHITECTURE - CANDLE COLORING
// ==================================================================
var color candleColor = color.gray

if longTrigger and majorVolExp
    candleColor := color.orange
else if shortTrigger and majorVolExp
    candleColor := color.maroon
else if longTrigger
    candleColor := color.lime
else if shortTrigger
    candleColor := color.fuchsia
else if majorVolExp
    candleColor := color.white
else if exhaustionUp or exhaustionDn
    candleColor := color.purple
else if trendBullCore
    candleColor := color.green
else if trendBearCore
    candleColor := color.teal
else
    candleColor := color.gray

plotcandle(open, high, low, close, title="QRV Dynamic Coloring", color=candleColor, wickcolor=candleColor, bordercolor=candleColor)

// ==================================================================
// STRUCTURAL LAYERS
// ==================================================================
plot(i_showMA ? sma50 : na, "Fast Structural SMA", color=color.new(color.blue, 30), linewidth=2)
plot(i_showMA ? sma200 : na, "Slow Structural SMA", color=color.new(color.white, 20), linewidth=3)
plot(i_showMA ? kamaLine : na, "KAMA Adaptive Baseline", color=color.new(color.yellow, 10), linewidth=2)

// ==================================================================
// EXECUTION EVENT MARKERS
// ==================================================================
if longTrigger
    label.new(bar_index, low, text="QRV LONG\n" + str.tostring(longScore) + " / 110", color=color.lime, textcolor=color.black, style=label.style_label_up)

if shortTrigger
    label.new(bar_index, high, text="QRV SHORT\n" + str.tostring(shortScore) + " / 110", color=color.fuchsia, textcolor=color.white, style=label.style_label_down)

if i_showDiv and bullDiv
    label.new(bar_index, low, text="BULL DIV CONF", color=color.aqua, textcolor=color.black, style=label.style_label_up)

if i_showDiv and bearDiv
    label.new(bar_index, high, text="BEAR DIV CONF", color=color.red, textcolor=color.white, style=label.style_label_down)

if i_showExh and exhaustionUp
    label.new(bar_index, high, text="EXHAUSTION UP", color=color.purple, textcolor=color.white, style=label.style_label_down)

if i_showExh and exhaustionDn
    label.new(bar_index, low, text="EXHAUSTION DN", color=color.purple, textcolor=color.white, style=label.style_label_up)

// ==================================================================
// TELEMETRY HUD DASHBOARD DISPLAY
// ==================================================================
var table qrvDash = table.new(position.top_right, 10, 2, bgcolor=color.new(color.black, 100), border_width=1)

commandStr = cooldownActive ? "STALKING..." : longTrigger ? "FIRE LONG" : shortTrigger ? "FIRE SHORT" : (longScore >= i_minScore or shortScore >= i_minScore) ? "ARMED" : "SCANNING..."
htfStr     = not i_useHtf ? "OFF" : tfInversionError ? "CHECK TF" : htfOkLong ? "BULL ALIGNED" : htfOkShort ? "BEAR ALIGNED" : "NO ALIGNMENT"
scoreText  = i_showScore ? (" QRV: " + activeSide + " [" + activeGrade + "] ") : " QRV: DISABLED "

if barstate.islast and i_showScore
    table.cell(qrvDash, 0, 0, "ENTROPY REGIME", text_color=color.gray, text_size=size.small, bgcolor=i_dashColor)
    table.cell(qrvDash, 1, 0, "BIAS PROXY", text_color=color.gray, text_size=size.small, bgcolor=i_dashColor)
    table.cell(qrvDash, 2, 0, "HTF ALIGNMENT", text_color=color.gray, text_size=size.small, bgcolor=i_dashColor)
    table.cell(qrvDash, 3, 0, "COMMAND ARRAY", text_color=color.gray, text_size=size.small, bgcolor=i_dashColor)
    table.cell(qrvDash, 4, 0, "CORE VECTOR", text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 30))
    table.cell(qrvDash, 5, 0, "LONG VECTOR", text_color=color.gray, text_size=size.small, bgcolor=i_dashColor)
    table.cell(qrvDash, 6, 0, "SHORT VECTOR", text_color=color.gray, text_size=size.small, bgcolor=i_dashColor)
    table.cell(qrvDash, 7, 0, "VOLUME Z", text_color=color.gray, text_size=size.small, bgcolor=i_dashColor)
    table.cell(qrvDash, 8, 0, "VOL GATE", text_color=color.gray, text_size=size.small, bgcolor=i_dashColor)
    table.cell(qrvDash, 9, 0, "COOLDOWN", text_color=color.gray, text_size=size.small, bgcolor=i_dashColor)

    table.cell(qrvDash, 0, 1, entropyStr, text_color=color.white, text_size=size.normal, bgcolor=entropyCol)
    table.cell(qrvDash, 1, 1, biasStr, text_color=color.black, text_size=size.normal, bgcolor=biasBull ? color.lime : biasBear ? color.red : color.gray)
    table.cell(qrvDash, 2, 1, htfStr, text_color=color.white, text_size=size.normal, bgcolor=tfInversionError ? color.purple : htfOkLong ? color.green : htfOkShort ? color.maroon : color.gray)
    table.cell(qrvDash, 3, 1, commandStr, text_color=color.black, text_size=size.normal, bgcolor=longTrigger or shortTrigger ? color.orange : cooldownActive ? color.yellow : color.gray)
    table.cell(qrvDash, 4, 1, scoreText, text_color=color.black, text_size=size.normal, bgcolor=scoreCol)
    table.cell(qrvDash, 5, 1, str.tostring(longScore) + " / 110", text_color=color.white, text_size=size.normal, bgcolor=longScore >= i_minScore ? color.green : i_dashColor)
    table.cell(qrvDash, 6, 1, str.tostring(shortScore) + " / 110", text_color=color.white, text_size=size.normal, bgcolor=shortScore >= i_minScore ? color.maroon : i_dashColor)
    table.cell(qrvDash, 7, 1, str.tostring(volZ, "#.##") + " σ", text_color=color.black, text_size=size.normal, bgcolor=majorVolExp ? color.orange : sigVol ? color.yellow : color.white)
    table.cell(qrvDash, 8, 1, highRange ? "OPEN" : "CLOSED", text_color=color.black, text_size=size.normal, bgcolor=highRange ? color.lime : color.gray)
    table.cell(qrvDash, 9, 1, cooldownActive ? "ACTIVE" : "CLEAR", text_color=color.black, text_size=size.normal, bgcolor=cooldownActive ? color.yellow : color.lime)

// ==================================================================
// SYSTEM ROUTING ALERTS
// ==================================================================
alertcondition(longTrigger, title="QRV LONG Trigger", message="QRV - Long confluence trigger confirmed | {{ticker}} @ {{close}}")
alertcondition(shortTrigger, title="QRV SHORT Trigger", message="QRV - Short confluence trigger confirmed | {{ticker}} @ {{close}}")
alertcondition(barConfirmed and majorVolExp, title="QRV Major Relative Volume Expansion", message="QRV - Major relative volume expansion detected | {{ticker}}")
alertcondition(bullDiv, title="QRV Bullish Divergence Confirmed", message="QRV - Pivot-confirmed bullish divergence detected | {{ticker}}")
alertcondition(bearDiv, title="QRV Bearish Divergence Confirmed", message="QRV - Pivot-confirmed bearish divergence detected | {{ticker}}")
alertcondition(exhaustionUp, title="QRV Upside Exhaustion Context", message="QRV - Upside exhaustion context detected | {{ticker}}")
alertcondition(exhaustionDn, title="QRV Downside Exhaustion Context", message="QRV - Downside exhaustion context detected | {{ticker}}")
````
