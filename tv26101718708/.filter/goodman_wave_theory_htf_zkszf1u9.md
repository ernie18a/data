# Goodman Wave Theory (HTF)

- url: https://www.tradingview.com/script/ZKSZF1u9-Goodman-Wave-Theory-HTF/
- type: indicator
- pine_id: PUB;795190cba2bb4832924cf15544b34c1b
- version: 1.0

## Description

[b]Goodman Wave Theory (HTF)[/b]

The first Pine Script implementation of Charles Goodman's 1-2-3 swing system (1984; codified by Michael Duane Archer in Technical Analysis of Stocks and Commodities, December 2010). Detects primary 1-2-3 structural units across three configurable higher timeframes, labels each confirmed point at its pivot price and time, projects the measured-move target from Point 3, and highlights the two highest-conviction conditions in the framework: Propagation and Intersection.
A 1-2-3 unit is the simplest complete swing in Goodman's framework: P1 (initial pivot) → P2 (impulse target) → P3 (pullback that holds above P1 for bull / below P1 for bear) → 3-C (the measured-move projection from P3). The 50% midpoint of the P1→P2 leg is a structural reference that often acts as support during the P3 pullback.

[b]How it works[/b]

For each of the three configured timeframes, the script runs two independent state machines — one bullish, one bearish — in parallel inside request.security. Each watches the same pivot stream but interprets it differently.

Bullish 1-2-3:[list]
[*]Phase 0 → 1 — a pivot low becomes P1. Lower pivot lows update P1.
[*]Phase 1 → 2 — a pivot high above P1 becomes P2. Higher P2s update.
[*]Phase 2 → 3 — a pivot low above P1 becomes P3. If the next pivot low breaks below P1, the structure resets to Phase 1 with a new P1.
[*]Phase 3 — the 3-C target is computed as P3 + (P2 − P1). When price reaches it, the structure completes and the prior 3-C target is stored for propagation detection.[/list]

Bearish 1-2-3 mirrors this exactly, replacing pivot highs with pivot lows and vice versa.
When close violates P1 in the wrong direction (close below P1 for bull, above P1 for bear) and the next pivot confirms the failure, the structure resets and the failed 3-C target is stored — failed setups still inform propagation.
Propagation fires when a new P1 forms within tolerance of the previous completed (or invalidated) 3-C target. Interpretation: the prior structure's terminal price has become the current structure's anchor — the swings are linked, the structure is propagating cleanly through the market.
Intersection fires when a bullish 3-C target sits within tolerance of the bearish 50% midpoint, or vice versa. In Goodman's framework this is the highest-conviction setup — two opposing structures pointing at the same price level, often before a decisive resolution.

[b]How to read it[/b]

Each timeframe has its own structural overlay. Border weight increases with timeframe (thin → medium → thick), so higher-timeframe structures dominate. Color carries direction:[list]
[*]Bullish 1-2-3 (default teal)
[*]Bearish 1-2-3 (default red)
[*]Intersection (default amber) — the bull/bear 3-C/midpoint coincidence
[*]Propagation (default purple, with a ⟳ prefix on P1) — P1 forms near prior 3-C
[/list]
Active structures draw:[list]
[*]P1 → P2 → P3 lines showing the swing geometry
[*]Point labels at each pivot (P1, P2, P3); a propagating P1 gets the ⟳ prefix
[*]50% midpoint as a dashed line through the P1→P2 leg, extending to the right edge
[*]3-C target as a dotted line with a right-edge label (3-C↑ or 3-C↓)
[*]Intersection level as a thicker amber line when a bull/bear coincidence is active
[*]Right-edge phase tag showing the active state ("Bull · P3", "Bear · P2", etc.) and a propagation indicator if applicable
[/list]
When a structure invalidates — close violates P1 — the lines dim and stop extending, same convention as the rest of the suite.
The framework's distinctive insight is that completed and failed structures aren't disposable. Their terminal prices anchor the next structure. Watch the propagation markers across multiple timeframes: when a 4H propagation aligns with a Daily P1, that's the same structural moment expressed at two scales.

[b]Inputs[/b][list]
[*]Pivot length — bars required on each side to confirm a structural pivot. Default 10.
[*]Intersection tolerance — maximum percentage distance between a 3-C target and an opposing 50% midpoint to be counted as an Intersection. Default 1.0% (tight); raise to 2–3% on volatile instruments.
[*]Timeframes 1/2/3 — defaults: 4H, Daily, Weekly. All three on by default.
[*]Colors — bullish, bearish, intersection, propagation.
[*]Display toggles — point labels, 3-C target, 50% midpoint, intersection zones, propagation markers, right-edge phase tag.[/list]

