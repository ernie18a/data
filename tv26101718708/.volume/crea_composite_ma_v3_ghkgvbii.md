# CREA Composite MA v3

- url: https://www.tradingview.com/script/GHKgvbii-CREA-Composite-MA-v3/
- type: indicator
- pine_id: PUB;849c3ecd476d4035b9b698c2df002eaf
- version: 1.0

## Description

Here's a clean description you can use as the indicator's published description on TradingView:

CREA Composite MA v3 — Multi-Layer Confluence Indicator
CREA Composite MA is a momentum and trend confluence engine disguised as a moving average. Rather than plotting a single indicator, it combines seven sub-indicators into one normalised 0–100 composite score, then runs that score through three layers of confirmation before generating a signal.
The seven components:

EMA Bias (EMA10/20 stack and price position)
MFI (Money Flow Index)
ADX with +DI/−DI directional spread
Volatility (inverse ATR%, environment-adjusted)
Delta (candle body direction and size)
Volume (Z-score, directionally weighted)
Momentum (Rate of Change, normalised)

Each component is independently normalised to 0–100. Scores above 50 are bullish, below 50 are bearish. All weights are fully adjustable.
Three confirmation layers:
Layer 1 — Component agreement: counts how many of the 7 sub-indicators individually agree with the direction. A composite score of 65 built on 6/7 components is treated differently from one built on 2 components spiking hard.
Layer 2 — HTF filter: rebuilds the full composite on a user-selected higher timeframe (default 15m) and gates signals accordingly. Bull signals are suppressed when the HTF composite is bearish, and vice versa. The HTF line is plotted directly on the pane so both timeframes are visible simultaneously.
Layer 3 — Score velocity: measures the 3-bar rate of change of the composite itself. A rising score carries more weight than a flat one at the same level.
Two-tier signal system:

EARLY (yellow) — fires on signal line crossover when ≥4/7 components agree and HTF is aligned. Appears before the threshold is reached, giving advance warning of a potential confirmed signal.
CONFIRMED (green/red) — fires on threshold cross when ≥5/7 components agree and HTF is aligned. Labelled with confidence tier (HIGH / MED / LOW) and agreement count (e.g. BULL HIGH 6/7).
BLOCKED (gray) — threshold was crossed but confirmation gates rejected it. Useful for auditing filter performance.

Confidence tiers:

HIGH — 6–7 components agree + velocity moving in signal direction
MED — 5+ components agree
LOW — 4+ components agree

HUD table (bottom-right) shows all seven component scores in real time, color-coded by strength, alongside the composite score, HTF score and bias, confidence tier, and velocity direction.
7 alert conditions included: Early Bull/Bear, Confirmed Bull/Bear, Blocked Bull/Bear, and HIGH Confidence.
All lengths, weights, thresholds, and filter settings are fully configurable via the settings panel.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © CREA Indicators — Composite MA v3.0 (HTF + Confidence + Early Entry)
//@version=6
indicator("CREA Composite MA v3", shorttitle="CREA CMA v3", format=format.price, precision=2)

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
mfi_len  = input.int(14, "MFI Length",              group=grp_sub)
adx_len  = input.int(14, "ADX/DI Length",           group=grp_sub)
atr_len  = input.int(14, "ATR Length (Volatility)", group=grp_sub)
vol_len  = input.int(20, "Volume Z-Score Lookback", group=grp_sub)
mom_len  = input.int(10, "Momentum (ROC) Length",   group=grp_sub)

grp_htf       = "HTF Filter"
htf_on        = input.bool(true,  "Enable HTF Filter",             group=grp_htf)
htf_tf        = input.timeframe("15", "HTF Timeframe",             group=grp_htf)
htf_min       = input.float(50,   "HTF Bull min score",            group=grp_htf, minval=40, maxval=80)
htf_max       = input.float(50,   "HTF Bear max score",            group=grp_htf, minval=20, maxval=60)
show_htf_line = input.bool(true,  "Show HTF line on pane",         group=grp_htf)

