# Adaptive Trend Checklist (EMA + Supertrend + ADX)svm

- url: https://www.tradingview.com/script/02CMQ5HC/
- type: indicator
- pine_id: PUB;a2e11ec45a674d9791ae5fbd4e8eed4b
- version: 1.0

## Description

**Adaptive Trend Checklist (EMA + Supertrend + ADX)** is a visual trend-following and trade-management indicator designed to help traders quickly evaluate market direction, trend strength, higher-timeframe alignment, entry signals, and risk levels directly on the chart.

This script combines **EMA/SMA trend bias**, **Supertrend**, **ADX strength filtering**, **multi-timeframe confirmation**, automatic timeframe-based settings, signal classification, and a built-in position management panel.

### What the indicator does

The indicator analyzes the current market using several layers of confirmation:

* **EMA/SMA trend filter** to define bullish or bearish bias.
* **Supertrend** to confirm directional structure.
* **ADX filter** to detect whether the market is ranging, trending, or strongly trending.
* **Higher Timeframe confirmation** using up to 4 configurable HTFs.
* **Automatic mode by timeframe**, adapting EMA length, ATR length, Supertrend factor, ADX threshold, and HTF references depending on whether you are scalping, intraday trading, or swing trading.
* **Manual mode**, allowing full customization of the core parameters.
* **Visual checklist panel** showing trend status, HTF status, ADX condition, active signal, market session, and final trade management recommendation.
* **Entry, Stop Loss, TP1, TP2 and optional TP3 levels** drawn automatically when a valid signal appears.
* **Risk management panel** calculating position size based on capital and risk percentage.
* **Alert conditions** for buy, sell, general signals, and operable signals.

### Main features

**1. Auto / Manual configuration**
The script can automatically adapt its settings to the current chart timeframe, or it can be manually configured by the trader.

**2. Trend direction system**
It uses the selected moving average and Supertrend to classify the market as bullish, bearish, or range-bound.

**3. ADX strength filter**
ADX helps avoid weak or choppy market conditions. The script labels the market as **RANGE**, **TREND**, or **STRONG**, and adjusts trade aggressiveness accordingly.

**4. Trading modes**
The indicator includes three trading styles:

* **Conservative**: stricter confirmation.
* **Aggressive**: faster signals with more flexibility.
* **Ultra Aggressive**: only allowed when ADX is strong enough; otherwise it is automatically blocked.

**5. Multi-Timeframe Checklist**
The script checks higher timeframes and scores their bullish or bearish alignment. This helps avoid trading against the broader trend.

**6. Visual trade management**
When a signal appears, the script plots:

* Entry price
* Stop Loss
* Take Profit 1
* Take Profit 2
* Take Profit 3 in aggressive modes

The Stop Loss is calculated using Supertrend distance and recent swing structure.

**7. Risk and position size panel**
By entering your capital and risk percentage, the script estimates the dollar position size for the trade.

### How to use it

Use the checklist as a decision-support tool:

* Look for **LONG** signals when EMA, Supertrend, ADX, and HTFs are aligned bullish.
* Look for **SHORT** signals when EMA, Supertrend, ADX, and HTFs are aligned bearish.
* Avoid trades when the panel shows **NO TRADE** or when ADX indicates range conditions.
* Use **NORMAL** risk when confirmation is strong.
* Use **REDUCED** risk when confirmation is weaker or partially aligned.
* Use the plotted Entry, SL, and TP levels to plan the trade before entering.

This indicator is not designed to predict the market with certainty. It is a structured decision-making tool that helps filter trades, reduce emotional entries, and improve consistency.

Descripción en castellano

**Adaptive Trend Checklist (EMA + Supertrend + ADX)** es un indicador visual de seguimiento de tendencia y gestión de operaciones diseñado para ayudar al trader a evaluar rápidamente la dirección del mercado, la fuerza de la tendencia, la alineación con temporalidades superiores, las señales de entrada y la gestión del riesgo directamente en el gráfico.

Este script combina **EMA/SMA**, **Supertrend**, **ADX**, confirmación **multi-timeframe**, configuración automática según temporalidad, clasificación de señales y un panel integrado de gestión de posición.

### Qué hace el indicador

El indicador analiza el mercado mediante varias capas de confirmación:

* **Filtro de tendencia EMA/SMA** para definir sesgo alcista o bajista.
* **Supertrend** para confirmar la estructura direccional.
* **ADX** para detectar si el mercado está en rango, en tendencia o en tendencia fuerte.
* **Confirmación en temporalidades superiores** usando hasta 4 HTF configurables.
* **Modo automático por timeframe**, adaptando EMA, ATR, factor de Supertrend, umbral ADX y HTF según si se opera scalping, intradía o swing.
* **Modo manual**, permitiendo personalizar todos los parámetros principales.
* **Panel checklist visual** con estado de tendencia, HTF, ADX, señal activa, sesión de mercado y recomendación final de gestión.
* **Líneas automáticas de Entry, Stop Loss, TP1, TP2 y TP3 opcional** cuando aparece una señal válida.
* **Panel de gestión de riesgo**, calculando tamaño de posición según capital y porcentaje de riesgo.
* **Alertas** para compra, venta, señales generales y señales operables.

### Funcionalidades principales

**1. Configuración Auto / Manual**
El script puede adaptar automáticamente sus parámetros a la temporalidad actual del gráfico, o permitir una configuración completamente manual.

**2. Sistema de dirección de tendencia**
Utiliza la media seleccionada y el Supertrend para clasificar el mercado como alcista, bajista o en rango.

**3. Filtro de fuerza ADX**
El ADX ayuda a evitar mercados débiles o laterales. El script clasifica el mercado como **RANGO**, **TENDENCIA** o **FUERTE**, y ajusta la agresividad de las señales.

**4. Modos de trading**
Incluye tres estilos operativos:

