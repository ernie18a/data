# Auto AVWAP - Core and Adaptive Levels

- url: https://www.tradingview.com/script/l4aykqmu/
- type: indicator
- pine_id: PUB;06345529be604bfe959fa1b0971d8f10
- version: 1.0

## Description

Auto AVWAP Core and Adaptive Levels

This indicator plots automatically anchored Volume Weighted Average Price levels designed to represent dynamic support and resistance.

It expands the traditional Auto AVWAP concept into a multi-level structure composed of:

- Core AVWAPs: the primary active support and resistance references.
- Adaptive AVWAPs: additional levels anchored at subsequently confirmed market swings.
- Developing candidates: optional previews of potential Adaptive anchors.

The objective is to preserve relevant volume-weighted references while allowing new AVWAPs to emerge during persistent directional moves. This can be particularly useful when an older AVWAP remains structurally relevant but becomes too distant from current price to represent nearby support or resistance.

Core calculation

Each AVWAP is calculated as:

AVWAP = Sum(Price × Volume) / Sum(Volume)

The indicator can use:

- High for resistance AVWAP calculations.
- Low for support AVWAP calculations.

When “Use High/Low instead of HLC3” is disabled, both directions use:

HLC3 = (High + Low + Close) / 3

Using High and Low generally creates greater separation between support and resistance AVWAPs. HLC3 produces a more conventional volume-weighted average.

Core AVWAPs

The indicator maintains one active Core AVWAP in each direction:

- Core Resistance AVWAP.
- Core Support AVWAP.

The Core Resistance AVWAP is violated when the selected violation source remains above it for the configured number of consecutive bars.

The Core Support AVWAP is violated when the selected violation source remains below it for the configured number of consecutive bars.

When a Core AVWAP reaches its violation threshold:

1) The active Core AVWAP stops immediately.
2) Its completed historical segment remains visible.
3) Its accumulators stop receiving new price and volume data.
4) The indicator waits for a confirmed replacement anchor.
5) The confirmed candidate becomes the new Core AVWAP.

This separates invalidation from replacement. A violated Core AVWAP is not kept active merely because its replacement has not yet been confirmed.

Adaptive AVWAPs

Adaptive AVWAPs provide additional support and resistance references during extended trends.

A new Adaptive AVWAP can be considered when:

- price has moved a configurable ATR distance from the newest valid AVWAP;
- the minimum number of bars between anchors has elapsed;
- a qualifying Stochastic RSI episode occurs;
- price reacts sufficiently from the candidate extreme;
- the selected top or bottom confirmation is completed;
- the anchor satisfies the configured spacing and progression rules;
- and an Adaptive AVWAP slot is available.

Each Adaptive AVWAP:

- begins at its own confirmed top or bottom;
- maintains independent price-volume accumulators;
- remains independent from the Core and other Adaptive AVWAPs;
- has its own consecutive-violation counter;
- remains active while respected;
- and stops only when its individual violation rule is satisfied.

The indicator supports up to 10 Adaptive AVWAPs per direction.

Adaptive creation distance

“Distance required from newest AVWAP (ATR)” determines how far price must move from the newest valid AVWAP before the indicator begins searching for an additional Adaptive anchor.

A lower value:

- creates Adaptive AVWAPs more frequently;
- keeps references closer to price;
- and may produce more overlapping levels.

A higher value:

- produces fewer Adaptive AVWAPs;
- requires greater separation from existing levels;
- and emphasizes larger market movements.

Anchor spacing and timing

“Minimum spacing between anchors (ATR)” prevents new Adaptive anchors from being created too close to the newest valid anchor.

“Minimum bars between anchors” imposes an additional time-based separation.

These controls work together with the creation-distance requirement to reduce redundant AVWAPs.

Progressive anchors

When “Require progressively higher lows / lower highs” is enabled:

- Adaptive support anchors must form at progressively higher lows.
- Adaptive resistance anchors must form at progressively lower highs.

This setting emphasizes directional progression.

When disabled, the indicator can accept sufficiently separated anchors that are not strictly progressive. This may be useful when a trend experiences a deeper correction before resuming.

Top and bottom confirmation

The indicator provides three confirmation modes.

Reaction only

The candidate requires:

- the relevant Stochastic RSI reversal;
- and a minimum price reaction measured in ATR.

This is the fastest and most sensitive mode.

Pivot confirmed

In addition to the required reaction, the candidate extreme must remain unbroken for the configured number of bars.

This reduces anchors generated from brief or unstable extremes.

Pivot + Structure break

This is the default and most selective mode.

A resistance anchor requires:

- an overbought Stochastic RSI episode;
- a candidate high;
- a bearish K/D reversal;
- the configured downward reaction in ATR;
- the high to remain unbroken for the required number of bars;
- and a close below the microstructure low captured around the extreme.

A support anchor requires the inverse sequence:

- an oversold Stochastic RSI episode;
- a candidate low;
- a bullish K/D reversal;
- the configured upward reaction in ATR;
- the low to remain unbroken for the required number of bars;
- and a close above the corresponding microstructure high.

All confirmation events must belong to the same candidate episode.

Candidate expiration

Unconfirmed candidates expire after the configured timeout.

When a candidate expires:

- its accumulated state is cleared;
- it cannot be confirmed much later;
- and it does not produce a historical AVWAP.

This prevents stale oscillator events from generating delayed or unrelated anchors.

Core and Adaptive invalidation

Every active Core and Adaptive AVWAP maintains an independent consecutive-violation counter.

The violation source can be selected from:

- Close: uses the candle close.
- Open: uses the candle open.
- High/Low: uses High for resistance violations and Low for support violations.

A resistance AVWAP is violated when the selected source remains above it.

A support AVWAP is violated when the selected source remains below it.

For example, with six consecutive bars selected:

- a resistance AVWAP stops after six consecutive violations above it;
- a support AVWAP stops after six consecutive violations below it.

If a bar does not violate a level, that AVWAP’s counter returns to zero.

The “Count only closed bars” option prevents an unfinished real-time candle from temporarily advancing the violation counter.

Historical origin display

Candidates remain hidden while unconfirmed.

When a Core or Adaptive candidate is confirmed, the indicator reconstructs and displays the AVWAP from its true anchor rather than displaying it only from the confirmation candle.

This preserves the complete origin and development of confirmed AVWAPs without displaying candidates that were rejected or expired.

The reconstructed origin uses the same direction, generation color, transparency, width, and approximate dotted style as the active AVWAP.

AVWAP interaction alerts

The indicator monitors every active Core and Adaptive AVWAP independently for three types of price interaction:

- Touch.
- Directional rejection.
- Failed violation.

These events are separated by direction into support and resistance alerts.

Touch

A touch occurs when the candle enters a configurable ATR-based zone around an active AVWAP.

The interaction zone is defined as:

AVWAP ± Touch Tolerance × ATR

A touch does not require the candle to close on a particular side of the AVWAP.

To reduce repeated notifications, a touch alert is triggered only when price enters the interaction zone. Additional candles remaining inside the same zone do not generate new touch alerts. The touch state resets after price leaves the zone.

