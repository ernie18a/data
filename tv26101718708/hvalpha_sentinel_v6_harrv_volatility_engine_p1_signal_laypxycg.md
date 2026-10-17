# HValpha Sentinel v6 , HAR-RV Volatility Engine  P1 Signal

- url: https://www.tradingview.com/script/LAYPXyCg/
- type: indicator
- pine_id: PUB;9a60424f5eaa42d294811c88ce565ff8
- version: 1.0

## Description

[b]What is it?[/b]
A real-time volatility engine that tells you three things at once:
how explosive the market is, how much you should risk, and which
direction to trade.

Under the hood it runs a HAR model (short, medium and long-term
realized volatility combined into a single forward forecast), a
dynamic leverage calculator that scales your position down when
volatility spikes, a fractional Kelly sizer, and a VaR/Expected
Shortfall risk monitor — all updated bar by bar.

The P1 signal fires when momentum, market regime and risk filters
all agree. No signal = stay flat. Simple as that.

[b]How to use it?[/b]
1. Check the dashboard table (top right). If P(liq) is red, do not
   enter a trade — your leverage is too high for current volatility.
2. Wait for a triangle on the chart. Green triangle up = long setup.
   Red triangle down = short setup.
3. Use the position size shown in the table and the VaR-based stop.
4. Set the built-in alerts so you never miss an entry.

Best on ETH, BTC and SOL perpetual futures, 1H timeframe.
Default parameters are calibrated for ETH.

Not financial advice. Risk responsibly.

## Source Code

````pine
//@version=5
indicator("HVα Sentinel v6 — HAR-RV Volatility Engine", shorttitle="HVα v6", overlay=false, max_bars_back=600, max_lines_count=10, max_labels_count=50)

// ================================================================
// INPUTS
// ================================================================
bars_1d  = input.int(24,   "Barres 1 jour",           group="HAR-RV MODEL", minval=1)
bars_5d  = input.int(120,  "Barres 5 jours",          group="HAR-RV MODEL", minval=2)
bars_22d = input.int(528,  "Barres 22 jours",         group="HAR-RV MODEL", minval=10)

pair_sel = input.string("Auto", "Paire", options=["Auto","ETH","BTC","SOL"], group="PAIRE (COEFFICIENTS HAR)")
b0 = input.float(0.0008, "β₀ (custom)", step=0.0001, group="PAIRE (COEFFICIENTS HAR)")
b1 = input.float(0.42,   "β₁ (custom)", step=0.01,   group="PAIRE (COEFFICIENTS HAR)")
b2 = input.float(0.38,   "β₂ (custom)", step=0.01,   group="PAIRE (COEFFICIENTS HAR)")
b3 = input.float(0.20,   "β₃ (custom)", step=0.01,   group="PAIRE (COEFFICIENTS HAR)")

tau      = input.float(0.15, "T — Vol cible (ann.)",   step=0.01,  group="RISK PARAMETERS")
l_max    = input.float(10.0, "L_max — Levier max",     step=1.0,   group="RISK PARAMETERS")
l_min    = input.float(1.0,  "L_min — Levier min",     step=0.5,   group="RISK PARAMETERS")
es_seuil = input.float(0.05, "ES seuil (5% défaut)",   step=0.005, group="RISK PARAMETERS")
pliq_max = input.float(0.01, "P(liq) max (1% défaut)", step=0.005, group="RISK PARAMETERS")
gamma_k  = input.float(0.25, "Γ Kelly fraction",       step=0.05,  group="RISK PARAMETERS")

p1_enabled   = input.bool(true,  "Activer signal P1",              group="P1 — SIGNAL DIRECTIONNEL")
p1_mom_fast  = input.int(8,      "EMA rapide μ̂ (barres)",          group="P1 — SIGNAL DIRECTIONNEL", minval=2)
p1_mom_slow  = input.int(21,     "EMA lente μ̂ (barres)",           group="P1 — SIGNAL DIRECTIONNEL", minval=3)
p1_mom_sig   = input.int(5,      "EMA signal MACD (barres)",        group="P1 — SIGNAL DIRECTIONNEL", minval=2)
p1_hurst_th  = input.float(0.52, "Seuil Hurst trending", step=0.01, group="P1 — SIGNAL DIRECTIONNEL")
p1_kelly_th  = input.float(0.05, "Seuil |f_t| min actif",step=0.01, group="P1 — SIGNAL DIRECTIONNEL")
p1_vol_mult  = input.float(1.50, "Filtre vol (x tau max)",step=0.10, group="P1 — SIGNAL DIRECTIONNEL")
p1_conf_mode = input.string("MACD+Regime", "Mode confirmation", options=["MACD only","MACD+Regime","MACD+Regime+Kelly"], group="P1 — SIGNAL DIRECTIONNEL")

