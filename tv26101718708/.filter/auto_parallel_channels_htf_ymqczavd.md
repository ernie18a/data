# Auto Parallel Channels (HTF)

- url: https://www.tradingview.com/script/YMQcZAVD-Auto-Parallel-Channels-HTF/
- type: indicator
- pine_id: PUB;30e53cca69154c7bb5747b0779593747
- version: 1.0

## Description

[b]Auto Parallel Channels (HTF)[/b]

Auto-detected parallel channels drawn between confirmed pivot highs and pivot lows on up to three higher timeframes. A channel forms only when two pivot highs and two pivot lows produce trendlines that are actually parallel within a configurable slope tolerance — the indicator stays silent when the geometry implies a triangle, wedge, or unstructured noise rather than a true channel.
The point is to surface validated parallel structure on multiple horizons without fabricating channels through every cluster of swings.

[b]How it works[/b]

For each of the three configured timeframes, the script runs pivot detection inside request.security and tracks the two most recent pivot highs and the two most recent pivot lows. It then asks a strict question: would these four pivots produce a parallel channel?
The check works by:[list=1]
[*]Computing the slope of the upper line (between the two pivot highs) and the slope of the lower line (between the two pivot lows).
[*]Projecting the channel width at the second high and at one channel-length forward.
[*]Accepting the channel only if the width changes by less than slope_tol between those two points.[/list]

If the slopes diverge — converging into a wedge or fanning out — the channel is rejected and nothing is drawn. This is deliberate: a channel that isn't parallel isn't a channel.
A valid channel is marked broken when close on the timeframe's own bars exceeds either boundary. Broken channels stop extending right and dim. All lines and labels rebuild on the last bar to keep projections current.

[b]How to read it[/b]

Each timeframe has its own color (defaults: indigo for TF1, amber for TF2, teal for TF3). Line weight increases with timeframe — thin for TF1, medium for TF2, thick for TF3 — so the dominant higher timeframe reads first.
Visual elements per channel:[list]
[*]Upper boundary — solid line through the two pivot highs, extending to the right edge.
[*]Lower boundary — solid line through the two pivot lows, extending to the right edge.
[*]Midline — dashed line through the centre of the channel, optional.
[*]Right-edge labels — projected upper, midline, and lower prices one channel-length forward (▲ upper, ─ midline, ▼ lower).[/list]
When channels from different timeframes overlap or share boundaries, that's confluence — a higher-timeframe boundary respected by a lower-timeframe channel is the more meaningful structural reference.

[b]Inputs[/b]
[list]
[*]Pivot length — bars required on each side to confirm a pivot. Default 9. Higher values find fewer, more significant pivots. Shared across all three timeframes.
[*]Slope tolerance — how much the channel width can change over one channel-length before the structure is rejected. Default 0.35 (35% width change accepted, handles slight wedging). Set to 0.0 for perfectly parallel only; raise to 0.5–0.7 if too few channels appear.
[*]Timeframes 1/2/3 — defaults: 4H, Daily, Weekly. All three on by default.
[*]Colors — one per timeframe.
[*]Midline — toggle the dashed centre line. Default on.
[*]Right-edge labels — toggle the upper/midline/lower price labels at the projected forward edge. Default on.
[/list]

[b]Built-in alerts[/b]
[list]
[*]Channel formed — fires when a new valid channel is detected on any enabled timeframe
[*]Channel broken — fires when an active channel is broken by close on any enabled timeframe[/list]

[b]Notes[/b]

