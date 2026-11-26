# Fibonacci Extension Breakout

- url: https://www.tradingview.com/script/cAPImScX/
- type: indicator
- pine_id: PUB;c28479b13f3e41b1b5c43a2d8260fc57
- version: 1.0

## Description

[b]Fibonacci Extension Breakout[/b]

This indicator automatically draws Fibonacci extension zones on higher-timeframe (HTF) breakouts. Instead of manually drawing Fibonacci retracements after every swing, the script detects when price closes beyond the previous HTF bar's high or low, and then plots seven colored zones (boxes) extending from that breakout range using the 0, 1, 1.272, 1.786, and 2.272 Fibonacci ratios (and their negative-side equivalents).

[b]How it works?[/b]

On each new HTF period (default: Daily), the script checks whether the current HTF close has broken above the prior HTF high (bullish) or below the prior HTF low (bearish).

If a breakout occurred, it takes the new period's high/low as the base range and calculates Fibonacci extension levels outward from that range using a custom scaling function.

Each level pair (e.g., 1–1.272, 1.272–1.786, etc.) is rendered as a colored box, updated live as the HTF period develops, and closed off once the period ends.

A configurable history limit (Box History) controls how many past breakout zones remain visible on the chart.

HTF data is requested with lookahead=off (the safe default) to avoid look-ahead / repainting bias, so historical results reflect only data that was actually available at that time.

[b]Inputs[/b]

[b]Timeframe:[/b] the higher timeframe used for breakout detection (default: Daily)
[b]Box History:[/b] number of past breakout zones kept on the chart
[b]Border Color:[/b] box border color

[b]How to use it?[/b]

Add the indicator to any chart. When a breakout box appears, the mid-zone (0–1) represents the breakout range itself; zones above/below represent potential extension targets or reaction areas traders commonly watch after a breakout. 

This tool visualizes potential price targets after a range breakout — it does not generate buy/sell signals and should be combined with your own risk management and trade plan.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © oguz_ozturk9241

