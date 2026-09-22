<!-- tradingview-pine-id: PUB;c7d6336172b342e5a0e919e8d773c2f3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# DFS-HAMA

Source: https://www.tradingview.com/script/CjDmLHAW-Dominant-Force-HAMA/

## Description

DFS‑HAMA calculates a Heikin‑Ashi (HA) average for each bar, then applies a weighted moving average (WMA) to that HA average using the user’s SMA length. The plotted line is colored green when the current Heikin‑Ashi close is above the HA open (bullish HA bar) and red when HA close is below HA open (bearish HA bar). Use it as a trend filter: green suggests bullish bias, red suggests bearish bias. Adjustable input: Source (defaults to close) and SMA Length (default 30) which controls smoothing.
What the script does (simple step‑by‑step)

Colors the plotted WMA green when haClose > haOpen (current HA bar bullish), otherwise red.
How to interpret (practical rules)

Green line: bullish bias — consider long trades or only taking long signals from other systems.
Red line: bearish bias — consider short trades or only taking short signals from other systems.
Crosses of price through the line or slope changes can be used as confirmations (combine with volume, support/resistance, or other indicators).
Longer SMA Length = smoother, slower signals; shorter = more responsive, more noise.
Inputs

This is a trend / smoothing indicator, not a standalone entry system. Backtest and combine with risk management before trading live.

Colors reflect the current Heikin‑Ashi bar only, not guaranteed reversals, use with other confirmations.

---

## Source Code

````pine
//@version=6
indicator('DFS-HAMA', overlay = true)

src = input(close, title = 'Source')
//haLength = input(30, title='Heikin Ashi Length')
smaLength = input(30, title = 'SMA Length') // Add this input for SMA length

haClose = (open + high + low + close) / 4
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2 : (haOpen[1] + haClose[1]) / 2
haHigh = math.max(high, math.max(haOpen, haClose))
haLow = math.min(low, math.min(haOpen, haClose))

//ma = ta.sma(src, smaLength)  // Use the user-defined SMA length
avg = math.avg(haOpen, haHigh, haLow, haClose)
HA_MA30 = ta.wma(avg, smaLength)


// Determine the current Heikin Ashi bar color
var color currentHAColor = na
currentHAColor := haClose > haOpen ? color.green : color.red

plot(HA_MA30, title = 'Moving Average', color = currentHAColor, linewidth = 1, offset = 0)
````
