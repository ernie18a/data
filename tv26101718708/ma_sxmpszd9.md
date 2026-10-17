# MA

- url: https://www.tradingview.com/script/SxmpsZd9-MA/
- type: indicator
- pine_id: PUB;5373528642a8424aa2cd0a337c3d5787
- version: 1.0

## Description

mark minervini moving average d lksadjf saldf saflkdsajf ;saldsad lfkjsa ;lfd fdwafasdf

## Source Code

````pine
//@version=6
// © KT_Investing

indicator(title='MA', shorttitle='MA', overlay=true)

// Moving Averages ###############################################################################

// EMA 5 //
EMA5len = input.int(5, minval=1, title="Length EMA 5")
EMA5src = input.source(close, title="Source EMA 5")
EMA5 = ta.ema(EMA5src, EMA5len)
plot(EMA5, title='EMA 5', color=#9c9c9c, style=plot.style_line, linewidth=1) 

// EMA 10 //
EMA10len = input.int(10, minval=1, title="Length EMA 10")
EMA10src = input.source(close, title="Source EMA 10")
EMA10 = ta.ema(EMA10src, EMA10len)
plot(EMA10, title='EMA 10', color=#ff00ff, style=plot.style_line, linewidth=1)

// EMA 21 //
EMA21len = input.int(21, minval=1, title="Length EMA 21")
EMA21src = input.source(close, title="Source EMA 21")
EMA21 = ta.ema(EMA21src, EMA21len)
plot(EMA21, title='EMA 21', color=#ffffff, style=plot.style_line, linewidth=1) 

// SMA 50 //
SMA50len = input.int(50, minval=1, title="Length SMA 50")
SMA50src = input.source(close, title="Source SMA 50")
SMA50 = ta.sma(SMA50src, SMA50len)
plot(SMA50, title='SMA 50', color=#14ff00, style=plot.style_line, linewidth=1) 

// SMA 150 //
SMA150len = input.int(150, minval=1, title="Length SMA 150")
SMA150src = input.source(close, title="Source SMA 150")
SMA150 = ta.sma(SMA150src, SMA150len)
plot(SMA150, title='SMA 150', color=#fce200, style=plot.style_line, linewidth=1) 

// SMA 200 //
SMA200len = input.int(200, minval=1, title="Length SMA 200")
SMA200src = input.source(close, title="Source SMA 200")
SMA200 = ta.sma(SMA200src, SMA200len)
plot(SMA200, title='SMA 200', color=#ff0000, style=plot.style_line, linewidth=1)
````
