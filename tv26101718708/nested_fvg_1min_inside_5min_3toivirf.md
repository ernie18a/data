# Nested FVG (1min inside 5min)

- url: https://www.tradingview.com/script/3ToIViRf-Nested-FVG-1min-inside-5min/
- type: indicator
- pine_id: PUB;e2e20ee261ab435bac8929e6da4aaad3
- version: 10.0

## Description

Nested FVG — 1min Inside 5min (ICT)
This indicator identifies high-probability Fair Value Gap setups by detecting when a 1-minute FVG forms inside — or within proximity of — a 5-minute FVG of the same direction. This confluence of imbalances across two timeframes is a core concept in ICT methodology, providing a more refined entry within a larger inefficiency.

How It Works
The indicator natively tracks 5-minute candle boundaries directly on the 1-minute chart. When a new 5-minute FVG (BISI or SIBI) forms during the session window, it is stored as an active zone. Every subsequent 1-minute bar is then checked for its own FVG — if that 1-minute gap falls inside or within a configurable proximity of an active 5-minute zone of the same direction, a signal fires.

Signal Logic

Bullish (BISI): 1-min low[0] > high[2], nested inside a 5-min bullish FVG
Bearish (SIBI): 1-min high[0] < low[2], nested inside a 5-min bearish FVG
A 30-bar cooldown prevents signal clusters (configurable)
Both FVGs must meet minimum size thresholds (in basis points) to filter noise


Automatic R/R Overlay
Every signal automatically plots a complete trade plan:

🟡 Entry — midpoint of the 1-min FVG
🔴 Stop — 15 points below/above entry
🔵 Partial — 15 points in profit (1:1)
🟢 Target — 45 points in profit (1:3)
🟨 Extended Target — 60 points in profit (1:4)


Visual Layout

5-min BISI/SIBI zones — solid bordered boxes labeled BISI or SIBI, extend right through the session
1-min nested FVG — dashed bordered boxes, visible for 15 minutes after formation
Triangles — green ▲ below bar for bullish, red ▼ above bar for bearish


Settings

Session filter (default 06:00–16:00 exchange time, works correctly on CME futures)
Minimum FVG size in basis points for both timeframes
Proximity tolerance (how close a 1-min FVG can be to the 5-min zone edge)
Cooldown between signals
All colors, R/R line lengths, and display options fully customizable


Important
► This indicator is designed to run on a 1-minute chart. Results on other timeframes will not be accurate.

For educational purposes only. Not financial advice. Always use proper risk management.

## Source Code

````pine
// © nested_fvg_indicator
// ► Run on a 1-MINUTE chart

