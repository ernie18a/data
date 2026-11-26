# Breakout Radar PRO

- url: https://www.tradingview.com/script/uxLWRqgR-Breakout-Radar-PRO/
- type: indicator
- pine_id: PUB;9537e0b550d24a68a4446c718c1819c4
- version: 1.0

## Description

🟢 股票 Stocks（推荐）
Range Threshold = 0.20
Squeeze = 0.6
Timeframe = Monthly

🟡 Crypto
Crypto 波动太大：
建议：
Range Threshold = 0.30~0.40
Squeeze = 0.7

🟠 Forex
Range Threshold = 0.10~0.15

## Source Code

````pine
//@version=5
indicator("Breakout Radar PRO", overlay=true)

// ===== 参数 =====
len = input.int(5, "Monthly Range Length")
threshold = input.float(0.20, "Max Range %")
squeezeFactor = input.float(0.6, "Squeeze Factor")
volLen = input.int(5, "Volume Average Length")

// ===== 当前区间 =====
hh = ta.highest(high, len)
ll = ta.lowest(low, len)

rangePct = (hh - ll) / ll

// ===== 前区间（用于比较压缩）=====
hh_prev = ta.highest(high, len * 2)[len]
ll_prev = ta.lowest(low, len * 2)[len]

prevRange = (hh_prev - ll_prev) / ll_prev

// ===== 横盘 =====
isRange = rangePct <= threshold

// ===== 压缩 =====
isSqueeze = rangePct < prevRange * squeezeFactor

// ===== 成交量收缩 =====
volNow = ta.sma(volume, volLen)
volPrev = ta.sma(volume, volLen)[len]

isVolumeDry = volNow < volPrev

// ===== 最终 setup =====
setup = isRange and isSqueeze and isVolumeDry

// ===== 突破条件 =====
breakout = close > hh[1]

// ===== 背景 =====
bgcolor(setup ? color.new(color.orange, 85) : na)

// ===== 标记 =====
plotshape(setup,
     style=shape.circle,
     color=color.orange,
     size=size.small,
     location=location.top,
     title="Setup")

plotshape(breakout and setup,
     style=shape.triangleup,
     color=color.lime,
     size=size.large,
     location=location.abovebar,
     title="Breakout")

// ===== Alert =====
alertcondition(setup,
     title="Squeeze Setup",
     message="Potential breakout setup detected")

alertcondition(breakout and setup,
     title="Breakout Trigger",
     message="Breakout confirmed")
````
