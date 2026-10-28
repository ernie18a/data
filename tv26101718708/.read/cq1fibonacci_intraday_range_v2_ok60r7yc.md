# CQ_(1)_Fibonacci IntraDay Range v2

- url: https://www.tradingview.com/script/oK60R7YC-CQ-1-Fibonacci-IntraDay-Range-v2/
- type: indicator
- pine_id: PUB;a093e3aa71314affa126e4ebfec558d6
- version: 1.0

## Description

================================================================================
  CQ FIBONACCI INTRADAY RANGE 2 — USER MANUAL
  Based on UkutaLabs intraday Range Indicator | Pine Script v6 | 
================================================================================


────────────────────────────────────────────────────────────────────────────────
  OVERVIEW
────────────────────────────────────────────────────────────────────────────────

This indicator projects Fibonacci-based intraday price targets above and below
each session's opening price, calculated from a rolling average of past daily
ranges. It also includes a real-time price tendency gauge and a live price label
to help you track intraday momentum at a glance.

Timeframe restriction:
  The indicator is hidden on Weekly and Monthly charts. It is active on all
  intraday timeframes (1m through 4H) and on the Daily chart.


────────────────────────────────────────────────────────────────────────────────
  HOW IT WORKS
────────────────────────────────────────────────────────────────────────────────

Step 1 — Average Range Calculation
  At the start of each new session (session.isfirstbar), the previous day's
  high-low range is added to a rolling array. Once the array exceeds the
  user-defined "Days to Average Range" setting, the oldest entry is dropped.
  The average of all entries in the array becomes the "averageRange" value used
  for the current session.

Step 2 — Level Projection
  Using the current session's opening price as the baseline, the indicator
  calculates Fibonacci percentage levels above and below:

    levelAbove = dailyOpen + averageRange × (Fib% ÷ 100)
    levelBelow = dailyOpen − averageRange × (Fib% ÷ 100)

  Available levels: 15%, 25%, 40%, 50%, 60%, 75%, 100%, 125%, 150%, 175%, 200%

  The 100% level represents a full average-range move from the open — the most
  statistically significant level. It is always rendered in the accent/highlight
  color regardless of individual color settings.

Step 3 — Drawing Objects
  All lines, label boxes, and circle markers are created once at session open
  and stored in an IntraDayRange object. On every subsequent bar, each line's
  right-hand x-coordinate is updated to (bar_index + offset), extending the
  lines forward in real time.

Step 4 — Session Cleanup
  When Display Mode limits the number of visible sessions, the oldest
  IntraDayRange object is automatically deleted (all its drawing objects
  removed) and shifted out of the internal collection array.


────────────────────────────────────────────────────────────────────────────────
  SETTINGS REFERENCE
────────────────────────────────────────────────────────────────────────────────

