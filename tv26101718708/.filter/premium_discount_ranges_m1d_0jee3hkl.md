# Premium + Discount Ranges (M1D)

- url: https://www.tradingview.com/script/0jee3HkL-Premium-Discount-Ranges-M1D/
- type: indicator
- pine_id: PUB;c7f1f9f79cb24e408576d9cf59b030fe
- version: 5.0

## Description

[b]Premium + Discount Ranges [/b]
Measures the range you are trading inside, the way it is read by eye from the newest swing point on a chosen timeframe across to the swing of the opposite kind, split into premium and discount either side of an equilibrium. Three ranges can run at once, each on its own timeframe, so an execution range can be read inside the higher one that frames it.

[b]Two ways to bound a range[/b]

Period takes the timeframe's own high and low so far: one month is one range, it starts empty at the open and is gone at the rollover. It answers where price sits in the month.

Swing takes the newest confirmed swing high across to the newest swing low on that same timeframe, which owes nothing to the calendar and can run across many periods. It answers which structural range price is inside right now.

Each range picks its own mode, and the chart says which: "1M High" is this month's high, "1M Swing High" is the monthly swing high.

[b]What counts as a swing[/b]

A swing is a level price actually turned at, not merely a high that sits above its neighbours while price kept running the same way. The candle has to hold the extreme against a chosen number of candles either side of it, and by default it also has to mark the change of direction — a swing high on the turn from an up candle to a down one, a swing low on the turn from down to up. That second condition can be switched off to accept any candle holding the extreme, regardless of what it turned into.

Every swing is read from candles already closed on its own timeframe, one bar clear of the newest bar, so nothing on a forming higher-timeframe candle can confirm or unconfirm it.

[b]The raided edge[/b]

A confirmed swing is the last level price turned at, which is not always the edge of the range being traded right now — the moment a boundary is taken, the real range is already wider than the swings describe. Each boundary is carried out to the extreme price has actually reached since its swing confirmed, and draws dotted while it is out there: a level price has not yet turned at is a raid in progress, not structure. It settles back to solid the moment a new swing confirms behind it. This can be switched off to pin both boundaries to confirmed swings only, with price free to trade outside the range.

[b]Direction and shading[/b]

The range is read from whichever swing formed most recently. A new swing low means price has already turned up away from it, so the leg is bullish and discount is the side being worked from; a new swing high reads the other way. The first range is shaded premium and discount by default; the shading can optionally lean toward the side being worked from, fading the other side back. Ranges two and three draw as bare levels by default so a bias range never muddies the range being traded.

[b]Anchoring and labels[/b]

Every boundary starts at the candle that set it, never drawn back across bars that closed before that price existed. The equilibrium and the shading begin at the later of the two swings, because a range has no midpoint until both ends exist.

Each range's names can follow the global label settings or override them: centred over the range's own span, to the left, to the right, at the swing that set the level, or off. Two names landing on the same price are merged into one label rather than left stacked; two that land close together without being the same level are separated by a blank line rather than overlapping.

[b]The readout[/b]

One panel, two blocks. The first names each active range's timeframe, whether it fits under the chart's own timeframe, which way it is working, which half of it price is trading in, and how far through it price has travelled. The second is a calendar statistic rather than a swing one: the average daily, weekly and monthly range over a chosen number of completed periods, how much of that average the current period has already used, and a countdown to the period's close.

[b]Alerts[/b]

Six. Price crossing into premium, price crossing into discount, price trading the equilibrium, the range high taken, the range low taken, and a new swing redrawing the range. All six read the range being traded — range one.

[b]Method and repainting[/b]

Swings on ranges two and three are read on their own timeframe via a higher-timeframe request; range one's swing test is likewise timeframe-bound to whichever timeframe is chosen for it. Every swing reads only candles already closed, one bar back, so nothing about it depends on lookahead revealing an unclosed bar.

A confirmed boundary moves only when a genuinely new swing prints. The one part of the drawing that is live by design is a boundary carried out to a raid in progress, and it draws dotted so that is visible rather than implied.

[b]What it will not do[/b]

It places no entries, exits, stops or targets, and it does not size a position. It draws no trend line, no bias score and no target projection beyond the range itself. It does not identify order blocks, fair value gaps or liquidity pools — only the swing highs and lows that bound the range and the equilibrium between them.

[b]Settings[/b]

Per range: on/off, timeframe, Period or Swing, label placement override, swing strength, premium/discount shading, boundary width. Swing definition: whether a direction turn is required, whether a raided boundary is carried out to price. Shading: premium and discount colours, transparency, whether the shading leans with direction and by how much. Lines: boundary and equilibrium colour and width, how far boundaries extend past the last bar. Labels: side and nudge for the high, low and equilibrium of each range, whether premium/discount get their own names, the collision distance that separates two close labels, whether price is shown in the label, label size and colour. Readout: show/hide, position, size. Average ranges: show/hide, lookback length for each of daily, weekly and monthly, and whether the close countdown is shown.

[b]Disclaimer[/b]

This is a decision-support tool for discretionary ICT trading. It is not financial advice, and no market's past behaviour is indicative of future results.

## Source Code

