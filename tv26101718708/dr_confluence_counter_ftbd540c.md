# DR Confluence Counter 

- url: https://www.tradingview.com/script/FTBd540C-DR-Confluence-Counter/
- type: indicator
- pine_id: PUB;e354b7d8a29d497fb981bcefa8ae1c87
- version: 2.0

## Description

This is a counter to help DR traders count or keep in sight the weight of the trades.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator("Confluence Counter", overlay=true)

// ─────────────────────────────────────────────
//  SETTINGS
// ─────────────────────────────────────────────
grp_d = "Direction"
grp_c = "Confluences"
grp_s = "Style"

dir = input.string("Long", "Direction", options=["Long", "Short"], group=grp_d)

c01_on = input.bool(false, "", inline="01", group=grp_c)
c01_nm = input.string("EMA crossover",   "→ Name", inline="01", group=grp_c)
c02_on = input.bool(false, "", inline="02", group=grp_c)
c02_nm = input.string("Key S/R level",   "→ Name", inline="02", group=grp_c)
c03_on = input.bool(false, "", inline="03", group=grp_c)
c03_nm = input.string("Higher TF trend", "→ Name", inline="03", group=grp_c)
c04_on = input.bool(false, "", inline="04", group=grp_c)
c04_nm = input.string("RSI divergence",  "→ Name", inline="04", group=grp_c)
c05_on = input.bool(false, "", inline="05", group=grp_c)
c05_nm = input.string("Volume spike",    "→ Name", inline="05", group=grp_c)
c06_on = input.bool(false, "", inline="06", group=grp_c)
c06_nm = input.string("Liquidity sweep", "→ Name", inline="06", group=grp_c)
c07_on = input.bool(false, "", inline="07", group=grp_c)
c07_nm = input.string("Breaker block",   "→ Name", inline="07", group=grp_c)
c08_on = input.bool(false, "", inline="08", group=grp_c)
c08_nm = input.string("FVG aligned",     "→ Name", inline="08", group=grp_c)
c09_on = input.bool(false, "", inline="09", group=grp_c)
c09_nm = input.string("Session open",    "→ Name", inline="09", group=grp_c)
c10_on = input.bool(false, "", inline="10", group=grp_c)
c10_nm = input.string("News catalyst",   "→ Name", inline="10", group=grp_c)
c11_on = input.bool(false, "", inline="11", group=grp_c)
c11_nm = input.string("Confluence 11",   "→ Name", inline="11", group=grp_c)
c12_on = input.bool(false, "", inline="12", group=grp_c)
c12_nm = input.string("Confluence 12",   "→ Name", inline="12", group=grp_c)
c13_on = input.bool(false, "", inline="13", group=grp_c)
c13_nm = input.string("Confluence 13",   "→ Name", inline="13", group=grp_c)
c14_on = input.bool(false, "", inline="14", group=grp_c)
c14_nm = input.string("Confluence 14",   "→ Name", inline="14", group=grp_c)
c15_on = input.bool(false, "", inline="15", group=grp_c)
c15_nm = input.string("Confluence 15",   "→ Name", inline="15", group=grp_c)
c16_on = input.bool(false, "", inline="16", group=grp_c)
c16_nm = input.string("Confluence 16",   "→ Name", inline="16", group=grp_c)
c17_on = input.bool(false, "", inline="17", group=grp_c)
c17_nm = input.string("Confluence 17",   "→ Name", inline="17", group=grp_c)
c18_on = input.bool(false, "", inline="18", group=grp_c)
c18_nm = input.string("Confluence 18",   "→ Name", inline="18", group=grp_c)


