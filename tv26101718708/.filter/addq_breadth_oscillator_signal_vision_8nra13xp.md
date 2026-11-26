# ADDQ Breadth Oscillator [Signal Vision]

- url: https://www.tradingview.com/script/8NrA13Xp-ADDQ-Breadth-Oscillator-Signal-Vision/
- type: indicator
- pine_id: PUB;6be5adc852804a0cbb43ca38e2901328
- version: 1.0

## Description

[b]ADDQ Breadth Oscillator [by: Signal Vision][/b]

📊 ADDQ Breadth Oscillator (Advanced Market Internal)
The ADDQ Breadth Oscillator is a momentum-based tool designed to visualize the internal health of the NASDAQ by tracking Net Advancing Issues (ADDQ).

Unlike standard price indicators, this oscillator looks "under the hood" of the market to see if price movement is supported by broad participation or if it’s being driven by just a few heavyweights.

🔍 How it Works

This indicator pulls the NASDAQ Advance-Decline Line (ADDQ) and processes it through a dual-EMA system to create a smoothed oscillator and a signal line. It measures the spread between the current breadth and its moving average, resulting in a responsive histogram that highlights shifts in market momentum.

🛡️ Smart Data Selection (Fail-safe)

One of the unique features of this script is its triple-source logic. Different TradingView data plans and brokers handle Breadth symbols differently. This script automatically checks:

NASDAQ:ADDQ

ADDQ (Generic)

ADVQ - DECLQ (Calculated manually from Advancing vs. Declining issues)

It will automatically use the best available source based on your data subscription, ensuring the indicator never returns a "blank" screen. A Debug Table in the top right confirms which source is currently active.

📈 Key Features

Momentum Histogram: A scaled histogram that shows the acceleration or deceleration of market breadth.

Trend Ribbon: The area between the ADDQ line and the Signal line changes color (Teal/Red) to indicate the short-term internal trend.

Extreme Levels: Horizontal dashed lines at +/- 1500 (customizable) highlight overbought or oversold breadth conditions.

Crossover Signals: Visual shapes appear on the chart when the breadth line crosses its signal line, marking potential entry or exit points.

🛠️ How to Use

Bullish Confirmation: Look for the ADDQ line to cross above the Signal line while the histogram turns bright teal.

Overextended Markets: When the background turns teal or red, the NASDAQ is reaching extreme breadth levels (+/- 1500). These are often areas where the market is prone to mean reversion or a temporary pause.

Divergence: If price is making new highs but the ADDQ Oscillator is making lower highs, it suggests the rally is losing participation.

⚙️ Settings

Signal Length: Adjust the smoothness of the yellow signal line.

Histogram Scale: Since ADDQ values are large, use this to make the histogram bars more or less prominent.

Extreme Level: Customize the threshold for "Extreme" market conditions based on current volatility.

Note: This indicator requires access to NASDAQ Market Internals data. If the debug table shows "no data," ensure you have the appropriate NASDAQ data package or are using a broker feed that supports breadth symbols.

## Source Code

````pine
//@version=6
indicator("ADDQ Breadth Oscillator", shorttitle="ADDQ OSC", format=format.price, precision=0)

sig_len   = input.int(9,  "Signal Length",     minval=1, group="Signal")
hist_mult = input.int(15, "Histogram Scale",   minval=1, maxval=100, group="Signal", tooltip="Multiplies histogram bars so they are visible against the ADDQ scale")
lvl_ext   = input.int(1500, "Extreme Level +/-", group="Levels")

// Try three ways to get ADDQ data
v1 = request.security("NASDAQ:ADDQ",  "1", close, ignore_invalid_symbol=true)
v2 = request.security("ADDQ",         "1", close, ignore_invalid_symbol=true)
v3 = request.security("NASDAQ:ADVQ",  "1", close, ignore_invalid_symbol=true) - request.security("NASDAQ:DECLQ", "1", close, ignore_invalid_symbol=true)

// Use whichever source has data
addq_raw = not na(v1) ? v1 : not na(v2) ? v2 : v3

addq   = ta.ema(addq_raw, 3)
signal = ta.ema(addq, sig_len)
hist   = addq - signal

// Colors
bull = #00c9a7
bear = #ff5252

hist_col   = hist >= 0 ? (hist >= hist[1] ? color.new(bull, 10) : color.new(bull, 58)) : (hist <= hist[1] ? color.new(bear, 10) : color.new(bear, 58))
addq_col   = addq >= signal ? bull : bear

// Plots
hist_scaled = hist * hist_mult
plot(hist_scaled, "Histogram", style=plot.style_histogram, color=hist_col, linewidth=4)
p1 = plot(addq,   "ADDQ",   color=addq_col,            linewidth=2)
p2 = plot(signal, "Signal", color=#ffd54f,             linewidth=1)
fill(p1, p2, color=addq >= signal ? color.new(bull, 85) : color.new(bear, 85))

hline(0,        color=color.new(color.white, 70), linewidth=1)
hline( lvl_ext, color=color.new(bull, 60), linestyle=hline.style_dashed)
hline(-lvl_ext, color=color.new(bear, 60), linestyle=hline.style_dashed)

bgcolor(addq >  lvl_ext ? color.new(bull, 92) : na)
bgcolor(addq < -lvl_ext ? color.new(bear, 92) : na)

// Crossovers -- anchored to the ADDQ line
bull_x = ta.crossover(addq,  signal)
bear_x = ta.crossunder(addq, signal)
offset = lvl_ext * 0.06
plotshape(bull_x ? addq - offset : na, style=shape.triangleup,   location=location.absolute, color=bull, size=size.small, title="Bull Cross")
plotshape(bear_x ? addq + offset : na, style=shape.triangledown, location=location.absolute, color=bear, size=size.small, title="Bear Cross")

// Debug table -- tells you exactly which data source is working
var table dbg = table.new(position.top_right, 2, 5, bgcolor=color.new(#0d111a, 70), border_color=color.new(color.white, 80), border_width=1)
if barstate.islast
    ok  = color.new(#00c9a7, 20)
    err = color.new(#ff5252, 20)
    table.cell(dbg, 0, 0, "Source",          text_color=color.new(color.white, 40), text_size=size.small)
    table.cell(dbg, 1, 0, "Value",           text_color=color.new(color.white, 40), text_size=size.small)
    table.cell(dbg, 0, 1, "NASDAQ:ADDQ",     text_color=color.white, text_size=size.small)
    table.cell(dbg, 1, 1, na(v1) ? "no data" : str.tostring(math.round(v1)), bgcolor=na(v1) ? err : ok, text_color=color.white, text_size=size.small)
    table.cell(dbg, 0, 2, "ADDQ",            text_color=color.white, text_size=size.small)
    table.cell(dbg, 1, 2, na(v2) ? "no data" : str.tostring(math.round(v2)), bgcolor=na(v2) ? err : ok, text_color=color.white, text_size=size.small)
    table.cell(dbg, 0, 3, "ADVQ-DECLQ",      text_color=color.white, text_size=size.small)
    table.cell(dbg, 1, 3, na(v3) ? "no data" : str.tostring(math.round(v3)), bgcolor=na(v3) ? err : ok, text_color=color.white, text_size=size.small)
    table.cell(dbg, 0, 4, "Using",           text_color=color.white, text_size=size.small)
    table.cell(dbg, 1, 4, na(addq_raw) ? "NONE - check plan" : not na(v1) ? "NASDAQ:ADDQ" : not na(v2) ? "ADDQ" : "ADVQ-DECLQ", bgcolor=na(addq_raw) ? err : ok, text_color=color.white, text_size=size.small)
````
