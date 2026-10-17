# Dr_iFractal

- url: https://www.tradingview.com/script/0lrGmjRY-Dr-iFractal/
- type: indicator
- pine_id: PUB;5a6c38e3985040608eeb0d228edb4688
- version: 5.0

## Description

it tries to find a smaller image that repeates on bigger image

## Source Code

````pine
//@version=6
indicator("Dr_iFractal", overlay=true, max_lines_count=500, max_labels_count=100, max_boxes_count=50)

// ── Inputs ──────────────────────────────────────────────────────────
int   smallBars     = input.int(50,    "Small Pattern Bars (History)", minval=5,   maxval=200)
int   bigBars       = input.int(200,   "Big Pattern Bars (Current)",  minval=20,  maxval=500)
int   scanHistory   = input.int(2000,  "Scan History Bars",           minval=100, maxval=5000)
float minSimilarity = input.float(50.0, "Min Similarity %",            minval=10,  maxval=99)
int   projectBars   = input.int(100,   "Forecast Bars",                minval=5,   maxval=500)
bool  lockPattern   = input.bool(false,"🔒 Lock Pattern")
color smallCol      = input.color(color.new(color.blue,   0),  "Source (Small) Box")
color greenBoxCol   = input.color(color.new(color.green,  0),  "Forecast Source Box")
color bigCol        = input.color(color.new(color.orange, 70), "Target (Big) Box")
color shapeCol      = input.color(color.new(color.blue,   0),  "Overlay Shape Line")
color projCol       = input.color(color.new(color.green,  0),  "Forecast Line")

// ── Persistent vars — data storage ──────────────────────────────────
var float savedSim        = 0.0
var int   savedSmallEnd   = -1 
var int   savedDetectBar  = -1

// ── MOBILE COMPATIBLE PERSISTENT DRAWINGS (One instance only) ───────
var box   srcBox     = box.new(na, na, na, na, border_color=smallCol, border_width=2, bgcolor=color.new(smallCol, 93))
var label srcLabel   = label.new(na, na, "", textcolor=smallCol, style=label.style_none, size=size.large)

var box   fcSrcBox   = box.new(na, na, na, na, border_color=greenBoxCol, border_width=2, bgcolor=color.new(greenBoxCol, 93))

var box   tgtBox     = box.new(na, na, na, na, border_color=bigCol, border_width=2, bgcolor=color.new(bigCol, 90))

// Pre-allocate line arrays for the overlay and forecast paths to modify them dynamically
var line[] overlayLines = array.new_line()
var line[] forecastLines = array.new_line()
var label statusLabel = label.new(na, na, "", textcolor=color.gray, style=label.style_none, size=size.tiny)

// Initialize line pools on the first bar calculation
if barstate.isfirst
    for i = 0 to 200
        array.push(overlayLines, line.new(na, na, na, na, color=shapeCol, width=2))
        array.push(forecastLines, line.new(na, na, na, na, color=projCol, width=2))

// ── Functions ────────────────────────────────────────────────────────
normalize(float[] src) =>
    float mn  = array.min(src)
    float mx  = array.max(src)
    float rng = mx - mn
    float[] dst = array.new_float(array.size(src), 0.0)
    for i = 0 to array.size(src) - 1
        float v = rng > 0.0 ? (array.get(src, i) - mn) / rng : 0.5
        array.set(dst, i, v)
    dst

similarity(float[] p1, float[] p2) =>
    int   sz   = array.size(p1)
    float diff = 0.0
    for i = 0 to sz - 1
        diff += math.abs(array.get(p1, i) - array.get(p2, i))
    (1.0 - diff / sz) * 100.0

// ── Global Scope TA Functions ────────────────────────────────────────
float globalBigHigh = ta.highest(high, bigBars)
float globalBigLow  = ta.lowest(low, bigBars)

