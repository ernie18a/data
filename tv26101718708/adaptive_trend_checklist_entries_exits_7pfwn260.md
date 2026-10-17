# Adaptive Trend Checklist Entries Exits

- url: https://www.tradingview.com/script/7pFWN260/
- type: indicator
- pine_id: PUB;9faa459a5d3f422a963af937be939e8e
- version: 1.0

## Description

English Description

Adaptive Trend Checklist PRO Optimal Entries and Exits

Adaptive Trend Checklist PRO is an advanced trend following and trade management indicator designed to help traders identify higher quality long and short opportunities directly on the chart.

The script combines trend direction, momentum, ADX strength, Supertrend, moving average bias, higher timeframe confirmation, risk management levels and automated alerts into a single visual trading framework.

Its purpose is not to predict the market with certainty, but to help the trader make more structured decisions by filtering weak setups, identifying valid entry conditions and managing exits through predefined technical logic.

Main Functionalities

1. Adaptive automatic mode by timeframe

The indicator can automatically adjust its internal parameters depending on the chart timeframe.

It adapts the moving average length, ATR length, Supertrend factor, ADX length, ADX minimum threshold, higher timeframe references and trading mode.

This allows the script to behave differently on scalping, intraday and swing trading timeframes.

2. Manual mode

Users can disable automatic mode and manually configure the trading mode, moving average period, ATR period, Supertrend factor, ADX minimum value, ADX length and higher timeframe confirmations.

This is useful for traders who want full control over the strategy logic.

3. Visual checklist panel

The script includes a visual checklist table showing the current market context.

The checklist displays the system mode, trading mode, higher timeframe trend state, moving average trend bias, Supertrend direction, ADX condition, current active trade direction, market session, risk status and last exit reason.

This panel helps the trader quickly understand whether the market is aligned for a potential trade.

4. Long and short entry signals

The indicator generates potential long and short entries when several conditions align.

The entry logic may include price above or below the selected moving average, price above or below the Supertrend, ADX confirming sufficient trend strength, higher timeframe confirmation, momentum trigger and no trade range filter.

The script marks entries directly on the chart with visual signals.

5. Optimal entry price

When a valid setup appears, the script calculates and displays a suggested entry price based on the close of the confirmed signal candle.

It also draws a horizontal entry line on the chart so the trader can clearly see the reference level.

6. Smart stop loss calculation

The stop loss is calculated using a combination of Supertrend distance, recent swing structure, volatility adjustment and timeframe based multiplier.

The aim is to avoid placing the stop too close to market noise while still maintaining a controlled risk profile.

7. Take profit levels

The script automatically calculates and displays three take profit levels called TP1, TP2 and TP3.

These levels are based on the real distance between entry and stop loss, using a risk reward structure.

8. Trailing stop

The indicator includes a trailing stop logic based on Supertrend movement.

The trailing stop is designed to protect profits as price moves in favor of the trade, without worsening the original stop loss.

9. Optimal exit logic

The script can trigger exit signals depending on the selected exit mode.

Available exit modes include TP1, TP2, TP3, TP2 plus trailing stop, trailing Supertrend and trend reversal.

The script also displays the reason for the last exit on the chart and in the checklist.

10. Trade management table

A separate management panel shows account capital, risk amount, entry price, stop loss, TP1, TP2, TP3, trailing stop and suggested position size in dollars.

This allows the trader to evaluate the risk and position size before entering the trade.

11. Automated alerts

The script includes alert conditions for optimal long entry, optimal short entry, optimal long exit, optimal short exit, general entry signal and general exit signal.

It also includes dynamic runtime alerts using alert function, which can provide detailed messages including entry price, stop loss and take profit levels.

How to Use

1. Add the script to your TradingView chart.

2. Choose whether to use Automatic Mode or Manual Mode.

3. Select your preferred trading style, Conservative, Aggressive or Ultra Aggressive.

4. Adjust the higher timeframe filters if needed.

5. Choose the desired exit mode.

6. Wait for a confirmed long or short signal.

7. Use the displayed entry, stop loss and take profit levels for trade planning.

8. Create alerts in TradingView using the script alert conditions.

For the most detailed alerts, create a TradingView alert and select Condition, Adaptive Trend Checklist PRO, Any alert function call.

This allows the script to send dynamic alerts with real trade levels.

Important Notice

This indicator is a decision support tool and should not be considered financial advice. No indicator can guarantee profitable trades or predict the market with certainty.

Traders should always combine this tool with their own analysis, risk management rules and market context. Backtesting and forward testing are strongly recommended before using it with real capital.

Descripcion en Castellano

Adaptive Trend Checklist PRO Entradas y Salidas Optimas

Adaptive Trend Checklist PRO es un indicador avanzado de seguimiento de tendencia y gestion de operaciones disenado para ayudar al trader a identificar oportunidades long y short de mayor calidad directamente sobre el grafico.

El script combina direccion de tendencia, momentum, fuerza mediante ADX, Supertrend, media movil, confirmacion de timeframes superiores, niveles de gestion de riesgo y alertas automaticas en un unico sistema visual de analisis.

Su objetivo no es predecir el mercado con certeza absoluta, sino ayudar al trader a tomar decisiones mas estructuradas, filtrando escenarios debiles, detectando condiciones validas de entrada y gestionando salidas mediante una logica tecnica predefinida.

Funcionalidades Principales

1. Modo automatico adaptativo por timeframe

