# VWAP VP IB ATR Multi Dashboard

- url: https://www.tradingview.com/script/P3OfoEry-VWAP-VP-IB-ATR-Multi-Dashboard/
- type: indicator
- pine_id: PUB;a0c2b538845a4953a2fddf09599f39e6
- version: 1.0

## Description

Dashboard monitors 3 assets

Globex VWAP
Session VWAP - Tokyo (Asia), London, New York (RTH)
IB - Initial Balance

When inside the bands then it will display In Value and outside Discovery

ATR for the current timeframe. Can be adjusted with number of bars to look back and it displays that number

Madonna - Coined by Chris Drysdale IB gets touched for the very first time

## Source Code

````pine
//@version=6
indicator("VWAP VP IB ATR Multi Dashboard", overlay=true)

// ═══════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════
var g_set = "Settings"
i_pos         = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=g_set)
i_band_mult   = input.float(1.0, "Band Multiplier", minval=0.1, step=0.1, group=g_set)
i_text_size   = input.string("normal", "Text Size", options=["tiny","small","normal","large"], group=g_set)
i_rth_session   = input.session("0930-1700", "RTH Session (NY time)",       group=g_set)
i_tok_session   = input.session("0900-1500", "Tokyo Session (Tokyo time)",     group=g_set,
     tooltip="Used for Tokyo VWAP/SVP. Default 09:00–15:00 Tokyo time.")
i_lon_session   = input.session("0800-1630", "London Session (London time)",  group=g_set,
     tooltip="Used for London VWAP/SVP. Default 08:00–16:30 London time.")
i_mad_nq_pts  = input.float(40.0,  "Madonna Proximity NQ (pts)", minval=1, step=0.25, group=g_set)
i_mad_es_pts  = input.float(10.0,  "Madonna Proximity ES (pts)", minval=1, step=0.25, group=g_set)
i_mad_ym_pts  = input.float(50.0,  "Madonna Proximity YM (pts)", minval=1, step=0.25, group=g_set)
i_ib_session  = input.session("0930-1030", "IB Session (NY time, first hour)", group=g_set,
     tooltip="Initial Balance: high/low of this window defines the IB range. Default 09:30–10:30.")
i_atr_len     = input.int(14, "ATR Length", minval=1, maxval=100, group=g_set)
i_svp_va_pct  = input.float(70.0, "SVP Value Area %", minval=1, maxval=99, group=g_set)
i_svp_rows    = input.int(200, "SVP Row Count", minval=20, maxval=400, group=g_set)


var g_sym = "Symbols"
i_nq_sym  = input.symbol("NQ1!", "NQ Symbol", group=g_sym)
i_es_sym  = input.symbol("ES1!", "ES Symbol", group=g_sym)
i_ym_sym  = input.symbol("YM1!", "YM Symbol", group=g_sym)

