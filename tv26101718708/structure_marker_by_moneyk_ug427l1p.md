# Structure Marker by MoneyK

- url: https://www.tradingview.com/script/ug427L1p/
- type: indicator
- pine_id: PUB;8f8ed81c9f9141c09197281c741faf42
- version: 2.0

## Description

Structure Marker by MoneyK

Structure Marker is a market-structure tool designed to make price action easier to read while keeping the chart clean.
It identifies structural swings as HH (Higher High), HL (Higher Low), LH (Lower High), and LL (Lower Low).
The most recent developing swing remains unlabeled while it is still active. Its HH, HL, LH, or LL classification is displayed only after the opposite swing confirms the structure. This is intended to distinguish completed structure from a pivot that may still extend.

Optional Support and Resistance
The indicator can also display one selected structural Support level and one selected structural Resistance level.
Rather than plotting every pivot, the S/R module evaluates structural candidates using several factors, including repeated reactions around a level, departure from the level, role changes between support and resistance, recency, proximity to current price, and wider structural pivots.
Only candidates that pass the confluence filter are displayed. This filtering is deterministic and does not represent a statistical probability or guarantee that price will react at a displayed level.
Support and Resistance are optional and are disabled by default.

How to use it
Use HH/HL/LH/LL to read the sequence of confirmed market structure. Optional Support and Resistance can be used as contextual areas to monitor alongside your own analysis.
Structure Marker does not generate BUY or SELL signals, trade entries, targets, stop losses, or alerts.

Limitations
Market structure is confirmed only after sufficient price development, so labels intentionally appear after the relevant swing has formed. Support and resistance levels are contextual references and can fail or be broken. This indicator should not be interpreted as a prediction of future price movement.

_______________________________
_______________________________

ESPAÑOL
Structure Marker es una herramienta de estructura de mercado diseñada para facilitar la lectura del precio manteniendo el gráfico limpio.
Identifica swings estructurales como HH, HL, LH y LL.
El swing más reciente permanece sin etiqueta mientras todavía está en formación. Su clasificación como HH, HL, LH o LL aparece únicamente cuando el swing contrario confirma la estructura. De esta manera se diferencia una estructura ya confirmada de un pivote que todavía puede extenderse.
El indicador también puede mostrar un Soporte y una Resistencia estructurales seleccionados. En lugar de dibujar todos los pivotes, evalúa candidatos mediante distintos factores estructurales, incluyendo reacciones repetidas, alejamiento del nivel, cambio de rol entre soporte y resistencia, recencia, cercanía al precio y pivotes estructurales de mayor amplitud.
Sólo se muestran los niveles que superan el filtro de confluencia. Este filtro no representa una probabilidad estadística ni garantiza que el precio vaya a reaccionar en el nivel.
Soporte y Resistencia son opcionales y vienen desactivados por defecto.
Structure Marker no genera señales BUY/SELL, entradas, objetivos, stop loss ni alertas.

## Source Code

````pine
//@version=6

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.

// © MoneyK

indicator("Structure Marker by MoneyK", max_lines_count=500, max_labels_count=500, max_bars_back=1000, overlay=true)

// Selective Structural Watch Levels

// Structure Marker displays confirmed market structure and optional filtered structural S/R levels.
// UPDATE · CONFIRMED PIVOTS
// Structural swing state now changes only on closed bars.
// Prevents provisional realtime HH/LH/HL/LL labels from appearing and disappearing intrabar.

// FIXED (NO USER INPUTS)

int    cnt   = 2

string style = line.style_solid

// BILINGUAL UI · ENGLISH DEFAULT

language = input.string("English", "Language / Idioma", options=["English", "Español"], display=display.none)

isEs = language == "Español"

const string SR_TOOLTIP = "EN: Shows one selected support and one selected resistance only when structural confluence is strong enough. Selection considers reactions, departure from the level, role flip, recency and proximity. This is not a statistical probability or a trading signal.\n\nES: Muestra un soporte y una resistencia seleccionados únicamente cuando existe suficiente confluencia estructural. La selección considera reacciones, salida del nivel, cambio de rol, recencia y cercanía. No representa una probabilidad estadística ni una señal de trading."

