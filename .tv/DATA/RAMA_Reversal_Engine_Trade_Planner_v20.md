<!-- tradingview-pine-id: PUB;393943e732114a6185cfa6b9c15f8841 -->
<!-- tradingviewscripts-format: 1 -->
# RAMA Reversal Engine + Trade Planner v2.0

Source: https://www.tradingview.com/script/8blYFZrR-RAMA-ALPHA-PRO-V-2-1/

## Description

RAMA ALPHA PRO V2.1 is a 4-hour swing trading indicator designed to detect early bullish reversal setups without waiting for delayed MACD confirmation. It prioritizes RSI, price action, momentum, stochastic behavior, EMA context, volume, and daily trend to generate Preparation, Buy, and Strong Buy signals. It also includes an automated trade planner with entry, stop-loss, profit targets, risk percentage, resistance analysis, and position sizing.

---

## Source Code

````pine
//@version=6
indicator(
     title = "RAMA Reversal Engine + Trade Planner v2.0",
     shorttitle = "RRE Planner v2.0",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 100
)

//=====================================================================
// 1. CONFIGURACIÓN GENERAL
//=====================================================================

groupGeneral = "1. Configuración general"

onlyConfirmedBars = input.bool(
     true,
     "Señales únicamente al cierre de vela",
     group = groupGeneral
)

showPreparation = input.bool(
     true,
     "Mostrar P de preparación",
     group = groupGeneral
)

showInvalidation = input.bool(
     true,
     "Mostrar X de riesgo",
     group = groupGeneral
)

showPanel = input.bool(
     true,
     "Mostrar panel RAMA",
     group = groupGeneral
)

showEmas = input.bool(
     true,
     "Mostrar EMA",
     group = groupGeneral
)

showTradeLines = input.bool(
     true,
     "Mostrar líneas del Trade Planner",
     group = groupGeneral
)

signalCooldown = input.int(
     6,
     "Velas mínimas entre señales",
     minval = 1,
     maxval = 50,
     group = groupGeneral
)

useDailyContext = input.bool(
     true,
     "Usar contexto diario",
     group = groupGeneral
)

//=====================================================================
// 2. UMBRALES DE SEÑAL
//=====================================================================

groupThresholds = "2. Umbrales"

preparationThreshold = input.int(
     50,
     "Score mínimo P",
     minval = 0,
     maxval = 100,
     group = groupThresholds
)

buyThreshold = input.int(
     65,
     "Score mínimo C",
     minval = 0,
     maxval = 100,
     group = groupThresholds
)

strongBuyThreshold = input.int(
     80,
     "Score mínimo C+",
     minval = 0,
     maxval = 100,
     group = groupThresholds
)

//=====================================================================
// 3. RSI
//=====================================================================

groupRsi = "3. RSI principal"

rsiLength = input.int(
     14,
     "Periodo RSI",
     minval = 2,
     group = groupRsi
)

rsiOversold = input.float(
     30.0,
     "Nivel de sobreventa",
     step = 0.5,
     group = groupRsi
)

rsiOpportunityMax = input.float(
     40.0,
     "RSI máximo para señal",
     step = 0.5,
     group = groupRsi
)

//=====================================================================
// 4. MEDIAS
//=====================================================================

groupTrend = "4. Tendencia y EMA"

emaFastLength = input.int(
     9,
     "EMA rápida",
     minval = 2,
     group = groupTrend
)

ema20Length = input.int(
     20,
     "EMA 20",
     minval = 2,
     group = groupTrend
)

ema50Length = input.int(
     50,
     "EMA 50",
     minval = 2,
     group = groupTrend
)

ema200Length = input.int(
     200,
     "EMA 200",
     minval = 2,
     group = groupTrend
)

//=====================================================================
// 5. MOMENTUM
//=====================================================================

groupMomentum = "5. Momentum"

macdFast = input.int(
     12,
     "MACD rápido",
     minval = 1,
     group = groupMomentum
)

macdSlow = input.int(
     26,
     "MACD lento",
     minval = 2,
     group = groupMomentum
)

macdSignalLength = input.int(
     9,
     "MACD señal",
     minval = 1,
     group = groupMomentum
)

stochLength = input.int(
     14,
     "Periodo estocástico",
     minval = 2,
     group = groupMomentum
)

stochSmoothK = input.int(
     3,
     "Suavizado K",
     minval = 1,
     group = groupMomentum
)

stochSmoothD = input.int(
     3,
     "Suavizado D",
     minval = 1,
     group = groupMomentum
)

//=====================================================================
// 6. VOLUMEN Y ATR
//=====================================================================

