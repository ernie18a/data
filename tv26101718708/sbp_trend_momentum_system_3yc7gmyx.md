# SBP Trend & Momentum System

- url: https://www.tradingview.com/script/3YC7gMYX-SBP-Trend-Momentum-System/
- type: indicator
- pine_id: PUB;86c07c6a9711407d90244e0dbca4b597
- version: 3.0

## Description

SBP Trend & Momentum System is an educational trend and momentum analysis tool designed to study directional market phases while reducing repeated and conflicting setup markers.

The script combines structured trend analysis, Hull-style adaptive smoothing, EMA directional consensus, ATR-normalized trend strength, momentum analysis, recent price-structure events, candle characteristics, volatility conditions, and optional relative-volume information.

### Why these components are combined

A single trend or momentum calculation may react differently during compression, directional expansion, and temporary counter-moves. This script combines several analytical components so that each performs a separate role within the setup process.

The trend filter and adaptive average evaluate directional slope. EMA alignment measures directional consensus and trend separation. ATR normalization adjusts momentum, structure penetration, and signal distance relative to current market movement. Candle and optional volume calculations provide additional setup context.

These components are combined through a normalized quality and factor-consensus framework rather than requiring every analytical event to occur on the same candle.

### Trend Phase Lock

The Trend Phase Lock maintains an established bullish or bearish directional phase.

Temporary neutral conditions do not automatically reset the active phase. A new opposite phase requires persistent opposite directional conditions before the phase state changes.

The primary setup engine permits one BUY or SELL marker per established directional phase. This is intended to reduce repeated same-direction labels during an ongoing move.

### Dominant Trend Guard

The Dominant Trend Guard distinguishes stronger directional conditions from ordinary short-term movement.

During a major bullish phase, the script evaluates whether bullish trend slope, adaptive direction, EMA alignment, and ATR-normalized trend strength remain aligned. The same process is applied inversely during a major bearish phase.

A temporary counter-move alone does not immediately change the active directional phase. Opposite phase processing uses reversal persistence, adaptive and EMA agreement, and ATR-normalized displacement before the phase can change.

This mechanism is a directional-state filter. It does not predict future price direction.

### Big Trend Continuation Rescue

Strong directional expansion can sometimes move beyond the normal signal-distance range or continue after the standard phase signal window.

The Big Trend Continuation Rescue evaluates dominant trend state, directional momentum, factor alignment, normalized quality, volatility, and candle-range conditions.

Its purpose is to allow the setup engine to continue evaluating a strong directional phase without requiring the ordinary setup conditions to occur within a narrow group of bars.

The one-primary-marker-per-phase rule remains applicable.

### Quality and Factor Consensus

The script calculates a normalized quality score from:

• Trend strength
• Directional alignment strength
• ATR-normalized momentum quality
• Candle characteristics
• Recent structure quality
• Optional relative-volume information

Momentum, structure, and candle conditions contribute to setup quality and factor consensus. They are not all required to occur on the same candle.

The available scoring denominator automatically adjusts when optional analytical components are disabled.

### Structure Memory

The structure engine evaluates closes relative to previous price structure and measures penetration in ATR terms.

A controlled fresh structure event receives greater analytical weight. A recent structure event can remain relevant for a limited number of bars.

This allows the setup engine to evaluate continuation conditions after a structure event rather than requiring the signal candle itself to be the structure-break candle.

### Trading Modes

The indicator includes three analytical modes:

**SCALPING** — shorter calculation lengths for faster chart conditions.

**INTRADAY** — balanced calculation lengths for intraday market analysis.

**SWING** — longer calculation lengths for broader directional analysis.

These modes adjust internal trend, adaptive smoothing, momentum, structure, and candle-range parameters.

### Signal Quality and Frequency

Users can select **Aggressive, Balanced, or Conservative** signal-quality settings.

The **Selective, Balanced, and Frequent** frequency settings adjust phase confirmation and setup evaluation parameters.

These controls change the script's rule-based analytical sensitivity. They do not represent expected performance levels.

### BUY and SELL Labels

BUY and SELL labels identify rule-based analytical setups generated when the script's directional phase, trend state, factor consensus, quality, volatility, and other enabled conditions meet the defined criteria.

The labels are analytical markers only. They are not automated orders, trade execution instructions, financial advice, or guarantees of future market movement.

### Early Transition Markers

Optional early transition markers evaluate directional crosses together with trend slope, adaptive direction, EMA alignment, momentum, and candle characteristics.

These markers are separate from the primary BUY and SELL setup engine. They do not reset the Trend Phase Lock or unlock another primary setup marker.

### ATR Risk Guide

The optional ATR Risk Guide plots a volatility-based visual reference around the adaptive average.

It is provided for chart analysis only and is not a broker order, strategy exit, or guaranteed stop-loss level.

### Bar-Close Processing

When **Signals On Bar Close** is enabled, phase processing, primary setup markers, early transition markers, and related alerts are evaluated after the chart bar closes.

The script does not use `request.security()` or future-data lookup.

