# Markov Regime Engine [Balanced Equity ETF]

- url: https://www.tradingview.com/script/ksCn74zt/
- type: indicator
- pine_id: PUB;1a194b451983425290e2369bdd501297
- version: 3.0

## Description

═════════════════════════════════════
📊 MARKOV REGIME ENGINE — EQUITY EDITION
═════════════════════════════════════
🧠 OVERVIEW

Markov Regime Engine is a probabilistic market regime detector designed for stocks and ETFs, optimized for swing trading (4H / Daily).

It identifies market conditions as:

• 🟢 Risk-On (Bull Regime)
• ⚪ Transition (Neutral / Uncertain)
• 🔴 Risk-Off (Bear / Defensive Regime)

The indicator is built on a pseudo Hidden Markov Model (HMM) framework combining:
trend, momentum, volatility, and market structure.

It does NOT predict price.
It detects market state persistence and regime shifts.

═════════════════════════════════════
⚙️ CORE LOGIC
═════════════════════════════════════

The model constructs a Composite Market Score:

✔ Trend strength (EMA structure + slope)
✔ Momentum persistence (ROC + smoothed returns)
✔ Volatility regime (ATR expansion)
✔ Market efficiency (Kaufman Efficiency Ratio)

Resulting score is normalized:

→ Range: -1 (bear pressure) to +1 (bull pressure)

═════════════════════════════════════
📈 REGIME CLASSIFICATION
═════════════════════════════════════

The score is transformed into probabilistic states:

🟢 RISK-ON
Strong trend alignment
Positive momentum persistence
Stable volatility regime

→ Long bias environment

⚪ TRANSITION
Mixed signals
Weak trend structure
Unstable momentum

→ No clear edge / reduced exposure

🔴 RISK-OFF
Breakdown of trend structure
Negative momentum persistence
Volatility expansion

→ Defensive / exit long exposure

═════════════════════════════════════
🔁 MARKOV PERSISTENCE MODEL
═════════════════════════════════════

Instead of reacting to single candles, the indicator uses a:

👉 Markov Transition Matrix

This introduces regime inertia:

• Bull markets tend to persist
• Bear markets persist during stress phases
• Transition states act as buffers

This reduces:
✔ false flips
✔ noise sensitivity
✔ overtrading

═════════════════════════════════════
🧮 PROBABILISTIC ENGINE
═════════════════════════════════════

The system outputs:

• P(Risk-On)
• P(Transition)
• P(Risk-Off)
• Confidence Score

Regimes are only confirmed when:

✔ Probability > threshold
✔ Persistence over multiple bars

This creates hysteresis-based filtering.

═════════════════════════════════════
🎯 VISUAL OUTPUT
═════════════════════════════════════
Background Color

🟢 Green → Risk-On
⚪ Gray → Transition
🔴 Red → Risk-Off

Overlay Elements

• EMA 50 (trend structure)
• EMA 200 (macro trend filter)
• Regime change labels

Probability Panel

Displays live:

• Risk-On %
• Transition %
• Risk-Off %
• Confidence level

═════════════════════════════════════
📊 STRATEGIC USE CASES
═════════════════════════════════════

Best suited for:

✔ ETF trend following
✔ Equity swing trading
✔ Portfolio regime filtering
✔ Macro risk allocation overlay

Examples:

• SPY
• QQQ
• XLK
• Large-cap equities

═════════════════════════════════════
⚠️ IMPORTANT NOTES
═════════════════════════════════════

• Not a predictive indicator
• Not designed for scalping
• Does NOT generate buy/sell signals directly
• Works best as a regime filter for other strategies

═════════════════════════════════════
🧠 QUANT INSIGHT
═════════════════════════════════════

Unlike standard indicators, this model:

• Uses multi-factor state estimation
• Applies Markov persistence smoothing
• Filters noise via probabilistic hysteresis
• Focuses on regime stability, not price prediction

Core philosophy:

Markets move in regimes, not in signals.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vittorio_pavesi
// Thanks to Nick_Maudit cor support

//@version=6
indicator("Markov Regime Engine", overlay=true, max_lines_count = 50, max_labels_count=500)

// ===================== MINIMAL INPUTS =====================
zWin       = input.int(252, "Z-score window (bars)", minval = 30)
useRolling = input.bool(false, "Use rolling-window empirical A")
showLL     = input.bool(false, "Plot running log-likelihood")

// ===================== CONSTANTS =====================
emaFastLen = 50
emaSlowLen = 200
rocLen     = 20
atrLen     = 14
erLen      = 20
slopeLen   = 10

