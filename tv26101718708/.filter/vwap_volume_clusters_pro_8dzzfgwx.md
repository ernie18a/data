# VWAP + Volume Clusters [Pro]

- url: https://www.tradingview.com/script/8dZzfGwX-vwap-volume-clusters-pro/
- type: indicator
- pine_id: PUB;a43166a56f3c46c9a84c610896c737f7
- version: 1.0

## Description

Институциональный VWAP и сессионный профиль объёма в одном инструменте — для intraday-трейдинга по логике «цена движется от ликвидности к ликвидности».

  Индикатор объединяет два ключевых ориентира внутридневной торговли: VWAP как institutional reference (средняя цена, по которой реально торговали крупные участники) и распределение объёма по уровням как зоны
  интереса. Минималистичный визуал, всё настраивается.

  Что внутри

  1. Session VWAP + полосы σ
  VWAP с привязкой к сессии (сброс в начале дня) и полосами стандартных отклонений 1σ / 2σ / 3σ. Полосы включаются по отдельности, множители настраиваются. VWAP — это «справедливая цена» дня: цена выше VWAP =
  контроль покупателей, ниже = продавцов. Полосы 2σ/3σ — зоны статистического перерастяжения (потенциальный возврат к среднему).

  2. Anchored VWAP
  Второй VWAP с ручным якорем (по умолчанию — начало месяца). Удобно мерить среднюю цену от важного события: открытие недели/месяца, экстремум, новостной импульс.

  3. Session Volume Profile (кластеры объёма)
  Профиль объёма за текущую сессию, до 100 бинов:
  - POC — уровень максимального объёма, точка контроля (магнит цены).
  - VAH / VAL — границы зоны 70% объёма (Value Area).
  - HVN — узлы высокого объёма (зоны принятия цены → поддержка/сопротивление).
  - LVN — узлы низкого объёма, «пустоты» в распределении (цена проходит их быстро → зоны отбраковки).
  - Гистограмма объёма справа от свечей. 
  
  4. Killzones (опционально)
  Фоновая подсветка торговых сессий Frankfurt / London / NY (часовой пояс настраивается). По умолчанию выключено.

  Алерты

  VWAP touch · 2σ extreme · 3σ extreme (reversion zone) · POC test · VWAP reclaim (bull/bear). Каждый — отдельным переключателем, по умолчанию выключены.

  На каких инструментах работает лучше
  
  - Фьючерсы (NQ, ES, GER40/DAX и др.) и индексы CME — реальный биржевой объём, поэтому профиль и его уровни максимально надёжны. Основной кейс.
  - Forex — VWAP полностью валиден, но профиль строится на tick volume (число тиков, не контракты), поэтому уровни объёма — ориентир, а не истина.

  Как использовать

  1. Цена у VWAP — точка равновесия, у 2σ/3σ — зона перерастяжения.
  2. POC и HVN — уровни притяжения и реакции; LVN — зоны быстрого прохода.
  3. Reclaim VWAP — смена внутридневного контроля.

  ▎ Volume Profile рассчитывается для текущей сессии (исторические профили не отображаются — сделано ради производительности). Индикатор информационный, не является торговым сигналом.

## Source Code

````pine
//@version=5
// =============================================================================
// VWAP + Volume Clusters [Pro]
// Session VWAP (+σ bands) · Anchored VWAP · Session Volume Profile · Killzones
// База для intraday ТС: VWAP = institutional reference, volume clusters = POI.
// =============================================================================
indicator("VWAP + Volume Clusters [Pro]", overlay=true, max_lines_count=200, max_boxes_count=200, max_labels_count=50)

// =============================================================================
//                                 INPUTS
// =============================================================================

// ---------------------------- БЛОК 1: VWAP -----------------------------------
var string grpV = "VWAP"
vwapSrc   = input.source(hlc3,  "VWAP Source", group=grpV)

// ---------------------------- БЛОК 1: Bands ----------------------------------
var string grpB = "Bands"
showBand1 = input.bool(true,  "Show 1σ Band", group=grpB)
showBand2 = input.bool(true,  "Show 2σ Band", group=grpB)
showBand3 = input.bool(false, "Show 3σ Band", group=grpB)
mult1     = input.float(1.0, "1σ Multiplier", minval=0.1, step=0.1, group=grpB)
mult2     = input.float(2.0, "2σ Multiplier", minval=0.1, step=0.1, group=grpB)
mult3     = input.float(3.0, "3σ Multiplier", minval=0.1, step=0.1, group=grpB)