Directional rejection

A rejection requires more than a simple touch.

The candle must:

- interact with the AVWAP;
- return to the valid side;
- close at least the configured ATR distance away from the AVWAP;
- and form in the expected directional candle color.

A resistance AVWAP rejection requires:

- the candle to touch or penetrate the resistance interaction zone;
- the candle to close back below the resistance AVWAP;
- the close to finish at least the configured rejection distance below the AVWAP;
- and a bearish candle, where Close is below Open.

A support AVWAP rejection requires:

- the candle to touch or penetrate the support interaction zone;
- the candle to close back above the support AVWAP;
- the close to finish at least the configured rejection distance above the AVWAP;
- and a bullish candle, where Close is above Open.

Doji candles, where Close equals Open, are not classified as rejection candles.

This directional-candle requirement is intended to distinguish an actual reaction from a candle that merely crosses or finishes near an AVWAP.

Failed violation

A failed violation occurs when price begins violating an AVWAP but returns to the valid side before reaching the number of consecutive bars required for full invalidation.

For a resistance AVWAP:

1) Price evaluates above the AVWAP according to the selected violation source.
2) A partial consecutive-violation count begins.
3) The count reaches the configured minimum partial-violation requirement.
4) Price returns to the valid side before reaching full invalidation.

For a support AVWAP, the inverse sequence applies below the level.

A failed violation does not require the reversal candle to be bullish or bearish. Its purpose is to identify an unsuccessful multi-bar violation sequence rather than a single-candle rejection pattern.

Interaction alert settings

Touch tolerance (ATR)

Defines the size of the interaction zone surrounding every active AVWAP.

A lower value requires price to approach the AVWAP more precisely.

A higher value detects interactions occurring within a wider volatility-adjusted area.

Minimum rejection close distance (ATR)

Defines how far the rejection candle must close back on the valid side of the AVWAP.

Increasing this setting requires a stronger reaction before a rejection alert is generated.

Minimum partial violation bars

Defines how many consecutive violation bars must occur before a return to the valid side can be classified as a failed violation.

For example:

- A value of 1 detects a failure after any single partial violation.
- A value of 2 requires at least two consecutive violation bars.
- The partial count must remain below the full invalidation threshold.

Confirm interactions only on closed bars

When enabled, touch, rejection, and failed-violation events are confirmed only after the candle closes.

This prevents temporary intrabar movements from producing interaction alerts that may disappear before the bar is complete.

Plots

The indicator can display:

- Core Resistance AVWAP.
- Core Support AVWAP.
- Up to 10 Adaptive Resistance AVWAPs.
- Up to 10 Adaptive Support AVWAPs.
- Optional developing Adaptive resistance candidate.
- Optional developing Adaptive support candidate.

Core AVWAPs use stronger red and green styling.

Adaptive resistance AVWAPs use orange, fuchsia, purple, and related shades.

Adaptive support AVWAPs use blue, aqua, teal, and related shades.

Developing candidates are hidden by default to reduce chart noise.

Alerts

The indicator includes alert conditions for:

- New Adaptive resistance AVWAP.
- New Adaptive support AVWAP.
- Resistance AVWAP invalidation.
- Support AVWAP invalidation.
- Resistance AVWAP touch.
- Support AVWAP touch.
- Resistance AVWAP rejection.
- Support AVWAP rejection.
- Failed resistance AVWAP violation.
- Failed support AVWAP violation.

Because TradingView alert conditions cannot dynamically create a separate selectable alert for every array slot, interaction alerts are aggregated by event type and direction.

For example, “Support AVWAP rejection” indicates that price rejected at least one active Core or Adaptive Support AVWAP. It does not identify the individual AVWAP slot in the static alert message.

How to use

- Treat support AVWAPs as potential dynamic support references.
- Treat resistance AVWAPs as potential dynamic resistance references.
- Use Core AVWAPs as the primary active market references.
- Use Adaptive AVWAPs to monitor newer levels formed during extended trends.
- Reduce the ATR creation distance to capture more intermediate anchors.
- Increase it to retain only more widely separated Adaptive levels.
- Use “Pivot + Structure break” when stronger confirmation is preferred.
- Use “Reaction only” when faster but less selective anchoring is desired.
- Increase the consecutive-violation requirement to make levels more persistent.
- Prefer confirmed closes when the objective is to reduce intrabar noise.
- Use touch alerts as early notifications that price is interacting with an active AVWAP.
- Use directional rejection alerts when a candle touches the level and confirms a reaction in the expected direction.
- Use failed-violation alerts to identify unsuccessful attempts to invalidate an AVWAP.
- A rejection and a failed violation represent different events: rejection is a directional candle pattern, while failed violation is the cancellation of a partial multi-bar violation sequence.
- Increase the rejection distance when stronger reactions are preferred.
- Increase the minimum partial-violation count to filter isolated failed breaks.
- Adjust settings according to the symbol, timeframe, session structure, liquidity, and volatility regime.

Example starting configuration

For an intraday chart, a possible starting configuration is:

- Maximum Adaptive AVWAPs per direction: 3 to 5
- ATR length: 14
- Distance required from newest AVWAP: 1.0 to 2.0 ATR
- Minimum bars between anchors: 12 to 24
- Minimum spacing between anchors: 0.5 to 1.0 ATR
- Required price reaction: 0.5 ATR
- Confirmation mode: Pivot + Structure break
- Bars without a new extreme: 3
- Microstructure lookback: 5
- Consecutive bars to invalidate: 3 to 6
- Violation source: Close
- Count only closed bars: Enabled
- Touch tolerance: 0.10 ATR
- Minimum rejection close distance: 0.15 ATR
- Minimum partial violation bars: 1
- Confirm interactions only on closed bars: Enabled

These values are starting points rather than universal settings.

Open-source reuse and credits

This script is based on the open-source indicator:

“Auto AVWAP (Anchored-VWAP)” by Electrified.

Original source:
https://www.tradingview.com/script/ZmNNKbwE-Auto-AVWAP-Anchored-VWAP/

This version substantially extends and changes the original lifecycle model by adding:

1) Pine Script v6 implementation.
2) Separate Core and Adaptive AVWAP architecture.
3) Up to 10 independent Adaptive AVWAPs per direction.
4) Independent price-volume accumulators for every active level.
5) Independent consecutive-violation counters.
6) Immediate invalidation separated from replacement confirmation.
7) ATR-based Adaptive AVWAP search.
8) Configurable distance and spacing between anchors.
9) Configurable minimum time between Adaptive anchors.
10) Optional progressively higher-low and lower-high requirements.
11) Isolated Stochastic RSI candidate episodes.
12) Reaction, pivot, and microstructure confirmation modes.
13) Candidate expiration to prevent stale confirmations.
14) Historical reconstruction from each confirmed anchor.
15) Consistent styling before and after confirmation.
16) Separate creation and invalidation alerts.
17) Independent lifecycle management for Core and Adaptive levels.
18) ATR-normalized interaction zones for all active Core and Adaptive AVWAPs.
19) Touch alerts with zone-entry latching to reduce repeated notifications.
20) Directional rejection alerts requiring bearish resistance-rejection candles and bullish support-rejection candles.
21) Failed-violation alerts based on incomplete consecutive-violation sequences.
22) Configurable closed-bar confirmation for AVWAP interaction events.

