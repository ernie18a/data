# golden zone (by appaz suarez gabriel)

- url: https://www.tradingview.com/script/oNdxpj3p/
- type: indicator
- pine_id: PUB;3af7cda082f947738a8675eab1040821
- version: 2.0

## Description

manten presente tu golden zone, para que no necesites marcar tu fibo

## Source Code

````pine
//@version=6
// @author appaz suarez gabriel
indicator("Elaris Master Pro v3 - Ultra Clean (by appaz suarez gabriel)", overlay=true, max_boxes_count=100)

// --- PARAMETROS DE CONFIGURACIÓN ---
int pivot_len = input.int(10, title="Sensibilidad Estructura (Mayor)", group="Configuración de Autor: appaz suarez gabriel")
int bb_len = input.int(20, title="BB Len", group="Configuración de Autor: appaz suarez gabriel")
float bb_mult = input.float(2.0, title="BB Mult", group="Configuración de Autor: appaz suarez gabriel")
int rsi_len = input.int(14, title="RSI Len", group="Configuración de Autor: appaz suarez gabriel")
int rsi_ob = input.int(70, title="RSI OB", group="Configuración de Autor: appaz suarez gabriel")
int rsi_os = input.int(30, title="RSI OS", group="Configuración de Autor: appaz suarez gabriel")
int ema_len = input.int(200, title="Periodos EMA", group="Configuración de Autor: appaz suarez gabriel")