//@version=6
indicator("Fibonacci Extension Breakout Pro", shorttitle="Fib Ext Pro", overlay=true, max_bars_back=500, max_boxes_count=500, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────
tf        = input.timeframe("D", "Timeframe")
geriGit   = input.int(10, "Box History",  minval=1, maxval=50)
bordColor = input.color(color.new(color.gray, 20), "Border Color")

// ─── DATA (no lookahead — safe / non-repainting) ──────────────
// lookahead=barmerge.lookahead_on removed: with a non-offset ([0]) source
// it leaked unclosed future-bar data into history (the exact issue flagged
// by PineCoders). Default lookahead_off gives the same "current HTF bar so
// far" behavior in real time, but only confirmed data on historical bars.
dHigh  = request.security(syminfo.tickerid, tf, high)
dLow   = request.security(syminfo.tickerid, tf, low)
dClose = request.security(syminfo.tickerid, tf, close)
dHigh2 = request.security(syminfo.tickerid, tf, high[1])
dLow2  = request.security(syminfo.tickerid, tf, low[1])
dTime  = request.security(syminfo.tickerid, tf, time)

isNewDay = ta.change(dTime) != 0

// ─── BREAKOUT DETECTION ───────────────────────────────────────
// Bullish: current close > previous high
// Bearish: current close < previous low
bullish = dClose > dHigh2
bearish = dClose < dLow2

// ─── FIBONACCI EXTENSION LEVELS ───────────────────────────────
// Bullish breakout: 0=Low, 1=High, extensions above and below
// Bearish breakout: 0=High, 1=Low, extensions below and above
f_levels(h, l, up) =>
    r      = h - l
    s0     = up ? l              : h
    s1     = up ? h              : l
    s1272  = up ? h + r * 0.272  : l - r * 0.272
    s1786  = up ? h + r * 0.786  : l - r * 0.786
    s2272  = up ? h + r * 1.272  : l - r * 1.272
    sn786  = up ? l - r * 0.786  : h + r * 0.786
    sn1272 = up ? l - r * 1.272  : h + r * 1.272
    [sn1272, sn786, s0, s1, s1272, s1786, s2272]

// ─── ARRAYS ───────────────────────────────────────────────────
var box[] f6 = array.new_box()  // s1786  - s2272
var box[] f5 = array.new_box()  // s1272  - s1786
var box[] f4 = array.new_box()  // s1     - s1272
var box[] f3 = array.new_box()  // s0     - s1
var box[] f2 = array.new_box()  // sn786  - s0
var box[] f1 = array.new_box()  // sn1272 - sn786

f_clean(arr, maks) =>
    while array.size(arr) > maks
        box.delete(array.shift(arr))

f_close(arr, idx) =>
    if array.size(arr) >= 2
        box.set_right(array.get(arr, array.size(arr) - 2), idx)

f_update(arr, top, bot, idx) =>
    if array.size(arr) > 0
        b = array.get(arr, array.size(arr) - 1)
        box.set_top(b,    math.max(top, bot))
        box.set_bottom(b, math.min(top, bot))
        box.set_right(b,  idx + 1)

// ─── NEW PERIOD — ONLY ON BREAKOUT ───────────────────────────
if isNewDay and (bullish or bearish)
    sol = bar_index
    bH  = dHigh
    bL  = dLow

    if not na(bH) and not na(bL) and bH > bL
        [sn1272, sn786, s0, s1, s1272, s1786, s2272] = f_levels(bH, bL, bullish)

        array.push(f6, box.new(sol, math.max(s2272,s1786),  sol+1, math.min(s2272,s1786),  border_color=bordColor, border_width=1, bgcolor=color.new(color.purple, 75)))
        array.push(f5, box.new(sol, math.max(s1786,s1272),  sol+1, math.min(s1786,s1272),  border_color=bordColor, border_width=1, bgcolor=color.new(color.red,    75)))
        array.push(f4, box.new(sol, math.max(s1272,s1),     sol+1, math.min(s1272,s1),     border_color=bordColor, border_width=1, bgcolor=color.new(color.orange, 75)))
        array.push(f3, box.new(sol, math.max(s1,s0),        sol+1, math.min(s1,s0),        border_color=bordColor, border_width=1, bgcolor=color.new(color.green,  75)))
        array.push(f2, box.new(sol, math.max(s0,sn786),     sol+1, math.min(s0,sn786),     border_color=bordColor, border_width=1, bgcolor=color.new(color.blue,   75)))
        array.push(f1, box.new(sol, math.max(sn786,sn1272), sol+1, math.min(sn786,sn1272), border_color=bordColor, border_width=1, bgcolor=color.new(color.purple, 85)))

        f_close(f6, bar_index), f_close(f5, bar_index), f_close(f4, bar_index)
        f_close(f3, bar_index), f_close(f2, bar_index), f_close(f1, bar_index)

        f_clean(f6, geriGit), f_clean(f5, geriGit), f_clean(f4, geriGit)
        f_clean(f3, geriGit), f_clean(f2, geriGit), f_clean(f1, geriGit)

// ─── UPDATE ACTIVE BOX ────────────────────────────────────────
if array.size(f3) > 0
    aH = dHigh
    aL = dLow

    if not na(aH) and not na(aL) and aH > aL
        [sn1272, sn786, s0, s1, s1272, s1786, s2272] = f_levels(aH, aL, bullish)

        f_update(f6, math.max(s2272,s1786),  math.min(s2272,s1786),  bar_index)
        f_update(f5, math.max(s1786,s1272),  math.min(s1786,s1272),  bar_index)
        f_update(f4, math.max(s1272,s1),     math.min(s1272,s1),     bar_index)
        f_update(f3, math.max(s1,s0),        math.min(s1,s0),        bar_index)
        f_update(f2, math.max(s0,sn786),     math.min(s0,sn786),     bar_index)
        f_update(f1, math.max(sn786,sn1272), math.min(sn786,sn1272), bar_index)
````