groupVolatility = "6. Volumen y volatilidad"

volumeLength = input.int(
     20,
     "Promedio de volumen",
     minval = 2,
     group = groupVolatility
)

atrLength = input.int(
     14,
     "Periodo ATR",
     minval = 2,
     group = groupVolatility
)

//=====================================================================
// 7. TRADE PLANNER
//=====================================================================

groupPlanner = "7. Trade Planner"

entryMode = input.string(
     "Ruptura",
     "Modo de entrada",
     options = ["Ruptura", "Retroceso", "Cierre de señal"],
     group = groupPlanner
)

breakoutAtrBuffer = input.float(
     0.10,
     "Margen ATR sobre máximo",
     minval = 0,
     step = 0.05,
     group = groupPlanner
)

retracementPercent = input.float(
     50.0,
     "Retroceso dentro de la vela (%)",
     minval = 0,
     maxval = 100,
     step = 5,
     group = groupPlanner
)

stopLookback = input.int(
     5,
     "Velas para stop estructural",
     minval = 2,
     maxval = 30,
     group = groupPlanner
)

stopAtrBuffer = input.float(
     0.20,
     "Margen ATR debajo del soporte",
     minval = 0,
     step = 0.05,
     group = groupPlanner
)

target1R = input.float(
     1.5,
     "Objetivo 1 en R",
     minval = 0.5,
     step = 0.25,
     group = groupPlanner
)

target2R = input.float(
     2.5,
     "Objetivo 2 en R",
     minval = 1,
     step = 0.25,
     group = groupPlanner
)

target3R = input.float(
     4.0,
     "Objetivo 3 en R",
     minval = 1,
     step = 0.25,
     group = groupPlanner
)

resistanceLookback = input.int(
     30,
     "Velas para resistencia cercana",
     minval = 5,
     maxval = 200,
     group = groupPlanner
)

useResistanceBlock = input.bool(
     true,
     "Bloquear si la resistencia está muy cerca",
     group = groupPlanner
)

minimumRoomR = input.float(
     1.5,
     "Espacio mínimo hasta resistencia (R)",
     minval = 0.5,
     step = 0.25,
     group = groupPlanner
)

maximumStopPercent = input.float(
     6.0,
     "Riesgo máximo entrada-stop (%)",
     minval = 0.5,
     step = 0.5,
     group = groupPlanner
)

manualBlock = input.bool(
     false,
     "Bloqueo manual: earnings/noticia/evento",
     group = groupPlanner
)

//=====================================================================
// 8. GESTIÓN DE CAPITAL
//=====================================================================

groupCapital = "8. Gestión de capital"

accountCapitalMxn = input.float(
     20000,
     "Capital de cuenta (MXN)",
     minval = 1,
     step = 1000,
     group = groupCapital
)

riskPerTradePercent = input.float(
     1.0,
     "Riesgo por operación (%)",
     minval = 0.1,
     maxval = 10,
     step = 0.1,
     group = groupCapital
)

maximumPositionPercent = input.float(
     15.0,
     "Máximo del capital por posición (%)",
     minval = 1,
     maxval = 100,
     step = 1,
     group = groupCapital
)

usdMxnExchangeRate = input.float(
     19.00,
     "Tipo de cambio USD/MXN",
     minval = 1,
     step = 0.10,
     group = groupCapital
)

allowFractionalShares = input.bool(
     true,
     "Permitir acciones fraccionadas",
     group = groupCapital
)

//=====================================================================
// 9. CÁLCULOS PRINCIPALES
//=====================================================================

rsi = ta.rsi(close, rsiLength)
rsiSlope = rsi - rsi[1]
rsiThreeBarChange = rsi - rsi[3]

ema9 = ta.ema(close, emaFastLength)
ema20 = ta.ema(close, ema20Length)
ema50 = ta.ema(close, ema50Length)
ema200 = ta.ema(close, ema200Length)

[macdLine, macdSignalLine, macdHistogram] =
     ta.macd(close, macdFast, macdSlow, macdSignalLength)

lowestStochLow = ta.lowest(low, stochLength)
highestStochHigh = ta.highest(high, stochLength)
stochRange = highestStochHigh - lowestStochLow

rawK =
     stochRange != 0
     ? 100 * (close - lowestStochLow) / stochRange
     : 50

stochK = ta.sma(rawK, stochSmoothK)
stochD = ta.sma(stochK, stochSmoothD)

averageVolume = ta.sma(volume, volumeLength)

relativeVolume =
     averageVolume > 0
     ? volume / averageVolume
     : 0

