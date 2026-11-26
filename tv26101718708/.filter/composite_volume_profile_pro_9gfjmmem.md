# Composite Volume Profile Pro

- url: https://www.tradingview.com/script/9GFJmmem/
- type: indicator
- pine_id: PUB;8274cbeef1f54d319c70b47970b4a7ad
- version: 1.0

## Description

# CVP Atlas — 5-Session Composite Volume Profile

## Description
CVP Atlas is a multi-session Volume Profile indicator designed to help traders identify key price levels and areas of interest at a glance.

It displays a composite profile across five sessions, highlighting the Point of Control (POC), Value Area High (VAH), Value Area Low (VAL), volume peaks and valleys, and low-volume areas.

The goal is to provide a clear view of volume distribution and help traders identify potential support and resistance zones.

## How to Use
1. Add CVP Atlas to your chart.
2. Select the session settings and time zone appropriate for your market.
3. Choose the volume allocation method. **OHLC Weighted** is the default setting and distributes volume across candle bodies and wicks using an approximation.
4. Use the POC to identify the profile's highest-volume price area.
5. Use VAH and VAL to identify the boundaries of the Value Area.
6. Observe volume peaks and valleys to locate areas of concentrated or limited volume.

Always verify the session settings, particularly when trading futures or markets with extended trading hours.

## Important Limitations — TradingView Basic
- **Estimated volume distribution:** OHLCV-based allocation methods do not provide true exchange-level volume-at-price data.
- **Intrabar data limits:** TradingView Basic may provide fewer historical intrabars, which can limit the available profile history and affect the completeness of the five-session composite.
- **Empty profile rows:** Some rows may appear empty because the selected allocation method assigns volume only to specific prices or distributes it differently. An empty row does not necessarily represent a true market inefficiency.
- **Session differences:** Incorrect session or time-zone settings may produce unexpected profile boundaries or results.

For more consistent results, use a sufficiently low chart timeframe, check your session settings, and avoid interpreting estimated low-volume areas as definitive trading signals.

CVP Atlas is an analytical tool, not a standalone trading system. Always combine it with price action and appropriate risk management.

## Source Code

````pine
//@version=6

indicator("CVP Atlas", "CVP Atlas", overlay = true, max_boxes_count = 500, max_lines_count = 100, max_labels_count = 50)

// ============================================================================

// CVP ATLAS — V9

// Automatic source, tick size and session handling where TradingView exposes it.

// AUTO follows the requested symbol's market session. RTH/custom are explicit

// alternatives because session definitions are instrument-specific.

// ============================================================================

groupCalc = "CALCULATION"

// 1 minute is the reference resolution. On sub-minute charts, use the chart

// resolution because security_lower_tf() cannot request a higher timeframe.

lookbackSessions = input.int(5, "Sessions", minval = 1, maxval = 5, group = groupCalc, display = display.none)
sourceMode = input.string("Chart Symbol", "Data Source", options = ["Chart Symbol", "Continuous Futures"], group = groupCalc, tooltip = "Chart Symbol uses the exact instrument shown on the chart. Continuous Futures uses the exchange root continuous contract and may differ around contract rolls.", display = display.none)

valueAreaPct = input.float(68.2, "Value Area (%)", minval = 50.0, maxval = 99.0, step = 0.1, group = groupCalc, display = display.none)

tickMode = input.string("Automatic", "Ticks per Row", options = ["Automatic", "Manual"], group = groupCalc, display = display.none)

manualTick = input.float(0.25, "Manual Tick Size", minval = 0.000001, step = 0.000001, group = groupCalc, display = display.none)

float tickSize = tickMode == "Automatic" ? syminfo.mintick : manualTick

allocation = input.string("OHLC Weighted", "Volume Allocation", options = ["OHLC Weighted", "Range", "Typical Price", "Close"], group = groupCalc, tooltip = "OHLC Weighted distributes each lower-timeframe bar volume across its candle body and wicks using a weighted range model inspired by common footprint approximations. Range spreads volume uniformly across the full high-low range. Typical Price and Close assign all volume to one price. All OHLCV-based methods are estimates, not exact exchange-level volume-at-price.", display = display.none)

