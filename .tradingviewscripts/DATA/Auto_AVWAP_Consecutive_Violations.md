<!-- tradingview-pine-id: PUB;38ba70a94f204d6bac25752eb3d0eb75 -->
<!-- tradingviewscripts-format: 1 -->
# Auto AVWAP - Consecutive Violations

Source: https://www.tradingview.com/script/6rTGrdmY/

## Description

Auto AVWAP with Consecutive Violation Control

This indicator plots automatically anchored Volume Weighted Average Price levels for potential support and resistance.

It maintains two primary Anchored VWAPs:

- High AVWAP: an upper reference derived from price highs or HLC3.
- Low AVWAP: a lower reference derived from price lows or HLC3.

It also calculates two developing “Next” AVWAPs. These represent potential future anchors identified through price extremes and Stochastic RSI conditions.

The main purpose of this version is to provide explicit control over when an active AVWAP is considered invalid. Unlike the original implementation, a main AVWAP is not replaced merely because a new price extreme appears or because the Stochastic RSI confirms a reversal. It remains active until price violates it for a configurable number of consecutive bars.

Core calculation

Each AVWAP is calculated as:

AVWAP = Sum(Price × Volume) / Sum(Volume)

By default, the indicator uses:

- High for the High AVWAP calculation.
- Low for the Low AVWAP calculation.

Users can disable the High/Low setting to calculate both AVWAPs from HLC3 instead.

Anchor candidate logic

Stochastic RSI and new price extremes are used to identify and maintain possible future anchor points.

The developing candidate levels are displayed as:

- High Next: potential future upper AVWAP.
- Low Next: potential future lower AVWAP.

These candidate levels can continue to develop without immediately replacing the active AVWAPs.

Consecutive violation control

A High AVWAP is considered violated when the selected price source is above it.

A Low AVWAP is considered violated when the selected price source is below it.

The active AVWAP is replaced only after the required number of consecutive violations has been reached. If a bar does not violate the level, the corresponding counter returns to zero.

This prevents a single wick, temporary breakout, or isolated close from prematurely replacing an established AVWAP.

Configurable violation source

The violation source can be selected from:

- Close: uses the candle close.
- Open: uses the candle open.
- High/Low: uses the high for High AVWAP violations and the low for Low AVWAP violations.

The “Count only closed bars” option prevents an unfinished real-time candle from temporarily increasing the violation counter.

Default configuration

The default configuration requires three consecutive confirmed closes:

- Consecutive bars to invalidate: 3
- Violation source: Close
- Count only closed bars: Enabled

This configuration is intended to filter isolated price excursions while allowing a sustained break to invalidate the active level.

Plots

The indicator displays:

- High AVWAP: primary upper reference.
- Low AVWAP: primary lower reference.
- High Next: developing upper candidate.
- Low Next: developing lower candidate.

The primary plots use stronger colors and greater width. Candidate plots use more transparent colors.

Alerts

The indicator includes alerts for:

- Breakout in either direction.
- High AVWAP resistance break.
- Low AVWAP support break.
- High AVWAP invalidation after consecutive violations.
- Low AVWAP invalidation after consecutive violations.

The breakout alerts can use either the candle open or close through the corresponding input.

How to use

- Treat the High AVWAP as a dynamic upper reference or potential resistance area.
- Treat the Low AVWAP as a dynamic lower reference or potential support area.
- Use the Next plots to monitor developing replacement anchors.
- Increase the required number of violations to retain AVWAPs for longer.
- Decrease it to make the indicator respond more quickly to sustained price breaks.
- Prefer confirmed closes when the objective is to reduce reactions to intrabar noise.
- Adjust the settings according to the symbol, timeframe, liquidity, and volatility regime.
- Combine the levels with market structure, volume analysis, and risk management.

Open-source reuse and credits

This script is based on the open-source indicator:

“Auto AVWAP (Anchored-VWAP)” by Electrified.

Original source:
https://www.tradingview.com/script/ZmNNKbwE-Auto-AVWAP-Anchored-VWAP/

This version adds and/or changes:

1) Consecutive-bar invalidation for the primary High and Low AVWAPs.
2) Configurable violation count.
3) Selectable Close, Open, or High/Low violation source.
4) Optional confirmed-bar-only counting.
5) Removal of automatic primary AVWAP replacement caused solely by new price extremes.
6) Removal of automatic primary AVWAP replacement caused solely by Stochastic RSI reversal confirmation.
7) Promotion of a developing candidate only after the active AVWAP satisfies its invalidation rule.
8) Dedicated High and Low AVWAP invalidation alerts.
9) Clear separation between candidate-anchor formation and active-level invalidation.