showS_R = input.bool(false, "Show Support/Resistance · Mostrar Soporte/Resistencia", tooltip=SR_TOOLTIP, display=display.none)

lineCol = color.new(color.white, 88)

pivotBg = color.new(color.black, 100)

pivotTx = color.white

supportBaseCol = color.rgb(40, 105, 190)

resistanceBaseCol = color.rgb(178, 76, 55)

supportStrongLineCol = color.new(supportBaseCol, 28)

resistanceStrongLineCol = color.new(resistanceBaseCol, 28)

supportStrongTagBg = color.new(supportBaseCol, 10)

resistanceStrongTagBg = color.new(resistanceBaseCol, 10)

srTagTx = color.white

var line[]  lines      = array.new<line>()

var label[] labels     = array.new<label>()

var int[]   pivotTypes = array.new<int>()

var float levelH  = high

var float levelL  = low

var int   countLL = 0

var int   countHH = 0

var int   dir     = 0

// FIXED SUPPORT/RESISTANCE SELECTION (NO USER INPUTS)

int   SR_PIVOT_LEFT         = 1

int   SR_PIVOT_RIGHT        = 1

int   SR_MAJOR_LEFT         = 8

int   SR_MAJOR_RIGHT        = 8

int   SR_MEMORY_LIMIT       = 240

int   SR_SCAN_LIMIT         = 160

int   SR_TAG_OFFSET         = 18

float SR_CLUSTER_ATR        = 0.16

float SR_BODY_SEPARATION_ATR = 0.03

float SR_MIN_DISTANCE_ATR   = 0.05

float SR_ROLE_FLIP_ATR      = 0.08

float SR_MAJOR_BONUS        = 6.0

float SR_MAX_DISTANCE_ATR   = 7.0

// SELECTIVE CONFLUENCE FILTER (FIXED · NO USER INPUTS)

float SR_FILTER_MIN_SCORE          = 17.0

int   SR_FILTER_MIN_REACTIONS      = 2

float SR_FILTER_MIN_DEPARTURE_ATR  = 0.65

int   SR_LOCAL_STRONG_REACTIONS       = 3

float SR_LOCAL_STRONG_DEPARTURE_ATR   = 0.90

// POST-SHOCK REBASE (FIXED · NO USER INPUTS)

int   SHOCK_REBASE_BARS      = 3

float SHOCK_RANGE_ATR        = 2.25

float SHOCK_MIN_BODY_SHARE   = 0.55

srAtr = math.max(nz(ta.atr(14), high - low), syminfo.mintick)

srPivotHigh = ta.pivothigh(high, SR_PIVOT_LEFT, SR_PIVOT_RIGHT)

srPivotLow  = ta.pivotlow(low, SR_PIVOT_LEFT, SR_PIVOT_RIGHT)

srMajorPivotHigh = ta.pivothigh(high, SR_MAJOR_LEFT, SR_MAJOR_RIGHT)

srMajorPivotLow  = ta.pivotlow(low, SR_MAJOR_LEFT, SR_MAJOR_RIGHT)

shockReferenceAtr = math.max(nz(srAtr[1], srAtr), syminfo.mintick)

shockRange = high - low

shockBody = math.abs(close - open)

shockDetected = barstate.isconfirmed and shockRange >= shockReferenceAtr * SHOCK_RANGE_ATR and shockBody >= shockRange * SHOCK_MIN_BODY_SHARE

var int shockRebaseRemaining = 0

var float[] srCandidateLevels = array.new<float>()

var int[]   srCandidateBars   = array.new<int>()

var int[]   srCandidateTypes  = array.new<int>()

var int[]   srCandidateSources = array.new<int>()

var int[]   srCandidateSpeeds = array.new<int>()

