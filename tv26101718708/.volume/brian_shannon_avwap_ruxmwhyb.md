# Brian Shannon AVWAP 

- url: https://www.tradingview.com/script/RuxMwHYb-Brian-Shannon-AVWAP/
- type: indicator
- pine_id: PUB;89e7e79822a14780b25e2ba2f6c51c4f
- version: 1.0

## Description

Anchored VWAP framework based on Brian Shannon's (AlphaTrends) methodology. Plots AVWAPs from key anchor points: earnings event, swing low, swing high, and recent low. Includes EMA 5 as momentum trigger and No Man's Land zone between earnings and swing-high AVWAPs. Used for personal swing trade analysis on individual setups.

## Source Code

````pine
//@version=6
indicator("Brian Shannon AVWAP — Swing Setup", overlay=true, max_labels_count=50)

// ─────────────────────────────────────────────────────────────────────────────
// BRIAN SHANNON (AlphaTrends) ANCHORED VWAP FRAMEWORK
// Anchors matched to the current symbol's key events.
// Update anchor dates when switching symbols.
//
// PWR (Quanta Services) Anchors — identified from daily bar analysis:
//   • Earnings       — Apr 30, 2026  (gap-up, 2.4M vol ~2x avg — primary anchor)
//   • Swing Low      — Mar 31, 2026  (pre-earnings base low ~$522 — demand AVWAP)
//   • Swing High     — May  6, 2026  (post-run peak ~$788 — overhead supply)
//   • Recent Low     — May 19, 2026  (pullback low ~$690 — near-term demand)
//
// Rules (Shannon):
//   Long bias  → price above AVWAP from swing low  (buyers profitable)
//   Short bias → price below AVWAP from swing high (sellers profitable)
//   No trade   → price between those two lines ("No Man's Land")
//   Entry      → pullback TO the relevant AVWAP + volume confirm + EMA 5 holds
//   Stop       → just below the AVWAP you entered from
// ─────────────────────────────────────────────────────────────────────────────

// ── Anchor timestamps — update these when switching symbols ──────────────────
t_earnings  = timestamp("2026-04-30 09:30:00")  // Q1 2026 earnings — massive gap-up event
t_swing_lo  = timestamp("2026-03-31 09:30:00")  // Pre-earnings base low ~$522 — demand
t_swing_hi  = timestamp("2026-05-06 09:30:00")  // Post-run peak ~$788 — overhead supply
t_recent_lo = timestamp("2026-05-19 09:30:00")  // Pullback low ~$690 — near-term demand

// ── AVWAP calculations ────────────────────────────────────────────────────────
var float pv_e = 0.0,  var float v_e = 0.0
var float pv_sh = 0.0, var float v_sh = 0.0
var float pv_sl = 0.0, var float v_sl = 0.0
var float pv_rl = 0.0, var float v_rl = 0.0

if time >= t_earnings
    pv_e  += hlc3 * volume
    v_e   += volume
if time >= t_swing_hi
    pv_sh += hlc3 * volume
    v_sh  += volume
if time >= t_swing_lo
    pv_sl += hlc3 * volume
    v_sl  += volume
if time >= t_recent_lo
    pv_rl += hlc3 * volume
    v_rl  += volume

avwap_e  = v_e  > 0 ? pv_e  / v_e  : na
avwap_sh = v_sh > 0 ? pv_sh / v_sh : na
avwap_sl = v_sl > 0 ? pv_sl / v_sl : na
avwap_rl = v_rl > 0 ? pv_rl / v_rl : na

// ── EMA 5 — Shannon's momentum trigger ───────────────────────────────────────
ema5 = ta.ema(close, 5)

// ── Plots ─────────────────────────────────────────────────────────────────────
plot(avwap_sl, "AVWAP Sw.Low  Mar 31 '26",  color=color.new(color.lime,   0), linewidth=2)
plot(avwap_e,  "AVWAP Earnings Apr 30 '26", color=color.new(color.orange, 0), linewidth=2)
plot(avwap_sh, "AVWAP Sw.High May  6 '26",  color=color.new(color.red,    0), linewidth=2)
plot(avwap_rl, "AVWAP Recent Lo May 19",    color=color.new(color.aqua,   30), linewidth=1)
plot(ema5,     "EMA 5 (Shannon trigger)",    color=color.new(color.yellow, 0), linewidth=1)

// ── No Man's Land zone (between earnings AVWAP and swing-high AVWAP) ──────────
p_nml_top = plot(avwap_sh, display=display.none)
p_nml_bot = plot(avwap_e,  display=display.none)
fill(p_nml_top, p_nml_bot, color=color.new(color.gray, 88), title="No Man's Land")

// ── Bar color ─────────────────────────────────────────────────────────────────
bull = not na(avwap_e) and close > avwap_e  and close > avwap_sl
bear = not na(avwap_e) and close < avwap_e  and close < avwap_sl
barcolor(bull ? color.new(color.green, 65) : bear ? color.new(color.red, 65) : na)

// ── Live labels at right edge ─────────────────────────────────────────────────
if barstate.islast
    if not na(avwap_sl)
        label.new(bar_index + 1, avwap_sl, " AVWAP Sw.Low $"   + str.tostring(avwap_sl, "#.00"), color=color.new(color.lime,   15), textcolor=color.white, style=label.style_label_left, size=size.small)
    if not na(avwap_e)
        label.new(bar_index + 1, avwap_e,  " AVWAP Earnings $" + str.tostring(avwap_e,  "#.00"), color=color.new(color.orange, 15), textcolor=color.white, style=label.style_label_left, size=size.small)
    if not na(avwap_sh)
        label.new(bar_index + 1, avwap_sh, " AVWAP Sw.High $"  + str.tostring(avwap_sh, "#.00"), color=color.new(color.red,    15), textcolor=color.white, style=label.style_label_left, size=size.small)
    if not na(avwap_rl)
        label.new(bar_index + 1, avwap_rl, " AVWAP Rec.Low $"  + str.tostring(avwap_rl, "#.00"), color=color.new(color.aqua,   15), textcolor=color.white, style=label.style_label_left, size=size.small)
````
