# 900 S/R Scanner v4

- url: https://www.tradingview.com/script/n6uVxLuG-900-S-R-Scanner-v4/
- type: indicator
- pine_id: PUB;f4697999c7ca49bebc2271f90ee34a23
- version: 1.0

## Description

support and resistance tool , that i made for myself , its show the 900 moving average on different time frames live.
just first tool that made if you have update suggestions write a comment

## Source Code

````pine
// @version=6
// 900 MA Support/Resistance Scanner v4
// =====================================
// Detects when the 900 MA acts as actual SUPPORT or RESISTANCE, not just a
// near-miss "touch". The logic is the classic price-action confirmation:
//
//   SUPPORT HOLD     = bar's low pierces/touches the MA from above,
//                      bar's close stays above the MA  →  MA held as support
//
//   RESISTANCE HOLD  = bar's high pierces/touches the MA from below,
//                      bar's close stays below the MA  →  MA held as resistance
//
// Single-line statements only (avoids CE10156 errors).
//
// Setup:
//   1. Pine Editor → paste → Save → Add to chart.
//   2. Click the alarm-clock → Create Alert.
//      Condition: "900 S/R Scanner v4" → "Any alert() function call".
//      Notifications tab: tick "Show pop-up" + "Play sound", pick a sound.
//      Settings tab: Expiration = "Open-ended". Click Create.

indicator("900 S/R Scanner v4", overlay = true, max_bars_back = 1000)

// ============================================================================
// INPUTS
// ============================================================================
g_ma   = "Moving Average"
g_sig  = "Signal type"
g_sec  = "Seconds"
g_min  = "Minutes"
g_hr   = "Hours"
g_day  = "Days"
g_disp = "Display"

ma_length  = input.int(900, "MA length", minval = 1, group = g_ma)
ma_type    = input.string("SMA", "MA type", options = ["SMA", "EMA"], group = g_ma)

signal_mode = input.string("Either", "Signal mode", options = ["Support only", "Resistance only", "Either"], group = g_sig)
tol_pct_in  = input.float(0.1, "Wick tolerance (%)", minval = 0.0, step = 0.05, group = g_sig)
tol_pct     = tol_pct_in / 100.0

use_15s = input.bool(true,  "15s",  group = g_sec)
use_30s = input.bool(true,  "30s",  group = g_sec)
use_45s = input.bool(true,  "45s",  group = g_sec)
use_1m  = input.bool(true,  "1m",   group = g_min)
use_3m  = input.bool(true,  "3m",   group = g_min)
use_5m  = input.bool(true,  "5m",   group = g_min)
use_10m = input.bool(true,  "10m",  group = g_min)
use_15m = input.bool(true,  "15m",  group = g_min)
use_30m = input.bool(true,  "30m",  group = g_min)
use_45m = input.bool(true,  "45m",  group = g_min)
use_1h  = input.bool(true,  "1h",   group = g_hr)
use_2h  = input.bool(true,  "2h",   group = g_hr)
use_3h  = input.bool(true,  "3h",   group = g_hr)
use_4h  = input.bool(true,  "4h",   group = g_hr)
use_1d  = input.bool(false, "1D",   group = g_day)

banner_pos_str = input.string("top_center", "Live banner position", options = ["top_left", "top_center", "top_right", "bottom_left", "bottom_center", "bottom_right", "off"], group = g_disp)
table_pos_str  = input.string("middle_right", "Status table position", options = ["top_left", "top_center", "top_right", "middle_left", "middle_right", "bottom_left", "bottom_center", "bottom_right", "off"], group = g_disp)
show_history   = input.bool(true, "Mark history of S/R holds on chart", group = g_disp)

want_support    = signal_mode == "Support only"    or signal_mode == "Either"
want_resistance = signal_mode == "Resistance only" or signal_mode == "Either"

// ============================================================================
// HELPERS
// ============================================================================
f_ma(src, len, kind) => kind == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

