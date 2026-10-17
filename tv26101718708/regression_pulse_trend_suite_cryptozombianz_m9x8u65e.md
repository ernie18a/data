# Regression Pulse Trend Suite [Crypto_Zombianz]

- url: https://www.tradingview.com/script/m9X8U65e-Regression-Pulse-Trend-Suite-Crypto-Zombianz/
- type: indicator
- pine_id: PUB;0a3ec38ea1084671b385484028ece567
- version: 1.0

## Description

# Regression Pulse Trend Suite [Crypto_Zombianz]

## Overview

Regression Pulse Trend Suite is a multi-purpose trend-following and market-structure indicator designed to help traders identify trend direction, dynamic support and resistance areas, potential reversal points, and long or short trading opportunities.

The indicator combines a Linear Regression Channel, volatility-based deviation bands, an EMA trend ribbon, peak and trough detection, risk-management levels, and customizable alerts in one complete trading tool.

It can be used on cryptocurrencies, forex, stocks, indices, commodities, and other liquid markets across multiple timeframes.

## Main Features

### Linear Regression Trend Channel

The indicator calculates a Linear Regression Channel using the selected lookback period.

The channel includes:

* A central regression line representing the prevailing price trend.
* Upper and lower deviation bands representing dynamic resistance and support.
* Intermediate dotted levels that help identify potential reaction and pullback areas.
* Optional channel extension to project the current trend structure forward.

The channel automatically adjusts as new price data becomes available.

### EMA Trend Ribbon

The indicator displays five Exponential Moving Averages:

* EMA 8
* EMA 12
* EMA 16
* EMA 20
* EMA 24

The EMA ribbon provides a visual representation of short-term trend direction and momentum.

A properly aligned and expanding ribbon may indicate strengthening momentum, while a compressed or frequently crossing ribbon may indicate consolidation or an uncertain market.

### Peak and Trough Detection

The indicator identifies potential market turning points using candle-direction changes and previous threshold levels.

* A red cross represents a detected peak.
* A blue diamond represents a detected trough.
* A red circle represents a potential short signal when signal visibility is enabled.
* A blue circle represents a potential long signal when signal visibility is enabled.

Peak and trough markers are not guaranteed reversal signals. They should be confirmed using the regression channel, EMA ribbon, market structure, volume, or another confirmation method.

### Long and Short Signals

A potential long signal is generated when a detected trough is followed by price crossing above the lower regression deviation band.

A potential short signal is generated when a detected peak is followed by price crossing below the upper regression deviation band.

The Position setting can be used to control which trade directions are allowed.

## How to Use the Indicator

### Long Setup

Consider a potential long setup when:

1. The price is near or below the lower regression channel.
2. A trough is detected.
3. The price crosses back above the lower deviation band.
4. The EMA ribbon supports bullish momentum.
5. The selected Position mode allows long trades.

The blue diamond identifies a trough, while the optional blue circle represents a potential long entry signal.

Avoid entering only because a trough appears. Waiting for candle-close confirmation and additional trend confirmation may help reduce false signals.

### Short Setup

Consider a potential short setup when:

1. The price is near or above the upper regression channel.
2. A peak is detected.
3. The price crosses back below the upper deviation band.
4. The EMA ribbon supports bearish momentum.
5. The selected Position mode allows short trades.

The red cross identifies a peak, while the optional red circle represents a potential short entry signal.

Avoid entering only because a peak appears. Waiting for candle-close confirmation and additional trend confirmation may help reduce false signals.

### Trend-Following Method

The indicator may also be used for trend-following entries.

During a bullish trend, traders can monitor the central regression line, lower intermediate level, or lower channel boundary for pullback opportunities.

During a bearish trend, traders can monitor the central regression line, upper intermediate level, or upper channel boundary for potential short opportunities.

A wider and clearly aligned EMA ribbon generally represents stronger momentum. A narrow or mixed ribbon can indicate consolidation.

### Support and Resistance Method

The regression levels can act as dynamic support and resistance zones:

* The upper deviation band may act as dynamic resistance.
* The lower deviation band may act as dynamic support.
* The central regression line may act as a trend equilibrium level.
* The intermediate dotted levels may act as pullback or partial profit-taking zones.

These levels should be treated as areas rather than exact prices.

## Indicator Settings

### Position

Controls the permitted trade direction:

* **Auto:** Allows long and short signals according to the regression trend filter.
* **Auto Long:** Allows only trend-filtered long signals.
* **Auto Short:** Allows only trend-filtered short signals.
* **Fixed:** Allows both long and short signals without the automatic trend-direction filter.
* **Fixed Long:** Allows only long signals.
* **Fixed Short:** Allows only short signals.

### Quantity

Sets the quantity value included in the indicator’s dynamic alert message.

This setting does not automatically place or execute an order.

### Take Profit

Controls the reward-to-risk multiplier used to calculate the projected take-profit level.

