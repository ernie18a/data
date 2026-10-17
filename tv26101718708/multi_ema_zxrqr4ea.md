# Multi EMA

- url: https://www.tradingview.com/script/zXRQR4eA-Multi-EMA/
- type: indicator
- pine_id: PUB;39053d6ebe2e45cdb0b46ec84463d7b5
- version: 1.0

## Description

Hello, adding multiple EMA (Exponential Moving Average) lines to your chart makes it easier to observe trends across different timeframes.

This Pine Script (v5) code allows you to add up to 5 EMA lines as desired. You can enable/disable each line and change its length and color directly in the settings.

## Source Code

````pine
// @version=5
indicator("Multi EMA", overlay=true)

// --- CẤU HÌNH INPUT ---
// EMA 1
showEma1 = input.bool(true, "Hiển thị EMA 1", group="EMA 1")
len1     = input.int(20, "Chiều dài EMA 1", minval=1, group="EMA 1")
col1     = input.color(color.blue, "Màu EMA 1", group="EMA 1")

// EMA 2
showEma2 = input.bool(true, "Hiển thị EMA 2", group="EMA 2")
len2     = input.int(50, "Chiều dài EMA 2", minval=1, group="EMA 2")
col2     = input.color(color.red, "Màu EMA 2", group="EMA 2")

// EMA 3
showEma3 = input.bool(true, "Hiển thị EMA 3", group="EMA 3")
len3     = input.int(100, "Chiều dài EMA 3", minval=1, group="EMA 3")
col3     = input.color(color.orange, "Màu EMA 3", group="EMA 3")

// EMA 4
showEma4 = input.bool(true, "Hiển thị EMA 4", group="EMA 4")
len4     = input.int(200, "Chiều dài EMA 4", minval=1, group="EMA 4")
col4     = input.color(color.purple, "Màu EMA 4", group="EMA 4")

// EMA 5
showEma5 = input.bool(false, "Hiển thị EMA 5", group="EMA 5")
len5     = input.int(800, "Chiều dài EMA 5", minval=1, group="EMA 5")
col5     = input.color(color.gray, "Màu EMA 5", group="EMA 5")

// --- TÍNH TOÁN ---
ema1 = ta.ema(close, len1)
ema2 = ta.ema(close, len2)
ema3 = ta.ema(close, len3)
ema4 = ta.ema(close, len4)
ema5 = ta.ema(close, len5)

// --- HIỂN THỊ (PLOT) ---
plot(showEma1 ? ema1 : na, color=col1, title="EMA 1", linewidth=2)
plot(showEma2 ? ema2 : na, color=col2, title="EMA 2", linewidth=2)
plot(showEma3 ? ema3 : na, color=col3, title="EMA 3", linewidth=2)
plot(showEma4 ? ema4 : na, color=col4, title="EMA 4", linewidth=2)
plot(showEma5 ? ema5 : na, color=col5, title="EMA 5", linewidth=2)
````
