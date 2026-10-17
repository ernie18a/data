# iFCPO Long-Cycle

- url: https://www.tradingview.com/script/rOXD2ouT-iFCPO-Long-Cycle/
- type: indicator
- pine_id: PUB;7bfc51f665994c7299938448841837b4
- version: 2.0

## Description

iFCPO Long-Cycle Oscillator Pack — slow-cycle bias indicators for FCPO traders.

Packages two long-cycle oscillators:
- Coppock Curve: WMA(14ROC + 11ROC, 10) — long-term momentum
- Ultimate Oscillator: weighted 7/14/28 stochastic — divergence detection

Intentionally BIAS-ONLY — these long-cycle oscillators are too slow for FCPO PM M5 entries (W40 research). Use them as higher-timeframe filters, not entry triggers.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Long-Cycle Oscillator Pack — D1/W1 bias for FCPO swing positioning
// Tier: FREE | Category: Oscillator
indicator("iFCPO Long-Cycle", "iFCPO Long", overlay = false)

show_coppock = input.bool(true, "Coppock", group = "Show")
show_ultimate = input.bool(true, "Ultimate (UO)", group = "Show")
show_mpob_marker = input.bool(true, "Mark MPOB release window (10th of month +/-2 days)", group = "MPOB")
mpob_window = input.int(2, "MPOB +/- days", minval = 0, maxval = 5, group = "MPOB")

roc14 = ta.roc(close, 14)
roc11 = ta.roc(close, 11)
coppock = ta.wma(roc14 + roc11, 10)
coppock_turn_up = ta.crossover(coppock, 0)

bp = close - math.min(low, close[1])
tr_v = math.max(high, close[1]) - math.min(low, close[1])
avg7  = ta.sma(bp, 7)  / ta.sma(tr_v, 7)
avg14 = ta.sma(bp, 14) / ta.sma(tr_v, 14)
avg28 = ta.sma(bp, 28) / ta.sma(tr_v, 28)
uo = 100 * (4 * avg7 + 2 * avg14 + avg28) / 7

TZ = "Asia/Kuala_Lumpur"
near_mpob = math.abs(dayofmonth(time, TZ) - 10) <= mpob_window

plot(show_coppock ? coppock : na, "Coppock", color = color.new(#3B82F6, 0), linewidth = 1)
hline(0, "Coppock zero", color = color.new(color.gray, 50), linestyle = hline.style_dotted)
plotshape(show_coppock and coppock_turn_up, "Coppock turn-up", style = shape.triangleup, location = location.bottom, color = color.new(#1FC77E, 0), size = size.small, text = "C+")

plot(show_ultimate ? uo - 50 : na, "Ultimate (50-centered)", color = color.new(#E0B544, 0), linewidth = 1)
hline( 20, "UO OB",  color = color.new(#FF3B5C, 60), linestyle = hline.style_dashed)
hline(-20, "UO OS",  color = color.new(#1FC77E, 60), linestyle = hline.style_dashed)

bgcolor(show_mpob_marker and near_mpob ? color.new(#E0B544, 90) : na, title = "MPOB window")

if barstate.islast
    var table tbl = table.new(position.top_right, 2, 5, bgcolor = color.new(color.black, 25), border_width = 1, border_color = color.new(color.gray, 70))
    table.cell(tbl, 0, 0, "iFCPO Long-Cycle", bgcolor = color.new(#3B82F6, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 1, 0)
    cop_lbl = coppock > 0 ? "BULL bias" : "BEAR bias"
    cop_col = coppock > 0 ? #1FC77E : #FF3B5C
    table.cell(tbl, 0, 1, "Coppock", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 1, cop_lbl + " " + str.tostring(coppock, "#.#"), text_color = cop_col, text_size = size.tiny)
    uo_lbl = uo > 70 ? "OB" : uo < 30 ? "OS" : "Neutral"
    uo_col = uo > 70 ? #FF3B5C : uo < 30 ? #1FC77E : #6B7280
    table.cell(tbl, 0, 2, "Ultimate", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 2, uo_lbl + " " + str.tostring(uo, "#"), text_color = uo_col, text_size = size.tiny)
    table.cell(tbl, 0, 3, "MPOB window", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 3, near_mpob ? "ACTIVE" : "off", text_color = near_mpob ? #E0B544 : color.gray, text_size = size.tiny)
    pair_signal = coppock > 0 and uo < 30 and near_mpob
    table.cell(tbl, 0, 4, "Setup", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 4, pair_signal ? "BULL bias + UO OS @ MPOB" : "Watch", text_color = pair_signal ? #1FC77E : color.gray, text_size = size.tiny)

plot(coppock, "coppock", display = display.data_window)
plot(uo,      "ultimate", display = display.data_window)
plot(coppock_turn_up ? 1 : 0, "coppock_turn_up", display = display.data_window)
plot(near_mpob ? 1 : 0, "near_mpob", display = display.data_window)
````
