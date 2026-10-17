# Trimmed Mean ATR Bands [NJ]

- url: https://www.tradingview.com/script/1gKysDV2-Trimmed-Mean-ATR-Bands-NJ/
- type: indicator
- pine_id: PUB;1a73af9d7db949d6aca81838139f7d4d
- version: 1.0

## Description

✧ OVERVIEW ✧

Trimmed Mean ATR Bands is a volatility-based, trend-following indicator that combines a trimmed mean with ATR-based volatility bands.

The trimmed mean reduces the influence of extreme price values by removing a selected percentage of the highest and lowest values before calculating the average.

Price crossing the ATR bands determines the current bullish or bearish condition, which is displayed using colored candles and an active volatility band.
[image]https://www.tradingview.com/x/cOnDvf9r/[/image]

✧ SETTINGS ✧

Color Candles
Shows or hides candle coloring based on the current signal.

Show Bands
Shows or hides the active ATR band.

TM Source
Selects the price source used for the trimmed mean calculation.

Trim Amount (%)
Controls the percentage of values removed from each side of the sorted price data before calculating the mean.

TM Length
Controls how many bars are used to calculate the trimmed mean.

ATR Length
Controls how many bars are used to calculate the ATR.

✧ HOW IT WORKS ✧

Trimmed Mean
Indicator collects selected number of price values and sorts them from lowest to highest.

Selected Trim Amount is removed from both the lowest and highest ends of the data. Remaining values are averaged to calculate the trimmed mean.

For example, a 25% trim removes approximately the lowest 25% and highest 25% of values before averaging the remaining values.

ATR Bands
ATR measures recent market volatility.
Upper Band = Trimmed Mean + ATR
Lower Band = Trimmed Mean − ATR

Signal Logic
A bullish condition is activated when the candle high moves above the upper band.
A bearish condition is activated when the candle low moves below the lower band.

Active condition remains unchanged until the opposite condition occurs.

✧ VISUALIZATION ✧

Green candles represent a bullish condition.
Red candles represent a bearish condition.

During a bullish condition, lower ATR band is displayed in green.
During a bearish condition, upper ATR band is displayed in red.

Candle coloring and bands can be enabled or disabled independently in the settings.

✧ USAGE ✧

Trimmed Mean ATR Bands can be used to identify:

Bullish and bearish trend conditions
Volatility-adjusted price breakouts
Dynamic trend support and resistance
Directional market bias
Additional confirmation for other technical analysis

Trimmed mean is designed to reduce the influence of unusually high or low price values compared with a standard arithmetic mean.

As with any technical indicator, it is best used alongside other forms of analysis rather than as a standalone entry or exit signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("Trimmed Mean ATR Bands [NJ]", "TMAB", overlay = true, behind_chart = false)

// ✧═════════════════✧
// ║      INPUTS      ║
// ✧═════════════════✧

const string g1 = "✧ DISPLAY ✧"
displayColCandles = input.bool(true, "Color candles", group = g1)
displayBands = input.bool(true, "Show bands", group = g1)

const string g2 = "✧ CALCULATION ✧"
tmSrc = input.source(close, "TM source", group = g2)
trimPct = input.int(25, "Trim amount (%)", minval = 0, maxval = 49, group = g2)
tmLen = input.int(66, "TM length", minval = 1, group = g2)
atrLen = input.int(18, "ATR length", minval = 1, group = g2)

// ✧═══════════════════════✧
// ║      TRIMMED MEAN      ║
// ✧═══════════════════════✧

tm(tmSrc, tmLen, trimPct) =>

    array<float> srcValues = array.new<float>()

    for i = 0 to tmLen - 1
        array.push(srcValues, tmSrc[i])

    array.sort(srcValues, order.ascending)

    trimCount = math.floor(tmLen * trimPct / 100)

    float sum = 0
    int count = 0
    for i = trimCount to tmLen - 1 - trimCount
        sum += array.get(srcValues, i)
        count += 1

    sum / count

trimmedMean = tm(tmSrc, tmLen, trimPct)

// ✧════════════════✧
// ║      BANDS      ║
// ✧════════════════✧

atr = ta.atr(atrLen)

upperBand = trimmedMean + atr
lowerBand = trimmedMean - atr

// ✧═══════════════════════✧
// ║      FINAL SIGNAL      ║
// ✧═══════════════════════✧

var int NJ = 0

if high > upperBand
    NJ := 1
if low < lowerBand
    NJ := -1

// ✧════════════════✧
// ║      PLOTS      ║
// ✧════════════════✧

sigCol = NJ == 1 ? color.rgb(0, 136, 100) : NJ == -1 ? color.rgb(120, 0, 32) : na

plotcandle(
     open, high, low, close,
     "Colored candles", 
     displayColCandles ? sigCol : na,
     displayColCandles ? sigCol : na,
     bordercolor = displayColCandles ? sigCol : na,
     display = display.all - display.status_line - display.price_scale)

plot(NJ == -1 and displayBands ? upperBand : na, "Upper band", color.rgb(120, 0, 32), 2, plot.style_linebr)
plot(NJ == 1 and displayBands ? lowerBand : na, "Lower band", color.rgb(0, 136, 100), 2, plot.style_linebr)
````
