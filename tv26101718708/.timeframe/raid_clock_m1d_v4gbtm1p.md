# Raid Clock+ (M1D)

- url: https://www.tradingview.com/script/V4GBtM1P-Raid-Clock-M1D/
- type: indicator
- pine_id: PUB;b22b61b0880d4263a1c1400910952bfd
- version: 1.0

## Description

[b]Raid Clock+ [/b]
Measures the New York time of day at which twelve liquidity pools are first traded through, and reads that history back as a conditional rather than a single hit rate. A pool taken on seven days in ten is not a seven-in-ten proposition at half past nine: by then the overnight raids have already spent themselves, and what is left is a smaller, later population. It also draws the higher timeframe liquidity those pools sit in. The pools, and reading liquidity against a clock, follow ICT (Michael J. Huddleston) convention; every figure the script prints is a count, and the conditional is arithmetic applied to those counts, not something drawn from ICT teaching.

[b]What it does[/b]

[b]1 · The pools.[/b] 
Twelve, in six pairs: the previous day's, week's and month's high and low, and the high and low of the Asia, London and New York sessions. The day, week and month are built from the chart's own candles, so a data provider's session boundary cannot change the level. Where the chart does not hold the whole period, usually the month on a one-minute chart, the level is read off the period's own candle, drawn, and kept out of the counts. A session pool is set when its window closes, the week at the weekly open, the month at the first evening open of the new month, and the day at the evening open.

[b]2 · The statistical day.[/b] 
A day runs 18:00 to 18:00 New York and is named for the regular session date it contains, so Sunday evening belongs to Monday. The previous day's high therefore exists from the evening session on, and a print through it in the evening counts as a raid in the evening window. Friday runs into Sunday as one rollover; no day is invented for a closed market.

[b]3 · The count.[/b] 
While a pool is live it is tested on every closed candle. A wick through the level is the raid by default, a close through it is available. The first raid records its thirty-minute slot and whether the candle closed back inside. Nothing reaches the history until a cycle has ended: counting the cycle still running would report a rate below the truth every time. The slot counts, the window counts and the raid count must reconcile, and the panel says so if they ever do not.

[b]4 · The conditional.[/b] 
Given a pool is still unswept at the time on the clock now, the conditional is the share of comparable past cycles that went on to take it before their own cycle ended. Cycles already raided earlier in the day are removed from both sides of the question. At the moment a pool is set the conditional equals the headline rate; from there the two separate as the day runs.

[b]5 · The five-year archive.[/b] 
On NQ and MNQ, ES and MES, GC and MGC the counts were measured once per product on five years of one-minute data, about 1,290 statistical days each, and are carried in the script, so they do not depend on how much history the chart loads. Cycles finishing after the archive are added on top. A cycle whose level was set on one quarterly contract and tested on the next is left out, since the price step between contracts is not a raid. The month is the exception: it crosses a roll about two times in three, so its level is moved by the spread between the two contracts on the last minute both traded, and the cycle is kept. The month holds 58 complete cycles, a thinner sample than the day or the week. Other symbols, session windows or a close-through raid fall back to the loaded history, and the panel says so.

[b]6 · The liquidity levels.[/b] 
The previous day, week, month and quarter highs and lows, and relative equal highs and lows (two swing pivots within a few ticks of one another), each drawn from the candle that formed them to a fixed point right of price. The quarter and the equal highs and lows are drawn but not timed: five years hold about twenty quarters, and a pool of equal highs or lows has no cycle to time. A level stays drawn however far price travels until it is taken. Day, week and equal highs and lows are on by default; month and quarter are one switch each.

[b]7 · The panel.[/b] 
The instrument, the timeframe and the sample the rates come from, then one row per timed pool: the same live conditional its line carries on the chart, with the counts behind it, or the time it was taken. Hovering a row gives the price, the rate across all cycles and whether the line has been removed. The long setting adds one chosen pool broken out across seven windows of the day and how often the raid candle closed back inside, with the Monday to Friday split on hover.

[b]Visual grammar[/b]

Every name is a transparent callout in the pool's colour, black by default, with buyside and sellside colours as settings. A live level's name sits at its right end with the date and its live conditional, for example PDH 22/09 42%; each family ends a few bars further right than the one below, so the names settle into columns. Where two levels share a price, or a session pool sits on a drawn level, one label carries both names, one line each. A taken level turns dotted, stops at the candle that took it, and its name moves to the swing that made it, above a high or below a low, with a cross. Session pools draw as lines to the current candle or as tags at their session's right edge; a taken session pool is removed, and one left far from price or long untouched is removed with its reason on the panel's hover. Every coordinate is a timestamp, so nothing drifts off its candle.

[b]Method & repainting[/b]

Raids are recorded on confirmed candles only and no completed cycle is ever revised. Higher timeframe values are read from the previous closed period. All times resolve through the New York clock, so the grid holds across daylight saving on any symbol. The grid is thirty minutes wide, so the script needs a 30-minute chart or finer and says so on a coarser one. A session pool set on a Friday close outlives one turn of the clock; its rate is marked with a star rather than presented straight.

[b]Settings[/b]

The day, week, month, quarter and equal highs and lows switches, what a taken level does, the swing strength, tick tolerance and how many equal highs and lows to keep, how far right the levels reach and the gap between families; each session pair and the focus pool; the Asia, London and New York windows; wick or close as the raid, the trusted minimum, the daily range length and the archive switch; the session retirement distance and hours; the panel mode, placement and text size, and how much each caption carries; the two colours, line width, label size and caption spacing. Seventeen alerts: the raid of each timed pool and of the previous quarter's high and low, equal highs taken, equal lows taken, and a pool still unswept entering its busiest window.

[b]Disclaimer[/b]

This is a measurement tool. It counts what a chart already contains and produces no entries, targets or stops. It is not financial advice, and no market's past behaviour is indicative of future results.

## Source Code

````pine
//@version=6
indicator("Raid Clock+ (M1D)", "Raids+ (M1D)", overlay = true,
     max_lines_count = 500, max_labels_count = 500)

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


// == CONSTANTS ===============================================================

//@variable Ink for text and default level colours
const color C_INK = #000000

//@variable Exchange-independent New York clock every window and every slot is quoted in
const string TZ = "America/New_York"

// Six hours. Added to a bar's timestamp before the calendar date is read off it, this
// maps the 18:00 open of a statistical day onto 00:00 of the date that day is named for.
// A bar at 18:00 Monday shifts to 00:00 Tuesday and is filed under Tuesday; 17:59 Monday
// shifts to 23:59 Monday and stays with Monday. Sunday 18:00 shifts to Monday 00:00, which
// is why Sunday evening carries a Monday label and Saturday never gets a day of its own.
const int SHIFT_MS = 21600000

//@variable Thirty minute slots in one statistical day. Slot 0 is 18:00-18:30 New York.
const int SLOTS_DAY = 48
//@variable Thirty minute slots in one statistical week — five trading days of SLOTS_DAY.
const int SLOTS_WEEK = 240
//@variable Most statistical days one month can hold — a 31 day month has at most 23 weekdays.
const int MONTH_DAYS = 23
//@variable Thirty minute slots in one statistical month — MONTH_DAYS trading days of SLOTS_DAY.
const int SLOTS_MONTH = 1104
//@variable Number of pools tracked, drawn or timed.
const int POOL_N = 14
//@variable Pools 0 to POOL_TIMED - 1 carry statistics; the ones after are drawn only.
const int POOL_TIMED = 12

//@variable Minutes from midnight to 18:00, the origin of the slot grid.
const int OPEN_MIN = 1080

// Pool slots, in the order they are pushed.
const int P_PDH = 0
const int P_PDL = 1
const int P_PWH = 2
const int P_PWL = 3
const int P_PMH = 10
const int P_PML = 11
const int P_PQH = 12
const int P_PQL = 13

// Clock a pool's first raid is filed on. The quarter is drawn only.
const int GRID_DAY   = 0
const int GRID_WEEK  = 1
const int GRID_MONTH = 2
const int GRID_NONE  = -1

const string DAY_TIP = "Times only, New York. Any day mask typed here is IGNORED. TradingView's mask names the day a session running overnight ENDS, so :12345 on an 18:00-01:00 session quietly drops Thursday evening's — the only one ending on a Friday. The days are worked out in code instead, from the window's own shape: one that wraps midnight may open Sunday to Thursday, one that does not may open Monday to Friday."

// == INPUTS — POOLS ==========================================================

const string G_L = "Liquidity levels"

bool showPd = input.bool(true,  "Previous day  (PDH · PDL)",     group = G_L)
bool showPw = input.bool(true,  "Previous week  (PWH · PWL)",    group = G_L)
bool showPm = input.bool(false, "Previous month  (PMH · PML)",   group = G_L,
     tooltip = "Timed in the panel like the day and the week. A month is about 58 cycles in the five-year archive, so its rates rest on a thinner sample than the others.")
bool showPq = input.bool(false, "Previous quarter  (PQH · PQL)", group = G_L,
     tooltip = "Drawn, not timed. Five years hold about twenty quarters, too few to read a clock from, so the quarter has no row in the panel.")
bool showEq = input.bool(true,  "Relative equal highs and lows  (REH · REL)", group = G_L,
     tooltip = "Two swing pivots resting within the tolerance below are one pool. Drawn, not timed.")
string onTaken = input.string("Dotted, ends at the raid", "Once taken",
     options = ["Dotted, ends at the raid", "Remove"], group = G_L,
     tooltip = "A taken level turns dotted and stops at the candle that took it, its name marked with a cross above that candle for a high and below it for a low. Remove clears it the moment it is taken. Applies to this group only; session pools are always removed.")
int swingLen = input.int(5, "Equal highs and lows: swing strength (bars)", minval = 1, maxval = 50, group = G_L,
     tooltip = "Bars either side a candle must dominate to count as a swing. Larger finds fewer, bigger pools.")
int eqTolTicks = input.int(4, "Equal highs and lows: tolerance (ticks)", minval = 1, maxval = 200, group = G_L,
     tooltip = "How far apart two pivots may sit and still count as equal. Measured in ticks, so it scales with the instrument.")
int eqKeep = input.int(12, "Equal highs and lows: live pools kept", minval = 1, maxval = 50, group = G_L)
int eqKeepTaken = input.int(2, "Equal highs and lows: taken pools kept", minval = 0, maxval = 10, group = G_L)
string eqStyleSel = input.string("Dashed", "Equal highs and lows: line style", options = ["Solid", "Dotted", "Dashed"], group = G_L)
bool showTf = input.bool(true, "Timeframe in equal highs and lows labels", group = G_L,
     tooltip = "A pool is found on the chart timeframe it was drawn on. The tag says which, REH · 5m, so a one-minute pool is not mistaken for a one-hour one when the chart is changed.")
int runwayBars = input.int(10, "Right offset (bars)", minval = 0, maxval = 100, group = G_L,
     tooltip = "How far past the live candle the nearest family, the equal highs and lows, stops. Its name sits at that end.")
int tfStep = input.int(10, "Extra bars per family", minval = 0, maxval = 100, group = G_L,
     tooltip = "Each family reaches further right than the one below it and every name sits at the end of its own line, so the names land in columns instead of contesting one. At the defaults equal highs and lows run 10 bars past the live candle, the previous day 20, the week 30, the month 40 and the quarter 50. Zero puts every name back in one column.")

const string G_P = "Pools"

bool showAs  = input.bool(true, "Asia session high and low",     group = G_P)
bool showLo  = input.bool(true, "London session high and low",   group = G_P)
bool showNy  = input.bool(true, "New York session high and low", group = G_P)

string focusName = input.string("PDH", "Focus pool",
     options = ["PDH", "PDL", "PWH", "PWL", "PMH", "PML", "Asia H", "Asia L", "London H", "London L", "NY H", "NY L"],
     group = G_P,
     tooltip = "The pool broken out in the second table: its raids segment by segment, its Monday to Friday split, and how often the raid bar closed back inside.")

// == INPUTS — SESSION WINDOWS ================================================

const string G_W = "Session Windows (New York time)"

string asiaSess = input.session("1800-0200", "Asia",     group = G_W, tooltip = DAY_TIP)
string lonSess  = input.session("0200-0600", "London",   group = G_W, tooltip = DAY_TIP)
string nySess   = input.session("0700-1615", "New York", group = G_W, tooltip = DAY_TIP)

// == INPUTS — MEASUREMENT ====================================================

const string G_M = "Measurement"

string statSrc = input.string("Five-year archive", "Statistics from", options = ["Five-year archive", "Loaded chart history"], group = G_M,
     tooltip = "Five-year archive: the counts were measured on five years of one-minute futures data and are carried inside the script, so every chart reads the same sample however little history it loads. Cycles that complete after the archive ends are added on top. It applies only to the products it was measured on, with the default session windows and a wick as the raid; anything else falls back to the loaded chart history and the panel says so.\nLoaded chart history: every figure is counted from the candles on the chart.")

bool closeThrough = input.bool(false, "Close through counts as the raid", group = G_M,
     tooltip = "Off: a wick through the level is the raid, which is the ICT reading and the default. On: the bar must CLOSE through it. Closing through cannot leave the bar back inside the level, so the reversal share is withheld in that mode rather than reported as zero.")

int minSample = input.int(30, "Minimum cycles before a rate is trusted", minval = 5, maxval = 500,
     group = G_M,
     tooltip = "Below this the row is greyed and tagged. The counts are still shown — a small sample is worth seeing, it is just not worth acting on.")

int adrLen = input.int(20, "ADR length (days)", minval = 2, maxval = 100, group = G_M)

// == INPUTS — RETIREMENT =====================================================

const string G_R = "Retirement"

float maxDistAdr = input.float(1.0, "Remove levels further than (x ADR)", minval = 0.1, maxval = 10.0,
     step = 0.1, group = G_R,
     tooltip = "Session pools only. A drawing left hanging far from the candles forces the auto price scale to keep reaching for it, and the pane rescales on every touch of the chart. The level keeps counting toward the statistics — only its drawing goes, and the panel's hover text says so. The day, week, month and quarter levels are exempt: a monthly level is meant to be far away.")

