# XAUUSD: Asia Box & S&R Master

- url: https://www.tradingview.com/script/gLIrWggD/
- type: indicator
- pine_id: PUB;60a96e07312741cd8c7d650f123442b8
- version: 1.0

## Description

This indicator is a powerful tool designed for Intraday and Scalping traders who utilize the Asian session's price action as a benchmark for the London and New York sessions.

🔍 Overview
In the Forex market, the Asian session is often characterized by lower volatility and consolidation. This script automatically identifies this range, creating a "Liquidity Box" that defines the boundaries for the rest of the trading day. These levels act as major Support and Resistance zones where institutional "stop hunts" or breakouts typically occur.

✨ Key Features
Auto-Session Highlighting: Automatically shades the Asian session background based on your preferred time zone (e.g., Tokyo/Sydney hours).

Dynamic Range Projections: * Asian High/Low: Draws extended horizontal lines marking the session's peak and trough.

Median Line (50% Revaluation): Displays the midpoint of the range, often used to determine bullish or bearish bias.

Liquidity Labels: Clearly identifies the "Buy Side Liquidity" (above High) and "Sell Side Liquidity" (below Low).

Customizable Visuals: Adjust colors, line styles, and transparency to keep your charts clean and professional.

💡 Trading Applications
The Breakout Strategy: Monitor for a clean candle close above or below the range during the London Open.

The "Judas Swing" (False Breakout): Identify when the price sweeps the Asian High/Low to grab liquidity before reversing in the opposite direction.

S&R Flips: Use the Asian High/Low as reactive support or resistance levels for retests later in the New York session.

🛠️ Recommended Settings
Standard Session: 00:00 to 09:00 (UTC) is the most common setting for general FX pairs.

Visual Style: Use subtle background colors (e.g., light blue or grey) so as not to distract from your primary price action analysis.

Pro Tip: If the Asian range is exceptionally narrow (tight consolidation), expect a high-volatility expansion during the London or New York sessions.

## Source Code

````pine
//@version=5
indicator("XAUUSD: Asia Box & S&R Master", "Asia+SR Master", overlay=true, max_boxes_count=500, max_labels_count=500)

// ==========================================
// --- 1. CONFIGURACIÓN SESIÓN ASIA (UTC-4) ---
// ==========================================
// Horario de Chile: 20:00 (8 PM) a 05:00 (5 AM)
asiaSession = input.session("2000-0500", title="Horario Sesión Asia (Chile)") 
boxColor    = input.color(color.new(#00bcd4, 75), title="Color Relleno Asia")

// Detectamos la sesión forzando la zona horaria de Santiago (UTC-4)
inSession = not na(time(timeframe.period, asiaSession, "UTC-4"))

var float sessionHigh = na
var float sessionLow  = na
var box currentBox    = na

if inSession
    if not inSession[1] // Primera vela de la sesión
        sessionHigh := high
        sessionLow  := low
        currentBox  := box.new(left=bar_index, top=sessionHigh, right=bar_index, bottom=sessionLow, bgcolor=boxColor, border_color=na)
    else // Durante la sesión
        sessionHigh := math.max(sessionHigh, high)
        sessionLow  := math.min(sessionLow, low)
        box.set_top(currentBox, sessionHigh)
        box.set_bottom(currentBox, sessionLow)
        box.set_right(currentBox, bar_index)

// ==========================================
// --- 2. SOPORTES Y RESISTENCIAS DINÁMICOS ---
// ==========================================
toggleBreaks = input.bool(true, title="Mostrar Rupturas (B)")
leftBars     = input.int(15, title="Barras Izquierda")
rightBars    = input.int(15, title="Barras Derecha")
volThresh    = input.int(20, title="Umbral de Volumen %")

// Cálculo de Pivots con lógica v5
ph = ta.pivothigh(leftBars, rightBars)
pl = ta.pivotlow(leftBars, rightBars)

// ta.valuewhen congela el nivel del pivot para dibujar la línea recta
highUsePivot = ta.valuewhen(ph, ph, 0)
lowUsePivot  = ta.valuewhen(pl, pl, 0)

// Dibujo de líneas con estilo de ruptura (style_linebr) para mayor limpieza
plot(highUsePivot, color=ta.change(highUsePivot) ? na : color.new(#FF0000, 0), linewidth=2, offset=-(rightBars+1), title="Resistencia", style=plot.style_linebr)
plot(lowUsePivot, color=ta.change(lowUsePivot) ? na : color.new(#233dee, 0), linewidth=2, offset=-(rightBars+1), title="Soporte", style=plot.style_linebr)

// ==========================================
// --- 3. VOLUMEN Y RUPTURAS ('B') ---
// ==========================================
// Oscilador de Volumen para confirmar interés institucional
volOsc = 100 * (ta.ema(volume, 5) - ta.ema(volume, 10)) / ta.ema(volume, 10)

// Lógica de Ruptura Alcista / Bajista
isBreakBear = toggleBreaks and ta.crossunder(close, lowUsePivot) and not (open - close < high - open) and volOsc > volThresh
isBreakBull = toggleBreaks and ta.crossover(close, highUsePivot) and not (open - low > close - open) and volOsc > volThresh

// Etiquetas de Ruptura 'B'
plotshape(isBreakBear, title="Break Bear", text='B', style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)
plotshape(isBreakBull, title="Break Bull", text='B', style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)

// --- ALERTAS ---
alertcondition(isBreakBear, "Soporte Roto (B)", "El precio rompió el soporte con volumen fuerte")
alertcondition(isBreakBull, "Resistencia Rota (B)", "El precio rompió la resistencia con volumen fuerte")
````
