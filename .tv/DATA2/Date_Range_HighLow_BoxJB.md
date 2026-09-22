<!-- tradingview-pine-id: PUB;a77d44a42848446dad0cd73ac3043e44 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Date Range High/Low Box-JB

Source: https://www.tradingview.com/script/Mf9krktk-Date-Range-High-Low-Box-JB/

## Description

This indicator allows you to isolate and visualize the highest high and lowest low within any specific time window using a highlighted bounding box.
Key Features:
Dynamic Auto-Dates: By default, the script automatically looks back to find the price range between 30 days ago and 15 days ago, automatically snapping to standard 09:00 AM to 04:00 PM session times.
Custom Calendar Inputs: You can toggle off the auto-range to manually select your exact Start Date/Time and End Date/Time using TradingView's built-in calendar pickers.
Perfect Alignment: As new candles process within your selected window, the top and bottom of the rectangle automatically adjust to lock onto the absolute highest and lowest price points of that period.
Fully Customizable: The border color, border width, and background fill of the range box can be adjusted in the style settings to fit your chart theme.
This tool is highly effective for backtesting specific historical periods, isolating price action during specific events, or highlighting structural consolidation zones over custom timeframes.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jbnaik

//@version=6
indicator("Date Range High/Low Box-JB", overlay=true)

// --- INPUTS ---
grp_dates = "Date Range Settings"

// Toggle for dynamic dates vs manual calendar dates
i_useDynamic = input.bool(true, title="Use Auto Dates (30 days back to 15 days back)", group=grp_dates)

// Calendar inputs with updated default times (09:00 AM and 04:00 PM)
i_customStart = input.time(timestamp("2023-01-01T09:00:00"), title="Custom From Date", group=grp_dates)
i_customEnd   = input.time(timestamp("2024-01-01T16:00:00"), title="Custom To Date", group=grp_dates)

grp_style = "Box Style Settings"
i_boxColor = input.color(color.blue, title="Border Color", group=grp_style)
i_bgColor  = input.color(color.new(color.blue, 85), title="Background Color", group=grp_style)
i_borderW  = input.int(2, title="Border Width", minval=1, group=grp_style)

// --- TIME CALCULATIONS ---
int MS_IN_DAY = 24 * 60 * 60 * 1000

// 1. Get raw timestamps for dynamic dates
int rawDynamicStart = timenow - (30 * MS_IN_DAY)
int rawDynamicEnd   = timenow - (15 * MS_IN_DAY)

// 2. Snap dynamic dates to 09:00 AM and 04:00 PM so they match your preferred market hours
int dynamicStart = timestamp(syminfo.timezone, year(rawDynamicStart), month(rawDynamicStart), dayofmonth(rawDynamicStart), 9, 0, 0)
int dynamicEnd   = timestamp(syminfo.timezone, year(rawDynamicEnd), month(rawDynamicEnd), dayofmonth(rawDynamicEnd), 16, 0, 0)

// 3. Finalize which timestamps to use based on the toggle
int startTime = i_useDynamic ? dynamicStart : i_customStart
int endTime   = i_useDynamic ? dynamicEnd   : i_customEnd

// --- VARIABLES ---
var float maxHigh = na
var float minLow  = na
var box   rangeBox = na

// --- LOGIC ---
// Check if the current candle's time falls within our 9:00 AM to 4:00 PM boundaries
inRange = time >= startTime and time <= endTime

if inRange
    // Calculate the highest high and lowest low dynamically
    maxHigh := na(maxHigh) ? high : math.max(maxHigh, high)
    minLow  := na(minLow)  ? low  : math.min(minLow, low)
    
    // Draw or update the rectangle
    if na(rangeBox)
        rangeBox := box.new(left=startTime, top=maxHigh, right=endTime, bottom=minLow, xloc=xloc.bar_time, border_color=i_boxColor, border_width=i_borderW, bgcolor=i_bgColor)
    else
        box.set_top(rangeBox, maxHigh)
        box.set_bottom(rangeBox, minLow)
````
