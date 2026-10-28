# EdgeHunter Levels & Sweeps

- url: https://www.tradingview.com/script/UBVTZY6p-EdgeHunter-Levels-Sweeps/
- type: indicator
- pine_id: PUB;876a5b5c145245489af10e71eb82482b
- version: 1.0

## Description

EdgeHunter Levels + Sweeps is a multi-timeframe reference level tracker that draws the key highs and lows traders use for context, monitors each level for sweeps in real time using 1-minute resolution, tracks whether a higher timeframe close has reclaimed back inside a swept level, and fires alerts at each stage. All levels, sweep states, and reclaim status are summarised in a live on-chart table.

Levels Tracked

The indicator draws and monitors the following levels simultaneously:

Previous Day High and Low — sourced from the daily timeframe, updated each new session
Previous 1-Hour High and Low — sourced from the 60-minute timeframe, updated each new hour
Previous 4-Hour High and Low — sourced from the 4-hour timeframe, updated each new 4-hour close
Asia Session High and Low — built from a configurable Asia session window (default 20:00–00:00 NY time)
London Session High and Low — built from a configurable London session window (default 02:00–05:00 NY time)
Midnight Open — the opening price of the 00:00 candle in the configured timezone, tracked as a reference level for the trading day
Previous Day Volume Profile Levels — manually entered VAH, VAL, and POC from an external volume profile tool
Each level is drawn from its originating bar and extends forward until swept, at which point the line stops extending and its style switches to dotted to visually indicate it has been taken.

Sweep Detection

All sweep detection runs internally against 1-minute data, regardless of the timeframe the chart is set to. A level is marked swept the moment any 1-minute bar's high crosses above a high level or low crosses below a low level. This ensures sweeps are caught without waiting for a higher timeframe candle to close.

Reclaim Tracking

After a level is swept, the indicator continues monitoring whether price has closed back inside — on a user-selected higher timeframe (configurable, e.g., 1-hour). Each level carries one of three states at any time: Unswept, Outside (swept and the HTF close confirmed outside), or Inside (swept and the HTF close confirmed back inside the level). This reclaim state is what many traders consider confirmation that the sweep was a liquidity grab rather than a genuine directional break.

Status Table

A live table displays every tracked level with its name, current sweep status (SWEPT / UNSWEPT), and current close status relative to the chosen HTF. The table background colour changes to indicate swept levels at a glance. The table position, text size, and colour scheme are fully configurable.

Label Anti-Stacking

When multiple levels are close together in price, labels are automatically staggered vertically to prevent overlap. A configurable minimum separation and step size control how aggressively labels are pushed apart. This keeps the chart readable even when session highs and lows cluster in a narrow range.

Alerts

Three categories of alerts are available:

Level Swept (1m) — fires when any tracked level is crossed using 1-minute precision, naming the level and price
HTF Closed Inside — fires when a previously swept level is reclaimed on the chosen HTF close, indicating a potential false break
VP Level Touch — fires when price touches the manually entered VAH, VAL, or POC, on a per-level or combined basis
All alerts use once per bar close to prevent repeated firing and include the level name and price in the message.

## Source Code

````pine

//@version=6
indicator("EdgeHunter Levels & Sweeps", shorttitle="LvlsSwps", overlay=true, max_lines_count=500, max_labels_count=500)

//─────────────────────────────────────────────────────────────────────────────
// Helpers
//─────────────────────────────────────────────────────────────────────────────
f_lineStyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

f_textSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large

f_pos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left

f_upsertLine(line lnIn, int startTime, int endTime, float y, color col, int width, string styleStr) =>
    line ln = lnIn
    if na(ln)
        ln := line.new(x1=startTime, y1=y, x2=endTime, y2=y, xloc=xloc.bar_time, extend=extend.none, color=col, width=width, style=f_lineStyle(styleStr))
    else
        line.set_x1(ln, startTime)
        line.set_y1(ln, y)
        line.set_x2(ln, endTime)
        line.set_y2(ln, y)
        line.set_color(ln, col)
        line.set_width(ln, width)
        line.set_style(ln, f_lineStyle(styleStr))
    ln

f_upsertText(label lbIn, int xTime, float y, string txt, color txtCol, string sizeStr) =>
    label lb = lbIn
    if na(lb)
        lb := label.new(x=xTime, y=y, xloc=xloc.bar_time, yloc=yloc.price, text=txt, style=label.style_none, textcolor=txtCol, size=f_textSize(sizeStr))
    else
        label.set_x(lb, xTime)
        label.set_y(lb, y)
        label.set_text(lb, txt)
        label.set_textcolor(lb, txtCol)
        label.set_size(lb, f_textSize(sizeStr))
    lb

// Collision check helper
f_clash(float y, float a, float b, float c, float d, float e, float f, float g, float minSep) =>
    bool clash = false
    clash := clash or (not na(a) and math.abs(y - a) < minSep)
    clash := clash or (not na(b) and math.abs(y - b) < minSep)
    clash := clash or (not na(c) and math.abs(y - c) < minSep)
    clash := clash or (not na(d) and math.abs(y - d) < minSep)
    clash := clash or (not na(e) and math.abs(y - e) < minSep)
    clash := clash or (not na(f) and math.abs(y - f) < minSep)
    clash := clash or (not na(g) and math.abs(y - g) < minSep)
    clash

