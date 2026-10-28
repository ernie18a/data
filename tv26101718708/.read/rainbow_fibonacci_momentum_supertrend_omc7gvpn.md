# Rainbow Fibonacci Momentum - SuperTrend

- url: https://www.tradingview.com/script/OMc7Gvpn-Rainbow-Fibonacci-Momentum-SuperTrend/
- type: indicator
- pine_id: PUB;ba3e57d4df5542d583eda8bee7f4f30d
- version: 2.0

## Description

🌈 "Rainbow Fibonacci Momentum - SuperTrend" Indicator 🌈

[b]IMPORTANT:[/b] as this is a complex and elaborate TREND ANALYSIS on the graph, ALL INDICATORS REPAINT.

Experience the brilliance of "Rainbow Fibonacci Momentum - SuperTrend" for your technical analysis on TradingView! This versatile indicator allows you to visualize various types of Moving Averages, including Simple Moving Averages (SMA), Exponential Moving Averages (EMA), Weighted Moving Averages (WMA), Hull Moving Averages (HMA), and Volume Weighted Moving Averages (VWMA).

Each MA displayed in a unique color to create a stunning rainbow effect. This makes it easier for you to identify trends and potential trading opportunities.

Key Features:
📊 Multiple Moving Average Types - Choose from a range of moving average types to suit your analysis.
🎨 Stunning Color Gradient - Each moving average type is displayed in a unique color, creating a beautiful rainbow effect.
📉 Overlay Compatible - Use it as an overlay on your price chart for clear trend insights.

With the "Rainbow Fibonacci Momentum - SuperTrend" indicator, you'll add a burst of color to your trading routine and gain a deeper understanding of market trends.

[b]HOW IT WORKS[/b]

[b]MA Lines:[/b]
[list]
[*]MA - 5: purple lines
[*]MA - 8: blue lines
[*]MA - 13: green lines
[*]MA - 21: yellow lines
[*]MA - 34: orange lines
[*]MA - 55: red line
[/list]

[b]Header Color Indicators:[/b]
[list]
[*]Purple: MA-5 is in uptrend on the chart
[*]Blue: MA-5 and MA-8 are in the uptrend on the chart
[*]Green: MA-5, MA-8 and MA-13 are in the uptrend on the chart
[*]Yellow: MA-5, MA-8, MA-13 and MA-21 are in the uptrend on the chart
[*]Orange: MA-5, MA-8, MA-13, MA-21 and MA-34 are in the uptrend on the chart
[*]Red: MA-5, MA-8, MA-13, MA-21, MA-34 and MA-55 are in the uptrend on the chart
[*]Red + White Arrow: All MAs are correctly aligned in the uptrend on the chart
[/list]

[b]Footer Color Indicators:[/b]
[list]
[*]Purple: MA-5 is in downtrend on the chart
[*]Blue: MA-5 and MA-8 are in the downtrend on the chart
[*]Green: MA-5, MA-8 and MA-13 are in the downtrend on the chart
[*]Yellow: MA-5, MA-8, MA-13 and MA-21 are in the downtrend on the chart
[*]Orange: MA-5, MA-8, MA-13, MA-21 and MA-34 are in the downtrend on the chart
[*]Red: MA-5, MA-8, MA-13, MA-21, MA-34 and MA-55 are in the downtrend on the chart
[*]Red + White Arrow: All MAs are correctly aligned in the downtrend on the chart
[/list]

[b]Background Colors:[/b]
[list]
[*]Light Red: All MAs are on the rise!
[*]Red: All MAs are align correctly on the rise!
[*]Light Green: All MAs are in freefall!
[*]Green: All MAs are align correctly in freefall!
[/list]

[b]Tiny Arrows Indicators/Alerts:[/b]
[list]
[*]Down Arrow: All MAs are in freefall!
[*]Up Arrow: All MAs are on the rise!
[/list]

[b]Big Arrows Indicators/Alerts:[/b]
[list]
[*]Down Arrow: All MAs are align correctly in freefall!
[*]Up Arrow: All MAs are align correctly on the rise!
[/list]

## Source Code

````pine
//@version=5
indicator(title="Rainbow Fibonacci Momentum", shorttitle = "RFM", overlay=true)

// Input for Moving Average Type
ma_type = input.string("EMA", title="Moving Average Type", options=["EMA", "SMA", "WMA", "HMA", "VWMA"])