show_rv    = input.bool(true, "Afficher RV components",    group="AFFICHAGE")
show_lev   = input.bool(true, "Afficher levier dynamique", group="AFFICHAGE")
show_var   = input.bool(true, "Afficher VaR / ES / P_liq", group="AFFICHAGE")
show_kelly = input.bool(true, "Afficher Kelly sizing",     group="AFFICHAGE")
show_p1    = input.bool(true, "Afficher P1 signal",        group="AFFICHAGE")
h_bars     = input.int(4,    "Horizon h (barres)",         group="AFFICHAGE", minval=1)

// ================================================================
// HAR-RV
// ================================================================
ann_f     = math.sqrt(24.0 * 365.0)
ret       = math.log(close / close[1])
rv_1d     = ta.stdev(ret, bars_1d)  * ann_f
rv_5d     = ta.stdev(ret, bars_5d)  * ann_f
rv_22d    = ta.stdev(ret, bars_22d) * ann_f
sigma_hat = math.max(b0 + b1 * rv_1d + b2 * rv_5d + b3 * rv_22d, 0.001)

// ================================================================
// HURST & REGIME
// ================================================================
hurst_proxy = bar_index >= bars_22d ? math.max(0.30, math.min(0.80, 0.5 + (math.log(math.max(rv_22d, 0.001) / math.max(rv_1d, 0.001)) / math.log(22.0)) * 0.30)) : 0.5
hv_ratio    = rv_22d > 0 ? rv_1d / rv_22d : 1.0
acf1        = ta.correlation(ret, ret[1], 20)
is_trending = hurst_proxy > p1_hurst_th or hv_ratio > 1.20
is_mr       = hurst_proxy < (1.0 - p1_hurst_th)
regime_str  = is_trending ? "TRENDING" : is_mr ? "MEAN-REV" : "NEUTRAL"

// ================================================================
// LEVIER DYNAMIQUE
// ================================================================
L_raw = tau / sigma_hat
L_t   = math.min(l_max, math.max(l_min, L_raw))

// ================================================================
// MU MOMENTUM
// ================================================================
ema_fast  = ta.ema(close, p1_mom_fast)
ema_slow  = ta.ema(close, p1_mom_slow)
macd_line = ema_fast - ema_slow
macd_sig  = ta.ema(macd_line, p1_mom_sig)
macd_hist = macd_line - macd_sig
mu_hat    = ((ema_slow - ema_slow[p1_mom_slow]) / (math.max(ema_slow[p1_mom_slow], 0.001) * p1_mom_slow)) * ann_f * ann_f

// ================================================================
// KELLY FRACTIONNEL
// ================================================================
kelly_raw = mu_hat / math.max(sigma_hat * sigma_hat, 0.0001)
f_t       = gamma_k * kelly_raw
f_t_clip  = math.max(-l_max, math.min(l_max, f_t))

// ================================================================
// VaR / ES / P(LIQ)
// ================================================================
sigma_h    = sigma_hat / ann_f * math.sqrt(float(h_bars))
z95        = 1.6449
z_es       = 2.0627
VaR_pct    = z95  * sigma_h
ES_pct     = z_es * sigma_h
VaR_abs    = VaR_pct * close
ES_abs     = ES_pct  * close
liq_thresh = L_t > 0 ? 1.0 / L_t : 1.0
cf_adj     = sigma_h > 0 ? liq_thresh / (sigma_h * 1.15) : 10.0
_x         = (cf_adj - z95) / 0.50
_e2x       = math.exp(math.min(2.0 * _x, 20.0))
p_liq      = math.max(0.0, math.min(1.0, 0.5 * (1.0 - (_e2x - 1.0) / (_e2x + 1.0))))

// ================================================================
// P1 SIGNAL
// ================================================================
vol_ok     = sigma_hat < tau * p1_vol_mult
kelly_ok   = math.abs(f_t_clip) > p1_kelly_th
pliq_ok    = p_liq < pliq_max * 5.0
dir_long   = mu_hat > 0 and macd_hist > 0
dir_short  = mu_hat < 0 and macd_hist < 0
conf_long  = p1_enabled and (p1_conf_mode == "MACD only" ? vol_ok and dir_long : p1_conf_mode == "MACD+Regime" ? vol_ok and dir_long and is_trending : vol_ok and dir_long and is_trending and kelly_ok)
conf_short = p1_enabled and (p1_conf_mode == "MACD only" ? vol_ok and dir_short : p1_conf_mode == "MACD+Regime" ? vol_ok and dir_short : vol_ok and dir_short and kelly_ok)
long_entry  = p1_enabled and ta.crossover(macd_line,  macd_sig) and vol_ok
short_entry = p1_enabled and ta.crossunder(macd_line, macd_sig) and vol_ok
pos_net     = conf_long ? math.min(f_t_clip * (tau / math.max(sigma_hat, 0.001)), l_max) : conf_short ? math.max(f_t_clip * (tau / math.max(sigma_hat, 0.001)), -l_max) : 0.0
sl_long     = conf_long  ? close - VaR_abs : na
sl_short    = conf_short ? close + VaR_abs : na