// Non-loop stacking resolver
f_stackY(float baseY, float yA, float yB, float yC, float yD, float yE, float yF, float yG, float minSep, float step) =>
    float out = baseY
    if f_clash(out, yA,yB,yC,yD,yE,yF,yG, minSep)
        out += step
    if f_clash(out, yA,yB,yC,yD,yE,yF,yG, minSep)
        out += step
    if f_clash(out, yA,yB,yC,yD,yE,yF,yG, minSep)
        out += step
    if f_clash(out, yA,yB,yC,yD,yE,yF,yG, minSep)
        out += step
    if f_clash(out, yA,yB,yC,yD,yE,yF,yG, minSep)
        out += step
    if f_clash(out, yA,yB,yC,yD,yE,yF,yG, minSep)
        out += step
    out

// Bar duration for extending lines on the *chart timeframe*
barSec = math.max(1, timeframe.in_seconds(timeframe.period))
barMs  = barSec * 1000

//─────────────────────────────────────────────────────────────────────────────
// Inputs
//─────────────────────────────────────────────────────────────────────────────
grpGeneral = "General"
extendBars = input.int(20, "Extend level lines (bars)", minval=1, maxval=200, group=grpGeneral)
closeTF    = input.timeframe("60", "Close status timeframe (HTF)", group=grpGeneral)

grpLbl = "Label Layout"
labelXBars  = input.int(0, "Label X shift (bars to the right)", minval=0, maxval=50, group=grpLbl)
minSepTicks = input.int(8, "Min vertical separation (ticks)", minval=1, maxval=100, group=grpLbl)
stepTicks   = input.int(10, "Stagger step (ticks)", minval=1, maxval=200, group=grpLbl)

grpSess = "Session Times"
sessTZ  = input.string("America/New_York", "Session timezone", group=grpSess)
asiaSes = input.session("2000-0000", "Asia session (20:00–00:00)", group=grpSess)
ldnSes  = input.session("0200-0500", "London session (02:00–05:00)", group=grpSess)

grpAlerts = "Alerts"
enableAlerts = input.bool(true, "Enable alerts", group=grpAlerts)

grpTable = "Status Table"
showTable      = input.bool(true, "Show table", group=grpTable)
tablePos       = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpTable)
tableTextSz    = input.string("Small", "Text size", options=["Tiny","Small","Normal","Large"], group=grpTable)
tableHdrBg     = input.color(color.new(color.black, 0), "Header bg", group=grpTable)
tableHdrTx     = input.color(color.white, "Header text", group=grpTable)
tableRowTx     = input.color(color.white, "Row text", group=grpTable)
tableTakenBg   = input.color(color.new(color.red, 0), "Swept bg", group=grpTable)
tableUntakenBg = input.color(color.new(color.lime, 0), "Unswept bg", group=grpTable)
tableBorderCol = input.color(color.new(color.white, 60), "Border colour", group=grpTable)
tableBorderW   = input.int(1, "Border width", minval=0, maxval=4, group=grpTable)

// Level styles
grpPD = "Prev Day (PDH/PDL)"
showPD   = input.bool(true, "Show", group=grpPD)
pdCol    = input.color(color.white, "Line colour", group=grpPD)
pdW      = input.int(1, "Line width", minval=1, maxval=5, group=grpPD)
pdSty    = input.string("Dashed", "Line style", options=["Solid","Dashed","Dotted"], group=grpPD)
pdhTxt   = input.string("Previous Day High", "High label text", group=grpPD)
pdlTxt   = input.string("Previous Day Low",  "Low label text", group=grpPD)
pdTxtCol = input.color(color.white, "Label text colour", group=grpPD)
pdTxtSz  = input.string("Small", "Label text size", options=["Tiny","Small","Normal","Large"], group=grpPD)

grp1H = "Prev 1H (H/L)"
showP1H   = input.bool(true, "Show", group=grp1H)
p1hCol    = input.color(color.rgb(120, 210, 255), "Line colour", group=grp1H)
p1hW      = input.int(1, "Line width", minval=1, maxval=5, group=grp1H)
p1hSty    = input.string("Solid", "Line style", options=["Solid","Dashed","Dotted"], group=grp1H)
p1hHTxt   = input.string("Prev 1H High", "High label text", group=grp1H)
p1hLTxt   = input.string("Prev 1H Low",  "Low label text", group=grp1H)
p1hTxtCol = input.color(color.white, "Label text colour", group=grp1H)
p1hTxtSz  = input.string("Small", "Label text size", options=["Tiny","Small","Normal","Large"], group=grp1H)

grp4H = "Prev 4H (H/L)"
showP4H   = input.bool(true, "Show", group=grp4H)
p4hCol    = input.color(color.rgb(200,160,255), "Line colour", group=grp4H)
p4hW      = input.int(1, "Line width", minval=1, maxval=5, group=grp4H)
p4hSty    = input.string("Solid", "Line style", options=["Solid","Dashed","Dotted"], group=grp4H)
p4hHTxt   = input.string("Prev 4H High", "High label text", group=grp4H)
p4hLTxt   = input.string("Prev 4H Low",  "Low label text", group=grp4H)
p4hTxtCol = input.color(color.white, "Label text colour", group=grp4H)
p4hTxtSz  = input.string("Small", "Label text size", options=["Tiny","Small","Normal","Large"], group=grp4H)

grpAsia = "Asia (H/L)"
showAsia   = input.bool(true, "Show", group=grpAsia)
asiaCol    = input.color(color.new(color.blue, 0), "Line colour", group=grpAsia)
asiaW      = input.int(1, "Line width", minval=1, maxval=5, group=grpAsia)
asiaSty    = input.string("Solid", "Line style", options=["Solid","Dashed","Dotted"], group=grpAsia)
asiaHTxt   = input.string("Asia High", "High label text", group=grpAsia)
asiaLTxt   = input.string("Asia Low",  "Low label text", group=grpAsia)
asiaTxtCol = input.color(color.white, "Label text colour", group=grpAsia)
asiaTxtSz  = input.string("Small", "Label text size", options=["Tiny","Small","Normal","Large"], group=grpAsia)

