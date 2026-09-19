<!-- tradingview-pine-id: PUB;079c0f5e0e434644ae65c14f08867885 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Simple Support & Resistance (Multi-Timeframe filter)

Source: https://www.tradingview.com/script/JfUvPW7f-Simple-Support-Resistance-Multi-Timeframe-filter/

## Description

Identify key market levels with clarity and precision. This Pine Script v6 indicator dynamically calculates and draws essential support and resistance levels directly on your chart—either from your current view or a higher timeframe (MTF).

Key Features:

Multi-Timeframe Flexibility: Track higher timeframe key levels without constantly switching charts.

Independent Lookback: Tailor the lookback period for support and resistance separately to fit your strategy.

Wick or Body Calculation: Choose whether levels are based on candle wicks (high/low) or candle bodies (open/close).

Clean Visuals: Dynamic lines and clear labels keep your chart readable and actionable.

Filter out the noise, focus on high-probability zones, and trade with confidence.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Maximkrzsk

//@version=6
indicator("Simple Support & Resistance (Multi-Timeframe filter)", shorttitle = "Sup & Res", overlay = true)

// Get user input
htf = input.timeframe("", "Higher Timeframe", tooltip = "Timeframe used to calculate levels. Leave empty to use the current chart timeframe.")
lookbackSup = input.int(100, "Support Lookback", tooltip = "Number of bars to look back to find the lowest support point.", inline = "sup")
supCol      = input.color(color.blue, "", inline = "sup")
lookbackRes = input.int(100, "Resistance Lookback", tooltip = "Number of bars to look back to find the highest resistance point.", inline = "res")
resCol      = input.color(color.orange, "", inline = "res")
useBody     = input.bool(false, "Use Candle Body?", tooltip = "If enabled, calculations use open/close prices instead of high/low wicks.")

// Get the current Resistace and Support
f_calcLevels() =>
    res = ta.highest(useBody ? close : high, lookbackRes)
    sup = ta.lowest(useBody ? close : low, lookbackSup)
    [res, sup]

// Higher Timeframe data request
[resistace, support] = request.security(syminfo.tickerid, htf, f_calcLevels(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// Draw Resitace and Support
var line resLine = na
var line supLine = na
var label resLab = na
var label supLab = na

if barstate.islast
    line.delete(resLine)
    line.delete(supLine)
    label.delete(resLab)
    label.delete(supLab)

    resLine := line.new(bar_index - lookbackRes, resistace, bar_index + 30, resistace, color = resCol, width = 2)
    supLine := line.new(bar_index - lookbackSup, support, bar_index + 30, support, color = supCol, width = 2)

    resLab  := label.new(bar_index + 30, resistace, "Resistance " + htf, color = resCol, style = label.style_label_left)
    supLab  := label.new(bar_index + 30, support, "Support " + htf, color = supCol, style = label.style_label_left)
````