* **Conservador**: mayor exigencia de confirmación.
* **Agresivo**: señales más rápidas y flexibles.
* **Ultra Agresivo**: solo se activa si el ADX es suficientemente fuerte; si no, queda bloqueado automáticamente.

**5. Checklist Multi-Timeframe**
El script analiza temporalidades superiores y calcula una puntuación de alineación alcista o bajista. Esto ayuda a evitar operar contra la tendencia principal.

**6. Gestión visual de la operación**
Cuando aparece una señal, el script dibuja:

* Precio de entrada
* Stop Loss
* Take Profit 1
* Take Profit 2
* Take Profit 3 en modos agresivos

El Stop Loss se calcula combinando la distancia del Supertrend y la estructura reciente del precio.

**7. Panel de riesgo y tamaño de posición**
Introduciendo el capital y el porcentaje de riesgo, el script estima el tamaño de posición en dólares para la operación.

### Cómo usarlo

Usa el checklist como herramienta de apoyo a la decisión:

* Buscar señales **LONG** cuando EMA, Supertrend, ADX y HTF estén alineados al alza.
* Buscar señales **SHORT** cuando EMA, Supertrend, ADX y HTF estén alineados a la baja.
* Evitar operar cuando el panel indique **NO OPERAR** o cuando el ADX marque rango.
* Usar riesgo **NORMAL** cuando la confirmación sea fuerte.
* Usar riesgo **REDUCIDO** cuando la confirmación sea parcial o más débil.
* Utilizar las líneas de Entry, SL y TP para planificar la operación antes de entrar.

Este indicador no pretende predecir el mercado con certeza. Está diseñado como una herramienta estructurada de toma de decisiones para filtrar operaciones, reducir entradas impulsivas y mejorar la consistencia operativa.

## Source Code

````pine
//@version=5
indicator("Adaptive Trend Checklist (EMA + Supertrend + ADX)", overlay=true)
// ==========================================================
// MODO DE OPERACIÓN
// ==========================================================
// MODO GLOBAL: AUTO / MANUAL
// ==========================================================
useAuto = input.bool(true, "Modo Automático por Timeframe")

// ==========================================================
// INPUTS MANUALES (SOLO SE USAN SI useAuto = false)
// ==========================================================
manualTradeMode = input.string("CONSERVADOR", "Modo Manual", options=["CONSERVADOR","AGRESIVO","ULTRA AGRESIVO"])
manualEmaLen    = input.int(30, "EMA Manual")
manualAtrLen    = input.int(10, "ATR Manual")
manualStFactor  = input.float(3.0, "Factor Supertrend Manual")
manualAdxMin    = input.int(20, "ADX Mínimo Manual")

manualHTF1 = input.timeframe("15", "HTF 1 Manual")
manualHTF2 = input.timeframe("60", "HTF 2 Manual")
manualAdxLen = input.int(14, "ADX Length Manual")

// ==========================================================
// AUTO TF ENGINE
// ==========================================================
tfMin =     timeframe.isseconds ? timeframe.multiplier / 60 :     timeframe.isminutes ? timeframe.multiplier :     timeframe.isdaily   ? 1440 :     timeframe.isweekly  ? 10080 :     timeframe.ismonthly ? 43200 :                            5

isScalpFast = tfMin <= 3
isScalp     = tfMin > 3  and tfMin <= 5
isIntra     = tfMin > 5  and tfMin <= 15
isSwing     = tfMin > 15 and tfMin <= 60
isSwingHigh = tfMin > 60
autoAdxLen =     isScalpFast ? 10 :     isScalp     ? 12 :     isIntra     ? 14 :     isSwing     ? 18 :                   20

autoAdxMin =     isScalpFast ? 25 :     isScalp     ? 23 :     isIntra     ? 20 :     isSwing     ? 18 :                   15
adxMargin =     isScalpFast ? 7 :     isScalp     ? 7 :     isIntra     ? 10 :     isSwing     ? 15 :                    15
autoTradeMode =
     isScalpFast ? "AGRESIVO" :
     isScalp     ? "AGRESIVO" :
     isIntra     ? "AGRESIVO" :
     isSwing     ? "CONSERVADOR" :
                   "CONSERVADOR"

autoEmaLen =
     isScalpFast ? 21 :     isScalp     ? 30 :     isIntra     ? 30 :     isSwing     ? 50 :                   100

autoAtrLen =
     isScalpFast ? 7 :     isScalp     ? 10 :     isIntra     ? 10 :     isSwing     ? 10 :                   14

autoStFactor =     isScalpFast ? 2.5 :     isScalp     ? 3.0 :     isIntra     ? 3.0 :     isSwing     ? 3.5 :                   4.0



autoHTF1 =     isScalpFast ? "15" :     isScalp     ? "15" :     isIntra     ? "60" :     isSwing     ? "240" :                   "D"

autoHTF2 =     isScalpFast ? "60" :     isScalp     ? "60" :     isIntra     ? "240" :     isSwing     ? "D" :                   "W"
showScore = input.bool(false, "Mostrar Score HTF")

// ==========================================================
// VARIABLES FINALES (USAR SOLO ESTAS EN EL SCRIPT)
// ==========================================================
tradeMode = useAuto ? autoTradeMode : manualTradeMode
maLen     = useAuto ? autoEmaLen    : manualEmaLen
atrPeriod = useAuto ? autoAtrLen    : manualAtrLen
factor    = useAuto ? autoStFactor  : manualStFactor
adxMin    = useAuto ? autoAdxMin    : manualAdxMin
htfTF1    = useAuto ? autoHTF1      : manualHTF1
htfTF2    = useAuto ? autoHTF2      : manualHTF2
adxLenFinal = useAuto ? autoAdxLen : manualAdxLen
adxMinFinal = useAuto ? autoAdxMin : manualAdxMin



// ─── TAMAÑO DE LETRA ─────────────────────────────────────
chkFontOpt = input.string(     "SMALL",     "Letra Checklist",     options = ["MEDIANA", "SMALL", "TINY"])

