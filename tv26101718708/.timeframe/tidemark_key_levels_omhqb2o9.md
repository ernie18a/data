# Tidemark Key Levels

- url: https://www.tradingview.com/script/OMhqb2o9-Tidemark-Key-Levels/
- type: indicator
- pine_id: PUB;6e70769f23d54acab27814dee410f233
- version: 3.0

## Description

A clean, all-in-one key levels indicator that maps the price reference points institutional traders use to define liquidity. It plots:

Previous and current Day, Week, and Year highs/lows
RTH session Open and Close
Asia and London session highs/lows
All anchored to a single timezone setting so levels stay accurate across instruments

Each level tracks its own state. Once price trades through it, the line fades to a configurable transparency, switches style (solid → dotted by default), and optionally appends a ✕ to its label — giving you an instant visual map of which liquidity pools have already been swept and which are still in play.
The confluence merge engine bundles levels that sit within an ATR-scaled distance of each other into a single line with a combined label (e.g., PDH/Asia H/Lon H), so stacked levels read as one zone instead of three overlapping plots. Current-day, current-week, and current-year highs/lows update live as the period develops and lock in when it closes.
Built with extended-hours data fetching so Asia and London ranges still plot correctly even when the chart is set to RTH-only.
Use it for: liquidity sweep entries, defining HTF context, marking magnet levels for breakout targets, and seeing at a glance whether the session is hunting old liquidity or building toward fresh.

## Source Code

````pine
// =============================================================================
//  Tidemark — Key Levels & Liquidity Sweep  —  Pine Script v6
//  by WavyTradesNQ
// =============================================================================

//@version=6
indicator("Tidemark — Key Levels", "Tidemark",
     overlay           = true,
     max_lines_count   = 500,
     max_labels_count  = 500)

// ══════════════════════════════ INPUTS ══════════════════════════════
string GEN  = "⚙ General"
string STY  = "🎨 Appearance"
string gPD  = "📅 Previous Day"
string gPW  = "📅 Previous Week"
string gRTH = "🏛 RTH Session"
string gASI = "🌏 Asia Session"
string gLON = "🇬🇧 London Session"
string gPY  = "📆 Previous Year"
string gCY  = "📆 Current Year"

tzInput = input.string("UTC-7", "Timezone",
     options=["UTC-12","UTC-11","UTC-10","UTC-9","UTC-8","UTC-7","UTC-6","UTC-5",
              "UTC-4","UTC-3","UTC-2","UTC-1","UTC","UTC+1","UTC+2","UTC+3",
              "UTC+4","UTC+5","UTC+6","UTC+7","UTC+8","UTC+9","UTC+10","UTC+11","UTC+12"],
     group=GEN, tooltip="All session windows below are read in this zone")
string tz = str.replace(tzInput, "UTC", "GMT")

useETH = input.bool(true, "Fetch extended-hours data for sessions", group=GEN,
     tooltip="If your chart is set to RTH only, enable this so Asia/London session levels still plot correctly.")

activeTransp = input.int(0,  "Active line transparency",  0, 100, group=STY)
sweptTransp  = input.int(75, "Swept line transparency",   0, 100, group=STY,
     tooltip="Higher = more faded once a level gets swept")
lineWidth    = input.int(2,  "Line width", 1, 5, group=STY)
styleIn      = input.string("Solid",  "Active style", options=["Solid","Dashed","Dotted"], group=STY)
sweptStyleIn = input.string("Dotted", "Swept style",  options=["Solid","Dashed","Dotted","Same as active"], group=STY)
lineStyle    = styleIn      == "Solid"  ? line.style_solid  : styleIn      == "Dashed" ? line.style_dashed : line.style_dotted
sweptStyle   = sweptStyleIn == "Solid"  ? line.style_solid  : sweptStyleIn == "Dashed" ? line.style_dashed :
               sweptStyleIn == "Dotted" ? line.style_dotted : lineStyle
