# NY Session Conviction Dashboard

- url: https://www.tradingview.com/script/8lbALTHB-NY-Session-Conviction-Dashboard/
- type: indicator
- pine_id: PUB;436f89eace1a4fb9a385270f6cafb085
- version: 1.0

## Description

Overview
The NY Session Conviction Dashboard is a comprehensive market-state engine designed specifically for intraday futures traders (ES/NQ) executing during the New York session. Rather than generating lagging, automated buy/sell signals, this tool functions as a professional tape-reading companion. It provides a real-time, statistical framework to assess institutional conviction, market efficiency, and volume participation when price tests critical structural levels like Prior Day High/Low (PDH/PDL), Overnight High/Low (ONH/ONL), and Session VWAP.

By applying a Wyckoff-inspired Effort vs. Result model, the script evaluates whether current order flow supports a structural breakout/continuation or a structural fading/rejection.

Core Architecture & Components
1. Intraday Effort (Market Internals Engine)
Dual Index VOLD Ratios: Tracks institutional volume deployment by calculating the dynamic ratio of advancing vs. declining volume for both the NYSE (USI:UVOL/USI:DVOL) and NASDAQ (USI:UVOLQ/USI:DVOLQ).

NYSE TICK Integration: Samples centralized order flow momentum to confirm whether sudden price spikes are supported by broad market buying/selling.

2. Intraday Result (Structural Efficiency & Pressure)
Kaufman-Driven Adaptive KAMA: Uses an Efficiency Ratio (ER) lookback to dynamically adjust its smoothing factor. It remains flat during erratic, noisy balance areas and turns sharply directional when true algorithmic expansion occurs.

Session VWAP with ER Stabilization: Resets precisely at the NY Open (0930 EST). Features a unique initial-hour "Stabilization Event Box" based on Early Session efficiency to protect against choppy opening balancing behaviors.

Candle Pressure Index (CPI): Measures the precision of close location relative to a bar's total range, filtered through an ATR noise gate to eliminate low-liquidity anomalies.

3. Institutional Absorption Detection
Plots discrete, real-time exhaustion markers (X) directly on the chart when high-effort internal signatures (VOLD extremes/TICK spikes) fail to yield a directional result—classically signaling institutional absorption or passive resting liquidity behavior.

Understanding the Tape Reading States
The dashboard dynamically computes and displays the mathematical harmony between broad market internals and current price action, classifying the market into distinct behavioral regimes:

BULL ALIGN / BEAR ALIGN (Golden State): Full harmony. Internals, Volume Ratios, TICK, CPI, and Trend Efficiency are aligned aggressively in one direction. High-conviction expansion.

BULL DIV / BEAR DIV (Price Divergence): Price is flat or declining, but broad market internals are heavily positive (or vice-versa). Often leads to a sudden catch-up expansion or rotational reversal.

BULL ABSORB / BEAR ABSORB: High internal volume effort is actively hitting the market, but the price trend efficiency is exceptionally low (ER < 0.30). This points to major passive limit orders blocking further progression.

LEAD DIV (Leadership Divergence): NYSE and NASDAQ volume structures are actively opposing one another, indicating a split, rotation-heavy market profile.

How to Use This Tool
This indicator is built for discretionary execution support.

Identify Your Levels Manually: Map out your key price boundaries (PDH, PDL, Daily VWAP, or high-volume nodes).

Watch the Test: As price approaches a level, look down at the Tape Dashboard.

Verify Conviction: * A breakout past PDH accompanied by a BULL ALIGN state implies high-probability continuation.

A test of PDH accompanied by a BEAR ABSORB or BEAR DIV state indicates a structural failure, offering a high-probability mean-reversion setup back to VWAP.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © immediatePerso44773

//@version=6
indicator("NY Session Conviction Dashboard", shorttitle = "NY Conviction", overlay = true)