El indicador puede ajustar automaticamente sus parametros internos segun el timeframe del grafico.

Adapta automaticamente la longitud de la media movil, longitud del ATR, factor del Supertrend, longitud del ADX, umbral minimo del ADX, timeframes superiores de referencia y modo de trading.

Esto permite que el script se comporte de forma diferente en temporalidades de scalping, intradia o swing trading.

2. Modo manual

El usuario puede desactivar el modo automatico y configurar manualmente el modo de trading, periodo de la media movil, periodo del ATR, factor del Supertrend, valor minimo del ADX, longitud del ADX y confirmaciones de timeframes superiores.

Este modo es util para traders que quieren controlar completamente la logica del indicador.

3. Panel visual de checklist

El script incluye una tabla visual que muestra el estado actual del mercado.

El checklist muestra el modo del sistema, modo de trading, estado de los timeframes superiores, sesgo de la media movil, direccion del Supertrend, estado del ADX, direccion de la operacion activa, sesion de mercado, estado de gestion y motivo de la ultima salida.

Este panel permite entender rapidamente si el mercado esta alineado o no para una posible operacion.

4. Senales de entrada long y short

El indicador genera posibles entradas long y short cuando se alinean varias condiciones tecnicas.

La logica de entrada puede incluir precio por encima o por debajo de la media movil seleccionada, precio por encima o por debajo del Supertrend, ADX confirmando suficiente fuerza tendencial, confirmacion de timeframes superiores, activacion por momentum y filtro de rango o no operar.

Las entradas se muestran directamente en el grafico mediante senales visuales.

5. Precio de entrada optima

Cuando aparece una configuracion valida, el script calcula y muestra un precio de entrada sugerido basado en el cierre de la vela de senal confirmada.

Tambien dibuja una linea horizontal de entrada en el grafico para que el trader tenga una referencia clara del nivel operativo.

6. Calculo inteligente del stop loss

El stop loss se calcula combinando distancia respecto al Supertrend, estructura reciente de swings, ajuste por volatilidad y multiplicador adaptado al timeframe.

El objetivo es evitar colocar el stop demasiado cerca del ruido del mercado, manteniendo al mismo tiempo un riesgo controlado.

7. Niveles de take profit

El script calcula y muestra automaticamente tres niveles de take profit llamados TP1, TP2 y TP3.

Estos niveles se basan en la distancia real entre la entrada y el stop loss, utilizando una estructura de riesgo beneficio.

8. Trailing stop

El indicador incorpora una logica de trailing stop basada en el movimiento del Supertrend.

El trailing stop esta disenado para proteger beneficios a medida que el precio avanza a favor de la operacion, sin empeorar nunca el stop loss original.

9. Logica de salida optima

El script puede activar senales de salida segun el modo de salida seleccionado.

Los modos disponibles son TP1, TP2, TP3, TP2 mas trailing stop, trailing Supertrend y giro de tendencia.

Ademas, el script muestra el motivo de la ultima salida tanto en el grafico como en el checklist.

10. Tabla de gestion de operacion

El indicador incluye una tabla separada de gestion donde se muestra capital de la cuenta, importe de riesgo, precio de entrada, stop loss, TP1, TP2, TP3, trailing stop y tamano sugerido de posicion en dolares.

Esto permite al trader evaluar el riesgo y el tamano de posicion antes de operar.

11. Alertas automaticas

El script incluye condiciones de alerta para entrada optima long, entrada optima short, salida optima long, salida optima short, senal general de entrada y senal general de salida.

Tambien incorpora alertas dinamicas mediante alert function, que pueden enviar mensajes detallados con precio de entrada, stop loss y objetivos de beneficio.

Modo de Uso

1. Anade el script al grafico de TradingView.

2. Elige entre Modo Automatico o Modo Manual.

3. Selecciona el estilo de trading deseado, Conservador, Agresivo o Ultra Agresivo.

4. Ajusta los filtros de timeframes superiores si lo necesitas.

5. Selecciona el modo de salida deseado.

6. Espera una senal long o short confirmada.

7. Usa los niveles de entrada, stop loss y take profit mostrados en el grafico para planificar la operacion.

8. Crea alertas en TradingView usando las condiciones de alerta del script.

Para recibir las alertas mas completas, crea una alerta en TradingView y selecciona Condition, Adaptive Trend Checklist PRO, Any alert function call.

Esto permite que el script envie alertas dinamicas con los niveles reales de la operacion.

Aviso Importante

Este indicador es una herramienta de apoyo a la toma de decisiones y no debe considerarse asesoramiento financiero. Ningun indicador puede garantizar operaciones rentables ni predecir el mercado con certeza absoluta.

El trader debe combinar esta herramienta con su propio analisis, gestion de riesgo y contexto de mercado. Se recomienda realizar backtesting y pruebas en tiempo real antes de utilizarlo con capital real.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=5
indicator("Adaptive Trend Checklist Entries Exits", shorttitle="ATC Entries Exits", overlay=true, max_bars_back=500, max_lines_count=100, max_labels_count=100)

// ==========================================================
// NOTA
// ==========================================================
// Esta versión NO promete entradas infalibles. Calcula una entrada óptima operativa
// según tendencia, Supertrend, ADX, confirmación HTF y momentum; y calcula salida
// por TP objetivo, SL, trailing Supertrend o giro de tendencia.
// Para alertas automáticas con precios reales, crear alerta en TradingView usando:
// Condition: este indicador -> "Any alert() function call".

