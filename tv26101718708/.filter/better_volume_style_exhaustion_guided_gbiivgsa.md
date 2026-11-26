# Better Volume Style Exhaustion - Guided

- url: https://www.tradingview.com/script/GbiiVgsa-Better-Volume-Style-Exhaustion-Guided/
- type: indicator
- pine_id: PUB;c095539c95704c158a64f9facaafd291
- version: 1.0

## Description

Better Volume Style Exhaustion – Guided

Better Volume Style Exhaustion – Guided is an enhanced volume analysis indicator designed to identify buyer exhaustion, seller exhaustion, climax activity, churn, and participation shifts through color-coded volume behavior.

Rather than displaying raw volume alone, the indicator interprets price spread + relative volume + candle structure to help traders visualize when market participants may be losing strength.

This tool was built to help traders spot potential reversals, trend exhaustion, absorption, and institutional activity before price direction changes become obvious.

Features

Buyer Exhaustion Detection

Highlights situations where aggressive buying may be weakening.
Useful near:
Supply zones
Resistance levels
Extended bullish trends

Seller Exhaustion Detection

Identifies signs that selling pressure may be fading.
Useful near:
Demand zones
Support levels
Extended bearish trends

Climactic Volume Detection

Detects unusually high volume compared with recent market activity.
Helps reveal strong participation and possible turning points.

Churn / Indecision Recognition

Marks high volume with weak price progress.
Can indicate:
Absorption
Institutional activity
Consolidation
Buyer vs seller battles

Average Volume Reference

Displays average volume for quick comparison against current participation.

Integrated Help System

Built-in guide box and detailed tooltips explain each setting and signal directly inside the indicator.
Color Guide

🟠 Orange → Buyer exhaustion / Buying climax
🔵 Cyan → Seller exhaustion / Selling climax
🔴 Red → Strong bullish participation
🟢 Green → Strong bearish participation
🟣 Purple → Churn / absorption / indecision
⚪ Gray → Low market participation
🔵 Blue → Normal market activity

Best Use Cases

This indicator performs best when combined with:

Supply & Demand zones
Market structure shifts
Support / Resistance
Rejection candles
Trend continuation setups
Higher timeframe bias

Suggested workflow:

Identify a key area on the chart
Wait for price to enter that zone
Watch for exhaustion colors (Orange/Cyan)
Confirm with structure or price action
Execute only when confluence aligns
Important Note

This indicator does not predict market direction and should not be used as a standalone entry signal.

Volume behavior provides context. The strongest setups occur when volume signals align with structure, zones, and price action.

Designed for traders seeking cleaner visual information and earlier insight into potential market exhaustion.

## Source Code

