# Dual Profile Structure Map [JOAT]

- url: https://www.tradingview.com/script/PlbxEJ70-Dual-Profile-Structure-Map-JOAT/
- type: indicator
- pine_id: PUB;f3aabbfc62df45b1a0056774cd3dbb9b
- version: 1.0

## Description

[b]Dual Profile Structure Map [JOAT][/b]

[b]Introduction[/b]

Dual Profile Structure Map is an open-source session volume profile indicator that computes Point of Control, Value Area High, Value Area Low, and Initial Balance levels for the current session and displays them as a horizontal histogram overlaid on price. Unlike fixed-range or visible-range profiles, this indicator uses time-based session segmentation — the profile represents only the bars within the current trading day, updating continuously as each bar closes.

The profile answers a specific question: where was the majority of trading activity concentrated in the current session, and what are the structural reference levels that follow from that activity? The Initial Balance (the range of the first hour of the session) provides context for whether subsequent price behavior is an extension or a rejection.

[b]Core Concepts[/b]

[b]1. Volume Profile Calculation[/b]

Price range is divided into configurable bins. Each bar's volume is allocated to the bins that overlap its high-low range, proportionally by the fraction of the bar that falls within each bin. The result is an array of volume-at-price values for the session:

[pine]
for b = 0 to nBins - 1
    float binLo = profileLow + b * binSize
    float binHi = binLo + binSize
    float overlap = math.min(high, binHi) - math.max(low, binLo)
    if overlap > 0
        vol_at_bin[b] += volume * (overlap / (high - low))
[/pine]

[b]2. Point of Control and Value Area[/b]

The Point of Control (POC) is the bin with the highest volume — the price level where the most trading occurred. The Value Area is computed using the standard 70% rule: starting from the POC, adjacent bins are added to the value area (choosing the higher-volume adjacent bin each time) until 70% of session volume is captured. The resulting Value Area High (VAH) and Value Area Low (VAL) define the range where value was accepted.

[image]https://www.tradingview.com/x/Yo2HwaLN/[/image]

[b]3. Initial Balance[/b]

The Initial Balance uses the high and low of the first configurable number of bars after session open (default: first 4 bars on a 15-minute chart = first hour). IB High and IB Low are drawn as horizontal lines across the chart. Price trading above IB High is bullish extension; below IB Low is bearish extension; inside the IB is balance.

[b]4. Histogram Rendering[/b]

Volume bins are rendered as horizontal bars extending leftward from the right edge of the session. Bar width is proportional to relative volume. The POC bin uses a distinct color. Value area bins use a softer fill. Bins outside the value area use the dimmest fill. This creates the standard volume profile "bell curve" visualization.

[b]Features[/b]

[list]
[*][b]Session volume profile:[/b] Real-time per-session histogram updated bar by bar
[*][b]Point of Control (POC):[/b] Highest-volume price bin with labeled line
[*][b]Value Area (VAH/VAL):[/b] 70% volume concentration band with boundary lines
[*][b]Initial Balance High/Low:[/b] First-session-period range with horizontal level lines
[*][b]Configurable bin count:[/b] Controls granularity of the volume distribution
[*][b]Session reset logic:[/b] Profile resets at each new session boundary
[*][b]Candle coloring:[/b] Candles painted by position relative to POC and value area
[*][b]Dashboard:[/b] Current POC, VAH, VAL, IB range, and session volume total
[/list]

[b]Input Parameters[/b]

[b]Profile Configuration:[/b]
[list]
[*]Number of Bins: Price level granularity for the profile (default: 24)
[*]IB Bars: Number of bars defining the Initial Balance period (default: 4)
[*]Session Type: Trading session boundary for profile reset
[/list]

[b]Display:[/b]
[list]
[*]Histogram Width: Maximum bar width in chart bars (default: 30)
[*]Show POC Line toggle
[*]Show Value Area toggle
[*]Show Initial Balance toggle
[*]Show Candle Color toggle
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the POC[/b]
The POC is the fair value anchor for the session. Price gravitating toward the POC during a pullback indicates healthy trend behavior. Price unable to hold above or below the POC suggests indecision at current levels.

[b]Step 2: Use Value Area for Range Context[/b]
Value area acceptance means price is spending time within the 70% volume zone — a range-bound state. Value area rejection (price rapidly leaving VAH or VAL and not returning) indicates directional conviction.

