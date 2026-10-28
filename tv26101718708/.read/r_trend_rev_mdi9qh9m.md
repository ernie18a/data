# %R Trend Rev

- url: https://www.tradingview.com/script/MDI9qh9m/
- type: indicator
- pine_id: PUB;0ce05ba632a84cfc9a4ffb3d90419502
- version: 1.0

## Description

This script is an extended version of "%R Trend Exhaustion" by ＠upslidedown. Full credit to the original author for the dual Williams %R concept (fast 21 / slow 112) and the overbought/oversold exhaustion logic. This version keeps the original behavior available and adds signal-quality filters, trade levels and built-in performance statistics.

HOW IT WORKS
Two Williams %R lines (fast and slow) are calculated. When both are above -threshold the market is in an overbought trend; when both are below -100+threshold, an oversold trend. The original signal fires when price leaves that zone, suggesting the trend is exhausted.

WHAT'S NEW
1) Signal-quality filters (each can be toggled):
- Minimum time in zone: the zone must last at least N bars before its exit counts as a reversal. Removes 1–2 bar zone exits.
- Price confirmation: after the zone exit, the close must break the low (shorts) or high (longs) of the last N bars within a configurable window. The signal is cancelled if %R re-enters the zone.
- Internal divergence (optional): requires price to make a new extreme inside the zone while the fast %R fails to confirm it.
- Bar-close signals: signals are only confirmed on bar close to avoid intrabar repainting.

2) Higher-timeframe filter
Uses the slow %R from a higher timeframe (previous closed HTF bar, no lookahead repainting). Two modes: block signals against HTF extremes, or require HTF bias in the trade direction.

3) Trade levels
Each confirmed signal draws Entry, Stop Loss and two Take Profits. SL is placed beyond the OB/OS zone extreme plus an ATR buffer; TPs are R multiples. Alerts include these levels in the message.

4) Performance table
Tracks every confirmed signal until SL, TP or a max-bars timeout: win rate (total, long, short), expectancy in R, profit factor and average MFE/MAE in ATR. If SL and TP are hit in the same bar, it is counted as a loss (conservative). Use it to compare settings objectively on your instrument and timeframe.

5) Other improvements
Division-by-zero guard, OB/OS gradients linked to the threshold setting, consistent Average-formula mode, fixed zero-cross marker placement, and exit conditions for the TTS backtester signal (opposite signal or slow %R crossing -50).

HOW TO USE
Start with default settings, then turn filters on/off and watch the statistics table to see what each one contributes. The 112 slow period was originally tuned for crypto; validate it on your market before relying on it.

DISCLAIMER
The statistics are a simplified in-indicator simulation (no spread, commissions or slippage) and past results do not guarantee future performance. This is an analysis tool, not financial advice.

## Source Code

````pine
// © upslidedown — versión extendida
// Base: %R Trend Exhaustion v2.3 (dual %R 21/112 con zonas OB/OS).
// Mejoras v3.0:
//   • Filtros de calidad: duración mínima en zona, confirmación por ruptura de precio, divergencia en zona
//   • Filtro de temporalidad superior (sin repintado: [1] + lookahead_on)
//   • Setup operable: Entrada / SL (extremo de la zona + buffer ATR) / TP1 / TP2 en R
//   • Tabla de estadísticas: win rate, expectancy en R, profit factor, MFE/MAE en ATR
//   • Señales solo al cierre de vela (opcional), salidas para TTS, correcciones varias

//@version=6
import HeWhoMustNotBeNamed/ta/1
indicator("%R Trend Exhaustion+ [upslidedown mod]", shorttitle="%RTE+", format=format.price, precision=2, explicit_plot_zorder=true, max_boxes_count=300, max_lines_count=500, max_labels_count=500)

const string version = "v3.0"
const string groupSettings = "Settings " + version

// ═══════════════════════════════════════════════════════════════════════════════
// TIPOS
// ═══════════════════════════════════════════════════════════════════════════════
type Trade
    int   dir
    int   startBar
    float entry
    float sl
    float tp
    float rr
    float risk
    float atr0
    float mfe = 0.0
    float mae = 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — GENERALES