sessionMode = input.string("Automatic", "Session", options = ["Automatic", "US RTH 09:30-16:00", "Custom"], group = groupCalc, display = display.none)

customSession = input.session("0930-1600", "Custom Session", group = groupCalc, display = display.none)

sessionTZ = input.string("America/New_York", "Custom/RTH Time Zone", options = ["America/New_York", "Europe/Rome", "Europe/London", "UTC", "Asia/Tokyo", "Asia/Singapore"], group = groupCalc, display = display.none)

fillVisualGaps = input.bool(false, "Visual Gap Filling", group = groupCalc, tooltip = "Optional visual bridge across empty display rows. Disabled by default so zero-volume rows remain visible; this setting never changes volume calculations.", display = display.none)

// --------------------------- Automatic source --------------------------------

// For futures, build the continuous contract from the exchange prefix + root.

// For all other asset types, keep the chart's own dataset because there is no

// universal continuous-contract convention outside futures.

string continuousSymbol = syminfo.prefix + ":" + syminfo.root + "1!"
string profileSymbol = syminfo.type == "futures" and sourceMode == "Continuous Futures" ? continuousSymbol : syminfo.tickerid

// --------------------------- Rendering ---------------------------------------

groupView = "DISPLAY"

rightOffset = input.int(55, "Right Offset", minval = 0, maxval = 499, group = groupView, tooltip = "Moves the profile farther into the chart area reserved to the right of the latest candles.", display = display.none)

profileWidth = input.int(130, "Profile Width", minval = 10, maxval = 300, group = groupView, display = display.none)

barThickness = input.float(110.0, "Profile Bar Thickness (%)", minval = 50.0, maxval = 140.0, step = 5.0, group = groupView, tooltip = "Controls the vertical thickness of each profile bar. Values above 100% create slight overlap; lower values create more separation.", display = display.none)

widthSensitivity = input.float(2.5, "Bar Visibility", minval = 1.0, maxval = 5.0, step = 0.25, group = groupView, tooltip = "Higher values widen low- and medium-volume bars without changing calculated volume. Maximum width remains Profile Width.", display = display.none)

maxRows = input.int(480, "Displayed Rows", minval = 50, maxval = 490, group = groupView, display = display.none)

showLevels = input.bool(true, "POC / VAH / VAL", group = groupView, display = display.none)

showInfo = input.bool(false, "Information Panel", group = groupView, display = display.none)
showLevelLabels = input.bool(true, "Show Level Labels", group = groupView, tooltip = "Displays labels identifying POC, VAH, VAL, Peaks, and Valleys.", display = display.none)

volumeColor = input.color(color.rgb(143, 188, 143), "Volume", group = groupView, display = display.none)

valueAreaColor = input.color(color.rgb(70, 130, 180), "Value Area", group = groupView, display = display.none)

pocColor = input.color(color.rgb(178, 0, 0), "POC", group = groupView, display = display.none)

levelColor = input.color(color.rgb(34, 139, 34), "VAH / VAL", group = groupView, display = display.none)

showPeaksValleys = input.bool(true, "Show Peaks and Valleys", group = groupView, display = display.none)
peakValleySensitivity = input.float(12.0, "Peak/Valley Sensitivity (%)", minval = 1.0, maxval = 30.0, step = 0.5, group = groupView, tooltip = "Higher values filter out minor peaks and valleys and show fewer, more significant levels.", display = display.none)
maxPeakValleyLevels = input.int(1, "Maximum Peak/Valley Levels per Type", minval = 1, maxval = 4, group = groupView, display = display.none)
peakValleyRadius = input.int(6, "Peak/Valley Detection Radius (Rows)", minval = 2, maxval = 12, group = groupView, tooltip = "A candidate must stand out against neighboring rows across this radius. Larger values suppress small, noisy fluctuations.", display = display.none)
peakColor = input.color(color.rgb(190, 35, 25), "Peak Color", group = groupView, display = display.none)
valleyColor = input.color(color.rgb(35, 150, 65), "Valley Color", group = groupView, display = display.none)

// --------------------------- Session container -------------------------------

type SessionData

    int id

    map<int, float> volumes

var map<int, float> composite = map.new<int, float>()

var array<SessionData> sessions = array.new<SessionData>()

