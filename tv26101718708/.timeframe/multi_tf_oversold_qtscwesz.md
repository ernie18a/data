# Multi TF Oversold

- url: https://www.tradingview.com/script/qtsCwEsz-Multi-TF-Oversold/
- type: indicator
- pine_id: PUB;8f4715d565a34b59ba26915bc10bb817
- version: 1.0

## Description

measuring over solf on multipletime frames. Multi Timeframe Oversold RSI Scanner
Scans for stocks that are oversold across multiple timeframes simultaneously. Uses RSI (14) across the 15-minute, 1-hour, 2-hour, 4-hour, and daily timeframes.
The indicator returns a score from 0 to 5, representing how many timeframes are currently showing oversold conditions below RSI 20. A score of 5 means all timeframes are oversold simultaneously — an extremely rare and potentially powerful reversal signal. A score of 3 or higher indicates strong oversold confluence across timeframes.
Use in the TradingView Pine Screener to scan your watchlist and filter for stocks with a score of 3 or higher to find the most oversold candidates.

## Source Code

````pine
//@version=6
indicator("Multi TF Oversold", overlay=false)

rsi_15m = request.security(syminfo.tickerid, "15", ta.rsi(close, 14))
rsi_1h  = request.security(syminfo.tickerid, "60", ta.rsi(close, 14))
rsi_2h  = request.security(syminfo.tickerid, "120", ta.rsi(close, 14))
rsi_4h  = request.security(syminfo.tickerid, "240", ta.rsi(close, 14))
rsi_1d  = request.security(syminfo.tickerid, "D", ta.rsi(close, 14))

score = (rsi_15m < 20 ? 1 : 0) + (rsi_1h < 20 ? 1 : 0) + (rsi_2h < 20 ? 1 : 0) + (rsi_4h < 20 ? 1 : 0) + (rsi_1d < 20 ? 1 : 0)

plot(score, title="Oversold Score")
````
