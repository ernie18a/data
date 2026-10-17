# Log Regression Channel (1000 Bars)

- url: https://www.tradingview.com/script/xxbdDQmM-Log-Regression-Channel-1000-Bars/
- type: indicator
- pine_id: PUB;7b457a874b014f58991f2cf45b0d609e
- version: 1.0

## Description

This indicator fits a linear regression to the natural log of price over a configurable lookback (default 1000 bars), then plots the resulting trend line along with standard deviation bands above and below it.

Working in log space rather than raw price means the fit follows percentage-based (exponential) growth, which suits assets that compound over time. The center line represents the statistical trend over the lookback window. The inner bands sit at 1 standard deviation of the regression residuals, and the outer bands at 2 standard deviations, giving a sense of how stretched price is relative to its own trend: near the upper bands is historically extended, near the lower bands is historically compressed.

How it works:

- Computes a least-squares linear regression on log(price) across the lookback window
- Measures the standard deviation of the residuals (how far price typically strays from the fit)
- Draws the center line plus inner (1 SD) and outer (2 SD) bands, extended to the right
- Auto-adapts to each symbol and timeframe; bars with missing or non-positive prices are skipped so it renders across a wide range of assets

Inputs:

- Lookback length (number of bars used in the fit)
- Source
- Inner and outer band multipliers (default 1 and 2 standard deviations)
- Editable colors and line widths for the center line and each band set

How to use:

View on a log-scaled chart for correct interpretation (the channel is fit in log space). Higher timeframes describe a longer-term trend; lower timeframes describe a shorter one. Most meaningful on assets with a persistent growth trend, and less informative on flat, range-bound, or structurally declining markets. Best used as one input among several rather than a standalone signal.

## Source Code

````pine
//@version=6
indicator("Log Regression Channel - Auto-fit", overlay=true, max_lines_count=20)

length = input.int(1000, "Lookback (bars)", minval=2)
src    = input.source(close, "Source")
dev1   = input.float(1.0, "Inner band (std dev)", step=0.1, group="Bands")
dev2   = input.float(2.0, "Outer band (std dev)", step=0.1, group="Bands")

colMid  = input.color(color.black, "Center line", group="Style")
colDev1 = input.color(color.red,   "Inner bands (1 SD)", group="Style")
colDev2 = input.color(color.black, "Outer bands (2 SD)", group="Style")
wMid  = input.int(2, "Center width", minval=1, maxval=10, group="Style")
wDev1 = input.int(1, "Inner width",  minval=1, maxval=10, group="Style")
wDev2 = input.int(1, "Outer width",  minval=1, maxval=10, group="Style")

f(base, k, sd) => math.exp(base + k * sd)

var line lMid = na
var line lU1  = na
var line lL1  = na
var line lU2  = na
var line lL2  = na

n = math.min(length, bar_index + 1)

float sumX  = 0.0
float sumY  = 0.0
float sumXY = 0.0
float sumX2 = 0.0
float sumY2 = 0.0
int   cnt   = 0
float xMin  = na
float xMax  = na

for i = 0 to n - 1
    price = src[i]
    if not na(price) and price > 0
        x = float(n - 1 - i)
        y = math.log(price)
        sumX  += x
        sumY  += y
        sumXY += x * y
        sumX2 += x * x
        sumY2 += y * y
        cnt   += 1
        xMin := na(xMin) ? x : math.min(xMin, x)
        xMax := na(xMax) ? x : math.max(xMax, x)

float nf    = float(cnt)
float denom = cnt > 1 ? nf * sumX2 - sumX * sumX : na
float slope = not na(denom) and denom != 0 ? (nf * sumXY - sumX * sumY) / denom : na
float intercept = not na(slope) ? (sumY - slope * sumX) / nf : na

float sse   = not na(slope) ? sumY2 - intercept * sumY - slope * sumXY : na
float stdev = not na(sse) ? math.sqrt(math.max(sse, 0.0) / nf) : na

int   xOldBar = not na(xMin) ? bar_index - (n - 1) + int(xMin) : na
int   xNewBar = not na(xMax) ? bar_index - (n - 1) + int(xMax) : na
float yOld    = not na(slope) ? intercept + slope * xMin : na
float yNew    = not na(slope) ? intercept + slope * xMax : na

if barstate.islast and not na(slope) and not na(stdev)
    line.delete(lMid)
    line.delete(lU1)
    line.delete(lL1)
    line.delete(lU2)
    line.delete(lL2)
    lMid := line.new(xOldBar, math.exp(yOld), xNewBar, math.exp(yNew), xloc.bar_index, extend=extend.right, color=colMid, width=wMid)
    lU1  := line.new(xOldBar, f(yOld, dev1, stdev), xNewBar, f(yNew, dev1, stdev), xloc.bar_index, extend=extend.right, color=colDev1, width=wDev1)
    lL1  := line.new(xOldBar, f(yOld, 0.0 - dev1, stdev), xNewBar, f(yNew, 0.0 - dev1, stdev), xloc.bar_index, extend=extend.right, color=colDev1, width=wDev1)
    lU2  := line.new(xOldBar, f(yOld, dev2, stdev), xNewBar, f(yNew, dev2, stdev), xloc.bar_index, extend=extend.right, color=colDev2, width=wDev2)
    lL2  := line.new(xOldBar, f(yOld, 0.0 - dev2, stdev), xNewBar, f(yNew, 0.0 - dev2, stdev), xloc.bar_index, extend=extend.right, color=colDev2, width=wDev2)
````
