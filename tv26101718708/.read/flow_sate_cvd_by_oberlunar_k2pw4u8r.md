# Flow Sate CVD [by Oberlunar]

- url: https://www.tradingview.com/script/K2PW4u8r/
- type: indicator
- pine_id: PUB;ab8366feb9254d76ad82b5d346590625
- version: 1.0

## Description

Flow Sate CVD [by Oberlunar]  framework combining cumulative volume delta gap and fair-value gap geometry with an adaptive order-flow and market-state model. It maps Absorption, AAA and Exhaustion structures to price while continuously tracking Flow, Response, Structure and Regime states.

The indicator detects two CVD discontinuity models across configurable timeframes: two-bar TimeFixed CVD gaps and same-anchor three-bar CVD FVGs. Detected events are projected onto their corresponding price zones, with opacity determined solely by the relative magnitude of the CVD gap.

An adaptive classifier evaluates signed CVD pressure, flow persistence, price-impact efficiency, resistance, impact decay, ATR regime, EMA fan structure, multi-scale TRIX/RSI momentum, liquidity and price/CVD divergence. Internal thresholds and fast/mid/slow weights adapt to the observed market state automatically.

The resulting structures are classified as Absorption, AAA (Absorption-Acceptance-Aggression) or Exhaustion. Absorption and AAA create persistent, directionally polarised price zones; Exhaustion is displayed as a point event.

Four continuous lanes summarise the underlying model:

[list]
[*][b]FLOW: [/b] directional pressure and persistence.
[*][b]RESPONSE:[/b] The Drive, Resistance or Decay pattern.
[*][b]STRUCTURE:[/b]  simple EMA/TRIX/RSI alignment adjusted for price/CVD divergence.
[*][b]REGIME:[/b] liquidity and volatility environment.
[/list]

A Flow State meter provides the same four states in compact form. A separate composite combines FLOW, RESPONSE and STRUCTURE, while REGIME adjusts confidence. Its current state is displayed on the price chart through a colour-coded EMA(7): aqua for bullish consensus, red for bearish consensus and grey when the adaptive threshold is not reached.

The UK, US1, and US2 liquidity windows are shown with adaptive session backgrounds and opening labels and can be independently filtered for structural events.

The script uses confirmed historical information with barmerge.lookahead_off for its MTF requests and does not intentionally access future data.

[b]How to Use[/b]

Set TF1 for the displayed CVD and optionally enable additional MTF references. Use TimeFixed GAP CVD, CVD FVG, or both. Read the four lanes and Flow State meter as contextual diagnostics; projected Abs/AAA zones identify persistent price areas associated with classified CVD events, while Exhaustion circles mark decay events.

The EMA(7) is a compact visualisation of the composite state: increasing aqua intensity indicates stronger bullish agreement across the model, increasing red intensity indicates stronger bearish agreement, and grey indicates insufficient consensus.

[b]Some specifications[/b]
CVD is derived from the volume data available to TradingView and is not equivalent to full limit-order-book order flow. The FLOW component is therefore a CVD-derived signed-flow proxy, not true exchange-level OFI.  Classification is contextual and descriptive; Absorption, AAA, Exhaustion and composite states do not imply future price outcomes. MTF structures may also become available later than lower-timeframe observations because higher-timeframe information must develop and be confirmed.

Enjoy,
Oberlunar 👁★

## Source Code

````pine
//@version=6
import TradingView/ta/12

indicator("Flow Sate CVD [by Oberlunar]", shorttitle="FS-CVD [by Oberlunar]", overlay=false, format=format.volume, max_bars_back=5000, max_boxes_count=500, max_labels_count=500, dynamic_requests=true)

//=============================================================================
// CORE HELPERS
//=============================================================================

clamp01(float x) => math.max(0.0, math.min(1.0, x))
clamp11(float x) => math.max(-1.0, math.min(1.0, x))

tanhf(float x) =>
    float xx = math.max(-10.0, math.min(10.0, x))
    float e2 = math.exp(2.0 * xx)
    (e2 - 1.0) / (e2 + 1.0)

f_autoLowerTf(string refTf) =>
    float sec = timeframe.in_seconds(refTf)
    sec < 60.0 ? "1S" : sec < 86400.0 ? "1" : sec < 604800.0 ? "5" : "60"

f_prettyTf(string tf) =>
    int sec = int(timeframe.in_seconds(tf))
    sec < 60 ? str.tostring(sec) + "s" :
     sec < 3600 ? str.tostring(int(sec / 60)) + "m" :
     sec < 86400 ? (sec % 3600 == 0 ? str.tostring(int(sec / 3600)) + "H" : str.tostring(int(sec / 60)) + "m") :
     sec < 604800 ? (sec % 86400 == 0 ? str.tostring(int(sec / 86400)) + "D" : str.tostring(int(sec / 3600)) + "H") :
     str.tostring(int(sec / 604800)) + "W"

f_inWindow(int startMinute, int endMinute, string tz) =>
    int m = hour(time, tz) * 60 + minute(time, tz)
    int dw = dayofweek(time, tz)
    dw >= dayofweek.monday and dw <= dayofweek.friday and m >= startMinute and m < endMinute

f_inWindowAt(int ts, int startMinute, int endMinute, string tz) =>
    int m = hour(ts, tz) * 60 + minute(ts, tz)
    int dw = dayofweek(ts, tz)
    dw >= dayofweek.monday and dw <= dayofweek.friday and m >= startMinute and m < endMinute

f_windowProgress(int startMinute, int endMinute, string tz) =>
    int m = hour(time, tz) * 60 + minute(time, tz)
    clamp01(float(m - startMinute) / math.max(1.0, float(endMinute - startMinute)))

f_bgColor(color baseColor, float strength) =>
    color.new(baseColor, int(math.round(98.0 - clamp01(strength) * 40.0)))

f_inside(float innerTop, float innerBottom, float outerTop, float outerBottom) =>
    not na(innerTop) and not na(innerBottom) and not na(outerTop) and not na(outerBottom) and innerTop <= outerTop and innerBottom >= outerBottom

//=============================================================================
// INPUTS
//=============================================================================

string GROUP_CVD = "01 - CVD"

anchorInput = input.timeframe("30", "Anchor period", group=GROUP_CVD)
dataAggregationInput = input.string("Time", "Data aggregation", options=["Time", "1 tick"], group=GROUP_CVD)
bool useTicks = dataAggregationInput == "1 tick"

useCustomTimeframeInput = input.bool(false, "Use custom CVD aggregation timeframe", active=not useTicks, group=GROUP_CVD)
lowerTimeframeInput = input.timeframe("1", "CVD aggregation timeframe", active=useCustomTimeframeInput and not useTicks, group=GROUP_CVD)

string GROUP_MTF = "02 - Gap Timeframes"

tf1Input = input.timeframe("5", "TF1 - displayed CVD", group=GROUP_MTF)
string tf1 = tf1Input == "" ? timeframe.period : tf1Input

useTf2 = input.bool(true, "TF2", inline="T2", group=GROUP_MTF)
tf2 = input.timeframe("10", "", inline="T2", group=GROUP_MTF)

useTf3 = input.bool(false, "TF3", inline="T3", group=GROUP_MTF)
tf3 = input.timeframe("15", "", inline="T3", group=GROUP_MTF)

useTf4 = input.bool(false, "TF4", inline="T4", group=GROUP_MTF)
tf4 = input.timeframe("30", "", inline="T4", group=GROUP_MTF)

useTf5 = input.bool(false, "TF5", inline="T5", group=GROUP_MTF)
tf5 = input.timeframe("45", "", inline="T5", group=GROUP_MTF)

string GROUP_GAPS = "03 - Gap Models"

showTimeFixedGap = input.bool(true, "TimeFixed GAP CVD", inline="GM", group=GROUP_GAPS)
showFvgCvd = input.bool(false, "FVG CVD", inline="GM", group=GROUP_GAPS)

string GROUP_TYPES = "04 - Order Flow Structures"

showAbsorption = input.bool(true, "Absorption boxes", inline="TYPE", group=GROUP_TYPES)
showAAA = input.bool(true, "AAA boxes", inline="TYPE", group=GROUP_TYPES)
showExhaustion = input.bool(true, "Exhaustion circles", inline="TYPE", group=GROUP_TYPES)

string GROUP_FILTER = "05 - Signal Session Filter"

showUKSignals = input.bool(true, "UK", inline="SF", group=GROUP_FILTER)
showUS1Signals = input.bool(true, "US1", inline="SF", group=GROUP_FILTER)
showUS2Signals = input.bool(true, "US2", inline="SF", group=GROUP_FILTER)
showOutsideSignals = input.bool(true, "Outside", inline="SF2", group=GROUP_FILTER)

string GROUP_SESS = "06 - Session Backgrounds"

useUK = input.bool(true, "UK", inline="SES", group=GROUP_SESS)
useUS1 = input.bool(true, "US1", inline="SES", group=GROUP_SESS)
useUS2 = input.bool(true, "US2", inline="SES", group=GROUP_SESS)
orbMinutes = input.int(30, "Opening drive duration", options=[5, 15, 30, 60], group=GROUP_SESS)

string GROUP_LANES = "07 - Adaptive Flow Deck"

showFlowLanes = input.bool(true, "Show flow lanes", inline="LANE", group=GROUP_LANES)
showLaneStates = input.bool(true, "Right-edge states", inline="LANE", group=GROUP_LANES)
showFlowMeter = input.bool(true, "Show Flow State meter", group=GROUP_LANES)

string GROUP_COLOR = "08 - Colors"

bullCVD = input.color(color.rgb(0, 190, 185, 50), "Bull CVD", group=GROUP_COLOR)
bearCVD = input.color(color.rgb(215, 70, 114, 50), "Bear CVD", group=GROUP_COLOR)

bullAbsorptionColor = input.color(color.rgb(0, 200, 150, 50), "Bullish absorption", group=GROUP_COLOR)
bearAbsorptionColor = input.color(color.rgb(220, 60, 100, 50), "Bearish absorption", group=GROUP_COLOR)

bullExhaustionColor = input.color(color.rgb(50, 180, 255, 50), "Bullish exhaustion", group=GROUP_COLOR)
bearExhaustionColor = input.color(color.rgb(255, 40, 51, 50), "Bearish exhaustion", group=GROUP_COLOR)

bullAAAColor = input.color(color.rgb(70, 235, 235, 50), "Bullish AAA", group=GROUP_COLOR)
bearAAAColor = input.color(color.rgb(255, 80, 170, 50), "Bearish AAA", group=GROUP_COLOR)

ukColor = input.color(color.rgb(40, 255, 237, 50), "UK session", group=GROUP_COLOR)
us1Color = input.color(color.rgb(252, 255, 90, 50), "US1 session", group=GROUP_COLOR)
us2Color = input.color(color.rgb(35, 123, 255, 50), "US2 session", group=GROUP_COLOR)

