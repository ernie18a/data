# CCI Threshold State | NickJoan

- url: https://www.tradingview.com/script/s8hYqSJ1-CCI-Threshold-State-NickJoan/
- type: indicator
- pine_id: PUB;8c0fb74d28a04934b1f3a758cf97c16c
- version: 2.0

## Description

CCI Threshold State is a trend-following indicator built around the Commodity Channel Index (CCI) and user-defined bullish and bearish threshold levels. It identifies directional bias by tracking whether CCI moves above or below the selected threshold boundaries, then maintains the active state until an opposing condition appears.

How it works
[list=1]
[*]The script calculates CCI using the selected source and length.
[*]A bullish condition is triggered when CCI rises above the Long Threshold.
[*]A bearish condition is triggered when CCI falls below the Short Threshold.
[*]If neither threshold is crossed, the current state remains unchanged.
[/list]

Visual output
[list]
[*]The CCI line is plotted in a separate pane.
[*]Upper and lower threshold levels define the bullish and bearish trigger zones.
[*]The space between thresholds is filled using the active state color.
[*]Candles on the main chart are color-coded according to the current bullish or bearish state.
[/list]

Alerts
[list]
[*]Long Signal triggers when the state turns bullish.
[*]Short Signal triggers when the state turns bearish.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nick_Joan

//@version=6
indicator(title="CCI Threshold State | NickJoan", precision=2, timeframe = '', timeframe_gaps = false)

// ─── Inputs ───────────────────────────────────────────────────────────────────
cciSource         = input.source(hlc3, 'Source', group = 'CCI')
cciLen            = input.int(40, 'Length', group = 'CCI')
cciLongThreshold  = input.int(103, 'Long Threshold', group = 'THRESHOLDS')
cciShortThreshold = input.int(-25, 'Short Threshold', group = 'THRESHOLDS')
bullColor         = input.color(color.aqua, "Bullish Color", group = "Colors")
bearColor         = input.color(color.olive, "Bearish Color", group = "Colors")

// ─── Calculations ─────────────────────────────────────────────────────────────
cci = ta.cci(cciSource, cciLen)

// ─── Long/Short Conditions ─────────────────────────────────────────────────────────────
longCondition  = cci > cciLongThreshold
shortCondition = cci < cciShortThreshold

var state = 0
state := longCondition ? 1 : shortCondition ? -1 : state

// ─── Plots and Colors ─────────────────────────────────────────────────────────────
stateColor = state == 1 ? bullColor : state == -1 ? bearColor : na

plot(cci, 'CCI', stateColor)

h1 = hline(cciLongThreshold, 'Long Threshold', bullColor, editable = false)
h2 = hline(cciShortThreshold, 'Short Threshold', bearColor, editable = false)
 
fill(h1, h2, color.new(stateColor, 90))

plotcandle(open , high, low, close, title = 'Color Bars', wickcolor = stateColor, bordercolor = stateColor, color = stateColor, display = display.pane, force_overlay = true)

// ─── Alerts ─────────────────────────────────────────────────────────────
longSignal = state == 1 and state[1] != 1
shortSignal = state == -1 and state[1] != -1
alertcondition(longSignal, title='Long Signal', message='CCI Threshold State turned bullish')
alertcondition(shortSignal, title='Short Signal', message='CCI Threshold State turned bearish')
````
