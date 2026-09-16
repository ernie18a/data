<!-- tradingview-pine-id: PUB;adae6bf8fdcd4687b40fd7651ab3283c -->
<!-- tradingview-pine-version: 5.0 -->
<!-- tradingviewscripts-format: 1 -->
# Markus Channel v3

Source: https://www.tradingview.com/script/jxSzAth6-Markus-Channel-Dual-Expansion-Envelopes-V1/

## Description

Markus Channel + Dual Expansion Envelopes (Crossover Multiplier MA)

█ OVERVIEW

Markus Channel + Dual Expansion Envelopes is a multi-layer expansion trading system originally designed and calibrated around XAUUSD for spot traders.

Most retail brokers (Vantage, IC Markets, Pepperstone, etc.) do not provide a true order book or Level 2 data on gold. The only reliable real-time participation metric available is tick volume. This indicator was built from the ground up to extract maximum information from tick volume and turn it into a clean, adaptive expansion framework.

At its core sits an original hybrid construction — the Markus Channel — which fuses a volume-sensitive Keltner core with the statistical width of Bollinger Bands. Around this core, two adaptive outer envelopes (Orange Expansion + Blue Trigger) and a dynamic Crossover Multiplier MA are projected.

The result is a complete visual hierarchy for gold expansion / breakout trading when you only have tick volume to work with:

Core structure → First expansion → Confirmed expansion → Dynamic multiplier targets

█ HOW IT WORKS

⚪ 1. Auto MA Selection Engine (Adaptive AI)

Five classic moving averages are calculated in parallel (SMA, EMA, RMA, WMA, VWMA).

Each candidate is scored using a combined error function:

Lag Error = SMA( (MA − Source)² , length )
Jitter    = SMA( (ΔMA)² , length )
Score     = Lag Error + (Jitter × Penalty)

The MA with the lowest score is automatically selected. This keeps the center line optimally responsive on the highly volatile XAUUSD tick stream.

⚪ 2. Markus Channel (Original Hybrid Construction for Spot Gold)

Because no real order book is available, the entire channel is driven by tick volume:

1. Midline = Auto-selected MA of close (Base Center Length)
2. Bollinger Bands = Midline ± (StdDev × BB Multiplier)
3. Tick Volume Ratio = Volume / SMA(Volume, Vol Length)
4. Dynamic Keltner Multiplier = clamp( 3.0 + (Volume Ratio − 1) × Volume Sensitivity , 3.0 , 4.0 )
5. Keltner Bands = Midline ± (ATR × Dynamic Multiplier)
6. Band Difference = Bollinger − Keltner
7. Smoothed Difference = SMA(Band Difference, Diff MA Length)

Final Markus Bands:
Markus Upper = Keltner Upper + Smoothed Upper Difference
Markus Lower = Keltner Lower + Smoothed Lower Difference

This construction allows the channel to:
• Expand aggressively when tick volume spikes (the only real-time participation signal available on most brokers)
• Retain the statistical properties of Bollinger Bands
• Smooth the difference so the final bands remain stable even during gold’s fast moves

⚪ 3. Orange Expansion Envelope

Channel Width = Markus Upper − Markus Lower
Average Width = SMA(Channel Width, Expansion MA Length)
Volume Boost  = 1 + max(0, Tick Volume Ratio − 1) × Orange Volume Boost

Orange Offset = (Average Width × 0.5 × Orange Base Multiplier) × Volume Boost

Orange Upper / Lower = Markus Bands ± Orange Offset

Optional “Breakouts Only” mode keeps the chart clean until price actually leaves the Markus channel.

⚪ 4. Blue Trigger Channel

Two memory modes designed for gold’s expansion behavior:

• Dynamic Tracking – slowly decays after the expansion ends  
• Hold Peak Level – latches the extreme expansion level until a new expansion occurs

A final volatility buffer (scaled by the same tick-volume boost) is applied to create the Blue Trigger zone.

⚪ 5. Crossover Multiplier MA Engine

On every cross of the selected target (Midline / Markus / Orange / Blue):

Raw Multiplier = Dynamic Keltner Multiplier × Tick Volume Ratio

The multiplier is latched on the cross and smoothed by the Auto MA engine. Projection lines are then drawn:

Cross Upper / Lower = Midline ± (ATR × Smoothed Multiplier)

These lines act as adaptive, volume-scaled targets that expand and contract with real participation — critical when trading XAUUSD without an order book.

█ HOW TO USE (XAUUSD Spot Focus)

• Expansion Detection  
  Background turns green/red when price breaks a Markus band while channel width is expanding on rising tick volume.

• First Target  
  Orange Envelope = initial expansion objective on gold.

• High-Conviction Expansion  
  Blue Trigger Channel = stronger expansion zone (especially useful in Hold Peak mode during London/NY gold sessions).

