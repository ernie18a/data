# Universal Renko Fusion by Rajat

- url: https://www.tradingview.com/script/2ldivRwK-Universal-Renko-Fusion-by-Rajat/
- type: indicator
- pine_id: PUB;2d886940dd91427ea3d77865cf9f49c8
- version: 1.0

## Description

URF — Universal Renko Fusion by Rajat

URF (Universal Renko Fusion) is a multi-component technical indicator designed to simplify Renko-based market analysis by combining Renko brick structure, PPST trailing levels, and SuperTrend Fusion signals in one chart.

Key Features

Universal Renko Analysis: Customizable Renko box size for different markets and instruments.

PPST System: Displays PPST trailing levels and directional signals.

SuperTrend Fusion: Integrates trend detection with configurable ATR, factor, acceleration factor (AF), and optional filters.

Renko Brick Data: Displays recent brick information for quick market analysis.

Customizable Settings: Adjust box size, displayed bricks, PPST parameters, and Fusion settings to suit your trading approach.

Purpose: To help traders identify trend direction, monitor potential reversals, and analyze Renko price action using a unified indicator.

For educational and analytical purposes only. This indicator does not guarantee profits. Always apply appropriate risk management.

## Source Code

````pine
//@version=6

indicator("Universal Renko Fusion by Rajat", overlay=true, max_boxes_count=100, max_lines_count=100, max_labels_count=500)



// ============================================================

// SETTINGS

// ============================================================

BOX = input.float(59.0, "Renko Box Size", minval=0.0000001, step=0.0000001)

DISPLAY_BRICKS = input.int(30, "Bricks To Display", minval=5, maxval=50)

SHOW_DATA = input.bool(true, "Show Last 4 Brick Data")



SHOW_PPST = input.bool(true, "Show PPST")

PPST_PIVOT = input.int(1, "PPST Pivot Period", minval=1)

PPST_FACTOR = input.float(2.4, "PPST ATR Factor", minval=0.1, step=0.1)

PPST_ATR = input.int(9, "PPST ATR Period", minval=1)



SHOW_FUSION = input.bool(true, "Show SuperTrend Fusion")

FUSION_ATR = input.int(10, "Fusion ATR Length", minval=1)

FUSION_FACTOR = input.float(2.5, "Fusion Factor", minval=0.1, step=0.1)

FUSION_AF_PERIOD = input.int(14, "Fusion AF Period", minval=1)

FUSION_AF_SMOOTH = input.int(5, "Fusion AF Smooth", minval=1)

FUSION_USE_AF = input.bool(true, "Fusion AF Filter")

FUSION_USE_CHOP = input.bool(false, "Fusion Chop Filter")

FUSION_CHOP_LENGTH = input.int(14, "Fusion Chop Length", minval=1)

FUSION_CHOP_THRESHOLD = input.int(50, "Fusion Chop Threshold", minval=1, maxval=100)



SHOW_MA234 = input.bool(true, "Show 234 MA")

MA_LENGTH = input.int(234, "MA Length", minval=1)



// ============================================================

// RENKO ENGINE — EXACT WORKING VERSION

// ============================================================

var float rClose = na

var int rDir = 0

var float swingHigh = na

var float swingLow = na



var brickOpen  = array.new_float()

var brickHigh  = array.new_float()

var brickLow   = array.new_float()

var brickClose = array.new_float()

var brickDir   = array.new_int()

var brickTime  = array.new_int()