var int activeSession = na

var bool wasInSession = false

priceToTick(float price) =>

    int(math.round(price / tickSize))

tickToPrice(int priceTick) =>

    priceTick * tickSize

addVolume(map<int, float> target, int priceTick, float amount) =>

    if amount > 0 and not na(priceTick)

        float old = target.get(priceTick)

        target.put(priceTick, na(old) ? amount : old + amount)

removeVolume(map<int, float> target, int priceTick, float amount) =>

    float old = target.get(priceTick)

    if not na(old)

        float remaining = old - amount

        if remaining <= 0.000001

            target.remove(priceTick)

        else

            target.put(priceTick, remaining)

// Distribute an amount evenly over every integer tick in an inclusive range.
addRangeVolume(map<int, float> target, int bottomTick, int topTick, float amount) =>
    if amount > 0 and topTick >= bottomTick
        int levelCount = topTick - bottomTick + 1
        float perLevel = amount / levelCount
        for priceTick = bottomTick to topTick
            addVolume(target, priceTick, perLevel)

// OHLC-weighted estimate inspired by candle-body/wick allocation models.
// This preserves the source bar's total volume, but does not reconstruct actual trades.
addWeightedBar(map<int, float> target, float o, float h, float l, float c, float vol) =>
    if vol > 0 and not na(o) and not na(h) and not na(l) and not na(c)
        float bodyTop = math.max(o, c)
        float bodyBottom = math.min(o, c)
        float body = bodyTop - bodyBottom
        float upperWick = math.max(0.0, h - bodyTop)
        float lowerWick = math.max(0.0, bodyBottom - l)
        float totalWeight = body + 2.0 * upperWick + 2.0 * lowerWick
        if totalWeight <= 0
            addVolume(target, priceToTick(c), vol)
        else
            if body > 0
                addRangeVolume(target, priceToTick(bodyBottom), priceToTick(bodyTop), vol * body / totalWeight)
            if upperWick > 0
                addRangeVolume(target, priceToTick(bodyTop), priceToTick(h), vol * 2.0 * upperWick / totalWeight)
            if lowerWick > 0
                addRangeVolume(target, priceToTick(l), priceToTick(bodyBottom), vol * 2.0 * lowerWick / totalWeight)

// --------------------------- Lower timeframe request -------------------------

float chartSeconds = timeframe.in_seconds()

bool tfIsValid = not na(chartSeconds)

if not tfIsValid

    runtime.error("CVP Atlas: unsupported non-time-based chart. Use a time-based chart timeframe.")

string effectiveTF = chartSeconds < 60 ? timeframe.period : "1"

[arrayTime, arrayOpen, arrayHigh, arrayLow, arrayClose, arrayVolume, arrayMarket, arrayFirstBar, arrayCustom] = request.security_lower_tf(

     profileSymbol,

     effectiveTF,

     [time, open, high, low, close, volume, session.ismarket, session.isfirstbar, not na(time("", customSession, sessionTZ))],

     ignore_invalid_symbol = true,

     ignore_invalid_timeframe = true,

     calc_bars_count = 100000)

// --------------------------- Build rolling sessions --------------------------

array<int> workTime = arrayTime

array<float> workOpen = arrayOpen

array<float> workHigh = arrayHigh

array<float> workLow = arrayLow

array<float> workClose = arrayClose

array<float> workVolume = arrayVolume

array<bool> workMarket = arrayMarket

array<bool> workFirstBar = arrayFirstBar

array<bool> workCustom = arrayCustom

int n = array.size(workTime)

