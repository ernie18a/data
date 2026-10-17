# Pullback Marker (Inside Bars Ignored) by Shadow Quant Trader

- url: https://www.tradingview.com/script/BqTdzk6y-Pullback-Marker-Inside-Bars-Ignored-by-Shadow-Quant-Trader/
- type: indicator
- pine_id: PUB;b3c48d061c2f481c82c91d9e16ec06aa
- version: 1.0

## Description

Pullback Marker (Inside Bars Ignored)

This indicator is designed to identify pullback highs and pullback lows while completely ignoring inside bars.

How it works:

Every inside bar is skipped from the counting logic.
If multiple candles remain inside the range of the mother candle, all of them are ignored until a real breakout candle appears.
The indicator then evaluates only the real candles, not the inside bars.
Pullback high logic:

A pullback high is marked when the middle real candle forms the highest high compared to the candles before and after it.
If the next candle has the same high, the indicator waits.
If a later real candle then forms a lower high, the first candle of that equal-high sequence is marked as the pullback high.
Pullback low logic:

A pullback low is marked when the middle real candle forms the lowest low compared to the candles before and after it.
If the next candle has the same low, the indicator waits.
If a later real candle then forms a higher low, the first candle of that equal-low sequence is marked as the pullback low.
Features:

Ignores all inside bars in a mother-candle chain
Marks only valid pullback highs and lows
Handles equal-high and equal-low cases correctly
Uses arrows placed close to candles for clear chart reading

## Source Code

````pine
//@version=5
indicator("Pullback Marker (Inside Bars Ignored)", overlay=true, max_labels_count=500)

markerColor = input.color(color.black, "Marker Color")
markerSizeInput = input.string("Small", "Marker Size", options=["Tiny", "Small", "Normal", "Large"])
showHighPullbacks = input.bool(true, "Mark High Pullbacks")
showLowPullbacks = input.bool(true, "Mark Low Pullbacks")
offsetTicks = input.int(4, "Arrow Distance (Ticks)", minval=1)

markerSize = switch markerSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    => size.large

var bool motherInitialized = false
var float motherHigh = na
var float motherLow = na

var bool hasLastReal = false
var int lastRealBar = na
var float lastRealHigh = na
var float lastRealLow = na

var bool highCandidateActive = false
var int highCandidateBar = na
var float highCandidateHigh = na
var float highLeftHigh = na

var bool lowCandidateActive = false
var int lowCandidateBar = na
var float lowCandidateLow = na
var float lowLeftLow = na

isInsideBar = motherInitialized and high <= motherHigh and low >= motherLow

plotHighArrow(targetBar, targetHigh) =>
    label.new(
         x=targetBar,
         y=targetHigh + syminfo.mintick * offsetTicks,
         text="",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_arrowdown,
         color=markerColor,
         textcolor=markerColor,
         size=markerSize)

plotLowArrow(targetBar, targetLow) =>
    label.new(
         x=targetBar,
         y=targetLow - syminfo.mintick * offsetTicks,
         text="",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_arrowup,
         color=markerColor,
         textcolor=markerColor,
         size=markerSize)

if not motherInitialized
    motherInitialized := true
    motherHigh := high
    motherLow := low

    hasLastReal := true
    lastRealBar := bar_index
    lastRealHigh := high
    lastRealLow := low
else if not isInsideBar
    currentBar = bar_index
    currentHigh = high
    currentLow = low

    if hasLastReal
        if not highCandidateActive
            if currentHigh > lastRealHigh
                highCandidateActive := true
                highCandidateBar := currentBar
                highCandidateHigh := currentHigh
                highLeftHigh := lastRealHigh
        else
            if currentHigh == highCandidateHigh
                highCandidateBar := highCandidateBar
            else if currentHigh < highCandidateHigh
                if showHighPullbacks and highCandidateHigh > highLeftHigh
                    plotHighArrow(highCandidateBar, highCandidateHigh)
                highCandidateActive := false
                if currentHigh > lastRealHigh
                    highCandidateActive := true
                    highCandidateBar := currentBar
                    highCandidateHigh := currentHigh
                    highLeftHigh := lastRealHigh
            else
                highCandidateBar := currentBar
                highCandidateHigh := currentHigh
                highLeftHigh := lastRealHigh

        if not lowCandidateActive
            if currentLow < lastRealLow
                lowCandidateActive := true
                lowCandidateBar := currentBar
                lowCandidateLow := currentLow
                lowLeftLow := lastRealLow
        else
            if currentLow == lowCandidateLow
                lowCandidateBar := lowCandidateBar
            else if currentLow > lowCandidateLow
                if showLowPullbacks and lowCandidateLow < lowLeftLow
                    plotLowArrow(lowCandidateBar, lowCandidateLow)
                lowCandidateActive := false
                if currentLow < lastRealLow
                    lowCandidateActive := true
                    lowCandidateBar := currentBar
                    lowCandidateLow := currentLow
                    lowLeftLow := lastRealLow
            else
                lowCandidateBar := currentBar
                lowCandidateLow := currentLow
                lowLeftLow := lastRealLow

    lastRealBar := currentBar
    lastRealHigh := currentHigh
    lastRealLow := currentLow

    motherHigh := currentHigh
    motherLow := currentLow
````
