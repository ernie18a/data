# Fear & Greed Index

- url: https://www.tradingview.com/script/StFrcnv6/
- type: indicator
- pine_id: PUB;2d304abea09042738dbe785f2fd0346c
- version: 1.0

## Description

The Fear & Greed Index is a synthetic market sentiment indicator designed to convert multiple technical signals into a single 0–100 score.
Its purpose is to quickly identify market phases of fear, neutrality, or greed across any asset or index.

This indicator does not rely on an official VIX.
Instead, it uses synthetic realized volatility, combined with trend and momentum metrics, to provide a visual reading of market sentiment and regime conditions.

Methodology

The score is built from several components:

Realized volatility
used as a market stress proxy: higher volatility pushes the index toward fear.
Momentum
captures recent price acceleration or deterioration.
RSI
evaluates market strength and overbought / oversold conditions.
Trend vs moving average
compares current price to its moving average to assess directional bias.
Drawdown
measures the distance from recent highs to identify stress, correction, or recovery phases.
Score interpretation

The final score is normalized between 0 and 100:

0 – 20 → Extreme Fear
20 – 40 → Fear
40 – 60 → Neutral
60 – 80 → Greed
80 – 100 → Extreme Greed
How to use it
Low readings usually reflect stressed, volatile, or corrective market conditions.
High readings usually reflect confident, bullish, or potentially overheated market conditions.
The indicator is best used as a market regime / sentiment filter, not as a standalone buy or sell signal.
Disclaimer

This script is a synthetic sentiment indicator based on price and volume data.
It is not an official volatility index and should not be considered investment advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © abdou_echchrif

//@version=6
indicator("Fear & Greed Index - Synthetic VIX", overlay=false, max_labels_count=500)

// === Paramètres
lenVol = input.int(20, "Période volatilité ")
lenMom = input.int(20, "Momentum")
lenMA  = input.int(50, "Moyenne mobile tendance")
lenRSI = input.int(14, "RSI")
lenDD  = input.int(100, "Drawdown lookback")

// === Données
ret = math.log(close / close[1])

// Volatilité annualisée synthétique type VIX 
vol = ta.stdev(ret, lenVol) * math.sqrt(252) * 100

// Plus volatilité haute = plus peur
volScore = 100 - math.min(math.max((vol - 5) / (35 - 5) * 100, 0), 100)

// Momentum
mom = close / close[lenMom] - 1
momScore = math.min(math.max((mom + 0.05) / 0.10 * 100, 0), 100)

// RSI
rsi = ta.rsi(close, lenRSI)
rsiScore = math.min(math.max(rsi, 0), 100)

// Tendance vs MA
ma = ta.sma(close, lenMA)
trend = close / ma - 1
trendScore = math.min(math.max((trend + 0.05) / 0.10 * 100, 0), 100)

// Drawdown
highestClose = ta.highest(close, lenDD)
dd = close / highestClose - 1
ddScore = math.min(math.max((dd + 0.20) / 0.20 * 100, 0), 100)

// Volume
volMA = ta.sma(volume, 20)
volumeScore = volume > volMA ? 60 : 40

// Score final
fearGreed = volScore * 0.30 + momScore * 0.25 + rsiScore * 0.20 + trendScore * 0.15 + ddScore * 0.10

// === Affichage
plot(fearGreed, title="Fear & Greed", linewidth=3)

hline(80, "Extreme Greed", linestyle=hline.style_dashed)
hline(60, "Greed", linestyle=hline.style_dotted)
hline(40, "Neutral", linestyle=hline.style_dotted)
hline(20, "Fear", linestyle=hline.style_dotted)

// Fond coloré
bg = fearGreed >= 80 ? color.new(color.green, 85) : fearGreed >= 60 ? color.new(color.lime, 88) : fearGreed >= 40 ? color.new(color.gray, 90) : fearGreed >= 20 ? color.new(color.orange, 85) : color.new(color.red, 85)
bgcolor(bg)

// Texte état marché
state = fearGreed >= 80 ? "Extreme Greed" : fearGreed >= 60 ? "Greed" : fearGreed >= 40 ? "Neutral" : fearGreed >= 20 ? "Fear" : "Extreme Fear"

// Affichage du label seulement sur la dernière bougie
if barstate.islast
    label.new(bar_index, fearGreed, state, style=label.style_label_left, textcolor=color.white, size=size.small)

// Alertes
alertcondition(fearGreed < 20, "Extreme Fear", "Fear & Greed sous 20")
alertcondition(fearGreed > 80, "Extreme Greed", "Fear & Greed au-dessus de 80")
````
