<!-- tradingview-pine-id: PUB;a4af2b18840b4ebf8a4979578e280532 -->
<!-- tradingviewscripts-format: 1 -->
# SPY/SPX/ES Live Conversion Ratio

Source: https://www.tradingview.com/script/ZUpJEn4a-ES-SPY-Conversion-Ratio-by-Yulien/

## Description

The [symbol="CME_MINI:ES1!"]CME_MINI:ES1![/symbol] ES/ [symbol="AMEX:SPY"]AMEX:SPY[/symbol] SPY Conversion Ratio compares E-mini S&P 500 futures  (ES) with the SPDR S&P 500 ETF (SPY). It establishes a daily reference ratio from the confirmed close of the first regular-session minute (9:30-9:31 AM, America/New_York), avoiding reliance on the noisier opening-auction print.
It also calculates a live ratio on every update, displays the percentage drift from the first-minute reference, and converts a user-selected SPY price level into its corresponding ES price rounded to the configured ES tick size.

The indicator includes a configurable on-chart table, an interactive SPY reference level, and a customizable horizontal marker. It does not generate trading alerts or directional signals. This tool is intended for relative price conversion and execution reference only.

IMPORTANT DATA REQUIREMENT
Accurate operation requires real-time market data for both CME ES futures and SPY. Delayed, unavailable, or differently timestamped feeds can produce stale prices, an unavailable first-minute reference, or an inaccurate live ratio.

---

## Source Code

````pine
//@version=6
// Author: Yulien
// Version: 3.0.0
// Description: Converts a live price level between SPY, SPX, and ES using the
// active chart as the main market and the other two markets as references.
//
// TRADINGVIEW PUBLICATION DESCRIPTION
// The SPY/SPX/ES Live Conversion Ratio converts price levels between the SPDR
// S&P 500 ETF (SPY), the S&P 500 Index (SPX), and E-mini S&P 500 futures (ES).
// The active chart is the main market, and the other two markets are assigned
// automatically as references.
//
// The script calculates two synchronized live Reference/Main ratios. A single
// interactive Reference Level, taken from the main chart's price scale, is
// converted simultaneously into both reference markets. Conversions into ES
// are rounded to the configured ES tick size.
//
// The indicator does not generate alerts or directional signals. It is intended
// for relative price conversion and execution reference only.
//
// IMPORTANT DATA REQUIREMENT
// Accurate operation requires real-time market data for CME ES futures, SPY,
// and SPX. Delayed, unavailable, or differently timestamped feeds can produce
// stale prices or inaccurate live ratios.
indicator("SPY/SPX/ES Live Conversion Ratio", shorttitle="SPY/SPX/ES Converter", overlay=true, dynamic_requests=true)

// ============================================================================
// 1. INPUTS
// ============================================================================
string grupo_simbolos = "Symbols"
string selector_principal = input.string("Current chart", "Main ticker", options=["Current chart", "SPY", "SPX", "ES"], tooltip="Current chart detects the main ticker automatically. An explicit selection must match the active chart.", group=grupo_simbolos)
string simbolo_es = input.symbol("CME_MINI:ES1!", "ES Futures", group=grupo_simbolos)
string simbolo_spy = input.symbol("AMEX:SPY", "ETF SPY", group=grupo_simbolos)
string simbolo_spx = input.symbol("INDEX:SPX", "SPX Index", group=grupo_simbolos)
float tamano_tick_es = input.float(0.25, "ES minimum tick size", minval=0.01, step=0.01, group=grupo_simbolos)

string grupo_visual = "Display"
string posicion_input = input.string("Top right", "Table position", options=["Top right", "Top left", "Bottom right", "Bottom left"], group=grupo_visual)
bool mostrar_precio_principal = input.bool(true, "Show Main Price", group=grupo_visual)
bool mostrar_precio_ref_1 = input.bool(true, "Show Reference 1 Price", group=grupo_visual)
bool mostrar_precio_ref_2 = input.bool(true, "Show Reference 2 Price", group=grupo_visual)
bool mostrar_ratio_vivo_1 = input.bool(true, "Show Reference 1 Live Ratio", group=grupo_visual)
bool mostrar_ratio_vivo_2 = input.bool(true, "Show Reference 2 Live Ratio", group=grupo_visual)
bool mostrar_equivalente_ref_1 = input.bool(true, "Show Reference 1 Equivalent", group=grupo_visual)
bool mostrar_equivalente_ref_2 = input.bool(true, "Show Reference 2 Equivalent", group=grupo_visual)