// --- COLORES ---
color c_gz = input.color(#ffcc0022, title="Color Area GZ")

// --- EMA FILTRO TENDENCIA ---
ema_200 = ta.ema(close, ema_len)
plot(ema_200, color=#a020f0, linewidth=2, title="EMA 200")

// --- DETECCIÓN DE PIVOTS ---
float p_high = ta.pivothigh(high, pivot_len, pivot_len)
float p_low  = ta.pivotlow(low, pivot_len, pivot_len)

// VARIABLES DE MEMORIA INSTITUCIONAL PERSISTENTES
var float mx_blq = na
var float mn_blq = na
var int idx_high = na
var int idx_low  = na
var bool candado_total = false
var bool mitigado = false
var bool es_alcista = false

// Verificar rupturas reales basadas estrictamente en los extremos congelados
bool rompe_arriba = candado_total and close > mx_blq
bool rompe_abajo  = candado_total and close < mn_blq

// El ciclo solo se resetea por una ruptura estructural válida
if rompe_arriba or rompe_abajo
    if mitigado
        mx_blq := na
        mn_blq := na
        idx_high := na
        idx_low := na
        candado_total := false
        mitigado := false
    else
        if rompe_arriba and not na(p_high)
            mx_blq := p_high
            idx_high := bar_index - pivot_len
        if rompe_abajo and not na(p_low)
            mn_blq := p_low
            idx_low := bar_index - pivot_len

// Registrar y fijar extremos mayores sin interferencias de la EMA
if not candado_total
    if not na(p_high)
        mx_blq := p_high
        idx_high := bar_index - pivot_len
    if not na(p_low)
        mn_blq := p_low
        idx_low := bar_index - pivot_len
    
    // Una vez que ambos extremos se consolidan, bloqueamos y definimos la dirección teórica original
    if not na(mx_blq) and not na(mn_blq) and not na(idx_high) and not na(idx_low)
        candado_total := true
        mitigado := false
        es_alcista := idx_low < idx_high

// --- CÁLCULO DE LA GOLDEN ZONE ESTÁTICA EN TIEMPO REAL ---
float diff = candado_total ? mx_blq - mn_blq : na
float fib_50  = na
float fib_786 = na

if candado_total
    // Si la estructura nació alcista, la Golden Zone se queda ABAJO de forma permanente
    if es_alcista
        fib_50  := mx_blq - (diff * 0.50)
        fib_786 := mx_blq - (diff * 0.786)
    // Si la estructura nació bajista, la Golden Zone se queda ARRIBA de forma permanente
    else
        fib_50  := mn_blq + (diff * 0.50)
        fib_786 := mn_blq + (diff * 0.786)

// --- CONTROL DE MITIGACIÓN ---
if candado_total and not na(fib_50) and not mitigado
    if (es_alcista and low <= fib_50) or (not es_alcista and high >= fib_50)
        mitigado := true

// Dibujo de las líneas de la Golden Zone (Solo si el candado está activo para limpiar el pasado)
p_f50  = plot(candado_total ? fib_50 : na, color=#ffcc0055, style=plot.style_linebr, title="Fib 50%")
p_f786 = plot(candado_total ? fib_786 : na, color=#ffcc0055, style=plot.style_linebr, title="Fib 78.6%")

// Relleno seguro nativo v6 (Limpio y sin efecto de barras verticales)
fill(p_f50, p_f786, color=candado_total ? c_gz : na, title="Golden Zone Area")

// Ploteo de los extremos fijos congelados/expandidos
plot(mx_blq, color=#ff0000, style=plot.style_linebr, linewidth=2, title="Maximo Mayor")
plot(mn_blq, color=#00ff00, style=plot.style_linebr, linewidth=2, title="Minimo Mayor")

// --- ALGORITMO DE SEÑALES ---
bool break_up   = false
bool break_down = false
var float u_bu = na
var float u_bd = na

if candado_total
    if high > mx_blq and close > mx_blq and mx_blq != u_bu
        break_up := true
        u_bu := mx_blq
    if low < mn_blq and close < mn_blq and mn_blq != u_bd
        break_down := true
        u_bd := mn_blq

[bb_basis, bb_up, bb_low] = ta.bb(close, bb_len, bb_mult)
rsi_val = ta.rsi(close, rsi_len)

bool rango_buy  = false
bool rango_sell = false
var bool p_c_u = false
var bool p_v_u = false

if low <= bb_low and rsi_val <= rsi_os and not break_down
    if not p_c_u
        rango_buy := true
        p_c_u := true
else if low > bb_basis
    p_c_u := false

if high >= bb_up and rsi_val >= rsi_ob and not break_up
    if not p_v_u
        rango_sell := true
        p_v_u := true
else if high < bb_basis
    p_v_u := false

// Filtro de señales operativas por EMA 200
bool c_buy  = close > ema_200
bool c_sell = close < ema_200

bool m_b_up   = break_up and c_buy
bool m_r_buy  = rango_buy and c_buy
bool m_b_down = break_down and c_sell
bool m_r_sell = rango_sell and c_sell

// Ploteo estético pegado a las velas
float atr = ta.atr(14)
float p_up = high + (atr * 0.2)
float p_dn = low - (atr * 0.2)

plotshape(m_b_up ? p_dn : na, style=shape.triangleup, location=location.absolute, color=#00ff00, text="BUY BREAK", textcolor=#00ff00)
plotshape(m_b_down ? p_up : na, style=shape.triangledown, location=location.absolute, color=#ff0000, text="SELL BREAK", textcolor=#ff0000)
plotshape(m_r_buy ? p_dn : na, style=shape.arrowup, location=location.absolute, color=#00ffff, text="BUY RANGE", textcolor=#00ffff)
plotshape(m_r_sell ? p_up : na, style=shape.arrowdown, location=location.absolute, color=#ff00ff, text="SELL RANGE", textcolor=#ff00ff)

// Sistema de Alertas nativo v6
if m_b_up
    alert("¡BUY BREAK por ruptura estructural!", alert.freq_once_per_bar_close)
if m_b_down
    alert("¡SELL BREAK por ruptura estructural!", alert.freq_once_per_bar_close)
if m_r_buy
    alert("¡BUY RANGE por rebote de rango!", alert.freq_once_per_bar_close)
if m_r_sell
    alert("¡SELL RANGE por rebote de rango!", alert.freq_once_per_bar_close)
````
