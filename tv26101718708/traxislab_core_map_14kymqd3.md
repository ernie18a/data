# TraxisLab - Core Map

- url: https://www.tradingview.com/script/14KYMQd3/
- type: indicator
- pine_id: PUB;0b9dafc654574e43a7346bc7f73e6739
- version: 1.0

## Description

TraxisLab Core Map is a clean market-structure and analysis layer designed to give traders a clear overview of price, volume, trend, and key reference levels without entry signals, sweep clutter, or unnecessary noise.

This indicator combines Vector Candles, anchored VWAP levels, Daily Open, EMAs, and a Rolling POC / Value Area model into one lightweight visual framework.

The goal of Core Map is simple:
to help traders read where price is trading relative to important volume, session, and trend references.

Key Features

Vector Candles
Highlights candles with unusually strong volume-spread force compared to the recent average.
Extreme vectors are separated from regular vectors to make high-effort candles easier to identify.

Custom Candle Coloring
Bullish, bearish, normal, vector, and extreme candles can all be customized individually.

Multi-Timeframe VWAP Anchors
Displays VWAP levels anchored to:

Daily
Weekly
Monthly
4H

Each VWAP is drawn as a clean horizontal reference line with optional labels and projection.

Daily Open
Shows the current daily open as a key intraday reference level.

EMAs
Includes three customizable exponential moving averages:

Fast EMA
Mid EMA
Slow EMA

Useful for trend context and dynamic support/resistance.

Rolling POC
Calculates a rolling Point of Control based on recent volume distribution across price bins.

Value Area High / Value Area Low
Optional VAH and VAL levels help visualize the current rolling value area around the POC.

Small Info Table
A compact table displays current vector status, POC, daily VWAP, and daily open.

How to Use

Use this indicator as a market map, not as a standalone signal system.

Core Map is designed to help answer questions like:

Is price above or below the Daily Open?
Is price reacting around Daily, Weekly, or 4H VWAP?
Where is the current rolling POC?
Is price trading inside or outside the value area?
Are strong vector candles appearing at important reference levels?
Are EMAs aligned with the current market direction?

The strongest use case is combining the visual levels with your own trading model, session context, and confirmation tools.

Notes

This script does not generate buy or sell signals.
It is intended as a clean analytical overlay for discretionary traders.

The Rolling POC is an approximation based on selected lookback bars and price bins. It is designed for visual context and may differ from exchange-native volume profile tools.

Disclaimer

This indicator is for educational and analytical purposes only.
It does not provide financial advice, trading recommendations, or guaranteed results. Always use proper risk management and perform your own analysis before making trading decisions.

## Source Code

````pine
//@version=5
// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ TRAXISLAB — CORE MAP v1.0                                                ║
// ║ Vector Candles · VWAP Anchors · Daily Open · EMAs · Rolling POC           ║
// ║ Clean analysis layer, no entries, no sweep clutter                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

