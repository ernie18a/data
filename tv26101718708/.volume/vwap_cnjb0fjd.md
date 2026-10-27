# vwap

- url: https://www.tradingview.com/script/cnJb0fjD/
- type: indicator
- pine_id: PUB;789b2f9922d34451b309fba1e5f94cd2
- version: 1.0

## Description

日均价指标，参考当日平均价判断是否日内单边

## Source Code

````pine
//@version=5
indicator("TradingHero - 日内均价 VWAP + 可调差异标签", shorttitle="日内均价差异", overlay=true)

// === 新增设置：标签显示内容（均价插值 或 均价值）===
label_display = input.string("均价插值", title="标签显示内容", 
     options=["均价插值", "均价值"], 
     defval="均价插值", 
     tooltip="选择标签显示『均价插值』（价格 - VWAP 差值）还是『均价值』（VWAP 本身）")

// 计算当天K线数量（每天自动重置）——与原脚本完全一致
isNewDay = ta.change(time("D"))
var float cumTypicalPrice = 0.0
var float cumVolume = 0.0

if isNewDay
    cumTypicalPrice := 0.0
    cumVolume := 0.0

typicalPrice = (high + low + close) / 3
cumTypicalPrice += typicalPrice * volume
cumVolume += volume

vwapValue = cumVolume != 0 ? cumTypicalPrice / cumVolume : na

// 计算价格差异（当前收盘价 - 日内VWAP）
diffValue = close - vwapValue

// === 显示均价线（蓝色）===
plot(vwapValue, title="日内均价 VWAP", color=color.blue, linewidth=2)

// === 差价/均价标签放置在均价线旁边 ===
var label diffLabel = label.new(bar_index, vwapValue, "", color=color.orange, textcolor=color.white, style=label.style_label_left, size=size.normal)

if barstate.islast
    // 根据设置决定显示内容
    string label_text = label_display == "均价插值" ? 
         "均价插值\n" + str.tostring(diffValue, "#.##") : 
         "均价值\n" + str.tostring(vwapValue, "#.##")
    
    label.set_xy(diffLabel, bar_index + 1, vwapValue)          // 紧贴均价线旁边
    label.set_text(diffLabel, label_text)
    label.set_color(diffLabel, label_display == "均价插值" ? color.orange : color.blue)
````
