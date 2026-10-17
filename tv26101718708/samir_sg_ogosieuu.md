# SAMIR SG]

- url: https://www.tradingview.com/script/OGoSieUU-SAMIR-SG/
- type: indicator
- pine_id: PUB;d8f1bd0a4a004e0bad98784db1094d17
- version: 1.0

## Description

For Education Purpose. short term marker trend changing

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Farazhassan27

//@version=6
indicator(title="SAMIR SG]", shorttitle="SAMIR SG", overlay=true)
src = close
sm = input.int(21, title="Smoothing Period")
cd = input.float(0.4, title="Constant D")
ebc = input.bool(false, title="Color Bars")
ribm = input.bool(false, title="Ribbon Mode")
di = (sm - 1.0) / 2.0 + 1.0
c1 = 2 / (di + 1.0)
c2 = 1 - c1
c3 = 3.0 * (cd * cd + cd * cd * cd)
c4 = -3.0 * (2.0 * cd * cd + cd + cd * cd * cd)
c5 = 3.0 * cd + 1.0 + cd * cd * cd + 3.0 * cd * cd

var float i1 = na
var float i2 = na
var float i3 = na
var float i4 = na
var float i5 = na
var float i6 = na

i1 := c1 * src + c2 * nz(i1[1])
i2 := c1 * i1 + c2 * nz(i2[1])
i3 := c1 * i2 + c2 * nz(i3[1])
i4 := c1 * i3 + c2 * nz(i4[1])
i5 := c1 * i4 + c2 * nz(i5[1])
i6 := c1 * i5 + c2 * nz(i6[1])

bfr = -cd * cd * cd * i6 + c3 * i5 + c4 * i4 + c5 * i3

// Trend color
bfrC = bfr > nz(bfr[1]) ? color.green : bfr < nz(bfr[1]) ? color.red : color.blue
tc = ebc ? color.gray : bfrC

plot(ribm ? na : bfr, title="Trend", linewidth=3, style=plot.style_circles, color=tc)
bgcolor(ribm ? color.new(bfrC, 50) : na)

barcolor(ebc ? bfrC : na)

// Buy signal: trend changes up
buySignal = (bfr > nz(bfr[1])) and (nz(bfr[1]) <= nz(bfr[2]))
// Sell signal: trend changes down
sellSignal = (bfr < nz(bfr[1])) and (nz(bfr[1]) >= nz(bfr[2]))

// Plot buy/sell logos as labels on chart
plotshape(buySignal, title="", location=location.belowbar, color=color.green, style=shape.labelup, size=size.small, text="")
plotshape(sellSignal, title="", location=location.abovebar, color=color.red, style=shape.labeldown, size=size.small, text="")
````
