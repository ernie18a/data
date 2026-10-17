# [SkuldX] FVG & Session Opens

- url: https://www.tradingview.com/script/TR4Cr2sJ-SkuldX-FVG-Session-Opens/
- type: indicator
- pine_id: PUB;ddd5f5d1cbbd4d34890974acccbdf4d0
- version: 1.0

## Description

SkuldX FVG & Session Opens — Institutional Imbalance Zones
by SkuldX Trading Systems

What is it?
SkuldX FVG & Session Opens combines two core concepts of institutional price analysis: true session opening levels and Fair Value Gaps. Together they identify where the market opened and where the first imbalance formed — giving traders a structural edge at the start of every session.

Session Opens
TDO (True Day Open) — marks 00:00 NY time, the true start of the trading day. The line extends to the right and updates its label dynamically as price moves, always showing the current distance from the open.
TWO (True Weekly Open) — marks the opening of a chosen day and time in NY timezone. Fully configurable: choose any day of the week and any hour/minute. Defaults to Monday 18:00 NY — the standard weekly open used by institutional traders.
Both lines are customizable in color, style, and width, with labels anchored to the right edge for clean chart readability.

Fair Value Gaps
A Fair Value Gap is a three-candle imbalance where price moves so aggressively that a gap forms between the first and third candle. These zones often act as high-probability targets for price to return and rebalance.
TWO FVG — detected on the first candle after the weekly open. This zone represents the initial weekly imbalance and remains visible for the entire week as a key reference level.
TDO First FVG — detected on the first candle after the daily open. Marks the initial daily imbalance and holds for the full session.
TDO Live FVG — recalculates every 3 bars throughout the day, always showing the most recent imbalance zone. Updates automatically — old zone is replaced as new imbalances form.
Bullish FVGs appear in green, bearish in red. Each zone is labeled inside the box for instant identification.

Settings
TDO / TWO — toggle visibility, color, line style and width per session
TWO Day of Week — choose which day triggers the weekly open (Sunday through Saturday)
TWO Hour / Minute — precise NY time for the weekly open
Show TDO First FVG — toggle the daily anchor imbalance zone
Show TDO Live FVG — toggle the rolling 3-bar imbalance zone
Show TWO FVG — toggle the weekly imbalance zone
Bullish / Bearish / Live FVG Colors — independent color control per zone type

Notes
Best used on 1h or lower timeframes where individual session opens and intraday FVGs are clearly visible. On higher timeframes the TWO FVG is the primary reference — the weekly imbalance zone that price frequently revisits before continuing its directional move.

Built for SkuldX ecosystem
Session opens and FVG zones are core inputs to SkuldX automated trading logic. Bots built on the SkuldX infrastructure use these levels for entry timing, stop placement, and target identification.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © skuldxtrade

