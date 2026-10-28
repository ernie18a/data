# SMI + Bollinger Bands

- url: https://www.tradingview.com/script/ptEBDRpd-SMI-Bollinger-Bands/
- type: indicator
- pine_id: PUB;c6a8fc44e4514fbdbf58b2b4e86aceb6
- version: 1.0

## Description

## SMI + Bollinger Bands

SMI + Bollinger Bands is an overlay indicator that projects the Stochastic Momentum Index directly into the price space defined by Bollinger Bands.

Traditional SMI indicators are displayed in a separate oscillator pane. This script instead transforms the SMI value into a price-relative flow line, allowing momentum, volatility, and price structure to be viewed together on the main chart.

### Core concept

The indicator calculates two related systems:

1. A standard Bollinger Band structure based on a configurable moving average and standard deviation.
2. A double-smoothed Stochastic Momentum Index calculated from the relationship between the closing price and its recent high-low range.

The SMI is then normalized using the selected SMI Threshold and projected around the Bollinger basis:

* An SMI value equal to the positive threshold aligns with the primary upper Bollinger Band.
* An SMI value equal to the negative threshold aligns with the primary lower Bollinger Band.
* Values between the thresholds appear inside the primary Bollinger range.
* Momentum exceeding the threshold can extend beyond the primary bands and into the optional extended-band zones.

This projection makes it possible to compare momentum behavior directly with current price and volatility rather than interpreting an oscillator in a separate pane.

### Plotted elements

**Bollinger basis**

The center line of the Bollinger structure. The moving-average type can be selected from SMA, EMA, SMMA/RMA, WMA, or VWMA.

**Primary Bollinger Bands**

The upper and lower volatility boundaries calculated from the selected standard-deviation multiplier.

**Extended Bollinger Bands**

Optional outer volatility zones using a separately configurable standard-deviation multiplier. These areas can help visualize unusually extended price or momentum conditions.

**SMI Flow**

The yellow line represents the projected Stochastic Momentum Index. Its position shows where momentum currently sits relative to the Bollinger structure.

**SMI Flow-Base**

The white line is an EMA-smoothed version of the projected SMI Flow. It provides a slower reference line that can be used to observe momentum direction, compression, expansion, and crossings.

### Inputs

**Bollinger Band settings**

* Length: Lookback period used for the Bollinger basis and standard deviation.
* Basis MA Type: Moving-average calculation used for the basis.
* Source: Price source used for the Bollinger calculations.
* StdDev: Multiplier used for the primary Bollinger Bands.
* Extended StdDev: Multiplier used for the optional outer bands.
* Use Extended Bands: Enables or disables the extended volatility zones.

**SMI settings**

* %K Length: Lookback period used to determine the recent high-low momentum range.
* %D Length: Double-EMA smoothing applied during the SMI calculation.
* EMA Length: Smoothing applied to the projected SMI Flow-Base line.
* SMI Threshold: Defines which positive and negative SMI values align with the primary upper and lower Bollinger Bands.

### General interpretation

The indicator is intended as a visual analysis framework rather than a standalone entry system.

Traders may use it to study:

* Momentum changes relative to volatility.
* SMI Flow and Flow-Base crossings.
* Momentum expansion beyond the primary bands.
* Momentum rejection from extended zones.
* Divergence between price movement and projected momentum.
* Compression around the Bollinger basis.
* Confluence with trend, structure, volume, support, resistance, or other analysis.

A movement outside a band does not automatically indicate a reversal. Strong trends can remain extended, and crossings can occur repeatedly during sideways or volatile conditions. Market context and risk management remain necessary.

### Calculation behavior

This script does not use future data, lookahead calculations, or higher-timeframe requests. Values on the active candle may continue changing as the candle’s high, low, and close update. Historical values are finalized after their respective candles close.

### Disclaimer

This indicator is provided for research, education, and chart analysis. It does not provide guaranteed trade signals, financial advice, or predictions of future market performance. Users are responsible for independently evaluating all trading decisions and managing their own risk.

## Source Code

````pine
// © silence_has_a_color
//@version=6
indicator(shorttitle="smibb", title="SMI + Bollinger Bands", overlay=true)

