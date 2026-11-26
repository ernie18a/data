# Pre-Market High & Low

- url: https://www.tradingview.com/script/zfAhcT2n-Pre-Market-High-Low/
- type: indicator
- pine_id: PUB;dd2011871b6b440ebd2d3a1661bbc09b
- version: 1.0

## Description

Description:
This indicator automatically detects and plots the Pre-Market High (PMH) and Pre-Market Low (PML) for the current trading day, based on price action from the 4:00 AM to 9:30 AM EST extended session.
How it works:

Scans every bar during the pre-market session (4:00–9:30 AM EST) and records the highest high and lowest low
Once the regular session opens (9:30 AM), the levels are locked and extended as horizontal lines across the chart
Levels reset automatically at the start of each new trading day
An information table displays the PMH, PML, and the total pre-market range in the top-right corner

Features:

PMH and PML lines extended across the full trading day
Price labels showing the exact level of each line
Info table with PMH, PML, and pre-market range
4 built-in alerts: price crosses above/below PMH and above/below PML
Fully customizable: line color, width, style (solid, dashed, dotted), and label visibility

How to use it:

Apply on a 1-minute or 5-minute intraday chart for best results
Use PMH and PML as key intraday levels — breakouts above PMH or breakdowns below PML often signal strong directional moves
Combine with VWAP and the 9 EMA for high-probability trade setups

Requirements:

TradingView Pro plan or higher is required to access pre-market data and extended hours sessions

Best for: Stocks, ETFs — intraday traders and swing traders who use opening range and pre-market levels as part of their strategy.

## Source Code

````pine
//@version=5
indicator("Pre-Market High & Low", shorttitle="PM H/L", overlay=true)

// ── Inputs ──────────────────────────────────────────────────────────────
col_high    = input.color(color.new(color.lime,   0), "Color High Pre-Market",  group="Colores")
col_low     = input.color(color.new(color.red,    0), "Color Low Pre-Market",   group="Colores")
show_labels = input.bool(true,  "Mostrar etiquetas",  group="Opciones")
show_table  = input.bool(true,  "Mostrar tabla",      group="Opciones")
lw          = input.int(1, "Grosor de línea", minval=1, maxval=4, group="Opciones")
ls          = input.string("─────", "Estilo de línea",
             options=["─────","- - -","·····"], group="Opciones")

f_style() =>
    ls == "- - -" ? line.style_dashed :
     ls == "·····" ? line.style_dotted :
     line.style_solid

// ── Pre-Market session: 4:00am - 9:30am EST ─────────────────────────────
// En TradingView la sesión pre-market es "0400-0930"
is_premarket = not na(time("1", "0400-0930:23456"))

// Detectar inicio de nuevo día (reset)
new_day = dayofweek != dayofweek[1] or
          (hour == 4 and minute == 0) or
          time("D") != time("D")[1]

var float pm_high = na
var float pm_low  = na
var bool  pm_done = false   // true cuando ya termino el pre-market del dia

// Reset al inicio de cada nuevo día de trading
if new_day
    pm_high := na
    pm_low  := na
    pm_done := false

// Acumular high y low durante el pre-market
if is_premarket
    pm_high := na(pm_high) ? high : math.max(pm_high, high)
    pm_low  := na(pm_low)  ? low  : math.min(pm_low,  low)
    pm_done := false

// Marcar cuando termina el pre-market (apertura regular 9:30am)
is_regular = not na(time("1", "0930-1600:23456"))
if is_regular and not is_premarket and not pm_done and not na(pm_high)
    pm_done := true

// ── Dibujar líneas ───────────────────────────────────────────────────────
var line  ln_pmh = na
var line  ln_pml = na
var label lb_pmh = na
var label lb_pml = na

// Extender las líneas en cada barra del día regular
if not na(pm_high) and not na(pm_low)
    // High
    line.delete(ln_pmh)
    ln_pmh := line.new(
         x1    = bar_index,
         y1    = pm_high,
         x2    = bar_index + 1,
         y2    = pm_high,
         color = col_high,
         width = lw,
         style = f_style(),
         extend= extend.right)

    // Low
    line.delete(ln_pml)
    ln_pml := line.new(
         x1    = bar_index,
         y1    = pm_low,
         x2    = bar_index + 1,
         y2    = pm_low,
         color = col_low,
         width = lw,
         style = f_style(),
         extend= extend.right)

    // Labels
    if show_labels
        label.delete(lb_pmh)
        label.delete(lb_pml)
        lb_pmh := label.new(
             x         = bar_index,
             y         = pm_high,
             text      = "PMH " + str.tostring(pm_high, format.mintick),
             color     = color.new(col_high, 80),
             textcolor = col_high,
             style     = label.style_label_right,
             size      = size.small)
        lb_pml := label.new(
             x         = bar_index,
             y         = pm_low,
             text      = "PML " + str.tostring(pm_low, format.mintick),
             color     = color.new(col_low, 80),
             textcolor = col_low,
             style     = label.style_label_right,
             size      = size.small)

// ── Tabla informativa ────────────────────────────────────────────────────
var table info = table.new(
     position     = position.top_right,
     columns      = 2,
     rows         = 4,
     border_width = 1,
     border_color = color.new(color.gray, 60),
     bgcolor      = color.new(color.black, 75))

if barstate.islast and show_table and not na(pm_high)
    float pm_range = pm_high - pm_low

    table.cell(info, 0, 0, "Pre-Market", text_color=color.white,
         text_size=size.small, bgcolor=color.new(color.gray, 50))
    table.cell(info, 1, 0, "Precio",     text_color=color.white,
         text_size=size.small, bgcolor=color.new(color.gray, 50))

    table.cell(info, 0, 1, "PMH",
         text_color=col_high, text_size=size.small)
    table.cell(info, 1, 1, str.tostring(pm_high, format.mintick),
         text_color=col_high, text_size=size.small)

    table.cell(info, 0, 2, "PML",
         text_color=col_low, text_size=size.small)
    table.cell(info, 1, 2, str.tostring(pm_low, format.mintick),
         text_color=col_low, text_size=size.small)

    table.cell(info, 0, 3, "Rango PM",
         text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 3, str.tostring(pm_range, format.mintick),
         text_color=color.gray, text_size=size.small)

// ── Alertas ──────────────────────────────────────────────────────────────
alertcondition(ta.crossover(close,  pm_high), title="Precio cruza ARRIBA de PMH",
     message="🟢 Precio rompió ARRIBA del Pre-Market High ({{ticker}} - {{close}})")
alertcondition(ta.crossunder(close, pm_high), title="Precio cruza ABAJO de PMH",
     message="🔴 Precio cayó ABAJO del Pre-Market High ({{ticker}} - {{close}})")
alertcondition(ta.crossover(close,  pm_low),  title="Precio cruza ARRIBA de PML",
     message="🟢 Precio rompió ARRIBA del Pre-Market Low ({{ticker}} - {{close}})")
alertcondition(ta.crossunder(close, pm_low),  title="Precio cruza ABAJO de PML",
     message="🔴 Precio cayó ABAJO del Pre-Market Low ({{ticker}} - {{close}})")
````
