# SLTP AMT Flow Coach Futures

- url: https://www.tradingview.com/script/fTpFTks4-SLTP-AMT-Flow-Coach-Futures/
- type: indicator
- pine_id: PUB;8c74207ab3be4a4db6573b15391c77c2
- version: 2.0

## Description

Educational AMT and order-flow indicator for COMEX Gold (GC/MGC) and CME Nasdaq-100 (NQ/MNQ) futures. It uses TradingView's native volume-footprint data to display a session profile (VAH, POC, VAL), bar delta, cumulative volume delta (CVD), an approximate nearest HVN/LVN, possible absorption areas, and confirmation-based LONG/SHORT candidates with illustrative entry, invalidation, and target levels.

The script does not place orders or calculate position size. Its signals are rule-based candidates, not guaranteed outcomes. The session profile resets at the symbol's daily session boundary and does not separate RTH from overnight. HVN is represented by the profile POC; LVN is a local volume trough estimate.

Requires a TradingView Premium or Ultimate plan for footprint requests. Real-time CME/COMEX data may require a separate exchange data subscription. Test in Bar Replay or paper trading and review all levels before use.

## Source Code

````pine
//@version=6
indicator("AMT SL/TP Flow Coach • Futures", shorttitle = "SL/TP Flow", overlay = true, max_labels_count = 100, max_boxes_count = 500)

// Educational AMT/order-flow assistant for GC/MGC and NQ/MNQ futures charts.
// Use on a liquid futures chart, such as COMEX:GC1! or CME_MINI:NQ1!.
// The script does not place orders. Signals are rule-based candidates, not trade recommendations.

// ─── Inputs ──────────────────────────────────────────────────────────────────
string grpFlow = "01 • Footprint & order flow"
int rowTicks = input.int(4, "Footprint row size (ticks)", minval = 1, maxval = 100, group = grpFlow,
     tooltip = "Tick rows used by TradingView's native footprint. Start with 4 and adjust for the chart timeframe.")
int vaPercent = input.int(70, "Value area (%)", minval = 50, maxval = 90, group = grpFlow)
int imbalancePercent = input.int(300, "Diagonal imbalance (%)", minval = 100, maxval = 1000, step = 25, group = grpFlow)
int cvdReset = input.string("Daily", "CVD reset", options = ["Daily", "Never"], group = grpFlow) == "Daily" ? 1 : 0

string grpSetup = "02 • Setup filters"
int swingLookback = input.int(10, "Swing lookback", minval = 3, maxval = 50, group = grpSetup)
int confirmBars = input.int(4, "Bars allowed for confirmation", minval = 1, maxval = 12, group = grpSetup)
int volumeLength = input.int(20, "Average footprint volume length", minval = 5, maxval = 100, group = grpSetup)
float volumeMultiple = input.float(1.30, "High-volume threshold × average", minval = 1.0, maxval = 4.0, step = 0.05, group = grpSetup)
float deltaThreshold = input.float(0.25, "Minimum |delta| / volume", minval = 0.05, maxval = 0.90, step = 0.05, group = grpSetup)
float nearAtr = input.float(0.30, "Near-level distance (ATR)", minval = 0.05, maxval = 1.5, step = 0.05, group = grpSetup)

string grpDisplay = "03 • Display"
bool showProfile = input.bool(true, "Show session VAH / VAL / POC", group = grpDisplay)
bool showNodes = input.bool(true, "Show nearest HVN / LVN", group = grpDisplay)
bool showVolumeProfile = input.bool(true, "Show session volume profile", group = grpDisplay)
string profileSide = input.string("Right", "Profile position", options = ["Left", "Right"], group = grpDisplay)
int profileWidth = input.int(16, "Profile maximum width (bars)", minval = 6, maxval = 60, group = grpDisplay)
int profileOffset = input.int(2, "Profile distance from chart edge (bars)", minval = 0, maxval = 50, group = grpDisplay)
int profileTransparency = input.int(48, "Profile transparency", minval = 0, maxval = 90, group = grpDisplay)
bool showPlan = input.bool(true, "Show latest entry / stop / target plan", group = grpDisplay)
bool showDashboard = input.bool(true, "Show compact dashboard", group = grpDisplay)
bool showAbsorptionMarks = input.bool(true, "Mark possible absorption", group = grpDisplay)

