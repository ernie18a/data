# CQ_(0)_Fibonacci Intra4H Range v2

- url: https://www.tradingview.com/script/mBLNwzoN-CQ-0-Fibonacci-Intra4H-Range-v2/
- type: indicator
- pine_id: PUB;094a403c688d422c96b88ea704d7b109
- version: 1.0

## Description

================================================================================
  FIBONACCI INTRA 4H RANGE INDICATOR  |  TradingView Pine Script v6
  User Manual BASED ON UKUTALABS INTRADAY RANGE SCRIPT
================================================================================


--------------------------------------------------------------------------------
1. OVERVIEW
--------------------------------------------------------------------------------

The Fibonacci Intra 4H Range indicator projects statistically grounded price
targets above and below the current 4-hour candle's open price. It calculates
a rolling average range from recent 4H bars and uses that average as the basis
for a set of Fibonacci-proportioned horizontal levels, giving intraday traders
a visual map of where price is likely to travel -- or stall -- within any given
4-hour session.

IMPORTANT: This indicator only displays on intraday charts (timeframes below
1 day). It is automatically hidden on Daily, Weekly, and Monthly charts.

Key capabilities:

  - Fibonacci levels: Draws horizontal price lines at 11 Fibonacci-based
    multiples of the average 4H range, both above and below the 4H open.

  - Vertical range spine: A vertical line connects the -100% and +100% levels
    at the bar of the 4H open, visually framing the full expected session range.

  - 4H price tendency gauge: A live widget drawn to the right of price shows
    where the current bar sits relative to the 4H open, high, and low, including
    a running P&L from the 4H open.

  - Display history control: Choose to display 1, 2, 6, or all historical 4H
    range sets simultaneously.

  - Full visual customization: Each level has its own color, enable/disable
    toggle, line style, label settings, and circle markers.


--------------------------------------------------------------------------------
2. HOW IT WORKS
--------------------------------------------------------------------------------

The indicator follows a six-step process on every bar:

  1. 4H data is fetched.
     Using request.security, the script retrieves the open, high, low, and
     close values from the 4-hour timeframe, regardless of the chart timeframe
     currently viewed.

  2. New 4H bars are detected.
     The script checks ta.change(time('240')) to identify the first intraday
     bar of every new 4H candle. This is the trigger point for all drawing
     operations.

  3. Range history is recorded.
     At each new 4H bar, the prior 4H candle's range (high - low) is pushed
     into a rolling buffer. The buffer size is set by the "4H Bars to Average
     Range" input (default: 6 bars). When the buffer exceeds this size, the
     oldest value is dropped.

  4. Average range is calculated.
     The arithmetic mean of all values in the buffer becomes the average range
     -- the single number used to derive every Fibonacci level price.

     Formula:  Level price = 4H Open +/- (Average Range x Fibonacci multiple / 100)

  5. Lines and labels are drawn.
     A new set of horizontal lines, label boxes, optional circle markers, and
     a vertical spine is created at the 4H open bar for all enabled Fibonacci
     levels. Each set is stored in an Intra4HRange object that tracks its own
     lines, labels, and circles.

  6. Lines extend and old sets are pruned.
     On every bar, all active lines are extended rightward to the horizontal
     offset position. Based on Display Mode, sets that exceed the maximum are
     automatically deleted to keep the chart uncluttered.


--------------------------------------------------------------------------------
3. SETTINGS REFERENCE
--------------------------------------------------------------------------------

3.1  CONFIGURATION
---------------------------------------

  Display Mode
    Controls how many historical 4H range sets are visible.
      This Bar  -- shows only the current 4H range set (default)
      2 Bars    -- keeps the last 2 sets visible
      6 Bars    -- keeps the last 6 sets visible
      All       -- no pruning; all historical sets are shown
      Hidden    -- disables all drawing entirely


3.2  AVERAGE RANGE SETTINGS
---------------------------------------

  4H Bars to Average Range
    Number of completed 4H bars used to compute the rolling average range.
    Default: 6. Increase this value (e.g. 10-20) to smooth out spike
    distortions; decrease it for faster adaptation to recent volatility.


