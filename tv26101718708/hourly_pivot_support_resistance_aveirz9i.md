# Hourly Pivot Support Resistance

- url: https://www.tradingview.com/script/AvEIRZ9I-Hourly-Pivot-Support-Resistance/
- type: indicator
- pine_id: PUB;f344e5bf1dd1480cbf1ce321ea35322a
- version: 1.0

## Description

Hourly pivots support and resistance
Hourly Pivot Support Resistance
Hourly Pivot Support Resistance
Hourly Pivot Support Resistance
Hourly Pivot Support Resistance
Hourly Pivot Support Resistance
Hourly Pivot Support Resistance

## Source Code

````pine
//@version=6
indicator("Codex Hourly Pivot Support Resistance", overlay=true, max_lines_count=500)

//====================================================
// Inputs
//====================================================
cashSession = input.session("0930-1600", "Cash Session")
tz = input.string("America/New_York", "Timezone")

showR1 = input.bool(true, "Show R1")
showS1 = input.bool(true, "Show S1")
showR2 = input.bool(true, "Show R2")
showS2 = input.bool(true, "Show S2")
showPP = input.bool(false, "Show Pivot Point")

rColor = input.color(color.new(color.red, 0), "Resistance Color")
sColor = input.color(color.new(color.lime, 0), "Support Color")
ppColor = input.color(color.new(color.yellow, 0), "Pivot Color")

lineWidth = input.int(2, "Line Width", minval=1, maxval=5)

//====================================================
// Session + Hour Detection
//====================================================
inCash = not na(time(timeframe.period, cashSession, tz))
cashStarted = inCash and not inCash[1]

hourKey = hour(time, tz)
newHour = inCash and not cashStarted and hourKey != hourKey[1]

//====================================================
// Current Cash Hour State
//====================================================
var float hOpen = na
var float hHigh = na
var float hLow = na
var float hClose = na
var bool hasHour = false

// Previous completed hour pivot levels
var float pp = na
var float r1 = na
var float s1 = na
var float r2 = na
var float s2 = na

calcLevels(float high_, float low_, float close_) =>
    float range_ = high_ - low_
    float pivot_ = (high_ + low_ + close_) / 3.0
    float r1_ = 2.0 * pivot_ - low_
    float s1_ = 2.0 * pivot_ - high_
    float r2_ = pivot_ + range_
    float s2_ = pivot_ - range_
    [pivot_, r1_, s1_, r2_, s2_]

//====================================================
// Hourly Roll
//====================================================
if cashStarted
    hOpen := open
    hHigh := high
    hLow := low
    hClose := close
    hasHour := true

    pp := na
    r1 := na
    s1 := na
    r2 := na
    s2 := na

else if newHour and hasHour
    [newPP, newR1, newS1, newR2, newS2] = calcLevels(hHigh, hLow, hClose)

    pp := newPP
    r1 := newR1
    s1 := newS1
    r2 := newR2
    s2 := newS2

    hOpen := open
    hHigh := high
    hLow := low
    hClose := close

else if inCash
    hHigh := na(hHigh) ? high : math.max(hHigh, high)
    hLow := na(hLow) ? low : math.min(hLow, low)
    hClose := close
    hasHour := true

//====================================================
// Plots
//====================================================
plot(inCash and showPP ? pp : na, "Previous Hour Pivot", color=ppColor, linewidth=lineWidth, style=plot.style_stepline)

plot(inCash and showR1 ? r1 : na, "Previous Hour R1", color=color.new(rColor, 35), linewidth=lineWidth, style=plot.style_stepline)
plot(inCash and showS1 ? s1 : na, "Previous Hour S1", color=color.new(sColor, 35), linewidth=lineWidth, style=plot.style_stepline)

plot(inCash and showR2 ? r2 : na, "Previous Hour R2", color=rColor, linewidth=lineWidth, style=plot.style_stepline)
plot(inCash and showS2 ? s2 : na, "Previous Hour S2", color=sColor, linewidth=lineWidth, style=plot.style_stepline)
````
