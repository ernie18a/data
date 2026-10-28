# [Dark Data] Volume Density

- url: https://www.tradingview.com/script/bINZuCQy-Dark-Data-Volume-Density/
- type: indicator
- pine_id: PUB;e6fcb8b688ee4827bf51a698924cf209
- version: 1.0

## Description

[b]Objective[/b]
Calculates the ratio of volume to price range over a given time period.

[b]Theory[/b]
Volume density is a valuable metric with many applications.
Elevated density can indicate accumulation of open interest, preceding significant price moves or liquidity sweeps.
A sharp drop in density can indicate gaps in fair value distribution, which the market often tries to fill.

[b]How To Use[/b]
Choose your period for each enabled plot.
Multiple plots are advised to reduce noise, Volume Density moves that align across periods tend to be more indicative.
Volume weighting is available as another potential tool to reduce noise.

[b]Nuanced Info/Warnings[/b]
The indications derived from volume density can be very speculative and may vary wildly between different assets. The biggest factor is likely finding the right combination of timeframe and period(s) to align with the asset's natural patterns of revisiting liquidity imbalances.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DarkData_Official

//@version=6
indicator("[Dark Data] Volume Density", shorttitle="Volume Density", precision=4)

grpCore = "Core Settings"
grpVis  = "Visuals"
period    = input.int(30,    "1st Period", minval=1, group=grpCore)
show2     = input.bool(true, "2nd",        group=grpCore, inline="plot2")
period2   = input.int(60,   "Period",      minval=1, group=grpCore, inline="plot2")
show3     = input.bool(true, "3rd",        group=grpCore, inline="plot3")
period3   = input.int(120,  "Period",      minval=1, group=grpCore, inline="plot3")
useWeight = input.bool(false, "Weight Volume", group=grpCore,
    tooltip="Applies a linear decay to volume, giving more weight to recent bars.")

showFill = input.bool(true, "Show Fills", group=grpVis)

// Weight[i] = (p - i): 1.0 at bar 0 (current), extrapolates to 0 at bar p (one past oldest).
// Normalised by wSum then scaled by p to stay comparable with the unweighted sum.
calcRatio(p) =>
    rv = ta.highest(high, p) - ta.lowest(low, p)
    if rv == 0.0
        na
    else if useWeight
        wVol = 0.0
        wSum = 0.0
        for i = 0 to p - 1
            w     = float(p - i)
            wVol += volume[i] * w
            wSum += w
        wVol / wSum * p / rv
    else
        math.sum(volume, p) / rv

ratio1 = calcRatio(period)
ratio2 = calcRatio(period2)
ratio3 = calcRatio(period3)

var float chartMax1 = 0.0
var float chartMax2 = 0.0
var float chartMax3 = 0.0
chartMax1 := math.max(chartMax1, nz(ratio1))
chartMax2 := math.max(chartMax2, nz(ratio2))
chartMax3 := math.max(chartMax3, nz(ratio3))

p_zero = plot(0, display=display.none, editable=false)
p3     = plot(show3 ? ratio3 : na, title="Volume Density (3)", color=color.new(#FFD600, 0), linewidth=1)
p2     = plot(show2 ? ratio2 : na, title="Volume Density (2)", color=color.new(#FF6D00, 0), linewidth=1)
p1     = plot(ratio1,              title="Volume Density (1)", color=color.new(#FF1744, 0), linewidth=1)

fill(p3, p_zero, chartMax3, 0.0, top_color=showFill ? color.new(#FFD600, 60)  : na, bottom_color=showFill ? color.new(#FFD600, 100) : na, title="Fill 3")
fill(p2, p_zero, chartMax2, 0.0, top_color=showFill ? color.new(#FF6D00, 60)  : na, bottom_color=showFill ? color.new(#FF6D00, 100) : na, title="Fill 2")
fill(p1, p_zero, chartMax1, 0.0, top_color=showFill ? color.new(#FF1744, 60)  : na, bottom_color=showFill ? color.new(#FF1744, 100) : na, title="Fill 1")
````
