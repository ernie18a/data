# SMA and EMA Lines

- url: https://www.tradingview.com/script/BKCytgy7/
- type: indicator
- pine_id: PUB;61a940df78fc42f5abeddd98aad75ee9
- version: 2.0

## Description

Script displays the EMA10, SMA50, SMA150 and SMA200 in one indicator.

## Source Code

````pine

// © KamikazeEddi

//@version=6
indicator("SMA and EMA Lines", overlay=true)

// Colors
ema10Color = color.rgb(243, 145, 33, 36)
sma50Color = color.rgb(33, 149, 243, 36)
sma150Color = color.rgb(33, 149, 243, 14)
sma200Color = color.blue

// Values
ema10     = ta.ema(close, 10)
sma9     = ta.sma(close, 9)
sma50    = ta.sma(close, 50)
sma150   = ta.sma(close, 150)
sma200   = ta.sma(close, 200)

// Plot
plot(ema10, color=ema10Color, title="EMA 10")
var label lblema10  = label.new(bar_index, ema10,  "EMA 10",  style=label.style_none, textcolor=ema10Color, size=size.small)
label.set_xy(lblema10,  bar_index + 4, ema10)

plot(sma50, color=sma50Color, title="SMA 50")
var label lbl50  = label.new(bar_index, sma50,  "SMA 50",  style=label.style_none, textcolor=sma50Color, size=size.small)
label.set_xy(lbl50,  bar_index + 4, sma50)

plot(sma150, color=sma150Color, title="SMA 150")
var label lbl150 = label.new(bar_index, sma150, "SMA 150", style=label.style_none, textcolor=sma150Color, size=size.small)
label.set_xy(lbl150, bar_index + 4, sma150)

plot(sma200, color=sma200Color, title="SMA 200")
var label lbl200 = label.new(bar_index, sma200, "SMA 200", style=label.style_none, textcolor=sma200Color, size=size.small)
label.set_xy(lbl200, bar_index + 4, sma200)
````