For example, a value of 1.2 calculates a target approximately 1.2 times the defined risk distance.

### Stop Loss

Available stop-loss calculation methods:

* **ATR:** Adds or subtracts one ATR from the recent three-bar high or low.
* **ATR x 2:** Adds or subtracts two ATR values from the recent three-bar high or low.
* **HHLL:** Uses the highest high or lowest low of the latest three candles without an additional ATR offset.

### Deviation

Controls the width of the Linear Regression Channel.

A higher value creates wider bands and fewer potential channel-crossing signals. A lower value creates narrower bands and may produce more frequent signals.

### Period

Defines the number of candles used in the Linear Regression calculation.

Lower periods react faster to recent price changes but may generate more market noise. Higher periods create smoother channels but react more slowly.

### Spread Percentages

Displays the percentage movement between detected peaks and troughs.

This can help traders estimate the size of recent market swings.

### Extend Trendlines

Extends the regression channel to the right side of the chart.

The projected lines represent the continuation of the current regression structure and will change as new candles are added.

### Visible Signals

Shows or hides the circular long and short signal markers.

Disabling this option does not disable the alert conditions.

## Alerts

The indicator provides alert conditions for:

* Long entry
* Short entry
* Peak detected
* Trough detected

Dynamic long and short alerts may also include:

* Ticker symbol
* Current price
* Quantity
* Stop-loss level
* Take-profit level

To create an alert, add the indicator to the chart, open TradingView’s alert menu, select the indicator, and choose the required alert condition.

For more reliable confirmation, alerts may be configured to trigger once per bar close.

## Recommended Usage

The indicator may be more effective when used with:

* Higher-timeframe trend analysis
* Support and resistance levels
* Volume confirmation
* Market structure
* Appropriate position sizing
* Candle-close confirmation

It is recommended to test different Period and Deviation settings because every market and timeframe has different volatility characteristics.

## Important Notes

The projected stop-loss and take-profit levels are visual reference levels only. The indicator does not automatically execute trades or manage positions.

Regression channels and signals can change as new market data becomes available. Projected trendlines should not be treated as fixed future levels.

No indicator can predict every market movement or eliminate false signals. Always test the indicator using historical data, paper trading, and your own trading plan before using it in live markets.

## Disclaimer

This indicator is provided for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Trading involves substantial risk, and past performance does not guarantee future results. Users are responsible for their own trading decisions and risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Crypto_Zombianz

//@version=6
indicator('Regression Pulse Trend Suite [Crypto_Zombianz]', overlay = true)

// VALUE
var top = float(na)
var bottom = float(na)
var above = float(na)
var below = float(na)
var line median = na
var line resistance = na
var line support = na
var line higher = na
var line lower = na
var line limit = na
line.delete(median[1])
line.delete(resistance[1])
line.delete(support[1])
line.delete(higher[1])
line.delete(lower[1])
line.delete(limit[1])
position = input.string('Auto', 'Position', options = ['Auto', 'Auto Long', 'Auto Short', 'Fixed', 'Fixed Long', 'Fixed Short'])
quantity = input.float(50, 'Quantity')
profit = input.float(1.2, 'Take Profit', minval = 0.1, group = 'Risk & Reward')
loss = input.string('ATR', 'Stop Loss', options = ['ATR', 'ATR x 2', 'HHLL'], group = 'Risk & Reward')
factor = input.float(1.5, 'Deviation', minval = 0.5, group = 'Trendline')
period = input.int(100, 'Period', minval = 5, group = 'Trendline')
spread = input.bool(true, 'Spread Percentages', group = 'Visibility')
extend = input.bool(true, 'Extend Trendlines', group = 'Visibility') ? extend.right : extend.none
signal = input.bool(false, 'Visible Signals', group = 'Visibility')

// DIRECTION
up = open > close and open[1] < close[1]
down = open < close and open[1] > close[1]

// LEVEL
peak = up and high > above
trough = down and low < below

// THRESHOLD
if up
    above := high
    above
if down
    below := low
    below

// ATR
atr = ta.atr(14)

// LINEAR REGRESSION
x = 0.0
y = 0.0
x2 = 0.0
y2 = 0.0
xy = 0.0
index = period - 1
for i = 0 to index by 1
    c = nz(close[i])
    x := x + i
    y := y + c
    x2 := x2 + i * i
    y2 := y2 + c * c
    xy := xy + c * i
    xy
sx = math.pow(x, 2.0)
sy = math.pow(y, 2.0)
pearson = (xy - x * y / period) / (math.sqrt(x2 - sx / period) * math.sqrt(y2 - sy / period))
xx = x * x
slope = x2 == xx ? 0.0 : (period * xy - x * y) / (period * x2 - xx)
linreg = (y - slope * x) / period
intercept = linreg + bar_index * slope
deviation = 0.0
for i = 0 to index by 1
    deviation := deviation + math.pow(nz(close[i]) - (intercept - slope * bar_index[i]), 2.0)
    deviation