string grupo_nivel_referencia = "Interactive Reference Level"
float nivel_referencia_principal = input.price(0.0, "Reference level (main chart)", tooltip="Select or drag a price on the active main-ticker chart. The same level is converted into both reference markets.", group=grupo_nivel_referencia, confirm=true)
bool mostrar_linea_referencia = input.bool(true, "Show reference-level line", group=grupo_nivel_referencia)
color color_linea_referencia = input.color(color.orange, "Line color", group=grupo_nivel_referencia)
int grosor_linea_referencia = input.int(2, "Line width", minval=1, maxval=5, group=grupo_nivel_referencia)
string estilo_linea_input = input.string("Dashed", "Line style", options=["Solid", "Dashed", "Dotted"], group=grupo_nivel_referencia)

estilo_linea_referencia = line.style_solid
if estilo_linea_input == "Dashed"
    estilo_linea_referencia := line.style_dashed
else if estilo_linea_input == "Dotted"
    estilo_linea_referencia := line.style_dotted

posicion_tabla = position.top_right
if posicion_input == "Top left"
    posicion_tabla := position.top_left
else if posicion_input == "Bottom right"
    posicion_tabla := position.bottom_right
else if posicion_input == "Bottom left"
    posicion_tabla := position.bottom_left

// ============================================================================
// 2. CHART VALIDATION AND DYNAMIC MARKET MAPPING
// ============================================================================
// SPY and SPX are identified by ticker. Any continuous or dated futures
// contract whose root is ES is accepted as the main ES chart.
string nombre_principal = ""
if syminfo.ticker == "SPY"
    nombre_principal := "SPY"
else if syminfo.ticker == "SPX"
    nombre_principal := "SPX"
else if syminfo.root == "ES"
    nombre_principal := "ES"

bool grafica_soportada = nombre_principal != ""
if not grafica_soportada
    runtime.error("This indicator can only be used on SPY, SPX, or ES charts.")

bool seleccion_automatica = selector_principal == "Current chart"
bool seleccion_coincide = selector_principal == nombre_principal
if grafica_soportada and not seleccion_automatica and not seleccion_coincide
    runtime.error("Main ticker must match the active chart. Select " + nombre_principal + " or Current chart in Settings.")

// Reference ordering remains deterministic so table rows and line conversions
// retain the same meaning after switching between supported charts.
string nombre_ref_1 = "ES"
string nombre_ref_2 = "SPX"
string simbolo_ref_1 = simbolo_es
string simbolo_ref_2 = simbolo_spx

if nombre_principal == "SPX"
    nombre_ref_1 := "ES"
    nombre_ref_2 := "SPY"
    simbolo_ref_1 := simbolo_es
    simbolo_ref_2 := simbolo_spy
else if nombre_principal == "ES"
    nombre_ref_1 := "SPY"
    nombre_ref_2 := "SPX"
    simbolo_ref_1 := simbolo_spy
    simbolo_ref_2 := simbolo_spx

string nombre_ratio_1 = nombre_ref_1 + "/" + nombre_principal
string nombre_ratio_2 = nombre_ref_2 + "/" + nombre_principal
bool ref_1_es = nombre_ref_1 == "ES"
bool ref_2_es = nombre_ref_2 == "ES"

// ============================================================================
// 3. CONVERSION FUNCTION
// ============================================================================
convertir_a_referencia(float precio_principal, float ratio_conversion, bool referencia_es) =>
    float precio_referencia = na
    if precio_principal > 0 and not na(ratio_conversion)
        precio_referencia := precio_principal * ratio_conversion
        if referencia_es
            precio_referencia := math.round(precio_referencia / tamano_tick_es) * tamano_tick_es
        else
            precio_referencia := math.round(precio_referencia * 100) / 100
    precio_referencia

// ============================================================================
// 4. STATIC VISUAL INITIALIZATION
// ============================================================================
// One customizable line is sufficient because the same main-chart level feeds
// both conversions. The input.price marker remains directly draggable.
var line linea_referencia = na
if barstate.isfirst and mostrar_linea_referencia and nivel_referencia_principal > 0
    linea_referencia := line.new(bar_index, nivel_referencia_principal, bar_index + 1, nivel_referencia_principal, xloc=xloc.bar_index, extend=extend.both, color=color_linea_referencia, style=estilo_linea_referencia, width=grosor_linea_referencia)

