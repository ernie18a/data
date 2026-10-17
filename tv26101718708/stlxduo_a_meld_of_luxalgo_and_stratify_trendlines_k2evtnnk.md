# STLXduo, a meld of Luxalgo and Stratify trendlines.

- url: https://www.tradingview.com/script/k2eVtNNK-STLXduo-a-meld-of-Luxalgo-and-Stratify-trendlines/
- type: indicator
- pine_id: PUB;48ebf7ee9f9b4d38b7e72803ed33eb50
- version: 1.0

## Description

max-flex inputs for testing,  soon to include pinescreener version.

## Source Code

````pine
//@version=6
indicator("STLXduo", "STLXduo", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

grpCore = "CORE SETTINGS"
mult       = input.float (1.0,  "Slope Multiplier",  minval = 0,   maxval = 50,  step = 0.1, group = grpCore)
calcMethod = input.string("Atr", "Slope Method",     options = ["Atr","Stdev","Linreg"],     group = grpCore)
backpaint  = input.bool  (true, "Backpaint?",                                                group = grpCore)

grpFast = "ENGINE A — FAST"
showFast = input.bool (true,    "Enable Fast Engine?",                                        group = grpFast)
lenF     = input.int  (5,       "Fast Pivot Lookback",  minval = 1, maxval = 500,             group = grpFast, tooltip = "Bars each side of pivot")
cupF     = input.color(#0044ff, "Fast Bull Color",                                            group = grpFast)
cdnF     = input.color(#ff2b00, "Fast Bear Color",                                            group = grpFast)

grpSlow = "ENGINE B — SLOW"
showSlow = input.bool (true,    "Enable Slow Engine?",                                        group = grpSlow)
lenS     = input.int  (13,      "Slow Pivot Lookback",  minval = 1, maxval = 500,             group = grpSlow, tooltip = "Bars each side of pivot")
cupS     = input.color(#00bcd4, "Slow Bull Color",                                            group = grpSlow)
cdnS     = input.color(#ff9800, "Slow Bear Color",                                            group = grpSlow)

grpStyle = "STYLE"
space    = input.float(2.0,  "Channel Width Multiplier", minval = 0, maxval = 50, step = 0.1, group = grpStyle, tooltip = "Multiplier on slope for channel width")
showExt  = input.bool (true, "Show Extended Lines?",                                          group = grpStyle)
showFill = input.bool (true, "Show Channel Fill?",                                            group = grpStyle)
showSlowProj = input.bool(false, "Show Slow Projection?",                                     group = grpStyle, tooltip = "Dotted ray projecting each Slow main line forward by its own length")
projTrailCount = input.int(5, "Projection Trail Count", minval = 1, maxval = 100,             group = grpStyle, tooltip = "How many expired Slow projection rays to keep on screen")

grpSig = "SIGNALS"
shs        = input.bool  (true,     "Show Breakout Icons?",                                      group = grpSig)
iconAtrLen = input.int   (14,       "Icon ATR Length",        minval = 1,   maxval = 500,        group = grpSig)
iconMult   = input.float (0.5,      "Icon Offset (ATR mult)", minval = 0,   maxval = 20, step = 0.1, group = grpSig)

grpIcon = "ICONS"
iconCupF = input.color(#0044ff, "Fast Bull Icon",        group = grpIcon)
iconCdnF = input.color(#ff2b00, "Fast Bear Icon",        group = grpIcon)
iconCupS = input.color(#00bcd4, "Slow Bull Icon",        group = grpIcon)
iconCdnS = input.color(#ff9800, "Slow Bear Icon",        group = grpIcon)
iconOff  = input.float(0.5, "Icon Offset (×ATR)", minval = 0, step = 0.1, group = grpIcon)

// ═══════════════════════════════════════════════════════════════
// TYPES
// ═══════════════════════════════════════════════════════════════

type store
    float src
    int   n

type draw
    line[] upln
    line[] dnln

// ═══════════════════════════════════════════════════════════════
// VARIABLES
// ═══════════════════════════════════════════════════════════════

var store[] upbinF = array.new<store>()
var store[] dnbinF = array.new<store>()
var draw    dF     = draw.new(array.new<line>(), array.new<line>())

var store[] upbinS = array.new<store>()
var store[] dnbinS = array.new<store>()
var draw    dS     = draw.new(array.new<line>(), array.new<line>())

var bool brokenF = false
var bool brokenS = false

bool plupF = false
bool pldnF = false
bool plupS = false
bool pldnS = false

var line[] projTrailS = array.new<line>()

// ═══════════════════════════════════════════════════════════════
// BODY SOURCE
// ═══════════════════════════════════════════════════════════════

bodyH = math.max(open, close)
bodyL = math.min(open, close)

// ═══════════════════════════════════════════════════════════════
// PIVOTS & SLOPE
// ═══════════════════════════════════════════════════════════════

phF = ta.pivothigh(bodyH, lenF, lenF)
plF = ta.pivotlow (bodyL, lenF, lenF)
phS = ta.pivothigh(bodyH, lenS, lenS)
plS = ta.pivotlow (bodyL, lenS, lenS)

float n = bar_index

f_slope(_len) =>
    float s = switch calcMethod
        "Atr"    => ta.atr(_len) / _len * mult
        "Stdev"  => ta.stdev(close, _len) / _len * mult
        "Linreg" => math.abs(ta.sma(close * n, _len) - ta.sma(close, _len) * ta.sma(n, _len)) / ta.variance(n, _len) / 2.0 * mult
        => ta.atr(_len) / _len * mult
    s

slopeF = f_slope(lenF)
slopeS = f_slope(lenS)

widthF = slopeF * space
widthS = slopeS * space

atrIcon = ta.atr(iconAtrLen)

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════

lineSlope(line ln) =>
    x = ln.get_x2() - ln.get_x1()
    y = ln.get_y2() - ln.get_y1()
    y / x

// Build a dotted projection ray from an expiring line, projected forward by its own span.
// Returns the new line (or na if span invalid). Caller handles trail array + gating.
f_makeProj(line src, color col) =>
    x1 = src.get_x1()
    x2 = src.get_x2()
    y1 = src.get_y1()
    y2 = src.get_y2()
    span = x2 - x1
    line result = na
    if span > 0
        sl = (y2 - y1) / span
        result := line.new(x2, y2, x2 + span, y2 + sl * span, color = col, style = line.style_dotted, width = 3)
    result

// ═══════════════════════════════════════════════════════════════
// ENGINE A — FAST — UPPER TRENDLINE (BEARISH)
// ═══════════════════════════════════════════════════════════════

if showFast and not na(phF)
    bool   removeF = false
    var bool validF = false

    upbinF.unshift(store.new(bodyH[lenF], bar_index[lenF]))
    if upbinF.size() > 1
        current = upbinF.get(0)
        before  = upbinF.get(1)
        if current.src < before.src
            if brokenF
                validF := true
            else
                validF := false
                if upbinF.size() > 3
                    pastold = upbinF.get(3)
                    pastcur = upbinF.get(2)
                    now     = upbinF.get(1)
                    late    = upbinF.get(0)
                    if now.src < pastcur.src and now.src < pastold.src and late.src < pastcur.src and late.src < pastold.src
                        validF := true
                    else
                        validF := false
                else
                    validF := false

            if validF
                float yOffset = widthF

                dF.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src,            y2 = current.src,            color = cdnF))
                dF.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src - yOffset, y2 = current.src - yOffset, color = cdnF))

                ln = dF.upln.get(1)
                for i = 0 to (bar_index - before.n)
                    sl = lineSlope(ln)
                    ln.set_x2(bar_index[i])
                    ln.set_y2(ln.get_y2() - sl)
                    if bodyL[i] > ln.get_y2()
                        removeF := true
                        break

                if removeF
                    dF.upln.get(0).delete()
                    dF.upln.get(1).delete()
                    dF.upln.clear()
                    upbinF.clear()
                    brokenF := true
                else
                    dF.upln.get(0).delete()
                    dF.upln.get(1).delete()
                    dF.upln.clear()

                    dF.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src,            y2 = current.src,            color = cdnF))
                    dF.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src - yOffset, y2 = current.src - yOffset, color = cdnF))

                    if showFill
                        linefill.new(dF.upln.get(0), dF.upln.get(1), color = color.new(cdnF, 75))

                    upbinF.clear()
                    brokenF := false

// Extend Fast upper lines
if dF.upln.size() > 1
    btm = dF.upln.get(0)
    top = dF.upln.get(1)

    if bodyL > top.get_y2()
        dF.upln.clear()
        brokenF := true
        upbinF.clear()
        plupF   := true

    if dF.upln.size() > 1
        slup = lineSlope(top)
        sldn = lineSlope(btm)

        top.set_x2(bar_index)
        top.set_y2(top.get_y2() + slup)

        btm.set_x2(bar_index)
        btm.set_y2(btm.get_y2() + sldn)

// ═══════════════════════════════════════════════════════════════
// ENGINE A — FAST — LOWER TRENDLINE (BULLISH)
// ═══════════════════════════════════════════════════════════════

if showFast and not na(plF)
    bool   removeF = false
    var bool validF = false

    dnbinF.unshift(store.new(bodyL[lenF], bar_index[lenF]))
    if dnbinF.size() > 1
        current = dnbinF.get(0)
        before  = dnbinF.get(1)
        if current.src > before.src
            if brokenF
                validF := true
            else
                validF := false
                if dnbinF.size() > 3
                    pastold = dnbinF.get(3)
                    pastcur = dnbinF.get(2)
                    now     = dnbinF.get(1)
                    late    = dnbinF.get(0)
                    if now.src > pastcur.src and now.src > pastold.src and late.src > pastcur.src and late.src > pastold.src
                        validF := true
                    else
                        validF := false
                else
                    validF := false

            if validF
                float yOffset = widthF

                dF.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src,            y2 = current.src,            color = cupF))
                dF.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src + yOffset, y2 = current.src + yOffset, color = cupF))

                ln = dF.dnln.get(1)
                for i = 0 to (bar_index - before.n)
                    sl = lineSlope(ln)
                    ln.set_x2(bar_index[i])
                    ln.set_y2(ln.get_y2() - sl)
                    if bodyH[i] < ln.get_y2()
                        removeF := true
                        break

                if removeF
                    dF.dnln.get(0).delete()
                    dF.dnln.get(1).delete()
                    dF.dnln.clear()
                    dnbinF.clear()
                    brokenF := true
                else
                    dF.dnln.get(0).delete()
                    dF.dnln.get(1).delete()
                    dF.dnln.clear()

                    dF.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src,            y2 = current.src,            color = cupF))
                    dF.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src + yOffset, y2 = current.src + yOffset, color = cupF))

                    if showFill
                        linefill.new(dF.dnln.get(0), dF.dnln.get(1), color = color.new(cupF, 75))

                    dnbinF.clear()
                    brokenF := false

