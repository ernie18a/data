# 5M Range + Squeeze Detector

- url: https://www.tradingview.com/script/PNFj0VgE-5M-Range-Squeeze-Detector/
- type: indicator
- pine_id: PUB;c8be64c013e343d888175fe22a408871
- version: 1.0

## Description

To monitor a ranging / consolidation in monthly chart

You can edit the range (LEN) by your self.

## Source Code

````pine
//@version=5
indicator("5M Range + Squeeze Detector", overlay=true)

len = 5
threshold = 0.20

// 5个月区间
hh = ta.highest(high, len)
ll = ta.lowest(low, len)
rangePct = (hh - ll) / ll

// 前一个区间（用于压缩判断）
hh_prev = ta.highest(high, len * 2)[len]
ll_prev = ta.lowest(low, len * 2)[len]
prevRange = (hh_prev - ll_prev) / ll_prev

// 横盘条件
isRange = rangePct <= threshold

// 压缩条件（突破前夜）
isSqueeze = rangePct < prevRange * 0.6

// 最终信号
setup = isRange and isSqueeze

bgcolor(setup ? color.new(color.orange, 80) : na)

plotshape(setup, style=shape.triangleup, location=location.top, color=color.orange, size=size.small, text="SQUEEZE")
````