if barstate.isconfirmed

    price = close



    if na(rClose)

        rClose := math.round(price / BOX) * BOX

        rDir := 0

        swingHigh := price

        swingLow := price

    else

        swingHigh := math.max(swingHigh, price)

        swingLow := math.min(swingLow, price)



        bool madeBrick = true

        int safety = 0



        while madeBrick and safety < 100

            madeBrick := false

            safety += 1



            if rDir >= 0 and price - rClose >= BOX

                float o = rClose

                float c = rClose + BOX

                float h = c

                float l = math.min(swingLow, o)



                array.push(brickOpen, o)

                array.push(brickHigh, h)

                array.push(brickLow, l)

                array.push(brickClose, c)

                array.push(brickDir, 1)

                array.push(brickTime, time)



                rClose := c

                rDir := 1

                swingHigh := c

                swingLow := c

                madeBrick := true



            else if rDir == 1 and rClose - price >= BOX * 2

                float o = rClose - BOX

                float c = rClose - BOX * 2

                float h = math.max(swingHigh, o)

                float l = c



                array.push(brickOpen, o)

                array.push(brickHigh, h)

                array.push(brickLow, l)

                array.push(brickClose, c)

                array.push(brickDir, -1)

                array.push(brickTime, time)



                rClose := c

                rDir := -1

                swingHigh := c

                swingLow := c

                madeBrick := true



            else if rDir <= 0 and rClose - price >= BOX

                float o = rClose

                float c = rClose - BOX

                float h = math.max(swingHigh, o)

                float l = c



                array.push(brickOpen, o)

                array.push(brickHigh, h)

                array.push(brickLow, l)

                array.push(brickClose, c)

                array.push(brickDir, -1)

                array.push(brickTime, time)



                rClose := c

                rDir := -1

                swingHigh := c

                swingLow := c

                madeBrick := true



            else if rDir == -1 and price - rClose >= BOX * 2

                float o = rClose + BOX

                float c = rClose + BOX * 2

                float h = c

                float l = math.min(swingLow, o)



                array.push(brickOpen, o)

                array.push(brickHigh, h)

                array.push(brickLow, l)

                array.push(brickClose, c)

                array.push(brickDir, 1)

                array.push(brickTime, time)



                rClose := c

                rDir := 1

                swingHigh := c

                swingLow := c

                madeBrick := true



while array.size(brickClose) > 300

    array.shift(brickOpen)

    array.shift(brickHigh)

    array.shift(brickLow)

    array.shift(brickClose)

    array.shift(brickDir)

    array.shift(brickTime)



// ============================================================

// BUILD RENKO SERIES FOR INDICATORS

// IMPORTANT: use nz() fallback so MA/PPST never displays NaN

// ============================================================

int brickCount = array.size(brickClose)



float renkoCloseSeries = brickCount > 0 ? array.get(brickClose, brickCount - 1) : na

float renkoOpenSeries  = brickCount > 0 ? array.get(brickOpen, brickCount - 1) : na

float renkoHighSeries  = brickCount > 0 ? array.get(brickHigh, brickCount - 1) : na

float renkoLowSeries   = brickCount > 0 ? array.get(brickLow, brickCount - 1) : na



// The MA is calculated directly from the stored completed Renko closes.

// We calculate it manually from the Renko array instead of ta.sma().

// This avoids NaN caused by sparse/non-bar Renko series.

