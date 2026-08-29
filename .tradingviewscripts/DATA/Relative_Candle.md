<!-- tradingview-pine-id: PUB;uOQsb3eWhWwOOQliqKkYauquRoKBEBhY -->
<!-- tradingviewscripts-format: 1 -->
# Relative Candle

Source: https://www.tradingview.com/script/k6OlgKAO-Relative-Candle/

## Description

This script visualizes the relative movement of a single OHLC candle compared to an index (or another symbol).  The vertical location of the candle indicates the general positive/negative comparison of the bar vs the index.  The color of the candle indicates how the candle moved relative to the index.  The wick indicates the closing range compared to the index (did the symbol close at lows of the bar while the index closed at highs).

The area graph in the background shows the average relative close over a 10-day simple moving average. 

I use this to pop any behavior that is out of line with the market, whether positive or negative.  For example, is a red bar day due to the market pullback or something specific to the stock.  Or did the market pull back and the stock did the opposite, strong day!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Author: drewby4321, Drew Robbins, v1.1, 2020.11.02

//@version=4
study("Relative Candle")

var idx_symbol = input("IXIC", "Index", type=input.symbol)
var average_close_length = input(10, "Average Relative Close Length")
var average_zoom_factor = input(5, "Zoom Factor for Average Relative Close")

idx_open = security(idx_symbol, timeframe.period, open)
idx_high = security(idx_symbol, timeframe.period, high)
idx_low = security(idx_symbol, timeframe.period, low)
idx_close = security(idx_symbol, timeframe.period, close)

chg_idx_open = (idx_open/idx_close[1])-1
chg_idx_close = (idx_close/idx_close[1])-1
chg_idx_closerange = (idx_close-idx_low)/(idx_high-idx_low)

chg_open = (open/close[1])-1
chg_close = (close/close[1])-1
chg_closerange = (close-low)/(high-low)

relative_open = (chg_open - chg_idx_open) * 100
relative_close = (chg_close - chg_idx_close) * 100
relative_closerange = abs(relative_close - relative_open) * (chg_closerange - chg_idx_closerange)
relative_high = relative_closerange < 0 ? max(relative_close, relative_open)-relative_closerange : max(relative_open, relative_close) 
relative_low = relative_closerange >= 0 ? min(relative_open, relative_close)-relative_closerange : min(relative_open, relative_close)

avarage_relative_close = sma(relative_close,average_close_length)
plot(avarage_relative_close * average_zoom_factor, title="Average Relative Close", style=plot.style_area, color=avarage_relative_close >= 0 ? color.new(color.teal,70) : color.new(color.red,70))

plotcandle(relative_open, relative_high, relative_low, relative_close, title="Relative OHLC", color=relative_close-relative_open >= 0 ? color.new(color.blue,0) : color.new(color.orange,0))
````
