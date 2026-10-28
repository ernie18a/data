# Major Institutional Imbalance Zones

- url: https://www.tradingview.com/script/YRoIdbhM-Major-Institutional-Imbalance-Zones/
- type: indicator
- pine_id: PUB;dc2f05b2866b41d184b708e20a6fab53
- version: 1.0

## Description

Major Institutional Imbalance Zones

A clean Smart Money Concepts (SMC) indicator designed to detect high-probability institutional imbalance zones and Fair Value Gaps (FVGs) with reduced market noise.

This indicator identifies strong bullish and bearish displacement candles backed by ATR-based momentum and optional volume confirmation to highlight only major institutional activity areas.

Features

• Detects valid bullish and bearish institutional imbalances
• Filters weak and low-quality Fair Value Gaps
• Uses ATR displacement logic to identify strong momentum candles
• Optional volume confirmation for stronger institutional validation
• Draws clean institutional zones directly on chart
• Auto-extends imbalance zones into future price action
• Generates simplified BUY and SELL signals
• Includes alert conditions for bullish and bearish imbalance detection

Bullish Imbalance Conditions

A bullish zone is created when:

Current candle low is above the high from 2 candles back
Strong bullish displacement candle exists
Gap size exceeds ATR-based threshold
Volume confirmation passes (optional)
Bearish Imbalance Conditions

A bearish zone is created when:

Current candle high is below the low from 2 candles back
Strong bearish displacement candle exists
Gap size exceeds ATR-based threshold
Volume confirmation passes (optional)
Best Used For

• Smart Money Concepts (SMC) trading
• Institutional order flow analysis
• Intraday and swing trading
• Liquidity and imbalance trading strategies
• Finding premium entry zones after displacement moves

Recommended Timeframes

Works best on:

5m
15m
1H
4H
Important Note

This indicator focuses only on major imbalances to reduce unnecessary noise and avoid weak signals commonly found in traditional FVG indicators.

## Source Code

````pine
//@version=5
indicator("Major Institutional Imbalance Zones", overlay=true, max_boxes_count=100)

// ======================================================
// SETTINGS
// ======================================================

showBullish = input.bool(true, "Show Bullish Zones")
showBearish = input.bool(true, "Show Bearish Zones")

atrMultiplier = input.float(1.2, "Minimum Imbalance Strength", step=0.1)
volumeFilter  = input.bool(true, "Use Volume Confirmation")

extendZones   = input.bool(true, "Extend Zones")

bullColor = input.color(color.new(color.green, 82), "Bullish Zone")
bearColor = input.color(color.new(color.red, 82), "Bearish Zone")

// ======================================================
// CALCULATIONS
// ======================================================

atr = ta.atr(14)
avgVol = ta.sma(volume, 20)

// Strong displacement candle
bullDisplacement = close > open and (close - open) > atr * atrMultiplier
bearDisplacement = close < open and (open - close) > atr * atrMultiplier

// Volume confirmation
highVol = volume > avgVol

// ======================================================
// VALID INSTITUTIONAL IMBALANCE
// ======================================================

// Bullish imbalance
bullFVG = low > high[2]
bullGap = low - high[2]

validBull =
     bullFVG and
     bullGap > atr * 0.4 and
     bullDisplacement and
     (volumeFilter ? highVol : true)

// Bearish imbalance
bearFVG = high < low[2]
bearGap = low[2] - high

validBear =
     bearFVG and
     bearGap > atr * 0.4 and
     bearDisplacement and
     (volumeFilter ? highVol : true)

// ======================================================
// DRAW ONLY MAJOR ZONES
// ======================================================

// Bullish Institutional Zone
if validBull and showBullish
    box.new(
         left = bar_index - 2,
         right = extendZones ? bar_index + 100 : bar_index,
         top = low,
         bottom = high[2],
         bgcolor = bullColor,
         border_color = color.green,
         border_width = 1
     )

// Bearish Institutional Zone
if validBear and showBearish
    box.new(
         left = bar_index - 2,
         right = extendZones ? bar_index + 100 : bar_index,
         top = low[2],
         bottom = high,
         bgcolor = bearColor,
         border_color = color.red,
         border_width = 1
     )

// ======================================================
// CLEAN SIGNALS
// ======================================================

plotshape(validBull,
     title="Institutional Buy",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small)

plotshape(validBear,
     title="Institutional Sell",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small)

// ======================================================
// ALERTS
// ======================================================

alertcondition(validBull,
     title="Major Bullish Imbalance",
     message="Strong Bullish Institutional Imbalance Detected")

alertcondition(validBear,
     title="Major Bearish Imbalance",
     message="Strong Bearish Institutional Imbalance Detected")
````
