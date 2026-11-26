# STS4x - Initial Balance

- url: https://www.tradingview.com/script/a2sADa5T-STS4x-Initial-Balance/
- type: indicator
- pine_id: PUB;7d6f722125b7491c95b6c57929f474fe
- version: 1.0

## Description

Clean Initial Balance with bar-anchored line origins, H/L letter markers, and a live info dashboard. Built for index futures (ES/NQ/YM and their micros) but works on anything intraday.
What it does:
Tracks the high and low established in the first 30 or 60 minutes of the RTH session, locks the range when the window closes, and gives you the IBH, IBL, midpoint, plus optional 1x and 2x range extensions for the rest of the day.
What sets it apart:

IBH and IBL lines start at the exact bar that printed each extreme. Not at session open. The midpoint anchors at whichever extreme came first.
"H" and "L" letter tag markers sit on those exact candles so you can see at a glance where the structural extremes were set.
Solid color info dashboard with sectioned layout. No transparent washes. Four built-in schemes: STS4x Cyan, Amber Terminal, Crimson Pro, Mono Slate.
Live position and break tracking. The table shows whether price is above IBH, inside, or below IBL, the live distance to each level, and flips green or red the moment either side breaks.
Day-end freeze. Lines extend forward each bar during RTH and freeze permanently at session close. New day resets cleanly.
No repaint. IB values lock when the window closes and stay frozen for the day.

How traders use the IB:

Above IBH on a strong open: trend-day potential, IBH becomes support
Below IBL on a weak open: same logic short, IBL becomes resistance
Holding inside the IB: rotational day, fade the edges
Both sides broken: distribution day, lower conviction
1x and 2x extensions act as target zones on trend days

Settings:

IB Length: 30 min or 60 min (60 default)
RTH session and timezone (defaults to 0930-1600 ET)
Bars ahead of price: how far lines project forward
Independent color, width, and style controls for IBH, IBL, IBM
Marker style: Letter Tag, Letter Circle, or Plain Circle
1x and 2x range extensions, optional
Solid color price tags at the right edge
Info table position, size, and color scheme

Alerts:

IB Locked
IBH Break
IBL Break

Recommended timeframes: 1m, 3m, 5m, 15m. Lower timeframes give cleaner extremes since the lines anchor to the exact bars that set them.
Works on any intraday timeframe. Will not load on Daily, Weekly, or Monthly since IB doesn't apply there.

## Source Code

````pine
//@version=5
// =============================================================================
// STS4x - Initial Balance  (v3: Industrial Terminal styling)
//
// Sturdy, professional dashboard look. Solid (no transparency) backgrounds,
// sectioned layout, uppercase labels, right-aligned values, accent-framed
// table. Matching solid-bg price tags and letter markers (H/L) on the bars
// that printed the IBH and IBL.
//
// Lines start at the EXACT bar that printed each extreme. Lines extend
// forward by ibExtBars during RTH, then freeze permanently at RTH close.
// =============================================================================

indicator("STS4x - Initial Balance", shorttitle="STS4x IB", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

if timeframe.isdwm
    runtime.error("STS4x IB only works on intraday timeframes.")


// =============================================================================
// INPUTS
// =============================================================================

// --- IB Settings ---
grpIB     = "Initial Balance"
ibLength  = input.string("60 min", "IB Length", options=["30 min","60 min"], group=grpIB, tooltip="Length of the Initial Balance period from RTH open.")
sessRTH   = input.session("0930-1600", "RTH Session", group=grpIB, tooltip="Full RTH window for break/position tracking. 0930-1600 = ES/NQ/YM RTH.")
sessTZ    = input.string("America/New_York", "Session Timezone", options=["America/New_York","America/Chicago","America/Los_Angeles","Etc/UTC"], group=grpIB)
ibExtBars = input.int(20, "Bars ahead of current price", minval=1, maxval=500, group=grpIB)

// --- IB High Line ---
grpH     = "IB High Line"
showHigh = input.bool(true, "Show", group=grpH, inline="h1")
ibHColor = input.color(color.aqua, "Color", group=grpH, inline="h1")
ibHWidth = input.int(2, "Width", minval=1, maxval=5, group=grpH, inline="h2")
ibHStyle = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group=grpH, inline="h2")

