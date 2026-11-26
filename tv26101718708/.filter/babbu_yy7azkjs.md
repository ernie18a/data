# babbu

- url: https://www.tradingview.com/script/YY7AzKJS-babbu/
- type: indicator
- pine_id: PUB;66891a249c0e43259c6c22a8ac6f11e0
- version: 1.0

## Description

Indicator Description (Use this)

BabbuLiveHighLow is a real-time session-based indicator that dynamically tracks and plots the current trading session’s high and low levels, along with the previous session’s key levels.

The indicator continuously updates the live high and low as price evolves throughout the session, allowing traders to clearly identify intraday range extremes, liquidity zones, and potential breakout or reversal areas.

At the start of each new session, the indicator automatically resets and stores the prior session’s high and low, plotting them as reference levels for the current trading day.

This tool is designed to help traders:

Identify intraday support and resistance
Spot breakouts above session highs
Detect rejections from session lows
Track market structure in real time
Use previous session levels for liquidity-based trading strategies

Key Features:

Real-time updating current session high & low
Automatic detection of new trading sessions
Plots previous session high & low
Clean horizontal level visualization
Optimized for intraday futures trading (MNQ, NQ, ES, etc.)

## Source Code

````pine
//@version=5
indicator("Highs & Lows Levels", overlay=true)

showTodayHigh  = input.bool(true, "Show Today High")
showTodayLow   = input.bool(true, "Show Today Low")
showYHigh      = input.bool(true, "Show Yesterday High")
showYLow       = input.bool(true, "Show Yesterday Low")
showWeeklyLow  = input.bool(true, "Show Weekly Low")
showMondayOpen = input.bool(true, "Show Monday Open / Weekly Open")

todayHigh = request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_on)
todayLow  = request.security(syminfo.tickerid, "D", low, lookahead=barmerge.lookahead_on)

yesterdayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
yesterdayLow  = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)

weeklyLow  = request.security(syminfo.tickerid, "W", low, lookahead=barmerge.lookahead_on)
mondayOpen = request.security(syminfo.tickerid, "W", open, lookahead=barmerge.lookahead_on)

plot(showTodayHigh ? todayHigh : na, title="Today High", color=color.new(color.green, 0), linewidth=3)
plot(showTodayLow ? todayLow : na, title="Today Low", color=color.new(color.red, 0), linewidth=3)

plot(showYHigh ? yesterdayHigh : na, title="Yesterday High", color=color.new(color.orange, 0), linewidth=2)
plot(showYLow ? yesterdayLow : na, title="Yesterday Low", color=color.new(color.blue, 0), linewidth=2)

plot(showWeeklyLow ? weeklyLow : na, title="Weekly Low", color=color.new(color.purple, 0), linewidth=2)
plot(showMondayOpen ? mondayOpen : na, title="Monday Open / Weekly Open", color=color.new(color.yellow, 0), linewidth=2)

var label todayHighLabel = na
var label todayLowLabel = na
var label yHighLabel = na
var label yLowLabel = na
var label weeklyLowLabel = na
var label mondayOpenLabel = na

if barstate.islast
    label.delete(todayHighLabel)
    label.delete(todayLowLabel)
    label.delete(yHighLabel)
    label.delete(yLowLabel)
    label.delete(weeklyLowLabel)
    label.delete(mondayOpenLabel)

    if showTodayHigh
        todayHighLabel := label.new(bar_index + 2, todayHigh, "Today High", style=label.style_label_left, color=color.green, textcolor=color.white)

    if showTodayLow
        todayLowLabel := label.new(bar_index + 2, todayLow, "Today Low", style=label.style_label_left, color=color.red, textcolor=color.white)

    if showYHigh
        yHighLabel := label.new(bar_index + 2, yesterdayHigh, "Yesterday High", style=label.style_label_left, color=color.orange, textcolor=color.white)

    if showYLow
        yLowLabel := label.new(bar_index + 2, yesterdayLow, "Yesterday Low", style=label.style_label_left, color=color.blue, textcolor=color.white)

    if showWeeklyLow
        weeklyLowLabel := label.new(bar_index + 2, weeklyLow, "Weekly Low", style=label.style_label_left, color=color.purple, textcolor=color.white)

    if showMondayOpen
        mondayOpenLabel := label.new(bar_index + 2, mondayOpen, "Monday Open", style=label.style_label_left, color=color.yellow, textcolor=color.black)
````
