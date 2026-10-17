# MA

- url: https://www.tradingview.com/script/xHJpVjkk-MA/
- type: indicator
- pine_id: PUB;013346d412fa47a1a533f6229cd29b5c
- version: 1.0

## Description

ro2heqp cwqojfeouwqrhf owqpe wofh oewpjqf dsalks aflkjds;o kokwlfdlsag

## Source Code

````pine
//@version=6
// © Undertaker2546

indicator(title='MA', shorttitle='MA', overlay=true)

// --- Master Toggles (สวิตช์เปิด-ปิดแบบกลุ่ม) --- //
showAllEMA = input.bool(true, title="Show All EMAs (เปิด/ปิด ชุด EMA)", group="EMA Settings")
showAllSMA = input.bool(true, title="Show All SMAs (เปิด/ปิด ชุด SMA)", group="SMA Settings")

// Moving Averages ###############################################################################

// EMA 5 //
EMA5len = input.int(5, minval=1, title="Length EMA 5", group="EMA Settings")
EMA5src = input.source(close, title="Source EMA 5", group="EMA Settings")
EMA5 = ta.ema(EMA5src, EMA5len)
plot(showAllEMA ? EMA5 : na, title='EMA 5', color=#ffffff, style=plot.style_line, linewidth=1) 

// EMA 10 //
EMA10len = input.int(10, minval=1, title="Length EMA 10", group="EMA Settings")
EMA10src = input.source(close, title="Source EMA 10", group="EMA Settings")
EMA10 = ta.ema(EMA10src, EMA10len)
plot(showAllEMA ? EMA10 : na, title='EMA 10', color=#ff00ff, style=plot.style_line, linewidth=1)

// EMA 21 //
EMA21len = input.int(21, minval=1, title="Length EMA 21", group="EMA Settings")
EMA21src = input.source(close, title="Source EMA 21", group="EMA Settings")
EMA21 = ta.ema(EMA21src, EMA21len)
plot(showAllEMA ? EMA21 : na, title='EMA 21', color=color.rgb(7, 7, 221), style=plot.style_line, linewidth=1) 

// SMA 50 //
SMA50len = input.int(50, minval=1, title="Length SMA 50", group="SMA Settings")
SMA50src = input.source(close, title="Source SMA 50", group="SMA Settings")
SMA50 = ta.sma(SMA50src, SMA50len)
plot(showAllSMA ? SMA50 : na, title='SMA 50', color=#14ff00, style=plot.style_line, linewidth=1) 

// SMA 150 //
SMA150len = input.int(150, minval=1, title="Length SMA 150", group="SMA Settings")
SMA150src = input.source(close, title="Source SMA 150", group="SMA Settings")
SMA150 = ta.sma(SMA150src, SMA150len)
plot(showAllSMA ? SMA150 : na, title='SMA 150', color=#fce200, style=plot.style_line, linewidth=1) 

// SMA 200 //
SMA200len = input.int(200, minval=1, title="Length SMA 200", group="SMA Settings")
SMA200src = input.source(close, title="Source SMA 200", group="SMA Settings")
SMA200 = ta.sma(SMA200src, SMA200len)
plot(showAllSMA ? SMA200 : na, title='SMA 200', color=#ff0000, style=plot.style_line, linewidth=1)
````
