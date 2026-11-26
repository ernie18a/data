# ROCKIT Market Internals

- url: https://www.tradingview.com/script/v6YH9bvT-ROCKIT-Market-Internals/
- type: indicator
- pine_id: PUB;e220d36e3edd47ddaf6681eb58fb5d73
- version: 2.0

## Description

The indicator showing NQ score rating of Mag7 and SOXX index, improving ,neutral or degrading.  Helps to watch market internals.

## Source Code

````pine
// © ROCKIT Framework — Market Internals Indicator
// Mirrors the exact scoring logic in modules/market_internals.py (NQ) and
// the ES inline scoring from .claude/skills/internals/SKILL.md (ES).
//
// Add to a NEW PANE below your NQ/ES chart on the 15-min timeframe.
// Works on any symbol — all data is fetched independently via request.security().
//
// Plots
//   • NQ Score  (blue,  -10..+10)  — MAG7 + SOX + VIX + Sector Rotation + NDX Breadth
//   • ES Score  (orange, -10..+10) — 11 GICS sectors (weighted) + RSP/SPY + VIX + XLF
//   • Gap NQ-ES (histogram)        — positive=GROWTH LEADING, negative=VALUE LEADING
//   • MAG7 Scaled (purple)         — breadth 0-7 mapped to -10..+10
//
// Table (top-right) shows live regime readings for all key sub-components.
// Alerts fire on regime transitions and breadth extremes.
//@version=5
indicator("ROCKIT Market Internals", shorttitle="ROCKIT INT", overlay=false, max_bars_back=500)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
grp_d = "Display"
show_nq    = input.bool(true,  "NQ Score",              group=grp_d)
show_es    = input.bool(true,  "ES Score",              group=grp_d)
show_gap   = input.bool(true,  "Score Gap NQ−ES",       group=grp_d)
show_mag7  = input.bool(true,  "MAG7 Breadth (scaled)", group=grp_d)
show_tbl   = input.bool(true,  "Info Table",            group=grp_d)
rth_only   = input.bool(true,  "RTH Only (hide globex)",group=grp_d)
tbl_pos_in = input.string("top_right", "Table Position",
                 options=["top_right","top_left","bottom_right","bottom_left"],
                 group=grp_d)

// ─── HELPER: daily % change in one security call ─────────────────────────────
daily_pct(string sym) =>
    [d, d1] = request.security(sym, "D", [close, close[1]], lookahead=barmerge.lookahead_on)
    nz((d - d1) / d1 * 100.0)

// ─── MARKET ETFs ─────────────────────────────────────────────────────────────
spy_pct  = daily_pct("AMEX:SPY")
qqq_pct  = daily_pct("NASDAQ:QQQ")
soxx_pct = daily_pct("NASDAQ:SOXX")
rsp_pct  = daily_pct("AMEX:RSP")

// ─── VIX (tuple to save one security call) ───────────────────────────────────
[vix_now, vix_prev] = request.security("TVC:VIX", "D", [close, close[1]], lookahead=barmerge.lookahead_on)
vix_level = nz(vix_now, 18.0)
vix_prev_v = nz(vix_prev, 18.0)
// 1=rising  -1=falling  0=flat
vix_dir = vix_level > vix_prev_v * 1.01 ? 1 : vix_level < vix_prev_v * 0.99 ? -1 : 0

// ─── MAG7 (7 names) ──────────────────────────────────────────────────────────
nvda_pct  = daily_pct("NASDAQ:NVDA")
aapl_pct  = daily_pct("NASDAQ:AAPL")
msft_pct  = daily_pct("NASDAQ:MSFT")
amzn_pct  = daily_pct("NASDAQ:AMZN")
meta_pct  = daily_pct("NASDAQ:META")
googl_pct = daily_pct("NASDAQ:GOOGL")
tsla_pct  = daily_pct("NASDAQ:TSLA")