The strict parallelism check is this indicator's most opinionated design choice. Most auto-channel tools draw something on any four pivots, even when the geometry is clearly a wedge or triangle. This one refuses — if the slopes don't match within tolerance, no channel appears. Fewer channels, higher quality.
If you've also published Auto Parallel Channel (HTF) (singular): that indicator builds a single pitchfork-style channel from three of the last four zigzag pivots, with no parallelism validation. This one (plural) draws a separate channel per timeframe, validated for actual parallel geometry. They use different definitions of "channel" and will produce different output on the same chart. Pick the one whose definition matches your intent — or use both, treating the singular one as approximate structure and this one as confirmed parallel structure.
The pivot length is shared across all three timeframes by design here. Most parallel structures have similar swing-density requirements regardless of timeframe — a length that finds meaningful pivots on the daily usually finds meaningful pivots on the weekly too, just spaced further apart in calendar time. If one timeframe is over- or under-detecting, adjust the slope tolerance rather than the pivot length.
Higher-timeframe pivots don't confirm until pivot length bars after the actual high or low. On Weekly with length 9, that's nine weeks of delay between the swing and the channel appearing. Geometry is non-repainting once it prints.
When no channel appears on a timeframe, it usually means either (a) fewer than two pivot highs and two pivot lows have accumulated, or (b) the pivots that exist don't form a parallel structure within tolerance. Both are normal states. Lower the pivot length to speed up (a); raise the slope tolerance to relax (b).
This is a structural tool, not a signal generator. It surfaces validated parallel channels on each higher timeframe and flags when price has broken them.

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
//                Auto Parallel Channels (HTF)
//                ──────────────────────────────
//   Projects three configurable higher-timeframe parallel channels directly
//   onto the price chart.  Each channel is built from confirmed pivot highs
//   and lows on its own timeframe via request.security() — genuinely HTF
//   structure, not a longer window of chart-timeframe bars.
//
//   A channel is only drawn when two confirmed pivot highs and two confirmed
//   pivot lows form a geometrically parallel structure within the configured
//   slope tolerance.  When the lines diverge too far (triangle or wedge
//   geometry), the indicator stays silent rather than drawing a fabricated
//   channel through unstructured price.
//
//   Once active, channels extend to the right edge with right-edge price
//   labels at the upper, midline, and lower boundaries.  When price closes
//   outside the channel on its own HTF, the lines dim and stop extending —
//   same convention as the suite's other structural indicators.
//
//   Visual hierarchy follows the suite's one-color-per-TF, thin-to-thick
//   tier-weight convention: TF 1 carries the lightest lines, TF 3 the
//   heaviest, so the dominant higher timeframe always reads first.
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Auto Parallel Channels (HTF)", shorttitle="APCh", overlay=true, max_lines_count=30, max_labels_count=20)

// ── Inputs ───────────────────────────────────────────────────────────────────
pivot_len = input.int(9,   "Pivot length",      minval=2, maxval=50,  group="Detection", tooltip="Number of bars required on each side of a pivot high or low to confirm it as structural. Higher values find fewer, more significant pivots; lower values are more sensitive to minor swings.")
slope_tol = input.float(0.35, "Slope tolerance", minval=0.0, maxval=1.0, step=0.05, group="Detection", tooltip="How much the channel width can change over one channel-length before the structure is rejected as non-parallel. 0 = perfectly parallel only; 0.35 = up to 35% width change accepted (handles slight wedging). Raise to 0.5-0.7 if few channels are appearing.")

tf1_on = input.bool(true, "TF 1", group="Timeframes", inline="tf1")
tf1    = input.timeframe("240", "", group="Timeframes", inline="tf1")
tf2_on = input.bool(true, "TF 2", group="Timeframes", inline="tf2")
tf2    = input.timeframe("D",   "", group="Timeframes", inline="tf2")
tf3_on = input.bool(true, "TF 3", group="Timeframes", inline="tf3")
tf3    = input.timeframe("W",   "", group="Timeframes", inline="tf3")

