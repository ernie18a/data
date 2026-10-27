# PIVOT + SL/TP v2 (MAXSAM)

- url: https://www.tradingview.com/script/nCfALJH6/
- type: indicator
- pine_id: PUB;b15a673b46224eb9b7c680a718af8ce6
- version: 1.0

## Description

🎯 PIVOT + SL/TP — (MAXSAM)

How many times did you nail the perfect entry... but had no clear exit plan?

This indicator was built from that frustration.

Bounce Zones automatically identifies the most relevant DEMAND and SUPPLY zones on any chart — those areas where price has bounced multiple times and where major market participants tend to defend their positions. But it doesn’t stop there.

Every zone comes with a complete Trade Plan:
✅ Precise entry at the zone’s edge
🛡️ Stop Loss calculated with a smart buffer beyond the real pivot extreme
🎯 TP1 and TP2 projected toward the nearest opposing zones
📊 R:R Ratio displayed so you decide before entering, not after

🔥 What makes it different:
— Dynamic zone scoring (touches, trendline confluence, recency & volume)
— Detects and discards broken zones so you don’t get false signals
— Only shows signals when price is on the correct side of the trade
— Smart merging of overlapping zones to cut through the noise
— Summary panel showing the best active opportunity in real time

This is not an auto-entry indicator. It’s a tool for traders who want to operate with context, structure, and a defined risk from the very first moment.

Use it. Improve it. Make it yours.

📌 Works on any asset and timeframe.
💡 Open source — because sharing knowledge is what makes us better traders.

— MAXSAM

## Source Code

````pine
//@version=6
// ============================================================================
// PIVOT + SL/TP (MAXSAM) — VERSIÓN OPTIMIZADA
// Mejoras: precisión de señales, rendimiento, scoring mejorado
// ============================================================================
indicator("PIVOT + SL/TP v2 (MAXSAM)", overlay=true,
     max_boxes_count=100, max_lines_count=200,
     max_labels_count=200, max_bars_back=5000)

// ============================================================================
// ENTRADAS / INPUTS
// ============================================================================
grpDet = "Detección"
pivotLen     = input.int(10,  "Longitud Pivote S/R",        minval=2,  maxval=50,   group=grpDet)
tlPivotLen   = input.int(8,   "Longitud Pivote Tendencia",  minval=2,  maxval=30,   group=grpDet)
lookback     = input.int(300, "Barras a analizar",          minval=50, maxval=5000, group=grpDet)
srTolerance  = input.float(0.5, "Tolerancia agrupación (×ATR)",       minval=0.1, maxval=5.0, step=0.1, group=grpDet)
tlTolerance  = input.float(0.3, "Tolerancia toque tendencia (×ATR)",  minval=0.1, maxval=3.0, step=0.1, group=grpDet)
minTouchesTL = input.int(2,   "Toques mínimos tendencia",  minval=2,  maxval=10,   group=grpDet)

grpZonas   = "Zonas de Rebote"
zoneHeight = input.float(0.6, "Altura de zona (×ATR)",     minval=0.1, maxval=3.0, step=0.1, group=grpZonas)
maxZones   = input.int(5,     "Máx. zonas a mostrar",      minval=1,   maxval=15,            group=grpZonas)
minScore   = input.float(30,  "Puntuación mínima (%)",     minval=10,  maxval=100, step=5,   group=grpZonas)
mergeZones = input.bool(true, "Fusionar zonas solapadas",                                    group=grpZonas)

// OPT #1 — NUEVO: Filtro por volumen relativo para validar zonas de alta actividad
grpFiltro      = "Filtros de Relevancia"
showOnlyNearby = input.bool(true,  "Mostrar solo zonas cercanas",      group=grpFiltro)
nearbyRange    = input.float(8.0,  "Rango cercanía (×ATR)", minval=1.0, maxval=30.0, step=0.5, group=grpFiltro)
useVolFilter   = input.bool(false, "Filtro de volumen (requiere datos)", group=grpFiltro,
     tooltip="Bonifica zonas donde el volumen superó la media en el momento del pivote")

