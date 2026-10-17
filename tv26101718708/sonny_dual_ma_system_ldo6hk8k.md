# Sonny Dual MA System

- url: https://www.tradingview.com/script/LDO6Hk8k/
- type: indicator
- pine_id: PUB;6acf115d45684754995a3d8003721ab2
- version: 1.0

## Description

Sonny Dual MA System is a clean trend-following indicator designed to provide a simple visual framework for identifying short-, medium-, and long-term market trends.

The indicator combines Simple Moving Averages (SMA) and Exponential Moving Averages (EMA) across three key periods:

* 20 MA — Short-term trend
* 60 MA — Medium-term trend
* 120 MA — Long-term trend

Each period displays both an SMA and EMA, allowing traders to compare the smoother trend structure of the SMA with the faster price response of the EMA.

How to Read It

When shorter-period moving averages are positioned above longer-period averages, the market generally shows a stronger bullish structure.

When shorter-period moving averages are positioned below longer-period averages, the market generally shows a stronger bearish structure.

The relationship between the SMA and EMA within each period can also help visualize changes in momentum and potential trend transitions.

Historical Reference Dots

The yellow dots mark the price location from 20, 60, and 120 bars ago, providing a quick visual reference for comparing current price action with previous market structure.

Features

• SMA 20 / EMA 20
• SMA 60 / EMA 60
• SMA 120 / EMA 120
• Short-, medium-, and long-term trend visualization
• Historical 20 / 60 / 120-bar reference markers
• Designed for clean chart analysis across multiple timeframes

This indicator is intended as a market structure and trend visualization tool rather than a standalone buy or sell signal system.

For educational and informational purposes only.

## Source Code

````pine
//@version=6
indicator("均线系统", shorttitle="均", overlay=true)

// —— 均线计算
sma20  = ta.sma(close, 20)
sma60  = ta.sma(close, 60)
sma120 = ta.sma(close, 120)

ema20  = ta.ema(close, 20)
ema60  = ta.ema(close, 60)
ema120 = ta.ema(close, 120)

// —— 绘制均线
plot(sma20,  color=color.black,                title="SMA20")
plot(ema20,  color=color.new(color.black, 50), title="EMA20")

plot(sma60,  color=color.blue,                 title="SMA60")
plot(ema60,  color=color.new(color.blue, 50),  title="EMA60")

plot(sma120, color=color.purple,               title="SMA120")
plot(ema120, color=color.new(color.purple, 50),title="EMA120")

// —— 圆点定位
cond    = barstate.islast
bl      = low

moveBar = input.int(0,   title="Move Bar")
x20     = input.int(20,  title="X20 Offset")  + moveBar
x60     = input.int(60,  title="X60 Offset")  + moveBar
x120    = input.int(120, title="X120 Offset") + moveBar

plot(cond ? bl[20]  : na, color=color.new(#FFC40C, 0), linewidth=5, offset=-x20,  style=plot.style_circles, title="Dot20")
plot(cond ? bl[60]  : na, color=color.new(#FFC40C, 0), linewidth=5, offset=-x60,  style=plot.style_circles, title="Dot60")
plot(cond ? bl[120] : na, color=color.new(#FFC40C, 0), linewidth=5, offset=-x120, style=plot.style_circles, title="Dot120")
````
