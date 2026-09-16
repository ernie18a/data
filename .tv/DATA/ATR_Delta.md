<!-- tradingview-pine-id: PUB;47e1a52a09404473acf7f69ec24974af -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ATR Delta

Source: https://www.tradingview.com/script/AZdx8UK2-ATR-Delta/

## Description

ATR Delta is a volatility oscillator that separates the Average True Range into its up- and down-move components instead of showing a single combined value. It's built for anyone who wants to see whether current volatility is being driven more by up bars or by down bars, rather than only how large that volatility is overall — for example to judge whether a rise or a drop in volatility comes from bullish or bearish price action. Each bar's true range is assigned to the up or down side depending on whether the bar closed higher or lower than the previous close, and both sides are then smoothed independently using the same RMA-based method the classic ATR uses. The smoothing length and the two fill colors can be freely adjusted.

Calculation

Length:        number of bars used to smooth the directional true range.

Appearance

Bull / Bear:   two colors: one for the area between the Up line and the Delta line, the other for the area between the Delta line and the Down line.

https://www.tradingview.com/x/3AXrDRI9/

The indicator plots two smoothed lines — one for the true range on up bars, one for the true range on down bars, mirrored below the zero line — plus a delta line placed exactly between them. The delta line sits above zero when the up side currently has more true range than the down side, and below zero when the down side has more; the further it moves from zero, the larger that imbalance. The area between the upper line and the delta line is filled in Bull Color, and the area between the delta line and the lower line is filled in Bear Color. A bar with an unchanged close is always counted on the up side.

https://www.tradingview.com/x/wqf6IrBv/

This indicator is intended solely for market analysis and does not constitute investment advice or a guarantee of success. Use it at your own discretion and risk; past results are not indicative of future performance.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © graefe
//@version=6
indicator(title = "ATR Delta", overlay = false)

int   inp_length    = input.int(defval = 14, title = "Length", minval = 1, maxval = 2000, group = "Calculation", tooltip = "Number of bars used to smooth the directional true range.")
color inp_bullColor = input.color(defval = color.new(#bac70c, 55), title = "Bull Color", group = "Appearance")
color inp_bearColor = input.color(defval = color.new(#96420a, 55), title = "Bear Color", group = "Appearance")

// True Range is assigned to the up or down side depending on price direction; an unchanged close counts as an up bar
float cal_trueRange = ta.tr(true)
float cal_up        = close >= close[1] ? cal_trueRange : 0.0
float cal_down      = close <  close[1] ? cal_trueRange : 0.0

// Both sides are smoothed independently; the down side is negated so it plots below the zero line
float cal_upLine    = ta.rma(cal_up, inp_length)
float cal_downLine  = - ta.rma(cal_down, inp_length)

// Delta line sits exactly between both sides: above zero when the up side is larger, below zero when the down side is larger
float cal_midLine   = (cal_upLine + cal_downLine) / 2.0

outp_upLine   = plot(series = cal_upLine, title = "Up", color = na, linewidth = 1, editable = false)
outp_midLine  = plot(series = cal_midLine, title = "Delta", color = na, linewidth = 1, editable = false)
outp_downLine = plot(series = cal_downLine, title = "Down", color = na, linewidth = 1, editable = false)

fill(plot1 = outp_upLine, plot2 = outp_midLine, color = inp_bullColor, title = "Bull Fill", editable = false)
fill(plot1 = outp_midLine, plot2 = outp_downLine, color = inp_bearColor, title = "Bear Fill", editable = false)

hline(price = 0, title = "Zero Line", color = color.new(chart.fg_color, 50), editable = false)
````
