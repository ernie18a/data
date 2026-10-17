# Tight Days Range Expansion Labels

- url: https://www.tradingview.com/script/LpE2iXAG-Tight-Days-Range-Expansion-Labels/
- type: indicator
- pine_id: PUB;a08b3ee5d3ed4adb9424cb6a33d10c3e
- version: 1.0

## Description

Tight Days Range Expansion displays a percentage label above each bar to show the size of the move using one of three methods: Open to Close, Low to High, or Previous Close to Close. It also includes an optional threshold filter, ATR-based label spacing, color-coded positive and negative values, and adjustable text sizing for easier chart review.

This script is designed as a visual tool for analyzing price expansion and bar behavior rather than as a standalone trading system. It is intended for educational and analytical use.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MysticMads

//@version=6
indicator("Tight Days Range Expansion Labels", overlay=true, max_labels_count=500)

// === Inputs ===
moveType = input.string("Open to Close", "Percent Move Type", options=["Open to Close", "Low to High", "Previous Close to Close"])
showOnlyAboveThreshold = input.bool(false, "Only Show Moves Above Threshold")
thresholdPct = input.float(1.0, "Threshold %", step=0.1)
labelOffsetAtr = input.float(0.25, "Label Offset ATR", step=0.05)
textSize = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"])

// === Text Size Mapping ===
labelSize =
     textSize == "Tiny"   ? size.tiny  :
     textSize == "Small"  ? size.small :
     textSize == "Normal" ? size.normal :
     size.large

// === Percent Move Calculation ===
percentMove =
     moveType == "Open to Close"          ? ((close - open) / open) * 100 :
     moveType == "Low to High"            ? ((high - low) / low) * 100 :
     moveType == "Previous Close to Close" ? ((close - close[1]) / close[1]) * 100 :
     na

// === Display Filter ===
showLabel = not showOnlyAboveThreshold or math.abs(percentMove) >= thresholdPct

// === Label Placement ===
atr = ta.atr(14)
yPosition = high + atr * labelOffsetAtr

// === Label Color ===
isBullish = percentMove >= 0
txtColor = isBullish ? color.lime : color.red

// === Plot Labels ===
if showLabel and not na(percentMove)
    label.new(
         bar_index,
         yPosition,
         str.tostring(percentMove, "#.##") + "%",
         style=label.style_none,
         textcolor=txtColor,
         size=labelSize
     )
````
