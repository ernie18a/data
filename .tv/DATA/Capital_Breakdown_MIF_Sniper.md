<!-- tradingview-pine-id: PUB;dfd1c8e564a943868a216f38f0a44201 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Capital Breakdown: MIF Sniper

Source: https://www.tradingview.com/script/kQqhyTJs-Capital-Breakdown-MIF-Sniper/

## Description

Capital Breakdown: MIF Sniper is a macro-to-micro decision framework built for traders who want more than a sector heatmap — it tells you who's actually leading inside that sector.

The system runs as a two-desk architecture:

TRADE DESK — pivot-based support/resistance, supertrend + DEMA trend confirmation, and RSI-based reversal signals, with a live signal HUD and built-in alerts.

MACRO DESK — an 11-sector SPDR rotation heatmap ranking all sectors by relative strength vs SPY, plus regime classification (Trend / Transition / Shock), a Dynamic Conviction Index, and active macro driver detection (USD, rates, energy, risk sentiment, growth, industrial).

NAME-LEVEL DRILL-DOWN — the newest layer. Pick any sector from the settings dropdown, and the HUD ranks the top 5 strongest names inside that sector using relative strength versus the sector's own ETF (not just the broad market). A live LEADER/WATCH indicator tells you instantly whether the sector you're drilled into is the one actually leading right now, or one you're simply watching. Every candidate list is fully editable in settings — no coding required.

This turns sector rotation from a top-down observation into a tradeable single-name idea: see which sector is winning, then see which stock inside it is winning hardest.

Built for traders working across US equities, sector ETFs, and single names who want an institutional-style read on where capital is actually flowing — not just where the index is pointing.

---

## Source Code