// ------------------------- БЛОК 2: Anchored VWAP -----------------------------
var string grpA = "Anchored VWAP"
showAVWAP   = input.bool(false, "Show Anchored VWAP", group=grpA)
avwapAnchor = input.time(timestamp("2026-05-01T00:00:00"), "Anchor Time (default = month start)", group=grpA)

// ------------------------- БЛОК 3: Volume Profile ----------------------------
var string grpVP = "Volume Profile"
showVP     = input.bool(true,  "Show Volume Profile", group=grpVP)
showHist   = input.bool(true,  "Show Histogram Bars", group=grpVP)
vpBins     = input.int(50, "Bins", minval=20, maxval=100, group=grpVP)
vaPercent  = input.float(70, "Value Area %", minval=1, maxval=99, group=grpVP)
histTransp = input.int(70, "Histogram Transparency", minval=0, maxval=100, group=grpVP)
histWidth  = input.int(30, "Histogram Width (bars)", minval=5, maxval=120, group=grpVP)
hvnCount   = input.int(3, "HVN count (excl. POC)", minval=0, maxval=10, group=grpVP)
lvnCount   = input.int(5, "LVN max count", minval=0, maxval=10, group=grpVP)
lvnThresh  = input.float(0.2, "LVN threshold (× POC vol)", minval=0.01, maxval=0.9, step=0.05, group=grpVP)

// ---------------------------- БЛОК 4: Sessions -------------------------------
var string grpS = "Sessions"
showKZ = input.bool(false, "Show Killzones", group=grpS)
tz     = input.string("Europe/Kiev", "Timezone", group=grpS)
ffSess = input.session("0900-1000", "Frankfurt", group=grpS)
loSess = input.session("1000-1400", "London",    group=grpS)
nySess = input.session("1500-1800", "New York",  group=grpS)

// ---------------------------- Alerts -----------------------------------------
var string grpAL = "Alerts"
alVWAPtouch = input.bool(false, "Alert: VWAP touch",  group=grpAL)
al2sigma    = input.bool(false, "Alert: 2σ extreme",  group=grpAL)
al3sigma    = input.bool(false, "Alert: 3σ extreme",  group=grpAL)
alPOC       = input.bool(false, "Alert: POC test",    group=grpAL)
alReclaim   = input.bool(false, "Alert: VWAP reclaim", group=grpAL)