//=============================================================================
// INTERNAL CONSTANTS
//
// No order-flow thresholds are user-selectable.
// Multi-scale feature banks stay fixed; their weights and decision thresholds
// adapt continuously to the inferred market regime.
//=============================================================================

int ATR_FAST = 14
int ATR_SLOW = 100
int GAP_RANGE_LOOKBACK = 50

int GAP_KIND_TIMEFIXED = 1
int GAP_KIND_FVG = 2

int UK_START = 8 * 60
int UK_END = 16 * 60 + 30

int US1_START = 9 * 60 + 30
int US1_END = 12 * 60 + 30

int US2_START = 12 * 60 + 30
int US2_END = 16 * 60

int PREOPEN_MIN = 30

int DIV_FAST = 21
int DIV_MID = 55
int DIV_SLOW = 89

float DIV_MIN_SIGNAL = 0.12
float DIV_MIN_SCORE = 0.14

float ZONE_MIN_OPACITY = 3.0
float ZONE_MAX_OPACITY = 26.0

int METER_SEGMENTS = 21
int METER_LAST_COL = METER_SEGMENTS + 1
color METER_BG = color.rgb(7, 2, 29)
color METER_NEUTRAL = color.rgb(38, 38, 52)

//=============================================================================
// MODEL HELPERS
//=============================================================================

f_zUnit(float src, simple int len) =>
    float mu = ta.sma(src, len)
    float sd = ta.stdev(src, len)
    float z = not na(sd) and sd > 0.0 ? (src - mu) / sd : 0.0
    tanhf(z / 2.0)

f_trixUnit(float src, simple int len) =>
    float e1 = ta.ema(src, len)
    float e2 = ta.ema(e1, len)
    float e3 = ta.ema(e2, len)
    float den = math.max(math.abs(nz(e3[1], e3)), 1e-10)
    float raw = 100.0 * (e3 - nz(e3[1], e3)) / den
    float sd = ta.stdev(raw, len)
    float z = not na(sd) and sd > 0.0 ? raw / sd : 0.0
    tanhf(z / 2.0)

f_waveSignal(float src, simple int len, float normScale) =>
    float e1 = ta.ema(src, len)
    float e2 = ta.ema(e1, len)
    float e3 = ta.ema(e2, len)

    float scale = math.max(math.abs(normScale), 1e-10)
    float maSlope = (e3 - e3[3]) / (scale * math.sqrt(3.0))

    float trixDen = math.max(math.abs(e3[1]), scale)
    float rawTrix = 100.0 * (e3 - e3[1]) / trixDen
    float trixSd = ta.stdev(rawTrix, len)
    float trixZ = not na(trixSd) and trixSd > 0.0 ? rawTrix / trixSd : 0.0

    float maSignal = tanhf(maSlope)
    float trixSignal = tanhf(trixZ / 2.0)

    bool agree = math.sign(maSignal) == math.sign(trixSignal) and math.abs(maSignal) > 0.03 and math.abs(trixSignal) > 0.03
    float signal = agree ? 0.58 * maSignal + 0.42 * trixSignal : 0.0

    [e3, signal]

//=============================================================================
// ADAPTIVE MARKET-STATE ENGINE
//
// Latent features:
//
// FLOW
//   signed CVD pressure
//   flow intensity
//   persistence
//
// RESPONSE
//   impact efficiency
//   resistance
//   impact decay
//
// STRUCTURE
//   EMA fan
//   TRIX
//   RSI
//
// REGIME
//   volatility
//   liquidity
//   structural noise
//=============================================================================

f_regimeCore(float d) =>
    float atrFast = ta.atr(ATR_FAST)
    float atrSlow = ta.atr(ATR_SLOW)

    //-------------------------------------------------------------------------
    // VOLATILITY REGIME
    //-------------------------------------------------------------------------

    float volRatio = not na(atrSlow) and atrSlow > 0.0 ? atrFast / atrSlow : 1.0
    float volatilityScore = clamp01((volRatio - 0.70) / 0.90)

    //-------------------------------------------------------------------------
    // EMA FAN
    //-------------------------------------------------------------------------

    float e8 = ta.ema(close, 8)
    float e13 = ta.ema(close, 13)
    float e21 = ta.ema(close, 21)
    float e34 = ta.ema(close, 34)
    float e55 = ta.ema(close, 55)
    float e89 = ta.ema(close, 89)

    float bullPairs = (e8 > e13 ? 1.0 : 0.0) + (e13 > e21 ? 1.0 : 0.0) + (e21 > e34 ? 1.0 : 0.0) + (e34 > e55 ? 1.0 : 0.0) + (e55 > e89 ? 1.0 : 0.0)
    float bearPairs = (e8 < e13 ? 1.0 : 0.0) + (e13 < e21 ? 1.0 : 0.0) + (e21 < e34 ? 1.0 : 0.0) + (e34 < e55 ? 1.0 : 0.0) + (e55 < e89 ? 1.0 : 0.0)

    float orderSigned = (bullPairs - bearPairs) / 5.0
    float fanSpreadSigned = not na(atrFast) and atrFast > 0.0 ? clamp11((e8 - e89) / (atrFast * 3.5)) : 0.0

    float slope8 = not na(atrFast) and atrFast > 0.0 ? clamp11((e8 - e8[3]) / (atrFast * 1.50)) : 0.0
    float slope21 = not na(atrFast) and atrFast > 0.0 ? clamp11((e21 - e21[3]) / (atrFast * 1.25)) : 0.0
    float slope55 = not na(atrFast) and atrFast > 0.0 ? clamp11((e55 - e55[3]) / atrFast) : 0.0

    float slopeSigned = (slope8 + slope21 + slope55) / 3.0
    float trendSigned = clamp11(0.45 * orderSigned + 0.30 * fanSpreadSigned + 0.25 * slopeSigned)
    float trendStrength = math.abs(trendSigned)

    //-------------------------------------------------------------------------
    // CONTINUOUS MULTI-SCALE WEIGHTS
    //
    // High volatility -> faster bank receives more weight.
    // Calm environment -> slow structural bank receives more weight.
    //-------------------------------------------------------------------------

    float wFast = 0.65 + 0.85 * volatilityScore
    float wMid = 1.00
    float wSlow = 1.15 - 0.55 * volatilityScore
    float wSum = math.max(wFast + wMid + wSlow, 1e-10)

    //-------------------------------------------------------------------------
    // TRIX + RSI MOMENTUM CONSENSUS
    //-------------------------------------------------------------------------

    float trixFast = f_trixUnit(close, 8)
    float trixMid = f_trixUnit(close, 21)
    float trixSlow = f_trixUnit(close, 55)

    float rsiFast = clamp11((ta.rsi(close, 7) - 50.0) / 50.0)
    float rsiMid = clamp11((ta.rsi(close, 14) - 50.0) / 50.0)
    float rsiSlow = clamp11((ta.rsi(close, 28) - 50.0) / 50.0)

    float trixSigned = (wFast * trixFast + wMid * trixMid + wSlow * trixSlow) / wSum
    float rsiSigned = (wFast * rsiFast + wMid * rsiMid + wSlow * rsiSlow) / wSum
    float momentumSigned = clamp11(0.58 * trixSigned + 0.42 * rsiSigned)

    //-------------------------------------------------------------------------
    // MULTI-SCALE SIGNED FLOW
    //-------------------------------------------------------------------------

    float flowFast = f_zUnit(d, 8)
    float flowMid = f_zUnit(d, 21)
    float flowSlow = f_zUnit(d, 55)

    float flowSigned = clamp11((wFast * flowFast + wMid * flowMid + wSlow * flowSlow) / wSum)

    float absFlowMean = ta.ema(math.abs(d), 21)
    float flowNorm = not na(absFlowMean) and absFlowMean > 0.0 ? math.abs(d) / absFlowMean : 0.0
    float flowBurst = clamp01((flowNorm - 0.55) / 1.75)

    float flowIntensity = clamp01(0.55 * math.abs(flowSigned) + 0.45 * flowBurst)

    //-------------------------------------------------------------------------
    // FLOW PERSISTENCE
    //-------------------------------------------------------------------------

    float flowSign = d > 0.0 ? 1.0 : d < 0.0 ? -1.0 : 0.0

    float persistFast = ta.ema(flowSign, 5)
    float persistMid = ta.ema(flowSign, 13)
    float persistSlow = ta.ema(flowSign, 34)

    float persistenceSigned = clamp11((wFast * persistFast + wMid * persistMid + wSlow * persistSlow) / wSum)

    //-------------------------------------------------------------------------
    // STRUCTURAL NOISE
    //-------------------------------------------------------------------------

    float structureCoherence = clamp01(0.42 * trendStrength + 0.33 * math.abs(momentumSigned) + 0.25 * math.abs(persistenceSigned))
    float noiseScore = 1.0 - structureCoherence

    //-------------------------------------------------------------------------
    // PRICE IMPACT EFFICIENCY
    //-------------------------------------------------------------------------

    float priceBody = close - open
    float bodyAtr = not na(atrFast) and atrFast > 0.0 ? math.abs(priceBody) / atrFast : 0.0

    float impactRaw = bodyAtr / math.max(flowNorm, 0.25)
    float impactEfficiency = clamp01(impactRaw / 0.75)

    bool aligned = (priceBody > 0.0 and d > 0.0) or (priceBody < 0.0 and d < 0.0)
    float impactDirection = priceBody > 0.0 ? 1.0 : priceBody < 0.0 ? -1.0 : 0.0
    float impactSigned = impactDirection * impactEfficiency * (aligned ? 1.0 : 0.35)

    //-------------------------------------------------------------------------
    // FLOW RESISTANCE
    //
    // Negative aggressive flow resisted by price -> bullish resistance.
    // Positive aggressive flow resisted by price -> bearish resistance.
    //-------------------------------------------------------------------------

    float resistanceScore = clamp01(flowIntensity * (1.0 - impactEfficiency) * (0.70 + 0.30 * noiseScore))
    float resistanceSigned = d < 0.0 ? resistanceScore : d > 0.0 ? -resistanceScore : 0.0

    //-------------------------------------------------------------------------
    // IMPACT DECAY
    //-------------------------------------------------------------------------

    float low5 = ta.lowest(low, 5)[1]
    float low8 = ta.lowest(low, 8)[1]
    float low13 = ta.lowest(low, 13)[1]

    float high5 = ta.highest(high, 5)[1]
    float high8 = ta.highest(high, 8)[1]
    float high13 = ta.highest(high, 13)[1]

    float downExt = (wFast * (low <= low5 ? 1.0 : 0.0) + wMid * (low <= low8 ? 1.0 : 0.0) + wSlow * (low <= low13 ? 1.0 : 0.0)) / wSum
    float upExt = (wFast * (high >= high5 ? 1.0 : 0.0) + wMid * (high >= high8 ? 1.0 : 0.0) + wSlow * (high >= high13 ? 1.0 : 0.0)) / wSum

    float sell5 = math.abs(math.min(nz(ta.lowest(d, 5)[1]), 0.0))
    float sell8 = math.abs(math.min(nz(ta.lowest(d, 8)[1]), 0.0))
    float sell13 = math.abs(math.min(nz(ta.lowest(d, 13)[1]), 0.0))

    float buy5 = math.max(nz(ta.highest(d, 5)[1]), 0.0)
    float buy8 = math.max(nz(ta.highest(d, 8)[1]), 0.0)
    float buy13 = math.max(nz(ta.highest(d, 13)[1]), 0.0)

    float sellRef = (wFast * sell5 + wMid * sell8 + wSlow * sell13) / wSum
    float buyRef = (wFast * buy5 + wMid * buy8 + wSlow * buy13) / wSum

    float sellDecay = d < 0.0 and sellRef > 0.0 ? clamp01(1.0 - math.abs(d) / sellRef) : 0.0
    float buyDecay = d > 0.0 and buyRef > 0.0 ? clamp01(1.0 - math.abs(d) / buyRef) : 0.0

    float momentumLoss = clamp01((math.abs(nz(momentumSigned[1])) - math.abs(momentumSigned)) / 0.35)
    float fanLoss = clamp01((math.abs(nz(trendSigned[1])) - trendStrength) / 0.30)

    float bullDecay = clamp01(downExt * sellDecay * (0.55 + 0.25 * momentumLoss + 0.20 * fanLoss))
    float bearDecay = clamp01(upExt * buyDecay * (0.55 + 0.25 * momentumLoss + 0.20 * fanLoss))

    float decaySigned = bullDecay > bearDecay ? bullDecay : bearDecay > bullDecay ? -bearDecay : 0.0

    //-------------------------------------------------------------------------
    // LIQUIDITY / TAPE QUALITY
    //-------------------------------------------------------------------------

    float liquidityScore = clamp01(0.40 * flowIntensity + 0.25 * impactEfficiency + 0.20 * (1.0 - noiseScore) + 0.15 * volatilityScore)

    [flowSigned, flowIntensity, impactSigned, persistenceSigned, resistanceSigned, decaySigned, volatilityScore, trendSigned, momentumSigned, noiseScore, liquidityScore]

