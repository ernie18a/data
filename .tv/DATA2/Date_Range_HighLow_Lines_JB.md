<!-- tradingview-pine-id: PUB;f070f57230e349588018988f10f2a053 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Date Range High/Low Lines - JB

Source: https://www.tradingview.com/script/54ZGb6cK-Date-Range-High-Low-Lines-JB/

## Description

This indicator isolates a specific historical time window, highlights it on the chart, and projects its highest high and lowest low forward as dynamic support and resistance levels.
Key Features:

Visual Range Highlight: Automatically shades the background of your selected time period so you can clearly see the exact data being measured.

Projected High/Low Lines: Identifies the absolute highest and lowest price points within the highlighted window and draws horizontal lines that extend continuously to the most recent candle on the chart.

Dynamic Auto-Dates: By default, the script automatically looks back to find the price range between 30 days ago and 15 days ago, snapping to standard 09:00 AM to 04:00 PM session times.

Custom Calendar Inputs: Toggle off the auto-range to manually select your exact Start Date/Time and End Date/Time using TradingView's built-in calendar pickers.

Fully Customizable: Adjust line colors, line width, and the background highlight opacity in the style settings to fit your specific chart theme.

This tool is highly effective for marking out historical consolidation zones, highlighting opening ranges, or projecting the high and low of a previous macroeconomic event as future structural levels.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jbnaik

//@version=6
indicator("Date Range High/Low Lines - JB", overlay=true)

// --- INPUTS ---
grp_dates = "Date Range Settings"

// Toggle for dynamic dates vs manual calendar dates
i_useDynamic = input.bool(true, title="Use Auto Dates (30 days back to 15 days back)", group=grp_dates)

// Calendar inputs with default times (09:00 AM and 04:00 PM)
i_customStart = input.time(timestamp("2023-01-01T09:00:00"), title="Custom From Date", group=grp_dates)
i_customEnd   = input.time(timestamp("2024-01-01T16:00:00"), title="Custom To Date", group=grp_dates)

grp_style = "Style Settings"
i_lineColor = input.color(color.blue, title="Line Color", group=grp_style)
i_lineW     = input.int(2, title="Line Width", minval=1, group=grp_style)
i_bgColor   = input.color(color.new(color.blue, 90), title="Range Highlight Color", group=grp_style)

// --- TIME CALCULATIONS ---
int MS_IN_DAY = 24 * 60 * 60 * 1000

// 1. Get raw timestamps for dynamic dates
int rawDynamicStart = timenow - (30 * MS_IN_DAY)
int rawDynamicEnd   = timenow - (15 * MS_IN_DAY)

// 2. Snap dynamic dates to 09:00 AM and 04:00 PM
int dynamicStart = timestamp(syminfo.timezone, year(rawDynamicStart), month(rawDynamicStart), dayofmonth(rawDynamicStart), 9, 0, 0)
int dynamicEnd   = timestamp(syminfo.timezone, year(rawDynamicEnd), month(rawDynamicEnd), dayofmonth(rawDynamicEnd), 16, 0, 0)

// 3. Finalize which timestamps to use based on the toggle
int startTime = i_useDynamic ? dynamicStart : i_customStart
int endTime   = i_useDynamic ? dynamicEnd   : i_customEnd

// --- VARIABLES ---
var float maxHigh = na
var float minLow  = na
var line  highLine = na
var line  lowLine  = na

// --- LOGIC ---
// Check if the current candle's time falls within our 9:00 AM to 4:00 PM boundaries
inRange = time >= startTime and time <= endTime

// Highlight the vertical background area for the specified date range
bgcolor(inRange ? i_bgColor : na, title="Date Range Highlight")

if inRange
    // Calculate the highest high and lowest low dynamically
    maxHigh := na(maxHigh) ? high : math.max(maxHigh, high)
    minLow  := na(minLow)  ? low  : math.min(minLow, low)
    
    // Draw or update the horizontal lines
    if na(highLine)
        // Create lines on the first candle of the range using xloc.bar_time
        highLine := line.new(x1=startTime, y1=maxHigh, x2=time, y2=maxHigh, xloc=xloc.bar_time, color=i_lineColor, width=i_lineW)
        lowLine  := line.new(x1=startTime, y1=minLow,  x2=time, y2=minLow,  xloc=xloc.bar_time, color=i_lineColor, width=i_lineW)
    else
        // Update the y-coordinates of the lines as new highs/lows are found
        line.set_y1(highLine, maxHigh)
        line.set_y2(highLine, maxHigh)
        
        line.set_y1(lowLine, minLow)
        line.set_y2(lowLine, minLow)

// Constantly update the right side of the lines to stretch to the newest candle on the chart
if not na(highLine)
    line.set_x2(highLine, time)
    line.set_x2(lowLine, time)
````
