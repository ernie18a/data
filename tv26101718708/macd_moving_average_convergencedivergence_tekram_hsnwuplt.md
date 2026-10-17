# MACD Moving Average Convergence/Divergence - TeKrAm

- url: https://www.tradingview.com/script/HsnWuPLT-MACD-Moving-Average-Convergence-Divergence-TeKrAm/
- type: indicator
- pine_id: PUB;441129d082b048ce867a95a2ceddd9b8
- version: 1.0

## Description

MACD - TeKrAm is a customized MACD indicator designed to make momentum, zero-line shifts, and signal-line crosses easier to read visually.

This version includes:

• Dynamic MACD line coloring
• Dynamic signal line coloring
• MACD/signal fill zone
• Zero-line color shift
• Histogram momentum coloring
• Background highlights for MACD zero-line crosses
• Background highlights for MACD/signal crosses
• Circle markers for zero-line and signal-line cross events
• Alert conditions for all major MACD cross events

The indicator is built for traders who want a clearer visual read on momentum transitions, trend bias, and MACD cross signals directly inside the MACD panel.

Alerts included:

• MACD crosses above zero
• MACD crosses below zero
• MACD crosses above signal line
• MACD crosses below signal line

This tool is for technical analysis and educational use only. It does not guarantee future results and should not be used as financial advice.

## Source Code

````pine
//@version=5
indicator("MACD Moving Average Convergence/Divergence - TeKrAm", shorttitle="MACD - TeKrAm", overlay=false, timeframe="")

// Input Parameters
fast_length = input.int(12, title="Fast Length")
slow_length = input.int(26, title="Slow Length")
src = input.source(close, title="Source")
signal_length = input.int(9, title="Signal Smoothing", minval=1, maxval=50)
sma_source = input.bool(false, title="Simple MA (Oscillator)")
sma_signal = input.bool(false, title="Simple MA (Signal Line)")

// MACD Calculation
fast_ma = sma_source ? ta.sma(src, fast_length) : ta.ema(src, fast_length)
slow_ma = sma_source ? ta.sma(src, slow_length) : ta.ema(src, slow_length)
macd = fast_ma - slow_ma
signal = sma_signal ? ta.sma(macd, signal_length) : ta.ema(macd, signal_length)
hist = macd - signal

// Color Definitions for MACD and Signal Line Based on Crossing
macd_color = macd > signal and macd > 0 ? color.new(#17ff03, 0) : 
             macd > signal and macd < 0 ? color.new(#ff0000, 0) : 
             macd < signal and macd > 0 ? color.new(#01a208, 0) : 
             color.new(#b80606, 0)

signal_color = signal > macd and signal > 0 ? color.new(#0300ff, 0) : 
               signal > macd and signal < 0 ? color.new(#ff0000, 0) : 
               signal < macd and signal > 0 ? color.new(#0047ff, 0) : 
               color.new(#b80606, 0)

// Plot Signal Line with Dynamic Color
F1 = plot(signal, title="Signal", color=signal_color, linewidth=2)

// Plot MACD Line with Dynamic Color
F2 = plot(macd, title="MACD", color=macd_color, linewidth=2)

// Fill Color Based on MACD and Signal Cross
FilCol = macd > signal ? color.new(#17ff03, 80) : color.new(#ff0000, 80)
fill(F1, F2, title="MACD/Signal Fill", color=FilCol)

// Plot Zero Line
zero = 0
zero_color = macd >= 0 ? color.new(#00ff00, 0) : color.new(#ff0000, 0)
plot(zero, title="Zero", color=zero_color, linewidth=2, offset=1)

// Plot Zero Fill Line and Histogram
zerofill = macd > signal ? (macd > zero ? (signal > zero ? signal : zero) : (signal > zero ? zero : macd)) : (macd > zero ? (signal > zero ? macd : zero) : (signal > zero ? zero : signal))
col_zero = zerofill > zero ? color.new(#9800ff, 80) : color.new(#0300ff, 80)
plot(zerofill, title="Zero Fill Line", style=plot.style_area, color=col_zero)

plot(hist, title="Histogram", style=plot.style_columns, color=(hist >= 0 ? (hist[1] < hist ? color.new(#01a208, 0) : color.new(#1b5e20, 0)) : (hist[1] < hist ? color.new(#890202, 0) : color.new(#b80606, 0))))

// Background Color for Zero Line Crossovers
Cross1 = ta.crossover(macd, zero) ? color.new(#17ff03, 0) : na
Cross2 = ta.crossunder(macd, zero) ? color.new(#ff0000, 0) : na
bgcolor(Cross1, title="Cross Over Zero")
bgcolor(Cross2, title="Cross Under Zero")

// Full Background Color for the Indicator Space
bg_color = macd > zero ? color.new(#17ff03, 90) : color.new(#ff0000, 90)
bgcolor(bg_color, transp=85)

// MACD Cross Above/Below Zero Line
macdCrossAboveZero = ta.crossover(macd, zero)
macdCrossBelowZero = ta.crossunder(macd, zero)

// Plot MACD Zero Line Cross Signals (in the MACD window)
plot(macdCrossAboveZero ? macd : na, color=color.green, style=plot.style_circles, linewidth=4, title="MACD Cross Above Zero")
plot(macdCrossBelowZero ? macd : na, color=color.red, style=plot.style_circles, linewidth=4, title="MACD Cross Below Zero")

// MACD Cross Above/Below Signal Line
macdCrossAboveSignal = ta.crossover(macd, signal)
macdCrossBelowSignal = ta.crossunder(macd, signal)

// Plot MACD Signal Line Cross Signals (in the MACD window)
plot(macdCrossAboveSignal ? macd : na, color=color.green, style=plot.style_circles, linewidth=4, title="MACD Cross Above Signal")
plot(macdCrossBelowSignal ? macd : na, color=color.red, style=plot.style_circles, linewidth=4, title="MACD Cross Below Signal")

// Background Color for MACD Cross Signal Line
bgCrossUp = ta.crossover(macd, signal) ? color.new(#00ff00, 80) : na
bgCrossDown = ta.crossunder(macd, signal) ? color.new(#ff0000, 80) : na
bgcolor(bgCrossUp, title="BG MACD Cross Up")
bgcolor(bgCrossDown, title="BG MACD Cross Down")

// Alerts
alertcondition(macdCrossAboveZero, "MACD Above Zero Line Alert", "MACD has crossed above the zero line")
alertcondition(macdCrossBelowZero, "MACD Below Zero Line Alert", "MACD has crossed below the zero line")
alertcondition(macdCrossAboveSignal, "MACD Above Signal Line Alert", "MACD has crossed above the signal line")
alertcondition(macdCrossBelowSignal, "MACD Below Signal Line Alert", "MACD has crossed below the signal line")
````
