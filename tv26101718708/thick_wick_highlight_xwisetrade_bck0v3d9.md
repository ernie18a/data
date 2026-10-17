# Thick Wick Highlight [XWiseTrade]

- url: https://www.tradingview.com/script/Bck0v3d9-Thick-Wick-Highlight-XWiseTrade/
- type: indicator
- pine_id: PUB;0fc01786cda4446a9983a170f8d94eab
- version: 1.0

## Description

Make candle wicks pop with customizable thickness and color!

This lightweight overlay draws bold lines over upper and lower wicks on every candle—ideal for:
• Crowded charts with multiple indicators where thin wicks get lost
• Cleaner screenshots and printed analysis
• Making long wicks more visible at a glance

Features:
• Adjustable wick color and thickness (1-10)
• Works on all symbols and timeframes
• Simple, fast, non-repainting

Note: Due to TradingView's line object limit (~50 lines per script), thick wicks are visible on the most recent ~25 candles.

## Source Code

````pine
//@version=6
indicator("Thick Wick [XWiseTrade]", overlay=true)

// 用户可调整的参数
color wick_color = input.color(color.black, "Wick Color", tooltip="Color of the thick wicks")
int wick_width = input.int(3, "Wick Width", minval=1, maxval=10, tooltip="Width of the thick wicks")

// 获取K线数据
float o = open
float h = high
float l = low
float c = close

// 绘制粗影线（对所有历史K线）
if h > math.max(o, c)
    line.new(bar_index, math.max(o, c), bar_index, h, color=wick_color, width=wick_width, xloc=xloc.bar_index)  // 上影线
if l < math.min(o, c)
    line.new(bar_index, math.min(o, c), bar_index, l, color=wick_color, width=wick_width, xloc=xloc.bar_index)  // 下影线
````
