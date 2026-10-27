# Anchored VWAP

- url: https://www.tradingview.com/script/fV9gFt37-Anchored-VWAP/
- type: indicator
- pine_id: PUB;efae20b6500146849eb7e990c85b95de
- version: 1.0

## Description

An Anchored VWAP serves as a baseline benchmark tool used to track and display the cumulative average price of a listed asset, starting from the exact moment it became part of that public listing or index.

Intended Purpose
Institutional Benchmarking: It allows investors to see the true, volume-weighted average price that the market has paid for an asset since it was first introduced to that specific public directory, directory update, or rebalancing date.

Fair Value Tracking: Because it weights price by actual trading volume, it shows whether the asset is currently trading above or below its historical "fair value" anchor point relative to its public shelf life.

Support & Resistance Identification: Market participants use it to pinpoint key psychological support and resistance levels that have built up from the exact inception date of the listing.

## Source Code

````pine
//@version=6
indicator("⚓️VWAP", overlay=true)

// Calendar Picker 
anchorTime = input.time(timestamp("2026-05-01 09:30"), title="Anchor Date / Time")

// Determine the exact anchor point statelessly
isAnchor = time >= anchorTime and time[1] < anchorTime

// Declare empty series variables (Notice: NO 'var' keyword!)
float sumSrcVol = na
float sumVol = na

// Use the exact same recursive [1] logic from your EMA script:
// 1. If it's the anchor bar, seed the initial value.
// 2. If we are past the anchor, take the previous bar's value nz([1]) and add current volume.
// 3. Otherwise, keep it empty (na).
sumSrcVol := isAnchor ? (ohlc4 * volume) : (time > anchorTime ? nz(sumSrcVol[1]) + (ohlc4 * volume) : na)
sumVol    := isAnchor ? volume           : (time > anchorTime ? nz(sumVol[1]) + volume           : na)

// Calculate final VWAP
myvwap = sumVol > 0 ? sumSrcVol / sumVol : na

// Plotting (Dotted pink line)
plot(myvwap, title="AVWAP", color=color.rgb(255, 105, 180), linewidth=2, linestyle = plot.linestyle_dotted)
````
