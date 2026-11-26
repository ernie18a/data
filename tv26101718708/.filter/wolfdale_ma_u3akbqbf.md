# Wolfdale - MA

- url: https://www.tradingview.com/script/u3AkbqBF-Wolfdale-MA/
- type: indicator
- pine_id: PUB;c91c607fe0074d87a453513f1da7654b
- version: 2.0

## Description

Easy configurable MA ribbon, each MA can be configured on type and time.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Wolfdale
// V1.1
//@version=5
indicator(title="Wolfdale-MA", shorttitle="CMA", overlay=true)

// ─── GLOBAL ───────────────────────────────────────────────────────────────────
src = input.source(close, "Price Source")

// ─── MA FUNCTION ──────────────────────────────────────────────────────────────
f_ma(source, length, type) =>
    switch type
        "SMA"  => ta.sma(source, length)
        "EMA"  => ta.ema(source, length)
        "WMA"  => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)
        "HMA"  => ta.wma(2 * ta.wma(source, length / 2) - ta.wma(source, length), math.round(math.sqrt(length)))
        "RMA"  => ta.rma(source, length)
        "DEMA" =>
            _e = ta.ema(source, length)
            2 * _e - ta.ema(_e, length)
        "TEMA" =>
            _e  = ta.ema(source, length)
            _e2 = ta.ema(_e, length)
            3 * _e - 3 * _e2 + ta.ema(_e2, length)
        => ta.ema(source, length)

// ─── MA 1 ─────────────────────────────────────────────────────────────────────
ma1_len      = input.int(144,    "MA #1 Length",           minval=1,                                                              group="MA 1")
ma1_type     = input.string("EMA","MA #1 Type",            options=["SMA","EMA","WMA","VWMA","HMA","RMA","DEMA","TEMA"],           group="MA 1")
ma1_show     = input.bool(true,  "Plot MA #1?",                                                                                   group="MA 1")
ma1_useCurr  = input.bool(true,  "MA #1 — Use Current Timeframe?",                                                               group="MA 1")
ma1_tf       = input.timeframe("240", "MA #1 — Locked Timeframe",                                                                group="MA 1")

// ─── MA 2 ─────────────────────────────────────────────────────────────────────
ma2_len      = input.int(169,    "MA #2 Length",           minval=1,                                                              group="MA 2")
ma2_type     = input.string("EMA","MA #2 Type",            options=["SMA","EMA","WMA","VWMA","HMA","RMA","DEMA","TEMA"],           group="MA 2")
ma2_show     = input.bool(true,  "Plot MA #2?",                                                                                   group="MA 2")
ma2_useCurr  = input.bool(true,  "MA #2 — Use Current Timeframe?",                                                               group="MA 2")
ma2_tf       = input.timeframe("240", "MA #2 — Locked Timeframe",                                                                group="MA 2")

// ─── MA 3 ─────────────────────────────────────────────────────────────────────
ma3_len      = input.int(480,    "MA #3 Length",           minval=1,                                                              group="MA 3")
ma3_type     = input.string("EMA","MA #3 Type",            options=["SMA","EMA","WMA","VWMA","HMA","RMA","DEMA","TEMA"],           group="MA 3")
ma3_show     = input.bool(true,  "Plot MA #3?",                                                                                   group="MA 3")
ma3_useCurr  = input.bool(true,  "MA #3 — Use Current Timeframe?",                                                               group="MA 3")
ma3_tf       = input.timeframe("240", "MA #3 — Locked Timeframe",                                                                group="MA 3")

// ─── MA 4 ─────────────────────────────────────────────────────────────────────
ma4_len      = input.int(864,    "MA #4 Length",           minval=1,                                                              group="MA 4")
ma4_type     = input.string("EMA","MA #4 Type",            options=["SMA","EMA","WMA","VWMA","HMA","RMA","DEMA","TEMA"],           group="MA 4")
ma4_show     = input.bool(true,  "Plot MA #4?",                                                                                   group="MA 4")
ma4_useCurr  = input.bool(true,  "MA #4 — Use Current Timeframe?",                                                               group="MA 4")
ma4_tf       = input.timeframe("240", "MA #4 — Locked Timeframe",                                                                group="MA 4")