//=============================================================================
// SEMANTIC HELPERS
//=============================================================================

f_classEnabled(int cls) =>
    int family = math.abs(cls)
    family == 1 ? showAbsorption : family == 2 ? showExhaustion : family == 3 ? showAAA : false

f_classText(int cls) =>
    int family = math.abs(cls)
    family == 1 ? "Abs" : family == 2 ? "Exh" : family == 3 ? "AAA" : "Ntr"

f_gapKindText(int kind) =>
    kind == GAP_KIND_TIMEFIXED ? "TFG" : "FVG"

f_directionText(int cls) =>
    cls > 0 ? "Bullish" : cls < 0 ? "Bearish" : "Neutral"

f_zoneColor(int cls) =>
    cls == 3 ? bullAAAColor :
     cls == -3 ? bearAAAColor :
     cls == 1 ? bullAbsorptionColor :
     cls == -1 ? bearAbsorptionColor :
     cls == 2 ? bullExhaustionColor :
     cls == -2 ? bearExhaustionColor :
     color.gray

f_laneSignedColor(float signedValue, float intensity, color bullColor, color bearColor) =>
    float s = clamp11(nz(signedValue))
    float i = clamp01(nz(intensity))
    s > 0.06 ? color.from_gradient(i, 0.0, 1.0, color.new(bullColor, 90), color.new(bullColor, 5)) :
     s < -0.06 ? color.from_gradient(i, 0.0, 1.0, color.new(bearColor, 90), color.new(bearColor, 5)) :
     color.new(color.gray, 88)

f_laneUnsignedColor(float intensity, color hue) =>
    color.from_gradient(clamp01(nz(intensity)), 0.0, 1.0, color.new(hue, 92), color.new(hue, 5))

//=============================================================================
// EFFECTIVE REQUEST TIMEFRAMES
//=============================================================================

string reqTf2 = useTf2 ? tf2 : tf1
string reqTf3 = useTf3 ? tf3 : tf1
string reqTf4 = useTf4 ? tf4 : tf1
string reqTf5 = useTf5 ? tf5 : tf1

float chartSec = timeframe.in_seconds()

float tf1Sec = timeframe.in_seconds(tf1)
float tf2Sec = timeframe.in_seconds(tf2)
float tf3Sec = timeframe.in_seconds(tf3)
float tf4Sec = timeframe.in_seconds(tf4)
float tf5Sec = timeframe.in_seconds(tf5)

//=============================================================================
// VALIDATION
//=============================================================================

if barstate.isfirst
    if tf1Sec < chartSec
        runtime.error("TF1 must be greater than or equal to the chart timeframe.")
    if useTf2 and tf2Sec < chartSec
        runtime.error("TF2 must be greater than or equal to the chart timeframe.")
    if useTf3 and tf3Sec < chartSec
        runtime.error("TF3 must be greater than or equal to the chart timeframe.")
    if useTf4 and tf4Sec < chartSec
        runtime.error("TF4 must be greater than or equal to the chart timeframe.")
    if useTf5 and tf5Sec < chartSec
        runtime.error("TF5 must be greater than or equal to the chart timeframe.")

    if useCustomTimeframeInput and not useTicks
        float customLtfSec = timeframe.in_seconds(lowerTimeframeInput)
        if customLtfSec > chartSec
            runtime.error("Custom CVD aggregation timeframe must be <= chart timeframe.")

//=============================================================================
// LOWER TIMEFRAMES
//=============================================================================

string ltf1 = useTicks ? "1T" : useCustomTimeframeInput ? lowerTimeframeInput : f_autoLowerTf(tf1)
string ltf2 = useTicks ? "1T" : useCustomTimeframeInput ? lowerTimeframeInput : f_autoLowerTf(reqTf2)
string ltf3 = useTicks ? "1T" : useCustomTimeframeInput ? lowerTimeframeInput : f_autoLowerTf(reqTf3)
string ltf4 = useTicks ? "1T" : useCustomTimeframeInput ? lowerTimeframeInput : f_autoLowerTf(reqTf4)
string ltf5 = useTicks ? "1T" : useCustomTimeframeInput ? lowerTimeframeInput : f_autoLowerTf(reqTf5)

string baseLtf = useTicks ? "1T" : useCustomTimeframeInput ? lowerTimeframeInput : f_autoLowerTf(timeframe.period)

//=============================================================================
// SESSION FILTER
//=============================================================================

f_signalSessionEnabled(int sourceTime, int sourceTimeClose) =>
    int midTime = sourceTime + int((sourceTimeClose - sourceTime) / 2)
    int endTime = math.max(sourceTime, sourceTimeClose - 1)

    bool uk = f_inWindowAt(sourceTime, UK_START, UK_END, "Europe/London") or f_inWindowAt(midTime, UK_START, UK_END, "Europe/London") or f_inWindowAt(endTime, UK_START, UK_END, "Europe/London")
    bool us1 = f_inWindowAt(sourceTime, US1_START, US1_END, "America/New_York") or f_inWindowAt(midTime, US1_START, US1_END, "America/New_York") or f_inWindowAt(endTime, US1_START, US1_END, "America/New_York")
    bool us2 = f_inWindowAt(sourceTime, US2_START, US2_END, "America/New_York") or f_inWindowAt(midTime, US2_START, US2_END, "America/New_York") or f_inWindowAt(endTime, US2_START, US2_END, "America/New_York")

    bool insideDefined = uk or us1 or us2

    (uk and showUKSignals) or (us1 and showUS1Signals) or (us2 and showUS2Signals) or (not insideDefined and showOutsideSignals)

//=============================================================================
// ADAPTIVE GAP PACKET
//=============================================================================