grp_conf      = "Confidence & Early Entry"
early_agree   = input.int(4,    "Min components for EARLY signal", group=grp_conf, minval=3, maxval=7)
conf_agree    = input.int(5,    "Min components for CONFIRMED",    group=grp_conf, minval=4, maxval=7)
show_early    = input.bool(true, "Show Early entry labels",        group=grp_conf)
show_velocity = input.bool(true, "Show score velocity line",       group=grp_conf)
vel_len       = input.int(3,    "Velocity lookback (bars)",        group=grp_conf, minval=2, maxval=10)

grp_sig       = "Signal & Display"
sig_len       = input.int(9,     "Signal Line Length",             group=grp_sig)
show_hud      = input.bool(true, "Show Component HUD (table)",     group=grp_sig)
show_labels   = input.bool(true, "Show Confirmed/Blocked labels",  group=grp_sig)
bull_thresh   = input.float(60,  "Bull threshold",                 group=grp_sig, minval=50, maxval=95)
bear_thresh   = input.float(40,  "Bear threshold",                 group=grp_sig, minval=5,  maxval=50)

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
col_early_bull  = color.new(#FFD600, 0)
col_early_bear  = color.new(#FF9800, 0)
col_velocity    = color.new(#CE93D8, 70)

// ─────────────────────────────────────────────────────────────
// HELPER: normalise series to 0-100
// ─────────────────────────────────────────────────────────────
norm(src, len) =>
    lo    = ta.lowest(src, len)
    hi    = ta.highest(src, len)
    denom = hi - lo
    denom == 0 ? 50.0 : (src - lo) / denom * 100

// ─────────────────────────────────────────────────────────────
// COMPOSITE BUILDER
// Returns [smoothed_composite, s1, s2, s3, s4, s5, s6, s7]
// s1-s7 = individual component scores for agreement counting
// ─────────────────────────────────────────────────────────────
build_composite(float o, float h, float l, float c, float v,
                int e1l, int e2l, int mfil, int adxl,
                int atrl, int voll, int moml,
                float we, float wm, float wa,
                float wv, float wd, float wvol, float wmo) =>

    // 1. EMA bias
    e1        = ta.ema(c, e1l)
    e2        = ta.ema(c, e2l)
    abv       = (c > e1 and c > e2) ? 1.0 : 0.0
    stk       = e1 > e2 ? 1.0 : 0.0
    s_ema     = ta.ema(abv * 50 + stk * 50, 3)

    // 2. MFI
    hlc3_s    = (h + l + c) / 3
    s_mfi     = ta.mfi(hlc3_s, mfil)

    // 3. ADX DI spread
    [dip, dim, adxv] = ta.dmi(adxl, adxl)
    s_adx     = norm(dip - dim, 100)

    // 4. Volatility
    atr_v     = ta.atr(atrl)
    atr_p     = atr_v / c * 100
    vol_i     = 100 - norm(atr_p, 100)
    s_vol     = (vol_i + s_ema) / 2

    // 5. Delta
    s_delta   = norm(c - o, 50)

    // 6. Volume z-score directional
    v_ma      = ta.sma(v, voll)
    v_std     = ta.stdev(v, voll)
    v_z       = v_std != 0 ? (v - v_ma) / v_std : 0.0
    v_sc      = math.max(0, math.min(100, (v_z + 2) / 4 * 100))
    dsign     = c >= o ? 1.0 : -1.0
    s_volume  = 50 + (v_sc - 50) * dsign

    // 7. Momentum ROC
    s_mom     = norm(ta.roc(c, moml), 100)

    // Weighted composite
    tw        = we + wm + wa + wv + wd + wvol + wmo
    tw_s      = tw == 0 ? 100.0 : tw
    raw       = (s_ema * we + s_mfi * wm + s_adx * wa + s_vol * wv + s_delta * wd + s_volume * wvol + s_mom * wmo) / tw_s
    comp      = ta.ema(raw, 3)

    [comp, s_ema, s_mfi, s_adx, s_vol, s_delta, s_volume, s_mom]

// ─────────────────────────────────────────────────────────────
// LTF COMPOSITE
// ─────────────────────────────────────────────────────────────
[comp_smooth, s_ema, s_mfi, s_adx, s_vol, s_delta, s_volume, s_mom] =
     build_composite(open, high, low, close, volume,
         ema1_len, ema2_len, mfi_len, adx_len,
         atr_len, vol_len, mom_len,
         w_ema, w_mfi, w_adx, w_vol, w_delta, w_volume, w_mom)

signal_line = ta.ema(comp_smooth, sig_len)
hist        = comp_smooth - signal_line

// ─────────────────────────────────────────────────────────────
// SCORE VELOCITY  (rate of change of composite, normalised)
// ─────────────────────────────────────────────────────────────
vel_raw      = comp_smooth - comp_smooth[vel_len]
vel_norm     = norm(vel_raw, 50)   // 0-100: 50=flat, >50=rising, <50=falling
vel_rising   = vel_norm > 55
vel_falling  = vel_norm < 45

// ─────────────────────────────────────────────────────────────
// COMPONENT AGREEMENT COUNT
// How many of the 7 components are individually bullish (>50)
// ─────────────────────────────────────────────────────────────
agree_bull = (s_ema > 50 ? 1 : 0) + (s_mfi > 50 ? 1 : 0) + (s_adx > 50 ? 1 : 0) + (s_vol > 50 ? 1 : 0) + (s_delta > 50 ? 1 : 0) + (s_volume > 50 ? 1 : 0) + (s_mom > 50 ? 1 : 0)
agree_bear = 7 - agree_bull

// ─────────────────────────────────────────────────────────────
// CONFIDENCE TIER
// HIGH  = 6-7 components agree + velocity confirms
// MED   = 5 components agree
// LOW   = 4 components agree
// ─────────────────────────────────────────────────────────────
is_bull_side = comp_smooth >= 50

conf_agree_count = is_bull_side ? agree_bull : agree_bear
conf_vel_ok      = is_bull_side ? vel_rising : vel_falling

confidence_high = conf_agree_count >= 6 and conf_vel_ok
confidence_med  = conf_agree_count >= 5
confidence_low  = conf_agree_count >= 4

conf_label = confidence_high ? "HIGH" : confidence_med ? "MED" : confidence_low ? "LOW" : "WEAK"

// ─────────────────────────────────────────────────────────────
// HTF COMPOSITE
// ─────────────────────────────────────────────────────────────
htf_open   = request.security(syminfo.tickerid, htf_tf, open,   lookahead=barmerge.lookahead_off)
htf_high   = request.security(syminfo.tickerid, htf_tf, high,   lookahead=barmerge.lookahead_off)
htf_low    = request.security(syminfo.tickerid, htf_tf, low,    lookahead=barmerge.lookahead_off)
htf_close  = request.security(syminfo.tickerid, htf_tf, close,  lookahead=barmerge.lookahead_off)
htf_volume = request.security(syminfo.tickerid, htf_tf, volume, lookahead=barmerge.lookahead_off)

[htf_comp, _h1, _h2, _h3, _h4, _h5, _h6, _h7] =
     build_composite(htf_open, htf_high, htf_low, htf_close, htf_volume,
         ema1_len, ema2_len, mfi_len, adx_len,
         atr_len, vol_len, mom_len,
         w_ema, w_mfi, w_adx, w_vol, w_delta, w_volume, w_mom)

htf_bull_ok = not htf_on or htf_comp >= htf_min
htf_bear_ok = not htf_on or htf_comp <= htf_max

// ─────────────────────────────────────────────────────────────
// SIGNAL LOGIC — TWO TIERS
// ─────────────────────────────────────────────────────────────
prev_comp   = comp_smooth[1]
prev_signal = signal_line[1]

// Confirmed: threshold cross + min agreement + HTF aligned
bull_cross      = comp_smooth > bull_thresh and prev_comp <= bull_thresh
bear_cross      = comp_smooth < bear_thresh and prev_comp >= bear_thresh
bull_confirmed  = bull_cross and agree_bull >= conf_agree and htf_bull_ok
bear_confirmed  = bear_cross and agree_bear >= conf_agree and htf_bear_ok
bull_blocked    = bull_cross and (agree_bull < conf_agree or not htf_bull_ok)
bear_blocked    = bear_cross and (agree_bear < conf_agree or not htf_bear_ok)

// Early: signal line crossover + min agreement + HTF aligned + not already in confirmed zone
bull_sig_cross  = ta.crossover(comp_smooth, signal_line)
bear_sig_cross  = ta.crossunder(comp_smooth, signal_line)

// Early fires only when composite is NOT already past the threshold (avoid duplicate)
bull_early      = bull_sig_cross and agree_bull >= early_agree and htf_bull_ok and comp_smooth < bull_thresh
bear_early      = bear_sig_cross and agree_bear >= early_agree and htf_bear_ok and comp_smooth > bear_thresh

// ─────────────────────────────────────────────────────────────
// COLOUR LOGIC
// ─────────────────────────────────────────────────────────────
ltf_line_color  = comp_smooth >= 75 ? col_strong_bull : comp_smooth >= 55 ? col_bull : comp_smooth >= 45 ? col_neutral : comp_smooth >= 25 ? col_bear : col_strong_bear
is_htf_muted    = htf_on and ((is_bull_side and not htf_bull_ok) or (not is_bull_side and not htf_bear_ok))
line_color      = is_htf_muted ? col_blocked : ltf_line_color
hist_color      = hist >= 0 ? col_hist_bull : col_hist_bear
htf_line_col    = htf_comp >= 50 ? col_htf_bull : col_htf_bear

// ─────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────
hline(50,          "Midline",   color=color.new(color.gray,  70), linestyle=hline.style_dashed,  linewidth=1)
hline(bull_thresh, "Bull Zone", color=color.new(color.green, 70), linestyle=hline.style_dotted)
hline(bear_thresh, "Bear Zone", color=color.new(color.red,   70), linestyle=hline.style_dotted)

bgcolor(comp_smooth > bull_thresh and htf_bull_ok ? color.new(color.green, 93) :
        comp_smooth < bear_thresh and htf_bear_ok ? color.new(color.red,   93) :
        comp_smooth > bull_thresh                 ? color.new(color.gray,  96) :
        comp_smooth < bear_thresh                 ? color.new(color.gray,  96) : na)

// HTF dashed line
plot(show_htf_line ? htf_comp : na, title="HTF Composite", color=htf_line_col, linewidth=1, linestyle=plot.linestyle_dashed)

// Velocity line (thin, purple — shows score momentum)
plot(show_velocity ? vel_norm : na, title="Score Velocity", color=col_velocity, linewidth=1, linestyle=plot.linestyle_dotted)

// Histogram & signal
plot(hist,        title="Histogram", style=plot.style_columns, color=hist_color, linewidth=1)
plot(signal_line, title="Signal",    color=col_signal, linewidth=1)

// Main composite line
p = plot(comp_smooth, title="CREA Composite MA", color=line_color, linewidth=3)
s = plot(signal_line, title="Signal Fill Ref",   display=display.none)
fill(p, s, color=comp_smooth > signal_line ? color.new(color.green, 88) : color.new(color.red, 88))

// ─────────────────────────────────────────────────────────────
// LABELS
// ─────────────────────────────────────────────────────────────

// Early labels (yellow — signal line cross, pre-threshold)
if show_early
    if bull_early
        label.new(bar_index, comp_smooth + 2, "E+" + str.tostring(agree_bull) + "/7",
             style=label.style_label_up, color=col_early_bull,
             textcolor=color.black, size=size.small)
    if bear_early
        label.new(bar_index, comp_smooth - 2, "E-" + str.tostring(agree_bear) + "/7",
             style=label.style_label_down, color=col_early_bear,
             textcolor=color.black, size=size.small)

// Confirmed / blocked labels
if show_labels
    if bull_confirmed
        label.new(bar_index, comp_smooth + 4,
             "BULL " + conf_label + " " + str.tostring(agree_bull) + "/7",
             style=label.style_label_up,   color=color.new(color.green, 10),
             textcolor=color.white, size=size.small)
    else if bull_blocked
        label.new(bar_index, comp_smooth + 4, "BLK",
             style=label.style_label_up,   color=color.new(color.gray, 20),
             textcolor=color.white, size=size.small)
    if bear_confirmed
        label.new(bar_index, comp_smooth - 4,
             "BEAR " + conf_label + " " + str.tostring(agree_bear) + "/7",
             style=label.style_label_down, color=color.new(color.red, 10),
             textcolor=color.white, size=size.small)
    else if bear_blocked
        label.new(bar_index, comp_smooth - 4, "BLK",
             style=label.style_label_down, color=color.new(color.gray, 20),
             textcolor=color.white, size=size.small)

// ─────────────────────────────────────────────────────────────
// HUD TABLE
// 13 rows: header + 7 components + composite + spacer + HTF + confidence + velocity
// ─────────────────────────────────────────────────────────────
conf_cnt_disp = is_bull_side ? agree_bull : agree_bear
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
    var tbl = table.new(position.bottom_right, 3, 13,
         bgcolor=color.new(color.black, 65), border_color=color.new(color.gray, 60),
         border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

    hdr_bg = color.new(#1a1a2e, 30)
    row_bg = color.new(color.black, 75)

    // Header
    table.cell(tbl, 0, 0, "Component",  text_color=color.new(color.white, 20), text_size=size.small, bgcolor=hdr_bg)
    table.cell(tbl, 1, 0, "Score",      text_color=color.new(color.white, 20), text_size=size.small, bgcolor=hdr_bg)
    table.cell(tbl, 2, 0, "Wt / Info",  text_color=color.new(color.white, 20), text_size=size.small, bgcolor=hdr_bg)

    wt_col = color.new(color.silver, 30)

    // Row 1: EMA Bias
    table.cell(tbl, 0, 1, "EMA Bias",   text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 1, str.tostring(math.round(s_ema,     1)), text_color=bar_clr(s_ema),     text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 1, str.tostring(math.round(w_ema,     0)) + "%", text_color=wt_col, text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // Row 2: MFI
    table.cell(tbl, 0, 2, "MFI",        text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 2, str.tostring(math.round(s_mfi,     1)), text_color=bar_clr(s_mfi),     text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 2, str.tostring(math.round(w_mfi,     0)) + "%", text_color=wt_col, text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // Row 3: ADX
    table.cell(tbl, 0, 3, "ADX DI+-",   text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 3, str.tostring(math.round(s_adx,     1)), text_color=bar_clr(s_adx),     text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 3, str.tostring(math.round(w_adx,     0)) + "%", text_color=wt_col, text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // Row 4: Volatility
    table.cell(tbl, 0, 4, "Volatility", text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 4, str.tostring(math.round(s_vol,     1)), text_color=bar_clr(s_vol),     text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 4, str.tostring(math.round(w_vol,     0)) + "%", text_color=wt_col, text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // Row 5: Delta
    table.cell(tbl, 0, 5, "Delta",      text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 5, str.tostring(math.round(s_delta,   1)), text_color=bar_clr(s_delta),   text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 5, str.tostring(math.round(w_delta,   0)) + "%", text_color=wt_col, text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // Row 6: Volume
    table.cell(tbl, 0, 6, "Volume",     text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 6, str.tostring(math.round(s_volume,  1)), text_color=bar_clr(s_volume),  text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 6, str.tostring(math.round(w_volume,  0)) + "%", text_color=wt_col, text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // Row 7: Momentum
    table.cell(tbl, 0, 7, "Momentum",   text_color=color.silver, text_size=size.small, bgcolor=row_bg)
    table.cell(tbl, 1, 7, str.tostring(math.round(s_mom,     1)), text_color=bar_clr(s_mom),     text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 7, str.tostring(math.round(w_mom,     0)) + "%", text_color=wt_col, text_size=size.small, bgcolor=row_bg, text_halign=text.align_center)

    // Row 8: Composite
    comp_bg = color.new(bar_clr(comp_smooth), 55)
    table.cell(tbl, 0, 8, "COMPOSITE",  text_color=color.white, text_size=size.small, bgcolor=comp_bg)
    table.cell(tbl, 1, 8, str.tostring(math.round(comp_smooth, 1)), text_color=color.white, text_size=size.small, bgcolor=comp_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 8, "---",        text_color=color.white, text_size=size.small, bgcolor=comp_bg, text_halign=text.align_center)

    // Spacer
    table.cell(tbl, 0, 9, "", bgcolor=color.new(color.black, 90), text_size=size.small)
    table.cell(tbl, 1, 9, "", bgcolor=color.new(color.black, 90), text_size=size.small)
    table.cell(tbl, 2, 9, "", bgcolor=color.new(color.black, 90), text_size=size.small)

    // Row 10: HTF
    htf_status  = htf_on ? (htf_comp >= 50 ? "BULL" : "BEAR") : "OFF"
    htf_row_col = not htf_on ? color.new(color.gray, 40) : htf_comp >= 50 ? color.new(#00BCD4, 30) : color.new(#FF6F00, 30)
    htf_txt_col = not htf_on ? color.new(color.gray, 20) : color.white
    table.cell(tbl, 0, 10, "HTF " + htf_tf, text_color=htf_txt_col, text_size=size.small, bgcolor=htf_row_col)
    table.cell(tbl, 1, 10, str.tostring(math.round(htf_comp, 1)), text_color=htf_txt_col, text_size=size.small, bgcolor=htf_row_col, text_halign=text.align_center)
    table.cell(tbl, 2, 10, htf_status,       text_color=htf_txt_col, text_size=size.small, bgcolor=htf_row_col, text_halign=text.align_center)

    // Row 11: Confidence
    conf_bg  = confidence_high ? color.new(color.green, 30) : confidence_med ? color.new(color.teal, 40) : color.new(color.gray, 50)
    table.cell(tbl, 0, 11, "Confidence", text_color=color.white, text_size=size.small, bgcolor=conf_bg)
    table.cell(tbl, 1, 11, conf_label,   text_color=color.white, text_size=size.small, bgcolor=conf_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 11, str.tostring(conf_cnt_disp) + "/7", text_color=color.white, text_size=size.small, bgcolor=conf_bg, text_halign=text.align_center)

    // Row 12: Velocity
    vel_txt = vel_rising ? "RISING" : vel_falling ? "FALLING" : "FLAT"
    vel_bg  = vel_rising ? color.new(color.purple, 40) : vel_falling ? color.new(color.orange, 40) : color.new(color.gray, 55)
    table.cell(tbl, 0, 12, "Velocity",   text_color=color.white, text_size=size.small, bgcolor=vel_bg)
    table.cell(tbl, 1, 12, str.tostring(math.round(vel_norm, 1)), text_color=color.white, text_size=size.small, bgcolor=vel_bg, text_halign=text.align_center)
    table.cell(tbl, 2, 12, vel_txt,      text_color=color.white, text_size=size.small, bgcolor=vel_bg, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────

alertcondition(bull_early,      title="CREA CMA - Early Bull",       message="CREA CMA: EARLY bull signal - signal line cross ({{ticker}} / {{interval}})")
alertcondition(bear_early,      title="CREA CMA - Early Bear",       message="CREA CMA: EARLY bear signal - signal line cross ({{ticker}} / {{interval}})")
alertcondition(bull_confirmed,  title="CREA CMA - Bull Confirmed",   message="CREA CMA: BULL confirmed - HTF aligned ({{ticker}} / {{interval}})")
alertcondition(bear_confirmed,  title="CREA CMA - Bear Confirmed",   message="CREA CMA: BEAR confirmed - HTF aligned ({{ticker}} / {{interval}})")
alertcondition(bull_blocked,    title="CREA CMA - Bull Blocked",     message="CREA CMA: Bull cross BLOCKED - low agreement or HTF counter-trend ({{ticker}})")
alertcondition(bear_blocked,    title="CREA CMA - Bear Blocked",     message="CREA CMA: Bear cross BLOCKED - low agreement or HTF counter-trend ({{ticker}})")
alertcondition(confidence_high, title="CREA CMA - HIGH Confidence",  message="CREA CMA: HIGH confidence signal active ({{ticker}} / {{interval}})")
````