riskFontOpt = input.string(     "SMALL",     "Letra Gestión",     options = ["MEDIANA", "SMALL", "TINY"])
// ─── MAPEO DE TAMAÑO DE TEXTO ────────────────────────────
chkTextSize =
     chkFontOpt == "MEDIANA" ? size.normal :
     chkFontOpt == "SMALL"   ? size.small  :
                               size.tiny

riskTextSize =     riskFontOpt == "MEDIANA" ? size.normal :     riskFontOpt == "SMALL"   ? size.small  :                                size.tiny


// ==========================================================
// SUPERTREND
// ==========================================================
// atrPeriod = input.int(10, "ATR Length"

// factor    = input.float(3.0, "Factor")

[supertrend, dir] = ta.supertrend(factor, atrPeriod)
supertrend := barstate.isfirst ? na : supertrend

plot(dir < 0 ? supertrend : na, color=color.green, style=plot.style_linebr)
plot(dir > 0 ? supertrend : na, color=color.red,   style=plot.style_linebr)

// ==========================================================
// ==========================================================
// MEDIA MÓVIL (EMA / SMA)
// ==========================================================
maType = input.string("EMA", "Tipo de Media", options=["EMA", "SMA"])
// maLen  = input.int(30, "Periodo Media")
maVal = maType == "EMA" ? ta.ema(close, maLen) : ta.sma(close, maLen)

plot(maVal,
     title="MEDIA",
     color=maType == "EMA" ? color.aqua : color.orange,
     linewidth=2)

// ==========================================================
// ==========================================================
// ADX DINÁMICO + CONTROL DE MODOS
// ==========================================================

// ─── INPUTS ADX ─────────────────────────────────────────
useADX = input.bool(true, "Usar ADX")
adxLen = input.int(14, "ADX Length")

[_, _, adxVal] = ta.dmi(adxLenFinal, adxLenFinal)


// ─── ADX mínimo dinámico por TF ─────────────────────────
// adxMin =     timeframe.isseconds ? 28 :     timeframe.multiplier <= 3   ? 25 :     timeframe.multiplier <= 5   ? 23 :     timeframe.multiplier <= 15  ? 20 :     timeframe.multiplier <= 60  ? 18 :     timeframe.multiplier <= 240 ? 15 :                                   13

// ─── ESTADO ADX (RANGO / TENDENCIA / FUERTE) ────────────
// ==========================================================
// VARIABLES FINALES ADX (AUTO / MANUAL)
// ==========================================================

// ADX Length final


adxState =
     not useADX                  ? "OFF" :
     adxVal < adxMinFinal        ? "RANGO" :
     adxVal < adxMinFinal + adxMargin ? "TENDENCIA" :
                                         "FUERTE"


// ─── COLORES ADX (SEMÁFORO) ─────────────────────────────
adxCol =
     not useADX                  ? color.new(color.gray, 80) :
     adxVal < adxMinFinal        ? color.gray :
     adxVal < adxMinFinal + adxMargin ? color.orange :
                                         color.green


// ─── ADX FUERTE (FILTRO PARA ULTRA) ─────────────────────
adxStrong = useADX and adxVal >= (adxMinFinal + adxMargin)



// ==========================================================
// MODOS DE TRADING (ORDEN CORRECTO)
// ==========================================================

// RAW (solo input)

// ─── MODOS RAW (solo input) ─────────────────────────────
isUltraAggressiveRaw = tradeMode == "ULTRA AGRESIVO"

isAggressiveRaw      = tradeMode == "AGRESIVO"
isConservative       = tradeMode == "CONSERVADOR"

// ULTRA solo si ADX fuerte
isUltraAggressive = isUltraAggressiveRaw and adxStrong

// fallback automático
isAggressive = isAggressiveRaw or (isUltraAggressiveRaw and not adxStrong)

// ==========================================================
// LÓGICA ADX SEGÚN MODO
// ==========================================================

adxTrend =
     not useADX         ? true :
     isUltraAggressive  ? adxVal >= (adxMinFinal - 5) :
     isAggressive       ? adxVal >= (adxMinFinal - 3) :
                           adxVal >= adxMinFinal



// ==========================================================
// CONDICIONES BASE
emaBull = close > maVal
emaBear = close < maVal

bullCond =
     isUltraAggressive ? emaBull :
     isAggressive      ? emaBull and close > supertrend :
                          emaBull and close > supertrend

bearCond =
     isUltraAggressive ? emaBear :
     isAggressive      ? emaBear and close < supertrend :
                          emaBear and close < supertrend








// ==========================================================

// ─── INPUTS HTF ─────────────────────────────────────────
useHTF1 = input.bool(true,  "Usar HTF 1")
// htfTF1  = input.timeframe("15",  "HTF 1")

useHTF2 = input.bool(true,  "Usar HTF 2")
// htfTF2  = input.timeframe("60",  "HTF 2")

useHTF3 = input.bool(false, "Usar HTF 3")
htfTF3  = input.timeframe("240", "HTF 3")

useHTF4 = input.bool(false, "Usar HTF 4")
htfTF4  = input.timeframe("D",   "HTF 4")

showBox = input.bool(true, "Mostrar Gestión")
// ─── PESOS POR TIMEFRAME ────────────────────────────────
wHTF1 = 1.0     // 60 min
wHTF2 = 1.5     // 240 min
wHTF3 = 2.0     // Diario
wHTF4 = 3.0     // Semanal

// ─── FUNCIÓN SUPERTREND HTF ─────────────────────────────
f_htfSupertrend() =>
    [st, _] = ta.supertrend(factor, atrPeriod)
    st

