# VWAP Mean Reversion Scalper with Multi-SD Bands and CVD

- url: https://www.tradingview.com/script/pCzoghh1-VWAP-Mean-Reversion-Scalper-with-Multi-SD-Bands-and-CVD/
- type: indicator
- pine_id: PUB;cbf0a37a9ddf43759b8af378e9b0bb6c
- version: 1.0

## Description

The VWAP Mean Reversion Scalper is an execution-focused indicator designed to identify potential price exhaustion points at statistical extremes. It utilizes a Volume Weighted Average Price (VWAP) core with multiple standard deviation bands to define overextended market conditions, confirmed by real-time Volume Delta (CVD).

How It Works (Technical Logic)
This script identifies reversal setups based on the convergence of three primary data points:

Statistical Extremes (VWAP SD Bands): The indicator calculates three standard deviation bands based on the VWAP. These bands serve as dynamic "overbought" and "oversold" zones.
Universal Rejection: A signal is generated when a candle tests a band (or the VWAP mid-line) and closes in the opposite direction (e.g., price touches the upper band and closes as a red candle).
Cumulative Volume Delta (CVD) Confirmation: Using request.security_lower_tf, the script analyzes volume delta from a lower timeframe (e.g., 1-minute). A signal only confirms if the aggressive market orders (buying for longs, selling for shorts) align with the rejection direction.
Volatility Filtering: An optional ATR-based filter ensures that the rejection candle has sufficient range to represent a meaningful shift in momentum.
Unique Signal Filtering
To maintain a clean interface and avoid "signal clusters" during trending periods, the script uses a State-Based Filter:

Neutral Zone Reset: After a signal triggers at the outer bands, the script will not generate another signal in that direction until price returns to the "Neutral Zone" (the area between the SD 1.0 bands).
Scaling Logic: The indicator permits "scaling in" signals if the price moves to a deeper standard deviation level (e.g., from SD 2 to SD 3) before returning to the mean.
Usage & Best Practices
Timeframes: Optimized for intraday scalping (1m, 5m, 15m).
Execution: Ideal targets are the VWAP mid-line (mean) or the opposite SD 1 band.
CVD Setup: For the most accurate delta readings, ensure the "CVD Calculation Timeframe" in settings is set to 1-minute or lower.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tradedailywithseb

//@version=6
indicator("VWAP Mean Reversion Scalper with Multi-SD Bands and CVD", shorttitle="VWAP MR Scalper", overlay = true, max_labels_count = 500)

// --- Groups ---
var G_VWAP     = "VWAP Settings"
var G_CVD      = "CVD (Volume Delta)"
var G_FILTER   = "Signal Filtering"
var G_VOL      = "Volatility Filter"
var G_STYLE    = "Style Settings"

// --- Inputs ---
vwapAnchor     = input.string("Session", "VWAP Anchor", options = ["Session", "Week", "Month", "Year"], group = G_VWAP, tooltip = "The timeframe to reset the VWAP calculation.")
sdMult1        = input.float(1.0, "SD Multiplier 1", minval = 0.1, step = 0.1, group = G_VWAP, tooltip = "First standard deviation band multiplier.")
sdMult2        = input.float(2.0, "SD Multiplier 2", minval = 0.1, step = 0.1, group = G_VWAP, tooltip = "Second standard deviation band multiplier.")
sdMult3        = input.float(3.0, "SD Multiplier 3", minval = 0.1, step = 0.1, group = G_VWAP, tooltip = "Third standard deviation band multiplier.")

cvdThreshold   = input.float(0, "CVD Delta Threshold", group = G_CVD, tooltip = "Minimum relative delta required for confirmation. Signals only trigger if volume delta matches price direction.")
lowerTf        = input.timeframe("1", "CVD Calculation Timeframe", group = G_CVD, tooltip = "The lower timeframe used to compute volume delta (e.g., 1-minute).")

cleanSignals   = input.bool(true, "Clean Signal Mode", group = G_FILTER, tooltip = "Prevents signal clustering by requiring price to return to the neutral zone (SD1 bands) before another signal in the same direction.")
cooldown       = input.int(5, "Signal Cooldown (Bars)", minval = 0, group = G_FILTER, tooltip = "Minimum number of bars between consecutive signals.")
showVwapSignals = input.bool(true, "Show VWAP Rejection Signals", group = G_FILTER, tooltip = "Toggle signals for price rejecting the VWAP mid-line.")

useVolFilter   = input.bool(false, "Use Volatility Filter", group = G_VOL, tooltip = "Filters signals based on the range of the rejection candle compared to ATR.")
volLength      = input.int(20, "ATR Lookback", minval = 1, group = G_VOL)
volMult        = input.float(1.0, "Min Range Multiplier", minval = 0.1, step = 0.1, group = G_VOL, tooltip = "Rejection candle range must be at least this multiple of ATR.")

