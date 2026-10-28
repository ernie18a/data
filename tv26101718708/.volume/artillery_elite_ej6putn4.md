# Artillery Elite

- url: https://www.tradingview.com/script/Ej6PutN4-Artillery-Elite/
- type: indicator
- pine_id: PUB;59099d6da6f04b3889452e33d7462f88
- version: 1.0

## Description

Artillery Elite is a session momentum-pullback signal indicator for intraday index futures. It marks BUY/SELL candidates only when several independent conditions line up at once - trend structure, VWAP bias, a completed pullback, momentum strength and the time of day - and then draws the full trade context (entry, stop, target zones) so you can judge each signal against your own plan. This canonical publication consolidates the earlier Artillery Elite variants (two strategy versions and an older indicator build) into one script.

WHAT IT DOES

A signal prints only when ALL of these agree:

1) Trend structure - the 9 EMA above the 21 EMA for longs (below for shorts), with a 50 EMA plotted for wider context.
2) VWAP bias - price on the trend side of the session VWAP: longs only above it, shorts only below it.
3) Pullback and resume - one of the last two bars dipped through the 9 EMA (the pullback), and the signal bar closes back beyond the 9 EMA in the trend direction with a real body.
4) Momentum floor - ADX (computed from the classic DMI recursion) above a configurable minimum, so signals are skipped in driftless tape.
5) Session windows - signals fire only inside the configurable AM (9:45-11:30 ET) and PM (14:00-15:30 ET) windows, with a separate highlighted mid-morning focus window. A cooldown gate spaces consecutive signals.

WHY THESE FILTERS TOGETHER

Each filter fails in a different way on its own: EMA crosses whipsaw in chop, VWAP bias alone is late, pullbacks against momentum keep pulling. Requiring structure + bias + a finished pullback + a momentum floor + the right session is what turns five ordinary conditions into one selective checklist. All code is original and uses only Pine built-ins.

WHAT YOU SEE ON THE CHART

- BUY / SELL labels on qualifying bars, with gold-highlighted signal bars
- Optional projection lines and shaded zones for the reference entry, stop and target (point-based inputs, drawn for study - not advice)
- Session VWAP (gold), the 9/21 EMA pair with a trend-tinted fill, and the 50 EMA
- Background shading for the AM window, PM window and the mid-morning focus window
- A dashboard with trend state, VWAP bias, live ADX, current signal, active session and the configured reference R:R
- Eight visual themes

INPUTS

Reference TP/SL in points (defaults scaled for MNQ - rescale for other symbols), signal cooldown, ADX minimum, short-signal toggle, the three session windows, per-layer visual toggles and the theme picker.

ALERTS

Two alert conditions: BUY signal and SELL signal.

BEHAVIOUR NOTES

Conditions are evaluated on the live bar and confirm at bar close, so a forming signal can appear and disappear until its bar closes. The script uses no higher-timeframe requests and no lookahead. This is a signal-study tool: it does not measure or display any historical win rate, and drawn targets are geometric references, not predictions.

This is an educational and analytical tool. It is not financial advice.

## Source Code

