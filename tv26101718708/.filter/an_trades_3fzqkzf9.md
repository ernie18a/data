# AN Trades

- url: https://www.tradingview.com/script/3FZqkzF9-AN-Trades/
- type: indicator
- pine_id: PUB;0db7f47d932543668b9fbac16f85435f
- version: 2.0

## Description

**AN Trades — Entry Signal Indicator**

A Smart Money / ICT-based entry signal indicator that plots a **BUY** or **SELL** arrow only when a full confluence of conditions is met. It does not repaint — signals fire on the close of the confirming bar.

---

**How a signal triggers (all must be true simultaneously):**

1. **Liquidity Sweep** — Price wicks below a recent swing low (for longs) or above a recent swing high (for shorts) and closes back through it, indicating a manipulation / stop hunt

2. **IFVG (Inverted Fair Value Gap)** — A previously bullish/bearish FVG has been invaded and closed through, flipping it into an IFVG. Price must be entering or touching that zone at signal time

3. **CISD (Change in State of Delivery)** — Price closes through the open of a prior delivery candle in the opposite direction, confirming a shift in order flow

4. **Manipulation Leg Invalidation** — If after the sweep, price closes back through the swept level again (taking out the swing that caused the manipulation), the trade is blocked — the setup has failed

---

**Optional filters (toggleable):**

- **SMT Divergence** — One correlated instrument (default NQ) makes a new high/low while the other fails to, confirming institutional divergence
- **Opposing DOL** — Blocks the trade if the nearest liquidity in the opposite direction is closer than the target
- **Data Wick** — Blocks the trade if an abnormally large wick (news spike / algo wick) is present in the opposing direction
- **HTF Bias** — Tracks the higher timeframe FVG direction; used internally for context

## Source Code

````pine

// This Pine Script® code is subject to the Mozilla Public License 2.0
// © AN Trades — Entry Signal Indicator
//@version=6
indicator("AN Trades", shorttitle="AN Trades", overlay=true)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════
var G1 = "── HTF Bias ──"
htf_tf = input.timeframe("60", "HTF Bias Timeframe", group=G1)

var G2 = "── Entry Filters ──"
require_cisd = input.bool(true,  "Require CISD",                             group=G2)
require_smt  = input.bool(false, "Require SMT",                              group=G2)
smt_sym      = input.symbol("NQ1!", "SMT Symbol",                            group=G2)
smt_len      = input.int(5, "SMT Lookback", minval=2, maxval=30,             group=G2)
filter_dol   = input.bool(true,  "Block if opposing DOL nearby",             group=G2)
filter_wick  = input.bool(true,  "Block on opposing data wick",              group=G2)
wick_mult    = input.float(2.5,  "Data Wick Threshold", minval=1.0, step=0.5, group=G2)
filter_manip = input.bool(true,  "Block if manip sweep level taken out",     group=G2)

var G3 = "── Structure ──"
swing_len  = input.int(10, "Swing Lookback",     minval=3, maxval=50, group=G3)
sweep_bars = input.int(10, "Sweep Valid (bars)", minval=1, maxval=50, group=G3)

// ═══════════════════════════════════════════════════════════════════════════
// HTF BIAS
// ═══════════════════════════════════════════════════════════════════════════
htf_h0 = request.security(syminfo.tickerid, htf_tf, high,      lookahead=barmerge.lookahead_off)
htf_l0 = request.security(syminfo.tickerid, htf_tf, low,       lookahead=barmerge.lookahead_off)
htf_h2 = request.security(syminfo.tickerid, htf_tf, high[2],   lookahead=barmerge.lookahead_off)
htf_l2 = request.security(syminfo.tickerid, htf_tf, low[2],    lookahead=barmerge.lookahead_off)
htf_bi = request.security(syminfo.tickerid, htf_tf, bar_index, lookahead=barmerge.lookahead_off)

new_htf = ta.change(htf_bi) != 0

var int htf_bias = 0
if new_htf and htf_h2 < htf_l0
    htf_bias := 1
if new_htf and htf_l2 > htf_h0
    htf_bias := -1