bullColor      = input.color(#089981, "Bullish Color", group = G_STYLE)
bearColor      = input.color(#f23645, "Bearish Color", group = G_STYLE)
vwapColor      = input.color(color.gray, "VWAP Color", group = G_STYLE)

// --- VWAP with Multi-SD Bands Calculation ---
var anchor = switch vwapAnchor
    "Session" => "D"
    "Week"    => "W"
    "Month"   => "M"
    "Year"    => "12M"

newSession = timeframe.change(anchor)

var float vwapSum = 0.0
var float volSum = 0.0
var float vwapSumSq = 0.0

if newSession
    vwapSum := 0.0
    volSum := 0.0
    vwapSumSq := 0.0

vwapSum   += hlc3 * volume
volSum    += volume
vwapSumSq += volume * math.pow(hlc3, 2)

vwapValue = vwapSum / volSum
variance  = vwapSumSq / volSum - math.pow(vwapValue, 2)
stdev     = math.sqrt(math.max(0, variance))

// Bands
vU1 = vwapValue + stdev * sdMult1
vU2 = vwapValue + stdev * sdMult2
vU3 = vwapValue + stdev * sdMult3
vL1 = vwapValue - stdev * sdMult1
vL2 = vwapValue - stdev * sdMult2
vL3 = vwapValue - stdev * sdMult3

// --- CVD Logic ---
f_getCVD() =>
    float d = volume * math.sign(close - open)
    d

cvdArray = request.security_lower_tf(syminfo.tickerid, lowerTf, f_getCVD())
float currentDelta = 0.0
if not na(cvdArray) and array.size(cvdArray) > 0
    for i = 0 to array.size(cvdArray) - 1
        currentDelta += array.get(cvdArray, i)

isDeltaPos = currentDelta > cvdThreshold
isDeltaNeg = currentDelta < -cvdThreshold

// --- Volatility Logic ---
atrValue = ta.atr(volLength)
rangeOk = not useVolFilter or (high - low) >= (atrValue * volMult)

// --- Rejection Logic ---
int upperLevel = high >= vU3 ? 3 : high >= vU2 ? 2 : high >= vU1 ? 1 : 0
int lowerLevel = low <= vL3 ? 3 : low <= vL2 ? 2 : low <= vL1 ? 1 : 0
upperTouched = upperLevel > 0
lowerTouched = lowerLevel > 0
vwapTouched = low <= vwapValue and high >= vwapValue

isBullishRejection = close > open and (lowerTouched or vwapTouched)
isBearishRejection = close < open and (upperTouched or vwapTouched)

// --- Cleaning & State Logic ---
var int lastSignalBar = 0
var int lastDirection = 0 // 1 for Long, -1 for Short
var int lastLevel = 0
var bool neutralZoneReached = true

// Reset Zone (SD1 to SD1)
isInNeutralZone = low <= vU1 and high >= vL1
if isInNeutralZone
    neutralZoneReached := true

// Raw Signal Detection
rawLong  = isBullishRejection and isDeltaPos and rangeOk
rawShort = isBearishRejection and isDeltaNeg and rangeOk

// Filter Conditions
currentLowerLevel = lowerTouched ? lowerLevel : (vwapTouched ? 0 : -1)
currentUpperLevel = upperTouched ? upperLevel : (vwapTouched ? 0 : -1)

canLong  = not cleanSignals or (lastDirection != 1 or neutralZoneReached or (currentLowerLevel != -1 and currentLowerLevel > lastLevel))
canShort = not cleanSignals or (lastDirection != -1 or neutralZoneReached or (currentUpperLevel != -1 and currentUpperLevel > lastLevel))

cooldownActive = (bar_index - lastSignalBar) < cooldown

longSignal  = rawLong and canLong and not cooldownActive and (lowerTouched or (showVwapSignals and vwapTouched))
shortSignal = rawShort and canShort and not cooldownActive and (upperTouched or (showVwapSignals and vwapTouched))

if longSignal
    lastSignalBar := bar_index
    lastDirection := 1
    lastLevel := currentLowerLevel
    neutralZoneReached := false

if shortSignal
    lastSignalBar := bar_index
    lastDirection := -1
    lastLevel := currentUpperLevel
    neutralZoneReached := false

// --- Visuals ---
plot(vwapValue, "VWAP", vwapColor, 2)
pU1 = plot(vU1, "Upper SD 1", color.new(bearColor, 60))
pU2 = plot(vU2, "Upper SD 2", color.new(bearColor, 40))
pU3 = plot(vU3, "Upper SD 3", color.new(bearColor, 20))
pL1 = plot(vL1, "Lower SD 1", color.new(bullColor, 60))
pL2 = plot(vL2, "Lower SD 2", color.new(bullColor, 40))
pL3 = plot(vL3, "Lower SD 3", color.new(bullColor, 20))

fill(pU1, pU2, color.new(bearColor, 90), "Upper Fill 1-2")
fill(pU2, pU3, color.new(bearColor, 85), "Upper Fill 2-3")
fill(pL1, pL2, color.new(bullColor, 90), "Lower Fill 1-2")
fill(pL2, pL3, color.new(bullColor, 85), "Lower Fill 2-3")

// Labels
plotshape(longSignal and vwapTouched and not lowerTouched,  "VWAP Long",  shape.triangleup,   location.belowbar, bullColor, 0, "VWAP LONG",  chart.fg_color, size = size.small)
plotshape(longSignal and lowerTouched,  "Band Bull Rejection",  shape.triangleup,   location.belowbar, bullColor, 0, "BULL REJECTION",  chart.fg_color, size = size.small)

plotshape(shortSignal and vwapTouched and not upperTouched, "VWAP Short", shape.triangledown, location.abovebar, bearColor, 0, "VWAP SHORT", chart.fg_color, size = size.small)
plotshape(shortSignal and upperTouched, "Band Bear Rejection", shape.triangledown, location.abovebar, bearColor, 0, "BEAR REJECTION", chart.fg_color, size = size.small)

alertcondition(longSignal, "Long Rejection", "VWAP/SD Universal Rejection Long")
alertcondition(shortSignal, "Short Rejection", "VWAP/SD Universal Rejection Short")
````
