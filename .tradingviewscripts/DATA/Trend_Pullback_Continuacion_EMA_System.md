<!-- tradingview-pine-id: PUB;f237b664e2374fffbd7632b0158dbd49 -->
<!-- tradingviewscripts-format: 1 -->
# Trend + Pullback + Continuación (EMA System)

Source: https://www.tradingview.com/script/CLvCY5Rp/

## Description

esta gratis pruevenlo y optimizanlo y compartab conmigo gracias

---

## Source Code

````pine
//@version=6
// =====================================================================================
// ESTRATEGIA: TREND FOLLOWING CON PULLBACK A MEDIA MOVIL + PRE-ALERTAS + PANEL VISUAL
// Autor: Generado con Claude - Basado en concepto EMA10/20/89/200
// Automatización ajustada para PickMyTrade (Tradovate) - esquema JSON oficial
// =====================================================================================
strategy("Trend + Pullback + Continuación (EMA System)", shorttitle="TP-EMA Strategy",
     overlay=true, pyramiding=5, default_qty_type=strategy.fixed, default_qty_value=1,
     calc_on_every_tick=false, process_orders_on_close=true, max_bars_back=500)

// =====================================================================================
// 1. INPUTS - SISTEMA DE CONTEXTO DE MERCADO (EMAs)
// =====================================================================================
g_ema = "Configuración de Medias Móviles"
maTypeInput = input.string("EMA", "Tipo de Media Móvil", options=["EMA", "SMA", "WMA"], group=g_ema)
fastLen     = input.int(10,  "Período Media Rápida",  minval=1, group=g_ema)
mediumLen   = input.int(20,  "Período Media Media",   minval=1, group=g_ema)
triggerLen  = input.int(89,  "Período Media Gatillo (Pullback)", minval=1, group=g_ema)
trendLen    = input.int(200, "Período Media de Tendencia", minval=1, group=g_ema)

g_pb = "Configuración de Pullback"
pullbackWindow = input.int(15, "Ventana máxima de Pullback (velas)", minval=1, group=g_pb)
maxDistance    = input.float(10.0, "Distancia máx. precio-EMA gatillo (puntos)", minval=0.01, step=0.5, group=g_pb)
confirmType    = input.string("Cierre", "Tipo de confirmación de vela", options=["Cierre", "Envolvente"], group=g_pb)

g_eq = "Filtros de Calidad de Entrada (Mejoras v3)"
useATRZone          = input.bool(false, "Usar Distancia Dinámica (ATR) en vez de puntos fijos", group=g_eq, tooltip="Si se activa, el ancho de la zona de pullback se calcula como ATR x Multiplicador en lugar de la 'Distancia máx. precio-EMA gatillo' fija. Recomendado para Forex/CFD u operar en varios instrumentos/timeframes, donde una distancia fija en puntos no es comparable.")
atrLenEntry         = input.int(14, "Período ATR (zona dinámica)", minval=1, group=g_eq)
atrZoneMult         = input.float(1.0, "Multiplicador ATR (ancho zona)", minval=0.1, step=0.1, group=g_eq)
requireZoneBreakout = input.bool(false, "Exigir ruptura de zona en la confirmación", group=g_eq, tooltip="Si se activa, la vela de confirmación debe cerrar FUERA de la zona de pullback (no solo cruzar la EMA gatillo). Señal más fuerte pero más tardía.")
minBiasBars         = input.int(0, "Barras mínimas de sesgo estable antes de operar", minval=0, group=g_eq, tooltip="Evita operar justo cuando el sesgo (tendencia+momentum) acaba de cambiar. 0 = desactivado (comportamiento original).")
cooldownBarsAfterSignal = input.int(0, "Barras de enfriamiento tras una señal confirmada", minval=0, group=g_eq, tooltip="Bloquea nuevas señales durante N barras después de una entrada confirmada, incluso si el precio vuelve a la zona. 0 = desactivado (comportamiento original).")

g_pre = "Sistema de Pre-Alerta"
enablePreAlert = input.bool(true, "Activar Pre-Alertas", group=g_pre)
preAlertBars   = input.int(3, "Velas de anticipación para pre-aviso", minval=1, group=g_pre)
approachMult   = input.float(2.0, "Multiplicador zona de aproximación", minval=1.0, step=0.1, group=g_pre, tooltip="Distancia (x veces la distancia máxima) desde la cual se muestra un aviso temprano de 'aproximación' antes de que el precio entre a la zona de pullback")

g_risk = "Gestión de Riesgo"
riskPerTrade  = input.float(200.0, "Riesgo por operación ($)", minval=1, group=g_risk)
rrRatio       = input.float(1.5, "Relación Riesgo:Beneficio (R)", minval=0.1, step=0.1, group=g_risk)
slBufferTicks = input.int(1, "Buffer SL (ticks)", minval=0, group=g_risk)
useBE         = input.bool(false, "Activar Break Even", group=g_risk)
beTriggerR    = input.float(1.0, "Break Even al alcanzar (R)", minval=0.1, step=0.1, group=g_risk)
useTrailing   = input.bool(false, "Activar Trailing Stop", group=g_risk)
trailPoints   = input.float(20.0, "Trailing Stop - activación (puntos de ganancia)", minval=0.1, group=g_risk)
trailOffset   = input.float(5.0,  "Trailing Stop - distancia del máximo (puntos)", minval=0.0, group=g_risk)
maxTrades     = input.int(1, "Máximo de operaciones simultáneas", minval=1, group=g_risk)