// SUPPORT hold:    wick low pierces (or comes within tol of) MA from above, close stays above MA
f_support(h, l, c, ma_val, tol) => not na(ma_val) and l <= ma_val * (1 + tol) and c > ma_val

// RESISTANCE hold: wick high pierces (or comes within tol of) MA from below, close stays below MA
f_resistance(h, l, c, ma_val, tol) => not na(ma_val) and h >= ma_val * (1 - tol) and c < ma_val

// Multi-timeframe lookup: returns [ma_value, support_bool, resistance_bool]
f_check(tf) =>
    [h, l, c, m] = request.security(syminfo.tickerid, tf, [high, low, close, f_ma(close, ma_length, ma_type)], lookahead = barmerge.lookahead_off)
    [m, f_support(h, l, c, m, tol_pct), f_resistance(h, l, c, m, tol_pct)]

f_pos(s) =>
    p = position.bottom_right
    p := s == "top_left" ? position.top_left : p
    p := s == "top_center" ? position.top_center : p
    p := s == "top_right" ? position.top_right : p
    p := s == "middle_left" ? position.middle_left : p
    p := s == "middle_center" ? position.middle_center : p
    p := s == "middle_right" ? position.middle_right : p
    p := s == "bottom_left" ? position.bottom_left : p
    p := s == "bottom_center" ? position.bottom_center : p
    p

f_since(b) =>
    out = na(b) ? "—" : b == bar_index ? "NOW" : str.tostring(bar_index - b) + "b"
    out

f_signal_text(sup, res) =>
    out = sup and res ? "BOTH" : sup ? "SUP" : res ? "RES" : "—"
    out

f_signal_color(sup, res, enabled) =>
    c = color.new(color.gray, 60)
    c := not enabled ? color.new(color.gray, 80) : sup ? color.new(color.lime, 20) : res ? color.new(color.red, 20) : color.new(color.gray, 60)
    c

f_paint_hist(b, enabled) =>
    c = color.new(color.gray, 70)
    c := not enabled or na(b) ? color.new(color.gray, 80) : bar_index - b <= 5 ? color.new(color.orange, 40) : bar_index - b <= 50 ? color.new(color.gray, 50) : color.new(color.gray, 70)
    c

// ============================================================================
// CHART MA
// ============================================================================
ma_chart = f_ma(close, ma_length, ma_type)
plot(ma_chart, title = "900 MA", color = color.orange, linewidth = 2)

// ============================================================================
// MULTI-TIMEFRAME LOOKUPS
// ============================================================================
[m_15s, S_15s_raw, R_15s_raw] = f_check("15S")
[m_30s, S_30s_raw, R_30s_raw] = f_check("30S")
[m_45s, S_45s_raw, R_45s_raw] = f_check("45S")
[m_1m,  S_1m_raw,  R_1m_raw ] = f_check("1")
[m_3m,  S_3m_raw,  R_3m_raw ] = f_check("3")
[m_5m,  S_5m_raw,  R_5m_raw ] = f_check("5")
[m_10m, S_10m_raw, R_10m_raw] = f_check("10")
[m_15m, S_15m_raw, R_15m_raw] = f_check("15")
[m_30m, S_30m_raw, R_30m_raw] = f_check("30")
[m_45m, S_45m_raw, R_45m_raw] = f_check("45")
[m_1h,  S_1h_raw,  R_1h_raw ] = f_check("60")
[m_2h,  S_2h_raw,  R_2h_raw ] = f_check("120")
[m_3h,  S_3h_raw,  R_3h_raw ] = f_check("180")
[m_4h,  S_4h_raw,  R_4h_raw ] = f_check("240")
[m_1d,  S_1d_raw,  R_1d_raw ] = f_check("D")

