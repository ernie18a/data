# Wolfe Waves (HTF)

- url: https://www.tradingview.com/script/lMK2Jda9-Wolfe-Waves-HTF/
- type: indicator
- pine_id: PUB;a2ca167b0cfe4b8380a73911116467c6
- version: 3.0

## Description

[b]Wolfe Waves (HTF)[/b]

Detects Wolfe Wave patterns — bullish and bearish — across up to three configurable higher timeframes, drawing the complete geometric structure of each detected pattern: the five-pivot wave skeleton, the 1→3 trend channel, the 2→4 EPA projection line, and the Sweet Zone fill between them.
Wolfe Waves are a five-point reversal pattern from Bill Wolfe's price-action work. The defining geometry: a descending or ascending wedge that overshoots its own trend channel at point 5, with point 5's reversal projected toward an EPA target derived from the 2→4 line. Properly formed Wolfe Waves are relatively rare; they're high-conviction setups when they appear, and the indicator's purpose is to surface them without manual chart-drawing.

[b]How it works[/b]

For each of the three configured timeframes, the script runs Wolfe Wave detection inside request.security. Detection requires five pivots in the correct sequence:[list]
[*]P1, P3, P5 — pivot lows, with P3 < P1 (lower low) and P5 below the trendline connecting P1 and P3 (overshoot of the descending channel)
[*]P2, P4 — pivot highs, with P4 < P2 (lower high) and P4 > P3 (P4 sits above P3)
[*]Symmetry constraint — the time between P1 and P3 must be within tolerance of the time between P3 and P5 (default ±40%). Filters out patterns where swing durations differ wildly.[/list]

Bearish Wolfe Wave mirrors the geometry, with P1/P3/P5 as pivot highs and P2/P4 as pivot lows.
When all conditions are met, three structural elements are computed:[list]
[*]1→3 trend channel — the line through the first and third pivots, extended to the right edge. The "channel" the wave traded inside before the P5 overshoot.
[*]2→4 EPA line — the line through the second and fourth pivots, extended to the right edge. EPA stands for Estimated Price at Arrival — where Wolfe expected price to reverse to after the P5 turn.
[*]Sweet Zone — the area between the 1→3 trend channel and the 2→4 EPA line. The Wolfe framework treats this region as the high-probability reversal zone.[/list]

Each pattern cycles through three visual states:[list]
[*]Active — price is between P5 and the EPA target. The pattern is in play.
[*]Completed — price has reached the EPA line. The Wolfe target has been hit; the pattern resolved as Wolfe predicted.
[*]Failed — price has broken back through P5 in the wrong direction. The pattern has been invalidated.[/list]

[b]How to read it[/b]

Each timeframe gets its own pattern overlay. Color carries direction and state:[list]
[*]Bullish Wolfe (default cyan)
[*]Bearish Wolfe (default orange)
[*]Failed (grey, dimmed) — pattern that broke back through P5[/list]

Active patterns draw:[list]
[*]Wave skeleton — five line segments connecting P1 → P2 → P3 → P4 → P5, with numeric labels at each pivot
[*]1→3 trend channel extended to the right edge
[*]2→4 EPA line extended to the right edge, with an "EPA" label at the projected target point
[*]Sweet Zone fill between the channel and EPA line — the visual emphasis of the framework[/list]

When a pattern completes (price reaches EPA), the structure dims and the fill thins — kept on chart as historical context, visually de-emphasised. When a pattern fails (close back through P5), the lines turn grey-dashed.
The conviction read is geometric: a Wolfe Wave with tight symmetry (P1→P3 duration very close to P3→P5), a clean channel overshoot at P5, and proximity to a higher-timeframe Fibonacci or S/R level is structurally much stronger than a barely-qualifying pattern at random price. This indicator detects the geometry; the cross-checks against other structural tools are where conviction comes from.

[b]Inputs[/b][list]
[*]Pivot Sensitivity — bars required on each side to confirm a pivot. Default 5. Lower values find more pivots and more patterns; higher values restrict to major swings.
[*]Symmetry Tolerance — maximum allowed deviation of the P1→P3 / P3→P5 duration ratio from 1:1. Default ±40%. Tighter values (10–20%) flag only highly symmetric, textbook Wolfes; looser values (60–80%) capture more candidates including imperfect ones.
[*]Timeframes 1/2/3 — defaults: Daily, Weekly, Monthly. All three on by default.
[*]Display toggles — Sweet Zone fill, pivot labels, EPA line and label.
[*]Colors — bullish, bearish.[/list]

[b]Built-in alerts[/b]

This indicator does not currently expose alert conditions. Wolfe Wave detection is most useful as visual structural context rather than real-time triggers — the patterns confirm slowly (P5 has to be a confirmed pivot, which requires pivot length bars of confirmation lag), and the meaningful events happen at EPA arrival, by which point price has moved a long way from the original setup.
If you want alerts: set TradingView alerts on price crossing the published EPA target levels, or on the chart approaching the Sweet Zone, using the on-chart line values.

[b]Notes[/b]

