# Trend Score For Loop | NickJoan

- url: https://www.tradingview.com/script/8M0KM9GA-Trend-Score-For-Loop-NickJoan/
- type: indicator
- pine_id: PUB;0877a457dfe04f0791d76e090080dc98
- version: 1.0

## Description

Trend Score For Loop is a trend-classification indicator that evaluates the current source relative to a defined range of prior bars using a loop-based scoring process. The resulting score is compared against user-defined threshold levels to identify bullish and bearish state shifts, while the indicator simultaneously colors price candles to reflect the active directional bias.

Methodology
The indicator calculates a cumulative score by comparing the current source value to each historical value between the selected Start and End lookback points. A positive comparison contributes to upward bias, while a negative comparison contributes to downward bias, producing a simple but adaptive measure of directional strength across the selected range.

Signal logic
A bullish state is established when the score exceeds the Long Threshold, while a bearish state is established when the score falls below the Short Threshold. Once a state is confirmed, it remains active until an opposing threshold condition is triggered, allowing the indicator to behave as a persistent market-bias filter.

Visual output
The script plots the trend score in a separate pane and applies color-coded candle overlays on the main chart to improve visual interpretation of the active state.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nick_Joan

//@version=6 
indicator(title="Trend Score For Loop | NickJoan", overlay=false, timeframe="", timeframe_gaps = false)

////////////////////////////
///// Inputs
////////////////////////////
source         = input.source(hlc3, title = 'Source', group = 'SOURCE')
Start          = input.int(1, title = 'Start', group = 'FOR LOOP SETTINGS', minval = 1)
End            = input.int(50, title = 'End', group = 'FOR LOOP SETTINGS', minval = 2)
LongThreshold  = input.int(40,'Long Threshold', group = 'THRESHOLDS')
ShortThreshold = input.int(-10,'Short Threshold', group = 'THRESHOLDS')

////////////////////////////
///// Trend Score Calculation
////////////////////////////
TrendScore(Start, End) =>
    sum  = 0.0
    for i  = Start to End by 1
        sum += (source > source[i] ? 1 : -1)
        sum
    sum

score = TrendScore(Start, End)

////////////////////////////
///// Long/Short Conditions
////////////////////////////
LongCond = score > LongThreshold
ShortCond = score < ShortThreshold 

var state = 0
state := LongCond ? 1 : ShortCond ? -1 : state
 
////////////////////////////
///// Plots and Colors
//////////////////////////// 

StateColor = state == 1 ? color.aqua : state == -1 ? color.olive : color.gray
plotcandle(open ,high, low, close, title = 'Color Bars', wickcolor = StateColor, bordercolor = StateColor, color = StateColor, force_overlay = true, display = display.pane)
plot(score, color = StateColor, title = 'Score')
hline(ShortThreshold, 'Short Threshold', color = color.olive)
hline(LongThreshold,'Long Threshold', color = color.aqua)

////////////////////////////
///// Alerts
//////////////////////////// 
longSignal = state == 1 and state[1] != 1
shortSignal = state == -1 and state[1] != -1

alertcondition(longSignal, title="Long Signal", message="Trend Score turned bullish")
alertcondition(shortSignal, title="Short Signal", message="Trend Score turned bearish")
````
