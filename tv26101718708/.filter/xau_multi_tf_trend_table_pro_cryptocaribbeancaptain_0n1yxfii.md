# XAU Multi TF Trend Table PRO - CryptoCaribbeanCaptain

- url: https://www.tradingview.com/script/0N1yxfIi/
- type: indicator
- pine_id: PUB;c84a9aa5dd7842b69b4a559e4856cff9
- version: 1.0

## Description

Cómo utilizarlo:

Cuando veas:

Todas 🟢 → mercado en expansión → buscas continuidad
Todas 🔴 → caída limpia → scalping agresivo
Mezcla → manipulación → esperas liquidez

Una vista rápida al mercado para ver el BIA

## Source Code

````pine
//@version=5
indicator("XAU Multi TF Trend Table PRO (FIXED)", overlay=true)

// Función de tendencia
getTrend(tf) =>
    ema50 = request.security(syminfo.tickerid, tf, ta.ema(close, 50))
    ema200 = request.security(syminfo.tickerid, tf, ta.ema(close, 200))
    ema50 > ema200 ? 1 : ema50 < ema200 ? -1 : 0

// Llamadas individuales (IMPORTANTE)
t15  = getTrend("15")
t30  = getTrend("30")
t45  = getTrend("45")
t60  = getTrend("60")
t120 = getTrend("120")
t180 = getTrend("180")
t240 = getTrend("240")
tD   = getTrend("D")

// Crear tabla
var table trendTable = table.new(position.top_right, 2, 9, border_width=1)

// Encabezados
if bar_index == 0
    table.cell(trendTable, 0, 0, "TF", bgcolor=color.black, text_color=color.white)
    table.cell(trendTable, 1, 0, "Tendencia", bgcolor=color.black, text_color=color.white)

// Función para texto + color
getText(trend) =>
    trend == 1 ? "ALCISTA 🟢" : trend == -1 ? "BAJISTA 🔴" : "NEUTRAL"

getColor(trend) =>
    trend == 1 ? color.green : trend == -1 ? color.red : color.gray

// Dibujar tabla
table.cell(trendTable, 0, 1, "15M", text_color=color.white)
table.cell(trendTable, 1, 1, getText(t15), bgcolor=getColor(t15), text_color=color.white)

table.cell(trendTable, 0, 2, "30M", text_color=color.white)
table.cell(trendTable, 1, 2, getText(t30), bgcolor=getColor(t30), text_color=color.white)

table.cell(trendTable, 0, 3, "45M", text_color=color.white)
table.cell(trendTable, 1, 3, getText(t45), bgcolor=getColor(t45), text_color=color.white)

table.cell(trendTable, 0, 4, "1H", text_color=color.white)
table.cell(trendTable, 1, 4, getText(t60), bgcolor=getColor(t60), text_color=color.white)

table.cell(trendTable, 0, 5, "2H", text_color=color.white)
table.cell(trendTable, 1, 5, getText(t120), bgcolor=getColor(t120), text_color=color.white)

table.cell(trendTable, 0, 6, "3H", text_color=color.white)
table.cell(trendTable, 1, 6, getText(t180), bgcolor=getColor(t180), text_color=color.white)

table.cell(trendTable, 0, 7, "4H", text_color=color.white)
table.cell(trendTable, 1, 7, getText(t240), bgcolor=getColor(t240), text_color=color.white)

table.cell(trendTable, 0, 8, "1D", text_color=color.white)
table.cell(trendTable, 1, 8, getText(tD), bgcolor=getColor(tD), text_color=color.white)
````
