<!-- tradingview-pine-id: PUB;37a061528d76407ca786dd4ee17519d2 -->
<!-- tradingviewscripts-format: 1 -->
# Bill Williams Awesome Oscillator Signals

Source: https://www.tradingview.com/script/Wak6GkO2-Bill-Williams-Awesome-Oscillator-Signals/

## Description

# Bill Williams Awesome Oscillator Signals

This indicator is based on the **Bill Williams Awesome Oscillator (AO)** and adds visual trading signals derived from the original AO methodology.

The Awesome Oscillator measures market momentum by comparing the short-term and long-term market balance using the difference between two simple moving averages:

* Fast SMA: 5 periods
* Slow SMA: 34 periods
* Source: HL2 (Median Price)

The histogram changes color depending on AO momentum:

* Rising AO — increasing bullish momentum
* Falling AO — decreasing bullish momentum

## Included AO Signals

### Saucer Signals

Classic Bill Williams AO Saucer patterns:

* **Bullish Saucer** — appears above the zero line when momentum changes from falling to rising
* **Bearish Saucer** — appears below the zero line when momentum changes from rising to falling

### Zero Line Cross Signals

Based on AO zero-line crossings:

* Bullish signal when AO crosses above zero
* Bearish signal when AO crosses below zero

This helps identify transitions between bullish and bearish momentum phases.

### 3-Bar AO Signals

Optional classic AO 3-bar momentum patterns:

* Bullish sequence after negative AO values
* Bearish sequence after positive AO values

### Twin Peaks / Twin Bottoms

Optional divergence-style signals based on AO extremes.

The indicator searches for two AO highs or lows on the same side of the zero line:

* **Bullish Twin Bottom** — second AO low forms higher than the previous low without crossing above zero
* **Bearish Twin Peak** — second AO high forms lower than the previous high without crossing below zero

This follows Bill Williams' Twin Peaks concept and focuses on momentum weakening before possible reversals.

## Visual Signals

Signals are displayed as square markers:

* Green squares — bullish AO conditions
* Red squares — bearish AO conditions

Marker placement adapts automatically to remain visible outside the histogram area.

## How to Use

The Awesome Oscillator is a momentum tool and works best when combined with:

* Market structure analysis
* Trend direction
* Support and resistance levels
* Volume analysis
* Other Bill Williams tools

AO signals should be used as confirmation of momentum changes, not as standalone entry signals.

## Settings

Users can enable or disable:

* AO histogram
* Zero line
* Saucer signals
* Zero-cross signals
* 3-bar signals
* Twin Peaks / Twin Bottom signals

Adjust marker distance and AO colors according to chart preferences.

---

Based on Bill Williams' Awesome Oscillator methodology.
Designed for traders who use momentum analysis and market psychology concepts.

---

## Source Code

````pine
// © OlekBard

//@version=6
indicator("Bill Williams Awesome Oscillator Signals", shorttitle="AO", overlay=false, max_labels_count=500)

//=========================
// USER INPUTS
//=========================
showHistogram        = input.bool(true, "Show AO Histogram")
showZeroLine         = input.bool(true, "Show Zero Line")
showSaucerSignals    = input.bool(true, "Show Saucer Signals")
showZeroCrossSignals = input.bool(true, "Show Zero Line Cross Signals")
showThreeBarSignals  = input.bool(false, "Show 3-Bar Signals")
showTwinPeaksSignals = input.bool(false, "Show Twin Peaks / Bottoms Signals")
markerOffsetFactor = input.float(0.15, "Marker Offset Factor", step=0.01, minval=0.0, maxval=0.5)

