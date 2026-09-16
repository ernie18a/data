<!-- tradingview-pine-id: PUB;5ac3fb95b5c84904912665fb4b09fb35 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ICT Kill Zones and Session High Low

Source: https://www.tradingview.com/script/8OMkwGXn-ICT-Kill-Zones-and-Session-High-Low/

## Description

ICT Kill Zones and Session High Low

What it does
This indicator draws the intraday sessions as boxes with their high and low, marks the three daily opening levels, and reports which time state the chart is currently in. Its point is not the feature list, which you can find elsewhere; its point is being right at the edges. Everything is anchored to New York wall-clock time, so the sessions keep their place through every daylight-saving changeover, including the weeks when the United States and Europe have not both switched yet. On those weeks the panel says so.

How it works
Every window is resolved through the named time zone America/New York rather than a fixed offset, the chart time zone or your local time. That single choice is what makes the boxes sit correctly in March and October, and it is the reason a session cannot drift by an hour without anyone noticing.

[*] A session starts on the first bar that falls inside its window, not on a bar whose clock reads exactly the start time. On a 45 minute chart no bar lands on 07:00, and a script that waits for one draws nothing that day.
[*] While a session runs, its box grows and its high and low move with it. That state is drawn with a dashed border, because a level that can still change must not look like one that cannot.
[*] When the session ends, the high and low are fixed and never move again. The border turns solid and the two levels extend to the right.
[*] The bar that ends a session can already trade through what that session just fixed, so both things are allowed to happen on the same bar. A level that was taken immediately is never shown as untouched first.
[*] A level is taken when price trades strictly beyond it, by wick or by close depending on the setting. A value exactly on the level is not a take, and each level changes state only once.
[*] The New York to London offset is recalculated per trading day from the calendar itself. It is displayed, never applied: the sessions sit right because they are anchored to New York, not because anything is shifted.
[*] Short trading days and holidays are read from the bars that exist, not from a stored calendar that would need maintenance and would eventually be wrong.

How to use it

[*] Add the script to an intraday chart. Sessions cannot be resolved above 60 minutes, and on higher timeframes the script says so instead of drawing something misleading.
[*] Read the dashed box as the session in progress and the solid one as finished. The two lines running to the right are the finished session's high and low.
[*] Watch the panel in March and late October. When it reads 4h instead of 5h, the two regions are out of step and the London session sits an hour away from where it was the week before. The gap can last up to three weeks in spring and about a week in autumn, depending on the year.
[*] If a day reads Early close or No RTH session, that day was short or closed. Both are recognised after the day is over, so the label refers to the last completed day.

Inputs

[*] Sessions group - one row per session with a switch, its start and end time in New York wall-clock time, and its colour. London Close is off by default so the standard chart shows four boxes that do not overlap.
[*] Session Levels group - show the fixed high and low, extend them to the right, and choose whether a wick or a close counts as taking them.
[*] Time Markers group - Midnight Open, True Day Open and RTH Open, each switchable. The last two are hidden automatically where they have no meaning. Extend Markers Right lets the newest marker of each type run past the latest candle so its line and label stay visible in front of the price action; range 0-500, default 10. Older markers still end where the next marker of the same type begins.
[*] Level Line Style and Marker Line Style - solid, dashed or dotted. The markers are dotted by default so they read as references rather than as structure.
[*] Label Background - off by default, so only the label text shows. Turn it on where a label sits over the candles and the bare text is hard to read.
[*] Days Retained - how many trading days stay drawn, the current one included. Range 1-10, default 2. Older days are deleted, not hidden. On futures the Sunday evening open counts as its own day, so on a Monday the default keeps Sunday and Monday rather than Friday and Monday.
[*] Display group - session labels and where they sit: Above Box by default, Inside Box or Below Box, always centred on the width of the box. Plus text size in points, the time state panel and its corner.
[*] Style group - how far the boxes fade for finished and running sessions, line widths, and one colour per time marker.
[*] Alerts group - each of the four alert conditions can be switched off.

Signals and alerts

[*] Session opened - fires on the first closed bar of a tracked session. Off by default, because the clock is not news.
[*] Session closed - fires when a session has ended and its levels are fixed. Off by default for the same reason.
[*] Session high taken and Session low taken - fire when price trades through a fixed level. On by default, because this is the one event of the four that is not predictable from a clock.

All four fire on the close of the bar that produced the change, and each level can only be taken once.

Repainting
Sessions start, end and levels are taken only on closed bars. A running session is the one thing that changes while it runs, and that is its purpose rather than a defect: its box grows with each bar and is drawn with a dashed border to say so. Once a session is finished its box and its two levels are fixed and are never rewritten, and the offset shown in the panel changes nothing that is already on the chart.

Limitations

[*] A short trading day or a holiday is recognised only after the day is over, because it is read from the bars that exist rather than from a stored calendar. The panel therefore reports the last completed day. On futures that means a short Friday is reported during the Sunday evening session and is replaced once Monday begins.
[*] Sessions need an intraday timeframe. Above 60 minutes the windows cannot be resolved and nothing is drawn.
[*] On instruments without a regular trading session - spot forex, crypto and CFDs - the True Day Open and RTH Open markers are hidden because they are not defined there. The panel says so.
[*] Only the most recent day's time markers carry a label. Older ones keep their line but would otherwise stack their labels on the same spot at the right edge.
[*] A session with no bars inside its window produces nothing at all, which is correct but means an empty session leaves no trace to explain itself.
[*] Days Retained set to 1 together with a window you moved across midnight keeps only the session that is still running. Its completed form is never shown, because the day it belongs to is already outside the retention. Raise Days Retained to 2 if you want to see it finished.
[*] Only the bars of the chart timeframe are used. There is no higher timeframe layer, no intrabar data and no volume.
[*] The script describes when things happened and whether a level was traded through. It does not compare sessions, rank them, or suggest entries, exits or targets.

This script is a charting tool for educational purposes. It does not provide financial advice and does not predict future price movement. Trading carries risk; decisions and their outcome remain yours.

---

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) KronosMMXM

