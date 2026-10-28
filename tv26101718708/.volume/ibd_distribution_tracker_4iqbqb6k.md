# IBD Distribution Tracker

- url: https://www.tradingview.com/script/4iQbqb6k-IBD-Distribution-Tracker/
- type: indicator
- pine_id: PUB;bb9f6cb4e69645b29af7b0fe1084bde0
- version: 1.0

## Description

Indicator Summary: IBD Distribution & Stalling Tracker
The Goal:
This custom TradingView indicator is designed to automatically detect and track "Distribution Days"—a core concept from William O'Neil and Investor's Business Daily (IBD). A distribution day signals that large institutions (mutual funds, hedge funds, banks) are actively selling and locking in profits, which often precedes a market correction.

What Triggers a Warning Day?
The script monitors the daily price action and volume, flagging a day if it meets any of the following three conditions:

Standard Distribution: The price drops by 0.2% or more, and the trading volume is higher than the previous day.

Churning: Heavy volume pushes into the market, but the price stalls and closes in the lower 50% of its daily range (this catches hidden selling on days that might technically close "green").

Stalling: Trading volume surges above the 25-day moving average, but the price barely moves, gaining less than 0.2% (indicating heavy overhead supply capping the advance).

The "Smart" 25-Day Memory (The 5% Rule):
Instead of just counting every bad day forever, the script utilizes a dynamic 25-day rolling window with an intelligent invalidation rule.

It keeps a running tally of valid distribution days over the last 5 weeks.

Invalidation: If the market manages to rally and close 5% higher than the closing price of a previous distribution day, that specific day is considered "defeated" by the bulls. The script automatically wipes it from the running count, ensuring the data is never skewed by old, irrelevant sell-offs.

Visual Outputs:

Chart Markers: Any day that triggers one of the three conditions has its candle colored purple and is marked with a purple downward triangle for quick visual scanning.

Live Dashboard: A clean, on-screen table sits in the top right corner of the chart, displaying the current tally of valid distribution days. If the count hits 5 or more (the traditional IBD danger zone), the text flashes red to warn of elevated market risk.

## Source Code

````pine
//@version=5
indicator("IBD Distribution & Churning Days", overlay=true, max_labels_count=500)

// --- INPUTS ---
dropThreshold = input.float(0.2, title="Minimum Price Drop (%)", step=0.1)
rollingWindow = input.int(25, title="Rolling Window for Count (Days)", minval=1)
invalidationPct = input.float(5.0, title="Invalidation Rise (%)", step=0.5)

// New Inputs for Stalling
stallingPct = input.float(0.2, title="Max Stalling Rise (%)", step=0.1)
volSmaLength = input.int(25, title="Volume SMA Length", minval=1)

// --- 1. STANDARD DISTRIBUTION ---
pctChange = ((close - close[1]) / close[1]) * 100
isSignificantDrop = pctChange <= -dropThreshold
isHigherVolume = volume > volume[1]
isStandardDist = isSignificantDrop and isHigherVolume

// --- 2. CHURNING ---
dailyRange = high - low
midPoint = low + (dailyRange * 0.5)
isLowerHalfClose = close <= midPoint
isChurning = isHigherVolume and isLowerHalfClose

// --- 3. STALLING (New Rule) ---
avgVol = ta.sma(volume, volSmaLength)
isStalling = (volume > avgVol) and (pctChange < stallingPct)

// --- 4. COMBINED SIGNAL ---
isDistToday = isStandardDist or isChurning or isStalling

// --- 5. ROLLING COUNT WITH 5% INVALIDATION RULE ---
invMult = 1.0 + (invalidationPct / 100.0)
validDistCount = 0

for i = 0 to rollingWindow - 1
    if isDistToday[i]
        invalidated = false
        if i > 0
            for j = 0 to i - 1
                if close[j] >= (close[i] * invMult)
                    invalidated := true
                    break
        if not invalidated
            validDistCount := validDistCount + 1

// --- PLOTTING ---
barcolor(isDistToday ? color.purple : na, title="Distribution Bar Color")
plotshape(series=isDistToday, title="Distribution Marker", style=shape.triangledown, location=location.abovebar, color=color.purple, size=size.small)
plotchar(validDistCount, title="Valid Dist Days", char="", location=location.bottom, color=color.purple, display=display.data_window)

// --- ON-SCREEN TALLY DASHBOARD ---
var table distTable = table.new(position.top_right, 2, 1, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.gray)

if barstate.islast
    // Header Cell
    table.cell(distTable, 0, 0, "Valid Dist Days (25d):", text_color=color.white, text_size=size.small)
    // Tally Cell (Turns red if 5 or more)
    tallyColor = validDistCount >= 5 ? color.red : color.white
    table.cell(distTable, 1, 0, str.tostring(validDistCount), text_color=tallyColor, text_size=size.normal, text_halign=text.align_center)
````
