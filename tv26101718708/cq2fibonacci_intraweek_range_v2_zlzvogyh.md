# CQ_(2)_Fibonacci IntraWeek Range v2

- url: https://www.tradingview.com/script/zlzVoGYH-CQ-2-Fibonacci-IntraWeek-Range-v2/
- type: indicator
- pine_id: PUB;fdf5991ed39c402a93e417ed50055bfe
- version: 1.0

## Description

================================================================================
  CQ FIBONACCI INTRAWEEK RANGE 2 — USER MANUAL
  Based on Fibonacci IntraDay Range [UkutaLabs] — Adapted to Intraweek Targets
  Pine Script v6 | TradingView Overlay Indicator
================================================================================


────────────────────────────────────────────────────────────────────────────────
  OVERVIEW
────────────────────────────────────────────────────────────────────────────────

This indicator is a weekly-timeframe adaptation of the Fibonacci IntraDay Range
system. Instead of projecting intraday price targets from the daily open, it
projects INTRAWEEK Fibonacci targets above and below each week's opening price,
calculated from a rolling average of past weekly high-low ranges.

The indicator is designed for traders who plan their weekly bias and price
targets at the start of each trading week, using historical average weekly
range as the statistical basis for target placement.

Key differences from the IntraDay version:
  - Reference period: WEEKLY open instead of daily open
  - Range calculation: average weekly high-low ranges (default: 4 weeks)
  - Session trigger: first bar of each new week instead of each new day
  - Gauge label: "WEEK" instead of "DAY"
  - Weekly open baseline label: "⨁W" instead of "⨁D"
  - Default horizontal offset: 45 bars (wider, suits higher timeframes)
  - Default circle size: Tiny (cleaner on higher timeframes)
  - Default level colors: amber/orange (rgb 182, 109, 0) vs blue
  - Display Mode options: This Week / Two Weeks / Month / All
  - Timeframe guard: hidden on Monthly only (Weekly charts ARE allowed)

Timeframe availability:
  Allowed:   Intraday (1m – 4H), Daily, Weekly
  Hidden:    Monthly and above


────────────────────────────────────────────────────────────────────────────────
  HOW IT WORKS — CONCEPTUAL SUMMARY
────────────────────────────────────────────────────────────────────────────────

Step 1 — Weekly range accumulation:
  Each week's high-low range is tracked as the week progresses. On the first
  bar of each new week, the completed prior week's range (weekHigh - weekLow)
  is added to a rolling array. The oldest entry is dropped once the array
  exceeds the "Weeks to Average Range" setting. The array average becomes
  the "averageRange" for the new week.

Step 2 — Level projection:
  Using the current week's opening price as the baseline, Fibonacci percentage
  levels are projected both above and below:

    levelAbove = weeklyOpen + averageRange × (Fib% ÷ 100)
    levelBelow = weeklyOpen − averageRange × (Fib% ÷ 100)

  Available levels: 15%, 25%, 40%, 50%, 60%, 75%, 100%, 125%, 150%, 175%, 200%
  The 100% level represents a full average-range move — the primary weekly target.

Step 3 — Drawing objects created at week open:
  At the first bar of each week, all lines, label boxes, and circle markers
  are created and stored inside an IntraWeekRange object. Every subsequent bar
  extends the right edge of all lines and label boxes forward in real time.

Step 4 — Session cleanup:
  When Display Mode limits how many weeks are visible, the oldest
  IntraWeekRange object is deleted (all drawing objects removed) when the
  collection exceeds the maximum.

Step 5 — Gauge update:
  On every bar, the intraweek gauge is repositioned to the right edge of the
  chart, showing current price position relative to the weekly open, high,
  and low in real time.


────────────────────────────────────────────────────────────────────────────────
  ALGORITHM — DETAILED STEP-BY-STEP
────────────────────────────────────────────────────────────────────────────────

══════════════════════════════════════════════════════════════════════════════
  PROCESS 1: WEEKLY DATA RETRIEVAL
══════════════════════════════════════════════════════════════════════════════

The indicator requests weekly OHLC data using request.security() with
lookahead_on, ensuring that the weekly open, high, low, and close values are
available on every intraday, daily, or weekly bar:

  weekly_open  — opening price of the current week's candle
  weekly_high  — running high of the current week
  weekly_low   — running low of the current week
  weekly_close — most recent close (equivalent to current price intraweek)

These values feed both the gauge display and the profit/loss label.

══════════════════════════════════════════════════════════════════════════════
  PROCESS 2: AVERAGE WEEKLY RANGE CALCULATION
══════════════════════════════════════════════════════════════════════════════

Variables:
  weekRanges    — rolling float array of completed weekly ranges
  weekHigh      — running high of the current week (tracked bar by bar)
  weekLow       — running low of the current week (tracked bar by bar)
  averageRange  — average of all entries in weekRanges
  weeks         — user-defined window size (default: 4)

