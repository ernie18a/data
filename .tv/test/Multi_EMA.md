<!-- tradingview-pine-id: PUB;8984c8886d884826ae8a56b541a6d0d6 -->
<!-- tradingviewscripts-format: 1 -->
# Multi EMA

Source: https://www.tradingview.com/script/XZjIdMm9-Multi-EMA/

## Description

Up to 5 Configurable EMAs on One Chart

One indicator that replaces multiple single-EMA instances. Add up to 5 independent EMAs, each with its own:

[*]Length
[*]Timeframe (leave blank for chart timeframe, or set a higher/lower one — e.g. 5m, 15m, 1h)
[*]Source
[*]Color & line width
[*]On/off toggle

Built for traders who track EMA confluence across multiple timeframes (e.g. execution + intermediate + higher-timeframe trend) without cluttering the chart with repeated copies of the same indicator.

Higher-timeframe EMAs are calculated with request.security() using non-repainting settings (lookahead_off), so historical and real-time values stay consistent.

---

## Source Code

````pine
//@version=6
indicator(title="Multi EMA", shorttitle="Multi-EMA", overlay=true)

// ————— Reusable EMA calc with optional custom timeframe —————
f_ema(_src, _len, _tf) =>
    request.security(syminfo.tickerid, _tf, ta.ema(_src, _len), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)

// ============ Slot 1 ============
g1 = "EMA 1"
e1_on   = input.bool(false, "Enable", group=g1, inline="e1a")
e1_len  = input.int(9, "Length", minval=1, group=g1, inline="e1b")
e1_tf   = input.timeframe("", "Timeframe", group=g1, inline="e1b")
e1_src  = input.source(close, "Source", group=g1, inline="e1c")
e1_col  = input.color(color.blue, "Color", group=g1, inline="e1c")
e1_wid  = input.int(1, "Width", minval=1, maxval=5, group=g1, inline="e1d")
e1_val  = e1_on ? f_ema(e1_src, e1_len, e1_tf) : na
plot(e1_val, title="EMA 1", color=e1_col, linewidth=e1_wid)

// ============ Slot 2 ============
g2 = "EMA 2"
e2_on   = input.bool(false, "Enable", group=g2, inline="e2a")
e2_len  = input.int(21, "Length", minval=1, group=g2, inline="e2b")
e2_tf   = input.timeframe("", "Timeframe", group=g2, inline="e2b")
e2_src  = input.source(close, "Source", group=g2, inline="e2c")
e2_col  = input.color(color.orange, "Color", group=g2, inline="e2c")
e2_wid  = input.int(1, "Width", minval=1, maxval=5, group=g2, inline="e2d")
e2_val  = e2_on ? f_ema(e2_src, e2_len, e2_tf) : na
plot(e2_val, title="EMA 2", color=e2_col, linewidth=e2_wid)

// ============ Slot 3 ============
g3 = "EMA 3"
e3_on   = input.bool(false, "Enable", group=g3, inline="e3a")
e3_len  = input.int(50, "Length", minval=1, group=g3, inline="e3b")
e3_tf   = input.timeframe("", "Timeframe", group=g3, inline="e3b")
e3_src  = input.source(close, "Source", group=g3, inline="e3c")
e3_col  = input.color(color.red, "Color", group=g3, inline="e3c")
e3_wid  = input.int(1, "Width", minval=1, maxval=5, group=g3, inline="e3d")
e3_val  = e3_on ? f_ema(e3_src, e3_len, e3_tf) : na
plot(e3_val, title="EMA 3", color=e3_col, linewidth=e3_wid)

// ============ Slot 4 ============
g4 = "EMA 4"
e4_on   = input.bool(false, "Enable", group=g4, inline="e4a")
e4_len  = input.int(100, "Length", minval=1, group=g4, inline="e4b")
e4_tf   = input.timeframe("", "Timeframe", group=g4, inline="e4b")
e4_src  = input.source(close, "Source", group=g4, inline="e4c")
e4_col  = input.color(color.purple, "Color", group=g4, inline="e4c")
e4_wid  = input.int(1, "Width", minval=1, maxval=5, group=g4, inline="e4d")
e4_val  = e4_on ? f_ema(e4_src, e4_len, e4_tf) : na
plot(e4_val, title="EMA 4", color=e4_col, linewidth=e4_wid)

// ============ Slot 5 ============
g5 = "EMA 5"
e5_on   = input.bool(false, "Enable", group=g5, inline="e5a")
e5_len  = input.int(200, "Length", minval=1, group=g5, inline="e5b")
e5_tf   = input.timeframe("", "Timeframe", group=g5, inline="e5b")
e5_src  = input.source(close, "Source", group=g5, inline="e5c")
e5_col  = input.color(color.gray, "Color", group=g5, inline="e5c")
e5_wid  = input.int(1, "Width", minval=1, maxval=5, group=g5, inline="e5d")
e5_val  = e5_on ? f_ema(e5_src, e5_len, e5_tf) : na
plot(e5_val, title="EMA 5", color=e5_col, linewidth=e5_wid)
````
