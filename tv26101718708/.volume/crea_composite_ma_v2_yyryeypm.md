# CREA Composite MA v2

- url: https://www.tradingview.com/script/YYRyEYpm-CREA-Composite-MA-v2/
- type: indicator
- pine_id: PUB;65d72f3fa6a04aafa53fde4ca011e9fc
- version: 1.0

## Description

Composite - Testing

Still under review and continuously adding features to it

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © CREA Indicators — Composite MA v2.0 (HTF Filter)
//@version=6
indicator("CREA Composite MA v2", shorttitle="CREA CMA v2", format=format.price, precision=2)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────
grp_ema  = "EMA Settings"
ema1_len = input.int(10, "EMA 1 Length", group=grp_ema)
ema2_len = input.int(20, "EMA 2 Length", group=grp_ema)

grp_comp = "Component Weights (must sum to 100)"
w_ema    = input.float(20, "EMA Bias Weight %",   group=grp_comp, minval=0, maxval=100)
w_mfi    = input.float(15, "MFI Weight %",        group=grp_comp, minval=0, maxval=100)
w_adx    = input.float(15, "ADX Weight %",        group=grp_comp, minval=0, maxval=100)
w_vol    = input.float(10, "Volatility Weight %", group=grp_comp, minval=0, maxval=100)
w_delta  = input.float(15, "Delta Weight %",      group=grp_comp, minval=0, maxval=100)
w_volume = input.float(10, "Volume Weight %",     group=grp_comp, minval=0, maxval=100)
w_mom    = input.float(15, "Momentum Weight %",   group=grp_comp, minval=0, maxval=100)

grp_sub  = "Sub-indicator Settings"
mfi_len  = input.int(14, "MFI Length",               group=grp_sub)
adx_len  = input.int(14, "ADX/DI Length",            group=grp_sub)
atr_len  = input.int(14, "ATR Length (Volatility)",  group=grp_sub)
vol_len  = input.int(20, "Volume Z-Score Lookback",  group=grp_sub)
mom_len  = input.int(10, "Momentum (ROC) Length",    group=grp_sub)

grp_htf  = "HTF Filter"
htf_on   = input.bool(true,  "Enable HTF Filter",              group=grp_htf)
htf_tf   = input.timeframe("15", "HTF Timeframe",              group=grp_htf)
htf_min  = input.float(50,   "HTF Bull min score (for BULL)",  group=grp_htf, minval=40, maxval=80)
htf_max  = input.float(50,   "HTF Bear max score (for BEAR)",  group=grp_htf, minval=20, maxval=60)
show_htf_line = input.bool(true, "Show HTF line on pane",      group=grp_htf)

grp_sig      = "Signal & Display"
sig_len      = input.int(9,     "Signal Line Length",          group=grp_sig)
show_hud     = input.bool(true, "Show Component HUD (table)",  group=grp_sig)
show_labels  = input.bool(true, "Show Buy/Sell Labels",        group=grp_sig)
bull_thresh  = input.float(60,  "Bull threshold",              group=grp_sig, minval=50, maxval=95)
bear_thresh  = input.float(40,  "Bear threshold",              group=grp_sig, minval=5,  maxval=50)

