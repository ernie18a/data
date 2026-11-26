# Squeeze Momentum + ADX Memo

- url: https://www.tradingview.com/script/ITKJj6Ml/
- type: indicator
- pine_id: PUB;bf8b5d50296f47878719d6d13dd2ee12
- version: 1.0

## Description

This indicator is a comprehensive technical analysis tool that combines the volatility detection of the Squeeze Momentum with the trend strength of the ADX (Average Directional Index). It is optimized to provide a clear reading of price action across multiple timeframes.

Unlike standard oscillators, this customized version by Memo integrates a dynamic Multi-Timeframe (MTF) info panel and a visual scaling system, allowing you to monitor strength and momentum in a single pane without cluttering your price chart.

🛠 KEY FEATURES
Squeeze Momentum: Identifies compression phases (red dots) and volatility breakouts (green dots).

Dynamic ADX: ADX and DI+/DI- lines are proportionally scaled to the histogram for intuitive visualization.

Multi-Timeframe Analysis (MTF): A dedicated dashboard shows trend strength and direction (EMA 200) for both the current chart and a higher timeframe (e.g., 1D).

Divergence Detector: Automatically identifies Bullish and Bearish divergences (BULL/BEAR DIV).

Signal Labels: LONG and SHORT markers triggered when trend strength is confirmed.

📘 DETAILED USER GUIDE
1. Understanding the Elements
Histogram: Cyan/Blue (Bullish), Red/Maroon (Bearish).

Center Dots: Red dots indicate the market is "squeezing" (price compression/accumulation). Green dots indicate the squeeze has released and a trend is underway.

White Line (ADX): Above the Critical Level (23) indicates a strong trend. Below 23 suggests a range-bound or "choppy" market.

2. Trading Strategy (High Probability Setup)
LONG Entry (Buy):

Squeeze: Red dots must be present (accumulation phase).

Shift: Histogram starts moving up or changes to recovery colors.

Strength: The ADX (white line) crosses above the critical level (23).

Confirmation: DI+ (green) must be above DI- (red).

Macro Filter: The dashboard must show a BULLISH trend on the Higher Timeframe.

SHORT Entry (Sell):

Squeeze: Red dots must be present.

Shift: Histogram starts dropping with increasing momentum.

Strength: The ADX crosses above the critical level (strength is gaining on the downside).

Confirmation: DI- (red) must be above DI+ (green).

Macro Filter: The dashboard must show a BEARISH trend on the Higher Timeframe.

3. Divergences & Exits
Use the BULL DIV and BEAR DIV labels as warning signals. A divergence against your current position is a clear sign to take profits or tighten your Stop Loss.

4. Info Panel (Dashboard)
ADX Metric: If both timeframes (Current and Higher) are green, the probability of a successful trend trade increases significantly.

Trend: Based on the 200 EMA. Memo's Golden Rule: Avoid trading against the higher timeframe trend to stay away from "fakeouts."

## Source Code

````pine
//@version=6
// @author: Memo
// Descripción: Indicador Squeeze Momentum + ADX Memo

indicator(shorttitle="Squeeze Momentum + ADX Memo", 
     title="Squeeze Momentum + ADX Memo", 
     overlay=false, 
     precision=2,
     max_labels_count = 500)

// ==========================================
// --- ENTRADAS (Configuración de Memo) ---
// ==========================================
group_ui      = "Visualización"
show_table    = input.bool(true, "Mostrar Panel Informativo", group=group_ui)
show_dmi      = input.bool(true, "Mostrar Líneas DI+/DI-", group=group_ui)
show_labels   = input.bool(true, "Mostrar Etiquetas Long/Short", group=group_ui)
show_div      = input.bool(true, "Mostrar DiverGencias", group=group_ui)
tf_superior   = input.timeframe("1D", "TF Superior (Análisis)", group=group_ui)
alpha         = input.int(40, "Transparencia del Panel (0-100)", minval=0, maxval=100, group=group_ui)

group_logic   = "Parámetros"
adx_level     = input.int(23, "Nivel Crítico ADX", group=group_logic)
length        = input.int(20, "Periodos Squeeze/Bollinger", group=group_logic)
adx_smoothing = input.int(14, "Suavizado ADX", group=group_logic)
adx_far_sight = input.int(75, "ADX Far Sightness", group=group_logic)
adx_scale_val = input.float(2.0, "ADX Scale", step=0.1, group=group_logic)

// --- FUNCIÓN PARA FORMATEAR TEMPORALIDADES ---
format_tf(tf) =>
    result = tf
    if tf == "1D" or tf == "D"
        result := "1D"
    else if tf == "1W" or tf == "W"
        result := "1S"
    else if tf == "1M" or tf == "M"
        result := "1M"
    else
        tf_int = str.tonumber(tf)
        if not na(tf_int)
            if tf_int >= 60
                result := str.tostring(math.floor(tf_int / 60)) + "H"
            else
                result := str.tostring(tf_int) + "m"
    result

// ==========================================
// --- LÓGICA DE CÁLCULOS (Auditoría: Memo) ---
// ==========================================
basis   = ta.sma(close, length)
dev     = 2.0 * ta.stdev(close, length)
maKC    = ta.ema(close, length)
rangeKC = ta.ema(ta.tr, length)
sqzOn   = (basis - dev > maKC - rangeKC * 1.5) and (basis + dev < maKC + rangeKC * 1.5)

[currDip, currDim, currADX] = ta.dmi(adx_smoothing, adx_smoothing)
currTrend = close > ta.ema(close, 200)

