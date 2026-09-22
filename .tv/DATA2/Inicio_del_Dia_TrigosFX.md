<!-- tradingview-pine-id: PUB;962eda5a126a4cfcb2e12d7d394f007c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Inicio del Día - TrigosFX

Source: https://www.tradingview.com/script/nK6YUtc5/

## Description

A clean and customizable TradingView indicator designed to clearly mark the start of each trading day with a vertical line.

Perfect for traders who want a simple visual reference for daily market structure, session analysis, liquidity tracking, ICT/SMC concepts, PO3, CRT, or any strategy that depends on precise daily timing.

The indicator allows you to customize the start time based on your preferred time zone, making it useful for traders anywhere in the world.

Key Features:
• Custom daily start time
• Multiple global time zones
• Automatic Daylight Saving Time adjustment
• Custom line color
• Adjustable line thickness
• Solid, dashed, or dotted line styles
• Clean and minimal chart display

Set your preferred time zone and daily start time, and the indicator will automatically mark each new trading day directly on your chart.

Simple. Flexible. Built for traders worldwide.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrigosFxMentor

//@version=6
indicator("Inicio del Día - TrigosFX", overlay=true, max_lines_count=500)

// ─────────────────────────────────────────────
// CONFIGURACIÓN
// ─────────────────────────────────────────────

// Hora de inicio
startHour   = input.int(0, "Hora de inicio", minval=0, maxval=23)
startMinute = input.int(0, "Minuto de inicio", minval=0, maxval=59)

// Zona horaria
timezone = input.string(
     "Europe/Madrid",
     "Zona horaria",
     options=[
         "Europe/Madrid",
         "Europe/London",
         "America/New_York",
         "America/Chicago",
         "America/Los_Angeles",
         "Asia/Tokyo",
         "Asia/Hong_Kong",
         "Asia/Singapore",
         "Australia/Sydney",
         "Etc/UTC"
     ]
)

// Apariencia
lineColor = input.color(color.gray, "Color de línea")
lineWidth = input.int(1, "Grosor", minval=1, maxval=5)

lineStyleInput = input.string(
     "Discontinua",
     "Estilo",
     options=["Continua", "Discontinua", "Punteada"]
)

lineStyle = switch lineStyleInput
    "Continua"     => line.style_solid
    "Discontinua" => line.style_dashed
    => line.style_dotted

// ─────────────────────────────────────────────
// DETECTAR INICIO DEL DÍA
// ─────────────────────────────────────────────

currentHour   = hour(time, timezone)
currentMinute = minute(time, timezone)

isStart = currentHour == startHour and currentMinute == startMinute

// ─────────────────────────────────────────────
// DIBUJAR LÍNEA VERTICAL
// ─────────────────────────────────────────────

if isStart
    line.new(
         x1=bar_index,
         y1=low,
         x2=bar_index,
         y2=high,
         extend=extend.both,
         color=lineColor,
         width=lineWidth,
         style=lineStyle
     )
````
