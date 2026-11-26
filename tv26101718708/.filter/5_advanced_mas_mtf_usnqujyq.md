# 5 Advanced MAs MTF

- url: https://www.tradingview.com/script/usnqUjYQ/
- type: indicator
- pine_id: PUB;29634a82fedd41ddbb03dbb1a13b7c8b
- version: 3.0

## Description

🔵 OVERVIEW

5 Advanced MAs MTF is a professional moving averages indicator designed for traders who need to see multiple trend layers on a single chart simultaneously, each one with its own independent configuration and — above all — its own timeframe.

Unlike typical "ribbon" or "multi-MA" indicators on the market, which display several averages all computed on the active chart's timeframe, this indicator allows each of the 5 averages to have its own timeframe. You can have your EMA 8 on the 15-minute chart, your EMA 20 on the 1-hour, your EMA 50 on the 4-hour, and your SMA 200 on the daily, all plotted on the same 15-minute chart. That turns the indicator into a complete multi-timeframe control panel without needing to open four separate charts or saturate your installed indicators list.


🔶 KEY FEATURES

• 5 fully independent moving averages — each one configured separately and enabled or disabled individually.

• True multi-timeframe per MA — the core differentiator. Each MA can read its value from a higher, lower, or equal timeframe relative to the active chart. Leave it empty to use the chart's current timeframe.

• 9 moving average types — SMA, EMA, WMA, RMA, HMA, VWMA, TEMA, KAMA, and JMA. The last three (TEMA, KAMA, JMA) are implemented with their original formulas, no shortcuts. JMA uses Mark Jurik's standard defaults (Phase = 50, Power = 2).

• Configurable source per MA — Close, Open, High, Low, hl2, hlc3, ohlc4.

• Full visual styling per MA — color, width (1 to 10), and line style (solid, dashed, or dotted).

• Smart labels — each MA can show its label directly on the line, with configurable content (type, length, timeframe, or any combination of the three). Adjustable horizontal bar offset and text size.

• Interactive summary table — placed at any of the 9 chart anchors, displaying color column, type, length, timeframe, and price distance from each MA (in percentage and absolute value). Toggle to include or exclude hidden MAs.

• 22-alert system — 10 for Price↔MA crosses (bullish and bearish for each MA), 10 for MA↔MA crosses across 5 configurable slots (you pick which MA pairs to monitor), and 2 wildcard "any cross detected" alerts. All compatible with webhooks and automation.

• Works on any market and any timeframe — equities, futures, crypto, forex, commodities. From tick charts to monthly charts.


🔹 USE CASES BY TRADER STYLE

▪️ Day trader / scalper
Configure the first 3 MAs as short EMAs (8, 20, 50) on the chart's timeframe (5m or 15m) and leave MAs 4 and 5 as SMA 200 and VWMA 100 but reading them from a higher timeframe (1H, 4H, or daily). Result: you see your fast entry signals and the higher-timeframe bias at the same time without switching charts.

▪️ Swing trader
Recommended setup: EMA 20 and EMA 50 on the active chart (1H or 4H) + SMA 200 read from daily + VWMA 100 read from weekly. This lets you watch pullbacks against the EMA 20 on your operative timeframe with immediate confirmation that the higher-timeframe bias is aligned, plus the weekly VWMA as a volume-weighted "fair price" reference.

▪️ Position trader / long-term
Enable all 5 MAs on daily or weekly to build a complete structural map of the asset. The default configuration (EMA 8, EMA 20, EMA 50, SMA 200, and VWMA 100, all on daily) covers everything from fast momentum to the institutional level, combining pure-price references (SMA 200) with volume-weighted references (VWMA 100). The summary table shows the exact distance of price from each one.

▪️ Systematic crossover trader
The MA↔MA alert slots let you configure up to 5 specific crossovers simultaneously. Classic Golden Cross / Death Cross setup: Slot 1 with MA 3 (EMA 50) crossing MA 4 (SMA 200) on daily, with an automatic alert sent to your bot's webhook or notification system.

▪️ Multi-timeframe confluence trader
The most differentiating use case. Assign each MA to a different timeframe: MA 1 on 5m, MA 2 on 15m, MA 3 on 1H, MA 4 on 4H, MA 5 on daily or weekly. The summary table shows you in real time the distance of current price from the key level of each of those timeframes. When several MAs from different timeframes converge on the same price zone, that zone becomes a high-density structural level — one of the most-used concepts among institutional traders.


⚙️ INPUTS & CUSTOMIZATION

The entire indicator is 100% configurable from the Inputs panel. Each MA has its own expandable group with 14 controls. The summary table is also fully customizable (position, text size, background/border/text colors). The JMA global parameters (Phase and Power) live in their own section so advanced users can adjust them without cluttering the individual groups.

By default, all 5 MAs are enabled with a configuration tailored for daily and swing use: EMA 8 (blue, 1D), EMA 20 (red, 1D), EMA 50 (yellow, 1D), SMA 200 (green dashed, 1D), and VWMA 100 (pink dotted, 1D). The user can modify any of the parameters or reassign the MAs to other timeframes at any moment.


🔔 ALERTS

The indicator ships with 22 precompiled alerts ready to use:
• 5 alerts "Price crosses above MA N"
• 5 alerts "Price crosses below MA N"
• 10 alerts across 5 configurable slots for MA↔MA crossovers (bullish and bearish per slot)
• 2 wildcard alerts "any cross detected"

All messages include the {{ticker}} and {{close}} placeholders so they are directly parseable by webhooks, bots, and automation systems.


❓ FAQ

Does the indicator repaint?
No. The moving averages are computed on confirmed historical data. Cross alerts fire on the bar of the cross and values are not modified retroactively. To avoid signals that appear and disappear intra-bar, set the alerts to "Once per bar close".

Does it work on any timeframe?
Yes. From tick charts to monthly. In addition, each MA can have its own higher, lower, or equal timeframe relative to the active chart. The default timeframe is the current chart's timeframe.

Why 9 MA types?
Because each type behaves differently. SMA is the pure average; EMA weights recent bars more; HMA virtually eliminates lag; KAMA adapts to volatility; JMA is the smoothest while staying responsive; VWMA weights by volume. Having all of them available lets you use the right tool for each analysis without installing several separate indicators.

What are the 5 MA↔MA alert slots for?
They let you configure specific crossovers between any pair of MAs without having to create all possible combinations. In each slot you pick the fast MA and slow MA from dropdowns and receive alerts for the bullish and bearish crossovers of that pair. Example: Slot 1 = MA 3 crosses MA 4 (classic Golden Cross / Death Cross when MA 3 = EMA 50 and MA 4 = SMA 200).

What is the best MA combination?
There is no single "best" — it depends on the trading style and the asset. The Use Cases section above includes recommended configurations for the 5 most common profiles.

Is it compatible with webhooks and automation?
Yes. The 22 alerts use {{ticker}} and {{close}} placeholders in their messages, making them directly compatible with TradingView Webhooks, copy-trading platforms, Telegram/Discord bots, and any system that parses JSON.

Is it free to use?
Yes. Open-source indicator under the Mozilla Public License 2.0. You can review the full code, use it freely on TradingView, and create derivative copies while respecting the license terms.


⚠️ DISCLAIMER

This indicator is a technical analysis tool provided solely for educational and informational purposes. It does not constitute financial advice, an investment recommendation, or an invitation to trade any instrument. Moving averages are reactive (not predictive) indicators: they are based on historical data and, by their nature, can produce delayed signals in markets with sharp trend changes. In ranging or low-volatility market contexts, crossovers can be frequent and not particularly informative. Every trading decision is the sole responsibility of the trader. Past performance does not guarantee future results.


© 2026 Lic. Farias Foresi, Leandro M. — License: Mozilla Public License 2.0

## Source Code

````pine
//@version=6
// =====================================================================================================================
// Adv. MAs MTF (Eng/Spa/Port)(LFF) — 5 ADVANCED MULTI-TIMEFRAME MOVING AVERAGES — by Lic. Farias Foresi, Leandro M.
// =====================================================================================================================
// © 2026 Lic. Farias Foresi, Leandro M.
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// =====================================================================================================================
// VERSIÓN: BASIC (gratuita / código abierto) — ACTUALIZACIÓN v2.
//
// ─── REGISTRO DE CAMBIOS RESPECTO AL SCRIPT ORIGINAL ("5 Advanced MAs MTF") ──────────────────────────────────────────
//   1) Título del código cambiado a "Adv. MAs MTF (Eng/Spa/Port)(LFF)" y shorttitle a "MAs MTF (LFF)".
//   2) NUEVO MÓDULO IDIOMA (trilingüe EN/ES/PT).
//   3) Panel de Control reescrito en 3 idiomas (inglés / español / portugués), en labels y tooltips.
//   4) Encabezados de la tabla resumen ahora se traducen dinámicamente según el idioma elegido (helper tr()).
//   5) Las 22 alarmas conservan sus condiciones y toggles; sus mensajes ahora son trilingües en un solo texto (Camino A).
//   Nota técnica: el idioma del Panel de Control no puede alternarse con un botón (Pine fija esos textos al compilar);
//   por eso el panel se escribe en los 3 idiomas. El botón de idioma cambia lo que se DIBUJA en el gráfico (tabla).
//   Las etiquetas de cada MA muestran códigos técnicos universales (ej.: "EMA(8) 1D"), iguales en todos los idiomas.
//
// ─── REGISTRO DE CAMBIOS DE LA ACTUALIZACIÓN v2 ─────────────────────────────────────────────────────────────────────
//   A1) Tabla resumen: dos columnas nuevas — Ritmo (pendiente de la MA en % por barra) y Últ. cruce (barras desde el
//       último cruce del precio con esa MA). Ambas con toggle propio.
//   A2) Tabla resumen: fila nueva de ALINEACIÓN ("abanico") — indica si las 5 MAs están apiladas en orden alcista,
//       bajista o mixto, y cuántas tiene el precio por encima. Con toggle propio.
//   A3) Relleno configurable entre dos MAs elegibles (dropdowns), con color según cuál está arriba.
//   A4) Cono de proyección: proyecta cada MA hacia adelante con una banda que se ensancha (± desvíos × √tiempo).
//       Escenario de "si todo sigue igual", no una predicción. Apagado por defecto.
//   B1) Probabilidad de cruce (tiempo de primer paso, Browniano con deriva): para los 10 pares (5 Precio↔MA y los
//       5 slots MA↔MA) estima la probabilidad de que la brecha llegue a cero dentro de N barras, más la barra y la
//       zona de precios aproximadas del cruce. Sin llamadas request.* adicionales.
//       Lleva TRES correcciones sobre la fórmula de manual, todas medidas por Monte Carlo (400.000 barras, con
//       agrupamiento de volatilidad). Cada una está documentada donde se aplica:
//         · barrera corrida β·σ (Broadie-Glasserman-Kou): la fórmula es de tiempo continuo pero el cruce se declara
//           entre cierres. Sesgo medio con parámetros conocidos: 10,1 pp → 0,5 pp.
//         · σ medido a la escala del horizonte: los cambios de una brecha entre medias tienen autocorrelación +0,96,
//           así que escalar σ de una barra por √N subestima la dispersión real unas 3 veces.
//         · deriva encogida por su relación señal-ruido: es información real en los pares MA↔MA y casi puro ruido
//           en los pares precio↔MA; el encogimiento distingue los dos casos solo.
//       Efecto conjunto sobre el error de calibración en la zona que la tabla realmente muestra (probabilidad ≥ el
//       umbral): 29,1 → 15,0 pp en los pares MA↔MA y 20,4 → 4,4 pp en los pares precio↔MA. El bucket "80-100%"
//       pasó de anunciar 98% y cumplirse el 68% de las veces, a anunciar 91% y cumplirse el 81%.
//   B2) Banda anti-ruido (× ATR) opcional sobre TODOS los cruces: el cruce se declara solo cuando la separación supera
//       el temblor típico del mercado (histéresis). Apagada por defecto → comportamiento idéntico al de la v1.
//   GC) Golden Cross / Death Cross: señal visual en el gráfico (etiqueta + línea opcional) cuando la MA rápida elegida
//       cruza a la MA lenta elegida. Por defecto MA 3 ↔ MA 5 (EMA 50 vs SMA 200 = el cruce clásico). +2 alarmas.
//
//   D)  NUEVOS VALORES DE FÁBRICA de las 5 medias, para que el juego por defecto sea el set clásico de tendencia y
//       el par 50/200 quede armado de entrada:
//         MA 1 = EMA 8 azul · MA 2 = EMA 21 rojo · MA 3 = EMA 50 amarillo · MA 4 = SMA 100 verde · MA 5 = SMA 200 violeta
//       Todas continuas y de grosor 1, salvo la SMA 200 que va en grosor 2 por ser la referencia de fondo.
//       Con esto, el Cruce Dorado / de la Muerte por defecto es MA 3 ↔ MA 5 (EMA 50 vs SMA 200) y el relleno apunta
//       al mismo par, así que sombreado y marcador cuentan la misma historia.
//       Cambiar un valor por defecto NO altera los gráficos que ya tienen el indicador puesto: TradingView guarda la
//       configuración de cada gráfico al agregarlo. Los nuevos defaults los ven quienes lo agreguen desde ahora y
//       quienes usen "Restablecer ajustes".
//
//   COMPATIBILIDAD: los 98 inputs de la v1 conservan su orden y posición exactos, y las 22 alarmas conservan su orden
//   y sus títulos. Todo lo nuevo se AGREGA después. Así, quien ya tenga el indicador en un gráfico no pierde su
//   configuración guardada ni sus alertas activas al actualizarse.
// =====================================================================================================================
// FEATURES:
//   • 5 independent MAs, each fully configurable. | 5 MAs independientes, totalmente configurables. | 5 MMs independentes.
//   • 9 MA types: SMA, EMA, WMA, RMA, HMA, VWMA, TEMA, KAMA, JMA.
//   • Multi-timeframe per MA (empty = chart timeframe). | MTF por MA (vacío = TF del gráfico). | MTF por MM (vazio = TF).
//   • Configurable source: Close, Open, High, Low, hl2, hlc3, ohlc4 (default Close).
//   • Color, width and line style (Solid / Dashed / Dotted) per MA.
//   • Label per MA (toggle, content, offset, size). | Etiqueta por MA. | Rótulo por MM.
//   • Summary table: 9 anchors, sizes, colors, hidden-MA toggle, distance %/$, slope, bars since last cross, fan row.
//   • Configurable fill between any two MAs. | Relleno entre dos MAs. | Preenchimento entre duas MMs.
//   • MA projection cone (uncertainty fan). | Cono de proyección. | Cone de projeção.
//   • Cross probability (first-passage time) + estimated bar and price zone of the cross.
//   • Golden Cross / Death Cross markers on chart. | Cruce Dorado / Cruce de la Muerte. | Cruz Dourada / da Morte.
//   • Optional ATR noise band on every cross (anti-whipsaw). | Banda anti-ruido. | Banda anti-ruído.
//   • JMA global parameters: Phase = 50, Power = 2 (Mark Jurik's most reproduced standard defaults).
//   • 24 alerts: 10 Price↔MA, 10 MA↔MA (5 slots), 2 wildcard, 2 Golden/Death. | 24 alarmas. | 24 alertas.
// =====================================================================================================================

indicator("Adv. MAs MTF (Eng/Spa/Port)(LFF)", shorttitle="MAs MTF (LFF)", overlay=true,
     max_labels_count=500, max_lines_count=500, max_polylines_count=100)


// =====================================================================================================================
// SECCIÓN 0 — MÓDULO IDIOMA (trilingüe)  ·  [MÓDULO INDEPENDIENTE Y REMOVIBLE — ver rule 19]
// ---------------------------------------------------------------------------------------------------------------------
// Para quitar el trilingüe dinámico: eliminar este bloque y reemplazar cada llamada tr(a,b,c) por su primer argumento.
// =====================================================================================================================

grp_lang = "🌐 Language / Idioma / Idioma"
i_lang = input.string("English",
     "Language / Idioma / Idioma",
     options=["English","Español","Português"],
     tooltip="Sets the language of the ON-CHART TEXT (summary table headers). / Define el idioma del TEXTO EN EL GRÁFICO (encabezados de la tabla). / Define o idioma do TEXTO NO GRÁFICO (cabeçalhos da tabela). \n\nNote: the settings panel is trilingual by design; MA labels use universal technical codes (e.g. EMA(8) 1D); alert messages are always trilingual.",
     group=grp_lang)

