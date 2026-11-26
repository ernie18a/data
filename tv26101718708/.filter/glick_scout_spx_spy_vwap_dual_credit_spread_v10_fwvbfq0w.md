# GLICK Scout  SPX SPY VWAP Dual Credit Spread v1.0

- url: https://www.tradingview.com/script/FWvbFQ0W-GLICK-Scout-SPX-SPY-VWAP-Dual-Credit-Spread-v1-0/
- type: indicator
- pine_id: PUB;03f85446be1f4f58ba10e03594f508d8
- version: 1.0

## Description

GLICK Scout is an intraday signal indicator designed for 
OTM Credit Spread entries on SPX and SPY (0DTE and weekly).

It detects high-probability setups based on dual VWAP 
analysis — combining the current day VWAP with the 
previous day VWAP for stronger signal confirmation.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SIGNAL LOGIC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CALL Credit Spread signal when:
- Price crosses BELOW current VWAP
- Price is below previous day VWAP
- Price action (close < open) confirms direction
- Score 3/4 or 4/4 required

PUT Credit Spread signal when:
- Price crosses ABOVE current VWAP
- Price is above previous day VWAP
- Price action (close > open) confirms direction
- Score 3/4 or 4/4 required

DUAL VWAP setup (4/4) is the strongest signal — 
price must be on the correct side of BOTH VWAPs 
to achieve maximum score.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SCORING SYSTEM (0-4)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Each signal scores 4 components:
- PA  — Price action direction (close vs open)
- VWAP  — Price position vs current VWAP
- PVWAP — Price position vs previous day VWAP
- CROSS — VWAP crossover trigger

IDEAL = 4/4 | GOOD = 3/4 | AVOID = below 3

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VISUAL ELEMENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- VWAP today (blue) — current session anchor
- VWAP yesterday (orange) — previous session anchor
- EMA 70 (mustard) — intermediate trend reference
- EMA 120 (light yellow) — intermediate trend reference
- ▼ label — Call Credit Spread entry signal
- ▲ label — Put Credit Spread entry signal

Hover over any signal to see:
- Suggested strikes (Sell/Buy)
- Score and quality rating
- DUAL VWAP confirmation status
- Both VWAP levels at signal time

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DASHBOARD TABLE (top right)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- Mode: CALL / PUT (dominant side)
- Score: /4
- PA, VWAP, PVWAP, CROSS — individual component status
- VIX — current level with min/max filter
- Session — market open/closed status
- Signal — current signal or Wait
- Quality — IDEAL / GOOD / AVOID
- PCC — Put/Call ratio with BULL/BEAR/NEUT reading

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- OTM distance in points (default 10)
- Spread width in points (default 5)
- Close at % of credit received (default 50%)
- Minimum score 1-4 (default 3)
- Minimum bars between signals
- VIX min/max filter
- Put/Call ratio thresholds
- Market session hours (NY time)
- All visual elements toggleable

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RECOMMENDED USE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- Timeframe: 3min, 5min, 15min
- Best for: SPX and SPY intraday credit spreads
- Strategy: OTM vertical credit spreads 0DTE
- Session: Regular market hours only

Signals fire only on confirmed VWAP crossovers with 
dual VWAP alignment — keeping false signals low and 
entry timing precise.

This indicator does not repaint.
For educational purposes only. Not financial advice.

## Source Code

````pine
//@version=6
indicator("GLICK Scout — SPX/SPY VWAP Dual Credit Spread v1.0",
          overlay=true, max_labels_count=500, max_lines_count=300)

// ── Spread OTM ──
g_spread     = "Spread OTM"
otm_dist     = input.int(10, "Distancia OTM en puntos",   group=g_spread, minval=5, maxval=100)
spread_width = input.int(5,  "Ancho del spread en puntos", group=g_spread, minval=5)
close_pct    = input.int(50, "Cerrar en % del credito",    group=g_spread, minval=10, maxval=90)

// ── Senal ──
g_sig     = "Senal"
min_score = input.int(3, "Score minimo 1-4",            group=g_sig, minval=1, maxval=4)
sig_gap   = input.int(5, "Barras minimas entre senales", group=g_sig, minval=1)

// ── Sesion ──
g_session = "Sesion de Mercado"
sess_str  = input.string("0930-1545", "Horario NY (HHMM-HHMM)", group=g_session)

// ── VIX ──
g_vix   = "Filtro VIX"
vix_max = input.int(35, "VIX maximo aceptable", group=g_vix)
vix_min = input.int(12, "VIX minimo aceptable", group=g_vix)

// ── Put/Call Ratio ──
g_pc     = "Put Call Ratio"
pcc_bull = input.float(0.7, "Umbral BULL menor que", group=g_pc, step=0.05)
pcc_bear = input.float(1.0, "Umbral BEAR mayor que", group=g_pc, step=0.05)