atr = ta.atr(atrLength)

//=====================================================================
// 10. CONTEXTO DIARIO
//=====================================================================

dailyClose = request.security(
     syminfo.tickerid,
     "D",
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

dailyEma20 = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, 20),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

dailyEma50 = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, 50),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

dailyTrendBullish =
     dailyClose > dailyEma20 and
     dailyEma20 > dailyEma50

dailyTrendRecovering =
     dailyClose > dailyEma20 or
     dailyEma20 > dailyEma20[1]

dailyTrendWeak =
     dailyClose < dailyEma20 and
     dailyEma20 < dailyEma50

//=====================================================================
// 11. ACCIÓN DEL PRECIO
//=====================================================================

candleRange = high - low
bodySize = math.abs(close - open)

lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

closePosition =
     candleRange > 0
     ? (close - low) / candleRange
     : 0.5

bullishCandle = close > open

longLowerWick =
     candleRange > 0 and
     lowerWick >= bodySize * 1.5 and
     closePosition >= 0.55

hammer =
     bullishCandle and
     longLowerWick and
     upperWick <= candleRange * 0.25

bullishEngulfing =
     close > open and
     close[1] < open[1] and
     open <= close[1] and
     close >= open[1]

outsideBullish =
     high > high[1] and
     low < low[1] and
     close > open and
     closePosition >= 0.65

strongBullishClose =
     bullishCandle and
     closePosition >= 0.75

//=====================================================================
// 12. SCORE RSI — 40 PUNTOS
//=====================================================================

float rsiZoneScore =
     rsi >= 26 and rsi <= 31 ? 20 :
     rsi > 31 and rsi <= 35 ? 17 :
     rsi > 35 and rsi <= 40 ? 11 :
     rsi < 26 ? 10 :
     0

float rsiSlopeScore =
     rsiSlope > 2 ? 8 :
     rsiSlope > 0 ? 5 :
     0

float rsiRecoveryScore =
     ta.crossover(rsi, rsiOversold) ? 7 :
     rsi > rsi[1] and rsi[1] <= rsiOversold ? 5 :
     0

float rsiAccelerationScore =
     rsiThreeBarChange >= 5 ? 5 :
     rsiThreeBarChange > 0 ? 3 :
     0

rsiScore = math.min(
     rsiZoneScore +
     rsiSlopeScore +
     rsiRecoveryScore +
     rsiAccelerationScore,
     40
)

//=====================================================================
// 13. MACD ANTICIPADO — 15 PUNTOS
//=====================================================================

histImproving =
     macdHistogram > macdHistogram[1]

histImprovingTwice =
     macdHistogram > macdHistogram[1] and
     macdHistogram[1] > macdHistogram[2]

macdDistance =
     math.abs(macdLine - macdSignalLine)

macdDistanceShrinking =
     macdDistance < macdDistance[1]

macdLineTurning =
     macdLine > macdLine[1]

macdBullCross =
     ta.crossover(macdLine, macdSignalLine)

float macdScore =
     (histImproving ? 4 : 0) +
     (histImprovingTwice ? 3 : 0) +
     (macdDistanceShrinking ? 3 : 0) +
     (macdLineTurning ? 2 : 0) +
     (macdBullCross ? 3 : 0)

macdScore := math.min(macdScore, 15)

//=====================================================================
// 14. ESTOCÁSTICO — 15 PUNTOS
//=====================================================================

stochOversold = stochK <= 20
stochLow = stochK <= 30
stochTurning = stochK > stochK[1]
stochBullCross = ta.crossover(stochK, stochD)
stochBullish = stochK > stochD

float stochScore =
     (stochOversold ? 6 : stochLow ? 3 : 0) +
     (stochTurning ? 4 : 0) +
     (stochBullish ? 2 : 0) +
     (stochBullCross ? 3 : 0)

stochScore := math.min(stochScore, 15)

//=====================================================================
// 15. ACCIÓN DEL PRECIO — 20 PUNTOS
//=====================================================================

float candleScore =
     (longLowerWick ? 5 : 0) +
     (hammer ? 5 : 0) +
     (bullishEngulfing ? 7 : 0) +
     (outsideBullish ? 5 : 0) +
     (strongBullishClose ? 3 : 0)

candleScore := math.min(candleScore, 20)

//=====================================================================
// 16. EMA — 10 PUNTOS
//=====================================================================

distanceEma20 =
     math.abs(close - ema20) / ema20 * 100

distanceEma50 =
     math.abs(close - ema50) / ema50 * 100