• Dynamic Targets After Cross  
  Crossover Multiplier lines provide live support/resistance that scale with the intensity of the tick-volume surge.

• Regime Context  
  The HUD shows active MA type, current multiplier strength, expansion state, and bullish/bearish regime at a glance.

Built specifically for traders who trade gold spot CFDs and only have tick volume as their real-time activity metric.

█ SETTINGS

• Auto MA Selection Engine – Adaptive AI or Manual  
• Markus Engine – Base length, BB multiplier, ATR length, tick-volume sensitivity, difference MA  
• Orange Expansion Envelope – Base multiplier + volume boost + breakout-only mode  
• Blue Trigger Channel – Buffer size + Dynamic / Hold Peak memory  
• Crossover Multiplier MA – Target layer + smoothing length  
• Full visual control (clouds, backgrounds, candle coloring, HUD, colors)

█ NOTES

The Markus Channel is an original hybrid construction developed and tuned on XAUUSD. It deliberately uses tick volume (the only participation data most brokers provide) instead of relying on a non-existent order book. All outer envelopes and the Crossover Multiplier engine are derived from this core structure.

Licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.
Not financial advice !

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
//                                  INDICATOR INITIALIZATION                                     }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
// Initializes the Markus Channel v3 Pine Script v6 indicator instance with chart overlay enabled, 
// a 2100 historical bar buffer for dynamic array calculations, and decimal precision formatting.

//@version=6
indicator('Markus Channel v3', overlay = true, max_bars_back = 2100, precision = 2)

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
//                                    USER INPUTS & CONFIG                                       }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
// Defines UI tooltip documentation, input controls for the adaptive MA selector, volatility/ATR 
// parameters, expansion envelope multipliers, trigger channels, crossover monitoring, and visual themes.

// ── Tooltip Documentation ─────────────────────────────────────────────────────
var string t1  = "AUTO MA SELECTION MODE\n\n'Auto (Adaptive Scoring)' dynamically evaluates SMA, EMA, WMA, RMA, and VWMA candidates, selecting the MA with the lowest combined tracking error and jitter penalty."
var string t2  = "BASE CENTER LENGTH\n\nThe lookback period for the primary center moving average that anchors the Bollinger and Keltner components of the Markus Channel."
var string t3  = "BOLLINGER BANDS MULTIPLIER\n\nStandard deviation multiplier applied to the outer Bollinger component."
var string t4  = "ATR LENGTH\n\nLookback period for Average True Range used in the Keltner component of the Markus Channel."
var string t5  = "TICK VOLUME SENSITIVITY\n\nDynamically scales the Keltner expansion multiplier between 3.0 and 4.0 during volume spikes."
var string t6  = "BAND DIFFERENCE MA LENGTH\n\nLookback period for the moving average applied to the difference between Bollinger and Keltner outer bands."
var string t7  = "ENVELOPE BASE MULTIPLIER\n\nBase width factor applied to the smoothed Markus channel width to project the outer Expansion Envelope."
var string t8  = "ENVELOPE VOLUME BOOST\n\nControls how strongly tick-volume expansion pushes the Expansion Envelope outward."
var string t9  = "TRIGGER BUFFER MULTIPLIER\n\nProportional width scalar that determines the outer Trigger Channel bounds."
var string t10 = "TRIGGER TRACKING MODE\n\n'Dynamic Tracking' continuously updates via the Expansion MA.\n'Hold Peak Level' latches the maximum expansion levels."
var string t11 = "CROSSOVER MULTIPLIER ENGINE\n\nTracks band crosses and calculates a dynamic multiplier (Keltner Multiplier × Volume/Pattern Ratio). This product is smoothed by an MA to project adaptive overlay lines."
var string t12 = "LIQUIDITY MEAN BLEND\n\n0 = pure Adaptive MA | 1 = pure Liquidity-Acceptance Mean.\n0.40 is a balanced starting point for most markets."
var string t13 = "ASYMMETRY STRENGTH\n\nHow strongly upper/lower wicks expand the respective side of the Markus Channel."

// ── Auto MA Selection Engine Inputs ───────────────────────────────────────────
maSelectMode = input.string("Auto (Adaptive Scoring)", 'MA Selection Engine', options = ["Auto (Adaptive Scoring)", "Manual Choice"], group = "Auto MA Selection Engine", tooltip = t1)
manualMaType = input.string("EMA", 'Manual MA Selection', options = ["EMA", "SMA", "SMMA (RMA)", "WMA", "VWMA"], group = "Auto MA Selection Engine", active = maSelectMode == "Manual Choice")
noisePenalty = input.float(1.5, 'Auto MA Jitter Penalty', minval = 0.1, maxval = 5.0, step = 0.1, group = "Auto MA Selection Engine", active = maSelectMode == "Auto (Adaptive AI)")
hystMargin   = input.float(0.10, 'MA Switch Hysteresis', minval = 0.0, maxval = 0.5, step = 0.05, group = "Auto MA Selection Engine", tooltip = "Minimum relative score improvement required before switching MA type. Higher = more stable center line, less reactive to noise.", active = maSelectMode == "Auto (Adaptive Scoring)")