// Moving Average Periods
ma_length5 = 5
ma_length6 = 6
ma_length7 = 7
ma_length8 = 8
ma_length9 = 9
ma_length10 = 10
ma_length11 = 11
ma_length12 = 12
ma_length13 = 13
ma_length14 = 14
ma_length15 = 15
ma_length16 = 16
ma_length17 = 17
ma_length18 = 18
ma_length19 = 19
ma_length20 = 20
ma_length21 = 21
ma_length22 = 22
ma_length23 = 23
ma_length24 = 24
ma_length25 = 25
ma_length26 = 26
ma_length27 = 27
ma_length28 = 28
ma_length29 = 29
ma_length30 = 30
ma_length31 = 31
ma_length32 = 32
ma_length33 = 33
ma_length34 = 34
ma_length35 = 35
ma_length36 = 36
ma_length37 = 37
ma_length38 = 38
ma_length39 = 39
ma_length40 = 40
ma_length41 = 41
ma_length42 = 42
ma_length43 = 43
ma_length44 = 44
ma_length45 = 45
ma_length46 = 46
ma_length47 = 47
ma_length48 = 48
ma_length49 = 49
ma_length50 = 50
ma_length51 = 51
ma_length52 = 52
ma_length53 = 53
ma_length54 = 54
ma_length55 = 55

