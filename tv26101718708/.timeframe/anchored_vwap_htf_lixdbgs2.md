# Anchored VWAP (HTF)

- url: https://www.tradingview.com/script/lIxdBGs2-Anchored-VWAP-HTF/
- type: indicator
- pine_id: PUB;50a18a0d8bdb4e2a90c0087cc5763069
- version: 1.0

## Description

[b]Anchored VWAP (HTF Structural)[/b]

Anchored VWAPs computed from confirmed swing pivots on up to three higher timeframes, rendered on the current chart at full resolution. Each timeframe shows two slots — an active AVWAP from the most recent pivot and a faded AVWAP from the prior one — so you can see how volume-weighted commitment evolved through the previous structural phase and how it's evolving now. True cumulative standard deviation bands (±1σ, ±2σ) wrap the active AVWAP, computed via König's formula for numerical stability over long accumulations.
The point is to surface where volume-weighted price sits across structural horizons, anchored to the same pivot events that other tools in this collection use as reference points.

[b]How it works[/b]

For each of the three configured timeframes, the script runs swing-pivot detection inside request.security and emits a signal when a new bullish (pivot low) or bearish (pivot high) anchor is confirmed. The detection runs on the higher timeframe; the accumulation runs on the chart's own bars. This dual-resolution design means the AVWAP curves are smooth and scroll-stable rather than stepped, even though the anchors come from HTF structure.
When a new HTF pivot fires:[list]
[*]The current active slot's accumulators (Σpv, Σv, Σp²v) are demoted to the faded historical slot, preserving the prior anchor's curve for visual context.
[*]A fresh active slot opens at the new pivot's bar.[/list]
Accumulation uses three running sums per slot:
[pine]Σpv,  Σv,  Σp²v[/pine]

with p = hlc3, v = effective volume per bar. The AVWAP is Σpv / Σv. The true cumulative standard deviation is computed via König's formula:
[pine]σ = √( Σp²v / Σv − (Σpv / Σv)² )[/pine]

A new active anchor is marked mitigated when price closes on the wrong side of the anchor pivot — below a swing-low anchor for a bull case, above a swing-high anchor for a bear case. Mitigated active AVWAPs turn grey but continue accumulating; the visual cue tells you the structural premise of that AVWAP has been challenged.
For instruments where TradingView reports no real volume (forex), the script transparently falls back to TWAP (time-weighted average price) by treating each bar's volume as 1. A small "TWAP (volume N/A)" label appears at the chart's right edge so you know what's being plotted.

[b]How to read it[/b]

Each timeframe gets its own border weight (thin → medium → thick) so higher-TF AVWAPs visually dominate. Color carries direction:[list]
[*]Bullish anchor (default teal) — anchored to a swing low; treat as dynamic support
[*]Bearish anchor (default amber) — anchored to a swing high; treat as dynamic resistance
[*]Mitigated (grey) — active AVWAP whose anchor pivot has been violated
[*]Historical (faded, same hue) — the previous anchor's AVWAP, kept for context[/list]

Bands wrap the active AVWAP only:[list]
[*]±1σ — the central 68% of volume-weighted price activity since the anchor
[*]±2σ — the central 95%[/list]

When price is well outside the ±2σ band, it's trading meaningfully far from volume-weighted consensus formed since the anchor — typically a sign of either strong directional commitment (if the move is recent) or extension that may be due to revert.

Session VWAPs layer additional context:[list]
[*]Weekly VWAP (default indigo) with ±1σ / ±2σ bands — the calendar week's volume-weighted price
[*]NY Session VWAP (default magenta) with ±1σ band — useful on intraday charts during US trading hours[/list]

When multiple AVWAPs cluster at the same price — a 1H bullish AVWAP, a 4H bullish AVWAP, and the Weekly VWAP all sitting in the same region — that's volume-weighted confluence and tends to act as a stronger reference than any single line.