// Extend Fast lower lines
if dF.dnln.size() > 1
    btm = dF.dnln.get(0)
    top = dF.dnln.get(1)

    if bodyH < btm.get_y2()
        dF.dnln.clear()
        brokenF := true
        dnbinF.clear()
        pldnF   := true

    if dF.dnln.size() > 1
        slup = lineSlope(top)
        sldn = lineSlope(btm)

        top.set_x2(bar_index)
        top.set_y2(top.get_y2() + slup)

        btm.set_x2(bar_index)
        btm.set_y2(btm.get_y2() + sldn)

// ═══════════════════════════════════════════════════════════════
// ENGINE B — SLOW — UPPER TRENDLINE (BEARISH)
// ═══════════════════════════════════════════════════════════════

if showSlow and not na(phS)
    bool   removeS = false
    var bool validS = false

    upbinS.unshift(store.new(bodyH[lenS], bar_index[lenS]))
    if upbinS.size() > 1
        current = upbinS.get(0)
        before  = upbinS.get(1)
        if current.src < before.src
            if brokenS
                validS := true
            else
                validS := false
                if upbinS.size() > 3
                    pastold = upbinS.get(3)
                    pastcur = upbinS.get(2)
                    now     = upbinS.get(1)
                    late    = upbinS.get(0)
                    if now.src < pastcur.src and now.src < pastold.src and late.src < pastcur.src and late.src < pastold.src
                        validS := true
                    else
                        validS := false
                else
                    validS := false

            if validS
                float yOffset = widthS

                dS.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src,            y2 = current.src,            color = cdnS))
                dS.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src - yOffset, y2 = current.src - yOffset, color = cdnS))

                ln = dS.upln.get(1)
                for i = 0 to (bar_index - before.n)
                    sl = lineSlope(ln)
                    ln.set_x2(bar_index[i])
                    ln.set_y2(ln.get_y2() - sl)
                    if bodyL[i] > ln.get_y2()
                        removeS := true
                        break

                if removeS
                    dS.upln.get(0).delete()
                    dS.upln.get(1).delete()
                    dS.upln.clear()
                    upbinS.clear()
                    brokenS := true
                else
                    dS.upln.get(0).delete()
                    dS.upln.get(1).delete()
                    dS.upln.clear()

                    dS.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src,            y2 = current.src,            color = cdnS))
                    dS.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src - yOffset, y2 = current.src - yOffset, color = cdnS))

                    if showFill
                        linefill.new(dS.upln.get(0), dS.upln.get(1), color = color.new(cdnS, 75))

                    upbinS.clear()
                    brokenS := false

