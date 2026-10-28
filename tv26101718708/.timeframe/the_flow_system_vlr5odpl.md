# The Flow System

- url: https://www.tradingview.com/script/vlr5odPl-The-Flow-System/
- type: indicator
- pine_id: PUB;601548e8e78a40b3867e2e2e5bd6fb9e
- version: 1.0

## Description

Entire Trading Schematic, Covers ICC, ICT, and Smart Money concepts, Has volume ranges, and active High Impact news Crediton

## Source Code

````pine

//@version=6
indicator("The Flow System", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=1500)

// ════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════════════════════════════════════════

g1 = "ICC Structure"
icc_tf    = input.timeframe("240", "ICC Timeframe",                    group=g1)
icc_bars  = input.int(1,   "ICC Candle — Bars Back",                   group=g1, minval=1, maxval=50)
eq_tol    = input.float(15.0, "Consolidation Tolerance (pts)",         group=g1)
show_zone = input.bool(true,  "Show 4H Active Zone",                   group=g1)
show_pd   = input.bool(true,  "Show Previous Day H/L",                 group=g1)

g3 = "Signal Filters"
conf_tol    = input.float(8.0,  "ICC Level Touch Tolerance (pts)",     group=g3)
min_body    = input.float(0.55, "Min Candle Body %",                   group=g3, minval=0.1, maxval=1.0, step=0.05)
swing_lb    = input.int(8,      "HTF Swing Lookback (bars)",           group=g3, tooltip="1H and 4H bars back to define swing H/L for structure break confirmation")
stop_dist   = input.float(10.0, "BOS Invalidation Distance (pts)",     group=g3, minval=0.5, step=0.5)
replay_mode = input.bool(false, "Replay Mode  (show all signals on visible bars)", group=g3, tooltip="Enable when using TradingView Replay so labels and signals are visible on historical bars")

g4 = "BOS + Retest Entries"
show_bos  = input.bool(true, "Show BOS Retest Signals",                group=g4)
bos_lb    = input.int(10,    "Local Swing Lookback (bars)",            group=g4, minval=3, maxval=50)
show_fvg  = input.bool(true, "Draw Active FVG Zones",                  group=g4)
col_bb    = input.color(color.new(color.aqua,   0), "BOS Buy Color",  group=g4)
col_bs    = input.color(color.new(color.orange, 0), "BOS Sell Color", group=g4)

g4b = "Structure Labels (BOS)"
show_bos_lbl  = input.bool(true, "Show BOS Labels on Break",           group=g4b)
show_bos_line = input.bool(true, "Show BOS Level Lines",               group=g4b)
col_bos_bull  = input.color(color.new(color.lime, 0), "BOS Bull",      group=g4b)
col_bos_bear  = input.color(color.new(color.red,  0), "BOS Bear",      group=g4b)

g4c = "AMD Model  (Accum → Manip → Distrib)"
show_amd      = input.bool(true,  "Show AMD Model",                    group=g4c)
amd_sweep_tol = input.float(3.0,  "Sweep Tolerance (pts)",             group=g4c, minval=0.5, step=0.5)
col_amd       = input.color(color.new(color.purple, 70), "AMD Zone",   group=g4c)

g_po3 = "PO3 — Power of Three"
show_po3       = input.bool(true,  "Show PO3",                          group=g_po3)
po3_accum_bars = input.int(3,      "Accumulation Bars (from day open)", group=g_po3, minval=1, maxval=24, tooltip="Number of bars after day open to define the accumulation range")
col_po3        = input.color(color.new(color.orange, 0), "PO3 Color",  group=g_po3)

g_orb = "ORB — Opening Range Breakout  (CST, format HHMM-HHMM)"
show_orb         = input.bool(true,   "Show ORB Levels & Signals",              group=g_orb)
ny_orb_session   = input.string("0830-0845", "NY Open ORB Window",              group=g_orb, tooltip="Default: 0830-0845 CST (first 15 min of NY)")
asia_orb_session = input.string("1700-1715", "Asia Open ORB Window",            group=g_orb, tooltip="Default: 1700-1715 CST (first 15 min of Asia)")
col_orb_bull     = input.color(color.new(color.green, 0),  "ORB Buy Color",     group=g_orb)
col_orb_bear     = input.color(color.new(color.red,   0),  "ORB Sell Color",    group=g_orb)
col_orb_zone     = input.color(color.new(color.silver,70), "ORB Range Color",   group=g_orb)

g_ifvg        = "IFVG — Inverse Fair Value Gaps"
show_ifvg     = input.bool(true, "Show IFVGs",           group=g_ifvg)
ifvg_max_n    = input.int(5,     "Max IFVGs to Track",   group=g_ifvg, minval=1, maxval=15)
col_ifvg_bull = input.color(color.new(color.lime, 80),  "Bullish IFVG Color", group=g_ifvg)
col_ifvg_bear = input.color(color.new(color.red,  80),  "Bearish IFVG Color", group=g_ifvg)

g_swing        = "1H Swing Structure (HH / HL / LH / LL)"
show_swing     = input.bool(true, "Show 1H Swing Labels",  group=g_swing)
swing_pivot_lb = input.int(3,     "Pivot Lookback (1H bars)", group=g_swing, minval=1, maxval=10, tooltip="Bars left and right of a candle required to confirm a 1H swing high/low")
col_hh_hl      = input.color(color.new(color.lime,  0), "HH / HL Color", group=g_swing)
col_lh_ll      = input.color(color.new(color.red,   0), "LH / LL Color", group=g_swing)

