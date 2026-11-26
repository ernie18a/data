# Bearish Trend Reversal Detector

- url: https://www.tradingview.com/script/Cm2gkyhV-Bearish-Trend-Reversal-Detector/
- type: indicator
- pine_id: PUB;90d4b3912bb04c1e97bef3182b4b83eb
- version: 1.0

## Description

indicates when a green candle is formed with higher volume vs a red candles, or two green candles with aggregated volume higher than two red candles' svolume.

## Source Code

````pine
//@version=6
indicator('Bearish Trend Reversal Detector', overlay = true)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
minRedCandles = input.int(2, title = 'Minimum Red Candles Before Reversal', minval = 2)

// ─────────────────────────────────────────
// CANDLE DEFINITIONS
// ─────────────────────────────────────────
isRed(offset) =>
    close[offset] < open[offset]
isGreen(offset) =>
    close[offset] > open[offset]

// ─────────────────────────────────────────
// RED CANDLE STREAK CHECK
// Checks that there are at least `minRedCandles` consecutive red candles
// ending at Candle -1 (i.e. candles -1, -2, -3... all red)
// ─────────────────────────────────────────
redStreakValid() =>
    valid = true
    for i = 1 to minRedCandles by 1
        if not isRed(i)
            valid := false
            valid
    valid

// ─────────────────────────────────────────
// CONDITION SET 1
// Setup : 2+ red candles ending at -1
// Signal: Candle 0 is green
//         Candle 0 close > Candle -1 high (closes above prior red candle's wick)
//         Vol(0) > Vol(-1)
// Evaluated at close of Candle 0
// ─────────────────────────────────────────
cs1 = redStreakValid() and isGreen(0) and close > high[1] and volume > volume[1]

// ─────────────────────────────────────────
// CONDITION SET 2
// Setup : 2+ red candles ending at -2 (i.e. candles -2, -3... all red)
// Signal: Candle -1 was green, Candle 0 is green (Candle 0 = +1 from perspective of CS2 check)
//         CS1 was NOT triggered on the prior bar
//         Vol(-1) + Vol(0) > Vol(-2) + Vol(-3)
// Evaluated at close of Candle +1 (which is current Candle 0 in real time)
// ─────────────────────────────────────────

// Check red streak ending at candle -2 (i.e. offset by 1 more)
redStreakValidCS2() =>
    valid = true
    for i = 2 to minRedCandles + 1 by 1
        if not isRed(i)
            valid := false
            valid
    valid

// CS1 would have fired on the previous bar (Candle -1 from current perspective)
// Must mirror full CS1 logic including close > high of the candle before it
cs1_prev = redStreakValid()[1] and isGreen(1) and close[1] > high[2] and volume[1] > volume[2]

cs2 = redStreakValidCS2() and isGreen(1) and isGreen(0) and not cs1_prev and volume[1] + volume > volume[2] + volume[3] // Candle -1 (the first green) is green isGreen(0) and           // Candle  0 (the second green, i.e. +1) is green not cs1_prev and         // CS1 did NOT already fire on the prior bar (volume[1] + volume) > (volume[2] + volume[3])

// ─────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────
plotshape(cs1, title = 'CS1 — Single Green Reversal', location = location.belowbar, style = shape.triangleup, color = color.new(color.lime, 0), size = size.small, text = 'R1')

plotshape(cs2, title = 'CS2 — Two Green Reversal', location = location.belowbar, style = shape.triangleup, color = color.new(color.aqua, 0), size = size.small, text = 'R2')

// ─────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────
alertcondition(cs1, title = 'CS1 Reversal Signal', message = 'Bearish Reversal — CS1: Single green candle with volume confirmation.')
alertcondition(cs2, title = 'CS2 Reversal Signal', message = 'Bearish Reversal — CS2: Two green candles with combined volume confirmation.')
alertcondition(cs1 or cs2, title = 'Any Reversal Signal', message = 'Bearish Reversal detected (CS1 or CS2).')
````