// ── Core Channel Engine Inputs ────────────────────────────────────────────────
baseLen   = input.int(13, 'Base Center Length', minval = 1, group = "Core Channel Engine", tooltip = t2)
bbMult    = input.float(1.6, 'Bollinger Bands StdDev', minval = 0.1, step = 0.1, group = "Core Channel Engine", tooltip = t3)
atrLen    = input.int(9, 'Keltner ATR Length', minval = 1, group = "Core Channel Engine", tooltip = t4)
volLen    = input.int(20, 'Tick Volume MA Length', minval = 1, group = "Core Channel Engine")
volSens   = input.float(0.5, 'Volume Expansion Factor', minval = 0.0, step = 0.1, group = "Core Channel Engine", tooltip = t5)
diffMaLen = input.int(10, 'Band Diff MA Length', minval = 1, group = "Core Channel Engine", tooltip = t6)

liqBlend  = input.float(0.40, 'Liquidity Mean Blend', minval = 0.0, maxval = 1.0, step = 0.05, group = "Core Channel Engine", tooltip = t12)
asymStr   = input.float(0.15, 'Asymmetry Strength', minval = 0.0, maxval = 0.50, step = 0.05, group = "Core Channel Engine", tooltip = t13)

// ── Expansion Envelope Inputs ────────────────────────────────────────────────
showEnvelope   = input.bool(true, 'Show Expansion Envelope', inline = 'e1', group = "Expansion Envelope")
onlyOnBreakout = input.bool(false, 'Breakouts Only', inline = 'e1', group = "Expansion Envelope")
envLen         = input.int(14, 'Expansion MA Length', minval = 1, group = "Expansion Envelope")
envMult        = input.float(0.5, 'Envelope Base Multiplier', minval = 0.05, step = 0.05, group = "Expansion Envelope", tooltip = t7)
envVolSens     = input.float(0.6, 'Envelope Volume Boost', minval = 0.0, step = 0.1, group = "Expansion Envelope", tooltip = t8)
longAtrLen     = input.int(200, 'Long-Term ATR Length (Normalization)', minval = 50, group = "Expansion Envelope", tooltip = "Longer-horizon ATR used to keep envelope/trigger width consistent across quiet vs. volatile sessions.")

// ── Envelope Outside Timer Settings ──────────────────────────────────────────
showDwellStats = input.bool(true, 'Show Outside Envelope Stats', group = "Expansion Envelope", tooltip = "Tracks time spent when price closes OUTSIDE the outer Expansion Envelope.")
dwellLookback  = input.int(20, 'Dwell Lookback (# of streaks)', minval = 5, group = "Expansion Envelope", tooltip = "Number of most recent outside envelope streaks averaged.")

// ── Trigger Channel Inputs ───────────────────────────────────────────────────
showTrigger   = input.bool(true, 'Show Trigger Channel', group = "Trigger Channel")
trigBuffMult  = input.float(0.25, 'Trigger Buffer Multiplier', minval = 0.0, step = 0.05, group = "Trigger Channel", tooltip = t9)
trigTrackMode = input.string("Dynamic Tracking", 'Trigger Memory Mode', options = ["Dynamic Tracking", "Hold Peak Level"], group = "Trigger Channel", tooltip = t10)
trigSmoothLen = input.int(4, 'Trigger Smoothing Length', minval = 1, group = "Trigger Channel", tooltip = "Short fixed EMA applied to the latched trigger levels.")

// ── Crossover Multiplier Engine Inputs ───────────────────────────────────────
showCrossMA         = input.bool(true, 'Show Crossover Dynamic Lines', inline = 'cm', group = "Crossover Multiplier Engine", tooltip = t11)
crossTarget         = input.string("Markus Bands", 'Cross Monitoring Target', options = ["Midline", "Markus Bands", "Expansion Envelope", "Trigger Channel"], inline = 'cm', group = "Crossover Multiplier Engine")
crossMaLen          = input.int(14, 'Multiplier MA Smoothing Length', minval = 1, group = "Crossover Multiplier Engine")
useSignalFilter     = input.bool(true, 'Filter Crossovers by Tension/Volume', group = "Crossover Multiplier Engine")
tensionThresh       = input.float(0.25, 'Tension Threshold', minval = 0.0, maxval = 1.0, step = 0.05, group = "Crossover Multiplier Engine")
requireVolExpansion = input.bool(true, 'Require Volume Expansion', group = "Crossover Multiplier Engine")

