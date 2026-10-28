# Screener Logic: PDH/PDL Shakeout

- url: https://www.tradingview.com/script/4HitC8mf-Screener-Logic-PDH-PDL-Shakeout/
- type: indicator
- pine_id: PUB;fd2fe7a2dca14622aa65432eed1aa627
- version: 1.0

## Description

Script for tracking shakeout of previous day low and breakout of previous day high.

## Source Code

````pine
//@version=5
indicator("Screener Logic: PDH/PDL Shakeout", overlay=true)

// --- Inputs ---
ema5_len  = input.int(5, "EMA 5 Length")
ema21_len = input.int(21, "EMA 21 Length")

// --- Calculations ---
ema5  = ta.ema(close, ema5_len)
ema21 = ta.ema(close, ema21_len)

// Fetch Previous Day Data (Daily timeframe)
pd_high = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pd_low  = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)

// --- Condition 1: Above PDH but Below EMA5 ---
// Price > PDH AND Price < EMA5
cond1 = close > pd_high and close < ema5

// --- Condition 2: PDL Shakeout ---
// Today Low < PDL AND Current Price > PDL AND Price > EMA21 AND Price < EMA5
cond2 = low < pd_low and close > pd_low and close > ema21 and close < ema5

// --- Visualizing on Chart (Optional) ---
plotshape(cond1, title="Above PDH / Below EMA5", style=shape.triangleup, location=location.abovebar, color=color.green, size=size.small)
plotshape(cond2, title="PDL Shakeout", style=shape.xcross, location=location.belowbar, color=color.orange, size=size.small)

// --- Screener Plots ---
// These plots allow the Screener to "see" the values
plot(cond1 ? 1 : 0, "Cond 1: Above PDH Below EMA5", display=display.none)
plot(cond2 ? 1 : 0, "Cond 2: PDL Shakeout", display=display.none)
````