// ================================================================
// PLOTS
// ================================================================
plot(show_rv ? rv_1d  * 100 : na, "sigma 1D (%)",  color=color.new(color.red,    15), linewidth=1)
plot(show_rv ? rv_5d  * 100 : na, "sigma 5D (%)",  color=color.new(color.orange, 20), linewidth=1)
plot(show_rv ? rv_22d * 100 : na, "sigma 22D (%)", color=color.new(color.yellow, 30), linewidth=1)
plot(sigma_hat * 100, "sigma HAR (%)", color=color.new(color.white, 0), linewidth=2)
hline(tau * 100, "tau vol-cible (%)", color=color.new(color.aqua, 40), linestyle=hline.style_dashed, linewidth=1)
plot(show_lev ? L_t * 10 : na, "Lt x10", color=color.new(color.blue, 30), linewidth=1, style=plot.style_stepline)
plot(show_var ? VaR_pct * 100 : na, "VaR 95% (%)", color=color.new(color.orange, 40), linewidth=1, style=plot.style_circles)
plot(show_var ? ES_pct  * 100 : na, "ES 95% (%)",  color=color.new(color.red,    40), linewidth=1, style=plot.style_circles)
plot(hurst_proxy * 100, "Hurst x100", color=color.new(color.purple, 20), linewidth=1)
hline(52, "H=0.52 trending",    color=color.new(color.green, 60), linestyle=hline.style_dotted)
hline(50, "H=0.50 random walk", color=color.new(color.gray,  50), linestyle=hline.style_dashed)
bgcolor(show_p1 and conf_long  ? color.new(color.green, 88) : na, title="P1 Long zone")
bgcolor(show_p1 and conf_short ? color.new(color.red,   88) : na, title="P1 Short zone")
plotshape(show_p1 and long_entry  ? sigma_hat * 100 : na, title="P1 LONG",  style=shape.triangleup,   location=location.absolute, color=color.lime, size=size.small, text="L")
plotshape(show_p1 and short_entry ? sigma_hat * 100 : na, title="P1 SHORT", style=shape.triangledown, location=location.absolute, color=color.red,  size=size.small, text="S")
plot(show_p1 ? macd_hist * 1000 : na, "MACD Hist x1000", color=macd_hist >= 0 ? color.new(color.lime, 60) : color.new(color.red, 60), style=plot.style_histogram, linewidth=2)

// ================================================================
// TABLE
// ================================================================
var table t = table.new(position.top_right, 2, 22, bgcolor=color.new(color.black, 25), border_color=color.new(color.gray, 50), border_width=1, frame_width=1, frame_color=color.new(color.navy, 20))
f_val(v, d) => str.tostring(v, "#." + str.repeat("0", d))
f_pct(v)    => f_val(v * 100, 1) + "%"
c_dir(v)    => v > 0 ? color.new(color.lime, 10) : color.new(color.red, 10)