3.3  LABEL SETTINGS
---------------------------------------

  Show Labels
    Toggles the price label boxes shown at each level line.

  Font Size
    Size of label text. Options: Tiny, Small, Medium, Large. Default: Small.

  Text Alignment
    Horizontal alignment of label text within its box.
    Options: Left, Center, Right. Default: Right.

  Position (Horizontal Offset)
    How far to the right (in bars) the level lines and labels extend from the
    current bar. Range: 0-100. Default: 19. The gauge offset is automatically
    derived as this value minus 6.


3.4  LINE SETTINGS
---------------------------------------

  Line Width
    Pixel thickness of each level line.

  Line Style
    Visual style for level lines.
    Options: Solid, Dashed, Dotted. Default: Solid.


3.5  CIRCLE SETTINGS
---------------------------------------

  Show Circles
    Toggles the filled dot markers drawn at the left-hand start of each level
    line. Circles share the highlight color and help anchor each level visually
    on busy charts.

  Circle Size
    Size of the dot markers. Options: Tiny, Small, Normal, Large. Default: Small.


--------------------------------------------------------------------------------
4. FIBONACCI LEVELS
--------------------------------------------------------------------------------

Each enabled level produces two horizontal lines: one above (+) and one below
(-) the 4H open price, at a distance equal to the average range multiplied by
the level's factor. Levels can be individually enabled or disabled, and each
has its own color picker.

NOTE: The 100% level is always rendered in the highlight color (yellow-gold by
default), regardless of the general line color setting. It represents a full
average-range move and is the most significant target on the chart.

  Level   Multiplier   Default    Notes
  ------  -----------  ---------  -----------------------------------------------
  15%     x 0.15       Enabled    Early momentum probe
  25%     x 0.25       Enabled    First-quarter level
  40%     x 0.40       Enabled    Pre-midpoint stall zone
  50%     x 0.50       Enabled    Midpoint of average range -- significant level
  60%     x 0.60       Enabled    Post-midpoint extension
  75%     x 0.75       Enabled    Three-quarter range
  100%    x 1.00       Enabled    Full average range -- primary target, highlighted
  125%    x 1.25       Disabled   First extension, use in trending sessions
  150%    x 1.50       Disabled   Extension
  175%    x 1.75       Disabled   Extension
  200%    x 2.00       Disabled   Double range, extreme trending markets only


Color inputs:

  Line Color
    Applied to all standard levels (15% through 200%). Each level has its own
    independent color picker.

  Highlighted Items Color
    Applied to the 4H open baseline, the 100% level lines, and the vertical
    range spine. Defaults to bright yellow-gold.


Vertical range spine:

  A vertical line is drawn at the 4H open bar, connecting the -100% level to
  the +100% level. It uses the highlight color at 60% transparency. Unlike the
  horizontal lines, the spine does not extend rightward -- it marks the origin
  bar only, serving as a visual frame for the full expected session range.


--------------------------------------------------------------------------------
5. 4H PRICE TENDENCY GAUGE
--------------------------------------------------------------------------------

The gauge is a compact real-time widget drawn to the right of the current bar
(offset = Position - 6 bars). It gives an at-a-glance read of where price sits
within the active 4H candle.

Gauge structure:

  Bullish box (top)
    Spans from the 4H open up to the 4H high. Fills with the bullish background
    color when price is above the 4H open.

  Bearish box (bottom)
    Spans from the 4H open down to the 4H low. Fills with the bearish background
    color when price is below the 4H open.

  Price fill bar
    A smaller box inside the bullish or bearish zone tracks the current close
    relative to the 4H open, filling proportionally.

  High and low labels
    The 4H session high and low are labeled in their respective foreground colors.

  Open marker
    A white arrow and horizontal tick mark the exact 4H open price on the gauge.

  P&L label
    A floating label to the right of the gauge shows the dollar distance and
    percentage move from the 4H open to the current close. Hovering the label
    (tooltip) shows the full breakdown including the 4H opening price.


Gauge color settings:

  Gauge Background (Bullish)
    Background color of the upper gauge box. Default: dark teal.

  Foreground (Bullish)
    Color for the high label and price fill bar when bullish. Default: bright teal.

  Gauge Background (Bearish)
    Background color of the lower gauge box. Default: dark amber/brown.

  Foreground (Bearish)
    Color for the low label and price fill bar when bearish. Default: bright amber.