f_cvdPacket(string lowerTf, string anchor) =>
    [o, h, l, c] = ta.requestVolumeDelta(lowerTf, anchor)

    float d = c - o

    [flowSigned, flowIntensity, impactSigned, persistenceSigned, resistanceSigned, decaySigned, volatilityScore, trendSigned, momentumSigned, noiseScore, liquidityScore] = f_regimeCore(d)

    float atrNow = ta.atr(ATR_FAST)
    float priceRange = high - low
    float body = close - open

    float bodyAtrSigned = not na(atrNow) and atrNow > 0.0 ? body / atrNow : 0.0
    float bodyEff = priceRange > 0.0 ? body / priceRange : 0.0
    float closeLocation = priceRange > 0.0 ? (close - low) / priceRange : 0.5
    float trendStrength = math.abs(trendSigned)

    //-------------------------------------------------------------------------
    // ADAPTIVE ABSORPTION
    //-------------------------------------------------------------------------

    float absFlowThreshold = 0.38 + 0.22 * noiseScore + 0.10 * trendStrength
    float absResistanceThreshold = 0.20 + 0.16 * noiseScore + 0.08 * trendStrength
    float absResponseTolerance = 0.22 + 0.38 * volatilityScore

    bool absBull = d < 0.0 and flowIntensity >= absFlowThreshold and resistanceSigned >= absResistanceThreshold and bodyAtrSigned > -absResponseTolerance and closeLocation >= 0.42
    bool absBear = d > 0.0 and flowIntensity >= absFlowThreshold and resistanceSigned <= -absResistanceThreshold and bodyAtrSigned < absResponseTolerance and closeLocation <= 0.58

    //-------------------------------------------------------------------------
    // ADAPTIVE ACCEPTANCE
    //-------------------------------------------------------------------------

    int bullAbsAge = nz(ta.barssince(absBull), 10000)
    int bearAbsAge = nz(ta.barssince(absBear), 10000)

    float lastBullAbsHigh = ta.valuewhen(absBull, high, 0)
    float lastBullAbsLow = ta.valuewhen(absBull, low, 0)

    float lastBearAbsHigh = ta.valuewhen(absBear, high, 0)
    float lastBearAbsLow = ta.valuewhen(absBear, low, 0)

    float rangeAtr = not na(atrNow) and atrNow > 0.0 ? priceRange / atrNow : 1.0
    float compressionRangeLimit = 0.55 + 0.35 * volatilityScore

    float rangeCompression = 1.0 - clamp01(rangeAtr / math.max(compressionRangeLimit, 0.10))
    float flowCompression = 1.0 - flowIntensity
    float fanCompression = 1.0 - trendStrength
    float momentumCompression = 1.0 - math.abs(momentumSigned)

    float acceptanceScore = clamp01(0.30 * rangeCompression + 0.25 * flowCompression + 0.25 * fanCompression + 0.20 * momentumCompression)

    int aaaWindow = int(math.round(8.0 + 6.0 * (1.0 - volatilityScore) + 4.0 * noiseScore))
    float acceptanceThreshold = 0.50 + 0.10 * noiseScore
    float holdTolerance = not na(atrNow) ? atrNow * (0.15 + 0.20 * volatilityScore) : 0.0

    bool bullAcceptance = bullAbsAge >= 1 and bullAbsAge <= aaaWindow and acceptanceScore >= acceptanceThreshold and not na(lastBullAbsLow) and low >= lastBullAbsLow - holdTolerance and close >= lastBullAbsLow
    bool bearAcceptance = bearAbsAge >= 1 and bearAbsAge <= aaaWindow and acceptanceScore >= acceptanceThreshold and not na(lastBearAbsHigh) and high <= lastBearAbsHigh + holdTolerance and close <= lastBearAbsHigh

    int bullAcceptanceAge = nz(ta.barssince(bullAcceptance), 10000)
    int bearAcceptanceAge = nz(ta.barssince(bearAcceptance), 10000)

    bool bullOrdered = bullAbsAge >= 2 and bullAbsAge <= aaaWindow and bullAcceptanceAge >= 1 and bullAcceptanceAge < bullAbsAge
    bool bearOrdered = bearAbsAge >= 2 and bearAbsAge <= aaaWindow and bearAcceptanceAge >= 1 and bearAcceptanceAge < bearAbsAge

    //-------------------------------------------------------------------------
    // ADAPTIVE AGGRESSION
    //-------------------------------------------------------------------------

    float bullPersistence = clamp01(persistenceSigned)
    float bearPersistence = clamp01(-persistenceSigned)

    float bullMomentum = clamp01(momentumSigned)
    float bearMomentum = clamp01(-momentumSigned)

    float bullTrend = clamp01(trendSigned)
    float bearTrend = clamp01(-trendSigned)

    float impactEfficiency = math.abs(impactSigned)

    float bullAggressionScore = clamp01(0.30 * flowIntensity + 0.22 * impactEfficiency + 0.18 * bullPersistence + 0.16 * bullMomentum + 0.14 * bullTrend)
    float bearAggressionScore = clamp01(0.30 * flowIntensity + 0.22 * impactEfficiency + 0.18 * bearPersistence + 0.16 * bearMomentum + 0.14 * bearTrend)

    float aggressionThreshold = 0.55 + 0.10 * noiseScore - 0.05 * volatilityScore
    float bodyEfficiencyThreshold = 0.18 + 0.16 * (1.0 - volatilityScore)

    bool bullAggression = bullOrdered and not na(lastBullAbsHigh) and close > lastBullAbsHigh and flowSigned > 0.12 and bullAggressionScore >= aggressionThreshold and bodyEff >= bodyEfficiencyThreshold
    bool bearAggression = bearOrdered and not na(lastBearAbsLow) and close < lastBearAbsLow and flowSigned < -0.12 and bearAggressionScore >= aggressionThreshold and bodyEff <= -bodyEfficiencyThreshold

    //-------------------------------------------------------------------------
    // ADAPTIVE EXHAUSTION
    //-------------------------------------------------------------------------

    float decayThreshold = 0.25 + 0.18 * noiseScore + 0.05 * trendStrength

    bool exhBull = decaySigned >= decayThreshold and closeLocation >= 0.30
    bool exhBear = decaySigned <= -decayThreshold and closeLocation <= 0.70

    // AAA > Absorption > Exhaustion.
    int cls = bullAggression ? 3 : bearAggression ? -3 : absBull ? 1 : absBear ? -1 : exhBull ? 2 : exhBear ? -2 : 0

    //-------------------------------------------------------------------------
    // TIMEFIXED GAP
    //-------------------------------------------------------------------------

    bool tfGapUp = not na(l) and not na(h[1]) and l > h[1]
    bool tfGapDown = not na(h) and not na(l[1]) and h < l[1]

    int tfGapDir = tfGapUp ? 1 : tfGapDown ? -1 : 0
    float tfGapSize = tfGapUp ? l - h[1] : tfGapDown ? l[1] - h : 0.0

    //-------------------------------------------------------------------------
    // SAME-ANCHOR 3-CANDLE FVG
    //-------------------------------------------------------------------------

    int anchorStamp = time(anchor)

    bool sameAnchor3 = not na(anchorStamp) and not na(anchorStamp[1]) and not na(anchorStamp[2]) and anchorStamp == anchorStamp[1] and anchorStamp[1] == anchorStamp[2]

    bool fvgGapUp = sameAnchor3 and not na(l) and not na(h[2]) and l > h[2]
    bool fvgGapDown = sameAnchor3 and not na(h) and not na(l[2]) and h < l[2]

    int fvgGapDir = fvgGapUp ? 1 : fvgGapDown ? -1 : 0
    float fvgGapSize = fvgGapUp ? l - h[2] : fvgGapDown ? l[2] - h : 0.0

    float cvdRange = not na(h) and not na(l) ? math.max(h - l, 0.0) : na
    float rangeRef = ta.ema(cvdRange, GAP_RANGE_LOOKBACK)

    [o, h, l, c, tfGapDir, tfGapSize, fvgGapDir, fvgGapSize, high[1], low[1], time[1], time_close[1], rangeRef, cls[1], atrNow[1]]

//=============================================================================
// MTF GAP REQUESTS
//=============================================================================