float retireHours = input.float(24, "Retire a level left untouched after (hours)",
     minval = 1, maxval = 168, step = 1, group = G_R,
     tooltip = "Session pools only. A distance gate alone cannot save a drawing over a weekend — by the time price has walked far enough to trip it, the level has already been floating for a day. Every session level therefore carries its own age as well; a session pool armed on a Friday close is the one that reaches it. The day, week, month and quarter levels stay drawn until they are taken.")

// == INPUTS — TABLES =========================================================

const string G_T = "Tables"

string tblMode = input.string("Short", "Tables", options = ["Long", "Short", "Off"], group = G_T,
     tooltip = "Short: one row per timed pool still unswept, its name and its headline raid rate. Hover a row for the price and the counts behind the rate.\nLong: adds the focus pool broken out by window of the day.\nA pool switched off in the Pools group, or with no level yet, takes its row with it.")

string panelPosIn = input.string("Bottom right", "Placement",
     options = ["Bottom right", "Top right", "Middle right", "Bottom left", "Top left"], group = G_T)

string tblSizeIn = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal"],
     group = G_T)

string levelMode = input.string("Origin tags", "Session pool display", options = ["Lines", "Origin tags"], group = G_T,
     tooltip = "How the Asia, London and New York pools draw. The liquidity levels always draw as lines.\nLines: each live pool is a line from the candle that formed it to the current candle, captioned at its right hand end.\nOrigin tags: no line. Each live pool is a tag on the candle that formed it, above a high and below a low, carrying its name and its live conditional. It leaves the right hand side of the chart to whatever else is drawing levels there. Two pools formed by the same candle share one tag.")

string tagSide = input.string("Session box corners", "Origin tag placement", options = ["Session box corners", "Line end, inside", "Line end, outside", "Beside the candle", "Above a high, below a low"], group = G_T,
     tooltip = "Where a pool's tag sits when Level display is Origin tags.\nSession box corners: a session high is tagged inside the top right corner of its session, a session low inside the bottom right corner, so a script boxing the same session has its name above the box and its levels to the right left clear.\nLine end: at the right hand edge, where another script's level line for the same price stops, finishing at that point so it clears a name printed to the right of it. Inside puts it under a high and over a low; outside puts it over a high and under a low. Pick the side the other script is not already using.\nBeside the candle: left of the candle that formed the level, on its price.\nAbove a high, below a low: on the candle that formed the level.")
int tagRunway = input.int(10, "Line end is this many bars right of price", minval = 0, maxval = 100, group = G_T,
     tooltip = "Match it to the other script's right offset so the tag finishes where that script's line does.")

string labelDetail = input.string("Short", "Level label detail",
     options = ["Short", "Full", "None"], group = G_T,
     tooltip = "Short prints the pool, the date of a day, week, month or quarter level, and its live conditional. Full adds the level's price. None draws the lines with no caption.")

// == INPUTS — STYLE ==========================================================

const string G_C = "Style"

color buyCol  = input.color(C_INK, "Buyside pools",  group = G_C)
color sellCol = input.color(C_INK, "Sellside pools", group = G_C)
int   lineW   = input.int(2, "Level line width", minval = 1, maxval = 4, group = G_C,
     tooltip = "Liquidity lines run at width 2 by house convention. Equal highs and lows run at 1.")
string labelSize = input.string("small", "Label text size", options = ["tiny", "small", "normal", "large"], group = G_C)

float labelGapAdr = input.float(0.05, "Minimum caption spacing (x ADR)", minval = 0.0, maxval = 1.0,
     step = 0.01, group = G_C,
     tooltip = "Two pools very often sit at exactly the same price — the previous day's high IS the previous New York session high on any day whose extreme was made in New York hours, and the same goes for the lows. Their captions would then print on top of each other and neither would be readable. This is the least each caption is moved apart when, and only when, two would physically collide. The LINE never moves: it always sits on the level's true price, and only the callout is nudged. Keep it small — a caption pushed far from its own line reads as a mistake. Set it to zero to switch the nudging off entirely.")

// == TYPES ===================================================================

//@type One pool's fixed identity. Nothing here changes once the script starts.
//@field nm       Name printed on the chart and in the table
//@field isHigh   True for a buyside pool, false for a sellside one
//@field cycStart Slot the pool's cycle begins at, on its own grid
//@field grid     GRID_DAY, GRID_WEEK or GRID_MONTH for the clock its raids are filed on; GRID_NONE when drawn only
//@field shown    Whether the pool draws on the chart
//@field rank     0 for a session pool; 1 day, 2 week, 3 month, 4 quarter — the drawing column of a liquidity level
type PoolDef
    string nm       = ""
    bool   isHigh   = true
    int    cycStart = 0
    int    grid     = 0
    bool   shown    = true
    int    rank     = 0

//@type One pool's accumulated history. Nothing is written here until a cycle has ENDED.
//@field firstRaid Count of first raids per slot — 48 slots daily, 240 weekly, 1104 monthly
//@field segCnt    The same counts folded into the seven display windows
//@field dowObs    Cycles observed, Monday to Friday
//@field dowRaid   Of those, how many were raided
//@field n         Complete cycles observed
//@field raids     Of those, how many were raided
//@field revInside Raids whose bar closed back inside the level
//@field peakSeg   Display window holding the most first raids, or -1
type PoolStats
    array<int> firstRaid = na
    array<int> segCnt    = na
    array<int> dowObs    = na
    array<int> dowRaid   = na
    int        n         = 0
    int        raids     = 0
    int        revInside = 0
    int        peakSeg   = -1

//@type The pool instance currently live. Every anchor is a timestamp, never a bar index.
//@field level    Price of the pool
//@field originT  Timestamp of the candle that formed it
//@field armed    Whether a cycle is running
//@field clean    Whether this instance may post to history when it ends
//@field raided   Whether it has already been taken
//@field raidSlot Slot the first raid landed in, on the pool's own grid
//@field raidT    Timestamp of the raid bar, 0 when it was taken before the chart's history begins
//@field raidPx   The raid bar's wick
//@field raidDow  Monday-to-Friday index of the statistical day the raid landed on
//@field dateTxt  The period a liquidity level belongs to, as printed beside its name
//@field armDow   Monday-to-Friday index of the statistical day it armed on, or -1
//@field armT     Timestamp the instance opened, used to spot a cycle that outran the clock
//@field lastNearT Last time price came within the distance gate of the level
//@field far      Suppressed this bar for sitting beyond the distance gate
//@field stale    Suppressed this bar for going untouched past its retirement age
type PoolLive
    float level            = na
    int   originT          = 0
    int   boxL             = 0
    int   boxR             = 0
    int   armT             = 0
    bool  armed            = false
    bool  clean            = false
    bool  raided           = false
    int   raidSlot         = -1
    int   raidT            = 0
    float raidPx           = na
    int   raidDow          = -1
    string dateTxt         = ""
    bool  raidClosedInside = false
    int   armDow           = -1
    int   lastNearT        = 0
    bool  far              = false
    bool  stale            = false
    line  lnObj            = na
    label lblObj           = na

//@type A forming period reduced to its extremes and the candles that made them.
//@field fresh True when the period was opened by a rollover this script saw, rather than
//             simply being whatever was running when the chart history began
type PeriodTrk
    float hi      = na
    float lo      = na
    int   hiT     = 0
    int   startT  = 0
    int   endT    = 0
    int   loT     = 0
    bool  hasBars = false
    bool  fresh   = false

// == HELPERS =================================================================

//@function Slot on the thirty minute grid whose slot 0 is 18:00-18:30 New York.
//@param nyMinute (int) Minutes from New York midnight
//@returns (int) Slot index, 0 to 47
f_slot(int nyMinute) =>
    int fromOpen = (nyMinute - OPEN_MIN + 1440) % 1440
    int(math.floor(fromOpen / 30.0))

//@function Reads the closing time out of a session window and returns its slot.
//@param sessWin (string) A nine character HHMM-HHMM window
//@returns (int) Slot the window closes in
f_endSlot(string sessWin) =>
    int endHour = int(math.round(nz(str.tonumber(str.substring(sessWin, 5, 7)))))
    int endMins = int(math.round(nz(str.tonumber(str.substring(sessWin, 7, 9)))))
    f_slot(endHour * 60 + endMins)

//@function Whether a window wraps past midnight, read from the times themselves so
//          retiming a session updates which day rule applies to it.
//@param sessWin (string) A nine character HHMM-HHMM window
//@returns (bool) True when the window ends on the following day
f_overnight(string sessWin) =>
    int fromMin = int(math.round(nz(str.tonumber(str.substring(sessWin, 0, 2))))) * 60 +
         int(math.round(nz(str.tonumber(str.substring(sessWin, 2, 4)))))
    int toMin = int(math.round(nz(str.tonumber(str.substring(sessWin, 5, 7))))) * 60 +
         int(math.round(nz(str.tonumber(str.substring(sessWin, 7, 9)))))
    toMin <= fromMin

//@function Applies the day rule to a session window. Membership of the window itself is left
//          to TradingView, which already handles gaps, holidays and short days; only the DAY
//          test is done here, because that is the part its own session mask gets backwards on
//          a window running overnight. The test runs once, on the opening bar, and is held for the
//          rest of the session — testing every bar would cut a session running overnight in half at
//          midnight, when the calendar day underneath it changes but the session does not.
//          Carries state and reads its own history, so it must be called on every bar and never
//          from inside a condition. Each call site keeps its own.
//@param rawIn     (bool) Whether the bar falls in the window
//@param overnight (bool) Whether the window wraps past midnight
//@returns (tuple) Inside the session, and opening it
f_days(bool rawIn, bool overnight) =>
    var bool allowed = false
    bool rawStart = rawIn and not rawIn[1]
    if rawStart
        int dow = dayofweek(time, TZ)
        allowed := overnight ? (dow >= dayofweek.sunday and dow <= dayofweek.thursday) : (dow >= dayofweek.monday and dow <= dayofweek.friday)
    [rawIn and allowed, rawStart and allowed]

//@function The display window a daily slot belongs to. The seven windows are the ones a
//          session is actually read in — the evening, the overnight, the pre-open, the first
//          ninety minutes, the middle of the day, the afternoon, and the close-to-open gap.
//@param slotIdx (int) Slot on the 48 slot daily grid
//@returns (int) Display window index, 0 to 6
f_segOf(int slotIdx) =>
    switch
        slotIdx < 12 => 0
        slotIdx < 26 => 1
        slotIdx < 31 => 2
        slotIdx < 34 => 3
        slotIdx < 39 => 4
        slotIdx < 44 => 5
        =>              6

//@function Formats a New York clock time as hh:mm.
//@param stamp (int) A timestamp
//@returns (string) The time, zero padded
f_hhmm(int stamp) =>
    int hh = hour(stamp, TZ)
    int mm = minute(stamp, TZ)
    (hh < 10 ? "0" : "") + str.tostring(hh) + ":" + (mm < 10 ? "0" : "") + str.tostring(mm)

//@function A rate and the counts behind it. A percentage is never printed without them.
//@param num (int) Numerator
//@param den (int) Denominator
//@returns (string) The formatted rate, or a dash when there is nothing to divide
f_rate(int num, int den) =>
    den <= 0 ? "—" : str.tostring(int(math.round(num * 100.0 / den))) + "% (" + str.tostring(num) + "/" + str.tostring(den) + ")"

//@function Formats a price using the instrument's own tick formatting.
//@param value (float) The price
//@returns (string) The formatted price
f_price(float value) =>
    na(value) ? "—" : str.tostring(value, format.mintick)

//@function Resolves a table position input to a Pine position constant.
//@param posName (string) The chosen placement
//@returns (string) Matching position.* constant
f_pos(string posName) =>
    switch posName
        "Top right"    => position.top_right
        "Middle right" => position.middle_right
        "Bottom left"  => position.bottom_left
        "Top left"     => position.top_left
        =>                position.bottom_right

//@function Resolves the table size input to a Pine size constant.
//@param sizeName (string) The chosen size
//@returns (string) Matching size.* constant
f_txtSize(string sizeName) =>
    switch sizeName
        "Tiny"   => size.tiny
        "Normal" => size.normal
        =>          size.small