distanceEma200 =
     math.abs(close - ema200) / ema200 * 100

nearEma20 = distanceEma20 <= 2
nearEma50 = distanceEma50 <= 3
nearEma200 = distanceEma200 <= 4

recoveringEma9 = ta.crossover(close, ema9)
recoveringEma20 = ta.crossover(close, ema20)

float emaScore =
     (nearEma20 ? 2 : 0) +
     (nearEma50 ? 3 : 0) +
     (nearEma200 ? 3 : 0) +
     (recoveringEma9 ? 1 : 0) +
     (recoveringEma20 ? 1 : 0)

emaScore := math.min(emaScore, 10)

//=====================================================================
// 17. VOLUMEN Y CONTEXTO
//=====================================================================

float volumeBonus =
     relativeVolume >= 1.50 ? 5 :
     relativeVolume >= 1.10 ? 3 :
     0

float dailyContextScore =
     not useDailyContext ? 0 :
     dailyTrendBullish ? 6 :
     dailyTrendRecovering ? 3 :
     dailyTrendWeak ? -4 :
     0

//=====================================================================
// 18. PENALIZACIONES
//=====================================================================

rsiStillFalling =
     rsi < rsi[1] and
     rsi[1] < rsi[2]

macdWorsening =
     macdHistogram < macdHistogram[1] and
     macdHistogram[1] < macdHistogram[2]

stochWorsening =
     stochK < stochK[1] and
     stochK < stochD

weakClose =
     closePosition <= 0.25

largeBearishCandle =
     close < open and
     bodySize >= atr * 1.20

previousTenBarLow = ta.lowest(low, 10)[1]

supportBreak =
     close < previousTenBarLow

fallingKnife =
     rsi < 32 and
     rsiStillFalling and
     macdWorsening and
     stochWorsening

float penalties =
     (rsiStillFalling ? 8 : 0) +
     (macdWorsening ? 7 : 0) +
     (stochWorsening ? 5 : 0) +
     (weakClose ? 5 : 0) +
     (largeBearishCandle ? 8 : 0) +
     (supportBreak ? 10 : 0)

penalties := math.min(penalties, 30)

//=====================================================================
// 19. SCORE FINAL
//=====================================================================

rawScore =
     rsiScore +
     macdScore +
     stochScore +
     candleScore +
     emaScore +
     volumeBonus +
     dailyContextScore -
     penalties

ramaScore =
     math.max(0, math.min(rawScore, 100))

familyCount =
     (rsiScore >= 20 ? 1 : 0) +
     (macdScore >= 7 ? 1 : 0) +
     (stochScore >= 7 ? 1 : 0) +
     (candleScore >= 5 ? 1 : 0) +
     (emaScore >= 3 ? 1 : 0)

rsiGate =
     rsi <= rsiOpportunityMax

confirmed =
     not onlyConfirmedBars or
     barstate.isconfirmed

//=====================================================================
// 20. CONDICIONES DE SEÑAL
//=====================================================================

preparationCondition =
     confirmed and
     rsiGate and
     ramaScore >= preparationThreshold and
     ramaScore < buyThreshold and
     familyCount >= 2 and
     not fallingKnife

buyCondition =
     confirmed and
     rsiGate and
     ramaScore >= buyThreshold and
     ramaScore < strongBuyThreshold and
     familyCount >= 3 and
     not fallingKnife

strongBuyCondition =
     confirmed and
     rsiGate and
     ramaScore >= strongBuyThreshold and
     familyCount >= 4 and
     not fallingKnife

preparationStarted =
     preparationCondition and
     not preparationCondition[1]

buyStarted =
     buyCondition and
     not buyCondition[1]

strongBuyStarted =
     strongBuyCondition and
     not strongBuyCondition[1]

invalidationStarted =
     confirmed and
     fallingKnife and
     not fallingKnife[1]

//=====================================================================
// 21. ENFRIAMIENTO
//=====================================================================

var int lastSignalBar = na

cooldownComplete =
     na(lastSignalBar) or
     bar_index - lastSignalBar >= signalCooldown

newStrongBuy =
     strongBuyStarted and
     cooldownComplete

newBuy =
     buyStarted and
     cooldownComplete and
     not newStrongBuy

newPreparation =
     preparationStarted and
     cooldownComplete and
     not newBuy and
     not newStrongBuy

newInvalidation =
     invalidationStarted and
     cooldownComplete

if newPreparation or newBuy or newStrongBuy or newInvalidation
    lastSignalBar := bar_index

newTradeSignal =
     newBuy or newStrongBuy