g_vp       = "Volume Profile"
show_vp    = input.bool(true,  "Show Session Volume Profile",     group=g_vp)
vp_rows    = input.int(24,     "Profile Rows",                    group=g_vp, minval=10, maxval=40)
vp_width   = input.int(20,     "Max Width (bars)",                group=g_vp, minval=5,  maxval=60)
vp_va_pct  = input.float(70.0, "Value Area %",                    group=g_vp, minval=50.0, maxval=95.0, step=5.0)
col_vp_poc = input.color(color.new(#FFD700, 0),     "POC Color",        group=g_vp)
col_vp_va  = input.color(color.new(color.teal, 55), "Value Area Color", group=g_vp)
col_vp_out = input.color(color.new(color.gray, 78), "Outside VA Color", group=g_vp)

g5 = "Sessions  (CST / Chicago)"
en_ny     = input.bool(true, "NY Open    08:30 - 12:00",               group=g5)
en_lunch  = input.bool(true, "NY Lunch   12:00 - 13:30",               group=g5)
en_london = input.bool(true, "London     02:00 - 08:00",               group=g5)
en_asia   = input.bool(true, "Asia       17:00 - 02:00",               group=g5)

g6 = "Colors"
col_h    = input.color(color.new(color.lime,   0),  "ICC High",        group=g6)
col_l    = input.color(color.new(color.red,    0),  "ICC Low",         group=g6)
col_mid  = input.color(color.new(color.yellow, 0),  "ICC 50%",         group=g6)
col_zon  = input.color(color.new(color.blue,  80),  "4H Active Zone",  group=g6)
col_pd   = input.color(color.new(color.gray,  30),  "PDH / PDL",       group=g6)

// ════════════════════════════════════════════════════════════════════════════
//  TIMEFRAME GATES
// ════════════════════════════════════════════════════════════════════════════

is_entry_tf = timeframe.period == "5"  or timeframe.period == "15"
is_swing_tf = timeframe.period == "60" or timeframe.period == "240"
is_15m      = timeframe.period == "15"
is_5m       = timeframe.period == "5"

is_recent   = replay_mode or time >= timenow - 5 * 24 * 60 * 60 * 1000

max_bars_back(high,   600)
max_bars_back(low,    600)
max_bars_back(close,  600)
max_bars_back(volume, 600)

// ════════════════════════════════════════════════════════════════════════════
//  HTF DATA
// ════════════════════════════════════════════════════════════════════════════

icc_h   = request.security(syminfo.tickerid, icc_tf, high[icc_bars], lookahead=barmerge.lookahead_off)
icc_l   = request.security(syminfo.tickerid, icc_tf, low[icc_bars],  lookahead=barmerge.lookahead_off)
icc_mid = (icc_h + icc_l) / 2.0
icc_rng = icc_h - icc_l

cur_h   = request.security(syminfo.tickerid, icc_tf, high[0], lookahead=barmerge.lookahead_off)
cur_l   = request.security(syminfo.tickerid, icc_tf, low[0],  lookahead=barmerge.lookahead_off)
pd_h    = request.security(syminfo.tickerid, "D",   high[1],  lookahead=barmerge.lookahead_off)
pd_l    = request.security(syminfo.tickerid, "D",   low[1],   lookahead=barmerge.lookahead_off)

h4_h1   = request.security(syminfo.tickerid, "240", high[1],  lookahead=barmerge.lookahead_off)
h4_h2   = request.security(syminfo.tickerid, "240", high[2],  lookahead=barmerge.lookahead_off)
h4_h3   = request.security(syminfo.tickerid, "240", high[3],  lookahead=barmerge.lookahead_off)
h4_l1   = request.security(syminfo.tickerid, "240", low[1],   lookahead=barmerge.lookahead_off)
h4_l2   = request.security(syminfo.tickerid, "240", low[2],   lookahead=barmerge.lookahead_off)
h4_l3   = request.security(syminfo.tickerid, "240", low[3],   lookahead=barmerge.lookahead_off)

d_c1    = request.security(syminfo.tickerid, "D",   close[1], lookahead=barmerge.lookahead_off)
d_c2    = request.security(syminfo.tickerid, "D",   close[2], lookahead=barmerge.lookahead_off)
h4_c1   = request.security(syminfo.tickerid, "240", close[1], lookahead=barmerge.lookahead_off)
h4_c2   = request.security(syminfo.tickerid, "240", close[2], lookahead=barmerge.lookahead_off)
h1_c1   = request.security(syminfo.tickerid, "60",  close[1], lookahead=barmerge.lookahead_off)
h1_c2   = request.security(syminfo.tickerid, "60",  close[2], lookahead=barmerge.lookahead_off)

h1_sh   = request.security(syminfo.tickerid, "60",  ta.highest(high, swing_lb)[2], lookahead=barmerge.lookahead_off)
h1_sl   = request.security(syminfo.tickerid, "60",  ta.lowest(low,   swing_lb)[2], lookahead=barmerge.lookahead_off)
h4_sh   = request.security(syminfo.tickerid, "240", ta.highest(high, swing_lb)[2], lookahead=barmerge.lookahead_off)
h4_sl   = request.security(syminfo.tickerid, "240", ta.lowest(low,   swing_lb)[2], lookahead=barmerge.lookahead_off)

// ════════════════════════════════════════════════════════════════════════════
//  HTF FILTERS
// ════════════════════════════════════════════════════════════════════════════

ranging     = (math.abs(h4_h1-h4_h2)<eq_tol and math.abs(h4_h2-h4_h3)<eq_tol) or
              (math.abs(h4_l1-h4_l2)<eq_tol and math.abs(h4_l2-h4_l3)<eq_tol)

bull_trend  = d_c1 > d_c2 and h4_c1 > h4_c2 and h1_c1 > h1_c2
bear_trend  = d_c1 < d_c2 and h4_c1 < h4_c2 and h1_c1 < h1_c2

bull_struct = h1_c1 > h1_sh and h4_c1 > h4_sh
bear_struct = h1_c1 < h1_sl and h4_c1 < h4_sl

tz          = "America/Chicago"
in_ny       = en_ny     and not na(time(timeframe.period, "0830-1200", tz))
in_lunch    = en_lunch  and not na(time(timeframe.period, "1200-1330", tz))
in_lon      = en_london and not na(time(timeframe.period, "0200-0800", tz))
in_asia     = en_asia   and not na(time(timeframe.period, "1700-0200", tz))
in_sess     = in_ny or in_lunch or in_lon or in_asia

in_asia_raw = not na(time(timeframe.period, "1700-0200", tz))
in_lon_raw  = not na(time(timeframe.period, "0200-0800", tz))
in_ny_raw   = not na(time(timeframe.period, "0830-1200", tz))

body        = math.abs(close - open)
hl_rng      = math.max(high - low, syminfo.mintick)
strong      = (body / hl_rng) >= min_body
sess_tag    = in_ny ? "NY" : in_lon ? "LON" : in_asia ? "ASIA" : in_lunch ? "LUNCH" : ""

// ════════════════════════════════════════════════════════════════════════════
//  1H SWING STRUCTURE  (HH / HL / LH / LL)  — visible on 1H and 4H only
// ════════════════════════════════════════════════════════════════════════════

h1_pivot_hi = request.security(syminfo.tickerid, "60",
     ta.pivothigh(high, swing_pivot_lb, swing_pivot_lb),
     lookahead = barmerge.lookahead_off)

h1_pivot_lo = request.security(syminfo.tickerid, "60",
     ta.pivotlow(low, swing_pivot_lb, swing_pivot_lb),
     lookahead = barmerge.lookahead_off)

var float sw_last_ph = na
var float sw_last_pl = na

sw_new_ph = show_swing and is_swing_tf and not na(h1_pivot_hi) and (na(sw_last_ph) or h1_pivot_hi != sw_last_ph)
sw_new_pl = show_swing and is_swing_tf and not na(h1_pivot_lo) and (na(sw_last_pl) or h1_pivot_lo != sw_last_pl)

if sw_new_ph
    is_hh = na(sw_last_ph) or h1_pivot_hi > sw_last_ph
    sw_last_ph := h1_pivot_hi
    if is_recent
        label.new(bar_index - 1, h1_pivot_hi,
                  is_hh ? "HH" : "LH",
                  color     = is_hh ? color.new(col_hh_hl, 10) : color.new(col_lh_ll, 10),
                  textcolor = color.white,
                  style     = label.style_label_down,
                  size      = size.small,
                  tooltip   = is_hh ? "Higher High — bullish structure" : "Lower High — bearish structure")

if sw_new_pl
    is_hl = na(sw_last_pl) or h1_pivot_lo > sw_last_pl
    sw_last_pl := h1_pivot_lo
    if is_recent
        label.new(bar_index - 1, h1_pivot_lo,
                  is_hl ? "HL" : "LL",
                  color     = is_hl ? color.new(col_hh_hl, 10) : color.new(col_lh_ll, 10),
                  textcolor = color.white,
                  style     = label.style_label_up,
                  size      = size.small,
                  tooltip   = is_hl ? "Higher Low — bullish structure" : "Lower Low — bearish structure")

// ════════════════════════════════════════════════════════════════════════════
//  PO3 — POWER OF THREE
// ════════════════════════════════════════════════════════════════════════════

var float po3_open      = na
var float po3_h         = na
var float po3_l         = na
var int   po3_start_bar = 0
var int   po3_bar_count = 0
var bool  po3_in_accum  = false
var bool  po3_swept_h   = false
var bool  po3_swept_l   = false
var bool  po3_dist_done = false

var float vp_sess_hi    = na
var float vp_sess_lo    = na
var int   vp_sess_start = 0
var box[] vp_boxes      = array.new<box>()
var line  vp_poc_ln     = na
var line  vp_vah_ln     = na
var line  vp_val_ln     = na
var label vp_poc_lb     = na
var label vp_vah_lb     = na
var label vp_val_lb     = na

new_day = ta.change(time("D")) != 0

if new_day
    po3_open      := open
    po3_h         := high
    po3_l         := low
    po3_start_bar := bar_index
    po3_bar_count := 1
    po3_in_accum  := true
    po3_swept_h   := false
    po3_swept_l   := false
    po3_dist_done := false

else if po3_in_accum
    po3_h         := math.max(po3_h, high)
    po3_l         := math.min(po3_l, low)
    po3_bar_count += 1
    if po3_bar_count >= po3_accum_bars
        po3_in_accum := false
        if show_po3 and is_15m
            box.new(po3_start_bar, po3_h, bar_index, po3_l,
                    border_color = color.new(col_po3, 20),
                    bgcolor      = color.new(col_po3, 82),
                    text         = "PO3  A",
                    text_color   = col_po3,
                    text_size    = size.tiny,
                    text_halign  = text.align_left,
                    text_valign  = text.align_top)

// VP session H/L tracking
if new_day
    vp_sess_hi    := high
    vp_sess_lo    := low
    vp_sess_start := bar_index
else if not na(vp_sess_hi)
    vp_sess_hi := math.max(vp_sess_hi, high)
    vp_sess_lo := math.min(vp_sess_lo, low)

po3_manip_up = show_po3 and is_15m and not po3_in_accum and not po3_swept_h and not po3_swept_l and not na(po3_h) and high > po3_h
po3_manip_dn = show_po3 and is_15m and not po3_in_accum and not po3_swept_h and not po3_swept_l and not na(po3_l) and low  < po3_l

if po3_manip_up
    po3_swept_h := true
    if is_recent
        label.new(bar_index, high, "M↑  PO3",
                  color=color.new(col_po3, 10), textcolor=color.white,
                  style=label.style_label_down, size=size.tiny, tooltip="PO3: High swept — expect bearish distribution")

if po3_manip_dn
    po3_swept_l := true
    if is_recent
        label.new(bar_index, low, "M↓  PO3",
                  color=color.new(col_po3, 10), textcolor=color.white,
                  style=label.style_label_up, size=size.tiny, tooltip="PO3: Low swept — expect bullish distribution")

po3_dist_bull = show_po3 and is_15m and po3_swept_l and not po3_dist_done and close > po3_l and close > open and strong
po3_dist_bear = show_po3 and is_15m and po3_swept_h and not po3_dist_done and close < po3_h and close < open and strong

if po3_dist_bull
    po3_dist_done := true
    if is_recent
        label.new(bar_index, low, "D↑  PO3",
                  color=color.new(color.teal, 10), textcolor=color.white,
                  style=label.style_label_up, size=size.small, tooltip="PO3 Distribution — Bullish")

if po3_dist_bear
    po3_dist_done := true
    if is_recent
        label.new(bar_index, high, "D↓  PO3",
                  color=color.new(color.fuchsia, 10), textcolor=color.white,
                  style=label.style_label_down, size=size.small, tooltip="PO3 Distribution — Bearish")

// ════════════════════════════════════════════════════════════════════════════
//  ORB TRACKING
// ════════════════════════════════════════════════════════════════════════════

in_ny_orb   = show_orb and not na(time(timeframe.period, ny_orb_session,   tz))
in_asia_orb = show_orb and not na(time(timeframe.period, asia_orb_session, tz))

var float ny_orb_h        = na
var float ny_orb_l        = na
var int   ny_orb_s_bar    = 0
var bool  ny_orb_done     = false
var bool  ny_orb_buy_done = false
var bool  ny_orb_sel_done = false

ny_orb_opens = in_ny_orb and not in_ny_orb[1]
ny_orb_ends  = not in_ny_orb and in_ny_orb[1]

if ny_orb_opens
    ny_orb_h        := high
    ny_orb_l        := low
    ny_orb_s_bar    := bar_index
    ny_orb_done     := false
    ny_orb_buy_done := false
    ny_orb_sel_done := false

if in_ny_orb
    ny_orb_h := math.max(ny_orb_h, high)
    ny_orb_l := math.min(ny_orb_l, low)

if ny_orb_ends
    ny_orb_done := true
    box.new(ny_orb_s_bar, ny_orb_h, bar_index, ny_orb_l,
            border_color = color.new(col_orb_zone, 20),
            bgcolor      = color.new(col_orb_zone, 75),
            text         = "NY ORB",
            text_color   = color.gray,
            text_size    = size.tiny)

var float asia_orb_h        = na
var float asia_orb_l        = na
var int   asia_orb_s_bar    = 0
var bool  asia_orb_done     = false
var bool  asia_orb_buy_done = false
var bool  asia_orb_sel_done = false

asia_orb_opens = in_asia_orb and not in_asia_orb[1]
asia_orb_ends  = not in_asia_orb and in_asia_orb[1]

if asia_orb_opens
    asia_orb_h        := high
    asia_orb_l        := low
    asia_orb_s_bar    := bar_index
    asia_orb_done     := false
    asia_orb_buy_done := false
    asia_orb_sel_done := false

if in_asia_orb
    asia_orb_h := math.max(asia_orb_h, high)
    asia_orb_l := math.min(asia_orb_l, low)

if asia_orb_ends
    asia_orb_done := true
    box.new(asia_orb_s_bar, asia_orb_h, bar_index, asia_orb_l,
            border_color = color.new(col_orb_zone, 20),
            bgcolor      = color.new(col_orb_zone, 75),
            text         = "ASIA ORB",
            text_color   = color.gray,
            text_size    = size.tiny)

_ny_xup = ta.crossover(close,  ny_orb_h)
_ny_xdn = ta.crossunder(close, ny_orb_l)
_as_xup = ta.crossover(close,  asia_orb_h)
_as_xdn = ta.crossunder(close, asia_orb_l)

ny_orb_bull   = show_orb and ny_orb_done   and not ny_orb_buy_done   and _ny_xup
ny_orb_bear   = show_orb and ny_orb_done   and not ny_orb_sel_done   and _ny_xdn
asia_orb_bull = show_orb and asia_orb_done and not asia_orb_buy_done and _as_xup
asia_orb_bear = show_orb and asia_orb_done and not asia_orb_sel_done and _as_xdn

if ny_orb_bull
    ny_orb_buy_done := true
    if is_recent and is_5m
        label.new(bar_index, low,  "BUY | NY ORB\n" + sess_tag,
                  color=color.new(col_orb_bull, 10), textcolor=color.white,
                  style=label.style_label_up, size=size.small)

if ny_orb_bear
    ny_orb_sel_done := true
    if is_recent and is_5m
        label.new(bar_index, high, "SELL | NY ORB\n" + sess_tag,
                  color=color.new(col_orb_bear, 10), textcolor=color.white,
                  style=label.style_label_down, size=size.small)

if asia_orb_bull
    asia_orb_buy_done := true
    if is_recent and is_5m
        label.new(bar_index, low,  "BUY | ASIA ORB\n" + sess_tag,
                  color=color.new(col_orb_bull, 10), textcolor=color.white,
                  style=label.style_label_up, size=size.small)

if asia_orb_bear
    asia_orb_sel_done := true
    if is_recent and is_5m
        label.new(bar_index, high, "SELL | ASIA ORB\n" + sess_tag,
                  color=color.new(col_orb_bear, 10), textcolor=color.white,
                  style=label.style_label_down, size=size.small)

// ════════════════════════════════════════════════════════════════════════════
//  LOCAL BOS DETECTION
// ════════════════════════════════════════════════════════════════════════════

loc_sh  = ta.highest(high, bos_lb)[1]
loc_sl  = ta.lowest(low,   bos_lb)[1]

bull_bos = ta.crossover(close,  loc_sh)
bear_bos = ta.crossunder(close, loc_sl)

var bool  bull_up  = false
var bool  bear_up  = false
var float bull_lvl = na
var float bear_lvl = na
var int   bull_bi  = 0
var int   bear_bi  = 0

if bull_bos
    bull_up  := true
    bear_up  := false
    bull_lvl := loc_sh
    bull_bi  := bar_index

if bear_bos
    bear_up  := true
    bull_up  := false
    bear_lvl := loc_sl
    bear_bi  := bar_index

if bull_up and not na(bull_lvl) and close < bull_lvl - stop_dist * 2
    bull_up := false

if bear_up and not na(bear_lvl) and close > bear_lvl + stop_dist * 2
    bear_up := false

// ════════════════════════════════════════════════════════════════════════════
//  BOS LABELS & LINES
// ════════════════════════════════════════════════════════════════════════════

bos_bull_brk = bull_trend and bull_bos
bos_bear_brk = bear_trend and bear_bos

if show_bos_lbl and bos_bull_brk and is_recent
    label.new(bar_index, low,  "BOS", color=color.new(col_bos_bull, 15), textcolor=color.white, style=label.style_label_up,   size=size.tiny)
if show_bos_lbl and bos_bear_brk and is_recent
    label.new(bar_index, high, "BOS", color=color.new(col_bos_bear, 15), textcolor=color.white, style=label.style_label_down, size=size.tiny)

if show_bos_line and bos_bull_brk and is_recent
    line.new(bar_index - bos_lb, loc_sh, bar_index, loc_sh, color=col_bos_bull, width=1, style=line.style_dashed)
if show_bos_line and bos_bear_brk and is_recent
    line.new(bar_index - bos_lb, loc_sl, bar_index, loc_sl, color=col_bos_bear, width=1, style=line.style_dashed)

// ════════════════════════════════════════════════════════════════════════════
//  AMD MODEL
// ════════════════════════════════════════════════════════════════════════════

var float asia_h         = na
var float asia_l         = na
var int   asia_bar_start = 0
var bool  amd_swept_bull = false
var bool  amd_swept_bear = false
var bool  amd_active     = false

asia_session_open = in_asia_raw and not in_asia_raw[1]
if asia_session_open
    asia_h         := high
    asia_l         := low
    asia_bar_start := bar_index
    amd_swept_bull := false
    amd_swept_bear := false
    amd_active     := true

if in_asia_raw and amd_active
    asia_h := math.max(asia_h, high)
    asia_l := math.min(asia_l, low)

amd_manip_bull = show_amd and is_15m and amd_active and (in_lon_raw or in_ny_raw) and not amd_swept_bull and not amd_swept_bear and low  < asia_l - amd_sweep_tol
amd_manip_bear = show_amd and is_15m and amd_active and (in_lon_raw or in_ny_raw) and not amd_swept_bull and not amd_swept_bear and high > asia_h + amd_sweep_tol

if amd_manip_bull
    amd_swept_bull := true
    if is_recent
        label.new(bar_index, low,  "M↓", color=color.new(color.red, 10), textcolor=color.white, style=label.style_label_up,   size=size.tiny, tooltip="AMD: Asia Low swept")
if amd_manip_bear
    amd_swept_bear := true
    if is_recent
        label.new(bar_index, high, "M↑", color=color.new(color.red, 10), textcolor=color.white, style=label.style_label_down, size=size.tiny, tooltip="AMD: Asia High swept")

amd_dist_bull = show_amd and is_15m and amd_swept_bull and close > asia_l and close > open and strong
amd_dist_bear = show_amd and is_15m and amd_swept_bear and close < asia_h and close < open and strong

if amd_dist_bull
    amd_active := false
    if is_recent
        label.new(bar_index, low,  "D↑ AMD", color=color.new(color.teal,    10), textcolor=color.white, style=label.style_label_up,   size=size.small, tooltip="AMD Distribution — Bullish")
if amd_dist_bear
    amd_active := false
    if is_recent
        label.new(bar_index, high, "D↓ AMD", color=color.new(color.fuchsia, 10), textcolor=color.white, style=label.style_label_down, size=size.small, tooltip="AMD Distribution — Bearish")

// ════════════════════════════════════════════════════════════════════════════
//  FVG DETECTION  (BOS-aligned active zones)
// ════════════════════════════════════════════════════════════════════════════

b_fvg_new = high[2] < low[0]
s_fvg_new = low[2]  > high[0]

var float b_fvg_hi = na
var float b_fvg_lo = na
var int   b_fvg_bi = 0
var float s_fvg_hi = na
var float s_fvg_lo = na
var int   s_fvg_bi = 0

if bull_up and b_fvg_new and bar_index >= bull_bi
    b_fvg_hi := low[0]
    b_fvg_lo := high[2]
    b_fvg_bi := bar_index
if bear_up and s_fvg_new and bar_index >= bear_bi
    s_fvg_hi := low[2]
    s_fvg_lo := high[0]
    s_fvg_bi := bar_index
if not na(b_fvg_lo) and low < b_fvg_lo
    b_fvg_hi := na
    b_fvg_lo := na
if not na(s_fvg_hi) and high > s_fvg_hi
    s_fvg_hi := na
    s_fvg_lo := na
if not bull_up
    b_fvg_hi := na
    b_fvg_lo := na
if not bear_up
    s_fvg_hi := na
    s_fvg_lo := na

// ════════════════════════════════════════════════════════════════════════════
//  IFVG — INVERSE FAIR VALUE GAPS
// ════════════════════════════════════════════════════════════════════════════

var float[] ifvg_bull_hi  = array.new_float()
var float[] ifvg_bull_lo  = array.new_float()
var int[]   ifvg_bull_bi  = array.new_int()
var box[]   ifvg_bull_box = array.new<box>()

var float[] ifvg_bear_hi  = array.new_float()
var float[] ifvg_bear_lo  = array.new_float()
var int[]   ifvg_bear_bi  = array.new_int()
var box[]   ifvg_bear_box = array.new<box>()

raw_bull_fvg = high[2] < low[0]
raw_bear_fvg = low[2]  > high[0]

if show_ifvg and raw_bull_fvg
    fvg_top = low[0]
    fvg_bot = high[2]
    fvg_bx  = box.new(bar_index - 2, fvg_top, bar_index + 500, fvg_bot,
                      border_color = color.new(color.lime, 40),
                      bgcolor      = color.new(color.lime, 88),
                      text         = "FVG ↑",
                      text_color   = color.new(color.lime, 10),
                      text_size    = size.tiny,
                      text_halign  = text.align_left,
                      text_valign  = text.align_top)
    array.push(ifvg_bull_hi,  fvg_top)
    array.push(ifvg_bull_lo,  fvg_bot)
    array.push(ifvg_bull_bi,  bar_index - 1)
    array.push(ifvg_bull_box, fvg_bx)
    if array.size(ifvg_bull_hi) > ifvg_max_n
        box.delete(array.shift(ifvg_bull_box))
        array.shift(ifvg_bull_hi)
        array.shift(ifvg_bull_lo)
        array.shift(ifvg_bull_bi)

if show_ifvg and raw_bear_fvg
    fvg_top = low[2]
    fvg_bot = high[0]
    fvg_bx  = box.new(bar_index - 2, fvg_top, bar_index + 500, fvg_bot,
                      border_color = color.new(color.red, 40),
                      bgcolor      = color.new(color.red, 88),
                      text         = "FVG ↓",
                      text_color   = color.new(color.red, 10),
                      text_size    = size.tiny,
                      text_halign  = text.align_left,
                      text_valign  = text.align_top)
    array.push(ifvg_bear_hi,  fvg_top)
    array.push(ifvg_bear_lo,  fvg_bot)
    array.push(ifvg_bear_bi,  bar_index - 1)
    array.push(ifvg_bear_box, fvg_bx)
    if array.size(ifvg_bear_hi) > ifvg_max_n
        box.delete(array.shift(ifvg_bear_box))
        array.shift(ifvg_bear_hi)
        array.shift(ifvg_bear_lo)
        array.shift(ifvg_bear_bi)

if show_ifvg
    int bsz = array.size(ifvg_bull_hi)
    if bsz > 0
        for i = bsz - 1 to 0
            fhi  = array.get(ifvg_bull_hi,  i)
            flo  = array.get(ifvg_bull_lo,  i)
            fbi  = array.get(ifvg_bull_bi,  i)
            fbox = array.get(ifvg_bull_box, i)
            if close <= flo and bar_index > fbi + 1
                box.delete(fbox)
                if is_recent
                    box.new(fbi, fhi, bar_index, flo,
                            border_color = color.new(color.red, 20),
                            bgcolor      = col_ifvg_bear,
                            text         = "IFVG ↓",
                            text_color   = color.new(color.red, 0),
                            text_size    = size.tiny,
                            text_halign  = text.align_left,
                            text_valign  = text.align_top)
                array.remove(ifvg_bull_hi,  i)
                array.remove(ifvg_bull_lo,  i)
                array.remove(ifvg_bull_bi,  i)
                array.remove(ifvg_bull_box, i)
            else
                box.set_right(fbox, bar_index + 10)

    int ssz = array.size(ifvg_bear_hi)
    if ssz > 0
        for i = ssz - 1 to 0
            fhi  = array.get(ifvg_bear_hi,  i)
            flo  = array.get(ifvg_bear_lo,  i)
            fbi  = array.get(ifvg_bear_bi,  i)
            fbox = array.get(ifvg_bear_box, i)
            if close >= fhi and bar_index > fbi + 1
                box.delete(fbox)
                if is_recent
                    box.new(fbi, fhi, bar_index, flo,
                            border_color = color.new(color.green, 20),
                            bgcolor      = col_ifvg_bull,
                            text         = "IFVG ↑",
                            text_color   = color.new(color.green, 0),
                            text_size    = size.tiny,
                            text_halign  = text.align_left,
                            text_valign  = text.align_top)
                array.remove(ifvg_bear_hi,  i)
                array.remove(ifvg_bear_lo,  i)
                array.remove(ifvg_bear_bi,  i)
                array.remove(ifvg_bear_box, i)
            else
                box.set_right(fbox, bar_index + 10)

// ════════════════════════════════════════════════════════════════════════════
//  BOS RETEST ENTRIES
// ════════════════════════════════════════════════════════════════════════════

bull_retest_bos = bull_up and not na(bull_lvl) and low <= bull_lvl + conf_tol and close >= bull_lvl - conf_tol and close > open and strong
bull_retest_fvg = bull_up and not na(b_fvg_hi) and not na(b_fvg_lo) and low <= b_fvg_hi and close >= b_fvg_lo and close > open and strong
bos_buy = show_bos and is_entry_tf and in_sess and not ranging and bull_trend and bull_struct and (bull_retest_bos or bull_retest_fvg)

bear_retest_bos = bear_up and not na(bear_lvl) and high >= bear_lvl - conf_tol and close <= bear_lvl + conf_tol and close < open and strong
bear_retest_fvg = bear_up and not na(s_fvg_lo) and not na(s_fvg_hi) and high >= s_fvg_lo and close <= s_fvg_hi and close < open and strong
bos_sell = show_bos and is_entry_tf and in_sess and not ranging and bear_trend and bear_struct and (bear_retest_bos or bear_retest_fvg)

// ════════════════════════════════════════════════════════════════════════════
//  ICC ENTRIES
// ════════════════════════════════════════════════════════════════════════════

icc_buy  = is_entry_tf and in_sess and not ranging and bull_trend and bull_struct and low  <= icc_l + conf_tol and close < icc_mid and close > open and strong
icc_sell = is_entry_tf and in_sess and not ranging and bear_trend and bear_struct and high >= icc_h - conf_tol and close > icc_mid and close < open and strong

// ════════════════════════════════════════════════════════════════════════════
//  ICC / BOS SIGNAL LABELS
// ════════════════════════════════════════════════════════════════════════════

if icc_buy and is_recent
    label.new(bar_index, low,  "BUY | Flow\n"  + sess_tag, color=color.new(color.green, 10), textcolor=color.white, style=label.style_label_up,   size=size.small)
if icc_sell and is_recent
    label.new(bar_index, high, "SELL | Flow\n" + sess_tag, color=color.new(color.red,   10), textcolor=color.white, style=label.style_label_down, size=size.small)
if bos_buy and is_recent
    label.new(bar_index, low,  "BUY | BOS\n"  + sess_tag, color=color.new(col_bb, 10), textcolor=color.white, style=label.style_label_up,   size=size.small)
if bos_sell and is_recent
    label.new(bar_index, high, "SELL | BOS\n" + sess_tag, color=color.new(col_bs, 10), textcolor=color.white, style=label.style_label_down, size=size.small)

// ════════════════════════════════════════════════════════════════════════════
//  USD HIGH IMPACT NEWS  (Forex Factory — Red Folder)
// ════════════════════════════════════════════════════════════════════════════

_today = str.tostring(year) +
         (month      < 10 ? "0" : "") + str.tostring(month)      +
         (dayofmonth < 10 ? "0" : "") + str.tostring(dayofmonth)

_hi_csv = ",20250110,20250207,20250307,20250404,20250502,20250606,20250711,20250801,20250905,20251003,20251107,20251205," +
          ",20250115,20250212,20250312,20250410,20250513,20250611,20250716,20250812,20250910,20251015,20251112,20251210," +
          ",20250116,20250213,20250313,20250411,20250514,20250612,20250715,20250813,20250911,20251016,20251113,20251211," +
          ",20250129,20250319,20250507,20250618,20250730,20250917,20251029,20250430,20250730,20251029," +
          ",20260109,20260206,20260306,20260403,20260501,20260605,20260710,20260807,20260904,20261002,20261106,20261204," +
          ",20260114,20260211,20260311,20260410,20260513,20260611,20260715,20260812,20260910,20261014,20261111,20261210," +
          ",20260113,20260212,20260312,20260411,20260514,20260612,20260716,20260813,20260911,20261015,20261112,20261211," +
          ",20260128,20260318,20260429,20260617,20260729,20260916,20261028,20261209," +
          ",20260129,20260429,20260729,20261028,"

is_hi_news = str.contains(_hi_csv, "," + _today + ",")

// ════════════════════════════════════════════════════════════════════════════
//  TRADER RULES — BOTTOM LEFT
// ════════════════════════════════════════════════════════════════════════════

col_gold = color.new(#FFD700, 0)

var table rules_tbl = table.new(position.bottom_left, 1, 10,
     bgcolor      = color.new(color.black, 45),
     border_color = color.new(color.gray,  60),
     border_width = 1,
     frame_color  = color.new(#FFD700, 40),
     frame_width  = 2)

table.cell(rules_tbl, 0, 0, "YOU ARE AN INTRADAY-SWING TRADER",
     text_color  = col_gold,
     bgcolor     = color.new(color.black, 30),
     text_size   = size.small,
     text_halign = text.align_center)

table.cell(rules_tbl, 0, 1, "USD HIGH IMPACT  (FF Red Folder)",
     text_color  = col_gold,
     bgcolor     = color.new(color.black, 35),
     text_size   = size.tiny,
     text_halign = text.align_center)
table.cell(rules_tbl, 0, 2, "NFP · CPI · PPI · FOMC · GDP · PCE · Retail",
     text_color  = color.new(color.silver, 20),
     bgcolor     = color.new(color.black, 55),
     text_size   = size.tiny,
     text_halign = text.align_center)
table.cell(rules_tbl, 0, 3,
     is_hi_news ? "⚡  TRADE DAY" : "✓  NO TRADE DAY",
     text_color  = is_hi_news ? color.new(color.red,  0) : color.new(color.lime, 10),
     bgcolor     = is_hi_news ? color.new(color.red, 82) : color.new(color.green, 82),
     text_size   = size.tiny,
     text_halign = text.align_center)
table.cell(rules_tbl, 0, 4, "Stay off the 1 Min time frame",
     text_color  = color.new(color.red, 10),
     bgcolor     = color.new(color.black, 55),
     text_size   = size.small,
     text_halign = text.align_center)
table.cell(rules_tbl, 0, 5, "Pray before each session",
     text_color  = color.new(color.white, 0),
     bgcolor     = color.new(color.black, 55),
     text_size   = size.small,
     text_halign = text.align_center)
table.cell(rules_tbl, 0, 6, "Only trade NY and Asia sessions",
     text_color  = color.new(color.white, 0),
     bgcolor     = color.new(color.black, 55),
     text_size   = size.small,
     text_halign = text.align_center)
table.cell(rules_tbl, 0, 7, "Wait 45 mins - 1H after session opens",
     text_color  = color.new(color.white, 0),
     bgcolor     = color.new(color.black, 55),
     text_size   = size.small,
     text_halign = text.align_center)
table.cell(rules_tbl, 0, 8, "Check trend clarification: 4H > 1H > 15M",
     text_color  = color.new(color.aqua, 0),
     bgcolor     = color.new(color.black, 55),
     text_size   = size.small,
     text_halign = text.align_center)
table.cell(rules_tbl, 0, 9, "Wait for candle closures",
     text_color  = color.new(color.white, 0),
     bgcolor     = color.new(color.black, 55),
     text_size   = size.small,
     text_halign = text.align_center)

// ════════════════════════════════════════════════════════════════════════════
//  CHECKLIST TABLE
// ════════════════════════════════════════════════════════════════════════════

f_ok(v)  => v ? color.new(color.green, 55) : color.new(color.red, 65)
f_chk(v) => v ? "✓" : "✘"

trend_str = bull_trend ? "▲ BULL" : bear_trend ? "▼ BEAR" : "— NEUTRAL"
trend_col = bull_trend ? color.lime  : bear_trend ? color.red : color.gray
sess_disp = sess_tag == "" ? "—" : sess_tag

var table chk_tbl = table.new(position.top_right, 2, 12,
     bgcolor      = color.new(color.black, 55),
     border_color = color.new(color.gray,  50),
     border_width = 1,
     frame_color  = color.new(color.gray,  30),
     frame_width  = 1)

table.cell(chk_tbl, 0, 0, "THE FLOW SYSTEM",
     text_color=color.white, bgcolor=color.new(color.navy, 20),
     text_size=size.small, text_halign=text.align_center)
table.cell(chk_tbl, 1, 0, "", bgcolor=color.new(color.navy, 20))

table.cell(chk_tbl, 0, 1,  "Trend",       text_color=color.silver, text_size=size.tiny, bgcolor=color.new(color.black,60))
table.cell(chk_tbl, 1, 1,  trend_str,     text_color=trend_col,    text_size=size.tiny, bgcolor=color.new(color.black,60))

table.cell(chk_tbl, 0, 2,  "Session",     text_color=color.silver, text_size=size.tiny, bgcolor=color.new(color.black,60))
table.cell(chk_tbl, 1, 2,  sess_disp,     text_color=color.white,  text_size=size.tiny, bgcolor=color.new(color.black,60))

table.cell(chk_tbl, 0, 3,  "Ranging",     text_color=color.silver, text_size=size.tiny, bgcolor=f_ok(not ranging))
table.cell(chk_tbl, 1, 3,  ranging ? "YES ✘" : "NO ✓", text_color=color.white, text_size=size.tiny, bgcolor=f_ok(not ranging))

table.cell(chk_tbl, 0, 4,  "Bull Struct", text_color=color.silver, text_size=size.tiny, bgcolor=f_ok(bull_struct))
table.cell(chk_tbl, 1, 4,  f_chk(bull_struct), text_color=color.white, text_size=size.tiny, bgcolor=f_ok(bull_struct))

table.cell(chk_tbl, 0, 5,  "Bear Struct", text_color=color.silver, text_size=size.tiny, bgcolor=f_ok(bear_struct))
table.cell(chk_tbl, 1, 5,  f_chk(bear_struct), text_color=color.white, text_size=size.tiny, bgcolor=f_ok(bear_struct))

table.cell(chk_tbl, 0, 6,  "BOS Bull",   text_color=color.silver, text_size=size.tiny, bgcolor=f_ok(bull_up))
table.cell(chk_tbl, 1, 6,  f_chk(bull_up), text_color=color.white, text_size=size.tiny, bgcolor=f_ok(bull_up))

table.cell(chk_tbl, 0, 7,  "BOS Bear",   text_color=color.silver, text_size=size.tiny, bgcolor=f_ok(bear_up))
table.cell(chk_tbl, 1, 7,  f_chk(bear_up), text_color=color.white, text_size=size.tiny, bgcolor=f_ok(bear_up))

table.cell(chk_tbl, 0, 8,  "AMD",        text_color=color.silver, text_size=size.tiny, bgcolor=f_ok(amd_active))
table.cell(chk_tbl, 1, 8,  amd_active ? "ACTIVE ✓" : "—", text_color=color.white, text_size=size.tiny, bgcolor=f_ok(amd_active))

table.cell(chk_tbl, 0, 9,  "PO3",        text_color=color.silver, text_size=size.tiny, bgcolor=f_ok(not po3_in_accum))
table.cell(chk_tbl, 1, 9,  po3_in_accum ? "ACCUM" : po3_dist_done ? "DIST ✓" : po3_swept_h or po3_swept_l ? "MANIP" : "READY", text_color=color.white, text_size=size.tiny, bgcolor=f_ok(not po3_in_accum))

table.cell(chk_tbl, 0, 10, "NY ORB",    text_color=color.silver, text_size=size.tiny, bgcolor=f_ok(ny_orb_done))
table.cell(chk_tbl, 1, 10, f_chk(ny_orb_done), text_color=color.white, text_size=size.tiny, bgcolor=f_ok(ny_orb_done))

table.cell(chk_tbl, 0, 11, "ASIA ORB",  text_color=color.silver, text_size=size.tiny, bgcolor=f_ok(asia_orb_done))
table.cell(chk_tbl, 1, 11, f_chk(asia_orb_done), text_color=color.white, text_size=size.tiny, bgcolor=f_ok(asia_orb_done))

// ════════════════════════════════════════════════════════════════════════════
//  ALERT CONDITIONS — ORB
// ════════════════════════════════════════════════════════════════════════════

alertcondition(ny_orb_bull,   title="NY ORB — Bullish Breakout",   message="NY ORB Breakout UP — {{ticker}} broke above NY Opening Range High at {{close}}")
alertcondition(ny_orb_bear,   title="NY ORB — Bearish Breakout",   message="NY ORB Breakdown — {{ticker}} broke below NY Opening Range Low at {{close}}")
alertcondition(asia_orb_bull, title="Asia ORB — Bullish Breakout", message="Asia ORB Breakout UP — {{ticker}} broke above Asia Opening Range High at {{close}}")
alertcondition(asia_orb_bear, title="Asia ORB — Bearish Breakout", message="Asia ORB Breakdown — {{ticker}} broke below Asia Opening Range Low at {{close}}")

// ════════════════════════════════════════════════════════════════════════════
//  STATIC LEVELS  (last bar only)
// ════════════════════════════════════════════════════════════════════════════

var line  l_h        = na
var line  l_l        = na
var line  l_mid      = na
var line  l_ch       = na
var line  l_cl       = na
var line  l_pdh      = na
var line  l_pdl      = na
var line  l_ny_orb_h = na
var line  l_ny_orb_l = na
var line  l_as_orb_h = na
var line  l_as_orb_l = na
var line  l_po3_open = na
var label lb_h        = na
var label lb_l        = na
var label lb_mid      = na
var label lb_ch       = na
var label lb_cl       = na
var label lb_pdh      = na
var label lb_pdl      = na
var label lb_ny_orb_h = na
var label lb_ny_orb_l = na
var label lb_as_orb_h = na
var label lb_as_orb_l = na
var label lb_po3_open = na
var box   bx_zon      = na
var box   bx_bfvg     = na
var box   bx_sfvg     = na
var box   bx_amd      = na
ext = 40

if barstate.islast
    line.delete(l_h),   line.delete(l_l),   line.delete(l_mid)
    line.delete(l_ch),  line.delete(l_cl),  line.delete(l_pdh),  line.delete(l_pdl)
    line.delete(l_ny_orb_h), line.delete(l_ny_orb_l)
    line.delete(l_as_orb_h), line.delete(l_as_orb_l)
    line.delete(l_po3_open)
    label.delete(lb_h),   label.delete(lb_l),   label.delete(lb_mid)
    label.delete(lb_ch),  label.delete(lb_cl),  label.delete(lb_pdh), label.delete(lb_pdl)
    label.delete(lb_ny_orb_h), label.delete(lb_ny_orb_l)
    label.delete(lb_as_orb_h), label.delete(lb_as_orb_l)
    label.delete(lb_po3_open)
    box.delete(bx_zon),  box.delete(bx_bfvg), box.delete(bx_sfvg)
    box.delete(bx_amd)

    l_h   := line.new(bar_index-150, icc_h,   bar_index+ext, icc_h,   color=col_h,   width=2)
    l_l   := line.new(bar_index-150, icc_l,   bar_index+ext, icc_l,   color=col_l,   width=2)
    l_mid := line.new(bar_index-150, icc_mid, bar_index+ext, icc_mid, color=col_mid, width=1, style=line.style_dashed)
    lb_h   := label.new(bar_index+ext, icc_h,   "Flow H   "+str.tostring(icc_h,  "#.##"), color=color.new(col_h,  85), textcolor=col_h,   style=label.style_label_left, size=size.normal)
    lb_l   := label.new(bar_index+ext, icc_l,   "Flow L   "+str.tostring(icc_l,  "#.##"), color=color.new(col_l,  85), textcolor=col_l,   style=label.style_label_left, size=size.normal)
    lb_mid := label.new(bar_index+ext, icc_mid, "Flow 50% "+str.tostring(icc_mid,"#.##"), color=color.new(col_mid,85), textcolor=col_mid, style=label.style_label_left, size=size.normal)

    if show_po3 and is_15m and not na(po3_open)
        l_po3_open  := line.new(po3_start_bar, po3_open, bar_index+ext, po3_open,
                                color=color.new(col_po3, 30), width=1, style=line.style_dashed)
        lb_po3_open := label.new(bar_index+ext, po3_open,
                                 "PO3 Open  "+str.tostring(po3_open,"#.##"),
                                 color=color.new(col_po3,85), textcolor=col_po3,
                                 style=label.style_label_left, size=size.small)

    if show_orb and ny_orb_done and not na(ny_orb_h)
        l_ny_orb_h  := line.new(ny_orb_s_bar, ny_orb_h, bar_index+ext, ny_orb_h, color=color.new(col_orb_bull, 30), width=1, style=line.style_dashed)
        l_ny_orb_l  := line.new(ny_orb_s_bar, ny_orb_l, bar_index+ext, ny_orb_l, color=color.new(col_orb_bear, 30), width=1, style=line.style_dashed)
        lb_ny_orb_h := label.new(bar_index+ext, ny_orb_h, "NY ORB H  "+str.tostring(ny_orb_h,"#.##"), color=color.new(col_orb_bull,85), textcolor=col_orb_bull, style=label.style_label_left, size=size.small)
        lb_ny_orb_l := label.new(bar_index+ext, ny_orb_l, "NY ORB L  "+str.tostring(ny_orb_l,"#.##"), color=color.new(col_orb_bear,85), textcolor=col_orb_bear, style=label.style_label_left, size=size.small)

    if show_orb and asia_orb_done and not na(asia_orb_h)
        l_as_orb_h  := line.new(asia_orb_s_bar, asia_orb_h, bar_index+ext, asia_orb_h, color=color.new(col_orb_bull, 50), width=1, style=line.style_dotted)
        l_as_orb_l  := line.new(asia_orb_s_bar, asia_orb_l, bar_index+ext, asia_orb_l, color=color.new(col_orb_bear, 50), width=1, style=line.style_dotted)
        lb_as_orb_h := label.new(bar_index+ext, asia_orb_h, "ASIA ORB H  "+str.tostring(asia_orb_h,"#.##"), color=color.new(col_orb_bull,85), textcolor=col_orb_bull, style=label.style_label_left, size=size.small)
        lb_as_orb_l := label.new(bar_index+ext, asia_orb_l, "ASIA ORB L  "+str.tostring(asia_orb_l,"#.##"), color=color.new(col_orb_bear,85), textcolor=col_orb_bear, style=label.style_label_left, size=size.small)

    if show_zone
        bx_zon := box.new(bar_index-150, cur_h, bar_index+ext, cur_l, border_color=color.new(col_zon,40), bgcolor=col_zon)
        l_ch   := line.new(bar_index-150, cur_h, bar_index+ext, cur_h, color=color.new(color.blue,20), width=1, style=line.style_dotted)
        l_cl   := line.new(bar_index-150, cur_l, bar_index+ext, cur_l, color=color.new(color.blue,20), width=1, style=line.style_dotted)
        lb_ch  := label.new(bar_index+ext, cur_h, "4H H  "+str.tostring(cur_h,"#.##"), color=color.new(color.blue,85), textcolor=color.blue, style=label.style_label_left, size=size.small)
        lb_cl  := label.new(bar_index+ext, cur_l, "4H L  "+str.tostring(cur_l,"#.##"), color=color.new(color.blue,85), textcolor=color.blue, style=label.style_label_left, size=size.small)

    if show_pd
        l_pdh  := line.new(bar_index-150, pd_h, bar_index+ext, pd_h, color=col_pd, width=1, style=line.style_dotted)
        l_pdl  := line.new(bar_index-150, pd_l, bar_index+ext, pd_l, color=col_pd, width=1, style=line.style_dotted)
        lb_pdh := label.new(bar_index+ext, pd_h, "PDH  "+str.tostring(pd_h,"#.##"), color=color.new(col_pd,85), textcolor=col_pd, style=label.style_label_left, size=size.small)
        lb_pdl := label.new(bar_index+ext, pd_l, "PDL  "+str.tostring(pd_l,"#.##"), color=color.new(col_pd,85), textcolor=col_pd, style=label.style_label_left, size=size.small)

    if show_fvg
        if bull_up and not na(b_fvg_hi) and not na(b_fvg_lo)
            bx_bfvg := box.new(b_fvg_bi-2, b_fvg_hi, bar_index+ext, b_fvg_lo, border_color=color.new(color.green,40), bgcolor=color.new(color.green,88))
        if bear_up and not na(s_fvg_hi) and not na(s_fvg_lo)
            bx_sfvg := box.new(s_fvg_bi-2, s_fvg_hi, bar_index+ext, s_fvg_lo, border_color=color.new(color.red,  40), bgcolor=color.new(color.red,  88))

    if show_amd and is_15m and amd_active and not na(asia_h) and not na(asia_l)
        bx_amd := box.new(asia_bar_start, asia_h, bar_index+ext, asia_l,
                          border_color=color.new(col_amd, 30), bgcolor=color.new(col_amd, 85),
                          text="A  (Accumulation)", text_color=col_amd, text_size=size.small)

    // ════════════════════════════════════════════════════════════════════════
    //  SESSION VOLUME PROFILE
    // ════════════════════════════════════════════════════════════════════════
    if show_vp and not na(vp_sess_hi) and not na(vp_sess_lo) and vp_sess_hi > vp_sess_lo
        for bx in vp_boxes
            box.delete(bx)
        array.clear(vp_boxes)
        line.delete(vp_poc_ln)
        line.delete(vp_vah_ln)
        line.delete(vp_val_ln)
        label.delete(vp_poc_lb)
        label.delete(vp_vah_lb)
        label.delete(vp_val_lb)

        bucket_sz = (vp_sess_hi - vp_sess_lo) / vp_rows
        vols      = array.new_float(vp_rows, 0.0)
        bars_back = math.max(0, math.min(bar_index - vp_sess_start, 499))

        for k = 0 to bars_back
            bh = high[k]
            bl = low[k]
            bv = volume[k]
            br = math.max(bh - bl, syminfo.mintick)
            for j = 0 to vp_rows - 1
                b_lo_j = vp_sess_lo + j * bucket_sz
                b_hi_j = b_lo_j + bucket_sz
                ov     = math.max(0.0, math.min(bh, b_hi_j) - math.max(bl, b_lo_j))
                if ov > 0.0
                    array.set(vols, j, array.get(vols, j) + bv * (ov / br))

        max_vol   = array.max(vols)
        poc_idx   = array.indexof(vols, max_vol)
        total_vol = array.sum(vols)
        va_target = total_vol * vp_va_pct / 100.0
        va_accum  = array.get(vols, poc_idx)
        vah_i     = poc_idx
        val_i     = poc_idx
        va_done   = va_accum >= va_target

        while not va_done
            up_v = vah_i < vp_rows - 1 ? array.get(vols, vah_i + 1) : 0.0
            dn_v = val_i > 0           ? array.get(vols, val_i - 1) : 0.0
            if up_v == 0.0 and dn_v == 0.0
                va_done := true
            else if up_v >= dn_v and vah_i < vp_rows - 1
                vah_i    += 1
                va_accum += up_v
            else if val_i > 0
                val_i    -= 1
                va_accum += dn_v
            else
                va_done := true
            if va_accum >= va_target
                va_done := true

        poc_price = vp_sess_lo + poc_idx * bucket_sz + bucket_sz * 0.5
        vah_price = vp_sess_lo + (vah_i + 1) * bucket_sz
        val_price = vp_sess_lo + val_i * bucket_sz

        x0    = bar_index + 2
        x_ext = bar_index + 2 + vp_width + 2

        for j = 0 to vp_rows - 1
            row_lo = vp_sess_lo + j * bucket_sz
            row_hi = row_lo + bucket_sz
            v      = array.get(vols, j)
            scaled = max_vol > 0 ? int(math.round(vp_width * v / max_vol)) : 0
            x1     = x0 + math.max(scaled, 1)
            is_poc = j == poc_idx
            is_va  = j >= val_i and j <= vah_i
            bg     = is_poc ? color.new(col_vp_poc, 20) : is_va ? col_vp_va : col_vp_out
            bc     = is_poc ? color.new(col_vp_poc, 0)  : is_va ? color.new(color.teal, 50) : color.new(color.gray, 70)
            array.push(vp_boxes, box.new(x0, row_hi, x1, row_lo, border_color=bc, bgcolor=bg))

        vp_poc_ln := line.new(bar_index - bars_back, poc_price, x_ext, poc_price,
                              color=color.new(col_vp_poc, 10), width=1, style=line.style_dashed)
        vp_vah_ln := line.new(bar_index - bars_back, vah_price, x_ext, vah_price,
                              color=color.new(color.teal, 40), width=1, style=line.style_dotted)
        vp_val_ln := line.new(bar_index - bars_back, val_price, x_ext, val_price,
                              color=color.new(color.teal, 40), width=1, style=line.style_dotted)
        vp_poc_lb := label.new(x_ext, poc_price, "POC  " + str.tostring(poc_price, "#.##"),
                               color=color.new(col_vp_poc, 75), textcolor=col_vp_poc,
                               style=label.style_label_left, size=size.small)
        vp_vah_lb := label.new(x_ext, vah_price, "VAH  " + str.tostring(vah_price, "#.##"),
                               color=color.new(color.teal, 75), textcolor=color.teal,
                               style=label.style_label_left, size=size.tiny)
        vp_val_lb := label.new(x_ext, val_price, "VAL  " + str.tostring(val_price, "#.##"),
                               color=color.new(color.teal, 75), textcolor=color.teal,
                               style=label.style_label_left, size=size.tiny)

// ════════════════════════════════════════════════════════════════════════════
//  VOLUME PROFILE TOGGLE BUTTON
// ════════════════════════════════════════════════════════════════════════════

var table vp_btn = table.new(position.bottom_right, 1, 1,
     border_color = color.new(color.gray, 40),
     border_width = 1)

table.cell(vp_btn, 0, 0,
     show_vp ? "VOL  ●  ON" : "VOL  ○  OFF",
     text_color = show_vp ? color.new(color.lime, 0) : color.new(color.gray, 30),
     bgcolor    = show_vp ? color.new(color.teal, 65) : color.new(color.black, 65),
     text_size  = size.small)
````
