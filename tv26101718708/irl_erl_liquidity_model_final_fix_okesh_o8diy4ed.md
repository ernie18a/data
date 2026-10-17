# IRL ERL Liquidity Model (FINAL FIX) okesh

- url: https://www.tradingview.com/script/O8dIY4ed-IRL-ERL-Liquidity-Model-FINAL-FIX-okesh/
- type: indicator
- pine_id: PUB;bb4401271c5642ec837ebee762a409fe
- version: 1.0

## Description

erl irl model base indicator creat by okesh matreLibrary "CurrentlyPositionIndicator" Currently position indicator run(_index, _price, _stoploss, _high, _low, _side, _is_entered, _colors, _position_left, _box_width)   Currently positions indicator   Parameters:      _index (int) : entry index      _price (float) : entry price      _stoploss (float) : stoploss price      _high (float) : range high      _low (float) : range low      _side (int)      _is_entered (bool) : is entered      _colors (color ) : color array      _position_left (int) : Left position      _box_width (int) : box's width   Returns: TODO: add what function returns
by boitoki
Updated Oct 15, 2023

## Source Code

````pine
//@version=6
indicator("IRL ERL Liquidity Model (FINAL FIX)", overlay=true)

// ===== INPUT =====
len = input.int(20, "Range Length")
showMid = input.bool(true, "Show IRL Mid")

// ===== ERL (External Liquidity) =====
erlHigh = ta.highest(high, len)
erlLow  = ta.lowest(low, len)

plot(erlHigh, "ERL High", color=color.red, linewidth=2)
plot(erlLow, "ERL Low", color=color.green, linewidth=2)

// ===== IRL (Internal Liquidity) =====
irlMid = (erlHigh + erlLow) / 2
plot(showMid ? irlMid : na, "IRL Mid", color=color.gray)

// ===== SAFE PIVOT DETECTION =====
left = 3
right = 3

ph = ta.pivothigh(high, left, right)
pl = ta.pivotlow(low, left, right)

// ===== FIX: store last confirmed bar index safely =====
if not na(ph)
    label.new(bar_index - right,
         high[right],
         text="IRL High",
         style=label.style_label_down,
         color=color.orange,
         textcolor=color.white,
         size=size.tiny)

if not na(pl)
    label.new(bar_index - right,
         low[right],
         text="IRL Low",
         style=label.style_label_up,
         color=color.aqua,
         textcolor=color.white,
         size=size.tiny)

// ===== LIQUIDITY SWEEP =====
buySweep = high > erlHigh
sellSweep = low < erlLow

plotshape(buySweep, title="BSL Sweep",
     location=location.abovebar,
     color=color.red,
     style=shape.triangledown,
     text="BSL",
     size=size.tiny)

plotshape(sellSweep, title="SSL Sweep",
     location=location.belowbar,
     color=color.green,
     style=shape.triangleup,
     text="SSL",
     size=size.tiny)
````
