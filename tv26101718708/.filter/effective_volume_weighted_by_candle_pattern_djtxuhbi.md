# Effective Volume (Weighted by candle pattern)

- url: https://www.tradingview.com/script/DjtxuhBi/
- type: indicator
- pine_id: PUB;fe1a149ef77c4e2aaf5f24cf20b44310
- version: 1.0

## Description

This is a indicator using candle : wick ratio to obtain a weighted volume.

useful for trader using volume-price action strategy.

the mechanism is easy:-

when it is full bullish / full bearish bar, the weighted volume exactly equal to the volume itself.

when it is a total wick bar , the weighted volume will be half of that time-frame volume

the weighted formula is simple mathematics due to body : wick ratio. 

However, I find that it useful for me.

## Source Code

````pine
//@version=5
indicator("Effective Volume with 2xMA", shorttitle="E-Vol", overlay=false, precision=0, format=format.volume)

daily_Length = input.int(50, "Long MA Length", minval=1)


// 陰陽燭條件
is_bullish = close > open
is_bearish = close <= open

// 計算正負成交量（你的原始公式保留）
positive_volume = is_bullish ? 
     volume * (high - low) / (2 * high - 2 * low + open - close) : 
     volume * (high - low) / (2 * high - 2 * low + close - open)

negative_volume = volume - positive_volume


volumeAvgShort = ta.sma(positive_volume , daily_Length)
volumeAvgDaily = ta.sma(volume, daily_Length)

// === 繪製柱狀圖 ===
// Bullish 陽燭
plot(is_bullish ? positive_volume : na, 
     style=plot.style_columns, 
     color=color.new(#2195f3, 62), 
     title="Positive Volume (Bullish)")

// Bearish 陰燭
plot(is_bearish ? positive_volume : na, 
     style=plot.style_columns, 
     color=color.new(#f91010, 60), 
     title="Positive Volume (Bearish)")

// Bearish 下灰燭
plot(-negative_volume, 
     style=plot.style_columns, 
     color= is_bullish and close[1] > close ? color.new(#f91010, 60) : is_bearish and close[1]<close ? color.new(#2195f3, 62) : color.new(#000000, 86), 
     title="Negative Volume")

// 零軸參考線（可選）
hline(0, "Zero", color=color.new(color.gray, 70), linestyle=hline.style_dotted)
// === 新增：普通 Total Volume 楷梯線 ===
plot(volume, 
     title="Total Volume (Stepline)", 
     style=plot.style_stepline, 
     color=color.new(#000000, 0), 
     linewidth=1)
plot(volumeAvgDaily, title = "AvgLine" ,color=#2f00ff)
plot(volumeAvgShort, title="ShortLine",color=color.rgb(21, 124, 71, 42))
````