// ═══════════════════════════════════════════════════════════════════════════
// HIGHER TF FVG ZONE TRACKING  (5m · 15m · 30m · 1hr · 4hr)
// Fixed timeframes — signals are consistent regardless of chart TF
// Zone = area between high[2] and low[0] (bull) or low[2] and high[0] (bear)
// Invalidated when price closes fully through
// ═══════════════════════════════════════════════════════════════════════════
tf5_h0   = request.security(syminfo.tickerid, "5",   high,      lookahead=barmerge.lookahead_off)
tf5_l0   = request.security(syminfo.tickerid, "5",   low,       lookahead=barmerge.lookahead_off)
tf5_h2   = request.security(syminfo.tickerid, "5",   high[2],   lookahead=barmerge.lookahead_off)
tf5_l2   = request.security(syminfo.tickerid, "5",   low[2],    lookahead=barmerge.lookahead_off)
tf5_bi   = request.security(syminfo.tickerid, "5",   bar_index, lookahead=barmerge.lookahead_off)

tf15_h0  = request.security(syminfo.tickerid, "15",  high,      lookahead=barmerge.lookahead_off)
tf15_l0  = request.security(syminfo.tickerid, "15",  low,       lookahead=barmerge.lookahead_off)
tf15_h2  = request.security(syminfo.tickerid, "15",  high[2],   lookahead=barmerge.lookahead_off)
tf15_l2  = request.security(syminfo.tickerid, "15",  low[2],    lookahead=barmerge.lookahead_off)
tf15_bi  = request.security(syminfo.tickerid, "15",  bar_index, lookahead=barmerge.lookahead_off)

tf30_h0  = request.security(syminfo.tickerid, "30",  high,      lookahead=barmerge.lookahead_off)
tf30_l0  = request.security(syminfo.tickerid, "30",  low,       lookahead=barmerge.lookahead_off)
tf30_h2  = request.security(syminfo.tickerid, "30",  high[2],   lookahead=barmerge.lookahead_off)
tf30_l2  = request.security(syminfo.tickerid, "30",  low[2],    lookahead=barmerge.lookahead_off)
tf30_bi  = request.security(syminfo.tickerid, "30",  bar_index, lookahead=barmerge.lookahead_off)

tf60_h0  = request.security(syminfo.tickerid, "60",  high,      lookahead=barmerge.lookahead_off)
tf60_l0  = request.security(syminfo.tickerid, "60",  low,       lookahead=barmerge.lookahead_off)
tf60_h2  = request.security(syminfo.tickerid, "60",  high[2],   lookahead=barmerge.lookahead_off)
tf60_l2  = request.security(syminfo.tickerid, "60",  low[2],    lookahead=barmerge.lookahead_off)
tf60_bi  = request.security(syminfo.tickerid, "60",  bar_index, lookahead=barmerge.lookahead_off)

tf240_h0 = request.security(syminfo.tickerid, "240", high,      lookahead=barmerge.lookahead_off)
tf240_l0 = request.security(syminfo.tickerid, "240", low,       lookahead=barmerge.lookahead_off)
tf240_h2 = request.security(syminfo.tickerid, "240", high[2],   lookahead=barmerge.lookahead_off)
tf240_l2 = request.security(syminfo.tickerid, "240", low[2],    lookahead=barmerge.lookahead_off)
tf240_bi = request.security(syminfo.tickerid, "240", bar_index, lookahead=barmerge.lookahead_off)

tf5_new   = ta.change(tf5_bi)   != 0
tf15_new  = ta.change(tf15_bi)  != 0
tf30_new  = ta.change(tf30_bi)  != 0
tf60_new  = ta.change(tf60_bi)  != 0
tf240_new = ta.change(tf240_bi) != 0

// ── HTF FVG zone state (most recent bull + bear per TF) ──
var float htf5_bull_top   = na,  var float htf5_bull_bot   = na
var float htf5_bear_top   = na,  var float htf5_bear_bot   = na
var float htf15_bull_top  = na,  var float htf15_bull_bot  = na
var float htf15_bear_top  = na,  var float htf15_bear_bot  = na
var float htf30_bull_top  = na,  var float htf30_bull_bot  = na
var float htf30_bear_top  = na,  var float htf30_bear_bot  = na
var float htf60_bull_top  = na,  var float htf60_bull_bot  = na
var float htf60_bear_top  = na,  var float htf60_bear_bot  = na
var float htf240_bull_top = na,  var float htf240_bull_bot = na
var float htf240_bear_top = na,  var float htf240_bear_bot = na

