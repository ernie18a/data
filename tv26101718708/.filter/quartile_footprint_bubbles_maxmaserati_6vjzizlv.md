# Quartile Footprint Bubbles @MaxMaserati

- url: https://www.tradingview.com/script/6VJZIZLv-Quartile-Footprint-Bubbles-MaxMaserati/
- type: indicator
- pine_id: PUB;84e481b4291a43b2b12181546f9f8ebb
- version: 1.0

## Description

Quartile Levels Volume Acceptance/Rejection @MaxMaserati 

This highly technical order flow tool merges quartile-based market structure with intrabar footprint analytics. It reveals the exact micro-price levels where liquidity resides and exposes whether buyers or sellers are seizing control at critical structural boundaries.

─── QUARTILE MARKET STRUCTURE ───
The indicator calculates the absolute trading range over a defined lookback period and mathematically divides it into four equal quartiles, projecting five dynamic structural zones:

100% (Upper Extremity) — Extreme Bearish Dynamic Resistance * 75% (Upper Quartile) — Bullish Dynamic Range / Support

50% (Midpoint) — Dynamic 50% Range / Equilibrium

25% (Lower Quartile) — Bearish Dynamic Range / Resistance

0% (Lower Extremity) — Extreme Bullish Dynamic Support

These quartile boundaries act as algorithmic tripwires. When price touches any of these levels, the indicator activates its footprint engine.

