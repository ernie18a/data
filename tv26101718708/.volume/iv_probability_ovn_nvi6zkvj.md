# IV Probability - OVN

- url: https://www.tradingview.com/script/nvI6ZkvJ-IV-Probability-OVN/
- type: indicator
- pine_id: PUB;a1a9137ffbb449dda7907a8712df8d22
- version: 2.0

## Description

This indicator builds an "implied move" box over each overnight (ETH) session by taking the prior day's volatility-index close, converting it to a single-day expectation, and projecting that 1σ move above and below the session open. It then subdivides each half of the box into range levels, draws standard-deviation expansion bands once price breaks out, and overlays the prior RTH session's closing VWAP with its own σ bands as a reference target. 

As every completed overnight session finishes, it scores whether price reached each level, closed inside or breached the box, and after a breach returned to the box edge, midpoint, or VWAP, accumulating these outcomes over the last N sessions. The statistics table then reports the historical reach and reversion probabilities for each level, giving you an empirical read on how often the market actually fulfills or exceeds the volatility-implied overnight range.

IV is inherently forward looking, so I expect these probabilities to play out accurately over a long period of time.

## Source Code

````pine
//@version=6
indicator("Deprecated!", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100)

// =========================================================================
// SESSION / MARKET
// =========================================================================
groupSession = "▶ SESSION / MARKET (run on an INTRADAY timeframe)"
marketPreset = input.string("ES/NQ (Equity Index)", "Market Preset", options=["ES/NQ (Equity Index)", "CL (Crude Oil)", "Custom"], group=groupSession, tooltip="Defines the OVERNIGHT (ETH) window the box is built over, and the RTH window used for the prior-session VWAP anchor.\n\nES/NQ : ETH 18:00–09:30, RTH 09:30–16:00 (ET)\nCL    : ETH 18:00–09:00, RTH 09:00–14:30 (ET)\nCustom: set both windows manually below.")
customON     = input.session("1800-0930", "Custom Overnight (ETH) Session", group=groupSession)
customRTH    = input.session("0930-1600", "Custom RTH Session", group=groupSession)
sessionTZ    = input.string("America/New_York", "Session Timezone", options=["America/New_York", "America/Chicago", "UTC"], group=groupSession)

string onSession  = marketPreset == "CL (Crude Oil)" ? "1800-0900" : marketPreset == "Custom" ? customON  : "1800-0930"
string rthSession = marketPreset == "CL (Crude Oil)" ? "0900-1430" : marketPreset == "Custom" ? customRTH : "0930-1600"

// =========================================================================
// INPUTS - IMPLIED VOLATILITY BOX & RANGES
// =========================================================================
groupVIX       = "▶ IMPLIED VOLATILITY"
showVIX        = input.bool(true, "Enable Implied Volatility Box", group=groupVIX)
vixIndex       = input.string("VIX", "Volatility Index", options=["VIX", "VIX1D", "VXN", "RVX", "VXD", "VXEW", "GVZ", "OVX", "VXFXI", "VXEEM", "VXTYN"], group=groupVIX, tooltip="The volatility index used to build the overnight implied move.\n\nAll indices are annualized values, so they are converted to a single-day move via ÷√252 — EXCEPT VIX1D, which is already a 1-day expectation and is therefore used DIRECTLY (no ÷√252). Selecting VIX1D automatically applies this direct mode.\n\nVIX   = S&P 500 Volatility Index\nVIX1D = S&P 500 1-Day Volatility Index (used directly)\nVXN   = Nasdaq-100 Volatility Index\nRVX   = Russell 2000 Volatility Index\nVXD   = Dow Jones Industrial Average Volatility Index\nVXEW  = Cboe S&P 500 VIX Without Weeklys\nGVZ   = Cboe Gold ETF Volatility Index\nOVX   = Cboe Crude Oil ETF Volatility Index\nVXFXI = Cboe China ETF Volatility Index\nVXEEM = Cboe Emerging Markets ETF Volatility Index\nVXTYN = 10-Year U.S. Treasury Note Volatility Index")
boxScalePct    = input.float(100, "Box Scale %", minval=1, maxval=100, step=5, group=groupVIX, tooltip="Universal scale applied to the implied move. The FULL implied move = 1σ. Scale shrinks the drawn box AND its σ proportionally.\n\n100% = full implied move, box edge = 1.0σ.\n50%  = half-size box, box edge = 0.5σ.\n25%  = quarter-size box, box edge = 0.25σ.\nEvery σ label is computed from the actual drawn price ÷ the true unscaled 1σ, so it is always mathematically exact.")
vixDivisions   = input.int(4, "Range Divisions (per half)", minval=1, maxval=10, group=groupVIX, tooltip="Each half of the box (0→box edge) is split into this many equal range levels. Every level is labeled with its true σ.")
sdLevels       = input.int(1, "Standard Deviation Bands (in box-edge units)", minval=1, maxval=5, group=groupVIX, tooltip="Once price exits the box, bands at 2× … this many × the box edge are drawn and marked on the breached side, each with its live, running reach probability and its true σ (computed from the actual band price). Set to 1 to disable SD expansion.")
extLevels      = input.int(0, "Extension Levels Beyond Box", minval=0, maxval=20, group=groupVIX, tooltip="Starts at 0. Each increment adds a level beyond the box edge, spaced by 'Extension Level Step %' of the implied move, on BOTH sides.")
extStep        = input.float(10, "Extension Level Step %", minval=1, maxval=200, step=5, group=groupVIX, tooltip="The spacing between extension levels, as a percentage of the implied move (the box half-height / box edge).")
maxSamples     = input.int(9999, "Max VIX Box Samples", minval=1, group=groupVIX, tooltip="All statistics are computed over only the most recent N completed overnight boxes. Default 9999 ≈ full history.")