mag7_count = (nvda_pct  > 0 ? 1 : 0) + (aapl_pct  > 0 ? 1 : 0) + (msft_pct  > 0 ? 1 : 0) +
             (amzn_pct  > 0 ? 1 : 0) + (meta_pct  > 0 ? 1 : 0) + (googl_pct > 0 ? 1 : 0) +
             (tsla_pct  > 0 ? 1 : 0)

// ─── NDX TOP-20 BREADTH (remaining 13 beyond MAG7) ───────────────────────────
// Proxy: "above prior close" instead of "above VWAP" (impossible for external
// symbols in Pine Script). Direction is the same signal.
avgo_pct  = daily_pct("NASDAQ:AVGO")
cost_pct  = daily_pct("NASDAQ:COST")
nflx_pct  = daily_pct("NASDAQ:NFLX")
amd_pct   = daily_pct("NASDAQ:AMD")
qcom_pct  = daily_pct("NASDAQ:QCOM")
adbe_pct  = daily_pct("NASDAQ:ADBE")
arm_pct   = daily_pct("NASDAQ:ARM")
panw_pct  = daily_pct("NASDAQ:PANW")
cdns_pct  = daily_pct("NASDAQ:CDNS")
crwd_pct  = daily_pct("NASDAQ:CRWD")
mrvl_pct  = daily_pct("NASDAQ:MRVL")
intc_pct  = daily_pct("NASDAQ:INTC")
asml_pct  = daily_pct("NASDAQ:ASML")

ndx_extra1  = (avgo_pct > 0 ? 1 : 0) + (cost_pct > 0 ? 1 : 0) + (nflx_pct > 0 ? 1 : 0) + (amd_pct  > 0 ? 1 : 0) + (qcom_pct > 0 ? 1 : 0) + (adbe_pct > 0 ? 1 : 0) + (arm_pct  > 0 ? 1 : 0)
ndx_extra2  = (panw_pct > 0 ? 1 : 0) + (cdns_pct > 0 ? 1 : 0) + (crwd_pct > 0 ? 1 : 0) + (mrvl_pct > 0 ? 1 : 0) + (intc_pct > 0 ? 1 : 0) + (asml_pct > 0 ? 1 : 0)
ndx20_above = mag7_count + ndx_extra1 + ndx_extra2

ndx20_pct_above = ndx20_above / 20.0 * 100.0

// ─── SECTOR ETFs ─────────────────────────────────────────────────────────────
// NQ sectors (rotation signal: XLK/XLC/XLY = risk-on; XLV/XLU/XLP = defensive)
xlk_pct  = daily_pct("AMEX:XLK")    // Tech           (NQ + ES weight 25%)
xlc_pct  = daily_pct("AMEX:XLC")    // Comm Services  (NQ + ES weight 10%)
xly_pct  = daily_pct("AMEX:XLY")    // Cons Disc      (NQ + ES weight 12%)
xlv_pct  = daily_pct("AMEX:XLV")    // Health Care    defensive (ES 8%)
xlu_pct  = daily_pct("AMEX:XLU")    // Utilities      defensive (ES 5%)
xlp_pct  = daily_pct("AMEX:XLP")    // Cons Staples   defensive (ES 5%)
// Additional ES sectors
xlf_pct  = daily_pct("AMEX:XLF")    // Financials     (ES 15%)
xli_pct  = daily_pct("AMEX:XLI")    // Industrials    (ES 8%)
xle_pct  = daily_pct("AMEX:XLE")    // Energy         (ES 5%)
xlb_pct  = daily_pct("AMEX:XLB")    // Materials      (ES 4%)
xlre_pct = daily_pct("AMEX:XLRE")   // Real Estate    (ES 3%)

// ═══════════════════════════════════════════════════════════════════════════════
// NQ SCORE   (matches modules/market_internals.py exactly)
// ═══════════════════════════════════════════════════════════════════════════════

// 1) MAG7: (count/7)*6 − 3  →  range −3..+3
s_mag7 = (mag7_count / 7.0) * 6.0 - 3.0

// 2) SOX/NQ delta: clip(Δ * 2, −2, +2)
sox_nq_delta = soxx_pct - qqq_pct
s_sox = math.max(-2.0, math.min(2.0, sox_nq_delta * 2.0))

