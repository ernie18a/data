# Rich Scanner

- url: https://www.tradingview.com/script/64V5aztk-Rich-Scanner/
- type: indicator
- pine_id: PUB;17c634db55a845efbe65a727c2ee9b98
- version: 1.0

## Description

this is real this is me I am exactly where I am Supposed to be now gonna let the light shine on me now I know where I am theres no way to hold it in this is me.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
// PB MECH MODEL — Scanner & Webhook Alert  v1.0
// ════════════════════════════════════════════════════════════════════════════
indicator("PB Mech Model — Scanner", overlay=true, max_boxes_count=100, max_lines_count=50, max_labels_count=50)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
var string G1 = "Confluence Thresholds"
i_min_score = input.int(6, "Min score to alert (1–8)", minval=1, maxval=8, group=G1)
i_disp_body = input.float(55, "Displacement — min body %", minval=30, maxval=100, step=5, group=G1)
i_disp_pts  = input.float(3.0, "Displacement — min size (points)", minval=0.25, step=0.25, group=G1)
i_level_buf = input.float(2.0, "HTF level proximity buffer (points)", minval=0.25, step=0.25, group=G1)
i_fib_lo    = input.float(0.50, "OTE retracement — low end (default 50%)", minval=0.10, maxval=0.90, step=0.01, group=G1)
i_fib_hi    = input.float(0.79, "OTE retracement — high end (default 79%)", minval=0.10, maxval=0.99, step=0.01, group=G1)
i_stop_buf  = input.float(1.5, "Stop buffer beyond FVG edge (points)", minval=0.0, step=0.25, group=G1)
i_rr        = input.float(2.0, "Default R:R for target", minval=1.0, step=0.5, group=G1)

var string G2 = "Lookback Windows"
i_sweep_lb  = input.int(10, "Sweep lookback (bars)", minval=2, maxval=30, group=G2)
i_setup_win = input.int(60, "Setup context window (bars)", minval=10, maxval=200, group=G2)
i_fvg_lb    = input.int(40, "FVG validity window (bars)", minval=5, maxval=100, group=G2)
i_fib_lb    = input.int(20, "Fib leg lookback (bars)", minval=5, maxval=50, group=G2)

var string G3 = "Display"
i_show_fvg = input.bool(true, "Show FVG boxes", group=G3)
i_show_pd  = input.bool(true, "Show PDH / PDL lines", group=G3)
i_show_kz  = input.bool(false, "Shade killzone background", group=G3)

// ─────────────────────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────
_touches(level) =>
    not na(level) and low <= level + i_level_buf and high >= level - i_level_buf

_chk(b) => b ? "✓" : "—"
_cc(b)  => b ? color.lime : color.new(color.red, 10)

// ─────────────────────────────────────────────────────────────────────────────
// C1 · KILLZONE  (America/New_York)
// ─────────────────────────────────────────────────────────────────────────────
_eth  = hour(time, "America/New_York")
_etm  = minute(time, "America/New_York")
_etms = _eth * 60 + _etm

kz_asia   = _etms >= 1200 and _etms <= 1439
kz_london = _etms >= 120 and _etms <= 300
kz_ny_am  = _etms >= 420 and _etms <= 600
kz_ny_pm  = _etms >= 810 and _etms <= 960

c1_killzone = kz_asia or kz_london or kz_ny_am or kz_ny_pm
kz_name     = kz_asia ? "Asia" : kz_london ? "London" : kz_ny_am ? "NY AM" : kz_ny_pm ? "NY PM" : "—"

// ─────────────────────────────────────────────────────────────────────────────
// C2 · HTF KEY LEVELS  (Previous Day / Week High & Low)
// ─────────────────────────────────────────────────────────────────────────────
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

c2_htf_level = _touches(pdh) or _touches(pdl) or _touches(pwh) or _touches(pwl)

// ─────────────────────────────────────────────────────────────────────────────
// C3 · LIQUIDITY SWEEP
// ─────────────────────────────────────────────────────────────────────────────
_prior_lo = ta.lowest(low[1], i_sweep_lb)
_prior_hi = ta.highest(high[1], i_sweep_lb)

_bull_sweep_struct = low < _prior_lo and close > _prior_lo
_bear_sweep_struct = high > _prior_hi and close < _prior_hi
_bull_sweep_htf    = (low < pdl and close > pdl) or (low < pwl and close > pwl)
_bear_sweep_htf    = (high > pdh and close < pdh) or (high > pwh and close < pwh)

bull_sweep_now = _bull_sweep_struct or _bull_sweep_htf
bear_sweep_now = _bear_sweep_struct or _bear_sweep_htf

var int last_bull_bar = -9999
var int last_bear_bar = -9999

if bull_sweep_now
    last_bull_bar := bar_index
    last_bear_bar := -9999
