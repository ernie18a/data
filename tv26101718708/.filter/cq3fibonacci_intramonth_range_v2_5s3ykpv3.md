# CQ_(3)_Fibonacci IntraMonth Range v2

- url: https://www.tradingview.com/script/5s3yKPv3-CQ-3-Fibonacci-IntraMonth-Range-v2/
- type: indicator
- pine_id: PUB;cd030f2d0f2e47e497714f8d75f24a0d
- version: 1.0

## Description

================================================================================
  CQ FIBONACCI INTRAMONTH RANGE 2 — USER MANUAL
  Based on Fibonacci IntraDay Range [UkutaLabs] — Adapted to IntraMonth Targets
  Pine Script v6 | TradingView Overlay Indicator
================================================================================


────────────────────────────────────────────────────────────────────────────────
  OVERVIEW
────────────────────────────────────────────────────────────────────────────────

This indicator is a monthly-timeframe adaptation of the Fibonacci IntraDay and
IntraWeek Range system. Instead of projecting intraday or intraweek price
targets, it projects INTRAMONTH Fibonacci targets above and below each month's
opening price, calculated from a rolling average of past monthly high-low ranges.

The indicator is designed for position traders and swing traders who plan their
monthly bias and price targets at the start of each calendar month, using the
historical average monthly range as the statistical basis for target placement.

Key differences from the IntraWeek version:
  - Reference period: MONTHLY open instead of weekly open
  - Range calculation: average monthly high-low ranges (default: 3 months)
  - Session trigger: first bar of each new month (timeframe.change("M"))
  - Gauge label: "MONTH" instead of "WEEK"
  - Monthly open baseline label: "⨁M" instead of "⨁W"
  - Default horizontal offset: 58 bars (widest of the three, suits weekly/monthly charts)
  - Default averaging window: 3 months (one quarter)
  - Default level colors: blue rgb(48, 141, 255) vs amber
  - Display Mode options: This Month / Two Months / Quarter / All
  - No timeframe guard — runs on ALL timeframes including Monthly
  - drawLines() called unconditionally (no tfAllowed check)

Timeframe availability:
  Allowed:   All timeframes (intraday, daily, weekly, monthly)
  Hidden:    Only when Display Mode = "Hidden"

Note: Unlike the IntraDay and IntraWeek versions, this script has NO tfAllowed
timeframe guard. The indicator draws on every timeframe without restriction.
The gauge also runs unconditionally (no tfAllowed check).


────────────────────────────────────────────────────────────────────────────────
  HOW IT WORKS — CONCEPTUAL SUMMARY
────────────────────────────────────────────────────────────────────────────────

Step 1 — Monthly range accumulation:
  Each month's high-low range is tracked as the month progresses bar by bar.
  On the first bar of each new month, the completed prior month's range
  (monthHigh - monthLow) is added to a rolling array. The oldest entry is
  dropped once the array exceeds the "Months to Average Range" setting.
  The array average becomes the "averageRange" for the new month.

Step 2 — Level projection:
  Using the current month's opening price as the baseline, Fibonacci percentage
  levels are projected both above and below:

    levelAbove = monthlyOpen + averageRange × (Fib% ÷ 100)
    levelBelow = monthlyOpen − averageRange × (Fib% ÷ 100)

  Available levels: 15%, 25%, 40%, 50%, 60%, 75%, 100%, 125%, 150%, 175%, 200%
  The 100% level equals a full average-range move — the primary monthly target.

Step 3 — Drawing objects created at month open:
  At the first bar of each new month, all lines, label boxes, and circle
  markers are created and stored in an IntraMonthRange object. Every subsequent
  bar extends the right edge of all lines and label boxes forward in real time.

Step 4 — Session cleanup:
  When Display Mode limits how many months are visible, the oldest
  IntraMonthRange object is deleted (all drawing objects removed) when the
  collection exceeds the maximum count.

Step 5 — Gauge update:
  On every bar, the intramonth gauge is repositioned to the right edge of the
  chart, showing current price position relative to the monthly open, high, and
  low in real time.


────────────────────────────────────────────────────────────────────────────────
  ALGORITHM — DETAILED STEP-BY-STEP
────────────────────────────────────────────────────────────────────────────────

══════════════════════════════════════════════════════════════════════════════
  PROCESS 1: MONTHLY SECURITY DATA RETRIEVAL
══════════════════════════════════════════════════════════════════════════════

The indicator requests monthly OHLC data using request.security() with
lookahead_on, making monthly values available on every lower-timeframe bar:

  monthly_open  — opening price of the current month's candle
  monthly_high  — running high of the current month
  monthly_low   — running low of the current month
  monthly_close — most recent close (current price intramonth)

These values feed both the gauge display and the profit/loss label.

══════════════════════════════════════════════════════════════════════════════
  PROCESS 2: AVERAGE MONTHLY RANGE CALCULATION
══════════════════════════════════════════════════════════════════════════════

Variables:
  monthRanges   — rolling float array of completed monthly ranges
  monthHigh     — running high of the current month (tracked bar by bar)
  monthLow      — running low of the current month (tracked bar by bar)
  averageRange  — average of all entries in monthRanges
  months        — user-defined window size (default: 3)

