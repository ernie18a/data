# CVD Chart (Overlay)

- url: https://www.tradingview.com/script/JpEDqTnN-cvd-chart-overlay/
- type: indicator
- pine_id: PUB;c7a90e0bc4b94e7cbb9059ceccc65bce
- version: 1.0

## Description

Вариант 1 — через меню индикатора:

На скрине я вижу у тебя сверху панели CVD есть тулбар: 👁 ⊕ {} 🗑 ⋯
Кликни на ⋯ (три точки в конце)
Выбери «Move pane up» или «Move to existing pane above» (на русском: «Переместить → Существующая панель выше»)
Повтори ещё раз, если CVD окажется в панели Delta Divergence — нужно его пропихнуть до самой верхней панели со свечами
Вариант 2 — простое перетаскивание:

Зажми левой кнопкой мыши на надпись «CVD Chart» в левом верхнем углу панели
Тяни вверх — поверх свечного графика
Отпусти — индикатор «прилипнет» к панели свечей
Вариант 3 — правый клик:

Правый клик на названии «CVD Chart» или на пустом месте панели CVD
«Move To» → «Existing Pane Above»
После перемещения возможен один момент
Когда CVD окажется на одной панели со свечами, TradingView попробует уместить и свечи (4670–4725), и зоны CVD (4640–4660) в одной шкале. Зоны рядом со свечами по высоте — всё должно влезть нормально.

Если вдруг свечи станут визуально «плоскими» (Y-axis растянется):

Правый клик на правой шкале цены (USD справа)
«Auto (Fits Data to Screen)» — TradingView пересчитает оптимальную высоту
Или «Scale Price Chart Only» — масштаб настроится только под свечи, зоны CVD «вылезут» вниз, но останутся на той же панели
Что мы получим в итоге
Картинка станет как в оригинале — на одном экране:

Свечи XAUUSD
LuxAlgo Liquidity Swings (красные/зеленые зоны)
VRVP (Volume Profile справа)
EMA 20/50/100/200
CVD-зоны прямо под минимумом сегмента, с метками Hi/Lo CVD
И там же — серый треугольник снизу свечи в момент начала нового дня (ресет CVD).

Покажи финальный скрин когда переместишь — посмотрим, нужно ли ещё что-то докрутить (цвета, высоту зон, gap).

## Source Code

````pine
//@version=5
indicator("CVD Chart (Overlay)", "CVD Chart",
     overlay           = true,
     max_lines_count   = 500,
     max_labels_count  = 500,
     max_boxes_count   = 500)

// ============================================================================
// CVD - Cumulative Volume Delta (Overlay)
//
// Recreates the visual style of the original TradingView CVD Chart indicator:
// the CVD oscillator is scaled into a green/red zone painted directly on the
// price chart, with Hi/Lo boundary lines, segment-Hi/Lo value labels and reset
// markers. Self-contained Pine v5 — no external libraries.
//
// One segment = the span between two resets (Daily by default).
// Inside each segment, CVD values are scaled so that ±globalMaxAbs (CVD range
// across all visible segments) maps to ±zoneH (half the zone height).
// ============================================================================


// ---------------------------- INPUTS ----------------------------
grpC = "Calculation"
resetMode = input.string("Daily", "Reset CVD",
     options = ["None", "Session", "Daily", "Weekly", "Monthly"], group = grpC)
ltfMode = input.string("Auto", "Lower timeframe",
     options = ["Auto", "1", "3", "5", "15"], group = grpC,
     tooltip = "Auto: 1m for ≤M15, 5m for ≤H1, 15m for higher.")
maxSegments = input.int(4, "Max visible segments",
     minval = 1, maxval = 20, group = grpC,
     tooltip = "Older segments are dropped to stay within Pine drawing limits.")
scalingMode = input.string("Per segment", "Zone scaling",
     options = ["Per segment", "Global"], group = grpC,
     tooltip = "Per segment: each zone is sized by its OWN price range — zones stay close to price even if some historical days were very volatile. Global: all zones share the same height (= biggest segment's range) — easier to compare visually, but old wild days inflate current zones and may push them off-screen.")

grpV = "Visuals"
zoneHeightPct = input.float(60, "Zone height (% of range)",
     minval = 10, maxval = 300, step = 10, group = grpV) / 100.0
zoneGapPct    = input.float(10, "Zone gap below price (% of zone height)",
     minval = 0, maxval = 200, step = 10, group = grpV,
     tooltip = "Empty space between the segment's price low and the top of the CVD zone.") / 100.0
lineType  = input.string("Line", "CVD style",
     options = ["Line", "Histogram"], group = grpV)
showBgArea    = input.bool(true,  "Background zones (up/down)",  group = grpV)
showHiLo      = input.bool(true,  "Hi/Lo boundary lines",        group = grpV)
showZero      = input.bool(true,  "Zero line",                   group = grpV)
showLabels    = input.bool(true,  "Hi/Lo CVD value labels",      group = grpV)
showResetMark = input.bool(true,  "Reset markers",               group = grpV)