string grpStyle = "04 • Colors & style"
color valueAreaColor = input.color(color.rgb(31, 200, 220), "Value area profile", group = grpStyle)
color outsideValueColor = input.color(color.rgb(71, 98, 130), "Outside value profile", group = grpStyle)
color pocColor = input.color(color.rgb(183, 102, 255), "POC / main HVN", group = grpStyle)
color valueLinesColor = input.color(color.rgb(60, 214, 230), "VAH / VAL lines", group = grpStyle)
color lvnLineColor = input.color(color.rgb(255, 174, 66), "LVN line", group = grpStyle)
color entryLineColor = input.color(color.rgb(235, 242, 255), "Entry line", group = grpStyle)
color stopLineColor = input.color(color.rgb(255, 91, 118), "Invalidation line", group = grpStyle)
color targetLineColor = input.color(color.rgb(90, 230, 160), "Target line", group = grpStyle)
color bullMarkColor = input.color(color.rgb(48, 224, 190), "Bullish signal marks", group = grpStyle)
color bearMarkColor = input.color(color.rgb(255, 91, 118), "Bearish signal marks", group = grpStyle)
int profileLineWidth = input.int(1, "VAH / VAL / LVN line width", minval = 1, maxval = 3, group = grpStyle)
int pocLineWidth = input.int(2, "POC line width", minval = 1, maxval = 4, group = grpStyle)
bool autoThemeColors = input.bool(true, "Adapt colors to chart theme", group = grpStyle,
     tooltip = "Automatically selects a high-contrast palette for light and dark chart themes. Turn off to use the custom colors above.")

bool lightChart = chart.fg_color == color.rgb(15, 15, 15)
color activeValueAreaColor = autoThemeColors ? (lightChart ? color.rgb(0, 132, 158) : color.rgb(31, 200, 220)) : valueAreaColor
color activeOutsideValueColor = autoThemeColors ? (lightChart ? color.rgb(111, 127, 148) : color.rgb(71, 98, 130)) : outsideValueColor
color activePocColor = autoThemeColors ? (lightChart ? color.rgb(126, 57, 177) : color.rgb(183, 102, 255)) : pocColor
color activeValueLinesColor = autoThemeColors ? (lightChart ? color.rgb(0, 126, 150) : color.rgb(60, 214, 230)) : valueLinesColor
color activeLvnLineColor = autoThemeColors ? (lightChart ? color.rgb(190, 106, 0) : color.rgb(255, 174, 66)) : lvnLineColor
color activeEntryLineColor = autoThemeColors ? (lightChart ? color.rgb(39, 78, 135) : color.rgb(235, 242, 255)) : entryLineColor
color activeStopLineColor = autoThemeColors ? (lightChart ? color.rgb(196, 45, 70) : color.rgb(255, 91, 118)) : stopLineColor
color activeTargetLineColor = autoThemeColors ? (lightChart ? color.rgb(0, 125, 82) : color.rgb(90, 230, 160)) : targetLineColor
color activeBullMarkColor = autoThemeColors ? (lightChart ? color.rgb(0, 125, 111) : color.rgb(48, 224, 190)) : bullMarkColor
color activeBearMarkColor = autoThemeColors ? (lightChart ? color.rgb(196, 45, 70) : color.rgb(255, 91, 118)) : bearMarkColor

// ─── Native footprint data ───────────────────────────────────────────────────
footprint fp = request.footprint(rowTicks, vaPercent, imbalancePercent)
bool hasFp = not na(fp)
float barDelta = hasFp ? fp.delta() : na
float barVolume = hasFp ? fp.total_volume() : na
float deltaShare = not na(barVolume) and barVolume > 0 ? barDelta / barVolume : na

// The session profile is assembled from native footprint rows.
// It resets at the chart symbol's daily session boundary.
float rowStep = syminfo.mintick * rowTicks
var map<int, float> sessionProfile = map.new<int, float>()
bool newSession = timeframe.change("1D")
if newSession
    sessionProfile.clear()

if barstate.isconfirmed and hasFp and rowStep > 0
    for row in fp.rows()
        int bin = int(math.floor(row.down_price() / rowStep + 0.000001))
        float oldVolume = sessionProfile.contains(bin) ? sessionProfile.get(bin) : 0.0
        sessionProfile.put(bin, oldVolume + row.total_volume())