var g_col = "Colors"
i_above_col   = input.color(color.new(#26A69A, 0),  "Above VWAP",      group=g_col)
i_below_col   = input.color(color.new(#EF5350, 0),  "Below VWAP",      group=g_col)
i_ext_col     = input.color(color.new(#FF9800, 0),  "Outside Band",    group=g_col)
i_inval_col   = input.color(color.new(#29B6F6, 0),  "In Value",        group=g_col)
i_disc_col    = input.color(color.new(#AB47BC, 0),  "Price Discovery", group=g_col)
i_header_col  = input.color(color.new(#37474F, 0),  "Header BG",       group=g_col)
i_subhdr_col  = input.color(color.new(#263238, 0),  "Sub-header BG",   group=g_col)
i_bg_col      = input.color(color.new(#1C2030, 90), "Table BG",        group=g_col)
i_na_col      = input.color(color.new(#607D8B, 0),  "Outside Session", group=g_col)

// ═══════════════════════════════════════════════════════════
// CORE VWAP LOGIC
// ═══════════════════════════════════════════════════════════
f_globex_vwap(float src, float vol, bool is_new_day, simple float mult) =>
    var float cpv = 0.0, var float cpv2 = 0.0, var float cvol = 0.0
    if is_new_day
        cpv := src * vol, cpv2 := src * src * vol, cvol := vol
    else
        cpv += src * vol, cpv2 += src * src * vol, cvol += vol
    float v = cvol > 0 ? cpv / cvol : na
    float u = na, float d = na
    if not na(v)
        float dev = math.sqrt(math.max(0.0, (cpv2 / cvol) - (v * v)))
        u := v + dev * mult, d := v - dev * mult
    [v, u, d]

f_rth_vwap(float src, float vol, bool in_sess, bool sess_open, simple float mult) =>
    var float cpv = 0.0, var float cpv2 = 0.0, var float cvol = 0.0
    if sess_open
        cpv := src * vol, cpv2 := src * src * vol, cvol := vol
    else if in_sess
        cpv += src * vol, cpv2 += src * src * vol, cvol += vol
    else
        cpv := 0.0, cpv2 := 0.0, cvol := 0.0
    float v = in_sess and cvol > 0 ? cpv / cvol : na
    float u = na, float d = na
    if not na(v)
        float dev = math.sqrt(math.max(0.0, (cpv2 / cvol) - (v * v)))
        u := v + dev * mult, d := v - dev * mult
    [v, u, d]


// f_session_vwap: Three-session VWAP — Tokyo → London → RTH.
// Resets at each session open. Returns which session is active via phase:
//   0 = outside all sessions, 1 = Tokyo, 2 = London, 3 = RTH
f_session_vwap(float src, float vol,
               bool in_tok, bool tok_open,
               bool in_lon, bool lon_open,
               bool in_rth, bool rth_open,
               simple float mult) =>
    var float cpv   = 0.0, var float cpv2 = 0.0, var float cvol = 0.0
    var int   phase = 0   // 0=off 1=Tokyo 2=London 3=RTH

    bool sess_open = tok_open or lon_open or rth_open
    bool in_sess   = in_tok or in_lon or in_rth

    if sess_open
        cpv  := src * vol
        cpv2 := src * src * vol
        cvol := vol
        phase := rth_open ? 3 : lon_open ? 2 : 1
    else if in_sess
        cpv  += src * vol
        cpv2 += src * src * vol
        cvol += vol
    else
        cpv  := 0.0, cpv2 := 0.0, cvol := 0.0

    float v = in_sess and cvol > 0 ? cpv / cvol : na
    float u = na, float d = na
    if not na(v)
        float dev = math.sqrt(math.max(0.0, (cpv2 / cvol) - (v * v)))
        u := v + dev * mult, d := v - dev * mult
    [v, u, d, phase, in_sess]


// ═══════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════
// MADONNA — IB boundary touch alert
// After the IB is established (ib_forming = false):
//   - Price must be inside the IB range first
//   - Once inside, if price comes within 40pts of either
//     boundary, show distance to the nearer side
//   - On first wick touch (hi >= ib_hi or lo <= ib_lo):
//     lock the result as touched (green=high, red=low)
//   - Once touched, stays locked for the rest of the day
// Returns [status, dist, touched, touch_side]
//   status:     0=not ready, 1=watching, 2=approaching, 3=touched
//   dist:       points to nearer boundary (na if not approaching)
//   touch_side: 1=high touched, -1=low touched, 0=none
// ═══════════════════════════════════════════════════════════
f_madonna(float hi, float lo, float cls,
          float ib_hi, float ib_lo, bool ib_forming,
          bool ib_open, bool rth_close, simple float proximity_pts) =>
    var int   status     = 0   // 0=not ready 1=was inside 2=approaching 3=touched
    var float dist       = na
    var int   touch_side = 0   // 1=high -1=low

    // Reset on market close (17:00 NY) — blank overnight
    if rth_close
        status     := 0
        dist       := na
        touch_side := 0

    // Reset on new IB window open (09:30 NY)
    if ib_open
        status     := 0
        dist       := na
        touch_side := 0

    // Only active once IB is established
    if not ib_forming and not na(ib_hi) and not na(ib_lo)
        if status == 3
            // Already touched — stay locked, do nothing
            na
        else if status == 0 or status == 1
            // Check if price is inside IB range
            if cls >= ib_lo and cls <= ib_hi
                status := 1   // price has been inside — now watching
            // If still status 0 (never been inside) keep waiting

        if status == 1 or status == 2
            // Check for touch first (wick)
            if hi >= ib_hi
                status     := 3
                dist       := na
                touch_side := 1
            else if lo <= ib_lo
                status     := 3
                dist       := na
                touch_side := -1
            else
                // Check proximity to either boundary
                float dist_hi = ib_hi - cls
                float dist_lo = cls   - ib_lo
                if dist_hi <= proximity_pts or dist_lo <= proximity_pts
                    // Approaching — show distance to nearer boundary
                    dist   := dist_hi <= dist_lo ? dist_hi : -dist_lo
                    status := 2
                else
                    dist   := na
                    if status == 2
                        status := 1   // moved away from boundary

    [status, dist, touch_side]

// ═══════════════════════════════════════════════════════════
// SESSION VOLUME PROFILE
// Anchors at 18:00 ET, accumulates volume into price buckets,
// computes POC / VAH / VAL live on each bar.
// Returns [vah, val] — the value area boundaries used for the
// "In Value" / "Discovery ▲/▼" status check.
// ═══════════════════════════════════════════════════════════
f_svp_levels(array<float> vols, float plo, float phi, simple float va_pct) =>
    float vah = na, float val = na
    int n = array.size(vols)
    if n > 0 and not na(plo) and phi > plo
        int   poc_row = 0
        float poc_vol = 0.0
        float total   = 0.0
        for r = 0 to n - 1
            float v = array.get(vols, r)
            total += v
            if v > poc_vol
                poc_vol := v
                poc_row := r
        float step   = (phi - plo) / n
        float target = total * va_pct / 100.0
        float va_vol = poc_vol
        int   va_lo  = poc_row
        int   va_hi  = poc_row
        if n > 1
            for _i = 0 to n - 2
                bool  can_up = va_hi < n - 1
                bool  can_dn = va_lo > 0
                float v_up   = can_up ? array.get(vols, va_hi + 1) : 0.0
                float v_dn   = can_dn ? array.get(vols, va_lo - 1) : 0.0
                if not can_up and not can_dn
                    break
                if v_up >= v_dn
                    va_hi += 1, va_vol += v_up
                else
                    va_lo -= 1, va_vol += v_dn
                if va_vol >= target
                    break
        vah := plo + (va_hi + 1) * step
        val := plo + va_lo       * step
    [vah, val]

// f_svp: Globex SVP anchored at 18:00 ET daily.
// CRITICAL FIX: sess_lo/sess_hi are set ONLY on the first bar of each session
// and never expanded. This ensures bucket boundaries are fixed absolute price
// levels throughout the session so VAH/VAL remain accurate as price extends.
// A generous initial range (first bar ± 5× the first bar range) is used to
// ensure the profile covers the full day without needing to expand.
f_svp(float hi, float lo, float vol, int bar_t,
      simple int rows, simple float va_pct) =>
    int   GLOBEX_SHIFT_MS = 18 * 60 * 60 * 1000
    int   DAY_MS          = 86400000
    int   globex_day      = int(math.floor((bar_t - GLOBEX_SHIFT_MS) / DAY_MS))
    var int          last_day = -1
    var array<float> vols     = array.new<float>(rows, 0.0)
    var float        sess_lo  = na
    var float        sess_hi  = na

    bool is_new_day = globex_day != last_day
    if is_new_day
        last_day := globex_day
        array.fill(vols, 0.0)
        // Anchor range: centre on first bar midpoint, extend ±10× bar range
        // to cover the full session without needing to expand later
        float bar_mid   = (hi + lo) / 2.0
        // Use a large enough range to cover the full session without clamping.
        // Minimum 500 ticks ensures quiet opening bars don't produce a
        // range too narrow to capture the full day's price action.
        float bar_range = math.max(hi - lo, syminfo.mintick * 500)
        sess_lo := bar_mid - bar_range * 3
        sess_hi := bar_mid + bar_range * 3

    if not na(sess_lo) and not na(sess_hi) and sess_hi > sess_lo and vol > 0
        float rng  = sess_hi - sess_lo
        float span = math.max(hi - lo, syminfo.mintick)
        int r_lo = math.max(0,        int(math.floor((lo - sess_lo) / rng * rows)))
        int r_hi = math.min(rows - 1, int(math.floor((hi - sess_lo) / rng * rows)))
        if r_lo <= r_hi
            for r = r_lo to r_hi
                float row_lo  = sess_lo + r       * rng / rows
                float row_hi  = sess_lo + (r + 1) * rng / rows
                float overlap = math.min(hi, row_hi) - math.max(lo, row_lo)
                if overlap > 0
                    array.set(vols, r, array.get(vols, r) + vol * (overlap / span))

    float vah = na, float val = na
    if not na(sess_lo) and not na(sess_hi) and sess_hi > sess_lo
        [_vah, _val] = f_svp_levels(vols, sess_lo, sess_hi, va_pct)
        vah := _vah, val := _val
    [vah, val]


// ═══════════════════════════════════════════════════════════
// f_session_svp: Three-session SVP — Tokyo → London → RTH.
// Resets at each session open with fixed-range bucketing.
// phase: 0=off 1=Tokyo 2=London 3=RTH
f_session_svp(float hi, float lo, float vol,
              bool in_tok, bool tok_open,
              bool in_lon, bool lon_open,
              bool in_rth, bool rth_open,
              simple int rows, simple float va_pct) =>
    var array<float> vols    = array.new<float>(rows, 0.0)
    var float        sess_lo = na
    var float        sess_hi = na
    var int          phase   = 0

    bool sess_open = tok_open or lon_open or rth_open
    bool in_sess   = in_tok or in_lon or in_rth

    if sess_open
        array.fill(vols, 0.0)
        float bar_mid   = (hi + lo) / 2.0
        // Use a large enough range to cover the full session without clamping.
        // Minimum 500 ticks ensures quiet opening bars don't produce a
        // range too narrow to capture the full day's price action.
        float bar_range = math.max(hi - lo, syminfo.mintick * 500)
        sess_lo := bar_mid - bar_range * 3
        sess_hi := bar_mid + bar_range * 3
        phase   := rth_open ? 3 : lon_open ? 2 : 1

    if in_sess and not na(sess_lo) and not na(sess_hi) and sess_hi > sess_lo and vol > 0
        float rng  = sess_hi - sess_lo
        float span = math.max(hi - lo, syminfo.mintick)
        int r_lo = math.max(0,        int(math.floor((lo - sess_lo) / rng * rows)))
        int r_hi = math.min(rows - 1, int(math.floor((hi - sess_lo) / rng * rows)))
        if r_lo <= r_hi
            for r = r_lo to r_hi
                float row_lo  = sess_lo + r       * rng / rows
                float row_hi  = sess_lo + (r + 1) * rng / rows
                float overlap = math.min(hi, row_hi) - math.max(lo, row_lo)
                if overlap > 0
                    array.set(vols, r, array.get(vols, r) + vol * (overlap / span))

    float vah = na, float val = na
    if in_sess and not na(sess_lo) and not na(sess_hi) and sess_hi > sess_lo
        [_vah, _val] = f_svp_levels(vols, sess_lo, sess_hi, va_pct)
        vah := _vah, val := _val
    [vah, val, phase, in_sess]

// SVP cell helper
// "In Value"    = close between VAL and VAH  → blue
// "Discovery ▲" = close above VAH            → purple
// "Discovery ▼" = close below VAL            → purple
// "—"           = outside session or no data → grey
f_svp_cell(float cls, float vah, float val, bool in_sess) =>
    string status = "—"
    color  col    = i_na_col
    if in_sess and not na(vah) and not na(val)
        if cls > vah
            status := "Discovery ▲", col := i_disc_col
        else if cls < val
            status := "Discovery ▼", col := i_disc_col
        else
            status := "In Value",    col := i_inval_col
    [status, col]

// ═══════════════════════════════════════════════════════════
// INITIAL BALANCE
// Tracks the high and low of the first hour of the NY session
// (default 09:30–10:30). Resets at each new IB window open.
// Returns [ib_high, ib_low] — persists indefinitely once set, resets at next IB open.
// ═══════════════════════════════════════════════════════════
f_ib(float hi, float lo, bool in_ib, bool ib_open) =>
    var float ib_high   = na
    var float ib_low    = na
    var bool  ib_forming = false  // true while current IB window is building

    if ib_open
        // Reset at each new IB open — start fresh from this bar
        ib_high   := hi
        ib_low    := lo
        ib_forming := true
    else if in_ib
        // Still inside the IB window — keep expanding
        if hi > ib_high or na(ib_high)
            ib_high := hi
        if lo < ib_low or na(ib_low)
            ib_low := lo
    else
        // IB window has closed — mark as complete
        ib_forming := false
    // ib_high/ib_low persist after window closes until next ib_open resets them.

    [ib_high, ib_low, ib_forming]

// ═══════════════════════════════════════════════════════════
// DATA GATHERING
// FIX 1: simple string parameter type for request.security()
// FIX 2: day-change uses math.floor(t/86400000) on the
//         returned time series, not the chart symbol's time()
// ═══════════════════════════════════════════════════════════
f_wrap(simple string sym, simple float mad_pts) =>
    [o, h, l, c, v, t, td, atr_val] = request.security(sym, timeframe.period,
         [open, high, low, close, volume, time, time("D"), ta.atr(i_atr_len)],
         lookahead=barmerge.lookahead_off)
    float src = (o + h + l + c) / 4
    // Use the symbol's own daily boundary for Globex day detection
    // This matches how the standalone Globex VWAP indicator resets
    bool nd    = ta.change(td) != 0
    bool r_s   = not na(time(timeframe.period, i_rth_session, "America/New_York"))
    bool r_o   = r_s and not r_s[1]
    bool lon_s = not na(time(timeframe.period, i_lon_session, "Europe/London"))
    bool lon_o = lon_s and not lon_s[1]
    bool tok_s = not na(time(timeframe.period, i_tok_session, "Asia/Tokyo"))
    bool tok_o = tok_s and not tok_s[1]
    bool ib_s  = not na(time(timeframe.period, i_ib_session, "America/New_York"))
    bool ib_o  = ib_s and not ib_s[1]
    [gv, gu, gd] = f_globex_vwap(src, v, nd, i_band_mult)
    [rv, ru, rd, rv_phase, rv_active] = f_session_vwap(src, v, tok_s, tok_o, lon_s, lon_o, r_s, r_o, i_band_mult)
    [svah, sval]   = f_svp(h, l, v, int(t), i_svp_rows, i_svp_va_pct)
    [lrvah, lrval, lr_phase, lr_active] = f_session_svp(h, l, v, tok_s, tok_o, lon_s, lon_o, r_s, r_o, i_svp_rows, i_svp_va_pct)
    [ib_hi, ib_lo, ib_forming] = f_ib(h, l, ib_s, ib_o)
    bool rth_close = not r_s and r_s[1]   // first bar after 17:00 NY
    [mad_status, mad_dist, mad_side] = f_madonna(h, l, c, ib_hi, ib_lo, ib_forming, ib_o, rth_close, mad_pts)
    bool sv_s = true
    [c, gv, gu, gd, rv, ru, rd, rv_phase, rv_active, r_s, svah, sval, sv_s, lrvah, lrval, lr_phase, lr_active, ib_hi, ib_lo, ib_forming, atr_val, mad_status, mad_dist, mad_side]

[nq_c, nq_gv, nq_gu, nq_gd, nq_rv, nq_ru, nq_rd, nq_rv_ph, nq_rv_act, nq_r_s, nq_svah, nq_sval, nq_sv_s, nq_lrvah, nq_lrval, nq_lr_ph, nq_lr_act, nq_ib_hi, nq_ib_lo, nq_ib_frm, nq_atr, nq_mad_st, nq_mad_dist, nq_mad_side] = f_wrap(i_nq_sym, i_mad_nq_pts)
[es_c, es_gv, es_gu, es_gd, es_rv, es_ru, es_rd, es_rv_ph, es_rv_act, es_r_s, es_svah, es_sval, es_sv_s, es_lrvah, es_lrval, es_lr_ph, es_lr_act, es_ib_hi, es_ib_lo, es_ib_frm, es_atr, es_mad_st, es_mad_dist, es_mad_side] = f_wrap(i_es_sym, i_mad_es_pts)
[ym_c, ym_gv, ym_gu, ym_gd, ym_rv, ym_ru, ym_rd, ym_rv_ph, ym_rv_act, ym_r_s, ym_svah, ym_sval, ym_sv_s, ym_lrvah, ym_lrval, ym_lr_ph, ym_lr_act, ym_ib_hi, ym_ib_lo, ym_ib_frm, ym_atr, ym_mad_st, ym_mad_dist, ym_mad_side] = f_wrap(i_ym_sym, i_mad_ym_pts)

// ═══════════════════════════════════════════════════════════
// CELL HELPER
// FIX: added i_inval_col for "In Value" so it shows in blue
//      rather than inheriting the above/below VWAP color
// ═══════════════════════════════════════════════════════════
f_cell_v(float c, float v, float u, float d, bool s) =>
    string dr = "—", string ds = "—", string ex = "—"
    color  cl = i_na_col, color ex_col = i_na_col
    if s and not na(v)
        dr    := c >= v ? "▲" : "▼"
        cl    := c >= v ? i_above_col : i_below_col
        ds    := (c - v >= 0 ? "+" : "") + str.tostring(c - v, format.mintick)
        if not na(u) and not na(d)
            if c > u
                ex := "+" + str.tostring(c - u, format.mintick)
                cl := i_ext_col, ex_col := i_ext_col
            else if c < d
                ex := "-" + str.tostring(d - c, format.mintick)
                cl := i_ext_col, ex_col := i_ext_col
            else
                ex := "In Value", ex_col := i_inval_col
    [dr, ds, ex, cl, ex_col]

// ═══════════════════════════════════════════════════════════
// TABLE GENERATION
// FIX 2: table guarded with if na(dash) so it is only created
//         once, not leaked on every realtime tick
// FIX 3: table.merge_cells called BEFORE table.cell content
//         so header text is not wiped by the merge
// FIX 4: table changed from 6 rows to 5 (row 5 was empty)
// ═══════════════════════════════════════════════════════════
var table dash = na

if barstate.islast
    ts    = i_text_size == "tiny" ? size.tiny : i_text_size == "small" ? size.small : i_text_size == "large" ? size.large : size.normal
    t_pos = i_pos == "Top Left" ? position.top_left : i_pos == "Bottom Right" ? position.bottom_right : i_pos == "Bottom Left" ? position.bottom_left : position.top_right
    color dim = color.new(color.white, 50)

    // FIX 2: only create the table once
    if na(dash)
        dash := table.new(t_pos, 12, 5,
             border_color=color.new(color.gray, 60),
             border_width=1,
             frame_color=color.new(color.gray, 40),
             frame_width=1)

    // ── Row 0: Primary Headers ───────────────────────────────
    // merge_cells BEFORE writing cell content
    table.merge_cells(dash, 1, 0, 3, 0)
    table.merge_cells(dash, 4, 0, 6, 0)
    table.cell(dash, 0, 0, "Symbol", bgcolor=i_header_col, text_color=color.white, text_size=ts, text_halign=text.align_center)
    table.cell(dash, 1, 0, "Globex VWAP", bgcolor=i_header_col, text_color=color.white, text_size=ts, text_halign=text.align_center)
    string rv_hdr = nq_rv_ph == 3 ? "RTH VWAP" : nq_rv_ph == 2 ? "London VWAP" : nq_rv_ph == 1 ? "Tokyo VWAP" : "VWAP"
    table.cell(dash, 4, 0, rv_hdr, bgcolor=i_header_col, text_color=color.white, text_size=ts, text_halign=text.align_center)
    table.cell(dash, 7, 0, "Globex VP", bgcolor=i_header_col, text_color=color.white, text_size=ts, text_halign=text.align_center)
    string lr_hdr = nq_lr_ph == 3 ? "RTH VP" : nq_lr_ph == 2 ? "London VP" : nq_lr_ph == 1 ? "Tokyo VP" : "VP"
    table.cell(dash, 8, 0, lr_hdr, bgcolor=i_header_col, text_color=color.white, text_size=ts, text_halign=text.align_center)
    table.cell(dash, 9, 0, "IB",  bgcolor=i_header_col, text_color=color.white, text_size=ts, text_halign=text.align_center)
    table.cell(dash, 10, 0, "ATR", bgcolor=i_header_col, text_color=color.white, text_size=ts, text_halign=text.align_center)
    table.cell(dash, 11, 0, "Madonna", bgcolor=i_header_col, text_color=color.white, text_size=ts, text_halign=text.align_center)

    // ── Row 1: Sub-Headers ───────────────────────────────────
    table.cell(dash, 0, 1, "", bgcolor=i_subhdr_col)
    string[] lbls = array.from("Dir", "Dist", "Ext", "Dir", "Dist", "Ext", "Value Area", "Value Area", "IB", str.tostring(i_atr_len) + " bar", "IB Touch")
    for i = 0 to 10
        table.cell(dash, i + 1, 1, array.get(lbls, i),
             bgcolor=i_subhdr_col, text_color=dim, text_size=ts,
             text_halign=text.align_center)

    // ── Rows 2-4: Data ───────────────────────────────────────
    string[] syms = array.from("NQ", "ES", "YM")

    float[] g_vs = array.from(nq_gv, es_gv, ym_gv)
    float[] g_us = array.from(nq_gu, es_gu, ym_gu)
    float[] g_ds = array.from(nq_gd, es_gd, ym_gd)
    float[] r_vs = array.from(nq_rv, es_rv, ym_rv)
    float[] r_us = array.from(nq_ru, es_ru, ym_ru)
    float[] r_ds = array.from(nq_rd, es_rd, ym_rd)
    float[] cls  = array.from(nq_c,  es_c,  ym_c)
    // VWAP col 4: London→RTH session VWAP
    bool[]  r_ss  = array.from(nq_r_s,   es_r_s,   ym_r_s)   // RTH active flag (for SVP)
    bool[]  rv_acts = array.from(nq_rv_act, es_rv_act, ym_rv_act)
    float[] s_vahs = array.from(nq_svah, es_svah, ym_svah)
    float[] s_vals = array.from(nq_sval, es_sval, ym_sval)
    bool[]  s_acts  = array.from(nq_sv_s,   es_sv_s,   ym_sv_s)
    float[] rs_vahs = array.from(nq_lrvah,  es_lrvah,  ym_lrvah)
    float[] rs_vals = array.from(nq_lrval,  es_lrval,  ym_lrval)
    bool[]  rs_acts  = array.from(nq_lr_act,  es_lr_act,  ym_lr_act)
    float[] ib_his  = array.from(nq_ib_hi,  es_ib_hi,  ym_ib_hi)
    float[] ib_los  = array.from(nq_ib_lo,  es_ib_lo,  ym_ib_lo)
    bool[]  ib_frms = array.from(nq_ib_frm, es_ib_frm, ym_ib_frm)
    float[] atrs     = array.from(nq_atr,     es_atr,     ym_atr)
    int[]   mad_sts   = array.from(nq_mad_st,   es_mad_st,   ym_mad_st)
    float[] mad_dists = array.from(nq_mad_dist, es_mad_dist, ym_mad_dist)
    int[]   mad_sides = array.from(nq_mad_side, es_mad_side, ym_mad_side)

    for i = 0 to 2
        int   row   = i + 2
        float cur_c = array.get(cls, i)
        color bg    = color.new(i_bg_col, 90)

        table.cell(dash, 0, row, array.get(syms, i),
             bgcolor=i_subhdr_col, text_color=color.white,
             text_size=ts, text_halign=text.align_center)

        // Globex VWAP
        [gd, gs, gx, gc, gxc] = f_cell_v(cur_c,
             array.get(g_vs, i), array.get(g_us, i), array.get(g_ds, i), true)
        table.cell(dash, 1, row, gd,
             bgcolor=color.new(gc, 75), text_color=color.white,
             text_size=ts, text_halign=text.align_center)
        table.cell(dash, 2, row, gs,
             bgcolor=bg, text_color=gc,
             text_size=ts, text_halign=text.align_right)
        table.cell(dash, 3, row, gx,
             bgcolor=bg, text_color=gxc,
             text_size=ts, text_halign=text.align_right)

        // Session VWAP (Tokyo → London → RTH)
        bool in_rv = array.get(rv_acts, i)
        [rd, rs, rx, rc, rxc] = f_cell_v(cur_c,
             array.get(r_vs, i), array.get(r_us, i), array.get(r_ds, i), in_rv)
        table.cell(dash, 4, row, rd,
             bgcolor=color.new(rc, 75), text_color=color.white,
             text_size=ts, text_halign=text.align_center)
        table.cell(dash, 5, row, rs,
             bgcolor=bg, text_color=rc,
             text_size=ts, text_halign=text.align_right)
        table.cell(dash, 6, row, rx,
             bgcolor=bg, text_color=rxc,
             text_size=ts, text_halign=text.align_right)

        // Globex SVP
        bool in_svp = array.get(s_acts, i)
        [svp_st, svp_cl] = f_svp_cell(cur_c, array.get(s_vahs, i), array.get(s_vals, i), in_svp)
        table.cell(dash, 7, row, svp_st,
             bgcolor=color.new(svp_cl, 75), text_color=color.white,
             text_size=ts, text_halign=text.align_center)

        // Session SVP (Tokyo → London → RTH)
        bool in_lr_svp = array.get(rs_acts, i)
        [rsvp_st, rsvp_cl] = f_svp_cell(cur_c, array.get(rs_vahs, i), array.get(rs_vals, i), in_lr_svp)
        table.cell(dash, 8, row, rsvp_st,
             bgcolor=color.new(rsvp_cl, 75), text_color=color.white,
             text_size=ts, text_halign=text.align_center)

        // IB — blank while forming, persists once locked
        float ib_hi   = array.get(ib_his,  i)
        float ib_lo   = array.get(ib_los,  i)
        bool  ib_form = array.get(ib_frms, i)
        string ib_str = "—"
        color  ib_col = i_na_col
        if not ib_form and not na(ib_hi) and not na(ib_lo)
            if cur_c > ib_hi
                ib_str := "Discovery ▲"
                ib_col := i_disc_col
            else if cur_c < ib_lo
                ib_str := "Discovery ▼"
                ib_col := i_disc_col
            else
                ib_str := "In Value"
                ib_col := i_inval_col
        table.cell(dash, 9, row, ib_str,
             bgcolor=color.new(ib_col, 75), text_color=color.white,
             text_size=ts, text_halign=text.align_center)

        // ATR
        float atr_v  = array.get(atrs, i)
        string atr_s = not na(atr_v) ? str.tostring(atr_v, format.mintick) : "—"
        table.cell(dash, 10, row, atr_s,
             bgcolor=bg, text_color=color.new(color.white, 20),
             text_size=ts, text_halign=text.align_right)

        // Madonna — IB boundary touch alert
        int   mad_st   = array.get(mad_sts,   i)
        float mad_d    = array.get(mad_dists, i)
        int   mad_sd   = array.get(mad_sides, i)
        string mad_str = "—"
        color  mad_bg  = bg
        color  mad_col = i_na_col
        if mad_st == 3
            // Touched — lock colour and label
            if mad_sd == 1
                mad_str := "✓ High"
                mad_bg  := color.new(i_above_col, 40)
                mad_col := color.white
            else if mad_sd == -1
                mad_str := "✓ Low"
                mad_bg  := color.new(i_below_col, 40)
                mad_col := color.white
        else if mad_st == 2 and not na(mad_d)
            // Approaching — show distance to boundary
            mad_str := mad_d >= 0
                 ? "H -" + str.tostring(mad_d,  format.mintick)
                 : "L -" + str.tostring(-mad_d, format.mintick)
            mad_col := mad_d >= 0 ? i_above_col : i_below_col
        table.cell(dash, 11, row, mad_str,
             bgcolor=mad_bg, text_color=mad_col,
             text_size=ts, text_halign=text.align_center)
````
