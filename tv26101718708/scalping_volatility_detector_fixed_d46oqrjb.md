# Scalping Volatility Detector FIXED

- url: https://www.tradingview.com/script/d46oQrJb/
- type: indicator
- pine_id: PUB;eea17bad6fa3408589997df6ec616b42
- version: 1.0

## Description

This simple indicator shows you whether there is enough volatility in the current time frame to scalp for at least one minute or not.

## Source Code

````pine
//@version=5
indicator("Scalping Volatility Detector FIXED", overlay=true)

// INPUTS
atrLen = input.int(14, "ATR Länge")
avgLen = input.int(50, "ATR Durchschnitt")
threshold = input.float(1.2, "Volatility Threshold")

// VOLATILITÄT
atr = ta.atr(atrLen)
atrAvg = ta.sma(atr, avgLen)
volRatio = atr / atrAvg

// ENTSCHEIDUNG
scalpOK = volRatio > threshold

// TABLE
var table t = table.new(position.top_right, 1, 1)

// WICHTIG: alles in EINE ZEILE
if barstate.islast
    table.cell(t, 0, 0, scalpOK ? "SCALP MODE 🟢" : "NO SCALP 🔴", text_color=color.white, bgcolor=scalpOK ? color.green : color.red)

// OPTIONAL
plot(volRatio, "Volatility Ratio", color=color.yellow)
hline(threshold, "Threshold", color=color.red)
````