//Bollinger Bands
TT_bbLENGTH  = "The time period to be used in calculating the MA which creates the base for the Upper and Lower Bands."
TT_MA_TYPE   = "Determines the type of Moving Average that is applied to the basis plot line."
TT_bbSOURCE  = "Determines what data from each bar will be used in calculations."
TT_bbMULT    = "The number of Standard Deviations away from the MA that the Upper and Lower Bands should be."

//bb inputs
bblength     = input.int(20, "Length", minval = 1, tooltip =  TT_bbLENGTH)
bbmaType     = input.string("SMA", "Basis MA Type", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], tooltip = TT_MA_TYPE)
bbsrc        = input(close, "Source", tooltip = TT_bbSOURCE)
bbmult       = input.float(2.0, "StdDev", minval = 0.001, maxval = 50,  tooltip = TT_bbMULT)
OBBmult      = input.float(2.5, "Extended StdDev", minval = 1, maxval = 50, step=0.1, tooltip="The number of Standard Deviations away from the MA that the Extended Upper and Lower Bands should be.")
showoutbands = input.bool(true, "Use Extended Bands", tooltip="Using this shows extended momentum/volatility zones")

//SMI inputs
lengthK   = input.int(10, "%K Length",  minval = 1, maxval = 15000, tooltip="Controls how many candles are used to calculate the momentum range. Lower values react faster to price movement while higher values produce smoother, slower momentum flow.")
lengthD   = input.int(3,  "%D Length",  minval = 1, maxval = 4999, tooltip="Controls the smoothing applied to the raw momentum calculation. Lower values increase responsiveness and noise, while higher values create smoother and more stable momentum behavior.")
lengthEMA = input.int(3,  "EMA Length", minval = 1, maxval = 4999, tooltip="Applies an additional EMA smoothing layer to the plotted SMI Flow. Higher values reduce volatility in the flow line and emphasize broader directional movement.")
SMIthresh = input.int(65, "SMI Threshold", minval = 40, maxval =100, tooltip="this is the over bought/sold line on your oscillator. It is matched to the primary BB upper/lower lines in this script.")

//bb data
ma(source, bblength, _type) =>
    switch _type
        "SMA" => ta.sma(source, bblength)
        "EMA" => ta.ema(source, bblength)
        "SMMA (RMA)" => ta.rma(source, bblength)
        "WMA" => ta.wma(source, bblength)
        "VWMA" => ta.vwma(source, bblength)

bbbasis = ma(bbsrc, bblength, bbmaType)
stdev = ta.stdev(bbsrc, bblength)
dev = bbmult * stdev
upper = bbbasis + dev
lower = bbbasis - dev
Odev = OBBmult * stdev
Oupper = bbbasis + Odev
Olower = bbbasis - Odev

//bb plotting
plot(bbbasis, "bbBasis", color=#2962FF)
p1 = plot(upper, "Upper", color=#F23645)
p2 = plot(lower, "Lower", color=#039b29)
Op1 = plot((showoutbands ? Oupper : na), "Outer Upper", color=color.rgb(250, 7, 7))
Op2 = plot((showoutbands ? Olower : na), "Outer Lower", color=color.rgb(7, 252, 15))

fill(p1, p2, title = "BB Range Background", color=color.rgb(33, 150, 243, 95))
fill(Op1, p1, title = "Outer Upper Background", color=(showoutbands ? color.rgb(255, 0, 0, 91) : na))
fill(Op2, p2, title = "Outer Lower Background", color=(showoutbands ? color.rgb(9, 255, 0, 95) : na))

//SMI data
emaEma(source, length) => ta.ema(ta.ema(source, length), length)
highestHigh = ta.highest(high,lengthK)
lowestLow = ta.lowest(low,lengthK)
highestLowestRange = highestHigh - lowestLow
relativeRange = close - (highestHigh + lowestLow) / 2
RelRangeEMA = emaEma(relativeRange, lengthD)
smidenom = emaEma(highestLowestRange, lengthD)
sminumer = 200 * RelRangeEMA
smi = smidenom != 0 ? sminumer / smidenom : 0
smiplotted = bbbasis + (smi/SMIthresh) * dev
smismoothed = ta.ema(smiplotted, lengthEMA)

//SMI plotting
plot(smiplotted, "SMI Flow", color=color.rgb(247, 224, 16), linewidth=2)
plot(smismoothed, "SMI Flow-Base", color=color.rgb(255, 255, 255), linewidth=2)
````
