# AM TBR - NQ Stats

- url: https://www.tradingview.com/script/fVikCsIY-AM-TBR-NQ-Stats/
- type: indicator
- pine_id: PUB;f6edd71345204c68a7e7006d4f40b4f5
- version: 1.0

## Description

## Summary

Credit. All historical statistics shown by this indicator are transcribed from the AM TBR study published by NQ Stats — a 10-year analysis of 2,572 NQ sessions (2016–2026). The research design and data analysis are entirely their work; this script is an independent live reconstruction of that methodology

AM TBR anchors a Time-Based Range at the 08:00 New York open, projects ±0.25 standard-deviation levels from that open using a rolling 20-day sample standard deviation of prior session % net changes, and tracks a single, well-defined statistical event in real time: does price touch either level, and if so, does it revert to the TBR Open before 12:00 New York?

Once a touch occurs, the indicator overlays historical context for that exact situation — reversion probability conditional on the hour of the touch, typical adverse excursion (MAE) zones, continuation (MFE) targets after reversion, and time-based cumulative milestones — so you can see at a glance whether the current session is behaving like a typical reverting session or drifting into historically non-reverting territory.

This is a statistical study tool, not a trading system. It does not generate buy/sell signals and makes no claims about future performance.

## What the indicator draws on the chart

At 08:00 New York every weekday the script anchors the TBR Open (drawn as a dashed line extended to 12:00), the two ±0.25σ touch levels, and an optional faint σ ladder at ±0.5 / 0.75 / 1.0 / 1.5 / 2.0 for scale. A light background tint marks the active 08:00–12:00 window.

On the first touch of either level, a marker stamps the exact time (resolved to the minute via lower-timeframe data where available) and shaded MAE zones appear on the touched side. These zones are anchored at the TBR Open — not at the touch level — matching the source study's measurement convention. Reading them from the open outward: the grey zone (TYPICAL) ends at the historical median MAE of sessions that went on to revert; blue (DEEP) ends at the reverted P75; orange (STRETCHED) at the reverted P90; red (RISK) at the median MAE of sessions that never reverted; and the dark zone (NON-REV) extends to the non-reverted P75. The practical reading: while price holds inside grey/blue, the session is taking normal heat for an eventual reversion; pushing through orange into red means the extension now looks more like the historical failures than the historical successes.

If price reverts to the TBR Open before 12:00, the target label flips to REVERTED with the time, and three dotted MFE lines appear on the far side of the open at the historical median (green), P75 (yellow), and P90 (orange) continuation distances — how far past the open reverting sessions historically travelled. At 12:00 the session settles as Reverted, No Reversion, or No Touch.

## Reading the dashboard, row by row

**σ (20d sample).** The rolling standard deviation currently in force, shown both as a percentage and converted to points (e.g. "1.55% ≈ 450.50"). The points figure is your conversion key for every σ value in the table: multiply any σ number by it to get a price distance. A 0.445σ median MAE with σ ≈ 450 points means roughly 200 points of adverse excursion from the open.

**TBR Open (08:00).** The anchor price. Every level, zone, and statistic is measured from here.

**First Touch.** Which level was hit first, the exact time, and the hour band it falls into (08:xx, 09:xx, 10:xx, or 11:xx). The band drives everything below it, because the source study's strongest finding is that reversion odds depend heavily on when the first touch happens.

**Band Reversion Rate.** The historical percentage of sessions with a same-side touch in the same hour band that reverted to the open before 12:00, with its sample size. Colour reflects strength: green at 75%+ (08:xx touches), teal 65–75% (09:xx), orange 45–65%, red below. A ⚠ marks bands where the historical sample is tiny (10:xx and 11:xx, with 48 and 11 touches respectively across ten years) — treat those rates as directional at best.

**Outcome.** The live state machine: Waiting (levels drawn, no touch), Touched — Pending, Reverted ✓ with the reversion time, No Reversion ✗, or No Touch.

**MAE (σ from open).** Your session's maximum adverse extension so far, in σ units measured from the TBR Open, with a context tag comparing it against the reverted-MAE distribution for your band: "≤ p50" means the current heat is smaller than the median reverting session took; "p50–p75" and "p75–p90" mean progressively deeper but still within the range most reverting sessions survived; "> p90 ⚠" means the extension now exceeds nine in ten historical reversions; "≥ non-rev p50 ⚠" means it has reached territory more typical of sessions that never came back. The background shifts green → orange → red accordingly. This row is the single fastest health-check in the table.

## The stat block in depth

The dark header names the exact historical slice being displayed — for example "+0.25 · 08:xx — |σ| FROM TBR OPEN" means every number below describes sessions where +0.25 was touched first during the 08:00 hour, with all distances in σ units from the TBR Open. Signs follow the study's convention: for a +0.25 touch, MAE values print positive (heat is above the open) and MFE prints negative (continuation is below the open); for a −0.25 touch the signs flip.

Each row shows n, Mean, Median, P75, and P90 of a distribution:

**MAE Rev** — adverse excursion of sessions that ultimately reverted. This is the "survivable heat" distribution and the source of the grey/blue/orange zone boundaries. Median well below mean tells you the distribution is right-skewed: most reverting sessions took modest heat, a minority took a lot.

**MAE N-Rev** — maximum extension of sessions that never reverted by 12:00. Compare its median against the MAE-Rev P90: the gap between them is the discrimination region. For 08:xx +0.25 touches, reverting sessions' P90 heat was about 0.96σ while non-reverting sessions' median run was about 1.53σ — extensions between those two values are where the historical populations genuinely separate.