//=====================================================================
// 22. CÁLCULO DEL PLAN EN LA VELA DE SEÑAL
//=====================================================================

breakoutEntryNow =
     high + atr * breakoutAtrBuffer

retracementEntryNow =
     low + candleRange * retracementPercent / 100

signalCloseEntryNow =
     close

selectedEntryNow =
     entryMode == "Ruptura" ? breakoutEntryNow :
     entryMode == "Retroceso" ? retracementEntryNow :
     signalCloseEntryNow

structureLowNow =
     ta.lowest(low, stopLookback)

stopNow =
     structureLowNow - atr * stopAtrBuffer

riskPerShareNow =
     selectedEntryNow - stopNow

riskPercentNow =
     selectedEntryNow > 0 and riskPerShareNow > 0
     ? riskPerShareNow / selectedEntryNow * 100
     : na

target1Now =
     selectedEntryNow + riskPerShareNow * target1R

target2Now =
     selectedEntryNow + riskPerShareNow * target2R

target3Now =
     selectedEntryNow + riskPerShareNow * target3R

resistanceNow =
     ta.highest(high, resistanceLookback)[1]

roomToResistanceRNow =
     riskPerShareNow > 0
     ? (resistanceNow - selectedEntryNow) / riskPerShareNow
     : na

invalidRiskStructureNow =
     riskPerShareNow <= 0

excessiveRiskNow =
     not na(riskPercentNow) and
     riskPercentNow > maximumStopPercent

resistanceTooCloseNow =
     useResistanceBlock and
     not na(roomToResistanceRNow) and
     roomToResistanceRNow < minimumRoomR

tradeBlockedNow =
     invalidRiskStructureNow or
     excessiveRiskNow or
     resistanceTooCloseNow or
     manualBlock

//=====================================================================
// 23. VARIABLES PERSISTENTES DEL ÚLTIMO PLAN
//=====================================================================

var float planEntry = na
var float planRetracement = na
var float planStop = na
var float planTarget1 = na
var float planTarget2 = na
var float planTarget3 = na
var float planResistance = na
var float planRiskPercent = na
var float planRoomR = na
var float planScore = na

var bool planBlocked = false
var bool planWasStrong = false
var int planSignalBar = na

if newTradeSignal
    planEntry := selectedEntryNow
    planRetracement := retracementEntryNow
    planStop := stopNow
    planTarget1 := target1Now
    planTarget2 := target2Now
    planTarget3 := target3Now
    planResistance := resistanceNow
    planRiskPercent := riskPercentNow
    planRoomR := roomToResistanceRNow
    planScore := ramaScore

    planBlocked := tradeBlockedNow
    planWasStrong := newStrongBuy
    planSignalBar := bar_index

//=====================================================================
// 24. TAMAÑO DE POSICIÓN
//=====================================================================

allowedRiskMxn =
     accountCapitalMxn * riskPerTradePercent / 100

allowedRiskUsd =
     allowedRiskMxn / usdMxnExchangeRate

maximumPositionMxn =
     accountCapitalMxn * maximumPositionPercent / 100

maximumPositionUsd =
     maximumPositionMxn / usdMxnExchangeRate

planRiskPerShare =
     not na(planEntry) and not na(planStop)
     ? planEntry - planStop
     : na

sharesByRisk =
     not na(planRiskPerShare) and planRiskPerShare > 0
     ? allowedRiskUsd / planRiskPerShare
     : na

sharesByCapital =
     not na(planEntry) and planEntry > 0
     ? maximumPositionUsd / planEntry
     : na

rawSuggestedShares =
     not na(sharesByRisk) and not na(sharesByCapital)
     ? math.min(sharesByRisk, sharesByCapital)
     : na

suggestedShares =
     allowFractionalShares
     ? rawSuggestedShares
     : math.floor(rawSuggestedShares)

suggestedPositionUsd =
     not na(suggestedShares) and not na(planEntry)
     ? suggestedShares * planEntry
     : na

suggestedPositionMxn =
     not na(suggestedPositionUsd)
     ? suggestedPositionUsd * usdMxnExchangeRate
     : na

//=====================================================================
// 25. ESTADO DEL PLAN
//=====================================================================

entryActivated =
     not na(planEntry) and
     high >= planEntry and
     bar_index >= planSignalBar

stopTouched =
     not na(planStop) and
     low <= planStop and
     bar_index > planSignalBar

target1Touched =
     not na(planTarget1) and
     high >= planTarget1 and
     bar_index > planSignalBar

target2Touched =
     not na(planTarget2) and
     high >= planTarget2 and
     bar_index > planSignalBar

