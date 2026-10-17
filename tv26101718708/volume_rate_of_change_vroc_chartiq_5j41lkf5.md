# Volume Rate of Change (VROC) - Chartiq

- url: https://www.tradingview.com/script/5j41lkF5-Volume-Rate-of-Change-VROC-Chartiq/
- type: indicator
- pine_id: PUB;a4d54a5862684a12b008a1a8efda438e
- version: 1.0

## Description

This is the formula used by Chartiq used in Kite so if anyone missing it in zerodha can find it here.

Volume Rate of Change🔗
Indicator Type🔗
Volume

Description🔗
Volume Rate of Change measures the percent change in volume over a set range.

Related Study: Price Rate of Change

Formula🔗
VROC = Current Volume – Volume (n-periods ago) * 100 -1 ÷ Volume n-periods ago

Math🔗
Input Parameters
Period (N)
R(i) = 100*((X(i)/X(i-N))-1)

## Source Code

````pine
//@version=5
indicator("Volume Rate of Change (VROC) - Custom", overlay=false)

// Input parameters
n = input.int(14, title="Period (N)", minval=1)

// The formula provided: 100 * ((Current_Volume / Volume_N_Periods_Ago) - 1)
// X(i) is volume
// X(i-N) is volume[n]
vrocValue = 100 * ((volume / volume[n]) - 1)

// Plotting
plot(vrocValue, title="VROC", color=color.blue, linewidth=2)

// Optional: Zero line for reference
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)
````
