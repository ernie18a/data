<!-- tradingview-pine-id: PUB;fe5301b8b36a495b865b342045854b28 -->
<!-- tradingviewscripts-format: 1 -->
# CM - Bollinger Bands Mean Reversion [CriptoMatiko]

Source: https://www.tradingview.com/script/UfVSoNrD-CM-Bollinger-Bands-Mean-Reversion-CriptoMatiko/

## Description

This indicator tracks **Bollinger Bands mean reversion signals**, replicating the entry and exit logic of a Python backtester that evaluated 81 long + 81 short parameter combinations on ETH/USDT 4H (Bybit Futures Linear, Mar 2025 – Aug 2026).

**The central finding:** the stop loss matters more than the band parameters.

| Setup | Direction | SL | Trades | Win Rate | Return |
|---|---|---|---|---|---|
| Standard (what tutorials teach) | Long | 2% | 110 | 38% | **-22.8%** |
| Optimized (indicator default) | Long | 1% | 110 | 38.2% | **+16.0%** |
| Buy & Hold ETH (same period) | — | — | — | — | -1.2% |

Same indicator. Same band parameters (20, 2.0). Different stop loss.

**Short side (optional):**
BB(20,2) shorts returned -17.4% — avoid with these settings. The optimizer found that shorts require different parameters: BB(10, 2.5) SL=1% TP=3R → +8.9% (Sharpe 7.81, 23 trades). Enable via the "Allow Short" input and adjust the parameters accordingly.

---

**Signal logic:**
- Long signal: bar closes **below** the lower Bollinger Band (no open position)
- Short signal: bar closes **above** the upper Bollinger Band (no open position)
- Entry: executed at the **next bar's open** (no lookahead)

**Exit logic — three mechanisms:**
1. **SL**: price hits SL% below (long) or above (short) the entry price
2. **TP**: price hits TP_ratio × risk from entry
3. **BB_UP / BB_DN**: bar closes beyond the opposite band (mean reversion complete)

**Default parameters (best Sharpe from 81-config long optimization):**
- BB Period: 20 | Std Deviation: 2.0 | Stop Loss: 1.0% | TP Ratio: 2.0R

**What makes this different from other BB indicators:**
- Parameters derived from a grid search (3 periods × 3 std devs × 3 SL% × 3 TP ratios × long/short/both)
- Simulated position tracking: entry marks appear on the next bar's open, matching backtester logic
- Three exit mechanisms with distinct markers (SL ✕ / TP ✓ / BB reversion ▽)
- SL and TP levels displayed as live lines during open position
- Short side included but with honest disclosure: BB(20,2) shorts underperform
- Uses ddof=1 standard deviation (biased=false) to match Python pandas behavior exactly

**Note:** This is an indicator with simulated position tracking, not a strategy. It shows signals and approximate trade timing for visual reference. For exact backtesting and the full optimizer: see GitHub link below.

**Tested on:** ETH/USDT 4H, Bybit Futures Linear. Validate on your own pair before using with real capital. Past performance does not guarantee future results.

---

## Source Code

````pine
// (c) CriptoMatiko | criptomatiko.com
// Author: Vernon Vilallonga - CriptoMatiko
//
// INDICATOR: Bollinger Bands Mean Reversion - Signal Tracker
// Python backtester: 81 long + 81 short combinations, ETH/USDT 4H, Mar 2025 - Aug 2026
//
// KEY FINDING:
//   BB(20,2) SL=1% TP=2R -> +16.0%  DD=-8.0%  Sharpe=3.86  (110 trades)
//   BB(20,2) SL=2% TP=2R -> -22.8%  DD=-41.5%              (what tutorials teach)
//   Same indicator. Same band. The stop loss kills the strategy.
//
// SHORT SIDE (optional, disabled by default):
//   BB(20,2) short: -17.4% - bad. Use BB(10,2.5) SL=1% TP=3R -> +8.9% (23 trades only)
//
// SIGNAL LOGIC:
//   Long:  close < lower band -> entry at next bar open
//   Short: close > upper band -> entry at next bar open
//   Exits: SL / TP / BB_UP (long) / BB_DN (short)
//
// Full Python backtester: github.com/VernonCM/bot-bollinger-bands-bybit

//@version=6
indicator("CM - Bollinger Bands Mean Reversion [CriptoMatiko]", shorttitle="CM BB MR", overlay=true)

// ---- Inputs -----------------------------------------------------------------
bb_length   = input.int(20, "BB Period", minval=5, group="Bollinger Bands")
bb_mult     = input.float(2.0, "Std Deviation", step=0.5, group="Bollinger Bands")
sl_pct      = input.float(1.0, "Stop Loss %", step=0.5, minval=0.1, group="SL / TP") / 100
tp_r        = input.float(2.0, "TP Ratio (R)", step=0.5, minval=0.5, group="SL / TP")
allow_long  = input.bool(true,  "Long  (close < lower band)", group="Direction")
allow_short = input.bool(false, "Short (close > upper band)", group="Direction")