````pine
//@version=6
// Artillery Elite - session momentum-pullback signal indicator (EMA structure,
// VWAP bias, pullback re-entry, ADX floor, AM/PM session windows, 8 themes).
// Canonical republication consolidating the previous Artillery Elite variants.
// Educational tool. Not financial advice.
indicator('Artillery Elite', shorttitle='ART Elite', overlay=true,
          max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ============================================================================
// INPUTS
// ============================================================================

grp_strat = "Setup"
tp_points   = input.float(35.0, "TP Points", group=grp_strat)
sl_points   = input.float(15.0, "SL Points", group=grp_strat)
cooldown    = input.int(5, "Signal Cooldown Bars", group=grp_strat)
adx_min     = input.int(15, "ADX Min", group=grp_strat)
enable_shorts = input.bool(true, "Show Short Signals", group=grp_strat)

grp_sess = "Session"
am_sess = input.session("0945-1130", "AM Session", group=grp_sess)
pm_sess = input.session("1400-1530", "PM Session", group=grp_sess)
sb_sess = input.session("1000-1100", "Mid-Morning Focus", group=grp_sess)

grp_vis = "Visuals"
show_vwap    = input.bool(true, "Show VWAP", group=grp_vis)
show_emas    = input.bool(true, "Show EMAs", group=grp_vis)
show_labels  = input.bool(true, "Show Labels", group=grp_vis)
show_proj    = input.bool(true, "Show Projections", group=grp_vis)
show_sess    = input.bool(true, "Show Sessions", group=grp_vis)
show_dash    = input.bool(true, "Show Dashboard", group=grp_vis)
show_barclr  = input.bool(true, "Bar Color", group=grp_vis)
proj_len     = input.int(15, "Projection Bars", group=grp_vis)

grp_theme = "Theme"
theme_choice = input.string("Chill Cafe", "Theme", options=["Chill Cafe", "Midnight Calm", "Neon Night", "Arctic Frost", "Sunset Vibes", "Stealth Ops", "Royal Velvet", "Matrix Code"], group=grp_theme)

// ============================================================================
// THEME COLORS
// ============================================================================

// Premium themes inspired by tradingviewthemes.com
// Chill Cafe: warm beige/coffee, soft blue accents, muted earth tones
// Midnight Calm: deep navy, cool blue glow, minimal
// Neon Night: electric cyan/magenta on dark - the classic
// Arctic Frost: icy whites, pale blue, clean
// Sunset Vibes: warm oranges, coral, golden hour feel
// Stealth Ops: tactical gray, low contrast, focus mode
// Royal Velvet: rich purple, gold accents, luxurious
// Matrix Code: green phosphor on black, retro hacker

f_bull_color() =>
    switch theme_choice
        "Chill Cafe"     => color.rgb(130, 180, 210)
        "Midnight Calm"  => color.rgb(100, 181, 246)
        "Neon Night"     => color.rgb(0, 229, 255)
        "Arctic Frost"   => color.rgb(179, 229, 252)
        "Sunset Vibes"   => color.rgb(255, 183, 77)
        "Stealth Ops"    => color.rgb(176, 190, 197)
        "Royal Velvet"   => color.rgb(186, 104, 200)
        "Matrix Code"    => color.rgb(0, 230, 118)
        => color.rgb(130, 180, 210)

f_bear_color() =>
    switch theme_choice
        "Chill Cafe"     => color.rgb(161, 136, 127)
        "Midnight Calm"  => color.rgb(239, 83, 80)
        "Neon Night"     => color.rgb(255, 0, 229)
        "Arctic Frost"   => color.rgb(144, 164, 174)
        "Sunset Vibes"   => color.rgb(239, 108, 77)
        "Stealth Ops"    => color.rgb(120, 144, 156)
        "Royal Velvet"   => color.rgb(171, 71, 188)
        "Matrix Code"    => color.rgb(200, 60, 60)
        => color.rgb(161, 136, 127)

f_accent_color() =>
    switch theme_choice
        "Chill Cafe"     => color.rgb(188, 170, 150)
        "Midnight Calm"  => color.rgb(66, 165, 245)
        "Neon Night"     => color.rgb(255, 215, 64)
        "Arctic Frost"   => color.rgb(224, 247, 250)
        "Sunset Vibes"   => color.rgb(255, 213, 79)
        "Stealth Ops"    => color.rgb(207, 216, 220)
        "Royal Velvet"   => color.rgb(255, 215, 64)
        "Matrix Code"    => color.rgb(105, 240, 174)
        => color.rgb(188, 170, 150)

f_dash_bg() =>
    switch theme_choice
        "Chill Cafe"     => color.rgb(62, 50, 42, 10)
        "Midnight Calm"  => color.rgb(13, 17, 23, 5)
        "Neon Night"     => color.rgb(13, 17, 23, 5)
        "Arctic Frost"   => color.rgb(30, 40, 55, 10)
        "Sunset Vibes"   => color.rgb(50, 30, 15, 10)
        "Stealth Ops"    => color.rgb(38, 50, 56, 5)
        "Royal Velvet"   => color.rgb(26, 0, 51, 10)
        "Matrix Code"    => color.rgb(0, 10, 0, 5)
        => color.rgb(62, 50, 42, 10)

bull_c   = f_bull_color()
bear_c   = f_bear_color()
accent_c = f_accent_color()
dash_bg  = f_dash_bg()

// ============================================================================
// CORE CALCULATIONS
// ============================================================================

ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
ema50 = ta.ema(close, 50)
vwap_val = ta.vwap

// ADX calculation
adx_len = 14
up_move   = ta.change(high)
down_move = -ta.change(low)
plus_dm   = na(up_move) ? na : (up_move > down_move and up_move > 0 ? up_move : 0)
minus_dm  = na(down_move) ? na : (down_move > up_move and down_move > 0 ? down_move : 0)
atr14     = ta.atr(adx_len)
plus_di   = 100 * ta.rma(plus_dm, adx_len) / atr14
minus_di  = 100 * ta.rma(minus_dm, adx_len) / atr14
dx_val    = math.abs(plus_di - minus_di) / (plus_di + minus_di) * 100
adx_val   = ta.rma(dx_val, adx_len)

// Trend
bull_trend = ema9 > ema21
bear_trend = ema9 < ema21

// ============================================================================
// SESSION LOGIC
// ============================================================================

in_am = not na(time(timeframe.period, am_sess, "America/New_York"))
in_pm = not na(time(timeframe.period, pm_sess, "America/New_York"))
in_sb = not na(time(timeframe.period, sb_sess, "America/New_York"))
in_session = in_am or in_pm

// ============================================================================
// SIGNAL LOGIC
// ============================================================================

var int bars_since_buy  = 999
var int bars_since_sell = 999
bars_since_buy  := bars_since_buy + 1
bars_since_sell := bars_since_sell + 1

// Pullback detection
pb_bull = close[1] < ema9[1] or close[2] < ema9[2]
pb_bear = close[1] > ema9[1] or close[2] > ema9[2]

// BUY conditions
buy_signal = bull_trend and close > vwap_val and pb_bull and close > ema9 and close > open and adx_val > adx_min and in_session and bars_since_buy > cooldown and bars_since_sell > cooldown

// SELL conditions
sell_cond = bear_trend and close < vwap_val and pb_bear and close < ema9 and close < open and adx_val > adx_min and in_session and bars_since_sell > cooldown and bars_since_buy > cooldown
sell_signal = enable_shorts and sell_cond

if buy_signal
    bars_since_buy := 0
if sell_signal
    bars_since_sell := 0

// ============================================================================
// PROJECTION LINES & BOXES
// ============================================================================

var line entry_ln = na
var line tp_ln    = na
var line sl_ln    = na
var label entry_lbl = na
var label tp_lbl    = na
var label sl_lbl    = na
var box  tp_box     = na
var box  sl_box     = na

f_clear_projections() =>
    if not na(entry_ln)
        line.delete(entry_ln)
    if not na(tp_ln)
        line.delete(tp_ln)
    if not na(sl_ln)
        line.delete(sl_ln)
    if not na(entry_lbl)
        label.delete(entry_lbl)
    if not na(tp_lbl)
        label.delete(tp_lbl)
    if not na(sl_lbl)
        label.delete(sl_lbl)
    if not na(tp_box)
        box.delete(tp_box)
    if not na(sl_box)
        box.delete(sl_box)



if show_proj and buy_signal
    f_clear_projections()
    entry_price = close
    tp_price    = entry_price + tp_points
    sl_price    = entry_price - sl_points
    end_bar     = bar_index + proj_len

    entry_ln := line.new(bar_index, entry_price, end_bar, entry_price, color=color.white, style=line.style_dotted, width=1)
    tp_ln    := line.new(bar_index, tp_price, end_bar, tp_price, color=color.lime, style=line.style_dashed, width=2)
    sl_ln    := line.new(bar_index, sl_price, end_bar, sl_price, color=color.red, style=line.style_dashed, width=2)

    entry_lbl := label.new(end_bar, entry_price, "ENTRY", style=label.style_label_left, color=color.rgb(50, 50, 50, 30), textcolor=color.white, size=size.small)
    tp_lbl    := label.new(end_bar, tp_price, "TP +" + str.tostring(tp_points, "#.#") + " pts", style=label.style_label_left, color=color.rgb(0, 100, 0, 30), textcolor=color.lime, size=size.small)
    sl_lbl    := label.new(end_bar, sl_price, "SL -" + str.tostring(sl_points, "#.#") + " pts", style=label.style_label_left, color=color.rgb(100, 0, 0, 30), textcolor=color.red, size=size.small)

    tp_box := box.new(bar_index, tp_price, end_bar, entry_price, bgcolor=color.new(color.green, 90), border_color=color.new(color.green, 85))
    sl_box := box.new(bar_index, entry_price, end_bar, sl_price, bgcolor=color.new(color.red, 92), border_color=color.new(color.red, 88))

if show_proj and sell_signal
    f_clear_projections()
    entry_price = close
    tp_price    = entry_price - tp_points
    sl_price    = entry_price + sl_points
    end_bar     = bar_index + proj_len

    entry_ln := line.new(bar_index, entry_price, end_bar, entry_price, color=color.white, style=line.style_dotted, width=1)
    tp_ln    := line.new(bar_index, tp_price, end_bar, tp_price, color=color.lime, style=line.style_dashed, width=2)
    sl_ln    := line.new(bar_index, sl_price, end_bar, sl_price, color=color.red, style=line.style_dashed, width=2)

    entry_lbl := label.new(end_bar, entry_price, "ENTRY", style=label.style_label_left, color=color.rgb(50, 50, 50, 30), textcolor=color.white, size=size.small)
    tp_lbl    := label.new(end_bar, tp_price, "TP +" + str.tostring(tp_points, "#.#") + " pts", style=label.style_label_left, color=color.rgb(0, 100, 0, 30), textcolor=color.lime, size=size.small)
    sl_lbl    := label.new(end_bar, sl_price, "SL -" + str.tostring(sl_points, "#.#") + " pts", style=label.style_label_left, color=color.rgb(100, 0, 0, 30), textcolor=color.red, size=size.small)

    tp_box := box.new(bar_index, sl_price, end_bar, entry_price, bgcolor=color.new(color.red, 92), border_color=color.new(color.red, 88))
    sl_box := box.new(bar_index, entry_price, end_bar, tp_price, bgcolor=color.new(color.green, 90), border_color=color.new(color.green, 85))

// ============================================================================
// SIGNAL LABELS
// ============================================================================

if show_labels and buy_signal
    label.new(bar_index, low, "BUY", style=label.style_label_up, color=bull_c, textcolor=color.black, size=size.large)

if show_labels and sell_signal
    label.new(bar_index, high, "SELL", style=label.style_label_down, color=bear_c, textcolor=color.white, size=size.large)

// ============================================================================
// VWAP
// ============================================================================

plot(show_vwap ? vwap_val : na, "VWAP", color=color.rgb(255, 215, 0), linewidth=3)

// ============================================================================
// EMA RIBBON
// ============================================================================

p9  = plot(show_emas ? ema9  : na, "EMA 9",  color=accent_c, linewidth=2)
p21 = plot(show_emas ? ema21 : na, "EMA 21", color=color.rgb(158, 158, 158), linewidth=1)
plot(show_emas ? ema50 : na, "EMA 50", color=color.rgb(80, 80, 80), linewidth=1)

fill_color = bull_trend ? color.new(color.green, 85) : color.new(color.red, 85)
fill(p9, p21, color=show_emas ? fill_color : na, title="EMA Fill")

// ============================================================================
// SESSION BACKGROUNDS
// ============================================================================

am_bg = show_sess and in_am and not in_sb ? color.new(color.green, 96) : na
sb_bg = show_sess and in_sb ? color.new(color.teal, 94) : na
pm_bg = show_sess and in_pm ? color.new(color.blue, 96) : na

bgcolor(sb_bg, title="Mid-Morning Focus BG")
bgcolor(am_bg, title="AM Session BG")
bgcolor(pm_bg, title="PM Session BG")

// Mid-morning focus label (once per window)
sb_start = in_sb and not in_sb[1]
if show_sess and sb_start
    label.new(bar_index, high, "FOCUS WINDOW", style=label.style_label_down, color=color.new(color.teal, 60), textcolor=color.white, size=size.tiny)

// ============================================================================
// BAR COLOR
// ============================================================================

bar_col = color(na)
if show_barclr
    if buy_signal or sell_signal
        bar_col := color.rgb(255, 215, 0)
    else if bull_trend
        bar_col := color.new(color.green, 70)
    else if bear_trend
        bar_col := color.new(color.red, 70)

barcolor(bar_col, title="Bar Color")

// ============================================================================
// DASHBOARD
// ============================================================================

if show_dash and barstate.islast
    var table dash = table.new(position.top_right, 2, 7, bgcolor=color.rgb(22, 22, 22, 10), border_width=1, border_color=color.rgb(60, 60, 60))

    table.cell(dash, 0, 0, "ARTILLERY", text_color=accent_c, text_size=size.small)
    table.cell(dash, 1, 0, "ELITE", text_color=bull_c, text_size=size.small)

    trend_txt = bull_trend ? "UP" : bear_trend ? "DOWN" : "FLAT"
    trend_clr = bull_trend ? color.lime : bear_trend ? color.red : color.gray
    table.cell(dash, 0, 1, "Trend", text_color=color.rgb(180, 180, 180), text_size=size.tiny)
    table.cell(dash, 1, 1, trend_txt, text_color=trend_clr, text_size=size.tiny)

    vwap_txt = close > vwap_val ? "ABOVE" : "BELOW"
    vwap_clr = close > vwap_val ? color.lime : color.red
    table.cell(dash, 0, 2, "VWAP", text_color=color.rgb(180, 180, 180), text_size=size.tiny)
    table.cell(dash, 1, 2, vwap_txt, text_color=vwap_clr, text_size=size.tiny)

    adx_clr = adx_val > 25 ? color.lime : adx_val > adx_min ? color.yellow : color.red
    table.cell(dash, 0, 3, "ADX", text_color=color.rgb(180, 180, 180), text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(adx_val, "#.#"), text_color=adx_clr, text_size=size.tiny)

    sig_txt = buy_signal ? "BUY" : sell_signal ? "SELL" : "WAIT"
    sig_clr = buy_signal ? color.lime : sell_signal ? color.red : color.gray
    table.cell(dash, 0, 4, "Signal", text_color=color.rgb(180, 180, 180), text_size=size.tiny)
    table.cell(dash, 1, 4, sig_txt, text_color=sig_clr, text_size=size.tiny)

    sess_txt = in_sb ? "FOCUS" : in_am ? "AM" : in_pm ? "PM" : "CLOSED"
    sess_clr = in_session ? color.lime : color.gray
    table.cell(dash, 0, 5, "Session", text_color=color.rgb(180, 180, 180), text_size=size.tiny)
    table.cell(dash, 1, 5, sess_txt, text_color=sess_clr, text_size=size.tiny)

    rr_val = str.tostring(tp_points / sl_points, "#.#") + ":1"
    table.cell(dash, 0, 6, "R:R", text_color=color.rgb(180, 180, 180), text_size=size.tiny)
    table.cell(dash, 1, 6, rr_val, text_color=accent_c, text_size=size.tiny)

// ============================================================================
// ALERTS
// ============================================================================

alertcondition(buy_signal, "BUY Signal", "Artillery Elite: BUY signal triggered")
alertcondition(sell_signal, "SELL Signal", "Artillery Elite: SELL signal triggered")
// end
````
