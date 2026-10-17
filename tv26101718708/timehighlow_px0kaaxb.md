# Timehighlow

- url: https://www.tradingview.com/script/Px0kaaXb/
- type: indicator
- pine_id: PUB;638e347a8c4d4ad688a484d61fd4f7a2
- version: 1.0

## Description

亚盘、欧盘、美盘的时段，并附有高低点。

## Source Code

````pine
//@version=5
indicator("三盘时段+高低点", overlay=true, shorttitle="盘口时段", max_labels_count=500)

// 自定义时段 UTC
asia_start = input.int(23, "亚盘开始(UTC)")
asia_end   = input.int(8,  "亚盘结束(UTC)")
eu_start   = input.int(7,  "欧盘开始(UTC)")
eu_end     = input.int(16, "欧盘结束(UTC)")
us_start   = input.int(13, "美盘开始(UTC)")
us_end     = input.int(22, "美盘结束(UTC)")

// 背景颜色
c_asia = input.color(color.new(color.teal, 85), "亚盘背景")
c_eu   = input.color(color.new(color.blue, 85), "欧盘背景")
c_us   = input.color(color.new(color.red, 85),  "美盘背景")

// 判断当前所属时段
h = hour(time)
in_asia = h >= asia_start or h < asia_end
in_eu   = h >= eu_start and h < eu_end
in_us   = h >= us_start and h < us_end

// 绘制时段背景
bgcolor(in_asia ? c_asia : na)
bgcolor(in_eu   ? c_eu   : na)
bgcolor(in_us   ? c_us   : na)

// 时段标签
var label[] lbl = array.new_label()
if barstate.isfirst
    array.clear(lbl)

if in_asia and not in_asia[1]
    array.push(lbl, label.new(bar_index, high, "亚盘", color=c_asia, textcolor=color.white, style=label.style_label_down, size=size.small))
if in_eu and not in_eu[1]
    array.push(lbl, label.new(bar_index, high, "欧盘", color=c_eu, textcolor=color.white, style=label.style_label_down, size=size.small))
if in_us and not in_us[1]
    array.push(lbl, label.new(bar_index, high, "美盘", color=c_us, textcolor=color.white, style=label.style_label_down, size=size.small))

// 统计区间K线数量 替代 barssince
var int cnt_asia = 0
var int cnt_eu = 0
var int cnt_us = 0

cnt_asia := in_asia ? cnt_asia + 1 : 0
cnt_eu   := in_eu   ? cnt_eu + 1 : 0
cnt_us   := in_us   ? cnt_us + 1 : 0

// 计算时段高低点
asia_high = ta.highest(high, cnt_asia)
asia_low  = ta.lowest(low,  cnt_asia)
eu_high   = ta.highest(high, cnt_eu)
eu_low    = ta.lowest(low,  cnt_eu)
us_high   = ta.highest(high, cnt_us)
us_low    = ta.lowest(low,  cnt_us)

// 绘制高低点
plot(in_asia ? asia_high : na, color=color.teal, style=plot.style_circles)
plot(in_asia ? asia_low  : na, color=color.teal, style=plot.style_circles)

plot(in_eu ? eu_high : na, color=color.blue, style=plot.style_circles)
plot(in_eu ? eu_low  : na, color=color.blue, style=plot.style_circles)

plot(in_us ? us_high : na, color=color.red, style=plot.style_circles)
plot(in_us ? us_low  : na, color=color.red, style=plot.style_circles)
````
