# MA Envelope 15%

- url: https://www.tradingview.com/script/QXp9jdhm-MA-Envelope-15/
- type: indicator
- pine_id: PUB;4ad90c863c1741179833192ccf2aa61f
- version: 1.0

## Description

Traders use this type of indicator to identify extreme price deviations, potential mean reversion opportunities, and trend strength. When price moves near or beyond the upper band, it may suggest overextension or overbought conditions. When price approaches the lower band, it may indicate oversold conditions or potential value zones.

Overall, this indicator is a simple but effective way to visualize volatility boundaries around a trend and to support decision-making in trend-following or mean-reversion strategies.

You can adjust the % yourself according to your instrument.

## Source Code

````pine
//@version=6
indicator("MA Envelope 15%", overlay=true)

len = input.int(21)
pct = input.float(15)

ma = ta.sma(close, len)

upper = ma * (1 + pct / 100)
lower = ma * (1 - pct / 100)

plot(ma, "MA20")
plot(upper, "Upper")
plot(lower, "Lower")
````
