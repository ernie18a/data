# 52W High Low with CMP Distance %

- url: https://www.tradingview.com/script/zU21LeBo-52W-High-Low-with-CMP-Distance/
- type: indicator
- pine_id: PUB;80a5c943e075414e80728ba2be8eabd4
- version: 1.0

## Description

This indicator would help traders to know how much % is the CMP away from its 52 week high and 52 week low. And the good part is this is on the chart and this is not an oscillator as other 52 week high low oscillators. It would be easy to take buy sell decisions based on the indicator. Use this strictly on weekly charts only.

## Source Code

````pine
//@version=5
indicator("52W High Low with CMP Distance %", overlay=true)

// ─── INPUTS ───
weeks = input.int(52, "Number of Weeks", minval=10, maxval=520, step=52)

// ─── WEEKLY CHECK ───
isWeekly = timeframe.period == "W"

if not isWeekly and barstate.islast
    label.new(bar_index, high, "Switch to Weekly Chart", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.large)

// ─── CALCULATIONS ───
highN = ta.highest(high, weeks)
lowN  = ta.lowest(low,   weeks)

distFromHigh = (close - highN) / highN * 100
distFromLow  = (close - lowN)  / lowN  * 100

// ─── HIGH AND LOW LINES ───
plot(isWeekly ? highN : na, title="Period High", color=color.new(color.white, 0), linewidth=2)
plot(isWeekly ? lowN  : na, title="Period Low",  color=color.new(color.white, 0), linewidth=2)

// ─── LABELS ───
var label lblHigh = na
var label lblLow  = na
var label lblCMP  = na

if isWeekly and barstate.islast
    label.delete(lblHigh)
    label.delete(lblLow)
    label.delete(lblCMP)

    txtHigh = str.tostring(weeks) + "W High: " + str.tostring(highN, "#.##")
    txtLow  = str.tostring(weeks) + "W Low: " + str.tostring(lowN, "#.##")
    txtCMP  = "CMP " + str.tostring(close, "#.##") + " | High " + str.tostring(distFromHigh, "#.##") + "% | Low +" + str.tostring(distFromLow, "#.##") + "%"

    lblHigh := label.new(bar_index + 3, highN, txtHigh, color=color.new(color.white, 20), textcolor=color.black, style=label.style_label_left, size=size.normal)
    lblLow  := label.new(bar_index + 3, lowN, txtLow, color=color.new(color.white, 20), textcolor=color.black, style=label.style_label_left, size=size.normal)
    lblCMP  := label.new(bar_index + 3, close, txtCMP, color=color.new(color.yellow, 10), textcolor=color.black, style=label.style_label_left, size=size.normal)

// ─── BACKGROUND ───
nearHigh = isWeekly and math.abs(close - highN) / highN * 100 < 2
nearLow  = isWeekly and math.abs(close - lowN)  / lowN  * 100 < 2

bgcolor(nearHigh ? color.new(color.white, 90) : na, title="Near High")
bgcolor(nearLow  ? color.new(color.white, 90) : na, title="Near Low")

// ─── TABLE — only High % and Low % ───
var table t = table.new(position.top_right, 2, 2, bgcolor=color.new(color.black, 60), border_width=1)

if isWeekly and barstate.islast
    table.cell(t, 0, 0, "From High", text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 0, str.tostring(distFromHigh, "#.##") + "%", text_color=color.white, text_size=size.normal)
    table.cell(t, 0, 1, "From Low", text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 1, "+" + str.tostring(distFromLow, "#.##") + "%", text_color=color.white, text_size=size.normal)
````