// ─── FUNCIÓN ESTADO HTF (SIN request EN IF) ─────────────
f_htfState(tf, enabled) =>
    ema = request.security(syminfo.tickerid, tf, ta.ema(close, maLen))
    st  = request.security(syminfo.tickerid, tf, f_htfSupertrend())
    cls = request.security(syminfo.tickerid, tf, close)

    bull = cls > ema and cls > st
    bear = cls < ema and cls < st

    txt = not enabled ? "—" :
          bull ? "BULLISH" :
          bear ? "BEARISH" :
                 "RANGO"

    col = not enabled ? color.new(color.gray, 80) :
          bull ? color.new(color.green, 0) :
          bear ? color.new(color.red, 0) :
                 color.new(color.gray, 0)

    bullOut = enabled ? bull : true
    bearOut = enabled ? bear : true

    [txt, col, bullOut, bearOut]

// ─── ESTADOS HTF EN VIVO ───────────────────────────────
[htf1Txt, htf1Col, htf1Bull, htf1Bear] = f_htfState(htfTF1, useHTF1)
[htf2Txt, htf2Col, htf2Bull, htf2Bear] = f_htfState(htfTF2, useHTF2)
[htf3Txt, htf3Col, htf3Bull, htf3Bear] = f_htfState(htfTF3, useHTF3)
[htf4Txt, htf4Col, htf4Bull, htf4Bear] = f_htfState(htfTF4, useHTF4)
// ─── SCORE ALCISTA / BAJISTA ────────────────────────────
bullScore =
     (useHTF1 and htf1Bull ? wHTF1 : 0) +
     (useHTF2 and htf2Bull ? wHTF2 : 0) +
     (useHTF3 and htf3Bull ? wHTF3 : 0) +
     (useHTF4 and htf4Bull ? wHTF4 : 0)

bearScore =
     (useHTF1 and htf1Bear ? wHTF1 : 0) +
     (useHTF2 and htf2Bear ? wHTF2 : 0) +
     (useHTF3 and htf3Bear ? wHTF3 : 0) +
     (useHTF4 and htf4Bear ? wHTF4 : 0)
maxScore =
     (useHTF1 ? wHTF1 : 0) +
     (useHTF2 ? wHTF2 : 0) +
     (useHTF3 ? wHTF3 : 0) +
     (useHTF4 ? wHTF4 : 0)
scoreThreshold = maxScore * 0.6
htfBullOK = bullScore >= scoreThreshold
htfBearOK = bearScore >= scoreThreshold
scorePct = maxScore > 0 ? math.max(bullScore, bearScore) / maxScore : 0

htfQuality =
     scorePct >= 0.8 ? "FUERTE" :
     scorePct >= 0.6 ? "MEDIA" :
                       "DÉBIL"



// ==========================================================
// EMA / ST ESTADO
// ==========================================================
emaTxt = close > maVal ? "BULLISH" : close < maVal ? "BEARISH" : "RANGO"
emaCol = emaTxt == "BULLISH" ? color.green : emaTxt == "BEARISH" ? color.red : color.gray

stTxt  = close > supertrend ? "BULLISH" : close < supertrend ? "BEARISH" : "RANGO"
stCol  = stTxt == "BULLISH" ? color.green : stTxt == "BEARISH" ? color.red : color.gray
bonusBull =
     emaTxt == "BULLISH" and stTxt == "BULLISH" ? 1 : 0

bonusBear =
     emaTxt == "BEARISH" and stTxt == "BEARISH" ? 1 : 0
bullScoreFinal = bullScore + bonusBull
bearScoreFinal = bearScore + bonusBear



// ==========================================================
// VARIABLES CONGELADAS
// ==========================================================
var string p_dirTxt  = "—"
var color  p_dirCol  = color.gray
var string p_riskTxt = "—"
var color  p_riskCol = color.gray

// ==========================================================
// EVALUAR SOLO EN NUEVA SEÑAL
// ==========================================================
var bool htfOK = false
rawSell = bearCond
rawBuy  = bullCond
hasRange =     emaTxt == "RANGO" or         stTxt  == "RANGO" or       adxState == "RANGO"
 or
     (useHTF1 and htf1Txt == "RANGO") or
     (useHTF2 and htf2Txt == "RANGO")






finalRiskTxt = hasRange ? "NO OPERAR" : p_riskTxt
triggerLong =
     isUltraAggressive ? close > close[1] :   // ultra = más rápido
                          close > high[1]     // conservador / agresivo

triggerShort =
     isUltraAggressive ? close < close[1] :
                          close < low[1]
// ─── TRIGGER DE ENTRADA (CONFIRMACIÓN MOMENTUM) ─────────


finalRiskCol = hasRange ? color.gray : p_riskCol
wasGray = finalRiskTxt[1] == "NO OPERAR"
nowTradable = finalRiskTxt != "NO OPERAR"
exitGray = wasGray and nowTradable
buySignal =
     rawBuy
     and triggerLong
     and (not rawBuy[1] or exitGray)

sellSignal =
     rawSell
     and triggerShort
     and (not rawSell[1] or exitGray)
scoreActive = buySignal ? bullScoreFinal :
              sellSignal ? bearScoreFinal :
              na

// scoreTxt =
//      na(scoreActive) ? "—" :
//      str.tostring(scoreActive) + " / " + str.tostring(maxScore)



isTradeSignal = buySignal or sellSignal      // señal estructural
isOperable   = finalRiskTxt != "NO OPERAR"   // filtro de riesgo
entryCol = isOperable ? color.blue  : color.gray
slCol    = isOperable ? color.red   : color.gray
tpCol    = isOperable ? color.green : color.gray


newSignal = buySignal or sellSignal
if finalRiskTxt == "NO OPERAR"
    newSignal := false

plotshape(buySignal,  location=location.belowbar, style=shape.triangleup,   color=color.green, size=size.small)
plotshape(sellSignal, location=location.abovebar, style=shape.triangledown, color=color.red,   size=size.small)
if isUltraAggressive and adxState == "RANGO"
    newSignal := false