if bear_sweep_now
    last_bear_bar := bar_index
    last_bull_bar := -9999

recent_bull = bar_index - last_bull_bar <= i_setup_win
recent_bear = bar_index - last_bear_bar <= i_setup_win

c3_sweep  = recent_bull or recent_bear
sweep_dir = recent_bull ? "BULL" : recent_bear ? "BEAR" : "NONE"

// ─────────────────────────────────────────────────────────────────────────────
// C4 · DISPLACEMENT CANDLE
// ─────────────────────────────────────────────────────────────────────────────
_cbody   = math.abs(close - open)
_crange  = high - low
_cbodypct = _crange > 0 ? _cbody / _crange * 100 : 0.0

_is_bull_disp = close > open and _cbodypct >= i_disp_body and _cbody >= i_disp_pts
_is_bear_disp = close < open and _cbodypct >= i_disp_body and _cbody >= i_disp_pts

var int last_bull_disp = -9999
var int last_bear_disp = -9999

if _is_bull_disp and recent_bull and bar_index > last_bull_bar
    last_bull_disp := bar_index
if _is_bear_disp and recent_bear and bar_index > last_bear_bar
    last_bear_disp := bar_index

if bull_sweep_now
    last_bear_disp := -9999
if bear_sweep_now
    last_bull_disp := -9999

c4_displacement = (sweep_dir == "BULL" and bar_index - last_bull_disp <= i_setup_win) or (sweep_dir == "BEAR" and bar_index - last_bear_disp <= i_setup_win)

// ─────────────────────────────────────────────────────────────────────────────
// C5 · FAIR VALUE GAP
// ─────────────────────────────────────────────────────────────────────────────
bull_fvg_now = high[2] < low[0]
bear_fvg_now = low[2] > high[0]

var float bfvg_top = na
var float bfvg_bot = na
var float sfvg_top = na
var float sfvg_bot = na
var int   bfvg_bar = -9999
var int   sfvg_bar = -9999

if bull_fvg_now and recent_bull and bar_index > last_bull_bar
    bfvg_top := low[0]
    bfvg_bot := high[2]
    bfvg_bar := bar_index
    if i_show_fvg
        box.new(bar_index[2], low[0], bar_index + 30, high[2], bgcolor=color.new(color.teal, 85), border_color=color.new(color.teal, 40), border_width=1)

if bear_fvg_now and recent_bear and bar_index > last_bear_bar
    sfvg_top := low[2]
    sfvg_bot := high[0]
    sfvg_bar := bar_index
    if i_show_fvg
        box.new(bar_index[2], low[2], bar_index + 30, high[0], bgcolor=color.new(color.red, 85), border_color=color.new(color.red, 40), border_width=1)

if bull_sweep_now
    sfvg_top := na
    sfvg_bot := na
    sfvg_bar := -9999
if bear_sweep_now
    bfvg_top := na
    bfvg_bot := na
    bfvg_bar := -9999

bfvg_valid = not na(bfvg_top) and recent_bull and (bar_index - bfvg_bar) <= i_fvg_lb
sfvg_valid = not na(sfvg_top) and recent_bear and (bar_index - sfvg_bar) <= i_fvg_lb

c5_fvg = (sweep_dir == "BULL" and bfvg_valid) or (sweep_dir == "BEAR" and sfvg_valid)

// ─────────────────────────────────────────────────────────────────────────────
// C6 · FIBONACCI OTE ZONE
// ─────────────────────────────────────────────────────────────────────────────
_leg_hi  = ta.highest(high, i_fib_lb)
_leg_lo  = ta.lowest(low, i_fib_lb)
_leg_rng = _leg_hi - _leg_lo

bull_ote_hi = _leg_hi - i_fib_lo * _leg_rng
bull_ote_lo = _leg_hi - i_fib_hi * _leg_rng
bear_ote_lo = _leg_lo + i_fib_lo * _leg_rng
bear_ote_hi = _leg_lo + i_fib_hi * _leg_rng

in_bull_ote = _leg_rng > 0 and close >= bull_ote_lo and close <= bull_ote_hi and close < open
in_bear_ote = _leg_rng > 0 and close >= bear_ote_lo and close <= bear_ote_hi and close > open

c6_fib_ote = (sweep_dir == "BULL" and in_bull_ote) or (sweep_dir == "BEAR" and in_bear_ote)

// ─────────────────────────────────────────────────────────────────────────────
// C7 · FVG PULLBACK / IFVG ENTRY
// ─────────────────────────────────────────────────────────────────────────────
in_bfvg = bfvg_valid and low <= bfvg_top and high >= bfvg_bot
in_sfvg = sfvg_valid and high >= sfvg_bot and low <= sfvg_top