g_filt = "Filtros y Sesiones"
enableBuy   = input.bool(true, "Activar Compras", group=g_filt)
enableSell  = input.bool(true, "Activar Ventas", group=g_filt)
useSession1 = input.bool(true, "Activar Sesión Mañana NY (Londres/Apertura NY)", group=g_filt)
session1    = input.session("0400-1700", "Horario Sesión Mañana", group=g_filt)
useSession2 = input.bool(true, "Activar Sesión Noche NY (Asia/Continuación)", group=g_filt)
session2    = input.session("1800-0200", "Horario Sesión Noche", group=g_filt)

g_vis = "Visualización"
showDashboard     = input.bool(true, "Mostrar Panel Visual", group=g_vis)
showEMAs          = input.bool(true, "Mostrar EMAs", group=g_vis)
showPullbackZone  = input.bool(true, "Mostrar Zona de Pullback", group=g_vis)
showSLTP          = input.bool(true, "Mostrar líneas SL/TP", group=g_vis)

// --- NUEVO: bloque de automatización dedicado a PickMyTrade ---
g_pmt = "Automatización (PickMyTrade → Tradovate)"
enableAutoAlerts    = input.bool(true, "Activar Alertas de Automatización", group=g_pmt, tooltip="Envía alert() en formato JSON del generador de PickMyTrade")
pmtToken            = input.string("TU_TOKEN_AQUI", "Token de PickMyTrade", group=g_pmt, tooltip="Cópialo desde 'Generate Alert' en el dashboard de PickMyTrade. NO lo compartas.")
pmtAccountId         = input.string("", "Account ID de Tradovate (vacío = cuenta por defecto)", group=g_pmt)
symbolOverride      = input.string("", "Símbolo para PickMyTrade (vacío = usar el del gráfico)", group=g_pmt, tooltip="Ej: NQ, ES, MNQ. PickMyTrade mapea el símbolo base a tu contrato de Tradovate vigente (revisa 'Contract Rollover Rule' en su documentación).")
pmtOrderType        = input.string("MKT", "Tipo de orden", options=["MKT", "LMT"], group=g_pmt)
pmtReverseOrderClose = input.bool(true, "reverse_order_close", group=g_pmt, tooltip="Si se activa, cierra cualquier posición opuesta abierta antes de ejecutar la nueva señal. Recomendado cuando 'Máximo de operaciones simultáneas' = 1.")
pmtPyramidAlert     = input.bool(false, "pyramid", group=g_pmt, tooltip="Si se activa, una nueva señal del mismo lado NO cierra la posición existente (permite apilar). Debe ser coherente con 'Máximo de operaciones simultáneas'.")
sendExitAlert       = input.bool(true, "Enviar alerta de cierre de posición (flat)", group=g_pmt, tooltip="Se dispara cuando la posición simulada por la estrategia pasa a 0 (SL, TP, BE o trailing)")
pmtSendStopUpdates  = input.bool(true, "Enviar actualizaciones de SL (Break Even / Trailing) al bridge", group=g_pmt, tooltip="Envía alertas update_sl:true con el nuevo precio de stop cada vez que el Break Even o el Trailing calculado en Pine mejora el stop. Necesario porque strategy.exit() con trail_points/trail_offset NO se propaga a Tradovate; PickMyTrade solo puede actuar sobre lo que llega por alert().")

// =====================================================================================
// 2. CÁLCULO DE MEDIAS MÓVILES (según tipo seleccionado)
// =====================================================================================
f_ma(src, len, string maType) =>
    smaVal = ta.sma(src, len)
    emaVal = ta.ema(src, len)
    wmaVal = ta.wma(src, len)
    float result = switch maType
        "SMA" => smaVal
        "WMA" => wmaVal
        => emaVal
    result

emaFast    = f_ma(close, fastLen, maTypeInput)
emaMedium  = f_ma(close, mediumLen, maTypeInput)
emaTrigger = f_ma(close, triggerLen, maTypeInput)
emaTrend   = f_ma(close, trendLen, maTypeInput)

plot(showEMAs ? emaFast    : na, "EMA Rápida",  color=color.new(color.aqua, 0), linewidth=1)
plot(showEMAs ? emaMedium  : na, "EMA Media",   color=color.new(color.orange, 0), linewidth=1)
plot(showEMAs ? emaTrigger : na, "EMA Gatillo", color=color.new(color.yellow, 0), linewidth=2)
plot(showEMAs ? emaTrend   : na, "EMA Tendencia", color=color.new(color.fuchsia, 0), linewidth=2)

// =====================================================================================
// 3. FILTRO DE TENDENCIA Y MOMENTUM
// =====================================================================================
trendUp   = close > emaTrend
trendDown = close < emaTrend
trendState = trendUp ? "ALCISTA" : trendDown ? "BAJISTA" : "NEUTRAL"

momentumUp   = emaFast > emaMedium
momentumDown = emaFast < emaMedium