── CONFIGURATION ───────────────────────────────────────────────────────────────

  Display Mode
    Controls how many session ranges are displayed simultaneously.
      Hidden    — turns the indicator completely off
      Today     — shows only the current session (default)
      Two Days  — shows today and yesterday
      Week      — shows the last 5 sessions
      All       — shows every session available on the chart

  Days to Average Range
    How many past daily candles are used to compute the average high-low range.
    Default: 1 (uses only yesterday's range).
    Higher values smooth out outlier days; lower values react faster to recent
    volatility.


── LABEL SETTINGS ──────────────────────────────────────────────────────────────

  Show Labels
    Toggles the price text boxes at each Fibonacci level. Each box shows the
    percentage label (e.g., "+50%") and the corresponding dollar price.

  Font Size
    Options: Tiny / Small / Medium / Large
    Applies to all level label text.

  Text Alignment
    Options: Left / Center / Right
    Controls the horizontal alignment of text inside each label box.

  Position (Horizontal Offset)
    Range: 0 – 100 bars. Default: 32.
    How far to the right the lines and labels extend past the last bar.
    The gauge position is automatically derived from this value (offset − 6).


── LINE SETTINGS ───────────────────────────────────────────────────────────────

  Line Width
    Pixel thickness of all Fibonacci level lines.

  Line Style
    Options: Solid / Dashed / Dotted
    Applies to all horizontal Fibonacci level lines.


── CIRCLE SETTINGS ─────────────────────────────────────────────────────────────

  Show Circles at Line Start
    Draws a dot marker at the left origin of each level line, providing a clear
    visual anchor at the session open bar.

  Circle Size
    Options: Tiny / Small / Normal / Large
    Scales the dot markers independently from the label text.


── FIBONACCI LEVELS ────────────────────────────────────────────────────────────

  Each level has three controls:
    - Line Color       individual color picker for that level's line
    - Enable toggle    on/off switch for that level
    - (The color and toggle appear inline on the same row in settings)

  Level    %       Default   Notes
  -------  ------  --------  ---------------------------------------------------
  0        15%     On        Minor support / resistance zone
  1        25%     On        Quarter-range pivot
  2        40%     On        Below-midpoint inflection
  3        50%     On        Midpoint — half the average range
  4        60%     On        Above-midpoint inflection
  5        75%     On        Three-quarter range target
  6        100%    On        Full average range — rendered in highlight color
  7        125%    Off       Extended move target
  8        150%    Off       Extended move target
  9        175%    Off       Extreme extension
  10       200%    Off       Double-range extreme

  Line Color (shared)
    Default color for all enabled levels: rgb(153, 198, 253) — soft blue.

  Highlighted Items Color
    The color used specifically for the daily open baseline and the 100% level
    lines and labels. Default: rgb(181, 212, 249).

  Normal Color
    The color used for all other enabled level labels.
    Default: rgb(136, 190, 255).


── GAUGE SETTINGS ──────────────────────────────────────────────────────────────

  Draw Intraday Price Tendency Gauge
    Enables or disables the vertical gauge drawn at the right edge of the chart.

  How the gauge works:
    The gauge is split into two halves, anchored at the daily open price:
      - Bullish half (upper): spans from daily open up to daily high
      - Bearish half (lower): spans from daily open down to daily low
    An inner shaded bar fills proportionally to show where current price sits
    within the session's range. The daily high and low are labeled with prices.
    A floating label to the right of the gauge shows the dollar gain/loss from
    the daily open, with a tooltip displaying the percentage move.

  Gauge Background (Bullish)
    Background color of the upper (bullish) half of the gauge.
    Default: dark green rgb(0, 83, 75).

  Foreground (Bullish)
    Color of the active fill bar and high price label when price is above open.
    Default: bright teal rgb(0, 194, 174).

  Gauge Background (Bearish)
    Background color of the lower (bearish) half of the gauge.
    Default: dark amber rgb(85, 48, 0).

  Foreground (Bearish)
    Color of the active fill bar and low price label when price is below open.
    Default: orange rgb(255, 153, 0).

  Note: The gauge's horizontal position is automatically calculated as
  (Position (Horizontal Offset) − 6) bars to the right of the last bar.


── CURRENT PRICE LABEL ─────────────────────────────────────────────────────────

  Show Current Price Label
    Displays a live-updating price label to the right of the chart.
    Only active on intraday timeframes at or below 4H, and only during
    confirmed real-time bars (not on historical bars).

  Position (Horizontal Offset)
    Controls how far to the right the price label sits from the last bar.
    This is a separate offset from the Fibonacci lines offset.

  Behavior:
    - Cyan color when price is above the daily open
    - Orange-red color when price is below the daily open
    - A bracket/frame label (⌜ ⌝ / ⌞ ⌟) surrounds the price for emphasis
    - Updates continuously during real-time bar progression


────────────────────────────────────────────────────────────────────────────────
  PRACTICAL TIPS
────────────────────────────────────────────────────────────────────────────────

Using levels as intraday targets
  The 50% and 100% levels are the most widely watched. A move to the 50% level
  often acts as the first intraday target. A push through the 100% level signals
  an unusually strong trending session. Levels above 100% (125%–200%) are most
  useful for identifying breakout extensions on high-volatility days.

Choosing the averaging window
  Set "Days to Average Range" to 1 to use only yesterday's range — ideal around
  major news events when recent conditions are most relevant. Set it to 5 or 10
  to smooth out weekly seasonality. Avoid very large values as they dilute the
  relevance of current market conditions.

Reducing visual clutter
  Disable the extended-range levels (125%–200%) unless you are specifically
  trading breakout scenarios. Setting Display Mode to "Today" and reducing the
  Horizontal Offset to 8–12 bars keeps the chart clean on lower timeframes.

Daily chart usage
  On the Daily timeframe the Fibonacci levels still draw, but the gauge and the
  current price label are disabled (they are intraday-only features). The
  session logic fires once per day, so each new candle extends the lines
  forward by one bar.

Working with multiple sessions (Two Days / Week / All)
  Each session gets its own set of lines drawn from that session's open. Older
  sessions are progressively deleted when the count exceeds the Display Mode
  limit. Switching from "Today" to "Week" mid-session will not retroactively
  draw past sessions that have already been cleaned up — it takes effect on the
  next session boundary.


────────────────────────────────────────────────────────────────────────────────
  QUICK REFERENCE — DEFAULT SETTINGS
────────────────────────────────────────────────────────────────────────────────

  Display Mode            Today
  Days to Average Range   1
  Show Labels             On
  Font Size               Small
  Text Alignment          Right
  Horizontal Offset       32
  Line Width              1
  Line Style              Solid
  Show Circles            On
  Circle Size             Small
  Active Fib Levels       15%, 25%, 40%, 50%, 60%, 75%, 100%
  Gauge                   On
  Current Price Label     On (intraday ≤ 4H only)


================================================================================
  END OF MANUAL
================================================================================

## Source Code

````pine

//@version=6
indicator("CQ_(1)_Fibonacci IntraDay Range v2", overlay=true,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ── Timeframe guard ───────────────────────────────────────────────────────────
// Hide the entire indicator on Weekly, Monthly, or any TF ≥ 1 week.
// Allowed on: intraday (1m…4H) AND daily.
bool tfAllowed = not timeframe.isweekly and not timeframe.ismonthly

//--------------
// USER VARIABLES
//--------------
string displayMode  = input.string(defval="Today", title="Display Mode",
     options=["Hidden", "Today", "Two Days", "Week", "All"], group="Configuration")

int days            = input.int(defval=1, title="Days to Average Range", group="Average Range Settings")

bool showLabels     = input.bool(defval=true, title="Show Labels", group="Label Settings")
string fontSize     = input.string(defval="Small", title="Font Size",
     options=["Tiny", "Small", "Medium", "Large"], group="Label Settings")
string textAlign    = input.string(defval="Right", title="Text Alignment",
     options=["Left", "Center", "Right"], group="Label Settings")
var lines_offset    = input.int(defval=32, minval=0, maxval=100,
     title='Position (Horizontal Offset)', group="Label Settings")

int lineWidth       = input(defval=1, title="Line Width", group="Line Settings")
string lineStyle    = input.string(defval="Solid", title="Line Style",
     options=["Dashed","Solid","Dotted"], group="Line Settings")

bool showCircles    = input.bool(defval=true, title="Show Circles at Line Start", group="Circle Settings")
string circleSize   = input.string(defval="Small", title="Circle Size",
     options=["Tiny", "Small", "Normal", "Large"], group="Circle Settings")

color LevelColor0   = input.color(defval=color.rgb(153, 198, 253), title="Line Color", group="Fibonacci Levels", inline="0")
bool showLevel0     = input.bool(defval=true,  title="Enable (15%)",   group="Fibonacci Levels", inline="0")
color LevelColor1   = input.color(defval=color.rgb(153, 198, 253), title="Line Color", group="Fibonacci Levels", inline="1")
bool showLevel1     = input.bool(defval=true,  title="Enable (25%)",   group="Fibonacci Levels", inline="1")
color LevelColor2   = input.color(defval=color.rgb(153, 198, 253), title="Line Color", group="Fibonacci Levels", inline="2")
bool showLevel2     = input.bool(defval=true,  title="Enable (40%)",   group="Fibonacci Levels", inline="2")
color LevelColor3   = input.color(defval=color.rgb(153, 198, 253), title="Line Color", group="Fibonacci Levels", inline="3")
bool showLevel3     = input.bool(defval=true,  title="Enable (50%)",   group="Fibonacci Levels", inline="3")
color LevelColor4   = input.color(defval=color.rgb(153, 198, 253), title="Line Color", group="Fibonacci Levels", inline="4")
bool showLevel4     = input.bool(defval=true,  title="Enable (60%)",   group="Fibonacci Levels", inline="4")
color LevelColor5   = input.color(defval=color.rgb(153, 198, 253), title="Line Color", group="Fibonacci Levels", inline="5")
bool showLevel5     = input.bool(defval=true,  title="Enable (75%)",   group="Fibonacci Levels", inline="5")
color LevelColor6   = input.color(defval=color.rgb(153, 198, 253), title="Line Color", group="Fibonacci Levels", inline="6")
bool showLevel6     = input.bool(defval=true,  title="Enable (100%)",  group="Fibonacci Levels", inline="6")
color LevelColor7   = input.color(defval=color.rgb(153, 198, 253), title="Line Color", group="Fibonacci Levels", inline="7")
bool showLevel7     = input.bool(defval=false, title="Enable (125%)",  group="Fibonacci Levels", inline="7")
color LevelColor8   = input.color(defval=color.rgb(153, 198, 253), title="Line Color", group="Fibonacci Levels", inline="8")
bool showLevel8     = input.bool(defval=false, title="Enable (150%)",  group="Fibonacci Levels", inline="8")
color LevelColor9   = input.color(defval=color.rgb(153, 198, 253), title="Line Color", group="Fibonacci Levels", inline="9")
bool showLevel9     = input.bool(defval=false, title="Enable (175%)",  group="Fibonacci Levels", inline="9")
color LevelColor10  = input.color(defval=color.rgb(153, 198, 253), title="Line Color", group="Fibonacci Levels", inline="10")
bool showLevel10    = input.bool(defval=false, title="Enable (200%)",  group="Fibonacci Levels", inline="10")
color NormalColor   = input.color(defval=color.rgb(136, 190, 255), title="Highlighted Items Color", group="Fibonacci Levels")
color HighLight     = input.color(defval=color.rgb(181, 212, 249), title="Highlighted Items Color", group="Fibonacci Levels")

// ── GAUGE ─────────────────────────────────────────────────────────────────────
Intraday_gauge_draw  = input.bool(true, 'Draw INTRADAY Price Tendency Gauge', inline='retlg', group='Gauge')
gauge_bullish_color  = input.color(color.rgb(0, 83, 75),   title='    Gauge Background (Bullish)', inline='Bullish')
gauge_bullish_color2 = input.color(color.rgb(0, 194, 174), title='    Foreground',                 inline='Bullish')
gauge_bearish_color  = input.color(color.rgb(85, 48, 0),   title='    Gauge Background (Bearish)', inline='Bearish')
gauge_bearish_color2 = input.color(color.rgb(255, 153, 0), title='    Foreground',                 inline='Bearish')

gauge_offset = lines_offset - 6

// Daily security data
daily_open  = request.security(syminfo.tickerid, 'D', open,  lookahead=barmerge.lookahead_on)
daily_high  = request.security(syminfo.tickerid, 'D', high,  lookahead=barmerge.lookahead_on)
daily_low   = request.security(syminfo.tickerid, 'D', low,   lookahead=barmerge.lookahead_on)
daily_close = request.security(syminfo.tickerid, 'D', close, lookahead=barmerge.lookahead_on)

// ── INTRADAY TENDENCY GAUGE (only when tfAllowed) ─────────────────────────────
GDOcolor     = close >= daily_open
Gdaily_color = GDOcolor ? gauge_bullish_color2 : gauge_bearish_color2

if Intraday_gauge_draw and tfAllowed

    var Gauge_box_scope  = box.new(bar_index, close, bar_index, daily_open,
         border_color=color.new(gauge_bullish_color, 0),
         border_width=1, border_style=line.style_dotted,
         text='DAY', text_valign=text.align_top, text_size=size.tiny,
         text_color=color.white, bgcolor=color.new(gauge_bullish_color, 50))
    var Gauge_line_max  = line.new(bar_index, close, bar_index, daily_open,
         color=gauge_bullish_color2, width=2)
    var Gauge_line_min  = line.new(bar_index, close, bar_index, daily_open,
         color=gauge_bullish_color, width=3)
    var Gauge_box_prc   = box.new(bar_index, close, bar_index, daily_open,
         border_color=color.new(gauge_bullish_color, 50), border_width=1,
         bgcolor=color.new(Gdaily_color, 80))
    var Gauge_line_prc  = line.new(bar_index, close, bar_index, daily_open,
         color=gauge_bullish_color, width=4)

    var label gauge_high_label = label.new(bar_index, daily_high,
         text=str.tostring(math.round(daily_high, 0), '$0,000'),
         style=label.style_label_down,
         color=color.new(gauge_bullish_color, 80),
         textcolor=gauge_bullish_color2, size=size.small)

    var line gauge_open_marker = line.new(
         x1=bar_index + gauge_offset - 2, y1=daily_open,
         x2=bar_index + gauge_offset + 1, y2=daily_open,
         color=color.white, width=3, style=line.style_solid)
    var label gauge_open_label = label.new(bar_index, daily_open,
         text="◀", style=label.style_label_left,
         color=color.new(color.black, 100), textcolor=color.white, size=size.small)

    box.set_lefttop    (Gauge_box_scope, bar_index + gauge_offset - 2, daily_high)
    box.set_rightbottom(Gauge_box_scope, bar_index + gauge_offset + 1, daily_open)
    line.set_xy1(Gauge_line_max, bar_index + gauge_offset - 2, daily_high)
    line.set_xy2(Gauge_line_max, bar_index + gauge_offset + 1, daily_high)
    line.set_xy1(Gauge_line_min, bar_index + gauge_offset - 2, daily_open)
    line.set_xy2(Gauge_line_min, bar_index + gauge_offset + 1, daily_open)
    box.set_lefttop    (Gauge_box_prc, bar_index + gauge_offset - 1, close)
    box.set_rightbottom(Gauge_box_prc, bar_index + gauge_offset,     daily_open)
    box.set_bgcolor    (Gauge_box_prc, color.new(Gdaily_color, 80))
    box.set_border_color(Gauge_box_prc, color.new(Gdaily_color, 50))
    line.set_xy1(Gauge_line_prc, bar_index + gauge_offset - 1, close)
    line.set_xy2(Gauge_line_prc, bar_index + gauge_offset,     close)
    line.set_color(Gauge_line_prc, gauge_bullish_color)
    label.set_xy  (gauge_high_label, bar_index + gauge_offset - 1, daily_high)
    label.set_text(gauge_high_label, str.tostring(math.round(daily_high, 0), '$0,000'))
    line.set_xy1(gauge_open_marker, bar_index + gauge_offset - 2, daily_open)
    line.set_xy2(gauge_open_marker, bar_index + gauge_offset + 1, daily_open)
    label.set_xy  (gauge_open_label, bar_index + gauge_offset, daily_open)
    label.set_text(gauge_open_label, "◀")

    var Gauge_box_scope2 = box.new(bar_index, close, bar_index, daily_open,
         border_color=color.new(gauge_bearish_color, 0),
         border_width=1, border_style=line.style_dotted,
         text='DAY', text_valign=text.align_bottom, text_size=size.tiny,
         text_color=color.white, bgcolor=color.new(gauge_bearish_color, 50))
    var Gauge_line_max2 = line.new(bar_index, close, bar_index, daily_open,
         color=gauge_bullish_color, width=3)
    var Gauge_line_min2 = line.new(bar_index, close, bar_index, daily_open,
         color=gauge_bearish_color2, width=2)
    var Gauge_box_prc2  = box.new(bar_index, close, bar_index, daily_open,
         border_color=color.new(gauge_bullish_color, 50), border_width=1,
         bgcolor=color.new(Gdaily_color, 80))
    var Gauge_line_prc2 = line.new(bar_index, close, bar_index, daily_open,
         color=Gdaily_color, width=4)

    var label gauge_low_label = label.new(bar_index, daily_low,
         text=str.tostring(math.round(daily_low, 0), '$0,000'),
         style=label.style_label_up,
         color=color.new(gauge_bearish_color, 80),
         textcolor=gauge_bearish_color2, size=size.small)

    box.set_lefttop    (Gauge_box_scope2, bar_index + gauge_offset - 2, daily_open)
    box.set_rightbottom(Gauge_box_scope2, bar_index + gauge_offset + 1, daily_low)
    line.set_xy1(Gauge_line_max2, bar_index + gauge_offset - 2, daily_open)
    line.set_xy2(Gauge_line_max2, bar_index + gauge_offset + 1, daily_open)
    line.set_xy1(Gauge_line_min2, bar_index + gauge_offset - 2, daily_low)
    line.set_xy2(Gauge_line_min2, bar_index + gauge_offset + 1, daily_low)
    box.set_lefttop    (Gauge_box_prc2, bar_index + gauge_offset - 1, close)
    box.set_rightbottom(Gauge_box_prc2, bar_index + gauge_offset,     daily_open)
    box.set_bgcolor    (Gauge_box_prc2, color.new(Gdaily_color, 80))
    box.set_border_color(Gauge_box_prc2, color.new(Gdaily_color, 50))
    line.set_xy1(Gauge_line_prc2, bar_index + gauge_offset - 1, close)
    line.set_xy2(Gauge_line_prc2, bar_index + gauge_offset,     close)
    line.set_color(Gauge_line_prc2, gauge_bullish_color)
    label.set_xy  (gauge_low_label, bar_index + gauge_offset - 1, daily_low)
    label.set_text(gauge_low_label, str.tostring(math.round(daily_low, 0), '$0,000'))

    var y_adjust = 1
    y_adjust := close - daily_open < 0 ? -1 : 1
    var profit_loss_label = label.new(bar_index, close,
         str.tostring(math.round(close - daily_open, 0), '$#,000'))
    label.set_xy     (profit_loss_label, bar_index + gauge_offset + 6, close + y_adjust)
    label.set_text   (profit_loss_label, str.tostring(math.round(close - daily_open, 0), '$#,000'))
    label.set_tooltip(profit_loss_label,
         str.tostring(((close - daily_open) / daily_open) * 100, format.percent) + ' ' +
         str.tostring(math.round(close - daily_open, 0), '$#,000') +
         ' from Daily Opening: ' + str.tostring(math.round(daily_open, 0), '$#,000'))
    label.set_color   (profit_loss_label, color.new(Gdaily_color, 100))
    label.set_textcolor(profit_loss_label, color.new(Gdaily_color, 0))
    label.set_size    (profit_loss_label, size.small)
    label.set_style   (profit_loss_label, label.style_label_right)
    label.set_textalign(profit_loss_label, text.align_left)

//--------------
// CLASSES
//--------------
type IntraDayRange
    array<line>  lines
    array<box>   labels
    array<label> circles

method extendLines(IntraDayRange this) =>
    if not na(this)
        for i = 0 to this.lines.size() - 1
            this.lines.get(i).set_x2(bar_index + lines_offset)
            if showLabels
                this.labels.get(i).set_right(bar_index + lines_offset)

method deleteLines(IntraDayRange this) =>
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
var collection         = array.new<IntraDayRange>(0)
var ranges             = array.new<float>(0)
var float averageRange = na
var float dayHigh      = na
var float dayLow       = na
var int   tfp          = timeframe.isintraday and not timeframe.isseconds ? int(str.tonumber(timeframe.period)) : 0

var fibMultis  = array.from(15, 25, 40, 50, 60, 75, 100, 125, 150, 175, 200)
var colors     = array.from(LevelColor0, LevelColor1, LevelColor2, LevelColor3, LevelColor4,
     LevelColor5, LevelColor6, LevelColor7, LevelColor8, LevelColor9, LevelColor10)
var fibEnabled = array.from(showLevel0, showLevel1, showLevel2, showLevel3, showLevel4,
     showLevel5, showLevel6, showLevel7, showLevel8, showLevel9, showLevel10)

//--------------
// DRAW FUNCTION
//--------------
drawLines(array<IntraDayRange> collection, float averageRange, int tfp) =>
    var IntraDayRange newIDR = na

    if session.isfirstbar and displayMode != "Hidden" and tfAllowed
        newIDR := IntraDayRange.new(
             lines   = array.new<line>(0),
             labels  = array.new<box>(0),
             circles = array.new<label>(0))

        // ── Daily open baseline ───────────────────────────────────────────────
        newIDR.lines.push(line.new(
             x1=bar_index, y1=open, x2=bar_index, y2=open,
             color=HighLight, width=lineWidth, style=line.style_dotted))

        if showCircles
            newIDR.circles.push(label.new(
                 x=bar_index - 1, y=open, text="●",
                 style=label.style_label_center,
                 color=color.new(color.black, 100),
                 size=f_circleSize(circleSize), textcolor=HighLight))

        if showLabels
            newIDR.labels.push(box.new(
                 left=bar_index, top=open + 1, right=bar_index, bottom=open,
                 bgcolor=HighLight, border_color=na,
                 text="⨁D    $" + str.tostring(open, '0,000'),
                 text_color=HighLight,
                 text_valign=text.align_center,
                 text_halign=textAlign == "Left" ? text.align_left : textAlign == "Center" ? text.align_center : text.align_right,
                 text_size=fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large))

        for i = 0 to 10
            if fibEnabled.get(i)
                float levelAbove = open + (averageRange * (fibMultis.get(i) / 100))
                float levelBelow = open - (averageRange * (fibMultis.get(i) / 100))
                color lineCol    = i == 6 ? HighLight : color.new(colors.get(i), 45)

                newIDR.lines.push(line.new(
                     x1=bar_index - 1, y1=levelAbove, x2=bar_index, y2=levelAbove,
                     style=lineStyle == "Dashed" ? line.style_dashed : lineStyle == "Solid" ? line.style_solid : line.style_dotted,
                     width=lineWidth, color=lineCol))

                if showCircles
                    newIDR.circles.push(label.new(
                         x=bar_index - 1, y=levelAbove, text="●",
                         style=label.style_label_center,
                         color=color.new(color.black, 100),
                         size=f_circleSize(circleSize), textcolor=HighLight))

                newIDR.lines.push(line.new(
                     x1=bar_index - 1, y1=levelBelow, x2=bar_index, y2=levelBelow,
                     style=lineStyle == "Dashed" ? line.style_dashed : lineStyle == "Solid" ? line.style_solid : line.style_dotted,
                     width=lineWidth, color=lineCol))

                if showCircles
                    newIDR.circles.push(label.new(
                         x=bar_index - 1, y=levelBelow, text="●",
                         style=label.style_label_center,
                         color=color.new(color.black, 100),
                         size=f_circleSize(circleSize), textcolor=HighLight))

            if showLabels
                if fibEnabled.get(i)
                    float levelAbove = open + (averageRange * (fibMultis.get(i) / 100))
                    float levelBelow = open - (averageRange * (fibMultis.get(i) / 100))

                    newIDR.labels.push(box.new(
                         left=bar_index, top=levelAbove + 1, right=bar_index, bottom=levelAbove,
                         bgcolor=color.rgb(54, 58, 69, 70), border_color=na,
                         text=i == 6 ? "▼+100%    $" + str.tostring(math.round(open + averageRange, 0), '0,000') :
                              '+' + str.tostring(fibMultis.get(i)) + "%    $" + str.tostring(math.round(levelAbove, 0), '0,000'),
                         text_color=i == 6 ? HighLight : NormalColor,
                         text_valign=text.align_bottom,
                         text_halign=textAlign == "Left" ? text.align_left : textAlign == "Center" ? text.align_center : text.align_right,
                         text_size=fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large))

                    newIDR.labels.push(box.new(
                         left=bar_index, top=levelBelow + 1, right=bar_index, bottom=levelBelow,
                         bgcolor=color.rgb(54, 58, 69, 70), border_color=na,
                         text=i == 6 ? "▲-100%    $" + str.tostring(math.round(open - averageRange, 0), '0,000') :
                              '-' + str.tostring(fibMultis.get(i)) + "%    $" + str.tostring(math.round(levelBelow, 0), '0,000'),
                         text_color=i == 6 ? HighLight : NormalColor,
                         text_valign=text.align_top,
                         text_halign=textAlign == "Left" ? text.align_left : textAlign == "Center" ? text.align_center : text.align_right,
                         text_size=fontSize == "Tiny" ? size.tiny : fontSize == "Small" ? size.small : fontSize == "Medium" ? size.normal : size.large))

        collection.push(newIDR)

    if not na(newIDR) and tfAllowed
        newIDR.extendLines()

    int maxDays = displayMode == "Today" ? 1 : displayMode == "Two Days" ? 2 : displayMode == "Week" ? 5 : 999
    if collection.size() > maxDays and displayMode != "All"
        collection.get(0).deleteLines()
        collection.shift()

//--------------
// MAIN LOGIC
//--------------
if session.isfirstbar
    ranges.push(dayHigh - dayLow)
    dayHigh := high
    dayLow  := low

    if ranges.size() > days
        ranges.shift()

    averageRange := array.avg(ranges)

if tfAllowed
    drawLines(collection, averageRange, tfp)

dayHigh := high > dayHigh ? high : dayHigh
dayLow  := low  < dayLow  ? low  : dayLow

////////////////////////////////////
//  CURRENT PRICE REFERENCE LABEL //
////////////////////////////////////

var dailyopen    = input(defval=true, title='Show Current Price Label', group='🪙 C U R R E N T - P R I C E - L A B E L')
var extend_right = input.int(defval=10, minval=1, maxval=100, title='Position (Horizontal Offset)')
var show_open    = dailyopen and timeframe.isintraday and timeframe.multiplier <= 240

DOcolor     = close >= daily_open
daily_color = DOcolor ? color.rgb(0, 255, 229) : color.rgb(255, 72, 0)

rightbar(bars) =>
    time_close + (time - time[1]) * bars

var price_label = label.new(x=rightbar(extend_right), y=close,
     text=str.tostring(close, '$0,000'),
     style=label.style_label_left,
     color=color.new(daily_color, 100),
     textcolor=daily_color,
     size=size.normal,
     xloc=xloc.bar_time)

if show_open and not barstate.isconfirmed and barstate.isrealtime
    label.set_x      (price_label, rightbar(extend_right - 11))
    label.set_y      (price_label, close)
    label.set_text   (price_label, str.tostring(close, '$0,000'))
    label.set_textcolor(price_label, daily_color)
    label.set_color  (price_label, color.new(daily_color, 100))

var price_level = label.new(x=rightbar(extend_right), y=close,
     text='⌜              ⌝\n⌞              ⌟',
     style=label.style_label_left,
     color=color.rgb(181, 212, 249, 100),
     textcolor=color.white,
     size=size.small,
     xloc=xloc.bar_time)

label.set_x(price_level, rightbar(extend_right - 11))
label.set_y(price_level, close)

////////////////////////////////////
//   END CURRENT PRICE REFERENCE  //
////////////////////////////////////

////////////////////////////////////
// BREAKOUT PROBABILITY INDICATOR //
////////////////////////////////////
// © Zeiierman

tt01 = 'The space between the levels can be adjusted with a percentage step. 1% means that each level is located 1% above/under the previous one.'
tt02 = 'Set the number of levels you want to display.'
tt03 = 'If a level got 0% likelihood of being hit, the level is not displayed as default. Enable the option if you want to see all levels regardless of their values.'
tt04 = 'Enable this option if you want to display the backtest statistics for that a new high or low is made.'
array<string> bo_tbl_tips = array.from(
     'Number of times price has reached the first highest percentage level',
     'Number of times price failed to reach the first highest percentage level',
     'Reached/Failed ratio')

showBOP       = input(title='Show Break Out Probability Meter', defval=true, group='🪙 B R E A K O U T P R O B A B I L I T Y ©Zeiierman')
perc          = input.float(0.5, title='Percentage Step', step=.1, minval=0, group='Gauge Parameters', tooltip=tt01)
nbr           = input.int(5, title='Number of Lines', maxval=5, minval=1, group='Settings', tooltip=tt02)
LabelTextSize = input.string(title='Label Size?', defval=size.small,
     options=[size.auto, size.tiny, size.small, size.normal, size.large, size.huge],
     tooltip='Use Tiny if on Mobile, Use Small if on Web browser.')

TupCol = input.color(color.rgb(186, 255, 255), title='Labels Color', inline='col')
TdnCol = input.color(color.rgb(255, 198, 198), title='', inline='col')
fill   = input.bool(false, title='Gauge Background Shade')
fill2  = input.bool(true,  title='Gauge Scale Background Shade')
upCol  = input.color(color.rgb(0, 255, 229), title='Gauge Lines/Background Color', inline='Scol')
dnCol  = input.color(color.rgb(255, 0, 0),   title='', inline='Scol')
offset = input.int(10, 'Position (Horizontal Offset)', maxval=50, minval=-1)

var array<bool> bools      = array.from(
     input.bool(false, title='Disable 0.00%',        group='Settings', tooltip=tt03),
     input.bool(false, title='Show Statistic Panel',  group='Settings', tooltip=tt04))
var array<bool> alert_bool = array.from(
     input.bool(true, title='Ticker ID',                  group='Any alert() function call'),
     input.bool(true, title='High/Low Price',             group='Any alert() function call'),
     input.bool(true, title='Bullish/Bearish Bias',       group='Any alert() function call'),
     input.bool(true, title='Bullish/Bearish Percentage', group='Any alert() function call'))

bi   = bar_index
opn  = open
hgh  = high
lw   = low
cls  = close
step = cls * (perc / 100)
shader = 0

var total  = matrix.new<int>(7, 4, 0)
var vals   = matrix.new<float>(5, 4, 0.0)
var lines  = matrix.new<line>(1, 10, line(na))
var lines2 = matrix.new<line>(1, 10, line(na))
var labels = matrix.new<label>(1, 10, label(na))
var bo_tbl = matrix.new<table>(1, 1,
     table.new(position.bottom_left, 2, 3,
      frame_color=color.rgb(19, 19, 19, 70), frame_width=3,
      border_color=chart.bg_color, border_width=-2))

green_candles = cls[1] > opn[1]
red_candles   = cls[1] < opn[1]

if green_candles
    prev = matrix.get(total, 5, 0)
    matrix.set(total, 5, 0, prev + 1)
if red_candles
    prev = matrix.get(total, 5, 1)
    matrix.set(total, 5, 1, prev + 1)

CreateLine(p, i, c) =>
    line.delete(matrix.get(lines,  0, i))
    line.delete(matrix.get(lines2, 0, i))
    li  = line.new(bi + offset + 0, p, bi + offset + 3, p, color=c, width=1, style=line.style_dotted)
    li2 = line.new(bi + offset - 2, p, bi + offset - 1, p, color=color.new(c, 100), width=1, style=line.style_dotted)
    matrix.set(lines,  0, i, li)
    matrix.set(lines2, 0, i, li2)

CreateLabel(p, i, c, r, v) =>
    label.delete(matrix.get(labels, 0, i))
    la = label.new(bi + offset + 1, p,
         text=str.tostring(matrix.get(vals, r, v), '0') + '%',
         style=label.style_label_right,
         color=color.new(color.black, 100),
         textcolor=c,
         size=LabelTextSize,
         textalign=text.align_right)
    matrix.set(labels, 0, i, la)

Score(x, i) =>
    ghh    = matrix.get(total, i, 0)
    gll    = matrix.get(total, i, 1)
    rhh    = matrix.get(total, i, 2)
    rll    = matrix.get(total, i, 3)
    gtotal = matrix.get(total, 5, 0)
    rtotal = matrix.get(total, 5, 1)
    hh = hgh >= hgh[1] + x
    ll = lw  <= lw[1]  - x
    if green_candles and hh
        matrix.set(total, i, 0, ghh + 1)
        matrix.set(vals,  i, 0, math.round((ghh + 1) / gtotal * 100, 2))
    if green_candles and ll
        matrix.set(total, i, 1, gll + 1)
        matrix.set(vals,  i, 1, math.round((gll + 1) / gtotal * 100, 2))
    if red_candles and hh
        matrix.set(total, i, 2, rhh + 1)
        matrix.set(vals,  i, 2, math.round((rhh + 1) / rtotal * 100, 2))
    if red_candles and ll
        matrix.set(total, i, 3, rll + 1)
        matrix.set(vals,  i, 3, math.round((rll + 1) / rtotal * 100, 2))

Backtest(v) =>
    p1 = matrix.get(total, 6, 0)
    p2 = matrix.get(total, 6, 1)
    if v == hgh[1]
        if hgh >= v
            matrix.set(total, 6, 0, p1 + 1)
        else
            matrix.set(total, 6, 1, p2 + 1)
    else
        if lw <= v
            matrix.set(total, 6, 0, p1 + 1)
        else
            matrix.set(total, 6, 1, p2 + 1)

Score(0,        0)
Score(step,     1)
Score(step * 2, 2)
Score(step * 3, 3)
Score(step * 4, 4)

a1 = matrix.get(vals, 0, 0)
b1 = matrix.get(vals, 0, 1)
a2 = matrix.get(vals, 0, 2)
b2 = matrix.get(vals, 0, 3)

if showBOP and tfAllowed
    for i = 0 to nbr - 1
        hide = array.get(bools, 0)
        if not hide or hide and (green_candles ? math.min(matrix.get(vals, i, 0), matrix.get(vals, i, 1)) > 0 : math.min(matrix.get(vals, i, 2), matrix.get(vals, i, 3)) > 0)
            hi = hgh[1] + step * i
            lo = lw[1]  - step * i
            CreateLine(hi, i,     color.new(upCol, shader))
            CreateLine(lo, 5 + i, color.new(dnCol, shader))
            if green_candles
                CreateLabel(hi, i,     color.new(TupCol, shader), i, 0)
                CreateLabel(lo, 5 + i, color.new(TdnCol, shader), i, 1)
            else
                CreateLabel(hi, i,     color.new(TupCol, shader), i, 2)
                CreateLabel(lo, 5 + i, color.new(TdnCol, shader), i, 3)
            shader := shader + 15
            if array.includes(alert_bool, true)
                s1 = str.tostring(syminfo.ticker)
                s2 = 'High Price: ' + str.tostring(math.round_to_mintick(hgh[1])) + ' | Low Price: ' + str.tostring(math.round_to_mintick(lw[1]))
                s3 = green_candles ? math.max(a1, b1) == a1 ? 'BULLISH' : 'BEARISH' : math.max(a2, b2) == a2 ? 'BULLISH' : 'BEARISH'
                s4 = green_candles ? math.max(a1, b1) == a1 ? a1 : b1 : math.min(a2, b2) == a2 ? a2 : b2
                s5 = red_candles   ? math.max(a2, b2) == a2 ? a2 : b2 : math.min(a1, b1) == a1 ? a1 : b1
                array<string> str_vals = array.from(s1, s2, 'BIAS: ' + s3, 'Percentage: High: ' + str.tostring(s4, format.percent) + ' | Low: ' + str.tostring(s5, format.percent))
                output = array.new_string()
                for x = 0 to array.size(alert_bool) - 1
                    if array.get(alert_bool, x)
                        array.push(output, array.get(str_vals, x))
                alert(array.join(output, '\n'), alert.freq_once_per_bar)
        else
            line.delete(matrix.get(lines,  0, i))
            line.delete(matrix.get(lines,  0, 5 + i))
            label.delete(matrix.get(labels, 0, i))
            label.delete(matrix.get(labels, 0, 5 + i))

Backtest(green_candles ? math.max(a1, b1) == a1 ? hgh[1] : lw[1] : math.max(a2, b2) == a2 ? hgh[1] : lw[1])

if fill and tfAllowed
    var filler = linefill(na)
    for i = 0 to 8
        get  = matrix.get(lines, 0, i)
        get1 = matrix.get(lines, 0, i + 1)
        col  = i > 4 ? color.new(dnCol, i * 10 + 10) : i == 4 ? color.new(color.gray, 100) : color.new(upCol, i * 10 + 65)
        filler := linefill.new(get, get1, color=col)
        linefill.delete(filler[1])

if fill2 and tfAllowed
    var filler2 = linefill(na)
    for i = 0 to 8
        get  = matrix.get(lines2, 0, i)
        get1 = matrix.get(lines2, 0, i + 1)
        col  = i > 4 ? color.new(dnCol, i * 10 + 10) : i == 4 ? color.new(color.gray, 100) : color.new(upCol, i * 10 + 65)
        filler2 := linefill.new(get, get1, color=col)
        linefill.delete(filler2[1])

if barstate.islast and array.get(bools, 1) and tfAllowed
    W  = matrix.get(total, 6, 0)
    L  = matrix.get(total, 6, 1)
    WR = math.round(W / (W + L) * 100, 2)
    array<string> bo_tbl_vals = array.from(
         'Reached: ' + str.tostring(W) + ' Times',
         'Failed: '  + str.tostring(L) + ' Times',
         'RATIO: '   + str.tostring(WR, format.percent))
    array<color> bo_tbl_col = array.from(color.rgb(2, 252, 11), color.rgb(255, 41, 41), chart.fg_color)
    for i = 0 to 2
        table.cell(matrix.get(bo_tbl, 0, 0), 0, i, array.get(bo_tbl_vals, i),
             text_halign=text.align_center, bgcolor=chart.bg_color,
             text_color=array.get(bo_tbl_col, i), text_size=size.tiny,
             tooltip=array.get(bo_tbl_tips, i))

/////////////////////////////////////////
//  END BREAKOUT PROBABILITY INDICATOR //
/////////////////////////////////////////
````
