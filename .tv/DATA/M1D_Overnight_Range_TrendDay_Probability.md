<!-- tradingview-pine-id: PUB;330571906a5b43b6a4ba45aa9d73bca4 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# M1D — Overnight Range & Trend-Day Probability

Source: https://www.tradingview.com/script/mOIFHBMY-Overnight-Range-Trend-Day-Probability/

## Description

Overnight Range & Trend-Day Probability 
Grades the coming cash session before it opens. It measures the overnight block, compares it to the instrument's average daily range, and answers one question: has today's expansion already happened overnight, or is it statistically still ahead?

The bias read

The overnight block runs from the Asia open to the cash open and freezes there. Its height is compared against the average daily range (ADR) to produce a trend-day grade:

[*]A small overnight range relative to ADR means the day's expansion is statistically still ahead — graded HIGH.
[*]A mid-sized overnight range grades MEDIUM.
[*]A large overnight range means the move may have already been spent overnight, favouring range-bound or reversal conditions — graded LOW.

The grade always prints with the number that produced it, so the read is verifiable at a glance rather than a bare word. A directional lean accompanies it, taken from where price trades relative to the open anchors — all above reads bullish, all below reads bearish, split reads mixed, with the vote count shown. An optional modifier flags when the week has already consumed most of its average weekly range.

What it draws

[*]The overnight range block — grows through the night, freezes at the cash open.
[*]Open-anchor lines — Midnight Open, News Open, Cash Open — each on its own custom time, extending to the cash close.
[*]AR projection lines — the anchor open ± ADR, with optional 1/3 and 2/3 ADR levels and optional ± AWR lines. The anchor is selectable: Midnight Open, Cash Open, or Asia Open.
[*]An on-chart bias label with the full read in one line.
[*]A compact table: the trend-day verdict first, then the lean, the overnight range, and the Asia share of the overnight block. Threshold arithmetic lives in the cell tooltips.

The chart carries one day at a time — the previous day's drawings clear the moment a new session begins.

Asia decomposition

The overnight block merges Asia, the dead zone, London, and pre-NY. This engine isolates the Asia kill zone portion and reports it as a share of the whole block, classified as Normal, Elevated, or Inverted against adjustable thresholds. An inverted reading — Asia doing the expansion leg instead of accumulating — is readable directly from the table. The verdict resolves at the cash-open freeze, since the share is undefined while Asia still is the whole block.

Settings

[*]Every session time is a custom input: the overnight block bounds, each open anchor, the Asia kill zone clock, and four optional session range boxes (Asia, London KZ, dead zone, NY AM KZ) — each drawn only across its own session high-low with its name on top, never as a full-height background tint. All off by default, each with its own colour.
[*]ADR and AWR lookbacks are adjustable.
[*]The probability thresholds, the Asia decomposition thresholds, and the exhaustion alert level are all adjustable.

Alerts

[*]Trend-day probability finalised at the cash-open freeze.
[*]Price crossing the Midnight Open or the Cash Open.
[*]Overnight range exhaustion against ADR.

All session logic runs on New York time with daylight saving handled automatically. Detection runs on confirmed bars only, so nothing repaints. Works across all instruments and timeframes — designed for price delivery analysis on MNQ, MES, MYM, XAU/USD, and related markets.

Disclaimer
This indicator is a chart analysis tool, not financial advice. It identifies price levels and statistical tendencies; it does not predict the market or generate trade signals. Always do your own analysis and manage your own risk.

---

## Source Code

````pine
//@version=6
// ============================================================================
// M1D — Overnight Range & Trend-Day Probability
// ----------------------------------------------------------------------------
// Tracks the overnight block (Asia open -> cash open), grades the coming
// session's trend-day probability from how much of the average daily range the
// overnight already spent, and reads a directional lean from price against the
// open anchors. Draws the ON range block, the open-anchor lines, AR projection
// lines (anchor open ± ADR, optional 1/3 & 2/3 ADR and ± AWR) and a compact
// bias table — verdict first, supporting rows beneath, arithmetic in tooltips.
// One day at a time: the previous day's drawings clear at each new NY day.
//
// DESIGN NOTES:
//  1. "Points" = raw price difference in quote units; no mintick scaling.
//  2. All session logic runs on "America/New_York"; DST handled by TradingView.
//  3. The overnight block spans Asia open -> Cash open and includes the
//     01:00-02:00 untracked hour. Globex trades through it; intended.
//  4. Detection/freezing runs on barstate.isconfirmed (anti-repaint).
//  5. Anchors capture from the open of the first confirmed bar at/after the
//     anchor time, within "Max capture lag".
// ============================================================================
indicator("M1D — Overnight Range & Trend-Day Probability", "M1D ON/TDP", overlay = true, max_lines_count = 100, max_labels_count = 100, max_boxes_count = 50)

// == CONSTANTS ===============================================================

//@variable Exchange-independent New York clock used by every time function
const string TZ = "America/New_York"
//@variable Number of tracked open anchors (Midnight / News / Cash)
const int ANCHOR_COUNT = 3
const string BUILD = "v3-b8"

// == INPUTS — OPEN ANCHORS ===================================================

bool  showMidnight   = input.bool(true, "Midnight Open", group = "Open Anchors")
int   midnightHour   = input.int(0,  "Midnight Open — hour", minval = 0, maxval = 23, group = "Open Anchors", inline = "mo")
int   midnightMinute = input.int(0,  "min",                  minval = 0, maxval = 59, group = "Open Anchors", inline = "mo")
bool  showNewsOpen   = input.bool(true, "News Open", group = "Open Anchors")
int   newsHour       = input.int(8,  "News Open — hour",     minval = 0, maxval = 23, group = "Open Anchors", inline = "no")
int   newsMinute     = input.int(30, "min",                  minval = 0, maxval = 59, group = "Open Anchors", inline = "no")
bool  showCashOpen   = input.bool(true, "Cash Open", group = "Open Anchors")
int   cashHour       = input.int(9,  "Cash Open — hour",     minval = 0, maxval = 23, group = "Open Anchors", inline = "co")
int   cashMinute     = input.int(30, "min",                  minval = 0, maxval = 59, group = "Open Anchors", inline = "co")
int   maxCaptureLag  = input.int(60, "Max capture lag (min)", minval = 1, maxval = 240, group = "Open Anchors", tooltip = "An anchor is only captured if the first bar at/after the anchor time starts within this many minutes of it. Prevents a mid-day chart start or a data gap from stamping a false anchor.")

