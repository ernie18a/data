# Leno Logic Stack: BOS & CHoCH

- url: https://www.tradingview.com/script/rnKhjMzu-Leno-Logic-Stack-BOS-CHoCH/
- type: indicator
- pine_id: PUB;da8b01d24402447987f8852e0a925c1e
- version: 1.0

## Description

The current script uses a fixed lookback. For your specific volume-based setups, you may want to add a volume > ta.sma(volume, 20) condition within the if statements to ensure that the structure break is "validated" by institutional participation.

Integration: Since you are tracking the interaction between price action and the VWMA 20, you could add a condition where a BOS label only prints if the close is above the ta.vwma(close, 20).

## Source Code

````pine
//@version=6
indicator("Leno Logic Stack: BOS & CHoCH", overlay=true)

// Settings
lookback = 5

// Identify pivots
ph = ta.pivothigh(high, lookback, lookback)
pl = ta.pivotlow(low, lookback, lookback)

// Variables for structure
var float last_high = na
var float last_low = na

// Logic for BOS/CHoCH
if not na(ph)
    last_high := ph
    
if not na(pl)
    last_low := pl

// Plotting Labels
if high > last_high and not na(last_high)
    label.new(bar_index[lookback], high, "BOS", color=color.green, style=label.style_label_up, textcolor=color.white)
    last_high := high

if low < last_low and not na(last_low)
    label.new(bar_index[lookback], low, "CHoCH", color=color.red, style=label.style_label_down, textcolor=color.white)
    last_low := low
````