// --- IB Low Line ---
grpL     = "IB Low Line"
showLow  = input.bool(true, "Show", group=grpL, inline="l1")
ibLColor = input.color(#ff5252, "Color", group=grpL, inline="l1")
ibLWidth = input.int(2, "Width", minval=1, maxval=5, group=grpL, inline="l2")
ibLStyle = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group=grpL, inline="l2")

// --- IB Mid Line ---
grpM     = "IB Midpoint"
showMid  = input.bool(true, "Show", group=grpM, inline="m1")
ibMColor = input.color(color.yellow, "Color", group=grpM, inline="m1")
ibMWidth = input.int(1, "Width", minval=1, maxval=5, group=grpM, inline="m2")
ibMStyle = input.string("Dashed", "Style", options=["Solid","Dashed","Dotted"], group=grpM, inline="m2")

// --- IBH/IBL Markers ---
grpDots     = "IBH/IBL Markers"
showDots    = input.bool(true, "Show markers on the bars that printed the extremes", group=grpDots)
dotStyleOpt = input.string("Letter Tag", "Marker Style", options=["Letter Tag","Letter Circle","Plain Circle"], group=grpDots)
dotSizeStr  = input.string("small", "Marker Size", options=["tiny","small","normal","large"], group=grpDots)

// --- Extensions ---
grpE     = "Extensions"
showExt1 = input.bool(true, "Show 1.0x Extensions (IBH+1 / IBL-1)", group=grpE)
showExt2 = input.bool(true, "Show 2.0x Extensions (IBH+2 / IBL-2)", group=grpE)
ibEColor = input.color(color.gray, "Color", group=grpE, inline="e1")
ibEWidth = input.int(1, "Width", minval=1, maxval=5, group=grpE, inline="e1")
ibEStyle = input.string("Dotted", "Style", options=["Solid","Dashed","Dotted"], group=grpE, inline="e1")

// --- Range Fill ---
grpF       = "Range Fill"
showFill   = input.bool(true, "Fill IB Range (over IB window only)", group=grpF)
fillColor  = input.color(color.aqua, "Fill Color", group=grpF, inline="f1")
fillTransp = input.int(92, "Transparency", minval=0, maxval=100, group=grpF, inline="f1")

// --- Right-edge Price Tags ---
grpLB        = "Price Tags"
showLabels   = input.bool(true, "Show Price Tags at Right Edge", group=grpLB)
labelSizeStr = input.string("normal", "Tag Size", options=["tiny","small","normal","large"], group=grpLB)

// --- Info Table ---
grpT         = "Info Table"
showTable    = input.bool(true, "Show Info Table", group=grpT)
schemeOpt    = input.string("STS4x Cyan", "Color Scheme", options=["STS4x Cyan","Amber Terminal","Crimson Pro","Mono Slate"], group=grpT, tooltip="Industrial terminal palettes. All solid - no transparency.")
tablePosStr  = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"], group=grpT)
tableSizeStr = input.string("normal", "Size", options=["tiny","small","normal","large"], group=grpT)


// =============================================================================
// HELPERS
// =============================================================================
getStyle(s) => s == "Solid" ? line.style_solid : (s == "Dashed" ? line.style_dashed : line.style_dotted)
getSize(s)  => s == "tiny" ? size.tiny : (s == "small" ? size.small : (s == "large" ? size.large : size.normal))
getTPos(p)  => p == "Top Right" ? position.top_right : (p == "Top Left" ? position.top_left : (p == "Bottom Right" ? position.bottom_right : (p == "Bottom Left" ? position.bottom_left : (p == "Middle Right" ? position.middle_right : position.middle_left))))

fmtVol(v) =>
    av = math.abs(v)
    av >= 1000000 ? str.tostring(v / 1000000.0, "#.##") + "M" : (av >= 1000 ? str.tostring(v / 1000.0, "#.#") + "K" : str.tostring(v, "#"))

fmtSigned(x) => (x >= 0 ? "+" : "") + str.tostring(x, "#.##")


// =============================================================================
// COLOR SCHEME RESOLUTION (all solid - no transparency)
// =============================================================================
bgMain = switch schemeOpt
    "Amber Terminal" => #1a1410
    "Crimson Pro"    => #1a0c0c
    "Mono Slate"     => #1c2128
    =>                  #0a1628