**MFE** — how far beyond the TBR Open reverting sessions continued after reverting. These are the three dotted target lines on the chart. The n here equals the reverted count, since only reverting sessions have an MFE. The large gap between median and P90 (0.69σ vs 1.99σ for 8am +0.25 touches) says continuation is occasionally explosive but usually moderate — which is why the lines are labelled as escalating reference distances rather than a single target.

To convert any cell to points, multiply by the σ-in-points figure from the top of the table.

## The cumulative section

**By 09:00 / 10:00 / 11:00 / 12:00** rows show the source study's cumulative reversion distribution: the percentage of all touched sessions (same side) that had already reverted by that clock time. These figures rise by construction — they are a running total of reversion times, ending at the overall band rate. When your touch is in the 08:xx band, the 8am-focus curve is used (27.9 → 68.2 → 76.1 → 78.4% for +0.25); otherwise the all-sessions curve applies. The Clock column counts down to each checkpoint and to the 12:00 Hard Stop.

Interpreting these correctly matters: a rising cumulative number is not "the odds are improving." The useful live question is conditional — if the session is still pending at a checkpoint, the chance of reverting before 12:00 equals (Final − Cum) ÷ (100 − Cum). Worked from the all-sessions +0.25 curve: still pending at 09:00 leaves roughly a 69% chance of reverting by noon; still pending at 10:00, about 34%; still pending at 11:00, about 10%. The longer a touched session goes without resolving, the more it historically resembles the sessions that never resolved.

## Inputs reference

**Setup group.** *SDEV Lookback* (default 20) sets how many completed daily sessions feed the standard deviation; 20 matches the source study, and changing it moves the levels while decoupling them from the reference statistics. *Touch Level (σ)* (default 0.25) sets the projected level distance — the levels will draw correctly at any value, but all displayed probabilities and distributions were generated for ±0.25 specifically and no longer describe other settings. *TBR Colour* and *Label Size* control appearance. *Keep previous sessions on chart* retains prior sessions' drawings instead of clearing at each new 08:00, useful for visually reviewing recent history (drawings beyond TradingView's object limits are recycled oldest-first).

**Levels group.** *Show σ Ladder* toggles the ±0.5–2.0σ reference lines and *Ladder Colour* styles them. *Show MAE Zones after touch* toggles the shaded zone map; *Zone Labels* independently toggles the text tags on those zones, worth switching off on busy charts. *Show MFE Targets after reversion* toggles the three continuation lines.

**Dashboard group.** *Show Dashboard* toggles the table; *Show Cumulative Milestones* toggles its bottom section if you prefer a shorter table; *Position* and *Text Size* place and scale it.

**Alerts.** Two alert conditions are provided — "Level Touched" and "Reverted to Open." Create them from the standard alert dialog by selecting this indicator and the desired condition; "Once Per Bar" is the natural frequency for both.

## How the statistics were generated (methodology and source)

The probabilities and distribution values displayed by this indicator are **not computed from your chart**. They are transcribed reference statistics from an independently published, publicly available 10-year statistical study of NASDAQ-100 E-mini futures (NQ) covering 2016–2026 (published by NQ Stats). That study's methodology, which this indicator reproduces live:

- **2,572 total sessions** analysed; **2,545 touched** a ±0.25σ level within the window (1,252 touched +0.25 first, 1,293 touched −0.25 first).
- **σ definition:** rolling 20-day *sample* standard deviation of prior session % net changes; the level is projected as TBR Open × (1 ± 0.25 × σ/100).
- **Window:** 08:00–12:00 New York time; a session "reverts" if price returns to the TBR Open after the touch and before 12:00.
- **Headline rates:** 74.0% of +0.25 touches and 74.6% of −0.25 touches reverted, strongly conditional on touch hour: roughly 79% for 08:xx, 69.5% for 09:xx, 39.6% for 10:xx, 9.1% for 11:xx.
- **MAE and MFE** are measured in |σ| units from the TBR Open. Where the study published no distribution rows for a band (MFE for 10/11:xx touches; MAE for 11:xx), the nearest earlier band's values are substituted and documented in the code.

**What is computed live from your chart:** the σ value, the TBR Open, all level and zone prices, touch and reversion detection and timing, and the running MAE. The geometry is yours; the probabilities are the study's, projected onto your chart's coordinates.

## Detection details

On chart timeframes of 1 minute and above, 1-minute intrabar data timestamps the first touch to the exact minute and sequences same-bar events correctly, so a pre-touch dip to the open is never miscounted as a reversion. Where 1-minute history is unavailable (deep chart history), detection falls back to chart-bar resolution with a documented tiebreak. Reversion means trading at or through the TBR Open price.

## Recommended use

NQ / MNQ futures (the reference statistics are NQ-specific; other symbols will run but the statistics will not apply), on 1–15 minute timeframes that divide evenly into an hour so the 08:00 anchor aligns exactly. The most robust historical context comes from 08:xx touches (n ≈ 1,500); late-morning touches carry small samples and wide uncertainty.

## Limitations and honest caveats

Historical frequencies are not probabilities of future outcomes; regimes drift. The live σ may differ slightly from the study's around continuous-contract roll dates, since roll adjustments perturb close-to-close % changes — statistics are σ-relative so behavioural context transfers, but exact prices may differ marginally from the original research. Sub-minute event ordering is unknowable at any bar resolution, and MAE on the reversion bar can be slightly overstated when the adverse extreme printed after the open-cross within the same bar; the underlying 1-minute study shares the same granularity limits. Source values were transcribed from the published tables and not independently re-derived; one internal inconsistency in the source (a single P90 cell differing between two of its tables) is documented in the code with the more internally consistent value chosen.