groupVIXVis    = "▶ IV BOX (VISUALS)"
vixBoxCol      = input.color(color.yellow, "Box Color", group=groupVIXVis)
boxOpacity     = input.int(85, "Box Transparency", 0, 100, group=groupVIXVis)
vixBorderCol   = input.color(color.yellow, "Border Color", group=groupVIXVis)
vixBorderTransp= input.int(50, "Border Transparency", 0, 100, group=groupVIXVis)
upRangeCol     = input.color(color.new(color.yellow, 0), "Upper Range Line Color", group=groupVIXVis)
dnRangeCol     = input.color(color.new(color.yellow, 0), "Lower Range Line Color", group=groupVIXVis)
sdCol          = input.color(color.new(color.red, 0), "Std Dev Band Color", group=groupVIXVis)
extCol         = input.color(color.new(color.red, 0), "Extension Level Color", group=groupVIXVis)
midCol         = input.color(color.new(color.yellow, 0), "Midpoint (50%) Line Color", group=groupVIXVis)
rangeLblTxtCol = input.color(color.white, "Range Label Text Color", group=groupVIXVis)

groupRef       = "▶ RTH VWAP REFERENCE (PRIOR RTH SESSION)"
showRef        = input.bool(true, "Show prior-RTH VWAP & SD Bands on each overnight box", group=groupRef, tooltip="Snapshots the prior RTH session's CLOSING VWAP and ±σ bands and draws them across the overnight box. These σ are the VWAP's OWN standard deviation — a separate statistic from the IV box σ. Breach→return stats use this snapshot. Requires VOLUME data on the chart symbol.")
refBands       = input.int(1, "RTH VWAP SD Bands (each side)", minval=1, maxval=3, group=groupRef)
refLblBands    = input.bool(true, "Label σ Bands (off = label VWAP line only, saves label budget)", group=groupRef)
refVwapCol     = input.color(color.new(color.blue, 0), "RTH VWAP Line Color", group=groupRef)
refBandCol     = input.color(color.new(color.blue, 30), "RTH VWAP SD Band Color", group=groupRef)
refTxtCol      = input.color(color.white, "RTH VWAP Label Text Color", group=groupRef)

groupTable     = "▶ STATISTICS TABLE"
tblHeadBgCol   = input.color(color.new(color.blue, 80), "Header BG Color", group=groupTable)
tblHeadTxtCol  = input.color(color.white, "Header Text Color", group=groupTable)
tblCellBgCol   = input.color(color.new(color.black, 0), "Cell BG Color", group=groupTable)
tblCellTxtCol  = input.color(color.white, "Cell Text Color", group=groupTable)
tblBorderCol   = input.color(color.new(color.gray, 50), "Border Color", group=groupTable)

float extFrac  = extStep / 100.0
float boxScale = boxScalePct / 100.0

// TRUE σ of a price level = |level - open| / (full unscaled 1σ in points).
// This is computed from the ACTUAL drawn price, so it is exact regardless of scale.
f_sigOf(float price, float openPx, float fullSig) =>
    na(fullSig) or fullSig == 0 or na(price) or na(openPx) ? "?σ" : str.tostring(math.abs(price - openPx) / fullSig, "#.###") + "σ"

// Analytic σ for the table (box-multiple × scale) — identical result to the price-based form.
f_sig(float mult, float scl) => str.tostring(mult * scl, "#.###") + "σ"

// =========================================================================
// VOLATILITY INDEX MAPPING
// =========================================================================
f_tickerOf(string idx) =>
    switch idx
        "VIX"   => "CBOE:VIX"
        "VIX1D" => "CBOE:VIX1D"
        "VXN"   => "CBOE:VXN"
        "RVX"   => "CBOE:RVX"
        "VXD"   => "CBOE:VXD"
        "VXEW"  => "CBOE:VXEW"
        "GVZ"   => "CBOE:GVZ"
        "OVX"   => "CBOE:OVX"
        "VXFXI" => "CBOE:VXFXI"
        "VXEEM" => "CBOE:VXEEM"
        "VXTYN" => "CBOE:VXTYN"
        =>         "CBOE:VIX"

f_descOf(string idx) =>
    switch idx
        "VIX"   => "S&P 500 Volatility Index"
        "VIX1D" => "S&P 500 1-Day Volatility Index"
        "VXN"   => "Nasdaq-100 Volatility Index"
        "RVX"   => "Russell 2000 Volatility Index"
        "VXD"   => "Dow Jones Industrial Average Volatility Index"
        "VXEW"  => "Cboe S&P 500 VIX Without Weeklys"
        "GVZ"   => "Cboe Gold ETF Volatility Index"
        "OVX"   => "Cboe Crude Oil ETF Volatility Index"
        "VXFXI" => "Cboe China ETF Volatility Index"
        "VXEEM" => "Cboe Emerging Markets ETF Volatility Index"
        "VXTYN" => "10-Year U.S. Treasury Note Volatility Index"
        =>         ""

// Index selection drives everything. VIX1D is already a 1-day expectation, so it
// is used DIRECTLY (divisor = 1). Every other index is annualized → ÷√252.
bool   useVix1D  = vixIndex == "VIX1D"
string effTicker = f_tickerOf(vixIndex)
string effName   = vixIndex
string effDesc   = f_descOf(vixIndex)
float  divisor   = useVix1D ? 1.0 : math.sqrt(252)
string verLabel  = useVix1D ? "Overnight (direct)" : "Overnight (÷√252)"