target3Touched =
     not na(planTarget3) and
     high >= planTarget3 and
     bar_index > planSignalBar

string planStatus =
     na(planEntry) ? "SIN PLAN" :
     planBlocked ? "NO OPERAR" :
     target3Touched ? "OBJETIVO 3" :
     target2Touched ? "OBJETIVO 2" :
     target1Touched ? "OBJETIVO 1" :
     stopTouched ? "STOP TOCADO" :
     entryActivated ? "ACTIVA" :
     "PENDIENTE"

//=====================================================================
// 26. RAZÓN DEL BLOQUEO
//=====================================================================

string blockReason =
     manualBlock ? "EVENTO MANUAL" :
     invalidRiskStructureNow ? "STOP INVÁLIDO" :
     excessiveRiskNow ? "RIESGO EXCESIVO" :
     resistanceTooCloseNow ? "RESISTENCIA CERCANA" :
     "NINGUNO"

// Mantener una explicación asociada al plan almacenado.
var string storedBlockReason = "NINGUNO"

if newTradeSignal
    storedBlockReason :=
         manualBlock ? "EVENTO MANUAL" :
         invalidRiskStructureNow ? "STOP INVÁLIDO" :
         excessiveRiskNow ? "RIESGO EXCESIVO" :
         resistanceTooCloseNow ? "RESISTENCIA CERCANA" :
         "NINGUNO"

//=====================================================================
// 27. MEDIAS EN LA GRÁFICA
//=====================================================================

plot(
     showEmas ? ema9 : na,
     title = "EMA 9",
     color = color.aqua,
     linewidth = 1
)

plot(
     showEmas ? ema20 : na,
     title = "EMA 20",
     color = color.blue,
     linewidth = 1
)

plot(
     showEmas ? ema50 : na,
     title = "EMA 50",
     color = color.orange,
     linewidth = 2
)

plot(
     showEmas ? ema200 : na,
     title = "EMA 200",
     color = color.purple,
     linewidth = 2
)

//=====================================================================
// 28. SEÑALES
//=====================================================================

plotshape(
     showPreparation and newPreparation,
     title = "Preparación RAMA",
     style = shape.labelup,
     location = location.belowbar,
     text = "P",
     color = color.rgb(230, 170, 30),
     textcolor = color.black,
     size = size.tiny
)

plotshape(
     newBuy,
     title = "Compra RAMA",
     style = shape.labelup,
     location = location.belowbar,
     text = "C",
     color = color.rgb(20, 175, 95),
     textcolor = color.white,
     size = size.small
)

plotshape(
     newStrongBuy,
     title = "Compra fuerte RAMA",
     style = shape.labelup,
     location = location.belowbar,
     text = "C+",
     color = color.rgb(0, 125, 70),
     textcolor = color.white,
     size = size.normal
)

plotshape(
     showInvalidation and newInvalidation,
     title = "Riesgo RAMA",
     style = shape.labeldown,
     location = location.abovebar,
     text = "X",
     color = color.rgb(210, 55, 55),
     textcolor = color.white,
     size = size.tiny
)

//=====================================================================
// 29. LÍNEAS DEL TRADE PLANNER
//=====================================================================

var line entryLine = na
var line stopLine = na
var line target1Line = na
var line target2Line = na
var line target3Line = na
var line resistanceLine = na

if newTradeSignal
    if not na(entryLine)
        line.delete(entryLine)

    if not na(stopLine)
        line.delete(stopLine)

    if not na(target1Line)
        line.delete(target1Line)

    if not na(target2Line)
        line.delete(target2Line)

    if not na(target3Line)
        line.delete(target3Line)

    if not na(resistanceLine)
        line.delete(resistanceLine)

    if showTradeLines
        entryLine := line.new(
             bar_index,
             planEntry,
             bar_index + 1,
             planEntry,
             extend = extend.right,
             color = color.blue,
             width = 2
        )

        stopLine := line.new(
             bar_index,
             planStop,
             bar_index + 1,
             planStop,
             extend = extend.right,
             color = color.red,
             width = 2
        )

        target1Line := line.new(
             bar_index,
             planTarget1,
             bar_index + 1,
             planTarget1,
             extend = extend.right,
             color = color.green,
             width = 1
        )

        target2Line := line.new(
             bar_index,
             planTarget2,
             bar_index + 1,
             planTarget2,
             extend = extend.right,
             color = color.green,
             width = 2
        )

        target3Line := line.new(
             bar_index,
             planTarget3,
             bar_index + 1,
             planTarget3,
             extend = extend.right,
             color = color.new(color.green, 35),
             width = 2,
             style = line.style_dashed
        )

        resistanceLine := line.new(
             bar_index,
             planResistance,
             bar_index + 1,
             planResistance,
             extend = extend.right,
             color = color.gray,
             width = 1,
             style = line.style_dotted
        )