// ==========================================================
// MODO DE OPERACIÓN
// ==========================================================
useAuto = input.bool(true, "Modo Automático por Timeframe")
manualTradeMode = input.string("CONSERVADOR", "Modo Manual", options=["CONSERVADOR", "AGRESIVO", "ULTRA AGRESIVO"])
manualEmaLen    = input.int(30, "EMA Manual", minval=1)
manualAtrLen    = input.int(10, "ATR Manual", minval=1)
manualStFactor  = input.float(3.0, "Factor Supertrend Manual", step=0.1)
manualAdxMin    = input.int(20, "ADX Mínimo Manual", minval=1)
manualAdxLen    = input.int(14, "ADX Length Manual", minval=1)
manualHTF1      = input.timeframe("15", "HTF 1 Manual")
manualHTF2      = input.timeframe("60", "HTF 2 Manual")

// ==========================================================
// AUTO TF ENGINE
// ==========================================================
tfMin = timeframe.isseconds ? timeframe.multiplier / 60.0 : timeframe.isminutes ? timeframe.multiplier : timeframe.isdaily ? 1440.0 : timeframe.isweekly ? 10080.0 : timeframe.ismonthly ? 43200.0 : 5.0

isScalpFast = tfMin <= 3
isScalp     = tfMin > 3  and tfMin <= 5
isIntra     = tfMin > 5  and tfMin <= 15
isSwing     = tfMin > 15 and tfMin <= 60
isSwingHigh = tfMin > 60

autoAdxLen = isScalpFast ? 10 : isScalp ? 12 : isIntra ? 14 : isSwing ? 18 : 20
autoAdxMin = isScalpFast ? 25 : isScalp ? 23 : isIntra ? 20 : isSwing ? 18 : 15
adxMargin  = isScalpFast ? 7  : isScalp ? 7  : isIntra ? 10 : isSwing ? 15 : 15

autoTradeMode = isScalpFast ? "AGRESIVO" : isScalp ? "AGRESIVO" : isIntra ? "AGRESIVO" : "CONSERVADOR"
autoEmaLen    = isScalpFast ? 21 : isScalp ? 30 : isIntra ? 30 : isSwing ? 50 : 100
autoAtrLen    = isScalpFast ? 7  : isScalp ? 10 : isIntra ? 10 : isSwing ? 10 : 14
autoStFactor  = isScalpFast ? 2.5 : isScalp ? 3.0 : isIntra ? 3.0 : isSwing ? 3.5 : 4.0
autoHTF1      = isScalpFast ? "15" : isScalp ? "15" : isIntra ? "60" : isSwing ? "240" : "D"
autoHTF2      = isScalpFast ? "60" : isScalp ? "60" : isIntra ? "240" : isSwing ? "D" : "W"

tradeMode   = useAuto ? autoTradeMode : manualTradeMode
maLen       = useAuto ? autoEmaLen    : manualEmaLen
atrPeriod   = useAuto ? autoAtrLen    : manualAtrLen
factor      = useAuto ? autoStFactor  : manualStFactor
adxLenFinal = useAuto ? autoAdxLen    : manualAdxLen
adxMinFinal = useAuto ? autoAdxMin    : manualAdxMin
htfTF1      = useAuto ? autoHTF1      : manualHTF1
htfTF2      = useAuto ? autoHTF2      : manualHTF2

// ==========================================================
// INPUTS VISUALES Y FILTROS
// ==========================================================
maType       = input.string("EMA", "Tipo de Media", options=["EMA", "SMA"])
useADX       = input.bool(true, "Usar ADX")
useHTF1      = input.bool(true,  "Usar HTF 1")
useHTF2      = input.bool(true,  "Usar HTF 2")
useHTF3      = input.bool(false, "Usar HTF 3")
htfTF3       = input.timeframe("240", "HTF 3")
useHTF4      = input.bool(false, "Usar HTF 4")
htfTF4       = input.timeframe("D", "HTF 4")
showChecklist = input.bool(true, "Mostrar Checklist")
showRiskBox   = input.bool(true, "Mostrar Gestión")
showScore     = input.bool(false, "Mostrar Score HTF")
showMarket    = input.bool(true, "Mostrar Mercado Abierto")

chkFontOpt  = input.string("SMALL", "Letra Checklist", options=["MEDIANA", "SMALL", "TINY"])
riskFontOpt = input.string("SMALL", "Letra Gestión", options=["MEDIANA", "SMALL", "TINY"])
chkTextSize  = chkFontOpt == "MEDIANA" ? size.normal : chkFontOpt == "SMALL" ? size.small : size.tiny
riskTextSize = riskFontOpt == "MEDIANA" ? size.normal : riskFontOpt == "SMALL" ? size.small : size.tiny

// Gestión y salida
capital       = input.float(1000, "Capital ($)", step=100)
riskPct       = input.float(1.0, "Riesgo (%)", step=0.1)
lineBars      = input.int(60, "Longitud líneas Entry/SL/TP", minval=10, maxval=300)
exitMode      = input.string("TP2 + Trailing", "Modo Salida Óptima", options=["TP1", "TP2", "TP3", "TP2 + Trailing", "Trailing Supertrend", "Giro Tendencia"])
useBarClose   = input.bool(true, "Confirmar señales al cierre de vela / No repaint")
useRuntimeAlerts = input.bool(true, "Alertas dinámicas con precio real")

