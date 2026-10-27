# Shaka VR Money Profile

- url: https://www.tradingview.com/script/dhN3idE7-Shaka-VR-Money-Profile/
- type: indicator
- pine_id: PUB;1bfee7d0c94f4b1f9046243f84ab96a5
- version: 1.0

## Description

Shaka VR Money Profile is a visible-range turnover profile built to answer a question that standard volume profiles often fail to answer:

Where did the market transact the most money?

A regular volume profile shows where the largest number of coins, shares, or contracts changed hands.
But markets do not distribute in units alone. They distribute in capital.

That becomes critical after large repricing moves.

Take [symbol="BINANCE:SOLUSDT"]BINANCE:SOLUSDT[/symbol] as an example.
A standard profile may show the main historical volume cluster near the low-price accumulation zone around $20.
From a raw volume perspective, that makes sense.
However, once price trades above $150, even a smaller number of coins can represent far greater capital rotation.
So while the classic profile suggests that “nothing important” happened at higher levels, the money-weighted profile shows that the largest turnover in dollar terms actually took place much higher.

This script was built specifically to expose that difference and to help distinguish accumulation from distribution more clearly.

The indicator works on the visible range and updates automatically as the chart window changes.
It supports:
- Volume mode
- Money mode
- POC / VAH / VAL
- Multiple allocation models, including Body Range + Wick Discount

Body Range + Wick Discount is especially useful when you want a profile that keeps the visual logic of a range-based model, but reduces the distortion created by long candle wicks.

This is not a tick-level volume-at-price engine.
It is a candle-based approximation of capital distribution.
But for cycle analysis, especially on assets that have moved several times higher from their accumulation base, it can reveal something that the standard profile often hides:
not where the most units traded,
but where the most money changed hands.

## Source Code

````pine
//@version=6
indicator("Visible Range Money / Dollar Volume Profile SIMPLE", overlay=true, max_boxes_count=900, max_lines_count=50)

//--------------------------------------------------
// Minimal inputs
//--------------------------------------------------
profileMode      = input.string("Money", "Profile Mode", options=["Money", "Volume"])
moneyPrice       = input.source(hlc3, "Price Source For Money Weight")

allocationMode   = input.string("Body Range + Wick Discount", "Allocation Mode", options=["Body Range + Wick Discount", "Uniform Range", "Typical Price Bin"])
wickDiscount     = input.float(0.35, "Wick Discount", minval=0.0, maxval=1.0, step=0.05)

valueAreaPct     = input.float(70.0, "Value Area %", minval=50.0, maxval=99.0, step=0.5)
profileWidthPct  = input.float(16.0, "Profile Width (% of visible bars)", minval=5.0, maxval=40.0, step=0.5)
gapBars          = input.int(12, "Gap Bars", minval=0, maxval=100)
maxBarsToScan    = input.int(20000, "Max Bars To Scan", minval=1000, maxval=100000)

showPOC          = input.bool(true, "Show POC")
showVAH          = input.bool(true, "Show VAH")
showVAL          = input.bool(true, "Show VAL")

//--------------------------------------------------
// Fixed settings
//--------------------------------------------------
int rows = 150

//--------------------------------------------------
// Customizable colors
//--------------------------------------------------
outsideVAColor   = input.color(color.new(color.gray, 82), "Outside VA Color")
valueAreaColor   = input.color(color.new(color.rgb(170, 185, 205), 72), "Value Area Color")
pocRowColor      = input.color(color.new(color.rgb(205, 185, 160), 58), "POC Row Color")

pocLineColor     = input.color(color.new(color.rgb(196, 163, 122), 10), "POC Line Color")
vahLineColor     = input.color(color.new(color.rgb(168, 188, 178), 20), "VAH Line Color")
valLineColor     = input.color(color.new(color.rgb(198, 170, 170), 20), "VAL Line Color")

//--------------------------------------------------
// Persistent objects
//--------------------------------------------------
var array<box> profileBoxes = array.new_box()
var line pocLine = na
var line vahLine = na
var line valLine = na

//--------------------------------------------------
// Helpers
//--------------------------------------------------
f_clamp(float v, float mn, float mx) =>
    math.max(mn, math.min(mx, v))

