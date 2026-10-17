# SERHAN 3 (EMD Trend + Supertrend Strategy)

- url: https://www.tradingview.com/script/XF2gEG0c/
- type: strategy
- pine_id: PUB;6a43d4aba0044d06a0e69e0530e364eb
- version: 2.0

## Description

I added the Supertrend Strategy to the EMD Trend indicator as a filter and optimized it as much as possible for very short-term scalping. The optimizations targeted BIST 30 companies.

## Source Code

````pine
//@version=5
strategy("WMA + RSI Filtreli Scalp", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// --- Girdiler ---
fastLen = input.int(9, title="Hızlı WMA", minval=1)
slowLen = input.int(21, title="Yavaş WMA", minval=1)
rsiLen  = input.int(14, title="RSI Periyodu", minval=1)

// --- Hesaplamalar ---
fastWMA = ta.wma(close, fastLen)
slowWMA = ta.wma(close, slowLen)
rsiVal  = ta.rsi(close, rsiLen)

// --- Çizimler ---
plot(fastWMA, color=color.blue, title="Hızlı WMA")
plot(slowWMA, color=color.orange, title="Yavaş WMA")

// --- Koşullar ---
// Long: Kesişim + Fiyat Ortalamaların Üstünde + RSI 55'den Büyük
longCondition = ta.crossover(fastWMA, slowWMA) and close > fastWMA and close > slowWMA and rsiVal > 50

// Short: Kesişim + Fiyat Ortalamaların Altında + RSI 45'den Küçük
shortCondition = ta.crossunder(fastWMA, slowWMA) and close < fastWMA and close < slowWMA and rsiVal < 50

// --- Emirler ---
if (longCondition)
    strategy.entry("Long", strategy.long, comment="Güçlü Long")

if (shortCondition)
    strategy.entry("Short", strategy.short, comment="Güçlü Short")
````