// ==========================================================
// SUPERTREND, MEDIA Y ADX
// ==========================================================
[supertrendRaw, dir] = ta.supertrend(factor, atrPeriod)
supertrend = barstate.isfirst ? na : supertrendRaw

maVal = maType == "EMA" ? ta.ema(close, maLen) : ta.sma(close, maLen)
[diPlus, diMinus, adxVal] = ta.dmi(adxLenFinal, adxLenFinal)

plot(dir < 0 ? supertrend : na, title="Supertrend Bull", color=color.green, style=plot.style_linebr, linewidth=2)
plot(dir > 0 ? supertrend : na, title="Supertrend Bear", color=color.red, style=plot.style_linebr, linewidth=2)
plot(maVal, title="Media", color=maType == "EMA" ? color.aqua : color.orange, linewidth=2)

adxState = not useADX ? "OFF" : adxVal < adxMinFinal ? "RANGO" : adxVal < adxMinFinal + adxMargin ? "TENDENCIA" : "FUERTE"
adxCol   = not useADX ? color.new(color.gray, 80) : adxVal < adxMinFinal ? color.gray : adxVal < adxMinFinal + adxMargin ? color.orange : color.green
adxStrong = useADX and adxVal >= adxMinFinal + adxMargin

isUltraAggressiveRaw = tradeMode == "ULTRA AGRESIVO"
isAggressiveRaw      = tradeMode == "AGRESIVO"
isConservative       = tradeMode == "CONSERVADOR"
isUltraAggressive    = isUltraAggressiveRaw and adxStrong
isAggressive         = isAggressiveRaw or (isUltraAggressiveRaw and not adxStrong)

adxTrend = not useADX ? true : isUltraAggressive ? adxVal >= adxMinFinal - 5 : isAggressive ? adxVal >= adxMinFinal - 3 : adxVal >= adxMinFinal

// ==========================================================
// HTF ENGINE
// ==========================================================
f_htfSupertrend() =>
    [st, _d] = ta.supertrend(factor, atrPeriod)
    st

f_htfState(tf, enabled) =>
    ema = request.security(syminfo.tickerid, tf, ta.ema(close, maLen), barmerge.gaps_off, barmerge.lookahead_off)
    st  = request.security(syminfo.tickerid, tf, f_htfSupertrend(), barmerge.gaps_off, barmerge.lookahead_off)
    cls = request.security(syminfo.tickerid, tf, close, barmerge.gaps_off, barmerge.lookahead_off)
    bull = cls > ema and cls > st
    bear = cls < ema and cls < st
    txt = not enabled ? "—" : bull ? "BULLISH" : bear ? "BEARISH" : "RANGO"
    col = not enabled ? color.new(color.gray, 80) : bull ? color.green : bear ? color.red : color.gray
    bullOut = enabled ? bull : true
    bearOut = enabled ? bear : true
    [txt, col, bullOut, bearOut]

[htf1Txt, htf1Col, htf1Bull, htf1Bear] = f_htfState(htfTF1, useHTF1)
[htf2Txt, htf2Col, htf2Bull, htf2Bear] = f_htfState(htfTF2, useHTF2)
[htf3Txt, htf3Col, htf3Bull, htf3Bear] = f_htfState(htfTF3, useHTF3)
[htf4Txt, htf4Col, htf4Bull, htf4Bear] = f_htfState(htfTF4, useHTF4)

wHTF1 = 1.0
wHTF2 = 1.5
wHTF3 = 2.0
wHTF4 = 3.0

bullScore = (useHTF1 and htf1Bull ? wHTF1 : 0) + (useHTF2 and htf2Bull ? wHTF2 : 0) + (useHTF3 and htf3Bull ? wHTF3 : 0) + (useHTF4 and htf4Bull ? wHTF4 : 0)
bearScore = (useHTF1 and htf1Bear ? wHTF1 : 0) + (useHTF2 and htf2Bear ? wHTF2 : 0) + (useHTF3 and htf3Bear ? wHTF3 : 0) + (useHTF4 and htf4Bear ? wHTF4 : 0)
maxScore  = (useHTF1 ? wHTF1 : 0) + (useHTF2 ? wHTF2 : 0) + (useHTF3 ? wHTF3 : 0) + (useHTF4 ? wHTF4 : 0)
scoreThreshold = maxScore > 0 ? maxScore * 0.6 : 0
htfBullOK = maxScore == 0 ? true : bullScore >= scoreThreshold
htfBearOK = maxScore == 0 ? true : bearScore >= scoreThreshold

scoreHTF = 0.0
scoreHTF += useHTF1 ? (htf1Bull ? wHTF1 : htf1Bear ? -wHTF1 : 0) : 0
scoreHTF += useHTF2 ? (htf2Bull ? wHTF2 : htf2Bear ? -wHTF2 : 0) : 0
scoreHTF += useHTF3 ? (htf3Bull ? wHTF3 : htf3Bear ? -wHTF3 : 0) : 0
scoreHTF += useHTF4 ? (htf4Bull ? wHTF4 : htf4Bear ? -wHTF4 : 0) : 0

