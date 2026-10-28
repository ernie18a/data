# S&R Breakout ATR Confirmation

- url: https://www.tradingview.com/script/4l1CWzgW-S-R-Breakout-ATR-Confirmation/
- type: indicator
- pine_id: PUB;95558c2eac1c44e79f0792745e59c81a
- version: 2.0

## Description

[b]Overview[/b]

S&R Breakout ATR Confirmation is a breakout confirmation indicator designed to help traders identify high-probability breakouts from key Support and Resistance levels. Instead of signaling every price breakout, it combines **ATR-based momentum** with an optional Volume confirmation filter to reduce false signals.

The indicator automatically plots dynamic Support and Resistance levels based on a user-defined lookback period and generates BUY or SELL signals only when the breakout meets the selected confirmation criteria.

[b]Features[/b]

* Automatic Support & Resistance detection
* ATR-based breakout strength confirmation
* Optional Volume confirmation filter
* BUY and SELL breakout signals
* Clean Support & Resistance plotting
* Background highlights for confirmed breakout candles
* Built-in alert conditions for bullish and bearish breakouts
* Fully customizable inputs

[b]Inputs[/b]

* **Support/Resistance Length:** Number of bars used to calculate Support and Resistance.
* **ATR Length:** ATR calculation period.
* **ATR Strength Multiplier:** Minimum candle size relative to ATR required for confirmation.
* **Use Volume Filter:** Enable or disable volume confirmation.
* **Volume MA Length:** Moving average period for volume.

[b]How It Works[/b]

[b]BUY Signal
A BUY signal is generated when:[/b]

* Price closes above the previous Resistance level.
* Bullish candle size exceeds the ATR strength threshold.
* Volume is above its moving average (if the Volume Filter is enabled).

[b]SELL Signal
A SELL signal is generated when:[/b]

* Price closes below the previous Support level.
* Bearish candle size exceeds the ATR strength threshold.
* Volume is above its moving average (if the Volume Filter is enabled).

[b]Alerts[/b]
The indicator includes ready-to-use TradingView alerts for:

* Bullish Breakout
* Bearish Breakout

[b]Best Markets[/b]

* Forex
* Stocks
* Indices
* Commodities
* Cryptocurrency

[b]Disclaimer[/b]

This indicator is intended for educational and analytical purposes only. No indicator guarantees profitable trades. Always use proper risk management and combine this tool with your own market analysis before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator('S&R Breakout ATR Confirmation', overlay = true, max_labels_count = 500)

// Inputs
lookback = input.int(20, 'Support/Resistance Length', minval = 5)
atrLength = input.int(14, 'ATR Length')
atrMultiplier = input.float(1.0, 'ATR Strength Multiplier', step = 0.1)

useVolume = input.bool(true, 'Use Volume Filter')
volumeLength = input.int(20, 'Volume MA Length')

// Support & Resistance
resistance = ta.highest(high, lookback)[1]
support = ta.lowest(low, lookback)[1]

// ATR Filter
atr = ta.atr(atrLength)
bullStrength = close - open > atr * atrMultiplier
bearStrength = open - close > atr * atrMultiplier

// Volume Filter
volMA = ta.sma(volume, volumeLength)
volumeConfirm = volume > volMA

// Breakout Conditions
bullBreakout = close > resistance and bullStrength and (not useVolume or volumeConfirm)
bearBreakout = close < support and bearStrength and (not useVolume or volumeConfirm)

// Plot Levels
plot(resistance, 'Resistance', color = color.red, linewidth = 2)
plot(support, 'Support', color = color.green, linewidth = 2)

// Signals
plotshape(bullBreakout, title = 'BUY', location = location.belowbar, style = shape.labelup, color = color.lime, text = 'BUY')

plotshape(bearBreakout, title = 'SELL', location = location.abovebar, style = shape.labeldown, color = color.red, text = 'SELL')

// Background Trend
bgcolor(bullBreakout ? color.new(color.green, 90) : na)
bgcolor(bearBreakout ? color.new(color.red, 90) : na)

// Alerts
alertcondition(bullBreakout, title = 'Bullish Breakout', message = 'Breakout Confirmation Pro BUY Signal')

alertcondition(bearBreakout, title = 'Bearish Breakout', message = 'Breakout Confirmation Pro SELL Signal')
````