// =========================================================================
// DATE LABEL HELPER
// =========================================================================
f_monAbbr(int m) =>
    switch m
        1  => "Jan"
        2  => "Feb"
        3  => "Mar"
        4  => "Apr"
        5  => "May"
        6  => "Jun"
        7  => "Jul"
        8  => "Aug"
        9  => "Sep"
        10 => "Oct"
        11 => "Nov"
        =>    "Dec"

f_sessionDate(int t) => f_monAbbr(month(t)) + " " + str.tostring(dayofmonth(t))

// =========================================================================
// STATS STORAGE
// =========================================================================
var matrix<float> statM = matrix.new<float>(0, 0)

int cUp     = 0
int cDn     = cUp   + vixDivisions
int cSdUp   = cDn   + vixDivisions
int cSdDn   = cSdUp + sdLevels
int cInside = cSdDn + sdLevels
int cBreach = cInside + 1
int cBCI    = cBreach + 1
int cRetMid = cBCI + 1
int cTVwap  = cRetMid + 1
int cRefUp  = cTVwap + 1
int cRefDn  = cRefUp + refBands
int cExtUp  = cRefDn + refBands
int cExtDn  = cExtUp + extLevels
int nCols   = cExtDn + extLevels

var int[] winUpReach = array.new_int(vixDivisions, 0)
var int[] winDnReach = array.new_int(vixDivisions, 0)
var int[] winSdUp    = array.new_int(sdLevels, 0)
var int[] winSdDn    = array.new_int(sdLevels, 0)
var int[] winRefUp   = array.new_int(refBands, 0)
var int[] winRefDn   = array.new_int(refBands, 0)
var int[] winExtUp   = array.new_int(extLevels, 0)
var int[] winExtDn   = array.new_int(extLevels, 0)
var int   winTotal  = 0
var int   winInside = 0
var int   winBreach = 0
var int   winBCI    = 0
var int   winRetMid = 0
var int   winTVwap  = 0

// Live box state
var float currentBoxTop      = na
var float currentBoxBottom   = na
var float currentBoxOpen     = na
var bool  currentBoxBreached = false
var float curPeriodHigh      = na
var float curPeriodLow       = na
var float boxVixRef          = na
var float curImpliedPoints   = na
var float curFullSigma       = na
var int   boxLeftBar         = na

var bool  seenBreachUp = false
var bool  seenBreachDn = false
var bool  retToMid     = false

var float refVwap0        = na
var float refSigma0       = na
var bool  touchedVwapFlag = false
var bool[] touchedUp     = array.new_bool(refBands, false)
var bool[] touchedDn     = array.new_bool(refBands, false)

var bool  boxActive  = false
var bool  sdDrawnUp = false
var bool  sdDrawnDn = false

var box     vixBox      = na
var line    curMidLine  = na
var label   curMidLabel = na
var line[]  curUpLines   = array.new_line()
var line[]  curDnLines   = array.new_line()
var label[] curUpLabels  = array.new_label()
var label[] curDnLabels  = array.new_label()
var float[] curUpLevels  = array.new_float()
var float[] curDnLevels  = array.new_float()
var line[]  curUpSDLines  = array.new_line()
var line[]  curDnSDLines  = array.new_line()
var label[] curUpSDLabels = array.new_label()
var label[] curDnSDLabels = array.new_label()
var line[]  curUpExtLines  = array.new_line()
var line[]  curDnExtLines  = array.new_line()
var label[] curUpExtLabels = array.new_label()
var label[] curDnExtLabels = array.new_label()

var line    curRefVwap = na
var line[]  curRefUp   = array.new_line()
var line[]  curRefDn   = array.new_line()

// VIX daily close: latest CLOSED daily value (no lookahead). By the time the
// overnight session begins in the evening, that day's VIX close is finalized.
float vixDailyClose = request.security(effTicker, "D", close, lookahead = barmerge.lookahead_off)

// =========================================================================
// PRIOR-RTH VWAP SNAPSHOT (anchored to the RTH window)
// =========================================================================
int  rthT       = time(timeframe.period, rthSession, sessionTZ)
bool inRTH      = not na(rthT)
bool rthStart   = inRTH and not inRTH[1]
bool rthEnd     = not inRTH and inRTH[1]
[vwVal, vwUp, vwLo] = ta.vwap(hlc3, rthStart, 1.0)
var float snapVwap  = na
var float snapSigma = na
if rthEnd
    snapVwap  := vwVal[1]
    snapSigma := vwUp[1] - vwVal[1]

