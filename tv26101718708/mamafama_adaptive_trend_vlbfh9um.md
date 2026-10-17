# MAMA/FAMA Adaptive Trend

- url: https://www.tradingview.com/script/VlbFH9uM-MAMA-FAMA-Adaptive-Trend/
- type: indicator
- pine_id: PUB;dbd48128288c48eaa05bb5dbd82f732a
- version: 1.0

## Description

MAMA/FAMA Adaptive Trend

1. Overview

MAMA/FAMA Adaptive Trend is an adaptive moving average indicator based on John Ehlers' MESA Adaptive Moving Average concept.

https://www.tradingview.com/x/a6i2qcjj/

The indicator plots two adaptive lines:

* MAMA: the faster adaptive moving average
* FAMA: the slower following adaptive moving average

The tool is designed to help traders study adaptive trend state, trend transitions, and filtered MAMA/FAMA cross events directly on the price chart.

This is an indicator, not a strategy. It does not place orders, does not execute trades, and does not produce TradingView Strategy Tester backtest results. Entry and exit markers are visual chart events only and should not be treated as guaranteed trading signals or financial advice.

2. Core Idea

Traditional moving averages use fixed periods. MAMA/FAMA is different because it adapts its smoothing behavior according to the market's measured cycle and phase behavior.

When market phase changes quickly, MAMA can become more responsive.

When market movement is slower or steadier, MAMA can smooth more heavily.

FAMA follows MAMA using a slower adaptive response.

The relationship between MAMA and FAMA is used to define the current adaptive trend state:

* MAMA above FAMA suggests a bullish adaptive state.
* MAMA below FAMA suggests a bearish adaptive state.

3. MAMA and FAMA Lines

MAMA

MAMA is the faster adaptive line. It reacts more quickly to changes in price behavior.

FAMA

FAMA is the following adaptive line. It is slower than MAMA and provides a smoother reference.

MAMA/FAMA Fill

The area between MAMA and FAMA can be filled:

* Green fill suggests a bullish adaptive state.
* Red fill suggests a bearish adaptive state.

This fill is visual context only. It does not guarantee future price direction.

4. Adaptive Trend State

The indicator uses the position of MAMA relative to FAMA to define trend state.

Bullish state

A bullish adaptive state occurs when MAMA is above FAMA.

Bearish state

A bearish adaptive state occurs when MAMA is below FAMA.

The color of the MAMA line and the fill can change according to this state.

5. Entry Filters

The script includes entry filters designed to reduce weak crosses in sideways or noisy markets.

The entry filters are applied only to entry markers.

Exit markers use separate logic and are not blocked by the same entry filters.

Minimum MAMA/FAMA Gap Filter

This filter checks whether the distance between MAMA and FAMA is large enough relative to ATR.

The logic is based on:

MAMA/FAMA gap divided by ATR

If the gap is too small, the cross can be ignored as a weak entry event.

Default settings:

* Gap ATR length: 12
* Minimum gap in ATR: 0.05

MAMA Slope Filter

This filter checks the slope of MAMA.

A bullish entry requires MAMA to be rising.

A bearish entry requires MAMA to be falling.

This can help reduce entry markers during flat or unclear market conditions.

6. Entry Markers

The script can display filtered entry markers.

Bull Entry

A Bull Entry marker appears when MAMA crosses above FAMA and the entry filters pass.

Bear Entry

A Bear Entry marker appears when MAMA crosses below FAMA and the entry filters pass.

Important note

These markers are adaptive trend-state events. They are not guaranteed buy or sell signals.

7. Exit Markers

The script includes separate exit markers.

Exit Long

An Exit Long marker appears when the indicator is in a visual long state and MAMA crosses below FAMA.

This exit is not blocked by the entry filters.

Exit Short

An Exit Short marker appears when the indicator is in a visual short state and MAMA crosses above FAMA.

This exit is not blocked by the entry filters.

Why exit logic is separate

Entry filters can be useful for reducing weak entries, but exits often need to react faster.

For this reason, the script uses filtered logic for entries and raw opposite MAMA/FAMA crosses for exits.

8. Signal Marker Placement

Entry and exit markers are placed using ATR-based distance from candles.

This helps reduce marker overlap with price bars.

Users can adjust:

Signal distance from candles (ATR)

Increasing this value moves markers farther away from candles.

Decreasing this value places markers closer to candles.

9. Display Options

The script includes display settings for:

* Entry markers
* Exit markers
* MAMA/FAMA fill
* Optional background regime

The background regime is OFF by default to keep the chart clean.

10. Alerts

The script includes alert conditions for:

* Bull Entry
* Bear Entry
* Exit Long
* Exit Short

