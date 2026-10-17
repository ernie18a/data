# Custom Candle Highlighter (NY Time)

- url: https://www.tradingview.com/script/GSMm4G1H-Custom-Candle-Highlighter-NY-Time/
- type: indicator
- pine_id: PUB;fb9f6453478d4f3f9b9a6217891e0b8b
- version: 2.0

## Description

### Overview
This lightweight utility script highlights exactly two specific candles during the trading day based on your custom time inputs. It is designed for traders who track specific key economic releases, market opens, or daily institutional windows.

### Features
* **Precise NY Time Tracking:** The script converts candle times to the New York timezone (`America/New_York`), meaning it automatically adjusts for U.S. Daylight Saving Time (DST). It will remain accurate regardless of your local chart timezone display.
* **Dual Time Inputs:** Easily set two independent times (Hour and Minute) directly from the indicator settings panel without changing the code.
* **Highly Visible Triggers:** When a candle matches your set time, the script highlights it using three visual anchors:
  1. Changes the candle body color to Yellow.
  2. Applies a soft Yellow background slot behind the candle.
  3. Places a tiny green triangle underneath the candle for absolute clarity.

### Important Usage Notes (Best Settings)
* **Timeframe Requirement:** To capture exact minutes (e.g., 08:55 AM), you **must** use this indicator on lower-interval timeframes like the **1-minute (1m)** chart. If you are on a 1-hour chart, individual minute triggers will not paint.
* **Inputs:** Access the settings gear icon to adjust the hours (0-23 format) and minutes (0-59 format) for both the morning and afternoon session targets.

Feel free to leave a comment or drop a like if you find this script useful for your daily routine!

## Source Code

````pine
//@version=5
indicator("Custom Candle Highlighter (NY Time)", overlay=true)

// Set New York timezone (automatically handles Daylight Saving Time adjustments)
tz = "America/New_York"

// Input settings available via the indicator settings menu
group1   = "First Candle Settings"
hour1    = input.int(8, title="Hour", minval=0, maxval=23, group=group1)
minute1  = input.int(55, title="Minute", minval=0, maxval=59, group=group1)

group2   = "Second Candle Settings"
hour2    = input.int(18, title="Hour", minval=0, maxval=23, group=group2)
minute2  = input.int(0, title="Minute", minval=0, maxval=59, group=group2)

// Extract current candle hour and minute based on New York time
ny_hour   = hour(time, tz)
ny_minute = minute(time, tz)

// Check if current candle matches the defined inputs
is_time1 = (ny_hour == hour1 and ny_minute == minute1)
is_time2 = (ny_hour == hour2 and ny_minute == minute2)
is_target_time = is_time1 or is_time2

// 1. Color the candle body
barcolor(is_target_time ? color.purple : na)

// 2. Color the background (yellow with 85% transparency)
bgcolor(is_target_time ? color.new(color.purple, 85) : na)

// 3. Add a tiny purple triangle shape below the candle
plotshape(is_target_time, style=shape.triangleup, location=location.belowbar, color=color.purple, size=size.tiny)
````
