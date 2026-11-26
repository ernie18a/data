# Back Burner 2.0 Multiple TF INDICATOR

- url: https://www.tradingview.com/script/OKvXlnNl-Back-Burner-2-0-Multiple-TF-INDICATOR/
- type: indicator
- pine_id: PUB;cdcd9d53a5a6404085b15153d69d12c4
- version: 1.0

## Description

Multi Timeframe Oversold RSI Reversal Scanner
This indicator scans for powerful oversold reversal conditions across four timeframes simultaneously — 15 minute, 1 hour, 4 hour, and daily.
It uses RSI (14) on each timeframe and flags a signal when all four timeframes show RSI below 40. When this condition is met a green arrow appears below the bar on the chart labeled "OS" indicating a potential reversal from oversold conditions back towards overbought.
A score is also plotted tracking how many timeframes are currently oversold from 0 to 4. The higher the score the stronger the oversold confluence and the more powerful the potential reversal signal.
This indicator is best used on individual stocks to identify high probability reversal points where multiple timeframes align. It works particularly well when combined with support levels, volume spikes, or candlestick reversal patterns to confirm the trade entry.

## Source Code

````pine
//@version=6
indicator("Multi TF Oversold", overlay=true)

rsi_15m = request.security(syminfo.tickerid, "15", ta.rsi(close, 14))
rsi_1h  = request.security(syminfo.tickerid, "60", ta.rsi(close, 14))
rsi_4h  = request.security(syminfo.tickerid, "240", ta.rsi(close, 14))
rsi_1d  = request.security(syminfo.tickerid, "D", ta.rsi(close, 14))

score = (rsi_15m < 40 ? 1 : 0) + (rsi_1h < 40 ? 1 : 0) + (rsi_4h < 40 ? 1 : 0) + (rsi_1d < 40 ? 1 : 0)

// Arrow appears when ALL 4 timeframes are oversold
allOversold = rsi_15m < 40 and rsi_1h < 40 and rsi_4h < 40 and rsi_1d < 40

plotshape(allOversold, title="Oversold Signal", location=location.belowbar, style=shape.arrowup, color=color.green, size=size.normal, text="OS")

plot(score + 20, title="Oversold Score")
````