[b]Inputs[/b][list]
[*]HTF Pivot Length — bars required on each side to confirm a swing. Default 10.
[*]Timeframes 1/2/3 — defaults: 1H, 4H, Daily. TF1 and TF2 on; TF3 off by default.
[*]±1σ Band — show one-sigma bands on each active AVWAP. Default on.
[*]±2σ Band — show two-sigma bands. Default on.
[*]Weekly VWAP — show the calendar-week VWAP with its bands. Default on.
[*]NY Session VWAP — show the New York session VWAP with its bands. Default off (only meaningful on intraday charts).
[*]NY Session Hours — session string in exchange timezone. Default 0930-1600.
[*]Colors — bullish anchor, bearish anchor, weekly VWAP, NY session VWAP.[/list]

[b]Notes[/b]

The dual-resolution design (HTF anchor detection, chart-resolution accumulation) is the indicator's most important architectural choice. Most MTF AVWAP implementations either run everything on the higher timeframe (producing stepped, low-resolution curves) or run everything on the chart timeframe with a longer pivot length (sacrificing the structural meaning of the anchor). This script does both correctly: pivots are detected with full higher-timeframe authority via request.security, but the volume accumulation that defines the AVWAP runs on every chart bar. The result is smooth curves readable on any chart timeframe.
The two-slot rotation per timeframe is unusual but practically useful. When a new pivot fires, you don't immediately lose the prior AVWAP — it stays visible (faded) until the next pivot fires after that. During the early bars of a new anchor (when its AVWAP and bands are still establishing), you can still see where the previous anchor's curve sat and judge continuity between them. Once a third pivot fires, the original anchor finally drops off.
The cumulative standard deviation is true cumulative, not rolling. Most VWAP-band indicators on TradingView use a rolling stdev over a fixed window, which doesn't actually reflect volume-weighted dispersion since the anchor — it just shows recent volatility. The König-formula approach here computes the actual variance of volume-weighted price across every bar since the anchor, which is what you'd want for structural AVWAP analysis.
Mitigation here means something different from the SMC indicators in this collection. For OB / FVG / Liquidity Areas, "mitigated" means price has interacted with the zone — usually expected behavior. For AVWAP, "mitigated" means price has closed on the wrong side of the anchor pivot, which is a meaningful failure of the structural premise. A bullish AVWAP anchored at a swing low loses its supportive interpretation once price closes below that low. The grey coloring marks this without removing the AVWAP from the chart, since it's still informative as historical reference.
The TWAP fallback for forex is a small but practical touch. TradingView's volume data for FX is fabricated tick-count data, not real volume, so a strict VWAP calculation would be misleading. Reverting to time-weighted (treating volume as 1) gives an honest, useful average that doesn't pretend to represent volume-weighted commitment. The right-edge label makes the substitution explicit so you're not silently looking at the wrong thing.

Higher-timeframe pivots don't confirm until pivot length bars after the actual swing. On Daily with length 10, that's ten days of delay between the swing and the new anchor appearing. AVWAPs are non-repainting from the moment the anchor confirms.
This is a structural tool, not a signal generator. It marks where volume-weighted commitment sits across multiple horizons.

[i]Five years of work on a trading system left me with dozens of indicators that ultimately didn't earn a place in the final build. They're not failures — they're tools that solved problems I no longer needed solved. So instead of shelving them, I'm publishing the majority of them open-source.
If you're a discretionary trader, take what's useful. If you're a systems builder, the source is yours to dissect, modify, and improve. The best return on five years of work is for it to keep working — for someone.
If you use this script — or part of it — in your own work, please credit the original with a link back to my profile.
Note: these indicators have been updated to Pine Script v6 — some manually, some with AI assistance.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradeSymbiotic
// If you are using (part of) this PineScript - please give credits with tag.