wTrend = 0.35
wMomo  = 0.25
wVol   = 0.20
wStruct= 0.20

mu_bull  = 1.0
sg_bull  = 0.7
mu_trans = 0.0
sg_trans = 0.9
mu_bear  = -1.0
sg_bear  = 1.1

a_BB = 0.94
a_BT = 0.05
a_BR = 0.01
a_TB = 0.20
a_TT = 0.60
a_TR = 0.20
a_RB = 0.01
a_RT = 0.07
a_RR = 0.92

rollWin = 252
confTh  = 0.60

// Visuals
showBg     = true
showEMAs   = true
showLabels = true

bullColor  = color.green
transColor = color.yellow
bearColor  = color.red
bgTransp   = 90

// ===================== FUNCTIONS =====================
logsumexp3(float a, float b, float c) =>
    float m = math.max(math.max(a, b), c)
    float s = math.exp(a - m) + math.exp(b - m) + math.exp(c - m)
    m + math.log(s)

gaussianLogPdf(float o, float mu, float sigma) =>
    float s = math.max(sigma, 1e-8)
    float z = (o - mu) / s
    -0.5 * math.log(2.0 * math.pi) - math.log(s) - 0.5 * z * z

stationary(matrix<float> A) =>
    array<float> v = array.from(1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0)
    for i_iter = 0 to 200
        float v0a = matrix.get(A, 0, 0) * array.get(v, 0)
        float v0b = matrix.get(A, 1, 0) * array.get(v, 1)
        float v0c = matrix.get(A, 2, 0) * array.get(v, 2)
        float v0  = v0a + v0b + v0c
        float v1a = matrix.get(A, 0, 1) * array.get(v, 0)
        float v1b = matrix.get(A, 1, 1) * array.get(v, 1)
        float v1c = matrix.get(A, 2, 1) * array.get(v, 2)
        float v1  = v1a + v1b + v1c
        float v2a = matrix.get(A, 0, 2) * array.get(v, 0)
        float v2b = matrix.get(A, 1, 2) * array.get(v, 1)
        float v2c = matrix.get(A, 2, 2) * array.get(v, 2)
        float v2  = v2a + v2b + v2c
        float ssum = v0 + v1 + v2
        if ssum > 0
            array.set(v, 0, v0 / ssum)
            array.set(v, 1, v1 / ssum)
            array.set(v, 2, v2 / ssum)
    v

normalizeRows(matrix<float> A) =>
    for i = 0 to 2
        float s = matrix.get(A, i, 0) + matrix.get(A, i, 1) + matrix.get(A, i, 2)
        if s > 0
            matrix.set(A, i, 0, matrix.get(A, i, 0) / s)
            matrix.set(A, i, 1, matrix.get(A, i, 1) / s)
            matrix.set(A, i, 2, matrix.get(A, i, 2) / s)
        else
            matrix.set(A, i, 0, 1.0 / 3.0)
            matrix.set(A, i, 1, 1.0 / 3.0)
            matrix.set(A, i, 2, 1.0 / 3.0)

// ===================== COMPUTATION =====================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

trendSpread = (emaFast - emaSlow) / emaSlow
emaSlope    = (emaFast - emaFast[slopeLen]) / (emaFast[slopeLen] * slopeLen)
distFromEma = (close - emaSlow) / emaSlow

trendRaw =
 0.5*math.sign(trendSpread)*math.min(math.abs(trendSpread)/0.05,3)+
 0.3*math.sign(emaSlope)*math.min(math.abs(emaSlope)/0.002,3)+
 0.2*math.sign(distFromEma)*math.min(math.abs(distFromEma)/0.05,3)

roc = ta.roc(close, rocLen)/100.
logRet = math.log(close / nz(close[1], close))
persLogRet = ta.sma(logRet, rocLen) * math.sqrt(rocLen)

momoRaw =
 0.6*math.sign(roc)*math.min(math.abs(roc)/0.05,3)+
 0.4*math.sign(persLogRet)*math.min(math.abs(persLogRet)/0.05,3)

atr = ta.atr(atrLen)
atrLong = ta.sma(atr, math.max(atrLen*5,50))
volRaw = -math.min((atr/atrLong-1.)/0.5,3)

priceChg = math.abs(close - close[erLen])
sumAbs = math.sum(math.abs(close - close[1]), erLen)
er = sumAbs > 0 ? priceChg/sumAbs : 0
structRaw = math.sign(emaFast-emaSlow)*(2*er-1)*1.5

