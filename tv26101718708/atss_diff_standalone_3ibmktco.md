# ATSS DIFF Standalone

- url: https://www.tradingview.com/script/3iBmKTCO-ATSS-DIFF-Standalone/
- type: indicator
- pine_id: PUB;e1821341900046bbab836ccdef93ed8e
- version: 1.0

## Description

**ATSS DIFF Standalone** is an overlay indicator that compares a fast and slow SuperSmoother line, then subtracts a smoothed signal line to produce a single DIFF value.

The label shows the current DIFF reading below the latest candle. Green means the fast-smoothed price is above its smoothed signal; red means it is below. Larger values suggest stronger short-term momentum difference, but it should be treated as a momentum/pressure reading, not a guaranteed next-candle direction signal.

## Source Code

````pine
//@version=6
indicator("ATSS DIFF Standalone", overlay=true, max_labels_count=500)

// Inputs
showDiffLabel = input.bool(true, "Show DIFF label")
diffFastLen = input.int(8, minval=1, title="DIFF Fast Line")
diffSlowLen = input.int(10, minval=1, title="DIFF Slow Line")
diffSmoothLen = input.int(8, minval=1, title="DIFF Smoothness")
diffScale = input.float(10000000.0, title="DIFF scale")
diffLabelOffsetAtr = input.float(3, minval=0.0, title="DIFF label offset ATR")

atr = ta.atr(14)
sp_src = close

// SuperSmoother fast
sp_f1 = (1.414 * math.pi) / diffFastLen
sp_a1 = math.exp(-sp_f1)
sp_c2_1 = 2.0 * sp_a1 * math.cos(sp_f1)
sp_c3_1 = -sp_a1 * sp_a1
sp_c1_1 = 1.0 - sp_c2_1 - sp_c3_1
var float sp_fast_smooth = na
sp_fast_smooth := sp_c1_1 * (sp_src + nz(sp_src[1], sp_src)) * 0.5 + sp_c2_1 * nz(sp_fast_smooth[1]) + sp_c3_1 * nz(sp_fast_smooth[2])

// SuperSmoother slow
sp_f2 = (1.414 * math.pi) / diffSlowLen
sp_a2 = math.exp(-sp_f2)
sp_c2_2 = 2.0 * sp_a2 * math.cos(sp_f2)
sp_c3_2 = -sp_a2 * sp_a2
sp_c1_2 = 1.0 - sp_c2_2 - sp_c3_2
var float sp_slow_smooth = na
sp_slow_smooth := sp_c1_2 * (sp_src + nz(sp_src[1], sp_src)) * 0.5 + sp_c2_2 * nz(sp_slow_smooth[1]) + sp_c3_2 * nz(sp_slow_smooth[2])

sp_green = (sp_fast_smooth - sp_slow_smooth) * diffScale

// SuperSmoother signal (yellow)
sp_f3 = (1.414 * math.pi) / diffSmoothLen
sp_a3 = math.exp(-sp_f3)
sp_c2_3 = 2.0 * sp_a3 * math.cos(sp_f3)
sp_c3_3 = -sp_a3 * sp_a3
sp_c1_3 = 1.0 - sp_c2_3 - sp_c3_3
var float sp_yellow = na
sp_yellow := sp_c1_3 * (sp_green + nz(sp_green[1], sp_green)) * 0.5 + sp_c2_3 * nz(sp_yellow[1]) + sp_c3_3 * nz(sp_yellow[2])

// DIFF = green - yellow
sp_diff = sp_green - sp_yellow
sp_diff_colour = sp_diff >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)
sp_diff_text = "DIFF: " + str.tostring(sp_diff, "#")

var label diffLabel = na
if barstate.islast and showDiffLabel
    label.delete(diffLabel)
    diffLabel := label.new(
         bar_index,
         low - nz(atr, high - low) * diffLabelOffsetAtr,
         sp_diff_text,
         style=label.style_label_up,
         color=sp_diff_colour,
         textcolor=color.white,
         size=size.normal
     )
````
