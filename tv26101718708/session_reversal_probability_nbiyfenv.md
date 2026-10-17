# Session Reversal Probability

- url: https://www.tradingview.com/script/NBiyfEnV-Session-Reversal-Probability/
- type: indicator
- pine_id: PUB;e0ab181e18dd49aaa95fddde5e41f055
- version: 1.0

## Description

[b]Institutional tier detection for Micro Gold Futures[/b]

Identifies price consolidation zones during the MGC Globex session (6 PM – 5 PM ET) and classifies them into three tiers based on how long price holds within a defined range. Built specifically for Micro Gold Futures (MGC) but applicable to any instrument with extended trading hours.

[i]How it works[/i]

The script tracks three independent range thresholds simultaneously (5pt, 7pt, and 10pt). When price holds within a threshold for a sustained period, the zone is promoted through a tier system:

B-Tier (yellow) — consolidation held for 15+ minutes. Zone is forming.
A-Tier (orange) — consolidation held for 30+ minutes. Institutionally relevant.
S-Tier (purple) — consolidation held for 60+ minutes. High-conviction accumulation or distribution zone.

Each tier upgrade fires a separate alert. Zones are drawn as boxes and extend forward until price breaks out. When price exits a zone, the box border updates to reflect the final tier achieved.

[i]What to look for[/i]
S-Tier zones represent price areas where neither buyers nor sellers were willing to push price significantly. These are the levels institutions use to quietly accumulate or distribute positions. A breakout from an S-Tier zone — especially with elevated volume — is a high-probability directional signal.
Inputs

Range thresholds for each of the three trackers
Tier promotion times (B / A / S in minutes)
Session window (default 6 PM – 5 PM ET)
Per-tier visibility toggles

## Source Code

````pine
//@version=6
indicator("Session Reversal Probability", shorttitle="Reversal Zone", overlay=true,
          max_lines_count=200, max_boxes_count=80, max_labels_count=200)

// ══════════════════════════════════════════════════════════════════════════════
//  MGC SESSION REVERSAL PROBABILITY  |  Pine Script v6  — Enhanced Edition
//
//  MGC Trading Day : 6:00 PM → 5:00 PM ET (Globex)
//
//  Named Windows (ET):
//    NYT    Consol 06:00–07:00  →  Reversal 07:00–07:30
//    Tokyo  Consol 20:00–21:00  →  Reversal 21:00–21:30
//    London Consol 03:00–04:00  →  Reversal 04:00–04:30
//
//  Rolling Windows:
//    recent_n (default 3)  — probability displayed on chart (last 3 sessions)
//    hist capacity (10)    — S-tier classification window
//
//  Tier System (matches Consolidation script visual language):
//    S-Tier : ≥ s_tier_pct (default 60%) historical freq  — purple  — super
//    A-Tier : ≥ a_tier_pct (default 40%) historical freq  — orange  — good
//    B-Tier : < a_tier_pct                                — yellow  — forming
//
//  Statistical Confidence (ported from Fib Probability script, no duplication):
//    t-test on direction-normalised returns  →  HIGH ★ / MED ◆ / TREND / LOW
//    Binomial z-score on win-rate vs 50%     →  p<0.05 / p<0.10
//    Wilson Score 95% CI on displayed prob
//
//  Auto-Discovery:
//    Scans all 23 MGC hourly slots. Only surfaces slots that reach S-Tier
//    (≥ s_tier_pct over 10+ observations). Keeps chart clean.
//
//  Redundancy avoidance:
//    Volume node confluence → handled by MGC Fibonacci Probability
//    Fib levels             → handled by MGC Fibonacci Probability
//    Time-based consol tier → handled by MGC Consolidation Detector
//    This script owns: named session reversal tracking + statistical confidence
// ══════════════════════════════════════════════════════════════════════════════

// ─── INPUTS ──────────────────────────────────────────────────────────────────
g1 = "① Reversal Parameters"
rev_pts    = input.float(5.0, "Direction flip threshold (pts, Cond A)", minval=0.5, step=0.5, group=g1)
consol_pts = input.float(8.0, "Max consolidation range (pts)",          minval=0.5, step=0.5, group=g1)

g2 = "② Named Sessions (ET)"
show_nyt   = input.bool(true, "NYT    | Consol 06:00–07:00 / Rev 07:00–07:30", group=g2)
show_tok   = input.bool(true, "Tokyo  | Consol 20:00–21:00 / Rev 21:00–21:30", group=g2)
show_lon   = input.bool(true, "London | Consol 03:00–04:00 / Rev 04:00–04:30", group=g2)

g3 = "③ Rolling Windows + Tier Thresholds"
recent_n   = input.int(3,    "Recent window (displayed probability)", minval=2, maxval=5,   group=g3,
                        tooltip="Probability shown on chart = last N sessions of that type.")