// ── Detect and store new HTF FVGs ──
if tf5_new
    if tf5_h2 < tf5_l0
        htf5_bull_top := tf5_l0
        htf5_bull_bot := tf5_h2
    if tf5_l2 > tf5_h0
        htf5_bear_top := tf5_l2
        htf5_bear_bot := tf5_h0

if tf15_new
    if tf15_h2 < tf15_l0
        htf15_bull_top := tf15_l0
        htf15_bull_bot := tf15_h2
    if tf15_l2 > tf15_h0
        htf15_bear_top := tf15_l2
        htf15_bear_bot := tf15_h0

if tf30_new
    if tf30_h2 < tf30_l0
        htf30_bull_top := tf30_l0
        htf30_bull_bot := tf30_h2
    if tf30_l2 > tf30_h0
        htf30_bear_top := tf30_l2
        htf30_bear_bot := tf30_h0

if tf60_new
    if tf60_h2 < tf60_l0
        htf60_bull_top := tf60_l0
        htf60_bull_bot := tf60_h2
    if tf60_l2 > tf60_h0
        htf60_bear_top := tf60_l2
        htf60_bear_bot := tf60_h0

if tf240_new
    if tf240_h2 < tf240_l0
        htf240_bull_top := tf240_l0
        htf240_bull_bot := tf240_h2
    if tf240_l2 > tf240_h0
        htf240_bear_top := tf240_l2
        htf240_bear_bot := tf240_h0

// ── Invalidate HTF FVG zones when price closes through ──
if not na(htf5_bull_top)   and close > htf5_bull_top
    htf5_bull_top   := na,  htf5_bull_bot   := na
if not na(htf5_bear_bot)   and close < htf5_bear_bot
    htf5_bear_top   := na,  htf5_bear_bot   := na
if not na(htf15_bull_top)  and close > htf15_bull_top
    htf15_bull_top  := na,  htf15_bull_bot  := na
if not na(htf15_bear_bot)  and close < htf15_bear_bot
    htf15_bear_top  := na,  htf15_bear_bot  := na
if not na(htf30_bull_top)  and close > htf30_bull_top
    htf30_bull_top  := na,  htf30_bull_bot  := na
if not na(htf30_bear_bot)  and close < htf30_bear_bot
    htf30_bear_top  := na,  htf30_bear_bot  := na
if not na(htf60_bull_top)  and close > htf60_bull_top
    htf60_bull_top  := na,  htf60_bull_bot  := na
if not na(htf60_bear_bot)  and close < htf60_bear_bot
    htf60_bear_top  := na,  htf60_bear_bot  := na
if not na(htf240_bull_top) and close > htf240_bull_top
    htf240_bull_top := na,  htf240_bull_bot := na
if not na(htf240_bear_bot) and close < htf240_bear_bot
    htf240_bear_top := na,  htf240_bear_bot := na

// ── Is price touching any HTF FVG zone? ──
price_in_htf_bull =
     (not na(htf5_bull_top)   and low <= htf5_bull_top   and high >= htf5_bull_bot)   or
     (not na(htf15_bull_top)  and low <= htf15_bull_top  and high >= htf15_bull_bot)  or
     (not na(htf30_bull_top)  and low <= htf30_bull_top  and high >= htf30_bull_bot)  or
     (not na(htf60_bull_top)  and low <= htf60_bull_top  and high >= htf60_bull_bot)  or
     (not na(htf240_bull_top) and low <= htf240_bull_top and high >= htf240_bull_bot)

price_in_htf_bear =
     (not na(htf5_bear_top)   and high >= htf5_bear_bot   and low <= htf5_bear_top)   or
     (not na(htf15_bear_top)  and high >= htf15_bear_bot  and low <= htf15_bear_top)  or
     (not na(htf30_bear_top)  and high >= htf30_bear_bot  and low <= htf30_bear_top)  or
     (not na(htf60_bear_top)  and high >= htf60_bear_bot  and low <= htf60_bear_top)  or
     (not na(htf240_bear_top) and high >= htf240_bear_bot and low <= htf240_bear_top)