// Petición al TF Superior
[supDip, supDim, supADX, supTrend] = request.security(syminfo.tickerid, tf_superior, [currDip, currDim, currADX, currTrend], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Momentum (Histograma)
val = ta.linreg(close - math.avg(math.avg(ta.highest(high, length), ta.lowest(low, length)), ta.sma(close, length)), length, 0)
val := nz(val)

// --- LÓGICA DE DIVERGENCIAS ---
lbR = 5, lbL = 5 
ph = ta.pivothigh(val, lbL, lbR)
pl = ta.pivotlow(val, lbL, lbR)
bearDiv = not na(ph) and (high[lbR] > ta.valuewhen(not na(ph), high[lbR], 1) and val[lbR] < ta.valuewhen(not na(ph), val[lbR], 1))
bullDiv = not na(pl) and (low[lbR] < ta.valuewhen(not na(pl), low[lbR], 1) and val[lbR] > ta.valuewhen(not na(pl), val[lbR], 1))

// ==========================================
// --- VISUALIZACIÓN ---
// ==========================================
color_area = val >= 0 ? (val >= nz(val[1]) ? #00FFFF : #0000FF) : (val < nz(val[1]) ? #FF0000 : #800000)
plot(val, "Momentum", color=color.new(color_area, 30), style=plot.style_columns, linewidth=2)
plot(0, "Punto Squeeze", color=sqzOn ? color.new(#800000, 0) : color.lime, style=plot.style_circles, linewidth=2)

max_val = ta.highest(math.abs(val), adx_far_sight)
max_val := nz(max_val) == 0 ? 1 : max_val 
scale(src) => (src / 100) * (max_val * adx_scale_val)

plot(show_dmi ? scale(currDip - adx_level) : na, "DI+", color=color.new(color.lime, 50), linewidth=1)
plot(show_dmi ? scale(currDim - adx_level) : na, "DI-", color=color.new(color.red, 50), linewidth=1)
plot(scale(currADX - adx_level), "ADX", color=color.white, linewidth=2)
plot(0, "Nivel Crítico", color=color.new(color.gray, 70), style=plot.style_linebr)

// --- ETIQUETAS RESTAURADAS (Memo Style) ---
adx_trigger = ta.crossover(currADX, 24)
if show_labels and adx_trigger
    l_text  = currDip > currDim ? "LONG" : "SHORT"
    l_color = currDip > currDim ? color.lime : color.red
    l_style = currDip > currDim ? label.style_label_up : label.style_label_down
    // Respetamos la posición vertical relativa al max_val que tenías
    label.new(bar_index, currDip > currDim ? -max_val * 0.4 : max_val * 0.4, l_text, color=l_color, textcolor=currDip > currDim ? color.black : color.white, style=l_style, size=size.small)

if show_div
    if bullDiv
        label.new(bar_index[lbR], val[lbR], "BULL DIV", color=color.new(color.lime, 0), style=label.style_label_up, size=size.tiny, textcolor=color.black)
    if bearDiv
        label.new(bar_index[lbR], val[lbR], "BEAR DIV", color=color.new(color.red, 0), style=label.style_label_down, size=size.tiny, textcolor=color.white)

// ==========================================
// --- PANEL INFORMATIVO (RESTAURADO) ---
// ==========================================
var table panel = table.new(position.top_right, 3, 5, border_width=1, border_color=color.new(color.gray, alpha))

if show_table and barstate.islast
    s_actual = format_tf(timeframe.period)
    s_super  = format_tf(tf_superior)
    
    table.cell(panel, 0, 0, "MÉTRICA", bgcolor=color.new(color.black, alpha), text_color=color.white)
    table.cell(panel, 1, 0, s_actual, bgcolor=color.new(#2a2e39, alpha), text_color=color.white)
    table.cell(panel, 2, 0, s_super, bgcolor=color.new(#2a2e39, alpha), text_color=color.white)
    
    table.cell(panel, 0, 1, "Fuerza ADX", bgcolor=color.new(#1e222d, alpha), text_color=color.white)
    table.cell(panel, 1, 1, str.tostring(math.round(currADX, 1)), bgcolor=color.new(currADX > adx_level ? color.green : color.red, alpha), text_color=color.white)
    table.cell(panel, 2, 1, str.tostring(math.round(supADX, 1)), bgcolor=color.new(supADX > adx_level ? color.green : color.red, alpha), text_color=color.white)

    table.cell(panel, 0, 2, "DI+", bgcolor=color.new(#1e222d, alpha), text_color=color.white)
    table.cell(panel, 1, 2, str.tostring(math.round(currDip, 1)), bgcolor=color.new(currDip > currDim ? color.lime : color.gray, alpha), text_color=color.black)
    table.cell(panel, 2, 2, str.tostring(math.round(supDip, 1)), bgcolor=color.new(supDip > supDim ? color.lime : color.gray, alpha), text_color=color.black)

    table.cell(panel, 0, 3, "DI-", bgcolor=color.new(#1e222d, alpha), text_color=color.white)
    table.cell(panel, 1, 3, str.tostring(math.round(currDim, 1)), bgcolor=color.new(currDim > currDip ? color.red : color.gray, alpha), text_color=color.white)
    table.cell(panel, 2, 3, str.tostring(math.round(supDim, 1)), bgcolor=color.new(supDim > supDip ? color.red : color.gray, alpha), text_color=color.white)

    table.cell(panel, 0, 4, "Tendencia", bgcolor=color.new(#1e222d, alpha), text_color=color.white)
    table.cell(panel, 1, 4, currTrend ? "ALCISTA" : "BAJISTA", bgcolor=color.new(currTrend ? color.blue : color.maroon, alpha), text_color=color.white)
    table.cell(panel, 2, 4, supTrend ? "ALCISTA" : "BAJISTA", bgcolor=color.new(supTrend ? color.blue : color.maroon, alpha), text_color=color.white)
````
