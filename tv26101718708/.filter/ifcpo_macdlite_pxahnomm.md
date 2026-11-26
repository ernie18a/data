# iFCPO MACD-Lite

- url: https://www.tradingview.com/script/pXahNOMm-iFCPO-MACD-Lite/
- type: indicator
- pine_id: PUB;a633880c8af74270b14aceb949af420c
- version: 1.0

## Description

iFCPO MACD-Lite — Higher-timeframe MACD bias for FCPO traders.

MACD(12,26,9) computed locally then security-pulled from D1 or W1 (user choice). Outputs BULL/BEAR/Neutral bias label.

Research context: W40 backtests confirmed MACD is too slow for FCPO PM entries. This indicator is intentionally limited to D1/W1 BIAS ONLY — use as a higher-timeframe filter for entries from faster signals (BB engine, EMA pullback).

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO MACD-Lite — D1/W1 bias only (W40 research: too slow for FCPO PM entries)
// Tier: FREE | Category: Momentum / Educational
indicator("iFCPO MACD-Lite", "iFCPO MACD", overlay = false)

fast_len = input.int(12, "Fast",   minval = 1, group = "MACD")
slow_len = input.int(26, "Slow",   minval = 1, group = "MACD")
sig_len  = input.int(9,  "Signal", minval = 1, group = "MACD")
htf      = input.string("D", "Higher TF for bias", options = ["D", "W"], group = "TF")

[m_local, s_local, h_local] = ta.macd(close, fast_len, slow_len, sig_len)
macd_v = request.security(syminfo.tickerid, htf, m_local, lookahead = barmerge.lookahead_off)
sig_v  = request.security(syminfo.tickerid, htf, s_local, lookahead = barmerge.lookahead_off)
hist_v = request.security(syminfo.tickerid, htf, h_local, lookahead = barmerge.lookahead_off)

bias_bull = macd_v > sig_v and hist_v > 0
bias_bear = macd_v < sig_v and hist_v < 0

plot(macd_v, "MACD",   color = color.new(#3B82F6, 0), linewidth = 1)
plot(sig_v,  "Signal", color = color.new(#E0B544, 0), linewidth = 1)
plot(hist_v, "Hist",
   color = hist_v >= 0 ? color.new(#1FC77E, 30) : color.new(#FF3B5C, 30),
   style = plot.style_columns)

if barstate.islast
    var table tbl = table.new(position.top_right, 2, 2, bgcolor = color.new(color.black, 25), border_width = 1, border_color = color.new(color.gray, 70))
    table.cell(tbl, 0, 0, "iFCPO MACD-Lite (" + htf + " bias only)", bgcolor = color.new(#3B82F6, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 1, 0)
    bias_lbl = bias_bull ? "BULL bias" : bias_bear ? "BEAR bias" : "Neutral"
    bias_col = bias_bull ? #1FC77E : bias_bear ? #FF3B5C : #6B7280
    table.cell(tbl, 0, 1, "Bias", text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 1, bias_lbl, text_color = bias_col, text_size = size.small)
````
