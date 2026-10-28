# MNQ Anomaly Candle - SMA Confluence V6

- url: https://www.tradingview.com/script/iDHT8ZoK-MNQ-Anomaly-Candle-SMA-Confluence-V6/
- type: indicator
- pine_id: PUB;ee3d69682eb546a78ade12f292c2c5b0
- version: 1.0

## Description

🚀 MNQ Anomaly Candle - SMA Trend Confluence (V6)

This Pine Script v6 indicator is designed for intraday momentum, continuation, and order flow traders (SMC/ICT) executing trades on lower timeframes (1m/5m) while respecting macro structures.

It isolates institutional "Anomaly Candles" (Spike Candles) where a surge in price range and relative volume confirms aggressive capital injection. To eliminate counter-trend noise and range-bound false breakouts, this script adds a strict trend filter based on the 9, 20, and 50 Simple Moving Averages (SMA).

📌 HOW IT WORKS
The script filters signals through a 3-layer confluence system:
1. Relative Volatility: Detects if the current candle's range is significantly larger than the recent lookback average (e.g., 2x larger via True Range).
2. Relative Volume (RVOL): Ensures the volume on the breakout candle exceeds its recent moving average, confirming institutional participation.
3. SMA Fan Alignment: A Long signal is only generated if the candle is green AND the SMAs are stacked in a bullish trend (9 > 20 > 50). A Short signal requires a red candle AND a bearish stack (9 < 20 < 50).

🛠️ FEATURES & PARAMETERS:
• Average Lookback Period: Customize the reference window for volume and volatility averages.
• Size Multiplier: Tweak how "abnormal" a candle needs to be to trigger an alert (e.g., 1.5x, 2x, 2.5x).
• SMA Trend Toggle: Turn the SMA confluence filter on or off depending on your preference.
• Separate Bullish/Bearish Alerts: Built-in distinct alert logs optimize compatibility with automated trading webhooks or targeted execution routines.

💡 STRATEGY TIP: Perfect for catching high-probability continuations out of Volume Profile zones (POC/VAH/VAL) or executing precise retracements into freshly formed Fair Value Gaps (FVG) on the 1-minute and 5-minute charts.

For optimal results with TradingView alerts, select "Once per bar close" to confirm the signal upon candle completion.

## Source Code

````pine
//@version=6
indicator("MNQ Anomaly Candle - SMA Confluence V6", overlay=true)

// --- Editable Inputs ---
avgLength       = input.int(20, title="Average Lookback Period (Bars)")
sizeMultiplier  = input.float(2.0, title="Size Multiplier (e.g., 2x larger)")
filterByVolume  = input.bool(true, title="Filter by Above-Average Volume?")
filterBySMA     = input.bool(true, title="Filter by SMA Alignment (9/20/50)?")

// --- SMA Settings ---
sma9  = ta.sma(close, 9)
sma20 = ta.sma(close, 20)
sma50 = ta.sma(close, 50)

// --- Candle Size Calculations ---
// ta.tr(true) calculates the True Range (total candle range)
currentCandleSize = ta.tr(true)
averageCandleSize = ta.sma(currentCandleSize, avgLength)
averageVolume     = ta.sma(volume, avgLength)

// --- Anomaly & Volume Conditions ---
largeCandleCondition = currentCandleSize > (averageCandleSize * sizeMultiplier)
volumeCondition      = filterByVolume ? (volume > averageVolume) : true

// --- SMA Confluence (Bullish / Bearish Fan) ---
bool isSmaBullish = sma9 > sma20 and sma20 > sma50
bool isSmaBearish = sma9 < sma20 and sma20 < sma50

// Candle Color/Direction
bool isGreen = close > open
bool isRed   = close < open

// --- Filtered Signals ---
bool signalLong  = largeCandleCondition and volumeCondition and isGreen and (filterBySMA ? isSmaBullish : true)
bool signalShort = largeCandleCondition and volumeCondition and isRed and (filterBySMA ? isSmaBearish : true)

// --- Chart Visuals ---
// Transparent green for Longs, transparent red for Shorts (85% transparency)
bgcolor(signalLong ? color.new(color.green, 85) : signalShort ? color.new(color.red, 85) : na)

plotshape(signalLong, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(signalShort, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// --- Separate Alert Triggers ---
if signalLong
    alert("MNQ - LONG SIGNAL: Anomaly Candle + High Volume + SMA Alignment", alert.freq_once_per_bar_close)

if signalShort
    alert("MNQ - SHORT SIGNAL: Anomaly Candle + High Volume + SMA Alignment", alert.freq_once_per_bar_close)
````