````pine
//@version=6
// ============================================================================
// Premium + Discount Ranges (M1D)
// ----------------------------------------------------------------------------
// The dealing range you are trading inside, measured the way it is read by
// hand: from the newest swing point on a chosen timeframe across to the swing
// of the opposite kind, with the space between them split into premium and
// discount either side of a solid equilibrium.
//
// A swing is a level price actually TURNED at. The candle must hold the extreme
// against its neighbours AND mark the change of direction - a swing high at the
// turn from a candle closing up to one closing down, a swing low at the turn from down to up.
// A high that merely sits above its neighbours while price kept running the same
// way is not a swing, and a range built on one is a range that never existed.
//
// Each range can be bounded two ways, and they answer different questions.
// PERIOD takes this period's own high and low: one month is one range, it starts
// empty at the open and is gone at the rollover - where price sits in the month.
// SWING is a dealing range that HOLDS: it forms on a swing high and a swing low on
// that timeframe, then ignores sweeps and internal swings and rebuilds only when a
// candle of that timeframe CLOSES through one side. It owes nothing to the calendar
// and can run across half a year - which structural range price is inside. The names on the chart say
// which: "1M High" is this month's high, "1M Swing High" is the monthly swing high.
//
// Three ranges can run at once, each on its own timeframe - 1H, 4H, 12H, Daily,
// Weekly or Monthly - so the execution range can be read inside the higher one
// that frames it. The first is shaded by default; the other two draw as bare
// levels so a bias range never muddies the range being traded.
//
// Anchoring. The high, the low, the equilibrium and the shading all start at the
// range's first swing, so the range reads as one block from where it began - on the
// chart bar that actually printed that swing, not the open of the higher-timeframe
// candle it belongs to.
//
// Names. A Swing range says so: "1W Swing High" is the weekly swing high, "1W High" is
// this week's high. Names on the same price merge into one; names merely close together
// stay at their own prices, each range in its own column.
//
// A broken range. When a candle closes through one side, the range rebuilds: the
// far edge moves to the extreme price has reached since the break, and the near
// edge becomes the swing that launched the break - the lowest low (or highest high)
// printed since the old edge was set. The far edge draws DOTTED and follows price
// until price turns: once that many candles of the range's timeframe have closed
// without exceeding it, it is a swing and settles to solid. A wick through a side
// that closes back inside is a sweep and moves nothing.
//
// Repainting. Every break and every swing is judged on candles already closed on
// their own timeframe, so nothing on a forming higher-timeframe candle can build or
// rebuild the range. A solid boundary therefore moves only on a genuine close
// through it. A dotted far edge is the one part that is live by design, and it says so.
//
// Direction. The range is read from the side it last broke through - a close above
// the high is a bullish leg, discount is the side being worked from; a close below
// the low reads the other way. Before its first break, from whichever swing formed last. The table names it.
// ============================================================================
indicator("Premium + Discount Ranges (M1D)", "Prem+Disc (M1D)", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

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


// == INPUTS - RANGES =========================================================
// Each range is independent: its own timeframe, its own swing strength, its own
// boundary weight. Range 1 is the one being traded and carries the shading;
// ranges 2 and 3 are context and default to bare levels.

const string G1 = "Range 1 - traded"
const string G2 = "Range 2 - context"
const string G3 = "Range 3 - context"

const string TF_TIP = "Which timeframe the range is built from. The range itself draws on every chart timeframe below it - a 4H range read on a 5m chart is the point of the tool."
const string LEN_TIP = "Swing ranges only, all three. How many candles either side of a swing must fail to exceed it - for the two swings the range first forms on, and for the far edge after a break to settle from dotted to solid. 1 is the short-term swing of that timeframe and is the usual read."

// Two ways to bound a range, and they answer different questions.
//
//   Period - THIS period's own high and low. One month is one range. It starts empty at
//            the open and fills out as the period trades, and it is gone at the rollover.
//            The plain "where are we in the month" read.
//   Swing  - the newest confirmed swing high across to the newest swing low, on that same
//            timeframe. It ignores period boundaries entirely, so a monthly swing range
//            can span half a year. The wider structural read.
//
// The same word means different things under each, which is why the names on the chart say
// so: "1M High" is this month's high, "1M Swing High" is the monthly swing high.
const string SRC_TIP = "Period: this period's own high and low - one month is one range, one week is one range, and it resets at the rollover. Swing: a dealing range that forms on a swing high and a swing low on that timeframe, holds through sweeps, and rebuilds only when a candle of that timeframe closes through a side. Period answers where price sits in the month; Swing answers which structural range price is inside."

// Every range naming itself down the same right-hand edge is what crowds that edge. A wide
// range has the whole width of its own span to be named across instead, so it can step out
// of the column and leave it to the ranges that have nowhere else to go. Names that land on
// the SAME price merge into one; names merely close together stay at their own prices -
// the price axis already separates them, and Pine cannot measure text to do better.
const string LBL_TIP = "Where this range names its levels. Right: every name at the right end of its own line, in this range's own column. Centred: the high above its line and the low below it, centred across the range's span, which takes a wide range out of the right-hand column; the equilibrium stays at the right. Inside corners: the high named just under its line and the low just over its own, inside the range at its right edge; the equilibrium stays at the right. Left: at the range's start. Off: the levels draw bare."

bool   on1     = input.bool(true, "Show", group = G1, inline = "a")
string tfPick1 = input.string("1H", "", options = ["1H", "4H", "12H", "Daily", "Weekly", "Monthly"], group = G1, inline = "a", tooltip = TF_TIP)
string srcPick1 = input.string("Swing", "Range from", options = ["Period", "Swing"], group = G1, tooltip = SRC_TIP)
string lblMode1 = input.string("Centred", "Label placement", options = ["Right", "Centred", "Inside corners", "Left", "Off"], group = G1, tooltip = LBL_TIP)
bool   shade1  = input.bool(true, "Shade premium / discount", group = G1)

bool   on2     = input.bool(true, "Show", group = G2, inline = "b")
string tfPick2 = input.string("Daily", "", options = ["1H", "4H", "12H", "Daily", "Weekly", "Monthly"], group = G2, inline = "b", tooltip = TF_TIP)
string srcPick2 = input.string("Period", "Range from", options = ["Period", "Swing"], group = G2, tooltip = SRC_TIP)
string lblMode2 = input.string("Right", "Label placement", options = ["Right", "Centred", "Inside corners", "Left", "Off"], group = G2, tooltip = LBL_TIP)
bool   shade2  = input.bool(false, "Shade premium / discount", group = G2)

bool   on3     = input.bool(false, "Show", group = G3, inline = "c")
string tfPick3 = input.string("Weekly", "", options = ["1H", "4H", "12H", "Daily", "Weekly", "Monthly"], group = G3, inline = "c", tooltip = TF_TIP)
string srcPick3 = input.string("Period", "Range from", options = ["Period", "Swing"], group = G3, tooltip = SRC_TIP)
string lblMode3 = input.string("Centred", "Label placement", options = ["Right", "Centred", "Inside corners", "Left", "Off"], group = G3, tooltip = LBL_TIP)
bool   shade3  = input.bool(false, "Shade premium / discount", group = G3)

// Boundary weight tracks seniority and is not a setting: the lowest timeframe on draws at 1,
// the next at 2 and the highest at 3, so the senior range reads first whichever slot it is
// in. The equilibrium always draws at 1. The rank is worked out under RESOLVED SETTINGS.

// == INPUTS - SWING DEFINITION ===============================================

const string G_SW = "Swing definition"

int  swingLen = input.int(1, "Swing strength", minval = 1, maxval = 20, group = G_SW, tooltip = LEN_TIP)
bool requireTurn = input.bool(false, "Require a direction turn", group = G_SW, tooltip = "On: the swing candle must also mark the change of direction - up to down for a high, down to up for a low. Two candles running the same way can bracket a price extreme never actually turned at, and that is not structure. Off: any candle holding the extreme against its neighbours counts.")
bool trackRunning = input.bool(true, "Follow a broken range's far edge live", group = G_SW, tooltip = "Swing ranges only. On: after a close breaks the range, its dotted far edge follows price inside the candle that is still forming, not only at each close. Off: it moves on closed candles only. A held edge never follows price either way - a wick through it is a sweep.")

// == INPUTS - SHADING ========================================================

const string G_SH = "Shading"

color premCol = input.color(#E04A6D, "Premium", group = G_SH, inline = "s1")
color discCol = input.color(#3A7BD5, "Discount", group = G_SH, inline = "s1")
int   shadeT  = input.int(90, "Transparency", minval = 70, maxval = 98, group = G_SH, tooltip = "Higher is fainter. The fills are sized to stay readable over candles on a white chart - drop toward 80 for a stronger wash, lift toward 96 for a hint.")
string namesOn = input.string("Lowest shaded timeframe", "Name Premium / Discount on", options = ["Lowest shaded timeframe", "Highest shaded timeframe", "Range 1", "Range 2", "Range 3", "Off"], group = G_SH, tooltip = "Which range carries the bold Premium and Discount names. One range only, so two sets never stack. The range picked must be shaded for its names to show. Naming a higher range leaves a lower range free to use Inside corners for its own labels.")

// == INPUTS - LINES ==========================================================

const string G_LN = "Lines"

color bndCol = input.color(color.new(#000000, 0), "Range high / low", group = G_LN)
color eqCol  = input.color(color.new(#000000, 0), "Equilibrium", group = G_LN)
int   rightPad = input.int(12, "Extend past the last bar (bars)", minval = 0, maxval = 200, group = G_LN)
// One column per range, decided in advance. Two ranges whose levels sit a few points apart
// would otherwise put their names on top of each other at the one right-hand edge.
int   rangeStep = input.int(30, "Extra bars per timeframe", minval = 0, maxval = 200, group = G_LN, tooltip = "Each higher timeframe on the chart reaches this many bars further right than the one below it, so the senior range names its levels furthest out and two ranges with levels a few points apart never stack their names. Ranked by timeframe, not by slot. 0 puts every range in one column.")
int   labelGap  = input.int(2, "Gap from the lines (bars)", minval = 0, maxval = 100, group = G_LN, tooltip = "Extra bars between the right end of a line and its name. Raise it to move the names further right, clear of another script's labels at the same edge.")

// == INPUTS - TEXT ===========================================================

const string G_TX = "Text"

string txtSizeIn = input.string("small", "Size", options = ["tiny", "small", "normal"], group = G_TX, tooltip = "The names on the chart and the table together.")
color  txtCol    = input.color(color.new(#000000, 0), "Colour", group = G_TX, tooltip = "The names on the chart and the table text together.")
bool   showPrice = input.bool(false, "Show the price in the names", group = G_TX, tooltip = "12H ranges and above only. Below that the levels sit close to price and the axis already reads them.")
bool   sessNames = input.bool(true, "Name session highs and lows", group = G_TX, tooltip = "A range high or low that is also the high or low of the Asia (18:00-00:00), London (02:00-05:00) or NY (09:30-11:00) session, New York time, says so - e.g. 1D Low + NY Low. Read from the chart's own candles, so it runs on 1H charts and below.")

// == INPUTS - TABLE ==========================================================

const string G_RD = "Table"

bool   showRead = input.bool(true, "Show the table", group = G_RD, tooltip = "One line per range, lowest timeframe first: Swing or Period, which way it is working, where price sits in it, and whether its held high and low have been swept (✓ swept, × not). Below, ADR / AWR / AMR with the share used and the time to the close.")
string readPos  = input.string("Top Right", "Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = G_RD)
bool   showAvg  = input.bool(true, "Show average ranges", group = G_RD, tooltip = "Adds ADR / AWR / AMR: the average of the last 5 completed daily, 4 weekly and 3 monthly ranges, how much of each the current period has already used, and how long it has left to run.")
bool   showTimers = input.bool(true, "Show the close countdown", group = G_RD)

// The average-range lookbacks are fixed at one trading week of days, one month of weeks and
// one quarter of months - the conventional read - rather than three more settings.
const int ADR_LEN = 5
const int AWR_LEN = 4
const int AMR_LEN = 3

// == TYPES ===================================================================

//@type Every drawing one range owns, held together so they are erased together. Names are
//      not among them: they are settled across all three ranges at once and so are owned
//      by the name store rather than by any single range.
type DrDraw
    box   premBox = na
    box   discBox = na
    line  hiLine  = na
    line  loLine  = na
    line  eqLine  = na
    label premLbl = na
    label discLbl = na

//@type One range reduced to its two prices, its two origin times and its direction.
//      A boundary is provisional while price has carried it past the swing that set it,
//      which is why the origin of a LINE and the start of the RANGE are held apart: the
//      line begins at the candle currently holding its price, the range began when its
//      two swings first both existed, and a raid moves the first without moving the second.
type DrState
    float hiPrice  = na
    int   hiTime   = 0
    float loPrice  = na
    int   loTime   = 0
    int   swHiTime = 0
    int   swLoTime = 0
    int   dir      = 0
    bool  valid    = false
    bool  hiProv   = false
    bool  loProv   = false

// == HELPERS =================================================================

//@function Maps the timeframe choice to its Pine period string
//@param pick (simple string) One of the six range timeframes
//@returns (simple string) Period string for request.security
f_tfCode(simple string pick) => switch pick
    "1H"      => "60"
    "4H"      => "240"
    "12H"     => "720"
    "Daily"   => "D"
    "Weekly"  => "W"
    =>           "M"

//@function Short tag used in every label and table row
//@param pick (string) One of the six range timeframes
//@returns (string) Tag text
f_tfTag(string pick) => switch pick
    "Daily"   => "1D"
    "Weekly"  => "1W"
    "Monthly" => "1M"
    =>           pick

//@function Resolves a size input string to a Pine size constant
//@param sizeName (string) One of "tiny", "small", "normal", "large"
//@returns (string) Matching size.* constant
f_size(string sizeName) => switch sizeName
    "tiny"   => size.tiny
    "normal" => size.normal
    "large"  => size.large
    =>          size.small

string txtSize = f_size(txtSizeIn)

//@function Resolves the table position input to a table position constant
//@param posName (string) Chosen corner
//@returns (string) Matching position.* constant
f_tblPos(string posName) => switch posName
    "Middle Right" => position.middle_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    "Bottom Left"  => position.bottom_left
    =>                position.top_right

//@function Callout style for a label side. A left-pointing callout centres its body
//          vertically on the anchor and extends it right; a right-pointing one extends
//          it left. A downward callout carries its body above the anchor, the upward one
//          below. Text naming a price level is never style_none, which would float it
//          off its own line.
//@param side (string) "Right" | "Left" | "Above" | "Below" | "InTop" | "InBot"
//@returns (string) Matching label.style_* constant
f_lblStyle(string side) => switch side
    "Left"   => label.style_label_right
    "InTop"  => label.style_label_upper_right
    "InBot"  => label.style_label_lower_right
    "Above"  => label.style_label_down
    "Below"  => label.style_label_up
    =>          label.style_label_left

//@function Resolves one level's label side from the range's placement.
//
//          Centred moves the two EDGES only - the high centred above its line, the low
//          centred below its own. The equilibrium stays at the right, because a range's
//          edges have empty chart above and below them to be named into and its middle does
//          not: a centred equilibrium lands its text in the candles it is read against.
//@param mode   (string) The range's placement: Right, Centred, Inside corners, Left or Off
//@param isEdge (bool)   True for the two boundaries, false for the equilibrium
//@param isLow  (bool)   True for the level that sits at the bottom of the range
//@returns (string) Side to place this label on
f_side(string mode, bool isEdge, bool isLow) =>
    string outSide = switch mode
        "Centred" => isEdge ? (isLow ? "Below" : "Above") : "Right"
        "Inside corners" => isEdge ? (isLow ? "InBot" : "InTop") : "Right"
        "Left"    => "Left"
        "Off"     => "Off"
        =>           "Right"
    outSide

//@function Time of the bar a given number of bars past the last one, counted in real bars
//          of the chart's session. Adding bar lengths to the clock instead puts every time
//          that falls in a closed market - a weekend, the daily break - on the next open, so
//          two columns set apart by a few bars would land on the same spot.
//@param bars (int) Bars past the last bar; capped at the 500 Pine can reach
//@returns (int) Bar time in milliseconds
f_futureT(int bars) =>
    time(timeframe.period, bars_back = -math.min(bars, 500))

//@function Anchor time for a label, from its side
//@param side      (string) Side choice
//@param leftT     (int)    Time the range starts
//@param rightT    (int)    Time of the live edge
//@param rightBars (int)    Bars from the last bar to the live edge
//@returns (int) Anchor time in milliseconds
f_lblTime(string side, int leftT, int rightT, int rightBars) =>
    switch side
        "Left"   => leftT
        "Above"  => int(math.avg(leftT, rightT))
        "Below"  => int(math.avg(leftT, rightT))
        "InTop"  => rightT
        "InBot"  => rightT
        =>          f_futureT(rightBars + labelGap)

// == SESSION NAMES ==
// Each session's running high and low, and the last few finished ones, so a range edge
// that is also a session's extreme can carry that session's name.

//@type One session's extremes
//@field name  (string)       Session name used in the label
//@field runHi (float)        High of the session in progress
//@field runLo (float)        Low of the session in progress
//@field his   (array<float>) Highs of finished sessions, newest first
//@field los   (array<float>) Lows of finished sessions, newest first
type SessBook
    string       name
    float        runHi = na
    float        runLo = na
    array<float> his
    array<float> los

//@function Carries a session's extremes forward one bar
//@param b      (SessBook) The session
//@param inNow  (bool)     This bar is inside the session
//@param inPrev (bool)     The previous bar was inside it
//@returns (bool) Always true
f_sessStep(SessBook b, bool inNow, bool inPrev) =>
    if not inNow and inPrev and not na(b.runHi)
        b.his.unshift(b.runHi)
        b.los.unshift(b.runLo)
        if b.his.size() > 10
            b.his.pop()
            b.los.pop()
        b.runHi := na
        b.runLo := na
    if inNow
        b.runHi := na(b.runHi) or not inPrev ? high : math.max(b.runHi, high)
        b.runLo := na(b.runLo) or not inPrev ? low : math.min(b.runLo, low)
    true

//@function Whether a range edge is this session's high or low, now or in the last ten
//@param b      (SessBook) The session
//@param price  (float)    The range edge
//@param isHigh (bool)     True for a range high
//@returns (bool) True when the edge is this session's extreme
f_sessHit(SessBook b, float price, bool isHigh) =>
    float tol = syminfo.mintick * 0.5
    float run = isHigh ? b.runHi : b.runLo
    bool  hit = not na(run) and math.abs(run - price) <= tol
    array<float> past = isHigh ? b.his : b.los
    if not hit and past.size() > 0
        for v in past
            if math.abs(v - price) <= tol
                hit := true
                break
    hit

string SESS_TZ = "America/New_York"
// The three session windows, New York time. Fixed rather than settings: they name a level,
// they do not change what the range is.
const string SESS_ASIA = "1800-0000"
const string SESS_LON  = "0200-0500"
const string SESS_NY   = "0930-1100"
var SessBook bookAsia = SessBook.new("Asia", his = array.new<float>(), los = array.new<float>())
var SessBook bookLon  = SessBook.new("London", his = array.new<float>(), los = array.new<float>())
var SessBook bookNy   = SessBook.new("NY", his = array.new<float>(), los = array.new<float>())
bool inAsiaS = not na(time(timeframe.period, SESS_ASIA, SESS_TZ))
bool inLonS  = not na(time(timeframe.period, SESS_LON, SESS_TZ))
bool inNyS   = not na(time(timeframe.period, SESS_NY, SESS_TZ))
f_sessStep(bookAsia, inAsiaS, inAsiaS[1])
f_sessStep(bookLon, inLonS, inLonS[1])
f_sessStep(bookNy, inNyS, inNyS[1])
bool sessOk = sessNames and timeframe.isintraday and timeframe.in_seconds() <= 3600

//@function The session a range edge shares, as a name suffix, e.g. " + NY Low"
//@param price  (float) The range edge
//@param isHigh (bool)  True for a range high
//@returns (string) The suffix, or empty
f_sessTag(float price, bool isHigh) =>
    string side = isHigh ? " High" : " Low"
    string out  = ""
    if sessOk
        if f_sessHit(bookNy, price, isHigh)
            out := " + NY" + side
        else if f_sessHit(bookLon, price, isHigh)
            out := " + London" + side
        else if f_sessHit(bookAsia, price, isHigh)
            out := " + Asia" + side
    out

// == NAME QUEUE ==============================================================
// Every name is queued here before any of it is drawn. Three ranges can put eleven names
// on one right edge, and two of them being the SAME level - or merely close enough to sit
// on top of each other - is a fact about the whole set, not about either name on its own.
// Drawing as we go would settle each one before the set was known.

var array<float>  qPrice  = array.new<float>(0)
var array<string> qName   = array.new<string>(0)
var array<string> qSide   = array.new<string>(0)
var array<int>    qAnchor = array.new<int>(0)
var array<bool>   qPriced = array.new<bool>(0)
var array<label>  nameStore = array.new<label>(0)

//@function Queues one name to be settled and drawn later
//@param anchorT (int)    Anchor time
//@param price   (float)  Exact price the text names
//@param name    (string) Level name, without its price
//@param side    (string) Side choice, driving the callout style
//@param priced  (bool)   Whether this name carries a price at all - a zone caption does not
//@returns (bool) Always true
f_queue(int anchorT, float price, string name, string side, bool priced) =>
    qPrice.push(price)
    qName.push(name)
    qSide.push(side)
    qAnchor.push(anchorT)
    qPriced.push(priced)
    true

//@function Settles the queued names and draws them.
//
//          Names sitting on the SAME price are one level wearing two hats - a 4H swing high
//          that is also the daily swing high - so they combine into a single name at the end
//          of the longer line, and the price is stated once. Right-side names merge across
//          columns; any other side only at one anchor. Names merely close together are left
//          at their own prices: each range has its own column, and nudging a name off its
//          price to dodge a neighbour is how a name ends up naming nothing.
//@param sz (string) Resolved size.* constant
//@returns (bool) Always true
f_flushNames(string sz) =>
    while nameStore.size() > 0
        label.delete(nameStore.shift())

    int total = qName.size()
    if total > 0
        // A tick of tolerance, not zero: two swings on the same level can differ by the
        // float noise of a midpoint without being two different prices.
        float sameTol = syminfo.mintick * 0.5

        array<bool>   live  = array.new<bool>(total, true)
        array<string> shown = array.new<string>(total, "")

        for i = 0 to total - 1
            if live.get(i)
                string joined = qName.get(i)
                bool   priced = qPriced.get(i)
                // Guarded, not merely bounded. A Pine for loop whose start exceeds its end
                // counts DOWNWARD rather than skipping, so on the last name this inner scan
                // would run backwards from one past the end of the array.
                if i < total - 1
                    for j = i + 1 to total - 1
                        if live.get(j) and qSide.get(j) == qSide.get(i) and (qSide.get(i) == "Right" or qAnchor.get(j) == qAnchor.get(i)) and math.abs(qPrice.get(j) - qPrice.get(i)) <= sameTol
                            joined := joined + " + " + qName.get(j)
                            priced := priced or qPriced.get(j)
                            live.set(j, false)
                            // The combined name moves to the furthest column, so no line of
                            // either range runs on through the text.
                            qAnchor.set(i, math.max(qAnchor.get(i), qAnchor.get(j)))
                shown.set(i, priced and showPrice ? joined + "  " + str.tostring(qPrice.get(i), format.mintick) : joined)

        for i = 0 to total - 1
            if live.get(i)
                label made = label.new(qAnchor.get(i), qPrice.get(i), shown.get(i), xloc = xloc.bar_time, style = f_lblStyle(qSide.get(i)), color = color.new(color.white, 100), textcolor = txtCol, size = sz, textalign = text.align_left)
                label.set_text_font_family(made, font.family_monospace)
                nameStore.push(made)

    qPrice.clear()
    qName.clear()
    qSide.clear()
    qAnchor.clear()
    qPriced.clear()
    true

//@function Newest confirmed swing high and swing low, evaluated inside the requested
//          timeframe's own context. The candidate sits len + 1 bars back, so every
//          candle the test reads has already closed and a forming higher-timeframe
//          candle can neither confirm nor unconfirm a swing.
//@param len      (simple int)  Candles either side that must fail to exceed the swing
//@param needTurn (simple bool) Also require the change of direction
//@returns (tuple) Swing high, its time, swing low, its time, and which formed last
f_swings(simple int len, simple bool needTurn) =>
    var float sHi  = na
    var int   sHiT = 0
    var float sLo  = na
    var int   sLoT = 0
    var int   last = 0

    int p = len + 1

    // The neighbours are read as running extremes rather than walked one at a time, so
    // every history offset stays a fixed number and the series needs no extra buffer.
    float olderHi = ta.highest(high, len)[p + 1]
    float newerHi = ta.highest(high, len)[1]
    float olderLo = ta.lowest(low, len)[p + 1]
    float newerLo = ta.lowest(low, len)[1]

    bool geoHi = high[p] > olderHi and high[p] > newerHi
    bool geoLo = low[p] < olderLo and low[p] < newerLo

    bool up    = close[p] > open[p]
    bool dn    = close[p] < open[p]
    bool upOld = close[p + 1] > open[p + 1]
    bool dnOld = close[p + 1] < open[p + 1]
    bool upNew = close[p - 1] > open[p - 1]
    bool dnNew = close[p - 1] < open[p - 1]

    // The turn may straddle the swing either way round: the swing candle is whichever of
    // the pair holds the extreme, so a high qualifies as the down candle following the up
    // one, or as the up candle preceding a down one.
    bool okHi = geoHi and (not needTurn or ((dn and upOld) or (up and dnNew)))
    bool okLo = geoLo and (not needTurn or ((up and dnOld) or (dn and upNew)))

    if okHi
        sHi  := high[p]
        sHiT := time[p]
    if okLo
        sLo  := low[p]
        sLoT := time[p]

    // One outside candle holds both extremes at once. The end it closed toward is the end
    // it reached last, so its own close decides which side of the range is the newer one.
    if okHi and okLo
        last := close[p] > open[p] ? -1 : 1
    else if okHi
        last := -1
    else if okLo
        last := 1

    [sHi, sHiT, sLo, sLoT, last]

//@function The swing dealing range, held until a candle closes through a side, evaluated
//          inside the requested timeframe's own context on closed candles only.
//
//          It forms on the newest confirmed swing high and swing low. From then on it
//          ignores sweeps and internal swings. A close above the high rebuilds it: the far
//          edge becomes that candle's high and follows new highs, and the near edge becomes
//          the lowest low printed since the old high was set - the swing that launched the
//          break. The far edge stays provisional until len candles have closed without
//          exceeding it. A close below the low mirrors it.
//@param len      (simple int)  Swing strength - forms the first range and settles the far edge
//@param needTurn (simple bool) Require a direction turn for the first two swings
//@returns (tuple) High, its candle time, low, its candle time, direction (1 up, -1 down),
//         which edge is still provisional (1 the high, -1 the low, 0 neither), the time of
//         the last rebuild, and whether the held high and the held low have been swept
f_dealRange(simple int len, simple bool needTurn) =>
    [sHi, sHiT, sLo, sLoT, sLast] = f_swings(len, needTurn)

    var float rHi      = na
    var int   rHiT     = 0
    var float rLo      = na
    var int   rLoT     = 0
    var int   rDir     = 0
    var int   farSide  = 0
    var int   farAge   = 0
    // The lowest low since the high was set, and the highest high since the low was:
    // the near edge waiting for the opposite side to break.
    var float loAfter  = na
    var int   loAfterT = 0
    var float hiAfter  = na
    var int   hiAfterT = 0
    // When the range last rebuilt on a close, and whether each held edge has been swept -
    // wicked through by a closed candle that closed back inside - since then.
    var int   rebT     = 0
    var bool  sweptHi  = false
    var bool  sweptLo  = false

    // Only the last closed candle is read, never the forming one.
    float h1 = high[1]
    float l1 = low[1]
    float c1 = close[1]
    int   t1 = time[1]

    if na(rHi) or na(rLo)
        if not na(sHi) and not na(sLo) and sHi > sLo
            rHi  := sHi
            rHiT := sHiT
            rLo  := sLo
            rLoT := sLoT
            rDir := sLoT > sHiT ? 1 : -1
            if sLoT > sHiT
                loAfter  := sLo
                loAfterT := sLoT
            else
                hiAfter  := sHi
                hiAfterT := sHiT
    else if not na(c1)
        bool setHi = false
        bool setLo = false
        if farSide == 1 and h1 > rHi
            // A broken range's far edge follows price until price turns.
            rHi    := h1
            rHiT   := t1
            farAge := 0
            setHi  := true
        else if farSide == -1 and l1 < rLo
            rLo    := l1
            rLoT   := t1
            farAge := 0
            setLo  := true
        else if c1 > rHi
            bool freshLo = na(loAfter) or l1 < loAfter
            rLo     := freshLo ? l1 : loAfter
            rLoT    := freshLo ? t1 : loAfterT
            rHi     := h1
            rHiT    := t1
            rDir    := 1
            farSide := 1
            farAge  := 0
            setHi   := true
            rebT    := t1
            sweptHi := false
            sweptLo := false
        else if c1 < rLo
            bool freshHi = na(hiAfter) or h1 > hiAfter
            rHi     := freshHi ? h1 : hiAfter
            rHiT    := freshHi ? t1 : hiAfterT
            rLo     := l1
            rLoT    := t1
            rDir    := -1
            farSide := -1
            farAge  := 0
            setLo   := true
            rebT    := t1
            sweptHi := false
            sweptLo := false
        else if farSide != 0
            farAge += 1
            if farAge >= len
                farSide := 0

        // A held edge wicked through and closed back inside is a sweep. The far edge of a
        // broken range is not held, so a new extreme there is the range extending instead.
        if not setHi and not setLo
            if farSide != 1 and h1 > rHi
                sweptHi := true
            if farSide != -1 and l1 < rLo
                sweptLo := true

        if setHi
            loAfter  := na
            loAfterT := 0
        else if na(loAfter) or l1 < loAfter
            loAfter  := l1
            loAfterT := t1
        if setLo
            hiAfter  := na
            hiAfterT := 0
        else if na(hiAfter) or h1 > hiAfter
            hiAfter  := h1
            hiAfterT := t1

    [rHi, rHiT, rLo, rLoT, rDir, farSide, rebT, sweptHi, sweptLo]

//@function Follows one boundary out to the extreme price has reached since its swing
//          confirmed. Called once per boundary at script scope and never inside a
//          condition - it carries state between bars, and a skipped bar is a missed
//          extreme. Each call site keeps its own state.
//@param swingPrice (float) The confirmed swing price
//@param swingTime  (int)   Time of the swing candle
//@param isHigh     (bool)  True for the upper boundary
//@param enabled    (bool)  False pins the boundary to its swing
//@returns (tuple) Boundary price, the time of the candle holding it, and whether it has
//         been carried past its swing
f_running(float swingPrice, int swingTime, bool isHigh, bool enabled) =>
    var float lvl   = na
    var int   lvlT  = 0
    var int   seenT = 0

    // A new swing resets the boundary onto it. The reset is keyed to the swing's TIME,
    // not its price: two swings at the same price are still two different swings, and a
    // boundary left carried out from the older one would be a level nothing set.
    if swingTime != seenT
        seenT := swingTime
        lvl   := swingPrice
        lvlT  := swingTime

    if enabled and not na(lvl)
        if isHigh and high > lvl
            lvl  := high
            lvlT := time
        if not isHigh and low < lvl
            lvl  := low
            lvlT := time

    [lvl, lvlT, not na(lvl) and not na(swingPrice) and lvl != swingPrice]

//@function Deletes every drawing a range owns
//@param d (DrDraw) Drawing set to erase
//@returns (bool) Always true
f_erase(DrDraw d) =>
    box.delete(d.premBox)
    box.delete(d.discBox)
    line.delete(d.hiLine)
    line.delete(d.loLine)
    line.delete(d.eqLine)
    label.delete(d.premLbl)
    label.delete(d.discLbl)
    true

//@function Draws one dealing range - its shading first so the levels sit over it, then
//          the two boundaries, the equilibrium and their names.
//@param d          (DrDraw)  Drawing set to fill
//@param s          (DrState) The range's prices, origins and direction
//@param tag        (string)  Name prefix for the labels, e.g. "1W Swing"
//@param wantShade  (bool)    Fill premium and discount
//@param wantNames  (bool)    Name the two halves, bold in the centre of each (Atlas §5.1)
//@param lnWidth    (int)     Boundary line width
//@param rightBars  (int)     Bars from the last bar to this range's live edge
//@param mode       (string)  This range's label placement
//@param priceOk    (bool)    This range may carry a price in its names
//@returns (bool) Always true
f_draw(DrDraw d, DrState s, string tag, bool wantShade, bool wantNames, int lnWidth, int rightBars, string mode, bool priceOk) =>
    f_erase(d)
    if s.valid
        int   rightT  = f_futureT(rightBars)
        float eqPrice = math.avg(s.hiPrice, s.loPrice)
        // Everything the range draws starts at its first swing. A boundary carried out by a
        // raid widens the range without restarting it, so it does not move that start.
        int   leftT = s.swHiTime > s.swLoTime ? s.swLoTime : s.swHiTime

        if wantShade
            color premFill = color.new(premCol, shadeT)
            color discFill = color.new(discCol, shadeT)
            d.premBox := box.new(f_xClamp(leftT), s.hiPrice, rightT, eqPrice, xloc = xloc.bar_time, border_color = premFill, border_width = 1, border_style = line.style_solid, bgcolor = premFill)
            d.discBox := box.new(f_xClamp(leftT), eqPrice, rightT, s.loPrice, xloc = xloc.bar_time, border_color = discFill, border_width = 1, border_style = line.style_solid, bgcolor = discFill)

        // The two boundaries are the range's buyside and sellside liquidity. They draw solid - but dotted
        // while price has carried one past its swing, because a level price has not turned
        // at yet is a raid in progress, not a confirmed edge. The equilibrium is a midline and
        // always dotted.
        d.hiLine := line.new(f_xClamp(leftT), s.hiPrice, rightT, s.hiPrice, xloc = xloc.bar_time, color = bndCol, width = lnWidth, style = s.hiProv ? line.style_dotted : line.style_solid)
        d.loLine := line.new(f_xClamp(leftT), s.loPrice, rightT, s.loPrice, xloc = xloc.bar_time, color = bndCol, width = lnWidth, style = s.loProv ? line.style_dotted : line.style_solid)
        d.eqLine := line.new(f_xClamp(leftT), eqPrice, rightT, eqPrice, xloc = xloc.bar_time, color = eqCol, width = 1, style = line.style_dotted)

        // Names are queued rather than drawn. Three ranges put up to nine of them on the
        // chart, and whether two of those are the same level cannot be known until every
        // range has had its say. f_flushNames settles that once, for all of them together.
        string useHi = f_side(mode, true, false)
        string useLo = f_side(mode, true, true)
        string useEq = f_side(mode, false, false)

        if useHi != "Off"
            f_queue(f_lblTime(useHi, leftT, rightT, rightBars), s.hiPrice, tag + " High" + f_sessTag(s.hiPrice, true), useHi, priceOk)
        if useLo != "Off"
            f_queue(f_lblTime(useLo, leftT, rightT, rightBars), s.loPrice, tag + " Low" + f_sessTag(s.loPrice, false), useLo, priceOk)
        if useEq != "Off"
            f_queue(f_lblTime(useEq, leftT, rightT, rightBars), eqPrice, tag + " EQ", useEq, priceOk)

        if wantShade and wantNames
            // Each half named bold in its own centre - across the range's span and halfway
            // up the half - so the words sit clear of the high, the low, the equilibrium and
            // their names. Owned by the range, not the name queue: they name a band, not a
            // price, so there is nothing to merge them with.
            int   midT    = int(math.avg(f_xClamp(leftT), rightT))
            float premMid = math.avg(s.hiPrice, eqPrice)
            float discMid = math.avg(eqPrice, s.loPrice)
            d.premLbl := label.new(midT, premMid, "Premium", xloc = xloc.bar_time, style = label.style_label_center, color = color.new(color.white, 100), textcolor = txtCol, size = txtSize, text_font_family = font.family_monospace, text_formatting = text.format_bold)
            d.discLbl := label.new(midT, discMid, "Discount", xloc = xloc.bar_time, style = label.style_label_center, color = color.new(color.white, 100), textcolor = txtCol, size = txtSize, text_font_family = font.family_monospace, text_formatting = text.format_bold)
    true

//@function Where price sits relative to a range, as a percentage of the range travelled
//@param s (DrState) The range
//@returns (float) 0 at the low, 100 at the high, outside that when price has left the range
f_position(DrState s) =>
    float span = s.valid ? s.hiPrice - s.loPrice : na
    span > 0 ? (close - s.loPrice) / span * 100.0 : na

//@function Names the half of the range price is trading in
//@param pct (float) Position from f_position
//@returns (string) Zone name
f_zone(float pct) =>
    string zoneName = switch
        na(pct)    => "-"
        pct > 100  => "Above range"
        pct < 0    => "Below range"
        pct > 50   => "Premium"
        pct < 50   => "Discount"
        =>            "At EQ"
    zoneName

//@function Names the direction a range is working, from the swing that formed last
//@param dirValue (int) 1 when the low is newer, -1 when the high is
//@returns (string) Direction name
f_dirName(int dirValue) =>
    string dirText = switch
        dirValue > 0 => "Bullish"
        dirValue < 0 => "Bearish"
        =>              "-"
    dirText

//@function Zero-pads a clock component to two digits
//@param value (int) Hours, minutes or seconds
//@returns (string) Two-character string
f_pad2(int value) => (value < 10 ? "0" : "") + str.tostring(value)

//@function Time left until a period closes, as a clock
//@param closeMs (int) Timestamp the period closes at
//@returns (string) Countdown, or a dash when the close is unknown or already past
f_countdown(int closeMs) =>
    string out = "-"
    if not na(closeMs)
        int rem = closeMs - timenow
        if rem > 0
            int totSec = int(rem / 1000)
            int days   = int(totSec / 86400)
            int hrs    = int((totSec % 86400) / 3600)
            int mins   = int((totSec % 3600) / 60)
            int secs   = totSec % 60
            out := days > 0 ? str.tostring(days) + "d " + f_pad2(hrs) + "h" : f_pad2(hrs) + ":" + f_pad2(mins) + ":" + f_pad2(secs)
    out

// == RESOLVED SETTINGS =======================================================

simple string tfCode1 = f_tfCode(tfPick1)
simple string tfCode2 = f_tfCode(tfPick2)
simple string tfCode3 = f_tfCode(tfPick3)

string tag1 = f_tfTag(tfPick1)
string tag2 = f_tfTag(tfPick2)
string tag3 = f_tfTag(tfPick3)

// "1M High" is this month's high; "1M Swing High" is the monthly swing high. Two different
// levels that would otherwise wear the same name on the same chart.
string lblTag1 = srcPick1 == "Swing" ? tag1 + " Swing" : tag1
string lblTag2 = srcPick2 == "Swing" ? tag2 + " Swing" : tag2
string lblTag3 = srcPick3 == "Swing" ? tag3 + " Swing" : tag3


// == TIMEFRAME RANK ==========================================================
// Column, line width and table row follow the TIMEFRAME, not the slot a range sits in: a Weekly
// range in slot 1 beside a 1H range in slot 2 still reaches furthest right, draws heaviest and
// lists last. Only ranges switched on are counted, so the columns stay packed; two ranges on
// the same timeframe keep their slot order.

//@function Rank of one range among the ranges switched on: 0 for the lowest timeframe
//@param mySec  (int)  This range's timeframe in seconds
//@param mySlot (int)  This range's slot, 1 to 3
//@param sec1   (int)  Range 1's timeframe in seconds
//@param sec2   (int)  Range 2's timeframe in seconds
//@param sec3   (int)  Range 3's timeframe in seconds
//@returns (int) How many switched-on ranges sit below this one
f_rank(int mySec, int mySlot, int sec1, int sec2, int sec3) =>
    int below = 0
    if on1 and mySlot != 1 and (sec1 < mySec or (sec1 == mySec and 1 < mySlot))
        below += 1
    if on2 and mySlot != 2 and (sec2 < mySec or (sec2 == mySec and 2 < mySlot))
        below += 1
    if on3 and mySlot != 3 and (sec3 < mySec or (sec3 == mySec and 3 < mySlot))
        below += 1
    below

int sec1 = timeframe.in_seconds(tfCode1)
int sec2 = timeframe.in_seconds(tfCode2)
int sec3 = timeframe.in_seconds(tfCode3)
int rank1 = f_rank(sec1, 1, sec1, sec2, sec3)
int rank2 = f_rank(sec2, 2, sec1, sec2, sec3)
int rank3 = f_rank(sec3, 3, sec1, sec2, sec3)

// A range measured on a timeframe at or below the chart's own is the chart redrawn, so
// it is withheld and said so rather than drawn as something it is not.
bool fits1 = timeframe.in_seconds(tfCode1) > timeframe.in_seconds()
bool fits2 = timeframe.in_seconds(tfCode2) > timeframe.in_seconds()
bool fits3 = timeframe.in_seconds(tfCode3) > timeframe.in_seconds()

// == HIGHER TIMEFRAME SWINGS =================================================
// One call per range, always evaluated. A request is never reduced by a toggle, so
// gating these would cost nothing and only make the load harder to read.
//
// Lookahead is ON, and it reveals nothing. The range reads no candle newer than
// one bar back, so every value it returns for a higher-timeframe bar was already
// settled before that bar opened. Lookahead therefore only stops the result being held
// back until the bar it was known in has closed - it hands over a fact on the bar it
// became a fact, rather than a bar late. Off would cost a full higher-timeframe candle
// of delay and buy nothing.

[hi1, hiT1, lo1, loT1, dir1, far1, reb1, swH1, swL1] = request.security(syminfo.tickerid, tfCode1, f_dealRange(swingLen, requireTurn), lookahead = barmerge.lookahead_on)
[hi2, hiT2, lo2, loT2, dir2, far2, reb2, swH2, swL2] = request.security(syminfo.tickerid, tfCode2, f_dealRange(swingLen, requireTurn), lookahead = barmerge.lookahead_on)
[hi3, hiT3, lo3, loT3, dir3, far3, reb3, swH3, swL3] = request.security(syminfo.tickerid, tfCode3, f_dealRange(swingLen, requireTurn), lookahead = barmerge.lookahead_on)

// == PERIOD EXTREMES =========================================================
// Deliberately a SEPARATE request with lookahead OFF, and it cannot ride along on the
// swing call above. The swing call reads no candle newer than one bar back, which is what
// makes lookahead harmless there. These read the FORMING candle at offset zero, where
// lookahead is the whole problem: it would hand back the period's finished high on the
// first bar of that period, so every historical month would open already knowing where it
// was going to top out - and the running-extreme pass, finding nothing left to exceed,
// would anchor the level to the period's open instead of the candle that made it.
// Off returns the period's high SO FAR, which is what a forming range actually is.

[pHi1, pLo1, pT1] = request.security(syminfo.tickerid, tfCode1, [high, low, time], lookahead = barmerge.lookahead_off)
[pHi2, pLo2, pT2] = request.security(syminfo.tickerid, tfCode2, [high, low, time], lookahead = barmerge.lookahead_off)
[pHi3, pLo3, pT3] = request.security(syminfo.tickerid, tfCode3, [high, low, time], lookahead = barmerge.lookahead_off)

// == RANGE SOURCE ============================================================
// Period or Swing, per range. Under Period both ends seed from the period's own start, so
// the range begins at the open, is bounded by nothing but this period's own trade, and is
// gone at the rollover - one month is one range. Under Swing they seed from their two
// confirmed swings, which owe nothing to the calendar.

bool per1 = srcPick1 == "Period"
bool per2 = srcPick2 == "Period"
bool per3 = srcPick3 == "Period"

float rawHi1 = per1 ? pHi1 : hi1
float rawLo1 = per1 ? pLo1 : lo1
int   rawHiT1 = per1 ? pT1 : hiT1
int   rawLoT1 = per1 ? pT1 : loT1

float rawHi2 = per2 ? pHi2 : hi2
float rawLo2 = per2 ? pLo2 : lo2
int   rawHiT2 = per2 ? pT2 : hiT2
int   rawLoT2 = per2 ? pT2 : loT2

float rawHi3 = per3 ? pHi3 : hi3
float rawLo3 = per3 ? pLo3 : lo3
int   rawHiT3 = per3 ? pT3 : hiT3
int   rawLoT3 = per3 ? pT3 : loT3

// == RUNNING BOUNDARIES ======================================================
// A confirmed swing is the last level price TURNED at, which is not always the edge of
// the range price is in right now - the moment a boundary is raided, the range being
// traded is already wider than the one the swings describe. Each boundary is therefore
// carried out to the extreme price has actually reached since its swing confirmed, and
// draws dotted while it is out there, because a level price has not yet turned at is a
// raid in progress and not structure. It settles back to solid the moment a new swing
// confirms behind it.
//
// These run on every bar, never inside a condition: they carry state between bars, and
// a skipped bar is a missed extreme.

// Period ranges always track, whatever the toggle says. There the tracking is not carrying
// a boundary past a swing - the period's high IS its running high - it is only there to
// find the exact candle that set it, so the level starts where the price began.
// A swing range tracks only its far edge after a break. A held edge never follows price:
// a wick through it that closes back inside is a sweep, and the range ignores it.

[liveHi1, liveHiT1, provHi1] = f_running(rawHi1, rawHiT1, true, per1 or (trackRunning and far1 == 1))
[liveLo1, liveLoT1, provLo1] = f_running(rawLo1, rawLoT1, false, per1 or (trackRunning and far1 == -1))
[liveHi2, liveHiT2, provHi2] = f_running(rawHi2, rawHiT2, true, per2 or (trackRunning and far2 == 1))
[liveLo2, liveLoT2, provLo2] = f_running(rawLo2, rawLoT2, false, per2 or (trackRunning and far2 == -1))
[liveHi3, liveHiT3, provHi3] = f_running(rawHi3, rawHiT3, true, per3 or (trackRunning and far3 == 1))
[liveLo3, liveLoT3, provLo3] = f_running(rawLo3, rawLoT3, false, per3 or (trackRunning and far3 == -1))

//@function Which end of a period range formed most recently, read from the two origin
//          candles. A period has no confirmed swings to order, but it still has a shape:
//          the end price reached last is the one it is working away from.
//@param hiWhen (int) Time of the candle holding the high
//@param loWhen (int) Time of the candle holding the low
//@returns (int) 1 when the low came last, -1 when the high did, 0 when neither has
f_periodDir(int hiWhen, int loWhen) =>
    int outDir = hiWhen > loWhen ? -1 : hiWhen < loWhen ? 1 : 0
    outDir

int dirUse1 = per1 ? f_periodDir(liveHiT1, liveLoT1) : dir1
int dirUse2 = per2 ? f_periodDir(liveHiT2, liveLoT2) : dir2
int dirUse3 = per3 ? f_periodDir(liveHiT3, liveLoT3) : dir3

// == REAL-BAR ANCHORS ========================================================
// A higher-timeframe swing knows its CANDLE, not its bar: the time the range hands back is the
// open of the weekly (or daily, or 4H) candle that made the high, which can sit days left of
// the chart bar that actually printed it. Each range's timeframe is followed here on the
// chart's own bars - time(tf) is a plain built-in, not a request - and the bar that printed
// each candle's high and low is recorded, keyed by that candle's open. A swing older than the
// loaded history has no bar to find and falls back to its candle's open.

//@variable Candles remembered per timeframe; older swings fall back to their candle's open
const int ANCHOR_KEEP = 600

//@function Follows one higher timeframe's candles on the chart's bars and records, for each
//          candle, the time of the chart bar that printed its high and the one that printed
//          its low. Runs on every bar, never inside a condition: it carries state.
//@param tf    (simple string) The range's timeframe
//@param hiAt  (map<int, int>) Candle open time -> time of the bar holding its high
//@param loAt  (map<int, int>) Candle open time -> time of the bar holding its low
//@returns (bool) Always true
f_trackBars(simple string tf, map<int, int> hiAt, map<int, int> loAt) =>
    var float cHi = na
    var float cLo = na
    int cOpen = time(tf)
    if not na(cOpen)
        if not hiAt.contains(cOpen)
            cHi := high
            cLo := low
            hiAt.put(cOpen, time)
            loAt.put(cOpen, time)
            if hiAt.size() > ANCHOR_KEEP
                hiAt.remove(hiAt.keys().first())
                loAt.remove(loAt.keys().first())
        else
            if high > cHi
                cHi := high
                hiAt.put(cOpen, time)
            if low < cLo
                cLo := low
                loAt.put(cOpen, time)
    true

//@function The chart bar that printed a candle's extreme, or the candle's open when that bar
//          is older than the loaded history
//@param m       (map<int, int>) The map for that extreme
//@param candleT (int)           The candle's open time
//@returns (int) Bar time to anchor on
f_realT(map<int, int> m, int candleT) =>
    int found = m.get(candleT)
    na(found) ? candleT : found

var map<int, int> hiAt1 = map.new<int, int>()
var map<int, int> loAt1 = map.new<int, int>()
var map<int, int> hiAt2 = map.new<int, int>()
var map<int, int> loAt2 = map.new<int, int>()
var map<int, int> hiAt3 = map.new<int, int>()
var map<int, int> loAt3 = map.new<int, int>()
f_trackBars(tfCode1, hiAt1, loAt1)
f_trackBars(tfCode2, hiAt2, loAt2)
f_trackBars(tfCode3, hiAt3, loAt3)

// Swing ranges only. A boundary still at its candle's price takes that candle's real bar; one
// carried out live by f_running already holds a chart bar's time. Period ranges keep their
// own times: they begin at the period's open by design and f_running finds the real bar.
int hiT1a = per1 or liveHiT1 != rawHiT1 ? liveHiT1 : f_realT(hiAt1, rawHiT1)
int loT1a = per1 or liveLoT1 != rawLoT1 ? liveLoT1 : f_realT(loAt1, rawLoT1)
int swHi1 = per1 ? rawHiT1 : f_realT(hiAt1, rawHiT1)
int swLo1 = per1 ? rawLoT1 : f_realT(loAt1, rawLoT1)
int hiT2a = per2 or liveHiT2 != rawHiT2 ? liveHiT2 : f_realT(hiAt2, rawHiT2)
int loT2a = per2 or liveLoT2 != rawLoT2 ? liveLoT2 : f_realT(loAt2, rawLoT2)
int swHi2 = per2 ? rawHiT2 : f_realT(hiAt2, rawHiT2)
int swLo2 = per2 ? rawLoT2 : f_realT(loAt2, rawLoT2)
int hiT3a = per3 or liveHiT3 != rawHiT3 ? liveHiT3 : f_realT(hiAt3, rawHiT3)
int loT3a = per3 or liveLoT3 != rawLoT3 ? liveLoT3 : f_realT(loAt3, rawLoT3)
int swHi3 = per3 ? rawHiT3 : f_realT(hiAt3, rawHiT3)
int swLo3 = per3 ? rawLoT3 : f_realT(loAt3, rawLoT3)

// Under Period the range began at the period's open, so both "swing" times are that open.
DrState state1 = DrState.new(hiPrice = liveHi1, hiTime = hiT1a, loPrice = liveLo1, loTime = loT1a, swHiTime = swHi1, swLoTime = swLo1, dir = dirUse1, valid = on1 and fits1 and not na(liveHi1) and not na(liveLo1) and liveHi1 > liveLo1, hiProv = provHi1 or (not per1 and far1 == 1), loProv = provLo1 or (not per1 and far1 == -1))
DrState state2 = DrState.new(hiPrice = liveHi2, hiTime = hiT2a, loPrice = liveLo2, loTime = loT2a, swHiTime = swHi2, swLoTime = swLo2, dir = dirUse2, valid = on2 and fits2 and not na(liveHi2) and not na(liveLo2) and liveHi2 > liveLo2, hiProv = provHi2 or (not per2 and far2 == 1), loProv = provLo2 or (not per2 and far2 == -1))
DrState state3 = DrState.new(hiPrice = liveHi3, hiTime = hiT3a, loPrice = liveLo3, loTime = loT3a, swHiTime = swHi3, swLoTime = swLo3, dir = dirUse3, valid = on3 and fits3 and not na(liveHi3) and not na(liveLo3) and liveHi3 > liveLo3, hiProv = provHi3 or (not per3 and far3 == 1), loProv = provLo3 or (not per3 and far3 == -1))

// == DRAWING =================================================================
// Only the range price is in right now carries meaning, so one set of drawings is
// kept and rebuilt on the live edge rather than a trail of retired ranges.

//@function Whether a range carries the Premium and Discount names
//@param slot (int)  This range's slot, 1 to 3
//@param ok   (bool) This range is shaded and has formed
//@param rk   (int)  This range's timeframe rank
//@param okB  (bool) One of the other two ranges is shaded and has formed
//@param rkB  (int)  Its rank
//@param okC  (bool) The remaining range is shaded and has formed
//@param rkC  (int)  Its rank
//@returns (bool) True when this range is the one to name
f_namesFor(int slot, bool ok, int rk, bool okB, int rkB, bool okC, int rkC) =>
    bool pick = switch namesOn
        "Lowest shaded timeframe"  => not ((okB and rkB < rk) or (okC and rkC < rk))
        "Highest shaded timeframe" => not ((okB and rkB > rk) or (okC and rkC > rk))
        "Range 1"                  => slot == 1
        "Range 2"                  => slot == 2
        "Range 3"                  => slot == 3
        =>                            false
    ok and pick

var DrDraw draw1 = DrDraw.new()
var DrDraw draw2 = DrDraw.new()
var DrDraw draw3 = DrDraw.new()

if barstate.islast
    // Each range's lines stop at its own column and its names ride that end, so a name is
    // always at the end of the line it belongs to.
    // Premium and Discount are named on ONE range only, the one picked under Shading.
    // Two or three sets stacked over each other read as noise.
    bool ok1 = shade1 and state1.valid
    bool ok2 = shade2 and state2.valid
    bool ok3 = shade3 and state3.valid
    bool names1 = f_namesFor(1, ok1, rank1, ok2, rank2, ok3, rank3)
    bool names2 = f_namesFor(2, ok2, rank2, ok1, rank1, ok3, rank3)
    bool names3 = f_namesFor(3, ok3, rank3, ok1, rank1, ok2, rank2)
    f_draw(draw1, state1, lblTag1, shade1, names1, 1 + rank1, rightPad + rank1 * rangeStep, lblMode1, sec1 >= 43200)
    f_draw(draw2, state2, lblTag2, shade2, names2, 1 + rank2, rightPad + rank2 * rangeStep, lblMode2, sec2 >= 43200)
    f_draw(draw3, state3, lblTag3, shade3, names3, 1 + rank3, rightPad + rank3 * rangeStep, lblMode3, sec3 >= 43200)
    // Every range has now had its say, so the names can be settled against each other.
    f_flushNames(txtSize)

// == AVERAGE RANGES ==========================================================
// The average is taken from COMPLETED periods only ([1]), so today's half-finished range
// is never averaged into the yardstick it is about to be measured against. The current
// period's own high and low are pulled separately and without lookahead, because there
// the developing value IS the answer - how far price has travelled so far.

[adrVal, dayHi, dayLo, dayCloseMs] = request.security(syminfo.tickerid, "D", [ta.sma(high - low, ADR_LEN)[1], high, low, time_close], lookahead = barmerge.lookahead_off)
[awrVal, wkHi, wkLo, wkCloseMs]    = request.security(syminfo.tickerid, "W", [ta.sma(high - low, AWR_LEN)[1], high, low, time_close], lookahead = barmerge.lookahead_off)
[amrVal, moHi, moLo, moCloseMs]    = request.security(syminfo.tickerid, "M", [ta.sma(high - low, AMR_LEN)[1], high, low, time_close], lookahead = barmerge.lookahead_off)

// == TABLE ===================================================================
// One panel, two questions. The upper block answers WHERE price is - which dealing range,
// which half of it. The lower block answers whether there is room left to get anywhere -
// how much of a normal day, week or month has already been spent. They are read together
// before a session and belong in the same place.

var table readTbl = table.new(f_tblPos(readPos), 2, 30, frame_color = #000000, frame_width = 1, border_width = 0)

//@function Writes one name / value line of the table in the house style
//@param row  (int)    Table row
//@param name (string) Name, in capitals
//@param val  (string) Reading
//@param tip  (string) Hover text on the reading
//@returns (int) The next free row
f_line(int row, string name, string val, string tip) =>
    table.cell(readTbl, 0, row, name, text_color = txtCol, text_size = txtSize, text_font_family = font.family_monospace, text_halign = text.align_left)
    table.cell(readTbl, 1, row, val, text_color = txtCol, text_size = txtSize, text_font_family = font.family_monospace, text_halign = text.align_left, tooltip = tip)
    row + 1

//@function Short tag for the chart's own timeframe
//@returns (string) e.g. 1m, 15m, 1H, 4H, 1D, 1W, 1M
f_chartTag() =>
    int sec = timeframe.in_seconds()
    string out = switch
        sec < 60            => str.tostring(sec) + "s"
        sec < 3600          => str.tostring(int(sec / 60)) + "m"
        sec < 86400         => str.tostring(int(sec / 3600)) + "H"
        timeframe.isweekly  => str.tostring(timeframe.multiplier) + "W"
        timeframe.ismonthly => str.tostring(timeframe.multiplier) + "M"
        =>                     str.tostring(timeframe.multiplier) + "D"
    out

//@function Writes one range's line: what it is built from, which way it is working, where
//          price sits in it, and whether each held edge has been swept
//@param row     (int)     Table row
//@param enabled (bool)    Whether the range is switched on
//@param fits    (bool)    Whether its timeframe is above the chart's
//@param s       (DrState) The range
//@param tag     (string)  Timeframe tag
//@param isPer   (bool)    Built from the period rather than from swings
//@param swHi    (bool)    Its held high has been swept by a closed candle
//@param swLo    (bool)    Its held low has been swept by a closed candle
//@returns (int) The next free row
f_rangeLine(int row, bool enabled, bool fits, DrState s, string tag, bool isPer, bool swHi, bool swLo) =>
    int next = row
    if enabled
        string name = tag + (isPer ? " PERIOD" : " SWING")
        if not fits
            next := f_line(row, name, "Below chart TF", "")
        else if not s.valid
            next := f_line(row, name, "No range yet", "")
        else
            float  pct  = f_position(s)
            string hiTx = str.tostring(s.hiPrice, format.mintick)
            string loTx = str.tostring(s.loPrice, format.mintick)
            string dirTx = f_dirName(s.dir)
            string val  = (dirTx == "-" ? "" : dirTx + " · ") + (na(pct) ? "-" : f_zone(pct) + " " + str.tostring(math.round(pct)) + "%")
            string tip  = "Range " + loTx + " - " + hiTx + "." + (s.hiProv or s.loProv ? " One side is still extending with price." : "") + (na(pct) ? "" : " Price in: (" + str.tostring(close, format.mintick) + " - " + loTx + ") / (" + hiTx + " - " + loTx + ").")
            if not isPer
                val += " · High " + (swHi ? "✓" : "×") + " · Low " + (swLo ? "✓" : "×")
                tip += " High " + hiTx + (swHi ? " swept" : " not swept") + ", low " + loTx + (swLo ? " swept" : " not swept") + ". Swept: a closed candle wicked through the level and closed back inside the range."
            next := f_line(row, name, val, tip)
    next

//@function Writes one average-range line into the table
//@param row     (int)    Table row
//@param avgName (string) Average's name - ADR, AWR or AMR
//@param avgVal  (float)  Average range of the last N completed periods
//@param prdHi   (float)  Current period's high so far
//@param prdLo   (float)  Current period's low so far
//@param closeMs (int)    Timestamp the period closes at
//@returns (int) The next free row
f_avgLine(int row, string avgName, float avgVal, float prdHi, float prdLo, int closeMs) =>
    float  used = not na(prdHi) and not na(avgVal) and avgVal > 0 ? (prdHi - prdLo) / avgVal * 100.0 : na
    string val  = (na(avgVal) ? "-" : str.tostring(avgVal, format.mintick)) + (na(used) ? "" : " · " + str.tostring(math.round(used)) + "% used") + (showTimers ? " · " + f_countdown(closeMs) : "")
    string tip  = (na(used) ? "" : "Range so far " + str.tostring(prdHi - prdLo, format.mintick) + " / average " + str.tostring(avgVal, format.mintick) + ". ") + (showTimers ? "The clock is the time left to the close." : "")
    f_line(row, avgName, val, tip)

if barstate.islast
    table.clear(readTbl, 0, 0, 1, 29)
    if showRead
        int row = 0
        row := f_line(row, "PREM + DISC", "", "")
        row := f_line(row, "INSTRUMENT", syminfo.ticker, "")
        row := f_line(row, "TIMEFRAME", f_chartTag(), "")
        // Lowest timeframe first, whichever slot it is in.
        for r = 0 to 2
            if on1 and rank1 == r
                row := f_rangeLine(row, on1, fits1, state1, tag1, per1, swH1, swL1)
            if on2 and rank2 == r
                row := f_rangeLine(row, on2, fits2, state2, tag2, per2, swH2, swL2)
            if on3 and rank3 == r
                row := f_rangeLine(row, on3, fits3, state3, tag3, per3, swH3, swL3)
        if showAvg
            row := f_avgLine(row, "ADR", adrVal, dayHi, dayLo, dayCloseMs)
            row := f_avgLine(row, "AWR", awrVal, wkHi, wkLo, wkCloseMs)
            row := f_avgLine(row, "AMR", amrVal, moHi, moLo, moCloseMs)

// == ALERTS (script scope) ===================================================
// Every alert reads the traded range. Crosses are evaluated unconditionally: ta.*
// functions carry bar-to-bar state and v6 short-circuits 'and', so guarding the call
// itself would skip it on the bars where no range exists and corrupt its own history.

// Every alert reads the range actually drawn. The two raid alerts read its HELD edges only:
// a Swing range's high and low while they are held, never a dotted far edge that is still
// following price (crossing that is the range extending, not a raid), and never a Period
// range, whose high and low are the period's running extremes and are extended, not raided.
// "New dealing range" fires when the range genuinely changes - a Swing range rebuilding on a
// close, a Period range rolling over - and never when a far edge merely extends.
float eq1 = state1.valid ? math.avg(state1.hiPrice, state1.loPrice) : na
float heldHi1 = state1.valid and not per1 and far1 != 1 ? state1.hiPrice : na
float heldLo1 = state1.valid and not per1 and far1 != -1 ? state1.loPrice : na

bool eqCrossRaw = ta.cross(close, eq1)
bool eqUpRaw    = ta.crossover(close, eq1)
bool eqDownRaw  = ta.crossunder(close, eq1)
bool hiTakeRaw  = ta.crossover(high, heldHi1)
bool loTakeRaw  = ta.crossunder(low, heldLo1)

bool live1         = state1.valid and not na(eq1)
bool intoPremium   = live1 and eqUpRaw
bool intoDiscount  = live1 and eqDownRaw
bool eqTraded      = live1 and eqCrossRaw
bool buysideTaken  = live1 and not na(heldHi1) and hiTakeRaw
bool sellsideTaken = live1 and not na(heldLo1) and loTakeRaw
bool rangeChanged  = live1 and (per1 ? pT1 != pT1[1] : reb1 != 0 and reb1 != reb1[1])

alertcondition(intoPremium,   "Price into premium",   "M1D: price crossed above the dealing range equilibrium into premium on {{ticker}} @ {{close}}")
alertcondition(intoDiscount,  "Price into discount",  "M1D: price crossed below the dealing range equilibrium into discount on {{ticker}} @ {{close}}")
alertcondition(eqTraded,      "Equilibrium traded",   "M1D: price traded the dealing range equilibrium on {{ticker}} @ {{close}}")
alertcondition(buysideTaken,  "Range high taken",     "M1D: the dealing range high was taken on {{ticker}} @ {{close}}")
alertcondition(sellsideTaken, "Range low taken",      "M1D: the dealing range low was taken on {{ticker}} @ {{close}}")
alertcondition(rangeChanged,  "New dealing range",    "M1D: the dealing range has rebuilt on {{ticker}}")
````
