# iFCPO Contract Spec Calculator

- url: https://www.tradingview.com/script/l3BqzfsF-iFCPO-Contract-Spec-Calculator/
- type: indicator
- pine_id: PUB;c9d67505f0c44f558dc832464081a854
- version: 2.0

## Description

iFCPO Contract Spec Calculator — Bursa-spec aware risk calculator for FCPO traders.

Inputs: contract count, SL/TP points.

Outputs (top-right table):
- RM/point (RM 25), lot size (25 MT), tick size, initial margin (RM 5,000)
- Contracts × margin = total margin required
- SL/TP in MYR, R:R ratio
- Rollover-week flag (12-18 of month)

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Contract Spec Calculator — Bursa-spec aware
// Tier: FREE | Category: Utility
// Inputs: contract count, SL/TP points
// Outputs: RM/point, lot size, margin, SL/TP RM, R:R, rollover-week flag
indicator("iFCPO Contract Spec Calculator", "iFCPO Spec", overlay = true)

// ── Inputs ──
contracts  = input.int(1,    "Contracts",         minval = 1, maxval = 100, group = "Position")
sl_points  = input.int(15,   "Stop Loss (pts)",   minval = 1, group = "Risk")
tp_points  = input.int(100,  "Take Profit (pts)", minval = 1, group = "Risk")

// ── FCPO Spec Constants (Bursa Malaysia) ──
RM_PER_POINT    = 25.0    // 1 point = RM25
LOT_SIZE        = 25      // metric tonnes per contract
INITIAL_MARGIN  = 5000.0  // RM per contract (approx)
MAINT_MARGIN    = 4000.0  // RM per contract (approx)
TICK_SIZE       = 1       // smallest price increment

// ── Calculations ──
sl_rm_per_contract = sl_points * RM_PER_POINT
sl_rm_total        = sl_rm_per_contract * contracts
tp_rm_per_contract = tp_points * RM_PER_POINT
tp_rm_total        = tp_rm_per_contract * contracts
margin_total       = INITIAL_MARGIN * contracts
risk_reward        = tp_points / sl_points

// Rollover-week flag: Bursa rolls front-month around the 15th of expiry month.
// QA-2026-05-10: anchored to MYT (Asia/Kuala_Lumpur) so flag is correct on bars near UTC midnight.
TZ = "Asia/Kuala_Lumpur"
is_rollover_week = dayofmonth(time, TZ) >= 12 and dayofmonth(time, TZ) <= 18

// ── Display ──
var table tbl = table.new(position.top_right, 2, 13,
   bgcolor      = color.new(color.black, 25),
   border_width = 1,
   border_color = color.new(color.gray, 70))

if barstate.islast
    txtw = color.white
    txtm = color.new(color.white, 40)
    bull = color.new(#1FC77E, 0)
    bear = color.new(#FF3B5C, 0)
    accent = color.new(#3B82F6, 0)
    gold   = color.new(#E0B544, 0)

    table.cell(tbl, 0, 0,  "iFCPO • Spec Calc", bgcolor = color.new(#3B82F6, 30), text_color = txtw, text_size = size.normal)
    table.merge_cells(tbl, 0, 0, 1, 0)

    table.cell(tbl, 0, 1, "Contract Spec", text_color = txtm, text_size = size.tiny)
    table.cell(tbl, 1, 1, "",              text_size = size.tiny)

    table.cell(tbl, 0, 2, "RM / point",     text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 2, "RM " + str.tostring(RM_PER_POINT, "#"), text_color = bull, text_size = size.tiny)

    table.cell(tbl, 0, 3, "Lot size",       text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 3, str.tostring(LOT_SIZE) + " MT", text_color = txtw, text_size = size.tiny)

    table.cell(tbl, 0, 4, "Tick size",      text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 4, str.tostring(TICK_SIZE) + " pt", text_color = txtw, text_size = size.tiny)

    table.cell(tbl, 0, 5, "Margin (IM)",    text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 5, "RM " + str.tostring(INITIAL_MARGIN, "#,##0"), text_color = txtw, text_size = size.tiny)

    table.cell(tbl, 0, 6, "Position",       text_color = txtm, text_size = size.tiny)
    table.cell(tbl, 1, 6, "",               text_size = size.tiny)

    table.cell(tbl, 0, 7, "Contracts",      text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 7, str.tostring(contracts), text_color = txtw, text_size = size.tiny)

    table.cell(tbl, 0, 8, "Margin req'd",   text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 8, "RM " + str.tostring(margin_total, "#,##0"), text_color = txtw, text_size = size.tiny)

    table.cell(tbl, 0, 9,  "SL " + str.tostring(sl_points) + " pt", text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 9,  "−RM " + str.tostring(sl_rm_total, "#,##0"), text_color = bear, text_size = size.tiny)

    table.cell(tbl, 0, 10, "TP " + str.tostring(tp_points) + " pt", text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 10, "+RM " + str.tostring(tp_rm_total, "#,##0"), text_color = bull, text_size = size.tiny)

    table.cell(tbl, 0, 11, "R : R",         text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 11, "1 : " + str.tostring(risk_reward, "#.##"), text_color = gold, text_size = size.tiny)

    table.cell(tbl, 0, 12, is_rollover_week ? "⚠ ROLLOVER WK" : "Stable contract",
       text_color = is_rollover_week ? color.yellow : color.new(color.white, 50),
       text_size  = size.tiny)
    table.cell(tbl, 1, 12, "",              text_size = size.tiny)
````
