# Top & Bottom Finder XL

- url: https://www.tradingview.com/script/k4IbCD67-Top-Bottom-Finder-XL/
- type: indicator
- pine_id: PUB;2b36a50ad5e54f7cac579f791f65ca7f
- version: 3.0

## Description

# Top & Bottom Finder XL

## User's Guide

---

# Overview

**Top & Bottom Finder XL** is a market exhaustion indicator.

Its purpose is **not** to predict every swing high and swing low.

Instead, it attempts to identify **high-probability exhaustion points** where price has become statistically extended and has a greater chance of reversing.

Unlike traditional pivot indicators, this indicator combines several independent filters:

* Structural pivots
* Momentum (RSI)
* Trend extension
* Volume
* Range expansion

Only when the selected filters agree does the indicator produce a **Confirmed Top** or **Confirmed Bottom**.

---

# How the Indicator Works

Every signal goes through the following process:

### Step 1 — Find a Pivot

The indicator first looks for a legitimate swing high or swing low using TradingView's pivot algorithm.

A pivot is not confirmed until the required number of right bars has completed.

Example:

Left = 100

Right = 5

means:

* current high must be higher than the previous 100 bars
* and remain the highest point for the next 5 bars

Only then is it officially a pivot.

---

### Step 2 — Apply RSI Filter (Optional)

Purpose:

Avoid taking pivots that occur without momentum extremes.

A top requires

RSI ≥ Top Threshold

A bottom requires

RSI ≤ Bottom Threshold

Default:

Top = 65

Bottom = 35

Disabling this filter means RSI is ignored completely.

---

### Step 3 — Apply Trend Extension Filter (Optional)

Purpose:

Avoid taking pivots that are too close to the trend.

The indicator measures:

Distance from EMA

using ATR.

Formula:

Distance =

Price − EMA

divided by ATR

Example

EMA = 100

ATR = 2

Price = 110

Distance =

10 ÷ 2

= 5 ATR

If Minimum ATR Extension = 5

the signal passes.

Otherwise it is rejected.

This filter is extremely effective at removing mediocre signals.

---

### Step 4 — Confirmation Filter

This determines whether the pivot occurred with unusually strong participation.

There are four modes.

## Off

No confirmation required.

Every pivot that passes the other filters becomes confirmed.

Produces the most signals.

---

## Volume Only

The pivot bar must have

Volume >

Average Volume × Multiplier

Default

50-bar average

Multiplier = 2

---

## Range Only

The pivot candle must have

Range >

Average Range × Multiplier

This looks for unusually large candles.

---

## Volume + Range

The strictest mode.

Requires BOTH:

* high volume
* large candle

Produces the fewest signals.

Usually the highest quality.

---

# Timeframe Settings

## Calculation Timeframe

Allows calculations on another timeframe.

Example

Chart = 15 minute

Calculation = 1 hour

Signals are calculated from hourly data but displayed on the 15-minute chart.

Leave blank to use the current chart timeframe.

---

# Pivot Settings

## Pivot Bars Left

Controls how significant the pivot must be.

Small values

More signals

Less significant

Large values

Fewer signals

More important turning points

Default

100

---

## Pivot Bars Right

Controls confirmation delay.

Larger values

Later signals

Higher confidence

Smaller values

Earlier signals

More false signals

Default

5

---

# Signal Filters

## Use RSI Filter

Enable or disable RSI completely.

---

## RSI Length

Default

14

Controls how RSI is calculated.

---

## Top RSI Threshold

Minimum RSI required for tops.

Default

65

Higher values

Fewer signals

---

## Bottom RSI Threshold

Maximum RSI allowed for bottoms.

Default

35

Lower values

Fewer signals

---

## Use Trend EMA Filter

Turns EMA distance filtering on or off.

---

## Trend EMA Length

Default

200

Long-term trend reference.

---

## ATR Length

Default

14

Used to normalize volatility.

---

## Minimum ATR Extension