//@version=6
indicator("Nested FVG (1min inside 5min)", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ─────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────
grp1 = "5-Minute FVG Settings"
fvg5_show      = input.bool(true,  "Show 5-min FVGs",                      group=grp1)
fvg5_bull_col  = input.color(color.new(#00bcd4, 70), "5-min Bullish Color", group=grp1)
fvg5_bear_col  = input.color(color.new(#ff5252, 70), "5-min Bearish Color", group=grp1)
fvg5_mitigated = input.bool(true,  "Remove 5-min FVG When Mitigated",       group=grp1)
fvg5_min_bp    = input.float(0.15, "5-min FVG Min Size (basis points)",     group=grp1, minval=0, maxval=100, step=0.05)

grp2 = "1-Minute FVG Settings"
fvg1_show      = input.bool(true,  "Show 1-min Nested FVGs",               group=grp2)
fvg1_bull_col  = input.color(color.new(#69f0ae, 40), "1-min Bullish Color", group=grp2)
fvg1_bear_col  = input.color(color.new(#ff8a80, 40), "1-min Bearish Color", group=grp2)
fvg1_min_bp    = input.float(0.15, "1-min FVG Min Size (basis points)",     group=grp2, minval=0, maxval=100, step=0.05)

grp3 = "Signal Settings"
sig_bull_col   = input.color(color.new(#00e676, 0), "Bullish Label Color",  group=grp3)
sig_bear_col   = input.color(color.new(#ff1744, 0), "Bearish Label Color",  group=grp3)
alert_on_nest  = input.bool(true, "Alert on Nested FVG",                    group=grp3)
alert_partial  = input.bool(true, "Alert on Partial/BE Hit",                group=grp3)
alert_stop     = input.bool(true, "Alert on Stop Hit",                      group=grp3)
alert_target   = input.bool(true, "Alert on Target Hit",                    group=grp3)
cooldown_bars  = input.int(30, "Cooldown Between Signals (bars/mins)",       group=grp3, minval=1, maxval=120)

grp6 = "R/R Tool"
rr_show        = input.bool(true,  "Show R/R Levels",                       group=grp6)
rr_label_size  = input.string("tiny", "R/R Label Size",                     group=grp6, options=["tiny","small","normal","large","huge"])
rr_stop_pts    = input.float(15.0, "Stop Loss (points)",                    group=grp6, minval=1, step=0.25)
rr_target_pts  = input.float(45.0, "Main Target (points)",                  group=grp6, minval=1, step=0.25)
rr_partial_pts = input.float(15.0, "Partial / BE Target (points)",          group=grp6, minval=1, step=0.25)
rr_ext_pts     = input.float(60.0, "Extended Target (points)",              group=grp6, minval=1, step=0.25)
rr_stop_col    = input.color(color.new(#ff1744, 0), "Stop Color",           group=grp6)
rr_entry_col   = input.color(color.new(#ffeb3b, 0), "Entry Color",          group=grp6)
rr_target_col  = input.color(color.new(#00e676, 0), "Target Color",         group=grp6)
rr_partial_col = input.color(color.new(#2196f3, 0), "Partial Color",        group=grp6)
rr_ext_col     = input.color(color.new(#ffeb3b, 0), "Extended Target Color", group=grp6)

grp7 = "Trade Tracker"
tbl_show       = input.bool(true,  "Show Trade Tracker Table",              group=grp7)
tbl_pos        = input.string("Bottom Right", "Table Position",             group=grp7, options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"])
tbl_size       = input.string("small", "Table Text Size",                   group=grp7, options=["tiny","small","normal"])
tbl_max_rows   = input.int(10, "Max Rows to Display",                       group=grp7, minval=3, maxval=20)
tbl_today_only = input.bool(true, "Today Only",                               group=grp7)
tbl_weekly     = input.bool(true,  "Show Weekly Summary Table",              group=grp7)
tbl_weekly_pos = input.string("Top Left", "Weekly Table Position",           group=grp7, options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"])
tbl_usd_per_pt = input.float(2.0,  "$ per Point",                            group=grp7, minval=0.0, step=0.5, tooltip="MNQ=$2, MES=$5, NQ=$20, ES=$50")
tbl_hourly     = input.bool(true, "Show Hourly Performance Table",            group=grp7)
tbl_hourly_pos = input.string("Bottom Left", "Hourly Table Position",         group=grp7, options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"])
tbl_theme      = input.string("Dark", "Table Theme",                             group=grp7, options=["Dark","Light"])

grp5 = "Proximity Filter"
proximity_bp   = input.float(5.0, "Proximity (basis points)",               group=grp5, minval=0, maxval=100, step=0.5)

grp4 = "Time Filter"
sess_string    = input.session("1900-1600:1234567", "Session (Exchange Time)", group=grp4)

// ─────────────────────────────────────────────────────────
//  CONVERSIONS
// ─────────────────────────────────────────────────────────
rr_sz = switch rr_label_size
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    => size.huge

tbl_pos_conv = switch tbl_pos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    => position.middle_left

tbl_sz_conv = switch tbl_size
    "tiny"  => size.tiny
    "small" => size.small
    => size.normal

// ─────────────────────────────────────────────────────────
//  THEME COLORS
// ─────────────────────────────────────────────────────────
bool isDark      = tbl_theme == "Dark"
color th_hbg     = isDark ? color.new(#1a1a2e, 0)   : color.new(#e8eaf6, 0)    // header bg
color th_row_bg  = isDark ? color.new(#2a2a3e, 20)  : color.new(#ffffff, 10)   // row bg
color th_sum_bg  = isDark ? color.new(#1a1a2e, 0)   : color.new(#c5cae9, 0)    // summary bg
color th_text    = isDark ? color.white               : color.new(#1a237e, 0)   // primary text
color th_muted   = isDark ? color.new(color.gray, 0) : color.new(#5c6bc0, 0)   // muted text
color th_hourly  = isDark ? color.new(color.gray, 80): color.new(#e8eaf6, 20)  // hourly row bg

// ─────────────────────────────────────────────────────────
//  SESSION
// ─────────────────────────────────────────────────────────
inSession         = not na(time(timeframe.period, sess_string, "America/Chicago"))
sessionJustOpened = inSession and not inSession[1]

// ─────────────────────────────────────────────────────────
//  5-MIN FVG STORAGE
// ─────────────────────────────────────────────────────────
var float[] fvg5_top    = array.new_float(0)
var float[] fvg5_bot    = array.new_float(0)
var int[]   fvg5_dir    = array.new_int(0)
var box[]   fvg5_box    = array.new_box(0)
var label[] fvg5_llabel = array.new_label(0)
var label[] fvg5_rlabel = array.new_label(0)
var box[]   fvg1_boxes  = array.new_box(0)

// ─────────────────────────────────────────────────────────
//  TRADE LOG ARRAYS
// ─────────────────────────────────────────────────────────
var int[]    tlog_num    = array.new_int(0)
var string[] tlog_date   = array.new_string(0)
var int[]    tlog_ts     = array.new_int(0)
var string[] tlog_time   = array.new_string(0)
var string[] tlog_dir    = array.new_string(0)
var float[]  tlog_entry  = array.new_float(0)
var float[]  tlog_stop   = array.new_float(0)
var float[]  tlog_part   = array.new_float(0)
var float[]  tlog_target = array.new_float(0)
var float[]  tlog_ext    = array.new_float(0)
var string[] tlog_result = array.new_string(0)
var float[]  tlog_pnl    = array.new_float(0)

// Hourly performance arrays (index 0-23 = hour 0-23)
var int[] active_hours = array.new_int(0)
var int[]   hr_trades  = array.new_int(24, 0)
var int[]   hr_wins    = array.new_int(24, 0)
var int[]   hr_losses  = array.new_int(24, 0)
var int[]   hr_partial = array.new_int(24, 0)
var float[] hr_pnl     = array.new_float(24, 0.0)
var int[]   hr_hour    = array.new_int(24, 0)

if barstate.isfirst
    for h = 0 to 23
        array.set(hr_hour, h, h)

// Open trade tracker
var bool  ot_active      = false
var int   ot_dir         = 0
var float ot_entry       = na
var float ot_stop        = na
var float ot_target      = na
var float ot_part        = na
var int   ot_idx         = -1
var bool  ot_partial_hit = false
var int   ot_hour        = 0

// Running stats
var int   stat_total     = 0
var int   stat_wins      = 0
var int   stat_losses    = 0
var int   stat_partials  = 0
var float stat_total_pnl = 0.0
var float stat_daily_pnl = 0.0
var int   stat_streak    = 0
var int   sig_count      = 0

// Cooldown
var int last_bull_bar   = -999
var int last_bear_bar   = -999
var int last_signal_bar = -999

// ─────────────────────────────────────────────────────────
//  PURGE ON SESSION OPEN
// ─────────────────────────────────────────────────────────
if sessionJustOpened
    if array.size(fvg5_box) > 0
        for i = 0 to array.size(fvg5_box) - 1
            box.delete(array.get(fvg5_box, i))
    if array.size(fvg5_llabel) > 0
        for i = 0 to array.size(fvg5_llabel) - 1
            label.delete(array.get(fvg5_llabel, i))
    if array.size(fvg5_rlabel) > 0
        for i = 0 to array.size(fvg5_rlabel) - 1
            label.delete(array.get(fvg5_rlabel, i))
    if array.size(fvg1_boxes) > 0
        for i = 0 to array.size(fvg1_boxes) - 1
            box.delete(array.get(fvg1_boxes, i))
    array.clear(fvg5_top)
    array.clear(fvg5_bot)
    array.clear(fvg5_dir)
    array.clear(fvg5_box)
    array.clear(fvg5_llabel)
    array.clear(fvg5_rlabel)
    array.clear(fvg1_boxes)
    last_bull_bar   := -999
    last_bear_bar   := -999
    last_signal_bar := -999
    stat_daily_pnl  := 0.0
    ot_active       := false
    ot_partial_hit  := false

bool _shared_ok       = (bar_index - last_signal_bar) >= cooldown_bars
bool bull_cooldown_ok = _shared_ok and (bar_index - last_bull_bar) >= cooldown_bars
bool bear_cooldown_ok = _shared_ok and (bar_index - last_bear_bar) >= cooldown_bars

// ─────────────────────────────────────────────────────────
//  OPEN TRADE OUTCOME DETECTION
// ─────────────────────────────────────────────────────────
bool outcome_partial = false
bool outcome_win     = false
bool outcome_loss    = false

if ot_active and not na(ot_entry)
    if ot_dir == 1
        if low <= ot_stop
            array.set(tlog_result, ot_idx, "❌ Loss")
            float p = ot_stop - ot_entry
            array.set(tlog_pnl, ot_idx, p)
            stat_total_pnl += p
            stat_daily_pnl += p
            stat_losses    += 1
            stat_streak     := stat_streak > 0 ? -1 : stat_streak - 1
            ot_active       := false
            ot_partial_hit  := false
            outcome_loss    := true
            array.set(hr_losses, ot_hour, array.get(hr_losses, ot_hour) + 1)
            array.set(hr_pnl,    ot_hour, array.get(hr_pnl,    ot_hour) + p)
        else if high >= ot_target
            array.set(tlog_result, ot_idx, "✅ Win")
            float p = ot_target - ot_entry
            array.set(tlog_pnl, ot_idx, p)
            stat_total_pnl += p
            stat_daily_pnl += p
            stat_wins      += 1
            stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
            ot_active       := false
            ot_partial_hit  := false
            outcome_win     := true
            array.set(hr_wins, ot_hour, array.get(hr_wins, ot_hour) + 1)
            array.set(hr_pnl,  ot_hour, array.get(hr_pnl,  ot_hour) + p)
        else if high >= ot_part and not ot_partial_hit
            array.set(tlog_result, ot_idx, "🔵 Partial")
            array.set(tlog_pnl,    ot_idx, ot_part - ot_entry)
            ot_partial_hit  := true
            stat_partials   += 1
            outcome_partial := true
            array.set(hr_partial, ot_hour, array.get(hr_partial, ot_hour) + 1)
            array.set(hr_pnl,     ot_hour, array.get(hr_pnl,     ot_hour) + (ot_part - ot_entry))
    else if ot_dir == -1
        if high >= ot_stop
            array.set(tlog_result, ot_idx, "❌ Loss")
            float p = ot_entry - ot_stop
            array.set(tlog_pnl, ot_idx, p)
            stat_total_pnl += p
            stat_daily_pnl += p
            stat_losses    += 1
            stat_streak     := stat_streak > 0 ? -1 : stat_streak - 1
            ot_active       := false
            ot_partial_hit  := false
            outcome_loss    := true
            array.set(hr_losses, ot_hour, array.get(hr_losses, ot_hour) + 1)
            array.set(hr_pnl,    ot_hour, array.get(hr_pnl,    ot_hour) + p)
        else if low <= ot_target
            array.set(tlog_result, ot_idx, "✅ Win")
            float p = ot_entry - ot_target
            array.set(tlog_pnl, ot_idx, p)
            stat_total_pnl += p
            stat_daily_pnl += p
            stat_wins      += 1
            stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
            ot_active       := false
            ot_partial_hit  := false
            outcome_win     := true
            array.set(hr_wins, ot_hour, array.get(hr_wins, ot_hour) + 1)
            array.set(hr_pnl,  ot_hour, array.get(hr_pnl,  ot_hour) + p)
        else if low <= ot_part and not ot_partial_hit
            array.set(tlog_result, ot_idx, "🔵 Partial")
            array.set(tlog_pnl,    ot_idx, ot_entry - ot_part)
            ot_partial_hit  := true
            stat_partials   += 1
            outcome_partial := true
            array.set(hr_partial, ot_hour, array.get(hr_partial, ot_hour) + 1)
            array.set(hr_pnl,     ot_hour, array.get(hr_pnl,     ot_hour) + (ot_entry - ot_part))

// ─────────────────────────────────────────────────────────
//  5-MIN BOUNDARY DETECTION
// ─────────────────────────────────────────────────────────
is_new_5m = timeframe.change("5")

var float running5High = na
var float running5Low  = na
var float h5_c0 = na,  var float l5_c0 = na
var float h5_c1 = na,  var float l5_c1 = na
var float h5_c2 = na,  var float l5_c2 = na

if is_new_5m
    h5_c2 := h5_c1
    l5_c2 := l5_c1
    h5_c1 := h5_c0
    l5_c1 := l5_c0
    h5_c0 := running5High
    l5_c0 := running5Low
    running5High := high
    running5Low  := low
else
    running5High := na(running5High) ? high : math.max(running5High, high)
    running5Low  := na(running5Low)  ? low  : math.min(running5Low,  low)

// ─────────────────────────────────────────────────────────
//  ADD 5-MIN FVG ZONE
// ─────────────────────────────────────────────────────────
f_add5(float ztop, float zbot, int zdir, string lbl, color bcol) =>
    array.push(fvg5_top, ztop)
    array.push(fvg5_bot, zbot)
    array.push(fvg5_dir, zdir)
    float mid = (ztop + zbot) / 2
    if fvg5_show
        b = box.new(bar_index - 15, ztop, bar_index, zbot,
             border_color=color.new(bcol, 0),
             bgcolor=color.new(bcol, 70),
             extend=extend.none, border_width=2,
             border_style=line.style_solid)
        array.push(fvg5_box, b)
        ll = label.new(bar_index - 15, mid, lbl,
             color=color.new(color.black, 100),
             textcolor=color.white,
             style=label.style_none,
             size=size.small,
             textalign=text.align_left)
        array.push(fvg5_llabel, ll)
        rl = label.new(bar_index, mid, lbl,
             color=color.new(color.black, 100),
             textcolor=color.white,
             style=label.style_none,
             size=size.small,
             textalign=text.align_right)
        array.push(fvg5_rlabel, rl)
    else
        array.push(fvg5_box,    box.new(0, 0, 1, 0))
        array.push(fvg5_llabel, label.new(0, 0, ""))
        array.push(fvg5_rlabel, label.new(0, 0, ""))

// ─────────────────────────────────────────────────────────
//  DETECT 5-MIN FVGS
// ─────────────────────────────────────────────────────────
if is_new_5m and inSession and not na(h5_c2)
    float gap5_bull = l5_c0 - h5_c2
    float min5_bull = h5_c2 * (fvg5_min_bp / 10000.0)
    if l5_c0 > h5_c2 and gap5_bull >= min5_bull
        f_add5(l5_c0, h5_c2, 1, "BISI", #00bcd4)

    float gap5_bear = l5_c2 - h5_c0
    float min5_bear = h5_c0 * (fvg5_min_bp / 10000.0)
    if h5_c0 < l5_c2 and gap5_bear >= min5_bear
        f_add5(l5_c2, h5_c0, -1, "SIBI", #ff5252)

// Stretch boxes + update right labels
if inSession and fvg5_show and array.size(fvg5_box) > 0
    for i = 0 to array.size(fvg5_box) - 1
        box.set_right(array.get(fvg5_box, i), bar_index)
        label.set_x(array.get(fvg5_rlabel, i), bar_index)

// ─────────────────────────────────────────────────────────
//  MITIGATION
// ─────────────────────────────────────────────────────────
if fvg5_mitigated and array.size(fvg5_top) > 0
    int i = 0
    while i < array.size(fvg5_top)
        bool mit = (array.get(fvg5_dir, i) == 1  and close < array.get(fvg5_bot, i)) or
                   (array.get(fvg5_dir, i) == -1 and close > array.get(fvg5_top, i))
        if mit
            array.remove(fvg5_top, i)
            array.remove(fvg5_bot, i)
            array.remove(fvg5_dir, i)
            box.delete(array.remove(fvg5_box, i))
            label.delete(array.remove(fvg5_llabel, i))
            label.delete(array.remove(fvg5_rlabel, i))
        else
            i += 1

// ─────────────────────────────────────────────────────────
//  1-MIN FVG + NESTED CHECK
// ─────────────────────────────────────────────────────────
bool bullNested = false
bool bearNested = false

if barstate.isconfirmed and inSession
    float gap1_bull = low - high[2]
    float min1_bull = high[2] * (fvg1_min_bp / 10000.0)
    if low > high[2] and gap1_bull >= min1_bull
        float top1 = low
        float bot1 = high[2]
        bool nested = false
        if array.size(fvg5_top) > 0
            for i = 0 to array.size(fvg5_top) - 1
                if array.get(fvg5_dir, i) == 1
                    float prox = array.get(fvg5_bot, i) * (proximity_bp / 10000.0)
                    if bot1 >= (array.get(fvg5_bot, i) - prox) and top1 <= (array.get(fvg5_top, i) + prox)
                        nested := true
                        break
        if nested and bull_cooldown_ok
            sig_count        += 1
            bullNested        := true
            last_bull_bar     := bar_index
            last_signal_bar   := bar_index
            stat_total        += 1
            float _be  = bot1
            float _bs  = _be - rr_stop_pts
            float _bp  = _be + rr_partial_pts
            float _bt  = _be + rr_target_pts
            float _bx  = _be + rr_ext_pts
            array.push(tlog_num,    sig_count)
            array.push(tlog_date,   str.format("{0,date,MM/dd}", time))
            array.push(tlog_ts,     time)
            array.push(tlog_time,   str.format("{0,time,HH:mm}", time))
            array.push(tlog_dir,    "▲ Bull")
            array.push(tlog_entry,  _be)
            array.push(tlog_stop,   _bs)
            array.push(tlog_part,   _bp)
            array.push(tlog_target, _bt)
            array.push(tlog_ext,    _bx)
            array.push(tlog_result, "⏳ Open")
            array.push(tlog_pnl,    0.0)
            ot_active      := true
            ot_dir         := 1
            ot_entry       := _be
            ot_hour        := hour(time, "America/Chicago")
            ot_stop        := _bs
            ot_target      := _bt
            ot_part        := _bp
            ot_idx         := array.size(tlog_time) - 1
            ot_partial_hit := false
            if fvg1_show
                b1 = box.new(bar_index - 2, top1, bar_index + 15, bot1,
                     border_color=color.new(#00ff00, 0), bgcolor=color.new(#00ff00, 40),
                     extend=extend.none, border_width=3, border_style=line.style_dashed)
                array.push(fvg1_boxes, b1)
            if rr_show
                int rs = bar_index + 1
                int re = bar_index + 16
                line.new(rs, _be, re, _be, color=rr_entry_col,   width=1, style=line.style_dashed)
                line.new(rs, _bs, re, _bs, color=rr_stop_col,    width=1, style=line.style_dashed)
                line.new(rs, _bp, re, _bp, color=rr_partial_col, width=1, style=line.style_dashed)
                line.new(rs, _bt, re, _bt, color=rr_target_col,  width=2, style=line.style_solid)
                line.new(rs, _bx, re, _bx, color=rr_ext_col,     width=2, style=line.style_solid)
                box.new(rs, _be, re, _bs, border_color=color.new(#ff1744,70), bgcolor=color.new(#ff1744,88), border_width=1)
                box.new(rs, _bt, re, _be, border_color=color.new(#00e676,70), bgcolor=color.new(#00e676,88), border_width=1)
                box.new(rs, _bx, re, _bt, border_color=color.new(#ffeb3b,70), bgcolor=color.new(#ffeb3b,88), border_width=1)
                label.new(re, _bx, "T2 +" + str.tostring(rr_ext_pts)    + "pts @ " + str.tostring(math.round(_bx,2)), color=color.new(#ffeb3b,10), textcolor=color.black, style=label.style_label_left, size=rr_sz)
                label.new(re, _bt, "T  +" + str.tostring(rr_target_pts) + "pts @ " + str.tostring(math.round(_bt,2)), color=color.new(#00e676,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _bp, "Partial / BE +" + str.tostring(rr_partial_pts) + "pts @ " + str.tostring(math.round(_bp,2)), color=color.new(#2196f3,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _bs, "S  -" + str.tostring(rr_stop_pts)   + "pts @ " + str.tostring(math.round(_bs,2)), color=color.new(#ff1744,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _be, "#" + str.tostring(sig_count) + " E @ " + str.tostring(math.round(_be,2)), color=color.new(#ffeb3b,10), textcolor=color.black, style=label.style_label_left, size=rr_sz)

    float gap1_bear = low[2] - high
    float min1_bear = high * (fvg1_min_bp / 10000.0)
    if high < low[2] and gap1_bear >= min1_bear
        float top1 = low[2]
        float bot1 = high
        bool nested = false
        if array.size(fvg5_top) > 0
            for i = 0 to array.size(fvg5_top) - 1
                if array.get(fvg5_dir, i) == -1
                    float prox = array.get(fvg5_bot, i) * (proximity_bp / 10000.0)
                    if bot1 >= (array.get(fvg5_bot, i) - prox) and top1 <= (array.get(fvg5_top, i) + prox)
                        nested := true
                        break
        if nested and bear_cooldown_ok
            sig_count        += 1
            bearNested        := true
            last_bear_bar     := bar_index
            last_signal_bar   := bar_index
            stat_total        += 1
            float _te  = top1
            float _ts  = _te + rr_stop_pts
            float _tp  = _te - rr_partial_pts
            float _tt  = _te - rr_target_pts
            float _tx  = _te - rr_ext_pts
            array.push(tlog_num,    sig_count)
            array.push(tlog_date,   str.format("{0,date,MM/dd}", time))
            array.push(tlog_ts,     time)
            array.push(tlog_time,   str.format("{0,time,HH:mm}", time))
            array.push(tlog_dir,    "▼ Bear")
            array.push(tlog_entry,  _te)
            array.push(tlog_stop,   _ts)
            array.push(tlog_part,   _tp)
            array.push(tlog_target, _tt)
            array.push(tlog_ext,    _tx)
            array.push(tlog_result, "⏳ Open")
            array.push(tlog_pnl,    0.0)
            ot_active      := true
            ot_dir         := -1
            ot_entry       := _te
            ot_hour        := hour(time, "America/Chicago")
            ot_stop        := _ts
            ot_target      := _tt
            ot_part        := _tp
            ot_idx         := array.size(tlog_time) - 1
            ot_partial_hit := false
            if fvg1_show
                b1 = box.new(bar_index - 2, top1, bar_index + 15, bot1,
                     border_color=color.new(#ff0000, 0), bgcolor=color.new(#ff0000, 40),
                     extend=extend.none, border_width=3, border_style=line.style_dashed)
                array.push(fvg1_boxes, b1)
            if rr_show
                int rs = bar_index + 1
                int re = bar_index + 16
                line.new(rs, _te, re, _te, color=rr_entry_col,   width=1, style=line.style_dashed)
                line.new(rs, _ts, re, _ts, color=rr_stop_col,    width=1, style=line.style_dashed)
                line.new(rs, _tp, re, _tp, color=rr_partial_col, width=1, style=line.style_dashed)
                line.new(rs, _tt, re, _tt, color=rr_target_col,  width=2, style=line.style_solid)
                line.new(rs, _tx, re, _tx, color=rr_ext_col,     width=2, style=line.style_solid)
                box.new(rs, _ts, re, _te, border_color=color.new(#ff1744,70), bgcolor=color.new(#ff1744,88), border_width=1)
                box.new(rs, _te, re, _tt, border_color=color.new(#00e676,70), bgcolor=color.new(#00e676,88), border_width=1)
                box.new(rs, _tt, re, _tx, border_color=color.new(#ffeb3b,70), bgcolor=color.new(#ffeb3b,88), border_width=1)
                label.new(re, _tx, "T2 -" + str.tostring(rr_ext_pts)    + "pts @ " + str.tostring(math.round(_tx,2)), color=color.new(#ffeb3b,10), textcolor=color.black, style=label.style_label_left, size=rr_sz)
                label.new(re, _tt, "T  -" + str.tostring(rr_target_pts) + "pts @ " + str.tostring(math.round(_tt,2)), color=color.new(#00e676,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _tp, "Partial / BE -" + str.tostring(rr_partial_pts) + "pts @ " + str.tostring(math.round(_tp,2)), color=color.new(#2196f3,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _ts, "S  +" + str.tostring(rr_stop_pts)   + "pts @ " + str.tostring(math.round(_ts,2)), color=color.new(#ff1744,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _te, "#" + str.tostring(sig_count) + " E @ " + str.tostring(math.round(_te,2)), color=color.new(#ffeb3b,10), textcolor=color.black, style=label.style_label_left, size=rr_sz)

// ─────────────────────────────────────────────────────────
//  RENDER TRADE TRACKER TABLE
// ─────────────────────────────────────────────────────────
if tbl_show and barstate.islast
    int  all_rows  = array.size(tlog_time)
    string today_str = str.format("{0,date,MM/dd}", time)

    var int[] filtered = array.new_int(0)
    array.clear(filtered)
    if all_rows > 0
        for i = 0 to all_rows - 1
            if not tbl_today_only or array.get(tlog_date, i) == today_str
                array.push(filtered, i)

    int frows = array.size(filtered)
    if frows > 0
        int start = math.max(0, frows - tbl_max_rows)
        int disp  = frows - start

        int   f_wins = 0, f_losses = 0, f_partials = 0
        float f_pnl  = 0.0
        int   f_streak = 0
        for k = 0 to frows - 1
            int    ki = array.get(filtered, k)
            string kr = array.get(tlog_result, ki)
            float  kp = array.get(tlog_pnl,    ki)
            if kr == "✅ Win"
                f_wins   += 1
                f_pnl    += kp
                f_streak  := f_streak < 0 ? 1 : f_streak + 1
            else if kr == "❌ Loss"
                f_losses += 1
                f_pnl    += kp
                f_streak  := f_streak > 0 ? -1 : f_streak - 1
            else if kr == "🔵 Partial"
                f_partials += 1
                f_pnl      += kp

        int   f_settled = f_wins + f_losses + f_partials
        float f_wr      = f_settled > 0 ? (f_wins / f_settled) * 100 : 0.0
        string streak_str = f_streak > 0 ? "🔥 " + str.tostring(f_streak) + "W" : f_streak < 0 ? "🧊 " + str.tostring(math.abs(f_streak)) + "L" : "-"

        color hbg    = th_hbg
        color row_bg = th_row_bg
        color sum_bg = th_sum_bg

        table t = table.new(tbl_pos_conv, 9, tbl_max_rows + 3,
             border_color=color.new(color.gray, 50),
             border_width=1,
             frame_color=color.new(color.gray, 30),
             frame_width=1)

        table.cell(t, 0, 0, "Date",    text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 1, 0, "Time",    text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 2, 0, "Dir",     text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 3, 0, "Entry",   text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 4, 0, "Stop",    text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 5, 0, "Target",  text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 6, 0, "Result",  text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 7, 0, "P&L",     text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 8, 0, "#",       text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)

        for i = 0 to disp - 1
            int    idx = array.get(filtered, start + i)
            int    row = i + 1
            string res = array.get(tlog_result, idx)
            float  pnl = array.get(tlog_pnl,    idx)
            string dir = array.get(tlog_dir,     idx)
            color  rc  = res == "✅ Win"     ? color.new(color.green, 20) : res == "❌ Loss" ? color.new(color.red, 20) : res == "🔵 Partial" ? color.new(color.blue, 20) : color.new(color.gray, 60)
            color  pc  = pnl > 0 ? color.new(color.green, 60) : pnl < 0 ? color.new(color.red, 60) : color.new(color.gray, 60)
            color  dc  = str.contains(dir, "Bull") ? color.new(color.teal, 20) : color.new(color.red, 20)
            table.cell(t, 0, row, array.get(tlog_date, idx),                                text_color=th_muted,  bgcolor=row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 1, row, array.get(tlog_time, idx),                                text_color=th_text,   bgcolor=row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 2, row, dir,                                                       text_color=color.white,  bgcolor=dc,     text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 3, row, str.tostring(math.round(array.get(tlog_entry,  idx),2)),  text_color=isDark ? color.yellow : color.new(#e65100, 0), bgcolor=row_bg, text_size=tbl_sz_conv, text_halign=text.align_right)
            table.cell(t, 4, row, str.tostring(math.round(array.get(tlog_stop,   idx),2)),  text_color=color.red,    bgcolor=row_bg, text_size=tbl_sz_conv, text_halign=text.align_right)
            table.cell(t, 5, row, str.tostring(math.round(array.get(tlog_target, idx),2)),  text_color=color.green,  bgcolor=row_bg, text_size=tbl_sz_conv, text_halign=text.align_right)
            table.cell(t, 6, row, res,                                                       text_color=color.white,  bgcolor=rc,     text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 7, row, (pnl >= 0 ? "+" : "") + str.tostring(math.round(pnl,1)), text_color=color.white, bgcolor=pc, text_size=tbl_sz_conv, text_halign=text.align_right)
            table.cell(t, 8, row, str.tostring(array.get(tlog_num, idx)),                   text_color=color.gray,   bgcolor=row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)

        int   srow   = disp + 1
        color pnl_bg = f_pnl >= 0 ? color.new(#1b5e20, 0) : color.new(#b71c1c, 0)
        color day_bg = stat_daily_pnl >= 0 ? color.new(#1b5e20, 30) : color.new(#b71c1c, 30)
        string mode_lbl = tbl_today_only ? "TODAY" : "ALL"
        table.cell(t, 0, srow, mode_lbl,                                                                                   text_color=th_text, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 1, srow, str.tostring(frows) + " trades",                                                            text_color=color.white, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 2, srow, str.tostring(f_wins) + "W " + str.tostring(f_losses) + "L " + str.tostring(f_partials) + "P", text_color=color.white, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 3, srow, "WR: " + str.tostring(math.round(f_wr,1)) + "%",                                           text_color=color.white, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 4, srow, "Streak: " + streak_str,                                                                    text_color=color.white, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 5, srow, "Day: " + (stat_daily_pnl >= 0 ? "+" : "") + str.tostring(math.round(stat_daily_pnl,1)) + "pts", text_color=color.white, bgcolor=day_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 6, srow, "All: " + (stat_total_pnl >= 0 ? "+" : "") + str.tostring(math.round(stat_total_pnl,1)) + "pts", text_color=color.white, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 7, srow, (f_pnl >= 0 ? "+" : "") + str.tostring(math.round(f_pnl,1)) + "pts",                      text_color=color.white, bgcolor=pnl_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 8, srow, str.tostring(stat_total) + " total",                                                        text_color=th_muted, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────
//  RENDER WEEKLY SUMMARY TABLE  (with Mon–Fri day breakdown)
// ─────────────────────────────────────────────────────────
if tbl_weekly and barstate.islast
    tbl_weekly_pos_conv = switch tbl_weekly_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.middle_left

    // ── Week boundary ────────────────────────────────────
    int cur_dow        = dayofweek(time, "America/Chicago")
    int cur_hour_w     = hour(time,   "America/Chicago")
    int cur_min_w      = minute(time, "America/Chicago")
    int days_since_sun = cur_dow == 1 ? 0 : cur_dow - 1
    bool before_open   = cur_dow == 1 and cur_hour_w < 17
    if before_open
        days_since_sun := 7
    int week_open_ts = time - days_since_sun * 86400000 - (cur_hour_w * 3600000) - (cur_min_w * 60000) + 17 * 3600000

    // ── Per-day boundary timestamps ───────────────────────
    int mon_open = week_open_ts + 86400000
    int tue_open = week_open_ts + 172800000
    int wed_open = week_open_ts + 259200000
    int thu_open = week_open_ts + 345600000
    int fri_open = week_open_ts + 432000000

    // Per-day tallies  [0]=Mon [1]=Tue [2]=Wed [3]=Thu [4]=Fri
    int[]   d_wins     = array.new_int(5, 0)
    int[]   d_losses   = array.new_int(5, 0)
    int[]   d_partials = array.new_int(5, 0)
    float[] d_pnl      = array.new_float(5, 0.0)
    int[]   d_total    = array.new_int(5, 0)

    // Week totals
    int   wk_wins = 0, wk_losses = 0, wk_partials = 0
    float wk_pnl  = 0.0
    int   wk_total = 0

    int all_rows3 = array.size(tlog_ts)
    if all_rows3 > 0
        for k = 0 to all_rows3 - 1
            int    kts = array.get(tlog_ts,     k)
            string kr  = array.get(tlog_result, k)
            float  kp  = array.get(tlog_pnl,    k)
            if kts >= week_open_ts
                wk_total += 1
                int di = kts >= fri_open ? 4 : kts >= thu_open ? 3 : kts >= wed_open ? 2 : kts >= tue_open ? 1 : 0
                array.set(d_total, di, array.get(d_total, di) + 1)
                if kr == "✅ Win"
                    wk_wins += 1
                    wk_pnl  += kp
                    array.set(d_wins, di, array.get(d_wins, di) + 1)
                    array.set(d_pnl,  di, array.get(d_pnl,  di) + kp)
                else if kr == "❌ Loss"
                    wk_losses += 1
                    wk_pnl    += kp
                    array.set(d_losses, di, array.get(d_losses, di) + 1)
                    array.set(d_pnl,    di, array.get(d_pnl,    di) + kp)
                else if kr == "🔵 Partial"
                    wk_partials += 1
                    wk_pnl      += kp
                    array.set(d_partials, di, array.get(d_partials, di) + 1)
                    array.set(d_pnl,      di, array.get(d_pnl,      di) + kp)
                else
                    wk_pnl += kp
                    array.set(d_pnl, di, array.get(d_pnl, di) + kp)

    int   wk_settled = wk_wins + wk_losses + wk_partials
    float wk_wr      = wk_settled > 0 ? (wk_wins / wk_settled) * 100 : 0.0
    float wk_usd     = wk_pnl * tbl_usd_per_pt

    color wbg     = wk_pnl >= 0 ? color.new(#1b5e20, 0) : color.new(#b71c1c, 0)
    color whbg    = th_hbg
    color wrow_bg = th_row_bg

    // Count active days to size table dynamically
    int active_days = 0
    for d = 0 to 4
        if array.get(d_total, d) > 0
            active_days += 1

    int total_wt_rows = 3 + active_days + 1
    string[] day_names = array.from("Mon", "Tue", "Wed", "Thu", "Fri")

    table wt = table.new(tbl_weekly_pos_conv, 5, total_wt_rows,
         border_color=color.new(color.gray, 50),
         border_width=1,
         frame_color=color.new(color.gray, 30),
         frame_width=1)

    // ── Header row ───────────────────────────────────────
    table.cell(wt, 0, 0, "THIS WEEK", text_color=th_text, bgcolor=whbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 1, 0, "W / L / P", text_color=th_text, bgcolor=whbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 2, 0, "Win %",     text_color=th_text, bgcolor=whbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 3, 0, "P&L pts",   text_color=th_text, bgcolor=whbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 4, 0, "P&L $",     text_color=th_text, bgcolor=whbg, text_size=tbl_sz_conv, text_halign=text.align_center)

    // ── Week total row ───────────────────────────────────
    table.cell(wt, 0, 1, str.tostring(wk_total) + " trades", text_color=th_text,  bgcolor=wrow_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 1, 1, str.tostring(wk_wins) + "W / " + str.tostring(wk_losses) + "L / " + str.tostring(wk_partials) + "P", text_color=th_text, bgcolor=wrow_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 2, 1, str.tostring(math.round(wk_wr,1)) + "%", text_color=wk_wr >= 50 ? color.green : color.red, bgcolor=wrow_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 3, 1, (wk_pnl >= 0 ? "+" : "") + str.tostring(math.round(wk_pnl,1)) + " pts", text_color=color.white, bgcolor=wbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 4, 1, (wk_usd >= 0 ? "+$" : "-$") + str.tostring(math.round(math.abs(wk_usd))), text_color=color.white, bgcolor=wbg, text_size=tbl_sz_conv, text_halign=text.align_center)

    // ── Per-day rows (only days with trades) ─────────────
    int drow = 2
    for d = 0 to 4
        int   dw = array.get(d_wins,     d)
        int   dl = array.get(d_losses,   d)
        int   dp = array.get(d_partials, d)
        int   dt = array.get(d_total,    d)
        float dpnl = array.get(d_pnl,   d)
        if dt > 0
            int   ds   = dw + dl + dp
            float dwr  = ds > 0 ? (dw / ds) * 100 : 0.0
            float dusd = dpnl * tbl_usd_per_pt
            color dbg  = dpnl >= 0 ? color.new(#1b5e20, 40) : color.new(#b71c1c, 40)
            color dtxt = isDark ? color.new(color.gray, 20) : color.new(#3949ab, 0)
            table.cell(wt, 0, drow, array.get(day_names, d),                                                             text_color=dtxt,  bgcolor=th_hourly, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(wt, 1, drow, str.tostring(dw) + "W / " + str.tostring(dl) + "L / " + str.tostring(dp) + "P",    text_color=dtxt,  bgcolor=th_hourly, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(wt, 2, drow, str.tostring(math.round(dwr,1)) + "%",                                               text_color=dwr >= 50 ? color.green : color.red, bgcolor=th_hourly, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(wt, 3, drow, (dpnl >= 0 ? "+" : "") + str.tostring(math.round(dpnl,1)) + " pts",                 text_color=color.white, bgcolor=dbg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(wt, 4, drow, (dusd >= 0 ? "+$" : "-$") + str.tostring(math.round(math.abs(dusd))),               text_color=color.white, bgcolor=dbg, text_size=tbl_sz_conv, text_halign=text.align_center)
            drow += 1

    // ── Footer / contract label row ───────────────────────
    string clbl = tbl_usd_per_pt == 2.0 ? "MNQ @ $2/pt" : tbl_usd_per_pt == 20.0 ? "NQ @ $20/pt" : tbl_usd_per_pt == 5.0 ? "MES @ $5/pt" : tbl_usd_per_pt == 50.0 ? "ES @ $50/pt" : "$" + str.tostring(tbl_usd_per_pt) + "/pt"
    table.cell(wt, 0, drow, clbl,                                            text_color=th_muted, bgcolor=whbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 1, drow, str.tostring(days_since_sun) + "d since Sun 5PM CT", text_color=th_muted, bgcolor=whbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 2, drow, "",                                               text_color=th_muted, bgcolor=whbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 3, drow, "",                                               text_color=th_muted, bgcolor=whbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 4, drow, "",                                               text_color=th_muted, bgcolor=whbg, text_size=tbl_sz_conv, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────
//  RENDER HOURLY PERFORMANCE TABLE
// ─────────────────────────────────────────────────────────
if tbl_hourly and barstate.islast
    tbl_hourly_pos_conv = switch tbl_hourly_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.middle_left

    array.clear(active_hours)
    for h = 0 to 23
        if array.get(hr_wins, h) + array.get(hr_losses, h) + array.get(hr_partial, h) > 0
            array.push(active_hours, h)

    int ah = array.size(active_hours)
    if ah > 0
        table ht = table.new(tbl_hourly_pos_conv, 7, ah + 2,
             border_color=color.new(color.gray, 50),
             border_width=1,
             frame_color=color.new(color.gray, 30),
             frame_width=1)

        color hhbg = th_hbg
        table.cell(ht, 0, 0, "Hour (CT)",  text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(ht, 1, 0, "Signals",    text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(ht, 2, 0, "Wins",       text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(ht, 3, 0, "Losses",     text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(ht, 4, 0, "Win %",      text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(ht, 5, 0, "P&L pts",    text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(ht, 6, 0, "Rating",     text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)

        for i = 0 to ah - 1
            int   h    = array.get(active_hours, i)
            int   row  = i + 1
            int   hw   = array.get(hr_wins,    h)
            int   hl   = array.get(hr_losses,  h)
            int   hp   = array.get(hr_partial, h)
            int   ht_  = hw + hl + hp
            float hpnl = array.get(hr_pnl,    h)
            int   settled = hw + hl + hp
            float wr   = settled > 0 ? (hw / settled) * 100 : 0.0
            bool is_power     = (h >= 8  and h <= 9)
            bool is_afternoon = (h >= 13 and h <= 14)
            bool is_evening   = (h >= 21 and h <= 22)
            bool is_recommended = (is_power or is_afternoon or is_evening) and hpnl > 0
            bool is_strong    = hpnl >= 300 and wr >= 30
            bool is_weak      = wr < 15 or (hpnl > 0 and hpnl < 150 and ht_ >= 10)
            string rating = is_strong and is_recommended ? "** USE **" : is_recommended ? "* Use *" : is_strong ? "* Use *" : is_weak ? "X Cut X" : "! Caution"
            color  rbg = rating == "** USE **" ? color.new(#1b5e20, 0) : rating == "* Use *" ? color.new(#1b5e20, 30) : rating == "X Cut X" ? color.new(#b71c1c, 20) : color.new(color.orange, 30)
            color  pbg = hpnl > 0 ? color.new(color.green, 60) : color.new(color.red, 60)
            int    h12  = h == 0 ? 12 : h > 12 ? h - 12 : h
            string ampm = h < 12 ? "AM" : "PM"
            string hlbl = str.tostring(h12) + ":00 " + ampm
            color  hbg2 = th_hourly
            table.cell(ht, 0, row, hlbl,                                                               text_color=th_text,  bgcolor=hbg2, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(ht, 1, row, str.tostring(ht_),                                                 text_color=th_text,  bgcolor=hbg2, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(ht, 2, row, str.tostring(hw),                                                  text_color=color.green,  bgcolor=hbg2, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(ht, 3, row, str.tostring(hl),                                                  text_color=color.red,    bgcolor=hbg2, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(ht, 4, row, str.tostring(math.round(wr, 1)) + "%",                             text_color=wr >= 50 ? color.green : color.red, bgcolor=hbg2, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(ht, 5, row, (hpnl >= 0 ? "+" : "") + str.tostring(math.round(hpnl, 1)),       text_color=hpnl >= 0 ? color.green : color.red, bgcolor=pbg, text_size=tbl_sz_conv, text_halign=text.align_right)
            table.cell(ht, 6, row, rating,                                                             text_color=th_text,  bgcolor=rbg,  text_size=tbl_sz_conv, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────
if alert_on_nest and bullNested
    alert('{"ticker":"' + syminfo.ticker + '","action":"buy","signal":"' + str.tostring(sig_count) + '","price":' + str.tostring(math.round(close,2)) + '}', alert.freq_once_per_bar_close)
if alert_on_nest and bearNested
    alert('{"ticker":"' + syminfo.ticker + '","action":"sell","signal":"' + str.tostring(sig_count) + '","price":' + str.tostring(math.round(close,2)) + '}', alert.freq_once_per_bar_close)
if alert_partial and outcome_partial
    alert("Partial/BE Hit — Signal #" + str.tostring(sig_count) + " — " + syminfo.ticker, alert.freq_once_per_bar_close)
if alert_stop and outcome_loss
    alert("Stop Hit — Signal #" + str.tostring(sig_count) + " — " + syminfo.ticker, alert.freq_once_per_bar_close)
if alert_target and outcome_win
    alert("Target Hit — Signal #" + str.tostring(sig_count) + " — " + syminfo.ticker, alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────
//  PLOT MARKERS
// ─────────────────────────────────────────────────────────
plotshape(bullNested, "Nested Bull", shape.triangleup,   location.belowbar, sig_bull_col, size=size.small)
plotshape(bearNested, "Nested Bear", shape.triangledown, location.abovebar, sig_bear_col, size=size.small)
````