Logic per bar:

  Trigger: isFirstBarOfWeek = timeframe.change("W")
  This fires on the first bar where the weekly timeframe changes — i.e., the
  Monday open bar (or the first bar of a new week on any timeframe).

  On isFirstBarOfWeek:
    1. Compute completed prior week's range: weekHigh - weekLow
       Push this value into weekRanges.
    2. Reset weekHigh = high (current bar's high) and weekLow = low.
    3. If weekRanges.size() > weeks, shift out the oldest entry.
    4. Recalculate averageRange = array.avg(weekRanges).

  On every bar (including non-week-open bars):
    weekHigh := high > weekHigh ? high : weekHigh
    weekLow  := low  < weekLow  ? low  : weekLow
  This continuously tracks the current week's expanding range.

  Note: On the very first bar of history, weekHigh and weekLow are na.
  The first completed range entered into weekRanges will be 0 (na - na = na,
  handled gracefully by array.avg). The averageRange stabilizes after the
  first full week of data.

══════════════════════════════════════════════════════════════════════════════
  PROCESS 3: INTRAWEEK TENDENCY GAUGE
══════════════════════════════════════════════════════════════════════════════

Purpose: Real-time vertical gauge at the right edge showing where price sits
within the current week's range relative to the weekly open.

Trigger: Runs on every bar when Intraweek_gauge_draw = true and tfAllowed.

Structure (two halves, anchored at weekly_open):

  BULLISH HALF (upper, green by default):
    Gauge_box_scope   — background box from weekly_open to weekly_high
                        Labeled "WEEK" at top. Dotted border.
    Gauge_line_max    — horizontal line at weekly_high (foreground color)
    Gauge_line_min    — horizontal line at weekly_open (background color)
    Gauge_box_prc     — filled box from weekly_open to close
                        Fill color = bullish color if close >= weekly_open
    Gauge_line_prc    — horizontal line at current close
    gauge_high_label  — price label above the weekly high: "$X,XXX"
    gauge_open_marker — short horizontal line at weekly_open level: "◀"
    gauge_open_label  — arrow label pointing left at weekly_open

  BEARISH HALF (lower, amber by default):
    Gauge_box_scope2  — background box from weekly_low to weekly_open
                        Labeled "WEEK" at bottom. Dotted border.
    Gauge_line_max2   — horizontal line at weekly_open
    Gauge_line_min2   — horizontal line at weekly_low (foreground color)
    Gauge_box_prc2    — filled box from close to weekly_open
                        Fill = bearish color if close < weekly_open
    Gauge_line_prc2   — horizontal line at current close
    gauge_low_label   — price label below the weekly low: "$X,XXX"

  PROFIT/LOSS LABEL (to the right of the gauge):
    profit_loss_label — shows dollar gain/loss from weekly open
    Position: bar_index + gauge_offset + 6 (6 bars right of gauge edge)
    Text: rounded dollar difference (close - weekly_open), formatted "$#,000"
    Color: bullish color (teal) if above open, bearish color (amber) if below
    Tooltip: percentage move + dollar amount + "from Weekly Opening: $X,XXX"

  Position calculation:
    gauge_offset = lines_offset - 6
    All gauge elements use: bar_index + gauge_offset ± 1 or 2
    This places the gauge just inside the label extension zone.

  Dynamic updates (every bar):
    All box corners, line endpoints, and label positions are updated using
    the set_ methods, so the gauge tracks price in real time without creating
    new objects.

══════════════════════════════════════════════════════════════════════════════
  PROCESS 4: DRAWING THE FIBONACCI LEVELS (drawLines function)
══════════════════════════════════════════════════════════════════════════════

Called every bar. Only creates new drawing objects when isFirstBarOfWeek is
true, displayMode is not "Hidden", and tfAllowed is true.

─── WEEK-OPEN TRIGGER ──────────────────────────────────────────────────────

A new IntraWeekRange object is created with three empty arrays:
  lines   — array<line>  for all Fibonacci level lines
  labels  — array<box>   for all text label boxes
  circles — array<label> for all circle dot markers

─── WEEKLY OPEN BASELINE ───────────────────────────────────────────────────

A dotted line is drawn at the opening price of the new week:
  line.new(x1=bar_index, y1=open, x2=bar_index, y2=open,
           color=HighLight, width=lineWidth, style=line.style_dotted)

Note: x1 = x2 = bar_index at creation. The line is extended by extendLines()
on every subsequent bar.

If showCircles:
  A "●" label is placed one bar to the left of the open at the open price,
  colored with HighLight.

If showLabels:
  A box label "⨁W    $X,XXX" is placed at the open price.
  ⨁W signals this is the weekly open baseline.

─── FIBONACCI LEVEL LOOP (i = 0 to 10) ────────────────────────────────────

For each of the 11 levels, if fibEnabled.get(i) is true:

  Compute:
    levelAbove = open + (averageRange × fibMultis.get(i) / 100)
    levelBelow = open − (averageRange × fibMultis.get(i) / 100)

  Line color selection:
    i == 6 (100% level): uses HighLight color (full opacity, accent)
    all others: uses color.new(colors.get(i), 45) (45% transparent)

  Circle color: always HighLight (amber) — identical above and below.
  Note: This differs from the IntraDay version where circles used the
  individual level color. Here ALL circles use the unified HighLight color.

  For levelAbove:
    Push a line (style per lineStyle setting) into newIWR.lines.
    If showCircles: push a "●" label at bar_index - 1 into newIWR.circles.

  For levelBelow:
    Push a line (same style) into newIWR.lines.
    If showCircles: push a "●" label at bar_index - 1 into newIWR.circles.

  If showLabels (independent check after the fib loop body):
    For levelAbove: push a box with text:
      i == 6: "▼+100%    $X,XXX"  (special highlight format)
      others: "+X%    $X,XXX"
      text_valign: text.align_bottom (label sits above the line)
      text_color: HighLight for i==6, NormalColor for others

    For levelBelow: push a box with text:
      i == 6: "▲-100%    $X,XXX"  (special highlight format)
      others: "-X%    $X,XXX"
      text_valign: text.align_top (label sits below the line)
      text_color: HighLight for i==6, NormalColor for others

  After loop: push newIWR into collection array.

─── LINE EXTENSION (every bar after week open) ─────────────────────────────

If newIWR is not na (i.e., this week's object was created at some point):
  Call newIWR.extendLines():
    For each line: set_x2(bar_index + lines_offset)
    For each box label: set_right(bar_index + lines_offset)

This extends every active line and label to stay current_bar + offset bars
ahead of the most recent bar on every tick.

─── COLLECTION CLEANUP ─────────────────────────────────────────────────────

  maxWeeks:
    "This Week"  → 1
    "Two Weeks"  → 2
    "Month"      → 4
    "All"        → 999

  If collection.size() > maxWeeks and displayMode != "All":
    Call deleteLines() on collection.get(0):
      Delete all lines, box labels, and circle labels in the oldest object.
    Shift the oldest object out of the collection array.


────────────────────────────────────────────────────────────────────────────────
  DATA STRUCTURES
────────────────────────────────────────────────────────────────────────────────

  type IntraWeekRange
    array<line>  lines    — all Fibonacci level lines for this week
    array<box>   labels   — all text label boxes for this week
    array<label> circles  — all circle dot markers for this week

  method extendLines(IntraWeekRange this)
    Extends all lines to bar_index + lines_offset.
    Extends all label boxes' right edge to bar_index + lines_offset.
    Only runs if showLabels is true for label extension.

  method deleteLines(IntraWeekRange this)
    Deletes every line and label box (if showLabels).
    Deletes every circle label.
    Called when a week scrolls out of the visible collection window.

  Global arrays:
    collection  — array<IntraWeekRange> — all active week objects
    weekRanges  — array<float>          — rolling weekly range history
    fibMultis   — [15,25,40,50,60,75,100,125,150,175,200] (fixed at init)
    colors      — array of 11 user-defined level colors (fixed at init)
    fibEnabled  — array of 11 user-defined boolean toggles (fixed at init)


────────────────────────────────────────────────────────────────────────────────
  SETTINGS REFERENCE
────────────────────────────────────────────────────────────────────────────────

── CONFIGURATION ───────────────────────────────────────────────────────────────

  Display Mode
    Controls how many weeks of Fibonacci levels are drawn simultaneously.
      Hidden      — disables all drawing (gauge still runs)
      This Week   — current week only (default)
      Two Weeks   — current and previous week
      Month       — last 4 weeks
      All         — every week on the chart (no cleanup)

── AVERAGE RANGE SETTINGS ──────────────────────────────────────────────────────

  Weeks to Average Range
    Number of past completed weeks used to compute the average weekly range.
    Default: 4 weeks (roughly one month of data).
    Lower values (1–2): reactive to recent volatility, suited for volatile
    markets or around major macro events.
    Higher values (8–12): smoothed historical norm, better for stable markets.

── LABEL SETTINGS ──────────────────────────────────────────────────────────────

  Show Labels
    Toggles all text boxes showing percentage and dollar value at each level.
    Default: On

  Font Size
    Options: Tiny / Small / Medium / Large
    Default: Small

  Text Alignment
    Options: Left / Center / Right
    Alignment of text within each label box.
    Default: Right

  Position (Horizontal Offset)
    Range: 0 – 100 bars.
    How far right lines and labels extend from the current bar.
    Default: 45 (wider than the intraday version to suit daily/weekly charts).
    The gauge position is derived as: offset − 6 bars.

── LINE SETTINGS ───────────────────────────────────────────────────────────────

  Line Width
    Pixel thickness of all Fibonacci level lines.
    Default: 1

  Line Style
    Options: Solid / Dashed / Dotted
    Default: Solid

── CIRCLE SETTINGS ─────────────────────────────────────────────────────────────

  Show Circles at Line Start
    Places a "●" dot marker at the left origin (week open bar) of each line.
    All circles use the HighLight color regardless of level.
    Default: On

  Circle Size
    Options: Tiny / Small / Normal / Large
    Default: Tiny (smaller than intraday version for cleaner higher-TF display)

── FIBONACCI LEVELS ────────────────────────────────────────────────────────────

  Each level has an individual color picker and an enable/disable toggle.
  All 11 levels share the same default color: rgb(182, 109, 0) (amber/brown).

  Level    %       Default   Notes
  -------  ------  --------  ---------------------------------------------------
  0        15%     On        Minor weekly support / resistance
  1        25%     On        Quarter-range pivot
  2        40%     On        Below midpoint inflection
  3        50%     On        Midpoint — half the average weekly range
  4        60%     On        Above midpoint inflection
  5        75%     On        Three-quarter range target
  6        100%    On        Full average range — rendered in HighLight color
  7        125%    Off       Extended weekly move
  8        150%    Off       Extended weekly move
  9        175%    Off       Extreme extension
  10       200%    Off       Double-range extreme

  Highlighted Items Color (NormalColor)
    Color for non-100% level label text.
    Default: rgb(192, 115, 0) — slightly brighter amber.

  Highlighted Items Color (HighLight)
    Color for the 100% level line and labels, the weekly open baseline line,
    and ALL circle markers.
    Default: rgb(255, 176, 58) — bright amber/gold.

  Note: Both color inputs share the same title "Highlighted Items Color" in
  the settings panel. NormalColor appears first, HighLight second.

── GAUGE SETTINGS ──────────────────────────────────────────────────────────────

  Draw Intraweek Price Tendency Gauge
    Enables/disables the vertical gauge at the right chart edge.
    Default: On

  Gauge Background (Bullish)
    Color of the upper (bullish) half box from weekly_open to weekly_high.
    Default: Dark green rgb(0, 83, 75).

  Foreground (Bullish)
    Fill bar and weekly high label color when close >= weekly_open.
    Default: Bright teal rgb(0, 194, 174).

  Gauge Background (Bearish)
    Color of the lower (bearish) half box from weekly_low to weekly_open.
    Default: Dark amber rgb(85, 48, 0).

  Foreground (Bearish)
    Fill bar and weekly low label color when close < weekly_open.
    Default: Orange rgb(255, 153, 0).


────────────────────────────────────────────────────────────────────────────────
  COMPARISON: INTRADAY vs INTRAWEEK VERSION
────────────────────────────────────────────────────────────────────────────────

  Feature                   IntraDay Version       IntraWeek Version
  ────────────────────────  ─────────────────────  ─────────────────────────
  Reference period          Daily open             Weekly open
  Range calculation         Daily H-L average      Weekly H-L average
  Default averaging window  1 day                  4 weeks
  Session trigger           session.isfirstbar     timeframe.change("W")
  Baseline label            ⨁D                    ⨁W
  Gauge label               DAY                    WEEK
  Security timeframe        'D' (daily)            'W' (weekly)
  Timeframe guard           Hides on W and M       Hides on M only
  Default offset            32 bars                45 bars
  Default circle size       Small                  Tiny
  Default level colors      Blue rgb(153,198,253)  Amber rgb(182,109,0)
  Circle color              HighLight              HighLight (all circles)
  Display mode options      Today/Two Days/Week/All This Week/Two Weeks/Month/All
  Current price label       Yes (intraday ≤ 4H)    No
  Class name                IntraDayRange          IntraWeekRange


────────────────────────────────────────────────────────────────────────────────
  PRACTICAL USAGE GUIDE
────────────────────────────────────────────────────────────────────────────────

Best timeframes for this indicator:
  Daily chart    — primary use case; shows weekly levels cleanly across
                   multiple days, allowing easy identification of which
                   Fibonacci level each day's session is targeting.
  4H chart       — good for swing traders monitoring intraweek progression.
  1H chart       — fine for active traders during the week, but may become
                   crowded with the gauge and labels.
  Weekly chart   — levels draw once per bar; useful for multi-week comparison
                   when Display Mode is set to "Two Weeks" or "Month".

Setting the averaging window:
  4 weeks (default) — balanced, one month of recent weekly behavior.
  1 week            — uses only last week's range; highly reactive, good for
                      earnings weeks or high-volatility environments.
  8–12 weeks        — long-term average, more stable targets, suited for
                      instruments with consistent weekly ranges.

Reading the gauge:
  The gauge provides instant visual feedback on the week's progress:
  - The bullish (teal) half shows how far price has moved above the weekly open
    toward the weekly high.
  - The bearish (amber) half shows how far price has dropped below the weekly
    open toward the weekly low.
  - The profit/loss label shows the current week's running P&L from Monday's
    open. Hover over it for the percentage return tooltip.

Using the 50% and 100% levels:
  The 50% level marks the midpoint of an average weekly range. Price reaching
  the 50% level by Wednesday is considered a normal weekly pace. The 100%
  level marks a full average-range move and is the primary weekly target in
  both directions. Levels above 100% signal an unusually strong trending week.

Display Mode recommendations:
  "This Week"  — cleanest view; focus on current week only.
  "Two Weeks"  — compare current week context against last week's structure.
  "Month"      — map the full month; useful for identifying clusters of levels
                 where multiple weeks share similar Fibonacci targets.

Reducing clutter:
  On intraday timeframes, the levels from a full-week projection can span a
  large price area. Disabling the 125%–200% levels and reducing the offset
  to 20–25 bars keeps the chart readable. On the daily chart, the default
  45-bar offset works well.


────────────────────────────────────────────────────────────────────────────────
  QUICK REFERENCE — DEFAULT SETTINGS
────────────────────────────────────────────────────────────────────────────────

  Display Mode              This Week
  Weeks to Average Range    4
  Show Labels               On
  Font Size                 Small
  Text Alignment            Right
  Horizontal Offset         45
  Line Width                1
  Line Style                Solid
  Show Circles              On
  Circle Size               Tiny
  Active Fib Levels         15%, 25%, 40%, 50%, 60%, 75%, 100%
  Level Colors              Amber rgb(182, 109, 0)
  HighLight Color           Gold  rgb(255, 176, 58)
  Normal Label Color        Amber rgb(192, 115, 0)
  Gauge                     On
  Gauge Bullish BG          Dark green rgb(0, 83, 75)
  Gauge Bullish FG          Teal rgb(0, 194, 174)
  Gauge Bearish BG          Dark amber rgb(85, 48, 0)
  Gauge Bearish FG          Orange rgb(255, 153, 0)


────────────────────────────────────────────────────────────────────────────────
  LIMITATIONS AND NOTES
────────────────────────────────────────────────────────────────────────────────

  - The indicator has no current price label. Unlike the IntraDay version,
    there is no live floating price box on this script.

  - averageRange is na on the first bar of history (before any week has
    completed). Fibonacci levels will not draw correctly until at least one
    full week of data is available.

  - On the Weekly timeframe, isFirstBarOfWeek fires on every bar (since each
    bar is itself a new week). This means all levels are redrawn every bar.
    Use the daily or intraday timeframes for the intended visual behavior.

  - The colors and fibEnabled arrays are initialized once at indicator load
    using the var keyword. Changing level color or enable settings mid-session
    may require a full indicator reload to take effect.

  - All past week objects remain on the chart within the Display Mode limit.
    Switching from "This Week" to "Month" will not retroactively add past weeks
    that were already deleted — it takes effect at the next week boundary.

  - Indicator drawing limits:
      max_lines_count  = 500
      max_boxes_count  = 500
      max_labels_count = 500
    On "All" mode with many weeks of history, these limits may be reached.
    Use "Month" (4 weeks) for practical long-term use.


================================================================================
  END OF MANUAL
================================================================================

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Based on "Fibonacci IntraDay Range [UkutaLabs]" — adapted to INTRAWEEK targets
// Modified: Circle markers at start of each Fibonacci level line using HighLight color     
//@version=6
indicator("CQ_(2)_Fibonacci IntraWeek Range v2", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ── Timeframe guard ───────────────────────────────────────────────────────────
// Hide the entire indicator on Monthly or any TF ≥ 1 month.
// Allowed on: intraday (1m…4H), daily, and weekly.
bool tfAllowed = not timeframe.ismonthly

//--------------
// USER VARIABLES
//--------------
string displayMode  = input.string(defval="This Week", title="Display Mode",
     options=["Hidden", "This Week", "Two Weeks", "Month", "All"], group="Configuration")

int weeks           = input.int(defval=4, title="Weeks to Average Range", group="Average Range Settings")

bool showLabels     = input.bool(defval=true, title="Show Labels", group="Label Settings")
string fontSize     = input.string(defval="Small", title="Font Size",
     options=["Tiny", "Small", "Medium", "Large"], group="Label Settings")
string textAlign    = input.string(defval="Right", title="Text Alignment",
     options=["Left", "Center", "Right"], group="Label Settings")
var lines_offset    = input.int(defval=45, minval=0, maxval=100,
     title='Position (Horizontal Offset)', group="Label Settings")

int lineWidth       = input(defval=1, title="Line Width", group="Line Settings")
string lineStyle    = input.string(defval="Solid", title="Line Style",
     options=["Dashed","Solid","Dotted"], group="Line Settings")

bool showCircles    = input.bool(defval=true, title="Show Circles at Line Start", group="Circle Settings")
string circleSize   = input.string(defval="Tiny", title="Circle Size",
     options=["Tiny", "Small", "Normal", "Large"], group="Circle Settings")

color LevelColor0   = input.color(defval=color.rgb(182, 109, 0), title="Line Color", group="Fibonacci Levels", inline="0")
bool showLevel0     = input.bool(defval=true,  title="Enable (15%)",   group="Fibonacci Levels", inline="0")
color LevelColor1   = input.color(defval=color.rgb(182, 109, 0), title="Line Color", group="Fibonacci Levels", inline="1")
bool showLevel1     = input.bool(defval=true,  title="Enable (25%)",   group="Fibonacci Levels", inline="1")
color LevelColor2   = input.color(defval=color.rgb(182, 109, 0), title="Line Color", group="Fibonacci Levels", inline="2")
bool showLevel2     = input.bool(defval=true,  title="Enable (40%)",   group="Fibonacci Levels", inline="2")
color LevelColor3   = input.color(defval=color.rgb(182, 109, 0), title="Line Color", group="Fibonacci Levels", inline="3")
bool showLevel3     = input.bool(defval=true,  title="Enable (50%)",   group="Fibonacci Levels", inline="3")
color LevelColor4   = input.color(defval=color.rgb(182, 109, 0), title="Line Color", group="Fibonacci Levels", inline="4")
bool showLevel4     = input.bool(defval=true,  title="Enable (60%)",   group="Fibonacci Levels", inline="4")
color LevelColor5   = input.color(defval=color.rgb(182, 109, 0), title="Line Color", group="Fibonacci Levels", inline="5")
bool showLevel5     = input.bool(defval=true,  title="Enable (75%)",   group="Fibonacci Levels", inline="5")
color LevelColor6   = input.color(defval=color.rgb(182, 109, 0), title="Line Color", group="Fibonacci Levels", inline="6")
bool showLevel6     = input.bool(defval=true,  title="Enable (100%)",  group="Fibonacci Levels", inline="6")
color LevelColor7   = input.color(defval=color.rgb(182, 109, 0), title="Line Color", group="Fibonacci Levels", inline="7")
bool showLevel7     = input.bool(defval=false, title="Enable (125%)",  group="Fibonacci Levels", inline="7")
color LevelColor8   = input.color(defval=color.rgb(182, 109, 0), title="Line Color", group="Fibonacci Levels", inline="8")
bool showLevel8     = input.bool(defval=false, title="Enable (150%)",  group="Fibonacci Levels", inline="8")
color LevelColor9   = input.color(defval=color.rgb(182, 109, 0), title="Line Color", group="Fibonacci Levels", inline="9")
bool showLevel9     = input.bool(defval=false, title="Enable (175%)",  group="Fibonacci Levels", inline="9")
color LevelColor10  = input.color(defval=color.rgb(182, 109, 0), title="Line Color", group="Fibonacci Levels", inline="10")
bool showLevel10    = input.bool(defval=false, title="Enable (200%)",  group="Fibonacci Levels", inline="10")

color NormalColor   = input.color(defval=color.rgb(192, 115, 0),  title="Highlighted Items Color", group="Fibonacci Levels")
color HighLight     = input.color(defval=color.rgb(255, 176, 58),  title="Highlighted Items Color", group="Fibonacci Levels")

// ── GAUGE ─────────────────────────────────────────────────────────────────────
Intraweek_gauge_draw = input.bool(true, 'Draw INTRAWEEK Price Tendency Gauge', inline='retlg', group='Gauge')
gauge_bullish_color  = input.color(color.rgb(0, 83, 75),   title='    Gauge Background (Bullish)', inline='Bullish')
gauge_bullish_color2 = input.color(color.rgb(0, 194, 174), title='    Foreground',                 inline='Bullish')
gauge_bearish_color  = input.color(color.rgb(85, 48, 0),   title='    Gauge Background (Bearish)', inline='Bearish')
gauge_bearish_color2 = input.color(color.rgb(255, 153, 0), title='    Foreground',                 inline='Bearish')

gauge_offset = lines_offset - 6

//--------------
// WEEKLY SECURITY DATA
//--------------
weekly_open  = request.security(syminfo.tickerid, 'W', open,  lookahead=barmerge.lookahead_on)
weekly_high  = request.security(syminfo.tickerid, 'W', high,  lookahead=barmerge.lookahead_on)
weekly_low   = request.security(syminfo.tickerid, 'W', low,   lookahead=barmerge.lookahead_on)
weekly_close = request.security(syminfo.tickerid, 'W', close, lookahead=barmerge.lookahead_on)

// ── INTRAWEEK TENDENCY GAUGE (only when tfAllowed) ────────────────────────────
GWOcolor      = close >= weekly_open
Gweekly_color = GWOcolor ? gauge_bullish_color2 : gauge_bearish_color2

if Intraweek_gauge_draw and tfAllowed

    var Gauge_box_scope  = box.new(bar_index, close, bar_index, weekly_open,
         border_color=color.new(gauge_bullish_color, 0),
         border_width=1, border_style=line.style_dotted,
         text='WEEK', text_valign=text.align_top, text_size=size.tiny,
         text_color=color.white, bgcolor=color.new(gauge_bullish_color, 50))
    var Gauge_line_max  = line.new(bar_index, close, bar_index, weekly_open,
         color=gauge_bullish_color2, width=2)
    var Gauge_line_min  = line.new(bar_index, close, bar_index, weekly_open,
         color=gauge_bullish_color, width=3)
    var Gauge_box_prc   = box.new(bar_index, close, bar_index, weekly_open,
         border_color=color.new(gauge_bullish_color, 50), border_width=1,
         bgcolor=color.new(Gweekly_color, 80))
    var Gauge_line_prc  = line.new(bar_index, close, bar_index, weekly_open,
         color=gauge_bullish_color, width=4)

    var label gauge_high_label = label.new(bar_index, weekly_high,
         text=str.tostring(math.round(weekly_high, 0), '$0,000'),
         style=label.style_label_down,
         color=color.new(gauge_bullish_color, 80),
         textcolor=gauge_bullish_color2, size=size.small)

    var line gauge_open_marker = line.new(
         x1=bar_index + gauge_offset - 2, y1=weekly_open,
         x2=bar_index + gauge_offset + 1, y2=weekly_open,
         color=color.white, width=3, style=line.style_solid)
    var label gauge_open_label = label.new(bar_index, weekly_open,
         text="◀", style=label.style_label_left,
         color=color.new(color.black, 100), textcolor=color.white, size=size.tiny)

    box.set_lefttop    (Gauge_box_scope, bar_index + gauge_offset - 2, weekly_high)
    box.set_rightbottom(Gauge_box_scope, bar_index + gauge_offset + 1, weekly_open)
    line.set_xy1(Gauge_line_max, bar_index + gauge_offset - 2, weekly_high)
    line.set_xy2(Gauge_line_max, bar_index + gauge_offset + 1, weekly_high)
    line.set_xy1(Gauge_line_min, bar_index + gauge_offset - 2, weekly_open)
    line.set_xy2(Gauge_line_min, bar_index + gauge_offset + 1, weekly_open)
    box.set_lefttop    (Gauge_box_prc, bar_index + gauge_offset - 1, close)
    box.set_rightbottom(Gauge_box_prc, bar_index + gauge_offset,     weekly_open)
    box.set_bgcolor    (Gauge_box_prc, color.new(Gweekly_color, 80))
    box.set_border_color(Gauge_box_prc, color.new(Gweekly_color, 50))
    line.set_xy1(Gauge_line_prc, bar_index + gauge_offset - 1, close)
    line.set_xy2(Gauge_line_prc, bar_index + gauge_offset,     close)
    line.set_color(Gauge_line_prc, gauge_bullish_color)
    label.set_xy  (gauge_high_label, bar_index + gauge_offset - 1, weekly_high)
    label.set_text(gauge_high_label, str.tostring(math.round(weekly_high, 0), '$0,000'))
    line.set_xy1(gauge_open_marker, bar_index + gauge_offset - 2, weekly_open)
    line.set_xy2(gauge_open_marker, bar_index + gauge_offset + 1, weekly_open)
    label.set_xy  (gauge_open_label, bar_index + gauge_offset, weekly_open)
    label.set_text(gauge_open_label, "◀")

    var Gauge_box_scope2 = box.new(bar_index, close, bar_index, weekly_open,
         border_color=color.new(gauge_bearish_color, 0),
         border_width=1, border_style=line.style_dotted,
         text='WEEK', text_valign=text.align_bottom, text_size=size.tiny,
         text_color=color.white, bgcolor=color.new(gauge_bearish_color, 50))
    var Gauge_line_max2 = line.new(bar_index, close, bar_index, weekly_open,
         color=gauge_bullish_color, width=3)
    var Gauge_line_min2 = line.new(bar_index, close, bar_index, weekly_open,
         color=gauge_bearish_color2, width=2)
    var Gauge_box_prc2  = box.new(bar_index, close, bar_index, weekly_open,
         border_color=color.new(gauge_bullish_color, 50), border_width=1,
         bgcolor=color.new(Gweekly_color, 80))
    var Gauge_line_prc2 = line.new(bar_index, close, bar_index, weekly_open,
         color=Gweekly_color, width=4)

    var label gauge_low_label = label.new(bar_index, weekly_low,
         text=str.tostring(math.round(weekly_low, 0), '$0,000'),
         style=label.style_label_up,
         color=color.new(gauge_bearish_color, 80),
         textcolor=gauge_bearish_color2, size=size.small)

    box.set_lefttop    (Gauge_box_scope2, bar_index + gauge_offset - 2, weekly_open)
    box.set_rightbottom(Gauge_box_scope2, bar_index + gauge_offset + 1, weekly_low)
    line.set_xy1(Gauge_line_max2, bar_index + gauge_offset - 2, weekly_open)
    line.set_xy2(Gauge_line_max2, bar_index + gauge_offset + 1, weekly_open)
    line.set_xy1(Gauge_line_min2, bar_index + gauge_offset - 2, weekly_low)
    line.set_xy2(Gauge_line_min2, bar_index + gauge_offset + 1, weekly_low)
    box.set_lefttop    (Gauge_box_prc2, bar_index + gauge_offset - 1, close)
    box.set_rightbottom(Gauge_box_prc2, bar_index + gauge_offset,     weekly_open)
    box.set_bgcolor    (Gauge_box_prc2, color.new(Gweekly_color, 80))
    box.set_border_color(Gauge_box_prc2, color.new(Gweekly_color, 50))
    line.set_xy1(Gauge_line_prc2, bar_index + gauge_offset - 1, close)
    line.set_xy2(Gauge_line_prc2, bar_index + gauge_offset,     close)
    line.set_color(Gauge_line_prc2, gauge_bullish_color)
    label.set_xy  (gauge_low_label, bar_index + gauge_offset - 1, weekly_low)
    label.set_text(gauge_low_label, str.tostring(math.round(weekly_low, 0), '$0,000'))

    var y_adjust = 1
    y_adjust := close - weekly_open < 0 ? -1 : 1
    var profit_loss_label = label.new(bar_index, close,
         str.tostring(math.round(close - weekly_open, 0), '$#,000'))
    label.set_xy     (profit_loss_label, bar_index + gauge_offset + 6, close + y_adjust)
    label.set_text   (profit_loss_label, str.tostring(math.round(close - weekly_open, 0), '$#,000'))
    label.set_tooltip(profit_loss_label,
         str.tostring(((close - weekly_open) / weekly_open) * 100, format.percent) + ' ' +
         str.tostring(math.round(close - weekly_open, 0), '$#,000') +
         ' from Weekly Opening: ' + str.tostring(math.round(weekly_open, 0), '$#,000'))
    label.set_color   (profit_loss_label, color.new(Gweekly_color, 100))
    label.set_textcolor(profit_loss_label, color.new(Gweekly_color, 0))
    label.set_size    (profit_loss_label, size.small)
    label.set_style   (profit_loss_label, label.style_label_right)
    label.set_textalign(profit_loss_label, text.align_left)

//--------------
// CLASSES
//--------------
type IntraWeekRange
    array<line>  lines
    array<box>   labels
    array<label> circles

method extendLines(IntraWeekRange this) =>
    if not na(this)
        for i = 0 to this.lines.size() - 1
            this.lines.get(i).set_x2(bar_index + lines_offset)
            if showLabels
                this.labels.get(i).set_right(bar_index + lines_offset)

method deleteLines(IntraWeekRange this) =>
    if not na(this)
        for i = 0 to this.lines.size() - 1
            this.lines.get(i).delete()
            if showLabels
                this.labels.get(i).delete()
        for i = 0 to this.circles.size() - 1
            this.circles.get(i).delete()

//--------------
// HELPER: resolve circle size string → Pine size constant
//--------------
f_circleSize(string s) =>
      s == "Tiny"   ? size.tiny   :
      s == "Small"  ? size.small  :
      s == "Normal" ? size.normal : size.large

//--------------
// VARIABLES
//--------------
var collection         = array.new<IntraWeekRange>(0)
var weekRanges         = array.new<float>(0)
var float averageRange = na
var float weekHigh     = na
var float weekLow      = na
var int   tfp          = timeframe.isintraday and not timeframe.isseconds ? int(str.tonumber(timeframe.period)) : 0

var fibMultis  = array.from(15, 25, 40, 50, 60, 75, 100, 125, 150, 175, 200)
var colors     = array.from(LevelColor0, LevelColor1, LevelColor2, LevelColor3, LevelColor4,
     LevelColor5, LevelColor6, LevelColor7, LevelColor8, LevelColor9, LevelColor10)
var fibEnabled = array.from(showLevel0, showLevel1, showLevel2, showLevel3, showLevel4,
     showLevel5, showLevel6, showLevel7, showLevel8, showLevel9, showLevel10)

isFirstBarOfWeek = timeframe.change("W")

//--------------
// DRAW FUNCTION
//--------------
drawLines(array<IntraWeekRange> collection, float averageRange, int tfp) =>
    var IntraWeekRange newIWR = na

    if isFirstBarOfWeek and displayMode != "Hidden" and tfAllowed
        newIWR := IntraWeekRange.new(
             lines   = array.new<line>(0),
             labels  = array.new<box>(0),
             circles = array.new<label>(0))

        // ── Weekly open baseline ──────────────────────────────────────────────
        newIWR.lines.push(line.new(
             x1=bar_index, y1=open, x2=bar_index, y2=open,
             color=HighLight, width=lineWidth, style=line.style_dotted))

        if showCircles
            newIWR.circles.push(label.new(
                 x=bar_index - 1, y=open, text="●",
                 style=label.style_label_center,
                 color=color.new(color.black, 100),
                 size=f_circleSize(circleSize), textcolor=HighLight))

        if showLabels
            newIWR.labels.push(box.new(
                 left=bar_index, top=open + 1, right=bar_index, bottom=open,
                 bgcolor=HighLight, border_color=na,
                 text="⨁W    $" + str.tostring(open, '0,000'),
                 text_color=HighLight,
                 text_valign=text.align_center,
                 text_halign=textAlign == "Left" ? text.align_left : textAlign == "Center" ? text.align_center : text.align_right,
                 text_size=fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large))

        // ── Fibonacci levels above & below weekly open ────────────────────────
        for i = 0 to 10
            if fibEnabled.get(i)
                float levelAbove = open + (averageRange * (fibMultis.get(i) / 100))
                float levelBelow = open - (averageRange * (fibMultis.get(i) / 100))
                color lineCol    = i == 6 ? HighLight : color.new(colors.get(i), 45)
                color circleCol  = HighLight

                newIWR.lines.push(line.new(
                     x1=bar_index - 1, y1=levelAbove, x2=bar_index, y2=levelAbove,
                     style=lineStyle == "Dashed" ? line.style_dashed : lineStyle == "Solid" ? line.style_solid : line.style_dotted,
                     width=lineWidth, color=lineCol))

                if showCircles
                    newIWR.circles.push(label.new(
                         x=bar_index - 1, y=levelAbove, text="●",
                         style=label.style_label_center,
                         color=color.new(color.black, 100),
                         size=f_circleSize(circleSize), textcolor=circleCol))

                newIWR.lines.push(line.new(
                     x1=bar_index - 1, y1=levelBelow, x2=bar_index, y2=levelBelow,
                     style=lineStyle == "Dashed" ? line.style_dashed : lineStyle == "Solid" ? line.style_solid : line.style_dotted,
                     width=lineWidth, color=lineCol))

                if showCircles
                    newIWR.circles.push(label.new(
                         x=bar_index - 1, y=levelBelow, text="●",
                         style=label.style_label_center,
                         color=color.new(color.black, 100),
                         size=f_circleSize(circleSize), textcolor=circleCol))

            if showLabels
                if fibEnabled.get(i)
                    float levelAbove = open + (averageRange * (fibMultis.get(i) / 100))
                    float levelBelow = open - (averageRange * (fibMultis.get(i) / 100))

                    newIWR.labels.push(box.new(
                         left=bar_index, top=levelAbove + 1, right=bar_index, bottom=levelAbove,
                         bgcolor=color.rgb(54, 58, 69, 70), border_color=na,
                         text=i == 6 ? "▼+100%    $" + str.tostring(math.round(open + averageRange, 0), '0,000') :
                              '+' + str.tostring(fibMultis.get(i)) + "%    $" + str.tostring(math.round(levelAbove, 0), '0,000'),
                         text_color=i == 6 ? HighLight : NormalColor,
                         text_valign=text.align_bottom,
                         text_halign=textAlign == "Left" ? text.align_left : textAlign == "Center" ? text.align_center : text.align_right,
                         text_size=fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large))

                    newIWR.labels.push(box.new(
                         left=bar_index, top=levelBelow + 1, right=bar_index, bottom=levelBelow,
                         bgcolor=color.rgb(54, 58, 69, 70), border_color=na,
                         text=i == 6 ? "▲-100%    $" + str.tostring(math.round(open - averageRange, 0), '0,000') :
                              '-' + str.tostring(fibMultis.get(i)) + "%    $" + str.tostring(math.round(levelBelow, 0), '0,000'),
                         text_color=i == 6 ? HighLight : NormalColor,
                         text_valign=text.align_top,
                         text_halign=textAlign == "Left" ? text.align_left : textAlign == "Center" ? text.align_center : text.align_right,
                         text_size=fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large))

        collection.push(newIWR)

    if not na(newIWR) and tfAllowed
        newIWR.extendLines()

    int maxWeeks = displayMode == "This Week" ? 1 : displayMode == "Two Weeks" ? 2 : displayMode == "Month" ? 4 : 999
    if collection.size() > maxWeeks and displayMode != "All"
        collection.get(0).deleteLines()
        collection.shift()

//--------------
// MAIN LOGIC
//--------------
if isFirstBarOfWeek
    weekRanges.push(weekHigh - weekLow)
    weekHigh := high
    weekLow  := low

    if weekRanges.size() > weeks
        weekRanges.shift()

    averageRange := array.avg(weekRanges)

if tfAllowed
    drawLines(collection, averageRange, tfp)

weekHigh := high > weekHigh ? high : weekHigh
weekLow  := low  < weekLow  ? low  : weekLow
````
