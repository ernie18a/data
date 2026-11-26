# Dual Volume Profile 

- url: https://www.tradingview.com/script/fHLjgr8p-Dual-Volume-Profile/
- type: indicator
- pine_id: PUB;476253226b234e2bb0c606d45d175099
- version: 1.0

## Description

Dual Volume Profile overlays two independent volume profiles on your chart simultaneously: a session profile built from intraday trading hours, and a composite range profile built from a configurable lookback period. Comparing the two reveals whether short-term auction activity is confirming or diverging from the broader volume structure.

Inspired by TradingView's built-in VRVP and SVP HD indicators, the Dual VP combines both concepts into a single overlay — pairing the structural range view of VRVP with the per-session granularity of SVP HD — and adds a signal layer that detects when the two profiles agree or diverge.

[b]Session profile[/b]

Builds a volume-at-price histogram for each trading session using your selected hours — CME RTH, NYSE RTH, Full Globex, or a custom window. Up to 5 historical sessions are displayed alongside the current developing session. Each session shows its own POC, VAH, and VAL.

[b]Range profile[/b]

Builds a composite volume-at-price histogram across a configurable lookback (default 200 bars). This acts as a multi-session structural view similar to TradingView's built-in VRVP, positioned in the right margin of the chart. POC, VAH, and VAL are drawn across the full range.

[b]Signals[/b]

The indicator generates three optional signals based on the relationship between the session and range profiles:

POC Alignment — fires when the session POC and range POC converge within a user-defined threshold, indicating agreement on fair value between the short-term and structural auctions.

Dual VA Breakout — fires when price trades above both value area highs or below both value area lows simultaneously, suggesting a directional move accepted by both timeframes.

VA Divergence — fires when the session's value area midpoint shifts significantly away from the range's value area midpoint, indicating the developing session is repricing relative to the composite structure.

[b]How to use it[/b]

Add the indicator and select the session type matching your instrument. The session profiles draw inline over price history; the range profile anchors to the right margin. Use the info table (top-right by default) to monitor both sets of levels and active signals at a glance. Session transparency is adjustable so the histograms don't obscure candles.

[b]Settings overview[/b]

Session Type, Sessions to Show, Session Bar Thickness, Session Transparency, Lookback Bars, Right Margin Offset, Price Rows (session and range independently), Value Area %, Up/Down volume colors, POC/VA line visibility, and signal thresholds for alignment, breakout, and divergence.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © yundore

//@version=6
indicator("Dual Volume Profile [Yun's Lab]", overlay=true, max_boxes_count=500, max_lines_count=100, max_labels_count=50, max_bars_back=5000)

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// --- Session Profile ---
string grpS = "Session Profile"
string sessType = input.string("CME RTH (8:30-15:15 CT)", "Session Type",
     options=["CME RTH (8:30-15:15 CT)", "NYSE RTH (8:30-15:00 CT)", "Full Globex (17:00-16:00 CT)", "Custom"],
     group=grpS,
     tooltip="Which trading hours build the session volume profile.")
string sessCustom = input.session("0830-1515:23456", "Custom Session", group=grpS,
     tooltip="Only active when Session Type = Custom.")
int maxSessions = input.int(3, "Sessions to Show", minval=1, maxval=5, group=grpS,
     tooltip="Number of historical sessions to display.\nMore sessions = more boxes used (TV has a 500 box limit).")
int sessHistoWidth = input.int(50, "Session Bar Thickness (bars)", minval=10, maxval=150, step=10, group=grpS,
     tooltip="How wide each session histogram extends leftward from the session boundary.")
int sessTransparency = input.int(60, "Session Transparency", minval=0, maxval=95, step=5, group=grpS,
     tooltip="Higher = more see-through so candles stay readable.\n0 = fully opaque, 90 = nearly invisible.")

// --- Range Profile ---
string grpR = "Range Profile"
int rangeLookback = input.int(200, "Lookback Bars", minval=50, maxval=1000, step=50, group=grpR,
     tooltip="How far back the range profile looks.\n200 on 5-min ≈ 3 sessions.")
int rangeBarWidth = input.int(200, "Bar Thickness (bars)", minval=50, maxval=400, step=10, group=grpR,
     tooltip="How thick the range histogram bars are.\nBigger = fatter bars like the built-in VRVP.")
int rangeRightEdge = input.int(150, "Right Edge (bars from last candle)", minval=10, maxval=400, step=10, group=grpR,
     tooltip="How far right of the last candle the histogram's right edge sits.\nIncrease until flush with the price scale.\nYou may also need to drag TradingView's price scale left\nto create more right margin space.")