deviation := math.sqrt(deviation / index) * factor
point = linreg + slope * index

// PRICE
price(value) =>
    value > 10.0 ? str.format('{0,number,#.##}', value) : str.tostring(value)

// CONDITION
short = peak and ta.crossunder(close, linreg + deviation)
long = trough and ta.crossover(close, linreg - deviation)

// SPREAD
if spread
    if peak
        label.new(bar_index, na, str.format('{0,number,#.##}', (high - bottom) / high * 100), yloc = yloc.abovebar, style = label.style_none, textcolor = color.red)
        top := high
        top
    if trough
        label.new(bar_index, na, str.format('{0,number,#.##}', (top - low) / top * 100), yloc = yloc.belowbar, style = label.style_none, textcolor = color.blue)
        bottom := low
        bottom

// SIGNAL
if barstate.islast
    if short and (position == 'Auto' or position == 'Auto Short' ? linreg < point : position == 'Fixed' or position == 'Fixed Short')
        risk = math.max(high[0], high[1], high[2]) + (loss == 'ATR' ? atr : loss == 'ATR x 2' ? atr * 2 : 0)
        reward = open - (risk - open) * profit
        limit := line.new(bar_index, risk, bar_index + 20, risk, color = color.red, width = 2, style = line.style_dotted)
        alert('Short\nTicker ' + syminfo.ticker + '\nPrice ' + str.tostring(close) + '\nQuantity ' + str.tostring(quantity) + '\nSL ' + price(risk) + '\nTP ' + price(reward), alert.freq_once_per_bar)
    if long and (position == 'Auto' or position == 'Auto Long' ? linreg > point : position == 'Fixed' or position == 'Fixed Long')
        risk = math.min(low[0], low[1], low[2]) - (loss == 'ATR' ? atr : loss == 'ATR x 2' ? atr * 2 : 0)
        reward = open + (open - risk) * profit
        limit := line.new(bar_index, risk, bar_index + 20, risk, color = color.blue, width = 2, style = line.style_dotted)
        alert('Long\nTicker ' + syminfo.ticker + '\nPrice ' + str.tostring(close) + '\nQuantity ' + str.tostring(quantity) + '\nSL ' + price(risk) + '\nTP ' + price(reward), alert.freq_once_per_bar)

// DRAW
median := line.new(bar_index - period + 1, point, bar_index, linreg, xloc.bar_index, extend, pearson < 0 ? color.lime : color.aqua, line.style_dotted, 2)
resistance := line.new(bar_index - period + 1, point + deviation, bar_index, linreg + deviation, xloc.bar_index, extend, color.red, line.style_dashed, 2)
support := line.new(bar_index - period + 1, point - deviation, bar_index, linreg - deviation, xloc.bar_index, extend, color.blue, line.style_dashed, 2)
higher := line.new(bar_index - period + 1, point + deviation / 2, bar_index, linreg + deviation / 2, xloc.bar_index, extend, color.red, line.style_dotted, 1)
lower := line.new(bar_index - period + 1, point - deviation / 2, bar_index, linreg - deviation / 2, xloc.bar_index, extend, color.blue, line.style_dotted, 1)
ribbon = ta.ema(close, 24) > ta.ema(close, 8) ? color.aqua : color.lime
plot(ta.ema(close, 8), color = color.new(ribbon, 40), title = 'EMA 8')
plot(ta.ema(close, 12), color = color.new(ribbon, 50), title = 'EMA 12')
plot(ta.ema(close, 16), color = color.new(ribbon, 60), title = 'EMA 16')
plot(ta.ema(close, 20), color = color.new(ribbon, 70), title = 'EMA 20')
plot(ta.ema(close, 24), color = color.new(ribbon, 80), title = 'EMA 24')
plotshape(short and signal, style = shape.circle, color = color.red, location = location.abovebar, size = size.tiny, title = 'Short')
plotshape(long and signal, style = shape.circle, color = color.blue, location = location.belowbar, size = size.tiny, title = 'Long')
plotshape(peak and (short == false or signal == false), style = shape.xcross, color = color.red, location = location.abovebar, size = size.tiny, title = 'Peak')
plotshape(trough and (long == false or signal == false), style = shape.diamond, color = color.blue, location = location.belowbar, size = size.tiny, title = 'Trough')
fill(plot((open + close) / 2, display = display.none), plot(ta.ema(close, 24), display = display.none), color = color.new(ribbon, 96))


// ENTRY POINT
alertcondition(short, title = 'Short', message = 'Entry Short')
alertcondition(long, title = 'Long', message = 'Entry Long')

// Alerts for Peak and Trough
alertcondition(peak, title = 'Peak', message = 'Peak Detected')
alertcondition(trough, title = 'Trough', message = 'Trough Detected')
````