grpLdn = "London (H/L)"
showLondon = input.bool(true, "Show", group=grpLdn)
ldnCol     = input.color(color.new(color.red, 0), "Line colour", group=grpLdn)
ldnW       = input.int(1, "Line width", minval=1, maxval=5, group=grpLdn)
ldnSty     = input.string("Solid", "Line style", options=["Solid","Dashed","Dotted"], group=grpLdn)
ldnHTxt    = input.string("London High", "High label text", group=grpLdn)
ldnLTxt    = input.string("London Low",  "Low label text", group=grpLdn)
ldnTxtCol  = input.color(color.white, "Label text colour", group=grpLdn)
ldnTxtSz   = input.string("Small", "Label text size", options=["Tiny","Small","Normal","Large"], group=grpLdn)

// Midnight Open (00:00 in sessTZ)
grpMid = "Midnight Open"
showMidnight = input.bool(true, "Show midnight open", group=grpMid)
midCol       = input.color(color.new(color.yellow, 0), "Line colour", group=grpMid)
midW         = input.int(1, "Line width", minval=1, maxval=5, group=grpMid)
midSty       = input.string("Dotted", "Line style", options=["Solid","Dashed","Dotted"], group=grpMid)
midTxt       = input.string("Midnight Open", "Label text", group=grpMid)
midTxtCol    = input.color(color.white, "Label text colour", group=grpMid)
midTxtSz     = input.string("Small", "Label text size", options=["Tiny","Small","Normal","Large"], group=grpMid)

// Prev Day Volume Profile Levels (manual inputs; 0.0 means "off")
grpVP = "Prev Day VP (VAH/VAL/POC)"
showVP    = input.bool(true, "Show", group=grpVP)
vpVah     = input.float(0.0, "Prev Day VAH", group=grpVP)
vpVal     = input.float(0.0, "Prev Day VAL", group=grpVP)
vpPoc     = input.float(0.0, "Prev Day POC", group=grpVP)

// Screenshot-like defaults + editable
vpColHV   = input.color(color.rgb(55, 140, 255), "VAH/VAL colour", group=grpVP)     // blue
vpColPOC  = input.color(color.rgb(190, 120, 210), "POC colour", group=grpVP)        // purple
vpW       = input.int(1, "Line width", minval=1, maxval=5, group=grpVP)
vpStyHV   = input.string("Dashed", "VAH/VAL line style", options=["Solid","Dashed","Dotted"], group=grpVP)
vpStyPOC  = input.string("Dashed", "POC line style", options=["Solid","Dashed","Dotted"], group=grpVP)

// These are still used for ALERT TEXT (plot titles must be constant strings)
vpVahTxt  = input.string("Yesterdays VAH", "VAH alert text", group=grpVP)
vpValTxt  = input.string("Yesterdays VAL", "VAL alert text", group=grpVP)
vpPocTxt  = input.string("Yesterdays POC", "POC alert text", group=grpVP)

// Default end time on chart TF
endTimeDefault = time + (extendBars * barMs)
labelXTime(endT) => endT + (labelXBars * barMs)

//─────────────────────────────────────────────────────────────────────────────
// 1m session builder + midnight tracking
//─────────────────────────────────────────────────────────────────────────────
f_trackPrevSession_1m(string sess, string tz) =>
    bool inSess = not na(time("1", sess, tz))
    var float curH = na
    var float curL = na
    var int   curStart = na
    var float prevH = na
    var float prevL = na
    var int   prevStart = na

    if inSess and not inSess[1]
        curStart := time
        curH := high
        curL := low

    if inSess
        curH := na(curH) ? high : math.max(curH, high)
        curL := na(curL) ? low  : math.min(curL, low)

    if (not inSess) and inSess[1]
        prevH := curH
        prevL := curL
        prevStart := curStart
        curH := na
        curL := na
        curStart := na

    [prevH, prevL, prevStart]

// Midnight open tracking (00:00 in tz), returns [level, startTime, newDay]
f_midnightOpen_1m(string tz) =>
    int y  = year(time, tz)
    int m  = month(time, tz)
    int d  = dayofmonth(time, tz)
    int y1 = year(time[1], tz)
    int m1 = month(time[1], tz)
    int d1 = dayofmonth(time[1], tz)
    bool newDay = (y != y1) or (m != m1) or (d != d1)

    var float lvl = na
    var int   st  = na
    if newDay
        lvl := open
        st  := time
    [lvl, st, newDay]

// closeState: 0 = — (not swept), 1 = Inside, 2 = Outside
f_levelState_1m(float lvl, bool isHigh, bool resetNow, string htf) =>
    var bool  swept = false
    var int   closeState = 0
    var int   sweptTime = na
    var float sweptLvl = na

    if resetNow
        swept := false
        closeState := 0
        sweptTime := na
        sweptLvl := na

    bool crossNow = false
    if not na(lvl)
        crossNow := isHigh ? (high > lvl) : (low < lvl)

    if (not swept) and crossNow
        swept := true
        sweptTime := time
        sweptLvl := lvl
        closeState := 2

    int hKey = time(htf)
    bool newHTF = hKey != hKey[1]
    if swept and newHTF and not na(sweptLvl)
        bool inside = isHigh ? (close[1] < sweptLvl) : (close[1] > sweptLvl)
        closeState := inside ? 1 : 2

    [swept, closeState, sweptTime, sweptLvl]