bgBorder = switch schemeOpt
    "Amber Terminal" => #2d2418
    "Crimson Pro"    => #2d1818
    "Mono Slate"     => #2d3340
    =>                  #18304a

bgSection = switch schemeOpt
    "Amber Terminal" => #3d2e15
    "Crimson Pro"    => #3d1818
    "Mono Slate"     => #3d4451
    =>                  #1e3a5f

bgAccent = switch schemeOpt
    "Amber Terminal" => #ff9a00
    "Crimson Pro"    => #dc2626
    "Mono Slate"     => #cbd5e1
    =>                  #00bcd4

txtLabel   = #94a3b8
txtValue   = #f8fafc
txtAccent  = color.black
txtSection = bgAccent

bullColor = #10b981
bearColor = #ef4444
neutColor = #f59e0b


// =============================================================================
// SESSION DETECTION
// =============================================================================
ibSessStr  = ibLength == "30 min" ? "0930-1000" : "0930-1030"
ibSessTime = time(timeframe.period, ibSessStr, sessTZ)
inIBWindow = not na(ibSessTime)

rthSessTime = time(timeframe.period, sessRTH, sessTZ)
inRTH       = not na(rthSessTime)


// =============================================================================
// IB STATE
// =============================================================================
var float ibHigh     = na
var float ibLow      = na
var float ibVolume   = 0.0
var int   ibStartBar = na
var int   ibEndBar   = na
var int   ibHiBar    = na
var int   ibLoBar    = na
var bool  ibWasIn    = false
var bool  ibLocked   = false
var bool  ibhBroken  = false
var bool  iblBroken  = false
var bool  ibDayDone  = false

var line  lnH   = na
var line  lnL   = na
var line  lnM   = na
var line  lnEU1 = na
var line  lnED1 = na
var line  lnEU2 = na
var line  lnED2 = na
var box   bxF   = na
var label lblH  = na
var label lblL  = na
var label lblM  = na


// =============================================================================
// IB ENGINE
// =============================================================================
if inIBWindow
    if not ibWasIn
        ibHigh     := high
        ibLow      := low
        ibVolume   := nz(volume)
        ibStartBar := bar_index
        ibHiBar    := bar_index
        ibLoBar    := bar_index
        ibEndBar   := na
        ibWasIn    := true
        ibLocked   := false
        ibhBroken  := false
        iblBroken  := false
        ibDayDone  := false
        lnH   := na
        lnL   := na
        lnM   := na
        lnEU1 := na
        lnED1 := na
        lnEU2 := na
        lnED2 := na
        bxF   := na
        lblH  := na
        lblL  := na
        lblM  := na
    else
        if high > ibHigh
            ibHigh  := high
            ibHiBar := bar_index
        if low < ibLow
            ibLow   := low
            ibLoBar := bar_index
        ibVolume += nz(volume)