// ═══════════════════════════════════════════════════════════════════════════════
var bullcol = input.color(#2466A7, 'Cold Color', group=groupSettings, inline="col")
var bearcol = input.color(#CA0017, 'Hot Color', group=groupSettings, inline="col")
var invisible = color.rgb(0, 0, 0, 100)

force_overlay = input.bool(true, title="Draw Boxes on Chart", group=groupSettings, inline='overlay')
max_boxes_to_print = input.int(60, title="#", minval=1, maxval=300, group=groupSettings, inline='overlay', active=force_overlay)

const string mode1 = "1 Oscillator Mode"
const string mode2 = "2 Overlay Mode (top and bottom no oscillator)"
const string mode3 = "3 Candle Mode"
mode = input.string(mode1, "Display Mode", options=[mode1, mode2, mode3], tooltip="Modes 2 & 3 are more advanced and expect that you most likely overlay the indicator on top of price action itself or another indiciator using TradingView's object tree panel.", group=groupSettings)
compact = mode == mode2

transparency = input.int(80, 'Base Transparency', minval=20, maxval=100, group=groupSettings)
var bullcol_xlight = color.new(bullcol, transparency)
var bearcol_xlight = color.new(bearcol, transparency)
var bullcol_light = color.new(bullcol, transparency - 10)
var bearcol_light = color.new(bearcol, transparency - 10)
var bullcol_medium = color.new(bullcol, transparency - 20)
var bearcol_medium = color.new(bearcol, transparency - 20)
var shortcol = chart.fg_color
var longcol = color.rgb(139, 174, 255)
const int bull_signal_loc = -107
const int bear_signal_loc = 5

formula1 = "Standard (2 Period)"
formula2 = "Average"
formula = input.string(formula1, "Formula", options=[formula1, formula2], group=groupSettings)
use_average = formula == formula2

src = input.source(close, "Source", group=groupSettings)
threshold = input.int(20, title="Exhaustion Threshold", minval=1, maxval=50, group=groupSettings, tooltip="Sets the overbought/oversold zone size and offset. Lower values will produce less results, higher values towards 50 will produce many results.")
smoothType = input.string('ema', title="Smoothing Type", options=['sma', 'ema', 'hma', 'rma', 'wma', 'vwma', 'swma', 'highlow', 'linreg', 'median', 'mom', 'percentrank'], group=groupSettings)
average_ma = input.int(3, "Average Formula MA", group=groupSettings)

plot_shading = input.bool(true, title="Fill Gradients in OB/OS Zone", group=groupSettings)
plot_crosses = input.bool(false, title="Highlight Crossovers", group=groupSettings, tooltip="Experimental idea for plotting crossovers with attempted bull/bear coloring. Disabled in Average mode.")
plot_zero_crosses = input.bool(false, title="Plot Zero Line Crosses", group=groupSettings, tooltip="Experimental idea for plotting crosses")

const string lookbackGroupName = "Dual Signal Setup (Fast/Slow Lookback)"
shortLength = input.int(title="Fast Length", defval=21, group=lookbackGroupName)
shortSmoothingLength = input.int(7, title="Fast Smoothing Length", group=lookbackGroupName)
longLength = input.int(112, title="Slow Length", minval=1, group=lookbackGroupName)
longSmoothingLength = input.int(3, title="Slow Smoothing Length", group=lookbackGroupName)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — MEJORAS
// ═══════════════════════════════════════════════════════════════════════════════
const string gFilt = "Filtros de calidad"
useMinBars = input.bool(true, "Duración mínima en zona", group=gFilt, inline="mb")
minBars    = input.int(3, "", minval=1, group=gFilt, inline="mb", tooltip="Barras mínimas en OB/OS antes de que la salida de la zona cuente como reversal. Elimina salidas de zona de 1-2 velas.")
useConfirm = input.bool(true, "Confirmación por ruptura de precio", group=gFilt)
confBars   = input.int(2, "Barras de referencia", minval=1, group=gFilt, tooltip="Short: el cierre debe quedar bajo el mínimo de las últimas N velas. Long: sobre el máximo.")
confWindow = input.int(3, "Ventana para confirmar (barras)", minval=0, group=gFilt, tooltip="Barras después de salir de la zona en las que se acepta la confirmación. Se cancela si el %R vuelve a entrar en la zona.")
useDiv     = input.bool(false, "Exigir divergencia en la zona", group=gFilt, inline="dv")
divMargin  = input.float(2.0, "Margen", minval=0, step=0.5, group=gFilt, inline="dv", tooltip="Dentro de la zona: el precio marca nuevo extremo y el %R rápido queda al menos este margen por debajo (OB) / encima (OS) de su valor en el extremo anterior.")
noRepaint  = input.bool(true, "Señales solo al cierre de vela", group=gFilt)
showRaw    = input.bool(false, "Mostrar reversals sin filtrar (tenue)", group=gFilt)

const string gHtf = "Temporalidad superior"
const string hm1 = "Bloquear contra extremos"
const string hm2 = "Exigir sesgo a favor"
useHtf      = input.bool(false, "Filtrar con %R lento de TF superior", group=gHtf)
htf         = input.timeframe("D", "TF superior", group=gHtf)
htfMode     = input.string(hm1, "Modo", options=[hm1, hm2], group=gHtf, tooltip="Bloquear contra extremos: no hay shorts si el HTF está en OB, ni longs si está en OS.\nExigir sesgo a favor: shorts solo si el %R HTF < -50, longs solo si > -50.")
htfThr      = input.int(20, "Umbral extremo HTF", minval=1, maxval=50, group=gHtf)
showHtfLine = input.bool(false, "Mostrar %R HTF en oscilador", group=gHtf)

const string gSetup = "Setup (Entrada / SL / TP)"
showSetup        = input.bool(true, "Dibujar niveles en el gráfico", group=gSetup)
showChartSignals = input.bool(true, "Etiqueta REV en las velas", group=gSetup)
maxSetups        = input.int(5, "Setups visibles", minval=1, maxval=100, group=gSetup)
setupLen         = input.int(15, "Largo de líneas (barras)", minval=1, maxval=400, group=gSetup)
atrLen           = input.int(14, "Periodo ATR", minval=1, group=gSetup)
slBuf            = input.float(0.25, "Buffer SL (x ATR)", minval=0, step=0.05, group=gSetup, tooltip="SL = extremo de la zona OB/OS (o de las velas recientes, el que sea más lejano) ± buffer x ATR.")
rr1              = input.float(1.5, "TP1 (R)", minval=0.1, step=0.1, group=gSetup)
rr2              = input.float(3.0, "TP2 (R)", minval=0.1, step=0.1, group=gSetup)
tpCol            = input.color(#2E9E5B, "Color TP", group=gSetup)

const string gStats = "Estadísticas"
showStats   = input.bool(true, "Mostrar tabla", group=gStats)
statsPosStr = input.string("Arriba derecha", "Posición", options=["Arriba derecha", "Arriba izquierda", "Abajo derecha", "Abajo izquierda"], group=gStats)
statsTarget = input.string("TP1", "Objetivo evaluado", options=["TP1", "TP2"], group=gStats)
maxHold     = input.int(30, "Máx. barras por trade", minval=1, group=gStats, tooltip="Si no toca SL ni TP en este número de barras, se cierra al precio de cierre (timeout).")

// ═══════════════════════════════════════════════════════════════════════════════
// CÁLCULO %R
// ═══════════════════════════════════════════════════════════════════════════════
_pr(length) =>
    float hi = ta.highest(length)
    float lo = ta.lowest(length)
    hi == lo ? -50.0 : 100 * (src - hi) / (hi - lo)

float s_percentR = _pr(shortLength)
float l_raw = _pr(longLength)
float l_percentR = l_raw
float avg_percentR = math.avg(s_percentR, l_percentR)

if shortSmoothingLength > 1
    s_percentR := ta.ma(s_percentR, smoothType, shortSmoothingLength)
if longSmoothingLength > 1
    l_percentR := ta.ma(l_percentR, smoothType, longSmoothingLength)
if average_ma > 1
    avg_percentR := ta.ma(avg_percentR, smoothType, average_ma)

// %R lento de temporalidad superior — barra HTF cerrada, sin repintado
float htfR = request.security(syminfo.tickerid, htf, l_raw[1], lookahead=barmerge.lookahead_on)
if useHtf and timeframe.in_seconds(htf) < timeframe.in_seconds()
    runtime.error("El TF superior debe ser mayor o igual al TF del gráfico.")

// ═══════════════════════════════════════════════════════════════════════════════
// LÓGICA OB / OS
// ═══════════════════════════════════════════════════════════════════════════════
bool overbought = s_percentR >= -threshold and l_percentR >= -threshold
bool oversold = s_percentR <= -100 + threshold and l_percentR <= -100 + threshold

bool bool_cross_long1 = ta.crossover(s_percentR, -50)
bool bool_cross_long2 = ta.crossover(l_percentR, -50)
bool bool_cross_short1 = ta.crossunder(s_percentR, -50)
bool bool_cross_short2 = ta.crossunder(l_percentR, -50)
bool avg_cross_up = ta.crossover(avg_percentR, -50)
bool avg_cross_dn = ta.crossunder(avg_percentR, -50)

bool zero_long = (s_percentR > -50 and l_percentR > -50) and (bool_cross_long1 or bool_cross_long2)
bool zero_short = (s_percentR < -50 and l_percentR < -50) and (bool_cross_short1 or bool_cross_short2)

if use_average
    overbought := avg_percentR >= -threshold
    oversold := avg_percentR <= -100 + threshold
    zero_long := avg_cross_up
    zero_short := avg_cross_dn

bool ob_reversal = not overbought and overbought[1]
bool os_reversal = not oversold and oversold[1]
bool ob_trend_start = overbought and not overbought[1]
bool os_trend_start = oversold and not oversold[1]

// Cruces entre líneas (solo tienen sentido en modo estándar)
bool cross_bear = ta.crossover(l_percentR, s_percentR) and not use_average
bool cross_bull = ta.crossunder(l_percentR, s_percentR) and not use_average

// Salidas del %R lento por -50 (para exits de TTS)
bool slow_cross_dn = use_average ? avg_cross_dn : bool_cross_short2
bool slow_cross_up = use_average ? avg_cross_up : bool_cross_long2

// ═══════════════════════════════════════════════════════════════════════════════
// FILTROS DE CALIDAD
// ═══════════════════════════════════════════════════════════════════════════════
// Duración en zona
var int obCount = 0
var int osCount = 0
obCount := overbought ? obCount + 1 : 0
osCount := oversold ? osCount + 1 : 0

// Extremos de la zona + divergencia interna
float divR = use_average ? avg_percentR : s_percentR
var float obHi = na
var float obRAtHi = na
var bool obDiv = false
var float osLo = na
var float osRAtLo = na
var bool osDiv = false

if ob_trend_start
    obHi := high
    obRAtHi := divR
    obDiv := false
else if overbought and high > obHi
    if divR < obRAtHi - divMargin
        obDiv := true
    obHi := high
    obRAtHi := divR

if os_trend_start
    osLo := low
    osRAtLo := divR
    osDiv := false
else if oversold and low < osLo
    if divR > osRAtLo + divMargin
        osDiv := true
    osLo := low
    osRAtLo := divR

// Temporalidad superior
bool htfShortOk = na(htfR) or (htfMode == hm1 ? htfR < -htfThr : htfR < -50)
bool htfLongOk = na(htfR) or (htfMode == hm1 ? htfR > -100 + htfThr : htfR > -50)

// Reversal base (filtrado)
bool bearBase = ob_reversal and (not useMinBars or obCount[1] >= minBars) and (not useDiv or obDiv) and (not useHtf or htfShortOk)
bool bullBase = os_reversal and (not useMinBars or osCount[1] >= minBars) and (not useDiv or osDiv) and (not useHtf or htfLongOk)

// Confirmación por precio con ventana
float recentLow = ta.lowest(low, confBars)[1]
float recentHigh = ta.highest(high, confBars)[1]
bool barOk = not noRepaint or barstate.isconfirmed

var int bearPend = na
var int bullPend = na
if bearBase
    bearPend := bar_index
if bullBase
    bullPend := bar_index

bool bearSignal = false
bool bullSignal = false

if barOk and not na(bearPend)
    if not useConfirm
        bearSignal := true
        bearPend := na
    else if overbought or bar_index - bearPend > confWindow
        bearPend := na
    else if close < recentLow
        bearSignal := true
        bearPend := na

if barOk and not na(bullPend)
    if not useConfirm
        bullSignal := true
        bullPend := na
    else if oversold or bar_index - bullPend > confWindow
        bullPend := na
    else if close > recentHigh
        bullSignal := true
        bullPend := na

// ═══════════════════════════════════════════════════════════════════════════════
// PLOTS OSCILADOR
// ═══════════════════════════════════════════════════════════════════════════════
top = hline(mode == mode1 ? 0 : na, 'Top', bearcol_medium, linestyle=hline.style_solid)
band1 = hline(mode == mode1 ? -threshold : na, 'Top Threshold', bearcol_medium, linestyle=hline.style_solid)
middle = hline(mode == mode1 ? -50 : na, 'Middle Line', color.new(chart.fg_color, 80), linestyle=hline.style_solid)
band0 = hline(mode == mode1 ? -100 + threshold : na, 'Bottom Threshold', bullcol_medium, linestyle=hline.style_solid)
bottom = hline(mode == mode1 ? -100 : na, 'Bottom', bullcol_medium, linestyle=hline.style_solid)

p_fastr = plot(mode == mode1 and not use_average ? s_percentR : na, "Fast Period %R", color=shortcol, linewidth=1)
p_slowr = plot(mode == mode1 and not use_average ? l_percentR : na, "Slow Period %R", color=longcol, linewidth=1)
p_avgr = plot(mode == mode1 and use_average ? avg_percentR : na, "Average Formula %R", color=shortcol, linewidth=1)
plot(mode == mode1 and useHtf and showHtfLine ? htfR : na, "HTF Slow %R", color=color.new(color.orange, 30), linewidth=2, style=plot.style_stepline)

gradientBullColor = plot_shading ? color.new(bullcol, 100) : invisible
gradientBearColor = plot_shading ? color.new(bearcol, 100) : invisible
fill(p_fastr, p_slowr, 0, -threshold, top_color=color.new(gradientBearColor, 0), bottom_color=gradientBearColor, title="Overbought Gradient Fill")
fill(p_fastr, p_slowr, -100 + threshold, -100, top_color=gradientBullColor, bottom_color=color.new(gradientBullColor, 0), title="Oversold Gradient Fill")

getlocation(mode, tORb) =>
    location = location.absolute
    if (mode == mode2 or mode == mode3)
        if tORb == 'top'
            location := mode == mode3 ? location.abovebar : location.top
        else if tORb == 'bottom'
            location := mode == mode3 ? location.belowbar : location.bottom
    location

// Reversals: confirmados (color pleno) y sin filtrar (tenue, opcional)
plotshape(bearSignal ? bear_signal_loc : na, title="Reversal confirmado ▼", style=shape.triangledown, location=getlocation(mode, 'top'), color=bearcol, size=size.small)
plotshape(bullSignal ? bull_signal_loc : na, title="Reversal confirmado ▲", style=shape.triangleup, location=getlocation(mode, 'bottom'), color=bullcol, size=size.small)
plotshape(showRaw and ob_reversal ? bear_signal_loc : na, title="Reversal sin filtrar ▼", style=shape.triangledown, location=getlocation(mode, 'top'), color=bearcol_light, size=size.tiny)
plotshape(showRaw and os_reversal ? bull_signal_loc : na, title="Reversal sin filtrar ▲", style=shape.triangleup, location=getlocation(mode, 'bottom'), color=bullcol_light, size=size.tiny)

plotshape(overbought ? bear_signal_loc : na, title="Overbought Trend Warning ■", style=shape.square, location=getlocation(mode, 'top'), color=bearcol_medium, size=size.tiny)
plotshape(oversold ? bull_signal_loc : na, title="Oversold Trend Warning ■", style=shape.square, location=getlocation(mode, 'bottom'), color=bullcol_medium, size=size.tiny)

// Zero crosses (corregido: long abajo ▲, short arriba ▼)
plotshape(zero_long and plot_zero_crosses ? bull_signal_loc : na, title="Zero Cross Long", style=shape.triangleup, location=getlocation(mode, 'bottom'), color=color.yellow, size=size.tiny)
plotshape(zero_short and plot_zero_crosses ? bear_signal_loc : na, title="Zero Cross Short", style=shape.triangledown, location=getlocation(mode, 'top'), color=color.yellow, size=size.tiny)

plot(not compact and plot_crosses and (cross_bull or cross_bear) ? l_percentR : na, "Crossover Dot (small)", style=plot.style_circles, color=cross_bull ? bullcol : bearcol, linewidth=4)
plot(not compact and plot_crosses and (cross_bull or cross_bear) ? l_percentR : na, "Crossover Dot (big)", style=plot.style_circles, color=cross_bull ? bullcol_light : bearcol_light, linewidth=12)

plotchar(ob_trend_start ? bear_signal_loc : na, char="◡", color=bearcol, location=getlocation(mode, 'top'))
plotchar(os_trend_start ? bull_signal_loc : na, char="◠", color=bullcol, location=getlocation(mode, 'bottom'))

// ═══════════════════════════════════════════════════════════════════════════════
// PLOTS SOBRE EL PRECIO
// ═══════════════════════════════════════════════════════════════════════════════
plotshape(force_overlay and bearSignal ? nz(obHi, high) : na, title="Overbought Break Candle ▼", style=shape.triangledown, location=location.absolute, color=bearcol, size=size.tiny, force_overlay=true)
plotshape(force_overlay and bullSignal ? nz(osLo, low) : na, title="Oversold Break Candle ▲", style=shape.triangleup, location=location.absolute, color=bullcol, size=size.tiny, force_overlay=true)
plotshape(showChartSignals and bearSignal, title="REV Short", style=shape.labeldown, location=location.abovebar, color=bearcol, text="REV", textcolor=color.white, size=size.small, force_overlay=true)
plotshape(showChartSignals and bullSignal, title="REV Long", style=shape.labelup, location=location.belowbar, color=bullcol, text="REV", textcolor=color.white, size=size.small, force_overlay=true)

// Cajas OB/OS (lógica original)
var box ob_box = na
var box os_box = na
var float ob_box_top = na
var float ob_box_bottom = na
var float os_box_top = na
var float os_box_bottom = na
var array<box> printed_boxes = array.new_box()

if force_overlay
    if ob_trend_start
        if not na(ob_box)
            box.delete(ob_box)
        ob_box_top := high
        ob_box_bottom := low
        ob_box := box.new(bar_index - 1, ob_box_top, bar_index, ob_box_bottom, bgcolor=bearcol_xlight, border_color=bearcol_medium, border_width=1, force_overlay=true)
        array.push(printed_boxes, ob_box)
        if array.size(printed_boxes) > max_boxes_to_print
            box.delete(array.shift(printed_boxes))
    else if overbought and not na(ob_box)
        box.set_right(ob_box, bar_index)
        if high > ob_box_top
            ob_box_top := high
            box.set_top(ob_box, ob_box_top)
        if low < ob_box_bottom
            ob_box_bottom := low
            box.set_bottom(ob_box, ob_box_bottom)
    else if not overbought and not na(ob_box)
        box.set_right(ob_box, bar_index - 1)
        ob_box := na

    if os_trend_start
        if not na(os_box)
            box.delete(os_box)
        os_box_top := high
        os_box_bottom := low
        os_box := box.new(bar_index - 1, os_box_top, bar_index, os_box_bottom, bgcolor=bullcol_xlight, border_color=bullcol_medium, border_width=1, force_overlay=true)
        array.push(printed_boxes, os_box)
        if array.size(printed_boxes) > max_boxes_to_print
            box.delete(array.shift(printed_boxes))
    else if oversold and not na(os_box)
        box.set_right(os_box, bar_index)
        if high > os_box_top
            os_box_top := high
            box.set_top(os_box, os_box_top)
        if low < os_box_bottom
            os_box_bottom := low
            box.set_bottom(os_box, os_box_bottom)
    else if not oversold and not na(os_box)
        box.set_right(os_box, bar_index - 1)
        os_box := na

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTAS — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
const string groupAlerts = "Alerts"
bullStartOn = input.bool(true, "Bull trend start ⏹", group=groupAlerts, inline="bullStart")
bullStartTxt = input.string("%RTE bull trend start ⏹", "", group=groupAlerts, inline="bullStart")
bearStartOn = input.bool(true, "Bear trend start ⏹", group=groupAlerts, inline="bearStart")
bearStartTxt = input.string("%RTE bear trend start ⏹", "", group=groupAlerts, inline="bearStart")
bullReversalOn = input.bool(true, "Bull trend break ▼ (confirmado)", group=groupAlerts, inline="bullReversal")
bullReversalTxt = input.string("%RTE SHORT ▼", "", group=groupAlerts, inline="bullReversal")
bearReversalOn = input.bool(true, "Bear trend break ▲ (confirmado)", group=groupAlerts, inline="bearReversal")
bearReversalTxt = input.string("%RTE LONG ▲", "", group=groupAlerts, inline="bearReversal")
bullCrossOn = input.bool(false, "Bull cross ⏺", group=groupAlerts, inline="bullCross")
bullCrossTxt = input.string("Bullish crossover", "", group=groupAlerts, inline="bullCross")
bearCrossOn = input.bool(false, "Bear cross ⏺", group=groupAlerts, inline="bearCross")
bearCrossTxt = input.string("Bearish crossover", "", group=groupAlerts, inline="bearCross")

// ═══════════════════════════════════════════════════════════════════════════════
// SETUP (ENTRADA / SL / TP) + REGISTRO DE TRADES
// ═══════════════════════════════════════════════════════════════════════════════
float atrV = ta.atr(atrLen)
float hhRecent = ta.highest(high, confWindow + 2)
float llRecent = ta.lowest(low, confWindow + 2)

var array<line> setupLines = array.new_line()
var array<label> setupLabels = array.new_label()
var array<Trade> openTrades = array.new<Trade>()

drawLevel(float price, color col, string txt) =>
    array.push(setupLines, line.new(bar_index, price, bar_index + setupLen, price, color=col, width=1, force_overlay=true))
    array.push(setupLabels, label.new(bar_index + setupLen, price, txt + " " + str.tostring(price, format.mintick), style=label.style_label_left, color=color.new(color.black, 100), textcolor=col, size=size.small, force_overlay=true))

openSetup(int dir, float entry, float slRaw) =>
    float risk = math.max(math.abs(entry - slRaw), syminfo.mintick)
    float sl = entry - dir * risk
    float tp1 = entry + dir * risk * rr1
    float tp2 = entry + dir * risk * rr2
    if showSetup
        drawLevel(entry, chart.fg_color, "Entrada")
        drawLevel(sl, bearcol, "SL")
        drawLevel(tp1, tpCol, "TP1")
        drawLevel(tp2, tpCol, "TP2")
        while array.size(setupLines) > maxSetups * 4
            line.delete(array.shift(setupLines))
        while array.size(setupLabels) > maxSetups * 4
            label.delete(array.shift(setupLabels))
    float tgtR = statsTarget == "TP1" ? rr1 : rr2
    array.push(openTrades, Trade.new(dir=dir, startBar=bar_index, entry=entry, sl=sl, tp=entry + dir * risk * tgtR, rr=tgtR, risk=risk, atr0=nz(atrV, risk)))
    [sl, tp1, tp2]

levelsTxt(float entry, float sl, float tp1, float tp2) =>
    " | Entrada " + str.tostring(entry, format.mintick) + " | SL " + str.tostring(sl, format.mintick) + " | TP1 " + str.tostring(tp1, format.mintick) + " | TP2 " + str.tostring(tp2, format.mintick)

// ── Estadísticas: actualizar trades abiertos (antes de abrir nuevos)
var int nWin = 0
var int nLoss = 0
var int nTime = 0
var int nLong = 0
var int nLongWin = 0
var int nShort = 0
var int nShortWin = 0
var float sumR = 0.0
var float grossWin = 0.0
var float grossLoss = 0.0
var float sumMfe = 0.0
var float sumMae = 0.0

if array.size(openTrades) > 0
    for i = array.size(openTrades) - 1 to 0
        Trade t = array.get(openTrades, i)
        if bar_index > t.startBar
            float fav = t.dir == 1 ? high - t.entry : t.entry - low
            float adv = t.dir == 1 ? t.entry - low : high - t.entry
            t.mfe := math.max(t.mfe, fav / t.atr0)
            t.mae := math.max(t.mae, adv / t.atr0)
            bool hitSL = t.dir == 1 ? low <= t.sl : high >= t.sl
            bool hitTP = t.dir == 1 ? high >= t.tp : low <= t.tp
            bool timedOut = bar_index - t.startBar >= maxHold
            if hitSL or hitTP or timedOut
                // Si SL y TP caen en la misma vela, se cuenta como pérdida (conservador)
                float r = hitSL ? -1.0 : hitTP ? t.rr : (close - t.entry) * t.dir / t.risk
                bool isWin = not hitSL and hitTP
                if hitSL
                    nLoss += 1
                else if hitTP
                    nWin += 1
                else
                    nTime += 1
                if t.dir == 1
                    nLong += 1
                    nLongWin += isWin ? 1 : 0
                else
                    nShort += 1
                    nShortWin += isWin ? 1 : 0
                sumR += r
                grossWin += math.max(r, 0)
                grossLoss += math.max(-r, 0)
                sumMfe += t.mfe
                sumMae += t.mae
                array.remove(openTrades, i)

// ── Nuevas señales → setup + alerta con niveles
if bearSignal
    [sl, tp1, tp2] = openSetup(-1, close, math.max(nz(obHi, high), hhRecent) + slBuf * nz(atrV))
    if bullReversalOn
        alert(bullReversalTxt + " " + syminfo.ticker + levelsTxt(close, sl, tp1, tp2), alert.freq_once_per_bar_close)

if bullSignal
    [sl, tp1, tp2] = openSetup(1, close, math.min(nz(osLo, low), llRecent) - slBuf * nz(atrV))
    if bearReversalOn
        alert(bearReversalTxt + " " + syminfo.ticker + levelsTxt(close, sl, tp1, tp2), alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════════════════════════════════════════
// TABLA DE ESTADÍSTICAS
// ═══════════════════════════════════════════════════════════════════════════════
statsPos = switch statsPosStr
    "Arriba izquierda" => position.top_left
    "Abajo derecha"    => position.bottom_right
    "Abajo izquierda"  => position.bottom_left
    => position.top_right

var table statsTbl = table.new(statsPos, 2, 11, bgcolor=color.new(chart.bg_color, 5), frame_color=color.new(chart.fg_color, 70), frame_width=1, border_color=color.new(chart.fg_color, 85), border_width=1)

fmtPct(int a, int b) =>
    b > 0 ? str.tostring(100.0 * a / b, "#.#") + "%" : "—"

statRow(int row, string k, string v, color vc) =>
    table.cell(statsTbl, 0, row, k, text_color=chart.fg_color, text_size=size.small, text_halign=text.align_left)
    table.cell(statsTbl, 1, row, v, text_color=vc, text_size=size.small, text_halign=text.align_right)

if showStats and barstate.islast
    int nClosed = nWin + nLoss + nTime
    float expR = nClosed > 0 ? sumR / nClosed : na
    float pf = grossLoss > 0 ? grossWin / grossLoss : na
    color good = tpCol
    color bad = bearcol
    statRow(0, "%RTE+ · objetivo " + statsTarget, str.tostring(maxHold) + " barras máx.", chart.fg_color)
    statRow(1, "Trades cerrados", str.tostring(nClosed), chart.fg_color)
    statRow(2, "Win rate (TP)", fmtPct(nWin, nClosed), chart.fg_color)
    statRow(3, "Long WR", fmtPct(nLongWin, nLong) + " (" + str.tostring(nLong) + ")", bullcol)
    statRow(4, "Short WR", fmtPct(nShortWin, nShort) + " (" + str.tostring(nShort) + ")", bearcol)
    statRow(5, "SL / Timeout", str.tostring(nLoss) + " / " + str.tostring(nTime), chart.fg_color)
    statRow(6, "Expectancy (R)", na(expR) ? "—" : str.tostring(expR, "#.##"), na(expR) ? chart.fg_color : expR > 0 ? good : bad)
    statRow(7, "Profit factor", na(pf) ? "—" : str.tostring(pf, "#.##"), na(pf) ? chart.fg_color : pf > 1 ? good : bad)
    statRow(8, "MFE prom. (ATR)", nClosed > 0 ? str.tostring(sumMfe / nClosed, "#.##") : "—", chart.fg_color)
    statRow(9, "MAE prom. (ATR)", nClosed > 0 ? str.tostring(sumMae / nClosed, "#.##") : "—", chart.fg_color)
    statRow(10, "Abiertos", str.tostring(array.size(openTrades)), chart.fg_color)

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTAS RESTANTES
// ═══════════════════════════════════════════════════════════════════════════════
if bullStartOn and ob_trend_start
    alert(message=bullStartTxt, freq=alert.freq_once_per_bar_close)
if bearStartOn and os_trend_start
    alert(message=bearStartTxt, freq=alert.freq_once_per_bar_close)
if bullCrossOn and cross_bull
    alert(message=bullCrossTxt, freq=alert.freq_once_per_bar_close)
if bearCrossOn and cross_bear
    alert(message=bearCrossTxt, freq=alert.freq_once_per_bar_close)

alertcondition(bearSignal, "Reversal bajista confirmado", message="%RTE+: reversal bajista confirmado")
alertcondition(bullSignal, "Reversal alcista confirmado", message="%RTE+: reversal alcista confirmado")
alertcondition(ob_reversal, "Arrow Down sin filtrar", message="Arrow Down: Overbought trend is exhausted")
alertcondition(os_reversal, "Arrow Up sin filtrar", message="Arrow Up: Oversold trend is exhausted")
alertcondition(ob_trend_start, "Overbought Trend Started", message="Warning: Possible overbought trend exhaustion")
alertcondition(os_trend_start, "Oversold Trend Started", message="Warning: Possible oversold trend exhaustion")
alertcondition(cross_bull, "Bullish Crossover", message="Potential bullish crossover printed")
alertcondition(cross_bear, "Bearish Crossover", message="Potential bearish crossover printed")

// ═══════════════════════════════════════════════════════════════════════════════
// ESTRATEGIA → SEÑAL EXTERNA PARA TTS
// ═══════════════════════════════════════════════════════════════════════════════
const string group_strategy = "Strategy (send external signal to TTS backtester)"

bool plotStrategyEntry = input.bool(false, "Plot Strategy Entries on Chart", group=group_strategy)
bool longDealsEnabled = input.bool(true, "Enable Long Deals", group=group_strategy)
bool shortDealsEnabled = input.bool(true, "Enable Short Deals", group=group_strategy)

strategy1 = "1 Trend Following @ Square"
strategy2 = "2 Reversal @ Square"
strategy3 = "3 Reversal Trade @ Triangle"
strategy4 = "4 Re-enter Trend Trade @ Triangle"
strategy5 = "5 Pings"
strategy6 = "6 Zero Line Cross"
strategyEntry = input.string(strategy3, "Strategy Entry", options=[strategy1, strategy2, strategy3, strategy4, strategy5, strategy6], group=group_strategy, tooltip="Las estrategias 3 y 4 usan los reversals confirmados (con filtros).")

const string ex1 = "Ninguna"
const string ex2 = "Señal opuesta"
const string ex3 = "Cruce de -50 del %R lento"
exitMode = input.string(ex1, "Salida", options=[ex1, ex2, ex3], group=group_strategy)

bool startLongDeal = false
bool startShortDeal = false

switch strategyEntry
    strategy1 =>
        if ob_trend_start and longDealsEnabled
            startLongDeal := true
        else if os_trend_start and shortDealsEnabled
            startShortDeal := true
    strategy2 =>
        if os_trend_start and longDealsEnabled
            startLongDeal := true
        else if ob_trend_start and shortDealsEnabled
            startShortDeal := true
    strategy3 =>
        if bearSignal and shortDealsEnabled
            startShortDeal := true
        else if bullSignal and longDealsEnabled
            startLongDeal := true
    strategy4 =>
        if bullSignal and shortDealsEnabled
            startShortDeal := true
        else if bearSignal and longDealsEnabled
            startLongDeal := true
    strategy5 =>
        if cross_bull and longDealsEnabled
            startLongDeal := true
        else if cross_bear and shortDealsEnabled
            startShortDeal := true
    strategy6 =>
        if zero_long and longDealsEnabled
            startLongDeal := true
        else if zero_short and shortDealsEnabled
            startShortDeal := true

bool endLongDeal = exitMode == ex2 ? startShortDeal : exitMode == ex3 ? slow_cross_dn : false
bool endShortDeal = exitMode == ex2 ? startLongDeal : exitMode == ex3 ? slow_cross_up : false

//#region 🔌 SIGNAL
import jason5480/tts_convention/7 as conv

dealConditions = conv.DealConditions.new(
  startLongDeal = startLongDeal,
  startShortDeal = startShortDeal,
  endLongDeal = endLongDeal,
  endShortDeal = endShortDeal)

plot(series = conv.getSignal(dealConditions), title = '🔌Signal to TTS', color = #808000, editable = false, display = display.data_window + display.status_line, precision = 0)

plotshape(plotStrategyEntry ? dealConditions.startLongDeal : false, title = 'Start Long', style = shape.triangleup, location = location.belowbar, color = bullcol, size = size.tiny, text = "Long", textcolor = chart.fg_color, display = display.all - display.status_line, force_overlay = true)
plotshape(plotStrategyEntry ? dealConditions.startShortDeal : false, title = 'Start Short', style = shape.triangledown, location = location.abovebar, color = bearcol, size = size.tiny, text = "Short", textcolor = chart.fg_color, display = display.all - display.status_line, force_overlay = true)
//#endregion
````
