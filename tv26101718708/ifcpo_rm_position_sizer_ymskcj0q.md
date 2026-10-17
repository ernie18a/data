# iFCPO RM Position Sizer

- url: https://www.tradingview.com/script/YMskCJ0Q-iFCPO-RM-Position-Sizer/
- type: indicator
- pine_id: PUB;4e2a87e8ce21458d825e06030481089a
- version: 1.0

## Description

iFCPO RM Position Sizer — interactive risk calculator in MYR for FCPO traders.

Inputs: account balance (RM), risk % per trade, SL/TP points, max margin %.

Outputs (top-right table):
- Recommended contracts (capped by risk OR margin, whichever is tighter)
- RM at risk + reward in MYR
- Margin used + cap reason

FCPO constants: RM 25 per point, RM 5,000 initial margin per lot.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO RM Position Sizer — interactive risk calculator in MYR
// Tier: FREE | Category: Risk Management
indicator("iFCPO RM Position Sizer", "iFCPO Sizr", overlay = true)

account_rm   = input.float(50000.0, "Account Balance (RM)", minval = 1000, group  = "Account")
risk_pct     = input.float(1.0,     "Risk % per Trade",     minval = 0.1,  maxval = 10.0, step = 0.1, group = "Account")
sl_points    = input.int(15,        "Stop Loss (pts)",       minval = 1,   group  = "Risk")
tp_points    = input.int(100,       "Take Profit (pts)",     minval = 1,   group  = "Risk")
max_pos_pct  = input.float(50.0,    "Max % Margin Use",      minval = 1,   maxval = 100, group = "Caps")

RM_PER_POINT   = 25.0
INITIAL_MARGIN = 5000.0

risk_amount        = account_rm * (risk_pct / 100.0)
sl_loss_per_lot    = sl_points * RM_PER_POINT
contracts_by_risk  = sl_loss_per_lot > 0 ? math.floor(risk_amount / sl_loss_per_lot) : 0
contracts_by_margin = math.floor((account_rm * max_pos_pct / 100.0) / INITIAL_MARGIN)
recommended        = math.min(contracts_by_risk, contracts_by_margin)
recommended       := math.max(0, recommended)

actual_risk_rm    = recommended * sl_loss_per_lot
actual_reward_rm  = recommended * tp_points * RM_PER_POINT
margin_used       = recommended * INITIAL_MARGIN
margin_pct        = account_rm > 0 ? (margin_used / account_rm) * 100 : 0.0
risk_to_acct_pct  = account_rm > 0 ? (actual_risk_rm / account_rm) * 100 : 0.0

var table tbl = table.new(position.top_right, 2, 12,
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

    table.cell(tbl, 0, 0,  "iFCPO Position Sizer", bgcolor = color.new(#3B82F6, 30), text_color = txtw, text_size = size.normal)
    table.merge_cells(tbl, 0, 0, 1, 0)

    table.cell(tbl, 0, 1, "Account",      text_color = txtm, text_size = size.tiny)
    table.cell(tbl, 1, 1, "",             text_size = size.tiny)
    table.cell(tbl, 0, 2, "Balance",      text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 2, "RM " + str.tostring(account_rm, "#,##0"), text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 0, 3, "Risk per trade", text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 3, str.tostring(risk_pct, "#.#") + "% (RM " + str.tostring(risk_amount, "#,##0") + ")", text_color = gold, text_size = size.tiny)

    table.cell(tbl, 0, 4, "Recommended", text_color = txtm, text_size = size.tiny)
    table.cell(tbl, 1, 4, "",            text_size = size.tiny)
    table.cell(tbl, 0, 5, "Contracts",   text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 5, str.tostring(recommended), text_color = accent, text_size = size.normal)

    table.cell(tbl, 0, 6, "Risk @ SL=" + str.tostring(sl_points), text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 6, "-RM " + str.tostring(actual_risk_rm, "#,##0") + " (" + str.tostring(risk_to_acct_pct, "#.##") + "%)", text_color = bear, text_size = size.tiny)
    table.cell(tbl, 0, 7, "Reward @ TP=" + str.tostring(tp_points), text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 7, "+RM " + str.tostring(actual_reward_rm, "#,##0"), text_color = bull, text_size = size.tiny)

    table.cell(tbl, 0, 8, "Margin used", text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 8, "RM " + str.tostring(margin_used, "#,##0") + " (" + str.tostring(margin_pct, "#.#") + "%)", text_color = txtw, text_size = size.tiny)

    cap_reason = contracts_by_risk <= contracts_by_margin ? "by risk %" : "by margin cap"
    table.cell(tbl, 0, 9,  "Cap reason", text_color = txtw, text_size = size.tiny)
    table.cell(tbl, 1, 9,  cap_reason,   text_color = gold, text_size = size.tiny)

    table.cell(tbl, 0, 10, "By risk %",  text_color = txtm, text_size = size.tiny)
    table.cell(tbl, 1, 10, str.tostring(contracts_by_risk),   text_color = txtm, text_size = size.tiny)
    table.cell(tbl, 0, 11, "By margin cap", text_color = txtm, text_size = size.tiny)
    table.cell(tbl, 1, 11, str.tostring(contracts_by_margin), text_color = txtm, text_size = size.tiny)
````
