# Day Cheese - Trading Sessions

- url: https://www.tradingview.com/script/iAUtTpGR/
- type: indicator
- pine_id: PUB;779716553e844273a905d3022a80e2a2
- version: 1.0

## Description

[b]Day Cheese[/b] is an intraday session visualization indicator developed by [b]The Cheese Trading[/b] as a modified and expanded version of LuxAlgo’s open-source “Sessions [LuxAlgo]” script. We sincerely thank LuxAlgo and give full credit for the original work that serves as the foundation for this indicator.

The modified version adds independently configurable sessions, session VWAP and average-close displays, historical level rays, estimated volume profiles, color palettes, and additional display controls. 

Day Cheese is shared publicly with [b]open-source code[/b] as a contribution to the wider trading community.

[b]Sessions and controls[/b]

[list]
[*]Configure New York, London, Tokyo, Sydney, and one custom session independently. Sydney and the custom session are disabled by default.
[*]All session hours use the America/New_York time zone. Set the chart clock to New York so session hours, day dividers, and weekday names align with the indicator.
[*]Choose a Cheese palette or select “Customize Here” to set session colors individually. Available palettes include Cheese Very Soft, Cheese Soft, Cheese Vivid, Cheese Contrast, Cheese Dark, Cheese Warm, Cheese Cool, and Cheese Colorblind.
[*]Set visible history from 1 to 14 days. Ray history can be set from 1 to 14 days when at least one session’s Rays option is enabled. Profile history can be set from 1 to 4 days when a session’s Volume Profile option is enabled.
[*]Set each volume profile to 12–20 rows and a width of 10%–60%.
[*]Configure day dividers, the day-start time, and weekday names separately from the session settings.[/list]

[b]Calculation and limitations[/b]

[p]A session’s range is based on its highest and lowest prices. Average Close is the arithmetic mean of the session’s bar closing prices. VWAP uses the available bar prices and volume. Rays extend selected session levels into later bars according to the ray-history setting.[/p]

[p]The volume profile is an estimate calculated from chart bars. It distributes each bar’s volume across its price range; it does not use individual trades, bid/ask volume, or order-book data. Results depend on the symbol’s volume feed and the chart data available to the script.[/p]

[p]Use Day Cheese on intraday, time-based charts. Session boundaries should align with chart bars. A bar that crosses a configured boundary may prevent the indicator from drawing that boundary precisely.[/p]

[b]English translations for the Spanish interface[/b]

[list]
[*]“Paleta de colores” = Color Palette; “Personaliza aquí” = Customize Here; “Historial visible” = Visible History.
[*]“Nueva York” = New York; “Londres” = London; “Tokio” = Tokyo; “Sídney” = Sydney; “Sesión personalizada” = Custom Session.
[*]“Mostrar sesión” = Show Session; “Nombre” = Name; “Horario” = Session Hours; “Rango” = Range; “Contorno” = Outline; “Nombre visible” = Show Label.
[*]“Media” = Average Close; “VWAP” = VWAP; “Máx./Mín.” = High/Low; “Rayos” = Rays; “Perfil de volumen” = Volume Profile.
[*]“Filas” = Rows; “Ancho %” = Width %; “Días visibles” = Visible Days; “Historial de rayos” = Ray History; “Días de perfiles” = Profile Days.
[*]“Días y separadores” = Days and Dividers; “Separadores” = Dividers; “Inicio del día” = Day Start; “Nombres de días” = Day Names.
[*]“Arriba” = Above; “Abajo” = Below; “Muy pequeño” = Very Small; “Pequeño” = Small; “Normal” = Normal; “Grande” = Large; “Muy grande” = Very Large.
[*]“Continua” = Solid; “Discontinua” = Dashed; “Punteada” = Dotted.
[*]“Cheese muy suave” = Cheese Very Soft; “Cheese suave” = Cheese Soft; “Cheese vivo” = Cheese Vivid; “Cheese contraste” = Cheese Contrast; “Cheese oscuro” = Cheese Dark; “Cheese cálido” = Cheese Warm; “Cheese frío” = Cheese Cool; “Cheese daltónico” = Cheese Colorblind.
[*]“Lunes” = Monday; “Martes” = Tuesday; “Miércoles” = Wednesday; “Jueves” = Thursday; “Viernes” = Friday; “Sábado” = Saturday; “Domingo” = Sunday.[/list]

## Source Code

````pine
// This work is licensed under CC BY-NC-SA 4.0.
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Based on “Sessions [LuxAlgo]” — © LuxAlgo.
// Original: https://www.tradingview.com/script/bkb6vZDz-Sessions-LuxAlgo/
// © The Cheese Trading — Spanish interface, visual redesign and additional development.
// Pine Script® v6.
// Day Cheese · Versión 1.6.4

//@version=6
indicator("Day Cheese", shorttitle = "Day Cheese", overlay = true,
     max_boxes_count = 500, max_lines_count = 400, max_labels_count = 100)

const string ZONE = "America/New_York"

const string G_PALETTE = "🎨 PALETA DE COLORES  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
const string G_HISTORY = "🗃️ HISTORIAL VISIBLE  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
const string G_A = "🗽 1 · NUEVA YORK  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
const string G_B = "🏛️ 2 · LONDRES  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
const string G_C = "🌸 3 · TOKIO  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
const string G_D = "🌏 4 · SÍDNEY  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
const string G_E = "⚙️ 5 · SESIÓN PERSONALIZADA  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
const string G_DAYS = "🗓️ DÍAS Y SEPARADORES  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

const string TT_ENABLE = "👁️ Mostrar sesión\n\nActiva o desactiva todos los elementos de este bloque. Si la apagas, sus ajustes quedan guardados."
const string TT_NAME = "🏷️ Nombre de la sesión\n\nCambia el texto que identifica esta sesión en el gráfico. No modifica su horario.\n\nEjemplo: puedes escribir «Apertura NY»."
const string TT_HOURS = "🕘 Horario de la sesión\n\nElige la hora de inicio y de cierre en Nueva York. Puedes usar cualquier hora entre 00:00 y 23:59. Si el cierre es menor que el inicio, la sesión termina al día siguiente.\n\nEjemplo: 18:00–03:00 empieza por la tarde y termina de madrugada. "
const string TT_RANGE = "📦 Rango\n\nActiva el recuadro entre el precio más alto y el más bajo de la sesión. El selector de color contiguo cambia su fondo y transparencia. Las paletas bloquean los colores individuales; elige «Personaliza aquí» para editarlos."
const string TT_OUTLINE = "🖊️ Contorno del rango\n\nDe izquierda a derecha: activar el borde, elegir color, grosor y estilo. El grosor admite valores de 1 a 4. Puedes elegir línea continua, discontinua o punteada."
const string TT_NAME_STYLE = "🏷️ Nombre del rango\n\nDe izquierda a derecha: mostrar u ocultar el nombre, colocarlo arriba o abajo y elegir el tamaño del texto. Solo se muestra si el Rango está activado."
const string TT_MEAN = "🧮 Media de cierres\n\nMuestra el promedio de los precios de cierre de las velas de esta sesión; no usa volumen. De izquierda a derecha: activar, color, grosor y estilo. El grosor admite valores de 1 a 4."
const string TT_VWAP = "📈 VWAP de sesión\n\nCalcula el precio promedio dando más peso a las velas con mayor volumen. Empieza de nuevo al iniciar cada sesión. De izquierda a derecha: activar, color, grosor y estilo. El grosor admite valores de 1 a 4."
const string TT_LEVELS = "↔️ Máximo y mínimo anteriores\n\nAl cerrar la sesión, conserva sus precios más alto y más bajo como referencia. De izquierda a derecha: activar, color, grosor y estilo. El grosor admite valores de 1 a 4. Si activas Rayos, estas líneas se ocultan para evitar duplicados."
const string TT_RAYS = "📡 Rayos de máximo y mínimo\n\nAl cerrar la sesión, extiende hacia la derecha sus precios más alto y más bajo. De izquierda a derecha: activar, color, grosor y estilo. El grosor admite valores de 1 a 4. El historial se puede ajustar cuando hay al menos un rayo activo."
const string TT_PROFILE = "📊 Perfil de volumen\n\nDibuja una estimación del volumen por precio dentro de la sesión. Cada vela distribuye su volumen entre los niveles que recorrió, con más peso cerca del promedio de máximo, mínimo y cierre de cada vela. El color permite ajustar su transparencia. Es una aproximación: no muestra operaciones individuales ni flujo de órdenes."
const string TT_PROFILE_LAYOUT = "📊 Filas y ancho del perfil\n\nFilas divide el rango de precios en niveles: admite de 12 a 20. Ancho % controla cuánto espacio ocupa el perfil dentro de la sesión: admite de 10 % a 60 %."
const string TT_HISTORY = "🗃️ Días visibles\n\nElige cuántos días conservar en el gráfico, entre 1 y 14. Afecta los rangos, medias, VWAP, niveles y separadores. Menos días significa menos dibujos en pantalla."
const string TT_RAY_HISTORY = "📡 Historial de rayos\n\nElige cuántas sesiones cerradas conservar por cada bloque, entre 1 y 14. No puede superar los Días visibles. Este ajuste se habilita al activar Rayos en alguna sesión."
const string TT_PROFILE_DAYS = "📊 Días de perfiles\n\nElige cuántos días de perfiles conservar, entre 1 y 4. Este ajuste se habilita al activar Perfil en alguna sesión."

