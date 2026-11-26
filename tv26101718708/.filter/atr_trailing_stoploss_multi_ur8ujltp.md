# ATR Trailing Stoploss [Multi]

- url: https://www.tradingview.com/script/ur8ujLTP-ATR-Trailing-Stoploss-Multi/
- type: indicator
- pine_id: PUB;6ab8a1a9c9e646cdba8e69e965326a84
- version: 1.0

## Description

ATR Trailing Stoploss [Multi]
This indicator plots five ATR-based trailing stop lines on your chart at once, giving you a layered view of volatility-adjusted support and resistance instead of a single stop level.
What it does
Each line is a trailing stoploss derived from the Average True Range (ATR). For every line it takes the recent high, subtracts a multiple of ATR, and tracks the highest such value over a lookback window. The result is a stop level that sits below price in uptrends and adapts as volatility expands or contracts. Plotting five of them together lets you see short-term and long-term stops simultaneously — faster lines hug price for tight exits, slower lines define the broader trend structure.
Two modes
Multi-Period (default): All five lines are calculated on your current chart timeframe using different ATR lengths (5, 10, 20, 40, 80 by default). Every line updates on every candle and moves smoothly with the bars, so you get five sensitivities — from scalping-tight to position-wide — on a single timeframe.
Multi-Timeframe: Each line is instead pulled from a higher timeframe (e.g. 5m, 15m, 1H, 4H, Daily) via request.security. This shows where the stop sits on larger timeframes while you trade a smaller one. Note that, by nature, each higher-timeframe line appears as a flat step that only changes when its timeframe closes a bar.
Inputs
You can set the ATR length for each of the five lines, the HHV lookback period, and the ATR multiplier (shared across lines). In Multi-Timeframe mode you choose the timeframe for each line and can optionally allow the live higher-timeframe bar to update in real time (repaint) or restrict to confirmed values only (non-repainting, default).
Signals and bar coloring
Bars are colored green when price is above Line 1's stop and red when below. Buy/Sell labels and alerts trigger when price crosses Line 1, so you can attach TradingView alerts to the fastest stop while using the slower lines as trend context.
How to use it
Treat the lines as a stack of dynamic stops: price holding above the cluster signals a healthy trend, while breaks through successive lines flag weakening momentum. Use the tighter lines for trade management and the wider lines to gauge whether the larger trend is still intact.
This script is a tool for analysis and does not constitute financial advice. Always test on your own instruments and timeframes before trading.

## Source Code

````pine
//@version=6
indicator('ATR Trailing Stoploss [Multi]', overlay = true)

// ============================================================================
// MODE
//   "Multi-Period"     -> all 5 lines computed on the CHART timeframe with
//                         different ATR lengths. Every line moves with every
//                         candle (no flat stair-steps). RECOMMENDED.
//   "Multi-Timeframe"  -> each line pulled from a higher timeframe via
//                         request.security (lines are flat across each HTF bar).
// ============================================================================
mode = input.string('Multi-Period', title = 'Mode', options = ['Multi-Period', 'Multi-Timeframe'], group = 'General')

// Shared params
Hhv = input.int(defval = 10, title = 'HHV Period', minval = 1, maxval = 500, group = 'ATR Settings')
Mult = input.float(defval = 2.5, title = 'Multiplier', minval = 0.1, group = 'ATR Settings')

// ----------------------------------------------------------------------------
// Per-line ATR lengths (used in BOTH modes as the ATR period of each line)
// ----------------------------------------------------------------------------
a1 = input.int(5, title = 'Line 1 ATR len', minval = 1, group = 'Lines')
a2 = input.int(10, title = 'Line 2 ATR len', minval = 1, group = 'Lines')
a3 = input.int(20, title = 'Line 3 ATR len', minval = 1, group = 'Lines')
a4 = input.int(40, title = 'Line 4 ATR len', minval = 1, group = 'Lines')
a5 = input.int(80, title = 'Line 5 ATR len', minval = 1, group = 'Lines')

// Timeframes (only used in Multi-Timeframe mode)
tf1 = input.timeframe('5', title = 'Line 1 TF', group = 'Timeframes (MTF mode)')
tf2 = input.timeframe('15', title = 'Line 2 TF', group = 'Timeframes (MTF mode)')
tf3 = input.timeframe('60', title = 'Line 3 TF', group = 'Timeframes (MTF mode)')
tf4 = input.timeframe('240', title = 'Line 4 TF', group = 'Timeframes (MTF mode)')
tf5 = input.timeframe('D', title = 'Line 5 TF', group = 'Timeframes (MTF mode)')

allowRepaint = input.bool(false, title = 'MTF: allow repaint (live HTF bar)', group = 'General')
barColorOn = input.bool(true, title = 'Color bars (Line 1 TS)', group = 'General')

// ============================================================================
// Core ATR Trailing Stoploss logic (parametrized by ATR length)
// ============================================================================
f_ts(_atrLen) =>
    base = high - Mult * ta.atr(_atrLen)
    highest = ta.highest(base, Hhv)
    iff_1 = close > highest and close > close[1] ? highest : highest
    ts = ta.cum(1) < 16 ? close : iff_1
    ts

// Pull a line's value according to the selected mode.
// request.security() must be called unconditionally (not inside if/else) and
// its lookahead arg must be a const, so we compute every variant and select.
f_line(_atrLen, _tf) =>
    chartTS = f_ts(_atrLen)
    htfNR = request.security(syminfo.tickerid, _tf, f_ts(_atrLen), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    htfRP = request.security(syminfo.tickerid, _tf, f_ts(_atrLen), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
    htfTS = allowRepaint ? htfRP : htfNR
    mode == 'Multi-Period' ? chartTS : htfTS

TS1 = f_line(a1, tf1)
TS2 = f_line(a2, tf2)
TS3 = f_line(a3, tf3)
TS4 = f_line(a4, tf4)
TS5 = f_line(a5, tf5)

// ============================================================================
// Plots — 5 distinct colored lines (bar-anchored, follow the candles)
// ============================================================================
plot(TS1, title = 'ATR TS 1', color = color.new(color.aqua, 0), linewidth = 2)
plot(TS2, title = 'ATR TS 2', color = color.new(color.lime, 0), linewidth = 2)
plot(TS3, title = 'ATR TS 3', color = color.new(color.orange, 0), linewidth = 2)
plot(TS4, title = 'ATR TS 4', color = color.new(color.fuchsia, 0), linewidth = 2)
plot(TS5, title = 'ATR TS 5', color = color.new(color.red, 0), linewidth = 2)

// ============================================================================
// Bar coloring + signals based on Line 1
// ============================================================================
TSsig = TS1
cColor = close > TSsig ? color.green : close < TSsig ? color.red : color.black
barcolor(barColorOn ? cColor : na)

Buy = ta.crossover(close, TSsig)
Sell = ta.crossunder(close, TSsig)

plotshape(Buy, 'BUY', shape.labelup, location.belowbar, color.new(color.green, 0), text = 'BUY', textcolor = color.new(color.black, 0), display = display.none)
plotshape(Sell, 'SELL', shape.labeldown, location.abovebar, color.new(color.red, 0), text = 'SELL', textcolor = color.new(color.black, 0), display = display.none)

alertcondition(Buy, 'Buy Signal', 'Buy ATR Trailing Stoploss')
alertcondition(Sell, 'Sell Signal', 'Sell ATR Trailing Stoploss')
````