// =========================================================================
// MAIN: OVERNIGHT SESSION BOX
// =========================================================================
if showVIX
    int  onT          = time(timeframe.period, onSession, sessionTZ)
    bool inSession     = not na(onT)
    bool sessionStart  = inSession and not inSession[1]
    bool sessionEnd    = not inSession and inSession[1]

    // ---- SCORE the just-finished overnight session ----
    if sessionEnd and boxActive and not na(currentBoxTop) and not na(currentBoxOpen)
        float upImplied = currentBoxTop - currentBoxOpen
        float dnImplied = currentBoxOpen - currentBoxBottom
        float[] row = array.new_float(nCols, 0.0)

        for i = 0 to vixDivisions - 1
            float frac = (i + 1) * 1.0 / vixDivisions
            if curPeriodHigh >= currentBoxOpen + frac * upImplied
                array.set(row, cUp + i, 1.0)
            if curPeriodLow <= currentBoxOpen - frac * dnImplied
                array.set(row, cDn + i, 1.0)

        for j = 1 to sdLevels
            if curPeriodHigh >= currentBoxOpen + j * upImplied
                array.set(row, cSdUp + (j - 1), 1.0)
            if curPeriodLow <= currentBoxOpen - j * dnImplied
                array.set(row, cSdDn + (j - 1), 1.0)

        if extLevels > 0
            for i = 0 to extLevels - 1
                float fracE = 1.0 + (i + 1) * extFrac
                if curPeriodHigh >= currentBoxOpen + fracE * upImplied
                    array.set(row, cExtUp + i, 1.0)
                if curPeriodLow <= currentBoxOpen - fracE * dnImplied
                    array.set(row, cExtDn + i, 1.0)

        bool closedInside = close[1] < currentBoxTop and close[1] > currentBoxBottom
        if closedInside
            array.set(row, cInside, 1.0)
        if currentBoxBreached
            array.set(row, cBreach, 1.0)
            if closedInside
                array.set(row, cBCI, 1.0)
            if retToMid
                array.set(row, cRetMid, 1.0)
            if showRef
                if touchedVwapFlag
                    array.set(row, cTVwap, 1.0)
                for k = 0 to refBands - 1
                    if array.get(touchedUp, k)
                        array.set(row, cRefUp + k, 1.0)
                    if array.get(touchedDn, k)
                        array.set(row, cRefDn + k, 1.0)

        matrix.add_row(statM, matrix.rows(statM), row)
        boxActive := false

    // ---- BUILD a new overnight box ----
    if sessionStart
        currentBoxOpen := open
        boxVixRef      := vixDailyClose
        boxActive      := true
        boxLeftBar     := bar_index
        sdDrawnUp      := false
        sdDrawnDn      := false
        seenBreachUp   := false
        seenBreachDn   := false
        retToMid       := false
        refVwap0        := snapVwap
        refSigma0       := snapSigma
        touchedVwapFlag := false
        for k = 0 to refBands - 1
            array.set(touchedUp, k, false)
            array.set(touchedDn, k, false)

        float periodIV     = vixDailyClose / divisor
        float fullSigPts   = currentBoxOpen * (periodIV / 100)   // FULL unscaled 1σ in points
        float impliedPoints = fullSigPts * boxScale              // scaled box half-height
        curImpliedPoints := impliedPoints
        curFullSigma     := fullSigPts

        currentBoxTop      := currentBoxOpen + impliedPoints
        currentBoxBottom   := currentBoxOpen - impliedPoints
        currentBoxBreached := high > currentBoxTop or low < currentBoxBottom

        curPeriodHigh := high
        curPeriodLow  := low

        vixBox := box.new(left=bar_index, top=currentBoxTop, bottom=currentBoxBottom, right=bar_index + 1, bgcolor=color.new(vixBoxCol, boxOpacity), border_color=color.new(vixBorderCol, vixBorderTransp))

        array.clear(curUpLines)
        array.clear(curDnLines)
        array.clear(curUpLabels)
        array.clear(curDnLabels)
        array.clear(curUpLevels)
        array.clear(curDnLevels)
        array.clear(curUpSDLines)
        array.clear(curDnSDLines)
        array.clear(curUpSDLabels)
        array.clear(curDnSDLabels)
        array.clear(curUpExtLines)
        array.clear(curDnExtLines)
        array.clear(curUpExtLabels)
        array.clear(curDnExtLabels)

        curMidLine  := line.new(bar_index, currentBoxOpen, bar_index + 1, currentBoxOpen, color=midCol, width=2, style=line.style_solid)
        curMidLabel := label.new(bar_index + 1, currentBoxOpen, "MID 50% | Open | 0σ", style=label.style_label_left, color=color.new(midCol, 70), textcolor=rangeLblTxtCol, size=size.small)

        for i = 0 to vixDivisions - 1
            float frac = (i + 1) * 1.0 / vixDivisions
            float upLevel = currentBoxOpen + frac * impliedPoints
            float dnLevel = currentBoxOpen - frac * impliedPoints
            line upL = line.new(bar_index, upLevel, bar_index + 1, upLevel, color=upRangeCol, width=1, style=line.style_solid)
            line dnL = line.new(bar_index, dnLevel, bar_index + 1, dnLevel, color=dnRangeCol, width=1, style=line.style_solid)
            label upLab = label.new(bar_index + 1, upLevel, "", style=label.style_label_left, color=color.new(upRangeCol, 70), textcolor=rangeLblTxtCol, size=size.small)
            label dnLab = label.new(bar_index + 1, dnLevel, "", style=label.style_label_left, color=color.new(dnRangeCol, 70), textcolor=rangeLblTxtCol, size=size.small)
            array.push(curUpLines, upL)
            array.push(curDnLines, dnL)
            array.push(curUpLabels, upLab)
            array.push(curDnLabels, dnLab)
            array.push(curUpLevels, upLevel)
            array.push(curDnLevels, dnLevel)

        if extLevels > 0
            for i = 0 to extLevels - 1
                float fracE = 1.0 + (i + 1) * extFrac
                float upLevel = currentBoxOpen + fracE * impliedPoints
                float dnLevel = currentBoxOpen - fracE * impliedPoints
                line upL = line.new(bar_index, upLevel, bar_index + 1, upLevel, color=extCol, width=1, style=line.style_dotted)
                line dnL = line.new(bar_index, dnLevel, bar_index + 1, dnLevel, color=extCol, width=1, style=line.style_dotted)
                label upLab = label.new(bar_index + 1, upLevel, "", style=label.style_label_left, color=color.new(extCol, 70), textcolor=rangeLblTxtCol, size=size.small)
                label dnLab = label.new(bar_index + 1, dnLevel, "", style=label.style_label_left, color=color.new(extCol, 70), textcolor=rangeLblTxtCol, size=size.small)
                array.push(curUpExtLines, upL)
                array.push(curDnExtLines, dnL)
                array.push(curUpExtLabels, upLab)
                array.push(curDnExtLabels, dnLab)

        // ---- Prior-RTH VWAP reference drawn across this overnight box ----
        if showRef and not na(refVwap0)
            string dstr = f_sessionDate(time)
            curRefVwap := line.new(bar_index, refVwap0, bar_index + 1, refVwap0, color=refVwapCol, width=2, style=line.style_solid)
            label.new(bar_index + 1, refVwap0, "Prior RTH VWAP  " + str.tostring(refVwap0, format.mintick) + "  · " + dstr, style=label.style_label_left, color=color.new(refVwapCol, 70), textcolor=refTxtCol, size=size.small)
            array.clear(curRefUp)
            array.clear(curRefDn)
            if not na(refSigma0) and refSigma0 > 0
                for k = 1 to refBands
                    float up = refVwap0 + k * refSigma0
                    float dn = refVwap0 - k * refSigma0
                    array.push(curRefUp, line.new(bar_index, up, bar_index + 1, up, color=refBandCol, width=1, style=line.style_dotted))
                    array.push(curRefDn, line.new(bar_index, dn, bar_index + 1, dn, color=refBandCol, width=1, style=line.style_dotted))
                    if refLblBands
                        label.new(bar_index + 1, up, "RTH VWAP +" + str.tostring(k) + "σ (VWAP-σ)  " + str.tostring(up, format.mintick), style=label.style_label_left, color=color.new(refBandCol, 70), textcolor=refTxtCol, size=size.small)
                        label.new(bar_index + 1, dn, "RTH VWAP -" + str.tostring(k) + "σ (VWAP-σ)  " + str.tostring(dn, format.mintick), style=label.style_label_left, color=color.new(refBandCol, 70), textcolor=refTxtCol, size=size.small)

    // ---- UPDATE the live overnight box (only during the session) ----
    else if boxActive and inSession and not na(vixBox)
        box.set_right(vixBox, bar_index)
        curPeriodHigh := math.max(curPeriodHigh, high)
        curPeriodLow  := math.min(curPeriodLow, low)
        if high > currentBoxTop or low < currentBoxBottom
            currentBoxBreached := true

        if not na(curMidLine)
            line.set_x2(curMidLine, bar_index)
            label.set_x(curMidLabel, bar_index)
        if array.size(curUpLines) > 0
            for i = 0 to array.size(curUpLines) - 1
                line.set_x2(array.get(curUpLines, i), bar_index)
                line.set_x2(array.get(curDnLines, i), bar_index)
                label.set_x(array.get(curUpLabels, i), bar_index)
                label.set_x(array.get(curDnLabels, i), bar_index)
        if array.size(curUpExtLines) > 0
            for i = 0 to array.size(curUpExtLines) - 1
                line.set_x2(array.get(curUpExtLines, i), bar_index)
                line.set_x2(array.get(curDnExtLines, i), bar_index)
                label.set_x(array.get(curUpExtLabels, i), bar_index)
                label.set_x(array.get(curDnExtLabels, i), bar_index)
        if not na(curRefVwap)
            line.set_x2(curRefVwap, bar_index)
            if array.size(curRefUp) > 0
                for k = 0 to array.size(curRefUp) - 1
                    line.set_x2(array.get(curRefUp, k), bar_index)
                    line.set_x2(array.get(curRefDn, k), bar_index)

    // ---- SEQUENTIAL BREACH / RETURN TRACKING (during session) ----
    if boxActive and inSession and not na(currentBoxTop) and not na(currentBoxOpen)
        bool breachUpNow = high > currentBoxTop
        bool breachDnNow = low  < currentBoxBottom
        if (seenBreachUp or breachUpNow) and low  <= currentBoxOpen
            retToMid := true
        if (seenBreachDn or breachDnNow) and high >= currentBoxOpen
            retToMid := true
        if breachUpNow
            seenBreachUp := true
        if breachDnNow
            seenBreachDn := true

    // ---- RTH VWAP touch tracking (only at/after a breach) ----
    if showRef and boxActive and inSession and (seenBreachUp or seenBreachDn) and not na(refVwap0)
        if low <= refVwap0 and high >= refVwap0
            touchedVwapFlag := true
        if not na(refSigma0) and refSigma0 > 0
            for k = 1 to refBands
                float u = refVwap0 + k * refSigma0
                float d = refVwap0 - k * refSigma0
                if low <= u and high >= u
                    array.set(touchedUp, k - 1, true)
                if low <= d and high >= d
                    array.set(touchedDn, k - 1, true)

    // ---- STANDARD DEVIATION BAND EXPANSION (during session) ----
    if boxActive and inSession and not na(vixBox) and sdLevels >= 2 and not na(curImpliedPoints)
        if high > currentBoxTop and not sdDrawnUp
            for j = 2 to sdLevels
                float lvl = currentBoxOpen + j * curImpliedPoints
                line ln = line.new(boxLeftBar, lvl, bar_index, lvl, color=sdCol, width=1, style=line.style_dashed)
                label lb = label.new(bar_index, lvl, "", style=label.style_label_left, color=color.new(sdCol, 70), textcolor=rangeLblTxtCol, size=size.small)
                array.push(curUpSDLines, ln)
                array.push(curUpSDLabels, lb)
            sdDrawnUp := true
        if low < currentBoxBottom and not sdDrawnDn
            for j = 2 to sdLevels
                float lvl = currentBoxOpen - j * curImpliedPoints
                line ln = line.new(boxLeftBar, lvl, bar_index, lvl, color=sdCol, width=1, style=line.style_dashed)
                label lb = label.new(bar_index, lvl, "", style=label.style_label_left, color=color.new(sdCol, 70), textcolor=rangeLblTxtCol, size=size.small)
                array.push(curDnSDLines, ln)
                array.push(curDnSDLabels, lb)
            sdDrawnDn := true
        if array.size(curUpSDLines) > 0
            for k = 0 to array.size(curUpSDLines) - 1
                line.set_x2(array.get(curUpSDLines, k), bar_index)
                label.set_x(array.get(curUpSDLabels, k), bar_index)
        if array.size(curDnSDLines) > 0
            for k = 0 to array.size(curDnSDLines) - 1
                line.set_x2(array.get(curDnSDLines, k), bar_index)
                label.set_x(array.get(curDnSDLabels, k), bar_index)