// Line style override once swept
styTaken(base, swept) => swept ? "Dotted" : base

// Pretty TF label
f_tfLabel(string tf) =>
    string out = tf
    if str.upper(tf) == "D"
        out := "D"
    else if str.upper(tf) == "W"
        out := "W"
    else if str.upper(tf) == "M"
        out := "M"
    else
        int sec = timeframe.in_seconds(tf)
        if sec >= 86400 and (sec % 86400 == 0)
            out := str.tostring(sec / 86400) + "D"
        else if sec >= 3600 and (sec % 3600 == 0)
            out := str.tostring(sec / 3600) + "H"
        else if sec >= 60 and (sec % 60 == 0)
            out := str.tostring(sec / 60) + "m"
        else
            out := str.tostring(sec) + "s"
    out

closeTFLabel = f_tfLabel(closeTF)

// Touch helper (range crosses level)
touchLevel(float lvl) =>
    low <= lvl and high >= lvl

// VP levels: treat 0.0 as "not set"
vpVah_ok = vpVah != 0.0
vpVal_ok = vpVal != 0.0
vpPoc_ok = vpPoc != 0.0

//─────────────────────────────────────────────────────────────────────────────
// Level sources
//─────────────────────────────────────────────────────────────────────────────
pdh  = request.security(syminfo.tickerid, "D",   high[1], barmerge.gaps_off, barmerge.lookahead_on)
pdl  = request.security(syminfo.tickerid, "D",   low[1],  barmerge.gaps_off, barmerge.lookahead_on)
pdt  = request.security(syminfo.tickerid, "D",   time[1], barmerge.gaps_off, barmerge.lookahead_on)

p1hH = request.security(syminfo.tickerid, "60",  high[1], barmerge.gaps_off, barmerge.lookahead_on)
p1hL = request.security(syminfo.tickerid, "60",  low[1],  barmerge.gaps_off, barmerge.lookahead_on)
p1hT = request.security(syminfo.tickerid, "60",  time[1], barmerge.gaps_off, barmerge.lookahead_on)

p4hH = request.security(syminfo.tickerid, "240", high[1], barmerge.gaps_off, barmerge.lookahead_on)
p4hL = request.security(syminfo.tickerid, "240", low[1],  barmerge.gaps_off, barmerge.lookahead_on)
p4hT = request.security(syminfo.tickerid, "240", time[1], barmerge.gaps_off, barmerge.lookahead_on)

[asiaH, asiaL, asiaT] = request.security(syminfo.tickerid, "1", f_trackPrevSession_1m(asiaSes, sessTZ), barmerge.gaps_off, barmerge.lookahead_off)
[ldnH,  ldnL,  ldnT ] = request.security(syminfo.tickerid, "1", f_trackPrevSession_1m(ldnSes,  sessTZ), barmerge.gaps_off, barmerge.lookahead_off)

// Midnight open anchored to 00:00 in sessTZ (from 1m)
[midLvl, midStartRaw, _] = request.security(syminfo.tickerid, "1", f_midnightOpen_1m(sessTZ), barmerge.gaps_off, barmerge.lookahead_off)

// Persist day start so VP lines don't "walk"
var int dayStart = na
if not na(midStartRaw)
    dayStart := midStartRaw
int vpStart = na(dayStart) ? time : dayStart

// Reset markers (when those level anchors change)
newPD  = showPD  and not na(pdt)  and (pdt  != pdt[1])
newP1H = showP1H and not na(p1hT) and (p1hT != p1hT[1])
newP4H = showP4H and not na(p4hT) and (p4hT != p4hT[1])
newAS  = showAsia and not na(asiaT) and (asiaT != asiaT[1])
newLDN = showLondon and not na(ldnT) and (ldnT != ldnT[1])

// Pull per-level states from 1m
[sPDH, csPDH, sPDH_t, _] = request.security(syminfo.tickerid, "1", f_levelState_1m(pdh,  true,  newPD,  closeTF), barmerge.gaps_off, barmerge.lookahead_off)
[sPDL, csPDL, sPDL_t, _] = request.security(syminfo.tickerid, "1", f_levelState_1m(pdl,  false, newPD,  closeTF), barmerge.gaps_off, barmerge.lookahead_off)

[s1HH, cs1HH, s1HH_t, _] = request.security(syminfo.tickerid, "1", f_levelState_1m(p1hH, true,  newP1H, closeTF), barmerge.gaps_off, barmerge.lookahead_off)
[s1HL, cs1HL, s1HL_t, _] = request.security(syminfo.tickerid, "1", f_levelState_1m(p1hL, false, newP1H, closeTF), barmerge.gaps_off, barmerge.lookahead_off)

[s4HH, cs4HH, s4HH_t, _] = request.security(syminfo.tickerid, "1", f_levelState_1m(p4hH, true,  newP4H, closeTF), barmerge.gaps_off, barmerge.lookahead_off)
[s4HL, cs4HL, s4HL_t, _] = request.security(syminfo.tickerid, "1", f_levelState_1m(p4hL, false, newP4H, closeTF), barmerge.gaps_off, barmerge.lookahead_off)

