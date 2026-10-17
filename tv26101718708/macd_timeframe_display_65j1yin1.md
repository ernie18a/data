# MACD + Timeframe Display

- url: https://www.tradingview.com/script/65J1yIn1-MACD-Timeframe-Display/
- type: indicator
- pine_id: PUB;835567883f4b477698b1be8bd4ea47e0
- version: 2.0

## Description

Have you ever maximized your MACD pane to get a closer look at a crossover, only to realize the top toolbar disappeared and you forgot exactly which timeframe you were analyzing?

This indicator solves that frustrating UI quirk.

This script is a 1:1 replica of TradingView’s standard built-in MACD, but with one major quality-of-life upgrade: it features a dynamic, built-in display table in the top right corner of the indicator pane that continuously tracks your active chart timeframe.

Because the text is drawn directly onto the indicator's canvas, it stays perfectly visible even when the pane is double-clicked and maximized.

Key Features:

Classic MACD Math: Uses the exact same calculations, inputs, and histogram color schemes as the default TradingView MACD. Your signals and familiar aesthetics remain completely unchanged.

Smart Timeframe Formatting: Automatically detects your active timeframe and converts raw minutes into a clean, human-readable format. Instead of displaying "60" or "240", it dynamically formats the text to "1H", "4H", "15m", "1D", etc.

Unobtrusive UI: The timeframe is displayed in a clean, semi-transparent box in the top right corner of the pane, ensuring it doesn't block your view of the moving averages or histogram.

How to use:
Simply add it to your chart, replace your old MACD, and customize your moving average lengths just like you normally would. The timeframe display is entirely automatic!

## Source Code

````pine
//@version=6
indicator("MACD + Timeframe Display", shorttitle="MACD+TF")

// --- Timeframe Formatting Function ---
format_tf() =>
    string res = timeframe.period
    if timeframe.isintraday
        int mins = int(str.tonumber(timeframe.period))
        if mins >= 60 and mins % 60 == 0
            res := str.tostring(int(mins / 60)) + "H"
        else
            res := str.tostring(mins) + "m"
    else if timeframe.isdaily
        res := timeframe.period == "D" ? "1D" : timeframe.period
    else if timeframe.isweekly
        res := timeframe.period == "W" ? "1W" : timeframe.period
    else if timeframe.ismonthly
        res := timeframe.period == "M" ? "1M" : timeframe.period
    res

// --- Standard MACD Inputs & Calculations ---
fast_length = input.int(title="Fast Length", defval=12)
slow_length = input.int(title="Slow Length", defval=26)
src = input.source(title="Source", defval=close)
signal_length = input.int(title="Signal Smoothing", minval=1, maxval=50, defval=9)
sma_source = input.string(title="Oscillator MA Type", defval="EMA", options=["SMA", "EMA"])
sma_signal = input.string(title="Signal Line MA Type", defval="EMA", options=["SMA", "EMA"])

fast_ma = sma_source == "SMA" ? ta.sma(src, fast_length) : ta.ema(src, fast_length)
slow_ma = sma_source == "SMA" ? ta.sma(src, slow_length) : ta.ema(src, slow_length)
macd = fast_ma - slow_ma
signal = sma_signal == "SMA" ? ta.sma(macd, signal_length) : ta.ema(macd, signal_length)
hist = macd - signal

// --- Plotting Standard MACD ---
hline(0, "Zero Line", color=color.new(#c1c2c6, 50))
hist_color = hist >= 0 ? (hist[1] < hist ? #26A69A : #B2DFDB) : (hist[1] < hist ? #FFCDD2 : #FF5252)
plot(hist, title="Histogram", style=plot.style_columns, color=hist_color)
plot(macd, title="MACD", color=#2962FF)
plot(signal, title="Signal", color=#FF6D00)

// --- Timeframe Display Table ---
// CHANGED: position.top_right is now position.bottom_right
var table tfTable = table.new(position.bottom_right, 1, 1, bgcolor=color.new(color.black, 70), frame_width=1, frame_color=color.new(color.gray, 50))

if barstate.islast
    table.cell(tfTable, 0, 0, format_tf(), text_color=color.rgb(0, 0, 0), text_size=size.large)
````