tbl_pos  = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grp_s)
txt_size = input.string("Normal", "Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=grp_s)

// ─────────────────────────────────────────────
//  TEXT SIZE
// ─────────────────────────────────────────────
sz = txt_size == "Tiny" ? size.tiny : txt_size == "Small" ? size.small : txt_size == "Normal" ? size.normal : txt_size == "Large" ? size.large : size.huge

// ─────────────────────────────────────────────
//  COUNT + STRENGTH
// ─────────────────────────────────────────────
total = (c01_on?1:0) + (c02_on?1:0) + (c03_on?1:0) + (c04_on?1:0) + (c05_on?1:0) + (c06_on?1:0) + (c07_on?1:0) + (c08_on?1:0) + (c09_on?1:0) + (c10_on?1:0) + (c11_on?1:0) + (c12_on?1:0) + (c13_on?1:0) + (c14_on?1:0) + (c15_on?1:0) + (c16_on?1:0) + (c17_on?1:0) + (c18_on?1:0)

str_text = total == 0 ? "—" : total <= 4 ? "WEAK" : total <= 8 ? "MODERATE" : total <= 13 ? "STRONG" : "CONFLUENT"

str_col = total == 0 ? color.new(color.gray, 40) : total <= 4 ? color.new(#888780, 0) : total <= 8 ? color.new(#BA7517, 0) : total <= 13 ? color.new(#639922, 0) : color.new(#1D9E75, 0)

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
C_BG      = color.new(#0d0d0d, 5)
C_BG2     = color.new(#111111, 0)
C_BG3     = color.new(#0a0a0a, 0)
C_ROW_ON  = color.new(#0f2a10, 0)
C_ROW_OFF = color.new(#0d0d0d, 0)
C_WHITE   = color.white
C_MUTED   = color.new(color.white, 55)
C_FAINT   = color.new(color.white, 75)
C_TICK_ON  = color.new(#6ab04c, 0)
C_TICK_OFF = color.new(color.white, 65)
C_TEXT_ON  = color.new(#a8d8a8, 0)
C_TEXT_OFF = color.new(color.white, 45)
C_BORDER  = color.new(color.white, 82)
C_FRAME   = color.new(color.white, 72)

dir_bg  = dir == "Long" ? color.new(#0f2a10, 0) : color.new(#2a0f0f, 0)
dir_col = dir == "Long" ? color.new(#6ab04c, 0) : color.new(#e05a4e, 0)

pos = tbl_pos == "Top Right" ? position.top_right : tbl_pos == "Top Left" ? position.top_left : tbl_pos == "Bottom Right" ? position.bottom_right : position.bottom_left

// ─────────────────────────────────────────────
//  TABLE  (2 cols x 23 rows)
//  row 0  : title
//  row 1  : direction
//  row 2  : count
//  row 3  : signal strength
//  row 4  : section divider
//  rows 5-22 : confluences 1-18
// ─────────────────────────────────────────────
var table t = table.new(pos, 2, 23, bgcolor=C_BG, border_color=C_BORDER, border_width=1, frame_color=C_FRAME, frame_width=1)

if barstate.islast

    // row 0 - title
    table.cell(t, 0, 0, "CONFLUENCE COUNTER", text_color=C_MUTED, text_size=sz, bgcolor=C_BG3, text_halign=text.align_center)
    table.merge_cells(t, 0, 0, 1, 0)

    // row 1 - direction
    table.cell(t, 0, 1, "DIR", text_color=C_FAINT, text_size=sz, bgcolor=C_BG2)
    table.cell(t, 1, 1, dir, text_color=dir_col, text_size=sz, bgcolor=dir_bg, text_halign=text.align_center)

    // row 2 - count
    table.cell(t, 0, 2, "COUNT", text_color=C_FAINT, text_size=sz, bgcolor=C_BG2)
    table.cell(t, 1, 2, str.tostring(total) + " / 18", text_color=C_WHITE, text_size=sz, bgcolor=C_BG2, text_halign=text.align_center)

    // row 3 - signal strength
    table.cell(t, 0, 3, "SIGNAL", text_color=C_FAINT, text_size=sz, bgcolor=C_BG2)
    table.cell(t, 1, 3, str_text, text_color=str_col, text_size=sz, bgcolor=C_BG2, text_halign=text.align_center)

    // row 4 - divider
    table.cell(t, 0, 4, "--- CHECKLIST ---", text_color=C_FAINT, text_size=sz, bgcolor=C_BG3, text_halign=text.align_center)
    table.merge_cells(t, 0, 4, 1, 4)

    // rows 5-22 - confluence items
    _names = array.from(c01_nm, c02_nm, c03_nm, c04_nm, c05_nm, c06_nm, c07_nm, c08_nm, c09_nm, c10_nm, c11_nm, c12_nm, c13_nm, c14_nm, c15_nm, c16_nm, c17_nm, c18_nm)
    _flags = array.from(c01_on, c02_on, c03_on, c04_on, c05_on, c06_on, c07_on, c08_on, c09_on, c10_on, c11_on, c12_on, c13_on, c14_on, c15_on, c16_on, c17_on, c18_on)

    for i = 0 to 17
        row = i + 5
        on  = array.get(_flags, i)
        nm  = array.get(_names, i)
        table.cell(t, 0, row, on ? "✓" : "○", text_color=on ? C_TICK_ON : C_TICK_OFF, text_size=sz, bgcolor=on ? C_ROW_ON : C_ROW_OFF, text_halign=text.align_center)
        table.cell(t, 1, row, nm, text_color=on ? C_TEXT_ON : C_TEXT_OFF, text_size=sz, bgcolor=on ? C_ROW_ON : C_ROW_OFF, text_halign=text.align_left)
````