````pine
//@version=5
indicator("Better Volume Style Exhaustion - Guided", overlay=false, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GROUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupMain  = "Core Settings"
groupColor = "Volume Colors"
groupMarks = "Exhaustion Markers"
groupGuide = "Help & Guide"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lookback = input.int(20, title="Volume Lookback", minval=5, group=groupMain, tooltip="Number of candles used to calculate average volume and average spread. Higher = smoother signals. Lower = faster signals.")
climaxMultiplier = input.float(1.8, title="Climax Volume Multiplier", step=0.1, group=groupMain, tooltip="Defines unusually high volume. 1.8 means volume must be 80% above average.")
churnMultiplier = input.float(1.5, title="Churn Volume Multiplier", step=0.1, group=groupMain, tooltip="Defines churn: high volume with weak price movement.")
showAvgVolume = input.bool(true, title="Show Average Volume Line", group=groupMain, tooltip="Displays the average volume line.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
buyerExhaustionColor = input.color(color.orange, title="Buyer Exhaustion / Buying Climax", group=groupColor, tooltip="Orange bars suggest buyers may be getting exhausted. Best near supply zones or resistance.")
sellerExhaustionColor = input.color(color.aqua, title="Seller Exhaustion / Selling Climax", group=groupColor, tooltip="Cyan bars suggest sellers may be getting exhausted. Best near demand zones or support.")
highVolUpColor = input.color(color.red, title="High Volume Up", group=groupColor, tooltip="Strong buying activity without confirmed exhaustion.")
highVolDownColor = input.color(color.lime, title="High Volume Down", group=groupColor, tooltip="Strong selling activity without confirmed exhaustion.")
churnColor = input.color(color.purple, title="Churn / Indecision", group=groupColor, tooltip="High volume with small candle range. Often shows absorption or indecision.")
lowVolumeColor = input.color(color.gray, title="Low Volume", group=groupColor, tooltip="Volume below average. Market participation is weak.")
normalVolumeColor = input.color(color.blue, title="Normal Volume", group=groupColor, tooltip="Balanced volume within normal range.")
avgVolumeColor = input.color(color.white, title="Average Volume Line", group=groupColor, tooltip="Color of the average volume reference line.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showBuyerMarkers = input.bool(true, title="Show Buyer Exhaustion Marker", group=groupMarks, tooltip="Shows BX when buyers may be exhausted.")
showSellerMarkers = input.bool(true, title="Show Seller Exhaustion Marker", group=groupMarks, tooltip="Shows SX when sellers may be exhausted.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GUIDE BOX
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showGuide = input.bool(true, title="Show Help Box", group=groupGuide, tooltip="Displays a guide box explaining how to read the indicator.")
guidePosition = input.string(defval="Top Right", title="Guide Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupGuide, tooltip="Choose where the help guide box appears.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
spread = high - low
avgVolume = ta.sma(volume, lookback)
avgSpread = ta.sma(spread, lookback)

highVolume = volume > avgVolume * climaxMultiplier
churnVolume = volume > avgVolume * churnMultiplier

lowSpread = spread < avgSpread * 0.7
wideSpread = spread > avgSpread * 1.2
lowVolume = volume < avgVolume * 0.6

bullCandle = close > open
bearCandle = close < open

buyingClimax = highVolume and bullCandle and wideSpread
sellingClimax = highVolume and bearCandle and wideSpread
churn = churnVolume and lowSpread

buyerExhaustion = buyingClimax and close < high - spread * 0.3
sellerExhaustion = sellingClimax and close > low + spread * 0.3

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLOR LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volColor = buyerExhaustion ? buyerExhaustionColor : sellerExhaustion ? sellerExhaustionColor : buyingClimax ? highVolUpColor : sellingClimax ? highVolDownColor : churn ? churnColor : lowVolume ? lowVolumeColor : normalVolumeColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(volume, title="Volume", style=plot.style_columns, color=volColor)
plot(showAvgVolume ? avgVolume : na, title="Average Volume", color=avgVolumeColor, linewidth=2)

plotshape(showBuyerMarkers and buyerExhaustion, title="Buyer Exhaustion", style=shape.triangledown, location=location.top, color=buyerExhaustionColor, size=size.tiny, text="BX")
plotshape(showSellerMarkers and sellerExhaustion, title="Seller Exhaustion", style=shape.triangleup, location=location.bottom, color=sellerExhaustionColor, size=size.tiny, text="SX")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GUIDE TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pos = guidePosition == "Top Right" ? position.top_right : guidePosition == "Top Left" ? position.top_left : guidePosition == "Bottom Right" ? position.bottom_right : position.bottom_left

var table guideTable = table.new(pos, 1, 1, border_width=1)

guideText = "BETTER VOLUME STYLE GUIDE\n\nOrange = Buyer exhaustion / buying climax\nCyan = Seller exhaustion / selling climax\nRed = Strong buying volume\nGreen = Strong selling volume\nPurple = Churn / absorption / indecision\nGray = Low participation\nBlue = Normal market activity\n\nBest use:\n1. Mark supply and demand zones\n2. Wait for price to reach a key zone\n3. Look for orange/cyan exhaustion\n4. Confirm with rejection candle or structure shift"

if barstate.islast
    if showGuide
        table.cell(guideTable, 0, 0, guideText, text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.small)
    else
        table.clear(guideTable, 0, 0)
````