Alerts are notifications only. They do not place trades and do not confirm broker execution.

11. How to Use

A practical workflow:

1. Use the MAMA/FAMA lines to identify the adaptive trend state.

2. Look for green fill when MAMA is above FAMA.

3. Look for red fill when MAMA is below FAMA.

4. Use Bull Entry and Bear Entry markers as filtered adaptive cross events.

5. Use Exit Long and Exit Short markers as visual exit references.

6. Adjust the gap filter if too many or too few entry markers appear.

7. Adjust marker distance if entry or exit markers are too close to candles.

8. Combine the indicator with market structure, volume, support/resistance, and risk management.

9. Suggested Use Cases

MAMA/FAMA Adaptive Trend can be used for:

* Adaptive trend-state analysis
* Moving average trend filtering
* Trend transition study
* Visual trend-following context
* Exit reference based on opposite adaptive crosses
* Cleaner MAMA/FAMA cross visualization

13. Important Limitations

This indicator does not predict future price movement.

It does not guarantee profitable trades.

It is not a trading strategy.

It does not place orders.

It does not produce Strategy Tester results.

MAMA/FAMA crosses can whipsaw in sideways markets.

Adaptive moving averages can still lag during sharp reversals.

Entry and exit markers are visual events only.

A Bull Entry marker is not a guaranteed buy signal.

A Bear Entry marker is not a guaranteed sell signal.

Exit markers are not broker fills.

Users are responsible for their own trading decisions, risk management, and position sizing.

14. Originality and Purpose

MAMA/FAMA Adaptive Trend combines the MESA Adaptive Moving Average concept with cleaner TradingView visualization and practical signal filtering.

The script adds:

* Filtered entry markers
* Separate exit markers
* ATR-based marker spacing
* Optional fill between MAMA and FAMA
* Optional background regime
* Alerts for entry and exit events
* Cleaner chart output without a dashboard/table

The purpose of the indicator is to help traders study adaptive trend behavior in a simple and visually clear way.

15. Educational Disclaimer

This script is for educational and chart-analysis purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Users should perform their own analysis and manage risk independently.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// MAMA/FAMA Adaptive Trend
// ============================================================================
// This indicator is based on John Ehlers' MESA Adaptive Moving Average concept.
// It uses Hilbert-transform style cycle measurement to estimate the market's
// dominant cycle and then adapts the smoothing factor of MAMA from the rate of
// phase change.
//
// MAMA = adaptive fast line.
// FAMA = following adaptive line using half of MAMA's alpha.
//
// The indicator is designed as an adaptive trend-state tool:
// - MAMA above FAMA suggests a bullish adaptive state.
// - MAMA below FAMA suggests a bearish adaptive state.
// - Filtered entries can mark adaptive regime changes.
// - Raw opposite crosses can mark exits from the current visual state.
//
// Improvements:
// - Pine Script version 6.
// - Gap ATR length default changed to 12.
// - Table / badge removed for a cleaner chart.
// - Weak filtered cross markers removed.
// - Optional minimum MAMA/FAMA gap filter for entries.
// - Optional MAMA slope filter for entries.
// - Separate Exit Long / Exit Short logic.
// - Exit markers are not blocked by entry filters.
// - Signal markers use ATR + minimum percentage distance.
// - Signal markers anchor away from candles using recent high/low.
// - Publishing-safe wording: this is an indicator, not a strategy.
// ============================================================================

indicator("MAMA/FAMA Adaptive Trend", "MAMA/FAMA", overlay = true, max_labels_count = 100)

// ============================================================================
// Inputs
// ============================================================================

grpMama = "1) MAMA / FAMA"

src = input.source(hl2, "Source", group = grpMama)

fastLimit = input.float(
     0.50,
     "Fast limit (max alpha)",
     minval = 0.01,
     maxval = 1.0,
     step = 0.01,
     group = grpMama,
     tooltip = "Upper bound on adaptiveness. Higher values make MAMA more responsive near turns.")

slowLimit = input.float(
     0.05,
     "Slow limit (min alpha)",
     minval = 0.01,
     maxval = 1.0,
     step = 0.01,
     group = grpMama,
     tooltip = "Lower bound on adaptiveness. Higher values reduce smoothing in quieter markets.")

grpFilter = "2) Entry Filters"

useGapFilter = input.bool(
     true,
     "Use minimum MAMA/FAMA gap filter",
     group = grpFilter,
     tooltip = "When ON, entry signals are allowed only when the distance between MAMA and FAMA is large enough relative to ATR. This helps reduce weak entries in sideways markets.")

gapAtrLen = input.int(
     12,
     "Gap ATR length",
     minval = 1,
     group = grpFilter)

