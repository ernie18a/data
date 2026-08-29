<!-- tradingview-pine-id: PUB;9cbb0f69d8c8490e89288b5d566e0f1d -->
<!-- tradingviewscripts-format: 1 -->
# 3-1-3 & 3-2-3 Candle Pattern Alert (Fixed)

Source: https://www.tradingview.com/script/5m7zjV6v-3-1-3-3-2-3-Candle-Pattern-Alert-Fixed/

## Description

The 3-1-3 & 3-2-3 Candle Pattern Alert is a technical analysis indicator script designed to automatically detect and map price action configurations that form specific structural sequences on a chart.

---

## Source Code

````pine
//@version=6
indicator("3-1-3 & 3-2-3 Candle Pattern Alert (Fixed)", overlay=true)

// === Settings ===
useSession   = input.bool(false, "Filter by Session Hours?", tooltip="Turn this off to scan all candles 24/7. Turn it on to restrict to specific hours.")
sessionInput = input.session("0930-1600", "Active Session (Exchange Time)")
allowDojis   = input.bool(true, "Allow Doji (Flat) Candles?", tooltip="If checked, flat candles (Open = Close) won't break your 3-candle color streaks.")

// Define candle colors (Handling Dojis dynamically based on user selection)
isRed   = allowDojis ? (close <= open) : (close < open)
isGreen = allowDojis ? (close >= open) : (close > open)

// Session Logic Evaluation
inSession = not useSession or not na(time(timeframe.period, sessionInput))

// Function to check N consecutive candles of same color starting at offset
sameColor(candleColor, length, offset) =>
    result = true
    if bar_index >= offset + length - 1
        for i = 0 to length - 1
            result := result and candleColor[offset + i]
    else
        result := false
    result

// --- 3-1-3 Pattern Conditions ---
bearish313 = sameColor(isRed, 3, 0) and isGreen[3] and sameColor(isRed, 3, 4) and inSession
bullish313 = sameColor(isGreen, 3, 0) and isRed[3] and sameColor(isGreen, 3, 4) and inSession

// --- 3-2-3 Pattern Conditions ---
bearish323 = sameColor(isRed, 3, 0) and sameColor(isGreen, 2, 3) and sameColor(isRed, 3, 5) and inSession
bullish323 = sameColor(isGreen, 3, 0) and sameColor(isRed, 2, 3) and sameColor(isGreen, 3, 5) and inSession

// === Plot Visual Markers ===
// 3-1-3 Plots
plotshape(bullish313, title="Bullish 3-1-3", style=shape.labelup, color=color.rgb(239, 243, 8), textcolor=color.rgb(0, 0, 0), text="3-1-3", location=location.belowbar)
plotshape(bearish313, title="Bearish 3-1-3", style=shape.labeldown, color=color.rgb(243, 239, 8), textcolor=color.rgb(2, 2, 2), text="3-1-3", location=location.abovebar)

// 3-2-3 Plots
plotshape(bullish323, title="Bullish 3-2-3", style=shape.labelup, color=color.rgb(240, 176, 0), textcolor=color.rgb(0, 0, 0), text="3-2-3", location=location.belowbar)
plotshape(bearish323, title="Bearish 3-2-3", style=shape.labeldown, color=color.rgb(238, 158, 9), textcolor=color.rgb(0, 0, 0), text="3-2-3", location=location.abovebar)

// === Alert Conditions ===
alertcondition(bullish313, title="Bullish 3-1-3 Pattern", message="Bullish 3-1-3 candle pattern detected!")
alertcondition(bearish313, title="Bearish 3-1-3 Pattern", message="Bearish 3-1-3 candle pattern detected!")
alertcondition(bullish323, title="Bullish 3-2-3 Pattern", message="Bullish 3-2-3 candle pattern detected!")
alertcondition(bearish323, title="Bearish 3-2-3 Pattern", message="Bearish 3-2-3 candle pattern detected!")
````
