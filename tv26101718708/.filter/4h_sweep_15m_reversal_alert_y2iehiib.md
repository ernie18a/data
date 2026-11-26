# 4H Sweep + 15M Reversal Alert

- url: https://www.tradingview.com/script/y2IEHIib-4H-Sweep-15M-Reversal-Alert/
- type: indicator
- pine_id: PUB;42732452d31b4ae697d7b9946a292bd3
- version: 1.0

## Description

This is a Pine Script v5 TradingView indicator that automates a multi-timeframe liquidity sweep + reversal strategy. It runs on the 15M chart but references 4H levels. Here's what each step does:
Step 1 — 4H Levels: Uses request.security to pull the highest high and lowest low from the last 20 (default) completed 4H bars, then plots them as stepline levels on your chart.
Step 2 — Sweep Detection: Flags a bullish sweep when a candle's wick pierces below the 4H low but the body closes back above it (stop hunt below support). Flags a bearish sweep for the mirror case above the 4H high. Each prints a labeled marker.
Step 3 — 15M Swing Points: Uses ta.pivothigh / ta.pivotlow with a 5-bar lookback on each side to mark recent swing highs and lows, storing the most recent ones in last_swing_high / last_swing_low variables for later reference.
Step 4 — Reversal Candle: After a sweep, it opens a "sweep window" and looks for a strong-bodied candle (body ≥ 50% of total range) closing in the reversal direction. Plots a circle when found.
Step 5 — Entry Confirmation: The actual trade trigger. It requires all three conditions stacked: sweep happened → reversal candle printed → price now closes beyond the most recent 15M swing point (breaking structure). Prints a "LONG" or "SHORT" label, then resets the state so it doesn't re-fire on the same setup.
Step 6 — Background Shading: Tints the background lime/red while a sweep window is active, so you visually know the setup is "armed."
Step 7 — Alerts: Six alert conditions covering every stage — sweep detected, reversal candle, and final entry confirmation — so you can get notified early or only on the confirmed entry, depending on which alert you set up in TradingView.
One thing worth flagging: the h4_lookback input allows a max of 100, but max_bars_back=500 combined with a 4H lookback on a 15M chart means you need sufficient historical bars loaded or the 4H levels may not populate on newer symbols. Also, bull_reversal_seen / bear_reversal_seen persist indefinitely until a confirmation fires or the opposite sweep occurs — so if a sweep window stays open for a long time without confirmation, a late breakout could still trigger an entry off a stale reversal candle. You may want to add a bar-count expiry to the sweep window.Opus 4.7

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © strades55

//@version=5
indicator("4H Sweep + 15M Reversal Alert", overlay=true, max_bars_back=500)

// ============================================================
// INPUTS
// ============================================================
// -- 4H Swing Lookback
h4_lookback = input.int(20, title="4H High/Low Lookback (bars)", minval=5, maxval=100, group="4H Settings")

// -- 15M Swing Detection
m15_swing_len = input.int(5, title="15M Swing Pivot Strength (bars each side)", minval=2, maxval=20, group="15M Settings")

// -- Colors
col_4h_high    = input.color(color.new(color.red,    0),  title="4H High Line",         group="Colors")
col_4h_low     = input.color(color.new(color.green,  0),  title="4H Low Line",          group="Colors")
col_sweep_bull = input.color(color.new(color.lime,   0),  title="Bullish Sweep Label",  group="Colors")
col_sweep_bear = input.color(color.new(color.red,    0),  title="Bearish Sweep Label",  group="Colors")
col_rev_bull   = input.color(color.new(color.aqua,   0),  title="Bullish Reversal",     group="Colors")
col_rev_bear   = input.color(color.new(color.orange, 0),  title="Bearish Reversal",     group="Colors")
col_conf_bull  = input.color(color.new(color.blue,   0),  title="Bullish Confirmation", group="Colors")
col_conf_bear  = input.color(color.new(color.fuchsia,0),  title="Bearish Confirmation", group="Colors")

// ============================================================
// STEP 1 — FETCH 4H HIGH / LOW
// ============================================================
h4_high = request.security(syminfo.tickerid, "240", ta.highest(high, h4_lookback)[1], lookahead=barmerge.lookahead_off)
h4_low  = request.security(syminfo.tickerid, "240", ta.lowest (low,  h4_lookback)[1], lookahead=barmerge.lookahead_off)

// Plot 4H levels
plot(h4_high, title="4H High", color=col_4h_high, linewidth=2, style=plot.style_stepline)
plot(h4_low,  title="4H Low",  color=col_4h_low,  linewidth=2, style=plot.style_stepline)

// ============================================================
// STEP 2 — DETECT 4H HIGH / LOW SWEEP (Wick pierces, body closes back)
// ============================================================
bull_sweep = low < h4_low and close > h4_low
bear_sweep = high > h4_high and close < h4_high

