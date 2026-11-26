# Simple RVOL + Normalized OBV + Volume MA

- url: https://www.tradingview.com/script/A2sDcsOn-Simple-RVOL-Normalized-OBV-Volume-MA/
- type: indicator
- pine_id: PUB;6c518e2a9119459e92fceadca6d80f29
- version: 1.0

## Description

Simple RVOL + Normalized OBV + Volume MA is a lower-pane volume analysis indicator designed to help traders evaluate relative volume expansion and directional volume pressure in one clean display.

The indicator combines several volume tools:

- Relative Volume histogram
- Normalized On Balance Volume line
- OBV moving average
- Volume moving average line
- RVOL reference level

The purpose is to make it easier to see when volume is unusually high compared with recent average volume, while also showing whether volume pressure is leaning bullish or bearish.

---
How It Works

The RVOL histogram measures current volume relative to average volume.

A reading around 1.0 means current volume is near normal.

A reading above 1.0 means current volume is above average.

A reading below 1.0 means current volume is below average.

Histogram bars are colored using OBV direction instead of candle color:

- Green means OBV is rising, suggesting bullish volume pressure
- Red means OBV is falling, suggesting bearish volume pressure
- Gray means OBV is unchanged

The indicator also plots a normalized OBV line and an OBV average line. Since raw OBV values can be very large, OBV is scaled so it can be viewed clearly in the same pane as RVOL.

A volume moving average line is included to show whether recent volume is generally expanding or contracting.

---

RVOL Modes

The script includes two RVOL calculation modes.

Simple RVOL

Simple RVOL calculates current volume divided by a moving average of volume.

This mode is clean, simple, and works well on both daily and intraday charts.

Time-of-Day Approximation

This mode is intended for intraday charts, such as 5-minute charts.

To keep the script lightweight and easy to understand, it uses a simplified rolling-volume approximation rather than a true same-time-of-day comparison.

It does not compare the current 5-minute candle directly against the exact same 5-minute time slot from prior sessions.

---

Inputs

The indicator includes editable settings for:

- RVOL mode
- Simple RVOL average length
- Time-of-day approximation lookback
- Volume moving average length
- Show or hide volume moving average
- OBV smoothing length
- Show or hide OBV line
- Show or hide OBV average line
- Bullish, bearish, and neutral histogram colors
- RVOL reference level

---

Best Used For

This indicator can be useful for:

- Identifying unusually high or low volume
- Spotting volume expansion during breakouts or reversals
- Comparing current volume to recent average volume
- Evaluating whether volume pressure is bullish or bearish
- Adding context to intraday and daily trade setups

---

Notes and Limitations

The time-of-day RVOL mode is a simplified approximation. A true same-time-of-day RVOL model requires more complex session tracking and historical time-slot calculations.

This indicator is intended as a lightweight visual tool for volume context and should not be used as a standalone buy or sell signal.

## Source Code

````pine
//@version=6
indicator("Simple RVOL + Normalized OBV + Volume MA", shorttitle="RVOL + OBV + Vol MA", overlay=false)

//────────────────────────────────────
// Inputs
//────────────────────────────────────
rvolMode = input.string(
     "Simple RVOL",
     title="RVOL Mode",
     options=["Simple RVOL", "Time-of-day approximation"]
)

simpleLen = input.int(
     20,
     title="Simple RVOL Average Length",
     minval=1
)

todLookbackDays = input.int(
     10,
     title="Time-of-day Approximation Lookback Days",
     minval=1
)

volMaLen = input.int(
     20,
     title="Volume Moving Average Length",
     minval=1
)

showVolMa = input.bool(
     true,
     title="Show Volume Moving Average Line"
)

obvMaLen = input.int(
     20,
     title="OBV Smoothing Length",
     minval=1
)

showObv = input.bool(
     true,
     title="Show OBV Line"
)

showObvMa = input.bool(
     true,
     title="Show OBV Average Line"
)

bullColor = input.color(
     color.lime,
     title="Bullish Volume-Pressure Color"
)

bearColor = input.color(
     color.red,
     title="Bearish Volume-Pressure Color"
)