[image][url=https://www.tradingview.com/x/7McfDhJm/]https://www.tradingview.com/x/7McfDhJm/[/url][/image]

─── EXACT INTRABAR POC ───
Unlike basic indicators that plot blindly on the high or low of a candle, this tool scans a Lower Timeframe (LTF) inside the live bar to locate the exact Point of Control (POC).

Bubbles and text labels are plotted precisely at the micro-level where the heaviest volume transacted, revealing hidden pockets of liquidity just above or just below the quartile lines.

─── CONCENTRIC FOOTPRINT BUBBLES ───
When a quartile line is tested, concentric bubbles appear at the POC, sized dynamically using an advanced 5-tier percentile algorithm (50th, 75th, 90th, and 97th percentiles) to filter out market noise:

Outer Bubble (Volume Mass): Represents total market participation. A massive outer bubble indicates intense liquidity and institutional interest.

Inner Bubble (Delta Pressure): Represents the true bid/ask delta. Green indicates aggressive buying dominated the POC; Red indicates aggressive selling dominated.

Dual Text Labels: Cleanly displays the Total Volume (top, neutral color) over the Net Delta (bottom, colored) directly at the POC coordinate.

─── HOW TO TRADE IT ───
Defending the Extremes: Look for large green inner bubbles at the 0% or 25% quartiles (buyers defending support) and large red inner bubbles at the 75% or 100% quartiles (sellers defending resistance).

The 50% Equilibrium: The 50% Structural Pivot dictates trend context. Price holding above it with green bubbles on pullbacks is bullish. Price holding below it with red bubbles on retracements is bearish.

Spotting Absorption: A massive outer volume bubble containing a tiny inner delta bubble means huge volume was traded, but neither side won decisively. This signals institutional absorption, not a directional breakout.

─── KEY SETTINGS ───
Structure Lookback: The rolling window used to calculate the highest highs and lowest lows for the quartile grid.

LTF Resolution: The micro-timeframe used to scan for the Intrabar POC and Delta (e.g., 1-minute is optimal for a 15-minute chart).

Bubble Size Offset: Shift the visual scaling of all bubbles up or down (+1 to enlarge, -1 to shrink) to perfectly fit the visual density of your specific asset.

Targeted Toggles: Individually turn specific quartile lines, outer/inner bubbles, and text labels on or off for a perfectly clean workspace.

## Source Code

````pine
//@version=6
indicator("Quartile Levels Volume Acceptance/Rejection @MaxMaserati", "QuartileFlow @MaxMaserati", overlay=true)

// ─── INPUTS ────────────────────────────────────────────────────────────────
grp_qs  = "Quartile Structure"
grp_bub = "Order Flow Bubbles"
grp_lbl = "Labels"
grp_adv = "Advanced"

// Quartile Structure
lookbackPeriod        = input.int(50, "Lookback Period", minval=5, tooltip="Number of bars used to calculate the highest high and lowest low for quartile level placement.", group=grp_qs)

show_sellers_defense  = input.bool(true,  "100% — Sellers Defense", inline="sd", group=grp_qs)
sellers_defense_color = input.color(color.new(color.red,   40), "", inline="sd", group=grp_qs)

show_upper_quartile   = input.bool(true,  "75%  — Upper Quartile",  inline="uq", group=grp_qs)
upper_quartile_color  = input.color(color.new(color.green, 40), "", inline="uq", group=grp_qs)

show_balance_line     = input.bool(true,  "50%  — Structural Pivot", inline="md", group=grp_qs)
pivot_line_color      = input.color(color.new(color.gray,   0), "", inline="md", group=grp_qs)

show_lower_quartile   = input.bool(true,  "25%  — Lower Quartile",  inline="lq", group=grp_qs)
lower_quartile_color  = input.color(color.new(color.red,   40), "", inline="lq", group=grp_qs)

show_buyers_defense   = input.bool(true,  "0%   — Buyers Defense",  inline="bd", group=grp_qs)
buyers_defense_color  = input.color(color.new(color.green, 40), "", inline="bd", group=grp_qs)

// Order Flow Bubbles
show_bubbles          = input.bool(true,  "Enable Bubbles",                                                    group=grp_bub)
show_outer_bub        = input.bool(false,  "Outer  — Volume Mass",   inline="ob", group=grp_bub)
outer_bub_color       = input.color(color.new(#9c9c9c, 80),      "", inline="ob", group=grp_bub)
show_inner_bub        = input.bool(true,  "Inner  — Delta Pressure", inline="ib", group=grp_bub)
bull_bubble_color     = input.color(color.new(color.lime, 30),   "▲", inline="ib", group=grp_bub)
bear_bubble_color     = input.color(color.new(color.red,  30),   "▼", inline="ib", group=grp_bub)
size_offset           = input.int(0, "Bubble Size Offset", minval=-2, maxval=2, tooltip="Shifts all bubble sizes up or down one tier. Use +1 for wider timeframes, -1 for busier charts.", group=grp_bub)

// Labels
show_labels           = input.bool(true, "Show Volume and Delta Labels",                                       group=grp_lbl)
i_lblSize             = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"],      group=grp_lbl)

// Advanced
ltf_res               = input.timeframe("1", "LTF Resolution", tooltip="Lower timeframe scanned inside each bar to locate the price with the highest volume (POC) and to calculate net delta. Set below your chart timeframe. Default 1-minute works well on 15m charts.", group=grp_adv)

// ─── HELPERS ───────────────────────────────────────────────────────────────
f_get_lbl_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_formatNum(float v) =>
    float  av   = math.abs(v)
    string sign = v < 0 ? "-" : ""
    av >= 1000000000 ? sign + str.tostring(av / 1000000000, "#.##") + "B" :
     av >= 1000000   ? sign + str.tostring(av / 1000000,    "#.##") + "M" :
     av >= 1000      ? sign + str.tostring(av / 1000,       "#.1")  + "K" :
     sign + str.tostring(av, "#")

// ─── STRUCTURE ─────────────────────────────────────────────────────────────
highest_high = ta.highest(high, lookbackPeriod)
lowest_low   = ta.lowest(low,   lookbackPeriod)
price_range  = highest_high - lowest_low

sellersDefenseLine = highest_high
upperQuartileLine  = highest_high - (price_range * 0.25)
middleLine         = highest_high - (price_range * 0.50)
lowerQuartileLine  = lowest_low   + (price_range * 0.25)
buyersDefenseLine  = lowest_low

// ─── TOUCH TRIGGERS ────────────────────────────────────────────────────────
t_sd = high >= sellersDefenseLine and low <= sellersDefenseLine
t_uq = high >= upperQuartileLine  and low <= upperQuartileLine
t_md = high >= middleLine         and low <= middleLine
t_lq = high >= lowerQuartileLine  and low <= lowerQuartileLine
t_bd = high >= buyersDefenseLine  and low <= buyersDefenseLine

bool is_touch = t_sd or t_uq or t_md or t_lq or t_bd

// ─── INTRABAR FOOTPRINT ────────────────────────────────────────────────────
[ltf_c, ltf_o, ltf_v, ltf_hlc3] = request.security_lower_tf(syminfo.tickerid, ltf_res, [close, open, volume, hlc3])

float bar_delta = 0.0
float poc_price = na
float max_ltf_v = -1.0

if is_touch and array.size(ltf_v) > 0
    for i = 0 to array.size(ltf_v) - 1
        float c = array.get(ltf_c, i)
        float o = array.get(ltf_o, i)
        float v = array.get(ltf_v, i)
        float p = array.get(ltf_hlc3, i)
        bar_delta += (c >= o ? v : -v)
        if v > max_ltf_v
            max_ltf_v := v
            poc_price := p
else if is_touch
    bar_delta := (close >= open ? volume : -volume)
    poc_price := hlc3

// ─── PERCENTILE SIZING ─────────────────────────────────────────────────────
volP50 = ta.percentile_linear_interpolation(volume,   lookbackPeriod, 50)
volP75 = ta.percentile_linear_interpolation(volume,   lookbackPeriod, 75)
volP90 = ta.percentile_linear_interpolation(volume,   lookbackPeriod, 90)
volP97 = ta.percentile_linear_interpolation(volume,   lookbackPeriod, 97)

absDelta = math.abs(bar_delta)
delP50   = ta.percentile_linear_interpolation(absDelta, lookbackPeriod, 50)
delP75   = ta.percentile_linear_interpolation(absDelta, lookbackPeriod, 75)
delP90   = ta.percentile_linear_interpolation(absDelta, lookbackPeriod, 90)

int volCat = volume >= volP97 ? 5 : volume >= volP90 ? 4 : volume >= volP75 ? 3 : volume >= volP50 ? 2 : 1
volCat    := math.max(1, math.min(5, volCat + size_offset))

int delCat = absDelta >= delP90 ? 4 : absDelta >= delP75 ? 3 : absDelta >= delP50 ? 2 : 1
delCat    := math.max(1, math.min(5, delCat + size_offset))
delCat    := math.min(delCat, math.max(1, volCat - 1))

color innerCol = bar_delta > 0 ? bull_bubble_color : bear_bubble_color
bool  canPlot  = show_bubbles and is_touch and not na(poc_price)

// Label text colors — solid, high-contrast, independent of bubble color inputs
// Bubble colors are semi-transparent by design so they layer visually.
// Text must always be fully readable against a dark chart background.
color volTextCol   = color.new(#a2a1a1, 0)   // white — volume is always neutral
color deltaTextCol = bar_delta > 0 ? color.new(#04753e, 0) : color.new(#b20404, 0)

// ─── LEVEL PLOTS ───────────────────────────────────────────────────────────
plot(show_sellers_defense ? sellersDefenseLine : na, "Sellers Defense",      color=sellers_defense_color, linewidth=2, style=plot.style_circles)
plot(show_upper_quartile  ? upperQuartileLine  : na, "Upper Quartile 75%",   color=upper_quartile_color,  linewidth=1)
plot(show_balance_line    ? middleLine         : na, "Structural Pivot 50%", color=pivot_line_color,      linewidth=2)
plot(show_lower_quartile  ? lowerQuartileLine  : na, "Lower Quartile 25%",   color=lower_quartile_color,  linewidth=1)
plot(show_buyers_defense  ? buyersDefenseLine  : na, "Buyers Defense",       color=buyers_defense_color,  linewidth=2, style=plot.style_circles)

// ─── OUTER BUBBLES (VOLUME MASS) ───────────────────────────────────────────
plotshape(show_outer_bub and canPlot and volCat == 1 ? poc_price : na, style=shape.circle, location=location.absolute, size=size.tiny,   color=outer_bub_color, title="Outer Vol Tiny")
plotshape(show_outer_bub and canPlot and volCat == 2 ? poc_price : na, style=shape.circle, location=location.absolute, size=size.small,  color=outer_bub_color, title="Outer Vol Small")
plotshape(show_outer_bub and canPlot and volCat == 3 ? poc_price : na, style=shape.circle, location=location.absolute, size=size.normal, color=outer_bub_color, title="Outer Vol Normal")
plotshape(show_outer_bub and canPlot and volCat == 4 ? poc_price : na, style=shape.circle, location=location.absolute, size=size.large,  color=outer_bub_color, title="Outer Vol Large")
plotshape(show_outer_bub and canPlot and volCat == 5 ? poc_price : na, style=shape.circle, location=location.absolute, size=size.huge,   color=outer_bub_color, title="Outer Vol Huge")

// ─── INNER BUBBLES (DELTA PRESSURE) ────────────────────────────────────────
plotshape(show_inner_bub and canPlot and delCat == 1 ? poc_price : na, style=shape.circle, location=location.absolute, size=size.tiny,   color=innerCol, title="Inner Del Tiny")
plotshape(show_inner_bub and canPlot and delCat == 2 ? poc_price : na, style=shape.circle, location=location.absolute, size=size.small,  color=innerCol, title="Inner Del Small")
plotshape(show_inner_bub and canPlot and delCat == 3 ? poc_price : na, style=shape.circle, location=location.absolute, size=size.normal, color=innerCol, title="Inner Del Normal")
plotshape(show_inner_bub and canPlot and delCat == 4 ? poc_price : na, style=shape.circle, location=location.absolute, size=size.large,  color=innerCol, title="Inner Del Large")
plotshape(show_inner_bub and canPlot and delCat == 5 ? poc_price : na, style=shape.circle, location=location.absolute, size=size.huge,   color=innerCol, title="Inner Del Huge")

// ─── LABELS ────────────────────────────────────────────────────────────────
if canPlot and show_labels
    string lblSz = f_get_lbl_size(i_lblSize)
    label.new(bar_index, poc_price, f_formatNum(volume)    + "\n ", color=color.new(color.white, 100), textcolor=volTextCol,   style=label.style_label_center, size=lblSz)
    label.new(bar_index, poc_price, " \n" + f_formatNum(bar_delta), color=color.new(color.white, 100), textcolor=deltaTextCol, style=label.style_label_center, size=lblSz)
````
