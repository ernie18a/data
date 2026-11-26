# Normalized Relative Volume Filter

- url: https://www.tradingview.com/script/zNVfYo7H-Normalized-Relative-Volume-Filter/
- type: indicator
- pine_id: PUB;c4623ac082f14abf9b056bfc31c20625
- version: 2.0

## Description

Analyzing raw volume bars can make it difficult to see if the current volume is truly significant. Every asset has a different baseline, and volume fluctuates constantly.

The Normalized Relative Volume Filter (NRVF) standardizes raw volume into a percentage relative to its moving average. This allows you to instantly gauge market interest and institutional presence regardless of the asset or timeframe.

This indicator sets a baseline using a Volume SMA (Default 20 period) which represents 100 percent. If the histogram hits 200, the current volume is exactly double the recent average. Significant moves are driven by above average volume. To keep your charts clean, this script automatically filters out and hides all below average volume under 100 percent. It only highlights the bars that actually matter. 

The histogram matches the price action with green for bullish candles and red for bearish candles so you can instantly see who is driving the volume spike.

When price breaks key levels, look for the histogram to surge well above the 100 percent baseline. Breakouts on below average volume are often fakeouts. You can also use it to confirm if an ongoing trend is backed by institutional participation, such as spikes reaching 150 percent or 200 percent or more.

You can adjust the lookback period for the baseline volume average using the Volume MA Length setting which defaults to 20.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rikyu04

//@version=6
indicator("Normalized Relative Volume Filter", shorttitle="NRVF", overlay=false)

// ==========================================
// Inputs & Settings
// ==========================================
volLength = input.int(20, title="Volume MA Length")
volSource = volume

// Calculate Base Moving Average
volMa = ta.sma(volSource, volLength)

// ==========================================
// Math: Normalize Volume to Percentage of its MA
// ==========================================
// 100.0 means volume is exactly at its 20-period average.
// 200.0 means volume is double (200%) its average.
rVol = volMa > 0 ? (volSource / volMa) * 100.0 : 0.0

// ==========================================
// Logic: Filter out below-average values
// ==========================================
// Since 100.0 is the baseline average, anything below 100.0 is hidden (na)
displayRVol = rVol >= 100.0 ? rVol : na

// ==========================================
// Dollar Volume of this bar (HLC3 x volume, same as TDV)
// ==========================================
dollarVol = hlc3 * volume

// ==========================================
// Plotting (Histogram format)
// ==========================================
volColor = close >= open ? color.new(color.green, 30) : color.new(color.red, 30)

// Baseline marker showing where the 100% (Average) mark sits
hline(100.0, "Volume MA Baseline (100%)", color=color.new(color.orange, 40), linestyle=hline.style_dashed)

// Plot the relative volume scale
plot(displayRVol, title="Relative Volume %", color=volColor, style=plot.style_histogram, linewidth=3,
     format=format.price, precision=2)

// Dollar volume is not drawn: hover a bar and read it (gold number) in the status line
color dollarCol = #FFD54F
plot(dollarVol, title="Dollar Volume", color=dollarCol,
     display=display.status_line + display.data_window, format=format.volume)

// ==========================================
// Legend Table: names the gold number as dollar volume (latest bar)
// ==========================================
showTable = input.bool(true, "Show Dollar Volume Label")

fmtUsd(float v) =>
    float a = math.abs(v)
    na(v)    ? "-" :
     a >= 1e9 ? "$" + str.tostring(v / 1e9, "0.00") + "B" :
     a >= 1e6 ? "$" + str.tostring(v / 1e6, "0.00") + "M" :
     a >= 1e3 ? "$" + str.tostring(v / 1e3, "0.0")  + "K" :
               "$" + str.tostring(v, "0")

var table legend = table.new(position.top_right, 2, 1, bgcolor=color.new(#1E222D, 20),
                             frame_color=#363A45, frame_width=1)

if showTable and barstate.islast
    table.cell(legend, 0, 0, "$ Vol", text_color=#787B86, text_size=size.small)
    table.cell(legend, 1, 0, fmtUsd(dollarVol), text_color=dollarCol, text_size=size.small)
````
