# SwiftLevels

- url: https://www.tradingview.com/script/L5PhFtQj-SwiftLevels/
- type: indicator
- pine_id: PUB;12aa486cffc54d1da29b2e5161bb2f1c
- version: 5.0

## Description

SwiftLevels is a clean, all-in-one overlay indicator that keeps the most important price reference levels and daily moving averages visible at a glance — without cluttering your chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRIOR DAY & PRIOR WEEK LEVELS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
On intraday charts, SwiftLevels draws horizontal lines for the prior day high/low and prior week high/low. Lines are anchored to the prior session's open so they don't clutter the left side of the chart. Labels float at the right edge of the current session and update each bar close to show the live percentage distance from price — positive when price is above, negative when below.

  Example: PRIOR DAY (+1.24%)   PRIOR WEEK (-0.87%)

Colors and label visibility are fully configurable per level group.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DAILY MOVING AVERAGES (5 fully configurable)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Five independent moving averages, each calculated from daily chart data regardless of your current timeframe.

On intraday charts:
  • Each MA is drawn as a clean horizontal line starting at today's session open and extending right — no stair-stepping history, no noise from previous sessions.
  • Labels appear just before the line starts, showing the MA name and live % distance from price, updated each bar close.
  • Example: 20d SMA (+2.11%)   50d SMA (-0.44%)

On the daily chart:
  • MAs are displayed as traditional full-history plots so you can see the curve over time.
  • Can be toggled on/off with the "Display on Daily" checkbox.

On weekly/monthly charts:
  • MAs are hidden to keep those timeframes uncluttered.

Each moving average is independently configurable:
  • Enable / disable
  • Length (default: 5, 10, 20, 50, 200)
  • SMA or EMA toggle
  • Custom color
  • Line width

## Source Code

````pine
// levels_v2.pinescript
// Prior Day & Week Levels + 5 configurable Daily MAs (real-time, no close wait)

//@version=6
indicator("SwiftLevels", overlay=true, shorttitle="SwiftLevels")

// ══════════════════════════════════════════════════════════════ INPUTS — DATA BOX
// Declared first so this group sits at the top of the settings panel — Pine
// orders the panel by declaration order.
var GRP_BOX = "Data Box"
show_position    = input.bool(true, "Show POSITION section",    group=GRP_BOX)
show_performance = input.bool(true, "Show PERFORMANCE section", group=GRP_BOX)