minGapAtr = input.float(
     0.05,
     "Minimum gap in ATR",
     minval = 0.0,
     maxval = 5.0,
     step = 0.01,
     group = grpFilter,
     tooltip = "Minimum MAMA/FAMA distance measured as ATR multiple. Example: 0.05 means the gap must be at least 5% of ATR.")

useSlopeFilter = input.bool(
     true,
     "Use MAMA slope filter",
     group = grpFilter,
     tooltip = "When ON, bullish entries require MAMA to be rising and bearish entries require MAMA to be falling.")

slopeLen = input.int(
     3,
     "Slope lookback bars",
     minval = 1,
     maxval = 50,
     group = grpFilter)

grpDisplay = "3) Display"

showEntries = input.bool(
     true,
     "Show entry markers",
     group = grpDisplay)

showExits = input.bool(
     true,
     "Show exit markers",
     group = grpDisplay)

signalAtrOffset = input.float(
     2.50,
     "Signal distance from candles (ATR)",
     minval = 0.10,
     maxval = 12.00,
     step = 0.10,
     group = grpDisplay,
     tooltip = "ATR multiplier used to place entry and exit markers away from candles. Increase this if markers are still too close.")

minSignalPct = input.float(
     2.50,
     "Minimum signal distance (%)",
     minval = 0.00,
     maxval = 20.00,
     step = 0.25,
     group = grpDisplay,
     tooltip = "Minimum percentage distance from price used when ATR distance is too small. This helps avoid markers sticking to candles in low-volatility areas.")

markerAnchorLen = input.int(
     3,
     "Marker anchor lookback",
     minval = 1,
     maxval = 20,
     group = grpDisplay,
     tooltip = "Markers are placed beyond the recent highest high or lowest low over this lookback, instead of only using the signal candle.")

showFill = input.bool(
     true,
     "Fill MAMA/FAMA",
     group = grpDisplay)

showBg = input.bool(
     false,
     "Show background regime",
     group = grpDisplay)

// ============================================================================
// Palette
// ============================================================================

cUp = color.rgb(54, 168, 112)
cDn = color.rgb(205, 85, 95)
cExit = color.rgb(235, 142, 52)

// ============================================================================
// Ehlers-style MAMA / FAMA calculation
// ============================================================================

float Smooth = 0.0
float Detrender = 0.0
float I1 = 0.0
float Q1 = 0.0
float jI = 0.0
float jQ = 0.0
float I2 = 0.0
float Q2 = 0.0
float Re = 0.0
float Im = 0.0
float Period = 0.0
float SmoothPeriod = 0.0
float Phase = 0.0
float MAMA = na
float FAMA = na

pf = 0.075 * nz(Period[1]) + 0.54

Smooth := (4.0 * src + 3.0 * src[1] + 2.0 * src[2] + src[3]) / 10.0

Detrender := (0.0962 * Smooth + 0.5769 * nz(Smooth[2]) - 0.5769 * nz(Smooth[4]) - 0.0962 * nz(Smooth[6])) * pf

Q1 := (0.0962 * Detrender + 0.5769 * nz(Detrender[2]) - 0.5769 * nz(Detrender[4]) - 0.0962 * nz(Detrender[6])) * pf

I1 := nz(Detrender[3])

jI := (0.0962 * I1 + 0.5769 * nz(I1[2]) - 0.5769 * nz(I1[4]) - 0.0962 * nz(I1[6])) * pf

jQ := (0.0962 * Q1 + 0.5769 * nz(Q1[2]) - 0.5769 * nz(Q1[4]) - 0.0962 * nz(Q1[6])) * pf

I2 := I1 - jQ
Q2 := Q1 + jI

I2 := 0.2 * I2 + 0.8 * nz(I2[1])
Q2 := 0.2 * Q2 + 0.8 * nz(Q2[1])

Re := I2 * nz(I2[1]) + Q2 * nz(Q2[1])
Im := I2 * nz(Q2[1]) - Q2 * nz(I2[1])

Re := 0.2 * Re + 0.8 * nz(Re[1])
Im := 0.2 * Im + 0.8 * nz(Im[1])

if Im != 0.0 and Re != 0.0
    Period := 2.0 * math.pi / math.atan(Im / Re)

if Period > 1.5 * nz(Period[1])
    Period := 1.5 * nz(Period[1])

if Period < 0.67 * nz(Period[1])
    Period := 0.67 * nz(Period[1])

if Period < 6.0
    Period := 6.0

if Period > 50.0
    Period := 50.0

Period := 0.2 * Period + 0.8 * nz(Period[1])
SmoothPeriod := 0.33 * Period + 0.67 * nz(SmoothPeriod[1])

