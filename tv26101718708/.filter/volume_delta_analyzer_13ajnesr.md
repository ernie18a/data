# Volume Delta Analyzer

- url: https://www.tradingview.com/script/13aJnEsR-Volume-Delta-Analyzer/
- type: indicator
- pine_id: PUB;5ece35bdae45462f9b4dc04fa419fe2f
- version: 5.0

## Description

Volume Delta Analyzer

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT IT DOES

Matrix fetches real tick-level volume delta from TradingView's premium data feed and visualizes it directly on your chart. It decomposes total volume into buyer vs seller initiated trades, tracks cumulative volume delta (CVD), detects divergences, identifies absorption, and optionally displays a volume profile histogram.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FEATURES

• Real Delta — Not an approximation. Uses ta.requestVolumeDelta() for actual tick data
• Buy/Sell Decomposition — See exactly how much volume was buyer vs seller initiated
• CVD Tracking — Cumulative volume delta to see who's in control over time
• Delta Spike Alerts — Get notified when delta exceeds a multiple of ATR
• CVD Divergence — Background highlights when price and CVD diverge
• Bar Coloring — Paint candles green/red based on delta direction
• Absorption Detection — Visual circles when big volume hits with small price movement
• Volume Profile Mode — Horizontal histogram showing delta distribution across price levels
• Smart Timeframe — Auto-selects optimal sub-timeframe based on your chart

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


USE CASES

• Order flow analysis without Level 2 data
• Spot absorption before breakout/breakdown
• Confirm breakouts with real delta direction
• Detect smart money divergence via CVD
• Volume profile at a glance

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REQUIRES

TradingView Premium plan for real volume delta data.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREDITS

Based on volume delta research by Benb1122. Enhanced with absorption detection, divergence alerts, and profile visualization.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Benb1122 - Enhanced Edition [v2.1 Pro]: Order-Flow Divergence, Corrected Profile,
//   True Volume Delta Absorption, Sanitized Fallbacks, Clean Single-Badge Rendering,
//   Glassmorphic HUD Dashboard & Dynamic Multi-Condition Alerts.
//@version=6
indicator("Volume Delta Analyzer [v2.1 Pro]", "Volume Delta Pro", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=100, max_bars_back=500)

import TradingView/ta/8

// ==============================================================================
// ⚙️ CORE CONFIGURATION
// ==============================================================================
grp1 = "⚙️ Core Configuration"
useCustomTimeframeInput = input.bool(false, "Custom Timeframe", group=grp1,
     tooltip="Lower timeframe scanned for volume delta. Turn off for auto-adaptive resolution.")
lowerTimeframeInput     = input.timeframe("1", "Timeframe Resolution", group=grp1, active=useCustomTimeframeInput,
     tooltip="Selected resolution for sub-bar volume delta aggregation.")
barsToShow              = input.int(75, "Lookback / Profile Bars", minval=10, maxval=200, group=grp1,
     tooltip="Number of bars to display candle labels or compute the Delta Profile.")
pivotLen                = input.int(5, "Pivot Confirmation Length", group=grp1, minval=2, maxval=50,
     tooltip="Bars on each side required to validate a swing pivot.")
maxPivotDist            = input.int(100, "Max Pivot Distance", group=grp1, minval=10, maxval=300,
     tooltip="Maximum bars allowed between two pivots to qualify for divergence.")
signalCooldown          = input.int(10, "Signal Cooldown", group=grp1, minval=0, maxval=200,
     tooltip="Suppress repeat signals within this many bars.")

// ==============================================================================
// 📊 VISUAL DISPLAY & CANDLE LABELS
// ==============================================================================
grp2 = "📊 Visual Display & Candle Labels"
displayMode   = input.string("Clean Minimalist", "Candle Data Style",
     options=["Clean Minimalist", "Spike Bars Only", "Glassmorphic Cards", "Disabled"], group=grp2,
     tooltip="Clean Minimalist: Borderless monospace numbers directly under candles (no black box clutter). Spike Bars Only: Only tags bars with significant institutional volume delta.")
minDeltaSpikeZ = input.float(1.2, "Spike Threshold (Z-Score)", minval=0.5, maxval=4.0, step=0.1, group=grp2,
     active=(displayMode == "Spike Bars Only"), tooltip="Minimum delta standard deviation required to display a label in 'Spike Bars Only' mode.")
txtSize       = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grp2)
spacing       = input.float(0.3, "Vertical Spacing (ATR x)", minval=0.1, maxval=3.0, step=0.05, group=grp2,
     tooltip="Gap below the candle low for data labels.")
useBarColor   = input.bool(false, "Color Bars by Delta", group=grp2,
     tooltip="Paint candles dynamically green/red based on positive/negative volume delta.")
barColorTheme = input.string("Delta Polarity", "Bar Color Theme", options=["Delta Polarity", "Delta Intensity Gradient"], group=grp2,
     active=useBarColor, tooltip="Choose flat polarity coloring or dynamic gradient intensity.")
showCvdLine   = input.bool(false, "CVD Overlay Ribbon", group=grp2,
     tooltip="Plot normalized cumulative volume delta as a smooth ribbon over the chart.")
cvdLookback   = input.int(50, "CVD Lookback Length", group=grp2, minval=10, maxval=200, active=showCvdLine)

// ==============================================================================
// 📈 DATA OVERLAYS (Per-Bar Metrics)
// ==============================================================================
grp3 = "📈 Data Overlays"
showDelta    = input.bool(true,  "Δ Volume Delta",          group=grp3)
showDeltaPct = input.bool(false, "Δ% Delta Percentage",     group=grp3)
showBuy      = input.bool(false, "BUY Buy Volume",          group=grp3)
showSell     = input.bool(false, "SELL Sell Volume",        group=grp3)
showTotal    = input.bool(false, "TOTAL Total Volume",      group=grp3)
showCvd      = input.bool(false, "CVD Cumulative Delta",    group=grp3)

