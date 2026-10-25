# Market Crash Barometer AB

- url: https://www.tradingview.com/script/znvakjrE-Market-Crash-Barometer-AB/
- type: indicator
- pine_id: PUB;5bb8ab8df649473a929f75e6b46719e2
- version: 1.0

## Description

Market Crash Barometer by AB

The Market Crash Barometer is a multi-factor risk indicator designed to measure overall market stress and identify conditions that commonly appear before sharp market selloffs or panic events.

Instead of relying on a single signal, this indicator combines six key market factors into one unified Crash Score (0–100):

[list]
[*]VIX Fear Index – Measures volatility and market fear
[*]Trend Strength – Detects when price trades below the 200-period moving average
[*]RSI Weakness – Identifies deteriorating momentum
[*]MACD Momentum – Confirms bearish momentum shifts
[*]Volume Expansion – Highlights abnormal trading activity
[*]ATR Volatility – Tracks rising market instability
[/list]

The combined score creates a real-time stress gauge that helps traders quickly assess whether markets are calm, weakening, or entering panic conditions.

Crash Score Zones
[list]
[*]0–25 → Normal Conditions
[*]25–45 → Caution
[*]45–65 → Stress
[*]65–80 → Panic
[*]80+ → Elevated Crash Risk
[/list]

Background colors automatically highlight extreme risk environments:

[list]
[*]Orange = Panic conditions
[*]Red = Severe crash risk
[*]Best Uses
[*]Risk management
[*]Market regime detection
[*]Confirming bearish setups
[*]Identifying high-volatility environments
[*]Timing defensive positioning[pine][/pine][pine][/pine][pine][/pine]
[/list]

Notes
This indicator is not intended to predict exact market tops or crashes. Instead, it acts as a probabilistic warning system by combining volatility, momentum, trend, and participation metrics into a single easy-to-read framework.

Works best when combined with price action and broader market analysis.

## Source Code

````pine
//@version=5
indicator("Market Crash Barometer", overlay=false)

vix = request.security("CBOE:VIX", timeframe.period, close)

ma200 = ta.sma(close, 200)
rsi = ta.rsi(close, 14)
[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)

volRatio = volume / ta.sma(volume, 20)
atrRatio = ta.atr(14) / ta.sma(ta.atr(14), 50)

vixScore = math.min(vix / 40, 1) * 25
trendScore = close < ma200 ? 20 : 0
rsiScore = rsi < 50 ? ((50 - rsi) / 50) * 15 : 0
momentumScore = hist < 0 ? 15 : 0
volumeScore = math.min(volRatio / 3, 1) * 10
atrScore = math.min(atrRatio / 2, 1) * 15

crashScore = vixScore + trendScore + rsiScore + momentumScore + volumeScore + atrScore

plot(crashScore, "Crash Barometer", linewidth=3)

hline(25, "Caution")
hline(45, "Stress")
hline(65, "Panic")
hline(80, "Crash Risk")

bgcolor(crashScore > 80 ? color.new(color.red, 80) : crashScore > 65 ? color.new(color.orange, 85) : na)
````