Limitations

- An AVWAP is a volume-weighted reference, not a guaranteed support or resistance level.
- Consecutive-bar confirmation introduces a deliberate delay before invalidation.
- Using High/Low as the violation source is more sensitive to intrabar price excursions.
- Candidate anchors depend on price extremes and Stochastic RSI behavior.
- Results vary across symbols, timeframes, sessions, and volatility regimes.
- Historical plots do not guarantee future market behavior.
- This is a decision-support tool, not a guaranteed-profit system.
- Risk management is required.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Original: © Electrified (electrifiedtrading)
// Modification: lifecycle controlled by consecutive violations
//@version=6
indicator(title="Auto AVWAP - Consecutive Violations", shorttitle="Auto AVWAP CV", overlay=true, format=format.price, precision=2, timeframe="")
kcolor = #0094FF
dcolor = #FF6A00
WMA = "WMA", EMA = "EMA", SMA = "SMA", VWMA = "VWMA", VAWMA = "VAWMA"
///////////////////////////////////////////////////
// Inputs
useHiLow = input.bool(true, "Use High/Low instead of HLC3", group="Anchored VWAP", tooltip="When true, high and low values are used to calculate each AVWAP instead of HLC3.")
useOpen  = input.bool(true, "Use open instead of close for alerts", group="Anchored VWAP", tooltip="Using the open instead of the close can avoid transient intrabar alert signals.")
violationBars   = input.int(3, "Consecutive bars to invalidate", group="AVWAP Invalidation", minval=1, tooltip="A High AVWAP is violated above it. A Low AVWAP is violated below it.")
violationSource = input.string("Close", "Violation source", group="AVWAP Invalidation", options=["Close", "Open", "High/Low"], tooltip="Close: candle close. Open: candle open. High/Low: high for High AVWAP and low for Low AVWAP.")
confirmedOnly   = input.bool(true, "Count only closed bars", group="AVWAP Invalidation", tooltip="Prevents the live candle from temporarily increasing the violation counter.")
k_mode      = input.string(WMA, "K Mode", group="Stochastic RSI", inline="Source", options=[SMA, EMA, WMA, VWMA, VAWMA])
src         = input.source(hlc3, "Source", group="Stochastic RSI", inline="Source")
smoothK     = input.int(4, "K", group="Stochastic RSI", inline="Values", minval=1)
smoothD     = input.int(4, "D", group="Stochastic RSI", inline="Values", minval=1)
lengthRSI   = input.int(64, "RSI", group="Lengths", inline="Lengths", minval=1)
lengthStoch = input.int(48, "Stochastic", group="Lengths", inline="Lengths", minval=1)
lowerBand = input.int(20, "Lower", group="Band", inline="Band", maxval=50, minval=0)
upperBand = input.int(80, "Upper", group="Band", inline="Band", minval=50, maxval=100)
lowerReversal = input.int(20, "Lower", group="Reversal", inline="Reversal", maxval=100, minval=0)
upperReversal = input.int(80, "Upper", group="Reversal", inline="Reversal", minval=0, maxval=100)
///////////////////////////////////////////////////
// Functions
vawma(src, len) =>
    sum = 0.0
    vol = 0.0
    for m = 1 to len
        i = len - m
        v = volume[i] * m
        vol := vol + v
        sum := sum + src[i] * v
    sum / vol
getMA(series, mode, len) =>
    mode == WMA ? ta.wma(series, len) :
      mode == EMA ? ta.ema(series, len) :
      mode == VWMA ? ta.vwma(series, len) :
      mode == VAWMA ? vawma(series, len) :
      ta.sma(series, len)
///////////////////////////////////////////////////
// Stochastic RSI
rsi1 = ta.rsi(src, lengthRSI)
stochValue = ta.stoch(rsi1, rsi1, rsi1, lengthStoch)
k = getMA(stochValue, k_mode, smoothK)
d = ta.sma(k, smoothD)
///////////////////////////////////////////////////
// AVWAP state
var hi = high
var lo = low
var phi = high
var plo = low
var state = 0
var float hiAVWAP_s = 0.0
var float loAVWAP_s = 0.0
var float hiAVWAP_v = 0.0
var float loAVWAP_v = 0.0
var float hiAVWAP_s_next = 0.0
var float loAVWAP_s_next = 0.0
var float hiAVWAP_v_next = 0.0
var float loAVWAP_v_next = 0.0
var int hiViolationCount = 0
var int loViolationCount = 0
// Candidate anchors continue to be formed as in the original indicator.
if d < lowerBand or high > phi
    phi := high
    hiAVWAP_s_next := 0.0
    hiAVWAP_v_next := 0.0