// ── Visual ──
g_vis      = "Visual"
show_vwap  = input.bool(true, "Mostrar VWAP dia actual",   group=g_vis)
show_pvwap = input.bool(true, "Mostrar VWAP dia anterior", group=g_vis)
show_table = input.bool(true, "Mostrar tabla",             group=g_vis)
show_ma70  = input.bool(true, "Mostrar EMA 70",            group=g_vis)
show_ma120 = input.bool(true, "Mostrar EMA 120",           group=g_vis)

// ═══════════════════════════════════════════════
// VWAP DIA ACTUAL
// ═══════════════════════════════════════════════
vwap_today = ta.vwap(hlc3)
plot(show_vwap ? vwap_today : na, "VWAP Hoy",
     color=color.new(color.rgb(88,166,255), 10), linewidth=2)

// ═══════════════════════════════════════════════
// VWAP DIA ANTERIOR
// ═══════════════════════════════════════════════
vwap_prev_raw = request.security(syminfo.tickerid, "D",
                ta.vwap(hlc3)[1],
                lookahead=barmerge.lookahead_on)
vwap_prev = na(vwap_prev_raw) ? vwap_today : vwap_prev_raw

plot(show_pvwap ? vwap_prev : na, "VWAP Ayer",
     color=color.new(color.rgb(255,160,50), 15), linewidth=2)

// ── EMA 70 y EMA 120 — solo referencia visual ──
ma70  = ta.ema(close, 70)
ma120 = ta.ema(close, 120)
plot(show_ma70  ? ma70  : na, "EMA 70",  color=color.new(color.rgb(205,155,29),  20), linewidth=1)
plot(show_ma120 ? ma120 : na, "EMA 120", color=color.new(color.rgb(255,240,100), 20), linewidth=1)

// ── VIX ──
vix_val = request.security("VIX", timeframe.period, close, lookahead=barmerge.lookahead_off)
vix_ok  = vix_val >= vix_min and vix_val <= vix_max

// ── Put/Call Ratio ──
pcc_raw = request.security("USI:PCCE", "D", close, lookahead=barmerge.lookahead_off)
pcr_raw = request.security("USI:PCC",  "D", close, lookahead=barmerge.lookahead_off)
pcc_val = na(pcc_raw) ? 0.85 : pcc_raw
pcr_val = na(pcr_raw) ? 0.85 : pcr_raw

pcc_txt = pcc_val < pcc_bull ? "BULL" : pcc_val > pcc_bear ? "BEAR" : "NEUT"
pcr_txt = pcr_val < pcc_bull ? "BULL" : pcr_val > pcc_bear ? "BEAR" : "NEUT"
pcc_col = pcc_val < pcc_bull ? color.lime : pcc_val > pcc_bear ? color.red : color.gray
pcr_col = pcr_val < pcc_bull ? color.lime : pcr_val > pcc_bear ? color.red : color.gray

// ── Sesion ──
in_session = not na(time(timeframe.period, sess_str + ":23456", "America/New_York"))
sess_txt   = in_session ? "OPEN" : "CLOSED"
sess_col   = in_session ? color.lime : color.red

// ── ATR ──
atr = ta.atr(14)

// ── Posicion vs VWAPs ──
below_today = close < vwap_today
above_today = close > vwap_today
below_prev  = close < vwap_prev
above_prev  = close > vwap_prev

// ── Cruces VWAP actual ──
cross_today_dn = ta.crossunder(close, vwap_today)
cross_today_up = ta.crossover(close,  vwap_today)

// ═══════════════════════════════════════════════
// SCORING CALL (0-4)
// ═══════════════════════════════════════════════
sc_call_pa    = close < open   ? 1 : 0
sc_call_vwap  = below_today    ? 1 : 0
sc_call_pvwap = below_prev     ? 1 : 0
sc_call_cross = cross_today_dn ? 1 : 0
score_call    = sc_call_pa + sc_call_vwap + sc_call_pvwap + sc_call_cross

// ═══════════════════════════════════════════════
// SCORING PUT (0-4)
// ═══════════════════════════════════════════════
sc_put_pa    = close > open    ? 1 : 0
sc_put_vwap  = above_today     ? 1 : 0
sc_put_pvwap = above_prev      ? 1 : 0
sc_put_cross = cross_today_up  ? 1 : 0
score_put    = sc_put_pa + sc_put_vwap + sc_put_pvwap + sc_put_cross

quality_call = score_call == 4 ? "IDEAL" : score_call == 3 ? "GOOD" : "AVOID"
quality_put  = score_put  == 4 ? "IDEAL" : score_put  == 3 ? "GOOD" : "AVOID"

// ── Strikes ──
base        = math.round(close / 5) * 5
sell_call   = base + otm_dist
buy_call    = sell_call + spread_width
sell_put    = base - otm_dist
buy_put_str = sell_put - spread_width

