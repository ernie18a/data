# Simple Time Highlight

- url: https://www.tradingview.com/script/i4o6cfpx-Simple-Time-Highlight/
- type: indicator
- pine_id: PUB;1a71d4c7d7fc4c22bf7d82bf33a8efd2
- version: 1.0

## Description

A lightweight session and time-window highlighting tool designed to visually mark important periods directly on your chart.

This indicator allows you to define up to 4 custom time windows, each with its own color and enable/disable toggle, making it easier to focus on key trading periods and recurring market behaviors.

Features:

• Highlight up to 4 independent time sessions
• Fully customizable session times and colors
• Adjustable time zone support
• Quickly visualize high-interest trading periods
• Clean background overlays with minimal chart clutter
• Works across different symbols and timeframes

Potential use cases:

• Mark London, New York, and Asia sessions
• Highlight market opens and closes
• Track high-volatility windows
• Identify personal trading hours
• Visualize recurring time-based patterns
• Monitor news or event periods

Default examples include:

• 5:00–8:15
• 9:30–10:30
• 16:00–18:00
• 00:00–03:00

Simple Time Highlight is intended as a lightweight visual tool that helps organize your chart around time-based behavior without adding complexity.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("Simple Time Highlight", overlay=true)

//====================================================
// Inputs
//====================================================
grp = "Time Highlights"

tzInput = input.string("America/Los_Angeles", "Time Zone", group=grp)

useTime1 = input.bool(true, "Highlight Time 1", group=grp)
session1 = input.session("0500-0815", "Time 1", group=grp)
color1 = input.color(color.new(color.green, 85), "Color 1", group=grp)

useTime2 = input.bool(false, "Highlight Time 2", group=grp)
session2 = input.session("0930-1030", "Time 2", group=grp)
color2 = input.color(color.new(color.blue, 85), "Color 2", group=grp)

useTime3 = input.bool(false, "Highlight Time 3", group=grp)
session3 = input.session("1600-1800", "Time 3", group=grp)
color3 = input.color(color.new(color.orange, 85), "Color 3", group=grp)

useTime4 = input.bool(false, "Highlight Time 4", group=grp)
session4 = input.session("0000-0300", "Time 4", group=grp)
color4 = input.color(color.new(color.red, 85), "Color 4", group=grp)

//====================================================
// Logic
//====================================================
inTime1 = useTime1 and not na(time(timeframe.period, session1, tzInput))
inTime2 = useTime2 and not na(time(timeframe.period, session2, tzInput))
inTime3 = useTime3 and not na(time(timeframe.period, session3, tzInput))
inTime4 = useTime4 and not na(time(timeframe.period, session4, tzInput))

bg =
     inTime1 ? color1 :
     inTime2 ? color2 :
     inTime3 ? color3 :
     inTime4 ? color4 :
     na

bgcolor(bg, title="Time Highlight")
````
