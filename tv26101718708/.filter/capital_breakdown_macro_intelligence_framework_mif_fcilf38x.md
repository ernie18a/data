# Capital Breakdown: Macro Intelligence Framework (MIF)

- url: https://www.tradingview.com/script/fCIlF38x-Capital-Breakdown-Macro-Intelligence-Framework-MIF/
- type: indicator
- pine_id: PUB;c36689c6009c4897935d2b013674b9ba
- version: 3.0

## Description

The Capital Breakdown: Macro Intelligence Framework (MIF) is a macro-level decision architecture designed to identify where institutional capital is flowing, which sectors are receiving money, and whether current market conditions support active trade deployment.
The MIF operates as the Macro Desk in a two desk institutional trading system. It does not generate buy or sell signals. It generates macro intelligence — telling you what the market environment looks like before you decide whether to act.
The Macro Desk reads six real time macro inputs and identifies which one is driving markets with the highest velocity. It then scores the conviction level of that environment, classifies the current market regime, and outputs a clear permission level telling you whether conditions are right to deploy capital, trade with reduced size, hold a directional bias only, or stand aside entirely.
The sector rotation matrix monitors all 11 SPDR sector ETFs and ranks them by relative strength versus SPY. This means it tells you not just which sectors are rising, but which sectors are outperforming the broad market — the way institutional desks actually measure money flow. The top five strongest and bottom five weakest sectors update in real time directly on your chart.
The system is designed to be used alongside the Institutional Flow Framework (IFF) trade desk. The macro desk tells you where the money is going. The trade desk tells you when and how to execute. A trade is only taken when both desks agree.
Recommended home base is SPY on the daily chart. Check the macro desk before every session. Hunt for assets only in the top performing sectors. Execute only when the trade desk confirms and the macro desk gives permits.

## Source Code

````pine
//@version=6
// © A_Peden 2026
indicator("Capital Breakdown: MIF 2", overlay=true, max_labels_count=50)
z_mult = input.int(75, "Zone Buffer (Ticks)")
show_d = input.bool(true, "Show Daily Architecture")
show_w = input.bool(true, "Show Weekly Architecture")
dH = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
dL = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
dC = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
dp = (dH + dL + dC) / 3
dr1 = dp * 2 - dL
ds1 = dp * 2 - dH
wH = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
wL = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
wC = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)
wp = (wH + wL + wC) / 3
wr1 = wp * 2 - wL
ws1 = wp * 2 - wH
wr2 = wp + (wH - wL)
ws2 = wp - (wH - wL)
z = syminfo.mintick * z_mult
[st_val, st_dir] = ta.supertrend(3, 10)
dema = ta.ema(ta.ema(close, 100), 100)
rsi = ta.rsi(close, 14)
rbr_long = (st_dir == -1 and close > dema)
rbr_short = (st_dir == 1 and close < dema)
rbr_align = rbr_long or rbr_short
mrs_exhaust = rsi > 70 or rsi < 30
plot(show_d ? dp : na, "DP", color.gray, 1, plot.style_linebr)
plot(show_d ? dr1 : na, "DR1", color.red, 1, plot.style_linebr)
plot(show_d ? ds1 : na, "DS1", color.green, 1, plot.style_linebr)
plot(show_w ? wr1 : na, "WR1", color.orange, 1, plot.style_linebr)
plot(show_w ? ws1 : na, "WS1", color.blue, 1, plot.style_linebr)
p_dp1 = plot(show_d ? dp + z : na, color=color.new(color.gray, 100))
p_dp2 = plot(show_d ? dp - z : na, color=color.new(color.gray, 100))
fill(p_dp1, p_dp2, color=color.new(color.gray, 85))
var table hud = table.new(position.top_right, 2, 2, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)
is_fv = (close > (dp - z) and close < (dp + z)) and rbr_align
is_st = (math.abs(close - wr1) < z or math.abs(close - ws1) < z or math.abs(close - wr2) < z or math.abs(close - ws2) < z or mrs_exhaust)
rbr_status_text = is_fv ? (rbr_long ? "READY (LONG)" : "READY (SHORT)") : "WAITING"
rbr_bg_color = is_fv ? (rbr_long ? color.new(color.green, 20) : color.new(color.red, 20)) : color.gray
table.cell(hud, 0, 0, "SYSTEM ACTIVE", text_color=color.white, text_size=size.small)
table.cell(hud, 1, 0, is_st ? "REVERSAL (MRS)" : is_fv ? "TREND (RBR)" : "NONE", text_color=color.white, text_size=size.small)
table.cell(hud, 0, 1, "SIGNAL STATUS", text_color=color.white, text_size=size.small)
table.cell(hud, 1, 1, is_st ? "READY (MRS)" : rbr_status_text, bgcolor=is_st ? color.orange : rbr_bg_color, text_size=size.small)
var l_dp = label.new(na, na, "DP", style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.gray, size=size.small)
var l_dr1 = label.new(na, na, "DR1", style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.red, size=size.small)
var l_ds1 = label.new(na, na, "DS1", style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.green, size=size.small)
var l_wr1 = label.new(na, na, "WR1", style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.orange, size=size.small)
var l_ws1 = label.new(na, na, "WS1", style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.blue, size=size.small)
label.set_xy(l_dp, bar_index + 2, dp)
label.set_xy(l_dr1, bar_index + 2, dr1)
label.set_xy(l_ds1, bar_index + 2, ds1)
label.set_xy(l_wr1, bar_index + 2, wr1)
label.set_xy(l_ws1, bar_index + 2, ws1)
alert_msg = is_st ? "READY (MRS)" : rbr_status_text
sig_change = ta.change(is_st or is_fv)
if (is_st or is_fv) and sig_change
    alert(alert_msg + " | " + syminfo.ticker, alert.freq_once_per_bar)// ==========================================