// ═══════════════════════════════════════════════════════════════════════════
// LOWER TF IFVG TRACKING  (30s · 1m · 2m · 3m · 5m)
// Tracks FVG inversions — when a FVG gets invaded and closes through it
// flips into an IFVG entry zone
// ═══════════════════════════════════════════════════════════════════════════
ltf30s_h0 = request.security(syminfo.tickerid, "30S", high,      lookahead=barmerge.lookahead_off)
ltf30s_l0 = request.security(syminfo.tickerid, "30S", low,       lookahead=barmerge.lookahead_off)
ltf30s_h2 = request.security(syminfo.tickerid, "30S", high[2],   lookahead=barmerge.lookahead_off)
ltf30s_l2 = request.security(syminfo.tickerid, "30S", low[2],    lookahead=barmerge.lookahead_off)
ltf30s_bi = request.security(syminfo.tickerid, "30S", bar_index, lookahead=barmerge.lookahead_off)

ltf1_h0   = request.security(syminfo.tickerid, "1",   high,      lookahead=barmerge.lookahead_off)
ltf1_l0   = request.security(syminfo.tickerid, "1",   low,       lookahead=barmerge.lookahead_off)
ltf1_h2   = request.security(syminfo.tickerid, "1",   high[2],   lookahead=barmerge.lookahead_off)
ltf1_l2   = request.security(syminfo.tickerid, "1",   low[2],    lookahead=barmerge.lookahead_off)
ltf1_bi   = request.security(syminfo.tickerid, "1",   bar_index, lookahead=barmerge.lookahead_off)

ltf2_h0   = request.security(syminfo.tickerid, "2",   high,      lookahead=barmerge.lookahead_off)
ltf2_l0   = request.security(syminfo.tickerid, "2",   low,       lookahead=barmerge.lookahead_off)
ltf2_h2   = request.security(syminfo.tickerid, "2",   high[2],   lookahead=barmerge.lookahead_off)
ltf2_l2   = request.security(syminfo.tickerid, "2",   low[2],    lookahead=barmerge.lookahead_off)
ltf2_bi   = request.security(syminfo.tickerid, "2",   bar_index, lookahead=barmerge.lookahead_off)

ltf3_h0   = request.security(syminfo.tickerid, "3",   high,      lookahead=barmerge.lookahead_off)
ltf3_l0   = request.security(syminfo.tickerid, "3",   low,       lookahead=barmerge.lookahead_off)
ltf3_h2   = request.security(syminfo.tickerid, "3",   high[2],   lookahead=barmerge.lookahead_off)
ltf3_l2   = request.security(syminfo.tickerid, "3",   low[2],    lookahead=barmerge.lookahead_off)
ltf3_bi   = request.security(syminfo.tickerid, "3",   bar_index, lookahead=barmerge.lookahead_off)

ltf5_h0   = request.security(syminfo.tickerid, "5",   high,      lookahead=barmerge.lookahead_off)
ltf5_l0   = request.security(syminfo.tickerid, "5",   low,       lookahead=barmerge.lookahead_off)
ltf5_h2   = request.security(syminfo.tickerid, "5",   high[2],   lookahead=barmerge.lookahead_off)
ltf5_l2   = request.security(syminfo.tickerid, "5",   low[2],    lookahead=barmerge.lookahead_off)
ltf5_bi   = request.security(syminfo.tickerid, "5",   bar_index, lookahead=barmerge.lookahead_off)

ltf30s_new = ta.change(ltf30s_bi) != 0
ltf1_new   = ta.change(ltf1_bi)   != 0
ltf2_new   = ta.change(ltf2_bi)   != 0
ltf3_new   = ta.change(ltf3_bi)   != 0
ltf5_new   = ta.change(ltf5_bi)   != 0

// ── Lower TF FVG state (pending inversion) ──
var float l30s_bfvg_top = na,  var float l30s_bfvg_bot = na
var float l30s_sfvg_top = na,  var float l30s_sfvg_bot = na
var float l1_bfvg_top   = na,  var float l1_bfvg_bot   = na
var float l1_sfvg_top   = na,  var float l1_sfvg_bot   = na
var float l2_bfvg_top   = na,  var float l2_bfvg_bot   = na
var float l2_sfvg_top   = na,  var float l2_sfvg_bot   = na
var float l3_bfvg_top   = na,  var float l3_bfvg_bot   = na
var float l3_sfvg_top   = na,  var float l3_sfvg_bot   = na
var float l5_bfvg_top   = na,  var float l5_bfvg_bot   = na
var float l5_sfvg_top   = na,  var float l5_sfvg_bot   = na