//@version=6
indicator("[SkuldX] FVG & Session Opens", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ══════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════

showTDO         = input.bool(true,          "Show TDO (Daily Open 00:00 NY)",   group = "TDO")
colorTDO        = input.color(color.white,  "Color",                            group = "TDO")
styleTDO        = input.string("solid",     "Style",                            group = "TDO", options = ["solid", "dashed", "dotted"])
widthTDO        = input.int(1,              "Width",                            group = "TDO", minval = 1, maxval = 4)
showTDOFVG      = input.bool(true,          "Show TDO First FVG (daily)",       group = "TDO")
showTDOFVGLive  = input.bool(true,          "Show TDO Live FVG (every 3 bars)", group = "TDO")

showTWO         = input.bool(true,          "Show Weekly Open",                 group = "TWO")
colorTWO        = input.color(color.yellow, "Color",                            group = "TWO")
styleTWO        = input.string("solid",     "Style",                            group = "TWO", options = ["solid", "dashed", "dotted"])
widthTWO        = input.int(2,              "Width",                            group = "TWO", minval = 1, maxval = 4)
twoDayInput     = input.string("Monday",    "Day of Week",                      group = "TWO", options = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"])
twoHourInput    = input.int(18,             "Hour (NY time)",                   group = "TWO", minval = 0, maxval = 23)
twoMinInput     = input.int(0,              "Minute (NY time)",                 group = "TWO", minval = 0, maxval = 59)
showTWOFVG      = input.bool(true,          "Show TWO First FVG (weekly)",      group = "TWO")

colorBullFVG    = input.color(color.new(color.green, 70), "Bullish FVG",        group = "FVG")
colorBearFVG    = input.color(color.new(color.red,   70), "Bearish FVG",        group = "FVG")
colorLiveFVG    = input.color(color.new(color.blue,  70), "Live FVG (TDO)",     group = "FVG")


// ══════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════

// Converts string style input to PineScript line style constant
lineStyle(string s) =>
    switch s
        "dashed" => line.style_dashed
        "dotted" => line.style_dotted
        =>          line.style_solid

// NY time helpers — DST-aware via timezone string
nyHour()      => hour(time,      "America/New_York")
nyMinute()    => minute(time,    "America/New_York")
nyDayOfWeek() => dayofweek(time, "America/New_York")

// Converts day-of-week string input to PineScript dayofweek constant
dayStringToInt(string d) =>
    switch d
        "Sunday"    => dayofweek.sunday
        "Monday"    => dayofweek.monday
        "Tuesday"   => dayofweek.tuesday
        "Wednesday" => dayofweek.wednesday
        "Thursday"  => dayofweek.thursday
        "Friday"    => dayofweek.friday
        =>             dayofweek.saturday

// FVG calculation across three candles [2], [1], [0]
// Bullish FVG: gap between high[2] and low[0] when middle candle is bullish
// Bearish FVG: gap between high[0] and low[2] when middle candle is bearish
// Returns: fvgTop, fvgBot, isBull, valid
calcFVG() =>
    bool  bullish = low[0]  > high[2] and close[1] > open[1]
    bool  bearish = high[0] < low[2] and close[1] < open[1]

    float fvgTop  = bullish ? low[0]  : bearish ? low[2]  : na
    float fvgBot  = bullish ? high[2] : bearish ? high[0] : na

    bool  isBull  = bullish
    bool  valid   = bullish or bearish
    
    [fvgTop, fvgBot, isBull, valid]


// ══════════════════════════════════════════════════════
// STATE: TWO (Time-based Weekly Open)
// Tracks the weekly open price, line, label, and first FVG
// ══════════════════════════════════════════════════════

var float twoPrice       = na
var line  twoLine        = na
var label twoLbl         = na

// First valid FVG after TWO — persists until the next weekly open
var box   twoFirstFvgBox = na
var bool  twoFvgSet      = false

// Bar counter since TWO — used to gate FVG search timing
var int   twoBarCount    = 0
var bool  twoActive      = false


// ══════════════════════════════════════════════════════
// TWO LOGIC + TWO FVG
// ══════════════════════════════════════════════════════

int  twoDayTarget = dayStringToInt(twoDayInput)
bool isTWO        = nyHour()      == twoHourInput and
                     nyMinute()    == twoMinInput   and
                     nyDayOfWeek() == twoDayTarget

// On TWO bar: reset state, record open price, draw line and label
if isTWO
    twoPrice    := open
    twoBarCount := 0
    twoActive   := true
    twoFvgSet   := false

    line.delete(twoLine)
    label.delete(twoLbl)
    box.delete(twoFirstFvgBox)
    twoFirstFvgBox := na

    if showTWO
        twoLine := line.new(
             x1     = time,
             y1     = twoPrice,
             x2     = time,
             y2     = twoPrice,
             xloc   = xloc.bar_time,
             color  = colorTWO,
             style  = lineStyle(styleTWO),
             width  = widthTWO,
             extend = extend.none)
       
        twoLbl := label.new(
             x         = time,
             y         = twoPrice,
             text      = twoDayInput + " TWO  " + str.tostring(twoPrice, format.mintick),
             style     = label.style_label_left,
             color     = color.new(colorTWO, 85),
             textcolor = colorTWO,
             size      = size.small,
             xloc      = xloc.bar_time)

// Extend TWO line and label rightward on every bar
if showTWO and not na(twoLine)
    line.set_x2(twoLine, time + timeframe.in_seconds() * 1000 * 8)
    if not na(twoLbl)
        label.set_x(twoLbl, time + timeframe.in_seconds() * 1000 * 8)

// Increment bar counter after TWO opens
if twoActive and not isTWO
    twoBarCount += 1

// TWO First FVG: search for the first valid FVG after the weekly open
// Once found, locked in for the remainder of the week
if showTWOFVG and twoActive and not twoFvgSet // and twoBarCount >= 1
    [fTop, fBot, fBull, fValid] = calcFVG()
    if fValid
        twoFvgSet      := true
        twoFirstFvgBox := box.new(
             left         = bar_index[2],
             top          = fTop,
             right        = bar_index,
             bottom       = fBot,
             bgcolor      = fBull ? colorBullFVG : colorBearFVG,
             border_color = fBull ? color.new(color.green, 40) : color.new(color.red, 40),
             border_width = 1,
             extend       = extend.none,
             text         = "TWO FVG",
             text_color   = color.white,
             text_size    = size.small,
             text_halign  = text.align_center,
             text_valign  = text.align_center)

// Extend TWO FVG box rightward to keep it visible through the week
if showTWOFVG and not na(twoFirstFvgBox)
    box.set_right(twoFirstFvgBox, bar_index + 8)


// ══════════════════════════════════════════════════════
// STATE: TDO (Time-based Daily Open)
// Tracks the daily open at 00:00 NY, first FVG, and live FVG
// ══════════════════════════════════════════════════════

var float tdoPrice       = na
var line  tdoLine        = na
var label tdoLbl         = na

// First FVG of the day — locked in once found, persists until next TDO
var box   tdoFirstFvgBox = na
var bool  tdoFirstFvgSet = false

// Live FVG — recalculated every 3 bars after TDO, replaces the previous one
var box   tdoLiveFvgBox  = na

// Bar counter since TDO — controls live FVG update frequency
var int   tdoBarCount    = 0
var bool  tdoActive      = false


// ══════════════════════════════════════════════════════
// TDO LOGIC + TDO FVG
// ══════════════════════════════════════════════════════

bool isTDO = nyHour() == 0 and nyMinute() == 0

// On TDO bar: reset all daily state, record open price, draw line and label
if isTDO
    tdoPrice       := open
    tdoBarCount    := 0
    tdoActive      := true
    tdoFirstFvgSet := false

    line.delete(tdoLine)
    label.delete(tdoLbl)
    box.delete(tdoFirstFvgBox)
    box.delete(tdoLiveFvgBox)
    tdoFirstFvgBox := na
    tdoLiveFvgBox  := na

    if showTDO
        tdoLine := line.new(
             x1     = time,
             y1     = tdoPrice,
             x2     = time,
             y2     = tdoPrice,
             xloc   = xloc.bar_time,
             color  = colorTDO,
             style  = lineStyle(styleTDO),
             width  = widthTDO,
             extend = extend.none)

        tdoLbl := label.new(
             x         = time,
             y         = tdoPrice,
             text      = "TDO  " + str.tostring(tdoPrice, format.mintick),
             style     = label.style_label_left,
             color     = color.new(colorTDO, 85),
             textcolor = colorTDO,
             size      = size.small,
             xloc      = xloc.bar_time)

// Extend TDO line and label rightward on every bar
if showTDO and not na(tdoLine)
    line.set_x2(tdoLine, time + timeframe.in_seconds() * 1000 * 8)
    if not na(tdoLbl)
        label.set_x(tdoLbl, time + timeframe.in_seconds() * 1000 * 8)

// Increment bar counter after TDO opens
if tdoActive and not isTDO
    tdoBarCount += 1

// TDO First FVG: search for the first valid FVG after the daily open
// Once found, locked in and extended to end of day
if showTDOFVG and tdoActive and not tdoFirstFvgSet // and tdoBarCount >= 1
    [fTop, fBot, fBull, fValid] = calcFVG()
    if fValid
        tdoFirstFvgSet := true
        tdoFirstFvgBox := box.new(
             left         = bar_index[2],
             top          = fTop,
             right        = bar_index,
             bottom       = fBot,
             bgcolor      = fBull ? colorBullFVG : colorBearFVG,
             border_color = fBull ? color.new(color.green, 40) : color.new(color.red, 40),
             border_width = 1,
             extend       = extend.none)

// Extend first FVG box rightward to end of day
if showTDOFVG and not na(tdoFirstFvgBox)
    box.set_right(tdoFirstFvgBox, bar_index)

// TDO Live FVG: recalculates every 3 bars after TDO
// Replaces the previous live FVG box each time a new one is found
if showTDOFVGLive and tdoActive and tdoBarCount >= 3 and tdoBarCount % 3 == 0
    [fTop, fBot, fBull, fValid] = calcFVG()
    if fValid
        box.delete(tdoLiveFvgBox)
        tdoLiveFvgBox := box.new(
             left         = bar_index[2],
             top          = fTop,
             right        = bar_index,
             bottom       = fBot,
             bgcolor      = fBull ? colorBullFVG : colorBearFVG,
             border_color = fBull ? color.new(color.green, 40) : color.new(color.red, 40),
             border_width = 1,
             extend       = extend.none,
             text         = "TWD FVG",
             text_color   = color.white,
             text_size    = size.small,
             text_halign  = text.align_center,
             text_valign  = text.align_center)

// Extend both FVG boxes rightward to stay visible on current bar
if showTDOFVG and not na(tdoFirstFvgBox)
    box.set_right(tdoFirstFvgBox, bar_index + 8)

if showTDOFVGLive and not na(tdoLiveFvgBox)
    box.set_right(tdoLiveFvgBox, bar_index + 8)
````
