# Liquidity Sweep Probability

- url: https://www.tradingview.com/script/GDM2Oedf-Liquidity-Sweep-Probability/
- type: indicator
- pine_id: PUB;85ca629789384f8ba7930d9b3951820d
- version: 1.0

## Description

[b]Stop-hunt detection with dynamic zone rendering and statistical edge validation[/b][i][/i]

Identifies liquidity sweeps — moments when price briefly wicks beyond a significant high or low, clears resting stop orders, then reverses sharply back inside. Tracks whether each sweep type has historically produced a follow-through move and highlights the 3 most contextually relevant zones based on what is currently visible on your chart.

[i]Sweep detection[/i]

A sweep is confirmed when:

Price wicks beyond the highest high or lowest low of the previous N bars by at least min_pts
The bar closes back inside that level

The wick represents stop orders being triggered (the liquidity grab). The close back inside confirms the reversal has begun.

[i]Dynamic zone rendering[/i]

Rather than cluttering the chart with every historical sweep, the indicator identifies the 3 most recent sweep events within your current visible chart window and renders only those as blue horizontal zones. As you scroll or zoom, the zones update automatically to reflect the 3 most recent events in view. The zone spans the swept price range (wick extreme to close) and extends forward by a configurable number of bars.

[i]Post-sweep confluence[/i]

After a sweep, two additional patterns are tracked:

Fair Value Gap (FVG) — a 3-candle price imbalance forming in the reversal direction while the scoring window is active. Represents unfilled price inefficiency that may act as support or resistance. Shown as dashed purple zones, also limited to 3 most recent in view.
Gap B — a traditional price gap where the bar opens completely beyond the previous bar's extreme. Rarer on MGC due to near-24-hour trading, but meaningful when it occurs around the 6 PM session open.

[i]Statistical confidence[/i]

The same probability engine used across the suite: uncapped wins/total observation counts feed the binomial z-score and t-test. Zones are only rendered when the binomial z-score exceeds the significance threshold (default 1.282, p < 0.10). The dashboard shows both the all-history probability and the recent-3 probability, with dual display triggered automatically when they diverge by 10 percentage points or more.
Inputs

Level lookback (bars defining the significant high/low)
Minimum sweep size in points
Reversal window (minutes) and threshold (points)
Significance threshold for zone display
Zone width and transparency
FVG and Gap B toggles

## Source Code

````pine
//@version=6
indicator("Liquidity Sweep Probability", shorttitle="L Sweeps (w/ add ons)", overlay=true,
          max_lines_count=20, max_boxes_count=20, max_labels_count=20)

// ══════════════════════════════════════════════════════════════════════════════
//  MGC LIQUIDITY SWEEP PROBABILITY  |  Pine Script v6
//
//  Dynamic view — on each render, finds the 3 most recent events whose
//  detection bar falls within the user's currently visible chart range.
//
//  Blue zones  — 3 most recent SWEEP events in view (bull or bear, same color)
//  Purple zones — 3 most recent FVG or Gap B events in view (combined pool)
//
//  Sweep  — wick beyond recent N-bar high/low, bar closes back inside
//  FVG    — 3-candle imbalance gap forming while sweep window is active
//  Gap B  — bar opens beyond previous bar's extreme (traditional price gap)
// ══════════════════════════════════════════════════════════════════════════════

// ─── INPUTS ──────────────────────────────────────────────────────────────────
g1 = "① Sweep Detection"
lookback    = input.int(20,    "Level lookback (bars)",             minval=3, maxval=500, group=g1)
min_pts     = input.float(1.0, "Min sweep size (pts beyond level)", minval=0.1, step=0.1, group=g1)
rev_win     = input.int(30,    "Reversal window (min)",             minval=5, maxval=240,  group=g1)
rev_pts     = input.float(3.0, "Reversal threshold pts (Cond A)",   minval=0.5, step=0.5, group=g1)

g2 = "② Zone Display"
band_width  = input.int(100,   "Zone right extent (bars)",          minval=20, maxval=500,  group=g2)
band_alpha  = input.int(75,    "Zone fill transparency",            minval=10, maxval=95,   group=g2)
show_fvg    = input.bool(false, "Show FVG zones (purple)",           group=g2)
show_gapb   = input.bool(true, "Show Gap B zones (purple)",         group=g2)
// Sweep markers: always exactly 3, managed dynamically in barstate.islast
show_table  = input.bool(true, "Dashboard table",                   group=g2)