// ── Lower TF IFVG zones (after inversion) ──
var float l30s_bifvg_top = na,  var float l30s_bifvg_bot = na
var float l30s_sifvg_top = na,  var float l30s_sifvg_bot = na
var float l1_bifvg_top   = na,  var float l1_bifvg_bot   = na
var float l1_sifvg_top   = na,  var float l1_sifvg_bot   = na
var float l2_bifvg_top   = na,  var float l2_bifvg_bot   = na
var float l2_sifvg_top   = na,  var float l2_sifvg_bot   = na
var float l3_bifvg_top   = na,  var float l3_bifvg_bot   = na
var float l3_sifvg_top   = na,  var float l3_sifvg_bot   = na
var float l5_bifvg_top   = na,  var float l5_bifvg_bot   = na
var float l5_sifvg_top   = na,  var float l5_sifvg_bot   = na

// ── Detect new FVGs on lower TFs ──
if ltf30s_new
    if ltf30s_h2 < ltf30s_l0
        l30s_bfvg_top := ltf30s_l0,  l30s_bfvg_bot := ltf30s_h2
    if ltf30s_l2 > ltf30s_h0
        l30s_sfvg_top := ltf30s_l2,  l30s_sfvg_bot := ltf30s_h0

if ltf1_new
    if ltf1_h2 < ltf1_l0
        l1_bfvg_top := ltf1_l0,  l1_bfvg_bot := ltf1_h2
    if ltf1_l2 > ltf1_h0
        l1_sfvg_top := ltf1_l2,  l1_sfvg_bot := ltf1_h0

if ltf2_new
    if ltf2_h2 < ltf2_l0
        l2_bfvg_top := ltf2_l0,  l2_bfvg_bot := ltf2_h2
    if ltf2_l2 > ltf2_h0
        l2_sfvg_top := ltf2_l2,  l2_sfvg_bot := ltf2_h0

if ltf3_new
    if ltf3_h2 < ltf3_l0
        l3_bfvg_top := ltf3_l0,  l3_bfvg_bot := ltf3_h2
    if ltf3_l2 > ltf3_h0
        l3_sfvg_top := ltf3_l2,  l3_sfvg_bot := ltf3_h0

if ltf5_new
    if ltf5_h2 < ltf5_l0
        l5_bfvg_top := ltf5_l0,  l5_bfvg_bot := ltf5_h2
    if ltf5_l2 > ltf5_h0
        l5_sfvg_top := ltf5_l2,  l5_sfvg_bot := ltf5_h0

// ── Process FVG inversions → create IFVG zones ──
// Bull FVG invaded and closes below bot → bearish IFVG
// Bull FVG close above top → fully mitigated, discard
// Bear FVG invaded and closes above top → bullish IFVG
// Bear FVG close below bot → fully mitigated, discard

// 30s
if not na(l30s_bfvg_top) and high >= l30s_bfvg_bot and low <= l30s_bfvg_top
    if close < l30s_bfvg_bot
        l30s_sifvg_top := l30s_bfvg_top,  l30s_sifvg_bot := l30s_bfvg_bot
        l30s_bfvg_top  := na,              l30s_bfvg_bot  := na
    else if close > l30s_bfvg_top
        l30s_bfvg_top := na,  l30s_bfvg_bot := na
if not na(l30s_sfvg_top) and high >= l30s_sfvg_bot and low <= l30s_sfvg_top
    if close > l30s_sfvg_top
        l30s_bifvg_top := l30s_sfvg_top,  l30s_bifvg_bot := l30s_sfvg_bot
        l30s_sfvg_top  := na,              l30s_sfvg_bot  := na
    else if close < l30s_sfvg_bot
        l30s_sfvg_top := na,  l30s_sfvg_bot := na

// 1m
if not na(l1_bfvg_top) and high >= l1_bfvg_bot and low <= l1_bfvg_top
    if close < l1_bfvg_bot
        l1_sifvg_top := l1_bfvg_top,  l1_sifvg_bot := l1_bfvg_bot
        l1_bfvg_top  := na,            l1_bfvg_bot  := na
    else if close > l1_bfvg_top
        l1_bfvg_top := na,  l1_bfvg_bot := na
