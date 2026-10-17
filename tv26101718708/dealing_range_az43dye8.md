# Dealing Range

- url: https://www.tradingview.com/script/az43dYe8-Dealing-Range/
- type: indicator
- pine_id: PUB;f7034de9026e40f5aafe57fd61435b11
- version: 3.0

## Description

Dealing Range (DR) — Session Range Tracker

Automatically maps the full CME session range from 6:00 PM to 4:15 PM New York time, tracking the highest high and lowest low as the session develops in real time. DR.High and DR.Low expand bar by bar and freeze at session close, giving you a clean visual boundary of the day's full price delivery range.
Within that range, the indicator plots the 25%, 50%, and 75% equilibrium levels. The 50% acts as the session's premium/discount divide — price trading above it is in premium, below it is in discount. The 25% and 75% levels mark the first standard reaction zones within each half of the range, useful for anticipating where price may stall, reverse, or accelerate through.
At the open of each new session, the completed range is preserved as the Previous Dealing Range (PDR.High, PDR.Low) with its own set of percentage levels. These static reference lines carry forward as key context for the incoming session — particularly the PDR 50%, which frequently acts as a draw on liquidity or a decision point during the early hours of the new session.
All visual elements are independently configurable. Current DR boundaries, current DR levels, previous DR lines, and labels for both sessions can each be toggled, recolored, resized, and restyled without affecting one another. 

Can set to only having one Range active at once, just used both to show both the ranges off, Works the same as the MTF DR just not using individual sessions for Higher time frame analysis.

Enjoy. :)

## Source Code