// CAPITAL BREAKDOWN - MACRO DESK
// ==========================================
// 1. DATA FEEDS
dxy_v = request.security("TVC:DXY", timeframe.period, close)
rates_v = request.security("TVC:US10Y-TVC:US02Y", timeframe.period, close)
oil_wti = request.security("TVC:USOIL", timeframe.period, close)
oil_brn = request.security("TVC:UKOIL", timeframe.period, close)
energy_v = (oil_wti + oil_brn) / 2
spx_v = request.security("SP:SPX", timeframe.period, close)
vix_v = request.security("CBOE:VIX", timeframe.period, close)
growth_v = request.security("NASDAQ:NDX/DJ:DJI", timeframe.period, close)
ind_v = request.security("DJ:DJI", timeframe.period, close)
// 2. VELOCITY
v_usd = math.abs(ta.roc(dxy_v, 5))
v_rates = math.abs(ta.roc(rates_v, 5))
v_energy = math.abs(ta.roc(energy_v, 5))
v_risk = math.abs(ta.roc(spx_v, 5))
v_growth = math.abs(ta.roc(growth_v, 5))
v_ind = math.abs(ta.roc(ind_v, 5))
// 3. DRIVER IDENTIFICATION
max_v = math.max(v_usd, math.max(v_rates, math.max(v_energy, math.max(v_risk, math.max(v_growth, v_ind)))))
d_title = max_v == v_usd ? "USD" : "NONE"
d_title := max_v == v_rates ? "YIELD CURVE" : d_title
d_title := max_v == v_energy ? "ENERGY" : d_title
d_title := max_v == v_risk ? "RISK (SENTIMENT)" : d_title
d_title := max_v == v_growth ? "GROWTH/SPEC" : d_title
d_title := max_v == v_ind ? "INDUSTRIAL" : d_title
// 4. SYSTEM STABILITY & DCI
corr_flow = ta.correlation(dxy_v, ind_v, 10)
stability = math.max(0, math.min(1, 1 - ta.stdev(corr_flow, 10)))
dci_score = math.max(0, math.min(1, (stability * 0.6) + (math.abs(corr_flow) * 0.4)))
// 5. REGIME & CONVICTION
is_shock = stability < 0.35 or vix_v > 25
regime_text = is_shock ? "SHOCK/LIQUIDITY" : stability > 0.75 ? "TREND" : "TRANSITION"
regime_color = is_shock ? color.red : stability > 0.75 ? color.blue : color.gray
conv_text = "NO TRADE"
conv_text := dci_score > 0.40 ? "BIAS ONLY" : conv_text
conv_text := dci_score > 0.60 ? "MODERATE" : conv_text
conv_text := dci_score > 0.80 ? "HIGH CONVICTION" : conv_text
conv_text := is_shock ? "NO TRADE" : conv_text
conv_color = conv_text == "HIGH CONVICTION" ? color.green : color.red
conv_color := conv_text == "MODERATE" ? color.orange : conv_color
conv_color := conv_text == "BIAS ONLY" ? color.yellow : conv_color
// 6. SECTOR ROTATION MATRIX - RELATIVE STRENGTH VS SPY
spy_c = request.security("SPY", timeframe.period, close)
xlk_c = request.security("XLK", timeframe.period, close)
xlf_c = request.security("XLF", timeframe.period, close)
xle_c = request.security("XLE", timeframe.period, close)
xlv_c = request.security("XLV", timeframe.period, close)
xli_c = request.security("XLI", timeframe.period, close)
xly_c = request.security("XLY", timeframe.period, close)
xlp_c = request.security("XLP", timeframe.period, close)
xlu_c = request.security("XLU", timeframe.period, close)
xlre_c = request.security("XLRE", timeframe.period, close)
xlb_c = request.security("XLB", timeframe.period, close)
xlc_c = request.security("XLC", timeframe.period, close)
r_xlk = ta.rsi(xlk_c / spy_c, 14)
r_xlf = ta.rsi(xlf_c / spy_c, 14)
r_xle = ta.rsi(xle_c / spy_c, 14)
r_xlv = ta.rsi(xlv_c / spy_c, 14)
r_xli = ta.rsi(xli_c / spy_c, 14)
r_xly = ta.rsi(xly_c / spy_c, 14)
r_xlp = ta.rsi(xlp_c / spy_c, 14)
r_xlu = ta.rsi(xlu_c / spy_c, 14)
r_xlre = ta.rsi(xlre_c / spy_c, 14)
r_xlb = ta.rsi(xlb_c / spy_c, 14)
r_xlc = ta.rsi(xlc_c / spy_c, 14)
// Normalize to -10 to +10 scale
n_xlk = (r_xlk - 50) / 5
n_xlf = (r_xlf - 50) / 5
n_xle = (r_xle - 50) / 5
n_xlv = (r_xlv - 50) / 5
n_xli = (r_xli - 50) / 5
n_xly = (r_xly - 50) / 5
n_xlp = (r_xlp - 50) / 5
n_xlu = (r_xlu - 50) / 5
n_xlre = (r_xlre - 50) / 5
n_xlb = (r_xlb - 50) / 5
n_xlc = (r_xlc - 50) / 5
// Find top 5
top1_v = math.max(n_xlk, math.max(n_xlf, math.max(n_xle, math.max(n_xlv, math.max(n_xli, math.max(n_xly, math.max(n_xlp, math.max(n_xlu, math.max(n_xlre, math.max(n_xlb, n_xlc))))))))))
t1 = top1_v == n_xlk ? "TECHNOLOGY" : top1_v == n_xlf ? "FINANCIALS" : top1_v == n_xle ? "ENERGY" : top1_v == n_xlv ? "HEALTHCARE" : top1_v == n_xli ? "INDUSTRIALS" : top1_v == n_xly ? "CONSM DISC" : top1_v == n_xlp ? "CONSM STAPL" : top1_v == n_xlu ? "UTILITIES" : top1_v == n_xlre ? "REAL ESTATE" : top1_v == n_xlb ? "MATERIALS" : "COMMUNICATN"
a_xlk = t1 == "TECHNOLOGY" ? -999.0 : n_xlk
a_xlf = t1 == "FINANCIALS" ? -999.0 : n_xlf
a_xle = t1 == "ENERGY" ? -999.0 : n_xle
a_xlv = t1 == "HEALTHCARE" ? -999.0 : n_xlv
a_xli = t1 == "INDUSTRIALS" ? -999.0 : n_xli
a_xly = t1 == "CONSM DISC" ? -999.0 : n_xly
a_xlp = t1 == "CONSM STAPL" ? -999.0 : n_xlp
a_xlu = t1 == "UTILITIES" ? -999.0 : n_xlu
a_xlre = t1 == "REAL ESTATE" ? -999.0 : n_xlre
a_xlb = t1 == "MATERIALS" ? -999.0 : n_xlb
a_xlc = t1 == "COMMUNICATN" ? -999.0 : n_xlc
top2_v = math.max(a_xlk, math.max(a_xlf, math.max(a_xle, math.max(a_xlv, math.max(a_xli, math.max(a_xly, math.max(a_xlp, math.max(a_xlu, math.max(a_xlre, math.max(a_xlb, a_xlc))))))))))
t2 = top2_v == a_xlk ? "TECHNOLOGY" : top2_v == a_xlf ? "FINANCIALS" : top2_v == a_xle ? "ENERGY" : top2_v == a_xlv ? "HEALTHCARE" : top2_v == a_xli ? "INDUSTRIALS" : top2_v == a_xly ? "CONSM DISC" : top2_v == a_xlp ? "CONSM STAPL" : top2_v == a_xlu ? "UTILITIES" : top2_v == a_xlre ? "REAL ESTATE" : top2_v == a_xlb ? "MATERIALS" : "COMMUNICATN"
b_xlk = t2 == "TECHNOLOGY" ? -999.0 : a_xlk
b_xlf = t2 == "FINANCIALS" ? -999.0 : a_xlf
b_xle = t2 == "ENERGY" ? -999.0 : a_xle
b_xlv = t2 == "HEALTHCARE" ? -999.0 : a_xlv
b_xli = t2 == "INDUSTRIALS" ? -999.0 : a_xli
b_xly = t2 == "CONSM DISC" ? -999.0 : a_xly
b_xlp = t2 == "CONSM STAPL" ? -999.0 : a_xlp
b_xlu = t2 == "UTILITIES" ? -999.0 : a_xlu
b_xlre = t2 == "REAL ESTATE" ? -999.0 : a_xlre
b_xlb = t2 == "MATERIALS" ? -999.0 : a_xlb
b_xlc = t2 == "COMMUNICATN" ? -999.0 : a_xlc
top3_v = math.max(b_xlk, math.max(b_xlf, math.max(b_xle, math.max(b_xlv, math.max(b_xli, math.max(b_xly, math.max(b_xlp, math.max(b_xlu, math.max(b_xlre, math.max(b_xlb, b_xlc))))))))))
t3 = top3_v == b_xlk ? "TECHNOLOGY" : top3_v == b_xlf ? "FINANCIALS" : top3_v == b_xle ? "ENERGY" : top3_v == b_xlv ? "HEALTHCARE" : top3_v == b_xli ? "INDUSTRIALS" : top3_v == b_xly ? "CONSM DISC" : top3_v == b_xlp ? "CONSM STAPL" : top3_v == b_xlu ? "UTILITIES" : top3_v == b_xlre ? "REAL ESTATE" : top3_v == b_xlb ? "MATERIALS" : "COMMUNICATN"
c_xlk = t3 == "TECHNOLOGY" ? -999.0 : b_xlk
c_xlf = t3 == "FINANCIALS" ? -999.0 : b_xlf
c_xle = t3 == "ENERGY" ? -999.0 : b_xle
c_xlv = t3 == "HEALTHCARE" ? -999.0 : b_xlv
c_xli = t3 == "INDUSTRIALS" ? -999.0 : b_xli
c_xly = t3 == "CONSM DISC" ? -999.0 : b_xly
c_xlp = t3 == "CONSM STAPL" ? -999.0 : b_xlp
c_xlu = t3 == "UTILITIES" ? -999.0 : b_xlu
c_xlre = t3 == "REAL ESTATE" ? -999.0 : b_xlre
c_xlb = t3 == "MATERIALS" ? -999.0 : b_xlb
c_xlc = t3 == "COMMUNICATN" ? -999.0 : b_xlc
top4_v = math.max(c_xlk, math.max(c_xlf, math.max(c_xle, math.max(c_xlv, math.max(c_xli, math.max(c_xly, math.max(c_xlp, math.max(c_xlu, math.max(c_xlre, math.max(c_xlb, c_xlc))))))))))
t4 = top4_v == c_xlk ? "TECHNOLOGY" : top4_v == c_xlf ? "FINANCIALS" : top4_v == c_xle ? "ENERGY" : top4_v == c_xlv ? "HEALTHCARE" : top4_v == c_xli ? "INDUSTRIALS" : top4_v == c_xly ? "CONSM DISC" : top4_v == c_xlp ? "CONSM STAPL" : top4_v == c_xlu ? "UTILITIES" : top4_v == c_xlre ? "REAL ESTATE" : top4_v == c_xlb ? "MATERIALS" : "COMMUNICATN"
d_xlk = t4 == "TECHNOLOGY" ? -999.0 : c_xlk
d_xlf = t4 == "FINANCIALS" ? -999.0 : c_xlf
d_xle = t4 == "ENERGY" ? -999.0 : c_xle
d_xlv = t4 == "HEALTHCARE" ? -999.0 : c_xlv
d_xli = t4 == "INDUSTRIALS" ? -999.0 : c_xli
d_xly = t4 == "CONSM DISC" ? -999.0 : c_xly
d_xlp = t4 == "CONSM STAPL" ? -999.0 : c_xlp
d_xlu = t4 == "UTILITIES" ? -999.0 : c_xlu
d_xlre = t4 == "REAL ESTATE" ? -999.0 : c_xlre
d_xlb = t4 == "MATERIALS" ? -999.0 : c_xlb
d_xlc = t4 == "COMMUNICATN" ? -999.0 : c_xlc
top5_v = math.max(d_xlk, math.max(d_xlf, math.max(d_xle, math.max(d_xlv, math.max(d_xli, math.max(d_xly, math.max(d_xlp, math.max(d_xlu, math.max(d_xlre, math.max(d_xlb, d_xlc))))))))))
t5 = top5_v == d_xlk ? "TECHNOLOGY" : top5_v == d_xlf ? "FINANCIALS" : top5_v == d_xle ? "ENERGY" : top5_v == d_xlv ? "HEALTHCARE" : top5_v == d_xli ? "INDUSTRIALS" : top5_v == d_xly ? "CONSM DISC" : top5_v == d_xlp ? "CONSM STAPL" : top5_v == d_xlu ? "UTILITIES" : top5_v == d_xlre ? "REAL ESTATE" : top5_v == d_xlb ? "MATERIALS" : "COMMUNICATN"
// Find bottom 5
bot1_v = math.min(n_xlk, math.min(n_xlf, math.min(n_xle, math.min(n_xlv, math.min(n_xli, math.min(n_xly, math.min(n_xlp, math.min(n_xlu, math.min(n_xlre, math.min(n_xlb, n_xlc))))))))))
w1 = bot1_v == n_xlk ? "TECHNOLOGY" : bot1_v == n_xlf ? "FINANCIALS" : bot1_v == n_xle ? "ENERGY" : bot1_v == n_xlv ? "HEALTHCARE" : bot1_v == n_xli ? "INDUSTRIALS" : bot1_v == n_xly ? "CONSM DISC" : bot1_v == n_xlp ? "CONSM STAPL" : bot1_v == n_xlu ? "UTILITIES" : bot1_v == n_xlre ? "REAL ESTATE" : bot1_v == n_xlb ? "MATERIALS" : "COMMUNICATN"
wa_xlk = w1 == "TECHNOLOGY" ? 999.0 : n_xlk
wa_xlf = w1 == "FINANCIALS" ? 999.0 : n_xlf
wa_xle = w1 == "ENERGY" ? 999.0 : n_xle
wa_xlv = w1 == "HEALTHCARE" ? 999.0 : n_xlv
wa_xli = w1 == "INDUSTRIALS" ? 999.0 : n_xli
wa_xly = w1 == "CONSM DISC" ? 999.0 : n_xly
wa_xlp = w1 == "CONSM STAPL" ? 999.0 : n_xlp
wa_xlu = w1 == "UTILITIES" ? 999.0 : n_xlu
wa_xlre = w1 == "REAL ESTATE" ? 999.0 : n_xlre
wa_xlb = w1 == "MATERIALS" ? 999.0 : n_xlb
wa_xlc = w1 == "COMMUNICATN" ? 999.0 : n_xlc
bot2_v = math.min(wa_xlk, math.min(wa_xlf, math.min(wa_xle, math.min(wa_xlv, math.min(wa_xli, math.min(wa_xly, math.min(wa_xlp, math.min(wa_xlu, math.min(wa_xlre, math.min(wa_xlb, wa_xlc))))))))))
w2 = bot2_v == wa_xlk ? "TECHNOLOGY" : bot2_v == wa_xlf ? "FINANCIALS" : bot2_v == wa_xle ? "ENERGY" : bot2_v == wa_xlv ? "HEALTHCARE" : bot2_v == wa_xli ? "INDUSTRIALS" : bot2_v == wa_xly ? "CONSM DISC" : bot2_v == wa_xlp ? "CONSM STAPL" : bot2_v == wa_xlu ? "UTILITIES" : bot2_v == wa_xlre ? "REAL ESTATE" : bot2_v == wa_xlb ? "MATERIALS" : "COMMUNICATN"
wb_xlk = w2 == "TECHNOLOGY" ? 999.0 : wa_xlk
wb_xlf = w2 == "FINANCIALS" ? 999.0 : wa_xlf
wb_xle = w2 == "ENERGY" ? 999.0 : wa_xle
wb_xlv = w2 == "HEALTHCARE" ? 999.0 : wa_xlv
wb_xli = w2 == "INDUSTRIALS" ? 999.0 : wa_xli
wb_xly = w2 == "CONSM DISC" ? 999.0 : wa_xly
wb_xlp = w2 == "CONSM STAPL" ? 999.0 : wa_xlp
wb_xlu = w2 == "UTILITIES" ? 999.0 : wa_xlu
wb_xlre = w2 == "REAL ESTATE" ? 999.0 : wa_xlre
wb_xlb = w2 == "MATERIALS" ? 999.0 : wa_xlb
wb_xlc = w2 == "COMMUNICATN" ? 999.0 : wa_xlc
bot3_v = math.min(wb_xlk, math.min(wb_xlf, math.min(wb_xle, math.min(wb_xlv, math.min(wb_xli, math.min(wb_xly, math.min(wb_xlp, math.min(wb_xlu, math.min(wb_xlre, math.min(wb_xlb, wb_xlc))))))))))
w3 = bot3_v == wb_xlk ? "TECHNOLOGY" : bot3_v == wb_xlf ? "FINANCIALS" : bot3_v == wb_xle ? "ENERGY" : bot3_v == wb_xlv ? "HEALTHCARE" : bot3_v == wb_xli ? "INDUSTRIALS" : bot3_v == wb_xly ? "CONSM DISC" : bot3_v == wb_xlp ? "CONSM STAPL" : bot3_v == wb_xlu ? "UTILITIES" : bot3_v == wb_xlre ? "REAL ESTATE" : bot3_v == wb_xlb ? "MATERIALS" : "COMMUNICATN"
wc_xlk = w3 == "TECHNOLOGY" ? 999.0 : wb_xlk
wc_xlf = w3 == "FINANCIALS" ? 999.0 : wb_xlf
wc_xle = w3 == "ENERGY" ? 999.0 : wb_xle
wc_xlv = w3 == "HEALTHCARE" ? 999.0 : wb_xlv
wc_xli = w3 == "INDUSTRIALS" ? 999.0 : wb_xli
wc_xly = w3 == "CONSM DISC" ? 999.0 : wb_xly
wc_xlp = w3 == "CONSM STAPL" ? 999.0 : wb_xlp
wc_xlu = w3 == "UTILITIES" ? 999.0 : wb_xlu
wc_xlre = w3 == "REAL ESTATE" ? 999.0 : wb_xlre
wc_xlb = w3 == "MATERIALS" ? 999.0 : wb_xlb
wc_xlc = w3 == "COMMUNICATN" ? 999.0 : wb_xlc
bot4_v = math.min(wc_xlk, math.min(wc_xlf, math.min(wc_xle, math.min(wc_xlv, math.min(wc_xli, math.min(wc_xly, math.min(wc_xlp, math.min(wc_xlu, math.min(wc_xlre, math.min(wc_xlb, wc_xlc))))))))))
w4 = bot4_v == wc_xlk ? "TECHNOLOGY" : bot4_v == wc_xlf ? "FINANCIALS" : bot4_v == wc_xle ? "ENERGY" : bot4_v == wc_xlv ? "HEALTHCARE" : bot4_v == wc_xli ? "INDUSTRIALS" : bot4_v == wc_xly ? "CONSM DISC" : bot4_v == wc_xlp ? "CONSM STAPL" : bot4_v == wc_xlu ? "UTILITIES" : bot4_v == wc_xlre ? "REAL ESTATE" : bot4_v == wc_xlb ? "MATERIALS" : "COMMUNICATN"
wd_xlk = w4 == "TECHNOLOGY" ? 999.0 : wc_xlk
wd_xlf = w4 == "FINANCIALS" ? 999.0 : wc_xlf
wd_xle = w4 == "ENERGY" ? 999.0 : wc_xle
wd_xlv = w4 == "HEALTHCARE" ? 999.0 : wc_xlv
wd_xli = w4 == "INDUSTRIALS" ? 999.0 : wc_xli
wd_xly = w4 == "CONSM DISC" ? 999.0 : wc_xly
wd_xlp = w4 == "CONSM STAPL" ? 999.0 : wc_xlp
wd_xlu = w4 == "UTILITIES" ? 999.0 : wc_xlu
wd_xlre = w4 == "REAL ESTATE" ? 999.0 : wc_xlre
wd_xlb = w4 == "MATERIALS" ? 999.0 : wc_xlb
wd_xlc = w4 == "COMMUNICATN" ? 999.0 : wc_xlc
bot5_v = math.min(wd_xlk, math.min(wd_xlf, math.min(wd_xle, math.min(wd_xlv, math.min(wd_xli, math.min(wd_xly, math.min(wd_xlp, math.min(wd_xlu, math.min(wd_xlre, math.min(wd_xlb, wd_xlc))))))))))
w5 = bot5_v == wd_xlk ? "TECHNOLOGY" : bot5_v == wd_xlf ? "FINANCIALS" : bot5_v == wd_xle ? "ENERGY" : bot5_v == wd_xlv ? "HEALTHCARE" : bot5_v == wd_xli ? "INDUSTRIALS" : bot5_v == wd_xly ? "CONSM DISC" : bot5_v == wd_xlp ? "CONSM STAPL" : bot5_v == wd_xlu ? "UTILITIES" : bot5_v == wd_xlre ? "REAL ESTATE" : bot5_v == wd_xlb ? "MATERIALS" : "COMMUNICATN"
// 7. RENDER MACRO HUD
var table m_hud = table.new(position.bottom_left, 2, 14, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)
table.cell(m_hud, 0, 0, "ACTIVE DRIVER", text_color=color.white, text_size=size.small)
table.cell(m_hud, 1, 0, d_title, text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 30))
table.cell(m_hud, 0, 1, "DCI SCORE", text_color=color.white, text_size=size.small)
table.cell(m_hud, 1, 1, str.tostring(dci_score, "#.##"), text_color=color.white, text_size=size.small)
table.cell(m_hud, 0, 2, "REGIME", text_color=color.white, text_size=size.small)
table.cell(m_hud, 1, 2, regime_text, text_color=color.white, text_size=size.small, bgcolor=regime_color)
table.cell(m_hud, 0, 3, "PERMISSION", text_color=color.white, text_size=size.small)
table.cell(m_hud, 1, 3, conv_text, text_color=color.white, text_size=size.small, bgcolor=conv_color)
table.cell(m_hud, 0, 4, "-- TOP SECTORS --", text_color=color.white, text_size=size.small)
table.cell(m_hud, 1, 4, "-- WEAK SECTORS --", text_color=color.white, text_size=size.small)
table.cell(m_hud, 0, 5, t1, text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 30))
table.cell(m_hud, 1, 5, w1, text_color=color.white, text_size=size.small, bgcolor=color.new(color.red, 30))
table.cell(m_hud, 0, 6, t2, text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 30))
table.cell(m_hud, 1, 6, w2, text_color=color.white, text_size=size.small, bgcolor=color.new(color.red, 30))
table.cell(m_hud, 0, 7, t3, text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 30))
table.cell(m_hud, 1, 7, w3, text_color=color.white, text_size=size.small, bgcolor=color.new(color.red, 30))
table.cell(m_hud, 0, 8, t4, text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 30))
table.cell(m_hud, 1, 8, w4, text_color=color.white, text_size=size.small, bgcolor=color.new(color.red, 30))
table.cell(m_hud, 0, 9, t5, text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 30))
table.cell(m_hud, 1, 9, w5, text_color=color.white, text_size=size.small, bgcolor=color.new(color.red, 30))
````
