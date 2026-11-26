# Wyckoff Phase Mapper (HTF)

- url: https://www.tradingview.com/script/hdK7qfbZ-Wyckoff-Phase-Mapper-HTF/
- type: indicator
- pine_id: PUB;843c5f935d994b20af4ca215d532cec5
- version: 1.0

## Description

[b]Wyckoff Phase Mapper (HTF)[/b]

Detects and labels canonical Wyckoff Accumulation and Distribution schematics across three configurable higher timeframes. The engine is a pivot-based state machine that sequences through Phases A–E, gating each transition behind a confirmed structural event:[list]
[*]Accumulation: SC → AR → (ST/Spring) → SOS → LPS → markup
[*]Distribution: BC → AR → (ST/UTAD) → SOW → LPSY → markdown[/list]
A trading-range box opens on the first confirmed climax event and remains visible until price closes outside it by the configured invalidation margin. Each canonical event is labelled at its confirmed pivot. The right edge shows the active phase letter (A–E) for every timeframe.

[b]How it works[/b]

Wyckoff schematics describe how smart money builds positions inside a trading range before a directional move. The script encodes the canonical sequence as a state machine that watches for, in order:[list=1]
[*]Phase A — Climax + Automatic Reaction. A pivot low (Selling Climax — SC) or pivot high (Buying Climax — BC) confirmed at a volume spike or wide-range bar, in the direction opposite to the prevailing EMA trend (downtrend for SC, uptrend for BC). The opposite-side pivot that follows is the Automatic Reaction (AR).
[*]Phase B — Cause building. Price oscillates within the SC–AR range. No event is required; the script simply waits.
[*]Phase C — Spring or UTAD (optional). A pivot low below the SC (Spring) for accumulation, or a pivot high above the BC (Upthrust After Distribution — UTAD) for distribution. This is the deceptive move that takes liquidity below support or above resistance before the genuine directional push. The state machine does not require this phase — Phase D can fire directly from Phase B if no Spring/UTAD forms.
[*]Phase D — Sign of Strength / Weakness. A pivot high above the AR level (SOS) for accumulation, or a pivot low below the AR (SOW) for distribution. Confirms the directional bias of the trading range.
[*]Phase E — Last Point of Support / Supply. A pivot back into the upper half of the range (LPS for accumulation, LPSY for distribution), marking the entry pullback before markup or markdown begins.[/list]
Each timeframe runs its own independent state-machine instance inside request.security. Border weight increases per TF (thin → medium → thick) so higher-timeframe structures dominate the visual.
Climax detection requires either a volume spike (configurable multiple of the 20-bar average) or an unusually wide-range bar (1.5× ATR). An EMA-based trend filter prevents the script from interpreting any pivot in a sideways market as a climax — only pivots in clear opposing trends qualify.
Invalidation: when close breaks beyond the SC (or BC) level by the configured percentage and the trend has reversed, the structure dims and the state machine resets. The two-condition reset is deliberate — a single failed bar isn't enough to discard a still-developing pattern.
Phase E expiry: once price moves the configured percentage beyond the trading range top (accumulation) or bottom (distribution), the structure resets so the engine can begin detecting the next one. This prevents fully completed structures from anchoring the chart's Y-axis indefinitely.

[b]How to read it[/b]

Each timeframe gets its own structural overlay. Color carries direction:[list]
[*]Accumulation (default teal) — bullish base structure
[*]Distribution (default red) — bearish topping structure[/list]
Every active structure draws:[list]
[*]Trading range box between SC/BC and AR, extending to the right edge
[*]Dashed line at SC or BC level — the structural floor/ceiling
[*]Solid line at AR level — the opposing boundary
[*]Optional midline through the centre of the range
[*]Event labels at each pivot: SC/BC, AR, Spring/UTAD, SOS/SOW, LPS/LPSY
[*]Phase tag at the right edge showing the current letter (A through E)[/list]
When invalidated, the structure dims, stops extending, and the lines lock to their last endpoints — visible as historical context but visually de-emphasised.
The structural read across timeframes: a 1H Phase D signal inside a 4H Phase B is a low-conviction setup (the higher timeframe is still building cause); a 1H Phase D aligned with a 4H Phase D is much stronger. The same pivot that completes a structure on a low timeframe is often only an early-phase event on the higher one.

