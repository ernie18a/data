# NSE F&O OI Analysis indicator 

- url: https://www.tradingview.com/script/KRqTcqtl-NSE-F-O-OI-Analysis-indicator/
- type: indicator
- pine_id: PUB;9be675a01e9c40cf9e7d2643d3c629e1
- version: 1.0

## Description

fno data it will show the fnodata with explaination of data on this basis you will take the descision

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © n_m007

//@version=6
//@version=5
indicator("NSE F&O OI Analysis", shorttitle="NSE OI", overlay=false)

// Input settings
lookback = input.int(20, "Lookback Period", minval=5, maxval=100)

// Data source
src = (high - low)

// Calculate OI Change
oi_current = src
oi_previous = src[1]
oi_change = oi_current - oi_previous

// Price direction
price_up = close > open
price_down = close < open

// Detect patterns
long_buildup = price_up and oi_change > 0
short_buildup = price_down and oi_change > 0
long_covering = price_up and oi_change < 0
short_covering = price_down and oi_change < 0

// Cumulative OI
var cum_oi = 0.0
cum_oi := cum_oi + oi_change

// Track positions
var long_oi = 0.0
var short_oi = 0.0

if long_buildup
    long_oi := long_oi + oi_change
if short_buildup
    short_oi := short_oi + oi_change
if long_covering
    long_oi := long_oi - math.abs(oi_change)
if short_covering
    short_oi := short_oi - math.abs(oi_change)

// Ensure no negative values
long_oi := math.max(long_oi, 0)
short_oi := math.max(short_oi, 0)

// Calculate ratio
ls_ratio = short_oi > 0 ? long_oi / short_oi : 1.0

// ============================================
// PLOTTING
// ============================================

// Plot 1: Long OI
plot(long_oi, title="Long OI", color=color.teal, linewidth=2)

// Plot 2: Short OI
plot(short_oi, title="Short OI", color=color.red, linewidth=2)

// Plot 3: Long Covering (green bars)
long_cov_val = long_covering ? math.abs(oi_change) : 0
plot(long_cov_val, title="Long Covering", color=color.lime, style=plot.style_histogram, linewidth=3)

// Plot 4: Short Covering (orange bars)
short_cov_val = short_covering ? math.abs(oi_change) : 0
plot(short_cov_val, title="Short Covering", color=color.orange, style=plot.style_histogram, linewidth=3)

// Plot 5: Cumulative OI
plot(cum_oi, title="Cumulative OI", color=color.blue, linewidth=2, style=plot.style_area)

// ============================================
// STATISTICS TABLE (Only on last bar)
// ============================================

if barstate.islast
    table_stats = table.new(position.top_right, 2, 6, bgcolor=color.new(color.gray, 60), border_color=color.white, border_width=1)
    
    table.cell(table_stats, 0, 0, "Metric", text_color=color.white, bgcolor=color.navy)
    table.cell(table_stats, 1, 0, "Value", text_color=color.white, bgcolor=color.navy)
    
    table.cell(table_stats, 0, 1, "Long OI", text_color=color.white)
    table.cell(table_stats, 1, 1, str.tostring(math.round(long_oi, 2)), text_color=color.teal)
    
    table.cell(table_stats, 0, 2, "Short OI", text_color=color.white)
    table.cell(table_stats, 1, 2, str.tostring(math.round(short_oi, 2)), text_color=color.red)
    
    table.cell(table_stats, 0, 3, "L/S Ratio", text_color=color.white)
    table.cell(table_stats, 1, 3, str.tostring(math.round(ls_ratio, 2)), text_color=color.yellow)
    
    table.cell(table_stats, 0, 4, "Cumulative OI", text_color=color.white)
    table.cell(table_stats, 1, 4, str.tostring(math.round(cum_oi, 2)), text_color=color.blue)
    
    table.cell(table_stats, 0, 5, "Status", text_color=color.white)
    status_text = long_oi > short_oi ? "BULLISH" : "BEARISH"
    status_color = long_oi > short_oi ? color.green : color.red
    table.cell(table_stats, 1, 5, status_text, text_color=status_color)

// ============================================
// ALERTS
// ============================================

alertcondition(long_buildup, title="Long Build-up", message="Long positions building up!")
alertcondition(short_buildup, title="Short Build-up", message="Short positions building up!")
alertcondition(long_covering, title="Long Covering", message="Long covering detected - Shorts may cover next!")
alertcondition(short_covering, title="Short Covering", message="Short covering detected - Possible reversal!")
````
