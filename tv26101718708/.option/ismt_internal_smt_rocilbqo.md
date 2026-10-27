# ISMT Internal SMT

- url: https://www.tradingview.com/script/rociLbqO-ISMT-Internal-SMT/
- type: indicator
- pine_id: PUB;172c5bb95c6f45c4be4ea6084f86bc5a
- version: 1.0

## Description

Internal SMT (Smart Money Technique) divergence occurs when two positively correlated assets (e.g., ES and NQ) move in opposite directions specifically when pulling back into an internal Point of Interest (POI), like a Fair Value Gap (FVG) or order block, rather than at the major external highs/lows.

## Source Code

````pine
//@version=6
indicator(title="ISMT – Internal SMT", shorttitle="ISMT", overlay=true, max_lines_count=500)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
grp_sym  = "Symbols"
sym_a    = input.symbol("NAS100USD", "Symbol A – Basis (NQ)",        group=grp_sym)
sym_b    = input.symbol("SP500USD",  "Symbol B – Vergleich 1 (ES)",  group=grp_sym)
sym_c    = input.symbol("US30USD",   "Symbol C – Vergleich 2 (YM)",  group=grp_sym)

grp_div  = "Divergence Lines"
show_div = input.bool(true, "Show Divergence Lines", group=grp_div)
bull_col = input.color(color.lime, "Bullish Line Color", group=grp_div)
bear_col = input.color(color.red,  "Bearish Line Color", group=grp_div)
div_wid  = input.int(2, "Line Width", minval=1, maxval=4, group=grp_div)

// ─────────────────────────────────────────────
//  DATA FETCH
// ─────────────────────────────────────────────
[ha, la, ca] = request.security(sym_a, timeframe.period, [high, low, close])
[hb, lb, cb] = request.security(sym_b, timeframe.period, [high, low, close])
[hc, lc, cc] = request.security(sym_c, timeframe.period, [high, low, close])

// ─────────────────────────────────────────────
//  ISMT LOGIC  (NQ = Symbol A als Basis)
//  Bullish SMT  = Chart macht LOWER LOW,  Symbol A macht HIGHER LOW
//  Bearish SMT  = Chart macht HIGHER HIGH, Symbol A macht LOWER HIGH
// ─────────────────────────────────────────────
bull_b = (low < low[1]) and (lb > lb[1])
bear_b = (high > high[1]) and (hb < hb[1])

bull_c = (low < low[1]) and (lc > lc[1])
bear_c = (high > high[1]) and (hc < hc[1])

bull_smt = bull_b or bull_c
bear_smt = bear_b or bear_c

// ─────────────────────────────────────────────
//  DIVERGENCE LINES  (vorheriger Bar → aktueller Bar)
// ─────────────────────────────────────────────
if show_div
    if bull_smt
        line.new(bar_index - 1, low[1], bar_index, low, color=bull_col, width=div_wid, style=line.style_solid)
    if bear_smt
        line.new(bar_index - 1, high[1], bar_index, high, color=bear_col, width=div_wid, style=line.style_solid)

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────
alertcondition(bull_smt, "ISMT – Bullish Divergence", "Internal SMT: Bullish divergence detected")
alertcondition(bear_smt, "ISMT – Bearish Divergence", "Internal SMT: Bearish divergence detected")
````