Default

5 ATR

Controls how far price must stretch away from the EMA.

Higher values

Only extreme exhaustion

Lower values

More frequent signals

---

## Confirmation Mode

Options:

* Off
* Volume Only
* Range Only
* Volume + Range

Determines final confirmation.

---

## Volume / Range Average Length

Default

50

Average period used for volume and range comparisons.

---

## Volume Multiplier

Default

2

Required increase above average volume.

Example

Average volume = 100,000

Multiplier = 2

Required volume

200,000

---

## Range Expansion Multiplier

Default

0.5

Required increase above average candle range.

Higher values

Require larger candles.

---

# Display Settings

## Show Trend EMA

Displays the EMA used for trend extension.

Useful for visualizing how stretched price became.

---

## Show Watch Signals

Displays every confirmed pivot before filtering.

Watch signals represent:

"Potential reversal areas."

Confirmed signals represent:

"Filtered, higher-probability reversal areas."

---

## Color Settings

Customize:

* Watch Tops
* Watch Bottoms
* Confirmed Tops
* Confirmed Bottoms
* EMA

---

# Label Controls

These options determine what information appears inside Confirmed labels.

---

## Show Price

Displays pivot price.

Example

Price

145.32

---

## Show Pivot Settings

Displays

Left / Right

Example

100 / 5

Useful when comparing settings.

---

## Show RSI

Displays RSI at the pivot.

Example

RSI

72.5

---

## Show Volume

Displays pivot volume.

Useful when Volume confirmation is enabled.

---

## Show ATR

Displays ATR at the pivot.

Important:

This is **not** the distance from the EMA.

It simply displays the market's volatility (ATR) at the time the pivot formed.

Higher ATR means a more volatile market.

Lower ATR means a quieter market.

---

## Show EMA Distance

Displays

Distance from EMA

measured in ATRs.

Example

EMA Dist

5.82 ATR

This is arguably the most useful statistic on the label because it quantifies how extended price was when the reversal occurred.

---

## Show Confirmation Type

Displays how the confirmation filter was satisfied.

Possible values:

* Volume
* Range
* Volume + Range
* None

---

# Alerts

The indicator includes four alerts:

### Confirmed Top Found

Generated when a filtered top is confirmed.

---

### Confirmed Bottom Found

Generated when a filtered bottom is confirmed.

---

### Top Watch

Generated for every structural pivot high before filtering.

---

### Bottom Watch

Generated for every structural pivot low before filtering.

---

# Understanding Signal Timing

This is important.

The indicator **does not repaint**, but it is intentionally delayed by the **Pivot Bars Right** setting.

Example:

Right Bars = 5

A top occurring today will only be confirmed after five additional bars have closed without a higher high.

This is necessary because the indicator waits for confirmation that the pivot is truly established.

---

# Suggested Starting Settings

## Swing Trading (Daily)

* Left Bars: 100
* Right Bars: 5
* RSI: On
* EMA Filter: On
* Minimum ATR Extension: 5
* Confirmation: Volume Only

---

## Position Trading (Weekly)

* Left Bars: 150–250
* Right Bars: 5–10
* ATR Extension: 6–8
* Confirmation: Volume + Range

---

## Short-Term Trading (15–60 Minute)

* Left Bars: 30–60
* Right Bars: 3–5
* ATR Extension: 3–4
* Confirmation: Volume Only

---

# Strengths

* Adapts to market volatility using ATR.
* Filters out many insignificant pivots.
* Uses multiple independent confirmation methods.
* Supports higher-timeframe calculations on lower-timeframe charts.
* Does not repaint after pivot confirmation.
* Highly configurable for different trading styles.

---

# Current Limitations

* Signals are intentionally delayed by the selected Right Bars value.
* The indicator identifies **exhaustion points**, not trend direction.
* Strong trends can continue after a confirmed top or bottom, especially during momentum-driven markets.
* Volume confirmation may be less reliable for markets where reported volume is limited or synthetic (such as many forex CFDs).