Limitations

- AVWAPs are analytical references, not guaranteed support or resistance.
- Stronger confirmation reduces false anchors but introduces additional delay.
- Lower ATR-distance settings may produce many overlapping Adaptive AVWAPs.
- Higher distance and spacing settings may omit useful intermediate swings.
- Stochastic RSI behavior depends on the selected symbol and timeframe.
- Volume quality varies across markets and data providers.
- HLC3 can make support and resistance AVWAPs appear closer together.
- Touch and rejection zones are ATR-based and may require adjustment across volatility regimes.
- Directional rejection alerts describe candle behavior around an AVWAP; they do not guarantee continued movement away from the level.
- Failed-violation alerts identify an incomplete invalidation sequence, but price may attempt another violation shortly afterward.
- Aggregated interaction alerts identify the event type and direction but do not specify the individual Core or Adaptive AVWAP slot.
- Historical reconstruction uses TradingView drawing objects and may not render identically to native plot points.
- TradingView imposes limits on historical drawing objects.
- Historical behavior does not guarantee future results.
- This is a decision-support tool, not a guaranteed-profit system.
- Risk management is required.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Original Auto AVWAP concept/code: © Electrified (electrifiedtrading)
// Core and Adaptive AVWAP lifecycle modification
//@version=6
indicator("Auto AVWAP - Core and Adaptive Levels", "Auto AVWAP CAL", overlay=true, format=format.price, precision=2, max_polylines_count=100)

WMA = "WMA", EMA = "EMA", SMA = "SMA", VWMA = "VWMA", VAWMA = "VAWMA"

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------

useHiLow = input.bool(true, "Use High/Low instead of HLC3", group="Anchored VWAP")

maxGenerations = input.int(3, "Maximum Adaptive AVWAPs per direction", minval=1, maxval=10, group="Adaptive AVWAP Creation")
atrLength = input.int(14, "ATR length", minval=1, group="Adaptive AVWAP Creation")
creationDistanceATR = input.float(2.0, "Distance required from newest AVWAP (ATR)", minval=0.1, step=0.1, group="Adaptive AVWAP Creation")
minimumBarsBetween = input.int(24, "Minimum bars between anchors", minval=1, group="Adaptive AVWAP Creation")
minimumAnchorSpacingATR = input.float(1.0, "Minimum spacing between anchors (ATR)", minval=0.0, step=0.1, group="Adaptive AVWAP Creation")
confirmationMoveATR = input.float(0.5, "Price reaction required (ATR)", minval=0.0, step=0.1, group="Adaptive AVWAP Creation")
candidateTimeout = input.int(100, "Candidate timeout (bars)", minval=5, group="Adaptive AVWAP Creation")
requireProgressive = input.bool(true, "Require progressively higher lows / lower highs", group="Adaptive AVWAP Creation", tooltip="Adaptive support AVWAPs require a higher anchor low. Adaptive resistance AVWAPs require a lower anchor high.")

confirmationMode = input.string("Pivot + Structure break", "Top/bottom confirmation", options=["Reaction only", "Pivot confirmed", "Pivot + Structure break"], group="Top/Bottom Confirmation")
pivotConfirmationBars = input.int(3, "Bars without a new extreme", minval=1, group="Top/Bottom Confirmation", tooltip="A top must remain unbroken for this many bars. A bottom follows the inverse rule.")
structureLookback = input.int(5, "Microstructure lookback", minval=2, group="Top/Bottom Confirmation", tooltip="A top is confirmed after closing below the local low captured at the extreme. A bottom requires a close above the captured local high.")

violationBars = input.int(3, "Consecutive bars to invalidate", minval=1, group="Core and Adaptive Invalidation")
violationSource = input.string("Close", "Violation source", options=["Close", "Open", "High/Low"], group="Core and Adaptive Invalidation")
confirmedOnly = input.bool(true, "Count only closed bars", group="Core and Adaptive Invalidation")

touchToleranceATR = input.float(0.10, "Touch tolerance (ATR)", minval=0.0, step=0.05, group="AVWAP Interaction Alerts", tooltip="Defines the interaction zone around each AVWAP.")
rejectionDistanceATR = input.float(0.15, "Minimum rejection close distance (ATR)", minval=0.0, step=0.05, group="AVWAP Interaction Alerts", tooltip="After touching or crossing an AVWAP, price must close this far back on the valid side to qualify as a rejection.")
minimumFailedBars = input.int(1, "Minimum partial violation bars", minval=1, group="AVWAP Interaction Alerts", tooltip="Minimum consecutive violation bars required before a return to the valid side is classified as a failed violation.")
interactionAlertsClosedOnly = input.bool(true, "Confirm interactions only on closed bars", group="AVWAP Interaction Alerts")

kMode = input.string(WMA, "K mode", options=[SMA, EMA, WMA, VWMA, VAWMA], group="Stochastic RSI", inline="K")
stochSource = input.source(hlc3, "Source", group="Stochastic RSI", inline="K")
smoothK = input.int(4, "K", minval=1, group="Stochastic RSI", inline="Smooth")
smoothD = input.int(4, "D", minval=1, group="Stochastic RSI", inline="Smooth")
lengthRSI = input.int(64, "RSI length", minval=1, group="Stochastic RSI", inline="Length")
lengthStoch = input.int(48, "Stochastic length", minval=1, group="Stochastic RSI", inline="Length")
lowerBand = input.float(20.0, "Lower band", minval=0.0, maxval=50.0, group="Stochastic RSI", inline="Band")
upperBand = input.float(80.0, "Upper band", minval=50.0, maxval=100.0, group="Stochastic RSI", inline="Band")

showCandidates = input.bool(false, "Show developing Adaptive candidates", group="Display")
showMothers = input.bool(true, "Show Core AVWAPs", group="Display")

//------------------------------------------------------------------------------
// Functions
//------------------------------------------------------------------------------

vawma(series float source, simple int length) =>
    float weightedSum = 0.0
    float weightedVolume = 0.0
    for m = 1 to length
        int offset = length - m
        float weightedVol = volume[offset] * m
        weightedVolume += weightedVol
        weightedSum += source[offset] * weightedVol
    weightedVolume > 0 ? weightedSum / weightedVolume : na

getMA(series float source, simple string mode, simple int length) =>
    switch mode
        WMA => ta.wma(source, length)
        EMA => ta.ema(source, length)
        VWMA => ta.vwma(source, length)
        VAWMA => vawma(source, length)
        => ta.sma(source, length)

firstFreeSlot(array<bool> activeSlots, int enabledSlots) =>
    int freeSlot = -1
    for slot = 0 to enabledSlots - 1
        if freeSlot == -1 and not array.get(activeSlots, slot)
            freeSlot := slot
    freeSlot

