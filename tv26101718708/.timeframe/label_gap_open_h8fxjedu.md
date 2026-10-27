# Label GAP Open %

- url: https://www.tradingview.com/script/H8fxjeDu-Label-GAP-Open/
- type: indicator
- pine_id: PUB;7cce39de8a414b3791af5ed76a0f78e7
- version: 1.0

## Description

Functional Description:
The "GAP % open label" indicator is designed to calculate and instantly display the percentage gap at which an asset opens for the current session. Unlike standard indicators that track real-time price changes, this tool specifically anchors its calculation between today's opening price and the previous regular session's closing price (4:00 PM EST). This provides a static, precise data point that serves as a reliable psychological reference throughout the entire trading day.

Strategic Utility:
This tool is particularly valuable for traders focusing on high-volatility US equities, such as tech stocks or crypto-related assets. By displaying the opening gap directly on the chart with a clean, minimalist design, it allows for quick identification of the market's initial bias. It supports decision-making for "gap and go" strategies or for spotting potential mean-reversion opportunities when the price attempts to fill the opening gap, helping traders manage risk near key institutional liquidity levels.

## Source Code

````pine
//@version=5
indicator("Label GAP Open %", overlay=true)

// 1. Obtener el cierre de ayer y la apertura de hoy
// Usamos request.security para asegurar el dato diario sin importar el timeframe del gráfico
cierre_ayer = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
apertura_hoy = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)

// 2. Calcular el % del Gap
gap_pct = ((apertura_hoy - cierre_ayer) / cierre_ayer) * 100

// 3. Configuración de la Tabla (Posición)
// Lo ponemos arriba a la derecha, con un par de saltos de línea para que no estorbe
var table gap_table = table.new(position.top_right, 1, 1)

// 4. Color según sea Gap Up o Gap Down
color_texto = gap_pct >= 0 ? color.green : color.red

// 5. Renderizado del texto
if barstate.islast
    // El \n\n es para dar el espacio que te gusta respecto al borde
    mensaje = "\n\nGap Open: " + str.tostring(gap_pct, "#.##") + "%"
    table.cell(gap_table, 0, 0, mensaje, 
         text_color = color_texto, 
         text_size = size.large,
         bgcolor = color.new(color.black, 100),
         text_halign = text.align_right)
````