s_tier_pct = input.float(60.0, "S-Tier threshold (%, 10-session)",   minval=40.0, maxval=99.0, step=5.0, group=g3,
                        tooltip="6/10 = 60%  →  S-Tier designation.")
a_tier_pct = input.float(40.0, "A-Tier threshold (%, 10-session)",   minval=20.0, maxval=80.0, step=5.0, group=g3)

g4 = "④ Auto-Discovery (S-Tier Slots Only)"
show_auto   = input.bool(true,  "Surface S-Tier hourly slots",       group=g4)
auto_min_obs = input.int(8,     "Min observations to qualify",        group=g4, minval=3, maxval=15)

g5 = "⑤ Display"
show_lbl   = input.bool(true, "Session probability labels",  group=g5)
show_bg    = input.bool(true, "Session background shading",  group=g5)
show_table = input.bool(false, "Dashboard table",             group=g5)

// ─── COLORS ──────────────────────────────────────────────────────────────────
// Tier palette — matches MGC Consolidation Detector
C_S      = color.new(#9B59B6, 55)   // S-Tier — purple
C_A      = color.new(color.orange, 60)
C_B      = color.new(color.yellow, 70)
C_S_BDR  = color.new(#9B59B6,  5)
C_A_BDR  = color.new(color.orange, 15)
C_B_BDR  = color.new(color.yellow, 15)

// Session bg tints
C_NYT_C  = color.new(#4FC3F7, 85)
C_NYT_R  = color.new(#0288D1, 72)
C_TOK_C  = color.new(#A5D6A7, 85)
C_TOK_R  = color.new(#2E7D32, 72)
C_LON_C  = color.new(#CE93D8, 85)
C_LON_R  = color.new(#6A1B9A, 72)

// Stat confidence colors
C_HIGH   = color.new(#2ECC71, 30)
C_MED    = color.new(#F39C12, 40)
C_WHITE  = color.white
C_DARK   = color.new(#111111, 20)
C_DIM    = color.new(color.gray, 40)

// ─── TIME ────────────────────────────────────────────────────────────────────
TZ   = "America/New_York"
et_h = hour(time,   TZ)
et_m = minute(time, TZ)
et_t = et_h * 100 + et_m

bool in_sess     = not na(time("1", "1800-1700", TZ))
bool mgc_new_day = et_t >= 1800 and et_t[1] < 1800

// Named window flags
bool in_nyt_c = show_nyt and et_t >= 600  and et_t < 700
bool in_nyt_r = show_nyt and et_t >= 700  and et_t < 730
bool in_tok_c = show_tok and et_t >= 2000 and et_t < 2100
bool in_tok_r = show_tok and et_t >= 2100 and et_t < 2130
bool in_lon_c = show_lon and et_t >= 300  and et_t < 400
bool in_lon_r = show_lon and et_t >= 400  and et_t < 430

bool nyt_c_ent = in_nyt_c and not in_nyt_c[1]
bool nyt_c_ext = not in_nyt_c and in_nyt_c[1]
bool nyt_r_ent = in_nyt_r and not in_nyt_r[1]
bool nyt_r_ext = not in_nyt_r and in_nyt_r[1]
bool tok_c_ent = in_tok_c and not in_tok_c[1]
bool tok_c_ext = not in_tok_c and in_tok_c[1]
bool tok_r_ent = in_tok_r and not in_tok_r[1]
bool tok_r_ext = not in_tok_r and in_tok_r[1]
bool lon_c_ent = in_lon_c and not in_lon_c[1]
bool lon_c_ext = not in_lon_c and in_lon_c[1]
bool lon_r_ent = in_lon_r and not in_lon_r[1]
bool lon_r_ext = not in_lon_r and in_lon_r[1]

// ─── UDT: SESSION STATE ───────────────────────────────────────────────────────
// hist_ret stores direction-normalised return for each scored session.
// Capacity fixed at 10 to support S-tier classification.
// hist[i]: 0=no reversal  1=one condition  2=both conditions
type Sess
    int          st
    float        c_hi
    float        c_lo
    float        c_op
    float        c_cl
    float        r_op
    float        r_cl
    float        r_hi
    float        r_lo
    bool         r_bu
    bool         r_bd
    array<int>   hist
    array<float> hist_ret
    int          di
    int          ns
    int          c_bar0
    int          r_bar0
    int          total
    int          wins_all

// ─── STATISTICAL HELPERS (ported from MGC Fibonacci Probability) ──────────────
// Reads the most recent n entries from the circular buffer (last-n-in order).
// Positive return = reversal went the expected direction.

// t-statistic: H0 = mean return = 0 (one-tailed: mean > 0)
t_stat_sess(Sess s, int n) =>
    int cap   = 10
    int n_use = math.min(s.ns, n)
    if n_use < 3
        0.0
    else
        float sr = 0.0
        float sq = 0.0
        for i = 1 to n_use
            int   idx = (s.di - i + cap) % cap
            float r   = array.get(s.hist_ret, idx)
            sr += r
            sq += r * r
        float mn   = sr / n_use
        float vari = (sq - n_use * mn * mn) / math.max(1, n_use - 1)
        float sd   = math.sqrt(math.max(0.0, vari))
        sd > 0 ? mn / (sd / math.sqrt(float(n_use))) : 0.0

// Binomial z: H0 = win-rate = 0.5
binom_z_sess(Sess s, int n) =>
    // n param kept for API compatibility but uses ALL observations for power
    int tot = s.total
    if tot < 5
        0.0
    else
        float se = math.sqrt(0.25 / float(tot))
        se > 0 ? (float(s.wins_all) / float(tot) - 0.5) / se : 0.0

// Wilson 95% CI — returns [lower%, upper%]
wilson_sess(Sess s, int n) =>
    int cap   = 10
    int n_use = math.min(s.ns, n)
    if n_use < 2
        [0.0, 100.0]
    else
        int wins = 0
        for i = 1 to n_use
            int idx = (s.di - i + cap) % cap
            if array.get(s.hist, idx) > 0
                wins += 1
        float z    = 1.96
        float z2   = z * z
        float denom = float(n_use) + z2
        float ctr  = (float(wins) + z2 / 2.0) / denom
        float marg = z * math.sqrt((float(wins) * float(n_use - wins) / float(n_use) + z2 / 4.0)) / denom
        [math.max(0.0, ctr - marg) * 100.0, math.min(1.0, ctr + marg) * 100.0]

// Confidence label
conf_lbl(float t, float bz, int ns) =>
    if ns < 5
        "INSUFF"
    else if t >= 1.645 and bz >= 1.645
        "HIGH ★"
    else if t >= 1.645 or bz >= 1.645
        "MED ◆"
    else if t >= 1.282 or bz >= 1.282
        "TREND"
    else
        "LOW"

conf_clr(string lbl) =>
    lbl == "HIGH ★" ? C_HIGH : lbl == "MED ◆" ? C_MED : C_DIM

// ─── PROBABILITY HELPERS ─────────────────────────────────────────────────────

// Recent n-session probability (reads last n entries from circular buffer)
recent_prob(Sess s, int n) =>
    int cap   = 10
    int n_use = math.min(s.ns, n)
    if n_use == 0
        float(na)
    else
        int rev = 0
        for i = 1 to n_use
            int idx = (s.di - i + cap) % cap
            if array.get(s.hist, idx) > 0
                rev += 1
        float(rev) / float(n_use) * 100.0

// Historical 10-session probability (for tier classification)
hist_prob(Sess s) =>
    int cap   = 10
    int n_use = math.min(s.ns, cap)
    if n_use == 0
        float(na)
    else
        int rev = 0
        for i = 0 to n_use - 1
            if array.get(s.hist, i) > 0
                rev += 1
        float(rev) / float(n_use) * 100.0

// Tier from historical probability
get_tier(float hp) =>
    if na(hp)
        "–"
    else if hp >= s_tier_pct
        "S"
    else if hp >= a_tier_pct
        "A"
    else
        "B"

tier_fill(string t) =>
    t == "S" ? C_S : t == "A" ? C_A : C_B

tier_bdr(string t) =>
    t == "S" ? C_S_BDR : t == "A" ? C_A_BDR : C_B_BDR

// Reversal scorer — Cond A (direction flip) + Cond B (failed breakout)
score_rev(float c_op, float c_cl, float c_hi, float c_lo,
          float r_op, float r_cl, float r_hi, float r_lo,
          bool r_bu, bool r_bd) =>
    float c_dir = c_cl - c_op
    float r_dir = r_cl - r_op
    bool cond_a = math.abs(c_dir) >= rev_pts and math.abs(r_dir) >= rev_pts and (c_dir > 0) != (r_dir > 0)
    bool cond_b = (r_bu or r_bd) and r_cl >= c_lo and r_cl <= c_hi
    (cond_a ? 1 : 0) + (cond_b ? 1 : 0)

// ─── SESSION STATE MACHINE ────────────────────────────────────────────────────
process_sess(Sess s, bool c_ent, bool c_in, bool c_ext, bool r_ent, bool r_in, bool r_ext) =>
    if c_ent
        s.st     := 1
        s.c_hi   := high
        s.c_lo   := low
        s.c_op   := open
        s.c_cl   := close
        s.c_bar0 := bar_index

    if s.st == 1 and c_in and not c_ent
        s.c_hi := math.max(s.c_hi, high)
        s.c_lo := math.min(s.c_lo, low)
        s.c_cl := close

    if c_ext and s.st == 1
        s.st := 2

    if r_ent and s.st == 2
        s.st     := 3
        s.r_op   := open
        s.r_cl   := close
        s.r_hi   := high
        s.r_lo   := low
        s.r_bu   := false
        s.r_bd   := false
        s.r_bar0 := bar_index

    if s.st == 3 and r_in and not r_ent
        s.r_hi := math.max(s.r_hi, high)
        s.r_lo := math.min(s.r_lo, low)
        s.r_cl := close
        if high > s.c_hi
            s.r_bu := true
        if low  < s.c_lo
            s.r_bd := true

    if r_ext and s.st == 3
        int   str     = score_rev(s.c_op, s.c_cl, s.c_hi, s.c_lo,
                                   s.r_op, s.r_cl, s.r_hi, s.r_lo,
                                   s.r_bu, s.r_bd)
        // Direction-normalised return: opposite of consol direction = successful reversal
        float c_dir   = s.c_cl - s.c_op
        float ret_val = c_dir > 0 ? (s.r_op - s.r_cl) : (s.r_cl - s.r_op)
        array.set(s.hist,     s.di, str)
        array.set(s.hist_ret, s.di, ret_val)
        s.di        := (s.di + 1) % 10
        s.ns        := math.min(s.ns + 1, 10)
        s.total     := s.total + 1
        s.wins_all  := s.wins_all + (str > 0 ? 1 : 0)
        s.st        := 0

// ─── SESSION INSTANCES ───────────────────────────────────────────────────────
var Sess nyt = Sess.new(0, na, na, na, na, na, na, na, na, false, false,
                         array.new<int>(10, 0), array.new<float>(10, 0.0), 0, 0, 0, 0, 0, 0)
var Sess tok = Sess.new(0, na, na, na, na, na, na, na, na, false, false,
                         array.new<int>(10, 0), array.new<float>(10, 0.0), 0, 0, 0, 0, 0, 0)
var Sess lon = Sess.new(0, na, na, na, na, na, na, na, na, false, false,
                         array.new<int>(10, 0), array.new<float>(10, 0.0), 0, 0, 0, 0, 0, 0)

process_sess(nyt, nyt_c_ent, in_nyt_c, nyt_c_ext, nyt_r_ent, in_nyt_r, nyt_r_ext)
process_sess(tok, tok_c_ent, in_tok_c, tok_c_ext, tok_r_ent, in_tok_r, tok_r_ext)
process_sess(lon, lon_c_ent, in_lon_c, lon_c_ext, lon_r_ent, in_lon_r, lon_r_ext)

// ─── PROBABILITIES + TIERS + STATISTICS ──────────────────────────────────────
// Recent (displayed) probability
float rp_nyt = recent_prob(nyt, recent_n)
float rp_tok = recent_prob(tok, recent_n)
float rp_lon = recent_prob(lon, recent_n)

// Historical (tier classification, 10-session)
float hp_nyt = hist_prob(nyt)
float hp_tok = hist_prob(tok)
float hp_lon = hist_prob(lon)

// Tier
string tier_nyt = get_tier(hp_nyt)
string tier_tok = get_tier(hp_tok)
string tier_lon = get_tier(hp_lon)

// Statistical confidence (over recent_n sessions)
// Stats use full available history (up to 10) — decoupled from recent_n display window.
// Reason: binomial z requires n≥5; recent_n=3 always returns 0 → always "LOW".
// Displayed probability stays recent_n (responsive); confidence uses all data (rigorous).
int stat_n_nyt = math.min(nyt.ns, 10)
int stat_n_tok = math.min(tok.ns, 10)
int stat_n_lon = math.min(lon.ns, 10)

float t_nyt  = t_stat_sess(nyt, stat_n_nyt)
float t_tok  = t_stat_sess(tok, stat_n_tok)
float t_lon  = t_stat_sess(lon, stat_n_lon)
float bz_nyt = binom_z_sess(nyt, stat_n_nyt)
float bz_tok = binom_z_sess(tok, stat_n_tok)
float bz_lon = binom_z_sess(lon, stat_n_lon)

string conf_nyt = conf_lbl(t_nyt, bz_nyt, nyt.total)
string conf_tok = conf_lbl(t_tok, bz_tok, tok.total)
string conf_lon = conf_lbl(t_lon, bz_lon, lon.total)

// Wilson CI also over full history for accuracy
[w_nyt_lo, w_nyt_hi] = wilson_sess(nyt, stat_n_nyt)
[w_tok_lo, w_tok_hi] = wilson_sess(tok, stat_n_tok)
[w_lon_lo, w_lon_hi] = wilson_sess(lon, stat_n_lon)

// ─── DISPLAY HELPERS ─────────────────────────────────────────────────────────
prob_str(float p) =>
    na(p) ? "–" : str.tostring(math.round(p)) + "%"

tier_str_full(string t, float rp, float hp) =>
    string marker = t == "S" ? " ★" : t == "A" ? " ◆" : ""
    string r_s = na(rp) ? "–" : str.tostring(math.round(rp)) + "%"
    string h_s = na(hp) ? "–" : str.tostring(math.round(hp)) + "%"
    t + "-TIER" + marker + "  " + r_s + " (" + str.tostring(recent_n) + "d) | " + h_s + " (10d)"

ci_str(float lo, float hi) =>
    str.tostring(math.round(lo)) + "–" + str.tostring(math.round(hi)) + "%"

// ─── NAMED SESSION BOXES ─────────────────────────────────────────────────────
var box nyt_c_bx = na
var box nyt_r_bx = na
var label nyt_lbl = na
var box tok_c_bx = na
var box tok_r_bx = na
var label tok_lbl = na
var box lon_c_bx = na
var box lon_r_bx = na
var label lon_lbl = na

// NYT boxes
if nyt_c_ent
    if not na(nyt_c_bx)
        box.delete(nyt_c_bx)
    nyt_c_bx := box.new(bar_index, high, bar_index, low,
                          border_color=tier_bdr(tier_nyt), bgcolor=tier_fill(tier_nyt), border_width=1)

if in_nyt_c and not na(nyt_c_bx)
    box.set_right(nyt_c_bx,  bar_index)
    box.set_top(nyt_c_bx,    nyt.c_hi)
    box.set_bottom(nyt_c_bx, nyt.c_lo)

if nyt_r_ent
    if not na(nyt_r_bx)
        box.delete(nyt_r_bx)
    nyt_r_bx := box.new(bar_index, high, bar_index, low,
                          border_color=color.new(#0288D1, 20), bgcolor=C_NYT_R, border_width=1)

if in_nyt_r and not na(nyt_r_bx)
    box.set_right(nyt_r_bx,  bar_index)
    box.set_top(nyt_r_bx,    math.max(nyt.c_hi, nyt.r_hi))
    box.set_bottom(nyt_r_bx, math.min(nyt.c_lo, nyt.r_lo))

if nyt_r_ext and show_lbl
    color  lc = tier_bdr(tier_nyt)
    string ts = tier_str_full(tier_nyt, rp_nyt, hp_nyt)
    if not na(nyt_lbl)
        label.delete(nyt_lbl)
    nyt_lbl := label.new(bar_index, math.max(nyt.c_hi, nyt.r_hi),
                          "NYT  " + ts + "\n" + conf_nyt + "  CI " + ci_str(w_nyt_lo, w_nyt_hi),
                          style=label.style_label_down, color=lc, textcolor=C_WHITE, size=size.small)
    if not na(nyt_c_bx)
        box.set_border_color(nyt_c_bx, lc)

// Tokyo boxes
if tok_c_ent
    if not na(tok_c_bx)
        box.delete(tok_c_bx)
    tok_c_bx := box.new(bar_index, high, bar_index, low,
                          border_color=tier_bdr(tier_tok), bgcolor=tier_fill(tier_tok), border_width=1)

if in_tok_c and not na(tok_c_bx)
    box.set_right(tok_c_bx,  bar_index)
    box.set_top(tok_c_bx,    tok.c_hi)
    box.set_bottom(tok_c_bx, tok.c_lo)

if tok_r_ent
    if not na(tok_r_bx)
        box.delete(tok_r_bx)
    tok_r_bx := box.new(bar_index, high, bar_index, low,
                          border_color=color.new(#2E7D32, 20), bgcolor=C_TOK_R, border_width=1)

if in_tok_r and not na(tok_r_bx)
    box.set_right(tok_r_bx,  bar_index)
    box.set_top(tok_r_bx,    math.max(tok.c_hi, tok.r_hi))
    box.set_bottom(tok_r_bx, math.min(tok.c_lo, tok.r_lo))

if tok_r_ext and show_lbl
    color  lc = tier_bdr(tier_tok)
    string ts = tier_str_full(tier_tok, rp_tok, hp_tok)
    if not na(tok_lbl)
        label.delete(tok_lbl)
    tok_lbl := label.new(bar_index, math.max(tok.c_hi, tok.r_hi),
                          "Tokyo  " + ts + "\n" + conf_tok + "  CI " + ci_str(w_tok_lo, w_tok_hi),
                          style=label.style_label_down, color=lc, textcolor=C_WHITE, size=size.small)
    if not na(tok_c_bx)
        box.set_border_color(tok_c_bx, lc)

// London boxes
if lon_c_ent
    if not na(lon_c_bx)
        box.delete(lon_c_bx)
    lon_c_bx := box.new(bar_index, high, bar_index, low,
                          border_color=tier_bdr(tier_lon), bgcolor=tier_fill(tier_lon), border_width=1)

if in_lon_c and not na(lon_c_bx)
    box.set_right(lon_c_bx,  bar_index)
    box.set_top(lon_c_bx,    lon.c_hi)
    box.set_bottom(lon_c_bx, lon.c_lo)

if lon_r_ent
    if not na(lon_r_bx)
        box.delete(lon_r_bx)
    lon_r_bx := box.new(bar_index, high, bar_index, low,
                          border_color=color.new(#6A1B9A, 20), bgcolor=C_LON_R, border_width=1)

if in_lon_r and not na(lon_r_bx)
    box.set_right(lon_r_bx,  bar_index)
    box.set_top(lon_r_bx,    math.max(lon.c_hi, lon.r_hi))
    box.set_bottom(lon_r_bx, math.min(lon.c_lo, lon.r_lo))

if lon_r_ext and show_lbl
    color  lc = tier_bdr(tier_lon)
    string ts = tier_str_full(tier_lon, rp_lon, hp_lon)
    if not na(lon_lbl)
        label.delete(lon_lbl)
    lon_lbl := label.new(bar_index, math.max(lon.c_hi, lon.r_hi),
                          "London  " + ts + "\n" + conf_lon + "  CI " + ci_str(w_lon_lo, w_lon_hi),
                          style=label.style_label_down, color=lc, textcolor=C_WHITE, size=size.small)
    if not na(lon_c_bx)
        box.set_border_color(lon_c_bx, lc)

// ─── BACKGROUND SHADING ───────────────────────────────────────────────────────
bgcolor(show_bg and in_nyt_c ? C_NYT_C : na, title="NYT Consol BG")
bgcolor(show_bg and in_nyt_r ? C_NYT_R : na, title="NYT Rev BG")
bgcolor(show_bg and in_tok_c ? C_TOK_C : na, title="Tokyo Consol BG")
bgcolor(show_bg and in_tok_r ? C_TOK_R : na, title="Tokyo Rev BG")
bgcolor(show_bg and in_lon_c ? C_LON_C : na, title="London Consol BG")
bgcolor(show_bg and in_lon_r ? C_LON_R : na, title="London Rev BG")

// ─── AUTO-DISCOVERY: S-TIER HOURLY SLOTS ─────────────────────────────────────
// Scans all 23 MGC session hours. Only surfaces slots reaching S-Tier.
// Avoids cluttering chart with mediocre zones — complements named sessions.

var array<float> ad_hi    = array.new<float>(24, na)
var array<float> ad_lo    = array.new<float>(24, na)
var array<float> ad_op    = array.new<float>(24, na)
var array<float> ad_cl    = array.new<float>(24, na)
var array<float> ad_r_op  = array.new<float>(24, na)
var array<float> ad_r_cl  = array.new<float>(24, na)
var array<float> ad_c_his = array.new<float>(24, na)
var array<float> ad_c_los = array.new<float>(24, na)
var array<bool>  ad_r_in  = array.new<bool>(24, false)
var array<bool>  ad_r_bu  = array.new<bool>(24, false)
var array<bool>  ad_r_bd  = array.new<bool>(24, false)
var array<int>   ad_total = array.new<int>(24, 0)
var array<int>   ad_revs  = array.new<int>(24, 0)

if show_auto and in_sess
    int  slot      = et_h
    int  prev_slot = (et_h - 1 + 24) % 24
    bool new_hour  = et_h != et_h[1]

    if slot != 17
        if new_hour
            array.set(ad_hi, slot, high)
            array.set(ad_lo, slot, low)
            array.set(ad_op, slot, open)
            array.set(ad_cl, slot, close)
        else if not na(array.get(ad_hi, slot))
            array.set(ad_hi, slot, math.max(array.get(ad_hi, slot), high))
            array.set(ad_lo, slot, math.min(array.get(ad_lo, slot), low))
            array.set(ad_cl, slot, close)

    if new_hour and prev_slot != 17
        float chi = array.get(ad_hi, prev_slot)
        float clo = array.get(ad_lo, prev_slot)
        bool  had_consol = not na(chi) and not na(clo) and (chi - clo) <= consol_pts
        array.set(ad_r_in, prev_slot, had_consol)
        if had_consol
            array.set(ad_c_his, prev_slot, chi)
            array.set(ad_c_los, prev_slot, clo)
            array.set(ad_r_op,  prev_slot, open)
            array.set(ad_r_cl,  prev_slot, close)
            array.set(ad_r_bu,  prev_slot, false)
            array.set(ad_r_bd,  prev_slot, false)

    if et_m < 30 and prev_slot != 17 and array.get(ad_r_in, prev_slot)
        array.set(ad_r_cl, prev_slot, close)
        if high > array.get(ad_c_his, prev_slot)
            array.set(ad_r_bu, prev_slot, true)
        if low  < array.get(ad_c_los, prev_slot)
            array.set(ad_r_bd, prev_slot, true)

    bool rev_ended = et_m == 30 and et_m[1] < 30
    if rev_ended and prev_slot != 17 and array.get(ad_r_in, prev_slot)
        float cop  = array.get(ad_op,    prev_slot)
        float ccl  = array.get(ad_cl,    prev_slot)
        float rop  = array.get(ad_r_op,  prev_slot)
        float rcl  = array.get(ad_r_cl,  prev_slot)
        float cdir = ccl - cop
        float rdir = rcl - rop
        bool  rbu  = array.get(ad_r_bu,  prev_slot)
        bool  rbd  = array.get(ad_r_bd,  prev_slot)
        float chi  = array.get(ad_c_his, prev_slot)
        float clo  = array.get(ad_c_los, prev_slot)
        bool cond_a = math.abs(cdir) >= rev_pts and math.abs(rdir) >= rev_pts and (cdir > 0) != (rdir > 0)
        bool cond_b = (rbu or rbd) and rcl >= clo and rcl <= chi
        array.set(ad_total, prev_slot, array.get(ad_total, prev_slot) + 1)
        if cond_a or cond_b
            array.set(ad_revs, prev_slot, array.get(ad_revs, prev_slot) + 1)
        array.set(ad_r_in, prev_slot, false)

// Live S-tier shading for auto-discovered slots
float ad_prob = na
bool  is_named_win = in_nyt_c or in_nyt_r or in_tok_c or in_tok_r or in_lon_c or in_lon_r

if show_auto and in_sess and et_h != 17 and not is_named_win
    int t = array.get(ad_total, et_h)
    if t >= auto_min_obs
        ad_prob := float(array.get(ad_revs, et_h)) / float(t) * 100.0

bool is_auto_s = show_auto and not is_named_win and not na(ad_prob) and ad_prob >= s_tier_pct

bgcolor(show_bg and is_auto_s ? color.new(C_S, 85) : na, title="Auto S-Tier Slot BG")

// Auto-discovery label (last bar)
var label ad_lbl = na

if barstate.islast and show_auto and show_lbl
    if not na(ad_lbl)
        label.delete(ad_lbl)

    string txt = "AUTO S-TIER SLOTS\n"
    string sep = "━━━━━━━━━━━━━━━━━━━━\n"
    txt := txt + sep
    bool any = false

    for h = 0 to 23
        if h == 17
            continue
        int t = array.get(ad_total, h)
        if t >= auto_min_obs
            float p = float(array.get(ad_revs, h)) / float(t) * 100.0
            if p >= s_tier_pct
                int h1 = (h + 1) % 24
                string hs  = h  < 10 ? "0" + str.tostring(h)  : str.tostring(h)
                string h1s = h1 < 10 ? "0" + str.tostring(h1) : str.tostring(h1)
                txt  := txt + "★ " + hs + ":00–" + h1s + ":30 ET  " + str.tostring(math.round(p)) + "% (" + str.tostring(t) + "d)\n"
                any  := true

    if not any
        txt := txt + "(need " + str.tostring(auto_min_obs) + "+ obs per slot)"

    ad_lbl := label.new(bar_index, ta.lowest(low, 60), txt,
                          style=label.style_label_upper_right,
                          color=C_DARK, textcolor=C_WHITE, size=size.small)

// ─── DASHBOARD TABLE ─────────────────────────────────────────────────────────
// Columns: Session | Window | Recent%(CI) | Tier | 10d% | Conf | Days
var table dash = na

if barstate.islast and show_table
    if not na(dash)
        table.delete(dash)

    dash := table.new(position.top_right, 7, 5,
                       border_color=color.new(color.gray, 30), border_width=1,
                       bgcolor=C_DARK, frame_color=color.new(color.gray, 20), frame_width=1)

    color HH = color.new(color.gray, 50)
    table.cell(dash, 0, 0, "Session",    bgcolor=HH, text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 1, 0, "Window ET",  bgcolor=HH, text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 2, 0, "Recent" + str.tostring(recent_n) + "d (CI)", bgcolor=HH, text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 3, 0, "Tier",       bgcolor=HH, text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 4, 0, "10d%",       bgcolor=HH, text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 5, 0, "Conf",       bgcolor=HH, text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 6, 0, "Days",       bgcolor=HH, text_color=C_WHITE, text_size=size.small)

    // NYT row
    color tnyt = tier_bdr(tier_nyt)
    color cnyt = conf_clr(conf_nyt)
    table.cell(dash, 0, 1, "NYT",        text_color=color.new(#4FC3F7,0), text_size=size.small)
    table.cell(dash, 1, 1, "06–07:30",   text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 2, 1, prob_str(rp_nyt) + "\n" + ci_str(w_nyt_lo, w_nyt_hi), bgcolor=tnyt, text_color=color.black, text_size=size.small)
    table.cell(dash, 3, 1, tier_nyt,     bgcolor=tnyt, text_color=color.black, text_size=size.small)
    table.cell(dash, 4, 1, prob_str(hp_nyt), text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 5, 1, conf_nyt,     bgcolor=cnyt, text_color=color.black, text_size=size.small)
    table.cell(dash, 6, 1, str.tostring(nyt.total) + " obs", text_color=C_WHITE, text_size=size.small)

    // Tokyo row
    color ttok = tier_bdr(tier_tok)
    color ctok = conf_clr(conf_tok)
    table.cell(dash, 0, 2, "Tokyo",      text_color=color.new(#A5D6A7,0), text_size=size.small)
    table.cell(dash, 1, 2, "20–21:30",   text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 2, 2, prob_str(rp_tok) + "\n" + ci_str(w_tok_lo, w_tok_hi), bgcolor=ttok, text_color=color.black, text_size=size.small)
    table.cell(dash, 3, 2, tier_tok,     bgcolor=ttok, text_color=color.black, text_size=size.small)
    table.cell(dash, 4, 2, prob_str(hp_tok), text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 5, 2, conf_tok,     bgcolor=ctok, text_color=color.black, text_size=size.small)
    table.cell(dash, 6, 2, str.tostring(tok.total) + " obs", text_color=C_WHITE, text_size=size.small)

    // London row
    color tlon = tier_bdr(tier_lon)
    color clon = conf_clr(conf_lon)
    table.cell(dash, 0, 3, "London",     text_color=color.new(#CE93D8,0), text_size=size.small)
    table.cell(dash, 1, 3, "03–04:30",   text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 2, 3, prob_str(rp_lon) + "\n" + ci_str(w_lon_lo, w_lon_hi), bgcolor=tlon, text_color=color.black, text_size=size.small)
    table.cell(dash, 3, 3, tier_lon,     bgcolor=tlon, text_color=color.black, text_size=size.small)
    table.cell(dash, 4, 3, prob_str(hp_lon), text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 5, 3, conf_lon,     bgcolor=clon, text_color=color.black, text_size=size.small)
    table.cell(dash, 6, 3, str.tostring(lon.total) + " obs", text_color=C_WHITE, text_size=size.small)

    // Legend
    table.cell(dash, 0, 4, "S≥" + str.tostring(int(s_tier_pct)) + "% A≥" + str.tostring(int(a_tier_pct)) + "%", text_color=C_S_BDR, text_size=size.tiny)
    table.cell(dash, 1, 4, "6PM–5PM MGC day", text_color=color.new(color.gray,20), text_size=size.tiny)
    table.cell(dash, 2, 4, "CI=Wilson 95%", text_color=color.new(color.gray,20), text_size=size.tiny)
    table.cell(dash, 3, 4, "10d window", text_color=color.new(color.gray,20), text_size=size.tiny)
    table.cell(dash, 4, 4, "hist 10d", text_color=color.new(color.gray,30), text_size=size.tiny)
    table.cell(dash, 5, 4, "t+binom", text_color=color.new(color.gray,20), text_size=size.tiny)
    table.cell(dash, 6, 4, "stat buf=10", text_color=color.new(color.gray,30), text_size=size.tiny)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(nyt_r_ext and tier_nyt == "S",
               title  ="MGC ★ NYT S-Tier Reversal Zone",
               message="MGC: NYT reversal window completed — S-Tier zone (≥60% historical freq).")

alertcondition(tok_r_ext and tier_tok == "S",
               title  ="MGC ★ Tokyo S-Tier Reversal Zone",
               message="MGC: Tokyo reversal window completed — S-Tier zone.")

alertcondition(lon_r_ext and tier_lon == "S",
               title  ="MGC ★ London S-Tier Reversal Zone",
               message="MGC: London reversal window completed — S-Tier zone.")

alertcondition(nyt_r_ext or tok_r_ext or lon_r_ext,
               title  ="MGC Session Reversal Window Closed",
               message="MGC: A named session reversal window just closed. Check probability labels.")

alertcondition(is_auto_s,
               title  ="MGC Auto S-Tier Hour Slot Active",
               message="MGC: Current hour slot is an auto-discovered S-Tier reversal zone.")
````