bool communityNote = input.bool(true, "The Cheese Trading", active = false,
     tooltip = "🧀 Querida comunidad,\n\nGracias por formar parte de The Cheese Trading y por la confianza depositada en este proyecto.\n\nEste indicador fue creado para acompañar su trabajo diario, simplificar la lectura del mercado y ayudarles a operar con mayor claridad, orden y criterio.\n\nDetrás de cada recurso de Cheese hay años de estudio, práctica, errores, aprendizaje y dedicación. Cada detalle ha sido desarrollado con la intención de aportar utilidad real a su proceso y ayudarles a trabajar de una forma más clara, ordenada y responsable.\n\nGracias por caminar junto a este proyecto y por contribuir a que The Cheese Trading siga creciendo con propósito, seriedad y corazón.\n\nJulio\nCEO de The Cheese Trading")
bool indicatorGuide = input.bool(true, "¿Qué hace Day Cheese?", active = false,
     tooltip = "📘 Guía rápida\n\nPermite estudiar Nueva York, Londres, Tokio, Sídney y una sesión personalizable. Cada bloque ofrece rango, media, VWAP, extremos, rayos y perfil de volumen. En cripto conserva sábado y domingo; en forex, CFD, futuros y otros mercados la apertura del domingo se cuenta como lunes.")
bool newYorkClockNote = input.bool(true, "Mantén el reloj en Nueva York", active = false,
     tooltip = "🕰️ Reloj de Nueva York\n\nDay Cheese calcula todos sus horarios con America/New_York y ajusta automáticamente sus cambios estacionales.\n\nPara leer las mismas horas en el eje del gráfico, configura el reloj de TradingView en Nueva York desde la esquina inferior derecha.")
bool interfaceNote = input.bool(true, "Spanish-language interface", active = false,
     tooltip = "🌐 Language\n\nThis indicator’s settings and tooltips are intentionally presented in Spanish to support the educational workflow of The Cheese Trading community.\n\nA complete English translation will be available in the public description, so every option can be understood clearly.\n\nThank you for your understanding.")

string paletteInput = input.string("Cheese muy suave", "Paleta",
     options = ["Personaliza aquí", "Cheese muy suave", "Cheese suave", "Cheese vivo", "Cheese contraste",
         "Cheese oscuro", "Cheese cálido", "Cheese frío", "Cheese daltónico"],
     group = G_PALETTE,
     tooltip = "🎨 Paleta Cheese\n\nPERSONALIZA\nPersonaliza aquí: cambia los colores desde las filas de cada sesión.\n\nPALETAS\nCheese muy suave: tonos delicados.\nCheese suave: tonos equilibrados.\nCheese vivo: tonos más intensos.\nCheese contraste: colores más fáciles de distinguir.\nCheese oscuro: tonos profundos.\nCheese cálido: tonos cálidos.\nCheese frío: tonos frescos.\nCheese daltónico: combinación de tonos diferenciados para facilitar su lectura.")
bool customPalette = paletteInput == "Personaliza aquí"

int historyDays = input.int(7, "Días visibles", minval = 1, maxval = 14,
     group = G_HISTORY, tooltip = TT_HISTORY)

bool onA = input.bool(true, "Mostrar sesión", group = G_A, tooltip = TT_ENABLE)
string nameA = input.string("Nueva York", "Nombre", group = G_A, active = onA, tooltip = TT_NAME)
string hoursA = input.session("0800-1700", "Horario", group = G_A, active = onA, tooltip = TT_HOURS)

