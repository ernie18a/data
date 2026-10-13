<!-- tradingview-pine-id: PUB;0b95994f85d84d739bbd7cdfde6c0e88 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Period High/Low

Source: https://www.tradingview.com/script/v5wIBtNQ-Period-High-Low/

## Description

Period High/Low is an overlay indicator that marks the highest high and the lowest low reached within a fixed lookback window, connecting each one to the exact bar where it occurred. It's built for anyone who wants a quick visual reference for the recent trading range — for example to gauge how far price currently sits from its recent extremes, or to notice at a glance when a new high or low is being set — without reading the values off the price axis by eye. Both levels come from a simple highest-high / lowest-low lookback over the chosen length, recalculated on every bar so the marked levels always reflect the most recent window.

Levels

Length:               number of bars to look back for the highest high and the lowest low.
Line Width:           thickness of both plotted lines.
High / Low Color:     two colors: one for the high line, the other for the low line.

https://www.tradingview.com/x/hiclvkCb/

The indicator draws two horizontal line segments — one stretching from the bar where the highest high of the lookback window occurred to the current bar, the other doing the same for the lowest low. Both segments are recalculated and repositioned on every bar, so only the current window's extremes are shown; once a new high or low takes over, the previous one disappears rather than staying on the chart as a historical mark.

https://www.tradingview.com/x/dZKe03tI/

This indicator is intended solely for market analysis and does not constitute investment advice or a guarantee of success. Use it at your own discretion and risk; past results are not indicative of future performance.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © graefe
//@version=6
indicator(title = "Period High/Low", overlay = true)

const string con_grpLevels     = "Levels"
const string con_lengthTooltip = "Lookback window used to locate the highest high and the lowest low."

int   inp_length    = input.int(defval = 200, title = "Length", minval = 1, maxval = 5000, group = con_grpLevels, tooltip = con_lengthTooltip)
int   inp_lineWidth = input.int(defval = 1, title = "Line Width", minval = 1, maxval = 5, group = con_grpLevels)
color inp_highColor = input.color(defval = color.new(#a0a0a0, 0), title = "High / Low Color", inline = "colors", group = con_grpLevels)
color inp_lowColor  = input.color(defval = color.new(#a0a0a0, 0), title = "", inline = "colors", group = con_grpLevels)

// Highest high and lowest low within the lookback length
float cal_highestHigh   = ta.highest(source = high, length = inp_length)
float cal_lowestLow     = ta.lowest(source = low, length = inp_length)
// Distance in bars to that high/low point; highestbars/lowestbars return a negative offset, math.abs makes it positive
int   cal_barsSinceHigh = math.abs(number = ta.highestbars(source = high, length = inp_length))
int   cal_barsSinceLow  = math.abs(number = ta.lowestbars(source = low, length = inp_length))

// Lines are created once and afterwards only repositioned (line.set_xy), instead of being recreated on every bar
var line outp_highLine = line.new(x1 = bar_index, y1 = cal_highestHigh, x2 = bar_index, y2 = cal_highestHigh, extend = extend.none, color = inp_highColor, width = inp_lineWidth)
var line outp_lowLine  = line.new(x1 = bar_index, y1 = cal_lowestLow,   x2 = bar_index, y2 = cal_lowestLow,   extend = extend.none, color = inp_lowColor,  width = inp_lineWidth)

// Repositioned only on the last bar: the lines show only the current highest/lowest value, no history of past periods
if barstate.islast
    line.set_xy1(id = outp_highLine, x = bar_index - cal_barsSinceHigh, y = cal_highestHigh)
    line.set_xy2(id = outp_highLine, x = bar_index, y = cal_highestHigh)
    line.set_xy1(id = outp_lowLine, x = bar_index - cal_barsSinceLow, y = cal_lowestLow)
    line.set_xy2(id = outp_lowLine, x = bar_index, y = cal_lowestLow)
````