// Create table cells once. Realtime executions update only the value texts,
// avoiding repeated cell-property configuration on every market tick.
var table tabla_conversion = table.new(posicion_tabla, 2, 7, border_width=1, border_color=color.new(color.gray, 50))
var int fila_precio_principal = na
var int fila_precio_ref_1 = na
var int fila_precio_ref_2 = na
var int fila_ratio_1 = na
var int fila_ratio_2 = na
var int fila_equivalente_ref_1 = na
var int fila_equivalente_ref_2 = na

if barstate.isfirst
    color fondo_etiqueta = color.rgb(25, 25, 25)
    color fondo_valor = color.rgb(45, 45, 45)
    color fondo_principal = color.rgb(35, 95, 165)
    color fondo_principal_valor = color.rgb(20, 60, 115)
    int fila_actual = 0

    if mostrar_precio_principal
        fila_precio_principal := fila_actual
        table.cell(tabla_conversion, 0, fila_actual, nombre_principal + " Price", text_color=color.white, bgcolor=fondo_principal, text_size=size.small)
        table.cell(tabla_conversion, 1, fila_actual, "—", text_color=color.white, bgcolor=fondo_principal_valor, text_size=size.small)
        fila_actual += 1

    if mostrar_precio_ref_1
        fila_precio_ref_1 := fila_actual
        table.cell(tabla_conversion, 0, fila_actual, nombre_ref_1 + " Ref. Price", text_color=color.white, bgcolor=fondo_etiqueta, text_size=size.small)
        table.cell(tabla_conversion, 1, fila_actual, "—", text_color=color.white, bgcolor=fondo_valor, text_size=size.small)
        fila_actual += 1

    if mostrar_precio_ref_2
        fila_precio_ref_2 := fila_actual
        table.cell(tabla_conversion, 0, fila_actual, nombre_ref_2 + " Ref. Price", text_color=color.white, bgcolor=fondo_etiqueta, text_size=size.small)
        table.cell(tabla_conversion, 1, fila_actual, "—", text_color=color.white, bgcolor=fondo_valor, text_size=size.small)
        fila_actual += 1

    if mostrar_ratio_vivo_1
        fila_ratio_1 := fila_actual
        table.cell(tabla_conversion, 0, fila_actual, nombre_ratio_1 + " Ratio", text_color=color.white, bgcolor=fondo_etiqueta, text_size=size.small)
        table.cell(tabla_conversion, 1, fila_actual, "—", text_color=color.rgb(255, 205, 90), bgcolor=fondo_valor, text_size=size.small)
        fila_actual += 1

    if mostrar_ratio_vivo_2
        fila_ratio_2 := fila_actual
        table.cell(tabla_conversion, 0, fila_actual, nombre_ratio_2 + " Ratio", text_color=color.white, bgcolor=fondo_etiqueta, text_size=size.small)
        table.cell(tabla_conversion, 1, fila_actual, "—", text_color=color.rgb(90, 205, 255), bgcolor=fondo_valor, text_size=size.small)
        fila_actual += 1

    if mostrar_equivalente_ref_1
        fila_equivalente_ref_1 := fila_actual
        table.cell(tabla_conversion, 0, fila_actual, nombre_ref_1 + " <- " + nombre_principal + " Ref.", text_color=color.white, bgcolor=color.rgb(90, 55, 0), text_size=size.small)
        table.cell(tabla_conversion, 1, fila_actual, "Set Ref. Level", text_color=color.rgb(255, 205, 90), bgcolor=fondo_valor, text_size=size.small)
        fila_actual += 1

    if mostrar_equivalente_ref_2
        fila_equivalente_ref_2 := fila_actual
        table.cell(tabla_conversion, 0, fila_actual, nombre_ref_2 + " <- " + nombre_principal + " Ref.", text_color=color.white, bgcolor=color.rgb(0, 65, 90), text_size=size.small)
        table.cell(tabla_conversion, 1, fila_actual, "Set Ref. Level", text_color=color.rgb(90, 205, 255), bgcolor=fondo_valor, text_size=size.small)
        fila_actual += 1

