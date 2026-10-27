# EBP H4 Chris

- url: https://www.tradingview.com/script/iK891G2X/
- type: indicator
- pine_id: PUB;b6babb6872434a1e9b3a29e86fd1b175
- version: 2.0

## Description

Indicatore EBP, rileva sul grafico selezionato le candele EBP, ovvero Engulfing Bar Play.

## Source Code

````pine
//@version=5
indicator("EBP H4 Custom Pro V5 - MTF Monitoring", overlay=true, max_labels_count=500)

// --- INPUTS: SESSIONI E FILTRI ORARI ---
group_sessions = "Impostazioni Orari (H4)"

sess_1 = input.session("0700-1100", "Sessione 1", group=group_sessions)
high_1 = input.bool(false, "Evidenzia Sessione 1", group=group_sessions, inline="s1")
col_1  = input.color(color.new(color.yellow, 0), "", group=group_sessions, inline="s1")

sess_2 = input.session("1100-1500", "Sessione 2", group=group_sessions)
high_2 = input.bool(false, "Evidenzia Sessione 2", group=group_sessions, inline="s2")
col_2  = input.color(color.new(color.orange, 0), "", group=group_sessions, inline="s2")

sess_3 = input.session("1500-1900", "Sessione 3", group=group_sessions)
high_3 = input.bool(true, "Evidenzia Sessione 3", group=group_sessions, inline="s3")
col_3  = input.color(color.new(color.blue, 0), "", group=group_sessions, inline="s3")

sess_4 = input.session("1900-2300", "Sessione 4", group=group_sessions)
high_4 = input.bool(false, "Evidenzia Sessione 4", group=group_sessions, inline="s4")
col_4  = input.color(color.new(color.purple, 0), "", group=group_sessions, inline="s4")

// Funzione controllo orario
is_in_session(sess) => not na(time(timeframe.period, sess, "UTC+2")) 

// Logica per determinare il colore corrente
color dynamic_col = na
if is_in_session(sess_1) and high_1
    dynamic_col := col_1
else if is_in_session(sess_2) and high_2
    dynamic_col := col_2
else if is_in_session(sess_3) and high_3
    dynamic_col := col_3
else if is_in_session(sess_4) and high_4
    dynamic_col := col_4

bgcolor(not na(dynamic_col) ? color.new(dynamic_col, 90) : na, title="Highlight Sessione")
barcolor(not na(dynamic_col) ? dynamic_col : na, title="Colore Candela")

// --- MONITORAGGIO STRUTTURA MTF DINAMICA ---
group_mtf = "Monitoraggio Struttura MTF"
ema_len = input.int(20, "Periodo EMA Struttura", minval=1, group=group_mtf)

// Determinazione automatica dei Timeframe
tf_high = timeframe.isintraday and timeframe.multiplier <= 60 ? "240" : "D"
tf_daily = "D"

// Funzione per ottenere la tendenza (Solo per visualizzazione)
get_trend(tf) =>
    ema_val = ta.ema(close, ema_len)
    price_high = request.security(syminfo.tickerid, tf, close)
    ema_high   = request.security(syminfo.tickerid, tf, ema_val)
    price_high > ema_high ? "BULL" : "BEAR"

struct_high = get_trend(tf_high)
struct_daily = get_trend(tf_daily)

// Tabella Informativa (Sempre visibile per tua decisione manuale)
var table panel = table.new(position.top_right, 2, 2, border_width = 1)
if barstate.islast
    table.cell(panel, 0, 0, "TF " + (tf_high == "240" ? "H4" : "D1"), bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 0, struct_high, bgcolor=(struct_high == "BULL" ? color.green : color.red), text_color=color.white, text_size=size.small)
    table.cell(panel, 0, 1, "TF D1", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 1, struct_daily, bgcolor=(struct_daily == "BULL" ? color.green : color.red), text_color=color.white, text_size=size.small)

// --- LOGICA SEGNALI (SENZA FILTRI BLOCCANTI) ---
in_any_session = is_in_session(sess_1) or is_in_session(sess_2) or is_in_session(sess_3) or is_in_session(sess_4)

high_prev = high[1]
low_prev = low[1]
body_high_prev = math.max(open[1], close[1])
body_low_prev = math.min(open[1], close[1])

// I segnali appaiono sempre se la condizione EBP è soddisfatta in sessione
is_bullish_ebp = in_any_session and (low < low_prev and close > body_high_prev)
is_bearish_ebp = in_any_session and (high > high_prev and close < body_low_prev)

// --- INPUTS DISPLAY & FIBONACCI ---
group_disp = "Visualizzazione Fibonacci"
line_length = input.int(4, "Lunghezza Linee", minval=1, group=group_disp)
max_signals = input.int(10, "Numero massimo di segnali", group=group_disp)
col_fib_lines = input.color(color.blue, "Colore 0.25 / 0.75", group=group_disp)
col_fib_mid   = input.color(color.orange, "Colore 0.5", group=group_disp)
col_fib_ext   = input.color(color.gray, "Colore 0 / 1", group=group_disp)
col_labels    = input.color(color.white, "Colore Testo Valori", group=group_disp)

// --- GESTIONE DISEGNI ---
var line[] fib_lines = array.new_line()
var label[] fib_labels = array.new_label()

clean_old_drawings() =>
    if array.size(fib_lines) > max_signals * 5 
        for i = 1 to 5
            line.delete(array.shift(fib_lines))
    if array.size(fib_labels) > max_signals * 5
        for i = 1 to 5
            label.delete(array.shift(fib_labels))

draw_fib_step(x1, x2, y_val, txt_val, col_val, style_val) =>
    l = line.new(x1, y_val, x2, y_val, color=col_val, style=style_val, width=1)
    lb = label.new(x2, y_val, txt_val, style=label.style_none, textcolor=col_labels, textalign=text.align_left, size=size.small)
    array.push(fib_lines, l)
    array.push(fib_labels, lb)

// --- ESECUZIONE ---
plotshape(is_bullish_ebp, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Freccia Long")
plotshape(is_bearish_ebp, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, title="Freccia Short")

if is_bullish_ebp
    float r = high - low
    int end_bar = bar_index + line_length
    draw_fib_step(bar_index, end_bar, high, "0", col_fib_ext, line.style_solid)
    draw_fib_step(bar_index, end_bar, high - r * 0.25, "0.25", col_fib_lines, line.style_solid)
    draw_fib_step(bar_index, end_bar, high - r * 0.50, "0.5", col_fib_mid, line.style_dashed)
    draw_fib_step(bar_index, end_bar, high - r * 0.75, "0.75", col_fib_lines, line.style_solid)
    draw_fib_step(bar_index, end_bar, low, "1", col_fib_ext, line.style_solid)
    clean_old_drawings()

if is_bearish_ebp
    float r = high - low
    int end_bar = bar_index + line_length
    draw_fib_step(bar_index, end_bar, low, "0", col_fib_ext, line.style_solid)
    draw_fib_step(bar_index, end_bar, low + r * 0.25, "0.25", col_fib_lines, line.style_solid)
    draw_fib_step(bar_index, end_bar, low + r * 0.50, "0.5", col_fib_mid, line.style_dashed)
    draw_fib_step(bar_index, end_bar, low + r * 0.75, "0.75", col_fib_lines, line.style_solid)
    draw_fib_step(bar_index, end_bar, high, "1", col_fib_ext, line.style_solid)
    clean_old_drawings()
````
