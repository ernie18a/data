# Multi TF EMA Cross and Index Movers

- url: https://www.tradingview.com/script/Vath07uo-Multi-TF-EMA-Cross-and-Index-Movers/
- type: indicator
- pine_id: PUB;ae0ac1df1002467bba9ffdeebd731298
- version: 1.0

## Description

This is a multi Time frame 
1. EMA Crossover with tunable EMA
2. Vix with used to guage Option Momentum
3. Nifty and BankNifty Movers

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © liberty2022

//@version=5
indicator("Multi TF EMA Cross and Index Movers", shorttitle="EMA VIX INDEX", overlay=true)

// ═══════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════
fast_len = input.int(4, "Fast EMA Length", minval=1)
slow_len = input.int(9, "Slow EMA Length", minval=1)

tf1 = input.timeframe("1",  "Timeframe 1")
tf2 = input.timeframe("5",  "Timeframe 2")

nifty_sym     = input.symbol("NSE:NIFTY",     "NIFTY Symbol")
banknifty_sym = input.symbol("NSE:BANKNIFTY", "BANK NIFTY Symbol")
vix_sym       = input.symbol("NSE:INDIAVIX",  "India VIX Symbol")
vix_ema_len   = input.int(20, "VIX EMA Length", minval=1)
bn_beta       = input.float(1.08, "Bank Nifty Beta", minval=0.5, maxval=3.0, step=0.01)

tbl_pos        = input.string("Bottom Right", "Main Table Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"])
movers_tbl_pos = input.string("Bottom Left",  "Movers Table Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"])