if n > 0

    for i = 0 to n - 1

        int t = array.get(workTime, i)

        bool inSession = false

        bool newSession = false

        if sessionMode == "US RTH 09:30-16:00"

            int h = hour(t, sessionTZ)

            int m = minute(t, sessionTZ)

            inSession := (h > 9 or (h == 9 and m >= 30)) and (h < 16)

            newSession := inSession and (not wasInSession)

        else if sessionMode == "Custom"

            // Evaluated inside the requested lower-timeframe context.

            inSession := array.get(workCustom, i)

            newSession := inSession and (not wasInSession)

        else

            // Automatic: use the requested symbol's actual market-session flag.

            // This is intentionally not hardcoded to a specific asset class.

            inSession := array.get(workMarket, i)

            newSession := inSession and (not wasInSession or array.get(workFirstBar, i))

        if inSession

            if newSession

                activeSession := na(activeSession) ? 1 : activeSession + 1

                SessionData newSessionData = SessionData.new(activeSession, map.new<int, float>())

                sessions.push(newSessionData)

                if sessions.size() > lookbackSessions

                    SessionData oldSession = sessions.shift()

                    for [oldPrice, oldVol] in oldSession.volumes

                        removeVolume(composite, oldPrice, oldVol)

            wasInSession := true

            SessionData currentSession = sessions.get(sessions.size() - 1)

            float op = array.get(workOpen, i)

            float hi = array.get(workHigh, i)

            float lo = array.get(workLow, i)

            float cl = array.get(workClose, i)

            float vol = array.get(workVolume, i)

            if allocation == "OHLC Weighted" and vol > 0 and not na(op) and not na(hi) and not na(lo) and not na(cl)
                addWeightedBar(currentSession.volumes, op, hi, lo, cl, vol)
                addWeightedBar(composite, op, hi, lo, cl, vol)

            else if allocation == "Typical Price" and vol > 0 and not na(hi) and not na(lo) and not na(cl)

                // HLC3 is a more balanced bar-based proxy than assigning all volume to close.

                int p = priceToTick((hi + lo + cl) / 3.0)

                addVolume(currentSession.volumes, p, vol)

                addVolume(composite, p, vol)

            else if allocation == "Close" and vol > 0 and not na(cl)

                int p = priceToTick(cl)

                addVolume(currentSession.volumes, p, vol)

                addVolume(composite, p, vol)

            else if allocation == "Range" and vol > 0 and not na(hi) and not na(lo)

                int top = priceToTick(hi)

                int bot = priceToTick(lo)

                int levels = math.max(1, top - bot + 1)

                float perLevel = vol / levels

                for j = 0 to levels - 1

                    int p = bot + j

                    addVolume(currentSession.volumes, p, perLevel)

                    addVolume(composite, p, perLevel)

        else

            wasInSession := false

// --------------------------- Calculate POC / Value Area ----------------------

float poc = na

float pocVol = 0.0

float totalVol = 0.0

float profileHigh = na

float profileLow = na

array<int> sortedTicks = array.new<int>()

if composite.size() > 0

    sortedTicks := composite.keys()

    array.sort(sortedTicks, order.ascending)

    for priceTick in sortedTicks

        float p = tickToPrice(priceTick)

        float v = composite.get(priceTick)

        totalVol += v

        profileHigh := na(profileHigh) ? p : math.max(profileHigh, p)

        profileLow := na(profileLow) ? p : math.min(profileLow, p)

        if v > pocVol

            pocVol := v

            poc := p

float vah = na
float val = na

if not na(poc) and totalVol > 0 and sortedTicks.size() > 0

    // Walk only occupied price rows. This avoids allocating a potentially huge

    // dense array when the symbol has a fine tick size or a wide price range.

    int pocTick = priceToTick(poc)

    int pocIndex = sortedTicks.indexof(pocTick)

    float targetVA = totalVol * valueAreaPct / 100.0

    float accumulated = pocVol

    int upperIndex = pocIndex

    int lowerIndex = pocIndex

    while accumulated < targetVA and (upperIndex < sortedTicks.size() - 1 or lowerIndex > 0)

        float upVol = upperIndex < sortedTicks.size() - 1 ? composite.get(sortedTicks.get(upperIndex + 1)) : -1.0

        float dnVol = lowerIndex > 0 ? composite.get(sortedTicks.get(lowerIndex - 1)) : -1.0

        if dnVol > upVol

            lowerIndex -= 1

            accumulated += dnVol

        else

            upperIndex += 1

            accumulated += upVol

    vah := tickToPrice(sortedTicks.get(upperIndex))

    val := tickToPrice(sortedTicks.get(lowerIndex))

// --------------------------- Rendering ---------------------------------------

var array<box> profileBoxes = array.new<box>()

var line pocLine = na

var line vahLine = na

var line valLine = na

