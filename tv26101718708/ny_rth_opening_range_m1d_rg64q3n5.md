# NY RTH Opening Range [M1D]

- url: https://www.tradingview.com/script/Rg64q3N5-NY-RTH-Opening-Range-M1D/
- type: indicator
- pine_id: PUB;f9864fc2b83f4df2b4b47eb8335a57e4
- version: 2.0

## Description

NY RTH Opening Range [M1D]

This indicator marks the New York Regular Trading Hours Opening Range (09:30–10:00 New York time, DST-adjusted automatically) on any chart timeframe at or below 30 minutes.

How it works: the script accumulates the highest high and lowest low across every bar that falls inside the 09:30–10:00 New York session window, rather than assuming a single candle equals the range — this makes it accurate whether you're viewing a 1-minute or 30-minute chart. 

Once the window closes, the range locks and three levels are drawn: the range high, the range low, and the midpoint (equilibrium). The current day's range plus a user-defined number of prior days are displayed for reference, with prior days dimmed automatically.

After the range locks, the script monitors price for a confirmed bar close beyond the range high or low and marks a single directional signal per side per day. If price later closes back inside the range following a break, a separate marker flags that the break may have failed, prompting reassessment rather than continued directional bias.

A status panel in the corner of the chart shows whether the range is still forming or has locked, the current high/low values, and the live directional bias.
Settings: session window and timezone, line extension length, number of prior days shown, line/marker colours, and panel visibility are all user-adjustable via the indicator's settings menu.


Note: This tool identifies a structural reference level and does not constitute financial advice or a standalone trading signal. As with any single concept, it is intended to be used as one component of a broader trading framework and should be combined with proper risk management.

## Source Code

````pine
//@version=6
// ============================================================================
// NY RTH Opening Range [M1D]
// Defaults: Window 0930-1000 "America/New_York" (DST auto-handled by tz string)
//           High and low solid black | EQ grey dotted | breaks purple / magenta
// Works on M1 / M5 / M15 / M30 — range is ACCUMULATED across the window,
// never assumes one bar = the range. Shows current + N prior days' ORBs.
// No request.security() used — fully on-chart, zero lookahead risk.
// ============================================================================
indicator("NY RTH Opening Range [M1D]", overlay = true, max_lines_count = 100, max_labels_count = 100, max_boxes_count = 50)

// ============================== CONSTANTS ===================================
color INK      = #000000
color EQ_GREY  = #787B86
color C_BULL   = #7246CE
color C_BEAR   = #DB1D9C

// ============================== INPUTS ======================================
string sessionInput   = input.session("0930-1000", "ORB Window",            group = "Session")
string tzInput        = input.string("America/New_York", "Timezone",        group = "Session")

int    endHourInput   = input.int(16, "Lines End (NY)", minval = 0, maxval = 23, group = "Display", inline = "end")
int    endMinInput    = input.int(55, ":", minval = 0, maxval = 59, group = "Display", inline = "end", tooltip = "The New York time the range lines and targets stop, the same day.")
bool   showEqInput    = input.bool(true,  "Show Equilibrium (EQ)",          group = "Display")
bool   showPriorInput = input.bool(true,  "Show Prior Days",                group = "Display")
int    priorDaysInput = input.int(2, "Prior Days to Show", minval = 0, maxval = 10, group = "Display")
bool   dimPriorInput  = input.bool(true,  "Dim Prior Days",                 group = "Display")
int    priorTranspIn  = input.int(55, "Prior Day Transparency", minval = 0, maxval = 100, group = "Display")
int    lineWidthInput = input.int(1, "Line Width", minval = 1, maxval = 4,  group = "Display")
bool   showLabelInput = input.bool(true,  "Show Labels",                    group = "Display")
string lblSizeIn      = input.string("small", "Text size", options = ["tiny", "small", "normal", "large"], group = "Display", tooltip = "Sets the labels and the table together.")