NOTE: The gauge can be disabled entirely using the "Draw 4H Price Tendency
Gauge" toggle at the top of the Gauge settings group.


--------------------------------------------------------------------------------
6. USAGE TIPS
--------------------------------------------------------------------------------

6.1  RECOMMENDED CHART TIMEFRAMES
---------------------------------------

  1-minute and 5-minute   Full level detail visible; gauge updates every tick.
  15-minute               Good balance of level visibility and chart readability.
  30-minute and 1-hour    Levels remain visible but fewer bars appear between them.


6.2  TUNING THE AVERAGE RANGE
---------------------------------------

  Low setting (3-4 bars)
    Adapts quickly to recent volatility. Best during regime changes or
    highly news-driven markets.

  Default (6 bars)
    Balances recency with stability. Works well for most instruments.

  High setting (10-20 bars)
    Smooths out spike distortions. Recommended when a single outlier session
    is skewing all levels.


6.3  READING THE LEVELS
---------------------------------------

  50% and 100% levels
    The most commonly respected. Watch for reactions, consolidation, and
    reversals near these before taking entries or exits.

  Price inside the range
    If price is trading between the -50% and +50% levels, the session is still
    range-bound. Wait for a breakout of the 50% level before assuming
    directional continuation.

  Price near +/-100%
    A statistically high percentage of sessions close within the full average
    range. When price approaches the 100% level, a pause or reversal is more
    likely unless a strong catalyst is present.

  Extension levels (125%-200%)
    Enable only during unusually strong trending conditions or high-impact news
    releases. These levels are disabled by default.


6.4  USING THE VERTICAL SPINE
---------------------------------------

  The vertical spine at the 4H open bar frames the entire expected session range
  visually. Use it to:

  - Quickly judge whether the current move is inside or outside the historical norm.
  - Identify the open bar's position on a crowded chart when multiple 4H sets
    are displayed.


6.5  DISPLAY MODE GUIDANCE
---------------------------------------

  This Bar    Best for clean charts focused on the current session only.
  2 Bars      Compare the current session to the immediately preceding one.
  6 Bars      Validate whether the average range setting produces realistic
              levels across multiple sessions.
  All         Use sparingly -- can produce excessive visual clutter.
  Hidden      Temporarily hide all drawings without removing the indicator.


6.6  HORIZONTAL OFFSET POSITIONING
---------------------------------------

  Adjust Position (Horizontal Offset) to push labels far enough right that they
  don't overlap price action. A value of 15-25 bars works for most intraday
  timeframes. On faster timeframes (1-minute), a higher offset may be needed.


6.7  GAUGE P&L TOOLTIP
---------------------------------------

  Hover over the P&L floating label to see the full breakdown: percentage move,
  dollar move, and the exact 4H opening price. Useful for scaling out of
  positions at meaningful fractions of the expected range.


--------------------------------------------------------------------------------
7. QUICK REFERENCE
--------------------------------------------------------------------------------

  Timeframe guard         Only active on intraday charts (below Daily).
  Data source             4H OHLC fetched via request.security with lookahead on.
  Range calculation       Rolling average of (4H High - 4H Low) over N bars.
  Level formula           Price = 4H Open +/- (Avg Range x Multiple / 100)
  Highlighted level       100% is always shown in the highlight color.
  Vertical spine          Connects -100% to +100% at the 4H open bar;
                          uses highlight color at 60% opacity.
  Gauge offset            Drawn at (Position - 6) bars right of current bar.
  Line/label persistence  Controlled by Display Mode; old sets auto-deleted.
  Max objects             500 lines, 500 boxes, 500 labels (Pine Script limits).


================================================================================
  END OF MANUAL
================================================================================

## Source Code

