# RSI Pigo Fade

- url: https://www.tradingview.com/script/VVJOg391/
- type: indicator
- pine_id: PUB;a7c33a1a33594d17aac496889e800670
- version: 1.0

## Description

RSI Pigo Fade — Multi-Timeframe Extreme Detector

An indicator designed to detect extreme overbought and oversold conditions by 
combining traditional RSI with a statistical percentile (KDE-style) across 
two simultaneously configurable timeframes.

🎯 PURPOSE

Built specifically for traders looking to fade reversals at target zones 
(Fibonacci levels, prior session highs/lows, liquidity sweeps). It filters 
REAL RSI extremes from normal trending momentum by analyzing the statistical 
position of the current RSI relative to its own recent history.

📊 HOW IT WORKS

The indicator simultaneously analyzes two timeframes (configurable, default 
1m and 5m) and calculates two metrics for each:

1. Standard RSI (default 14 periods)
   Measures relative price strength on the selected timeframe.

2. KDE Extremity (simplified Kernel Density Estimation)
   Calculates how extreme the current RSI is compared to its last 100 
   historical values. Ranges from 0% (neutral) to 100% (absolute extreme).
   
   - 0% = current RSI sits at the historical median
   - 50% = current RSI is at the 25th or 75th percentile
   - 100% = current RSI is at the absolute extreme of recent history
   
   The metric uses ta.percentrank() to ensure consistency across different 
   timeframes. Values remain identical regardless of which chart you're 
   currently viewing.

🔔 SIGNALS

The indicator triggers alerts when both conditions are met simultaneously:

🔴 BOTH OVERBOUGHT
   - RSI ≥ upper threshold in both TFs
   - KDE Extremity ≥ defined threshold in both TFs
   - Suggests potential ceiling / SHORT candidate at target zones

🟢 BOTH OVERSOLD
   - RSI ≤ lower threshold in both TFs
   - KDE Extremity ≥ defined threshold in both TFs
   - Suggests potential floor / LONG candidate at target zones

Individual TF alerts are also available for early detection.

⚙️ RECOMMENDED CONFIGURATION

For assets with persistent trends (NQ, ES, S&P futures):
- RSI High: 75 / RSI Low: 25
- KDE TF1: 75% / KDE TF2: 65%

For assets with more predictable reversals (Gold, EUR/USD, swing trading):
- RSI High: 70 / RSI Low: 30
- KDE TF1: 70% / KDE TF2: 60%

Asymmetric thresholds (TF2 lower than TF1) reflect the fact that fast TFs 
reach extremes before slow ones. TF2 acts as confirmation — it doesn't need 
to reach the same absolute extreme as TF1.

📋 DASHBOARD

Real-time display:
- TF (configured timeframe)
- RSI value
- KDE % (statistical extremity)
- Aggregated status: BOTH OVERBOUGHT / BOTH OVERSOLD / Partial / Neutral

Values are color-coded based on conditions: coral red for overbought, 
turquoise green for oversold.

🎓 RECOMMENDED USE

This indicator is NOT an automatic entry trigger. It's a quality filter that 
confirms statistical extremes. For maximum effectiveness, combine with:

- Technical zone analysis (Fibonacci, prior support/resistance)
- Structural confirmation (BOS, FVGs, session manipulation)
- Multi-timeframe trend and extension indicators

BOTH signals are rare by design. Their scarcity is what makes them valuable.

⚠️ LIMITATIONS