indicator("TraxisLab — Core Map", "TraxisLab CORE", true,
     max_labels_count=300, max_lines_count=300, max_boxes_count=100,
     max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════

grp_vc = "⟐ Vector Candles"
i_vc_on       = input.bool(true, "Vector Candles Active", group=grp_vc)
i_vc_lookback = input.int(20, "Lookback", minval=5, maxval=100, group=grp_vc)
i_vc_thresh   = input.float(1.5, "Vector Threshold (×)", minval=1.0, maxval=5.0, step=0.1, group=grp_vc)
i_vc_extreme  = input.float(2.5, "Extreme Threshold (×)", minval=1.5, maxval=8.0, step=0.1, group=grp_vc)
i_vc_minbody  = input.float(0.30, "Min Body Ratio", minval=0.1, maxval=0.8, step=0.02, group=grp_vc)

c_vc_bull     = input.color(#2f80ed, "Bull Vector", group=grp_vc, inline="vc1")
c_vc_bull_x   = input.color(#00ff1a, "Bull Extreme", group=grp_vc, inline="vc1")
c_vc_bear     = input.color(#f000ff, "Bear Vector", group=grp_vc, inline="vc2")
c_vc_bear_x   = input.color(#ff3547, "Bear Extreme", group=grp_vc, inline="vc2")
c_vc_neu_up   = input.color(#16bfd1, "Normal Bull", group=grp_vc, inline="vc3")
c_vc_neu_dn   = input.color(#ffffff, "Normal Bear", group=grp_vc, inline="vc3")

i_vc_dim      = input.int(10, "Dim Normal (%)", minval=0, maxval=90, step=5, group=grp_vc)
i_vc_dots     = input.bool(false, "Vector Dots", group=grp_vc)
i_vc_labels   = input.bool(false, "Extreme Labels", group=grp_vc)

grp_ema = "⟐ EMAs"
i_ema_on   = input.bool(true, "Show EMAs", group=grp_ema)
i_ema_1    = input.int(21, "EMA Fast", minval=1, maxval=500, group=grp_ema)
i_ema_2    = input.int(50, "EMA Mid", minval=1, maxval=500, group=grp_ema)
i_ema_3    = input.int(200, "EMA Slow", minval=1, maxval=500, group=grp_ema)
c_ema_1    = input.color(#00e5ff, "EMA Fast Color", group=grp_ema, inline="e1")
c_ema_2    = input.color(#ffc107, "EMA Mid Color", group=grp_ema, inline="e2")
c_ema_3    = input.color(#787b86, "EMA Slow Color", group=grp_ema, inline="e3")
i_ema_w    = input.int(1, "EMA Width", minval=1, maxval=4, group=grp_ema)

grp_anchor = "⟐ Volume Anchors / VWAP"
i_vwap_d = input.bool(true, "VWAP Daily", inline="v1", group=grp_anchor)
c_vwap_d = input.color(#ffc107, "", inline="v1", group=grp_anchor)
i_vwap_w = input.bool(true, "VWAP Weekly", inline="v2", group=grp_anchor)
c_vwap_w = input.color(#00e676, "", inline="v2", group=grp_anchor)
i_vwap_m = input.bool(false, "VWAP Monthly", inline="v3", group=grp_anchor)
c_vwap_m = input.color(#ff1744, "", inline="v3", group=grp_anchor)
i_vwap_4h = input.bool(true, "VWAP 4H", inline="v4", group=grp_anchor)
c_vwap_4h = input.color(#e040fb, "", inline="v4", group=grp_anchor)

i_do_on = input.bool(true, "Daily Open", inline="do", group=grp_anchor)
c_do    = input.color(#ffffff, "", inline="do", group=grp_anchor)

i_anchor_len  = input.int(70, "Anchor Line Length", minval=10, maxval=500, group=grp_anchor)
i_anchor_proj = input.int(8, "Project Right", minval=0, maxval=50, group=grp_anchor)
i_anchor_lbl  = input.bool(true, "Anchor Labels", group=grp_anchor)
i_anchor_w    = input.int(2, "Anchor Width", minval=1, maxval=4, group=grp_anchor)

grp_poc = "⟐ Rolling POC"
i_poc_on      = input.bool(true, "Show Rolling POC", group=grp_poc)
i_poc_len     = input.int(200, "POC Lookback Bars", minval=50, maxval=1000, group=grp_poc)
i_poc_bins    = input.int(48, "POC Price Bins", minval=16, maxval=120, group=grp_poc)
i_poc_src     = input.string("HLC3", "POC Price Source", options=["Close", "HLC3", "OHLC4"], group=grp_poc)
i_poc_va_on   = input.bool(true, "Show Value Area", group=grp_poc)
i_poc_va_pct  = input.int(70, "Value Area %", minval=50, maxval=95, group=grp_poc)
i_poc_lenline = input.int(120, "POC Line Length", minval=20, maxval=500, group=grp_poc)
i_poc_proj    = input.int(8, "POC Project Right", minval=0, maxval=50, group=grp_poc)
i_poc_lbl     = input.bool(true, "POC Labels", group=grp_poc)
c_poc         = input.color(#ffffff, "POC Color", group=grp_poc)
c_vah         = input.color(#00e676, "VAH Color", group=grp_poc)
c_val         = input.color(#ff1744, "VAL Color", group=grp_poc)

grp_vis = "⟐ Visual Control"
i_show_stats = input.bool(true, "Small Info Table", group=grp_vis)

// ═══════════════════════════════════════════════════════════════════════════
// VECTOR CANDLES
// ═══════════════════════════════════════════════════════════════════════════

spread = high - low
body = math.abs(close - open)
body_ratio = spread > 0 ? body / spread : 0.0

is_bull_candle = close > open
is_bear_candle = close < open

force = volume * spread
avg_force = ta.sma(force, i_vc_lookback)
rel_force = avg_force > 0 ? force / avg_force : 0.0

is_vec = rel_force >= i_vc_thresh and body_ratio >= i_vc_minbody
is_ext = rel_force >= i_vc_extreme and body_ratio >= i_vc_minbody

is_vec_bull = is_vec and is_bull_candle
is_vec_bear = is_vec and is_bear_candle
is_ext_bull = is_ext and is_bull_candle
is_ext_bear = is_ext and is_bear_candle

color vc_color = na

if i_vc_on
    if is_ext_bull
        vc_color := c_vc_bull_x
    else if is_ext_bear
        vc_color := c_vc_bear_x
    else if is_vec_bull
        vc_color := c_vc_bull
    else if is_vec_bear
        vc_color := c_vc_bear
    else if is_bull_candle
        vc_color := color.new(c_vc_neu_up, i_vc_dim)
    else if is_bear_candle
        vc_color := color.new(c_vc_neu_dn, i_vc_dim)

barcolor(vc_color)

plotshape(i_vc_on and i_vc_dots and is_vec_bull and not is_ext_bull, "Vector Bull Dot", shape.circle, location.belowbar, c_vc_bull, size=size.tiny)
plotshape(i_vc_on and i_vc_dots and is_vec_bear and not is_ext_bear, "Vector Bear Dot", shape.circle, location.abovebar, c_vc_bear, size=size.tiny)

if i_vc_on and i_vc_labels and is_ext_bull and barstate.isconfirmed
    label.new(bar_index, low - spread * 0.25, "V", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(c_vc_bull_x, 10), textcolor=color.white, size=size.tiny, tooltip="Extreme Bull Vector\nForce: " + str.tostring(rel_force, "#.0") + "×")

if i_vc_on and i_vc_labels and is_ext_bear and barstate.isconfirmed
    label.new(bar_index, high + spread * 0.25, "V", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(c_vc_bear_x, 10), textcolor=color.white, size=size.tiny, tooltip="Extreme Bear Vector\nForce: " + str.tostring(rel_force, "#.0") + "×")

// ═══════════════════════════════════════════════════════════════════════════
// EMAs
// ═══════════════════════════════════════════════════════════════════════════

ema_1 = ta.ema(close, i_ema_1)
ema_2 = ta.ema(close, i_ema_2)
ema_3 = ta.ema(close, i_ema_3)

plot(i_ema_on ? ema_1 : na, "EMA Fast", color.new(c_ema_1, 0), i_ema_w)
plot(i_ema_on ? ema_2 : na, "EMA Mid", color.new(c_ema_2, 0), i_ema_w)
plot(i_ema_on ? ema_3 : na, "EMA Slow", color.new(c_ema_3, 0), i_ema_w)

// ═══════════════════════════════════════════════════════════════════════════
// VWAP ANCHORS + DAILY OPEN
// ═══════════════════════════════════════════════════════════════════════════

hlc3_v = hlc3
vol_v = math.max(volume, 1)

new_d = ta.change(time("D")) != 0
new_w = ta.change(time("W")) != 0
new_m = ta.change(time("M")) != 0
new_4h = ta.change(time("240")) != 0

var float d_pv = 0.0
var float d_v = 0.0
var float w_pv = 0.0
var float w_v = 0.0
var float m_pv = 0.0
var float m_v = 0.0
var float h_pv = 0.0
var float h_v = 0.0

var int d_bar = na
var int w_bar = na
var int m_bar = na
var int h_bar = na

if barstate.isfirst or new_d
    d_pv := hlc3_v * vol_v
    d_v := vol_v
    d_bar := bar_index
else
    d_pv += hlc3_v * vol_v
    d_v += vol_v

if barstate.isfirst or new_w
    w_pv := hlc3_v * vol_v
    w_v := vol_v
    w_bar := bar_index
else
    w_pv += hlc3_v * vol_v
    w_v += vol_v

if barstate.isfirst or new_m
    m_pv := hlc3_v * vol_v
    m_v := vol_v
    m_bar := bar_index
else
    m_pv += hlc3_v * vol_v
    m_v += vol_v

if barstate.isfirst or new_4h
    h_pv := hlc3_v * vol_v
    h_v := vol_v
    h_bar := bar_index
else
    h_pv += hlc3_v * vol_v
    h_v += vol_v

vwap_d = d_v > 0 ? d_pv / d_v : hlc3_v
vwap_w = w_v > 0 ? w_pv / w_v : hlc3_v
vwap_m = m_v > 0 ? m_pv / m_v : hlc3_v
vwap_4h = h_v > 0 ? h_pv / h_v : hlc3_v

daily_open = request.security(syminfo.tickerid, "D", open, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_anchor_line(line old_line, bool show, float price, int x1, int x2, color col, int width) =>
    if not na(old_line)
        line.delete(old_line)
    line nl = na
    if show and not na(price)
        nl := line.new(x1, price, x2, price, xloc=xloc.bar_index, extend=extend.none, color=color.new(col, 0), width=width)
    nl

f_anchor_label(label old_label, bool show, float price, int x, string txt, color col) =>
    if not na(old_label)
        label.delete(old_label)
    label nl = na
    if show and not na(price)
        nl := label.new(x, price, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(col, 75), textcolor=col, size=size.tiny)
    nl

var line ln_d = na
var line ln_w = na
var line ln_m = na
var line ln_4h = na
var line ln_do = na

var label lb_d = na
var label lb_w = na
var label lb_m = na
var label lb_4h = na
var label lb_do = na

if barstate.islast
    int x2 = bar_index + i_anchor_proj
    int xd = math.max(nz(d_bar, bar_index), bar_index - i_anchor_len)
    int xw = math.max(nz(w_bar, bar_index), bar_index - i_anchor_len)
    int xm = math.max(nz(m_bar, bar_index), bar_index - i_anchor_len)
    int xh = math.max(nz(h_bar, bar_index), bar_index - i_anchor_len)

    ln_d := f_anchor_line(ln_d, i_vwap_d, vwap_d, xd, x2, c_vwap_d, i_anchor_w)
    ln_w := f_anchor_line(ln_w, i_vwap_w, vwap_w, xw, x2, c_vwap_w, i_anchor_w)
    ln_m := f_anchor_line(ln_m, i_vwap_m, vwap_m, xm, x2, c_vwap_m, i_anchor_w)
    ln_4h := f_anchor_line(ln_4h, i_vwap_4h, vwap_4h, xh, x2, c_vwap_4h, i_anchor_w)
    ln_do := f_anchor_line(ln_do, i_do_on, daily_open, xd, x2, c_do, i_anchor_w)

    lb_d := f_anchor_label(lb_d, i_anchor_lbl and i_vwap_d, vwap_d, x2 + 1, "VWAP-D", c_vwap_d)
    lb_w := f_anchor_label(lb_w, i_anchor_lbl and i_vwap_w, vwap_w, x2 + 1, "VWAP-W", c_vwap_w)
    lb_m := f_anchor_label(lb_m, i_anchor_lbl and i_vwap_m, vwap_m, x2 + 1, "VWAP-M", c_vwap_m)
    lb_4h := f_anchor_label(lb_4h, i_anchor_lbl and i_vwap_4h, vwap_4h, x2 + 1, "VWAP-4H", c_vwap_4h)
    lb_do := f_anchor_label(lb_do, i_anchor_lbl and i_do_on, daily_open, x2 + 1, "D-OPEN", c_do)

// ═══════════════════════════════════════════════════════════════════════════
// ROLLING POC
// ═══════════════════════════════════════════════════════════════════════════

f_poc_src(int i) =>
    i_poc_src == "Close" ? close[i] : i_poc_src == "OHLC4" ? (open[i] + high[i] + low[i] + close[i]) / 4.0 : (high[i] + low[i] + close[i]) / 3.0

var line ln_poc = na
var line ln_vah = na
var line ln_val = na

var label lb_poc = na
var label lb_vah = na
var label lb_val = na

var float poc_price = na
var float vah_price = na
var float val_price = na

if barstate.islast and i_poc_on
    int bars_available = math.min(i_poc_len, bar_index + 1)
    float lo = ta.lowest(low, bars_available)
    float hi = ta.highest(high, bars_available)
    float rng = hi - lo

    if rng > 0
        array<float> bins = array.new_float(i_poc_bins, 0.0)

        for i = 0 to bars_available - 1
            float p = f_poc_src(i)
            int idx = int(math.floor((p - lo) / rng * (i_poc_bins - 1)))
            idx := math.max(0, math.min(i_poc_bins - 1, idx))
            array.set(bins, idx, array.get(bins, idx) + volume[i])

        float max_vol = 0.0
        int max_idx = 0
        float total_vol = 0.0

        for b = 0 to i_poc_bins - 1
            float bv = array.get(bins, b)
            total_vol += bv
            if bv > max_vol
                max_vol := bv
                max_idx := b

        float step = rng / i_poc_bins
        poc_price := lo + (max_idx + 0.5) * step

        int left = max_idx
        int right = max_idx
        float acc = max_vol
        float target = total_vol * i_poc_va_pct / 100.0

        while acc < target and (left > 0 or right < i_poc_bins - 1)
            float lv = left > 0 ? array.get(bins, left - 1) : -1.0
            float rv = right < i_poc_bins - 1 ? array.get(bins, right + 1) : -1.0

            if rv > lv
                right += 1
                acc += rv
            else
                left -= 1
                acc += lv

        val_price := lo + left * step
        vah_price := lo + (right + 1) * step

    int x1p = math.max(0, bar_index - i_poc_lenline)
    int x2p = bar_index + i_poc_proj

    ln_poc := f_anchor_line(ln_poc, i_poc_on, poc_price, x1p, x2p, c_poc, 2)
    ln_vah := f_anchor_line(ln_vah, i_poc_on and i_poc_va_on, vah_price, x1p, x2p, c_vah, 1)
    ln_val := f_anchor_line(ln_val, i_poc_on and i_poc_va_on, val_price, x1p, x2p, c_val, 1)

    lb_poc := f_anchor_label(lb_poc, i_poc_lbl, poc_price, x2p + 1, "POC", c_poc)
    lb_vah := f_anchor_label(lb_vah, i_poc_lbl and i_poc_va_on, vah_price, x2p + 1, "VAH", c_vah)
    lb_val := f_anchor_label(lb_val, i_poc_lbl and i_poc_va_on, val_price, x2p + 1, "VAL", c_val)

// ═══════════════════════════════════════════════════════════════════════════
// SMALL TABLE
// ═══════════════════════════════════════════════════════════════════════════

var table t = table.new(position.bottom_right, 2, 5, bgcolor=color.new(#0f1119, 12), border_width=1, border_color=color.new(#2a2d3a, 65))

if i_show_stats and barstate.islast
    table.cell(t, 0, 0, "CORE", text_color=color.white, text_size=size.tiny, bgcolor=color.new(#1a1d28, 25))
    table.cell(t, 1, 0, "Clean Map", text_color=c_vwap_d, text_size=size.tiny, bgcolor=color.new(#1a1d28, 25))

    table.cell(t, 0, 1, "Vector", text_color=#5a5e70, text_size=size.tiny)
    table.cell(t, 1, 1, is_ext ? str.tostring(rel_force, "#.0") + "× EXT" : is_vec ? str.tostring(rel_force, "#.0") + "×" : "—", text_color=is_ext ? c_vc_bull_x : is_vec ? c_vc_bull : color.gray, text_size=size.tiny)

    table.cell(t, 0, 2, "POC", text_color=#5a5e70, text_size=size.tiny)
    table.cell(t, 1, 2, i_poc_on and not na(poc_price) ? str.tostring(poc_price, format.mintick) : "—", text_color=c_poc, text_size=size.tiny)

    table.cell(t, 0, 3, "VWAP-D", text_color=#5a5e70, text_size=size.tiny)
    table.cell(t, 1, 3, str.tostring(vwap_d, format.mintick), text_color=c_vwap_d, text_size=size.tiny)

    table.cell(t, 0, 4, "D-Open", text_color=#5a5e70, text_size=size.tiny)
    table.cell(t, 1, 4, str.tostring(daily_open, format.mintick), text_color=c_do, text_size=size.tiny)
````