if not na(l1_sfvg_top) and high >= l1_sfvg_bot and low <= l1_sfvg_top
    if close > l1_sfvg_top
        l1_bifvg_top := l1_sfvg_top,  l1_bifvg_bot := l1_sfvg_bot
        l1_sfvg_top  := na,            l1_sfvg_bot  := na
    else if close < l1_sfvg_bot
        l1_sfvg_top := na,  l1_sfvg_bot := na

// 2m
if not na(l2_bfvg_top) and high >= l2_bfvg_bot and low <= l2_bfvg_top
    if close < l2_bfvg_bot
        l2_sifvg_top := l2_bfvg_top,  l2_sifvg_bot := l2_bfvg_bot
        l2_bfvg_top  := na,            l2_bfvg_bot  := na
    else if close > l2_bfvg_top
        l2_bfvg_top := na,  l2_bfvg_bot := na
if not na(l2_sfvg_top) and high >= l2_sfvg_bot and low <= l2_sfvg_top
    if close > l2_sfvg_top
        l2_bifvg_top := l2_sfvg_top,  l2_bifvg_bot := l2_sfvg_bot
        l2_sfvg_top  := na,            l2_sfvg_bot  := na
    else if close < l2_sfvg_bot
        l2_sfvg_top := na,  l2_sfvg_bot := na

// 3m
if not na(l3_bfvg_top) and high >= l3_bfvg_bot and low <= l3_bfvg_top
    if close < l3_bfvg_bot
        l3_sifvg_top := l3_bfvg_top,  l3_sifvg_bot := l3_bfvg_bot
        l3_bfvg_top  := na,            l3_bfvg_bot  := na
    else if close > l3_bfvg_top
        l3_bfvg_top := na,  l3_bfvg_bot := na
if not na(l3_sfvg_top) and high >= l3_sfvg_bot and low <= l3_sfvg_top
    if close > l3_sfvg_top
        l3_bifvg_top := l3_sfvg_top,  l3_bifvg_bot := l3_sfvg_bot
        l3_sfvg_top  := na,            l3_sfvg_bot  := na
    else if close < l3_sfvg_bot
        l3_sfvg_top := na,  l3_sfvg_bot := na

// 5m
if not na(l5_bfvg_top) and high >= l5_bfvg_bot and low <= l5_bfvg_top
    if close < l5_bfvg_bot
        l5_sifvg_top := l5_bfvg_top,  l5_sifvg_bot := l5_bfvg_bot
        l5_bfvg_top  := na,            l5_bfvg_bot  := na
    else if close > l5_bfvg_top
        l5_bfvg_top := na,  l5_bfvg_bot := na
if not na(l5_sfvg_top) and high >= l5_sfvg_bot and low <= l5_sfvg_top
    if close > l5_sfvg_top
        l5_bifvg_top := l5_sfvg_top,  l5_bifvg_bot := l5_sfvg_bot
        l5_sfvg_top  := na,            l5_sfvg_bot  := na
    else if close < l5_sfvg_bot
        l5_sfvg_top := na,  l5_sfvg_bot := na

// ── Invalidate IFVG zones when fully mitigated ──
if not na(l30s_bifvg_top) and close > l30s_bifvg_top
    l30s_bifvg_top := na,  l30s_bifvg_bot := na
if not na(l30s_sifvg_bot) and close < l30s_sifvg_bot
    l30s_sifvg_top := na,  l30s_sifvg_bot := na
if not na(l1_bifvg_top) and close > l1_bifvg_top
    l1_bifvg_top := na,  l1_bifvg_bot := na
if not na(l1_sifvg_bot) and close < l1_sifvg_bot
    l1_sifvg_top := na,  l1_sifvg_bot := na
if not na(l2_bifvg_top) and close > l2_bifvg_top
    l2_bifvg_top := na,  l2_bifvg_bot := na
if not na(l2_sifvg_bot) and close < l2_sifvg_bot
    l2_sifvg_top := na,  l2_sifvg_bot := na
if not na(l3_bifvg_top) and close > l3_bifvg_top
    l3_bifvg_top := na,  l3_bifvg_bot := na
if not na(l3_sifvg_bot) and close < l3_sifvg_bot
    l3_sifvg_top := na,  l3_sifvg_bot := na
if not na(l5_bifvg_top) and close > l5_bifvg_top
    l5_bifvg_top := na,  l5_bifvg_bot := na