````pine
//@version=6
indicator("CQ_(0)_Fibonacci Intra4H Range v2", overlay=true,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ── Timeframe guard ───────────────────────────────────────────────────────────
// Hide the entire indicator on Daily, Weekly, Monthly, or any TF ≥ 1 day.
// timeframe.isintraday is true for any chart below Daily (1m … 4H, etc.)
bool tfAllowed = timeframe.isintraday

//--------------
// USER VARIABLES
//--------------
string displayMode  = input.string(defval="This Bar", title="Display Mode",
     options=["Hidden", "This Bar", "2 Bars", "6 Bars", "All"], group="Configuration")

int h4bars          = input.int(defval=6, title="4H Bars to Average Range", group="Average Range Settings")

bool showLabels     = input.bool(defval=true, title="Show Labels", group="Label Settings")
string fontSize     = input.string(defval="Small", title="Font Size",
     options=["Tiny", "Small", "Medium", "Large"], group="Label Settings")
string textAlign    = input.string(defval="Right", title="Text Alignment",
     options=["Left", "Center", "Right"], group="Label Settings")
var lines_offset    = input.int(defval=19, minval=0, maxval=100,
     title='Position (Horizontal Offset)', group="Label Settings")

int lineWidth       = input(defval=1, title="Line Width", group="Line Settings")
string lineStyle    = input.string(defval="Solid", title="Line Style",
     options=["Dashed","Solid","Dotted"], group="Line Settings")

bool showCircles    = input.bool(defval=true, title="Show Circles at Line Start", group="Circle Settings")
string circleSize   = input.string(defval="Small", title="Circle Size",
     options=["Tiny", "Small", "Normal", "Large"], group="Circle Settings")

color LevelColor0   = input.color(defval=color.rgb(162, 146, 0), title="Line Color", group="Fibonacci Levels", inline="0")
bool showLevel0     = input.bool(defval=true,  title="Enable (15%)",   group="Fibonacci Levels", inline="0")
color LevelColor1   = input.color(defval=color.rgb(162, 146, 0), title="Line Color", group="Fibonacci Levels", inline="1")
bool showLevel1     = input.bool(defval=true,  title="Enable (25%)",   group="Fibonacci Levels", inline="1")
color LevelColor2   = input.color(defval=color.rgb(162, 146, 0), title="Line Color", group="Fibonacci Levels", inline="2")
bool showLevel2     = input.bool(defval=true,  title="Enable (40%)",   group="Fibonacci Levels", inline="2")
color LevelColor3   = input.color(defval=color.rgb(162, 146, 0), title="Line Color", group="Fibonacci Levels", inline="3")
bool showLevel3     = input.bool(defval=true,  title="Enable (50%)",   group="Fibonacci Levels", inline="3")
color LevelColor4   = input.color(defval=color.rgb(162, 146, 0), title="Line Color", group="Fibonacci Levels", inline="4")
bool showLevel4     = input.bool(defval=true,  title="Enable (60%)",   group="Fibonacci Levels", inline="4")
color LevelColor5   = input.color(defval=color.rgb(162, 146, 0), title="Line Color", group="Fibonacci Levels", inline="5")
bool showLevel5     = input.bool(defval=true,  title="Enable (75%)",   group="Fibonacci Levels", inline="5")
color LevelColor6   = input.color(defval=color.rgb(162, 146, 0), title="Line Color", group="Fibonacci Levels", inline="6")
bool showLevel6     = input.bool(defval=true,  title="Enable (100%)",  group="Fibonacci Levels", inline="6")
color LevelColor7   = input.color(defval=color.rgb(162, 146, 0), title="Line Color", group="Fibonacci Levels", inline="7")
bool showLevel7     = input.bool(defval=false, title="Enable (125%)",  group="Fibonacci Levels", inline="7")
color LevelColor8   = input.color(defval=color.rgb(162, 146, 0), title="Line Color", group="Fibonacci Levels", inline="8")
bool showLevel8     = input.bool(defval=false, title="Enable (150%)",  group="Fibonacci Levels", inline="8")
color LevelColor9   = input.color(defval=color.rgb(162, 146, 0), title="Line Color", group="Fibonacci Levels", inline="9")
bool showLevel9     = input.bool(defval=false, title="Enable (175%)",  group="Fibonacci Levels", inline="9")
color LevelColor10  = input.color(defval=color.rgb(162, 146, 0), title="Line Color", group="Fibonacci Levels", inline="10")
bool showLevel10    = input.bool(defval=false, title="Enable (200%)",  group="Fibonacci Levels", inline="10")
color NormalColor   = input.color(defval=color.rgb(162, 146, 0), title="Highlighted Items Color", group="Fibonacci Levels")
color HighLight     = input.color(defval=color.rgb(255, 238, 0),  title="Highlighted Items Color", group="Fibonacci Levels")

// ── GAUGE ─────────────────────────────────────────────────────────────────────
h4_gauge_draw        = input.bool(true, 'Draw 4H Price Tendency Gauge', inline='retlg', group='Gauge')
gauge_bullish_color  = input.color(color.rgb(0, 83, 75),    title='    Gauge Background (Bullish)', inline='Bullish')
gauge_bullish_color2 = input.color(color.rgb(0, 194, 174),  title='    Foreground',                 inline='Bullish')
gauge_bearish_color  = input.color(color.rgb(85, 48, 0),    title='    Gauge Background (Bearish)', inline='Bearish')
gauge_bearish_color2 = input.color(color.rgb(255, 153, 0),  title='    Foreground',                 inline='Bearish')

gauge_offset = lines_offset - 6

// ── 4H security data ─────────────────────────────────────────────────────────
h4_open  = request.security(syminfo.tickerid, '240', open,  lookahead=barmerge.lookahead_on)
h4_high  = request.security(syminfo.tickerid, '240', high,  lookahead=barmerge.lookahead_on)
h4_low   = request.security(syminfo.tickerid, '240', low,   lookahead=barmerge.lookahead_on)
h4_close = request.security(syminfo.tickerid, '240', close, lookahead=barmerge.lookahead_on)

isFirst4HBar = ta.change(time('240')) != 0

// ── GAUGE (only on intraday charts) ──────────────────────────────────────────
GH4color  = close >= h4_open
Gh4_color = GH4color ? gauge_bullish_color2 : gauge_bearish_color2

if h4_gauge_draw and tfAllowed

    var Gauge_box_scope  = box.new(bar_index, close, bar_index, h4_open,
         border_color=color.new(gauge_bullish_color, 0),
         border_width=1, border_style=line.style_dotted,
         text='4HRS', text_valign=text.align_top, text_size=size.tiny,
         text_color=color.white, bgcolor=color.new(gauge_bullish_color, 50))
    var Gauge_line_max  = line.new(bar_index, close, bar_index, h4_open,
         color=gauge_bullish_color2, width=2)
    var Gauge_line_min  = line.new(bar_index, close, bar_index, h4_open,
         color=gauge_bullish_color, width=3)
    var Gauge_box_prc   = box.new(bar_index, close, bar_index, h4_open,
         border_color=color.new(gauge_bullish_color, 50), border_width=1,
         bgcolor=color.new(Gh4_color, 80))
    var Gauge_line_prc  = line.new(bar_index, close, bar_index, h4_open,
         color=gauge_bullish_color, width=4)

    var label gauge_high_label = label.new(bar_index, h4_high,
         text=str.tostring(math.round(h4_high, 0), '$0,000'),
         style=label.style_label_down,
         color=color.new(gauge_bullish_color, 80),
         textcolor=gauge_bullish_color2, size=size.small)

    var line gauge_open_marker = line.new(
         x1=bar_index + gauge_offset - 2, y1=h4_open,
         x2=bar_index + gauge_offset + 1, y2=h4_open,
         color=color.white, width=3, style=line.style_solid)
    var label gauge_open_label = label.new(bar_index, h4_open,
         text="◀", style=label.style_label_left,
         color=color.new(color.black, 100), textcolor=color.white, size=size.small)

    box.set_lefttop    (Gauge_box_scope, bar_index + gauge_offset - 2, h4_high)
    box.set_rightbottom(Gauge_box_scope, bar_index + gauge_offset + 1, h4_open)
    line.set_xy1(Gauge_line_max, bar_index + gauge_offset - 2, h4_high)
    line.set_xy2(Gauge_line_max, bar_index + gauge_offset + 1, h4_high)
    line.set_xy1(Gauge_line_min, bar_index + gauge_offset - 2, h4_open)
    line.set_xy2(Gauge_line_min, bar_index + gauge_offset + 1, h4_open)
    box.set_lefttop    (Gauge_box_prc, bar_index + gauge_offset - 1, close)
    box.set_rightbottom(Gauge_box_prc, bar_index + gauge_offset,     h4_open)
    box.set_bgcolor    (Gauge_box_prc, color.new(Gh4_color, 80))
    box.set_border_color(Gauge_box_prc, color.new(Gh4_color, 50))
    line.set_xy1(Gauge_line_prc, bar_index + gauge_offset - 1, close)
    line.set_xy2(Gauge_line_prc, bar_index + gauge_offset,     close)
    line.set_color(Gauge_line_prc, gauge_bullish_color)
    label.set_xy  (gauge_high_label, bar_index + gauge_offset - 1, h4_high)
    label.set_text(gauge_high_label, str.tostring(math.round(h4_high, 0), '$0,000'))
    line.set_xy1(gauge_open_marker, bar_index + gauge_offset - 2, h4_open)
    line.set_xy2(gauge_open_marker, bar_index + gauge_offset + 1, h4_open)
    label.set_xy  (gauge_open_label, bar_index + gauge_offset, h4_open)
    label.set_text(gauge_open_label, "◀")

    var Gauge_box_scope2 = box.new(bar_index, close, bar_index, h4_open,
         border_color=color.new(gauge_bearish_color, 0),
         border_width=1, border_style=line.style_dotted,
         text='4HRS', text_valign=text.align_bottom, text_size=size.tiny,
         text_color=color.white, bgcolor=color.new(gauge_bearish_color, 50))
    var Gauge_line_max2 = line.new(bar_index, close, bar_index, h4_open,
         color=gauge_bullish_color, width=3)
    var Gauge_line_min2 = line.new(bar_index, close, bar_index, h4_open,
         color=gauge_bearish_color2, width=2)
    var Gauge_box_prc2  = box.new(bar_index, close, bar_index, h4_open,
         border_color=color.new(gauge_bullish_color, 50), border_width=1,
         bgcolor=color.new(Gh4_color, 80))
    var Gauge_line_prc2 = line.new(bar_index, close, bar_index, h4_open,
         color=Gh4_color, width=4)

    var label gauge_low_label = label.new(bar_index, h4_low,
         text=str.tostring(math.round(h4_low, 0), '$0,000'),
         style=label.style_label_up,
         color=color.new(gauge_bearish_color, 80),
         textcolor=gauge_bearish_color2, size=size.small)

    box.set_lefttop    (Gauge_box_scope2, bar_index + gauge_offset - 2, h4_open)
    box.set_rightbottom(Gauge_box_scope2, bar_index + gauge_offset + 1, h4_low)
    line.set_xy1(Gauge_line_max2, bar_index + gauge_offset - 2, h4_open)
    line.set_xy2(Gauge_line_max2, bar_index + gauge_offset + 1, h4_open)
    line.set_xy1(Gauge_line_min2, bar_index + gauge_offset - 2, h4_low)
    line.set_xy2(Gauge_line_min2, bar_index + gauge_offset + 1, h4_low)
    box.set_lefttop    (Gauge_box_prc2, bar_index + gauge_offset - 1, close)
    box.set_rightbottom(Gauge_box_prc2, bar_index + gauge_offset,     h4_open)
    box.set_bgcolor    (Gauge_box_prc2, color.new(Gh4_color, 80))
    box.set_border_color(Gauge_box_prc2, color.new(Gh4_color, 50))
    line.set_xy1(Gauge_line_prc2, bar_index + gauge_offset - 1, close)
    line.set_xy2(Gauge_line_prc2, bar_index + gauge_offset,     close)
    line.set_color(Gauge_line_prc2, gauge_bullish_color)
    label.set_xy  (gauge_low_label, bar_index + gauge_offset - 1, h4_low)
    label.set_text(gauge_low_label, str.tostring(math.round(h4_low, 0), '$0,000'))

    var y_adjust = 1
    y_adjust := close - h4_open < 0 ? -1 : 1
    var profit_loss_label = label.new(bar_index, close,
         str.tostring(math.round(close - h4_open, 0), '$#,000'))
    label.set_xy     (profit_loss_label, bar_index + gauge_offset + 5, close + y_adjust)
    label.set_text   (profit_loss_label, str.tostring(math.round(close - h4_open, 0), '$#,000'))
    label.set_tooltip(profit_loss_label,
         str.tostring(((close - h4_open) / h4_open) * 100, format.percent) + ' ' +
         str.tostring(math.round(close - h4_open, 0), '$#,000') +
         ' from 4H Opening: ' + str.tostring(math.round(h4_open, 0), '$#,000'))
    label.set_color   (profit_loss_label, color.new(Gh4_color, 100))
    label.set_textcolor(profit_loss_label, color.new(Gh4_color, 0))
    label.set_size    (profit_loss_label, size.small)
    label.set_style   (profit_loss_label, label.style_label_right)
    label.set_textalign(profit_loss_label, text.align_left)

//--------------
// CLASSES
//--------------
type Intra4HRange
    array<line>  lines
    array<box>   labels
    array<label> circles

method extendLines(Intra4HRange this) =>
    if not na(this)
        for i = 0 to this.lines.size() - 1
            this.lines.get(i).set_x2(bar_index + lines_offset)
            if showLabels
                this.labels.get(i).set_right(bar_index + lines_offset)

method deleteLines(Intra4HRange this) =>
    if not na(this)
        for i = 0 to this.lines.size() - 1
            this.lines.get(i).delete()
            if showLabels
                this.labels.get(i).delete()
        for i = 0 to this.circles.size() - 1
            this.circles.get(i).delete()

//--------------
// HELPER: circle size string → Pine size constant
//--------------
f_circleSize(string s) =>
      s == "Tiny"   ? size.tiny   : 
      s == "Small"  ? size.small  :
      s == "Normal" ? size.normal : size.large

//--------------
// VARIABLES
//--------------
var collection         = array.new<Intra4HRange>(0)
var ranges             = array.new<float>(0)
var float averageRange = na
var float h4High       = na
var float h4Low        = na
var int   tfp          = timeframe.isintraday and not timeframe.isseconds ? int(str.tonumber(timeframe.period)) : 0

var fibMultis  = array.from(15, 25, 40, 50, 60, 75, 100, 125, 150, 175, 200)
var colors     = array.from(LevelColor0, LevelColor1, LevelColor2, LevelColor3, LevelColor4,
     LevelColor5, LevelColor6, LevelColor7, LevelColor8, LevelColor9, LevelColor10)
var fibEnabled = array.from(showLevel0, showLevel1, showLevel2, showLevel3, showLevel4,
     showLevel5, showLevel6, showLevel7, showLevel8, showLevel9, showLevel10)

//--------------
// DRAW FUNCTION
//--------------
drawLines(array<Intra4HRange> collection, float averageRange, int tfp) =>
    var Intra4HRange newI4HR = na

    if isFirst4HBar and displayMode != "Hidden" and tfAllowed
        newI4HR := Intra4HRange.new(
             lines   = array.new<line>(0),
             labels  = array.new<box>(0),
             circles = array.new<label>(0))

        // ── 4H open baseline ─────────────────────────────────────────────────
        newI4HR.lines.push(line.new(
             x1=bar_index, y1=open, x2=bar_index, y2=open,
             color=HighLight, width=lineWidth, style=line.style_dotted))

        if showCircles
            newI4HR.circles.push(label.new(
                 x=bar_index - 1, y=open, text="●",
                 style=label.style_label_center,
                 color=color.new(color.black, 100),
                 size=f_circleSize(circleSize), textcolor=HighLight))

        if showLabels
            newI4HR.labels.push(box.new(
                 left=bar_index, top=open + 1, right=bar_index, bottom=open,
                 bgcolor=HighLight, border_color=na,
                 text="⨁4H    $" + str.tostring(open, '0,000'),
                 text_color=HighLight,
                 text_valign=text.align_center,
                 text_halign=textAlign == "Left" ? text.align_left : textAlign == "Center" ? text.align_center : text.align_right,
                 text_size=fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large))

        // ── Fibonacci levels above & below 4H open ────────────────────────────
        for i = 0 to 10
            if fibEnabled.get(i)
                float levelAbove = open + (averageRange * (fibMultis.get(i) / 100))
                float levelBelow = open - (averageRange * (fibMultis.get(i) / 100))
                color lineCol    = i == 6 ? HighLight : color.new(colors.get(i), 45)

                newI4HR.lines.push(line.new(
                     x1=bar_index - 1, y1=levelAbove,
                     x2=bar_index,     y2=levelAbove,
                     style=lineStyle == "Dashed" ? line.style_dashed : lineStyle == "Solid" ? line.style_solid : line.style_dotted,
                     width=lineWidth, color=lineCol))

                if showCircles
                    newI4HR.circles.push(label.new(
                         x=bar_index - 1, y=levelAbove, text="●",
                         style=label.style_label_center,
                         color=color.new(color.black, 100),
                         size=f_circleSize(circleSize), textcolor=HighLight))

                newI4HR.lines.push(line.new(
                     x1=bar_index - 1, y1=levelBelow,
                     x2=bar_index,     y2=levelBelow,
                     style=lineStyle == "Dashed" ? line.style_dashed : lineStyle == "Solid" ? line.style_solid : line.style_dotted,
                     width=lineWidth, color=lineCol))

                if showCircles
                    newI4HR.circles.push(label.new(
                         x=bar_index - 1, y=levelBelow, text="●",
                         style=label.style_label_center,
                         color=color.new(color.black, 100),
                         size=f_circleSize(circleSize), textcolor=HighLight))

            if showLabels
                if fibEnabled.get(i)
                    float levelAbove = open + (averageRange * (fibMultis.get(i) / 100))
                    float levelBelow = open - (averageRange * (fibMultis.get(i) / 100))

                    newI4HR.labels.push(box.new(
                         left=bar_index, top=levelAbove + 1,
                         right=bar_index, bottom=levelAbove,
                         bgcolor=color.rgb(54, 58, 69, 70), border_color=na,
                         text=i == 6 ? "▼+100%    $" + str.tostring(math.round(open + averageRange, 0), '0,000') :
                              '+' + str.tostring(fibMultis.get(i)) + "%    $" + str.tostring(math.round(levelAbove, 0), '0,000'),
                         text_color=i == 6 ? HighLight : NormalColor,
                         text_valign=text.align_bottom,
                         text_halign=textAlign == "Left" ? text.align_left : textAlign == "Center" ? text.align_center : text.align_right,
                         text_size=fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large))

                    newI4HR.labels.push(box.new(
                         left=bar_index, top=levelBelow + 1,
                         right=bar_index, bottom=levelBelow,
                         bgcolor=color.rgb(54, 58, 69, 70), border_color=na,
                         text=i == 6 ? "▲-100%    $" + str.tostring(math.round(open - averageRange, 0), '0,000') :
                              '-' + str.tostring(fibMultis.get(i)) + "%    $" + str.tostring(math.round(levelBelow, 0), '0,000'),
                         text_color=i == 6 ? HighLight : NormalColor,
                         text_valign=text.align_top,
                         text_halign=textAlign == "Left" ? text.align_left : textAlign == "Center" ? text.align_center : text.align_right,
                         text_size=fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large))

        collection.push(newI4HR)

    if not na(newI4HR) and tfAllowed
        newI4HR.extendLines()

    int maxBars = displayMode == "This Bar" ? 1 : displayMode == "2 Bars" ? 2 : displayMode == "6 Bars" ? 6 : 999
    if collection.size() > maxBars and displayMode != "All"
        collection.get(0).deleteLines()
        collection.shift()

//--------------
// MAIN LOGIC
//--------------
if isFirst4HBar
    ranges.push(h4High - h4Low)
    h4High := high
    h4Low  := low

    if ranges.size() > h4bars
        ranges.shift()

    averageRange := array.avg(ranges)

if tfAllowed
    drawLines(collection, averageRange, tfp)

h4High := high > h4High ? high : h4High
h4Low  := low  < h4Low  ? low  : h4Low
````