showLabels   = input.bool(true, "Show labels", group=STY)
labelSizeIn  = input.string("Medium", "Label size", options=["Tiny","Small","Medium","Large","Huge"], group=STY)
labelSize    = labelSizeIn == "Tiny"   ? size.tiny   :
               labelSizeIn == "Small"  ? size.small  :
               labelSizeIn == "Medium" ? size.normal :
               labelSizeIn == "Large"  ? size.large  : size.huge
labelOffset  = input.int(15, "Label offset (bars)", 0, group=STY)
markSwept    = input.bool(true, "Append ✕ to swept labels", group=STY)

mergeATR     = input.float(0.15, "Confluence merge threshold (× ATR)", 0.0, 5.0, step=0.05, group=STY,
     tooltip="Levels within this distance get merged into one line with a combined label like 'PDH/Asia H'. 0 disables merging.")

showPD   = input.bool(true, "Show Prev Day H/L", group=gPD)
pdhColor = input.color(color.red,   "PDH", inline="pd", group=gPD)
pdlColor = input.color(color.green, "PDL", inline="pd", group=gPD)

showCD   = input.bool(true, "Show Current Day H/L (live)", group=gPD,
     tooltip="Shows the developing day's H/L in real time")
cdhColor = input.color(color.new(color.red, 40),   "CDH", inline="cd", group=gPD)
cdlColor = input.color(color.new(color.green, 40), "CDL", inline="cd", group=gPD)

showPW   = input.bool(true, "Show Prev Week H/L", group=gPW)
pwhColor = input.color(color.maroon, "PWH", inline="pw", group=gPW)
pwlColor = input.color(color.teal,   "PWL", inline="pw", group=gPW)

showCW   = input.bool(true, "Show Current Week H/L (live)", group=gPW)
cwhColor = input.color(color.new(color.maroon, 40), "CWH", inline="cw", group=gPW)
cwlColor = input.color(color.new(color.teal,   40), "CWL", inline="cw", group=gPW)

showRTHOpen  = input.bool(true, "Show RTH Open", group=gRTH,
     tooltip="Plots the opening price of the RTH session — updates live each session, locks in when it closes.")
rthOpenColor = input.color(color.aqua, "RTH Open color", group=gRTH)
showRTH      = input.bool(true, "Show RTH Close", group=gRTH)
rthColor     = input.color(color.yellow, "RTH Close color", group=gRTH)
rthSess      = input.session("0630-1300", "RTH session", group=gRTH,
     tooltip="Default: 09:30–16:00 New York expressed in UTC-7")

showAsia = input.bool(true, "Show Asia H/L", group=gASI)
asiaHCol = input.color(color.orange, "Asia H", inline="as", group=gASI)
asiaLCol = input.color(color.orange, "Asia L", inline="as", group=gASI)
asiaSess = input.session("1700-0100", "Asia session", group=gASI,
     tooltip="Default ≈ Tokyo hours in UTC-7")

showLon  = input.bool(true, "Show London H/L", group=gLON)
lonHCol  = input.color(color.blue, "Lon H", inline="lo", group=gLON)
lonLCol  = input.color(color.blue, "Lon L", inline="lo", group=gLON)
lonSess  = input.session("0000-0800", "London session", group=gLON,
     tooltip="Default ≈ London hours in UTC-7")

showPY   = input.bool(true, "Show Prev Year H/L", group=gPY)
pyhColor = input.color(color.purple, "PYH", inline="py", group=gPY)
pylColor = input.color(color.purple, "PYL", inline="py", group=gPY)

showCY   = input.bool(true, "Show Current Year H/L", group=gCY)
cyhColor = input.color(color.fuchsia, "CYH", inline="cy", group=gCY)
cylColor = input.color(color.fuchsia, "CYL", inline="cy", group=gCY)

// bar duration in ms
barMs      = timeframe.in_seconds(timeframe.period) * 1000
labelOffMs = labelOffset * barMs
atrV       = ta.atr(14)

