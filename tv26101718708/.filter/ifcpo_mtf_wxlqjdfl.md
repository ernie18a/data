# iFCPO MTF

- url: https://www.tradingview.com/script/WXLqJdfl-iFCPO-MTF/
- type: indicator
- pine_id: PUB;dd04ed1c90f745c29434685161fc03d4
- version: 2.0

## Description

iFCPO MTF Utility — no-repaint multi-timeframe EMA alignment for FCPO traders.

4 user-configurable HTFs (default: 15m / 1h / 4h / D1) all running EMA(34) on the same source. Each row in the table shows: TF / above-or-below EMA / BULL or BEAR.

Alignment count: 4/4 = STRONG BULL, 0/4 = STRONG BEAR, mixed = MIXED. No-repaint via lookahead_off.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO MTF Utility (W21-O Stack) — research-anchored 4-TF EMA34 alignment for FCPO PM longs
// Tier: FREE | Category: Multi-Timeframe
indicator("iFCPO MTF (W21-O Stack)", "iFCPO MTF", overlay = true)

ema_period = input.int(34, "EMA period (W21 default = 34)", minval = 5, group = "Stack")
slope_lookback_h4 = input.int(5, "H4 slope lookback bars (W21-O = 5 = 20hrs)", minval = 1, group = "Stack")

ema_m5  = ta.ema(close, ema_period)
ema_m15 = request.security(syminfo.tickerid, "15",  ta.ema(close, ema_period), lookahead = barmerge.lookahead_off)
ema_h4  = request.security(syminfo.tickerid, "240", ta.ema(close, ema_period), lookahead = barmerge.lookahead_off)
ema_d1  = request.security(syminfo.tickerid, "D",   ta.ema(close, ema_period), lookahead = barmerge.lookahead_off)

bull_m5  = close > ema_m5
bull_m15 = close > ema_m15
bull_h4  = close > ema_h4
bull_d1  = close > ema_d1

h4_slope_up = ema_h4 > ema_h4[slope_lookback_h4]

count_bull = (bull_m5 ? 1 : 0) + (bull_m15 ? 1 : 0) + (bull_h4 ? 1 : 0) + (bull_d1 ? 1 : 0)
w21o_full = bull_m5 and bull_m15 and bull_h4 and bull_d1 and h4_slope_up

plot(ema_m5,  "EMA M5",  color = color.new(#3B82F6, 60))
plot(ema_m15, "EMA M15", color = color.new(#3B82F6, 30))
plot(ema_h4,  "EMA H4",  color = color.new(#1FC77E, 30))
plot(ema_d1,  "EMA D1",  color = color.new(#FF3B5C, 0), linewidth = 2)

bgcolor(w21o_full ? color.new(#1FC77E, 92) : count_bull == 0 ? color.new(#FF3B5C, 92) : na, title = "W21-O state")

if barstate.islast
    var table tbl = table.new(position.top_right, 3, 7, bgcolor = color.new(color.black, 25), border_width = 1, border_color = color.new(color.gray, 70))
    table.cell(tbl, 0, 0, "iFCPO W21-O Stack", bgcolor = color.new(#3B82F6, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 2, 0)
    table.cell(tbl, 0, 1, "TF",     text_color = color.new(color.white, 40), text_size = size.tiny)
    table.cell(tbl, 1, 1, "Bias",   text_color = color.new(color.white, 40), text_size = size.tiny)
    table.cell(tbl, 2, 1, "vs EMA", text_color = color.new(color.white, 40), text_size = size.tiny)
    table.cell(tbl, 0, 2, "M5",  text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 2, bull_m5  ? "BULL" : "BEAR", text_color = bull_m5  ? #1FC77E : #FF3B5C, text_size = size.tiny)
    table.cell(tbl, 2, 2, bull_m5  ? "above" : "below", text_color = bull_m5  ? #1FC77E : #FF3B5C, text_size = size.tiny)
    table.cell(tbl, 0, 3, "M15", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 3, bull_m15 ? "BULL" : "BEAR", text_color = bull_m15 ? #1FC77E : #FF3B5C, text_size = size.tiny)
    table.cell(tbl, 2, 3, bull_m15 ? "above" : "below", text_color = bull_m15 ? #1FC77E : #FF3B5C, text_size = size.tiny)
    table.cell(tbl, 0, 4, "H4",  text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 4, bull_h4  ? "BULL" : "BEAR", text_color = bull_h4  ? #1FC77E : #FF3B5C, text_size = size.tiny)
    table.cell(tbl, 2, 4, h4_slope_up ? "slope up" : "slope flat/dn", text_color = h4_slope_up ? #1FC77E : #E0B544, text_size = size.tiny)
    table.cell(tbl, 0, 5, "D1",  text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 5, bull_d1  ? "BULL" : "BEAR", text_color = bull_d1  ? #1FC77E : #FF3B5C, text_size = size.tiny)
    table.cell(tbl, 2, 5, bull_d1  ? "above" : "below", text_color = bull_d1  ? #1FC77E : #FF3B5C, text_size = size.tiny)
    overall = w21o_full ? "W21-O LONG OK" : count_bull == 4 ? "Bias bull (no slope)" : count_bull == 0 ? "ALL BEAR" : str.tostring(count_bull) + "/4"
    overall_col = w21o_full ? #1FC77E : count_bull == 0 ? #FF3B5C : #E0B544
    table.cell(tbl, 0, 6, "STACK", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 6, overall,  text_color = overall_col, text_size = size.small)
    table.cell(tbl, 2, 6, "", text_size = size.tiny)

plot(count_bull, "count_bull", display = display.data_window)
plot(w21o_full ? 1 : 0, "w21o_full", display = display.data_window)
plot(h4_slope_up ? 1 : 0, "h4_slope_up", display = display.data_window)
````
