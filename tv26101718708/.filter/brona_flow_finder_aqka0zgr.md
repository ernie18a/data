# BroNa Flow Finder

- url: https://www.tradingview.com/script/aQkA0zgr-BroNa-Flow-Finder/
- type: indicator
- pine_id: PUB;6f2fba423ddb47b09c19ddf05352f7b0
- version: 1.0

## Description

Indicator Logic:
The stock first goes through a period of low-volume consolidation (recent volume contraction), indicating accumulation. There are no signs of distribution, as the last two candles do not show bearish closes with increased volume.
Then, today’s volume suddenly expands significantly (multiple of recent levels), accompanied by either a bullish candle or a gap-down bearish candle.
This represents a classic “low-volume buildup → explosive volume breakout” pattern, aiming to capture the exact moment when smart money finishes accumulation and initiates a strong move.

## Source Code

````pine
// 量能选股指标 — 从通达信迁移
//@version=5
indicator("量能选股", overlay=false, max_bars_back=200)

// ── 成交量均线
ma5   = ta.sma(volume, 5)
ma35  = ta.sma(volume, 35)
ma135 = ta.sma(volume, 135)

// ── 缩量 / 放量
suoliang = volume < ma5  and volume < ma35  and volume < ma135
fangliang = volume > ma5 or  volume > ma35  or  volume > ma135

// ── 倍量条件（量比 ≥ 1.91）
volRatio = volume / volume[1]

beiliangYangxian = volRatio >= 1.91 and close > open
beiliangYinxian  = volRatio >= 1.91 and low   > high[1] and open > close

// ── 收阴放量
shouYinFangliang = close < open and fangliang

// ── 选股条件
cond1 = ta.barssince(suoliang) <= 2
cond2 = ta.barssince(shouYinFangliang) > 1
cond3 = beiliangYangxian or beiliangYinxian

xuangu = cond1 and cond2 and cond3

// ── 绘图
plot(ma5,   title="MA5",   color=color.new(color.yellow, 0), linewidth=1)
plot(ma35,  title="MA35",  color=color.new(color.orange, 0), linewidth=1)
plot(ma135, title="MA135", color=color.new(color.red,    0), linewidth=1)

barColor = xuangu           ? color.new(#ff4444, 0)  :
           beiliangYangxian ? color.new(#ff8800, 30) :
           beiliangYinxian  ? color.new(#aa44ff, 30) :
           close > open     ? color.new(color.red,   40) :
                              color.new(color.green, 40)

plot(volume, style=plot.style_columns, color=barColor, title="成交量")

plotshape(xuangu, title="选股信号",
     location=location.top,
     style=shape.labelup,
     color=color.new(#ff4444, 0),
     text="选", textcolor=color.white, size=size.small)

bgcolor(xuangu ? color.new(#ff4444, 90) : na, title="选股高亮")
````
