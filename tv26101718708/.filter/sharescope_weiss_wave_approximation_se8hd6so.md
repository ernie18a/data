# ShareScope Weiss Wave approximation

- url: https://www.tradingview.com/script/Se8HD6SO-ShareScope-Weiss-Wave-approximation/
- type: indicator
- pine_id: PUB;fb8dc963d7514432bbfa5157974ff353
- version: 1.0

## Description

[b]ShareScope Weiss Wave approximation[/b]

This TradingView script is intended to provide a close visual approximation of the ShareScope Weis/Weiss Wave indicator. It is not an exact clone because ShareScope's proprietary source code is not known.

It has been prepared to facilitate comparison of several Weiss Waves against one another with different ZigZag values.

The indicator uses a configurable percentage ZigZag-style reversal threshold to define each wave, then accumulates volume during the active wave. When a new wave is confirmed, cumulative volume resets and a new wave-volume sequence begins.

The ZigZag Value (%) controls how much price must reverse before a new wave begins. The default value is 10%, matching the commonly observed ShareScope default.

ShareScope's suggested settings, comments and starting values:
Daily swing trading: 3–5%
Daily active/tactical: 2–3%
Weekly: 5–8%
Intraday 5-minute/hourly: 0.5–1.5%
UK mid-cap/AIM daily charts: often 5–7%
Large liquid FTSE 100 stocks: often 3–4%

Use High/Low is enabled by default. This uses the full candle high/low range and is intended to better capture true price extremes and turning points. If disabled, the script uses close-only logic, which is smoother but may miss intrabar extremes.

Symmetric Calculation is normally left OFF to remain closer to standard Weis Wave-style interpretation.

The practical purpose of this script is visual comparison. For example, users can apply two instances of the indicator to the same TradingView chart with different ZigZag percentage values, such as 10% and 4%, and compare how the wave structure changes against another indicator such as a stochastic curve.

[b]Important caveat: [/b]because the exact ShareScope calculation engine is not public, this script should be treated as an approximation for visual study, not a guaranteed replication of ShareScope's historical or live Weis/Weiss Wave engine.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © paulgill28

//@version=6
indicator("ShareScope Weiss Wave approximation", shorttitle="SS Weiss Wave approx", overlay=false)

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