newestActiveSlot(array<bool> activeSlots, array<int> createdBars, int enabledSlots) =>
    int newestSlot = -1
    int newestBar = -1
    for slot = 0 to enabledSlots - 1
        if array.get(activeSlots, slot) and array.get(createdBars, slot) > newestBar
            newestBar := array.get(createdBars, slot)
            newestSlot := slot
    newestSlot

slotValue(array<float> sums, array<float> volumes, int slot) =>
    float slotVolume = array.get(volumes, slot)
    slotVolume > 0 ? array.get(sums, slot) / slotVolume : na

resistanceSlotColor(int slot) =>
    switch slot
        0 => color.new(color.orange, 5)
        1 => color.new(color.fuchsia, 15)
        2 => color.new(color.purple, 20)
        3 => color.new(color.orange, 10)
        4 => color.new(color.fuchsia, 20)
        5 => color.new(color.purple, 25)
        6 => color.new(color.orange, 15)
        7 => color.new(color.fuchsia, 25)
        8 => color.new(color.purple, 30)
        => color.new(color.red, 25)

supportSlotColor(int slot) =>
    switch slot
        0 => color.new(color.blue, 5)
        1 => color.new(color.aqua, 10)
        2 => color.new(color.teal, 15)
        3 => color.new(color.blue, 10)
        4 => color.new(color.aqua, 15)
        5 => color.new(color.teal, 20)
        6 => color.new(color.blue, 15)
        7 => color.new(color.aqua, 20)
        8 => color.new(color.teal, 25)
        => color.new(color.navy, 20)

//------------------------------------------------------------------------------
// Oscillator and common values
//------------------------------------------------------------------------------

rsiValue = ta.rsi(stochSource, lengthRSI)
stochValue = ta.stoch(rsiValue, rsiValue, rsiValue, lengthStoch)
k = getMA(stochValue, kMode, smoothK)
d = ta.sma(k, smoothD)
atr = ta.atr(atrLength)
kCrossUnderD = ta.crossunder(k, d)
kCrossOverD = ta.crossover(k, d)
priorLocalLow = ta.lowest(low[1], structureLookback)
priorLocalHigh = ta.highest(high[1], structureLookback)

vwapHighPrice = useHiLow ? high : hlc3
vwapLowPrice = useHiLow ? low : hlc3
barVolume = volume
canCount = not confirmedOnly or barstate.isconfirmed
highViolationPrice = violationSource == "Open" ? open : violationSource == "High/Low" ? high : close
lowViolationPrice = violationSource == "Open" ? open : violationSource == "High/Low" ? low : close
interactionConfirmed = not interactionAlertsClosedOnly or barstate.isconfirmed
touchTolerance = touchToleranceATR * atr
rejectionDistance = rejectionDistanceATR * atr

bool resistanceTouchEvent = false
bool supportTouchEvent = false
bool resistanceRejectionEvent = false
bool supportRejectionEvent = false
bool resistanceFailedViolationEvent = false
bool supportFailedViolationEvent = false

//------------------------------------------------------------------------------
// Core AVWAPs
//------------------------------------------------------------------------------

var float motherHighSum = 0.0
var float motherLowSum = 0.0
var float motherHighVolume = 0.0
var float motherLowVolume = 0.0
var float motherHighNextSum = 0.0
var float motherLowNextSum = 0.0
var float motherHighNextVolume = 0.0
var float motherLowNextVolume = 0.0
var float motherHighNextExtreme = high
var float motherLowNextExtreme = low
var float motherHighAnchor = high
var float motherLowAnchor = low
var int motherHighCreatedBar = 0
var int motherLowCreatedBar = 0
var int motherHighViolationCount = 0
var int motherLowViolationCount = 0
var bool motherHighActive = true
var bool motherLowActive = true
var bool coreHighTouchLatched = false
var bool coreLowTouchLatched = false
var bool motherHighAwaitingConfirmation = false
var bool motherLowAwaitingConfirmation = false
var int motherHighNextStart = 0
var int motherLowNextStart = 0
var bool motherHighNextTurned = false
var bool motherLowNextTurned = false
var bool motherHighNextActive = false
var bool motherLowNextActive = false
var float motherHighStructureLevel = na
var float motherLowStructureLevel = na
var array<chart.point> motherHighOriginPoints = array.new<chart.point>()
var array<chart.point> motherLowOriginPoints = array.new<chart.point>()

// A Core candidate belongs to one complete oscillator episode. A resistance
// candidate can only start in overbought territory; support uses oversold.
if not motherHighNextActive and d > upperBand
    motherHighNextActive := true
    motherHighNextExtreme := high
    motherHighNextSum := 0.0
    motherHighNextVolume := 0.0
    motherHighNextStart := bar_index
    motherHighNextTurned := false
    motherHighStructureLevel := priorLocalLow
    array.clear(motherHighOriginPoints)

if not motherLowNextActive and d < lowerBand
    motherLowNextActive := true
    motherLowNextExtreme := low
    motherLowNextSum := 0.0
    motherLowNextVolume := 0.0
    motherLowNextStart := bar_index
    motherLowNextTurned := false
    motherLowStructureLevel := priorLocalHigh
    array.clear(motherLowOriginPoints)

if motherHighActive
    motherHighSum += vwapHighPrice * barVolume
    motherHighVolume += barVolume
if motherLowActive
    motherLowSum += vwapLowPrice * barVolume
    motherLowVolume += barVolume
if motherHighNextActive
    if high > motherHighNextExtreme
        motherHighNextExtreme := high
        motherHighNextSum := 0.0
        motherHighNextVolume := 0.0
        motherHighNextStart := bar_index
        motherHighNextTurned := false
        motherHighStructureLevel := priorLocalLow
        array.clear(motherHighOriginPoints)
    motherHighNextSum += vwapHighPrice * barVolume
    motherHighNextVolume += barVolume
    float motherHighDevelopingValue = motherHighNextVolume > 0 ? motherHighNextSum / motherHighNextVolume : na
    if not na(motherHighDevelopingValue)
        array.push(motherHighOriginPoints, chart.point.from_index(bar_index, motherHighDevelopingValue))
    if kCrossUnderD
        motherHighNextTurned := true

if motherLowNextActive
    if low < motherLowNextExtreme
        motherLowNextExtreme := low
        motherLowNextSum := 0.0
        motherLowNextVolume := 0.0
        motherLowNextStart := bar_index
        motherLowNextTurned := false
        motherLowStructureLevel := priorLocalHigh
        array.clear(motherLowOriginPoints)
    motherLowNextSum += vwapLowPrice * barVolume
    motherLowNextVolume += barVolume
    float motherLowDevelopingValue = motherLowNextVolume > 0 ? motherLowNextSum / motherLowNextVolume : na
    if not na(motherLowDevelopingValue)
        array.push(motherLowOriginPoints, chart.point.from_index(bar_index, motherLowDevelopingValue))
    if kCrossOverD
        motherLowNextTurned := true

