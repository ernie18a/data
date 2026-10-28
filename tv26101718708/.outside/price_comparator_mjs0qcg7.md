# Price Comparator

- url: https://www.tradingview.com/script/mjs0qCG7-Price-Comparator/
- type: indicator
- pine_id: PUB;6636311972024785ad1c2f1f8bc404a7
- version: 2.0

## Description

A simple script to compare the price between 2 symbols with EMA and High/Low Pivot Labels.

I use it to compare the price between NQ futures and spot pricing with a spread betting broker to take advantage of a tighter spread but it can be used to compare any 2 symbols.

## Source Code

````pine
//@version=6
indicator(title = "Price Comparator", shorttitle="PC", overlay=false)

// ===== USER INPUT =====
sym_1 = input.symbol("NQU2026", "Symbol 1", group="Symbols")
sym_2 = input.symbol("NQM2026", "Symbol 2", group="Symbols")

show_diff = input.bool(true, "Show Raw Price Difference", group="Raw Difference")
col_pos = input.color(color.green, "Positive Colour", group="Raw Difference")
col_neg = input.color(color.red, "Negative Colour", group="Raw Difference")


show_diff_avg = input.bool (true,"Show Average Price Difference", group="Average Difference")
avg_len = input.int(20,"Average Length", group="Average Difference")
col_avg = input.color(color.white, "Average Colour", group="Average Difference")

show_hilo = input.bool (true,"Show High/Low Swing Labels", group="Pivot Highs/Lows")
left_len = input.int(10,"Pivot Look Left Bars", group="Pivot Highs/Lows")
right_len = input.int(10,"Pivot Look Right Bars", group="Pivot Highs/Lows")
col_label_h = input.color(color.rgb(80,0,0,0),"High Label Colour", group="Pivot Highs/Lows")
col_label_l = input.color(color.rgb(1, 14, 88,0),"Low Label Colour", group="Pivot Highs/Lows")

// ===== FETCH DATA =====
sec_1 = request.security(sym_1, timeframe.period, close)
sec_2 = request.security(sym_2, timeframe.period, close)

//=== CALCULATIONS =====

diff = sec_1 - sec_2 // Calculate price difference between symbols

color_diff = diff >=0 ? col_pos : col_neg // Set colour for positive/negative values

diff_high = ta.pivothigh(diff, left_len, right_len) // Look for pivot highs
diff_low = ta.pivotlow(diff, left_len, right_len) // Look for pivot lows

value_high =str.tostring(diff_high) // Convert pivot high values to strings for labels
value_low =str.tostring(diff_low) // Convert pivot low values to strings for labels

diff_avg = ta.ema(diff,avg_len) // Calculate EMA of price difference

// ===== PLOTTING =====

plot(show_diff ? diff : na, title="Price Difference (Symbol 1 - Symbol 2)", color=color_diff, linewidth=3) //Plot raw price difference

if not na(diff_high)
    show_hilo ? label.new (bar_index[right_len],diff_high,value_high, style=label.style_label_down,size=size.small, color=col_label_h):na // Plot pivot high labels

if not na(diff_low)
    show_hilo ? label.new (bar_index[right_len],diff_low,value_low, style=label.style_label_up,size=size.small, color=col_label_l):na //Plot pivot low labels

plot(show_diff_avg? diff_avg : na,title = "Average Price Difference", color=col_avg, linestyle = plot.linestyle_solid, linewidth = 1)
````