grpTrade       = "Plan de Trade (SL/TP)"
showTradePlan  = input.bool(true,  "Mostrar plan SL/TP",                  group=grpTrade)
slBufferATR    = input.float(0.5,  "Colchón SL (×ATR)",   minval=0.1, maxval=3.0, step=0.1, group=grpTrade,
     tooltip="Distancia extra del SL fuera de la zona para evitar barridos")
minRR          = input.float(1.0,  "Ratio R:R mínimo",    minval=0.5, maxval=5.0, step=0.1, group=grpTrade,
     tooltip="Si TP1 no alcanza este ratio, no se muestra el plan")
tpExtendATR    = input.float(3.0,  "TP fallback (×ATR si no hay objetivo)", minval=1.0, maxval=10.0, step=0.5, group=grpTrade)
showOnlyTopPlan = input.bool(false,"Solo plan de la mejor zona", group=grpTrade,
     tooltip="Si está activo, solo dibuja el plan de la zona con mayor score")

// OPT #2 — NUEVO: opción de anclar SL al extremo real del pivote en lugar del borde de zona
slMode = input.string("Zona + buffer", "Modo SL",
     options=["Zona + buffer", "Pivote extremo + buffer"],
     group=grpTrade,
     tooltip="'Pivote extremo' usa el high/low real del pivote más cercano a la zona, más preciso que solo el borde de zona")

