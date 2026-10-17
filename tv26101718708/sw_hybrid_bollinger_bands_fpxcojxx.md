# SW Hybrid Bollinger Bands

- url: https://www.tradingview.com/script/fPXcOJxx-SW-Hybrid-Bollinger-Bands/
- type: indicator
- pine_id: PUB;993fab2fe6044ce69833992814c51c11
- version: 1.0

## Description

## Overview
Welcome to the **SW Hybrid Bollinger Bands**, a modern take on the classic Bollinger Bands volatility indicator. 

Unlike traditional Bollinger Bands that strictly use the closing price and a single Simple Moving Average (SMA), this script dynamically calculates standard deviation bands based on both the **High** and **Low** price points of candles. Furthermore, it incorporates both **EMA (Exponential Moving Average)** and **WMA (Weighted Moving Average)** to provide a smoother, more responsive volatility channel.

---

## How It Works
The indicator splits the volatility channels into two distinct zones:

* **Green Channels (High-Based):** Calculated using the candle's *High* price, integrated with EMA and WMA. These act as ultimate dynamic resistance zones and momentum gauges for upside moves.
* **Purple Channels (Low-Based):** Calculated using the candle's *Low* price, integrated with EMA and WMA. These serve as dynamic support zones and exhaustion areas during downward trends.
* **Center Line (White):** A standard 20-period SMA to keep you anchored to the baseline trend.

By blending EMA (which reacts faster to recent price action) and WMA (which emphasizes linear weight), the fills between these lines create unique **"Liquidity/Volatility Belts"** rather than single strict lines.

---

## How to Trade with It
1. **Trend Riding:** During strong uptrends, the price tends to float between the 20 SMA and the upper Green Channels. In strong downtrends, it stays between the 20 SMA and the lower Purple Channels.
2. **Reversals & Exhaustion:** When the price penetrates deep into the outer green or purple filled zones, it often signals an overextended market, hinting at a potential mean-reversion back to the white 20 SMA.
3. **Volatility Squeezes:** When the green and purple bands compress tightly towards each other, expect a massive explosive breakout soon.

---

## Release Notes
* **Open Source:** Free for the community! Feel free to favorite, share, and modify.
* **Version:** Pine Script v6 optimized.
* **Clean Visuals:** Red color elements updated to sleek **Purple** for better chart readability and modern aesthetic.

*Disclaimer: This script is for educational and informational purposes only. Past performance does not guarantee future results.*

## Source Code

````pine
//@version=6
indicator('SW Hybrid Bollinger Bands', overlay = true)

length = input.int(20, title = 'Length')
mult = input.float(2.0, title = 'StdDev Multiplier')

// --- High Price Bands ---
devHigh = ta.stdev(high, length) * mult
emaHigh = ta.ema(high, length)
wmaHigh = ta.wma(high, length)

sma20 = ta.sma(close, length)
plot(sma20, color = color.white, linewidth = 1, title = '20 SMA')

highUpperEMA = emaHigh + devHigh
highUpperWMA = wmaHigh + devHigh

highLowerEMA = emaHigh - devHigh
highLowerWMA = wmaHigh - devHigh

h1 = plot(highUpperEMA, color = color.green, linewidth = 1)
h2 = plot(highUpperWMA, color = color.green, linewidth = 1)
h3 = plot(highLowerEMA, color = color.green, linewidth = 1)
h4 = plot(highLowerWMA, color = color.green, linewidth = 1)

fill(h1, h2, color = color.new(color.green, 70))
fill(h3, h4, color = color.new(color.green, 70))

// --- Low Price Bands (Updated to Purple) ---
devLow = ta.stdev(low, length) * mult
emaLow = ta.ema(low, length)
wmaLow = ta.wma(low, length)

lowUpperEMA = emaLow + devLow
lowUpperWMA = wmaLow + devLow

lowLowerEMA = emaLow - devLow
lowLowerWMA = wmaLow - devLow

l1 = plot(lowUpperEMA, color = color.purple, linewidth = 1)
l2 = plot(lowUpperWMA, color = color.purple, linewidth = 1)
l3 = plot(lowLowerEMA, color = color.purple, linewidth = 1)
l4 = plot(lowLowerWMA, color = color.purple, linewidth = 1)

fill(l1, l2, color = color.new(color.purple, 70))
fill(l3, l4, color = color.new(color.purple, 70))
````