// ─── Session profile: POC, value area, HVN and a nearby LVN ──────────────────
float sessionPoc = na
float sessionVah = na
float sessionVal = na
float nearestHvn = na
float nearestLvn = na
int binCount = sessionProfile.size()
var array<box> profileBoxes = array.new<box>()

if barstate.islast
    while array.size(profileBoxes) > 0
        box.delete(array.pop(profileBoxes))

if binCount > 0
    array<int> bins = sessionProfile.keys()
    array.sort(bins, order.ascending)
    int pocIndex = 0
    float totalProfileVolume = 0.0
    float maxBinVolume = -1.0
    for i = 0 to binCount - 1
        int key = bins.get(i)
        float v = sessionProfile.get(key)
        totalProfileVolume += v
        if v > maxBinVolume
            maxBinVolume := v
            pocIndex := i

    int leftIndex = pocIndex
    int rightIndex = pocIndex
    float includedVolume = maxBinVolume
    float targetVolume = totalProfileVolume * vaPercent / 100.0
    int safety = 0
    while includedVolume < targetVolume and (leftIndex > 0 or rightIndex < binCount - 1) and safety < binCount
        safety += 1
        float belowVolume = leftIndex > 0 ? sessionProfile.get(bins.get(leftIndex - 1)) : -1.0
        float aboveVolume = rightIndex < binCount - 1 ? sessionProfile.get(bins.get(rightIndex + 1)) : -1.0
        if aboveVolume > belowVolume
            rightIndex += 1
            includedVolume += aboveVolume
        else
            leftIndex -= 1
            includedVolume += belowVolume

    int pocBin = bins.get(pocIndex)
    int lowBin = bins.get(leftIndex)
    int highBin = bins.get(rightIndex)
    sessionPoc := (pocBin + 0.5) * rowStep
    sessionVal := lowBin * rowStep
    sessionVah := (highBin + 1.0) * rowStep
    nearestHvn := sessionPoc

    // A local volume trough is a practical LVN candidate, not a guaranteed reaction level.
    if binCount >= 3
        float closestDistance = na
        for i = 1 to binCount - 2
            float prevV = sessionProfile.get(bins.get(i - 1))
            float thisV = sessionProfile.get(bins.get(i))
            float nextV = sessionProfile.get(bins.get(i + 1))
            bool localTrough = thisV < prevV and thisV < nextV
            float nodePrice = (bins.get(i) + 0.5) * rowStep
            float distance = math.abs(close - nodePrice)
            if localTrough and (na(closestDistance) or distance < closestDistance)
                closestDistance := distance
                nearestLvn := nodePrice

    // Draw a compact, automatically scaled histogram from the current session's footprint rows.
    // Adjacent rows are grouped only when needed to stay below the drawing-object limit.
    if showVolumeProfile and barstate.islast
        int maxProfileRows = 250
        int rowsPerBox = int(math.ceil(binCount / float(maxProfileRows)))
        int boxCount = int(math.ceil(binCount / float(rowsPerBox)))
        float maxGroupedVolume = 0.0
        for groupIndex = 0 to boxCount - 1
            int firstIndex = groupIndex * rowsPerBox
            int lastIndex = math.min(firstIndex + rowsPerBox - 1, binCount - 1)
            float groupedVolume = 0.0
            for rowIndex = firstIndex to lastIndex
                groupedVolume += sessionProfile.get(bins.get(rowIndex))
            maxGroupedVolume := math.max(maxGroupedVolume, groupedVolume)

        int barDurationMs = int(timeframe.in_seconds() * 1000)
        int visibleLeftTime = chart.left_visible_bar_time
        int visibleRightTime = chart.right_visible_bar_time
        int anchorTime = profileSide == "Right" ? visibleRightTime - profileOffset * barDurationMs : visibleLeftTime + profileOffset * barDurationMs
        for groupIndex = 0 to boxCount - 1
            int firstIndex = groupIndex * rowsPerBox
            int lastIndex = math.min(firstIndex + rowsPerBox - 1, binCount - 1)
            int firstBin = bins.get(firstIndex)
            int lastBin = bins.get(lastIndex)
            float groupedVolume = 0.0
            for rowIndex = firstIndex to lastIndex
                groupedVolume += sessionProfile.get(bins.get(rowIndex))
            int widthBars = maxGroupedVolume > 0 ? math.max(1, int(math.round(groupedVolume / maxGroupedVolume * profileWidth))) : 1
            int leftTime = profileSide == "Right" ? anchorTime - widthBars * barDurationMs : anchorTime
            int rightTime = profileSide == "Right" ? anchorTime : anchorTime + widthBars * barDurationMs
            float rowBottom = firstBin * rowStep
            float rowTop = (lastBin + 1.0) * rowStep
            float rowMid = (rowBottom + rowTop) * 0.5
            bool isPocGroup = pocBin >= firstBin and pocBin <= lastBin
            bool isValueArea = rowMid >= sessionVal and rowMid <= sessionVah
            color baseColor = isPocGroup ? activePocColor : isValueArea ? activeValueAreaColor : activeOutsideValueColor
            color fillColor = color.new(baseColor, profileTransparency)
            box profileRow = box.new(leftTime, rowTop, rightTime, rowBottom, xloc = xloc.bar_time,
                 border_color = color.new(baseColor, 100), bgcolor = fillColor)
            array.push(profileBoxes, profileRow)