### Important Information

This indicator is provided for educational and informational purposes only.

It is an analytical decision-support tool and does not execute trades or provide automated investment advice. BUY and SELL labels identify conditions defined by the script's calculations and should not be interpreted as guarantees of profitable outcomes or future price direction.

Users should independently evaluate market conditions and apply their own execution, position-sizing, and risk-management methods.

Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Trend and Momentum System", overlay = true, max_labels_count = 100)

// Only display controls belong in Settings. Alerts and calculations remain active.
string signalGroup = "01. Signals"
bool showSignals = input.bool(true, "Show Buy / Sale", group = signalGroup)
string zoneGroup = "02. Premium and Discount Zones"
bool showPriceZones = input.bool(false, "Show Premium / Discount Zones", group = zoneGroup)
string visualGroup = "03. Trend Reference"
bool showEfficiencyLine = input.bool(true, "Show Adaptive Trend Line", group = visualGroup)

// Fixed internal calibration keeps the setup simple and matches the previous defaults.
const int efficiencyLength = 16
const int fastResponseLength = 3
const int slowResponseLength = 34
const float efficiencyThreshold = 0.28
const int atrLength = 14
const float baseChannelATR = 0.70
const float noiseExpansionATR = 0.80
const int channelSmoothing = 3
const float pressureThreshold = 0.18
const int normalConfirmationBars = 2
const float stateReleaseFactor = 0.45
const float shockBodyATR = 0.90
const float shockRangeATR = 1.30
const float shockCloseLocation = 0.72
const int zoneLookback = 80
const int zoneSmoothing = 5

// Price-path efficiency drives both the adaptive center and noise-sensitive width.
float atr = ta.atr(atrLength)
float atrSafe = math.max(nz(atr, syminfo.mintick), syminfo.mintick)
float pathTravel = math.sum(math.abs(ta.change(close)), efficiencyLength)
float netTravel = math.abs(close - close[efficiencyLength])
float pathEfficiency = pathTravel > 0 and not na(netTravel) ? math.min(netTravel / pathTravel, 1.0) : 0.0
float fastConstant = 2.0 / (fastResponseLength + 1.0)
float slowConstant = 2.0 / (slowResponseLength + 1.0)
float adaptiveConstant = math.pow(pathEfficiency * (fastConstant - slowConstant) + slowConstant, 2.0)
var float efficiencyLine = na
efficiencyLine := na(efficiencyLine[1]) ? close : efficiencyLine[1] + adaptiveConstant * (close - efficiencyLine[1])
float lineVelocityATR = (efficiencyLine - nz(efficiencyLine[1], efficiencyLine)) / atrSafe
float channelWidth = atrSafe * (baseChannelATR + (1.0 - pathEfficiency) * noiseExpansionATR)
float upperChannel = ta.ema(efficiencyLine + channelWidth, channelSmoothing)
float lowerChannel = ta.ema(efficiencyLine - channelWidth, channelSmoothing)
float halfChannel = math.max((upperChannel - lowerChannel) * 0.5, syminfo.mintick)
float channelPressure = math.max(-1.0, math.min((close - efficiencyLine) / halfChannel, 1.0))
float candleRange = math.max(high - low, syminfo.mintick)
float candleBody = math.abs(close - open)
float closeLocation = (close - low) / candleRange

// The upper and lower quarters of a smoothed trailing range form the displayed zones.
// Values commit on candle close; they can move as the trailing range rolls forward.
float zoneHigh = ta.highest(high, zoneLookback)
float zoneLow = ta.lowest(low, zoneLookback)
float upperZoneSmooth = ta.ema(zoneHigh, zoneSmoothing)
float lowerZoneSmooth = ta.ema(zoneLow, zoneSmoothing)
float premiumSmooth = lowerZoneSmooth + (upperZoneSmooth - lowerZoneSmooth) * 0.75
float discountSmooth = lowerZoneSmooth + (upperZoneSmooth - lowerZoneSmooth) * 0.25
var float premiumOuter = na
var float discountOuter = na
var float premiumLine = na
var float discountLine = na
if barstate.isconfirmed
    premiumOuter := upperZoneSmooth
    discountOuter := lowerZoneSmooth
    premiumLine := premiumSmooth
    discountLine := discountSmooth

// A normal turn needs efficient travel, pressure, a moving center and a matching candle.
bool bullNormal = barstate.isconfirmed and pathEfficiency >= efficiencyThreshold and close > close[efficiencyLength] and channelPressure >= pressureThreshold and lineVelocityATR > 0 and close > open and close > efficiencyLine
bool bearNormal = barstate.isconfirmed and pathEfficiency >= efficiencyThreshold and close < close[efficiencyLength] and channelPressure <= -pressureThreshold and lineVelocityATR < 0 and close < open and close < efficiencyLine
bool bullShock = barstate.isconfirmed and close > open and candleBody / atrSafe >= shockBodyATR and candleRange / atrSafe >= shockRangeATR and closeLocation >= shockCloseLocation and close > upperChannel and lineVelocityATR >= 0
bool bearShock = barstate.isconfirmed and close < open and candleBody / atrSafe >= shockBodyATR and candleRange / atrSafe >= shockRangeATR and closeLocation <= 1.0 - shockCloseLocation and close < lowerChannel and lineVelocityATR <= 0