upColor = input.color(color.new(#00C853, 30), "CVD up",     group = grpV, inline = "line")
dnColor = input.color(color.new(#FF1744, 30), "CVD down",   group = grpV, inline = "line")
upBg    = input.color(color.new(#00C853, 92), "Up zone",    group = grpV, inline = "bg")
dnBg    = input.color(color.new(#FF1744, 92), "Dn zone",    group = grpV, inline = "bg")
hiCol   = input.color(color.new(#00C853, 60), "Hi line",    group = grpV, inline = "hi")
loCol   = input.color(color.new(#FF1744, 60), "Lo line",    group = grpV, inline = "hi")
zeroCol = input.color(color.new(color.gray, 50), "Zero",    group = grpV)
labelSize = input.string("small", "Label size",
     options = ["tiny", "small", "normal", "large"], group = grpV)


// ---------------------------- HELPERS ----------------------------
autoLtf() =>
    int s = timeframe.in_seconds(timeframe.period)
    s <= 900 ? "1" : s <= 3600 ? "5" : "15"
string ltf = ltfMode == "Auto" ? autoLtf() : ltfMode

classifyVol() =>
    float u = 0.0
    float d = 0.0
    if close > open
        u := volume
    else if close < open
        d := volume
    else if close > close[1]
        u := volume
    else if close < close[1]
        d := volume
    else
        u := volume * 0.5
        d := volume * 0.5
    [u, d]

labelSz = labelSize == "tiny"   ? size.tiny   :
           labelSize == "small"  ? size.small  :
           labelSize == "normal" ? size.normal :
           size.large


// ---------------------------- DELTA & CVD ----------------------------
[upA, dnA] = request.security_lower_tf(syminfo.tickerid, ltf, classifyVol())
float upVol = array.size(upA) > 0 ? array.sum(upA) : 0.0
float dnVol = array.size(dnA) > 0 ? array.sum(dnA) : 0.0
float barDelta = upVol - dnVol

bool isReset = switch resetMode
    "None"    => false
    "Session" => session.isfirstbar_regular
    "Daily"   => timeframe.change("D")
    "Weekly"  => timeframe.change("W")
    "Monthly" => timeframe.change("M")
    => false

var float cvd = 0.0
if isReset
    cvd := 0.0
cvd += barDelta


// ---------------------------- SEGMENT METADATA ----------------------------
var array<int>   segStart  = array.new<int>()
var array<int>   segEnd    = array.new<int>()
var array<float> segPHi    = array.new<float>()
var array<float> segPLo    = array.new<float>()
var array<float> segCHi    = array.new<float>()
var array<float> segCLo    = array.new<float>()
var array<int>   segCHiBar = array.new<int>()
var array<int>   segCLoBar = array.new<int>()

bool isFirstBar = array.size(segStart) == 0
if isReset or isFirstBar
    array.push(segStart,  bar_index)
    array.push(segEnd,    bar_index)
    array.push(segPHi,    high)
    array.push(segPLo,    low)
    array.push(segCHi,    cvd)
    array.push(segCLo,    cvd)
    array.push(segCHiBar, bar_index)
    array.push(segCLoBar, bar_index)
else
    int n = array.size(segStart) - 1
    array.set(segEnd, n, bar_index)
    array.set(segPHi, n, math.max(array.get(segPHi, n), high))
    array.set(segPLo, n, math.min(array.get(segPLo, n), low))
    if cvd > array.get(segCHi, n)
        array.set(segCHi,    n, cvd)
        array.set(segCHiBar, n, bar_index)
    if cvd < array.get(segCLo, n)
        array.set(segCLo,    n, cvd)
        array.set(segCLoBar, n, bar_index)

// Trim oldest segments
while array.size(segStart) > maxSegments
    array.shift(segStart)
    array.shift(segEnd)
    array.shift(segPHi)
    array.shift(segPLo)
    array.shift(segCHi)
    array.shift(segCLo)
    array.shift(segCHiBar)
    array.shift(segCLoBar)


// ---------------------------- DRAWING POOLS ----------------------------
// Track every drawing we create so we can delete them all on the next render.
var array<line>  dynLines  = array.new<line>()
var array<box>   dynBoxes  = array.new<box>()
var array<label> dynLabels = array.new<label>()


// ---------------------------- RESET MARKERS ----------------------------
plotshape(showResetMark and isReset, "Reset",
     location = location.belowbar,
     color    = color.new(color.gray, 50),
     style    = shape.triangleup,
     size     = size.tiny)


// ---------------------------- RENDER ----------------------------
if barstate.islast
    // 1) Cleanup previous render so real-time ticks don't accumulate drawings.
    while array.size(dynLines) > 0
        line.delete(array.pop(dynLines))
    while array.size(dynBoxes) > 0
        box.delete(array.pop(dynBoxes))
    while array.size(dynLabels) > 0
        label.delete(array.pop(dynLabels))

    int nSeg = array.size(segStart)
    if nSeg > 0
        // 2) Pre-compute global max range / max |CVD| (used only when
        //    scalingMode == "Global"; per-segment mode ignores them).
        float globalMaxRange = 0.0
        float globalMaxAbs   = 0.0
        for i = 0 to nSeg - 1
            float r = array.get(segPHi, i) - array.get(segPLo, i)
            globalMaxRange := math.max(globalMaxRange, r)
            globalMaxAbs := math.max(globalMaxAbs, math.abs(array.get(segCHi, i)))
            globalMaxAbs := math.max(globalMaxAbs, math.abs(array.get(segCLo, i)))

        bool useGlobal = scalingMode == "Global"

        if (useGlobal ? globalMaxRange > 0 and globalMaxAbs > 0 : true)

            // 3) Render each segment.
            for i = 0 to nSeg - 1
                int   sBar    = array.get(segStart, i)
                int   eBar    = array.get(segEnd, i)
                float pHi     = array.get(segPHi, i)
                float pLo     = array.get(segPLo, i)
                float cHi     = array.get(segCHi, i)
                float cLo     = array.get(segCLo, i)
                int   cHiBar  = array.get(segCHiBar, i)
                int   cLoBar  = array.get(segCLoBar, i)

                // Pick scale for this segment.
                float segRange  = pHi - pLo
                float segMaxAbs = math.max(math.abs(cHi), math.abs(cLo))

                float useRange  = useGlobal ? globalMaxRange : segRange
                float useMaxAbs = useGlobal ? globalMaxAbs   : segMaxAbs

                if useRange <= 0 or useMaxAbs <= 0
                    continue

                float zoneH = useRange * zoneHeightPct * 0.5

                // Place the zone entirely below the segment's price low.
                float topOfZone = pLo - zoneH * zoneGapPct
                float botOfZone = topOfZone - 2.0 * zoneH
                float zeroLvl   = (topOfZone + botOfZone) * 0.5  // == topOfZone - zoneH

                // Background up/down zones.
                if showBgArea
                    box upBox = box.new(sBar, topOfZone, eBar, zeroLvl,
                         border_color = color(na), bgcolor = upBg)
                    box dnBox = box.new(sBar, zeroLvl, eBar, botOfZone,
                         border_color = color(na), bgcolor = dnBg)
                    array.push(dynBoxes, upBox)
                    array.push(dynBoxes, dnBox)

                // Zero line.
                if showZero
                    line zL = line.new(sBar, zeroLvl, eBar, zeroLvl,
                         color = zeroCol, style = line.style_dashed)
                    array.push(dynLines, zL)

                // Hi/Lo boundary lines.
                if showHiLo
                    line hL = line.new(sBar, topOfZone, eBar, topOfZone, color = hiCol)
                    line lL = line.new(sBar, botOfZone, eBar, botOfZone, color = loCol)
                    array.push(dynLines, hL)
                    array.push(dynLines, lL)

                // CVD line / histogram inside the segment.
                float prevLvl = na
                int   prevBr  = na
                for b = sBar to eBar
                    int lb = bar_index - b
                    if lb >= 0
                        float cv = cvd[lb]
                        if not na(cv)
                            float scaled = zeroLvl + (cv / useMaxAbs) * zoneH
                            color lc = scaled >= zeroLvl ? upColor : dnColor
                            line ln = na
                            if lineType == "Histogram"
                                ln := line.new(b, zeroLvl, b, scaled,
                                     color = lc, width = 2)
                            else if not na(prevLvl)
                                ln := line.new(prevBr, prevLvl, b, scaled,
                                     color = lc, width = 2)
                            if not na(ln)
                                array.push(dynLines, ln)
                            prevLvl := scaled
                            prevBr  := b

                // Hi/Lo CVD labels.
                if showLabels
                    float cHiScaled = zeroLvl + (cHi / useMaxAbs) * zoneH
                    float cLoScaled = zeroLvl + (cLo / useMaxAbs) * zoneH
                    label hL2 = label.new(cHiBar, cHiScaled,
                         str.tostring(cHi, format.volume),
                         color     = color(na),
                         textcolor = upColor,
                         style     = label.style_label_down,
                         size      = labelSz)
                    label lL2 = label.new(cLoBar, cLoScaled,
                         str.tostring(cLo, format.volume),
                         color     = color(na),
                         textcolor = dnColor,
                         style     = label.style_label_up,
                         size      = labelSz)
                    array.push(dynLabels, hL2)
                    array.push(dynLabels, lL2)


// ---------------------------- SANITY ----------------------------
if barstate.islast and ta.cum(volume) == 0
    runtime.error("No volume data available for this symbol. Try a different broker feed.")

if barstate.islast and timeframe.in_seconds(ltf) >= timeframe.in_seconds(timeframe.period)
    runtime.error("Lower timeframe (" + ltf + ") must be smaller than chart timeframe (" + timeframe.period + ").")
````
