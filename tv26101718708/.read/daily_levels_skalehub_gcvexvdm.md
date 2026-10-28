# Daily Levels [SkaleHub]

- url: https://www.tradingview.com/script/GcveXVdm-Daily-Levels-SkaleHub/
- type: indicator
- pine_id: PUB;36826a6840024570b35348891cf45ea3
- version: 1.0

## Description

Overview
An automated, institutional-style tool that draws perfectly straight, subtle lines at the previous day's highest and lowest price points.

The Edge
These daily extremes are closely watched by algorithmic trading systems. They act as natural, high-probability support and resistance levels, giving traders an immediate perspective on where price is likely to bounce, reject, or break out next.

Key Features:

Automated Precision: Completely removes the tedious daily routine of manually drawing support and resistance lines every morning before the bell.

Institutional Context: Highlights the exact liquidity pools (previous day highs/lows) that smart money targets for stop runs and breakouts.

Intraday Auto-Filter: The script is coded to only display on intraday timeframes (like the 5m, 15m, or 1h), automatically hiding itself on Daily or Weekly charts to keep your big-picture analysis completely uncluttered.

How to Use

Apply the indicator to any intraday chart (it will not show up on the Daily chart).

Watch how price reacts when it approaches these lines. If price approaches the Previous Daily High (Orange), anticipate either a strong rejection (short setup) or a high-volume breakout (long setup).

Use the lines as conservative take-profit targets. If you enter a long trade mid-day, the Previous Daily High is an excellent, logical place to exit the trade.

Author's Note
This indicator is part of the SkaleHub Free Starter Library. It is designed to be paired with the SkaleHub Training System to help newer traders build mechanical discipline and systemize their trading process.

## Source Code

````pine
//@version=5
indicator("Daily Levels [SkaleHub]", overlay=true)

// =========================================================================
// 1. INPUT PARAMETERS
// =========================================================================
colorHigh = input.color(color.new(#ff9800, 40), title="Previous High Color", group="Visuals")
colorLow  = input.color(color.new(#00bcd4, 40), title="Previous Low Color", group="Visuals")
lineWidth = input.int(2, title="Line Thickness", minval=1, maxval=5, group="Visuals")

// =========================================================================
// 2. MATH & DATA FETCHING
// =========================================================================
// Fetch the highest high and lowest low from the previous completed daily candle.
// Using lookahead_on with historical reference [1] ensures the line plots instantly 
// at the daily open without repainting or lagging.
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)

// Determine if the user is on an intraday chart (minutes/hours) to prevent 
// cluttering higher timeframes like the weekly or monthly charts.
isIntraday = timeframe.isintraday

// =========================================================================
// 3. VISUAL PLOTTING
// =========================================================================
// Plot the levels using a stepline so they remain perfectly horizontal across the day
plot(isIntraday ? pdh : na, title="Previous Daily High", color=colorHigh, style=plot.style_stepline, linewidth=lineWidth)
plot(isIntraday ? pdl : na, title="Previous Daily Low", color=colorLow, style=plot.style_stepline, linewidth=lineWidth)
````
