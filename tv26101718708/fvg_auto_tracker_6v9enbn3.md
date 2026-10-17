# FVG Auto Tracker

- url: https://www.tradingview.com/script/6V9EnbN3/
- type: indicator
- pine_id: PUB;857dd3ef81a94857bd1c989f546c5ae3
- version: 1.0

## Description

FVG Auto Tracker

A clean and efficient Fair Value Gap (FVG) indicator designed for traders who want to quickly identify market imbalances directly on the chart.

This indicator automatically detects and displays bullish and bearish FVGs in real time, helping you spot potential reaction zones, liquidity areas, and continuation opportunities with clarity.

Features

✔ Automatic detection of Bullish & Bearish FVGs
✔ Real-time visualization directly on the chart
✔ Dynamic gap tracking
✔ FVG zones progressively shrink as price fills the imbalance
✔ Fully filled FVGs are automatically removed from the chart
✔ Clean and lightweight design


The indicator keeps your chart clean by updating gaps dynamically as the market evolves, allowing you to focus only on active and relevant imbalances.

Perfect for Forex, Gold (XAUUSD), Indices, Crypto, and all TradingView-supported markets.

## Source Code

````pine
//@version=6
indicator("FVG – Bougie", overlay=true, max_boxes_count=500)

fillMode = input.string("50%", "Comblement", options=["50%", "100%"])

bullFVG = high[2] < low[0]
bearFVG = low[2]  > high[0]

var float[] a_top  = array.new_float()
var float[] a_bot  = array.new_float()
var bool[]  a_bull = array.new_bool()
var box[]   a_box  = array.new_box()

if bullFVG
    array.push(a_top,  low[0])
    array.push(a_bot,  high[2])
    array.push(a_bull, true)
    array.push(a_box,  box.new(bar_index - 1,
                 math.max(open[1], close[1]),
                 bar_index,
                 math.min(open[1], close[1]),
                 bgcolor      = color.new(color.yellow, 20),
                 border_width = 0,
                 border_color = na))

if bearFVG
    array.push(a_top,  low[2])
    array.push(a_bot,  high[0])
    array.push(a_bull, false)
    array.push(a_box,  box.new(bar_index - 1,
                 math.max(open[1], close[1]),
                 bar_index,
                 math.min(open[1], close[1]),
                 bgcolor      = color.new(color.yellow, 20),
                 border_width = 0,
                 border_color = na))

i = 0
while i < array.size(a_top)
    _bull   = array.get(a_bull, i)
    _top    = array.get(a_top,  i)
    _bot    = array.get(a_bot,  i)
    _mid    = (_top + _bot) * 0.5
    _lvl    = fillMode == "50%" ? _mid : (_bull ? _bot : _top)
    _filled = _bull ? (low <= _lvl) : (high >= _lvl)
    if _filled
        box.delete(array.get(a_box, i))
        array.remove(a_top,  i)
        array.remove(a_bot,  i)
        array.remove(a_bull, i)
        array.remove(a_box,  i)
    else
        i += 1
````