if newSignal
    execOK = buySignal or sellSignal
    if newSignal
        htfOK :=     not (useHTF1 or useHTF2 or useHTF3 or useHTF4) ? true :     buySignal  ? htfBullOK :     sellSignal ? htfBearOK :                  false

                          




    gradeA = execOK and htfOK and adxTrend
    gradeB = execOK and (            isAggressive or            (not adxTrend)
         )
    gradeC = not execOK

    p_dirTxt := buySignal ? "LONG" : "SHORT"
    p_dirCol := buySignal ? color.green : color.red

    p_riskTxt := gradeA ? "NORMAL" : gradeB ? "REDUCIDO" : "NO OPERAR"
    p_riskCol := gradeA ? color.green : gradeB ? color.orange : color.gray
    



// ==========================================================
// DETECTAR RANGO GLOBAL
// ==========================================================


// ─── COLORES DINÁMICOS DE SEÑAL ─────────────────────────
buyColor =
     finalRiskTxt == "NO OPERAR" ? color.gray :
     finalRiskTxt == "REDUCIDO"  ? color.new(color.green, 40) :
                                   color.new(color.green, 0)

sellColor =
     finalRiskTxt == "NO OPERAR" ? color.gray :
     finalRiskTxt == "REDUCIDO"  ? color.new(color.red, 40) :
                                   color.new(color.red, 0)

// ─── TRIGGER DE ENTRADA (NO REPAINT) ─────────────────────

// ─── SEÑALES VISUALES (CON TRIGGER) ─────────────────────


// ─── COLORES DE SEÑAL SEGÚN ADX ─────────────────────────
buySignalColor =
     adxState == "RANGO" ? color.new(color.gray, 0) :
     finalRiskTxt == "REDUCIDO" ? color.new(color.green, 40) :
     finalRiskTxt == "NORMAL"   ? color.new(color.green, 0)  :
                                  color.new(color.gray, 0)

sellSignalColor =
     adxState == "RANGO" ? color.new(color.gray, 0) :
     finalRiskTxt == "REDUCIDO" ? color.new(color.red, 40) :
     finalRiskTxt == "NORMAL"   ? color.new(color.red, 0)  :
                                  color.new(color.gray, 0)
plotshape(
     buySignal,
     location = location.belowbar,
     style    = shape.triangleup,
     color    = buySignalColor,
     size     = size.small)

plotshape(
     sellSignal,
     location = location.abovebar,
     style    = shape.triangledown,
     color    = sellSignalColor,
     size     = size.small)


// ─── MODO TEXTO Y COLOR ──────────────────────────────────
modeTxt =
     isUltraAggressiveRaw and not adxStrong ? "ULTRA BLOQUEADO ⚠️" :
     isUltraAggressive                     ? "ULTRA AGRESIVO ⚠️" :
     isAggressiveRaw                       ? "AGRESIVO" :
                                             "CONSERVADOR"

modeCol =
     isUltraAggressiveRaw and not adxStrong ? color.gray :
     isUltraAggressive                     ? color.red :
     isAggressiveRaw                       ? color.orange :
                                             color.blue
if isUltraAggressiveRaw and not adxStrong
    finalRiskTxt := "NO OPERAR"
    finalRiskCol := color.gray

//autocontrol
var int tradesToday = 0
newDay = ta.change(time("D"))

// ==========================================================
// ==========================================================
// CHECKLIST VISUAL
// ==========================================================

showBox1 = input.bool(true, "Mostrar Checklist")
// ─── SESIONES / MERCADOS ─────────────────────────────────
inLondon  = not na(time(timeframe.period, "0800-1700"))
inNewYork = not na(time(timeframe.period, "1300-2200"))
inSydney  = not na(time(timeframe.period, "2100-0600"))

marketTxt =
     inLondon and inNewYork ? "US · EU" :
     inSydney and inLondon  ? "ASIA · EU" :
     inSydney and inNewYork ? "ASIA · US" :
     inNewYork              ? "US" :
     inLondon               ? "EU" :
     inSydney               ? "ASIA" :
                               "SIN MERCADO"


marketCol =
     inLondon and inNewYork ? color.new(color.green, 0) :      // US · EU → TOP
     inSydney and inLondon  ? color.new(color.orange, 0) :     // ASIA · EU → Transición
     inSydney and inNewYork ? color.new(color.yellow, 0) :     // ASIA · US → Débil
     inLondon               ? color.new(color.blue, 0) :       // EU solo
     inNewYork              ? color.new(color.teal, 0) :       // US solo
     inSydney               ? color.new(color.purple, 0) :    // ASIA solo
                               color.new(color.gray, 80)      // Cerrado



// ─── OPCIONES CHECKLIST (VISUAL) ───────────────────────



// ==========================================================
// CHECKLIST VISUAL · 1 COLUMNA · SEMÁFORO
// ==========================================================



// ─── COLORES SEMÁFORO (FONDO) ───────────────────────────

// MTF
mtf1_bg = not useHTF1 ? color.new(color.gray, 80) :
          htf1Txt == "RANGO" ? color.gray :
          htf1Txt == "BULLISH" ? color.green : color.red

mtf2_bg = not useHTF2 ? color.new(color.gray, 80) :
          htf2Txt == "RANGO" ? color.gray :
          htf2Txt == "BULLISH" ? color.green : color.red

mtf3_bg = not useHTF3 ? color.new(color.gray, 80) :
          htf3Txt == "RANGO" ? color.gray :
          htf3Txt == "BULLISH" ? color.green : color.red

mtf4_bg = not useHTF4 ? color.new(color.gray, 80) :
          htf4Txt == "RANGO" ? color.gray :
          htf4Txt == "BULLISH" ? color.green : color.red

// INDICADORES
ema_bg = emaTxt == "RANGO" ? color.gray :
         emaTxt == "BULLISH" ? color.green : color.red

st_bg  = stTxt == "RANGO" ? color.gray :
         stTxt == "BULLISH" ? color.green : color.red

adx_bg = adxState == "RANGO" ? color.gray : color.green
// ==========================================================
// ==========================================================



// ─── TEXTO + COLOR DINÁMICO ─────────────────────────────

