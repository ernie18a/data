# Stacey Burke Signal Day & Cycle

- url: https://www.tradingview.com/script/HoyKOtlk-Stacey-Burke-Signal-Day-Cycle/
- type: indicator
- pine_id: PUB;439ffad8ff4c427f9c5f3c8acf8f787d
- version: 3.0

## Description

Attempting to build this how Burke would like it. Let me know what is right or what is wrong or what is needed or needs to be removed.

## Source Code

````pine
//@version=6
// =============================================================================
// STACEY BURKE — SIGNAL DAY & CYCLE
//
// Community-built chart study inspired by publicly discussed trading concepts.
// Not affiliated with, endorsed by, or representing Stacey Burke or his
// courses, and no claim is made about the accuracy or profitability of
// anything drawn here. For education/research only — not trading advice.
//
// What it draws: daily signal-day classifications, a consecutive-break day
// counter, anchor levels (prior Friday / week / day), a projected strike
// zone, measured-move targets, Asia/London session boxes, a weekly calendar
// template, an automated bias table, an intraday BOS + supply/demand layer,
// and optional expected-move rails derived from an implied-volatility index
// (a volatility MODEL of the day's likely range — not options chain, GEX,
// or dealer-positioning data). Days are classified only after they fully
// complete (non-repainting);
// day OHLC is accumulated from the chart's own bars so the day boundary
// follows the symbol's daily session (e.g. CME 18:00 ET).
// Let me know in the comments if anything needs to be changed, fixed or added.
// =============================================================================
indicator("Stacey Burke — Signal Day & Cycle", shorttitle="Burke SD", overlay=true,
     max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================== INPUTS ==============================
var string G_SIG = "🎯 Signal Days"
i_show_inside   = input.bool(true,  "Inside Day",  group=G_SIG, inline="s1")
i_show_outside  = input.bool(true,  "Outside Day", group=G_SIG, inline="s1")
i_show_dayzero  = input.bool(true,  "Day Zero",    group=G_SIG, inline="s2")
i_show_frd_fgd  = input.bool(true,  "First Red / First Green Day", group=G_SIG, inline="s2")
i_show_boxes    = input.bool(true,  "Draw day range boxes", group=G_SIG)
i_show_labels   = input.bool(true,  "Draw labels", group=G_SIG, inline="s3")
i_label_size    = input.string("small", "", options=["tiny","small","normal"], group=G_SIG, inline="s3")

c_inside  = input.color(color.new(color.yellow, 80), "Inside",   group=G_SIG, inline="c1")
c_out_up  = input.color(color.new(color.green, 80),  "Outside↑", group=G_SIG, inline="c1")
c_out_dn  = input.color(color.new(color.red, 80),    "Outside↓", group=G_SIG, inline="c1")
c_dayzero = input.color(color.new(color.blue, 80),   "Day Zero", group=G_SIG, inline="c2")
c_frd     = input.color(color.new(color.red, 70),    "FRD",      group=G_SIG, inline="c2")
c_fgd     = input.color(color.new(color.lime, 70),   "FGD",      group=G_SIG, inline="c2")

var string G_FRD = "🔴🟢 FRD / FGD filter"
i_frd_swing   = input.bool(true, "Require prior day to be a swing extreme", group=G_FRD,
     tooltip="FRD = first red close after the up-move peaked; FGD = first green after a bottom. " +
             "When on, the prior (green/red) day must be the highest/lowest of the lookback.")
i_frd_lb      = input.int(5, "Swing lookback (days)", minval=2, maxval=20, group=G_FRD)

var string G_CYC = "🔢 3-Day Cycle"
i_show_cycle  = input.bool(true,  "Show cycle-day labels (D1/D2/D3)", group=G_CYC)
i_flag_day3   = input.bool(true,  "Highlight Day 3 (fade candidate)", group=G_CYC)
c_cycle       = input.color(color.gray, "Cycle label color", group=G_CYC, inline="cc")
c_day3        = input.color(color.orange, "Day-3 color", group=G_CYC, inline="cc")

var string G_LVL = "📏 Anchor Levels"
i_show_friday = input.bool(true,  "Prior Friday H/L (Monday anchor)", group=G_LVL, inline="l1")
c_friday      = input.color(color.new(#fbc02d, 0), "", group=G_LVL, inline="l1")
i_show_week   = input.bool(true,  "Prior Week H/L", group=G_LVL, inline="l2")
c_week        = input.color(color.new(#5b9cf6, 0), "", group=G_LVL, inline="l2")
i_show_pday   = input.bool(true,  "Prior Day H/L",  group=G_LVL, inline="l3")
c_pday        = input.color(color.new(#b0bec5, 0), "", group=G_LVL, inline="l3")
i_show_wkib   = input.bool(true,  "Week Initial Balance (Mon∪Tue H/L)", group=G_LVL, inline="l4",
     tooltip="The combined Monday+Tuesday range. Shows once Tuesday completes, through Friday.")
c_wkib        = input.color(color.new(#26c6da, 0), "", group=G_LVL, inline="l4")
i_lvl_ext     = input.int(30, "Level extension (bars)", minval=1, maxval=300, group=G_LVL)
i_lvl_style   = input.string("Dashed", "Level style", options=["Solid","Dashed","Dotted"], group=G_LVL)
i_lvl_txt     = input.string("normal", "Level label size", options=["tiny","small","normal","large"], group=G_LVL)
i_merge_tk    = input.int(4, "Merge level labels within (ticks)", minval=0, maxval=100, group=G_LVL,
     tooltip="Levels closer together than this share ONE combined label (e.g. 'Fri L · Wk L') so the text never stacks on itself. 0 = merge only exact matches.")

var string G_STRIKE = "📐 Day-2 Strike Zone (3 levels)"
i_show_strike = input.bool(true, "Project the strike zone", group=G_STRIKE,
     tooltip="Down cycle ⇒ LOD + 3 levels (a rally to fade into); up cycle ⇒ HOD − 3 levels (a dip to fade into). " +
             "If price exceeds the projection it redraws from the new extreme. Calibrate level size per instrument.")
i_lvl_pts     = input.float(10.0, "Level size (points)", minval=0.1, step=0.5, group=G_STRIKE,
     tooltip="One 'level' in chart points; 3 levels = the projection. ES: try 10 (30-pt projection); GC: try 8–12.")
c_strike      = input.color(color.new(#ff4081, 0), "Strike color", group=G_STRIKE)

var string G_TGT = "📐 Measured-Move Targets (FRD/FGD)"
i_show_tgt    = input.bool(true,  "Project fade targets", group=G_TGT)
i_tgt_n       = input.int(3, "Number of targets (×range)", minval=1, maxval=5, group=G_TGT,
     tooltip="1x/2x/3x the signal-day range projected from the extreme.")
c_tgt         = input.color(color.new(#ab47bc, 0), "Target color", group=G_TGT)

var string G_SESS = "🕒 Session Boxes — Asia / London (intraday)"
i_show_sess   = input.bool(true, "Draw session boxes (running H/L)", group=G_SESS,
     tooltip="Each box tracks the session's running high/low. Defaults: Asia 18:00–02:00 ET, London 02:00–05:00 ET.")
i_sess_days   = input.int(5, "Sessions to keep (each)", minval=1, maxval=30, group=G_SESS)
i_asia_sh     = input.int(18, "Asia  start", minval=0, maxval=23, group=G_SESS, inline="se1")
i_asia_sm     = input.int(0, ":", minval=0, maxval=59, group=G_SESS, inline="se1")
i_asia_eh     = input.int(2, "→ end", minval=0, maxval=23, group=G_SESS, inline="se1")
i_asia_em     = input.int(0, ":", minval=0, maxval=59, group=G_SESS, inline="se1")
c_asia        = input.color(color.new(color.purple, 88), "Asia box", group=G_SESS, inline="se2")
i_lon_sh      = input.int(2, "London start", minval=0, maxval=23, group=G_SESS, inline="se3")
i_lon_sm      = input.int(0, ":", minval=0, maxval=59, group=G_SESS, inline="se3")
i_lon_eh      = input.int(5, "→ end", minval=0, maxval=23, group=G_SESS, inline="se3")
i_lon_em      = input.int(0, ":", minval=0, maxval=59, group=G_SESS, inline="se3")
c_london      = input.color(color.new(color.teal, 88), "London box", group=G_SESS, inline="se2")

var string G_SD = "🧱 Structure & Zones (BOS · Supply/Demand)"
i_show_bos   = input.bool(true, "Break of Structure (BOS)", group=G_SD, inline="b1")
c_bos        = input.color(color.new(color.white, 0), "", group=G_SD, inline="b1",
     tooltip="BOS = close breaks the last confirmed swing high/low. Draws a thin line from the swing to the break bar with a 'BOS' tag.")
i_bos_sz     = input.string("small", "BOS label size", options=["tiny","small","normal"], group=G_SD, inline="b2")
i_bos_keep   = input.int(120, "· marks kept", minval=10, maxval=400, group=G_SD, inline="b2",
     tooltip="Lookback: how many past BOS lines/labels stay on the chart before the oldest are pruned.")
i_sw_len     = input.int(10, "Swing length (bars each side)", minval=2, maxval=50, group=G_SD,
     tooltip="Pivot strength for structure AND zones. Bigger = fewer, more significant swings.")
i_show_sd    = input.bool(true, "Supply / Demand zones", group=G_SD,
     tooltip="Zone = wick→body of each confirmed swing high (supply) / swing low (demand). Extends right until a CLOSE through the far edge mitigates it (zone deleted). Oldest zones pruned past the max.")
i_sd_max     = input.int(6, "Max zones per side", minval=1, maxval=20, group=G_SD,
     tooltip="Lookback: raise this to keep more (older) unmitigated zones on the chart.")
c_sup_bg     = input.color(color.new(#801922, 72), "Supply", group=G_SD, inline="z1")
c_sup_br     = input.color(color.new(#e0535f, 45), "", group=G_SD, inline="z1")
c_dem_bg     = input.color(color.new(#0d47a1, 72), "Demand", group=G_SD, inline="z2")
c_dem_br     = input.color(color.new(#64a0e8, 45), "", group=G_SD, inline="z2")

var string G_EM = "🌊 Expected Move Rails (implied vol — NOT options positioning data)"
i_em_on     = input.bool(true, "Show expected-move rails", group=G_EM,
     tooltip="Rails = anchor price ± N × the 1-day implied move from a volatility index (default VIX1D), " +
             "rounded to strikes. This is an implied-volatility MODEL of the day's likely range — it is not " +
             "options-chain, GEX, or dealer-positioning data and makes no claim to be. Designed for ES/SPX-type " +
             "charts; pick a matching vol index (or turn it off) on other symbols.")
i_em_tkr    = input.symbol("CBOE:VIX1D", "Volatility index", group=G_EM)
i_em_anchor = input.string("RTH Open (09:30 ET)", "Anchor", group=G_EM,
     options=["RTH Open (09:30 ET)","Prior Day Close","Daily Session Open"])
i_em_05     = input.bool(false, "±0.5σ", group=G_EM, inline="em1")
i_em_10     = input.bool(true,  "±1σ",   group=G_EM, inline="em1")
i_em_15     = input.bool(false, "±1.5σ", group=G_EM, inline="em1")
i_em_20     = input.bool(true,  "±2σ",   group=G_EM, inline="em1")
i_em_anc_ln = input.bool(false, "Anchor (0σ) line", group=G_EM, inline="em2")
c_em        = input.color(color.new(#7cb342, 0), "", group=G_EM, inline="em2")
i_em_round  = input.float(5.0, "Round rails to strike (pts, 0 = off)", minval=0, step=0.5, group=G_EM)
i_em_alerts = input.bool(true, "Alert on first ±1σ / ±2σ touch of the day", group=G_EM)

var string G_WK = "📅 Weekly Template (frontside / backside)"
i_show_wk_tmpl  = input.bool(true, "Calendar day labels (F1/F2 · F3|B1 · B2/B3)", group=G_WK)
i_show_fricp    = input.bool(true, "Prior Friday CLOSE (week anchor)", group=G_WK, inline="w1")
c_fricp         = input.color(color.new(#ff6d00, 0), "", group=G_WK, inline="w1")
i_show_fb_shade = input.bool(true, "Frontside/backside background tint", group=G_WK)
c_front         = input.color(color.new(color.teal, 94),   "Frontside Mon–Tue", group=G_WK, inline="w2")
c_back          = input.color(color.new(color.orange, 94), "Backside Thu–Fri",  group=G_WK, inline="w2")
c_wreset        = input.color(color.new(color.blue, 92),   "Wed (re-set day)",  group=G_WK, inline="w3")
i_show_wedtag   = input.bool(true, "Wednesday-close breakout tag", group=G_WK,
     tooltip="Tags Wednesdays that closed at the highest/lowest close of the week so far (WED✓↑/↓) and sets the back-half lean.")

var string G_DISP = "🎨 Display"
i_max_days    = input.int(15, "Days of history to keep drawn", minval=1, maxval=60, group=G_DISP)
i_show_table  = input.bool(true, "Show status table", group=G_DISP)
i_tbl_pos     = input.string("Top Right", "Table position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G_DISP)
i_tbl_size    = input.string("Normal", "Table text size",
     options=["Small","Normal","Large","Huge"], group=G_DISP)

// ============================== HELPERS ==============================
get_line_style(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

lbl_sz() =>
    switch i_label_size
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        => size.small

lvl_lbl_sz() =>
    switch i_lvl_txt
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.normal

// is the current bar inside an ET time window (handles midnight wrap)
in_sess_win(int sh, int sm, int eh, int em) =>
    int cur = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")
    int st = sh * 60 + sm
    int en = eh * 60 + em
    en > st ? (cur >= st and cur < en) : (cur >= st or cur < en)

// trade-date day of week (18:00-ET evening session belongs to the NEXT day). 1=Sun … 7=Sat
f_tradedow(int t) =>
    int dw = dayofweek(t, "America/New_York")
    hour(t, "America/New_York") >= 18 ? (dw == 7 ? 1 : dw + 1) : dw

// weekly-template tag for a trade dow (2=Mon … 6=Fri)
f_wk_tag(int dw) =>
    switch dw
        2 => "Mon F1 · Opening Rng"
        3 => "Tue F2 · Expansion"
        4 => "Wed F3|B1 · RE-SET"
        5 => "Thu B2 · Reversal"
        6 => "Fri B3 · Closing Rng"
        => ""

// access a completed-day array by distance-from-most-recent (0 = last completed day)
f_at(float[] a, int n) =>
    array.get(a, array.size(a) - 1 - n)

// pick the nearest level to `ref`; useSide filters to one side first, falls back to nearest-overall
pick_nearest(float[] prices, string[] names, float ref, bool useSide, bool wantBelow) =>
    float bp = na
    string bn = "—"
    float bd = 1e15
    for i = 0 to array.size(prices) - 1
        float p = array.get(prices, i)
        if not na(p)
            bool ok = not useSide or (wantBelow ? p <= ref : p >= ref)
            if ok
                float d = math.abs(ref - p)
                if d < bd
                    bd := d
                    bp := p
                    bn := array.get(names, i)
    if na(bp)
        for i = 0 to array.size(prices) - 1
            float p = array.get(prices, i)
            if not na(p)
                float d = math.abs(ref - p)
                if d < bd
                    bd := d
                    bp := p
                    bn := array.get(names, i)
    [bp, bn]

trim_boxes(box[] a, int cap) =>
    while array.size(a) > cap
        box.delete(array.shift(a))
trim_labels(label[] a, int cap) =>
    while array.size(a) > cap
        label.delete(array.shift(a))

// ============================== TRADE-DATE DAY DETECTION ==============================
day_start_t  = request.security(syminfo.tickerid, "D", time, lookahead=barmerge.lookahead_on)
week_start_t = request.security(syminfo.tickerid, "W", time, lookahead=barmerge.lookahead_on)
is_new_day   = ta.change(day_start_t)  != 0
is_new_week  = ta.change(week_start_t) != 0

// prior COMPLETED week H/L (non-repainting)
[pwk_h, pwk_l] = request.security(syminfo.tickerid, "W", [high[1], low[1]],
     lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

// ============================== DAY OHLC ACCUMULATION ==============================
var float d_o = na
var float d_h = na
var float d_l = na
var int   d_start_bar  = na
var int   d_start_time = na

// completed-day history (index 0 via f_at = most recent completed day)
var float[] DHI = array.new_float()
var float[] DLO = array.new_float()
var float[] DCL = array.new_float()
var float[] DOP = array.new_float()
var int[]   DSB = array.new_int()
var int[]   DEB = array.new_int()

var int last_fo = 0    // +1 = FOH, -1 = FOL, 0 = none
var int cy_up = 0
var int cy_dn = 0

// ============================== DRAWING STATE ==============================
var box[]   sig_boxes  = array.new_box()
var label[] sig_labels = array.new_label()
var label[] cyc_labels = array.new_label()
var line[]  tgt_lines  = array.new_line()
var label[] lvl_labels = array.new_label()   // merged right-edge labels (rebuilt each tick on the last bar)
var box[]   asia_boxes = array.new_box()
var box[]   lon_boxes  = array.new_box()
var bool    in_asia_s  = false
var bool    in_lon_s   = false

var line ln_friH = na
var line ln_friL = na
var line ln_wkH  = na
var line ln_wkL  = na
var line ln_pdH  = na
var line ln_pdL  = na
var line ln_friC = na
var line ln_wkibH = na
var line ln_wkibL = na
var line ln_strike = na

var string last_signal = "—"
var int    cycle_day   = 0
var int    cycle_dir   = 0
var float  friH = na
var float  friL = na
var float  friC = na

// weekly-template state
var float  wk_maxC = na
var float  wk_minC = na
var int    wed_dir = 0
var bool   tmpl_match = false

// week Initial Balance (Mon∪Tue H/L)
var float  wkib_h = na
var float  wkib_l = na
var bool   wkib_on = false

var bool   strike_hit = false

// automated bias state
var int    bias_dir   = 0      // +1 long, -1 short, 0 wait
var string bias_txt   = "Waiting for first signal"
var string conviction = "—"
var bool   trade_day  = false
var int    last_dir   = 0
var int    sig_age    = 99
var float  sig_anchor = na
var float  sig_range  = na
var int    sig_dir    = 0
var float  inval_level    = na
var int    inval_dir      = 0
var bool   bias_invalidated = false

// ============================== DAY CLASSIFICATION (on day completion) ==============================
if na(d_h)
    d_o := open
    d_h := high
    d_l := low
    d_start_bar := bar_index
    d_start_time := time
else if is_new_day
    float c_o = d_o
    float c_h = d_h
    float c_l = d_l
    float c_c = close[1]
    int c_sb = d_start_bar
    int c_eb = bar_index - 1
    int t_start = d_start_time
    int t_end   = time[1]
    int t_mid   = int((t_start + t_end) / 2)

    array.push(DOP, c_o)
    array.push(DHI, c_h)
    array.push(DLO, c_l)
    array.push(DCL, c_c)
    array.push(DSB, c_sb)
    array.push(DEB, c_eb)
    while array.size(DHI) > 70
        array.shift(DOP)
        array.shift(DHI)
        array.shift(DLO)
        array.shift(DCL)
        array.shift(DSB)
        array.shift(DEB)

    int n = array.size(DHI)
    if n >= 2
        float H0 = f_at(DHI, 0)
        float L0 = f_at(DLO, 0)
        float C0 = f_at(DCL, 0)
        float O0 = f_at(DOP, 0)
        float H1 = f_at(DHI, 1)
        float L1 = f_at(DLO, 1)
        float C1 = f_at(DCL, 1)
        float O1 = f_at(DOP, 1)

        // --- day primitives ---
        bool inside  = H0 < H1 and L0 > L1
        bool outside = H0 > H1 and L0 < L1
        bool foh0 = H0 > H1 and C0 < H1 and C0 > L1 and L0 >= L1
        bool fol0 = L0 < L1 and C0 > L1 and C0 < H1 and H0 <= H1
        int  fo0  = foh0 and not fol0 ? 1 : fol0 and not foh0 ? -1 : 0
        bool dayzero = not outside and ((fo0 == 1 and last_fo == -1) or (fo0 == -1 and last_fo == 1))

        // --- cycle counter (consecutive prior-extreme breaks, same dir) ---
        bool ub = H0 > H1
        bool db = L0 < L1
        if inside or outside
            cy_up := 0
            cy_dn := 0
        else if ub and not db
            cy_up := cy_up + 1
            cy_dn := 0
        else if db and not ub
            cy_dn := cy_dn + 1
            cy_up := 0
        else
            cy_up := 0
            cy_dn := 0
        cycle_day := math.max(cy_up, cy_dn)
        cycle_dir := cy_up > 0 ? 1 : cy_dn > 0 ? -1 : 0

        // --- weekly template: trade dow of the completed day + close tracking ---
        int dw0 = f_tradedow(t_end)
        if is_new_week
            wk_maxC := na
            wk_minC := na
            wed_dir := 0
        else
            wk_maxC := na(wk_maxC) ? C0 : math.max(wk_maxC, C0)
            wk_minC := na(wk_minC) ? C0 : math.min(wk_minC, C0)
            if dw0 == 4 and i_show_wedtag
                wed_dir := C0 >= wk_maxC ? 1 : C0 <= wk_minC ? -1 : 0

        // --- week Initial Balance (Mon∪Tue H/L) ---
        if dw0 == 2
            wkib_h := H0
            wkib_l := L0
            wkib_on := false
        else if dw0 == 3
            wkib_h := na(wkib_h) ? H0 : math.max(wkib_h, H0)
            wkib_l := na(wkib_l) ? L0 : math.min(wkib_l, L0)
            wkib_on := true

        // --- FRD / FGD ---
        bool red0   = C0 < O0
        bool green0 = C0 > O0
        bool green1 = C1 > O1
        bool red1   = C1 < O1
        bool swingHi = true
        bool swingLo = true
        if i_frd_swing
            int lb = math.min(i_frd_lb, n - 1)
            float mxH = H1
            float mnL = L1
            for k = 2 to lb
                mxH := math.max(mxH, f_at(DHI, k))
                mnL := math.min(mnL, f_at(DLO, k))
            swingHi := H1 >= mxH
            swingLo := L1 <= mnL
        bool isFRD = i_show_frd_fgd and red0   and green1 and swingHi
        bool isFGD = i_show_frd_fgd and green0 and red1   and swingLo

        last_fo := fo0   // update memory AFTER using it for Day Zero

        // --- box color + label (priority: Outside > DayZero > FRD/FGD > Inside) ---
        bool any_sig = false
        string txt = ""
        color boxcol = color.gray

        if outside and i_show_outside
            any_sig := true
            boxcol := C0 > O0 ? c_out_up : c_out_dn
            txt := "Outside"
        else if dayzero and i_show_dayzero
            any_sig := true
            boxcol := c_dayzero
            txt := "Day Zero"
        else if isFRD
            any_sig := true
            boxcol := c_frd
            txt := "FRD"
        else if isFGD
            any_sig := true
            boxcol := c_fgd
            txt := "FGD"
        else if inside and i_show_inside
            any_sig := true
            boxcol := c_inside
            txt := "Inside"

        if any_sig and txt != "FRD" and txt != "FGD"
            if isFRD
                txt := txt + " · FRD"
            else if isFGD
                txt := txt + " · FGD"

        if any_sig
            last_signal := txt

        if any_sig and i_show_boxes
            box b = box.new(t_start, H0, t_end, L0, border_color=color.new(boxcol, 0),
                 bgcolor=color.new(boxcol, 82), border_width=1, xloc=xloc.bar_time)
            array.push(sig_boxes, b)
            if i_show_labels
                label lb_l = label.new(t_mid, H0, txt, xloc=xloc.bar_time,
                     yloc=yloc.price, style=label.style_label_down,
                     color=color.new(boxcol, 0), textcolor=color.white, size=lbl_sz())
                array.push(sig_labels, lb_l)

        // --- cycle-day + calendar label (below the bars) ---
        string cal_txt = i_show_wk_tmpl ? f_wk_tag(dw0) : ""
        if dw0 == 4 and wed_dir != 0 and i_show_wedtag and cal_txt != ""
            cal_txt := cal_txt + (wed_dir > 0 ? " · WED✓↑" : " · WED✓↓")
        string pa_txt = i_show_cycle and cycle_day > 0 ?
             "D" + str.tostring(cycle_day) + (cycle_dir > 0 ? "↑" : "↓") : ""
        string sub_txt = pa_txt != "" and cal_txt != "" ? pa_txt + "  |  " + cal_txt :
             pa_txt != "" ? pa_txt : cal_txt
        if sub_txt != ""
            bool is_d3 = cycle_day == 3 and i_flag_day3
            color cyc_col = is_d3 ? c_day3 : dw0 == 4 and i_show_wk_tmpl ? color.new(color.blue, 10) : c_cycle
            label cl = label.new(t_mid, L0, sub_txt, xloc=xloc.bar_time,
                 yloc=yloc.price, style=label.style_label_up,
                 color=color.new(cyc_col, is_d3 ? 0 : 30), textcolor=color.white, size=lbl_sz())
            array.push(cyc_labels, cl)

        // --- automated bias ---
        bias_invalidated := false
        if isFRD
            bias_dir := -1
            last_dir := -1
            sig_age := 0
            sig_anchor := L0
            sig_range := H0 - L0
            sig_dir := -1
            inval_level := H0
            inval_dir := -1
            conviction := (cycle_dir > 0 and cycle_day >= 4) ? "Low" : "High"
            bias_txt := conviction == "Low" ? "FRD (weak — late in up-cycle) — short rallies" : "FRD — short rallies into the highs"
            trade_day := true
        else if isFGD
            bias_dir := 1
            last_dir := 1
            sig_age := 0
            sig_anchor := L0
            sig_range := H0 - L0
            sig_dir := 1
            inval_level := L0
            inval_dir := 1
            conviction := (cycle_dir < 0 and cycle_day >= 4) ? "Low" : "High"
            bias_txt := conviction == "Low" ? "FGD (weak — late in down-cycle) — long, needs reclaim" : "FGD — long dips into the lows"
            trade_day := true
        else
            sig_age := sig_age + 1
            if dayzero
                bias_dir := 0
                inval_level := na
                inval_dir := 0
                conviction := "—"
                bias_txt := "Day Zero — cycle reset, wait for the break"
                trade_day := false
            else if sig_age <= 1 and last_dir != 0
                bias_dir := last_dir
                inval_dir := last_dir
                inval_level := last_dir > 0 ? L0 : H0
                conviction := "Medium"
                bias_txt := last_dir > 0 ? "FGD holds — long the Day-3 setup" : "FRD holds — short the Day-3 setup"
                trade_day := true
            else if cycle_day == 3
                bias_dir := cycle_dir > 0 ? -1 : 1
                inval_dir := bias_dir
                inval_level := bias_dir > 0 ? L0 : H0
                conviction := "High"
                bias_txt := "Day 3 " + (cycle_dir > 0 ? "up — fade (short)" : "down — fade (long)")
                trade_day := true
            else if cycle_day == 4
                bias_dir := cycle_dir > 0 ? -1 : 1
                inval_dir := bias_dir
                inval_level := bias_dir > 0 ? L0 : H0
                conviction := "Low"
                bias_txt := "Day 4 " + (cycle_dir > 0 ? "up — LATE fade (short)" : "down — LATE fade (long)") + ", needs reclaim"
                trade_day := true
            else if cycle_day >= 5
                bias_dir := 0
                inval_level := na
                inval_dir := 0
                conviction := "—"
                bias_txt := "Day " + str.tostring(cycle_day) + " — trend too strong, don't fade"
                trade_day := false
            else if cycle_day == 2
                bias_dir := cycle_dir
                inval_dir := cycle_dir
                inval_level := cycle_dir > 0 ? L0 : H0
                conviction := "High"
                bias_txt := "Day 2 " + (cycle_dir > 0 ?
                     "up — buy the dip at the strike zone" :
                     "down — short the rally into the strike zone")
                trade_day := true
            else if inside
                bias_dir := 0
                inval_level := na
                inval_dir := 0
                conviction := "—"
                bias_txt := "Inside day — coil, wait for expansion"
                trade_day := false
            else if outside
                bias_dir := 0
                inval_level := na
                inval_dir := 0
                conviction := "—"
                bias_txt := "Outside day — expanded, caution / reversal"
                trade_day := false
            else if cycle_day == 1
                bias_dir := 0
                inval_level := na
                inval_dir := 0
                conviction := "—"
                bias_txt := "Day 1 — possible trap forming, wait"
                trade_day := false
            else
                bias_dir := 0
                inval_level := na
                inval_dir := 0
                conviction := "—"
                bias_txt := "No setup — stand aside"
                trade_day := false

        // --- calendar/PA confluence (frontside: Mon=1 Tue=2 Wed=3 · backside: Wed=1 Thu=2 Fri=3) ---
        tmpl_match := cycle_day > 0 and
             ((dw0 >= 2 and dw0 <= 4 and cycle_day == dw0 - 1) or
              (dw0 >= 4 and dw0 <= 6 and cycle_day == dw0 - 3))
        if trade_day and cycle_day == 3 and (dw0 == 4 or dw0 == 6)
            conviction := "High"
            bias_txt := bias_txt + " ⚡ ON-TEMPLATE (D3 on " + (dw0 == 4 ? "Wed" : "Fri") + ")"

        // --- alerts (fire once on the completed-day classification) ---
        if dayzero and i_show_dayzero
            alert("Burke SD: Day Zero", alert.freq_once_per_bar)
        if isFRD
            alert("Burke SD: First Red Day (short bias)", alert.freq_once_per_bar)
        if isFGD
            alert("Burke SD: First Green Day (long bias)", alert.freq_once_per_bar)
        if cycle_day == 3 and i_flag_day3
            alert("Burke SD: Day 3 fade candidate (" + (cycle_dir > 0 ? "shorts" : "longs") + ")", alert.freq_once_per_bar)
        if dw0 == 4 and wed_dir != 0 and i_show_wedtag
            alert("Burke SD: Wednesday closed in breakout " + (wed_dir > 0 ? "UP (back-half long lean)" : "DOWN (back-half short lean)"), alert.freq_once_per_bar)

    // --- prior-Friday anchor: on a new week, the just-completed day was Friday ---
    if is_new_week and array.size(DHI) >= 1
        friH := f_at(DHI, 0)
        friL := f_at(DLO, 0)
        friC := f_at(DCL, 0)

    trim_boxes(sig_boxes, i_max_days)
    trim_labels(sig_labels, i_max_days)
    trim_labels(cyc_labels, i_max_days)

    d_o := open
    d_h := high
    d_l := low
    d_start_bar := bar_index
    d_start_time := time
else
    d_h := math.max(d_h, high)
    d_l := math.min(d_l, low)

// ============================== LIVE BIAS INVALIDATION ==============================
if not bias_invalidated and inval_dir != 0 and not na(inval_level)
    if (inval_dir > 0 and close < inval_level) or (inval_dir < 0 and close > inval_level)
        bias_invalidated := true
        alert("Burke SD: bias INVALIDATED — price broke the signal level, stand aside", alert.freq_once_per_bar)

// ============================== STRIKE ZONE (live, auto-redraws from new extremes) ==============================
if is_new_day
    strike_hit := false
float strike_px = na
if i_show_strike and cycle_dir != 0 and cycle_day >= 1 and array.size(DLO) >= 1
    if cycle_dir < 0
        strike_px := math.min(f_at(DLO, 0), nz(d_l, f_at(DLO, 0))) + 3 * i_lvl_pts
    else
        strike_px := math.max(f_at(DHI, 0), nz(d_h, f_at(DHI, 0))) - 3 * i_lvl_pts
if not na(strike_px) and not strike_hit
    if (cycle_dir < 0 and high >= strike_px) or (cycle_dir > 0 and low <= strike_px)
        strike_hit := true
        alert("Burke SD: strike zone tagged — " + (cycle_dir < 0 ? "SELL" : "BUY") + " side", alert.freq_once_per_bar)

// ============================== EXPECTED MOVE RAILS (implied-vol model) ==============================
f_em_rnd(float px) =>
    i_em_round > 0 ? math.round(px / i_em_round) * i_em_round : px

f_near(float a, float b, float tol) =>
    not na(a) and not na(b) and math.abs(a - b) <= tol

float em_vix = request.security(i_em_tkr, timeframe.period, close, gaps=barmerge.gaps_off)

var float em_anchor = na
var float em_sig1   = na   // 1σ expected move in chart points
var bool  em_capt   = false
var bool  em1_hit   = false
var bool  em2_hit   = false

if is_new_day
    em_capt := false
    em1_hit := false
    em2_hit := false
    if i_em_anchor == "Prior Day Close"
        em_anchor := close[1]
        em_sig1 := na(em_vix) ? na : em_anchor * em_vix / 100 / math.sqrt(252)
        em_capt := true
    else if i_em_anchor == "Daily Session Open"
        em_anchor := open
        em_sig1 := na(em_vix) ? na : em_anchor * em_vix / 100 / math.sqrt(252)
        em_capt := true
if not em_capt and i_em_anchor == "RTH Open (09:30 ET)"
    int em_cur = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")
    if em_cur >= 570 and em_cur < 960
        em_anchor := open
        em_sig1 := na(em_vix) ? na : em_anchor * em_vix / 100 / math.sqrt(252)
        em_capt := true

bool  em_ok   = i_em_on and not na(em_anchor) and not na(em_sig1) and em_sig1 > 0
float em_p05u = em_ok ? f_em_rnd(em_anchor + 0.5 * em_sig1) : na
float em_p10u = em_ok ? f_em_rnd(em_anchor + 1.0 * em_sig1) : na
float em_p15u = em_ok ? f_em_rnd(em_anchor + 1.5 * em_sig1) : na
float em_p20u = em_ok ? f_em_rnd(em_anchor + 2.0 * em_sig1) : na
float em_p05d = em_ok ? f_em_rnd(em_anchor - 0.5 * em_sig1) : na
float em_p10d = em_ok ? f_em_rnd(em_anchor - 1.0 * em_sig1) : na
float em_p15d = em_ok ? f_em_rnd(em_anchor - 1.5 * em_sig1) : na
float em_p20d = em_ok ? f_em_rnd(em_anchor - 2.0 * em_sig1) : na

if em_ok and i_em_alerts
    if not em1_hit and i_em_10 and (high >= em_p10u or low <= em_p10d)
        em1_hit := true
        alert("Burke SD: ±1σ expected-move rail tagged", alert.freq_once_per_bar)
    if not em2_hit and i_em_20 and (high >= em_p20u or low <= em_p20d)
        em2_hit := true
        alert("Burke SD: ±2σ expected-move rail tagged", alert.freq_once_per_bar)

var line[] em_lns = array.new_line(9, na)

// ============================== ANCHOR LEVEL LINES ==============================
line_style = get_line_style(i_lvl_style)

draw_line(line ln, bool show, float px, color col) =>
    line oln = ln
    if show and not na(px)
        if na(oln)
            oln := line.new(bar_index, px, bar_index + i_lvl_ext, px, xloc=xloc.bar_index,
                 color=col, style=line_style, width=1)
        else
            line.set_xy1(oln, bar_index - 1, px)
            line.set_xy2(oln, bar_index + i_lvl_ext, px)
            line.set_color(oln, col)
            line.set_style(oln, line_style)
    else if not na(oln)
        line.delete(oln)
        oln := na
    oln

// collect a visible level into the merged-label pool
f_lvl_add(float[] pa, string[] ta_, color[] ca, bool show, float px, string tag, color col) =>
    if show and not na(px)
        array.push(pa, px)
        array.push(ta_, tag)
        array.push(ca, col)

if barstate.islast
    float pdH = array.size(DHI) >= 1 ? f_at(DHI, 0) : na
    float pdL = array.size(DLO) >= 1 ? f_at(DLO, 0) : na
    bool ib_show = i_show_wkib and wkib_on
    bool strike_show = i_show_strike and not na(strike_px)
    string strike_tag = cycle_dir < 0 ? "Strike ▼ sell" : "Strike ▲ buy"

    ln_friH   := draw_line(ln_friH,   i_show_friday, friH,      c_friday)
    ln_friL   := draw_line(ln_friL,   i_show_friday, friL,      c_friday)
    ln_wkH    := draw_line(ln_wkH,    i_show_week,   pwk_h,     c_week)
    ln_wkL    := draw_line(ln_wkL,    i_show_week,   pwk_l,     c_week)
    ln_pdH    := draw_line(ln_pdH,    i_show_pday,   pdH,       c_pday)
    ln_pdL    := draw_line(ln_pdL,    i_show_pday,   pdL,       c_pday)
    ln_friC   := draw_line(ln_friC,   i_show_fricp,  friC,      c_fricp)
    ln_wkibH  := draw_line(ln_wkibH,  ib_show,       wkib_h,    c_wkib)
    ln_wkibL  := draw_line(ln_wkibL,  ib_show,       wkib_l,    c_wkib)
    ln_strike := draw_line(ln_strike, strike_show,   strike_px, c_strike)

    // --- active measured-move target lines ---
    if array.size(tgt_lines) > 0
        for li = 0 to array.size(tgt_lines) - 1
            line.delete(array.get(tgt_lines, li))
        array.clear(tgt_lines)
    bool tgt_active = i_show_tgt and last_dir != 0 and sig_age <= 3 and not bias_invalidated and not na(sig_range) and sig_range > 0
    if tgt_active
        for m = 1 to i_tgt_n
            float tv = sig_anchor + sig_dir * m * sig_range
            line tl = line.new(bar_index, tv, bar_index + i_lvl_ext, tv, xloc=xloc.bar_index,
                 color=c_tgt, style=line.style_dotted, width=1)
            array.push(tgt_lines, tl)

    // --- merged right-edge labels: levels closer than the merge distance share one label ---
    float[]  Lpx = array.new_float()
    string[] Ltg = array.new_string()
    color[]  Lcl = array.new_color()
    f_lvl_add(Lpx, Ltg, Lcl, i_show_friday, friH,      "Fri H",  c_friday)
    f_lvl_add(Lpx, Ltg, Lcl, i_show_friday, friL,      "Fri L",  c_friday)
    f_lvl_add(Lpx, Ltg, Lcl, i_show_week,   pwk_h,     "Wk H",   c_week)
    f_lvl_add(Lpx, Ltg, Lcl, i_show_week,   pwk_l,     "Wk L",   c_week)
    f_lvl_add(Lpx, Ltg, Lcl, i_show_pday,   pdH,       "PD H",   c_pday)
    f_lvl_add(Lpx, Ltg, Lcl, i_show_pday,   pdL,       "PD L",   c_pday)
    f_lvl_add(Lpx, Ltg, Lcl, i_show_fricp,  friC,      "Fri CP", c_fricp)
    f_lvl_add(Lpx, Ltg, Lcl, ib_show,       wkib_h,    "IB H",   c_wkib)
    f_lvl_add(Lpx, Ltg, Lcl, ib_show,       wkib_l,    "IB L",   c_wkib)
    f_lvl_add(Lpx, Ltg, Lcl, strike_show,   strike_px, strike_tag, c_strike)
    if tgt_active
        for m = 1 to i_tgt_n
            f_lvl_add(Lpx, Ltg, Lcl, true, sig_anchor + sig_dir * m * sig_range, "T" + str.tostring(m), c_tgt)

    // --- expected-move rails (lines + labels) ---
    float[]  em_px = array.from(em_p05u, em_p10u, em_p15u, em_p20u, em_p05d, em_p10d, em_p15d, em_p20d, em_anchor)
    bool[]   em_sh = array.from(i_em_05, i_em_10, i_em_15, i_em_20, i_em_05, i_em_10, i_em_15, i_em_20, i_em_anc_ln)
    string[] em_tg = array.from("+0.5σ", "+1σ", "+1.5σ", "+2σ", "-0.5σ", "-1σ", "-1.5σ", "-2σ", "0σ")
    for ek = 0 to 8
        bool em_show = em_ok and array.get(em_sh, ek)
        array.set(em_lns, ek, draw_line(array.get(em_lns, ek), em_show, array.get(em_px, ek), c_em))
        f_lvl_add(Lpx, Ltg, Lcl, em_show, array.get(em_px, ek), array.get(em_tg, ek), c_em)

    while array.size(lvl_labels) > 0
        label.delete(array.pop(lvl_labels))
    int nL = array.size(Lpx)
    if nL > 0
        float tol = i_merge_tk * syminfo.mintick
        bool[] used = array.new_bool(nL, false)
        for i = 0 to nL - 1
            if not array.get(used, i)
                string mtxt = array.get(Ltg, i)
                float msum = array.get(Lpx, i)
                int mcnt = 1
                if i < nL - 1
                    for j = i + 1 to nL - 1
                        if not array.get(used, j) and math.abs(array.get(Lpx, j) - array.get(Lpx, i)) <= tol
                            mtxt := mtxt + " · " + array.get(Ltg, j)
                            msum := msum + array.get(Lpx, j)
                            mcnt := mcnt + 1
                            array.set(used, j, true)
                label ml = label.new(bar_index + i_lvl_ext, msum / mcnt, mtxt, xloc=xloc.bar_index,
                     yloc=yloc.price, style=label.style_label_left,
                     color=color.new(color.white, 100), textcolor=array.get(Lcl, i), size=lvl_lbl_sz())
                array.push(lvl_labels, ml)

// ============================== FRONTSIDE / BACKSIDE TINT ==============================
int live_dw = f_tradedow(time)
color fb_col = not i_show_fb_shade ? color(na) :
     live_dw == 2 or live_dw == 3 ? c_front :
     live_dw == 4 ? c_wreset :
     live_dw == 5 or live_dw == 6 ? c_back : color(na)
bgcolor(fb_col)

// ============================== SESSION BOXES (Asia / London running H/L) ==============================
update_sess_box(box[] boxes, bool was_in, bool now_in, color col, string tag) =>
    bool state = was_in
    if now_in and not was_in
        box b = box.new(bar_index, high, bar_index, low,
             border_color=color.new(col, 55), bgcolor=col, border_width=1,
             text=tag, text_color=color.new(col, 20), text_size=size.small,
             text_halign=text.align_left, text_valign=text.align_top)
        array.push(boxes, b)
        trim_boxes(boxes, i_sess_days)
        state := true
    else if now_in and was_in and array.size(boxes) > 0
        box b = array.get(boxes, array.size(boxes) - 1)
        box.set_right(b, bar_index)
        box.set_top(b, math.max(box.get_top(b), high))
        box.set_bottom(b, math.min(box.get_bottom(b), low))
    else if not now_in
        state := false
    state

if i_show_sess and timeframe.isintraday
    in_asia_s := update_sess_box(asia_boxes, in_asia_s, in_sess_win(i_asia_sh, i_asia_sm, i_asia_eh, i_asia_em), c_asia, "ASIA")
    in_lon_s  := update_sess_box(lon_boxes, in_lon_s, in_sess_win(i_lon_sh, i_lon_sm, i_lon_eh, i_lon_em), c_london, "LDN")

// ============================== STATUS TABLE ==============================
tbl_pos() =>
    switch i_tbl_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

tbl_sz() =>
    switch i_tbl_size
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

var table tbl = na
if i_show_table and barstate.islast
    tsz = tbl_sz()
    color gbg = color.new(color.gray, 80)
    float pdh_t = array.size(DHI) >= 1 ? f_at(DHI, 0) : na
    float pdl_t = array.size(DLO) >= 1 ? f_at(DLO, 0) : na

    // trap level: nearest Fri/Wk/PrevDay line in the bias direction
    float[]  tp_px = array.new_float()
    string[] tp_nm = array.new_string()
    if bias_dir < 0
        tp_px := array.from(friH, pwk_h, pdh_t)
        tp_nm := array.from("Fri H", "Wk H", "PD H")
    else if bias_dir > 0
        tp_px := array.from(friL, pwk_l, pdl_t)
        tp_nm := array.from("Fri L", "Wk L", "PD L")
    else
        tp_px := array.from(friH, friL, pwk_h, pwk_l, pdh_t, pdl_t)
        tp_nm := array.from("Fri H", "Fri L", "Wk H", "Wk L", "PD H", "PD L")
    [trap_px, trap_nm] = pick_nearest(tp_px, tp_nm, close, bias_dir != 0, bias_dir < 0)
    string trap_s = na(trap_px) ? "—" : trap_nm + " @ " + str.tostring(trap_px, format.mintick) +
         "  (" + str.tostring(math.abs(close - trap_px), "#.##") + "pt)"

    // live targets from the last FRD/FGD
    bool tgt_live = last_dir != 0 and sig_age <= 3 and not na(sig_range) and sig_range > 0
    string tgt_s = "—"
    if tgt_live
        string acc = ""
        for m = 1 to math.min(i_tgt_n, 3)
            float tv = sig_anchor + sig_dir * m * sig_range
            acc := acc + (m > 1 ? " / " : "") + str.tostring(tv, format.mintick)
        tgt_s := acc

    if na(tbl)
        tbl := table.new(tbl_pos(), 2, 17, border_width=1)

    bool inv = bias_invalidated
    bool trade_now = trade_day and not inv

    table.cell(tbl, 0, 0, "BURKE", text_color=color.white, bgcolor=color.new(color.blue, 0), text_size=tsz)
    table.cell(tbl, 1, 0, "Signal Day", text_color=color.white, bgcolor=color.new(color.blue, 0), text_size=tsz)

    string bias_lbl = inv ? "✕ INVALID → WAIT" : bias_dir > 0 ? "▲ LONG" : bias_dir < 0 ? "▼ SHORT" : "• WAIT"
    color  bias_bg  = inv ? color.new(color.orange, 15) : bias_dir > 0 ? color.new(color.green, 25) : bias_dir < 0 ? color.new(color.red, 25) : color.new(color.gray, 55)
    table.cell(tbl, 0, 1, "BIAS", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 1, bias_lbl, text_color=color.white, bgcolor=bias_bg, text_size=tsz)

    string setup_disp = inv ? "Invalidated — price broke the signal level, stand aside" : bias_txt
    table.cell(tbl, 0, 2, "Setup", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 2, setup_disp, text_color=color.white, bgcolor=gbg, text_size=tsz)

    string conv_disp = inv ? "—" : conviction
    color  conv_bg = conviction == "High" and not inv ? color.new(color.green, 35) : conviction == "Low" and not inv ? color.new(color.orange, 35) : gbg
    table.cell(tbl, 0, 3, "Conviction", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 3, conv_disp, text_color=color.white, bgcolor=conv_bg, text_size=tsz)

    table.cell(tbl, 0, 4, "Trade day?", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 4, trade_now ? "YES" : "no",
         text_color=color.white, bgcolor=trade_now ? color.new(color.green, 25) : gbg, text_size=tsz)

    string cyc_s = cycle_day > 0 ? "Day " + str.tostring(cycle_day) + (cycle_dir > 0 ? " ↑" : " ↓") : "—"
    if cycle_day > 0 and i_show_wk_tmpl
        cyc_s := cyc_s + (tmpl_match ? "  ⚡ on-template" : "  · off-template")
    color  cyc_bg = cycle_day == 3 ? color.new(c_day3, 20) : gbg
    table.cell(tbl, 0, 5, "Cycle", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 5, cyc_s, text_color=color.white, bgcolor=cyc_bg, text_size=tsz)

    table.cell(tbl, 0, 6, "Last signal", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 6, last_signal, text_color=color.white, bgcolor=gbg, text_size=tsz)

    table.cell(tbl, 0, 7, "Trap level", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 7, trap_s, text_color=color.white, bgcolor=gbg, text_size=tsz)

    table.cell(tbl, 0, 8, "Targets", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 8, tgt_s, text_color=color.white, bgcolor=gbg, text_size=tsz)

    table.cell(tbl, 0, 9, "Fri H/L · CP", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 9, na(friH) ? "—" : str.tostring(friH, format.mintick) + " / " + str.tostring(friL, format.mintick) +
         (na(friC) ? "" : " · " + str.tostring(friC, format.mintick)),
         text_color=color.white, bgcolor=gbg, text_size=tsz)

    table.cell(tbl, 0, 10, "Wk H/L", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 10, na(pwk_h) ? "—" : str.tostring(pwk_h, format.mintick) + " / " + str.tostring(pwk_l, format.mintick),
         text_color=color.white, bgcolor=gbg, text_size=tsz)

    table.cell(tbl, 0, 11, "PrevDay H/L", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 11, na(pdh_t) ? "—" : str.tostring(pdh_t, format.mintick) + " / " + str.tostring(pdl_t, format.mintick),
         text_color=color.white, bgcolor=gbg, text_size=tsz)

    string wk_s = f_wk_tag(live_dw)
    if wk_s == ""
        wk_s := "— (weekend)"
    if not na(friC)
        wk_s := wk_s + (close >= friC ? "  · above Fri CP" : "  · below Fri CP")
    color wk_bg = live_dw == 4 ? color.new(color.blue, 40) : gbg
    table.cell(tbl, 0, 12, "Week day", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 12, wk_s, text_color=color.white, bgcolor=wk_bg, text_size=tsz)

    string wed_s = wed_dir > 0 ? "Breakout ↑ — back-half long lean" :
         wed_dir < 0 ? "Breakdown ↓ — back-half short lean" : "—"
    color wed_bg = wed_dir > 0 ? color.new(color.green, 40) : wed_dir < 0 ? color.new(color.red, 40) : gbg
    table.cell(tbl, 0, 13, "Wed close", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 13, wed_s, text_color=color.white, bgcolor=wed_bg, text_size=tsz)

    // strike-zone ⚡ expected-move-rail confluence (two independent models agreeing)
    bool stk_rail = false
    if em_ok and not na(strike_px)
        float em_tol = 0.15 * em_sig1
        stk_rail := (i_em_05 and (f_near(strike_px, em_p05u, em_tol) or f_near(strike_px, em_p05d, em_tol))) or
             (i_em_10 and (f_near(strike_px, em_p10u, em_tol) or f_near(strike_px, em_p10d, em_tol))) or
             (i_em_15 and (f_near(strike_px, em_p15u, em_tol) or f_near(strike_px, em_p15d, em_tol))) or
             (i_em_20 and (f_near(strike_px, em_p20u, em_tol) or f_near(strike_px, em_p20d, em_tol)))
    string stk_s = na(strike_px) ? "—" :
         (cycle_dir < 0 ? "SELL rally @ " : "BUY dip @ ") + str.tostring(strike_px, format.mintick) +
         "  (" + str.tostring(math.abs(close - strike_px), "#.##") + "pt)" + (strike_hit ? "  ✓ tagged" : "") +
         (stk_rail ? "  ⚡ EM rail" : "")
    color stk_bg = strike_hit ? color.new(c_strike, 35) : gbg
    table.cell(tbl, 0, 14, "Strike zone", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 14, stk_s, text_color=color.white, bgcolor=stk_bg, text_size=tsz)

    // expected move: 1σ size + where price sits in σ terms right now
    string em_s = "—"
    color  em_bg = gbg
    if em_ok
        float sig_now = (close - em_anchor) / em_sig1
        em_s := "±" + str.tostring(em_sig1, "#.#") + "pt (1σ) · now " + (sig_now >= 0 ? "+" : "") + str.tostring(sig_now, "#.##") + "σ"
        em_bg := math.abs(sig_now) >= 2 ? color.new(color.red, 35) : math.abs(sig_now) >= 1 ? color.new(color.orange, 35) : gbg
    table.cell(tbl, 0, 15, "Exp. move", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 15, em_s, text_color=color.white, bgcolor=em_bg, text_size=tsz)

    string ib_s = wkib_on and not na(wkib_h) ?
         str.tostring(wkib_h, format.mintick) + " / " + str.tostring(wkib_l, format.mintick) :
         not na(wkib_h) ? "forming (Tue pending)" : "—"
    table.cell(tbl, 0, 16, "Wk IB", text_color=color.white, bgcolor=gbg, text_size=tsz)
    table.cell(tbl, 1, 16, ib_s, text_color=color.white, bgcolor=gbg, text_size=tsz)

// ============================== STRUCTURE & ZONES (BOS · Supply/Demand) ==============================
var line[]  bos_lines  = array.new_line()
var label[] bos_labels = array.new_label()
var box[]   sup_boxes  = array.new_box()
var box[]   dem_boxes  = array.new_box()

// last confirmed swing (for BOS detection)
var float swH       = na
var int   swH_bar   = na
var bool  swH_broke = true
var float swL       = na
var int   swL_bar   = na
var bool  swL_broke = true

trim_lines(line[] a, int cap) =>
    while array.size(a) > cap
        line.delete(array.shift(a))

bos_sz() =>
    switch i_bos_sz
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        => size.small

// price already sits inside an existing same-side zone? (skip duplicates)
f_in_zone(box[] zones, float px) =>
    bool hit = false
    if array.size(zones) > 0
        for zi = 0 to array.size(zones) - 1
            box zb = array.get(zones, zi)
            if px <= box.get_top(zb) and px >= box.get_bottom(zb)
                hit := true
    hit

float piv_h = ta.pivothigh(high, i_sw_len, i_sw_len)
float piv_l = ta.pivotlow(low, i_sw_len, i_sw_len)

if (i_show_bos or i_show_sd) and barstate.isconfirmed
    // --- new confirmed swing high → arm BOS + spawn supply zone ---
    if not na(piv_h)
        swH := piv_h
        swH_bar := bar_index - i_sw_len
        swH_broke := false
        if i_show_sd and not f_in_zone(sup_boxes, piv_h)
            float z_bot = math.min(math.max(open[i_sw_len], close[i_sw_len]), piv_h - syminfo.mintick)
            box sb = box.new(swH_bar, piv_h, bar_index + i_lvl_ext, z_bot,
                 border_color=c_sup_br, bgcolor=c_sup_bg, border_width=1,
                 text="SUPPLY", text_color=color.white, text_size=size.tiny,
                 text_halign=text.align_center, text_valign=text.align_center)
            array.push(sup_boxes, sb)
            trim_boxes(sup_boxes, i_sd_max)

    // --- new confirmed swing low → arm BOS + spawn demand zone ---
    if not na(piv_l)
        swL := piv_l
        swL_bar := bar_index - i_sw_len
        swL_broke := false
        if i_show_sd and not f_in_zone(dem_boxes, piv_l)
            float z_top = math.max(math.min(open[i_sw_len], close[i_sw_len]), piv_l + syminfo.mintick)
            box db = box.new(swL_bar, z_top, bar_index + i_lvl_ext, piv_l,
                 border_color=c_dem_br, bgcolor=c_dem_bg, border_width=1,
                 text="DEMAND", text_color=color.white, text_size=size.tiny,
                 text_halign=text.align_center, text_valign=text.align_center)
            array.push(dem_boxes, db)
            trim_boxes(dem_boxes, i_sd_max)

    // --- BOS events (close through the last unbroken swing) ---
    if not swH_broke and not na(swH) and close > swH
        swH_broke := true
        if i_show_bos
            array.push(bos_lines, line.new(swH_bar, swH, bar_index, swH,
                 color=color.new(c_bos, 55), style=line.style_solid, width=1))
            array.push(bos_labels, label.new((swH_bar + bar_index) / 2, swH, "BOS",
                 yloc=yloc.price, style=label.style_none, textcolor=c_bos, size=bos_sz()))
    if not swL_broke and not na(swL) and close < swL
        swL_broke := true
        if i_show_bos
            array.push(bos_lines, line.new(swL_bar, swL, bar_index, swL,
                 color=color.new(c_bos, 55), style=line.style_solid, width=1))
            array.push(bos_labels, label.new((swL_bar + bar_index) / 2, swL, "BOS",
                 yloc=yloc.price, style=label.style_none, textcolor=c_bos, size=bos_sz()))
    trim_lines(bos_lines, i_bos_keep)
    trim_labels(bos_labels, i_bos_keep)

    // --- zone mitigation: a close through the far edge deletes the zone ---
    if i_show_sd
        int si = 0
        while si < array.size(sup_boxes)
            if close > box.get_top(array.get(sup_boxes, si))
                box.delete(array.get(sup_boxes, si))
                array.remove(sup_boxes, si)
            else
                si += 1
        int di = 0
        while di < array.size(dem_boxes)
            if close < box.get_bottom(array.get(dem_boxes, di))
                box.delete(array.get(dem_boxes, di))
                array.remove(dem_boxes, di)
            else
                di += 1

// keep zone right edges aligned with the level extension distance
if i_show_sd
    if array.size(sup_boxes) > 0
        for bi = 0 to array.size(sup_boxes) - 1
            box.set_right(array.get(sup_boxes, bi), bar_index + i_lvl_ext)
    if array.size(dem_boxes) > 0
        for bi = 0 to array.size(dem_boxes) - 1
            box.set_right(array.get(dem_boxes, bi), bar_index + i_lvl_ext)
````
