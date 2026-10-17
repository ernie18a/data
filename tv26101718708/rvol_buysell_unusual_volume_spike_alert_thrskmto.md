# RVOL Buy/Sell Unusual Volume Spike Alert

- url: https://www.tradingview.com/script/thRskmTo-RVOL-Buy-Sell-Unusual-Volume-Spike-Alert/
- type: indicator
- pine_id: PUB;a1e65890e59543c1af2041f8bae8b308
- version: 1.0

## Description

This indicator is designed for lower time frames and works especially well for scalping and intraday trading. It detects unusual spikes in relative volume (RVOL) compared to the average trading volume and highlights potential bullish or bearish momentum candles.

When a candle closes with significantly higher-than-average volume:

Green candles indicate strong buying pressure
Red candles indicate strong selling pressure

You can customize the RVOL threshold based on your trading style and market conditions.

Recommended RVOL Settings:

Fast Scalping → 1.5 RVOL
Intraday Momentum Trading → 2.0 RVOL
High Conviction Breakouts → 3.0+ RVOL

This indicator is most effective for:

Momentum trading
Breakout confirmation
Detecting institutional activity
Identifying high-volume reversals
VWAP and trend continuation setups

## Source Code

````pine
//@version=6
indicator("RVOL Buy/Sell Spike Candle Coloring", overlay=true)

// === Inputs ===
volLength   = input.int(20, title="RVOL Average Length")
rvolTrigger = input.float(2.0, title="RVOL Spike Threshold", step=0.1)

// === Relative Volume (RVOL) ===
avgVol = ta.sma(volume, volLength)
rvol   = volume / avgVol

// === Candle Direction ===
bullCandle = close > open
bearCandle = close < open

// === Spike Conditions ===
bullSpike = bullCandle and rvol >= rvolTrigger
bearSpike = bearCandle and rvol >= rvolTrigger

// === Candle Colors ===
barcolor(
     bullSpike ? color.lime :
     bearSpike ? color.red :
     na
)

// === Optional Background Highlight ===
bgcolor(
     bullSpike ? color.new(color.green, 90) :
     bearSpike ? color.new(color.red, 90) :
     na
)

// === RVOL Plot ===
plot(
     rvol,
     title="RVOL",
     color=color.orange,
     linewidth=2
)

// === Threshold Line ===
hline(
     rvolTrigger,
     title="RVOL Threshold",
     color=color.gray,
     linestyle=hline.style_dashed
)

// === Labels ===
if bullSpike
    label.new(
         x=bar_index,
         y=low,
         text="BUY RVOL: " + str.tostring(rvol, "#.##"),
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small
     )

if bearSpike
    label.new(
         x=bar_index,
         y=high,
         text="SELL RVOL: " + str.tostring(rvol, "#.##"),
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small
     )
````