// =========================================================================
// WINDOWED (LAST-N) AGGREGATION
// =========================================================================
if barstate.islast
    int totalRows = matrix.rows(statM)
    int nWin = math.min(totalRows, maxSamples)
    winTotal  := nWin
    winInside := 0
    winBreach := 0
    winBCI    := 0
    winRetMid := 0
    winTVwap  := 0
    for i = 0 to vixDivisions - 1
        array.set(winUpReach, i, 0)
        array.set(winDnReach, i, 0)
    for j = 0 to sdLevels - 1
        array.set(winSdUp, j, 0)
        array.set(winSdDn, j, 0)
    for k = 0 to refBands - 1
        array.set(winRefUp, k, 0)
        array.set(winRefDn, k, 0)
    if extLevels > 0
        for i = 0 to extLevels - 1
            array.set(winExtUp, i, 0)
            array.set(winExtDn, i, 0)

    if totalRows > 0 and nWin > 0
        for r = totalRows - nWin to totalRows - 1
            for i = 0 to vixDivisions - 1
                array.set(winUpReach, i, array.get(winUpReach, i) + int(matrix.get(statM, r, cUp + i)))
                array.set(winDnReach, i, array.get(winDnReach, i) + int(matrix.get(statM, r, cDn + i)))
            for j = 0 to sdLevels - 1
                array.set(winSdUp, j, array.get(winSdUp, j) + int(matrix.get(statM, r, cSdUp + j)))
                array.set(winSdDn, j, array.get(winSdDn, j) + int(matrix.get(statM, r, cSdDn + j)))
            if extLevels > 0
                for i = 0 to extLevels - 1
                    array.set(winExtUp, i, array.get(winExtUp, i) + int(matrix.get(statM, r, cExtUp + i)))
                    array.set(winExtDn, i, array.get(winExtDn, i) + int(matrix.get(statM, r, cExtDn + i)))
            winInside += int(matrix.get(statM, r, cInside))
            winBreach += int(matrix.get(statM, r, cBreach))
            winBCI    += int(matrix.get(statM, r, cBCI))
            winRetMid += int(matrix.get(statM, r, cRetMid))
            winTVwap  += int(matrix.get(statM, r, cTVwap))
            for k = 0 to refBands - 1
                array.set(winRefUp, k, array.get(winRefUp, k) + int(matrix.get(statM, r, cRefUp + k)))
                array.set(winRefDn, k, array.get(winRefDn, k) + int(matrix.get(statM, r, cRefDn + k)))