if not na(l5_sifvg_bot) and close < l5_sifvg_bot
    l5_sifvg_top := na,  l5_sifvg_bot := na

// ── Is price touching any lower TF IFVG? ──
price_in_bull_ifvg =
     (not na(l30s_bifvg_top) and low <= l30s_bifvg_top and high >= l30s_bifvg_bot) or
     (not na(l1_bifvg_top)   and low <= l1_bifvg_top   and high >= l1_bifvg_bot)   or
     (not na(l2_bifvg_top)   and low <= l2_bifvg_top   and high >= l2_bifvg_bot)   or
     (not na(l3_bifvg_top)   and low <= l3_bifvg_top   and high >= l3_bifvg_bot)   or
     (not na(l5_bifvg_top)   and low <= l5_bifvg_top   and high >= l5_bifvg_bot)

price_in_bear_ifvg =
     (not na(l30s_sifvg_top) and high >= l30s_sifvg_bot and low <= l30s_sifvg_top) or
     (not na(l1_sifvg_top)   and high >= l1_sifvg_bot   and low <= l1_sifvg_top)   or
     (not na(l2_sifvg_top)   and high >= l2_sifvg_bot   and low <= l2_sifvg_top)   or
     (not na(l3_sifvg_top)   and high >= l3_sifvg_bot   and low <= l3_sifvg_top)   or
     (not na(l5_sifvg_top)   and high >= l5_sifvg_bot   and low <= l5_sifvg_top)

// ═══════════════════════════════════════════════════════════════════════════
// LIQUIDITY SWEEP
// ═══════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow(low,  swing_len, swing_len)

var float last_ph = na
var float last_pl = na
if not na(ph)
    last_ph := ph
if not na(pl)
    last_pl := pl

bearish_sweep = not na(last_ph) and high > last_ph and close < last_ph
bullish_sweep = not na(last_pl) and low  < last_pl and close > last_pl

var int bars_since_bull_sweep = 999
var int bars_since_bear_sweep = 999
if bullish_sweep
    bars_since_bull_sweep := 0
else
    bars_since_bull_sweep += 1
if bearish_sweep
    bars_since_bear_sweep := 0
else
    bars_since_bear_sweep += 1

recent_bull_sweep = bars_since_bull_sweep <= sweep_bars
recent_bear_sweep = bars_since_bear_sweep <= sweep_bars

// ═══════════════════════════════════════════════════════════════════════════
// MANIPULATION LEG INVALIDATION
// ═══════════════════════════════════════════════════════════════════════════
var float manip_swept_low     = na
var float manip_swept_high    = na
var bool  manip_long_invalid  = false
var bool  manip_short_invalid = false

if bullish_sweep
    manip_swept_low    := last_pl
    manip_long_invalid := false
if bearish_sweep
    manip_swept_high    := last_ph
    manip_short_invalid := false

if filter_manip and not na(manip_swept_low)  and close < manip_swept_low
    manip_long_invalid := true
if filter_manip and not na(manip_swept_high) and close > manip_swept_high
    manip_short_invalid := true

// ═══════════════════════════════════════════════════════════════════════════
// DOL
// ═══════════════════════════════════════════════════════════════════════════
var float[] dol_highs = array.new_float()
var float[] dol_lows  = array.new_float()

if not na(ph)
    if array.size(dol_highs) >= 5
        array.shift(dol_highs)
    array.push(dol_highs, ph)
if not na(pl)
    if array.size(dol_lows) >= 5
        array.shift(dol_lows)
    array.push(dol_lows, pl)

var float nearest_dol_up   = na
var float nearest_dol_down = na
nearest_dol_up   := na
nearest_dol_down := na

for i = array.size(dol_highs) - 1 to 0
    if i < 0 or i >= array.size(dol_highs)
        break
    lvl = array.get(dol_highs, i)
    if lvl > close
        if na(nearest_dol_up) or lvl < nearest_dol_up
            nearest_dol_up := lvl

for i = array.size(dol_lows) - 1 to 0
    if i < 0 or i >= array.size(dol_lows)
        break
    lvl = array.get(dol_lows, i)
    if lvl < close
        if na(nearest_dol_down) or lvl > nearest_dol_down
            nearest_dol_down := lvl

dol_dist_up   = not na(nearest_dol_up)   ? nearest_dol_up   - close : na
dol_dist_down = not na(nearest_dol_down) ? close - nearest_dol_down : na