// gate by signal mode + per-TF toggles
S_15s = use_15s and want_support    and S_15s_raw
R_15s = use_15s and want_resistance and R_15s_raw
S_30s = use_30s and want_support    and S_30s_raw
R_30s = use_30s and want_resistance and R_30s_raw
S_45s = use_45s and want_support    and S_45s_raw
R_45s = use_45s and want_resistance and R_45s_raw
S_1m  = use_1m  and want_support    and S_1m_raw
R_1m  = use_1m  and want_resistance and R_1m_raw
S_3m  = use_3m  and want_support    and S_3m_raw
R_3m  = use_3m  and want_resistance and R_3m_raw
S_5m  = use_5m  and want_support    and S_5m_raw
R_5m  = use_5m  and want_resistance and R_5m_raw
S_10m = use_10m and want_support    and S_10m_raw
R_10m = use_10m and want_resistance and R_10m_raw
S_15m = use_15m and want_support    and S_15m_raw
R_15m = use_15m and want_resistance and R_15m_raw
S_30m = use_30m and want_support    and S_30m_raw
R_30m = use_30m and want_resistance and R_30m_raw
S_45m = use_45m and want_support    and S_45m_raw
R_45m = use_45m and want_resistance and R_45m_raw
S_1h  = use_1h  and want_support    and S_1h_raw
R_1h  = use_1h  and want_resistance and R_1h_raw
S_2h  = use_2h  and want_support    and S_2h_raw
R_2h  = use_2h  and want_resistance and R_2h_raw
S_3h  = use_3h  and want_support    and S_3h_raw
R_3h  = use_3h  and want_resistance and R_3h_raw
S_4h  = use_4h  and want_support    and S_4h_raw
R_4h  = use_4h  and want_resistance and R_4h_raw
S_1d  = use_1d  and want_support    and S_1d_raw
R_1d  = use_1d  and want_resistance and R_1d_raw

// edge detection: only fire on bar where new signal first appears
ES_15s = S_15s and not S_15s[1]
ER_15s = R_15s and not R_15s[1]
ES_30s = S_30s and not S_30s[1]
ER_30s = R_30s and not R_30s[1]
ES_45s = S_45s and not S_45s[1]
ER_45s = R_45s and not R_45s[1]
ES_1m  = S_1m  and not S_1m[1]
ER_1m  = R_1m  and not R_1m[1]
ES_3m  = S_3m  and not S_3m[1]
ER_3m  = R_3m  and not R_3m[1]
ES_5m  = S_5m  and not S_5m[1]
ER_5m  = R_5m  and not R_5m[1]
ES_10m = S_10m and not S_10m[1]
ER_10m = R_10m and not R_10m[1]
ES_15m = S_15m and not S_15m[1]
ER_15m = R_15m and not R_15m[1]
ES_30m = S_30m and not S_30m[1]
ER_30m = R_30m and not R_30m[1]
ES_45m = S_45m and not S_45m[1]
ER_45m = R_45m and not R_45m[1]
ES_1h  = S_1h  and not S_1h[1]
ER_1h  = R_1h  and not R_1h[1]
ES_2h  = S_2h  and not S_2h[1]
ER_2h  = R_2h  and not R_2h[1]
ES_3h  = S_3h  and not S_3h[1]
ER_3h  = R_3h  and not R_3h[1]
ES_4h  = S_4h  and not S_4h[1]
ER_4h  = R_4h  and not R_4h[1]
ES_1d  = S_1d  and not S_1d[1]
ER_1d  = R_1d  and not R_1d[1]

// ============================================================================
// HISTORY: remember bar_index of last S or R signal per TF
// ============================================================================
var int b_15s = na, var int b_30s = na, var int b_45s = na
var int b_1m  = na, var int b_3m  = na, var int b_5m  = na
var int b_10m = na, var int b_15m = na, var int b_30m = na
var int b_45m = na, var int b_1h  = na, var int b_2h  = na
var int b_3h  = na, var int b_4h  = na, var int b_1d  = na

if S_15s or R_15s
    b_15s := bar_index
if S_30s or R_30s
    b_30s := bar_index
if S_45s or R_45s
    b_45s := bar_index
if S_1m or R_1m
    b_1m := bar_index