// Router de traducción: devuelve el string del idioma activo. Se usa SOLO para texto dinámico en el gráfico.
tr(simple string en, simple string es, simple string pt) =>
    i_lang == "Español"    ? es :
     i_lang == "Português" ? pt :
     en


// =====================================================================================================================
// SECCIÓN 1 — GLOBAL INPUTS (JMA)
// =====================================================================================================================

grp_jma = "🧮 JMA global parameters / Parámetros globales JMA / Parâmetros globais JMA"
jma_phase = input.int(50,
     "JMA: Phase / Fase / Fase (-100..100)",
     minval=-100, maxval=100,
     tooltip="Default = 50 (Mark Jurik's most reproduced standard). Phase=0 more lag; Phase>0 less lag with some overshoot. / Default = 50 (config. estándar más reproducida de Mark Jurik). Fase=0 más retardo; Fase>0 menos retardo con algo de overshoot. / Padrão = 50 (config. padrão mais reproduzida de Mark Jurik). Fase=0 mais atraso; Fase>0 menos atraso com algum overshoot.",
     group=grp_jma)
jma_power = input.int(2,
     "JMA: Power / Potencia / Potência (1..6)",
     minval=1, maxval=6,
     tooltip="Default = 2. Higher = smoother with more lag. / Default = 2. Mayor = más suave con más retardo. / Padrão = 2. Maior = mais suave com mais atraso.",
     group=grp_jma)


// =====================================================================================================================
// SECCIÓN 2 — INPUTS PARA CADA MA (×5) — 14 controles por MA
// =====================================================================================================================

// ─── MA 1 ────────────────────────────────────────────────────────────────────────────────────────────────────────
grp_ma1 = "📈 MA 1"
ma1_show       = input.bool(true,        "MA 1: Show on chart / Mostrar en gráfico / Mostrar no gráfico",                                                              group=grp_ma1)
ma1_tf         = input.timeframe("D",    "MA 1: Timeframe (empty=chart) / Temporalidad (vacío=gráfico) / Tempo gráfico (vazio=gráfico)",                              group=grp_ma1)
ma1_type       = input.string("EMA",     "MA 1: Type / Tipo / Tipo", options=["SMA","EMA","WMA","RMA","HMA","VWMA","TEMA","KAMA","JMA"],                              group=grp_ma1)
ma1_len        = input.int(8,            "MA 1: Length / Longitud / Comprimento", minval=1,                                                                            group=grp_ma1)
ma1_src        = input.string("Close",   "MA 1: Source / Fuente / Fonte", options=["Close","Open","High","Low","hl2","hlc3","ohlc4"],                                 group=grp_ma1)
ma1_col        = input.color(color.blue, "MA 1: Line color / Color de línea / Cor da linha",                                                                           group=grp_ma1)
ma1_width      = input.int(1,            "MA 1: Line width / Grosor de línea / Espessura da linha", minval=1, maxval=10,                                               group=grp_ma1)
ma1_style      = input.string("Solid",   "MA 1: Line style / Estilo de línea / Estilo da linha", options=["Solid","Dashed","Dotted"],                                 group=grp_ma1)
ma1_lbl_show   = input.bool(true,        "MA 1: Show label / Mostrar etiqueta / Mostrar rótulo",                                                                       group=grp_ma1)
ma1_lbl_tipo   = input.bool(true,        "MA 1: Label→Type / Etiqueta→Tipo / Rótulo→Tipo",                                                                             group=grp_ma1)
ma1_lbl_long   = input.bool(true,        "MA 1: Label→Length / Etiqueta→Longitud / Rótulo→Comprimento",                                                                group=grp_ma1)
ma1_lbl_tf     = input.bool(true,        "MA 1: Label→Timeframe / Etiqueta→Temporalidad / Rótulo→Tempo",                                                               group=grp_ma1)
ma1_lbl_offset = input.int(3,            "MA 1: Label offset bars (−left/+right) / Offset barras (−izq/+der) / Deslocamento barras (−esq/+dir)", minval=-500, maxval=500, group=grp_ma1)
ma1_lbl_size   = input.string("Normal",  "MA 1: Label size / Tamaño etiqueta / Tamanho do rótulo", options=["Tiny","Small","Normal","Large","Huge"],                  group=grp_ma1)

// ─── MA 2 ────────────────────────────────────────────────────────────────────────────────────────────────────────
grp_ma2 = "📈 MA 2"
ma2_show       = input.bool(true,        "MA 2: Show on chart / Mostrar en gráfico / Mostrar no gráfico",                                                              group=grp_ma2)
ma2_tf         = input.timeframe("D",    "MA 2: Timeframe (empty=chart) / Temporalidad (vacío=gráfico) / Tempo gráfico (vazio=gráfico)",                              group=grp_ma2)
ma2_type       = input.string("EMA",     "MA 2: Type / Tipo / Tipo", options=["SMA","EMA","WMA","RMA","HMA","VWMA","TEMA","KAMA","JMA"],                              group=grp_ma2)
ma2_len        = input.int(21,           "MA 2: Length / Longitud / Comprimento", minval=1,                                                                            group=grp_ma2)
ma2_src        = input.string("Close",   "MA 2: Source / Fuente / Fonte", options=["Close","Open","High","Low","hl2","hlc3","ohlc4"],                                 group=grp_ma2)
ma2_col        = input.color(color.red,  "MA 2: Line color / Color de línea / Cor da linha",                                                                           group=grp_ma2)
ma2_width      = input.int(1,            "MA 2: Line width / Grosor de línea / Espessura da linha", minval=1, maxval=10,                                               group=grp_ma2)
ma2_style      = input.string("Solid",   "MA 2: Line style / Estilo de línea / Estilo da linha", options=["Solid","Dashed","Dotted"],                                 group=grp_ma2)
ma2_lbl_show   = input.bool(true,        "MA 2: Show label / Mostrar etiqueta / Mostrar rótulo",                                                                       group=grp_ma2)
ma2_lbl_tipo   = input.bool(true,        "MA 2: Label→Type / Etiqueta→Tipo / Rótulo→Tipo",                                                                             group=grp_ma2)
ma2_lbl_long   = input.bool(true,        "MA 2: Label→Length / Etiqueta→Longitud / Rótulo→Comprimento",                                                                group=grp_ma2)
ma2_lbl_tf     = input.bool(true,        "MA 2: Label→Timeframe / Etiqueta→Temporalidad / Rótulo→Tempo",                                                               group=grp_ma2)
ma2_lbl_offset = input.int(3,            "MA 2: Label offset bars (−left/+right) / Offset barras (−izq/+der) / Deslocamento barras (−esq/+dir)", minval=-500, maxval=500, group=grp_ma2)
ma2_lbl_size   = input.string("Normal",  "MA 2: Label size / Tamaño etiqueta / Tamanho do rótulo", options=["Tiny","Small","Normal","Large","Huge"],                  group=grp_ma2)

// ─── MA 3 ────────────────────────────────────────────────────────────────────────────────────────────────────────
grp_ma3 = "📈 MA 3"
ma3_show       = input.bool(true,          "MA 3: Show on chart / Mostrar en gráfico / Mostrar no gráfico",                                                            group=grp_ma3)
ma3_tf         = input.timeframe("D",      "MA 3: Timeframe (empty=chart) / Temporalidad (vacío=gráfico) / Tempo gráfico (vazio=gráfico)",                            group=grp_ma3)
ma3_type       = input.string("EMA",       "MA 3: Type / Tipo / Tipo", options=["SMA","EMA","WMA","RMA","HMA","VWMA","TEMA","KAMA","JMA"],                            group=grp_ma3)
ma3_len        = input.int(50,             "MA 3: Length / Longitud / Comprimento", minval=1,                                                                          group=grp_ma3)
ma3_src        = input.string("Close",     "MA 3: Source / Fuente / Fonte", options=["Close","Open","High","Low","hl2","hlc3","ohlc4"],                               group=grp_ma3)
ma3_col        = input.color(color.yellow, "MA 3: Line color / Color de línea / Cor da linha",                                                                         group=grp_ma3)
ma3_width      = input.int(1,              "MA 3: Line width / Grosor de línea / Espessura da linha", minval=1, maxval=10,                                             group=grp_ma3)
ma3_style      = input.string("Solid",     "MA 3: Line style / Estilo de línea / Estilo da linha", options=["Solid","Dashed","Dotted"],                               group=grp_ma3)
ma3_lbl_show   = input.bool(true,          "MA 3: Show label / Mostrar etiqueta / Mostrar rótulo",                                                                     group=grp_ma3)
ma3_lbl_tipo   = input.bool(true,          "MA 3: Label→Type / Etiqueta→Tipo / Rótulo→Tipo",                                                                           group=grp_ma3)
ma3_lbl_long   = input.bool(true,          "MA 3: Label→Length / Etiqueta→Longitud / Rótulo→Comprimento",                                                              group=grp_ma3)
ma3_lbl_tf     = input.bool(true,          "MA 3: Label→Timeframe / Etiqueta→Temporalidad / Rótulo→Tempo",                                                             group=grp_ma3)
ma3_lbl_offset = input.int(3,              "MA 3: Label offset bars (−left/+right) / Offset barras (−izq/+der) / Deslocamento barras (−esq/+dir)", minval=-500, maxval=500, group=grp_ma3)
ma3_lbl_size   = input.string("Normal",    "MA 3: Label size / Tamaño etiqueta / Tamanho do rótulo", options=["Tiny","Small","Normal","Large","Huge"],                group=grp_ma3)

// ─── MA 4 ────────────────────────────────────────────────────────────────────────────────────────────────────────
grp_ma4 = "📈 MA 4"
ma4_show       = input.bool(true,         "MA 4: Show on chart / Mostrar en gráfico / Mostrar no gráfico",                                                             group=grp_ma4)
ma4_tf         = input.timeframe("D",     "MA 4: Timeframe (empty=chart) / Temporalidad (vacío=gráfico) / Tempo gráfico (vazio=gráfico)",                             group=grp_ma4)
ma4_type       = input.string("SMA",      "MA 4: Type / Tipo / Tipo", options=["SMA","EMA","WMA","RMA","HMA","VWMA","TEMA","KAMA","JMA"],                             group=grp_ma4)
ma4_len        = input.int(100,           "MA 4: Length / Longitud / Comprimento", minval=1,                                                                           group=grp_ma4)
ma4_src        = input.string("Close",    "MA 4: Source / Fuente / Fonte", options=["Close","Open","High","Low","hl2","hlc3","ohlc4"],                                group=grp_ma4)
ma4_col        = input.color(color.green, "MA 4: Line color / Color de línea / Cor da linha",                                                                          group=grp_ma4)
ma4_width      = input.int(1,             "MA 4: Line width / Grosor de línea / Espessura da linha", minval=1, maxval=10,                                              group=grp_ma4)
ma4_style      = input.string("Solid",    "MA 4: Line style / Estilo de línea / Estilo da linha", options=["Solid","Dashed","Dotted"],                                group=grp_ma4)
ma4_lbl_show   = input.bool(true,         "MA 4: Show label / Mostrar etiqueta / Mostrar rótulo",                                                                      group=grp_ma4)
ma4_lbl_tipo   = input.bool(true,         "MA 4: Label→Type / Etiqueta→Tipo / Rótulo→Tipo",                                                                            group=grp_ma4)
ma4_lbl_long   = input.bool(true,         "MA 4: Label→Length / Etiqueta→Longitud / Rótulo→Comprimento",                                                               group=grp_ma4)
ma4_lbl_tf     = input.bool(true,         "MA 4: Label→Timeframe / Etiqueta→Temporalidad / Rótulo→Tempo",                                                              group=grp_ma4)
ma4_lbl_offset = input.int(3,             "MA 4: Label offset bars (−left/+right) / Offset barras (−izq/+der) / Deslocamento barras (−esq/+dir)", minval=-500, maxval=500, group=grp_ma4)
ma4_lbl_size   = input.string("Normal",   "MA 4: Label size / Tamaño etiqueta / Tamanho do rótulo", options=["Tiny","Small","Normal","Large","Huge"],                 group=grp_ma4)

// ─── MA 5 ────────────────────────────────────────────────────────────────────────────────────────────────────────
grp_ma5 = "📈 MA 5"
ma5_show       = input.bool(true,           "MA 5: Show on chart / Mostrar en gráfico / Mostrar no gráfico",                                                           group=grp_ma5)
ma5_tf         = input.timeframe("D",       "MA 5: Timeframe (empty=chart) / Temporalidad (vacío=gráfico) / Tempo gráfico (vazio=gráfico)",                           group=grp_ma5)
ma5_type       = input.string("SMA",        "MA 5: Type / Tipo / Tipo", options=["SMA","EMA","WMA","RMA","HMA","VWMA","TEMA","KAMA","JMA"],                           group=grp_ma5)
ma5_len        = input.int(200,             "MA 5: Length / Longitud / Comprimento", minval=1,                                                                         group=grp_ma5)
ma5_src        = input.string("Close",      "MA 5: Source / Fuente / Fonte", options=["Close","Open","High","Low","hl2","hlc3","ohlc4"],                              group=grp_ma5)
ma5_col        = input.color(color.purple,  "MA 5: Line color / Color de línea / Cor da linha",                                                                        group=grp_ma5)
ma5_width      = input.int(2,               "MA 5: Line width / Grosor de línea / Espessura da linha", minval=1, maxval=10,                                            group=grp_ma5)
ma5_style      = input.string("Solid",      "MA 5: Line style / Estilo de línea / Estilo da linha", options=["Solid","Dashed","Dotted"],                              group=grp_ma5)
ma5_lbl_show   = input.bool(true,           "MA 5: Show label / Mostrar etiqueta / Mostrar rótulo",                                                                    group=grp_ma5)
ma5_lbl_tipo   = input.bool(true,           "MA 5: Label→Type / Etiqueta→Tipo / Rótulo→Tipo",                                                                          group=grp_ma5)
ma5_lbl_long   = input.bool(true,           "MA 5: Label→Length / Etiqueta→Longitud / Rótulo→Comprimento",                                                             group=grp_ma5)
ma5_lbl_tf     = input.bool(true,           "MA 5: Label→Timeframe / Etiqueta→Temporalidad / Rótulo→Tempo",                                                            group=grp_ma5)
ma5_lbl_offset = input.int(3,               "MA 5: Label offset bars (−left/+right) / Offset barras (−izq/+der) / Deslocamento barras (−esq/+dir)", minval=-500, maxval=500, group=grp_ma5)
ma5_lbl_size   = input.string("Normal",     "MA 5: Label size / Tamaño etiqueta / Tamanho do rótulo", options=["Tiny","Small","Normal","Large","Huge"],               group=grp_ma5)


// =====================================================================================================================
// SECCIÓN 3 — INPUTS DE LA TABLA RESUMEN
// =====================================================================================================================

grp_tbl = "📋 Summary table / Tabla resumen / Tabela resumo"
tbl_show           = input.bool(true,                        "Table: Show on chart / Tabla: Mostrar / Tabela: Mostrar",                                               group=grp_tbl)
tbl_include_hidden = input.bool(false,                       "Table: Include hidden MAs / Incluir MAs ocultas / Incluir MMs ocultas",                                 group=grp_tbl)
tbl_show_color     = input.bool(true,                        "Table: Show color column / Mostrar columna de color / Mostrar coluna de cor",                          group=grp_tbl)
tbl_position       = input.string("Top right",               "Table: Position / Posición / Posição",
                                  options=["Top left","Top center","Top right",
                                           "Middle left","Middle center","Middle right",
                                           "Bottom left","Bottom center","Bottom right"],                                                                             group=grp_tbl)