This indicator is for educational and analytical purposes only and is not financial advice.

---

*Open-source under the Mozilla Public License 2.0. The statistical reference values are transcribed from publicly published research as described above; the live reconstruction, detection engine, and visualisation are original work.*

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © lucymatos

//@version=6
indicator("AM TBR — NQ Stats", "AM-TBR", true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)

// ============================================================================
// INPUTS
// ============================================================================

var g_S = "Setup"
i_lookback  = input.int(20, "SDEV Lookback (sessions)", minval=5, maxval=60, group=g_S)
i_mult      = input.float(0.25, "Touch Level (σ)", minval=0.05, step=0.05, group=g_S)
i_col       = input.color(color.new(color.gray, 0), "TBR Colour", group=g_S)
i_lbl_size  = input.string("Tiny", "Label Size", options=["Tiny","Small","Normal"], group=g_S)
i_keep_hist = input.bool(false, "Keep previous sessions on chart", group=g_S)

var g_L = "Levels"
i_show_ladder = input.bool(true,  "Show σ Ladder (±0.5→2.0)", group=g_L)
i_ladder_col  = input.color(color.new(color.gray, 72), "Ladder Colour", group=g_L)
i_show_zones  = input.bool(true,  "Show MAE Zones after touch", group=g_L)
i_zone_lbls   = input.bool(true,  "Zone Labels", group=g_L)
i_show_mfe    = input.bool(true,  "Show MFE Targets after reversion", group=g_L)

var g_TBL = "Dashboard"
i_show_table = input.bool(true, "Show Dashboard", group=g_TBL)
i_show_miles = input.bool(true, "Show Cumulative Milestones", group=g_TBL)
i_tbl_pos    = input.string("Top Right", "Position", options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=g_TBL)
i_tbl_size   = input.string("Small", "Text Size", options=["Tiny","Small","Normal"], group=g_TBL)

// ============================================================================

get_stats(band, side) =>
    if band == 8 and side == 1
        array.from(78.4, 732.0, 0.0,
             574.0, 0.553, 0.445, 0.645, 0.957,
             158.0, 1.623, 1.528, 1.882, 2.317,
             574.0, 0.913, 0.687, 1.180, 1.993)
    else if band == 8 and side == 2
        array.from(79.6, 774.0, 0.0,
             616.0, 0.559, 0.441, 0.645, 0.969,
             158.0, 2.005, 1.749, 2.450, 3.208,
             616.0, 0.807, 0.619, 1.131, 1.722)
    else if band == 9 and side == 1
        array.from(69.7, 492.0, 0.0,
             343.0, 0.435, 0.363, 0.508, 0.697,
             149.0, 1.184, 1.095, 1.457, 1.689,
             343.0, 0.628, 0.430, 0.755, 1.515)
    else if band == 9 and side == 2
        array.from(69.3, 488.0, 0.0,
             338.0, 0.469, 0.382, 0.541, 0.769,
             150.0, 1.398, 1.239, 1.702, 2.283,
             338.0, 0.481, 0.362, 0.667, 1.091)
    else if band == 10 and side == 1
        array.from(47.6, 21.0, 1.0,
             10.0, 0.401, 0.335, 0.421, 0.608,
             11.0, 0.620, 0.631, 0.828, 0.896,
             343.0, 0.628, 0.430, 0.755, 1.515)
    else if band == 10 and side == 2
        array.from(33.3, 27.0, 1.0,
             9.0, 0.374, 0.390, 0.413, 0.442,
             18.0, 0.728, 0.656, 0.964, 1.158,
             338.0, 0.481, 0.362, 0.667, 1.091)
    else if side == 1
        array.from(0.0, 7.0, 1.0,
             10.0, 0.401, 0.335, 0.421, 0.608,
             11.0, 0.620, 0.631, 0.828, 0.896,
             343.0, 0.628, 0.430, 0.755, 1.515)
    else
        array.from(25.0, 4.0, 1.0,
             9.0, 0.374, 0.390, 0.413, 0.442,
             18.0, 0.728, 0.656, 0.964, 1.158,
             338.0, 0.481, 0.362, 0.667, 1.091)

// Cumulative reversion milestones [by09, by10, by11, by12]
get_milestones(band, side) =>
    if band == 8 and side == 1
        [27.9, 68.2, 76.1, 78.4]
    else if band == 8 and side == 2
        [28.8, 68.7, 76.7, 79.6]
    else if side == 1
        [16.3, 60.4, 71.2, 74.0]
    else
        [17.2, 60.2, 70.8, 74.6]

// ============================================================================
// HELPERS
// ============================================================================

tbl_pos(s) =>
    switch s
        "Top Left"     => position.top_left
        "Top Center"   => position.top_center
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

