# RSI EMA(WMA45)

- url: https://www.tradingview.com/script/JoheyaIg/
- type: indicator
- pine_id: PUB;c422faa6d33449b8b4220ba5c8ac72d6
- version: 1.0

## Description

zxc rsi 14 kết hợp wma 45
áld; ;skmdl;ák adl;kasjdas dalskdj;ád

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © sotogax320

//@version=6
indicator("RSI EMA(WMA45)", shorttitle="RSI EMA(WMA45)", overlay=false, precision=2)

// ── Inputs ─────────────────────────────────────────────
rsi_len = input.int(14, title="RSI Length", minval=1)
wma_len = input.int(45, title="WMA Length", minval=1)
src     = input.source(close, title="Source")

// ── Calculations ───────────────────────────────────────
rsiValue = ta.rsi(src, rsi_len)
wmaValue = ta.wma(rsiValue, wma_len)

// ── RSI Color ──────────────────────────────────────────
// Chỉ đoạn RSI >70 hoặc <30 chuyển đỏ
rsiColor = rsiValue > 70 or rsiValue < 30 ? color.red : color.white

// ── Plots ──────────────────────────────────────────────
plot(
     rsiValue,
     title="RSI",
     color=rsiColor,
     linewidth=2,
     style=plot.style_line
)

plot(wmaValue, title="WMA45 RSI", color=color.red, linewidth=2)

// ── Levels ─────────────────────────────────────────────
hline(80, "80", color=color.gray)
hline(66.66, "66.66", color=color.gray, linestyle=hline.style_dashed)

hline(60, "60", color=color.yellow, linestyle=hline.style_dashed)
hline(50, "50", color=color.green, linestyle=hline.style_dashed)
hline(40, "40", color=color.aqua, linestyle=hline.style_dashed)

hline(33.33, "33.33", color=color.gray, linestyle=hline.style_dashed)
hline(20, "20", color=color.gray)
````