if I1 != 0.0
    Phase := math.atan(Q1 / I1) * 180.0 / math.pi

DeltaPhase = nz(Phase[1]) - Phase

if DeltaPhase < 1.0
    DeltaPhase := 1.0

alpha = fastLimit / DeltaPhase

if alpha < slowLimit
    alpha := slowLimit

MAMA := na(MAMA[1]) ? src : alpha * src + (1.0 - alpha) * nz(MAMA[1])

FAMA := na(FAMA[1]) ? MAMA : 0.5 * alpha * MAMA + (1.0 - 0.5 * alpha) * nz(FAMA[1])

// ============================================================================
// Entry filters
// ============================================================================

atrVal = ta.atr(gapAtrLen)

gapAbs = math.abs(MAMA - FAMA)
gapAtr = atrVal > 0 ? gapAbs / atrVal : 0.0

gapOK = not useGapFilter or gapAtr >= minGapAtr

mamaSlopeBull = MAMA > MAMA[slopeLen]
mamaSlopeBear = MAMA < MAMA[slopeLen]

slopeBullOK = not useSlopeFilter or mamaSlopeBull
slopeBearOK = not useSlopeFilter or mamaSlopeBear

isUp = MAMA > FAMA

rawBullCross = ta.crossover(MAMA, FAMA)
rawBearCross = ta.crossunder(MAMA, FAMA)

filteredBullCross = rawBullCross and gapOK and slopeBullOK
filteredBearCross = rawBearCross and gapOK and slopeBearOK

// ============================================================================
// Visual state tracking
// ============================================================================

var int state = 0
// state =  1 -> visual long state
// state = -1 -> visual short state
// state =  0 -> flat / no active visual state

bullEntry = filteredBullCross and state == 0
bearEntry = filteredBearCross and state == 0

exitLong = rawBearCross and state == 1
exitShort = rawBullCross and state == -1

if bullEntry
    state := 1
else if bearEntry
    state := -1
else if exitLong or exitShort
    state := 0

// ============================================================================
// Signal marker placement
// ============================================================================

atrPad = atrVal * signalAtrOffset
pctPad = close * minSignalPct / 100.0
sigPad = math.max(atrPad, pctPad)

lowAnchor = ta.lowest(low, markerAnchorLen)
highAnchor = ta.highest(high, markerAnchorLen)

bullEntryY = showEntries and bullEntry ? lowAnchor - sigPad : na
bearEntryY = showEntries and bearEntry ? highAnchor + sigPad : na

exitLongY = showExits and exitLong ? highAnchor + sigPad : na
exitShortY = showExits and exitShort ? lowAnchor - sigPad : na

// ============================================================================
// Plots
// ============================================================================

mamaCol = isUp ? cUp : cDn

pM = plot(
     MAMA,
     "MAMA",
     color = mamaCol,
     linewidth = 2)

pF = plot(
     FAMA,
     "FAMA",
     color = color.new(isUp ? cUp : cDn, 35),
     linewidth = 1)

fill(
     pM,
     pF,
     color = showFill ? color.new(isUp ? cUp : cDn, 88) : na,
     title = "MAMA/FAMA Fill")

bgcolor(
     showBg ? color.new(isUp ? cUp : cDn, 94) : na,
     title = "Background Regime")

plotshape(
     bullEntryY,
     title = "Bull Entry",
     style = shape.triangleup,
     location = location.absolute,
     color = cUp,
     size = size.small)

plotshape(
     bearEntryY,
     title = "Bear Entry",
     style = shape.triangledown,
     location = location.absolute,
     color = cDn,
     size = size.small)

plotshape(
     exitLongY,
     title = "Exit Long",
     style = shape.xcross,
     location = location.absolute,
     color = cExit,
     size = size.small)

plotshape(
     exitShortY,
     title = "Exit Short",
     style = shape.xcross,
     location = location.absolute,
     color = cExit,
     size = size.small)

// ============================================================================
// Alerts
// ============================================================================

alertcondition(
     bullEntry,
     title = "Bull Entry",
     message = "MAMA/FAMA Adaptive Trend: filtered bullish entry")

alertcondition(
     bearEntry,
     title = "Bear Entry",
     message = "MAMA/FAMA Adaptive Trend: filtered bearish entry")

alertcondition(
     exitLong,
     title = "Exit Long",
     message = "MAMA/FAMA Adaptive Trend: exit long on MAMA/FAMA bearish cross")

alertcondition(
     exitShort,
     title = "Exit Short",
     message = "MAMA/FAMA Adaptive Trend: exit short on MAMA/FAMA bullish cross")

// ============================================================================
// End of file
// ============================================================================
````