[sAH,  csAH,  sAH_t,  _] = request.security(syminfo.tickerid, "1", f_levelState_1m(asiaH, true,  newAS,  closeTF), barmerge.gaps_off, barmerge.lookahead_off)
[sAL,  csAL,  sAL_t,  _] = request.security(syminfo.tickerid, "1", f_levelState_1m(asiaL, false, newAS,  closeTF), barmerge.gaps_off, barmerge.lookahead_off)

[sLH,  csLH,  sLH_t,  _] = request.security(syminfo.tickerid, "1", f_levelState_1m(ldnH,  true,  newLDN, closeTF), barmerge.gaps_off, barmerge.lookahead_off)
[sLL,  csLL,  sLL_t,  _] = request.security(syminfo.tickerid, "1", f_levelState_1m(ldnL,  false, newLDN, closeTF), barmerge.gaps_off, barmerge.lookahead_off)

// Freeze line end once SWEPT (crossed)
endPDH = (sPDH and not na(sPDH_t)) ? sPDH_t : endTimeDefault
endPDL = (sPDL and not na(sPDL_t)) ? sPDL_t : endTimeDefault
end1HH = (s1HH and not na(s1HH_t)) ? s1HH_t : endTimeDefault
end1HL = (s1HL and not na(s1HL_t)) ? s1HL_t : endTimeDefault
end4HH = (s4HH and not na(s4HH_t)) ? s4HH_t : endTimeDefault
end4HL = (s4HL and not na(s4HL_t)) ? s4HL_t : endTimeDefault
endAH  = (sAH  and not na(sAH_t )) ? sAH_t  : endTimeDefault
endAL  = (sAL  and not na(sAL_t )) ? sAL_t  : endTimeDefault
endLH  = (sLH  and not na(sLH_t )) ? sLH_t  : endTimeDefault
endLL  = (sLL  and not na(sLL_t )) ? sLL_t  : endTimeDefault
endMID = endTimeDefault

//─────────────────────────────────────────────────────────────────────────────
// Alerts (dynamic)
//─────────────────────────────────────────────────────────────────────────────
bool fireSwept  = false
bool fireInside = false
string sweptName = ""
float  sweptPrice = na
string insideName = ""
float  insidePrice = na

if barstate.isconfirmed and enableAlerts
    if sPDH and not sPDH[1]
        fireSwept := true, sweptName := pdhTxt, sweptPrice := pdh
    if sPDL and not sPDL[1]
        fireSwept := true, sweptName := pdlTxt, sweptPrice := pdl
    if s1HH and not s1HH[1]
        fireSwept := true, sweptName := p1hHTxt, sweptPrice := p1hH
    if s1HL and not s1HL[1]
        fireSwept := true, sweptName := p1hLTxt, sweptPrice := p1hL
    if s4HH and not s4HH[1]
        fireSwept := true, sweptName := p4hHTxt, sweptPrice := p4hH
    if s4HL and not s4HL[1]
        fireSwept := true, sweptName := p4hLTxt, sweptPrice := p4hL
    if sAH and not sAH[1]
        fireSwept := true, sweptName := asiaHTxt, sweptPrice := asiaH
    if sAL and not sAL[1]
        fireSwept := true, sweptName := asiaLTxt, sweptPrice := asiaL
    if sLH and not sLH[1]
        fireSwept := true, sweptName := ldnHTxt, sweptPrice := ldnH
    if sLL and not sLL[1]
        fireSwept := true, sweptName := ldnLTxt, sweptPrice := ldnL

    if sPDH and (csPDH == 1) and (csPDH[1] != 1)
        fireInside := true, insideName := pdhTxt, insidePrice := pdh
    if sPDL and (csPDL == 1) and (csPDL[1] != 1)
        fireInside := true, insideName := pdlTxt, insidePrice := pdl
    if s1HH and (cs1HH == 1) and (cs1HH[1] != 1)
        fireInside := true, insideName := p1hHTxt, insidePrice := p1hH
    if s1HL and (cs1HL == 1) and (cs1HL[1] != 1)
        fireInside := true, insideName := p1hLTxt, insidePrice := p1hL
    if s4HH and (cs4HH == 1) and (cs4HH[1] != 1)
        fireInside := true, insideName := p4hHTxt, insidePrice := p4hH
    if s4HL and (cs4HL == 1) and (cs4HL[1] != 1)
        fireInside := true, insideName := p4hLTxt, insidePrice := p4hL
    if sAH and (csAH == 1) and (csAH[1] != 1)
        fireInside := true, insideName := asiaHTxt, insidePrice := asiaH
    if sAL and (csAL == 1) and (csAL[1] != 1)
        fireInside := true, insideName := asiaLTxt, insidePrice := asiaL
    if sLH and (csLH == 1) and (csLH[1] != 1)
        fireInside := true, insideName := ldnHTxt, insidePrice := ldnH
    if sLL and (csLL == 1) and (csLL[1] != 1)
        fireInside := true, insideName := ldnLTxt, insidePrice := ldnL

if fireSwept and enableAlerts
    alert("SWEPT (1m): " + sweptName + " @ " + str.tostring(sweptPrice, format.mintick), alert.freq_once_per_bar_close)

if fireInside and enableAlerts
    alert("CLOSED INSIDE (" + closeTFLabel + "): " + insideName + " @ " + str.tostring(insidePrice, format.mintick), alert.freq_once_per_bar_close)

//─────────────────────────────────────────────────────────────────────────────
// Draw lines + labels (anti-stacking)
//─────────────────────────────────────────────────────────────────────────────
var line lnPDH = na
var line lnPDL = na
var line ln1HH = na
var line ln1HL = na
var line ln4HH = na
var line ln4HL = na
var line lnAH  = na
var line lnAL  = na
var line lnLH  = na
var line lnLL  = na
var line lnMID = na

