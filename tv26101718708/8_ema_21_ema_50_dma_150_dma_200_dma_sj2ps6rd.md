# 8 ema 21 ema 50 dma 150 dma 200 dma

- url: https://www.tradingview.com/script/Sj2pS6Rd-8-ema-21-ema-50-dma-150-dma-200-dma/
- type: indicator
- pine_id: PUB;b81827c61b75411fb3fa8de5ea237426
- version: 2.0

## Description

8 ema 21 ema 50 dma 150 dma 200 dma script to track stage 1, 2, 3, 4 level of perforamance

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quant

//@version=6
indicator("Multiple Moving Averages", overlay = true)

// --- Inputs ---
ema8Len   = input.int(8,   "EMA 8",   group = "Exponential Moving Averages")
ema21Len  = input.int(21,  "EMA 21",  group = "Exponential Moving Averages")

sma50Len  = input.int(50,  "SMA 50",  group = "Daily Moving Averages (SMA)")
sma150Len = input.int(150, "SMA 150", group = "Daily Moving Averages (SMA)")
sma200Len = input.int(200, "SMA 200", group = "Daily Moving Averages (SMA)")

// --- Calculations ---
ema8   = ta.ema(close, ema8Len)
ema21  = ta.ema(close, ema21Len)

sma50  = ta.sma(close, sma50Len)
sma150 = ta.sma(close, sma150Len)
sma200 = ta.sma(close, sma200Len)

// --- Plots ---
plot(ema8,   "8 EMA",   color = color.new(#2962ff, 0), style = plot.style_line)
plot(ema21,  "21 EMA",  color = color.new(#03aa27, 0), style = plot.style_line)
plot(sma50,  "50 DMA",  color = color.new(#f7ff07, 0), style = plot.style_line)
plot(sma150, "150 DMA", color = color.new(#f29a36, 0), style = plot.style_line)
plot(sma200, "200 DMA", color = color.new(#ef4242, 0), style = plot.style_line)
````