// ─── CVD, absorption candidates, and confirmation logic ──────────────────────
var float cvd = 0.0
if newSession and cvdReset == 1
    cvd := 0.0
if barstate.isconfirmed and hasFp and not na(barDelta)
    cvd += barDelta

float atr = ta.atr(14)
float candleRange = math.max(high - low, syminfo.mintick)
float closeLocation = (close - low) / candleRange
float averageFootprintVolume = ta.sma(barVolume, volumeLength)
bool highVolume = not na(averageFootprintVolume) and not na(barVolume) and barVolume >= averageFootprintVolume * volumeMultiple
bool strongSelling = not na(deltaShare) and deltaShare <= -deltaThreshold
bool strongBuying = not na(deltaShare) and deltaShare >= deltaThreshold
bool nearVal = not na(sessionVal) and low <= sessionVal + atr * nearAtr
bool nearVah = not na(sessionVah) and high >= sessionVah - atr * nearAtr
bool nearLvnLow = not na(nearestLvn) and low <= nearestLvn + atr * nearAtr and high >= nearestLvn - atr * nearAtr
bool nearHvnHigh = not na(nearestHvn) and low <= nearestHvn + atr * nearAtr and high >= nearestHvn - atr * nearAtr
float priorSwingLow = ta.lowest(low[1], swingLookback)
float priorSwingHigh = ta.highest(high[1], swingLookback)
bool sweptLow = low < priorSwingLow and close > priorSwingLow
bool sweptHigh = high > priorSwingHigh and close < priorSwingHigh

bool bullAbsorption = hasFp and highVolume and strongSelling and closeLocation >= 0.65 and (nearVal or nearLvnLow or sweptLow)
bool bearAbsorption = hasFp and highVolume and strongBuying and closeLocation <= 0.35 and (nearVah or nearHvnHigh or sweptHigh)

var float pendingLongTrigger = na
var float pendingLongStop = na
var int pendingLongBar = na
var int pendingLongAge = 0
var float pendingShortTrigger = na
var float pendingShortStop = na
var int pendingShortBar = na
var int pendingShortAge = 0

if barstate.isconfirmed
    if bullAbsorption and na(pendingLongTrigger)
        pendingLongTrigger := high
        pendingLongStop := low
        pendingLongBar := bar_index
        pendingLongAge := 0
    else if not na(pendingLongTrigger) and bar_index > pendingLongBar
        pendingLongAge += 1
        if low < pendingLongStop or pendingLongAge > confirmBars
            pendingLongTrigger := na
            pendingLongStop := na
            pendingLongBar := na
            pendingLongAge := 0

    if bearAbsorption and na(pendingShortTrigger)
        pendingShortTrigger := low
        pendingShortStop := high
        pendingShortBar := bar_index
        pendingShortAge := 0
    else if not na(pendingShortTrigger) and bar_index > pendingShortBar
        pendingShortAge += 1
        if high > pendingShortStop or pendingShortAge > confirmBars
            pendingShortTrigger := na
            pendingShortStop := na
            pendingShortBar := na
            pendingShortAge := 0

