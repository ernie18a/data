# CQ_(0-3)_Fibonacci All Ranges Suite v1

- url: https://www.tradingview.com/script/9te0DMgx-CQ-0-3-Fibonacci-All-Ranges-Suite-v1/
- type: indicator
- pine_id: PUB;3b3aa3fcfb97468fa4674db2f877109b
- version: 4.0

## Description

================================================================================
  CQ_(0-3)_FIBONACCI ALL RANGES SUITE v1
  User Manual
  Author: CQuevedo345 / UkutaLabs
================================================================================

OVERVIEW
--------
This TradingView indicator draws Fibonacci extension levels and price-tendency
gauges for four timeframes simultaneously on a single overlay chart:

  - 4H       (4-hour)
  - IntraDay (daily)
  - IntraWeek (weekly)
  - IntraMonth (monthly)

Each section is independently configurable and can be enabled or disabled.
All sections share the same chart overlay, with horizontal offsets that keep
the labels and gauges visually separated to the right of the last bar.


REQUIREMENTS
------------
- Pine Script v6
- Indicator type: Overlay (drawn directly on the price chart)
- Works on any symbol and any intraday timeframe up to 4H
- The 4H section only appears on intraday timeframes (below daily)
- The IntraDay section appears on all timeframes except weekly and monthly
- The IntraWeek section appears on all timeframes except monthly
- The IntraMonth section appears on all timeframes


================================================================================
  SECTION 1 — ENABLE / DISABLE
================================================================================

Found under the group "═══ ENABLE SECTIONS ═══"

  Enable 4H Range          Toggle the entire 4H section on/off
  Enable IntraDay Range    Toggle the entire IntraDay section on/off
  Enable IntraWeek Range   Toggle the entire IntraWeek section on/off
  Enable IntraMonth Range  Toggle the entire IntraMonth section on/off

Disabling a section hides all its lines, labels, circles, and gauge.


================================================================================
  SECTION 2 — 4H RANGE
================================================================================

Group: "── 4H Range ──"

DISPLAY MODE
  Controls how many past 4H periods are shown simultaneously.

  Hidden      No 4H lines drawn at all
  This Bar    Only the current 4H bar's levels (default)
  2 Bars      Current + previous 4H bar
  6 Bars      Last 6 4H bars
  All         Every 4H bar in history (use with caution on long charts)

4H BARS TO AVERAGE RANGE  (default: 6)
  The number of past 4H bars used to calculate the average true range.
  This average range determines the width of the Fibonacci extension levels.
  Higher values smooth out the range; lower values make it more reactive.

SHOW LABELS  (default: on)
  Shows text labels at each Fibonacci level displaying the percentage
  and the projected price value.

FONT SIZE  (default: Small)
  Size of the label text. Options: Tiny / Small / Medium / Large

TEXT ALIGNMENT  (default: Right)
  Horizontal alignment of the label text within the label box.
  Options: Left / Center / Right

POSITION — HORIZONTAL OFFSET  (default: 19)
  How many bars to the right of the current bar the levels extend.
  Increase this value to push the label cluster further right.
  Range: 0–100

LINE WIDTH  (default: 1)
  Thickness of the Fibonacci level lines.

LINE STYLE  (default: Solid)
  Visual style of the lines. Options: Dashed / Solid / Dotted

SHOW CIRCLES AT LINE START  (default: on)
  Places a small dot (●) at the left edge of each Fibonacci line,
  marking the bar where the period began.

CIRCLE SIZE  (default: Small)
  Size of the circle markers. Options: Tiny / Small / Normal / Large


4H FIBONACCI LEVELS
  Group: "── 4H Fibonacci Levels ──"

  There are 11 Fibonacci levels, each with its own line color toggle:

  Level    Percentage    Default
  ------   ----------    -------
  0        15%           enabled
  1        25%           enabled
  2        40%           enabled
  3        50%           enabled
  4        60%           enabled
  5        75%           enabled
  6        100%          enabled  (main level, shown in Highlight Color)
  7        125%          disabled
  8        150%          disabled
  9        175%          disabled
  10       200%          disabled

  Each level draws two lines: one above the open (positive extension)
  and one below the open (negative extension).

  The 100% level uses the Highlight Color and is visually emphasized.
  All other enabled levels use their assigned Line Color at 45% transparency.

  Normal Color     Color used for the percentage text labels
  Highlight Color  Color used for the 100% level line and its label


4H GAUGE
  Group: "── 4H Gauge ──"

  Draw 4H Price Tendency Gauge  (default: on)
    Draws a two-part visual gauge to the right of the current bar showing
    how far price has moved relative to the 4H open.

  The gauge consists of:
    - A bullish box: from the 4H open up to the 4H high
    - A bearish box: from the 4H open down to the 4H low
    - A shaded price bar showing the current close relative to the open
    - A small white arrow (◀) at the open price
    - High and Low price labels
    - A P&L label showing the dollar move and % change from the open

  Gauge Bullish Background / Foreground
    Colors for the upper (bull) half of the gauge when price is above open.

  Gauge Bearish Background / Foreground
    Colors for the lower (bear) half of the gauge when price is below open.


================================================================================
  SECTION 3 — INTRADAY RANGE
================================================================================

Group: "── IntraDay Range ──"

All settings mirror the 4H section. Key differences:

DISPLAY MODE options:
  Hidden / Today / Two Days / Week / All

DAYS TO AVERAGE RANGE  (default: 1)
  Number of past daily bars used to calculate the average range.

POSITION — HORIZONTAL OFFSET  (default: 32)
  Set higher than the 4H offset (19) so the labels don't overlap.

OPEN TAG shown on chart: ⨁D


INTRADAY FIBONACCI LEVELS
  Group: "── IntraDay Fibonacci Levels ──"
  Same 11 levels as 4H. Default colors are in the blue/steel range.


INTRADAY GAUGE
  Group: "── IntraDay Gauge ──"
  Same gauge as 4H, but driven by the daily open, high, and low.


INTRADAY PRICE LABEL
  Group: "── IntraDay Price Label ──"

  Show Current Price Label  (default: on)
    Displays a live price label to the right of the chart showing the
    current close price. The label color changes dynamically:
      - Cyan/teal  when close is at or above the daily open
      - Orange/red when close is below the daily open

    A bracket decoration (⌜ ⌝ / ⌞ ⌟) frames the label.

  This label only appears on intraday charts at or below the 4H timeframe.

  Position — Horizontal Offset  (default: 10)
    Controls how far right the price label appears.


================================================================================
  SECTION 4 — INTRAWEEK RANGE
================================================================================

Group: "── IntraWeek Range ──"

All settings mirror the 4H section. Key differences:

DISPLAY MODE options:
  Hidden / This Week / Two Weeks / Month / All

WEEKS TO AVERAGE RANGE  (default: 4)
  Number of past weekly bars used to calculate the average range.

POSITION — HORIZONTAL OFFSET  (default: 45)
  Set higher than the IntraDay offset (32) so labels don't overlap.

CIRCLE SIZE default: Tiny (smaller than 4H and IntraDay to reduce clutter)

OPEN TAG shown on chart: ⨁W


INTRAWEEK FIBONACCI LEVELS
  Group: "── IntraWeek Fibonacci Levels ──"
  Same 11 levels. Default colors are in the amber/orange range.


INTRAWEEK GAUGE
  Group: "── IntraWeek Gauge ──"
  Gauge driven by the weekly open, high, and low.


================================================================================
  SECTION 5 — INTRAMONTH RANGE
================================================================================

Group: "── IntraMonth Range ──"

All settings mirror the 4H section. Key differences:

DISPLAY MODE options:
  Hidden / This Month / Two Months / Quarter / All

MONTHS TO AVERAGE RANGE  (default: 3)
  Number of past monthly bars used to calculate the average range.

POSITION — HORIZONTAL OFFSET  (default: 58)
  Set higher than the IntraWeek offset (45) so labels don't overlap.

CIRCLE SIZE default: Tiny

OPEN TAG shown on chart: ⨁M


INTRAMONTH FIBONACCI LEVELS
  Group: "── IntraMonth Fibonacci Levels ──"
  Same 11 levels. Default colors are in the blue range.


INTRAMONTH GAUGE
  Group: "── IntraMonth Gauge ──"
  Gauge driven by the monthly open, high, and low.


================================================================================
  HOW FIBONACCI LEVELS ARE CALCULATED
================================================================================

For each timeframe, the indicator:

  1. Tracks the highest high and lowest low seen during the previous period.
  2. Computes the true range: high - low.
  3. Averages this range over the configured lookback (e.g. last 4 weeks).
  4. At the start of each new period, uses the opening price as the anchor.
  5. Projects levels above and below the open using the average range
     multiplied by each Fibonacci percentage:

       Level price (above) = Open + (Avg Range × Percentage / 100)
       Level price (below) = Open - (Avg Range × Percentage / 100)

  The 100% level represents the full average range projection.
  The 50% level represents the midpoint.
  Levels above 100% (125%, 150%, etc.) are extension zones.


================================================================================
  GAUGE — DETAILED EXPLANATION
================================================================================

The gauge is a compact visual summary of the current bar's price action
relative to the timeframe's open. It is drawn to the right of the price bars
using a fixed horizontal offset.

  Bull Box (upper half)
    Spans from the timeframe open up to the timeframe high.
    Background fills with the bullish color.

  Bear Box (lower half)
    Spans from the timeframe open down to the timeframe low.
    Background fills with the bearish color.

  Price Bar (inner shaded box)
    Spans from the open to the current close.
    Color switches between bullish and bearish depending on whether
    close is above or below the open.

  Open Marker
    A white horizontal line (◀) marks the open price, spanning both boxes.

  High Label
    Shows the timeframe high price above the bull box.

  Low Label
    Shows the timeframe low price below the bear box.

  P&L Label
    Appears further right. Shows the dollar difference (close - open).
    Color matches the current price direction.
    Tooltip shows: % change, dollar change, and the open price.


================================================================================
  RECOMMENDED OFFSET SPACING
================================================================================

To prevent overlapping labels, keep the offsets in ascending order:

  4H offset           19  (or lower)
  IntraDay offset     32
  IntraWeek offset    45
  IntraMonth offset   58
  Price label offset  10  (independent, placed close to the last bar)

Each gauge is drawn at: section_offset - 6
So the 4H gauge appears at bar_index + 13, IntraDay at bar_index + 26, etc.

If you increase any offset, increase all subsequent offsets by the same amount
to maintain visual separation.


================================================================================
  TIMEFRAME COMPATIBILITY
================================================================================

  Chart Timeframe    4H    IntraDay    IntraWeek    IntraMonth
  ----------------   ---   --------    ---------    ----------
  1m – 3H            YES   YES         YES          YES
  4H                 YES   YES         YES          YES
  Daily              NO    YES         YES          YES
  Weekly             NO    NO          YES          YES
  Monthly            NO    NO          NO           YES