else if ibWasIn
    ibWasIn  := false
    ibLocked := true
    ibEndBar := bar_index
    midPx    = (ibHigh + ibLow) / 2.0
    rangePx  = ibHigh - ibLow
    rightX   = bar_index + ibExtBars

    if showFill
        bxF := box.new(ibStartBar, ibHigh, ibEndBar, ibLow, bgcolor=color.new(fillColor, fillTransp), border_color=color.new(color.black, 100))

    if showHigh
        lnH := line.new(ibHiBar, ibHigh, rightX, ibHigh, color=ibHColor, width=ibHWidth, style=getStyle(ibHStyle))

    if showLow
        lnL := line.new(ibLoBar, ibLow, rightX, ibLow, color=ibLColor, width=ibLWidth, style=getStyle(ibLStyle))

    if showMid
        midX1 = math.min(ibHiBar, ibLoBar)
        lnM := line.new(midX1, midPx, rightX, midPx, color=ibMColor, width=ibMWidth, style=getStyle(ibMStyle))

    if showExt1
        lnEU1 := line.new(ibEndBar, ibHigh + rangePx, rightX, ibHigh + rangePx, color=ibEColor, width=ibEWidth, style=getStyle(ibEStyle))
        lnED1 := line.new(ibEndBar, ibLow  - rangePx, rightX, ibLow  - rangePx, color=ibEColor, width=ibEWidth, style=getStyle(ibEStyle))

    if showExt2
        lnEU2 := line.new(ibEndBar, ibHigh + 2.0 * rangePx, rightX, ibHigh + 2.0 * rangePx, color=ibEColor, width=ibEWidth, style=getStyle(ibEStyle))
        lnED2 := line.new(ibEndBar, ibLow  - 2.0 * rangePx, rightX, ibLow  - 2.0 * rangePx, color=ibEColor, width=ibEWidth, style=getStyle(ibEStyle))

    // === MARKERS - letter tags / circles / plain ===
    if showDots
        if dotStyleOpt == "Letter Tag"
            if showHigh
                label.new(ibHiBar, ibHigh, "H", style=label.style_label_down, color=ibHColor, textcolor=color.black, size=getSize(dotSizeStr))
            if showLow
                label.new(ibLoBar, ibLow, "L", style=label.style_label_up, color=ibLColor, textcolor=color.black, size=getSize(dotSizeStr))
        else if dotStyleOpt == "Letter Circle"
            if showHigh
                label.new(ibHiBar, ibHigh, "H", style=label.style_circle, color=ibHColor, textcolor=color.black, size=getSize(dotSizeStr))
            if showLow
                label.new(ibLoBar, ibLow, "L", style=label.style_circle, color=ibLColor, textcolor=color.black, size=getSize(dotSizeStr))
        else
            if showHigh
                label.new(ibHiBar, ibHigh, "", style=label.style_circle, color=ibHColor, size=getSize(dotSizeStr))
            if showLow
                label.new(ibLoBar, ibLow, "", style=label.style_circle, color=ibLColor, size=getSize(dotSizeStr))

    // === RIGHT-EDGE PRICE TAGS - solid bg, black text ===
    if showLabels
        if showHigh
            lblH := label.new(rightX, ibHigh, " IBH  " + str.tostring(ibHigh, format.mintick) + " ", style=label.style_label_left, color=ibHColor, textcolor=color.black, size=getSize(labelSizeStr))
        if showLow
            lblL := label.new(rightX, ibLow, " IBL  " + str.tostring(ibLow, format.mintick) + " ", style=label.style_label_left, color=ibLColor, textcolor=color.black, size=getSize(labelSizeStr))
        if showMid
            lblM := label.new(rightX, midPx, " IBM  " + str.tostring(midPx, format.mintick) + " ", style=label.style_label_left, color=ibMColor, textcolor=color.black, size=getSize(labelSizeStr))


// =============================================================================
// BREAK TRACKING
// =============================================================================
if ibLocked and inRTH
    if high > ibHigh
        ibhBroken := true
    if low < ibLow
        iblBroken := true


// =============================================================================
// LIVE EXTEND / DAY-END FREEZE
// =============================================================================
if ibLocked and not ibDayDone
    rightX2 = inRTH ? (bar_index + ibExtBars) : bar_index
    if not na(lnH)
        line.set_x2(lnH, rightX2)
    if not na(lnL)
        line.set_x2(lnL, rightX2)
    if not na(lnM)
        line.set_x2(lnM, rightX2)
    if not na(lnEU1)
        line.set_x2(lnEU1, rightX2)
    if not na(lnED1)
        line.set_x2(lnED1, rightX2)
    if not na(lnEU2)
        line.set_x2(lnEU2, rightX2)
    if not na(lnED2)
        line.set_x2(lnED2, rightX2)
    if not na(lblH)
        label.set_x(lblH, rightX2)
    if not na(lblL)
        label.set_x(lblL, rightX2)
    if not na(lblM)
        label.set_x(lblM, rightX2)
    if not inRTH
        ibDayDone := true


// =============================================================================
// INFO TABLE - INDUSTRIAL TERMINAL STYLING
//
// Layout (16 rows):
//   0  HEADER: STS4x IB | 60 MIN          accent bg, black text
//   1  STATUS: STATUS   | LOCKED          state-colored value bg
//   2  SECTION: LEVELS                    section bg band
//   3-5  IBH / IBL / IBM                  main bg, line-colored values
//   6  SECTION: METRICS                   section bg band
//   7-9  RANGE PTS / RANGE TKS / VOLUME   main bg
//   10 SECTION: STATE                     section bg band
//   11 POSITION                           main bg, state-colored value
//   12 TO IBH                             main bg
//   13 TO IBL                             main bg
//   14 IBH BREAK                          main bg, value flips green if hit
//   15 IBL BREAK                          main bg, value flips red if hit
// =============================================================================
var table infoTable = na