scoreTxt = scoreHTF >= 4 ? "STRONG BULLISH +" + str.tostring(scoreHTF) : scoreHTF >= 2 ? "BULLISH +" + str.tostring(scoreHTF) : scoreHTF <= -4 ? "STRONG BEARISH " + str.tostring(scoreHTF) : scoreHTF <= -2 ? "BEARISH " + str.tostring(scoreHTF) : "NEUTRAL"
scoreCol = scoreHTF >= 4 ? color.green : scoreHTF >= 2 ? color.lime : scoreHTF <= -4 ? color.red : scoreHTF <= -2 ? color.orange : color.gray

// ==========================================================
// CONDICIONES BASE Y RIESGO
// ==========================================================
emaTxt = close > maVal ? "BULLISH" : close < maVal ? "BEARISH" : "RANGO"
emaCol = emaTxt == "BULLISH" ? color.green : emaTxt == "BEARISH" ? color.red : color.gray
stTxt  = close > supertrend ? "BULLISH" : close < supertrend ? "BEARISH" : "RANGO"
stCol  = stTxt == "BULLISH" ? color.green : stTxt == "BEARISH" ? color.red : color.gray

emaBull = close > maVal
emaBear = close < maVal
stBull  = close > supertrend
stBear  = close < supertrend

bullCond = isUltraAggressive ? emaBull : emaBull and stBull
bearCond = isUltraAggressive ? emaBear : emaBear and stBear

hasRange = emaTxt == "RANGO" or stTxt == "RANGO" or adxState == "RANGO" or (useHTF1 and htf1Txt == "RANGO") or (useHTF2 and htf2Txt == "RANGO")

htfOKLong  = not (useHTF1 or useHTF2 or useHTF3 or useHTF4) ? true : htfBullOK
htfOKShort = not (useHTF1 or useHTF2 or useHTF3 or useHTF4) ? true : htfBearOK

baseLongOK  = bullCond and htfOKLong and adxTrend and not hasRange
baseShortOK = bearCond and htfOKShort and adxTrend and not hasRange

triggerLong  = isUltraAggressive ? close > close[1] : close > high[1]
triggerShort = isUltraAggressive ? close < close[1] : close < low[1]

confirmed = useBarClose ? barstate.isconfirmed : true

longSetup  = baseLongOK and triggerLong and confirmed
shortSetup = baseShortOK and triggerShort and confirmed

// ==========================================================
// ESTADO DE OPERACIÓN
// ==========================================================
var int   posDir     = 0       // 0 sin operación, 1 long, -1 short
var float entryPrice = na
var float stopLoss   = na
var float tp1        = na
var float tp2        = na
var float tp3        = na
var float risk       = na
var float trailStop  = na
var string lastExitReason = "—"

// Señal nueva solo si no hay operación abierta
entryLongSignal  = longSetup and posDir == 0
entryShortSignal = shortSetup and posDir == 0

// ==========================================================
// LÍNEAS Y LABELS
// ==========================================================
var line entryLine = na
var line slLine    = na
var line tp1Line   = na
var line tp2Line   = na
var line tp3Line   = na
var line trailLine = na

var label entryLbl = na
var label slLbl    = na
var label tp1Lbl   = na
var label tp2Lbl   = na
var label tp3Lbl   = na
var label trailLbl = na
var label exitLbl  = na