// ═══════════════════════════════════════════
// FETCH EMAs
// ═══════════════════════════════════════════
nifty_fast_1m = request.security(nifty_sym, tf1, ta.ema(close, fast_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
nifty_slow_1m = request.security(nifty_sym, tf1, ta.ema(close, slow_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
nifty_fast_5m = request.security(nifty_sym, tf2, ta.ema(close, fast_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
nifty_slow_5m = request.security(nifty_sym, tf2, ta.ema(close, slow_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

bn_fast_1m = request.security(banknifty_sym, tf1, ta.ema(close, fast_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
bn_slow_1m = request.security(banknifty_sym, tf1, ta.ema(close, slow_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
bn_fast_5m = request.security(banknifty_sym, tf2, ta.ema(close, fast_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
bn_slow_5m = request.security(banknifty_sym, tf2, ta.ema(close, slow_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

vix_close_1m = request.security(vix_sym, "1", close,                      gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
vix_ema_1m   = request.security(vix_sym, "1", ta.ema(close, vix_ema_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════
// VIX DAILY RANGE
// ═══════════════════════════════════════════
[nifty_daily_open, nifty_current] = request.security(nifty_sym,     "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[bn_daily_open,    bn_current]    = request.security(banknifty_sym, "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

vix_divisor       = 15.87
daily_move_pct    = vix_close_1m / vix_divisor
range_points      = nifty_daily_open * (daily_move_pct / 100.0)
upper_level       = nifty_daily_open + range_points
lower_level       = nifty_daily_open - range_points

bn_daily_move_pct = (vix_close_1m * bn_beta) / vix_divisor
bn_range_points   = bn_daily_open * (bn_daily_move_pct / 100.0)
bn_upper_level    = bn_daily_open + bn_range_points
bn_lower_level    = bn_daily_open - bn_range_points

nf_move = nifty_current - nifty_daily_open
bn_move = bn_current    - bn_daily_open

// ═══════════════════════════════════════════
// SHARED COMPONENTS  (BN + NF)
// ═══════════════════════════════════════════
[hdfc_o,  hdfc_c]  = request.security("NSE:HDFCBANK",   "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[icici_o, icici_c] = request.security("NSE:ICICIBANK",  "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[axis_o,  axis_c]  = request.security("NSE:AXISBANK",   "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[sbi_o,   sbi_c]   = request.security("NSE:SBIN",       "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[kotak_o, kotak_c] = request.security("NSE:KOTAKBANK",  "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════
// BN-ONLY COMPONENTS
// ═══════════════════════════════════════════
[fed_o,     fed_c]     = request.security("NSE:FEDERALBNK", "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[indus_o,   indus_c]   = request.security("NSE:INDUSINDBK", "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[aubnk_o,   aubnk_c]   = request.security("NSE:AUBANK",     "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[bob_o,     bob_c]     = request.security("NSE:BANKBARODA", "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[idfc_o,    idfc_c]    = request.security("NSE:IDFCFIRSTB", "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[pnb_o,     pnb_c]     = request.security("NSE:PNB",        "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[canara_o,  canara_c]  = request.security("NSE:CANBK",      "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[bandhan_o, bandhan_c] = request.security("NSE:BANDHANBNK", "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[yes_o,     yes_c]     = request.security("NSE:YESBANK",    "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════
// NF-ONLY COMPONENTS
// ═══════════════════════════════════════════
[rel_o,    rel_c]    = request.security("NSE:RELIANCE",   "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[airtel_o, airtel_c] = request.security("NSE:BHARTIARTL", "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[lt_o,     lt_c]     = request.security("NSE:LT",         "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[infy_o,   infy_c]   = request.security("NSE:INFY",       "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[itc_o,    itc_c]    = request.security("NSE:ITC",        "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[tcs_o,    tcs_c]    = request.security("NSE:TCS",        "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[maruti_o, maruti_c] = request.security("NSE:MARUTI",     "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[bajfin_o, bajfin_c] = request.security("NSE:BAJFINANCE", "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[sunp_o,   sunp_c]   = request.security("NSE:SUNPHARMA",  "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[hul_o,    hul_c]    = request.security("NSE:HINDUNILVR", "D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════
// GLOBAL HELPER FUNCTIONS
// ═══════════════════════════════════════════
pct_chg(o, c) =>
    o != 0 ? (c - o) / o * 100 : 0.0

fmt_pts(v) =>
    v >= 0 ? "+" + str.tostring(math.round(v, 0)) : str.tostring(math.round(v, 0))

// ═══════════════════════════════════════════
// BN WEIGHTS & CONTRIBUTIONS
// ═══════════════════════════════════════════
float bw_hdfc    = 18.37
float bw_icici   = 13.55
float bw_axis    = 10.02
float bw_sbi     =  9.93
float bw_kotak   =  9.67
float bw_fed     =  6.27
float bw_indus   =  5.35
float bw_aubnk   =  4.97
float bw_bob     =  4.34
float bw_idfc    =  4.12
float bw_pnb     =  3.80
float bw_canara  =  3.50
float bw_bandhan =  3.30
float bw_yes     =  2.81

float bn_hdfc_wpct    = pct_chg(hdfc_o,    hdfc_c)    * bw_hdfc    / 100
float bn_icici_wpct   = pct_chg(icici_o,   icici_c)   * bw_icici   / 100
float bn_axis_wpct    = pct_chg(axis_o,    axis_c)    * bw_axis    / 100
float bn_sbi_wpct     = pct_chg(sbi_o,     sbi_c)     * bw_sbi     / 100
float bn_kotak_wpct   = pct_chg(kotak_o,   kotak_c)   * bw_kotak   / 100
float bn_fed_wpct     = pct_chg(fed_o,     fed_c)     * bw_fed     / 100
float bn_indus_wpct   = pct_chg(indus_o,   indus_c)   * bw_indus   / 100
float bn_aubnk_wpct   = pct_chg(aubnk_o,   aubnk_c)   * bw_aubnk   / 100
float bn_bob_wpct     = pct_chg(bob_o,     bob_c)     * bw_bob     / 100
float bn_idfc_wpct    = pct_chg(idfc_o,    idfc_c)    * bw_idfc    / 100
float bn_pnb_wpct     = pct_chg(pnb_o,     pnb_c)     * bw_pnb     / 100
float bn_canara_wpct  = pct_chg(canara_o,  canara_c)  * bw_canara  / 100
float bn_bandhan_wpct = pct_chg(bandhan_o, bandhan_c) * bw_bandhan / 100
float bn_yes_wpct     = pct_chg(yes_o,     yes_c)     * bw_yes     / 100

float bn_total_wpct = bn_hdfc_wpct + bn_icici_wpct + bn_axis_wpct    + bn_sbi_wpct     + bn_kotak_wpct  +
                      bn_fed_wpct  + bn_indus_wpct + bn_aubnk_wpct   + bn_bob_wpct     + bn_idfc_wpct   +
                      bn_pnb_wpct  + bn_canara_wpct + bn_bandhan_wpct + bn_yes_wpct

float bn_hdfc_pts    = bn_total_wpct != 0 ? bn_move * (bn_hdfc_wpct    / bn_total_wpct) : 0.0
float bn_icici_pts   = bn_total_wpct != 0 ? bn_move * (bn_icici_wpct   / bn_total_wpct) : 0.0
float bn_axis_pts    = bn_total_wpct != 0 ? bn_move * (bn_axis_wpct    / bn_total_wpct) : 0.0
float bn_sbi_pts     = bn_total_wpct != 0 ? bn_move * (bn_sbi_wpct     / bn_total_wpct) : 0.0
float bn_kotak_pts   = bn_total_wpct != 0 ? bn_move * (bn_kotak_wpct   / bn_total_wpct) : 0.0
float bn_fed_pts     = bn_total_wpct != 0 ? bn_move * (bn_fed_wpct     / bn_total_wpct) : 0.0
float bn_indus_pts   = bn_total_wpct != 0 ? bn_move * (bn_indus_wpct   / bn_total_wpct) : 0.0
float bn_aubnk_pts   = bn_total_wpct != 0 ? bn_move * (bn_aubnk_wpct   / bn_total_wpct) : 0.0
float bn_bob_pts     = bn_total_wpct != 0 ? bn_move * (bn_bob_wpct     / bn_total_wpct) : 0.0
float bn_idfc_pts    = bn_total_wpct != 0 ? bn_move * (bn_idfc_wpct    / bn_total_wpct) : 0.0
float bn_pnb_pts     = bn_total_wpct != 0 ? bn_move * (bn_pnb_wpct     / bn_total_wpct) : 0.0
float bn_canara_pts  = bn_total_wpct != 0 ? bn_move * (bn_canara_wpct  / bn_total_wpct) : 0.0
float bn_bandhan_pts = bn_total_wpct != 0 ? bn_move * (bn_bandhan_wpct / bn_total_wpct) : 0.0
float bn_yes_pts     = bn_total_wpct != 0 ? bn_move * (bn_yes_wpct     / bn_total_wpct) : 0.0

// ═══════════════════════════════════════════
// NF WEIGHTS & CONTRIBUTIONS  (top 15)
// ═══════════════════════════════════════════
float nw_hdfc    = 10.73
float nw_rel     =  8.78
float nw_icici   =  8.21
float nw_airtel  =  5.26
float nw_lt      =  4.28
float nw_sbi     =  4.03
float nw_infy    =  3.76
float nw_axis    =  3.31
float nw_itc     =  2.76
float nw_kotak   =  2.56
float nw_tcs     =  2.40
float nw_maruti  =  1.80
float nw_bajfin  =  1.70
float nw_sunp    =  1.60
float nw_hul     =  1.50

float nf_hdfc_wpct   = pct_chg(hdfc_o,    hdfc_c)    * nw_hdfc   / 100
float nf_rel_wpct    = pct_chg(rel_o,     rel_c)     * nw_rel    / 100
float nf_icici_wpct  = pct_chg(icici_o,   icici_c)   * nw_icici  / 100
float nf_airtel_wpct = pct_chg(airtel_o,  airtel_c)  * nw_airtel / 100
float nf_lt_wpct     = pct_chg(lt_o,      lt_c)      * nw_lt     / 100
float nf_sbi_wpct    = pct_chg(sbi_o,     sbi_c)     * nw_sbi    / 100
float nf_infy_wpct   = pct_chg(infy_o,    infy_c)    * nw_infy   / 100
float nf_axis_wpct   = pct_chg(axis_o,    axis_c)    * nw_axis   / 100
float nf_itc_wpct    = pct_chg(itc_o,     itc_c)     * nw_itc    / 100
float nf_kotak_wpct  = pct_chg(kotak_o,   kotak_c)   * nw_kotak  / 100
float nf_tcs_wpct    = pct_chg(tcs_o,     tcs_c)     * nw_tcs    / 100
float nf_maruti_wpct = pct_chg(maruti_o,  maruti_c)  * nw_maruti / 100
float nf_bajfin_wpct = pct_chg(bajfin_o,  bajfin_c)  * nw_bajfin / 100
float nf_sunp_wpct   = pct_chg(sunp_o,    sunp_c)    * nw_sunp   / 100
float nf_hul_wpct    = pct_chg(hul_o,     hul_c)     * nw_hul    / 100

float nf_total_wpct = nf_hdfc_wpct  + nf_rel_wpct   + nf_icici_wpct  + nf_airtel_wpct + nf_lt_wpct    +
                      nf_sbi_wpct   + nf_infy_wpct  + nf_axis_wpct   + nf_itc_wpct    + nf_kotak_wpct +
                      nf_tcs_wpct   + nf_maruti_wpct + nf_bajfin_wpct + nf_sunp_wpct   + nf_hul_wpct

float nf_hdfc_pts   = nf_total_wpct != 0 ? nf_move * (nf_hdfc_wpct   / nf_total_wpct) : 0.0
float nf_rel_pts    = nf_total_wpct != 0 ? nf_move * (nf_rel_wpct    / nf_total_wpct) : 0.0
float nf_icici_pts  = nf_total_wpct != 0 ? nf_move * (nf_icici_wpct  / nf_total_wpct) : 0.0
float nf_airtel_pts = nf_total_wpct != 0 ? nf_move * (nf_airtel_wpct / nf_total_wpct) : 0.0
float nf_lt_pts     = nf_total_wpct != 0 ? nf_move * (nf_lt_wpct     / nf_total_wpct) : 0.0
float nf_sbi_pts    = nf_total_wpct != 0 ? nf_move * (nf_sbi_wpct    / nf_total_wpct) : 0.0
float nf_infy_pts   = nf_total_wpct != 0 ? nf_move * (nf_infy_wpct   / nf_total_wpct) : 0.0
float nf_axis_pts   = nf_total_wpct != 0 ? nf_move * (nf_axis_wpct   / nf_total_wpct) : 0.0
float nf_itc_pts    = nf_total_wpct != 0 ? nf_move * (nf_itc_wpct    / nf_total_wpct) : 0.0
float nf_kotak_pts  = nf_total_wpct != 0 ? nf_move * (nf_kotak_wpct  / nf_total_wpct) : 0.0
float nf_tcs_pts    = nf_total_wpct != 0 ? nf_move * (nf_tcs_wpct    / nf_total_wpct) : 0.0
float nf_maruti_pts = nf_total_wpct != 0 ? nf_move * (nf_maruti_wpct / nf_total_wpct) : 0.0
float nf_bajfin_pts = nf_total_wpct != 0 ? nf_move * (nf_bajfin_wpct / nf_total_wpct) : 0.0
float nf_sunp_pts   = nf_total_wpct != 0 ? nf_move * (nf_sunp_wpct   / nf_total_wpct) : 0.0
float nf_hul_pts    = nf_total_wpct != 0 ? nf_move * (nf_hul_wpct    / nf_total_wpct) : 0.0

// ═══════════════════════════════════════════
// SIGNAL LOGIC
// ═══════════════════════════════════════════
nifty_cross_up_1m = ta.crossover (nifty_fast_1m, nifty_slow_1m)
nifty_cross_dn_1m = ta.crossunder(nifty_fast_1m, nifty_slow_1m)
nifty_cross_up_5m = ta.crossover (nifty_fast_5m, nifty_slow_5m)
nifty_cross_dn_5m = ta.crossunder(nifty_fast_5m, nifty_slow_5m)

bn_cross_up_1m    = ta.crossover (bn_fast_1m, bn_slow_1m)
bn_cross_dn_1m    = ta.crossunder(bn_fast_1m, bn_slow_1m)
bn_cross_up_5m    = ta.crossover (bn_fast_5m, bn_slow_5m)
bn_cross_dn_5m    = ta.crossunder(bn_fast_5m, bn_slow_5m)

var string nifty_sig_1m = "WAIT"
var string nifty_sig_5m = "WAIT"
var string bn_sig_1m    = "WAIT"
var string bn_sig_5m    = "WAIT"

if nifty_cross_up_1m
    nifty_sig_1m := "CE"
else if nifty_cross_dn_1m
    nifty_sig_1m := "PE"

if nifty_cross_up_5m
    nifty_sig_5m := "CE"
else if nifty_cross_dn_5m
    nifty_sig_5m := "PE"

if bn_cross_up_1m
    bn_sig_1m := "CE"
else if bn_cross_dn_1m
    bn_sig_1m := "PE"

if bn_cross_up_5m
    bn_sig_5m := "CE"
else if bn_cross_dn_5m
    bn_sig_5m := "PE"

vix_sig_1m = vix_close_1m > vix_ema_1m ? "PE" : "NEUTRAL"

sig_color(sig) =>
    sig == "CE"      ? color.new(#00c853, 15) :
     sig == "PE"      ? color.new(#ff1744, 15) :
     sig == "NEUTRAL" ? color.new(#00838f, 20) :
     color.new(#37474f, 30)

sig_text_color(sig) =>
    sig == "WAIT" ? color.new(#ffffff, 30) : color.white

// ═══════════════════════════════════════════
// TABLE POSITION HELPER
// ═══════════════════════════════════════════
resolve_pos(pos_str) =>
    switch pos_str
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        => position.bottom_right

// ═══════════════════════════════════════════
// MAIN TABLE
// ═══════════════════════════════════════════
var table tbl = table.new(resolve_pos(tbl_pos), columns=3, rows=6,
     border_width=1, border_color=color.new(color.gray, 60),
     frame_width=2,  frame_color=color.new(color.gray, 40))

if barstate.islast

    header_bg = color.new(#1a237e, 10)
    header_fg = color.new(#e8eaf6, 0)

    table.cell(tbl, 0, 0, "SYMBOL",   text_color=header_fg, bgcolor=header_bg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, 0, "1m TREND", text_color=header_fg, bgcolor=header_bg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 2, 0, "5m TREND", text_color=header_fg, bgcolor=header_bg, text_size=size.small, text_halign=text.align_center)

    nifty_trend_1m = nifty_fast_1m > nifty_slow_1m ? "CE" : "PE"
    nifty_trend_5m = nifty_fast_5m > nifty_slow_5m ? "CE" : "PE"
    nifty_t1m_col  = nifty_fast_1m > nifty_slow_1m ? color.new(#00c853, 20) : color.new(#ff1744, 20)
    nifty_t5m_col  = nifty_fast_5m > nifty_slow_5m ? color.new(#00c853, 20) : color.new(#ff1744, 20)

    table.cell(tbl, 0, 1, "NIFTY",        text_color=color.white, bgcolor=color.new(#263238, 10), text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, 1, nifty_trend_1m, text_color=color.white, bgcolor=nifty_t1m_col,          text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 2, 1, nifty_trend_5m, text_color=color.white, bgcolor=nifty_t5m_col,          text_size=size.small, text_halign=text.align_center)

    bn_trend_1m = bn_fast_1m > bn_slow_1m ? "CE" : "PE"
    bn_t1m_col  = bn_fast_1m > bn_slow_1m ? color.new(#00c853, 20) : color.new(#ff1744, 20)

    table.cell(tbl, 0, 2, "BANK NIFTY", text_color=color.white, bgcolor=color.new(#263238, 10),             text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, 2, bn_trend_1m,  text_color=color.white, bgcolor=bn_t1m_col,                         text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 2, 2, bn_sig_5m,    text_color=sig_text_color(bn_sig_5m), bgcolor=sig_color(bn_sig_5m), text_size=size.small, text_halign=text.align_center)

    vix_val_str = str.tostring(math.round(vix_close_1m, 2))
    table.cell(tbl, 0, 3, "INDIA VIX",  text_color=color.white,                bgcolor=color.new(#4a148c, 20), text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, 3, vix_sig_1m,   text_color=sig_text_color(vix_sig_1m), bgcolor=sig_color(vix_sig_1m), text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 2, 3, vix_val_str,  text_color=color.white,                bgcolor=color.new(#263238, 10), text_size=size.small, text_halign=text.align_center)

    upper_str = str.tostring(math.round(upper_level, 0))
    lower_str = str.tostring(math.round(lower_level, 0))
    table.cell(tbl, 0, 4, "NF RANGE", text_color=color.white, bgcolor=color.new(#1a237e, 20), text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, 4, upper_str,  text_color=color.white, bgcolor=color.new(#00c853, 40), text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 2, 4, lower_str,  text_color=color.white, bgcolor=color.new(#ff1744, 40), text_size=size.small, text_halign=text.align_center)

    bn_upper_str = str.tostring(math.round(bn_upper_level, 0))
    bn_lower_str = str.tostring(math.round(bn_lower_level, 0))
    table.cell(tbl, 0, 5, "BN RANGE",   text_color=color.white, bgcolor=color.new(#1a237e, 20), text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, 5, bn_upper_str, text_color=color.white, bgcolor=color.new(#00c853, 40), text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 2, 5, bn_lower_str, text_color=color.white, bgcolor=color.new(#ff1744, 40), text_size=size.small, text_halign=text.align_center)

// ═══════════════════════════════════════════
// COMBINED MOVERS TABLE
// Cols: NF Stock | NF Pts | BN Stock | BN Pts
// Row 0: header
// Row 1-2: top 2 (green)
// Row 3-4: bot 2 (red)
// ═══════════════════════════════════════════
var table movers_tbl = table.new(resolve_pos(movers_tbl_pos), columns=4, rows=5,
     border_width=1, border_color=color.new(color.gray, 60),
     frame_width=2,  frame_color=color.new(color.gray, 40))

if barstate.islast

    // ── Sort NF ──────────────────────────
    nf_pts_arr   = array.from(nf_hdfc_pts,  nf_rel_pts,    nf_icici_pts,  nf_airtel_pts, nf_lt_pts, nf_sbi_pts,   nf_infy_pts,   nf_axis_pts,   nf_itc_pts,    nf_kotak_pts, nf_tcs_pts,   nf_maruti_pts, nf_bajfin_pts, nf_sunp_pts,   nf_hul_pts)
    nf_names_arr = array.from("HDFC", "RELIANCE", "ICICI", "AIRTEL", "L&T", "SBI",  "INFY",     "AXIS",  "ITC",    "KOTAK","TCS",  "MARUTI",   "BAJFIN","SUNP",   "HUL")

    int   nf_top1_idx = 0
    int   nf_top2_idx = 1
    float nf_top1_val = -1e10
    float nf_top2_val = -1e10
    for i = 0 to 14
        v = array.get(nf_pts_arr, i)
        if v >= nf_top1_val
            nf_top2_val := nf_top1_val
            nf_top2_idx := nf_top1_idx
            nf_top1_val := v
            nf_top1_idx := i
        else if v >= nf_top2_val
            nf_top2_val := v
            nf_top2_idx := i

    int   nf_bot1_idx = 0
    int   nf_bot2_idx = 1
    float nf_bot1_val = 1e10
    float nf_bot2_val = 1e10
    for i = 0 to 14
        v = array.get(nf_pts_arr, i)
        if v <= nf_bot1_val
            nf_bot2_val := nf_bot1_val
            nf_bot2_idx := nf_bot1_idx
            nf_bot1_val := v
            nf_bot1_idx := i
        else if v <= nf_bot2_val
            nf_bot2_val := v
            nf_bot2_idx := i

    // ── Sort BN ──────────────────────────
    bn_pts_arr   = array.from(bn_hdfc_pts, bn_icici_pts, bn_axis_pts,    bn_sbi_pts,     bn_kotak_pts, bn_fed_pts,  bn_indus_pts, bn_aubnk_pts,   bn_bob_pts,     bn_idfc_pts, bn_pnb_pts,  bn_canara_pts, bn_bandhan_pts, bn_yes_pts)
    bn_names_arr = array.from("HDFC", "ICICI", "AXIS", "SBI", "KOTAK", "FEDBK", "INDUSIND", "AUBANK", "BOB", "IDFC1B", "PNB", "CANARA", "BANDHAN", "YES")

    int   bn_top1_idx = 0
    int   bn_top2_idx = 1
    float bn_top1_val = -1e10
    float bn_top2_val = -1e10
    for i = 0 to 13
        v = array.get(bn_pts_arr, i)
        if v >= bn_top1_val
            bn_top2_val := bn_top1_val
            bn_top2_idx := bn_top1_idx
            bn_top1_val := v
            bn_top1_idx := i
        else if v >= bn_top2_val
            bn_top2_val := v
            bn_top2_idx := i

    int   bn_bot1_idx = 0
    int   bn_bot2_idx = 1
    float bn_bot1_val = 1e10
    float bn_bot2_val = 1e10
    for i = 0 to 13
        v = array.get(bn_pts_arr, i)
        if v <= bn_bot1_val
            bn_bot2_val := bn_bot1_val
            bn_bot2_idx := bn_bot1_idx
            bn_bot1_val := v
            bn_bot1_idx := i
        else if v <= bn_bot2_val
            bn_bot2_val := v
            bn_bot2_idx := i

    // ── Colors ───────────────────────────
    nf_hdr_bg  = color.new(#1a237e, 10)
    bn_hdr_bg  = color.new(#4a148c, 10)
    nf_move_bg = nf_move >= 0 ? color.new(#00c853, 20) : color.new(#ff1744, 20)
    bn_move_bg = bn_move >= 0 ? color.new(#00c853, 20) : color.new(#ff1744, 20)

    // ── Row 0: headers ───────────────────
    table.cell(movers_tbl, 0, 0, "NF " + fmt_pts(nf_move), text_color=color.white, bgcolor=nf_hdr_bg,  text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 1, 0, fmt_pts(nf_move),          text_color=color.white, bgcolor=nf_move_bg, text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 2, 0, "BN " + fmt_pts(bn_move), text_color=color.white, bgcolor=bn_hdr_bg,  text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 3, 0, fmt_pts(bn_move),          text_color=color.white, bgcolor=bn_move_bg, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(movers_tbl, 0, 0, 1, 0)
    table.merge_cells(movers_tbl, 2, 0, 3, 0)

    // ── Rows 1-2: top 2 green ────────────
    table.cell(movers_tbl, 0, 1, array.get(nf_names_arr, nf_top1_idx), text_color=color.white, bgcolor=color.new(#00c853, 40), text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 1, 1, fmt_pts(nf_top1_val),                 text_color=color.white, bgcolor=color.new(#00c853, 40), text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 2, 1, array.get(bn_names_arr, bn_top1_idx), text_color=color.white, bgcolor=color.new(#00c853, 40), text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 3, 1, fmt_pts(bn_top1_val),                 text_color=color.white, bgcolor=color.new(#00c853, 40), text_size=size.small, text_halign=text.align_center)

    table.cell(movers_tbl, 0, 2, array.get(nf_names_arr, nf_top2_idx), text_color=color.white, bgcolor=color.new(#00c853, 55), text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 1, 2, fmt_pts(nf_top2_val),                 text_color=color.white, bgcolor=color.new(#00c853, 55), text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 2, 2, array.get(bn_names_arr, bn_top2_idx), text_color=color.white, bgcolor=color.new(#00c853, 55), text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 3, 2, fmt_pts(bn_top2_val),                 text_color=color.white, bgcolor=color.new(#00c853, 55), text_size=size.small, text_halign=text.align_center)

    // ── Rows 3-4: bot 2 red ──────────────
    table.cell(movers_tbl, 0, 3, array.get(nf_names_arr, nf_bot1_idx), text_color=color.white, bgcolor=color.new(#ff1744, 40), text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 1, 3, fmt_pts(nf_bot1_val),                 text_color=color.white, bgcolor=color.new(#ff1744, 40), text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 2, 3, array.get(bn_names_arr, bn_bot1_idx), text_color=color.white, bgcolor=color.new(#ff1744, 40), text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 3, 3, fmt_pts(bn_bot1_val),                 text_color=color.white, bgcolor=color.new(#ff1744, 40), text_size=size.small, text_halign=text.align_center)

    table.cell(movers_tbl, 0, 4, array.get(nf_names_arr, nf_bot2_idx), text_color=color.white, bgcolor=color.new(#ff1744, 55), text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 1, 4, fmt_pts(nf_bot2_val),                 text_color=color.white, bgcolor=color.new(#ff1744, 55), text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 2, 4, array.get(bn_names_arr, bn_bot2_idx), text_color=color.white, bgcolor=color.new(#ff1744, 55), text_size=size.small, text_halign=text.align_center)
    table.cell(movers_tbl, 3, 4, fmt_pts(bn_bot2_val),                 text_color=color.white, bgcolor=color.new(#ff1744, 55), text_size=size.small, text_halign=text.align_center)

// ═══════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════
//alertcondition(nifty_cross_up_1m,  "NIFTY  1m BUY",       "NIFTY:  EMA4 crossed ABOVE EMA9 on 1-min")
//alertcondition(nifty_cross_dn_1m,  "NIFTY  1m SELL",      "NIFTY:  EMA4 crossed BELOW EMA9 on 1-min")
//alertcondition(nifty_cross_up_5m,  "NIFTY  5m BUY",       "NIFTY:  EMA4 crossed ABOVE EMA9 on 5-min")
//alertcondition(nifty_cross_dn_5m,  "NIFTY  5m SELL",      "NIFTY:  EMA4 crossed BELOW EMA9 on 5-min")
//alertcondition(bn_cross_up_1m,     "BANKNIFTY 1m BUY",    "BANKNIFTY: EMA4 crossed ABOVE EMA9 on 1-min")
//alertcondition(bn_cross_dn_1m,     "BANKNIFTY 1m SELL",   "BANKNIFTY: EMA4 crossed BELOW EMA9 on 1-min")
//alertcondition(bn_cross_up_5m,     "BANKNIFTY 5m BUY",    "BANKNIFTY: EMA4 crossed ABOVE EMA9 on 5-min")
//alertcondition(bn_cross_dn_5m,     "BANKNIFTY 5m SELL",   "BANKNIFTY: EMA4 crossed BELOW EMA9 on 5-min")
````