// MODO
mode_txt = isAggressive ? "AGRESIVO" : "CONSERVADOR"
mode_bg  = isAggressive ? color.orange : color.blue

// SEÑAL
signal_txt =
     not newSignal ? "—" :
     buySignal ? "LONG" :
     sellSignal ? "SHORT" : "—"

signal_bg =
     not newSignal ? color.new(color.gray, 80) :
     buySignal ? color.green :
     sellSignal ? color.red : color.gray

// MERCADO
market_txt = marketTxt == "SIN MERCADO" ? "CERRADO" : "ABIERTO"
market_bg  = marketTxt == "SIN MERCADO" ? color.gray : color.blue

// GESTIÓN
gestion_txt =
     finalRiskTxt == "NO OPERAR" ? "NO OPERAR" :
     finalRiskTxt == "REDUCIDO"  ? "REDUCIDO" :
                                   "NORMAL"

gestion_bg =
     finalRiskTxt == "NO OPERAR" ? color.gray :
     finalRiskTxt == "REDUCIDO"  ? color.orange :
                                   color.green
if scoreActive < maxScore * 0.5
    finalRiskTxt := "NO OPERAR"


// ─── TABLA CHECKLIST ───────────────────────────────────

// ─── ESTADOS AUXILIARES ────────────────────────────────

// ─── CHECKLIST VISUAL ──────────────────────────────────

// ─── OPCIÓN MERCADO ─────────────────────────────────────
showMarket = input.bool(true, "Mostrar Mercado Abierto")

// ─── TABLA (SE DECLARA UNA SOLA VEZ, FUERA DEL IF) ──────
var table chkTable = table.new(position.top_right, 2, 17, border_width = 1)
// ==========================================================
// MODO SISTEMA (AUTO / MANUAL / MONO)
// ==========================================================

// Input
systemMode = input.string(     "AUTO",     "Modo del Sistema",     options = ["AUTO", "MANUAL", "MONO"])

// Texto y color para checklist
autoModeTxt =     systemMode == "AUTO"   ? "AUTO TF" :     systemMode == "MANUAL" ? "MANUAL"  :                              "MONO"

autoModeCol =     systemMode == "AUTO"   ? color.new(color.green, 0) :    systemMode == "MANUAL" ? color.new(color.orange, 0) :                              color.new(color.blue, 0)

// ==========================================================
// SCORE HTF (PESO POR TIMEFRAME)
// ==========================================================

// Pesos (ajústalos si quieres)


scoreHTF = 0.0

// HTF 1
if useHTF1
    scoreHTF += htf1Bull ?  wHTF1 :                htf1Bear ? -wHTF1 : 0
// HTF 2
if useHTF2
    scoreHTF += htf2Bull ?  wHTF2 :                htf2Bear ? -wHTF2 : 0

// HTF 3
if useHTF3
    scoreHTF += htf3Bull ?  wHTF3 :                htf3Bear ? -wHTF3 : 0

// HTF 4
if useHTF4
    scoreHTF += htf4Bull ?  wHTF4 :                htf4Bear ? -wHTF4 : 0

// Texto
scoreTxt =
     scoreHTF >= 4   ? "STRONG BULLISH +" + str.tostring(scoreHTF) :
     scoreHTF >= 2   ? "BULLISH +" + str.tostring(scoreHTF) :
     scoreHTF <= -4  ? "STRONG BEARISH " + str.tostring(scoreHTF) :
     scoreHTF <= -2  ? "BEARISH " + str.tostring(scoreHTF) :
                       "NEUTRAL"

scoreCol =
     scoreHTF >= 4  ? color.green :
     scoreHTF >= 2  ? color.lime :
     scoreHTF <= -4 ? color.red :
     scoreHTF <= -2 ? color.orange :
                      color.gray
