# up/down VolumeRatio

- url: https://www.tradingview.com/script/dapl76nq-up-down-VolumeRatio/
- type: indicator
- pine_id: PUB;66c4b73f01f14c01a121082cfbb1b63a
- version: 1.0

## Description

Idea:
Measure the directional dominance of trading volume by comparing aggregated up-volume versus down-volume, then stabilize the signal using a logarithmic transformation and EMA smoothing.

Rationale:
The ratio of up-volume to down-volume captures the imbalance between buying and selling pressure. Log transformation ensures symmetry and reduces extreme value distortion, while EMA extracts persistent trends in volume flow.

Usage:
Use the log ratio crossing its EMA as a signal of momentum shift. Positive values indicate bullish dominance, negative values indicate bearish dominance.

## Source Code

````pine
//@version=6
indicator("Log UDVR + EMA", shorttitle="Log_UDVR_EMA", overlay=false)

// === 参数 ===
len      = input.int(20, "UDVR Length", minval=1)
ema_len  = input.int(10, "EMA Length", minval=1)

// === 成交量拆分 ===
upVol   = ta.change(close) > 0 ? volume : 0.0
downVol = ta.change(close) < 0 ? volume : 0.0

// === 滚动求和（v6 标准）===
sumUp   = math.sum(upVol, len)
sumDown = math.sum(downVol, len)

// === 比率 ===
ratio = sumDown > 0 ? sumUp / sumDown : na

// === 对数化（稳定结构）===
logRatio = math.log(ratio)

// === EMA 平滑 ===
logRatioEMA = ta.ema(logRatio, ema_len)

// === 绘图 ===
plot(logRatio,     title="Log UDVR", color=color.blue, linewidth=2)
plot(logRatioEMA,  title="EMA",      color=color.orange, linewidth=2)

hline(0, "Neutral Line", color=color.gray)
````
