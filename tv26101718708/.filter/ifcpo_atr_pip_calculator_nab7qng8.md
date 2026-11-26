# iFCPO ATR Pip Calculator

- url: https://www.tradingview.com/script/nab7qng8-iFCPO-ATR-Pip-Calculator/
- type: indicator
- pine_id: PUB;3c2e59356b9b42a5ac29b9248dced287
- version: 1.0

## Description

iFCPO ATR Pip Calculator — converts ATR to RM-per-contract for FCPO traders.

Computes:
- M5 ATR(14) in points + RM
- D1 ATR(14) in points + RM
- 1R/2R/3R levels (D1 ATR multiples) in points + RM

FCPO contract: 1 point = RM 25, lot = 25 metric tonnes. Useful for sizing SL/TP based on actual volatility (D1 ATR) rather than fixed-point levels.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO ATR Pip Calculator — converts ATR to RM-per-contract for FCPO traders
// Tier: FREE | Category: Volatility / Risk
indicator("iFCPO ATR Pip Calculator", "iFCPO ATR", overlay = true)

atr_period = input.int(14, "ATR period", minval = 1, group = "ATR")
contracts  = input.int(1,  "Contracts",  minval = 1, group = "Position")
risk_mult_1r = input.float(1.0,   "1R multiplier (xATR)", group = "R Levels")
risk_mult_2r = input.float(2.0,   "2R multiplier", group = "R Levels")
risk_mult_3r = input.float(3.0,   "3R multiplier", group = "R Levels")

RM_PER_POINT = 25.0

atr_d1 = request.security(syminfo.tickerid, "D", ta.atr(atr_period), lookahead = barmerge.lookahead_off)
atr_m5 = ta.atr(atr_period)
atr_d1_rm = atr_d1 * RM_PER_POINT * contracts
atr_m5_rm = atr_m5 * RM_PER_POINT * contracts

r1_pts = atr_d1 * risk_mult_1r
r2_pts = atr_d1 * risk_mult_2r
r3_pts = atr_d1 * risk_mult_3r
r1_rm = r1_pts * RM_PER_POINT * contracts
r2_rm = r2_pts * RM_PER_POINT * contracts
r3_rm = r3_pts * RM_PER_POINT * contracts

if barstate.islast
    var table tbl = table.new(position.top_right, 2, 9, bgcolor = color.new(color.black, 25), border_width = 1, border_color = color.new(color.gray, 70))
    table.cell(tbl, 0, 0, "iFCPO ATR Calc", bgcolor = color.new(#3B82F6, 30), text_color = color.white, text_size = size.normal)
    table.merge_cells(tbl, 0, 0, 1, 0)
    table.cell(tbl, 0, 1, "ATR M5", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 1, str.tostring(atr_m5, "#.#") + " pt = RM " + str.tostring(atr_m5_rm, "#,##0"), text_color = color.new(#1FC77E, 0), text_size = size.tiny)
    table.cell(tbl, 0, 2, "ATR D1", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 2, str.tostring(atr_d1, "#.#") + " pt = RM " + str.tostring(atr_d1_rm, "#,##0"), text_color = color.new(#1FC77E, 0), text_size = size.tiny)
    table.cell(tbl, 0, 3, "R Levels (D1)", text_color = color.new(color.white, 40), text_size = size.tiny)
    table.cell(tbl, 1, 3, "", text_size = size.tiny)
    table.cell(tbl, 0, 4, str.tostring(risk_mult_1r, "#.#") + "R = " + str.tostring(r1_pts, "#") + "pt", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 4, "RM " + str.tostring(r1_rm, "#,##0"), text_color = color.new(#E0B544, 0), text_size = size.tiny)
    table.cell(tbl, 0, 5, str.tostring(risk_mult_2r, "#.#") + "R = " + str.tostring(r2_pts, "#") + "pt", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 5, "RM " + str.tostring(r2_rm, "#,##0"), text_color = color.new(#E0B544, 0), text_size = size.tiny)
    table.cell(tbl, 0, 6, str.tostring(risk_mult_3r, "#.#") + "R = " + str.tostring(r3_pts, "#") + "pt", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 6, "RM " + str.tostring(r3_rm, "#,##0"), text_color = color.new(#E0B544, 0), text_size = size.tiny)
    table.cell(tbl, 0, 7, "RM/point", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 7, "RM " + str.tostring(RM_PER_POINT, "#"), text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 0, 8, "Contracts", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 8, str.tostring(contracts), text_color = color.white, text_size = size.tiny)
````
