# Weekly & Daily Reference Levels 

- url: https://www.tradingview.com/script/lxYljRGM-Weekly-Daily-Reference-Levels/
- type: indicator
- pine_id: PUB;3d18787cf0cb49aaac7bc853cfaabe94
- version: 2.0

## Description

Weekly & Daily Reference Levels (ICT)

Plots and labels six key price reference levels drawn directly from ICT methodology — Current Week High/Low (CWH/CWL), Previous Week High/Low (PWH/PWL), and Previous Day High/Low (PDH/PDL) — giving you a clean, always-updated map of where liquidity is resting and where price has been engineered from.
CWH and CWL update live as the week develops, acting as your active buy-side and sell-side liquidity references. PWH and PWL lock at the weekly close and serve as the higher-timeframe draw targets framing the current week's range. PDH and PDL reset each day, giving you the prior session's engineered liquidity for the current trading day — the levels most likely to be swept before any meaningful directional move.
When two or more levels coincide within a configurable price threshold, their labels automatically merge into a single combined label — so instead of stacked text you get one clean read like CWH + PDH directly on the line. The moment those levels separate, the labels split back out independently. No overlaps, no clutter, no manual cleanup required.
Built to stay readable on a white background at any scalping timeframe from 1m to 15m. Solid lines for active levels, dotted for reference levels, and a strict one-label-per-line rule enforced throughout.
Displays: CWH · CWL · PWH · PWL · PDH · PDL — nothing else.