[o1, h1, l1, c1, tfDir1, tfSize1, fvgDir1, fvgSize1, srcPH1, srcPL1, srcT1, srcTC1, refR1, cls1, srcATR1] = request.security(syminfo.tickerid, tf1, f_cvdPacket(ltf1, anchorInput), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
[o2, h2, l2, c2, tfDir2, tfSize2, fvgDir2, fvgSize2, srcPH2, srcPL2, srcT2, srcTC2, refR2, cls2, srcATR2] = request.security(syminfo.tickerid, reqTf2, f_cvdPacket(ltf2, anchorInput), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
[o3, h3, l3, c3, tfDir3, tfSize3, fvgDir3, fvgSize3, srcPH3, srcPL3, srcT3, srcTC3, refR3, cls3, srcATR3] = request.security(syminfo.tickerid, reqTf3, f_cvdPacket(ltf3, anchorInput), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
[o4, h4, l4, c4, tfDir4, tfSize4, fvgDir4, fvgSize4, srcPH4, srcPL4, srcT4, srcTC4, refR4, cls4, srcATR4] = request.security(syminfo.tickerid, reqTf4, f_cvdPacket(ltf4, anchorInput), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
[o5, h5, l5, c5, tfDir5, tfSize5, fvgDir5, fvgSize5, srcPH5, srcPL5, srcT5, srcTC5, refR5, cls5, srcATR5] = request.security(syminfo.tickerid, reqTf5, f_cvdPacket(ltf5, anchorInput), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)

//=============================================================================
// TF1 CVD
//=============================================================================

float cvdRange1 = not na(h1) and not na(l1) ? math.max(h1 - l1, 0.0) : na
float cvdRangeMean1 = ta.ema(cvdRange1, 34)
float cvdRangeRatio1 = not na(cvdRangeMean1) and cvdRangeMean1 > 0.0 ? cvdRange1 / cvdRangeMean1 : 1.0
float cvdVisualIntensity = clamp01((cvdRangeRatio1 - 0.50) / 1.50)

int cvdTransparency = int(math.round(80.0 - cvdVisualIntensity * 75.0))
color cvdBaseColor = c1 >= o1 ? bullCVD : bearCVD
color cvdColor = color.new(cvdBaseColor, cvdTransparency)

hline(0, "Zero", color=color.new(color.gray, 68), linestyle=hline.style_dashed)
plotcandle(o1, h1, l1, c1, title="CVD TF1", color=cvdColor, bordercolor=cvdColor, wickcolor=cvdColor)

//=============================================================================
// CONTINUOUS TF1 STATE PACKET
//=============================================================================

f_statePacket(string lowerTf, string anchor) =>
    [do_, dh_, dl_, dc_] = ta.requestVolumeDelta(lowerTf, anchor)

    float d_ = dc_ - do_

    [flowSigned_, flowIntensity_, impactSigned_, persistenceSigned_, resistanceSigned_, decaySigned_, volatilityScore_, trendSigned_, momentumSigned_, noiseScore_, liquidityScore_] = f_regimeCore(d_)

    float pAtr_ = ta.atr(ATR_FAST)
    float cAtr_ = ta.rma(math.abs(d_), ATR_FAST)

    [pWave0_, pSig0_] = f_waveSignal(close, DIV_FAST, pAtr_)
    [cWave0_, cSig0_] = f_waveSignal(dc_, DIV_FAST, cAtr_)

    [pWave1_, pSig1_] = f_waveSignal(close, DIV_MID, pAtr_)
    [cWave1_, cSig1_] = f_waveSignal(dc_, DIV_MID, cAtr_)

    [pWave2_, pSig2_] = f_waveSignal(close, DIV_SLOW, pAtr_)
    [cWave2_, cSig2_] = f_waveSignal(dc_, DIV_SLOW, cAtr_)

    [flowSigned_, flowIntensity_, impactSigned_, persistenceSigned_, resistanceSigned_, decaySigned_, volatilityScore_, trendSigned_, momentumSigned_, noiseScore_, liquidityScore_, pSig0_, cSig0_, cWave0_, pSig1_, cSig1_, cWave1_, pSig2_, cSig2_, cWave2_, cAtr_]

[flowSigned, flowIntensity, impactSigned, persistenceSigned, resistanceSigned, decaySigned, volatilityScore, trendSigned, momentumSigned, noiseScore, liquidityScore, pSig0, cSig0, cWave0, pSig1, cSig1, cWave1, pSig2, cSig2, cWave2, divCvdAtr] = request.security(syminfo.tickerid, tf1, f_statePacket(ltf1, anchorInput), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//=============================================================================
// ADAPTIVE DIVERGENCE
//=============================================================================

float divFastWeight = 0.85 + 0.45 * volatilityScore
float divMidWeight = 1.00
float divSlowWeight = 1.15 - 0.45 * volatilityScore

bool div0 = math.sign(pSig0) == -math.sign(cSig0) and math.abs(pSig0) >= DIV_MIN_SIGNAL and math.abs(cSig0) >= DIV_MIN_SIGNAL
bool div1 = math.sign(pSig1) == -math.sign(cSig1) and math.abs(pSig1) >= DIV_MIN_SIGNAL and math.abs(cSig1) >= DIV_MIN_SIGNAL
bool div2 = math.sign(pSig2) == -math.sign(cSig2) and math.abs(pSig2) >= DIV_MIN_SIGNAL and math.abs(cSig2) >= DIV_MIN_SIGNAL

float score0 = div0 ? math.sqrt(math.abs(pSig0 * cSig0)) * divFastWeight : 0.0
float score1 = div1 ? math.sqrt(math.abs(pSig1 * cSig1)) * divMidWeight : 0.0
float score2 = div2 ? math.sqrt(math.abs(pSig2 * cSig2)) * divSlowWeight : 0.0

int divRow = 0
float divScore = score0

if score1 > divScore
    divRow := 1
    divScore := score1

if score2 > divScore
    divRow := 2
    divScore := score2

float divWave = divRow == 0 ? cWave0 : divRow == 1 ? cWave1 : cWave2
float selectedPriceSignal = divRow == 0 ? pSig0 : divRow == 1 ? pSig1 : pSig2

int divDir = divScore >= DIV_MIN_SCORE ? (selectedPriceSignal > 0.0 ? 1 : selectedPriceSignal < 0.0 ? -1 : 0) : 0

bool divActive = divDir != 0
bool divStart = divActive and (not divActive[1] or divDir != divDir[1] or divRow != divRow[1])

color divergenceWaveColor = divDir > 0 ? color.new(bullCVD, 65) : divDir < 0 ? color.new(bearCVD, 65) : na

plot(divActive ? divWave : na, "Adaptive divergence wave", color=divergenceWaveColor, linewidth=2)

//=============================================================================
// FOUR SEMANTIC LANES
//=============================================================================

//-----------------------------------------------------------------------------
// FLOW = signed pressure + persistence
//-----------------------------------------------------------------------------

float flowLaneSigned = clamp11(0.58 * flowSigned + 0.42 * persistenceSigned)
float flowLaneIntensity = clamp01(0.55 * flowIntensity + 0.45 * math.abs(persistenceSigned))

string flowState =
     flowLaneIntensity < 0.16 ? "Balanced" :
     flowLaneSigned > 0.10 ? "Bullish" :
     flowLaneSigned < -0.10 ? "Bearish" :
     "Balanced"

color flowLaneColor =
     flowState == "Bullish" ? f_laneSignedColor(1.0, flowLaneIntensity, bullCVD, bearCVD) :
     flowState == "Bearish" ? f_laneSignedColor(-1.0, flowLaneIntensity, bullCVD, bearCVD) :
     color.new(color.gray, 84)

//-----------------------------------------------------------------------------
// RESPONSE = Drive / Resistance / Decay
//-----------------------------------------------------------------------------

float driveScore = clamp01(flowIntensity * math.abs(impactSigned) * (1.0 - math.abs(decaySigned)))
float resistanceScore = clamp01(math.abs(resistanceSigned))
float responseDecayScore = clamp01(math.abs(decaySigned))

float responseIntensity = math.max(driveScore, math.max(resistanceScore, responseDecayScore))

int responseMode =
     responseIntensity < 0.14 ? 0 :
     driveScore >= resistanceScore and driveScore >= responseDecayScore ? 1 :
     resistanceScore >= responseDecayScore ? 2 :
     3

string responseState =
     responseMode == 1 ? "Drive" :
     responseMode == 2 ? "Resistance" :
     responseMode == 3 ? "Decay" :
     "Neutral"

float responseSigned =
     responseMode == 1 ? math.sign(impactSigned) * driveScore :
     responseMode == 2 ? resistanceSigned :
     responseMode == 3 ? decaySigned :
     0.0

color responseLaneColor =
     responseMode == 1 ? f_laneSignedColor(responseSigned, responseIntensity, bullCVD, bearCVD) :
     responseMode == 2 ? f_laneSignedColor(responseSigned, responseIntensity, bullAbsorptionColor, bearAbsorptionColor) :
     responseMode == 3 ? f_laneSignedColor(responseSigned, responseIntensity, bullExhaustionColor, bearExhaustionColor) :
     color.new(color.gray, 86)

//-----------------------------------------------------------------------------
// STRUCTURE = EMA Fan + TRIX/RSI, divergence as coherence penalty
//-----------------------------------------------------------------------------

float structureBase = clamp11(0.52 * trendSigned + 0.48 * momentumSigned)

bool structureVsDivConflict = divDir != 0 and math.abs(structureBase) > 0.08 and ((structureBase > 0.0 and divDir < 0) or (structureBase < 0.0 and divDir > 0))
float divConflict = structureVsDivConflict ? clamp01(divScore) : 0.0

bool trendMomentumConflict = math.abs(trendSigned) > 0.15 and math.abs(momentumSigned) > 0.15 and math.sign(trendSigned) != math.sign(momentumSigned)

float structureLaneSigned = clamp11(structureBase * (1.0 - 0.60 * divConflict))

string structureState =
     divConflict >= 0.35 ? "Diverging" :
     trendMomentumConflict ? "Transition" :
     structureLaneSigned > 0.12 ? "Bullish" :
     structureLaneSigned < -0.12 ? "Bearish" :
     "Transition"

float structureLaneIntensity =
     structureState == "Diverging" ? divConflict :
     structureState == "Transition" ? clamp01(0.50 * math.abs(trendSigned) + 0.50 * math.abs(momentumSigned)) :
     clamp01(math.abs(structureLaneSigned))

color structureLaneColor =
     structureState == "Diverging" ? color.from_gradient(divConflict, 0.0, 1.0, color.new(color.gray, 84), color.new(color.yellow, 5)) :
     structureState == "Transition" ? color.new(color.silver, 72) :
     f_laneSignedColor(structureLaneSigned, structureLaneIntensity, color.aqua, color.red)

//-----------------------------------------------------------------------------
// REGIME = volatility + liquidity
//-----------------------------------------------------------------------------

float regimeActivity = clamp01(0.55 * volatilityScore + 0.45 * liquidityScore)
float dislocationScore = clamp01(volatilityScore * (1.0 - liquidityScore))

string regimeState =
     volatilityScore > 0.65 and dislocationScore > 0.30 ? "Dislocated" :
     volatilityScore > 0.70 and liquidityScore > 0.52 ? "Expansion" :
     liquidityScore > 0.52 and volatilityScore < 0.45 ? "Orderly" :
     regimeActivity > 0.55 ? "Active" :
     "Dormant"

float regimeIntensity =
     regimeState == "Dislocated" ? math.max(volatilityScore, dislocationScore) :
     regimeState == "Expansion" ? volatilityScore :
     regimeState == "Orderly" ? liquidityScore :
     regimeActivity

color regimeLaneColor =
     regimeState == "Dislocated" ? color.from_gradient(regimeIntensity, 0.0, 1.0, color.new(color.purple, 88), color.new(color.fuchsia, 5)) :
     regimeState == "Expansion" ? color.from_gradient(regimeIntensity, 0.0, 1.0, color.new(color.orange, 88), color.new(color.orange, 5)) :
     regimeState == "Active" ? color.from_gradient(regimeIntensity, 0.0, 1.0, color.new(color.yellow, 90), color.new(color.yellow, 12)) :
     regimeState == "Orderly" ? color.from_gradient(regimeIntensity, 0.0, 1.0, color.new(color.blue, 90), color.new(color.aqua, 18)) :
     color.new(color.gray, 86)

//=============================================================================
// SESSION-BASED CVD-LANE COORDINATE SYSTEM
//
// No viewport dependency.
// No fixed rolling lookback.
//
// The CVD envelope resets at:
//   UK open
//   US1 open
//   US2 open
//
// Each market block therefore gets its own CVD coordinate system.
//=============================================================================

float heldCvdLow = fixnan(l1)
float heldCvdHigh = fixnan(h1)

//-----------------------------------------------------------------------------
// SESSION DETECTION
// Defined locally so this block does not depend on the later
// SESSION BACKGROUNDS section.
//-----------------------------------------------------------------------------

bool laneUK = timeframe.isintraday and f_inWindow(UK_START, UK_END, "Europe/London")
bool laneUS1 = timeframe.isintraday and f_inWindow(US1_START, US1_END, "America/New_York")
bool laneUS2 = timeframe.isintraday and f_inWindow(US2_START, US2_END, "America/New_York")

bool laneUKOpen = laneUK and not laneUK[1]
bool laneUS1Open = laneUS1 and not laneUS1[1]
bool laneUS2Open = laneUS2 and not laneUS2[1]

bool laneSessionReset = laneUKOpen or laneUS1Open or laneUS2Open

//-----------------------------------------------------------------------------
// SESSION CVD ENVELOPE
//-----------------------------------------------------------------------------

var float sessionCvdLow = na
var float sessionCvdHigh = na

if laneSessionReset or na(sessionCvdLow) or na(sessionCvdHigh)
    sessionCvdLow := heldCvdLow
    sessionCvdHigh := heldCvdHigh
else
    if not na(heldCvdLow)
        sessionCvdLow := math.min(sessionCvdLow, heldCvdLow)

    if not na(heldCvdHigh)
        sessionCvdHigh := math.max(sessionCvdHigh, heldCvdHigh)

//-----------------------------------------------------------------------------
// SESSION SCALE
//-----------------------------------------------------------------------------

float localCvdRange = math.max(nz(heldCvdHigh - heldCvdLow), 0.0)
float smoothCvdRange = ta.ema(localCvdRange, 34)

float sessionCvdSpan = math.max(nz(sessionCvdHigh - sessionCvdLow), smoothCvdRange * 4.0)

float laneStep = math.max(
     sessionCvdSpan * 0.055,
     math.max(smoothCvdRange * 0.65, 1e-6)
)

// Slight separation from the lowest CVD level of the current session.
float laneCeiling = sessionCvdLow - laneStep * 0.35

float laneFlowY = laneCeiling - laneStep * 1.0
float laneResponseY = laneCeiling - laneStep * 2.0
float laneStructureY = laneCeiling - laneStep * 3.0
float laneRegimeY = laneCeiling - laneStep * 4.0

//-----------------------------------------------------------------------------
// FOUR LANES
//-----------------------------------------------------------------------------

plot(showFlowLanes ? laneCeiling : na, "Lane ceiling", color=color.new(color.gray, 90), linewidth=1, style=plot.style_stepline)

plot(showFlowLanes ? laneFlowY : na, "FLOW", color=flowLaneColor, linewidth=7, style=plot.style_stepline)
plot(showFlowLanes ? laneResponseY : na, "RESPONSE", color=responseLaneColor, linewidth=7, style=plot.style_stepline)
plot(showFlowLanes ? laneStructureY : na, "STRUCTURE", color=structureLaneColor, linewidth=7, style=plot.style_stepline)
plot(showFlowLanes ? laneRegimeY : na, "REGIME", color=regimeLaneColor, linewidth=7, style=plot.style_stepline)

//=============================================================================
// LAST-BAR STATE LABELS
//
// Labels are attached only to the current last bar.
// They no longer depend on the visible chart boundary.
//=============================================================================

f_stateLabel(label lb, int x, float y, string state, float intensity, color col) =>
    label.set_xy(lb, x, y)
    label.set_text(lb, state + "  " + str.tostring(int(math.round(clamp01(intensity) * 100.0))))
    label.set_color(lb, color.new(col, 84))
    label.set_textcolor(lb, color.new(col, 0))
    label.set_size(lb, size.small)

var label flowStateLabel = label.new(na, na, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left)
var label responseStateLabel = label.new(na, na, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left)
var label structureStateLabel = label.new(na, na, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left)
var label regimeStateLabel = label.new(na, na, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left)

if barstate.islast
    if showFlowLanes and showLaneStates
        f_stateLabel(flowStateLabel, bar_index, laneFlowY, flowState, flowLaneIntensity, flowLaneColor)
        f_stateLabel(responseStateLabel, bar_index, laneResponseY, responseState, responseIntensity, responseLaneColor)
        f_stateLabel(structureStateLabel, bar_index, laneStructureY, structureState, structureLaneIntensity, structureLaneColor)
        f_stateLabel(regimeStateLabel, bar_index, laneRegimeY, regimeState, regimeIntensity, regimeLaneColor)
    else
        label.set_text(flowStateLabel, "")
        label.set_text(responseStateLabel, "")
        label.set_text(structureStateLabel, "")
        label.set_text(regimeStateLabel, "")

//=============================================================================
// FLOW STATE METER
//
// LEFT            CENTER 21-CELL METER                     RIGHT
//
// FLOW       [==================▼==]                  Bullish 82%
// RESPONSE   [=============▼=======]                  Drive   67%
// STRUCTURE  [================▼====]                  Bullish 75%
// REGIME     [==============▼======]                  Active  69%
//
// Signed meters:
//   FLOW / STRUCTURE -> bearish <-- neutral --> bullish
//
// Intensity meters:
//   RESPONSE / REGIME -> low --> high
//=============================================================================

f_meterSigned(table t, int row, string laneName, float signedValue, float power, string state, color bearColor, color bullColor) =>
    float pos = clamp01((clamp11(signedValue) + 1.0) * 0.5)
    int idx = math.max(0, math.min(METER_SEGMENTS - 1, int(math.round(pos * float(METER_SEGMENTS - 1)))))

    table.cell(t, 0, row, laneName, text_color=color.rgb(220, 220, 235), bgcolor=METER_BG, text_size=size.small, width=5.0, text_halign=text.align_right)

    for i = 0 to METER_SEGMENTS - 1
        float p = float(i) / float(METER_SEGMENTS - 1)

        color cellBase =
             p <= 0.5 ? color.from_gradient(p, 0.0, 0.5, bearColor, METER_NEUTRAL) :
             color.from_gradient(p, 0.5, 1.0, METER_NEUTRAL, bullColor)

        bool marker = i == idx
        int alpha = marker ? 0 : math.min(78, 28 + int(math.round(math.abs(i - idx) * 4.0)))

        table.cell(t, i + 1, row, marker ? "▼" : "", bgcolor=color.new(cellBase, alpha), text_color=marker ? color.white : color.new(color.white, 100), width=1.45, height=1.05, text_size=size.small)

    color stateColor = signedValue > 0.06 ? bullColor : signedValue < -0.06 ? bearColor : color.silver
    string rightText = state + "  " + str.tostring(int(math.round(clamp01(power) * 100.0))) + "%"

    table.cell(t, METER_LAST_COL, row, rightText, text_color=stateColor, bgcolor=METER_BG, text_size=size.small, width=8.5, text_halign=text.align_left)

f_meterIntensity(table t, int row, string laneName, float intensity, string state, color stateColor) =>
    float val = clamp01(intensity)
    int idx = math.max(0, math.min(METER_SEGMENTS - 1, int(math.round(val * float(METER_SEGMENTS - 1)))))

    table.cell(t, 0, row, laneName, text_color=color.rgb(220, 220, 235), bgcolor=METER_BG, text_size=size.small, width=5.0, text_halign=text.align_right)

    for i = 0 to METER_SEGMENTS - 1
        float p = float(i) / float(METER_SEGMENTS - 1)

        color cellBase = color.from_gradient(p, 0.0, 1.0, METER_NEUTRAL, color.new(stateColor, 0))

        bool marker = i == idx
        int alpha = marker ? 0 : math.min(80, 30 + int(math.round(math.abs(i - idx) * 4.0)))

        table.cell(t, i + 1, row, marker ? "▼" : "", bgcolor=color.new(cellBase, alpha), text_color=marker ? color.white : color.new(color.white, 100), width=1.45, height=1.05, text_size=size.small)

    string rightText = state + "  " + str.tostring(int(math.round(val * 100.0))) + "%"

    table.cell(t, METER_LAST_COL, row, rightText, text_color=color.new(stateColor, 0), bgcolor=METER_BG, text_size=size.small, width=8.5, text_halign=text.align_left)

var table flowMeter = table.new(position.bottom_right, METER_SEGMENTS + 2, 6, bgcolor=METER_BG, border_width=0)

if barstate.islast
    table.clear(flowMeter, 0, 0, METER_LAST_COL, 5)

    if showFlowMeter
        table.merge_cells(flowMeter, 0, 0, METER_LAST_COL, 0)
        table.cell(flowMeter, 0, 0, " Flow State CVD  " + f_prettyTf(tf1), text_color=color.rgb(220, 220, 240), bgcolor=METER_BG, text_size=size.normal, text_halign=text.align_center)

        f_meterSigned(flowMeter, 1, "FLOW", flowLaneSigned, flowLaneIntensity, flowState, color.rgb(220, 35, 85), color.rgb(0, 205, 200))
        f_meterIntensity(flowMeter, 2, "RESP.", responseIntensity, responseState, responseLaneColor)
        f_meterSigned(flowMeter, 3, "STRUCT.", structureLaneSigned, structureLaneIntensity, structureState, color.rgb(220, 50, 80), color.rgb(0, 205, 220))
        f_meterIntensity(flowMeter, 4, "REGIME", regimeIntensity, regimeState, regimeLaneColor)

        table.merge_cells(flowMeter, 0, 5, METER_LAST_COL, 5)
        table.cell(flowMeter, 0, 5, "by Oberlunar  👁 ✦", text_color=color.rgb(170, 170, 195), bgcolor=METER_BG, text_size=size.normal, text_halign=text.align_right)



//=============================================================================
// SESSION BACKGROUNDS
//=============================================================================

bool ukPre = timeframe.isintraday and useUK and f_inWindow(UK_START - PREOPEN_MIN, UK_START, "Europe/London")
bool ukSession = timeframe.isintraday and useUK and f_inWindow(UK_START, UK_END, "Europe/London")

bool us1Pre = timeframe.isintraday and useUS1 and f_inWindow(US1_START - PREOPEN_MIN, US1_START, "America/New_York")
bool us1Session = timeframe.isintraday and useUS1 and f_inWindow(US1_START, US1_END, "America/New_York")

bool us2Pre = timeframe.isintraday and useUS2 and f_inWindow(US2_START - PREOPEN_MIN, US2_START, "America/New_York")
bool us2Session = timeframe.isintraday and useUS2 and f_inWindow(US2_START, US2_END, "America/New_York")

bool ukOpen = ukSession and not ukSession[1]
bool us1Open = us1Session and not us1Session[1]
bool us2Open = us2Session and not us2Session[1]

var float ukPreSum = 0.0
var float ukPrePeak = 0.0
var int ukPreCount = 0

var float us1PreSum = 0.0
var float us1PrePeak = 0.0
var int us1PreCount = 0

var float us2PreSum = 0.0
var float us2PrePeak = 0.0
var int us2PreCount = 0

var float ukSeed = 0.0
var float us1Seed = 0.0
var float us2Seed = 0.0

var int ukOpenTime = na
var int us1OpenTime = na
var int us2OpenTime = na

if ukPre and not ukPre[1]
    ukPreSum := 0.0
    ukPrePeak := 0.0
    ukPreCount := 0

if ukPre
    ukPreSum += liquidityScore
    ukPrePeak := math.max(ukPrePeak, liquidityScore)
    ukPreCount += 1

if ukOpen
    ukSeed := ukPreCount > 0 ? clamp01(0.65 * ukPreSum / float(ukPreCount) + 0.35 * ukPrePeak) : liquidityScore
    ukOpenTime := time

if us1Pre and not us1Pre[1]
    us1PreSum := 0.0
    us1PrePeak := 0.0
    us1PreCount := 0

if us1Pre
    us1PreSum += liquidityScore
    us1PrePeak := math.max(us1PrePeak, liquidityScore)
    us1PreCount += 1

if us1Open
    us1Seed := us1PreCount > 0 ? clamp01(0.65 * us1PreSum / float(us1PreCount) + 0.35 * us1PrePeak) : liquidityScore
    us1OpenTime := time

if us2Pre and not us2Pre[1]
    us2PreSum := 0.0
    us2PrePeak := 0.0
    us2PreCount := 0

if us2Pre
    us2PreSum += liquidityScore
    us2PrePeak := math.max(us2PrePeak, liquidityScore)
    us2PreCount += 1

if us2Open
    us2Seed := us2PreCount > 0 ? clamp01(0.65 * us2PreSum / float(us2PreCount) + 0.35 * us2PrePeak) : liquidityScore
    us2OpenTime := time

float ukPreProgress = ukPre ? f_windowProgress(UK_START - PREOPEN_MIN, UK_START, "Europe/London") : 0.0
float us1PreProgress = us1Pre ? f_windowProgress(US1_START - PREOPEN_MIN, US1_START, "America/New_York") : 0.0
float us2PreProgress = us2Pre ? f_windowProgress(US2_START - PREOPEN_MIN, US2_START, "America/New_York") : 0.0

float ukMinutes = ukSession and not na(ukOpenTime) ? (time - ukOpenTime) / 60000.0 : 0.0
float us1Minutes = us1Session and not na(us1OpenTime) ? (time - us1OpenTime) / 60000.0 : 0.0
float us2Minutes = us2Session and not na(us2OpenTime) ? (time - us2OpenTime) / 60000.0 : 0.0

float ukProgress = ukSession ? clamp01(ukMinutes / float(UK_END - UK_START)) : 0.0
float us1Progress = us1Session ? clamp01(us1Minutes / float(US1_END - US1_START)) : 0.0
float us2Progress = us2Session ? clamp01(us2Minutes / float(US2_END - US2_START)) : 0.0

float ukPreStrength = ukPre ? clamp01(ukPreProgress * (0.18 + 0.82 * liquidityScore)) : 0.0
float us1PreStrength = us1Pre ? clamp01(us1PreProgress * (0.18 + 0.82 * liquidityScore)) : 0.0
float us2PreStrength = us2Pre ? clamp01(us2PreProgress * (0.18 + 0.82 * liquidityScore)) : 0.0

float ukStrength = ukSession ? clamp01((0.20 + 0.80 * ukSeed) * (0.35 * math.exp(-2.15 * ukProgress) + 0.65 * math.exp(-1.80 * ukMinutes / math.max(1.0, float(orbMinutes))))) : 0.0
float us1Strength = us1Session ? clamp01((0.20 + 0.80 * us1Seed) * (0.35 * math.exp(-2.15 * us1Progress) + 0.65 * math.exp(-1.80 * us1Minutes / math.max(1.0, float(orbMinutes))))) : 0.0
float us2Strength = us2Session ? clamp01((0.20 + 0.80 * us2Seed) * (0.35 * math.exp(-2.15 * us2Progress) + 0.65 * math.exp(-1.80 * us2Minutes / math.max(1.0, float(orbMinutes))))) : 0.0

bgcolor(ukPre ? f_bgColor(ukColor, ukPreStrength) : ukSession ? f_bgColor(ukColor, ukStrength) : na, title="UK session")
bgcolor(us1Pre ? f_bgColor(us1Color, us1PreStrength) : us1Session ? f_bgColor(us1Color, us1Strength) : na, title="US1 session")
bgcolor(us2Pre ? f_bgColor(us2Color, us2PreStrength) : us2Session ? f_bgColor(us2Color, us2Strength) : na, title="US2 session")


//=============================================================================
// SESSION OPEN LABELS
//=============================================================================

plotshape(ukOpen, title="UK Open", style=shape.labeldown, location=location.top, color=color.new(ukColor, 100), text="UK", textcolor=ukColor, size=size.small)

plotshape(us1Open, title="US1 Open", style=shape.labeldown, location=location.top, color=color.new(us1Color, 100), text="US1", textcolor=us1Color, size=size.small)

plotshape(us2Open, title="US2 Open", style=shape.labeldown, location=location.top, color=color.new(us2Color, 100), text="US2", textcolor=us2Color, size=size.small)

//=============================================================================
// ACTIVE POLARIZED ABS / AAA ZONES
//=============================================================================

var array<box> activeBoxes = array.new<box>()
var array<float> activeTops = array.new<float>()
var array<float> activeBottoms = array.new<float>()
var array<int> activeSourceCloses = array.new<int>()
var array<bool> activeArmed = array.new<bool>()
var array<float> activeTfSecs = array.new<float>()
var array<int> activeClasses = array.new<int>()
var array<int> activeGapKinds = array.new<int>()

//=============================================================================
// REMOVE ACTIVE ZONE
//=============================================================================

f_removeZoneAt(int index, bool deleteVisual) =>
    bool removed = false

    if index >= 0 and index < array.size(activeBoxes)
        box bx = array.remove(activeBoxes, index)

        array.remove(activeTops, index)
        array.remove(activeBottoms, index)
        array.remove(activeSourceCloses, index)
        array.remove(activeArmed, index)
        array.remove(activeTfSecs, index)
        array.remove(activeClasses, index)
        array.remove(activeGapKinds, index)

        if deleteVisual and not na(bx)
            box.delete(bx)

        removed := true

    removed

//=============================================================================
// RETROSPECTIVE POLARIZED LIFECYCLE
//
// Bull:
//   arm only ABOVE
//   consume TOP -> BOTTOM
//
// Bear:
//   arm only BELOW
//   consume BOTTOM -> TOP
//
// A true jump through the complete zone does NOT mitigate it.
// It only disarms the structure until price establishes itself again on the
// semantically valid side.
//=============================================================================

f_retroPolarState(float originalTop, float originalBottom, int sourceClose, int scanBars, int polarity) =>
    float remainingTop = originalTop
    float remainingBottom = originalBottom

    bool armed = false
    bool done = false
    int doneTime = time_close

    for k = 0 to scanBars
        int j = scanBars - k

        bool eligible = not na(time[j]) and not na(sourceClose) and time[j] >= sourceClose

        if eligible and not done
            float bh = high[j]
            float bl = low[j]

            //=================================================================
            // BULLISH ZONE
            //=================================================================

            if polarity > 0
                if not armed
                    if bl > remainingTop
                        armed := true

                else
                    // Entire zone skipped downward: no mitigation.
                    if bh < remainingBottom
                        armed := false

                    // Valid return from above.
                    else if bl <= remainingTop and bh >= remainingBottom
                        if bl <= remainingBottom
                            done := true
                            doneTime := time_close[j]
                        else
                            remainingTop := math.max(remainingBottom, math.min(remainingTop, bl))

            //=================================================================
            // BEARISH ZONE
            //=================================================================

            else if polarity < 0
                if not armed
                    if bh < remainingBottom
                        armed := true

                else
                    // Entire zone skipped upward: no mitigation.
                    if bl > remainingTop
                        armed := false

                    // Valid return from below.
                    else if bh >= remainingBottom and bl <= remainingTop
                        if bh >= remainingTop
                            done := true
                            doneTime := time_close[j]
                        else
                            remainingBottom := math.min(remainingTop, math.max(remainingBottom, bh))

    [remainingTop, remainingBottom, armed, done, doneTime]

//=============================================================================
// MTF DE-DUPLICATION
//=============================================================================

f_hasHigherSameType(float newTfSec, float newTop, float newBottom, int newClass, int newGapKind) =>
    bool blocked = false
    int count = array.size(activeBoxes)

    if count > 0
        for i = 0 to count - 1
            float otherTf = array.get(activeTfSecs, i)
            float otherTop = array.get(activeTops, i)
            float otherBottom = array.get(activeBottoms, i)
            int otherClass = array.get(activeClasses, i)
            int otherKind = array.get(activeGapKinds, i)

            if otherTf > newTfSec and otherClass == newClass and otherKind == newGapKind and f_inside(newTop, newBottom, otherTop, otherBottom)
                blocked := true

    blocked

f_removeContainedLowerSameType(float newTfSec, float newTop, float newBottom, int newClass, int newGapKind) =>
    bool removedAny = false
    int count = array.size(activeBoxes)

    if count > 0
        for k = 0 to count - 1
            int i = count - 1 - k

            if i >= 0 and i < array.size(activeBoxes)
                float otherTf = array.get(activeTfSecs, i)
                float otherTop = array.get(activeTops, i)
                float otherBottom = array.get(activeBottoms, i)
                int otherClass = array.get(activeClasses, i)
                int otherKind = array.get(activeGapKinds, i)

                bool redundant = otherTf < newTfSec and otherClass == newClass and otherKind == newGapKind and f_inside(otherTop, otherBottom, newTop, newBottom)

                if redundant
                    bool removed = f_removeZoneAt(i, true)

                    if removed
                        removedAny := true

    removedAny

//=============================================================================
// LIVE POLARIZED LIFECYCLE
//=============================================================================

f_updateActiveZones() =>
    bool changed = false
    int count = array.size(activeBoxes)

    if count > 0
        for k = 0 to count - 1
            int i = count - 1 - k

            if i >= 0 and i < array.size(activeBoxes)
                box bx = array.get(activeBoxes, i)

                float zTop = array.get(activeTops, i)
                float zBottom = array.get(activeBottoms, i)

                int sourceClose = array.get(activeSourceCloses, i)
                bool armed = array.get(activeArmed, i)
                int cls = array.get(activeClasses, i)

                int polarity = cls > 0 ? 1 : -1

                box.set_right(bx, time_close)

                if not na(sourceClose) and time >= sourceClose

                    //=========================================================
                    // BULLISH ABS / AAA
                    //=========================================================

                    if polarity > 0
                        if not armed
                            // Valid departure: completely ABOVE.
                            if low > zTop
                                array.set(activeArmed, i, true)
                                changed := true

                        else
                            // True jump below entire residual zone.
                            // No mitigation. Re-arm is required from above.
                            if high < zBottom
                                array.set(activeArmed, i, false)
                                changed := true

                            // Valid return FROM ABOVE.
                            else if low <= zTop and high >= zBottom
                                if low <= zBottom
                                    box.set_right(bx, time_close)

                                    bool removed = f_removeZoneAt(i, false)

                                    if removed
                                        changed := true

                                else
                                    float newTop = math.max(zBottom, math.min(zTop, low))

                                    if newTop < zTop
                                        box.set_top(bx, newTop)
                                        array.set(activeTops, i, newTop)
                                        changed := true

                    //=========================================================
                    // BEARISH ABS / AAA
                    //=========================================================

                    else
                        if not armed
                            // Valid departure: completely BELOW.
                            if high < zBottom
                                array.set(activeArmed, i, true)
                                changed := true

                        else
                            // True jump above entire residual zone.
                            // No mitigation. Re-arm is required from below.
                            if low > zTop
                                array.set(activeArmed, i, false)
                                changed := true

                            // Valid return FROM BELOW.
                            else if high >= zBottom and low <= zTop
                                if high >= zTop
                                    box.set_right(bx, time_close)

                                    bool removed = f_removeZoneAt(i, false)

                                    if removed
                                        changed := true

                                else
                                    float newBottom = math.min(zTop, math.max(zBottom, high))

                                    if newBottom > zBottom
                                        box.set_bottom(bx, newBottom)
                                        array.set(activeBottoms, i, newBottom)
                                        changed := true

    changed

//=============================================================================
// EXHAUSTION EVENT CIRCLE
//=============================================================================

f_createExhaustionMarker(bool enabled, string refTf, int gapKind, int gapDir, float sourceHigh, float sourceLow, int sourceTime, int sourceTimeClose, float sourceAtr, int signalClass) =>
    bool created = false

    bool valid = enabled and showExhaustion and math.abs(signalClass) == 2 and gapDir != 0 and not na(sourceHigh) and not na(sourceLow) and not na(sourceTime) and not na(sourceTimeClose)

    if valid and barstate.isconfirmed and f_signalSessionEnabled(sourceTime, sourceTimeClose)
        int polarity = signalClass > 0 ? 1 : -1

        float baseOffset = not na(sourceAtr) and sourceAtr > 0.0 ? sourceAtr : math.max(sourceHigh - sourceLow, syminfo.mintick * 10.0)
        float offsetMult = gapKind == GAP_KIND_TIMEFIXED ? 0.20 : 0.34

        float markerY = polarity > 0 ? sourceLow - baseOffset * offsetMult : sourceHigh + baseOffset * offsetMult

        color markerColor = f_zoneColor(signalClass)

        string markerTooltip = f_prettyTf(refTf) + " Exh " + f_gapKindText(gapKind) + "\n" + f_directionText(signalClass)

        label.new(x=sourceTime, y=markerY, text="E", xloc=xloc.bar_time, yloc=yloc.price, color=color.new(markerColor, 80), style=label.style_circle, textcolor=color.white, size=size.small, tooltip=markerTooltip, force_overlay=true)

        created := true

    created

//=============================================================================
// GAP EVENT PROCESSOR
//=============================================================================

f_processSignal(bool enabled, string refTf, int gapKind, int gapDir, float gapSize, float sourceHigh, float sourceLow, int sourceTime, int sourceTimeClose, float sourceAtr, float referenceRange, int signalClass) =>
    bool created = false

    bool valid = enabled and gapDir != 0 and not na(gapSize) and gapSize > 0.0 and not na(sourceHigh) and not na(sourceLow) and not na(sourceTime) and not na(sourceTimeClose)

    if valid and barstate.isconfirmed
        int family = math.abs(signalClass)

        bool typeAllowed = f_classEnabled(signalClass)
        bool sessionAllowed = f_signalSessionEnabled(sourceTime, sourceTimeClose)

        //=====================================================================
        // EXHAUSTION -> EVENT ONLY
        //=====================================================================

        if family == 2 and typeAllowed and sessionAllowed
            bool markerCreated = f_createExhaustionMarker(true, refTf, gapKind, gapDir, sourceHigh, sourceLow, sourceTime, sourceTimeClose, sourceAtr, signalClass)

            if markerCreated
                created := true

        //=====================================================================
        // ABS / AAA -> PERSISTENT POLARIZED ZONE
        //=====================================================================

        else if (family == 1 or family == 3) and typeAllowed and sessionAllowed
            float tfSeconds = timeframe.in_seconds(refTf)
            int polarity = signalClass > 0 ? 1 : -1

            // CVD geometry controls opacity only.
            float gapStrength = not na(referenceRange) and referenceRange > 0.0 ? gapSize / (gapSize + referenceRange) : 0.0
            gapStrength := clamp01(gapStrength)

            float opacity = ZONE_MIN_OPACITY + gapStrength * (ZONE_MAX_OPACITY - ZONE_MIN_OPACITY)
            int transparency = int(math.round(100.0 - opacity))

            color baseColor = f_zoneColor(signalClass)
            color fillColor = color.new(baseColor, transparency)
            color borderColor = color.new(baseColor, 100)
            color textColor = color.new(baseColor, 5)

            int scanBars = int(math.min(4990.0, math.max(2.0, math.ceil(tfSeconds / math.max(1.0, chartSec)) + 3.0)))

            [remainingTop, remainingBottom, alreadyArmed, alreadyDone, doneTime] = f_retroPolarState(sourceHigh, sourceLow, sourceTimeClose, scanBars, polarity)

            // Already fully consumed before HTF confirmation -> no late box.
            if not alreadyDone
                bool hiddenByHigher = f_hasHigherSameType(tfSeconds, remainingTop, remainingBottom, signalClass, gapKind)

                if not hiddenByHigher
                    bool removedLower = f_removeContainedLowerSameType(tfSeconds, remainingTop, remainingBottom, signalClass, gapKind)

                    string firstLine = f_prettyTf(refTf) + " " + f_classText(signalClass) + " " + f_gapKindText(gapKind)
                    string secondLine = f_directionText(signalClass)
                    string boxText = firstLine + "\n" + secondLine

                    box newBox = box.new(left=sourceTime, top=remainingTop, right=time_close, bottom=remainingBottom, xloc=xloc.bar_time, border_color=borderColor, border_width=1, bgcolor=fillColor, text=boxText, text_color=textColor, text_size=size.small, text_halign=text.align_right, text_valign=text.align_center, force_overlay=true)

                    array.push(activeBoxes, newBox)
                    array.push(activeTops, remainingTop)
                    array.push(activeBottoms, remainingBottom)
                    array.push(activeSourceCloses, sourceTimeClose)
                    array.push(activeArmed, alreadyArmed)
                    array.push(activeTfSecs, tfSeconds)
                    array.push(activeClasses, signalClass)
                    array.push(activeGapKinds, gapKind)

                    created := true

    created

//=============================================================================
// UPDATE ACTIVE ZONES
//=============================================================================

bool zonesChanged = f_updateActiveZones()

//=============================================================================
// TIMEFIXED GAP EVENTS
//=============================================================================

bool tfCreated1 = f_processSignal(showTimeFixedGap, tf1, GAP_KIND_TIMEFIXED, tfDir1, tfSize1, srcPH1, srcPL1, srcT1, srcTC1, srcATR1, refR1, cls1)
bool tfCreated2 = f_processSignal(showTimeFixedGap and useTf2, tf2, GAP_KIND_TIMEFIXED, tfDir2, tfSize2, srcPH2, srcPL2, srcT2, srcTC2, srcATR2, refR2, cls2)
bool tfCreated3 = f_processSignal(showTimeFixedGap and useTf3, tf3, GAP_KIND_TIMEFIXED, tfDir3, tfSize3, srcPH3, srcPL3, srcT3, srcTC3, srcATR3, refR3, cls3)
bool tfCreated4 = f_processSignal(showTimeFixedGap and useTf4, tf4, GAP_KIND_TIMEFIXED, tfDir4, tfSize4, srcPH4, srcPL4, srcT4, srcTC4, srcATR4, refR4, cls4)
bool tfCreated5 = f_processSignal(showTimeFixedGap and useTf5, tf5, GAP_KIND_TIMEFIXED, tfDir5, tfSize5, srcPH5, srcPL5, srcT5, srcTC5, srcATR5, refR5, cls5)

//=============================================================================
// FVG EVENTS
//=============================================================================

bool fvgCreated1 = f_processSignal(showFvgCvd, tf1, GAP_KIND_FVG, fvgDir1, fvgSize1, srcPH1, srcPL1, srcT1, srcTC1, srcATR1, refR1, cls1)
bool fvgCreated2 = f_processSignal(showFvgCvd and useTf2, tf2, GAP_KIND_FVG, fvgDir2, fvgSize2, srcPH2, srcPL2, srcT2, srcTC2, srcATR2, refR2, cls2)
bool fvgCreated3 = f_processSignal(showFvgCvd and useTf3, tf3, GAP_KIND_FVG, fvgDir3, fvgSize3, srcPH3, srcPL3, srcT3, srcTC3, srcATR3, refR3, cls3)
bool fvgCreated4 = f_processSignal(showFvgCvd and useTf4, tf4, GAP_KIND_FVG, fvgDir4, fvgSize4, srcPH4, srcPL4, srcT4, srcTC4, srcATR4, refR4, cls4)
bool fvgCreated5 = f_processSignal(showFvgCvd and useTf5, tf5, GAP_KIND_FVG, fvgDir5, fvgSize5, srcPH5, srcPL5, srcT5, srcTC5, srcATR5, refR5, cls5)

//=============================================================================
// DATA VALIDATION
//=============================================================================

[baseOpen, baseHigh, baseLow, baseClose] = ta.requestVolumeDelta(baseLtf, anchorInput)

var float cumulativeVolumeCheck = 0.0
cumulativeVolumeCheck += nz(volume)

bool baseDeltaNa = na(baseOpen) and na(baseHigh) and na(baseLow) and na(baseClose)

if barstate.islast
    if cumulativeVolumeCheck == 0.0
        runtime.error("The data vendor does not provide volume data for this symbol.")

    if useTicks and baseDeltaNa
        runtime.error("Not enough tick depth for the current CVD anchor. Shorten the Anchor period or switch Data aggregation to Time.")




//=============================================================================
// 4-STATE COMPOSITE LONG / SHORT SIGNAL
//
// FLOW + RESPONSE + STRUCTURE provide directional information.
// REGIME modulates confidence/quality rather than imposing direction.
//
// Output:
//   compositeSignal > adaptive threshold  -> LONG
//   compositeSignal < -adaptive threshold -> SHORT
//
// The signal is rendered directly on price through an EMA(7):
//   aqua/green = bullish
//   red        = bearish
//   brightness = composite signal intensity
//=============================================================================

//-----------------------------------------------------------------------------
// DIRECTIONAL CORE
//-----------------------------------------------------------------------------

float compositeDirectional =
     clamp11(
         0.36 * flowLaneSigned +
         0.34 * responseSigned +
         0.30 * structureLaneSigned
     )

//-----------------------------------------------------------------------------
// CROSS-LAYER COHERENCE
//
// If FLOW / RESPONSE / STRUCTURE agree, their weighted signed sum is close
// to their total directional mass.
// If they conflict, coherence contracts toward zero.
//-----------------------------------------------------------------------------

float directionalMass =
     0.36 * math.abs(flowLaneSigned) +
     0.34 * math.abs(responseSigned) +
     0.30 * math.abs(structureLaneSigned)

float directionalCoherence =
     directionalMass > 0.0001 ?
     clamp01(math.abs(compositeDirectional) / directionalMass) :
     0.0

//-----------------------------------------------------------------------------
// REGIME QUALITY
//
// REGIME is intentionally non-directional.
// High liquidity/activity strengthens the composite.
// Dislocation and structural noise reduce confidence.
//-----------------------------------------------------------------------------

float regimeQuality =
     clamp01(
         0.30 +
         0.30 * regimeIntensity +
         0.30 * liquidityScore +
         0.15 * (1.0 - noiseScore) -
         0.25 * dislocationScore
     )

//-----------------------------------------------------------------------------
// FINAL COMPOSITE
//
// Coherence and regime operate as confidence multipliers.
// They cannot reverse the directional core.
//-----------------------------------------------------------------------------

float compositeSignal =
     clamp11(
         compositeDirectional *
         (0.50 + 0.50 * directionalCoherence) *
         (0.50 + 0.50 * regimeQuality)
     )

//-----------------------------------------------------------------------------
// ADAPTIVE DECISION THRESHOLD
//
// No user tuning.
// Noisy/dislocated environments require stronger four-state agreement.
//-----------------------------------------------------------------------------

float compositeThreshold =
     0.16 +
     0.10 * noiseScore +
     0.07 * dislocationScore

bool longSignal = compositeSignal >= compositeThreshold
bool shortSignal = compositeSignal <= -compositeThreshold

//-----------------------------------------------------------------------------
// SIGNAL INTENSITY
//
// 0 = just crossed the adaptive threshold
// 1 = maximum composite conviction
//-----------------------------------------------------------------------------

float signalAbs = math.abs(compositeSignal)

float signalIntensity =
     longSignal or shortSignal ?
     clamp01(
         (signalAbs - compositeThreshold) /
         math.max(1.0 - compositeThreshold, 0.01)
     ) :
     0.0

//-----------------------------------------------------------------------------
// EMA 7 PRICE SIGNAL
//-----------------------------------------------------------------------------

float compositeEMA7 = ta.ema(close, 7)

color longWeak = color.new(color.rgb(0, 190, 165), 78)
color longStrong = color.rgb(0, 255, 210)

color shortWeak = color.new(color.rgb(190, 25, 55), 78)
color shortStrong = color.rgb(255, 30, 65)

color compositeMAColor =
     longSignal ?
     color.from_gradient(signalIntensity, 0.0, 1.0, longWeak, longStrong) :
     shortSignal ?
     color.from_gradient(signalIntensity, 0.0, 1.0, shortWeak, shortStrong) :
     color.new(color.gray, 88)

plot(compositeEMA7, "4-State Composite EMA 7", color=compositeMAColor, linewidth=3, force_overlay=true)
````
