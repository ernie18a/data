# Initial Balance Suite [ChartSmith]

- url: https://www.tradingview.com/script/HJHS7DKx-Initial-Balance-Suite-ChartSmith/
- type: indicator
- pine_id: PUB;6d210d69f3b946dcad48c987f1c5f676
- version: 1.0

## Description

[b]Initial Balance Suite[/b] tracks the high, low, and midpoint established during a configurable opening window, then projects extension levels and archives prior sessions — giving you a complete picture of the day's structural framework from the first bar after the IB closes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]WHAT IS THE INITIAL BALANCE?[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The Initial Balance is the price range established during the opening period of a session — traditionally the first hour of RTH trading. The high and low formed during this window define the day's foundational structure. When price stays inside the IB, the market is balancing. When price breaks out of it, the market is entering price discovery. Extension levels above and below the IB project how far that discovery might reach.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]SESSION SETTINGS[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Session Start[/b] — Set the hour and minute at which the IB window begins. Defaults to 9:30, the RTH open.

[b]Timezone[/b] — Aligns the session start to the correct local time. Options: America/New_York · America/Chicago · Europe/London · Asia/Tokyo · UTC.

[b]IB Length[/b] — Controls how long the opening window runs before the IB is considered complete. Available options: 30s · 1m · 2m · 3m · 5m · 10m · 15m · 30m · 1hr · 2hr · 4hr. The IB high and low accumulate bar by bar throughout this window, locking in the final levels only when the window closes.

[i]Note: your chart timeframe must be shorter than or equal to the selected IB length for the levels to calculate correctly.[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]INITIAL BALANCE LEVELS[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]IB High (IBH)[/b] — The highest price reached during the IB window.
[b]IB Low (IBL)[/b] — The lowest price reached during the IB window.
[b]IB Mid (IBM)[/b] — The midpoint of the IB range: (IBH + IBL) / 2.
[b]Fill Area[/b] — Shades the region between IBH and IBL to visually define the balance zone.
[b]Extend Right[/b] — Extends all IB lines to the right edge of the chart until the next session begins.

Each level has independent color, width, and line style (Solid / Dashed / Dotted) controls.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]EXTENSION LEVELS[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Extension levels project above IBH and below IBL using multiples of the IB range. Each level can be toggled and colored independently.

[b]+/− 50%[/b] — IBH/IBL ± (0.5 × IB Range)
[b]+/− 100%[/b] — IBH/IBL ± (1.0 × IB Range)
[b]+/− 150%[/b] — IBH/IBL ± (1.5 × IB Range)
[b]+/− 200%[/b] — IBH/IBL ± (2.0 × IB Range)
[b]+/− 300%[/b] — IBH/IBL ± (3.0 × IB Range)

All extensions share a global width and style setting. Extensions are off by default — enable [i]Show Extensions[/i] to display them.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]PREVIOUS DAYS[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Completed sessions are automatically archived and displayed as prior-day reference levels. Each prior session is restyled with its own color, width, and line style so it stays visually distinct from the current session.

[b]Days to Show[/b] — Controls how many prior sessions are kept on the chart (1–10). Sessions beyond this count are deleted automatically.
[b]Fill Area[/b] — Optionally shades the prior session's IBH-to-IBL range. Off by default.
[b]Show Extensions[/b] — Optionally carries prior session extension lines forward. Off by default.

When a new session begins, the current IB is immediately reclassified as a prior-day level — no manual management required.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]LABELS[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Labels appear at the right edge of each line and display the level name alongside its current price, formatted to the instrument's minimum tick. Size options: Auto · Tiny · Small · Normal · Large · Huge.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]ALERTS[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Twelve alert conditions are built in, all gated so they only fire after the IB has fully formed:

- IBH Cross Up / IBL Cross Down
- IBH Touch / IBL Touch
- +50% Cross Up / −50% Cross Down
- +100% Cross Up / −100% Cross Down
- +200% Cross Up / −200% Cross Down
- +300% Cross Up / −300% Cross Down

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]USAGE NOTES[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- The IB locks in the moment the opening window closes — levels will not repaint after that point.
- Extensions default to off. Enable [i]Show Extensions[/i] first, then toggle individual levels.
- Previous session extensions are also off by default and are controlled separately from the current session under [i]Previous Days → Show Extensions[/i].
- To use with non-US sessions, adjust both the [i]Session Start[/i] time and the [i]Timezone[/i] to match your exchange.

## Source Code

````pine
//@version=5
indicator(
     title            = "Initial Balance Suite [ChartSmith]",
     shorttitle       = "CS · IB",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500
 )

// ══════════════════════════════════════════════════════════════════════════════
// §1 ─ INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// ─── Session ──────────────────────────────────────────────────────────────────
string GRP_SES = "Session"

int    i_rthHour  = input.int(
     defval  = 9,
     title   = "Session Start (HH",
     group   = GRP_SES,
     inline  = "rthstart",
     minval  = 0,
     maxval  = 23)
int    i_rthMin   = input.int(
     defval  = 30,
     title   = ": MM)",
     group   = GRP_SES,
     inline  = "rthstart",
     minval  = 0,
     maxval  = 59)
string i_timezone = input.string(
     defval  = "America/New_York",
     title   = "Timezone",
     group   = GRP_SES,
     options = ["America/New_York", "America/Chicago", "Europe/London", "Asia/Tokyo", "UTC"],
     tooltip = "Set to match the exchange timezone for the instrument you trade.")
string i_ibLength = input.string(
     defval  = "1hr",
     title   = "IB Length",
     group   = GRP_SES,
     options = ["30s", "1m", "2m", "3m", "5m", "10m", "15m", "30m", "1hr", "2hr", "4hr"],
     tooltip = "Duration of the initial balance period measured from the session start time.\n"
             + "Chart timeframe must be shorter than or equal to the selected IB length.")

// ─── Initial Balance ──────────────────────────────────────────────────────────
string GRP_IB = "Initial Balance"

bool   i_ibhShow  = input.bool(true,    "IB High",    group = GRP_IB, inline = "ibh")
color  i_ibhClr   = input.color(#F23645, "",           group = GRP_IB, inline = "ibh")
int    i_ibhWidth = input.int(2,  "",                  group = GRP_IB, inline = "ibh", minval = 1, maxval = 4)
string i_ibhStyle = input.string("Solid", "",          group = GRP_IB, inline = "ibh", options = ["Solid", "Dashed", "Dotted"])

bool   i_iblShow  = input.bool(true,    "IB Low",     group = GRP_IB, inline = "ibl")
color  i_iblClr   = input.color(#089981, "",           group = GRP_IB, inline = "ibl")
int    i_iblWidth = input.int(2,  "",                  group = GRP_IB, inline = "ibl", minval = 1, maxval = 4)
string i_iblStyle = input.string("Solid", "",          group = GRP_IB, inline = "ibl", options = ["Solid", "Dashed", "Dotted"])

bool   i_ibmShow  = input.bool(true,    "IB Mid",     group = GRP_IB, inline = "ibm")
color  i_ibmClr   = input.color(#787B86, "",           group = GRP_IB, inline = "ibm")
int    i_ibmWidth = input.int(1,  "",                  group = GRP_IB, inline = "ibm", minval = 1, maxval = 4)
string i_ibmStyle = input.string("Dashed", "",         group = GRP_IB, inline = "ibm", options = ["Solid", "Dashed", "Dotted"])

bool   i_ibFillShow = input.bool(true, "Fill Area",   group = GRP_IB, inline = "ibfill")
color  i_ibFillClr  = input.color(color.new(#2962FF, 88), "", group = GRP_IB, inline = "ibfill")
bool   i_ibExtRight = input.bool(true,  "Extend Right", group = GRP_IB,
     tooltip = "Extend all IB lines to the right until the next session begins.")

// ─── Extensions ───────────────────────────────────────────────────────────────
string GRP_EXT = "Extensions"

bool   i_extShow  = input.bool(false, "Show Extensions", group = GRP_EXT,
     tooltip = "Display extension levels above and below the initial balance range.\n"
             + "Extensions default to off. Enable individual levels below.")
int    i_extWidth = input.int(1,       "Width", group = GRP_EXT, inline = "extsty", minval = 1, maxval = 4)
string i_extStyle = input.string("Dashed", "Style", group = GRP_EXT, inline = "extsty",
     options = ["Solid", "Dashed", "Dotted"])

bool   i_ext50Show  = input.bool(true,  "50%",  group = GRP_EXT, inline = "e50")
color  i_ext50Clr   = input.color(#FF9800, "",   group = GRP_EXT, inline = "e50")
bool   i_ext100Show = input.bool(true,  "100%", group = GRP_EXT, inline = "e100")
color  i_ext100Clr  = input.color(#FF6D00, "",   group = GRP_EXT, inline = "e100")
bool   i_ext150Show = input.bool(true,  "150%", group = GRP_EXT, inline = "e150")
color  i_ext150Clr  = input.color(#F4511E, "",   group = GRP_EXT, inline = "e150")
bool   i_ext200Show = input.bool(true,  "200%", group = GRP_EXT, inline = "e200")
color  i_ext200Clr  = input.color(#E53935, "",   group = GRP_EXT, inline = "e200")
bool   i_ext300Show = input.bool(true,  "300%", group = GRP_EXT, inline = "e300")
color  i_ext300Clr  = input.color(#B71C1C, "",   group = GRP_EXT, inline = "e300")

// ─── Previous Days ────────────────────────────────────────────────────────────
string GRP_PD = "Previous Days"

bool   i_pdShow     = input.bool(true,  "Show Previous Days", group = GRP_PD,
     tooltip = "Display completed IB levels from prior sessions.")
int    i_pdCount    = input.int(1, "Days to Show",  group = GRP_PD, minval = 1, maxval = 10)
color  i_pdHighClr  = input.color(color.new(#F23645, 50), "High", group = GRP_PD, inline = "pdclr")
color  i_pdMidClr   = input.color(color.new(#787B86, 50), "Mid",  group = GRP_PD, inline = "pdclr")
color  i_pdLowClr   = input.color(color.new(#089981, 50), "Low",  group = GRP_PD, inline = "pdclr")
int    i_pdWidth    = input.int(1,        "Width", group = GRP_PD, inline = "pdsty", minval = 1, maxval = 4)
string i_pdStyle    = input.string("Dashed", "Style", group = GRP_PD, inline = "pdsty",
     options = ["Solid", "Dashed", "Dotted"])
bool   i_pdFillShow = input.bool(false, "Fill Area",  group = GRP_PD, inline = "pdfill")
color  i_pdFillClr  = input.color(color.new(#2962FF, 93), "", group = GRP_PD, inline = "pdfill")
bool   i_pdExtShow  = input.bool(false, "Show Extensions", group = GRP_PD)

// ─── Labels ───────────────────────────────────────────────────────────────────
string GRP_LBL = "Labels"

bool   i_lblShow = input.bool(true,    "Show Labels", group = GRP_LBL, inline = "lbl")
string i_lblSize = input.string("Small", "Size",      group = GRP_LBL, inline = "lbl",
     options = ["Auto", "Tiny", "Small", "Normal", "Large", "Huge"])


// ══════════════════════════════════════════════════════════════════════════════
// §2 ─ HELPERS
// ══════════════════════════════════════════════════════════════════════════════

f_ibLengthMs(string len) =>
    (len == "30s" ? 30000   : len == "1m"  ? 60000   : len == "2m"  ? 120000  :
     len == "3m"  ? 180000  : len == "5m"  ? 300000  : len == "10m" ? 600000  :
     len == "15m" ? 900000  : len == "30m" ? 1800000 : len == "1hr" ? 3600000 :
     len == "2hr" ? 7200000 : 14400000)

f_lineStyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_labelSize(string s) =>
    (s == "Tiny"  ? size.tiny  : s == "Small"  ? size.small  : s == "Normal" ? size.normal :
     s == "Large" ? size.large : s == "Huge"   ? size.huge   : size.auto)

// Per-extension-level accessors (idx 0–4 maps to 50%, 100%, 150%, 200%, 300%)
f_extMult(int idx) =>
    idx == 0 ? 0.5 : idx == 1 ? 1.0 : idx == 2 ? 1.5 : idx == 3 ? 2.0 : 3.0

f_extVisible(int idx) =>
    i_extShow and (idx == 0 ? i_ext50Show  : idx == 1 ? i_ext100Show :
     idx == 2 ? i_ext150Show : idx == 3 ? i_ext200Show : i_ext300Show)

f_extClr(int idx) =>
    (idx == 0 ? i_ext50Clr : idx == 1 ? i_ext100Clr : idx == 2 ? i_ext150Clr :
     idx == 3 ? i_ext200Clr : i_ext300Clr)

f_extPrefix(int idx) =>
    idx == 0 ? "50" : idx == 1 ? "100" : idx == 2 ? "150" : idx == 3 ? "200" : "300"

f_lblText(string name, float price) =>
    name + "  " + str.tostring(price, format.mintick)


// ══════════════════════════════════════════════════════════════════════════════
// §3 ─ SESSION & IB DETECTION
// ══════════════════════════════════════════════════════════════════════════════

int  rthHHMM      = i_rthHour * 100 + i_rthMin
int  ibLengthMs   = f_ibLengthMs(i_ibLength)

int  etNow        = hour(time, i_timezone) * 100 + minute(time, i_timezone)
int  etPrev       = hour(time[1], i_timezone) * 100 + minute(time[1], i_timezone)
bool isNewSession = (etNow >= rthHHMM and etPrev < rthHHMM) or barstate.isfirst


// ══════════════════════════════════════════════════════════════════════════════
// §4 ─ IB CALCULATION
// ══════════════════════════════════════════════════════════════════════════════

var float ibHigh      = na
var float ibLow       = na
var int   ibStartTime = na
var int   ibStartBar  = na
var bool  ibDone      = false

// Capture ibDone before any reset so the archive step in §5 sees the prior session's state
bool prevIbDone = ibDone
bool ibJustDone = false

if isNewSession
    ibHigh      := high
    ibLow       := low
    ibStartTime := time
    ibStartBar  := bar_index
    ibDone      := false
else if not ibDone
    if time < ibStartTime + ibLengthMs
        ibHigh := math.max(ibHigh, high)
        ibLow  := math.min(ibLow, low)
    else
        ibDone    := true
        ibJustDone := true

float ibMid   = na(ibHigh) ? na : (ibHigh + ibLow) / 2.0
float ibRange = na(ibHigh) ? na : ibHigh - ibLow


// ══════════════════════════════════════════════════════════════════════════════
// §5 ─ LINE & LABEL MANAGEMENT
// ══════════════════════════════════════════════════════════════════════════════

// ─── Current-session line/label handles ──────────────────────────────────────
// IBH and IBL are always created (transparent when hidden) so linefill can reference them.
// IBM and extensions are created only when visible.
var line     curHigh    = na
var line     curLow     = na
var line     curMid     = na
var linefill curFill    = na

// slots 0–4: above extensions (50%–300%), slots 5–9: below extensions (50%–300%)
var line[]  curExt    = array.new<line>(10, na)
// slots 0=IBH, 1=IBM, 2=IBL, 3–7=above ext labels, 8–12=below ext labels
var label[] curLbls   = array.new<label>(13, na)

// ─── History — one row per completed session (matrix cols = line/label slots) ─
var line[]     histHighLines = array.new<line>()
var line[]     histLowLines  = array.new<line>()
var line[]     histMidLines  = array.new<line>()
var linefill[] histFills     = array.new<linefill>()
// matrix<line>: rows = sessions (newest last), cols = 10 ext slots
var matrix<line>  histExtMtx = matrix.new<line>(0, 10, na)
// matrix<label>: rows = sessions, cols = 13 label slots
var matrix<label> histLblMtx = matrix.new<label>(0, 13, na)

// ─── Helper: build one horizontal line ───────────────────────────────────────
f_hline(int x1, float y, int x2, color clr, int wid, string sty) =>
    line.new(x1 = x1, y1 = y, x2 = x2, y2 = y,
     color = clr, width = wid, style = f_lineStyle(sty))

// ─── Helper: build a right-anchored label for a given line ───────────────────
f_lbl(line l, string txt, color clr) =>
    label.new(
     x         = line.get_x2(l),
     y         = line.get_y1(l),
     text      = txt,
     color     = color.new(color.black, 100),
     textcolor = clr,
     style     = label.style_label_left,
     size      = f_labelSize(i_lblSize))

// ─── Create IB lines when the initial balance period completes ────────────────
if ibJustDone
    // Use transparent color when the level's show toggle is off so the line
    // object still exists (needed for linefill) but remains invisible.
    ibhLineClr = i_ibhShow ? i_ibhClr : color.new(color.black, 100)
    iblLineClr = i_iblShow ? i_iblClr : color.new(color.black, 100)
    ibmLineClr = i_ibmShow ? i_ibmClr : color.new(color.black, 100)

    curHigh := f_hline(ibStartBar, ibHigh, bar_index, ibhLineClr, i_ibhWidth, i_ibhStyle)
    curLow  := f_hline(ibStartBar, ibLow,  bar_index, iblLineClr, i_iblWidth, i_iblStyle)
    curMid  := f_hline(ibStartBar, ibMid,  bar_index, ibmLineClr, i_ibmWidth, i_ibmStyle)

    curFill := i_ibFillShow ? linefill.new(curHigh, curLow, i_ibFillClr) : na

    // Extension lines
    for i = 0 to 4
        mult       = f_extMult(i)
        visible    = f_extVisible(i)
        clr        = f_extClr(i)
        aboveLvl   = ibHigh + mult * ibRange
        belowLvl   = ibLow  - mult * ibRange
        lAbove     = visible ? f_hline(ibStartBar, aboveLvl, bar_index, clr, i_extWidth, i_extStyle) : na
        lBelow     = visible ? f_hline(ibStartBar, belowLvl, bar_index, clr, i_extWidth, i_extStyle) : na
        array.set(curExt, i,     lAbove)
        array.set(curExt, i + 5, lBelow)

    // Labels
    if i_lblShow
        array.set(curLbls, 0, i_ibhShow ? f_lbl(curHigh, f_lblText("IBH",  ibHigh), i_ibhClr) : na)
        array.set(curLbls, 1, i_ibmShow ? f_lbl(curMid,  f_lblText("IBM",  ibMid),  i_ibmClr) : na)
        array.set(curLbls, 2, i_iblShow ? f_lbl(curLow,  f_lblText("IBL",  ibLow),  i_iblClr) : na)
        for i = 0 to 4
            lAbove = array.get(curExt, i)
            lBelow = array.get(curExt, i + 5)
            pctStr = f_extPrefix(i) + "%"
            clr    = f_extClr(i)
            if not na(lAbove)
                aboveLvl = ibHigh + f_extMult(i) * ibRange
                array.set(curLbls, i + 3, f_lbl(lAbove, f_lblText("+" + pctStr, aboveLvl), clr))
            if not na(lBelow)
                belowLvl = ibLow - f_extMult(i) * ibRange
                array.set(curLbls, i + 8, f_lbl(lBelow, f_lblText("−" + pctStr, belowLvl), clr))

// ─── Extend current session lines to follow the right edge ───────────────────
if ibDone and i_ibExtRight and not isNewSession and not na(curHigh)
    line.set_x2(curHigh, bar_index)
    line.set_x2(curLow,  bar_index)
    line.set_x2(curMid,  bar_index)
    for i = 0 to 9
        l = array.get(curExt, i)
        if not na(l)
            line.set_x2(l, bar_index)
    if i_lblShow
        for i = 0 to 12
            lb = array.get(curLbls, i)
            if not na(lb)
                label.set_x(lb, bar_index)

// ─── Archive previous session and reset current handles on new session ────────
if isNewSession and not barstate.isfirst and prevIbDone
    // Push current session's objects into history
    array.push(histHighLines, curHigh)
    array.push(histLowLines,  curLow)
    array.push(histMidLines,  curMid)
    array.push(histFills,     curFill)

    newExtRow = array.new<line>(10, na)
    newLblRow = array.new<label>(13, na)
    for i = 0 to 9
        array.set(newExtRow, i, array.get(curExt, i))
    for i = 0 to 12
        array.set(newLblRow, i, array.get(curLbls, i))
    matrix.add_row(histExtMtx, matrix.rows(histExtMtx), newExtRow)
    matrix.add_row(histLblMtx, matrix.rows(histLblMtx), newLblRow)

    // Restyle to previous-day appearance or delete if disabled
    pdSty = f_lineStyle(i_pdStyle)
    int   sessIdx = array.size(histHighLines) - 1

    if i_pdShow
        line.set_color(array.get(histHighLines, sessIdx), i_pdHighClr)
        line.set_color(array.get(histLowLines,  sessIdx), i_pdLowClr)
        line.set_color(array.get(histMidLines,  sessIdx), i_pdMidClr)
        line.set_width(array.get(histHighLines, sessIdx), i_pdWidth)
        line.set_width(array.get(histLowLines,  sessIdx), i_pdWidth)
        line.set_width(array.get(histMidLines,  sessIdx), i_pdWidth)
        line.set_style(array.get(histHighLines, sessIdx), pdSty)
        line.set_style(array.get(histLowLines,  sessIdx), pdSty)
        line.set_style(array.get(histMidLines,  sessIdx), pdSty)

        // Previous-day fill
        oldFill = array.get(histFills, sessIdx)
        if not na(oldFill)
            if i_pdFillShow
                linefill.set_color(oldFill, i_pdFillClr)
            else
                linefill.delete(oldFill)
                array.set(histFills, sessIdx, na)

        // Previous-day extension lines
        for i = 0 to 9
            l = matrix.get(histExtMtx, sessIdx, i)
            if not na(l)
                if i_pdExtShow
                    line.set_width(l, i_pdWidth)
                    line.set_style(l, pdSty)
                else
                    line.delete(l)
                    matrix.set(histExtMtx, sessIdx, i, na)

        // Previous-day labels
        for i = 0 to 12
            lb = matrix.get(histLblMtx, sessIdx, i)
            if not na(lb)
                if i_lblShow
                    lbClr = i == 0 ? i_pdHighClr : i == 1 ? i_pdMidClr : i_pdLowClr
                    label.set_textcolor(lb, lbClr)
                else
                    label.delete(lb)
                    matrix.set(histLblMtx, sessIdx, i, na)
    else
        // Previous days disabled — delete everything
        line.delete(array.get(histHighLines, sessIdx))
        line.delete(array.get(histLowLines,  sessIdx))
        line.delete(array.get(histMidLines,  sessIdx))
        oldFill = array.get(histFills, sessIdx)
        if not na(oldFill)
            linefill.delete(oldFill)
        for i = 0 to 9
            l = matrix.get(histExtMtx, sessIdx, i)
            if not na(l)
                line.delete(l)
        for i = 0 to 12
            lb = matrix.get(histLblMtx, sessIdx, i)
            if not na(lb)
                label.delete(lb)

    // Trim history beyond i_pdCount
    while array.size(histHighLines) > i_pdCount
        line.delete(array.shift(histHighLines))
        line.delete(array.shift(histLowLines))
        line.delete(array.shift(histMidLines))
        oldFill = array.shift(histFills)
        if not na(oldFill)
            linefill.delete(oldFill)
        for j = 0 to 9
            l = matrix.get(histExtMtx, 0, j)
            if not na(l)
                line.delete(l)
        matrix.remove_row(histExtMtx, 0)
        for j = 0 to 12
            lb = matrix.get(histLblMtx, 0, j)
            if not na(lb)
                label.delete(lb)
        matrix.remove_row(histLblMtx, 0)

// Reset current handles so they don't carry over into the new session
if isNewSession
    curHigh := na
    curLow  := na
    curMid  := na
    curFill := na
    array.fill(curExt,  na)
    array.fill(curLbls, na)


// ══════════════════════════════════════════════════════════════════════════════
// §6 ─ ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(ibDone and ta.crossover(close, ibHigh),
     title   = "IBH Cross Up",
     message = "Price crossed above Initial Balance High")
alertcondition(ibDone and ta.crossunder(close, ibLow),
     title   = "IBL Cross Down",
     message = "Price crossed below Initial Balance Low")
alertcondition(ibDone and ta.cross(close, ibHigh),
     title   = "IBH Touch",
     message = "Price touched Initial Balance High")
alertcondition(ibDone and ta.cross(close, ibLow),
     title   = "IBL Touch",
     message = "Price touched Initial Balance Low")
alertcondition(ibDone and ta.crossover(close, ibHigh + 0.5 * ibRange),
     title   = "IB +50% Cross Up",
     message = "Price crossed above IB +50% extension")
alertcondition(ibDone and ta.crossunder(close, ibLow - 0.5 * ibRange),
     title   = "IB -50% Cross Down",
     message = "Price crossed below IB -50% extension")
alertcondition(ibDone and ta.crossover(close, ibHigh + ibRange),
     title   = "IB +100% Cross Up",
     message = "Price crossed above IB +100% extension")
alertcondition(ibDone and ta.crossunder(close, ibLow - ibRange),
     title   = "IB -100% Cross Down",
     message = "Price crossed below IB -100% extension")
alertcondition(ibDone and ta.crossover(close, ibHigh + 2.0 * ibRange),
     title   = "IB +200% Cross Up",
     message = "Price crossed above IB +200% extension")
alertcondition(ibDone and ta.crossunder(close, ibLow - 2.0 * ibRange),
     title   = "IB -200% Cross Down",
     message = "Price crossed below IB -200% extension")
alertcondition(ibDone and ta.crossover(close, ibHigh + 3.0 * ibRange),
     title   = "IB +300% Cross Up",
     message = "Price crossed above IB +300% extension")
alertcondition(ibDone and ta.crossunder(close, ibLow - 3.0 * ibRange),
     title   = "IB -300% Cross Down",
     message = "Price crossed below IB -300% extension")
````