tbl_sz(s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        => size.small

zone_status(z) =>
    switch z
        0 => "TYPICAL"
        1 => "DEEP"
        2 => "STRETCHED"
        3 => "RISK"
        => "NON-REV"

zone_fill(z) =>
    switch z
        0 => color.new(color.gray,   80)
        1 => color.new(color.blue,   80)
        2 => color.new(color.orange, 80)
        3 => color.new(color.red,    80)
        => color.new(#37474f,        80)

zone_border(z) =>
    switch z
        0 => color.new(color.gray,   40)
        1 => color.new(color.blue,   40)
        2 => color.new(color.orange, 40)
        3 => color.new(color.red,    40)
        => color.new(#37474f,        40)

// ============================================================================

f_sigma() =>
    chg = (close - close[1]) / close[1] * 100.0
    ta.stdev(chg, i_lookback, false)   // biased=false → SAMPLE stdev

daily_sigma = request.security(syminfo.tickerid, "D", f_sigma()[1], lookahead=barmerge.lookahead_on)

// ============================================================================

ltf_tf = timeframe.in_seconds() >= 60 ? "1" : timeframe.period
[ltf_open_arr, ltf_high_arr, ltf_low_arr, ltf_time_arr] = request.security_lower_tf(syminfo.tickerid, ltf_tf, [open, high, low, time], ignore_invalid_symbol=true)

find_touch(upL, dnL) =>
    side = 0
    t    = int(na)
    idx  = -1
    n = array.size(ltf_high_arr)
    if n > 0
        for i = 0 to n - 1
            h1 = array.get(ltf_high_arr, i)
            l1 = array.get(ltf_low_arr,  i)
            hitU = h1 >= upL
            hitD = l1 <= dnL
            if hitU or hitD
                if hitU and hitD
                    o1 = array.get(ltf_open_arr, i)
                    side := upL - o1 <= o1 - dnL ? 1 : 2
                else
                    side := hitU ? 1 : 2
                t   := array.get(ltf_time_arr, i)
                idx := i
                break
    [side, t, idx]

find_rev(fromIdx, side, openP) =>
    rt = int(na)
    n = array.size(ltf_high_arr)
    if n > 0 and fromIdx >= 0 and fromIdx < n
        for i = fromIdx to n - 1
            l1 = array.get(ltf_low_arr,  i)
            h1 = array.get(ltf_high_arr, i)
            if (side == 1 and l1 <= openP) or (side == 2 and h1 >= openP)
                rt := array.get(ltf_time_arr, i)
                break
    rt

// ============================================================================
// STATE
// ============================================================================

var bool  v_active     = false
var float v_tbr_open   = na
var float v_sigma_pct  = na
var float v_sigma_px   = na
var float v_upL        = na
var float v_dnL        = na
var int   v_touch_side = 0      // 0=none 1=+0.25 2=−0.25
var int   v_touch_time = na
var int   v_touch_band = na     // 8 / 9 / 10 / 11
var int   v_touch_bar  = na     // [FIX-1] chart bar_index of the touch bar
var int   v_rev_time   = na
var int   v_outcome    = 0      // 0 wait 1 pending 2 reverted 3 no-rev 4 no-touch
var float v_max_ext    = 0.0
var int   v_ts_09      = na
var int   v_ts_10      = na
var int   v_ts_11      = na
var int   v_ts_12      = na

var array<float> S = array.new<float>()
var float m_by09 = na
var float m_by10 = na
var float m_by11 = na
var float m_by12 = na

Sget(i) => array.size(S) > 0 ? array.get(S, i) : na

// Drawing handles
var line  d_open_line = na
var label d_open_lbl  = na
var line  d_up_line   = na
var line  d_dn_line   = na
var label d_up_lbl    = na
var label d_dn_lbl    = na
var label d_touch_lbl = na
var array<line>  d_ladder_lines = array.new<line>()
var array<label> d_ladder_lbls  = array.new<label>()
var array<box>   d_zone_boxes   = array.new<box>()
var array<label> d_zone_labels  = array.new<label>()
var array<line>  d_mfe_lines    = array.new<line>()
var array<label> d_mfe_labels   = array.new<label>()

// ============================================================================
// CLEAR HELPERS
// ============================================================================

purge_lines(arr, del) =>
    if array.size(arr) > 0
        if del
            for i = 0 to array.size(arr) - 1
                line.delete(array.get(arr, i))
        array.clear(arr)

purge_labels(arr, del) =>
    if array.size(arr) > 0
        if del
            for i = 0 to array.size(arr) - 1
                label.delete(array.get(arr, i))
        array.clear(arr)

purge_boxes(arr, del) =>
    if array.size(arr) > 0
        if del
            for i = 0 to array.size(arr) - 1
                box.delete(array.get(arr, i))
        array.clear(arr)

clear_all(del) =>
    if del
        line.delete(d_open_line)
        label.delete(d_open_lbl)
        line.delete(d_up_line)
        line.delete(d_dn_line)
        label.delete(d_up_lbl)
        label.delete(d_dn_lbl)
        label.delete(d_touch_lbl)
    purge_lines(d_ladder_lines,  del)
    purge_labels(d_ladder_lbls,  del)
    purge_boxes(d_zone_boxes,    del)
    purge_labels(d_zone_labels,  del)
    purge_lines(d_mfe_lines,     del)
    purge_labels(d_mfe_labels,   del)

// ============================================================================
// DRAW  — MAE zones (anchored at TBR Open, touched side only)
// ============================================================================

draw_zones(side, t_left, t_right) =>
    purge_boxes(d_zone_boxes,   true)
    purge_labels(d_zone_labels, true)
    if i_show_zones and array.size(S) > 0
        bnds = array.from(i_mult, array.get(S, 5), array.get(S, 6), array.get(S, 7), array.get(S, 10), array.get(S, 11))
        for z = 0 to 4
            b_lo = array.get(bnds, z)
            b_hi = array.get(bnds, z + 1)
            if b_hi > b_lo
                float p_lo = na
                float p_hi = na
                if side == 1
                    p_lo := v_tbr_open + b_lo * v_sigma_px
                    p_hi := v_tbr_open + b_hi * v_sigma_px
                else
                    p_lo := v_tbr_open - b_hi * v_sigma_px
                    p_hi := v_tbr_open - b_lo * v_sigma_px

                bx = box.new(t_left, p_hi, t_right, p_lo,
                     xloc=xloc.bar_time,
                     border_color=zone_border(z), bgcolor=zone_fill(z),
                     border_width=1)
                array.push(d_zone_boxes, bx)

                if i_zone_lbls
                    txt = str.tostring(b_hi, "#.##") + "σ · " + zone_status(z)
                    lbl = label.new(t_right, (p_lo + p_hi) / 2.0, txt,
                         xloc=xloc.bar_time, yloc=yloc.price,
                         style=label.style_label_left,
                         color=color.new(color.white, 25),
                         textcolor=zone_border(z), size=tbl_sz(i_lbl_size),
                         text_font_family=font.family_monospace)
                    array.push(d_zone_labels, lbl)

// ============================================================================
// DRAW  — MFE continuation targets (far side of open, after reversion)
// ============================================================================

draw_mfe(side, t_left, t_right) =>
    purge_lines(d_mfe_lines,   true)
    purge_labels(d_mfe_labels, true)
    if i_show_mfe and array.size(S) > 0
        mfe_vals = array.from(array.get(S, 15), array.get(S, 16), array.get(S, 17))
        mfe_lbls = array.from("MFE p50", "MFE p75", "MFE p90")
        mfe_cols = array.from(color.new(color.green, 20), color.new(color.yellow, 20), color.new(color.orange, 20))
        for r = 0 to 2
            mv = array.get(mfe_vals, r)
            float mp = side == 1 ? v_tbr_open - mv * v_sigma_px : v_tbr_open + mv * v_sigma_px
            mc = array.get(mfe_cols, r)
            ln = line.new(t_left, mp, t_right, mp,
                 xloc=xloc.bar_time, color=mc, width=1,
                 style=line.style_dotted)
            array.push(d_mfe_lines, ln)
            lbl = label.new(t_right, mp,
                 array.get(mfe_lbls, r) + " " + str.tostring(mv, "#.##") + "σ",
                 xloc=xloc.bar_time, yloc=yloc.price,
                 style=label.style_label_left,
                 color=color.new(color.white, 25),
                 textcolor=mc, size=tbl_sz(i_lbl_size),
                 text_font_family=font.family_monospace)
            array.push(d_mfe_labels, lbl)

// ============================================================================
// MAIN
// ============================================================================

in_win    = not na(time(timeframe.period, "0800-1200:23456", "America/New_York"))
win_start = in_win and not in_win[1]
win_end   = (not in_win) and in_win[1]

// ── 08:00 — anchor TBR, project levels ───────────────────────────────────────
if win_start and not na(daily_sigma) and daily_sigma > 0
    clear_all(not i_keep_hist)
    v_active     := true
    v_outcome    := 0
    v_touch_side := 0
    v_touch_time := na
    v_touch_band := na
    v_touch_bar  := na
    v_rev_time   := na
    v_max_ext    := 0.0
    array.clear(S)

    v_tbr_open  := open
    v_sigma_pct := daily_sigma
    v_sigma_px  := v_tbr_open * daily_sigma / 100.0
    v_upL       := v_tbr_open + i_mult * v_sigma_px
    v_dnL       := v_tbr_open - i_mult * v_sigma_px

    yy = year(time,       "America/New_York")
    mm = month(time,      "America/New_York")
    dd = dayofmonth(time, "America/New_York")
    v_ts_09 := timestamp("America/New_York", yy, mm, dd,  9, 0)
    v_ts_10 := timestamp("America/New_York", yy, mm, dd, 10, 0)
    v_ts_11 := timestamp("America/New_York", yy, mm, dd, 11, 0)
    v_ts_12 := timestamp("America/New_York", yy, mm, dd, 12, 0)

    d_open_line := line.new(time, v_tbr_open, v_ts_12, v_tbr_open,
         xloc=xloc.bar_time, color=color.fuchsia, width=1,
         style=line.style_dashed)
    d_open_lbl := label.new(v_ts_12, v_tbr_open, "TBR OPEN",
         xloc=xloc.bar_time, yloc=yloc.price,
         style=label.style_label_left,
         color=color.new(color.white, 10),
         textcolor=color.fuchsia, size=tbl_sz(i_lbl_size),
         text_font_family=font.family_monospace)

    d_up_line := line.new(time, v_upL, v_ts_12, v_upL,
         xloc=xloc.bar_time, color=color.new(i_col, 20), width=2)
    d_dn_line := line.new(time, v_dnL, v_ts_12, v_dnL,
         xloc=xloc.bar_time, color=color.new(i_col, 20), width=2)
    d_up_lbl := label.new(v_ts_12, v_upL,
         "+" + str.tostring(i_mult, "#.##") + "σ",
         xloc=xloc.bar_time, yloc=yloc.price,
         style=label.style_label_left,
         color=color.new(color.white, 10),
         textcolor=color.new(i_col, 10), size=tbl_sz(i_lbl_size),
         text_font_family=font.family_monospace)
    d_dn_lbl := label.new(v_ts_12, v_dnL,
         "−" + str.tostring(i_mult, "#.##") + "σ",
         xloc=xloc.bar_time, yloc=yloc.price,
         style=label.style_label_left,
         color=color.new(color.white, 10),
         textcolor=color.new(i_col, 10), size=tbl_sz(i_lbl_size),
         text_font_family=font.family_monospace)

    if i_show_ladder
        mults = array.from(0.5, 0.75, 1.0, 1.5, 2.0)
        for k = 0 to array.size(mults) - 1
            mlt = array.get(mults, k)
            for sgn = 0 to 1
                lp = sgn == 0 ? v_tbr_open + mlt * v_sigma_px : v_tbr_open - mlt * v_sigma_px
                ln = line.new(time, lp, v_ts_12, lp,
                     xloc=xloc.bar_time, color=i_ladder_col, width=1,
                     style=line.style_dotted)
                array.push(d_ladder_lines, ln)
                lbl = label.new(v_ts_12, lp,
                     (sgn == 0 ? "+" : "−") + str.tostring(mlt, "#.##") + "σ",
                     xloc=xloc.bar_time, yloc=yloc.price,
                     style=label.style_none,
                     color=color.new(color.white, 100),
                     textcolor=i_ladder_col, size=size.tiny,
                     text_font_family=font.family_monospace)
                array.push(d_ladder_lbls, lbl)

// ── 08:00–12:00 — touch & reversion tracking ─────────────────────────────────
if v_active and in_win and v_outcome <= 1
    if v_touch_side == 0
        if high >= v_upL or low <= v_dnL
            [t_side0, t_time0, t_idx0] = find_touch(v_upL, v_dnL)
            int f_side = t_side0
            int f_time = t_time0
            int f_idx  = t_idx0
            // [FIX-2] no intrabar data (deep history) → chart-level classify
            if f_side == 0
                hitU = high >= v_upL
                hitD = low <= v_dnL
                if hitU and hitD
                    f_side := v_upL - open <= open - v_dnL ? 1 : 2
                else
                    f_side := hitU ? 1 : 2
                f_time := time
                f_idx  := -1

            v_touch_side := f_side
            v_touch_time := na(f_time) ? time : f_time
            v_touch_band := hour(v_touch_time, "America/New_York")
            v_touch_bar  := bar_index
            v_outcome    := 1
            v_max_ext    := f_side == 1 ? (high - v_tbr_open) / v_sigma_px : (v_tbr_open - low) / v_sigma_px
            S := get_stats(v_touch_band, f_side)
            [b9, b10, b11, b12] = get_milestones(v_touch_band, f_side)
            m_by09 := b9
            m_by10 := b10
            m_by11 := b11
            m_by12 := b12

            label.delete(d_touch_lbl)
            tp = f_side == 1 ? v_upL : v_dnL
            t_txt = (f_side == 1 ? "▼ +" : "▲ −") + str.tostring(i_mult, "#.##") + "σ " + str.format_time(v_touch_time, "HH:mm", "America/New_York")
            t_sty = f_side == 1 ? label.style_label_down : label.style_label_up
            t_bg  = color.new(f_side == 1 ? color.red : color.green, 30)
            d_touch_lbl := label.new(v_touch_time, tp, t_txt,
                 xloc=xloc.bar_time, yloc=yloc.price,
                 style=t_sty, color=t_bg,
                 textcolor=color.white, size=tbl_sz(i_lbl_size),
                 text_font_family=font.family_monospace)

            draw_zones(f_side, v_touch_time, v_ts_12)

            if not na(d_open_lbl)
                label.set_text(d_open_lbl, "TARGET: TBR OPEN")

            // Touch-bar reversion: LTF scan from the touch minute onward is
            // the ONLY authority on this bar ([FIX-1])
            rt = find_rev(f_idx, f_side, v_tbr_open)
            if not na(rt)
                v_rev_time := rt
                v_outcome  := 2

    if v_touch_side != 0 and v_outcome == 1
        ext = v_touch_side == 1 ? (high - v_tbr_open) / v_sigma_px : (v_tbr_open - low) / v_sigma_px
        v_max_ext := math.max(v_max_ext, ext)

        // [FIX-1] skip the sequence-blind chart-level check on the touch bar —
        // a pre-touch dip to open would otherwise register as a reversion
        if bar_index != v_touch_bar
            hit = (v_touch_side == 1 and low <= v_tbr_open) or (v_touch_side == 2 and high >= v_tbr_open)
            if hit
                rt = find_rev(0, v_touch_side, v_tbr_open)
                v_rev_time := na(rt) ? time : rt
                v_outcome  := 2

    if v_outcome == 2 and v_outcome[1] != 2
        if not na(d_open_lbl)
            rev_txt = "REVERTED ✓ " + str.format_time(v_rev_time, "HH:mm", "America/New_York")
            label.set_text(d_open_lbl, rev_txt)
            label.set_textcolor(d_open_lbl, color.green)
        draw_mfe(v_touch_side, v_rev_time, v_ts_12)

// ── 12:00 — hard stop, settle outcome ────────────────────────────────────────
if v_active and win_end
    if v_touch_side == 0
        v_outcome := 4
        if not na(d_open_lbl)
            label.set_text(d_open_lbl, "NO TOUCH")
            label.set_textcolor(d_open_lbl, color.gray)
    else if v_outcome == 1
        v_outcome := 3
        if not na(d_open_lbl)
            label.set_text(d_open_lbl, "NO REVERSION ✗")
            label.set_textcolor(d_open_lbl, color.red)

bgcolor(v_active and in_win ? color.new(i_col, 96) : na)

// ============================================================================
// ALERTS
// ============================================================================

touch_evt = v_touch_side != 0 and v_touch_side[1] == 0
rev_evt   = v_outcome == 2 and v_outcome[1] != 2
alertcondition(touch_evt, "AM TBR — Level Touched", "AM TBR: ±0.25σ level touched. Reversion-to-open study active.")
alertcondition(rev_evt, "AM TBR — Reverted to Open", "AM TBR: price reverted to TBR Open. MFE continuation targets drawn.")

// ============================================================================
// DASHBOARD  — single table, website-style stat blocks
// ============================================================================

f_cellm(t, c0, c1, r, txt, bg, tc, tsz, hal) =>
    table.cell(t, c0, r, txt, bgcolor=bg, text_color=tc, text_size=tsz,
         text_halign=hal, text_font_family=font.family_monospace)
    if c1 > c0
        for c = c0 + 1 to c1
            table.cell(t, c, r, "", bgcolor=bg, text_size=tsz)
        table.merge_cells(t, c0, r, c1, r)

f_info(t, r, lbl, val, val_bg, val_tc, tsz) =>
    f_cellm(t, 0, 2, r, lbl, color.white, color.rgb(40, 40, 40), tsz, text.align_left)
    f_cellm(t, 3, 5, r, val, val_bg, val_tc, tsz, text.align_right)

f_stat(t, r, name, sgn, nv, mn, md, p75, p90, name_tc, tsz) =>
    CEL_TX = color.rgb(40, 40, 40)
    table.cell(t, 0, r, name, bgcolor=color.rgb(245, 245, 245),
         text_color=name_tc, text_size=tsz, text_halign=text.align_left,
         text_font_family=font.family_monospace)
    table.cell(t, 1, r, str.tostring(nv, "#"), bgcolor=color.white,
         text_color=color.rgb(120, 120, 120), text_size=tsz,
         text_font_family=font.family_monospace)
    table.cell(t, 2, r, sgn + str.tostring(mn, "#.##") + "σ", bgcolor=color.white,
         text_color=CEL_TX, text_size=tsz, text_font_family=font.family_monospace)
    table.cell(t, 3, r, sgn + str.tostring(md, "#.##") + "σ", bgcolor=color.white,
         text_color=CEL_TX, text_size=tsz, text_font_family=font.family_monospace)
    table.cell(t, 4, r, sgn + str.tostring(p75, "#.##") + "σ", bgcolor=color.white,
         text_color=CEL_TX, text_size=tsz, text_font_family=font.family_monospace)
    table.cell(t, 5, r, sgn + str.tostring(p90, "#.##") + "σ", bgcolor=color.white,
         text_color=CEL_TX, text_size=tsz, text_font_family=font.family_monospace)

var table tbl = na

if i_show_table and barstate.islast
    table.delete(tbl)
    tsz    = tbl_sz(i_tbl_size)
    HDR_BG = color.rgb(30, 30, 30)
    SUB_BG = color.rgb(60, 60, 60)
    CEL_TX = color.rgb(40, 40, 40)

    tbl := table.new(tbl_pos(i_tbl_pos), 6, 20,
         bgcolor=color.white, border_color=color.rgb(200, 200, 200),
         border_width=1, frame_color=color.rgb(64, 64, 64), frame_width=2)
    row = 0

    // ── Title ────────────────────────────────────────────────────────────────
    title_txt = "AM TBR · ±" + str.tostring(i_mult, "#.##") + "σ REVERSION · 08:00–12:00 NY"
    f_cellm(tbl, 0, 5, row, title_txt, HDR_BG, color.white, tsz, text.align_center)
    row += 1

    // ── Session info ─────────────────────────────────────────────────────────
    string sig_str = "—"
    if not na(v_sigma_pct)
        sig_str := str.tostring(v_sigma_pct, "#.##") + "% ≈ " + str.tostring(v_sigma_px, format.mintick)
    f_info(tbl, row, "σ (" + str.tostring(i_lookback) + "d sample)", sig_str, color.white, CEL_TX, tsz)
    row += 1

    string open_str = na(v_tbr_open) ? "—" : str.tostring(v_tbr_open, format.mintick)
    f_info(tbl, row, "TBR Open (08:00)", open_str, color.white, CEL_TX, tsz)
    row += 1

    string tstr = "Awaiting touch"
    if v_touch_side != 0
        tt = str.format_time(v_touch_time, "HH:mm", "America/New_York")
        tstr := (v_touch_side == 1 ? "+" : "−") + str.tostring(i_mult, "#.##") + "σ @ " + tt
        tstr := tstr + " · " + str.tostring(v_touch_band, "00") + ":xx band"
    f_info(tbl, row, "First Touch", tstr, color.white, CEL_TX, tsz)
    row += 1

    if v_touch_side != 0
        rate   = Sget(0)
        n_t    = Sget(1)
        smalln = Sget(2) > 0.5
        color rate_bg = color.new(color.red, 55)
        if rate >= 75.0
            rate_bg := color.new(color.green, 55)
        else if rate >= 65.0
            rate_bg := color.new(color.teal, 55)
        else if rate >= 45.0
            rate_bg := color.new(color.orange, 55)
        rate_str = str.tostring(rate, "#.#") + "%  (n=" + str.tostring(n_t, "#") + (smalln ? " ⚠)" : ")")
        f_info(tbl, row, "Band Reversion Rate", rate_str, rate_bg, color.white, tsz)
        row += 1

    string outc_str = "Waiting…"
    color  outc_bg  = color.new(color.gray, 85)
    color  outc_tx  = CEL_TX
    if v_outcome == 1
        outc_str := "Touched — Pending"
        outc_bg  := color.new(color.blue, 80)
    else if v_outcome == 2
        outc_str := "Reverted ✓ " + str.format_time(v_rev_time, "HH:mm", "America/New_York")
        outc_bg  := color.new(color.green, 55)
        outc_tx  := color.white
    else if v_outcome == 3
        outc_str := "No Reversion ✗"
        outc_bg  := color.new(color.red, 55)
        outc_tx  := color.white
    else if v_outcome == 4
        outc_str := "No Touch"
    f_info(tbl, row, "Outcome", outc_str, outc_bg, outc_tx, tsz)
    row += 1

    if v_touch_side != 0 and v_max_ext > 0
        string mae_ctx = "≥ non-rev p50 ⚠"
        color  mae_bg  = color.new(color.red, 60)
        if v_max_ext <= Sget(5)
            mae_ctx := "≤ p50"
            mae_bg  := color.new(color.green, 72)
        else if v_max_ext <= Sget(6)
            mae_ctx := "p50–p75"
            mae_bg  := color.new(color.green, 72)
        else if v_max_ext <= Sget(7)
            mae_ctx := "p75–p90"
            mae_bg  := color.new(color.orange, 65)
        else if v_max_ext <= Sget(10)
            mae_ctx := "> p90 ⚠"
        f_info(tbl, row, "MAE (σ from open)", str.tostring(v_max_ext, "#.##") + "σ · " + mae_ctx, mae_bg, CEL_TX, tsz)
        row += 1

    // ── Stat blocks (website style) ──────────────────────────────────────────
    if v_touch_side == 0
        f_cellm(tbl, 0, 5, row, "MAE / MFE stats populate on first touch", color.rgb(245, 245, 245), color.rgb(140, 140, 140), tsz, text.align_center)
        row += 1
    else
        mae_sgn = v_touch_side == 1 ? "+" : "-"
        mfe_sgn = v_touch_side == 1 ? "-" : "+"

        sec_hdr = (v_touch_side == 1 ? "+" : "−") + str.tostring(i_mult, "#.##") + " · " + str.tostring(v_touch_band, "00") + ":xx — |σ| FROM TBR OPEN"
        f_cellm(tbl, 0, 5, row, sec_hdr, SUB_BG, color.white, tsz, text.align_center)
        row += 1

        hdr_txt = array.from("", "n", "Mean", "Median", "P75", "P90")
        for c = 0 to 5
            table.cell(tbl, c, row, array.get(hdr_txt, c), bgcolor=HDR_BG,
                 text_color=color.rgb(160, 160, 160), text_size=tsz,
                 text_font_family=font.family_monospace)
        row += 1

        f_stat(tbl, row, "MAE Rev",   mae_sgn, Sget(3),  Sget(4),  Sget(5),  Sget(6),  Sget(7),  color.new(color.green, 20), tsz)
        row += 1
        f_stat(tbl, row, "MAE N-Rev", mae_sgn, Sget(8),  Sget(9),  Sget(10), Sget(11), Sget(12), color.new(color.red, 20), tsz)
        row += 1
        f_stat(tbl, row, "MFE",       mfe_sgn, Sget(13), Sget(14), Sget(15), Sget(16), Sget(17), color.new(color.blue, 20), tsz)
        row += 1

    // ── Cumulative reversion milestones + hard stop ──────────────────────────
    if i_show_miles and v_touch_side != 0
        f_cellm(tbl, 0, 5, row, "CUMULATIVE REVERSION", SUB_BG, color.white, tsz, text.align_center)
        row += 1

        now_ms   = timenow
        ms_lbls  = array.from("By 09:00", "By 10:00", "By 11:00", "By 12:00")
        ms_rates = array.from(m_by09, m_by10, m_by11, m_by12)
        ms_times = array.from(v_ts_09, v_ts_10, v_ts_11, v_ts_12)

        for pi = 0 to 3
            mts    = array.get(ms_times, pi)
            passed = now_ms >= mts
            rem_m  = math.round((mts - now_ms) / 60000.0)

            string status = str.tostring(rem_m) + "m left"
            color  st_bg  = rem_m > 30 ? color.new(#1a3a5c, 25) : color.new(color.orange, 55)
            color  st_tx  = color.white
            if v_outcome == 2
                status := "✓ done"
                st_bg  := color.new(color.green, 60)
            else if passed
                status := "—"
                st_bg  := color.rgb(240, 240, 240)
                st_tx  := color.rgb(150, 150, 150)

            f_cellm(tbl, 0, 1, row, array.get(ms_lbls, pi), color.white, CEL_TX, tsz, text.align_left)
            f_cellm(tbl, 2, 3, row, str.tostring(array.get(ms_rates, pi), "#.#") + "% cum", color.white, color.rgb(90, 90, 90), tsz, text.align_center)
            f_cellm(tbl, 4, 5, row, status, st_bg, st_tx, tsz, text.align_center)
            row += 1

        hs_rem    = math.round((v_ts_12 - now_ms) / 60000.0)
        hs_passed = now_ms >= v_ts_12
        hs_str = hs_passed ? "EXPIRED" : str.tostring(hs_rem) + "m left"
        hs_bg  = hs_passed ? color.new(color.red, 40) : color.rgb(40, 20, 20)
        hs_tc  = hs_passed ? color.white : color.new(color.red, 20)
        f_cellm(tbl, 0, 1, row, "Hard Stop", color.rgb(255, 235, 235), color.rgb(180, 0, 0), tsz, text.align_left)
        f_cellm(tbl, 2, 3, row, "12:00 NY", color.rgb(255, 235, 235), color.rgb(180, 0, 0), tsz, text.align_center)
        f_cellm(tbl, 4, 5, row, hs_str, hs_bg, hs_tc, tsz, text.align_center)
````