// =========================================================================
// LIVE LABEL TEXT  (σ computed from ACTUAL drawn price ÷ full unscaled 1σ)
// =========================================================================
if showVIX and barstate.islast and array.size(curUpLevels) > 0
    for i = 0 to vixDivisions - 1
        float frac   = (i + 1) * 1.0 / vixDivisions
        float upPx   = array.get(curUpLevels, i)
        float dnPx   = array.get(curDnLevels, i)
        float baseUp = winTotal > 0 ? array.get(winUpReach, i) / winTotal * 100 : na
        float baseDn = winTotal > 0 ? array.get(winDnReach, i) / winTotal * 100 : na
        string upTxt = "+" + str.tostring(frac * 100, "#") + "% (" + f_sigOf(upPx, currentBoxOpen, curFullSigma) + ") | " + (na(baseUp) ? "N/A" : str.tostring(baseUp, "#.#") + "%")
        string dnTxt = "-" + str.tostring(frac * 100, "#") + "% (" + f_sigOf(dnPx, currentBoxOpen, curFullSigma) + ") | " + (na(baseDn) ? "N/A" : str.tostring(baseDn, "#.#") + "%")
        label.set_text(array.get(curUpLabels, i), upTxt)
        label.set_text(array.get(curDnLabels, i), dnTxt)

if showVIX and barstate.islast and array.size(curUpExtLines) > 0
    for i = 0 to array.size(curUpExtLines) - 1
        float fracE = 1.0 + (i + 1) * extFrac
        float upPx  = currentBoxOpen + fracE * curImpliedPoints
        float dnPx  = currentBoxOpen - fracE * curImpliedPoints
        float pu = winTotal > 0 ? array.get(winExtUp, i) / winTotal * 100 : na
        float pd = winTotal > 0 ? array.get(winExtDn, i) / winTotal * 100 : na
        label.set_text(array.get(curUpExtLabels, i), "+" + str.tostring(fracE * 100, "#") + "% (" + f_sigOf(upPx, currentBoxOpen, curFullSigma) + ") | " + (na(pu) ? "N/A" : str.tostring(pu, "#.#") + "%"))
        label.set_text(array.get(curDnExtLabels, i), "-" + str.tostring(fracE * 100, "#") + "% (" + f_sigOf(dnPx, currentBoxOpen, curFullSigma) + ") | " + (na(pd) ? "N/A" : str.tostring(pd, "#.#") + "%"))