// ---- Bollinger Bands --------------------------------------------------------
// biased=false = ddof=1 (Bessel correction) matches Python pandas rolling().std()
bb_mid   = ta.sma(close, bb_length)
bb_std   = ta.stdev(close, bb_length, false)
bb_upper = bb_mid + bb_mult * bb_std
bb_lower = bb_mid - bb_mult * bb_std

// ---- Position tracking (mirrors Python backtester loop) ---------------------
// Signal on bar[N] close -> pending flag -> entry at bar[N+1] open
var int   pos        = 0
var float entry_px   = na
var float sl_lv      = na
var float tp_lv      = na
var bool  pend_long  = false
var bool  pend_short = false

// Step 1 - Execute pending entry at this bar's open
just_long  = pend_long  and pos == 0
just_short = pend_short and pos == 0

if just_long
    r          = open * sl_pct
    entry_px  := open
    sl_lv     := open - r
    tp_lv     := open + tp_r * r
    pos       := 1
    pend_long := false

if just_short
    r           = open * sl_pct
    entry_px   := open
    sl_lv      := open + r
    tp_lv      := open - tp_r * r
    pos        := -1
    pend_short := false

// Step 2 - Evaluate exits (capture pos type BEFORE clearing for plotshapes)
was_long  = pos == 1
was_short = pos == -1
do_sl = (was_long and low <= sl_lv) or (was_short and high >= sl_lv)
do_tp = (was_long and high >= tp_lv) or (was_short and low <= tp_lv)
do_bb = (was_long and close > bb_upper) or (was_short and close < bb_lower)

if do_sl or do_tp or do_bb
    pos      := 0
    entry_px := na
    sl_lv    := na
    tp_lv    := na

// Step 3 - Detect new signals on this bar's close
sig_long  = close < bb_lower and pos == 0 and not pend_long  and not pend_short and allow_long
sig_short = close > bb_upper and pos == 0 and not pend_long  and not pend_short and allow_short

if sig_long
    pend_long  := true
if sig_short
    pend_short := true

// ---- Plots ------------------------------------------------------------------
in_long  = pos == 1
in_short = pos == -1
in_pos   = in_long or in_short

p_mid   = plot(bb_mid,   "Mid Band",   color=color.new(color.gray, 20), linewidth=1)
p_upper = plot(bb_upper, "Upper Band", color=color.new(color.blue, 20), linewidth=1)
p_lower = plot(bb_lower, "Lower Band", color=color.new(color.blue, 20), linewidth=1)

fill_color = in_long ? color.new(color.teal, 88) : in_short ? color.new(color.red, 92) : color.new(color.blue, 94)
fill(p_upper, p_lower, color=fill_color, title="BB Fill")

plot(in_pos ? sl_lv : na, "Stop Loss",   color=color.new(color.red,   10), style=plot.style_linebr, linewidth=1)
plot(in_pos ? tp_lv : na, "Take Profit", color=color.new(color.green, 10), style=plot.style_linebr, linewidth=1)

bgcolor(in_long  ? color.new(color.teal, 95) : na, title="Long background")
bgcolor(in_short ? color.new(color.red,  97) : na, title="Short background")

// ---- Markers ----------------------------------------------------------------
plotshape(sig_long,           title="Long Signal",  style=shape.circle,        location=location.belowbar, color=color.new(color.teal,   0), size=size.tiny)
plotshape(sig_short,          title="Short Signal", style=shape.circle,        location=location.abovebar, color=color.new(color.orange, 0), size=size.tiny)
plotshape(just_long,          title="Long Entry",   style=shape.triangleup,    location=location.belowbar, color=color.new(color.green,  0), size=size.small)
plotshape(just_short,         title="Short Entry",  style=shape.triangledown,  location=location.abovebar, color=color.new(color.red,    0), size=size.small)
plotshape(do_sl and was_long,  title="SL Exit Long",  style=shape.xcross,      location=location.belowbar, color=color.new(color.red,   0), size=size.small)
plotshape(do_sl and was_short, title="SL Exit Short", style=shape.xcross,      location=location.abovebar, color=color.new(color.red,   0), size=size.small)
plotshape(do_tp and was_long,  title="TP Exit Long",  style=shape.labelup,     location=location.belowbar, color=color.new(color.green, 0), size=size.small)
plotshape(do_tp and was_short, title="TP Exit Short", style=shape.labeldown,   location=location.abovebar, color=color.new(color.green, 0), size=size.small)
plotshape(do_bb and was_long,  title="BB_UP Exit",    style=shape.triangledown, location=location.abovebar, color=color.new(color.teal,  0), size=size.small)
plotshape(do_bb and was_short, title="BB_DN Exit",    style=shape.triangleup,  location=location.belowbar, color=color.new(color.teal,  0), size=size.small)
````