tbl_size           = input.string("Normal",                  "Table: Text size / Tamaño de texto / Tamanho do texto", options=["Tiny","Small","Normal","Large","Huge"], group=grp_tbl)
tbl_bg_col         = input.color(color.new(color.black, 20), "Table: Background / Fondo / Fundo",                                                                     group=grp_tbl)
tbl_border_col     = input.color(color.new(color.gray, 30),  "Table: Border / Borde / Borda",                                                                        group=grp_tbl)
tbl_header_bg      = input.color(color.new(color.gray, 50),  "Table: Header background / Fondo encabezado / Fundo do cabeçalho",                                      group=grp_tbl)
tbl_header_text    = input.color(color.white,                "Table: Header text / Texto encabezado / Texto do cabeçalho",                                           group=grp_tbl)
tbl_row_text       = input.color(color.white,                "Table: Row text / Texto de filas / Texto das linhas",                                                  group=grp_tbl)


// =====================================================================================================================
// SECCIÓN 4 — FUNCIONES AUXILIARES
// =====================================================================================================================

// ─── Cálculos especiales (TEMA, KAMA, JMA) ─────────────────────────────────────────────────────────────────────────
get_tema(src, simple int len) =>
    ema1 = ta.ema(src, len)
    ema2 = ta.ema(ema1, len)
    ema3 = ta.ema(ema2, len)
    3.0 * ema1 - 3.0 * ema2 + ema3

get_kama(src, simple int len) =>
    float fastAlpha = 2.0 / (2.0 + 1.0)
    float slowAlpha = 2.0 / (30.0 + 1.0)
    float change_    = math.abs(src - src[len])
    float volatility = math.sum(math.abs(src - src[1]), len)
    float er = volatility != 0 ? change_ / volatility : 0.0
    float sc = math.pow(er * (fastAlpha - slowAlpha) + slowAlpha, 2)
    var float kama = na
    kama := na(kama[1]) ? src : kama[1] + sc * (src - kama[1])
    kama

get_jma(src, simple int len, simple int phase, simple int power) =>
    float phaseRatio = phase < -100 ? 0.5 : phase > 100 ? 2.5 : phase / 100.0 + 1.5
    float beta  = 0.45 * (len - 1) / (0.45 * (len - 1) + 2)
    float alpha = math.pow(beta, power)
    var float e0 = 0.0
    var float e1 = 0.0
    var float e2 = 0.0
    var float jma = 0.0
    e0  := (1 - alpha) * src + alpha * nz(e0[1])
    e1  := (src - e0) * (1 - beta) + beta * nz(e1[1])
    e2  := (e0 + phaseRatio * e1 - nz(jma[1])) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(e2[1])
    jma := nz(jma[1]) + e2
    jma

// ─── Despachador unificado: selecciona la fórmula según el tipo ──
get_ma(simple string type_, src, simple int len) =>
    float result = na
    if type_ == "SMA"
        result := ta.sma(src, len)
    else if type_ == "EMA"
        result := ta.ema(src, len)
    else if type_ == "WMA"
        result := ta.wma(src, len)
    else if type_ == "RMA"
        result := ta.rma(src, len)
    else if type_ == "HMA"
        result := ta.hma(src, len)
    else if type_ == "VWMA"
        result := ta.vwma(src, len)
    else if type_ == "TEMA"
        result := get_tema(src, len)
    else if type_ == "KAMA"
        result := get_kama(src, len)
    else if type_ == "JMA"
        result := get_jma(src, len, jma_phase, jma_power)
    else
        result := ta.ema(src, len)
    result

// ─── Resuelve el string "Source" al precio del timeframe evaluado ──
resolve_source(simple string src_str) =>
    src_str == "Close" ? close :
     src_str == "Open"  ? open  :
     src_str == "High"  ? high  :
     src_str == "Low"   ? low   :
     src_str == "hl2"   ? hl2   :
     src_str == "hlc3"  ? hlc3  :
     src_str == "ohlc4" ? ohlc4 :
     close

// ─── Función envolvente: calcula la MA con la fuente correcta (se llama DENTRO de request.security) ──
calc_ma_wrapper(simple string type_, simple string src_str, simple int len) =>
    src_series = resolve_source(src_str)
    get_ma(type_, src_series, len)

// ─── Convierte el string de estilo de línea al valor nativo de plot() en Pine v6 ──
resolve_linestyle(simple string s) =>
    s == "Dashed" ? plot.linestyle_dashed :
     s == "Dotted" ? plot.linestyle_dotted :
     plot.linestyle_solid

// ─── Convierte el string de tamaño al valor nativo de size.* ──
resolve_text_size(simple string s) =>
    s == "Tiny"  ? size.tiny  :
     s == "Small" ? size.small :
     s == "Large" ? size.large :
     s == "Huge"  ? size.huge  :
     size.normal

// ─── Convierte el string de posición de tabla al valor nativo de position.* ──
resolve_table_position(simple string s) =>
    s == "Top left"      ? position.top_left      :
     s == "Top center"    ? position.top_center    :
     s == "Top right"     ? position.top_right     :
     s == "Middle left"   ? position.middle_left   :
     s == "Middle center" ? position.middle_center :
     s == "Middle right"  ? position.middle_right  :
     s == "Bottom left"   ? position.bottom_left   :
     s == "Bottom center" ? position.bottom_center :
     position.bottom_right

// ─── Texto de temporalidad de una MA (vacío = TF actual del gráfico) ──
display_tf(simple string tf_in) =>
    tf_in == "" ? timeframe.period : tf_in

// ─── Texto de etiqueta: combina Tipo / Longitud / Temporalidad (formato universal "EMA(8) 1D") ──
build_label_text(bool show_tipo, bool show_long, bool show_tf, string type_, int len, string tf_in) =>
    string parte_tipo_long = ""
    if show_tipo and show_long
        parte_tipo_long := type_ + "(" + str.tostring(len) + ")"
    else if show_tipo and not show_long
        parte_tipo_long := type_
    else if not show_tipo and show_long
        parte_tipo_long := str.tostring(len)
    string parte_tf = show_tf ? display_tf(tf_in) : ""
    string sep = (parte_tipo_long != "" and parte_tf != "") ? " " : ""
    parte_tipo_long + sep + parte_tf


// =====================================================================================================================
// SECCIÓN 5 — CÁLCULO DE LAS 5 MAs (MULTI-TEMPORALIDAD)
// Nota: request.security se llama SIEMPRE (lookahead OFF por defecto). Con TF "" usa la TF del gráfico.
// =====================================================================================================================

v_ma1 = request.security(syminfo.tickerid, ma1_tf, calc_ma_wrapper(ma1_type, ma1_src, ma1_len))
v_ma2 = request.security(syminfo.tickerid, ma2_tf, calc_ma_wrapper(ma2_type, ma2_src, ma2_len))
v_ma3 = request.security(syminfo.tickerid, ma3_tf, calc_ma_wrapper(ma3_type, ma3_src, ma3_len))
v_ma4 = request.security(syminfo.tickerid, ma4_tf, calc_ma_wrapper(ma4_type, ma4_src, ma4_len))
v_ma5 = request.security(syminfo.tickerid, ma5_tf, calc_ma_wrapper(ma5_type, ma5_src, ma5_len))


// =====================================================================================================================
// SECCIÓN 6 — PLOT DE LAS 5 MAs (estilo Solid / Dashed / Dotted)
// =====================================================================================================================

plot(ma1_show ? v_ma1 : na, "MA 1", color=ma1_col, linewidth=ma1_width, linestyle=resolve_linestyle(ma1_style))
plot(ma2_show ? v_ma2 : na, "MA 2", color=ma2_col, linewidth=ma2_width, linestyle=resolve_linestyle(ma2_style))
plot(ma3_show ? v_ma3 : na, "MA 3", color=ma3_col, linewidth=ma3_width, linestyle=resolve_linestyle(ma3_style))
plot(ma4_show ? v_ma4 : na, "MA 4", color=ma4_col, linewidth=ma4_width, linestyle=resolve_linestyle(ma4_style))
plot(ma5_show ? v_ma5 : na, "MA 5", color=ma5_col, linewidth=ma5_width, linestyle=resolve_linestyle(ma5_style))


// =====================================================================================================================
// SECCIÓN 7 — ETIQUETAS (UNA POR MA, REDIBUJADAS EN LA ÚLTIMA BARRA)
// =====================================================================================================================

var label lbl1 = na
var label lbl2 = na
var label lbl3 = na
var label lbl4 = na
var label lbl5 = na

draw_ma_label(bool show_ma, bool show_lbl, bool show_tipo, bool show_long, bool show_tf, string type_, int len, string tf_in, float ma_value, int offset_x, string lbl_size, color line_color) =>
    label new_lbl = na
    if show_ma and show_lbl and not na(ma_value)
        string txt = build_label_text(show_tipo, show_long, show_tf, type_, len, tf_in)
        if txt != ""
            new_lbl := label.new(
                 x=bar_index + offset_x,
                 y=ma_value,
                 text=txt,
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_none,
                 textcolor=line_color,
                 size=resolve_text_size(lbl_size))
    new_lbl

if barstate.islast
    label.delete(lbl1)
    label.delete(lbl2)
    label.delete(lbl3)
    label.delete(lbl4)
    label.delete(lbl5)
    lbl1 := draw_ma_label(ma1_show, ma1_lbl_show, ma1_lbl_tipo, ma1_lbl_long, ma1_lbl_tf, ma1_type, ma1_len, ma1_tf, v_ma1, ma1_lbl_offset, ma1_lbl_size, ma1_col)
    lbl2 := draw_ma_label(ma2_show, ma2_lbl_show, ma2_lbl_tipo, ma2_lbl_long, ma2_lbl_tf, ma2_type, ma2_len, ma2_tf, v_ma2, ma2_lbl_offset, ma2_lbl_size, ma2_col)
    lbl3 := draw_ma_label(ma3_show, ma3_lbl_show, ma3_lbl_tipo, ma3_lbl_long, ma3_lbl_tf, ma3_type, ma3_len, ma3_tf, v_ma3, ma3_lbl_offset, ma3_lbl_size, ma3_col)
    lbl4 := draw_ma_label(ma4_show, ma4_lbl_show, ma4_lbl_tipo, ma4_lbl_long, ma4_lbl_tf, ma4_type, ma4_len, ma4_tf, v_ma4, ma4_lbl_offset, ma4_lbl_size, ma4_col)
    lbl5 := draw_ma_label(ma5_show, ma5_lbl_show, ma5_lbl_tipo, ma5_lbl_long, ma5_lbl_tf, ma5_type, ma5_len, ma5_tf, v_ma5, ma5_lbl_offset, ma5_lbl_size, ma5_col)

// =====================================================================================================================
// SECCIÓN 8 — TABLA RESUMEN  →  MOVIDA A LA SECCIÓN 13 (final del script)
// ---------------------------------------------------------------------------------------------------------------------
// La tabla no se eliminó: se movió tal cual al final, porque en la v2 necesita leer inputs nuevos (columnas Ritmo y
// Últ. cruce, fila de alineación) que, por compatibilidad de configuraciones guardadas, deben declararse DESPUÉS de
// los 98 inputs de la v1. Mover código no afecta a nadie; mover perillas sí. Ver la nota de la SECCIÓN 13.
// =====================================================================================================================

// =====================================================================================================================
// SECCIÓN 9 — ALARMAS (22 EN TOTAL) — Camino A: mensajes trilingües en un solo texto
// ---------------------------------------------------------------------------------------------------------------------
// • 10 Precio↔MA (5 MAs × subir/bajar). Respetan el toggle "Mostrar" de la MA.
// • 10 MA↔MA en 5 slots configurables (dropdowns). Respetan el toggle "Activar" del slot.
// • 2 comodín. Los títulos y mensajes están escritos en inglés · español · portugués.
// v2: las CONDICIONES de estas 22 alarmas ahora pasan por la banda anti-ruido opcional (SECCIÓN 9b). Con la banda
//     apagada —que es el default— el resultado es idéntico al de la v1. Ni el orden ni los títulos cambiaron, así que
//     las alertas ya creadas por los usuarios siguen apuntando a lo mismo. Las 2 alarmas nuevas van al final (SEC. 18).
// =====================================================================================================================

grp_slots = "🔔 Alerts — MA↔MA slots / Alarmas — Slots MA↔MA / Alertas — Slots MA↔MA"

slot1_on   = input.bool(false, "Slot 1: Enable / Activar / Ativar",                                                       group=grp_slots)
slot1_fast = input.string("MA 1", "Slot 1: Fast MA / MA rápida / MM rápida", options=["MA 1","MA 2","MA 3","MA 4","MA 5"], group=grp_slots)
slot1_slow = input.string("MA 2", "Slot 1: Slow MA / MA lenta / MM lenta",   options=["MA 1","MA 2","MA 3","MA 4","MA 5"], group=grp_slots)

slot2_on   = input.bool(false, "Slot 2: Enable / Activar / Ativar",                                                       group=grp_slots)
slot2_fast = input.string("MA 1", "Slot 2: Fast MA / MA rápida / MM rápida", options=["MA 1","MA 2","MA 3","MA 4","MA 5"], group=grp_slots)
slot2_slow = input.string("MA 3", "Slot 2: Slow MA / MA lenta / MM lenta",   options=["MA 1","MA 2","MA 3","MA 4","MA 5"], group=grp_slots)

slot3_on   = input.bool(false, "Slot 3: Enable / Activar / Ativar",                                                       group=grp_slots)
slot3_fast = input.string("MA 2", "Slot 3: Fast MA / MA rápida / MM rápida", options=["MA 1","MA 2","MA 3","MA 4","MA 5"], group=grp_slots)
slot3_slow = input.string("MA 4", "Slot 3: Slow MA / MA lenta / MM lenta",   options=["MA 1","MA 2","MA 3","MA 4","MA 5"], group=grp_slots)

slot4_on   = input.bool(false, "Slot 4: Enable / Activar / Ativar",                                                       group=grp_slots)
slot4_fast = input.string("MA 3", "Slot 4: Fast MA / MA rápida / MM rápida", options=["MA 1","MA 2","MA 3","MA 4","MA 5"], group=grp_slots)
slot4_slow = input.string("MA 4", "Slot 4: Slow MA / MA lenta / MM lenta",   options=["MA 1","MA 2","MA 3","MA 4","MA 5"], group=grp_slots)

slot5_on   = input.bool(false, "Slot 5: Enable / Activar / Ativar",                                                       group=grp_slots)
slot5_fast = input.string("MA 2", "Slot 5: Fast MA / MA rápida / MM rápida", options=["MA 1","MA 2","MA 3","MA 4","MA 5"], group=grp_slots)
slot5_slow = input.string("MA 5", "Slot 5: Slow MA / MA lenta / MM lenta",   options=["MA 1","MA 2","MA 3","MA 4","MA 5"], group=grp_slots)

// =====================================================================================================================
// SECCIÓN 9b — INPUTS NUEVOS DE LA v2
// ---------------------------------------------------------------------------------------------------------------------
// IMPORTANTE (compatibilidad): TODOS los inputs nuevos se declaran ACÁ, después de los 98 inputs de la v1, y ninguno
// de los viejos se movió ni se reordenó. TradingView guarda la configuración del usuario por posición de input: si se
// insertara una perilla en el medio, todos los gráficos que ya tienen el indicador puesto verían su configuración
// corrida. Agregando siempre al final, la actualización es transparente para quien ya lo usa.
// (La agrupación visual del panel la maneja el NOMBRE del grupo, no el orden de declaración: por eso las columnas
//  nuevas de la tabla se declaran acá abajo pero aparecen dentro del grupo "Summary table" de más arriba.)
// =====================================================================================================================

// ─── B2 · BANDA ANTI-RUIDO (× ATR) ────────────────────────────────────────────────────────────────────────────────
// Un cruce "de verdad" separa las dos líneas más de lo que las separa el temblor normal del mercado. Con la banda
// activa, el cruce se declara recién cuando la separación supera k × ATR, y no vuelve a girar hasta que la separación
// cruce la banda del otro lado (histéresis). Eso elimina la ráfaga de cruces falsos en mercados laterales.
// APAGADA POR DEFECTO: con la banda apagada el script usa ta.crossover/ta.crossunder exactamente como la v1.
grp_band = "🎛️ Noise band / Banda anti-ruido / Banda anti-ruído"
band_on = input.bool(false,
     "Noise band: filter every cross / Banda: filtrar todos los cruces / Banda: filtrar todos os cruzamentos",
     tooltip="OFF (default) = identical behaviour to v1: a cross is any crossover. ON = a cross is declared only when the two lines separate by more than k × ATR, and it will not flip back until the band is crossed the other way. Fewer, cleaner signals. Applies to Price/MA alerts, MA/MA slot alerts and the Golden/Death Cross. / APAGADA (default) = comportamiento idéntico a la v1: el cruce es cualquier cruce. ENCENDIDA = el cruce se declara solo cuando las dos líneas se separan más de k × ATR, y no vuelve a girar hasta cruzar la banda del otro lado. Menos señales y más limpias. Afecta a las alarmas Precio/MA, a las de los slots MA/MA y al Cruce Dorado / de la Muerte. / DESLIGADA (padrão) = comportamento idêntico ao da v1. LIGADA = o cruzamento só é declarado quando as duas linhas se separam mais de k × ATR. Menos sinais e mais limpos.",
     group=grp_band)