// Calculate the moving averages
ma5 = ma_type == "EMA" ? ta.ema(close, ma_length5) : ma_type == "SMA" ? ta.sma(close, ma_length5) : ma_type == "WMA" ? ta.wma(close, ma_length5) : ma_type == "HMA" ? ta.hma(close, ma_length5) : ma_type == "VWMA" ? ta.vwma(close, ma_length5) : na
ma6 = ma_type == "EMA" ? ta.ema(close, ma_length6) : ma_type == "SMA" ? ta.sma(close, ma_length6) : ma_type == "WMA" ? ta.wma(close, ma_length6) : ma_type == "HMA" ? ta.hma(close, ma_length6) : ma_type == "VWMA" ? ta.vwma(close, ma_length6) : na
ma7 = ma_type == "EMA" ? ta.ema(close, ma_length7) : ma_type == "SMA" ? ta.sma(close, ma_length7) : ma_type == "WMA" ? ta.wma(close, ma_length7) : ma_type == "HMA" ? ta.hma(close, ma_length7) : ma_type == "VWMA" ? ta.vwma(close, ma_length7) : na
ma8 = ma_type == "EMA" ? ta.ema(close, ma_length8) : ma_type == "SMA" ? ta.sma(close, ma_length8) : ma_type == "WMA" ? ta.wma(close, ma_length8) : ma_type == "HMA" ? ta.hma(close, ma_length8) : ma_type == "VWMA" ? ta.vwma(close, ma_length8) : na
ma9 = ma_type == "EMA" ? ta.ema(close, ma_length9) : ma_type == "SMA" ? ta.sma(close, ma_length9) : ma_type == "WMA" ? ta.wma(close, ma_length9) : ma_type == "HMA" ? ta.hma(close, ma_length9) : ma_type == "VWMA" ? ta.vwma(close, ma_length9) : na
ma10 = ma_type == "EMA" ? ta.ema(close, ma_length10) : ma_type == "SMA" ? ta.sma(close, ma_length10) : ma_type == "WMA" ? ta.wma(close, ma_length10) : ma_type == "HMA" ? ta.hma(close, ma_length10) : ma_type == "VWMA" ? ta.vwma(close, ma_length10) : na
ma11 = ma_type == "EMA" ? ta.ema(close, ma_length11) : ma_type == "SMA" ? ta.sma(close, ma_length11) : ma_type == "WMA" ? ta.wma(close, ma_length11) : ma_type == "HMA" ? ta.hma(close, ma_length11) : ma_type == "VWMA" ? ta.vwma(close, ma_length11) : na
ma12 = ma_type == "EMA" ? ta.ema(close, ma_length12) : ma_type == "SMA" ? ta.sma(close, ma_length12) : ma_type == "WMA" ? ta.wma(close, ma_length12) : ma_type == "HMA" ? ta.hma(close, ma_length12) : ma_type == "VWMA" ? ta.vwma(close, ma_length12) : na
ma13 = ma_type == "EMA" ? ta.ema(close, ma_length13) : ma_type == "SMA" ? ta.sma(close, ma_length13) : ma_type == "WMA" ? ta.wma(close, ma_length13) : ma_type == "HMA" ? ta.hma(close, ma_length13) : ma_type == "VWMA" ? ta.vwma(close, ma_length13) : na
ma14 = ma_type == "EMA" ? ta.ema(close, ma_length14) : ma_type == "SMA" ? ta.sma(close, ma_length14) : ma_type == "WMA" ? ta.wma(close, ma_length14) : ma_type == "HMA" ? ta.hma(close, ma_length14) : ma_type == "VWMA" ? ta.vwma(close, ma_length14) : na
ma15 = ma_type == "EMA" ? ta.ema(close, ma_length15) : ma_type == "SMA" ? ta.sma(close, ma_length15) : ma_type == "WMA" ? ta.wma(close, ma_length15) : ma_type == "HMA" ? ta.hma(close, ma_length15) : ma_type == "VWMA" ? ta.vwma(close, ma_length15) : na
ma16 = ma_type == "EMA" ? ta.ema(close, ma_length16) : ma_type == "SMA" ? ta.sma(close, ma_length16) : ma_type == "WMA" ? ta.wma(close, ma_length16) : ma_type == "HMA" ? ta.hma(close, ma_length16) : ma_type == "VWMA" ? ta.vwma(close, ma_length16) : na
ma17 = ma_type == "EMA" ? ta.ema(close, ma_length17) : ma_type == "SMA" ? ta.sma(close, ma_length17) : ma_type == "WMA" ? ta.wma(close, ma_length17) : ma_type == "HMA" ? ta.hma(close, ma_length17) : ma_type == "VWMA" ? ta.vwma(close, ma_length17) : na
ma18 = ma_type == "EMA" ? ta.ema(close, ma_length18) : ma_type == "SMA" ? ta.sma(close, ma_length18) : ma_type == "WMA" ? ta.wma(close, ma_length18) : ma_type == "HMA" ? ta.hma(close, ma_length18) : ma_type == "VWMA" ? ta.vwma(close, ma_length18) : na
ma19 = ma_type == "EMA" ? ta.ema(close, ma_length19) : ma_type == "SMA" ? ta.sma(close, ma_length19) : ma_type == "WMA" ? ta.wma(close, ma_length19) : ma_type == "HMA" ? ta.hma(close, ma_length19) : ma_type == "VWMA" ? ta.vwma(close, ma_length19) : na
ma20 = ma_type == "EMA" ? ta.ema(close, ma_length20) : ma_type == "SMA" ? ta.sma(close, ma_length20) : ma_type == "WMA" ? ta.wma(close, ma_length20) : ma_type == "HMA" ? ta.hma(close, ma_length20) : ma_type == "VWMA" ? ta.vwma(close, ma_length20) : na
ma21 = ma_type == "EMA" ? ta.ema(close, ma_length21) : ma_type == "SMA" ? ta.sma(close, ma_length21) : ma_type == "WMA" ? ta.wma(close, ma_length21) : ma_type == "HMA" ? ta.hma(close, ma_length21) : ma_type == "VWMA" ? ta.vwma(close, ma_length21) : na
ma22 = ma_type == "EMA" ? ta.ema(close, ma_length22) : ma_type == "SMA" ? ta.sma(close, ma_length22) : ma_type == "WMA" ? ta.wma(close, ma_length22) : ma_type == "HMA" ? ta.hma(close, ma_length22) : ma_type == "VWMA" ? ta.vwma(close, ma_length22) : na
ma23 = ma_type == "EMA" ? ta.ema(close, ma_length23) : ma_type == "SMA" ? ta.sma(close, ma_length23) : ma_type == "WMA" ? ta.wma(close, ma_length23) : ma_type == "HMA" ? ta.hma(close, ma_length23) : ma_type == "VWMA" ? ta.vwma(close, ma_length23) : na
ma24 = ma_type == "EMA" ? ta.ema(close, ma_length24) : ma_type == "SMA" ? ta.sma(close, ma_length24) : ma_type == "WMA" ? ta.wma(close, ma_length24) : ma_type == "HMA" ? ta.hma(close, ma_length24) : ma_type == "VWMA" ? ta.vwma(close, ma_length24) : na
ma25 = ma_type == "EMA" ? ta.ema(close, ma_length25) : ma_type == "SMA" ? ta.sma(close, ma_length25) : ma_type == "WMA" ? ta.wma(close, ma_length25) : ma_type == "HMA" ? ta.hma(close, ma_length25) : ma_type == "VWMA" ? ta.vwma(close, ma_length25) : na
ma26 = ma_type == "EMA" ? ta.ema(close, ma_length26) : ma_type == "SMA" ? ta.sma(close, ma_length26) : ma_type == "WMA" ? ta.wma(close, ma_length26) : ma_type == "HMA" ? ta.hma(close, ma_length26) : ma_type == "VWMA" ? ta.vwma(close, ma_length26) : na
ma27 = ma_type == "EMA" ? ta.ema(close, ma_length27) : ma_type == "SMA" ? ta.sma(close, ma_length27) : ma_type == "WMA" ? ta.wma(close, ma_length27) : ma_type == "HMA" ? ta.hma(close, ma_length27) : ma_type == "VWMA" ? ta.vwma(close, ma_length27) : na
ma28 = ma_type == "EMA" ? ta.ema(close, ma_length28) : ma_type == "SMA" ? ta.sma(close, ma_length28) : ma_type == "WMA" ? ta.wma(close, ma_length28) : ma_type == "HMA" ? ta.hma(close, ma_length28) : ma_type == "VWMA" ? ta.vwma(close, ma_length28) : na
ma29 = ma_type == "EMA" ? ta.ema(close, ma_length29) : ma_type == "SMA" ? ta.sma(close, ma_length29) : ma_type == "WMA" ? ta.wma(close, ma_length29) : ma_type == "HMA" ? ta.hma(close, ma_length29) : ma_type == "VWMA" ? ta.vwma(close, ma_length29) : na
ma30 = ma_type == "EMA" ? ta.ema(close, ma_length30) : ma_type == "SMA" ? ta.sma(close, ma_length30) : ma_type == "WMA" ? ta.wma(close, ma_length30) : ma_type == "HMA" ? ta.hma(close, ma_length30) : ma_type == "VWMA" ? ta.vwma(close, ma_length30) : na
ma31 = ma_type == "EMA" ? ta.ema(close, ma_length31) : ma_type == "SMA" ? ta.sma(close, ma_length31) : ma_type == "WMA" ? ta.wma(close, ma_length31) : ma_type == "HMA" ? ta.hma(close, ma_length31) : ma_type == "VWMA" ? ta.vwma(close, ma_length31) : na
ma32 = ma_type == "EMA" ? ta.ema(close, ma_length32) : ma_type == "SMA" ? ta.sma(close, ma_length32) : ma_type == "WMA" ? ta.wma(close, ma_length32) : ma_type == "HMA" ? ta.hma(close, ma_length32) : ma_type == "VWMA" ? ta.vwma(close, ma_length32) : na
ma33 = ma_type == "EMA" ? ta.ema(close, ma_length33) : ma_type == "SMA" ? ta.sma(close, ma_length33) : ma_type == "WMA" ? ta.wma(close, ma_length33) : ma_type == "HMA" ? ta.hma(close, ma_length33) : ma_type == "VWMA" ? ta.vwma(close, ma_length33) : na
ma34 = ma_type == "EMA" ? ta.ema(close, ma_length34) : ma_type == "SMA" ? ta.sma(close, ma_length34) : ma_type == "WMA" ? ta.wma(close, ma_length34) : ma_type == "HMA" ? ta.hma(close, ma_length34) : ma_type == "VWMA" ? ta.vwma(close, ma_length34) : na
ma35 = ma_type == "EMA" ? ta.ema(close, ma_length35) : ma_type == "SMA" ? ta.sma(close, ma_length35) : ma_type == "WMA" ? ta.wma(close, ma_length35) : ma_type == "HMA" ? ta.hma(close, ma_length35) : ma_type == "VWMA" ? ta.vwma(close, ma_length35) : na
ma36 = ma_type == "EMA" ? ta.ema(close, ma_length36) : ma_type == "SMA" ? ta.sma(close, ma_length36) : ma_type == "WMA" ? ta.wma(close, ma_length36) : ma_type == "HMA" ? ta.hma(close, ma_length36) : ma_type == "VWMA" ? ta.vwma(close, ma_length36) : na
ma37 = ma_type == "EMA" ? ta.ema(close, ma_length37) : ma_type == "SMA" ? ta.sma(close, ma_length37) : ma_type == "WMA" ? ta.wma(close, ma_length37) : ma_type == "HMA" ? ta.hma(close, ma_length37) : ma_type == "VWMA" ? ta.vwma(close, ma_length37) : na
ma38 = ma_type == "EMA" ? ta.ema(close, ma_length38) : ma_type == "SMA" ? ta.sma(close, ma_length38) : ma_type == "WMA" ? ta.wma(close, ma_length38) : ma_type == "HMA" ? ta.hma(close, ma_length38) : ma_type == "VWMA" ? ta.vwma(close, ma_length38) : na
ma39 = ma_type == "EMA" ? ta.ema(close, ma_length39) : ma_type == "SMA" ? ta.sma(close, ma_length39) : ma_type == "WMA" ? ta.wma(close, ma_length39) : ma_type == "HMA" ? ta.hma(close, ma_length39) : ma_type == "VWMA" ? ta.vwma(close, ma_length39) : na
ma40 = ma_type == "EMA" ? ta.ema(close, ma_length40) : ma_type == "SMA" ? ta.sma(close, ma_length40) : ma_type == "WMA" ? ta.wma(close, ma_length40) : ma_type == "HMA" ? ta.hma(close, ma_length40) : ma_type == "VWMA" ? ta.vwma(close, ma_length40) : na
ma41 = ma_type == "EMA" ? ta.ema(close, ma_length41) : ma_type == "SMA" ? ta.sma(close, ma_length41) : ma_type == "WMA" ? ta.wma(close, ma_length41) : ma_type == "HMA" ? ta.hma(close, ma_length41) : ma_type == "VWMA" ? ta.vwma(close, ma_length41) : na
ma42 = ma_type == "EMA" ? ta.ema(close, ma_length42) : ma_type == "SMA" ? ta.sma(close, ma_length42) : ma_type == "WMA" ? ta.wma(close, ma_length42) : ma_type == "HMA" ? ta.hma(close, ma_length42) : ma_type == "VWMA" ? ta.vwma(close, ma_length42) : na
ma43 = ma_type == "EMA" ? ta.ema(close, ma_length43) : ma_type == "SMA" ? ta.sma(close, ma_length43) : ma_type == "WMA" ? ta.wma(close, ma_length43) : ma_type == "HMA" ? ta.hma(close, ma_length43) : ma_type == "VWMA" ? ta.vwma(close, ma_length43) : na
ma44 = ma_type == "EMA" ? ta.ema(close, ma_length44) : ma_type == "SMA" ? ta.sma(close, ma_length44) : ma_type == "WMA" ? ta.wma(close, ma_length44) : ma_type == "HMA" ? ta.hma(close, ma_length44) : ma_type == "VWMA" ? ta.vwma(close, ma_length44) : na
ma45 = ma_type == "EMA" ? ta.ema(close, ma_length45) : ma_type == "SMA" ? ta.sma(close, ma_length45) : ma_type == "WMA" ? ta.wma(close, ma_length45) : ma_type == "HMA" ? ta.hma(close, ma_length45) : ma_type == "VWMA" ? ta.vwma(close, ma_length45) : na
ma46 = ma_type == "EMA" ? ta.ema(close, ma_length46) : ma_type == "SMA" ? ta.sma(close, ma_length46) : ma_type == "WMA" ? ta.wma(close, ma_length46) : ma_type == "HMA" ? ta.hma(close, ma_length46) : ma_type == "VWMA" ? ta.vwma(close, ma_length46) : na
ma47 = ma_type == "EMA" ? ta.ema(close, ma_length47) : ma_type == "SMA" ? ta.sma(close, ma_length47) : ma_type == "WMA" ? ta.wma(close, ma_length47) : ma_type == "HMA" ? ta.hma(close, ma_length47) : ma_type == "VWMA" ? ta.vwma(close, ma_length47) : na
ma48 = ma_type == "EMA" ? ta.ema(close, ma_length48) : ma_type == "SMA" ? ta.sma(close, ma_length48) : ma_type == "WMA" ? ta.wma(close, ma_length48) : ma_type == "HMA" ? ta.hma(close, ma_length48) : ma_type == "VWMA" ? ta.vwma(close, ma_length48) : na
ma49 = ma_type == "EMA" ? ta.ema(close, ma_length49) : ma_type == "SMA" ? ta.sma(close, ma_length49) : ma_type == "WMA" ? ta.wma(close, ma_length49) : ma_type == "HMA" ? ta.hma(close, ma_length49) : ma_type == "VWMA" ? ta.vwma(close, ma_length49) : na
ma50 = ma_type == "EMA" ? ta.ema(close, ma_length50) : ma_type == "SMA" ? ta.sma(close, ma_length50) : ma_type == "WMA" ? ta.wma(close, ma_length50) : ma_type == "HMA" ? ta.hma(close, ma_length50) : ma_type == "VWMA" ? ta.vwma(close, ma_length50) : na
ma51 = ma_type == "EMA" ? ta.ema(close, ma_length51) : ma_type == "SMA" ? ta.sma(close, ma_length51) : ma_type == "WMA" ? ta.wma(close, ma_length51) : ma_type == "HMA" ? ta.hma(close, ma_length51) : ma_type == "VWMA" ? ta.vwma(close, ma_length51) : na
ma52 = ma_type == "EMA" ? ta.ema(close, ma_length52) : ma_type == "SMA" ? ta.sma(close, ma_length52) : ma_type == "WMA" ? ta.wma(close, ma_length52) : ma_type == "HMA" ? ta.hma(close, ma_length52) : ma_type == "VWMA" ? ta.vwma(close, ma_length52) : na
ma53 = ma_type == "EMA" ? ta.ema(close, ma_length53) : ma_type == "SMA" ? ta.sma(close, ma_length53) : ma_type == "WMA" ? ta.wma(close, ma_length53) : ma_type == "HMA" ? ta.hma(close, ma_length53) : ma_type == "VWMA" ? ta.vwma(close, ma_length53) : na
ma54 = ma_type == "EMA" ? ta.ema(close, ma_length54) : ma_type == "SMA" ? ta.sma(close, ma_length54) : ma_type == "WMA" ? ta.wma(close, ma_length54) : ma_type == "HMA" ? ta.hma(close, ma_length54) : ma_type == "VWMA" ? ta.vwma(close, ma_length54) : na
ma55 = ma_type == "EMA" ? ta.ema(close, ma_length55) : ma_type == "SMA" ? ta.sma(close, ma_length55) : ma_type == "WMA" ? ta.wma(close, ma_length55) : ma_type == "HMA" ? ta.hma(close, ma_length55) : ma_type == "VWMA" ? ta.vwma(close, ma_length55) : na

