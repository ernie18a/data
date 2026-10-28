# Bitcoin Compressing Power Law Channel

- url: https://www.tradingview.com/script/F6xGCbGB-Bitcoin-Compressing-Power-Law-Channel/
- type: indicator
- pine_id: PUB;56e6dfbd4b4f4c72bb3d4639084f1bbe
- version: 1.0

## Description

[b]Bitcoin Compressing Power Law Channel[/b]
Most Bitcoin power-law channels draw bands of a fixed width around a long-term trendline. This one is different: the channel width is not constant. It starts wide and compresses exponentially as Bitcoin matures, modeling the idea that long-term volatility around the trend tends to shrink over time. That decaying width is the core idea of this indicator.

[b]Why a compressing channel[/b]
A standard power-law channel assumes the spread between its upper and lower bounds stays the same across Bitcoin's entire history. In practice, an asset's relative volatility tends to fall as it grows larger and more liquid. This indicator captures that by letting the channel narrow over time toward a configurable floor, so the bounds reflect a maturing market rather than a permanently fixed range.

[b]How it works[/b]

The model assumes log(price) scales linearly with log(days since the genesis block), producing a fair-value trendline: logFair = intercept + slope * log10(days). A lower bound is offset below that line, and the upper bound is placed above the lower bound at a distance set by the channel width.
The width itself is the original part: width = minWidth + startWidth * exp(-decaySpeed * yearsSinceGenesis). Early in Bitcoin's history the exponential term is large and the channel is wide. As years pass, that term shrinks toward zero and the width converges to a minimum floor (minWidth). The result is a channel whose envelope tightens over time instead of staying fixed.

[b]What it plots[/b]

Three lines in price space (upper, middle, lower) with a shaded fill between the upper and lower bounds. Optionally, a 200 SMA of the current timeframe and a 200 SMA from the weekly timeframe, each toggleable. The weekly SMA is requested from a higher timeframe with lookahead disabled, so it does not repaint using future data. A normalized "Decay Channel Oscillator" is exposed in the Data Window, showing where the current close sits within the channel on a 0 to 1 scale (0 = lower bound, 1 = upper bound).
Inputs
Every model parameter is adjustable: the genesis date, the power-law intercept and slope, the lower offset, the initial and minimum channel widths, and the decay speed that controls how fast the channel compresses. Colors for each line, the fill, and both SMAs are configurable.

[b]How to use it[/b]

Apply it to a Bitcoin chart on a longer timeframe such as Daily or Weekly, where a power-law model is most meaningful. The middle line is the model's central estimate; the upper and lower lines describe the expected long-term range, narrowing as time goes on. The Data Window oscillator lets you read how stretched price is within the channel numerically.

[b]Parameters and calibration[/b]

The default intercept and slope are starting values that approximate Bitcoin's historical power-law fit. They are not fixed truths. You should re-evaluate them and adjust them, along with the offset, widths, and decay speed, to suit your own analysis and the data range you are studying. Different calibrations will move the channel and change how aggressively it compresses.

[b]Limitations and cautions[/b]

This is a model, not a prediction. The power-law relationship is an empirical observation that may break down at any time, and the decay parameters are assumptions, not facts. The compressing width is a hypothesis about volatility maturing over time; it may not hold. This indicator is built for Bitcoin and is not intended for other assets. Nothing here forecasts future prices, and the past behavior of the channel does not guarantee anything about how price will behave going forward.

[i]The code is open-source under the Mozilla Public License 2.0. You are welcome to study it and build on it.[/i]

## Source Code

````pine
//@version=6
indicator('Bitcoin Compressing Power Law Channel', overlay = true, max_bars_back = 5000)

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------
genesisTime = input.time(defval = 1230940800000, title = 'Bitcoin Genesis Date')

intercept = input.float(-17.0159, 'Power Law Intercept', step = 0.0001)
slope     = input.float(5.8451, 'Power Law Slope', step = 0.0001)