if S_3m or R_3m
    b_3m := bar_index
if S_5m or R_5m
    b_5m := bar_index
if S_10m or R_10m
    b_10m := bar_index
if S_15m or R_15m
    b_15m := bar_index
if S_30m or R_30m
    b_30m := bar_index
if S_45m or R_45m
    b_45m := bar_index
if S_1h or R_1h
    b_1h := bar_index
if S_2h or R_2h
    b_2h := bar_index
if S_3h or R_3h
    b_3h := bar_index
if S_4h or R_4h
    b_4h := bar_index
if S_1d or R_1d
    b_1d := bar_index

// ============================================================================
// ON-CHART HISTORY MARKERS (chart-TF only)
// ============================================================================
chart_S = want_support    and f_support(high, low, close, ma_chart, tol_pct)
chart_R = want_resistance and f_resistance(high, low, close, ma_chart, tol_pct)
bgcolor(show_history and chart_S ? color.new(color.lime, 80) : na, title = "Support hold")
bgcolor(show_history and chart_R ? color.new(color.red,  80) : na, title = "Resistance hold")
plotshape(show_history and chart_S, title = "Support marker",    style = shape.triangleup,   location = location.belowbar, color = color.lime, size = size.small)
plotshape(show_history and chart_R, title = "Resistance marker", style = shape.triangledown, location = location.abovebar, color = color.red,  size = size.small)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(ES_15s, title = "Support (15s)", message = "{{ticker}} - 900 SUPPORT at 15s")
alertcondition(ER_15s, title = "Resistance (15s)", message = "{{ticker}} - 900 RESISTANCE at 15s")
alertcondition(ES_30s, title = "Support (30s)", message = "{{ticker}} - 900 SUPPORT at 30s")
alertcondition(ER_30s, title = "Resistance (30s)", message = "{{ticker}} - 900 RESISTANCE at 30s")
alertcondition(ES_45s, title = "Support (45s)", message = "{{ticker}} - 900 SUPPORT at 45s")
alertcondition(ER_45s, title = "Resistance (45s)", message = "{{ticker}} - 900 RESISTANCE at 45s")
alertcondition(ES_1m,  title = "Support (1m)",  message = "{{ticker}} - 900 SUPPORT at 1m")
alertcondition(ER_1m,  title = "Resistance (1m)",  message = "{{ticker}} - 900 RESISTANCE at 1m")
alertcondition(ES_3m,  title = "Support (3m)",  message = "{{ticker}} - 900 SUPPORT at 3m")
alertcondition(ER_3m,  title = "Resistance (3m)",  message = "{{ticker}} - 900 RESISTANCE at 3m")
alertcondition(ES_5m,  title = "Support (5m)",  message = "{{ticker}} - 900 SUPPORT at 5m")
alertcondition(ER_5m,  title = "Resistance (5m)",  message = "{{ticker}} - 900 RESISTANCE at 5m")
alertcondition(ES_10m, title = "Support (10m)", message = "{{ticker}} - 900 SUPPORT at 10m")
alertcondition(ER_10m, title = "Resistance (10m)", message = "{{ticker}} - 900 RESISTANCE at 10m")
alertcondition(ES_15m, title = "Support (15m)", message = "{{ticker}} - 900 SUPPORT at 15m")
alertcondition(ER_15m, title = "Resistance (15m)", message = "{{ticker}} - 900 RESISTANCE at 15m")
alertcondition(ES_30m, title = "Support (30m)", message = "{{ticker}} - 900 SUPPORT at 30m")
alertcondition(ER_30m, title = "Resistance (30m)", message = "{{ticker}} - 900 RESISTANCE at 30m")
alertcondition(ES_45m, title = "Support (45m)", message = "{{ticker}} - 900 SUPPORT at 45m")
alertcondition(ER_45m, title = "Resistance (45m)", message = "{{ticker}} - 900 RESISTANCE at 45m")
alertcondition(ES_1h,  title = "Support (1h)",  message = "{{ticker}} - 900 SUPPORT at 1h")
alertcondition(ER_1h,  title = "Resistance (1h)",  message = "{{ticker}} - 900 RESISTANCE at 1h")
alertcondition(ES_2h,  title = "Support (2h)",  message = "{{ticker}} - 900 SUPPORT at 2h")
alertcondition(ER_2h,  title = "Resistance (2h)",  message = "{{ticker}} - 900 RESISTANCE at 2h")
alertcondition(ES_3h,  title = "Support (3h)",  message = "{{ticker}} - 900 SUPPORT at 3h")
alertcondition(ER_3h,  title = "Resistance (3h)",  message = "{{ticker}} - 900 RESISTANCE at 3h")
alertcondition(ES_4h,  title = "Support (4h)",  message = "{{ticker}} - 900 SUPPORT at 4h")
alertcondition(ER_4h,  title = "Resistance (4h)",  message = "{{ticker}} - 900 RESISTANCE at 4h")
alertcondition(ES_1d,  title = "Support (1D)",  message = "{{ticker}} - 900 SUPPORT at 1D")
alertcondition(ER_1d,  title = "Resistance (1D)", message = "{{ticker}} - 900 RESISTANCE at 1D")

