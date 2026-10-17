# Hourly High/Low Lines

- url: https://www.tradingview.com/script/NmugNCOd-Hourly-High-Low-Lines/
- type: indicator
- pine_id: PUB;a7768a32dbc444a2bbdeccbe10fa7d36
- version: 1.0

## Description

Here is a detailed and professional description you can copy and paste directly into the "Describe your script..." box on your screen:

Custom Hourly High/Low Lines

This indicator is designed for intraday traders who need to track and visualize the highest and lowest price points of specific hours throughout the day. Instead of extending lines indefinitely, this script draws clean, fixed-length horizontal lines from your target hours, keeping your chart clutter-free.

Key Features:

Customizable Target Hours: Select exactly which hour to track for the High, and which hour to track for the Low (0-23 format). By default, it is set to track the 6 PM Low and 7 PM High.

Anchored to New York Time: The script forces the time check to "America/New_York" (EST/EDT). This ensures your lines always anchor to the correct time regardless of what time zone your chart or exchange is set to (perfect for Crypto or Forex charts running on UTC).

Adjustable Line Length: Choose exactly how many hours the line should extend across your chart. By default, it draws a 3-hour line starting from the targeted hour.

Fully Customizable Styling: Easily change the colors and thickness of both the High and Low lines directly from the indicator's settings menu without touching the code.

Use Case:
Ideal for visualizing session liquidity, tracking opening range highs/lows, or highlighting key intraday levels (like the 6 PM opening low) for a specific duration of your trading session.

Once you paste that in, the Continue button at the bottom of your screen will become clickable!

## Source Code

````pine
//@version=6
indicator('Custom Hourly High/Low Lines', overlay = true)

// --- User Inputs ---
low_hour = input.int(18, title = 'Low Hour (New York Time, 0-23)', minval = 0, maxval = 23)
high_hour = input.int(19, title = 'High Hour (New York Time, 0-23)', minval = 0, maxval = 23)
line_hours = input.int(3, title = 'Line Length (Hours)', minval = 1)

grp_style = 'Line Styling'
low_color = input.color(color.blue, title = 'Low Line Color', group = grp_style)
high_color = input.color(color.red, title = 'High Line Color', group = grp_style)
line_width = input.int(2, title = 'Line Thickness', minval = 1, maxval = 5, group = grp_style)

// --- Timezone Setup ---
ny_hour = hour(time, 'America/New_York')

// --- Low Hour Logic ---
var float low_val = na
var int low_start_time = na

in_low_hour = ny_hour == low_hour

if in_low_hour and not in_low_hour[1]
    low_val := low
    low_start_time := time
    low_start_time
else if in_low_hour
    low_val := math.min(low_val, low)
    low_val

if not in_low_hour and in_low_hour[1]
    low_end_time = low_start_time + line_hours * 60 * 60 * 1000
    line.new(x1 = low_start_time, y1 = low_val, x2 = low_end_time, y2 = low_val, xloc = xloc.bar_time, color = low_color, width = line_width)

// --- High Hour Logic ---
var float high_val = na
var int high_start_time = na

in_high_hour = ny_hour == high_hour

if in_high_hour and not in_high_hour[1]
    high_val := high
    high_start_time := time
    high_start_time
else if in_high_hour
    high_val := math.max(high_val, high)
    high_val

if not in_high_hour and in_high_hour[1]
    high_end_time = high_start_time + line_hours * 60 * 60 * 1000
    line.new(x1 = high_start_time, y1 = high_val, x2 = high_end_time, y2 = high_val, xloc = xloc.bar_time, color = high_color, width = line_width)
````
