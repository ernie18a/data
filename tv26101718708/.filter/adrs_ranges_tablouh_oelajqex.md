# ADRs Ranges (Tablouh)

- url: https://www.tradingview.com/script/OElAJQex-ADRs-Ranges-Tablouh/
- type: indicator
- pine_id: PUB;2747c1c168a64bac9d7ca0dac5860305
- version: 1.0

## Description

This table is a Range Tracker that measures the distance between Highs and Lows.

LW / CW: Compares Last Week vs. This Week to see if the weekly trend is expanding.

LD / CD: Compares Yesterday vs. Today to see if the daily move is finished or just starting.

CCR (P): Shows the size of the Previous Candle to gauge immediate momentum.

In short: it tells you if the market is moving more or less than usual so you don't trade into "exhausted" moves.

## Source Code

````pine
//@version=5
indicator("Compact Range DB", overlay=true)

// --- POSITION & SIZE INPUTS ---
pos_opt = input.string("TR", "Table Position", options=["TR", "TL", "BR", "BL"], group="Placement")
txt_sz  = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group="Placement")

// --- COLOR INPUTS ---
bg_col   = input.color(#1e222d, "Background Color", group="Colors")
brd_col  = input.color(color.gray, "Border Color", group="Colors")
lw_col   = input.color(color.gray, "LW Color", group="Colors")
cw_col   = input.color(color.orange, "CW Color", group="Colors")
ld_col   = input.color(color.white, "LD Color", group="Colors")
cd_col   = input.color(color.yellow, "CD Color", group="Colors")
ccr_col  = input.color(color.aqua, "CCR Color", group="Colors")

// --- Logic ---
// 1. Last Week Range
[lw_h, lw_l] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

// 2. Current Week Data
var float w_h = na
var float w_l = na
if ta.change(time("W"))
    w_h := high
    w_l := low
else
    w_h := math.max(high, nz(w_h, high))
    w_l := math.min(low, nz(w_l, low))

// 3. Current Day & Yesterday Data
[d_h, d_l, y_h, y_l] = request.security(syminfo.tickerid, "D", [high, low, high[1], low[1]], lookahead=barmerge.lookahead_on)

// Metrics
LW_VAL  = lw_h - lw_l
CW_VAL  = w_h - w_l
LD_VAL  = y_h - y_l
CD_VAL  = d_h - d_l
PREV_CR = high[1] - low[1]

// --- UI ---
pos  = pos_opt == "TR" ? position.top_right : pos_opt == "TL" ? position.top_left : pos_opt == "BR" ? position.bottom_right : position.bottom_left
size = txt_sz == "Tiny" ? size.tiny : txt_sz == "Small" ? size.small : size.normal

var table db = table.new(pos, 2, 5, bgcolor=bg_col, border_width=1, border_color=brd_col)

if barstate.islast
    // Labels updated to remove "ADR"
    table.cell(db, 0, 0, "LW", text_color=lw_col, text_size=size)
    table.cell(db, 1, 0, str.tostring(LW_VAL, format.mintick), text_color=lw_col, text_size=size)
    
    table.cell(db, 0, 1, "CW", text_color=cw_col, text_size=size)
    table.cell(db, 1, 1, str.tostring(CW_VAL, format.mintick), text_color=cw_col, text_size=size)
    
    table.cell(db, 0, 2, "LD", text_color=ld_col, text_size=size)
    table.cell(db, 1, 2, str.tostring(LD_VAL, format.mintick), text_color=ld_col, text_size=size)
    
    table.cell(db, 0, 3, "CD", text_color=cd_col, text_size=size)
    table.cell(db, 1, 3, str.tostring(CD_VAL, format.mintick), text_color=cd_col, text_size=size)
    
    table.cell(db, 0, 4, "CCR(P)", text_color=ccr_col, text_size=size)
    table.cell(db, 1, 4, str.tostring(PREV_CR, format.mintick), text_color=ccr_col, text_size=size)
````
