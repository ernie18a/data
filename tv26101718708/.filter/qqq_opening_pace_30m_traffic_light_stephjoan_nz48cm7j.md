# QQQ Opening Pace 30m + Traffic Light stephjoan

- url: https://www.tradingview.com/script/NZ48cM7J-QQQ-Opening-Pace-30m-Traffic-Light-stephjoan/
- type: indicator
- pine_id: PUB;5199d09c57974703a6d41c47ad6a3d51
- version: 1.0

## Description

This indicator measures the total traded volume during the first 30 minutes of the US cash session (09:30–10:00 New York time) and compares it to the average opening volume of the last N trading days.

Inspired by Linda Raschke's concept of using the opening volume "pace" to classify the type of trading day:

HIGH PACE (green) — Pace Ratio above threshold (default 1.5) → higher odds of a trend or momentum-type day

NORMAL PACE (yellow) — Pace Ratio between thresholds → neutral, wait for confirmation

LOW PACE (red) — Pace Ratio below threshold (default 0.7) → higher odds of a range-bound or mean-reversion day

How to use:

Apply to an intraday chart of QQQ or SPY (5m or 15m recommended)

Wait until after 10:00 New York time — the script locks in the first 30 minutes' volume and compares it to the lookback average

Use the traffic light label and background color as a day-type context filter

Combine with price structure, relative strength, and market internals (TICK, Advance/Decline, TRIN) for best results

Settings:

Lookback Days: number of past days used for the average (default 10)

High Pace Threshold: ratio above which = HIGH PACE (default 1.5)

Low Pace Threshold: ratio below which = LOW PACE (default 0.7)

This is a context and diagnostic tool, not a standalone entry signal.

## Source Code

````pine
//@version=5
indicator("QQQ Opening Pace 30m + Traffic Light", overlay=false)

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
