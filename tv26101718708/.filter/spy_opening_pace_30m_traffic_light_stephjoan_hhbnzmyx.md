# SPY Opening Pace 30m + Traffic Light stephjoan

- url: https://www.tradingview.com/script/HhBnzmYX-SPY-Opening-Pace-30m-Traffic-Light-stephjoan/
- type: indicator
- pine_id: PUB;431c35e73f4d4abbb7bb434b0be2c588
- version: 1.0

## Description

This indicator measures the total traded volume during the first 30 minutes of the US cash session (09:30–10:00 New York time) and compares it to the average opening volume of the last N trading days. It is inspired by Linda Raschke’s idea of using the “pace” of the opening volume to classify the type of trading day. A high opening pace often aligns with trend or momentum-type days, while a low opening pace is more typical of range-bound or mean-reversion environments.

The script calculates the first 30 minutes’ volume, plots it as a daily value, overlays the moving average of those values, and computes a Pace Ratio (today’s 30-minute volume divided by the average). A simple traffic-light classification is provided:
– HIGH PACE (green) when the ratio is above the high threshold
– LOW PACE (red) when the ratio is below the low threshold
– NORMAL PACE (yellow) in between

This tool is meant as a market context filter, not as a stand-alone entry signal. It works best on intraday charts of SPY (or your main index proxy) and in combination with price action, trend structure, and market internals (such as TICK, Advance/Decline, and TRIN).

This script is designed for active intraday traders who want to quickly assess the opening pace of the US cash session using SPY as a practical proxy. Please use it as a context filter for day type (trend vs. range) and not as a mechanical trading system.

Recommended usage:
– Apply to an intraday chart of SPY (5m or 15m).
– Wait until after 10:00 New York time so the first 30 minutes’ volume can be locked in.
– Combine the pace reading (HIGH / NORMAL / LOW) with your own analysis of price structure, relative strength, and market internals.

If you request access, please briefly mention your TradingView username, primary markets traded, and how you intend to use the script.

## Source Code

````pine
//@version=5
indicator("SPY Opening Pace 30m + Traffic Light", overlay=false)

lookbackDays = input.int(10, "Lookback Days", minval=2)
highThresh = input.float(1.50, "High Pace Threshold", step=0.05)
lowThresh = input.float(0.70, "Low Pace Threshold", step=0.05)

var float accumVol = 0.0
var float first30mVol = na
var int prevDay = na

currentDay = dayofmonth(time)

isNewDay = na(prevDay) or currentDay != prevDay
if isNewDay
    prevDay := currentDay
    accumVol := 0.0
    first30mVol := na

inFirst30 = not na(time(timeframe.period, "0930-1000"))

if inFirst30
    accumVol += volume

endFirst30 = not inFirst30 and inFirst30[1]
if endFirst30
    first30mVol := accumVol

dailySeries = first30mVol
avgVol = ta.sma(dailySeries, lookbackDays)
pace = dailySeries / avgVol

paceState = na(pace) ? 0 : pace > highThresh ? 1 : pace < lowThresh ? -1 : 0
paceText = paceState == 1 ? "HIGH PACE" : paceState == -1 ? "LOW PACE" : "NORMAL PACE"
paceColor = paceState == 1 ? color.green : paceState == -1 ? color.red : color.yellow

plot(dailySeries, "First 30m Volume", style=plot.style_columns, color=color.new(color.blue, 0))
plot(avgVol, "Average 1st 30m Volume", color=color.orange, linewidth=2)
plot(pace, "Pace Ratio", color=color.green, linewidth=2)

hline(1.0, "Equal Pace", color=color.gray)
hline(highThresh, "High Pace", color=color.new(color.green, 50))
hline(lowThresh, "Low Pace", color=color.new(color.red, 50))

bgcolor(not na(pace) ? color.new(paceColor, 85) : na)

var label paceLabel = na
if barstate.islast
    label.delete(paceLabel)
    paceLabel := label.new(bar_index, nz(pace, 1), paceText, style=label.style_label_left, color=paceColor, textcolor=color.black)
````
