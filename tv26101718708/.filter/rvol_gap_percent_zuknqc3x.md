# Rvol & Gap Percent

- url: https://www.tradingview.com/script/zUKnQC3x-Rvol-Gap-Percent/
- type: indicator
- pine_id: PUB;eae2749893804ae18d17d326d0963fb8
- version: 1.0

## Description

Most volume indicators tell you whether a bar is "High Volume" or "Very High Volume." This indicator instead quantifies participation, helping you quickly judge the strength of buying or selling conviction behind a move.

It displays three metrics in the Status Line that automatically update as you hover over any candle:

RVOL = Current Volume ÷ 20-Day Average Volume  (Times the Volume : X)
Gap % = Opening Gap from Previous Close
VolMax30 = Current Volume ÷ Highest Volume of the Previous 30 Sessions (excluding today)

Setup
Add the indicator to your chart. preferablly below volume. 


This is not only good for Today's Value and Filtering But VERY GOOD FOR BACKTESTING, you need need to hover over a bar and you can see the values. Takes just a time to train eyes over the tabular form which shows only today's data - after that its so convinent.

Make sure Status Line is enabled in the indicator's Style settings.
Hover over any candle to view that candle's values directly in TradingView's status line.

Designed for momentum, breakout, and institutional participation analysis while keeping the chart completely clean.

## Source Code

````pine
//@version=6
indicator("RVOL & Gap", shorttitle="(avg,max) Rvol:X Gap:%", overlay=true)

//=========================
// CALCULATIONS
//=========================

len = input.int(20, "Average Volume Length")

avgVol = ta.sma(volume, len)

rvol = avgVol > 0 ? volume / avgVol : na


maxVol30 = ta.highest(volume[1], 30)
volVsMax30 = maxVol30 > 0 ? volume / maxVol30 : na

gapPct = na(close[1]) ? na : (open - close[1]) / close[1] * 100

//=========================
// INVISIBLE PLOTS
//=========================

plot(
     rvol,
     title="RVOL",
     color=color.new(color.white,100),
     linewidth=1,
     display=display.status_line + display.data_window)


plot(
     volVsMax30,
     title="VolMax30",
     color=color.new(color.aqua, 100),
     linewidth=1,
     display=display.status_line + display.data_window
)

plot(
     gapPct,
     title="Gap %",
     color=color.new(color.white,100),
     linewidth=1,
     display=display.status_line + display.data_window)
````