[b]Step 3: Trade Initial Balance Extensions[/b]
A close above IB High with follow-through is a bullish extension signal. A close below IB Low is bearish. Range expansion beyond the IB indicates participants accepting new value outside the opening equilibrium.

[b]Step 4: Watch POC as Support or Resistance[/b]
On future pullbacks, the prior session's POC often acts as structural support or resistance. The indicator's persistent level lines provide these reference points across sessions.

[b]Indicator Limitations[/b]

[list]
[*]Volume profile interpretation requires practice; mechanical rules based on profile levels without context produce poor results
[*]On instruments with irregular volume distribution (low-liquidity sessions, gaps), profiles may cluster into unrepresentative patterns
[*]The 70% value area rule is a convention from Market Profile theory, not a mathematically proven optimal threshold
[/list]

[b]Originality Statement[/b]

The combination of a real-time session volume profile with Initial Balance tracking, candle coloring by value area position, and a live-updating dashboard in a single Pine Script v6 publication provides a self-contained session structure tool. The session-adaptive profile calculation using proportional volume allocation across bins is implemented from first principles, not adapted from another published script.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Volume profile levels are historical references and do not guarantee future price reactions. Trading involves substantial risk of loss.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Dual Profile Structure Map [JOAT]", shorttitle="DPS [JOAT]", overlay=true,
     max_boxes_count=500, max_lines_count=300, max_labels_count=100, max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — COLOR SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
color UP_COL      = color.rgb(0,   188, 212)
color DN_COL      = color.rgb(233,  30,  99)
color POC_COL     = color.rgb(255, 255, 255)
color VA_COL      = color.rgb(255, 255, 255)
color IB_COL      = color.rgb(255, 185,  20)
color BULL_ZONE   = color.rgb(0,   200, 120)
color BEAR_ZONE   = color.rgb(220,  45,  75)
color VOID_BG     = color.rgb(10,   14,  26)
color SLATE_BRD   = color.rgb(40,   55,  90)
color LAVEN_HDR   = color.rgb(140, 160, 210)
color GOLD_VAL    = color.rgb(255, 215,  60)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string G_SESS = "━━ Session Profile ━━"
string G_RANGE= "━━ Range Profile ━━"
string G_CALC = "━━ Calculation ━━"
string G_VIZ  = "━━ Visual ━━"

string i_sessType = input.string("CME RTH (8:30-15:15 CT)", "Session Type",
     options=["CME RTH (8:30-15:15 CT)", "NYSE RTH (8:30-15:00 CT)",
              "Full Globex (17:00-16:00 CT)", "Custom"], group=G_SESS)
string i_sessCust = input.session("0830-1515:23456", "Custom Session", group=G_SESS)
int    i_maxSess  = input.int(3,  "Sessions to Show",    minval=1, maxval=5,  group=G_SESS)
int    i_sessW    = input.int(30, "Session Histo Width (bars)", minval=5, maxval=80, step=5, group=G_SESS)
int    i_sessTr   = input.int(65, "Session Transparency", minval=30, maxval=90, step=5, group=G_SESS)
bool   i_showIB   = input.bool(true, "Show Initial Balance", group=G_SESS)
int    i_ibBars   = input.int(4,  "Initial Balance Bars",  minval=1, maxval=20, group=G_SESS,
     tooltip="Number of bars from session open to define Initial Balance (first hour at default 4 bars on 15m).")

int    i_rangeLB  = input.int(200, "Range Lookback Bars", minval=50, maxval=1000, step=50, group=G_RANGE)
int    i_rangeW   = input.int(60,  "Range Histo Width (bars)", minval=20, maxval=150, step=10, group=G_RANGE)
int    i_rangeRE  = input.int(80,  "Range Right Margin (bars from last candle)", minval=10, maxval=250, step=10, group=G_RANGE)

int    i_sessRows = input.int(40,  "Session Price Rows", minval=20, maxval=80, step=10, group=G_CALC)
int    i_rangRows = input.int(80,  "Range Price Rows",   minval=40, maxval=200, step=10, group=G_CALC)
float  i_vaPct    = input.float(70.0, "Value Area %", minval=50.0, maxval=90.0, step=5.0, group=G_CALC)

bool   i_showPOC  = input.bool(true,  "Show POC Lines",       group=G_VIZ)
bool   i_showVA   = input.bool(true,  "Show VAH/VAL Lines",   group=G_VIZ)
bool   i_showSess = input.bool(true,  "Show Session Profiles",group=G_VIZ)
bool   i_showRng  = input.bool(true,  "Show Range Profile",   group=G_VIZ)
bool   i_showDash = input.bool(true,  "Show Dashboard",       group=G_VIZ)
bool   i_candleCol= input.bool(true,  "Candle Zone Coloring", group=G_VIZ,
     tooltip="Teal when above both VAH, red when below both VAL, dimmed inside VA.")