// 3) VIX regime  →  range −2..+2
s_vix = vix_level < 16 and vix_dir == -1 ? 2.0 : vix_level < 16 ? 1.5 : vix_level < 20 and vix_dir == -1 ? 1.0 : vix_level < 20 and vix_dir == 1 ? -0.5 : vix_level < 25 and vix_dir == 1 ? -1.5 : vix_level >= 25 ? -2.0 : 0.0

// 4) Sector rotation:
//    risk_on  = XLK/XLC/XLY beating SPY by >-0.05% (outperforming or in-line)
//    defensive= XLV/XLU/XLP beating SPY by >+0.10%  (clearly outperforming safety)
//    score = (risk_on_count − defensive_count) * 0.5  →  range −1.5..+1.5
risk_on_cnt  = (xlk_pct > spy_pct - 0.05 ? 1 : 0) +
               (xlc_pct > spy_pct - 0.05 ? 1 : 0) +
               (xly_pct > spy_pct - 0.05 ? 1 : 0)
def_cnt      = (xlv_pct > spy_pct + 0.10 ? 1 : 0) +
               (xlu_pct > spy_pct + 0.10 ? 1 : 0) +
               (xlp_pct > spy_pct + 0.10 ? 1 : 0)
s_sector = (risk_on_cnt - def_cnt) * 0.5

// 5) NDX breadth (above prior close proxy for above VWAP)  →  range −1.5..+1.5
s_ndx = ndx20_pct_above >= 70 ? 1.5 : ndx20_pct_above >= 55 ? 0.75 : ndx20_pct_above >= 40 ? 0.0 : ndx20_pct_above >= 25 ? -0.75 : -1.5

nq_score = math.max(-10.0, math.min(10.0, s_mag7 + s_sox + s_vix + s_sector + s_ndx))

// ═══════════════════════════════════════════════════════════════════════════════
// ES SCORE   (from .claude/skills/internals/SKILL.md inline Python)
// ═══════════════════════════════════════════════════════════════════════════════

// Weighted sector contribution: offensive = positive delta → positive score;
// defensive = positive delta vs SPY → NEGATIVE score (rotation to safety = bearish)
// formula: sign * direction * min(|Δ|/0.5, 1.0) * weight * 6.0
es_contrib(float delta, bool is_def, float w) =>
    s_dir = is_def ? -1.0 : 1.0
    mag   = math.min(math.abs(delta) / 0.5, 1.0)
    s_dir * (delta > 0 ? 1.0 : -1.0) * mag * w * 6.0

es_step1 = es_contrib(xlk_pct  - spy_pct, false, 0.25) +
           es_contrib(xlf_pct  - spy_pct, false, 0.15) +
           es_contrib(xly_pct  - spy_pct, false, 0.12) +
           es_contrib(xlc_pct  - spy_pct, false, 0.10) +
           es_contrib(xli_pct  - spy_pct, false, 0.08) +
           es_contrib(xlv_pct  - spy_pct, true,  0.08) +
           es_contrib(xlp_pct  - spy_pct, true,  0.05) +
           es_contrib(xle_pct  - spy_pct, false, 0.05) +
           es_contrib(xlu_pct  - spy_pct, true,  0.05) +
           es_contrib(xlb_pct  - spy_pct, false, 0.04) +
           es_contrib(xlre_pct - spy_pct, false, 0.03)

rsp_spy_delta = rsp_pct - spy_pct
es_step2 = rsp_spy_delta >= 0.3 ? 1.0 : rsp_spy_delta <= -0.3 ? -1.0 : 0.0

es_step3 = s_vix  // same VIX formula as NQ

xlf_vs_spy = xlf_pct - spy_pct
es_step4 = xlf_vs_spy >= 0.5 ? 0.5 : xlf_vs_spy <= -1.0 ? -0.5 : 0.0

es_score = math.max(-10.0, math.min(10.0, es_step1 + es_step2 + es_step3 + es_step4))