// Extend Slow upper lines
if dS.upln.size() > 1
    btm = dS.upln.get(0)
    top = dS.upln.get(1)

    if bodyL > top.get_y2()
        if showSlowProj
            pr = f_makeProj(top, cdnS)
            if not na(pr)
                projTrailS.push(pr)
                while projTrailS.size() > projTrailCount
                    old = projTrailS.shift()
                    old.delete()
        dS.upln.clear()
        brokenS := true
        upbinS.clear()
        plupS   := true

    if dS.upln.size() > 1
        slup = lineSlope(top)
        sldn = lineSlope(btm)

        top.set_x2(bar_index)
        top.set_y2(top.get_y2() + slup)

        btm.set_x2(bar_index)
        btm.set_y2(btm.get_y2() + sldn)

// ═══════════════════════════════════════════════════════════════
// ENGINE B — SLOW — LOWER TRENDLINE (BULLISH)
// ═══════════════════════════════════════════════════════════════

if showSlow and not na(plS)
    bool   removeS = false
    var bool validS = false

    dnbinS.unshift(store.new(bodyL[lenS], bar_index[lenS]))
    if dnbinS.size() > 1
        current = dnbinS.get(0)
        before  = dnbinS.get(1)
        if current.src > before.src
            if brokenS
                validS := true
            else
                validS := false
                if dnbinS.size() > 3
                    pastold = dnbinS.get(3)
                    pastcur = dnbinS.get(2)
                    now     = dnbinS.get(1)
                    late    = dnbinS.get(0)
                    if now.src > pastcur.src and now.src > pastold.src and late.src > pastcur.src and late.src > pastold.src
                        validS := true
                    else
                        validS := false
                else
                    validS := false

            if validS
                float yOffset = widthS

                dS.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src,            y2 = current.src,            color = cupS))
                dS.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src + yOffset, y2 = current.src + yOffset, color = cupS))

                ln = dS.dnln.get(1)
                for i = 0 to (bar_index - before.n)
                    sl = lineSlope(ln)
                    ln.set_x2(bar_index[i])
                    ln.set_y2(ln.get_y2() - sl)
                    if bodyH[i] < ln.get_y2()
                        removeS := true
                        break

                if removeS
                    dS.dnln.get(0).delete()
                    dS.dnln.get(1).delete()
                    dS.dnln.clear()
                    dnbinS.clear()
                    brokenS := true
                else
                    dS.dnln.get(0).delete()
                    dS.dnln.get(1).delete()
                    dS.dnln.clear()

                    dS.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src,            y2 = current.src,            color = cupS))
                    dS.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src + yOffset, y2 = current.src + yOffset, color = cupS))

                    if showFill
                        linefill.new(dS.dnln.get(0), dS.dnln.get(1), color = color.new(cupS, 75))

                    dnbinS.clear()
                    brokenS := false

