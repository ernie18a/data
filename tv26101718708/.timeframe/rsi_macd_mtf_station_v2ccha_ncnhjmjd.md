# RSI & MACD MTF Station [v2c_cha]

- url: https://www.tradingview.com/script/ncNhjmJD-RSI-MACD-MTF-Station-v2c-cha/
- type: indicator
- pine_id: PUB;fef3307407f94ba18c904bb670308a0a
- version: 1.0

## Description

Overview
The RSI & MACD MTF Heatmap Station is a comprehensive, all-in-one momentum and trend analysis tool designed to eliminate chart clutter. Traditionally, traders relying on Multi-Timeframe (MTF) analysis must either split their screens into multiple layouts or flood their indicator panels with overlapping "spaghetti" lines. This indicator solves that problem by consolidating the Relative Strength Index (RSI) and Moving Average Convergence Divergence (MACD) across 9 different timeframes into a single, compact visual Heatmap.

Core Concepts & Calculations
This indicator relies on the standard mathematical formulas for RSI (default 14 periods) and MACD (default 12, 26, 9). However, its core value lies in how it processes and displays this data:

Non-Repainting MTF Data: All higher-timeframe data is fetched using barmerge.lookahead_off and barmerge.gaps_off to ensure strict compliance with non-repainting rules. What you see on historical bars is exactly what would have printed in real-time.

Visual Anchoring: To display both the current RSI and current MACD lines harmoniously in the same pane without skewing the scale, the MACD line is mathematically anchored to the RSI's 50-level (neutral line).

[b]How to Read the Heatmap Dashboard[/b]
The dashboard is a 9-column by 3-row matrix located in the corner of your screen, covering timeframes from 1-minute to 1-Month.

Row 1 (RSI - Extreme Momentum): This row measures whether an asset is mathematically overbought or oversold.

🔴 Red (RSI >= 70): Overbought. The asset is extended to the upside in this specific timeframe.

🟢 Green (RSI <= 30): Oversold. The asset is extended to the downside.

⚫ Dark Gray (31-69): Neutral. The asset is flowing within normal momentum boundaries.

Row 2 (MACD - Trend Direction): This row measures the overarching trend control based on the MACD main line crossing the Zero line.

🟢 Green (MACD > 0): Bullish trend control.

🔴 Red (MACD < 0): Bearish trend control.

[b]Practical Trading Application (Top-Down Analysis)[/b]
This tool excels at spotting high-probability continuation setups by aligning the macro-trend with micro-momentum pullbacks.

Example Setup (The Buy Dip): A trader observing a 5-minute chart looks at the dashboard. The MACD row shows Green for the 1H and 4H timeframes, indicating a strong macro bullish trend. However, the RSI row shows Green (< 30) for the 5m and 15m timeframes. This tells the trader that while the macro trend is up, there is short-term panic/oversold conditions. This alignment provides a mathematical, rules-based area to look for long entries (buying the dip) in the direction of the macro trend.

Key Features & Customization

Fully Customizable: You can change the lengths and smoothing periods for both the RSI and MACD.

Dashboard Positioning: Move the heatmap to any corner of the screen to fit your layout.

Decluttered Charting: By default, only the current timeframe's RSI and MACD lines are plotted, while all MTF data is neatly organized inside the heatmap.

[b][i]Disclaimer: This indicator is for educational and analytical purposes only. It does not provide financial advice or guarantee profitable trades. Always combine momentum and trend indicators with proper risk management and price action analysis.[/i][/b]

## Source Code

````pine
// © Optimizacion v2c_cha
//@version=5
indicator("RSI & MACD MTF Station [v2c_cha]", shorttitle="MTF_Station", overlay=false)

// ══════════════════════════════════════════════
// 1. INPUTS — CONFIGURACIÓN CONJUNTA
// ══════════════════════════════════════════════
grpRSI = "Configuración RSI"
rsi_len = input.int(14, title="Longitud RSI", group=grpRSI)
src     = input.source(close, title="Fuente", group=grpRSI)