storeCandidate(candidateLevel, candidateBar, candidateType, candidateSource, candidateSpeed) =>

    bool found = false

    if array.size(srCandidateLevels) > 0

        for i = 0 to array.size(srCandidateLevels) - 1

            bool sameEvent = array.get(srCandidateBars, i) == candidateBar and

                 array.get(srCandidateTypes, i) == candidateType and

                 array.get(srCandidateSources, i) == candidateSource

            if sameEvent

                // A later 8/8 confirmation upgrades the original 1/1 event;

                // it does not create a second reaction at the same pivot.

                array.set(srCandidateSpeeds, i, math.max(array.get(srCandidateSpeeds, i), candidateSpeed))

                found := true

    if not found

        array.unshift(srCandidateLevels, candidateLevel)

        array.unshift(srCandidateBars, candidateBar)

        array.unshift(srCandidateTypes, candidateType)

        array.unshift(srCandidateSources, candidateSource)

        array.unshift(srCandidateSpeeds, candidateSpeed)

    true

if barstate.isconfirmed

    if not na(srPivotHigh)

        int pivotBar = bar_index - SR_PIVOT_RIGHT

        float bodyTop = math.max(open[SR_PIVOT_RIGHT], close[SR_PIVOT_RIGHT])

        storeCandidate(srPivotHigh, pivotBar, 1, 0, 0)

        if math.abs(srPivotHigh - bodyTop) >= srAtr[SR_PIVOT_RIGHT] * SR_BODY_SEPARATION_ATR

            storeCandidate(bodyTop, pivotBar, 1, 1, 0)

    if not na(srPivotLow)

        int pivotBar = bar_index - SR_PIVOT_RIGHT

        float bodyBottom = math.min(open[SR_PIVOT_RIGHT], close[SR_PIVOT_RIGHT])

        storeCandidate(srPivotLow, pivotBar, -1, 0, 0)

        if math.abs(srPivotLow - bodyBottom) >= srAtr[SR_PIVOT_RIGHT] * SR_BODY_SEPARATION_ATR

            storeCandidate(bodyBottom, pivotBar, -1, 1, 0)

    // Slower structural pivots reinforce levels that survive a wider context.

    // They complement the fast local layer; they do not replace it.

    if not na(srMajorPivotHigh)

        int pivotBar = bar_index - SR_MAJOR_RIGHT

        float bodyTop = math.max(open[SR_MAJOR_RIGHT], close[SR_MAJOR_RIGHT])

        storeCandidate(srMajorPivotHigh, pivotBar, 1, 0, 1)

        if math.abs(srMajorPivotHigh - bodyTop) >= srAtr[SR_MAJOR_RIGHT] * SR_BODY_SEPARATION_ATR

            storeCandidate(bodyTop, pivotBar, 1, 1, 1)

    if not na(srMajorPivotLow)

        int pivotBar = bar_index - SR_MAJOR_RIGHT

        float bodyBottom = math.min(open[SR_MAJOR_RIGHT], close[SR_MAJOR_RIGHT])

        storeCandidate(srMajorPivotLow, pivotBar, -1, 0, 1)

        if math.abs(srMajorPivotLow - bodyBottom) >= srAtr[SR_MAJOR_RIGHT] * SR_BODY_SEPARATION_ATR

            storeCandidate(bodyBottom, pivotBar, -1, 1, 1)

    while array.size(srCandidateLevels) > SR_MEMORY_LIMIT

        array.pop(srCandidateLevels)

        array.pop(srCandidateBars)

        array.pop(srCandidateTypes)

        array.pop(srCandidateSources)

        array.pop(srCandidateSpeeds)