var label txPDH = na
var label txPDL = na
var label tx1HH = na
var label tx1HL = na
var label tx4HH = na
var label tx4HL = na
var label txAH  = na
var label txAL  = na
var label txLH  = na
var label txLL  = na
var label txMID = na

float minSep = syminfo.mintick * minSepTicks
float step   = syminfo.mintick * stepTicks

var float yPDH = na
var float yPDL = na
var float y1HH = na
var float y1HL = na
var float y4HH = na
var float y4HL = na
var float yAH  = na
var float yAL  = na
var float yLH  = na
var float yLL  = na
var float yMID = na

yPDH := na, yPDL := na, y1HH := na, y1HL := na, y4HH := na, y4HL := na, yAH := na, yAL := na, yLH := na, yLL := na, yMID := na

if showPD and not na(pdh) and not na(pdl) and not na(pdt)
    lnPDH := f_upsertLine(lnPDH, pdt, endPDH, pdh, pdCol, pdW, styTaken(pdSty, sPDH))
    lnPDL := f_upsertLine(lnPDL, pdt, endPDL, pdl, pdCol, pdW, styTaken(pdSty, sPDL))
    yPDH := f_stackY(pdh, na,na,na,na,na,na,na, minSep, step)
    yPDL := f_stackY(pdl, yPDH,na,na,na,na,na,na, minSep, step)
    txPDH := f_upsertText(txPDH, labelXTime(endPDH), yPDH, pdhTxt, pdTxtCol, pdTxtSz)
    txPDL := f_upsertText(txPDL, labelXTime(endPDL), yPDL, pdlTxt, pdTxtCol, pdTxtSz)

if showP1H and not na(p1hH) and not na(p1hL) and not na(p1hT)
    ln1HH := f_upsertLine(ln1HH, p1hT, end1HH, p1hH, p1hCol, p1hW, styTaken(p1hSty, s1HH))
    ln1HL := f_upsertLine(ln1HL, p1hT, end1HL, p1hL, p1hCol, p1hW, styTaken(p1hSty, s1HL))
    y1HH := f_stackY(p1hH, yPDH,yPDL,na,na,na,na,na, minSep, step)
    y1HL := f_stackY(p1hL, yPDH,yPDL,y1HH,na,na,na,na, minSep, step)
    tx1HH := f_upsertText(tx1HH, labelXTime(end1HH), y1HH, p1hHTxt, p1hTxtCol, p1hTxtSz)
    tx1HL := f_upsertText(tx1HL, labelXTime(end1HL), y1HL, p1hLTxt, p1hTxtCol, p1hTxtSz)

if showP4H and not na(p4hH) and not na(p4hL) and not na(p4hT)
    ln4HH := f_upsertLine(ln4HH, p4hT, end4HH, p4hH, p4hCol, p4hW, styTaken(p4hSty, s4HH))
    ln4HL := f_upsertLine(ln4HL, p4hT, end4HL, p4hL, p4hCol, p4hW, styTaken(p4hSty, s4HL))
    y4HH := f_stackY(p4hH, yPDH,yPDL,y1HH,y1HL,na,na,na, minSep, step)
    y4HL := f_stackY(p4hL, yPDH,yPDL,y1HH,y1HL,y4HH,na,na, minSep, step)
    tx4HH := f_upsertText(tx4HH, labelXTime(end4HH), y4HH, p4hHTxt, p4hTxtCol, p4hTxtSz)
    tx4HL := f_upsertText(tx4HL, labelXTime(end4HL), y4HL, p4hLTxt, p4hTxtCol, p4hTxtSz)

if showAsia and not na(asiaH) and not na(asiaL) and not na(asiaT)
    lnAH := f_upsertLine(lnAH, asiaT, endAH, asiaH, asiaCol, asiaW, styTaken(asiaSty, sAH))
    lnAL := f_upsertLine(lnAL, asiaT, endAL, asiaL, asiaCol, asiaW, styTaken(asiaSty, sAL))
    yAH := f_stackY(asiaH, yPDH,yPDL,y1HH,y1HL,y4HH,y4HL,na, minSep, step)
    yAL := f_stackY(asiaL, yPDH,yPDL,y1HH,y1HL,y4HH,y4HL,yAH, minSep, step)
    txAH := f_upsertText(txAH, labelXTime(endAH), yAH, asiaHTxt, asiaTxtCol, asiaTxtSz)
    txAL := f_upsertText(txAL, labelXTime(endAL), yAL, asiaLTxt, asiaTxtCol, asiaTxtSz)

if showLondon and not na(ldnH) and not na(ldnL) and not na(ldnT)
    lnLH := f_upsertLine(lnLH, ldnT, endLH, ldnH, ldnCol, ldnW, styTaken(ldnSty, sLH))
    lnLL := f_upsertLine(lnLL, ldnT, endLL, ldnL, ldnCol, ldnW, styTaken(ldnSty, sLL))
    yLH := f_stackY(ldnH, yPDH,yPDL,y1HH,y1HL,y4HH,y4HL,yAH, minSep, step)
    yLL := f_stackY(ldnL, yPDH,yPDL,y1HH,y1HL,y4HH,y4HL,yAL, minSep, step)
    txLH := f_upsertText(txLH, labelXTime(endLH), yLH, ldnHTxt, ldnTxtCol, ldnTxtSz)
    txLL := f_upsertText(txLL, labelXTime(endLL), yLL, ldnLTxt, ldnTxtCol, ldnTxtSz)

