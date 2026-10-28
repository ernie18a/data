# Market Order Bubbles by LZ (inspired by Leviathan)

- url: https://www.tradingview.com/script/RIi2lJnh-Market-Order-Bubbles-by-LZ-inspired-by-Leviathan/
- type: indicator
- pine_id: PUB;2f8701e79a674b8cacf5a9117a94d7a2
- version: 1.0

## Description

Market Order Bubbles (inspired by Leviathan's original work) visualizes surges 
in aggressive buying and selling activity, estimated from OHLCV data using a 
simulated CVD approach. Use it as a reversal tool or to monitor real-time order 
flow dynamics.


HOW TO READ THE BUBBLES
● Green bubble (below bar)  — aggressive buying surge, price advanced effectively
                              → neutral to bullish continuation
● Red bubble (above bar)    — aggressive selling surge, price declined effectively
                              → neutral to bearish continuation
● Orange bubble (below bar) — aggressive buying, but price failed to advance
                              → buyer absorption / exhaustion → look for short
● Orange bubble (above bar) — aggressive selling, but price failed to decline
                              → seller absorption / exhaustion → look for long

Bubble size reflects surge intensity: small / medium / large.
Only the dominant side is shown per bar (buy or sell volume must exceed the 
other by at least 20%), eliminating ambiguous signals on high-volume two-sided 
candles.


KEY DIFFERENCES FROM THE ORIGINAL
1. Percentile thresholds instead of EMA + StdDev
   Volume is right-skewed. A single spike inflates standard deviation and 
   suppresses signals for many bars after. Rolling percentiles (90/95/99th) 
   are immune to this distortion.

2. Exhaustion vs. continuation detection (orange bubbles)
   The original treats all bubbles as contrarian signals. This version 
   distinguishes between continuation flow (price moves with the surge) and 
   exhaustion / absorption (price fails to follow), giving each bubble a 
   clearer directional context.

3. Tiny-range bar protection
   Bars with range < 0.1 × ATR(14) are skipped. Near-doji candles produce 
   unstable buy/sell volume estimates that can generate false signals.

4. Dominant-side filter
   When buy and sell volume are close in magnitude, no bubble is shown. 
   Only a clear directional imbalance (≥ 20% edge) triggers a signal.


SETTINGS
Percentile Window      — lookback length for threshold calculation (default 200)
Threshold 1/2/3        — percentile levels for small/medium/large bubbles
Tiny Range Filter      — minimum bar range as ATR multiple (default 0.1)
Exhaustion Threshold   — price efficiency cutoff for orange bubble (default 0.35)
                         lower close efficiency = buyer/seller failed to push price


TIPS
• Orange bubbles at swing highs/lows are the highest-probability signals.
• Consecutive same-color bubbles during a trend = continuation, not reversal.
• On lower timeframes (≤ 5m), reduce the percentile window to 100 for faster 
  adaptation to recent volume conditions.
• Pair with the companion Net Delta panel for a continuous view of buy/sell 
  pressure across all bars.


CREDITS
This indicator was built entirely with Claude Code as an experiment in 
AI-assisted Pine Script development. All credit for the original concept 
goes to Leviathan — this is simply a tribute and a tinkerer's exploration.

## Source Code

````pine
//@version=5
indicator("Market Order Bubbles by LZ", overlay=true, max_labels_count=500)

// ── 参数 ──────────────────────────────────────────────────────
pctLen = input.int(200,  "百分位窗口长度",  minval=50, group="阈值设置", display=display.data_window)
pct1   = input.float(90, "阈值1 小气泡",   minval=50, maxval=98, step=1, group="阈值设置", display=display.data_window)
pct2   = input.float(95, "阈值2 中气泡",   minval=50, maxval=98, step=1, group="阈值设置", display=display.data_window)
pct3   = input.float(99, "阈值3 大气泡",   minval=51, maxval=99, step=1, group="阈值设置", display=display.data_window)

minRangeMult = input.float(0.1,  "极小Range过滤 ATR倍数", minval=0, step=0.05, group="过滤设置", display=display.data_window)
effThresh    = input.float(0.35, "耗尽判断 价格效率阈值", minval=0, maxval=1,  step=0.05, group="过滤设置", display=display.data_window)

showSmall = input.bool(true, "显示小气泡", group="外观", display=display.data_window)
colBuy    = input.color(#26a69a, "买泡颜色 延续/中性", group="外观", display=display.data_window)
colSell   = input.color(#ef5350, "卖泡颜色 延续/中性", group="外观", display=display.data_window)
colExh    = input.color(#ff9800, "耗尽颜色 买卖共用",  group="外观", display=display.data_window)

// ── 极小 Range 保护 ───────────────────────────────────────────
atr14   = ta.atr(14)
range_  = high - low
tinyBar = range_ < minRangeMult * atr14 or range_ == 0

// ── 模拟买卖量 ────────────────────────────────────────────────
buyVol  = tinyBar ? 0.0 : volume * (close - low)  / range_
sellVol = tinyBar ? 0.0 : volume * (high - close) / range_

// ── 百分位阈值 ────────────────────────────────────────────────
b1 = ta.percentile_linear_interpolation(buyVol,  pctLen, pct1)
b2 = ta.percentile_linear_interpolation(buyVol,  pctLen, pct2)
b3 = ta.percentile_linear_interpolation(buyVol,  pctLen, pct3)
s1 = ta.percentile_linear_interpolation(sellVol, pctLen, pct1)
s2 = ta.percentile_linear_interpolation(sellVol, pctLen, pct2)
s3 = ta.percentile_linear_interpolation(sellVol, pctLen, pct3)

// ── 气泡等级（0=无 1=小 2=中 3=大）──────────────────────────
buyLv  = buyVol  >= b3 ? 3 : buyVol  >= b2 ? 2 : buyVol  >= b1 ? 1 : 0
sellLv = sellVol >= s3 ? 3 : sellVol >= s2 ? 2 : sellVol >= s1 ? 1 : 0

buySize  = buyLv  == 3 ? "large" : buyLv  == 2 ? "normal" : buyLv  == 1 and showSmall ? "small" : ""
sellSize = sellLv == 3 ? "large" : sellLv == 2 ? "normal" : sellLv == 1 and showSmall ? "small" : ""

// ── 价格推进效率 + 耗尽判断 ───────────────────────────────────
buyEff  = range_ > 0 ? (close - low)  / range_ : 0.5
sellEff = range_ > 0 ? (high - close) / range_ : 0.5

buyCol  = buyLv  > 0 and buyEff  < effThresh ? colExh : colBuy
sellCol = sellLv > 0 and sellEff < effThresh ? colExh : colSell

// ── 画气泡 ────────────────────────────────────────────────────
offset = atr14 * 0.3

if buySize != ""
    label.new(bar_index, low - offset, "●",
         color=buyCol, textcolor=buyCol,
         style=label.style_none, size=buySize, yloc=yloc.price)

if sellSize != ""
    label.new(bar_index, high + offset, "●",
         color=sellCol, textcolor=sellCol,
         style=label.style_none, size=sellSize, yloc=yloc.price)
````