if barstate.islast
    table.cell(t, 0,  0, "HVa v6 - HAR-RV Engine",    text_color=color.white,                  bgcolor=color.new(color.navy, 30), text_size=size.small)
    table.cell(t, 1,  0, syminfo.ticker + " " + timeframe.period + "H", text_color=color.yellow, bgcolor=color.new(color.navy, 30), text_size=size.small)
    table.cell(t, 0,  1, "sigma HAR forecast",          text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1,  1, f_pct(sigma_hat),              text_color=sigma_hat > tau * 1.5 ? color.new(color.orange, 10) : color.new(color.lime, 10), text_size=size.tiny)
    table.cell(t, 0,  2, "sigma realisee 1D",           text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1,  2, f_pct(rv_1d),                  text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 0,  3, "sigma realisee 5D",           text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1,  3, f_pct(rv_5d),                  text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 0,  4, "sigma realisee 22D",          text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1,  4, f_pct(rv_22d),                 text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 0,  5, "HV Ratio",                    text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1,  5, f_val(hv_ratio, 2) + "x",     text_color=hv_ratio > 1.2 ? color.new(color.orange, 10) : color.new(color.lime, 10), text_size=size.tiny)
    table.cell(t, 0,  6, "Hurst proxy",                 text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1,  6, f_val(hurst_proxy, 3),         text_color=hurst_proxy > p1_hurst_th ? color.new(color.lime, 10) : color.new(color.silver, 20), text_size=size.tiny)
    table.cell(t, 0,  7, "Regime",                      text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1,  7, regime_str,                    text_color=is_trending ? color.new(color.lime, 10) : is_mr ? color.new(color.orange, 10) : color.new(color.silver, 20), text_size=size.tiny)
    table.cell(t, 0,  8, "Regularite (ACF1)",           text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1,  8, f_pct(acf1),                   text_color=c_dir(acf1), text_size=size.tiny)
    table.cell(t, 0,  9, "VaR 95% (fwd)",               text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1,  9, f_val(VaR_abs, 2) + " ^",     text_color=color.new(color.orange, 10),  text_size=size.tiny)
    table.cell(t, 0, 10, "ES 95%",                      text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1, 10, f_val(ES_abs, 2) + " ^",      text_color=color.new(color.red,    10),  text_size=size.tiny)
    table.cell(t, 0, 11, "P(liquidation)",              text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1, 11, f_pct(p_liq),                 text_color=p_liq > pliq_max ? color.new(color.red, 10) : color.new(color.lime, 10), text_size=size.tiny)
    table.cell(t, 0, 12, "Lt (vol-target)",             text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1, 12, "+" + f_val(L_raw, 1) + "x",  text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 0, 13, "Lt (apres contr.)",           text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1, 13, "+" + f_val(L_t, 1) + "x",    text_color=L_t >= l_max * 0.9 ? color.new(color.orange, 10) : color.new(color.lime, 10), text_size=size.tiny)
    table.cell(t, 0, 14, "Kelly brut Kt",               text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1, 14, f_val(kelly_raw, 2),           text_color=c_dir(kelly_raw), text_size=size.tiny)
    table.cell(t, 0, 15, "Kelly frac ft (g=" + f_val(gamma_k, 2) + ")", text_color=color.new(color.silver, 20), text_size=size.tiny)
    table.cell(t, 1, 15, f_val(f_t_clip, 2),            text_color=c_dir(f_t_clip), text_size=size.tiny)
    table.cell(t, 0, 16, "P1 SIGNAL (" + p1_conf_mode + ")", text_color=color.aqua, bgcolor=color.new(color.teal, 30), text_size=size.tiny)
    table.cell(t, 1, 16, "",                             bgcolor=color.new(color.teal, 30))
    table.cell(t, 0, 17, "Direction P1",                text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1, 17, conf_long ? "LONG" : conf_short ? "SHORT" : "FLAT", text_color=conf_long ? color.new(color.lime, 10) : conf_short ? color.new(color.red, 10) : color.new(color.silver, 20), text_size=size.tiny)
    table.cell(t, 0, 18, "mu annualise",                text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1, 18, f_pct(mu_hat),                 text_color=c_dir(mu_hat), text_size=size.tiny)
    table.cell(t, 0, 19, "Taille pos. P1",              text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1, 19, math.abs(pos_net) > 0.01 ? (pos_net > 0 ? "+" : "") + f_val(pos_net, 2) + "x" : "0 FLAT", text_color=conf_long ? color.new(color.lime, 10) : conf_short ? color.new(color.red, 10) : color.new(color.silver, 20), text_size=size.tiny)
    table.cell(t, 0, 20, "Stop-loss (VaR)",             text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1, 20, conf_long ? f_val(sl_long, 2) + " SL" : conf_short ? f_val(sl_short, 2) + " SL" : "-", text_color=color.new(color.orange, 10), text_size=size.tiny)
    table.cell(t, 0, 21, "Filtres P1",                  text_color=color.new(color.silver, 20),  text_size=size.tiny)
    table.cell(t, 1, 21, (vol_ok ? "VOL+ " : "VOL- ") + (kelly_ok ? "KEL+ " : "KEL- ") + (pliq_ok ? "LIQ+" : "LIQ-"), text_color=vol_ok and kelly_ok ? color.new(color.lime, 10) : color.new(color.orange, 10), text_size=size.tiny)

// ================================================================
// ALERTES
// ================================================================
alertcondition(long_entry,  "P1 - Entree LONG",  "HVa P1 LONG - {{ticker}} @ {{close}}")
alertcondition(short_entry, "P1 - Entree SHORT", "HVa P1 SHORT - {{ticker}} @ {{close}}")
alertcondition(p_liq > pliq_max, "P1 - P(liq) CRITIQUE", "HVa P(liq) > seuil - reduire position!")
alertcondition(sigma_hat > tau * p1_vol_mult, "P1 - FILTRE VOL actif", "HVa Vol extreme - signal P1 suspendu")
alertcondition(ta.crossover(hurst_proxy,  p1_hurst_th), "P1 - Regime TRENDING", "HVa Hurst > seuil trending - {{ticker}}")
alertcondition(ta.crossunder(hurst_proxy, 0.5),          "P1 - Regime MEAN-REV",  "HVa Hurst < 0.50 - mean-rev {{ticker}}")
````
