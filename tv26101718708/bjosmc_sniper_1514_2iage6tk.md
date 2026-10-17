# BJO-SMC sniper 15/1/4

- url: https://www.tradingview.com/script/2IaGE6TK/
- type: indicator
- pine_id: PUB;5f56252e0a2e4f18bbf9471626eb8dc2
- version: 1.0

## Description

Basado en el concepto de Smart Money concept, he diseñado este indicador para buscar Señales long y short, sirve en multiples temporalidades

## Source Code

````pine
//@version=6
indicator("BJO-SMC sniper 15/1/4", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ========================================================================= //
// 1. CONFIGURACIÓN GENERAL Y VARIABLES MACRO
// ========================================================================= //
grp_time = "Temporalidades Top-Down"
macro_tf = input.timeframe("240", title="Fase Macro (DOL)", group=grp_time) // 4 Horas
struct_tf = input.timeframe("60", title="Fase Estructural (POI)", group=grp_time) // 1 Hora

grp_killzones = "Killzones (Horario NY)"
asia_time = input.session("2000-0000", title="Asia (Fábrica Liquidez)", group=grp_killzones)
ny_time = input.session("0800-1200", title="New York (Ejecución)", group=grp_killzones)
tz = "America/New_York"

// ========================================================================= //
// 2. DETECCIÓN DE KILLZONES
// ========================================================================= //
in_asia = not na(time(timeframe.period, asia_time, tz))
in_ny = not na(time(timeframe.period, ny_time, tz))

bgcolor(in_asia ? color.new(color.blue, 90) : na, title="Fondo Asia")
bgcolor(in_ny ? color.new(color.red, 90) : na, title="Fondo NY")

// ========================================================================= //
// 3. IDENTIFICACIÓN DE LIQUIDEZ Y EQUAL HIGHS/LOWS
// ========================================================================= //
atr = ta.atr(14)
pivot_len = input.int(5, title="Longitud de Pivotes", minval=1)
ph = ta.pivothigh(high, pivot_len, pivot_len)
pl = ta.pivotlow(low, pivot_len, pivot_len)
tol = atr * 0.10 // Tolerancia dinámica

var float last_ph = na
var float last_pl = na

if not na(ph)
    if not na(last_ph) and math.abs(ph - last_ph) <= tol
        line.new(bar_index[pivot_len*3], last_ph, bar_index-pivot_len, ph, color=color.red, style=line.style_dashed, width=2)
        label.new(bar_index-pivot_len, ph, "BSL (EQH)", color=color.new(color.red, 80), style=label.style_label_down, textcolor=color.white, size=size.tiny)
    last_ph := ph

if not na(pl)
    if not na(last_pl) and math.abs(pl - last_pl) <= tol
        line.new(bar_index[pivot_len*3], last_pl, bar_index-pivot_len, pl, color=color.blue, style=line.style_dashed, width=2)
        label.new(bar_index-pivot_len, pl, "SSL (EQL)", color=color.new(color.blue, 80), style=label.style_label_up, textcolor=color.white, size=size.tiny)
    last_pl := pl

// ========================================================================= //
// 4. FAIR VALUE GAPS (FVG), ORDER BLOCKS (OB) Y MEMORIA ESTRUCTURAL
// ========================================================================= //
bull_fvg = low > high[2]
bear_fvg = high < low[2]

bull_ob = close[2] < open[2] and bull_fvg
bear_ob = close[2] > open[2] and bear_fvg

// Dibujar Cajas de OB
if bull_ob
    box.new(bar_index[2], high[2], bar_index, low[2], bgcolor=color.new(color.green, 80), border_color=color.green, text="Bull OB", text_size=size.tiny)
if bear_ob
    box.new(bar_index[2], high[2], bar_index, low[2], bgcolor=color.new(color.red, 80), border_color=color.red, text="Bear OB", text_size=size.tiny)

// --- Memoria de FVG No Mitigados (El "Scanner" para TPs) ---
var float unmit_bear_fvg_prox = na // Borde proximal (abajo) del FVG Bajista
var float unmit_bear_fvg_ce = na   // 50% del FVG Bajista
var float unmit_bear_fvg_dist = na // Borde distal (arriba) del FVG Bajista

if bear_fvg
    unmit_bear_fvg_prox := high
    unmit_bear_fvg_dist := low[2]
    unmit_bear_fvg_ce := (unmit_bear_fvg_prox + unmit_bear_fvg_dist) / 2

// Si el precio cruza por encima del FVG bajista, se considera mitigado (lo borramos)
if not na(unmit_bear_fvg_dist) and high > unmit_bear_fvg_dist
    unmit_bear_fvg_prox := na
    unmit_bear_fvg_ce := na
    unmit_bear_fvg_dist := na

var float unmit_bull_fvg_prox = na // Borde proximal (arriba) del FVG Alcista
var float unmit_bull_fvg_ce = na   // 50% del FVG Alcista
var float unmit_bull_fvg_dist = na // Borde distal (abajo) del FVG Alcista

if bull_fvg
    unmit_bull_fvg_prox := low
    unmit_bull_fvg_dist := high[2]
    unmit_bull_fvg_ce := (unmit_bull_fvg_prox + unmit_bull_fvg_dist) / 2

// Si el precio cruza por debajo del FVG alcista, se considera mitigado (lo borramos)
if not na(unmit_bull_fvg_dist) and low < unmit_bull_fvg_dist
    unmit_bull_fvg_prox := na
    unmit_bull_fvg_ce := na
    unmit_bull_fvg_dist := na

// ========================================================================= //
// 5. SEÑALES DE ENTRADA, SL ESTRUCTURAL Y TP DINÁMICO LEYENDO ESTRUCTURA
// ========================================================================= //
long_cond = in_ny and bull_fvg and close > open
short_cond = in_ny and bear_fvg and close < open

var float entry_price = na
var float sl_price = na
var float tp1_price = na
var float tp2_price = na

if long_cond and not long_cond[1]
    entry_price := high[2]
    sl_price := low[2] - (atr * 0.2) // SL Estructural
    risk = entry_price - sl_price
    
    float base_tp_2 = entry_price + (risk * 2) // Ratio mínimo 1:2
    string tp_text_1 = "TP1 (1:1)"
    string tp_text_2 = "TP2 (1:2 Base)"
    
    // Lógica del TP Dinámico: Escanear FVG Bajista por encima
    if not na(unmit_bear_fvg_prox) and unmit_bear_fvg_prox > base_tp_2
        tp1_price := unmit_bear_fvg_prox
        tp2_price := unmit_bear_fvg_ce
        tp_text_1 := "TP1 (Inicio FVG)"
        tp_text_2 := "TP2 (50% FVG)"
    else
        tp1_price := entry_price + risk
        tp2_price := base_tp_2
        
    // Dibujo
    line.new(bar_index, entry_price, bar_index+10, entry_price, color=color.blue, width=2)
    label.new(bar_index+10, entry_price, "LONG ENTRY", color=color.blue, textcolor=color.white, style=label.style_label_left, size=size.small)
    
    line.new(bar_index, sl_price, bar_index+10, sl_price, color=color.red, style=line.style_dashed, width=2)
    label.new(bar_index+10, sl_price, "SL Estructural", color=color.red, textcolor=color.white, style=label.style_label_left, size=size.small)
    
    line.new(bar_index, tp1_price, bar_index+10, tp1_price, color=color.gray, style=line.style_dotted, width=1)
    label.new(bar_index+10, tp1_price, tp_text_1, color=color.gray, textcolor=color.white, style=label.style_label_left, size=size.tiny)
    
    line.new(bar_index, tp2_price, bar_index+10, tp2_price, color=color.green, width=2)
    label.new(bar_index+10, tp2_price, tp_text_2, color=color.green, textcolor=color.white, style=label.style_label_left, size=size.small)

if short_cond and not short_cond[1]
    entry_price := low[2]
    sl_price := high[2] + (atr * 0.2) // SL Estructural
    risk = sl_price - entry_price
    
    float base_tp_2 = entry_price - (risk * 2) // Ratio mínimo 1:2
    string tp_text_1 = "TP1 (1:1)"
    string tp_text_2 = "TP2 (1:2 Base)"
    
    // Lógica del TP Dinámico: Escanear FVG Alcista por debajo
    if not na(unmit_bull_fvg_prox) and unmit_bull_fvg_prox < base_tp_2
        tp1_price := unmit_bull_fvg_prox
        tp2_price := unmit_bull_fvg_ce
        tp_text_1 := "TP1 (Inicio FVG)"
        tp_text_2 := "TP2 (50% FVG)"
    else
        tp1_price := entry_price - risk
        tp2_price := base_tp_2
        
    // Dibujo
    line.new(bar_index, entry_price, bar_index+10, entry_price, color=color.fuchsia, width=2)
    label.new(bar_index+10, entry_price, "SHORT ENTRY", color=color.fuchsia, textcolor=color.white, style=label.style_label_left, size=size.small)
    
    line.new(bar_index, sl_price, bar_index+10, sl_price, color=color.red, style=line.style_dashed, width=2)
    label.new(bar_index+10, sl_price, "SL Estructural", color=color.red, textcolor=color.white, style=label.style_label_left, size=size.small)
    
    line.new(bar_index, tp1_price, bar_index+10, tp1_price, color=color.gray, style=line.style_dotted, width=1)
    label.new(bar_index+10, tp1_price, tp_text_1, color=color.gray, textcolor=color.white, style=label.style_label_left, size=size.tiny)
    
    line.new(bar_index, tp2_price, bar_index+10, tp2_price, color=color.green, width=2)
    label.new(bar_index+10, tp2_price, tp_text_2, color=color.green, textcolor=color.white, style=label.style_label_left, size=size.small)
````
