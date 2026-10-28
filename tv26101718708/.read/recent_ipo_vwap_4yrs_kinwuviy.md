# Recent IPO VWAP (<= 4yrs)

- url: https://www.tradingview.com/script/kinWUvIY-Recent-IPO-VWAP-4yrs/
- type: indicator
- pine_id: PUB;3eebac803c7746e59e20262c031b1982
- version: 2.0

## Description

[b]CREDITS TO VENU FOR THE IDEA 
X: [url=https://x.com/Venu_7_]https://x.com/Venu_7_[/url][/b]

IPO Anchored VWAP with 4-Year Age Filter
Overview
This script automatically plots an Anchored VWAP (AVWAP) starting from the very first bar of data (IPO) for any given ticker. To maintain clean charts and focus on relevant high-growth names, the indicator features a built-in logic gate that only displays the line if the stock's trading history is 4 years or less.

Why use this?
For many trend traders (following methodologies like CAN SLIM or Mark Minervini’s Trend Template), the IPO VWAP represents the ultimate "institutional average cost basis." However, manually anchoring this on every new chart is tedious.

This script solves two problems:

Automation: It finds the IPO bar instantly without manual clicking.

Decluttering: It automatically hides itself on "legacy" stocks (like AAPL or MSFT) where the IPO anchor is no longer technically relevant for short-to-medium term trading.

Key Features
Auto-Anchor: Dynamically calculates bar_index == 0 to find the start of trading.

Age Filter: Uses a time-based calculation to ensure the line only plots on companies that IPO'd within the last 4 years (approx. 1,461 days).

Lightweight: Minimal Pine Script footprint for fast chart loading.

How to use
Simply add the script to your chart. When you flip through your watchlist:

Recent IPOs (under 4 years): You will see the red AVWAP line.

Established Stocks (over 4 years): The chart will remain clean and the line will be hidden.

## Source Code

````pine
//@version=6
indicator("Recent IPO VWAP (<= 4yrs)", overlay=true)

// --- 1. AGE CALCULATION ---
var int ipoTimestamp = na
if bar_index == 0
    ipoTimestamp := time

// Calculate 4 years in milliseconds (4 * 31557600000)
fourYearsMs = 126230400000 
isRecentEnough = (timenow - ipoTimestamp) <= fourYearsMs

// --- 2. VWAP CALCULATION ---
var float sumSrcVol = 0.0
var float sumVol = 0.0

if bar_index == 0
    sumSrcVol := close * volume
    sumVol := volume
else
    sumSrcVol += close * volume
    sumVol += volume

ipoVwap = sumSrcVol / sumVol

// --- 3. CONDITIONAL PLOT ---
plot(isRecentEnough ? ipoVwap : na, title="IPO VWAP", color=color.new(#FF5252, 0), linewidth=2)
````