// ─────────────────────────────────────────────────────────────
// COLOURS
// ─────────────────────────────────────────────────────────────
col_strong_bull = color.new(#00C853, 0)
col_bull        = color.new(#69F0AE, 0)
col_neutral     = color.new(#90A4AE, 0)
col_bear        = color.new(#FF8A80, 0)
col_strong_bear = color.new(#D50000, 0)
col_hist_bull   = color.new(#69F0AE, 50)
col_hist_bear   = color.new(#FF8A80, 50)
col_signal      = color.new(#FFEB3B, 0)
col_htf_bull    = color.new(#00BCD4, 60)
col_htf_bear    = color.new(#FF6F00, 60)
col_blocked     = color.new(#607D8B, 0)

// ─────────────────────────────────────────────────────────────
// HELPER: normalise series to 0-100
// ─────────────────────────────────────────────────────────────
norm(src, len) =>
    lo    = ta.lowest(src, len)
    hi    = ta.highest(src, len)
    denom = hi - lo
    denom == 0 ? 50.0 : (src - lo) / denom * 100

// ─────────────────────────────────────────────────────────────
// COMPOSITE BUILDER — used for both LTF and HTF
// Takes pre-fetched OHLCV series, returns smoothed composite
// ─────────────────────────────────────────────────────────────
build_composite(float o, float h, float l, float c, float v,
                int e1l, int e2l, int mfil, int adxl,
                int atrl, int voll, int moml,
                float we, float wm, float wa,
                float wv, float wd, float wvol, float wmo) =>

    // EMA bias
    e1        = ta.ema(c, e1l)
    e2        = ta.ema(c, e2l)
    abv       = (c > e1 and c > e2) ? 1.0 : 0.0
    stk       = e1 > e2 ? 1.0 : 0.0
    e_score   = ta.ema(abv * 50 + stk * 50, 3)

    // MFI
    hlc3_s    = (h + l + c) / 3
    m_score   = ta.mfi(hlc3_s, mfil)

    // ADX DI spread
    [dip, dim, adxv] = ta.dmi(adxl, adxl)
    a_score   = norm(dip - dim, 100)

    // Volatility (inverse ATR blend)
    atr_v     = ta.atr(atrl)
    atr_p     = atr_v / c * 100
    vol_i     = 100 - norm(atr_p, 100)
    v_score   = (vol_i + e_score) / 2

    // Delta
    d_score   = norm(c - o, 50)

    // Volume z-score directional
    v_ma      = ta.sma(v, voll)
    v_std     = ta.stdev(v, voll)
    v_z       = v_std != 0 ? (v - v_ma) / v_std : 0.0
    v_sc      = math.max(0, math.min(100, (v_z + 2) / 4 * 100))
    dsign     = c >= o ? 1.0 : -1.0
    vol_score = 50 + (v_sc - 50) * dsign

    // Momentum ROC
    mo_score  = norm(ta.roc(c, moml), 100)

    // Weighted composite
    tw        = we + wm + wa + wv + wd + wvol + wmo
    tw_s      = tw == 0 ? 100.0 : tw
    raw       = (e_score * we + m_score * wm + a_score * wa + v_score * wv + d_score * wd + vol_score * wvol + mo_score * wmo) / tw_s
    ta.ema(raw, 3)

// ─────────────────────────────────────────────────────────────
// LTF COMPOSITE  (current chart timeframe)
// ─────────────────────────────────────────────────────────────
comp_smooth = build_composite(open, high, low, close, volume,
                 ema1_len, ema2_len, mfi_len, adx_len,
                 atr_len, vol_len, mom_len,
                 w_ema, w_mfi, w_adx, w_vol, w_delta, w_volume, w_mom)

signal_line = ta.ema(comp_smooth, sig_len)
hist        = comp_smooth - signal_line

// ─────────────────────────────────────────────────────────────
// HTF COMPOSITE  (request.security on selected HTF)
// Each raw series is fetched separately, then composite built
// ─────────────────────────────────────────────────────────────
htf_open   = request.security(syminfo.tickerid, htf_tf, open,   lookahead=barmerge.lookahead_off)
htf_high   = request.security(syminfo.tickerid, htf_tf, high,   lookahead=barmerge.lookahead_off)
htf_low    = request.security(syminfo.tickerid, htf_tf, low,    lookahead=barmerge.lookahead_off)
htf_close  = request.security(syminfo.tickerid, htf_tf, close,  lookahead=barmerge.lookahead_off)
htf_volume = request.security(syminfo.tickerid, htf_tf, volume, lookahead=barmerge.lookahead_off)

htf_comp = build_composite(htf_open, htf_high, htf_low, htf_close, htf_volume,
                 ema1_len, ema2_len, mfi_len, adx_len,
                 atr_len, vol_len, mom_len,
                 w_ema, w_mfi, w_adx, w_vol, w_delta, w_volume, w_mom)

// ─────────────────────────────────────────────────────────────
// HTF GATE LOGIC
// ─────────────────────────────────────────────────────────────
htf_bull_ok = not htf_on or htf_comp >= htf_min   // HTF confirms bullish
htf_bear_ok = not htf_on or htf_comp <= htf_max   // HTF confirms bearish

// ─────────────────────────────────────────────────────────────
// COLOUR LOGIC
// ─────────────────────────────────────────────────────────────
// If HTF filter is blocking, line turns slate gray
ltf_line_color = comp_smooth >= 75 ? col_strong_bull : comp_smooth >= 55 ? col_bull : comp_smooth >= 45 ? col_neutral : comp_smooth >= 25 ? col_bear : col_strong_bear

// Mute line when HTF is counter-trend
is_bull_side  = comp_smooth >= 50
is_htf_muted  = htf_on and ((is_bull_side and not htf_bull_ok) or (not is_bull_side and not htf_bear_ok))
line_color    = is_htf_muted ? col_blocked : ltf_line_color
hist_color    = hist >= 0 ? col_hist_bull : col_hist_bear
htf_line_col  = htf_comp >= 50 ? col_htf_bull : col_htf_bear

// ─────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────
hline(50,          "Midline",   color=color.new(color.gray,  70), linestyle=hline.style_dashed, linewidth=1)
hline(bull_thresh, "Bull Zone", color=color.new(color.green, 70), linestyle=hline.style_dotted)
hline(bear_thresh, "Bear Zone", color=color.new(color.red,   70), linestyle=hline.style_dotted)

bgcolor(comp_smooth > bull_thresh and htf_bull_ok ? color.new(color.green, 93) :
        comp_smooth < bear_thresh and htf_bear_ok ? color.new(color.red,   93) :
        comp_smooth > bull_thresh                 ? color.new(color.gray,  96) :
        comp_smooth < bear_thresh                 ? color.new(color.gray,  96) : na)

// HTF line (dashed, dimmed — cyan = HTF bull, orange = HTF bear)
plot(show_htf_line ? htf_comp : na, title="HTF Composite", color=htf_line_col, linewidth=1, style=plot.style_line, linestyle=plot.linestyle_dashed)

// Histogram & signal
plot(hist,        title="Histogram", style=plot.style_columns, color=hist_color, linewidth=1)
plot(signal_line, title="Signal",    color=col_signal, linewidth=1)

// Main composite line
p = plot(comp_smooth, title="CREA Composite MA", color=line_color, linewidth=3)
s = plot(signal_line, title="Signal Fill Ref",   display=display.none)
fill(p, s, color=comp_smooth > signal_line ? color.new(color.green, 88) : color.new(color.red, 88))

// ─────────────────────────────────────────────────────────────
// BUY / SELL LABELS  (gated by HTF)
// ─────────────────────────────────────────────────────────────
prev_comp  = comp_smooth[1]
bull_cross = comp_smooth > bull_thresh and prev_comp <= bull_thresh
bear_cross = comp_smooth < bear_thresh and prev_comp >= bear_thresh

bull_confirmed = bull_cross and htf_bull_ok
bear_confirmed = bear_cross and htf_bear_ok
bull_blocked   = bull_cross and not htf_bull_ok
bear_blocked   = bear_cross and not htf_bear_ok

if show_labels
    if bull_confirmed
        label.new(bar_index, comp_smooth + 3, "BULL", style=label.style_label_up,   color=color.new(color.green,   10), textcolor=color.white, size=size.small)
    else if bull_blocked
        label.new(bar_index, comp_smooth + 3, "BLK",  style=label.style_label_up,   color=color.new(color.gray,    20), textcolor=color.white, size=size.small)
    if bear_confirmed
        label.new(bar_index, comp_smooth - 3, "BEAR", style=label.style_label_down, color=color.new(color.red,     10), textcolor=color.white, size=size.small)
    else if bear_blocked
        label.new(bar_index, comp_smooth - 3, "BLK",  style=label.style_label_down, color=color.new(color.gray,    20), textcolor=color.white, size=size.small)

// ─────────────────────────────────────────────────────────────
// HUD TABLE
// ─────────────────────────────────────────────────────────────
bar_clr(float v) =>
    color res = col_neutral
    if v >= 65
        res := col_strong_bull
    else if v >= 53
        res := col_bull
    else if v >= 47
        res := col_neutral
    else if v >= 35
        res := col_bear
    else
        res := col_strong_bear
    res

if show_hud and barstate.islast
    // 11 rows: header + 7 components + composite + spacer + HTF row
    var tbl = table.new(position.bottom_right, 3, 11, bgcolor=color.new(color.black, 65), border_color=color.new(color.gray, 60), border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

    hdr_bg = color.new(#1a1a2e, 30)
    row_bg = color.new(color.black, 75)

    // Header
    table.cell(tbl, 0, 0, "Component",  text_color=color.new(color.white, 20), text_size=size.small, bgcolor=hdr_bg)
    table.cell(tbl, 1, 0, "Score",      text_color=color.new(color.white, 20), text_size=size.small, bgcolor=hdr_bg)
    table.cell(tbl, 2, 0, "Weight",     text_color=color.new(color.white, 20), text_size=size.small, bgcolor=hdr_bg)

    // Component rows
    // EMA Bias
    table.cell(tbl, 0, 1, "EMA Bias",   text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 1, str.tostring(math.round(comp_smooth, 1)), text_color=bar_clr(comp_smooth), text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 1, str.tostring(math.round(w_ema,    0)) + "%", text_color=color.new(color.silver, 30), text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // MFI
    float mfi_disp = ta.mfi(hlc3, mfi_len)
    table.cell(tbl, 0, 2, "MFI",        text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 2, str.tostring(math.round(mfi_disp,  1)), text_color=bar_clr(mfi_disp),  text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 2, str.tostring(math.round(w_mfi,     0)) + "%", text_color=color.new(color.silver, 30), text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // ADX
    [dp2, dm2, adxv2] = ta.dmi(adx_len, adx_len)
    float adx_disp = norm(dp2 - dm2, 100)
    table.cell(tbl, 0, 3, "ADX DI+-",   text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 3, str.tostring(math.round(adx_disp,  1)), text_color=bar_clr(adx_disp),  text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 3, str.tostring(math.round(w_adx,     0)) + "%", text_color=color.new(color.silver, 30), text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // Volatility
    float atr_d  = ta.atr(atr_len)
    float vol_d  = (100 - norm(atr_d / close * 100, 100) + comp_smooth) / 2
    table.cell(tbl, 0, 4, "Volatility", text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 4, str.tostring(math.round(vol_d,     1)), text_color=bar_clr(vol_d),     text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 4, str.tostring(math.round(w_vol,     0)) + "%", text_color=color.new(color.silver, 30), text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // Delta
    float dlt_d  = norm(close - open, 50)
    table.cell(tbl, 0, 5, "Delta",      text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 5, str.tostring(math.round(dlt_d,     1)), text_color=bar_clr(dlt_d),     text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 5, str.tostring(math.round(w_delta,   0)) + "%", text_color=color.new(color.silver, 30), text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // Volume
    float vma_d  = ta.sma(volume, vol_len)
    float vst_d  = ta.stdev(volume, vol_len)
    float vz_d   = vst_d != 0 ? (volume - vma_d) / vst_d : 0.0
    float vsc_d  = math.max(0, math.min(100, (vz_d + 2) / 4 * 100))
    float vdir_d = 50 + (vsc_d - 50) * (close >= open ? 1.0 : -1.0)
    table.cell(tbl, 0, 6, "Volume",     text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 6, str.tostring(math.round(vdir_d,    1)), text_color=bar_clr(vdir_d),    text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 6, str.tostring(math.round(w_volume,  0)) + "%", text_color=color.new(color.silver, 30), text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // Momentum
    float mom_d  = norm(ta.roc(close, mom_len), 100)
    table.cell(tbl, 0, 7, "Momentum",   text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 7, str.tostring(math.round(mom_d,     1)), text_color=bar_clr(mom_d),     text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 7, str.tostring(math.round(w_mom,     0)) + "%", text_color=color.new(color.silver, 30), text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // Composite row
    comp_bg = color.new(bar_clr(comp_smooth), 55)
    table.cell(tbl, 0, 8, "COMPOSITE",  text_color=color.white, text_size=size.small, bgcolor=comp_bg)
    table.cell(tbl, 1, 8, str.tostring(math.round(comp_smooth, 1)), text_color=color.white, text_size=size.small, bgcolor=comp_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 8, "---",        text_color=color.white, text_size=size.small, bgcolor=comp_bg, text_halign=text.align_center)

    // Spacer
    table.cell(tbl, 0, 9, "",  bgcolor=color.new(color.black, 90), text_size=size.small)
    table.cell(tbl, 1, 9, "",  bgcolor=color.new(color.black, 90), text_size=size.small)
    table.cell(tbl, 2, 9, "",  bgcolor=color.new(color.black, 90), text_size=size.small)

    // HTF row
    htf_status  = htf_on ? (htf_comp >= 50 ? "BULL" : "BEAR") : "OFF"
    htf_gate_ok = (htf_comp >= 50 and htf_bull_ok) or (htf_comp < 50 and htf_bear_ok)
    htf_row_col = not htf_on ? color.new(color.gray, 40) : htf_comp >= 50 ? color.new(#00BCD4, 30) : color.new(#FF6F00, 30)
    htf_txt_col = not htf_on ? color.new(color.gray, 20) : color.white
    table.cell(tbl, 0, 10, "HTF " + htf_tf,  text_color=htf_txt_col, text_size=size.small, bgcolor=htf_row_col)
    table.cell(tbl, 1, 10, str.tostring(math.round(htf_comp, 1)), text_color=htf_txt_col, text_size=size.small, bgcolor=htf_row_col, text_halign=text.align_center)
    table.cell(tbl, 2, 10, htf_status,        text_color=htf_txt_col, text_size=size.small, bgcolor=htf_row_col, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────────
// ALERTS  (HTF-gated)
// ─────────────────────────────────────────────────────────────
alertcondition(bull_confirmed,                              title="CREA CMA - Bull Signal (HTF OK)",    message="CREA CMA BULL confirmed - HTF aligned ({{ticker}} / {{interval}}) | Score: {{close}}")
alertcondition(bear_confirmed,                              title="CREA CMA - Bear Signal (HTF OK)",    message="CREA CMA BEAR confirmed - HTF aligned ({{ticker}} / {{interval}}) | Score: {{close}}")
alertcondition(bull_blocked,                                title="CREA CMA - Bull BLOCKED by HTF",     message="CREA CMA bull cross BLOCKED by HTF filter ({{ticker}} / {{interval}})")
alertcondition(bear_blocked,                                title="CREA CMA - Bear BLOCKED by HTF",     message="CREA CMA bear cross BLOCKED by HTF filter ({{ticker}} / {{interval}})")
alertcondition(ta.crossover(comp_smooth, signal_line),      title="CREA CMA - Line cross up",           message="CMA crossed above signal ({{ticker}})")
alertcondition(ta.crossunder(comp_smooth, signal_line),     title="CREA CMA - Line cross down",         message="CMA crossed below signal ({{ticker}})")
````