// Extend Slow lower lines
if dS.dnln.size() > 1
    btm = dS.dnln.get(0)
    top = dS.dnln.get(1)

    if bodyH < btm.get_y2()
        if showSlowProj
            pr = f_makeProj(top, cupS)
            if not na(pr)
                projTrailS.push(pr)
                while projTrailS.size() > projTrailCount
                    old = projTrailS.shift()
                    old.delete()
        dS.dnln.clear()
        brokenS := true
        dnbinS.clear()
        pldnS   := true

    if dS.dnln.size() > 1
        slup = lineSlope(top)
        sldn = lineSlope(btm)

        top.set_x2(bar_index)
        top.set_y2(top.get_y2() + slup)

        btm.set_x2(bar_index)
        btm.set_y2(btm.get_y2() + sldn)

// ═══════════════════════════════════════════════════════════════
// BREAKOUT ICONS
// ═══════════════════════════════════════════════════════════════

if shs and plupF
    label.new(bar_index, low - atrIcon * iconOff, "▲", color = color.new(color.black, 100), textcolor = iconCupF, style = label.style_none, size = size.large)
if shs and pldnF
    label.new(bar_index, high + atrIcon * iconOff, "▼", color = color.new(color.black, 100), textcolor = iconCdnF, style = label.style_none, size = size.large)
if shs and plupS
    label.new(bar_index, low - atrIcon * iconOff, "▲", color = color.new(color.black, 100), textcolor = iconCupS, style = label.style_none, size = size.large)
if shs and pldnS
    label.new(bar_index, high + atrIcon * iconOff, "▼", color = color.new(color.black, 100), textcolor = iconCdnS, style = label.style_none, size = size.large)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════

alertcondition(plupF, "Fast Bullish Break",  "Fast engine: bullish breakout")
alertcondition(pldnF, "Fast Bearish Break",  "Fast engine: bearish breakout")
alertcondition(plupS, "Slow Bullish Break",  "Slow engine: bullish breakout")
alertcondition(pldnS, "Slow Bearish Break",  "Slow engine: bearish breakout")
alertcondition(plupF or pldnF or plupS or pldnS, "Any Break", "Trendline breakout (any engine)")
````