// Plot Moving Averages
p5 = plot(ma5, title="5th Moving Average", color=color.rgb(156, 39, 176, 50), style=plot.style_line, linewidth = 3)
plot(ma6, title="6th Moving Average", color=color.rgb(156, 39, 176, 80), style=plot.style_line)
p7 = plot(ma7, title="7th Moving Average", color=color.rgb(156, 39, 176, 80), style=plot.style_line)
p8 = plot(ma8, title="8th Moving Average", color=color.rgb(33, 150, 243, 50), style=plot.style_line, linewidth = 2)
//plot(ma9, title="9th Moving Average", color=color.rgb(33, 150, 243, 80), style=plot.style_line)
plot(ma10, title="10th Moving Average", color=color.rgb(33, 150, 243, 80), style=plot.style_line)
//plot(ma11, title="11th Moving Average", color=color.rgb(33, 150, 243, 80), style=plot.style_line)
p12 = plot(ma12, title="12th Moving Average", color=color.rgb(33, 150, 243, 80), style=plot.style_line)
p13 = plot(ma13, title="13th Moving Average", color=color.rgb(0, 137, 123, 50), style=plot.style_line, linewidth = 2)
//plot(ma14, title="14th Moving Average", color=color.rgb(0, 137, 123, 80), style=plot.style_line)
plot(ma15, title="15th Moving Average", color=color.rgb(0, 137, 123, 80), style=plot.style_line)
//plot(ma16, title="16th Moving Average", color=color.rgb(0, 137, 123, 80), style=plot.style_line)
//plot(ma17, title="17th Moving Average", color=color.rgb(0, 137, 123, 80), style=plot.style_line)
plot(ma18, title="18th Moving Average", color=color.rgb(0, 137, 123, 80), style=plot.style_line)
//plot(ma19, title="19th Moving Average", color=color.rgb(0, 137, 123, 80), style=plot.style_line)
p20 = plot(ma20, title="20th Moving Average", color=color.rgb(0, 137, 123, 80), style=plot.style_line)
p21 = plot(ma21, title="21st Moving Average", color=color.rgb(255, 235, 59, 50), style=plot.style_line, linewidth = 2)
//plot(ma22, title="22nd Moving Average", color=color.rgb(255, 235, 59, 80), style=plot.style_line)
plot(ma23, title="23rd Moving Average", color=color.rgb(255, 235, 59, 80), style=plot.style_line)
//plot(ma24, title="24th Moving Average", color=color.rgb(255, 235, 59, 80), style=plot.style_line)
plot(ma25, title="25th Moving Average", color=color.rgb(255, 235, 59, 80), style=plot.style_line)
//plot(ma26, title="26th Moving Average", color=color.rgb(255, 235, 59, 80), style=plot.style_line)
plot(ma27, title="27th Moving Average", color=color.rgb(255, 235, 59, 80), style=plot.style_line)
//plot(ma28, title="28th Moving Average", color=color.rgb(255, 235, 59, 80), style=plot.style_line)
plot(ma29, title="29th Moving Average", color=color.rgb(255, 235, 59, 80), style=plot.style_line)
//plot(ma30, title="30th Moving Average", color=color.rgb(255, 235, 59, 80), style=plot.style_line)
plot(ma31, title="31st Moving Average", color=color.rgb(255, 235, 59, 80), style=plot.style_line)
//plot(ma32, title="32nd Moving Average", color=color.rgb(255, 235, 59, 80), style=plot.style_line)
p33 = plot(ma33, title="33rd Moving Average", color=color.rgb(255, 235, 59, 80), style=plot.style_line)
p34 = plot(ma34, title="34th Moving Average", color=color.rgb(255, 152, 80, 50), style=plot.style_line, linewidth = 2)
//plot(ma35, title="35th Moving Average", color=color.rgb(255, 152, 80, 800), style=plot.style_line)
plot(ma36, title="36th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
//plot(ma37, title="37th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
plot(ma38, title="38th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
//plot(ma39, title="39th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
plot(ma40, title="40th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
//plot(ma41, title="41st Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
plot(ma42, title="42nd Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
//plot(ma43, title="43rd Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
plot(ma44, title="44th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
//plot(ma45, title="45th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
plot(ma46, title="46th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
//plot(ma47, title="47th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
plot(ma48, title="48th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
//plot(ma49, title="49th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
plot(ma50, title="50th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
//plot(ma51, title="51st Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
plot(ma52, title="52nd Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
//plot(ma53, title="53rd Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
p54 = plot(ma54, title="54th Moving Average", color=color.rgb(255, 152, 80, 80), style=plot.style_line)
p55 = plot(ma55, title="55th Moving Average", color=color.rgb(255, 82, 82, 50), style=plot.style_line, linewidth = 3)

fill(p5, p7, color=color.rgb(156, 39, 176, 90))
fill(p8, p12, color=color.rgb(33, 150, 243, 90))
fill(p13, p20, color=color.rgb(0, 137, 123, 90))
fill(p21, p33, color=color.rgb(255, 235, 59, 90))
fill(p34, p54, color=color.rgb(255, 152, 80, 90))

trend_down1 = ma5 < ma5[1] and ma8 > ma8[1] and ma13 > ma13[1] and ma21 > ma21[1] and ma34 > ma34[1] and ma55 > ma55[1]
trend_down2 = ma5 < ma5[1] and ma8 < ma8[1] and ma13 > ma13[1] and ma21 > ma21[1] and ma34 > ma34[1] and ma55 > ma55[1]
trend_down3 = ma5 < ma5[1] and ma8 < ma8[1] and ma13 < ma13[1] and ma21 > ma21[1] and ma34 > ma34[1] and ma55 > ma55[1]
trend_down4 = ma5 < ma5[1] and ma8 < ma8[1] and ma13 < ma13[1] and ma21 < ma21[1] and ma34 > ma34[1] and ma55 > ma55[1]
trend_down5 = ma5 < ma5[1] and ma8 < ma8[1] and ma13 < ma13[1] and ma21 < ma21[1] and ma34 < ma34[1] and ma55 > ma55[1]
trend_down6 = ma5 < ma5[1] and ma8 < ma8[1] and ma13 < ma13[1] and ma21 < ma21[1] and ma34 < ma34[1] and ma55 < ma55[1]

trend_up1 = ma5 > ma5[1] and ma8 < ma8[1] and ma13 < ma13[1] and ma21 < ma21[1] and ma34 < ma34[1] and ma55 < ma55[1]
trend_up2 = ma5 > ma5[1] and ma8 > ma8[1] and ma13 < ma13[1] and ma21 < ma21[1] and ma34 < ma34[1] and ma55 < ma55[1]
trend_up3 = ma5 > ma5[1] and ma8 > ma8[1] and ma13 > ma13[1] and ma21 < ma21[1] and ma34 < ma34[1] and ma55 < ma55[1]
trend_up4 = ma5 > ma5[1] and ma8 > ma8[1] and ma13 > ma13[1] and ma21 > ma21[1] and ma34 < ma34[1] and ma55 < ma55[1]
trend_up5 = ma5 > ma5[1] and ma8 > ma8[1] and ma13 > ma13[1] and ma21 > ma21[1] and ma34 > ma34[1] and ma55 < ma55[1]
trend_up6 = ma5 > ma5[1] and ma8 > ma8[1] and ma13 > ma13[1] and ma21 > ma21[1] and ma34 > ma34[1] and ma55 > ma55[1]

trend_down = (ma5 < ma5[1] and ma8 < ma8[1] and ma13 < ma13[1] and ma21 < ma21[1] and ma34 < ma34[1] and ma55 < ma55[1]) and not (ma5 < ma5[1] and ma8 < ma8[1] and ma13 < ma13[1] and ma21 < ma21[1] and ma34 < ma34[1] and ma55 < ma55[1])[1]
trend_up = (ma5 > ma5[1] and ma8 > ma8[1] and ma13 > ma13[1] and ma21 > ma21[1] and ma34 > ma34[1] and ma55 > ma55[1]) and not (ma5 > ma5[1] and ma8 > ma8[1] and ma13 > ma13[1] and ma21 > ma21[1] and ma34 > ma34[1] and ma55 > ma55[1])[1]

crossover = (ma5 < ma5[1] and ma8 < ma8[1] and ma13 < ma13[1] and ma21 < ma21[1] and ma34 < ma34[1] and ma55 < ma55[1])
crossunder = (ma5 > ma5[1] and ma8 > ma8[1] and ma13 > ma13[1] and ma21 > ma21[1] and ma34 > ma34[1] and ma55 > ma55[1])

crossover_area = (crossover and ma5 < ma8 and ma8 < ma13 and ma13 < ma21 and ma21 < ma34 and ma34 < ma55)
crossunder_area = (crossunder and ma5 > ma8 and ma8 > ma13 and ma13 > ma21 and ma21 > ma34 and ma34 > ma55)

indicator_negative = crossover_area and trend_down
indicator_positive = crossunder_area and trend_up

bgcolor(crossover ? color.rgb(160, 80, 100, 90) : na, title="Weak CrossOver Area BG")
bgcolor(crossunder ? color.rgb(80, 160, 130, 90) : na, title="Weak CrossUnder Area BG")

plotshape(crossover_area, style=shape.triangledown, location=location.bottom, color=color.rgb(170, 170, 170, 0), size=size.tiny, title="Strong CrossOver Area Indicator")
plotshape(crossunder_area, style=shape.triangleup, location=location.top, color=color.rgb(170, 170, 170), size=size.tiny, title="Strong CrossUnder Area Indicator")

bgcolor(crossover_area ? color.rgb(160, 80, 100, 90) : na, title="Strong CrossOver Area BG")
bgcolor(crossunder_area ? color.rgb(80, 160, 130, 90) : na, title="Strong CrossUnder Area BG")

plotshape(trend_down1, style=shape.labeldown, location=location.bottom, color=color.rgb(156, 39, 176, 0), size=size.tiny, title="MA(5) - DOWN")
plotshape(trend_down2, style=shape.labeldown, location=location.bottom, color=color.rgb(33, 150, 243, 0), size=size.tiny, title="MA(5/8) - DOWN")
plotshape(trend_down3, style=shape.labeldown, location=location.bottom, color=color.rgb(0, 137, 123, 0), size=size.tiny, title="MA(5/8/13) - DOWN")
plotshape(trend_down4, style=shape.labeldown, location=location.bottom, color=color.rgb(255, 235, 59, 0), size=size.tiny, title="MA(5/8/13/21) - DOWN")
plotshape(trend_down5, style=shape.labeldown, location=location.bottom, color=color.rgb(255, 152, 80, 0), size=size.tiny, title="MA(5/8/13/21/34) - DOWN")
plotshape(trend_down6, style=shape.labeldown, location=location.bottom, color=color.rgb(255, 82, 82, 0), size=size.tiny, title="MA(5/8/13/21/34/55) - DOWN")

plotshape(trend_up1, style=shape.labelup, location=location.top, color=color.rgb(156, 39, 176, 0), size=size.tiny, title="MA(5) - UP")
plotshape(trend_up2, style=shape.labelup, location=location.top, color=color.rgb(33, 150, 243, 0), size=size.tiny, title="MA(5/8) - UP")
plotshape(trend_up3, style=shape.labelup, location=location.top, color=color.rgb(0, 137, 123, 0), size=size.tiny, title="MA(5/8/13) - UP")
plotshape(trend_up4, style=shape.labelup, location=location.top, color=color.rgb(255, 235, 59, 0), size=size.tiny, title="MA(5/8/13/21) - UP")
plotshape(trend_up5, style=shape.labelup, location=location.top, color=color.rgb(255, 152, 80, 0), size=size.tiny, title="MA(5/8/13/21/34) - UP")
plotshape(trend_up6, style=shape.labelup, location=location.top, color=color.rgb(255, 82, 82, 0), size=size.tiny, title="MA(5/8/13/21/34/55) - UP")

plotshape(trend_down and not indicator_negative, style=shape.triangledown, location=location.abovebar, color=color.rgb(170, 170, 170, 0), size=size.tiny, title="Super Trend Down")
plotshape(trend_up and not indicator_positive, style=shape.triangleup, location=location.belowbar, color=color.rgb(170, 170, 170, 0), size=size.tiny, title="Super Trend Up")

plotshape(indicator_negative, style=shape.triangledown, location=location.abovebar, color=color.rgb(170, 170, 170, 0), size=size.small, title="Mega Trend Down")
plotshape(indicator_positive, style=shape.triangleup, location=location.belowbar, color=color.rgb(170, 170, 170, 0), size=size.small, title="Super Trend Up")

bgcolor(indicator_negative ? color.rgb(160, 80, 100, 85) : na, title="Sell Indicator BG")
bgcolor(indicator_positive ? color.rgb(80, 160, 130, 85) : na, title="Buy Indicator BG")

// Create an alert when the condition is true
alertcondition(trend_down, title="Super Trend Down", message="All MAs are in freefall!")
alertcondition(trend_up, title="Super Trend Up", message="All MAs are on the rise!")
alertcondition(indicator_negative, title="Mega Trend Down", message="All MAs are align correctly in freefall!")
alertcondition(indicator_positive, title="Mega Trend Up", message="All MAs are align correctly on the rise!")
````
