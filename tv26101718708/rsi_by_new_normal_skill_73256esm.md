# RSI by New Normal Skill

- url: https://www.tradingview.com/script/73256ESm-RSI-by-New-Normal-Skill/
- type: indicator
- pine_id: PUB;c0fc0d0b8b7e437c8a70109b1cec8ee7
- version: 1.0

## Description

RSI by New Normal Skill V5
21/4/2569

RSI with momentum zone

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © New Normal Skill (Updated to v5)

//@version=5
indicator(title="RSI by New Normal Skill", shorttitle="RSI by NNS", format=format.price, precision=2)

// Inputs
len = input.int(14, minval=1, title="Length")
src = input.source(close, "Source")

// Manual RSI Calculation using ta.rma (Relative Moving Average)
up   = ta.rma(math.max(ta.change(src), 0), len)
down = ta.rma(-math.min(ta.change(src), 0), len)
rsi  = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

// Plotting the RSI Line
plot(rsi, "RSI", color = #FFDD33, linewidth = 2)

// Drawing Horizontal Lines (hlines)
band7 = hline(90, "Up Zone 4", color=color.gray)
band6 = hline(80, "Low Zone 4", color=color.gray)
fill(band7, band6, color.new(#4caf50, 70), title="Background4")

band5 = hline(65, "Up Zone 3", color=color.gray)
band4 = hline(55, "Low Zone 3", color=color.gray)
fill(band5, band4, color.new(#f44336, 70), title="Background3")

band3 = hline(50, "Up Zone 2", color=color.gray)
band2 = hline(40, "Low Zone 2", color=color.gray)
fill(band3, band2, color.new(#4caf50, 70), title="Background2")

band1 = hline(25, "Up zone 1", color=color.gray)
band0 = hline(15, "Low zone 1", color=color.gray)
fill(band1, band0, color.new(#f44336, 70), title="Background1")
````