//=============================================================================
// SCRIPT OVERVIEW
//=============================================================================
//
// Name:
//     An ER KAMA and Session VWAP
//
// Purpose:
//
// Provide a statistical assessment of market conviction,
// participation, efficiency, and directional pressure during
// the New York session.
//
// The indicator is intended to assist discretionary traders
// when evaluating manually identified reference levels such
// as PDH, PDL, PDVAH, PDVAL, ONH, ONL, and the New York Open.
//
// Rather than generating automatic buy or sell signals,
// the indicator combines NY session VWAP reset, Adaptive KAMA,
// Efficiency Ratio, Market Internals, CPI, and Adaptive Conviction 
// Momentum analysis to help determine whether current market 
// conditions support acceptance, rejection, or continuation 
// through a key price level.
//
// Core Components:
//
//     1. Session VWAP
//          Measures intraday fair value.
//
//     2. Adaptive KAMA
//          Trend filter controlled by Efficiency Ratio.
//
//     3. Candle Pressure Index (CPI)
//          Measures where price closes inside a candle.
//
//     4. Market Internals
//          NYSE VOLD
//          NASDAQ VOLD
//          NYSE TICK
//
//     5. Effort vs Result Framework
//          Effort:
//              NYSE/NASDAQ Volume Ratios
//              TICK
//           Result:
//               CPI
//               ER
//               VWAP Trend
//               KAMA Trend
//               Two-Bar Trens Momentum
//
//     6. Hybrid State Machine
//          Determines market readiness.
//
//    7. Tape Reading Dashboard

//        Provides a Wyckoff-inspired effort-versus-result assessment
//        of current market conditions using internals, efficiency,
//        momentum, and trend alignment to help evaluate acceptance
//        or rejection at manually drawn key price levels.
//
// Designed For:
//
//     ES Futures
//     NQ Futures
//     New York Session Trading
//
//=============================================================================
// ————— Dashboard Display Settings —————
grp_table = "Dashboard Table Settings"
tablePos  = input.string("Bottom Right", "Table Position", 
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left", "Middle Center"], 
     tooltip = "Dashboard locaction", group = grp_table)

// ————— Session VWAP Settings—————
grp_vwap        = "Session VWAP Settings"
sessionInput    = input.session("0930-1600", "Trading Session", 
     tooltip = "Session used for VWAP reset and internals.",
     group = grp_vwap)
src             = input(hlc3, "Source", tooltip = "Price source used in VWAP calculations.", group=grp_vwap)
vwap_len        = input.int(15, "VWAP ER Length", 
     tooltip = "ER lookback for VWAP trend efficiency.(1 min 15, 5 min 20)",
     group = grp_vwap)
vwap_ER_Smooth  = input.int(3, "VWAP ER Smoothing Length", 
     tooltip = "Smoothing applied to VWAP ER (1 min 3, 5 min 4).",
     group = grp_vwap)

// ————— Adaptive KAMA Settings —————
grp_KAMA      = "Adaptive KAMA Settings"
KAMAerLen     = input.int(21,"KAMA ER Length", 
     tooltip = "ER lookback controlling KAMA adaptation (1 min 15, 5 min 24).",  
     group = grp_KAMA)
KAMAerSmooth  = input.int(3, "KAMA ER Smoothing Length", 
     tooltip = "Smoothing applied to KAMA ER(1 min 3, 5 min 4).",
     group= grp_KAMA)
minLen        = input.int(2, "KAMA Fast Length", 
     tooltip = "Fastest KAMA response.",
     group = grp_KAMA)
maxLen        = input.int(34, "KAMA Slow Length", 
     tooltip = "Slowest KAMA response (1 min 21, 5 min 34).", 
     group = grp_KAMA)

// ————— Market Internals (Effort) Settings —————
grp_int     = "Market Internals (Effort) Settings"
voldThresh  = input.float(2.0, "VOLD Ratio Threshold (e.g. 2:1)", 
     tooltip = "Volume dominance threshold.", group=grp_int)
tickThresh  = input.int(600, "TICK Threshold", 
     tooltip = "NYSE TICK confirmation threshold.", group=grp_int)

// ————— CPI & Efficiency (Result) Settings —————
grp_cpi     = "CPI & Efficiency (Result) Settings"
minRangePoints = input.int(5, "Min Range Noise Gate (Ticks)", minval=0, 
     tooltip = "Ignore candles smaller than this range.", group=grp_cpi)