//=====================================================================
// 30. TEXTOS DEL PANEL
//=====================================================================

color darkBlue = color.rgb(10, 30, 55)
color green = color.rgb(20, 175, 95)
color yellow = color.rgb(230, 170, 30)
color red = color.rgb(210, 55, 55)
color gray = color.rgb(120, 130, 145)

string setupState =
     strongBuyCondition ? "ZONA C+" :
     buyCondition ? "ZONA C" :
     preparationCondition ? "PREPARACIÓN" :
     fallingKnife ? "RIESGO" :
     "SIN SEÑAL"

color setupColor =
     strongBuyCondition ? green :
     buyCondition ? green :
     preparationCondition ? yellow :
     fallingKnife ? red :
     gray

string dailyContextText =
     dailyTrendBullish ? "ALCISTA" :
     dailyTrendRecovering ? "RECUPERANDO" :
     dailyTrendWeak ? "BAJISTA" :
     "NEUTRAL"

string signalQuality =
     na(planScore) ? "—" :
     planScore >= 90 ? "EXCEPCIONAL" :
     planScore >= 80 ? "MUY ALTA" :
     planScore >= 70 ? "ALTA" :
     planScore >= 65 ? "MODERADA" :
     "BAJA"

string stars =
     na(planScore) ? "—" :
     planScore >= 90 ? "★★★★★" :
     planScore >= 80 ? "★★★★☆" :
     planScore >= 70 ? "★★★☆☆" :
     planScore >= 65 ? "★★☆☆☆" :
     "★☆☆☆☆"

color planStatusColor =
     planStatus == "NO OPERAR" ? red :
     planStatus == "STOP TOCADO" ? red :
     planStatus == "OBJETIVO 3" ? green :
     planStatus == "OBJETIVO 2" ? green :
     planStatus == "OBJETIVO 1" ? green :
     planStatus == "ACTIVA" ? green :
     planStatus == "PENDIENTE" ? yellow :
     gray

//=====================================================================
// 31. PANEL PRINCIPAL
//=====================================================================

var table panel = table.new(
     position.top_right,
     2,
     22,
     frame_color = darkBlue,
     border_color = color.new(darkBlue, 35),
     border_width = 1
)