// ═══════════════════════════════════════════════
// SENALES
// ═══════════════════════════════════════════════
var int last_sig = 0
gap_ok = bar_index - last_sig >= sig_gap

call_signal = score_call >= min_score and cross_today_dn and vix_ok and in_session and gap_ok
put_signal  = score_put  >= min_score and cross_today_up and vix_ok and in_session and gap_ok and not call_signal

if call_signal or put_signal
    last_sig := bar_index

// ── Labels ──
if call_signal
    dual = sc_call_pvwap == 1 ? "DUAL VWAP ✓" : "Solo VWAP hoy"
    tt = "CALL Credit Spread OTM  0DTE" + "\n" +
         "━━━━━━━━━━━━━━━━━━━━━━━━━" + "\n" +
         "Sell: " + str.tostring(sell_call) + " Call" + "\n" +
         "Buy:  " + str.tostring(buy_call)  + " Call" + "\n" +
         "Score:  " + str.tostring(score_call) + "/4  " + quality_call + "\n" +
         "Close:  " + str.tostring(close_pct) + "% del credito" + "\n" +
         "Setup:  " + dual + "\n" +
         "VWAP hoy:  " + str.tostring(math.round(vwap_today, 2)) + "\n" +
         "VWAP ayer: " + str.tostring(math.round(vwap_prev,  2))
    label.new(bar_index, high + atr * 1.2, text="▼",
              color=color.new(color.white, 0), textcolor=color.white,
              style=label.style_none, size=size.normal, tooltip=tt)

if put_signal
    dual = sc_put_pvwap == 1 ? "DUAL VWAP ✓" : "Solo VWAP hoy"
    tt = "PUT Credit Spread OTM  0DTE" + "\n" +
         "━━━━━━━━━━━━━━━━━━━━━━━━━" + "\n" +
         "Sell: " + str.tostring(sell_put)    + " Put" + "\n" +
         "Buy:  " + str.tostring(buy_put_str) + " Put" + "\n" +
         "Score:  " + str.tostring(score_put) + "/4  " + quality_put + "\n" +
         "Close:  " + str.tostring(close_pct) + "% del credito" + "\n" +
         "Setup:  " + dual + "\n" +
         "VWAP hoy:  " + str.tostring(math.round(vwap_today, 2)) + "\n" +
         "VWAP ayer: " + str.tostring(math.round(vwap_prev,  2))
    label.new(bar_index, low - atr * 1.2, text="▲",
              color=color.new(color.white, 0), textcolor=color.white,
              style=label.style_none, size=size.normal, tooltip=tt)

