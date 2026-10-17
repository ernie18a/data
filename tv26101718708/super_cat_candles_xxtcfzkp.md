# Super Cat Candles

- url: https://www.tradingview.com/script/xxtcfzkP/
- type: indicator
- pine_id: PUB;31bb6d16f68c4183ad2bee5b36da5e68
- version: 2.0

## Description

​Overview
​"Super Cat Candles" is a unique candlestick assistant designed to bring both fun and enhanced visual clarity to your charts. Don't be fooled by its cute appearance—under the hood, it calculates recent volatility and automatically detects high-momentum bars (Marubozu/Huge Bars) using an advanced body-size logic, marking them with special cat emojis.
​Key Features & Logic
​Trend Visualization (White & Black Cats):
​When a bullish bar closes, a White Cat (🐈) appears above the high.
​When a bearish bar closes, a Black Cat (🐈‍⬛) appears below the low.
This immediately improves chart readability and helps you spot the closing dynamics at a glance.
​Momentum & Breakout Detection (Boss & Angry Cats):
​The script calculates the Simple Moving Average (SMA 20) of the candlestick body size.
​If a bar's body is more than twice (2x) the average size, it flags it as a "Huge Bar" (strong momentum) and summons a Lion (🦁) or an Angry Cat (😾) to warn you of a powerful trend acceleration or market climax.
​Smart Dynamic Offsetting via ATR:
​Instead of using fixed pixel coordinates, the cat labels are placed dynamically using a 30% offset of the ATR (14). This ensures that whether you are trading highly volatile Crypto or tight FX pairs, the cats will always sit perfectly without cluttering your price action.
​How to Use for Trading
​Breakout Confirmation: When the market breaks out of a consolidation zone accompanied by a 🦁 or 😾, it confirms a surge in institutional volume and strong momentum.
​Climax/Exhaustion Warning: If you see these giant bars appearing consecutively after a prolonged trend, it may signal an overextended market or a potential blow-off top/bottom.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mamachi-
//@version=6
// max_labels_count=500 
indicator('🐱 Super Cat Candles', overlay = true, max_labels_count = 500)


offset = ta.atr(14) * 0.3


bodySize = math.abs(close - open)
avgBodySize = ta.sma(bodySize, 20)
isHugeBar = bodySize > avgBodySize * 2 

if barstate.isconfirmed
    if close >= open
        
        string catEmoji = isHugeBar ? '🦁' : '🐈'
        label.new(bar_index, high + offset, catEmoji, style = label.style_none, size = size.normal)

    else 
        string catEmoji = isHugeBar ? '😾' : '🐈‍⬛'
        label.new(bar_index, low - offset, catEmoji, style = label.style_none, size = size.normal)
````