// ══════════════════════════════ ETH DATA FEED ══════════════════════════════
ethTicker = useETH ? ticker.modify(syminfo.tickerid, session=session.extended) : syminfo.tickerid
[ethHigh, ethLow, ethTime] = request.security(ethTicker, timeframe.period,
     [high, low, time], lookahead=barmerge.lookahead_off)

sHigh = useETH ? ethHigh : high
sLow  = useETH ? ethLow  : low

// Daily levels are pulled from the actual daily candle so CDH/PDH match TradingView's
// daily high/low instead of being rebuilt from the visible intraday chart bars.
[dayHigh, dayLow, dayStart, prevDayHigh, prevDayLow, prevDayStart] = request.security(ethTicker, "D",
     [high, low, time, high[1], low[1], time[1]], lookahead=barmerge.lookahead_off)

// ══════════════════════════════ UDT ══════════════════════════════
type Lvl
    float  price     = na
    line   li        = na
    label  lb        = na
    bool   swept     = false
    int    kind      = 0
    color  base      = color.white
    string txt       = ""
    int    createdAt = na
    bool   live      = false

method refresh(Lvl L) =>
    if not na(L.li)
        t = L.swept ? sweptTransp : activeTransp
        c = color.new(L.base, t)
        L.li.set_color(c)
        L.li.set_style(L.swept ? sweptStyle : lineStyle)
        if not na(L.lb)
            L.lb.set_textcolor(c)
            L.lb.set_text(L.swept and markSwept ? L.txt + " ✕" : L.txt)

method anchor(Lvl L) =>
    if not na(L.lb)
        L.lb.set_x(time + labelOffMs)
    if not na(L.li)
        L.li.set_x2(time + labelOffMs)

method checkSweep(Lvl L) =>
    if not na(L.li) and not L.swept and not L.live and not na(L.createdAt) and bar_index > L.createdAt
        hit = false
        if L.kind == 0 and high > L.price
            hit := true
        else if L.kind == 1 and low < L.price
            hit := true
        else if L.kind == 2 and high >= L.price and low <= L.price
            hit := true
        if hit
            L.swept := true
            L.refresh()

method create(Lvl L, float price, int startTime, color col, string txt, int kind, bool live=false) =>
    if not na(L.li)
        line.delete(L.li)
    if not na(L.lb)
        label.delete(L.lb)
    L.price     := price
    L.base      := col
    L.kind      := kind
    L.swept     := false
    L.txt       := txt
    L.createdAt := bar_index
    L.live      := live
    c = color.new(col, activeTransp)
    L.li := line.new(startTime, price, time + labelOffMs, price,
         xloc.bar_time, extend=extend.right, color=c, style=lineStyle, width=lineWidth)
    if showLabels
        L.lb := label.new(time + labelOffMs, price, txt,
             xloc.bar_time, yloc.price,
             color=color.new(color.black, 100), textcolor=c,
             style=label.style_label_lower_left, size=labelSize)

method move(Lvl L, float newPrice, int newStartTime) =>
    L.price := newPrice
    if not na(L.li)
        L.li.set_xy1(newStartTime, newPrice)
        L.li.set_xy2(time + labelOffMs, newPrice)
    if not na(L.lb)
        L.lb.set_y(newPrice)

method updatePrice(Lvl L, float newPrice) =>
    L.price := newPrice
    if not na(L.li)
        L.li.set_y1(newPrice)
        L.li.set_y2(newPrice)
    if not na(L.lb)
        L.lb.set_y(newPrice)

// ══════════════════════════════ STATE ══════════════════════════════
var Lvl pdhL = Lvl.new()
var Lvl pdlL = Lvl.new()
var Lvl cdhL = Lvl.new()
var Lvl cdlL = Lvl.new()
var Lvl pwhL = Lvl.new()
var Lvl pwlL = Lvl.new()
var Lvl cwhL = Lvl.new()
var Lvl cwlL = Lvl.new()
var Lvl rthOpenL = Lvl.new()
var Lvl rthL = Lvl.new()
var Lvl ahL  = Lvl.new()
var Lvl alL  = Lvl.new()
var Lvl loHL = Lvl.new()
var Lvl loLL = Lvl.new()
var Lvl pyhL = Lvl.new()
var Lvl pylL = Lvl.new()
var Lvl cyhL = Lvl.new()
var Lvl cylL = Lvl.new()