motherHighBeforePromotion = motherHighVolume > 0 ? motherHighSum / motherHighVolume : na
motherLowBeforePromotion = motherLowVolume > 0 ? motherLowSum / motherLowVolume : na

bool motherHighInvalidatedNowEvent = false
bool motherLowInvalidatedNowEvent = false

bool coreHighInTouchZone = motherHighActive and not na(motherHighBeforePromotion) and high >= motherHighBeforePromotion - touchTolerance and low <= motherHighBeforePromotion + touchTolerance
bool coreLowInTouchZone = motherLowActive and not na(motherLowBeforePromotion) and high >= motherLowBeforePromotion - touchTolerance and low <= motherLowBeforePromotion + touchTolerance

if interactionConfirmed
    if coreHighInTouchZone and not coreHighTouchLatched
        resistanceTouchEvent := true
    if coreLowInTouchZone and not coreLowTouchLatched
        supportTouchEvent := true
    coreHighTouchLatched := coreHighInTouchZone
    coreLowTouchLatched := coreLowInTouchZone

    if motherHighActive and high >= motherHighBeforePromotion - touchTolerance and close <= motherHighBeforePromotion - rejectionDistance
        resistanceRejectionEvent := true
    if motherLowActive and low <= motherLowBeforePromotion + touchTolerance and close >= motherLowBeforePromotion + rejectionDistance
        supportRejectionEvent := true

if canCount and motherHighActive
    bool coreHighViolatedNow = highViolationPrice > motherHighBeforePromotion
    int previousCoreHighViolations = motherHighViolationCount
    if interactionConfirmed and not coreHighViolatedNow and previousCoreHighViolations >= minimumFailedBars and previousCoreHighViolations < violationBars
        resistanceFailedViolationEvent := true
    motherHighViolationCount := coreHighViolatedNow ? previousCoreHighViolations + 1 : 0
    if motherHighViolationCount >= violationBars
        motherHighActive := false
        motherHighAwaitingConfirmation := true
        motherHighViolationCount := 0
        motherHighInvalidatedNowEvent := true

if canCount and motherLowActive
    bool coreLowViolatedNow = lowViolationPrice < motherLowBeforePromotion
    int previousCoreLowViolations = motherLowViolationCount
    if interactionConfirmed and not coreLowViolatedNow and previousCoreLowViolations >= minimumFailedBars and previousCoreLowViolations < violationBars
        supportFailedViolationEvent := true
    motherLowViolationCount := coreLowViolatedNow ? previousCoreLowViolations + 1 : 0
    if motherLowViolationCount >= violationBars
        motherLowActive := false
        motherLowAwaitingConfirmation := true
        motherLowViolationCount := 0
        motherLowInvalidatedNowEvent := true

bool motherHighPivotConfirmed = motherHighNextActive and bar_index - motherHighNextStart >= pivotConfirmationBars
bool motherLowPivotConfirmed = motherLowNextActive and bar_index - motherLowNextStart >= pivotConfirmationBars
bool motherHighStructureConfirmed = motherHighNextActive and not na(motherHighStructureLevel) and close < motherHighStructureLevel
bool motherLowStructureConfirmed = motherLowNextActive and not na(motherLowStructureLevel) and close > motherLowStructureLevel
bool motherHighReactionConfirmed = motherHighNextActive and motherHighNextTurned and close <= motherHighNextExtreme - confirmationMoveATR * atr
bool motherLowReactionConfirmed = motherLowNextActive and motherLowNextTurned and close >= motherLowNextExtreme + confirmationMoveATR * atr
bool motherHighTopConfirmed = motherHighReactionConfirmed and (confirmationMode == "Reaction only" or motherHighPivotConfirmed and (confirmationMode == "Pivot confirmed" or motherHighStructureConfirmed))
bool motherLowBottomConfirmed = motherLowReactionConfirmed and (confirmationMode == "Reaction only" or motherLowPivotConfirmed and (confirmationMode == "Pivot confirmed" or motherLowStructureConfirmed))

bool motherHighPromotedEvent = motherHighAwaitingConfirmation and motherHighTopConfirmed
bool motherLowPromotedEvent = motherLowAwaitingConfirmation and motherLowBottomConfirmed

if motherHighPromotedEvent
    if array.size(motherHighOriginPoints) > 1
        polyline.new(array.copy(motherHighOriginPoints), curved=false, closed=false, xloc=xloc.bar_index, line_color=color.new(color.red, 35), line_style=line.style_dotted, line_width=3)
    motherHighSum := motherHighNextSum
    motherHighVolume := motherHighNextVolume
    motherHighAnchor := motherHighNextExtreme
    motherHighCreatedBar := bar_index
    motherHighViolationCount := 0
    motherHighActive := true
    motherHighAwaitingConfirmation := false
    motherHighNextSum := 0.0
    motherHighNextVolume := 0.0
    motherHighNextExtreme := high
    motherHighNextStart := bar_index
    motherHighNextTurned := false
    motherHighNextActive := false
    motherHighStructureLevel := priorLocalLow
    array.clear(motherHighOriginPoints)

if motherLowPromotedEvent
    if array.size(motherLowOriginPoints) > 1
        polyline.new(array.copy(motherLowOriginPoints), curved=false, closed=false, xloc=xloc.bar_index, line_color=color.new(color.green, 35), line_style=line.style_dotted, line_width=3)
    motherLowSum := motherLowNextSum
    motherLowVolume := motherLowNextVolume
    motherLowAnchor := motherLowNextExtreme
    motherLowCreatedBar := bar_index
    motherLowViolationCount := 0
    motherLowActive := true
    motherLowAwaitingConfirmation := false
    motherLowNextSum := 0.0
    motherLowNextVolume := 0.0
    motherLowNextExtreme := low
    motherLowNextStart := bar_index
    motherLowNextTurned := false
    motherLowNextActive := false
    motherLowStructureLevel := priorLocalHigh
    array.clear(motherLowOriginPoints)

// Stale, unconfirmed Core candidates cannot be promoted much later.
if motherHighNextActive and bar_index - motherHighNextStart > candidateTimeout
    motherHighNextActive := false
    motherHighNextTurned := false
    motherHighNextSum := 0.0
    motherHighNextVolume := 0.0
    array.clear(motherHighOriginPoints)

if motherLowNextActive and bar_index - motherLowNextStart > candidateTimeout
    motherLowNextActive := false
    motherLowNextTurned := false
    motherLowNextSum := 0.0
    motherLowNextVolume := 0.0
    array.clear(motherLowOriginPoints)

motherHigh = motherHighActive and motherHighVolume > 0 ? motherHighSum / motherHighVolume : na
motherLow = motherLowActive and motherLowVolume > 0 ? motherLowSum / motherLowVolume : na
motherHighNext = motherHighNextActive and motherHighNextVolume > 0 ? motherHighNextSum / motherHighNextVolume : na
motherLowNext = motherLowNextActive and motherLowNextVolume > 0 ? motherLowNextSum / motherLowNextVolume : na