// --- Calculation ---
string grpC = "Calculation"
int sessRows = input.int(40, "Session Price Rows", minval=20, maxval=80, step=10, group=grpC,
     tooltip="Price buckets for session profiles.\nKeep lower to stay within TradingView's 500 box limit.")
int rangeRows = input.int(100, "Range Price Rows", minval=40, maxval=200, step=10, group=grpC,
     tooltip="Price buckets for the range profile.\nMore rows = denser, thicker look matching the built-in VRVP.")
float vaPct = input.float(70.0, "Value Area %", minval=50.0, maxval=90.0, step=5.0, group=grpC)

// --- Colors ---
string grpClr = "Colors"
color upClr   = input.color(color.new(#00BCD4, 30), "Up Volume", group=grpClr)
color dnClr   = input.color(color.new(#E91E63, 30), "Down Volume", group=grpClr)

// --- Visuals ---
string grpV = "Visual Display"
bool showSess   = input.bool(true, "Show Session Profiles", group=grpV)
bool showRange  = input.bool(true, "Show Range Profile", group=grpV)
bool showPOC    = input.bool(true, "Show POC Lines", group=grpV)
bool showVA     = input.bool(true, "Show Value Area Lines", group=grpV)
bool showTable  = input.bool(true, "Show Info Table", group=grpV)
string tblPos   = input.string("Top Right", "Table Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpV)

// --- Signals ---
string grpSig = "Signals"
bool sigAlign    = input.bool(true, "POC Alignment Signal", group=grpSig)
bool sigBreakout = input.bool(true, "Dual VA Breakout Signal", group=grpSig)
bool sigDiverge  = input.bool(true, "VA Divergence Signal", group=grpSig)
float alignTol   = input.float(0.3, "Alignment Threshold (%)", minval=0.05, maxval=2.0, step=0.05, group=grpSig)
float divTol     = input.float(30.0, "Divergence Threshold (%)", minval=10.0, maxval=80.0, step=5.0, group=grpSig)

// ══════════════════════════════════════════════════════════════════════════════
//  SESSION TRACKING
// ══════════════════════════════════════════════════════════════════════════════

sessString() =>
    switch sessType
        "CME RTH (8:30-15:15 CT)"       => "0830-1515:23456"
        "NYSE RTH (8:30-15:00 CT)"       => "0830-1500:23456"
        "Full Globex (17:00-16:00 CT)"   => "1700-1600:12345"
        "Custom"                          => sessCustom
        => "0830-1515:23456"

string sStr        = sessString()
bool   inSess      = not na(time(timeframe.period, sStr))
var bool prevInSess = false
bool   newSess     = inSess and not prevInSess
prevInSess        := inSess

var array<int> sessStarts = array.new_int()
var array<int> sessEnds   = array.new_int()
var int curSessStart      = 0

if newSess
    if curSessStart > 0
        array.push(sessStarts, curSessStart)
        array.push(sessEnds, bar_index - 1)
        // Trim arrays to keep only what we need (maxSessions + 1 buffer)
        int maxKeep = maxSessions + 1
        while array.size(sessStarts) > maxKeep
            array.shift(sessStarts)
            array.shift(sessEnds)
    curSessStart := bar_index

// ══════════════════════════════════════════════════════════════════════════════
//  PROFILE CALCULATION
// ══════════════════════════════════════════════════════════════════════════════

calcProfileRange(int fromBar, int toBar, int rows) =>
    int barsBack = math.min(bar_index - fromBar, 4000)
    int barsEnd  = math.min(bar_index - toBar, 4000)

    float rH = high[barsEnd]
    float rL = low[barsEnd]
    for i = barsEnd to barsBack
        if i >= 0
            rH := math.max(rH, high[i])
            rL := math.min(rL, low[i])

    float bSz = (rH - rL) / rows
    if bSz <= 0
        bSz := syminfo.mintick

    upArr = array.new_float(rows, 0.0)
    dnArr = array.new_float(rows, 0.0)
    float totV = 0.0
    float maxV = 0.0

    for i = barsEnd to barsBack
        if i >= 0
            float mid = (high[i] + low[i]) / 2.0
            int   bkt = math.max(0, math.min(int(math.floor((mid - rL) / bSz)), rows - 1))
            float v   = nz(volume[i])
            if close[i] >= open[i]
                array.set(upArr, bkt, array.get(upArr, bkt) + v)
            else
                array.set(dnArr, bkt, array.get(dnArr, bkt) + v)
            float rowT = array.get(upArr, bkt) + array.get(dnArr, bkt)
            maxV := math.max(maxV, rowT)
            totV += v

    // POC
    int   pocBkt = 0
    float pocMax = 0.0
    for i = 0 to rows - 1
        float rowV = array.get(upArr, i) + array.get(dnArr, i)
        if rowV > pocMax
            pocMax := rowV
            pocBkt := i

    float pocP = rL + (pocBkt + 0.5) * bSz

    // Value Area
    float vaVol  = array.get(upArr, pocBkt) + array.get(dnArr, pocBkt)
    float target = totV * (vaPct / 100.0)
    int   vahBkt = pocBkt
    int   valBkt = pocBkt

    for _iter = 0 to rows
        if vaVol >= target
            break
        if vahBkt >= rows - 1 and valBkt <= 0
            break
        float upNext = vahBkt < rows - 1 ? array.get(upArr, vahBkt + 1) + array.get(dnArr, vahBkt + 1) : 0.0
        float dnNext = valBkt > 0        ? array.get(upArr, valBkt - 1) + array.get(dnArr, valBkt - 1) : 0.0
        if upNext >= dnNext
            if vahBkt < rows - 1
                vahBkt += 1
                vaVol  += upNext
            else if valBkt > 0
                valBkt -= 1
                vaVol  += dnNext
            else
                break
        else
            if valBkt > 0
                valBkt -= 1
                vaVol  += dnNext
            else if vahBkt < rows - 1
                vahBkt += 1
                vaVol  += upNext
            else
                break

    float vahP = rL + (vahBkt + 1) * bSz
    float valP = rL + valBkt * bSz

    [upArr, dnArr, rH, rL, pocP, vahP, valP, bSz, maxV]

calcProfileLookback(int lookback, int rows) =>
    int fromBar = math.max(0, bar_index - lookback)
    calcProfileRange(fromBar, bar_index, rows)

// ══════════════════════════════════════════════════════════════════════════════
//  DRAWING STORAGE & CLEANUP
// ══════════════════════════════════════════════════════════════════════════════

var box[]   dBoxes  = array.new_box()
var line[]  dLines  = array.new_line()
var label[] dLabels = array.new_label()

clearAll() =>
    while array.size(dBoxes) > 0
        box.delete(array.pop(dBoxes))
    while array.size(dLines) > 0
        line.delete(array.pop(dLines))
    while array.size(dLabels) > 0
        label.delete(array.pop(dLabels))

// ══════════════════════════════════════════════════════════════════════════════
//  DRAWING HELPERS
// ══════════════════════════════════════════════════════════════════════════════

drawHistoLeft(array<float> upArr, array<float> dnArr, float rngLow, float bSz, float maxV, int anchorRight, int maxW, color upC, color dnC) =>
    if maxV > 0
        int rows = array.size(upArr)
        for i = 0 to rows - 1
            float uv = array.get(upArr, i)
            float dv = array.get(dnArr, i)
            float tv = uv + dv
            if tv > 0
                float top = rngLow + (i + 1) * bSz
                float bot = rngLow + i * bSz
                int totalW = math.max(1, int(math.round(tv / maxV * maxW)))
                float upRatio = tv > 0 ? uv / tv : 0.5
                int upW = math.max(0, int(math.round(totalW * upRatio)))
                int dnW = math.max(0, totalW - upW)
                if dnW > 0
                    b = box.new(anchorRight - dnW, top, anchorRight, bot, border_color=color.new(dnC, 90), bgcolor=dnC, border_width=0)
                    array.push(dBoxes, b)
                if upW > 0
                    b = box.new(anchorRight - dnW - upW, top, anchorRight - dnW, bot, border_color=color.new(upC, 90), bgcolor=upC, border_width=0)
                    array.push(dBoxes, b)

drawLevels(int leftBar, int rightBar, float poc, float vah, float val) =>
    if showPOC
        l = line.new(leftBar, poc, rightBar, poc, color=color.white, style=line.style_solid, width=1)
        array.push(dLines, l)
    if showVA
        l1 = line.new(leftBar, vah, rightBar, vah, color=color.new(color.white, 60), style=line.style_dotted, width=1)
        l2 = line.new(leftBar, val, rightBar, val, color=color.new(color.white, 60), style=line.style_dotted, width=1)
        array.push(dLines, l1)
        array.push(dLines, l2)

tablePos() =>
    switch tblPos
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        => position.top_right

// ══════════════════════════════════════════════════════════════════════════════
//  MAIN LOGIC — LAST BAR ONLY
// ══════════════════════════════════════════════════════════════════════════════

var table infoTbl = na

if barstate.islast
    clearAll()

    int totalSessions = array.size(sessStarts)

    float sPoc = na
    float sVah = na
    float sVal = na

    // Session colors with user-controlled transparency
    color sessUpClr = color.new(upClr, sessTransparency)
    color sessDnClr = color.new(dnClr, sessTransparency)

    // ═══════════════════════════════════════════════════════════════════
    //  SESSION PROFILES
    // ═══════════════════════════════════════════════════════════════════

    if showSess
        int startFrom = math.max(0, totalSessions - maxSessions)
        for s = startFrom to totalSessions - 1
            int sStart = array.get(sessStarts, s)
            int sEnd   = array.get(sessEnds, s)
            if sEnd > 0 and sStart < sEnd
                [upA, dnA, sH, sL, poc, vah, val, bsz, mx] = calcProfileRange(sStart, sEnd, sessRows)
                drawHistoLeft(upA, dnA, sL, bsz, mx, sEnd, sessHistoWidth, sessUpClr, sessDnClr)
                drawLevels(sStart, sEnd, poc, vah, val)

        // Current developing session
        if curSessStart > 0 and bar_index > curSessStart
            [csUp, csDn, csH, csL, csPoc, csVah, csVal, csBsz, csMx] = calcProfileRange(curSessStart, bar_index, sessRows)
            drawHistoLeft(csUp, csDn, csL, csBsz, csMx, bar_index, sessHistoWidth, sessUpClr, sessDnClr)
            sPoc := csPoc
            sVah := csVah
            sVal := csVal
            drawLevels(curSessStart, bar_index, csPoc, csVah, csVal)

    // ═══════════════════════════════════════════════════════════════════
    //  RANGE PROFILE — right edge anchored to bar_index + rangeRightEdge
    // ═══════════════════════════════════════════════════════════════════

    float rPoc = na
    float rVah = na
    float rVal = na
    float rH   = na
    float rL   = na

    if showRange
        int rightAnchor = bar_index + rangeRightEdge
        [rUpA, rDnA, rrH, rrL, rrPoc, rrVah, rrVal, rBsz, rMx] = calcProfileLookback(rangeLookback, rangeRows)
        rPoc := rrPoc
        rVah := rrVah
        rVal := rrVal
        rH   := rrH
        rL   := rrL
        drawHistoLeft(rUpA, rDnA, rrL, rBsz, rMx, rightAnchor, rangeBarWidth, upClr, dnClr)
        drawLevels(bar_index - rangeLookback, rightAnchor, rrPoc, rrVah, rrVal)

    // ═══════════════════════════════════════════════════════════════════
    //  SIGNALS
    // ═══════════════════════════════════════════════════════════════════

    bool alignFired  = false
    bool breakFired  = false
    bool divFired    = false
    string divDir    = ""

    float rangeHeight = na(rH) or na(rL) ? 0.0 : rH - rL

    if sigAlign and not na(sPoc) and not na(rPoc) and rangeHeight > 0
        float pocDist = math.abs(sPoc - rPoc)
        if pocDist <= rangeHeight * (alignTol / 100.0)
            alignFired := true
            float midP = math.avg(sPoc, rPoc)
            lb = label.new(bar_index, midP, "POC ALIGN", color=color.new(#00C853, 15), textcolor=color.white, style=label.style_label_right, size=size.small)
            array.push(dLabels, lb)
            alert("POC Alignment at " + str.tostring(midP, format.mintick), alert.freq_once_per_bar_close)

    if sigBreakout and not na(sVah) and not na(rVah) and not na(sVal) and not na(rVal)
        bool aboveBoth = close > sVah and close > rVah
        bool belowBoth = close < sVal and close < rVal
        if aboveBoth
            breakFired := true
            lb = label.new(bar_index, high, "DUAL BO", color=color.new(#00BFA5, 15), textcolor=color.white, style=label.style_label_down, size=size.small)
            array.push(dLabels, lb)
            alert("Dual VA Breakout UP", alert.freq_once_per_bar_close)
        if belowBoth
            breakFired := true
            lb = label.new(bar_index, low, "DUAL BD", color=color.new(#FF1744, 15), textcolor=color.white, style=label.style_label_up, size=size.small)
            array.push(dLabels, lb)
            alert("Dual VA Breakdown", alert.freq_once_per_bar_close)

    if sigDiverge and not na(sVah) and not na(sVal) and not na(rVah) and not na(rVal)
        float sessMid = math.avg(sVah, sVal)
        float rngMid  = math.avg(rVah, rVal)
        float rngW    = rVah - rVal
        if rngW > 0
            float pctShift = (sessMid - rngMid) / rngW * 100.0
            if math.abs(pctShift) >= divTol
                divFired := true
                divDir   := pctShift > 0 ? "BULL" : "BEAR"
                string dTxt = pctShift > 0 ? "VA DIV UP" : "VA DIV DN"
                color  dClr = pctShift > 0 ? color.new(#00BFA5, 20) : color.new(#FF1744, 20)
                float  dY   = pctShift > 0 ? sVah : sVal
                lb = label.new(bar_index - 8, dY, dTxt, color=dClr, textcolor=color.white, style=pctShift > 0 ? label.style_label_down : label.style_label_up, size=size.small)
                array.push(dLabels, lb)
                alert("VA Divergence " + divDir, alert.freq_once_per_bar_close)

    // ═══════════════════════════════════════════════════════════════════
    //  INFO TABLE
    // ═══════════════════════════════════════════════════════════════════

    if showTable
        if not na(infoTbl)
            table.delete(infoTbl)
        infoTbl := table.new(tablePos(), 3, 8,
             bgcolor=color.new(#1E1E1E, 5), border_color=color.new(color.gray, 60), border_width=1,
             frame_color=color.new(color.gray, 40), frame_width=1)

        table.cell(infoTbl, 0, 0, "DUAL VP",  text_color=color.white, text_size=size.small, bgcolor=color.new(#333333, 0))
        table.cell(infoTbl, 1, 0, "Session",  text_color=upClr,       text_size=size.small, bgcolor=color.new(#333333, 0))
        table.cell(infoTbl, 2, 0, "Range",    text_color=dnClr,       text_size=size.small, bgcolor=color.new(#333333, 0))

        string sPocTxt = not na(sPoc) ? str.tostring(sPoc, format.mintick) : "---"
        string sVahTxt = not na(sVah) ? str.tostring(sVah, format.mintick) : "---"
        string sValTxt = not na(sVal) ? str.tostring(sVal, format.mintick) : "---"
        string rPocTxt = not na(rPoc) ? str.tostring(rPoc, format.mintick) : "---"
        string rVahTxt = not na(rVah) ? str.tostring(rVah, format.mintick) : "---"
        string rValTxt = not na(rVal) ? str.tostring(rVal, format.mintick) : "---"

        table.cell(infoTbl, 0, 1, "POC", text_color=color.gray, text_size=size.small)
        table.cell(infoTbl, 1, 1, sPocTxt, text_color=color.white, text_size=size.small)
        table.cell(infoTbl, 2, 1, rPocTxt, text_color=color.white, text_size=size.small)

        table.cell(infoTbl, 0, 2, "VAH", text_color=color.gray, text_size=size.small)
        table.cell(infoTbl, 1, 2, sVahTxt, text_color=color.white, text_size=size.small)
        table.cell(infoTbl, 2, 2, rVahTxt, text_color=color.white, text_size=size.small)

        table.cell(infoTbl, 0, 3, "VAL", text_color=color.gray, text_size=size.small)
        table.cell(infoTbl, 1, 3, sValTxt, text_color=color.white, text_size=size.small)
        table.cell(infoTbl, 2, 3, rValTxt, text_color=color.white, text_size=size.small)

        table.cell(infoTbl, 0, 4, "-----", text_color=color.gray, text_size=size.small)
        table.cell(infoTbl, 1, 4, "-----", text_color=color.gray, text_size=size.small)
        table.cell(infoTbl, 2, 4, "-----", text_color=color.gray, text_size=size.small)

        table.cell(infoTbl, 0, 5, "Signals", text_color=color.white, text_size=size.small, bgcolor=color.new(#333333, 0))
        table.merge_cells(infoTbl, 0, 5, 2, 5)

        string alignTxt = alignFired ? "ACTIVE" : "---"
        color  alignC   = alignFired ? #00C853 : color.gray
        table.cell(infoTbl, 0, 6, "POC Align", text_color=color.gray, text_size=size.small)
        table.cell(infoTbl, 1, 6, alignTxt, text_color=alignC, text_size=size.small)
        table.merge_cells(infoTbl, 1, 6, 2, 6)

        string brkTxt = breakFired ? "ACTIVE" : "---"
        color  brkC   = breakFired ? #FF6D00 : color.gray
        table.cell(infoTbl, 0, 7, "Dual VA", text_color=color.gray, text_size=size.small)
        table.cell(infoTbl, 1, 7, brkTxt, text_color=brkC, text_size=size.small)
        table.merge_cells(infoTbl, 1, 7, 2, 7)
````