var float dH     = na
var float dL     = na
var int   dStart = na
var float wH     = na
var float wL     = na
var int   wStart = na
var float yrH    = na
var float yrL    = na
var int   yrStart = na
var float asH     = na
var float asL     = na
var int   asStart = na
var float loH     = na
var float loL     = na
var int   loStart = na

newDay  = ta.change(dayStart) != 0
newWeek = ta.change(weekofyear(time, tz))  != 0
newYear = ta.change(year(time, tz))        != 0

// ══════════════════════════════ DAY ══════════════════════════════
// Uses the symbol's real daily candle. This fixes CDH being off when the chart session,
// timezone, or visible bars do not match the true ETH daily candle.
if newDay
    if showPD and not na(prevDayHigh)
        pdhL.create(prevDayHigh, nz(prevDayStart, time), pdhColor, "PDH", 0)
        pdlL.create(prevDayLow,  nz(prevDayStart, time), pdlColor, "PDL", 1)

    dH     := dayHigh
    dL     := dayLow
    dStart := dayStart

    if showCD and not na(dayHigh)
        cdhL.create(dayHigh, dayStart, cdhColor, "CDH", 0, true)
        cdlL.create(dayLow,  dayStart, cdlColor, "CDL", 1, true)
else
    dH     := dayHigh
    dL     := dayLow
    dStart := dayStart

    if showCD and not na(dayHigh)
        if na(cdhL.li)
            cdhL.create(dayHigh, dayStart, cdhColor, "CDH", 0, true)
            cdlL.create(dayLow,  dayStart, cdlColor, "CDL", 1, true)
        else
            if dayHigh != cdhL.price
                cdhL.updatePrice(dayHigh)
            if dayLow != cdlL.price
                cdlL.updatePrice(dayLow)

// ══════════════════════════════ WEEK ══════════════════════════════
if newWeek
    lwH = wH
    lwL = wL
    lwStart = wStart
    if showPW and not na(lwH)
        pwhL.create(lwH, nz(lwStart, time), pwhColor, "PWH", 0)
        pwlL.create(lwL, nz(lwStart, time), pwlColor, "PWL", 1)
    wH     := high
    wL     := low
    wStart := time
    if showCW
        cwhL.create(wH, wStart, cwhColor, "CWH", 0, true)
        cwlL.create(wL, wStart, cwlColor, "CWL", 1, true)
else
    if na(wStart)
        wStart := time
    newWH = na(wH) ? high : math.max(wH, high)
    newWL = na(wL) ? low  : math.min(wL, low)
    if showCW and na(cwhL.li) and not na(wStart)
        cwhL.create(newWH, wStart, cwhColor, "CWH", 0, true)
        cwlL.create(newWL, wStart, cwlColor, "CWL", 1, true)
    if newWH != wH and showCW and not na(cwhL.li)
        cwhL.updatePrice(newWH)
    if newWL != wL and showCW and not na(cwlL.li)
        cwlL.updatePrice(newWL)
    wH := newWH
    wL := newWL

// ══════════════════════════════ YEAR ══════════════════════════════
if newYear
    lyrH = yrH
    lyrL = yrL
    lyrStart = yrStart
    if showPY and not na(lyrH)
        pyhL.create(lyrH, nz(lyrStart, time), pyhColor, "PYH", 0)
        pylL.create(lyrL, nz(lyrStart, time), pylColor, "PYL", 1)
    yrH     := high
    yrL     := low
    yrStart := time
    if showCY
        cyhL.create(yrH, yrStart, cyhColor, "CYH", 0, true)
        cylL.create(yrL, yrStart, cylColor, "CYL", 1, true)