bool rangeA = input.bool(true, "Rango     ", inline = "A_RANGE", group = G_A, active = onA)
color customRangeA = input.color(color.new(#FFD400, 95), "", inline = "A_RANGE", group = G_A, active = onA and rangeA and customPalette, tooltip = TT_RANGE)

bool outlineA = input.bool(true, "Contorno  ", inline = "A_OUT", group = G_A, active = onA and rangeA)
color customOutlineA = input.color(#FFD400, "", inline = "A_OUT", group = G_A,
     active = onA and rangeA and outlineA and customPalette)
int outlineWidthA = input.int(1, "", minval = 1, maxval = 4, inline = "A_OUT", group = G_A,
     active = onA and rangeA and outlineA)
string outlineStyleInputA = input.string("Punteada", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "A_OUT", group = G_A, active = onA and rangeA and outlineA, tooltip = TT_OUTLINE)

bool namesA = input.bool(true, "Nombre    ", inline = "A_NAME", group = G_A, active = onA and rangeA)
string labelSideA = input.string("Arriba", "", options = ["Arriba", "Abajo"],
     inline = "A_NAME", group = G_A, active = onA and rangeA and namesA)
string textSizeInputA = input.string("Pequeño", "", options = ["Muy pequeño", "Pequeño", "Normal", "Grande", "Muy grande"],
     inline = "A_NAME", group = G_A, active = onA and rangeA and namesA, tooltip = TT_NAME_STYLE)

bool meanA = input.bool(false, "Media     ", inline = "A_MEAN", group = G_A, active = onA)
color customMeanA = input.color(#FFD400, "", inline = "A_MEAN", group = G_A,
     active = onA and meanA and customPalette)
int meanWidthA = input.int(1, "", minval = 1, maxval = 4, inline = "A_MEAN", group = G_A,
     active = onA and meanA)
string meanStyleInputA = input.string("Continua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "A_MEAN", group = G_A, active = onA and meanA, tooltip = TT_MEAN)

bool vwapA = input.bool(false, "VWAP      ", inline = "A_VWAP", group = G_A, active = onA)
color customVwapA = input.color(#FFD400, "", inline = "A_VWAP", group = G_A,
     active = onA and vwapA and customPalette)
int vwapWidthA = input.int(1, "", minval = 1, maxval = 4, inline = "A_VWAP", group = G_A,
     active = onA and vwapA)
string vwapStyleInputA = input.string("Continua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "A_VWAP", group = G_A, active = onA and vwapA, tooltip = TT_VWAP)

bool levelsA = input.bool(false, "Máx./Mín. ", inline = "A_LEVEL", group = G_A, active = onA)
color customLevelsA = input.color(#FFD400, "", inline = "A_LEVEL", group = G_A,
     active = onA and levelsA and customPalette)
int levelsWidthA = input.int(1, "", minval = 1, maxval = 4, inline = "A_LEVEL", group = G_A,
     active = onA and levelsA)
string levelsStyleInputA = input.string("Discontinua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "A_LEVEL", group = G_A, active = onA and levelsA, tooltip = TT_LEVELS)

bool raysA = input.bool(false, "Rayos     ", inline = "A_RAY", group = G_A, active = onA)
color customRaysA = input.color(#FFD400, "", inline = "A_RAY", group = G_A,
     active = onA and raysA and customPalette)
int rayWidthA = input.int(1, "", minval = 1, maxval = 4, inline = "A_RAY", group = G_A,
     active = onA and raysA)
string rayStyleInputA = input.string("Discontinua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "A_RAY", group = G_A, active = onA and raysA, tooltip = TT_RAYS)

bool profileA = input.bool(false, "Perfil    ", inline = "A_VP", group = G_A, active = onA)
color customProfileA = input.color(color.new(#FFD400, 90), "", inline = "A_VP", group = G_A,
     active = onA and profileA and customPalette, tooltip = TT_PROFILE)
int profileRowsA = input.int(20, "Filas", minval = 12, maxval = 20, inline = "A_VP2", group = G_A,
     active = onA and profileA)
int profileWidthA = input.int(60, "Ancho %", minval = 10, maxval = 60,
     inline = "A_VP2", group = G_A, active = onA and profileA, tooltip = TT_PROFILE_LAYOUT)

bool onB = input.bool(true, "Mostrar sesión", group = G_B, tooltip = TT_ENABLE)
string nameB = input.string("Londres", "Nombre", group = G_B, active = onB, tooltip = TT_NAME)
string hoursB = input.session("0300-1200", "Horario", group = G_B, active = onB, tooltip = TT_HOURS)

bool rangeB = input.bool(true, "Rango     ", inline = "B_RANGE", group = G_B, active = onB)
color customRangeB = input.color(color.new(#80B7CF, 95), "", inline = "B_RANGE", group = G_B,
     active = onB and rangeB and customPalette, tooltip = TT_RANGE)

bool outlineB = input.bool(true, "Contorno  ", inline = "B_OUT", group = G_B, active = onB and rangeB)
color customOutlineB = input.color(#80B7CF, "", inline = "B_OUT", group = G_B,
     active = onB and rangeB and outlineB and customPalette)
int outlineWidthB = input.int(1, "", minval = 1, maxval = 4, inline = "B_OUT", group = G_B,
     active = onB and rangeB and outlineB)
string outlineStyleInputB = input.string("Punteada", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "B_OUT", group = G_B, active = onB and rangeB and outlineB, tooltip = TT_OUTLINE)

bool namesB = input.bool(true, "Nombre    ", inline = "B_NAME", group = G_B, active = onB and rangeB)
string labelSideB = input.string("Arriba", "", options = ["Arriba", "Abajo"],
     inline = "B_NAME", group = G_B, active = onB and rangeB and namesB)
string textSizeInputB = input.string("Pequeño", "", options = ["Muy pequeño", "Pequeño", "Normal", "Grande", "Muy grande"],
     inline = "B_NAME", group = G_B, active = onB and rangeB and namesB, tooltip = TT_NAME_STYLE)

bool meanB = input.bool(false, "Media     ", inline = "B_MEAN", group = G_B, active = onB)
color customMeanB = input.color(#80B7CF, "", inline = "B_MEAN", group = G_B,
     active = onB and meanB and customPalette)
int meanWidthB = input.int(1, "", minval = 1, maxval = 4, inline = "B_MEAN", group = G_B,
     active = onB and meanB)
string meanStyleInputB = input.string("Continua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "B_MEAN", group = G_B, active = onB and meanB, tooltip = TT_MEAN)

bool vwapB = input.bool(false, "VWAP      ", inline = "B_VWAP", group = G_B, active = onB)
color customVwapB = input.color(#80B7CF, "", inline = "B_VWAP", group = G_B,
     active = onB and vwapB and customPalette)
int vwapWidthB = input.int(1, "", minval = 1, maxval = 4, inline = "B_VWAP", group = G_B,
     active = onB and vwapB)
string vwapStyleInputB = input.string("Continua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "B_VWAP", group = G_B, active = onB and vwapB, tooltip = TT_VWAP)

bool levelsB = input.bool(false, "Máx./Mín. ", inline = "B_LEVEL", group = G_B, active = onB)
color customLevelsB = input.color(#80B7CF, "", inline = "B_LEVEL", group = G_B,
     active = onB and levelsB and customPalette)
int levelsWidthB = input.int(1, "", minval = 1, maxval = 4, inline = "B_LEVEL", group = G_B,
     active = onB and levelsB)
string levelsStyleInputB = input.string("Discontinua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "B_LEVEL", group = G_B, active = onB and levelsB, tooltip = TT_LEVELS)

bool raysB = input.bool(false, "Rayos     ", inline = "B_RAY", group = G_B, active = onB)
color customRaysB = input.color(#80B7CF, "", inline = "B_RAY", group = G_B,
     active = onB and raysB and customPalette)
int rayWidthB = input.int(1, "", minval = 1, maxval = 4, inline = "B_RAY", group = G_B,
     active = onB and raysB)
string rayStyleInputB = input.string("Discontinua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "B_RAY", group = G_B, active = onB and raysB, tooltip = TT_RAYS)

bool profileB = input.bool(false, "Perfil    ", inline = "B_VP", group = G_B, active = onB)
color customProfileB = input.color(color.new(#80B7CF, 90), "", inline = "B_VP", group = G_B,
     active = onB and profileB and customPalette, tooltip = TT_PROFILE)
int profileRowsB = input.int(20, "Filas", minval = 12, maxval = 20, inline = "B_VP2", group = G_B,
     active = onB and profileB)
int profileWidthB = input.int(60, "Ancho %", minval = 10, maxval = 60,
     inline = "B_VP2", group = G_B, active = onB and profileB, tooltip = TT_PROFILE_LAYOUT)

bool onC = input.bool(true, "Mostrar sesión", group = G_C, tooltip = TT_ENABLE)
string nameC = input.string("Tokio", "Nombre", group = G_C, active = onC, tooltip = TT_NAME)
string hoursC = input.session("1900-0400", "Horario", group = G_C, active = onC, tooltip = TT_HOURS)

bool rangeC = input.bool(true, "Rango     ", inline = "C_RANGE", group = G_C, active = onC)
color customRangeC = input.color(color.new(#D88FA5, 95), "", inline = "C_RANGE", group = G_C,
     active = onC and rangeC and customPalette, tooltip = TT_RANGE)

bool outlineC = input.bool(true, "Contorno  ", inline = "C_OUT", group = G_C, active = onC and rangeC)
color customOutlineC = input.color(#D88FA5, "", inline = "C_OUT", group = G_C,
     active = onC and rangeC and outlineC and customPalette)
int outlineWidthC = input.int(1, "", minval = 1, maxval = 4, inline = "C_OUT", group = G_C,
     active = onC and rangeC and outlineC)
string outlineStyleInputC = input.string("Punteada", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "C_OUT", group = G_C, active = onC and rangeC and outlineC, tooltip = TT_OUTLINE)

bool namesC = input.bool(true, "Nombre    ", inline = "C_NAME", group = G_C, active = onC and rangeC)
string labelSideC = input.string("Arriba", "", options = ["Arriba", "Abajo"],
     inline = "C_NAME", group = G_C, active = onC and rangeC and namesC)
string textSizeInputC = input.string("Pequeño", "", options = ["Muy pequeño", "Pequeño", "Normal", "Grande", "Muy grande"],
     inline = "C_NAME", group = G_C, active = onC and rangeC and namesC, tooltip = TT_NAME_STYLE)

bool meanC = input.bool(false, "Media     ", inline = "C_MEAN", group = G_C, active = onC)
color customMeanC = input.color(#D88FA5, "", inline = "C_MEAN", group = G_C,
     active = onC and meanC and customPalette)
int meanWidthC = input.int(1, "", minval = 1, maxval = 4, inline = "C_MEAN", group = G_C,
     active = onC and meanC)
string meanStyleInputC = input.string("Continua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "C_MEAN", group = G_C, active = onC and meanC, tooltip = TT_MEAN)

bool vwapC = input.bool(false, "VWAP      ", inline = "C_VWAP", group = G_C, active = onC)
color customVwapC = input.color(#D88FA5, "", inline = "C_VWAP", group = G_C,
     active = onC and vwapC and customPalette)
int vwapWidthC = input.int(1, "", minval = 1, maxval = 4, inline = "C_VWAP", group = G_C,
     active = onC and vwapC)
string vwapStyleInputC = input.string("Continua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "C_VWAP", group = G_C, active = onC and vwapC, tooltip = TT_VWAP)

bool levelsC = input.bool(false, "Máx./Mín. ", inline = "C_LEVEL", group = G_C, active = onC)
color customLevelsC = input.color(#D88FA5, "", inline = "C_LEVEL", group = G_C,
     active = onC and levelsC and customPalette)
int levelsWidthC = input.int(1, "", minval = 1, maxval = 4, inline = "C_LEVEL", group = G_C,
     active = onC and levelsC)
string levelsStyleInputC = input.string("Discontinua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "C_LEVEL", group = G_C, active = onC and levelsC, tooltip = TT_LEVELS)

bool raysC = input.bool(false, "Rayos     ", inline = "C_RAY", group = G_C, active = onC)
color customRaysC = input.color(#D88FA5, "", inline = "C_RAY", group = G_C,
     active = onC and raysC and customPalette)
int rayWidthC = input.int(1, "", minval = 1, maxval = 4, inline = "C_RAY", group = G_C,
     active = onC and raysC)
string rayStyleInputC = input.string("Discontinua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "C_RAY", group = G_C, active = onC and raysC, tooltip = TT_RAYS)

bool profileC = input.bool(false, "Perfil    ", inline = "C_VP", group = G_C, active = onC)
color customProfileC = input.color(color.new(#D88FA5, 90), "", inline = "C_VP", group = G_C,
     active = onC and profileC and customPalette, tooltip = TT_PROFILE)
int profileRowsC = input.int(20, "Filas", minval = 12, maxval = 20, inline = "C_VP2", group = G_C,
     active = onC and profileC)
int profileWidthC = input.int(60, "Ancho %", minval = 10, maxval = 60,
     inline = "C_VP2", group = G_C, active = onC and profileC, tooltip = TT_PROFILE_LAYOUT)

bool onD = input.bool(false, "Mostrar sesión", group = G_D, tooltip = TT_ENABLE)
string nameD = input.string("Sídney", "Nombre", group = G_D, active = onD, tooltip = TT_NAME)
string hoursD = input.session("1800-0300", "Horario", group = G_D, active = onD, tooltip = TT_HOURS)

bool rangeD = input.bool(true, "Rango     ", inline = "D_RANGE", group = G_D, active = onD)
color customRangeD = input.color(color.new(#F39A62, 95), "", inline = "D_RANGE", group = G_D,
     active = onD and rangeD and customPalette, tooltip = TT_RANGE)

bool outlineD = input.bool(true, "Contorno  ", inline = "D_OUT", group = G_D, active = onD and rangeD)
color customOutlineD = input.color(#F39A62, "", inline = "D_OUT", group = G_D,
     active = onD and rangeD and outlineD and customPalette)
int outlineWidthD = input.int(1, "", minval = 1, maxval = 4, inline = "D_OUT", group = G_D,
     active = onD and rangeD and outlineD)
string outlineStyleInputD = input.string("Punteada", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "D_OUT", group = G_D, active = onD and rangeD and outlineD, tooltip = TT_OUTLINE)

bool namesD = input.bool(true, "Nombre    ", inline = "D_NAME", group = G_D, active = onD and rangeD)
string labelSideD = input.string("Arriba", "", options = ["Arriba", "Abajo"],
     inline = "D_NAME", group = G_D, active = onD and rangeD and namesD)
string textSizeInputD = input.string("Pequeño", "", options = ["Muy pequeño", "Pequeño", "Normal", "Grande", "Muy grande"],
     inline = "D_NAME", group = G_D, active = onD and rangeD and namesD, tooltip = TT_NAME_STYLE)

bool meanD = input.bool(false, "Media     ", inline = "D_MEAN", group = G_D, active = onD)
color customMeanD = input.color(#F39A62, "", inline = "D_MEAN", group = G_D,
     active = onD and meanD and customPalette)
int meanWidthD = input.int(1, "", minval = 1, maxval = 4, inline = "D_MEAN", group = G_D,
     active = onD and meanD)
string meanStyleInputD = input.string("Continua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "D_MEAN", group = G_D, active = onD and meanD, tooltip = TT_MEAN)

bool vwapD = input.bool(false, "VWAP      ", inline = "D_VWAP", group = G_D, active = onD)
color customVwapD = input.color(#F39A62, "", inline = "D_VWAP", group = G_D,
     active = onD and vwapD and customPalette)
int vwapWidthD = input.int(1, "", minval = 1, maxval = 4, inline = "D_VWAP", group = G_D,
     active = onD and vwapD)
string vwapStyleInputD = input.string("Continua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "D_VWAP", group = G_D, active = onD and vwapD, tooltip = TT_VWAP)

bool levelsD = input.bool(false, "Máx./Mín. ", inline = "D_LEVEL", group = G_D, active = onD)
color customLevelsD = input.color(#F39A62, "", inline = "D_LEVEL", group = G_D,
     active = onD and levelsD and customPalette)
int levelsWidthD = input.int(1, "", minval = 1, maxval = 4, inline = "D_LEVEL", group = G_D,
     active = onD and levelsD)
string levelsStyleInputD = input.string("Discontinua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "D_LEVEL", group = G_D, active = onD and levelsD, tooltip = TT_LEVELS)

bool raysD = input.bool(false, "Rayos     ", inline = "D_RAY", group = G_D, active = onD)
color customRaysD = input.color(#F39A62, "", inline = "D_RAY", group = G_D,
     active = onD and raysD and customPalette)
int rayWidthD = input.int(1, "", minval = 1, maxval = 4, inline = "D_RAY", group = G_D,
     active = onD and raysD)
string rayStyleInputD = input.string("Discontinua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "D_RAY", group = G_D, active = onD and raysD, tooltip = TT_RAYS)

bool profileD = input.bool(false, "Perfil    ", inline = "D_VP", group = G_D, active = onD)
color customProfileD = input.color(color.new(#F39A62, 90), "", inline = "D_VP", group = G_D,
     active = onD and profileD and customPalette, tooltip = TT_PROFILE)
int profileRowsD = input.int(20, "Filas", minval = 12, maxval = 20, inline = "D_VP2", group = G_D,
     active = onD and profileD)
int profileWidthD = input.int(60, "Ancho %", minval = 10, maxval = 60,
     inline = "D_VP2", group = G_D, active = onD and profileD, tooltip = TT_PROFILE_LAYOUT)


bool onE = input.bool(false, "Mostrar sesión", group = G_E, tooltip = TT_ENABLE)
string nameE = input.string("Personalizada", "Nombre", group = G_E, active = onE, tooltip = TT_NAME)
string hoursE = input.session("1800-0300", "Horario", group = G_E, active = onE, tooltip = TT_HOURS)

bool rangeE = input.bool(true, "Rango     ", inline = "E_RANGE", group = G_E, active = onE)
color customRangeE = input.color(color.new(#7894AA, 95), "", inline = "E_RANGE", group = G_E,
     active = onE and rangeE and customPalette, tooltip = TT_RANGE)

bool outlineE = input.bool(true, "Contorno  ", inline = "E_OUT", group = G_E, active = onE and rangeE)
color customOutlineE = input.color(#7894AA, "", inline = "E_OUT", group = G_E,
     active = onE and rangeE and outlineE and customPalette)
int outlineWidthE = input.int(1, "", minval = 1, maxval = 4, inline = "E_OUT", group = G_E,
     active = onE and rangeE and outlineE)
string outlineStyleInputE = input.string("Punteada", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "E_OUT", group = G_E, active = onE and rangeE and outlineE, tooltip = TT_OUTLINE)

bool namesE = input.bool(true, "Nombre    ", inline = "E_NAME", group = G_E, active = onE and rangeE)
string labelSideE = input.string("Arriba", "", options = ["Arriba", "Abajo"],
     inline = "E_NAME", group = G_E, active = onE and rangeE and namesE)
string textSizeInputE = input.string("Pequeño", "", options = ["Muy pequeño", "Pequeño", "Normal", "Grande", "Muy grande"],
     inline = "E_NAME", group = G_E, active = onE and rangeE and namesE, tooltip = TT_NAME_STYLE)

bool meanE = input.bool(false, "Media     ", inline = "E_MEAN", group = G_E, active = onE)
color customMeanE = input.color(#7894AA, "", inline = "E_MEAN", group = G_E,
     active = onE and meanE and customPalette)
int meanWidthE = input.int(1, "", minval = 1, maxval = 4, inline = "E_MEAN", group = G_E,
     active = onE and meanE)
string meanStyleInputE = input.string("Continua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "E_MEAN", group = G_E, active = onE and meanE, tooltip = TT_MEAN)

bool vwapE = input.bool(false, "VWAP      ", inline = "E_VWAP", group = G_E, active = onE)
color customVwapE = input.color(#7894AA, "", inline = "E_VWAP", group = G_E,
     active = onE and vwapE and customPalette)
int vwapWidthE = input.int(1, "", minval = 1, maxval = 4, inline = "E_VWAP", group = G_E,
     active = onE and vwapE)
string vwapStyleInputE = input.string("Continua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "E_VWAP", group = G_E, active = onE and vwapE, tooltip = TT_VWAP)

bool levelsE = input.bool(false, "Máx./Mín. ", inline = "E_LEVEL", group = G_E, active = onE)
color customLevelsE = input.color(#7894AA, "", inline = "E_LEVEL", group = G_E,
     active = onE and levelsE and customPalette)
int levelsWidthE = input.int(1, "", minval = 1, maxval = 4, inline = "E_LEVEL", group = G_E,
     active = onE and levelsE)
string levelsStyleInputE = input.string("Discontinua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "E_LEVEL", group = G_E, active = onE and levelsE, tooltip = TT_LEVELS)

bool raysE = input.bool(false, "Rayos     ", inline = "E_RAY", group = G_E, active = onE)
color customRaysE = input.color(#7894AA, "", inline = "E_RAY", group = G_E,
     active = onE and raysE and customPalette)
int rayWidthE = input.int(1, "", minval = 1, maxval = 4, inline = "E_RAY", group = G_E,
     active = onE and raysE)
string rayStyleInputE = input.string("Discontinua", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "E_RAY", group = G_E, active = onE and raysE, tooltip = TT_RAYS)

bool profileE = input.bool(false, "Perfil    ", inline = "E_VP", group = G_E, active = onE)
color customProfileE = input.color(color.new(#7894AA, 90), "", inline = "E_VP", group = G_E,
     active = onE and profileE and customPalette, tooltip = TT_PROFILE)
int profileRowsE = input.int(20, "Filas", minval = 12, maxval = 20, inline = "E_VP2", group = G_E,
     active = onE and profileE)
int profileWidthE = input.int(60, "Ancho %", minval = 10, maxval = 60,
     inline = "E_VP2", group = G_E, active = onE and profileE, tooltip = TT_PROFILE_LAYOUT)


bool anyRays = raysA or raysB or raysC or raysD or raysE
bool anyProfile = profileA or profileB or profileC or profileD or profileE
int rayHistory = input.int(1, "Historial de rayos", minval = 1, maxval = 14,
     group = G_HISTORY, active = anyRays, tooltip = TT_RAY_HISTORY)
int profileDays = input.int(3, "Días de perfiles", minval = 1, maxval = 4,
     group = G_HISTORY, active = anyProfile, tooltip = TT_PROFILE_DAYS)

bool dailyDividers = input.bool(true, "Separadores   ", inline = "DAY_LINE", group = G_DAYS)
color dayTone = input.color(color.new(#555555, 35), "", inline = "DAY_LINE", group = G_DAYS,
     active = dailyDividers)
int dayWidth = input.int(1, "", minval = 1, maxval = 4, inline = "DAY_LINE", group = G_DAYS,
     active = dailyDividers)
string dayStyleInput = input.string("Punteada", "", options = ["Continua", "Discontinua", "Punteada"],
     inline = "DAY_LINE", group = G_DAYS, active = dailyDividers,
     tooltip = "🗓️ Separadores\n\nDe izquierda a derecha: activar, color, grosor y estilo. Marcan el nuevo día de Nueva York a la hora definida abajo. El grosor admite valores de 1 a 4; puedes elegir línea continua, discontinua o punteada.")

bool showDayNames = input.bool(true, "Nombres de días", inline = "DAY_NAME", group = G_DAYS,
     active = dailyDividers, tooltip = "📅 Nombres de días\n\nSe muestran pequeños y fijos en la parte superior del gráfico. Siguen a cada día cuando desplazas la gráfica y quedan una vela a la derecha del separador. Cripto conserva sábado y domingo; en los demás mercados la apertura dominical se cuenta como lunes.")
color dayNameTone = input.color(#696969, "", inline = "DAY_NAME", group = G_DAYS,
     active = dailyDividers and showDayNames)

int dayStartHour = input.int(18, "Inicio del día", minval = 0, maxval = 23,
     inline = "DAY_TIME", group = G_DAYS, active = dailyDividers)
int dayStartMinute = input.int(0, ":", minval = 0, maxval = 59,
     inline = "DAY_TIME", group = G_DAYS, active = dailyDividers,
     tooltip = "🕕 Comienzo del día\n\nHora de Nueva York para forex, CFD, futuros y otros mercados. La hora admite de 0 a 23 y los minutos de 0 a 59. En cripto se usa automáticamente la medianoche para conservar los siete días naturales. Si no existe una vela exacta, se usa la primera posterior.")


f_line_style(string selected) =>
    switch selected
        "Discontinua" => line.style_dashed
        "Punteada" => line.style_dotted
        => line.style_solid

f_text_size(string selected) =>
    switch selected
        "Muy pequeño" => size.tiny
        "Normal" => size.normal
        "Grande" => size.large
        "Muy grande" => size.huge
        => size.small

int paletteTransparency = paletteInput == "Cheese muy suave" ? 95 : paletteInput == "Cheese vivo" ? 88 : 90
color baseA = switch paletteInput
    "Cheese muy suave" => #FFD400
    "Cheese suave" => #F2CA00
    "Cheese vivo" => #FFD400
    "Cheese contraste" => #C9A900
    "Cheese oscuro" => #B39500
    "Cheese cálido" => #E6B800
    "Cheese frío" => #E8CC00
    "Cheese daltónico" => #E69F00
    => customOutlineA
color rangeFillA = customPalette ? customRangeA : color.new(baseA, paletteTransparency)
color outlineToneA = customPalette ? customOutlineA : baseA
color meanToneA = customPalette ? customMeanA : baseA
color vwapToneA = customPalette ? customVwapA : baseA
color levelsToneA = customPalette ? customLevelsA : baseA
color rayToneA = customPalette ? customRaysA : baseA
color profileToneA = customPalette ? customProfileA : color.new(baseA, 90)
string outlineStyleA = f_line_style(outlineStyleInputA)
string meanStyleA = f_line_style(meanStyleInputA)
string rayStyleA = f_line_style(rayStyleInputA)
string textSizeA = f_text_size(textSizeInputA)

color baseB = switch paletteInput
    "Cheese muy suave" => #80B7CF
    "Cheese suave" => #568EAA
    "Cheese vivo" => #00A6C8
    "Cheese contraste" => #006E8A
    "Cheese oscuro" => #345B6B
    "Cheese cálido" => #A88858
    "Cheese frío" => #4C9FCC
    "Cheese daltónico" => #56B4E9
    => customOutlineB
color rangeFillB = customPalette ? customRangeB : color.new(baseB, paletteTransparency)
color outlineToneB = customPalette ? customOutlineB : baseB
color meanToneB = customPalette ? customMeanB : baseB
color vwapToneB = customPalette ? customVwapB : baseB
color levelsToneB = customPalette ? customLevelsB : baseB
color rayToneB = customPalette ? customRaysB : baseB
color profileToneB = customPalette ? customProfileB : color.new(baseB, 90)
string outlineStyleB = f_line_style(outlineStyleInputB)
string meanStyleB = f_line_style(meanStyleInputB)
string rayStyleB = f_line_style(rayStyleInputB)
string textSizeB = f_text_size(textSizeInputB)

color baseC = switch paletteInput
    "Cheese muy suave" => #D88FA5
    "Cheese suave" => #C56581
    "Cheese vivo" => #E64B69
    "Cheese contraste" => #AE3D58
    "Cheese oscuro" => #773A4A
    "Cheese cálido" => #D2735E
    "Cheese frío" => #7D93B5
    "Cheese daltónico" => #CC79A7
    => customOutlineC
color rangeFillC = customPalette ? customRangeC : color.new(baseC, paletteTransparency)
color outlineToneC = customPalette ? customOutlineC : baseC
color meanToneC = customPalette ? customMeanC : baseC
color vwapToneC = customPalette ? customVwapC : baseC
color levelsToneC = customPalette ? customLevelsC : baseC
color rayToneC = customPalette ? customRaysC : baseC
color profileToneC = customPalette ? customProfileC : color.new(baseC, 90)
string outlineStyleC = f_line_style(outlineStyleInputC)
string meanStyleC = f_line_style(meanStyleInputC)
string rayStyleC = f_line_style(rayStyleInputC)
string textSizeC = f_text_size(textSizeInputC)

color baseD = switch paletteInput
    "Cheese muy suave" => #F39A62
    "Cheese suave" => #D58453
    "Cheese vivo" => #F59E0B
    "Cheese contraste" => #995400
    "Cheese oscuro" => #856028
    "Cheese cálido" => #D2A04D
    "Cheese frío" => #B78363
    "Cheese daltónico" => #D55E00
    => customOutlineD
color rangeFillD = customPalette ? customRangeD : color.new(baseD, paletteTransparency)
color outlineToneD = customPalette ? customOutlineD : baseD
color meanToneD = customPalette ? customMeanD : baseD
color vwapToneD = customPalette ? customVwapD : baseD
color levelsToneD = customPalette ? customLevelsD : baseD
color rayToneD = customPalette ? customRaysD : baseD
color profileToneD = customPalette ? customProfileD : color.new(baseD, 90)
string outlineStyleD = f_line_style(outlineStyleInputD)
string meanStyleD = f_line_style(meanStyleInputD)
string rayStyleD = f_line_style(rayStyleInputD)
string textSizeD = f_text_size(textSizeInputD)


color baseE = switch paletteInput
    "Cheese muy suave" => #7894AA
    "Cheese suave" => #627D95
    "Cheese vivo" => #275D78
    "Cheese contraste" => #193E52
    "Cheese oscuro" => #303B45
    "Cheese cálido" => #A99C84
    "Cheese frío" => #3E6F91
    "Cheese daltónico" => #0072B2
    => customOutlineE
color rangeFillE = customPalette ? customRangeE : color.new(baseE, paletteTransparency)
color outlineToneE = customPalette ? customOutlineE : baseE
color meanToneE = customPalette ? customMeanE : baseE
color vwapToneE = customPalette ? customVwapE : baseE
color levelsToneE = customPalette ? customLevelsE : baseE
color rayToneE = customPalette ? customRaysE : baseE
color profileToneE = customPalette ? customProfileE : color.new(baseE, 90)
string outlineStyleE = f_line_style(outlineStyleInputE)
string meanStyleE = f_line_style(meanStyleInputE)
string rayStyleE = f_line_style(rayStyleInputE)
string textSizeE = f_text_size(textSizeInputE)


string dayStyle = f_line_style(dayStyleInput)
plotVwapStyleA = switch vwapStyleInputA
    "Punteada" => plot.linestyle_dotted
    "Discontinua" => plot.linestyle_dashed
    => plot.linestyle_solid

plotVwapStyleB = switch vwapStyleInputB
    "Punteada" => plot.linestyle_dotted
    "Discontinua" => plot.linestyle_dashed
    => plot.linestyle_solid

plotVwapStyleC = switch vwapStyleInputC
    "Punteada" => plot.linestyle_dotted
    "Discontinua" => plot.linestyle_dashed
    => plot.linestyle_solid

plotVwapStyleD = switch vwapStyleInputD
    "Punteada" => plot.linestyle_dotted
    "Discontinua" => plot.linestyle_dashed
    => plot.linestyle_solid


plotVwapStyleE = switch vwapStyleInputE
    "Punteada" => plot.linestyle_dotted
    "Discontinua" => plot.linestyle_dashed
    => plot.linestyle_solid


int rayLimit = math.min(rayHistory, historyDays)
int effectiveProfileDays = math.min(profileDays, historyDays)

bool cryptoCalendar = syminfo.type == "crypto"
int effectiveDayStartHour = cryptoCalendar ? 0 : dayStartHour
int effectiveDayStartMinute = cryptoCalendar ? 0 : dayStartMinute

int latestBoundary = timestamp(ZONE, year(last_bar_time, ZONE), month(last_bar_time, ZONE),
     dayofmonth(last_bar_time, ZONE), effectiveDayStartHour, effectiveDayStartMinute)
int latestDayStart = last_bar_time >= latestBoundary ? latestBoundary :
     timestamp(ZONE, year(last_bar_time, ZONE), month(last_bar_time, ZONE),
     dayofmonth(last_bar_time, ZONE) - 1, effectiveDayStartHour, effectiveDayStartMinute)
int historyStart = timestamp(ZONE, year(latestDayStart, ZONE), month(latestDayStart, ZONE),
     dayofmonth(latestDayStart, ZONE) - historyDays + 1, effectiveDayStartHour, effectiveDayStartMinute)

if not chart.is_standard or not timeframe.isintraday or timeframe.isticks
    runtime.error("Day Cheese requiere velas estándar intradía basadas en tiempo.")

f_window(string hours) =>
    int sh = int(str.tonumber(str.substring(hours, 0, 2)))
    int sm = int(str.tonumber(str.substring(hours, 2, 4)))
    int eh = int(str.tonumber(str.substring(hours, 5, 7)))
    int em = int(str.tonumber(str.substring(hours, 7, 9)))
    int y = year(time, ZONE)
    int m = month(time, ZONE)
    int d = dayofmonth(time, ZONE)
    int todayStart = timestamp(ZONE, y, m, d, sh, sm)
    int start = time >= todayStart ? todayStart : timestamp(ZONE, y, m, d - 1, sh, sm)
    int nextDay = eh * 60 + em <= sh * 60 + sm ? 1 : 0
    int finish = timestamp(ZONE, year(start, ZONE), month(start, ZONE),
         dayofmonth(start, ZONE) + nextDay, eh, em)
    [start, finish, todayStart]

f_add_rays(array<line> upperRays, array<line> lowerRays, int startTime,
     float maxLevel, float minLevel, color tone, int width, string style) =>
    line upper = line.new(startTime, maxLevel, startTime + 60000, maxLevel,
         xloc = xloc.bar_time, extend = extend.right, color = tone, width = width, style = style)
    line lower = line.new(startTime, minLevel, startTime + 60000, minLevel,
         xloc = xloc.bar_time, extend = extend.right, color = tone, width = width, style = style)
    array.push(upperRays, upper)
    array.push(lowerRays, lower)
    if array.size(upperRays) > rayLimit
        line.delete(array.shift(upperRays))
        line.delete(array.shift(lowerRays))

f_trim_profile_groups(array<box> allBoxes, array<int> groupSizes) =>
    while array.size(groupSizes) > effectiveProfileDays
        int quantity = array.shift(groupSizes)
        for i = 0 to quantity - 1
            box.delete(array.shift(allBoxes))

f_session(bool enabled, string title, string hours,
     bool drawRange, color rangeColor, bool drawOutline, color outlineColor,
     int outlineWidth, string outlineStyle, bool drawName, string nameSide, string nameSize,
     bool drawMean, color meanColor, int meanWidth, string meanStyle,
     bool drawVwap, bool drawLevels, color levelsColor, int levelsWidth, string levelsStyle, bool drawRays, color rayColor, int rayWidth, string rayStyle,
     bool drawProfile, color profileColor, int rows, int profileWidth) =>

    [start, finish, todayStart] = f_window(hours)
    bool active = enabled and not na(time(timeframe.period, hours, ZONE))

    var int cycle = na
    var int firstTime = na
    var int closeTime = na
    var int completedEnd = na
    var float completedHigh = na
    var float completedLow = na
    var bool captured = false
    var float hi = na
    var float lo = na
    var float sumClose = 0.0
    var float sumPV = 0.0
    var float sumV = 0.0
    var int count = 0
    var bool validVolume = true

    var box rangeBox = na
    var label rangeLabel = na
    var line meanLine = na
    var array<box> rangeBoxes = array.new<box>()
    var array<label> rangeLabels = array.new<label>()
    var array<line> meanLines = array.new<line>()
    var array<line> upperRays = array.new<line>()
    var array<line> lowerRays = array.new<line>()
    var array<line> upperLevelLines = array.new<line>()
    var array<line> lowerLevelLines = array.new<line>()
    var line activeUpperLevel = na
    var line activeLowerLevel = na

    var array<float> profileVolumes = array.new<float>()
    var array<box> currentProfileBoxes = array.new<box>()
    var array<box> allProfileBoxes = array.new<box>()
    var array<int> profileGroupSizes = array.new<int>()
    var float profileHi = na
    var float profileLo = na

    bool started = active and (na(cycle) or start != cycle)
    bool crossesStart = time < todayStart and time_close > todayStart
    if enabled and (crossesStart or (active and time_close > finish))
        runtime.error("La sesión " + title + " comienza o termina dentro de una vela. Usa una temporalidad menor o ajusta sus horas.")

    if enabled and not na(cycle) and not captured and time >= closeTime
        completedHigh := hi
        completedLow := lo
        completedEnd := closeTime
        captured := true
        if drawLevels and not drawRays and closeTime >= historyStart
            line upperLevel = line.new(closeTime, hi, closeTime + 60000, hi,
                 xloc = xloc.bar_time, extend = extend.right, color = levelsColor,
                 width = levelsWidth, style = levelsStyle)
            line lowerLevel = line.new(closeTime, lo, closeTime + 60000, lo,
                 xloc = xloc.bar_time, extend = extend.right, color = levelsColor,
                 width = levelsWidth, style = levelsStyle)
            array.push(upperLevelLines, upperLevel)
            array.push(lowerLevelLines, lowerLevel)
            activeUpperLevel := upperLevel
            activeLowerLevel := lowerLevel
            if array.size(upperLevelLines) > historyDays
                line.delete(array.shift(upperLevelLines))
                line.delete(array.shift(lowerLevelLines))
        if drawRays and closeTime >= historyStart
            f_add_rays(upperRays, lowerRays, closeTime, hi, lo, rayColor, rayWidth, rayStyle)

    if started
        if not na(activeUpperLevel)
            line.set_x2(activeUpperLevel, time)
            line.set_extend(activeUpperLevel, extend.none)
            activeUpperLevel := na
        if not na(activeLowerLevel)
            line.set_x2(activeLowerLevel, time)
            line.set_extend(activeLowerLevel, extend.none)
            activeLowerLevel := na
        cycle := start
        firstTime := time
        closeTime := finish
        hi := high
        lo := low
        sumClose := 0.0
        sumPV := 0.0
        sumV := 0.0
        count := 0
        validVolume := true
        captured := false
        rangeBox := na
        rangeLabel := na
        meanLine := na

        array.clear(profileVolumes)
        for row = 0 to rows - 1
            array.push(profileVolumes, 0.0)
        array.clear(currentProfileBoxes)
        profileHi := high
        profileLo := low

        if time >= historyStart and drawRange
            rangeBox := box.new(time, hi, time_close, lo, xloc = xloc.bar_time,
                 bgcolor = rangeColor, border_color = drawOutline ? outlineColor : na,
                 border_width = outlineWidth, border_style = outlineStyle)
            array.push(rangeBoxes, rangeBox)
            if array.size(rangeBoxes) > historyDays
                box.delete(array.shift(rangeBoxes))

            if drawName
                rangeLabel := label.new(time, nameSide == "Arriba" ? hi : lo, title,
                     xloc = xloc.bar_time,
                     style = nameSide == "Arriba" ? label.style_label_down : label.style_label_up,
                     color = color.new(outlineColor, 100), textcolor = outlineColor, size = nameSize)
                array.push(rangeLabels, rangeLabel)
                if array.size(rangeLabels) > historyDays
                    label.delete(array.shift(rangeLabels))

        if time >= historyStart and drawMean
            meanLine := line.new(time, close, time_close, close, xloc = xloc.bar_time,
                 color = meanColor, width = meanWidth, style = meanStyle)
            array.push(meanLines, meanLine)
            if array.size(meanLines) > historyDays
                line.delete(array.shift(meanLines))

        if time >= historyStart and drawProfile
            for row = 0 to rows - 1
                box id = box.new(time, high, time_close, low, xloc = xloc.bar_time,
                     border_color = na, bgcolor = profileColor)
                array.push(currentProfileBoxes, id)
                array.push(allProfileBoxes, id)
            array.push(profileGroupSizes, rows)
            f_trim_profile_groups(allProfileBoxes, profileGroupSizes)

    if active
        float oldHi = hi
        float oldLo = lo
        hi := math.max(hi, high)
        lo := math.min(lo, low)
        count += 1
        sumClose += close

        bool barVolumeOk = not na(volume) and volume >= 0
        if drawVwap
            validVolume := validVolume and barVolumeOk
            if barVolumeOk
                sumPV += close * volume
                sumV += volume

        if not na(rangeBox)
            box.set_top(rangeBox, hi)
            box.set_rightbottom(rangeBox, time_close, lo)

        if not na(rangeLabel)
            label.set_xy(rangeLabel, firstTime + int((time_close - firstTime) / 2),
                 nameSide == "Arriba" ? hi : lo)

        if not na(meanLine)
            float average = sumClose / count
            line.set_y1(meanLine, average)
            line.set_xy2(meanLine, time_close, average)

        if drawProfile and barstate.isconfirmed and array.size(currentProfileBoxes) == rows
            float oldSpan = math.max(oldHi - oldLo, syminfo.mintick)
            float newSpan = math.max(hi - lo, syminfo.mintick)
            bool rangeExpanded = hi != profileHi or lo != profileLo

            if rangeExpanded
                array<float> remapped = array.new<float>(rows, 0.0)
                float oldStep = math.max((profileHi - profileLo) / rows, syminfo.mintick)
                float newStep = math.max(newSpan / rows, syminfo.mintick)
                for row = 0 to rows - 1
                    float oldVolume = array.get(profileVolumes, row)
                    float midpoint = profileLo + (row + 0.5) * oldStep
                    int newRow = math.max(0, math.min(rows - 1, int(math.floor((midpoint - lo) / newStep))))
                    array.set(remapped, newRow, array.get(remapped, newRow) + oldVolume)
                for row = 0 to rows - 1
                    array.set(profileVolumes, row, array.get(remapped, row))
                profileHi := hi
                profileLo := lo

            if barVolumeOk
                float step = math.max(newSpan / rows, syminfo.mintick)
                int firstRow = math.max(0, math.min(rows - 1, int(math.floor((low - lo) / step))))
                int lastRow = math.max(0, math.min(rows - 1, int(math.floor((high - lo) / step))))
                float weightSum = 0.0
                for row = firstRow to lastRow
                    float midpoint = lo + (row + 0.5) * step
                    float weight = 1.0 / (1.0 + math.abs(midpoint - hlc3) / step)
                    weightSum += weight
                for row = firstRow to lastRow
                    float midpoint = lo + (row + 0.5) * step
                    float weight = 1.0 / (1.0 + math.abs(midpoint - hlc3) / step)
                    float distributedVolume = volume * weight / math.max(weightSum, 0.000001)
                    array.set(profileVolumes, row, array.get(profileVolumes, row) + distributedVolume)

            float maxVolume = math.max(array.max(profileVolumes), 1.0)
            float rowStep = math.max(newSpan / rows, syminfo.mintick)
            int fullWidth = math.max(time_close - firstTime, 60000)

            for row = 0 to rows - 1
                box id = array.get(currentProfileBoxes, row)
                float rowVolume = array.get(profileVolumes, row)
                int widthMs = int(fullWidth * profileWidth / 100.0 * rowVolume / maxVolume)
                float bottom = lo + row * rowStep
                float top = row == rows - 1 ? hi : bottom + rowStep
                int leftTime = rowVolume > 0 ? time_close - math.max(widthMs, 60000) : time_close
                box.set_lefttop(id, leftTime, top)
                box.set_rightbottom(id, time_close, bottom)
                box.set_bgcolor(id, profileColor)

        if not captured and barstate.isconfirmed and time_close == closeTime
            completedHigh := hi
            completedLow := lo
            completedEnd := closeTime
            captured := true
            if drawLevels and not drawRays and closeTime >= historyStart
                line upperLevel = line.new(closeTime, hi, closeTime + 60000, hi,
                     xloc = xloc.bar_time, extend = extend.right, color = levelsColor,
                     width = levelsWidth, style = levelsStyle)
                line lowerLevel = line.new(closeTime, lo, closeTime + 60000, lo,
                     xloc = xloc.bar_time, extend = extend.right, color = levelsColor,
                     width = levelsWidth, style = levelsStyle)
                array.push(upperLevelLines, upperLevel)
                array.push(lowerLevelLines, lowerLevel)
                activeUpperLevel := upperLevel
                activeLowerLevel := lowerLevel
                if array.size(upperLevelLines) > historyDays
                    line.delete(array.shift(upperLevelLines))
                    line.delete(array.shift(lowerLevelLines))
            if drawRays and closeTime >= historyStart
                f_add_rays(upperRays, lowerRays, closeTime, hi, lo, rayColor, rayWidth, rayStyle)

    while array.size(upperRays) > rayLimit
        line.delete(array.shift(upperRays))
        line.delete(array.shift(lowerRays))
    f_trim_profile_groups(allProfileBoxes, profileGroupSizes)

    bool hasCompleted = enabled and not na(completedEnd) and completedEnd >= historyStart
    bool lastSessionBar = not active and not na(cycle) and not na(closeTime) and time >= closeTime and time[1] < closeTime and time_close[1] == closeTime
    float sessionVwap = drawVwap and validVolume and sumV > 0 and (active or lastSessionBar) ? sumPV / sumV : na
    bool breakVwap = started and active[1]
    [sessionVwap, breakVwap]

[vwA, gapA] = f_session(onA, nameA, hoursA,
     rangeA, rangeFillA, outlineA, outlineToneA, outlineWidthA, outlineStyleA,
     namesA, labelSideA, textSizeA,
     meanA, meanToneA, meanWidthA, meanStyleA,
     vwapA, levelsA, levelsToneA, levelsWidthA, f_line_style(levelsStyleInputA), raysA, rayToneA, rayWidthA, rayStyleA,
     profileA, profileToneA, profileRowsA, profileWidthA)
[vwB, gapB] = f_session(onB, nameB, hoursB,
     rangeB, rangeFillB, outlineB, outlineToneB, outlineWidthB, outlineStyleB,
     namesB, labelSideB, textSizeB,
     meanB, meanToneB, meanWidthB, meanStyleB,
     vwapB, levelsB, levelsToneB, levelsWidthB, f_line_style(levelsStyleInputB), raysB, rayToneB, rayWidthB, rayStyleB,
     profileB, profileToneB, profileRowsB, profileWidthB)
[vwC, gapC] = f_session(onC, nameC, hoursC,
     rangeC, rangeFillC, outlineC, outlineToneC, outlineWidthC, outlineStyleC,
     namesC, labelSideC, textSizeC,
     meanC, meanToneC, meanWidthC, meanStyleC,
     vwapC, levelsC, levelsToneC, levelsWidthC, f_line_style(levelsStyleInputC), raysC, rayToneC, rayWidthC, rayStyleC,
     profileC, profileToneC, profileRowsC, profileWidthC)
[vwD, gapD] = f_session(onD, nameD, hoursD,
     rangeD, rangeFillD, outlineD, outlineToneD, outlineWidthD, outlineStyleD,
     namesD, labelSideD, textSizeD,
     meanD, meanToneD, meanWidthD, meanStyleD,
     vwapD, levelsD, levelsToneD, levelsWidthD, f_line_style(levelsStyleInputD), raysD, rayToneD, rayWidthD, rayStyleD,
     profileD, profileToneD, profileRowsD, profileWidthD)

[vwE, gapE] = f_session(onE, nameE, hoursE,
     rangeE, rangeFillE, outlineE, outlineToneE, outlineWidthE, outlineStyleE,
     namesE, labelSideE, textSizeE,
     meanE, meanToneE, meanWidthE, meanStyleE,
     vwapE, levelsE, levelsToneE, levelsWidthE, f_line_style(levelsStyleInputE), raysE, rayToneE, rayWidthE, rayStyleE,
     profileE, profileToneE, profileRowsE, profileWidthE)

plot(time >= historyStart ? vwA : na, "Nueva York · VWAP", gapA ? na : vwapToneA, vwapWidthA, plot.style_linebr, linestyle = plotVwapStyleA, editable = false)
plot(time >= historyStart ? vwB : na, "Londres · VWAP", gapB ? na : vwapToneB, vwapWidthB, plot.style_linebr, linestyle = plotVwapStyleB, editable = false)
plot(time >= historyStart ? vwC : na, "Tokio · VWAP", gapC ? na : vwapToneC, vwapWidthC, plot.style_linebr, linestyle = plotVwapStyleC, editable = false)
plot(time >= historyStart ? vwD : na, "Sídney · VWAP", gapD ? na : vwapToneD, vwapWidthD, plot.style_linebr, linestyle = plotVwapStyleD, editable = false)
plot(time >= historyStart ? vwE : na, "Personalizada · VWAP", gapE ? na : vwapToneE, vwapWidthE, plot.style_linebr, linestyle = plotVwapStyleE, editable = false)


int localYear = year(time, ZONE)
int localMonth = month(time, ZONE)
int localDate = dayofmonth(time, ZONE)
int boundaryToday = timestamp(ZONE, localYear, localMonth, localDate, effectiveDayStartHour, effectiveDayStartMinute)
int dayAnchor = time >= boundaryToday ? boundaryToday :
     timestamp(ZONE, localYear, localMonth, localDate - 1, effectiveDayStartHour, effectiveDayStartMinute)
int dateKey = year(dayAnchor, ZONE) * 10000 + month(dayAnchor, ZONE) * 100 + dayofmonth(dayAnchor, ZONE)
bool newDay = not na(dateKey[1]) and dateKey != dateKey[1]

// Crypto follows calendar days. Other markets assign Sunday opening to Monday.
int calendarDateOffset = cryptoCalendar ? 0 : 1
int namedDate = timestamp(ZONE, year(dayAnchor, ZONE), month(dayAnchor, ZONE),
     dayofmonth(dayAnchor, ZONE) + calendarDateOffset, 12, 0)
int calendarWeekday = dayofweek(namedDate, ZONE)
int tradingDate = not cryptoCalendar and calendarWeekday == dayofweek.sunday ?
     timestamp(ZONE, year(namedDate, ZONE), month(namedDate, ZONE), dayofmonth(namedDate, ZONE) + 1, 12, 0) : namedDate
int namedWeekday = dayofweek(tradingDate, ZONE)
int namedDateKey = year(tradingDate, ZONE) * 10000 + month(tradingDate, ZONE) * 100 + dayofmonth(tradingDate, ZONE)
var int lastNamedDateKey = na
// Ignore the forex Sunday opening candle when it arrives before the configured day boundary.
// The first divider/name then appears at the selected New York hour, without a duplicate Monday.
bool sundayBeforeBoundary = not cryptoCalendar and dayofweek(time, ZONE) == dayofweek.sunday and time < boundaryToday
bool newTradingDay = newDay and not sundayBeforeBoundary and (na(lastNamedDateKey) or namedDateKey != lastNamedDateKey)
if newTradingDay
    lastNamedDateKey := namedDateKey
var array<line> dayLines = array.new<line>()
if dailyDividers and newTradingDay and time >= historyStart
    line lineId = line.new(time, close + syminfo.mintick, time, close - syminfo.mintick,
         xloc = xloc.bar_time, extend = extend.both, color = dayTone,
         width = dayWidth, style = dayStyle)
    array.push(dayLines, lineId)

while array.size(dayLines) > historyDays
    line.delete(array.shift(dayLines))

bool drawDayName = dailyDividers and showDayNames and newTradingDay and time >= historyStart
plotshape(drawDayName and namedWeekday == dayofweek.monday,
     "Lunes", shape.labeldown, location.top, color = na, offset = 2, text = "     Lunes",
     textcolor = dayNameTone, size = size.tiny, editable = false, display = display.pane)
plotshape(drawDayName and namedWeekday == dayofweek.tuesday,
     "Martes", shape.labeldown, location.top, color = na, offset = 2, text = "     Martes",
     textcolor = dayNameTone, size = size.tiny, editable = false, display = display.pane)
plotshape(drawDayName and namedWeekday == dayofweek.wednesday,
     "Miércoles", shape.labeldown, location.top, color = na, offset = 2, text = "     Miércoles",
     textcolor = dayNameTone, size = size.tiny, editable = false, display = display.pane)
plotshape(drawDayName and namedWeekday == dayofweek.thursday,
     "Jueves", shape.labeldown, location.top, color = na, offset = 2, text = "     Jueves",
     textcolor = dayNameTone, size = size.tiny, editable = false, display = display.pane)
plotshape(drawDayName and namedWeekday == dayofweek.friday,
     "Viernes", shape.labeldown, location.top, color = na, offset = 2, text = "     Viernes",
     textcolor = dayNameTone, size = size.tiny, editable = false, display = display.pane)
plotshape(drawDayName and namedWeekday == dayofweek.saturday,
     "Sábado", shape.labeldown, location.top, color = na, offset = 2, text = "     Sábado",
     textcolor = dayNameTone, size = size.tiny, editable = false, display = display.pane)
plotshape(drawDayName and namedWeekday == dayofweek.sunday,
     "Domingo", shape.labeldown, location.top, color = na, offset = 2, text = "     Domingo",
     textcolor = dayNameTone, size = size.tiny, editable = false, display = display.pane)
````