band_k  = input.float(0.25,
     "Noise band: width (× ATR) / Banda: ancho (× ATR) / Banda: largura (× ATR)",
     minval=0.0, maxval=5.0, step=0.05,
     tooltip="0.25 = a quarter of the average range. Higher = stricter (fewer signals, more lag). / 0,25 = un cuarto del rango promedio. Más alto = más exigente (menos señales, más retraso). / 0,25 = um quarto do intervalo médio. Mais alto = mais exigente (menos sinais, mais atraso).",
     group=grp_band)
band_lb = input.int(14,
     "Noise band: ATR length / Banda: ventana del ATR / Banda: janela do ATR",
     minval=1, maxval=200,
     tooltip="Bars used to measure the typical range of the market. Always measured on the CHART timeframe, because that is where the alerts fire. / Barras con las que se mide el rango típico del mercado. Siempre en la temporalidad DEL GRÁFICO, porque es ahí donde disparan las alarmas. / Barras usadas para medir o intervalo típico. Sempre no tempo gráfico DO GRÁFICO.",
     group=grp_band)

// ─── GC · GOLDEN CROSS / DEATH CROSS ──────────────────────────────────────────────────────────────────────────────
// El cruce más mirado del análisis técnico: una media rápida cruzando a una lenta. El clásico es 50 vs 200, que con
// los defaults de este indicador son justamente MA 3 (EMA 50) y MA 5 (SMA 200). Cualquier par se puede elegir.
// El RELLENO entre MAs (grupo 🎨) viene apuntando al mismo par: es la versión continua de este cruce — pinta todo el
// tiempo de qué lado está el mercado, y cambia de color exactamente en el instante que acá se marca con la etiqueta.
grp_gc = "✨ Golden / Death Cross"
gc_on    = input.bool(true,
     "Show Golden · Death Cross on chart / Mostrar Cruce Dorado · de la Muerte / Mostrar Cruz Dourada · da Morte",
     tooltip="Marks on the chart the moment the chosen fast MA crosses the chosen slow MA: bullish = Golden Cross, bearish = Death Cross. / Marca en el gráfico el momento en que la MA rápida elegida cruza a la MA lenta elegida: alcista = Cruce Dorado, bajista = Cruce de la Muerte. / Marca no gráfico o momento em que a MM rápida escolhida cruza a MM lenta escolhida.",
     group=grp_gc)
gc_fast  = input.string("MA 3", "Fast MA / MA rápida / MM rápida", options=["MA 1","MA 2","MA 3","MA 4","MA 5"],
     tooltip="With the factory defaults, MA 3 = EMA(50). / Con los valores de fábrica, MA 3 = EMA(50). / Com os valores de fábrica, MM 3 = EMA(50).",
     group=grp_gc)
gc_slow  = input.string("MA 5", "Slow MA / MA lenta / MM lenta",   options=["MA 1","MA 2","MA 3","MA 4","MA 5"],
     tooltip="With the factory defaults, MA 5 = SMA(200), so MA 3 vs MA 5 is the classic 50/200 cross. / Con los valores de fábrica, MA 5 = SMA(200), así que MA 3 vs MA 5 es el cruce clásico 50/200. / Com os valores de fábrica, MM 5 = SMA(200), portanto é o cruzamento clássico 50/200.",
     group=grp_gc)
gc_txt   = input.bool(true,  "Show text next to the marker / Mostrar el texto junto a la marca / Mostrar o texto junto à marca", group=grp_gc)
gc_size  = input.string("Small", "Marker size / Tamaño de la marca / Tamanho da marca", options=["Tiny","Small","Normal","Large","Huge"], group=grp_gc)
gc_line  = input.bool(false, "Draw a vertical line at the cross / Dibujar una línea vertical en el cruce / Desenhar uma linha vertical no cruzamento",
     tooltip="Useful to line the cross up against what the price did afterwards. Off by default to keep the chart clean. / Sirve para alinear el cruce con lo que hizo el precio después. Apagada por defecto para no ensuciar el gráfico. / Serve para alinhar o cruzamento com o que o preço fez depois. Desligada por padrão.",
     group=grp_gc)