candidateScore(candidateIndex, referenceClose, referenceAtr, scanCount, clusterTolerance) =>

    float candidateLevel = array.get(srCandidateLevels, candidateIndex)

    int candidateBar = array.get(srCandidateBars, candidateIndex)

    int candidateType = array.get(srCandidateTypes, candidateIndex)

    int candidateSource = array.get(srCandidateSources, candidateIndex)

    int candidateSpeed = array.get(srCandidateSpeeds, candidateIndex)

    float distanceAtr = math.abs(candidateLevel - referenceClose) / referenceAtr

    // Reactions are structural pivot events, not Retest Checker touches.

    // Wick and body anchors from the same pivot count only once.

    int reactions = 0

    int lastReactionBar = na

    for j = 0 to scanCount - 1

        float comparisonLevel = array.get(srCandidateLevels, j)

        int comparisonBar = array.get(srCandidateBars, j)

        if math.abs(comparisonLevel - candidateLevel) <= clusterTolerance and (na(lastReactionBar) or comparisonBar != lastReactionBar)

            reactions += 1

            lastReactionBar := comparisonBar

    // Measure the first structural departure after the candidate pivot.

    float departureAtr = 0.0

    int nearestNewerGap = 1000000

    for j = 0 to scanCount - 1

        int comparisonBar = array.get(srCandidateBars, j)

        int newerGap = comparisonBar - candidateBar

        if newerGap > 0 and newerGap <= nearestNewerGap

            float comparisonLevel = array.get(srCandidateLevels, j)

            if newerGap < nearestNewerGap

                nearestNewerGap := newerGap

                departureAtr := math.abs(comparisonLevel - candidateLevel) / referenceAtr

            else

                departureAtr := math.max(departureAtr, math.abs(comparisonLevel - candidateLevel) / referenceAtr)

    bool roleFlip = (candidateType == 1 and referenceClose > candidateLevel + referenceAtr * SR_ROLE_FLIP_ATR) or

         (candidateType == -1 and referenceClose < candidateLevel - referenceAtr * SR_ROLE_FLIP_ATR)

    int ageBars = math.max(bar_index - candidateBar, 0)

    float reactionScore = reactions * 3.25

    float departureScore = math.min(departureAtr, 4.0) * 1.75

    float roleFlipScore = roleFlip ? 4.0 : 0.0

    float bodyScore = candidateSource == 1 ? 1.15 : 0.0

    float majorScore = candidateSpeed == 1 ? SR_MAJOR_BONUS : 0.0

    float recencyScore = math.max(0.0, 3.0 - ageBars * 0.025)

    float proximityScore = 5.0 / (1.0 + distanceAtr)

    float score = reactionScore + departureScore + roleFlipScore + bodyScore + majorScore + recencyScore + proximityScore

    [score, reactions, departureAtr, roleFlip, distanceAtr]

// A level is shown only when several independent pieces of structural evidence agree.

// This is a deterministic confluence filter, not a measured win probability.

passesConfluenceFilter(candidateSpeed, score, reactions, departureAtr, roleFlip, distanceAtr) =>

    bool inRange = distanceAtr >= SR_MIN_DISTANCE_ATR and distanceAtr <= SR_MAX_DISTANCE_ATR

    bool enoughScore = score >= SR_FILTER_MIN_SCORE

    bool baseEvidence = reactions >= SR_FILTER_MIN_REACTIONS and departureAtr >= SR_FILTER_MIN_DEPARTURE_ATR

    bool majorConfluence = candidateSpeed == 1 and baseEvidence and (reactions >= SR_LOCAL_STRONG_REACTIONS or departureAtr >= 1.0 or roleFlip)

    bool localConfluence = candidateSpeed == 0 and reactions >= SR_LOCAL_STRONG_REACTIONS and departureAtr >= SR_LOCAL_STRONG_DEPARTURE_ATR and roleFlip

    inRange and enoughScore and (majorConfluence or localConfluence)

setProjectedLevel(ln, tagLabel, tagText, x, y, visible, supportSide) =>

    if visible

        line.set_xy1(ln, x, y)

        line.set_xy2(ln, x + 1, y)

        line.set_color(ln, supportSide ? supportStrongLineCol : resistanceStrongLineCol)

        line.set_width(ln, 1)

        label.set_xy(tagLabel, bar_index + SR_TAG_OFFSET, y)

        label.set_text(tagLabel, tagText)

        label.set_style(tagLabel, label.style_label_left)

        label.set_color(tagLabel, supportSide ? supportStrongTagBg : resistanceStrongTagBg)

        label.set_textcolor(tagLabel, srTagTx)

        label.set_size(tagLabel, size.small)

    else

        line.set_xy1(ln, bar_index, na)

        line.set_xy2(ln, bar_index + 1, na)

        label.set_xy(tagLabel, bar_index + SR_TAG_OFFSET, na)

        label.set_text(tagLabel, "")