[b]Inputs[/b][list]
[*]Pivot length — bars required on each side to confirm a structural pivot. Default 10.
[*]Climax volume multiplier — volume must exceed this multiple of the 20-bar average on the climax bar. Default 1.5.
[*]Invalidation threshold — percentage close-through required to invalidate. Default 2%.
[*]Phase E expiry — percentage move beyond the range that resets the structure. Default 20% (suits crypto; tighten to 10–15% for equities or FX).
[*]Timeframes 1/2/3 — defaults: 1H, 4H, Daily. All three on by default.
[*]Colors — accumulation and distribution.
[*]Display toggles — event labels, phase tag at right edge, midline.[/list]

[b]Built-in alerts[/b]

Seven alerts on TF1 (kept TF1-only by design; the higher timeframes confirm so slowly that real-time alerts aren't useful):[list]
[*]Spring confirmed — Phase C accumulation event
[*]SOS confirmed — Phase D accumulation event
[*]LPS confirmed — Phase E accumulation event
[*]UTAD confirmed — Phase C distribution event
[*]SOW confirmed — Phase D distribution event
[*]LPSY confirmed — Phase E distribution event
[*]Structure broken — invalidation triggered[/list]

[b]Notes[/b]

Wyckoff is the original "smart money" framework — most modern SMC/ICT terminology descends from it. If you've found OB / FVG / Liquidity Areas / OTE useful, the same intuitions apply here, just expressed through the older vocabulary. A Wyckoff Spring is conceptually the same event as an SMC liquidity sweep below support; a Phase D SOS is a market-structure shift in the upward direction; an LPS is an OTE-style retracement entry. The Wyckoff schematic is more prescriptive about the order events must occur in, which is why this indicator uses a state machine rather than independent zone/level detection.
The state machine deliberately allows Phase C to be skipped. Not every accumulation includes a Spring — some structures go directly from Phase B back-and-forth into a Phase D breakout. Forcing a Spring requirement would miss those entirely. The trade-off is that some genuine Phase B exits get classified as SOS without the deceptive-shakeout step, which is fine for trading purposes even if the textbook wants the Spring.
The two-condition invalidation (close-through plus trend reversal) is conservative on purpose. A Wyckoff structure invalidated by one bad close where the underlying trend hasn't actually flipped tends to resolve into a re-test rather than a true failure. The dual gate filters out single-bar noise while still resetting cleanly when the macro picture has genuinely shifted.
The volume multiplier is the most-tuned setting in practice. Different markets have different baseline volume volatility — crypto and small-caps generate volume spikes constantly; major indices and large-cap equities are smoother. If too many spurious climaxes appear, raise to 2.0–2.5. If obvious capitulation candles aren't triggering structures, drop to 1.2–1.3.
Higher-timeframe pivots don't confirm until pivot length bars after the actual swing. On Daily with length 10, that's ten days of delay between the actual climax and the structure appearing. The structure is non-repainting once it prints.
When no structure appears on a timeframe, it usually means either (a) no climax has been detected — no qualifying volume/range pivot in a counter-trend setup, or (b) a previous structure was invalidated and the trend hasn't yet flipped to allow detection of the next one. Both are normal states.
Wyckoff analysis is interpretive — different practitioners disagree on what counts as a valid climax, what level of overshoot constitutes a Spring, and how strictly the AMD sequence must be followed. This indicator implements one defensible mechanical interpretation; users with different philosophies should adjust the inputs (or fork the source) rather than expecting it to match any specific teacher's framework verbatim.
This is a structural tool, not a signal generator. It marks where the canonical Wyckoff events have occurred and tracks which phase each structure is in.

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
//                Wyckoff Phase Mapper (HTF)
//                ─────────────────────────────────────
//   Detects and labels the canonical Wyckoff Accumulation and Distribution
//   schematics across three configurable higher timeframes.  The engine is a
//   pivot-based state machine that sequences through Phases A–E, gating each
//   transition behind a confirmed structural event:
//
//   Accumulation:  SC → AR → (ST/Spring) → SOS → LPS → markup
//   Distribution:  BC → AR → (ST/UTAD)  → SOW → LPSY → markdown
//
//   A trading-range box opens on the first confirmed climax event and remains
//   visible until price closes outside it by the configured invalidation
//   margin — at which point lines dim and the box stops extending, the same
//   convention used across the suite.  All event labels (SC, AR, Spring, SOS,
//   LPS / BC, UTAD, SOW, LPSY) appear at the price and time of the confirmed
//   pivot.  The right edge shows the active phase (A–E) for each timeframe.
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Wyckoff Phase Mapper (HTF)", shorttitle="WyckPM", overlay=true, max_boxes_count=15, max_lines_count=40, max_labels_count=60)

// ── Inputs ───────────────────────────────────────────────────────────────────
pivot_len     = input.int(10,   "Pivot length",               minval=2,   maxval=50,  group="Detection", tooltip="Bars required on each side of a pivot to confirm it as a structural high or low. Higher values find fewer, more significant pivots.")
vol_mult      = input.float(1.5,"Climax volume multiplier",   minval=1.0, maxval=5.0, step=0.1, group="Detection", tooltip="Volume must exceed this multiple of the 20-bar average on the climax bar (SC or BC) for a structure to be recognised. Raise if too many false starts appear; lower if the indicator misses obvious climaxes.")
breakdown_pct = input.float(2.0,"Invalidation threshold (%)", minval=0.5, maxval=10.0, step=0.5, group="Detection", tooltip="A close this far below the SC level (accumulation) or above the BC level (distribution) invalidates the structure and resets detection.")
expiry_pct    = input.float(20.0,"Phase E expiry (%)",         minval=5.0, maxval=100.0, step=5.0, group="Detection", tooltip="Once Phase E is confirmed and price moves this far beyond the trading range top (accumulation) or below the trading range bottom (distribution), the structure resets so the engine can detect the next one. Prevents completed structures from anchoring the Y-axis. 20% works well for crypto; tighten to 10-15% for equities or FX.")

tf1_on = input.bool(true, "TF 1", group="Timeframes", inline="tf1")
tf1    = input.timeframe("60", "", group="Timeframes", inline="tf1")
tf2_on = input.bool(true, "TF 2", group="Timeframes", inline="tf2")
tf2    = input.timeframe("240", "", group="Timeframes", inline="tf2")
tf3_on = input.bool(true, "TF 3", group="Timeframes", inline="tf3")
tf3    = input.timeframe("D", "", group="Timeframes", inline="tf3")

acc_col  = input.color(#26a69a, "Accumulation", group="Colors")
dist_col = input.color(#ef5350, "Distribution", group="Colors")

show_labels = input.bool(true, "Event labels", group="Display")
show_phase  = input.bool(true, "Phase tag (right edge)", group="Display")
show_mid    = input.bool(true, "Midline", group="Display")

// ── Wyckoff state machine ─────────────────────────────────────────────────────
f_wyckoff(plen, vmult, brk_pct, exp_pct) =>
    ph  = ta.pivothigh(high, plen, plen)
    pl  = ta.pivotlow(low,  plen, plen)

    avg_vol  = ta.sma(volume, 20)
    atr_val  = ta.atr(14)

    // Climax criteria at the pivot bar (plen bars ago)
    vol_spike = volume[plen] > avg_vol[plen] * vmult
    wide_bar  = (high[plen] - low[plen]) > atr_val[plen] * 1.5

    // Trend filter: EMA cross
    ema_fast = ta.ema(close, 21)
    ema_slow = ta.ema(close, 55)
    dn_trend = ema_fast < ema_slow
    up_trend = ema_fast > ema_slow

    // ── State
    var int   phase = 0
    var float s1_p  = na
    var float s1_t  = na
    var float s2_p  = na
    var float s2_t  = na
    var float s3_p  = na
    var float s3_t  = na
    var float s3_l  = na
    var float s4_p  = na
    var float s4_t  = na
    var float s4_l  = na
    var float s5_p  = na
    var float s5_t  = na
    var float s5_l  = na
    var bool  brk   = false

    // ── Accumulation state machine ────────────────────────────────────────────
    if phase == 0 and dn_trend and not na(pl) and (vol_spike or wide_bar)
        phase := 1
        s1_p  := pl
        s1_t  := float(time[plen])
        s2_p  := na
        s2_t  := na
        s3_p  := na
        s3_t  := na
        s3_l  := na
        s4_p  := na
        s4_t  := na
        s4_l  := na
        s5_p  := na
        s5_t  := na
        s5_l  := na
        brk   := false

    if phase == 1 and not na(ph)
        phase := 2
        s2_p  := ph
        s2_t  := float(time[plen])

    if phase == 2
        if not na(pl)
            if pl < s1_p
                phase := 3
                s3_p  := pl
                s3_t  := float(time[plen])
                s3_l  := 4.0
        if not na(ph) and ph > s2_p
            phase := 4
            s4_p  := ph
            s4_t  := float(time[plen])
            s4_l  := 5.0

    if phase == 3 and not na(ph) and ph > s2_p
        phase := 4
        s4_p  := ph
        s4_t  := float(time[plen])
        s4_l  := 5.0

    if phase == 4 and not na(pl) and pl > s1_p
        phase := 5
        s5_p  := pl
        s5_t  := float(time[plen])
        s5_l  := 6.0

    // ── Distribution state machine ────────────────────────────────────────────
    if phase == 0 and up_trend and not na(ph) and (vol_spike or wide_bar)
        phase := -1
        s1_p  := ph
        s1_t  := float(time[plen])
        s2_p  := na
        s2_t  := na
        s3_p  := na
        s3_t  := na
        s3_l  := na
        s4_p  := na
        s4_t  := na
        s4_l  := na
        s5_p  := na
        s5_t  := na
        s5_l  := na
        brk   := false

    if phase == -1 and not na(pl)
        phase := -2
        s2_p  := pl
        s2_t  := float(time[plen])

    if phase == -2
        if not na(ph)
            if ph > s1_p
                phase := -3
                s3_p  := ph
                s3_t  := float(time[plen])
                s3_l  := -4.0
        if not na(pl) and pl < s2_p
            phase := -4
            s4_p  := pl
            s4_t  := float(time[plen])
            s4_l  := -5.0

    if phase == -3 and not na(pl) and pl < s2_p
        phase := -4
        s4_p  := pl
        s4_t  := float(time[plen])
        s4_l  := -5.0

    if phase == -4 and not na(ph) and ph < s1_p
        phase := -5
        s5_p  := ph
        s5_t  := float(time[plen])
        s5_l  := -6.0

    // ── Invalidation ──────────────────────────────────────────────────────────
    thresh = brk_pct / 100.0
    if phase > 0 and not na(s1_p) and close < s1_p * (1.0 - thresh)
        brk := true
    if phase < 0 and not na(s1_p) and close > s1_p * (1.0 + thresh)
        brk := true

    // ── Phase E expiry ────────────────────────────────────────────────────────────
    exp_thresh = exp_pct / 100.0
    if phase == 5 and not na(s2_p) and close > s2_p * (1.0 + exp_thresh)
        phase := 0
        s1_p  := na
        s1_t  := na
        s2_p  := na
        s2_t  := na
        s3_p  := na
        s3_t  := na
        s3_l  := na
        s4_p  := na
        s4_t  := na
        s4_l  := na
        s5_p  := na
        s5_t  := na
        s5_l  := na
        brk   := false
    if phase == -5 and not na(s2_p) and close < s2_p * (1.0 - exp_thresh)
        phase := 0
        s1_p  := na
        s1_t  := na
        s2_p  := na
        s2_t  := na
        s3_p  := na
        s3_t  := na
        s3_l  := na
        s4_p  := na
        s4_t  := na
        s4_l  := na
        s5_p  := na
        s5_t  := na
        s5_l  := na
        brk   := false

    // ── Reset if broken and trend has fully reversed ───────────────────────────
    if brk and phase != 0 and ((phase > 0 and up_trend) or (phase < 0 and dn_trend))
        phase := 0
        s1_p  := na
        s1_t  := na
        s2_p  := na
        s2_t  := na
        s3_p  := na
        s3_t  := na
        s3_l  := na
        s4_p  := na
        s4_t  := na
        s4_l  := na
        s5_p  := na
        s5_t  := na
        s5_l  := na
        brk   := false

    // ── Trading range boundaries ──────────────────────────────────────────────
    tr_top = phase > 0 ? s2_p : phase < 0 ? s1_p : float(na)
    tr_bot = phase > 0 ? s1_p : phase < 0 ? s2_p : float(na)

    [phase, s1_p, s1_t, s2_p, s2_t, s3_p, s3_t, s3_l, s4_p, s4_t, s4_l, s5_p, s5_t, s5_l, tr_top, tr_bot, brk]

// ── Request HTF state ─────────────────────────────────────────────────────────
[tf1_phase, tf1_s1p, tf1_s1t, tf1_s2p, tf1_s2t, tf1_s3p, tf1_s3t, tf1_s3l,
 tf1_s4p, tf1_s4t, tf1_s4l, tf1_s5p, tf1_s5t, tf1_s5l, tf1_tr_top, tf1_tr_bot, tf1_brk] = request.security(syminfo.tickerid, tf1, f_wyckoff(pivot_len, vol_mult, breakdown_pct, expiry_pct))

[tf2_phase, tf2_s1p, tf2_s1t, tf2_s2p, tf2_s2t, tf2_s3p, tf2_s3t, tf2_s3l,
 tf2_s4p, tf2_s4t, tf2_s4l, tf2_s5p, tf2_s5t, tf2_s5l, tf2_tr_top, tf2_tr_bot, tf2_brk] = request.security(syminfo.tickerid, tf2, f_wyckoff(pivot_len, vol_mult, breakdown_pct, expiry_pct))

[tf3_phase, tf3_s1p, tf3_s1t, tf3_s2p, tf3_s2t, tf3_s3p, tf3_s3t, tf3_s3l,
 tf3_s4p, tf3_s4t, tf3_s4l, tf3_s5p, tf3_s5t, tf3_s5l, tf3_tr_top, tf3_tr_bot, tf3_brk] = request.security(syminfo.tickerid, tf3, f_wyckoff(pivot_len, vol_mult, breakdown_pct, expiry_pct))

// ── Drawing registries ────────────────────────────────────────────────────────
var box[]   g_boxes = array.new<box>(0)
var line[]  g_lines = array.new<line>(0)
var label[] g_lbls  = array.new<label>(0)

// ── Event label name ──────────────────────────────────────────────────────────
f_ev_name(code) =>
    c = int(math.round(code))
    c == 1 ? "SC" : c == -1 ? "BC" : c == 2 ? "AR" : c == -2 ? "AR" : c == 4 ? "Spring" : c == -4 ? "UTAD" : c == 5 ? "SOS" : c == -5 ? "SOW" : c == 6 ? "LPS" : c == -6 ? "LPSY" : ""

// ── Phase name ────────────────────────────────────────────────────────────────
f_phase_name(ph) =>
    a = math.abs(ph)
    pfx = ph > 0 ? "Acc" : ph < 0 ? "Dist" : ""
    sfx = a == 1 ? " · Phase A" : a == 2 ? " · Phase B" : a == 3 ? " · Phase C" : a == 4 ? " · Phase D" : a == 5 ? " · Phase E" : ""
    pfx + sfx

// ── Draw one Wyckoff structure ────────────────────────────────────────────────
f_draw(ph, s1p, s1t, s2p, s2t, s3p, s3t, s3l, s4p, s4t, s4l, s5p, s5t, s5l, tr_top, tr_bot, is_brk, lw) =>
    if ph != 0 and not na(s1p) and not na(s1t)
        is_acc = ph > 0

        box_t = is_brk ? 93 : 88
        brd_t = is_brk ? 70 : 15
        lne_t = is_brk ? 72 : 20
        lbl_t = is_brk ? 70 : 15

        box_c = is_acc ? color.new(acc_col, box_t) : color.new(dist_col, box_t)
        brd_c = is_acc ? color.new(acc_col, brd_t) : color.new(dist_col, brd_t)
        lne_c = is_acc ? color.new(acc_col, lne_t) : color.new(dist_col, lne_t)
        lbl_c = is_acc ? color.new(acc_col, lbl_t) : color.new(dist_col, lbl_t)
        mid_c = is_acc ? color.new(acc_col, 55)    : color.new(dist_col, 55)

        x1  = int(s1t)
        x2  = is_brk ? (not na(s5t) ? int(s5t) : not na(s4t) ? int(s4t) : not na(s3t) ? int(s3t) : int(s2t)) : int(time)
        ext = is_brk ? extend.none : extend.right

        if not na(tr_top) and not na(tr_bot)
            array.push(g_boxes, box.new(x1, tr_top, x2, tr_bot, xloc=xloc.bar_time, bgcolor=box_c, border_color=brd_c, border_width=lw))

        if not na(s1p)
            s1_x2  = not na(s2t) ? int(s2t) : x2
            s1_ext = is_brk ? extend.none : (not na(s2t) ? extend.none : extend.right)
            array.push(g_lines, line.new(x1, s1p, s1_x2, s1p, xloc=xloc.bar_time, extend=s1_ext, color=lne_c, width=lw, style=line.style_dashed))
        if not na(s2p) and not na(s2t)
            array.push(g_lines, line.new(int(s2t), s2p, x2, s2p, xloc=xloc.bar_time, extend=ext, color=lne_c, width=lw))
        if show_mid and not na(tr_top) and not na(tr_bot)
            mid = (tr_top + tr_bot) / 2.0
            array.push(g_lines, line.new(x1, mid, x2, mid, xloc=xloc.bar_time, extend=ext, color=mid_c, width=1, style=line.style_dashed))

        if show_labels
            s1_name  = is_acc ? "SC" : "BC"
            s1_style = is_acc ? label.style_label_up   : label.style_label_down
            s2_style = is_acc ? label.style_label_down : label.style_label_up
            s3_style = is_acc ? label.style_label_up   : label.style_label_down
            s4_style = is_acc ? label.style_label_down : label.style_label_up
            s5_style = is_acc ? label.style_label_up   : label.style_label_down
            array.push(g_lbls, label.new(x1, s1p, s1_name, xloc=xloc.bar_time, style=s1_style, color=lbl_c, textcolor=color.white, size=size.small))
            if not na(s2p) and not na(s2t)
                array.push(g_lbls, label.new(int(s2t), s2p, "AR", xloc=xloc.bar_time, style=s2_style, color=lbl_c, textcolor=color.white, size=size.small))
            if not na(s3p) and not na(s3t) and not na(s3l)
                array.push(g_lbls, label.new(int(s3t), s3p, f_ev_name(s3l), xloc=xloc.bar_time, style=s3_style, color=lbl_c, textcolor=color.white, size=size.small))
            if not na(s4p) and not na(s4t) and not na(s4l)
                array.push(g_lbls, label.new(int(s4t), s4p, f_ev_name(s4l), xloc=xloc.bar_time, style=s4_style, color=lbl_c, textcolor=color.white, size=size.small))
            if not na(s5p) and not na(s5t) and not na(s5l)
                array.push(g_lbls, label.new(int(s5t), s5p, f_ev_name(s5l), xloc=xloc.bar_time, style=s5_style, color=lbl_c, textcolor=color.white, size=size.small))

        if show_phase and not is_brk
            phase_txt  = f_phase_name(ph)
            phase_y    = is_acc ? tr_top : tr_bot
            array.push(g_lbls, label.new(bar_index + 2, phase_y, phase_txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=lbl_c, textcolor=color.white, size=size.small))

// ── Rebuild at barstate.islast ────────────────────────────────────────────────
if barstate.islast
    n_b = array.size(g_boxes)
    if n_b > 0
        for i = 0 to n_b - 1
            box.delete(array.get(g_boxes, i))
    array.clear(g_boxes)

    n_l = array.size(g_lines)
    if n_l > 0
        for i = 0 to n_l - 1
            line.delete(array.get(g_lines, i))
    array.clear(g_lines)

    n_lb = array.size(g_lbls)
    if n_lb > 0
        for i = 0 to n_lb - 1
            label.delete(array.get(g_lbls, i))
    array.clear(g_lbls)

    if tf3_on and tf3_phase != 0
        f_draw(tf3_phase, tf3_s1p, tf3_s1t, tf3_s2p, tf3_s2t, tf3_s3p, tf3_s3t, tf3_s3l, tf3_s4p, tf3_s4t, tf3_s4l, tf3_s5p, tf3_s5t, tf3_s5l, tf3_tr_top, tf3_tr_bot, tf3_brk, 3)
    if tf2_on and tf2_phase != 0
        f_draw(tf2_phase, tf2_s1p, tf2_s1t, tf2_s2p, tf2_s2t, tf2_s3p, tf2_s3t, tf2_s3l, tf2_s4p, tf2_s4t, tf2_s4l, tf2_s5p, tf2_s5t, tf2_s5l, tf2_tr_top, tf2_tr_bot, tf2_brk, 2)
    if tf1_on and tf1_phase != 0
        f_draw(tf1_phase, tf1_s1p, tf1_s1t, tf1_s2p, tf1_s2t, tf1_s3p, tf1_s3t, tf1_s3l, tf1_s4p, tf1_s4t, tf1_s4l, tf1_s5p, tf1_s5t, tf1_s5l, tf1_tr_top, tf1_tr_bot, tf1_brk, 1)

// ── Alerts ────────────────────────────────────────────────────────────────────
tf1_spring_new = tf1_on and not na(tf1_s3l) and int(math.round(tf1_s3l)) == 4  and not (not na(tf1_s3l[1]) and int(math.round(tf1_s3l[1])) == 4)
tf1_sos_new    = tf1_on and not na(tf1_s4l) and int(math.round(tf1_s4l)) == 5  and not (not na(tf1_s4l[1]) and int(math.round(tf1_s4l[1])) == 5)
tf1_lps_new    = tf1_on and not na(tf1_s5l) and int(math.round(tf1_s5l)) == 6  and not (not na(tf1_s5l[1]) and int(math.round(tf1_s5l[1])) == 6)
tf1_utad_new   = tf1_on and not na(tf1_s3l) and int(math.round(tf1_s3l)) == -4 and not (not na(tf1_s3l[1]) and int(math.round(tf1_s3l[1])) == -4)
tf1_sow_new    = tf1_on and not na(tf1_s4l) and int(math.round(tf1_s4l)) == -5 and not (not na(tf1_s4l[1]) and int(math.round(tf1_s4l[1])) == -5)
tf1_lpsy_new   = tf1_on and not na(tf1_s5l) and int(math.round(tf1_s5l)) == -6 and not (not na(tf1_s5l[1]) and int(math.round(tf1_s5l[1])) == -6)
tf1_brk_new    = tf1_on and tf1_brk and not tf1_brk[1]

alertcondition(tf1_spring_new, "Spring confirmed",  "{{ticker}} — Wyckoff Spring confirmed on TF1 {{interval}}")
alertcondition(tf1_sos_new,    "SOS confirmed",     "{{ticker}} — Sign of Strength confirmed on TF1 {{interval}}")
alertcondition(tf1_lps_new,    "LPS confirmed",     "{{ticker}} — Last Point of Support confirmed on TF1 {{interval}}")
alertcondition(tf1_utad_new,   "UTAD confirmed",    "{{ticker}} — Upthrust After Distribution confirmed on TF1 {{interval}}")
alertcondition(tf1_sow_new,    "SOW confirmed",     "{{ticker}} — Sign of Weakness confirmed on TF1 {{interval}}")
alertcondition(tf1_lpsy_new,   "LPSY confirmed",    "{{ticker}} — Last Point of Supply confirmed on TF1 {{interval}}")
alertcondition(tf1_brk_new,    "Structure broken",  "{{ticker}} — Wyckoff structure invalidated on TF1 {{interval}}")
````
