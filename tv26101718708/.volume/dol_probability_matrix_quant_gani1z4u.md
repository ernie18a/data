# DOL Probability Matrix [Quant]

- url: https://www.tradingview.com/script/gAnI1Z4u/
- type: indicator
- pine_id: PUB;9e615e1433554b4f9c34138274264762
- version: 1.0

## Description

Davidreyna dol probability, donde puedes ver la probabilidad que tiene el precio de llegar a una liquidez ya sea si es sellside o buyside, aparte te identifica el bias

## Source Code

````pine
// ============================================================
// DOL PROBABILITY MATRIX v1.1 — Pine Script v6
// Proxy Cuantitativo basado en Volume Delta, Distancia y Tendencia
// ============================================================

//@version=6
indicator("DOL Probability Matrix [Quant]", overlay=true, max_lines_count=10, max_labels_count=10)

// ─── FIX PARA EL BUFFER DE MEMORIA ───────────────────────────
// Obligamos a TradingView a recordar hasta 500 velas en el pasado
// para que el ciclo 'for' del Volume Profile no se quede sin datos.
max_bars_back(volume, 500)
max_bars_back(high, 500)
max_bars_back(low, 500)

// ─── INPUTS ──────────────────────────────────────────────────
grp1 = "⚙️ Liquidez (DOL)"
liq_lookback = input.int(50, "Periodo para detectar Liquidez", group=grp1)

grp2 = "📊 Ponderación de Probabilidades"
weight_dist  = input.int(40, "Peso: Distancia (%)", group=grp2)
weight_delta = input.int(30, "Peso: Volume Delta/Footprint Proxy (%)", group=grp2)
weight_trend = input.int(20, "Peso: Tendencia HTF (%)", group=grp2)
weight_poc   = input.int(10, "Peso: Volume Profile (POC) (%)", group=grp2)

// ─── LÓGICA DE LIQUIDEZ (DOL) ────────────────────────────────
// Encontramos los Swing Highs y Lows principales (BSL y SSL)
bsl = ta.highest(high, liq_lookback)
ssl = ta.lowest(low,   liq_lookback)

// ─── FOOTPRINT PROXY (CUMULATIVE VOLUME DELTA) ───────────────
// Aproximación del flujo de órdenes (compradores vs vendedores)
up_vol = close > open ? volume : (close == open ? volume / 2 : 0)
dn_vol = close < open ? volume : (close == open ? volume / 2 : 0)
delta  = up_vol - dn_vol

// Suavizado del Delta para ver la presión institucional reciente
delta_ema = ta.ema(delta, 10)
bullish_footprint = delta_ema > 0
bearish_footprint = delta_ema < 0

// ─── TENDENCIA HTF ───────────────────────────────────────────
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
bull_trend = ema50 > ema200
bear_trend = ema50 < ema200

// ─── VOLUME PROFILE PROXY (POC) ──────────────────────────────
// Calculamos el nivel de precio con más volumen en la zona reciente
var float poc_price = na
if barstate.islast
    float max_vol = 0
    // Aseguramos que el loop no exceda el límite de max_bars_back
    loop_limit = math.min(liq_lookback, 499)
    for i = 0 to loop_limit - 1
        if volume[i] > max_vol
            max_vol   := volume[i]
            poc_price := (high[i] + low[i]) / 2

// ─── MOTOR DE PROBABILIDADES ─────────────────────────────────
var float prob_bsl = 0.0
var float prob_ssl = 0.0

if barstate.islast
    // 1. Puntaje de Distancia (0 al máximo asignado)
    total_range = bsl - ssl
    dist_to_bsl = close - ssl // Cuanto más lejos del fondo, más cerca del techo
    dist_to_ssl = bsl - close 
    
    score_dist_bsl = total_range > 0 ? (dist_to_bsl / total_range) * weight_dist : 0
    score_dist_ssl = total_range > 0 ? (dist_to_ssl / total_range) * weight_dist : 0
    
    // 2. Puntaje de Footprint/Delta
    score_delta_bsl = bullish_footprint ? weight_delta : 0
    score_delta_ssl = bearish_footprint ? weight_delta : 0
    
    // 3. Puntaje de Tendencia
    score_trend_bsl = bull_trend ? weight_trend : 0
    score_trend_ssl = bear_trend ? weight_trend : 0
    
    // 4. Puntaje de Volume Profile (Si el precio está por encima del POC, presiona arriba)
    score_poc_bsl = close > poc_price ? weight_poc : 0
    score_poc_ssl = close < poc_price ? weight_poc : 0
    
    // SUMA TOTAL
    prob_bsl := score_dist_bsl + score_delta_bsl + score_trend_bsl + score_poc_bsl
    prob_ssl := score_dist_ssl + score_delta_ssl + score_trend_ssl + score_poc_ssl

// ─── DIBUJOS Y ETIQUETAS (Visualización en tiempo real) ──────
var line line_bsl = na
var line line_ssl = na
var label lbl_bsl = na
var label lbl_ssl = na

if barstate.islast
    // Limpiar dibujos anteriores
    line.delete(line_bsl)
    line.delete(line_ssl)
    label.delete(lbl_bsl)
    label.delete(lbl_ssl)
    
    // Líneas de Liquidez
    line_bsl := line.new(bar_index - liq_lookback, bsl, bar_index + 5, bsl, color=color.red, width=2, style=line.style_dashed)
    line_ssl := line.new(bar_index - liq_lookback, ssl, bar_index + 5, ssl, color=color.lime, width=2, style=line.style_dashed)
    
    // Etiquetas de Probabilidad
    txt_bsl = "BSL (Liquidez)\nProbabilidad: " + str.tostring(prob_bsl, "#.##") + "%"
    lbl_bsl := label.new(bar_index + 5, bsl, txt_bsl, color=color.new(color.red, 80), textcolor=color.white, style=label.style_label_left, size=size.normal)
    
    txt_ssl = "SSL (Liquidez)\nProbabilidad: " + str.tostring(prob_ssl, "#.##") + "%"
    lbl_ssl := label.new(bar_index + 5, ssl, txt_ssl, color=color.new(color.lime, 80), textcolor=color.white, style=label.style_label_left, size=size.normal)

// ─── PANEL DE DATOS ──────────────────────────────────────────
var table panel = table.new(position.bottom_right, 2, 5, bgcolor=color.new(color.black, 10), border_color=color.gray, border_width=1)

if barstate.islast
    table.cell(panel, 0, 0, "MÉTRICA DOL",      text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(panel, 1, 0, "ESTADO",           text_color=color.white, bgcolor=color.new(color.navy, 0))
    
    table.cell(panel, 0, 1, "Footprint Delta",  text_color=color.silver)
    table.cell(panel, 1, 1, bullish_footprint ? "Comprador 🟢" : "Vendedor 🔴", text_color=bullish_footprint ? color.lime : color.red)
    
    table.cell(panel, 0, 2, "POC Level",        text_color=color.silver)
    table.cell(panel, 1, 2, str.tostring(poc_price, "#.##"), text_color=color.orange)
    
    table.cell(panel, 0, 3, "HIT BSL (%)",      text_color=color.white, bgcolor=color.new(color.red, 80))
    table.cell(panel, 1, 3, str.tostring(prob_bsl, "#.##") + "%", text_color=color.white)
    
    table.cell(panel, 0, 4, "HIT SSL (%)",      text_color=color.white, bgcolor=color.new(color.lime, 80))
    table.cell(panel, 1, 4, str.tostring(prob_ssl, "#.##") + "%", text_color=color.white)
````