// Combined any-edge alert
any_S = ES_15s or ES_30s or ES_45s or ES_1m or ES_3m or ES_5m or ES_10m or ES_15m or ES_30m or ES_45m or ES_1h or ES_2h or ES_3h or ES_4h or ES_1d
any_R = ER_15s or ER_30s or ER_45s or ER_1m or ER_3m or ER_5m or ER_10m or ER_15m or ER_30m or ER_45m or ER_1h or ER_2h or ER_3h or ER_4h or ER_1d

if any_S or any_R
    sup_msg = ""
    sup_msg := ES_15s ? sup_msg + " 15s," : sup_msg
    sup_msg := ES_30s ? sup_msg + " 30s," : sup_msg
    sup_msg := ES_45s ? sup_msg + " 45s," : sup_msg
    sup_msg := ES_1m  ? sup_msg + " 1m,"  : sup_msg
    sup_msg := ES_3m  ? sup_msg + " 3m,"  : sup_msg
    sup_msg := ES_5m  ? sup_msg + " 5m,"  : sup_msg
    sup_msg := ES_10m ? sup_msg + " 10m," : sup_msg
    sup_msg := ES_15m ? sup_msg + " 15m," : sup_msg
    sup_msg := ES_30m ? sup_msg + " 30m," : sup_msg
    sup_msg := ES_45m ? sup_msg + " 45m," : sup_msg
    sup_msg := ES_1h  ? sup_msg + " 1h,"  : sup_msg
    sup_msg := ES_2h  ? sup_msg + " 2h,"  : sup_msg
    sup_msg := ES_3h  ? sup_msg + " 3h,"  : sup_msg
    sup_msg := ES_4h  ? sup_msg + " 4h,"  : sup_msg
    sup_msg := ES_1d  ? sup_msg + " 1D,"  : sup_msg
    res_msg = ""
    res_msg := ER_15s ? res_msg + " 15s," : res_msg
    res_msg := ER_30s ? res_msg + " 30s," : res_msg
    res_msg := ER_45s ? res_msg + " 45s," : res_msg
    res_msg := ER_1m  ? res_msg + " 1m,"  : res_msg
    res_msg := ER_3m  ? res_msg + " 3m,"  : res_msg
    res_msg := ER_5m  ? res_msg + " 5m,"  : res_msg
    res_msg := ER_10m ? res_msg + " 10m," : res_msg
    res_msg := ER_15m ? res_msg + " 15m," : res_msg
    res_msg := ER_30m ? res_msg + " 30m," : res_msg
    res_msg := ER_45m ? res_msg + " 45m," : res_msg
    res_msg := ER_1h  ? res_msg + " 1h,"  : res_msg
    res_msg := ER_2h  ? res_msg + " 2h,"  : res_msg
    res_msg := ER_3h  ? res_msg + " 3h,"  : res_msg
    res_msg := ER_4h  ? res_msg + " 4h,"  : res_msg
    res_msg := ER_1d  ? res_msg + " 1D,"  : res_msg
    sup_clean = str.length(sup_msg) > 0 ? str.substring(sup_msg, 0, str.length(sup_msg) - 1) : ""
    res_clean = str.length(res_msg) > 0 ? str.substring(res_msg, 0, str.length(res_msg) - 1) : ""
    full_msg = syminfo.ticker
    full_msg := any_S ? full_msg + " - 900 SUPPORT at" + sup_clean : full_msg
    full_msg := any_R ? full_msg + (any_S ? " | " : " -") + " 900 RESISTANCE at" + res_clean : full_msg
    alert(full_msg, alert.freq_once_per_bar)