// ══════════════════════════════════════════════════════════════ INPUTS — SESSION
// Futures trade nearly 24h, so the symbol's own daily bar spans the overnight
// (Globex) session — an overnight spike becomes the "prior day high" even though
// it never traded during regular hours. With this on, the prior day/week levels
// are rebuilt from the chart's own bars using only the session window below.
//
// OFF BY DEFAULT — default behavior is byte-for-byte what it was.
//
// The daily moving averages are deliberately NOT affected: rebuilding a 200d MA
// from regular hours would need 200 days of intraday bars on the chart, and a
// daily MA is conventionally computed on the full session anyway.
var GRP_SESS = "Session"
rth_only = input.bool(false, "Enforce Regular Hours Only (for Futures)", group=GRP_SESS)
rth_sess = input.session("0930-1600", "Regular Hours",                   group=GRP_SESS)
rth_tz   = input.string("America/New_York", "Timezone", group=GRP_SESS, options=["America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "America/Sao_Paulo", "Europe/London", "Europe/Dublin", "Europe/Paris", "Europe/Berlin", "Europe/Zurich", "Europe/Stockholm", "Europe/Moscow", "Asia/Dubai", "Asia/Kolkata", "Asia/Singapore", "Asia/Hong_Kong", "Asia/Shanghai", "Asia/Tokyo", "Asia/Seoul", "Australia/Sydney", "Pacific/Auckland", "UTC"])

// ══════════════════════════════════════════════════════════════ INPUTS — LEVELS
var GRP_PD  = "Prior Day"
var GRP_PD2 = "Prior Day -2"
var GRP_PW  = "Prior Week"
var GRP_PW2 = "Prior Week -2"

// "Enable" hides the whole group — both lines and their labels. "Show Labels"
// keeps the lines but drops the text.
pd_en     = input.bool(true, "Enable",                         group=GRP_PD)
pdh_show  = input.bool(true, "Show High",                      group=GRP_PD)
pdl_show  = input.bool(true, "Show Low",                       group=GRP_PD)
pdh_color = input.color(color.new(#b0b0b0, 0),  "High Color",  group=GRP_PD)
pdl_color = input.color(color.new(#b0b0b0, 0),  "Low Color",   group=GRP_PD)
pd_width  = input.int(1, "Line Width", minval=1, maxval=4,     group=GRP_PD)
pd_labels = input.bool(true, "Show Labels",                    group=GRP_PD)

pd2_en     = input.bool(true, "Enable",                        group=GRP_PD2)
pdh2_show  = input.bool(true, "Show High",                     group=GRP_PD2)
pdl2_show  = input.bool(true, "Show Low",                      group=GRP_PD2)
pdh2_color = input.color(color.new(#b0b0b0, 45), "High Color", group=GRP_PD2)
pdl2_color = input.color(color.new(#b0b0b0, 45), "Low Color",  group=GRP_PD2)
pd2_width  = input.int(1, "Line Width", minval=1, maxval=4,    group=GRP_PD2)
pd2_labels = input.bool(true, "Show Labels",                   group=GRP_PD2)

pw_en     = input.bool(true, "Enable",                         group=GRP_PW)
pwh_show  = input.bool(true, "Show High",                      group=GRP_PW)
pwl_show  = input.bool(true, "Show Low",                       group=GRP_PW)
pwh_color = input.color(color.new(#60a5fa, 0),  "High Color",  group=GRP_PW)
pwl_color = input.color(color.new(#f87171, 0),  "Low Color",   group=GRP_PW)
pw_width  = input.int(2, "Line Width", minval=1, maxval=4,     group=GRP_PW)
pw_labels = input.bool(true, "Show Labels",                    group=GRP_PW)

pw2_en     = input.bool(true, "Enable",                        group=GRP_PW2)
pwh2_show  = input.bool(true, "Show High",                     group=GRP_PW2)
pwl2_show  = input.bool(true, "Show Low",                      group=GRP_PW2)
pwh2_color = input.color(color.new(#60a5fa, 45), "High Color", group=GRP_PW2)
pwl2_color = input.color(color.new(#f87171, 45), "Low Color",  group=GRP_PW2)
pw2_width  = input.int(2, "Line Width", minval=1, maxval=4,    group=GRP_PW2)
pw2_labels = input.bool(true, "Show Labels",                   group=GRP_PW2)

// (Per-line visibility is resolved further down, once the effective level values
//  are known — in regular-hours mode a level can be unavailable.)

// ══════════════════════════════════════════════════════════════ INPUTS — MAs
var GRP_MA1 = "Moving Average 1"
var GRP_MA2 = "Moving Average 2"
var GRP_MA3 = "Moving Average 3"
var GRP_MA4 = "Moving Average 4"
var GRP_MA5 = "Moving Average 5"

ma_show_daily = input.bool(true, "Display on Daily", group="Moving Averages")

ma1_en  = input.bool(true,  "Enable",      group=GRP_MA1)
ma1_len = input.int(5,      "Length",      group=GRP_MA1, minval=1)
ma1_exp = input.bool(false, "Exponential", group=GRP_MA1)
ma1_col = input.color(color.new(#808080, 0), "Color",     group=GRP_MA1)
ma1_wid = input.int(1,      "Line Width",  group=GRP_MA1, minval=1, maxval=4)

ma2_en  = input.bool(true,  "Enable",      group=GRP_MA2)
ma2_len = input.int(10,     "Length",      group=GRP_MA2, minval=1)
ma2_exp = input.bool(false, "Exponential", group=GRP_MA2)
ma2_col = input.color(color.new(#808080, 0), "Color",     group=GRP_MA2)
ma2_wid = input.int(1,      "Line Width",  group=GRP_MA2, minval=1, maxval=4)

ma3_en  = input.bool(true,  "Enable",      group=GRP_MA3)
ma3_len = input.int(21,     "Length",      group=GRP_MA3, minval=1)
ma3_exp = input.bool(true,  "Exponential", group=GRP_MA3)
ma3_col = input.color(color.new(#ff00ff, 0), "Color",     group=GRP_MA3)
ma3_wid = input.int(1,      "Line Width",  group=GRP_MA3, minval=1, maxval=4)

ma4_en  = input.bool(true,  "Enable",      group=GRP_MA4)
ma4_len = input.int(50,     "Length",      group=GRP_MA4, minval=1)
ma4_exp = input.bool(false, "Exponential", group=GRP_MA4)
ma4_col = input.color(color.new(#ef4444, 0), "Color",     group=GRP_MA4)
ma4_wid = input.int(1,      "Line Width",  group=GRP_MA4, minval=1, maxval=4)

ma5_en  = input.bool(true,  "Enable",      group=GRP_MA5)
ma5_len = input.int(200,    "Length",      group=GRP_MA5, minval=1)
ma5_exp = input.bool(false, "Exponential", group=GRP_MA5)
ma5_col = input.color(color.new(#808080, 0), "Color",     group=GRP_MA5)
ma5_wid = input.int(1,      "Line Width",  group=GRP_MA5, minval=1, maxval=4)

// ══════════════════════════════════════════════════════════════ INPUTS — LABEL OFFSETS
// How far right of the last bar each label floats, in BARS — not pixels. The
// on-screen gap therefore scales with chart zoom. Give two groups different
// offsets to stagger them into separate columns when their prices sit close
// together; give them the same offset to line them up in one column.
// NOTE: labels beyond the last bar need chart room — if your "Bars to the right"
// margin is smaller than the offset, they'll sit off-screen until you scroll.
var GRP_LBL = "Label Offsets"
lbl_x_pd  = input.int(10, "Prior Day",       group=GRP_LBL, minval=1, maxval=200)
lbl_x_pd2 = input.int(10, "Prior Day -2",    group=GRP_LBL, minval=1, maxval=200)
lbl_x_pw  = input.int(10, "Prior Week",      group=GRP_LBL, minval=1, maxval=200)
lbl_x_pw2 = input.int(10, "Prior Week -2",   group=GRP_LBL, minval=1, maxval=200)
lbl_x_ma  = input.int(45, "Moving Averages", group=GRP_LBL, minval=1, maxval=200)

// ══════════════════════════════════════════════════════════════ HIGHER-TF DATA
// All same-timeframe requests are bundled into one tuple call each, so the whole
// indicator makes just 5 request.security() calls instead of 23 — security calls
// are the dominant cost in Pine, so this is the main performance lever.
// IMPORTANT: tuple destructuring is POSITIONAL. When editing a call, keep each
// name on the left aligned with its expression on the right (1:1, in order).

// ── Daily: prior-day & prior-day-2 levels + reference closes + weekday names ──
// Weekday is resolved inside the daily context so it names the actual session
// those levels came from (Friday, after a holiday Thursday, etc.) — not a
// calendar guess from the current bar.
// The "_n" suffix is the NATIVE session value — whatever the symbol's own daily
// bar spans. For futures that includes the overnight/Globex session; the
// regular-hours mode below overrides these.
[pdh_n, pdl_n, pdh2_n, pdl2_n, pdc_n, y1c, pd_dow_n, pd2_dow_n] = request.security(syminfo.tickerid, "D",
     [high[1], low[1], high[2], low[2], close[1], close[252],
      dayofweek(time[1], syminfo.timezone), dayofweek(time[2], syminfo.timezone)],
     lookahead=barmerge.lookahead_on)
//   pdh_n    pdl_n   pdh2_n    pdl2_n   pdc_n(Day Gain)  y1c(~1yr ago, 252 td)  pd_dow_n  pd2_dow_n

// ── Weekly: prior-week & prior-week-2 levels + reference close ──
[pwh_n, pwl_n, pwh2_n, pwl2_n, pwc] = request.security(syminfo.tickerid, "W",
     [high[1], low[1], high[2], low[2], close[1]],
     lookahead=barmerge.lookahead_on)
//   pwh_n    pwl_n   pwh2_n    pwl2_n   pwc(Week Gain)

// ── Monthly / yearly reference closes ──
pmc = request.security(syminfo.tickerid, "M",   close[1], lookahead=barmerge.lookahead_on)  // prior month close → Month Gain
pyc = request.security(syminfo.tickerid, "12M", close[1], lookahead=barmerge.lookahead_on)  // prior year close  → YTD Gain

// ══════════════════════════════════════════════════════════════ DAILY MAs
// One tuple request for all 5 MAs. Each MA contributes a pair:
//   *_raw = today's forming daily bar (locked into *_val on bar close below)
//   *_d1  = yesterday's confirmed daily value (for slope direction)
[ma1_raw, ma1_d1, ma2_raw, ma2_d1, ma3_raw, ma3_d1, ma4_raw, ma4_d1, ma5_raw, ma5_d1] = request.security(syminfo.tickerid, "D",
       [ma1_exp ? ta.ema(close, ma1_len) : ta.sma(close, ma1_len), (ma1_exp ? ta.ema(close, ma1_len) : ta.sma(close, ma1_len))[1],
        ma2_exp ? ta.ema(close, ma2_len) : ta.sma(close, ma2_len), (ma2_exp ? ta.ema(close, ma2_len) : ta.sma(close, ma2_len))[1],
        ma3_exp ? ta.ema(close, ma3_len) : ta.sma(close, ma3_len), (ma3_exp ? ta.ema(close, ma3_len) : ta.sma(close, ma3_len))[1],
        ma4_exp ? ta.ema(close, ma4_len) : ta.sma(close, ma4_len), (ma4_exp ? ta.ema(close, ma4_len) : ta.sma(close, ma4_len))[1],
        ma5_exp ? ta.ema(close, ma5_len) : ta.sma(close, ma5_len), (ma5_exp ? ta.ema(close, ma5_len) : ta.sma(close, ma5_len))[1]],
     lookahead=barmerge.lookahead_on)

var float ma1_val = na
var float ma2_val = na
var float ma3_val = na
var float ma4_val = na
var float ma5_val = na

if barstate.isconfirmed
    ma1_val := ma1_raw
    ma2_val := ma2_raw
    ma3_val := ma3_raw
    ma4_val := ma4_raw
    ma5_val := ma5_raw

// ══════════════════════════════════════════════════════════════ REGULAR-HOURS SESSION TRACKING
// Only does work when "Enforce Regular Hours Only" is on.
//
// Levels are accumulated bar-by-bar from the chart's own data because
// request.security() cannot be handed an arbitrary session window —
// ticker.modify() accepts only session.regular / session.extended, and for CME
// futures "regular" is already the full ~23h Globex session, so it wouldn't help.
//
// LIMITATION: this only sees bars actually loaded on the chart. Prior day and
// day -2 need ~2 sessions and are always fine. Prior week -2 needs ~10 sessions,
// which a 1-minute chart may not load. Any level that can't be built yet stays
// na and simply isn't drawn, rather than drawing something wrong.

rth_active = rth_only and timeframe.isintraday
in_sess    = rth_active and not na(time(timeframe.period, rth_sess, rth_tz))
sess_start = in_sess and not in_sess[1]

var float rth_cur_h   = na   // developing session
var float rth_cur_l   = na
var int   rth_cur_dow = na
var float rth_d1_h    = na   // prior session
var float rth_d1_l    = na
var float rth_d1_c    = na   // its closing price → Day Gain reference
var int   rth_d1_dow  = na
var float rth_d2_h    = na   // the session before that
var float rth_d2_l    = na
var int   rth_d2_dow  = na
var float rth_sess_c  = na   // running last in-session close

var float rth_wcur_h  = na   // developing week
var float rth_wcur_l  = na
var float rth_w1_h    = na   // prior week
var float rth_w1_l    = na
var float rth_w2_h    = na   // the week before that
var float rth_w2_l    = na
var int   rth_week    = na

bool rth_new_week = false

if sess_start
    // ── Roll the day tier: current → prior → prior-2 ──
    rth_d2_h    := rth_d1_h
    rth_d2_l    := rth_d1_l
    rth_d2_dow  := rth_d1_dow
    rth_d1_h    := rth_cur_h
    rth_d1_l    := rth_cur_l
    rth_d1_dow  := rth_cur_dow
    rth_d1_c    := rth_sess_c          // captured before rth_sess_c advances below
    rth_cur_h   := high
    rth_cur_l   := low
    rth_cur_dow := dayofweek(time, rth_tz)

    // ── Roll the week tier on the first session of a new week ──
    int wk = weekofyear(time, rth_tz)
    if na(rth_week) or wk != rth_week
        rth_new_week := true
        rth_w2_h   := rth_w1_h
        rth_w2_l   := rth_w1_l
        rth_w1_h   := rth_wcur_h
        rth_w1_l   := rth_wcur_l
        rth_wcur_h := high
        rth_wcur_l := low
        rth_week   := wk
    else
        rth_wcur_h := na(rth_wcur_h) ? high : math.max(rth_wcur_h, high)
        rth_wcur_l := na(rth_wcur_l) ? low  : math.min(rth_wcur_l, low)
else if in_sess
    rth_cur_h  := na(rth_cur_h)  ? high : math.max(rth_cur_h,  high)
    rth_cur_l  := na(rth_cur_l)  ? low  : math.min(rth_cur_l,  low)
    rth_wcur_h := na(rth_wcur_h) ? high : math.max(rth_wcur_h, high)
    rth_wcur_l := na(rth_wcur_l) ? low  : math.min(rth_wcur_l, low)

if in_sess
    rth_sess_c := close

// ══════════════════════════════════════════════════════════════ EFFECTIVE LEVEL VALUES
// The one place the regular-hours switch is resolved. Everything downstream —
// lines, labels, data box — reads these, so the two modes can't drift apart.
pdh_v     = rth_active ? rth_d1_h   : pdh_n
pdl_v     = rth_active ? rth_d1_l   : pdl_n
pdh2_v    = rth_active ? rth_d2_h   : pdh2_n
pdl2_v    = rth_active ? rth_d2_l   : pdl2_n
pwh_v     = rth_active ? rth_w1_h   : pwh_n
pwl_v     = rth_active ? rth_w1_l   : pwl_n
pwh2_v    = rth_active ? rth_w2_h   : pwh2_n
pwl2_v    = rth_active ? rth_w2_l   : pwl2_n
pdc_v     = rth_active ? rth_d1_c   : pdc_n
pd_dow_v  = rth_active ? rth_d1_dow : pd_dow_n
pd2_dow_v = rth_active ? rth_d2_dow : pd2_dow_n

// Per-line visibility: group toggle AND individual high/low toggle AND data
// present. The na check earns its keep in regular-hours mode, where a level is
// unavailable until enough sessions have loaded.
pdh_on  = pd_en  and pdh_show  and not na(pdh_v)
pdl_on  = pd_en  and pdl_show  and not na(pdl_v)
pdh2_on = pd2_en and pdh2_show and not na(pdh2_v)
pdl2_on = pd2_en and pdl2_show and not na(pdl2_v)
pwh_on  = pw_en  and pwh_show  and not na(pwh_v)
pwl_on  = pw_en  and pwl_show  and not na(pwl_v)
pwh2_on = pw2_en and pwh2_show and not na(pwh2_v)
pwl2_on = pw2_en and pwl2_show and not na(pwl2_v)

// ══════════════════════════════════════════════════════════════ LABEL HELPERS
f_pct(val) =>
    pct = (close - val) / val * 100
    (pct >= 0 ? "+" : "-") + str.tostring(math.abs(pct), "0.00") + "%"

f_lvl_txt(name, val) =>
    name + " (" + f_pct(val) + ")"

// Weekday abbreviation from a dayofweek() value; "" when the daily bar isn't
// available yet (short history), so callers can fall back to a static name.
f_dow(d) =>
    na(d) ? "" :
     d == dayofweek.monday    ? "MON" :
     d == dayofweek.tuesday   ? "TUE" :
     d == dayofweek.wednesday ? "WED" :
     d == dayofweek.thursday  ? "THU" :
     d == dayofweek.friday    ? "FRI" :
     d == dayofweek.saturday  ? "SAT" : "SUN"

// Prior day: weekday trails the percentage — "PRIOR DAY HIGH (-3.13%) MON"
f_lvl_txt_dow(name, val, d) =>
    n = f_dow(d)
    f_lvl_txt(name, val) + (n == "" ? "" : " " + n)

// Prior day -2: weekday replaces the name entirely — "FRI HIGH (-1.32%)"
f_dow_name(d, fallback) =>
    n = f_dow(d)
    n == "" ? fallback : n

f_ma_txt(len, is_exp, val) =>
    str.tostring(len) + "d " + (is_exp ? "EMA" : "SMA") + " (" + f_pct(val) + ")"

// Levels: single row per range — yellow inside, green above high, red below low
f_dot_range(lo, hi) =>
    close > hi ? "🟢" : close < lo ? "🔴" : "🟡"

f_dot_col_range(lo, hi) =>
    close > hi ? color.new(#22c55e, 0) : close < lo ? color.new(#ef4444, 0) : color.new(#f59e0b, 0)

f_pct_range(lo, hi) =>
    close > hi ? f_pct(hi) : close < lo ? f_pct(lo) : "Inside"

// MAs: yellow when price is within ±0.20% of the MA
f_dot_ma(level) =>
    na(level) ? "—" : math.abs(close - level) / level * 100 <= 0.20 ? "🟡" : close >= level ? "🟢" : "🔴"

f_dot_col_ma(level) =>
    na(level) ? color.new(#666666, 0) : math.abs(close - level) / level * 100 <= 0.20 ? color.new(#f59e0b, 0) : close >= level ? color.new(#22c55e, 0) : color.new(#ef4444, 0)

// ── Tooltip helpers ──────────────────────────────────────────────────────
f_price(val) =>
    str.tostring(val, "0.00")

f_tt_dot_range(name, lo, hi) =>
    close > hi ? "Price is above the " + name + " range (" + f_pct(hi) + " above the high)" :
     close < lo ? "Price is below the " + name + " range (" + f_pct(lo) + " below the low)" :
     "Price is inside the " + name + " range"

f_tt_lbl_range(name, lo, hi) =>
    name + "  ·  High: " + f_price(hi) + "  Low: " + f_price(lo)

f_tt_pct_range(name, lo, hi) =>
    close > hi ? f_pct(hi) + " above the " + name + " high (" + f_price(hi) + ")" :
     close < lo ? f_pct(lo) + " below the " + name + " low (" + f_price(lo) + ")" :
     "Price is inside the " + name + " range"

f_tt_dot_ma(len, is_exp, val) =>
    t = is_exp ? "EMA" : "SMA"
    n = str.tostring(len) + "d " + t
    math.abs(close - val) / val * 100 <= 0.20 ?
     "Within ±0.20% of the " + n + " — actively testing this level" :
     close >= val ? "Price is " + f_pct(val) + " above the " + n :
     "Price is " + f_pct(val) + " below the " + n

f_tt_lbl_ma(len, is_exp, val) =>
    t = is_exp ? "EMA" : "SMA"
    str.tostring(len) + "d Daily " + t + "  ·  Current value: " + f_price(val)

f_tt_pct_ma(len, is_exp, val) =>
    t = is_exp ? "EMA" : "SMA"
    n = str.tostring(len) + "d " + t
    "Price is " + f_pct(val) + " from the " + n + " (" + f_price(val) + ")"

f_tt_slope(len, is_exp, val, prev) =>
    t = is_exp ? "EMA" : "SMA"
    n = str.tostring(len) + "d " + t
    val > prev ? n + " is sloping up" : n + " is sloping down"

// ── Gain helpers ─────────────────────────────────────────────────────────
// Gain = current price vs a prior-period reference close.
f_gain_dot(ref) =>
    na(ref) ? "—" : close >= ref ? "🟢" : "🔴"

f_gain_col(ref) =>
    na(ref) ? color.new(#cccccc, 0) : close >= ref ? color.new(#22c55e, 0) : color.new(#ef4444, 0)

f_tt_gain(name, ref) =>
    na(ref) ? name + " — no data available" :
     name + "  ·  vs reference close " + f_price(ref) + "  (" + f_pct(ref) + ")"

// ══════════════════════════════════════════════════════════════ LINE OBJECTS
var line l_pdh  = na
var line l_pdl  = na
var line l_pwh  = na
var line l_pwl  = na
var line l_pdh2 = na
var line l_pdl2 = na
var line l_pwh2 = na
var line l_pwl2 = na
var line l_ma1  = na
var line l_ma2  = na
var line l_ma3  = na
var line l_ma4  = na
var line l_ma5  = na
var label lb_pdh = na
var label lb_pdl = na
var label lb_pwh = na
var label lb_pwl = na
var label lb_pdh2 = na
var label lb_pdl2 = na
var label lb_pwh2 = na
var label lb_pwl2 = na
var label lb_ma1 = na
var label lb_ma2 = na
var label lb_ma3 = na
var label lb_ma4 = na
var label lb_ma5 = na

var int day_open_bar = na
var int ma_start_bar = na  // label anchor = prior day open

// ── New day: redraw all lines and labels ─────────────────────────────────
// In regular-hours mode the redraw is driven by the session window, not the
// symbol's daily bar — otherwise on futures the lines would re-anchor at the
// 18:00 Globex open instead of the 09:30 cash open.
new_day  = timeframe.isintraday and (rth_active ? sess_start   : ta.change(time("D")) != 0)
new_week = timeframe.isintraday and (rth_active ? rth_new_week : ta.change(time("W")) != 0)

if new_day
    line.delete(l_pdh),  line.delete(l_pdl)
    line.delete(l_pdh2), line.delete(l_pdl2)
    line.delete(l_ma1),  line.delete(l_ma2),  line.delete(l_ma3)
    line.delete(l_ma4),  line.delete(l_ma5)
    label.delete(lb_pdh), label.delete(lb_pdl)
    label.delete(lb_pdh2), label.delete(lb_pdl2)
    label.delete(lb_ma1), label.delete(lb_ma2), label.delete(lb_ma3)
    label.delete(lb_ma4), label.delete(lb_ma5)

    int label_start = na(day_open_bar) ? bar_index : day_open_bar
    ma_start_bar   := label_start

    // Level lines start at prior day open
    if pdh_on
        l_pdh := line.new(label_start, pdh_v, bar_index + 1, pdh_v,
                          extend=extend.right, color=pdh_color, width=pd_width, style=line.style_solid)
        if pd_labels
            lb_pdh := label.new(bar_index + lbl_x_pd, pdh_v, f_lvl_txt_dow("PRIOR DAY HIGH", pdh_v, pd_dow_v),
                                color=color.new(color.black, 0),
                                textcolor=pdh_color, style=label.style_label_left, size=size.small)
    if pdl_on
        l_pdl := line.new(label_start, pdl_v, bar_index + 1, pdl_v,
                          extend=extend.right, color=pdl_color, width=pd_width, style=line.style_solid)
        if pd_labels
            lb_pdl := label.new(bar_index + lbl_x_pd, pdl_v, f_lvl_txt_dow("PRIOR DAY LOW", pdl_v, pd_dow_v),
                                color=color.new(color.black, 0),
                                textcolor=pdl_color, style=label.style_label_left, size=size.small)

    // Prior day -2 levels (dashed)
    if pdh2_on
        l_pdh2 := line.new(label_start, pdh2_v, bar_index + 1, pdh2_v,
                           extend=extend.right, color=pdh2_color, width=pd2_width, style=line.style_dashed)
        if pd2_labels
            lb_pdh2 := label.new(bar_index + lbl_x_pd2, pdh2_v, f_lvl_txt(f_dow_name(pd2_dow_v, "PRIOR DAY -2") + " HIGH", pdh2_v),
                                 color=color.new(color.black, 0),
                                 textcolor=pdh2_color, style=label.style_label_left, size=size.small)
    if pdl2_on
        l_pdl2 := line.new(label_start, pdl2_v, bar_index + 1, pdl2_v,
                           extend=extend.right, color=pdl2_color, width=pd2_width, style=line.style_dashed)
        if pd2_labels
            lb_pdl2 := label.new(bar_index + lbl_x_pd2, pdl2_v, f_lvl_txt(f_dow_name(pd2_dow_v, "PRIOR DAY -2") + " LOW", pdl2_v),
                                 color=color.new(color.black, 0),
                                 textcolor=pdl2_color, style=label.style_label_left, size=size.small)

    // MA labels float at the right edge, staggered into a second column past the
    // level labels so the two don't collide when an MA sits near a level.
    if ma1_en
        lb_ma1 := label.new(bar_index + lbl_x_ma, ma1_val, f_ma_txt(ma1_len, ma1_exp, ma1_val),
                            color=color.new(color.black, 0), textcolor=ma1_col, style=label.style_label_left, size=size.small)
        l_ma1  := line.new(bar_index, ma1_val, bar_index + 1, ma1_val,
                           extend=extend.right, color=ma1_col, width=ma1_wid, style=line.style_solid)
    if ma2_en
        lb_ma2 := label.new(bar_index + lbl_x_ma, ma2_val, f_ma_txt(ma2_len, ma2_exp, ma2_val),
                            color=color.new(color.black, 0), textcolor=ma2_col, style=label.style_label_left, size=size.small)
        l_ma2  := line.new(bar_index, ma2_val, bar_index + 1, ma2_val,
                           extend=extend.right, color=ma2_col, width=ma2_wid, style=line.style_solid)
    if ma3_en
        lb_ma3 := label.new(bar_index + lbl_x_ma, ma3_val, f_ma_txt(ma3_len, ma3_exp, ma3_val),
                            color=color.new(color.black, 0), textcolor=ma3_col, style=label.style_label_left, size=size.small)
        l_ma3  := line.new(bar_index, ma3_val, bar_index + 1, ma3_val,
                           extend=extend.right, color=ma3_col, width=ma3_wid, style=line.style_solid)
    if ma4_en
        lb_ma4 := label.new(bar_index + lbl_x_ma, ma4_val, f_ma_txt(ma4_len, ma4_exp, ma4_val),
                            color=color.new(color.black, 0), textcolor=ma4_col, style=label.style_label_left, size=size.small)
        l_ma4  := line.new(bar_index, ma4_val, bar_index + 1, ma4_val,
                           extend=extend.right, color=ma4_col, width=ma4_wid, style=line.style_solid)
    if ma5_en
        lb_ma5 := label.new(bar_index + lbl_x_ma, ma5_val, f_ma_txt(ma5_len, ma5_exp, ma5_val),
                            color=color.new(color.black, 0), textcolor=ma5_col, style=label.style_label_left, size=size.small)
        l_ma5  := line.new(bar_index, ma5_val, bar_index + 1, ma5_val,
                           extend=extend.right, color=ma5_col, width=ma5_wid, style=line.style_solid)

    day_open_bar := bar_index

// ── Each bar close: update MA line prices to follow the daily value ───────
if timeframe.isintraday and barstate.isconfirmed
    if pd_en and pd_labels
        if pdh_on and not na(lb_pdh)
            label.set_x(lb_pdh, bar_index + lbl_x_pd)
            label.set_text(lb_pdh, f_lvl_txt_dow("PRIOR DAY HIGH", pdh_v, pd_dow_v))
        if pdl_on and not na(lb_pdl)
            label.set_x(lb_pdl, bar_index + lbl_x_pd)
            label.set_text(lb_pdl, f_lvl_txt_dow("PRIOR DAY LOW", pdl_v, pd_dow_v))
    if pd2_en and pd2_labels
        if pdh2_on and not na(lb_pdh2)
            label.set_x(lb_pdh2, bar_index + lbl_x_pd2)
            label.set_text(lb_pdh2, f_lvl_txt(f_dow_name(pd2_dow_v, "PRIOR DAY -2") + " HIGH", pdh2_v))
        if pdl2_on and not na(lb_pdl2)
            label.set_x(lb_pdl2, bar_index + lbl_x_pd2)
            label.set_text(lb_pdl2, f_lvl_txt(f_dow_name(pd2_dow_v, "PRIOR DAY -2") + " LOW", pdl2_v))
    if pw_en and pw_labels
        if pwh_on and not na(lb_pwh)
            label.set_x(lb_pwh, bar_index + lbl_x_pw)
            label.set_text(lb_pwh, f_lvl_txt("PRIOR WEEK HIGH", pwh_v))
        if pwl_on and not na(lb_pwl)
            label.set_x(lb_pwl, bar_index + lbl_x_pw)
            label.set_text(lb_pwl, f_lvl_txt("PRIOR WEEK LOW", pwl_v))
    if pw2_en and pw2_labels
        if pwh2_on and not na(lb_pwh2)
            label.set_x(lb_pwh2, bar_index + lbl_x_pw2)
            label.set_text(lb_pwh2, f_lvl_txt("2 WEEKS AGO HIGH", pwh2_v))
        if pwl2_on and not na(lb_pwl2)
            label.set_x(lb_pwl2, bar_index + lbl_x_pw2)
            label.set_text(lb_pwl2, f_lvl_txt("2 WEEKS AGO LOW", pwl2_v))
    if ma1_en and not na(l_ma1)
        line.set_y1(l_ma1, ma1_val), line.set_y2(l_ma1, ma1_val)
        label.set_xy(lb_ma1, bar_index + lbl_x_ma, ma1_val)
        label.set_text(lb_ma1, f_ma_txt(ma1_len, ma1_exp, ma1_val))
    if ma2_en and not na(l_ma2)
        line.set_y1(l_ma2, ma2_val), line.set_y2(l_ma2, ma2_val)
        label.set_xy(lb_ma2, bar_index + lbl_x_ma, ma2_val)
        label.set_text(lb_ma2, f_ma_txt(ma2_len, ma2_exp, ma2_val))
    if ma3_en and not na(l_ma3)
        line.set_y1(l_ma3, ma3_val), line.set_y2(l_ma3, ma3_val)
        label.set_xy(lb_ma3, bar_index + lbl_x_ma, ma3_val)
        label.set_text(lb_ma3, f_ma_txt(ma3_len, ma3_exp, ma3_val))
    if ma4_en and not na(l_ma4)
        line.set_y1(l_ma4, ma4_val), line.set_y2(l_ma4, ma4_val)
        label.set_xy(lb_ma4, bar_index + lbl_x_ma, ma4_val)
        label.set_text(lb_ma4, f_ma_txt(ma4_len, ma4_exp, ma4_val))
    if ma5_en and not na(l_ma5)
        line.set_y1(l_ma5, ma5_val), line.set_y2(l_ma5, ma5_val)
        label.set_xy(lb_ma5, bar_index + lbl_x_ma, ma5_val)
        label.set_text(lb_ma5, f_ma_txt(ma5_len, ma5_exp, ma5_val))

// ── New week: redraw prior-week lines ────────────────────────────────────
if new_week
    line.delete(l_pwh)
    line.delete(l_pwl)
    line.delete(l_pwh2)
    line.delete(l_pwl2)
    label.delete(lb_pwh)
    label.delete(lb_pwl)
    label.delete(lb_pwh2)
    label.delete(lb_pwl2)

    int start = na(day_open_bar) ? bar_index : day_open_bar

    if pwh_on
        l_pwh := line.new(start, pwh_v, bar_index + 1, pwh_v,
                          extend=extend.right, color=pwh_color, width=pw_width, style=line.style_solid)
        if pw_labels
            lb_pwh := label.new(bar_index + lbl_x_pw, pwh_v, f_lvl_txt("PRIOR WEEK HIGH", pwh_v),
                                color=color.new(color.black, 0),
                                textcolor=pwh_color, style=label.style_label_left, size=size.small)
    if pwl_on
        l_pwl := line.new(start, pwl_v, bar_index + 1, pwl_v,
                          extend=extend.right, color=pwl_color, width=pw_width, style=line.style_solid)
        if pw_labels
            lb_pwl := label.new(bar_index + lbl_x_pw, pwl_v, f_lvl_txt("PRIOR WEEK LOW", pwl_v),
                                color=color.new(color.black, 0),
                                textcolor=pwl_color, style=label.style_label_left, size=size.small)

    // Prior week -2 levels (dashed)
    if pwh2_on
        l_pwh2 := line.new(start, pwh2_v, bar_index + 1, pwh2_v,
                           extend=extend.right, color=pwh2_color, width=pw2_width, style=line.style_dashed)
        if pw2_labels
            lb_pwh2 := label.new(bar_index + lbl_x_pw2, pwh2_v, f_lvl_txt("2 WEEKS AGO HIGH", pwh2_v),
                                 color=color.new(color.black, 0),
                                 textcolor=pwh2_color, style=label.style_label_left, size=size.small)
    if pwl2_on
        l_pwl2 := line.new(start, pwl2_v, bar_index + 1, pwl2_v,
                           extend=extend.right, color=pwl2_color, width=pw2_width, style=line.style_dashed)
        if pw2_labels
            lb_pwl2 := label.new(bar_index + lbl_x_pw2, pwl2_v, f_lvl_txt("2 WEEKS AGO LOW", pwl2_v),
                                 color=color.new(color.black, 0),
                                 textcolor=pwl2_color, style=label.style_label_left, size=size.small)

// ══════════════════════════════════════════════════════════════ PLOT MAs (daily/weekly only)
ma1_plot = ma1_exp ? ta.ema(close, ma1_len) : ta.sma(close, ma1_len)
ma2_plot = ma2_exp ? ta.ema(close, ma2_len) : ta.sma(close, ma2_len)
ma3_plot = ma3_exp ? ta.ema(close, ma3_len) : ta.sma(close, ma3_len)
ma4_plot = ma4_exp ? ta.ema(close, ma4_len) : ta.sma(close, ma4_len)
ma5_plot = ma5_exp ? ta.ema(close, ma5_len) : ta.sma(close, ma5_len)

plot(ma1_en and ma_show_daily and timeframe.isdaily ? ma1_plot : na, title="MA1", color=ma1_col, linewidth=ma1_wid, display=display.pane)
plot(ma2_en and ma_show_daily and timeframe.isdaily ? ma2_plot : na, title="MA2", color=ma2_col, linewidth=ma2_wid, display=display.pane)
plot(ma3_en and ma_show_daily and timeframe.isdaily ? ma3_plot : na, title="MA3", color=ma3_col, linewidth=ma3_wid, display=display.pane)
plot(ma4_en and ma_show_daily and timeframe.isdaily ? ma4_plot : na, title="MA4", color=ma4_col, linewidth=ma4_wid, display=display.pane)
plot(ma5_en and ma_show_daily and timeframe.isdaily ? ma5_plot : na, title="MA5", color=ma5_col, linewidth=ma5_wid, display=display.pane)

// ══════════════════════════════════════════════════════════════ DATA BOX (intraday)
var table t_box = na

if timeframe.isintraday and (show_position or show_performance)
    if na(t_box)
        t_box := table.new(position.top_right, 4, 14,
                           bgcolor=color.new(#0f0f0f, 15),
                           frame_color=color.new(#555555, 0), frame_width=1,
                           border_color=color.new(#2a2a2a, 0), border_width=1)

    if barstate.isconfirmed
        BG   = color.new(#0f0f0f, 15)
        TXT  = color.new(#cccccc, 0)
        UP   = color.new(#22c55e, 0)
        DN   = color.new(#ef4444, 0)
        HDR  = color.new(#2a2a2a, 0)

        if show_position
            // ── Divider: POSITION ──
            table.cell(t_box, 0, 0, "",         bgcolor=HDR, text_size=size.small)
            table.cell(t_box, 1, 0, "POSITION", bgcolor=HDR, text_color=color.new(#999999, 0), text_size=size.small, text_halign=text.align_left)
            table.cell(t_box, 2, 0, "",            bgcolor=HDR, text_size=size.small)
            table.cell(t_box, 3, 0, "",            bgcolor=HDR, text_size=size.small)
            // Prior Day
            table.cell(t_box, 0, 1, f_dot_range(pdl_v, pdh_v), bgcolor=BG, text_size=size.small, text_halign=text.align_center, tooltip=f_tt_dot_range("Prior Day", pdl_v, pdh_v))
            table.cell(t_box, 1, 1, "Prior Day",            bgcolor=BG, text_color=TXT, text_size=size.small, text_halign=text.align_left,   tooltip=f_tt_lbl_range("Prior Day", pdl_v, pdh_v))
            table.cell(t_box, 2, 1, f_pct_range(pdl_v, pdh_v), bgcolor=BG, text_color=f_dot_col_range(pdl_v, pdh_v), text_size=size.small, text_halign=text.align_right)
            table.cell(t_box, 3, 1, "",                     bgcolor=BG, text_size=size.small)
            // Prior Week
            table.cell(t_box, 0, 2, f_dot_range(pwl_v, pwh_v), bgcolor=BG, text_size=size.small, text_halign=text.align_center, tooltip=f_tt_dot_range("Prior Week", pwl_v, pwh_v))
            table.cell(t_box, 1, 2, "Prior Week",           bgcolor=BG, text_color=TXT, text_size=size.small, text_halign=text.align_left,   tooltip=f_tt_lbl_range("Prior Week", pwl_v, pwh_v))
            table.cell(t_box, 2, 2, f_pct_range(pwl_v, pwh_v), bgcolor=BG, text_color=f_dot_col_range(pwl_v, pwh_v), text_size=size.small, text_halign=text.align_right)
            table.cell(t_box, 3, 2, "",                     bgcolor=BG, text_size=size.small)
            // MA 1
            table.cell(t_box, 0, 3, ma1_en ? f_dot_ma(ma1_val) : "—", bgcolor=BG, text_size=size.small, text_halign=text.align_center, tooltip=ma1_en ? f_tt_dot_ma(ma1_len, ma1_exp, ma1_val) : "")
            table.cell(t_box, 1, 3, str.tostring(ma1_len) + "d " + (ma1_exp ? "EMA" : "SMA"), bgcolor=BG, text_color=TXT, text_size=size.small, text_halign=text.align_left, tooltip=ma1_en ? f_tt_lbl_ma(ma1_len, ma1_exp, ma1_val) : "")
            table.cell(t_box, 2, 3, ma1_en ? f_pct(ma1_val) : "—", bgcolor=BG, text_color=ma1_en ? f_dot_col_ma(ma1_val) : TXT, text_size=size.small, text_halign=text.align_right)
            table.cell(t_box, 3, 3, ma1_en ? (ma1_val > ma1_d1 ? "▲" : "▼") : "", bgcolor=BG, text_color=ma1_en ? (ma1_val > ma1_d1 ? UP : DN) : TXT, text_size=size.small, text_halign=text.align_center, tooltip=ma1_en ? f_tt_slope(ma1_len, ma1_exp, ma1_val, ma1_d1) : "")
            // MA 2
            table.cell(t_box, 0, 4, ma2_en ? f_dot_ma(ma2_val) : "—", bgcolor=BG, text_size=size.small, text_halign=text.align_center, tooltip=ma2_en ? f_tt_dot_ma(ma2_len, ma2_exp, ma2_val) : "")
            table.cell(t_box, 1, 4, str.tostring(ma2_len) + "d " + (ma2_exp ? "EMA" : "SMA"), bgcolor=BG, text_color=TXT, text_size=size.small, text_halign=text.align_left, tooltip=ma2_en ? f_tt_lbl_ma(ma2_len, ma2_exp, ma2_val) : "")
            table.cell(t_box, 2, 4, ma2_en ? f_pct(ma2_val) : "—", bgcolor=BG, text_color=ma2_en ? f_dot_col_ma(ma2_val) : TXT, text_size=size.small, text_halign=text.align_right)
            table.cell(t_box, 3, 4, ma2_en ? (ma2_val > ma2_d1 ? "▲" : "▼") : "", bgcolor=BG, text_color=ma2_en ? (ma2_val > ma2_d1 ? UP : DN) : TXT, text_size=size.small, text_halign=text.align_center, tooltip=ma2_en ? f_tt_slope(ma2_len, ma2_exp, ma2_val, ma2_d1) : "")
            // MA 3
            table.cell(t_box, 0, 5, ma3_en ? f_dot_ma(ma3_val) : "—", bgcolor=BG, text_size=size.small, text_halign=text.align_center, tooltip=ma3_en ? f_tt_dot_ma(ma3_len, ma3_exp, ma3_val) : "")
            table.cell(t_box, 1, 5, str.tostring(ma3_len) + "d " + (ma3_exp ? "EMA" : "SMA"), bgcolor=BG, text_color=TXT, text_size=size.small, text_halign=text.align_left, tooltip=ma3_en ? f_tt_lbl_ma(ma3_len, ma3_exp, ma3_val) : "")
            table.cell(t_box, 2, 5, ma3_en ? f_pct(ma3_val) : "—", bgcolor=BG, text_color=ma3_en ? f_dot_col_ma(ma3_val) : TXT, text_size=size.small, text_halign=text.align_right)
            table.cell(t_box, 3, 5, ma3_en ? (ma3_val > ma3_d1 ? "▲" : "▼") : "", bgcolor=BG, text_color=ma3_en ? (ma3_val > ma3_d1 ? UP : DN) : TXT, text_size=size.small, text_halign=text.align_center, tooltip=ma3_en ? f_tt_slope(ma3_len, ma3_exp, ma3_val, ma3_d1) : "")
            // MA 4
            table.cell(t_box, 0, 6, ma4_en ? f_dot_ma(ma4_val) : "—", bgcolor=BG, text_size=size.small, text_halign=text.align_center, tooltip=ma4_en ? f_tt_dot_ma(ma4_len, ma4_exp, ma4_val) : "")
            table.cell(t_box, 1, 6, str.tostring(ma4_len) + "d " + (ma4_exp ? "EMA" : "SMA"), bgcolor=BG, text_color=TXT, text_size=size.small, text_halign=text.align_left, tooltip=ma4_en ? f_tt_lbl_ma(ma4_len, ma4_exp, ma4_val) : "")
            table.cell(t_box, 2, 6, ma4_en ? f_pct(ma4_val) : "—", bgcolor=BG, text_color=ma4_en ? f_dot_col_ma(ma4_val) : TXT, text_size=size.small, text_halign=text.align_right)
            table.cell(t_box, 3, 6, ma4_en ? (ma4_val > ma4_d1 ? "▲" : "▼") : "", bgcolor=BG, text_color=ma4_en ? (ma4_val > ma4_d1 ? UP : DN) : TXT, text_size=size.small, text_halign=text.align_center, tooltip=ma4_en ? f_tt_slope(ma4_len, ma4_exp, ma4_val, ma4_d1) : "")
            // MA 5
            table.cell(t_box, 0, 7, ma5_en ? f_dot_ma(ma5_val) : "—", bgcolor=BG, text_size=size.small, text_halign=text.align_center, tooltip=ma5_en ? f_tt_dot_ma(ma5_len, ma5_exp, ma5_val) : "")
            table.cell(t_box, 1, 7, str.tostring(ma5_len) + "d " + (ma5_exp ? "EMA" : "SMA"), bgcolor=BG, text_color=TXT, text_size=size.small, text_halign=text.align_left, tooltip=ma5_en ? f_tt_lbl_ma(ma5_len, ma5_exp, ma5_val) : "")
            table.cell(t_box, 2, 7, ma5_en ? f_pct(ma5_val) : "—", bgcolor=BG, text_color=ma5_en ? f_dot_col_ma(ma5_val) : TXT, text_size=size.small, text_halign=text.align_right)
            table.cell(t_box, 3, 7, ma5_en ? (ma5_val > ma5_d1 ? "▲" : "▼") : "", bgcolor=BG, text_color=ma5_en ? (ma5_val > ma5_d1 ? UP : DN) : TXT, text_size=size.small, text_halign=text.align_center, tooltip=ma5_en ? f_tt_slope(ma5_len, ma5_exp, ma5_val, ma5_d1) : "")

        // PERFORMANCE section — slides up to row 0 when POSITION is hidden
        if show_performance
            int perf = show_position ? 8 : 0
            // ── Divider: PERFORMANCE ──
            table.cell(t_box, 0, perf, "",            bgcolor=HDR, text_size=size.small)
            table.cell(t_box, 1, perf, "PERFORMANCE", bgcolor=HDR, text_color=color.new(#999999, 0), text_size=size.small, text_halign=text.align_left)
            table.cell(t_box, 2, perf, "",            bgcolor=HDR, text_size=size.small)
            table.cell(t_box, 3, perf, "",            bgcolor=HDR, text_size=size.small)
            // Day Gain
            table.cell(t_box, 0, perf + 1, f_gain_dot(pdc_v), bgcolor=BG, text_size=size.small, text_halign=text.align_center, tooltip=f_tt_gain("Day Gain", pdc_v))
            table.cell(t_box, 1, perf + 1, "Day Gain",      bgcolor=BG, text_color=TXT, text_size=size.small, text_halign=text.align_left, tooltip=f_tt_gain("Day Gain", pdc_v))
            table.cell(t_box, 2, perf + 1, na(pdc_v) ? "—" : f_pct(pdc_v), bgcolor=BG, text_color=f_gain_col(pdc_v), text_size=size.small, text_halign=text.align_right)
            table.cell(t_box, 3, perf + 1, "",              bgcolor=BG, text_size=size.small)
            // Week Gain
            table.cell(t_box, 0, perf + 2, f_gain_dot(pwc), bgcolor=BG, text_size=size.small, text_halign=text.align_center, tooltip=f_tt_gain("Week Gain", pwc))
            table.cell(t_box, 1, perf + 2, "Week Gain",     bgcolor=BG, text_color=TXT, text_size=size.small, text_halign=text.align_left, tooltip=f_tt_gain("Week Gain", pwc))
            table.cell(t_box, 2, perf + 2, na(pwc) ? "—" : f_pct(pwc), bgcolor=BG, text_color=f_gain_col(pwc), text_size=size.small, text_halign=text.align_right)
            table.cell(t_box, 3, perf + 2, "",              bgcolor=BG, text_size=size.small)
            // Month Gain
            table.cell(t_box, 0, perf + 3, f_gain_dot(pmc), bgcolor=BG, text_size=size.small, text_halign=text.align_center, tooltip=f_tt_gain("Month Gain", pmc))
            table.cell(t_box, 1, perf + 3, "Month Gain",    bgcolor=BG, text_color=TXT, text_size=size.small, text_halign=text.align_left, tooltip=f_tt_gain("Month Gain", pmc))
            table.cell(t_box, 2, perf + 3, na(pmc) ? "—" : f_pct(pmc), bgcolor=BG, text_color=f_gain_col(pmc), text_size=size.small, text_halign=text.align_right)
            table.cell(t_box, 3, perf + 3, "",              bgcolor=BG, text_size=size.small)
            // YTD Gain
            table.cell(t_box, 0, perf + 4, f_gain_dot(pyc), bgcolor=BG, text_size=size.small, text_halign=text.align_center, tooltip=f_tt_gain("YTD Gain", pyc))
            table.cell(t_box, 1, perf + 4, "YTD Gain",      bgcolor=BG, text_color=TXT, text_size=size.small, text_halign=text.align_left, tooltip=f_tt_gain("YTD Gain", pyc))
            table.cell(t_box, 2, perf + 4, na(pyc) ? "—" : f_pct(pyc), bgcolor=BG, text_color=f_gain_col(pyc), text_size=size.small, text_halign=text.align_right)
            table.cell(t_box, 3, perf + 4, "",              bgcolor=BG, text_size=size.small)
            // 1-Year Gain
            table.cell(t_box, 0, perf + 5, f_gain_dot(y1c), bgcolor=BG, text_size=size.small, text_halign=text.align_center, tooltip=f_tt_gain("1-Year Gain", y1c))
            table.cell(t_box, 1, perf + 5, "1-Year Gain",   bgcolor=BG, text_color=TXT, text_size=size.small, text_halign=text.align_left, tooltip=f_tt_gain("1-Year Gain", y1c))
            table.cell(t_box, 2, perf + 5, na(y1c) ? "—" : f_pct(y1c), bgcolor=BG, text_color=f_gain_col(y1c), text_size=size.small, text_halign=text.align_right)
            table.cell(t_box, 3, perf + 5, "",              bgcolor=BG, text_size=size.small)
````