// AO Colors
aoRisingColor  = input.color(#009688, "AO Rising Color")
aoFallingColor = input.color(#F44336, "AO Falling Color")

// Marker Colors
greenAboveZero = input.color(#81c784, "Green Above Zero")
greenBelowZero = input.color(#81c784, "Green Below Zero")
redAboveZero   = input.color(#e57373, "Red Above Zero")
redBelowZero   = input.color(#e57373, "Red Below Zero")

// Minimal AO difference for twin peaks/bottoms
minAoDiff = input.float(0.0005, "Min AO Difference Between Extremes", step=0.0001)

//=========================
// AWESOME OSCILLATOR
//=========================
aoFast = ta.sma(hl2, 5)
aoSlow = ta.sma(hl2, 34)
ao     = aoFast - aoSlow

isGreen = ao > ao[1]
isRed   = ao < ao[1]

plotColor = ao >= ao[1] ? aoRisingColor : aoFallingColor

//=========================
// PLOT HISTOGRAM & ZERO
//=========================
plot(showHistogram ? ao : na, style=plot.style_histogram, color=plotColor, linewidth=2)
plot(showZeroLine ? 0 : na, color=color.gray, style=plot.style_line, linewidth=1)

//=========================
// SAUCER SIGNALS
//=========================
saucerBuy  = ao > 0 and isRed[2] and isRed[1] and isGreen
saucerSell = ao < 0 and isGreen[2] and isGreen[1] and isRed

buySaucerSignal  = showSaucerSignals and saucerBuy
sellSaucerSignal = showSaucerSignals and saucerSell

//=========================
// 3-BAR SIGNALS
//=========================
threeBuy  = ao < 0 and isRed[3] and isGreen[2] and isGreen[1] and isGreen
threeSell = ao > 0 and isGreen[3] and isRed[2] and isRed[1] and isRed

buyThreeSignal  = showThreeBarSignals and threeBuy
sellThreeSignal = showThreeBarSignals and threeSell

//=========================
// TWIN PEAKS / BOTTOMS LOGIC
//=========================
var float prevLowAO   = na
var float lastLowAO   = na
var int   prevLowBar  = na
var int   lastLowBar  = na
var bool  twinBottomFired = false

var float prevHighAO  = na
var float lastHighAO  = na
var int   prevHighBar = na
var int   lastHighBar = na
var bool  twinPeakFired = false

//=========================
// LOCAL EXTREMES (3-BAR PIVOTS)
//=========================
f_localLow(_ao) =>
    _ao[1] < _ao[0] and _ao[1] < _ao[2] ? _ao[1] : na

f_localHigh(_ao) =>
    _ao[1] > _ao[0] and _ao[1] > _ao[2] ? _ao[1] : na

lowPivot  = f_localLow(ao)
highPivot = f_localHigh(ao)

//=========================
// UPDATE EXTREMES
//=========================
if not na(lowPivot) and lowPivot < 0
    prevLowAO := lastLowAO
    prevLowBar := lastLowBar

    lastLowAO := lowPivot
    lastLowBar := bar_index - 1
    twinBottomFired := false

if not na(highPivot) and highPivot > 0
    prevHighAO := lastHighAO
    prevHighBar := lastHighBar

    lastHighAO := highPivot
    lastHighBar := bar_index - 1
    twinPeakFired := false

//=========================
// NO ZERO CROSS CHECK FOR TWIN PEAKS
//=========================
barsBetweenLows  = lastLowBar - prevLowBar
barsBetweenHighs = lastHighBar - prevHighBar

noZeroCrossLow = (
    not na(prevLowBar) and
    barsBetweenLows > 0 and
    ta.highest(ao, math.max(barsBetweenLows, 1)) < 0
)

noZeroCrossHigh = (
    not na(prevHighBar) and
    barsBetweenHighs > 0 and
    ta.lowest(ao, math.max(barsBetweenHighs, 1)) > 0
)
//=========================
// BULLISH TWIN BOTTOM SIGNAL
//=========================
buyTwinSignal = showTwinPeaksSignals and (
                    not na(prevLowAO) and
                    not na(lastLowAO) and
                    lastLowAO > prevLowAO + minAoDiff and
                    noZeroCrossLow and
                    not twinBottomFired and
                    isRed[2] and
                    isRed[1] and
                    isGreen and
                    bar_index == lastLowBar + 1
                )

if buyTwinSignal
    twinBottomFired := true

//=========================
// BEARISH TWIN PEAK SIGNAL
//=========================
sellTwinSignal = showTwinPeaksSignals and (
                     not na(prevHighAO) and
                     not na(lastHighAO) and
                     lastHighAO < prevHighAO - minAoDiff and
                     noZeroCrossHigh and
                     not twinPeakFired and
                     isGreen[2] and
                     isGreen[1] and
                     isRed and
                     bar_index == lastHighBar + 1
                 )

if sellTwinSignal
    twinPeakFired := true

//=========================
// ZERO LINE CROSS SIGNALS (Bill Williams)
//=========================
zeroCrossBuy  = showZeroCrossSignals and ao > 0 and ao[1] <= 0
zeroCrossSell = showZeroCrossSignals and ao < 0 and ao[1] >= 0

//=========================
// FINAL SIGNALS
//=========================
buySignal  = buyTwinSignal  ? 1 : buySaucerSignal ? 1 : buyThreeSignal ? 1 : zeroCrossBuy ? 1 : 0
sellSignal = sellTwinSignal ? 1 : sellSaucerSignal ? 1 : sellThreeSignal ? 1 : zeroCrossSell ? 1 : 0

finalBuy  = buySignal == 1 and sellSignal == 0
finalSell = sellSignal == 1 and buySignal == 0

//=========================
// OFFSET FOR MARKERS OUTSIDE HISTOGRAM
//=========================
offsetUp   = ta.highest(ao, 100) * markerOffsetFactor
offsetDown = ta.lowest(ao, 100) * markerOffsetFactor

//=========================
// PLOT MARKERS
//=========================
plotshape(finalBuy and ao < 0 ? ao + offsetDown : na, style=shape.square, location=location.absolute, color=greenBelowZero, size=size.auto)
plotshape(finalSell and ao > 0 ? ao + offsetUp   : na, style=shape.square, location=location.absolute, color=redAboveZero, size=size.auto)
plotshape(finalBuy and ao >= 0 ? ao + offsetUp   : na, style=shape.square, location=location.absolute, color=greenAboveZero, size=size.auto)
plotshape(finalSell and ao <= 0 ? ao + offsetDown : na, style=shape.square, location=location.absolute, color=redBelowZero, size=size.auto)
````