if showVIX and barstate.islast and sdLevels >= 2
    if array.size(curUpSDLines) > 0
        for k = 0 to array.size(curUpSDLines) - 1
            int j = k + 2
            float px = currentBoxOpen + j * curImpliedPoints
            float p = winTotal > 0 ? array.get(winSdUp, j - 1) / winTotal * 100 : na
            label.set_text(array.get(curUpSDLabels, k), "+" + f_sigOf(px, currentBoxOpen, curFullSigma) + " | " + (na(p) ? "N/A" : str.tostring(p, "#.#") + "%"))
    if array.size(curDnSDLines) > 0
        for k = 0 to array.size(curDnSDLines) - 1
            int j = k + 2
            float px = currentBoxOpen - j * curImpliedPoints
            float p = winTotal > 0 ? array.get(winSdDn, j - 1) / winTotal * 100 : na
            label.set_text(array.get(curDnSDLabels, k), "-" + f_sigOf(px, currentBoxOpen, curFullSigma) + " | " + (na(p) ? "N/A" : str.tostring(p, "#.#") + "%"))

// =========================================================================
// STATS TABLE
// =========================================================================
var table statsTable = table.new(position.bottom_right, 2, 120, border_width=1, border_color=tblBorderCol)

if barstate.islast
    string vixBoxStatus = "N/A"
    color  vixStatusCol = tblCellTxtCol
    if showVIX and not na(currentBoxTop) and not na(curFullSigma) and curFullSigma != 0
        if close > currentBoxTop
            vixBoxStatus := "Outside ↑ " + f_sigOf(close, currentBoxOpen, curFullSigma)
            vixStatusCol := color.yellow
        else if close < currentBoxBottom
            vixBoxStatus := "Outside ↓ " + f_sigOf(close, currentBoxOpen, curFullSigma)
            vixStatusCol := color.red
        else
            vixBoxStatus := "Inside (" + f_sigOf(close, currentBoxOpen, curFullSigma) + ")"
            vixStatusCol := color.yellow

    float refVix = na(boxVixRef) ? vixDailyClose : boxVixRef
    float impliedPct = refVix / divisor * boxScale
    string scaleTag = boxScale != 1.0 ? " ×" + str.tostring(boxScalePct, "#") + "%" : ""
    string vixValStr = str.tostring(refVix, "#.##") + " (" + str.tostring(impliedPct, "#.##") + "%" + scaleTag + ", edge=" + f_sig(1.0, boxScale) + ")"

    int r = 0
    table.cell(statsTable, 0, r, "System Metric", bgcolor=tblHeadBgCol, text_color=tblHeadTxtCol)
    table.cell(statsTable, 1, r, "Value", bgcolor=tblHeadBgCol, text_color=tblHeadTxtCol)
    r += 1
    table.cell(statsTable, 0, r, effName + " " + verLabel + " IV", bgcolor=tblHeadBgCol, text_color=tblHeadTxtCol)
    table.cell(statsTable, 1, r, showVIX ? vixValStr : "Disabled", bgcolor=tblHeadBgCol, text_color=tblHeadTxtCol)
    r += 1
    table.cell(statsTable, 0, r, "Overnight Session", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
    table.cell(statsTable, 1, r, onSession + " " + sessionTZ, bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
    r += 1
    table.cell(statsTable, 0, r, "Source", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
    table.cell(statsTable, 1, r, showVIX ? effDesc + "  (" + effTicker + ")" : "Disabled", bgcolor=tblCellBgCol, text_color=showVIX ? color.white : color.gray)
    r += 1
    table.cell(statsTable, 0, r, effName + " Overnight Samples", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
    table.cell(statsTable, 1, r, showVIX ? str.tostring(winTotal) + (winTotal >= maxSamples ? " (cap " + str.tostring(maxSamples) + ")" : "") : "Disabled", bgcolor=tblCellBgCol, text_color=showVIX ? color.white : color.gray)
    r += 1
    table.cell(statsTable, 0, r, "Live " + effName + " Box Status", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
    table.cell(statsTable, 1, r, showVIX ? vixBoxStatus : "Disabled", bgcolor=tblCellBgCol, text_color=showVIX ? vixStatusCol : color.gray)
    r += 1

    if showVIX and winTotal > 0
        if sdLevels >= 2
            for j = sdLevels to 2
                float b = array.get(winSdUp, j - 1) / winTotal * 100
                table.cell(statsTable, 0, r, "Reach +" + f_sig(j, boxScale), bgcolor=tblCellBgCol, text_color=sdCol)
                table.cell(statsTable, 1, r, str.tostring(b, "#.#") + "%  (" + str.tostring(array.get(winSdUp, j - 1)) + "/" + str.tostring(winTotal) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
                r += 1

        if extLevels > 0
            for i = extLevels - 1 to 0
                float fracE = 1.0 + (i + 1) * extFrac
                float b = array.get(winExtUp, i) / winTotal * 100
                table.cell(statsTable, 0, r, "Reach +" + str.tostring(fracE * 100, "#") + "% (" + f_sig(fracE, boxScale) + ")", bgcolor=tblCellBgCol, text_color=extCol)
                table.cell(statsTable, 1, r, str.tostring(b, "#.#") + "%  (" + str.tostring(array.get(winExtUp, i)) + "/" + str.tostring(winTotal) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
                r += 1

        for i = vixDivisions - 1 to 0
            float frac = (i + 1) * 1.0 / vixDivisions
            float b = array.get(winUpReach, i) / winTotal * 100
            table.cell(statsTable, 0, r, "Reach +" + str.tostring(frac * 100, "#") + "% (" + f_sig(frac, boxScale) + ")", bgcolor=tblCellBgCol, text_color=upRangeCol)
            table.cell(statsTable, 1, r, str.tostring(b, "#.#") + "%  (" + str.tostring(array.get(winUpReach, i)) + "/" + str.tostring(winTotal) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
            r += 1

        table.cell(statsTable, 0, r, "Midpoint (50% / Open / 0σ)", bgcolor=tblCellBgCol, text_color=midCol)
        table.cell(statsTable, 1, r, "Reference", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
        r += 1

        for i = 0 to vixDivisions - 1
            float frac = (i + 1) * 1.0 / vixDivisions
            float b = array.get(winDnReach, i) / winTotal * 100
            table.cell(statsTable, 0, r, "Reach -" + str.tostring(frac * 100, "#") + "% (" + f_sig(frac, boxScale) + ")", bgcolor=tblCellBgCol, text_color=dnRangeCol)
            table.cell(statsTable, 1, r, str.tostring(b, "#.#") + "%  (" + str.tostring(array.get(winDnReach, i)) + "/" + str.tostring(winTotal) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
            r += 1

        if extLevels > 0
            for i = 0 to extLevels - 1
                float fracE = 1.0 + (i + 1) * extFrac
                float b = array.get(winExtDn, i) / winTotal * 100
                table.cell(statsTable, 0, r, "Reach -" + str.tostring(fracE * 100, "#") + "% (" + f_sig(fracE, boxScale) + ")", bgcolor=tblCellBgCol, text_color=extCol)
                table.cell(statsTable, 1, r, str.tostring(b, "#.#") + "%  (" + str.tostring(array.get(winExtDn, i)) + "/" + str.tostring(winTotal) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
                r += 1

        if sdLevels >= 2
            for j = 2 to sdLevels
                float b = array.get(winSdDn, j - 1) / winTotal * 100
                table.cell(statsTable, 0, r, "Reach -" + f_sig(j, boxScale), bgcolor=tblCellBgCol, text_color=sdCol)
                table.cell(statsTable, 1, r, str.tostring(b, "#.#") + "%  (" + str.tostring(array.get(winSdDn, j - 1)) + "/" + str.tostring(winTotal) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
                r += 1

        float probInside = winInside / winTotal * 100
        float probBreach = winBreach / winTotal * 100
        table.cell(statsTable, 0, r, "Prob. Close Inside (edge " + f_sig(1.0, boxScale) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
        table.cell(statsTable, 1, r, str.tostring(probInside, "#.#") + "%  (" + str.tostring(winInside) + "/" + str.tostring(winTotal) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
        r += 1
        table.cell(statsTable, 0, r, "Prob. Breached edge " + f_sig(1.0, boxScale) + " (Wick)", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
        table.cell(statsTable, 1, r, str.tostring(probBreach, "#.#") + "%  (" + str.tostring(winBreach) + "/" + str.tostring(winTotal) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
        r += 1

        if winBreach > 0
            float pRetInside = winBCI / winBreach * 100
            float pRetMid    = winRetMid / winBreach * 100
            table.cell(statsTable, 0, r, "Breach → Return Inside edge " + f_sig(1.0, boxScale), bgcolor=tblCellBgCol, text_color=color.yellow)
            table.cell(statsTable, 1, r, str.tostring(pRetInside, "#.#") + "%  (" + str.tostring(winBCI) + "/" + str.tostring(winBreach) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
            r += 1
            table.cell(statsTable, 0, r, "Breach → Return to Midpoint", bgcolor=tblCellBgCol, text_color=color.yellow)
            table.cell(statsTable, 1, r, str.tostring(pRetMid, "#.#") + "%  (" + str.tostring(winRetMid) + "/" + str.tostring(winBreach) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
            r += 1

            if showRef
                float pRetVwap = winTVwap / winBreach * 100
                table.cell(statsTable, 0, r, "Breach → Return Prior-RTH VWAP", bgcolor=tblCellBgCol, text_color=refVwapCol)
                table.cell(statsTable, 1, r, str.tostring(pRetVwap, "#.#") + "%  (" + str.tostring(winTVwap) + "/" + str.tostring(winBreach) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
                r += 1
                for k = 1 to refBands
                    float pu = array.get(winRefUp, k - 1) / winBreach * 100
                    table.cell(statsTable, 0, r, "   → RTH VWAP +" + str.tostring(k) + "σ (VWAP-σ)", bgcolor=tblCellBgCol, text_color=refBandCol)
                    table.cell(statsTable, 1, r, str.tostring(pu, "#.#") + "%  (" + str.tostring(array.get(winRefUp, k - 1)) + "/" + str.tostring(winBreach) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
                    r += 1
                    float pd = array.get(winRefDn, k - 1) / winBreach * 100
                    table.cell(statsTable, 0, r, "   → RTH VWAP -" + str.tostring(k) + "σ (VWAP-σ)", bgcolor=tblCellBgCol, text_color=refBandCol)
                    table.cell(statsTable, 1, r, str.tostring(pd, "#.#") + "%  (" + str.tostring(array.get(winRefDn, k - 1)) + "/" + str.tostring(winBreach) + ")", bgcolor=tblCellBgCol, text_color=tblCellTxtCol)
                    r += 1
````
