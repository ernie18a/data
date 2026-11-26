# Signal Probability   tgambinox

- url: https://www.tradingview.com/script/rnALKVTQ-Signal-Probability-tgambinox/
- type: indicator
- pine_id: PUB;0310b4a28eac47eaa9742aa59c3ad698
- version: 1.0

## Description

Here's a clean description ready to paste into TradingView when publishing:

Title: Signal Probability • EMA + RSI + MACD + VWAP — tgambinox

Description:
This indicator scores the probability of a successful LONG or SHORT entry in real time by evaluating four technical conditions simultaneously, each worth 25 points for a maximum score of 100%.
The four conditions:

C1 · EMA 9/21 — Trend direction. EMA 9 above EMA 21 confirms bullish momentum; below confirms bearish.
C2 · RSI (14) — Filters overbought/oversold extremes. Optimal zone is 40–60 to avoid chasing extended moves.
C3 · MACD (12,26,9) — Momentum confirmation. A bullish crossover validates LONG entries; bearish crossover validates SHORT.
C4 · VWAP + Volume — Price must be above (LONG) or below (SHORT) the daily VWAP, backed by above-average volume.

Signal levels:

🟢 ≥ 90% — Strong signal, all conditions aligned. Triangle marker on chart.
🟡 ≥ 65% — Moderate signal, 3 of 4 conditions met. Label only.
Below 65% — No signal. Wait for better alignment.

## Source Code

````pine
//@version=6
//=============================================================================
// 🎯 Signal Probability • EMA + RSI + MACD + VWAP/Vol
//-----------------------------------------------------------------------------
// Elaborado por @tgambinox 🇬🇹
//
// 📖 Descripción:
// Este indicador calcula en tiempo real la probabilidad de éxito de una
// entrada LONG o SHORT evaluando simultáneamente cuatro condiciones técnicas:
//
//   C1 · EMA 9 / EMA 21  — Detecta la dirección de tendencia vigente.
//                           Una EMA rápida por encima de la lenta confirma
//                           momentum alcista; por debajo, bajista.
//
//   C2 · RSI (14)         — Filtra zonas de sobrecompra/sobreventa.
//                           Se considera óptimo cuando el RSI se encuentra
//                           entre 40 y 60, evitando entradas en extremos.
//
//   C3 · MACD (12,26,9)   — Confirma el momentum de la señal.
//                           Un cruce alcista de la línea MACD sobre la señal
//                           valida entradas LONG; el cruce inverso, SHORT.
//
//   C4 · VWAP + Volumen   — Valida que el precio opera sobre (LONG) o bajo
//                           (SHORT) el VWAP del día, respaldado por volumen
//                           superior al promedio móvil configurado.
//
// Cada condición aporta hasta 25 puntos al score total (0–100%).
// Solo se muestra UNA etiqueta por señal nueva (no en cada vela).
// Las líneas TP/SL aparecen únicamente en la señal más reciente.
// El panel de estado en la esquina siempre refleja el estado actual.
//
// ⚠️ Este indicador es una herramienta de análisis técnico y no constituye
//    asesoría financiera. Úsalo siempre con gestión de riesgo adecuada.
//=============================================================================
indicator(title = "Signal Probability • EMA+RSI+MACD+VWAP — @tgambinox",
     shorttitle      = "SigProb%",
     overlay         = true,
     max_labels_count = 100,
     max_lines_count  = 10)

// ============================================================
// INPUTS
// ============================================================
grp1 = "═══ EMA ═══"
ema_fast = input.int(9,  "EMA Rápida", minval = 1, group = grp1)
ema_slow = input.int(21, "EMA Lenta",  minval = 1, group = grp1)

grp2 = "═══ RSI ═══"
rsi_len = input.int(14, "RSI Período",             minval = 1, group = grp2)
rsi_hi  = input.int(60, "RSI Límite Alto entrada",             group = grp2)
rsi_lo  = input.int(40, "RSI Límite Bajo entrada",             group = grp2)

grp3 = "═══ MACD ═══"
macd_fast = input.int(12, "Fast",   group = grp3)
macd_slow = input.int(26, "Slow",   group = grp3)
macd_sig  = input.int(9,  "Signal", group = grp3)

grp4 = "═══ Volumen ═══"
vol_ma_len = input.int(20,    "MA Período",    group = grp4)
vol_mult   = input.float(1.2, "Multiplicador", step = 0.1, group = grp4)

grp5 = "═══ Señales ═══"
min_prob   = input.int(65,    "Probabilidad mínima para señal (%)", minval = 50, maxval = 100, group = grp5)
show_tp_sl = input.bool(true, "Mostrar TP / SL en última señal",    group = grp5)
sl_pct     = input.float(1.0, "Stop Loss %",    step = 0.1, group = grp5)
tp_ratio   = input.float(2.0, "TP Ratio (R:R)", step = 0.1, group = grp5)
show_bg    = input.bool(false, "Fondo de color en zonas de señal",  group = grp5)