//------------------------------------------------------------------------------
// Ten fixed Adaptive AVWAP slots per direction
//------------------------------------------------------------------------------

var highSums = array.new_float(10, 0.0)
var highVolumes = array.new_float(10, 0.0)
var highActive = array.new_bool(10, false)
var highViolations = array.new_int(10, 0)
var highCreatedBars = array.new_int(10, -1)
var highAnchorPrices = array.new_float(10, na)
var highTouchLatched = array.new_bool(10, false)

var lowSums = array.new_float(10, 0.0)
var lowVolumes = array.new_float(10, 0.0)
var lowActive = array.new_bool(10, false)
var lowViolations = array.new_int(10, 0)
var lowCreatedBars = array.new_int(10, -1)
var lowAnchorPrices = array.new_float(10, na)
var lowTouchLatched = array.new_bool(10, false)

bool highInvalidatedEvent = motherHighInvalidatedNowEvent
bool lowInvalidatedEvent = motherLowInvalidatedNowEvent

// Update every active generation and invalidate each one independently.
for slot = 0 to 9
    if array.get(highActive, slot)
        array.set(highSums, slot, array.get(highSums, slot) + vwapHighPrice * barVolume)
        array.set(highVolumes, slot, array.get(highVolumes, slot) + barVolume)
        float currentHighValue = slotValue(highSums, highVolumes, slot)
        bool highInTouchZone = high >= currentHighValue - touchTolerance and low <= currentHighValue + touchTolerance
        if interactionConfirmed
            if highInTouchZone and not array.get(highTouchLatched, slot)
                resistanceTouchEvent := true
            array.set(highTouchLatched, slot, highInTouchZone)
            if high >= currentHighValue - touchTolerance and close <= currentHighValue - rejectionDistance
                resistanceRejectionEvent := true
        if canCount
            bool highViolatedNow = highViolationPrice > currentHighValue
            int previousCount = array.get(highViolations, slot)
            if interactionConfirmed and not highViolatedNow and previousCount >= minimumFailedBars and previousCount < violationBars
                resistanceFailedViolationEvent := true
            int count = highViolatedNow ? previousCount + 1 : 0
            array.set(highViolations, slot, count)
            if count >= violationBars
                array.set(highActive, slot, false)
                array.set(highViolations, slot, 0)
                array.set(highTouchLatched, slot, false)
                highInvalidatedEvent := true

    if array.get(lowActive, slot)
        array.set(lowSums, slot, array.get(lowSums, slot) + vwapLowPrice * barVolume)
        array.set(lowVolumes, slot, array.get(lowVolumes, slot) + barVolume)
        float currentLowValue = slotValue(lowSums, lowVolumes, slot)
        bool lowInTouchZone = high >= currentLowValue - touchTolerance and low <= currentLowValue + touchTolerance
        if interactionConfirmed
            if lowInTouchZone and not array.get(lowTouchLatched, slot)
                supportTouchEvent := true
            array.set(lowTouchLatched, slot, lowInTouchZone)
            if low <= currentLowValue + touchTolerance and close >= currentLowValue + rejectionDistance
                supportRejectionEvent := true
        if canCount
            bool lowViolatedNow = lowViolationPrice < currentLowValue
            int previousCount = array.get(lowViolations, slot)
            if interactionConfirmed and not lowViolatedNow and previousCount >= minimumFailedBars and previousCount < violationBars
                supportFailedViolationEvent := true
            int count = lowViolatedNow ? previousCount + 1 : 0
            array.set(lowViolations, slot, count)
            if count >= violationBars
                array.set(lowActive, slot, false)
                array.set(lowViolations, slot, 0)
                array.set(lowTouchLatched, slot, false)
                lowInvalidatedEvent := true

//------------------------------------------------------------------------------
// Determine the newest valid reference for each direction
//------------------------------------------------------------------------------

int newestHighSlot = newestActiveSlot(highActive, highCreatedBars, maxGenerations)
int newestLowSlot = newestActiveSlot(lowActive, lowCreatedBars, maxGenerations)

float newestHighValue = newestHighSlot >= 0 ? slotValue(highSums, highVolumes, newestHighSlot) : motherHigh
float newestLowValue = newestLowSlot >= 0 ? slotValue(lowSums, lowVolumes, newestLowSlot) : motherLow
float newestHighAnchor = newestHighSlot >= 0 ? array.get(highAnchorPrices, newestHighSlot) : motherHighAnchor
float newestLowAnchor = newestLowSlot >= 0 ? array.get(lowAnchorPrices, newestLowSlot) : motherLowAnchor
int newestHighBar = newestHighSlot >= 0 ? array.get(highCreatedBars, newestHighSlot) : motherHighCreatedBar
int newestLowBar = newestLowSlot >= 0 ? array.get(lowCreatedBars, newestLowSlot) : motherLowCreatedBar

int freeHighSlot = firstFreeSlot(highActive, maxGenerations)
int freeLowSlot = firstFreeSlot(lowActive, maxGenerations)

bool highAbandoned = freeHighSlot >= 0 and not na(atr) and newestHighValue - close >= creationDistanceATR * atr and bar_index - newestHighBar >= minimumBarsBetween
bool lowAbandoned = freeLowSlot >= 0 and not na(atr) and close - newestLowValue >= creationDistanceATR * atr and bar_index - newestLowBar >= minimumBarsBetween

//------------------------------------------------------------------------------
// Candidate state: lower high for resistance / higher low for support
//------------------------------------------------------------------------------

var bool highArmed = false
var bool lowArmed = false
var bool highCandidateActive = false
var bool lowCandidateActive = false
var bool highCandidateTurned = false
var bool lowCandidateTurned = false
var int highCandidateStart = na
var int lowCandidateStart = na
var float highCandidateExtreme = na
var float lowCandidateExtreme = na
var float highCandidateSum = 0.0
var float lowCandidateSum = 0.0
var float highCandidateVolume = 0.0
var float lowCandidateVolume = 0.0
var float highCandidateStructureLevel = na
var float lowCandidateStructureLevel = na
var array<chart.point> highCandidateOriginPoints = array.new<chart.point>()
var array<chart.point> lowCandidateOriginPoints = array.new<chart.point>()

// A Core replacement starts a new search context. Existing confirmed
// Adaptive AVWAPs remain active, but an unfinished candidate from the old Core is discarded.
if motherHighPromotedEvent
    highArmed := false
    highCandidateActive := false
    highCandidateTurned := false
if motherLowPromotedEvent
    lowArmed := false
    lowCandidateActive := false
    lowCandidateTurned := false

if highAbandoned
    highArmed := true
if lowAbandoned
    lowArmed := true

// An overbought episode begins a possible new resistance anchor.
if highArmed and not highCandidateActive and d > upperBand
    highCandidateActive := true
    highCandidateTurned := false
    highCandidateStart := bar_index
    highCandidateExtreme := high
    highCandidateSum := 0.0
    highCandidateVolume := 0.0
    highCandidateStructureLevel := priorLocalLow
    array.clear(highCandidateOriginPoints)