ifvg_bull = bfvg_valid and close[1] < bfvg_bot and close >= bfvg_bot
ifvg_bear = sfvg_valid and close[1] > sfvg_top and close <= sfvg_top

c7_fvg_pullback = (sweep_dir == "BULL" and (in_bfvg or ifvg_bull)) or (sweep_dir == "BEAR" and (in_sfvg or ifvg_bear))

// ─────────────────────────────────────────────────────────────────────────────
// C8 · 1-MINUTE STRUCTURE BREAK
// ─────────────────────────────────────────────────────────────────────────────
[m1c, m1h, m1l, m1o] = request.security(syminfo.tickerid, "1", [close, high, low, open], lookahead=barmerge.lookahead_off)

m1_bull_bos = m1c > m1h[1] and m1c > m1o
m1_bear_bos = m1c < m1l[1] and m1c < m1o

c8_inversion = (sweep_dir == "BULL" and m1_bull_bos) or (sweep_dir == "BEAR" and m1_bear_bos)

// ─────────────────────────────────────────────────────────────────────────────
// CONFLUENCE SCORE  (0–8)
// ─────────────────────────────────────────────────────────────────────────────
score = (c1_killzone ? 1 : 0) + (c2_htf_level ? 1 : 0) + (c3_sweep ? 1 : 0) + (c4_displacement ? 1 : 0) + (c5_fvg ? 1 : 0) + (c6_fib_ote ? 1 : 0) + (c7_fvg_pullback ? 1 : 0) + (c8_inversion ? 1 : 0)

// ─────────────────────────────────────────────────────────────────────────────
// TRADE LEVELS
// ─────────────────────────────────────────────────────────────────────────────
_atr = ta.atr(14)

bull_stop   = bfvg_valid ? bfvg_bot - i_stop_buf : close - _atr * 1.5
bear_stop   = sfvg_valid ? sfvg_top + i_stop_buf : close + _atr * 1.5
bull_risk   = math.max(close - bull_stop, 0.25)
bear_risk   = math.max(bear_stop - close, 0.25)
bull_target = close + bull_risk * i_rr
bear_target = close - bear_risk * i_rr
bull_inval  = bfvg_valid ? bfvg_bot : bull_stop
bear_inval  = sfvg_valid ? sfvg_top : bear_stop

entry_p  = close
stop_p   = sweep_dir == "BULL" ? bull_stop : bear_stop
target_p = sweep_dir == "BULL" ? bull_target : bear_target
risk_p   = sweep_dir == "BULL" ? bull_risk : bear_risk
inval_p  = sweep_dir == "BULL" ? bull_inval : bear_inval
action   = sweep_dir == "BULL" ? "BUY" : "SELL"
rr_str   = str.tostring(math.round(i_rr * 10) / 10, "#.0") + "R"

// ─────────────────────────────────────────────────────────────────────────────
// ALERT CONDITION
// ─────────────────────────────────────────────────────────────────────────────
setup_found = score >= i_min_score and sweep_dir != "NONE" and barstate.isconfirmed

_rsn = (c3_sweep ? "Liq sweep" : "") + (c5_fvg ? " + FVG" : "") + (c6_fib_ote ? " + OTE" : "") + (c7_fvg_pullback ? " + FVG pb" : "") + (c8_inversion ? " + 1m inv" : "")

_json = '{"symbol":"' + syminfo.ticker + '"' + ',"action":"' + action + '"' + ',"price":' + str.tostring(entry_p, "#.00") + ',"stop":' + str.tostring(stop_p, "#.00") + ',"target":' + str.tostring(target_p, "#.00") + ',"risk_pts":' + str.tostring(risk_p, "#.00") + ',"rr":"' + rr_str + '"' + ',"killzone":"' + kz_name + '"' + ',"score":' + str.tostring(score) + ',"invalidation":' + str.tostring(inval_p, "#.00") + ',"reason":"' + _rsn + '"' + ',"timeframe":"5"}'