if d > upperBand or low < plo
    plo := low
    loAVWAP_s_next := 0.0
    loAVWAP_v_next := 0.0
vwapHi = useHiLow ? high : hlc3
vwapLo = useHiLow ? low : hlc3
hiAVWAP_s := hiAVWAP_s + vwapHi * volume
loAVWAP_s := loAVWAP_s + vwapLo * volume
hiAVWAP_v := hiAVWAP_v + volume
loAVWAP_v := loAVWAP_v + volume
hiAVWAP_s_next := hiAVWAP_s_next + vwapHi * volume
loAVWAP_s_next := loAVWAP_s_next + vwapLo * volume
hiAVWAP_v_next := hiAVWAP_v_next + volume
loAVWAP_v_next := loAVWAP_v_next + volume
if state != -1 and d < lowerBand
    state := -1
else if state != 1 and d > upperBand
    state := 1
hiAVWAP = hiAVWAP_v > 0 ? hiAVWAP_s / hiAVWAP_v : na
loAVWAP = loAVWAP_v > 0 ? loAVWAP_s / loAVWAP_v : na
hiAVWAP_next = hiAVWAP_v_next > 0 ? hiAVWAP_s_next / hiAVWAP_v_next : na
loAVWAP_next = loAVWAP_v_next > 0 ? loAVWAP_s_next / loAVWAP_v_next : na
// A violation is directional: above the High AVWAP and below the Low AVWAP.
hiViolationValue = violationSource == "Open" ? open : violationSource == "High/Low" ? high : close
loViolationValue = violationSource == "Open" ? open : violationSource == "High/Low" ? low : close
canCount = not confirmedOnly or barstate.isconfirmed
hiViolated = canCount and hiViolationValue > hiAVWAP
loViolated = canCount and loViolationValue < loAVWAP
// On an unconfirmed live bar the counters are held, not reset.
if canCount
    hiViolationCount := hiViolated ? hiViolationCount + 1 : 0
    loViolationCount := loViolated ? loViolationCount + 1 : 0
hiInvalidated = hiViolationCount >= violationBars
loInvalidated = loViolationCount >= violationBars
// The principal AVWAP can now change ONLY after X consecutive violations.
// The candidate accumulated by the original logic becomes the new principal.
if hiInvalidated
    hi := phi
    hiAVWAP_s := hiAVWAP_s_next
    hiAVWAP_v := hiAVWAP_v_next
    hiViolationCount := 0
if loInvalidated
    lo := plo
    loAVWAP_s := loAVWAP_s_next
    loAVWAP_v := loAVWAP_v_next
    loViolationCount := 0
// Recalculate after a possible promotion so the new value is plotted immediately.
hiAVWAP_plot = hiAVWAP_v > 0 ? hiAVWAP_s / hiAVWAP_v : na
loAVWAP_plot = loAVWAP_v > 0 ? loAVWAP_s / loAVWAP_v : na
plot(hiAVWAP_next, "High Next", color.new(color.red, 75), 1, style=plot.style_circles)
plot(loAVWAP_next, "Low Next", color.new(color.green, 75), 1, style=plot.style_circles)
plot(hiAVWAP_plot, "High", color.new(color.red, 50), 2, style=plot.style_circles)
plot(loAVWAP_plot, "Low", color.new(color.green, 50), 2, style=plot.style_circles)
alertValue = useOpen ? open : close
resistance = alertValue - hiAVWAP_plot
support = alertValue - loAVWAP_plot
alertcondition(resistance > 0 or support < 0, title="Breakout (▲▼)", message="Breakout ({{ticker}} {{interval}})")
alertcondition(resistance > 0, title="Resistance Broken ▲", message="Resistance Broken ▲ ({{ticker}} {{interval}})")
alertcondition(support < 0, title="Support Broken ▼", message="Support Broken ▼ ({{ticker}} {{interval}})")
alertcondition(hiInvalidated, title="High AVWAP invalidated", message="High AVWAP invalidated after consecutive violations ({{ticker}} {{interval}})")
alertcondition(loInvalidated, title="Low AVWAP invalidated", message="Low AVWAP invalidated after consecutive violations ({{ticker}} {{interval}})")
````