tf1_col = input.color(#5c6bc0, "TF 1", group="Colors", inline="c1")
tf2_col = input.color(#f59e0b, "TF 2", group="Colors", inline="c2")
tf3_col = input.color(#26a69a, "TF 3", group="Colors", inline="c3")

show_mid    = input.bool(true, "Midline",             group="Display")
show_labels = input.bool(true, "Right-edge labels",   group="Display")

// ── Channel detection (runs inside each request.security context) ─────────────
f_ch() =>
    ph = ta.pivothigh(high, pivot_len, pivot_len)
    pl = ta.pivotlow(low,  pivot_len, pivot_len)

    var float ph1_p = na
    var float ph1_t = na
    var float ph2_p = na
    var float ph2_t = na
    var float pl1_p = na
    var float pl1_t = na
    var float pl2_p = na
    var float pl2_t = na
    var bool  brk   = false

    if not na(ph)
        ph2_p := ph1_p
        ph2_t := ph1_t
        ph1_p := ph
        ph1_t := float(time[pivot_len])
        brk   := false

    if not na(pl)
        pl2_p := pl1_p
        pl2_t := pl1_t
        pl1_p := pl
        pl1_t := float(time[pivot_len])
        brk   := false

    has_both = not na(ph1_p) and not na(ph2_p) and not na(pl1_p) and not na(pl2_p)

    slope_h = has_both ? (ph1_p - ph2_p) / math.max(ph1_t - ph2_t, 1.0) : float(na)
    slope_l = has_both ? (pl1_p - pl2_p) / math.max(pl1_t - pl2_t, 1.0) : float(na)

    is_valid = false
    if has_both and not na(slope_h) and not na(slope_l)
        proj_l_ref = pl1_p + slope_l * (ph1_t - pl1_t)
        ch_w_ref   = ph1_p - proj_l_ref
        span       = math.abs(ph1_t - ph2_t)
        ch_w_fut   = (ph1_p + slope_h * span) - (pl1_p + slope_l * (ph1_t + span - pl1_t))
        is_valid  := ch_w_ref > 0.0 and math.abs(ch_w_fut - ch_w_ref) / ch_w_ref < slope_tol

    if is_valid and not brk and not na(slope_h) and not na(slope_l)
        proj_h_now = ph1_p + slope_h * (float(time) - ph1_t)
        proj_l_now = pl1_p + slope_l * (float(time) - pl1_t)
        if close > proj_h_now or close < proj_l_now
            brk := true

    [ph1_p, ph1_t, ph2_p, ph2_t, pl1_p, pl1_t, pl2_p, pl2_t, is_valid, brk]

// ── Request HTF channel state ─────────────────────────────────────────────────
[tf1_ph1p, tf1_ph1t, tf1_ph2p, tf1_ph2t,
 tf1_pl1p, tf1_pl1t, tf1_pl2p, tf1_pl2t,
 tf1_valid, tf1_brk] = request.security(syminfo.tickerid, tf1, f_ch())

[tf2_ph1p, tf2_ph1t, tf2_ph2p, tf2_ph2t,
 tf2_pl1p, tf2_pl1t, tf2_pl2p, tf2_pl2t,
 tf2_valid, tf2_brk] = request.security(syminfo.tickerid, tf2, f_ch())

[tf3_ph1p, tf3_ph1t, tf3_ph2p, tf3_ph2t,
 tf3_pl1p, tf3_pl1t, tf3_pl2p, tf3_pl2t,
 tf3_valid, tf3_brk] = request.security(syminfo.tickerid, tf3, f_ch())

// ── Drawing registries ────────────────────────────────────────────────────────
var line[]  g_lns = array.new<line>(0)
var label[] g_lbs = array.new<label>(0)

// ── Per-TF channel draw ───────────────────────────────────────────────────────
f_draw(ph1p, ph1t, ph2p, ph2t, pl1p, pl1t, pl2p, pl2t, is_valid, brk, col, lw) =>
    if is_valid
        slope_h = (ph1p - ph2p) / math.max(ph1t - ph2t, 1.0)
        slope_l = (pl1p - pl2p) / math.max(pl1t - pl2t, 1.0)

        line_col = brk ? color.new(col, 72) : color.new(col, 15)
        mid_col  = brk ? color.new(col, 80) : color.new(col, 38)
        ext      = brk ? extend.none : extend.right

        array.push(g_lns, line.new(int(ph2t), ph2p, int(ph1t), ph1p, xloc=xloc.bar_time, extend=ext, color=line_col, width=lw))

        array.push(g_lns, line.new(int(pl2t), pl2p, int(pl1t), pl1p, xloc=xloc.bar_time, extend=ext, color=line_col, width=lw))

        if show_mid
            mid_at_ph2t = (ph2p + (pl1p + slope_l * (ph2t - pl1t))) / 2.0
            mid_at_ph1t = (ph1p + (pl1p + slope_l * (ph1t - pl1t))) / 2.0
            array.push(g_lns, line.new(int(ph2t), mid_at_ph2t, int(ph1t), mid_at_ph1t, xloc=xloc.bar_time, extend=ext, color=mid_col, width=1, style=line.style_dashed))

        if show_labels and not brk
            span      = ph1t - ph2t
            label_t   = int(ph1t + span)
            proj_h_lb = ph1p + slope_h * span
            proj_l_lb = pl1p + slope_l * (ph1t + span - pl1t)
            proj_m_lb = (proj_h_lb + proj_l_lb) / 2.0
            array.push(g_lbs, label.new(label_t, proj_h_lb, "▲  " + str.tostring(proj_h_lb, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(col, 15), textcolor=color.white, size=size.small))
            array.push(g_lbs, label.new(label_t, proj_m_lb, "─  " + str.tostring(proj_m_lb, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(col, 38), textcolor=color.white, size=size.small))
            array.push(g_lbs, label.new(label_t, proj_l_lb, "▼  " + str.tostring(proj_l_lb, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(col, 15), textcolor=color.white, size=size.small))

// ── Rebuild all drawings at barstate.islast ───────────────────────────────────
if barstate.islast
    n_ln = array.size(g_lns)
    if n_ln > 0
        for i = 0 to n_ln - 1
            line.delete(array.get(g_lns, i))
    array.clear(g_lns)

    n_lb = array.size(g_lbs)
    if n_lb > 0
        for i = 0 to n_lb - 1
            label.delete(array.get(g_lbs, i))
    array.clear(g_lbs)

    if tf3_on and tf3_valid
        f_draw(tf3_ph1p, tf3_ph1t, tf3_ph2p, tf3_ph2t, tf3_pl1p, tf3_pl1t, tf3_pl2p, tf3_pl2t, tf3_valid, tf3_brk, tf3_col, 3)
    if tf2_on and tf2_valid
        f_draw(tf2_ph1p, tf2_ph1t, tf2_ph2p, tf2_ph2t, tf2_pl1p, tf2_pl1t, tf2_pl2p, tf2_pl2t, tf2_valid, tf2_brk, tf2_col, 2)
    if tf1_on and tf1_valid
        f_draw(tf1_ph1p, tf1_ph1t, tf1_ph2p, tf1_ph2t, tf1_pl1p, tf1_pl1t, tf1_pl2p, tf1_pl2t, tf1_valid, tf1_brk, tf1_col, 1)

// ── Alerts ────────────────────────────────────────────────────────────────────
tf1_new_ch  = tf1_on and tf1_valid and not tf1_valid[1]
tf2_new_ch  = tf2_on and tf2_valid and not tf2_valid[1]
tf3_new_ch  = tf3_on and tf3_valid and not tf3_valid[1]
tf1_new_brk = tf1_on and tf1_brk   and not tf1_brk[1]
tf2_new_brk = tf2_on and tf2_brk   and not tf2_brk[1]
tf3_new_brk = tf3_on and tf3_brk   and not tf3_brk[1]

alertcondition(tf1_new_ch or tf2_new_ch or tf3_new_ch,     "Channel formed",  "{{ticker}} — parallel channel formed on {{interval}}")
alertcondition(tf1_new_brk or tf2_new_brk or tf3_new_brk, "Channel broken",  "{{ticker}} — parallel channel broken on {{interval}}")
````