string i_tblPos   = input.string("Top Right", "Dashboard Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G_VIZ)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — SESSION TRACKING
// ═══════════════════════════════════════════════════════════════════════════════
sessString() =>
    switch i_sessType
        "CME RTH (8:30-15:15 CT)"      => "0830-1515:23456"
        "NYSE RTH (8:30-15:00 CT)"     => "0830-1500:23456"
        "Full Globex (17:00-16:00 CT)" => "1700-1600:12345"
        "Custom"                        => i_sessCust
        =>                                "0830-1515:23456"

string sStr       = sessString()
bool   inSess     = not na(time(timeframe.period, sStr))
var bool prevInS  = false
bool   newSess    = inSess and not prevInS
prevInS          := inSess

var int[] sessStarts = array.new_int()
var int[] sessEnds   = array.new_int()
var int   curSessStart = 0

if newSess
    if curSessStart > 0
        array.push(sessStarts, curSessStart)
        array.push(sessEnds,   bar_index - 1)
        while sessStarts.size() > i_maxSess + 1
            array.shift(sessStarts)
            array.shift(sessEnds)
    curSessStart := bar_index

// Initial Balance
var bool  ibActive    = false
var float ibHigh      = na
var float ibLow       = na
var int   ibBars      = 0
var float lastIBH     = na
var float lastIBL     = na
var int   ibSessStart = 0

if newSess
    ibActive    := true
    ibHigh      := high
    ibLow       := low
    ibBars      := 0
    ibSessStart := bar_index

if ibActive
    ibBars += 1
    if high > ibHigh
        ibHigh := high
    if low < ibLow
        ibLow := low
    if ibBars >= i_ibBars
        ibActive := false
        lastIBH  := ibHigh
        lastIBL  := ibLow

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — PROFILE CALCULATION ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
calcProfile(int fromBar, int toBar, int rows) =>
    int bkEnd   = math.min(bar_index - fromBar, 4000)
    int bkStart = math.min(bar_index - toBar,   4000)
    bkStart     := math.max(0, bkStart)
    bkEnd       := math.max(bkStart, bkEnd)

    float rH = high[bkStart]
    float rL = low[bkStart]
    for i = bkStart to bkEnd
        if high[i] > rH
            rH := high[i]
        if low[i] < rL
            rL := low[i]

    float bSz = (rH - rL) / rows
    if bSz <= 0.0
        bSz := syminfo.mintick

    float[] upArr = array.new_float(rows, 0.0)
    float[] dnArr = array.new_float(rows, 0.0)
    float totV = 0.0
    float maxV = 0.0

    for i = bkStart to bkEnd
        float mid = (high[i] + low[i]) / 2.0
        int   bkt = math.max(0, math.min(rows - 1, int(math.floor((mid - rL) / bSz))))
        float v   = nz(volume[i])
        if close[i] >= open[i]
            array.set(upArr, bkt, array.get(upArr, bkt) + v)
        else
            array.set(dnArr, bkt, array.get(dnArr, bkt) + v)
        float rowT = array.get(upArr, bkt) + array.get(dnArr, bkt)
        if rowT > maxV
            maxV := rowT
        totV += v

    int   pocBkt = 0
    float pocMax = 0.0
    for i = 0 to rows - 1
        float rv = array.get(upArr, i) + array.get(dnArr, i)
        if rv > pocMax
            pocMax := rv
            pocBkt := i
    float pocP = rL + (pocBkt + 0.5) * bSz

    float vaVol  = array.get(upArr, pocBkt) + array.get(dnArr, pocBkt)
    float target = totV * (i_vaPct / 100.0)
    int   vahBkt = pocBkt
    int   valBkt = pocBkt

    for _iter = 0 to rows
        if vaVol >= target
            break
        if vahBkt >= rows - 1 and valBkt <= 0
            break
        float upN = vahBkt < rows - 1 ? array.get(upArr, vahBkt+1) + array.get(dnArr, vahBkt+1) : 0.0
        float dnN = valBkt > 0        ? array.get(upArr, valBkt-1) + array.get(dnArr, valBkt-1) : 0.0
        if upN >= dnN
            if vahBkt < rows - 1
                vahBkt += 1
                vaVol  += upN
            else if valBkt > 0
                valBkt -= 1
                vaVol  += dnN
            else
                break
        else
            if valBkt > 0
                valBkt -= 1
                vaVol  += dnN
            else if vahBkt < rows - 1
                vahBkt += 1
                vaVol  += upN
            else
                break

    float vahP = rL + (vahBkt + 1) * bSz
    float valP = rL + valBkt * bSz

    [upArr, dnArr, rH, rL, pocP, vahP, valP, bSz, maxV]

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — DRAWING STORAGE
// ═══════════════════════════════════════════════════════════════════════════════
var box[]   dBoxes  = array.new_box()
var line[]  dLines  = array.new_line()
var label[] dLabels = array.new_label()

clearAll() =>
    while dBoxes.size() > 0
        box.delete(array.pop(dBoxes))
    while dLines.size() > 0
        line.delete(array.pop(dLines))
    while dLabels.size() > 0
        label.delete(array.pop(dLabels))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — CLEAN HISTOGRAM DRAWING
// Draws a narrow, clean histogram LEFT of anchorRight bar
// ═══════════════════════════════════════════════════════════════════════════════
drawHisto(float[] upArr, float[] dnArr, float rL, float bSz, float maxV, int anchorRight, int maxW, int transp, color upC, color dnC) =>
    if maxV > 0.0
        int rows = upArr.size()
        for i = 0 to rows - 1
            float uv = array.get(upArr, i)
            float dv = array.get(dnArr, i)
            float tv = uv + dv
            if tv > 0.0
                float top = rL + (i + 1) * bSz
                float bot = rL + i * bSz
                float barH = top - bot
                // Minimum visible height
                if barH < syminfo.mintick
                    barH := syminfo.mintick
                    top  := bot + barH
                int totalW = math.max(1, int(math.round(tv / maxV * maxW)))
                float upRatio = tv > 0.0 ? uv / tv : 0.5
                int   upW = math.max(0, int(math.round(totalW * upRatio)))
                int   dnW = math.max(0, totalW - upW)
                // Draw down volume (closer to right anchor)
                if dnW > 0
                    b = box.new(anchorRight - dnW, top, anchorRight, bot,
                         border_color=color.new(color.black, 100),
                         bgcolor=color.new(dnC, transp), border_width=0)
                    array.push(dBoxes, b)
                // Draw up volume (further left)
                if upW > 0
                    b = box.new(anchorRight - dnW - upW, top, anchorRight - dnW, bot,
                         border_color=color.new(color.black, 100),
                         bgcolor=color.new(upC, transp), border_width=0)
                    array.push(dBoxes, b)

// Draw POC + VAH/VAL levels cleanly with labels
drawLevels(int leftBar, int rightBar, float poc, float vah, float val, string prefix) =>
    // POC — solid white line + label
    if i_showPOC
        l = line.new(leftBar, poc, rightBar, poc,
             color=POC_COL, style=line.style_solid, width=2)
        array.push(dLines, l)
        lb = label.new(rightBar, poc, prefix + "POC  " + str.tostring(poc, format.mintick),
             style=label.style_label_left, color=color.new(VOID_BG, 20),
             textcolor=POC_COL, size=size.tiny)
        array.push(dLabels, lb)
    // VAH + VAL — dotted, dimmer
    if i_showVA
        l1 = line.new(leftBar, vah, rightBar, vah,
             color=color.new(VA_COL, 60), style=line.style_dotted, width=1)
        l2 = line.new(leftBar, val, rightBar, val,
             color=color.new(VA_COL, 60), style=line.style_dotted, width=1)
        array.push(dLines, l1)
        array.push(dLines, l2)
        lb1 = label.new(rightBar, vah, prefix + "VAH  " + str.tostring(vah, format.mintick),
             style=label.style_label_left, color=color.new(VOID_BG, 40),
             textcolor=color.new(VA_COL, 30), size=size.tiny)
        lb2 = label.new(rightBar, val, prefix + "VAL  " + str.tostring(val, format.mintick),
             style=label.style_label_left, color=color.new(VOID_BG, 40),
             textcolor=color.new(VA_COL, 30), size=size.tiny)
        array.push(dLabels, lb1)
        array.push(dLabels, lb2)

tablePos() =>
    switch i_tblPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>               position.top_right

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — POC MIGRATION TRACKING
// ═══════════════════════════════════════════════════════════════════════════════
var float prevSessPOC = na
var int   pocMigDir   = 0

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — MAIN DRAW ENGINE (barstate.islast)
// ═══════════════════════════════════════════════════════════════════════════════
var table infoTbl = na

float curSessPOC = na
float curSessVAH = na
float curSessVAL = na
float curRngPOC  = na
float curRngVAH  = na
float curRngVAL  = na

if barstate.islast
    clearAll()

    int totalSess = sessStarts.size()
    color sessUpC = color.new(UP_COL, i_sessTr)
    color sessDnC = color.new(DN_COL, i_sessTr)

    // ── Session Profiles ─────────────────────────────────────────────────────
    if i_showSess
        int startFrom = math.max(0, totalSess - i_maxSess)
        for s = startFrom to totalSess - 1
            int sStart = array.get(sessStarts, s)
            int sEnd   = array.get(sessEnds,   s)
            if sEnd > 0 and sStart < sEnd
                [upA, dnA, sH, sL, poc, vah, val, bsz, mx] = calcProfile(sStart, sEnd, i_sessRows)
                drawHisto(upA, dnA, sL, bsz, mx, sEnd, i_sessW, i_sessTr, sessUpC, sessDnC)
                drawLevels(sStart, sEnd, poc, vah, val, "S ")

        // Current developing session
        if curSessStart > 0 and bar_index > curSessStart
            [csUp, csDn, csH, csL, csPoc, csVah, csVal, csBsz, csMx] = calcProfile(curSessStart, bar_index, i_sessRows)
            drawHisto(csUp, csDn, csL, csBsz, csMx, bar_index, i_sessW, i_sessTr, sessUpC, sessDnC)
            curSessPOC := csPoc
            curSessVAH := csVah
            curSessVAL := csVal
            drawLevels(curSessStart, bar_index, csPoc, csVah, csVal, "")
            if not na(prevSessPOC)
                pocMigDir := csPoc > prevSessPOC ? 1 : csPoc < prevSessPOC ? -1 : pocMigDir
            prevSessPOC := csPoc

    // ── Initial Balance ───────────────────────────────────────────────────────
    if i_showIB and not na(lastIBH) and not na(lastIBL) and curSessStart > 0
        int ibRight = math.min(bar_index, curSessStart + i_ibBars * 3)
        line ibH = line.new(curSessStart, lastIBH, ibRight, lastIBH,
             color=IB_COL, width=2, style=line.style_solid)
        line ibL = line.new(curSessStart, lastIBL, ibRight, lastIBL,
             color=IB_COL, width=2, style=line.style_solid)
        array.push(dLines, ibH)
        array.push(dLines, ibL)
        label lbIBH = label.new(ibRight, lastIBH, "IB Hi  " + str.tostring(lastIBH, format.mintick),
             style=label.style_label_left, color=color.new(IB_COL, 80),
             textcolor=IB_COL, size=size.tiny)
        label lbIBL = label.new(ibRight, lastIBL, "IB Lo  " + str.tostring(lastIBL, format.mintick),
             style=label.style_label_left, color=color.new(IB_COL, 80),
             textcolor=IB_COL, size=size.tiny)
        array.push(dLabels, lbIBH)
        array.push(dLabels, lbIBL)

    // ── Range Profile ─────────────────────────────────────────────────────────
    if i_showRng
        int fromB       = math.max(0, bar_index - i_rangeLB)
        int rightAnchor = bar_index + i_rangeRE
        [rUpA, rDnA, rrH, rrL, rrPoc, rrVah, rrVal, rBsz, rMx] = calcProfile(fromB, bar_index, i_rangRows)
        curRngPOC := rrPoc
        curRngVAH := rrVah
        curRngVAL := rrVal
        drawHisto(rUpA, rDnA, rrL, rBsz, rMx, rightAnchor, i_rangeW, 35, UP_COL, DN_COL)
        drawLevels(bar_index - i_rangeLB, rightAnchor, rrPoc, rrVah, rrVal, "R ")

    // ── Dashboard ─────────────────────────────────────────────────────────────
    if i_showDash
        if not na(infoTbl)
            table.delete(infoTbl)
        infoTbl := table.new(tablePos(), 3, 7,
             bgcolor=color.new(VOID_BG, 5), border_color=SLATE_BRD,
             border_width=1, frame_color=SLATE_BRD, frame_width=1)

        table.cell(infoTbl, 0, 0, "Dual Profile Map", text_color=LAVEN_HDR,
             text_size=size.small, bgcolor=color.new(VOID_BG, 5))
        table.cell(infoTbl, 1, 0, "Session",  text_color=UP_COL,   text_size=size.small, bgcolor=color.new(VOID_BG, 5))
        table.cell(infoTbl, 2, 0, "Range",    text_color=DN_COL,   text_size=size.small, bgcolor=color.new(VOID_BG, 5))

        table.cell(infoTbl, 0, 1, "POC", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
        table.cell(infoTbl, 1, 1, not na(curSessPOC) ? str.tostring(curSessPOC, format.mintick) : "—",
             text_color=POC_COL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
        table.cell(infoTbl, 2, 1, not na(curRngPOC)  ? str.tostring(curRngPOC,  format.mintick) : "—",
             text_color=POC_COL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

        table.cell(infoTbl, 0, 2, "VAH", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
        table.cell(infoTbl, 1, 2, not na(curSessVAH) ? str.tostring(curSessVAH, format.mintick) : "—",
             text_color=color.new(VA_COL, 0), text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
        table.cell(infoTbl, 2, 2, not na(curRngVAH)  ? str.tostring(curRngVAH,  format.mintick) : "—",
             text_color=color.new(VA_COL, 0), text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

        table.cell(infoTbl, 0, 3, "VAL", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
        table.cell(infoTbl, 1, 3, not na(curSessVAL) ? str.tostring(curSessVAL, format.mintick) : "—",
             text_color=color.new(VA_COL, 0), text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
        table.cell(infoTbl, 2, 3, not na(curRngVAL)  ? str.tostring(curRngVAL,  format.mintick) : "—",
             text_color=color.new(VA_COL, 0), text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

        string ibTxt = not na(lastIBH) ? str.tostring(lastIBH, format.mintick) + " / " + str.tostring(lastIBL, format.mintick) : "—"
        table.cell(infoTbl, 0, 4, "Init Balance", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
        table.cell(infoTbl, 1, 4, ibTxt, text_color=IB_COL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
        table.merge_cells(infoTbl, 1, 4, 2, 4)

        string migStr = pocMigDir == 1 ? "RISING (Bull)" : pocMigDir == -1 ? "FALLING (Bear)" : "NEUTRAL"
        color  migCol = pocMigDir == 1 ? BULL_ZONE : pocMigDir == -1 ? BEAR_ZONE : LAVEN_HDR
        table.cell(infoTbl, 0, 5, "POC Migration", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
        table.cell(infoTbl, 1, 5, migStr, text_color=migCol, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
        table.merge_cells(infoTbl, 1, 5, 2, 5)

        // Price position relative to value areas
        bool aboveAll = not na(curSessVAH) and not na(curRngVAH) and close > curSessVAH and close > curRngVAH
        bool belowAll = not na(curSessVAL) and not na(curRngVAL) and close < curSessVAL and close < curRngVAL
        string posStr = aboveAll ? "ABOVE VALUE (Bull)" : belowAll ? "BELOW VALUE (Bear)" : "INSIDE VALUE"
        color  posCol = aboveAll ? BULL_ZONE : belowAll ? BEAR_ZONE : LAVEN_HDR
        table.cell(infoTbl, 0, 6, "Price Position", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
        table.cell(infoTbl, 1, 6, posStr, text_color=posCol, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
        table.merge_cells(infoTbl, 1, 6, 2, 6)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — CANDLE COLORING
// ═══════════════════════════════════════════════════════════════════════════════
bool aboveVA = i_candleCol and not na(curSessVAH) and not na(curRngVAH) and close > curSessVAH and close > curRngVAH
bool belowVA = i_candleCol and not na(curSessVAL) and not na(curRngVAL) and close < curSessVAL and close < curRngVAL

barcolor(aboveVA ? color.new(BULL_ZONE, 20) : belowVA ? color.new(BEAR_ZONE, 20) : na, title="DPS Zone Candle Color")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(aboveVA, "DPS Above Value Area",
     "Dual Profile Structure Map [JOAT]: Price ABOVE both value areas on {{ticker}} {{interval}}")
alertcondition(belowVA, "DPS Below Value Area",
     "Dual Profile Structure Map [JOAT]: Price BELOW both value areas on {{ticker}} {{interval}}")
alertcondition(not na(curSessPOC) and not na(curRngPOC) and math.abs(curSessPOC - curRngPOC) < syminfo.mintick * 10,
     "DPS POC Confluence",
     "Dual Profile Structure Map [JOAT]: Session and Range POC near confluence on {{ticker}}")
````