// ─── DERIVED METRICS ─────────────────────────────────────────────────────────
score_gap         = nq_score - es_score              // + = NQ stronger, - = ES stronger
es_nq_price_delta = spy_pct  - qqq_pct               // + = ES outperforming NQ price-wise
def_avg           = (xlv_pct + xlu_pct + xlp_pct) / 3.0
off_avg           = (xlk_pct + xly_pct + xlf_pct) / 3.0
def_vs_off        = def_avg - off_avg                 // + = defensive rotation (risk-off)

sectors_beat_spy = (xlk_pct > spy_pct ? 1 : 0) + (xlf_pct > spy_pct ? 1 : 0) +
                   (xly_pct > spy_pct ? 1 : 0) + (xlc_pct > spy_pct ? 1 : 0) +
                   (xli_pct > spy_pct ? 1 : 0) + (xlv_pct > spy_pct ? 1 : 0) +
                   (xlp_pct > spy_pct ? 1 : 0) + (xle_pct > spy_pct ? 1 : 0) +
                   (xlu_pct > spy_pct ? 1 : 0) + (xlb_pct > spy_pct ? 1 : 0) +
                   (xlre_pct > spy_pct ? 1 : 0)

// ─── REGIME HELPERS ──────────────────────────────────────────────────────────
regime_label(float s) =>
    s >= 6 ? "VERY STRONG" : s >= 2 ? "IMPROVING" : s >= -2 ? "NEUTRAL" : s >= -6 ? "FADING" : "COLLAPSING"

regime_color(float s) =>
    s >= 6 ? #00e676 : s >= 2 ? #69f0ae : s >= -2 ? #90a4ae : s >= -6 ? #ff7043 : #d32f2f

// Helper for signed strings in table
sgn(float v, string fmt) =>
    (v > 0 ? "+" : "") + str.tostring(v, fmt)

// MAG7 scaled to the score pane −10..+10 for visual comparison
mag7_scaled = (mag7_count / 7.0) * 20.0 - 10.0

// ─── RTH SESSION FILTER ──────────────────────────────────────────────────────
is_rth   = not na(time("1", "0930-1600", "America/New_York"))
show_bar = not rth_only or is_rth