Wolfe Waves are one of the more demanding chart-pattern frameworks. The geometric constraints — channel overshoot at P5, symmetric P1→P3 and P3→P5 durations, correct ordering of all five pivots — eliminate most random pivot clusters that other pattern detectors would happily label as "patterns." A given chart may show no valid Wolfe for weeks or months at a time. This is by design, not a bug. When a valid pattern appears, it's because the geometry is actually there.
The symmetry tolerance is the most impactful setting. The default ±40% is moderate — strict enough to filter out wildly asymmetric setups, loose enough to capture most real Wolfes. Bill Wolfe's original teaching emphasized tighter symmetry (10–20%); modern algorithmic implementations tend to be more permissive. Adjust based on whether you're using this for entry-quality screening (tight) or structural-context awareness (loose).
The EPA target is the framework's headline output. Where most pattern indicators just label the pattern, Wolfe Waves come with a specific price target — the 2→4 line projected forward. This is what makes the framework actionable: it tells you not just "a pattern formed" but "here's where price should arrive if the pattern resolves as expected." When EPA targets coincide with other structural levels (a Fibonacci retracement, a higher-timeframe S/R zone, a Wyckoff phase boundary), conviction goes up substantially.

This indicator pairs naturally with other tools in the collection:[list]
[*][url=https://www.tradingview.com/script/z3oy63SY-Automatic-Fibonacci-Retracement-Levels-MTF/]Automatic Fibonacci Retracement Levels (MTF)[/url] — see if the EPA target aligns with a key Fib level on a higher timeframe
[*][url=https://www.tradingview.com/script/bwgDptmi-Trend-Lines-HTF/]Trend Lines (HTF)[/url] — confirms the 1→3 channel against independently-detected trendlines
[*][url=https://www.tradingview.com/script/cNhHt6hZ-MTF-Support-Resistance-Channels/]MTF Support / Resistance Channels[/url] — cross-references the EPA target against pivot-based S/R zones[/list]

Higher-timeframe pivots don't confirm until pivot length bars after the actual swing. On Monthly with length 5, that's five months of delay between the swing and the pattern appearing. The geometry is non-repainting once it prints.
When no pattern appears on a timeframe, it usually means the recent pivot sequence doesn't satisfy Wolfe's geometric constraints — wrong pivot ordering, insufficient channel overshoot, or symmetry outside tolerance. All normal states. The indicator stays silent rather than fabricating patterns.
This is a structural tool, not a signal generator. It marks the canonical Wolfe geometry and projects the EPA target.

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
//                  Wolfe Waves (HTF)
//                  ──────────────────
//   Detects Wolfe Wave patterns (bullish and bearish) on up to three higher 
//   timeframes and renders the full geometry on the chart as structural
//   context. Each pattern draws the five-pivot wave skeleton, the 1→3 trend
//   channel, the 2→4 EPA projection line, and a Sweet Zone fill between them.
//
//   Patterns cycle through three visual states:
//     Active    — price is between P5 and the EPA target
//     Completed — price has reached the EPA line
//     Failed    — price has broken back through P5 in the wrong direction 
//
//   Pairs with: Automatic Fibonacci Retracement Levels (MTF), Trend Lines (HTF),
//               MTF Support / Resistance Channels
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Wolfe Waves (HTF)", shorttitle="WW HTF", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=50)

// ── Inputs ────────────────────────────────────────────────────────────────────
pivot_len = input.int(5,    "Pivot Sensitivity (bars each side)", minval=2, maxval=20, group="Detection", tooltip="Bars required on each side of a pivot to confirm it on the higher timeframe. Lower = more pivots; higher = major swings only.")
sym_tol   = input.float(0.40, "Symmetry Tolerance",               minval=0.05, maxval=1.0, step=0.05, group="Detection", tooltip="Maximum allowed deviation of the P1→P3 / P3→P5 duration ratio from 1:1. Default ±40%.")

tf1    = input.timeframe("D", "Timeframe 1", group="Timeframes")
tf2    = input.timeframe("W", "Timeframe 2", group="Timeframes")
tf3    = input.timeframe("M", "Timeframe 3", group="Timeframes")
tf1_on = input.bool(true, "Show TF1", group="Timeframes")
tf2_on = input.bool(true, "Show TF2", group="Timeframes")
tf3_on = input.bool(true, "Show TF3", group="Timeframes")

show_sweet_zone = input.bool(true, "Sweet Zone Fill",  group="Display")
show_labels     = input.bool(true, "Pivot Labels",     group="Display")
show_epa        = input.bool(true, "EPA Line & Label", group="Display")

bull_col = input.color(#00bcd4, "Bullish Color", group="Colors")
bear_col = input.color(#ff9800, "Bearish Color", group="Colors")

// ── Helper: interpolate price on a line at time t ─────────────────────────────
line_y_at_t(x1, y1, x2, y2, t) =>
    dx = x2 - x1
    dx != 0.0 ? y1 + (y2 - y1) / dx * (t - x1) : y1

// ── f_wolfe: detect the most recent valid Wolfe Wave on the calling TF ────────
f_wolfe(plen, stol) =>
    var float[] ph_p = array.new<float>()
    var float[] ph_t = array.new<float>()
    var float[] pl_p = array.new<float>()
    var float[] pl_t = array.new<float>()

    _ph = ta.pivothigh(high, plen, plen)
    _pl = ta.pivotlow(low,  plen, plen)
    pbt = int(time[plen])

    if not na(_ph)
        array.unshift(ph_p, _ph)
        array.unshift(ph_t, float(pbt))
        if array.size(ph_p) > 8
            array.pop(ph_p)
            array.pop(ph_t)

    if not na(_pl)
        array.unshift(pl_p, _pl)
        array.unshift(pl_t, float(pbt))
        if array.size(pl_p) > 8
            array.pop(pl_p)
            array.pop(pl_t)

    n_pl = array.size(pl_p)
    n_ph = array.size(ph_p)

    // ── Bullish Wolfe ─────────────────────────────────────────────────────────
    b_p1p = float(na)
    b_p1t = float(na)
    b_p2p = float(na)
    b_p2t = float(na)
    b_p3p = float(na)
    b_p3t = float(na)
    b_p4p = float(na)
    b_p4t = float(na)
    b_p5p = float(na)
    b_p5t = float(na)
    b_valid = 0.0

    if n_pl >= 3 and n_ph >= 2
        for i = 0 to n_pl - 3
            if b_valid == 1.0
                break
            for j = i + 1 to n_pl - 2
                if b_valid == 1.0
                    break
                for k = j + 1 to n_pl - 1
                    if b_valid == 1.0
                        break
                    _p5p = array.get(pl_p, i)
                    _p5t = array.get(pl_t, i)
                    _p3p = array.get(pl_p, j)
                    _p3t = array.get(pl_t, j)
                    _p1p = array.get(pl_p, k)
                    _p1t = array.get(pl_t, k)
                    if not (_p3p < _p1p)
                        continue
                    _p2p = float(na)
                    _p2t = float(na)
                    for m = 0 to n_ph - 1
                        _ht = array.get(ph_t, m)
                        if _ht > _p1t and _ht < _p3t
                            _hp = array.get(ph_p, m)
                            if na(_p2p) or _hp > _p2p
                                _p2p := _hp
                                _p2t := _ht
                    if na(_p2p)
                        continue
                    _p4p = float(na)
                    _p4t = float(na)
                    for m = 0 to n_ph - 1
                        _ht = array.get(ph_t, m)
                        if _ht > _p3t and _ht < _p5t
                            _hp = array.get(ph_p, m)
                            if na(_p4p) or _hp > _p4p
                                _p4p := _hp
                                _p4t := _ht
                    if na(_p4p)
                        continue
                    if not (_p4p < _p2p and _p4p > _p3p)
                        continue
                    if not (_p5p < line_y_at_t(_p1t, _p1p, _p3t, _p3p, _p5t))
                        continue
                    _d13 = _p3t - _p1t
                    _d35 = _p5t - _p3t
                    if _d35 <= 0.0 or math.abs(_d13 / _d35 - 1.0) > stol
                        continue
                    b_p1p := _p1p
                    b_p1t := _p1t
                    b_p2p := _p2p
                    b_p2t := _p2t
                    b_p3p := _p3p
                    b_p3t := _p3t
                    b_p4p := _p4p
                    b_p4t := _p4t
                    b_p5p := _p5p
                    b_p5t := _p5t
                    b_valid := 1.0

    // ── Bearish Wolfe ─────────────────────────────────────────────────────────
    s_p1p = float(na)
    s_p1t = float(na)
    s_p2p = float(na)
    s_p2t = float(na)
    s_p3p = float(na)
    s_p3t = float(na)
    s_p4p = float(na)
    s_p4t = float(na)
    s_p5p = float(na)
    s_p5t = float(na)
    s_valid = 0.0

    if n_ph >= 3 and n_pl >= 2
        for i = 0 to n_ph - 3
            if s_valid == 1.0
                break
            for j = i + 1 to n_ph - 2
                if s_valid == 1.0
                    break
                for k = j + 1 to n_ph - 1
                    if s_valid == 1.0
                        break
                    _p5p = array.get(ph_p, i)
                    _p5t = array.get(ph_t, i)
                    _p3p = array.get(ph_p, j)
                    _p3t = array.get(ph_t, j)
                    _p1p = array.get(ph_p, k)
                    _p1t = array.get(ph_t, k)
                    if not (_p3p > _p1p)
                        continue
                    _p2p = float(na)
                    _p2t = float(na)
                    for m = 0 to n_pl - 1
                        _lt = array.get(pl_t, m)
                        if _lt > _p1t and _lt < _p3t
                            _lp = array.get(pl_p, m)
                            if na(_p2p) or _lp < _p2p
                                _p2p := _lp
                                _p2t := _lt
                    if na(_p2p)
                        continue
                    _p4p = float(na)
                    _p4t = float(na)
                    for m = 0 to n_pl - 1
                        _lt = array.get(pl_t, m)
                        if _lt > _p3t and _lt < _p5t
                            _lp = array.get(pl_p, m)
                            if na(_p4p) or _lp < _p4p
                                _p4p := _lp
                                _p4t := _lt
                    if na(_p4p)
                        continue
                    if not (_p4p > _p2p and _p4p < _p3p)
                        continue
                    if not (_p5p > line_y_at_t(_p1t, _p1p, _p3t, _p3p, _p5t))
                        continue
                    _d13 = _p3t - _p1t
                    _d35 = _p5t - _p3t
                    if _d35 <= 0.0 or math.abs(_d13 / _d35 - 1.0) > stol
                        continue
                    s_p1p := _p1p
                    s_p1t := _p1t
                    s_p2p := _p2p
                    s_p2t := _p2t
                    s_p3p := _p3p
                    s_p3t := _p3t
                    s_p4p := _p4p
                    s_p4t := _p4t
                    s_p5p := _p5p
                    s_p5t := _p5t
                    s_valid := 1.0

    [b_p1p, b_p1t, b_p2p, b_p2t, b_p3p, b_p3t, b_p4p, b_p4t, b_p5p, b_p5t, b_valid,
     s_p1p, s_p1t, s_p2p, s_p2t, s_p3p, s_p3t, s_p4p, s_p4t, s_p5p, s_p5t, s_valid]

// ── request.security calls (one per timeframe) ────────────────────────────────
[tf1_b_p1p, tf1_b_p1t, tf1_b_p2p, tf1_b_p2t, tf1_b_p3p, tf1_b_p3t, tf1_b_p4p, tf1_b_p4t, tf1_b_p5p, tf1_b_p5t, tf1_b_valid, tf1_s_p1p, tf1_s_p1t, tf1_s_p2p, tf1_s_p2t, tf1_s_p3p, tf1_s_p3t, tf1_s_p4p, tf1_s_p4t, tf1_s_p5p, tf1_s_p5t, tf1_s_valid] = request.security(syminfo.tickerid, tf1, f_wolfe(pivot_len, sym_tol), lookahead=barmerge.lookahead_off)

[tf2_b_p1p, tf2_b_p1t, tf2_b_p2p, tf2_b_p2t, tf2_b_p3p, tf2_b_p3t, tf2_b_p4p, tf2_b_p4t, tf2_b_p5p, tf2_b_p5t, tf2_b_valid, tf2_s_p1p, tf2_s_p1t, tf2_s_p2p, tf2_s_p2t, tf2_s_p3p, tf2_s_p3t, tf2_s_p4p, tf2_s_p4t, tf2_s_p5p, tf2_s_p5t, tf2_s_valid] = request.security(syminfo.tickerid, tf2, f_wolfe(pivot_len, sym_tol), lookahead=barmerge.lookahead_off)

[tf3_b_p1p, tf3_b_p1t, tf3_b_p2p, tf3_b_p2t, tf3_b_p3p, tf3_b_p3t, tf3_b_p4p, tf3_b_p4t, tf3_b_p5p, tf3_b_p5t, tf3_b_valid, tf3_s_p1p, tf3_s_p1t, tf3_s_p2p, tf3_s_p2t, tf3_s_p3p, tf3_s_p3t, tf3_s_p4p, tf3_s_p4t, tf3_s_p5p, tf3_s_p5t, tf3_s_valid] = request.security(syminfo.tickerid, tf3, f_wolfe(pivot_len, sym_tol), lookahead=barmerge.lookahead_off)

// ── Time anchors (chart context) ──────────────────────────────────────────────
_now          = float(time)
_bar_dur_ms   = float(time_close - time)

// ── EPA: project the 2→4 line to the current bar ─────────────────────────────
f_epa_now(p2p, p2t, p4p, p4t) =>
    dt = p4t - p2t
    dt != 0.0 ? p2p + (p4p - p2p) / dt * (_now - p2t) : float(na)

tf1_b_epa = f_epa_now(tf1_b_p2p, tf1_b_p2t, tf1_b_p4p, tf1_b_p4t)
tf1_s_epa = f_epa_now(tf1_s_p2p, tf1_s_p2t, tf1_s_p4p, tf1_s_p4t)
tf2_b_epa = f_epa_now(tf2_b_p2p, tf2_b_p2t, tf2_b_p4p, tf2_b_p4t)
tf2_s_epa = f_epa_now(tf2_s_p2p, tf2_s_p2t, tf2_s_p4p, tf2_s_p4t)
tf3_b_epa = f_epa_now(tf3_b_p2p, tf3_b_p2t, tf3_b_p4p, tf3_b_p4t)
tf3_s_epa = f_epa_now(tf3_s_p2p, tf3_s_p2t, tf3_s_p4p, tf3_s_p4t)

// ── Pattern state ─────────────────────────────────────────────────────────────
f_bull_state(valid, p5p, epa) =>
    valid != 1.0 ? 0 : close < p5p ? 3 : not na(epa) and close >= epa ? 2 : 1

f_bear_state(valid, p5p, epa) =>
    valid != 1.0 ? 0 : close > p5p ? 3 : not na(epa) and close <= epa ? 2 : 1

tf1_b_state = f_bull_state(tf1_b_valid, tf1_b_p5p, tf1_b_epa)
tf1_s_state = f_bear_state(tf1_s_valid, tf1_s_p5p, tf1_s_epa)
tf2_b_state = f_bull_state(tf2_b_valid, tf2_b_p5p, tf2_b_epa)
tf2_s_state = f_bear_state(tf2_s_valid, tf2_s_p5p, tf2_s_epa)
tf3_b_state = f_bull_state(tf3_b_valid, tf3_b_p5p, tf3_b_epa)
tf3_s_state = f_bear_state(tf3_s_valid, tf3_s_p5p, tf3_s_epa)

// ── Color helpers ─────────────────────────────────────────────────────────────
f_wave_col(base_col, state) =>
    state == 1 ? color.new(base_col, 0) : state == 2 ? color.new(base_col, 65) : color.new(#78909c, 65)

f_chan_col(base_col, state) =>
    state == 0 ? color.new(base_col, 100) : state == 1 ? color.new(base_col, 20) : state == 2 ? color.new(base_col, 70) : color.new(#78909c, 70)

f_fill_transp(state) =>
    state == 1 ? 90 : 97

// ── Persistent drawing objects ────────────────────────────────────────────────
var line l_tf1_b_12 = na
var line l_tf1_b_23 = na
var line l_tf1_b_34 = na
var line l_tf1_b_45 = na
var line l_tf1_b_ch = na
var line l_tf1_b_ep = na

var line l_tf1_s_12 = na
var line l_tf1_s_23 = na
var line l_tf1_s_34 = na
var line l_tf1_s_45 = na
var line l_tf1_s_ch = na
var line l_tf1_s_ep = na

var line l_tf2_b_12 = na
var line l_tf2_b_23 = na
var line l_tf2_b_34 = na
var line l_tf2_b_45 = na
var line l_tf2_b_ch = na
var line l_tf2_b_ep = na

var line l_tf2_s_12 = na
var line l_tf2_s_23 = na
var line l_tf2_s_34 = na
var line l_tf2_s_45 = na
var line l_tf2_s_ch = na
var line l_tf2_s_ep = na

var line l_tf3_b_12 = na
var line l_tf3_b_23 = na
var line l_tf3_b_34 = na
var line l_tf3_b_45 = na
var line l_tf3_b_ch = na
var line l_tf3_b_ep = na

var line l_tf3_s_12 = na
var line l_tf3_s_23 = na
var line l_tf3_s_34 = na
var line l_tf3_s_45 = na
var line l_tf3_s_ch = na
var line l_tf3_s_ep = na

var label lb_tf1_b_1 = na
var label lb_tf1_b_2 = na
var label lb_tf1_b_3 = na
var label lb_tf1_b_4 = na
var label lb_tf1_b_5 = na
var label lb_tf1_b_e = na
var label lb_tf1_s_1 = na
var label lb_tf1_s_2 = na
var label lb_tf1_s_3 = na
var label lb_tf1_s_4 = na
var label lb_tf1_s_5 = na
var label lb_tf1_s_e = na
var label lb_tf2_b_1 = na
var label lb_tf2_b_2 = na
var label lb_tf2_b_3 = na
var label lb_tf2_b_4 = na
var label lb_tf2_b_5 = na
var label lb_tf2_b_e = na
var label lb_tf2_s_1 = na
var label lb_tf2_s_2 = na
var label lb_tf2_s_3 = na
var label lb_tf2_s_4 = na
var label lb_tf2_s_5 = na
var label lb_tf2_s_e = na
var label lb_tf3_b_1 = na
var label lb_tf3_b_2 = na
var label lb_tf3_b_3 = na
var label lb_tf3_b_4 = na
var label lb_tf3_b_5 = na
var label lb_tf3_b_e = na
var label lb_tf3_s_1 = na
var label lb_tf3_s_2 = na
var label lb_tf3_s_3 = na
var label lb_tf3_s_4 = na
var label lb_tf3_s_5 = na
var label lb_tf3_s_e = na

var linefill lf_tf1_b = na
var linefill lf_tf1_s = na
var linefill lf_tf2_b = na
var linefill lf_tf2_s = na
var linefill lf_tf3_b = na
var linefill lf_tf3_s = na

// ── Upsert helpers ─────────────────────────────────────────────────────────────
upsert_line(ln, x1, y1, x2, y2, col, lw, ext) =>
    _r = ln
    if na(_r)
        _r := line.new(x1, y1, x2, y2, xloc=xloc.bar_time, color=col, width=lw, extend=ext)
    else
        line.set_x1(_r, x1)
        line.set_y1(_r, y1)
        line.set_x2(_r, x2)
        line.set_y2(_r, y2)
        line.set_color(_r, col)
        line.set_width(_r, lw)
        line.set_extend(_r, ext)
    _r

upsert_label(lb, x, y, txt, col, sz, sty) =>
    _r = lb
    if na(_r)
        _r := label.new(x, y, txt, xloc=xloc.bar_time, style=sty, color=col, textcolor=color.white, size=sz)
    else
        label.set_x(_r, x)
        label.set_y(_r, y)
        label.set_text(_r, txt)
        label.set_color(_r, col)
    _r

upsert_linefill(lf, ln1, ln2, col) =>
    _r = lf
    if na(_r)
        _r := linefill.new(ln1, ln2, color=col)
    else
        linefill.set_color(_r, col)
    _r

// ── Pattern drawing function ───────────────────────────────────────────────────
f_draw_pattern(state, is_bull, lw, tf_tag, show_sw, show_lb, show_ep, p1p, p1t, p2p, p2t, p3p, p3t, p4p, p4t, p5p, p5t, epa_val, base_col, chan_col, ln12, ln23, ln34, ln45, lnch, lnep, lb1, lb2, lb3, lb4, lb5, lbe, lf) =>
    _dummy_t = int(time)

    _wc  = state != 0 ? f_wave_col(base_col, state) : color.new(base_col, 100)
    _cc  = state != 0 ? f_chan_col(chan_col, state)  : color.new(chan_col, 100)
    _ftr = f_fill_transp(state)

    _ch_x1 = state != 0 ? int(p1t) : _dummy_t
    _ch_y1 = state != 0 ? p1p : 0.0
    _ch_x2 = state != 0 ? int(p3t) : _dummy_t
    _ch_y2 = state != 0 ? p3p : 0.0

    _ep_x1 = state != 0 ? int(p2t) : _dummy_t
    _ep_y1 = state != 0 ? p2p : 0.0
    _ep_x2 = state != 0 ? int(p4t) : _dummy_t
    _ep_y2 = state != 0 ? p4p : 0.0

    _arr_t = state != 0 ? int(p5t) + int(p5t - p3t) : _dummy_t
    _arr_y = state != 0 ? line_y_at_t(p2t, p2p, p4t, p4p, float(_arr_t)) : 0.0

    _ln12 = upsert_line(ln12, state != 0 ? int(p1t) : _dummy_t, state != 0 ? p1p : 0.0, state != 0 ? int(p2t) : _dummy_t, state != 0 ? p2p : 0.0, _wc, lw, extend.none)
    _ln23 = upsert_line(ln23, state != 0 ? int(p2t) : _dummy_t, state != 0 ? p2p : 0.0, state != 0 ? int(p3t) : _dummy_t, state != 0 ? p3p : 0.0, _wc, lw, extend.none)
    _ln34 = upsert_line(ln34, state != 0 ? int(p3t) : _dummy_t, state != 0 ? p3p : 0.0, state != 0 ? int(p4t) : _dummy_t, state != 0 ? p4p : 0.0, _wc, lw, extend.none)
    _ln45 = upsert_line(ln45, state != 0 ? int(p4t) : _dummy_t, state != 0 ? p4p : 0.0, state != 0 ? int(p5t) : _dummy_t, state != 0 ? p5p : 0.0, _wc, lw, extend.none)

    _lnch = upsert_line(lnch, _ch_x1, _ch_y1, _ch_x2, _ch_y2, _cc, lw, extend.right)
    _lnep = show_ep ? upsert_line(lnep, _ep_x1, _ep_y1, _ep_x2, _ep_y2, _cc, lw, extend.right) : upsert_line(lnep, _dummy_t, 0.0, _dummy_t, 0.0, color.new(base_col, 100), lw, extend.none)

    _fill_col = show_sw and state != 0 ? color.new(base_col, _ftr) : color.new(base_col, 100)
    _lf = upsert_linefill(lf, _lnch, _lnep, _fill_col)

    _sz        = size.small
    _lo_sty    = label.style_label_up
    _hi_sty    = label.style_label_down
    _lb_col    = state != 0 ? _wc : color.new(base_col, 100)
    _p1_sty    = is_bull ? _lo_sty : _hi_sty
    _p2_sty    = is_bull ? _hi_sty : _lo_sty
    _p3_sty    = is_bull ? _lo_sty : _hi_sty
    _p4_sty    = is_bull ? _hi_sty : _lo_sty
    _p5_sty    = is_bull ? _lo_sty : _hi_sty
    _epa_sty   = is_bull ? _hi_sty : _lo_sty
    _blank_col = color.new(base_col, 100)

    _lb1 = show_lb and state != 0 ? upsert_label(lb1, int(p1t), p1p, "1", _lb_col, _sz, _p1_sty) : upsert_label(lb1, _dummy_t, 0.0, "", _blank_col, _sz, label.style_none)
    _lb2 = show_lb and state != 0 ? upsert_label(lb2, int(p2t), p2p, "2", _lb_col, _sz, _p2_sty) : upsert_label(lb2, _dummy_t, 0.0, "", _blank_col, _sz, label.style_none)
    _lb3 = show_lb and state != 0 ? upsert_label(lb3, int(p3t), p3p, "3", _lb_col, _sz, _p3_sty) : upsert_label(lb3, _dummy_t, 0.0, "", _blank_col, _sz, label.style_none)
    _lb4 = show_lb and state != 0 ? upsert_label(lb4, int(p4t), p4p, "4", _lb_col, _sz, _p4_sty) : upsert_label(lb4, _dummy_t, 0.0, "", _blank_col, _sz, label.style_none)
    _lb5 = show_lb and state != 0 ? upsert_label(lb5, int(p5t), p5p, "5", _lb_col, _sz, _p5_sty) : upsert_label(lb5, _dummy_t, 0.0, "", _blank_col, _sz, label.style_none)
    _lbe = show_ep and show_lb and state != 0 ? upsert_label(lbe, _arr_t, _arr_y, "EPA " + tf_tag, _lb_col, _sz, _epa_sty) : upsert_label(lbe, _dummy_t, 0.0, "", _blank_col, _sz, label.style_none)

    [_ln12, _ln23, _ln34, _ln45, _lnch, _lnep, _lb1, _lb2, _lb3, _lb4, _lb5, _lbe, _lf]

// ── Drawing update ─────────────────────────────────────────────────────────────
if barstate.islast

    if tf1_on
        [_l12, _l23, _l34, _l45, _lch, _lep, _b1, _b2, _b3, _b4, _b5, _be, _lf] = f_draw_pattern(tf1_b_state, true, 1, tf1, show_sweet_zone, show_labels, show_epa, tf1_b_p1p, tf1_b_p1t, tf1_b_p2p, tf1_b_p2t, tf1_b_p3p, tf1_b_p3t, tf1_b_p4p, tf1_b_p4t, tf1_b_p5p, tf1_b_p5t, tf1_b_epa, bull_col, color.new(#26a69a, 0), l_tf1_b_12, l_tf1_b_23, l_tf1_b_34, l_tf1_b_45, l_tf1_b_ch, l_tf1_b_ep, lb_tf1_b_1, lb_tf1_b_2, lb_tf1_b_3, lb_tf1_b_4, lb_tf1_b_5, lb_tf1_b_e, lf_tf1_b)
        l_tf1_b_12 := _l12
        l_tf1_b_23 := _l23
        l_tf1_b_34 := _l34
        l_tf1_b_45 := _l45
        l_tf1_b_ch := _lch
        l_tf1_b_ep := _lep
        lb_tf1_b_1 := _b1
        lb_tf1_b_2 := _b2
        lb_tf1_b_3 := _b3
        lb_tf1_b_4 := _b4
        lb_tf1_b_5 := _b5
        lb_tf1_b_e := _be
        lf_tf1_b   := _lf

    if tf1_on
        [_l12, _l23, _l34, _l45, _lch, _lep, _b1, _b2, _b3, _b4, _b5, _be, _lf] = f_draw_pattern(tf1_s_state, false, 1, tf1, show_sweet_zone, show_labels, show_epa, tf1_s_p1p, tf1_s_p1t, tf1_s_p2p, tf1_s_p2t, tf1_s_p3p, tf1_s_p3t, tf1_s_p4p, tf1_s_p4t, tf1_s_p5p, tf1_s_p5t, tf1_s_epa, bear_col, color.new(#ffb74d, 0), l_tf1_s_12, l_tf1_s_23, l_tf1_s_34, l_tf1_s_45, l_tf1_s_ch, l_tf1_s_ep, lb_tf1_s_1, lb_tf1_s_2, lb_tf1_s_3, lb_tf1_s_4, lb_tf1_s_5, lb_tf1_s_e, lf_tf1_s)
        l_tf1_s_12 := _l12
        l_tf1_s_23 := _l23
        l_tf1_s_34 := _l34
        l_tf1_s_45 := _l45
        l_tf1_s_ch := _lch
        l_tf1_s_ep := _lep
        lb_tf1_s_1 := _b1
        lb_tf1_s_2 := _b2
        lb_tf1_s_3 := _b3
        lb_tf1_s_4 := _b4
        lb_tf1_s_5 := _b5
        lb_tf1_s_e := _be
        lf_tf1_s   := _lf

    if tf2_on
        [_l12, _l23, _l34, _l45, _lch, _lep, _b1, _b2, _b3, _b4, _b5, _be, _lf] = f_draw_pattern(tf2_b_state, true, 2, tf2, show_sweet_zone, show_labels, show_epa, tf2_b_p1p, tf2_b_p1t, tf2_b_p2p, tf2_b_p2t, tf2_b_p3p, tf2_b_p3t, tf2_b_p4p, tf2_b_p4t, tf2_b_p5p, tf2_b_p5t, tf2_b_epa, bull_col, color.new(#26a69a, 0), l_tf2_b_12, l_tf2_b_23, l_tf2_b_34, l_tf2_b_45, l_tf2_b_ch, l_tf2_b_ep, lb_tf2_b_1, lb_tf2_b_2, lb_tf2_b_3, lb_tf2_b_4, lb_tf2_b_5, lb_tf2_b_e, lf_tf2_b)
        l_tf2_b_12 := _l12
        l_tf2_b_23 := _l23
        l_tf2_b_34 := _l34
        l_tf2_b_45 := _l45
        l_tf2_b_ch := _lch
        l_tf2_b_ep := _lep
        lb_tf2_b_1 := _b1
        lb_tf2_b_2 := _b2
        lb_tf2_b_3 := _b3
        lb_tf2_b_4 := _b4
        lb_tf2_b_5 := _b5
        lb_tf2_b_e := _be
        lf_tf2_b   := _lf

    if tf2_on
        [_l12, _l23, _l34, _l45, _lch, _lep, _b1, _b2, _b3, _b4, _b5, _be, _lf] = f_draw_pattern(tf2_s_state, false, 2, tf2, show_sweet_zone, show_labels, show_epa, tf2_s_p1p, tf2_s_p1t, tf2_s_p2p, tf2_s_p2t, tf2_s_p3p, tf2_s_p3t, tf2_s_p4p, tf2_s_p4t, tf2_s_p5p, tf2_s_p5t, tf2_s_epa, bear_col, color.new(#ffb74d, 0), l_tf2_s_12, l_tf2_s_23, l_tf2_s_34, l_tf2_s_45, l_tf2_s_ch, l_tf2_s_ep, lb_tf2_s_1, lb_tf2_s_2, lb_tf2_s_3, lb_tf2_s_4, lb_tf2_s_5, lb_tf2_s_e, lf_tf2_s)
        l_tf2_s_12 := _l12
        l_tf2_s_23 := _l23
        l_tf2_s_34 := _l34
        l_tf2_s_45 := _l45
        l_tf2_s_ch := _lch
        l_tf2_s_ep := _lep
        lb_tf2_s_1 := _b1
        lb_tf2_s_2 := _b2
        lb_tf2_s_3 := _b3
        lb_tf2_s_4 := _b4
        lb_tf2_s_5 := _b5
        lb_tf2_s_e := _be
        lf_tf2_s   := _lf

    if tf3_on
        [_l12, _l23, _l34, _l45, _lch, _lep, _b1, _b2, _b3, _b4, _b5, _be, _lf] = f_draw_pattern(tf3_b_state, true, 3, tf3, show_sweet_zone, show_labels, show_epa, tf3_b_p1p, tf3_b_p1t, tf3_b_p2p, tf3_b_p2t, tf3_b_p3p, tf3_b_p3t, tf3_b_p4p, tf3_b_p4t, tf3_b_p5p, tf3_b_p5t, tf3_b_epa, bull_col, color.new(#26a69a, 0), l_tf3_b_12, l_tf3_b_23, l_tf3_b_34, l_tf3_b_45, l_tf3_b_ch, l_tf3_b_ep, lb_tf3_b_1, lb_tf3_b_2, lb_tf3_b_3, lb_tf3_b_4, lb_tf3_b_5, lb_tf3_b_e, lf_tf3_b)
        l_tf3_b_12 := _l12
        l_tf3_b_23 := _l23
        l_tf3_b_34 := _l34
        l_tf3_b_45 := _l45
        l_tf3_b_ch := _lch
        l_tf3_b_ep := _lep
        lb_tf3_b_1 := _b1
        lb_tf3_b_2 := _b2
        lb_tf3_b_3 := _b3
        lb_tf3_b_4 := _b4
        lb_tf3_b_5 := _b5
        lb_tf3_b_e := _be
        lf_tf3_b   := _lf

    if tf3_on
        [_l12, _l23, _l34, _l45, _lch, _lep, _b1, _b2, _b3, _b4, _b5, _be, _lf] = f_draw_pattern(tf3_s_state, false, 3, tf3, show_sweet_zone, show_labels, show_epa, tf3_s_p1p, tf3_s_p1t, tf3_s_p2p, tf3_s_p2t, tf3_s_p3p, tf3_s_p3t, tf3_s_p4p, tf3_s_p4t, tf3_s_p5p, tf3_s_p5t, tf3_s_epa, bear_col, color.new(#ffb74d, 0), l_tf3_s_12, l_tf3_s_23, l_tf3_s_34, l_tf3_s_45, l_tf3_s_ch, l_tf3_s_ep, lb_tf3_s_1, lb_tf3_s_2, lb_tf3_s_3, lb_tf3_s_4, lb_tf3_s_5, lb_tf3_s_e, lf_tf3_s)
        l_tf3_s_12 := _l12
        l_tf3_s_23 := _l23
        l_tf3_s_34 := _l34
        l_tf3_s_45 := _l45
        l_tf3_s_ch := _lch
        l_tf3_s_ep := _lep
        lb_tf3_s_1 := _b1
        lb_tf3_s_2 := _b2
        lb_tf3_s_3 := _b3
        lb_tf3_s_4 := _b4
        lb_tf3_s_5 := _b5
        lb_tf3_s_e := _be
        lf_tf3_s   := _lf
````