// Midnight open line
if showMidnight and not na(midLvl) and not na(dayStart)
    lnMID := f_upsertLine(lnMID, dayStart, endMID, midLvl, midCol, midW, midSty)
    yMID := f_stackY(midLvl, yPDH,yPDL,y1HH,y1HL,y4HH,y4HL,yAH, minSep, step)
    txMID := f_upsertText(txMID, labelXTime(endMID), yMID, midTxt, midTxtCol, midTxtSz)

//─────────────────────────────────────────────────────────────────────────────
// VP lines: extend right + TRUE price-scale anchored labels
//─────────────────────────────────────────────────────────────────────────────
var line lnVAH = na
var line lnVAL = na
var line lnPOC = na

if showVP and not na(dayStart)
    if vpVah_ok
        if na(lnVAH)
            lnVAH := line.new(x1=vpStart, y1=vpVah, x2=vpStart + barMs, y2=vpVah,
                 xloc=xloc.bar_time, extend=extend.right, color=vpColHV, width=vpW, style=f_lineStyle(vpStyHV))
        else
            line.set_x1(lnVAH, vpStart), line.set_y1(lnVAH, vpVah)
            line.set_x2(lnVAH, vpStart + barMs), line.set_y2(lnVAH, vpVah)
            line.set_extend(lnVAH, extend.right)
            line.set_color(lnVAH, vpColHV), line.set_width(lnVAH, vpW), line.set_style(lnVAH, f_lineStyle(vpStyHV))

    if vpVal_ok
        if na(lnVAL)
            lnVAL := line.new(x1=vpStart, y1=vpVal, x2=vpStart + barMs, y2=vpVal,
                 xloc=xloc.bar_time, extend=extend.right, color=vpColHV, width=vpW, style=f_lineStyle(vpStyHV))
        else
            line.set_x1(lnVAL, vpStart), line.set_y1(lnVAL, vpVal)
            line.set_x2(lnVAL, vpStart + barMs), line.set_y2(lnVAL, vpVal)
            line.set_extend(lnVAL, extend.right)
            line.set_color(lnVAL, vpColHV), line.set_width(lnVAL, vpW), line.set_style(lnVAL, f_lineStyle(vpStyHV))

    if vpPoc_ok
        if na(lnPOC)
            lnPOC := line.new(x1=vpStart, y1=vpPoc, x2=vpStart + barMs, y2=vpPoc,
                 xloc=xloc.bar_time, extend=extend.right, color=vpColPOC, width=vpW, style=f_lineStyle(vpStyPOC))
        else
            line.set_x1(lnPOC, vpStart), line.set_y1(lnPOC, vpPoc)
            line.set_x2(lnPOC, vpStart + barMs), line.set_y2(lnPOC, vpPoc)
            line.set_extend(lnPOC, extend.right)
            line.set_color(lnPOC, vpColPOC), line.set_width(lnPOC, vpW), line.set_style(lnPOC, f_lineStyle(vpStyPOC))

// TRUE price-scale anchored tags (these do NOT move when you pan)
// NOTE: plot titles must be CONST strings in Pine.
plot(showVP and vpVah_ok ? vpVah : na, title="Yesterdays VAH", color=vpColHV, linewidth=1, style=plot.style_linebr, trackprice=true)
plot(showVP and vpVal_ok ? vpVal : na, title="Yesterdays VAL", color=vpColHV, linewidth=1, style=plot.style_linebr, trackprice=true)
plot(showVP and vpPoc_ok ? vpPoc : na, title="Yesterdays POC", color=vpColPOC, linewidth=1, style=plot.style_linebr, trackprice=true)

//─────────────────────────────────────────────────────────────────────────────
// VP Touch Alerts
//─────────────────────────────────────────────────────────────────────────────
bool touchVAH = showVP and vpVah_ok and touchLevel(vpVah)
bool touchVAL = showVP and vpVal_ok and touchLevel(vpVal)
bool touchPOC = showVP and vpPoc_ok and touchLevel(vpPoc)
bool touchANY = touchVAH or touchVAL or touchPOC

if enableAlerts and barstate.isconfirmed
    if touchVAH
        alert("TOUCH: " + vpVahTxt + " @ " + str.tostring(vpVah, format.mintick), alert.freq_once_per_bar_close)
    if touchVAL
        alert("TOUCH: " + vpValTxt + " @ " + str.tostring(vpVal, format.mintick), alert.freq_once_per_bar_close)
    if touchPOC
        alert("TOUCH: " + vpPocTxt + " @ " + str.tostring(vpPoc, format.mintick), alert.freq_once_per_bar_close)

alertcondition(touchVAH, "Touch PD VAH", "Price touched previous day's VAH.")
alertcondition(touchVAL, "Touch PD VAL", "Price touched previous day's VAL.")
alertcondition(touchPOC, "Touch PD POC", "Price touched previous day's POC.")
alertcondition(touchANY, "Touch Any PD VP Level", "Price touched VAH/VAL/POC.")

//─────────────────────────────────────────────────────────────────────────────
// Table
//─────────────────────────────────────────────────────────────────────────────
f_sweptTxt(bool t) => t ? "SWEPT" : "UNSWEPT"
f_sweptBg(bool t) => t ? tableTakenBg : tableUntakenBg

f_closeTxt(int st) =>
    string out = "—"
    if st == 1
        out := "Inside (" + closeTFLabel + ")"
    else if st == 2
        out := "Outside (" + closeTFLabel + ")"
    out