// == INPUTS — OVERNIGHT BLOCK ================================================

int  asiaOpenHour   = input.int(18, "ON block opens — hour", minval = 0, maxval = 23, group = "Overnight Block", inline = "onO")
int  asiaOpenMinute = input.int(0,  "min",                   minval = 0, maxval = 59, group = "Overnight Block", inline = "onO")
int  rthCloseHour   = input.int(16, "Anchor lines stop — hour", minval = 0, maxval = 23, group = "Overnight Block", inline = "rthC", tooltip = "The cash close: where the open-anchor lines and their labels stop extending.")
int  rthCloseMinute = input.int(14, "min",                   minval = 0, maxval = 59, group = "Overnight Block", inline = "rthC")
bool showOnBlock    = input.bool(true, "Draw the ON Range block", group = "Overnight Block", tooltip = "The overnight box, Asia open -> cash open. Its height IS the ON Range the bias is computed from.")
color onBlockColor  = input.color(color.new(color.gray, 88), "ON block fill (border matches)", group = "Overnight Block")

// == INPUTS — RANGE METRICS ==================================================

int adrLength = input.int(9, "ADR lookback (days)",  minval = 1, maxval = 60, group = "Range Metrics", tooltip = "Number of completed daily ranges averaged into the ADR.")
int awrLength = input.int(9, "AWR lookback (weeks)", minval = 1, maxval = 60, group = "Range Metrics", tooltip = "Feeds the AWR-spent modifier only — nothing is drawn from it.")

// == INPUTS — ASIA DECOMPOSITION =============================================
// This engine owns its own clock — the ICT Asia KILL ZONE bounds, deliberately
// separate from any session-tint window.

bool  showDecomp    = input.bool(true, "Show Asia decomposition", group = "Asia Decomposition")
int   asiaKzOpenHr  = input.int(18, "Asia KZ open — hour",  minval = 0, maxval = 23, group = "Asia Decomposition", inline = "akzO")
int   asiaKzOpenMn  = input.int(0,  "min",                  minval = 0, maxval = 59, group = "Asia Decomposition", inline = "akzO")
int   asiaKzCloseHr = input.int(22, "Asia KZ close — hour", minval = 0, maxval = 23, group = "Asia Decomposition", inline = "akzC")
int   asiaKzCloseMn = input.int(0,  "min",                  minval = 0, maxval = 59, group = "Asia Decomposition", inline = "akzC")
float elevatedPct   = input.float(30.0, "Elevated above (% of ON)", minval = 1.0, maxval = 100.0, step = 1.0, group = "Asia Decomposition")
float invertedPct   = input.float(50.0, "Inverted above (% of ON)", minval = 1.0, maxval = 100.0, step = 1.0, group = "Asia Decomposition")

// == INPUTS — PROBABILITY ENGINE =============================================

float lowThreshold  = input.float(35.0, "HIGH below ON % of ADR",  minval = 1.0,  maxval = 200.0, step = 1.0, group = "Probability Engine")
float highThreshold = input.float(65.0, "LOW above ON % of ADR",   minval = 1.0,  maxval = 300.0, step = 1.0, group = "Probability Engine")
bool  useAwrMod     = input.bool(true,  "AWR-spent modifier",      group = "Probability Engine")
float wtdThreshold  = input.float(80.0, "WTD % of AWR threshold",  minval = 1.0,  maxval = 300.0, step = 1.0, group = "Probability Engine")
float exhaustPct    = input.float(85.0, "ON exhaustion alert (% of ADR)", minval = 1.0, maxval = 300.0, step = 1.0, group = "Probability Engine")
bool  showProbLabel = input.bool(true,  "On-chart bias label", group = "Probability Engine")

// == INPUTS — AR PROJECTIONS =================================================
// The ADR/AWR projection lines: anchor open ± the average range, so the bias
// read and its targets live on one script.