f_clearTradeObjects() =>
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    line.delete(trailLine)
    label.delete(entryLbl)
    label.delete(slLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    label.delete(trailLbl)

// ==========================================================
// CÁLCULO DE ENTRY / SL / TP
// ==========================================================
swingLen = isUltraAggressive ? 2 : isAggressive ? 3 : 5
swingLow  = ta.lowest(low, swingLen)
swingHigh = ta.highest(high, swingLen)

slMult = timeframe.isseconds ? 1.6 : tfMin <= 3 ? 1.5 : tfMin <= 5 ? 1.4 : tfMin <= 15 ? 1.3 : tfMin <= 60 ? 1.2 : 1.1

if entryLongSignal or entryShortSignal
    f_clearTradeObjects()
    label.delete(exitLbl)

    posDir := entryLongSignal ? 1 : -1
    entryPrice := close

    stDist = math.abs(entryPrice - supertrend)
    sl_st = posDir == 1 ? entryPrice - stDist * slMult : entryPrice + stDist * slMult
    sl_struct = posDir == 1 ? swingLow : swingHigh
    stopLoss := posDir == 1 ? math.min(sl_st, sl_struct) : math.max(sl_st, sl_struct)

    risk := math.abs(entryPrice - stopLoss)
    tp1 := posDir == 1 ? entryPrice + risk : entryPrice - risk
    tp2 := posDir == 1 ? entryPrice + risk * 2 : entryPrice - risk * 2
    tp3 := posDir == 1 ? entryPrice + risk * 3 : entryPrice - risk * 3
    trailStop := stopLoss

    entryColor = posDir == 1 ? color.green : color.red
    tpColor = color.green
    slColor = color.red

    entryLine := line.new(bar_index, entryPrice, bar_index + lineBars, entryPrice, color=entryColor, width=2)
    slLine    := line.new(bar_index, stopLoss,   bar_index + lineBars, stopLoss,   color=slColor, width=2)
    tp1Line   := line.new(bar_index, tp1,        bar_index + lineBars, tp1,        color=tpColor, width=1)
    tp2Line   := line.new(bar_index, tp2,        bar_index + lineBars, tp2,        color=tpColor, width=1)
    tp3Line   := line.new(bar_index, tp3,        bar_index + lineBars, tp3,        color=tpColor, width=1)
    trailLine := line.new(bar_index, trailStop,  bar_index + lineBars, trailStop,  color=color.orange, width=2, style=line.style_dashed)

    sideTxt = posDir == 1 ? "LONG" : "SHORT"
    entryLbl := label.new(bar_index + lineBars, entryPrice, "ENTRY " + sideTxt + "\n" + str.tostring(entryPrice, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=entryColor, textcolor=color.white, size=size.small)
    slLbl    := label.new(bar_index + lineBars, stopLoss,   "SL\n" + str.tostring(stopLoss, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=slColor, textcolor=color.white, size=size.small)
    tp1Lbl   := label.new(bar_index + lineBars, tp1,        "TP1\n" + str.tostring(tp1, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=tpColor, textcolor=color.white, size=size.small)
    tp2Lbl   := label.new(bar_index + lineBars, tp2,        "TP2\n" + str.tostring(tp2, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=tpColor, textcolor=color.white, size=size.small)
    tp3Lbl   := label.new(bar_index + lineBars, tp3,        "TP3\n" + str.tostring(tp3, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=tpColor, textcolor=color.white, size=size.small)
    trailLbl := label.new(bar_index + lineBars, trailStop,  "TRAIL\n" + str.tostring(trailStop, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.orange, textcolor=color.white, size=size.small)

// ==========================================================
// TRAILING Y SALIDA ÓPTIMA
// ==========================================================
if posDir != 0 and not na(entryPrice)
    // Trailing inteligente: nunca empeora el SL inicial
    if posDir == 1
        trailCandidate = math.max(stopLoss, supertrend)
        trailStop := na(trailStop) ? stopLoss : math.max(trailStop, trailCandidate)
    else
        trailCandidate = math.min(stopLoss, supertrend)
        trailStop := na(trailStop) ? stopLoss : math.min(trailStop, trailCandidate)

    line.set_xy1(trailLine, bar_index, trailStop)
    line.set_xy2(trailLine, bar_index + lineBars, trailStop)
    label.set_x(trailLbl, bar_index + lineBars)
    label.set_y(trailLbl, trailStop)
    label.set_text(trailLbl, "TRAIL\n" + str.tostring(trailStop, format.mintick))

    // Mantener líneas extendidas hacia delante
    line.set_x2(entryLine, bar_index + lineBars)
    line.set_x2(slLine, bar_index + lineBars)
    line.set_x2(tp1Line, bar_index + lineBars)
    line.set_x2(tp2Line, bar_index + lineBars)
    line.set_x2(tp3Line, bar_index + lineBars)
    label.set_x(entryLbl, bar_index + lineBars)
    label.set_x(slLbl, bar_index + lineBars)
    label.set_x(tp1Lbl, bar_index + lineBars)
    label.set_x(tp2Lbl, bar_index + lineBars)
    label.set_x(tp3Lbl, bar_index + lineBars)

longHitSL      = posDir == 1 and low <= stopLoss
shortHitSL     = posDir == -1 and high >= stopLoss
longHitTrail   = posDir == 1 and low <= trailStop
shortHitTrail  = posDir == -1 and high >= trailStop
longHitTP1     = posDir == 1 and high >= tp1
shortHitTP1    = posDir == -1 and low <= tp1
longHitTP2     = posDir == 1 and high >= tp2
shortHitTP2    = posDir == -1 and low <= tp2
longHitTP3     = posDir == 1 and high >= tp3
shortHitTP3    = posDir == -1 and low <= tp3
longTrendFlip  = posDir == 1 and confirmed and (close < maVal or close < supertrend or shortSetup)
shortTrendFlip = posDir == -1 and confirmed and (close > maVal or close > supertrend or longSetup)

exitByTP1   = exitMode == "TP1" and (longHitTP1 or shortHitTP1)
exitByTP2   = exitMode == "TP2" and (longHitTP2 or shortHitTP2)
exitByTP3   = exitMode == "TP3" and (longHitTP3 or shortHitTP3)
exitByTP2Tr = exitMode == "TP2 + Trailing" and ((longHitTP2 or shortHitTP2) or (longHitTrail or shortHitTrail))
exitByTrail = exitMode == "Trailing Supertrend" and (longHitTrail or shortHitTrail)
exitByFlip  = exitMode == "Giro Tendencia" and (longTrendFlip or shortTrendFlip)
exitByHardSL = longHitSL or shortHitSL

exitLongSignal  = posDir == 1 and (exitByHardSL or exitByTP1 or exitByTP2 or exitByTP3 or exitByTP2Tr or exitByTrail or exitByFlip)
exitShortSignal = posDir == -1 and (exitByHardSL or exitByTP1 or exitByTP2 or exitByTP3 or exitByTP2Tr or exitByTrail or exitByFlip)

float exitPrice = na
if exitLongSignal or exitShortSignal
    if exitByHardSL
        exitPrice := stopLoss
        lastExitReason := "SL"
    else if exitByTP3
        exitPrice := tp3
        lastExitReason := "TP3"
    else if exitByTP2 or exitByTP2Tr
        exitPrice := exitMode == "TP2 + Trailing" and (longHitTrail or shortHitTrail) and not (longHitTP2 or shortHitTP2) ? trailStop : tp2
        lastExitReason := exitMode == "TP2 + Trailing" and (longHitTrail or shortHitTrail) and not (longHitTP2 or shortHitTP2) ? "TRAIL" : "TP2"
    else if exitByTP1
        exitPrice := tp1
        lastExitReason := "TP1"
    else if exitByTrail
        exitPrice := trailStop
        lastExitReason := "TRAIL"
    else
        exitPrice := close
        lastExitReason := "GIRO"

    exitColor = exitLongSignal ? color.red : color.green
    exitText  = exitLongSignal ? "SALIDA LONG" : "SALIDA SHORT"
    label.delete(exitLbl)
    exitLbl := label.new(bar_index, exitPrice, exitText + "\n" + lastExitReason + "\n" + str.tostring(exitPrice, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=exitColor, textcolor=color.white, size=size.small)
    posDir := 0

// ==========================================================
// SEÑALES VISUALES
// ==========================================================
plotshape(entryLongSignal,  title="Entrada Long",  location=location.belowbar, style=shape.triangleup,   color=color.green, size=size.small, text="LONG")
plotshape(entryShortSignal, title="Entrada Short", location=location.abovebar, style=shape.triangledown, color=color.red,   size=size.small, text="SHORT")
plotshape(exitLongSignal,   title="Salida Long",   location=location.abovebar, style=shape.xcross, color=color.orange, size=size.small, text="EXIT")
plotshape(exitShortSignal,  title="Salida Short",  location=location.belowbar, style=shape.xcross, color=color.orange, size=size.small, text="EXIT")

// ==========================================================
// MERCADOS / SESIONES
// ==========================================================
inLondon  = not na(time(timeframe.period, "0800-1700"))
inNewYork = not na(time(timeframe.period, "1300-2200"))
inSydney  = not na(time(timeframe.period, "2100-0600"))
marketTxt = inLondon and inNewYork ? "US · EU" : inSydney and inLondon ? "ASIA · EU" : inSydney and inNewYork ? "ASIA · US" : inNewYork ? "US" : inLondon ? "EU" : inSydney ? "ASIA" : "SIN MERCADO"
marketCol = inLondon and inNewYork ? color.green : inSydney and inLondon ? color.orange : inSydney and inNewYork ? color.yellow : inLondon ? color.blue : inNewYork ? color.teal : inSydney ? color.purple : color.new(color.gray, 80)

modeTxt = isUltraAggressiveRaw and not adxStrong ? "ULTRA BLOQUEADO" : isUltraAggressive ? "ULTRA AGRESIVO" : isAggressiveRaw ? "AGRESIVO" : "CONSERVADOR"
modeCol = isUltraAggressiveRaw and not adxStrong ? color.gray : isUltraAggressive ? color.red : isAggressiveRaw ? color.orange : color.blue

riskTxt = hasRange ? "NO OPERAR" : (baseLongOK or baseShortOK ? "NORMAL" : "NO OPERAR")
riskCol = riskTxt == "NORMAL" ? color.green : color.gray
activeDirTxt = posDir == 1 ? "LONG" : posDir == -1 ? "SHORT" : "—"
activeDirCol = posDir == 1 ? color.green : posDir == -1 ? color.red : color.gray

// ==========================================================
// CHECKLIST VISUAL
// ==========================================================
var table chkTable = table.new(position.top_right, 2, 15, border_width=1)

if showChecklist and barstate.islast
    table.clear(chkTable, 0, 0, 1, 14)
    table.cell(chkTable, 0, 0, "CHECKLIST", bgcolor=color.black, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 0, activeDirTxt, bgcolor=activeDirCol, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 0, 1, "MODO", text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 1, useAuto ? "AUTO TF" : "MANUAL", bgcolor=useAuto ? color.green : color.orange, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 0, 2, "TRADING", text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 2, modeTxt, bgcolor=modeCol, text_color=color.white, text_size=chkTextSize)

    table.cell(chkTable, 0, 3, htfTF1, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 3, htf1Txt, bgcolor=htf1Col, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 0, 4, htfTF2, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 4, htf2Txt, bgcolor=htf2Col, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 0, 5, htfTF3, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 5, useHTF3 ? htf3Txt : "OFF", bgcolor=useHTF3 ? htf3Col : color.new(color.gray, 80), text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 0, 6, htfTF4, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 6, useHTF4 ? htf4Txt : "OFF", bgcolor=useHTF4 ? htf4Col : color.new(color.gray, 80), text_color=color.white, text_size=chkTextSize)

    if showScore
        table.cell(chkTable, 0, 7, "SCORE HTF", text_color=color.white, text_size=chkTextSize)
        table.cell(chkTable, 1, 7, scoreTxt, bgcolor=scoreCol, text_color=color.white, text_size=chkTextSize)

    table.cell(chkTable, 0, 8, maType, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 8, emaTxt, bgcolor=emaCol, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 0, 9, "SUPERTREND", text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 9, stTxt, bgcolor=stCol, text_color=color.white, text_size=chkTextSize)

    adxUp = adxVal > adxVal[1]
    adxArrow = adxUp ? " ↑" : adxVal < adxVal[1] ? " ↓" : " →"
    adxTxt = not useADX ? "ADX OFF" : adxState + " (" + str.tostring(adxVal, "#.0") + ")" + adxArrow
    table.cell(chkTable, 0, 10, "ADX", text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 10, adxTxt, bgcolor=adxCol, text_color=color.white, text_size=chkTextSize)

    table.cell(chkTable, 0, 11, "OPERACIÓN", text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 11, posDir == 0 ? "SIN OPERACIÓN" : activeDirTxt, bgcolor=activeDirCol, text_color=color.white, text_size=chkTextSize)

    if showMarket
        table.cell(chkTable, 0, 12, "MERCADO", text_color=color.white, text_size=chkTextSize)
        table.cell(chkTable, 1, 12, marketTxt, bgcolor=marketCol, text_color=color.white, text_size=chkTextSize)

    table.cell(chkTable, 0, 13, "GESTIÓN", text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 13, riskTxt, bgcolor=riskCol, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 0, 14, "ÚLTIMA SALIDA", text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 14, lastExitReason, bgcolor=color.gray, text_color=color.white, text_size=chkTextSize)

// ==========================================================
// TABLA GESTIÓN DE POSICIÓN
// ==========================================================
riskDollar  = capital * riskPct / 100
riskPerUnit = math.abs(entryPrice - stopLoss)
positionUSD = riskPerUnit > 0 and not na(entryPrice) and not na(stopLoss) ? (riskDollar / riskPerUnit) * entryPrice : na

var table posTable = table.new(position.bottom_right, 2, 10, border_width=1)

if showRiskBox and barstate.islast
    table.clear(posTable, 0, 0, 1, 9)
    table.cell(posTable, 0, 0, "GESTIÓN", bgcolor=color.black, text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 1, 0, activeDirTxt, bgcolor=activeDirCol, text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 0, 1, "Capital", text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 1, 1, "$" + str.tostring(capital), text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 0, 2, "Riesgo $", text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 1, 2, "$" + str.tostring(riskDollar, format.mintick), text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 0, 3, "Entry", text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 1, 3, str.tostring(entryPrice, format.mintick), text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 0, 4, "SL", text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 1, 4, str.tostring(stopLoss, format.mintick), text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 0, 5, "TP1", text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 1, 5, str.tostring(tp1, format.mintick), text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 0, 6, "TP2", text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 1, 6, str.tostring(tp2, format.mintick), text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 0, 7, "TP3", text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 1, 7, str.tostring(tp3, format.mintick), text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 0, 8, "Trail", text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 1, 8, str.tostring(trailStop, format.mintick), text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 0, 9, "Tamaño $", text_color=color.white, text_size=riskTextSize)
    table.cell(posTable, 1, 9, "$" + str.tostring(positionUSD, format.mintick), text_color=color.white, text_size=riskTextSize)

// ==========================================================
// ALERTAS CLÁSICAS TRADINGVIEW
// ==========================================================
alertcondition(entryLongSignal,  title="ENTRADA LONG ÓPTIMA",  message="ENTRADA LONG | {{ticker}} | TF {{interval}} | Precio {{close}}")
alertcondition(entryShortSignal, title="ENTRADA SHORT ÓPTIMA", message="ENTRADA SHORT | {{ticker}} | TF {{interval}} | Precio {{close}}")
alertcondition(exitLongSignal,   title="SALIDA LONG ÓPTIMA",   message="SALIDA LONG | {{ticker}} | TF {{interval}} | Precio {{close}}")
alertcondition(exitShortSignal,  title="SALIDA SHORT ÓPTIMA",  message="SALIDA SHORT | {{ticker}} | TF {{interval}} | Precio {{close}}")
alertcondition(entryLongSignal or entryShortSignal, title="ENTRADA ÓPTIMA LONG/SHORT", message="ENTRADA ÓPTIMA | {{ticker}} | TF {{interval}} | Precio {{close}}")
alertcondition(exitLongSignal or exitShortSignal,   title="SALIDA ÓPTIMA LONG/SHORT",  message="SALIDA ÓPTIMA | {{ticker}} | TF {{interval}} | Precio {{close}}")

// ==========================================================
// ALERTAS DINÁMICAS CON PRECIO REAL
// ==========================================================
if useRuntimeAlerts and entryLongSignal
    alert("ENTRADA LONG ÓPTIMA | " + syminfo.ticker + " | TF " + timeframe.period + " | Entry " + str.tostring(entryPrice, format.mintick) + " | SL " + str.tostring(stopLoss, format.mintick) + " | TP1 " + str.tostring(tp1, format.mintick) + " | TP2 " + str.tostring(tp2, format.mintick) + " | TP3 " + str.tostring(tp3, format.mintick), alert.freq_once_per_bar_close)

if useRuntimeAlerts and entryShortSignal
    alert("ENTRADA SHORT ÓPTIMA | " + syminfo.ticker + " | TF " + timeframe.period + " | Entry " + str.tostring(entryPrice, format.mintick) + " | SL " + str.tostring(stopLoss, format.mintick) + " | TP1 " + str.tostring(tp1, format.mintick) + " | TP2 " + str.tostring(tp2, format.mintick) + " | TP3 " + str.tostring(tp3, format.mintick), alert.freq_once_per_bar_close)

if useRuntimeAlerts and exitLongSignal
    alert("SALIDA LONG ÓPTIMA | " + syminfo.ticker + " | TF " + timeframe.period + " | Motivo " + lastExitReason + " | Precio " + str.tostring(exitPrice, format.mintick), alert.freq_once_per_bar_close)

if useRuntimeAlerts and exitShortSignal
    alert("SALIDA SHORT ÓPTIMA | " + syminfo.ticker + " | TF " + timeframe.period + " | Motivo " + lastExitReason + " | Precio " + str.tostring(exitPrice, format.mintick), alert.freq_once_per_bar_close)
````