if barstate.islast and showPanel
    table.cell(
         panel, 0, 0,
         "RAMA RRE v2",
         bgcolor = darkBlue,
         text_color = color.white
    )

    table.cell(
         panel, 1, 0,
         syminfo.ticker,
         bgcolor = darkBlue,
         text_color = color.white
    )

    table.cell(panel, 0, 1, "Temporalidad")
    table.cell(panel, 1, 1, timeframe.period)

    table.cell(panel, 0, 2, "Score actual")
    table.cell(
         panel, 1, 2,
         str.tostring(ramaScore, "#") + "/100",
         text_color = setupColor
    )

    table.cell(panel, 0, 3, "Setup")
    table.cell(
         panel, 1, 3,
         setupState,
         bgcolor = setupColor,
         text_color = color.white
    )

    table.cell(panel, 0, 4, "RSI")
    table.cell(
         panel, 1, 4,
         str.tostring(rsi, "#.##")
    )

    table.cell(panel, 0, 5, "Confirmaciones")
    table.cell(
         panel, 1, 5,
         str.tostring(familyCount) + "/5"
    )

    table.cell(panel, 0, 6, "Contexto diario")
    table.cell(
         panel, 1, 6,
         dailyContextText
    )

    table.cell(
         panel, 0, 7,
         "TRADE PLANNER",
         bgcolor = darkBlue,
         text_color = color.white
    )

    table.cell(
         panel, 1, 7,
         planWasStrong ? "C+" : "C",
         bgcolor = darkBlue,
         text_color = color.white
    )

    table.cell(panel, 0, 8, "Estado del plan")
    table.cell(
         panel, 1, 8,
         planStatus,
         bgcolor = planStatusColor,
         text_color = color.white
    )

    table.cell(panel, 0, 9, "Calidad")
    table.cell(
         panel, 1, 9,
         signalQuality
    )

    table.cell(panel, 0, 10, "Valoración")
    table.cell(
         panel, 1, 10,
         stars
    )

    table.cell(panel, 0, 11, "Entrada")
    table.cell(
         panel, 1, 11,
         na(planEntry) ? "—" :
         str.tostring(planEntry, format.mintick)
    )

    table.cell(panel, 0, 12, "Entrada retroceso")
    table.cell(
         panel, 1, 12,
         na(planRetracement) ? "—" :
         str.tostring(planRetracement, format.mintick)
    )

    table.cell(panel, 0, 13, "Stop")
    table.cell(
         panel, 1, 13,
         na(planStop) ? "—" :
         str.tostring(planStop, format.mintick),
         text_color = red
    )

    table.cell(panel, 0, 14, "Riesgo")
    table.cell(
         panel, 1, 14,
         na(planRiskPercent) ? "—" :
         str.tostring(planRiskPercent, "#.##") + "%"
    )

    table.cell(panel, 0, 15, "Objetivo 1")
    table.cell(
         panel, 1, 15,
         na(planTarget1) ? "—" :
         str.tostring(planTarget1, format.mintick),
         text_color = green
    )

    table.cell(panel, 0, 16, "Objetivo 2")
    table.cell(
         panel, 1, 16,
         na(planTarget2) ? "—" :
         str.tostring(planTarget2, format.mintick),
         text_color = green
    )

    table.cell(panel, 0, 17, "Objetivo 3")
    table.cell(
         panel, 1, 17,
         na(planTarget3) ? "—" :
         str.tostring(planTarget3, format.mintick),
         text_color = green
    )

    table.cell(panel, 0, 18, "Resistencia")
    table.cell(
         panel, 1, 18,
         na(planResistance) ? "—" :
         str.tostring(planResistance, format.mintick)
    )

    table.cell(panel, 0, 19, "Espacio hasta resist.")
    table.cell(
         panel, 1, 19,
         na(planRoomR) ? "—" :
         str.tostring(planRoomR, "#.##") + "R"
    )

    table.cell(panel, 0, 20, "Posición sugerida")
    table.cell(
         panel, 1, 20,
         na(suggestedShares) ? "—" :
         str.tostring(suggestedShares, "#.##") + " acc."
    )

    table.cell(panel, 0, 21, "Monto aproximado")
    table.cell(
         panel, 1, 21,
         na(suggestedPositionMxn) ? "—" :
         "$" + str.tostring(suggestedPositionMxn, "#") + " MXN"
    )

//=====================================================================
// 32. ETIQUETA DE BLOQUEO
//=====================================================================

if newTradeSignal and tradeBlockedNow
    label.new(
         bar_index,
         high + atr,
         "NO OPERAR\n" + blockReason,
         style = label.style_label_down,
         color = red,
         textcolor = color.white,
         size = size.small
    )

//=====================================================================
// 33. ALERTAS
//=====================================================================

alertcondition(
     newPreparation,
     title = "RAMA Preparación",
     message = "Preparación RAMA en {{exchange}}:{{ticker}}"
)

alertcondition(
     newBuy,
     title = "RAMA C",
     message = "Zona C RAMA detectada en {{exchange}}:{{ticker}}"
)

alertcondition(
     newStrongBuy,
     title = "RAMA C+",
     message = "Zona C+ RAMA detectada en {{exchange}}:{{ticker}}"
)

alertcondition(
     newTradeSignal and not tradeBlockedNow,
     title = "RAMA Plan operable",
     message = "Plan operable RAMA en {{exchange}}:{{ticker}}"
)

alertcondition(
     newTradeSignal and tradeBlockedNow,
     title = "RAMA operación bloqueada",
     message = "Setup RAMA bloqueado en {{exchange}}:{{ticker}}"
)

alertcondition(
     newInvalidation,
     title = "RAMA Riesgo",
     message = "Riesgo RAMA detectado en {{exchange}}:{{ticker}}"
)

//=====================================================================
// 34. DATOS OCULTOS PARA PINE SCREENER
//=====================================================================

plot(
     ramaScore,
     "RRE Score",
     display = display.none
)

plot(
     rsi,
     "RRE RSI",
     display = display.none
)

plot(
     familyCount,
     "RRE Confirmaciones",
     display = display.none
)

plot(
     planEntry,
     "RRE Entrada",
     display = display.none
)

plot(
     planStop,
     "RRE Stop",
     display = display.none
)

plot(
     planTarget2,
     "RRE Objetivo 2",
     display = display.none
)

float numericState =
     strongBuyCondition ? 4 :
     buyCondition ? 3 :
     preparationCondition ? 2 :
     fallingKnife ? 1 :
     0

plot(
     numericState,
     "RRE Estado",
     display = display.none
)
````