grpStyle    = "Estilo Visual"
demandColor = input.color(#26a69a, "Color zona de DEMANDA", group=grpStyle)
supplyColor = input.color(#ef5350, "Color zona de OFERTA",  group=grpStyle)
slColor     = input.color(#e91e63, "Color SL",              group=grpStyle)
tp1Color    = input.color(#4caf50, "Color TP1",             group=grpStyle)
tp2Color    = input.color(#2e7d32, "Color TP2",             group=grpStyle)
showScore   = input.bool(true,  "Mostrar puntuación de zona", group=grpStyle)
showPanel   = input.bool(true,  "Mostrar panel resumen",      group=grpStyle)
extendBars  = input.int(30,     "Extensión hacia la derecha", minval=5, maxval=100, group=grpStyle)

// ============================================================================
// FUNCIONES AUXILIARES
// ============================================================================
// OPT #3 — ATR suavizado con EMA para reducir ruido en mercados volátiles
atrRaw  = ta.atr(14)
atr     = ta.ema(atrRaw, 5)   // suavizado ligero; evita que una vela extrema distorsione zonas

f_scoreAlpha(float score) =>
    math.round(80.0 - (score / 100.0) * 65.0)

// OPT #4 — Volumen relativo: ratio vol actual vs media 20 períodos
volMA    = ta.sma(volume, 20)
relVol   = volMA > 0 ? volume / volMA : 1.0

// ============================================================================
// PIVOTES
// ============================================================================
ph   = ta.pivothigh(high, pivotLen,   pivotLen)
pl   = ta.pivotlow (low,  pivotLen,   pivotLen)
phTL = ta.pivothigh(high, tlPivotLen, tlPivotLen)
plTL = ta.pivotlow (low,  tlPivotLen, tlPivotLen)

var array<float> pHighs  = array.new<float>()
var array<int>   pHighB  = array.new<int>()
var array<float> pHighVR = array.new<float>()   // OPT #4: vol relativo en el pivote
var array<float> pLows   = array.new<float>()
var array<int>   pLowB   = array.new<int>()
var array<float> pLowVR  = array.new<float>()

if not na(ph)
    array.push(pHighs, ph)
    array.push(pHighB, bar_index - pivotLen)
    array.push(pHighVR, relVol[pivotLen])
    if array.size(pHighs) > 200
        array.shift(pHighs)
        array.shift(pHighB)
        array.shift(pHighVR)

if not na(pl)
    array.push(pLows,  pl)
    array.push(pLowB,  bar_index - pivotLen)
    array.push(pLowVR, relVol[pivotLen])
    if array.size(pLows) > 200
        array.shift(pLows)
        array.shift(pLowB)
        array.shift(pLowVR)

var array<float> tlPHs = array.new<float>()
var array<int>   tlPHb = array.new<int>()
var array<float> tlPLs = array.new<float>()
var array<int>   tlPLb = array.new<int>()

if not na(phTL)
    array.push(tlPHs, phTL)
    array.push(tlPHb, bar_index - tlPivotLen)
    if array.size(tlPHs) > 100
        array.shift(tlPHs)
        array.shift(tlPHb)

if not na(plTL)
    array.push(tlPLs, plTL)
    array.push(tlPLb, bar_index - tlPivotLen)
    if array.size(tlPLs) > 100
        array.shift(tlPLs)
        array.shift(tlPLb)

// ============================================================================
// TIPOS
// ============================================================================
type SRLevel
    float price        = 0.0
    int   touches      = 0
    int   firstBar     = 0
    int   lastBar      = 0
    bool  isDemand     = false
    float avgVolRel    = 1.0  // volumen relativo promedio
    float extremePrice = 0.0  // extremo real del pivote

type Zone
    float topPrice      = 0.0
    float botPrice      = 0.0
    float centerPrice   = 0.0
    int   firstBar      = 0
    int   touches       = 0
    int   trendlineHits = 0
    bool  isDemand      = false
    float score         = 0.0
    float entryPrice    = 0.0
    float slPrice       = 0.0
    float tp1Price      = 0.0
    float tp2Price      = 0.0
    float rr1           = 0.0
    float rr2           = 0.0
    bool  hasValidPlan  = false
    float extremePrice  = 0.0

// ============================================================================
// CLUSTERS S/R — con volumen y extremo de pivote
// ============================================================================
f_buildClusters(array<float> prices, array<int> bars, bool isDem, array<float> volRels) =>
    array<SRLevel> result = array.new<SRLevel>()
    int n = array.size(prices)
    if n > 0
        for i = 0 to n - 1
            float p  = array.get(prices,   i)
            int   b  = array.get(bars,     i)
            float vr = array.size(volRels) > i ? array.get(volRels, i) : 1.0
            if (bar_index - b) <= lookback
                bool merged = false
                int csize = array.size(result)
                if csize > 0
                    for j = 0 to csize - 1
                        SRLevel lvl = array.get(result, j)
                        if math.abs(lvl.price - p) <= atr * srTolerance
                            float newPrice = (lvl.price * lvl.touches + p) / (lvl.touches + 1)
                            // OPT #4: promedio ponderado de volumen relativo
                            float newVR    = (lvl.avgVolRel * lvl.touches + vr) / (lvl.touches + 1)
                            // OPT #2: guardar el extremo más conservador (mínimo en demanda, máximo en oferta)
                            float newExt   = isDem
                                 ? math.min(lvl.extremePrice, p)
                                 : math.max(lvl.extremePrice, p)
                            lvl.price        := newPrice
                            lvl.touches      += 1
                            lvl.firstBar     := math.min(lvl.firstBar, b)
                            lvl.lastBar      := math.max(lvl.lastBar,  b)
                            lvl.avgVolRel    := newVR
                            lvl.extremePrice := newExt
                            array.set(result, j, lvl)
                            merged := true
                            break
                if not merged
                    array.push(result, SRLevel.new(p, 1, b, b, isDem, vr, p))
    result

// ============================================================================
// CONFLUENCIA DE TENDENCIAS — optimizada
// OPT #5: se pre-filtra por distancia antes del bucle while para evitar
// iterar líneas que claramente no pasan cerca del precio evaluado.
// ============================================================================
f_trendlineConfluence(float price, bool isDemand) =>
    int   hits = 0
    float tol  = atr * (srTolerance + 0.2)
    int   STEP = 4   // OPT #6: paso 4 en vez de 3 — ~25% menos iteraciones, impacto mínimo en precisión

    if isDemand
        int n = array.size(tlPLs)
        if n >= 2
            for i = 0 to n - 2
                for j = i + 1 to n - 1
                    int   b1 = array.get(tlPLb, i)
                    float p1 = array.get(tlPLs, i)
                    int   b2 = array.get(tlPLb, j)
                    float p2 = array.get(tlPLs, j)
                    if (bar_index - b1) <= lookback and p2 > p1 and b2 > b1
                        float slope = (p2 - p1) / float(b2 - b1)
                        float yNow  = p1 + slope * (bar_index - b1)
                        // OPT #5: pre-filtro — si el precio proyectado ahora está lejos, saltamos
                        if math.abs(yNow - price) <= tol
                            int   tcount = 0
                            int   bIter  = b1
                            while bIter <= bar_index
                                int off = bar_index - bIter
                                if off >= 0 and off < 5000
                                    float lineY = p1 + slope * (bIter - b1)
                                    if math.abs(low[off] - lineY) <= atr * tlTolerance
                                        tcount += 1
                                bIter += STEP
                            if tcount >= minTouchesTL
                                hits += 1
    else
        int n = array.size(tlPHs)
        if n >= 2
            for i = 0 to n - 2
                for j = i + 1 to n - 1
                    int   b1 = array.get(tlPHb, i)
                    float p1 = array.get(tlPHs, i)
                    int   b2 = array.get(tlPHb, j)
                    float p2 = array.get(tlPHs, j)
                    if (bar_index - b1) <= lookback and p2 < p1 and b2 > b1
                        float slope = (p2 - p1) / float(b2 - b1)
                        float yNow  = p1 + slope * (bar_index - b1)
                        // OPT #5: pre-filtro
                        if math.abs(yNow - price) <= tol
                            int   tcount = 0
                            int   bIter  = b1
                            while bIter <= bar_index
                                int off = bar_index - bIter
                                if off >= 0 and off < 5000
                                    float lineY = p1 + slope * (bIter - b1)
                                    if math.abs(high[off] - lineY) <= atr * tlTolerance
                                        tcount += 1
                                bIter += STEP
                            if tcount >= minTouchesTL
                                hits += 1
    hits

// ============================================================================
// ARRAYS DE DIBUJO
// ============================================================================
var array<box>   zoneBoxes  = array.new<box>()
var array<label> zoneLabels = array.new<label>()
var array<line>  planLines  = array.new<line>()
var array<label> planLabels = array.new<label>()

f_clearAll() =>
    if array.size(zoneBoxes) > 0
        for i = 0 to array.size(zoneBoxes) - 1
            box.delete(array.get(zoneBoxes, i))
    array.clear(zoneBoxes)
    if array.size(zoneLabels) > 0
        for i = 0 to array.size(zoneLabels) - 1
            label.delete(array.get(zoneLabels, i))
    array.clear(zoneLabels)
    if array.size(planLines) > 0
        for i = 0 to array.size(planLines) - 1
            line.delete(array.get(planLines, i))
    array.clear(planLines)
    if array.size(planLabels) > 0
        for i = 0 to array.size(planLabels) - 1
            label.delete(array.get(planLabels, i))
    array.clear(planLabels)

// ============================================================================
// CÁLCULO DE PLAN SL/TP
// OPT #2: modo "Pivote extremo" usa el low/high real del cluster como base del SL
// OPT #7: entrada mejorada — usa el borde de la zona (no el centro) para mayor
//         precisión en trades reales. Demanda → entrada en topPrice, oferta → botPrice.
// ============================================================================
f_calculatePlan(Zone z, array<Zone> allZones) =>
    // OPT #7: entrada en el borde de la zona más cercano al precio actual
    float entry   = z.isDemand ? z.topPrice : z.botPrice
    float safeATR = atr > 0 ? atr : 1.0

    float sl = na
    if slMode == "Pivote extremo + buffer"
        // Usa el extremo real del pivote (más conservador y preciso)
        sl := z.isDemand
             ? z.extremePrice - (safeATR * slBufferATR)
             : z.extremePrice + (safeATR * slBufferATR)
    else
        sl := z.isDemand
             ? z.botPrice - (safeATR * slBufferATR)
             : z.topPrice + (safeATR * slBufferATR)

    float tp1 = na
    float tp2 = na

    if z.isDemand
        array<float> targets = array.new<float>()
        if array.size(allZones) > 0
            for i = 0 to array.size(allZones) - 1
                Zone t = array.get(allZones, i)
                // OPT #8: el objetivo debe tener score mínimo razonable para ser válido
                if not t.isDemand and t.botPrice > entry and t.score >= (minScore * 0.7)
                    array.push(targets, t.botPrice)
        if array.size(targets) > 1
            array.sort(targets, order.ascending)
        tp1 := array.size(targets) >= 1 ? array.get(targets, 0) : entry + (safeATR * tpExtendATR)
        tp2 := array.size(targets) >= 2 ? array.get(targets, 1) : entry + (safeATR * tpExtendATR * 1.8)
    else
        array<float> targets = array.new<float>()
        if array.size(allZones) > 0
            for i = 0 to array.size(allZones) - 1
                Zone t = array.get(allZones, i)
                if t.isDemand and t.topPrice < entry and t.score >= (minScore * 0.7)
                    array.push(targets, t.topPrice)
        if array.size(targets) > 1
            array.sort(targets, order.descending)
        tp1 := array.size(targets) >= 1 ? array.get(targets, 0) : entry - (safeATR * tpExtendATR)
        tp2 := array.size(targets) >= 2 ? array.get(targets, 1) : entry - (safeATR * tpExtendATR * 1.8)

    float risk  = math.abs(entry - sl)
    float r1    = risk > 0 ? math.abs(tp1 - entry) / risk : 0.0
    float r2    = risk > 0 ? math.abs(tp2 - entry) / risk : 0.0
    bool  valid = r1 >= minRR

    z.entryPrice   := entry
    z.slPrice      := sl
    z.tp1Price     := tp1
    z.tp2Price     := tp2
    z.rr1          := r1
    z.rr2          := r2
    z.hasValidPlan := valid
    z

// ============================================================================
// VARIABLES DE PANEL
// ============================================================================
var int   panelDemandCount = 0
var int   panelSupplyCount = 0
var float panelTopScore    = 0.0
var float panelTopPrice    = 0.0
var bool  panelTopIsDemand = false
var float panelTopRR       = 0.0

// ============================================================================
// PROCESO PRINCIPAL
// ============================================================================
if barstate.islast
    f_clearAll()

    // 1) Construir clusters (ahora con volumen relativo)
    array<SRLevel> demands  = f_buildClusters(pLows,  pLowB,  true,  pLowVR)
    array<SRLevel> supplies = f_buildClusters(pHighs, pHighB, false, pHighVR)

    array<SRLevel> allLevels = array.new<SRLevel>()
    if array.size(demands) > 0
        for i = 0 to array.size(demands) - 1
            array.push(allLevels, array.get(demands, i))
    if array.size(supplies) > 0
        for i = 0 to array.size(supplies) - 1
            array.push(allLevels, array.get(supplies, i))

    // 2) Máximo de toques
    int maxTouches = 1
    if array.size(allLevels) > 0
        for i = 0 to array.size(allLevels) - 1
            SRLevel lvl = array.get(allLevels, i)
            if lvl.touches > maxTouches
                maxTouches := lvl.touches

    // 3) Generar zonas con scoring mejorado
    array<Zone> zones = array.new<Zone>()
    if array.size(allLevels) > 0
        for i = 0 to array.size(allLevels) - 1
            SRLevel lvl = array.get(allLevels, i)
            if lvl.touches >= 2
                bool keep = true
                if showOnlyNearby
                    if math.abs(lvl.price - close) > atr * nearbyRange
                        keep := false

                if keep
                    // FIX CRÍTICO: detectar si la zona fue perforada/rota por el precio actual
                    // Una zona de DEMANDA rota = precio está claramente POR DEBAJO de su base
                    // Una zona de OFERTA rota   = precio está claramente POR ENCIMA de su techo
                    float halfH_chk = atr * zoneHeight / 2.0
                    float zTop_chk  = lvl.price + halfH_chk
                    float zBot_chk  = lvl.price - halfH_chk
                    bool  broken    = lvl.isDemand ? (close < zBot_chk - atr * 0.3) : (close > zTop_chk + atr * 0.3)

                    // FIX CRÍTICO: solo mostrar zona si precio está del lado correcto para el trade
                    // DEMANDA válida: precio encima o dentro de la zona (posible rebote al alza)
                    // OFERTA válida:  precio debajo o dentro de la zona (posible rebote a la baja)
                    bool  wrongSide = lvl.isDemand ? (close < lvl.price - halfH_chk * 1.5) : (close > lvl.price + halfH_chk * 1.5)

                    if not broken and not wrongSide
                        int tlHits = f_trendlineConfluence(lvl.price, lvl.isDemand)

                        // SCORING MEJORADO: escala logarítmica + recencia + volumen
                        float touchRaw = math.min(1.0, math.log(float(lvl.touches)) / math.log(float(math.max(maxTouches, 3))))
                        float tlPct    = math.min(1.0, tlHits / 3.0)
                        float agePct   = math.min(1.0, float(bar_index - lvl.firstBar) / float(lookback))
                        float recency  = 1.0 - math.min(1.0, float(bar_index - lvl.lastBar) / float(lookback * 0.5))
                        float volBonus = useVolFilter ? math.min(1.0, (lvl.avgVolRel - 1.0) / 2.0) : 0.0
                        volBonus      := math.max(0.0, volBonus)

                        // Pesos: toques 35%, trendline 25%, recencia 20%, antigüedad 10%, volumen 10%
                        float score = (touchRaw * 35.0) + (tlPct * 25.0) + (recency * 20.0) + (agePct * 10.0) + (volBonus * 10.0)
                        score := math.min(100.0, score)

                        if score >= minScore
                            float halfH = atr * zoneHeight / 2.0
                            Zone z = Zone.new(
                                 lvl.price + halfH,
                                 lvl.price - halfH,
                                 lvl.price,
                                 lvl.firstBar,
                                 lvl.touches,
                                 tlHits,
                                 lvl.isDemand,
                                 score,
                                 na, na, na, na,
                                 0.0, 0.0,
                                 false,
                                 lvl.extremePrice)
                            array.push(zones, z)

    // 4) Fusión de zonas solapadas
    if mergeZones and array.size(zones) > 1
        array<Zone> merged = array.new<Zone>()
        for i = 0 to array.size(zones) - 1
            Zone cur      = array.get(zones, i)
            bool absorbed = false
            int  ms       = array.size(merged)
            if ms > 0
                for k = 0 to ms - 1
                    Zone ex       = array.get(merged, k)
                    bool sameType = ex.isDemand == cur.isDemand
                    bool overlap  = cur.botPrice <= ex.topPrice and cur.topPrice >= ex.botPrice
                    if sameType and overlap
                        ex.topPrice      := math.max(ex.topPrice,  cur.topPrice)
                        ex.botPrice      := math.min(ex.botPrice,  cur.botPrice)
                        ex.centerPrice   := (ex.topPrice + ex.botPrice) / 2.0
                        ex.touches       += cur.touches
                        ex.trendlineHits += cur.trendlineHits
                        ex.score         := math.min(100.0, ex.score + cur.score * 0.3)
                        ex.firstBar      := math.min(ex.firstBar, cur.firstBar)
                        // OPT #2: conservar el extremo más agresivo tras fusión
                        ex.extremePrice  := ex.isDemand
                             ? math.min(ex.extremePrice, cur.extremePrice)
                             : math.max(ex.extremePrice, cur.extremePrice)
                        array.set(merged, k, ex)
                        absorbed := true
                        break
            if not absorbed
                array.push(merged, cur)
        zones := merged

    // 5) Ordenar por score (bubble sort)
    int zsize = array.size(zones)
    if zsize > 1
        for i = 0 to zsize - 2
            for j = 0 to zsize - 2 - i
                Zone za = array.get(zones, j)
                Zone zb = array.get(zones, j + 1)
                if za.score < zb.score
                    array.set(zones, j,     zb)
                    array.set(zones, j + 1, za)

    // 6) Limitar a top N
    array<Zone> finalZones = array.new<Zone>()
    int toDraw = math.min(maxZones, array.size(zones))
    if toDraw > 0
        for i = 0 to toDraw - 1
            array.push(finalZones, array.get(zones, i))

    // 7) Calcular plan SL/TP
    int fz = array.size(finalZones)
    if fz > 0
        for i = 0 to fz - 1
            Zone z = array.get(finalZones, i)
            z := f_calculatePlan(z, finalZones)
            array.set(finalZones, i, z)

    // 8) Dibujar zonas
    panelDemandCount := 0
    panelSupplyCount := 0
    panelTopScore    := 0.0
    panelTopRR       := 0.0

    if fz > 0
        for i = 0 to fz - 1
            Zone  z         = array.get(finalZones, i)
            color baseCol   = z.isDemand ? demandColor : supplyColor
            int   alpha     = f_scoreAlpha(z.score)
            int   alphaClamped  = math.max(0, math.min(100, alpha))
            int   alphaBorder   = math.max(0, math.min(100, alpha - 30))
            color fillCol   = color.new(baseCol, alphaClamped)
            color borderCol = color.new(baseCol, alphaBorder)

            int xEnd = bar_index + extendBars
            box bx = box.new(z.firstBar, z.topPrice, xEnd, z.botPrice,
                             border_color=borderCol, border_width=1, bgcolor=fillCol)
            array.push(zoneBoxes, bx)

            if showScore
                string typeTxt = z.isDemand ? "DEMANDA" : "OFERTA"
                string volTxt  = useVolFilter and z.score >= minScore ? " 📊" : ""
                string txt = typeTxt + " " + str.tostring(math.round(z.score)) + "%" + volTxt
                if z.trendlineHits > 0
                    txt := txt + " ⚡" + str.tostring(z.trendlineHits)
                txt := txt + " ×" + str.tostring(z.touches)
                label lb = label.new(xEnd, z.centerPrice, txt,
                             xloc=xloc.bar_index, yloc=yloc.price,
                             style=label.style_label_left,
                             color=color.new(baseCol, 10),
                             textcolor=color.white, size=size.small)
                array.push(zoneLabels, lb)

            if z.isDemand
                panelDemandCount += 1
            else
                panelSupplyCount += 1

            if z.score > panelTopScore
                panelTopScore    := z.score
                panelTopPrice    := z.centerPrice
                panelTopIsDemand := z.isDemand
                panelTopRR       := z.rr1

    // 9) Dibujar SL/TP
    if showTradePlan
        int planLimit = showOnlyTopPlan ? math.min(1, fz) : fz
        if planLimit > 0
            for i = 0 to planLimit - 1
                Zone z = array.get(finalZones, i)
                if z.hasValidPlan
                    int xEnd   = bar_index + extendBars
                    int xStart = bar_index + 2

                    line slLine = line.new(xStart, z.slPrice, xEnd, z.slPrice,
                                 color=color.new(slColor, 0), width=2, style=line.style_dashed)
                    array.push(planLines, slLine)
                    label slLabel = label.new(xEnd, z.slPrice,
                                 "SL " + str.tostring(math.round_to_mintick(z.slPrice)),
                                 xloc=xloc.bar_index, yloc=yloc.price,
                                 style=label.style_label_left,
                                 color=color.new(slColor, 20),
                                 textcolor=color.white, size=size.small)
                    array.push(planLabels, slLabel)

                    line tp1Line = line.new(xStart, z.tp1Price, xEnd, z.tp1Price,
                                 color=color.new(tp1Color, 0), width=2, style=line.style_dashed)
                    array.push(planLines, tp1Line)
                    string tp1Txt = "TP1 " + str.tostring(math.round_to_mintick(z.tp1Price)) +
                                 " (R:R " + str.tostring(z.rr1, "#.##") + ")"
                    label tp1Label = label.new(xEnd, z.tp1Price, tp1Txt,
                                 xloc=xloc.bar_index, yloc=yloc.price,
                                 style=label.style_label_left,
                                 color=color.new(tp1Color, 20),
                                 textcolor=color.white, size=size.small)
                    array.push(planLabels, tp1Label)

                    line tp2Line = line.new(xStart, z.tp2Price, xEnd, z.tp2Price,
                                 color=color.new(tp2Color, 0), width=2, style=line.style_dotted)
                    array.push(planLines, tp2Line)
                    string tp2Txt = "TP2 " + str.tostring(math.round_to_mintick(z.tp2Price)) +
                                 " (R:R " + str.tostring(z.rr2, "#.##") + ")"
                    label tp2Label = label.new(xEnd, z.tp2Price, tp2Txt,
                                 xloc=xloc.bar_index, yloc=yloc.price,
                                 style=label.style_label_left,
                                 color=color.new(tp2Color, 20),
                                 textcolor=color.white, size=size.small)
                    array.push(planLabels, tp2Label)

                    line entryLine = line.new(xStart, z.entryPrice, xEnd, z.entryPrice,
                                 color=color.new(color.yellow, 30), width=1, style=line.style_solid)
                    array.push(planLines, entryLine)
                    string dirArrow = z.isDemand ? "↑ LONG" : "↓ SHORT"
                    label entryLabel = label.new(xEnd, z.entryPrice,
                                 dirArrow + " " + str.tostring(math.round_to_mintick(z.entryPrice)),
                                 xloc=xloc.bar_index, yloc=yloc.price,
                                 style=label.style_label_left,
                                 color=color.new(color.yellow, 20),
                                 textcolor=color.black, size=size.small)
                    array.push(planLabels, entryLabel)

// ============================================================================
// PANEL RESUMEN
// ============================================================================
var table panel = table.new(position.top_right, 2, 7,
     bgcolor=color.new(color.black, 80),
     border_width=1, border_color=color.new(color.gray, 50))

if barstate.islast and showPanel
    table.cell(panel, 0, 0, "ZONAS + PLAN v2",
         text_color=color.white, text_size=size.normal, bgcolor=color.new(color.blue, 40))
    table.cell(panel, 1, 0, "", bgcolor=color.new(color.blue, 40))

    table.cell(panel, 0, 1, "Demanda", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 1, str.tostring(panelDemandCount),
         text_color=color.new(demandColor, 0), text_size=size.small)

    table.cell(panel, 0, 2, "Oferta", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 2, str.tostring(panelSupplyCount),
         text_color=color.new(supplyColor, 0), text_size=size.small)

    string topTxt = panelTopScore > 0 and not na(panelTopPrice) ?
         (panelTopIsDemand ? "↑ " : "↓ ") + str.tostring(math.round_to_mintick(panelTopPrice)) : "—"
    table.cell(panel, 0, 3, "Mejor zona", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 3, topTxt, text_color=color.white, text_size=size.small)

    table.cell(panel, 0, 4, "Score", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 4, str.tostring(math.round(panelTopScore)) + "%",
         text_color=color.yellow, text_size=size.small)

    table.cell(panel, 0, 5, "R:R TP1", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 5,
         panelTopRR > 0 ? str.tostring(panelTopRR, "#.##") : "—",
         text_color=color.aqua, text_size=size.small)

    // OPT #10: mostrar modo SL activo en panel
    table.cell(panel, 0, 6, "Modo SL", text_color=color.gray, text_size=size.tiny)
    table.cell(panel, 1, 6, slMode == "Pivote extremo + buffer" ? "Pivote" : "Zona",
         text_color=color.gray, text_size=size.tiny)
````
