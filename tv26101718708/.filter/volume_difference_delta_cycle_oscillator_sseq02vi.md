# Volume Difference Delta Cycle Oscillator

- url: https://www.tradingview.com/script/SseQ02vi-Volume-Difference-Delta-Cycle-Oscillator/
- type: strategy
- pine_id: PUB;65567e0bf070440bb93d958abda95788
- version: 1.0

## Description

Volume Difference Delta Cycle Oscillator indicator:

Using the power of my Volume Difference Indicator and standard deviations based on Bollinger Bands and more, we present this wonderful indicator with the following features:

Price Action Histogram: This is the bread and butter of this graph, if the PAH is above 0, this is considered a BULL cycle, and if below 0, this is considered a BEAR cycle. The histogram will move up and down based on the Histagram settings you set in the properties field. Be careful, we advise using default settings.

Custom Overbought & Oversold Lines:mean
These lines can be used to identify when to buy and sell the security, and help you make sense of the action of the histogram. Change the color, size, and linewidth!
These lines are what are used to perform the trades with the strategy as well, so if you change them, they will make an impact on the strategy itself.

EzSpot Background:
Do you want to turn your brain off and just trade when you you're inside an Overbought or Oversold line? Awesome! Turn on EzSpot backgrounds, and when it's green, go long, when it's red go short! Simple as that!

How it works:

By taking the Delta of the Volume Difference Indicator we're able to find the rate of change of the amount of change of volume, allowing us to see changes in volume before price changes. To add onto these, we supercharge it by taking the output of this line as the input source of bollinger bands which we use to output the %B of the Delta of the Volume Difference Indicator. 

Separately, we calculate the %B of the current close to use later.

The final step is taking the second %B (which is an indication of where price lies on the curve of historical price data), and from it subtract the first %B, which allows us to visualize the standard deviation of the closing price, minus the standard deviation of Delta of the Volume Difference , which in essence allows us to see when volume changes but price does not and vice versa.

This final output is then plotted along with an over bought and over sold line, which we use to perform our trades on.

Simplified: This indicator shows the cycles of price action  - volume based on the rate of the rate of volume changes based on price and the closing price.

Super Simple: Notice when volume increases but price hasn't, and vice versa with this indicator.

## Source Code

````pine
//// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tathal and special thanks to oakwhiz for his porting of my custom volume indicator

//@version=5
strategy('Volume Difference Delta Cycle Oscillator', 'VDDC Osc', default_qty_type=strategy.percent_of_equity, default_qty_value=100, max_bars_back=5000)

startDate = input.int(title='Start Date', defval=1, minval=1, maxval=31)
startMonth = input.int(title='Start Month', defval=1, minval=1, maxval=12)
startYear = input.int(title='Start Year', defval=2010, minval=1800, maxval=2100)

endDate = input.int(title='End Date', defval=31, minval=1, maxval=31)
endMonth = input.int(title='End Month', defval=12, minval=1, maxval=12)
endYear = input.int(title='End Year', defval=2021, minval=1800, maxval=2100)

// Normalize Function
normalize(_src, _min, _max) =>
    // Normalizes series with unknown min/max using historical min/max.
    // _src      : series to rescale.
    // _min, _min: min/max values of rescaled series.
    var _historicMin = 10e10
    var _historicMax = -10e10
    _historicMin := math.min(nz(_src, _historicMin), _historicMin)
    _historicMax := math.max(nz(_src, _historicMax), _historicMax)
    _min + (_max - _min) * (_src - _historicMin) / math.max(_historicMax - _historicMin, 10e-10)


// STEP 2:
// Look if the close time of the current bar
// falls inside the date range
inDateRange = time >= timestamp(syminfo.timezone, startYear, startMonth, startDate, 0, 0) and time < timestamp(syminfo.timezone, endYear, endMonth, endDate, 0, 0)

// Stop loss & Take Profit Section     
l_sl_inp = input(2.0, title='Long Stop Loss %') / 100
l_tp_inp = input(4.0, title='Long Take Profit %') / 100

l_stop_level = strategy.position_avg_price * (1 - l_sl_inp)
l_take_level = strategy.position_avg_price * (1 + l_tp_inp)

s_sl_inp = input(2.0, title='Short Stop Loss %') / 100
s_tp_inp = input(4.0, title='Short Take Profit %') / 100

s_stop_level = strategy.position_avg_price * (1 + s_sl_inp)
s_take_level = strategy.position_avg_price * (1 - s_tp_inp)

src = close

//  Volume Differnce Indicator Delta

float change_src = ta.change(src)
float i_obv = ta.cum(change_src > 0 ? volume : change_src < 0 ? -volume : 0 * volume)
float i_pvt = ta.pvt

float result = ta.change(i_obv - i_pvt)

float nresult = ta.ema(normalize(result, -1, 1), 20)


// Volume Differnce Indicator Delta %B
length = input.int(20, minval=1, title='Volume Bands Length')
mult = input.float(2.0, minval=0.001, maxval=50, title='Volume Bands StdDev')
basis = ta.ema(nresult, length)
dev = mult * ta.stdev(nresult, length)
upper = basis + dev
lower = basis - dev
bbr = (nresult - lower) / (upper - lower)

// Normal %B, Based on close

l1 = input.int(20, minval=1, title='Bollinger Bands Length')
src2 = close
mult1 = input.float(2.0, minval=0.001, maxval=50, title='Bollinger Bands StdDev')
basis1 = ta.sma(src2, l1)
dev1 = mult1 * ta.stdev(src2, l1)
upper1 = basis1 + dev1
lower1 = basis1 - dev1
bbr1 = (src - lower1) / (upper1 - lower1)

/// Final Output Line

hist = ta.ema(ta.ema(ta.ema(bbr1 - bbr, input(2, title='Hist Smoothing Factor #1')), input(2, title='Hist Smoothing Factor #2')), input(2, title='Hist Smoothing Factor #3'))

/// Overbought / Oversold Line Creation
oversold = input(-.1)
overbought = input(.4)
hline(oversold, linewidth=2, color=color.new(#81c784, 62))
hline(overbought, linewidth=2, color=color.new(#c2185b, 38))

/// Long & Short Conditions

short = hist > overbought
long = hist < oversold

/// Colors & Plotting
histColor = hist >= 0 ? hist[1] < hist ? #26A69A : #B2DFDB : hist[1] < hist ? #FFCDD2 : #EF5350
plot(hist, title='Histogram', style=plot.style_columns, color=color.new(histColor, 0))

CrossBgColor = long ? color.new(#81c784, 62) : short ? color.new(#c2185b, 38) : na
bgcolor(color.new(CrossBgColor, 90))

/// Strategy Methodology

if inDateRange
    strategy.entry('long', strategy.long, when=long, stop=l_stop_level, limit=l_take_level)

if inDateRange and strategy.position_size > 0
    strategy.close_all(when=short)

if inDateRange
    strategy.entry('short', strategy.short, when=short, stop=s_stop_level, limit=s_take_level)

if inDateRange and strategy.position_size < 0
    strategy.close_all(when=long)
````
