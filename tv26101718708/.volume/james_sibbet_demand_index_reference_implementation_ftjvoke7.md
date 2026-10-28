# James Sibbet Demand Index (Reference Implementation)

- url: https://www.tradingview.com/script/FtJVoKe7-James-Sibbet-Demand-Index-Reference-Implementation/
- type: indicator
- pine_id: PUB;fa44c4034b244936af49c12c9617b967
- version: 1.0

## Description

The James Sibbet Demand Index is a volume-based indicator that measures buying pressure and selling pressure.

This script offers two display modes:

• Demand Index Mode – shows the classic Demand Index and its signal line.

• Buying/Selling Pressure Mode – shows the underlying Buying Pressure (BP) and Selling Pressure (SP) components used to calculate the Demand Index.

The indicator combines price, volume and volatility to estimate whether demand or supply is dominating the market.

This open-source script is intended as a documented reference implementation of the James Sibbet Demand Index.

## Source Code

````pine
//@version=6

// Version 1.0
// Release Date: 23 June 2026, India

// ============================================================================
// James Sibbet Demand Index (Reference Implementation)
// ============================================================================
//
// Historical Background
//
// The Demand Index was developed by James Sibbet during the 1970s.
//
// The objective of the indicator is to estimate buying pressure and
// selling pressure using a combination of price, volume and volatility.
//
// This implementation attempts to preserve and document the methodology
// in an open-source and transparent form.
//
// Reference Sources
//
// • James Sibbet Demand Index methodology
// • Sierra Chart Demand Index documentation
// • Historical spreadsheet reconstruction and validation
//
// Design Philosophy
//
// This script intentionally excludes:
//
// • Trading signals
// • Arrows
// • Dots
// • Labels
// • Alerts
// • Divergence detection
// • Strategy logic
//
// The objective is preservation, documentation,
// transparency and reproducibility.
//
// License: MIT
//
// ============================================================================

indicator("James Sibbet Demand Index (Reference Implementation)", shorttitle = "Sibbet DI Ref", overlay = false)

// ============================================================================
// INPUTS
// ============================================================================
//
// Display Mode
//
// Demand Index
//     Displays DI and Signal.
//
// Buying/Selling Pressure
//     Displays BP and SP.
//
// ============================================================================

displayMode = input.string("Demand Index", "Display Mode", options = ["Demand Index", "Buying/Selling Pressure"])

// ============================================================================
// CORE PARAMETERS
// ============================================================================

length = input.int(19, "Length", minval = 1)
signalLength = input.int(9, "Signal Length", minval = 1)

maType = input.string("RMA", "MA Type", options = ["SMA", "EMA", "RMA"])

normMethod = input.string("Range", "Normalization Method", options = ["Range", "ATR"])
normLength = input.int(2, "Normalization Length", minval = 1)

// ============================================================================
// DISPLAY MODE LOGIC
// ============================================================================

showDI = displayMode == "Demand Index"
showSignal = displayMode == "Demand Index"
showBP = displayMode == "Buying/Selling Pressure"
showSP = displayMode == "Buying/Selling Pressure"

// ============================================================================
// MOVING AVERAGE ENGINE
// ============================================================================
//
// Version 1 intentionally supports:
//
// • SMA
// • EMA
// • RMA
//
// Additional smoothing methods should be implemented
// only in derivative works.
//
// ============================================================================

ma(src, len) =>
    float result = na
    if maType == "SMA"
        result := ta.sma(src, len)
    else if maType == "EMA"
        result := ta.ema(src, len)
    else
        result := ta.rma(src, len)
    result

// ============================================================================
// PRICE CALCULATION
// ============================================================================
//
// Sibbet weighted price:
//
// P = High + Low + 2 × Close
//
// The close receives double weight.
//
// ============================================================================

price = high + low + close + close
prevPrice = nz(price[1], price)

// ============================================================================
// VOLUME NORMALIZATION
// ============================================================================
//
// Volume Ratio = Current Volume / Average Volume
//
// ============================================================================

volumeAverage = ma(volume, length)
volumeRatio = volumeAverage != 0 ? volume / volumeAverage : 0.0

// ============================================================================
// VOLATILITY NORMALIZATION
// ============================================================================
//
// Sierra documentation references H0-L0.
//
// This implementation replaces that static value
// with a dynamic normalization.
//
// Range:
//     Highest High - Lowest Low
//
// ATR:
//     Wilder ATR
//
// ============================================================================

rangeNormalization = ta.highest(high, normLength) - ta.lowest(low, normLength)
atrLength = math.max(normLength, 3)
atrNormalization = ta.atr(atrLength)
normalization = normMethod == "Range" ? rangeNormalization : atrNormalization
normalization := normalization <= 0 ? 0.0000001 : normalization

// ============================================================================
// BUYING PRESSURE
// ============================================================================
//
// When price declines,
// buying pressure is reduced exponentially.
//
// Otherwise BP equals normalized volume.
//
// ============================================================================

bpExponent = 0.375 * ((price + prevPrice) / normalization) * ((prevPrice - price) / math.max(price, 0.0000001))
rawBP = price < prevPrice ? volumeRatio / math.exp(bpExponent) : volumeRatio

// ============================================================================
// SELLING PRESSURE
// ============================================================================
//
// When price rises,
// selling pressure is reduced exponentially.
//
// Otherwise SP equals normalized volume.
//
// ============================================================================

spExponent = 0.375 * ((price + prevPrice) / normalization) * ((price - prevPrice) / math.max(prevPrice, 0.0000001))
rawSP = price > prevPrice ? volumeRatio / math.exp(spExponent) : volumeRatio

// ============================================================================
// SMOOTHED PRESSURE
// ============================================================================
//
// BP and SP are smoothed using the user-selected
// moving average type and length.
//
// ============================================================================

bp = ma(rawBP, length)
sp = ma(rawSP, length)

// ============================================================================
// DEMAND INDEX
// ============================================================================
//
// DI = 100 × (BP − SP) / max(BP,SP)
//
// Positive:
//     Buying pressure dominates.
//
// Negative:
//     Selling pressure dominates.
//
// Zero:
//     Equilibrium.
//
// ============================================================================

di = 100 * (bp - sp) / math.max(bp, sp)
signal = ma(di, signalLength)

// ============================================================================
// PLOTS
// ============================================================================

bpPlot = plot(showBP ? bp : na, "Buying Pressure", color.green, 2)
spPlot = plot(showSP ? sp : na, "Selling Pressure", color.orange, 2)

plot(showDI ? di : na, "Demand Index", color.white, 2)
plot(showSignal ? signal : na, "Signal", color.blue, 2)

// ============================================================================
// PRESSURE DOMINANCE SHADING
// ============================================================================
//
// Green:
//     BP > SP
//
// Red:
//     SP > BP
//
// Opacity:
//     8%
//
// ============================================================================

fill(bpPlot, spPlot, bp >= sp ? color.new(color.green, 92) : color.new(color.red, 92))

// ============================================================================
// HISTORICAL PRESERVATION NOTE
// ============================================================================
//
// This script attempts to preserve and document
// the James Sibbet Demand Index.
//
// Future enhancements should be developed as
// separate derivative works so that this
// reference implementation remains a stable
// historical record of the underlying method.
//
// ============================================================================
// Reference Implementation Status:
// Validated against Sibbet DI V1
````