// ── Main Execution ───────────────────────────────────────────────────
if barstate.islast
    // ── 1. Build Target Pattern (Current 200 Bars) Left-to-Right ──
    float[] bigSampled = array.new_float(smallBars, 0.0)
    float   bStep      = (bigBars - 1.0) / (smallBars - 1.0)
    for i = 0 to smallBars - 1
        int offset = bigBars - 1 - math.round(i * bStep)
        array.set(bigSampled, i, close[math.max(0, offset)])
    float[] bigNorm = normalize(bigSampled)

    float bigHigh  = globalBigHigh
    float bigLow   = globalBigLow
    float bigRange = bigHigh - bigLow
    float bigPad   = bigRange * 0.03

    // ── 2. Historical Scanner ──────────────────────────────────────────
    float bestSim    = 0.0
    int   bestEndIdx = -1

    if not lockPattern
        int minScan = bigBars + 10
        int maxScan = math.min(scanHistory, bar_index - smallBars - projectBars - 5)
        
        if maxScan > minScan
            for b = minScan to maxScan
                float[] sRaw = array.new_float(smallBars, 0.0)
                int startBarOffset = b + smallBars - 1
                
                for i = 0 to smallBars - 1
                    array.set(sRaw, i, close[startBarOffset - i])
                    
                float sim = similarity(bigNorm, normalize(sRaw))
                if sim > bestSim
                    bestSim    := sim
                    bestEndIdx := b

        if bar_index != savedDetectBar and bestSim >= minSimilarity and bestSim > savedSim + 1.0
            savedSim      := bestSim
            savedSmallEnd := bestEndIdx
            savedDetectBar := bar_index

    float drawSim      = savedSim
    int   drawSmallEnd = savedSmallEnd

    // Hide everything by default to manage state redraw changes cleanly
    box.set_lefttop(srcBox, na, na), box.set_rightbottom(srcBox, na, na), label.set_xy(srcLabel, na, na)
    box.set_lefttop(fcSrcBox, na, na), box.set_rightbottom(fcSrcBox, na, na)
    box.set_lefttop(tgtBox, na, na), box.set_rightbottom(tgtBox, na, na)
    label.set_xy(statusLabel, na, na)
    for i = 0 to 200 - 1
        line.set_xy1(array.get(overlayLines, i), na, na), line.set_xy2(array.get(overlayLines, i), na, na)
        line.set_xy1(array.get(forecastLines, i), na, na), line.set_xy2(array.get(forecastLines, i), na, na)

    // ── 3. Engine Rendering Block (Modifying persistent pointers instead of creating new instances) ──
    if drawSmallEnd > 0 and drawSim >= minSimilarity
        int sLookbackEnd   = drawSmallEnd
        int sLookbackStart = drawSmallEnd + smallBars - 1
        
        float sH = high[sLookbackEnd]
        float sL = low[sLookbackEnd]
        for i = 0 to smallBars - 1
            sH := math.max(sH, high[sLookbackEnd + i])
            sL := math.min(sL, low[sLookbackEnd + i])
        float sP = (sH - sL) * 0.03

        // Move the persistent Source Blue Box
        box.set_lefttop(srcBox, bar_index - sLookbackStart, sH + sP)
        box.set_rightbottom(srcBox, bar_index - sLookbackEnd, sL - sP)
        label.set_xy(srcLabel, bar_index - sLookbackStart, sH + sP * 4)
        label.set_text(srcLabel, "Source (" + str.tostring(drawSim, "#.0") + "%)")

        // Move the persistent Forecast Source Green Box (No text label added)
        int gLookbackStart = sLookbackEnd - 1
        int gLookbackEnd   = math.max(0, sLookbackEnd - projectBars)
        
        float gH = high[gLookbackEnd]
        float gL = low[gLookbackEnd]
        for i = 0 to (gLookbackStart - gLookbackEnd)
            gH := math.max(gH, high[gLookbackEnd + i])
            gL := math.min(gL, low[gLookbackEnd + i])
        float gP = (gH - gL) * 0.03

        box.set_lefttop(fcSrcBox, bar_index - gLookbackStart, gH + gP)
        box.set_rightbottom(fcSrcBox, bar_index - gLookbackEnd, gL - gP)

        // Move the persistent Target Orange Box
        int bigStartBar = bar_index - bigBars + 1
        box.set_lefttop(tgtBox, bigStartBar, bigHigh + bigPad)
        box.set_rightbottom(tgtBox, bar_index, bigLow - bigPad)

        // Morph the pre-allocated Overlay Lines
        float[] srcPatternRaw = array.new_float(smallBars, 0.0)
        for i = 0 to smallBars - 1
            array.set(srcPatternRaw, i, close[sLookbackStart - i])
        float[] srcPatternNorm = normalize(srcPatternRaw)

        for i = 0 to math.min(smallBars - 2, 199)
            float fracA = i / (smallBars - 1.0)
            float fracB = (i + 1.0) / (smallBars - 1.0)
            int   barX1 = bigStartBar + math.round(fracA * (bigBars - 1))
            int   barX2 = bigStartBar + math.round(fracB * (bigBars - 1))
            float y1    = bigLow + array.get(srcPatternNorm, i) * bigRange
            float y2    = bigLow + array.get(srcPatternNorm, i + 1) * bigRange
            
            line l = array.get(overlayLines, i)
            line.set_xy1(l, barX1, y1)
            line.set_xy2(l, barX2, y2)

        // Morph the pre-allocated Forecast Lines
        int actualProjLen = projectBars
        if sLookbackEnd - actualProjLen < 0
            actualProjLen := sLookbackEnd

        if actualProjLen > 5
            float[] rawProjArray = array.new_float(actualProjLen + 1, 0.0)
            array.set(rawProjArray, 0, close[sLookbackEnd])
            for i = 1 to actualProjLen
                array.set(rawProjArray, i, close[sLookbackEnd - i])
            
            float srcMin = array.min(srcPatternRaw)
            float srcMax = array.max(srcPatternRaw)
            float srcRng = srcMax - srcMin <= 0 ? 1.0 : srcMax - srcMin
            
            float[] normProjArray = array.new_float(actualProjLen + 1, 0.0)
            for i = 0 to actualProjLen
                array.set(normProjArray, i, (array.get(rawProjArray, i) - srcMin) / srcRng)

            float lastLimeY = bigLow + array.get(srcPatternNorm, smallBars - 1) * bigRange
            float anchorOffset = array.get(normProjArray, 0)
            
            for i = 0 to math.min(actualProjLen - 1, 199)
                float py1 = lastLimeY + (array.get(normProjArray, i) - anchorOffset) * bigRange
                float py2 = lastLimeY + (array.get(normProjArray, i + 1) - anchorOffset) * bigRange
                
                line l = array.get(forecastLines, i)
                line.set_xy1(l, bar_index + i, py1)
                line.set_xy2(l, bar_index + i + 1, py2)
    else
        label.set_xy(statusLabel, bar_index, close)
        label.set_text(statusLabel, "Searching Fixed Fractals... (" + str.tostring(math.round(bestSim)) + "%)")
````