// ─────────────────────────────────────────────────────────────────────────────
//                  Anchored VWAP (HTF Structural)
//                  ──────────────────────────────
//   Anchors VWAP to confirmed swing pivots on up to three higher timeframes,
//   rendering the resulting curves on the current chart. Two slots per
//   timeframe (active + one faded) show how commitment has evolved across
//   successive structural events.
//
//   HTF pivot detection fires via request.security; accumulation runs on the
//   current chart's bars for full resolution and scroll-stable rendering.
//   True cumulative standard deviation bands (±1σ / ±2σ) from König's formula.
//   Falls back to TWAP on symbols with no true volume.
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Anchored VWAP (HTF)", shorttitle="AVWAP HTF", overlay=true,
          max_lines_count=200, max_labels_count=50)

// ── Inputs ────────────────────────────────────────────────────────────────────
pivot_len = input.int(10, "HTF Pivot Length", minval=2, maxval=50, group="Detection",
              tooltip="Bars on each side of a swing to confirm it on the higher timeframe.")

tf1    = input.timeframe("60", "Timeframe 1", group="Timeframes")
tf2    = input.timeframe("240", "Timeframe 2", group="Timeframes")
tf3    = input.timeframe("D", "Timeframe 3", group="Timeframes")
tf1_on = input.bool(true,  "Show TF1", group="Timeframes")
tf2_on = input.bool(true,  "Show TF2", group="Timeframes")
tf3_on = input.bool(false, "Show TF3", group="Timeframes")

show_sd1   = input.bool(true,  "±1σ Band (active anchor)", group="Bands")
show_sd2   = input.bool(true,  "±2σ Band (active anchor)", group="Bands")

show_wvwap = input.bool(true,  "Weekly VWAP",     group="Session Lines")
show_dvwap = input.bool(false, "NY Session VWAP", group="Session Lines",
               tooltip="Only meaningful on intraday charts.")
ny_session = input.session("0930-1600", "NY Session Hours", group="Session Lines",
               tooltip="In exchange timezone. Default: regular US equity hours.")

bull_col  = input.color(#26a69a, "Bullish Anchor", group="Colors",
               tooltip="Swing-low anchors.")
bear_col  = input.color(#ff9800, "Bearish Anchor", group="Colors",
               tooltip="Swing-high anchors.")