g3 = "③ Probability"
sig_thresh  = input.float(1.282, "Min binom z to show zones",       minval=0.5, maxval=2.5, step=0.1, group=g3)
dual_diff   = input.float(10.0,  "Dual window if |all-3d| ≥ (%)",  minval=1.0, maxval=50.0, step=1.0, group=g3)

// ─── COLORS ──────────────────────────────────────────────────────────────────
C_SWEEP  = color.new(#1E90FF, 0)   // blue  — sweep zones
C_EVENT  = color.new(#9B59B6, 0)   // purple — FVG / Gap B zones
C_HIGH   = color.new(#2ECC71, 30)
C_MED    = color.new(#F39C12, 40)
C_DIM    = color.new(color.gray, 40)
C_WHITE  = color.white
C_DARK   = color.new(#111111, 20)

// ─── UDT ─────────────────────────────────────────────────────────────────────
type SwpState
    bool          active
    float         sweep_lvl
    float         entry_cl
    float         r_hi
    float         r_lo
    float         r_cl
    int           sweep_ms
    bool          scored
    bool          is_bull
    array<int>    hist
    array<float>  hist_ret
    int           di
    int           ns
    int           total
    int           wins_all
    int           sweep_bar
    float         box_top
    float         box_bot

// ─── STATISTICAL HELPERS ─────────────────────────────────────────────────────
sw_all_p(SwpState s) =>
    s.total == 0 ? float(na) : float(s.wins_all) / float(s.total) * 100.0

sw_recent_p(SwpState s) =>
    int cap   = 10
    int n_use = math.min(s.ns, 3)
    if n_use == 0
        float(na)
    else
        int rev = 0
        for i = 1 to n_use
            int idx = (s.di - i + cap) % cap
            if array.get(s.hist, idx) > 0
                rev += 1
        float(rev) / float(n_use) * 100.0

sw_binom_z(SwpState s) =>
    int n = s.total
    if n < 5
        0.0
    else
        float se = math.sqrt(0.25 / float(n))
        se > 0 ? (float(s.wins_all) / float(n) - 0.5) / se : 0.0

sw_t_stat(SwpState s) =>
    int n = math.min(s.ns, 10)
    if n < 3
        0.0
    else
        float sr = 0.0
        float sq = 0.0
        for i = 0 to n - 1
            float r = array.get(s.hist_ret, i)
            sr += r
            sq += r * r
        float mn   = sr / n
        float vari = (sq - n * mn * mn) / math.max(1, n - 1)
        float sd   = math.sqrt(math.max(0.0, vari))
        sd > 0 ? mn / (sd / math.sqrt(float(n))) : 0.0

sw_conf(SwpState s) =>
    float t  = sw_t_stat(s)
    float bz = sw_binom_z(s)
    if s.total < 5
        "INSUFF"
    else if t >= 1.645 and bz >= 1.645
        "HIGH ★"
    else if t >= 1.645 or bz >= 1.645
        "MED ◆"
    else if t >= 1.282 or bz >= 1.282
        "TREND"
    else
        "LOW"

sw_conf_clr(string c) =>
    c == "HIGH ★" ? C_HIGH : c == "MED ◆" ? C_MED : C_DIM

// ─── INSTANCES ───────────────────────────────────────────────────────────────
var SwpState sw_bull = SwpState.new(false, na, na, na, na, na, 0, false, true,
                                     array.new<int>(10, 0), array.new<float>(10, 0.0),
                                     0, 0, 0, 0, 0, na, na)
var SwpState sw_bear = SwpState.new(false, na, na, na, na, na, 0, false, false,
                                     array.new<int>(10, 0), array.new<float>(10, 0.0),
                                     0, 0, 0, 0, 0, na, na)

// ─── EVENT HISTORY ARRAYS (newest first via unshift, capped at 50) ────────────
// Sweep events
var array<int>   sw_t   = array.new<int>(0)    // bar open time (ms)
var array<int>   sw_bi  = array.new<int>(0)    // bar_index
var array<float> sw_top = array.new<float>(0)
var array<float> sw_bot = array.new<float>(0)
var array<bool>  sw_dir = array.new<bool>(0)   // true = bull sweep

// FVG + Gap B events (combined pool)
var array<int>   ev_t   = array.new<int>(0)
var array<int>   ev_bi  = array.new<int>(0)
var array<float> ev_top = array.new<float>(0)
var array<float> ev_bot = array.new<float>(0)

push_event(array<int> ta, array<int> ba, array<float> tpa, array<float> bta, int t, int bi, float tp, float bt) =>
    array.unshift(ta,  t)
    array.unshift(ba,  bi)
    array.unshift(tpa, tp)
    array.unshift(bta, bt)
    if array.size(ta) > 50
        array.pop(ta)
        array.pop(ba)
        array.pop(tpa)
        array.pop(bta)

// ─── SWEEP DETECTION ─────────────────────────────────────────────────────────
float rec_high = ta.highest(high, lookback)[1]
float rec_low  = ta.lowest(low,   lookback)[1]

bool new_bull = not na(rec_low)  and low  < rec_low  - min_pts and close > rec_low
bool new_bear = not na(rec_high) and high > rec_high + min_pts and close < rec_high

// Record sweep events (box spans from wick extreme to close)
if new_bull
    push_event(sw_t, sw_bi, sw_top, sw_bot, time, bar_index, close, low)
    array.unshift(sw_dir, true)
    if array.size(sw_dir) > 50
        array.pop(sw_dir)
if new_bear
    push_event(sw_t, sw_bi, sw_top, sw_bot, time, bar_index, high, close)
    array.unshift(sw_dir, false)
    if array.size(sw_dir) > 50
        array.pop(sw_dir)

// ─── FVG DETECTION ───────────────────────────────────────────────────────────
var bool  bull_fvg_on  = false
var bool  bear_fvg_on  = false
var float bull_fvg_top = na
var float bull_fvg_bot = na
var float bear_fvg_top = na
var float bear_fvg_bot = na

if new_bull
    bull_fvg_on := false
if new_bear
    bear_fvg_on := false

if show_fvg and sw_bull.active and high[2] < low[0] and not bull_fvg_on
    bull_fvg_on  := true
    bull_fvg_top := low[0]
    bull_fvg_bot := high[2]
    push_event(ev_t, ev_bi, ev_top, ev_bot, time, bar_index, low[0], high[2])

if show_fvg and sw_bear.active and low[2] > high[0] and not bear_fvg_on
    bear_fvg_on  := true
    bear_fvg_top := low[2]
    bear_fvg_bot := high[0]
    push_event(ev_t, ev_bi, ev_top, ev_bot, time, bar_index, low[2], high[0])

// ─── GAP B DETECTION ─────────────────────────────────────────────────────────
// Traditional gap: bar opens beyond prior bar's extreme while sweep window active
bool bull_gap_b = show_gapb and sw_bull.active and open > high[1]
bool bear_gap_b = show_gapb and sw_bear.active and open < low[1]

if bull_gap_b
    push_event(ev_t, ev_bi, ev_top, ev_bot, time, bar_index, open, high[1])
if bear_gap_b
    push_event(ev_t, ev_bi, ev_top, ev_bot, time, bar_index, low[1], open)

// ─── STATE MACHINE ────────────────────────────────────────────────────────────
proc_sweep(SwpState s, bool new_sw, bool bull) =>
    if new_sw
        s.active    := true
        s.sweep_lvl := bull ? rec_low : rec_high
        s.entry_cl  := close
        s.r_hi      := high
        s.r_lo      := low
        s.r_cl      := close
        s.sweep_ms  := time
        s.scored    := false
        s.is_bull   := bull
        s.sweep_bar := bar_index
        s.box_top   := bull ? close : high
        s.box_bot   := bull ? low   : close

    if s.active and not s.scored
        float elapsed = (time - s.sweep_ms) / 60000.0
        s.r_hi := math.max(s.r_hi, high)
        s.r_lo := math.min(s.r_lo, low)
        s.r_cl := close

        if elapsed >= rev_win
            float net   = s.r_cl - s.entry_cl
            bool cond_a = bull ? net >= rev_pts : net <= -rev_pts
            bool cond_b = bull ? s.r_lo > s.sweep_lvl : s.r_hi < s.sweep_lvl
            int  str    = (cond_a ? 1 : 0) + (cond_b ? 1 : 0)
            float ret   = bull ? (s.r_cl - s.entry_cl) : (s.entry_cl - s.r_cl)
            array.set(s.hist,     s.di, str)
            array.set(s.hist_ret, s.di, ret)
            s.di       := (s.di + 1) % 10
            s.ns       := math.min(s.ns + 1, 10)
            s.total    := s.total + 1
            s.wins_all := s.wins_all + (str > 0 ? 1 : 0)
            s.active   := false
            s.scored   := true

proc_sweep(sw_bull, new_bull, true)
proc_sweep(sw_bear, new_bear, false)

// ─── PROBABILITIES ────────────────────────────────────────────────────────────
float bp_all = sw_all_p(sw_bull)
float bp_rec = sw_recent_p(sw_bull)
float sp_all = sw_all_p(sw_bear)
float sp_rec = sw_recent_p(sw_bear)
bool  bull_sig = sw_binom_z(sw_bull) >= sig_thresh
bool  bear_sig = sw_binom_z(sw_bear) >= sig_thresh
bool  dual_bull = not na(bp_all) and not na(bp_rec) and math.abs(bp_all - bp_rec) >= dual_diff
bool  dual_bear = not na(sp_all) and not na(sp_rec) and math.abs(sp_all - sp_rec) >= dual_diff

// ─── DYNAMIC ZONE RENDERING ───────────────────────────────────────────────────
// On each render, scan the event history for the 3 most recent events whose
// detection bar time falls within the user's visible chart range.
// Previous boxes are deleted and redrawn fresh each time.

var array<box>   sw_bxs = array.new<box>(3, na)   // 3 sweep zone boxes (blue)
var array<box>   ev_bxs = array.new<box>(3, na)   // 3 FVG/GapB zone boxes (purple)
var array<label> sw_lbs = array.new<label>(3, na) // labels for sweep zones

if barstate.islast and not na(chart.left_visible_bar_time)
    int lft = chart.left_visible_bar_time
    int rgt = chart.right_visible_bar_time

    // ── Sweep zones (blue) ──
    for i = 0 to 2
        box bx = array.get(sw_bxs, i)
        if not na(bx)
            box.delete(bx)
            array.set(sw_bxs, i, na)
        label lb = array.get(sw_lbs, i)
        if not na(lb)
            label.delete(lb)
            array.set(sw_lbs, i, na)

    int sw_drawn = 0
    int sw_sz    = array.size(sw_t)
    for i = 0 to sw_sz - 1
        if sw_drawn >= 3
            break
        int evt = array.get(sw_t, i)
        if evt >= lft and evt <= rgt
            int   bi  = array.get(sw_bi,  i)
            float tp  = array.get(sw_top, i)
            float bt  = array.get(sw_bot, i)
            box bx = box.new(bi, tp, bi + band_width, bt,
                              border_color=color.new(C_SWEEP, 20),
                              bgcolor     =color.new(C_SWEEP, band_alpha),
                              border_width=1)
            array.set(sw_bxs, sw_drawn, bx)
            bool is_b = array.get(sw_dir, i)
            label lb = label.new(bi, is_b ? bt : tp,
                                  is_b ? "▲" : "▼",
                                  style   = is_b ? label.style_label_up : label.style_label_down,
                                  color   = color.new(C_SWEEP, 20),
                                  textcolor = C_WHITE,
                                  size    = size.small)
            array.set(sw_lbs, sw_drawn, lb)
            sw_drawn += 1

    // ── FVG / Gap B zones (purple) ──
    for i = 0 to 2
        box bx = array.get(ev_bxs, i)
        if not na(bx)
            box.delete(bx)
            array.set(ev_bxs, i, na)

    int ev_drawn = 0
    int ev_sz    = array.size(ev_t)
    for i = 0 to ev_sz - 1
        if ev_drawn >= 3
            break
        int evt = array.get(ev_t, i)
        if evt >= lft and evt <= rgt
            int   bi  = array.get(ev_bi,  i)
            float tp  = array.get(ev_top, i)
            float bt  = array.get(ev_bot, i)
            box bx = box.new(bi, tp, bi + band_width, bt,
                              border_color=color.new(C_EVENT, 30),
                              bgcolor     =color.new(C_EVENT, 88),
                              border_width=1,
                              border_style=line.style_dashed)
            array.set(ev_bxs, ev_drawn, bx)
            ev_drawn += 1

// ─── MARKERS ──────────────────────────────────────────────────────────────────
// Sweep markers rendered dynamically — see barstate.islast block above (3 only)
plotshape(bull_gap_b, title="Bull Gap B",
          style=shape.circle, location=location.belowbar,
          color=color.new(C_EVENT, 30), size=size.tiny)
plotshape(bear_gap_b, title="Bear Gap B",
          style=shape.circle, location=location.abovebar,
          color=color.new(C_EVENT, 30), size=size.tiny)

// ─── DASHBOARD TABLE ──────────────────────────────────────────────────────────
var table dash = na

if barstate.islast and show_table
    if not na(dash)
        table.delete(dash)

    dash := table.new(position.bottom_left, 4, 4,
                       border_color=color.new(color.gray, 30), border_width=1,
                       bgcolor=C_DARK, frame_color=color.new(color.gray, 20), frame_width=1)

    color HH = color.new(color.gray, 50)
    table.cell(dash, 0, 0, "Sweep",     bgcolor=HH, text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 1, 0, "All %",     bgcolor=HH, text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 2, 0, "3d %",      bgcolor=HH, text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 3, 0, "Conf / Obs",bgcolor=HH, text_color=C_WHITE, text_size=size.small)

    string bc  = sw_conf(sw_bull)
    color  bcc = sw_conf_clr(bc)
    color  bac = not na(bp_all) and bp_all >= 60.0 ? color.new(C_SWEEP, 50) : color.new(color.gray, 60)
    table.cell(dash, 0, 1, "BULL", text_color=color.new(#00d4aa, 0), text_size=size.small)
    table.cell(dash, 1, 1, na(bp_all) ? "–" : str.tostring(math.round(bp_all)) + "%", bgcolor=bac, text_color=color.black, text_size=size.small)
    table.cell(dash, 2, 1, na(bp_rec) ? "–" : str.tostring(math.round(bp_rec)) + "%", text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 3, 1, bc + "  " + str.tostring(sw_bull.total), bgcolor=bcc, text_color=color.black, text_size=size.small)

    string sc  = sw_conf(sw_bear)
    color  scc = sw_conf_clr(sc)
    color  sac = not na(sp_all) and sp_all >= 60.0 ? color.new(#ff4757, 50) : color.new(color.gray, 60)
    table.cell(dash, 0, 2, "BEAR", text_color=color.new(#ff4757, 0), text_size=size.small)
    table.cell(dash, 1, 2, na(sp_all) ? "–" : str.tostring(math.round(sp_all)) + "%", bgcolor=sac, text_color=color.black, text_size=size.small)
    table.cell(dash, 2, 2, na(sp_rec) ? "–" : str.tostring(math.round(sp_rec)) + "%", text_color=C_WHITE, text_size=size.small)
    table.cell(dash, 3, 2, sc + "  " + str.tostring(sw_bear.total), bgcolor=scc, text_color=color.black, text_size=size.small)

    string fvg_s = (bull_fvg_on ? "FVG▲ " : "") + (bear_fvg_on ? "FVG▼" : "")
    table.cell(dash, 0, 3, "lkbk=" + str.tostring(lookback),         text_color=color.new(color.gray, 30), text_size=size.tiny)
    table.cell(dash, 1, 3, fvg_s == "" ? "–" : fvg_s,               text_color=color.new(C_EVENT, 0),     text_size=size.tiny)
    table.cell(dash, 2, 3, "z≥" + str.tostring(sig_thresh, "#.###"), text_color=color.new(color.gray, 30), text_size=size.tiny)
    table.cell(dash, 3, 3, "3 zones in view",                        text_color=color.new(color.gray, 40), text_size=size.tiny)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(new_bull and bull_sig, title="MGC Bull Liquidity Sweep",
               message="MGC: Bull sweep — statistically significant reversal probability.")
alertcondition(new_bear and bear_sig, title="MGC Bear Liquidity Sweep",
               message="MGC: Bear sweep — statistically significant reversal probability.")
alertcondition((bull_fvg_on and not bull_fvg_on[1]) or (bear_fvg_on and not bear_fvg_on[1]),
               title="MGC Post-Sweep FVG Formed",
               message="MGC: Inversion FVG formed after liquidity sweep.")
````