grpMACD = "Configuración MACD"
fast_len = input.int(12, title="Fast Length", group=grpMACD)
slow_len = input.int(26, title="Slow Length", group=grpMACD)
smooth   = input.int(9,  title="Signal Smoothing", group=grpMACD)

grpVis  = "Visualización del Panel"
showDash = input.bool(true, title="Mostrar Súper Panel de Calor", group=grpVis)
dashPos  = input.string("Top Right", "Posición del Panel", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpVis)

// ══════════════════════════════════════════════
// 2. FUNCIONES MATEMÁTICAS PURAS
// ══════════════════════════════════════════════
// Función RSI
getRsi() => ta.rsi(src, rsi_len)

// Función MACD (Solo la línea principal)
getMacd() =>
    [macdLine, signalLine, histLine] = ta.macd(src, fast_len, slow_len, smooth)
    macdLine

// ══════════════════════════════════════════════
// 3. CÁLCULOS MTF (Sin Repainting)
// ══════════════════════════════════════════════
// Valores RSI
rsiCur = getRsi()
rsi1m  = request.security(syminfo.tickerid, "1",   getRsi(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rsi5m  = request.security(syminfo.tickerid, "5",   getRsi(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rsi15m = request.security(syminfo.tickerid, "15",  getRsi(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rsi30m = request.security(syminfo.tickerid, "30",  getRsi(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rsi1h  = request.security(syminfo.tickerid, "60",  getRsi(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rsi4h  = request.security(syminfo.tickerid, "240", getRsi(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rsi1D  = request.security(syminfo.tickerid, "D",   getRsi(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rsi1W  = request.security(syminfo.tickerid, "W",   getRsi(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rsi1M  = request.security(syminfo.tickerid, "M",   getRsi(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Valores MACD
macCur = getMacd()
mac1m  = request.security(syminfo.tickerid, "1",   getMacd(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mac5m  = request.security(syminfo.tickerid, "5",   getMacd(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mac15m = request.security(syminfo.tickerid, "15",  getMacd(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mac30m = request.security(syminfo.tickerid, "30",  getMacd(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mac1h  = request.security(syminfo.tickerid, "60",  getMacd(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mac4h  = request.security(syminfo.tickerid, "240", getMacd(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mac1D  = request.security(syminfo.tickerid, "D",   getMacd(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mac1W  = request.security(syminfo.tickerid, "W",   getMacd(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mac1M  = request.security(syminfo.tickerid, "M",   getMacd(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ══════════════════════════════════════════════
// 4. PLOTS (Gráfico Principal del Oscilador)
// ══════════════════════════════════════════════
// Zonas RSI
h1 = hline(30, color=color.new(color.gray, 50), linestyle=hline.style_dashed)
h2 = hline(70, color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hline(50, color=color.new(color.gray, 50), linestyle=hline.style_dotted, title="Línea 50 (Cero MACD)")
fill(h1, h2, color=color.new(color.purple, 90), title="Zona Base RSI")

// Trazado: Para que el MACD se vea bien junto al RSI, lo "anclamos" visualmente a la línea 50.
plot(rsiCur, color=color.new(#00B2FF, 0), title="RSI Actual", linewidth=2)
plot(50 + macCur, color=color.new(#FF00FF, 0), title="MACD Actual (Anclado a 50)", linewidth=2)

// ══════════════════════════════════════════════
// 5. SÚPER PANEL DE CALOR (Dashboard Unificado)
// ══════════════════════════════════════════════
// Funciones de Color
bgRsi(val) => val >= 70 ? color.new(color.red, 40) : val <= 30 ? color.new(color.green, 40) : color.new(color.gray, 80)
bgMac(val) => val > 0 ? color.new(color.green, 40) : val < 0 ? color.new(color.red, 40) : color.new(color.gray, 80)

// Configuración de Posición
posTable = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left

// Crear Tabla (10 Columnas x 3 Filas)
var table dash = table.new(posTable, columns=10, rows=3, bgcolor=color.new(color.black, 100), frame_color=color.new(color.gray, 80), frame_width=1, border_color=color.new(color.gray, 80), border_width=1)

if barstate.islast and showDash
    // Fila 1: Encabezados de Temporalidad
    table.cell(dash, 0, 0, "MTF", text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(dash, 1, 0, "1m",  text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(dash, 2, 0, "5m",  text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(dash, 3, 0, "15m", text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(dash, 4, 0, "30m", text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(dash, 5, 0, "1H",  text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(dash, 6, 0, "4H",  text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(dash, 7, 0, "1D",  text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(dash, 8, 0, "1W",  text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(dash, 9, 0, "1M",  text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 20))
    
    // Fila 2: RSI (Momento Extremo)
    table.cell(dash, 0, 1, "RSI", text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 30))
    table.cell(dash, 1, 1, str.tostring(math.round(rsi1m)),  text_color=color.white, text_size=size.small, bgcolor=bgRsi(rsi1m))
    table.cell(dash, 2, 1, str.tostring(math.round(rsi5m)),  text_color=color.white, text_size=size.small, bgcolor=bgRsi(rsi5m))
    table.cell(dash, 3, 1, str.tostring(math.round(rsi15m)), text_color=color.white, text_size=size.small, bgcolor=bgRsi(rsi15m))
    table.cell(dash, 4, 1, str.tostring(math.round(rsi30m)), text_color=color.white, text_size=size.small, bgcolor=bgRsi(rsi30m))
    table.cell(dash, 5, 1, str.tostring(math.round(rsi1h)),  text_color=color.white, text_size=size.small, bgcolor=bgRsi(rsi1h))
    table.cell(dash, 6, 1, str.tostring(math.round(rsi4h)),  text_color=color.white, text_size=size.small, bgcolor=bgRsi(rsi4h))
    table.cell(dash, 7, 1, str.tostring(math.round(rsi1D)),  text_color=color.white, text_size=size.small, bgcolor=bgRsi(rsi1D))
    table.cell(dash, 8, 1, str.tostring(math.round(rsi1W)),  text_color=color.white, text_size=size.small, bgcolor=bgRsi(rsi1W))
    table.cell(dash, 9, 1, str.tostring(math.round(rsi1M)),  text_color=color.white, text_size=size.small, bgcolor=bgRsi(rsi1M))

    // Fila 3: MACD (Dirección de Tendencia)
    table.cell(dash, 0, 2, "MACD", text_color=color.white, text_size=size.small, bgcolor=color.new(color.maroon, 30))
    table.cell(dash, 1, 2, str.tostring(mac1m,  "#.##"), text_color=color.white, text_size=size.small, bgcolor=bgMac(mac1m))
    table.cell(dash, 2, 2, str.tostring(mac5m,  "#.##"), text_color=color.white, text_size=size.small, bgcolor=bgMac(mac5m))
    table.cell(dash, 3, 2, str.tostring(mac15m, "#.##"), text_color=color.white, text_size=size.small, bgcolor=bgMac(mac15m))
    table.cell(dash, 4, 2, str.tostring(mac30m, "#.##"), text_color=color.white, text_size=size.small, bgcolor=bgMac(mac30m))
    table.cell(dash, 5, 2, str.tostring(mac1h,  "#.##"), text_color=color.white, text_size=size.small, bgcolor=bgMac(mac1h))
    table.cell(dash, 6, 2, str.tostring(mac4h,  "#.##"), text_color=color.white, text_size=size.small, bgcolor=bgMac(mac4h))
    table.cell(dash, 7, 2, str.tostring(mac1D,  "#.##"), text_color=color.white, text_size=size.small, bgcolor=bgMac(mac1D))
    table.cell(dash, 8, 2, str.tostring(mac1W,  "#.##"), text_color=color.white, text_size=size.small, bgcolor=bgMac(mac1W))
    table.cell(dash, 9, 2, str.tostring(mac1M,  "#.##"), text_color=color.white, text_size=size.small, bgcolor=bgMac(mac1M))
````