Note: The 4H section uses a period-change flag (ta.change of the 240-minute
timeframe). If the chart timeframe is daily or higher, the 4H open/high/low
values from request.security are still fetched but the 4H section drawing
is suppressed by the timeframe guard.


================================================================================
  KNOWN LIMITATIONS
================================================================================

- max_lines_count = 500 and max_boxes_count = 500.
  On charts with many historical bars and "All" display mode enabled for
  multiple sections, these limits may be reached and older objects will
  be automatically removed by TradingView.

- The price label (IntraDay section) only updates on intraday timeframes
  at or below 4H. On daily or higher charts it remains hidden.

- The average range is seeded from na on the very first bar of each period,
  so the first plotted Fibonacci set may show slightly incorrect levels.
  This corrects itself after one full period.

- All gauge objects are created once and repositioned every bar. On very
  slow machines or tablets, a brief rendering delay may be visible when
  scrolling historical data.


================================================================================
  TIPS
================================================================================

- If labels overlap with price bars, increase the horizontal offset for the
  affected section. Each offset unit equals one chart bar's width.

- To use only one section (e.g. daily only), disable the other three sections
  in the ENABLE SECTIONS group.

- The 100% Fibonacci level (the full average range) is the most significant
  level and is displayed in the Highlight Color to stand out.

- Setting "Days/Weeks/Months to Average Range" to 1 gives you a pure
  prior-period range rather than a smoothed average. Higher values reduce
  the effect of unusually large or small periods.

- The Filtered Short / Filtered Long signals use the lookback and strength
  parameters from the SHARED section and are designed to confirm entries
  after the WVF indicator fires (see the companion WVF indicator script).


================================================================================
  VERSION HISTORY
================================================================================

  v1   Initial merged release combining:
         CQ_(0) 4H Range
         CQ_(1) IntraDay Range
         CQ_(2) IntraWeek Range
         CQ_(3) IntraMonth Range
       into a single unified overlay indicator.

       Fixes applied vs. original separate scripts:
         - Gauge objects now use var + placeholder init to avoid duplication
         - Price label repositioned via bar_index math (removed broken
           rightbar() function that referenced undefined time_close)


================================================================================
  CREDITS
================================================================================

  Original concept: UkutaLabs — "Fibonacci IntraDay Range" by:   UkutaLabs
  Pine Script v6