//@version=6
indicator("ICT Kill Zones and Session High Low", shorttitle = "Killzones (kronos)", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//#region TYPES ================================================================

enum TakeBasis
    wickThrough = "Wick"
    closeBeyond = "Close"

enum LineLook
    solid  = "Solid"
    dashed = "Dashed"
    dotted = "Dotted"

enum PanelSpot
    topRight    = "Top Right"
    topLeft     = "Top Left"
    bottomRight = "Bottom Right"

enum LabelSpot
    aboveBox  = "Above Box"
    insideBox = "Inside Box"
    belowBox  = "Below Box"

// One instance of one session on one trading day. Everything geometric is
// frozen the moment the session completes.
type Session
    int   slot
    int   day
    int   startBar
    int   endBar
    float high
    float low
    int   state
    int   highState
    int   lowState
    int   highTakenBar = na
    int   lowTakenBar  = na
    box   area         = na
    label tag          = na
    line  highLine     = na
    line  lowLine      = na

// A daily price anchor: the open of the first bar from a given wall-clock time.
type TimeMark
    int   slot
    int   day
    int   anchorBar
    int   endBar
    float price
    line  mark  = na
    label tag   = na

//#endregion

//#region CONSTANTS ============================================================

int    STATE_FORMING    = 0
int    STATE_COMPLETE   = 1
int    STATE_TAKEN      = 2

int    SLOT_ASIA        = 0
int    SLOT_LONDON      = 1
int    SLOT_NY_AM       = 2
int    SLOT_LDN_CLOSE   = 3
int    SLOT_NY_PM       = 4
int    SLOT_COUNT       = 5

int    MARK_MIDNIGHT    = 0
int    MARK_TRUE_DAY    = 1
int    MARK_RTH         = 2
int    MARK_COUNT       = 3

string TZ_NEW_YORK      = "America/New_York"
string TZ_LONDON        = "Europe/London"
int    NOON_HOUR        = 12
int    MS_PER_HOUR      = 3600000
int    REGULAR_OFFSET   = 5

string WIN_MIDNIGHT     = "0000-0100"
string WIN_TRUE_DAY     = "1800-1900"
string WIN_RTH          = "0930-1600"

color  ASIA_COLOR       = #7e57c2ff
color  LONDON_COLOR     = #26a69aff
color  NY_AM_COLOR      = #42a5f5ff
color  LDN_CLOSE_COLOR  = #ab47bcff
color  NY_PM_COLOR      = #ef5350ff
color  MIDNIGHT_COLOR   = #b2b5beff
color  TRUE_DAY_COLOR   = #5c9ce6ff
color  RTH_COLOR        = #e0a458ff
color  ALERT_COLOR      = #ffb74dff

string GRP_SESSIONS     = "Sessions"
string GRP_LEVELS       = "Session Levels"
string GRP_MARKERS      = "Time Markers"
string GRP_RETENTION    = "Retention"
string GRP_DISPLAY      = "Display"
string GRP_STYLE        = "Style"
string GRP_ALERTS       = "Alerts"

int    DAYS_MIN         = 1
int    DAYS_MAX         = 10
int    OPACITY_MAX      = 100
int    WIDTH_MIN        = 1
int    WIDTH_MAX        = 4
int    TEXT_SIZE_MIN    = 10
int    TEXT_SIZE_MAX    = 40
int    X_MIN_OFFSET     = 10000
int    MARK_EXTEND_MAX  = 500
int    TAKES_LISTED     = 8
int    MAX_INTRADAY_SEC = 3600
int    RTH_END_SECOND   = 57600

string NOTE_TIMEFRAME   = "Sessions require an intraday timeframe (60m or lower)."
string NOTE_NO_RTH_TYPE = "RTH markers are not defined on this instrument class."
string LABEL_EARLY      = "Early close"
string LABEL_NO_RTH     = "No RTH session"
string LABEL_OFFSET     = "NY/London offset: "
string LABEL_TRANSITION = " - transition week"
string LABEL_NONE       = "-"

string EVENT_SESSION_OPEN  = "Session opened"
string EVENT_SESSION_CLOSE = "Session closed"
string EVENT_HIGH_TAKEN    = "Session high taken"
string EVENT_LOW_TAKEN     = "Session low taken"
string MSG_SESSION_OPEN    = "A tracked session produced its first closed bar."
string MSG_SESSION_CLOSE   = "A tracked session closed; its high and low are now fixed."
string MSG_HIGH_TAKEN      = "Price traded through a fixed session high."
string MSG_LOW_TAKEN       = "Price traded through a fixed session low."

string TIP_SESSION = """Start and end in New York wall-clock time. The script
resolves that zone with its real daylight-saving rules, so a session keeps its
New York time through every changeover without you touching it."""

string TIP_TAKE = """Wick counts a high or low that trades through a fixed
level. Close needs a confirmed close beyond it. A value exactly on the level is
never a take."""

string TIP_DAYS = """How many past trading days stay drawn. Older days are
deleted, not hidden."""

string TIP_PANEL = """Shows which session is running, the current New York to
London offset, and whether the day was a holiday or closed early. The offset is
displayed, never applied - the sessions sit right because they are anchored to
New York, not because they are shifted."""

string TIP_TEXT_SIZE = """Text size of session labels and the panel, in points."""

string TIP_LEVEL_STYLE = """Style of the session high and low lines."""

string TIP_MARK_STYLE = """Style of the time markers. Dotted by default so they
read as references rather than as structure."""

string TIP_LABEL_PLATE = """Draws an opaque plate behind the label text. Off by
default so only the text shows. Turn it on where a label sits over the candles
and the bare text is hard to read."""

string TIP_LABEL_SPOT = """Where the session label sits, always centred on the
width of its box: right above the box, in the middle of it, or right below."""

string TIP_MARK_EXTEND = """How many bars the newest time marker of each type
runs past the latest candle, so its line and label stay visible in front of the
price action instead of behind it. 0 ends it on the current bar. Older markers
still end where the next marker of the same type begins."""

string TIP_OPACITY = """How far the session boxes fade into the background. 0 is
a solid block, higher values let the candles show through. A running session
fades one step further so the two states stay apart at a glance."""

//#endregion

//#region INPUTS ===============================================================

bool      showAsiaInput      = input.bool(true, "Asia", inline = "asia", group = GRP_SESSIONS)
string    asiaTimeInput      = input.session("2000-0000", "", inline = "asia", group = GRP_SESSIONS, tooltip = TIP_SESSION, active = showAsiaInput)
color     asiaColorInput     = input.color(ASIA_COLOR, "", inline = "asia", group = GRP_SESSIONS, active = showAsiaInput)
bool      showLondonInput    = input.bool(true, "London", inline = "ldn", group = GRP_SESSIONS)
string    londonTimeInput    = input.session("0200-0500", "", inline = "ldn", group = GRP_SESSIONS, active = showLondonInput)
color     londonColorInput   = input.color(LONDON_COLOR, "", inline = "ldn", group = GRP_SESSIONS, active = showLondonInput)
bool      showNyAmInput      = input.bool(true, "New York AM", inline = "nyam", group = GRP_SESSIONS)
string    nyAmTimeInput      = input.session("0700-1000", "", inline = "nyam", group = GRP_SESSIONS, active = showNyAmInput)
color     nyAmColorInput     = input.color(NY_AM_COLOR, "", inline = "nyam", group = GRP_SESSIONS, active = showNyAmInput)
bool      showLdnCloseInput  = input.bool(false, "London Close", inline = "ldnc", group = GRP_SESSIONS)
string    ldnCloseTimeInput  = input.session("1000-1200", "", inline = "ldnc", group = GRP_SESSIONS, active = showLdnCloseInput)
color     ldnCloseColorInput = input.color(LDN_CLOSE_COLOR, "", inline = "ldnc", group = GRP_SESSIONS, active = showLdnCloseInput)
bool      showNyPmInput      = input.bool(true, "New York PM", inline = "nypm", group = GRP_SESSIONS)
string    nyPmTimeInput      = input.session("1330-1600", "", inline = "nypm", group = GRP_SESSIONS, active = showNyPmInput)
color     nyPmColorInput     = input.color(NY_PM_COLOR, "", inline = "nypm", group = GRP_SESSIONS, active = showNyPmInput)

bool      showLevelsInput    = input.bool(true, "Show Session High/Low", group = GRP_LEVELS)
bool      extendLevelsInput  = input.bool(true, "Extend Levels Right", group = GRP_LEVELS, active = showLevelsInput)
TakeBasis takeBasisInput     = input.enum(TakeBasis.wickThrough, "Level Take Basis", group = GRP_LEVELS, active = showLevelsInput, tooltip = TIP_TAKE)

bool      showMidnightInput  = input.bool(true, "Show Midnight Open", group = GRP_MARKERS)
bool      showTrueDayInput   = input.bool(true, "Show True Day Open", group = GRP_MARKERS)
bool      showRthInput       = input.bool(true, "Show RTH Open", group = GRP_MARKERS)
int       markExtendInput    = input.int(10, "Extend Markers Right (Bars)", minval = 0, maxval = MARK_EXTEND_MAX, group = GRP_MARKERS, tooltip = TIP_MARK_EXTEND)

int       daysRetainedInput  = input.int(2, "Days Retained", minval = DAYS_MIN, maxval = DAYS_MAX, group = GRP_RETENTION, tooltip = TIP_DAYS)

bool      showSessLabelInput = input.bool(true, "Show Session Labels", group = GRP_DISPLAY)
LabelSpot sessLabelSpotInput = input.enum(LabelSpot.aboveBox, "Session Label Position", group = GRP_DISPLAY, active = showSessLabelInput, tooltip = TIP_LABEL_SPOT)
int       textSizeInput      = input.int(12, "Text Size", minval = TEXT_SIZE_MIN, maxval = TEXT_SIZE_MAX, group = GRP_DISPLAY, tooltip = TIP_TEXT_SIZE)
bool      showPanelInput     = input.bool(true, "Show Time State Panel", group = GRP_DISPLAY, tooltip = TIP_PANEL)
PanelSpot panelSpotInput     = input.enum(PanelSpot.topRight, "Panel Position", group = GRP_DISPLAY, active = showPanelInput)

int       boxFadeInput       = input.int(90, "Box Transparency", minval = 0, maxval = OPACITY_MAX, group = GRP_STYLE, tooltip = TIP_OPACITY)
int       formingFadeInput   = input.int(95, "Forming Transparency", minval = 0, maxval = OPACITY_MAX, group = GRP_STYLE)
int       levelWidthInput    = input.int(1, "Level Line Width", minval = WIDTH_MIN, maxval = WIDTH_MAX, group = GRP_STYLE, active = showLevelsInput)
int       markWidthInput     = input.int(1, "Marker Line Width", minval = WIDTH_MIN, maxval = WIDTH_MAX, group = GRP_STYLE)
LineLook  levelLookInput     = input.enum(LineLook.solid, "Level Line Style", group = GRP_STYLE, tooltip = TIP_LEVEL_STYLE, active = showLevelsInput)
LineLook  markLookInput      = input.enum(LineLook.dotted, "Marker Line Style", group = GRP_STYLE, tooltip = TIP_MARK_STYLE)
bool      labelPlateInput    = input.bool(false, "Label Background", group = GRP_STYLE, tooltip = TIP_LABEL_PLATE)
color     midnightColorInput = input.color(MIDNIGHT_COLOR, "Midnight Open", group = GRP_STYLE, active = showMidnightInput)
color     trueDayColorInput  = input.color(TRUE_DAY_COLOR, "True Day Open", group = GRP_STYLE, active = showTrueDayInput)
color     rthColorInput      = input.color(RTH_COLOR, "RTH Open", group = GRP_STYLE, active = showRthInput)

bool      alertOpenInput     = input.bool(false, "Alert On Session Open", group = GRP_ALERTS)
bool      alertCloseInput    = input.bool(false, "Alert On Session Close", group = GRP_ALERTS)
bool      alertTakenInput    = input.bool(true, "Alert On Level Taken", group = GRP_ALERTS)

//#endregion

//#region FUNCTIONS ============================================================

// @function        Colour configured for one session slot.
// @param slot      (int) Session slot index.
// @returns         (series color) Colour of that session.
// Dependencies     the five session colour inputs
slotColor(int slot) =>
    switch slot
        SLOT_ASIA      => asiaColorInput
        SLOT_LONDON    => londonColorInput
        SLOT_NY_AM     => nyAmColorInput
        SLOT_LDN_CLOSE => ldnCloseColorInput
        =>                nyPmColorInput

// @function        Display name of one session slot.
// @param slot      (int) Session slot index.
// @returns         (series string) Human-readable name.
slotName(int slot) =>
    switch slot
        SLOT_ASIA      => "Asia"
        SLOT_LONDON    => "London"
        SLOT_NY_AM     => "New York AM"
        SLOT_LDN_CLOSE => "London Close"
        =>                "New York PM"

// @function        Colour configured for one time marker.
// @param slot      (int) Marker slot index.
// @returns         (series color) Colour of that marker.
// Dependencies     the three marker colour inputs
markColor(int slot) =>
    switch slot
        MARK_MIDNIGHT => midnightColorInput
        MARK_TRUE_DAY => trueDayColorInput
        =>               rthColorInput

// @function        Short label of one time marker.
// @param slot      (int) Marker slot index.
// @returns         (series string) Two or three letter tag.
markName(int slot) =>
    switch slot
        MARK_MIDNIGHT => "MO"
        MARK_TRUE_DAY => "TDO"
        =>               "RTH"

// @function        New York to London offset for the day a bar belongs to.
// @returns         (series int) Offset in whole hours, 5 normally, 4 in a
//                  changeover week when the two regions have not both switched.
// Dependencies     none beyond the current bar's date
regionOffsetHours() =>
    int y = year(time, TZ_NEW_YORK)
    int m = month(time, TZ_NEW_YORK)
    int d = dayofmonth(time, TZ_NEW_YORK)
    // Same wall-clock moment translated in both zones; the gap is the offset.
    int noonNy     = timestamp(TZ_NEW_YORK, y, m, d, NOON_HOUR, 0, 0)
    int noonLondon = timestamp(TZ_LONDON, y, m, d, NOON_HOUR, 0, 0)
    math.round((noonNy - noonLondon) / MS_PER_HOUR)

// @function        Whether a price has passed a fixed level, strictly.
// @param isHigh    (bool) True for a session high, false for a session low.
// @param price     (float) Price being tested.
// @param level     (float) Fixed level.
// @returns         (series bool) True only when price is strictly past it.
passedLevel(bool isHigh, float price, float level) =>
    isHigh ? price > level : price < level

// @function        Table position chosen by the user.
// @param spot      (PanelSpot) Selected corner.
// @returns         (series string) Matching `position.*` constant.
panelPosition(PanelSpot spot) =>
    switch spot
        PanelSpot.topRight => position.top_right
        PanelSpot.topLeft  => position.top_left
        =>                    position.bottom_right

// @function        Opening minute of a session window, in wall-clock minutes.
// @param spec      (simple string) Session specification, e.g. "1800-0200".
// @returns         (simple int) Minutes since midnight of the window start.
//                  Reads the leading "HHMM" only, so an optional day-of-week
//                  suffix such as ":23456" never reaches the parser.
windowStart(simple string spec) =>
    math.round(str.tonumber(str.substring(spec, 0, 2))) * 60
      + math.round(str.tonumber(str.substring(spec, 2, 4)))

// @function        Closing minute of a session window, in wall-clock minutes.
// @param spec      (simple string) Session specification, e.g. "1800-0200".
// @returns         (simple int) Minutes since midnight of the window end.
windowEnd(simple string spec) =>
    math.round(str.tonumber(str.substring(spec, 5, 7))) * 60
      + math.round(str.tonumber(str.substring(spec, 7, 9)))

// @function        Appends one truthful take to the alert text.
// @param acc       (string) Text collected on this bar so far.
// @param name      (string) Session that was taken.
// @param isHigh    (bool) True for the high, false for the low.
// @param level     (float) The level that was taken.
// @param taken     (int) How many takes this bar has already produced.
// @returns         (series string) `acc` with this take appended, or a short
//                  tail once the list would grow past `TAKES_LISTED`. Pine caps
//                  an alert message at 4096 characters, and a single bar can in
//                  principle take both sides of every retained session.
//                  Built at the moment of the take, per session and per side.
//                  A single session/level pair for the whole bar would combine
//                  the last writer with an aggregated flag and could name a
//                  level that was never touched.
appendTake(string acc, string name, bool isHigh, float level, int taken) =>
    string one = name + (isHigh ? " high" : " low") + " taken at "
      + str.tostring(level, format.mintick)
    switch
        acc == ""                 => one
        taken <= TAKES_LISTED     => acc + "; " + one
        taken == TAKES_LISTED + 1 => acc + " and more"
        =>                           acc

// @function        Maps the chosen look to a Pine line style constant.
// @param look      (LineLook) Style picked in the settings.
// @returns         (series string) Matching `line.style_*` constant.
lineStyleOf(LineLook look) =>
    switch look
        LineLook.dashed => line.style_dashed
        LineLook.dotted => line.style_dotted
        =>                 line.style_solid

// @function        Opaque plate or none, depending on the setting.
// @param on        (bool) Whether the plate is switched on.
// @returns         (series color) Label background colour.
labelPlate(bool on) =>
    color.new(chart.bg_color, on ? 0 : 100)

// @function        Vertical anchor of a session label for the chosen spot.
// @param spot      (LabelSpot) Position picked in the settings.
// @param hi        (float) Session high.
// @param lo        (float) Session low.
// @returns         (series float) Price the label is anchored to.
labelAnchor(LabelSpot spot, float hi, float lo) =>
    switch spot
        LabelSpot.belowBox  => lo
        LabelSpot.insideBox => math.avg(hi, lo)
        =>                     hi

// @function        Label style that puts the text on the intended side.
// @param spot      (LabelSpot) Position picked in the settings.
// @returns         (series string) Matching `label.style_*` constant.
labelStyleOf(LabelSpot spot) =>
    switch spot
        LabelSpot.belowBox  => label.style_label_up
        LabelSpot.insideBox => label.style_label_center
        =>                     label.style_label_down

// @function        Whether a session window wraps past midnight.
// @param spec      (simple string) Session specification, e.g. "1800-0200".
// @returns         (simple bool) True when the window really crosses midnight.
//                  Derived from the window itself, never from the first bar
//                  that happened to fall inside it. A window that ends exactly
//                  at "0000" stops on the boundary instead of crossing it, so
//                  it does not count as wrapping and keeps the day guard armed.
windowWraps(simple string spec) =>
    int endMin = windowEnd(spec)
    windowStart(spec) > endMin and endMin != 0

// @function        Removes every drawing of a session that is being dropped.
// @param sess      (Session) Session being discarded.
// @returns         (void)
clearSession(Session sess) =>
    box.delete(sess.area)
    label.delete(sess.tag)
    line.delete(sess.highLine)
    line.delete(sess.lowLine)
    sess.area     := na
    sess.tag      := na
    sess.highLine := na
    sess.lowLine  := na

// @function        Removes every drawing of a time marker that is being dropped.
// @param mark      (TimeMark) Marker being discarded.
// @returns         (void)
clearMark(TimeMark mark) =>
    line.delete(mark.mark)
    label.delete(mark.tag)
    mark.mark := na
    mark.tag  := na

//#endregion

//#region CALCULATIONS =========================================================

var array<Session>  sessions = array.new<Session>()
var array<TimeMark> marks    = array.new<TimeMark>()
var array<Session>  openNow  = array.new<Session>(SLOT_COUNT, na)

// Session membership has to come from the window state, never from an exact
// clock comparison - a 45m chart never lands on 07:00 (brief, item 5).
bool inAsia     = not na(time(timeframe.period, asiaTimeInput, TZ_NEW_YORK))
bool inLondon   = not na(time(timeframe.period, londonTimeInput, TZ_NEW_YORK))
bool inNyAm     = not na(time(timeframe.period, nyAmTimeInput, TZ_NEW_YORK))
bool inLdnClose = not na(time(timeframe.period, ldnCloseTimeInput, TZ_NEW_YORK))
bool inNyPm     = not na(time(timeframe.period, nyPmTimeInput, TZ_NEW_YORK))

bool inMidnight = not na(time(timeframe.period, WIN_MIDNIGHT, TZ_NEW_YORK))
bool inTrueDay  = not na(time(timeframe.period, WIN_TRUE_DAY, TZ_NEW_YORK))
bool inRth      = not na(time(timeframe.period, WIN_RTH, TZ_NEW_YORK))

var array<bool> insideNow = array.new<bool>(SLOT_COUNT, false)
array.set(insideNow, SLOT_ASIA, inAsia)
array.set(insideNow, SLOT_LONDON, inLondon)
array.set(insideNow, SLOT_NY_AM, inNyAm)
array.set(insideNow, SLOT_LDN_CLOSE, inLdnClose)
array.set(insideNow, SLOT_NY_PM, inNyPm)

var array<bool> markInside = array.new<bool>(MARK_COUNT, false)
array.set(markInside, MARK_MIDNIGHT, inMidnight)
array.set(markInside, MARK_TRUE_DAY, inTrueDay)
array.set(markInside, MARK_RTH, inRth)

// Instrument classes: what is undefined is not drawn, and the panel says so.
bool isForex   = syminfo.type == "forex"
bool isCrypto  = syminfo.type == "crypto"
bool isCfd     = syminfo.type == "cfd"
bool rthDefined = not (isForex or isCrypto or isCfd)

var array<bool> slotEnabled = array.new<bool>(SLOT_COUNT, false)
array.set(slotEnabled, SLOT_ASIA, showAsiaInput)
array.set(slotEnabled, SLOT_LONDON, showLondonInput)
array.set(slotEnabled, SLOT_NY_AM, showNyAmInput)
array.set(slotEnabled, SLOT_LDN_CLOSE, showLdnCloseInput)
array.set(slotEnabled, SLOT_NY_PM, showNyPmInput)

var array<bool> markEnabled = array.new<bool>(MARK_COUNT, false)
array.set(markEnabled, MARK_MIDNIGHT, showMidnightInput)
array.set(markEnabled, MARK_TRUE_DAY, showTrueDayInput and rthDefined)
array.set(markEnabled, MARK_RTH, showRthInput and rthDefined)

// time() returns the bar's UNIX timestamp; the timezone argument only decides
// WHICH bars fall inside the window, it does not shift the value. A day index
// built from it rolls at 00:00 UTC, which is 19:00 or 20:00 New York time.
// Hence a counter of our own, keyed on the New York calendar day.
var int  tradingDay = 0
var int  lastNyDate = na
int  nyDate = dayofmonth(time, TZ_NEW_YORK)
if na(lastNyDate)
    lastNyDate := nyDate
else if nyDate != lastNyDate
    tradingDay := tradingDay + 1
    lastNyDate := nyDate

bool intradayOk  = timeframe.in_seconds() <= MAX_INTRADAY_SEC
bool advanceNow  = barstate.isconfirmed and intradayOk

// Day bookkeeping for the early-close and holiday findings. A day is only ever
// classified once it is over - otherwise every morning would read "Early close".
var int   currentDay   = na
var int   currentDow   = na
var int   lastRthSec   = na
var bool  sawRthToday  = false
var bool  prevEarly    = false
var bool  prevNoRth    = false
int  minuteOfDay = hour(time, TZ_NEW_YORK) * 60 + minute(time, TZ_NEW_YORK)

// --- Session lifecycle ---
// These functions live below the inputs and arrays they work on (HOUSE-STYLE A.8).

// @function        Freezes a session: its high and low never move again.
// @param sess      (Session) Session that just ended.
// @returns         (void)
completeSession(Session sess) =>
    sess.state     := STATE_COMPLETE
    sess.highState := STATE_COMPLETE
    sess.lowState  := STATE_COMPLETE

// @function        Applies the current bar to one session's fixed levels.
// @param sess      (Session) Session to test.
// @returns         ([bool, bool]) Whether the high and the low were taken now.
// Dependencies     takeBasisInput
takeLevels(Session sess) =>
    bool tookHigh = false
    bool tookLow  = false
    if sess.state == STATE_COMPLETE
        bool  wick      = takeBasisInput == TakeBasis.wickThrough
        float upPrice   = wick ? high : close
        float downPrice = wick ? low : close
        if sess.highState == STATE_COMPLETE and passedLevel(true, upPrice, sess.high)
            sess.highState    := STATE_TAKEN
            sess.highTakenBar := bar_index
            tookHigh          := true
        if sess.lowState == STATE_COMPLETE and passedLevel(false, downPrice, sess.low)
            sess.lowState    := STATE_TAKEN
            sess.lowTakenBar := bar_index
            tookLow          := true
    [tookHigh, tookLow]

// Once per chart: does this window run past midnight? That property belongs to
// the configured window, not to whichever bar first fell inside it.
var array<bool> slotWraps = array.new<bool>(SLOT_COUNT, false)
var array<int>  slotStart = array.new<int>(SLOT_COUNT, 0)
if barstate.isfirst
    array.set(slotWraps, SLOT_ASIA, windowWraps(asiaTimeInput))
    array.set(slotWraps, SLOT_LONDON, windowWraps(londonTimeInput))
    array.set(slotWraps, SLOT_NY_AM, windowWraps(nyAmTimeInput))
    array.set(slotWraps, SLOT_LDN_CLOSE, windowWraps(ldnCloseTimeInput))
    array.set(slotWraps, SLOT_NY_PM, windowWraps(nyPmTimeInput))
    array.set(slotStart, SLOT_ASIA, windowStart(asiaTimeInput))
    array.set(slotStart, SLOT_LONDON, windowStart(londonTimeInput))
    array.set(slotStart, SLOT_NY_AM, windowStart(nyAmTimeInput))
    array.set(slotStart, SLOT_LDN_CLOSE, windowStart(ldnCloseTimeInput))
    array.set(slotStart, SLOT_NY_PM, windowStart(nyPmTimeInput))

var array<bool> markWasIn      = array.new<bool>(MARK_COUNT, false)
var array<int>  markNewestDay = array.new<int>(MARK_COUNT, na)

bool sessionOpenedNow = false
bool sessionClosedNow = false
bool highTakenNow     = false
bool lowTakenNow      = false
string takeText       = ""
int    takeCount      = 0

if advanceNow
    if array.size(sessions) > 0
        for i = 0 to array.size(sessions) - 1
            Session sess = array.get(sessions, i)
            [tookHigh, tookLow] = takeLevels(sess)
            if tookHigh
                takeCount := takeCount + 1
                takeText  := appendTake(takeText, slotName(sess.slot), true, sess.high, takeCount)
            if tookLow
                takeCount := takeCount + 1
                takeText  := appendTake(takeText, slotName(sess.slot), false, sess.low, takeCount)
            highTakenNow := highTakenNow or tookHigh
            lowTakenNow  := lowTakenNow or tookLow

    for slot = 0 to SLOT_COUNT - 1
        bool    inside  = array.get(insideNow, slot) and array.get(slotEnabled, slot)
        Session current = array.get(openNow, slot)
        // Which trading day this bar belongs to WITHIN its window. For a window
        // that wraps past midnight, the hours after midnight still belong to
        // the day the window opened on, so a bar there does not end the box.
        // Everything else keeps the day guard: a window that only looks
        // continuous because the chart has no bars in between is not one box.
        bool wraps   = array.get(slotWraps, slot)
        int  slotDay = not wraps or minuteOfDay >= array.get(slotStart, slot)
          ? tradingDay
          : tradingDay - 1
        // Never read a field inside an and-chain: Pine evaluates both sides.
        if not na(current)
            if inside and current.day != slotDay
                completeSession(current)
                array.set(openNow, slot, na)
                sessionClosedNow := true
                // Here too, the closing bar can already take what it just froze.
                [dayTookHigh, dayTookLow] = takeLevels(current)
                if dayTookHigh
                    takeCount := takeCount + 1
                    takeText  := appendTake(
                      takeText, slotName(current.slot), true, current.high, takeCount)
                if dayTookLow
                    takeCount := takeCount + 1
                    takeText  := appendTake(
                      takeText, slotName(current.slot), false, current.low, takeCount)
                highTakenNow := highTakenNow or dayTookHigh
                lowTakenNow  := lowTakenNow or dayTookLow
                current := na
        if inside
            if na(current)
                Session born = Session.new(
                  slot        = slot,
                  day         = slotDay,
                  startBar    = bar_index,
                  endBar      = bar_index,
                  high        = high,
                  low         = low,
                  state       = STATE_FORMING,
                  highState   = STATE_FORMING,
                  lowState    = STATE_FORMING)
                array.push(sessions, born)
                array.set(openNow, slot, born)
                sessionOpenedNow := true
            else
                current.endBar := bar_index
                current.high   := math.max(current.high, high)
                current.low    := math.min(current.low, low)
        else if not na(current)
            completeSession(current)
            array.set(openNow, slot, na)
            sessionClosedNow := true
            // The bar that ended the session can already take what it froze.
            [tookHigh, tookLow] = takeLevels(current)
            if tookHigh
                takeCount := takeCount + 1
                takeText  := appendTake(
                  takeText, slotName(current.slot), true, current.high, takeCount)
            if tookLow
                takeCount := takeCount + 1
                takeText  := appendTake(
                  takeText, slotName(current.slot), false, current.low, takeCount)
            highTakenNow := highTakenNow or tookHigh
            lowTakenNow  := lowTakenNow or tookLow

    for slot = 0 to MARK_COUNT - 1
        bool inside = array.get(markInside, slot)
        if array.get(markEnabled, slot) and inside and not array.get(markWasIn, slot)
            // True Day Open is anchored at 18:00 and opens the FOLLOWING trading
            // day - it must live through that day, not expire at midnight.
            int markDay = slot == MARK_TRUE_DAY ? tradingDay + 1 : tradingDay
            array.push(marks, TimeMark.new(slot, markDay, bar_index, bar_index, open))
        array.set(markWasIn, slot, inside)

    // Which day is the newest mark of each slot? Not simply `tradingDay`: True
    // Day Open is stamped with the FOLLOWING day, so between 18:00 and midnight
    // no mark of that slot carries today's number. Growing the right edge on
    // `== tradingDay` left the fresh marker a zero-length line without a label
    // for six hours, while yesterday's marker still wore the tag.
    for slot = 0 to MARK_COUNT - 1
        array.set(markNewestDay, slot, na)
    if array.size(marks) > 0
        for i = 0 to array.size(marks) - 1
            TimeMark mark = array.get(marks, i)
            int seen = array.get(markNewestDay, mark.slot)
            if na(seen) or mark.day > seen
                array.set(markNewestDay, mark.slot, mark.day)

    // A marker runs from its anchor until the next marker of the SAME slot is
    // born - not to the chart edge, and not to the end of the calendar day.
    // The day boundary would be wrong for True Day Open, which opens at 18:00
    // and belongs to the following trading day; and under the old rule the RTH
    // marker carried no label between midnight and 09:30 either.
    if array.size(marks) > 0
        for i = 0 to array.size(marks) - 1
            TimeMark mark = array.get(marks, i)
            if mark.day == array.get(markNewestDay, mark.slot)
                mark.endBar := bar_index

    // A day is classified only once it is over.
    if not na(currentDay) and tradingDay != currentDay
        // In seconds, not minutes: on a 30s chart the last regular bar starts
        // at 15:59:30, and a minute-resolution check would call every day short.
        // A future trading on Sunday evening without an RTH session is not a
        // holiday. Only a weekday can be one.
        bool wasWeekday = currentDow != dayofweek.saturday and currentDow != dayofweek.sunday
        bool closedShort = sawRthToday and not na(lastRthSec)
          and lastRthSec + timeframe.in_seconds() < RTH_END_SECOND
        prevNoRth   := rthDefined and wasWeekday and not sawRthToday
        prevEarly   := rthDefined and closedShort
        sawRthToday := false
        lastRthSec  := na
    currentDay := tradingDay
    currentDow := dayofweek(time, TZ_NEW_YORK)
    if inRth
        sawRthToday := true
        lastRthSec  := minuteOfDay * 60 + second(time, TZ_NEW_YORK)

    // "Days Retained = 2" means two days, not three.
    int oldestDay = tradingDay - daysRetainedInput + 1
    // Plus one: the retention only runs on confirmed bars, VISUALS on every one.
    // Kept exactly at `bar_index - X_MIN_OFFSET`, the same object would sit at
    // `bar_index - X_MIN_OFFSET - 1` on the next unconfirmed bar - one past the
    // smallest x-coordinate Pine allows (PINE-FEATURES 1.7).
    int oldestBar = bar_index - X_MIN_OFFSET + 1
    if array.size(sessions) > 0
        for i = array.size(sessions) - 1 to 0
            Session sess = array.get(sessions, i)
            Session held = array.get(openNow, sess.slot)
            // Identity, not just the day: two sessions of one slot can never
            // share a start bar, so this pins the very object.
            bool stillOpen = na(held) ? false
              : held.day == sess.day and held.startBar == sess.startBar
            // Objects that are too old are discarded, not clamped: a clamped
            // box would have zero width somewhere it never was. The session
            // that is still taking bars is exempt from the DAY cutoff: a window
            // that wraps past midnight opens on the previous trading day, so at
            // `Days Retained = 1` its own day is already older than the cutoff.
            // Without the exemption it would be born and discarded on every bar
            // after midnight - no box at all, and "session opened" firing on
            // each one. The coordinate limit stays absolute; nothing may be
            // drawn beyond it.
            if (sess.day < oldestDay and not stillOpen) or sess.startBar < oldestBar
                if stillOpen
                    array.set(openNow, sess.slot, na)
                clearSession(sess)
                array.remove(sessions, i)
    if array.size(marks) > 0
        for i = array.size(marks) - 1 to 0
            TimeMark mark = array.get(marks, i)
            if mark.day < oldestDay or mark.anchorBar < oldestBar
                clearMark(mark)
                array.remove(marks, i)

int  offsetHours   = regionOffsetHours()
bool transitionWk  = offsetHours != REGULAR_OFFSET

//#endregion

//#region VISUALS ==============================================================

// @function        Draws or updates one session, reusing its objects.
// @param sess      (Session) Session to render.
// @returns         (void)
// Dependencies     the display and style inputs
renderSession(Session sess) =>
    bool  forming = sess.state == STATE_FORMING
    color base    = slotColor(sess.slot)
    color fill    = color.new(base, forming ? formingFadeInput : boxFadeInput)
    int   left    = sess.startBar
    int   right   = math.max(sess.endBar, left)
    if na(sess.area)
        sess.area := box.new(left, sess.high, right, sess.low, border_color = base, bgcolor = fill)
    box.set_lefttop(sess.area, left, sess.high)
    box.set_rightbottom(sess.area, right, sess.low)
    box.set_border_color(sess.area, base)
    box.set_border_style(sess.area, forming ? line.style_dashed : line.style_solid)
    box.set_bgcolor(sess.area, fill)
    if showSessLabelInput
        // Centred on the box width; the vertical side is the user's choice.
        int   mid    = math.round(math.avg(left, right))
        float anchor = labelAnchor(sessLabelSpotInput, sess.high, sess.low)
        if na(sess.tag)
            sess.tag := label.new(
              mid, anchor, slotName(sess.slot),
              style     = labelStyleOf(sessLabelSpotInput),
              color     = labelPlate(labelPlateInput),
              textcolor = chart.fg_color,
              size      = textSizeInput)
        label.set_color(sess.tag, labelPlate(labelPlateInput))
        label.set_xy(sess.tag, mid, anchor)
        label.set_style(sess.tag, labelStyleOf(sessLabelSpotInput))
        label.set_size(sess.tag, textSizeInput)
        // Pine types both branches of an if even when nothing reads the result;
        // the bare na keeps them compatible (CE10235).
        na
    else
        label.delete(sess.tag)
        sess.tag := na
    if showLevelsInput
        // While the session is running, its levels stay inside the box.
        int highRight = forming ? right
          : sess.highState == STATE_TAKEN ? sess.highTakenBar
          : extendLevelsInput ? bar_index : right
        int lowRight  = forming ? right
          : sess.lowState == STATE_TAKEN ? sess.lowTakenBar
          : extendLevelsInput ? bar_index : right
        color highCol = color.new(base, sess.highState == STATE_TAKEN ? 55 : 0)
        color lowCol  = color.new(base, sess.lowState == STATE_TAKEN ? 55 : 0)
        if na(sess.highLine)
            sess.highLine := line.new(
              left, sess.high, highRight, sess.high,
              width = levelWidthInput)
            sess.lowLine := line.new(
              left, sess.low, lowRight, sess.low,
              width = levelWidthInput)
        line.set_xy1(sess.highLine, left, sess.high)
        line.set_xy2(sess.highLine, math.max(highRight, left), sess.high)
        line.set_color(sess.highLine, highCol)
        line.set_xy1(sess.lowLine, left, sess.low)
        line.set_xy2(sess.lowLine, math.max(lowRight, left), sess.low)
        line.set_color(sess.lowLine, lowCol)
        line.set_style(sess.highLine, lineStyleOf(levelLookInput))
        line.set_style(sess.lowLine, lineStyleOf(levelLookInput))
        // Pine types both branches of an if even when nothing reads the result;
        // the bare na keeps them compatible (CE10235).
        na
    else
        line.delete(sess.highLine)
        line.delete(sess.lowLine)
        sess.highLine := na
        sess.lowLine  := na

// @function        Draws or updates one time marker.
// @param mark      (TimeMark) Marker to render.
// @param newest    (bool) True when this marker belongs to the current day.
// @returns         (void)
// Dependencies     markWidthInput, markExtendInput, textSizeInput
renderMark(TimeMark mark, bool newest) =>
    color base  = markColor(mark.slot)
    int   left  = mark.anchorBar
    // Only the newest marker of a type runs past the latest candle, so its
    // line and label sit in front of the price action instead of behind it.
    // Older markers still end where the next one of the same type begins.
    int   right = math.max(mark.endBar, left) + (newest ? markExtendInput : 0)
    if na(mark.mark)
        mark.mark := line.new(
          left, mark.price, right, mark.price,
          color = base,
          width = markWidthInput)
    line.set_xy1(mark.mark, left, mark.price)
    line.set_xy2(mark.mark, right, mark.price)
    line.set_color(mark.mark, base)
    line.set_width(mark.mark, markWidthInput)
    line.set_style(mark.mark, lineStyleOf(markLookInput))
    // Only the most recent day carries a label - otherwise the labels of every
    // retained day stack up on the same edge.
    if newest
        if na(mark.tag)
            mark.tag := label.new(
              right, mark.price, markName(mark.slot),
              style     = label.style_label_left,
              color     = labelPlate(labelPlateInput),
              textcolor = chart.fg_color,
              size      = textSizeInput)
        label.set_color(mark.tag, labelPlate(labelPlateInput))
        label.set_xy(mark.tag, right, mark.price)
        label.set_size(mark.tag, textSizeInput)
        // Pine types both branches of an if even when nothing reads the result;
        // the bare na keeps them compatible (CE10235).
        na
    else
        label.delete(mark.tag)
        mark.tag := na

// --- Draw everything that survived retention ---

if array.size(sessions) > 0
    for i = 0 to array.size(sessions) - 1
        Session sess = array.get(sessions, i)
        if array.get(slotEnabled, sess.slot) and intradayOk
            renderSession(sess)
        else
            clearSession(sess)

if array.size(marks) > 0
    for i = 0 to array.size(marks) - 1
        TimeMark mark = array.get(marks, i)
        if array.get(markEnabled, mark.slot) and intradayOk
            renderMark(mark, mark.day == array.get(markNewestDay, mark.slot))
        else
            clearMark(mark)

// The single panel of this script. It reports the time state; it never
// changes where anything is drawn.
var table panel = table.new(position.top_right, 1, 3)
if barstate.islast
    table.set_position(panel, panelPosition(panelSpotInput))
    table.clear(panel, 0, 0, 0, 2)
    if not intradayOk
        table.cell(
          panel, 0, 0, NOTE_TIMEFRAME,
          text_color = chart.fg_color,
          text_size  = textSizeInput)
    else if showPanelInput
        string running = LABEL_NONE
        for slot = 0 to SLOT_COUNT - 1
            if array.get(insideNow, slot) and array.get(slotEnabled, slot)
                running := slotName(slot)
        string offsetText = LABEL_OFFSET + str.tostring(offsetHours) + "h"
          + (transitionWk ? LABEL_TRANSITION : "")
        string condition = prevNoRth ? LABEL_NO_RTH : prevEarly ? LABEL_EARLY : ""
        if not rthDefined
            condition := NOTE_NO_RTH_TYPE
        color offsetColor = transitionWk ? ALERT_COLOR : chart.fg_color
        table.cell(
          panel, 0, 0, running,
          text_color = chart.fg_color,
          text_size  = textSizeInput)
        table.cell(
          panel, 0, 1, offsetText,
          text_color = offsetColor,
          text_size  = textSizeInput)
        if str.length(condition) > 0
            table.cell(
              panel, 0, 2, condition,
              text_color = chart.fg_color,
              text_size  = textSizeInput)

//#endregion

//#region ALERTS ===============================================================

bool openAlertNow  = sessionOpenedNow and alertOpenInput
bool closeAlertNow = sessionClosedNow and alertCloseInput
bool highAlertNow  = highTakenNow and alertTakenInput
bool lowAlertNow   = lowTakenNow and alertTakenInput

alertcondition(openAlertNow, title = EVENT_SESSION_OPEN, message = MSG_SESSION_OPEN)
alertcondition(closeAlertNow, title = EVENT_SESSION_CLOSE, message = MSG_SESSION_CLOSE)
alertcondition(highAlertNow, title = EVENT_HIGH_TAKEN, message = MSG_HIGH_TAKEN)
alertcondition(lowAlertNow, title = EVENT_LOW_TAKEN, message = MSG_LOW_TAKEN)

// alertcondition() can only carry a fixed string, but the brief asks the text
// to name the session and the level - that needs alert(). The text was built
// take by take, so every fragment names a level that really was taken.
if (highAlertNow or lowAlertNow) and takeText != ""
    alert(takeText, alert.freq_once_per_bar_close)

//#endregion
````
