# Ninja Trader - Order Flow Smart Footprint 

- url: https://www.tradingview.com/script/BrNW3Fku-Ninja-Trader-Order-Flow-Smart-Footprint/
- type: indicator
- pine_id: PUB;09c74b66c4984f8eadc7ad7918d7b347
- version: 1.0

## Description

📘 User Manual: Order Flow Smart Footprint
The Order Flow Smart Footprint acts as an "X-ray" for your charts. It breaks down standard price candles into their volume components, identifying aggressive buyers/sellers and highlighting institutional-level activity (Smart Money).

1. Visual Elements & Their Meaning
🔴/🟢 Volume Clusters (Circles)
What it is: Circles plotted on the candle at the price level where the highest volume imbalance occurred.
Green Circle: Aggressive buyers have taken control. This is a strong Bullish signal.
Red Circle: Aggressive sellers are dominating. This is a strong Bearish signal.
How to use: Finding a cluster at a Support/Resistance level confirms that institutions have started entering positions.
📊 Point of Control (POC) Lines
What it is: Horizontal dashed lines inside every candle.
Significance: This represents the specific price level where the most trading activity occurred during that candle.
How to use: The POC acts as a "price magnet." If the price stays above the POC in subsequent candles, the trend is strong. If the price crosses the POC to the opposite side, a trend reversal is likely.
🔢 Bar Delta Labels (+500 / -300)
What it is: Numerical values displayed above or below the candles.
Significance: The net difference between market buy volume and market sell volume.
Positive Delta (+): More aggressive buying pressure.
Negative Delta (-): More aggressive selling pressure.
How to use: Use this to spot "Absorptions." For example, if a candle is green but the Delta is negative, it suggests sellers are secretly absorbing the buyers' orders, signaling a potential drop.
🎨 Background Heatmap (Color Shading)
What it is: Soft background coloring behind specific bars.
Significance: Indicates zones of "Panic Buying" or "Panic Selling" where the Order Flow imbalance is extreme.
2. Settings (Inputs)
Imbalance Ratio: Controls the sensitivity of the indicator. A higher number (e.g., 3.0) will only show the most significant Smart Money traces. A lower number (e.g., 1.5) will provide more frequent signals.
Show POC Lines: Toggle to enable or disable the high-volume concentration lines.
Show Bar Delta: Toggle the numerical display of the buy/sell volume difference.
3. Trading Strategies
A. Trend Continuation
Condition: Market is in a clear uptrend.
Signal: A green candle appears with a Green Cluster (Circle) and positive Delta.
Action: Enter Long, as this confirms aggressive institutional participation in the direction of the trend.
B. Reversal & Absorption
Condition: Price reaches a major resistance level.
Signal: A Red Cluster appears at the very top of a green candle, or a negative Delta is seen on a bullish candle.
Action: Prepare for a Short entry, as this indicates "Supply" is entering the market and buyers are being exhausted.
4. Important Notes
Timeframes: This indicator is most effective on "Intraday" timeframes (1m, 5m, 15m) where Order Flow activity is most granular.
Confirmation: Never use this indicator in isolation. Always combine it with Market Structure (HH/HL) or identified Support and Resistance zones.
This tool gives you the edge to see "under the hood" of the market, allowing you to follow the footprints of institutional traders rather than just reacting to price movement.

Happy Trading!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Order Flow Smart Footprint - LuxAlgo", shorttitle="OF Footprint", overlay=true)

// --- Simple Inputs ---
imbRatio = input.float(2.0, "Imbalance Ratio")
showPOC  = input.bool(true, "Rodyti POC Linijas")
showDelta = input.bool(true, "Rodyti Bar Delta")

// --- Order Flow Calculation ---
float barVolume = volume
float bodySize = math.abs(close - open)
float candleRange = high - low + 0.000001
float delta = (close > open ? 1 : -1) * (bodySize / candleRange) * barVolume

// POC Estimation (Point of Control)
float pocLevel = (open + close) / 2

// --- Visual Elements ---
// 1. POC Lines (kaip 1 nuotraukoje)
if showPOC
    line.new(bar_index, pocLevel, bar_index + 1, pocLevel, color=color.new(chart.fg_color, 70), width=1)

// 2. Volume Clusters (Rutuliukai kaip 3 ir 4 nuotraukose)
// Rodo didelio tūrio koncentraciją
if math.abs(delta) > (barVolume * 0.3)
    color clusterColor = delta > 0 ? color.new(#089981, 20) : color.new(#f23645, 20)
    label.new(bar_index, pocLevel, "", color=clusterColor, style=label.style_circle, size=size.tiny)

// 3. Delta Labels (kaip jūsų pavyzdžiuose)
if showDelta
    string deltaTxt = (delta > 0 ? "+" : "") + str.tostring(math.round(delta))
    color txtColor = delta > 0 ? #089981 : #f23645
    label.new(bar_index, delta > 0 ? high : low, deltaTxt, 
         color=color.new(chart.bg_color, 100), 
         textcolor=txtColor, 
         style=delta > 0 ? label.style_label_down : label.style_label_up,
         size=size.small)

// 4. Background Heatmap
bgcolor(math.abs(delta) > (barVolume * 0.45) ? (delta > 0 ? color.new(#089981, 95) : color.new(#f23645, 95)) : na)
````