// ── Visual Settings Inputs ────────────────────────────────────────────────────
paintBars       = input.bool(true, 'Candle Coloring', inline = 'v1', group = "Visual Settings")
showCloud       = input.bool(true, 'Multi-Layer Cloud', inline = 'v1', group = "Visual Settings")
showDash        = input.bool(true, 'Show Dashboard HUD', group = "Visual Settings")
useTensionColor = input.bool(true, 'Use Liquidity-Warp Tension Color', group = "Visual Settings")

// ── Color Theme Inputs ────────────────────────────────────────────────────────
colUpper   = input.color(#E040FB, 'Upper', inline = 'col', group = "Colors")
colLower   = input.color(#00E5FF, 'Lower', inline = 'col', group = "Colors")
colEnv     = input.color(#FF9800, 'Envelope', inline = 'col2', group = "Colors")
colTrig    = input.color(#00B0FF, 'Trigger', inline = 'col2', group = "Colors")
colCross   = input.color(color.white, 'Crossover', inline = 'col2', group = "Colors")
colMid     = input.color(#FF00E5, 'Midline', inline = 'col2', group = "Colors")
colNeutral = input.color(color.silver, 'Neutral Tension', group = "Colors")

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
//                                 CALCULATIONS & CORE ENGINE                                    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
// Houses custom utility algorithms, MA scoring routines, liquidity weighting functions, volatility 
// normalizations, and outside dwell time statistics calculation logic.

// ── Duration Formatting Utility ───────────────────────────────────────────────
// @function Converts raw time in minutes into a formatted human-readable duration string.
f_fmtDuration(float minutes) =>
    string result = "n/a"
    if not na(minutes)
        float totalSeconds = minutes * 60
        if totalSeconds < 60
            result := str.tostring(math.round(totalSeconds)) + "s"
        else if minutes < 60
            int wholeMin = math.floor(minutes)
            int remSec   = math.round((minutes - wholeMin) * 60)
            result := remSec > 0 ? str.tostring(wholeMin) + "m " + str.tostring(remSec) + "s" : str.tostring(wholeMin) + "m"
        else
            int wholeHr  = math.floor(minutes / 60)
            int remMin   = math.round(minutes - wholeHr * 60)
            result := str.tostring(wholeHr) + "h " + str.tostring(remMin) + "m"
    result

// ── MA Scoring & Selection Engine ──────────────────────────────────────────────
// @function Calculates a penalty score for a candidate moving average using Mean Squared Error lag and jitter.
f_scoreMA(float srcVal, float candVal, int len, float penalty) =>
    float lagError = ta.sma(math.pow(candVal - srcVal, 2), len)
    float jitter   = ta.sma(math.pow(ta.change(candVal), 2), len)
    lagError + (jitter * penalty)

// @function Dynamically evaluates SMA, EMA, RMA, WMA, and VWMA types to select the best performer with hysteresis.
f_autoSelectMA(float srcVal, int len, float pen, string manualType, bool isAuto, float hyst) =>
    candSMA  = ta.sma(srcVal, len)
    candEMA  = ta.ema(srcVal, len)
    candRMA  = ta.rma(srcVal, len)
    candWMA  = ta.wma(srcVal, len)
    candVWMA = ta.vwma(srcVal, len)

    sSMA  = f_scoreMA(srcVal, candSMA, len, pen)
    sEMA  = f_scoreMA(srcVal, candEMA, len, pen)
    sRMA  = f_scoreMA(srcVal, candRMA, len, pen)
    sWMA  = f_scoreMA(srcVal, candWMA, len, pen)
    sVWMA = f_scoreMA(srcVal, candVWMA, len, pen)

    var string prevChoice = na
    float selectedMA = candEMA
    string maName    = "EMA"

    if isAuto
        float bestScore = sEMA
        float bestMA    = candEMA
        string bestName = "EMA"
        if sSMA < bestScore
            bestScore := sSMA
            bestMA    := candSMA
            bestName  := "SMA"
        if sWMA < bestScore
            bestScore := sWMA
            bestMA    := candWMA
            bestName  := "WMA"
        if sRMA < bestScore
            bestScore := sRMA
            bestMA    := candRMA
            bestName  := "RMA"
        if sVWMA < bestScore
            bestScore := sVWMA
            bestMA    := candVWMA
            bestName  := "VWMA"

        if na(prevChoice)
            selectedMA := bestMA
            maName     := bestName
            prevChoice := bestName
        else
            float prevScore = switch prevChoice
                "SMA"  => sSMA
                "EMA"  => sEMA
                "RMA"  => sRMA
                "WMA"  => sWMA
                "VWMA" => sVWMA
                => sEMA
            if bestScore < prevScore * (1.0 - hyst)
                selectedMA := bestMA
                maName     := bestName
                prevChoice := bestName
            else
                selectedMA := switch prevChoice
                    "SMA"  => candSMA
                    "EMA"  => candEMA
                    "RMA"  => candRMA
                    "WMA"  => candWMA
                    "VWMA" => candVWMA
                    => candEMA
                maName := prevChoice
    else
        selectedMA := switch manualType
            "SMA"        => candSMA
            "EMA"        => candEMA
            "SMMA (RMA)" => candRMA
            "WMA"        => candWMA
            "VWMA"       => candVWMA
            => candEMA
        maName := manualType

    [selectedMA, maName]

// ── Liquidity-Acceptance Mean Algorithm ───────────────────────────────────────
// @function Calculates a Liquidity-Acceptance Mean weighted by volume expansion relative to true range and wick pressure.
f_liqMean(src, len) =>
    tr = ta.tr(true)
    va = ta.sma(volume, len)
    ra = ta.sma(tr, len)
    vr = va > 0 ? volume / va : 1.0
    rr = ra > syminfo.mintick ? tr / ra : 1.0
    ab = math.max(0.15, math.min(6.0, vr / math.max(rr, 0.20)))
    wt = math.pow(ab, 1.1)

    uw = math.max(0.0, high - math.max(open, close))
    dw = math.max(0.0, math.min(open, close) - low)
    ap = close + 0.105 * (dw - uw)

    sum  = 0.0
    wsum = 0.0
    for i = 0 to len - 1
        v = ap[i]
        q = nz(wt[i], 0.0)
        if not na(v) and q > 0
            sum  += v * q
            wsum += q

    float smaFallback = ta.sma(src, len)
    wsum > 0 ? sum / wsum : smaFallback

// ── Primary Centerline & Band Calculations ────────────────────────────────────
bool isAutoMA = maSelectMode == "Auto (Adaptive Scoring)"
[rawMid, activeMaName] = f_autoSelectMA(close, baseLen, noisePenalty, manualMaType, isAutoMA, hystMargin)

liqMid  = f_liqMean(close, baseLen)
midLine = rawMid * (1.0 - liqBlend) + liqMid * liqBlend

volMa    = ta.sma(volume, volLen)
volRatio = volMa > 0 ? volume / volMa : 1.0
kcMult   = math.min(4.0, math.max(3.0, 3.0 + (volRatio - 1.0) * volSens))

uw = math.max(0.0, high - math.max(open, close))
dw = math.max(0.0, math.min(open, close) - low)
ur = ta.rma(uw, baseLen)
lr = ta.rma(dw, baseLen)
atrVal = ta.atr(atrLen)
longAtrVal      = ta.atr(longAtrLen)
volNormFactor   = longAtrVal > 0 ? atrVal / longAtrVal : 1.0
volNormClamped  = math.max(0.5, math.min(2.0, volNormFactor))
upMult = bbMult * (1.0 + asymStr * (ur / math.max(atrVal, syminfo.mintick)))
dnMult = bbMult * (1.0 + asymStr * (lr / math.max(atrVal, syminfo.mintick)))

bbStd   = ta.stdev(close, baseLen)
bbUpper = midLine + (bbStd * upMult)
bbLower = midLine - (bbStd * dnMult)

kcUpper = midLine + (atrVal * kcMult)
kcLower = midLine - (atrVal * kcMult)

diffUpper   = bbUpper - kcUpper
diffLower   = bbLower - kcLower
maDiffUpper = ta.sma(diffUpper, diffMaLen)
maDiffLower = ta.sma(diffLower, diffMaLen)

MCUpper = kcUpper + maDiffUpper
MCLower = kcLower + maDiffLower

// ── Expansion Envelope Engine Calculations ────────────────────────────────────
MCWidth    = MCUpper - MCLower
avgMCWidth = ta.sma(MCWidth, envLen)

envVolBoost = 1.0 + math.max(0.0, volRatio - 1.0) * envVolSens
envOffset   = (avgMCWidth * 0.5 * envMult) * envVolBoost * volNormClamped

envUpper = MCUpper + envOffset
envLower = MCLower - envOffset

isUpperExpansion = high >= MCUpper
isLowerExpansion = low  <= MCLower
isWidthExpanding = MCWidth > avgMCWidth

plotEnvUpper = showEnvelope and (not onlyOnBreakout or isUpperExpansion) ? envUpper : na
plotEnvLower = showEnvelope and (not onlyOnBreakout or isLowerExpansion) ? envLower : na

// ── Outside Envelope Dwell Tracking ───────────────────────────────────────────
bool isOutsideEnvelope = close > envUpper or close < envLower

var int outsideDwellBars           = 0
var array<int> outsideDwellHistory = array.new_int(0)
int maxSaneStreak                  = 500

if barstate.isconfirmed
    if isOutsideEnvelope
        outsideDwellBars += 1
    else
        if outsideDwellBars > 0
            if outsideDwellBars <= maxSaneStreak
                array.push(outsideDwellHistory, outsideDwellBars)
                if array.size(outsideDwellHistory) > dwellLookback
                    array.shift(outsideDwellHistory)
            outsideDwellBars := 0

float avgOutsideDwellBars = array.size(outsideDwellHistory) > 0 ? array.avg(outsideDwellHistory) : na

float barSeconds             = timeframe.in_seconds(timeframe.period)
float currentOutsideDwellMin = outsideDwellBars * barSeconds / 60
float avgOutsideDwellMin     = na(avgOutsideDwellBars) ? na : avgOutsideDwellBars * barSeconds / 60

// ── Trigger Channel Peak & Tracking Calculations ──────────────────────────────
var float latchedUpperTrigger = na
var float latchedLowerTrigger = na

if isUpperExpansion
    latchedUpperTrigger := trigTrackMode == "Hold Peak Level" ? math.max(nz(latchedUpperTrigger, envUpper), envUpper) : envUpper
else if trigTrackMode == "Dynamic Tracking" and not isUpperExpansion
    latchedUpperTrigger := math.max(MCUpper, nz(latchedUpperTrigger, MCUpper) - (avgMCWidth / envLen))

if isLowerExpansion
    latchedLowerTrigger := trigTrackMode == "Hold Peak Level" ? math.min(nz(latchedLowerTrigger, envLower), envLower) : envLower
else if trigTrackMode == "Dynamic Tracking" and not isLowerExpansion
    latchedLowerTrigger := math.min(MCLower, nz(latchedLowerTrigger, MCLower) + (avgMCWidth / envLen))

rawTrigUpper = nz(latchedUpperTrigger, envUpper)
rawTrigLower = nz(latchedLowerTrigger, envLower)

smoothedTrigUpper = ta.ema(rawTrigUpper, trigSmoothLen)
smoothedTrigLower = ta.ema(rawTrigLower, trigSmoothLen)

trigBuffer     = (avgMCWidth * trigBuffMult) * envVolBoost * volNormClamped
finalTrigUpper = smoothedTrigUpper + trigBuffer
finalTrigLower = smoothedTrigLower - trigBuffer

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
//                                  SIGNAL & STATE LOGIC                                         }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
// Evaluates market tension, path efficiency ratios, target boundary crossover triggers, and 
// computes the adaptive crossover dynamic multiplier overlay series.

bool isCrossUpper = false
bool isCrossLower = false

switch crossTarget
    "Midline" =>
        isCrossUpper := ta.crossover(close, midLine)
        isCrossLower := ta.crossunder(close, midLine)
    "Markus Bands" =>
        isCrossUpper := ta.crossover(close, MCUpper)
        isCrossLower := ta.crossunder(close, MCLower)
    "Expansion Envelope" =>
        isCrossUpper := ta.crossover(close, envUpper)
        isCrossLower := ta.crossunder(close, envLower)
    "Trigger Channel" =>
        isCrossUpper := ta.crossover(close, finalTrigUpper)
        isCrossLower := ta.crossunder(close, finalTrigLower)

// Tension / Path Efficiency
peLen   = 5
pathEff = math.abs(close - close[peLen]) / math.max(ta.sma(math.abs(ta.change(close)), peLen) * peLen, syminfo.mintick)
tension = ta.ema((close > midLine ? 1.0 : -1.0) * pathEff, 8)

bool isAnyCross    = isCrossUpper or isCrossLower
bool longFilterOK  = (not useSignalFilter) or (tension > tensionThresh and (not requireVolExpansion or volRatio > 1.0))
bool shortFilterOK = (not useSignalFilter) or (tension < -tensionThresh and (not requireVolExpansion or volRatio > 1.0))

bool isSignalCrossUpper = isCrossUpper and longFilterOK
bool isSignalCrossLower = isCrossLower and shortFilterOK
bool isSignalCross      = isSignalCrossUpper or isSignalCrossLower

// Adaptive Crossover Multiplier Calculations
float rawCrossMult = kcMult * volRatio
var float latchedCrossMult = rawCrossMult
if isAnyCross
    latchedCrossMult := rawCrossMult

[smoothedCrossMult, _] = f_autoSelectMA(latchedCrossMult, crossMaLen, noisePenalty, manualMaType, isAutoMA, hystMargin)

float crossOffset    = atrVal * smoothedCrossMult
float crossUpperLine = midLine + crossOffset
float crossLowerLine = midLine - crossOffset

bool isBull = close > midLine

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
//                                   PLOTS & VISUALIZATION                                       }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
// Renders candle coloring, central Markus lines, expansion envelopes, trigger levels, crossover lines, 
// and multi-layered gradient clouds onto the chart canvas.

// ── Candle Coloring ───────────────────────────────────────────────────────────
color regimeColor = useTensionColor ? 
     (tension > 0.25 ? colUpper : tension < -0.25 ? colLower : colNeutral) : 
     (isBull ? colUpper : colLower)

color barCol = paintBars ? regimeColor : na
plotcandle(open, high, low, close, title = 'Candle Coloring', color = barCol, wickcolor = barCol, bordercolor = barCol)

// ── Crossover Dynamic Lines ───────────────────────────────────────────────────
plot(showCrossMA ? crossUpperLine : na, 'Crossover Upper', 
     color = colCross, linewidth = 2, style = plot.style_line, 
     linestyle = plot.linestyle_dotted)

plot(showCrossMA ? crossLowerLine : na, 'Crossover Lower', 
     color = colCross, linewidth = 2, style = plot.style_line, 
     linestyle = plot.linestyle_dotted)

// ── Primary Channel Lines ─────────────────────────────────────────────────────
pMid   = plot(midLine,  'Markus Center', color = color.new(colMid, 15), linewidth = 1)
pUpper = plot(MCUpper, 'Markus Upper',  color = color.new(colUpper, 10), linewidth = 1)
pLower = plot(MCLower, 'Markus Lower',  color = color.new(colLower, 10), linewidth = 1)

pEUpper = plot(plotEnvUpper, 'Envelope Upper', color = color.new(colEnv, 45), linewidth = 1, style = onlyOnBreakout ? plot.style_linebr : plot.style_line)
pELower = plot(plotEnvLower, 'Envelope Lower', color = color.new(colEnv, 45), linewidth = 1, style = onlyOnBreakout ? plot.style_linebr : plot.style_line)

pTUpper = plot(showTrigger and not na(latchedUpperTrigger) ? finalTrigUpper : na, 'Trigger Upper', color = color.new(colTrig, 50), linewidth = 1)
pTLower = plot(showTrigger and not na(latchedLowerTrigger) ? finalTrigLower : na, 'Trigger Lower', color = color.new(colTrig, 50), linewidth = 1)

// ── Multi-Layer Cloud – Inner Markus Bands ───────────────────────────────────
cloudA_Upper = midLine + (MCUpper - midLine) * 0.25
cloudB_Upper = midLine + (MCUpper - midLine) * 0.50
cloudC_Upper = midLine + (MCUpper - midLine) * 0.75

cloudA_Lower = midLine + (MCLower - midLine) * 0.25
cloudB_Lower = midLine + (MCLower - midLine) * 0.50
cloudC_Lower = midLine + (MCLower - midLine) * 0.75

pUA = plot(showCloud ? cloudA_Upper : na, display = display.none)
pUB = plot(showCloud ? cloudB_Upper : na, display = display.none)
pUC = plot(showCloud ? cloudC_Upper : na, display = display.none)
pLA = plot(showCloud ? cloudA_Lower : na, display = display.none)
pLB = plot(showCloud ? cloudB_Lower : na, display = display.none)
pLC = plot(showCloud ? cloudC_Lower : na, display = display.none)

fill(pMid, pUA,     color = showCloud ? color.new(colUpper, 90) : na, title = 'Inner Upper Cloud 1')
fill(pUA,  pUB,     color = showCloud ? color.new(colUpper, 82) : na, title = 'Inner Upper Cloud 2')
fill(pUB,  pUC,     color = showCloud ? color.new(colUpper, 74) : na, title = 'Inner Upper Cloud 3')
fill(pUC,  pUpper,  color = showCloud ? color.new(colUpper, 66) : na, title = 'Inner Upper Cloud 4')

fill(pMid, pLA,     color = showCloud ? color.new(colLower, 90) : na, title = 'Inner Lower Cloud 1')
fill(pLA,  pLB,     color = showCloud ? color.new(colLower, 82) : na, title = 'Inner Lower Cloud 2')
fill(pLB,  pLC,     color = showCloud ? color.new(colLower, 74) : na, title = 'Inner Lower Cloud 3')
fill(pLC,  pLower,  color = showCloud ? color.new(colLower, 66) : na, title = 'Inner Lower Cloud 4')

// ── Multi-Layer Cloud – Outer Expansion Envelope ─────────────────────────────
envCloudA_Upper = MCUpper + (envUpper - MCUpper) * 0.25
envCloudB_Upper = MCUpper + (envUpper - MCUpper) * 0.50
envCloudC_Upper = MCUpper + (envUpper - MCUpper) * 0.75

envCloudA_Lower = MCLower + (envLower - MCLower) * 0.25
envCloudB_Lower = MCLower + (envLower - MCLower) * 0.50
envCloudC_Lower = MCLower + (envLower - MCLower) * 0.75

pEUA = plot(showEnvelope and not na(plotEnvUpper) ? envCloudA_Upper : na, display = display.none)
pEUB = plot(showEnvelope and not na(plotEnvUpper) ? envCloudB_Upper : na, display = display.none)
pEUC = plot(showEnvelope and not na(plotEnvUpper) ? envCloudC_Upper : na, display = display.none)

pELA = plot(showEnvelope and not na(plotEnvLower) ? envCloudA_Lower : na, display = display.none)
pELB = plot(showEnvelope and not na(plotEnvLower) ? envCloudB_Lower : na, display = display.none)
pELC = plot(showEnvelope and not na(plotEnvLower) ? envCloudC_Lower : na, display = display.none)

fill(pUpper, pEUA,    color = showEnvelope and not na(plotEnvUpper) ? color.new(colEnv, 90) : na, title = 'Envelope Upper Cloud 1')
fill(pEUA,   pEUB,    color = showEnvelope and not na(plotEnvUpper) ? color.new(colEnv, 82) : na, title = 'Envelope Upper Cloud 2')
fill(pEUB,   pEUC,    color = showEnvelope and not na(plotEnvUpper) ? color.new(colEnv, 74) : na, title = 'Envelope Upper Cloud 3')
fill(pEUC,   pEUpper, color = showEnvelope and not na(plotEnvUpper) ? color.new(colEnv, 66) : na, title = 'Envelope Upper Cloud 4')

fill(pLower, pELA,    color = showEnvelope and not na(plotEnvLower) ? color.new(colEnv, 90) : na, title = 'Envelope Lower Cloud 1')
fill(pELA,   pELB,    color = showEnvelope and not na(plotEnvLower) ? color.new(colEnv, 82) : na, title = 'Envelope Lower Cloud 2')
fill(pELB,   pELC,    color = showEnvelope and not na(plotEnvLower) ? color.new(colEnv, 74) : na, title = 'Envelope Lower Cloud 3')
fill(pELC,   pELower, color = showEnvelope and not na(plotEnvLower) ? color.new(colEnv, 66) : na, title = 'Envelope Lower Cloud 4')

int trigTrans = isWidthExpanding ? 80 : 90
fill(pEUpper, pTUpper, color = showTrigger and not na(latchedUpperTrigger) ? color.new(colTrig, trigTrans) : na, title = 'Trigger Upper Fill')
fill(pELower, pTLower, color = showTrigger and not na(latchedLowerTrigger) ? color.new(colTrig, trigTrans) : na, title = 'Trigger Lower Fill')

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
//                                  DRAWINGS, LABELS & TABLES                                    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
// Dynamically creates and updates the floating HUD statistics table anchored to the top-right corner 
// of the chart displaying current engine state, MA selection, and dwell metrics.

var table hud = table.new(position = position.top_right, columns = 2, rows = 8, bgcolor = color.new(#0D0B14, 10), border_width = 1, border_color = color.new(color.gray, 60))

if barstate.islast and showDash
    table.cell(hud, 0, 0, "Engine MA",        text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 0, activeMaName + (isAutoMA ? " (Scoring)" : ""), text_color = colTrig, text_size = size.small)
    
    table.cell(hud, 0, 1, "Liq Blend",        text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 1, str.tostring(liqBlend, "#.##"), text_color = color.yellow, text_size = size.small)
    
    table.cell(hud, 0, 2, "Cross Target",     text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 2, crossTarget,        text_color = color.yellow, text_size = size.small)
    
    table.cell(hud, 0, 3, "Cross Multiplier", text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 3, str.tostring(smoothedCrossMult, "#.##"), text_color = colCross, text_size = size.small)
    
    table.cell(hud, 0, 4, "Expansion State",  text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 4, isWidthExpanding ? "Expanding" : "Neutral", text_color = isWidthExpanding ? colEnv : color.gray, text_size = size.small)
    
    table.cell(hud, 0, 5, "Regime",           text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 5, isBull ? "Bullish" : "Bearish", text_color = regimeColor, text_size = size.small)
    
    table.cell(hud, 0, 6, "Outside Envelope", text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 6, f_fmtDuration(isOutsideEnvelope ? currentOutsideDwellMin : 0.0), text_color = isOutsideEnvelope ? colEnv : color.gray, text_size = size.small)

    table.cell(hud, 0, 7, "Avg Outside Time", text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 7, f_fmtDuration(avgOutsideDwellMin), text_color = color.yellow, text_size = size.small)

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
//                                   ALERTS & CONDITION HOOKS                                    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
// Configures alert conditions and event hooks for crossover detection, with options for raw 
// crossovers and tension/volume confirmed signals.

alertcondition(isAnyCross, 'Markus Channel Cross', 'Price crossed selected target channel')

if barstate.isconfirmed and isAnyCross
    alert('🔔 Markus Channel Cross on ' + syminfo.ticker + ' (' + crossTarget + ') – Mult: ' + str.tostring(smoothedCrossMult, "#.##"), alert.freq_once_per_bar_close)

alertcondition(isSignalCross, 'Markus Channel Cross', 'Price crossed selected target channel (tension/volume confirmed)')
if barstate.isconfirmed and isSignalCross
    alert('🔔 Markus Channel Cross on ' + syminfo.ticker + ' (' + crossTarget + ') – Mult: ' + str.tostring(smoothedCrossMult, "#.##"), alert.freq_once_per_bar_close)
````