// ─── CHECKLIST VISUAL ───────────────────────────────────
// ─── CHECKLIST VISUAL ───────────────────────────────────
if showBox1
    // Limpieza correcta (2 columnas, filas 0–13)
    table.clear(chkTable, 0, 0, 1, 13)

    // ─── TÍTULO ─────────────────────────────────────────
    table.cell(chkTable, 0, 0, "CHECKLIST",
         bgcolor=color.black, text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 0, p_dirTxt,
         bgcolor=p_dirCol, text_color=color.white, text_size=chkTextSize)

    // ─── MODO SISTEMA ───────────────────────────────────
    table.cell(chkTable, 0, 1, "MODO SISTEMA",
         text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 1, autoModeTxt,
         bgcolor=autoModeCol, text_color=color.white, text_size=chkTextSize)

    // ─── MODO DE TRADING ────────────────────────────────
    table.cell(chkTable, 0, 2, "MODO TRADING",
         text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 2, tradeMode,
         bgcolor=modeCol, text_color=color.white, text_size=chkTextSize)

    // ─── HTF ────────────────────────────────────────────
    if useHTF1
        table.cell(chkTable, 0, 3, htfTF1 + " min",
             text_color=color.white, text_size=chkTextSize)
        table.cell(chkTable, 1, 3, htf1Txt,
             bgcolor=htf1Col, text_color=color.white, text_size=chkTextSize)

    if useHTF2
        table.cell(chkTable, 0, 4, htfTF2 + " min",
             text_color=color.white, text_size=chkTextSize)
        table.cell(chkTable, 1, 4, htf2Txt,
             bgcolor=htf2Col, text_color=color.white, text_size=chkTextSize)

    if useHTF3
        table.cell(chkTable, 0, 5, htfTF3 + " min",
             text_color=color.white, text_size=chkTextSize)
        table.cell(chkTable, 1, 5, htf3Txt,
             bgcolor=htf3Col, text_color=color.white, text_size=chkTextSize)

    if useHTF4
        table.cell(chkTable, 0, 6, htfTF4 + " min",
             text_color=color.white, text_size=chkTextSize)
        table.cell(chkTable, 1, 6, htf4Txt,
             bgcolor=htf4Col, text_color=color.white, text_size=chkTextSize)

    // ─── SCORE HTF (OPCIONAL) ───────────────────────────
    if showScore
        table.cell(chkTable, 0, 7, "SCORE HTF",
             text_color=color.white, text_size=chkTextSize)
        table.cell(chkTable, 1, 7, scoreTxt,
             bgcolor=scoreCol, text_color=color.white, text_size=chkTextSize)

    // ─── EMA / SUPERTREND ───────────────────────────────
    table.cell(chkTable, 0, 8, "EMA",
         text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 8, emaTxt,
         bgcolor=emaCol, text_color=color.white, text_size=chkTextSize)

    table.cell(chkTable, 0, 9, "SUPERTREND",
         text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 9, stTxt,
         bgcolor=stCol, text_color=color.white, text_size=chkTextSize)

    // ─── ADX ────────────────────────────────────────────
    adxUp    = adxVal > adxVal[1]
    adxDown  = adxVal < adxVal[1]
    adxArrow = adxUp ? " ↑" : adxDown ? " ↓" : " →"

    adxTxt = not useADX ? "ADX OFF" :
             adxState + " (" + str.tostring(adxVal, "#.0") + ")" + adxArrow

    table.cell(chkTable, 0, 10, "ADX",
         text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 10, adxTxt,
         bgcolor=adxCol, text_color=color.white, text_size=chkTextSize)

    // ─── SEÑAL ACTIVA ───────────────────────────────────
    table.cell(chkTable, 0, 11, "SEÑAL ACTIVA",
         text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 11, newSignal ? "SÍ" : "—",
         bgcolor = newSignal ? color.new(color.green, 0) : color.new(color.gray, 80),
         text_color=color.white, text_size=chkTextSize)

    // ─── MERCADO ────────────────────────────────────────
    if showMarket
        table.cell(chkTable, 0, 12, "MERCADO",
             text_color=color.white, text_size=chkTextSize)
        table.cell(chkTable, 1, 12, marketTxt,
             bgcolor=marketCol, text_color=color.white, text_size=chkTextSize)

    // ─── GESTIÓN FINAL ──────────────────────────────────
    table.cell(chkTable, 0, 13, "GESTIÓN",
         text_color=color.white, text_size=chkTextSize)
    table.cell(chkTable, 1, 13, finalRiskTxt,
         bgcolor=finalRiskCol, text_color=color.white, text_size=chkTextSize)

// ==========================================================
/// ==========================================================
// LÍNEAS ENTRY / SL / TP (SL INTELIGENTE)
// ==========================================================
lineBars = 60

var line entryLine = na
var line slLine    = na
var line tp1Line   = na
var line tp2Line   = na
var line tp3Line   = na

var label entryLbl = na
var label slLbl    = na
var label tp1Lbl   = na
var label tp2Lbl   = na
var label tp3Lbl   = na

var float entryPrice = na
var float stopLoss   = na
var float tp1 = na
var float tp2 = na
var float tp3 = na
var float risk = na

// ─── SWINGS (ESTRUCTURA) ────────────────────────────────
swingLen =
     isUltraAggressive ? 2 :
     isAggressive      ? 3 :
                          5

swingLow  = ta.lowest(low, swingLen)
swingHigh = ta.highest(high, swingLen)

// ─── MULTIPLICADOR SL POR TIMEFRAME ─────────────────────
slMult =
     timeframe.isseconds ? 1.6 :
     timeframe.multiplier <= 3   ? 1.5 :
     timeframe.multiplier <= 5   ? 1.4 :
     timeframe.multiplier <= 15  ? 1.3 :
     timeframe.multiplier <= 60  ? 1.2 :
                                   1.1

// ==========================================================
// EJECUCIÓN SOLO EN SEÑAL
// ==========================================================
if isTradeSignal
    // ─── LIMPIAR LÍNEAS Y LABELS PREVIOS ─────────────────
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)

    label.delete(entryLbl)
    label.delete(slLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)

    // ─── ENTRY ──────────────────────────────────────────
    entryPrice := close

    // ─── DISTANCIA SUPERTREND ───────────────────────────
    stDist = math.abs(entryPrice - supertrend)

    // ─── SL POR SUPERTREND (✔ SINTAXIS CORRECTA) ─────────
    sl_st =        finalRiskTxt == "REDUCIDO"            ? (buySignal                ? entryPrice - stDist * slMult                : entryPrice + stDist * slMult)            : supertrend

    // ─── SL POR ESTRUCTURA ──────────────────────────────
    sl_struct = buySignal ? swingLow : swingHigh

    // ─── SELECCIÓN SL MÁS SEGURO ─────────────────────────
    if buySignal
        stopLoss := math.min(sl_st, sl_struct)
    else
        stopLoss := math.max(sl_st, sl_struct)

    // ─── RIESGO REAL ────────────────────────────────────
    risk := math.abs(entryPrice - stopLoss)

    // ─── TAKE PROFITS ───────────────────────────────────
    tp1 := buySignal ? entryPrice + risk : entryPrice - risk
    tp2 := buySignal ? entryPrice + risk * 2 : entryPrice - risk * 2
    tp3 := (isAggressive or isUltraAggressive)        ? (buySignal ? entryPrice + risk * 3 : entryPrice - risk * 3)        : na

    // ─── COLORES (OPERABLE VS GRIS) ─────────────────────
    entryColor = finalRiskTxt == "NO OPERAR" ? color.gray : entryCol
    slColor    = finalRiskTxt == "NO OPERAR" ? color.gray : slCol
    tpColor    = finalRiskTxt == "NO OPERAR" ? color.gray : tpCol

    // ─── LÍNEAS ─────────────────────────────────────────
    entryLine := line.new(bar_index, entryPrice, bar_index + lineBars, entryPrice, color=entryColor, width=2)
    slLine    := line.new(bar_index, stopLoss,   bar_index + lineBars, stopLoss,   color=slColor,    width=2)
    tp1Line   := line.new(bar_index, tp1, bar_index + lineBars, tp1, color=tpColor)
    tp2Line   := line.new(bar_index, tp2, bar_index + lineBars, tp2, color=tpColor)

    if not na(tp3)
        tp3Line := line.new(bar_index, tp3, bar_index + lineBars, tp3, color=tpColor)

    // ─── LABELS ─────────────────────────────────────────
    entryLbl := label.new(bar_index + lineBars, entryPrice,        "ENTRY\n" + str.tostring(entryPrice, format.mintick),        xloc=xloc.bar_index, yloc=yloc.price,        style=label.style_label_left,       color=entryColor, textcolor=color.white, size=size.small)

    slLbl := label.new(bar_index + lineBars, stopLoss,        "SL\n" + str.tostring(stopLoss, format.mintick),        xloc=xloc.bar_index, yloc=yloc.price,        style=label.style_label_left,color=slColor, textcolor=color.white, size=size.small)

    tp1Lbl := label.new(bar_index + lineBars, tp1,        "TP 1\n" + str.tostring(tp1, format.mintick),        xloc=xloc.bar_index, yloc=yloc.price,        style=label.style_label_left,       color=tpColor, textcolor=color.white, size=size.small)

    tp2Lbl := label.new(bar_index + lineBars, tp2,        "TP 2\n" + str.tostring(tp2, format.mintick),       xloc=xloc.bar_index, yloc=yloc.price,        style=label.style_label_left,       color=tpColor, textcolor=color.white, size=size.small)

    if not na(tp3)
        tp3Lbl := label.new(bar_index + lineBars, tp3,            "TP 3\n" + str.tostring(tp3, format.mintick),            xloc=xloc.bar_index, yloc=yloc.price,            style=label.style_label_left,            color=tpColor, textcolor=color.white, size=size.small)