// ============================================================
// CÁLCULOS
// ============================================================
ema9  = ta.ema(close, ema_fast)
ema21 = ta.ema(close, ema_slow)
rsi   = ta.rsi(close, rsi_len)
[macdLine, signalLine, hist] = ta.macd(close, macd_fast, macd_slow, macd_sig)
vwap_val = ta.vwap(hlc3)
vol_ma   = ta.sma(volume, vol_ma_len)
high_vol = volume > (vol_ma * vol_mult)

// ============================================================
// SCORE LONG
// ============================================================
c1_long = ema9 > ema21
c2_long = rsi >= rsi_lo and rsi <= rsi_hi
c3_long = ta.crossover(macdLine, signalLine) or (macdLine > signalLine and hist > 0)
c4_long = close > vwap_val and high_vol

s1L = c1_long ? 25 : 0
s2L = c2_long ? 25 : (rsi < 70 and rsi > 30 ? 12 : 0)
s3L = ta.crossover(macdLine, signalLine) ? 25 : (macdLine > signalLine ? 15 : 0)
s4L = c4_long ? 25 : (close > vwap_val ? 12 : 0)

prob_long = s1L + s2L + s3L + s4L

// ============================================================
// SCORE SHORT
// ============================================================
c1_short = ema9 < ema21
c2_short = rsi >= rsi_lo and rsi <= rsi_hi
c3_short = ta.crossunder(macdLine, signalLine) or (macdLine < signalLine and hist < 0)
c4_short = close < vwap_val and high_vol

s1S = c1_short ? 25 : 0
s2S = c2_short ? 25 : (rsi > 30 and rsi < 70 ? 12 : 0)
s3S = ta.crossunder(macdLine, signalLine) ? 25 : (macdLine < signalLine ? 15 : 0)
s4S = c4_short ? 25 : (close < vwap_val ? 12 : 0)

prob_short = s1S + s2S + s3S + s4S

// ============================================================
// SEÑALES — solo en cambio de estado (evita repetición)
// ============================================================
signal_long  = prob_long  >= min_prob and prob_long  > prob_short
signal_short = prob_short >= min_prob and prob_short > prob_long

new_long  = signal_long  and not signal_long[1]
new_short = signal_short and not signal_short[1]

// ============================================================
// PLOTS — EMAs y VWAP
// ============================================================
plot(ema9,     "EMA 9",  color = color.new(color.yellow, 0), linewidth = 1)
plot(ema21,    "EMA 21", color = color.new(color.blue,   0), linewidth = 2)
plot(vwap_val, "VWAP",   color = color.new(color.white, 60), linewidth = 1, style = plot.style_circles)

// ============================================================
// FONDO SUTIL (opcional)
// ============================================================
var color bg_col = na
if show_bg
    if signal_long
        bg_col := color.new(color.green, 92)
    else if signal_short
        bg_col := color.new(color.red, 92)
    else
        bg_col := na
else
    bg_col := na
bgcolor(bg_col)

// ============================================================
// ETIQUETAS — solo al inicio de cada nueva señal
// ============================================================
if new_long
    lbl = "▲ LONG  " + str.tostring(prob_long) + "%\n" +
          (c1_long ? "✅" : "❌") + " EMA   " +
          (c2_long ? "✅" : "❌") + " RSI " + str.tostring(math.round(rsi, 1)) + "\n" +
          (c3_long ? "✅" : "❌") + " MACD  " +
          (c4_long ? "✅" : "❌") + " VWAP"
    label.new(bar_index, low * 0.9985,
         text       = lbl,
         color      = color.new(color.green, 15),
         textcolor  = color.white,
         style      = label.style_label_up,
         size       = size.small)

if new_short
    lbl = "▼ SHORT  " + str.tostring(prob_short) + "%\n" +
          (c1_short ? "✅" : "❌") + " EMA   " +
          (c2_short ? "✅" : "❌") + " RSI " + str.tostring(math.round(rsi, 1)) + "\n" +
          (c3_short ? "✅" : "❌") + " MACD  " +
          (c4_short ? "✅" : "❌") + " VWAP"
    label.new(bar_index, high * 1.0015,
         text       = lbl,
         color      = color.new(color.red, 15),
         textcolor  = color.white,
         style      = label.style_label_down,
         size       = size.small)

// ============================================================
// TP / SL — una sola línea persistente, se reemplaza en cada señal
// ============================================================
var line  sl_line = na
var line  tp_line = na
var label sl_lbl  = na
var label tp_lbl  = na