// An oversold episode begins a possible new support anchor.
if lowArmed and not lowCandidateActive and d < lowerBand
    lowCandidateActive := true
    lowCandidateTurned := false
    lowCandidateStart := bar_index
    lowCandidateExtreme := low
    lowCandidateSum := 0.0
    lowCandidateVolume := 0.0
    lowCandidateStructureLevel := priorLocalHigh
    array.clear(lowCandidateOriginPoints)

if highCandidateActive
    if high > highCandidateExtreme
        highCandidateExtreme := high
        highCandidateSum := 0.0
        highCandidateVolume := 0.0
        highCandidateStart := bar_index
        highCandidateTurned := false
        highCandidateStructureLevel := priorLocalLow
        array.clear(highCandidateOriginPoints)
    highCandidateSum += vwapHighPrice * barVolume
    highCandidateVolume += barVolume
    float highDevelopingValue = highCandidateVolume > 0 ? highCandidateSum / highCandidateVolume : na
    if not na(highDevelopingValue)
        array.push(highCandidateOriginPoints, chart.point.from_index(bar_index, highDevelopingValue))
    if kCrossUnderD
        highCandidateTurned := true

if lowCandidateActive
    if low < lowCandidateExtreme
        lowCandidateExtreme := low
        lowCandidateSum := 0.0
        lowCandidateVolume := 0.0
        lowCandidateStart := bar_index
        lowCandidateTurned := false
        lowCandidateStructureLevel := priorLocalHigh
        array.clear(lowCandidateOriginPoints)
    lowCandidateSum += vwapLowPrice * barVolume
    lowCandidateVolume += barVolume
    float lowDevelopingValue = lowCandidateVolume > 0 ? lowCandidateSum / lowCandidateVolume : na
    if not na(lowDevelopingValue)
        array.push(lowCandidateOriginPoints, chart.point.from_index(bar_index, lowDevelopingValue))
    if kCrossOverD
        lowCandidateTurned := true

bool highPivotConfirmed = highCandidateActive and bar_index - highCandidateStart >= pivotConfirmationBars
bool lowPivotConfirmed = lowCandidateActive and bar_index - lowCandidateStart >= pivotConfirmationBars
bool highStructureConfirmed = highCandidateActive and not na(highCandidateStructureLevel) and close < highCandidateStructureLevel
bool lowStructureConfirmed = lowCandidateActive and not na(lowCandidateStructureLevel) and close > lowCandidateStructureLevel
bool highReactionReached = highCandidateActive and highCandidateTurned and close <= highCandidateExtreme - confirmationMoveATR * atr
bool lowReactionReached = lowCandidateActive and lowCandidateTurned and close >= lowCandidateExtreme + confirmationMoveATR * atr
bool highReactionConfirmed = highReactionReached and (confirmationMode == "Reaction only" or highPivotConfirmed and (confirmationMode == "Pivot confirmed" or highStructureConfirmed))
bool lowReactionConfirmed = lowReactionReached and (confirmationMode == "Reaction only" or lowPivotConfirmed and (confirmationMode == "Pivot confirmed" or lowStructureConfirmed))

bool highSpacingValid = highCandidateActive and (not requireProgressive ? math.abs(highCandidateExtreme - newestHighAnchor) >= minimumAnchorSpacingATR * atr : highCandidateExtreme <= newestHighAnchor - minimumAnchorSpacingATR * atr)
bool lowSpacingValid = lowCandidateActive and (not requireProgressive ? math.abs(lowCandidateExtreme - newestLowAnchor) >= minimumAnchorSpacingATR * atr : lowCandidateExtreme >= newestLowAnchor + minimumAnchorSpacingATR * atr)

bool highCreatedEvent = false
bool lowCreatedEvent = false

if highReactionConfirmed and highSpacingValid and freeHighSlot >= 0
    if array.size(highCandidateOriginPoints) > 1
        polyline.new(array.copy(highCandidateOriginPoints), curved=false, closed=false, xloc=xloc.bar_index, line_color=resistanceSlotColor(freeHighSlot), line_style=line.style_dotted, line_width=2)
    array.set(highSums, freeHighSlot, highCandidateSum)
    array.set(highVolumes, freeHighSlot, highCandidateVolume)
    array.set(highActive, freeHighSlot, true)
    array.set(highViolations, freeHighSlot, 0)
    array.set(highTouchLatched, freeHighSlot, false)
    array.set(highCreatedBars, freeHighSlot, bar_index)
    array.set(highAnchorPrices, freeHighSlot, highCandidateExtreme)
    highCandidateActive := false
    highCandidateTurned := false
    highArmed := false
    highCreatedEvent := true
    array.clear(highCandidateOriginPoints)

if lowReactionConfirmed and lowSpacingValid and freeLowSlot >= 0
    if array.size(lowCandidateOriginPoints) > 1
        polyline.new(array.copy(lowCandidateOriginPoints), curved=false, closed=false, xloc=xloc.bar_index, line_color=supportSlotColor(freeLowSlot), line_style=line.style_dotted, line_width=2)
    array.set(lowSums, freeLowSlot, lowCandidateSum)
    array.set(lowVolumes, freeLowSlot, lowCandidateVolume)
    array.set(lowActive, freeLowSlot, true)
    array.set(lowViolations, freeLowSlot, 0)
    array.set(lowTouchLatched, freeLowSlot, false)
    array.set(lowCreatedBars, freeLowSlot, bar_index)
    array.set(lowAnchorPrices, freeLowSlot, lowCandidateExtreme)
    lowCandidateActive := false
    lowCandidateTurned := false
    lowArmed := false
    lowCreatedEvent := true
    array.clear(lowCandidateOriginPoints)

// Discard stale candidates. A new abandonment condition may arm another search.
if highCandidateActive and bar_index - highCandidateStart > candidateTimeout
    highCandidateActive := false
    highCandidateTurned := false
    highArmed := false
    array.clear(highCandidateOriginPoints)

if lowCandidateActive and bar_index - lowCandidateStart > candidateTimeout
    lowCandidateActive := false
    lowCandidateTurned := false
    lowArmed := false
    array.clear(lowCandidateOriginPoints)

// If all enabled slots become occupied, stop waiting for another candidate.
if firstFreeSlot(highActive, maxGenerations) < 0
    highArmed := false
    highCandidateActive := false
    array.clear(highCandidateOriginPoints)
if firstFreeSlot(lowActive, maxGenerations) < 0
    lowArmed := false
    lowCandidateActive := false
    array.clear(lowCandidateOriginPoints)

//------------------------------------------------------------------------------
// Plots
//------------------------------------------------------------------------------

plot(showMothers ? motherHigh : na, "Core Resistance AVWAP", color.new(color.red, 35), 3, plot.style_circles)
plot(showMothers ? motherLow : na, "Core Support AVWAP", color.new(color.green, 35), 3, plot.style_circles)

