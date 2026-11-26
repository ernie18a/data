# DDT Trend

- url: https://www.tradingview.com/script/1wZCJHg1-DDT-Trend/
- type: indicator
- pine_id: PUB;40f15525c74343f4abaa4fb07882f923
- version: 1.0

## Description

DDT Trend

The DDT Trend indicator is designed to provide a clean and objective view of market direction by filtering out noise and highlighting the dominant trend.

Unlike many trend indicators that constantly change direction during consolidation, DDT Trend focuses on identifying meaningful shifts in market structure and directional momentum. The goal is not to predict where the market will go next, but to help traders stay aligned with the side of the market that currently has the highest probability.

Key Features

▪️ Clean trend visualization without unnecessary clutter.

▪️ Helps identify bullish and bearish market environments.

▪️ Designed to reduce emotional decision-making and trend fighting.

▪️ Works across all markets and timeframes.

▪️ Best used as a directional filter alongside market structure, liquidity, supply and demand, and Wyckoff analysis.

How It Is Used

The DDT Trend indicator is not intended to generate entries on its own.

Instead, it acts as a contextual tool that helps traders answer a simple but important question:

"Which side of the market currently has the advantage?"

When the trend is bullish, traders can focus on long opportunities and avoid unnecessary shorts.

When the trend is bearish, traders can focus on short opportunities and avoid trying to catch reversals too early.

This aligns with one of the core principles of The Structured Process:

Respect the trend until there is objective evidence that it has changed.

Best Practices

▪️ Use higher timeframe trend as your primary directional bias.

▪️ Combine with market structure and liquidity for entries.

▪️ Avoid treating trend shifts as automatic buy or sell signals.

▪️ Let the trend provide context, not confirmation.

The DDT Philosophy

Most traders lose money fighting trends, predicting tops, and predicting bottoms.

The purpose of DDT Trend is to help traders stay objective, focus on probability, and remain aligned with the dominant market direction until the market proves otherwise.

Process over outcome.

## Source Code

````pine
//@version=6
indicator("DDT Trend", shorttitle="DDT Trend", overlay=true, max_lines_count=500)

// Settings
atrPeriod = input.int(10, "ATR Length", minval=1)
factor = input.float(3.0, "Factor", minval=0.01, step=0.01)

// Fixed DDT Timeframe
ddtTimeframe = "60"

// DDT Colors
ddtBull = color.rgb(26, 90, 255)
ddtBear = color.red

// 1H Supertrend Calculation
[ddtTrend, ddtDirection] = request.security(
     syminfo.tickerid,
     ddtTimeframe,
     ta.supertrend(factor, atrPeriod),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
 )

// Remove first bar value
ddtTrend := barstate.isfirst ? na : ddtTrend

// Trend Plots
upTrend = plot(
     ddtDirection < 0 ? ddtTrend : na,
     title="DDT Up Trend",
     color=ddtBull,
     style=plot.style_linebr,
     linewidth=2
 )

downTrend = plot(
     ddtDirection < 0 ? na : ddtTrend,
     title="DDT Down Trend",
     color=ddtBear,
     style=plot.style_linebr,
     linewidth=2
 )

bodyMiddle = plot(
     barstate.isfirst ? na : (open + close) / 2,
     title="Body Middle",
     display=display.none
 )

// Background Fill
fill(
     bodyMiddle,
     upTrend,
     title="DDT Uptrend Background",
     color=color.new(ddtBull, 90),
     fillgaps=false
 )

fill(
     bodyMiddle,
     downTrend,
     title="DDT Downtrend Background",
     color=color.new(ddtBear, 90),
     fillgaps=false
 )

// Alerts
alertcondition(
     ddtDirection[1] > ddtDirection,
     title="DDT Downtrend to Uptrend",
     message="{{ticker}} DDT Trend switched from Downtrend to Uptrend on {{interval}}"
 )

alertcondition(
     ddtDirection[1] < ddtDirection,
     title="DDT Uptrend to Downtrend",
     message="{{ticker}} DDT Trend switched from Uptrend to Downtrend on {{interval}}"
 )

alertcondition(
     ddtDirection[1] != ddtDirection,
     title="DDT Trend Change",
     message="{{ticker}} DDT Trend changed direction on {{interval}}"
 )
````