[b]Built-in alerts[/b]
Six alerts on TF1 (kept TF1-only since higher timeframes confirm too slowly for real-time alerts to be useful):[list]
[*]Bull P2 confirmed — bullish impulse target reached
[*]Bull P3 confirmed — bullish pullback completed
[*]Bear P2 confirmed — bearish impulse target reached
[*]Bear P3 confirmed — bearish pullback completed
[*]Intersection detected — bull/bear 3-C/midpoint coincidence
[*]Propagation detected — new P1 forms near prior 3-C[/list]

[b]Notes[/b]

Goodman is much less widely known than Wyckoff or Elliott Wave, but his 1-2-3 system is in some ways more disciplined: every transition has a precise rule, every level has a precise definition, and the framework is symmetrical between bull and bear setups. Where Elliott Wave invites endless interpretation about which wave you're in, Goodman's state machine simply asks "have you confirmed P3 yet?" and proceeds accordingly.
The two cross-structure concepts — Propagation and Intersection — are what distinguish Goodman from a generic 1-2-3 pattern detector. Plenty of indicators draw 1-2-3 patterns; very few track how completed and failed structures inform the next one. Worth watching the propagation markers specifically: a chart where every new P1 fires a propagation marker is one where price is moving through coherent structural geometry rather than noise.
The bullish and bearish state machines run independently. This means at any moment a chart can show both an active bull 1-2-3 and an active bear 1-2-3, with their respective P1/P2/P3 levels and 3-C targets drawn simultaneously. When their levels coincide — hence Intersection — that's the framework's headline event.
The intersection tolerance is the most-tuned setting. 1% is appropriate for major equity indices and large-cap stocks where structural levels respect each other tightly. Crypto and small-caps may need 2–3% before genuine intersections register; FX pairs with low daily ranges can stay at 1% or tighter.
Higher-timeframe pivots don't confirm until pivot length bars after the actual swing. On Weekly with length 10, that's ten weeks of delay between the swing and the structure appearing. Geometry is non-repainting once it prints.
When no structure appears on a timeframe, the state machine is usually between completed structures or in early Phase 0/1 with no P2 yet confirmed. Both are normal. If structures consistently reach Phase 3 but never hit the 3-C target, lower the pivot length to capture finer swings or consider whether the chart's volatility regime has shifted.
This is a structural tool, not a signal generator. It marks the canonical Goodman geometry and flags the framework's two highest-conviction conditions.

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
//                Goodman Wave Theory (HTF)
//                ─────────────────────────────
//   The first Pine Script implementation of Charles Goodman's 1-2-3 swing
//   system (1984; codified by Michael Duane Archer, T&AS Dec 2010).  Detects
//   primary 1-2-3 structural units across three configurable higher timeframes,
//   labels each confirmed point (P1, P2, P3) at its pivot price and time,
//   projects the 3-C measured-move target from Point 3, and holds the 50%
//   midpoint of the P1→P2 leg as a key structural reference.
//
//   Propagation: current swing's P1 formed near prior 3-C → structure is
//   propagating (prior move "gave birth" to this one).  Intersection: bull
//   3-C ≈ bear 50% midpoint or vice versa — the highest-conviction setup in
//   the Goodman framework, highlighted with an amber level.
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Goodman Wave Theory (HTF)", shorttitle="GWT", overlay=true, max_lines_count=200, max_labels_count=300, max_boxes_count=30)

// ── Inputs ───────────────────────────────────────────────────────────────────
pivot_len = input.int(10,  "Pivot length",               minval=2, maxval=50,  step=1,   group="Detection", tooltip="Bars required on each side of a pivot to confirm it as a structural high or low. Use the same value across all suite indicators for consistency.")
isect_tol = input.float(1.0, "Intersection tolerance (%)", minval=0.1, maxval=5.0, step=0.1, group="Detection", tooltip="Maximum distance between a 3-C target and an opposing 50% midpoint for them to be counted as an Intersection. 1% is tight; raise to 2-3% on volatile instruments.")

tf1_on = input.bool(true,  "TF 1", group="Timeframes", inline="tf1")
tf1    = input.timeframe("240", "", group="Timeframes", inline="tf1")
tf2_on = input.bool(true,  "TF 2", group="Timeframes", inline="tf2")
tf2    = input.timeframe("D",   "", group="Timeframes", inline="tf2")
tf3_on = input.bool(true,  "TF 3", group="Timeframes", inline="tf3")
tf3    = input.timeframe("W",   "", group="Timeframes", inline="tf3")