bias = (trendUp and momentumUp) ? 1 : (trendDown and momentumDown) ? -1 : 0

// =====================================================================================
// 4. FILTRO DE SESIÓN
// =====================================================================================
inSess1 = useSession1 and not na(time(timeframe.period, session1))
inSess2 = useSession2 and not na(time(timeframe.period, session2))
inSession = (not useSession1 and not useSession2) ? true : (inSess1 or inSess2)

// =====================================================================================
// 5. MÁQUINA DE ESTADOS: DETECCIÓN DE PULLBACK
// stateCode: 0 = esperando, 1 = en zona de pullback, -1 = en cooldown post-entrada
// =====================================================================================
var int   stateCode  = 0
var int   barsInZone = 0
var float swingLow   = na
var float swingHigh  = na
var int   lastBias   = 0
var int   biasBarsCount = 0
var int   barsSinceLastSignal = 999999

// --- Distancia de zona: fija (puntos) o dinámica (ATR), según el toggle ---
atrEntry = ta.atr(atrLenEntry)
effectiveMaxDistance = useATRZone ? atrEntry * atrZoneMult : maxDistance

zoneUpper = emaTrigger + effectiveMaxDistance
zoneLower = emaTrigger - effectiveMaxDistance

distToTrigger  = math.abs(close - emaTrigger)
inZone         = distToTrigger <= effectiveMaxDistance
approachingZone = distToTrigger <= effectiveMaxDistance * approachMult and not inZone

// --- Estabilidad de sesgo: cuántas barras consecutivas lleva el mismo bias ---
biasBarsCount := bias == lastBias ? biasBarsCount + 1 : 1
biasStable = biasBarsCount >= math.max(1, minBiasBars)

// --- Cooldown tras la última señal confirmada (calculado con el valor de la barra anterior) ---
cooldownOk = barsSinceLastSignal >= cooldownBarsAfterSignal

if bias != lastBias
    stateCode  := 0
    barsInZone := 0
    swingLow   := na
    swingHigh  := na
lastBias := bias

// Confirmación de vela (rechazo / recuperación)
buyConfirm  = confirmType == "Cierre" ?
     (close > open and close > emaTrigger) :
     (close > open and close > high[1] and open <= close[1])

sellConfirm = confirmType == "Cierre" ?
     (close < open and close < emaTrigger) :
     (close < open and close < low[1] and open >= close[1])

// --- Ruptura de zona (opcional): la vela de confirmación debe cerrar fuera de la zona, no solo cruzar la EMA gatillo ---
buyBreakoutOk  = not requireZoneBreakout or close > zoneUpper
sellBreakoutOk = not requireZoneBreakout or close < zoneLower

buyConfirmedSignal  = false
sellConfirmedSignal = false
preBuySignal    = false   // precio ya está en la zona de pullback, sin confirmar
preSellSignal   = false
approachBuySignal  = false // precio se está acercando a la zona (aviso muy temprano)
approachSellSignal = false

if bias == 1 and enableBuy
    if stateCode == -1 and not inZone
        stateCode := 0
    if inZone and stateCode == 0 and biasStable
        stateCode  := 1
        barsInZone := 1
        swingLow   := low
    else if stateCode == 1
        barsInZone := barsInZone + 1
        swingLow   := math.min(swingLow, low)
        if barsInZone > pullbackWindow
            stateCode  := 0
            barsInZone := 0
            swingLow   := na
    if enablePreAlert and stateCode == 0 and approachingZone
        approachBuySignal := true
    if stateCode == 1 and enablePreAlert and barsInZone <= preAlertBars
        preBuySignal := true
    if stateCode == 1 and buyConfirm and buyBreakoutOk and cooldownOk and barsInZone <= pullbackWindow
        buyConfirmedSignal := true
        stateCode := -1

if bias == -1 and enableSell
    if stateCode == -1 and not inZone
        stateCode := 0
    if inZone and stateCode == 0 and biasStable
        stateCode  := 1
        barsInZone := 1
        swingHigh  := high
    else if stateCode == 1
        barsInZone := barsInZone + 1
        swingHigh  := math.max(swingHigh, high)
        if barsInZone > pullbackWindow
            stateCode  := 0
            barsInZone := 0
            swingHigh  := na
    if enablePreAlert and stateCode == 0 and approachingZone
        approachSellSignal := true
    if stateCode == 1 and enablePreAlert and barsInZone <= preAlertBars
        preSellSignal := true
    if stateCode == 1 and sellConfirm and sellBreakoutOk and cooldownOk and barsInZone <= pullbackWindow
        sellConfirmedSignal := true
        stateCode := -1

barsSinceLastSignal := (buyConfirmedSignal or sellConfirmedSignal) ? 0 : barsSinceLastSignal + 1

barsRemaining = stateCode == 1 ? math.max(0, pullbackWindow - barsInZone) : na

// =====================================================================================
// 6. PROBABILIDAD DE SEÑAL
// =====================================================================================
probScore = 0
if bias == 1
    probScore += 1
    probScore += momentumUp ? 1 : 0
    probScore += stateCode == 1 ? 1 : 0
    probScore += (stateCode == 1 and barsInZone <= math.round(pullbackWindow / 2)) ? 1 : 0