string tvRenkoTicker = ticker.renko(syminfo.tickerid, "Traditional", BOX)
float ma234 = request.security(
     tvRenkoTicker,
     timeframe.period,
     ta.sma(close, MA_LENGTH),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

plot(SHOW_MA234 ? ma234 : na, "Renko SMA 234", color=color.yellow, linewidth=2, style=plot.style_stepline)



// ============================================================

// RENKO TRUE RANGE / ATR FOR PPST
// Exact Wilder RMA-style ATR on the completed synthetic Renko stream.
// ============================================================
var float[] renkoTR = array.new_float()
var float[] renkoATR = array.new_float()
array.clear(renkoTR)
array.clear(renkoATR)

if brickCount > 0
    for i = 0 to brickCount - 1
        float h = array.get(brickHigh, i)
        float l = array.get(brickLow, i)
        float pc = i > 0 ? array.get(brickClose, i - 1) : array.get(brickClose, i)
        float tr = math.max(h - l, math.max(math.abs(h - pc), math.abs(l - pc)))
        array.push(renkoTR, tr)

    for i = 0 to brickCount - 1
        float atrValue = na
        if i + 1 >= PPST_ATR
            if i + 1 == PPST_ATR
                float s = 0.0
                for k = 0 to PPST_ATR - 1
                    s += array.get(renkoTR, i - k)
                atrValue := s / PPST_ATR
            else
                float prevATR = array.get(renkoATR, i - 1)
                float trNow = array.get(renkoTR, i)
                atrValue := na(prevATR) ? na : (prevATR * (PPST_ATR - 1.0) + trNow) / PPST_ATR
        array.push(renkoATR, atrValue)

// PPST — exact Pivot Point SuperTrend sequence on Renko bricks.
var float[] ppCenterArr = array.new_float()
var float[] ppUpArr = array.new_float()
var float[] ppDnArr = array.new_float()
var float[] ppTUArr = array.new_float()
var float[] ppTDArr = array.new_float()
var int[] ppTrendArr = array.new_int()
array.clear(ppCenterArr)
array.clear(ppUpArr)
array.clear(ppDnArr)
array.clear(ppTUArr)
array.clear(ppTDArr)
array.clear(ppTrendArr)

if brickCount > 0
    for i = 0 to brickCount - 1
        float h = array.get(brickHigh, i)
        float l = array.get(brickLow, i)
        float c = array.get(brickClose, i)
        float pHigh = na
        float pLow = na

        // ta.pivothigh/ta.pivotlow(P,P): pivot at i-P is confirmed at i.
        if i >= PPST_PIVOT * 2
            int pivotIndex = i - PPST_PIVOT
            bool highPivot = true
            bool lowPivot = true
            for k = 1 to PPST_PIVOT
                highPivot := highPivot and array.get(brickHigh, pivotIndex) >= array.get(brickHigh, pivotIndex - k) and array.get(brickHigh, pivotIndex) > array.get(brickHigh, pivotIndex + k)
                lowPivot := lowPivot and array.get(brickLow, pivotIndex) <= array.get(brickLow, pivotIndex - k) and array.get(brickLow, pivotIndex) < array.get(brickLow, pivotIndex + k)
            pHigh := highPivot ? array.get(brickHigh, pivotIndex) : na
            pLow := lowPivot ? array.get(brickLow, pivotIndex) : na

        // Original PPST gives pivot-high priority if both exist.
        float lastPP = not na(pHigh) ? pHigh : not na(pLow) ? pLow : na
        float prevCenter = i > 0 ? array.get(ppCenterArr, i - 1) : na
        float center = na(lastPP) ? prevCenter : na(prevCenter) ? lastPP : (prevCenter * 2.0 + lastPP) / 3.0

        float atr = array.get(renkoATR, i)
        float up = na(center) or na(atr) ? na : center - PPST_FACTOR * atr
        float dn = na(center) or na(atr) ? na : center + PPST_FACTOR * atr
        float prevTU = i > 0 ? array.get(ppTUArr, i - 1) : up
        float prevTD = i > 0 ? array.get(ppTDArr, i - 1) : dn
        float prevClose = i > 0 ? array.get(brickClose, i - 1) : c
        float tu = na(up) ? na : (not na(prevTU) and prevClose > prevTU ? math.max(up, prevTU) : up)
        float td = na(dn) ? na : (not na(prevTD) and prevClose < prevTD ? math.min(dn, prevTD) : dn)
        int prevTrend = i > 0 ? array.get(ppTrendArr, i - 1) : 1
        int trend = c > nz(prevTD, dn) ? 1 : c < nz(prevTU, up) ? -1 : prevTrend

        array.push(ppCenterArr, center)
        array.push(ppUpArr, up)
        array.push(ppDnArr, dn)
        array.push(ppTUArr, tu)
        array.push(ppTDArr, td)
        array.push(ppTrendArr, trend)

float ppstLevel = na
int ppstTrend = 0
if brickCount > 0
    ppstTrend := array.get(ppTrendArr, brickCount - 1)
    ppstLevel := ppstTrend == 1 ? array.get(ppTUArr, brickCount - 1) : array.get(ppTDArr, brickCount - 1)

plot(SHOW_PPST ? ppstLevel : na, "PPST Trailing Level", color=ppstTrend == 1 ? color.lime : color.red, linewidth=3, style=plot.style_stepline)

bool ppstBuySignal = brickCount >= 2 and array.get(ppTrendArr, brickCount - 1) == 1 and array.get(ppTrendArr, brickCount - 2) == -1
bool ppstSellSignal = brickCount >= 2 and array.get(ppTrendArr, brickCount - 1) == -1 and array.get(ppTrendArr, brickCount - 2) == 1

// ============================================================
// SUPER TREND FUSION — TradingView Traditional Renko source
// ============================================================

// Fusion is calculated on TradingView's own Traditional Renko ticker.
// This is intentionally separate from the custom Renko engine used by PPST/MA.
renkoTickerFusion = ticker.renko(syminfo.tickerid, "Traditional", BOX, true)

f_fusionOnTVRenko() =>
    // Run the complete ATP-style calculation INSIDE the requested Renko context.
    // Do not detect direction flips again on the 1-minute chart series.
    [stValue, stDirection] = ta.supertrend(FUSION_FACTOR, FUSION_ATR)

    float highestHi = ta.highest(high, FUSION_AF_PERIOD)
    float lowestLo = ta.lowest(low, FUSION_AF_PERIOD)
    float afRange = highestHi - lowestLo
    float afRaw = afRange == 0.0 ? 0.0 : (close - lowestLo) / afRange - 0.5
    float afValue = ta.sma(afRaw, FUSION_AF_SMOOTH)

    float highestChop = ta.highest(high, FUSION_CHOP_LENGTH)
    float lowestChop = ta.lowest(low, FUSION_CHOP_LENGTH)
    float chopRange = highestChop - lowestChop
    float chopSum = math.sum(ta.atr(1), FUSION_CHOP_LENGTH)
    float chopValue = chopRange != 0.0 ? 100.0 * math.log10(chopSum / chopRange) / math.log10(FUSION_CHOP_LENGTH) : 100.0

    bool rawLongFlip = ta.change(stDirection) < 0
    bool rawShortFlip = ta.change(stDirection) > 0
    bool bullOK = (not FUSION_USE_AF or afValue > 0) and (not FUSION_USE_CHOP or chopValue < FUSION_CHOP_THRESHOLD)
    bool bearOK = (not FUSION_USE_AF or afValue < 0) and (not FUSION_USE_CHOP or chopValue < FUSION_CHOP_THRESHOLD)
    bool longEntry = rawLongFlip and bullOK
    bool shortEntry = rawShortFlip and bearOK
    bool filteredLong = rawLongFlip and not longEntry
    bool filteredShort = rawShortFlip and not shortEntry
    int fusionStateLocal = stDirection < 0 and bullOK ? 1 : stDirection > 0 and bearOK ? -1 : 0
    [stValue, stDirection, afValue, fusionStateLocal, time, high, low, close, longEntry, shortEntry, filteredLong, filteredShort]

[tvFusionST, tvFusionDirection, tvFusionAF, tvFusionState, tvFusionTime, tvFusionHigh, tvFusionLow, tvFusionClose, tvFusionLongInContext, tvFusionShortInContext, tvFilteredLongInContext, tvFilteredShortInContext] = request.security(renkoTickerFusion, timeframe.period, f_fusionOnTVRenko(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// request.security() can hold the last Renko value across chart bars. Gate every
// event with a change in the source Renko timestamp, and use event booleans that
// were already calculated in the Renko context. This prevents chart-timeframe
// edge detection from inventing, delaying, or dropping flips.
// request.security() holds Renko-context values between source bricks.
// Detect the rising edge of each already-filtered event boolean directly.
// This avoids dropping a valid Fusion flip when source close/time sampling
// does not change on the same chart bar.
bool tvFusionLongEvent = SHOW_FUSION and tvFusionLongInContext and not tvFusionLongInContext[1]
bool tvFusionShortEvent = SHOW_FUSION and tvFusionShortInContext and not tvFusionShortInContext[1]
bool tvFilteredLongEvent = SHOW_FUSION and tvFilteredLongInContext and not tvFilteredLongInContext[1]
bool tvFilteredShortEvent = SHOW_FUSION and tvFilteredShortInContext and not tvFilteredShortInContext[1]

// Save each event's timestamp AND source Renko close. The close is used as a
// second matching key because Renko timestamps can differ between feeds.
var int[] fusionEventTimes = array.new_int()
var int[] fusionEventTypes = array.new_int() // 1=BUY, -1=SELL, 2=filtered BUY, -2=filtered SELL
var float[] fusionEventPrices = array.new_float()
if barstate.isconfirmed
    if tvFusionLongEvent
        array.push(fusionEventTimes, int(tvFusionTime))
        array.push(fusionEventTypes, 1)
        array.push(fusionEventPrices, tvFusionClose)
    if tvFusionShortEvent
        array.push(fusionEventTimes, int(tvFusionTime))
        array.push(fusionEventTypes, -1)
        array.push(fusionEventPrices, tvFusionClose)
    if tvFilteredLongEvent
        array.push(fusionEventTimes, int(tvFusionTime))
        array.push(fusionEventTypes, 2)
        array.push(fusionEventPrices, tvFusionClose)
    if tvFilteredShortEvent
        array.push(fusionEventTimes, int(tvFusionTime))
        array.push(fusionEventTypes, -2)
        array.push(fusionEventPrices, tvFusionClose)
    while array.size(fusionEventTimes) > 500
        array.shift(fusionEventTimes)
        array.shift(fusionEventTypes)
        array.shift(fusionEventPrices)

float fusionSTValue = tvFusionST
int fusionDirection = int(tvFusionDirection)
int fusionState = int(tvFusionState)
float fusionAFValue = tvFusionAF
color fusionColor = fusionState == 1 ? color.aqua : fusionState == -1 ? color.orange : color.gray
plot(SHOW_FUSION ? fusionSTValue : na, "SuperTrend Fusion — TV Renko Source", color=fusionColor, linewidth=2, style=plot.style_stepline)

// ============================================================
// RENKO BRICKS — CLEAN VISUALS
// Uses the existing completed Renko OHLC/wick arrays.
// Calculation logic is unchanged.

var bodyBoxes = array.new_box()
var wickLines = array.new_line()
var ppstLabels = array.new_label()
var tvFusionLabels = array.new_label()

if barstate.islast
    if array.size(bodyBoxes) > 0
        for i = 0 to array.size(bodyBoxes) - 1
            box.delete(array.get(bodyBoxes, i))
        array.clear(bodyBoxes)

    if array.size(wickLines) > 0
        for i = 0 to array.size(wickLines) - 1
            line.delete(array.get(wickLines, i))
        array.clear(wickLines)

    if array.size(ppstLabels) > 0
        for i = 0 to array.size(ppstLabels) - 1
            label.delete(array.get(ppstLabels, i))
        array.clear(ppstLabels)

    if array.size(tvFusionLabels) > 0
        for i = 0 to array.size(tvFusionLabels) - 1
            label.delete(array.get(tvFusionLabels, i))
        array.clear(tvFusionLabels)

    int totalDraw = array.size(brickClose)

    if totalDraw > 0
        int firstDraw = math.max(0, totalDraw - DISPLAY_BRICKS)

        for i = firstDraw to totalDraw - 1
            float o = array.get(brickOpen, i)
            float c = array.get(brickClose, i)
            float h = array.get(brickHigh, i)
            float l = array.get(brickLow, i)
            int d = array.get(brickDir, i)

            int x1 = bar_index - (totalDraw - 1 - i)
            int x2 = x1 + 1

            float top = math.max(o, c)
            float bottom = math.min(o, c)

            box body = box.new(
                 left=x1,
                 top=top,
                 right=x2,
                 bottom=bottom,
                 xloc=xloc.bar_index,
                 border_width=1,
                 border_color=d == 1 ? color.lime : color.red,
                 bgcolor=d == 1 ? color.new(color.lime, 15) : color.new(color.red, 15))

            array.push(bodyBoxes, body)

            // GREEN: lower wick only.
            if d == 1 and l < bottom
                line wick = line.new(
                     x1=x1, y1=l, x2=x1, y2=bottom,
                     xloc=xloc.bar_index,
                     color=color.lime,
                     width=1)
                array.push(wickLines, wick)

            // RED: upper wick only.
            if d == -1 and h > top
                line wick = line.new(
                     x1=x1, y1=h, x2=x1, y2=top,
                     xloc=xloc.bar_index,
                     color=color.red,
                     width=1)
                array.push(wickLines, wick)

            // PPST marker: anchored to the exact signal brick.
            bool buySignal = i >= 1 and
                 array.get(ppTrendArr, i) == 1 and
                 array.get(ppTrendArr, i - 1) == -1

            bool sellSignal = i >= 1 and
                 array.get(ppTrendArr, i) == -1 and
                 array.get(ppTrendArr, i - 1) == 1

            if SHOW_PPST and buySignal
                label lb = label.new(
                     x=x1,
                     y=l - BOX * 0.35,
                     text="▲",
                     xloc=xloc.bar_index,
                     style=label.style_none,
                     color=color.lime,
                     textcolor=color.lime,
                     size=size.small)
                array.push(ppstLabels, lb)

            if SHOW_PPST and sellSignal
                label lb = label.new(
                     x=x1,
                     y=h + BOX * 0.35,
                     text="▼",
                     xloc=xloc.bar_index,
                     style=label.style_none,
                     color=color.red,
                     textcolor=color.red,
                     size=size.small)
                array.push(ppstLabels, lb)

        // Map saved Fusion events to the nearest visible custom Renko brick.
        // This aligns signal markers with the custom bricks displayed on screen.
        int visibleStartTime = array.get(brickTime, firstDraw)
        int visibleEndTime = array.get(brickTime, totalDraw - 1)
        // Renko feeds may timestamp a brick differently from the custom engine.
        // Use a wider time window, then match by both source close and timestamp.
        int timeTolerance = 60 * 60 * 1000
        int eventCount = array.size(fusionEventTimes)
        if SHOW_FUSION and eventCount > 0
            for e = 0 to eventCount - 1
                int eventTime = array.get(fusionEventTimes, e)
                int eventType = array.get(fusionEventTypes, e)
                float eventPrice = array.get(fusionEventPrices, e)
                bool inVisibleWindow = eventTime >= visibleStartTime - timeTolerance and eventTime <= visibleEndTime + timeTolerance
                if inVisibleWindow
                    int nearestIndex = -1
                    float bestScore = 1e20
                    for k = firstDraw to totalDraw - 1
                        int timeDiff = math.abs(array.get(brickTime, k) - eventTime)
                        if timeDiff <= timeTolerance
                            float priceDiff = math.abs(array.get(brickClose, k) - eventPrice)
                            // One box of price difference is weighted like 15 minutes.
                            float score = priceDiff / BOX + timeDiff / (15.0 * 60.0 * 1000.0)
                            if score < bestScore
                                bestScore := score
                                nearestIndex := k
                    if nearestIndex >= 0
                        float eventHigh = array.get(brickHigh, nearestIndex)
                        float eventLow = array.get(brickLow, nearestIndex)
                        int eventX = bar_index - (totalDraw - 1 - nearestIndex)
                        string markerText = eventType == 1 ? "▲ BUY" : eventType == -1 ? "▼ SELL" : "×"
                        color markerColor = eventType == 1 ? color.aqua : color.orange
                        float markerY = eventType == 1 or eventType == 2 ? eventLow - BOX * (eventType == 1 ? 0.60 : 0.42) : eventHigh + BOX * (eventType == -1 ? 0.60 : 0.42)
                        label marker = label.new(x=eventX, y=markerY, text=markerText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=markerColor, color=color.new(markerColor, 100), size=eventType == 2 or eventType == -2 ? size.tiny : size.small)
                        array.push(tvFusionLabels, marker)


// Fusion markers are drawn on the custom bricks below, mapped by timestamp.

// LAST 4 BRICK DATA

// ============================================================

var table dataTable = table.new(position.top_right, 6, 6, border_width=1)



if barstate.islast

    for row = 0 to 5

        for col = 0 to 5

            table.cell(dataTable, col, row, "")



    if SHOW_DATA

        table.cell(dataTable, 0, 0, "BRICK", text_color=color.white)

        table.cell(dataTable, 1, 0, "TIME", text_color=color.white)

        table.cell(dataTable, 2, 0, "OPEN", text_color=color.white)

        table.cell(dataTable, 3, 0, "HIGH", text_color=color.white)

        table.cell(dataTable, 4, 0, "LOW", text_color=color.white)

        table.cell(dataTable, 5, 0, "CLOSE", text_color=color.white)



        int total = array.size(brickClose)

        int rows = math.min(4, total)



        if rows > 0

            for j = 0 to rows - 1

                int idx = total - 1 - j

                int d = array.get(brickDir, idx)

                int t = array.get(brickTime, idx)



                table.cell(dataTable, 0, j + 1, d == 1 ? "GREEN" : "RED",

                     text_color=d == 1 ? color.lime : color.red)

                table.cell(dataTable, 1, j + 1, str.format("{0,time,HH:mm}", t), text_color=color.white)

                table.cell(dataTable, 2, j + 1, str.tostring(array.get(brickOpen, idx)), text_color=color.white)

                table.cell(dataTable, 3, j + 1, str.tostring(array.get(brickHigh, idx)), text_color=color.white)

                table.cell(dataTable, 4, j + 1, str.tostring(array.get(brickLow, idx)), text_color=color.white)

                table.cell(dataTable, 5, j + 1, str.tostring(array.get(brickClose, idx)), text_color=color.white)



// ============================================================

// STATUS

// ============================================================

var table status = table.new(position.bottom_right, 2, 9, border_width=1)



if barstate.islast

    table.cell(status, 0, 0, "SYMBOL", text_color=color.gray)

    table.cell(status, 1, 0, syminfo.ticker, text_color=color.white)



    table.cell(status, 0, 1, "BOX", text_color=color.gray)

    table.cell(status, 1, 1, str.tostring(BOX), text_color=color.white)



    table.cell(status, 0, 2, "BRICKS", text_color=color.gray)

    table.cell(status, 1, 2, str.tostring(brickCount), text_color=color.white)



    table.cell(status, 0, 3, "PPST", text_color=color.gray)

    table.cell(status, 1, 3, ppstTrend == 1 ? "BUY" : ppstTrend == -1 ? "SELL" : "WAIT",

         text_color=ppstTrend == 1 ? color.lime : ppstTrend == -1 ? color.red : color.gray)



    table.cell(status, 0, 4, "FUSION", text_color=color.gray)

    table.cell(status, 1, 4, fusionState == 1 ? "BULLISH" : fusionState == -1 ? "BEARISH" : "NEUTRAL",

         text_color=fusionColor)



    table.cell(status, 0, 5, "MA 234", text_color=color.gray)

    table.cell(status, 1, 5, na(ma234) ? "WAIT" : close > ma234 ? "BULLISH" : "BEARISH",

         text_color=na(ma234) ? color.gray : close > ma234 ? color.lime : color.red)



    table.cell(status, 0, 6, "MA VALUE", text_color=color.gray)

    table.cell(status, 1, 6, na(ma234) ? "WAITING" : str.tostring(ma234),

         text_color=color.yellow)
    
    table.cell(status, 0, 7, "PPST TRAIL", text_color=color.gray)
    table.cell(status, 1, 7, na(ppstLevel) ? "WAITING" : str.tostring(ppstLevel),
         text_color=ppstTrend == 1 ? color.lime : color.red)

    table.cell(status, 0, 8, "FUSION AF", text_color=color.gray)
    table.cell(status, 1, 8, na(fusionAFValue) ? "WAITING" : str.tostring(fusionAFValue),
         text_color=fusionAFValue > 0 ? color.aqua : fusionAFValue < 0 ? color.orange : color.gray)
````
