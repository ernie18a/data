# Arbitrary Price-Percent Pivot Zones

- url: https://www.tradingview.com/script/0eLlXtFt-Arbitrary-Price-Percent-Pivot-Zones/
- type: indicator
- pine_id: PUB;1bce64c902c644e5964f1d654f3213b8
- version: 2.0

## Description

Arbitrary Price-Percent Pivot Zones. Random percentage of candle open price.

## Source Code

````pine
//@version=6
indicator("Arbitrary Price-Percent Pivot Zones", overlay = true, max_boxes_count = 100)

// --- Settings ---
group_math = "Mathematical Ratios (% of Open Price)"
z1_off_pct = input.float(0.3402, "Inner Offset %", step = 0.001, group = group_math, tooltip = "Distance from Open to Inner Box center.")
z1_h_pct   = input.float(0.0969, "Inner Height %", step = 0.001, group = group_math, tooltip = "Thickness of Inner Box.")
z2_off_pct = input.float(1.0758, "Outer Offset %", step = 0.001, group = group_math, tooltip = "Distance from Open to Outer Box center.")
z2_h_pct   = input.float(0.2108, "Outer Height %", step = 0.001, group = group_math, tooltip = "Thickness of Outer Box.")

group_style = "Style Settings"
bullColor   = input.color(color.new(#089981, 85), "Upper Zones Color", group = group_style)
bearColor   = input.color(color.new(#f23645, 85), "Lower Zones Color", group = group_style)
borderCol   = input.color(color.new(color.gray, 70), "Border Color", group = group_style)
showOpen    = input.bool(true, "Show Daily Open Line", group = group_style)

// --- Data ---
// Fetch Today's Open (The Anchor)
dOpen = request.security(syminfo.tickerid, "D", open, lookahead = barmerge.lookahead_on)

isNewDay = ta.change(time("D")) != 0

// --- Logic ---
var box b1_up = na, var box b2_up = na
var box b1_dn = na, var box b2_dn = na
var line l_open = na

if isNewDay and not na(dOpen)
    // Convert ratios to price units based on the Open
    float off1 = dOpen * (z1_off_pct / 100)
    float off2 = dOpen * (z2_off_pct / 100)
    float h1   = dOpen * (z1_h_pct / 100)
    float h2   = dOpen * (z2_h_pct / 100)

    // Draw Zones
    // Inner Upper & Lower (Straddle Open)
    b1_up := box.new(bar_index, dOpen + off1 + (h1/2), bar_index, dOpen + off1 - (h1/2), bgcolor = bullColor, border_color = borderCol)
    b1_dn := box.new(bar_index, dOpen - off1 + (h1/2), bar_index, dOpen - off1 - (h1/2), bgcolor = bearColor, border_color = borderCol)
    
    // Outer Upper & Lower (Straddle Open)
    b2_up := box.new(bar_index, dOpen + off2 + (h2/2), bar_index, dOpen + off2 - (h2/2), bgcolor = bullColor, border_color = borderCol)
    b2_dn := box.new(bar_index, dOpen - off2 + (h2/2), bar_index, dOpen - off2 - (h2/2), bgcolor = bearColor, border_color = borderCol)

    if showOpen
        l_open := line.new(bar_index, dOpen, bar_index, dOpen, color = color.new(color.gray, 50), style = line.style_dotted)

// Extension
if not na(b1_up)
    box.set_right(b1_up, bar_index), box.set_right(b2_up, bar_index)
    box.set_right(b1_dn, bar_index), box.set_right(b2_dn, bar_index)
    if not na(l_open)
        line.set_x2(l_open, bar_index)

plot(showOpen ? dOpen : na, "Daily Open", color.new(color.gray, 80), 1, plot.style_linebr)
````