gc_col_g = input.color(#FFB300, "Golden Cross color / Color Cruce Dorado / Cor Cruz Dourada", group=grp_gc, inline="gcc")
gc_col_d = input.color(#C62828, "Death / Muerte / Morte",                                     group=grp_gc, inline="gcc")
gc_col_t = input.color(color.white, "Marker text color / Color del texto de la marca / Cor do texto da marca", group=grp_gc)

// ─── A3 · RELLENO ENTRE DOS MAs ───────────────────────────────────────────────────────────────────────────────────
grp_fil = "🎨 Fill between MAs / Relleno entre MAs / Preenchimento entre MMs"
fil_on   = input.bool(false, "Fill: show / Relleno: mostrar / Preenchimento: mostrar",
     tooltip="Paints the area between the two chosen MAs: one colour when the first is above, another when it is below. Out of the box it points at the same pair as the Golden/Death Cross (MA 3 vs MA 5), so it is the continuous version of that cross: the band flips colour exactly at the cross, and its thickness shows how far apart the two MAs are, i.e. how strong the trend is. / Pinta el área entre las dos MAs elegidas: un color cuando la primera está arriba y otro cuando está abajo. De fábrica apunta al mismo par que el Cruce Dorado / de la Muerte (MA 3 vs MA 5), así que es la versión continua de ese cruce: la franja cambia de color justo en el cruce, y su grosor muestra cuán separadas están las dos MAs, o sea la fuerza de la tendencia. / Pinta a área entre as duas MMs escolhidas. De fábrica aponta para o mesmo par da Cruz Dourada / da Morte (MM 3 vs MM 5): a faixa muda de cor exatamente no cruzamento e sua espessura mostra a força da tendência.",
     group=grp_fil)
fil_a    = input.string("MA 3", "Fill: MA A / Relleno: MA A / Preenchimento: MM A", options=["MA 1","MA 2","MA 3","MA 4","MA 5"], group=grp_fil)
fil_b    = input.string("MA 5", "Fill: MA B / Relleno: MA B / Preenchimento: MM B", options=["MA 1","MA 2","MA 3","MA 4","MA 5"], group=grp_fil)
fil_c_up = input.color(#26A69A, "A above B / A sobre B / A acima de B", group=grp_fil, inline="fc")
fil_c_dn = input.color(#EF5350, "A below B / A bajo B / A abaixo de B", group=grp_fil, inline="fc")
fil_tr   = input.int(85, "Fill: transparency / Relleno: transparencia / Preenchimento: transparência", minval=0, maxval=100, group=grp_fil)

// ─── VENTANAS COMUNES DE CÁLCULO ──────────────────────────────────────────────────────────────────────────────────
// Una sola ventana de "ritmo" y una sola de "volatilidad" alimentan la columna Ritmo, el cono de proyección y la
// probabilidad de cruce. Se comparten a propósito: son la misma pregunta ("¿a qué velocidad va?" y "¿cuánto tiembla?")
// hecha sobre series distintas, y tener tres perillas separadas para lo mismo solo confunde.
grp_win = "📐 Calculation windows / Ventanas de cálculo / Janelas de cálculo"
w_slope = input.int(20, "Rate window (bars) / Ventana del ritmo (barras) / Janela do ritmo (barras)", minval=2, maxval=500,
     tooltip="Over how many bars the pace of a line is measured (how fast it rises or falls). Shorter = reacts fast to recent changes; longer = smoother and more stable. Used by the Rate column, the projection cone and the cross probability. / Sobre cuántas barras se mide el ritmo de una línea (a qué velocidad sube o baja). Más corta = reacciona rápido a cambios recientes; más larga = más suave y estable. La usan la columna Ritmo, el cono de proyección y la probabilidad de cruce. / Sobre quantas barras se mede o ritmo de uma linha. Mais curta = reage rápido; mais longa = mais suave.",
     group=grp_win)
w_vol   = input.int(20, "Volatility window (bars) / Ventana de volatilidad (barras) / Janela de volatilidade (barras)", minval=2, maxval=500,
     tooltip="Over how many bars the wobble of a line is measured. It sets the width of the projection cone and it is the factor that weighs most in the cross probability: more wobble = a cross is more likely. Note: the probability module uses three times this window, and measures the wobble at the scale of the horizon rather than bar by bar, because the gap between two averages is a smooth curve and not a random walk. / Sobre cuántas barras se mide cuánto tiembla una línea. Define el ancho del cono de proyección y es el factor que más pesa en la probabilidad de cruce: más temblor = cruce más probable. Nota: el módulo de probabilidad usa el triple de esta ventana, y mide el temblor a la escala del horizonte en vez de barra a barra, porque la brecha entre dos medias es una curva suave y no un paseo aleatorio. / Sobre quantas barras se mede o quanto uma linha treme. Define a largura do cone e é o fator de maior peso na probabilidade. Nota: o módulo de probabilidade usa o triplo desta janela e mede na escala do horizonte.",
     group=grp_win)

// ─── A4 · CONO DE PROYECCIÓN ──────────────────────────────────────────────────────────────────────────────────────
// Proyecta cada MA hacia adelante siguiendo su ritmo actual, con una banda que se ensancha con el tiempo
// (ancho ∝ volatilidad × √tiempo). Es la forma honesta de dibujar un pronóstico, la misma que usan los bancos
// centrales en sus fan charts: en vez de una línea (que sugiere una precisión que no existe), la banda de lo posible.
grp_proj = "🔮 Projection cone / Cono de proyección / Cone de projeção"
proj_show    = input.bool(false, "Cone: show / Cono: mostrar / Cone: mostrar",
     tooltip="Draws where each MA would go if it kept its current pace, inside a band that widens the further out it goes. It is an 'if everything stays the same' scenario, NOT a crystal ball. / Dibuja hacia dónde iría cada MA si mantuviera su ritmo actual, dentro de una banda que se ensancha cuanto más lejos va. Es un escenario de 'si todo sigue igual', NO una bola de cristal. / Desenha para onde cada MM iria se mantivesse seu ritmo atual, dentro de uma banda que se alarga. É um cenário de 'se tudo continuar igual', NÃO uma bola de cristal.",
     group=grp_proj)
proj_bars    = input.int(10, "Cone: bars to project / Cono: barras a proyectar / Cone: barras a projetar", minval=2, maxval=100, group=grp_proj)
proj_band    = input.float(1.0, "Cone: width (x std dev) / Cono: ancho (x desvíos) / Cone: largura (x desvios)", minval=0.2, maxval=4.0, step=0.1,
     tooltip="1 is roughly a 68% band (one standard deviation). 2 is roughly 95%. Higher = wider and more conservative. / 1 es aproximadamente la banda del 68% (un desvío estándar). 2 es aproximadamente 95%. Más alto = más ancho y más conservador. / 1 é aproximadamente a banda de 68% (um desvio padrão). 2 é aproximadamente 95%.",
     group=grp_proj)
proj_opacity = input.int(88, "Cone: fill transparency / Cono: transparencia del relleno / Cone: transparência do preenchimento", minval=0, maxval=100, group=grp_proj)
proj_center  = input.bool(true, "Cone: draw the centre line (dashed) / Cono: dibujar la línea central (punteada) / Cone: desenhar a linha central (tracejada)", group=grp_proj)
proj_ma1     = input.bool(true, "Project MA 1 / Proyectar MA 1 / Projetar MM 1", group=grp_proj, inline="pj1")
proj_ma2     = input.bool(true, "MA 2", group=grp_proj, inline="pj1")
proj_ma3     = input.bool(true, "MA 3", group=grp_proj, inline="pj1")
proj_ma4     = input.bool(true, "MA 4", group=grp_proj, inline="pj1")
proj_ma5     = input.bool(true, "MA 5", group=grp_proj, inline="pj1")

// ─── B1 · PROBABILIDAD DE CRUCE ───────────────────────────────────────────────────────────────────────────────────
// Un cruce ocurre cuando la BRECHA entre dos líneas llega a cero. La probabilidad de que eso pase dentro de N barras
// se calcula con el "tiempo de primer paso" de un Browniano con deriva: entran la brecha actual, su tendencia (¿se
// vienen acercando?) y su volatilidad (¿cuánto tiembla?). Es el mismo cálculo que se usa para la probabilidad de que
// un precio toque una barrera. No hay parámetros ajustados al pasado: es una fórmula cerrada.
grp_prob = "🎲 Cross probability / Probabilidad de cruce / Probabilidade de cruzamento"
prob_show   = input.bool(false, "Probability: show table / Probabilidad: mostrar tabla / Probabilidade: mostrar tabela",
     tooltip="Estimates the probability that each pair of lines touches within the chosen horizon, plus the approximate bar and price zone of that cross. / Estima la probabilidad de que cada par de líneas se toque dentro del horizonte elegido, más la barra y la zona de precios aproximadas de ese cruce. / Estima a probabilidade de que cada par de linhas se toque dentro do horizonte escolhido.",
     group=grp_prob)
prob_horizon = input.int(10, "Horizon: within how many bars / Horizonte: dentro de cuántas barras / Horizonte: dentro de quantas barras", minval=1, maxval=200,
     tooltip="Measured in bars OF THE CHART, not of the timeframe of the MA. On a 1h chart with a Daily MA, a horizon of 10 means 'within the next 10 hourly bars'. / Se mide en barras DEL GRÁFICO, no de la temporalidad de la MA. En un gráfico de 1h con una MA diaria, un horizonte de 10 significa 'en las próximas 10 barras de 1h'. / É medido em barras DO GRÁFICO, não do tempo gráfico da MM.",
     group=grp_prob)
prob_umbral = input.float(60.0, "Highlight threshold (%) / Umbral para resaltar (%) / Limiar para destacar (%)", minval=0.0, maxval=100.0, step=5.0,
     tooltip="Probability from which the cell is highlighted, and from which the estimated bar and price zone are shown. Below it they stay hidden on purpose: showing a precise forecast of a cross that probably will not happen would be dishonest. / Probabilidad a partir de la cual se resalta la celda, y a partir de la cual se muestran la barra y la zona de precios estimadas. Por debajo quedan ocultas a propósito: mostrar un pronóstico preciso de un cruce que probablemente no va a ocurrir sería deshonesto. / Probabilidade a partir da qual a célula é destacada e a barra e a zona estimadas são mostradas.",
     group=grp_prob)
prob_xprice = input.bool(true, "Show estimated bar and price zone / Mostrar barra y zona de precios estimadas / Mostrar barra e zona de preços estimadas", group=grp_prob)
xp_band     = input.float(1.0, "Cross zone width (x std dev) / Ancho de la zona de cruce (x desvíos) / Largura da zona (x desvios)", minval=0.2, maxval=4.0, step=0.1,
     tooltip="How wide the price zone of the cross is. 1 is roughly 68% confidence; higher = a wider zone. / Qué tan ancha es la zona de precios del cruce. 1 es aproximadamente 68% de confianza; más alto = zona más amplia. / Quão larga é a zona de preços do cruzamento.",
     group=grp_prob)
prob_pos    = input.string("Bottom right", "Probability: position / Probabilidad: posición / Probabilidade: posição",
     options=["Top left","Top center","Top right","Middle left","Middle center","Middle right","Bottom left","Bottom center","Bottom right"], group=grp_prob)
prob_size   = input.string("Tiny", "Probability: text size / Probabilidad: tamaño del texto / Probabilidade: tamanho do texto", options=["Tiny","Small","Normal","Large","Huge"], group=grp_prob)
prob_col_hi = input.color(color.new(color.green, 55), "High probability / Probabilidad alta / Probabilidade alta", group=grp_prob)
prob_col_lo = input.color(color.new(color.gray, 82),  "Low probability / Probabilidad baja / Probabilidade baixa",  group=grp_prob)
prob_col_tx = input.color(color.white,                "Probability: text / Probabilidad: texto / Probabilidade: texto", group=grp_prob)
prob_col_hd = input.color(color.new(color.black, 10), "Probability: header / Probabilidad: encabezado / Probabilidade: cabeçalho", group=grp_prob)

// ─── A1 / A2 · COLUMNAS Y FILA NUEVAS DE LA TABLA RESUMEN ─────────────────────────────────────────────────────────
// Se declaran acá (al final, por compatibilidad) pero usan el MISMO grupo que la tabla de la v1, así que en el panel
// aparecen donde corresponde: dentro de "Summary table / Tabla resumen / Tabela resumo".
tbl_show_rate  = input.bool(true, "Table: Rate column (MA slope) / Tabla: columna Ritmo (pendiente de la MA) / Tabela: coluna Ritmo",
     tooltip="How fast each MA is rising or falling, as a percentage of its own value per bar. Tells you whether a moving average is really trending or just drifting sideways. / A qué velocidad sube o baja cada MA, como porcentaje de su propio valor por barra. Dice si una media está realmente en tendencia o solo va de costado. / A que velocidade cada MM sobe ou desce, como percentual do seu próprio valor por barra.",
     group=grp_tbl)
tbl_flat_pct   = input.float(0.02, "Table: flat threshold (% per bar) / Tabla: umbral de plana (% por barra) / Tabela: limiar de plana (% por barra)", minval=0.0, maxval=5.0, step=0.01,
     tooltip="Below this pace the MA is shown as flat with an arrow to the right, instead of rising or falling. / Por debajo de este ritmo la MA se muestra como plana (flecha horizontal) en vez de subiendo o bajando. / Abaixo deste ritmo a MM é mostrada como plana.",
     group=grp_tbl)
tbl_show_lastx = input.bool(true, "Table: bars since last cross / Tabla: barras desde el último cruce / Tabela: barras desde o último cruzamento",
     tooltip="How many bars ago the price last crossed that MA. A very low number means the signal is fresh; a very high one, that the move is mature. / Cuántas barras atrás el precio cruzó por última vez esa MA. Un número muy bajo significa que la señal es fresca; uno muy alto, que el movimiento ya está maduro. / Há quantas barras o preço cruzou pela última vez essa MM.",
     group=grp_tbl)
tbl_show_align = input.bool(true, "Table: fan / alignment row / Tabla: fila de alineación (abanico) / Tabela: linha de alinhamento (leque)",
     tooltip="Final row: checks whether the MAs are stacked in order (fastest above slowest = bullish fan, the other way round = bearish fan) or tangled (mixed). A clean fan is the classic signature of a strong trend. It also shows how many MAs the price is above. Speed is ranked by the TIME each MA covers (length x its timeframe), not by length alone, so the reading stays correct when you mix timeframes. / Fila final: revisa si las MAs están apiladas en orden (la más rápida arriba de la más lenta = abanico alcista, al revés = bajista) o enredadas (mixto). Un abanico limpio es la firma clásica de una tendencia fuerte. También muestra sobre cuántas MAs está el precio. La velocidad se mide por el TIEMPO que cubre cada MA (longitud x su temporalidad) y no por la longitud sola, así la lectura sigue siendo correcta al mezclar temporalidades. / Linha final: verifica se as MMs estão empilhadas em ordem (mais rápida acima da mais lenta = leque de alta) ou embaralhadas. A velocidade é medida pelo TEMPO que cada MM cobre (comprimento x seu tempo gráfico).",
     group=grp_tbl)

// ─── Helper: resuelve "MA N" al valor numérico correspondiente ──
get_ma_value_by_name(simple string ma_name) =>
    ma_name == "MA 1" ? v_ma1 :
     ma_name == "MA 2" ? v_ma2 :
     ma_name == "MA 3" ? v_ma3 :
     ma_name == "MA 4" ? v_ma4 :
     ma_name == "MA 5" ? v_ma5 :
     na

// ─── B2 · BANDA ANTI-RUIDO: ATR del gráfico y ancho efectivo de la banda ──
// El ATR se calcula SIEMPRE, nunca dentro de un ternario: las funciones ta.* necesitan evaluarse en todas las barras
// para mantener su estado interno. El toggle solo decide si el ancho resultante es el ATR o cero.
float _atr_band = ta.atr(band_lb)
float f_band    = band_on ? band_k * nz(_atr_band) : 0.0

// ─── B2 · Estado con histéresis ──
// Devuelve +1 cuando "a" supera a "b" por más que la banda, -1 cuando queda por debajo por más que la banda, y
// MANTIENE el estado anterior mientras la separación esté dentro de la banda. Así un mercado lateral que roza la
// media una y otra vez no genera una ráfaga de cruces: hay que salir por el otro lado de la banda para que gire.
// Cada sitio de llamada tiene su propia memoria (el `var` es por sitio de llamada, no compartido).
f_dir_band(float a, float b, float band) =>
    var int _st = 0
    float _g = a - b
    _st := na(_g) ? _st : (_g > band ? 1 : _g < -band ? -1 : _st)
    _st

// ─── Cruces Precio↔MA ──
// (1) Las ta.* se calculan SIEMPRE, de forma incondicional. (2) La banda, si está activa, reemplaza el criterio de
// cruce por el giro del estado con histéresis. (3) Recién al final se aplica el toggle "Mostrar" de cada MA.
// Con la banda apagada (default) el resultado es idéntico, línea por línea, al de la v1.
int _stb_ma1 = f_dir_band(close, v_ma1, f_band)
int _stb_ma2 = f_dir_band(close, v_ma2, f_band)
int _stb_ma3 = f_dir_band(close, v_ma3, f_band)
int _stb_ma4 = f_dir_band(close, v_ma4, f_band)
int _stb_ma5 = f_dir_band(close, v_ma5, f_band)

bool _co_ma1 = ta.crossover(close, v_ma1)
bool _co_ma2 = ta.crossover(close, v_ma2)
bool _co_ma3 = ta.crossover(close, v_ma3)
bool _co_ma4 = ta.crossover(close, v_ma4)
bool _co_ma5 = ta.crossover(close, v_ma5)

bool _cu_ma1 = ta.crossunder(close, v_ma1)
bool _cu_ma2 = ta.crossunder(close, v_ma2)
bool _cu_ma3 = ta.crossunder(close, v_ma3)
bool _cu_ma4 = ta.crossunder(close, v_ma4)
bool _cu_ma5 = ta.crossunder(close, v_ma5)

bool _raw_xup_ma1 = band_on ? (_stb_ma1 == 1 and _stb_ma1[1] == -1) : _co_ma1
bool _raw_xup_ma2 = band_on ? (_stb_ma2 == 1 and _stb_ma2[1] == -1) : _co_ma2
bool _raw_xup_ma3 = band_on ? (_stb_ma3 == 1 and _stb_ma3[1] == -1) : _co_ma3
bool _raw_xup_ma4 = band_on ? (_stb_ma4 == 1 and _stb_ma4[1] == -1) : _co_ma4
bool _raw_xup_ma5 = band_on ? (_stb_ma5 == 1 and _stb_ma5[1] == -1) : _co_ma5

bool _raw_xdn_ma1 = band_on ? (_stb_ma1 == -1 and _stb_ma1[1] == 1) : _cu_ma1
bool _raw_xdn_ma2 = band_on ? (_stb_ma2 == -1 and _stb_ma2[1] == 1) : _cu_ma2
bool _raw_xdn_ma3 = band_on ? (_stb_ma3 == -1 and _stb_ma3[1] == 1) : _cu_ma3
bool _raw_xdn_ma4 = band_on ? (_stb_ma4 == -1 and _stb_ma4[1] == 1) : _cu_ma4
bool _raw_xdn_ma5 = band_on ? (_stb_ma5 == -1 and _stb_ma5[1] == 1) : _cu_ma5

bool xup_ma1 = ma1_show and _raw_xup_ma1
bool xup_ma2 = ma2_show and _raw_xup_ma2
bool xup_ma3 = ma3_show and _raw_xup_ma3
bool xup_ma4 = ma4_show and _raw_xup_ma4
bool xup_ma5 = ma5_show and _raw_xup_ma5

bool xdn_ma1 = ma1_show and _raw_xdn_ma1
bool xdn_ma2 = ma2_show and _raw_xdn_ma2
bool xdn_ma3 = ma3_show and _raw_xdn_ma3
bool xdn_ma4 = ma4_show and _raw_xdn_ma4
bool xdn_ma5 = ma5_show and _raw_xdn_ma5

// Cualquier cruce del precio con cada MA (sin filtrar por el toggle "Mostrar"): lo consume la columna "Últ. cruce"
// de la tabla resumen, que debe informar aunque la MA esté oculta si se pidió incluir las ocultas.
bool xany_ma1 = _raw_xup_ma1 or _raw_xdn_ma1
bool xany_ma2 = _raw_xup_ma2 or _raw_xdn_ma2
bool xany_ma3 = _raw_xup_ma3 or _raw_xdn_ma3
bool xany_ma4 = _raw_xup_ma4 or _raw_xdn_ma4
bool xany_ma5 = _raw_xup_ma5 or _raw_xdn_ma5

// ─── Cruces MA↔MA en los 5 slots ──
float s1_fast = get_ma_value_by_name(slot1_fast)
float s1_slow = get_ma_value_by_name(slot1_slow)
float s2_fast = get_ma_value_by_name(slot2_fast)
float s2_slow = get_ma_value_by_name(slot2_slow)
float s3_fast = get_ma_value_by_name(slot3_fast)
float s3_slow = get_ma_value_by_name(slot3_slow)
float s4_fast = get_ma_value_by_name(slot4_fast)
float s4_slow = get_ma_value_by_name(slot4_slow)
float s5_fast = get_ma_value_by_name(slot5_fast)
float s5_slow = get_ma_value_by_name(slot5_slow)

int _stb_s1 = f_dir_band(s1_fast, s1_slow, f_band)
int _stb_s2 = f_dir_band(s2_fast, s2_slow, f_band)
int _stb_s3 = f_dir_band(s3_fast, s3_slow, f_band)
int _stb_s4 = f_dir_band(s4_fast, s4_slow, f_band)
int _stb_s5 = f_dir_band(s5_fast, s5_slow, f_band)

bool _co_s1 = ta.crossover(s1_fast, s1_slow)
bool _co_s2 = ta.crossover(s2_fast, s2_slow)
bool _co_s3 = ta.crossover(s3_fast, s3_slow)
bool _co_s4 = ta.crossover(s4_fast, s4_slow)
bool _co_s5 = ta.crossover(s5_fast, s5_slow)

bool _cu_s1 = ta.crossunder(s1_fast, s1_slow)
bool _cu_s2 = ta.crossunder(s2_fast, s2_slow)
bool _cu_s3 = ta.crossunder(s3_fast, s3_slow)
bool _cu_s4 = ta.crossunder(s4_fast, s4_slow)
bool _cu_s5 = ta.crossunder(s5_fast, s5_slow)

bool _raw_s1_xup = band_on ? (_stb_s1 == 1 and _stb_s1[1] == -1) : _co_s1
bool _raw_s2_xup = band_on ? (_stb_s2 == 1 and _stb_s2[1] == -1) : _co_s2
bool _raw_s3_xup = band_on ? (_stb_s3 == 1 and _stb_s3[1] == -1) : _co_s3
bool _raw_s4_xup = band_on ? (_stb_s4 == 1 and _stb_s4[1] == -1) : _co_s4
bool _raw_s5_xup = band_on ? (_stb_s5 == 1 and _stb_s5[1] == -1) : _co_s5

bool _raw_s1_xdn = band_on ? (_stb_s1 == -1 and _stb_s1[1] == 1) : _cu_s1
bool _raw_s2_xdn = band_on ? (_stb_s2 == -1 and _stb_s2[1] == 1) : _cu_s2
bool _raw_s3_xdn = band_on ? (_stb_s3 == -1 and _stb_s3[1] == 1) : _cu_s3
bool _raw_s4_xdn = band_on ? (_stb_s4 == -1 and _stb_s4[1] == 1) : _cu_s4
bool _raw_s5_xdn = band_on ? (_stb_s5 == -1 and _stb_s5[1] == 1) : _cu_s5

bool s1_xup = slot1_on and _raw_s1_xup
bool s2_xup = slot2_on and _raw_s2_xup
bool s3_xup = slot3_on and _raw_s3_xup
bool s4_xup = slot4_on and _raw_s4_xup
bool s5_xup = slot5_on and _raw_s5_xup

bool s1_xdn = slot1_on and _raw_s1_xdn
bool s2_xdn = slot2_on and _raw_s2_xdn
bool s3_xdn = slot3_on and _raw_s3_xdn
bool s4_xdn = slot4_on and _raw_s4_xdn
bool s5_xdn = slot5_on and _raw_s5_xdn

// ─── Comodín ──
bool any_price_cross = xup_ma1 or xup_ma2 or xup_ma3 or xup_ma4 or xup_ma5 or xdn_ma1 or xdn_ma2 or xdn_ma3 or xdn_ma4 or xdn_ma5
bool any_ma_cross    = s1_xup or s2_xup or s3_xup or s4_xup or s5_xup or s1_xdn or s2_xdn or s3_xdn or s4_xdn or s5_xdn

// ─── Declaración de las 22 alarmas (títulos y mensajes trilingües: EN · ES · PT) ──
// Precio↔MA — cruces alcistas (5)
alertcondition(xup_ma1, title="🟢 Price/Precio/Preço ↑ MA 1", message="Price crossed above MA 1 · Precio cruzó por encima de MA 1 · Preço cruzou acima da MA 1 — {{ticker}} @ {{close}}")
alertcondition(xup_ma2, title="🟢 Price/Precio/Preço ↑ MA 2", message="Price crossed above MA 2 · Precio cruzó por encima de MA 2 · Preço cruzou acima da MA 2 — {{ticker}} @ {{close}}")
alertcondition(xup_ma3, title="🟢 Price/Precio/Preço ↑ MA 3", message="Price crossed above MA 3 · Precio cruzó por encima de MA 3 · Preço cruzou acima da MA 3 — {{ticker}} @ {{close}}")
alertcondition(xup_ma4, title="🟢 Price/Precio/Preço ↑ MA 4", message="Price crossed above MA 4 · Precio cruzó por encima de MA 4 · Preço cruzou acima da MA 4 — {{ticker}} @ {{close}}")
alertcondition(xup_ma5, title="🟢 Price/Precio/Preço ↑ MA 5", message="Price crossed above MA 5 · Precio cruzó por encima de MA 5 · Preço cruzou acima da MA 5 — {{ticker}} @ {{close}}")

// Precio↔MA — cruces bajistas (5)
alertcondition(xdn_ma1, title="🔴 Price/Precio/Preço ↓ MA 1", message="Price crossed below MA 1 · Precio cruzó por debajo de MA 1 · Preço cruzou abaixo da MA 1 — {{ticker}} @ {{close}}")
alertcondition(xdn_ma2, title="🔴 Price/Precio/Preço ↓ MA 2", message="Price crossed below MA 2 · Precio cruzó por debajo de MA 2 · Preço cruzou abaixo da MA 2 — {{ticker}} @ {{close}}")
alertcondition(xdn_ma3, title="🔴 Price/Precio/Preço ↓ MA 3", message="Price crossed below MA 3 · Precio cruzó por debajo de MA 3 · Preço cruzou abaixo da MA 3 — {{ticker}} @ {{close}}")
alertcondition(xdn_ma4, title="🔴 Price/Precio/Preço ↓ MA 4", message="Price crossed below MA 4 · Precio cruzó por debajo de MA 4 · Preço cruzou abaixo da MA 4 — {{ticker}} @ {{close}}")
alertcondition(xdn_ma5, title="🔴 Price/Precio/Preço ↓ MA 5", message="Price crossed below MA 5 · Precio cruzó por debajo de MA 5 · Preço cruzou abaixo da MA 5 — {{ticker}} @ {{close}}")

// MA↔MA — cruces alcistas en los 5 slots (5)
alertcondition(s1_xup, title="🟢 Slot 1: ↑ MA↔MA", message="Slot 1: bullish MA↔MA cross · Slot 1: cruce alcista MA↔MA · Slot 1: cruzamento de alta MA↔MA — {{ticker}} @ {{close}}")
alertcondition(s2_xup, title="🟢 Slot 2: ↑ MA↔MA", message="Slot 2: bullish MA↔MA cross · Slot 2: cruce alcista MA↔MA · Slot 2: cruzamento de alta MA↔MA — {{ticker}} @ {{close}}")
alertcondition(s3_xup, title="🟢 Slot 3: ↑ MA↔MA", message="Slot 3: bullish MA↔MA cross · Slot 3: cruce alcista MA↔MA · Slot 3: cruzamento de alta MA↔MA — {{ticker}} @ {{close}}")
alertcondition(s4_xup, title="🟢 Slot 4: ↑ MA↔MA", message="Slot 4: bullish MA↔MA cross · Slot 4: cruce alcista MA↔MA · Slot 4: cruzamento de alta MA↔MA — {{ticker}} @ {{close}}")
alertcondition(s5_xup, title="🟢 Slot 5: ↑ MA↔MA", message="Slot 5: bullish MA↔MA cross · Slot 5: cruce alcista MA↔MA · Slot 5: cruzamento de alta MA↔MA — {{ticker}} @ {{close}}")

// MA↔MA — cruces bajistas en los 5 slots (5)
alertcondition(s1_xdn, title="🔴 Slot 1: ↓ MA↔MA", message="Slot 1: bearish MA↔MA cross · Slot 1: cruce bajista MA↔MA · Slot 1: cruzamento de baixa MA↔MA — {{ticker}} @ {{close}}")
alertcondition(s2_xdn, title="🔴 Slot 2: ↓ MA↔MA", message="Slot 2: bearish MA↔MA cross · Slot 2: cruce bajista MA↔MA · Slot 2: cruzamento de baixa MA↔MA — {{ticker}} @ {{close}}")
alertcondition(s3_xdn, title="🔴 Slot 3: ↓ MA↔MA", message="Slot 3: bearish MA↔MA cross · Slot 3: cruce bajista MA↔MA · Slot 3: cruzamento de baixa MA↔MA — {{ticker}} @ {{close}}")
alertcondition(s4_xdn, title="🔴 Slot 4: ↓ MA↔MA", message="Slot 4: bearish MA↔MA cross · Slot 4: cruce bajista MA↔MA · Slot 4: cruzamento de baixa MA↔MA — {{ticker}} @ {{close}}")
alertcondition(s5_xdn, title="🔴 Slot 5: ↓ MA↔MA", message="Slot 5: bearish MA↔MA cross · Slot 5: cruce bajista MA↔MA · Slot 5: cruzamento de baixa MA↔MA — {{ticker}} @ {{close}}")

// Comodín (2)
alertcondition(any_price_cross, title="🚦 Any/Cualq./Qualq. cross Price↔MA", message="Any Price↔MA cross · Cualquier cruce Precio↔MA · Qualquer cruzamento Preço↔MA — {{ticker}} @ {{close}}")
alertcondition(any_ma_cross,    title="🚦 Any/Cualq./Qualq. cross MA↔MA",    message="Any MA↔MA cross (slots) · Cualquier cruce MA↔MA (slots) · Qualquer cruzamento MA↔MA (slots) — {{ticker}} @ {{close}}")


// =====================================================================================================================
// SECCIÓN 10 — FUNCIONES AUXILIARES DE LA v2
// =====================================================================================================================

// ─── Función error y CDF normal (aproximación Abramowitz-Stegun 7.1.26, precisa a ~1e-7) ──
f_erf(float x) =>
    float _s = x < 0 ? -1.0 : 1.0
    float _x = math.abs(x)
    float _t = 1.0 / (1.0 + 0.3275911 * _x)
    float _y = 1.0 - (((((1.061405429 * _t - 1.453152027) * _t) + 1.421413741) * _t - 0.284496736) * _t + 0.254829592) * _t * math.exp(-_x * _x)
    _s * _y

f_ncdf(float x) =>
    0.5 * (1.0 + f_erf(x / math.sqrt(2.0)))

// ─── B1 · Probabilidad de que la brecha entre dos líneas llegue a CERO dentro de N barras ──
// Tiempo de primer paso de un movimiento Browniano con deriva contra una barrera.
//   d0    = brecha actual entre las dos líneas
//   drift = tendencia de esa brecha (¿se vienen acercando o alejando?)
//   sigma = volatilidad de los cambios de la brecha (el factor que más pesa)
//   N     = horizonte en barras del gráfico
// Es una fórmula cerrada, sin parámetros ajustados al pasado: si dos líneas están muy juntas y la brecha tiembla
// mucho, la probabilidad de que se toquen es alta, y viceversa. Devuelve na si no hay datos suficientes.
//
// CORRECCIÓN DE MONITOREO DISCRETO (Broadie-Glasserman-Kou, 1997)
// ---------------------------------------------------------------------------------------------------------------
// La fórmula cerrada es de tiempo CONTINUO: supone que el proceso puede tocar la barrera en cualquier instante.
// Pero acá un cruce se declara comparando CIERRES (igual que ta.crossover): si la brecha se hunde y vuelve dentro
// de la misma barra, no hubo cruce. La fórmula sin corregir cuenta esos caminos y sobreestima.
// Medido por Monte Carlo sobre 15 combinaciones de distancia y deriva, el sesgo medio era de 10,1 puntos
// porcentuales, y llegaba a 20 pp con las líneas cerca. La corrección consiste en correr la barrera hacia afuera
// una fracción de la volatilidad de una barra: a → a + β·σ, con β = -ζ(1/2)/√(2π) ≈ 0,5826. Con eso el sesgo medio
// baja a 0,5 pp. Es exacta en el límite y no tiene ningún parámetro que ajustar.
BGK_BETA = 0.5826

f_prob_formula(float d0, float drift, float sigma, int N) =>
    float _p = na
    if not na(d0) and not na(sigma) and sigma > 0 and N > 0
        float _absd = math.abs(d0) + BGK_BETA * sigma
        float _nu = drift * (d0 >= 0 ? 1.0 : -1.0)
        float _sq = sigma * math.sqrt(N)
        float _t1 = f_ncdf((-_absd - _nu * N) / _sq)
        float _ex = math.exp(math.max(-50.0, math.min(50.0, -2.0 * _nu * _absd / (sigma * sigma))))
        float _t2 = _ex * f_ncdf((-_absd + _nu * N) / _sq)
        _p := math.max(0.0, math.min(1.0, _t1 + _t2))
    _p

// ─── B1 · Encogimiento de la deriva por su propia relación señal-ruido ──
// La deriva se estima con dos puntos separados W barras, así que su error estándar es σ/√W. Cuando la deriva medida
// es chica frente a ese error, lo que se está midiendo es ruido, y meterlo en la fórmula como si fuera un dato firme
// produce probabilidades exageradas en los dos sentidos.
// El factor λ = 1 - (SE/deriva)² es el encogimiento clásico de James-Stein: deja intacta una deriva claramente mayor
// que su ruido, y aplasta a cero una que no se distingue de él. Sin perillas nuevas y sin decidir nada a mano.
// Esto importa porque los dos tipos de par se comportan al revés: en los pares MA↔MA la deriva es información real
// (sacarla derrumba el poder predictivo a la mitad), mientras que en los pares precio↔MA es casi puro ruido. El
// encogimiento distingue los dos casos solo, barra a barra, sin que haya que decirle cuál es cuál.
f_shrink_drift(float drift, float sigma, simple int w) =>
    float _out = na
    if not na(drift) and not na(sigma) and w > 0
        float _se2 = sigma * sigma / w
        float _d2  = drift * drift
        float _lam = _d2 > 0 ? math.max(0.0, 1.0 - _se2 / _d2) : 0.0
        _out := _lam * drift
    _out

// ─── B1 · Barra aproximada y zona de precios del cruce, si el ritmo actual se mantiene ──
// Devuelve [barra≈, borde inferior de la zona, borde superior]. La zona se ensancha con √tiempo, igual que el cono:
// cuanto más lejos está el cruce, menos se puede precisar dónde ocurriría.
f_cruce(float d0, float drift, float sig, float l2v, float l2s, int N, float band) =>
    float _ts = not na(drift) and drift != 0 and not na(d0) ? -d0 / drift : na
    float _bn = na
    float _lo = na
    float _hi = na
    if not na(_ts) and _ts > 0 and _ts <= 999 and not na(l2v) and not na(l2s)
        float _cen = l2v + l2s * _ts
        float _hw = band * nz(sig) * math.sqrt(math.min(_ts, N))
        _bn := math.ceil(_ts)
        _lo := _cen - _hw
        _hi := _cen + _hw
    [_bn, _lo, _hi]

// ─── Descripción técnica y color de cada MA (para las tablas: "EMA(50) 1D") ──
string _desc1 = ma1_type + "(" + str.tostring(ma1_len) + ") " + display_tf(ma1_tf)
string _desc2 = ma2_type + "(" + str.tostring(ma2_len) + ") " + display_tf(ma2_tf)
string _desc3 = ma3_type + "(" + str.tostring(ma3_len) + ") " + display_tf(ma3_tf)
string _desc4 = ma4_type + "(" + str.tostring(ma4_len) + ") " + display_tf(ma4_tf)
string _desc5 = ma5_type + "(" + str.tostring(ma5_len) + ") " + display_tf(ma5_tf)

f_desc_name(simple string n) =>
    n == "MA 1" ? _desc1 : n == "MA 2" ? _desc2 : n == "MA 3" ? _desc3 : n == "MA 4" ? _desc4 : n == "MA 5" ? _desc5 : "?"

f_desc_color(simple string n) =>
    n == "MA 1" ? ma1_col : n == "MA 2" ? ma2_col : n == "MA 3" ? ma3_col : n == "MA 4" ? ma4_col : n == "MA 5" ? ma5_col : color.gray


// =====================================================================================================================
// SECCIÓN 11 — MÉTRICAS POR MA: RITMO (pendiente), VOLATILIDAD Y BARRAS DESDE EL ÚLTIMO CRUCE
// ---------------------------------------------------------------------------------------------------------------------
// Se calculan una sola vez y las consumen tres módulos: la tabla resumen (columnas Ritmo y Últ. cruce), el cono de
// proyección (centro y ancho) y la probabilidad de cruce (dónde estaría la línea lenta al momento del cruce).
// Todo es global e incondicional: las ta.* y las referencias históricas necesitan evaluarse en todas las barras.
// =====================================================================================================================

// Ritmo de cada MA en precio por barra
float slp_ma1 = (v_ma1 - v_ma1[w_slope]) / w_slope
float slp_ma2 = (v_ma2 - v_ma2[w_slope]) / w_slope
float slp_ma3 = (v_ma3 - v_ma3[w_slope]) / w_slope
float slp_ma4 = (v_ma4 - v_ma4[w_slope]) / w_slope
float slp_ma5 = (v_ma5 - v_ma5[w_slope]) / w_slope

f_slope_name(simple string n) =>
    n == "MA 1" ? slp_ma1 : n == "MA 2" ? slp_ma2 : n == "MA 3" ? slp_ma3 : n == "MA 4" ? slp_ma4 : n == "MA 5" ? slp_ma5 : na

// Ritmo en % del propio valor de la MA por barra: comparable entre activos y entre temporalidades
f_rate_pct(float ma_v, float slope) =>
    (not na(ma_v) and ma_v != 0 and not na(slope)) ? slope / ma_v * 100.0 : na

float rate_ma1 = f_rate_pct(v_ma1, slp_ma1)
float rate_ma2 = f_rate_pct(v_ma2, slp_ma2)
float rate_ma3 = f_rate_pct(v_ma3, slp_ma3)
float rate_ma4 = f_rate_pct(v_ma4, slp_ma4)
float rate_ma5 = f_rate_pct(v_ma5, slp_ma5)

// Volatilidad de cada MA (para el ancho del cono)
float sig_ma1 = ta.stdev(v_ma1 - v_ma1[1], w_vol)
float sig_ma2 = ta.stdev(v_ma2 - v_ma2[1], w_vol)
float sig_ma3 = ta.stdev(v_ma3 - v_ma3[1], w_vol)
float sig_ma4 = ta.stdev(v_ma4 - v_ma4[1], w_vol)
float sig_ma5 = ta.stdev(v_ma5 - v_ma5[1], w_vol)

// Barras desde el último cruce del precio con cada MA (na mientras nunca haya cruzado)
float lx_ma1 = ta.barssince(xany_ma1)
float lx_ma2 = ta.barssince(xany_ma2)
float lx_ma3 = ta.barssince(xany_ma3)
float lx_ma4 = ta.barssince(xany_ma4)
float lx_ma5 = ta.barssince(xany_ma5)


// =====================================================================================================================
// SECCIÓN 12 — A2 · ALINEACIÓN DE LAS MAs ("ABANICO")
// ---------------------------------------------------------------------------------------------------------------------
// Ordena las MAs de la más RÁPIDA a la más LENTA y revisa si sus valores quedan apilados en ese mismo orden. Abanico
// alcista = la más rápida arriba de todas y la más lenta abajo. Abanico bajista = exactamente al revés. Cualquier
// enredo entre medio = mixto. Un abanico limpio es la firma clásica de una tendencia fuerte, y su ruptura suele
// anticipar el final del movimiento.
//
// CRITERIO DE ORDEN: no se ordena por longitud, sino por TIEMPO CUBIERTO = longitud × duración de su temporalidad.
// Ordenar por longitud sola sería un error en cuanto el usuario mezcla temporalidades: una EMA(8) semanal cubre casi
// dos meses y es mucho más lenta que una SMA(200) de 5 minutos, que cubre menos de un día. Con todas las MAs en la
// misma temporalidad —el caso por defecto— este criterio da exactamente el mismo orden que la longitud.
// Se calcula solo en la última barra (es lo único que se dibuja) para no gastar cómputo en todo el histórico.
// =====================================================================================================================

// Duración en segundos de la temporalidad de cada MA (vacío = la del gráfico)
int _tfs_ma1 = ma1_tf == "" ? timeframe.in_seconds() : timeframe.in_seconds(ma1_tf)
int _tfs_ma2 = ma2_tf == "" ? timeframe.in_seconds() : timeframe.in_seconds(ma2_tf)
int _tfs_ma3 = ma3_tf == "" ? timeframe.in_seconds() : timeframe.in_seconds(ma3_tf)
int _tfs_ma4 = ma4_tf == "" ? timeframe.in_seconds() : timeframe.in_seconds(ma4_tf)
int _tfs_ma5 = ma5_tf == "" ? timeframe.in_seconds() : timeframe.in_seconds(ma5_tf)

var int  fan_dir   = 0      // +1 alcista · -1 bajista · 0 sin definir
var bool fan_clean = false  // true = apilamiento perfecto
var int  fan_n     = 0      // MAs consideradas
var int  fan_above = 0      // cuántas MAs tiene el precio por encima

if barstate.islast
    array<float> _fan_key = array.from(ma1_len * 1.0 * _tfs_ma1, ma2_len * 1.0 * _tfs_ma2, ma3_len * 1.0 * _tfs_ma3, ma4_len * 1.0 * _tfs_ma4, ma5_len * 1.0 * _tfs_ma5)
    array<float> _fan_val = array.from(v_ma1, v_ma2, v_ma3, v_ma4, v_ma5)
    array<bool>  _fan_use = array.from(ma1_show or tbl_include_hidden, ma2_show or tbl_include_hidden, ma3_show or tbl_include_hidden, ma4_show or tbl_include_hidden, ma5_show or tbl_include_hidden)
    array<int>   _fan_ord = array.sort_indices(_fan_key, order.ascending)

    int  _prev = -1
    int  _dir  = 0
    bool _brk  = false
    int  _n    = 0
    int  _abv  = 0

    for _k = 0 to 4
        int _i = array.get(_fan_ord, _k)
        if array.get(_fan_use, _i) and not na(array.get(_fan_val, _i))
            _n += 1
            if close > array.get(_fan_val, _i)
                _abv += 1
            if _prev >= 0
                float _rapida = array.get(_fan_val, _prev)   // la de menos tiempo cubierto
                float _lenta  = array.get(_fan_val, _i)      // la inmediatamente más lenta
                int   _d = _rapida > _lenta ? 1 : _rapida < _lenta ? -1 : 0
                if _d == 0
                    _brk := true
                else if _dir == 0
                    _dir := _d
                else if _d != _dir
                    _brk := true
            _prev := _i

    fan_n     := _n
    fan_above := _abv
    fan_clean := _n >= 2 and not _brk and _dir != 0
    fan_dir   := fan_clean ? _dir : 0


// =====================================================================================================================
// SECCIÓN 13 — TABLA RESUMEN  (v1 ampliada)
// ---------------------------------------------------------------------------------------------------------------------
// Columnas: [Color, opcional] · Tipo · Longitud · Temporalidad · Distancia % · Distancia $ · [Ritmo] · [Últ. cruce]
// Signo de la distancia: positivo = precio SOBRE la MA; negativo = precio BAJO la MA.  ·  Orden fijo MA1 → MA5.
// Fila final opcional: alineación / abanico.
// Los ENCABEZADOS se traducen con tr() según el idioma elegido. El contenido es numérico/técnico (universal).
//
// NOTA DE ARQUITECTURA: en la v1 este bloque estaba en la SECCIÓN 8, antes de las alarmas. Se movió acá abajo, sin
// cambiar una sola línea de su lógica original, porque ahora necesita leer inputs (columnas nuevas) que —por
// compatibilidad de configuraciones guardadas— tienen que declararse después de los 98 inputs de la v1. Mover CÓDIGO
// no afecta a nadie; mover INPUTS sí. Por eso se movió el código y no las perillas.
// =====================================================================================================================

var table tbl = na

fill_row(table t, int row_idx, color line_color, string type_, int len, string tf_in, float ma_value, float rate_pct, float bars_x) =>
    float dist_pct = na
    float dist_abs = na
    if not na(ma_value) and ma_value != 0
        dist_abs := close - ma_value
        dist_pct := (close - ma_value) / ma_value * 100.0
    string s_pct = na(dist_pct) ? "—" : (dist_pct > 0 ? "+" : "") + str.tostring(dist_pct, "#.##") + "%"
    string s_abs = na(dist_abs) ? "—" : (dist_abs > 0 ? "+" : "") + str.tostring(dist_abs, format.mintick)
    string s_rate = "—"
    if not na(rate_pct)
        string _arrow = rate_pct > tbl_flat_pct ? "↗" : rate_pct < -tbl_flat_pct ? "↘" : "→"
        s_rate := _arrow + " " + (rate_pct > 0 ? "+" : "") + str.tostring(rate_pct, "#.###") + "%"
    string s_lastx = na(bars_x) ? "—" : str.tostring(int(bars_x))
    int col_idx = 0
    if tbl_show_color
        table.cell(t, col_idx, row_idx, "", bgcolor=line_color, text_color=line_color, text_size=resolve_text_size(tbl_size))
        col_idx += 1
    table.cell(t, col_idx, row_idx, type_,             bgcolor=tbl_bg_col, text_color=tbl_row_text, text_size=resolve_text_size(tbl_size))
    col_idx += 1
    table.cell(t, col_idx, row_idx, str.tostring(len), bgcolor=tbl_bg_col, text_color=tbl_row_text, text_size=resolve_text_size(tbl_size))
    col_idx += 1
    table.cell(t, col_idx, row_idx, display_tf(tf_in), bgcolor=tbl_bg_col, text_color=tbl_row_text, text_size=resolve_text_size(tbl_size))
    col_idx += 1
    table.cell(t, col_idx, row_idx, s_pct,             bgcolor=tbl_bg_col, text_color=tbl_row_text, text_size=resolve_text_size(tbl_size))
    col_idx += 1
    table.cell(t, col_idx, row_idx, s_abs,             bgcolor=tbl_bg_col, text_color=tbl_row_text, text_size=resolve_text_size(tbl_size))
    col_idx += 1
    if tbl_show_rate
        table.cell(t, col_idx, row_idx, s_rate,        bgcolor=tbl_bg_col, text_color=tbl_row_text, text_size=resolve_text_size(tbl_size))
        col_idx += 1
    if tbl_show_lastx
        table.cell(t, col_idx, row_idx, s_lastx,       bgcolor=tbl_bg_col, text_color=tbl_row_text, text_size=resolve_text_size(tbl_size))

if barstate.islast and tbl_show
    int n_cols = (tbl_show_color ? 1 : 0) + 5 + (tbl_show_rate ? 1 : 0) + (tbl_show_lastx ? 1 : 0)
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(resolve_table_position(tbl_position), n_cols, 8, bgcolor=tbl_bg_col, border_color=tbl_border_col, border_width=1)

    // ─── Encabezado (fila 0) — traducido según idioma ───
    int hcol = 0
    if tbl_show_color
        table.cell(tbl, hcol, 0, " ", bgcolor=tbl_header_bg, text_color=tbl_header_text, text_size=resolve_text_size(tbl_size))
        hcol += 1
    table.cell(tbl, hcol, 0, tr("Type","Tipo","Tipo"),                          bgcolor=tbl_header_bg, text_color=tbl_header_text, text_size=resolve_text_size(tbl_size))
    hcol += 1
    table.cell(tbl, hcol, 0, tr("Length","Longitud","Comprimento"),             bgcolor=tbl_header_bg, text_color=tbl_header_text, text_size=resolve_text_size(tbl_size))
    hcol += 1
    table.cell(tbl, hcol, 0, tr("Timeframe","Temporalidad","Tempo Gráfico"),    bgcolor=tbl_header_bg, text_color=tbl_header_text, text_size=resolve_text_size(tbl_size))
    hcol += 1
    table.cell(tbl, hcol, 0, "Dist. %",                                         bgcolor=tbl_header_bg, text_color=tbl_header_text, text_size=resolve_text_size(tbl_size))
    hcol += 1
    table.cell(tbl, hcol, 0, "Dist. $",                                         bgcolor=tbl_header_bg, text_color=tbl_header_text, text_size=resolve_text_size(tbl_size))
    hcol += 1
    if tbl_show_rate
        table.cell(tbl, hcol, 0, tr("Rate","Ritmo","Ritmo"),                    bgcolor=tbl_header_bg, text_color=tbl_header_text, text_size=resolve_text_size(tbl_size))
        hcol += 1
    if tbl_show_lastx
        table.cell(tbl, hcol, 0, tr("Last x","Últ. cruce","Últ. cruz."),        bgcolor=tbl_header_bg, text_color=tbl_header_text, text_size=resolve_text_size(tbl_size))

    // ─── Filas (orden fijo MA1 → MA5), respetando el toggle "incluir ocultas" ───
    int row_cursor = 1
    if ma1_show or tbl_include_hidden
        fill_row(tbl, row_cursor, ma1_col, ma1_type, ma1_len, ma1_tf, v_ma1, rate_ma1, lx_ma1)
        row_cursor += 1
    if ma2_show or tbl_include_hidden
        fill_row(tbl, row_cursor, ma2_col, ma2_type, ma2_len, ma2_tf, v_ma2, rate_ma2, lx_ma2)
        row_cursor += 1
    if ma3_show or tbl_include_hidden
        fill_row(tbl, row_cursor, ma3_col, ma3_type, ma3_len, ma3_tf, v_ma3, rate_ma3, lx_ma3)
        row_cursor += 1
    if ma4_show or tbl_include_hidden
        fill_row(tbl, row_cursor, ma4_col, ma4_type, ma4_len, ma4_tf, v_ma4, rate_ma4, lx_ma4)
        row_cursor += 1
    if ma5_show or tbl_include_hidden
        fill_row(tbl, row_cursor, ma5_col, ma5_type, ma5_len, ma5_tf, v_ma5, rate_ma5, lx_ma5)
        row_cursor += 1

    // ─── A2 · Fila de alineación (abanico) ───
    if tbl_show_align and row_cursor <= 7 and fan_n >= 2
        string _fan_verdict = tr("MIXED","MIXTO","MISTO")
        if fan_dir == 1
            _fan_verdict := tr("BULLISH FAN","ABANICO ALCISTA","LEQUE DE ALTA")
        else if fan_dir == -1
            _fan_verdict := tr("BEARISH FAN","ABANICO BAJISTA","LEQUE DE BAIXA")
        string _fan_txt = tr("Fan","Abanico","Leque") + ": " + _fan_verdict
        _fan_txt := _fan_txt + "  ·  " + tr("price above","precio sobre","preço acima")
        _fan_txt := _fan_txt + " " + str.tostring(fan_above) + "/" + str.tostring(fan_n)
        color _fan_bg = fan_dir == 1 ? color.new(#26A69A, 65) : fan_dir == -1 ? color.new(#EF5350, 65) : color.new(color.gray, 65)
        for _c = 0 to n_cols - 1
            table.cell(tbl, _c, row_cursor, _c == 0 ? _fan_txt : "", bgcolor=_fan_bg, text_color=tbl_row_text, text_size=resolve_text_size(tbl_size))
        if n_cols > 1
            table.merge_cells(tbl, 0, row_cursor, n_cols - 1, row_cursor)


// =====================================================================================================================
// SECCIÓN 14 — GC · GOLDEN CROSS / DEATH CROSS
// ---------------------------------------------------------------------------------------------------------------------
// El cruce más seguido del análisis técnico. Con los valores de fábrica de este indicador, MA 3 = EMA(50) y
// MA 5 = SMA(200), así que el par por defecto (MA 3 ↔ MA 5) es exactamente el cruce clásico 50/200.
// Respeta la banda anti-ruido: si está activa, el cruce se declara solo cuando las dos medias se separan de verdad.
// Se dibuja con label.new y no con plotshape, por dos motivos: (a) plotshape consume el presupuesto de 64 "plots" de
// TradingView, y (b) plotshape exige un tamaño constante, así que no podría configurarse desde una perilla.
// =====================================================================================================================

float gc_v_fast = get_ma_value_by_name(gc_fast)
float gc_v_slow = get_ma_value_by_name(gc_slow)

int  _stb_gc = f_dir_band(gc_v_fast, gc_v_slow, f_band)
bool _co_gc  = ta.crossover(gc_v_fast, gc_v_slow)
bool _cu_gc  = ta.crossunder(gc_v_fast, gc_v_slow)

bool _raw_golden = band_on ? (_stb_gc == 1 and _stb_gc[1] == -1) : _co_gc
bool _raw_death  = band_on ? (_stb_gc == -1 and _stb_gc[1] == 1) : _cu_gc

bool gc_golden = gc_on and _raw_golden
bool gc_death  = gc_on and _raw_death

if gc_golden
    label.new(bar_index, low,
         gc_txt ? tr("Golden Cross", "Cruce Dorado", "Cruz Dourada") : "",
         style     = gc_txt ? label.style_label_up : label.style_triangleup,
         color     = gc_col_g,
         textcolor = gc_col_t,
         yloc      = yloc.belowbar,
         size      = resolve_text_size(gc_size))
    if gc_line
        line.new(bar_index, low, bar_index, high == low ? low + syminfo.mintick : high, extend=extend.both, color=color.new(gc_col_g, 45), style=line.style_dashed, width=1)

if gc_death
    label.new(bar_index, high,
         gc_txt ? tr("Death Cross", "Cruce de la Muerte", "Cruz da Morte") : "",
         style     = gc_txt ? label.style_label_down : label.style_triangledown,
         color     = gc_col_d,
         textcolor = gc_col_t,
         yloc      = yloc.abovebar,
         size      = resolve_text_size(gc_size))
    if gc_line
        line.new(bar_index, low, bar_index, high == low ? low + syminfo.mintick : high, extend=extend.both, color=color.new(gc_col_d, 45), style=line.style_dashed, width=1)


// =====================================================================================================================
// SECCIÓN 15 — A3 · RELLENO ENTRE DOS MAs
// ---------------------------------------------------------------------------------------------------------------------
// fill() necesita identificadores de plot fijados en tiempo de compilación, y acá las dos MAs las elige el usuario con
// un dropdown. La solución es crear dos plots auxiliares que transportan el valor de las MAs elegidas y rellenar entre
// ellos. Cuestan 2 de los 64 plots disponibles (el script pasa de 5 a 7).
// Los plots se hacen invisibles con COLOR 100% TRANSPARENTE, y no con display=display.none: un plot oculto por completo
// no es un soporte confiable para fill(). Con display=display.pane el plot sigue existiendo en el panel (donde es
// transparente, así que no se ve) pero desaparece de la línea de estado y de la ventana de datos, que es justo lo que
// se busca: relleno visible, cero ruido en la leyenda.
// =====================================================================================================================

float fil_v_a = get_ma_value_by_name(fil_a)
float fil_v_b = get_ma_value_by_name(fil_b)

p_fil_a = plot(fil_on ? fil_v_a : na, "Fill A", color=color.new(color.gray, 100), display=display.pane, editable=false)
p_fil_b = plot(fil_on ? fil_v_b : na, "Fill B", color=color.new(color.gray, 100), display=display.pane, editable=false)

fill(p_fil_a, p_fil_b,
     color = (not na(fil_v_a) and not na(fil_v_b) and fil_v_a >= fil_v_b) ? color.new(fil_c_up, fil_tr) : color.new(fil_c_dn, fil_tr),
     title = "Fill between MAs / Relleno entre MAs / Preenchimento entre MMs")


// =====================================================================================================================
// SECCIÓN 16 — A4 · CONO DE PROYECCIÓN DE LAS MAs
// ---------------------------------------------------------------------------------------------------------------------
// Proyecta cada MA hacia adelante siguiendo su ritmo actual, dentro de un cono cuyo ancho crece con √tiempo. Es la
// forma honesta de dibujar un pronóstico: una línea sola sugiere una precisión que no existe; el cono muestra la
// banda de lo posible, más ancha cuanto más lejos se mira. Es un escenario de "si todo sigue igual", no una predicción.
// Se redibuja completo en cada última barra: se borran los objetos anteriores antes de crear los nuevos.
// =====================================================================================================================

f_draw_cono(array<polyline> pls, array<line> lns, bool activo, float ma_now, float slope, float sigma, color col, int N, float band, int opac, bool center) =>
    if activo and not na(ma_now) and not na(slope) and not na(sigma)
        array<chart.point> _pts = array.new<chart.point>()
        for _k = 0 to N
            float _c = ma_now + slope * _k
            float _w = band * sigma * math.sqrt(_k)
            array.push(_pts, chart.point.from_index(bar_index + _k, _c + _w))
        for _k = N to 0
            float _c = ma_now + slope * _k
            float _w = band * sigma * math.sqrt(_k)
            array.push(_pts, chart.point.from_index(bar_index + _k, _c - _w))
        polyline _pl = polyline.new(_pts, curved=true, closed=true, line_color=color.new(col, 55), fill_color=color.new(col, opac))
        array.push(pls, _pl)
        if center
            line _ln = line.new(bar_index, ma_now, bar_index + N, ma_now + slope * N, color=col, style=line.style_dashed, width=1)
            array.push(lns, _ln)

var array<polyline> _conos   = array.new<polyline>()
var array<line>     _centros = array.new<line>()

if proj_show and barstate.islast
    for _pl in _conos
        polyline.delete(_pl)
    array.clear(_conos)
    for _ln in _centros
        line.delete(_ln)
    array.clear(_centros)
    f_draw_cono(_conos, _centros, proj_ma1 and ma1_show, v_ma1, slp_ma1, sig_ma1, ma1_col, proj_bars, proj_band, proj_opacity, proj_center)
    f_draw_cono(_conos, _centros, proj_ma2 and ma2_show, v_ma2, slp_ma2, sig_ma2, ma2_col, proj_bars, proj_band, proj_opacity, proj_center)
    f_draw_cono(_conos, _centros, proj_ma3 and ma3_show, v_ma3, slp_ma3, sig_ma3, ma3_col, proj_bars, proj_band, proj_opacity, proj_center)
    f_draw_cono(_conos, _centros, proj_ma4 and ma4_show, v_ma4, slp_ma4, sig_ma4, ma4_col, proj_bars, proj_band, proj_opacity, proj_center)
    f_draw_cono(_conos, _centros, proj_ma5 and ma5_show, v_ma5, slp_ma5, sig_ma5, ma5_col, proj_bars, proj_band, proj_opacity, proj_center)


// =====================================================================================================================
// SECCIÓN 17 — B1 · PROBABILIDAD DE CRUCE
// ---------------------------------------------------------------------------------------------------------------------
// Para cada uno de los 10 pares (5 Precio↔MA y los 5 slots MA↔MA) se mide la brecha, su tendencia y su volatilidad, y
// se estima la probabilidad de que la brecha llegue a cero dentro del horizonte elegido.
// La BARRA y la ZONA del cruce solo se muestran cuando la probabilidad supera el umbral: si el cruce no es probable,
// mostrar un precio exacto para él sería vender una precisión que no existe.
// Los 5 pares MA↔MA son los definidos por los dropdowns de los slots de alarmas, estén esas alarmas activadas o no.
// =====================================================================================================================

// ─── VENTANA DE LA VOLATILIDAD A ESCALA DEL HORIZONTE ───────────────────────────────────────────────────────────
// Los cambios de una brecha entre dos medias NO son independientes entre sí: la diferencia de dos promedios es una
// curva suave, no un paseo aleatorio. Medido sobre 400.000 barras simuladas, la autocorrelación de esos cambios es
// de +0,96 en un par MA↔MA (y de 0,00 en un par precio↔MA, donde el problema no existe).
// Consecuencia: estimar σ con cambios de UNA barra y escalarlo por √N subestima la dispersión real a N barras por un
// factor cercano a 3, y eso hace que extrapolar la deriva parezca mucho más seguro de lo que es. De ahí las
// probabilidades del 98% que se cumplían dos de cada tres veces.
// La corrección es medir la dispersión directamente A LA ESCALA DEL HORIZONTE —el desvío de los cambios de N
// barras— y recién después dividir por √N. Así la autocorrelación queda absorbida por la propia medición.
// La ventana tiene que ser larga: con cambios de N barras solapados, una ventana corta mete ruido propio y empeora
// los pares precio↔MA, donde σ de una barra ya era correcto. 3×w_vol (60 por defecto) resultó el mejor compromiso
// probado; el piso de 4×horizonte garantiza muestra suficiente si se acorta la ventana de volatilidad.
// Se declara `simple int` a propósito: ta.stdev exige que la longitud sea simple, y con el ternario en vez de
// math.max no hay ninguna duda de que el resultado conserva el tipo y el calificador.
simple int w_vr = w_vol * 3 > prob_horizon * 4 ? w_vol * 3 : prob_horizon * 4

// Brecha, tendencia de la brecha y volatilidad de la brecha — Precio↔MA
float d0_p1 = close - v_ma1
float d0_p2 = close - v_ma2
float d0_p3 = close - v_ma3
float d0_p4 = close - v_ma4
float d0_p5 = close - v_ma5

float dr_p1 = (d0_p1 - d0_p1[w_slope]) / w_slope
float dr_p2 = (d0_p2 - d0_p2[w_slope]) / w_slope
float dr_p3 = (d0_p3 - d0_p3[w_slope]) / w_slope
float dr_p4 = (d0_p4 - d0_p4[w_slope]) / w_slope
float dr_p5 = (d0_p5 - d0_p5[w_slope]) / w_slope

float sg_p1 = ta.stdev(d0_p1 - d0_p1[prob_horizon], w_vr) / math.sqrt(prob_horizon)
float sg_p2 = ta.stdev(d0_p2 - d0_p2[prob_horizon], w_vr) / math.sqrt(prob_horizon)
float sg_p3 = ta.stdev(d0_p3 - d0_p3[prob_horizon], w_vr) / math.sqrt(prob_horizon)
float sg_p4 = ta.stdev(d0_p4 - d0_p4[prob_horizon], w_vr) / math.sqrt(prob_horizon)
float sg_p5 = ta.stdev(d0_p5 - d0_p5[prob_horizon], w_vr) / math.sqrt(prob_horizon)

// Deriva encogida por su relación señal-ruido (ver f_shrink_drift). Es la que alimenta tanto la
// probabilidad como la estimación de la barra del cruce, para que las dos columnas no se contradigan.
float ds_p1 = f_shrink_drift(dr_p1, sg_p1, w_slope)
float ds_p2 = f_shrink_drift(dr_p2, sg_p2, w_slope)
float ds_p3 = f_shrink_drift(dr_p3, sg_p3, w_slope)
float ds_p4 = f_shrink_drift(dr_p4, sg_p4, w_slope)
float ds_p5 = f_shrink_drift(dr_p5, sg_p5, w_slope)

float pA_p1 = f_prob_formula(d0_p1, ds_p1, sg_p1, prob_horizon)
float pA_p2 = f_prob_formula(d0_p2, ds_p2, sg_p2, prob_horizon)
float pA_p3 = f_prob_formula(d0_p3, ds_p3, sg_p3, prob_horizon)
float pA_p4 = f_prob_formula(d0_p4, ds_p4, sg_p4, prob_horizon)
float pA_p5 = f_prob_formula(d0_p5, ds_p5, sg_p5, prob_horizon)

// Brecha, tendencia y volatilidad — MA↔MA (los 5 slots)
float d0_s1 = s1_fast - s1_slow
float d0_s2 = s2_fast - s2_slow
float d0_s3 = s3_fast - s3_slow
float d0_s4 = s4_fast - s4_slow
float d0_s5 = s5_fast - s5_slow

float dr_s1 = (d0_s1 - d0_s1[w_slope]) / w_slope
float dr_s2 = (d0_s2 - d0_s2[w_slope]) / w_slope
float dr_s3 = (d0_s3 - d0_s3[w_slope]) / w_slope
float dr_s4 = (d0_s4 - d0_s4[w_slope]) / w_slope
float dr_s5 = (d0_s5 - d0_s5[w_slope]) / w_slope

float sg_s1 = ta.stdev(d0_s1 - d0_s1[prob_horizon], w_vr) / math.sqrt(prob_horizon)
float sg_s2 = ta.stdev(d0_s2 - d0_s2[prob_horizon], w_vr) / math.sqrt(prob_horizon)
float sg_s3 = ta.stdev(d0_s3 - d0_s3[prob_horizon], w_vr) / math.sqrt(prob_horizon)
float sg_s4 = ta.stdev(d0_s4 - d0_s4[prob_horizon], w_vr) / math.sqrt(prob_horizon)
float sg_s5 = ta.stdev(d0_s5 - d0_s5[prob_horizon], w_vr) / math.sqrt(prob_horizon)

// Deriva encogida por su relación señal-ruido (ver f_shrink_drift). Es la que alimenta tanto la
// probabilidad como la estimación de la barra del cruce, para que las dos columnas no se contradigan.
float ds_s1 = f_shrink_drift(dr_s1, sg_s1, w_slope)
float ds_s2 = f_shrink_drift(dr_s2, sg_s2, w_slope)
float ds_s3 = f_shrink_drift(dr_s3, sg_s3, w_slope)
float ds_s4 = f_shrink_drift(dr_s4, sg_s4, w_slope)
float ds_s5 = f_shrink_drift(dr_s5, sg_s5, w_slope)

float pA_s1 = f_prob_formula(d0_s1, ds_s1, sg_s1, prob_horizon)
float pA_s2 = f_prob_formula(d0_s2, ds_s2, sg_s2, prob_horizon)
float pA_s3 = f_prob_formula(d0_s3, ds_s3, sg_s3, prob_horizon)
float pA_s4 = f_prob_formula(d0_s4, ds_s4, sg_s4, prob_horizon)
float pA_s5 = f_prob_formula(d0_s5, ds_s5, sg_s5, prob_horizon)

// Barra y zona de precios estimadas del cruce (la "línea 2" de cada par es la barrera)
[bn_p1, lo_p1, hi_p1] = f_cruce(d0_p1, ds_p1, sg_p1, v_ma1, slp_ma1, prob_horizon, xp_band)
[bn_p2, lo_p2, hi_p2] = f_cruce(d0_p2, ds_p2, sg_p2, v_ma2, slp_ma2, prob_horizon, xp_band)
[bn_p3, lo_p3, hi_p3] = f_cruce(d0_p3, ds_p3, sg_p3, v_ma3, slp_ma3, prob_horizon, xp_band)
[bn_p4, lo_p4, hi_p4] = f_cruce(d0_p4, ds_p4, sg_p4, v_ma4, slp_ma4, prob_horizon, xp_band)
[bn_p5, lo_p5, hi_p5] = f_cruce(d0_p5, ds_p5, sg_p5, v_ma5, slp_ma5, prob_horizon, xp_band)
[bn_s1, lo_s1, hi_s1] = f_cruce(d0_s1, ds_s1, sg_s1, s1_slow, f_slope_name(slot1_slow), prob_horizon, xp_band)
[bn_s2, lo_s2, hi_s2] = f_cruce(d0_s2, ds_s2, sg_s2, s2_slow, f_slope_name(slot2_slow), prob_horizon, xp_band)
[bn_s3, lo_s3, hi_s3] = f_cruce(d0_s3, ds_s3, sg_s3, s3_slow, f_slope_name(slot3_slow), prob_horizon, xp_band)
[bn_s4, lo_s4, hi_s4] = f_cruce(d0_s4, ds_s4, sg_s4, s4_slow, f_slope_name(slot4_slow), prob_horizon, xp_band)
[bn_s5, lo_s5, hi_s5] = f_cruce(d0_s5, ds_s5, sg_s5, s5_slow, f_slope_name(slot5_slow), prob_horizon, xp_band)

f_ppct(float x) => na(x) ? "—" : str.tostring(x * 100.0, "#") + "%"

var table tprob = na
if prob_show and barstate.islast
    if not na(tprob)
        table.delete(tprob)
    int _pn = prob_xprice ? 6 : 4
    tprob := table.new(resolve_table_position(prob_pos), _pn, 11, border_width=1, border_color=color.new(color.gray, 40))

    table.cell(tprob, 0, 0, tr("Line 1","Línea 1","Linha 1"),   text_color=prob_col_tx, bgcolor=prob_col_hd, text_size=resolve_text_size(prob_size))
    table.cell(tprob, 1, 0, tr("Line 2","Línea 2","Linha 2"),   text_color=prob_col_tx, bgcolor=prob_col_hd, text_size=resolve_text_size(prob_size))
    table.cell(tprob, 2, 0, "Dir",                              text_color=prob_col_tx, bgcolor=prob_col_hd, text_size=resolve_text_size(prob_size))
    table.cell(tprob, 3, 0, "Prob.",                            text_color=prob_col_tx, bgcolor=prob_col_hd, text_size=resolve_text_size(prob_size))
    if prob_xprice
        table.cell(tprob, 4, 0, tr("Bar","Barra","Barra"),      text_color=prob_col_tx, bgcolor=prob_col_hd, text_size=resolve_text_size(prob_size))
        table.cell(tprob, 5, 0, tr("Zone $","Zona $","Zona $"), text_color=prob_col_tx, bgcolor=prob_col_hd, text_size=resolve_text_size(prob_size))

    // Cada par se parte en dos celdas (una por línea) para respetar el color de cada MA en el gráfico
    string _px_lbl = tr("Price","Precio","Preço")
    string _vs     = "vs "   // universal en los tres idiomas: no pasa por tr()
    array<string> _nom1 = array.from(_px_lbl, _px_lbl, _px_lbl, _px_lbl, _px_lbl, f_desc_name(slot1_fast), f_desc_name(slot2_fast), f_desc_name(slot3_fast), f_desc_name(slot4_fast), f_desc_name(slot5_fast))
    array<color>  _col1 = array.from(prob_col_tx, prob_col_tx, prob_col_tx, prob_col_tx, prob_col_tx, f_desc_color(slot1_fast), f_desc_color(slot2_fast), f_desc_color(slot3_fast), f_desc_color(slot4_fast), f_desc_color(slot5_fast))
    array<string> _nom2 = array.from(_vs + _desc1, _vs + _desc2, _vs + _desc3, _vs + _desc4, _vs + _desc5, _vs + f_desc_name(slot1_slow), _vs + f_desc_name(slot2_slow), _vs + f_desc_name(slot3_slow), _vs + f_desc_name(slot4_slow), _vs + f_desc_name(slot5_slow))
    array<color>  _col2 = array.from(ma1_col, ma2_col, ma3_col, ma4_col, ma5_col, f_desc_color(slot1_slow), f_desc_color(slot2_slow), f_desc_color(slot3_slow), f_desc_color(slot4_slow), f_desc_color(slot5_slow))
    array<float>  _gapA = array.from(d0_p1, d0_p2, d0_p3, d0_p4, d0_p5, d0_s1, d0_s2, d0_s3, d0_s4, d0_s5)
    array<float>  _prbA = array.from(pA_p1, pA_p2, pA_p3, pA_p4, pA_p5, pA_s1, pA_s2, pA_s3, pA_s4, pA_s5)
    array<float>  _bnA  = array.from(bn_p1, bn_p2, bn_p3, bn_p4, bn_p5, bn_s1, bn_s2, bn_s3, bn_s4, bn_s5)
    array<float>  _loA  = array.from(lo_p1, lo_p2, lo_p3, lo_p4, lo_p5, lo_s1, lo_s2, lo_s3, lo_s4, lo_s5)
    array<float>  _hiA  = array.from(hi_p1, hi_p2, hi_p3, hi_p4, hi_p5, hi_s1, hi_s2, hi_s3, hi_s4, hi_s5)

    for _i = 0 to 9
        int   _row = _i + 1
        float _g   = array.get(_gapA, _i)
        float _p   = array.get(_prbA, _i)
        string _dir = na(_g) ? "—" : _g >= 0 ? "↓" : "↑"
        bool  _showx = not na(_p) and _p * 100.0 >= prob_umbral
        color _cp = _showx ? prob_col_hi : prob_col_lo
        table.cell(tprob, 0, _row, array.get(_nom1, _i), text_color=array.get(_col1, _i), bgcolor=prob_col_hd, text_size=resolve_text_size(prob_size))
        table.cell(tprob, 1, _row, array.get(_nom2, _i), text_color=array.get(_col2, _i), bgcolor=prob_col_hd, text_size=resolve_text_size(prob_size))
        table.cell(tprob, 2, _row, _dir,                 text_color=prob_col_tx,          bgcolor=prob_col_hd, text_size=resolve_text_size(prob_size))
        table.cell(tprob, 3, _row, f_ppct(_p),           text_color=prob_col_tx,          bgcolor=_cp,         text_size=resolve_text_size(prob_size))
        if prob_xprice
            float _bn = array.get(_bnA, _i)
            float _lo = array.get(_loA, _i)
            float _hi = array.get(_hiA, _i)
            string _sbar  = _showx and not na(_bn) ? "≈" + str.tostring(int(_bn)) : "—"
            string _szona = _showx and not na(_lo) and not na(_hi) ? str.tostring(_lo, format.mintick) + "–" + str.tostring(_hi, format.mintick) : "—"
            table.cell(tprob, 4, _row, _sbar,  text_color=prob_col_tx, bgcolor=prob_col_hd, text_size=resolve_text_size(prob_size))
            table.cell(tprob, 5, _row, _szona, text_color=prob_col_tx, bgcolor=prob_col_hd, text_size=resolve_text_size(prob_size))


// =====================================================================================================================
// SECCIÓN 18 — ALARMAS NUEVAS DE LA v2 (2)
// ---------------------------------------------------------------------------------------------------------------------
// Se declaran DESPUÉS de las 22 de la v1 y sin tocar ninguna de ellas, para que las alertas que los usuarios ya tengan
// creadas sigan apuntando exactamente a la misma condición.
// =====================================================================================================================

alertcondition(gc_golden, title="✨ Golden Cross / Cruce Dorado / Cruz Dourada",
     message="Golden Cross: the fast MA crossed above the slow MA · Cruce Dorado: la MA rápida cruzó por encima de la MA lenta · Cruz Dourada: a MM rápida cruzou acima da MM lenta — {{ticker}} @ {{close}}")
alertcondition(gc_death, title="💀 Death Cross / Cruce de la Muerte / Cruz da Morte",
     message="Death Cross: the fast MA crossed below the slow MA · Cruce de la Muerte: la MA rápida cruzó por debajo de la MA lenta · Cruz da Morte: a MM rápida cruzou abaixo da MM lenta — {{ticker}} @ {{close}}")


// =====================================================================================================================
// FIN / END / FIM
// =====================================================================================================================
````