erMin       = input.float(0.4, "Min Efficiency (ER)", 
     tooltip = "Minimum ER required for trend confirmation.", group=grp_cpi)
cpiThresh   = input.float(0.5, "CPI Pressure Threshold", 
     tooltip = "Minimum CPI required for pressure confirmation.", group=grp_cpi)

atr_norm = ta.atr(14)
var int sessionBars = 0
int tfSec = timeframe.in_seconds()

enum CandleDir 
    BULL
    BEAR
    NEUTRAL

enum CloseZone
    LOWER
    MIDDLE
    UPPER

enum RangeRel
    INSIDE
    OUTSIDE

chosenPosition = switch tablePos

    "Top Right"     => position.top_right
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Middle Right"  => position.middle_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    => position.bottom_right // Fallback default

timeVariable   = ta.change(time("D", "", "America/New_York"))
bool isNewDay = ta.change(timeVariable) != 0 and not na(timeVariable)
inSession = bool(time(timeframe.period, sessionInput, "America/New_York"))
firstMarketBar = inSession and (not inSession[1] or isNewDay)

if firstMarketBar

    sessionBars := 1

else if inSession

    sessionBars += 1

else

    sessionBars := 0

f_er(src, len) =>

    net  = math.abs(src - src[len])
    move = math.sum(math.abs(src - src[1]), len)

    move > 0 ? net / move : 0.0

f_dir(o, c) => 

     c > o ? CandleDir.BULL : 
     c < o ? CandleDir.BEAR : CandleDir.NEUTRAL

f_closeZone(h, l, c) =>

    rng = h - l
    upper = l + rng * 2.0 / 3.0
    lower = l + rng * 1.0 / 3.0
    c >= upper ? CloseZone.UPPER : c <= lower ? CloseZone.LOWER : CloseZone.MIDDLE

f_rangeRel(c, ph, pl) => 

    if (c > ph or c < pl)

        RangeRel.OUTSIDE

    else

        RangeRel.INSIDE

f_bodyScore(dir, zone, o, c, h, l) =>

    rng = h - l

    bodyRatio =
         rng == 0 ? 0 :
         math.abs(c - o) / rng

    strength =
         rng == 0 ? 0 :
         bodyRatio >= 0.66 ? 2 :
         bodyRatio >= 0.33 ? 1 : 0

    dir == CandleDir.BULL ? strength :
     dir == CandleDir.BEAR ? -strength :
     0

f_candleScore(dir, zone) =>

    switch dir

        CandleDir.BULL =>
            zone == CloseZone.UPPER ? 2 :
             zone == CloseZone.MIDDLE ? 1 : 0

        CandleDir.BEAR =>
            zone == CloseZone.LOWER ? 2 :
             zone == CloseZone.MIDDLE ? 1 : 0

        CandleDir.NEUTRAL =>
            0

// Prior candle
d1 = f_dir(open[1], close[1])
z1 = f_closeZone(high[1], low[1], close[1])
s1 = f_candleScore(d1, z1) + f_bodyScore(d1, z1, open[1], close[1], high[1], low[1])

// Current candle
d0 = f_dir(open, close)
z0 = f_closeZone(high, low, close)
s0 = f_candleScore(d0, z0) + f_bodyScore(d0, z0, open, close, high, low)
rel = f_rangeRel(close, high[1], low[1])  
currDir =
     close > open ? 1 :
     close < open ? -1 :
     0
directionalRScore = 
      rel == RangeRel.OUTSIDE ? (2 * currDir) : 0
float barRange = high - low
rangeWeight =
     not na(atr_norm) and atr_norm > 0
     ? math.min(barRange / atr_norm, 2.0)
     : 1.0

finalScore = (s1 + s0 + directionalRScore) * rangeWeight

scoreSlope =

     ta.linreg(finalScore, 5, 0) -  ta.linreg(finalScore, 5, 1)

scoreER =
     nz(f_er(finalScore, 5), 0)