float longTargetCandidate = not na(sessionPoc) and sessionPoc > close ? sessionPoc : sessionVah
float shortTargetCandidate = not na(sessionPoc) and sessionPoc < close ? sessionPoc : sessionVal
bool longConfirmed = barstate.isconfirmed and not na(pendingLongTrigger) and bar_index > pendingLongBar and close > pendingLongTrigger and not na(longTargetCandidate) and longTargetCandidate > close
bool shortConfirmed = barstate.isconfirmed and not na(pendingShortTrigger) and bar_index > pendingShortBar and close < pendingShortTrigger and not na(shortTargetCandidate) and shortTargetCandidate < close

var int activeDirection = 0
var float planEntry = na
var float planStop = na
var float planTarget = na
if longConfirmed
    activeDirection := 1
    planEntry := close
    planStop := pendingLongStop
    planTarget := longTargetCandidate
    pendingLongTrigger := na
    pendingLongStop := na
    pendingLongBar := na
    pendingLongAge := 0
    pendingShortTrigger := na
    pendingShortStop := na
    pendingShortBar := na
    pendingShortAge := 0
else if shortConfirmed
    activeDirection := -1
    planEntry := close
    planStop := pendingShortStop
    planTarget := shortTargetCandidate
    pendingShortTrigger := na
    pendingShortStop := na
    pendingShortBar := na
    pendingShortAge := 0
    pendingLongTrigger := na
    pendingLongStop := na
    pendingLongBar := na
    pendingLongAge := 0

// ─── Clean chart layer ───────────────────────────────────────────────────────
plot(showProfile ? sessionVah : na, "Session VAH", color = color.new(activeValueLinesColor, 12), linewidth = profileLineWidth, style = plot.style_linebr)
plot(showProfile ? sessionVal : na, "Session VAL", color = color.new(activeValueLinesColor, 12), linewidth = profileLineWidth, style = plot.style_linebr)
plot(showProfile ? sessionPoc : na, "Session POC / main HVN", color = activePocColor, linewidth = pocLineWidth, style = plot.style_linebr)
plot(showNodes ? nearestLvn : na, "Nearest session LVN", color = activeLvnLineColor, linewidth = profileLineWidth, style = plot.style_linebr)
plot(showPlan and activeDirection != 0 ? planEntry : na, "Latest plan • entry", color = activeEntryLineColor, linewidth = 1, style = plot.style_linebr)
plot(showPlan and activeDirection != 0 ? planStop : na, "Latest plan • invalidation", color = activeStopLineColor, linewidth = 1, style = plot.style_linebr)
plot(showPlan and activeDirection != 0 ? planTarget : na, "Latest plan • target", color = activeTargetLineColor, linewidth = 1, style = plot.style_linebr)
plot(cvd, "Session CVD (data window)", color = color.new(color.teal, 100), display = display.data_window)
plot(barDelta, "Footprint delta (data window)", color = color.new(color.orange, 100), display = display.data_window)

plotshape(showAbsorptionMarks and bullAbsorption, title = "Possible bullish absorption", style = shape.circle, location = location.belowbar, color = activeBullMarkColor, size = size.tiny, text = "A", display = display.pane)
plotshape(showAbsorptionMarks and bearAbsorption, title = "Possible bearish absorption", style = shape.circle, location = location.abovebar, color = activeBearMarkColor, size = size.tiny, text = "A", display = display.pane)
plotshape(longConfirmed, title = "Long confirmation", style = shape.labelup, location = location.belowbar, color = activeBullMarkColor, textcolor = color.white, size = size.small, text = "LONG", display = display.pane)
plotshape(shortConfirmed, title = "Short confirmation", style = shape.labeldown, location = location.abovebar, color = activeBearMarkColor, textcolor = color.white, size = size.small, text = "SHORT", display = display.pane)

// ─── Compact dashboard ──────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 8, frame_color = color.new(color.gray, 65), frame_width = 1, border_color = color.new(color.gray, 80))
f_price(float value) => na(value) ? "—" : str.tostring(value, format.mintick)
f_vol(float value) => na(value) ? "—" : str.tostring(value, format.volume)