// ==============================================================================
// 📊 VOLUME PROFILE (Horizontal Delta Histogram)
// ==============================================================================
grp4 = "📊 Volume Profile"
useProfileMode     = input.bool(false, "Enable Delta Profile", group=grp4,
     tooltip="Renders a horizontal delta histogram on the right margin instead of per-bar labels.")
profileBars        = input.int(24, "Histogram Price Levels", group=grp4, minval=5, maxval=50, active=useProfileMode,
     tooltip="Number of vertical price tiers across the lookback high-low range.")
profileWidth       = input.float(0.6, "Histogram Max Width", group=grp4, minval=0.1, maxval=2.5, step=0.1, active=useProfileMode,
     tooltip="Relative horizontal scaling factor for profile bars.")
profileOffset      = input.int(4, "Right Margin Offset", group=grp4, minval=1, maxval=30, active=useProfileMode,
     tooltip="Number of bars to the right of the current candle to anchor the histogram.")
showPoc            = input.bool(true, "Highlight POC (Point of Control)", group=grp4, active=useProfileMode,
     tooltip="Highlight the price level with the highest accumulated delta.")
showProfileLabels  = input.bool(true, "Show Histogram Values", group=grp4, active=useProfileMode,
     tooltip="Print numeric delta totals adjacent to profile bars.")

// ==============================================================================
// 🔵 ORDER FLOW ABSORPTION
// ==============================================================================
grp5 = "🔵 Order Flow Absorption"
useAbsorptionCircles   = input.bool(true, "Detect Absorption Candles", group=grp5,
     tooltip="Identifies institutional absorption: heavy aggressive delta absorbed by limit orders.")
absVolMult             = input.float(1.5, "Volume Multiplier", group=grp5, minval=1.0, maxval=5.0, step=0.1, active=useAbsorptionCircles,
     tooltip="Volume must exceed this multiple of SMA(20).")
absBodyPct             = input.float(0.35, "Max Body Ratio", group=grp5, minval=0.05, maxval=0.75, step=0.05, active=useAbsorptionCircles,
     tooltip="Candle body must be less than this percentage of total candle range.")
requireDeltaAbsorption = input.bool(true, "Require Delta Absorption", group=grp5, active=useAbsorptionCircles,
     tooltip="Verifies aggressive sell delta on bullish absorption or buy delta on bearish absorption.")

// ==============================================================================
// 🔀 DIVERGENCE DETECTION ENGINE
// ==============================================================================
grp6 = "🔀 Divergence Detection"
useExhaustion        = input.bool(true, "Exhaustion Signals", group=grp6,
     tooltip="Price achieves new pivot extreme, but CVD fails to confirm (buyers/sellers exhausted).")
useAbsorptionDetect  = input.bool(true, "Absorption Signals", group=grp6,
     tooltip="CVD achieves new aggressive extreme, but Price fails to confirm (institutional limit defense).")
minSwingATR          = input.float(0.75, "Min Price Swing (ATR x)", group=grp6, minval=0.0, maxval=5.0, step=0.25,
     tooltip="Filters out small noise swings. Divergence rejected if price delta < ATR * threshold.")
showDivergenceLabels = input.bool(true, "Pivot Pattern Labels", group=grp6,
     tooltip="Display badges at confirmed pivot points.")
divLabelStyle        = input.string("Compact Pill", "Label Style", options=["Compact Pill", "Minimal Icon", "Detailed Callout"], group=grp6,
     active=showDivergenceLabels, tooltip="Compact Pill: Sleek single-line badge right at the wick. Minimal Icon: Minimalist arrow tag. Detailed Callout: Full multiline description.")
divLabelSize         = input.string("Normal", "Pattern Badge Size", options=["Tiny", "Small", "Normal", "Large"], group=grp6,
     active=showDivergenceLabels, tooltip="Font size for divergence pivot labels.")
showDivergenceBg     = input.bool(false, "Background Aura", group=grp6,
     tooltip="Soft ambient background glow behind price action on validated divergence (ultra-subtle 94% transparency). Default is off for maximum chart cleanliness.")
divBgFade            = input.int(8, "Background Fade (Bars)", group=grp6, minval=1, maxval=30, active=showDivergenceBg,
     tooltip="Number of bars before ambient glow fades.")

// ==============================================================================
// 🔔 ALERTS
// ==============================================================================
grp7 = "🔔 Alerts"
useDeltaAlert  = input.bool(false, "Delta Spike Alert", group=grp7,
     tooltip="Triggers alert when absolute delta exceeds standard deviation multiplier.")
deltaAlertMult = input.float(2.0, "Spike Threshold (Z-Score)", group=grp7, minval=1.0, maxval=5.0, step=0.5, active=useDeltaAlert)

// ==============================================================================
// 🎨 INSTITUTIONAL COLOR PALETTE
// ==============================================================================
grp8 = "🎨 Color Theme"
delta_positive_color = input.color(color.rgb(0, 230, 118),   "Delta Positive", group=grp8, inline="d")
delta_negative_color = input.color(color.rgb(255, 61, 104),   "Delta Negative", group=grp8, inline="d")
cvd_up_color         = input.color(color.rgb(0, 212, 255),   "CVD Up",         group=grp8, inline="c")
cvd_down_color       = input.color(color.rgb(255, 145, 0),   "CVD Down",       group=grp8, inline="c")
buy_color            = input.color(color.rgb(38, 166, 154),  "Buy Vol",        group=grp8, inline="v")
sell_color           = input.color(color.rgb(239, 83, 80),   "Sell Vol",       group=grp8, inline="v")
total_color          = input.color(color.rgb(120, 144, 156), "Total Vol",      group=grp8, inline="v")
exhaustBullColor     = input.color(color.rgb(0, 230, 118),   "Exh Bull",       group=grp8, inline="pe")
exhaustBearColor     = input.color(color.rgb(255, 61, 104),   "Exh Bear",       group=grp8, inline="pe")
absorpBullColor      = input.color(color.rgb(0, 176, 255),   "Abs Bull",       group=grp8, inline="pa")
absorpBearColor      = input.color(color.rgb(255, 171, 0),   "Abs Bear",       group=grp8, inline="pa")
divBgBullColor       = input.color(color.rgb(0, 230, 118),   "Bg Bullish",     group=grp8, inline="bg")
divBgBearColor       = input.color(color.rgb(255, 61, 104),   "Bg Bearish",     group=grp8, inline="bg")
pocColor             = input.color(color.rgb(255, 215, 0),   "POC Level",      group=grp8, inline="poc")