bull_col  = input.color(#26a69a, "Bullish (1-2-3)",  group="Colors")
bear_col  = input.color(#ef5350, "Bearish (1-2-3)",  group="Colors")
isect_col = input.color(#f59e0b, "Intersection",     group="Colors")
prop_col  = input.color(#7c3aed, "Propagation",      group="Colors")

show_labels = input.bool(true, "Point labels (P1 / P2 / P3)", group="Display")
show_target = input.bool(true, "3-C target",                  group="Display")
show_mid    = input.bool(true, "50% midpoint",                group="Display")
show_isect  = input.bool(true, "Intersection zones",          group="Display")
show_prop   = input.bool(true, "Propagation markers",         group="Display")
show_phase  = input.bool(true, "Phase tag (right edge)",      group="Display")

// ── Goodman 1-2-3 state machine ──────────────────────────────────────────────
f_goodman(plen, tol_pct) =>
    // ── Bullish state ─────────────────────────────────────────────────────────
    var int   b_ph       = 0
    var float b_p1       = float(na)
    var float b_p1t      = float(na)
    var float b_p2       = float(na)
    var float b_p2t      = float(na)
    var float b_p3       = float(na)
    var float b_p3t      = float(na)
    var bool  b_brk      = false
    var float b_prev_tgt = float(na)
    var float b_prev_mid = float(na)

    // ── Bearish state ─────────────────────────────────────────────────────────
    var int   s_ph       = 0
    var float s_p1       = float(na)
    var float s_p1t      = float(na)
    var float s_p2       = float(na)
    var float s_p2t      = float(na)
    var float s_p3       = float(na)
    var float s_p3t      = float(na)
    var bool  s_brk      = false
    var float s_prev_tgt = float(na)
    var float s_prev_mid = float(na)

    // Pivot detection
    ph = ta.pivothigh(plen, plen)
    pl = ta.pivotlow(plen, plen)

    // Pivot bar times (offset back plen bars)
    ph_t = not na(ph) ? float(time[plen]) : float(na)
    pl_t = not na(pl) ? float(time[plen]) : float(na)
    ph_v = not na(ph) ? ph : float(na)
    pl_v = not na(pl) ? pl : float(na)

    // ── Bullish transitions ───────────────────────────────────────────────────
    if b_ph == 0
        if not na(pl_v)
            b_ph  := 1
            b_p1  := pl_v
            b_p1t := pl_t
            b_p2  := float(na)
            b_p2t := float(na)
            b_p3  := float(na)
            b_p3t := float(na)
            b_brk := false

    else if b_ph == 1
        if not na(pl_v)
            if pl_v < b_p1
                b_p1  := pl_v
                b_p1t := pl_t
        if not na(ph_v)
            if ph_v > b_p1
                b_ph  := 2
                b_p2  := ph_v
                b_p2t := ph_t

    else if b_ph == 2
        if not na(ph_v)
            if ph_v > b_p2
                b_p2  := ph_v
                b_p2t := ph_t
        if not na(pl_v)
            if pl_v > b_p1
                b_ph       := 3
                b_p3       := pl_v
                b_p3t      := pl_t
                b_prev_mid := (b_p1 + b_p2) / 2.0
                b_brk      := false
            else
                b_ph  := 1
                b_p1  := pl_v
                b_p1t := pl_t
                b_p2  := float(na)
                b_p2t := float(na)
                b_p3  := float(na)
                b_p3t := float(na)
                b_brk := false

    else if b_ph == 3
        _b_tgt = b_p3 + (b_p2 - b_p1)
        if high >= _b_tgt
            b_prev_tgt := _b_tgt
            b_prev_mid := (b_p1 + b_p2) / 2.0
            b_ph  := 0
            b_p1  := float(na)
            b_p1t := float(na)
            b_p2  := float(na)
            b_p2t := float(na)
            b_p3  := float(na)
            b_p3t := float(na)
            b_brk := false
        else
            if close < b_p1
                b_brk := true
            if b_brk and not na(pl_v)
                b_prev_tgt := _b_tgt
                b_prev_mid := (b_p1 + b_p2) / 2.0
                b_ph  := 1
                b_p1  := pl_v
                b_p1t := pl_t
                b_p2  := float(na)
                b_p2t := float(na)
                b_p3  := float(na)
                b_p3t := float(na)
                b_brk := false

    // ── Bearish transitions ───────────────────────────────────────────────────
    if s_ph == 0
        if not na(ph_v)
            s_ph  := 1
            s_p1  := ph_v
            s_p1t := ph_t
            s_p2  := float(na)
            s_p2t := float(na)
            s_p3  := float(na)
            s_p3t := float(na)
            s_brk := false

    else if s_ph == 1
        if not na(ph_v)
            if ph_v > s_p1
                s_p1  := ph_v
                s_p1t := ph_t
        if not na(pl_v)
            if pl_v < s_p1
                s_ph  := 2
                s_p2  := pl_v
                s_p2t := pl_t

    else if s_ph == 2
        if not na(pl_v)
            if pl_v < s_p2
                s_p2  := pl_v
                s_p2t := pl_t
        if not na(ph_v)
            if ph_v < s_p1
                s_ph       := 3
                s_p3       := ph_v
                s_p3t      := ph_t
                s_prev_mid := (s_p1 + s_p2) / 2.0
                s_brk      := false
            else
                s_ph  := 1
                s_p1  := ph_v
                s_p1t := ph_t
                s_p2  := float(na)
                s_p2t := float(na)
                s_p3  := float(na)
                s_p3t := float(na)
                s_brk := false

    else if s_ph == 3
        _s_tgt = s_p3 - (s_p1 - s_p2)
        if low <= _s_tgt
            s_prev_tgt := _s_tgt
            s_prev_mid := (s_p1 + s_p2) / 2.0
            s_ph  := 0
            s_p1  := float(na)
            s_p1t := float(na)
            s_p2  := float(na)
            s_p2t := float(na)
            s_p3  := float(na)
            s_p3t := float(na)
            s_brk := false
        else
            if close > s_p1
                s_brk := true
            if s_brk and not na(ph_v)
                s_prev_tgt := _s_tgt
                s_prev_mid := (s_p1 + s_p2) / 2.0
                s_ph  := 1
                s_p1  := ph_v
                s_p1t := ph_t
                s_p2  := float(na)
                s_p2t := float(na)
                s_p3  := float(na)
                s_p3t := float(na)
                s_brk := false

    // ── Derived levels ────────────────────────────────────────────────────────
    b_tgt = b_ph == 3 and not na(b_p3) ? b_p3 + (b_p2 - b_p1) : float(na)
    b_mid = b_ph >= 2 and not na(b_p2) ? (b_p1 + b_p2) / 2.0  : float(na)
    s_tgt = s_ph == 3 and not na(s_p3) ? s_p3 - (s_p1 - s_p2) : float(na)
    s_mid = s_ph >= 2 and not na(s_p2) ? (s_p1 + s_p2) / 2.0  : float(na)

    // ── Intersection ──────────────────────────────────────────────────────────
    tol       = tol_pct / 100.0
    isect_lev  = float(na)
    isect_bull = false
    isect_bear = false

    if not na(b_tgt) and not na(s_mid) and s_mid > 0.0
        if math.abs(b_tgt - s_mid) / s_mid < tol
            isect_lev  := (b_tgt + s_mid) / 2.0
            isect_bull := true

    if not na(s_tgt) and not na(b_mid) and b_mid > 0.0
        if math.abs(s_tgt - b_mid) / b_mid < tol
            isect_lev  := (s_tgt + b_mid) / 2.0
            isect_bear := true

    // ── Propagation ───────────────────────────────────────────────────────────
    prop_bull = not na(b_p1) and not na(b_prev_tgt) and b_prev_tgt > 0.0 and math.abs(b_p1 - b_prev_tgt) / b_prev_tgt < tol * 2.0
    prop_bear = not na(s_p1) and not na(s_prev_tgt) and s_prev_tgt > 0.0 and math.abs(s_p1 - s_prev_tgt) / s_prev_tgt < tol * 2.0

    [b_ph, b_p1, b_p1t, b_p2, b_p2t, b_p3, b_p3t, b_tgt, b_mid, b_brk,
     s_ph, s_p1, s_p1t, s_p2, s_p2t, s_p3, s_p3t, s_tgt, s_mid, s_brk,
     isect_lev, isect_bull, isect_bear,
     prop_bull, prop_bear]

// ── Request HTF state ─────────────────────────────────────────────────────────

[tf1_b_ph, tf1_b_p1, tf1_b_p1t, tf1_b_p2, tf1_b_p2t, tf1_b_p3, tf1_b_p3t, tf1_b_tgt, tf1_b_mid, tf1_b_brk, tf1_s_ph, tf1_s_p1, tf1_s_p1t, tf1_s_p2, tf1_s_p2t, tf1_s_p3, tf1_s_p3t, tf1_s_tgt, tf1_s_mid, tf1_s_brk, tf1_isect_lev, tf1_isect_bull, tf1_isect_bear, tf1_prop_bull, tf1_prop_bear] = request.security(syminfo.tickerid, tf1, f_goodman(pivot_len, isect_tol), lookahead=barmerge.lookahead_off)

[tf2_b_ph, tf2_b_p1, tf2_b_p1t, tf2_b_p2, tf2_b_p2t, tf2_b_p3, tf2_b_p3t, tf2_b_tgt, tf2_b_mid, tf2_b_brk, tf2_s_ph, tf2_s_p1, tf2_s_p1t, tf2_s_p2, tf2_s_p2t, tf2_s_p3, tf2_s_p3t, tf2_s_tgt, tf2_s_mid, tf2_s_brk, tf2_isect_lev, tf2_isect_bull, tf2_isect_bear, tf2_prop_bull, tf2_prop_bear] = request.security(syminfo.tickerid, tf2, f_goodman(pivot_len, isect_tol), lookahead=barmerge.lookahead_off)

[tf3_b_ph, tf3_b_p1, tf3_b_p1t, tf3_b_p2, tf3_b_p2t, tf3_b_p3, tf3_b_p3t, tf3_b_tgt, tf3_b_mid, tf3_b_brk, tf3_s_ph, tf3_s_p1, tf3_s_p1t, tf3_s_p2, tf3_s_p2t, tf3_s_p3, tf3_s_p3t, tf3_s_tgt, tf3_s_mid, tf3_s_brk, tf3_isect_lev, tf3_isect_bull, tf3_isect_bear, tf3_prop_bull, tf3_prop_bear] = request.security(syminfo.tickerid, tf3, f_goodman(pivot_len, isect_tol), lookahead=barmerge.lookahead_off)

// ── Drawing registries ────────────────────────────────────────────────────────

var box[]   g_boxes = array.new<box>(0)
var line[]  g_lines = array.new<line>(0)
var label[] g_lbls  = array.new<label>(0)

// ── Draw one timeframe's Goodman structures ───────────────────────────────────

f_draw(b_ph, b_p1, b_p1t, b_p2, b_p2t, b_p3, b_p3t, b_tgt, b_mid, b_brk,
       s_ph, s_p1, s_p1t, s_p2, s_p2t, s_p3, s_p3t, s_tgt, s_mid, s_brk,
       isect_lev, isect_bull, isect_bear,
       prop_bull, prop_bear, lw, right_t) =>

    // ── Bullish colors (pre-expanded — no series color as first arg) ───────────
    b_line_c = b_brk ? color.new(bull_col, 72) : color.new(bull_col, 20)
    b_lbl_c  = b_brk ? color.new(bull_col, 72) : color.new(bull_col, 15)
    b_mid_c  = b_brk ? color.new(bull_col, 85) : color.new(bull_col, 55)
    b_tgt_c  = b_brk ? color.new(bull_col, 72) : color.new(bull_col, 25)
    p1_lbl_c = prop_bull and show_prop ? color.new(prop_col, 15) : (b_brk ? color.new(bull_col, 72) : color.new(bull_col, 15))

    // ── Bearish colors (pre-expanded) ─────────────────────────────────────────
    s_line_c = s_brk ? color.new(bear_col, 72) : color.new(bear_col, 20)
    s_lbl_c  = s_brk ? color.new(bear_col, 72) : color.new(bear_col, 15)
    s_mid_c  = s_brk ? color.new(bear_col, 85) : color.new(bear_col, 55)
    s_tgt_c  = s_brk ? color.new(bear_col, 72) : color.new(bear_col, 25)
    s1_lbl_c = prop_bear and show_prop ? color.new(prop_col, 15) : (s_brk ? color.new(bear_col, 72) : color.new(bear_col, 15))

    // ── Bullish 1-2-3 ─────────────────────────────────────────────────────────
    if b_ph >= 1 and not na(b_p1)
        // P1 label
        if show_labels
            _p1_txt = prop_bull and show_prop ? "⟳ P1" : "P1"
            _lbl = label.new(int(b_p1t), b_p1, _p1_txt,
                 xloc=xloc.bar_time, style=label.style_label_up,
                 color=p1_lbl_c, textcolor=color.white, size=size.tiny)
            array.push(g_lbls, _lbl)

        if b_ph >= 2 and not na(b_p2t)
            // P1→P2 line
            _l12 = line.new(int(b_p1t), b_p1, int(b_p2t), b_p2,
                 xloc=xloc.bar_time, color=b_line_c, width=lw)
            array.push(g_lines, _l12)

            // P2 label
            if show_labels
                _lbl2 = label.new(int(b_p2t), b_p2, "P2",
                     xloc=xloc.bar_time, style=label.style_label_down,
                     color=b_lbl_c, textcolor=color.white, size=size.tiny)
                array.push(g_lbls, _lbl2)

            // 50% midpoint line
            if show_mid
                _ext = b_brk ? extend.none : extend.right
                _lmid = line.new(int(b_p1t), (b_p1 + b_p2) / 2.0, int(time), (b_p1 + b_p2) / 2.0,
                     xloc=xloc.bar_time, color=b_mid_c, style=line.style_dashed,
                     width=lw, extend=_ext)
                array.push(g_lines, _lmid)

        if b_ph >= 3 and not na(b_p3t)
            // P2→P3 line
            _l23 = line.new(int(b_p2t), b_p2, int(b_p3t), b_p3,
                 xloc=xloc.bar_time, color=b_line_c, width=lw)
            array.push(g_lines, _l23)

            // P3 label
            if show_labels
                _lbl3 = label.new(int(b_p3t), b_p3, "P3",
                     xloc=xloc.bar_time, style=label.style_label_up,
                     color=b_lbl_c, textcolor=color.white, size=size.tiny)
                array.push(g_lbls, _lbl3)

            // 3-C target line
            if show_target and not na(b_tgt)
                _ext_tgt = b_brk ? extend.none : extend.right
                _ltgt = line.new(int(b_p3t), b_tgt, int(time), b_tgt,
                     xloc=xloc.bar_time, color=b_tgt_c, style=line.style_dotted,
                     width=lw + 1, extend=_ext_tgt)
                array.push(g_lines, _ltgt)

                // 3-C label
                if show_labels and not b_brk
                    _ltgt_lbl = label.new(right_t, b_tgt, "3-C↑",
                         xloc=xloc.bar_time, style=label.style_label_left,
                         color=b_tgt_c, textcolor=color.white, size=size.tiny)
                    array.push(g_lbls, _ltgt_lbl)

    // ── Bearish 1-2-3 ─────────────────────────────────────────────────────────
    if s_ph >= 1 and not na(s_p1)
        // P1 label
        if show_labels
            _sp1_txt = prop_bear and show_prop ? "⟳ P1" : "P1"
            _slbl = label.new(int(s_p1t), s_p1, _sp1_txt,
                 xloc=xloc.bar_time, style=label.style_label_down,
                 color=s1_lbl_c, textcolor=color.white, size=size.tiny)
            array.push(g_lbls, _slbl)

        if s_ph >= 2 and not na(s_p2t)
            // P1→P2 line
            _sl12 = line.new(int(s_p1t), s_p1, int(s_p2t), s_p2,
                 xloc=xloc.bar_time, color=s_line_c, width=lw)
            array.push(g_lines, _sl12)

            // P2 label
            if show_labels
                _slbl2 = label.new(int(s_p2t), s_p2, "P2",
                     xloc=xloc.bar_time, style=label.style_label_up,
                     color=s_lbl_c, textcolor=color.white, size=size.tiny)
                array.push(g_lbls, _slbl2)

            // 50% midpoint line
            if show_mid
                _sext = s_brk ? extend.none : extend.right
                _slmid = line.new(int(s_p1t), (s_p1 + s_p2) / 2.0, int(time), (s_p1 + s_p2) / 2.0,
                     xloc=xloc.bar_time, color=s_mid_c, style=line.style_dashed,
                     width=lw, extend=_sext)
                array.push(g_lines, _slmid)

        if s_ph >= 3 and not na(s_p3t)
            // P2→P3 line
            _sl23 = line.new(int(s_p2t), s_p2, int(s_p3t), s_p3,
                 xloc=xloc.bar_time, color=s_line_c, width=lw)
            array.push(g_lines, _sl23)

            // P3 label
            if show_labels
                _slbl3 = label.new(int(s_p3t), s_p3, "P3",
                     xloc=xloc.bar_time, style=label.style_label_down,
                     color=s_lbl_c, textcolor=color.white, size=size.tiny)
                array.push(g_lbls, _slbl3)

            // 3-C target line
            if show_target and not na(s_tgt)
                _sext_tgt = s_brk ? extend.none : extend.right
                _sltgt = line.new(int(s_p3t), s_tgt, int(time), s_tgt,
                     xloc=xloc.bar_time, color=s_tgt_c, style=line.style_dotted,
                     width=lw + 1, extend=_sext_tgt)
                array.push(g_lines, _sltgt)

                // 3-C label
                if show_labels and not s_brk
                    _sltgt_lbl = label.new(right_t, s_tgt, "3-C↓",
                         xloc=xloc.bar_time, style=label.style_label_left,
                         color=s_tgt_c, textcolor=color.white, size=size.tiny)
                    array.push(g_lbls, _sltgt_lbl)

    // ── Intersection ──────────────────────────────────────────────────────────
    if show_isect and (isect_bull or isect_bear) and not na(isect_lev)
        _ix1 = isect_bull and not na(b_p3t) ? int(b_p3t) : isect_bear and not na(s_p3t) ? int(s_p3t) : not na(b_p1t) ? int(b_p1t) : not na(s_p1t) ? int(s_p1t) : int(time)
        _isect_line = line.new(_ix1, isect_lev, int(time), isect_lev,
             xloc=xloc.bar_time, color=color.new(isect_col, 20),
             width=lw + 1, extend=extend.right)
        array.push(g_lines, _isect_line)

        _isect_txt = isect_bull ? "↑ Intersection" : "↓ Intersection"
        _isect_lbl = label.new(right_t, isect_lev, _isect_txt,
             xloc=xloc.bar_time, style=label.style_label_left,
             color=color.new(isect_col, 15), textcolor=color.white, size=size.small)
        array.push(g_lbls, _isect_lbl)

    // ── Right-edge phase tag ──────────────────────────────────────────────────
    if show_phase
        b_str = b_ph > 0 ? "Bull · P" + str.tostring(b_ph) : ""
        s_str = s_ph > 0 ? "Bear · P" + str.tostring(s_ph) : ""

        _combined = b_str != "" and s_str != "" ? b_str + " · " + s_str : b_str != "" ? b_str : s_str != "" ? s_str : ""

        _prop_sfx = (prop_bull or prop_bear) and show_prop ? "\n⟳ Propagation" : ""
        _phase_txt = _combined + _prop_sfx

        if _phase_txt != ""
            _bull_dom = b_ph > 0 and (s_ph == 0 or b_ph >= s_ph)
            _y_anchor = _bull_dom and not na(b_p2) ? b_p2 : not na(s_p1) ? s_p1 : close
            _phase_col = _bull_dom ? color.new(bull_col, 15) : color.new(bear_col, 15)

            _plbl = label.new(right_t, _y_anchor, _phase_txt,
                 xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left,
                 color=_phase_col, textcolor=color.white, size=size.small)
            array.push(g_lbls, _plbl)

// ── Rebuild at barstate.islast ────────────────────────────────────────────────

var float _drawn_cs = float(na)

_cs_raw = (na(tf1_b_p1) ? 0.0 : tf1_b_p1) + (na(tf1_b_p2) ? 0.0 : tf1_b_p2) + (na(tf1_b_p3) ? 0.0 : tf1_b_p3) + (na(tf1_s_p1) ? 0.0 : tf1_s_p1) + (na(tf1_s_p2) ? 0.0 : tf1_s_p2) + (na(tf1_s_p3) ? 0.0 : tf1_s_p3) + (na(tf2_b_p1) ? 0.0 : tf2_b_p1) + (na(tf2_b_p2) ? 0.0 : tf2_b_p2) + (na(tf2_b_p3) ? 0.0 : tf2_b_p3) + (na(tf2_s_p1) ? 0.0 : tf2_s_p1) + (na(tf2_s_p2) ? 0.0 : tf2_s_p2) + (na(tf2_s_p3) ? 0.0 : tf2_s_p3) + (na(tf3_b_p1) ? 0.0 : tf3_b_p1) + (na(tf3_b_p2) ? 0.0 : tf3_b_p2) + (na(tf3_b_p3) ? 0.0 : tf3_b_p3) + (na(tf3_s_p1) ? 0.0 : tf3_s_p1) + (na(tf3_s_p2) ? 0.0 : tf3_s_p2) + (na(tf3_s_p3) ? 0.0 : tf3_s_p3)

if barstate.islast and (_cs_raw != _drawn_cs or na(_drawn_cs))
    _drawn_cs := _cs_raw
    n_bx = array.size(g_boxes)
    if n_bx > 0
        for i = 0 to n_bx - 1
            box.delete(array.get(g_boxes, i))
    array.clear(g_boxes)

    n_ln = array.size(g_lines)
    if n_ln > 0
        for i = 0 to n_ln - 1
            line.delete(array.get(g_lines, i))
    array.clear(g_lines)

    n_lb = array.size(g_lbls)
    if n_lb > 0
        for i = 0 to n_lb - 1
            label.delete(array.get(g_lbls, i))
    array.clear(g_lbls)

    _bar_dur = not na(time[1]) ? int(time) - int(time[1]) : 86400000
    _right_t = int(time) + _bar_dur * 3

    if tf3_on and (tf3_b_ph != 0 or tf3_s_ph != 0)
        f_draw(tf3_b_ph, tf3_b_p1, tf3_b_p1t, tf3_b_p2, tf3_b_p2t, tf3_b_p3, tf3_b_p3t, tf3_b_tgt, tf3_b_mid, tf3_b_brk,
               tf3_s_ph, tf3_s_p1, tf3_s_p1t, tf3_s_p2, tf3_s_p2t, tf3_s_p3, tf3_s_p3t, tf3_s_tgt, tf3_s_mid, tf3_s_brk,
               tf3_isect_lev, tf3_isect_bull, tf3_isect_bear,
               tf3_prop_bull, tf3_prop_bear, 3, _right_t)

    if tf2_on and (tf2_b_ph != 0 or tf2_s_ph != 0)
        f_draw(tf2_b_ph, tf2_b_p1, tf2_b_p1t, tf2_b_p2, tf2_b_p2t, tf2_b_p3, tf2_b_p3t, tf2_b_tgt, tf2_b_mid, tf2_b_brk,
               tf2_s_ph, tf2_s_p1, tf2_s_p1t, tf2_s_p2, tf2_s_p2t, tf2_s_p3, tf2_s_p3t, tf2_s_tgt, tf2_s_mid, tf2_s_brk,
               tf2_isect_lev, tf2_isect_bull, tf2_isect_bear,
               tf2_prop_bull, tf2_prop_bear, 2, _right_t)

    if tf1_on and (tf1_b_ph != 0 or tf1_s_ph != 0)
        f_draw(tf1_b_ph, tf1_b_p1, tf1_b_p1t, tf1_b_p2, tf1_b_p2t, tf1_b_p3, tf1_b_p3t, tf1_b_tgt, tf1_b_mid, tf1_b_brk,
               tf1_s_ph, tf1_s_p1, tf1_s_p1t, tf1_s_p2, tf1_s_p2t, tf1_s_p3, tf1_s_p3t, tf1_s_tgt, tf1_s_mid, tf1_s_brk,
               tf1_isect_lev, tf1_isect_bull, tf1_isect_bear,
               tf1_prop_bull, tf1_prop_bear, 1, _right_t)

// ── Alerts ────────────────────────────────────────────────────────────────────

tf1_bull_p2_new = tf1_b_ph == 2 and tf1_b_ph[1] != 2
tf1_bull_p3_new = tf1_b_ph == 3 and tf1_b_ph[1] != 3
tf1_bear_p2_new = tf1_s_ph == 2 and tf1_s_ph[1] != 2
tf1_bear_p3_new = tf1_s_ph == 3 and tf1_s_ph[1] != 3
tf1_isect_new   = (tf1_isect_bull or tf1_isect_bear) and not (tf1_isect_bull[1] or tf1_isect_bear[1])
tf1_prop_new    = (tf1_prop_bull or tf1_prop_bear)   and not (tf1_prop_bull[1]  or tf1_prop_bear[1])

alertcondition(tf1_bull_p2_new, "GWT - Bull P2 confirmed",    "{{ticker}} — Goodman Bull P2 confirmed on TF1 {{interval}}")
alertcondition(tf1_bull_p3_new, "GWT - Bull P3 confirmed",    "{{ticker}} — Goodman Bull P3 confirmed on TF1 {{interval}}")
alertcondition(tf1_bear_p2_new, "GWT - Bear P2 confirmed",    "{{ticker}} — Goodman Bear P2 confirmed on TF1 {{interval}}")
alertcondition(tf1_bear_p3_new, "GWT - Bear P3 confirmed",    "{{ticker}} — Goodman Bear P3 confirmed on TF1 {{interval}}")
alertcondition(tf1_isect_new,   "GWT - Intersection detected","{{ticker}} — Goodman Intersection confirmed on TF1 {{interval}}")
alertcondition(tf1_prop_new,    "GWT - Propagation detected",  "{{ticker}} — Goodman Propagation confirmed on TF1 {{interval}}")
````