if show_tp_sl and (new_long or new_short)
    if not na(sl_line)
        line.delete(sl_line)
    if not na(tp_line)
        line.delete(tp_line)
    if not na(sl_lbl)
        label.delete(sl_lbl)
    if not na(tp_lbl)
        label.delete(tp_lbl)

    sl_val = new_long ? close * (1.0 - sl_pct / 100.0) : close * (1.0 + sl_pct / 100.0)
    tp_val = new_long ? close * (1.0 + sl_pct * tp_ratio / 100.0) : close * (1.0 - sl_pct * tp_ratio / 100.0)

    sl_line := line.new(bar_index, sl_val, bar_index + 20, sl_val,
         color = color.new(color.red, 20), width = 1,
         style = line.style_dashed, extend = extend.right)
    tp_line := line.new(bar_index, tp_val, bar_index + 20, tp_val,
         color = color.new(color.green, 20), width = 1,
         style = line.style_dashed, extend = extend.right)
    sl_lbl := label.new(bar_index + 2, sl_val,
         "SL  " + str.tostring(math.round(sl_val, 4)),
         color = color.new(color.red, 70), textcolor = color.red,
         style = label.style_label_right, size = size.tiny)
    tp_lbl := label.new(bar_index + 2, tp_val,
         "TP  " + str.tostring(math.round(tp_val, 4)),
         color = color.new(color.green, 70), textcolor = color.green,
         style = label.style_label_right, size = size.tiny)

// ============================================================
// SHAPES — solo señales fuertes (≥90%)
// ============================================================
plotshape(new_long  and prob_long  >= 90, "LONG",  shape.triangleup,   location.belowbar, color.new(color.green, 0), size = size.small)
plotshape(new_short and prob_short >= 90, "SHORT", shape.triangledown, location.abovebar, color.new(color.red,   0), size = size.small)

// ============================================================
// ALERTAS
// ============================================================
alertcondition(new_long  and prob_long  >= 90, "🟢 LONG FUERTE",    "SigProb: LONG ≥90% — todas las condiciones cumplidas")
alertcondition(new_long  and prob_long  >= 65, "🟡 LONG MODERADO",  "SigProb: LONG ≥65% — señal moderada")
alertcondition(new_short and prob_short >= 90, "🔴 SHORT FUERTE",   "SigProb: SHORT ≥90% — todas las condiciones cumplidas")
alertcondition(new_short and prob_short >= 65, "🟠 SHORT MODERADO", "SigProb: SHORT ≥65% — señal moderada")

// ============================================================
// PANEL — estado en tiempo real
// ============================================================
var table panel = table.new(position.top_right, 2, 8,
     bgcolor      = color.new(color.black, 30),
     border_color = color.new(color.gray, 60), border_width = 1,
     frame_color  = color.new(color.gray, 40), frame_width  = 1)

if barstate.islast
    table.cell(panel, 0, 0, "CONDICIÓN",
         text_color = color.new(color.white, 20), text_size = size.small,
         bgcolor    = color.new(color.navy, 40))
    table.cell(panel, 1, 0, "ESTADO",
         text_color = color.new(color.white, 20), text_size = size.small,
         bgcolor    = color.new(color.navy, 40))

    table.cell(panel, 0, 1, "C1  EMA 9/21", text_color = color.silver, text_size = size.small)
    table.cell(panel, 1, 1,
         c1_long ? "▲ LONG" : c1_short ? "▼ SHORT" : "—",
         text_color = c1_long ? color.green : c1_short ? color.red : color.gray,
         text_size  = size.small)

    table.cell(panel, 0, 2, "C2  RSI(" + str.tostring(rsi_len) + ")", text_color = color.silver, text_size = size.small)
    table.cell(panel, 1, 2,
         str.tostring(math.round(rsi, 1)) + (c2_long ? "  ✅" : "  ·"),
         text_color = c2_long ? color.green : color.orange,
         text_size  = size.small)

    table.cell(panel, 0, 3, "C3  MACD", text_color = color.silver, text_size = size.small)
    table.cell(panel, 1, 3,
         c3_long ? "▲ LONG" : c3_short ? "▼ SHORT" : "—",
         text_color = c3_long ? color.green : c3_short ? color.red : color.gray,
         text_size  = size.small)

    table.cell(panel, 0, 4, "C4  VWAP+Vol", text_color = color.silver, text_size = size.small)
    table.cell(panel, 1, 4,
         c4_long ? "▲ LONG" : c4_short ? "▼ SHORT" : "—",
         text_color = c4_long ? color.green : c4_short ? color.red : color.gray,
         text_size  = size.small)

    table.cell(panel, 0, 5, "──────────────", text_color = color.new(color.gray, 50), text_size = size.tiny)
    table.cell(panel, 1, 5, "──────────────", text_color = color.new(color.gray, 50), text_size = size.tiny)

    long_col = prob_long  >= 90 ? color.green  : prob_long  >= 65 ? color.yellow : color.gray
    short_col = prob_short >= 90 ? color.red   : prob_short >= 65 ? color.orange : color.gray

    table.cell(panel, 0, 6, "PROB LONG",
         text_color = color.silver, text_size = size.small)
    table.cell(panel, 1, 6, str.tostring(prob_long) + "%",
         text_color = long_col, text_size = size.normal,
         bgcolor    = color.new(prob_long >= 65 ? color.green : color.gray, 85))

    table.cell(panel, 0, 7, "PROB SHORT",
         text_color = color.silver, text_size = size.small)
    table.cell(panel, 1, 7, str.tostring(prob_short) + "%",
         text_color = short_col, text_size = size.normal,
         bgcolor    = color.new(prob_short >= 65 ? color.red : color.gray, 85))

//=============================================================================
// Fin del script · @tgambinox 🇬🇹
//=============================================================================
````