// ---------------------------- Colors -----------------------------------------
var string grpC = "Colors"
colVWAP = input.color(#FFA726, "VWAP",          group=grpC)
colB1   = input.color(#4FC3F7, "Band 1σ",       group=grpC)
colB2   = input.color(#FFD54F, "Band 2σ",       group=grpC)
colB3   = input.color(#EF5350, "Band 3σ",       group=grpC)
colAV   = input.color(#D1D4DC, "Anchored VWAP", group=grpC)
colPOC  = input.color(#FFEB3B, "POC",           group=grpC)
colVA   = input.color(#FFD54F, "VAH / VAL",     group=grpC)
colHVN  = input.color(#B2B5BE, "HVN",           group=grpC)
colLVN  = input.color(#EC407A, "LVN",           group=grpC)
colHist = input.color(#4FC3F7, "Histogram",     group=grpC)
colFF   = input.color(#4FC3F7, "Frankfurt BG",  group=grpC)
colLO   = input.color(#66BB6A, "London BG",     group=grpC)
colNY   = input.color(#FFA726, "New York BG",   group=grpC)

// =============================================================================
//                         БЛОК 1 — SESSION VWAP + BANDS
// =============================================================================
// Якорь сессии: смена дня (для intraday это начало торговой сессии символа).
bool newSession = na(time("D")[1]) or time("D") != time("D")[1]

// ta.vwap с stdev_mult возвращает [vwap, upper, lower].
// Три вызова с одним якорем дают согласованные полосы для 1σ/2σ/3σ.
[vwapVal, b1u, b1l] = ta.vwap(vwapSrc, newSession, mult1)
[_v2,     b2u, b2l] = ta.vwap(vwapSrc, newSession, mult2)
[_v3,     b3u, b3l] = ta.vwap(vwapSrc, newSession, mult3)

plot(vwapVal, "VWAP", color=colVWAP, linewidth=2)

// Bands: plot не умеет dashed-линию для непрерывной серии,
// поэтому полосы рисуются полупрозрачными (transparency 50%).
plot(showBand1 ? b1u : na, "1σ Upper", color=color.new(colB1, 50))
plot(showBand1 ? b1l : na, "1σ Lower", color=color.new(colB1, 50))
plot(showBand2 ? b2u : na, "2σ Upper", color=color.new(colB2, 50))
plot(showBand2 ? b2l : na, "2σ Lower", color=color.new(colB2, 50))
plot(showBand3 ? b3u : na, "3σ Upper", color=color.new(colB3, 50))
plot(showBand3 ? b3l : na, "3σ Lower", color=color.new(colB3, 50))

// =============================================================================
//                       БЛОК 2 — ANCHORED VWAP (вторичный)
// =============================================================================
bool avStart = na(avwapAnchor) ? false : (time >= avwapAnchor and (na(time[1]) or time[1] < avwapAnchor))
avwapVal = ta.vwap(vwapSrc, avStart)
plot(showAVWAP ? avwapVal : na, "Anchored VWAP", color=colAV, linewidth=2)

// =============================================================================
//                       БЛОК 4 — KILLZONE SESSIONS (фон)
// =============================================================================
bool inFF = not na(time(timeframe.period, ffSess, tz))
bool inLO = not na(time(timeframe.period, loSess, tz))
bool inNY = not na(time(timeframe.period, nySess, tz))
bgcolor(showKZ and inFF ? color.new(colFF, 93) : na, title="Frankfurt KZ")
bgcolor(showKZ and inLO ? color.new(colLO, 93) : na, title="London KZ")
bgcolor(showKZ and inNY ? color.new(colNY, 93) : na, title="New York KZ")

// =============================================================================
//                  БЛОК 3 — SESSION VOLUME PROFILE (кластеры)
// =============================================================================
// Накапливаем сырые данные сессии (high/low/volume каждой свечи).
// Профиль строится из этих массивов на последнем (текущем) баре — это держит
// производительность: тяжёлый O(bars×bins) пересчёт идёт раз за тик, а не O(n²).
var array<float> barHi = array.new_float()
var array<float> barLo = array.new_float()
var array<float> barVo = array.new_float()
var int sessStartIdx   = 0
var float gPOC         = na   // POC текущей сессии — нужен для алерта

if newSession
    array.clear(barHi)
    array.clear(barLo)
    array.clear(barVo)
    sessStartIdx := bar_index

array.push(barHi, high)
array.push(barLo, low)
array.push(barVo, volume)

// Контейнеры для рисованных объектов (удаляем и перерисовываем при ребилде).
var array<box>  vpBoxes = array.new<box>()
var array<line> vpLines = array.new<line>()

clearDrawings() =>
    for b in vpBoxes
        box.delete(b)
    array.clear(vpBoxes)
    for l in vpLines
        line.delete(l)
    array.clear(vpLines)

if barstate.islast and showVP and array.size(barHi) > 0
    clearDrawings()
    float sHigh = array.max(barHi)
    float sLow  = array.min(barLo)
    float rng   = sHigh - sLow
    if rng > 0
        float binSize = rng / vpBins
        array<float> vols = array.new_float(vpBins, 0.0)
        int n = array.size(barHi)

        // --- распределяем объём каждой свечи по перекрытым бинам ---
        for i = 0 to n - 1
            float bh = array.get(barHi, i)
            float bl = array.get(barLo, i)
            float bv = array.get(barVo, i)
            int iLo = int(math.floor((bl - sLow) / binSize))
            int iHi = int(math.floor((bh - sLow) / binSize))
            iLo := math.max(0, math.min(vpBins - 1, iLo))
            iHi := math.max(0, math.min(vpBins - 1, iHi))
            int span = iHi - iLo + 1
            float share = bv / span
            for b = iLo to iHi
                array.set(vols, b, array.get(vols, b) + share)

        // --- POC и суммарный объём ---
        float maxV = 0.0
        int pocIdx = 0
        float totV = 0.0
        for b = 0 to vpBins - 1
            float v = array.get(vols, b)
            totV += v
            if v > maxV
                maxV := v
                pocIdx := b

        float pocPrice = sLow + (pocIdx + 0.5) * binSize
        gPOC := pocPrice

        // --- Value Area: расширяемся от POC, пока не наберём vaPercent% объёма ---
        float target = totV * vaPercent / 100.0
        int upIdx = pocIdx
        int dnIdx = pocIdx
        float acc = array.get(vols, pocIdx)
        while acc < target and (upIdx < vpBins - 1 or dnIdx > 0)
            float upV = upIdx < vpBins - 1 ? array.get(vols, upIdx + 1) : -1.0
            float dnV = dnIdx > 0          ? array.get(vols, dnIdx - 1) : -1.0
            if upV >= dnV
                upIdx += 1
                acc += upV
            else
                dnIdx -= 1
                acc += dnV
        float vah = sLow + (upIdx + 1) * binSize
        float val = sLow + dnIdx * binSize

        int rightX = bar_index + 2

        // --- histogram (горизонтальные бары справа от свечей) ---
        if showHist
            for b = 0 to vpBins - 1
                float v = array.get(vols, b)
                int len = maxV > 0 ? int(math.round(v / maxV * histWidth)) : 0
                if len > 0
                    float yTop = sLow + (b + 1) * binSize
                    float yBot = sLow + b * binSize
                    box bx = box.new(rightX, yTop, rightX + len, yBot, border_color=color.new(colHist, 100), bgcolor=color.new(colHist, histTransp))
                    array.push(vpBoxes, bx)

        // --- POC: жирная линия через весь график ---
        line pocL = line.new(sessStartIdx, pocPrice, bar_index, pocPrice, extend=extend.both, color=colPOC, width=2)
        array.push(vpLines, pocL)

        // --- VAH / VAL: пунктир, средняя толщина ---
        line vahL = line.new(sessStartIdx, vah, bar_index, vah, extend=extend.right, color=colVA, width=1, style=line.style_dashed)
        line valL = line.new(sessStartIdx, val, bar_index, val, extend=extend.right, color=colVA, width=1, style=line.style_dashed)
        array.push(vpLines, vahL)
        array.push(vpLines, valL)

        // --- HVN: топ-N нод кроме POC (тонкие сплошные) ---
        array<float> tmp = array.copy(vols)
        array.set(tmp, pocIdx, -1.0)
        for k = 0 to (hvnCount > 0 ? hvnCount - 1 : -1)
            float mv = -1.0
            int mi = -1
            for b = 0 to vpBins - 1
                if array.get(tmp, b) > mv
                    mv := array.get(tmp, b)
                    mi := b
            if mi >= 0 and mv > 0
                float hp = sLow + (mi + 0.5) * binSize
                line hl = line.new(sessStartIdx, hp, bar_index, hp, extend=extend.right, color=colHVN, width=1)
                array.push(vpLines, hl)
                array.set(tmp, mi, -1.0)

        // --- LVN: локальные минимумы распределения (пустоты), точечные линии ---
        int lvnDrawn = 0
        for b = 1 to vpBins - 2
            if lvnDrawn < lvnCount
                float v = array.get(vols, b)
                if v < array.get(vols, b - 1) and v < array.get(vols, b + 1) and v < maxV * lvnThresh and v > 0
                    float lp = sLow + (b + 0.5) * binSize
                    line ll = line.new(sessStartIdx, lp, bar_index, lp, extend=extend.right, color=colLVN, width=1, style=line.style_dotted)
                    array.push(vpLines, ll)
                    lvnDrawn += 1

// =============================================================================
//                                 ALERTS
// =============================================================================
bool vwapTouch  = low <= vwapVal and high >= vwapVal
bool sig2       = high >= b2u or low <= b2l
bool sig3       = high >= b3u or low <= b3l
bool pocTest    = not na(gPOC) and low <= gPOC and high >= gPOC
bool reclaimBull = close > vwapVal and close[1] <= vwapVal
bool reclaimBear = close < vwapVal and close[1] >= vwapVal

alertcondition(alVWAPtouch and vwapTouch,                 "VWAP touch",  "VWAP touch on {{ticker}} @ {{close}}")
alertcondition(al2sigma and sig2,                         "2σ extreme",  "Price at 2σ extreme on {{ticker}}")
alertcondition(al3sigma and sig3,                         "3σ extreme",  "Price at 3σ extreme on {{ticker}} — reversion zone")
alertcondition(alPOC and pocTest,                         "POC test",    "POC test on {{ticker}} @ {{close}}")
alertcondition(alReclaim and reclaimBull,                 "VWAP reclaim bull", "VWAP reclaim bull on {{ticker}} @ {{close}}")
alertcondition(alReclaim and reclaimBear,                 "VWAP reclaim bear", "VWAP reclaim bear on {{ticker}} @ {{close}}")
````