if setup_found
    alert(_json, alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// VISUALS — Killzone background
// ─────────────────────────────────────────────────────────────────────────────
bgcolor(i_show_kz and kz_asia ? color.new(color.purple, 94) : na, title="Asia KZ")
bgcolor(i_show_kz and kz_london ? color.new(color.blue, 94) : na, title="London KZ")
bgcolor(i_show_kz and kz_ny_am ? color.new(color.green, 94) : na, title="NY AM KZ")
bgcolor(i_show_kz and kz_ny_pm ? color.new(color.yellow, 94) : na, title="NY PM KZ")

// ─────────────────────────────────────────────────────────────────────────────
// VISUALS — PDH / PDL horizontal lines
// ─────────────────────────────────────────────────────────────────────────────
plot(i_show_pd ? pdh : na, "PDH", color=color.new(color.orange, 20), linewidth=1, style=plot.style_linebr)
plot(i_show_pd ? pdl : na, "PDL", color=color.new(color.orange, 20), linewidth=1, style=plot.style_linebr)
plot(i_show_pd ? pwh : na, "PWH", color=color.new(color.orange, 55), linewidth=1, style=plot.style_linebr)
plot(i_show_pd ? pwl : na, "PWL", color=color.new(color.orange, 55), linewidth=1, style=plot.style_linebr)

// ─────────────────────────────────────────────────────────────────────────────
// VISUALS — Setup label on chart
// ─────────────────────────────────────────────────────────────────────────────
if setup_found
    _ldir = sweep_dir == "BULL" ? label.style_label_up : label.style_label_down
    _ly   = sweep_dir == "BULL" ? low : high
    _lcol = sweep_dir == "BULL" ? color.teal : color.red
    _ltxt = (sweep_dir == "BULL" ? "BUY " : "SELL ") + syminfo.ticker + "\n" + str.tostring(score) + "/8  " + kz_name + "\nE " + str.tostring(entry_p, "#.00") + "  SL " + str.tostring(stop_p, "#.00") + "\nTP " + str.tostring(target_p, "#.00") + "  (" + rr_str + ")"
    label.new(bar_index, _ly, _ltxt, style=_ldir, color=_lcol, textcolor=color.white, size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
// VISUALS — Confluence score table (top-right)
// ─────────────────────────────────────────────────────────────────────────────
var table _tbl = table.new(position.top_right, 2, 12, bgcolor=color.new(color.black, 65), border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast
    color hdr_bg = color.new(color.navy, 40)
    table.cell(_tbl, 0, 0, "PB Mech Model", text_color=color.white, bgcolor=hdr_bg, text_size=size.small)
    table.cell(_tbl, 1, 0, str.tostring(score) + "/8", text_color=score >= i_min_score ? color.lime : color.gray, bgcolor=hdr_bg, text_size=size.small)
    table.cell(_tbl, 0, 1, "1 · Killzone", text_color=color.silver, text_size=size.tiny)
    table.cell(_tbl, 1, 1, _chk(c1_killzone), text_color=_cc(c1_killzone), text_size=size.tiny)
    table.cell(_tbl, 0, 2, "2 · HTF Level", text_color=color.silver, text_size=size.tiny)
    table.cell(_tbl, 1, 2, _chk(c2_htf_level), text_color=_cc(c2_htf_level), text_size=size.tiny)
    table.cell(_tbl, 0, 3, "3 · Liq Sweep", text_color=color.silver, text_size=size.tiny)
    table.cell(_tbl, 1, 3, _chk(c3_sweep), text_color=_cc(c3_sweep), text_size=size.tiny)
    table.cell(_tbl, 0, 4, "4 · Displacement", text_color=color.silver, text_size=size.tiny)
    table.cell(_tbl, 1, 4, _chk(c4_displacement), text_color=_cc(c4_displacement), text_size=size.tiny)
    table.cell(_tbl, 0, 5, "5 · FVG", text_color=color.silver, text_size=size.tiny)
    table.cell(_tbl, 1, 5, _chk(c5_fvg), text_color=_cc(c5_fvg), text_size=size.tiny)
    table.cell(_tbl, 0, 6, "6 · Fib OTE", text_color=color.silver, text_size=size.tiny)
    table.cell(_tbl, 1, 6, _chk(c6_fib_ote), text_color=_cc(c6_fib_ote), text_size=size.tiny)
    table.cell(_tbl, 0, 7, "7 · FVG Pullback", text_color=color.silver, text_size=size.tiny)
    table.cell(_tbl, 1, 7, _chk(c7_fvg_pullback), text_color=_cc(c7_fvg_pullback), text_size=size.tiny)
    table.cell(_tbl, 0, 8, "8 · 1m Inversion", text_color=color.silver, text_size=size.tiny)
    table.cell(_tbl, 1, 8, _chk(c8_inversion), text_color=_cc(c8_inversion), text_size=size.tiny)
    table.cell(_tbl, 0, 9, "Direction", text_color=color.silver, text_size=size.tiny)
    table.cell(_tbl, 1, 9, sweep_dir, text_color=color.yellow, text_size=size.tiny)
    table.cell(_tbl, 0, 10, "Killzone", text_color=color.silver, text_size=size.tiny)
    table.cell(_tbl, 1, 10, kz_name, text_color=c1_killzone ? color.lime : color.gray, text_size=size.tiny)
    table.cell(_tbl, 0, 11, "Alert → Webhook URL", text_color=color.gray, text_size=size.tiny)
    table.cell(_tbl, 1, 11, "set in alert dialog", text_color=color.gray, text_size=size.tiny)
````