bool   showAr       = input.bool(true, "Show AR lines (anchor ± ADR)", group = "AR Projections")
string arAnchorIn   = input.string("Midnight Open", "AR anchor", options = ["Midnight Open", "Cash Open", "Asia Open"], group = "AR Projections", tooltip = "The open the projections measure from. Midnight Open is the ICT true-day anchor.")
bool   showArThirds = input.bool(false, "Show 1/3 and 2/3 ADR levels", group = "AR Projections")
bool   showAwrLines = input.bool(false, "Show ± AWR lines", group = "AR Projections")
color  arColor      = input.color(color.new(#000000, 0), "AR line colour", group = "AR Projections")

// == INPUTS — SESSION RANGE BOXES ============================================
// Each enabled session draws a box bounding only its own high-low, from session
// start to session end — never a full-height background tint. Asia uses the
// Session Decomposition clock; the other three own their times below.

bool  showAsiaBox  = input.bool(false, "Asia range box",   group = "Session Range Boxes", inline = "sAsia")
color asiaBoxCol   = input.color(color.new(#1E90FF, 0), "col", group = "Session Range Boxes", inline = "sAsia")
bool  showLokzBox  = input.bool(false, "London range box", group = "Session Range Boxes", inline = "sLokz")
color lokzBoxCol   = input.color(color.new(#CC0000, 0), "col", group = "Session Range Boxes", inline = "sLokz")
int   lokzStartHour = input.int(2, "London KZ start — hour", minval = 0, maxval = 23, group = "Session Range Boxes", inline = "lokzS")
int   lokzStartMin_ = input.int(0, "min",                    minval = 0, maxval = 59, group = "Session Range Boxes", inline = "lokzS")
int   lokzEndHour   = input.int(5, "London KZ end — hour",   minval = 0, maxval = 23, group = "Session Range Boxes", inline = "lokzE")
int   lokzEndMin_   = input.int(0, "min",                    minval = 0, maxval = 59, group = "Session Range Boxes", inline = "lokzE")
bool  showDeadBox  = input.bool(false, "Dead zone box",    group = "Session Range Boxes", inline = "sDead")
color deadBoxCol   = input.color(color.new(color.gray, 0), "col", group = "Session Range Boxes", inline = "sDead")
int   deadStartHour = input.int(5, "Dead zone start — hour", minval = 0, maxval = 23, group = "Session Range Boxes", inline = "deadS")
int   deadStartMin_ = input.int(0, "min",                    minval = 0, maxval = 59, group = "Session Range Boxes", inline = "deadS")
int   deadEndHour   = input.int(6, "Dead zone end — hour",   minval = 0, maxval = 23, group = "Session Range Boxes", inline = "deadE")
int   deadEndMin_   = input.int(0, "min",                    minval = 0, maxval = 59, group = "Session Range Boxes", inline = "deadE")
bool  showNyKzBox  = input.bool(false, "NY AM range box",  group = "Session Range Boxes", inline = "sNyKz")
color nyKzBoxCol   = input.color(color.new(#00A83E, 0), "col", group = "Session Range Boxes", inline = "sNyKz")
int   nyKzStartHour = input.int(9,  "NY AM KZ start — hour", minval = 0, maxval = 23, group = "Session Range Boxes", inline = "nykzS")
int   nyKzStartMin_ = input.int(30, "min",                   minval = 0, maxval = 59, group = "Session Range Boxes", inline = "nykzS")
int   nyKzEndHour   = input.int(11, "NY AM KZ end — hour",   minval = 0, maxval = 23, group = "Session Range Boxes", inline = "nykzE")
int   nyKzEndMin_   = input.int(0,  "min",                   minval = 0, maxval = 59, group = "Session Range Boxes", inline = "nykzE")

// == INPUTS — VISUALS & TABLE ================================================

color  anchorColor   = input.color(color.new(#000000, 0), "Anchor line colour", group = "Visuals")
color  bullColor     = input.color(color.new(#7246CE, 0), "Bullish text colour", group = "Visuals")
color  bearColor     = input.color(color.new(#DB1D9C, 0), "Bearish text colour", group = "Visuals")
bool   showAnchorLbl = input.bool(true, "Show anchor labels", group = "Visuals")
int    lineExtendBars = input.int(15, "Line right extension (bars)", minval = 0, maxval = 100, group = "Visuals", tooltip = "How far every anchor and AR line runs past the live candle. Labels sit past the line ends.")
int    labelGapBars  = input.int(2, "Label gap from line ends (bars)", minval = 1, maxval = 50, group = "Visuals")
string labelSizeIn   = input.string("small", "Label size", options = ["tiny", "small", "normal"], group = "Visuals")
float  lblClearance  = input.float(0.25, "Label clearance (x ATR14)", minval = 0.05, maxval = 1.0, step = 0.05, group = "Visuals")

bool   showTable  = input.bool(true, "Show table", group = "Table")
string tablePosIn = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group = "Table")
color  headerFill = input.color(color.rgb(146, 49, 211), "Header fill", group = "Table")
color  headerText = input.color(color.white, "Header text", group = "Table")

// == HELPER FUNCTIONS ========================================================

//@function Converts an hour/minute pair into a New York minute-of-day
//@param hourValue   (int) Hour component, 0-23
//@param minuteValue (int) Minute component, 0-59
//@returns (int) Minutes elapsed since New York midnight
minuteOfDay(int hourValue, int minuteValue) => hourValue * 60 + minuteValue

//@function Tests whether a minute-of-day falls inside a window that may wrap midnight
//@param nowMin   (int) Current New York minute-of-day
//@param startMin (int) Window start minute-of-day
//@param endMin   (int) Window end minute-of-day (exclusive)
//@returns (bool) True when inside the window
inWindow(int nowMin, int startMin, int endMin) => startMin <= endMin ? (nowMin >= startMin and nowMin < endMin) : (nowMin >= startMin or nowMin < endMin)

//@function Detects the first confirmed bar at or after a New York anchor time on a given day
//@param nowMin    (int)  Current New York minute-of-day
//@param prevMin   (int)  Previous bar's New York minute-of-day
//@param anchorMin (int)  Anchor minute-of-day
//@param newDay    (bool) True when this bar opens a new New York calendar day
//@param maxLag    (int)  Maximum permitted minutes between the anchor and the capturing bar
//@returns (bool) True on the capture bar only
crossedAnchor(int nowMin, int prevMin, int anchorMin, bool newDay, int maxLag) => nowMin >= anchorMin and (newDay or prevMin < anchorMin) and (nowMin - anchorMin) <= maxLag

//@function Resolves the label-size input string to a Pine size constant
//@param sizeName (string) One of "tiny", "small", "normal"
//@returns (string) Matching size.* constant
resolveSize(string sizeName) => switch sizeName
    "tiny"   => size.tiny
    "normal" => size.normal
    =>          size.small

//@function Resolves the table-position input string to a Pine position constant
//@param posName (string) Human-readable corner name
//@returns (string) Matching position.* constant
resolvePosition(string posName) => switch posName
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Middle Right"  => position.middle_right
    "Middle Left"   => position.middle_left
    =>                 position.top_right

//@function Formats a price/points value for table and label display
//@param value (float) Value to format
//@returns (string) Two-decimal string, or an em dash when the value is na
fmtValue(float value) => na(value) ? "—" : str.tostring(value, "#.##")

//@function Formats a whole-number percentage
//@param value (float) Value to format
//@returns (string) Zero-decimal percentage, or an em dash when na
fmtPct0(float value) => na(value) ? "—" : str.tostring(value, "#") + "%"

//@function Places every live label at the shared right edge, spaced so none overlap
//@param labels   (array<label>) Labels to lay out
//@param levels   (array<float>) The price each label wants to sit at
//@param targetX  (int)          Bar index every label is placed on
//@param minGap   (float)        Minimum vertical separation in price units
//@returns (bool) Always true
layoutRightEdge(array<label> labels, array<float> levels, int targetX, float minGap) =>
    if labels.size() > 0
        array<int> ascending = levels.sort_indices(order.ascending)
        float previousY = na
        for n = 0 to ascending.size() - 1
            int k = ascending.get(n)
            float placedY = levels.get(k)
            if not na(previousY) and placedY - previousY < minGap
                placedY := previousY + minGap
            label.set_xy(labels.get(k), targetX, placedY)
            previousY := placedY
    true

// == DERIVED SESSION CONSTANTS ===============================================

int asiaOpenMin     = minuteOfDay(asiaOpenHour,    asiaOpenMinute)
int rthCloseMin     = minuteOfDay(rthCloseHour,    rthCloseMinute)
int midnightMin     = minuteOfDay(midnightHour,    midnightMinute)
int newsMin         = minuteOfDay(newsHour,        newsMinute)
int cashOpenMin     = minuteOfDay(cashHour,        cashMinute)
int asiaKzOpenMin   = minuteOfDay(asiaKzOpenHr,    asiaKzOpenMn)
int asiaKzCloseMin  = minuteOfDay(asiaKzCloseHr,   asiaKzCloseMn)
int lokzStartMin    = minuteOfDay(lokzStartHour,   lokzStartMin_)
int lokzEndMin      = minuteOfDay(lokzEndHour,     lokzEndMin_)
int deadStartMin    = minuteOfDay(deadStartHour,   deadStartMin_)
int deadEndMin      = minuteOfDay(deadEndHour,     deadEndMin_)
int nyKzStartMin    = minuteOfDay(nyKzStartHour,   nyKzStartMin_)
int nyKzEndMin      = minuteOfDay(nyKzEndHour,     nyKzEndMin_)

string labelSize = resolveSize(labelSizeIn)

// == CLOCK ===================================================================

//@variable New York minute-of-day for the current bar's open
int nyMin = minuteOfDay(hour(time, TZ), minute(time, TZ))
//@variable New York minute-of-day for the previous bar's open
int nyMinPrev = nz(nyMin[1], nyMin)
//@variable New York day-of-week for the current bar
int nyDow = dayofweek(time, TZ)
//@variable True on the first bar of a new New York calendar day
bool isNewNyDay = na(time[1]) or dayofmonth(time, TZ) != dayofmonth(time[1], TZ)
//@variable ATR(14) used purely for label clearance, never plotted
float atrValue = ta.atr(14)
//@variable Minimum vertical label separation in price units
float labelGap = nz(atrValue, syminfo.mintick * 10) * lblClearance

// == HTF RANGE METRICS (anti-repaint, confirmed closed bars only) ============

//@variable Mean of the last adrLength COMPLETED daily ranges
float adrValue = request.security(syminfo.tickerid, "D", ta.sma(high - low, adrLength)[1], lookahead = barmerge.lookahead_on)
//@variable Mean of the last awrLength COMPLETED weekly ranges — modifier input only
float awrValue = request.security(syminfo.tickerid, "W", ta.sma(high - low, awrLength)[1], lookahead = barmerge.lookahead_on)

// == ON RANGE ENGINE =========================================================

//@variable True while inside the merged overnight block (Asia open -> Cash open)
bool inOvernight = inWindow(nyMin, asiaOpenMin, cashOpenMin)
bool overnightStart = inOvernight and not inOvernight[1]
bool overnightEnd   = not inOvernight and inOvernight[1]

//@variable Running overnight high, reset at each Asia open
var float onHigh = na
//@variable Running overnight low, reset at each Asia open
var float onLow = na
//@variable Overnight range frozen at the cash open and held for the day
var float onRangeFrozen = na
//@variable True once the cash-open freeze has happened for the current cycle
var bool onIsFrozen = false

if barstate.isconfirmed
    if overnightStart
        onHigh := high
        onLow := low
        onRangeFrozen := na
        onIsFrozen := false
    else if inOvernight
        onHigh := math.max(nz(onHigh, high), high)
        onLow := math.min(nz(onLow, low), low)
    if overnightEnd and not onIsFrozen and not na(onHigh) and not na(onLow)
        onRangeFrozen := onHigh - onLow
        onIsFrozen := true

//@variable Overnight range in points — running before the cash open, frozen after
float onRange = onIsFrozen ? onRangeFrozen : (na(onHigh) or na(onLow) ? na : onHigh - onLow)
//@variable Overnight range expressed as a percentage of ADR(adrLength)
float onPctAdr = na(onRange) or na(adrValue) or adrValue <= 0 ? na : onRange / adrValue * 100.0
//@variable Display flag distinguishing a running reading from the frozen one
string onFlag = onIsFrozen ? "final" : "live"

// == ASIA KZ SUB-RANGE =======================================================
// The share is only meaningful once the ON block has frozen — before the KZ
// close Asia IS the whole ON block by construction, so the state verdict is
// withheld until the cash-open freeze.

bool inAsiaKz    = inWindow(nyMin, asiaKzOpenMin, asiaKzCloseMin)
bool asiaKzStart = inAsiaKz and not inAsiaKz[1]
bool asiaKzEnd   = not inAsiaKz and inAsiaKz[1]

//@variable Running Asia KZ high, reset at each Asia KZ open
var float asiaKzHigh = na
//@variable Running Asia KZ low, reset at each Asia KZ open
var float asiaKzLow = na
//@variable Asia KZ range frozen at the KZ close, held until the next KZ open
var float asiaKzFrozen = na
//@variable True once the Asia KZ range has been frozen for the current cycle
var bool asiaKzIsFrozen = false

if barstate.isconfirmed
    if asiaKzStart
        asiaKzHigh := high
        asiaKzLow := low
        asiaKzFrozen := na
        asiaKzIsFrozen := false
    else if inAsiaKz
        asiaKzHigh := math.max(nz(asiaKzHigh, high), high)
        asiaKzLow := math.min(nz(asiaKzLow, low), low)
    if asiaKzEnd and not asiaKzIsFrozen and not na(asiaKzHigh) and not na(asiaKzLow)
        asiaKzFrozen := asiaKzHigh - asiaKzLow
        asiaKzIsFrozen := true

//@variable Asia KZ range in points — running before the KZ close, frozen after
float asiaKzRange = asiaKzIsFrozen ? asiaKzFrozen : (na(asiaKzHigh) or na(asiaKzLow) ? na : asiaKzHigh - asiaKzLow)
//@variable Asia KZ range as a percentage of the overnight block
float asiaPctOn = na(asiaKzRange) or na(onRange) or onRange <= 0 ? na : asiaKzRange / onRange * 100.0
//@variable Template state — withheld until the ON block freezes at the cash open
string asiaState = not onIsFrozen ? "pending" : na(asiaPctOn) ? "—" : asiaPctOn > invertedPct ? "Inverted" : asiaPctOn > elevatedPct ? "Elevated" : "Normal"
//@variable Row colour keyed to template state
color asiaStateColor = asiaState == "Inverted" ? bearColor : asiaState == "Normal" ? bullColor : color.new(#000000, 0)

// == WEEK-TO-DATE RANGE (modifier input only — nothing is drawn) =============

bool weekWindowOpen = nyDow == dayofweek.sunday and nyMin >= asiaOpenMin
bool weekStart = weekWindowOpen and not weekWindowOpen[1]

//@variable Running week-to-date high measured from the Sunday Asia open
var float wtdHigh = na
//@variable Running week-to-date low measured from the Sunday Asia open
var float wtdLow = na

if barstate.isconfirmed
    if weekStart
        wtdHigh := high
        wtdLow := low
    else
        wtdHigh := math.max(nz(wtdHigh, high), high)
        wtdLow := math.min(nz(wtdLow, low), low)

//@variable Week-to-date range as a percentage of AWR(awrLength)
float wtdPctAwr = na(wtdHigh) or na(wtdLow) or na(awrValue) or awrValue <= 0 ? na : (wtdHigh - wtdLow) / awrValue * 100.0

// == OPEN ANCHORS — ONE DAY ONLY =============================================

//@variable Per-anchor visibility toggles
var array<bool>   anchorEnabled = array.from(showMidnight, showNewsOpen, showCashOpen)
//@variable Display names shared by the chart labels
var array<string> anchorNames   = array.from("Midnight Open", "News Open", "Cash Open")
//@variable Captured anchor prices for the current New York day, na until captured
var array<float>  anchorPrices  = array.new<float>(ANCHOR_COUNT, na)
//@variable Live anchor lines for the current day
var array<line>   anchorLines   = array.new<line>(ANCHOR_COUNT, na)
//@variable Live anchor labels for the current day, riding the line's right edge
var array<label>  anchorLabels  = array.new<label>(ANCHOR_COUNT, na)
//@variable Per-bar capture flags for the three anchors
var array<bool>   anchorCross   = array.new<bool>(ANCHOR_COUNT, false)

//@variable Box drawing the current overnight block
var box onBox = na
//@variable Right-edge label naming the overnight block
var label onLabel = na
//@variable True while the overnight block is still growing
var bool onBlockLive = false
//@variable Bar index of the Asia open that started the current ON block
var int onStartBar = 0
//@variable Live on-chart bias label for the current day, na before the cash open
var label probLabel = na

bool midnightCross = crossedAnchor(nyMin, nyMinPrev, midnightMin, isNewNyDay, maxCaptureLag)
bool newsCross     = crossedAnchor(nyMin, nyMinPrev, newsMin,     isNewNyDay, maxCaptureLag)
bool cashCross     = crossedAnchor(nyMin, nyMinPrev, cashOpenMin, isNewNyDay, maxCaptureLag)
//@variable True while the anchor lines and their labels are still extending
bool anchorsLive   = nyMin <= rthCloseMin

//@variable Bull anchor agreement count, refreshed each confirmed bar
var int bullVotes = 0
//@variable Bear anchor agreement count, refreshed each confirmed bar
var int bearVotes = 0
//@variable Count of formed anchors participating in the lean vote
var int liveAnchors = 0

// The drawing layer runs on EVERY update, live bar included — the windows are
// time-based and a bar's high/low only ever extend, so nothing here can
// repaint. Only the close-based lean vote and the frozen metrics stay gated on
// confirmed bars.
anchorCross.set(0, midnightCross)
anchorCross.set(1, newsCross)
anchorCross.set(2, cashCross)

// -- Daily reset: one day at a time — the prior day's drawings are deleted --
if isNewNyDay
    for i = 0 to ANCHOR_COUNT - 1
        line oldLine = anchorLines.get(i)
        if not na(oldLine)
            line.delete(oldLine)
        label oldLabel = anchorLabels.get(i)
        if not na(oldLabel)
            label.delete(oldLabel)
        anchorPrices.set(i, na)
        anchorLines.set(i, na)
        anchorLabels.set(i, na)
    if not na(probLabel)
        label.delete(probLabel)
        probLabel := na

// -- Capture anchors, draw their lines and their right-edge labels. The     --
// -- captured price is the bar's OPEN, fixed from its first tick.           --
for i = 0 to ANCHOR_COUNT - 1
    if anchorEnabled.get(i) and anchorCross.get(i) and na(anchorPrices.get(i))
        float capturedPrice = open
        anchorPrices.set(i, capturedPrice)
        line newLine = line.new(bar_index, capturedPrice, bar_index, capturedPrice, xloc = xloc.bar_index, color = anchorColor, width = 1, style = line.style_dotted)
        anchorLines.set(i, newLine)
        if showAnchorLbl
            label newLabel = label.new(bar_index, capturedPrice, anchorNames.get(i), style = label.style_none, textcolor = color.new(#000000, 0), size = labelSize, xloc = xloc.bar_index)
            label.set_text_font_family(newLabel, font.family_monospace)
            anchorLabels.set(i, newLabel)

// -- Extend live anchor lines past the live candle, until the RTH close --
for i = 0 to ANCHOR_COUNT - 1
    line liveLine = anchorLines.get(i)
    if not na(liveLine) and anchorsLive
        line.set_x2(liveLine, bar_index + lineExtendBars)

// -- Directional lean: close-based, so it stays on confirmed bars only --
if barstate.isconfirmed
    bullVotes := 0
    bearVotes := 0
    liveAnchors := 0
    for i = 0 to ANCHOR_COUNT - 1
        float anchorPrice = anchorPrices.get(i)
        if anchorEnabled.get(i) and not na(anchorPrice)
            liveAnchors += 1
            if close > anchorPrice
                bullVotes += 1
            else if close < anchorPrice
                bearVotes += 1

// -- ON RANGE BLOCK: opens on the Asia-open candle, grows with the live     --
// -- overnight high/low, freezes at the cash open. One block only — the     --
// -- previous day's is deleted the moment a new one opens.                  --
if showOnBlock and overnightStart and not onBlockLive
    if not na(onBox)
        box.delete(onBox)
    if not na(onLabel)
        label.delete(onLabel)
    onStartBar := bar_index
    onBox := box.new(bar_index, high, bar_index, low, border_color = onBlockColor, border_width = 1, border_style = line.style_solid, bgcolor = onBlockColor, xloc = xloc.bar_index)
    onLabel := label.new(bar_index, high, "ON Range", style = label.style_flag, color = color.new(color.white, 100), textcolor = color.new(#000000, 0), size = labelSize, textalign = text.align_center, xloc = xloc.bar_index)
    label.set_text_font_family(onLabel, font.family_monospace)
    onBlockLive := true
if not na(onBox) and inOvernight and not onIsFrozen
    box.set_top(onBox, math.max(nz(onHigh, high), high))
    box.set_bottom(onBox, math.min(nz(onLow, low), low))
    box.set_right(onBox, bar_index)
    if not na(onLabel)
        label.set_xy(onLabel, math.round((onStartBar + bar_index) / 2), math.max(nz(onHigh, high), high))
if onIsFrozen and onBlockLive
    onBlockLive := false

// == AR PROJECTION LINES =====================================================
// One set at a time, measured from the selected anchor's open. Recreated on
// each new anchor capture (which also deletes the previous day's set), extended
// until the post-close dead window between the RTH close and the Asia open.

//@variable Minute-of-day of the selected AR anchor
int arAnchorMin = arAnchorIn == "Cash Open" ? cashOpenMin : arAnchorIn == "Asia Open" ? asiaOpenMin : midnightMin
//@variable True on the bar that captures the AR anchor
bool arCross = crossedAnchor(nyMin, nyMinPrev, arAnchorMin, isNewNyDay, maxCaptureLag)
//@variable True while AR lines should still extend — everything except the post-close halt
bool arLive = not (nyMin >= rthCloseMin and nyMin < asiaOpenMin)

//@variable AR line handles — [+ADR, −ADR, +1/3, −1/3, +2/3, −2/3, +AWR, −AWR]
var array<line> arLines = array.new<line>(8, na)
//@variable Matching AR labels, right-edge laid out with everything else
var array<label> arLabels = array.new<label>(8, na)
//@variable Prices behind each AR line, na when that slot is unused
var array<float> arPrices = array.new<float>(8, na)

//@function Creates one AR projection line + label pair into slot `slot`.
//@param slot  (int)    Store slot, 0-7
//@param price (float)  The projected level
//@param txt   (string) Label text, e.g. "+ADR"
f_arLine(int slot, float price, string txt) =>
    line ln = line.new(bar_index, price, bar_index, price, xloc = xloc.bar_index, color = arColor, width = 1, style = line.style_dotted)
    label lb = label.new(bar_index, price, txt, style = label.style_none, textcolor = arColor, size = labelSize, xloc = xloc.bar_index)
    label.set_text_font_family(lb, font.family_monospace)
    arLines.set(slot, ln)
    arLabels.set(slot, lb)
    arPrices.set(slot, price)

//@variable Bar the current AR set was captured on — stops a live bar's later ticks recreating it
var int arCapturedBar = na

if showAr
    if arCross and not na(adrValue) and (na(arCapturedBar) or arCapturedBar != bar_index)
        arCapturedBar := bar_index
        // New anchor: clear the previous set outright — one day at a time.
        for i = 0 to 7
            line oldLn = arLines.get(i)
            if not na(oldLn)
                line.delete(oldLn)
            label oldLb = arLabels.get(i)
            if not na(oldLb)
                label.delete(oldLb)
            arLines.set(i, na)
            arLabels.set(i, na)
            arPrices.set(i, na)
        float anchorPx = open
        f_arLine(0, anchorPx + adrValue, "+ADR")
        f_arLine(1, anchorPx - adrValue, "-ADR")
        if showArThirds
            f_arLine(2, anchorPx + adrValue / 3.0, "+1/3 ADR")
            f_arLine(3, anchorPx - adrValue / 3.0, "-1/3 ADR")
            f_arLine(4, anchorPx + adrValue * 2.0 / 3.0, "+2/3 ADR")
            f_arLine(5, anchorPx - adrValue * 2.0 / 3.0, "-2/3 ADR")
        if showAwrLines and not na(awrValue)
            f_arLine(6, anchorPx + awrValue, "+AWR")
            f_arLine(7, anchorPx - awrValue, "-AWR")
    if arLive
        for i = 0 to 7
            line ln = arLines.get(i)
            if not na(ln)
                line.set_x2(ln, bar_index + lineExtendBars)

// == PROBABILITY ENGINE ======================================================
// Grade is read from how much of the average daily range has ALREADY been spent
// overnight. Small ON range -> expansion statistically still ahead (HIGH).
// Large ON range -> the move may have already happened overnight (LOW).

//@variable Trend-day probability grade derived from ON % of ADR
string probGrade = na(onPctAdr) ? "—" : onPctAdr < lowThreshold ? "HIGH" : onPctAdr <= highThreshold ? "MEDIUM" : "LOW"
//@variable Directional lean — agreement across every formed anchor, else Mixed
string probLean = liveAnchors == 0 ? "Neutral" : bullVotes == liveAnchors ? "Bullish" : bearVotes == liveAnchors ? "Bearish" : "Mixed"
//@variable The grade with the ON % of ADR reading that produced it
string gradeText = probGrade == "—" ? "—" : probGrade + " · ON " + fmtPct0(onPctAdr) + " of ADR"
//@variable Lean with the vote arithmetic visible
string leanText = probLean + (liveAnchors > 0 ? " (" + str.tostring(bullVotes) + "/" + str.tostring(liveAnchors) + " opens below price)" : "")
//@variable On-chart label text — the whole bias read in one line
string chartBiasText = "Trend Day " + probGrade + " · ON " + fmtPct0(onPctAdr) + " ADR · " + probLean + (useAwrMod and not na(wtdPctAwr) and wtdPctAwr > wtdThreshold ? " · AWR spent" : "")
//@variable Text colour for the bias row / label
color probColor = probLean == "Bullish" ? bullColor : probLean == "Bearish" ? bearColor : color.new(#000000, 0)

// == RIGHT-EDGE LABEL LAYOUT =================================================
// Runs every update so the labels ride the live bar, not one bar behind it.

if true
    // The bias label sits centred ABOVE the ON range block, clear of price —
    // a down-pointing callout with a spacer line holds a fixed pixel clearance
    // at any zoom. It is excluded from the right-edge layout so it stays put.
    if showProbLabel and cashCross and na(probLabel) and not na(onHigh)
        int onCentreBar = not na(onBox) ? math.round((onStartBar + box.get_right(onBox)) / 2) : bar_index
        probLabel := label.new(onCentreBar, onHigh, chartBiasText + "\n ", style = label.style_label_down, color = color.new(color.white, 100), textcolor = probColor, size = labelSize, textalign = text.align_center, xloc = xloc.bar_index)
        label.set_text_font_family(probLabel, font.family_monospace)
    if not na(probLabel)
        label.set_text(probLabel, chartBiasText + "\n ")
        label.set_textcolor(probLabel, probColor)

    array<label> liveLabels = array.new<label>(0)
    array<float> liveLevels = array.new<float>(0)

    if anchorsLive
        for i = 0 to ANCHOR_COUNT - 1
            if not na(anchorLabels.get(i)) and not na(anchorPrices.get(i))
                liveLabels.push(anchorLabels.get(i))
                liveLevels.push(anchorPrices.get(i))

    if showAr and arLive
        for i = 0 to 7
            if not na(arLabels.get(i)) and not na(arPrices.get(i))
                liveLabels.push(arLabels.get(i))
                liveLevels.push(arPrices.get(i))

    layoutRightEdge(liveLabels, liveLevels, bar_index + lineExtendBars + labelGapBars, labelGap)

// == SESSION RANGE BOXES =====================================================
// Each enabled session is a box bounding only its own high-low, from session
// start to session end. The box grows with the session and freezes at the
// session close. Its caption sits top-centre, matching the ON Range block —
// every box caption in this file uses the same centred, on-top placement.
// One instance per session: the previous day's box is deleted when the same
// session next opens, so the chart carries a single rolling day.

//@type One session window's range box, its state and its drawing objects
type SessRange
    string name     = ""
    int    startMin = 0
    int    endMin   = 0
    bool   enabled  = false
    color  col      = na
    float  hi       = na
    float  lo       = na
    int    startBar = 0
    box    bx       = na
    label  lb       = na
    bool   live     = false

var array<SessRange> sessions = array.new<SessRange>(0)

if bar_index == 0
    sessions.push(SessRange.new("Asia",   asiaKzOpenMin, asiaKzCloseMin, showAsiaBox, asiaBoxCol))
    sessions.push(SessRange.new("London", lokzStartMin,  lokzEndMin,     showLokzBox, lokzBoxCol))
    sessions.push(SessRange.new("❌",     deadStartMin,  deadEndMin,     showDeadBox, deadBoxCol))
    sessions.push(SessRange.new("NY AM",  nyKzStartMin,  nyKzEndMin,     showNyKzBox, nyKzBoxCol))

for si = 0 to sessions.size() - 1
    SessRange s = sessions.get(si)
    if s.enabled
        bool nowIn = inWindow(nyMin, s.startMin, s.endMin)
        if nowIn and not s.live
            if not na(s.bx)
                box.delete(s.bx)
            if not na(s.lb)
                label.delete(s.lb)
            s.hi := high
            s.lo := low
            s.startBar := bar_index
            s.bx := box.new(bar_index, high, bar_index, low, border_color = color.new(color.black, 0), border_width = 1, border_style = line.style_dotted, bgcolor = color.new(s.col, 90), xloc = xloc.bar_index)
            s.lb := label.new(bar_index, high, s.name, style = label.style_label_down, color = color.new(color.white, 100), textcolor = color.new(#000000, 0), size = labelSize, textalign = text.align_center, xloc = xloc.bar_index)
            label.set_text_font_family(s.lb, font.family_monospace)
            s.live := true
        else if nowIn and s.live
            s.hi := math.max(s.hi, high)
            s.lo := math.min(s.lo, low)
            box.set_top(s.bx, s.hi)
            box.set_bottom(s.bx, s.lo)
            box.set_right(s.bx, bar_index)
            label.set_xy(s.lb, math.round((s.startBar + bar_index) / 2), s.hi)
        else if not nowIn and s.live
            s.live := false

// == DATA TABLE — the bias read, nothing else ================================
// Verdict first; every remaining row is an input to that verdict. The
// arithmetic lives in the cell tooltips, not on the chart.

int tableRows = 4 + (showDecomp ? 1 : 0)
var table infoTable = table.new(resolvePosition(tablePosIn), 2, tableRows, border_width = 1, border_color = color.new(color.black, 60))

if showTable and barstate.islast
    table.cell(infoTable, 0, 0, "OVERNIGHT BIAS", text_color = headerText, bgcolor = headerFill, text_size = size.small, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(infoTable, 1, 0, onFlag, text_color = headerText, bgcolor = headerFill, text_size = size.small, text_halign = text.align_right, text_font_family = font.family_monospace)

    table.cell(infoTable, 0, 1, "Trend Day", text_color = #000000, bgcolor = color.white, text_size = size.small, text_halign = text.align_left, text_font_family = font.family_monospace, text_formatting = text.format_bold)
    table.cell(infoTable, 1, 1, gradeText, text_color = probColor, bgcolor = color.white, text_size = size.small, text_halign = text.align_right, text_font_family = font.family_monospace, text_formatting = text.format_bold, tooltip = "HIGH below " + str.tostring(lowThreshold, "#") + "% · LOW above " + str.tostring(highThreshold, "#") + "% of ADR(" + str.tostring(adrLength) + ") = " + fmtValue(adrValue) + " pts")

    table.cell(infoTable, 0, 2, "Lean", text_color = #000000, bgcolor = color.white, text_size = size.small, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(infoTable, 1, 2, leanText, text_color = probColor, bgcolor = color.white, text_size = size.small, text_halign = text.align_right, text_font_family = font.family_monospace, tooltip = "Agreement across the formed open anchors. All above price = Bullish, all below = Bearish, split = Mixed." + (useAwrMod and not na(wtdPctAwr) and wtdPctAwr > wtdThreshold ? " AWR-SPENT: week-to-date has used " + fmtPct0(wtdPctAwr) + " of AWR." : ""))

    table.cell(infoTable, 0, 3, "ON Range", text_color = #000000, bgcolor = color.white, text_size = size.small, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(infoTable, 1, 3, fmtValue(onRange) + " pts · " + fmtPct0(onPctAdr) + " ADR", text_color = #000000, bgcolor = color.white, text_size = size.small, text_halign = text.align_right, text_font_family = font.family_monospace, tooltip = "ADR(" + str.tostring(adrLength) + ") = " + fmtValue(adrValue) + " pts. Exhaustion alert at " + str.tostring(exhaustPct, "#") + "%.")

    if showDecomp
        table.cell(infoTable, 0, 4, "Asia % of ON", text_color = #000000, bgcolor = color.white, text_size = size.small, text_halign = text.align_left, text_font_family = font.family_monospace)
        table.cell(infoTable, 1, 4, fmtPct0(asiaPctOn) + " · " + asiaState, text_color = asiaStateColor, bgcolor = color.white, text_size = size.small, text_halign = text.align_right, text_font_family = font.family_monospace, tooltip = "Asia KZ range " + fmtValue(asiaKzRange) + " pts. Elevated above " + str.tostring(elevatedPct, "#") + "%, Inverted above " + str.tostring(invertedPct, "#") + "% of the ON block. Verdict resolves at the cash-open freeze.")

// == ALERTS ==================================================================

//@variable Midnight Open price exposed at global scope for the cross alert
float midnightOpenPrice = anchorPrices.get(0)
//@variable Cash Open price exposed at global scope for the cross alert
float cashOpenPrice = anchorPrices.get(2)

// ta.cross must run unconditionally on every bar — behind a short-circuiting
// 'and' it would skip bars and corrupt its own state history.
bool rawCrossMidnight = ta.cross(close, midnightOpenPrice)
bool rawCrossCashOpen = ta.cross(close, cashOpenPrice)

bool alertProbFinalised = overnightEnd and barstate.isconfirmed
bool alertCrossMidnight = not na(midnightOpenPrice) and rawCrossMidnight
bool alertCrossCashOpen = not na(cashOpenPrice) and rawCrossCashOpen
bool alertOnExhaustion  = not na(onPctAdr) and onPctAdr >= exhaustPct and nz(onPctAdr[1], 0.0) < exhaustPct

alertcondition(alertProbFinalised, "Trend-Day Probability Finalised", "M1D: overnight range frozen at the cash open — trend-day probability finalised on {{ticker}}")
alertcondition(alertCrossMidnight, "Cross Midnight Open",             "M1D: price crossed the Midnight Open on {{ticker}} @ {{close}}")
alertcondition(alertCrossCashOpen, "Cross Cash Open",                 "M1D: price crossed the Cash Open on {{ticker}} @ {{close}}")
alertcondition(alertOnExhaustion,  "ON Range Exhaustion",             "M1D: overnight range exceeded the exhaustion threshold vs ADR on {{ticker}} — reversal-zone conditions")

// == BUILD STAMP =============================================================

if barstate.islast
    log.info("BUILD " + BUILD)
````
