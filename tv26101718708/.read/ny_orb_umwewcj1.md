# NY ORB

- url: https://www.tradingview.com/script/uMWEwCj1-NY-ORB/
- type: indicator
- pine_id: PUB;01df4c90cfde445ba3bd5e19c2e75123
- version: 1.0

## Description

Ny ORB
This is a beautiful pine script made by Abdulfattah espir for detecting open range etc...

## Source Code

````pine
//@version=6
indicator("NY ORB 9:30–9:45 (Fixed for Holidays)", overlay=true)

// ─── Inputs ───
thirdPercent = input.float(33.0, "Distance % from Mid", minval=1, maxval=99) / 100

// ─── Function to calculate ORB on 1-minute basis ───
calcORB() =>
    var float h = na
    var float l = na
    
    ny_day = dayofmonth(time, "America/New_York")
    is_new_day = ta.change(ny_day) != 0
    if is_new_day
        h := na
        l := na
        
    ny_hour = hour(time, "America/New_York")
    ny_min  = minute(time, "America/New_York")
    
    in_orb_period = (ny_hour == 9 and ny_min >= 30 and ny_min < 45)
    
    if in_orb_period
        h := na(h) ? high : math.max(h, high)
        l := na(l) ? low : math.min(l, low)
    [h, l]

// ─── Request Data from 1-Minute timeframe ───
[orbH, orbL] = request.security(syminfo.tickerid, "1", calcORB(), lookahead=barmerge.lookahead_on)

// ─── Variables for Drawing ───
var float fixedH = na
var float fixedL = na

ny_hour_chart = hour(time, "America/New_York")
ny_min_chart  = minute(time, "America/New_York")

is_rth       = (ny_hour_chart == 9 and ny_min_chart >= 30) or (ny_hour_chart >= 10 and ny_hour_chart < 16)
is_after_orb = (ny_hour_chart == 9 and ny_min_chart >= 45) or (ny_hour_chart >= 10 and ny_hour_chart < 16)

if is_after_orb and is_rth
    fixedH := orbH
    fixedL := orbL
else
    fixedH := na
    fixedL := na

// ─── Calculations ───
mid         = (fixedH + fixedL) / 2
orbRangeVal = fixedH - fixedL  
levelUp     = mid + (orbRangeVal / 2 * thirdPercent)
levelDown   = mid - (orbRangeVal / 2 * thirdPercent)

// ─── Plotting ───
show = not na(fixedH)

plot(show ? fixedH : na, "ORB High", color=color.new(color.green, 0),  linewidth=2, style=plot.style_linebr)
plot(show ? fixedL : na, "ORB Low",  color=color.new(color.red, 0),    linewidth=2, style=plot.style_linebr)
plot(show ? mid    : na, "Mid",      color=color.new(color.orange, 0), linewidth=1, style=plot.style_linebr)
plot(show ? levelUp   : na, "Upper Mid", color=color.new(color.orange, 30), style=plot.style_linebr)
plot(show ? levelDown : na, "Lower Mid", color=color.new(color.orange, 30), style=plot.style_linebr)
````
