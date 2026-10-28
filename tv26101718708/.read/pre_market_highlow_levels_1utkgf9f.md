# Pre Market High/Low Levels

- url: https://www.tradingview.com/script/1UTKGF9F-Pre-Market-High-Low-Levels/
- type: indicator
- pine_id: PUB;aaf4f80abe144c0fa9da1c5b8893cbb8
- version: 1.0

## Description

This indicator automatically identifies and plots the Pre Market High (PMH) and Pre Market Low (PML) for each trading day.

Features:
• Tracks the complete pre market session from 4:00 AM to 9:30 AM Eastern Time.
• Automatically locks the final pre market high and low once the regular trading session begins.
• Draws clean horizontal support and resistance levels that remain visible throughout the trading day.
• Displays PM HIGH and PM LOW labels at the end of each level for quick identification.
• Automatically resets and calculates new levels each trading day.
• Works on all intraday timeframes.

Many traders use the pre market high and low as key intraday reference points for:
• Breakout entries
• Reversal setups
• Support and resistance
• Liquidity sweeps
• Risk management

This indicator is designed to provide a clean, distraction-free view of these important price levels without unnecessary visual clutter.

## Source Code

````pine
//@version=6
indicator("Pre Market High/Low Levels", overlay=true, max_lines_count=20, max_labels_count=20)

// Settings
show_premarket_high = input.bool(true, "Show Pre Market High", group="Settings")
show_premarket_low = input.bool(true, "Show Pre Market Low", group="Settings")
show_labels = input.bool(true, "Show Labels", group="Settings")

// Colors
color_pm_high = input.color(color.new(color.blue, 0), "Pre Market High Color", group="Colors")
color_pm_low = input.color(color.new(color.blue, 0), "Pre Market Low Color", group="Colors")

// Line style
line_width = input.int(2, "Line Width", minval=1, maxval=5, group="Style")

// Sessions
premarket_session = "0400-0930"
regular_session = "0930-1600"

is_premarket = not na(time(timeframe.period, premarket_session, "America/New_York"))
is_regular = not na(time(timeframe.period, regular_session, "America/New_York"))

// Variables
var float pm_high = na
var float pm_low = na
var int pm_start_time = na

// New day reset
new_day = ta.change(time("D")) != 0

if new_day
    pm_high := na
    pm_low := na
    pm_start_time := na

// First pre-market bar
first_pm_bar = is_premarket and not is_premarket[1]

if first_pm_bar
    pm_high := high
    pm_low := low
    pm_start_time := time

// Update during pre-market
if is_premarket and not na(pm_high)
    pm_high := math.max(pm_high, high)
    pm_low := math.min(pm_low, low)

// First regular market bar
first_regular_bar = is_regular and not is_regular[1]

if first_regular_bar and not na(pm_high) and not na(pm_low)
    end_time = time + 11 * 60 * 60 * 1000

    if show_premarket_high
        line.new(
             x1=pm_start_time,
             y1=pm_high,
             x2=end_time,
             y2=pm_high,
             color=color_pm_high,
             width=line_width,
             style=line.style_solid,
             xloc=xloc.bar_time
             )

        if show_labels
            label.new(
                 x=end_time,
                 y=pm_high,
                 text="PM HIGH",
                 xloc=xloc.bar_time,
                 style=label.style_label_left,
                 color=color_pm_high,
                 textcolor=color.white,
                 size=size.small
                 )

    if show_premarket_low
        line.new(
             x1=pm_start_time,
             y1=pm_low,
             x2=end_time,
             y2=pm_low,
             color=color_pm_low,
             width=line_width,
             style=line.style_solid,
             xloc=xloc.bar_time
             )

        if show_labels
            label.new(
                 x=end_time,
                 y=pm_low,
                 text="PM LOW",
                 xloc=xloc.bar_time,
                 style=label.style_label_left,
                 color=color_pm_low,
                 textcolor=color.white,
                 size=size.small
                 )
````