compositeRaw = wTrend*trendRaw + wMomo*momoRaw + wVol*volRaw + wStruct*structRaw
compMean = ta.sma(compositeRaw, zWin)
compStd  = ta.stdev(compositeRaw, zWin)
o_t = compStd > 0 ? (compositeRaw-compMean)/compStd : 0

// ===================== HMM =====================
var array<float>  log_alpha_prev = array.from(math.log(1.0/3), math.log(1.0/3), math.log(1.0/3))
var array<float>  gamma_prev     = array.from(1.0/3, 1.0/3, 1.0/3)
var matrix<float> A_runtime      = matrix.new<float>(3, 3, 1.0 / 3.0)
var matrix<float> trans_counts   = matrix.new<float>(3, 3, 1.0)
var float         log_p_obs      = 0.0
var bool          initialized    = false

// ===================== CONDITIONS =====================
if not initialized
    matrix.set(A_runtime, 0, 0, a_BB)
    matrix.set(A_runtime, 0, 1, a_BT)
    matrix.set(A_runtime, 0, 2, a_BR)
    matrix.set(A_runtime, 1, 0, a_TB)
    matrix.set(A_runtime, 1, 1, a_TT)
    matrix.set(A_runtime, 1, 2, a_TR)
    matrix.set(A_runtime, 2, 0, a_RB)
    matrix.set(A_runtime, 2, 1, a_RT)
    matrix.set(A_runtime, 2, 2, a_RR)
    normalizeRows(A_runtime)
    array<float> pi0 = stationary(A_runtime)
    array.set(log_alpha_prev, 0, math.log(math.max(array.get(pi0, 0), 1e-12)))
    array.set(log_alpha_prev, 1, math.log(math.max(array.get(pi0, 1), 1e-12)))
    array.set(log_alpha_prev, 2, math.log(math.max(array.get(pi0, 2), 1e-12)))
    initialized := true

if not useRolling
    matrix.set(A_runtime, 0, 0, a_BB)
    matrix.set(A_runtime, 0, 1, a_BT)
    matrix.set(A_runtime, 0, 2, a_BR)
    matrix.set(A_runtime, 1, 0, a_TB)
    matrix.set(A_runtime, 1, 1, a_TT)
    matrix.set(A_runtime, 1, 2, a_TR)
    matrix.set(A_runtime, 2, 0, a_RB)
    matrix.set(A_runtime, 2, 1, a_RT)
    matrix.set(A_runtime, 2, 2, a_RR)
    normalizeRows(A_runtime)


//             FORWARD RECURSION IN LOG-SPACE (Rabiner 1989)
float lb_bull  = gaussianLogPdf(o_t, mu_bull,  sg_bull)
float lb_trans = gaussianLogPdf(o_t, mu_trans, sg_trans)
float lb_bear  = gaussianLogPdf(o_t, mu_bear,  sg_bear)

float lap0 = array.get(log_alpha_prev, 0)
float lap1 = array.get(log_alpha_prev, 1)
float lap2 = array.get(log_alpha_prev, 2)

float lA00 = math.log(math.max(matrix.get(A_runtime, 0, 0), 1e-12))
float lA01 = math.log(math.max(matrix.get(A_runtime, 0, 1), 1e-12))
float lA02 = math.log(math.max(matrix.get(A_runtime, 0, 2), 1e-12))
float lA10 = math.log(math.max(matrix.get(A_runtime, 1, 0), 1e-12))
float lA11 = math.log(math.max(matrix.get(A_runtime, 1, 1), 1e-12))
float lA12 = math.log(math.max(matrix.get(A_runtime, 1, 2), 1e-12))
float lA20 = math.log(math.max(matrix.get(A_runtime, 2, 0), 1e-12))
float lA21 = math.log(math.max(matrix.get(A_runtime, 2, 1), 1e-12))
float lA22 = math.log(math.max(matrix.get(A_runtime, 2, 2), 1e-12))

float la_bull  = lb_bull  + logsumexp3(lap0 + lA00, lap1 + lA10, lap2 + lA20)
float la_trans = lb_trans + logsumexp3(lap0 + lA01, lap1 + lA11, lap2 + lA21)
float la_bear  = lb_bear  + logsumexp3(lap0 + lA02, lap1 + lA12, lap2 + lA22)

float Z_t     = logsumexp3(la_bull, la_trans, la_bear)
float p_bull  = math.exp(la_bull  - Z_t)
float p_trans = math.exp(la_trans - Z_t)
float p_bear  = math.exp(la_bear  - Z_t)

log_p_obs := Z_t

