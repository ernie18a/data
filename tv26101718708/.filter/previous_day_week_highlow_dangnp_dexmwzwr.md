# Previous Day & Week High/Low DangNP

- url: https://www.tradingview.com/script/dEXmWzwr-Previous-Day-Week-High-Low-DangNP/
- type: indicator
- pine_id: PUB;e67eb80b36b649928a437dc0259b2978
- version: 1.0

## Description

The "Previous Day & Week High/Low" indicator is a simple yet powerful price action tool designed for day traders and swing traders. It automatically identifies and plots the highest and lowest price levels of the previous trading day and the previous trading week directly onto your chart, saving you the time of drawing them manually.

Key Features

Previous Day Levels (Blue Lines): Automatically plots the Previous Day High (PDH) and Previous Day Low (PDL). These lines are configured to display only on intraday timeframes to keep your higher timeframe charts clean.

Previous Week Levels (Purple Lines): Plots the Previous Week High (PWH) and Previous Week Low (PWL). These are visible on both intraday and daily timeframes.

Fully Customizable: You can easily toggle the visibility of either the Daily or Weekly levels on and off via the indicator's Inputs settings.

How to Use
Previous Day and Previous Week highs and lows are crucial structural levels in price action trading:

Support & Resistance: These levels often act as natural barriers where price might stall, consolidate, or reverse.

Liquidity Sweeps (False Breakouts): Institutional traders often hunt the liquidity resting above previous highs or below previous lows. Traders can look for price to "sweep" these levels and reject them as a strong reversal signal.

Breakouts: A strong, sustained break and candle close beyond the previous day or week's extremes can signal trend continuation.

This script is lightweight, distraction-free, and written in Pine Script v6 for optimal performance.

## Source Code

````pine
//@version=6
indicator(title="Previous Day & Week High/Low", shorttitle="PD/PW HL", overlay=true)

// 1. Create Options (Checkboxes) in the Settings panel (Inputs tab)
showDayInput  = input.bool(true, title="Show Previous Day Levels")
showWeekInput = input.bool(true, title="Show Previous Week Levels")

// 2. Get data for the Previous Day
prevDayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevDayLow  = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)

// 3. Get data for the Previous Week
prevWeekHigh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
prevWeekLow  = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)

// 4. Visibility conditions: 
// - Must be checked in the Settings
// - AND the chart must be on an appropriate timeframe
showDay  = showDayInput and timeframe.isintraday
showWeek = showWeekInput and (timeframe.isintraday or timeframe.isdaily)

// 5. Plot the Previous Day lines (Blue color)
plot(showDay ? prevDayHigh : na, title="Prev Day High", color=color.blue, style=plot.style_line, linewidth=2)
plot(showDay ? prevDayLow : na, title="Prev Day Low", color=color.blue, style=plot.style_line, linewidth=2)

// 6. Plot the Previous Week lines (Purple color)
plot(showWeek ? prevWeekHigh : na, title="Prev Week High", color=color.purple, style=plot.style_line, linewidth=2)
plot(showWeek ? prevWeekLow : na, title="Prev Week Low", color=color.purple, style=plot.style_line, linewidth=2)
````
