# ShareScope Weiss Wave approximation v1

- url: https://www.tradingview.com/script/xet0n0zS-ShareScope-Weiss-Wave-approximation-v1/
- type: indicator
- pine_id: PUB;ac32ba7637944280b9143c3e710cfbfd
- version: 1.0

## Description

[b]ShareScope Weis Wave Approximation v1
[/b]
Overview

This indicator is an attempt to reproduce the behaviour of the Weis Wave implementation available in ShareScope using TradingView Pine Script.

The objective is not to recreate every interpretation of David H. Weis's work, but rather to approximate the wave-construction and cumulative volume behaviour observed in ShareScope's Volume Weis Wave indicator.

[b]Methodology
[/b]
The indicator organises market volume into directional price waves using a percentage-based ZigZag reversal threshold.

A wave remains active while price continues moving in the current direction. When price reverses by the specified percentage amount, the current wave is completed and a new wave begins. Volume is accumulated throughout the life of each wave and displayed as a cumulative histogram.

[b]Available options include:
[/b]
• ZigZag Value (%) – percentage reversal required to start a new wave.
• Use High/Low – uses candle extremes rather than closing prices when determining wave reversals.
• Symmetric Calculation – applies proportional reversal mathematics so that up and down reversals are geometrically symmetrical.

The calculation updates dynamically as new price data arrives and completed waves become fixed only after the reversal threshold has been reached.

What This Indicator Is Not

[b]Please note - [/b]This is not an ATR-based Weis Wave model.

Some modern Weis Wave implementations use Average True Range (ATR), volatility measurements, adaptive thresholds or other dynamic methods to determine wave reversals. This indicator does not use ATR, volatility bands, adaptive filters, moving averages or volume-based reversal logic.

Wave changes are driven solely by the selected percentage reversal threshold, consistent with the behaviour described for ShareScope's Weis Wave implementation.

[b]Notes
[/b]
David H. Weis never published a single definitive formula for constructing Weis Waves and various software platforms implement the concept differently. As a result, indicators carrying the "Weis Wave" name may produce substantially different results depending on the wave-construction methodology used.

This script focuses specifically on approximating ShareScope's percentage-based wave model rather than ATR-based, volatility-based or proprietary alternatives.

For research and comparison purposes, several exportable data series are included:

• Wave Direction
• New Wave Trigger
• Active Wave Volume
• ZigZag Value
• Current Swing Extreme

These outputs can be accessed through TradingView's Data Window and CSV export facilities.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © paulgill28

//@version=6
indicator("ShareScope Weiss Wave approximation", shorttitle="SS Weiss Wave approx v1", overlay=false)

// -----------------------------------------------------------------------------
// ShareScope Weiss Wave approximation
// -----------------------------------------------------------------------------
// This script is a close visual approximation of ShareScope Weis/Weiss Wave
// behaviour. It is not a guaranteed clone because ShareScope's proprietary
// source code and exact implementation details are not known.
//
// The calculation is causal: it does not use future-looking pivots and confirms
// a new wave only when price reverses by the configured ZigZag percentage.
// -----------------------------------------------------------------------------

zigZagValuePercent = input.float(10.0, "ZigZag Value (%)", minval=0.1, step=0.1)
useHighLow         = input.bool(true, "Use High/Low")
symmetricCalc      = input.bool(false, "Symmetric Calculation")

zigZagFraction = zigZagValuePercent / 100.0

// Use candle extremes when requested; otherwise use close-only logic.
upPrice   = useHighLow ? high : close
downPrice = useHighLow ? low : close
seedPrice = close

// Persistent state for the active wave.
var int   waveDirection    = 0
var float swingExtreme     = na
var float unconfirmedHigh  = na
var float unconfirmedLow   = na
var float activeWaveVolume = 0.0

bool newUpWave = false
bool newDownWave = false

// Threshold helpers. Standard mode uses a simple percentage move from the
// current extreme. Symmetric mode uses reciprocal downside thresholds so equal
// up/down percentage moves are geometrically balanced.
upReversalLevel(float extreme, float fraction) =>
    extreme * (1.0 + fraction)

downReversalLevel(float extreme, float fraction, bool symmetric) =>
    symmetric ? extreme / (1.0 + fraction) : extreme * (1.0 - fraction)

if na(swingExtreme)
    swingExtreme := seedPrice
    unconfirmedHigh := upPrice
    unconfirmedLow := downPrice
    activeWaveVolume := volume
else
    activeWaveVolume += volume

    if waveDirection == 0
        // No confirmed direction yet. Track both sides of the starting range
        // until price moves far enough to establish the first active wave.
        unconfirmedHigh := math.max(nz(unconfirmedHigh, upPrice), upPrice)
        unconfirmedLow := math.min(nz(unconfirmedLow, downPrice), downPrice)

        if upPrice >= upReversalLevel(unconfirmedLow, zigZagFraction)
            waveDirection := 1
            swingExtreme := upPrice
            activeWaveVolume := volume
            newUpWave := true
        else if downPrice <= downReversalLevel(unconfirmedHigh, zigZagFraction, symmetricCalc)
            waveDirection := -1
            swingExtreme := downPrice
            activeWaveVolume := volume
            newDownWave := true
        else
            swingExtreme := close >= seedPrice ? unconfirmedHigh : unconfirmedLow

    else if waveDirection == 1
        // During an up wave, keep raising the high extreme until a confirmed
        // downside reversal begins a new down wave.
        if upPrice > swingExtreme
            swingExtreme := upPrice

        if downPrice <= downReversalLevel(swingExtreme, zigZagFraction, symmetricCalc)
            waveDirection := -1
            swingExtreme := downPrice
            activeWaveVolume := volume
            newDownWave := true

    else if waveDirection == -1
        // During a down wave, keep lowering the low extreme until a confirmed
        // upside reversal begins a new up wave.
        if downPrice < swingExtreme
            swingExtreme := downPrice

        if upPrice >= upReversalLevel(swingExtreme, zigZagFraction)
            waveDirection := 1
            swingExtreme := upPrice
            activeWaveVolume := volume
            newUpWave := true

newWaveTrigger = newUpWave ? 1 : newDownWave ? -1 : 0
histogramValue = activeWaveVolume
histogramColor = waveDirection >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)

plot(histogramValue, title="Weis/Weiss Wave Volume", style=plot.style_histogram, color=histogramColor, linewidth=3)


// Exportable numeric series for CSV export and parity testing.
plot(waveDirection, title="Wave Direction", display=display.data_window)
plot(newWaveTrigger, title="New Wave Trigger", display=display.data_window)
plot(activeWaveVolume, title="Active Wave Volume", display=display.data_window)
plot(zigZagValuePercent, title="ZigZag Value", display=display.data_window)
plot(swingExtreme, title="Current Swing Extreme", display=display.data_window)
````
