# Super-trend Signal Engine Quantum Edge

- url: https://www.tradingview.com/script/9VZKhSFJ-Super-trend-Signal-Engine-Quantum-Edge/
- type: strategy
- pine_id: PUB;3e32ab526fd84c02ad0400a1b0e1bcba
- version: 1.0

## Description

Short description
ATR-based Supertrend strategy that flips long or short on confirmed trend reversals, with optional signal labels, trend highlighting, bar coloring, and built-in date-range backtesting.

Description
Signal Engine Quantum Edge is a public Supertrend-based strategy built to track volatility-adjusted trend shifts and execute long or short entries when trend direction flips. The script uses ATR-expanded bands around hl2, then updates those bands as price develops so the strategy can detect reversals and stay aligned with the active move. TradingView describes Supertrend as a trend-following tool built from ATR and price-based bands, where changes in the line’s position relative to price signal shifts in trend direction.

How it works
Calculates ATR using either the built-in ATR method or an alternative SMA-of-true-range method.

Builds dynamic upper and lower trend bands from price and ATR.

Triggers a long entry when trend flips from bearish to bullish.

Triggers a short entry when trend flips from bullish to bearish.

Restricts entries to the user-defined backtest date window.

This strategy follows the same general Supertrend logic TradingView documents for reversal-based entries, where long positions begin when the trend changes from above price to below price, and short positions begin on the opposite transition.

Inputs
ATR Period — default 10.

ATR Multiplier — default 3.0.

Source — default hl2.

Change ATR Calculation Method? — switch between built-in ATR and SMA-of-TR.

Show Buy/Sell Signals? — toggle signal labels.

Highlighter On/Off? — toggle trend fill shading.

Bar Coloring On/Off? — color candles by active trend.

From / To Date — define the backtest window.

Visual features
Green Supertrend line and fills for bullish phases.

Red Supertrend line and fills for bearish phases.

Optional Buy/Sell labels at trend flips.

Bar coloring to reflect the most recent active signal.

Usage notes
This is a strategy, not an indicator, so it uses strategy.entry() to simulate long and short trades directly from reversal signals.

Like most Supertrend systems, it is designed for trending conditions and can produce false signals during sideways or highly compressed markets, which TradingView also notes as a common limitation of Supertrend-based methods.

For more realistic testing, set commission, slippage, and position sizing in the strategy properties before evaluating results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quantum Edge


//@version=6
strategy('Signal Engine Quantum Edge', overlay = true)
Periods = input(title = 'ATR Period', defval = 10)
src = input(hl2, title = 'Source')
Multiplier = input.float(title = 'ATR Multiplier', step = 0.1, defval = 3.0)
changeATR = input(title = 'Change ATR Calculation Method ?', defval = true)
showsignals = input(title = 'Show Buy/Sell Signals ?', defval = false)
highlighting = input(title = 'Highlighter On/Off ?', defval = true)
barcoloring = input(title = 'Bar Coloring On/Off ?', defval = true)
atr2 = ta.sma(ta.tr, Periods)
atr = changeATR ? ta.atr(Periods) : atr2
up = src - Multiplier * atr
up1 = nz(up[1], up)
up := close[1] > up1 ? math.max(up, up1) : up
dn = src + Multiplier * atr
dn1 = nz(dn[1], dn)
dn := close[1] < dn1 ? math.min(dn, dn1) : dn
trend = 1
trend := nz(trend[1], trend)
trend := trend == -1 and close > dn1 ? 1 : trend == 1 and close < up1 ? -1 : trend
upPlot = plot(trend == 1 ? up : na, title = 'Up Trend', style = plot.style_linebr, linewidth = 2, color = color.new(color.green, 0))
buySignal = trend == 1 and trend[1] == -1
plotshape(buySignal ? up : na, title = 'UpTrend Begins', location = location.absolute, style = shape.circle, size = size.tiny, color = color.new(color.green, 0))
plotshape(buySignal and showsignals ? up : na, title = 'Buy', text = 'Buy', location = location.absolute, style = shape.labelup, size = size.tiny, color = color.new(color.green, 0), textcolor = color.new(color.white, 0))
dnPlot = plot(trend == 1 ? na : dn, title = 'Down Trend', style = plot.style_linebr, linewidth = 2, color = color.new(color.red, 0))
sellSignal = trend == -1 and trend[1] == 1
plotshape(sellSignal ? dn : na, title = 'DownTrend Begins', location = location.absolute, style = shape.circle, size = size.tiny, color = color.new(color.red, 0))
plotshape(sellSignal and showsignals ? dn : na, title = 'Sell', text = 'Sell', location = location.absolute, style = shape.labeldown, size = size.tiny, color = color.new(color.red, 0), textcolor = color.new(color.white, 0))
mPlot = plot(ohlc4, title = '', style = plot.style_circles, linewidth = math.max(1, 0))
longFillColor = highlighting ? trend == 1 ? color.green : color.white : color.white
shortFillColor = highlighting ? trend == -1 ? color.red : color.white : color.white
fill(mPlot, upPlot, title = 'UpTrend Highligter', color = longFillColor)
fill(mPlot, dnPlot, title = 'DownTrend Highligter', color = shortFillColor)
FromMonth = input.int(defval = 9, title = 'From Month', minval = 1, maxval = 12)
FromDay = input.int(defval = 1, title = 'From Day', minval = 1, maxval = 31)
FromYear = input.int(defval = 2018, title = 'From Year', minval = 999)
ToMonth = input.int(defval = 1, title = 'To Month', minval = 1, maxval = 12)
ToDay = input.int(defval = 1, title = 'To Day', minval = 1, maxval = 31)
ToYear = input.int(defval = 9999, title = 'To Year', minval = 999)
start = timestamp(FromYear, FromMonth, FromDay, 00, 00)
finish = timestamp(ToYear, ToMonth, ToDay, 23, 59)
window() =>
    time >= start and time <= finish ? true : false
longCondition = buySignal
if longCondition
    if window()
        strategy.entry('BUY', strategy.long)
shortCondition = sellSignal
if shortCondition
    if window()
        strategy.entry('SELL', strategy.short)
buy1 = ta.barssince(buySignal)
sell1 = ta.barssince(sellSignal)
color1 = buy1[1] < sell1[1] ? color.green : buy1[1] > sell1[1] ? color.red : na
barcolor(barcoloring ? color1 : na)
````