Slopeadaptive =

     scoreSlope * scoreER
     
var float cumPV = 0.0
var float cumV  = 0.0

if firstMarketBar

    cumPV := hlc3 * volume
    cumV  := volume

else if inSession

    cumPV += hlc3 * volume
    cumV  += volume

else

    cumPV := 0.0
    cumV  := 0.0

var float vwapValue = na

vwapValue :=
     inSession and cumV > 0
     ? cumPV / cumV
     : na

vwapEfficiency =
     ta.ema(f_er(vwapValue, vwap_len), vwap_ER_Smooth)

chart_Based_Lookback =
     tfSec <= 60 ? 3 :
     tfSec <= 300 ? 5 :
     tfSec <= 900 ? 8 :
     12

vwapSlopeStrength = atr_norm > 0
     ? (vwapValue - vwapValue[chart_Based_Lookback]) / atr_norm
     : 0.0

//━━━━━━━━━━━━━━━ SESSION-AWARE INITIALIZATION ━━━━━━━━━━━━━━━//
usingER = 
      sessionBars >= vwap_len + vwap_ER_Smooth
vwapER = 
      usingER ? vwapEfficiency : na

stdvwapSlope = 
      ta.stdev(vwapSlopeStrength, 20)

slopeDev = sessionBars > 20
     ? stdvwapSlope
     : na

slopeThreshold = 
      math.max(slopeDev * 0.5, 0.15)

trendBull = usingER and
     not na(slopeDev) and
     vwapSlopeStrength > slopeThreshold and
     vwapER > 0.30

trendBear = usingER and
     not na(slopeDev) and
     vwapSlopeStrength < -slopeThreshold and
     vwapER > 0.30

//━━━━━━━━━━━━━━━ ER STABILIZATION EVENT ━━━━━━━━━━━━━━━//
erTransition = sessionBars == (vwap_len + vwap_ER_Smooth)
//━━━━━━━━━━━━━━━━━━━ VWAP Transistion Marker ━━━━━━━━━━━━━━━━━━━//
er = 
      ta.ema(f_er(close, vwap_len), vwap_ER_Smooth)

//━━━━━━━━ VWAP ER Initialization Zone ━━━━━━━━━//
var box executionBox = na