if showTable and barstate.isfirst
    infoTable := table.new(getTPos(tablePosStr), 2, 16, frame_color=bgAccent, frame_width=2, border_color=bgBorder, border_width=1)

if showTable and barstate.islast
    table.clear(infoTable, 0, 0, 1, 15)
    sz = getSize(tableSizeStr)

    // Computed values
    midPx2   = (na(ibHigh) or na(ibLow)) ? na : (ibHigh + ibLow) / 2.0
    rangePx2 = (na(ibHigh) or na(ibLow)) ? na : ibHigh - ibLow
    rangeTk2 = na(rangePx2) ? na : rangePx2 / syminfo.mintick
    distH    = na(ibHigh) ? na : close - ibHigh
    distL    = na(ibLow)  ? na : close - ibLow

    // Status
    statusTxt    = (not inRTH) ? "OFF HOURS" : (ibLocked ? "LOCKED" : (inIBWindow ? "BUILDING" : "PENDING"))
    statusBg     = (not inRTH) ? bgMain : (ibLocked ? bullColor : (inIBWindow ? neutColor : bgSection))
    statusTxtCol = (not inRTH) ? txtLabel : color.black

    // Position vs IB
    posTxt = (na(ibHigh) or na(ibLow)) ? "-" : (close > ibHigh ? "ABOVE IBH" : (close < ibLow ? "BELOW IBL" : "INSIDE IB"))
    posCol = (na(ibHigh) or na(ibLow)) ? txtLabel : (close > ibHigh ? bullColor : (close < ibLow ? bearColor : neutColor))

    // === Row 0 - HEADER ===
    table.cell(infoTable, 0, 0, "STS4x IB", text_color=txtAccent, text_size=sz, text_halign=text.align_left, bgcolor=bgAccent)
    table.cell(infoTable, 1, 0, str.upper(ibLength), text_color=txtAccent, text_size=sz, text_halign=text.align_right, bgcolor=bgAccent)

    // === Row 1 - STATUS ===
    table.cell(infoTable, 0, 1, "STATUS", text_color=txtLabel, text_size=sz, text_halign=text.align_left, bgcolor=bgMain)
    table.cell(infoTable, 1, 1, statusTxt, text_color=statusTxtCol, text_size=sz, text_halign=text.align_right, bgcolor=statusBg)

    // === Row 2 - SECTION: LEVELS ===
    table.cell(infoTable, 0, 2, "LEVELS", text_color=txtSection, text_size=sz, text_halign=text.align_left, bgcolor=bgSection)
    table.cell(infoTable, 1, 2, "", bgcolor=bgSection)

    // === Row 3 - IBH ===
    table.cell(infoTable, 0, 3, "IBH", text_color=txtLabel, text_size=sz, text_halign=text.align_left, bgcolor=bgMain)
    table.cell(infoTable, 1, 3, na(ibHigh) ? "-" : str.tostring(ibHigh, format.mintick), text_color=ibHColor, text_size=sz, text_halign=text.align_right, bgcolor=bgMain)

    // === Row 4 - IBL ===
    table.cell(infoTable, 0, 4, "IBL", text_color=txtLabel, text_size=sz, text_halign=text.align_left, bgcolor=bgMain)
    table.cell(infoTable, 1, 4, na(ibLow) ? "-" : str.tostring(ibLow, format.mintick), text_color=ibLColor, text_size=sz, text_halign=text.align_right, bgcolor=bgMain)

    // === Row 5 - IBM ===
    table.cell(infoTable, 0, 5, "IBM", text_color=txtLabel, text_size=sz, text_halign=text.align_left, bgcolor=bgMain)
    table.cell(infoTable, 1, 5, na(midPx2) ? "-" : str.tostring(midPx2, format.mintick), text_color=ibMColor, text_size=sz, text_halign=text.align_right, bgcolor=bgMain)

    // === Row 6 - SECTION: METRICS ===
    table.cell(infoTable, 0, 6, "METRICS", text_color=txtSection, text_size=sz, text_halign=text.align_left, bgcolor=bgSection)
    table.cell(infoTable, 1, 6, "", bgcolor=bgSection)

    // === Row 7 - RANGE PTS ===
    table.cell(infoTable, 0, 7, "RANGE PTS", text_color=txtLabel, text_size=sz, text_halign=text.align_left, bgcolor=bgMain)
    table.cell(infoTable, 1, 7, na(rangePx2) ? "-" : str.tostring(rangePx2, "#.##"), text_color=txtValue, text_size=sz, text_halign=text.align_right, bgcolor=bgMain)

    // === Row 8 - RANGE TICKS ===
    table.cell(infoTable, 0, 8, "RANGE TKS", text_color=txtLabel, text_size=sz, text_halign=text.align_left, bgcolor=bgMain)
    table.cell(infoTable, 1, 8, na(rangeTk2) ? "-" : str.tostring(rangeTk2, "#"), text_color=txtValue, text_size=sz, text_halign=text.align_right, bgcolor=bgMain)

    // === Row 9 - VOLUME ===
    table.cell(infoTable, 0, 9, "VOLUME", text_color=txtLabel, text_size=sz, text_halign=text.align_left, bgcolor=bgMain)
    table.cell(infoTable, 1, 9, ibVolume == 0 ? "-" : fmtVol(ibVolume), text_color=txtValue, text_size=sz, text_halign=text.align_right, bgcolor=bgMain)

    // === Row 10 - SECTION: STATE ===
    table.cell(infoTable, 0, 10, "STATE", text_color=txtSection, text_size=sz, text_halign=text.align_left, bgcolor=bgSection)
    table.cell(infoTable, 1, 10, "", bgcolor=bgSection)

    // === Row 11 - POSITION ===
    table.cell(infoTable, 0, 11, "POSITION", text_color=txtLabel, text_size=sz, text_halign=text.align_left, bgcolor=bgMain)
    table.cell(infoTable, 1, 11, posTxt, text_color=posCol, text_size=sz, text_halign=text.align_right, bgcolor=bgMain)

    // === Row 12 - TO IBH ===
    table.cell(infoTable, 0, 12, "TO IBH", text_color=txtLabel, text_size=sz, text_halign=text.align_left, bgcolor=bgMain)
    table.cell(infoTable, 1, 12, na(distH) ? "-" : fmtSigned(distH), text_color=txtValue, text_size=sz, text_halign=text.align_right, bgcolor=bgMain)

    // === Row 13 - TO IBL ===
    table.cell(infoTable, 0, 13, "TO IBL", text_color=txtLabel, text_size=sz, text_halign=text.align_left, bgcolor=bgMain)
    table.cell(infoTable, 1, 13, na(distL) ? "-" : fmtSigned(distL), text_color=txtValue, text_size=sz, text_halign=text.align_right, bgcolor=bgMain)

    // === Row 14 - IBH BREAK ===
    table.cell(infoTable, 0, 14, "IBH BREAK", text_color=txtLabel, text_size=sz, text_halign=text.align_left, bgcolor=bgMain)
    table.cell(infoTable, 1, 14, ibhBroken ? "YES" : "no", text_color=ibhBroken ? bullColor : txtLabel, text_size=sz, text_halign=text.align_right, bgcolor=bgMain)

    // === Row 15 - IBL BREAK ===
    table.cell(infoTable, 0, 15, "IBL BREAK", text_color=txtLabel, text_size=sz, text_halign=text.align_left, bgcolor=bgMain)
    table.cell(infoTable, 1, 15, iblBroken ? "YES" : "no", text_color=iblBroken ? bearColor : txtLabel, text_size=sz, text_halign=text.align_right, bgcolor=bgMain)


// =============================================================================
// ALERTS
// =============================================================================
ibJustEnded = ((not inIBWindow) and inIBWindow[1] and not na(ibHigh))
alertcondition(ibJustEnded,                    title="STS4x IB Locked",  message="STS4x IB locked: range established")
alertcondition(ibhBroken and not ibhBroken[1], title="STS4x IBH Break",  message="STS4x IBH broken")
alertcondition(iblBroken and not iblBroken[1], title="STS4x IBL Break",  message="STS4x IBL broken")
````
