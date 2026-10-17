# 20/200SMAangle

- url: https://www.tradingview.com/script/EXg0pqmP-20-200SMAangle/
- type: indicator
- pine_id: PUB;cb49894b22cf424891195c8375f56905
- version: 8.0

## Description

Simple script prob tons more out there that do even more.

Shows when the 20ma is crossing the 200ma, with angle adjustment for more aggressive movement.

## Source Code

````pine
//@version=6
indicator("SMA°", overlay=true)

//---------------------------------------------------------
// Inputs
//---------------------------------------------------------
enableBullAlert = input.bool(true, "Enable Bullish Alert")
enableBearAlert = input.bool(true, "Enable Bearish Alert")

fastLen   = input.int(20,  "Fast SMA")
slowLen   = input.int(200, "Slow SMA")
lookback  = input.int(5,   "Slope Lookback")
minAngle  = input.float(5.0, "Minimum Angle (Degrees)")   // Now meaningful
atrLen    = input.int(14,  "ATR Normalization Length")

//---------------------------------------------------------
// Heikin Ashi Close
//---------------------------------------------------------
haClose = (open + high + low + close) / 4

//---------------------------------------------------------
// SMAs
//---------------------------------------------------------
smaFast = ta.sma(haClose, fastLen)
smaSlow = ta.sma(haClose, slowLen)

// Dashed effect
isDashFast = bar_index % 4 < 3
isDashSlow = bar_index % 5 < 4

plot(isDashFast ? smaFast : na, "Fast SMA", color=color.yellow, linewidth=2, style=plot.style_linebr)
plot(isDashSlow ? smaSlow : na, "Slow SMA", color=color.red, linewidth=3, style=plot.style_linebr)

//---------------------------------------------------------
// Cross Conditions
//---------------------------------------------------------
bullCross = ta.crossover(smaFast, smaSlow)
bearCross = ta.crossunder(smaFast, smaSlow)

//---------------------------------------------------------
// True Angle Calculation (0°–90°)
//---------------------------------------------------------
// Normalize slope by ATR so angle behaves like real geometry
atr = ta.atr(atrLen)

// Rise = SMA change
rise = smaFast - smaFast[lookback]

// Run = lookback bars * ATR (normalizes chart scaling)
run = lookback * atr

// Slope ratio
slope = rise / run

// Convert to degrees
angle = math.atan(slope) * 180 / math.pi

//---------------------------------------------------------
// Filtered Signals
//---------------------------------------------------------
bullSignal = bullCross and angle > minAngle
bearSignal = bearCross and angle < -minAngle

//---------------------------------------------------------
// Plot Arrows
//---------------------------------------------------------
plotshape(
    bullSignal,
    title="Bullish Cross",
    location=location.belowbar,
    color=color.lime,
    style=shape.triangleup,
    size=size.large
)

plotshape(
    bearSignal,
    title="Bearish Cross",
    location=location.abovebar,
    color=color.red,
    style=shape.triangledown,
    size=size.large
)

//---------------------------------------------------------
// Alerts
//---------------------------------------------------------
if bullSignal and enableBullAlert
    alert(
        "Bullish 20/200 SMA cross with angle " + str.tostring(angle, "#.##") + "°",
        alert.freq_once_per_bar_close
    )

if bearSignal and enableBearAlert
    alert(
        "Bearish 20/200 SMA cross with angle " + str.tostring(angle, "#.##") + "°",
        alert.freq_once_per_bar_close
    )

//---------------------------------------------------------
// Debug Plot (optional)
//---------------------------------------------------------
// plot(angle, "Angle", color=color.white)
// hline(minAngle, "Min Angle", color=color.green)
// hline(-minAngle, "Min Angle -", color=color.red)
````