Logic per bar:

  Trigger: isFirstBarOfMonth = timeframe.change("M")
  Fires on the first bar where the monthly timeframe changes — the first
  trading bar of each new calendar month.

  On isFirstBarOfMonth:
    1. Compute completed prior month's range: monthHigh - monthLow
       Push this value into monthRanges.
    2. Reset monthHigh = high and monthLow = low (current bar's values).
    3. If monthRanges.size() > months, shift out the oldest entry.
    4. Recalculate averageRange = array.avg(monthRanges).

  On every bar (including non-month-open bars):
    monthHigh := high > monthHigh ? high : monthHigh
    monthLow  := low  < monthLow  ? low  : monthLow
  This continuously tracks the current month's expanding range.

  Note: On the first bar of history, monthHigh and monthLow are na. The first
  completed range pushed to monthRanges will compute as na - na = na. The
  averageRange stabilizes only after at least one full month of data.

  Important ordering note: In the main logic block, monthRanges.push() and the
  monthHigh/monthLow reset happen BEFORE drawLines() is called. This means
  the averageRange used to draw this month's levels is based on the prior
  completed months only — the current month's range is not included in its
  own level calculation. This is correct behavior.

══════════════════════════════════════════════════════════════════════════════
  PROCESS 3: INTRAMONTH TENDENCY GAUGE
══════════════════════════════════════════════════════════════════════════════

Purpose: Real-time vertical gauge at the right edge of the chart showing
where price sits within the current month's range relative to the monthly open.

Trigger: Runs on every bar when Intramonth_gauge_draw = true.
Note: Unlike the IntraDay and IntraWeek versions, there is NO tfAllowed guard
on the gauge block. It runs on all timeframes.

Structure (two halves, anchored at monthly_open):

  BULLISH HALF (upper, dark green by default):
    Gauge_box_scope   — background box spanning monthly_open to monthly_high
                        Labeled "MONTH" at top, dotted border, 50% transparent.
    Gauge_line_max    — horizontal line at monthly_high (foreground/teal color)
    Gauge_line_min    — horizontal line at monthly_open (background color)
    Gauge_box_prc     — filled inner box from monthly_open to close
                        Color = bullish foreground if close >= monthly_open
    Gauge_line_prc    — horizontal line at current close (width 4)
    gauge_high_label  — price label above the monthly high: "$X,XXX"
                        Style: label_down, sits above the bull box top
    gauge_open_marker — short solid white horizontal line at monthly_open
    gauge_open_label  — "◀" label pointing left at monthly_open

  BEARISH HALF (lower, dark amber by default):
    Gauge_box_scope2  — background box spanning monthly_low to monthly_open
                        Labeled "MONTH" at bottom, dotted border, 50% transparent.
    Gauge_line_max2   — horizontal line at monthly_open (bullish color, width 3)
    Gauge_line_min2   — horizontal line at monthly_low (bearish foreground, width 2)
    Gauge_box_prc2    — filled inner box from close to monthly_open
                        Color = Gmonthly_color (teal if above open, amber if below)
    Gauge_line_prc2   — horizontal line at current close (width 4)
    gauge_low_label   — price label below the monthly low: "$X,XXX"
                        Style: label_up, sits below the bear box bottom

  PROFIT/LOSS LABEL (positioned to the right of the gauge):
    profit_loss_label — dollar gain/loss from monthly open: "$#,XXX"
    Position: bar_index + gauge_offset + 6
    y position: close + y_adjust (1 if above open, -1 if below)
    Text: math.round(close - monthly_open, 0) formatted as '$#,000'
    Color: fully transparent background, opaque text
    Text color: teal if above monthly open, amber if below
    Tooltip: percentage return + dollar amount + "from Monthly Opening: $X,XXX"

  Position calculation:
    gauge_offset = lines_offset - 6
    Bullish box:  left = bar_index + gauge_offset - 2
                  right = bar_index + gauge_offset + 1
    Fill box:     left = bar_index + gauge_offset - 1
                  right = bar_index + gauge_offset (note: -0 = +0)
    P&L label:   bar_index + gauge_offset + 6

  Dynamic updates (every bar):
    All box corners, line endpoints, and label positions are updated using
    set_ methods so the gauge tracks price in real time without creating
    new objects on each bar.

  Color logic:
    GMOcolor       = close >= monthly_open (boolean)
    Gmonthly_color = gauge_bullish_color2 if GMOcolor else gauge_bearish_color2
    This single variable drives the fill color of both price boxes and the
    profit/loss label text color.

══════════════════════════════════════════════════════════════════════════════
  PROCESS 4: FIBONACCI LEVEL DRAWING (drawLines function)
══════════════════════════════════════════════════════════════════════════════

Called unconditionally on every bar (no tfAllowed guard in the call site).
Creates new drawing objects only when isFirstBarOfMonth is true and
displayMode is not "Hidden".

─── MONTH-OPEN TRIGGER ─────────────────────────────────────────────────────

A new IntraMonthRange object is instantiated with three empty arrays:
  lines   — array<line>  for all Fibonacci level lines
  labels  — array<box>   for all text label boxes
  circles — array<label> for all circle dot markers

─── MONTHLY OPEN BASELINE ──────────────────────────────────────────────────

A dotted line is drawn at the opening price of the new month:
  line.new(x1=bar_index, y1=open, x2=bar_index, y2=open,
           color=HighLight, width=lineWidth, style=line.style_dotted)

x1 = x2 = bar_index at creation time. The extendLines() method updates x2
on every subsequent bar to extend the line forward.

If showCircles:
  A "●" label is placed at bar_index - 1 at the open price.
  Transparent background, HighLight text color.

If showLabels:
  A box label "⨁M    $X,XXX" is placed at the open price.
  ⨁M identifies this as the monthly open baseline.
  bgcolor = HighLight, text_color = HighLight (rendered as colored text
  against the HighLight background, making it appear highlighted).

─── FIBONACCI LEVEL LOOP (i = 0 to 10) ────────────────────────────────────

For each of the 11 possible levels, if fibEnabled.get(i) is true:

  Compute:
    levelAbove = open + (averageRange × fibMultis.get(i) / 100)
    levelBelow = open − (averageRange × fibMultis.get(i) / 100)

  Line color selection:
    i == 6 (100% level): HighLight color (full opacity, accent blue)
    all others: color.new(colors.get(i), 45) (45% transparent)

  Circle color: always HighLight — same color for all circles regardless of level.

  For levelAbove:
    Push a line (style per lineStyle) into newIMR.lines.
    If showCircles: push a "●" label at bar_index - 1, y = levelAbove.

  For levelBelow:
    Push a line (same style) into newIMR.lines.
    If showCircles: push a "●" label at bar_index - 1, y = levelBelow.

  If showLabels (evaluated independently after the main fib block):
    For levelAbove: push a box with:
      i == 6: "▼+100%    $X,XXX"  (special full-range label)
      others: "+X%    $X,XXX"
      text_valign: text.align_bottom (label text sits above the line)
      text_color: HighLight for i==6, NormalColor for all others
      bgcolor: color.rgb(54, 58, 69, 70) — semi-transparent dark gray

    For levelBelow: push a box with:
      i == 6: "▲-100%    $X,XXX"  (special full-range label, downside)
      others: "-X%    $X,XXX"
      text_valign: text.align_top (label text sits below the line)
      text_color: HighLight for i==6, NormalColor for all others
      bgcolor: same semi-transparent dark gray

  After loop completes: push newIMR into collection array.

─── LINE EXTENSION (every bar after month open) ────────────────────────────

If newIMR is not na (i.e., a month object was created at some point during
this indicator's execution):
  Call newIMR.extendLines():
    For each line: line.set_x2(bar_index + lines_offset)
    For each box label: box.set_right(bar_index + lines_offset)
    (Label extension only runs if showLabels is true)

This keeps every active line and label stretched to the current bar plus
the user-defined offset on every tick.

─── COLLECTION CLEANUP ─────────────────────────────────────────────────────

  maxMonths mapping:
    "This Month"  → 1
    "Two Months"  → 2
    "Quarter"     → 3
    "All"         → 999

  If collection.size() > maxMonths AND displayMode != "All":
    Call deleteLines() on collection.get(0):
      Delete all lines and label boxes (if showLabels) in the oldest object.
      Delete all circle labels.
    Shift the oldest object out of collection.


────────────────────────────────────────────────────────────────────────────────
  DATA STRUCTURES
────────────────────────────────────────────────────────────────────────────────

  type IntraMonthRange
    array<line>  lines    — all Fibonacci level lines for this month
    array<box>   labels   — all text label boxes for this month
    array<label> circles  — all circle dot markers for this month

  method extendLines(IntraMonthRange this)
    Iterates over lines[] and extends each to bar_index + lines_offset.
    Iterates over labels[] and extends each right edge to bar_index + lines_offset.
    Guard: skips if this is na.

  method deleteLines(IntraMonthRange this)
    Deletes every line in lines[].
    Deletes every box in labels[] (only if showLabels is true).
    Deletes every label in circles[].
    Guard: skips if this is na.

  Global state arrays:
    collection   — array<IntraMonthRange> — all active month objects
    monthRanges  — array<float>           — rolling monthly range history
    fibMultis    — [15,25,40,50,60,75,100,125,150,175,200] (fixed at init)
    colors       — 11 user-defined level colors (captured at indicator load)
    fibEnabled   — 11 user-defined boolean toggles (captured at indicator load)


────────────────────────────────────────────────────────────────────────────────
  SETTINGS REFERENCE
────────────────────────────────────────────────────────────────────────────────

── CONFIGURATION ───────────────────────────────────────────────────────────────

  Display Mode
    Controls how many months of Fibonacci levels are drawn simultaneously.
      Hidden      — disables all Fibonacci drawing (gauge still runs)
      This Month  — current month only (default)
      Two Months  — current and previous month
      Quarter     — last 3 months (one quarter)
      All         — every month on the chart (no cleanup, watch limits)

── AVERAGE RANGE SETTINGS ──────────────────────────────────────────────────────

  Months to Average Range
    Number of past completed months used to compute the average monthly range.
    Default: 3 months (one quarter).
    Lower values (1–2): react quickly to recent volatility; useful during
      earnings seasons or high macro-event months.
    Higher values (6–12): smoothed long-term average; better for stable,
      range-bound instruments or broad index analysis.

── LABEL SETTINGS ──────────────────────────────────────────────────────────────

  Show Labels
    Toggles all text boxes showing percentage and dollar value at each level.
    Default: On

  Font Size
    Options: Tiny / Small / Medium / Large
    Applies to all level label text boxes.
    Default: Small

  Text Alignment
    Options: Left / Center / Right
    Horizontal alignment of text within each label box.
    Default: Right

  Position (Horizontal Offset)
    Range: 0 – 100 bars. Default: 58.
    How far right lines and labels extend past the current bar.
    This is the widest default of the three versions (IntraDay=32, Week=45,
    Month=58), reflecting the wider spacing needed on daily/weekly charts.
    The gauge position is derived as: lines_offset − 6.

── LINE SETTINGS ───────────────────────────────────────────────────────────────

  Line Width
    Pixel thickness of all Fibonacci level lines.
    Default: 1

  Line Style
    Options: Solid / Dashed / Dotted
    Applies uniformly to all Fibonacci level lines.
    Default: Solid

── CIRCLE SETTINGS ─────────────────────────────────────────────────────────────

  Show Circles at Line Start
    Places a "●" marker at the left origin (month open bar) of each level line.
    All circles use HighLight color regardless of individual level color.
    Default: On

  Circle Size
    Options: Tiny / Small / Normal / Large
    Default: Tiny

── FIBONACCI LEVELS ────────────────────────────────────────────────────────────

  Each level has an individual color picker and enable/disable toggle.
  All 11 levels share the same default color: rgb(48, 141, 255) — medium blue.

  Level    %       Default   Notes
  -------  ------  --------  ---------------------------------------------------
  0        15%     On        Minor monthly support / resistance
  1        25%     On        Quarter-range monthly pivot
  2        40%     On        Below midpoint inflection
  3        50%     On        Midpoint — half the average monthly range
  4        60%     On        Above midpoint inflection
  5        75%     On        Three-quarter range target
  6        100%    On        Full average range — rendered in HighLight color
  7        125%    Off       Extended monthly move
  8        150%    Off       Extended monthly move
  9        175%    Off       Extreme monthly extension
  10       200%    Off       Double-range extreme

  NormalColor (first "Highlighted Items Color" input)
    Color of label text for all non-100% enabled levels.
    Default: rgb(48, 141, 255) — same medium blue as level lines.

  HighLight (second "Highlighted Items Color" input)
    Color for: 100% level line and labels, the monthly open baseline line,
    and ALL circle markers.
    Default: rgb(134, 207, 255) — lighter, brighter blue.

  Note: Both color inputs share the title "Highlighted Items Color" in
  the settings panel. NormalColor appears first, HighLight second.

── GAUGE SETTINGS ──────────────────────────────────────────────────────────────

  Draw Intramonth Price Tendency Gauge
    Enables/disables the vertical gauge at the right chart edge.
    Default: On
    Note: No tfAllowed restriction — gauge runs on all timeframes.

  Gauge Background (Bullish)
    Background color of the upper half box (monthly_open to monthly_high).
    Default: Dark green rgb(0, 83, 75).

  Foreground (Bullish)
    Fill bar color and monthly high label text color when close >= monthly_open.
    Default: Bright teal rgb(0, 194, 174).

  Gauge Background (Bearish)
    Background color of the lower half box (monthly_low to monthly_open).
    Default: Dark amber rgb(85, 48, 0).

  Foreground (Bearish)
    Fill bar color and monthly low label text color when close < monthly_open.
    Default: Orange rgb(255, 153, 0).


────────────────────────────────────────────────────────────────────────────────
  COMPARISON: ALL THREE VERSIONS SIDE BY SIDE
────────────────────────────────────────────────────────────────────────────────

  Feature                   IntraDay           IntraWeek          IntraMonth
  ────────────────────────  ─────────────────  ─────────────────  ─────────────────
  Reference period          Daily open         Weekly open        Monthly open
  Range source              Daily H-L          Weekly H-L         Monthly H-L
  Default avg window        1 day              4 weeks            3 months
  Session trigger           session.isfirstbar timeframe.change   timeframe.change
                                               ("W")              ("M")
  Baseline label            ⨁D                ⨁W                 ⨁M
  Gauge label               DAY                WEEK               MONTH
  Security timeframe        'D'                'W'                'M'
  Timeframe guard           W and M hidden     M hidden           None (all TFs)
  tfAllowed in drawLines    Yes                Yes                No (removed)
  Default offset            32 bars            45 bars            58 bars
  Default circle size       Small              Tiny               Tiny
  Default level colors      Blue (153,198,253) Amber (182,109,0)  Blue (48,141,255)
  HighLight color           Blue (181,212,249) Gold (255,176,58)  LtBlue(134,207,255)
  Display mode options      Today/Two Days/    This Week/         This Month/
                            Week/All           Two Weeks/         Two Months/
                                               Month/All          Quarter/All
  Max visible periods       1/2/5/999          1/2/4/999          1/2/3/999
  Current price label       Yes (≤4H only)     No                 No
  Class name                IntraDayRange      IntraWeekRange     IntraMonthRange


────────────────────────────────────────────────────────────────────────────────
  PRACTICAL USAGE GUIDE
────────────────────────────────────────────────────────────────────────────────

Best timeframes for this indicator:
  Weekly chart  — primary use case for position traders; shows the monthly
                  Fibonacci levels across all weeks of the month, making it
                  easy to see which levels each week's price action is
                  interacting with.
  Daily chart   — ideal for swing traders; allows granular tracking of price
                  progress toward each monthly Fibonacci target day by day.
  4H chart      — useful for active traders who want intraday context while
                  keeping monthly structure visible.
  Monthly chart — levels draw once per bar; useful only for quick reference
                  when comparing multiple months in "Two Months" or "Quarter"
                  mode.

Setting the averaging window:
  3 months (default) — one quarter; balances recency with seasonal smoothing.
  1 month            — uses only last month's range; extremely reactive; good
                       for instruments with high month-to-month volatility.
  6 months           — half-year average; best for stable indices or commodities
                       where monthly ranges are relatively consistent.
  12 months          — full-year average; produces very stable targets; useful
                       for annual range planning.

Reading the monthly gauge:
  The gauge gives instant visual feedback on the month's price progress:
  - The teal upper half shows how far price has moved above the monthly open
    toward the month's running high.
  - The amber lower half shows how far price has dropped below the monthly open
    toward the month's running low.
  - The fill bar inside each half shows the proportional position of current
    price within that half of the month's range.
  - Hover over the P&L label for exact percentage return from the monthly open.

Using levels as monthly targets:
  The 50% level marks the midpoint of an average monthly range. Reaching 50%
  within the first two weeks of the month represents a normal monthly pace.
  The 100% level is the primary monthly target — reaching it signals a full
  average-range month. Levels above 100% indicate an unusually large monthly
  move, typical of trend-acceleration or major macro events.

Display Mode recommendations:
  "This Month"  — cleanest; focus on current month only.
  "Two Months"  — compare current month structure against the prior month.
  "Quarter"     — map the full quarter; useful for identifying whether
                  Fibonacci targets cluster across months (confluence zones).
  "All"         — useful only on high timeframes with limited bar history.
                  Monitor drawing object limits carefully.

Avoiding chart clutter:
  On intraday and daily timeframes, monthly Fibonacci levels span a very large
  price area. Keep the 125%–200% levels disabled unless specifically tracking
  breakout months. Reducing the offset to 30–40 bars on daily charts helps
  prevent label overlap with price action. On weekly charts the default 58-bar
  offset works well.


────────────────────────────────────────────────────────────────────────────────
  KEY DIFFERENCES FROM INTRADAY/INTRAWEEK VERSIONS — TECHNICAL NOTES
────────────────────────────────────────────────────────────────────────────────

  1. No timeframe guard on indicator execution:
     The IntraDay version hides on Weekly and Monthly charts. The IntraWeek
     version hides on Monthly charts. The IntraMonth version has NO such guard.
     The tfAllowed variable that exists in the other two versions is absent here.
     drawLines() is called unconditionally, and the gauge block runs without a
     tfAllowed condition.

  2. No tfAllowed check inside drawLines():
     The IntraDay and IntraWeek drawLines() functions check tfAllowed before
     extending lines and before cleanup. The IntraMonth version omits this check
     entirely — extension and cleanup run on every bar regardless of timeframe.

  3. "Quarter" instead of "Month" or "Week":
     The maximum Display Mode at the 3-period mark is called "Quarter" (3 months)
     rather than "Month" (4 weeks in IntraWeek) or "Week" (5 days in IntraDay).
     The maxMonths mapping is: This Month=1, Two Months=2, Quarter=3, All=999.

  4. Main logic call order:
     In IntraDay and IntraWeek, the range reset and averageRange recalculation
     happen inside the session trigger block, followed by a separate drawLines()
     call. In IntraMonth, the same order is preserved but drawLines() is called
     at the bottom of the script without any tfAllowed guard wrapper.

  5. Gauge fill box right edge:
     The IntraMonth gauge uses bar_index + gauge_offset - 0 (effectively +0)
     for the right edge of the fill box, compared to bar_index + gauge_offset
     in the IntraWeek version. The result is functionally identical.


────────────────────────────────────────────────────────────────────────────────
  QUICK REFERENCE — DEFAULT SETTINGS
────────────────────────────────────────────────────────────────────────────────

  Display Mode              This Month
  Months to Average Range   3
  Show Labels               On
  Font Size                 Small
  Text Alignment            Right
  Horizontal Offset         58
  Line Width                1
  Line Style                Solid
  Show Circles              On
  Circle Size               Tiny
  Active Fib Levels         15%, 25%, 40%, 50%, 60%, 75%, 100%
  Level Colors              Blue rgb(48, 141, 255)
  HighLight Color           Light Blue rgb(134, 207, 255)
  Normal Label Color        Blue rgb(48, 141, 255)
  Gauge                     On (all timeframes)
  Gauge Bullish BG          Dark green rgb(0, 83, 75)
  Gauge Bullish FG          Teal rgb(0, 194, 174)
  Gauge Bearish BG          Dark amber rgb(85, 48, 0)
  Gauge Bearish FG          Orange rgb(255, 153, 0)


────────────────────────────────────────────────────────────────────────────────
  LIMITATIONS AND NOTES
────────────────────────────────────────────────────────────────────────────────

  - averageRange is na until at least one full month of data has been processed.
    Fibonacci levels will not appear correctly on the very first month of any
    chart's history.

  - The colors[] and fibEnabled[] arrays are initialized once at indicator load
    using the var keyword. Changes to level colors or enable/disable toggles
    may require a full indicator reload to take effect on the arrays.

  - On the Monthly timeframe, timeframe.change("M") fires on every bar. This
    causes drawLines() to create a new IntraMonthRange object on every bar,
    immediately cleaning up the previous one. Use the Daily or Weekly timeframes
    for the intended visual behavior.

  - All past month objects remain visible within the Display Mode limit.
    Switching Display Mode mid-month will not retroactively restore previously
    deleted month objects. The new limit takes effect at the next month boundary.

  - Indicator drawing limits:
      max_lines_count  = 500
      max_boxes_count  = 500
      max_labels_count = 500
    In "All" mode with extended chart history on intraday timeframes, these
    limits may be reached. Use "Quarter" (3 months) for practical long-term use.

  - There is no current price label in this version. Unlike the IntraDay
    version, no live floating price box is included in this script.

  - The indicator does not provide stop loss, position sizing, or take profit
    levels. These must be determined by the trader using their own risk
    management framework.


================================================================================
  END OF MANUAL
================================================================================

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Based on "Fibonacci IntraDay Range [UkutaLabs]" — adapted to INTRAMONTH targets
// Modified: Circle markers at start of each Fibonacci level line using HighLight color
//@version=6
indicator("CQ_(3)_Fibonacci IntraMonth Range v2", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

//--------------
// USER VARIABLES
//--------------
string displayMode  = input.string(defval="This Month", title="Display Mode",
     options=["Hidden", "This Month", "Two Months", "Quarter", "All"], group="Configuration")

int months          = input.int(defval=3, title="Months to Average Range", group="Average Range Settings")

bool showLabels     = input.bool(defval=true, title="Show Labels", group="Label Settings")
string fontSize     = input.string(defval="Small", title="Font Size",
     options=["Tiny", "Small", "Medium", "Large"], group="Label Settings")
string textAlign    = input.string(defval="Right", title="Text Alignment",
     options=["Left", "Center", "Right"], group="Label Settings")
var lines_offset    = input.int(defval=58, minval=0, maxval=100,
     title='Position (Horizontal Offset)', group="Label Settings")

int lineWidth       = input(defval=1, title="Line Width", group="Line Settings")
string lineStyle    = input.string(defval="Solid", title="Line Style",
     options=["Dashed","Solid","Dotted"], group="Line Settings")

// ── Circle Settings ───────────────────────────────────────────────────────────
bool showCircles    = input.bool(defval=true, title="Show Circles at Line Start", group="Circle Settings")
string circleSize   = input.string(defval="Tiny", title="Circle Size",
     options=["Tiny", "Small", "Normal", "Large"], group="Circle Settings")

color LevelColor0   = input.color(defval=color.rgb(48, 141, 255), title="Line Color", group="Fibonacci Levels", inline="0")
bool showLevel0     = input.bool(defval=true,  title="Enable (15%)",   group="Fibonacci Levels", inline="0")
color LevelColor1   = input.color(defval=color.rgb(48, 141, 255), title="Line Color", group="Fibonacci Levels", inline="1")
bool showLevel1     = input.bool(defval=true,  title="Enable (25%)",   group="Fibonacci Levels", inline="1")
color LevelColor2   = input.color(defval=color.rgb(48, 141, 255), title="Line Color", group="Fibonacci Levels", inline="2")
bool showLevel2     = input.bool(defval=true,  title="Enable (40%)",   group="Fibonacci Levels", inline="2")
color LevelColor3   = input.color(defval=color.rgb(48, 141, 255), title="Line Color", group="Fibonacci Levels", inline="3")
bool showLevel3     = input.bool(defval=true,  title="Enable (50%)",   group="Fibonacci Levels", inline="3")
color LevelColor4   = input.color(defval=color.rgb(48, 141, 255), title="Line Color", group="Fibonacci Levels", inline="4")
bool showLevel4     = input.bool(defval=true,  title="Enable (60%)",   group="Fibonacci Levels", inline="4")
color LevelColor5   = input.color(defval=color.rgb(48, 141, 255), title="Line Color", group="Fibonacci Levels", inline="5")
bool showLevel5     = input.bool(defval=true,  title="Enable (75%)",   group="Fibonacci Levels", inline="5")
color LevelColor6   = input.color(defval=color.rgb(48, 141, 255), title="Line Color", group="Fibonacci Levels", inline="6")
bool showLevel6     = input.bool(defval=true,  title="Enable (100%)",  group="Fibonacci Levels", inline="6")
color LevelColor7   = input.color(defval=color.rgb(48, 141, 255), title="Line Color", group="Fibonacci Levels", inline="7")
bool showLevel7     = input.bool(defval=false, title="Enable (125%)",  group="Fibonacci Levels", inline="7")
color LevelColor8   = input.color(defval=color.rgb(48, 141, 255), title="Line Color", group="Fibonacci Levels", inline="8")
bool showLevel8     = input.bool(defval=false, title="Enable (150%)",  group="Fibonacci Levels", inline="8")
color LevelColor9   = input.color(defval=color.rgb(48, 141, 255), title="Line Color", group="Fibonacci Levels", inline="9")
bool showLevel9     = input.bool(defval=false, title="Enable (175%)",  group="Fibonacci Levels", inline="9")
color LevelColor10  = input.color(defval=color.rgb(48, 141, 255), title="Line Color", group="Fibonacci Levels", inline="10")
bool showLevel10    = input.bool(defval=false, title="Enable (200%)",  group="Fibonacci Levels", inline="10")

color NormalColor   = input.color(defval=color.rgb(48, 141, 255), title="Highlighted Items Color", group="Fibonacci Levels")
color HighLight     = input.color(defval=color.rgb(134, 207, 255), title="Highlighted Items Color", group="Fibonacci Levels")

// ── GAUGE (relative to MONTHLY open) ─────────────────────────────────────────
Intramonth_gauge_draw  = input.bool(true, 'Draw INTRAMONTH Price Tendency Gauge', inline='retlg', group='Gauge')

gauge_bullish_color    = input.color(color.rgb(0, 83, 75),   title='    Gauge Background (Bullish)', inline='Bullish')
gauge_bullish_color2   = input.color(color.rgb(0, 194, 174), title='    Foreground',                inline='Bullish')

gauge_bearish_color    = input.color(color.rgb(85, 48, 0),   title='    Gauge Background (Bearish)', inline='Bearish')
gauge_bearish_color2   = input.color(color.rgb(255, 153, 0),  title='    Foreground',                inline='Bearish')


//gauge_offset         = input.int(49, title='    Position (Horizontal Offset)')
gauge_offset           =  lines_offset - 6 

//--------------
// MONTHLY SECURITY DATA
//--------------
monthly_open  = request.security(syminfo.tickerid, 'M', open,  lookahead=barmerge.lookahead_on)
monthly_high  = request.security(syminfo.tickerid, 'M', high,  lookahead=barmerge.lookahead_on)
monthly_low   = request.security(syminfo.tickerid, 'M', low,   lookahead=barmerge.lookahead_on)
monthly_close = request.security(syminfo.tickerid, 'M', close, lookahead=barmerge.lookahead_on)

// ── INTRAMONTH TENDENCY GAUGE ─────────────────────────────────────────────────
GMOcolor       = close >= monthly_open
Gmonthly_color = GMOcolor ? gauge_bullish_color2 : gauge_bearish_color2

if Intramonth_gauge_draw == true

    // ── Bull box (open → high) ────────────────────────────────────────────────
    var Gauge_box_scope  = box.new(bar_index, close, bar_index, monthly_open,
         border_color=color.new(gauge_bullish_color, 0), border_width=1,
         border_style=line.style_dotted,
         text='MONTH', text_valign=text.align_top, text_size=size.tiny,
         text_color=color.white, bgcolor=color.new(gauge_bullish_color, 50))
    var Gauge_line_max   = line.new(bar_index, close, bar_index, monthly_open,
         color=gauge_bullish_color2, width=2)
    var Gauge_line_min   = line.new(bar_index, close, bar_index, monthly_open,
         color=gauge_bullish_color, width=3)
    var Gauge_box_prc    = box.new(bar_index, close, bar_index, monthly_open,
         border_color=color.new(gauge_bullish_color, 50), border_width=1,
         bgcolor=color.new(Gmonthly_color, 80))
    var Gauge_line_prc   = line.new(bar_index, close, bar_index, monthly_open,
         color=gauge_bullish_color, width=4)

    // ── NEW: Monthly High label — sits above the bull box ─────────────────────
    var label gauge_high_label = label.new(bar_index, monthly_high,
         text      = str.tostring(math.round(monthly_high, 0), '$0,000'),
         style     = label.style_label_down,
         color     = color.new(gauge_bullish_color, 80),
         textcolor = gauge_bullish_color2,
         size      = size.small)

    // ── NEW: Opening price marker — bold white line spanning both boxes ───────
    var line gauge_open_marker = line.new(
         x1    = bar_index + gauge_offset - 2,
         y1    = monthly_open,
         x2    = bar_index + gauge_offset + 1,
         y2    = monthly_open,
         color = color.white,
         width = 3,
         style = line.style_solid)
    var label gauge_open_label = label.new(bar_index, monthly_open,
         text      = "◀",
         style     = label.style_label_left,
         color     = color.new(color.black, 100),
         textcolor = color.white,
         size      = size.tiny)

    // ── Update bull box every bar ─────────────────────────────────────────────
    box.set_lefttop    (Gauge_box_scope, bar_index + gauge_offset - 2, monthly_high)
    box.set_rightbottom(Gauge_box_scope, bar_index + gauge_offset + 1, monthly_open)
    line.set_xy1(Gauge_line_max, bar_index + gauge_offset - 2, monthly_high)
    line.set_xy2(Gauge_line_max, bar_index + gauge_offset + 1, monthly_high)
    line.set_xy1(Gauge_line_min, bar_index + gauge_offset - 2, monthly_open)
    line.set_xy2(Gauge_line_min, bar_index + gauge_offset + 1, monthly_open)

    box.set_lefttop    (Gauge_box_prc, bar_index + gauge_offset - 1, close)
    box.set_rightbottom(Gauge_box_prc, bar_index + gauge_offset - 0, monthly_open)
    box.set_bgcolor    (Gauge_box_prc, color.new(Gmonthly_color, 80))
    box.set_border_color(Gauge_box_prc, color.new(Gmonthly_color, 50))
    line.set_xy1(Gauge_line_prc, bar_index + gauge_offset - 1, close)
    line.set_xy2(Gauge_line_prc, bar_index + gauge_offset + 0, close)
    line.set_color(Gauge_line_prc, gauge_bullish_color)

    // ── Update High label every bar ───────────────────────────────────────────
    label.set_xy  (gauge_high_label, bar_index + gauge_offset - 1, monthly_high)
    label.set_text(gauge_high_label, str.tostring(math.round(monthly_high, 0), '$0,000'))

    // ── Update Open marker & label every bar ──────────────────────────────────
    line.set_xy1(gauge_open_marker, bar_index + gauge_offset - 2, monthly_open)
    line.set_xy2(gauge_open_marker, bar_index + gauge_offset + 1, monthly_open)
    label.set_xy  (gauge_open_label, bar_index + gauge_offset + 0, monthly_open)
    label.set_text(gauge_open_label, "◀")

    // ── Bear box (open → low) ─────────────────────────────────────────────────
    var Gauge_box_scope2 = box.new(bar_index, close, bar_index, monthly_open,
         border_color=color.new(gauge_bearish_color, 0), border_width=1,
         border_style=line.style_dotted, 
         bgcolor=color.new(gauge_bearish_color, 50),
         text='MONTH', 
         text_valign=text.align_bottom, 
         text_size=size.tiny,
         text_color=color.white)       
    var Gauge_line_max2  = line.new(bar_index, close, bar_index, monthly_open,
         color=gauge_bullish_color, width=3)
    var Gauge_line_min2  = line.new(bar_index, close, bar_index, monthly_open,
         color=gauge_bearish_color2, width=2)
    var Gauge_box_prc2   = box.new(bar_index, close, bar_index, monthly_open,
         border_color=color.new(gauge_bullish_color, 50), border_width=1,
         bgcolor=color.new(Gmonthly_color, 80))
    var Gauge_line_prc2  = line.new(bar_index, close, bar_index, monthly_open,
         color=Gmonthly_color, width=4)

    // ── NEW: Monthly Low label — sits below the bear box ─────────────────────
    var label gauge_low_label = label.new(bar_index, monthly_low,
         text      = str.tostring(math.round(monthly_low, 0), '$0,000'),
         style     = label.style_label_up,
         color     = color.new(gauge_bearish_color, 80),
         textcolor = gauge_bearish_color2,
         size      = size.small)

    // ── Update bear box every bar ─────────────────────────────────────────────
    box.set_lefttop    (Gauge_box_scope2, bar_index + gauge_offset - 2, monthly_open)
    box.set_rightbottom(Gauge_box_scope2, bar_index + gauge_offset + 1, monthly_low)
    line.set_xy1(Gauge_line_max2, bar_index + gauge_offset - 2, monthly_open)
    line.set_xy2(Gauge_line_max2, bar_index + gauge_offset + 1, monthly_open)
    line.set_xy1(Gauge_line_min2, bar_index + gauge_offset - 2, monthly_low)
    line.set_xy2(Gauge_line_min2, bar_index + gauge_offset + 1, monthly_low)

    box.set_lefttop    (Gauge_box_prc2, bar_index + gauge_offset - 1, close)
    box.set_rightbottom(Gauge_box_prc2, bar_index + gauge_offset - 0, monthly_open)
    box.set_bgcolor    (Gauge_box_prc2, color.new(Gmonthly_color, 80))
    box.set_border_color(Gauge_box_prc2, color.new(Gmonthly_color, 50))
    line.set_xy1(Gauge_line_prc2, bar_index + gauge_offset - 1, close)
    line.set_xy2(Gauge_line_prc2, bar_index + gauge_offset + 0, close)
    line.set_color(Gauge_line_prc2, gauge_bullish_color)

    // ── Update Low label every bar ────────────────────────────────────────────
    label.set_xy  (gauge_low_label, bar_index + gauge_offset - 1, monthly_low)
    label.set_text(gauge_low_label, str.tostring(math.round(monthly_low, 0), '$0,000'))

    // ── P&L label ─────────────────────────────────────────────────────────────
    var y_adjust = 1
    y_adjust := close - monthly_open < 0 ? -1 : 1

    var profit_loss_label = label.new(bar_index, close,
         str.tostring(math.round(close - monthly_open, 0), '$#,000'))
    label.set_xy      (profit_loss_label, bar_index + gauge_offset + 6, close + y_adjust)
    label.set_text    (profit_loss_label, str.tostring(math.round(close - monthly_open, 0), '$#,000'))
    label.set_tooltip (profit_loss_label,
         str.tostring(((close - monthly_open) / monthly_open) * 100, format.percent) + ' ' +
         str.tostring(math.round(close - monthly_open, 0), '$#,000') +
         ' from Monthly Opening: ' + str.tostring(math.round(monthly_open, 0), '$#,000'))
    label.set_color   (profit_loss_label, color.new(Gmonthly_color, 100))
    label.set_textcolor(profit_loss_label, color.new(Gmonthly_color, 0))
    label.set_size    (profit_loss_label, size.small)
    label.set_style   (profit_loss_label, label.style_label_right)
    label.set_textalign(profit_loss_label, text.align_left)

//--------------
// CLASSES
//--------------
type IntraMonthRange
    array<line>  lines
    array<box>   labels
    array<label> circles

method extendLines(IntraMonthRange this) =>
    if not na(this)
        for i = 0 to this.lines.size() - 1
            this.lines.get(i).set_x2(bar_index + lines_offset)
            if showLabels
                this.labels.get(i).set_right(bar_index + lines_offset)

method deleteLines(IntraMonthRange this) =>
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
var collection         = array.new<IntraMonthRange>(0)
var monthRanges        = array.new<float>(0)
var float averageRange = na
var float monthHigh    = na
var float monthLow     = na
var int   tfp          = timeframe.isintraday and not timeframe.isseconds ? int(str.tonumber(timeframe.period)) : 0

var fibMultis  = array.from(15, 25, 40, 50, 60, 75, 100, 125, 150, 175, 200)
var colors     = array.from(LevelColor0, LevelColor1, LevelColor2, LevelColor3, LevelColor4,
     LevelColor5, LevelColor6, LevelColor7, LevelColor8, LevelColor9, LevelColor10)
var fibEnabled = array.from(showLevel0, showLevel1, showLevel2, showLevel3, showLevel4,
     showLevel5, showLevel6, showLevel7, showLevel8, showLevel9, showLevel10)

isFirstBarOfMonth = timeframe.change("M")

//--------------
// DRAW FUNCTION (month-aware) — with circles
//--------------
drawLines(array<IntraMonthRange> collection, float averageRange, int tfp) =>
    var IntraMonthRange newIMR = na

    if isFirstBarOfMonth and displayMode != "Hidden"
        newIMR := IntraMonthRange.new(
             lines   = array.new<line>(0),
             labels  = array.new<box>(0),
             circles = array.new<label>(0))

        // ── Monthly open baseline ─────────────────────────────────────────────
        newIMR.lines.push(line.new(
             x1=bar_index, y1=open, x2=bar_index, y2=open,
             color=HighLight, width=lineWidth, style=line.style_dotted))

        if showCircles
            newIMR.circles.push(label.new(
                 x         = bar_index - 1,
                 y         = open,
                 text      = "●",
                 style     = label.style_label_center,
                 color     = color.new(color.black, 100),
                 size      = f_circleSize(circleSize),
                 textcolor = HighLight))

        if showLabels
            newIMR.labels.push(box.new(
                 left=bar_index, top=open + 1, right=bar_index, bottom=open,
                 bgcolor=HighLight, border_color=na,
                 text="⨁M    $" + str.tostring(open, '0,000'),
                 text_color=HighLight,
                 text_valign=text.align_center,
                 text_halign=textAlign == "Left" ? text.align_left : textAlign == "Center" ? text.align_center : text.align_right,
                 text_size=fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large))

        // ── Fibonacci levels above & below monthly open ───────────────────────
        for i = 0 to 10
            if fibEnabled.get(i)
                float levelAbove = open + (averageRange * (fibMultis.get(i) / 100))
                float levelBelow = open - (averageRange * (fibMultis.get(i) / 100))
                color lineCol    = i == 6 ? HighLight : color.new(colors.get(i), 45)

                newIMR.lines.push(line.new(
                     x1=bar_index - 1, y1=levelAbove,
                     x2=bar_index,     y2=levelAbove,
                     style=lineStyle == "Dashed" ? line.style_dashed : lineStyle == "Solid" ? line.style_solid : line.style_dotted,
                     width=lineWidth, color=lineCol))

                if showCircles
                    newIMR.circles.push(label.new(
                         x         = bar_index - 1,
                         y         = levelAbove,
                         text      = "●",
                         style     = label.style_label_center,
                         color     = color.new(color.black, 100),
                         size      = f_circleSize(circleSize),
                         textcolor = HighLight))

                newIMR.lines.push(line.new(
                     x1=bar_index - 1, y1=levelBelow,
                     x2=bar_index,     y2=levelBelow,
                     style=lineStyle == "Dashed" ? line.style_dashed : lineStyle == "Solid" ? line.style_solid : line.style_dotted,
                     width=lineWidth, color=lineCol))

                if showCircles
                    newIMR.circles.push(label.new(
                         x         = bar_index - 1,
                         y         = levelBelow,
                         text      = "●",
                         style     = label.style_label_center,
                         color     = color.new(color.black, 100),
                         size      = f_circleSize(circleSize),
                         textcolor = HighLight))

            if showLabels
                if fibEnabled.get(i)
                    float levelAbove = open + (averageRange * (fibMultis.get(i) / 100))
                    float levelBelow = open - (averageRange * (fibMultis.get(i) / 100))

                    newIMR.labels.push(box.new(
                         left=bar_index, top=levelAbove + 1,
                         right=bar_index, bottom=levelAbove,
                         bgcolor=color.rgb(54, 58, 69, 70), border_color=na,
                         text=i == 6 ? "▼+100%    $" + str.tostring(math.round(open + averageRange, 0), '0,000') :
                              '+' + str.tostring(fibMultis.get(i)) + "%    $" + str.tostring(math.round(levelAbove, 0), '0,000'),
                         text_color=i == 6 ? HighLight : NormalColor,
                         text_valign=text.align_bottom,
                         text_halign=textAlign == "Left" ? text.align_left : textAlign == "Center" ? text.align_center : text.align_right,
                         text_size=fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large))

                    newIMR.labels.push(box.new(
                         left=bar_index, top=levelBelow + 1,
                         right=bar_index, bottom=levelBelow,
                         bgcolor=color.rgb(54, 58, 69, 70), border_color=na,
                         text=i == 6 ? "▲-100%    $" + str.tostring(math.round(open - averageRange, 0), '0,000') :
                              '-' + str.tostring(fibMultis.get(i)) + "%    $" + str.tostring(math.round(levelBelow, 0), '0,000'),
                         text_color=i == 6 ? HighLight : NormalColor,
                         text_valign=text.align_top,
                         text_halign=textAlign == "Left" ? text.align_left : textAlign == "Center" ? text.align_center : text.align_right,
                         text_size=fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large))

        collection.push(newIMR)

    if not na(newIMR)
        newIMR.extendLines()

    int maxMonths = displayMode == "This Month" ? 1 : displayMode == "Two Months" ? 2 : displayMode == "Quarter" ? 3 : 999
    if collection.size() > maxMonths and displayMode != "All"
        collection.get(0).deleteLines()
        collection.shift()

//--------------
// MAIN LOGIC — track monthly high/low and build average range
//--------------
if isFirstBarOfMonth
    monthRanges.push(monthHigh - monthLow)
    monthHigh := high
    monthLow  := low

    if monthRanges.size() > months
        monthRanges.shift()

    averageRange := array.avg(monthRanges)

drawLines(collection, averageRange, tfp)

monthHigh := high > monthHigh ? high : monthHigh
monthLow  := low  < monthLow  ? low  : monthLow
````