opp_dol_long  = filter_dol and not na(dol_dist_up) and not na(dol_dist_down) and dol_dist_down < dol_dist_up
opp_dol_short = filter_dol and not na(dol_dist_up) and not na(dol_dist_down) and dol_dist_up  < dol_dist_down

// ═══════════════════════════════════════════════════════════════════════════
// CISD
// ═══════════════════════════════════════════════════════════════════════════
body_sz  = math.abs(close - open)
bar_rng  = high - low
is_deliv = bar_rng > 0 and (body_sz / bar_rng) >= 0.3

var float last_bull_open = na
var float last_bear_open = na
if is_deliv
    if close > open
        last_bull_open := open
    if close < open
        last_bear_open := open

cisd_bear = not na(last_bull_open) and close < last_bull_open
cisd_bull = not na(last_bear_open) and close > last_bear_open
if cisd_bear
    last_bull_open := na
if cisd_bull
    last_bear_open := na

// ═══════════════════════════════════════════════════════════════════════════
// DATA WICK + SMT
// ═══════════════════════════════════════════════════════════════════════════
avg_rng = ta.atr(20)

block_long_wick  = filter_wick and (math.min(open, close) - low)  > avg_rng * wick_mult
block_short_wick = filter_wick and (high - math.max(open, close)) > avg_rng * wick_mult

smt_h = request.security(smt_sym, timeframe.period, high)
smt_l = request.security(smt_sym, timeframe.period, low)

high_hi = ta.highest(high,  smt_len)[1]
low_lo  = ta.lowest(low,    smt_len)[1]
smth_hi = ta.highest(smt_h, smt_len)[1]
smtl_lo = ta.lowest(smt_l,  smt_len)[1]

smt_bull_div = low  < low_lo  and smt_l > smtl_lo
smt_bear_div = high > high_hi and smt_h < smth_hi

// ═══════════════════════════════════════════════════════════════════════════
// SESSION HIGH / LOW
// Track daily high/low — price at these levels bypasses sweep requirement
// ═══════════════════════════════════════════════════════════════════════════
new_day = ta.change(time("D")) != 0

var float sess_high = na
var float sess_low  = na

// Check against previous accumulated value (before this bar updates it)
is_session_high = not na(sess_high) and high >= sess_high
is_session_low  = not na(sess_low)  and low  <= sess_low

if new_day
    sess_high := high
    sess_low  := low
else
    sess_high := na(sess_high) ? high : math.max(sess_high, high)
    sess_low  := na(sess_low)  ? low  : math.min(sess_low, low)

// ═══════════════════════════════════════════════════════════════════════════
// ENTRY SIGNALS
// Sweep requirement:
//   - NOT required when HTF FVG tap is present (price_in_htf_bull/bear)
//   - NOT required when price is at a session extreme (session high/low)
//   - Required only when trading the IFVG alone with no HTF confluence
// ═══════════════════════════════════════════════════════════════════════════
ifvg_long_ok  = price_in_bull_ifvg or price_in_htf_bull
ifvg_short_ok = price_in_bear_ifvg or price_in_htf_bear

sweep_ok_long  = recent_bull_sweep or price_in_htf_bull or is_session_low
sweep_ok_short = recent_bear_sweep or price_in_htf_bear or is_session_high

long_signal  = sweep_ok_long  and ifvg_long_ok  and (require_cisd ? cisd_bull : true) and (require_smt ? smt_bull_div : true) and not opp_dol_long  and not block_long_wick  and not manip_long_invalid
short_signal = sweep_ok_short and ifvg_short_ok and (require_cisd ? cisd_bear : true) and (require_smt ? smt_bear_div : true) and not opp_dol_short and not block_short_wick and not manip_short_invalid

plotshape(long_signal,  "LONG",  shape.labelup,   location.belowbar, color=#00e676, size=size.normal, text="BUY",  textcolor=color.black)
plotshape(short_signal, "SHORT", shape.labeldown, location.abovebar, color=#ff1744, size=size.normal, text="SELL", textcolor=color.white)

alertcondition(long_signal,  "LONG ENTRY - AN Trades",  "BUY signal fired.")
alertcondition(short_signal, "SHORT ENTRY - AN Trades", "SELL signal fired.")
````