// Confirmation counts only consecutive qualifying candles; shock turns confirm immediately.
var int behaviourState = 0
var int pendingDirection = 0
var int pendingBars = 0
bool buySignal = false
bool saleSignal = false
bool majorBuySignal = false
bool majorSaleSignal = false
if barstate.isconfirmed
    bool bullishRelease = behaviourState != -1 or channelPressure[1] > -pressureThreshold * stateReleaseFactor
    bool bearishRelease = behaviourState != 1 or channelPressure[1] < pressureThreshold * stateReleaseFactor
    int candidate = bullShock and not bearShock and behaviourState != 1 ? 1 : bearShock and not bullShock and behaviourState != -1 ? -1 : bullNormal and not bearNormal and bullishRelease ? 1 : bearNormal and not bullNormal and bearishRelease ? -1 : 0
    if candidate == 0 or candidate == behaviourState
        pendingDirection := 0
        pendingBars := 0
    else if candidate == 1 and bullShock or candidate == -1 and bearShock
        behaviourState := candidate
        buySignal := candidate == 1
        saleSignal := candidate == -1
        majorBuySignal := buySignal
        majorSaleSignal := saleSignal
        pendingDirection := 0
        pendingBars := 0
    else
        pendingBars := candidate == pendingDirection ? pendingBars + 1 : 1
        pendingDirection := candidate
        if pendingBars >= normalConfirmationBars
            behaviourState := candidate
            buySignal := candidate == 1
            saleSignal := candidate == -1
            pendingDirection := 0
            pendingBars := 0

// The behavior channel remains an internal signal measurement; only price zones are drawn.
float visualStrength = math.max(0.0, math.min(pathEfficiency * 0.65 + math.abs(channelPressure) * 0.35, 1.0))
color bullColour = color.from_gradient(visualStrength, 0.0, 1.0, color.aqua, color.green)
color bearColour = color.from_gradient(visualStrength, 0.0, 1.0, color.orange, color.red)
color stateColour = behaviourState == 1 ? bullColour : behaviourState == -1 ? bearColour : color.new(color.gray, 20)
premiumOuterPlot = plot(showPriceZones ? premiumOuter : na, "Premium Zone Outer", color = color.new(color.red, 62), linewidth = 1, style = plot.style_linebr, editable = false)
premiumInnerPlot = plot(showPriceZones ? premiumLine : na, "Premium Zone Inner", color = color.new(color.red, 10), linewidth = 2, style = plot.style_linebr, editable = false)
discountInnerPlot = plot(showPriceZones ? discountLine : na, "Discount Zone Inner", color = color.new(color.lime, 10), linewidth = 2, style = plot.style_linebr, editable = false)
discountOuterPlot = plot(showPriceZones ? discountOuter : na, "Discount Zone Outer", color = color.new(color.lime, 62), linewidth = 1, style = plot.style_linebr, editable = false)
fill(premiumOuterPlot, premiumInnerPlot, color = showPriceZones ? color.new(color.red, 87) : na, title = "Possible Premium Zone", editable = false)
fill(premiumInnerPlot, discountInnerPlot, color = showPriceZones ? color.new(color.blue, 91) : na, title = "Premium Discount Channel Interior", editable = false)
fill(discountInnerPlot, discountOuterPlot, color = showPriceZones ? color.new(color.lime, 87) : na, title = "Possible Discount Zone", editable = false)
plot(showEfficiencyLine ? efficiencyLine : na, "Adaptive Trend Line", color = stateColour, linewidth = 2, editable = false)
plotshape(showSignals and buySignal, "BUY", shape.labelup, location.belowbar, color.green, text = "BUY", textcolor = color.white, size = size.small, editable = false)
plotshape(showSignals and saleSignal, "SALE", shape.labeldown, location.abovebar, color.red, text = "SALE", textcolor = color.white, size = size.small, editable = false)
alertcondition(buySignal, "Trend and Momentum System BUY", "Trend and Momentum System: BUY")
alertcondition(saleSignal, "Trend and Momentum System SALE", "Trend and Momentum System: SALE")
alertcondition(majorBuySignal, "Trend and Momentum System Shock BUY", "Trend and Momentum System: SHOCK BUY")
alertcondition(majorSaleSignal, "Trend and Momentum System Shock SALE", "Trend and Momentum System: SHOCK SALE")
plot(pathEfficiency, "Path Efficiency", color = color.new(color.white, 100), display = display.data_window, editable = false)
plot(channelPressure, "Channel Pressure", color = color.new(color.white, 100), display = display.data_window, editable = false)
plot(behaviourState, "Behaviour State", color = color.new(color.white, 100), display = display.data_window, editable = false)
````