if bias == -1
    probScore += 1
    probScore += momentumDown ? 1 : 0
    probScore += stateCode == 1 ? 1 : 0
    probScore += (stateCode == 1 and barsInZone <= math.round(pullbackWindow / 2)) ? 1 : 0

probLabel = probScore >= 3 ? "ALTA" : probScore == 2 ? "MEDIA" : "BAJA"
probColor = probScore >= 3 ? color.new(color.green, 0) : probScore == 2 ? color.new(color.orange, 0) : color.new(color.red, 0)

// =====================================================================================
// 7. GESTIÓN DE POSICIÓN / RIESGO / ÓRDENES
// =====================================================================================
var float lastSLLong  = na
var float lastTPLong  = na
var float lastSLShort = na
var float lastTPShort = na
var string lastSignalTxt = "Ninguna"
var float lastQtyLong  = na
var float lastRiskLong = na
var float lastQtyShort  = na
var float lastRiskShort = na

canTrade = inSession and strategy.opentrades < maxTrades

if buyConfirmedSignal and canTrade and not na(swingLow)
    slPrice = swingLow - slBufferTicks * syminfo.mintick
    riskPts = close - slPrice
    if riskPts > 0
        tpPrice = close + riskPts * rrRatio
        qty = math.max(1, math.round(riskPerTrade / (riskPts * syminfo.pointvalue)))
        strategy.entry("Buy", strategy.long, qty=qty)
        lastSLLong := slPrice
        lastTPLong := tpPrice
        lastSignalTxt := "COMPRA @ " + str.tostring(close, format.mintick)
        lastQtyLong  := qty
        lastRiskLong := riskPts
        if not useTrailing
            strategy.exit("SL/TP Buy", "Buy", stop=slPrice, limit=tpPrice)
        else
            strategy.exit("SL/TP Buy", "Buy", stop=slPrice,
                 trail_points=trailPoints / syminfo.mintick, trail_offset=trailOffset / syminfo.mintick)

if sellConfirmedSignal and canTrade and not na(swingHigh)
    slPrice = swingHigh + slBufferTicks * syminfo.mintick
    riskPts = slPrice - close
    if riskPts > 0
        tpPrice = close - riskPts * rrRatio
        qty = math.max(1, math.round(riskPerTrade / (riskPts * syminfo.pointvalue)))
        strategy.entry("Sell", strategy.short, qty=qty)
        lastSLShort := slPrice
        lastTPShort := tpPrice
        lastSignalTxt := "VENTA @ " + str.tostring(close, format.mintick)
        lastQtyShort  := qty
        lastRiskShort := riskPts
        if not useTrailing
            strategy.exit("SL/TP Sell", "Sell", stop=slPrice, limit=tpPrice)
        else
            strategy.exit("SL/TP Sell", "Sell", stop=slPrice,
                 trail_points=trailPoints / syminfo.mintick, trail_offset=trailOffset / syminfo.mintick)

// Break Even (solo si el trailing está desactivado, para evitar conflicto de órdenes)
if useBE and not useTrailing and strategy.position_size != 0
    avgPrice = strategy.position_avg_price
    if strategy.position_size > 0 and not na(lastSLLong)
        riskPtsLong = avgPrice - lastSLLong
        if riskPtsLong > 0 and (close - avgPrice) >= riskPtsLong * beTriggerR
            strategy.exit("SL/TP Buy", "Buy", stop=avgPrice + slBufferTicks * syminfo.mintick, limit=lastTPLong)
    if strategy.position_size < 0 and not na(lastSLShort)
        riskPtsShort = lastSLShort - avgPrice
        if riskPtsShort > 0 and (avgPrice - close) >= riskPtsShort * beTriggerR
            strategy.exit("SL/TP Sell", "Sell", stop=avgPrice - slBufferTicks * syminfo.mintick, limit=lastTPShort)

// =====================================================================================
// 7b. TRACKING MANUAL DE STOP PARA EL BRIDGE (Break Even + Trailing → PickMyTrade)
// -------------------------------------------------------------------------------------
// strategy.exit(..., trail_points=..., trail_offset=...) solo mueve el stop DENTRO del
// backtester de TradingView; ese movimiento nunca llega a Tradovate. Por eso replicamos
// aquí, barra a barra, el mismo cálculo de BE/trailing y disparamos una alerta
// update_sl:true con el precio exacto cada vez que el stop mejora (nunca empeora).
// =====================================================================================
var float managedStopLong  = na
var float managedStopShort = na
var float runningExtremeLong  = na   // máximo alcanzado desde la entrada (para trailing long)
var float runningExtremeShort = na   // mínimo alcanzado desde la entrada (para trailing short)

if buyConfirmedSignal and canTrade and not na(lastSLLong)
    managedStopLong  := lastSLLong
    runningExtremeLong := high
    managedStopShort := na
    runningExtremeShort := na

if sellConfirmedSignal and canTrade and not na(lastSLShort)
    managedStopShort := lastSLShort
    runningExtremeShort := low
    managedStopLong  := na
    runningExtremeLong := na

sendStopUpdateLong  = false
sendStopUpdateShort = false
float newManagedStopLong  = na
float newManagedStopShort = na