// ============================================================================
// LIVE BANNER
// ============================================================================
var table banner = table.new(f_pos(banner_pos_str), 1, 1, border_width = 2, frame_color = color.gray, frame_width = 1)

if banner_pos_str != "off" and barstate.islast
    sup_now = ""
    sup_now := S_15s ? sup_now + " 15s," : sup_now
    sup_now := S_30s ? sup_now + " 30s," : sup_now
    sup_now := S_45s ? sup_now + " 45s," : sup_now
    sup_now := S_1m  ? sup_now + " 1m,"  : sup_now
    sup_now := S_3m  ? sup_now + " 3m,"  : sup_now
    sup_now := S_5m  ? sup_now + " 5m,"  : sup_now
    sup_now := S_10m ? sup_now + " 10m," : sup_now
    sup_now := S_15m ? sup_now + " 15m," : sup_now
    sup_now := S_30m ? sup_now + " 30m," : sup_now
    sup_now := S_45m ? sup_now + " 45m," : sup_now
    sup_now := S_1h  ? sup_now + " 1h,"  : sup_now
    sup_now := S_2h  ? sup_now + " 2h,"  : sup_now
    sup_now := S_3h  ? sup_now + " 3h,"  : sup_now
    sup_now := S_4h  ? sup_now + " 4h,"  : sup_now
    sup_now := S_1d  ? sup_now + " 1D,"  : sup_now
    res_now = ""
    res_now := R_15s ? res_now + " 15s," : res_now
    res_now := R_30s ? res_now + " 30s," : res_now
    res_now := R_45s ? res_now + " 45s," : res_now
    res_now := R_1m  ? res_now + " 1m,"  : res_now
    res_now := R_3m  ? res_now + " 3m,"  : res_now
    res_now := R_5m  ? res_now + " 5m,"  : res_now
    res_now := R_10m ? res_now + " 10m," : res_now
    res_now := R_15m ? res_now + " 15m," : res_now
    res_now := R_30m ? res_now + " 30m," : res_now
    res_now := R_45m ? res_now + " 45m," : res_now
    res_now := R_1h  ? res_now + " 1h,"  : res_now
    res_now := R_2h  ? res_now + " 2h,"  : res_now
    res_now := R_3h  ? res_now + " 3h,"  : res_now
    res_now := R_4h  ? res_now + " 4h,"  : res_now
    res_now := R_1d  ? res_now + " 1D,"  : res_now
    has_sup = str.length(sup_now) > 0
    has_res = str.length(res_now) > 0
    sup_clean2 = has_sup ? str.substring(sup_now, 0, str.length(sup_now) - 1) : ""
    res_clean2 = has_res ? str.substring(res_now, 0, str.length(res_now) - 1) : ""
    txt = "○ no active S/R"
    txt := has_sup and has_res ? "▲ SUP:" + sup_clean2 + "  ▼ RES:" + res_clean2 : txt
    txt := has_sup and not has_res ? "▲ 900 SUPPORT:" + sup_clean2 : txt
    txt := has_res and not has_sup ? "▼ 900 RESISTANCE:" + res_clean2 : txt
    bg = color.new(color.gray, 70)
    bg := has_sup and not has_res ? color.new(color.green, 20) : bg
    bg := has_res and not has_sup ? color.new(color.red, 20) : bg
    bg := has_sup and has_res ? color.new(color.purple, 20) : bg
    table.cell(banner, 0, 0, txt, bgcolor = bg, text_color = color.white, text_size = size.large)