if bull_sweep
    label.new(bar_index, low, "🔻 Low\nSweep", color=col_sweep_bull, textcolor=color.white, style=label.style_label_up,   size=size.small)

if bear_sweep
    label.new(bar_index, high, "🔺 High\nSweep", color=col_sweep_bear, textcolor=color.white, style=label.style_label_down, size=size.small)

// ============================================================
// STEP 3 — DETECT 15M SWING HIGH / LOW (most recent)
// ============================================================
swing_high = ta.pivothigh(high, m15_swing_len, m15_swing_len)
swing_low  = ta.pivotlow (low,  m15_swing_len, m15_swing_len)

var float last_swing_high = na
var float last_swing_low  = na

if not na(swing_high)
    last_swing_high := swing_high

if not na(swing_low)
    last_swing_low := swing_low

plotshape(not na(swing_high), title="15M Swing High", location=location.abovebar, style=shape.triangledown, color=color.new(col_4h_high, 30), size=size.tiny)
plotshape(not na(swing_low),  title="15M Swing Low",  location=location.belowbar, style=shape.triangleup,   color=color.new(col_4h_low,  30), size=size.tiny)

plot(last_swing_high, title="Last 15M Swing High", color=color.new(col_4h_high, 60), linewidth=1, style=plot.style_linebr)
plot(last_swing_low,  title="Last 15M Swing Low",  color=color.new(col_4h_low,  60), linewidth=1, style=plot.style_linebr)

// ============================================================
// STEP 4 — DETECT 15M PRICE REVERSAL CANDLE
// ============================================================
candle_body  = math.abs(close - open)
candle_range = high - low
strong_body  = candle_range > 0 and (candle_body / candle_range) >= 0.5

var bool in_bull_sweep_window = false
var bool in_bear_sweep_window = false

if bull_sweep
    in_bull_sweep_window := true
    in_bear_sweep_window := false

if bear_sweep
    in_bear_sweep_window := true
    in_bull_sweep_window := false

bull_reversal = in_bull_sweep_window and close > open and strong_body
bear_reversal = in_bear_sweep_window and close < open and strong_body

plotshape(bull_reversal, title="15M Bull Reversal", location=location.belowbar, style=shape.circle, color=col_rev_bull, size=size.small)
plotshape(bear_reversal, title="15M Bear Reversal", location=location.abovebar, style=shape.circle, color=col_rev_bear, size=size.small)

// ============================================================
// STEP 5 — CONFIRMATION: 15M CANDLE CLOSE ABOVE/BELOW LAST SWING
// ============================================================
var bool bull_reversal_seen = false
var bool bear_reversal_seen = false

if bull_reversal
    bull_reversal_seen := true

if bear_reversal
    bear_reversal_seen := true

bull_confirm = bull_reversal_seen and in_bull_sweep_window and close > last_swing_high
bear_confirm = bear_reversal_seen and in_bear_sweep_window and close < last_swing_low

if bull_confirm
    in_bull_sweep_window := false
    bull_reversal_seen   := false

if bear_confirm
    in_bear_sweep_window := false
    bear_reversal_seen   := false

plotshape(bull_confirm, title="✅ Bullish Entry Signal", location=location.belowbar, style=shape.labelup,   color=col_conf_bull, text="LONG",  textcolor=color.white, size=size.normal)
plotshape(bear_confirm, title="✅ Bearish Entry Signal", location=location.abovebar, style=shape.labeldown, color=col_conf_bear, text="SHORT", textcolor=color.white, size=size.normal)

// ============================================================
// STEP 6 — BACKGROUND HIGHLIGHT during active sweep window
// ============================================================
bgcolor(in_bull_sweep_window ? color.new(color.lime, 92) : na, title="Active Bull Sweep Window")
bgcolor(in_bear_sweep_window ? color.new(color.red,  92) : na, title="Active Bear Sweep Window")

// ============================================================
// STEP 7 — ALERTS
// ============================================================
alertcondition(bull_sweep,    title="🔻 4H Low Swept",            message="[{{ticker}}] 4H Low Swept on {{interval}} — Watching for bullish reversal")
alertcondition(bear_sweep,    title="🔺 4H High Swept",           message="[{{ticker}}] 4H High Swept on {{interval}} — Watching for bearish reversal")
alertcondition(bull_reversal, title="🔄 Bullish Reversal Candle", message="[{{ticker}}] 15M Bullish reversal candle after low sweep — Watch for swing high break")
alertcondition(bear_reversal, title="🔄 Bearish Reversal Candle", message="[{{ticker}}] 15M Bearish reversal candle after high sweep — Watch for swing low break")
alertcondition(bull_confirm,  title="✅ LONG Entry Confirmed",    message="[{{ticker}}] LONG ENTRY: 15M close above swing high after 4H low sweep + reversal")
alertcondition(bear_confirm,  title="✅ SHORT Entry Confirmed",   message="[{{ticker}}] SHORT ENTRY: 15M close below swing low after 4H high sweep + reversal")
````