if strategy.position_size > 0 and not na(managedStopLong)
    avgPriceL = strategy.position_avg_price
    runningExtremeLong := math.max(runningExtremeLong, high)
    candidateStop = managedStopLong
    if useBE
        riskPtsL = avgPriceL - lastSLLong
        if riskPtsL > 0 and (close - avgPriceL) >= riskPtsL * beTriggerR
            candidateStop := math.max(candidateStop, avgPriceL + slBufferTicks * syminfo.mintick)
    if useTrailing and (runningExtremeLong - avgPriceL) >= trailPoints
        candidateStop := math.max(candidateStop, runningExtremeLong - trailOffset)
    if candidateStop > managedStopLong
        newManagedStopLong := candidateStop
        sendStopUpdateLong := true
        managedStopLong := candidateStop

if strategy.position_size < 0 and not na(managedStopShort)
    avgPriceS = strategy.position_avg_price
    runningExtremeShort := math.min(runningExtremeShort, low)
    candidateStopS = managedStopShort
    if useBE
        riskPtsS = lastSLShort - avgPriceS
        if riskPtsS > 0 and (avgPriceS - close) >= riskPtsS * beTriggerR
            candidateStopS := math.min(candidateStopS, avgPriceS - slBufferTicks * syminfo.mintick)
    if useTrailing and (avgPriceS - runningExtremeShort) >= trailPoints
        candidateStopS := math.min(candidateStopS, runningExtremeShort + trailOffset)
    if candidateStopS < managedStopShort
        newManagedStopShort := candidateStopS
        sendStopUpdateShort := true
        managedStopShort := candidateStopS

if strategy.position_size == 0
    managedStopLong  := na
    managedStopShort := na
    runningExtremeLong := na
    runningExtremeShort := na

// =====================================================================================
// 8. VISUALIZACIÓN: ZONA DE PULLBACK, FLECHAS, ETIQUETAS, SL/TP
// =====================================================================================
pZU = plot(showPullbackZone ? zoneUpper : na, "Zona Pullback Sup.", color=color.new(color.gray, 80), display=display.none)
pZL = plot(showPullbackZone ? zoneLower : na, "Zona Pullback Inf.", color=color.new(color.gray, 80), display=display.none)
fill(pZU, pZL, color=showPullbackZone ? color.new(color.yellow, 88) : na, title="Zona Pullback")

plotshape(buyConfirmedSignal,  title="Entrada Compra", style=shape.triangleup,   location=location.belowbar, color=color.new(color.green, 0), size=size.small)
plotshape(sellConfirmedSignal, title="Entrada Venta",  style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0),   size=size.small)

// --- Etiquetas dinámicas de APROXIMACIÓN (aviso muy temprano, antes de tocar la zona) ---
var label approachLabelBuy  = na
var label approachLabelSell = na