================================================================================

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Based on "Fibonacci IntraDay Range [UkutaLabs]"
// Merged: CQ_(0) 4H + CQ_(1) IntraDay + CQ_(2) IntraWeek + CQ_(3) IntraMonth
// Author: CQuevedo345 / UkutaLabs
//@version=6
indicator("CQ_(1-4)_Fibonacci All Ranges Suite v1", overlay=true,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════════════════
// ── SECTION ENABLE / DISABLE ──────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
bool enable_4H = input.bool(true, "Enable 4H Range", group="═══ ENABLE SECTIONS ═══")
bool enable_Day = input.bool(true, "Enable IntraDay Range", group="═══ ENABLE SECTIONS ═══")
bool enable_Week = input.bool(true, "Enable IntraWeek Range", group="═══ ENABLE SECTIONS ═══")
bool enable_Month = input.bool(true, "Enable IntraMonth Range", group="═══ ENABLE SECTIONS ═══")

// ════════════════════════════════════════════════════════════════════════════════
// ── GAUGE DISPLAY SETTINGS ────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
bool gauge_showPercent = input.bool(true, "Show Percentage on Gauge Levels", group="── Gauge Levels ──", tooltip="Appends the % change from the period's open to the High/Low labels on every gauge (4H, Day, Week, Month).")
int GaugePos = input(8, "Left Separation from labels", group="── Gauge Levels ──", tooltip="Gauge eparation from Fibonacci Labels to the left on every gauge (4H, Day, Week, Month).")
int gauge_innerBoxOpacity = input.int(50, "Inner Price Box Opacity %", minval=0, maxval=100, group="── Gauge Levels ──", tooltip="Opacity of the small price box drawn inside the scope box on every gauge (4H/Day/Week/Month). 0 = fully transparent, 100 = fully opaque.")
int gauge_innerBoxTrans = 100 - gauge_innerBoxOpacity
int gauge_scopeBoxOpacity = input.int(25, "Scope Box Opacity %", minval=0, maxval=100, group="── Gauge Levels ──", tooltip="Opacity of the larger bull/bear scope box (High-to-Open and Open-to-Low background) on every gauge (4H/Day/Week/Month). 0 = fully transparent, 100 = fully opaque.")
int gauge_scopeBoxTrans = 100 - gauge_scopeBoxOpacity
int gauge_scopeBorderOpacity = input.int(90, "Scope Box Border Opacity %", minval=0, maxval=100, group="── Gauge Levels ──", tooltip="Opacity of the scope box border on every gauge (4H/Day/Week/Month). 0 = fully transparent, 100 = fully opaque.")
int gauge_scopeBorderTrans = 100 - gauge_scopeBorderOpacity
int gauge_innerBorderOpacity = input.int(90, "Inner Price Box Border Opacity %", minval=0, maxval=100, group="── Gauge Levels ──", tooltip="Opacity of the inner price box border on every gauge (4H/Day/Week/Month). 0 = fully transparent, 100 = fully opaque.")
int gauge_innerBorderTrans = 100 - gauge_innerBorderOpacity
int gauge_innerBoxBrightness = input.int(30, "Inner Box Brightness %", minval=0, maxval=100, group="── Gauge Levels ──", tooltip="Blends the inner price box's color toward white to improve visibility against the scope box on every gauge (4H/Day/Week/Month). 0 = no change, 100 = fully white.")
color gauge_priceLabelColor = input.color(color.white, "Gauge Price Label Color", group="── Gauge Levels ──", tooltip="Text color of the Open-price marker/label and the P&L label on every gauge (4H/Day/Week/Month).")
bool gauge_showPriceLabel = input.bool(true, "Show Gauge Price Label", group="── Gauge Levels ──", tooltip="Shows/hides the Open-price marker, Open-price text, and P&L label on every gauge (4H/Day/Week/Month).")
string gauge_priceLabelSide = input.string("Right", "Gauge Price Label Side", options=["Left","Right"], group="── Gauge Levels ──", tooltip="Which side of the gauge the Open-price marker/label and P&L label are drawn on.")
color gauge_scopeHighLabelColor = input.color(color.rgb(0,194,174), "Scope High Label Color", group="── Gauge Levels ──", tooltip="Text color of the High price label attached to the scope box on every gauge (4H/Day/Week/Month).")
color gauge_scopeLowLabelColor = input.color(color.rgb(255,153,0), "Scope Low Label Color", group="── Gauge Levels ──", tooltip="Text color of the Low price label attached to the scope box on every gauge (4H/Day/Week/Month).")
string gauge_widthMode = input.string("Original", "Gauge Width Mode", options=["Original", "Reduced (2 Bars)"], group="── Gauge Levels ──", tooltip="Original: scope boxes span 3 bars with the inner price box inset inside them (default). Reduced (2 Bars): scope boxes span 2 bars, and the inner price marker collapses to a centered bar drawn purely from the inner box's border. Applies to every gauge (4H/Day/Week/Month).")
int gauge_reducedBarWidth = input.int(3, "Reduced Mode Inner Bar Width", minval=1, maxval=10, group="── Gauge Levels ──", tooltip="Border thickness (in pixels) used to render the centered inner price bar when Gauge Width Mode is set to Reduced (2 Bars). Ignored in Original mode.")


// ════════════════════════════════════════════════════════════════════════════════
// ── GLOBAL LINE COLOR MODE ────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
string g_lineColorMode = input.string("Original", "Level Line Color Mode", options = ["Original", "Bull/Bear (Teal/Orange)"], group = "── Global Line Style ──", tooltip = "Original: each timeframe uses its own configured line colors.\nBull/Bear: all lines above open draw in teal, all lines below open draw in orange.")

// ════════════════════════════════════════════════════════════════════════════════
// ── GAUGE COLOR PALETTE ───────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
string palette = input.string("Custom", "Gauge Color Palette", options=["Custom", "Classic", "Ocean", "Sunset", "Neon", "Monochrome", "Desert", "Oldbook", "OldWest", "Vivid"], group="── Gauge Color Palette ──", tooltip="Custom: each gauge (4H/Day/Week/Month) uses its own Bullish/Bearish Background colors set below in its own Gauge group.\nAny other option: overrides every gauge's Bullish/Bearish Background with the selected palette's colors. Foreground colors and Custom's per-gauge inputs stay available/editable at all times.")

// === Palette Definitions ===
colorGreen = palette == "Classic" ? color.rgb(0, 57, 55) : palette == "Ocean" ? color.rgb(0, 54, 93) : palette == "Sunset" ? color.rgb(102, 61, 0) : palette == "Neon" ? color.rgb(0, 80, 145) : palette == "Monochrome" ? color.rgb(117, 117, 117) : palette == "Desert" ? color.rgb(0, 39, 35) : palette == "Oldbook" ? color.rgb(63, 73, 7) : palette == "OldWest" ? color.rgb(49, 49, 49) : color.rgb(0, 255, 191)
colorRed   = palette == "Classic" ? color.rgb(72, 0, 0)  : palette == "Ocean" ? color.rgb(0, 20, 85) : palette == "Sunset" ? color.rgb(35, 34, 32) : palette == "Neon" ? color.rgb(42, 45, 51) : palette == "Monochrome" ? color.rgb(65, 65, 65) : palette == "Desert" ? color.rgb(61, 37, 0) : palette == "Oldbook" ? color.rgb(49, 43, 5) : palette == "OldWest" ? color.rgb(49, 10, 0) : color.rgb(255, 0, 0, 100)

// ════════════════════════════════════════════════════════════════════════════════
// ── LAYOUT MODE ───────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
string layout_mode = input.string("Original", "Fib Levels & Gauges Layout", options=["Original", "Stacked (Levels then Gauges)"], group="── Layout Mode ──", tooltip="Original: each timeframe (4H/Day/Week/Month) keeps its own independently configured Position offset for both its fib levels and its gauge — the default spread-out layout. Stacked: all four timeframes' fib levels are drawn back-to-back first, starting at the 4H Position offset, followed by a gap of empty candle-spaces, then all four gauges drawn back-to-back.")
int stack_level_width = input.int(13, "Stacked Level Lane Width", minval=1, group="── Layout Mode ──", tooltip="Only used in Stacked mode. Horizontal spacing (in bars) between each consecutive timeframe's fib-level lane.")
int stack_gauge_width = input.int(15, "Stacked Gauge Lane Width", minval=1, group="── Layout Mode ──", tooltip="Only used in Stacked mode. Horizontal spacing (in bars) between each consecutive timeframe's gauge lane.")
int stack_gap = input.int(5, "Gap Between Levels and Gauges", minval=0, group="── Layout Mode ──", tooltip="Only used in Stacked mode. Number of empty candle-spaces left between the last fib-level lane and the first gauge lane.")

// ════════════════════════════════════════════════════════════════════════════════
// ── DYNAMIC LEVEL SHADING ──────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
bool dyn_shade_enable = input.bool(true, "Enable Dynamic Proximity Shading", group="── Dynamic Level Shading ──", tooltip="Fades each Fibonacci level's line and label based on how close that level is to the current price. The period's opening line/label always tracks the Nearest-Levels opacity below.")
int pct_near = input.int(100, "Nearest Levels Opacity %", minval=0, maxval=100, group="── Dynamic Level Shading ──", tooltip="Opacity used for the level immediately above the current price and the level immediately below it (also always applied to the period's opening line).")
int pct_mid = input.int(70, "Next Levels Opacity %", minval=0, maxval=100, group="── Dynamic Level Shading ──", tooltip="Opacity used for the second-nearest level above the current price and the second-nearest level below it.")
int pct_far = input.int(40, "Remaining Levels Opacity %", minval=0, maxval=100, group="── Dynamic Level Shading ──", tooltip="Opacity used for every other level, beyond the two nearest on each side of the current price.")

// ════════════════════════════════════════════════════════════════════════════════
// ── 4H RANGE SETTINGS ─────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
string h4_displayMode = input.string("This Bar", "Display Mode", options=["Hidden","This Bar","2 Bars","6 Bars","All"], group="── 4H Range ──")
int h4_bars = input.int(1, "4H Bars to Average Range", group="── 4H Range ──")
bool h4_showLabels = input.bool(true, "Show Labels", group="── 4H Range ──")
bool h4_showPercent = input.bool(true, "Show Percentage", group="── 4H Range ──", inline="h4_pp")
bool h4_showPrice = input.bool(true, "Show Price", group="── 4H Range ──", inline="h4_pp")
string h4_fontSize = input.string("Tiny", "Font Size", options=["Tiny","Small","Medium","Large"], group="── 4H Range ──")
string h4_textAlign = input.string("Right", "Text Alignment", options=["Left","Center","Right"], group="── 4H Range ──")
var h4_linesOffset = input.int(19, "Position (Horizontal Offset)", minval=0, maxval=100, group="── 4H Range ──")
int h4_lineWidth = input(1, "Line Width", group="── 4H Range ──")
string h4_lineStyle = input.string("Solid", "Line Style", options=["Dashed","Solid","Dotted"], group="── 4H Range ──")
bool h4_showCircles = input.bool(true, "Show Circles at Line Start", group="── 4H Range ──")
bool h4_showCirclesEnd = input.bool(true, "Show Circles at Line End", group="── 4H Range ──")
string h4_circleSize = input.string("Small", "Circle Size", options=["Tiny","Small","Normal","Large"], group="── 4H Range ──")

color h4_LC0 = input.color(color.rgb(165, 160, 95), "Line Color", group="── 4H Fibonacci Levels ──", inline="h4_0")
bool h4_SL0 = input.bool(true, "Enable (15%)", group="── 4H Fibonacci Levels ──", inline="h4_0")
color h4_LC1 = input.color(color.rgb(165, 160, 95), "Line Color", group="── 4H Fibonacci Levels ──", inline="h4_1")
bool h4_SL1 = input.bool(true, "Enable (25%)", group="── 4H Fibonacci Levels ──", inline="h4_1")
color h4_LC2 = input.color(color.rgb(165, 160, 95), "Line Color", group="── 4H Fibonacci Levels ──", inline="h4_2")
bool h4_SL2 = input.bool(true, "Enable (40%)", group="── 4H Fibonacci Levels ──", inline="h4_2")
color h4_LC3 = input.color(color.rgb(165, 160, 95), "Line Color", group="── 4H Fibonacci Levels ──", inline="h4_3")
bool h4_SL3 = input.bool(true, "Enable (50%)", group="── 4H Fibonacci Levels ──", inline="h4_3")
color h4_LC4 = input.color(color.rgb(165, 160, 95), "Line Color", group="── 4H Fibonacci Levels ──", inline="h4_4")
bool h4_SL4 = input.bool(true, "Enable (60%)", group="── 4H Fibonacci Levels ──", inline="h4_4")
color h4_LC5 = input.color(color.rgb(165, 160, 95), "Line Color", group="── 4H Fibonacci Levels ──", inline="h4_5")
bool h4_SL5 = input.bool(true, "Enable (75%)", group="── 4H Fibonacci Levels ──", inline="h4_5")
color h4_LC6 = input.color(color.rgb(165, 160, 95), "Line Color", group="── 4H Fibonacci Levels ──", inline="h4_6")
bool h4_SL6 = input.bool(true, "Enable (100%)", group="── 4H Fibonacci Levels ──", inline="h4_6")
color h4_LC7 = input.color(color.rgb(165, 160, 95), "Line Color", group="── 4H Fibonacci Levels ──", inline="h4_7")
bool h4_SL7 = input.bool(false, "Enable (125%)", group="── 4H Fibonacci Levels ──", inline="h4_7")
color h4_LC8 = input.color(color.rgb(165, 160, 95), "Line Color", group="── 4H Fibonacci Levels ──", inline="h4_8")
bool h4_SL8 = input.bool(false, "Enable (150%)", group="── 4H Fibonacci Levels ──", inline="h4_8")
color h4_LC9 = input.color(color.rgb(165, 160, 95), "Line Color", group="── 4H Fibonacci Levels ──", inline="h4_9")
bool h4_SL9 = input.bool(false, "Enable (175%)", group="── 4H Fibonacci Levels ──", inline="h4_9")
color h4_LC10 = input.color(color.rgb(165, 160, 95), "Line Color", group="── 4H Fibonacci Levels ──", inline="h4_10")
bool h4_SL10 = input.bool(false, "Enable (200%)", group="── 4H Fibonacci Levels ──", inline="h4_10")
color h4_NormalColor = input.color(color.rgb(165, 160, 95), "Normal Color", group="── 4H Fibonacci Levels ──")
color h4_HighLight = input.color(color.rgb(209, 203, 123), "Highlight Color", group="── 4H Fibonacci Levels ──")

bool h4_gauge_draw = input.bool(true, "Draw 4H Price Tendency Gauge", group="── 4H Gauge ──")
color h4_gauge_bull_bg = input.color(color.rgb(0,83,75), "Gauge Bullish Background", group="── 4H Gauge ──", inline="h4gb")
color h4_gauge_bull_fg = input.color(color.rgb(0,194,174), "Foreground", group="── 4H Gauge ──", inline="h4gb")
color h4_gauge_bear_bg = input.color(color.rgb(85,48,0), "Gauge Bearish Background", group="── 4H Gauge ──", inline="h4br")
color h4_gauge_bear_fg = input.color(color.rgb(255,153,0), "Foreground", group="── 4H Gauge ──", inline="h4br")

// ════════════════════════════════════════════════════════════════════════════════
// ── INTRADAY RANGE SETTINGS ───────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
string day_displayMode = input.string("Today", "Display Mode", options=["Hidden","Today","Two Days","Week","All"], group="── IntraDay Range ──")
int day_days = input.int(1, "Days to Average Range", group="── IntraDay Range ──")
bool day_showLabels = input.bool(true, "Show Labels", group="── IntraDay Range ──")
bool day_showPercent = input.bool(false, "Show Percentage", group="── IntraDay Range ──", inline="day_pp")
bool day_showPrice = input.bool(true, "Show Price", group="── IntraDay Range ──", inline="day_pp")
string day_fontSize = input.string("Small", "Font Size", options=["Tiny","Small","Medium","Large"], group="── IntraDay Range ──")
string day_textAlign = input.string("Right", "Text Alignment", options=["Left","Center","Right"], group="── IntraDay Range ──")
var day_linesOffset = input.int(32, "Position (Horizontal Offset)", minval=0, maxval=100, group="── IntraDay Range ──")
int day_lineWidth = input(1, "Line Width", group="── IntraDay Range ──")
string day_lineStyle = input.string("Solid", "Line Style", options=["Dashed","Solid","Dotted"], group="── IntraDay Range ──")
bool day_showCircles = input.bool(true, "Show Circles at Line Start", group="── IntraDay Range ──")
bool day_showCirclesEnd = input.bool(true, "Show Circles at Line End", group="── IntraDay Range ──")
string day_circleSize = input.string("Tiny", "Circle Size", options=["Tiny","Small","Normal","Large"], group="── IntraDay Range ──")

color day_LC0 = input.color(color.rgb(100, 147, 165), "Line Color", group="── IntraDay Fibonacci Levels ──", inline="d0")
bool day_SL0 = input.bool(true, "Enable (15%)", group="── IntraDay Fibonacci Levels ──", inline="d0")
color day_LC1 = input.color(color.rgb(100, 147, 165), "Line Color", group="── IntraDay Fibonacci Levels ──", inline="d1")
bool day_SL1 = input.bool(true, "Enable (25%)", group="── IntraDay Fibonacci Levels ──", inline="d1")
color day_LC2 = input.color(color.rgb(100, 147, 165), "Line Color", group="── IntraDay Fibonacci Levels ──", inline="d2")
bool day_SL2 = input.bool(true, "Enable (40%)", group="── IntraDay Fibonacci Levels ──", inline="d2")
color day_LC3 = input.color(color.rgb(100, 147, 165), "Line Color", group="── IntraDay Fibonacci Levels ──", inline="d3")
bool day_SL3 = input.bool(true, "Enable (50%)", group="── IntraDay Fibonacci Levels ──", inline="d3")
color day_LC4 = input.color(color.rgb(100, 147, 165), "Line Color", group="── IntraDay Fibonacci Levels ──", inline="d4")
bool day_SL4 = input.bool(true, "Enable (60%)", group="── IntraDay Fibonacci Levels ──", inline="d4")
color day_LC5 = input.color(color.rgb(100, 147, 165), "Line Color", group="── IntraDay Fibonacci Levels ──", inline="d5")
bool day_SL5 = input.bool(true, "Enable (75%)", group="── IntraDay Fibonacci Levels ──", inline="d5")
color day_LC6 = input.color(color.rgb(100, 147, 165), "Line Color", group="── IntraDay Fibonacci Levels ──", inline="d6")
bool day_SL6 = input.bool(true, "Enable (100%)", group="── IntraDay Fibonacci Levels ──", inline="d6")
color day_LC7 = input.color(color.rgb(100, 147, 165), "Line Color", group="── IntraDay Fibonacci Levels ──", inline="d7")
bool day_SL7 = input.bool(false, "Enable (125%)", group="── IntraDay Fibonacci Levels ──", inline="d7")
color day_LC8 = input.color(color.rgb(100, 147, 165), "Line Color", group="── IntraDay Fibonacci Levels ──", inline="d8")
bool day_SL8 = input.bool(false, "Enable (150%)", group="── IntraDay Fibonacci Levels ──", inline="d8")
color day_LC9 = input.color(color.rgb(100, 147, 165), "Line Color", group="── IntraDay Fibonacci Levels ──", inline="d9")
bool day_SL9 = input.bool(false, "Enable (175%)", group="── IntraDay Fibonacci Levels ──", inline="d9")
color day_LC10 = input.color(color.rgb(100, 147, 165), "Line Color", group="── IntraDay Fibonacci Levels ──", inline="d10")
bool day_SL10 = input.bool(false, "Enable (200%)", group="── IntraDay Fibonacci Levels ──", inline="d10")
color day_NormalColor = input.color(color.rgb(100, 147, 165), "Normal Color", group="── IntraDay Fibonacci Levels ──")
color day_HighLight = input.color(color.rgb(154, 226, 255), "Highlight Color", group="── IntraDay Fibonacci Levels ──")

bool day_gauge_draw = input.bool(true, "Draw IntraDay Price Tendency Gauge", group="── IntraDay Gauge ──")
color day_gauge_bull_bg = input.color(color.rgb(0,83,75), "Gauge Bullish Background", group="── IntraDay Gauge ──", inline="dgb")
color day_gauge_bull_fg = input.color(color.rgb(0,194,174), "Foreground", group="── IntraDay Gauge ──", inline="dgb")
color day_gauge_bear_bg = input.color(color.rgb(85,48,0), "Gauge Bearish Background", group="── IntraDay Gauge ──", inline="dbr")
color day_gauge_bear_fg = input.color(color.rgb(255,153,0), "Foreground", group="── IntraDay Gauge ──", inline="dbr")

var day_showPriceLabel = input.bool(true, "Show Current Price Label", group="── IntraDay Price Label ──")
var day_priceOffset = input.int(10, "Position (Horizontal Offset)", minval=1, maxval=100, group="── IntraDay Price Label ──")

// ════════════════════════════════════════════════════════════════════════════════
// ── INTRAWEEK RANGE SETTINGS ──────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
string wk_displayMode = input.string("This Week", "Display Mode", options=["Hidden","This Week","Two Weeks","Month","All"], group="── IntraWeek Range ──")
int wk_weeks = input.int(1, "Weeks to Average Range", group="── IntraWeek Range ──")
bool wk_showLabels = input.bool(true, "Show Labels", group="── IntraWeek Range ──")
bool wk_showPercent = input.bool(false, "Show Percentage", group="── IntraWeek Range ──", inline="wk_pp")
bool wk_showPrice = input.bool(true, "Show Price", group="── IntraWeek Range ──", inline="wk_pp")
string wk_fontSize = input.string("Small", "Font Size", options=["Tiny","Small","Medium","Large"], group="── IntraWeek Range ──")
string wk_textAlign = input.string("Right", "Text Alignment", options=["Left","Center","Right"], group="── IntraWeek Range ──")
var wk_linesOffset = input.int(45, "Position (Horizontal Offset)", minval=0, maxval=100, group="── IntraWeek Range ──")
int wk_lineWidth = input(1, "Line Width", group="── IntraWeek Range ──")
string wk_lineStyle = input.string("Solid", "Line Style", options=["Dashed","Solid","Dotted"], group="── IntraWeek Range ──")
bool wk_showCircles = input.bool(true, "Show Circles at Line Start", group="── IntraWeek Range ──")
bool wk_showCirclesEnd = input.bool(true, "Show Circles at Line End", group="── IntraWeek Range ──")
string wk_circleSize = input.string("Tiny", "Circle Size", options=["Tiny","Small","Normal","Large"], group="── IntraWeek Range ──")

color wk_LC0 = input.color(color.rgb(23, 143, 173), "Line Color", group="── IntraWeek Fibonacci Levels ──", inline="w0")
bool wk_SL0 = input.bool(true, "Enable (15%)", group="── IntraWeek Fibonacci Levels ──", inline="w0")
color wk_LC1 = input.color(color.rgb(23, 143, 173), "Line Color", group="── IntraWeek Fibonacci Levels ──", inline="w1")
bool wk_SL1 = input.bool(true, "Enable (25%)", group="── IntraWeek Fibonacci Levels ──", inline="w1")
color wk_LC2 = input.color(color.rgb(23, 143, 173), "Line Color", group="── IntraWeek Fibonacci Levels ──", inline="w2")
bool wk_SL2 = input.bool(true, "Enable (40%)", group="── IntraWeek Fibonacci Levels ──", inline="w2")
color wk_LC3 = input.color(color.rgb(23, 143, 173), "Line Color", group="── IntraWeek Fibonacci Levels ──", inline="w3")
bool wk_SL3 = input.bool(true, "Enable (50%)", group="── IntraWeek Fibonacci Levels ──", inline="w3")
color wk_LC4 = input.color(color.rgb(23, 143, 173), "Line Color", group="── IntraWeek Fibonacci Levels ──", inline="w4")
bool wk_SL4 = input.bool(true, "Enable (60%)", group="── IntraWeek Fibonacci Levels ──", inline="w4")
color wk_LC5 = input.color(color.rgb(23, 143, 173), "Line Color", group="── IntraWeek Fibonacci Levels ──", inline="w5")
bool wk_SL5 = input.bool(true, "Enable (75%)", group="── IntraWeek Fibonacci Levels ──", inline="w5")
color wk_LC6 = input.color(color.rgb(23, 143, 173), "Line Color", group="── IntraWeek Fibonacci Levels ──", inline="w6")
bool wk_SL6 = input.bool(true, "Enable (100%)", group="── IntraWeek Fibonacci Levels ──", inline="w6")
color wk_LC7 = input.color(color.rgb(23, 143, 173), "Line Color", group="── IntraWeek Fibonacci Levels ──", inline="w7")
bool wk_SL7 = input.bool(false, "Enable (125%)", group="── IntraWeek Fibonacci Levels ──", inline="w7")
color wk_LC8 = input.color(color.rgb(23, 143, 173), "Line Color", group="── IntraWeek Fibonacci Levels ──", inline="w8")
bool wk_SL8 = input.bool(false, "Enable (150%)", group="── IntraWeek Fibonacci Levels ──", inline="w8")
color wk_LC9 = input.color(color.rgb(23, 143, 173), "Line Color", group="── IntraWeek Fibonacci Levels ──", inline="w9")
bool wk_SL9 = input.bool(false, "Enable (175%)", group="── IntraWeek Fibonacci Levels ──", inline="w9")
color wk_LC10 = input.color(color.rgb(23, 143, 173), "Line Color", group="── IntraWeek Fibonacci Levels ──", inline="w10")
bool wk_SL10 = input.bool(false, "Enable (200%)", group="── IntraWeek Fibonacci Levels ──", inline="w10")
color wk_NormalColor = input.color(color.rgb(23, 143, 173), "Normal Color", group="── IntraWeek Fibonacci Levels ──")
color wk_HighLight = input.color(color.rgb(58, 206, 243), "Highlight Color", group="── IntraWeek Fibonacci Levels ──")

bool wk_gauge_draw = input.bool(true, "Draw IntraWeek Price Tendency Gauge", group="── IntraWeek Gauge ──")
color wk_gauge_bull_bg = input.color(color.rgb(0,83,75), "Gauge Bullish Background", group="── IntraWeek Gauge ──", inline="wgb")
color wk_gauge_bull_fg = input.color(color.rgb(0,194,174), "Foreground", group="── IntraWeek Gauge ──", inline="wgb")
color wk_gauge_bear_bg = input.color(color.rgb(85,48,0), "Gauge Bearish Background", group="── IntraWeek Gauge ──", inline="wbr")
color wk_gauge_bear_fg = input.color(color.rgb(255,153,0), "Foreground", group="── IntraWeek Gauge ──", inline="wbr")

// ════════════════════════════════════════════════════════════════════════════════
// ── INTRAMONTH RANGE SETTINGS ─────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
string mo_displayMode = input.string("This Month", "Display Mode", options=["Hidden","This Month","Two Months","Quarter","All"], group="── IntraMonth Range ──")
int mo_months = input.int(1, "Months to Average Range", group="── IntraMonth Range ──")
bool mo_showLabels = input.bool(true, "Show Labels", group="── IntraMonth Range ──")
bool mo_showPercent = input.bool(false, "Show Percentage", group="── IntraMonth Range ──", inline="mo_pp")
bool mo_showPrice = input.bool(true, "Show Price", group="── IntraMonth Range ──", inline="mo_pp")
string mo_fontSize = input.string("Small", "Font Size", options=["Tiny","Small","Medium","Large"], group="── IntraMonth Range ──")
string mo_textAlign = input.string("Right", "Text Alignment", options=["Left","Center","Right"], group="── IntraMonth Range ──")
var mo_linesOffset = input.int(58, "Position (Horizontal Offset)", minval=0, maxval=100, group="── IntraMonth Range ──")
int mo_lineWidth = input(1, "Line Width", group="── IntraMonth Range ──")
string mo_lineStyle = input.string("Solid", "Line Style", options=["Dashed","Solid","Dotted"], group="── IntraMonth Range ──")
bool mo_showCircles = input.bool(true, "Show Circles at Line Start", group="── IntraMonth Range ──")
bool mo_showCirclesEnd = input.bool(true, "Show Circles at Line End", group="── IntraMonth Range ──")
string mo_circleSize = input.string("Tiny", "Circle Size", options=["Tiny","Small","Normal","Large"], group="── IntraMonth Range ──")

color mo_LC0 = input.color(color.rgb(27, 102, 173), "Line Color", group="── IntraMonth Fibonacci Levels ──", inline="m0")
bool mo_SL0 = input.bool(true, "Enable (15%)", group="── IntraMonth Fibonacci Levels ──", inline="m0")
color mo_LC1 = input.color(color.rgb(27, 102, 173), "Line Color", group="── IntraMonth Fibonacci Levels ──", inline="m1")
bool mo_SL1 = input.bool(true, "Enable (25%)", group="── IntraMonth Fibonacci Levels ──", inline="m1")
color mo_LC2 = input.color(color.rgb(27, 102, 173), "Line Color", group="── IntraMonth Fibonacci Levels ──", inline="m2")
bool mo_SL2 = input.bool(true, "Enable (40%)", group="── IntraMonth Fibonacci Levels ──", inline="m2")
color mo_LC3 = input.color(color.rgb(27, 102, 173), "Line Color", group="── IntraMonth Fibonacci Levels ──", inline="m3")
bool mo_SL3 = input.bool(true, "Enable (50%)", group="── IntraMonth Fibonacci Levels ──", inline="m3")
color mo_LC4 = input.color(color.rgb(27, 102, 173), "Line Color", group="── IntraMonth Fibonacci Levels ──", inline="m4")
bool mo_SL4 = input.bool(true, "Enable (60%)", group="── IntraMonth Fibonacci Levels ──", inline="m4")
color mo_LC5 = input.color(color.rgb(27, 102, 173), "Line Color", group="── IntraMonth Fibonacci Levels ──", inline="m5")
bool mo_SL5 = input.bool(true, "Enable (75%)", group="── IntraMonth Fibonacci Levels ──", inline="m5")
color mo_LC6 = input.color(color.rgb(27, 102, 173), "Line Color", group="── IntraMonth Fibonacci Levels ──", inline="m6")
bool mo_SL6 = input.bool(true, "Enable (100%)", group="── IntraMonth Fibonacci Levels ──", inline="m6")
color mo_LC7 = input.color(color.rgb(27, 102, 173), "Line Color", group="── IntraMonth Fibonacci Levels ──", inline="m7")
bool mo_SL7 = input.bool(false, "Enable (125%)", group="── IntraMonth Fibonacci Levels ──", inline="m7")
color mo_LC8 = input.color(color.rgb(27, 102, 173), "Line Color", group="── IntraMonth Fibonacci Levels ──", inline="m8")
bool mo_SL8 = input.bool(false, "Enable (150%)", group="── IntraMonth Fibonacci Levels ──", inline="m8")
color mo_LC9 = input.color(color.rgb(27, 102, 173), "Line Color", group="── IntraMonth Fibonacci Levels ──", inline="m9")
bool mo_SL9 = input.bool(false, "Enable (175%)", group="── IntraMonth Fibonacci Levels ──", inline="m9")
color mo_LC10 = input.color(color.rgb(27, 102, 173), "Line Color", group="── IntraMonth Fibonacci Levels ──", inline="m10")
bool mo_SL10 = input.bool(false, "Enable (200%)", group="── IntraMonth Fibonacci Levels ──", inline="m10")
color mo_NormalColor = input.color(color.rgb(27, 102, 173), "Normal Color", group="── IntraMonth Fibonacci Levels ──")
color mo_HighLight = input.color(color.rgb(54, 143, 226), "Highlight Color", group="── IntraMonth Fibonacci Levels ──")

bool mo_gauge_draw = input.bool(true, "Draw IntraMonth Price Tendency Gauge", group="── IntraMonth Gauge ──")
color mo_gauge_bull_bg = input.color(color.rgb(0,83,75), "Gauge Bullish Background", group="── IntraMonth Gauge ──", inline="mgb")
color mo_gauge_bull_fg = input.color(color.rgb(0,194,174), "Foreground", group="── IntraMonth Gauge ──", inline="mgb")
color mo_gauge_bear_bg = input.color(color.rgb(85,48,0), "Gauge Bearish Background", group="── IntraMonth Gauge ──", inline="mbr")
color mo_gauge_bear_fg = input.color(color.rgb(255,153,0), "Foreground", group="── IntraMonth Gauge ──", inline="mbr")

// ════════════════════════════════════════════════════════════════════════════════
// ── TIMEFRAME GUARDS ──────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
bool tf_4H    = timeframe.isintraday
bool tf_Day   = not timeframe.isweekly and not timeframe.ismonthly
bool tf_Week  = not timeframe.ismonthly
bool tf_Month = true

// ════════════════════════════════════════════════════════════════════════════════
// ── EFFECTIVE GAUGE COLORS (Palette override) ─────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
// When palette == "Custom", each gauge keeps using its own Bullish/Bearish
// Background inputs from its own Gauge group above (fully editable at all times).
// Any other palette overrides every gauge's Bullish/Bearish Background with the
// selected palette's colorGreen/colorRed. Foreground colors are never touched by
// the palette and stay independently editable per gauge.
bool useCustomGaugeColors = palette == "Custom"

h4_finalBullBg  = useCustomGaugeColors ? h4_gauge_bull_bg  : colorGreen
h4_finalBearBg  = useCustomGaugeColors ? h4_gauge_bear_bg  : colorRed
day_finalBullBg = useCustomGaugeColors ? day_gauge_bull_bg : colorGreen
day_finalBearBg = useCustomGaugeColors ? day_gauge_bear_bg : colorRed
wk_finalBullBg  = useCustomGaugeColors ? wk_gauge_bull_bg  : colorGreen
wk_finalBearBg  = useCustomGaugeColors ? wk_gauge_bear_bg  : colorRed
mo_finalBullBg  = useCustomGaugeColors ? mo_gauge_bull_bg  : colorGreen
mo_finalBearBg  = useCustomGaugeColors ? mo_gauge_bear_bg  : colorRed

// ════════════════════════════════════════════════════════════════════════════════
// ── STACKED LAYOUT OFFSETS ────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
// "Original": each timeframe keeps its own independently configured Position
// offset for both its fib levels and its gauge (today's behavior, unchanged).
// "Stacked": the four timeframes' fib levels are drawn back-to-back first —
// 4H at its own Position offset, then Day/Week/Month each stack_level_width
// bars further out — followed by a stack_gap-bar empty space, then all four
// gauges drawn back-to-back (each stack_gauge_width bars apart), in the same
// 4H → Day → Week → Month order.
bool useStackedLayout = layout_mode == "Stacked (Levels then Gauges)"

h4_lvlOffset  = h4_linesOffset
day_lvlOffset = useStackedLayout ? h4_linesOffset + stack_level_width * 1 : day_linesOffset
wk_lvlOffset  = useStackedLayout ? h4_linesOffset + stack_level_width * 2 : wk_linesOffset
mo_lvlOffset  = useStackedLayout ? h4_linesOffset + stack_level_width * 3 : mo_linesOffset

stackGaugeBase = h4_linesOffset + stack_level_width * 4 + stack_gap
h4_gaugeBase  = useStackedLayout ? stackGaugeBase                        : h4_linesOffset
day_gaugeBase = useStackedLayout ? stackGaugeBase + stack_gauge_width * 1 : day_linesOffset
wk_gaugeBase  = useStackedLayout ? stackGaugeBase + stack_gauge_width * 2 : wk_linesOffset
mo_gaugeBase  = useStackedLayout ? stackGaugeBase + stack_gauge_width * 3 : mo_linesOffset

// ════════════════════════════════════════════════════════════════════════════════
// ── SHARED HELPERS ────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
f_circleSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

f_fontSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Medium" ? size.normal : size.large

f_lineStyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_textAlign(string s) =>
    s == "Left" ? text.align_left : s == "Center" ? text.align_center : text.align_right

// Blend a color toward white to make it appear brighter, preserving its base hue.
f_brighten(color c, float amt) =>
    int r = int(math.round(color.r(c) + (255 - color.r(c)) * amt))
    int g = int(math.round(color.g(c) + (255 - color.g(c)) * amt))
    int b = int(math.round(color.b(c) + (255 - color.b(c)) * amt))
    color.new(color.rgb(r, g, b), color.t(c))

// Blend a color toward black to make it appear dimmer, preserving its base hue.
f_darken(color c, float amt) =>
    int r = int(math.round(color.r(c) * (1 - amt)))
    int g = int(math.round(color.g(c) * (1 - amt)))
    int b = int(math.round(color.b(c) * (1 - amt)))
    color.new(color.rgb(r, g, b), color.t(c))

// Maps a proximity rank (0 = nearest to current price) to its configured opacity %.
f_bucketPct(int rank, float pctNear, float pctMid, float pctFar) =>
    rank == 0 ? pctNear : rank == 1 ? pctMid : pctFar

// ════════════════════════════════════════════════════════════════════════════════
// ── SHARED FIB MULTIPLES ──────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
var fibMultis = array.from(15, 25, 40, 50, 60, 75, 100, 125, 150, 175, 200)

// ════════════════════════════════════════════════════════════════════════════════
// ── SECURITY DATA ─────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
h4_open    = request.security(syminfo.tickerid, "240", open,  lookahead=barmerge.lookahead_on)
h4_high    = request.security(syminfo.tickerid, "240", high,  lookahead=barmerge.lookahead_on)
h4_low     = request.security(syminfo.tickerid, "240", low,   lookahead=barmerge.lookahead_on)

daily_open  = request.security(syminfo.tickerid, "D", open,  lookahead=barmerge.lookahead_on)
daily_high  = request.security(syminfo.tickerid, "D", high,  lookahead=barmerge.lookahead_on)
daily_low   = request.security(syminfo.tickerid, "D", low,   lookahead=barmerge.lookahead_on)

weekly_open  = request.security(syminfo.tickerid, "W", open,  lookahead=barmerge.lookahead_on)
weekly_high  = request.security(syminfo.tickerid, "W", high,  lookahead=barmerge.lookahead_on)
weekly_low   = request.security(syminfo.tickerid, "W", low,   lookahead=barmerge.lookahead_on)

monthly_open  = request.security(syminfo.tickerid, "M", open,  lookahead=barmerge.lookahead_on)
monthly_high  = request.security(syminfo.tickerid, "M", high,  lookahead=barmerge.lookahead_on)
monthly_low   = request.security(syminfo.tickerid, "M", low,   lookahead=barmerge.lookahead_on)

// ── Period-change flags ───────────────────────────────────────────────────────
isFirst4HBar    = ta.change(time("240")) != 0
isFirstDayBar   = session.isfirstbar
isFirstWeekBar  = timeframe.change("W")
isFirstMonthBar = timeframe.change("M")

// ════════════════════════════════════════════════════════════════════════════════
// ── GAUGE DRAWING PROCEDURE ───────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
drawGauge(
     int    gOffset,
     float  refOpen,  float  refHigh,  float  refLow,
     color  bullBg,   color  bullFg,
     color  bearBg,   color  bearFg,
     string labelTxt,
     bool   showPercent,
     int    innerBoxTrans,
     int    scopeBoxTrans,
     int    scopeBorderTrans,
     int    innerBorderTrans,
     color  priceLabelColor,
     color  scopeHighLabelColor,
     color  scopeLowLabelColor,
     bool   showPriceLabel,
     string priceLabelSide,
     int    innerBrightness,
     bool   reducedWidth,
     int    reducedBarWidth) =>

    isAbove = close >= refOpen
    dynCol  = isAbove ? bullFg : bearFg
    dynBg   = isAbove ? bullBg : bearBg
    innerDynBg = innerBrightness > 0 ? f_brighten(dynBg, innerBrightness / 100.0) : dynBg

    var box  g_bull_scope = box.new(0, open, 0, open,
         border_color=color.new(bullBg, scopeBorderTrans), border_width=1,
         border_style=line.style_dotted,
         text=labelTxt, text_valign=text.align_top, text_size=size.tiny,
         text_color=color.white, bgcolor=color.new(bullBg, scopeBoxTrans))
    var line g_bull_top   = line.new(0, open, 0, open, color=bullFg, width=2)
    var line g_bull_base  = line.new(0, open, 0, open, color=bullBg, width=3)
    var box  g_bull_prc   = box.new(0, open, 0, open,
         border_color=color.new(bullBg, innerBorderTrans), border_width=1,
         bgcolor=color.new(innerDynBg, innerBoxTrans))
    var line g_bull_prc_l = line.new(0, open, 0, open, color=bullBg, width=4)

    var box  g_bear_scope = box.new(0, open, 0, open,
         border_color=color.new(bearBg, scopeBorderTrans), border_width=1,
         border_style=line.style_dotted,
         text=labelTxt, text_valign=text.align_bottom, text_size=size.tiny,
         text_color=color.white, bgcolor=color.new(bearBg, scopeBoxTrans))
    var line g_bear_top   = line.new(0, open, 0, open, color=bullBg, width=3)
    var line g_bear_base  = line.new(0, open, 0, open, color=bearFg, width=2)
    var box  g_bear_prc   = box.new(0, open, 0, open,
         border_color=color.new(bullBg, innerBorderTrans), border_width=1,
         bgcolor=color.new(innerDynBg, innerBoxTrans))
    var line g_bear_prc_l = line.new(0, open, 0, open, color=dynCol, width=4)

    var line  g_open_mk  = line.new(0, open, 0, open,
         color=color.white, width=3, style=line.style_solid)
    var label g_open_lbl = label.new(0, open,
         text="◀", style=label.style_label_left,
         color=color.new(color.black, 100), textcolor=priceLabelColor, size=size.small)
    var label g_open_price_lbl = label.new(0, open,
         text="", style=label.style_label_right, textalign=text.align_left,
         color=color.new(color.black, 100), textcolor=priceLabelColor, size=size.small)

    var label g_high_lbl = label.new(0, open,
         text="", style=label.style_label_down,
         color=color.new(bullBg, 80), textcolor=scopeHighLabelColor, size=size.small)
    var label g_low_lbl  = label.new(0, open,
         text="", style=label.style_label_up,
         color=color.new(bearBg, 80), textcolor=scopeLowLabelColor, size=size.small)

    var int   y_adj     = 1
    var label g_pnl_lbl = label.new(0, open,
         text="", style=label.style_label_right, textalign=text.align_left,
         color=color.new(dynCol, 100), textcolor=priceLabelColor, size=size.small)

    // Scope box: 3-bar span in Original mode, 2-bar span in Reduced mode (both
    // centered on the same gOffset anchor so switching modes doesn't shift the
    // gauge's overall position). Inner price marker: inset 1-bar box in
    // Original mode; collapses to a single x-coordinate (left == right) in
    // Reduced mode, so it renders purely as a centered bar drawn from its own
    // border thickness (reducedBarWidth) rather than as a filled box.
    int L = reducedWidth ? bar_index + gOffset - 1 : bar_index + gOffset - 2
    int R = bar_index + gOffset + 1
    int l = reducedWidth ? bar_index + gOffset     : bar_index + gOffset - 1
    int r = reducedWidth ? bar_index + gOffset     : bar_index + gOffset
    int innerBorderW = reducedWidth ? reducedBarWidth : 1

    box.set_lefttop    (g_bull_scope, L, refHigh)
    box.set_rightbottom(g_bull_scope, R, refOpen)
    line.set_xy1(g_bull_top,  L, refHigh)
    line.set_xy2(g_bull_top,  R, refHigh)
    line.set_xy1(g_bull_base, L, refOpen)
    line.set_xy2(g_bull_base, R, refOpen)
    box.set_lefttop    (g_bull_prc, l, close)
    box.set_rightbottom(g_bull_prc, r, refOpen)
    box.set_bgcolor    (g_bull_prc, color.new(innerDynBg, innerBoxTrans))
    box.set_border_color(g_bull_prc, color.new(dynBg, innerBorderTrans))
    box.set_border_width(g_bull_prc, innerBorderW)
    line.set_xy1(g_bull_prc_l, l, close)
    line.set_xy2(g_bull_prc_l, r, close)
    line.set_color(g_bull_prc_l, bullBg)

    box.set_lefttop    (g_bear_scope, L, refOpen)
    box.set_rightbottom(g_bear_scope, R, refLow)
    line.set_xy1(g_bear_top,  L, refOpen)
    line.set_xy2(g_bear_top,  R, refOpen)
    line.set_xy1(g_bear_base, L, refLow)
    line.set_xy2(g_bear_base, R, refLow)
    box.set_lefttop    (g_bear_prc, l, close)
    box.set_rightbottom(g_bear_prc, r, refOpen)
    box.set_bgcolor    (g_bear_prc, color.new(innerDynBg, innerBoxTrans))
    box.set_border_color(g_bear_prc, color.new(dynBg, innerBorderTrans))
    box.set_border_width(g_bear_prc, innerBorderW)
    line.set_xy1(g_bear_prc_l, l, close)
    line.set_xy2(g_bear_prc_l, r, close)
    line.set_color(g_bear_prc_l, dynCol)

    line.set_xy1(g_open_mk, L, refOpen)
    line.set_xy2(g_open_mk, R, refOpen)

    int priceLblX = priceLabelSide == "Left" ? l : r
    if showPriceLabel
        label.set_xy(g_open_lbl, priceLblX, refOpen)
        label.set_text(g_open_lbl, "◂")
        label.set_textalign(g_open_lbl, text.align_left)
    else
        label.set_text(g_open_lbl, "")

    string openPriceTxt = str.tostring(math.round(refOpen, 0), "$0,000")
    if showPriceLabel
        label.set_xy       (g_open_price_lbl, priceLblX, refOpen)
        label.set_text     (g_open_price_lbl, openPriceTxt)
        label.set_tooltip  (g_open_price_lbl, labelTxt + " Open: " + openPriceTxt)
    else
        label.set_text     (g_open_price_lbl, "")

    float pctHigh = refOpen != 0 ? (refHigh - refOpen) / refOpen * 100 : 0
    float pctLow  = refOpen != 0 ? (refLow  - refOpen) / refOpen * 100 : 0

    string highTxt = str.tostring(math.round(refHigh, 0), "$0,000")
         + (showPercent ? "\n(" + (pctHigh >= 0 ? "+" : "") + str.tostring(math.round(pctHigh, 2)) + "%)" : "")
    string lowTxt  = str.tostring(math.round(refLow, 0), "$0,000")
         + (showPercent ? "\n(" + (pctLow >= 0 ? "+" : "") + str.tostring(math.round(pctLow, 2)) + "%)" : "")

    label.set_xy  (g_high_lbl, l, refHigh)
    label.set_text(g_high_lbl, highTxt)
    label.set_color(g_high_lbl, color.new(bullBg, 80))
    label.set_xy  (g_low_lbl,  l, refLow)
    label.set_text(g_low_lbl,  lowTxt)
    label.set_color(g_low_lbl, color.new(bearBg, 80))

    y_adj := close - refOpen < 0 ? -1 : 1
    int pnlX = priceLabelSide == "Left" ? bar_index + gOffset - 10 : bar_index + gOffset + 10
    if showPriceLabel
        label.set_xy      (g_pnl_lbl, pnlX, close + y_adj)
        label.set_text    (g_pnl_lbl, str.tostring(math.round(close - refOpen, 0), "$#,000"))
        label.set_tooltip (g_pnl_lbl,
             str.tostring(((close - refOpen) / refOpen) * 100, format.percent) + "  " +
             str.tostring(math.round(close - refOpen, 0), "$#,000") +
             "  from " + labelTxt + " Open: " +
             str.tostring(math.round(refOpen, 0), "$0,000"))
        label.set_color   (g_pnl_lbl, color.new(dynCol, 100))
        label.set_textcolor(g_pnl_lbl, priceLabelColor)
    else
        label.set_text    (g_pnl_lbl, "")

// ════════════════════════════════════════════════════════════════════════════════
// ── GAUGE CALLS ───────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
bool gauge_reducedWidth = gauge_widthMode == "Reduced (2 Bars)"

if enable_4H and h4_gauge_draw and tf_4H
    drawGauge(h4_gaugeBase - GaugePos,
         h4_open, h4_high, h4_low,
         h4_finalBullBg, h4_gauge_bull_fg,
         h4_finalBearBg, h4_gauge_bear_fg,
         "4H", gauge_showPercent, gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
         gauge_priceLabelColor, gauge_scopeHighLabelColor, gauge_scopeLowLabelColor,
         gauge_showPriceLabel, gauge_priceLabelSide, gauge_innerBoxBrightness,
         gauge_reducedWidth, gauge_reducedBarWidth)

if enable_Day and day_gauge_draw and tf_Day
    drawGauge(day_gaugeBase - GaugePos,
         daily_open, daily_high, daily_low,
         day_finalBullBg, day_gauge_bull_fg,
         day_finalBearBg, day_gauge_bear_fg,
         "DAY", gauge_showPercent, gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
         gauge_priceLabelColor, gauge_scopeHighLabelColor, gauge_scopeLowLabelColor,
         gauge_showPriceLabel, gauge_priceLabelSide, gauge_innerBoxBrightness,
         gauge_reducedWidth, gauge_reducedBarWidth)

if enable_Week and wk_gauge_draw and tf_Week
    drawGauge(wk_gaugeBase - GaugePos,
         weekly_open, weekly_high, weekly_low,
         wk_finalBullBg, wk_gauge_bull_fg,
         wk_finalBearBg, wk_gauge_bear_fg,
         "WEEK", gauge_showPercent, gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
         gauge_priceLabelColor, gauge_scopeHighLabelColor, gauge_scopeLowLabelColor,
         gauge_showPriceLabel, gauge_priceLabelSide, gauge_innerBoxBrightness,
         gauge_reducedWidth, gauge_reducedBarWidth)

if enable_Month and mo_gauge_draw and tf_Month
    drawGauge(mo_gaugeBase - GaugePos,
         monthly_open, monthly_high, monthly_low,
         mo_finalBullBg, mo_gauge_bull_fg,
         mo_finalBearBg, mo_gauge_bear_fg,
         "MONTH", gauge_showPercent, gauge_innerBoxTrans, gauge_scopeBoxTrans, gauge_scopeBorderTrans, gauge_innerBorderTrans,
         gauge_priceLabelColor, gauge_scopeHighLabelColor, gauge_scopeLowLabelColor,
         gauge_showPriceLabel, gauge_priceLabelSide, gauge_innerBoxBrightness,
         gauge_reducedWidth, gauge_reducedBarWidth)

// ════════════════════════════════════════════════════════════════════════════════
// ── GENERIC RANGE TYPE ────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
type FibRange
    array<line>  lines
    array<box>   labels
    array<label> circles
    array<label> circlesEnd
    array<float> linePrices
    array<color> lineBaseCols
    array<color> labelBaseCols
    array<color> circleBaseCols
    array<color> circleEndBaseCols

method extendFibRange(FibRange this, int offset, bool showLbls) =>
    if not na(this)
        for i = 0 to this.lines.size() - 1
            this.lines.get(i).set_x2(bar_index + offset)
        if showLbls
            for i = 0 to this.labels.size() - 1
                this.labels.get(i).set_right(bar_index + offset)
        for i = 0 to this.circlesEnd.size() - 1
            this.circlesEnd.get(i).set_x(bar_index + offset)

method deleteFibRange(FibRange this, bool showLbls) =>
    if not na(this)
        for i = 0 to this.lines.size() - 1
            this.lines.get(i).delete()
        if showLbls
            for i = 0 to this.labels.size() - 1
                this.labels.get(i).delete()
        for i = 0 to this.circles.size() - 1
            this.circles.get(i).delete()
        for i = 0 to this.circlesEnd.size() - 1
            this.circlesEnd.get(i).delete()

// Ranks every level line/label (skipping index 0, the period's opening line/label,
// which always tracks pctNear directly) by its distance to refClose — separately
// for levels above and levels below — and fades each one to pctNear (nearest on
// that side), pctMid (2nd nearest), or pctFar (everything else). Levels whose price
// is still na (e.g. bar 0 of a period, before any range average exists) are skipped
// rather than fed into the sort, which is what was crashing on bar 0.
method updateShading(FibRange this, float refClose, float pctNear, float pctMid, float pctFar) =>
    if not na(this) and this.lines.size() > 0 and not na(refClose)
        n = this.lines.size()

        // The period's opening line/label always uses the "Nearest" opacity.
        openTrans = 100 - pctNear
        this.lines.get(0).set_color(color.new(this.lineBaseCols.get(0), openTrans))
        if this.labels.size() > 0
            this.labels.get(0).set_text_color(color.new(this.labelBaseCols.get(0), openTrans))
        if this.circles.size() > 0
            this.circles.get(0).set_textcolor(color.new(this.circleBaseCols.get(0), openTrans))
        if this.circlesEnd.size() > 0
            this.circlesEnd.get(0).set_textcolor(color.new(this.circleEndBaseCols.get(0), openTrans))

        if n > 1
            array<int>   idxAbove = array.new<int>(0)
            array<int>   idxBelow = array.new<int>(0)
            array<float> pxAbove  = array.new<float>(0)
            array<float> pxBelow  = array.new<float>(0)
            for i = 1 to n - 1
                p = this.linePrices.get(i)
                if not na(p)
                    if p >= refClose
                        idxAbove.push(i)
                        pxAbove.push(p)
                    else
                        idxBelow.push(i)
                        pxBelow.push(p)

            if idxAbove.size() > 0
                array<int> ordAbove = array.sort_indices(pxAbove, order.ascending)   // nearest to refClose first
                for r = 0 to ordAbove.size() - 1
                    li = idxAbove.get(ordAbove.get(r))
                    trans = 100 - f_bucketPct(r, pctNear, pctMid, pctFar)
                    this.lines.get(li).set_color(color.new(this.lineBaseCols.get(li), trans))
                    if this.labels.size() > li
                        this.labels.get(li).set_text_color(color.new(this.labelBaseCols.get(li), trans))
                    if this.circles.size() > li
                        this.circles.get(li).set_textcolor(color.new(this.circleBaseCols.get(li), trans))
                    if this.circlesEnd.size() > li
                        this.circlesEnd.get(li).set_textcolor(color.new(this.circleEndBaseCols.get(li), trans))

            if idxBelow.size() > 0
                array<int> ordBelow = array.sort_indices(pxBelow, order.descending)  // nearest to refClose first
                for r = 0 to ordBelow.size() - 1
                    li = idxBelow.get(ordBelow.get(r))
                    trans = 100 - f_bucketPct(r, pctNear, pctMid, pctFar)
                    this.lines.get(li).set_color(color.new(this.lineBaseCols.get(li), trans))
                    if this.labels.size() > li
                        this.labels.get(li).set_text_color(color.new(this.labelBaseCols.get(li), trans))
                    if this.circles.size() > li
                        this.circles.get(li).set_textcolor(color.new(this.circleBaseCols.get(li), trans))
                    if this.circlesEnd.size() > li
                        this.circlesEnd.get(li).set_textcolor(color.new(this.circleEndBaseCols.get(li), trans))

// ════════════════════════════════════════════════════════════════════════════════
// ── GENERIC FIB DRAW FUNCTION ─────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
drawFibRange(
     float  avgRange,
     color  hl,         color  nc,
     array<color> cols, array<bool> enabled,
     bool   showLbls,   bool   showCircs,
     bool   showCircsEnd,
     bool   showPercent, bool  showPrice,
     string fSize,      string tAlign,
     int    lWidth,     string lStyle,
     string cSize,
     string openTag,
     string lineColorMode) =>

    FibRange newR = FibRange.new(
         lines        = array.new<line>(0),
         labels       = array.new<box>(0),
         circles      = array.new<label>(0),
         circlesEnd   = array.new<label>(0),
         linePrices   = array.new<float>(0),
         lineBaseCols = array.new<color>(0),
         labelBaseCols= array.new<color>(0),
         circleBaseCols   = array.new<color>(0),
         circleEndBaseCols= array.new<color>(0))

    szFont  = f_fontSize(fSize)
    szCirc  = f_circleSize(cSize)
    stLine  = f_lineStyle(lStyle)
    halign  = f_textAlign(tAlign)

    // ── Directional colors ────────────────────────────────────────────────────
    color dotBull  = color.rgb(0, 194, 174)    // teal  — above open
    color dotBear  = color.rgb(255, 153, 0)    // orange — below open
    bool  useDirLines = lineColorMode == "Bull/Bear (Teal/Orange)"

    // ── Open reference line ───────────────────────────────────────────────────
    newR.lines.push(line.new(bar_index, open, bar_index, open,
         color=hl, width=lWidth, style=line.style_dotted))
    newR.linePrices.push(open)
    newR.lineBaseCols.push(hl)
    if showCircs
        newR.circles.push(label.new(bar_index - 1, open, "●",
             style=label.style_label_center,
             color=color.new(color.black, 100), textcolor=dotBull, size=szCirc))
        newR.circleBaseCols.push(dotBull)
    if showCircsEnd
        newR.circlesEnd.push(label.new(bar_index, open, "●",
             style=label.style_label_center,
             color=color.new(color.black, 100), textcolor=dotBull, size=szCirc))
        newR.circleEndBaseCols.push(dotBull)
    if showLbls
        string openTxt = openTag
        if showPercent
            openTxt := openTxt + "0%"
        if showPrice
            openTxt := openTxt + (showPercent ? "    " : "") + "$" + str.tostring(open, "0,000")
        newR.labels.push(box.new(bar_index, open + 1, bar_index, open,
             bgcolor=hl, border_color=na,
             text=openTxt,
             text_color=hl, text_valign=text.align_center,
             text_halign=halign, text_size=szFont))
        newR.labelBaseCols.push(hl)

    for i = 0 to 10
        if enabled.get(i)
            float lvlA = open + avgRange * (fibMultis.get(i) / 100)
            float lvlB = open - avgRange * (fibMultis.get(i) / 100)
            color baseA = useDirLines ? dotBull : (i == 6 ? hl : cols.get(i))
            color baseB = useDirLines ? dotBear : (i == 6 ? hl : cols.get(i))

            // ── Bull level (above open) ───────────────────────────────────────
            newR.lines.push(line.new(bar_index - 1, lvlA, bar_index, lvlA,
                 style=stLine, width=lWidth, color=color.new(baseA, 45)))
            newR.linePrices.push(lvlA)
            newR.lineBaseCols.push(baseA)
            if showCircs
                newR.circles.push(label.new(bar_index - 1, lvlA, "●",
                     style=label.style_label_center,
                     color=color.new(color.black, 100), textcolor=dotBull, size=szCirc))
                newR.circleBaseCols.push(dotBull)
            if showCircsEnd
                newR.circlesEnd.push(label.new(bar_index, lvlA, "●",
                     style=label.style_label_center,
                     color=color.new(color.black, 100), textcolor=dotBull, size=szCirc))
                newR.circleEndBaseCols.push(dotBull)

            // ── Bear level (below open) ───────────────────────────────────────
            newR.lines.push(line.new(bar_index - 1, lvlB, bar_index, lvlB,
                 style=stLine, width=lWidth, color=color.new(baseB, 45)))
            newR.linePrices.push(lvlB)
            newR.lineBaseCols.push(baseB)
            if showCircs
                newR.circles.push(label.new(bar_index - 1, lvlB, "●",
                     style=label.style_label_center,
                     color=color.new(color.black, 100), textcolor=dotBear, size=szCirc))
                newR.circleBaseCols.push(dotBear)
            if showCircsEnd
                newR.circlesEnd.push(label.new(bar_index, lvlB, "●",
                     style=label.style_label_center,
                     color=color.new(color.black, 100), textcolor=dotBear, size=szCirc))
                newR.circleEndBaseCols.push(dotBear)

        if showLbls and enabled.get(i)
            float lvlA = open + avgRange * (fibMultis.get(i) / 100)
            float lvlB = open - avgRange * (fibMultis.get(i) / 100)

            string pctA = i == 6 ? "▼+100%" : "+" + str.tostring(fibMultis.get(i)) + "%"
            string pctB = i == 6 ? "▲-100%" : "-" + str.tostring(fibMultis.get(i)) + "%"
            string priceA = "$" + str.tostring(math.round(lvlA, 0), "0,000")
            string priceB = "$" + str.tostring(math.round(lvlB, 0), "0,000")

            string txtA = ""
            if showPercent
                txtA := txtA + pctA
            if showPrice
                txtA := txtA + (showPercent ? "    " : "") + priceA

            string txtB = ""
            if showPercent
                txtB := txtB + pctB
            if showPrice
                txtB := txtB + (showPercent ? "    " : "") + priceB

            // Same base color per timeframe (nc / hl for the equilibrium row),
            // but levels above open render brighter and levels below open render dimmer.
            color tcolBase = i == 6 ? hl : nc
            color tcolA    = f_brighten(tcolBase, 0.35)
            color tcolB    = f_darken(tcolBase, 0.35)

            newR.labels.push(box.new(bar_index, lvlA + 1, bar_index, lvlA,
                 bgcolor=color.rgb(54,58,69,70), border_color=na,
                 text=txtA, text_color=tcolA,
                 text_valign=text.align_bottom, text_halign=halign, text_size=szFont))
            newR.labelBaseCols.push(tcolA)
            newR.labels.push(box.new(bar_index, lvlB + 1, bar_index, lvlB,
                 bgcolor=color.rgb(54,58,69,70), border_color=na,
                 text=txtB, text_color=tcolB,
                 text_valign=text.align_top, text_halign=halign, text_size=szFont))
            newR.labelBaseCols.push(tcolB)
    newR

// ════════════════════════════════════════════════════════════════════════════════
// ── PER-TIMEFRAME STATE ───────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════

// ── 4H ───────────────────────────────────────────────────────────────────────
var h4_collection  = array.new<FibRange>(0)
var h4_ranges      = array.new<float>(0)
var float h4_avg   = na
var float h4_Hi    = na
var float h4_Lo    = na

var h4_colors  = array.from(h4_LC0,h4_LC1,h4_LC2,h4_LC3,h4_LC4,h4_LC5,h4_LC6,h4_LC7,h4_LC8,h4_LC9,h4_LC10)
var h4_enabled = array.from(h4_SL0,h4_SL1,h4_SL2,h4_SL3,h4_SL4,h4_SL5,h4_SL6,h4_SL7,h4_SL8,h4_SL9,h4_SL10)

if enable_4H and tf_4H and isFirst4HBar
    h4_ranges.push(h4_Hi - h4_Lo)
    h4_Hi := high
    h4_Lo := low
    if h4_ranges.size() > h4_bars
        h4_ranges.shift()
    h4_avg := array.avg(h4_ranges)

var FibRange h4_cur = na
if enable_4H and tf_4H and isFirst4HBar and h4_displayMode != "Hidden"
    h4_cur := drawFibRange(h4_avg,
         h4_HighLight, h4_NormalColor, h4_colors, h4_enabled,
         h4_showLabels, h4_showCircles, h4_showCirclesEnd,
         h4_showPercent, h4_showPrice,
         h4_fontSize,  h4_textAlign,
         h4_lineWidth, h4_lineStyle,
         h4_circleSize, "⨁4H   ", g_lineColorMode)
    h4_collection.push(h4_cur)

if enable_4H and tf_4H and not na(h4_cur)
    h4_cur.extendFibRange(h4_lvlOffset, h4_showLabels)
    if dyn_shade_enable
        h4_cur.updateShading(close, pct_near, pct_mid, pct_far)

if enable_4H and tf_4H
    int h4_max = h4_displayMode == "This Bar" ? 1 : h4_displayMode == "2 Bars" ? 2 : h4_displayMode == "6 Bars" ? 6 : 999
    if h4_collection.size() > h4_max and h4_displayMode != "All"
        h4_collection.get(0).deleteFibRange(h4_showLabels)
        h4_collection.shift()

h4_Hi := high > h4_Hi ? high : h4_Hi
h4_Lo := low  < h4_Lo ? low  : h4_Lo

// ── IntraDay ──────────────────────────────────────────────────────────────────
var day_collection = array.new<FibRange>(0)
var day_ranges     = array.new<float>(0)
var float day_avg  = na
var float day_Hi   = na
var float day_Lo   = na

var day_colors  = array.from(day_LC0,day_LC1,day_LC2,day_LC3,day_LC4,day_LC5,day_LC6,day_LC7,day_LC8,day_LC9,day_LC10)
var day_enabled = array.from(day_SL0,day_SL1,day_SL2,day_SL3,day_SL4,day_SL5,day_SL6,day_SL7,day_SL8,day_SL9,day_SL10)

if enable_Day and tf_Day and isFirstDayBar
    day_ranges.push(day_Hi - day_Lo)
    day_Hi := high
    day_Lo := low
    if day_ranges.size() > day_days
        day_ranges.shift()
    day_avg := array.avg(day_ranges)

var FibRange day_cur = na
if enable_Day and tf_Day and isFirstDayBar and day_displayMode != "Hidden"
    day_cur := drawFibRange(day_avg,
         day_HighLight, day_NormalColor, day_colors, day_enabled,
         day_showLabels, day_showCircles, day_showCirclesEnd,
         day_showPercent, day_showPrice,
         day_fontSize,  day_textAlign,
         day_lineWidth, day_lineStyle,
         day_circleSize, "⨁D   ", g_lineColorMode)
    day_collection.push(day_cur)

if enable_Day and tf_Day and not na(day_cur)
    day_cur.extendFibRange(day_lvlOffset, day_showLabels)
    if dyn_shade_enable
        day_cur.updateShading(close, pct_near, pct_mid, pct_far)

if enable_Day and tf_Day
    int day_max = day_displayMode == "Today" ? 1 : day_displayMode == "Two Days" ? 2 : day_displayMode == "Week" ? 5 : 999
    if day_collection.size() > day_max and day_displayMode != "All"
        day_collection.get(0).deleteFibRange(day_showLabels)
        day_collection.shift()

day_Hi := high > day_Hi ? high : day_Hi
day_Lo := low  < day_Lo ? low  : day_Lo

// ── IntraWeek ─────────────────────────────────────────────────────────────────
var wk_collection = array.new<FibRange>(0)
var wk_ranges     = array.new<float>(0)
var float wk_avg  = na
var float wk_Hi   = na
var float wk_Lo   = na

var wk_colors  = array.from(wk_LC0,wk_LC1,wk_LC2,wk_LC3,wk_LC4,wk_LC5,wk_LC6,wk_LC7,wk_LC8,wk_LC9,wk_LC10)
var wk_enabled = array.from(wk_SL0,wk_SL1,wk_SL2,wk_SL3,wk_SL4,wk_SL5,wk_SL6,wk_SL7,wk_SL8,wk_SL9,wk_SL10)

if enable_Week and tf_Week and isFirstWeekBar
    wk_ranges.push(wk_Hi - wk_Lo)
    wk_Hi := high
    wk_Lo := low
    if wk_ranges.size() > wk_weeks
        wk_ranges.shift()
    wk_avg := array.avg(wk_ranges)

var FibRange wk_cur = na
if enable_Week and tf_Week and isFirstWeekBar and wk_displayMode != "Hidden"
    wk_cur := drawFibRange(wk_avg,
         wk_HighLight, wk_NormalColor, wk_colors, wk_enabled,
         wk_showLabels, wk_showCircles, wk_showCirclesEnd,
         wk_showPercent, wk_showPrice,
         wk_fontSize,  wk_textAlign,
         wk_lineWidth, wk_lineStyle,
         wk_circleSize, "⨁W   ", g_lineColorMode)
    wk_collection.push(wk_cur)

if enable_Week and tf_Week and not na(wk_cur)
    wk_cur.extendFibRange(wk_lvlOffset, wk_showLabels)
    if dyn_shade_enable
        wk_cur.updateShading(close, pct_near, pct_mid, pct_far)

if enable_Week and tf_Week
    int wk_max = wk_displayMode == "This Week" ? 1 : wk_displayMode == "Two Weeks" ? 2 : wk_displayMode == "Month" ? 4 : 999
    if wk_collection.size() > wk_max and wk_displayMode != "All"
        wk_collection.get(0).deleteFibRange(wk_showLabels)
        wk_collection.shift()

wk_Hi := high > wk_Hi ? high : wk_Hi
wk_Lo := low  < wk_Lo ? low  : wk_Lo

// ── IntraMonth ────────────────────────────────────────────────────────────────
var mo_collection = array.new<FibRange>(0)
var mo_ranges     = array.new<float>(0)
var float mo_avg  = na
var float mo_Hi   = na
var float mo_Lo   = na

var mo_colors  = array.from(mo_LC0,mo_LC1,mo_LC2,mo_LC3,mo_LC4,mo_LC5,mo_LC6,mo_LC7,mo_LC8,mo_LC9,mo_LC10)
var mo_enabled = array.from(mo_SL0,mo_SL1,mo_SL2,mo_SL3,mo_SL4,mo_SL5,mo_SL6,mo_SL7,mo_SL8,mo_SL9,mo_SL10)

if enable_Month and tf_Month and isFirstMonthBar
    mo_ranges.push(mo_Hi - mo_Lo)
    mo_Hi := high
    mo_Lo := low
    if mo_ranges.size() > mo_months
        mo_ranges.shift()
    mo_avg := array.avg(mo_ranges)

var FibRange mo_cur = na
if enable_Month and tf_Month and isFirstMonthBar and mo_displayMode != "Hidden"
    mo_cur := drawFibRange(mo_avg,
         mo_HighLight, mo_NormalColor, mo_colors, mo_enabled,
         mo_showLabels, mo_showCircles, mo_showCirclesEnd,
         mo_showPercent, mo_showPrice,
         mo_fontSize,  mo_textAlign,
         mo_lineWidth, mo_lineStyle,
         mo_circleSize, "⨁M   ", g_lineColorMode)
    mo_collection.push(mo_cur)

if enable_Month and tf_Month and not na(mo_cur)
    mo_cur.extendFibRange(mo_lvlOffset, mo_showLabels)
    if dyn_shade_enable
        mo_cur.updateShading(close, pct_near, pct_mid, pct_far)

if enable_Month and tf_Month
    int mo_max = mo_displayMode == "This Month" ? 1 : mo_displayMode == "Two Months" ? 2 : mo_displayMode == "Quarter" ? 3 : 999
    if mo_collection.size() > mo_max and mo_displayMode != "All"
        mo_collection.get(0).deleteFibRange(mo_showLabels)
        mo_collection.shift()

mo_Hi := high > mo_Hi ? high : mo_Hi
mo_Lo := low  < mo_Lo ? low  : mo_Lo

// ════════════════════════════════════════════════════════════════════════════════
// ── CURRENT PRICE LABEL ───────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
bool show_price_label = day_showPriceLabel and timeframe.isintraday and timeframe.multiplier <= 240

daily_open_ref = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
DOcolor        = close >= daily_open_ref
daily_color    = DOcolor ? color.rgb(0,255,229) : color.rgb(255, 99, 37)

var label price_label = label.new(
     x=bar_index, y=close,
     text=str.tostring(close, "$0,000"),
     style=label.style_label_left,
     color=color.new(daily_color, 100),
     textcolor=color.white, 
     size=size.normal,
     xloc=xloc.bar_index)

var label price_bracket = label.new(
     x=bar_index, y=close,
     text="⌜              ⌝\n⌞              ⌟",
     style=label.style_label_left,
     color=color.new(daily_color, 95),
     textcolor=daily_color, size=size.small,
     xloc=xloc.bar_index)

if enable_Day and show_price_label
    int px = bar_index + day_priceOffset - 11
    label.set_x        (price_label,   px)
    label.set_y        (price_label,   close)
    label.set_text     (price_label,   str.tostring(close, "$0,000"))
    label.set_textcolor(price_label,   color.white)
    label.set_color    (price_label,   color.new(daily_color, 95))
    label.set_color    (price_bracket, color.new(daily_color, 95))
    label.set_textcolor(price_bracket, daily_color)
    label.set_x        (price_bracket, px)
    label.set_y        (price_bracket, close)

// EOF
````