f_add_bin(array<float> arr, float allocPrice, float weight, float rangeLow, float step, int rowsCount) =>
    if weight > 0
        int bin = int(math.floor((allocPrice - rangeLow) / step))
        bin := int(f_clamp(bin, 0, rowsCount - 1))
        array.set(arr, bin, array.get(arr, bin) + weight)

f_add_uniform_segment(array<float> arr, float segLow, float segHigh, float segWeight, float rangeLow, float step, int rowsCount) =>
    if segWeight > 0 and segHigh >= segLow
        int fromBin = int(math.floor((segLow  - rangeLow) / step))
        int toBin   = int(math.floor((segHigh - rangeLow) / step))

        fromBin := int(f_clamp(fromBin, 0, rowsCount - 1))
        toBin   := int(f_clamp(toBin, 0, rowsCount - 1))

        int binsCovered = math.max(1, toBin - fromBin + 1)
        float part = segWeight / binsCovered

        for r = fromBin to toBin
            array.set(arr, r, array.get(arr, r) + part)

//--------------------------------------------------
// Visible range
//--------------------------------------------------
leftVisibleTime  = chart.left_visible_bar_time
rightVisibleTime = chart.right_visible_bar_time

//--------------------------------------------------
// Main
//--------------------------------------------------
if barstate.islast
    // Clear old drawings
    if array.size(profileBoxes) > 0
        for i = 0 to array.size(profileBoxes) - 1
            box.delete(array.get(profileBoxes, i))
        array.clear(profileBoxes)

    if not na(pocLine)
        line.delete(pocLine)
        pocLine := na

    if not na(vahLine)
        line.delete(vahLine)
        vahLine := na

    if not na(valLine)
        line.delete(valLine)
        valLine := na

    int scanLimit = math.min(maxBarsToScan - 1, bar_index)

    float rangeHigh = na
    float rangeLow  = na
    int leftIndex   = na
    int rightIndex  = na
    int barsFound   = 0

    // 1) Find visible bars
    for i = 0 to scanLimit
        bool inVisibleRange = time[i] >= leftVisibleTime and time[i] <= rightVisibleTime
        if inVisibleRange
            barsFound += 1
            rangeHigh := na(rangeHigh) ? high[i] : math.max(rangeHigh, high[i])
            rangeLow  := na(rangeLow)  ? low[i]  : math.min(rangeLow, low[i])

            int bi = bar_index - i
            leftIndex  := na(leftIndex)  ? bi : math.min(leftIndex, bi)
            rightIndex := na(rightIndex) ? bi : math.max(rightIndex, bi)

    if barsFound > 0
        float priceRange = math.max(rangeHigh - rangeLow, syminfo.mintick * rows)
        float step = math.max(priceRange / rows, syminfo.mintick)

        array<float> profile = array.new_float(rows, 0.0)

        // 2) Build profile
        for i = 0 to scanLimit
            bool inVisibleRange = time[i] >= leftVisibleTime and time[i] <= rightVisibleTime
            if inVisibleRange
                float weight = profileMode == "Money" ? nz(volume[i]) * nz(moneyPrice[i]) : nz(volume[i])

                if allocationMode == "Uniform Range"
                    f_add_uniform_segment(profile, low[i], high[i], weight, rangeLow, step, rows)

                else if allocationMode == "Typical Price Bin"
                    float tp = (high[i] + low[i] + close[i]) / 3.0
                    f_add_bin(profile, tp, weight, rangeLow, step, rows)

                else
                    // Body Range + Wick Discount
                    float bodyLow  = math.min(open[i], close[i])
                    float bodyHigh = math.max(open[i], close[i])

                    float bodyLen  = math.max(bodyHigh - bodyLow, 0.0)
                    float lowerLen = math.max(bodyLow - low[i], 0.0)
                    float upperLen = math.max(high[i] - bodyHigh, 0.0)

                    float effectiveLen = bodyLen + wickDiscount * (lowerLen + upperLen)

                    if effectiveLen <= syminfo.mintick
                        float tp2 = (high[i] + low[i] + close[i]) / 3.0
                        f_add_bin(profile, tp2, weight, rangeLow, step, rows)
                    else
                        float bodyWeight  = weight * bodyLen / effectiveLen
                        float lowerWeight = weight * wickDiscount * lowerLen / effectiveLen
                        float upperWeight = weight * wickDiscount * upperLen / effectiveLen

                        if bodyLen > syminfo.mintick
                            f_add_uniform_segment(profile, bodyLow, bodyHigh, bodyWeight, rangeLow, step, rows)
                        else
                            f_add_bin(profile, close[i], bodyWeight, rangeLow, step, rows)

                        if lowerLen > syminfo.mintick
                            f_add_uniform_segment(profile, low[i], bodyLow, lowerWeight, rangeLow, step, rows)

                        if upperLen > syminfo.mintick
                            f_add_uniform_segment(profile, bodyHigh, high[i], upperWeight, rangeLow, step, rows)

        // 3) Find POC and total
        float maxVal = 0.0
        float totalProfile = 0.0
        int pocRow = 0

        for r = 0 to rows - 1
            float v = array.get(profile, r)
            totalProfile += v
            if v > maxVal
                maxVal := v
                pocRow := r

        if maxVal > 0 and totalProfile > 0
            // 4) Value area
            float targetVA = totalProfile * valueAreaPct / 100.0
            int vaLowRow = pocRow
            int vaHighRow = pocRow
            float cumVA = array.get(profile, pocRow)

            while cumVA < targetVA and (vaLowRow > 0 or vaHighRow < rows - 1)
                float downVal = vaLowRow > 0 ? array.get(profile, vaLowRow - 1) : -1.0
                float upVal   = vaHighRow < rows - 1 ? array.get(profile, vaHighRow + 1) : -1.0

                if upVal >= downVal
                    if vaHighRow < rows - 1
                        vaHighRow += 1
                        cumVA += array.get(profile, vaHighRow)
                    else if vaLowRow > 0
                        vaLowRow -= 1
                        cumVA += array.get(profile, vaLowRow)
                else
                    if vaLowRow > 0
                        vaLowRow -= 1
                        cumVA += array.get(profile, vaLowRow)
                    else if vaHighRow < rows - 1
                        vaHighRow += 1
                        cumVA += array.get(profile, vaHighRow)

            // 5) Profile placement
            int widthBars = math.max(3, int(math.round(barsFound * profileWidthPct / 100.0)))
            int rawRight = rightIndex + gapBars + widthBars - 1
            int profileRight = int(math.min(bar_index + 490, rawRight))
            int levelRight = profileRight - widthBars

            // 6) Draw profile
            for r = 0 to rows - 1
                float rowVal = array.get(profile, r)
                if rowVal > 0
                    float y1 = rangeLow + r * step
                    float y2 = y1 + step

                    int barLen = math.max(1, int(math.round(widthBars * rowVal / maxVal)))
                    int leftX = profileRight - barLen + 1

                    bool inVA = r >= vaLowRow and r <= vaHighRow
                    color fillColor = r == pocRow ? pocRowColor : (inVA ? valueAreaColor : outsideVAColor)

                    box b = box.new(
                         leftX, y2, profileRight, y1,
                         xloc=xloc.bar_index,
                         bgcolor=fillColor,
                         border_color=color.new(color.white, 100))
                    array.push(profileBoxes, b)

            // 7) Prices
            float pocPrice = rangeLow + (pocRow + 0.5) * step
            float vahPrice = rangeLow + (vaHighRow + 1.0) * step
            float valPrice = rangeLow + vaLowRow * step

            // 8) Draw levels
            if showPOC
                pocLine := line.new(
                     leftIndex, pocPrice, levelRight, pocPrice,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     color=pocLineColor,
                     width=1,
                     style=line.style_solid)

            if showVAH
                vahLine := line.new(
                     leftIndex, vahPrice, levelRight, vahPrice,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     color=vahLineColor,
                     width=1,
                     style=line.style_dashed)

            if showVAL
                valLine := line.new(
                     leftIndex, valPrice, levelRight, valPrice,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     color=valLineColor,
                     width=1,
                     style=line.style_dashed)
````