// ==============================================================================
// 📋 HUD DASHBOARD
// ==============================================================================
grp9 = "📋 HUD Dashboard"
showTable     = input.bool(true, "Show Dashboard", group=grp9)
tableMode     = input.string("Compact HUD", "Dashboard Mode", options=["Compact HUD", "Full Terminal"], group=grp9,
     tooltip="Compact HUD: Minimal 6-row institutional widget that never blocks price action. Full Terminal: Expanded analytics.")
tablePosition = input.string("top_right", "Position",
     options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group=grp9)
tableSize     = input.string("normal", "Size", options=["tiny", "small", "normal", "large"], group=grp9)

// ==============================================================================
// 🛠️ HELPER FUNCTIONS
// ==============================================================================
f_txtSz(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

f_getTableSize(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.normal

f_getTablePosition(p) =>
    switch p
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_center" => position.middle_center
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right"  => position.bottom_right
        => position.top_right

// Volume abbreviation formatter (e.g., 1.25M, 450.2K, 850)
f_vol(float v) =>
    float absV = math.abs(v)
    string sign = v < 0 ? "-" : (v > 0 ? "+" : "")
    if absV >= 1000000000
        sign + str.tostring(absV / 1000000000, "0.00") + "B"
    else if absV >= 1000000
        sign + str.tostring(absV / 1000000, "0.00") + "M"
    else if absV >= 1000
        sign + str.tostring(absV / 1000, "0.0") + "K"
    else
        sign + str.tostring(absV, "0")

// ==============================================================================
// 📦 DATA REQUEST & ESTIMATION FALLBACK
// ==============================================================================
// Adaptive timeframe resolution: default intraday to 1-minute to prevent sub-bar limit errors
lowerTimeframe = switch
    useCustomTimeframeInput => lowerTimeframeInput
    timeframe.isseconds     => "1S"
    timeframe.isintraday    => "1"
    timeframe.isdaily       => "5"
    => "60"

[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframe)

// Intra-bar volume estimation fallback if exchange does not provide lower tf data on historical bars
candleRange = high - low
closePosNorm = candleRange > 0 ? (close - open) / candleRange : 0.0
estimatedDelta = closePosNorm * nz(volume, 0.0)

// Robust delta sanitization
rawDelta = not na(lastVolume) ? lastVolume : estimatedDelta
delta = nz(rawDelta, 0.0)

total_volume = nz(volume, 0.0)
buy_volume   = math.max((total_volume + delta) / 2.0, 0.0)
sell_volume  = math.max((total_volume - delta) / 2.0, 0.0)
delta_pct    = total_volume > 0 ? (delta / total_volume) * 100.0 : 0.0

// Running Cumulative Volume Delta (CVD) - immune to NaN corruption
var float cvd = 0.0
cvd := nz(cvd[1]) + delta

// Ensure compiler allocates historical buffer for loop lookback on barstate.islast
max_bars_back(delta, 500)
max_bars_back(delta_pct, 500)
max_bars_back(buy_volume, 500)
max_bars_back(sell_volume, 500)
max_bars_back(total_volume, 500)
max_bars_back(cvd, 500)
max_bars_back(low, 500)
max_bars_back(high, 500)

var float cumVol = 0.0
cumVol += total_volume
if barstate.islast and cumVol == 0
    runtime.error("The data vendor does not provide volume data for this asset.")

// Volatility & Standard Deviation Baseline
atr14 = nz(ta.atr(14), ta.tr)
stdevDelta = ta.stdev(delta, 50)
stdevDeltaSafe = nz(stdevDelta > 0 ? stdevDelta : ta.sma(math.abs(delta), 20), 1.0)
avgVol = nz(ta.sma(volume, 20), 1.0)

// ==============================================================================
// 🎨 BAR COLORING
// ==============================================================================
deltaZ = stdevDeltaSafe > 0 ? delta / stdevDeltaSafe : 0.0
color barClr = na

if useBarColor
    if barColorTheme == "Delta Polarity"
        barClr := delta >= 0 ? delta_positive_color : delta_negative_color
    else if barColorTheme == "Delta Intensity Gradient"
        float normIntensity = math.min(math.abs(deltaZ) / 2.5, 1.0)
        int alphaVal = math.round(70 - normIntensity * 60)
        barClr := delta >= 0 ? color.new(delta_positive_color, alphaVal) : color.new(delta_negative_color, alphaVal)

barcolor(barClr)

// ==============================================================================
// 📈 CVD OVERLAY RIBBON
// ==============================================================================
int cvdLB = math.max(cvdLookback, 10)
float cvdHi = ta.highest(cvd, cvdLB)
float cvdLo = ta.lowest(cvd, cvdLB)
float cvdRange = cvdHi - cvdLo
float cvdNorm = cvdRange > 0 ? (cvd - cvdLo) / cvdRange : 0.5

// Anchor CVD smoothly around an exponential price baseline
float cvdAnchor = ta.ema(close, 20)
float cvdPlot = showCvdLine ? cvdAnchor + (cvdNorm - 0.5) * atr14 * 2.0 : na
plot(cvdPlot, "CVD Ribbon", color=cvdNorm >= cvdNorm[1] ? cvd_up_color : cvd_down_color, linewidth=2)

// CVD Momentum over confirmation length
cvdMomentum = cvd - nz(cvd[pivotLen])
cvdMomentumZ = stdevDeltaSafe > 0 ? cvdMomentum / (stdevDeltaSafe * math.sqrt(pivotLen)) : 0.0

// ==============================================================================
// 🔵 ORDER FLOW ABSORPTION DETECTION
// ==============================================================================
absVolSMA    = ta.sma(total_volume, 20)
absBody      = math.abs(close - open)
absRange     = high - low
absBodyRatio = absRange > 0 ? absBody / absRange : 1.0
absVolRatio  = absVolSMA > 0 ? total_volume / absVolSMA : 1.0

// Bullish Absorption: High volume, long lower wick (close in upper 35%),
// aggressive market sells absorbed by passive buyers
bool deltaSellAbsorbed = not requireDeltaAbsorption or delta < 0 or delta < -0.15 * total_volume
isBullAbsorb = useAbsorptionCircles and absVolRatio >= absVolMult and absBodyRatio <= absBodyPct and
               close >= (high - absRange * 0.35) and deltaSellAbsorbed

// Bearish Absorption: High volume, long upper wick (close in lower 35%),
// aggressive market buys absorbed by passive sellers
bool deltaBuyAbsorbed = not requireDeltaAbsorption or delta > 0 or delta > 0.15 * total_volume
isBearAbsorb = useAbsorptionCircles and absVolRatio >= absVolMult and absBodyRatio <= absBodyPct and
               close <= (low + absRange * 0.35) and deltaBuyAbsorbed

plotshape(isBullAbsorb, title="Bullish Absorption", style=shape.circle, location=location.belowbar,
     color=absorpBullColor, size=size.tiny, offset=0)
plotshape(isBearAbsorb, title="Bearish Absorption", style=shape.circle, location=location.abovebar,
     color=absorpBearColor, size=size.tiny, offset=0)

// ==============================================================================
// 🔀 DIVERGENCE DETECTION ENGINE (Pivot-to-Pivot)
// ==============================================================================
pricePL = ta.pivotlow(low, pivotLen, pivotLen)
pricePH = ta.pivothigh(high, pivotLen, pivotLen)

var float prevPricePL = na
var float prevCvdAtPL = na
var int   prevBarPL   = na
var float lastPricePL = na
var float lastCvdAtPL = na
var int   lastBarPL   = na

var float prevPricePH = na
var float prevCvdAtPH = na
var int   prevBarPH   = na
var float lastPricePH = na
var float lastCvdAtPH = na
var int   lastBarPH   = na

var int lastBullExhBar = na
var int lastBullAbsBar = na
var int lastBearExhBar = na
var int lastBearAbsBar = na

f_cool(lastBar) =>
    signalCooldown <= 0 or na(lastBar) or (bar_index - lastBar) >= signalCooldown

bool bullExhaustion = false
bool bullAbsorption = false
bool bearExhaustion = false
bool bearAbsorption = false

float divScore     = 0.0
string divType     = "NONE"
float divPriceMove = 0.0
float divCvdMove   = 0.0

// --- Bullish Patterns (Lows) ---
if not na(pricePL)
    cvdAtPL  = nz(cvd[pivotLen])
    pivotBar = bar_index - pivotLen

    prevPricePL := lastPricePL
    prevCvdAtPL := lastCvdAtPL
    prevBarPL   := lastBarPL
    lastPricePL := pricePL
    lastCvdAtPL := cvdAtPL
    lastBarPL   := pivotBar

    if not na(prevPricePL) and not na(prevCvdAtPL) and not na(prevBarPL)
        barDist = lastBarPL - prevBarPL
        distOK  = barDist >= pivotLen and barDist <= maxPivotDist
        priceDiff = math.abs(pricePL - prevPricePL)
        swingOK = minSwingATR <= 0 or priceDiff >= atr14 * minSwingATR

        if distOK and swingOK
            priceATRDiff = atr14 > 0 ? priceDiff / atr14 : 1.0
            cvdZDiff = stdevDeltaSafe > 0 ? math.abs(cvdAtPL - prevCvdAtPL) / (stdevDeltaSafe * math.sqrt(barDist)) : 1.0
            score = math.min(math.max((priceATRDiff + cvdZDiff) / 2.0, 0.5), 5.0)

            // Bullish Exhaustion: Price reaches lower low, CVD forms higher low (sellers dried up)
            if useExhaustion and pricePL < prevPricePL and cvdAtPL > prevCvdAtPL and f_cool(lastBullExhBar)
                bullExhaustion := true
                lastBullExhBar := bar_index
                divType        := "BULL EXH"
                divScore       := score
                divPriceMove   := priceATRDiff
                divCvdMove     := cvdAtPL - prevCvdAtPL

            // Bullish Absorption: Price forms higher low, CVD reaches lower low (selling pressure absorbed)
            if useAbsorptionDetect and pricePL > prevPricePL and cvdAtPL < prevCvdAtPL and f_cool(lastBullAbsBar)
                bullAbsorption := true
                lastBullAbsBar := bar_index
                divType        := "BULL ABS"
                divScore       := score
                divPriceMove   := priceATRDiff
                divCvdMove     := prevCvdAtPL - cvdAtPL

// --- Bearish Patterns (Highs) ---
if not na(pricePH)
    cvdAtPH  = nz(cvd[pivotLen])
    pivotBar = bar_index - pivotLen

    prevPricePH := lastPricePH
    prevCvdAtPH := lastCvdAtPH
    prevBarPH   := lastBarPH
    lastPricePH := pricePH
    lastCvdAtPH := cvdAtPH
    lastBarPH   := pivotBar

    if not na(prevPricePH) and not na(prevCvdAtPH) and not na(prevBarPH)
        barDist = lastBarPH - prevBarPH
        distOK  = barDist >= pivotLen and barDist <= maxPivotDist
        priceDiff = math.abs(pricePH - prevPricePH)
        swingOK = minSwingATR <= 0 or priceDiff >= atr14 * minSwingATR

        if distOK and swingOK
            priceATRDiff = atr14 > 0 ? priceDiff / atr14 : 1.0
            cvdZDiff = stdevDeltaSafe > 0 ? math.abs(cvdAtPH - prevCvdAtPH) / (stdevDeltaSafe * math.sqrt(barDist)) : 1.0
            score = math.min(math.max((priceATRDiff + cvdZDiff) / 2.0, 0.5), 5.0)

            // Bearish Exhaustion: Price reaches higher high, CVD forms lower high (buyers dried up)
            if useExhaustion and pricePH > prevPricePH and cvdAtPH < prevCvdAtPH and f_cool(lastBearExhBar)
                bearExhaustion := true
                lastBearExhBar := bar_index
                divType        := "BEAR EXH"
                divScore       := score
                divPriceMove   := priceATRDiff
                divCvdMove     := prevCvdAtPH - cvdAtPH

            // Bearish Absorption: Price forms lower high, CVD reaches higher high (buying pressure absorbed)
            if useAbsorptionDetect and pricePH < prevPricePH and cvdAtPH > prevCvdAtPH and f_cool(lastBearAbsBar)
                bearAbsorption := true
                lastBearAbsBar := bar_index
                divType        := "BEAR ABS"
                divScore       := score
                divPriceMove   := priceATRDiff
                divCvdMove     := cvdAtPH - prevCvdAtPH

// ==============================================================================
// 🎨 DIVERGENCE BACKGROUND SHADING (Smooth Dynamic Fade)
// ==============================================================================
var string activeDivType     = "NONE"
var int    activeDivBar      = na
var float  activeDivScore    = 0.0

if bullExhaustion or bullAbsorption or bearExhaustion or bearAbsorption
    activeDivType  := divType
    activeDivBar   := bar_index
    activeDivScore := divScore

if not na(activeDivBar) and (bar_index - activeDivBar) > divBgFade
    activeDivType := "NONE"

isBullDiv = str.contains(activeDivType, "BULL")
isBearDiv = str.contains(activeDivType, "BEAR")
anyActive = isBullDiv or isBearDiv

barsSince = na(activeDivBar) ? 0 : bar_index - activeDivBar
fadeRatio = math.max(1.0 - (barsSince / math.max(divBgFade, 1)), 0.0)

color targetBgColor = isBullDiv ? divBgBullColor : divBgBearColor
// Ultra-subtle ambient glow (92% - 98% transparent) instead of harsh dark vertical walls
int bgTransp = math.round(98 - fadeRatio * 6)
color finalBgColor = color.new(targetBgColor, bgTransp)

bgcolor(showDivergenceBg and anyActive and fadeRatio > 0 ? finalBgColor : na, title="Ambient Pattern Glow")

// ==============================================================================
// 🏷️ HISTORICAL PIVOT LABELS (Confirmed on Close)
// ==============================================================================
if showDivergenceLabels and barstate.isconfirmed
    divSz = f_txtSz(divLabelSize)
    if bullExhaustion
        string bullExhTxt = divLabelStyle == "Compact Pill" ? "▲ EXH " + str.tostring(divScore, "0.0") + "σ" :   divLabelStyle == "Minimal Icon"  ? "▲" : "▲ EXHAUSTION\nSellers Dried (" + str.tostring(divScore, "0.0") + "σ)"
        label.new(bar_index[pivotLen], low[pivotLen], bullExhTxt,
             yloc=yloc.belowbar, style=label.style_label_up, color=exhaustBullColor,
             textcolor=color.rgb(10, 25, 15), size=divSz)

    if bullAbsorption
        string bullAbsTxt = divLabelStyle == "Compact Pill" ? "▲ ABS " + str.tostring(divScore, "0.0") + "σ" :   divLabelStyle == "Minimal Icon"  ? "▲" : "▲ ABSORPTION\nBuyers Absorbed (" + str.tostring(divScore, "0.0") + "σ)"
        label.new(bar_index[pivotLen], low[pivotLen], bullAbsTxt,
             yloc=yloc.belowbar, style=label.style_label_up, color=absorpBullColor,
             textcolor=color.rgb(10, 20, 30), size=divSz)

    if bearExhaustion
        string bearExhTxt = divLabelStyle == "Compact Pill" ? "▼ EXH " + str.tostring(divScore, "0.0") + "σ" :  divLabelStyle == "Minimal Icon"  ? "▼" :  "▼ EXHAUSTION\nBuyers Dried (" + str.tostring(divScore, "0.0") + "σ)"
        label.new(bar_index[pivotLen], high[pivotLen], bearExhTxt,
             yloc=yloc.abovebar, style=label.style_label_down, color=exhaustBearColor,
             textcolor=color.white, size=divSz)

    if bearAbsorption
        string bearAbsTxt = divLabelStyle == "Compact Pill" ? "▼ ABS " + str.tostring(divScore, "0.0") + "σ" :  divLabelStyle == "Minimal Icon"  ? "▼" :   "▼ ABSORPTION\nSellers Absorbed (" + str.tostring(divScore, "0.0") + "σ)"
        label.new(bar_index[pivotLen], high[pivotLen], bearAbsTxt,
             yloc=yloc.abovebar, style=label.style_label_down, color=absorpBearColor,
             textcolor=color.rgb(30, 20, 5), size=divSz)

// ==============================================================================
// 📊 SIGNAL TRACKER & HISTORICAL STATISTICS
// ==============================================================================
var string lastSignalText     = "NONE"
var color  lastSignalColor    = color.gray
var float  lastSignalStrength = 0.0
var int    bullPatternCount   = 0
var int    bearPatternCount   = 0
var int    totalExhCount      = 0
var int    totalAbsCount      = 0

if bullExhaustion
    lastSignalText     := "▲ BULL EXH"
    lastSignalColor    := exhaustBullColor
    lastSignalStrength := divScore
    bullPatternCount   += 1
    totalExhCount      += 1
else if bearExhaustion
    lastSignalText     := "▼ BEAR EXH"
    lastSignalColor    := exhaustBearColor
    lastSignalStrength := divScore
    bearPatternCount   += 1
    totalExhCount      += 1
else if bullAbsorption
    lastSignalText     := "▲ BULL ABS"
    lastSignalColor    := absorpBullColor
    lastSignalStrength := divScore
    bullPatternCount   += 1
    totalAbsCount      += 1
else if bearAbsorption
    lastSignalText     := "▼ BEAR ABS"
    lastSignalColor    := absorpBearColor
    lastSignalStrength := divScore
    bearPatternCount   += 1
    totalAbsCount      += 1

// ==============================================================================
// 🔔 ALERTS
// ==============================================================================
deltaSpike = useDeltaAlert and math.abs(deltaZ) >= deltaAlertMult
alertcondition(deltaSpike,      title="Delta Spike",        message="Order Flow: Extreme Volume Delta Spike detected on {{ticker}} ({{interval}})")
alertcondition(bullExhaustion,  title="Bullish Exhaustion", message="Order Flow: Bullish Exhaustion confirmed on {{ticker}} ({{interval}})")
alertcondition(bearExhaustion,  title="Bearish Exhaustion", message="Order Flow: Bearish Exhaustion confirmed on {{ticker}} ({{interval}})")
alertcondition(bullAbsorption,  title="Bullish Absorption", message="Order Flow: Bullish Absorption confirmed on {{ticker}} ({{interval}})")
alertcondition(bearAbsorption,  title="Bearish Absorption", message="Order Flow: Bearish Absorption confirmed on {{ticker}} ({{interval}})")
alertcondition(isBullAbsorb,    title="Absorption Candle Bull", message="Order Flow: Bullish Absorption Candle formed on {{ticker}} ({{interval}})")
alertcondition(isBearAbsorb,    title="Absorption Candle Bear", message="Order Flow: Bearish Absorption Candle formed on {{ticker}} ({{interval}})")

// ==============================================================================
// 📋 HUD DASHBOARD TABLE
// ==============================================================================
var table analysisTable = table.new(f_getTablePosition(tablePosition), 2, 16,
     border_width=0, frame_width=1, frame_color=color.rgb(40, 48, 68))

if showTable and barstate.islast
    table.clear(analysisTable, 0, 0, 1, 15)
    tblSz = f_getTableSize(tableSize)

    color cBgHeader = color.rgb(18, 22, 34)
    color cBgRowA   = color.rgb(13, 16, 24)
    color cBgRowB   = color.rgb(17, 21, 30)
    color cTxtMuted = color.rgb(140, 150, 170)

    pressureRatio = sell_volume > 0 ? buy_volume / sell_volume : buy_volume > 0 ? 10.0 : 1.0
    pressureColor = pressureRatio > 1.2 ? delta_positive_color : pressureRatio < 0.8 ? delta_negative_color : color.gray
    pressureText  = pressureRatio > 1.2 ? "BUYERS 🐂" : pressureRatio < 0.8 ? "SELLERS 🐻" : "BALANCED ⚖️"
    momColor      = cvdMomentumZ > 0.5 ? delta_positive_color : cvdMomentumZ < -0.5 ? delta_negative_color : color.gray

    if tableMode == "Compact HUD"
        // ── 6-ROW ULTRA-COMPACT STREAMLINED HUD ──
        table.cell(analysisTable, 0, 0, "⚡ ORDER FLOW", text_color=color.white, bgcolor=cBgHeader, text_size=tblSz)
        table.cell(analysisTable, 1, 0, syminfo.ticker, text_color=color.rgb(0, 212, 255), bgcolor=cBgHeader, text_size=tblSz)

        // Row 1: Delta + Delta %
        color dClr = delta >= 0 ? delta_positive_color : delta_negative_color
        string dStr = f_vol(delta) + " (" + (delta_pct >= 0 ? "+" : "") + str.tostring(delta_pct, "0.0") + "%)"
        table.cell(analysisTable, 0, 1, "Bar Delta", text_color=cTxtMuted, bgcolor=cBgRowA, text_size=tblSz)
        table.cell(analysisTable, 1, 1, dStr, text_color=dClr, bgcolor=cBgRowA, text_size=tblSz)

        // Row 2: Cumulative CVD + Trend
        color cvdClr = cvd >= 0 ? cvd_up_color : cvd_down_color
        string cvdStr = f_vol(cvd) + (cvd > cvd[1] ? " ▲" : cvd < cvd[1] ? " ▼" : " ─")
        table.cell(analysisTable, 0, 2, "Cumulative CVD", text_color=cTxtMuted, bgcolor=cBgRowB, text_size=tblSz)
        table.cell(analysisTable, 1, 2, cvdStr, text_color=cvdClr, bgcolor=cBgRowB, text_size=tblSz)

        // Row 3: Pressure & Dominance
        table.cell(analysisTable, 0, 3, "Flow Pressure", text_color=cTxtMuted, bgcolor=cBgRowA, text_size=tblSz)
        table.cell(analysisTable, 1, 3, pressureText + " (" + str.tostring(pressureRatio, "0.00") + "x)",
             text_color=pressureColor, bgcolor=cBgRowA, text_size=tblSz)

        // Row 4: Last Divergence Signal
        string divStr = lastSignalText != "NONE" ? lastSignalText + " (" + str.tostring(lastSignalStrength, "0.0") + "σ)" : "None"
        table.cell(analysisTable, 0, 4, "Last Signal", text_color=cTxtMuted, bgcolor=cBgRowB, text_size=tblSz)
        table.cell(analysisTable, 1, 4, divStr, text_color=lastSignalColor, bgcolor=cBgRowB, text_size=tblSz)

        // Row 5: Pattern Counts
        string tallyStr = "▲" + str.tostring(bullPatternCount) + "  ▼" + str.tostring(bearPatternCount) + " (E" + str.tostring(totalExhCount) + " A" + str.tostring(totalAbsCount) + ")"
        table.cell(analysisTable, 0, 5, "Pattern Tally", text_color=cTxtMuted, bgcolor=cBgRowA, text_size=tblSz)
        table.cell(analysisTable, 1, 5, tallyStr, text_color=color.white, bgcolor=cBgRowA, text_size=tblSz)

    else
        // ── FULL TERMINAL MODE (11 Clean Rows) ──
        table.cell(analysisTable, 0, 0, "⚡ ORDER FLOW PRO", text_color=color.white, bgcolor=cBgHeader, text_size=tblSz)
        table.cell(analysisTable, 1, 0, syminfo.ticker, text_color=color.rgb(0, 212, 255), bgcolor=cBgHeader, text_size=tblSz)

        // Section 1: Order Flow
        table.cell(analysisTable, 0, 1, "ORDER FLOW", text_color=color.rgb(180, 190, 215), bgcolor=color.rgb(26, 31, 44), text_size=tblSz)
        table.cell(analysisTable, 1, 1, "LTF: " + lowerTimeframe, text_color=color.rgb(0, 212, 255), bgcolor=color.rgb(26, 31, 44), text_size=tblSz)

        table.cell(analysisTable, 0, 2, "Bar Delta", text_color=cTxtMuted, bgcolor=cBgRowA, text_size=tblSz)
        table.cell(analysisTable, 1, 2, f_vol(delta), text_color=delta >= 0 ? delta_positive_color : delta_negative_color, bgcolor=cBgRowA, text_size=tblSz)

        table.cell(analysisTable, 0, 3, "Delta %", text_color=cTxtMuted, bgcolor=cBgRowB, text_size=tblSz)
        table.cell(analysisTable, 1, 3, (delta_pct >= 0 ? "+" : "") + str.tostring(delta_pct, "0.0") + "%",
             text_color=delta_pct >= 0 ? delta_positive_color : delta_negative_color, bgcolor=cBgRowB, text_size=tblSz)

        table.cell(analysisTable, 0, 4, "CVD Total", text_color=cTxtMuted, bgcolor=cBgRowA, text_size=tblSz)
        table.cell(analysisTable, 1, 4, f_vol(cvd), text_color=cvd >= 0 ? cvd_up_color : cvd_down_color, bgcolor=cBgRowA, text_size=tblSz)

        table.cell(analysisTable, 0, 5, "Buy / Sell Vol", text_color=cTxtMuted, bgcolor=cBgRowB, text_size=tblSz)
        table.cell(analysisTable, 1, 5, f_vol(buy_volume) + " / " + f_vol(sell_volume), text_color=color.white, bgcolor=cBgRowB, text_size=tblSz)

        // Section 2: Flow Pressure
        table.cell(analysisTable, 0, 6, "Pressure Ratio", text_color=cTxtMuted, bgcolor=cBgRowA, text_size=tblSz)
        table.cell(analysisTable, 1, 6, str.tostring(pressureRatio, "0.00") + "x", text_color=pressureColor, bgcolor=cBgRowA, text_size=tblSz)

        table.cell(analysisTable, 0, 7, "Dominant Force", text_color=cTxtMuted, bgcolor=cBgRowB, text_size=tblSz)
        table.cell(analysisTable, 1, 7, pressureText, text_color=pressureColor, bgcolor=cBgRowB, text_size=tblSz)

        table.cell(analysisTable, 0, 8, "CVD Momentum", text_color=cTxtMuted, bgcolor=cBgRowA, text_size=tblSz)
        table.cell(analysisTable, 1, 8, (cvdMomentumZ >= 0 ? "+" : "") + str.tostring(cvdMomentumZ, "0.00") + "σ", text_color=momColor, bgcolor=cBgRowA, text_size=tblSz)

        // Section 3: Patterns
        table.cell(analysisTable, 0, 9, "Last Divergence", text_color=cTxtMuted, bgcolor=cBgRowB, text_size=tblSz)
        string lastDivFull = lastSignalText != "NONE" ? lastSignalText + " (" + str.tostring(lastSignalStrength, "0.0") + "σ)" : "None"
        table.cell(analysisTable, 1, 9, lastDivFull, text_color=lastSignalColor, bgcolor=cBgRowB, text_size=tblSz)

        table.cell(analysisTable, 0, 10, "Pattern Tally", text_color=cTxtMuted, bgcolor=cBgRowA, text_size=tblSz)
        table.cell(analysisTable, 1, 10, "▲" + str.tostring(bullPatternCount) + "  ▼" + str.tostring(bearPatternCount) + " (E" + str.tostring(totalExhCount) + " A" + str.tostring(totalAbsCount) + ")",
             text_color=color.white, bgcolor=cBgRowA, text_size=tblSz)

// ==============================================================================
// 🖌️ RENDERING ENGINE (Candle Badges & Delta Profile)
// ==============================================================================
var label[] labs      = array.new<label>()
var label[] profLabs  = array.new<label>()
var box[]   profBoxes = array.new<box>()

// Profile range length is guaranteed to be >= 1 to eliminate runtime errors
int safeProfileLength = math.max(1, math.min(barsToShow, 200))
float profHi = ta.highest(high, safeProfileLength)
float profLo = ta.lowest(low, safeProfileLength)

if barstate.islast
    // Clear dynamic chart artifacts on each refresh
    if array.size(labs) > 0
        for i = 0 to array.size(labs) - 1
            label.delete(array.get(labs, i))
        array.clear(labs)

    if array.size(profLabs) > 0
        for i = 0 to array.size(profLabs) - 1
            label.delete(array.get(profLabs, i))
        array.clear(profLabs)

    if array.size(profBoxes) > 0
        for i = 0 to array.size(profBoxes) - 1
            box.delete(array.get(profBoxes, i))
        array.clear(profBoxes)

    txtSz = f_txtSz(txtSize)
    step  = nz(atr14) * spacing

    // ──────────────────────────────────────────────────────────────────────────
    // MODE A: CANDLE DATA LABELS
    // ──────────────────────────────────────────────────────────────────────────
    if not useProfileMode and displayMode != "Disabled"
        bool hasOverlays = showDelta or showDeltaPct or showBuy or showSell or showTotal or showCvd

        if hasOverlays and step > 0
            int effBars = math.min(barsToShow, math.min(bar_index, 200))

            for c = 0 to effBars - 1
                float d  = nz(delta[c])
                float dp = nz(delta_pct[c])
                float bv = nz(buy_volume[c])
                float sv = nz(sell_volume[c])
                float tv = nz(total_volume[c])
                float cv = nz(cvd[c])

                // Delta spike condition
                bool isSpike = stdevDeltaSafe > 0 and (math.abs(d) / stdevDeltaSafe) >= minDeltaSpikeZ

                if displayMode != "Spike Bars Only" or isSpike
                    color numClr = d >= 0 ? delta_positive_color : delta_negative_color

                    if displayMode == "Clean Minimalist" or displayMode == "Spike Bars Only"
                        // ── SLEEK BORDERLESS MONOSPACE TEXT (No bulky black boxes!) ──
                        string tag = ""
                        if showDelta
                            tag += f_vol(d)
                        if showDeltaPct
                            tag += (tag != "" ? "\n" : "") + (dp >= 0 ? "+" : "") + str.tostring(dp, "0") + "%"
                        if showBuy
                            tag += (tag != "" ? "\n" : "") + "B " + f_vol(bv)
                        if showSell
                            tag += (tag != "" ? "\n" : "") + "S " + f_vol(sv)
                        if showTotal
                            tag += (tag != "" ? "\n" : "") + "T " + f_vol(tv)
                        if showCvd
                            tag += (tag != "" ? "\n" : "") + "CVD " + f_vol(cv)

                        l = label.new(bar_index[c], low[c] - step, tag,
                             yloc=yloc.price, style=label.style_none, size=txtSz,
                             textcolor=numClr)
                        array.push(labs, l)

                    else if displayMode == "Glassmorphic Cards"
                        // ── COMPACT GLASS PILL ──
                        string cardText = ""
                        if showDelta
                            cardText += "Δ " + f_vol(d)
                        if showDeltaPct
                            cardText += (cardText != "" ? "\n" : "") + (dp >= 0 ? "+" : "") + str.tostring(dp, "0.0") + "%"
                        if showBuy
                            cardText += (cardText != "" ? "\n" : "") + "B " + f_vol(bv)
                        if showSell
                            cardText += (cardText != "" ? "\n" : "") + "S " + f_vol(sv)
                        if showTotal
                            cardText += (cardText != "" ? "\n" : "") + "T " + f_vol(tv)
                        if showCvd
                            cardText += (cardText != "" ? "\n" : "") + "CVD " + f_vol(cv)

                        color cardBgColor = color.new(color.rgb(18, 22, 32), 40)
                        l = label.new(bar_index[c], low[c] - step, cardText,
                             yloc=yloc.price, style=label.style_label_up, size=txtSz,
                             color=cardBgColor, textcolor=numClr)
                        array.push(labs, l)

    // ──────────────────────────────────────────────────────────────────────────
    // MODE B: HORIZONTAL DELTA PROFILE (On the Right Margin)
    // ──────────────────────────────────────────────────────────────────────────
    else if useProfileMode
        float priceRange = profHi - profLo
        int pBars = math.min(profileBars, 50)

        if priceRange > 0 and safeProfileLength > 0
            float levelStep = priceRange / pBars
            float[] lvlDeltas = array.new<float>(pBars, 0.0)
            float[] lvlTotals = array.new<float>(pBars, 0.0)

            // Step 1: Accumulate volume & delta across price levels
            int profBarsLoop = math.min(safeProfileLength, bar_index + 1)
            for c = 0 to profBarsLoop - 1
                float barLo    = low[c]
                float barHi    = high[c]
                float barDelta = nz(delta[c])
                float barTotal = nz(total_volume[c])

                int botLvl = math.max(0, int((barLo - profLo) / levelStep))
                int topLvl = math.min(pBars - 1, int((barHi - profLo) / levelStep))
                int span   = topLvl - botLvl + 1

                if span > 0
                    float deltaShare = barDelta / span
                    float totalShare = barTotal / span
                    for L = botLvl to topLvl
                        array.set(lvlDeltas, L, array.get(lvlDeltas, L) + deltaShare)
                        array.set(lvlTotals, L, array.get(lvlTotals, L) + totalShare)

            // Step 2: Calculate maximums for proportional normalization & POC discovery
            float maxAbsLvlDelta = 0.0
            float maxLvlTotal    = 0.0
            int   pocLevelIndex  = 0

            for lvl = 0 to pBars - 1
                float absD = math.abs(array.get(lvlDeltas, lvl))
                if absD > maxAbsLvlDelta
                    maxAbsLvlDelta := absD

                float tot = array.get(lvlTotals, lvl)
                if tot > maxLvlTotal
                    maxLvlTotal   := tot
                    pocLevelIndex := lvl

            int maxLenBars = math.max(math.round(25 * profileWidth), 2)

            // Step 3: Render profile histogram cleanly in the right margin
            if maxAbsLvlDelta > 0
                for lvl = 0 to pBars - 1
                    float lvlLo    = profLo + lvl * levelStep
                    float lvlHi    = lvlLo + levelStep
                    float lvlDelta = array.get(lvlDeltas, lvl)
                    float lvlMid   = (lvlLo + lvlHi) / 2.0

                    float normRatio = math.abs(lvlDelta) / maxAbsLvlDelta
                    int barWidth = math.max(int(normRatio * maxLenBars), 1)

                    // Anchored to the right of current price action
                    int bxL = bar_index + profileOffset
                    int bxR = bxL + barWidth
                    int lx  = bxR + 1

                    bool isPoc = showPoc and (lvl == pocLevelIndex)

                    // Safe transparency calculation strictly clamped [20, 85]
                    int alphaVal = math.max(20, math.min(85, math.round(85 - normRatio * 60)))
                    color barBaseClr = isPoc ? pocColor : (lvlDelta >= 0 ? delta_positive_color : delta_negative_color)
                    color barClrBox  = color.new(barBaseClr, isPoc ? 10 : alphaVal)
                    color borderClr  = isPoc ? pocColor : color.new(barBaseClr, 40)

                    b = box.new(bxL, lvlHi, bxR, lvlLo,
                         bgcolor=barClrBox, border_color=borderClr, border_width=isPoc ? 2 : 1)
                    array.push(profBoxes, b)

                    if showProfileLabels
                        string deltaTag = (isPoc ? "★ POC " : "") + f_vol(lvlDelta)
                        lbl = label.new(lx, lvlMid, deltaTag,
                             yloc=yloc.price, style=label.style_none, size=txtSz,
                             textcolor=isPoc ? pocColor : color.rgb(220, 220, 220))
                        array.push(profLabs, lbl)
````