````pine
//@version=6
// © A_Peden 2026
indicator("Capital Breakdown: MIF Sniper", overlay=true, max_labels_count=50)
z_mult = input.int(75, "Zone Buffer (Ticks)")
show_d = input.bool(true, "Show Daily Architecture")
show_w = input.bool(true, "Show Weekly Architecture")
cand_xlk = input.string("NVDA,AAPL,MSFT,AVGO,AMD,CSCO,INTC,AMAT,LRCX,MU", "Technology Candidates", group="Name Drill-Down (Top Sector)")
cand_xlf = input.string("JPM,WFC,BAC,GS,MS,SPGI,BLK,C,AXP,SCHW", "Financials Candidates", group="Name Drill-Down (Top Sector)")
cand_xle = input.string("XOM,CVX,COP,WMB,EOG,PSX,MPC,SLB,OKE,VLO", "Energy Candidates", group="Name Drill-Down (Top Sector)")
cand_xlv = input.string("LLY,UNH,JNJ,ABBV,MRK,TMO,ABT,ISRG,PFE,DHR", "Healthcare Candidates", group="Name Drill-Down (Top Sector)")
cand_xli = input.string("GE,CAT,RTX,UBER,HON,UNP,ADP,ETN,BA,LMT", "Industrials Candidates", group="Name Drill-Down (Top Sector)")
cand_xly = input.string("AMZN,TSLA,HD,MCD,BKNG,NKE,LOW,SBUX,TJX,CMG", "Cons Discretionary Candidates", group="Name Drill-Down (Top Sector)")
cand_xlp = input.string("COST,WMT,PG,KO,PM,PEP,MDLZ,CL,MO,TGT", "Cons Staples Candidates", group="Name Drill-Down (Top Sector)")
cand_xlu = input.string("NEE,SO,DUK,CEG,VST,AEP,D,EXC,SRE,PEG", "Utilities Candidates", group="Name Drill-Down (Top Sector)")
cand_xlre = input.string("PLD,AMT,EQIX,WELL,SPG,PSA,O,DLR,CCI,VICI", "Real Estate Candidates", group="Name Drill-Down (Top Sector)")
cand_xlb = input.string("LIN,SHW,ECL,FCX,APD,NEM,CTVA,DD,VMC,MLM", "Materials Candidates", group="Name Drill-Down (Top Sector)")
cand_xlc = input.string("META,GOOGL,NFLX,T,VZ,CMCSA,TMUS,DIS,EA,WBD", "Comm Services Candidates", group="Name Drill-Down (Top Sector)")
sector_select = input.string("TECHNOLOGY", "Drill-Down Sector (pick one)", options=["TECHNOLOGY", "FINANCIALS", "ENERGY", "HEALTHCARE", "INDUSTRIALS", "CONSM DISC", "CONSM STAPL", "UTILITIES", "REAL ESTATE", "MATERIALS", "COMMUNICATN"], group="Name Drill-Down (Top Sector)")
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
// ==========================================
// 7. NAME-LEVEL DRILL DOWN (STRONGEST SECTOR)
// ==========================================
active_cand = sector_select == "TECHNOLOGY" ? cand_xlk : sector_select == "FINANCIALS" ? cand_xlf : sector_select == "ENERGY" ? cand_xle : sector_select == "HEALTHCARE" ? cand_xlv : sector_select == "INDUSTRIALS" ? cand_xli : sector_select == "CONSM DISC" ? cand_xly : sector_select == "CONSM STAPL" ? cand_xlp : sector_select == "UTILITIES" ? cand_xlu : sector_select == "REAL ESTATE" ? cand_xlre : sector_select == "MATERIALS" ? cand_xlb : cand_xlc
active_sector_c = sector_select == "TECHNOLOGY" ? xlk_c : sector_select == "FINANCIALS" ? xlf_c : sector_select == "ENERGY" ? xle_c : sector_select == "HEALTHCARE" ? xlv_c : sector_select == "INDUSTRIALS" ? xli_c : sector_select == "CONSM DISC" ? xly_c : sector_select == "CONSM STAPL" ? xlp_c : sector_select == "UTILITIES" ? xlu_c : sector_select == "REAL ESTATE" ? xlre_c : sector_select == "MATERIALS" ? xlb_c : xlc_c
sector_is_leader = sector_select == t1
cand_arr = str.split(active_cand, ",")
cand_size = array.size(cand_arr)
valid_1 = cand_size > 0
valid_2 = cand_size > 1
valid_3 = cand_size > 2
valid_4 = cand_size > 3
valid_5 = cand_size > 4
valid_6 = cand_size > 5
valid_7 = cand_size > 6
valid_8 = cand_size > 7
valid_9 = cand_size > 8
valid_10 = cand_size > 9
tkr_1 = valid_1 ? str.trim(array.get(cand_arr, 0)) : "SPY"
tkr_2 = valid_2 ? str.trim(array.get(cand_arr, 1)) : "SPY"
tkr_3 = valid_3 ? str.trim(array.get(cand_arr, 2)) : "SPY"
tkr_4 = valid_4 ? str.trim(array.get(cand_arr, 3)) : "SPY"
tkr_5 = valid_5 ? str.trim(array.get(cand_arr, 4)) : "SPY"
tkr_6 = valid_6 ? str.trim(array.get(cand_arr, 5)) : "SPY"
tkr_7 = valid_7 ? str.trim(array.get(cand_arr, 6)) : "SPY"
tkr_8 = valid_8 ? str.trim(array.get(cand_arr, 7)) : "SPY"
tkr_9 = valid_9 ? str.trim(array.get(cand_arr, 8)) : "SPY"
tkr_10 = valid_10 ? str.trim(array.get(cand_arr, 9)) : "SPY"
px_1 = request.security(tkr_1, timeframe.period, close)
px_2 = request.security(tkr_2, timeframe.period, close)
px_3 = request.security(tkr_3, timeframe.period, close)
px_4 = request.security(tkr_4, timeframe.period, close)
px_5 = request.security(tkr_5, timeframe.period, close)
px_6 = request.security(tkr_6, timeframe.period, close)
px_7 = request.security(tkr_7, timeframe.period, close)
px_8 = request.security(tkr_8, timeframe.period, close)
px_9 = request.security(tkr_9, timeframe.period, close)
px_10 = request.security(tkr_10, timeframe.period, close)
rs_1 = ta.rsi(px_1 / active_sector_c, 14)
rs_2 = ta.rsi(px_2 / active_sector_c, 14)
rs_3 = ta.rsi(px_3 / active_sector_c, 14)
rs_4 = ta.rsi(px_4 / active_sector_c, 14)
rs_5 = ta.rsi(px_5 / active_sector_c, 14)
rs_6 = ta.rsi(px_6 / active_sector_c, 14)
rs_7 = ta.rsi(px_7 / active_sector_c, 14)
rs_8 = ta.rsi(px_8 / active_sector_c, 14)
rs_9 = ta.rsi(px_9 / active_sector_c, 14)
rs_10 = ta.rsi(px_10 / active_sector_c, 14)
n_1 = valid_1 ? (rs_1 - 50) / 5 : -999.0
n_2 = valid_2 ? (rs_2 - 50) / 5 : -999.0
n_3 = valid_3 ? (rs_3 - 50) / 5 : -999.0
n_4 = valid_4 ? (rs_4 - 50) / 5 : -999.0
n_5 = valid_5 ? (rs_5 - 50) / 5 : -999.0
n_6 = valid_6 ? (rs_6 - 50) / 5 : -999.0
n_7 = valid_7 ? (rs_7 - 50) / 5 : -999.0
n_8 = valid_8 ? (rs_8 - 50) / 5 : -999.0
n_9 = valid_9 ? (rs_9 - 50) / 5 : -999.0
n_10 = valid_10 ? (rs_10 - 50) / 5 : -999.0
top1n_v = math.max(n_1, math.max(n_2, math.max(n_3, math.max(n_4, math.max(n_5, math.max(n_6, math.max(n_7, math.max(n_8, math.max(n_9, n_10)))))))))
tn1 = top1n_v == n_1 ? tkr_1 : top1n_v == n_2 ? tkr_2 : top1n_v == n_3 ? tkr_3 : top1n_v == n_4 ? tkr_4 : top1n_v == n_5 ? tkr_5 : top1n_v == n_6 ? tkr_6 : top1n_v == n_7 ? tkr_7 : top1n_v == n_8 ? tkr_8 : top1n_v == n_9 ? tkr_9 : tkr_10
e_1 = tn1 == tkr_1 ? -999.0 : n_1
e_2 = tn1 == tkr_2 ? -999.0 : n_2
e_3 = tn1 == tkr_3 ? -999.0 : n_3
e_4 = tn1 == tkr_4 ? -999.0 : n_4
e_5 = tn1 == tkr_5 ? -999.0 : n_5
e_6 = tn1 == tkr_6 ? -999.0 : n_6
e_7 = tn1 == tkr_7 ? -999.0 : n_7
e_8 = tn1 == tkr_8 ? -999.0 : n_8
e_9 = tn1 == tkr_9 ? -999.0 : n_9
e_10 = tn1 == tkr_10 ? -999.0 : n_10
top2n_v = math.max(e_1, math.max(e_2, math.max(e_3, math.max(e_4, math.max(e_5, math.max(e_6, math.max(e_7, math.max(e_8, math.max(e_9, e_10)))))))))
tn2 = top2n_v == e_1 ? tkr_1 : top2n_v == e_2 ? tkr_2 : top2n_v == e_3 ? tkr_3 : top2n_v == e_4 ? tkr_4 : top2n_v == e_5 ? tkr_5 : top2n_v == e_6 ? tkr_6 : top2n_v == e_7 ? tkr_7 : top2n_v == e_8 ? tkr_8 : top2n_v == e_9 ? tkr_9 : tkr_10
f_1 = tn2 == tkr_1 ? -999.0 : e_1
f_2 = tn2 == tkr_2 ? -999.0 : e_2
f_3 = tn2 == tkr_3 ? -999.0 : e_3
f_4 = tn2 == tkr_4 ? -999.0 : e_4
f_5 = tn2 == tkr_5 ? -999.0 : e_5
f_6 = tn2 == tkr_6 ? -999.0 : e_6
f_7 = tn2 == tkr_7 ? -999.0 : e_7
f_8 = tn2 == tkr_8 ? -999.0 : e_8
f_9 = tn2 == tkr_9 ? -999.0 : e_9
f_10 = tn2 == tkr_10 ? -999.0 : e_10
top3n_v = math.max(f_1, math.max(f_2, math.max(f_3, math.max(f_4, math.max(f_5, math.max(f_6, math.max(f_7, math.max(f_8, math.max(f_9, f_10)))))))))
tn3 = top3n_v == f_1 ? tkr_1 : top3n_v == f_2 ? tkr_2 : top3n_v == f_3 ? tkr_3 : top3n_v == f_4 ? tkr_4 : top3n_v == f_5 ? tkr_5 : top3n_v == f_6 ? tkr_6 : top3n_v == f_7 ? tkr_7 : top3n_v == f_8 ? tkr_8 : top3n_v == f_9 ? tkr_9 : tkr_10
g_1 = tn3 == tkr_1 ? -999.0 : f_1
g_2 = tn3 == tkr_2 ? -999.0 : f_2
g_3 = tn3 == tkr_3 ? -999.0 : f_3
g_4 = tn3 == tkr_4 ? -999.0 : f_4
g_5 = tn3 == tkr_5 ? -999.0 : f_5
g_6 = tn3 == tkr_6 ? -999.0 : f_6
g_7 = tn3 == tkr_7 ? -999.0 : f_7
g_8 = tn3 == tkr_8 ? -999.0 : f_8
g_9 = tn3 == tkr_9 ? -999.0 : f_9
g_10 = tn3 == tkr_10 ? -999.0 : f_10
top4n_v = math.max(g_1, math.max(g_2, math.max(g_3, math.max(g_4, math.max(g_5, math.max(g_6, math.max(g_7, math.max(g_8, math.max(g_9, g_10)))))))))
tn4 = top4n_v == g_1 ? tkr_1 : top4n_v == g_2 ? tkr_2 : top4n_v == g_3 ? tkr_3 : top4n_v == g_4 ? tkr_4 : top4n_v == g_5 ? tkr_5 : top4n_v == g_6 ? tkr_6 : top4n_v == g_7 ? tkr_7 : top4n_v == g_8 ? tkr_8 : top4n_v == g_9 ? tkr_9 : tkr_10
h_1 = tn4 == tkr_1 ? -999.0 : g_1
h_2 = tn4 == tkr_2 ? -999.0 : g_2
h_3 = tn4 == tkr_3 ? -999.0 : g_3
h_4 = tn4 == tkr_4 ? -999.0 : g_4
h_5 = tn4 == tkr_5 ? -999.0 : g_5
h_6 = tn4 == tkr_6 ? -999.0 : g_6
h_7 = tn4 == tkr_7 ? -999.0 : g_7
h_8 = tn4 == tkr_8 ? -999.0 : g_8
h_9 = tn4 == tkr_9 ? -999.0 : g_9
h_10 = tn4 == tkr_10 ? -999.0 : g_10
top5n_v = math.max(h_1, math.max(h_2, math.max(h_3, math.max(h_4, math.max(h_5, math.max(h_6, math.max(h_7, math.max(h_8, math.max(h_9, h_10)))))))))
tn5 = top5n_v == h_1 ? tkr_1 : top5n_v == h_2 ? tkr_2 : top5n_v == h_3 ? tkr_3 : top5n_v == h_4 ? tkr_4 : top5n_v == h_5 ? tkr_5 : top5n_v == h_6 ? tkr_6 : top5n_v == h_7 ? tkr_7 : top5n_v == h_8 ? tkr_8 : top5n_v == h_9 ? tkr_9 : tkr_10
// 8. RENDER MACRO HUD
var table m_hud = table.new(position.bottom_left, 2, 16, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)
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
table.cell(m_hud, 0, 10, sector_is_leader ? "NAMES (LEADER)" : "NAMES (WATCH)", text_color=color.white, text_size=size.small)
table.cell(m_hud, 1, 10, sector_select, text_color=color.white, text_size=size.small, bgcolor=sector_is_leader ? color.new(color.green, 30) : color.new(color.orange, 30))
table.cell(m_hud, 0, 11, "#1", text_color=color.white, text_size=size.small)
table.cell(m_hud, 1, 11, tn1, text_color=color.white, text_size=size.small, bgcolor=color.new(color.green, 30))
table.cell(m_hud, 0, 12, "#2", text_color=color.white, text_size=size.small)
table.cell(m_hud, 1, 12, tn2, text_color=color.white, text_size=size.small, bgcolor=color.new(color.green, 30))
table.cell(m_hud, 0, 13, "#3", text_color=color.white, text_size=size.small)
table.cell(m_hud, 1, 13, tn3, text_color=color.white, text_size=size.small, bgcolor=color.new(color.green, 30))
table.cell(m_hud, 0, 14, "#4", text_color=color.white, text_size=size.small)
table.cell(m_hud, 1, 14, tn4, text_color=color.white, text_size=size.small, bgcolor=color.new(color.green, 30))
table.cell(m_hud, 0, 15, "#5", text_color=color.white, text_size=size.small)
table.cell(m_hud, 1, 15, tn5, text_color=color.white, text_size=size.small, bgcolor=color.new(color.green, 30))
````
