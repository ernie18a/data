# VWAP + RSI Confluence

- url: https://www.tradingview.com/script/cJu8w2PO-VWAP-RSI-Confluence/
- type: indicator
- pine_id: PUB;a4f73cb09c2043f7a2e784737eee9be6
- version: 1.0

## Description

This indicator merges VWAP and RSI into one clean visual system by coloring candles based on their agreement.

Green candles → Bullish confluence: Price is above VWAP and RSI is above the midline (default 50).
Red candles → Bearish confluence: Price is below VWAP and RSI is below the midline.
White candles (Hold) → Conflict between VWAP and RSI. The market is undecided — best to stay out and avoid choppy, low-quality setups.

The white “Hold” candles act as a powerful filter that helps you avoid trading when the two indicators disagree.
How to Use

Trade in the direction of the colored candles (green = long bias, red = short bias).
Avoid trading during white “Hold” candles.
Best used at key support/resistance levels or in combination with your existing price action or structure.
Works on all timeframes and instruments.

Important Setup Step (Required for Reliable Colors)
For the custom candle colors to display correctly even when the indicator is not selected, you must do the following once:

Add the indicator to your chart.
Right-click anywhere on the chart.
Select Object Tree.
Right-click on VWAP + RSI Confluence.
Go to Visual Order → Bring to front.

After this step, the colors will remain stable. It is recommended to save your chart as a template afterward so you don’t have to repeat this process.
Settings

VWAP Anchor: Choose between Day, Week, Month, or Year (resets the VWAP calculation accordingly).
RSI Length: Default is 21 (adjustable).
RSI Midline: Default is 50.0 (the threshold for bullish/bearish agreement).
Colors: Fully customizable colors for Bullish candles, Bearish candles, Hold candles, and their wicks.

Recommended Use
This indicator is especially useful for day trading and swing trading when you want a clear visual filter that reduces conflicting signals between momentum (RSI) and institutional average price (VWAP).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Richard_1O1

//@version=6
indicator("VWAP + RSI Candle Color [Final]", shorttitle="VWAP+RSI", overlay=true, max_bars_back=500)

group_vwap   = "VWAP Einstellungen"
group_rsi    = "RSI Einstellungen"
group_colors = "Farben"

vwap_anchor = input.string("Day", "VWAP Anker", options=["Day","Week","Month","Year"], group=group_vwap)
rsi_length  = input.int(21, "RSI Länge", minval=1, group=group_rsi)
rsi_source  = input.source(close, "RSI Quelle", group=group_rsi)
rsi_mid     = input.float(50.0, "RSI Mittellinie", minval=1, maxval=99, step=0.5, group=group_rsi)

bull_color     = input.color(color.rgb(10, 223, 138), "Bullish Kerze", group=group_colors)
bear_color     = input.color(color.new(#ef5350, 0), "Bearish Kerze", group=group_colors)
hold_color     = input.color(color.new(#ffffff, 0), "Hold Kerze (weiß)", group=group_colors)
bull_wick_col  = input.color(color.rgb(16, 255, 123), "Bullish Docht", group=group_colors)
bear_wick_col  = input.color(color.new(#ef5350, 30), "Bearish Docht", group=group_colors)
hold_wick_col  = input.color(color.new(#ffffff, 0), "Hold Docht", group=group_colors)

// VWAP
anchor_tf = switch vwap_anchor
    "Day"   => "D"
    "Week"  => "W"
    "Month" => "M"
    "Year"  => "12M"
    => "D"

is_new_period = timeframe.change(anchor_tf)

var float cum_vol       = 0.0
var float cum_price_vol = 0.0

if is_new_period or barstate.isfirst
    cum_vol       := 0.0
    cum_price_vol := 0.0

cum_vol       += volume
cum_price_vol += hlc3 * volume
vwap_val       = cum_vol > 0 ? cum_price_vol / cum_vol : hlc3

rsi_val = ta.rsi(rsi_source, rsi_length)

is_bullish = close > vwap_val and rsi_val > rsi_mid
is_bearish = close < vwap_val and rsi_val < rsi_mid

candle_col = is_bullish ? bull_color : is_bearish ? bear_color : hold_color
wick_col   = is_bullish ? bull_wick_col : is_bearish ? bear_wick_col : hold_wick_col

plotcandle(open, high, low, close,
     color       = candle_col,
     wickcolor   = wick_col,
     bordercolor = candle_col,
     editable    = false,
     title       = "VWAP+RSI Kerzen")

plot(vwap_val, "VWAP", color=color.new(#2962ff, 0), linewidth=2)

bgcolor(is_bullish ? color.new(color.green, 92) : is_bearish ? color.new(color.red, 92) : color.new(color.gray, 94), title="Hold Hintergrund")
````