- Requires ~30 seconds at load to build statistical history
- In markets breaking out from prolonged lateral ranges, may give premature 
  signals (KDE marks extreme but structurally it's nascent momentum). 
  Combine with trend analysis to avoid this trap.
- Does not work well in illiquid markets or those with large gaps

🔧 CUSTOMIZATION

All parameters are configurable: RSI length, KDE lookback, kernel type 
(Gaussian/Uniform/Sigmoid), bandwidth, dashboard position, colors. Adaptable 
to any instrument and operational timeframe.

═══════════════════════════════════════════════════════════════
Version: 1.0
Compatibility: Pine Script v6
Type: Overlay with dashboard
═══════════════════════════════════════════════════════════════

## Source Code

````pine
//@version=6
indicator("RSI Pigo Fade", shorttitle = "RSIPigo", overlay = true, dynamic_requests = true)

// ══════════════════════════════════════════════════════════════
// SETTINGS
// ══════════════════════════════════════════════════════════════
g_rsi = "RSI Settings"
rsiLen = input.int(14, "RSI Length", minval = 1, group = g_rsi)
rsiSrc = input.source(close, "Source", group = g_rsi)

g_mtf = "📊 Timeframes"
tf1 = input.timeframe("1", "TF1", group = g_mtf)
tf2 = input.timeframe("5", "TF2", group = g_mtf)

g_thresh = "🎯 Thresholds"
rsi_high = input.float(70.0, "RSI High Threshold", minval = 50, maxval = 95, step = 1, group = g_thresh)
rsi_low = input.float(30.0, "RSI Low Threshold", minval = 5, maxval = 50, step = 1, group = g_thresh)
kde_threshold_tf1 = input.float(75.0, "KDE Threshold TF1 (%)", minval = 1, maxval = 99, step = 1, group = g_thresh)
kde_threshold_tf2 = input.float(65.0, "KDE Threshold TF2 (%)", minval = 1, maxval = 99, step = 1, group = g_thresh)

g_kde = "KDE Settings"
kde_lookback = input.int(100, "KDE Lookback (bars)", minval = 30, maxval = 500, group = g_kde, tooltip = "Cuántas velas del propio TF se usan para calcular el KDE. 100 es estándar.")

g_dash = "Dashboard"
showTable = input.bool(true, "Show Dashboard", group = g_dash)
tablePos = input.string("Top Right", "Position", options = ["Top Right", "Top Center", "Right Center", "Middle Center", "Left Center", "Bottom Center"], group = g_dash)
bgColor = input.color(#1B1F2B, "Background", group = g_dash)
txtColor = input.color(color.white, "Text", group = g_dash)
hotColor = input.color(#f23646, "Hot Color (Overbought)", group = g_dash)
coldColor = input.color(#089981, "Cold Color (Oversold)", group = g_dash)

// ══════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════
getPos(pos) =>
    if pos == "Top Right"
        position.top_right
    else if pos == "Top Center"
        position.top_center
    else if pos == "Right Center"
        position.middle_right
    else if pos == "Left Center"
        position.middle_left
    else if pos == "Bottom Center"
        position.bottom_center
    else
        position.middle_center

// ══════════════════════════════════════════════════════════════
// CALC ENGINE — usando ta.percentrank (estable en MTF)
// ══════════════════════════════════════════════════════════════
// ta.percentrank(source, length) devuelve el % de valores en las últimas
// `length` barras que son MENORES O IGUALES al valor actual.
// Esto reemplaza el KDE manual y funciona correctamente en MTF
// porque NO depende de variables `var` que cambian entre charts.

calc_engine() =>
    rsi = ta.rsi(rsiSrc, rsiLen)
    
    // Percentile rank: qué % de los últimos N RSIs son <= al RSI actual
    // 100% = RSI actual es el más alto en el lookback
    // 0% = RSI actual es el más bajo en el lookback
    // 50% = RSI actual está en la mediana
    percentile = ta.percentrank(rsi, kde_lookback)
    
    // Convertimos a "extremidad": qué tan lejos del 50% está
    // 0% = neutral (centro del rango)
    // 100% = extremo (en cualquier dirección)
    kdeExtreme = math.abs(percentile - 50) * 2
    
    [rsi, kdeExtreme]

// ══════════════════════════════════════════════════════════════
// REQUEST DATA — ahora estable porque ta.percentrank no usa var
// ══════════════════════════════════════════════════════════════
[rsi_tf1, kde_tf1] = request.security(syminfo.tickerid, tf1, calc_engine(), lookahead = barmerge.lookahead_off)
[rsi_tf2, kde_tf2] = request.security(syminfo.tickerid, tf2, calc_engine(), lookahead = barmerge.lookahead_off)

// ══════════════════════════════════════════════════════════════
// EXTREME CONDITIONS
// ══════════════════════════════════════════════════════════════
tf1_overbought = rsi_tf1 >= rsi_high and kde_tf1 >= kde_threshold_tf1
tf2_overbought = rsi_tf2 >= rsi_high and kde_tf2 >= kde_threshold_tf2
both_overbought = tf1_overbought and tf2_overbought

tf1_oversold = rsi_tf1 <= rsi_low and kde_tf1 >= kde_threshold_tf1
tf2_oversold = rsi_tf2 <= rsi_low and kde_tf2 >= kde_threshold_tf2
both_oversold = tf1_oversold and tf2_oversold

// ══════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════
alertcondition(both_overbought, 
     title = "🔴 Both TFs Overbought", 
     message = "RSI Pigo: AMBAS TFs en sobrecompra extrema en {{ticker}}")

alertcondition(both_oversold, 
     title = "🟢 Both TFs Oversold", 
     message = "RSI Pigo: AMBAS TFs en sobreventa extrema en {{ticker}}")

alertcondition(tf1_overbought, 
     title = "TF1 Overbought", 
     message = "RSI Pigo: TF1 sobrecompra en {{ticker}}")

alertcondition(tf1_oversold, 
     title = "TF1 Oversold", 
     message = "RSI Pigo: TF1 sobreventa en {{ticker}}")

alertcondition(tf2_overbought, 
     title = "TF2 Overbought", 
     message = "RSI Pigo: TF2 sobrecompra en {{ticker}}")

alertcondition(tf2_oversold, 
     title = "TF2 Oversold", 
     message = "RSI Pigo: TF2 sobreventa en {{ticker}}")

// ══════════════════════════════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════════════════════════════
if showTable and barstate.islast
    var table dash = table.new(getPos(tablePos), 3, 4, bgcolor = bgColor, frame_width = 2, frame_color = txtColor, border_width = 1, border_color = txtColor)
    
    // Header
    table.cell(dash, 0, 0, "TF",    text_color = txtColor, bgcolor = bgColor)
    table.cell(dash, 1, 0, "RSI",   text_color = txtColor, bgcolor = bgColor)
    table.cell(dash, 2, 0, "KDE %", text_color = txtColor, bgcolor = bgColor)
    
    // Color logic
    rsi_tf1_color = rsi_tf1 >= rsi_high ? hotColor : rsi_tf1 <= rsi_low ? coldColor : txtColor
    rsi_tf2_color = rsi_tf2 >= rsi_high ? hotColor : rsi_tf2 <= rsi_low ? coldColor : txtColor
    kde_tf1_color = kde_tf1 >= kde_threshold_tf1 ? (rsi_tf1 >= rsi_high ? hotColor : rsi_tf1 <= rsi_low ? coldColor : txtColor) : txtColor
    kde_tf2_color = kde_tf2 >= kde_threshold_tf2 ? (rsi_tf2 >= rsi_high ? hotColor : rsi_tf2 <= rsi_low ? coldColor : txtColor) : txtColor
    
    // Row TF1
    table.cell(dash, 0, 1, tf1, text_color = txtColor, bgcolor = bgColor)
    table.cell(dash, 1, 1, str.tostring(rsi_tf1, "#.#"), text_color = rsi_tf1_color, bgcolor = bgColor)
    table.cell(dash, 2, 1, str.tostring(kde_tf1, "#.#") + "%", text_color = kde_tf1_color, bgcolor = bgColor)
    
    // Row TF2
    table.cell(dash, 0, 2, tf2, text_color = txtColor, bgcolor = bgColor)
    table.cell(dash, 1, 2, str.tostring(rsi_tf2, "#.#"), text_color = rsi_tf2_color, bgcolor = bgColor)
    table.cell(dash, 2, 2, str.tostring(kde_tf2, "#.#") + "%", text_color = kde_tf2_color, bgcolor = bgColor)
    
    // Status row
    status_text = ""
    status_color = txtColor
    if both_overbought
        status_text := "🔴 BOTH OVERBOUGHT"
        status_color := hotColor
    else if both_oversold
        status_text := "🟢 BOTH OVERSOLD"
        status_color := coldColor
    else if tf1_overbought or tf2_overbought
        status_text := "⚠️ Partial overbought"
        status_color := hotColor
    else if tf1_oversold or tf2_oversold
        status_text := "⚠️ Partial oversold"
        status_color := coldColor
    else
        status_text := "○"
        status_color := txtColor
    
    table.merge_cells(dash, 0, 3, 2, 3)
    table.cell(dash, 0, 3, status_text, text_color = status_color, bgcolor = bgColor)
````
