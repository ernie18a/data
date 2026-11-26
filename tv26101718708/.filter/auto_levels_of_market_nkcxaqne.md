# Auto levels of market

- url: https://www.tradingview.com/script/Nkcxaqne-Auto-levels-of-market/
- type: indicator
- pine_id: PUB;48e60e896ca14ff8ae129ae36a2aed8b
- version: 1.0

## Description

auto level markings by me only trial version by sushant

## Source Code

````pine
//@version=6
indicator(title="Points Alerts", shorttitle="Points Alerts", overlay=true)

// Function outputs true when it's the first bar of the D/W/M/Y
is_newbar(res) =>
    bool ch = false
    if res == 'Y'
        t = year(time('D'))
        ch := ta.change(t) != 0
    else
        t = time(res)
        ch := ta.change(t) != 0
    ch

////////////
// INPUTS //
////////////

pp_period = input.string(title="Period", defval="Day", options=['Day', 'Week', 'Month', 'Year'])

pp_res = pp_period == 'Day' ? 'D' : pp_period == 'Week' ? 'W' : pp_period == 'Month' ? 'M' : 'Y'

/////////////////////
// Get HLC from HT //

// Calc High
var float high_cur = 0.0
high_cur := is_newbar(pp_res) ? high : math.max(high_cur[1], high)

var float phigh = 0.0
phigh := is_newbar(pp_res) ? high_cur[1] : phigh[1]

// Calc Low
var float low_cur = 0.0
low_cur := is_newbar(pp_res) ? low : math.min(low_cur[1], low)

var float plow = 0.0
plow := is_newbar(pp_res) ? low_cur[1] : plow[1]

// Calc Close
var float pclose = 0.0
pclose := is_newbar(pp_res) ? close[1] : pclose[1]

////////////////////////////////

vPP = (phigh + plow + pclose) / 3
vR1 = vPP + (phigh - plow) * 0.382
vS1 = vPP - (phigh - plow) * 0.382
vR2 = vPP + (phigh - plow) * 0.618
vS2 = vPP - (phigh - plow) * 0.618
vR3 = vPP + (phigh - plow) * 1.000
vS3 = vPP - (phigh - plow) * 1.000

//////////////
// PLOTTING //

var int bars_sinse = 0
bars_sinse := is_newbar(pp_res) ? 0 : bars_sinse[1] + 1

////////////////////////
// PLOT PIVOTS LEVELS //

vpp_p = line.new(bar_index[bars_sinse], vPP, bar_index, vPP, color=#f57f17, style=line.style_solid, extend=extend.right)
vs1_p = line.new(bar_index[bars_sinse], vS1, bar_index, vS1, color=#f57f17, style=line.style_solid, extend=extend.right)
vs2_p = line.new(bar_index[bars_sinse], vS2, bar_index, vS2, color=#f57f17, style=line.style_solid, extend=extend.right)
vs3_p = line.new(bar_index[bars_sinse], vS3, bar_index, vS3, color=#f57f17, style=line.style_solid, extend=extend.right)
vr1_p = line.new(bar_index[bars_sinse], vR1, bar_index, vR1, color=#f57f17, style=line.style_solid, extend=extend.right)
vr2_p = line.new(bar_index[bars_sinse], vR2, bar_index, vR2, color=#f57f17, style=line.style_solid, extend=extend.right)
vr3_p = line.new(bar_index[bars_sinse], vR3, bar_index, vR3, color=#f57f17, style=line.style_solid, extend=extend.right)

// Delete previous lines in the same period
if not is_newbar(pp_res)
    line.delete(vpp_p[1])
    line.delete(vs1_p[1])
    line.delete(vs2_p[1])
    line.delete(vs3_p[1])
    line.delete(vr1_p[1])
    line.delete(vr2_p[1])
    line.delete(vr3_p[1])

// Remove extend for the old lines
if is_newbar(pp_res)
    line.set_extend(vpp_p[1], extend.none)
    line.set_extend(vs1_p[1], extend.none)
    line.set_extend(vs2_p[1], extend.none)
    line.set_extend(vs3_p[1], extend.none)
    line.set_extend(vr1_p[1], extend.none)
    line.set_extend(vr2_p[1], extend.none)
    line.set_extend(vr3_p[1], extend.none)

// Add labels
if is_newbar(pp_res)
    label.new(bar_index, vPP, text="P",  style=label.style_none)
    label.new(bar_index, vS1, text="S1", style=label.style_none)
    label.new(bar_index, vS2, text="S2", style=label.style_none)
    label.new(bar_index, vS3, text="S3", style=label.style_none)
    label.new(bar_index, vR1, text="R1", style=label.style_none)
    label.new(bar_index, vR2, text="R2", style=label.style_none)
    label.new(bar_index, vR3, text="R3", style=label.style_none)

////////////
// ALERTS //

alertcondition(not is_newbar(pp_res) and ta.cross(close, vPP), "Cross Fib P",  "Cross Fib P")
alertcondition(not is_newbar(pp_res) and ta.cross(close, vS1), "Cross Fib S1", "Cross Fib S1")
alertcondition(not is_newbar(pp_res) and ta.cross(close, vS2), "Cross Fib S2", "Cross Fib S2")
alertcondition(not is_newbar(pp_res) and ta.cross(close, vS3), "Cross Fib S3", "Cross Fib S3")
alertcondition(not is_newbar(pp_res) and ta.cross(close, vR1), "Cross Fib R1", "Cross Fib R1")
alertcondition(not is_newbar(pp_res) and ta.cross(close, vR2), "Cross Fib R2", "Cross Fib R2")
alertcondition(not is_newbar(pp_res) and ta.cross(close, vR3), "Cross Fib R3", "Cross Fib R3")

alertcondition(not is_newbar(pp_res) and (ta.cross(close, vPP) or ta.cross(close, vS1) or ta.cross(close, vS2) or ta.cross(close, vS3) or
   ta.cross(close, vR1) or ta.cross(close, vR2) or ta.cross(close, vR3)), "Cross Fib Any", "Cross Fib Any")
````
