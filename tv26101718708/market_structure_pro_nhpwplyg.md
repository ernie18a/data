# Market Structure Pro+

- url: https://www.tradingview.com/script/NHPwpLYG-Market-Structure-Pro/
- type: indicator
- pine_id: PUB;8b375b5145e348e5845902d418ab0b8a
- version: 1.0

## Description

# Market Structure Pro+

**Market Structure Pro+** is a price-action-based market structure indicator designed to automatically identify trend shifts, Break of Structure (BOS), and Change of Character (CHoCH) events without relying on lagging oscillators or moving averages.

Built for traders who prefer reading market structure, this tool helps visualize the battle between buyers and sellers while highlighting key trend transitions in real time.

---

## Key Concepts

### Break of Structure (BOS)

A BOS occurs when price successfully breaks a previous swing high or swing low, confirming continuation of the current trend.

* **Bullish BOS (Green):** Indicates buyers remain in control.
* **Bearish BOS (Red):** Indicates sellers remain in control.

### Change of Character (CHoCH)

A CHoCH is the first warning sign that the current trend may be weakening.

It appears when price violates the most important structural level in the opposite direction, often preceding a trend reversal.

* Early reversal detection
* Trend exhaustion identification
* Confirmation before a new market phase begins

---

## What the Chart Demonstrates

Using the NIFTY 50 4H chart:

🚀 During the bullish expansion phase, Market Structure Pro+ continuously printed bullish BOS signals as price created higher highs and higher lows.

📈 The indicator remained aligned with the dominant trend, helping traders stay invested during the strongest part of the rally.

⚠️ Near the market peak, a CHoCH appeared before the larger decline developed, providing an early warning that bullish momentum was fading.

📉 As the downtrend matured, consecutive bearish BOS signals confirmed seller dominance and helped traders avoid fighting the trend.

🔄 Recent structural shifts indicate that traders should monitor upcoming BOS and CHoCH events for confirmation of the next directional move.

---

## Features

✔ Automatic Break of Structure detection

✔ Automatic Change of Character detection

✔ Bullish and Bearish trend identification

✔ Dynamic structure labeling

✔ Reduced chart noise

✔ Suitable for Smart Money Concepts (SMC) workflows

✔ Multi-timeframe compatibility

✔ Works on Forex, Crypto, Stocks, Indices, and Commodities

---

## Best Timeframes

* 15 Minutes
* 1 Hour
* 4 Hours
* Daily
* Weekly

Higher timeframes generally provide stronger structure signals and fewer false breaks.

---

## How to Use

### Bullish Setup

1. Wait for a bullish CHoCH or bullish BOS.
2. Confirm higher-high and higher-low formation.
3. Look for pullbacks into support or demand zones.
4. Manage risk below the latest structural low.

### Bearish Setup

1. Wait for a bearish CHoCH or bearish BOS.
2. Confirm lower-high and lower-low formation.
3. Look for pullbacks into resistance or supply zones.
4. Manage risk above the latest structural high.

---

## Who Is It For?

* Price Action Traders
* Smart Money Concept Traders
* Swing Traders
* Position Traders
* Trend Followers
* Market Structure Analysts

---

## Notes

Market Structure Pro+ focuses on objective price structure rather than predictive signals. It is designed to help traders understand what the market is currently doing rather than forecast what it might do next.

For best results, combine market structure signals with:

* Support and Resistance
* Volume Analysis
* Liquidity Zones
* Risk Management Rules

---

**Market Structure Pro+ provides a clean and systematic approach to identifying trend continuation and reversal events through BOS and CHoCH analysis, helping traders stay aligned with the dominant market structure.**

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator('Market Structure Pro+', overlay = true, max_labels_count = 500)

pivotLen = input.int(5, 'Swing Length')

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh = na
var float lastLow = na
var string trend = 'Neutral'

if not na(ph)
    lastHigh := ph
    lastHigh

if not na(pl)
    lastLow := pl
    lastLow

bullBOS = not na(lastHigh) and close > lastHigh
bearBOS = not na(lastLow) and close < lastLow

if bullBOS
    trend := 'Bullish'
    trend

if bearBOS
    trend := 'Bearish'
    trend

// BOS Labels
if bullBOS
    label.new(bar_index, high, 'BOS', style = label.style_label_up, color = color.green, textcolor = color.white)

if bearBOS
    label.new(bar_index, low, 'BOS', style = label.style_label_down, color = color.red, textcolor = color.white)

// CHoCH
bullCHoCH = trend[1] == 'Bearish' and bullBOS
bearCHoCH = trend[1] == 'Bullish' and bearBOS

if bullCHoCH
    label.new(bar_index, high, 'CHoCH', color = color.lime, style = label.style_label_up)

if bearCHoCH
    label.new(bar_index, low, 'CHoCH', color = color.orange, style = label.style_label_down)

// Swings
plotshape(not na(ph), location = location.abovebar, color = color.red, style = shape.circle, size = size.tiny)

plotshape(not na(pl), location = location.belowbar, color = color.green, style = shape.circle, size = size.tiny)

// Background Trend
bgcolor(trend == 'Bullish' ? color.new(color.green, 95) : trend == 'Bearish' ? color.new(color.red, 95) : na)

alertcondition(bullBOS, 'Bull BOS', 'Bullish Break of Structure')
alertcondition(bearBOS, 'Bear BOS', 'Bearish Break of Structure')
````
