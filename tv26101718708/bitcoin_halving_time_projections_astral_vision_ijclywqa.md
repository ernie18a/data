# Bitcoin Halving Time Projections | Astral Vision 

- url: https://www.tradingview.com/script/ijCLYWQa/
- type: indicator
- pine_id: PUB;b1a9ed22eef94cfb979b7413d2e7a62e
- version: 1.0

## Description

[b]Bitcoin Halving Time Projections | Astral Vision 🌠💠[/b]

Bitcoin's halving events cut the block reward in half approximately every four years, structurally reducing the rate of new supply issuance. 
Across every completed cycle, price has followed a remarkably consistent temporal pattern relative to the halving date: a prolonged accumulation window in the months preceding it, and a distribution window in the months following it before the subsequent cycle peak.

This indicator encodes that pattern as fixed time offsets from each halving date, projecting three vertical markers per cycle (a buy window opening before the halving, the halving itself, and a sell window closing after it) across all historical halvings and forward into the next projected event. 
All five halvings from 2012 through the projected 2028 event are included.

[b]Calculation ⚙️[/b]

`Buy Signal = Halving date − 500 days`

`Sell Signal = Halving date + 535 days`

Both offsets are fixed constants derived from the historical temporal structure of Bitcoin's halving cycles. The halving dates for events 1 through 4 are hardcoded to their actual timestamps; the fifth is projected based on the expected block schedule. All markers are rendered at the last bar and extended across the full chart using time-based coordinates, making them visible at any chart resolution.

[b]Plots 📊[/b]
[list]
[*]Buy Signal vertical line per halving 500 days before the event, rendered with a 3-layer glow (widths 12/6/2, transparencies 85/60/0)
[*]Halving vertical line per event rendered with the same 3-layer glow in a dedicated halving color
[*]Sell Signal vertical line per halving 535 days after the event, same glow rendering
[*]Labels at each marker identifying the event type (Buy Signal, Halving, Sell Signal)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Halving Color`: independent color for the halving date lines (default white)
[*]Buy and sell offsets (500 / 535 days) are fixed constants, not exposed as inputs, to preserve the integrity of the historical cycle structure
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Futura. Positive color applies to buy signal lines; negative color applies to sell signal lines. The halving line has its own independent color input separate from the theme system.

[b]Purpose 🎯[/b]

Most halving indicators mark only the halving date itself, providing no actionable context about when historically the optimal accumulation and distribution windows have opened and closed relative to it. The halving date alone tells you the supply event happened, it does not tell you where you are in the cycle's temporal structure.

This indicator maps the full three-point cycle geometry onto the chart for all five halvings simultaneously, making the historical alignment between time offsets and price behavior directly visible without any manual calculation. The forward projection of the 2028 halving extends the same framework into the current cycle, giving traders a concrete temporal reference for where the buy and sell windows are expected to fall, not as a prediction, but as a historically grounded structural anchor.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision 

//@version=6
indicator("Bitcoin Halving Time Projections | Astral Vision 🌠💠", overlay=true, max_lines_count=500, max_labels_count=100)

group1 = "Settings"
group2 = "Astral Colors"

buy_days  = 500
sell_days = 535
halving_col = input.color(color.rgb(255,255,255), "Halving Color", group=group2)

theme      = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
usecustom  = input.bool(false, "Use Custom Colors", group=group2)
custom_pos = input.color(color.rgb(255,255,255), "Custom Positive (Buy)",  group=group2)
custom_neg = input.color(color.rgb(100,100,100), "Custom Negative (Sell)", group=group2)

raw_pos = theme == "Inferno" ? color.rgb(255,0,0)   : theme == "Paradiso" ? color.rgb(0,210,255)  : theme == "Futura" ? color.rgb(0,255,180)  : theme == "Infinito" ? color.rgb(180,120,255) : color.rgb(255,160,0)
raw_neg = theme == "Inferno" ? color.rgb(120,0,0)   : theme == "Paradiso" ? color.rgb(0,80,160)   : theme == "Futura" ? color.rgb(180,0,255)  : theme == "Infinito" ? color.rgb(255,220,80)  : color.rgb(0,180,120)

col_buy  = usecustom ? custom_pos : raw_pos
col_sell = usecustom ? custom_neg : raw_neg

MS_DAY = 86400000

halving1 = timestamp(2012, 11, 28, 0, 0)
halving2 = timestamp(2016,  7,  9, 0, 0)
halving3 = timestamp(2020,  5, 11, 0, 0)
halving4 = timestamp(2024,  4, 19, 0, 0)
halving5 = timestamp(2028,  4, 18, 0, 0)

halvings = array.from(halving1, halving2, halving3, halving4, halving5)

drawBeam(int t, color col) =>
    line.new(t, close, t, close * 1.001, xloc=xloc.bar_time, extend=extend.both, color=color.new(col, 85), width=12)
    line.new(t, close, t, close * 1.001, xloc=xloc.bar_time, extend=extend.both, color=color.new(col, 60), width=6)
    line.new(t, close, t, close * 1.001, xloc=xloc.bar_time, extend=extend.both, color=color.new(col,  0), width=2)

drawLabel(int t, string txt, color col, bool isAbove) =>
    label.new(t, close, txt,
         xloc      = xloc.bar_time,
         yloc      = isAbove ? yloc.belowbar : yloc.abovebar,
         style     = isAbove ? label.style_label_up : label.style_label_down,
         color     = color.new(col, 60),
         textcolor = color.white,
         size      = size.small)

if barstate.islast
    for i = 0 to array.size(halvings) - 1
        h      = array.get(halvings, i)
        buy_t  = h - buy_days  * MS_DAY
        sell_t = h + sell_days * MS_DAY

        drawBeam(buy_t,  col_buy)
        drawBeam(h,      halving_col)
        drawBeam(sell_t, col_sell)

        drawLabel(buy_t,  "Buy Signal", col_buy,     true)
        drawLabel(h,      "Halving",    halving_col, true)
        drawLabel(sell_t, "Sell Signal",col_sell,   false)
````
