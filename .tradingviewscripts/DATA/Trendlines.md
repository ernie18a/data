<!-- tradingview-pine-id: PUB;43QQg9nDN0YPnyEWoGquJlspUe4BhKs5 -->
<!-- tradingviewscripts-format: 1 -->
# Trendlines

Source: https://www.tradingview.com/script/ih8Z9vSB-Automatic-Trendlines/

## Description

Introduction
For a full free tutorial explaining this code in more detail, visit the backtest-rookies (.com) website. 

This indicator will plot two trend lines at any given time. A resistance trend line and a support trend line. The resistance trend is shown with red circles and is created by joining swing highs together. The second is a support trend which is created by joining swing lows.

Since we need swings to make the trend, the trend line code contains code for the swing detection. You can play around with the swing detection to alter how frequently new trend lines are detected. Relying on swings also means that there will be some delay in trend detection depending on how you configure the swing detection. The higher you set rightbars, the more lag you will have before a trend is detected. However, at the same time the quality of the pivots found will increase. So it is a trade-off you need to come to terms with and decide what the best settings are for you.

Lines

A single trend line is made up of several components.

[*] Pivot Points: Marked as blue or orange circles. There will be two pivots per trend.
[*] Orange/Purple Lines: Connecting all pivot points. You will see these lines change direction slightly each time a new pivot is detected (new circles appear). 
[*] Green/Red Circle lines: Showing the trend line from the earliest moment a new trend is detected.
[*] Blue Dashed lines: Joining the purple and green/red circle lines so the full trend line can be seen.

Note: The blue dashed lines use pine-scripts drawing functions. As such, there is a limit to how many of these can be placed on a chart. When the limit is reached, the oldest line will be removed so the newest can be drawn. This means that if you detect enough trends and scroll back in time, the blue dashed lines will disappear at some point!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BacktestRookies

//@version=4
study("Trendlines", shorttitle='BTL', overlay=true)

leftbars = input(100, minval=1, title='Pivot Detection: Left Bars')
rightbars = input(15, minval=1, title='Pivot Detection: Right Bars')
plotpivots = input(true, title='Plot Pivots')

// Pivots
ph = pivothigh(high, leftbars, rightbars)
pl = pivotlow(low, leftbars, rightbars)

phv1 = valuewhen(ph, high[rightbars], 0)
phb1 = valuewhen(ph, bar_index[rightbars], 0)
phv2 = valuewhen(ph, high[rightbars], 1)
phb2 = valuewhen(ph, bar_index[rightbars], 1)

plv1 = valuewhen(pl, low[rightbars], 0)
plb1 = valuewhen(pl, bar_index[rightbars], 0)
plv2 = valuewhen(pl, low[rightbars], 1)
plb2 = valuewhen(pl, bar_index[rightbars], 1)
    
plotshape(ph, style=shape.circle, location=location.abovebar, color=color.orange,  title='Pivot High', offset=-rightbars)
plotshape(pl, style=shape.circle,   location=location.belowbar, color=color.blue, title='Pivot Low',  offset=-rightbars)

plot(ph ? high[rightbars] : na, color=color.orange, offset=-rightbars)
plot(pl ? low[rightbars] : na, color=color.purple, offset=-rightbars)

// TRENDLINE CODE
// --------------
get_slope(x1,x2,y1,y2)=>
    m = (y2-y1)/(x2-x1)
 
get_y_intercept(m, x1, y1)=>
    b=y1-m*x1

get_y(m, b, ts)=>
    Y = m * ts + b


int   res_x1 = na
float res_y1 = na
int   res_x2 = na
float res_y2 = na

int   sup_x1 = na
float sup_y1 = na
int   sup_x2 = na
float sup_y2 = na


// Resistance
res_x1 := ph ? phb1 : res_x1[1]
res_y1 := ph ? phv1 : res_y1[1]
res_x2 := ph ? phb2 : res_x2[1]
res_y2 := ph ? phv2 : res_y2[1]

res_m = get_slope(res_x1,res_x2,res_y1,res_y2)
res_b = get_y_intercept(res_m, res_x1, res_y1)
res_y = get_y(res_m, res_b, bar_index)

// Support
sup_x1 := pl ? plb1 : sup_x1[1]
sup_y1 := pl ? plv1 : sup_y1[1]
sup_x2 := pl ? plb2 : sup_x2[1]
sup_y2 := pl ? plv2 : sup_y2[1]

sup_m = get_slope(sup_x1,sup_x2,sup_y1,sup_y2)
sup_b = get_y_intercept(sup_m, sup_x1, sup_y1)
sup_y = get_y(sup_m, sup_b, bar_index)


// plot(line.get_y2(line1))
plot(res_y, color=color.red, title='Resistance Trendline', linewidth=2, style=plot.style_circles)
plot(sup_y, color=color.lime, title='Support Trendline', linewidth=2, style=plot.style_circles)

if ph
    line.new(phb1,phv1, bar_index, res_y, style=line.style_dashed, color=color.blue)
    
if pl
    line.new(plb1,plv1, bar_index, sup_y, style=line.style_dashed, color=color.blue)
    
// Breaks
long_break = crossover(close, res_y)
short_break = crossunder(close, sup_y)
plotshape(long_break,  style=shape.triangleup, color=color.green, size=size.tiny, location=location.belowbar, title='Long Break')
plotshape(short_break, style=shape.triangledown, color=color.red, size=size.tiny, location=location.abovebar, title='Short Break')

alertcondition(long_break, title='Long Breakout')
alertcondition(short_break, title='Short Breakout')
````