bool   showBiasInput  = input.bool(true,  "Show Bias Markers",              group = "Markers")
bool   showFailInput  = input.bool(true,  "Show Failure Markers",           group = "Markers")

bool   showPdInput    = input.bool(false, "Premium / Discount Fill",       group = "Display", tooltip = "Shades the top half of the range as premium and the bottom half as discount.")
bool   showTgtInput   = input.bool(true,  "Show Targets",                   group = "Targets", tooltip = "After the first close through the range, targets step out in that direction. The next one appears when price reaches the last.")
float  tgtStepInput   = input.float(0.5, "Target Step (ranges)", minval = 0.1, step = 0.25, group = "Targets", tooltip = "Distance between targets, in opening ranges. 0.5 = half the range, 1 = the full range.")
int    tgtMaxInput    = input.int(10, "Max Targets per Day", minval = 1, maxval = 20, group = "Targets")
int    tgtLenInput    = input.int(60, "Target Line Length (minutes)", minval = 5, group = "Targets")

bool   showTableInput = input.bool(true,  "Show Status Table",              group = "Table")
string tablePosInput  = input.string("Bottom Center", "Table Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left", "Bottom Center"], group = "Table")

color  topColInput    = input.color(INK,     "ORB Top",                 group = "Colours")
color  botColInput    = input.color(INK,     "ORB Bottom",              group = "Colours")
color  eqColInput     = input.color(EQ_GREY, "EQ",                      group = "Colours")
color  bullMarkCol    = input.color(C_BULL,  "Bullish Break",           group = "Colours")
color  bearMarkCol    = input.color(C_BEAR,  "Bearish Break",           group = "Colours")
color  failMarkCol    = input.color(INK,     "Failure ✕",               group = "Colours")
color  premColInput   = input.color(color.new(#F23645, 85), "Premium",   group = "Colours")
color  discColInput   = input.color(color.new(#2962FF, 85), "Discount",  group = "Colours")
color  tgtUpCol       = input.color(C_BULL,  "Bullish Targets",         group = "Colours")
color  tgtDnCol       = input.color(C_BEAR,  "Bearish Targets",         group = "Colours")

//@function Resolves a size name to the size constant.
//@param s (string) "tiny", "small", "normal" or "large".
//@returns (string) The size constant.
f_size(string s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        =>         size.normal

string LBL_SZ = f_size(lblSizeIn)
int    BAR_MS = timeframe.in_seconds() * 1000

// ============================== TYPES =======================================
//@variable Bundles the six drawing objects of a single day's ORB for clean reuse/deletion.
type OrbBox
    line  topLn = na
    line  botLn = na
    line  eqLn  = na
    label topLb = na
    label botLb = na
    label eqLb  = na
    array<line>  tgtLn
    array<label> tgtLb
    int          tgtDir = 0
    box          premBx = na
    box          discBx = na

// ============================== STATE =======================================
var float curHigh      = na
var float curLow       = na
var float curEq        = na
var int   curStartTime = na
var bool  rangeLocked  = false
var bool  brokeUp      = false
var bool  brokeDown    = false
var bool  failedUp     = false
var bool  failedDown   = false
var int   curRightT    = na
var int   tgtDir       = 0
var int   tgtN         = 0
var float tgtNext      = na
var array<OrbBox> drawnOrbs = array.new<OrbBox>(0)

// ============================== CALCS =======================================
int   tInWindow    = time(timeframe.period, sessionInput, tzInput)
bool  inWindow     = not na(tInWindow)
bool  windowStart  = inWindow and not inWindow[1]
bool  windowEnd     = not inWindow and inWindow[1]
int   priorDays    = showPriorInput ? priorDaysInput : 0

//@function A level's name at the left end of its line, on its price, clear of where price is heading.
//@param x (int) Bar time of the line's left end.
//@param y (float) The level.
//@param txt (string) The name.
//@param col (color) Text colour.
//@returns (label) The label.
f_tagL(int x, float y, string txt, color col) =>
    label.new(x, y, txt, xloc = xloc.bar_time, style = label.style_label_right, color = color.new(#FFFFFF, 100), textcolor = col, size = LBL_SZ, textalign = text.align_right, text_font_family = font.family_monospace)

// == RANGE ACCUMULATION ==
if windowStart
    curHigh      := high
    curLow       := low
    curStartTime := time
    rangeLocked  := false
    brokeUp      := false
    brokeDown    := false
    failedUp     := false
    failedDown   := false
    tgtDir       := 0
    tgtN         := 0
    tgtNext      := na
else if inWindow
    curHigh := math.max(curHigh, high)
    curLow  := math.min(curLow, low)

// == LOCK & DRAW ==
if windowEnd and not rangeLocked and not na(curHigh)
    curEq := (curHigh + curLow) / 2.0
    int   endT    = time
    int   rightT  = math.max(endT, timestamp(tzInput, year(endT, tzInput), month(endT, tzInput), dayofmonth(endT, tzInput), endHourInput, endMinInput))
    curRightT := rightT

    if dimPriorInput and drawnOrbs.size() > 0
        OrbBox prev = drawnOrbs.last()
        line.set_color(prev.topLn, color.new(topColInput, priorTranspIn))
        line.set_color(prev.botLn, color.new(botColInput, priorTranspIn))
        if not na(prev.eqLn)
            line.set_color(prev.eqLn, color.new(eqColInput, priorTranspIn))
        if not na(prev.topLb)
            label.set_textcolor(prev.topLb, color.new(topColInput, priorTranspIn))
            label.set_textcolor(prev.botLb, color.new(botColInput, priorTranspIn))
        if not na(prev.eqLb)
            label.set_textcolor(prev.eqLb, color.new(eqColInput, priorTranspIn))
        for l in prev.tgtLn
            line.set_color(l, color.new(prev.tgtDir == 1 ? tgtUpCol : tgtDnCol, priorTranspIn))
        for b in prev.tgtLb
            label.set_textcolor(b, color.new(INK, priorTranspIn))
        if not na(prev.premBx)
            box.set_bgcolor(prev.premBx, color.new(premColInput, math.min(100, 100 - (100 - color.t(premColInput)) * (100 - priorTranspIn) / 100)))
            box.set_bgcolor(prev.discBx, color.new(discColInput, math.min(100, 100 - (100 - color.t(discColInput)) * (100 - priorTranspIn) / 100)))

    OrbBox ob = OrbBox.new(tgtLn = array.new<line>(), tgtLb = array.new<label>())
    ob.topLn := line.new(curStartTime, curHigh, rightT, curHigh, xloc = xloc.bar_time, color = topColInput, width = lineWidthInput, style = line.style_solid)
    ob.botLn := line.new(curStartTime, curLow,  rightT, curLow,  xloc = xloc.bar_time, color = botColInput, width = lineWidthInput, style = line.style_solid)
    if showPdInput
        ob.premBx := box.new(curStartTime, curHigh, rightT, curEq, xloc = xloc.bar_time, border_width = 0, border_color = color.new(#FFFFFF, 100), bgcolor = premColInput)
        ob.discBx := box.new(curStartTime, curEq, rightT, curLow, xloc = xloc.bar_time, border_width = 0, border_color = color.new(#FFFFFF, 100), bgcolor = discColInput)
    if showEqInput
        ob.eqLn := line.new(curStartTime, curEq, rightT, curEq, xloc = xloc.bar_time, color = eqColInput, width = 1, style = line.style_dotted)
    if showLabelInput
        ob.topLb := f_tagL(curStartTime, curHigh, "ORB H", topColInput)
        ob.botLb := f_tagL(curStartTime, curLow, "ORB L", botColInput)
        if showEqInput
            ob.eqLb := f_tagL(curStartTime, curEq, "EQ", eqColInput)

    drawnOrbs.push(ob)

    if drawnOrbs.size() > priorDays + 1
        OrbBox old = drawnOrbs.shift()
        line.delete(old.topLn)
        line.delete(old.botLn)
        if not na(old.eqLn)
            line.delete(old.eqLn)
        if not na(old.topLb)
            label.delete(old.topLb)
            label.delete(old.botLb)
        if not na(old.eqLb)
            label.delete(old.eqLb)
        for l in old.tgtLn
            line.delete(l)
        for b in old.tgtLb
            label.delete(b)
        box.delete(old.premBx)
        box.delete(old.discBx)

    rangeLocked := true

// == BIAS & FAILURE DETECTION ==
bool confirmed = barstate.isconfirmed
bool canSignal = confirmed and rangeLocked and not brokeUp and not brokeDown
bool bullBreak = canSignal and close > curHigh
bool bearBreak = canSignal and close < curLow
bool failUp    = confirmed and brokeUp   and not failedUp   and close < curHigh
bool failDown  = confirmed and brokeDown and not failedDown and close > curLow

if bullBreak
    brokeUp := true
if bearBreak
    brokeDown := true
if failUp
    failedUp := true
if failDown
    failedDown := true

// == TARGETS ==
//@function Draws target n at price y, starting on this bar.
//@param ob (OrbBox) The day's drawings.
//@param y (float) The target price.
//@param n (int) Target number.
//@param col (color) Line colour.
//@returns (bool) Always true.
f_target(OrbBox ob, float y, int n, color col) =>
    int x2 = math.max(time + tgtLenInput * 60 * 1000, time + BAR_MS)
    ob.tgtLn.push(line.new(time, y, x2, y, xloc = xloc.bar_time, color = col, width = 1, style = line.style_solid))
    if showLabelInput
        ob.tgtLb.push(label.new(time, y, "T" + str.tostring(n), xloc = xloc.bar_time, style = label.style_label_right, color = color.new(#FFFFFF, 100), textcolor = INK, size = LBL_SZ, textalign = text.align_right, text_font_family = font.family_monospace))
    true

if showTgtInput and drawnOrbs.size() > 0 and rangeLocked
    OrbBox cur  = drawnOrbs.last()
    float  step = (curHigh - curLow) * tgtStepInput
    color  tCol = tgtDir == 1 ? tgtUpCol : tgtDnCol
    if bullBreak or bearBreak
        tgtDir  := bullBreak ? 1 : -1
        cur.tgtDir := tgtDir
        tgtN    := 1
        tgtNext := bullBreak ? curHigh + step : curLow - step
        f_target(cur, tgtNext, tgtN, bullBreak ? tgtUpCol : tgtDnCol)
        tCol := bullBreak ? tgtUpCol : tgtDnCol
    if tgtDir != 0 and confirmed and step > 0 and time <= curRightT
        while tgtN < tgtMaxInput and (tgtDir == 1 ? high >= tgtNext : low <= tgtNext)
            tgtN    += 1
            tgtNext += tgtDir * step
            f_target(cur, tgtNext, tgtN, tCol)

// == KEEP THE DAY'S LINES AHEAD OF PRICE ==
//@function Pushes a line's right end to at least one candle past the live candle.
//@param l (line) The line.
//@param x (int) The time it must reach.
//@returns (bool) Always true.
f_ahead(line l, int x) =>
    if not na(l) and line.get_x2(l) < x
        line.set_x2(l, x)
    true

if drawnOrbs.size() > 0 and rangeLocked and time <= curRightT
    OrbBox cur = drawnOrbs.last()
    int    x   = time + BAR_MS
    f_ahead(cur.topLn, x)
    f_ahead(cur.botLn, x)
    f_ahead(cur.eqLn, x)
    for l in cur.tgtLn
        f_ahead(l, x)
    if not na(cur.premBx) and box.get_right(cur.premBx) < x
        box.set_right(cur.premBx, x)
        box.set_right(cur.discBx, x)

// ============================== VISUALS =====================================
plotshape(showBiasInput and bullBreak, "Bullish Break", shape.triangleup,   location.belowbar, bullMarkCol, size = size.tiny)
plotshape(showBiasInput and bearBreak, "Bearish Break", shape.triangledown, location.abovebar, bearMarkCol, size = size.tiny)
plotchar(showFailInput and failUp,   "ORB Fail (bull)", "✕", location.abovebar, failMarkCol, size = size.tiny)
plotchar(showFailInput and failDown, "ORB Fail (bear)", "✕", location.belowbar, failMarkCol, size = size.tiny)

// == TIMEFRAME GUARD ==
var label tfWarn = na
if barstate.islast
    if timeframe.in_seconds() > 1800
        if na(tfWarn)
            tfWarn := label.new(bar_index, high, "ORB: use M30 or lower", style = label.style_label_down, color = color.new(#FFFFFF, 100), textcolor = INK, size = LBL_SZ, text_font_family = font.family_monospace)
        else
            label.set_xy(tfWarn, bar_index, high)
    else if not na(tfWarn)
        label.delete(tfWarn)
        tfWarn := na

// == STATUS TABLE ==
//@function Resolves the table.position.* constant from the string input.
//@param posStr (string) Human-readable position label.
//@returns (string) The position constant for table.new().
getTablePos(string posStr) =>
    string result = switch posStr
        "Top Right"    => position.top_right
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Bottom Center" => position.bottom_center
        =>                position.bottom_left
    result

//@function Writes one name and value row of the table.
//@param t (table) The table.
//@param r (int) Row.
//@param name (string) Name, left.
//@param val (string) Value, right.
//@returns (bool) Always true.
f_row(table t, int r, string name, string val) =>
    table.cell(t, 0, r, " " + name, text_color = INK, text_size = LBL_SZ, text_halign = text.align_left, text_font_family = font.family_monospace, text_formatting = text.format_italic)
    table.cell(t, 1, r, val + " ", text_color = INK, text_size = LBL_SZ, text_halign = text.align_right, text_font_family = font.family_monospace, text_formatting = text.format_bold)
    true

var table statusTable = na
if showTableInput and barstate.islast
    if na(statusTable)
        statusTable := table.new(getTablePos(tablePosInput), 2, 5, bgcolor = #FFFFFF, frame_color = INK, frame_width = 1, border_color = INK, border_width = 1)
        table.merge_cells(statusTable, 0, 0, 1, 0)
    table.cell(statusTable, 0, 0, " M1D · NY RTH Opening Range ", text_color = INK, text_size = LBL_SZ, text_halign = text.align_center, text_font_family = font.family_monospace, bgcolor = color.new(#cd82ff, 49))

    string biasTxt = switch
        brokeUp   => "Bullish"
        brokeDown => "Bearish"
        =>           "Neutral"
    f_row(statusTable, 1, "Bias", biasTxt)
    f_row(statusTable, 2, "Range", rangeLocked ? "Formed" : "Forming")
    f_row(statusTable, 3, "High", na(curHigh) ? "—" : str.tostring(curHigh, format.mintick))
    f_row(statusTable, 4, "Low", na(curLow) ? "—" : str.tostring(curLow, format.mintick))
else if not showTableInput and not na(statusTable)
    table.delete(statusTable)
    statusTable := na

// ============================== ALERTS ======================================
alertcondition(bullBreak, "ORB Bullish Break", "Price closed above NY ORB high on {{ticker}}")
alertcondition(bearBreak, "ORB Bearish Break", "Price closed below NY ORB low on {{ticker}}")
alertcondition(failUp or failDown, "ORB Failure", "NY ORB break failed — reassess on {{ticker}}")
````