erColor =
     er > 0.5  ? color.new(color.green,90) :
     er < 0.2  ? color.new(#cb0526,90) :
     color.new(color.orange,85)

if erTransition

    box.delete(executionBox)

    executionBox := box.new(left = bar_index,
         right = bar_index + 60, top = vwapValue + atr_norm * 0.5,
         bottom = vwapValue - atr_norm * 0.5, border_width = 2,
         bgcolor = erColor, border_color = erColor)

//━━━━━━━━━━━━━━━━━━━ ADAPTIVE KAMA ENGINE ━━━━━━━━━━━━━━━━━━━//
fastSC = 2.0 / (minLen + 1)
slowSC = 2.0 / (maxLen + 1)

//━━━━━━━━━━━ Adaptive smoothing after initialization ━━━━━━━━━━━//
ER_KAMAerLen = ta.ema(f_er(close, KAMAerLen), KAMAerSmooth)
adaptiveSC   = math.pow(ER_KAMAerLen * (fastSC - slowSC) + slowSC, 2)
var float adaptiveKAMA = na

adaptiveKAMA := na(adaptiveKAMA[1]) ? close
     : adaptiveKAMA[1] + adaptiveSC * (close - adaptiveKAMA[1])

//━━━━━━━━━━━━━━━━━━━ KAMA Directional State ━━━━━━━━━━━━━━━━━━━//
kamaDelta = adaptiveKAMA - adaptiveKAMA[1]
kamaBull  = kamaDelta > 0 and ER_KAMAerLen > 0.30
kamaBear  = kamaDelta < 0 and ER_KAMAerLen > 0.30

//━━━━━━━━━━━━━━━━━━━ KAMA Colors ━━━━━━━━━━━━━━━━━━━//
color kamaLine_Color = color.gray

if kamaBull

    kamaLine_Color := color.new(color.green, 20)

else if kamaBear

    kamaLine_Color := color.new(#cb0526, 20)

plot(adaptiveKAMA, "KAMA", color = kamaLine_Color,
     linewidth = 2,  
     style = plot.style_line, 
     linestyle = plot.linestyle_dashed)

//━━━━━━━━━━━━━━━━━━━ CPI ENGINE ━━━━━━━━━━━━━━━━━━━//
isGated = barRange < (minRangePoints * syminfo.mintick)

cpi = barRange != 0 and not isGated ? (2 * close - high - low) / barRange : 0.0

//━━━━━━━━━━━━━━━ Early Session Fallback ━━━━━━━━━━━━━━━//
earlyBull =

     inSession and
     close > vwapValue and
     sessionBars >= 5 and
     cpi > 0.25

earlyBear =

     inSession and
     close < vwapValue and
     sessionBars >= 5 and
     cpi < -0.25

//━━━━━━━━━━━━━━━━━━━ HYBRID STATE MACHINE ━━━━━━━━━━━━━━━━━━━//
bullState = usingER ? trendBull : earlyBull
bearState = usingER ? trendBear : earlyBear

//━━━━━━━━━━━━━━━━━━━ VWAP Visual State Colors ━━━━━━━━━━━━━━━━━━━//
color Above = color.gray
float KAMA_VWAP = adaptiveKAMA - vwapValue

if inSession

    if bullState and close > vwapValue

        Above := color.new(color.green, 20)

    else if bearState and close < vwapValue

        Above := color.new(#cb0526, 20)

    else

        Above := color.gray

plot(inSession ? vwapValue : na, 
     title = "Session VWAP", 
     style = plot.style_linebr, 
     color = Above, 
     linewidth = 1)

//━━━━━━━━━━━━━━━━━━━ MARKET INTERNALS ENGINE ━━━━━━━━━━━━━━━━━━━//
uvol_ny    = request.security("USI:UVOL", timeframe.period, close, lookahead = barmerge.lookahead_off)
dvol_ny    = request.security("USI:DVOL", timeframe.period, close, lookahead = barmerge.lookahead_off)
uvol_nq    = request.security("USI:UVOLQ", timeframe.period, close, lookahead = barmerge.lookahead_off)
dvol_nq    = request.security("USI:DVOLQ", timeframe.period, close, lookahead = barmerge.lookahead_off)
tick_close = request.security("USI:TICK.US", timeframe.period, close, lookahead = barmerge.lookahead_off)

calc_ratio(u, d) =>

    (d == 0 or u == 0) ? 0 :
     u >= d ? (u / d) : -(d / u)

ny_ratio = calc_ratio(uvol_ny, dvol_ny)
nq_ratio = calc_ratio(uvol_nq, dvol_nq)

upperWick     = high - math.max(open, close)
lowerWick     = math.min(open, close) - low
bodySize      = math.abs(close - open)
effectiveBody = math.max(bodySize, atr_norm * 0.05)

bullAbsorption =

     inSession and
     er < erMin and
     lowerWick > effectiveBody * 1.5 and
     close > low + barRange * 0.4

bearAbsorption =

     inSession and
     er < erMin and
     upperWick > effectiveBody * 1.5 and
     close < high - barRange * 0.4

bullAbsorptionStrong =

     bullAbsorption and
     (tick_close > 300 or ny_ratio > 2)

bearAbsorptionStrong =

     bearAbsorption and
     (tick_close < -300 or ny_ratio < -2)

//━━━━━━━━━━━━━━━━━━━ Visuals for Defined Absorption Bias ━━━━━━━━━━━━━━━━━━━//
plotshape(bearAbsorptionStrong, "Bear Absorption", 
    style = shape.xcross, 
    location = location.abovebar, 
    color = #cb0526, 
    size=size.tiny)

plotshape(bullAbsorptionStrong, "Bull Absorption", 
    style = shape.xcross, 
    location = location.belowbar, 
    color = color.green, 
    size=size.tiny)

//━━━━━━━━━━━━━━━━━━━ Combined CPI with Internals for Bias ━━━━━━━━━━━━━━━━━━━//

strongConflict =

     math.sign(ny_ratio) != math.sign(nq_ratio) and
     math.abs(ny_ratio) > 1.5 and
     math.abs(nq_ratio) > 1.5

vwapDirection =

     vwapSlopeStrength > 0 ? 1 :
     vwapSlopeStrength < 0 ? -1 :
     0

internalScore =

     ny_ratio * 0.30 + nq_ratio * 0.70

internalDirection =

     internalScore > 0 ? 1 :
     internalScore < 0 ? -1 :
     0

effortResultDiv =

     math.abs(ny_ratio) > 1.5 and
     math.abs(nq_ratio) > 1.5 and
     er < 0.30

bool Bull_CPI_VOLD_TICK_ER = 

      cpi >= cpiThresh and (ny_ratio > 1 or tick_close > tickThresh * 0.5) and er >= erMin

bool Bear_CPI_VOLD_TICK_ER = 

      cpi <= -cpiThresh and (ny_ratio < -1 or tick_close < tickThresh * 0.5) and er >= erMin

//━━━━━━━━━━━━━━━━━━━ State Engine ━━━━━━━━━━━━━━━━━━━//
bullReady =

     Bull_CPI_VOLD_TICK_ER and trendBull and
     kamaBull and finalScore >= 2

bearReady =

     Bear_CPI_VOLD_TICK_ER and  trendBear and
     kamaBear and finalScore <= -2

//━━━━━━━━ MARKET STATE ENGINE ━━━━━━━━//
bool goldenLong =

     Bull_CPI_VOLD_TICK_ER and
     nq_ratio > 1.0 and
     ny_ratio > 1.0

bool goldenShort =

     Bear_CPI_VOLD_TICK_ER and
     nq_ratio < -1.0 and
     ny_ratio < -1.0

bool leadershipDiv =

     math.sign(ny_ratio) != math.sign(nq_ratio)

bool priceDivBull =

     internalDirection > 0 and
     vwapDirection <= 0

bool priceDivBear =

     internalDirection < 0 and
     vwapDirection >= 0

bool effortResultDivBull =

     ny_ratio > 1.5 and
     nq_ratio > 1.5 and
     er < 0.30

bool effortResultDivBear =

     ny_ratio < -1.5 and
     nq_ratio < -1.5 and
     er < 0.30

bool neutralState =

     not goldenLong and
     not goldenShort and
     not leadershipDiv and
     not priceDivBull and
     not priceDivBear and
     not effortResultDivBull and
     not effortResultDivBear

//━━━━━━━━━━━━━━━━━━━ TAPE READING DASHBOARD ━━━━━━━━━━━━━━━━━━━//
var table tape = table.new(chosenPosition,
     4,      // Metric + 3 history columns
     8,      // Header + 8 data rows
     bgcolor = color.new(color.black, 70),
     border_width = 1)

//━━━━━━━━━━━━━━━━━━━ GOLDEN ALIGNMENT VISUALS ━━━━━━━━━━━━━━━━━━━//
headerColor =

     not inSession ? color.gray :
     goldenLong          ? color.green :
     goldenShort         ? color.red :
     leadershipDiv       ? color.purple :
     priceDivBull        ? color.new(color.green, 30) :
     priceDivBear        ? color.new(color.red, 30) :
     effortResultDivBull ? color.teal :
     effortResultDivBear ? color.orange :
     color.gray


headerText =

     not inSession ? "OVERNIGHT" :
     goldenLong ? "BULL ALIGN" :
     goldenShort ? "BEAR ALIGN" :
     leadershipDiv ? "LEAD DIV" :
     priceDivBull ? "BULL DIV" :
     priceDivBear ? "BEAR DIV" :
     effortResultDivBull ? "BULL ABSORB" :
     effortResultDivBear ? "BEAR ABSORB" :
     "NEUTRAL"

f_get_ui_size(score) =>

    score >= 5 ? size.huge :
     score >= 4 ? size.large :
     score >= 3 ? size.normal :
     score >= 2 ? size.small :
     size.tiny

stateScore =

     goldenLong or goldenShort ? 5 :
     bullReady or bearReady ? 4 :
     leadershipDiv ? 3 :
     priceDivBull or priceDivBear ? 2 :
     effortResultDivBull or effortResultDivBear ? 1 :
     0

headerSize = f_get_ui_size(stateScore)

var labels = array.from(
     "NASD VOLD","NYSE VOLD",
     "TICK", "PRICE ER", "CPI %", 
     "SCORED MOMENTUM", "KAMA-VWAP")

f_histCell(table tbl, int col,
           int row, string txt,
           color txtColor, color bgColor,
           text_size) =>

    table.cell(tbl, col, row, txt,
         text_color = txtColor,
         bgcolor = bgColor,
         text_size = text_size)

if barstate.islast

    //━━━━━━━━ HEADER ━━━━━━━━
    table.cell(tape, 0, 0, "METRIC",
         bgcolor = color.black,
         text_color = color.white)

    table.cell(tape, 1, 0, "BAR-2",
         bgcolor = color.black,
         text_color = color.white)

    table.cell(tape, 2, 0, "BAR-1",
         bgcolor = color.black,
         text_color = color.white)

    table.cell(tape, 3, 0, headerText,
          bgcolor = headerColor,
          text_color = color.white,
          text_size = headerSize)

    //━━━━━━━━ ROW LABELS ━━━━━━━━
    for row = 0 to array.size(labels) - 1

        table.cell(tape, 0, row + 1,
             array.get(labels, row),
             text_color = color.white)

    //━━━━━━━━ HISTORY DATA ━━━━━━━━
    for i = 0 to 2

        idx = 2 - i

        goldBg =
          goldenLong[idx] ?
          color.new(color.green, 80) :
          goldenShort[idx] ?
          color.new(color.red, 65) :
          na

        // NASD VOLD
        f_histCell(tape, i + 1, 1,  str.tostring(nq_ratio[idx], "#.##"),
             nq_ratio[idx] >= voldThresh ?
                  color.lime :
             nq_ratio[idx] <= -voldThresh ?
                  color.rgb(248, 7, 63) :
                  color.white,
             goldBg, size.normal)
             
        // NYSE VOLD
        f_histCell(tape, i + 1, 2, str.tostring(ny_ratio[idx], "#.##"),
             ny_ratio[idx] >= voldThresh ?
             color.lime :
             ny_ratio[idx] <= -voldThresh ?
             color.rgb(248, 7, 63) :
             color.white,
             na,
            headerSize)

        // TICK
        f_histCell(tape, i + 1, 3, str.tostring(tick_close[idx], "#"),
             tick_close[idx] >= tickThresh ?
                  color.lime :
             tick_close[idx] <= -tickThresh ?
                  color.rgb(248, 7, 63) :
                  color.white, goldBg, headerSize)

        // ER
        f_histCell(tape, i + 1, 4,  str.tostring(er[idx], "#.##"),
             er[idx] > erMin ?
                  color.aqua :
                  color.orange,
            goldBg, headerSize)

        // Normalized CPI
        cpiVal =
             math.round(((cpi[idx] + 1.0) / 2.0) * 100.0)

        f_histCell(tape, i + 1, 5, str.tostring(cpiVal),
             cpiVal >= 70 ?
                  color.lime :
             cpiVal <= 30 ?
                  color.rgb(248, 7, 63) :
                  color.white, goldBg, size.normal)

        // Adaptive CPI Momentum
        f_histCell(tape, i + 1, 6, str.tostring(Slopeadaptive[idx], "#.#"),
             Slopeadaptive[idx] > 0 ?
                  color.lime :
             Slopeadaptive[idx] < 0 ?
                  color.rgb(248, 7, 63) :
                  color.white,
             na, size.normal)

        // KAMA-VWAP
        f_histCell(tape, i + 1, 7,  str.tostring(KAMA_VWAP[idx], "#.##"),
             KAMA_VWAP[idx] > 0 ?
                  color.lime :
                  color.rgb(248, 7, 63),
             na, size.normal)
````