lowerOffsetLog = input.float(0.45, 'Lower Offset Log10', step = 0.01)
startWidthLog  = input.float(2.00, 'Initial Channel Width Log10', step = 0.01)
minWidthLog    = input.float(0.45, 'Minimum Channel Width Log10', step = 0.01)
decaySpeed     = input.float(0.12, 'Decay Speed', step = 0.01)

upperColor = input.color(color.red, 'Upper Channel')
midColor   = input.color(color.gray, 'Middle Channel')
lowerColor = input.color(color.green, 'Lower Channel')
fillColor  = input.color(color.new(color.gray, 90), 'Channel Fill')

showSma200       = input.bool(true, 'Show SMA 200 Current TF')
showWeeklySma200 = input.bool(true, 'Show SMA 200 Weekly TF')
sma200Color       = input.color(color.white, 'SMA 200 Current TF')
weeklySma200Color = input.color(color.blue, 'SMA 200 Weekly TF')

// ---------------------------------------------------------------------------
// Time
// ---------------------------------------------------------------------------
daysSinceGenesis  = math.max(1.0, (time - genesisTime) / 86400000.0)
yearsSinceGenesis = daysSinceGenesis / 365.25

// ---------------------------------------------------------------------------
// Log helpers
// ---------------------------------------------------------------------------
logDays  = math.log(daysSinceGenesis) / math.log(10)
logClose = math.log(close) / math.log(10)

// ---------------------------------------------------------------------------
// Decay Channel
// ---------------------------------------------------------------------------
logFair      = intercept + slope * logDays
logLower     = logFair - lowerOffsetLog
channelWidth = minWidthLog + startWidthLog * math.exp(-decaySpeed * yearsSinceGenesis)
logUpper     = logLower + channelWidth
logMiddle    = math.avg(logUpper, logLower)

lowerChannel  = math.pow(10, logLower)
middleChannel = math.pow(10, logMiddle)
upperChannel  = math.pow(10, logUpper)

// ---------------------------------------------------------------------------
// Moving Averages
// Weekly SMA is pulled from a higher timeframe via request.security with
// lookahead disabled, so it does not repaint using future data.
// ---------------------------------------------------------------------------
sma200       = ta.sma(close, 200)
weeklySma200 = request.security(syminfo.tickerid, 'W', ta.sma(close, 200), barmerge.gaps_off, barmerge.lookahead_off)

// ---------------------------------------------------------------------------
// Oscillator (position of close within the channel, 0 = lower, 1 = upper)
// ---------------------------------------------------------------------------
decayOsc        = (logClose - logLower) / (logUpper - logLower)
decayOscClamped = math.max(0.0, math.min(1.0, decayOsc))

// ---------------------------------------------------------------------------
// Plots
// ---------------------------------------------------------------------------
pUpper = plot(upperChannel, title = 'Upper Decay Channel', color = upperColor, linewidth = 2)
plot(middleChannel, title = 'Middle Decay Channel', color = midColor, linewidth = 1)
pLower = plot(lowerChannel, title = 'Lower Decay Channel', color = lowerColor, linewidth = 2)
plot(showSma200 ? sma200 : na, title = 'SMA 200 Current TF', color = sma200Color, linewidth = 2)
plot(showWeeklySma200 ? weeklySma200 : na, title = 'SMA 200 Weekly TF', color = weeklySma200Color, linewidth = 2)

fill(pUpper, pLower, color = fillColor)

// ---------------------------------------------------------------------------
// Data Window
// ---------------------------------------------------------------------------
plot(decayOscClamped, title = 'Decay Channel Oscillator', display = display.data_window)
plot(logLower, title = 'Log Lower', display = display.data_window)
plot(logMiddle, title = 'Log Middle', display = display.data_window)
plot(logUpper, title = 'Log Upper', display = display.data_window)
````