Enjoy. :)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ 
//@version=6
indicator("Weekly & Daily Reference Levels", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─── INPUTS ───────────────────────────────────────────
showCW         = input.bool(true,  "Show Current Week Levels",  group = "Visibility")
showPW         = input.bool(true,  "Show Previous Week Levels", group = "Visibility")
showPD         = input.bool(true,  "Show Previous Day Levels",  group = "Visibility")
showHistory    = input.bool(true,  "Show Historical Levels",    group = "Visibility", tooltip = "Show past levels as static segments")
mergeThreshold = input.float(0.05, "Merge Threshold (%)", minval = 0.01, maxval = 0.5, step = 0.01, group = "Labels")
labelOffset    = input.int(9,      "Label Bar Offset (bars right)", minval = 1, maxval = 100, group = "Labels")
labelSizeStr   = input.string("tiny", "Label Size", options = ["tiny", "small"], group = "Labels")

// ─── STYLE CONSTANTS ──────────────────────────────────
COLOR_CWH = #056cd2
COLOR_CWL = #8B0000
COLOR_PWH = #056cd2
COLOR_PWL = #8B0000
COLOR_PDH = #000000
COLOR_PDL = #000000

// ─── DATA STRUCTURES ──────────────────────────────────
// FIX: idx now stores `time` (int milliseconds) — not bar_index
// This avoids the "x1 bar index too far from current bar" error
type LevelPoint
    float val
    int   t     // unix time in ms

type LevelInfo
    float  val
    string title
    color  col
    int    rank

type LabelGroupData
    label  lbl
    float  yPos
    string txt
    color  c

// ─── STATE ────────────────────────────────────────────
//@variable Current week high — time-anchored
var LevelPoint cwh = LevelPoint.new(0.0,  time)
//@variable Current week low — time-anchored
var LevelPoint cwl = LevelPoint.new(1e10, time)
//@variable Previous week high
var LevelPoint pwh = LevelPoint.new(na, na)
//@variable Previous week low
var LevelPoint pwl = LevelPoint.new(na, na)
//@variable Previous day high
var LevelPoint pdh = LevelPoint.new(na, na)
//@variable Previous day low
var LevelPoint pdl = LevelPoint.new(na, na)

var float d_high     = 0.0
var float d_low      = 1e10
var int   d_high_t   = time   // time of intraday high
var int   d_low_t    = time   // time of intraday low

isNewWeek = timeframe.isintraday and time("W") != time("W")[1]
isNewDay  = timeframe.isintraday and time("D") != time("D")[1]

// ─── HISTORICAL SEGMENTS ──────────────────────────────
var line[] histLines = array.new<line>()

//@function Pushes a completed historical level segment using time-based x coords
//@param val    (float) Price level
//@param t1     (int)   Start time in ms
//@param t2     (int)   End time in ms
//@param col    (color) Line colour
//@param wid    (int)   Line width
//@param stl    (string) Line style
//@returns void
addHistLine(float val, int t1, int t2, color col, int wid, string stl) =>
    if showHistory and not na(val)
        histLines.push(
             line.new(t1, val, t2, val,
                      xloc  = xloc.bar_time,
                      color = color.new(col, 50),
                      width = wid,
                      style = stl))
        if histLines.size() > 450
            line.delete(histLines.shift())

// ─── HIGH / LOW TRACKING ──────────────────────────────
if isNewWeek
    // Archive the week that just closed
    addHistLine(cwh.val, cwh.t, time[1], COLOR_CWH, 1, line.style_solid)
    addHistLine(cwl.val, cwl.t, time[1], COLOR_CWL, 1, line.style_solid)

    pwh.val := cwh.val
    pwh.t   := cwh.t
    pwl.val := cwl.val
    pwl.t   := cwl.t
    // Reset current week from this bar
    cwh.val := high
    cwh.t   := time
    cwl.val := low
    cwl.t   := time
else
    if high > cwh.val
        cwh.val := high
        cwh.t   := time
    if low < cwl.val
        cwl.val := low
        cwl.t   := time

if isNewDay
    // Archive the day that just closed
    addHistLine(d_high, d_high_t, time[1], COLOR_PDH, 1, line.style_dotted)
    addHistLine(d_low,  d_low_t,  time[1], COLOR_PDL, 1, line.style_dotted)

    pdh.val := d_high
    pdh.t   := d_high_t
    pdl.val := d_low
    pdl.t   := d_low_t
    // Reset intraday tracking
    d_high   := high
    d_high_t := time
    d_low    := low
    d_low_t  := time
else
    if high > d_high
        d_high   := high
        d_high_t := time
    if low < d_low
        d_low   := low
        d_low_t := time

// ─── PDH / PDL BROKEN FLAGS ───────────────────────────
var bool pdhBroken = false
var bool pdlBroken = false
if isNewDay
    pdhBroken := false
    pdlBroken := false
if not pdhBroken and not na(pdh.val) and close > pdh.val
    pdhBroken := true
if not pdlBroken and not na(pdl.val) and close < pdl.val
    pdlBroken := true

// ─── ACTIVE LINE OBJECTS (time-based) ─────────────────
// Initialise with dummy coords — updated every bar on barstate.islast
var line lnCWH = line.new(time, close, time, close, xloc = xloc.bar_time, color = COLOR_CWH, width = 2)
var line lnCWL = line.new(time, close, time, close, xloc = xloc.bar_time, color = COLOR_CWL, width = 2)
var line lnPWH = line.new(time, close, time, close, xloc = xloc.bar_time, color = COLOR_PWH, width = 1, style = line.style_dotted)
var line lnPWL = line.new(time, close, time, close, xloc = xloc.bar_time, color = COLOR_PWL, width = 1, style = line.style_dotted)
var line lnPDH = line.new(time, close, time, close, xloc = xloc.bar_time, color = COLOR_PDH, width = 1, style = line.style_dotted)
var line lnPDL = line.new(time, close, time, close, xloc = xloc.bar_time, color = COLOR_PDL, width = 1, style = line.style_dotted)

// ─── LABEL OBJECTS ────────────────────────────────────
var label lblCWH = label.new(bar_index, close, "", style = label.style_none, size = size.tiny)
var label lblCWL = label.new(bar_index, close, "", style = label.style_none, size = size.tiny)
var label lblPWH = label.new(bar_index, close, "", style = label.style_none, size = size.tiny)
var label lblPWL = label.new(bar_index, close, "", style = label.style_none, size = size.tiny)
var label lblPDH = label.new(bar_index, close, "", style = label.style_none, size = size.tiny)
var label lblPDL = label.new(bar_index, close, "", style = label.style_none, size = size.tiny)

// ─── RENDER ON LAST BAR ───────────────────────────────
if barstate.islast
    // Project lines forward by 10 bars worth of time from current bar
    int barMs    = math.round((time - time[1]))  // approx ms per bar
    int fwdTime  = time + barMs * 10

    // Active level lines — x1 anchored to origin time, x2 projected forward
    line.set_x1(lnCWH, cwh.t)
    line.set_x2(lnCWH, fwdTime)
    line.set_y1(lnCWH, cwh.val)
    line.set_y2(lnCWH, cwh.val)
    line.set_color(lnCWH, showCW ? COLOR_CWH : color.new(color.white, 100))

    line.set_x1(lnCWL, cwl.t)
    line.set_x2(lnCWL, fwdTime)
    line.set_y1(lnCWL, cwl.val)
    line.set_y2(lnCWL, cwl.val)
    line.set_color(lnCWL, showCW ? COLOR_CWL : color.new(color.white, 100))

    line.set_x1(lnPWH, na(pwh.t) ? time : pwh.t)
    line.set_x2(lnPWH, fwdTime)
    line.set_y1(lnPWH, nz(pwh.val))
    line.set_y2(lnPWH, nz(pwh.val))
    line.set_color(lnPWH, (showPW and not na(pwh.val)) ? COLOR_PWH : color.new(color.white, 100))

    line.set_x1(lnPWL, na(pwl.t) ? time : pwl.t)
    line.set_x2(lnPWL, fwdTime)
    line.set_y1(lnPWL, nz(pwl.val))
    line.set_y2(lnPWL, nz(pwl.val))
    line.set_color(lnPWL, (showPW and not na(pwl.val)) ? COLOR_PWL : color.new(color.white, 100))

    line.set_x1(lnPDH, na(pdh.t) ? time : pdh.t)
    line.set_x2(lnPDH, fwdTime)
    line.set_y1(lnPDH, nz(pdh.val))
    line.set_y2(lnPDH, nz(pdh.val))
    line.set_color(lnPDH, (showPD and not na(pdh.val) and not pdhBroken) ? COLOR_PDH : color.new(color.white, 100))

    line.set_x1(lnPDL, na(pdl.t) ? time : pdl.t)
    line.set_x2(lnPDL, fwdTime)
    line.set_y1(lnPDL, nz(pdl.val))
    line.set_y2(lnPDL, nz(pdl.val))
    line.set_color(lnPDL, (showPD and not na(pdl.val) and not pdlBroken) ? COLOR_PDL : color.new(color.white, 100))

    // ─── LABEL COLLECTION & MERGE ─────────────────────
    lvls = array.new<LevelInfo>()
    if showCW
        lvls.push(LevelInfo.new(cwh.val, "CWH", COLOR_CWH, 1))
        lvls.push(LevelInfo.new(cwl.val, "CWL", COLOR_CWL, 2))
    if showPW and not na(pwh.val)
        lvls.push(LevelInfo.new(pwh.val, "PWH", COLOR_PWH, 3))
        lvls.push(LevelInfo.new(pwl.val, "PWL", COLOR_PWL, 4))
    if showPD and not na(pdh.val)
        if not pdhBroken
            lvls.push(LevelInfo.new(pdh.val, "PDH", COLOR_PDH, 5))
        if not pdlBroken
            lvls.push(LevelInfo.new(pdl.val, "PDL", COLOR_PDL, 6))

    // Reset all labels to invisible
    array<label> allLabels = array.from(lblCWH, lblCWL, lblPWH, lblPWL, lblPDH, lblPDL)
    for lbl in allLabels
        label.set_text(lbl, "")
        label.set_textcolor(lbl, color.new(color.black, 100))

    // Merge nearby labels within threshold
    labelGroups = array.new<LabelGroupData>()
    int n               = lvls.size()
    array<bool> proc    = array.new<bool>(n, false)

    for i = 0 to (n > 0 ? n - 1 : -1)
        if proc.get(i)
            continue
        LevelInfo base = lvls.get(i)
        string mTxt = base.title
        color  mCol = base.col
        int    topR = base.rank
        float  sPri = base.val
        int    cnt  = 1
        proc.set(i, true)

        // Guard: only enter inner loop if there are remaining items to compare
        if i < n - 1
            for j = i + 1 to n - 1
                if proc.get(j)
                    continue
                LevelInfo target = lvls.get(j)
                if math.abs(base.val - target.val) / base.val * 100 <= mergeThreshold
                    mTxt += " + " + target.title
                    if target.rank < topR
                        topR := target.rank
                        mCol := target.col
                    sPri += target.val
                    cnt  += 1
                    proc.set(j, true)

        label targetLbl = switch base.title
            "CWH" => lblCWH
            "CWL" => lblCWL
            "PWH" => lblPWH
            "PWL" => lblPWL
            "PDH" => lblPDH
            => lblPDL

        labelGroups.push(LabelGroupData.new(targetLbl, sPri / cnt, mTxt, mCol))

    // Sort descending by price for stagger logic
    if labelGroups.size() > 1
        for i = 0 to labelGroups.size() - 2
            for j = i + 1 to labelGroups.size() - 1
                if labelGroups.get(i).yPos < labelGroups.get(j).yPos
                    temp = labelGroups.get(i)
                    labelGroups.set(i, labelGroups.get(j))
                    labelGroups.set(j, temp)

        float stagger = syminfo.mintick * 120
        for i = 1 to labelGroups.size() - 1
            LabelGroupData prev = labelGroups.get(i - 1)
            LabelGroupData curr = labelGroups.get(i)
            if (prev.yPos - curr.yPos) < (curr.yPos * 0.001)
                curr.yPos := prev.yPos - stagger

    // Render labels
    for g in labelGroups
        label.set_xy(g.lbl, bar_index + labelOffset, g.yPos)
        label.set_text(g.lbl, g.txt)
        label.set_textcolor(g.lbl, g.c)
        label.set_size(g.lbl, labelSizeStr == "small" ? size.small : size.tiny)
````
