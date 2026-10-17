# Checklist Table for ICT

- url: https://www.tradingview.com/script/E1QmcU78-Checklist-Table-for-ICT/
- type: indicator
- pine_id: PUB;7dbfa231bcef4090bf8cc56ea2592f94
- version: 1.0

## Description

Created a simple checklist for people that Trade ICT

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © williammacrina724
//@version=6
indicator("Checklist Table", overlay=true, max_lines_count=0, max_boxes_count=0)

// Inputs
i_liq  = input.bool(false, "Liquidity Sweep (Must)")
i_ifvg = input.bool(false, "Inverse FVG (Must)")
i_cisd = input.bool(false, "CISD (Must)")
i_htf  = input.bool(false, "HTF PD Array")
i_eq   = input.bool(false, "Equilibrium")
i_fvg  = input.bool(false, "Unfilled 3m+ FVG")
i_nwog = input.bool(false, "NWOG")

var table t = table.new(
     position.bottom_right, 2, 9,
     bgcolor      = color.white,
     border_color = color.black,
     border_width = 1,
     frame_color  = color.black,
     frame_width  = 1)

if barstate.islast
    table.cell(t, 0, 0, "☑",         text_color=color.white, bgcolor=color.gray,  text_size=size.normal, text_halign=text.align_center)
    table.cell(t, 1, 0, "CHECK BOX", text_color=color.white, bgcolor=color.gray,  text_size=size.normal, text_halign=text.align_center)

    table.cell(t, 0, 1, i_liq  ? "☑" : "☐", text_color=i_liq  ? color.green : color.gray, bgcolor=i_liq  ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_center)
    table.cell(t, 1, 1, "Liquidity Sweep (Must)",  text_color=color.black, bgcolor=i_liq  ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_left)

    table.cell(t, 0, 2, i_ifvg ? "☑" : "☐", text_color=i_ifvg ? color.green : color.gray, bgcolor=i_ifvg ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_center)
    table.cell(t, 1, 2, "Inverse FVG (Must)",      text_color=color.black, bgcolor=i_ifvg ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_left)

    table.cell(t, 0, 3, i_cisd ? "☑" : "☐", text_color=i_cisd ? color.green : color.gray, bgcolor=i_cisd ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_center)
    table.cell(t, 1, 3, "CISD (Must)",             text_color=color.black, bgcolor=i_cisd ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_left)

    table.cell(t, 0, 4, i_htf  ? "☑" : "☐", text_color=i_htf  ? color.green : color.gray, bgcolor=i_htf  ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_center)
    table.cell(t, 1, 4, "HTF PD Array",            text_color=color.black, bgcolor=i_htf  ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_left)

    table.cell(t, 0, 5, i_eq   ? "☑" : "☐", text_color=i_eq   ? color.green : color.gray, bgcolor=i_eq   ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_center)
    table.cell(t, 1, 5, "Equilibrium",             text_color=color.black, bgcolor=i_eq   ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_left)

    table.cell(t, 0, 6, i_fvg  ? "☑" : "☐", text_color=i_fvg  ? color.green : color.gray, bgcolor=i_fvg  ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_center)
    table.cell(t, 1, 6, "Unfilled 3m+ FVG",        text_color=color.black, bgcolor=i_fvg  ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_left)

    table.cell(t, 0, 7, i_nwog ? "☑" : "☐", text_color=i_nwog ? color.green : color.gray, bgcolor=i_nwog ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_center)
    table.cell(t, 1, 7, "NWOG",                    text_color=color.black, bgcolor=i_nwog ? color.new(color.green,85) : color.white, text_size=size.normal, text_halign=text.align_left)
//@version=6
````