````pine
//@version=6
indicator("ICT Dealing Range", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

const color C_INK = #000000

// == ORIGIN GUARD ==
// A drawing anchored on a stored origin can sit thousands of chart bars back. Placing that x walks the
// `time` series to it, and Pine auto-sizes that buffer from what history happened to need, so a live bar
// that needs one more kills the whole script ("requested historical offset is beyond the historical
// buffer's limit"). Function form buffers `time` alone; anything older than ORIGIN_MAX clamps to the
// buffer's edge and draws short from the left instead of crashing.
const int ORIGIN_MAX = 4900
max_bars_back(time, 5000)
//@function Clamps a bar-time anchor to the oldest bar the drawing engine can still place.
//@param t (int) The stored origin time.
//@returns (int) t, or the time of the oldest reachable bar when t is older than that.
f_xClamp(int t) =>
    math.max(t, time[math.min(bar_index, ORIGIN_MAX)])


// ══════════════════════════════════════════════════════════════════
// ICT DEALING RANGE — Three-Session Edition
// ──────────────────────────────────────────────────────────────────
// Tracks the high/low of a user-defined NY-time window per session.
// On window close, levels are locked and drawn:
//   DR.H  87.5%  75%  62.5%  50%  37.5%  25%  12.5%  DR.L
// (the octant levels are opt-in, alongside the original quartiles;
//  sixteenth levels are a further opt-in, restricted to Prev Day only)
// Lines stop at a shared right edge and each name sits at the end of its line.
// Display Style: Lines (original) or Boxed Zone — one shaded box per
// session spanning DR.H to DR.L, for a cleaner whole-day read.
// ══════════════════════════════════════════════════════════════════


// ──────────────────────────────────────────────────────────────────
// USER-DEFINED TYPE
// ──────────────────────────────────────────────────────────────────

type DRSession
    string name
    int    startHour
    int    startMin
    int    endHour
    int    endMin
    color  lineColor
    float  drHigh       = na
    float  drLow        = na
    bool   locked       = false
    int    startTime    = na
    line   lineH        = na
    line   line9375     = na
    line   line875      = na
    line   line8125     = na
    line   line75       = na
    line   line6875     = na
    line   line625      = na
    line   line5625     = na
    line   line50       = na
    line   line4375     = na
    line   line375      = na
    line   line3125     = na
    line   line25       = na
    line   line1875     = na
    line   line125      = na
    line   line0625     = na
    line   lineL        = na
    label  lblH         = na
    label  lbl9375      = na
    label  lbl875       = na
    label  lbl8125      = na
    label  lbl75        = na
    label  lbl6875      = na
    label  lbl625       = na
    label  lbl5625      = na
    label  lbl50        = na
    label  lbl4375      = na
    label  lbl375       = na
    label  lbl3125      = na
    label  lbl25        = na
    label  lbl1875      = na
    label  lbl125       = na
    label  lbl0625      = na
    label  lblL         = na
    box    zoneBox      = na
    label  zoneLbl      = na
    line   prevH        = na
    line   prev9375     = na
    line   prev875      = na
    line   prev8125     = na
    line   prev75       = na
    line   prev6875     = na
    line   prev625      = na
    line   prev5625     = na
    line   prev50       = na
    line   prev4375     = na
    line   prev375      = na
    line   prev3125     = na
    line   prev25       = na
    line   prev1875     = na
    line   prev125      = na
    line   prev0625     = na
    line   prevL        = na
    box    prevZoneBox  = na


// ──────────────────────────────────────────────────────────────────
// INPUTS — ASIA SESSION
// ──────────────────────────────────────────────────────────────────

bool   i_showAsia      = input.bool(true,          "Show Asia Session",        group="Asia Session")
string i_asiaLabel     = input.string("Asia",      "Label",                    group="Asia Session")
int    i_asiaStartHour = input.int(20,             "Start Hour (NY)",          group="Asia Session", minval=0, maxval=23)
int    i_asiaStartMin  = input.int(0,              "Start Minute (NY)",        group="Asia Session", minval=0, maxval=59)
int    i_asiaEndHour   = input.int(22,             "End Hour (NY)",            group="Asia Session", minval=0, maxval=23)
int    i_asiaEndMin    = input.int(0,              "End Minute (NY)",          group="Asia Session", minval=0, maxval=59)
color  i_asiaColor     = input.color(C_INK,  "Line / Label Color",       group="Asia Session")


// ──────────────────────────────────────────────────────────────────
// INPUTS — LONDON SESSION
// ──────────────────────────────────────────────────────────────────

bool   i_showLondon      = input.bool(false,         "Show London Session",      group="London Session")
string i_londonLabel     = input.string("London",    "Label",                    group="London Session")
int    i_londonStartHour = input.int(3,              "Start Hour (NY)",          group="London Session", minval=0, maxval=23)
int    i_londonStartMin  = input.int(0,              "Start Minute (NY)",        group="London Session", minval=0, maxval=59)
int    i_londonEndHour   = input.int(5,              "End Hour (NY)",            group="London Session", minval=0, maxval=23)
int    i_londonEndMin    = input.int(0,              "End Minute (NY)",          group="London Session", minval=0, maxval=59)
color  i_londonColor     = input.color(C_INK,  "Line / Label Color",       group="London Session")


// ──────────────────────────────────────────────────────────────────
// INPUTS — NEW YORK SESSION
// ──────────────────────────────────────────────────────────────────

bool   i_showNY      = input.bool(false,         "Show NY Session",          group="NY Session")
string i_nyLabel     = input.string("NY",        "Label",                    group="NY Session")
int    i_nyStartHour = input.int(9,              "Start Hour (NY)",          group="NY Session", minval=0, maxval=23)
int    i_nyStartMin  = input.int(30,             "Start Minute (NY)",        group="NY Session", minval=0, maxval=59)
int    i_nyEndHour   = input.int(11,             "End Hour (NY)",            group="NY Session", minval=0, maxval=23)
int    i_nyEndMin    = input.int(30,             "End Minute (NY)",          group="NY Session", minval=0, maxval=59)
color  i_nyColor     = input.color(C_INK,  "Line / Label Color",       group="NY Session")


// ──────────────────────────────────────────────────────────────────
// INPUTS — PREV DAY SESSION
// ──────────────────────────────────────────────────────────────────

bool   i_showPrevDay      = input.bool(false,            "Show Prev Day Session",    group="Prev Day Session")
string i_prevDayLabel     = input.string("Prev Day",     "Label",                    group="Prev Day Session")
int    i_prevDayStartHour = input.int(18,                "Start Hour (NY)",          group="Prev Day Session", minval=0, maxval=23)
int    i_prevDayStartMin  = input.int(0,                 "Start Minute (NY)",        group="Prev Day Session", minval=0, maxval=59)
int    i_prevDayEndHour   = input.int(16,                "End Hour (NY)",            group="Prev Day Session", minval=0, maxval=23)
int    i_prevDayEndMin    = input.int(15,                "End Minute (NY)",          group="Prev Day Session", minval=0, maxval=59)
color  i_prevDayColor     = input.color(C_INK,     "Line / Label Color",       group="Prev Day Session")
bool   i_showSixteenths   = input.bool(false,             "Show Sixteenth Levels (Prev Day only)", group="Prev Day Session", tooltip="Adds the 6.25/18.75/31.25/43.75/56.25/68.75/81.25/93.75% levels on top of the octants. Deliberately restricted to the Prev Day range — a full day's range is wide enough for this much granularity to stay readable; the single sessions are not.")


// ──────────────────────────────────────────────────────────────────
// INPUTS — STYLE
// ──────────────────────────────────────────────────────────────────

int    i_lineWidth  = input.int(1,        "Line Width",              group="Style", minval=1, maxval=4)
string i_lineStyle  = input.string("solid", "Line Style",            group="Style", options=["solid", "dotted", "dashed"])
bool   i_showQ25    = input.bool(true,    "Show 25% Level",          group="Style")
bool   i_showQ75    = input.bool(true,    "Show 75% Level",          group="Style")
bool   i_showOctants = input.bool(false,  "Show Octant Levels (12.5/37.5/62.5/87.5%)", group="Style")
string i_lblSize    = input.string("small", "Label Size",           group="Style", options=["tiny", "small", "normal", "large"])
float  i_lblOffset  = input.float(0.0,    "DR.L Label Offset (x Range)", group="Style", minval=0.0, maxval=5.0, step=0.1, tooltip="Pushes ONLY the DR.L label below its line, as a fraction of the range. Set it to 0 to sit the label on the line like every other level.")
int    i_lblBarOffset = input.int(10,     "Right offset (bars)", group="Style", minval=0, maxval=100, tooltip="How many bars past the current bar the lines stop and their names sit. Every session shares this one right edge.")
bool   i_extendRight  = input.bool(false, "Extend lines across chart", group="Style", tooltip="Off: every line stops at its name. On: lines run on to the right edge of the chart and pass behind the names. Lines display style only.")

string i_zoneStyle   = input.string("Lines", "Display Style", group="Style", options=["Lines", "Boxed Zone"], tooltip="Lines extends every level across the chart, as before. Boxed Zone draws one shaded box per session spanning DR.H to DR.L, with the internal levels shown as reference lines bounded inside it — a cleaner read of the whole day's range.")
int    i_zoneFillPct = input.int(88,      "Zone Fill %", group="Style", minval=50, maxval=98)


// ──────────────────────────────────────────────────────────────────
// INPUTS — OPTIONS
// ──────────────────────────────────────────────────────────────────

bool  i_showPrev    = input.bool(false, "Show Previous Range (faded)", group="Options")
int   i_prevFade    = input.int(75,     "Previous Range Fade %",       group="Options", minval=50, maxval=95)
bool  i_showTint    = input.bool(false, "Background Tint During Window", group="Options")
color i_tintColor   = input.color(color.new(color.gray, 95), "Window Tint Color", group="Options")


// ──────────────────────────────────────────────────────────────────
// STYLE CONSTANT RESOLUTION
// ──────────────────────────────────────────────────────────────────

// Resolve string inputs to Pine constants before passing to methods
string resolvedLineStyle = switch i_lineStyle
    "dotted" => line.style_dotted
    "dashed" => line.style_dashed
    =>          line.style_solid

string resolvedLblSize = switch i_lblSize
    "tiny"   => size.tiny
    "small"  => size.small
    "large"  => size.large
    =>          size.normal

bool i_asZone = i_zoneStyle == "Boxed Zone"

int MS_PER_BAR = timeframe.in_seconds(timeframe.period) * 1000
//@variable The right edge every line and box stops at, and the x every level name sits at.
int rightTime = time + i_lblBarOffset * MS_PER_BAR

//@function Creates a level name as a transparent callout to the right of its anchor, monospace,
//          vertically centred on the level.
//@param x        (int)    Bar time to anchor at (the line's right edge)
//@param y        (float)  Price to anchor at
//@param txt      (string) Label text
//@param txtColor (color)  Text colour
//@param sizeStr  (string) Resolved Pine size constant
//@returns (label)
f_levelLabel(int x, float y, string txt, color txtColor, string sizeStr) =>
    lbl = label.new(x, y, txt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(color.white, 100), textcolor=txtColor, size=sizeStr, textalign=text.align_left)
    label.set_text_font_family(lbl, font.family_monospace)
    lbl

//@function Stops a superseded line at the given time.
//@param ln (line) Line to freeze
//@param t  (int)  Bar time to end it at
f_freeze(line ln, int t) =>
    if not na(ln)
        line.set_x2(ln, t)




// ──────────────────────────────────────────────────────────────────
// SESSION INSTANCES
// ──────────────────────────────────────────────────────────────────

var DRSession asiaSession   = DRSession.new(
     name      = i_asiaLabel,
     startHour = i_asiaStartHour,
     startMin  = i_asiaStartMin,
     endHour   = i_asiaEndHour,
     endMin    = i_asiaEndMin,
     lineColor = i_asiaColor)

var DRSession londonSession = DRSession.new(
     name      = i_londonLabel,
     startHour = i_londonStartHour,
     startMin  = i_londonStartMin,
     endHour   = i_londonEndHour,
     endMin    = i_londonEndMin,
     lineColor = i_londonColor)

var DRSession nySession = DRSession.new(
     name      = i_nyLabel,
     startHour = i_nyStartHour,
     startMin  = i_nyStartMin,
     endHour   = i_nyEndHour,
     endMin    = i_nyEndMin,
     lineColor = i_nyColor)


var DRSession prevDaySession = DRSession.new(
     name      = i_prevDayLabel,
     startHour = i_prevDayStartHour,
     startMin  = i_prevDayStartMin,
     endHour   = i_prevDayEndHour,
     endMin    = i_prevDayEndMin,
     lineColor = i_prevDayColor)


//@function True when nyTimeInt falls inside this session's time window.
//          Handles cross-midnight windows (e.g. 18:00 – 16:15 next day)
//          by detecting when startVal > endVal and inverting the logic.
//@param this       (DRSession) Session to test
//@param nyTimeInt  (int)       Current bar NY time as HHMM integer
//@returns (bool)
method inWindow(DRSession this, int nyTimeInt) =>
    int startVal = this.startHour * 100 + this.startMin
    int endVal   = this.endHour   * 100 + this.endMin
    startVal > endVal ? nyTimeInt >= startVal or nyTimeInt < endVal : nyTimeInt >= startVal and nyTimeInt < endVal


// ──────────────────────────────────────────────────────────────────
// METHOD — draw
// ──────────────────────────────────────────────────────────────────

//@function Cleans up old drawings and renders locked DR levels
//@param this          (DRSession) Session to render
//@param showPrev      (bool)      Fade and keep previous session lines
//@param prevFade      (int)       Transparency % applied to faded previous lines
//@param currentTime   (int)       Current bar timestamp (x2 before extend.right)
//@param lineStyleStr  (string)    Resolved Pine line style constant
//@param lineWidth     (int)       Line width in pixels
//@param showQ25       (bool)      Draw the 25% / 75% levels
//@param showQ75       (bool)      Draw the 75% level
//@param showOctants   (bool)      Draw the 12.5/37.5/62.5/87.5% levels
//@param showSixteenths (bool)     Draw the 6.25/18.75/31.25/43.75/56.25/68.75/81.25/93.75% levels (implies octants)
//@param asZone        (bool)      Boxed Zone mode instead of extending lines
//@param zoneFillPct   (int)       Box fill transparency in Boxed Zone mode
//@param lblSizeStr    (string)    Resolved Pine size constant
//@param lblOffset     (float)     DR.L label drop, as a fraction of the range
//@param rightT        (int)       Right edge time: where the lines stop and the names sit
//@param extendRight   (bool)      Run the lines on past the names (Lines style only)
method draw(DRSession this, bool showPrev, int prevFade, int currentTime, string lineStyleStr, int lineWidth, bool showQ25, bool showQ75, bool showOctants, bool showSixteenths, bool asZone, int zoneFillPct, string lblSizeStr, float lblOffset, int rightT, bool extendRight) =>
    float drRange = this.drHigh - this.drLow
    bool  showOct = showOctants or showSixteenths
    float q9375   = this.drLow + drRange * 0.9375
    float q875    = this.drLow + drRange * 0.875
    float q8125   = this.drLow + drRange * 0.8125
    float q75     = this.drLow + drRange * 0.75
    float q6875   = this.drLow + drRange * 0.6875
    float q625    = this.drLow + drRange * 0.625
    float q5625   = this.drLow + drRange * 0.5625
    float q50     = this.drLow + drRange * 0.50
    float q4375   = this.drLow + drRange * 0.4375
    float q375    = this.drLow + drRange * 0.375
    float q3125   = this.drLow + drRange * 0.3125
    float q25     = this.drLow + drRange * 0.25
    float q1875   = this.drLow + drRange * 0.1875
    float q125    = this.drLow + drRange * 0.125
    float q0625   = this.drLow + drRange * 0.0625

    // Delete two-sessions-old drawings
    line.delete(this.prevH)
    line.delete(this.prev9375)
    line.delete(this.prev875)
    line.delete(this.prev8125)
    line.delete(this.prev75)
    line.delete(this.prev6875)
    line.delete(this.prev625)
    line.delete(this.prev5625)
    line.delete(this.prev50)
    line.delete(this.prev4375)
    line.delete(this.prev375)
    line.delete(this.prev3125)
    line.delete(this.prev25)
    line.delete(this.prev1875)
    line.delete(this.prev125)
    line.delete(this.prev0625)
    line.delete(this.prevL)
    box.delete(this.prevZoneBox)

    // Handle outgoing current drawings
    if showPrev
        this.prevH       := this.lineH
        this.prev9375    := this.line9375
        this.prev875     := this.line875
        this.prev8125    := this.line8125
        this.prev75      := this.line75
        this.prev6875    := this.line6875
        this.prev625     := this.line625
        this.prev5625    := this.line5625
        this.prev50      := this.line50
        this.prev4375    := this.line4375
        this.prev375     := this.line375
        this.prev3125    := this.line3125
        this.prev25      := this.line25
        this.prev1875    := this.line1875
        this.prev125      := this.line125
        this.prev0625     := this.line0625
        this.prevL        := this.lineL
        this.prevZoneBox := this.zoneBox
        for ln in array.from(this.prevH, this.prev9375, this.prev875, this.prev8125, this.prev75, this.prev6875, this.prev625, this.prev5625, this.prev50, this.prev4375, this.prev375, this.prev3125, this.prev25, this.prev1875, this.prev125, this.prev0625, this.prevL)
            f_freeze(ln, currentTime)
        if not na(this.prevZoneBox)
            box.set_right(this.prevZoneBox, currentTime)
        color fadedColor = color.new(this.lineColor, prevFade)
        if not na(this.prevH)
            line.set_color(this.prevH,  fadedColor)
            line.set_color(this.prev50, fadedColor)
            line.set_color(this.prevL,  fadedColor)
        if not na(this.prev9375)
            line.set_color(this.prev9375, fadedColor)
        if not na(this.prev875)
            line.set_color(this.prev875, fadedColor)
        if not na(this.prev8125)
            line.set_color(this.prev8125, fadedColor)
        if not na(this.prev75)
            line.set_color(this.prev75, fadedColor)
        if not na(this.prev6875)
            line.set_color(this.prev6875, fadedColor)
        if not na(this.prev625)
            line.set_color(this.prev625, fadedColor)
        if not na(this.prev5625)
            line.set_color(this.prev5625, fadedColor)
        if not na(this.prev375)
            line.set_color(this.prev375, fadedColor)
        if not na(this.prev4375)
            line.set_color(this.prev4375, fadedColor)
        if not na(this.prev3125)
            line.set_color(this.prev3125, fadedColor)
        if not na(this.prev25)
            line.set_color(this.prev25, fadedColor)
        if not na(this.prev1875)
            line.set_color(this.prev1875, fadedColor)
        if not na(this.prev125)
            line.set_color(this.prev125, fadedColor)
        if not na(this.prev0625)
            line.set_color(this.prev0625, fadedColor)
        if not na(this.prevZoneBox)
            box.set_bgcolor(this.prevZoneBox, color.new(this.lineColor, math.min(prevFade + 5, 98)))
            box.set_border_color(this.prevZoneBox, fadedColor)
    else
        line.delete(this.lineH)
        line.delete(this.line9375)
        line.delete(this.line875)
        line.delete(this.line8125)
        line.delete(this.line75)
        line.delete(this.line6875)
        line.delete(this.line625)
        line.delete(this.line5625)
        line.delete(this.line50)
        line.delete(this.line4375)
        line.delete(this.line375)
        line.delete(this.line3125)
        line.delete(this.line25)
        line.delete(this.line1875)
        line.delete(this.line125)
        line.delete(this.line0625)
        line.delete(this.lineL)
        box.delete(this.zoneBox)

    // Delete all labels — recreated fresh each lock
    label.delete(this.lblH)
    label.delete(this.lbl9375)
    label.delete(this.lbl875)
    label.delete(this.lbl8125)
    label.delete(this.lbl75)
    label.delete(this.lbl6875)
    label.delete(this.lbl625)
    label.delete(this.lbl5625)
    label.delete(this.lbl50)
    label.delete(this.lbl4375)
    label.delete(this.lbl375)
    label.delete(this.lbl3125)
    label.delete(this.lbl25)
    label.delete(this.lbl1875)
    label.delete(this.lbl125)
    label.delete(this.lbl0625)
    label.delete(this.lblL)
    label.delete(this.zoneLbl)

    string lineExtend = not asZone and extendRight ? extend.right : extend.none
    int sx = f_xClamp(this.startTime)

    // Boxed Zone mode — one shaded box spanning the whole range, name above it.
    // The internal levels below are still drawn, just bounded to the box's width
    // instead of slicing across the whole chart.
    if asZone
        this.zoneBox := box.new(sx, this.drHigh, rightT, this.drLow, xloc=xloc.bar_time, extend=extend.none, border_color=this.lineColor, border_width=lineWidth, bgcolor=color.new(this.lineColor, zoneFillPct))
        this.zoneLbl := label.new(x=int(math.avg(sx, rightT)), y=this.drHigh, text=this.name, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=color.new(color.white, 100), textcolor=this.lineColor, size=lblSizeStr)
        label.set_text_font_family(this.zoneLbl, font.family_monospace)

    // Draw DR.H line
    this.lineH := line.new(x1=sx, y1=this.drHigh, x2=rightT, y2=this.drHigh, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)

    // Draw 93.75% line (conditional — Prev Day only)
    if showSixteenths
        this.line9375 := line.new(x1=sx, y1=q9375, x2=rightT, y2=q9375, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line9375 := na

    // Draw 87.5% line (conditional)
    if showOct
        this.line875 := line.new(x1=sx, y1=q875, x2=rightT, y2=q875, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line875 := na

    // Draw 81.25% line (conditional — Prev Day only)
    if showSixteenths
        this.line8125 := line.new(x1=sx, y1=q8125, x2=rightT, y2=q8125, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line8125 := na

    // Draw 75% line (conditional)
    if showQ75
        this.line75 := line.new(x1=sx, y1=q75, x2=rightT, y2=q75, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line75 := na

    // Draw 68.75% line (conditional — Prev Day only)
    if showSixteenths
        this.line6875 := line.new(x1=sx, y1=q6875, x2=rightT, y2=q6875, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line6875 := na

    // Draw 62.5% line (conditional)
    if showOct
        this.line625 := line.new(x1=sx, y1=q625, x2=rightT, y2=q625, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line625 := na

    // Draw 56.25% line (conditional — Prev Day only)
    if showSixteenths
        this.line5625 := line.new(x1=sx, y1=q5625, x2=rightT, y2=q5625, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line5625 := na

    // Draw 50% line
    this.line50 := line.new(x1=sx, y1=q50, x2=rightT, y2=q50, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)

    // Draw 43.75% line (conditional — Prev Day only)
    if showSixteenths
        this.line4375 := line.new(x1=sx, y1=q4375, x2=rightT, y2=q4375, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line4375 := na

    // Draw 37.5% line (conditional)
    if showOct
        this.line375 := line.new(x1=sx, y1=q375, x2=rightT, y2=q375, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line375 := na

    // Draw 31.25% line (conditional — Prev Day only)
    if showSixteenths
        this.line3125 := line.new(x1=sx, y1=q3125, x2=rightT, y2=q3125, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line3125 := na

    // Draw 25% line (conditional)
    if showQ25
        this.line25 := line.new(x1=sx, y1=q25, x2=rightT, y2=q25, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line25 := na

    // Draw 18.75% line (conditional — Prev Day only)
    if showSixteenths
        this.line1875 := line.new(x1=sx, y1=q1875, x2=rightT, y2=q1875, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line1875 := na

    // Draw 12.5% line (conditional)
    if showOct
        this.line125 := line.new(x1=sx, y1=q125, x2=rightT, y2=q125, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line125 := na

    // Draw 6.25% line (conditional — Prev Day only)
    if showSixteenths
        this.line0625 := line.new(x1=sx, y1=q0625, x2=rightT, y2=q0625, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)
    else
        this.line0625 := na

    // Draw DR.L line
    this.lineL := line.new(x1=sx, y1=this.drLow, x2=rightT, y2=this.drLow, xloc=xloc.bar_time, extend=lineExtend, color=this.lineColor, width=lineWidth, style=lineStyleStr)

    // Per-level labels. Drawn in BOTH display styles, so the percentage
    // levels stay readable inside a Boxed Zone, not just in Lines mode. The box
    // bounds the lines; it does not hide what they are.
    this.lblH := f_levelLabel(rightT, this.drHigh, this.name + "  DR.H", this.lineColor, lblSizeStr)

    if showSixteenths
        this.lbl9375 := f_levelLabel(rightT, q9375, "93.75%", this.lineColor, lblSizeStr)

    if showOct
        this.lbl875 := f_levelLabel(rightT, q875, "87.5%", this.lineColor, lblSizeStr)

    if showSixteenths
        this.lbl8125 := f_levelLabel(rightT, q8125, "81.25%", this.lineColor, lblSizeStr)

    if showQ75
        this.lbl75 := f_levelLabel(rightT, q75, "75%", this.lineColor, lblSizeStr)

    if showSixteenths
        this.lbl6875 := f_levelLabel(rightT, q6875, "68.75%", this.lineColor, lblSizeStr)

    if showOct
        this.lbl625 := f_levelLabel(rightT, q625, "62.5%", this.lineColor, lblSizeStr)

    if showSixteenths
        this.lbl5625 := f_levelLabel(rightT, q5625, "56.25%", this.lineColor, lblSizeStr)

    this.lbl50 := f_levelLabel(rightT, q50, "50%", this.lineColor, lblSizeStr)

    if showSixteenths
        this.lbl4375 := f_levelLabel(rightT, q4375, "43.75%", this.lineColor, lblSizeStr)

    if showOct
        this.lbl375 := f_levelLabel(rightT, q375, "37.5%", this.lineColor, lblSizeStr)

    if showSixteenths
        this.lbl3125 := f_levelLabel(rightT, q3125, "31.25%", this.lineColor, lblSizeStr)

    if showQ25
        this.lbl25 := f_levelLabel(rightT, q25, "25%", this.lineColor, lblSizeStr)

    if showSixteenths
        this.lbl1875 := f_levelLabel(rightT, q1875, "18.75%", this.lineColor, lblSizeStr)

    if showOct
        this.lbl125 := f_levelLabel(rightT, q125, "12.5%", this.lineColor, lblSizeStr)

    if showSixteenths
        this.lbl0625 := f_levelLabel(rightT, q0625, "6.25%", this.lineColor, lblSizeStr)

    this.lblL := f_levelLabel(rightT, this.drLow - drRange * lblOffset, this.name + "  DR.L", this.lineColor, lblSizeStr)


// ──────────────────────────────────────────────────────────────────
// METHOD — updateLabels
// ──────────────────────────────────────────────────────────────────

//@function Moves the live lines, zone box and level names to the shared right edge each bar,
//          so every name stays at the end of its own line. A box or line
//          that has been superseded by a fresh lock is no longer `this.zoneBox`/`this.lineXXX`
//          — it is simply not reached by this method any more, so it freezes exactly where it
//          was at the handoff instead of growing forever. That is what bounds the zone.
//@param this         (DRSession) Session whose drawings to update
//@param rightT       (int)       Right edge time: where the lines stop and the names sit
method updateLabels(DRSession this, int rightT) =>
    if not na(this.zoneBox)
        box.set_right(this.zoneBox, rightT)
    if not na(this.lineH)
        line.set_x2(this.lineH, rightT)
    if not na(this.line9375)
        line.set_x2(this.line9375, rightT)
    if not na(this.line875)
        line.set_x2(this.line875, rightT)
    if not na(this.line8125)
        line.set_x2(this.line8125, rightT)
    if not na(this.line75)
        line.set_x2(this.line75, rightT)
    if not na(this.line6875)
        line.set_x2(this.line6875, rightT)
    if not na(this.line625)
        line.set_x2(this.line625, rightT)
    if not na(this.line5625)
        line.set_x2(this.line5625, rightT)
    if not na(this.line50)
        line.set_x2(this.line50, rightT)
    if not na(this.line4375)
        line.set_x2(this.line4375, rightT)
    if not na(this.line375)
        line.set_x2(this.line375, rightT)
    if not na(this.line3125)
        line.set_x2(this.line3125, rightT)
    if not na(this.line25)
        line.set_x2(this.line25, rightT)
    if not na(this.line1875)
        line.set_x2(this.line1875, rightT)
    if not na(this.line125)
        line.set_x2(this.line125, rightT)
    if not na(this.line0625)
        line.set_x2(this.line0625, rightT)
    if not na(this.lineL)
        line.set_x2(this.lineL, rightT)

    if not na(this.lblH)
        label.set_x(this.lblH,  rightT)
    if not na(this.lbl9375)
        label.set_x(this.lbl9375, rightT)
    if not na(this.lbl875)
        label.set_x(this.lbl875, rightT)
    if not na(this.lbl8125)
        label.set_x(this.lbl8125, rightT)
    if not na(this.lbl75)
        label.set_x(this.lbl75, rightT)
    if not na(this.lbl6875)
        label.set_x(this.lbl6875, rightT)
    if not na(this.lbl625)
        label.set_x(this.lbl625, rightT)
    if not na(this.lbl5625)
        label.set_x(this.lbl5625, rightT)
    if not na(this.lbl50)
        label.set_x(this.lbl50, rightT)
    if not na(this.lbl4375)
        label.set_x(this.lbl4375, rightT)
    if not na(this.lbl375)
        label.set_x(this.lbl375, rightT)
    if not na(this.lbl3125)
        label.set_x(this.lbl3125, rightT)
    if not na(this.lbl25)
        label.set_x(this.lbl25, rightT)
    if not na(this.lbl1875)
        label.set_x(this.lbl1875, rightT)
    if not na(this.lbl125)
        label.set_x(this.lbl125, rightT)
    if not na(this.lbl0625)
        label.set_x(this.lbl0625, rightT)
    if not na(this.lblL)
        label.set_x(this.lblL,  rightT)


// ──────────────────────────────────────────────────────────────────
// NY TIME — computed once per bar
// ──────────────────────────────────────────────────────────────────

int nyHour    = hour(time, "America/New_York")
int nyMin     = minute(time, "America/New_York")
int nyTimeInt = nyHour * 100 + nyMin


// ──────────────────────────────────────────────────────────────────

bool asiaInWin    = asiaSession.inWindow(nyTimeInt)
bool londonInWin  = londonSession.inWindow(nyTimeInt)
bool nyInWin      = nySession.inWindow(nyTimeInt)
bool prevDayInWin = prevDaySession.inWindow(nyTimeInt)


// ──────────────────────────────────────────────────────────────────
// SESSION PROCESSING — ASIA
// ──────────────────────────────────────────────────────────────────

if i_showAsia
    bool asiaOpened = asiaInWin and not asiaInWin[1]
    bool asiaClosed = not asiaInWin and asiaInWin[1] and not asiaSession.locked and not na(asiaSession.drHigh) and not na(asiaSession.drLow)

    if asiaOpened
        asiaSession.drHigh    := high
        asiaSession.drLow     := low
        asiaSession.locked    := false
        asiaSession.startTime := time

    if asiaInWin and not asiaSession.locked
        asiaSession.drHigh := math.max(nz(asiaSession.drHigh, high), high)
        asiaSession.drLow  := math.min(nz(asiaSession.drLow,  low),  low)

    if asiaClosed
        asiaSession.locked := true
        asiaSession.draw(i_showPrev, i_prevFade, time, resolvedLineStyle, i_lineWidth, i_showQ25, i_showQ75, i_showOctants, false, i_asZone, i_zoneFillPct, resolvedLblSize, i_lblOffset, rightTime, i_extendRight)


// ──────────────────────────────────────────────────────────────────
// SESSION PROCESSING — LONDON
// ──────────────────────────────────────────────────────────────────

if i_showLondon
    bool londonOpened = londonInWin and not londonInWin[1]
    bool londonClosed = not londonInWin and londonInWin[1] and not londonSession.locked and not na(londonSession.drHigh) and not na(londonSession.drLow)

    if londonOpened
        londonSession.drHigh    := high
        londonSession.drLow     := low
        londonSession.locked    := false
        londonSession.startTime := time

    if londonInWin and not londonSession.locked
        londonSession.drHigh := math.max(nz(londonSession.drHigh, high), high)
        londonSession.drLow  := math.min(nz(londonSession.drLow,  low),  low)

    if londonClosed
        londonSession.locked := true
        londonSession.draw(i_showPrev, i_prevFade, time, resolvedLineStyle, i_lineWidth, i_showQ25, i_showQ75, i_showOctants, false, i_asZone, i_zoneFillPct, resolvedLblSize, i_lblOffset, rightTime, i_extendRight)


// ──────────────────────────────────────────────────────────────────
// SESSION PROCESSING — NEW YORK
// ──────────────────────────────────────────────────────────────────

if i_showNY
    bool nyOpened = nyInWin and not nyInWin[1]
    bool nyClosed = not nyInWin and nyInWin[1] and not nySession.locked and not na(nySession.drHigh) and not na(nySession.drLow)

    if nyOpened
        nySession.drHigh    := high
        nySession.drLow     := low
        nySession.locked    := false
        nySession.startTime := time

    if nyInWin and not nySession.locked
        nySession.drHigh := math.max(nz(nySession.drHigh, high), high)
        nySession.drLow  := math.min(nz(nySession.drLow,  low),  low)

    if nyClosed
        nySession.locked := true
        nySession.draw(i_showPrev, i_prevFade, time, resolvedLineStyle, i_lineWidth, i_showQ25, i_showQ75, i_showOctants, false, i_asZone, i_zoneFillPct, resolvedLblSize, i_lblOffset, rightTime, i_extendRight)


// ──────────────────────────────────────────────────────────────────
// SESSION PROCESSING — PREV DAY (6PM–4:15PM NY, cross-midnight)
// ──────────────────────────────────────────────────────────────────

if i_showPrevDay
    bool prevDayOpened = prevDayInWin and not prevDayInWin[1]
    bool prevDayClosed = not prevDayInWin and prevDayInWin[1] and not prevDaySession.locked and not na(prevDaySession.drHigh) and not na(prevDaySession.drLow)

    if prevDayOpened
        prevDaySession.drHigh    := high
        prevDaySession.drLow     := low
        prevDaySession.locked    := false
        prevDaySession.startTime := time

    if prevDayInWin and not prevDaySession.locked
        prevDaySession.drHigh := math.max(nz(prevDaySession.drHigh, high), high)
        prevDaySession.drLow  := math.min(nz(prevDaySession.drLow,  low),  low)

    if prevDayClosed
        prevDaySession.locked := true
        prevDaySession.draw(i_showPrev, i_prevFade, time, resolvedLineStyle, i_lineWidth, i_showQ25, i_showQ75, i_showOctants, i_showSixteenths, i_asZone, i_zoneFillPct, resolvedLblSize, i_lblOffset, rightTime, i_extendRight)


asiaSession.updateLabels(rightTime)
londonSession.updateLabels(rightTime)
nySession.updateLabels(rightTime)
prevDaySession.updateLabels(rightTime)


// ──────────────────────────────────────────────────────────────────
// BACKGROUND TINT (optional)
// ──────────────────────────────────────────────────────────────────

bool anyWindowOpen = (i_showAsia and asiaInWin) or (i_showLondon and londonInWin) or (i_showNY and nyInWin) or (i_showPrevDay and prevDayInWin)
bgcolor(i_showTint and anyWindowOpen ? i_tintColor : na, title="DR Window Tint")


// ──────────────────────────────────────────────────────────────────
// ALERTS
// ──────────────────────────────────────────────────────────────────

alertcondition(i_showAsia    and not asiaInWin    and asiaInWin[1],    "Asia DR Locked",     "Asia Dealing Range locked — {{ticker}}")
alertcondition(i_showLondon  and not londonInWin  and londonInWin[1],  "London DR Locked",   "London Dealing Range locked — {{ticker}}")
alertcondition(i_showNY      and not nyInWin      and nyInWin[1],      "NY DR Locked",       "NY Dealing Range locked — {{ticker}}")
alertcondition(i_showPrevDay and not prevDayInWin and prevDayInWin[1], "Prev Day DR Locked", "Prev Day Dealing Range locked — {{ticker}}")
````