//@function Resolves the label size input to a Pine size constant.
//@param s (simple string) The raw input value
//@returns (simple string) A size.* constant
f_lblSize(simple string s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        =>         size.normal

//@function Resolves a line style input to a Pine line style constant.
//@param s (simple string) The raw input value
//@returns (simple string) A line.style_* constant
f_lineStyle(simple string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        =>          line.style_dotted

//@function The chart timeframe as a short tag: 1m · 15m · 1H · 4H · D · W · M.
//@returns (simple string) The tag
f_tfTag() =>
    string tag = timeframe.period
    if timeframe.isseconds
        tag := str.tostring(timeframe.multiplier) + "s"
    else if timeframe.isminutes
        tag := timeframe.multiplier < 60 ? str.tostring(timeframe.multiplier) + "m"
             : str.tostring(timeframe.multiplier / 60) + "H"
    else if timeframe.isdaily
        tag := "D"
    else if timeframe.isweekly
        tag := "W"
    else if timeframe.ismonthly
        tag := "M"
    tag

string LBL_SZ   = f_lblSize(labelSize)
string EQ_STYLE = f_lineStyle(eqStyleSel)
string TF_TAG   = f_tfTag()

//@function Length of the clock a pool's first raids are filed on.
//@param grid (int) GRID_DAY, GRID_WEEK or GRID_MONTH
//@returns (int) Slots in one turn of that clock
f_gridLen(int grid) =>
    switch grid
        GRID_WEEK  => SLOTS_WEEK
        GRID_MONTH => SLOTS_MONTH
        =>            SLOTS_DAY

//@function A New York calendar date as dd/mm.
//@param stamp (int) A timestamp
//@returns (string) The date, zero padded
f_ddmm(int stamp) =>
    int d = dayofmonth(stamp, TZ)
    int m = month(stamp, TZ)
    (d < 10 ? "0" : "") + str.tostring(d) + "/" + (m < 10 ? "0" : "") + str.tostring(m)

var array<string> MONTH_NAMES = array.from("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

// == PERIOD TRACKING =========================================================

//@function Folds the current bar into a period's extremes, recording the candle that made each.
//@param this (PeriodTrk) The period being tracked
//@returns (bool) Always true
method fold(PeriodTrk this) =>
    if na(this.hi) or high > this.hi
        this.hi  := high
        this.hiT := time
    if na(this.lo) or low < this.lo
        this.lo  := low
        this.loT := time
    this.endT    := time
    this.hasBars := true
    true

//@function Copies one period's measurement into another.
//@param this (PeriodTrk) Destination
//@param src (PeriodTrk) Source
//@returns (bool) Always true
method copyFrom(PeriodTrk this, PeriodTrk src) =>
    this.hi      := src.hi
    this.lo      := src.lo
    this.hiT     := src.hiT
    this.startT  := src.startT
    this.endT    := src.endT
    this.loT     := src.loT
    this.hasBars := src.hasBars
    this.fresh   := src.fresh
    true

//@function Empties a period ready for the next one.
//@param this (PeriodTrk) The period being reset
//@param bornHere (bool) True when this script saw the rollover that opened it
//@returns (bool) Always true
method wipe(PeriodTrk this, bool bornHere) =>
    this.hi      := na
    this.lo      := na
    this.hiT     := 0
    this.startT  := time
    this.endT    := time
    this.loT     := 0
    this.hasBars := false
    this.fresh   := bornHere
    true

//@function Origin of a level read off a period candle rather than measured bar by bar. The candle knows
//          the price but not the bar that set it, so the tracker's own bar is used where the two agree
//          to the tick, and the period's own open where the chart never saw the real extreme.
//@param src (PeriodTrk) Whatever part of the period the chart did see
//@param hiSide (bool) True for the high
//@param val (float) The period candle's high or low
//@param startT (int) Open time of the period candle
//@returns (int) The origin time
f_anchor(PeriodTrk src, bool hiSide, float val, int startT) =>
    float seen = hiSide ? src.hi : src.lo
    bool agree = src.hasBars and not na(seen) and math.abs(seen - val) <= syminfo.mintick
    agree ? (hiSide ? src.hiT : src.loT) : nz(startT, time)

// == ARCHIVE =================================================================
// Generated by bake_archive.py in research/raid-clock-stats from the measured JSON. Never typed by hand.
// One row per pool: cycles | raids | raid candle closed back inside at 1m | 5m | 15m | 30m |
// Monday-Friday observed | Monday-Friday raided | first raids per slot (one count per slot for
// the day and week; slot:count for the month, whose 1,104 slots are nearly all empty).

// == ARCHIVE DATA BEGIN ==
//@function Statistical days measured for one product family, 0 when it has no archive.
f_archDays(string fam) =>
    switch fam
        "ES" => 1292
        "GC" => 1290
        "NQ" => 1292
        => 0

//@function Time of the last archived candle for one product family.
f_archEnd(string fam) =>
    switch fam
        "ES" => 1789689540000
        "GC" => 1789689540000
        "NQ" => 1789343940000
        => 0

//@function One pool's archive row for one product family, empty when there is none.
f_archRow(string fam, int pool) =>
    string key = fam + str.tostring(pool)
    switch key
        "ES0" => "1251|709|228|276|308|316|239,261,259,256,236|132,156,150,146,125|110,11,32,15,22,8,17,17,8,5,6,5,5,3,3,7,16,8,21,11,20,11,3,2,8,6,10,7,15,42,15,57,24,23,18,19,5,13,6,11,12,11,10,21,9,1,0,0"
        "ES1" => "1251|604|209|249|266|282|239,261,259,256,236|101,141,123,128,111|88,23,15,11,17,17,6,13,13,5,4,1,5,3,6,4,12,6,14,15,9,10,9,3,6,4,6,13,8,32,11,39,31,30,11,14,12,6,15,9,9,16,4,14,4,1,0,0"
        "ES2" => "221|131|55|54|58|60|221,221,221,221,221|68,20,24,12,7|17,1,1,0,2,1,1,2,0,0,0,1,0,0,0,2,0,0,1,0,1,0,1,0,1,0,1,1,1,2,1,9,3,4,5,1,0,1,2,2,0,1,2,0,0,0,0,0,1,0,1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0,0,0,2,0,2,0,2,0,0,0,1,0,1,0,2,0,0,1,0,0,1,0,0,1,1,0,1,0,0,0,1,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,2,1,3,1,0,2,0,1,0,0,2,2,3,2,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,2,0,1,0,0,0,3,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,2,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
        "ES3" => "221|98|40|47|47|50|221,221,221,221,221|43,22,14,8,11|15,2,0,0,1,1,0,0,1,0,0,0,0,0,0,1,1,0,1,2,0,2,4,0,0,0,0,2,0,0,0,3,1,0,0,2,0,0,2,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,2,0,0,1,0,1,0,0,0,1,2,0,1,3,1,1,1,0,0,0,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,0,2,2,0,2,1,0,0,0,0,0,0,2,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,1,0,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0"
        "ES4" => "1271|1057|341|426|472|502|257,261,259,255,239|211,212,221,210,203|8,2,0,0,1,1,1,0,0,1,1,0,0,1,0,0,247,82,127,68,69,32,25,13,18,18,31,19,32,61,8,62,26,26,16,9,8,4,8,5,8,9,1,7,2,0,0,0"
        "ES5" => "1271|992|355|459|477|507|257,261,259,255,239|176,216,210,197,193|4,3,1,2,3,1,1,2,0,1,0,0,0,0,1,2,194,67,102,55,42,37,27,22,17,18,22,17,21,52,17,69,43,30,20,12,8,11,10,14,10,11,13,7,1,2,0,0"
        "ES6" => "1270|1041|392|457|494|502|257,261,259,255,238|215,215,212,204,195|7,2,0,0,0,0,0,0,0,1,0,0,0,0,2,1,3,0,4,2,5,1,1,0,224,106,100,76,63,103,27,127,53,23,21,9,11,10,9,11,11,4,7,12,4,1,0,0"
        "ES7" => "1270|999|385|449|484|505|257,261,259,255,238|186,212,208,206,187|4,3,1,2,4,1,1,3,1,3,0,0,1,0,1,1,2,1,5,1,3,2,2,0,170,78,79,50,63,111,45,130,58,40,25,17,11,15,19,11,10,8,8,7,0,2,0,0"
        "ES8" => "1271|755|240|299|328|342|243,283,257,249,239|154,170,152,141,138|75,6,27,13,19,11,17,16,8,2,5,5,7,4,3,8,15,8,23,10,17,12,5,4,9,8,9,7,14,41,16,53,23,25,18,17,3,13,6,13,12,14,7,20,73,34,0,0"
        "ES9" => "1271|652|241|285|299|301|243,283,257,249,239|130,153,138,126,105|72,14,14,9,19,15,9,11,12,4,4,1,6,3,5,8,13,11,15,12,4,12,6,3,7,7,9,10,8,31,11,40,39,26,15,15,9,8,15,7,7,15,7,13,53,18,0,0"
        "ES10" => "58|38|18|17|20|19|58,58,58,58,58|9,6,10,6,7|0:4,4:1,28:1,31:2,33:3,35:1,40:2,41:1,45:1,48:1,60:1,68:1,70:1,132:1,145:1,161:1,173:1,175:1,207:1,323:1,354:1,365:1,379:2,428:1,463:1,523:1,552:1,616:1,661:1,975:1"
        "ES11" => "58|22|9|7|7|8|58,58,58,58,58|6,2,3,7,4|0:2,1:1,34:1,42:2,56:1,71:1,80:1,84:1,96:1,176:2,320:1,404:1,518:1,582:1,667:1,672:1,706:1,813:1,955:1"
        "GC0" => "1239|677|246|283|287|316|247,249,248,250,245|113,146,143,133,142|126,19,20,21,32,23,24,16,10,10,11,5,11,7,7,14,14,10,20,9,14,4,12,8,8,0,12,9,12,53,13,34,27,11,13,6,6,2,3,3,9,3,2,4,0,0,0,0"
        "GC1" => "1239|588|265|285|311|321|247,249,248,250,245|112,119,119,129,109|54,11,27,14,37,15,24,24,14,18,12,5,9,11,6,16,14,7,14,17,12,12,2,9,10,10,5,4,15,37,13,18,27,13,14,6,7,4,3,2,7,4,3,2,0,0,0,0"
        "GC2" => "210|117|39|42|40|40|210,210,210,210,210|58,18,15,13,13|20,1,2,2,4,3,0,0,2,1,1,0,0,0,1,1,1,2,0,0,1,0,0,0,1,0,0,1,1,1,1,2,2,1,0,2,1,0,0,1,0,1,0,1,0,0,0,0,0,0,0,1,1,0,1,2,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,1,0,1,0,1,1,1,1,2,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,3,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,1,1,3,1,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,1,0,1,0,0,0,0,0,0,4,0,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,1,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,2,1,0,0,0,3,0,0,0,0,0,0,0"
        "GC3" => "210|89|44|55|48|49|210,210,210,210,210|46,23,12,7,1|11,2,2,0,2,3,1,1,1,1,1,0,0,0,0,0,0,0,0,3,1,0,0,0,1,0,1,0,3,2,1,1,2,2,1,0,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,0,1,2,0,0,0,1,0,0,2,1,0,0,0,1,1,0,0,0,0,0,1,0,0,1,2,1,0,2,3,1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,3,0,0,0,0,0,0,1,0,0,0,0,0,1,2,0,1,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
        "GC4" => "1264|923|328|404|438|428|252,254,255,253,250|162,185,201,180,195|8,2,3,1,2,3,3,2,1,4,2,2,0,1,0,4,239,78,73,60,46,29,22,17,19,18,25,15,38,62,16,40,29,15,12,9,3,5,0,3,3,4,2,1,2,0,0,0"
        "GC5" => "1264|863|363|422|443|448|252,254,255,253,250|160,172,185,169,177|7,0,4,3,7,4,6,3,1,4,2,2,1,2,3,6,202,82,88,44,33,29,24,13,12,14,13,12,20,59,28,40,24,15,13,5,7,4,5,3,4,5,3,3,1,3,0,0"
        "GC6" => "1263|970|382|444|477|495|252,254,255,253,249|177,198,198,197,200|10,1,1,2,4,1,6,4,4,2,1,1,0,1,3,1,4,2,1,5,4,1,0,2,220,89,88,77,98,114,45,62,24,21,19,8,6,5,6,5,6,3,5,3,2,3,0,0"
        "GC7" => "1263|931|395|476|506|504|252,254,255,253,249|190,175,196,188,182|10,0,3,2,5,2,7,3,5,3,3,2,0,5,0,4,6,2,1,3,2,0,1,3,202,82,65,48,82,131,41,75,39,24,13,12,8,8,4,5,10,4,4,2,0,0,0,0"
        "GC8" => "1263|768|286|337|343|365|236,275,254,248,250|152,182,150,155,129|93,17,23,18,38,26,29,22,12,13,9,6,11,14,7,18,16,10,21,10,12,5,11,11,8,3,11,7,17,51,19,29,24,15,13,7,3,3,5,3,7,5,6,1,32,47,0,0"
        "GC9" => "1263|680|309|321|347|366|236,275,254,248,250|130,158,146,121,125|47,13,32,11,40,23,30,23,14,22,8,5,12,15,11,18,14,8,15,15,19,15,6,8,10,13,8,4,13,38,13,21,25,14,14,6,10,2,3,2,6,4,4,1,17,28,0,0"
        "GC10" => "58|33|19|17|20|19|58,58,58,58,58|10,5,3,8,7|0:3,5:2,7:1,8:2,29:1,31:1,32:1,34:1,43:1,80:1,128:1,144:1,192:1,228:1,240:1,291:1,365:1,413:1,414:1,417:1,423:1,480:1,559:1,609:1,615:1,639:1,660:1,662:1,941:1"
        "GC11" => "58|19|3|6|8|8|58,58,58,58,58|6,1,3,5,4|0:1,1:1,11:1,28:1,84:1,86:1,122:1,223:1,235:1,324:1,333:1,413:1,485:1,497:1,654:1,690:1,724:1,749:1,878:1"
        "NQ0" => "1253|708|264|294|303|319|238,254,259,258,244|134,154,154,142,124|131,22,21,20,29,12,11,13,11,4,3,7,7,1,4,7,15,6,21,13,19,9,8,4,5,2,8,7,11,33,17,72,30,19,15,13,11,4,9,8,13,6,10,6,10,1,0,0"
        "NQ1" => "1253|603|239|240|255|282|238,254,259,258,244|99,132,120,132,120|93,15,18,15,21,15,14,14,7,4,4,4,6,1,5,7,10,7,13,13,7,11,7,5,3,6,12,11,6,30,8,60,25,32,10,13,13,5,3,8,14,8,7,10,1,2,0,0"
        "NQ2" => "221|127|49|54|55|59|221,221,221,221,221|68,18,19,13,9|19,3,1,0,4,1,0,1,0,1,1,1,0,0,0,0,1,0,0,1,2,1,1,0,1,0,0,0,1,1,1,12,1,4,0,0,1,1,3,1,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,2,1,0,0,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,0,0,1,0,3,1,0,0,1,0,0,0,0,0,2,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,2,4,2,0,1,1,1,0,0,0,0,2,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,2,0,1,2,1,0,2,0,1,0,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,3,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0"
        "NQ3" => "221|101|40|38|46|48|221,221,221,221,221|48,21,16,4,12|16,0,0,0,1,0,2,0,1,0,0,1,0,0,0,3,0,0,1,1,0,1,0,0,0,1,1,3,0,0,2,5,2,2,0,2,1,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,0,0,0,4,0,0,0,0,1,0,0,0,0,1,1,1,3,1,3,0,1,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,1,0,0,1,0,0,1,0,0,1,1,0,0,1,0,1,0,2,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,0,1,1,0,3,0,1,0,1,1,0,0,0,0,0,0,0,0"
        "NQ4" => "1272|1053|447|478|485|487|250,261,259,258,244|201,211,226,212,203|2,1,1,1,1,1,1,0,1,0,1,0,1,0,0,3,255,76,117,60,72,33,26,14,7,18,28,17,27,56,17,79,33,32,13,7,11,5,3,7,8,3,3,8,4,0,0,0"
        "NQ5" => "1272|990|396|446|461|489|250,261,259,258,244|166,211,211,204,198|5,1,5,3,4,0,3,0,1,1,1,1,0,0,0,0,195,72,101,49,54,27,20,16,17,19,15,14,19,52,12,112,48,28,23,11,14,9,7,9,6,6,6,3,1,0,0,0"
        "NQ6" => "1271|1039|453|482|515|531|250,261,259,258,243|213,204,215,202,205|2,3,0,0,1,0,0,2,1,0,0,1,0,0,0,2,1,0,2,2,4,0,0,1,212,97,107,78,68,101,32,143,46,24,22,14,11,7,13,10,10,7,4,5,4,2,0,0"
        "NQ7" => "1271|1016|472|491|513|525|250,261,259,258,243|184,211,207,211,203|6,3,3,2,2,0,4,0,0,1,0,0,0,2,1,1,0,0,0,6,1,3,2,1,172,76,89,46,63,106,41,191,57,39,24,10,13,8,11,8,6,7,5,3,3,0,0,0"
        "NQ8" => "1272|752|302|324|336|342|236,283,257,252,244|148,178,148,135,143|87,19,16,18,26,14,11,8,11,5,3,5,7,2,4,8,16,8,21,14,17,10,9,4,5,4,7,8,10,37,19,68,29,14,16,14,11,2,9,11,11,7,8,9,72,38,0,0"
        "NQ9" => "1272|644|252|252|262|294|236,283,257,252,244|122,150,138,131,103|70,8,18,12,21,14,13,12,7,4,3,4,7,1,8,5,10,10,14,14,6,10,5,4,3,6,11,9,5,30,9,63,32,31,14,12,12,5,3,10,13,6,7,11,54,18,0,0"
        "NQ10" => "58|35|21|17|19|20|58,58,58,58,58|7,4,11,5,8|0:2,4:1,15:1,16:1,29:1,31:1,33:1,41:2,71:1,79:1,103:1,125:1,131:1,135:1,173:1,175:1,224:1,326:1,368:1,370:1,372:1,398:1,426:1,427:1,461:1,464:1,516:1,631:1,761:1,848:1,861:1,1002:2"
        "NQ11" => "58|24|5|4|7|9|58,58,58,58,58|10,2,1,7,4|0:2,27:1,37:1,42:1,52:1,56:1,81:1,96:1,131:1,172:1,240:1,266:1,404:1,415:1,475:1,518:1,607:1,667:1,720:1,742:1,789:1,812:1,906:1"
        => ""
// == ARCHIVE DATA END ==

//@variable The product family the chart symbol belongs to, empty when none was measured.
string archFam = switch syminfo.root
    "NQ"  => "NQ"
    "MNQ" => "NQ"
    "ES"  => "ES"
    "MES" => "ES"
    "GC"  => "GC"
    "MGC" => "GC"
    =>       ""

//@variable True when the archive was asked for. It was measured with the default windows and a wick raid.
bool archAsked = statSrc == "Five-year archive"
bool archFits  = str.substring(asiaSess, 0, 9) == "1800-0200" and str.substring(lonSess, 0, 9) == "0200-0600" and
     str.substring(nySess, 0, 9) == "0700-1615" and not closeThrough
//@variable True when the panel reads the archive rather than the loaded history.
bool archOn = archAsked and archFits and f_archDays(archFam) > 0
//@variable A cycle armed at or before this time is already inside the archive and is not counted again.
int archEndT = archOn ? f_archEnd(archFam) : 0

//@function Whole number out of a text field.
f_int(string s) => int(math.round(nz(str.tonumber(s))))

//@function Fills one pool's history from its archive row.
//@param st (PoolStats) The pool's history
//@param row (string) The archive row
//@returns (bool) True when the row was read
f_archLoad(PoolStats st, string row) =>
    array<string> f = str.split(row, "|")
    bool ok = f.size() == 9
    if ok
        int bm = int(math.round(timeframe.in_seconds() / 60))
        st.n         := f_int(f.get(0))
        st.raids     := f_int(f.get(1))
        st.revInside := f_int(f.get(bm >= 30 ? 5 : bm >= 15 ? 4 : bm >= 5 ? 3 : 2))
        array<string> obs = str.split(f.get(6), ",")
        array<string> rd  = str.split(f.get(7), ",")
        for d = 0 to 4
            st.dowObs.set(d, f_int(obs.get(d)))
            st.dowRaid.set(d, f_int(rd.get(d)))
        // Day and week rows are one count per slot. A month row is 1,104 slots, nearly all empty, so
        // it carries only the slots that hold a raid, as slot:count.
        array<string> fr = str.split(f.get(8), ",")
        for k = 0 to fr.size() - 1
            string tok = fr.get(k)
            int slotIdx = k
            int v = 0
            if str.contains(tok, ":")
                array<string> kv = str.split(tok, ":")
                slotIdx := f_int(kv.get(0))
                v := f_int(kv.get(1))
            else
                v := f_int(tok)
            if slotIdx >= 0 and slotIdx < st.firstRaid.size() and v > 0
                st.firstRaid.set(slotIdx, v)
                int seg = f_segOf(slotIdx % SLOTS_DAY)
                st.segCnt.set(seg, st.segCnt.get(seg) + v)
        int best = 0
        for s = 1 to 6
            if st.segCnt.get(s) > st.segCnt.get(best)
                best := s
        st.peakSeg := st.segCnt.get(best) > 0 ? best : -1
    ok

// == POOL LIFECYCLE ==========================================================

//@function Posts a finished cycle into the pool's history and clears the instance.
//
//          NOTHING reaches the history anywhere else. A cycle contributes once, at its end,
//          and only if it ran from a complete source period — which keeps the partial cycle
//          at the very start of the loaded history, and the one still in progress at the
//          right hand edge, out of every number the table prints.
//
//          The Monday-to-Friday split is keyed differently for the grids, and both
//          readings are a valid ratio. A daily cycle belongs to the statistical day it armed
//          on, so its column is that day. A weekly or monthly cycle is live across all five days,
//          so it counts as observed in every column and its raid is filed under the day the raid
//          itself landed on — "of N weeks observed, X were first raided on a Tuesday".
//@param this (PoolLive) The instance ending
//@param st (PoolStats) The pool's history
//@param grid (int) The pool's clock; GRID_NONE posts nothing
//@returns (bool) Always true
method retire(PoolLive this, PoolStats st, int grid) =>
    if grid != GRID_NONE and this.armed and this.clean and not na(this.level) and this.armT > archEndT
        st.n += 1
        if grid == GRID_DAY and this.armDow >= 0
            st.dowObs.set(this.armDow, st.dowObs.get(this.armDow) + 1)
        if grid != GRID_DAY
            for d = 0 to 4
                st.dowObs.set(d, st.dowObs.get(d) + 1)

        if this.raided and this.raidSlot >= 0 and this.raidSlot < st.firstRaid.size()
            st.raids += 1
            st.firstRaid.set(this.raidSlot, st.firstRaid.get(this.raidSlot) + 1)

            int seg = f_segOf(this.raidSlot % SLOTS_DAY)
            st.segCnt.set(seg, st.segCnt.get(seg) + 1)

            int dowSlot = grid == GRID_DAY ? this.armDow : this.raidDow
            if dowSlot >= 0 and dowSlot <= 4
                st.dowRaid.set(dowSlot, st.dowRaid.get(dowSlot) + 1)

            if this.raidClosedInside
                st.revInside += 1

            int best = 0
            for s = 1 to 6
                if st.segCnt.get(s) > st.segCnt.get(best)
                    best := s
            st.peakSeg := st.segCnt.get(best) > 0 ? best : -1

    this.armed  := false
    this.raided := false
    true

//@function Opens a new instance of a pool.
//@param this (PoolLive) The instance being opened
//@param lvl (float) Price of the pool
//@param oT (int) Timestamp of the candle that formed it
//@param cleanSrc (bool) Whether the source period was complete
//@param aDow (int) Monday-to-Friday index of the statistical day, or -1
//@returns (bool) Always true
method arm(PoolLive this, float lvl, int oT, bool cleanSrc, int aDow) =>
    this.boxL             := 0
    this.boxR             := 0
    this.level            := lvl
    this.originT          := oT
    this.armT             := time
    this.armed            := true
    this.clean            := cleanSrc
    this.raided           := false
    this.raidSlot         := -1
    this.raidT            := 0
    this.raidPx           := na
    this.raidDow          := -1
    this.raidClosedInside := false
    this.armDow           := aDow
    this.lastNearT        := time
    true

//@function Ends a pool's running cycle and opens the next, on one call so the two can never be split.
//@param this (PoolLive) The instance
//@param st (PoolStats) The pool's history
//@param grid (int) The pool's clock
//@param lvl (float) Price of the new level
//@param oT (int) Timestamp of the candle that formed it
//@param cleanSrc (bool) Whether the source period was complete
//@param aDow (int) Monday-to-Friday index of the statistical day
//@param dTxt (string) The period it belongs to, as printed beside its name
//@returns (bool) Always true
method rearm(PoolLive this, PoolStats st, int grid, float lvl, int oT, bool cleanSrc, int aDow, string dTxt) =>
    this.retire(st, grid)
    this.arm(lvl, oT, cleanSrc, aDow)
    this.dateTxt := dTxt
    true

//@function Arms a level that has never been armed, off its period candle, on a chart that opened part way
//          through the period. Never posts to the statistics. A level the running period had already
//          traded through before the chart's history began is armed as taken, with no raid time.
//@param this (PoolLive) The instance
//@param lvl (float) The period candle's high or low
//@param oT (int) Open time of the period candle
//@param dTxt (string) The period it belongs to, as printed beside its name
//@param isHigh (bool) True for a buyside level
//@param toDate (float) The running period's extreme so far, on daily candles
//@param samePeriod (bool) True when toDate belongs to the period now running
//@returns (bool) Always true
method seed(PoolLive this, float lvl, int oT, string dTxt, bool isHigh, float toDate, bool samePeriod) =>
    if not this.armed and not na(lvl)
        this.arm(lvl, oT, false, -1)
        this.dateTxt := dTxt
        if samePeriod and not na(toDate) and (isHigh ? toDate > lvl : toDate < lvl)
            this.raided := true
    true

//@function Records the first and last candle of the session a pool came from.
//@param this (PoolLive) The instance
//@param fromT (int) Time of the session's first candle
//@param toT (int) Time of the session's last candle
//@returns (bool) Always true
method span(PoolLive this, int fromT, int toT) =>
    this.boxL := fromT
    this.boxR := toT
    true

//@function Conditional hit rate given the pool is still unswept at a slot.
//
//          Walks the pool's own cycle order from its cycle start and totals the first raids
//          that landed STRICTLY BEFORE the slot asked about. Those cycles are spent: they
//          were raided by now, so they cannot be raided later. Removing them from both the
//          numerator and the denominator leaves the population that reached this slot with
//          the pool still open, and the share of it that went on to raid.
//
//          Evaluated at the cycle start the sum is empty, so the answer is the headline hit
//          rate exactly — which is the invariant that keeps the two numbers on one scale.
//@param st (PoolStats) The pool's history
//@param cycStart (int) Slot the pool's cycle begins at
//@param nowSlot (int) Slot to evaluate at
//@param slotsLen (int) Length of the pool's grid
//@returns (tuple) Cycles that went on to raid, and cycles still open at that slot
f_cond(PoolStats st, int cycStart, int nowSlot, int slotsLen) =>
    int spent = 0
    for k = 0 to slotsLen - 1
        int idx = (cycStart + k) % slotsLen
        if idx == nowSlot
            break
        spent += st.firstRaid.get(idx)
    [st.raids - spent, st.n - spent]

// == STATE ===================================================================

var array<PoolDef>   defs  = array.new<PoolDef>()
var array<PoolStats> stats = array.new<PoolStats>()
var array<PoolLive>  lives = array.new<PoolLive>()

var PeriodTrk dayTrk  = PeriodTrk.new()
var PeriodTrk dayPrev = PeriodTrk.new()
var PeriodTrk wkTrk   = PeriodTrk.new()
var PeriodTrk wkPrev  = PeriodTrk.new()
var PeriodTrk asiaTrk = PeriodTrk.new()
var PeriodTrk lonTrk  = PeriodTrk.new()
var PeriodTrk nyTrk   = PeriodTrk.new()
// The month and the quarter are STATISTICAL periods — every statistical day named for a date in them —
// which is also how the exchange's own monthly candle is built. Each is sampled at its open and then emptied.
var PeriodTrk monTrk  = PeriodTrk.new()
var PeriodTrk qtrTrk  = PeriodTrk.new()

//@variable Statistical days completed since the loaded history began.
var int daysSeen = 0
//@variable Day of week of the previous true day, used to place the week boundary.
var int prevTrueDow = na
//@variable Monday-to-Friday index of the previous statistical day.
var int prevStatIdx = na

var array<string> DAY_NAMES = array.from("Mon", "Tue", "Wed", "Thu", "Fri")
var array<string> SEG_NAMES = array.from("18:00-00:00", "00:00-07:00", "07:00-09:30",
     "09:30-11:00", "11:00-13:30", "13:30-16:00", "16:00-18:00")

// == CLOCK ===================================================================

//@variable Length of one chart bar in minutes, floored at 1 on sub-minute timeframes.
int barMinutes = math.max(int(math.round(timeframe.in_seconds() / 60)), 1)

// The grid is thirty minutes wide, so a bar wider than that can straddle a boundary and
// the raid would be filed at a time it did not happen. Nothing is measured above 30m.
bool tfOk = timeframe.isintraday and barMinutes >= 1 and barMinutes <= 30

// The session windows are cut to nine characters inline, NOT through a helper. A user
// function's return is inferred as series and time() will only take a simple session string,
// so wrapping this in a function makes it uncallable. Cutting also discards any day mask —
// removing it beats leaving it unset, because editing a time in TradingView's session picker
// can rewrite the string, and a mask that reappeared there would quietly start filtering days
// behind this script's own day rule.
simple string asiaWin = str.substring(asiaSess, 0, 9)
simple string lonWin  = str.substring(lonSess, 0, 9)
simple string nyWin   = str.substring(nySess, 0, 9)

bool asiaRaw = not na(time(timeframe.period, asiaWin, TZ))
bool lonRaw  = not na(time(timeframe.period, lonWin, TZ))
bool nyRaw   = not na(time(timeframe.period, nyWin, TZ))

[inAsia, asiaOpen] = f_days(asiaRaw, f_overnight(asiaWin))
[inLon, lonOpen]   = f_days(lonRaw, f_overnight(lonWin))
[inNy, nyOpen]     = f_days(nyRaw, f_overnight(nyWin))

// The slot comes off the true New York wall clock, so it is exact across a daylight saving
// change. The statistical date key comes off the shifted timestamp. The two can disagree by
// one bar window across a DST transition, which for index futures and metals falls inside
// the weekend gap where there are no bars at all.
int nyMinute = hour(time, TZ) * 60 + minute(time, TZ)
int slotNow  = f_slot(nyMinute)

int shifted = time + SHIFT_MS
int statKey = year(shifted, TZ) * 10000 + month(shifted, TZ) * 100 + dayofmonth(shifted, TZ)
int statDow = dayofweek(shifted, TZ)

int nyKey = year(time, TZ) * 10000 + month(time, TZ) * 100 + dayofmonth(time, TZ)
int nyDow = dayofweek(time, TZ)

// Monday through Friday map to 0-4. A statistical day labelled Saturday or Sunday only exists
// on a symbol that trades the weekend; it follows Friday's, so it shares Friday's column
// on the week grid rather than opening one of its own.
int statIdx = statDow == dayofweek.monday ? 0 :
     statDow == dayofweek.tuesday ? 1 :
     statDow == dayofweek.wednesday ? 2 :
     statDow == dayofweek.thursday ? 3 : 4

//@variable Slot on the 240 slot week grid, for the pools whose cycle is a whole week.
int weekSlotNow = statIdx * SLOTS_DAY + slotNow

//@variable Display window the current bar falls in.
int segNow = f_segOf(slotNow)

bool newStatDay = statKey != statKey[1]
bool newTrueDay = nyKey != nyKey[1]

// The statistical week opens with the statistical day labelled Monday — Sunday 18:00. The
// second test is the holiday case: a week whose Monday never traded still has to open.
bool newStatWeek = newStatDay and (statIdx == 0 or statIdx < nz(prevStatIdx, 99))

// The true week is anchored on Monday 00:00 New York. Sunday closes a week rather than opening
// one, which is what puts a full Monday-to-Friday measurement in the tracker at Sunday 18:00,
// where the previous week's high and low are read from it.
bool newTrueWeek = newTrueDay and (nyDow == dayofweek.monday or
     prevTrueDow == dayofweek.sunday or
     (nyDow < nz(prevTrueDow, 0) and nyDow != dayofweek.sunday))

if newTrueDay
    prevTrueDow := nyDow
if newStatDay
    prevStatIdx := statIdx

int statY   = year(shifted, TZ)
int statMon = month(shifted, TZ)
int statMonKey = statY * 100 + statMon
int statQtr    = int(math.floor((statMon - 1) / 3))
int statQtrKey = statY * 10 + statQtr
bool newStatMonth = statMonKey != statMonKey[1]
bool newStatQtr   = statQtrKey != statQtrKey[1]

//@function Weekdays from the 1st of a month up to, not including, a given date — the statistical day of
//          the month for a chart that never saw the month open. A full exchange holiday earlier in the
//          month (Good Friday, a weekday Christmas or New Year) puts it one day high.
//@param y (int) Year
//@param m (int) Month
//@param d (int) Day of the month
//@returns (int) The count
f_weekdaysBefore(int y, int m, int d) =>
    int cnt = 0
    if d > 1
        for k = 1 to d - 1
            int dw = dayofweek(timestamp("UTC", y, m, k, 12, 0), "UTC")
            if dw != dayofweek.saturday and dw != dayofweek.sunday
                cnt += 1
    cnt

//@variable Statistical day of the month, 0 on its first. Counted from the month open when the chart saw it.
var int monthDay = 0
var bool monthDaySeen = false
if newStatMonth and not na(statMonKey[1])
    monthDay     := 0
    monthDaySeen := true
else if newStatDay
    monthDay := monthDaySeen ? monthDay + 1 : f_weekdaysBefore(statY, statMon, dayofmonth(shifted, TZ))
if not monthDaySeen and bar_index == 0
    monthDay := f_weekdaysBefore(statY, statMon, dayofmonth(shifted, TZ))

//@variable Slot on the month grid, for the pools whose cycle is a whole month.
int monthSlotNow = math.min(monthDay, MONTH_DAYS - 1) * SLOTS_DAY + slotNow

//@function The slot now on a pool's own clock.
//@param grid (int) The pool's clock
//@returns (int) The slot
f_nowSlot(int grid) =>
    grid == GRID_MONTH ? monthSlotNow : grid == GRID_WEEK ? weekSlotNow : slotNow

//@variable Average daily range over the previous adrLen completed daily bars.
float adr = request.security(syminfo.tickerid, "D", ta.sma(high - low, adrLen)[1],
     lookahead = barmerge.lookahead_on)

//@variable Price distance beyond which a drawing is removed rather than left hanging.
float distGate = nz(adr, 0.0) * maxDistAdr

// The previous week, month and quarter as the exchange's own candles report them. They are the level only
// where the chart never saw the whole period — a short one-minute history holds neither the month nor,
// often, the week — and a level taken from them is drawn but never posted to the statistics. The
// [1] + lookahead_on pair asks for the settled previous candle, so none of the three can repaint.
[wHiC, wLoC, wOpenC] = request.security(syminfo.tickerid, "W",  [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)
[mHiC, mLoC, mOpenC] = request.security(syminfo.tickerid, "M",  [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)
[qHiC, qLoC, qOpenC] = request.security(syminfo.tickerid, "3M", [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)

//@function The running week, month and quarter extremes so far, on daily candles. Read with lookahead off,
//          a chart bar sees them as of the last CLOSED daily candle, which is what a level set before the
//          chart's history began needs to know whether it was already taken.
//@returns (tuple) week high, week low, week's first trading day, month high, month low, month key,
//                 quarter high, quarter low, quarter key
f_toDate() =>
    int td = time_tradingday
    int dw = dayofweek(td, "UTC")
    int mk = year(td, "UTC") * 100 + month(td, "UTC")
    int qk = year(td, "UTC") * 10 + int(math.floor((month(td, "UTC") - 1) / 3))
    var float wH = na
    var float wL = na
    var int   wT = na
    var float mH = na
    var float mL = na
    var float qH = na
    var float qL = na
    var int lastTd = na
    var int lastDw = na
    var int lastMk = na
    var int lastQk = na
    bool nw = na(lastTd) or dw < lastDw or td - lastTd >= 604800000
    if nw
        wH := high
        wL := low
        wT := td
    else
        wH := math.max(wH, high)
        wL := math.min(wL, low)
    if na(lastMk) or mk != lastMk
        mH := high
        mL := low
    else
        mH := math.max(mH, high)
        mL := math.min(mL, low)
    if na(lastQk) or qk != lastQk
        qH := high
        qL := low
    else
        qH := math.max(qH, high)
        qL := math.min(qL, low)
    lastTd := td
    lastDw := dw
    lastMk := mk
    lastQk := qk
    [wH, wL, wT, mH, mL, mk, qH, qL, qk]

[wtdHi, wtdLo, wtdStart, mtdHi, mtdLo, mtdKey, qtdHi, qtdLo, qtdKey] = request.security(syminfo.tickerid, "D", f_toDate())

// == POOL CONSTRUCTION =======================================================

if barstate.isfirst
    int asiaEnd = f_endSlot(asiaWin)
    int lonEnd  = f_endSlot(lonWin)
    int nyEnd   = f_endSlot(nyWin)

    defs.push(PoolDef.new(nm = "PDH",      isHigh = true,  cycStart = 0,       grid = GRID_DAY,   shown = showPd, rank = 1))
    defs.push(PoolDef.new(nm = "PDL",      isHigh = false, cycStart = 0,       grid = GRID_DAY,   shown = showPd, rank = 1))
    defs.push(PoolDef.new(nm = "PWH",      isHigh = true,  cycStart = 0,       grid = GRID_WEEK,  shown = showPw, rank = 2))
    defs.push(PoolDef.new(nm = "PWL",      isHigh = false, cycStart = 0,       grid = GRID_WEEK,  shown = showPw, rank = 2))
    defs.push(PoolDef.new(nm = "Asia H",   isHigh = true,  cycStart = asiaEnd, grid = GRID_DAY,   shown = showAs, rank = 0))
    defs.push(PoolDef.new(nm = "Asia L",   isHigh = false, cycStart = asiaEnd, grid = GRID_DAY,   shown = showAs, rank = 0))
    defs.push(PoolDef.new(nm = "London H", isHigh = true,  cycStart = lonEnd,  grid = GRID_DAY,   shown = showLo, rank = 0))
    defs.push(PoolDef.new(nm = "London L", isHigh = false, cycStart = lonEnd,  grid = GRID_DAY,   shown = showLo, rank = 0))
    defs.push(PoolDef.new(nm = "NY H",     isHigh = true,  cycStart = nyEnd,   grid = GRID_DAY,   shown = showNy, rank = 0))
    defs.push(PoolDef.new(nm = "NY L",     isHigh = false, cycStart = nyEnd,   grid = GRID_DAY,   shown = showNy, rank = 0))
    defs.push(PoolDef.new(nm = "PMH",      isHigh = true,  cycStart = 0,       grid = GRID_MONTH, shown = showPm, rank = 3))
    defs.push(PoolDef.new(nm = "PML",      isHigh = false, cycStart = 0,       grid = GRID_MONTH, shown = showPm, rank = 3))
    defs.push(PoolDef.new(nm = "PQH",      isHigh = true,  cycStart = 0,       grid = GRID_NONE,  shown = showPq, rank = 4))
    defs.push(PoolDef.new(nm = "PQL",      isHigh = false, cycStart = 0,       grid = GRID_NONE,  shown = showPq, rank = 4))

    for i = 0 to POOL_N - 1
        int g = defs.get(i).grid
        stats.push(PoolStats.new(firstRaid = array.new<int>(g == GRID_NONE ? 0 : f_gridLen(g), 0),
             segCnt = array.new<int>(7, 0), dowObs = array.new<int>(5, 0),
             dowRaid = array.new<int>(5, 0)))
        lives.push(PoolLive.new())
        if archOn and i < POOL_TIMED
            f_archLoad(stats.get(i), f_archRow(archFam, i))

//@variable Index of the pool broken out in the focus table.
var int focusPool = 0
if barstate.isfirst
    for i = 0 to POOL_TIMED - 1
        if defs.get(i).nm == focusName
            focusPool := i

// == DRIVER (confirmed bars only) ============================================

// Order matters and is fixed: the true periods roll over first, then the pools arm from what
// those periods hold, then the current bar is folded in, then raids are tested. The pool armed
// on this bar is therefore tested against this bar — a print in the evening through a level frozen at
// 18:00 is a raid in the 18:00-18:30 slot, which is exactly what the tool is built to measure.

//@variable True on the bar each pool is first raided, in pool order.
var array<bool> raidNow = array.new<bool>(POOL_N, false)
//@variable True on the bar a pool still unswept enters its own historically busiest window.
bool peakEntry = false

// Cleared unconditionally, OUTSIDE the confirmed gate. Left inside it, a flag raised on a
// closed bar would still be standing through the whole of the forming bar that follows and
// the alert would fire a second time on a raid that only happened once.
for i = 0 to POOL_N - 1
    raidNow.set(i, false)

if barstate.isconfirmed and tfOk
    // ── True periods ────────────────────────────────────────────────────────
    if newTrueWeek
        if wkTrk.hasBars
            wkPrev.copyFrom(wkTrk)
        wkTrk.wipe(true)
    if newTrueDay
        if dayTrk.hasBars
            dayPrev.copyFrom(dayTrk)
        dayTrk.wipe(true)

    // ── Sessions ────────────────────────────────────────────────────────────
    if asiaOpen
        asiaTrk.wipe(true)
    if lonOpen
        lonTrk.wipe(true)
    if nyOpen
        nyTrk.wipe(true)

    // ── Arming ──────────────────────────────────────────────────────────────
    // Previous week, at the weekly open. The tracker holds the week that has just traded;
    // it falls back to the last completed one on a symbol whose week has no bars left
    // in it by the time the new one opens.
    // A week the chart did not see from its open is read off the weekly candle instead of the part
    // the chart holds, which would be the wrong price. It is drawn, never posted.
    if newStatWeek
        PeriodTrk src = wkTrk.hasBars ? wkTrk : wkPrev
        if src.hasBars and src.fresh
            lives.get(P_PWH).rearm(stats.get(P_PWH), GRID_WEEK, src.hi, src.hiT, true, statIdx, f_ddmm(src.hiT))
            lives.get(P_PWL).rearm(stats.get(P_PWL), GRID_WEEK, src.lo, src.loT, true, statIdx, f_ddmm(src.loT))
        else if not na(wHiC)
            int hT = f_anchor(src, true, wHiC, wOpenC)
            int lT = f_anchor(src, false, wLoC, wOpenC)
            lives.get(P_PWH).rearm(stats.get(P_PWH), GRID_WEEK, wHiC, hT, false, statIdx, f_ddmm(hT == wOpenC ? hT + SHIFT_MS : hT))
            lives.get(P_PWL).rearm(stats.get(P_PWL), GRID_WEEK, wLoC, lT, false, statIdx, f_ddmm(lT == wOpenC ? lT + SHIFT_MS : lT))

    // Previous day, at the 18:00 statistical open. The level is the running extreme of the
    // true day now ending — sampled once, then frozen for the whole statistical day, so the
    // evening cannot quietly move the level it is being measured against. On Sunday 18:00
    // the current true day has no bars, and the fallback puts Friday's extremes on the chart.
    if newStatDay
        daysSeen += 1
        PeriodTrk src = dayTrk.hasBars ? dayTrk : dayPrev
        if src.hasBars
            lives.get(P_PDH).rearm(stats.get(P_PDH), GRID_DAY, src.hi, src.hiT, src.fresh, statIdx, f_ddmm(src.hiT))
            lives.get(P_PDL).rearm(stats.get(P_PDL), GRID_DAY, src.lo, src.loT, src.fresh, statIdx, f_ddmm(src.loT))

    // Previous month and quarter, at their statistical open: the month that has just ended is sampled
    // before its tracker is emptied for the new one. Read off the period candle where the chart did not
    // see the whole period, and then drawn but never posted.
    string prevMonTxt = MONTH_NAMES.get(statMon == 1 ? 11 : statMon - 2)
    string prevQtrTxt = "Q" + str.tostring(statQtr == 0 ? 4 : statQtr)
    if newStatMonth and not na(statMonKey[1])
        if monTrk.hasBars and monTrk.fresh
            lives.get(P_PMH).rearm(stats.get(P_PMH), GRID_MONTH, monTrk.hi, monTrk.hiT, true, statIdx, prevMonTxt)
            lives.get(P_PML).rearm(stats.get(P_PML), GRID_MONTH, monTrk.lo, monTrk.loT, true, statIdx, prevMonTxt)
        else if not na(mHiC)
            lives.get(P_PMH).rearm(stats.get(P_PMH), GRID_MONTH, mHiC, f_anchor(monTrk, true, mHiC, mOpenC), false, statIdx, prevMonTxt)
            lives.get(P_PML).rearm(stats.get(P_PML), GRID_MONTH, mLoC, f_anchor(monTrk, false, mLoC, mOpenC), false, statIdx, prevMonTxt)
        monTrk.wipe(true)
    if newStatQtr and not na(statQtrKey[1])
        if qtrTrk.hasBars and qtrTrk.fresh
            lives.get(P_PQH).rearm(stats.get(P_PQH), GRID_NONE, qtrTrk.hi, qtrTrk.hiT, false, statIdx, prevQtrTxt)
            lives.get(P_PQL).rearm(stats.get(P_PQL), GRID_NONE, qtrTrk.lo, qtrTrk.loT, false, statIdx, prevQtrTxt)
        else if not na(qHiC)
            lives.get(P_PQH).rearm(stats.get(P_PQH), GRID_NONE, qHiC, f_anchor(qtrTrk, true, qHiC, qOpenC), false, statIdx, prevQtrTxt)
            lives.get(P_PQL).rearm(stats.get(P_PQL), GRID_NONE, qLoC, f_anchor(qtrTrk, false, qLoC, qOpenC), false, statIdx, prevQtrTxt)
        qtrTrk.wipe(true)

    // A chart that opens part way through a week, month or quarter has no rollover to arm from. The
    // level comes off the period candle at once, and the running week, month or quarter on daily candles
    // says whether price had already taken it before the chart's history began.
    int statDateUtc = timestamp("UTC", statY, statMon, dayofmonth(shifted, TZ), 0, 0)
    bool sameWeek = not na(wtdStart) and wtdStart >= statDateUtc - statIdx * 86400000
    lives.get(P_PWH).seed(wHiC, wOpenC, f_ddmm(wOpenC + SHIFT_MS), true,  wtdHi, sameWeek)
    lives.get(P_PWL).seed(wLoC, wOpenC, f_ddmm(wOpenC + SHIFT_MS), false, wtdLo, sameWeek)
    lives.get(P_PMH).seed(mHiC, mOpenC, prevMonTxt, true,  mtdHi, mtdKey == statMonKey)
    lives.get(P_PML).seed(mLoC, mOpenC, prevMonTxt, false, mtdLo, mtdKey == statMonKey)
    lives.get(P_PQH).seed(qHiC, qOpenC, prevQtrTxt, true,  qtdHi, qtdKey == statQtrKey)
    lives.get(P_PQL).seed(qLoC, qOpenC, prevQtrTxt, false, qtdLo, qtdKey == statQtrKey)

    // Sessions, on the first bar after the window closes. A tracker only exists when this
    // script saw the session open, so a chart starting mid-session simply waits for the next
    // one rather than arming from half a session.
    bool asiaShut = not inAsia and inAsia[1]
    bool lonShut  = not inLon and inLon[1]
    bool nyShut   = not inNy and inNy[1]

    if asiaShut and asiaTrk.hasBars and asiaTrk.fresh
        lives.get(4).rearm(stats.get(4), GRID_DAY, asiaTrk.hi, asiaTrk.hiT, true, statIdx, "")
        lives.get(5).rearm(stats.get(5), GRID_DAY, asiaTrk.lo, asiaTrk.loT, true, statIdx, "")
        lives.get(4).span(asiaTrk.startT, asiaTrk.endT)
        lives.get(5).span(asiaTrk.startT, asiaTrk.endT)
    if lonShut and lonTrk.hasBars and lonTrk.fresh
        lives.get(6).rearm(stats.get(6), GRID_DAY, lonTrk.hi, lonTrk.hiT, true, statIdx, "")
        lives.get(7).rearm(stats.get(7), GRID_DAY, lonTrk.lo, lonTrk.loT, true, statIdx, "")
        lives.get(6).span(lonTrk.startT, lonTrk.endT)
        lives.get(7).span(lonTrk.startT, lonTrk.endT)
    if nyShut and nyTrk.hasBars and nyTrk.fresh
        lives.get(8).rearm(stats.get(8), GRID_DAY, nyTrk.hi, nyTrk.hiT, true, statIdx, "")
        lives.get(9).rearm(stats.get(9), GRID_DAY, nyTrk.lo, nyTrk.loT, true, statIdx, "")
        lives.get(8).span(nyTrk.startT, nyTrk.endT)
        lives.get(9).span(nyTrk.startT, nyTrk.endT)

    // ── Fold this bar into every forming period ─────────────────────────────
    dayTrk.fold()
    wkTrk.fold()
    monTrk.fold()
    qtrTrk.fold()
    if inAsia
        asiaTrk.fold()
    if inLon
        lonTrk.fold()
    if inNy
        nyTrk.fold()

    // ── Raids ───────────────────────────────────────────────────────────────
    for i = 0 to POOL_N - 1
        PoolDef pd  = defs.get(i)
        PoolLive lv = lives.get(i)
        if lv.armed and not lv.raided and not na(lv.level)
            float probe = closeThrough ? close : (pd.isHigh ? high : low)
            bool taken = pd.isHigh ? probe > lv.level : probe < lv.level
            if taken
                lv.raided           := true
                lv.raidSlot         := f_nowSlot(pd.grid)
                lv.raidT            := time
                lv.raidPx           := pd.isHigh ? high : low
                lv.raidDow          := statIdx
                // A raid that closes back on the origin side of the level is the reversal
                // this framework is looking for. Closing THROUGH cannot do that by
                // definition, so in that mode the share is withheld rather than reported.
                lv.raidClosedInside := closeThrough ? false : (pd.isHigh ? close < lv.level : close > lv.level)
                raidNow.set(i, true)
            else if distGate > 0 and low - distGate <= lv.level and high + distGate >= lv.level
                lv.lastNearT := time

    // ── Peak window entry ───────────────────────────────────────────────────
    if segNow != segNow[1]
        for i = 0 to POOL_TIMED - 1
            PoolStats st = stats.get(i)
            PoolLive lv  = lives.get(i)
            if lv.armed and not lv.raided and st.n >= minSample and st.peakSeg == segNow
                peakEntry := true

// == RELATIVE EQUAL HIGHS AND LOWS ===========================================
// Ported from Liquidity Levels+ (M1D). Two swing pivots resting within a tick tolerance of one another
// are ONE pool: the orders beyond them are the same orders, and price treats the pair as a single
// destination. The line anchors at the candle that made the EXTREME of the pair, because that is the
// price that has to trade for the pool to be taken. Drawn, not timed: it has no cycle to put on a clock.

//@type A relative-equal-price liquidity pool.
//@field price The extreme of the pair — what must trade to take it
//@field startT Bar time of the pivot that set the extreme
//@field isHigh True for equal highs, false for equal lows
//@field raided True once price has traded through it
//@field raidT Bar time of the candle that took it
//@field raidPx The wick of that candle
type EqPool
    float price
    int   startT
    bool  isHigh
    bool  raided = false
    int   raidT  = 0
    float raidPx = na

var array<float>  phPrice = array.new<float>(0)
var array<int>    phTime  = array.new<int>(0)
//@variable True once price has traded through this stored pivot. A pivot whose price is spent can never
//          form a live pool.
var array<bool>   phSwept = array.new<bool>(0)
var array<float>  plPrice = array.new<float>(0)
var array<int>    plTime  = array.new<int>(0)
var array<bool>   plSwept = array.new<bool>(0)
var array<EqPool> eqPools = array.new<EqPool>(0)

//@variable Equal-price tolerance in price terms, scaled by the instrument.
float eqTol = syminfo.mintick * eqTolTicks

//@variable How many recent pivots per side are held for pairing.
const int PIVOT_MEMORY = 10

//@function Adds a pool unless one already sits at this price on this side.
//@param px (float) The pool's price
//@param t (int) Bar time of the pivot that set the extreme
//@param isHigh (bool) True for equal highs
//@returns (bool) Always true
f_addEq(float px, int t, bool isHigh) =>
    bool exists = false
    if eqPools.size() > 0
        for i = 0 to eqPools.size() - 1
            EqPool p = eqPools.get(i)
            if p.isHigh == isHigh and math.abs(p.price - px) <= eqTol
                exists := true
    if not exists
        eqPools.push(EqPool.new(price = px, startT = t, isHigh = isHigh))
        while eqPools.size() > eqKeep + eqKeepTaken
            eqPools.shift()
    true

//@function Trims taken pools to the retained count, oldest removed first.
//@param keep (int) How many taken pools may stay on the chart
//@returns (bool) Always true
f_pruneTaken(int keep) =>
    int excess = 0
    if eqPools.size() > 0
        for i = 0 to eqPools.size() - 1
            if eqPools.get(i).raided
                excess += 1
    excess := excess - keep
    // The store is oldest first, so the first taken entry found is the oldest.
    while excess > 0
        int at = -1
        if eqPools.size() > 0
            for i = 0 to eqPools.size() - 1
                if at < 0 and eqPools.get(i).raided
                    at := i
        if at < 0
            excess := 0
        else
            eqPools.remove(at)
            excess := excess - 1
    true

// Both ta.* calls sit at global scope: they carry bar-to-bar state, and behind a condition they would
// skip the bars it is false on and corrupt their own history.
float pivotHi = ta.pivothigh(high, swingLen, swingLen)
float pivotLo = ta.pivotlow(low, swingLen, swingLen)
//@variable Extremes across the pivot's confirmation lag, to catch a pool price already took while the
//          pivot was still confirming.
float sinceHi = ta.highest(high, swingLen + 1)
float sinceLo = ta.lowest(low, swingLen + 1)

//@variable True on the bar a pool of equal highs or lows is taken. Feeds the alerts.
bool eqHighTaken = false
bool eqLowTaken  = false

// Detection is never gated on the display switch: hiding the pools must not stop them being found.
if barstate.isconfirmed
    // Two pivots at one price are only a live pool if that price was never taken BETWEEN them.
    if phPrice.size() > 0
        for i = 0 to phPrice.size() - 1
            if high > phPrice.get(i)
                phSwept.set(i, true)
    if plPrice.size() > 0
        for i = 0 to plPrice.size() - 1
            if low < plPrice.get(i)
                plSwept.set(i, true)

    if not na(pivotHi)
        bool paired = false
        if phPrice.size() > 0
            for i = 0 to phPrice.size() - 1
                if not paired and not phSwept.get(i) and math.abs(phPrice.get(i) - pivotHi) <= eqTol
                    paired := true
                    // The pool sits at the higher of the pair and anchors at the candle that MADE that
                    // high. Ties go to the earlier.
                    float lvl = math.max(phPrice.get(i), pivotHi)
                    int oT = phPrice.get(i) >= pivotHi ? phTime.get(i) : time[swingLen]
                    if sinceHi <= lvl
                        f_addEq(lvl, oT, true)
        phPrice.unshift(pivotHi)
        phTime.unshift(time[swingLen])
        phSwept.unshift(false)
        while phPrice.size() > PIVOT_MEMORY
            phPrice.pop()
            phTime.pop()
            phSwept.pop()

    if not na(pivotLo)
        bool pairedLo = false
        if plPrice.size() > 0
            for i = 0 to plPrice.size() - 1
                if not pairedLo and not plSwept.get(i) and math.abs(plPrice.get(i) - pivotLo) <= eqTol
                    pairedLo := true
                    float lvl = math.min(plPrice.get(i), pivotLo)
                    int oT = plPrice.get(i) <= pivotLo ? plTime.get(i) : time[swingLen]
                    if sinceLo >= lvl
                        f_addEq(lvl, oT, false)
        plPrice.unshift(pivotLo)
        plTime.unshift(time[swingLen])
        plSwept.unshift(false)
        while plPrice.size() > PIVOT_MEMORY
            plPrice.pop()
            plTime.pop()
            plSwept.pop()

    // A wick through is the raid, the same as every pool in this script.
    if eqPools.size() > 0
        for i = eqPools.size() - 1 to 0
            EqPool p = eqPools.get(i)
            if not p.raided and (p.isHigh ? high > p.price : low < p.price)
                p.raided := true
                p.raidT  := time
                p.raidPx := p.isHigh ? high : low
                if p.isHigh
                    eqHighTaken := true
                else
                    eqLowTaken := true
                if onTaken == "Remove"
                    eqPools.remove(i)
    f_pruneTaken(onTaken == "Remove" ? 0 : eqKeepTaken)

// == DRAWING (last bar only) =================================================
// The bar-by-bar pass collects DATA. Every drawing is built fresh on the last bar from what
// was collected, so nothing has to survive thousands of bars of edits to still be correct.
//
// Two families, drawn two ways.
//
// SESSION POOLS. Only armed, unswept, near levels draw. A raided session level's line and caption
// are gone the same bar it is taken — the swept state lives in the table, where it costs the chart
// nothing. Nothing extends: each line runs from the candle that formed the level to the current
// candle and stops there.
//
// LIQUIDITY LEVELS — the previous day, week, month and quarter, and equal highs and lows. Ported from
// Liquidity Levels+ (M1D). Each runs from the candle that formed it to a fixed right hand edge, and its
// name sits at that end. Seniority buys reach: each family stops a fixed number of bars further right
// than the one below it, so the names sort into columns without any leaving the end of its own line.
// They are exempt from the distance and age gates — a monthly level is meant to be far away. A taken
// one turns dotted and stops at the candle that took it, its name crossed above that candle's high or
// below its low, until the next period replaces it.

//@variable Equal highs and lows drawings, rebuilt on the last bar.
var array<line>  eqLines  = array.new<line>()
var array<label> eqLabels = array.new<label>()

//@function The name printed on a liquidity level: the pool, its period, its price on Full, and its live
//          conditional where the pool is timed.
//@param i (int) Pool index
//@returns (string) The caption
f_levelCap(int i) =>
    PoolDef pd   = defs.get(i)
    PoolStats st = stats.get(i)
    PoolLive lv  = lives.get(i)
    string txt = pd.nm + (lv.dateTxt != "" ? " " + lv.dateTxt : "")
    if labelDetail == "Full"
        txt += "  " + f_price(lv.level)
    if pd.grid != GRID_NONE
        [went, open2] = f_cond(st, pd.cycStart, f_nowSlot(pd.grid), f_gridLen(pd.grid))
        txt += "  " + f_rate(went, open2)
    txt

//@function One price, one name. The most senior live level at a price carries every coinciding name, one
//          line each, and the junior levels at that price lose their own label. Without it the senior's
//          line, which always reaches further right, runs straight through a junior's separate name
//          whenever two periods closed at the same price, e.g. PWH == PDH.
//@param side (array<int>) One side's liquidity level pools, most senior first
//@returns (bool) Always true
f_mergeSame(array<int> side) =>
    int n = side.size()
    array<bool> merged = array.new<bool>(n, false)
    for a = 0 to n - 1
        PoolLive s = lives.get(side.get(a))
        if not merged.get(a) and not na(s.lblObj) and not s.raided
            string txt = label.get_text(s.lblObj)
            if a < n - 1
                for b = a + 1 to n - 1
                    PoolLive t = lives.get(side.get(b))
                    if not merged.get(b) and not na(t.lblObj) and not t.raided and math.abs(t.level - s.level) <= syminfo.mintick
                        txt += "\n" + label.get_text(t.lblObj)
                        label.delete(t.lblObj)
                        t.lblObj := na
                        merged.set(b, true)
            label.set_text(s.lblObj, txt)
    true

//@function True when a live liquidity level already names this price, so a pool of equal highs or lows
//          sitting on it keeps its line and drops its name.
//@param px (float) The price to test
//@returns (bool) True if a named level sits within the equal-price tolerance
f_levelNamed(float px) =>
    bool hit = false
    for i = 0 to POOL_N - 1
        PoolLive lv = lives.get(i)
        if defs.get(i).rank > 0 and not na(lv.lblObj) and not lv.raided and math.abs(lv.level - px) <= eqTol
            hit := true
    hit

//@function A transparent callout at the right hand end of a line, on the line's own price.
//@param x (int) Bar time of the line's right hand end
//@param y (float) The line's price
//@param txt (string) The caption
//@param col (color) Text colour
//@returns (label) The label
f_endCap(int x, float y, string txt, color col) =>
    label lb = label.new(x, y, txt, xloc = xloc.bar_time, style = label.style_label_left,
         color = color.new(C_INK, 100), textcolor = col, size = LBL_SZ, textalign = text.align_left,
         text_formatting = text.format_bold)
    label.set_text_font_family(lb, font.family_monospace)
    lb

//@function A taken level's name with a cross, at the swing that made the level: above a high, below a
//          low, running right along the dotted line so it never sits in the price that took it.
//@param x (int) Bar time of the level's origin
//@param y (float) The level
//@param txt (string) The pool's name
//@param isHigh (bool) True for a buyside level
//@param col (color) Text colour
//@returns (label) The label
f_takenCap(int x, float y, string txt, bool isHigh, color col) =>
    label lb = label.new(x, y, txt + " ×", xloc = xloc.bar_time,
         style = isHigh ? label.style_label_lower_left : label.style_label_upper_left,
         color = color.new(C_INK, 100), textcolor = col, size = LBL_SZ, textalign = text.align_left,
         text_formatting = text.format_bold)
    label.set_text_font_family(lb, font.family_monospace)
    lb

//@function One swing, one taken label. Levels made by the same candle on one side are named in a
//          single label, rather than one label per level stacked on one spot.
//@param lbs (array<label>) Taken labels already placed this pass
//@param xs (array<int>) Their origin candle times
//@param ups (array<bool>) Their sides, true for buyside
//@param x (int) Bar time of the level's origin
//@param y (float) The level
//@param txt (string) The pool's name
//@param isHigh (bool) True for a buyside level
//@param col (color) Text colour
//@returns (label) The label now carrying the name
f_takenAt(array<label> lbs, array<int> xs, array<bool> ups, int x, float y, string txt, bool isHigh, color col) =>
    int hit = -1
    if lbs.size() > 0
        for k = 0 to lbs.size() - 1
            if xs.get(k) == x and ups.get(k) == isHigh
                hit := k
    label lb = na
    if hit >= 0
        lb := lbs.get(hit)
        label.set_text(lb, label.get_text(lb) + "\n" + txt + " ×")
    else
        lb := f_takenCap(x, y, txt, isHigh, col)
        lbs.push(lb)
        xs.push(x)
        ups.push(isHigh)
    lb

//@function The live liquidity level a session pool coincides with, if any. A session high is very often
//          the previous day's high itself, and the two names would print into each other at one price.
//@param isHigh (bool) True for a buyside pool
//@param px (float) The session pool's price
//@returns (int) The level's pool index, or -1 when none sits on that price
f_levelAt(bool isHigh, float px) =>
    int hit = -1
    for i = 0 to POOL_N - 1
        PoolDef d  = defs.get(i)
        PoolLive l = lives.get(i)
        if hit < 0 and d.rank > 0 and d.shown and d.isHigh == isHigh and l.armed and not l.raided and
             not na(l.level) and math.abs(l.level - px) <= syminfo.mintick
            hit := i
    hit

var array<int> HIGH_SIDE = array.from(P_PQH, P_PMH, P_PWH, P_PDH)
var array<int> LOW_SIDE  = array.from(P_PQL, P_PML, P_PWL, P_PDL)

if barstate.islast
    for i = 0 to POOL_N - 1
        PoolLive lv = lives.get(i)
        line.delete(lv.lnObj)
        label.delete(lv.lblObj)
        lv.lnObj  := na
        lv.lblObj := na
        lv.far    := false
        lv.stale  := false
    for ln in eqLines
        line.delete(ln)
    for lb in eqLabels
        label.delete(lb)
    eqLines.clear()
    eqLabels.clear()

    // Captions are created on their own true price and then placed by one layout pass at the
    // end, because whether two of them collide is not knowable until every one exists.
    array<label> capLbl = array.new<label>()
    array<float> capPx  = array.new<float>()
    // Origin tags already placed this pass, so two pools formed by one candle share a tag.
    array<label> tagLbl = array.new<label>()
    array<int>   tagT   = array.new<int>()
    array<float> tagPx  = array.new<float>()
    // Taken labels already placed this pass, so one raid candle carries one label per side.
    array<label> takenLbl = array.new<label>()
    array<int>   takenX   = array.new<int>()
    array<bool>  takenUp  = array.new<bool>()
    // Session names that belong on a liquidity level's label, handed over once that label exists.
    array<int>    pendIdx = array.new<int>()
    array<string> pendTxt = array.new<string>()
    bool tagMode = levelMode == "Origin tags"
    int barMs = barMinutes * 60000

    if tfOk
        // ── Session pools ───────────────────────────────────────────────────
        int maxAgeMs = int(math.round(retireHours * 3600000))
        for i = 0 to POOL_N - 1
            PoolDef pd   = defs.get(i)
            PoolStats st = stats.get(i)
            PoolLive lv  = lives.get(i)

            if pd.rank == 0 and lv.armed and not lv.raided and not na(lv.level)
                // Both tests need the daily range to mean anything, and "untouched" is
                // measured against the same gate, so with no daily data neither runs and
                // the footer says the gate is withheld rather than the chart going blank.
                lv.far   := distGate > 0 and math.abs(lv.level - close) > distGate
                lv.stale := distGate > 0 and lv.lastNearT > 0 and (time - lv.lastNearT) > maxAgeMs

                if pd.shown and not lv.far and not lv.stale
                    color poolCol = pd.isHigh ? buyCol : sellCol
                    [went, open2] = f_cond(st, pd.cycStart, f_nowSlot(pd.grid), f_gridLen(pd.grid))
                    if tagMode
                        string tagTxt = pd.nm + "  " + f_rate(went, open2)
                        bool tagBeside = tagSide == "Beside the candle"
                        bool tagBox    = tagSide == "Session box corners" and lv.boxR > 0
                        bool tagEnd    = tagSide == "Line end, inside" or tagSide == "Line end, outside" or (tagSide == "Session box corners" and not tagBox)
                        // Inside is under a high and over a low; the corner styles hang the text off that side.
                        bool tagUnder  = pd.isHigh == (tagSide != "Line end, outside")
                        int tagX = tagBox ? f_xClamp(lv.boxR) : tagEnd ? time + tagRunway * barMs : f_xClamp(lv.originT) - (tagBeside ? 2 * barMs : 0)
                        int lvlHit = tagEnd ? f_levelAt(pd.isHigh, lv.level) : -1
                        int hit = -1
                        if tagLbl.size() > 0
                            for k = 0 to tagLbl.size() - 1
                                if tagT.get(k) == tagX and tagPx.get(k) == lv.level
                                    hit := k
                        if lvlHit >= 0
                            pendIdx.push(lvlHit)
                            pendTxt.push(tagTxt)
                        else if hit >= 0
                            label.set_text(tagLbl.get(hit), label.get_text(tagLbl.get(hit)) + "\n" + tagTxt)
                        else
                            label tag = label.new(tagX, lv.level, tagTxt,
                                 xloc      = xloc.bar_time,
                                 style     = tagBox ? (pd.isHigh ? label.style_label_upper_right : label.style_label_lower_right) : tagEnd ? (tagUnder ? label.style_label_upper_right : label.style_label_lower_right) : tagBeside ? label.style_label_right : pd.isHigh ? label.style_label_down : label.style_label_up,
                                 color     = color.new(C_INK, 100),
                                 textcolor = poolCol,
                                 size      = LBL_SZ,
                                 textalign = tagBox or tagBeside or tagEnd ? text.align_right : text.align_center,
                                 text_formatting = text.format_bold)
                            label.set_text_font_family(tag, font.family_monospace)
                            lv.lblObj := tag
                            tagLbl.push(tag)
                            tagT.push(tagX)
                            tagPx.push(lv.level)
                            // At the line end every tag shares one column, so they go through the same
                            // spacing pass the line captions use.
                            if tagEnd
                                capLbl.push(tag)
                                capPx.push(lv.level)
                    else
                        lv.lnObj := line.new(f_xClamp(lv.originT), lv.level, time, lv.level,
                             xloc = xloc.bar_time, color = poolCol, width = lineW,
                             style = line.style_solid)
                        if labelDetail != "None"
                            string capTxt = pd.nm + "  " + f_rate(went, open2)
                            if labelDetail == "Full"
                                capTxt := pd.nm + " " + f_price(lv.level) + "  " + f_rate(went, open2)
                            // A left-pointing callout carries its body to the LEFT of its anchor,
                            // so the caption sits off the right hand end of the line it belongs to
                            // and never over it. It is placed on the level's own price here; the
                            // layout pass below moves it only if another caption is already there.
                            int lvlHit = f_levelAt(pd.isHigh, lv.level)
                            if lvlHit >= 0
                                pendIdx.push(lvlHit)
                                pendTxt.push(capTxt)
                            else
                                label cap = f_endCap(time, lv.level, capTxt, poolCol)
                                lv.lblObj := cap
                                capLbl.push(cap)
                                capPx.push(lv.level)

        // ── Liquidity levels: day, week, month, quarter ─────────────────────
        for i = 0 to POOL_N - 1
            PoolDef pd  = defs.get(i)
            PoolLive lv = lives.get(i)
            if pd.rank > 0 and pd.shown and lv.armed and not na(lv.level)
                color poolCol = pd.isHigh ? buyCol : sellCol
                if not lv.raided
                    int edge = time + (runwayBars + pd.rank * tfStep) * barMs
                    lv.lnObj := line.new(f_xClamp(lv.originT), lv.level, edge, lv.level,
                         xloc = xloc.bar_time, color = poolCol, width = lineW, style = line.style_solid)
                    if labelDetail != "None"
                        lv.lblObj := f_endCap(edge, lv.level, f_levelCap(i), poolCol)
                else if onTaken != "Remove" and lv.raidT > 0
                    lv.lnObj := line.new(f_xClamp(lv.originT), lv.level, f_xClamp(lv.raidT), lv.level,
                         xloc = xloc.bar_time, color = poolCol, width = lineW, style = line.style_dotted)
                    if labelDetail != "None"
                        lv.lblObj := f_takenAt(takenLbl, takenX, takenUp, f_xClamp(lv.originT), lv.level, pd.nm, pd.isHigh, poolCol)
        if pendIdx.size() > 0
            for k = 0 to pendIdx.size() - 1
                label host = lives.get(pendIdx.get(k)).lblObj
                if not na(host)
                    label.set_text(host, label.get_text(host) + "\n" + pendTxt.get(k))
        f_mergeSame(HIGH_SIDE)
        f_mergeSame(LOW_SIDE)

        // ── Equal highs and lows, innermost column ──────────────────────────
        if showEq and eqPools.size() > 0
            for i = 0 to eqPools.size() - 1
                EqPool p = eqPools.get(i)
                color poolCol = p.isHigh ? buyCol : sellCol
                string nm = (p.isHigh ? "REH" : "REL") + (showTf ? " · " + TF_TAG : "")
                if not p.raided
                    int edge = time + runwayBars * barMs
                    eqLines.push(line.new(f_xClamp(p.startT), p.price, edge, p.price,
                         xloc = xloc.bar_time, color = poolCol, width = 1, style = EQ_STYLE))
                    // Where a named level already sits on the pool's price the pool keeps its LINE and
                    // drops its NAME: same price is a tick question, so it uses the pairing tolerance.
                    if labelDetail != "None" and not f_levelNamed(p.price)
                        eqLabels.push(f_endCap(edge, p.price, labelDetail == "Full" ? nm + "  " + f_price(p.price) : nm, poolCol))
                else if p.raidT > 0
                    eqLines.push(line.new(f_xClamp(p.startT), p.price, f_xClamp(p.raidT), p.price,
                         xloc = xloc.bar_time, color = poolCol, width = 1, style = line.style_dotted))
                    if labelDetail != "None"
                        int nBefore = takenLbl.size()
                        label tl = f_takenAt(takenLbl, takenX, takenUp, f_xClamp(p.startT), p.price, p.isHigh ? "REH" : "REL", p.isHigh, poolCol)
                        // Only a label this pool created is its own to delete next pass.
                        if takenLbl.size() > nBefore
                            eqLabels.push(tl)

    // One pass over the session captions, lowest price first. A caption is left exactly on its own
    // level unless the one below it has already claimed that space, and then it is moved by
    // the smallest amount that clears it and no more.
    if capPx.size() > 1 and labelGapAdr > 0
        float capGap = nz(adr, 0.0) * labelGapAdr
        if capGap > 0
            array<int> byPrice = capPx.sort_indices(order.ascending)
            float lastY = na
            for k = 0 to byPrice.size() - 1
                int j = byPrice.get(k)
                float y = capPx.get(j)
                if not na(lastY) and y - lastY < capGap
                    y := lastY + capGap
                label.set_y(capLbl.get(j), y)
                lastY := y

// == TABLES ==================================================================

//@variable Resolved text size for every cell in the table.
string tblTxt = f_txtSize(tblSizeIn)

//@variable Pool order in the panel: the liquidity levels shortest cycle first, then the sessions.
var array<int> ROW_ORDER = array.from(P_PDH, P_PDL, P_PWH, P_PWL, P_PMH, P_PML, 4, 5, 6, 7, 8, 9)

//@function Appends one row to the panel's pending rows.
//@param nms (array<string>) Row names
//@param vals (array<string>) Row values
//@param tips (array<string>) Row tooltips
//@param nm (string) Name
//@param val (string) Value
//@param tip (string) Tooltip
//@returns (bool) Always true
f_row(array<string> nms, array<string> vals, array<string> tips, string nm, string val, string tip) =>
    nms.push(nm)
    vals.push(val)
    tips.push(tip)
    true

//@variable The table. Rebuilt whenever its row count changes.
var table panel = na
//@variable Rows the current table object was built with.
var int panelRows = na

if barstate.islast and tblMode != "Off"
    bool wide = tblMode == "Long"

    // Every figure below rests on three totals agreeing: the per slot counts with the raid
    // count, the display windows with the same, and raids never above observations.
    bool booksOk = true
    for i = 0 to POOL_TIMED - 1
        PoolStats st = stats.get(i)
        int slotTotal = 0
        for j = 0 to st.firstRaid.size() - 1
            slotTotal += st.firstRaid.get(j)
        int segTotal = 0
        for j = 0 to 6
            segTotal += st.segCnt.get(j)
        if slotTotal != st.raids or segTotal != st.raids or st.raids > st.n
            booksOk := false

    array<string> rName = array.new<string>()
    array<string> rVal  = array.new<string>()
    array<string> rTip  = array.new<string>()

    string srcTxt = archOn ? "5-YEAR ARCHIVE · " + str.tostring(f_archDays(archFam)) + " DAYS" :
         "LOADED HISTORY · " + str.tostring(math.max(daysSeen - 1, 0)) + " DAYS"
    f_row(rName, rVal, rTip, "INSTRUMENT", syminfo.ticker, "")
    f_row(rName, rVal, rTip, "TIMEFRAME", TF_TAG, "")
    f_row(rName, rVal, rTip, "SAMPLE", srcTxt, archOn ? "Five years of one-minute data measured once per product, plus every cycle completed since." :
         "No archive for this symbol or these settings: rates count the loaded history only.")

    // Each pool reads the same live rate its line carries on the chart: of the past cycles still
    // open at this time on the clock, the share that went on to be taken.
    for k = 0 to POOL_TIMED - 1
        int i = ROW_ORDER.get(k)
        PoolDef pd   = defs.get(i)
        PoolStats st = stats.get(i)
        PoolLive lv  = lives.get(i)
        if pd.shown and lv.armed and not na(lv.level)
            int cycleSpan = pd.grid == GRID_MONTH ? 3024000000 : pd.grid == GRID_WEEK ? 604800000 : 86400000
            bool wrapped = not lv.raided and lv.armT > 0 and (time - lv.armT) > cycleSpan
            [went, open2] = f_cond(st, pd.cycStart, f_nowSlot(pd.grid), f_gridLen(pd.grid))
            string valTxt = lv.raided ? (lv.raidT > 0 ? "TAKEN " + f_hhmm(lv.raidT) : "TAKEN") :
                 f_rate(went, open2) + (wrapped ? " *" : "")
            string tip = f_price(lv.level) + "\nAll cycles: raided " + f_rate(st.raids, st.n)
            if not lv.raided
                tip += "\nStill open at this time: went on to be taken " + f_rate(went, open2)
            if st.n < minSample
                tip += "\nUnder " + str.tostring(minSample) + " cycles: a thin sample"
            if lv.far
                tip += "\n" + f_price(math.abs(lv.level - close)) + " from price, line removed"
            else if lv.stale
                tip += "\nUntouched " + str.tostring(int(math.round((time - lv.lastNearT) / 3600000.0))) + "h, line removed"
            if wrapped
                tip += "\n* outlasted one turn of its clock: its live rate is approximate"
            f_row(rName, rVal, rTip, str.upper(pd.nm), valTxt, tip)

    if not tfOk
        f_row(rName, rVal, rTip, "WITHHELD", "NEEDS 30M OR FINER", "The 30 minute grid needs a 30m chart or finer.")
    else if na(adr)
        f_row(rName, rVal, rTip, "DISTANCE GATE", "NO DAILY DATA", "No daily data for ADR " + str.tostring(adrLen) + ".")
    if not booksOk
        f_row(rName, rVal, rTip, "ACCOUNTING", "FAILED", "Slot totals do not reconcile with raid counts.")

    // ── Focus breakdown, Long only ──────────────────────────────────────────
    if wide
        PoolDef fpd   = defs.get(focusPool)
        PoolStats fst = stats.get(focusPool)

        string dowTip = fpd.grid == GRID_DAY ? "Raided / observed, by cycle day" : "Raided / observed, by raid day"
        for d = 0 to 4
            dowTip += "\n" + array.get(DAY_NAMES, d) + "  " + f_rate(fst.dowRaid.get(d), fst.dowObs.get(d))
        f_row(rName, rVal, rTip, "FOCUS", str.upper(fpd.nm) + " · RAIDED " + f_rate(fst.raids, fst.n), dowTip)

        // Share of first raids per window, and the conditional re-read at the window's open,
        // withheld for a weekly or monthly pool whose cycle is longer than a day.
        for s = 0 to 6
            int segFirstSlot = switch s
                0 => 0
                1 => 12
                2 => 26
                3 => 31
                4 => 34
                5 => 39
                => 44
            string val = f_rate(fst.segCnt.get(s), fst.raids)
            string tip = "Share of first raids in this window"
            if fpd.grid == GRID_DAY and fst.n > 0
                [went, open2] = f_cond(fst, fpd.cycStart, segFirstSlot, SLOTS_DAY)
                tip += "\nStill open at " + str.substring(SEG_NAMES.get(s), 0, 5) + ": went on to be taken " + f_rate(went, open2)
            if fst.peakSeg == s and fst.n >= minSample
                val += " · BUSIEST"
            f_row(rName, rVal, rTip, SEG_NAMES.get(s), val, tip)

        if not closeThrough
            f_row(rName, rVal, rTip, "CLOSED BACK INSIDE", f_rate(fst.revInside, fst.raids), "Raid candle closed back on the origin side of the level.")

    int wantRows = 1 + rName.size()
    if na(panel) or panelRows != wantRows
        if not na(panel)
            table.delete(panel)
        panel := table.new(f_pos(panelPosIn), 2, wantRows, bgcolor = chart.bg_color, frame_color = #000000, frame_width = 1, border_width = 0)
        panelRows := wantRows

    table.cell(panel, 0, 0, "RAID CLOCK+", text_color = #000000, text_size = tblTxt,
         text_halign = text.align_left, text_font_family = font.family_monospace,
         tooltip = "Day 18:00 to 18:00 New York.")
    table.cell(panel, 1, 0, "", text_size = tblTxt)
    for k = 0 to rName.size() - 1
        table.cell(panel, 0, k + 1, rName.get(k), text_color = #000000, text_size = tblTxt,
             text_halign = text.align_left, text_font_family = font.family_monospace, tooltip = rTip.get(k))
        table.cell(panel, 1, k + 1, rVal.get(k), text_color = #000000, text_size = tblTxt,
             text_halign = text.align_left, text_font_family = font.family_monospace, tooltip = rTip.get(k))
else if barstate.islast and not na(panel)
    table.delete(panel)
    panel := na
    panelRows := na

// == ALERTS (script scope) ===================================================

bool raidPdh = raidNow.get(0)
bool raidPdl = raidNow.get(1)
bool raidPwh = raidNow.get(2)
bool raidPwl = raidNow.get(3)
bool raidAsh = raidNow.get(4)
bool raidAsl = raidNow.get(5)
bool raidLoh = raidNow.get(6)
bool raidLol = raidNow.get(7)
bool raidNyh = raidNow.get(8)
bool raidNyl = raidNow.get(9)
bool raidPmh = raidNow.get(P_PMH)
bool raidPml = raidNow.get(P_PML)
bool raidPqh = raidNow.get(P_PQH)
bool raidPql = raidNow.get(P_PQL)

alertcondition(raidPdh, "PDH raided",      "M1D: PDH raided at {{time}} on {{ticker}}")
alertcondition(raidPdl, "PDL raided",      "M1D: PDL raided at {{time}} on {{ticker}}")
alertcondition(raidPwh, "PWH raided",      "M1D: PWH raided at {{time}} on {{ticker}}")
alertcondition(raidPwl, "PWL raided",      "M1D: PWL raided at {{time}} on {{ticker}}")
alertcondition(raidAsh, "Asia high raided",   "M1D: the Asia session high was raided at {{time}} on {{ticker}}")
alertcondition(raidAsl, "Asia low raided",    "M1D: the Asia session low was raided at {{time}} on {{ticker}}")
alertcondition(raidLoh, "London high raided", "M1D: the London session high was raided at {{time}} on {{ticker}}")
alertcondition(raidLol, "London low raided",  "M1D: the London session low was raided at {{time}} on {{ticker}}")
alertcondition(raidNyh, "NY high raided",     "M1D: the New York session high was raided at {{time}} on {{ticker}}")
alertcondition(raidNyl, "NY low raided",      "M1D: the New York session low was raided at {{time}} on {{ticker}}")
alertcondition(raidPmh, "PMH raided",      "M1D: PMH raided at {{time}} on {{ticker}}")
alertcondition(raidPml, "PML raided",      "M1D: PML raided at {{time}} on {{ticker}}")
alertcondition(raidPqh, "PQH raided",      "M1D: PQH raided at {{time}} on {{ticker}}")
alertcondition(raidPql, "PQL raided",      "M1D: PQL raided at {{time}} on {{ticker}}")
alertcondition(eqHighTaken, "Equal highs taken", "M1D: relative equal highs taken at {{time}} on {{ticker}}")
alertcondition(eqLowTaken,  "Equal lows taken",  "M1D: relative equal lows taken at {{time}} on {{ticker}}")
alertcondition(peakEntry, "Peak window entered unswept",
     "M1D: a pool still unswept has entered its historically busiest raid window on {{ticker}}")
````