array.set(log_alpha_prev, 0, la_bull  - Z_t)
array.set(log_alpha_prev, 1, la_trans - Z_t)
array.set(log_alpha_prev, 2, la_bear  - Z_t)

//          OPZIONALE: A EMPIRICA ROLLING (Kim-1994 soft counts) SELEZIONARE IN IMPOSTAZIONI
if useRolling and barstate.isconfirmed
    float decay = 1.0 - 1.0 / math.max(rollWin, 2)
    for i = 0 to 2
        float gprev_i = array.get(gamma_prev, i)
        for j = 0 to 2
            float oldv = matrix.get(trans_counts, i, j)
            float gnow = j == 0 ? p_bull : j == 1 ? p_trans : p_bear
            float soft = gprev_i * gnow
            matrix.set(trans_counts, i, j, decay * oldv + soft)
    for i = 0 to 2
        matrix.set(A_runtime, i, 0, matrix.get(trans_counts, i, 0) + 1e-6)
        matrix.set(A_runtime, i, 1, matrix.get(trans_counts, i, 1) + 1e-6)
        matrix.set(A_runtime, i, 2, matrix.get(trans_counts, i, 2) + 1e-6)
    normalizeRows(A_runtime)

array.set(gamma_prev, 0, p_bull)
array.set(gamma_prev, 1, p_trans)
array.set(gamma_prev, 2, p_bear)

//  FLAG BULL/BEAR + CONFIDENZA
int   mapState = p_bull >= p_trans and p_bull >= p_bear ? 0 : p_trans >= p_bear ? 1 : 2
float mapProb  = mapState == 0 ? p_bull : mapState == 1 ? p_trans : p_bear

bool confident = mapProb >= confTh
var int lastConfidentState = 1
if confident
    lastConfidentState := mapState

//                  PLOT
// EMA fast/slow ON CHART (price scale) ---------------------------------------
plot(showEMAs ? emaFast : na, "EMA fast", color = color.new(color.aqua,   20), linewidth = 1)
plot(showEMAs ? emaSlow : na, "EMA slow", color = color.new(color.orange, 20), linewidth = 1)

// PRICE PANE BACKGROUNG COLOR  --------------
bgcol = lastConfidentState == 0 ? color.new(bullColor, bgTransp) : lastConfidentState == 1 ? color.new(transColor, math.min(bgTransp + 4, 100)) : color.new(bearColor, bgTransp)
bgcolor(showBg ? bgcol : na, title = "MAP regime")

// CONFIRMED REGIME CHANGE FLAG  ----------------------------------------
bool bullCross  = lastConfidentState == 0 and lastConfidentState[1] != 0
bool transCross = lastConfidentState == 1 and lastConfidentState[1] != 1
bool bearCross  = lastConfidentState == 2 and lastConfidentState[1] != 2

if showLabels and bullCross
    label.new(bar_index, low, "Bull", yloc = yloc.belowbar, color = color.new(bullColor, 0), textcolor = color.white, style = label.style_label_up,   size = size.small)
if showLabels and transCross
    label.new(bar_index, high, "Trans", yloc = yloc.abovebar, color = color.new(transColor, 0), textcolor = color.black, style = label.style_label_down, size = size.small)
if showLabels and bearCross
    label.new(bar_index, high, "Bear", yloc = yloc.abovebar, color = color.new(bearColor, 0), textcolor = color.white, style = label.style_label_down, size = size.small)

plot(p_bull,                  "P(Bull)",         color = color.new(bullColor,  0), display = display.data_window)
plot(p_trans,                 "P(Transition)",   color = color.new(transColor, 0), display = display.data_window)
plot(p_bear,                  "P(Bear)",         color = color.new(bearColor,  0), display = display.data_window)
plot(showLL ? log_p_obs : na, "log P(O|lambda)", color = color.new(color.blue, 0), display = display.data_window)
plot(o_t,                     "Standardized obs z", color = color.new(color.aqua, 50), display = display.data_window)
plotchar(mapState, "MAP state",     "", location.top, color = color.gray, display = display.data_window)
plotchar(mapProb,  "MAP posterior", "", location.top, color = color.gray, display = display.data_window)

//                              SIGNAL MESSAGES
alertcondition(bullCross,  title = "Bull regime confirmed",       message = "HMM 3-regime: Bull (Risk-On) confirmed")
alertcondition(bearCross,  title = "Bear regime confirmed",       message = "HMM 3-regime: Bear (Risk-Off) confirmed")
alertcondition(transCross, title = "Transition regime confirmed", message = "HMM 3-regime: Transition confirmed")
````
