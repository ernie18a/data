# Volume Z-Score (2 StdDev)

- url: https://www.tradingview.com/script/6FEsUdB9-Volume-Z-Score-2-StdDev/
- type: indicator
- pine_id: PUB;97cef50b50024d00a1496e1b29244e4d
- version: 1.0

## Description

Here's a ready-to-use description for the publish listing:

---

**Volume Z-Score (2 StdDev) — Sell-off vs. Buying Volume Outliers**

This indicator flags statistically unusual volume days by calculating a z-score: how many standard deviations today's volume is from its rolling 20-period average. Rather than relying on a fixed "unusual volume" threshold that doesn't adapt across different stocks or volatility regimes, this calculates the mean and standard deviation dynamically, so the "outlier" bar scales naturally with each symbol's own typical volume behavior.

**How it works:**
- Volume bars are plotted as columns, color-coded by both magnitude and direction:
  - **Gray** — normal volume, within 2 standard deviations of the 20-period average
  - **Lime green** — volume is 2+ standard deviations above average AND the bar closed up (buying/accumulation pressure)
  - **Red** — volume is 2+ standard deviations above average AND the bar closed down (selling/distribution pressure)
- An orange threshold line plots the actual 2-standard-deviation level (average + 2×stdDev), so you can see the dynamic cutoff directly rather than trusting the color alone
- Two separate alert conditions are included: one for sell-off volume outliers, one for buying volume outliers, so you can set alerts independently for either direction

**How to use it:**
Best paired with a volatility-compression indicator like the TTM Squeeze — a squeeze release confirmed by a same-day green (or red) volume outlier here is a stronger signal than a squeeze release with unremarkable volume. Works on any timeframe and any symbol; the 20-period lookback can be adjusted in settings to suit shorter or longer-term analysis.

**Settings:**
- Lookback Length (default 20) — the period used to calculate the rolling average and standard deviation of volume

**Disclaimer:** This is a volatility/volume analysis tool, not a standalone trading system. It does not predict direction with certainty and should be combined with price action, trend context, and proper risk management. Past patterns do not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Volume Z-Score (2 StdDev)", overlay=false)

len = input.int(20, "Lookback Length")
vol = volume
avgVol = ta.sma(vol, len)
stdDevVol = ta.stdev(vol, len)
zScore = (vol - avgVol) / stdDevVol

isDownDay = close < open
isUpDay = close >= open

barColor = zScore >= 2 and isDownDay ? color.red : zScore >= 2 and isUpDay ? color.lime : color.gray

plot(vol, style=plot.style_columns, color=barColor)
plot(avgVol + 2 * stdDevVol, color=color.orange, title="2 StdDev Threshold")

alertcondition(zScore >= 2 and isDownDay, title="Sell-off Volume Outlier", message="Large down-day volume detected")
alertcondition(zScore >= 2 and isUpDay, title="Buying Volume Outlier", message="Large up-day volume detected")
````