// ============================================================================
// STATUS TABLE
// ============================================================================
var table tbl = table.new(f_pos(table_pos_str), 4, 16, border_width = 1, frame_color = color.gray, frame_width = 1)

if table_pos_str != "off" and barstate.islast
    table.cell(tbl, 0, 0, "TF",     bgcolor = color.new(color.black, 20), text_color = color.white)
    table.cell(tbl, 1, 0, "MA",     bgcolor = color.new(color.black, 20), text_color = color.white)
    table.cell(tbl, 2, 0, "Signal", bgcolor = color.new(color.black, 20), text_color = color.white)
    table.cell(tbl, 3, 0, "Last",   bgcolor = color.new(color.black, 20), text_color = color.white)
    table.cell(tbl, 0, 1, "15s")
    table.cell(tbl, 1, 1, na(m_15s) ? "—" : str.tostring(m_15s, "#.##"))
    table.cell(tbl, 2, 1, f_signal_text(S_15s, R_15s), bgcolor = f_signal_color(S_15s, R_15s, use_15s))
    table.cell(tbl, 3, 1, f_since(b_15s), bgcolor = f_paint_hist(b_15s, use_15s))
    table.cell(tbl, 0, 2, "30s")
    table.cell(tbl, 1, 2, na(m_30s) ? "—" : str.tostring(m_30s, "#.##"))
    table.cell(tbl, 2, 2, f_signal_text(S_30s, R_30s), bgcolor = f_signal_color(S_30s, R_30s, use_30s))
    table.cell(tbl, 3, 2, f_since(b_30s), bgcolor = f_paint_hist(b_30s, use_30s))
    table.cell(tbl, 0, 3, "45s")
    table.cell(tbl, 1, 3, na(m_45s) ? "—" : str.tostring(m_45s, "#.##"))
    table.cell(tbl, 2, 3, f_signal_text(S_45s, R_45s), bgcolor = f_signal_color(S_45s, R_45s, use_45s))
    table.cell(tbl, 3, 3, f_since(b_45s), bgcolor = f_paint_hist(b_45s, use_45s))
    table.cell(tbl, 0, 4, "1m")
    table.cell(tbl, 1, 4, na(m_1m) ? "—" : str.tostring(m_1m, "#.##"))
    table.cell(tbl, 2, 4, f_signal_text(S_1m, R_1m), bgcolor = f_signal_color(S_1m, R_1m, use_1m))
    table.cell(tbl, 3, 4, f_since(b_1m), bgcolor = f_paint_hist(b_1m, use_1m))
    table.cell(tbl, 0, 5, "3m")
    table.cell(tbl, 1, 5, na(m_3m) ? "—" : str.tostring(m_3m, "#.##"))
    table.cell(tbl, 2, 5, f_signal_text(S_3m, R_3m), bgcolor = f_signal_color(S_3m, R_3m, use_3m))
    table.cell(tbl, 3, 5, f_since(b_3m), bgcolor = f_paint_hist(b_3m, use_3m))
    table.cell(tbl, 0, 6, "5m")
    table.cell(tbl, 1, 6, na(m_5m) ? "—" : str.tostring(m_5m, "#.##"))
    table.cell(tbl, 2, 6, f_signal_text(S_5m, R_5m), bgcolor = f_signal_color(S_5m, R_5m, use_5m))
    table.cell(tbl, 3, 6, f_since(b_5m), bgcolor = f_paint_hist(b_5m, use_5m))
    table.cell(tbl, 0, 7, "10m")
    table.cell(tbl, 1, 7, na(m_10m) ? "—" : str.tostring(m_10m, "#.##"))
    table.cell(tbl, 2, 7, f_signal_text(S_10m, R_10m), bgcolor = f_signal_color(S_10m, R_10m, use_10m))
    table.cell(tbl, 3, 7, f_since(b_10m), bgcolor = f_paint_hist(b_10m, use_10m))
    table.cell(tbl, 0, 8, "15m")
    table.cell(tbl, 1, 8, na(m_15m) ? "—" : str.tostring(m_15m, "#.##"))
    table.cell(tbl, 2, 8, f_signal_text(S_15m, R_15m), bgcolor = f_signal_color(S_15m, R_15m, use_15m))
    table.cell(tbl, 3, 8, f_since(b_15m), bgcolor = f_paint_hist(b_15m, use_15m))
    table.cell(tbl, 0, 9, "30m")
    table.cell(tbl, 1, 9, na(m_30m) ? "—" : str.tostring(m_30m, "#.##"))
    table.cell(tbl, 2, 9, f_signal_text(S_30m, R_30m), bgcolor = f_signal_color(S_30m, R_30m, use_30m))
    table.cell(tbl, 3, 9, f_since(b_30m), bgcolor = f_paint_hist(b_30m, use_30m))
    table.cell(tbl, 0, 10, "45m")
    table.cell(tbl, 1, 10, na(m_45m) ? "—" : str.tostring(m_45m, "#.##"))
    table.cell(tbl, 2, 10, f_signal_text(S_45m, R_45m), bgcolor = f_signal_color(S_45m, R_45m, use_45m))
    table.cell(tbl, 3, 10, f_since(b_45m), bgcolor = f_paint_hist(b_45m, use_45m))
    table.cell(tbl, 0, 11, "1h")
    table.cell(tbl, 1, 11, na(m_1h) ? "—" : str.tostring(m_1h, "#.##"))
    table.cell(tbl, 2, 11, f_signal_text(S_1h, R_1h), bgcolor = f_signal_color(S_1h, R_1h, use_1h))
    table.cell(tbl, 3, 11, f_since(b_1h), bgcolor = f_paint_hist(b_1h, use_1h))
    table.cell(tbl, 0, 12, "2h")
    table.cell(tbl, 1, 12, na(m_2h) ? "—" : str.tostring(m_2h, "#.##"))
    table.cell(tbl, 2, 12, f_signal_text(S_2h, R_2h), bgcolor = f_signal_color(S_2h, R_2h, use_2h))
    table.cell(tbl, 3, 12, f_since(b_2h), bgcolor = f_paint_hist(b_2h, use_2h))
    table.cell(tbl, 0, 13, "3h")
    table.cell(tbl, 1, 13, na(m_3h) ? "—" : str.tostring(m_3h, "#.##"))
    table.cell(tbl, 2, 13, f_signal_text(S_3h, R_3h), bgcolor = f_signal_color(S_3h, R_3h, use_3h))
    table.cell(tbl, 3, 13, f_since(b_3h), bgcolor = f_paint_hist(b_3h, use_3h))
    table.cell(tbl, 0, 14, "4h")
    table.cell(tbl, 1, 14, na(m_4h) ? "—" : str.tostring(m_4h, "#.##"))
    table.cell(tbl, 2, 14, f_signal_text(S_4h, R_4h), bgcolor = f_signal_color(S_4h, R_4h, use_4h))
    table.cell(tbl, 3, 14, f_since(b_4h), bgcolor = f_paint_hist(b_4h, use_4h))
    table.cell(tbl, 0, 15, "1D")
    table.cell(tbl, 1, 15, na(m_1d) ? "—" : str.tostring(m_1d, "#.##"))
    table.cell(tbl, 2, 15, f_signal_text(S_1d, R_1d), bgcolor = f_signal_color(S_1d, R_1d, use_1d))
    table.cell(tbl, 3, 15, f_since(b_1d), bgcolor = f_paint_hist(b_1d, use_1d))
````