var table tb = na
if showTable and barstate.isfirst
    tb := table.new(f_pos(tablePos), 3, 11, border_width=tableBorderW, border_color=tableBorderCol)

if showTable and not na(tb)
    table.cell(tb, 0, 0, "LEVEL", text_color=tableHdrTx, bgcolor=tableHdrBg, text_size=f_textSize(tableTextSz))
    table.cell(tb, 1, 0, "SWEEP?", text_color=tableHdrTx, bgcolor=tableHdrBg, text_size=f_textSize(tableTextSz))
    table.cell(tb, 2, 0, "CLOSE", text_color=tableHdrTx, bgcolor=tableHdrBg, text_size=f_textSize(tableTextSz))

    table.cell(tb, 0, 1, pdhTxt, text_color=tableRowTx, text_size=f_textSize(tableTextSz))
    table.cell(tb, 1, 1, f_sweptTxt(sPDH), text_color=tableRowTx, bgcolor=f_sweptBg(sPDH), text_size=f_textSize(tableTextSz))
    table.cell(tb, 2, 1, f_closeTxt(csPDH), text_color=tableRowTx, text_size=f_textSize(tableTextSz))

    table.cell(tb, 0, 2, pdlTxt, text_color=tableRowTx, text_size=f_textSize(tableTextSz))
    table.cell(tb, 1, 2, f_sweptTxt(sPDL), text_color=tableRowTx, bgcolor=f_sweptBg(sPDL), text_size=f_textSize(tableTextSz))
    table.cell(tb, 2, 2, f_closeTxt(csPDL), text_color=tableRowTx, text_size=f_textSize(tableTextSz))

    table.cell(tb, 0, 3, p1hHTxt, text_color=tableRowTx, text_size=f_textSize(tableTextSz))
    table.cell(tb, 1, 3, f_sweptTxt(s1HH), text_color=tableRowTx, bgcolor=f_sweptBg(s1HH), text_size=f_textSize(tableTextSz))
    table.cell(tb, 2, 3, f_closeTxt(cs1HH), text_color=tableRowTx, text_size=f_textSize(tableTextSz))

    table.cell(tb, 0, 4, p1hLTxt, text_color=tableRowTx, text_size=f_textSize(tableTextSz))
    table.cell(tb, 1, 4, f_sweptTxt(s1HL), text_color=tableRowTx, bgcolor=f_sweptBg(s1HL), text_size=f_textSize(tableTextSz))
    table.cell(tb, 2, 4, f_closeTxt(cs1HL), text_color=tableRowTx, text_size=f_textSize(tableTextSz))

    table.cell(tb, 0, 5, p4hHTxt, text_color=tableRowTx, text_size=f_textSize(tableTextSz))
    table.cell(tb, 1, 5, f_sweptTxt(s4HH), text_color=tableRowTx, bgcolor=f_sweptBg(s4HH), text_size=f_textSize(tableTextSz))
    table.cell(tb, 2, 5, f_closeTxt(cs4HH), text_color=tableRowTx, text_size=f_textSize(tableTextSz))

    table.cell(tb, 0, 6, p4hLTxt, text_color=tableRowTx, text_size=f_textSize(tableTextSz))
    table.cell(tb, 1, 6, f_sweptTxt(s4HL), text_color=tableRowTx, bgcolor=f_sweptBg(s4HL), text_size=f_textSize(tableTextSz))
    table.cell(tb, 2, 6, f_closeTxt(cs4HL), text_color=tableRowTx, text_size=f_textSize(tableTextSz))

    table.cell(tb, 0, 7, asiaHTxt, text_color=tableRowTx, text_size=f_textSize(tableTextSz))
    table.cell(tb, 1, 7, f_sweptTxt(sAH), text_color=tableRowTx, bgcolor=f_sweptBg(sAH), text_size=f_textSize(tableTextSz))
    table.cell(tb, 2, 7, f_closeTxt(csAH), text_color=tableRowTx, text_size=f_textSize(tableTextSz))

    table.cell(tb, 0, 8, asiaLTxt, text_color=tableRowTx, text_size=f_textSize(tableTextSz))
    table.cell(tb, 1, 8, f_sweptTxt(sAL), text_color=tableRowTx, bgcolor=f_sweptBg(sAL), text_size=f_textSize(tableTextSz))
    table.cell(tb, 2, 8, f_closeTxt(csAL), text_color=tableRowTx, text_size=f_textSize(tableTextSz))

    table.cell(tb, 0, 9, ldnHTxt, text_color=tableRowTx, text_size=f_textSize(tableTextSz))
    table.cell(tb, 1, 9, f_sweptTxt(sLH), text_color=tableRowTx, bgcolor=f_sweptBg(sLH), text_size=f_textSize(tableTextSz))
    table.cell(tb, 2, 9, f_closeTxt(csLH), text_color=tableRowTx, text_size=f_textSize(tableTextSz))

    table.cell(tb, 0, 10, ldnLTxt, text_color=tableRowTx, text_size=f_textSize(tableTextSz))
    table.cell(tb, 1, 10, f_sweptTxt(sLL), text_color=tableRowTx, bgcolor=f_sweptBg(sLL), text_size=f_textSize(tableTextSz))
    table.cell(tb, 2, 10, f_closeTxt(csLL), text_color=tableRowTx, text_size=f_textSize(tableTextSz))

alertcondition(fireSwept,  "Level Swept (1m)", "A tracked level was swept (crossed) using 1-minute data.")
alertcondition(fireInside, "HTF Closed Inside", "Chosen HTF closed back inside a swept level.")
````