---

# Best Use Practices

The indicator performs best when used to identify **areas of elevated reversal probability**, not as a standalone buy or sell trigger. Higher-quality setups occur when a confirmed signal aligns with higher-timeframe support or resistance, trendline breaks, divergence, or other independent forms of technical confirmation. Treat confirmed tops and bottoms as locations to focus attention rather than automatic entry points.

## Source Code

````pine
//@version=6
indicator("Top & Bottom Finder XL", shorttitle="Top & Bottom XL", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Input Groups
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupTimeframe = "Timeframe Settings"
groupPivot = "Pivot Settings"
groupFilters = "Signal Filters"
groupGrading = "Signal Grading"
groupDisplay = "Display Settings"
groupLabels = "Label Controls"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Timeframe Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

calcTimeframeInput = input.timeframe("", "Calculation Timeframe", group=groupTimeframe, tooltip="Select the timeframe used for the indicator calculations. Leave blank to use the chart timeframe.")
calcTimeframe = calcTimeframeInput == "" ? timeframe.period : calcTimeframeInput

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pivot Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

leftBars = input.int(100, "Pivot Bars Left", minval=5, maxval=500, step=1, group=groupPivot, tooltip="Number of bars to the left used to qualify a major pivot. Higher values detect larger market swings.")
rightBars = input.int(5, "Pivot Bars Right", minval=1, maxval=50, step=1, group=groupPivot, tooltip="Number of bars to the right required to confirm the pivot. This creates the signal delay.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Filters
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

useTrendEmaFilter = input.bool(true, "Use Trend EMA Filter", group=groupFilters, tooltip="When enabled, pivots must be extended away from the Trend EMA by the required ATR multiple.")
emaLen = input.int(200, "Trend EMA Length", minval=20, maxval=500, group=groupFilters, tooltip="Long-term EMA used as the reference line for measuring price extension.")
atrLen = input.int(14, "ATR Length", minval=2, maxval=100, group=groupFilters, tooltip="ATR lookback used to measure volatility-adjusted price extension.")
atrMult = input.float(5, "Minimum ATR Extension", minval=1, maxval=50, step=0.5, group=groupFilters, tooltip="Pivot must be extended from the EMA by at least this ATR multiple.")

confirmMode = input.string("Volume Only", "Confirmation Mode", options=["Volume + Range", "Volume Only", "Range Only", "Off"], group=groupFilters, tooltip="Hard gate. A pivot must Pass this check or no signal is generated, regardless of RSI grade. Volume + Range requires both. Off disables the gate.")
volLen = input.int(50, "Volume / Range Average Length", minval=5, maxval=200, group=groupFilters, tooltip="Average length used for volume and candle range confirmation.")
volMult = input.float(2, "Volume Multiplier", minval=1, maxval=50, step=0.5, group=groupFilters, tooltip="Pivot-bar volume must exceed average volume multiplied by this value to Pass.")
rangeMult = input.float(1, "Range Expansion Multiplier", minval=0.1, maxval=5, step=0.1, group=groupFilters, tooltip="Pivot-bar candle range must exceed average range multiplied by this value to Pass.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Grading (RSI Tiers)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rsiLen = input.int(14, "RSI Length", minval=2, maxval=100, group=groupGrading, tooltip="RSI lookback used to grade tops and bottoms.")

topWeakRsi = input.float(60, "Weak Top RSI", minval=50, maxval=100, step=1, group=groupGrading, tooltip="Minimum RSI at the pivot high for a Weak Top. Below this level no top signal is generated. Keep Weak < Strong < Extreme.")
topStrongRsi = input.float(70, "Strong Top RSI", minval=50, maxval=100, step=1, group=groupGrading, tooltip="Minimum RSI at the pivot high for a Strong Top.")
topExtremeRsi = input.float(80, "Extreme Top RSI", minval=50, maxval=100, step=1, group=groupGrading, tooltip="Minimum RSI at the pivot high for an Extreme Top.")

bottomWeakRsi = input.float(40, "Weak Bottom RSI", minval=0, maxval=50, step=1, group=groupGrading, tooltip="Maximum RSI at the pivot low for a Weak Bottom. Above this level no bottom signal is generated. Keep Weak > Strong > Extreme.")
bottomStrongRsi = input.float(30, "Strong Bottom RSI", minval=0, maxval=50, step=1, group=groupGrading, tooltip="Maximum RSI at the pivot low for a Strong Bottom.")
bottomExtremeRsi = input.float(20, "Extreme Bottom RSI", minval=0, maxval=50, step=1, group=groupGrading, tooltip="Maximum RSI at the pivot low for an Extreme Bottom.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Display Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showEma = input.bool(false, "Show Trend EMA", group=groupDisplay, tooltip="Displays the trend EMA on the chart.")
showWatchSignals = input.bool(false, "Show Watch Signals", group=groupDisplay, tooltip="Shows confirmed pivot highs and pivot lows before filters and grading are applied.")

topWatchColor = input.color(color.orange, "Top Watch Color", group=groupDisplay)
bottomWatchColor = input.color(color.aqua, "Bottom Watch Color", group=groupDisplay)

topWeakColor = input.color(color.orange, "Weak Top Color", group=groupDisplay)
topStrongColor = input.color(color.red, "Strong Top Color", group=groupDisplay)
topExtremeColor = input.color(color.maroon, "Extreme Top Color", group=groupDisplay)

bottomWeakColor = input.color(color.aqua, "Weak Bottom Color", group=groupDisplay)
bottomStrongColor = input.color(color.lime, "Strong Bottom Color", group=groupDisplay)
bottomExtremeColor = input.color(color.teal, "Extreme Bottom Color", group=groupDisplay)

emaColor = input.color(color.gray, "EMA Color", group=groupDisplay)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Label Controls
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showLabels = input.bool(true, "Show Top/Bottom Labels", group=groupLabels, tooltip="Displays detailed text labels on graded tops and bottoms.")
labelSizeInput = input.string("Tiny", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupLabels, tooltip="Controls the size of the detailed top and bottom labels.")

showLabelTimeframe = input.bool(true, "Show Timeframe", group=groupLabels, tooltip="Adds the calculation timeframe used to generate the signal.")
showLabelPrice = input.bool(true, "Show Price", group=groupLabels, tooltip="Adds pivot price to the label text.")
showLabelPivotSettings = input.bool(false, "Show Pivot Settings", group=groupLabels, tooltip="Adds pivot settings to the label as Left/Right, for example 100/5.")
showLabelRsi = input.bool(true, "Show RSI", group=groupLabels, tooltip="Adds RSI value to the label text.")
showLabelVolume = input.bool(false, "Show Volume", group=groupLabels, tooltip="Adds pivot-bar volume to the label text.")
showLabelAtr = input.bool(false, "Show ATR", group=groupLabels, tooltip="Adds pivot-bar ATR value to the label text.")
showLabelDistance = input.bool(false, "Show EMA Distance", group=groupLabels, tooltip="Adds distance from EMA in ATR multiples to the label text.")
showLabelConfirm = input.bool(true, "Show Confirmation Detail", group=groupLabels, tooltip="Adds what the pivot bar passed confirmation by (volume, range, or both). Shows Off when Confirmation Mode is disabled.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Label Size Conversion
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

labelSize = switch labelSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    "Huge" => size.huge
    => size.small

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Function
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

calcSignals() =>
    _rsi = ta.rsi(close, rsiLen)
    _ema = ta.ema(close, emaLen)
    _atr = ta.atr(atrLen)
    _volAvg = ta.sma(volume, volLen)
    _range = high - low
    _rangeAvg = ta.sma(_range, volLen)

    _pivotHigh = ta.pivothigh(high, leftBars, rightBars)
    _pivotLow = ta.pivotlow(low, leftBars, rightBars)

    _pivotHighConfirmed = not na(_pivotHigh)
    _pivotLowConfirmed = not na(_pivotLow)

    _pivotHighRsi = _rsi[rightBars]
    _pivotLowRsi = _rsi[rightBars]

    _pivotHighEma = _ema[rightBars]
    _pivotLowEma = _ema[rightBars]

    _pivotHighAtr = _atr[rightBars]
    _pivotLowAtr = _atr[rightBars]

    _pivotHighVol = volume[rightBars]
    _pivotLowVol = volume[rightBars]

    _pivotHighVolAvg = _volAvg[rightBars]
    _pivotLowVolAvg = _volAvg[rightBars]

    _pivotHighRange = _range[rightBars]
    _pivotLowRange = _range[rightBars]

    _pivotHighRangeAvg = _rangeAvg[rightBars]
    _pivotLowRangeAvg = _rangeAvg[rightBars]

    // ── RSI tier: 3 = Extreme, 2 = Strong, 1 = Weak, 0 = no signal
    _topRsiTier = _pivotHighRsi >= topExtremeRsi ? 3 : _pivotHighRsi >= topStrongRsi ? 2 : _pivotHighRsi >= topWeakRsi ? 1 : 0
    _bottomRsiTier = _pivotLowRsi <= bottomExtremeRsi ? 3 : _pivotLowRsi <= bottomStrongRsi ? 2 : _pivotLowRsi <= bottomWeakRsi ? 1 : 0

    // ── Trend EMA extension gate
    _topExtensionPass = not useTrendEmaFilter or _pivotHigh > _pivotHighEma + _pivotHighAtr * atrMult
    _bottomExtensionPass = not useTrendEmaFilter or _pivotLow < _pivotLowEma - _pivotLowAtr * atrMult

    // ── Confirmation Pass/Fail
    _topVolumePass = not na(_pivotHighVolAvg) and _pivotHighVolAvg > 0 ? _pivotHighVol >= _pivotHighVolAvg * volMult : false
    _bottomVolumePass = not na(_pivotLowVolAvg) and _pivotLowVolAvg > 0 ? _pivotLowVol >= _pivotLowVolAvg * volMult : false

    _topRangePass = not na(_pivotHighRangeAvg) and _pivotHighRangeAvg > 0 ? _pivotHighRange >= _pivotHighRangeAvg * rangeMult : false
    _bottomRangePass = not na(_pivotLowRangeAvg) and _pivotLowRangeAvg > 0 ? _pivotLowRange >= _pivotLowRangeAvg * rangeMult : false

    _topConfirmPass = confirmMode == "Off" ? true : confirmMode == "Volume Only" ? _topVolumePass : confirmMode == "Range Only" ? _topRangePass : _topVolumePass and _topRangePass
    _bottomConfirmPass = confirmMode == "Off" ? true : confirmMode == "Volume Only" ? _bottomVolumePass : confirmMode == "Range Only" ? _bottomRangePass : _bottomVolumePass and _bottomRangePass

    _topPassDetail = _topVolumePass and _topRangePass ? "Volume + Range" : _topVolumePass ? "Volume" : _topRangePass ? "Range" : "None"
    _bottomPassDetail = _bottomVolumePass and _bottomRangePass ? "Volume + Range" : _bottomVolumePass ? "Volume" : _bottomRangePass ? "Range" : "None"

    _topConfirmText = confirmMode == "Off" ? "Off" : (_topConfirmPass ? "Pass" : "Fail") + " (" + _topPassDetail + ")"
    _bottomConfirmText = confirmMode == "Off" ? "Off" : (_bottomConfirmPass ? "Pass" : "Fail") + " (" + _bottomPassDetail + ")"

    // ── Grade comes from RSI alone. Confirmation Mode is a hard gate:
    //    Fail = no signal, regardless of RSI tier. "Off" disables the gate.
    _topTier = _topRsiTier
    _bottomTier = _bottomRsiTier

    _majorTop = _pivotHighConfirmed and _topExtensionPass and _topConfirmPass and _topTier >= 1
    _majorBottom = _pivotLowConfirmed and _bottomExtensionPass and _bottomConfirmPass and _bottomTier >= 1

    _watchTop = showWatchSignals and _pivotHighConfirmed
    _watchBottom = showWatchSignals and _pivotLowConfirmed

    _topDistanceAtr = _pivotHighAtr != 0 ? (_pivotHigh - _pivotHighEma) / _pivotHighAtr : na
    _bottomDistanceAtr = _pivotLowAtr != 0 ? (_pivotLowEma - _pivotLow) / _pivotLowAtr : na

    _topPivotTime = time[rightBars]
    _bottomPivotTime = time[rightBars]

    [_ema, _majorTop, _majorBottom, _watchTop, _watchBottom, _pivotHigh, _pivotLow, _pivotHighRsi, _pivotLowRsi, _pivotHighAtr, _pivotLowAtr, _pivotHighVol, _pivotLowVol, _topDistanceAtr, _bottomDistanceAtr, _topConfirmText, _bottomConfirmText, _topPivotTime, _bottomPivotTime, _topTier, _bottomTier]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Timeframe Calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[ema, majorTop, majorBottom, watchTop, watchBottom, pivotHigh, pivotLow, pivotHighRsi, pivotLowRsi, pivotHighAtr, pivotLowAtr, pivotHighVol, pivotLowVol, topDistanceAtr, bottomDistanceAtr, topConfirmText, bottomConfirmText, topPivotTime, bottomPivotTime, topTier, bottomTier] = request.security(syminfo.tickerid, calcTimeframe, calcSignals(), barmerge.gaps_off, barmerge.lookahead_off)

newMajorTop = majorTop and not majorTop[1]
newMajorBottom = majorBottom and not majorBottom[1]
newWatchTop = watchTop and not watchTop[1]
newWatchBottom = watchBottom and not watchBottom[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Grade Text & Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gradeName(int _tier) =>
    _tier >= 3 ? "Extreme" : _tier == 2 ? "Strong" : "Weak"

topLabelColor = topTier >= 3 ? topExtremeColor : topTier == 2 ? topStrongColor : topWeakColor
bottomLabelColor = bottomTier >= 3 ? bottomExtremeColor : bottomTier == 2 ? bottomStrongColor : bottomWeakColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Label Text
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotSettingsText = str.tostring(leftBars) + "/" + str.tostring(rightBars)

timeframeText =
     calcTimeframeInput == "" ? "Chart"   :
     calcTimeframe == "1"   ? "1 min"     :
     calcTimeframe == "3"   ? "3 min"     :
     calcTimeframe == "5"   ? "5 min"     :
     calcTimeframe == "10"  ? "10 min"    :
     calcTimeframe == "15"  ? "15 min"    :
     calcTimeframe == "30"  ? "30 min"    :
     calcTimeframe == "45"  ? "45 min"    :
     calcTimeframe == "60"  ? "1 hr"      :
     calcTimeframe == "120" ? "2 hr"      :
     calcTimeframe == "180" ? "3 hr"      :
     calcTimeframe == "240" ? "4 hr"      :
     calcTimeframe == "D"   ? "Daily"     :
     calcTimeframe == "W"   ? "Weekly"    :
     calcTimeframe == "M"   ? "Monthly"   :
     calcTimeframe

topLabelText = gradeName(topTier) + " Top"
topLabelText += showLabelTimeframe ? "\nTF: " + timeframeText : ""
topLabelText += showLabelPrice ? "\nPrice: " + str.tostring(pivotHigh, format.mintick) : ""
topLabelText += showLabelPivotSettings ? "\nPivot: " + pivotSettingsText : ""
topLabelText += showLabelRsi ? "\nRSI: " + str.tostring(pivotHighRsi, "#.0") : ""
topLabelText += showLabelVolume ? "\nVol: " + str.tostring(pivotHighVol, format.volume) : ""
topLabelText += showLabelAtr ? "\nATR: " + str.tostring(pivotHighAtr, format.mintick) : ""
topLabelText += showLabelDistance ? "\nEMA Dist: " + str.tostring(topDistanceAtr, "#.00") + " ATR" : ""
topLabelText += showLabelConfirm ? "\nConfirm: " + topConfirmText : ""

bottomLabelText = gradeName(bottomTier) + " Bottom"
bottomLabelText += showLabelTimeframe ? "\nTF: " + timeframeText : ""
bottomLabelText += showLabelPrice ? "\nPrice: " + str.tostring(pivotLow, format.mintick) : ""
bottomLabelText += showLabelPivotSettings ? "\nPivot: " + pivotSettingsText : ""
bottomLabelText += showLabelRsi ? "\nRSI: " + str.tostring(pivotLowRsi, "#.0") : ""
bottomLabelText += showLabelVolume ? "\nVol: " + str.tostring(pivotLowVol, format.volume) : ""
bottomLabelText += showLabelAtr ? "\nATR: " + str.tostring(pivotLowAtr, format.mintick) : ""
bottomLabelText += showLabelDistance ? "\nEMA Dist: " + str.tostring(bottomDistanceAtr, "#.00") + " ATR" : ""
bottomLabelText += showLabelConfirm ? "\nConfirm: " + bottomConfirmText : ""

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plotting
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(showEma ? ema : na, "Trend EMA", color=color.new(emaColor, 0), linewidth=2)

if showWatchSignals and newWatchTop and not newMajorTop
    label.new(topPivotTime, pivotHigh, "Watch Top", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(topWatchColor, 0), textcolor=color.white, size=size.tiny)

if showWatchSignals and newWatchBottom and not newMajorBottom
    label.new(bottomPivotTime, pivotLow, "Watch Bottom", xloc=xloc.bar_time, style=label.style_label_up, color=color.new(bottomWatchColor, 0), textcolor=color.black, size=size.tiny)

if showLabels and newMajorTop
    label.new(topPivotTime, pivotHigh, topLabelText, xloc=xloc.bar_time, style=label.style_label_down, color=color.new(topLabelColor, 0), textcolor=color.white, size=labelSize)

if showLabels and newMajorBottom
    label.new(bottomPivotTime, pivotLow, bottomLabelText, xloc=xloc.bar_time, style=label.style_label_up, color=color.new(bottomLabelColor, 0), textcolor=color.black, size=labelSize)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(newMajorTop, title="Any Top Found", message="Top & Bottom Finder: Market top detected.")
alertcondition(newMajorBottom, title="Any Bottom Found", message="Top & Bottom Finder: Market bottom detected.")

alertcondition(newMajorTop and topTier == 1, title="Weak Top Found", message="Top & Bottom Finder: Weak Top detected.")
alertcondition(newMajorTop and topTier == 2, title="Strong Top Found", message="Top & Bottom Finder: Strong Top detected.")
alertcondition(newMajorTop and topTier >= 3, title="Extreme Top Found", message="Top & Bottom Finder: Extreme Top detected.")

alertcondition(newMajorBottom and bottomTier == 1, title="Weak Bottom Found", message="Top & Bottom Finder: Weak Bottom detected.")
alertcondition(newMajorBottom and bottomTier == 2, title="Strong Bottom Found", message="Top & Bottom Finder: Strong Bottom detected.")
alertcondition(newMajorBottom and bottomTier >= 3, title="Extreme Bottom Found", message="Top & Bottom Finder: Extreme Bottom detected.")

alertcondition(newWatchTop, title="Top Watch", message="Top & Bottom Finder: Confirmed pivot high.")
alertcondition(newWatchBottom, title="Bottom Watch", message="Top & Bottom Finder: Confirmed pivot low.")
````