// ─── MA 5 ─────────────────────────────────────────────────────────────────────
ma5_len      = input.int(864,    "MA #5 Length",           minval=1,                                                              group="MA 5")
ma5_type     = input.string("EMA","MA #5 Type",            options=["SMA","EMA","WMA","VWMA","HMA","RMA","DEMA","TEMA"],           group="MA 5")
ma5_show     = input.bool(false, "Plot MA #5?",                                                                                   group="MA 5")
ma5_useCurr  = input.bool(true,  "MA #5 — Use Current Timeframe?",                                                               group="MA 5")
ma5_tf       = input.timeframe("240", "MA #5 — Locked Timeframe",                                                                group="MA 5")

// ─── MA 6 ─────────────────────────────────────────────────────────────────────
ma6_len      = input.int(200,    "MA #6 Length",           minval=1,                                                              group="MA 6")
ma6_type     = input.string("EMA","MA #6 Type",            options=["SMA","EMA","WMA","VWMA","HMA","RMA","DEMA","TEMA"],           group="MA 6")
ma6_show     = input.bool(true,  "Plot MA #6?",                                                                                   group="MA 6")
ma6_useCurr  = input.bool(true,  "MA #6 — Use Current Timeframe?",                                                               group="MA 6")
ma6_tf       = input.timeframe("240", "MA #6 — Locked Timeframe",                                                                group="MA 6")

// ─── CROSSOVER ────────────────────────────────────────────────────────────────
fastMA = input.string("MA 1", "Fast MA", options=["MA 1","MA 2","MA 3","MA 4","MA 5","MA 6"], group="Crossover Signals")
slowMA = input.string("MA 3", "Slow MA", options=["MA 1","MA 2","MA 3","MA 4","MA 5","MA 6"], group="Crossover Signals")

// ─── SECURITY CALLS ───────────────────────────────────────────────────────────
ma1 = request.security(syminfo.tickerid, ma1_useCurr ? timeframe.period : ma1_tf, f_ma(src, ma1_len, ma1_type), lookahead=barmerge.lookahead_off)
ma2 = request.security(syminfo.tickerid, ma2_useCurr ? timeframe.period : ma2_tf, f_ma(src, ma2_len, ma2_type), lookahead=barmerge.lookahead_off)
ma3 = request.security(syminfo.tickerid, ma3_useCurr ? timeframe.period : ma3_tf, f_ma(src, ma3_len, ma3_type), lookahead=barmerge.lookahead_off)
ma4 = request.security(syminfo.tickerid, ma4_useCurr ? timeframe.period : ma4_tf, f_ma(src, ma4_len, ma4_type), lookahead=barmerge.lookahead_off)
ma5 = request.security(syminfo.tickerid, ma5_useCurr ? timeframe.period : ma5_tf, f_ma(src, ma5_len, ma5_type), lookahead=barmerge.lookahead_off)
ma6 = request.security(syminfo.tickerid, ma6_useCurr ? timeframe.period : ma6_tf, f_ma(src, ma6_len, ma6_type), lookahead=barmerge.lookahead_off)

// ─── PLOTS ────────────────────────────────────────────────────────────────────
plot(ma1_show ? ma1 : na, "MA 1", color=#00BCD4, linewidth=2)
plot(ma2_show ? ma2 : na, "MA 2", color=#00796B, linewidth=2)
plot(ma3_show ? ma3 : na, "MA 3", color=#5C9BD6, linewidth=2)
plot(ma4_show ? ma4 : na, "MA 4", color=#1A237E, linewidth=2)
plot(ma5_show ? ma5 : na, "MA 5", color=#F48FB1, linewidth=2)
plot(ma6_show ? ma6 : na, "MA 6", color=#880E4F, linewidth=2)

// ─── CROSSOVER SIGNALS ────────────────────────────────────────────────────────
f_get_ma(name) =>
    switch name
        "MA 1" => ma1
        "MA 2" => ma2
        "MA 3" => ma3
        "MA 4" => ma4
        "MA 5" => ma5
        "MA 6" => ma6
        => ma1

fast = f_get_ma(fastMA)
slow = f_get_ma(slowMA)

bullCross = ta.crossover(fast, slow)
bearCross = ta.crossunder(fast, slow)

plotshape(bullCross, "Bullish MA Crossover",  shape.triangleup,   location.belowbar, color=color.new(#4CAF50, 0), size=size.small)
plotshape(bearCross, "Bearish MA Crossunder", shape.triangledown, location.abovebar, color=color.new(#FF5252, 0), size=size.small)
````