var label infoLabel = na
var array<line> peakValleyLines = array.new<line>()
var array<label> levelLabels = array.new<label>()

clearBoxes() =>

    int sz = profileBoxes.size()

    if sz > 0

        for k = 0 to sz - 1

            box.delete(profileBoxes.get(k))

        profileBoxes.clear()

if barstate.islast

    clearBoxes()
    if peakValleyLines.size() > 0
        for lineIndex = 0 to peakValleyLines.size() - 1
            line.delete(peakValleyLines.get(lineIndex))
        peakValleyLines.clear()
    if levelLabels.size() > 0
        for labelIndex = 0 to levelLabels.size() - 1
            label.delete(levelLabels.get(labelIndex))
        levelLabels.clear()

    if not na(poc) and composite.size() > 0 and not na(profileHigh) and not na(profileLow)

        int lowTick = sortedTicks.first()

        int highTick = sortedTicks.last()

        int exactRows = highTick - lowTick + 1

        int rows = math.min(maxRows, math.max(1, exactRows))

        float displayStep = rows > 1 ? (highTick - lowTick) * tickSize / (rows - 1) : tickSize

        displayStep := math.max(displayStep, tickSize)

        array<float> rowVol = array.new_float(rows, 0.0)

        array<float> rowPrice = array.new_float(rows, na)

        for [priceTick, v] in composite

            int tickOffset = priceTick - lowTick

            int idx = exactRows <= maxRows ? tickOffset : int(math.round(tickOffset * (rows - 1.0) / (exactRows - 1.0)))

            idx := math.max(0, math.min(rows - 1, idx))

            rowVol.set(idx, rowVol.get(idx) + v)

        float maxRowVol = 0.0

        for r = 0 to rows - 1

            int representativeTick = exactRows <= maxRows ? lowTick + r : lowTick + int(math.round(r * (exactRows - 1.0) / (rows - 1.0)))

            float rp = tickToPrice(representativeTick)

            rowPrice.set(r, rp)

            maxRowVol := math.max(maxRowVol, rowVol.get(r))

        int rightX = bar_index + rightOffset

        float rowHeight = displayStep * barThickness / 100.0

        for r = 0 to rows - 1

            float rv = rowVol.get(r)

            float renderVol = rv

            if fillVisualGaps and rv <= 0 and maxRowVol > 0

                int below = r - 1

                while below >= 0 and rowVol.get(below) <= 0

                    below -= 1

                int above = r + 1

                while above < rows and rowVol.get(above) <= 0

                    above += 1

                if below >= 0 and above < rows

                    renderVol := math.min(rowVol.get(below), rowVol.get(above)) * 0.08

            if renderVol > 0 and maxRowVol > 0

                float rp = rowPrice.get(r)

                float ratio = renderVol / maxRowVol

                // Visual compression widens smaller bars while preserving relative volume ordering.

                float visibleRatio = math.pow(math.min(1.0, ratio), 1.0 / widthSensitivity)

                int leftX = rightX - math.max(1, int(math.round(profileWidth * visibleRatio)))

                bool insideVA = rp >= val and rp <= vah

                color c = insideVA ? valueAreaColor : volumeColor

                int transp = rv <= 0 ? 94 : math.max(15, math.min(90, int(math.round(90 - 50 * math.min(1.0, ratio)))))

                box b = box.new(leftX, rp + rowHeight * 0.5, rightX, rp - rowHeight * 0.5, bgcolor = color.new(c, transp), border_color = na)

                profileBoxes.push(b)

        // Detect candidates on the displayed profile rows. When the profile is compressed
        // to fit Displayed Rows, these levels are visual approximations of the full tick grid.
        // Select prominent levels globally and suppress candidates near POC/VAH/VAL or
        // previously selected Peaks/Valleys to prevent clusters of nearly duplicate lines.
        if showPeaksValleys and rows > peakValleyRadius * 2 and maxRowVol > 0
            array<bool> peakCandidates = array.new_bool(rows, false)
            array<bool> valleyCandidates = array.new_bool(rows, false)
            array<float> peakScores = array.new_float(rows, 0.0)
            array<float> valleyScores = array.new_float(rows, 0.0)
            array<float> selectedLevels = array.new_float()
            float minProminence = peakValleySensitivity / 100.0
            float minPeakVolume = maxRowVol * 0.15
            for r = peakValleyRadius to rows - peakValleyRadius - 1
                float currentVol = rowVol.get(r)
                float neighborhoodMax = 0.0
                float neighborhoodMin = 1e20
                bool isStrictPeak = currentVol > 0
                bool isStrictValley = true
                for offset = 1 to peakValleyRadius
                    float leftVol = rowVol.get(r - offset)
                    float rightVol = rowVol.get(r + offset)
                    neighborhoodMax := math.max(neighborhoodMax, math.max(leftVol, rightVol))
                    neighborhoodMin := math.min(neighborhoodMin, math.min(leftVol, rightVol))
                    isStrictPeak := isStrictPeak and currentVol >= leftVol and currentVol >= rightVol
                    isStrictValley := isStrictValley and currentVol <= leftVol and currentVol <= rightVol
                float peakProminence = (currentVol - neighborhoodMin) / maxRowVol
                float valleyProminence = (neighborhoodMax - currentVol) / maxRowVol
                bool isPeak = isStrictPeak and currentVol >= minPeakVolume and peakProminence >= minProminence
                bool isValley = isStrictValley and neighborhoodMax >= minPeakVolume and valleyProminence >= minProminence
                peakCandidates.set(r, isPeak)
                valleyCandidates.set(r, isValley)
                peakScores.set(r, peakProminence)
                valleyScores.set(r, valleyProminence)

            float minSeparation = math.max(tickSize * peakValleyRadius * 6.0, displayStep * peakValleyRadius * 2.0)
            // Reserve space around the core profile levels before adding secondary levels.
            array<float> coreLevels = array.from(poc, vah, val)
            for selected = 0 to maxPeakValleyLevels - 1
                float bestScore = minProminence - 0.000001
                int bestIndex = -1
                for r = peakValleyRadius to rows - peakValleyRadius - 1
                    float candidatePrice = rowPrice.get(r)
                    bool separated = true
                    for corePrice in coreLevels
                        if not na(corePrice) and math.abs(candidatePrice - corePrice) < minSeparation
                            separated := false
                    for priorPrice in selectedLevels
                        if math.abs(candidatePrice - priorPrice) < minSeparation
                            separated := false
                    if peakCandidates.get(r) and peakScores.get(r) > bestScore and separated
                        bestScore := peakScores.get(r)
                        bestIndex := r
                if bestIndex >= 0
                    float levelPrice = rowPrice.get(bestIndex)
                    line peakLine = line.new(rightX - profileWidth, levelPrice, rightX, levelPrice, xloc = xloc.bar_index, extend = extend.none, color = peakColor, width = 1)
                    peakValleyLines.push(peakLine)
                    selectedLevels.push(levelPrice)
                    if showLevelLabels
                        label peakLabel = label.new(rightX, levelPrice, "PEAK " + str.tostring(levelPrice, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = peakColor, textcolor = color.white, size = size.tiny)
                        levelLabels.push(peakLabel)
                    for r = 0 to rows - 1
                        if math.abs(rowPrice.get(r) - levelPrice) <= minSeparation
                            peakCandidates.set(r, false)

            for selected = 0 to maxPeakValleyLevels - 1
                float bestScore = minProminence - 0.000001
                int bestIndex = -1
                for r = peakValleyRadius to rows - peakValleyRadius - 1
                    float candidatePrice = rowPrice.get(r)
                    bool separated = true
                    for corePrice in coreLevels
                        if not na(corePrice) and math.abs(candidatePrice - corePrice) < minSeparation
                            separated := false
                    for priorPrice in selectedLevels
                        if math.abs(candidatePrice - priorPrice) < minSeparation
                            separated := false
                    if valleyCandidates.get(r) and valleyScores.get(r) > bestScore and separated
                        bestScore := valleyScores.get(r)
                        bestIndex := r
                if bestIndex >= 0
                    float levelPrice = rowPrice.get(bestIndex)
                    line valleyLine = line.new(rightX - profileWidth, levelPrice, rightX, levelPrice, xloc = xloc.bar_index, extend = extend.none, color = valleyColor, width = 1)
                    peakValleyLines.push(valleyLine)
                    selectedLevels.push(levelPrice)
                    if showLevelLabels
                        label valleyLabel = label.new(rightX, levelPrice, "VALLEY " + str.tostring(levelPrice, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = valleyColor, textcolor = color.white, size = size.tiny)
                        levelLabels.push(valleyLabel)
                    for r = 0 to rows - 1
                        if math.abs(rowPrice.get(r) - levelPrice) <= minSeparation
                            valleyCandidates.set(r, false)

        if showLevels

            if na(pocLine)

                pocLine := line.new(bar_index, poc, rightX, poc, xloc = xloc.bar_index, extend = extend.left, color = pocColor, width = 2)

            else

                line.set_xy1(pocLine, bar_index, poc), line.set_xy2(pocLine, rightX, poc), line.set_color(pocLine, pocColor), line.set_width(pocLine, 2), line.set_extend(pocLine, extend.left)

            if na(vahLine)

                vahLine := line.new(bar_index, vah, rightX, vah, xloc = xloc.bar_index, extend = extend.left, color = levelColor, width = 1)

            else

                line.set_xy1(vahLine, bar_index, vah), line.set_xy2(vahLine, rightX, vah), line.set_color(vahLine, levelColor), line.set_width(vahLine, 1), line.set_extend(vahLine, extend.left)

            if na(valLine)

                valLine := line.new(bar_index, val, rightX, val, xloc = xloc.bar_index, extend = extend.left, color = levelColor, width = 1)

            else

                line.set_xy1(valLine, bar_index, val), line.set_xy2(valLine, rightX, val), line.set_color(valLine, levelColor), line.set_width(valLine, 1), line.set_extend(valLine, extend.left)

            if showLevelLabels
                label pocLabel = label.new(rightX, poc, "POC " + str.tostring(poc, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = pocColor, textcolor = color.white, size = size.tiny)
                label vahLabel = label.new(rightX, vah, "VAH " + str.tostring(vah, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = levelColor, textcolor = color.white, size = size.tiny)
                label valLabel = label.new(rightX, val, "VAL " + str.tostring(val, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = levelColor, textcolor = color.white, size = size.tiny)
                levelLabels.push(pocLabel)
                levelLabels.push(vahLabel)
                levelLabels.push(valLabel)

        else

            if not na(pocLine)

                line.delete(pocLine), pocLine := na

            if not na(vahLine)

                line.delete(vahLine), vahLine := na

            if not na(valLine)

                line.delete(valLine), valLine := na

        if showInfo

            string sessionText = sessionMode == "Automatic" ? "Automatic Symbol Session" : sessionMode

            string txt = "CVP Atlas V9 | " +

                 "Sessions: " + str.tostring(sessions.size()) + " | Rows: " + str.tostring(composite.size()) + "\n" +

                 "POC: " + str.tostring(poc, format.mintick) + "\n" +

                 "VAH: " + str.tostring(vah, format.mintick) + "\n" +

                 "VAL: " + str.tostring(val, format.mintick) + "\n" +

                 "Tick Size: " + str.tostring(tickSize) + "\n" +

                 "Allocation: " + allocation + " (estimate)\n" +

                 "Session: " + sessionText + "\n" +

                 "Source: " + profileSymbol + "\n" +

                 "Data Timeframe: " + effectiveTF

            if na(infoLabel)

                infoLabel := label.new(rightX, profileLow - displayStep * 2.0, txt, xloc = xloc.bar_index, style = label.style_label_left, textcolor = color.gray, color = color.new(color.white, 100), size = size.small)

            else

                label.set_xy(infoLabel, rightX, profileLow - displayStep * 2.0), label.set_text(infoLabel, txt)

        else if not na(infoLabel)

            label.delete(infoLabel), infoLabel := na

if barstate.islast and (na(poc) or composite.size() == 0)

    clearBoxes()

    if not na(pocLine)

        line.delete(pocLine), pocLine := na

    if not na(vahLine)

        line.delete(vahLine), vahLine := na

    if not na(valLine)

        line.delete(valLine), valLine := na

    if not na(infoLabel)

        label.delete(infoLabel), infoLabel := na
````