// ═══════════════════════════════════════════════════════════════════════════════
// BACKGROUND + REFERENCE LINES
// ═══════════════════════════════════════════════════════════════════════════════
nq_bg_col = nq_score >= 6 ? color.new(#00e676, 92) : nq_score >= 2 ? color.new(#69f0ae, 93) : nq_score <= -6 ? color.new(#d32f2f, 90) : nq_score <= -2 ? color.new(#ff7043, 93) : color.new(#607d8b, 96)
bgcolor(show_bar ? nq_bg_col : na, title="NQ Regime Band")

hline(0,   "Zero",         color.new(#78909c, 40), hline.style_solid,  1)
hline( 6,  "+6 Very Str",  color.new(#00e676, 60), hline.style_dashed, 1)
hline( 2,  "+2 Improving", color.new(#69f0ae, 60), hline.style_dashed, 1)
hline(-2,  "-2 Fading",    color.new(#ff7043, 60), hline.style_dashed, 1)
hline(-6,  "-6 Collapsng", color.new(#d32f2f, 60), hline.style_dashed, 1)

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN PLOTS
// ═══════════════════════════════════════════════════════════════════════════════
// Invisible scale anchors — pin pane to -10..+10
plot(show_bar ?  10.0 : na, display=display.none, editable=false)
plot(show_bar ? -10.0 : na, display=display.none, editable=false)

plot(show_nq   ? (show_bar ? nq_score    : na) : na, "NQ Score",
     color=color.new(#2196f3, 0), linewidth=2)

plot(show_es   ? (show_bar ? es_score    : na) : na, "ES Score",
     color=color.new(#ff9800, 0), linewidth=2)

plot(show_gap  ? (show_bar ? score_gap   : na) : na, "Gap NQ-ES",
     color=score_gap >= 0 ? color.new(#00bcd4, 35) : color.new(#e91e63, 35),
     linewidth=1, style=plot.style_histogram)

plot(show_mag7 ? (show_bar ? mag7_scaled : na) : na, "MAG7 (scaled -10..+10)",
     color=color.new(#9c27b0, 40), linewidth=1, style=plot.style_line)

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(ta.crossover(nq_score, 6),    "NQ → VERY STRONG",  "NQ internals: VERY STRONG (+6)")
alertcondition(ta.crossover(nq_score, 2),    "NQ → IMPROVING",    "NQ internals: crossed into IMPROVING (+2)")
alertcondition(ta.crossunder(nq_score, -2),  "NQ → FADING",       "NQ internals: crossed into FADING (-2)")
alertcondition(ta.crossunder(nq_score, -6),  "NQ → COLLAPSING",   "NQ internals: COLLAPSING — contrarian LONG WATCH")
alertcondition(ta.crossover(es_score, 2),    "ES → IMPROVING",    "ES internals: crossed into IMPROVING")
alertcondition(ta.crossunder(es_score, -2),  "ES → FADING",       "ES internals: crossed into FADING")
alertcondition(mag7_count == 7,              "MAG7 7/7 Green",    "All 7 MAG7 names above prior close")
alertcondition(mag7_count <= 1,              "MAG7 Narrow ≤1/7",  "Breadth collapse: MAG7 ≤1/7 green")
alertcondition(math.abs(score_gap) >= 3,     "NQ-ES Gap ≥3",      "Large divergence: NQ-ES gap >= 3 pts")
alertcondition(xlf_vs_spy <= -1.0,           "XLF Stress",        "Financials stress: XLF lagging SPY by >1%")
alertcondition(def_vs_off >= 0.5,            "Defensive Rotation","Risk-off: defensive sectors outperforming offensive")

// ═══════════════════════════════════════════════════════════════════════════════
// INFO TABLE  (barstate.islast → only rendered on the most recent bar)
// ═══════════════════════════════════════════════════════════════════════════════
if show_tbl and barstate.islast
    tbl_pos = tbl_pos_in == "top_right" ? position.top_right : tbl_pos_in == "top_left" ? position.top_left : tbl_pos_in == "bottom_right" ? position.bottom_right : position.bottom_left

    t = table.new(tbl_pos, 3, 16,
                  bgcolor      = color.new(#0a0a14, 8),
                  border_color = color.new(#263238, 70),
                  border_width = 1,
                  frame_color  = color.new(#263238, 50),
                  frame_width  = 1)

    // ── Header ───────────────────────────────────────────────────────────────
    hdr = color.new(#0d47a1, 15)
    table.cell(t, 0, 0, "METRIC",    text_color=#eceff1, text_size=size.small, bgcolor=hdr, text_halign=text.align_left)
    table.cell(t, 1, 0, "VALUE",     text_color=#eceff1, text_size=size.small, bgcolor=hdr)
    table.cell(t, 2, 0, "SIGNAL",    text_color=#eceff1, text_size=size.small, bgcolor=hdr)

    // ── NQ Score ─────────────────────────────────────────────────────────────
    nq_c = color.new(regime_color(nq_score), 0)
    table.cell(t, 0, 1, "NQ Score",  text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 1, sgn(math.round(nq_score,1), "0.0"), text_color=nq_c, text_size=size.small)
    table.cell(t, 2, 1, regime_label(nq_score), text_color=nq_c, text_size=size.small)

    // ── ES Score ─────────────────────────────────────────────────────────────
    es_c = color.new(regime_color(es_score), 0)
    table.cell(t, 0, 2, "ES Score",  text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 2, sgn(math.round(es_score,1), "0.0"), text_color=es_c, text_size=size.small)
    table.cell(t, 2, 2, regime_label(es_score), text_color=es_c, text_size=size.small)

    // ── Score Gap ────────────────────────────────────────────────────────────
    gap_c = score_gap >= 2 ? color.new(#00e5ff, 0) : score_gap <= -2 ? color.new(#ff4081, 0) : color.new(#78909c, 0)
    gap_lbl = score_gap >= 2 ? "GROWTH LEAD" : score_gap <= -2 ? "VALUE LEAD" : "ALIGNED"
    table.cell(t, 0, 3, "Gap NQ-ES", text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 3, sgn(math.round(score_gap,1), "0.0"), text_color=gap_c, text_size=size.small)
    table.cell(t, 2, 3, gap_lbl, text_color=gap_c, text_size=size.small)

    // ── Section: NQ Components ───────────────────────────────────────────────
    sep = color.new(#1a237e, 60)
    table.cell(t, 0, 4, "── NQ COMPONENTS ──", text_color=#546e7a, text_size=size.tiny, text_halign=text.align_left, bgcolor=sep)
    table.cell(t, 1, 4, "", text_size=size.tiny, bgcolor=sep)
    table.cell(t, 2, 4, "", text_size=size.tiny, bgcolor=sep)

    // MAG7 Breadth
    m7_c = mag7_count >= 5 ? #69f0ae : mag7_count >= 3 ? #ffeb3b : #ff5252
    m7_l = mag7_count >= 5 ? "BROAD" : mag7_count >= 3 ? "MIXED" : "NARROW ⚠"
    table.cell(t, 0, 5, "MAG7 Brdth", text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 5, str.tostring(mag7_count) + "/7", text_color=color.new(m7_c,0), text_size=size.small)
    table.cell(t, 2, 5, m7_l, text_color=color.new(m7_c,0), text_size=size.small)

    // NDX Top-20 breadth
    nd_c = ndx20_pct_above >= 65 ? #69f0ae : ndx20_pct_above >= 45 ? #ffeb3b : #ff5252
    nd_l = ndx20_pct_above >= 65 ? "BROAD" : ndx20_pct_above >= 45 ? "MIXED" : "NARROW"
    table.cell(t, 0, 6, "NDX20 >Prev", text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 6, str.tostring(math.round(ndx20_pct_above,0)) + "%", text_color=color.new(nd_c,0), text_size=size.small)
    table.cell(t, 2, 6, nd_l, text_color=color.new(nd_c,0), text_size=size.small)

    // SOX/NQ delta
    sx_c = sox_nq_delta >= 0.3 ? #69f0ae : sox_nq_delta <= -0.3 ? #ff5252 : #90a4ae
    sx_l = sox_nq_delta >= 0.3 ? "LEADING ✓" : sox_nq_delta <= -0.3 ? "LAGGING ⚠" : "NEUTRAL"
    table.cell(t, 0, 7, "SOX Δ NQ",   text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 7, sgn(math.round(sox_nq_delta,2), "0.00") + "%", text_color=color.new(sx_c,0), text_size=size.small)
    table.cell(t, 2, 7, sx_l, text_color=color.new(sx_c,0), text_size=size.small)

    // Sector rotation signal
    rot_c = risk_on_cnt >= 2 and def_cnt == 0 ? #69f0ae : def_cnt >= 2 and risk_on_cnt == 0 ? #ff5252 : #90a4ae
    rot_l = risk_on_cnt >= 2 and def_cnt == 0 ? "RISK-ON ✓" : def_cnt >= 2 and risk_on_cnt == 0 ? "RISK-OFF ⚠" : "NEUTRAL"
    rot_val = "R" + str.tostring(risk_on_cnt) + " D" + str.tostring(def_cnt)
    table.cell(t, 0, 8, "Sector Rot",  text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 8, rot_val, text_color=color.new(rot_c,0), text_size=size.small)
    table.cell(t, 2, 8, rot_l, text_color=color.new(rot_c,0), text_size=size.small)

    // ── Section: ES Components ───────────────────────────────────────────────
    sep2 = color.new(#4a148c, 60)
    table.cell(t, 0, 9, "── ES COMPONENTS ──", text_color=#546e7a, text_size=size.tiny, text_halign=text.align_left, bgcolor=sep2)
    table.cell(t, 1, 9, "", text_size=size.tiny, bgcolor=sep2)
    table.cell(t, 2, 9, "", text_size=size.tiny, bgcolor=sep2)

    // Sectors beating SPY
    sb_c = sectors_beat_spy >= 7 ? #69f0ae : sectors_beat_spy >= 5 ? #ffeb3b : #ff5252
    table.cell(t, 0, 10, "Sectors>SPY", text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 10, str.tostring(sectors_beat_spy) + "/11", text_color=color.new(sb_c,0), text_size=size.small)
    table.cell(t, 2, 10, sectors_beat_spy >= 7 ? "BROAD" : sectors_beat_spy >= 5 ? "MIXED" : "NARROW", text_color=color.new(sb_c,0), text_size=size.small)

    // RSP/SPY delta (equal-weight vs cap-weight)
    rsp_c = rsp_spy_delta >= 0.3 ? #69f0ae : rsp_spy_delta <= -0.3 ? #ff5252 : #90a4ae
    rsp_l = rsp_spy_delta >= 0.3 ? "BROAD BULL" : rsp_spy_delta <= -0.3 ? "NARROW" : "NEUTRAL"
    table.cell(t, 0, 11, "RSP/SPY Δ",  text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 11, sgn(math.round(rsp_spy_delta,2), "0.00") + "%", text_color=color.new(rsp_c,0), text_size=size.small)
    table.cell(t, 2, 11, rsp_l, text_color=color.new(rsp_c,0), text_size=size.small)

    // XLF vs SPY (financials stress is the most bearish ES signal)
    xlf_c = xlf_vs_spy >= 0.5 ? #69f0ae : xlf_vs_spy <= -1.0 ? #ff5252 : #90a4ae
    xlf_l = xlf_vs_spy >= 0.5 ? "STRONG" : xlf_vs_spy <= -1.0 ? "STRESS ⚠" : "NEUTRAL"
    table.cell(t, 0, 12, "XLF vs SPY", text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 12, sgn(math.round(xlf_vs_spy,2), "0.00") + "%", text_color=color.new(xlf_c,0), text_size=size.small)
    table.cell(t, 2, 12, xlf_l, text_color=color.new(xlf_c,0), text_size=size.small)

    // Def vs Offensive rotation
    dvo_c = def_vs_off >= 0.3 ? #ff7043 : def_vs_off <= -0.3 ? #69f0ae : #90a4ae
    dvo_l = def_vs_off >= 0.3 ? "RISK-OFF ⚠" : def_vs_off <= -0.3 ? "RISK-ON ✓" : "NEUTRAL"
    table.cell(t, 0, 13, "Def vs Off", text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 13, def_vs_off >= 0.3 ? "DEF LEADS" : def_vs_off <= -0.3 ? "OFF LEADS" : "NEUTRAL", text_color=color.new(dvo_c,0), text_size=size.small)
    table.cell(t, 2, 13, dvo_l, text_color=color.new(dvo_c,0), text_size=size.small)

    // ES/NQ price-level divergence (spy% vs qqq%)
    ep_c = es_nq_price_delta >= 0.5 ? #ff9800 : es_nq_price_delta <= -0.5 ? #2196f3 : #90a4ae
    ep_l = es_nq_price_delta >= 0.5 ? "ES > NQ" : es_nq_price_delta <= -0.5 ? "NQ > ES" : "ALIGNED"
    table.cell(t, 0, 14, "ES/NQ Δprice", text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 14, sgn(math.round(es_nq_price_delta,2), "0.00") + "%", text_color=color.new(ep_c,0), text_size=size.small)
    table.cell(t, 2, 14, ep_l, text_color=color.new(ep_c,0), text_size=size.small)

    // VIX
    vd_str = vix_dir == 1 ? "↑ RISING" : vix_dir == -1 ? "↓ FALLING" : "→ FLAT"
    vix_c = vix_level >= 25 ? #ff5252 : vix_level >= 20 ? #ff7043 : vix_level >= 16 ? #ffeb3b : #69f0ae
    table.cell(t, 0, 15, "VIX",        text_color=#b0bec5, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 15, str.tostring(vix_level, "0.0"), text_color=color.new(vix_c,0), text_size=size.small)
    table.cell(t, 2, 15, vd_str, text_color=color.new(vix_c,0), text_size=size.small)
````