neutralColor = input.color(
     color.gray,
     title="Neutral Volume-Pressure Color"
)

rvolRef = input.float(
     1.0,
     title="RVOL Reference Level",
     minval=0.1,
     step=0.1
)

//────────────────────────────────────
// Relative Volume
//────────────────────────────────────

// Simple RVOL:
// RVOL = Volume / SMA(Volume, Length)
simpleAvgVol = ta.sma(volume, simpleLen)
simpleRvol = simpleAvgVol != 0 ? volume / simpleAvgVol : na

// Time-of-day approximation:
// This is intentionally simple.
// It does NOT compare the current bar with the exact same time slot
// from prior sessions. Instead, on intraday charts it estimates a
// rolling average using roughly N trading days of intraday bars.
secondsPerBar = timeframe.in_seconds(timeframe.period)
regularSessionSeconds = 6.5 * 60 * 60

barsPerDay = timeframe.isintraday and secondsPerBar > 0 ? regularSessionSeconds / secondsPerBar : simpleLen
todLen = timeframe.isintraday ? math.max(1, math.round(todLookbackDays * barsPerDay)) : simpleLen

todAvgVol = ta.sma(volume, todLen)
todRvol = todAvgVol != 0 ? volume / todAvgVol : na

// Select RVOL mode.
// On daily charts, the time-of-day approximation gracefully falls back
// to a simple rolling average style calculation.
rvol = rvolMode == "Simple RVOL" ? simpleRvol : todRvol

//────────────────────────────────────
// Volume Moving Average line
//────────────────────────────────────

// The raw volume MA is converted into RVOL-style scale by dividing
// the volume MA by the same average volume used in the selected RVOL mode.
// This keeps the line readable in the same pane as RVOL.
volMaRaw = ta.sma(volume, volMaLen)

selectedAvgVol = rvolMode == "Simple RVOL" ? simpleAvgVol : todAvgVol
volMaScaled = selectedAvgVol != 0 ? volMaRaw / selectedAvgVol : na

//────────────────────────────────────
// OBV calculation
//────────────────────────────────────

// Standard OBV:
// Add volume when close rises, subtract volume when close falls.
priceChange = ta.change(close)

obvStep = priceChange > 0 ? volume : priceChange < 0 ? -volume : 0
obv = ta.cum(obvStep)

obvMa = ta.sma(obv, obvMaLen)

//────────────────────────────────────
// Normalize OBV for shared display
//────────────────────────────────────

// Raw OBV values can be very large compared with RVOL.
// This normalizes OBV around the RVOL reference level so it can be
// viewed in the same lower pane as the RVOL histogram.
obvNormLen = math.max(obvMaLen * 3, 20)
obvMean = ta.sma(obv, obvNormLen)
obvStdev = ta.stdev(obv, obvNormLen)

obvScale = 0.25

obvNorm = obvStdev != 0 ? rvolRef + ((obv - obvMean) / obvStdev) * obvScale : rvolRef
obvMaNorm = obvStdev != 0 ? rvolRef + ((obvMa - obvMean) / obvStdev) * obvScale : rvolRef

//────────────────────────────────────
// Volume-pressure coloring
//────────────────────────────────────

// Color RVOL bars by OBV direction, not candle color.
obvRising = obv > obv[1]
obvFalling = obv < obv[1]

barColor = obvRising ? bullColor : obvFalling ? bearColor : neutralColor

//────────────────────────────────────
// Plots
//────────────────────────────────────

plot(
     rvol,
     title="RVOL Histogram",
     style=plot.style_columns,
     color=barColor
)

plot(
     showVolMa ? volMaScaled : na,
     title="Volume MA, RVOL-Scaled",
     color=color.aqua,
     linewidth=2
)

plot(
     showObv ? obvNorm : na,
     title="Normalized OBV",
     color=color.white,
     linewidth=2
)

plot(
     showObvMa ? obvMaNorm : na,
     title="Normalized OBV Average",
     color=color.orange,
     linewidth=2
)

hline(
     rvolRef,
     title="RVOL Reference Level",
     color=color.new(color.white, 40),
     linestyle=hline.style_dashed
)
````