else
    if na(yrStart)
        yrStart := time
    newYH = na(yrH) ? high : math.max(yrH, high)
    newYL = na(yrL) ? low  : math.min(yrL, low)
    if showCY and na(cyhL.li) and not na(yrStart)
        cyhL.create(newYH, yrStart, cyhColor, "CYH", 0, true)
        cylL.create(newYL, yrStart, cylColor, "CYL", 1, true)
    if newYH != yrH and showCY and not na(cyhL.li)
        cyhL.updatePrice(newYH)
    if newYL != yrL and showCY and not na(cylL.li)
        cylL.updatePrice(newYL)
    yrH := newYH
    yrL := newYL

// ══════════════════════════════ ASIA ══════════════════════════════
inAsia  = not na(time(timeframe.period, asiaSess, tz))
asBegin = inAsia and not inAsia[1]
asEnd   = not inAsia and inAsia[1]

if asBegin
    asH     := sHigh
    asL     := sLow
    asStart := time
    if showAsia
        ahL.create(asH, asStart, asiaHCol, "Asia H", 0, true)
        alL.create(asL, asStart, asiaLCol, "Asia L", 1, true)
else if inAsia
    newAsH = math.max(nz(asH, sHigh), sHigh)
    newAsL = math.min(nz(asL, sLow),  sLow)
    if newAsH != asH
        asH := newAsH
        if showAsia and not na(ahL.li)
            ahL.updatePrice(asH)
    if newAsL != asL
        asL := newAsL
        if showAsia and not na(alL.li)
            alL.updatePrice(asL)

if asEnd and not na(asH) and showAsia
    ahL.live := false
    alL.live := false

// ══════════════════════════════ LONDON ══════════════════════════════
inLon   = not na(time(timeframe.period, lonSess, tz))
loBegin = inLon and not inLon[1]
loEnd   = not inLon and inLon[1]

if loBegin
    loH     := sHigh
    loL     := sLow
    loStart := time
    if showLon
        loHL.create(loH, loStart, lonHCol, "Lon H", 0, true)
        loLL.create(loL, loStart, lonLCol, "Lon L", 1, true)
else if inLon
    newLoH = math.max(nz(loH, sHigh), sHigh)
    newLoL = math.min(nz(loL, sLow),  sLow)
    if newLoH != loH
        loH := newLoH
        if showLon and not na(loHL.li)
            loHL.updatePrice(loH)
    if newLoL != loL
        loL := newLoL
        if showLon and not na(loLL.li)
            loLL.updatePrice(loL)

if loEnd and not na(loH) and showLon
    loHL.live := false
    loLL.live := false

// ══════════════════════════════ RTH OPEN + CLOSE ══════════════════════════════
inRTH    = not na(time(timeframe.period, rthSess, tz))
rthBegin = inRTH and not inRTH[1]
rthEnd   = not inRTH and inRTH[1]

if rthBegin and showRTHOpen
    rthOpenL.create(open, time, rthOpenColor, "RTH Open", 2, true)

if rthEnd
    if showRTHOpen and not na(rthOpenL.li)
        rthOpenL.live := false
    if showRTH
        rthL.create(close[1], time[1], rthColor, "RTH Close", 2)

// ══════════════════════════════ SWEEP CHECK ══════════════════════════════
pdhL.checkSweep()
pdlL.checkSweep()
cdhL.checkSweep()
cdlL.checkSweep()
pwhL.checkSweep()
pwlL.checkSweep()
cwhL.checkSweep()
cwlL.checkSweep()
rthOpenL.checkSweep()
rthL.checkSweep()
ahL.checkSweep()
alL.checkSweep()
loHL.checkSweep()
loLL.checkSweep()
pyhL.checkSweep()
pylL.checkSweep()
cyhL.checkSweep()
cylL.checkSweep()