wvwap_col = input.color(#5c6bc0, "Weekly VWAP",     group="Colors")
dvwap_col = input.color(#e91e63, "NY Session VWAP", group="Colors")

// ── HTF anchor detection (minimal — runs inside request.security) ─────────────
f_htf_detect(plen) =>
    ph = ta.pivothigh(high, plen, plen)
    pl = ta.pivotlow(low,  plen, plen)
    new_bull = not na(pl) and na(pl[1])
    new_bear = not na(ph) and na(ph[1]) and na(pl)
    anc_p    = new_bull ? pl : new_bear ? ph : float(na)
    [new_bull, new_bear, anc_p]

// ── HTF requests (3 values each — keeps series count low) ─────────────────────
[tf1_nb, tf1_ns, tf1_ap] = request.security(syminfo.tickerid, tf1,
     f_htf_detect(pivot_len), lookahead=barmerge.lookahead_off)
[tf2_nb, tf2_ns, tf2_ap] = request.security(syminfo.tickerid, tf2,
     f_htf_detect(pivot_len), lookahead=barmerge.lookahead_off)
[tf3_nb, tf3_ns, tf3_ap] = request.security(syminfo.tickerid, tf3,
     f_htf_detect(pivot_len), lookahead=barmerge.lookahead_off)

// ── Current-chart AVWAP accumulation ──────────────────────────────────────────
eff_vol = nz(volume, 1.0)
_p      = hlc3
_pv     = _p * eff_vol
_pv2    = _p * _p * eff_vol

// ── TF1 state ─────────────────────────────────────────────────────────────────
var float tf1_s0_pv   = 0.0
var float tf1_s0_v    = 0.0
var float tf1_s0_pv2  = 0.0
var bool  tf1_s0_bull = true
var float tf1_s0_ap   = na
var bool  tf1_s0_act  = false
var float tf1_s1_pv   = 0.0
var float tf1_s1_v    = 0.0
var float tf1_s1_pv2  = 0.0
var bool  tf1_s1_bull = true
var float tf1_s1_ap   = na
var bool  tf1_s1_act  = false

tf1_bfire = tf1_nb and not tf1_nb[1]
tf1_sfire = tf1_ns and not tf1_ns[1]
tf1_fire  = tf1_bfire or tf1_sfire

if tf1_fire
    tf1_s1_pv   := tf1_s0_pv
    tf1_s1_v    := tf1_s0_v
    tf1_s1_pv2  := tf1_s0_pv2
    tf1_s1_bull := tf1_s0_bull
    tf1_s1_ap   := tf1_s0_ap
    tf1_s1_act  := tf1_s0_act
    tf1_s0_pv   := 0.0
    tf1_s0_v    := 0.0
    tf1_s0_pv2  := 0.0
    tf1_s0_bull := tf1_bfire
    tf1_s0_ap   := tf1_ap
    tf1_s0_act  := true

if tf1_s0_act
    tf1_s0_pv  += _pv
    tf1_s0_v   += eff_vol
    tf1_s0_pv2 += _pv2
if tf1_s1_act
    tf1_s1_pv  += _pv
    tf1_s1_v   += eff_vol
    tf1_s1_pv2 += _pv2

tf1_v0 = tf1_s0_v > 0.0 ? tf1_s0_pv / tf1_s0_v : na
tf1_v1 = tf1_s1_v > 0.0 ? tf1_s1_pv / tf1_s1_v : na
tf1_d0 = tf1_s0_v > 0.0 ? math.sqrt(math.max(0.0, tf1_s0_pv2 / tf1_s0_v - tf1_v0 * tf1_v0)) : na

// ── TF2 state ─────────────────────────────────────────────────────────────────
var float tf2_s0_pv   = 0.0
var float tf2_s0_v    = 0.0
var float tf2_s0_pv2  = 0.0
var bool  tf2_s0_bull = true
var float tf2_s0_ap   = na
var bool  tf2_s0_act  = false
var float tf2_s1_pv   = 0.0
var float tf2_s1_v    = 0.0
var float tf2_s1_pv2  = 0.0
var bool  tf2_s1_bull = true
var float tf2_s1_ap   = na
var bool  tf2_s1_act  = false

tf2_bfire = tf2_nb and not tf2_nb[1]
tf2_sfire = tf2_ns and not tf2_ns[1]
tf2_fire  = tf2_bfire or tf2_sfire

if tf2_fire
    tf2_s1_pv   := tf2_s0_pv
    tf2_s1_v    := tf2_s0_v
    tf2_s1_pv2  := tf2_s0_pv2
    tf2_s1_bull := tf2_s0_bull
    tf2_s1_ap   := tf2_s0_ap
    tf2_s1_act  := tf2_s0_act
    tf2_s0_pv   := 0.0
    tf2_s0_v    := 0.0
    tf2_s0_pv2  := 0.0
    tf2_s0_bull := tf2_bfire
    tf2_s0_ap   := tf2_ap
    tf2_s0_act  := true

if tf2_s0_act
    tf2_s0_pv  += _pv
    tf2_s0_v   += eff_vol
    tf2_s0_pv2 += _pv2
if tf2_s1_act
    tf2_s1_pv  += _pv
    tf2_s1_v   += eff_vol
    tf2_s1_pv2 += _pv2

tf2_v0 = tf2_s0_v > 0.0 ? tf2_s0_pv / tf2_s0_v : na
tf2_v1 = tf2_s1_v > 0.0 ? tf2_s1_pv / tf2_s1_v : na
tf2_d0 = tf2_s0_v > 0.0 ? math.sqrt(math.max(0.0, tf2_s0_pv2 / tf2_s0_v - tf2_v0 * tf2_v0)) : na

// ── TF3 state ─────────────────────────────────────────────────────────────────
var float tf3_s0_pv   = 0.0
var float tf3_s0_v    = 0.0
var float tf3_s0_pv2  = 0.0
var bool  tf3_s0_bull = true
var float tf3_s0_ap   = na
var bool  tf3_s0_act  = false
var float tf3_s1_pv   = 0.0
var float tf3_s1_v    = 0.0
var float tf3_s1_pv2  = 0.0
var bool  tf3_s1_bull = true
var float tf3_s1_ap   = na
var bool  tf3_s1_act  = false

tf3_bfire = tf3_nb and not tf3_nb[1]
tf3_sfire = tf3_ns and not tf3_ns[1]
tf3_fire  = tf3_bfire or tf3_sfire

if tf3_fire
    tf3_s1_pv   := tf3_s0_pv
    tf3_s1_v    := tf3_s0_v
    tf3_s1_pv2  := tf3_s0_pv2
    tf3_s1_bull := tf3_s0_bull
    tf3_s1_ap   := tf3_s0_ap
    tf3_s1_act  := tf3_s0_act
    tf3_s0_pv   := 0.0
    tf3_s0_v    := 0.0
    tf3_s0_pv2  := 0.0
    tf3_s0_bull := tf3_bfire
    tf3_s0_ap   := tf3_ap
    tf3_s0_act  := true

if tf3_s0_act
    tf3_s0_pv  += _pv
    tf3_s0_v   += eff_vol
    tf3_s0_pv2 += _pv2
if tf3_s1_act
    tf3_s1_pv  += _pv
    tf3_s1_v   += eff_vol
    tf3_s1_pv2 += _pv2

tf3_v0 = tf3_s0_v > 0.0 ? tf3_s0_pv / tf3_s0_v : na
tf3_v1 = tf3_s1_v > 0.0 ? tf3_s1_pv / tf3_s1_v : na
tf3_d0 = tf3_s0_v > 0.0 ? math.sqrt(math.max(0.0, tf3_s0_pv2 / tf3_s0_v - tf3_v0 * tf3_v0)) : na

// ── Session VWAPs (current-chart resolution) ───────────────────────────────────
var float wv_pv  = 0.0
var float wv_v   = 0.0
var float wv_pv2 = 0.0
if ta.change(time("W")) != 0
    wv_pv  := 0.0
    wv_v   := 0.0
    wv_pv2 := 0.0
wv_pv  += _pv
wv_v   += eff_vol
wv_pv2 += _pv2
wvwap    = wv_v > 0.0 ? wv_pv / wv_v : na
wvwap_sd = wv_v > 0.0 ? math.sqrt(math.max(0.0, wv_pv2 / wv_v - wvwap * wvwap)) : na

in_ny   = not na(time("1D", ny_session))
var float dv_pv  = 0.0
var float dv_v   = 0.0
var float dv_pv2 = 0.0
if in_ny and not in_ny[1]
    dv_pv  := 0.0
    dv_v   := 0.0
    dv_pv2 := 0.0
if in_ny
    dv_pv  += _pv
    dv_v   += eff_vol
    dv_pv2 += _pv2
dvwap    = dv_v > 0.0 and in_ny ? dv_pv / dv_v : na
dvwap_sd = dv_v > 0.0 and in_ny ? math.sqrt(math.max(0.0, dv_pv2 / dv_v - dvwap * dvwap)) : na

// ── Mitigation color helper ───────────────────────────────────────────────────
f_acol(base, is_bull, anc_p, is_act) =>
    _mit = is_act and not na(anc_p) and (is_bull ? close < anc_p : close > anc_p)
    _mit ? color.new(#78909c, 65) : is_act ? color.new(base, 0) : color.new(base, 100)

// ── Per-slot colors ───────────────────────────────────────────────────────────
tf1_bc0  = tf1_s0_bull ? bull_col : bear_col
tf1_bc1  = tf1_s1_bull ? bull_col : bear_col
tf1_col0 = f_acol(tf1_bc0, tf1_s0_bull, tf1_s0_ap, tf1_s0_act)
tf1_col1 = tf1_s1_act ? color.new(tf1_bc1, 58) : color.new(tf1_bc1, 100)

tf2_bc0  = tf2_s0_bull ? bull_col : bear_col
tf2_bc1  = tf2_s1_bull ? bull_col : bear_col
tf2_col0 = f_acol(tf2_bc0, tf2_s0_bull, tf2_s0_ap, tf2_s0_act)
tf2_col1 = tf2_s1_act ? color.new(tf2_bc1, 58) : color.new(tf2_bc1, 100)

tf3_bc0  = tf3_s0_bull ? bull_col : bear_col
tf3_bc1  = tf3_s1_bull ? bull_col : bear_col
tf3_col0 = f_acol(tf3_bc0, tf3_s0_bull, tf3_s0_ap, tf3_s0_act)
tf3_col1 = tf3_s1_act ? color.new(tf3_bc1, 58) : color.new(tf3_bc1, 100)

// ── Plotting ──────────────────────────────────────────────────────────────────

// TF1
p_tf1_v0 = plot(tf1_on ? tf1_v0 : na, "TF1 AVWAP",    color=tf1_col0, linewidth=1)
p_tf1_v1 = plot(tf1_on ? tf1_v1 : na, "TF1 AVWAP H1", color=tf1_col1, linewidth=1)
p_tf1_u1 = plot((tf1_on and show_sd1) ? tf1_v0 + tf1_d0     : na, "TF1 +1σ", color=color.new(tf1_bc0, 50), linewidth=1)
p_tf1_l1 = plot((tf1_on and show_sd1) ? tf1_v0 - tf1_d0     : na, "TF1 -1σ", color=color.new(tf1_bc0, 50), linewidth=1)
p_tf1_u2 = plot((tf1_on and show_sd2) ? tf1_v0 + 2 * tf1_d0 : na, "TF1 +2σ", color=color.new(tf1_bc0, 68), linewidth=1)
p_tf1_l2 = plot((tf1_on and show_sd2) ? tf1_v0 - 2 * tf1_d0 : na, "TF1 -2σ", color=color.new(tf1_bc0, 68), linewidth=1)
fill(p_tf1_u1, p_tf1_l1, color=color.new(tf1_bc0, 88), title="TF1 ±1σ Fill")
fill(p_tf1_u2, p_tf1_l2, color=color.new(tf1_bc0, 94), title="TF1 ±2σ Fill")

// TF2
p_tf2_v0 = plot(tf2_on ? tf2_v0 : na, "TF2 AVWAP",    color=tf2_col0, linewidth=2)
p_tf2_v1 = plot(tf2_on ? tf2_v1 : na, "TF2 AVWAP H1", color=tf2_col1, linewidth=2)
p_tf2_u1 = plot((tf2_on and show_sd1) ? tf2_v0 + tf2_d0     : na, "TF2 +1σ", color=color.new(tf2_bc0, 50), linewidth=1)
p_tf2_l1 = plot((tf2_on and show_sd1) ? tf2_v0 - tf2_d0     : na, "TF2 -1σ", color=color.new(tf2_bc0, 50), linewidth=1)
p_tf2_u2 = plot((tf2_on and show_sd2) ? tf2_v0 + 2 * tf2_d0 : na, "TF2 +2σ", color=color.new(tf2_bc0, 68), linewidth=1)
p_tf2_l2 = plot((tf2_on and show_sd2) ? tf2_v0 - 2 * tf2_d0 : na, "TF2 -2σ", color=color.new(tf2_bc0, 68), linewidth=1)
fill(p_tf2_u1, p_tf2_l1, color=color.new(tf2_bc0, 88), title="TF2 ±1σ Fill")
fill(p_tf2_u2, p_tf2_l2, color=color.new(tf2_bc0, 94), title="TF2 ±2σ Fill")

// TF3
p_tf3_v0 = plot(tf3_on ? tf3_v0 : na, "TF3 AVWAP",    color=tf3_col0, linewidth=3)
p_tf3_v1 = plot(tf3_on ? tf3_v1 : na, "TF3 AVWAP H1", color=tf3_col1, linewidth=3)
p_tf3_u1 = plot((tf3_on and show_sd1) ? tf3_v0 + tf3_d0     : na, "TF3 +1σ", color=color.new(tf3_bc0, 50), linewidth=1)
p_tf3_l1 = plot((tf3_on and show_sd1) ? tf3_v0 - tf3_d0     : na, "TF3 -1σ", color=color.new(tf3_bc0, 50), linewidth=1)
p_tf3_u2 = plot((tf3_on and show_sd2) ? tf3_v0 + 2 * tf3_d0 : na, "TF3 +2σ", color=color.new(tf3_bc0, 68), linewidth=1)
p_tf3_l2 = plot((tf3_on and show_sd2) ? tf3_v0 - 2 * tf3_d0 : na, "TF3 -2σ", color=color.new(tf3_bc0, 68), linewidth=1)
fill(p_tf3_u1, p_tf3_l1, color=color.new(tf3_bc0, 88), title="TF3 ±1σ Fill")
fill(p_tf3_u2, p_tf3_l2, color=color.new(tf3_bc0, 94), title="TF3 ±2σ Fill")

// Weekly VWAP
p_wv  = plot(show_wvwap ? wvwap : na,                              "Weekly VWAP", color=wvwap_col,                linewidth=2)
p_wu1 = plot((show_wvwap and show_sd1) ? wvwap + wvwap_sd : na,   "W +1σ",       color=color.new(wvwap_col, 50), linewidth=1)
p_wl1 = plot((show_wvwap and show_sd1) ? wvwap - wvwap_sd : na,   "W -1σ",       color=color.new(wvwap_col, 50), linewidth=1)
p_wu2 = plot((show_wvwap and show_sd2) ? wvwap + 2*wvwap_sd : na, "W +2σ",       color=color.new(wvwap_col, 68), linewidth=1)
p_wl2 = plot((show_wvwap and show_sd2) ? wvwap - 2*wvwap_sd : na, "W -2σ",       color=color.new(wvwap_col, 68), linewidth=1)
fill(p_wu1, p_wl1, color=color.new(wvwap_col, 90), title="Weekly ±1σ Fill")
fill(p_wu2, p_wl2, color=color.new(wvwap_col, 95), title="Weekly ±2σ Fill")

// NY Session VWAP
p_dv  = plot(show_dvwap ? dvwap : na,                            "NY VWAP", color=dvwap_col,                linewidth=1)
p_du1 = plot((show_dvwap and show_sd1) ? dvwap + dvwap_sd : na, "NY +1σ",  color=color.new(dvwap_col, 50), linewidth=1)
p_dl1 = plot((show_dvwap and show_sd1) ? dvwap - dvwap_sd : na, "NY -1σ",  color=color.new(dvwap_col, 50), linewidth=1)
fill(p_du1, p_dl1, color=color.new(dvwap_col, 90), title="NY ±1σ Fill")

// ── TWAP notice ───────────────────────────────────────────────────────────────
var label _twap_lbl = na
if barstate.islast and syminfo.type == "forex"
    if na(_twap_lbl)
        _twap_lbl := label.new(bar_index, high, "TWAP (volume N/A)",
                       xloc=xloc.bar_index, style=label.style_label_left,
                       color=color.new(#78909c, 50), textcolor=color.white, size=size.small)
    else
        label.set_x(_twap_lbl, bar_index)
        label.set_y(_twap_lbl, high)
````