pivotText(i) =>

    string txt = ""

    if array.size(labels) > i + 2 and array.size(pivotTypes) > i + 2

        cur  = array.get(labels, i)

        prv  = array.get(labels, i + 2)

        curY = label.get_y(cur)

        prvY = label.get_y(prv)

        pTyp = array.get(pivotTypes, i)

        txt := pTyp == 1 ? (curY > prvY ? "HH" : "LH") : pTyp == -1 ? (curY < prvY ? "LL" : "HL") : ""

    txt

refreshPivotLabels() =>

    if array.size(labels) > 0

        maxIdx = math.min(array.size(labels) - 1, 499)

        for i = 0 to maxIdx

            lb  = array.get(labels, i)

            // The newest pivot (index 0) is still active and may move.

            // Show HH/LH/HL/LL only after an opposite swing confirms it.

            txt = i == 0 ? "" : pivotText(i)

            label.set_text(lb, txt)

            label.set_color(lb, pivotBg)

            label.set_textcolor(lb, pivotTx)

            label.set_size(lb, size.small)

if array.size(lines) >= 496

    line.delete(array.pop(lines))

if array.size(labels) >= 496

    label.delete(array.pop(labels))

if array.size(pivotTypes) >= 496

    array.pop(pivotTypes)

if barstate.isfirst

    array.unshift(labels, label.new(bar_index, hl2, text="", style=label.style_label_left, color=pivotBg, textcolor=pivotTx, size=size.small))

    array.unshift(pivotTypes, 0)

// CONFIRMED-BAR STRUCTURE ENGINE
// Historical behavior is unchanged; realtime pivots commit only when the chart bar closes.
if barstate.isconfirmed
    if close < levelL

        countLL += 1

        if countLL == cnt

            countHH := 0

            countLL := 0

            levelL := low

            levelH := high

            if dir > -1

                array.unshift(labels, label.new(bar_index, low, text="", style=label.style_label_up, color=pivotBg, textcolor=pivotTx, size=size.small))

                array.unshift(pivotTypes, -1)

                if array.size(labels) > 1

                    array.unshift(lines, line.new(label.get_x(array.get(labels, 1)), label.get_y(array.get(labels, 1)), bar_index, low, color=lineCol, style=style))

                dir := -1

            else

                label.set_xy(array.get(labels, 0), bar_index, low)

                if array.size(lines) > 0

                    line.set_xy2(array.get(lines, 0), bar_index, low)

            if array.size(labels) > 2

                hi = low

                bx = 0

                for i = 0 to bar_index - label.get_x(array.get(labels, 2))

                    if high[i] > hi

                        hi := high[i]

                        bx := bar_index - i

                label.set_xy(array.get(labels, 1), bx, hi)

                if array.size(lines) > 1

                    line.set_xy2(array.get(lines, 1), bx, hi)

                    line.set_xy1(array.get(lines, 0), bx, hi)

    if close > levelH

        countHH += 1

        if countHH == cnt

            countHH := 0

            countLL := 0

            levelL := low

            levelH := high

            if dir < 1

                array.unshift(labels, label.new(bar_index, high, text="", style=label.style_label_down, color=pivotBg, textcolor=pivotTx, size=size.small))

                array.unshift(pivotTypes, 1)

                if array.size(labels) > 1

                    array.unshift(lines, line.new(label.get_x(array.get(labels, 1)), label.get_y(array.get(labels, 1)), bar_index, high, color=lineCol, style=style))

                dir := 1

            else

                label.set_xy(array.get(labels, 0), bar_index, high)

                if array.size(lines) > 0

                    line.set_xy2(array.get(lines, 0), bar_index, high)

            if array.size(labels) > 2

                lo = high

                bx = 0

                for i = 0 to bar_index - label.get_x(array.get(labels, 2))

                    if low[i] < lo

                        lo := low[i]

                        bx := bar_index - i

                label.set_xy(array.get(labels, 1), bx, lo)

                if array.size(lines) > 1

                    line.set_xy2(array.get(lines, 1), bx, lo)

                    line.set_xy1(array.get(lines, 0), bx, lo)

// A shock candle can leave the normal engine trapped inside an oversized

// confirmation range. After three closed post-shock candles, rebuild the

// working boundaries from the last two stabilized candles. Normal structure

// detection remains untouched outside this exceptional condition.