// ── Tabla ──
if show_table
    bg_score  = color.new(color.rgb(15,18,32),  5)
    bg_call   = color.new(color.rgb(25,10,15),  5)
    bg_put    = color.new(color.rgb(10,25,15),  5)
    bg_active = score_call >= score_put ? bg_call : bg_put
    bg_sep    = color.new(color.rgb(40,50,68), 20)
    bg_vix    = color.new(color.rgb(10,14,24),  5)
    bg_pc     = color.new(color.rgb(12,12,28),  5)
    bg_sess   = color.new(color.rgb(12,20,12),  5)
    col_lbl   = color.new(color.rgb(180,195,215), 0)

    is_call_mode    = score_call >= score_put
    active_score    = is_call_mode ? score_call    : score_put
    active_sc_pa    = is_call_mode ? sc_call_pa    : sc_put_pa
    active_sc_vwap  = is_call_mode ? sc_call_vwap  : sc_put_vwap
    active_sc_pvwap = is_call_mode ? sc_call_pvwap : sc_put_pvwap
    active_sc_cross = is_call_mode ? sc_call_cross : sc_put_cross
    active_quality  = is_call_mode ? quality_call  : quality_put
    active_signal   = is_call_mode ? call_signal   : put_signal
    active_sig_txt  = is_call_mode ? (call_signal ? "CALL OTM" : "Wait") : (put_signal ? "PUT OTM" : "Wait")
    active_sig_col  = is_call_mode ? (call_signal ? color.orange : color.gray) : (put_signal ? color.yellow : color.gray)
    active_ind_col  = is_call_mode ? color.red  : color.lime
    mode_txt        = is_call_mode ? "CALL" : "PUT"
    mode_col        = is_call_mode ? color.red : color.lime
    sc_col          = active_score == 4 ? color.lime : active_score == 3 ? color.yellow : color.red

    var table t = table.new(position.top_right, 13, 2,
                            bgcolor      = color.new(color.rgb(10,12,20), 8),
                            border_color = color.new(color.rgb(40,52,70),22),
                            border_width = 1,
                            frame_color  = color.new(color.rgb(40,52,70),18),
                            frame_width  = 1)

    table.cell(t, 0,  0, "MODE",   text_color=col_lbl, text_size=size.tiny,  bgcolor=bg_score, text_halign=text.align_center)
    table.cell(t, 1,  0, "SCORE",  text_color=col_lbl, text_size=size.tiny,  bgcolor=bg_score, text_halign=text.align_center)
    table.cell(t, 2,  0, " ",      bgcolor=bg_sep,      text_size=size.tiny)
    table.cell(t, 3,  0, "PA",     text_color=col_lbl, text_size=size.tiny,  bgcolor=bg_active, text_halign=text.align_center)
    table.cell(t, 4,  0, "VWAP",   text_color=col_lbl, text_size=size.tiny,  bgcolor=bg_active, text_halign=text.align_center)
    table.cell(t, 5,  0, "PVWAP",  text_color=col_lbl, text_size=size.tiny,  bgcolor=bg_active, text_halign=text.align_center)
    table.cell(t, 6,  0, "CROSS",  text_color=col_lbl, text_size=size.tiny,  bgcolor=bg_active, text_halign=text.align_center)
    table.cell(t, 7,  0, " ",      bgcolor=bg_sep,      text_size=size.tiny)
    table.cell(t, 8,  0, "VIX",    text_color=col_lbl, text_size=size.tiny,  bgcolor=bg_vix,    text_halign=text.align_center)
    table.cell(t, 9,  0, "SESS",   text_color=col_lbl, text_size=size.tiny,  bgcolor=bg_sess,   text_halign=text.align_center)
    table.cell(t, 10, 0, "SIGNAL", text_color=col_lbl, text_size=size.tiny,  bgcolor=bg_vix,    text_halign=text.align_center)
    table.cell(t, 11, 0, "QUALIT", text_color=col_lbl, text_size=size.tiny,  bgcolor=bg_vix,    text_halign=text.align_center)
    table.cell(t, 12, 0, "PCC",    text_color=col_lbl, text_size=size.tiny,  bgcolor=bg_pc,     text_halign=text.align_center)

    table.cell(t, 0,  1, mode_txt,                        text_color=mode_col,       text_size=size.small, bgcolor=bg_score,  text_halign=text.align_center)
    table.cell(t, 1,  1, str.tostring(active_score)+"/4", text_color=sc_col,         text_size=size.small, bgcolor=bg_score,  text_halign=text.align_center)
    table.cell(t, 2,  1, " ", bgcolor=bg_sep, text_size=size.tiny)
    table.cell(t, 3,  1, active_sc_pa   ==1?"+":" -", text_color=active_sc_pa   ==1?active_ind_col:color.gray, text_size=size.small, bgcolor=bg_active, text_halign=text.align_center)
    table.cell(t, 4,  1, active_sc_vwap ==1?"+":" -", text_color=active_sc_vwap ==1?active_ind_col:color.gray, text_size=size.small, bgcolor=bg_active, text_halign=text.align_center)
    table.cell(t, 5,  1, active_sc_pvwap==1?"+":" -", text_color=active_sc_pvwap==1?active_ind_col:color.gray, text_size=size.small, bgcolor=bg_active, text_halign=text.align_center)
    table.cell(t, 6,  1, active_sc_cross==1?"+":" -", text_color=active_sc_cross==1?active_ind_col:color.gray, text_size=size.small, bgcolor=bg_active, text_halign=text.align_center)
    table.cell(t, 7,  1, " ", bgcolor=bg_sep, text_size=size.tiny)
    table.cell(t, 8,  1, str.tostring(math.round(vix_val,1)), text_color=vix_ok?color.lime:color.red, text_size=size.small, bgcolor=bg_vix,  text_halign=text.align_center)
    table.cell(t, 9,  1, sess_txt,         text_color=sess_col,       text_size=size.small, bgcolor=bg_sess, text_halign=text.align_center)
    table.cell(t, 10, 1, active_sig_txt,   text_color=active_sig_col, text_size=size.small, bgcolor=bg_vix,  text_halign=text.align_center)
    table.cell(t, 11, 1, active_signal ? active_quality : "-", text_color=sc_col, text_size=size.small, bgcolor=bg_vix, text_halign=text.align_center)
    table.cell(t, 12, 1, str.tostring(math.round(pcc_val,2))+" "+pcc_txt, text_color=pcc_col, text_size=size.tiny, bgcolor=bg_pc, text_halign=text.align_center)

// ── Alertas ──
alertcondition(call_signal,               title="CALL OTM", message="GLICK Scout: Call Credit Spread OTM 0DTE — Dual VWAP bajista.")
alertcondition(put_signal,                title="PUT OTM",  message="GLICK Scout: Put Credit Spread OTM 0DTE — Dual VWAP alcista.")
alertcondition(call_signal or put_signal, title="GLICK",    message="GLICK Scout: Senal Dual VWAP detectada.")
````
