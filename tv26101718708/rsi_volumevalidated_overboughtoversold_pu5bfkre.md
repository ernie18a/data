# RSI Volume-Validated Overbought/Oversold

- url: https://www.tradingview.com/script/pU5BfkRE/
- type: indicator
- pine_id: PUB;c875aa1009074ec5a3e8198f3e78d7eb
- version: 1.0

## Description

RSI Volume-Validated Overbought/Oversold

OVERVIEW

This indicator combines a standard RSI with a volume validation layer. The core idea: an RSI reading in overbought or oversold territory does not by itself guarantee that price will decelerate or reverse — the move often needs participation (volume) behind it to be meaningful. This script accumulates volume while price sits inside an overbought or oversold RSI zone and only flags the episode once that accumulated volume reaches a defined threshold, distinguishing zones with real participation from zones with weak, low-volume RSI extremes that are more likely to be ignored by price.

WHAT IT IS MADE OF

1. RSI Engine
   A standard RSI (configurable length and source) checked against two configurable levels: an overbought level (default 70) and an oversold level (default 30).

2. Volume Accumulator
   From the moment RSI enters an overbought or oversold zone, the indicator starts summing the volume of every bar for as long as RSI remains inside that zone. This running total resets to zero each time a new zone episode begins (i.e., each fresh entry into overbought or oversold after having been outside it).

3. Volume Threshold
   A simple moving average of volume (default length 20) multiplied by a user-defined factor (default 8) forms the validation threshold. This threshold is recalculated on every bar using current volume conditions.

4. Validation Logic
   The indicator continuously compares the accumulated zone volume against the threshold. The first bar where the accumulated volume reaches or exceeds the threshold — while RSI is still inside the zone — triggers the signal for that episode. Only one signal can fire per zone episode; once triggered, the indicator will not signal again until RSI exits the zone and re-enters it later.

WHAT IT SIGNALS AND HOW

- A green upward triangle below the bar marks a validated oversold episode (accumulated volume met the threshold while RSI was oversold).
- A red downward triangle above the bar marks a validated overbought episode (accumulated volume met the threshold while RSI was overbought).
- A label is plotted at the signal bar showing the exact accumulated volume figure for that episode, so the reader can see how much participation triggered the validation.
- RSI readings that reach overbought/oversold but never accumulate enough volume before exiting the zone produce no signal at all. These "weak" episodes are intentionally left unmarked.

HOW TO INTERPRET IT

A signal does not mean "buy here" or "sell here." It means: at this point, price has been overbought/oversold for long enough, with enough volume behind that condition, that the RSI extreme is more likely to carry real weight. Historically, this tends to coincide with one of three outcomes:

  - Price decelerates and reverses direction.
  - Price decelerates and consolidates/pauses before continuing.
  - Price continues in the same direction, but at a reduced pace.

The signal is a condition-strength marker, not a directional entry trigger.

HOW TO USE IT

Use this indicator as a filter or confirmation layer on top of your own analysis — for example, alongside support/resistance, structure, or other timing tools — to judge whether a given overbought/oversold reading is likely to matter. It is best suited as a heads-up that momentum may be about to change character, not as a standalone trigger for opening positions.

LIMITATIONS

- This indicator does NOT generate buy/sell entries. It only flags when a volume-validated overbought/oversold condition occurs. Any trading decision based on it requires additional confirmation and risk management from the user.
- It does not predict the magnitude or exact timing of a reversal or deceleration — only that the condition has met a volume-based validation threshold.
- The volume SMA and threshold factor are fully adjustable; results will vary significantly by asset, timeframe, and the chosen factor. Defaults shown here (SMA length 20, factor 8) were tuned through visual backtesting and may need re-calibration for other instruments or timeframes.
- On instruments or data feeds where volume data is unavailable or unreliable (e.g., some spot forex feeds), the volume accumulation and threshold comparison will not function as intended.
- This script does not repaint: each signal is generated and locked in on the bar where the volume threshold is met and does not change on historical bars after that point.

## Source Code

````pine
//@version=6
indicator("RSI Volume-Validated Overbought/Oversold", overlay = true, max_bars_back = 500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────

rsiLen      = input.int(14, "RSI Length", group = "RSI", minval = 1)
rsiSrc      = input.source(close, "RSI Source", group = "RSI")
obLevel     = input.float(70.0, "Overbought Level", group = "RSI", minval = 50, maxval = 99)
osLevel     = input.float(30.0, "Oversold Level",   group = "RSI", minval = 1,  maxval = 50)

volMaLen    = input.int(20, "Volume SMA Length", group = "Volume Validation", minval = 1)
volFactor   = input.float(8.0, "Volume Threshold Factor", group = "Volume Validation", minval = 0.1, step = 0.1)

showLabels  = input.bool(true, "Show Zone Labels", group = "Display")

// ─────────────────────────────────────────────
// RSI
// ─────────────────────────────────────────────

rsiVal = ta.rsi(rsiSrc, rsiLen)

inOB = rsiVal >= obLevel
inOS = rsiVal <= osLevel
inZone = inOB or inOS

// ─────────────────────────────────────────────
// VOLUME THRESHOLD
// ─────────────────────────────────────────────

volSma  = ta.sma(volume, volMaLen)
volThreshold = volSma * volFactor

// ─────────────────────────────────────────────
// ACCUMULATE VOLUME WHILE INSIDE ZONE
// ─────────────────────────────────────────────

var float cumVolOB = 0.0
var float cumVolOS = 0.0

wasOB = inOB[1]
wasOS = inOS[1]

// Reset accumulator on fresh entry into a zone
if inOB and not wasOB
    cumVolOB := 0.0
if inOS and not wasOS
    cumVolOS := 0.0

if inOB
    cumVolOB += volume
if inOS
    cumVolOS += volume

// ─────────────────────────────────────────────
// TRACK WHETHER THIS ZONE EPISODE ALREADY SIGNALED
// ─────────────────────────────────────────────

var bool obSignaled = false
var bool osSignaled = false

if inOB and not wasOB
    obSignaled := false
if inOS and not wasOS
    osSignaled := false

// ─────────────────────────────────────────────
// SIGNAL — fires the moment accumulated volume crosses the threshold,
// while still inside the zone (only once per episode)
// ─────────────────────────────────────────────

shortSignal = inOB and not obSignaled and cumVolOB >= volThreshold
longSignal  = inOS and not osSignaled and cumVolOS >= volThreshold

if shortSignal
    obSignaled := true
if longSignal
    osSignaled := true

plotshape(longSignal,  title = "Long Signal (Real Oversold)",   style = shape.triangleup,
     location = location.belowbar, color = color.green, size = size.small)
plotshape(shortSignal, title = "Short Signal (Real Overbought)", style = shape.triangledown,
     location = location.abovebar, color = color.red, size = size.small)

// ─────────────────────────────────────────────
// LABELS — show accumulated volume only when a signal fires
// ─────────────────────────────────────────────

if showLabels and shortSignal
    label.new(bar_index, high, text = "REAL OB\n" + str.tostring(cumVolOB, "#,###"),
         style = label.style_label_down, color = color.red,
         textcolor = color.white, size = size.small)

if showLabels and longSignal
    label.new(bar_index, low, text = "REAL OS\n" + str.tostring(cumVolOS, "#,###"),
         style = label.style_label_up, color = color.green,
         textcolor = color.white, size = size.small)
````