string marketState = na(sessionVah) or na(sessionVal) ? "Building profile" : close > sessionVah ? "Above value • check acceptance" : close < sessionVal ? "Below value • check acceptance" : "Inside value • possible balance"
string flowState = not hasFp ? "Footprint unavailable" : bullAbsorption ? "Possible bullish absorption" : bearAbsorption ? "Possible bearish absorption" : strongBuying ? "Buy delta dominant" : strongSelling ? "Sell delta dominant" : "Mixed flow • wait"
string setupState = longConfirmed ? "LONG confirmed • alert" : shortConfirmed ? "SHORT confirmed • alert" : not na(pendingLongTrigger) ? "Long setup • waiting for break" : not na(pendingShortTrigger) ? "Short setup • waiting for break" : "Waiting for setup"
string cvdState = cvd > cvd[1] ? "↑ Buyers" : cvd < cvd[1] ? "↓ Sellers" : "→ Neutral"

if barstate.islast and showDashboard
    color headBg = color.rgb(25, 35, 50)
    color labelBg = color.new(color.rgb(25, 35, 50), 12)
    color valBg = color.new(color.rgb(13, 18, 28), 5)
    table.cell(dash, 0, 0, "AMT SL/TP FLOW", text_color = color.white, bgcolor = headBg, text_size = size.small)
    table.cell(dash, 1, 0, syminfo.ticker + " • " + timeframe.period, text_color = color.aqua, bgcolor = headBg, text_size = size.small)
    table.cell(dash, 0, 1, "Date", text_color = color.silver, bgcolor = labelBg, text_size = size.tiny)
    table.cell(dash, 1, 1, hasFp ? "Footprint OK" : "No footprint", text_color = hasFp ? color.lime : color.orange, bgcolor = valBg, text_size = size.tiny)
    table.cell(dash, 0, 2, "Auction", text_color = color.silver, bgcolor = labelBg, text_size = size.tiny)
    table.cell(dash, 1, 2, marketState, text_color = color.white, bgcolor = valBg, text_size = size.tiny)
    table.cell(dash, 0, 3, "Flow / setup", text_color = color.silver, bgcolor = labelBg, text_size = size.tiny)
    table.cell(dash, 1, 3, setupState == "Waiting for setup" ? flowState : setupState, text_color = longConfirmed or bullAbsorption ? color.aqua : shortConfirmed or bearAbsorption ? color.red : color.silver, bgcolor = valBg, text_size = size.tiny)
    table.cell(dash, 0, 4, "Bar delta", text_color = color.silver, bgcolor = labelBg, text_size = size.tiny)
    table.cell(dash, 1, 4, f_vol(barDelta) + (na(deltaShare) ? "" : " • " + str.tostring(deltaShare * 100, "#.0") + "%"), text_color = na(barDelta) ? color.silver : barDelta >= 0 ? color.lime : color.red, bgcolor = valBg, text_size = size.tiny)
    table.cell(dash, 0, 5, "CVD", text_color = color.silver, bgcolor = labelBg, text_size = size.tiny)
    table.cell(dash, 1, 5, f_vol(cvd) + " • " + cvdState, text_color = cvd >= cvd[1] ? color.lime : color.red, bgcolor = valBg, text_size = size.tiny)
    table.cell(dash, 0, 6, "VAH / POC / VAL", text_color = color.silver, bgcolor = labelBg, text_size = size.tiny)
    table.cell(dash, 1, 6, f_price(sessionVah) + " / " + f_price(sessionPoc) + " / " + f_price(sessionVal), text_color = color.white, bgcolor = valBg, text_size = size.tiny)
    table.cell(dash, 0, 7, "HVN / LVN", text_color = color.silver, bgcolor = labelBg, text_size = size.tiny)
    table.cell(dash, 1, 7, f_price(nearestHvn) + " / " + f_price(nearestLvn), text_color = color.white, bgcolor = valBg, text_size = size.tiny)

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 7)

// ─── Alerts ──────────────────────────────────────────────────────────────────
alertcondition(bullAbsorption, "Possible bullish absorption", "AMT SL/TP Flow Coach: possible bullish absorption on {{ticker}} {{interval}}. Wait for price confirmation.")
alertcondition(bearAbsorption, "Possible bearish absorption", "AMT SL/TP Flow Coach: possible bearish absorption on {{ticker}} {{interval}}. Wait for price confirmation.")
alertcondition(longConfirmed, "Long confirmation", "AMT SL/TP Flow Coach: LONG confirmation on {{ticker}} {{interval}}. Review the chart and risk plan.")
alertcondition(shortConfirmed, "Short confirmation", "AMT SL/TP Flow Coach: SHORT confirmation on {{ticker}} {{interval}}. Review the chart and risk plan.")
````