if barstate.isconfirmed

    if shockDetected

        shockRebaseRemaining := SHOCK_REBASE_BARS

    else if shockRebaseRemaining > 0

        shockRebaseRemaining -= 1

        if shockRebaseRemaining == 0

            levelH := math.max(high, high[1])

            levelL := math.min(low, low[1])

            countHH := 0

            countLL := 0

refreshPivotLabels()

var line l0 = line.new(na, na, na, na, extend=extend.right, style=line.style_dotted, color=supportStrongLineCol, width=1)

var line l1 = line.new(na, na, na, na, extend=extend.right, style=line.style_dotted, color=resistanceStrongLineCol, width=1)

var label tag0 = label.new(na, na, text="", style=label.style_label_left, color=supportStrongTagBg, textcolor=srTagTx, size=size.tiny)

var label tag1 = label.new(na, na, text="", style=label.style_label_left, color=resistanceStrongTagBg, textcolor=srTagTx, size=size.tiny)

if barstate.islast

    float referenceClose = (barstate.isconfirmed or bar_index == 0) ? close : close[1]

    float referenceAtr = math.max(nz((barstate.isconfirmed or bar_index == 0) ? srAtr : srAtr[1], srAtr), syminfo.mintick)

    float clusterTolerance = referenceAtr * SR_CLUSTER_ATR

    int scanCount = math.min(math.min(math.min(math.min(math.min(array.size(srCandidateLevels), array.size(srCandidateBars)), array.size(srCandidateTypes)), array.size(srCandidateSources)), array.size(srCandidateSpeeds)), SR_SCAN_LIMIT)

    float bestSupportLevel = na

    float bestResistanceLevel = na

    int bestSupportX = na

    int bestResistanceX = na

    float bestSupportScore = -1000000.0

    float bestResistanceScore = -1000000.0

    int bestSupportSpeed = -1

    int bestResistanceSpeed = -1

    if showS_R and scanCount > 0

        for i = 0 to scanCount - 1

            float candidateLevel = array.get(srCandidateLevels, i)

            int candidateX = array.get(srCandidateBars, i)

            int candidateSpeed = array.get(srCandidateSpeeds, i)

            [score, reactions, departureAtr, roleFlip, distanceAtr] = candidateScore(i, referenceClose, referenceAtr, scanCount, clusterTolerance)

            bool qualified = passesConfluenceFilter(candidateSpeed, score, reactions, departureAtr, roleFlip, distanceAtr)

            if qualified

                bool isSupport = candidateLevel < referenceClose

                bool isResistance = candidateLevel > referenceClose

                // Score decides. A confirmed 8/8 pivot breaks an exact score tie.

                bool betterSupport = isSupport and (na(bestSupportLevel) or score > bestSupportScore or (score == bestSupportScore and candidateSpeed > bestSupportSpeed))

                bool betterResistance = isResistance and (na(bestResistanceLevel) or score > bestResistanceScore or (score == bestResistanceScore and candidateSpeed > bestResistanceSpeed))

                if betterSupport

                    bestSupportLevel := candidateLevel

                    bestSupportX := candidateX

                    bestSupportScore := score

                    bestSupportSpeed := candidateSpeed

                if betterResistance

                    bestResistanceLevel := candidateLevel

                    bestResistanceX := candidateX

                    bestResistanceScore := score

                    bestResistanceSpeed := candidateSpeed

    string supportText = isEs ? "Soporte" : "Support"

    string resistanceText = isEs ? "Resistencia" : "Resistance"

    setProjectedLevel(l0, tag0, supportText, bestSupportX, bestSupportLevel, showS_R and not na(bestSupportLevel), true)

    setProjectedLevel(l1, tag1, resistanceText, bestResistanceX, bestResistanceLevel, showS_R and not na(bestResistanceLevel), false)

// DISCREET BRAND WATERMARK

var table watermarkTable = table.new(position.bottom_right, 1, 1, bgcolor=color.new(color.black, 100), border_width=0)

if barstate.islast

    table.cell(watermarkTable, 0, 0, "©Trading MoneyK's Way", text_color=color.new(color.white, 72), text_size=size.tiny, bgcolor=color.new(color.black, 100))
````
