# Ineficient market

- url: https://www.tradingview.com/script/t578EfVb/
- type: strategy
- pine_id: PUB;dd624efbefc8412f9f8e83f57f2fbde5
- version: 1.0

## Description

The setup
The 1-2-3 pattern (price-structure reversal, in the Joe Ross / Zeiierman lineage) marks three alternating pivots: an extreme, a pullback, and a second extreme that fails to exceed the first — a Higher-Low for longs, a Lower-High for shorts. Entry fires on confirmation of the 3rd pivot (no waiting for a breakout, which cuts lag). On top of that sits a volatility gate: signals only trigger when relative volatility is compressed (ATR% ≤ its own moving average). Trades resolve on a small fixed TP, a wide SL, and a time-stop.

The inefficiency
This isn't about "predicting direction" — direction is free and doesn't pay. The edge is a short-term overreaction at structure pivots: after price prints a failed extreme, it tends to give back a small, fast fraction of the move. In compressed volatility that give-back is more reliable and less noisy. The edge is statistical and regime-conditional — not a silver bullet.

Why the exit looks "wrong" (and why that's the whole point)
The counterintuitive part: small TP + wide SL + no trailing, no break-even, no touching the trade. We tested active management extensively (move to BE, trailing, tight stops at the "normal MAE") and every version destroys the edge — because 1–3% adverse excursion is normal even on winners, and any tight stop sits exactly where noise wanders. Holding through that swing is what captures the reversion. It's fire-and-forget by design, not by laziness.

How we found it (the differentiator)
This wasn't reverse-engineered from a pretty chart. It survived:
- Random-matched placebo — the same exit engine fired on random bars vs. the real signal, proving the edge lives in the signal, not the short TP.
- Path-dependent backtesting — simulating the exact order of intra-trade events, not aggregate stats (which mislead).
- Conditional MAE analysis — measuring how win probability decays as a trade digs, which set the wide SL and killed the temptation of tight stops.

Inputs: prd (pivot lookback) · ATR ratio max (volatility gate) · TP % · SL % · time-stop · direction (long/short).

Disclaimer: For research/education, not financial advice. Past performance does not guarantee future results. The edge is conditional on regime and costs — test with your own commission/slippage before any live use.

## Source Code

````pine
//@version=6
// ============================================================================
//  1-2-3 Pattern + ATR Filter  —  Strategy
//  Price-action reversal setup (Joe Ross / Zeiierman 1-2-3) with a volatility
//  gate. A signal is taken on confirmation of the 3rd pivot (early entry),
//  only when relative ATR is compressed (mean/quiet regime). Fixed % TP,
//  wide % SL and a time-stop. Long & Short.
//
//  Structure:
//    Bullish (long) : pivot Low(3) > Low(1) and Low(3) < High(2)   [Higher-Low]
//    Bearish (short): pivot High(3) < High(1) and High(3) > Low(2)  [Lower-High]
//  ATR gate: ATR% / SMA50(ATR%) <= threshold.
//
//  © abib14bis
// ============================================================================
strategy('1-2-3 Pattern + ATR Filter', overlay = true, max_bars_back = 5000, initial_capital = 10000, default_qty_type = strategy.cash, default_qty_value = 1000, commission_type = strategy.commission.percent, commission_value = 0.055, slippage = 2, process_orders_on_close = true, pyramiding = 0)

// ============ INPUTS ============
grpSig = 'Signal'
prd = input.int(20, 'Pivot lookback (prd)', minval = 2, group = grpSig, tooltip = 'Left/right bars for pivot detection. Higher = fewer, cleaner pivots.')
atr_filter_max = input.float(0.85, 'ATR ratio max (0 = off)', step = 0.05, group = grpSig, tooltip = 'Signal only fires when ATR% / SMA50(ATR%) <= this. 0 disables the filter.')
allowLong = input.bool(true, 'Allow Long', group = grpSig)
allowShort = input.bool(true, 'Allow Short', group = grpSig)

grpExit = 'Exits'
tp_pct = input.float(0.98, 'Take Profit %', step = 0.01, minval = 0.0, group = grpExit)
sl_pct = input.float(9.5, 'Stop Loss %', step = 0.1, minval = 0.0, group = grpExit)
time_stop_bars = input.int(480, 'Time stop (bars)', minval = 1, group = grpExit, tooltip = 'Force-close the position after this many bars if neither TP nor SL is hit.')

grpVis = 'Visual'
showPattern = input.bool(true, 'Show 1-2-3 labels', group = grpVis)

colBull = color.new(#31be0c, 0)
colBear = color.new(#df3d3d, 0)

// ============ ATR FILTER ============
atr_val = ta.atr(14)
atr_pct = atr_val / close * 100
atr_sma50 = ta.sma(atr_pct, 50)
atr_ratio = atr_sma50 > 0 ? atr_pct / atr_sma50 : 1.0
atr_ok = atr_filter_max <= 0 or atr_ratio <= atr_filter_max

// ============ PIVOT STATE (last 3 pivots, alternating H/L) ============
var pvts = array.new<float>(3, 0.0)
var idx = array.new<int>(3, 0)
var pos = 0

pvtHi = ta.pivothigh(high, prd, prd)
pvtLo = ta.pivotlow(low, prd, prd)

just_added_high = false
just_added_low = false

if not na(pvtHi) and pos <= 0
    array.pop(pvts)
    array.pop(idx)
    array.unshift(pvts, high[prd])
    array.unshift(idx, bar_index - prd)
    pos := 1
    just_added_high := true
    just_added_high

if not na(pvtLo) and pos >= 0
    array.pop(pvts)
    array.pop(idx)
    array.unshift(pvts, low[prd])
    array.unshift(idx, bar_index - prd)
    pos := -1
    just_added_low := true
    just_added_low

// ============ SIGNAL (on 3rd pivot confirmation) ============
var pattern = true
long_sig = false
short_sig = false

if pattern and array.get(idx, 2) > 0 and atr_ok
    p0 = array.get(pvts, 0)
    p1 = array.get(pvts, 1)
    p2 = array.get(pvts, 2)
    if just_added_low and p0 > p2 and p0 < p1
        long_sig := true
        if showPattern
            label.new(array.get(idx, 2), p2, '1', color = color(na), textcolor = chart.fg_color, style = label.style_label_up)
            label.new(array.get(idx, 1), p1, '2', color = color(na), textcolor = chart.fg_color, style = label.style_label_down)
            label.new(array.get(idx, 0), p0, '3', color = color(na), textcolor = chart.fg_color, style = label.style_label_up)
            line.new(array.get(idx, 2), p2, array.get(idx, 1), p1, color = colBull, width = 2)
            line.new(array.get(idx, 1), p1, array.get(idx, 0), p0, color = colBull, width = 2)
        pattern := false
        pattern
    if just_added_high and p0 < p2 and p0 > p1
        short_sig := true
        if showPattern
            label.new(array.get(idx, 2), p2, '1', color = color(na), textcolor = chart.fg_color, style = label.style_label_down)
            label.new(array.get(idx, 1), p1, '2', color = color(na), textcolor = chart.fg_color, style = label.style_label_up)
            label.new(array.get(idx, 0), p0, '3', color = color(na), textcolor = chart.fg_color, style = label.style_label_down)
            line.new(array.get(idx, 2), p2, array.get(idx, 1), p1, color = colBear, width = 2)
            line.new(array.get(idx, 1), p1, array.get(idx, 0), p0, color = colBear, width = 2)
        pattern := false
        pattern

// Reset the pattern lock whenever the middle pivot (point 2) changes
if ta.change(array.get(pvts, 1)) != 0
    pattern := true
    pattern

// ============ EXECUTION ============
var int entry_bar = na

if allowLong and long_sig and strategy.position_size == 0
    strategy.entry('Long', strategy.long)
    entry_bar := bar_index
    entry_bar

if allowShort and short_sig and strategy.position_size == 0
    strategy.entry('Short', strategy.short)
    entry_bar := bar_index
    entry_bar

if strategy.position_size > 0
    tp_price = strategy.position_avg_price * (1 + tp_pct / 100)
    sl_price = strategy.position_avg_price * (1 - sl_pct / 100)
    strategy.exit('Exit Long', 'Long', limit = tp_price, stop = sl_price)
    if not na(entry_bar) and bar_index - entry_bar >= time_stop_bars
        strategy.close('Long', comment = 'Time stop')

if strategy.position_size < 0
    tp_price = strategy.position_avg_price * (1 - tp_pct / 100)
    sl_price = strategy.position_avg_price * (1 + sl_pct / 100)
    strategy.exit('Exit Short', 'Short', limit = tp_price, stop = sl_price)
    if not na(entry_bar) and bar_index - entry_bar >= time_stop_bars
        strategy.close('Short', comment = 'Time stop')

if strategy.position_size == 0
    entry_bar := na
    entry_bar

// ============ PLOTS ============
plotshape(long_sig, title = 'BUY', style = shape.triangleup, location = location.belowbar, color = colBull, size = size.small)
plotshape(short_sig, title = 'SELL', style = shape.triangledown, location = location.abovebar, color = colBear, size = size.small)
````
