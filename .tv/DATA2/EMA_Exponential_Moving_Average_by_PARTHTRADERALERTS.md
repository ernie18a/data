<!-- tradingview-pine-id: PUB;a763ca57c27a4b32997c552958ec54c3 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# EMA (Exponential Moving Average) by PARTHTRADERALERTS

Source: https://www.tradingview.com/script/nAvWTKP7-EMA-Exponential-Moving-Average-by-PARTHTRADERALERTS/

## Description

EMA (Exponential Moving Average) by PARTHTRADERALERTS

This is a clean and simple Multi EMA indicator designed for Price Action and Trend Trading.

What is EMA?
Exponential Moving Average (EMA) gives more weight to recent price, so it reacts faster than SMA. Perfect for intraday and swing trading.

Features in this Indicator:
✅ 6 EMAs in one indicator - 9, 11, 45, 30, 50, 100
✅ Default ON: EMA 9 (RED), EMA 11 (GREEN), EMA 45 (MAGENTA)
✅ Default OFF: EMA 30, 50, 100 - You can enable from settings
✅ Fully Customizable: You can change Length, Color, Width, Source
✅ Clean Chart: No extra boxes, no repaint, overlay fixed on price
✅ Works on All Markets: Stocks, Nifty, BankNifty, Crypto, Forex, Commodity

How to Use This Strategy?
1. TREND IDENTIFICATION: If price is above EMA 45, trend is UP. If below, trend is DOWN.
2. ENTRY SIGNAL (9/11 Crossover): When EMA 9 crosses above EMA 11 = Buy Signal. When EMA 9 crosses below EMA 11 = Sell Signal.
3. STRONG CONFIRMATION: Take buy trade only when Price > EMA 9 > EMA 11 > EMA 45. Opposite for sell.
4. STOP LOSS: Use EMA 45 as a trailing stop loss for swing trades.

Best Timeframe: 5 Min, 15 Min, 1 Hour, Daily

This indicator is made for beginners and pro traders who want a clean EMA setup without clutter.

Disclaimer: This is only for educational purpose. Do your own analysis before taking any trade.

#EMA #ExponentialMovingAverage #PARTHTRADERALERTS 
#MovingAverage #Nifty #BankNifty #Crypto #Forex #Commodity

---

## Source Code

````pine
// This Pine ScripScriptt® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © parthtraderalerts
// @version=6
indicator(title="EMA (Exponential Moving Average) by PARTHTRADERALERTS", shorttitle="EMA by PARTHTRADERALERTS", overlay=true)

// --- EMA (Exponential Moving Average) SETTINGS ---
show1 = input.bool(true, "EMA 1 (one)", inline="e1")
len1 = input.int(9, "", minval=1, inline="e1")
col1 = input.color(color.red, "", inline="e1")

show2 = input.bool(true, "EMA 2 (two)", inline="e2")
len2 = input.int(11, "", minval=1, inline="e2")
col2 = input.color(color.green, "", inline="e2")

show3 = input.bool(true, "EMA 3 (three)", inline="e3")
len3 = input.int(45, "", minval=1, inline="e3")
col3 = input.color(color.rgb(255, 0, 255), "", inline="e3")

show4 = input.bool(false, "EMA 4 (four)", inline="e4")
len4 = input.int(30, "", minval=1, inline="e4")
col4 = input.color(color.blue, "", inline="e4")

show5 = input.bool(false, "EMA 5 (five)", inline="e5")
len5 = input.int(50, "", minval=1, inline="e5")
col5 = input.color(color.orange, "", inline="e5")

show6 = input.bool(false, "EMA 6 (six)", inline="e6")
len6 = input.int(100, "", minval=1, inline="e6")
col6 = input.color(color.rgb(165, 42, 42), "", inline="e6")

// --- CALC ---
ema1 = ta.ema(close, len1)
ema2 = ta.ema(close, len2)
ema3 = ta.ema(close, len3)
ema4 = ta.ema(close, len4)
ema5 = ta.ema(close, len5)
ema6 = ta.ema(close, len6)

// --- PLOT - FIXED ON CHART ---
plot(show1 ? ema1 : na, title="EMA 🕐 ONE", color=col1, linewidth=2)
plot(show2 ? ema2 : na, title="EMA 🕑 TWO", color=col2, linewidth=2)
plot(show3 ? ema3 : na, title="EMA 🕒 THREE", color=col3, linewidth=2)
plot(show4 ? ema4 : na, title="EMA 🕓 FOUR", color=col4, linewidth=2)
plot(show5 ? ema5 : na, title="EMA 🕔 FIVE", color=col5, linewidth=2)
plot(show6 ? ema6 : na, title="EMA 🕕 SIX", color=col6, linewidth=2)
````