// ══════════════════════════════ ANCHOR ══════════════════════════════
pdhL.anchor()
pdlL.anchor()
cdhL.anchor()
cdlL.anchor()
pwhL.anchor()
pwlL.anchor()
cwhL.anchor()
cwlL.anchor()
rthOpenL.anchor()
rthL.anchor()
ahL.anchor()
alL.anchor()
loHL.anchor()
loLL.anchor()
pyhL.anchor()
pylL.anchor()
cyhL.anchor()
cylL.anchor()

// ══════════════════════════════ CONFLUENCE MERGE ══════════════════════════════
if barstate.islast
    pdhL.refresh()
    pdlL.refresh()
    cdhL.refresh()
    cdlL.refresh()
    pwhL.refresh()
    pwlL.refresh()
    cwhL.refresh()
    cwlL.refresh()
    rthOpenL.refresh()
    rthL.refresh()
    ahL.refresh()
    alL.refresh()
    loHL.refresh()
    loLL.refresh()
    pyhL.refresh()
    pylL.refresh()
    cyhL.refresh()
    cylL.refresh()

    if mergeATR > 0 and not na(atrV)
        threshold = atrV * mergeATR
        arr = array.new<Lvl>()
        if not na(pdhL.lb)
            arr.push(pdhL)
        if not na(pdlL.lb)
            arr.push(pdlL)
        // Keep developing current-day levels exact; merging can make CDH/CDL appear a few ticks off.
        if not na(cdhL.lb) and not cdhL.live
            arr.push(cdhL)
        if not na(cdlL.lb) and not cdlL.live
            arr.push(cdlL)
        if not na(pwhL.lb)
            arr.push(pwhL)
        if not na(pwlL.lb)
            arr.push(pwlL)
        // Keep developing current-week levels exact too.
        if not na(cwhL.lb) and not cwhL.live
            arr.push(cwhL)
        if not na(cwlL.lb) and not cwlL.live
            arr.push(cwlL)
        if not na(rthOpenL.lb)
            arr.push(rthOpenL)
        if not na(rthL.lb)
            arr.push(rthL)
        if not na(ahL.lb)
            arr.push(ahL)
        if not na(alL.lb)
            arr.push(alL)
        if not na(loHL.lb)
            arr.push(loHL)
        if not na(loLL.lb)
            arr.push(loLL)
        if not na(pyhL.lb)
            arr.push(pyhL)
        if not na(pylL.lb)
            arr.push(pylL)
        // Keep developing current-year levels exact too.
        if not na(cyhL.lb) and not cyhL.live
            arr.push(cyhL)
        if not na(cylL.lb) and not cylL.live
            arr.push(cylL)

        n = arr.size()
        if n > 1
            for i = 0 to n - 2
                maxIdx = i
                for j = i + 1 to n - 1
                    if array.get(arr, j).price > array.get(arr, maxIdx).price
                        maxIdx := j
                if maxIdx != i
                    tmp = array.get(arr, i)
                    array.set(arr, i, array.get(arr, maxIdx))
                    array.set(arr, maxIdx, tmp)

            idx = 0
            while idx < n
                groupEnd = idx
                while groupEnd < n - 1 and array.get(arr, idx).price - array.get(arr, groupEnd + 1).price < threshold
                    groupEnd := groupEnd + 1

                if groupEnd > idx
                    primary = array.get(arr, idx)
                    combinedTxt = primary.txt
                    allSwept = primary.swept
                    for k = idx + 1 to groupEnd
                        member = array.get(arr, k)
                        combinedTxt := combinedTxt + "/" + member.txt
                        allSwept := allSwept and member.swept
                        if not na(member.li)
                            member.li.set_color(color.new(color.white, 100))
                        if not na(member.lb)
                            member.lb.set_text("")

                    finalTxt = allSwept and markSwept ? combinedTxt + " ✕" : combinedTxt
                    primary.lb.set_text(finalTxt)

                idx := groupEnd + 1
````