if enablePreAlert and approachBuySignal
    txtAppB = "⏳ APROXIMANDO COMPRA"
    if na(approachLabelBuy)
        approachLabelBuy := label.new(bar_index, low - (high - low) * 1.5, txtAppB, style=label.style_label_up,
             color=color.new(color.blue, 40), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(approachLabelBuy, bar_index, low - (high - low) * 1.5)
        label.set_text(approachLabelBuy, txtAppB)
else if not na(approachLabelBuy)
    label.delete(approachLabelBuy)
    approachLabelBuy := na

if enablePreAlert and approachSellSignal
    txtAppS = "⏳ APROXIMANDO VENTA"
    if na(approachLabelSell)
        approachLabelSell := label.new(bar_index, high + (high - low) * 1.5, txtAppS, style=label.style_label_down,
             color=color.new(color.blue, 40), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(approachLabelSell, bar_index, high + (high - low) * 1.5)
        label.set_text(approachLabelSell, txtAppS)
else if not na(approachLabelSell)
    label.delete(approachLabelSell)
    approachLabelSell := na

// --- Etiquetas dinámicas de PRE-ALERTA (precio ya en zona, con contador de velas) ---
var label preLabelBuy  = na
var label preLabelSell = na

if enablePreAlert and preBuySignal
    txtPreB = "🔔 PRE COMPRA (faltan " + str.tostring(math.max(0, preAlertBars - barsInZone + 1)) + " de aviso)"
    if na(preLabelBuy)
        preLabelBuy := label.new(bar_index, low - (high - low) * 2.5, txtPreB, style=label.style_label_up,
             color=color.new(color.lime, 10), textcolor=color.black, size=size.small)
    else
        label.set_xy(preLabelBuy, bar_index, low - (high - low) * 2.5)
        label.set_text(preLabelBuy, txtPreB)
else if not na(preLabelBuy)
    label.delete(preLabelBuy)
    preLabelBuy := na

if enablePreAlert and preSellSignal
    txtPreS = "🔔 PRE VENTA (faltan " + str.tostring(math.max(0, preAlertBars - barsInZone + 1)) + " de aviso)"
    if na(preLabelSell)
        preLabelSell := label.new(bar_index, high + (high - low) * 2.5, txtPreS, style=label.style_label_down,
             color=color.new(color.orange, 10), textcolor=color.black, size=size.small)
    else
        label.set_xy(preLabelSell, bar_index, high + (high - low) * 2.5)
        label.set_text(preLabelSell, txtPreS)
else if not na(preLabelSell)
    label.delete(preLabelSell)
    preLabelSell := na

// --- Marcado de ENTRADA / SL / TP con líneas y etiquetas que siguen la operación abierta ---
var line  entryLine  = na
var line  slLine     = na
var line  tpLine     = na
var label entryLabel = na
var label slLabel    = na
var label tpLabel    = na

if showSLTP
    if buyConfirmedSignal and not na(lastSLLong)
        line.delete(entryLine)
        line.delete(slLine)
        line.delete(tpLine)
        label.delete(entryLabel)
        label.delete(slLabel)
        label.delete(tpLabel)
        entryLine  := line.new(bar_index, close, bar_index, close, color=color.new(color.blue, 0), style=line.style_dashed, width=1)
        slLine     := line.new(bar_index, lastSLLong, bar_index, lastSLLong, color=color.new(color.red, 0), style=line.style_dashed, width=1)
        tpLine     := line.new(bar_index, lastTPLong, bar_index, lastTPLong, color=color.new(color.green, 0), style=line.style_dashed, width=1)
        entryLabel := label.new(bar_index, close, "ENTRADA " + str.tostring(close, format.mintick), style=label.style_label_left, color=color.new(color.blue, 0), textcolor=color.white, size=size.small)
        slLabel    := label.new(bar_index, lastSLLong, "SL " + str.tostring(lastSLLong, format.mintick), style=label.style_label_left, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
        tpLabel    := label.new(bar_index, lastTPLong, "TP " + str.tostring(lastTPLong, format.mintick), style=label.style_label_left, color=color.new(color.green, 0), textcolor=color.white, size=size.small)
    if sellConfirmedSignal and not na(lastSLShort)
        line.delete(entryLine)
        line.delete(slLine)
        line.delete(tpLine)
        label.delete(entryLabel)
        label.delete(slLabel)
        label.delete(tpLabel)
        entryLine  := line.new(bar_index, close, bar_index, close, color=color.new(color.blue, 0), style=line.style_dashed, width=1)
        slLine     := line.new(bar_index, lastSLShort, bar_index, lastSLShort, color=color.new(color.red, 0), style=line.style_dashed, width=1)
        tpLine     := line.new(bar_index, lastTPShort, bar_index, lastTPShort, color=color.new(color.green, 0), style=line.style_dashed, width=1)
        entryLabel := label.new(bar_index, close, "ENTRADA " + str.tostring(close, format.mintick), style=label.style_label_left, color=color.new(color.blue, 0), textcolor=color.white, size=size.small)
        slLabel    := label.new(bar_index, lastSLShort, "SL " + str.tostring(lastSLShort, format.mintick), style=label.style_label_left, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
        tpLabel    := label.new(bar_index, lastTPShort, "TP " + str.tostring(lastTPShort, format.mintick), style=label.style_label_left, color=color.new(color.green, 0), textcolor=color.white, size=size.small)

    // Mientras la operación siga abierta, la línea y la etiqueta avanzan con el precio actual
    if strategy.position_size != 0 and not na(entryLine)
        line.set_x2(entryLine, bar_index)
        line.set_x2(slLine, bar_index)
        line.set_x2(tpLine, bar_index)
        label.set_x(entryLabel, bar_index)
        label.set_x(slLabel, bar_index)
        label.set_x(tpLabel, bar_index)

// =====================================================================================
// 9. PANEL VISUAL (DASHBOARD)
// =====================================================================================
var table dash = table.new(position.top_right, 2, 12, border_width=1, border_color=color.gray, frame_color=color.gray, frame_width=1)

if showDashboard and barstate.islast
    trendColor = trendUp ? color.new(color.green, 0) : trendDown ? color.new(color.red, 0) : color.new(color.gray, 0)

    pbStatus = stateCode == -1 ? "CONFIRMADO ✔" :
         stateCode == 1 ? "ZONA DE ENTRADA" :
         (approachBuySignal or approachSellSignal) ? "APROXIMANDO..." : "ESPERANDO RETROCESO"
    pbColor = stateCode == -1 ? color.new(color.green, 0) :
         stateCode == 1 ? color.new(color.orange, 0) :
         (approachBuySignal or approachSellSignal) ? color.new(color.blue, 0) : color.new(color.gray, 0)

    barsZoneTxt = stateCode == 1 ? str.tostring(barsInZone) + " / " + str.tostring(pullbackWindow) + "  (quedan " + str.tostring(barsRemaining) + ")" : "-"

    posSize    = strategy.position_size
    posTxt     = posSize > 0 ? "LONG 🟢" : posSize < 0 ? "SHORT 🔴" : "SIN POSICIÓN"
    posColor   = posSize > 0 ? color.new(color.green, 0) : posSize < 0 ? color.new(color.red, 0) : color.new(color.gray, 0)
    entryTxt   = posSize != 0 ? str.tostring(strategy.position_avg_price, format.mintick) : "-"
    slTxt      = posSize > 0 ? str.tostring(managedStopLong, format.mintick) : posSize < 0 ? str.tostring(managedStopShort, format.mintick) : "-"
    tpTxt      = posSize > 0 ? str.tostring(lastTPLong, format.mintick) : posSize < 0 ? str.tostring(lastTPShort, format.mintick) : "-"

    // --- Cabecera ---
    table.cell(dash, 0, 0, "📊 PANEL TP-EMA", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 0, timeframe.period + "  " + syminfo.ticker, text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(dash, 0, 1, "TENDENCIA",         text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(dash, 1, 1, trendState,           text_color=color.white, bgcolor=trendColor)

    table.cell(dash, 0, 2, "MOMENTUM (10/20)",   text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(dash, 1, 2, momentumUp ? "ALCISTA" : momentumDown ? "BAJISTA" : "PLANA",
         text_color=color.white, bgcolor=momentumUp ? color.new(color.green, 0) : momentumDown ? color.new(color.red, 0) : color.new(color.gray, 0))

    table.cell(dash, 0, 3, "EMA Gatillo/Tend.",  text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(dash, 1, 3, str.tostring(emaTrigger, format.mintick) + " / " + str.tostring(emaTrend, format.mintick),
         text_color=color.white, bgcolor=color.new(color.gray, 30))

    table.cell(dash, 0, 4, "DIST. A EMA GATILLO", text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(dash, 1, 4, str.tostring(distToTrigger, format.mintick) + " pts", text_color=color.white, bgcolor=color.new(color.gray, 30))

    table.cell(dash, 0, 5, "ESTADO PULLBACK",    text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(dash, 1, 5, pbStatus,             text_color=color.white, bgcolor=pbColor)

    table.cell(dash, 0, 6, "VELAS EN ZONA",      text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(dash, 1, 6, barsZoneTxt,          text_color=color.white, bgcolor=color.new(color.gray, 30))

    table.cell(dash, 0, 7, "PROBABILIDAD",       text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(dash, 1, 7, probLabel,            text_color=color.white, bgcolor=probColor)

    table.cell(dash, 0, 8, "SESIÓN ACTIVA",      text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(dash, 1, 8, inSession ? "SÍ" : "NO", text_color=color.white, bgcolor=inSession ? color.new(color.green, 0) : color.new(color.red, 0))

    table.cell(dash, 0, 9, "POSICIÓN",           text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(dash, 1, 9, posTxt,               text_color=color.white, bgcolor=posColor)

    table.cell(dash, 0, 10, "ENTRADA / SL / TP", text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(dash, 1, 10, entryTxt + "  /  " + slTxt + "  /  " + tpTxt, text_color=color.white, bgcolor=color.new(color.gray, 30))

    table.cell(dash, 0, 11, "ÚLTIMA SEÑAL",      text_color=color.white, bgcolor=color.new(color.navy, 0))
    table.cell(dash, 1, 11, lastSignalTxt,       text_color=color.white, bgcolor=color.new(color.gray, 30))

// =====================================================================================
// 10. ALERTAS PARA TRADINGVIEW (VISUALES / INFORMATIVAS, no van al bridge)
// =====================================================================================
alertcondition(approachBuySignal,  title="APROXIMANDO COMPRA",
     message='{"signal":"APPROACH_BUY","symbol":"{{ticker}}","price":{{close}},"time":"{{timenow}}"}')

alertcondition(approachSellSignal, title="APROXIMANDO VENTA",
     message='{"signal":"APPROACH_SELL","symbol":"{{ticker}}","price":{{close}},"time":"{{timenow}}"}')

alertcondition(preBuySignal and barsInZone == 1,  title="PRE COMPRA",
     message='{"signal":"PRE_BUY","symbol":"{{ticker}}","price":{{close}},"time":"{{timenow}}"}')

alertcondition(preSellSignal and barsInZone == 1, title="PRE VENTA",
     message='{"signal":"PRE_SELL","symbol":"{{ticker}}","price":{{close}},"time":"{{timenow}}"}')

alertcondition(buyConfirmedSignal, title="COMPRA CONFIRMADA",
     message='{"signal":"BUY_CONFIRMED","symbol":"{{ticker}}","price":{{close}},"time":"{{timenow}}"}')

alertcondition(sellConfirmedSignal, title="VENTA CONFIRMADA",
     message='{"signal":"SELL_CONFIRMED","symbol":"{{ticker}}","price":{{close}},"time":"{{timenow}}"}')

// =====================================================================================
// 11. ALERTAS DE AUTOMATIZACIÓN — ESQUEMA REAL DE PICKMYTRADE
// Referencia: docs.pickmytrade.trade "Generate Alert – JSON Configuration for TradingView"
//             y "Update Stop Loss (SL) and Take Profit (TP) in Tradovate with PickMyTrade"
//
// Campos clave que usa PickMyTrade (no son placeholders genéricos):
//   symbol, date, data ("buy"/"sell"/"close"), quantity, order_type ("MKT"/"LMT"),
//   sl / tp  -> PRECIOS ABSOLUTOS (no puntos ni distancias),
//   percentage_sl/tp, dollar_sl/tp -> alternativas, en 0 porque usamos sl/tp exactos,
//   update_sl / update_tp -> true SOLO en las alertas de gestión (sección 11b),
//   token, account_id, pyramid, reverse_order_close.
//
// IMPORTANTE:
// - Recuerda pegar cada alert() como el "Alert Message" en TradingView con el Webhook
//   URL de PickMyTrade para Tradovate: https://api.pickmytrade.trade/v2/add-trade-data-latest
// - Frecuencia del alert de TradingView: "Once Per Bar Close" (evita señales duplicadas
//   intrabar, PickMyTrade lo advierte explícitamente en su documentación).
// - symbol: usa el símbolo BASE (ej. "NQ", "MNQ"), no el continuo "NQ1!"; PickMyTrade
//   resuelve el contrato vigente. Verifica su regla de rollover si operas en fechas
//   cercanas al vencimiento.
// =====================================================================================
symForBridge = symbolOverride == "" ? syminfo.ticker : symbolOverride
pmtPyramidStr = pmtPyramidAlert ? "true" : "false"
pmtReverseStr = pmtReverseOrderClose ? "true" : "false"

if enableAutoAlerts and buyConfirmedSignal and canTrade and not na(lastQtyLong)
    autoMsgBuy = '{"symbol":"' + symForBridge + '","date":"{{timenow}}","data":"buy"' +
         ',"quantity":' + str.tostring(lastQtyLong, "#") +
         ',"risk_percentage":0' +
         ',"order_type":"' + pmtOrderType + '"' +
         ',"tp":' + str.tostring(lastTPLong, format.mintick) + ',"percentage_tp":0,"dollar_tp":0' +
         ',"sl":' + str.tostring(lastSLLong, format.mintick) + ',"percentage_sl":0,"dollar_sl":0' +
         ',"update_tp":false,"update_sl":false' +
         ',"token":"' + pmtToken + '"' +
         ',"pyramid":' + pmtPyramidStr +
         ',"reverse_order_close":' + pmtReverseStr +
         (pmtAccountId == "" ? "" : ',"account_id":"' + pmtAccountId + '"') +
         '}'
    alert(autoMsgBuy, alert.freq_once_per_bar_close)

if enableAutoAlerts and sellConfirmedSignal and canTrade and not na(lastQtyShort)
    autoMsgSell = '{"symbol":"' + symForBridge + '","date":"{{timenow}}","data":"sell"' +
         ',"quantity":' + str.tostring(lastQtyShort, "#") +
         ',"risk_percentage":0' +
         ',"order_type":"' + pmtOrderType + '"' +
         ',"tp":' + str.tostring(lastTPShort, format.mintick) + ',"percentage_tp":0,"dollar_tp":0' +
         ',"sl":' + str.tostring(lastSLShort, format.mintick) + ',"percentage_sl":0,"dollar_sl":0' +
         ',"update_tp":false,"update_sl":false' +
         ',"token":"' + pmtToken + '"' +
         ',"pyramid":' + pmtPyramidStr +
         ',"reverse_order_close":' + pmtReverseStr +
         (pmtAccountId == "" ? "" : ',"account_id":"' + pmtAccountId + '"') +
         '}'
    alert(autoMsgSell, alert.freq_once_per_bar_close)

positionJustClosed = strategy.position_size == 0 and strategy.position_size[1] != 0
closedWasLong = strategy.position_size[1] > 0

if enableAutoAlerts and sendExitAlert and positionJustClosed
    autoMsgExit = '{"symbol":"' + symForBridge + '","date":"{{timenow}}","data":"close"' +
         ',"token":"' + pmtToken + '"' +
         (pmtAccountId == "" ? "" : ',"account_id":"' + pmtAccountId + '"') +
         '}'
    alert(autoMsgExit, alert.freq_once_per_bar_close)

// =====================================================================================
// 11b. ALERTAS update_sl → BREAK EVEN / TRAILING (mismo formato oficial de PickMyTrade)
// Se disparan solo cuando el stop manejado en 7b mejora (nunca en cada barra sin cambio).
// "data" debe reflejar el lado de la posición abierta que se está gestionando.
// =====================================================================================
if enableAutoAlerts and pmtSendStopUpdates and sendStopUpdateLong and not na(newManagedStopLong)
    autoMsgUpdateSLLong = '{"symbol":"' + symForBridge + '","date":"{{timenow}}","data":"buy"' +
         ',"quantity":' + str.tostring(lastQtyLong, "#") +
         ',"update_sl":true,"sl":' + str.tostring(newManagedStopLong, format.mintick) +
         ',"percentage_sl":0,"dollar_sl":0' +
         ',"token":"' + pmtToken + '"' +
         (pmtAccountId == "" ? "" : ',"account_id":"' + pmtAccountId + '"') +
         '}'
    alert(autoMsgUpdateSLLong, alert.freq_once_per_bar_close)

if enableAutoAlerts and pmtSendStopUpdates and sendStopUpdateShort and not na(newManagedStopShort)
    autoMsgUpdateSLShort = '{"symbol":"' + symForBridge + '","date":"{{timenow}}","data":"sell"' +
         ',"quantity":' + str.tostring(lastQtyShort, "#") +
         ',"update_sl":true,"sl":' + str.tostring(newManagedStopShort, format.mintick) +
         ',"percentage_sl":0,"dollar_sl":0' +
         ',"token":"' + pmtToken + '"' +
         (pmtAccountId == "" ? "" : ',"account_id":"' + pmtAccountId + '"') +
         '}'
    alert(autoMsgUpdateSLShort, alert.freq_once_per_bar_close)
````