// ============================================================================
// 5. LIVE DATA, RATIOS, CONVERSIONS, AND TABLE UPDATE
// ============================================================================
// Only the two reference markets require external data. The main price comes
// directly from the active chart. Dynamic contexts are initialized on the last
// historical bar, then refreshed on the active bar. Each request retrieves only
// one one-minute value, avoiding execution across the full chart history.
bool preparar_o_actualizar_datos = barstate.islastconfirmedhistory or barstate.islast
float ultimo_ref_1 = na
float ultimo_ref_2 = na
if preparar_o_actualizar_datos
    ultimo_ref_1 := request.security(simbolo_ref_1, "1", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=1)
    ultimo_ref_2 := request.security(simbolo_ref_2, "1", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=1)

if barstate.islast
    float ultimo_principal = close

    float ratio_vivo_1 = na
    float ratio_vivo_2 = na
    if not na(ultimo_principal) and ultimo_principal != 0 and not na(ultimo_ref_1)
        ratio_vivo_1 := ultimo_ref_1 / ultimo_principal
    if not na(ultimo_principal) and ultimo_principal != 0 and not na(ultimo_ref_2)
        ratio_vivo_2 := ultimo_ref_2 / ultimo_principal

    float equivalente_ref_1 = convertir_a_referencia(nivel_referencia_principal, ratio_vivo_1, ref_1_es)
    float equivalente_ref_2 = convertir_a_referencia(nivel_referencia_principal, ratio_vivo_2, ref_2_es)

    string texto_precio_principal = "—"
    string texto_precio_ref_1 = "—"
    string texto_precio_ref_2 = "—"
    string texto_ratio_1 = "—"
    string texto_ratio_2 = "—"
    string texto_equivalente_ref_1 = "Set Ref. Level"
    string texto_equivalente_ref_2 = "Set Ref. Level"

    if not na(ultimo_principal)
        texto_precio_principal := str.tostring(ultimo_principal, "#.##")
    if not na(ultimo_ref_1)
        texto_precio_ref_1 := str.tostring(ultimo_ref_1, "#.##")
    if not na(ultimo_ref_2)
        texto_precio_ref_2 := str.tostring(ultimo_ref_2, "#.##")
    if not na(ratio_vivo_1)
        texto_ratio_1 := str.tostring(ratio_vivo_1, "#.######")
    if not na(ratio_vivo_2)
        texto_ratio_2 := str.tostring(ratio_vivo_2, "#.######")
    if not na(equivalente_ref_1)
        texto_equivalente_ref_1 := str.tostring(equivalente_ref_1, "#.00") + "  (" + nombre_principal + " " + str.tostring(nivel_referencia_principal, "#.##") + ")"
    if not na(equivalente_ref_2)
        texto_equivalente_ref_2 := str.tostring(equivalente_ref_2, "#.00") + "  (" + nombre_principal + " " + str.tostring(nivel_referencia_principal, "#.##") + ")"

    if mostrar_precio_principal
        table.cell_set_text(tabla_conversion, 1, fila_precio_principal, texto_precio_principal)
    if mostrar_precio_ref_1
        table.cell_set_text(tabla_conversion, 1, fila_precio_ref_1, texto_precio_ref_1)
    if mostrar_precio_ref_2
        table.cell_set_text(tabla_conversion, 1, fila_precio_ref_2, texto_precio_ref_2)
    if mostrar_ratio_vivo_1
        table.cell_set_text(tabla_conversion, 1, fila_ratio_1, texto_ratio_1)
    if mostrar_ratio_vivo_2
        table.cell_set_text(tabla_conversion, 1, fila_ratio_2, texto_ratio_2)
    if mostrar_equivalente_ref_1
        table.cell_set_text(tabla_conversion, 1, fila_equivalente_ref_1, texto_equivalente_ref_1)
    if mostrar_equivalente_ref_2
        table.cell_set_text(tabla_conversion, 1, fila_equivalente_ref_2, texto_equivalente_ref_2)

// ============================================================================
// 6. USAGE NOTES AND LIMITATIONS
// ============================================================================
// Supported main charts: SPY, SPX, and any futures contract with an ES root.
// The current chart supplies the main price and Reference Level. The two other
// markets are assigned automatically and requested with lookahead disabled.
//
// Generic conversion:
//   Reference equivalent = Main Reference Level * (Reference/Main live ratio)
//
// Pine indicators execute when the main chart receives a data update. The live
// ratios therefore reflect the latest values available at that execution time.
````
