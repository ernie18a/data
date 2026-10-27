# Jose Daily EMA 9/21/50/100/200

- url: https://www.tradingview.com/script/G1w4eKcH-Jose-Daily-EMA-9-21-50-100-200/
- type: indicator
- pine_id: PUB;720d32b908904e2783ed51676a4509bf
- version: 4.0

## Description

Jose Daily EMA 9/21/50/100/200 plots fixed daily exponential moving averages on any chart timeframe. The indicator displays the 9, 21, 50, 100, and 200-day EMAs using daily data, so the levels remain based on the daily timeframe even when viewing intraday charts such as 1-minute, 5-minute, or 15-minute.

This tool is useful for identifying higher-timeframe trend direction, dynamic support and resistance, pullback zones, and key reaction areas during intraday trading. The shorter EMAs help track momentum, while the 50, 100, and 200-day EMAs provide broader market context.

Key features:

Fixed daily EMA levels
Works on any chart timeframe
Includes 9, 21, 50, 100, and 200-day EMAs
Helpful for scalping, day trading, breakout trading, and trend analysis
Designed to avoid EMA changes when switching chart timeframes

## Source Code

````pine
//@version=5
indicator("Jose Daily EMA 9/21/50/100/200", overlay=true)

// Fixed Daily Timeframe
tf = "D"
src = close

// Daily EMAs
ema9D   = request.security(syminfo.tickerid, tf, ta.ema(src, 9),   barmerge.gaps_off, barmerge.lookahead_off)
ema21D  = request.security(syminfo.tickerid, tf, ta.ema(src, 21),  barmerge.gaps_off, barmerge.lookahead_off)
ema50D  = request.security(syminfo.tickerid, tf, ta.ema(src, 50),  barmerge.gaps_off, barmerge.lookahead_off)
ema100D = request.security(syminfo.tickerid, tf, ta.ema(src, 100), barmerge.gaps_off, barmerge.lookahead_off)
ema200D = request.security(syminfo.tickerid, tf, ta.ema(src, 200), barmerge.gaps_off, barmerge.lookahead_off)

// Plots
plot(ema9D,   title="9 Day EMA",   color=color.orange, linewidth=1)
plot(ema21D,  title="21 Day EMA",  color=color.aqua,   linewidth=2)
plot(ema50D,  title="50 Day EMA",  color=color.teal,   linewidth=3)
plot(ema100D, title="100 Day EMA", color=color.blue,   linewidth=3)
plot(ema200D, title="200 Day EMA", color=color.purple, linewidth=4)
````