high1 = maxGenerations >= 1 and array.get(highActive, 0) ? slotValue(highSums, highVolumes, 0) : na
high2 = maxGenerations >= 2 and array.get(highActive, 1) ? slotValue(highSums, highVolumes, 1) : na
high3 = maxGenerations >= 3 and array.get(highActive, 2) ? slotValue(highSums, highVolumes, 2) : na
high4 = maxGenerations >= 4 and array.get(highActive, 3) ? slotValue(highSums, highVolumes, 3) : na
high5 = maxGenerations >= 5 and array.get(highActive, 4) ? slotValue(highSums, highVolumes, 4) : na
high6 = maxGenerations >= 6 and array.get(highActive, 5) ? slotValue(highSums, highVolumes, 5) : na
high7 = maxGenerations >= 7 and array.get(highActive, 6) ? slotValue(highSums, highVolumes, 6) : na
high8 = maxGenerations >= 8 and array.get(highActive, 7) ? slotValue(highSums, highVolumes, 7) : na
high9 = maxGenerations >= 9 and array.get(highActive, 8) ? slotValue(highSums, highVolumes, 8) : na
high10 = maxGenerations >= 10 and array.get(highActive, 9) ? slotValue(highSums, highVolumes, 9) : na
low1 = maxGenerations >= 1 and array.get(lowActive, 0) ? slotValue(lowSums, lowVolumes, 0) : na
low2 = maxGenerations >= 2 and array.get(lowActive, 1) ? slotValue(lowSums, lowVolumes, 1) : na
low3 = maxGenerations >= 3 and array.get(lowActive, 2) ? slotValue(lowSums, lowVolumes, 2) : na
low4 = maxGenerations >= 4 and array.get(lowActive, 3) ? slotValue(lowSums, lowVolumes, 3) : na
low5 = maxGenerations >= 5 and array.get(lowActive, 4) ? slotValue(lowSums, lowVolumes, 4) : na
low6 = maxGenerations >= 6 and array.get(lowActive, 5) ? slotValue(lowSums, lowVolumes, 5) : na
low7 = maxGenerations >= 7 and array.get(lowActive, 6) ? slotValue(lowSums, lowVolumes, 6) : na
low8 = maxGenerations >= 8 and array.get(lowActive, 7) ? slotValue(lowSums, lowVolumes, 7) : na
low9 = maxGenerations >= 9 and array.get(lowActive, 8) ? slotValue(lowSums, lowVolumes, 8) : na
low10 = maxGenerations >= 10 and array.get(lowActive, 9) ? slotValue(lowSums, lowVolumes, 9) : na

plot(high1, "Adaptive Resistance AVWAP 1", resistanceSlotColor(0), 2, plot.style_circles)
plot(high2, "Adaptive Resistance AVWAP 2", resistanceSlotColor(1), 2, plot.style_circles)
plot(high3, "Adaptive Resistance AVWAP 3", resistanceSlotColor(2), 2, plot.style_circles)
plot(high4, "Adaptive Resistance AVWAP 4", resistanceSlotColor(3), 2, plot.style_circles)
plot(high5, "Adaptive Resistance AVWAP 5", resistanceSlotColor(4), 2, plot.style_circles)
plot(high6, "Adaptive Resistance AVWAP 6", resistanceSlotColor(5), 2, plot.style_circles)
plot(high7, "Adaptive Resistance AVWAP 7", resistanceSlotColor(6), 2, plot.style_circles)
plot(high8, "Adaptive Resistance AVWAP 8", resistanceSlotColor(7), 2, plot.style_circles)
plot(high9, "Adaptive Resistance AVWAP 9", resistanceSlotColor(8), 2, plot.style_circles)
plot(high10, "Adaptive Resistance AVWAP 10", resistanceSlotColor(9), 2, plot.style_circles)
plot(low1, "Adaptive Support AVWAP 1", supportSlotColor(0), 2, plot.style_circles)
plot(low2, "Adaptive Support AVWAP 2", supportSlotColor(1), 2, plot.style_circles)
plot(low3, "Adaptive Support AVWAP 3", supportSlotColor(2), 2, plot.style_circles)
plot(low4, "Adaptive Support AVWAP 4", supportSlotColor(3), 2, plot.style_circles)
plot(low5, "Adaptive Support AVWAP 5", supportSlotColor(4), 2, plot.style_circles)
plot(low6, "Adaptive Support AVWAP 6", supportSlotColor(5), 2, plot.style_circles)
plot(low7, "Adaptive Support AVWAP 7", supportSlotColor(6), 2, plot.style_circles)
plot(low8, "Adaptive Support AVWAP 8", supportSlotColor(7), 2, plot.style_circles)
plot(low9, "Adaptive Support AVWAP 9", supportSlotColor(8), 2, plot.style_circles)
plot(low10, "Adaptive Support AVWAP 10", supportSlotColor(9), 2, plot.style_circles)

highCandidateValue = highCandidateVolume > 0 ? highCandidateSum / highCandidateVolume : na
lowCandidateValue = lowCandidateVolume > 0 ? lowCandidateSum / lowCandidateVolume : na
plot(showCandidates and highCandidateActive ? highCandidateValue : na, "Developing Adaptive Resistance Candidate", color.new(color.orange, 70), 1, plot.style_circles)
plot(showCandidates and lowCandidateActive ? lowCandidateValue : na, "Developing Adaptive Support Candidate", color.new(color.blue, 70), 1, plot.style_circles)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------

alertcondition(highCreatedEvent, "New Adaptive resistance AVWAP", "New Adaptive resistance AVWAP created ({{ticker}} {{interval}})")
alertcondition(lowCreatedEvent, "New Adaptive support AVWAP", "New Adaptive support AVWAP created ({{ticker}} {{interval}})")
alertcondition(highInvalidatedEvent, "Resistance AVWAP invalidated", "A Core or Adaptive resistance AVWAP was invalidated ({{ticker}} {{interval}})")
alertcondition(lowInvalidatedEvent, "Support AVWAP invalidated", "A Core or Adaptive support AVWAP was invalidated ({{ticker}} {{interval}})")
alertcondition(resistanceTouchEvent, "Resistance AVWAP touch", "Price touched a Core or Adaptive resistance AVWAP ({{ticker}} {{interval}})")
alertcondition(supportTouchEvent, "Support AVWAP touch", "Price touched a Core or Adaptive support AVWAP ({{ticker}} {{interval}})")
alertcondition(resistanceRejectionEvent, "Resistance AVWAP rejection", "Price rejected a Core or Adaptive resistance AVWAP ({{ticker}} {{interval}})")
alertcondition(supportRejectionEvent, "Support AVWAP rejection", "Price rejected a Core or Adaptive support AVWAP ({{ticker}} {{interval}})")
alertcondition(resistanceFailedViolationEvent, "Failed resistance AVWAP violation", "A partial resistance AVWAP violation failed before confirmation ({{ticker}} {{interval}})")
alertcondition(supportFailedViolationEvent, "Failed support AVWAP violation", "A partial support AVWAP violation failed before confirmation ({{ticker}} {{interval}})")
````