// ==========================================================
// ==========================================================
// RECUADRO GESTIÓN DE POSICIÓN (EN DÓLARES)
// ==========================================================

// Inputs
capital = input.float(1000, "Capital ($)", step = 100)
riskPct = input.float(1.0,  "Riesgo (%)", step = 0.1)

// Cálculos
riskDollar  = capital * riskPct / 100
riskPerUnit = math.abs(entryPrice - stopLoss)

// Tamaño de posición en dólares
positionUSD = (riskPerUnit > 0 and not na(entryPrice) and not na(stopLoss)) ?
     (riskDollar / riskPerUnit) * entryPrice :
     na

// ==========================================================
// TABLA GESTIÓN DE RIESGO (CON TP Y SL COLOREADOS)




var table posTable = table.new(     position.bottom_right,     2,     9,     border_width = 1)


if barstate.islast and not na(positionUSD)
    table.clear(posTable, 0, 0, 1, 8)

    // TÍTULO
    table.cell(posTable, 0, 0, "GESTIÓN", bgcolor=color.black, text_color=color.white,text_size=riskTextSize)
    table.cell(posTable, 1, 0, "", bgcolor=color.black,text_size=riskTextSize)

    // CAPITAL
    table.cell(posTable, 0, 1, "Capital", text_color=color.white,text_size=riskTextSize)
    table.cell(posTable, 1, 1, "$" + str.tostring(capital), text_color=color.white,text_size=riskTextSize)

    // RIESGO $
    table.cell(posTable, 0, 2, "Riesgo", text_color=color.white,text_size=riskTextSize)
    table.cell(posTable, 1, 2, "$" + str.tostring(riskDollar, format.mintick), text_color=color.white,text_size=riskTextSize)

 

    // TP1 (VERDE)
    table.cell(posTable, 0, 3, "TP 1", text_color=color.white,text_size=riskTextSize)
    table.cell(posTable, 1, 3, str.tostring(tp1, format.mintick),       text_color=color.white,text_size=riskTextSize)

    // TP2 (VERDE)
    table.cell(posTable, 0, 4, "TP 2", text_color=color.white,text_size=riskTextSize)
    table.cell(posTable, 1, 4, str.tostring(tp2, format.mintick),        text_color=color.white,text_size=riskTextSize)
//tp3
    if isAggressive
        table.cell(posTable, 0, 5, "TP 3", text_color=color.white,text_size=riskTextSize)
        table.cell(posTable, 1, 5, str.tostring(tp3, format.mintick),        text_color=color.white,text_size=riskTextSize)


   // STOP LOSS (ROJO)
    table.cell(posTable, 0, 6, "SL", text_color=color.white,text_size=riskTextSize)
    table.cell(posTable, 1, 6, str.tostring(stopLoss, format.mintick),        text_color=color.white,text_size=riskTextSize)

    // TAMAÑO POSICIÓN $
    table.cell(posTable, 0, 7, "Tamaño $", text_color=color.white,text_size=riskTextSize)
    table.cell(posTable, 1, 7, "$" + str.tostring(positionUSD, format.mintick), text_color=color.white,text_size=riskTextSize)


// ==========================================================
// ALERTAS (UNA SOLA LÍNEA, SIN SPAM)
// ==========================================================

// COMPRA
alertcondition(
     buySignal and newSignal,     title   = "ALERTA COMPRA",     message = "COMPRA | {{ticker}} | TF {{interval}} | Precio {{close}}")

// VENTA
alertcondition(     sellSignal and newSignal,     title   = "ALERTA VENTA",     message = "VENTA | {{ticker}} | TF {{interval}} | Precio {{close}}")

// COMPRA / VENTA
alertcondition(     newSignal,     title   = "ALERTA COMPRA / VENTA",     message = "SEÑAL | {{ticker}} | TF {{interval}} | Precio {{close}}")

// COMPRA / VENTA NO GRIS (GRADE A + B)
alertcondition(     newSignal and finalRiskTxt != "NO OPERAR",     title   = "ALERTA COMPRA / VENTA NO GRIS",    message = "SEÑAL OPERABLE | {{ticker}} | TF {{interval}} | Precio {{close}}")
````
