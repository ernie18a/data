<!-- tradingview-pine-id: PUB;dac2f9229aca453f87b5f3025153027e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Heikin Ashi Lag Meter [BSL]

Source: https://www.tradingview.com/script/t25S8iqq-Heikin-Ashi-Lag-Meter-BSL/

## Description

Heikin Ashi candles look clean because they arrive late.

That is not a criticism, it is arithmetic: the transform averages, and
averaging costs time. Heikin Ashi Lag Meter [BSL] puts a number on the cost,
every single time the colour changes.

WHAT THE BOX IS

Your chart keeps its real candles. Only their colour comes from the Heikin
Ashi state, so you see the smoothing and the actual prices together instead of
choosing between them.

When the state flips, the script draws a box. It starts at the closing extreme
of the leg that just ended and runs to the bar the colour actually changed on.

That box is the part of the move that had already happened before the signal
appeared. It is what you would have missed if you had waited for the colour.

Its border is dashed, and that is deliberate. The box could only be drawn once
the flip had happened. It is a reconstruction taken backwards, not something
that was visible while the move was running. A solid border would suggest a
live region. The dashed one says: this was worked out afterwards.

READING THE NUMBER

The panel reports the median box length in bars, beside the number of flips
that median was taken over.

The smallest number it can ever report is 1. A flip is detected on the bar the
state changes, and the earliest a leg's extreme can sit is the bar before
that. So a reading of one bar means the transform was as fast as it is capable
of being: not that it was instant.

WHEN THERE IS NO NUMBER

Below the minimum flip count there is no median at all. The panel prints how
many flips it has and says so, rather than presenting the middle of three
observations as a typical value.

The leg still in progress gets no box and is not measured. Its extreme can
still move, and a box drawn over an unfinished leg would be measuring a guess.

You can cap how many boxes stay on the chart, and that cap changes what is
DRAWN and never what is COUNTED. The panel reports the full flip count beside
the number of boxes surviving the cap, so the gap between them is visible
rather than something you have to suspect.

CONTROLS

- Minimum flips before a median is shown: 5
- Keep this many lag boxes: 50
- Draw the lag regions: on
- Colour the real candles by Heikin Ashi state: on
- Panel detail: Compact
- Panel position: Bottom center

Six positions are offered. Bottom center is the default for a practical reason:
this script is meant to be read next to others, the right side is where they all
try to sit, and both left corners already have the platform's own furniture in
them.

IT WILL NOT RUN ON A HEIKIN ASHI CHART

This is the one refusal in the family with a reason that goes beyond good
practice.

The script computes the Heikin Ashi transform ITSELF, from standard candles.
On a chart already set to Heikin Ashi, the open, high, low and close it
receives have already been through the transform once. Applying it again would
compare a twice-smoothed state against bars that are not real candles. The
script would be measuring its own output and reporting the answer as a
property of the market.

So on Heikin Ashi, and equally on Renko, Kagi, Point & Figure and Range, the
paint, the boxes and the published values stop and the panel collapses to one
frozen row naming the chart type.

Switch the chart to standard candles and it works. That is the whole fix: this
tool is how you look at Heikin Ashi, not something you run inside it.

THE TWO PUBLISHED SERIES

The script publishes two series that another indicator can select in its
Source setting.

The first is the flip itself: +1 on the bar the state turns up, -1 on the bar
it turns down, 0 on every other bar. It returns to 0 between flips, so it
marks moments rather than conditions.

The second is the measured lag on those same bars.

Both carry no value at all before the script has an opinion, which is not the
same as a lag of zero. Nothing means "not measured". Zero would mean
"measured, and the lag was none", and as above that cannot happen.

The flip series is shaped for Signal Audit Lab [BSL], which can measure it
forward and report what the lateness actually cost.

Two alert conditions sit in the same list. They are not values. The candle
colouring and the lag boxes cannot be selected at all, so these two are the
whole readable surface of the script.

WHAT IT WILL NOT TELL YOU

Nothing here claims the lateness was worth paying, or was not. That is an
outcome, and this reports a distance in bars and never what followed it.

It does not judge Heikin Ashi. Lateness is measured, not scored, and a trader
who accepts the delay in exchange for fewer false turns is making a trade this
script has no opinion about. It offers no smoothing of its own, no variant
transform and no multi-timeframe version. It contains nothing you could act on
directly: no entry, no exit, no target.

This tool measures the latency of a transform. It does not predict price,
guarantee performance or provide trading advice. Validate the behaviour on
your own symbols, timeframes and execution assumptions before making
decisions.

Open-source Pine Script® v6. Educational use only.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// © BarState Labs
//@version=6
indicator("Heikin Ashi Lag Meter [BSL]", shorttitle = "BSL HA Lag", overlay = true,
     max_bars_back = 700, max_boxes_count = 500)

// Heikin Ashi candles look clean because they arrive late. This measures how
// many bars late, every single time: at each state flip it boxes the stretch
// between the closing extreme of the finished leg and the bar the colour
// actually changed on.
//
// It measures a popular tool rather than using it, and it says nothing about
// whether the lateness was worth paying. That would be an outcome claim, and
// outcomes belong to BSL-001 Signal Audit Lab, which can consume the signed
// flip stream this script publishes.

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string GROUP_MEASURE = "01 · Measurement"
string GROUP_DISPLAY = "02 · Display"

int minimumFlips = input.int(5, "Minimum flips before a median is shown", minval = 1, maxval = 1000,
     group = GROUP_MEASURE,
     tooltip = "Below this many completed flips the panel prints the raw count instead of a median. A median over two observations is a number, not a measurement.")
int boxCap = input.int(50, "Keep this many lag boxes", minval = 1, maxval = 500, group = GROUP_MEASURE,
     tooltip = "Older boxes are deleted so the drawing stays inside Pine's 500-box ceiling however long the chart. The panel always reports the full flip count, so capping the drawing never censors the statistic.")

bool showBoxes = input.bool(true, "Draw the lag regions", group = GROUP_DISPLAY)
bool showPaint = input.bool(true, "Colour the real candles by Heikin Ashi state", group = GROUP_DISPLAY,
     tooltip = "The candles stay real. Only their colour comes from the Heikin Ashi transform, so the lateness the boxes measure is visible against the prices it was late about.")
string panelDensity = input.string("Compact", "Panel detail", options = ["Compact", "Full"], group = GROUP_DISPLAY)
string panelPositionInput = input.string("Bottom center", "Panel position", options = ["Auto", "Top right", "Bottom right", "Top left", "Bottom left", "Top center", "Bottom center"],
     group = GROUP_DISPLAY, tooltip = "Auto keeps the panel opposite the latest price within the visible chart range. Pick a corner by hand when another script already occupies this one.")

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────
color COLOR_BG = color.rgb(11, 14, 13)
color COLOR_TEXT = color.rgb(242, 239, 232)
color COLOR_MUTED = color.rgb(156, 161, 154)
color COLOR_GREEN = color.rgb(82, 211, 151)
color COLOR_RED = color.rgb(239, 107, 107)
color COLOR_AMBER = color.rgb(235, 184, 87)
color COLOR_BLUE = color.rgb(104, 167, 255)

// A leg longer than this is measured over its most recent bars only. The cap
// exists because ta.highestbars reads history and Pine bounds how far back a
// script may look; it is declared here and printed on the full panel rather
// than left as an undisclosed truncation.
const int LEG_SCAN_CAP = 500

f_chart_type() =>
    chart.is_heikinashi ? "HEIKIN ASHI" :
     chart.is_renko ? "RENKO" :
     chart.is_kagi ? "KAGI" :
     chart.is_pnf ? "POINT & FIGURE" :
     chart.is_range ? "RANGE" : "NON-STANDARD"

// ─────────────────────────────────────────────────────────────────────────────
// Readiness
//
// The chart-type guard is the same rule and the same wording as
// data-trust-painter.pine, deliberately. This product computes the Heikin Ashi
// transform ITSELF from standard candles. On a chart already set to Heikin Ashi
// the built-in open, high, low and close are already synthetic, so applying the
// transform again would compare a double-transformed state against bars that
// are not real candles — it would be measuring its own output. On Renko, Kagi,
// Point & Figure and Range the bars are synthetic for other reasons and the
// same refusal applies. A user who owns both products must never see them
// disagree about whether the current chart can be measured.
// ─────────────────────────────────────────────────────────────────────────────
bool configValid = minimumFlips >= 1 and minimumFlips <= 1000 and boxCap >= 1 and boxCap <= 500
bool standardChart = chart.is_standard
bool drawable = configValid and standardChart
bool resolved = drawable and barstate.isconfirmed

// ─────────────────────────────────────────────────────────────────────────────
// The Heikin Ashi transform, on chart bars only
//
// Everything runs on the chart's own bars: there is no higher-timeframe call,
// so no lookahead question arises at all. The seed is the first bar's own open
// and close, which is the published convention and is what makes a reload
// reproduce the same series.
// ─────────────────────────────────────────────────────────────────────────────
float haClose = (open + high + low + close) / 4.0
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2.0 : (haOpen[1] + haClose[1]) / 2.0

// A body of exactly zero is 0, and 0 never flips anything: the previous state
// is held. Treating a doji as a third state would manufacture two flips where
// the transform recorded none, and every one of them would be counted and
// measured.
int haState = haClose > haOpen ? 1 : haClose < haOpen ? -1 : 0

var int lastState = na
var int legStart = 0

// Both extreme searches run in global scope on every bar. A history-dependent
// function that only runs on some bars carries a different history, and the
// length is read BEFORE legStart is updated, so on a flip bar it is the length
// of the leg that is ending.
int rawLegLength = math.max(1, bar_index - legStart)
int scanLength = math.min(LEG_SCAN_CAP, rawLegLength)
int highOffset = ta.highestbars(close[1], scanLength)
int lowOffset = ta.lowestbars(close[1], scanLength)

var int flipUpCount = 0
var int flipDownCount = 0
var int observedBars = 0
var int lastFlipBar = na
var int lastFlipLag = na
var array<float> flipLags = array.new<float>()

int flipEvent = na
int flipLag = na
int extremeBar = na

if resolved
    observedBars += 1
    flipEvent := 0
    if haState != 0
        if na(lastState)
            // The first leg begins here. There is nothing behind it to measure,
            // so this is not a flip.
            lastState := haState
            legStart := bar_index
        else if haState != lastState
            // math.abs makes the arithmetic independent of whether the offset
            // is returned as a negative or a positive number of bars back. The
            // sign convention is a documentation claim this build cannot
            // compile, and the distance is the same either way.
            int offset = math.abs(lastState > 0 ? highOffset : lowOffset)
            extremeBar := bar_index - 1 - offset
            flipLag := bar_index - extremeBar
            array.push(flipLags, float(flipLag))
            flipEvent := haState
            lastFlipBar := bar_index
            lastFlipLag := flipLag
            flipUpCount += haState > 0 ? 1 : 0
            flipDownCount += haState < 0 ? 1 : 0
            lastState := haState
            legStart := bar_index

// The emptiness guard is not redundant with the minimum. What array.median
// does with an empty array is not compiler-verified here, and a guard that
// rests on an input's minval is a guard a later edit to the input can silently
// remove.
int flipCount = array.size(flipLags)
float lagMedian = flipCount > 0 and flipCount >= minimumFlips ? array.median(flipLags) : na

// ─────────────────────────────────────────────────────────────────────────────
// Paint and lag regions
//
// barcolor has no hollow style, so the still-open bar is the same state colour
// at raised transparency. The lag region is a box with a DASHED border, which
// is a real box border style: it marks the region as a reconstruction after the
// fact rather than a live signal. Pine has no fill pattern of any kind, so the
// dashed border rather than any hatching carries that meaning.
// ─────────────────────────────────────────────────────────────────────────────
color stateColor = haState > 0 ? COLOR_GREEN : haState < 0 ? COLOR_RED : COLOR_MUTED
barcolor(showPaint and drawable ? (barstate.isconfirmed ? stateColor : color.new(stateColor, 55)) : na,
     title = "Heikin Ashi state")

var array<box> lagBoxes = array.new<box>()

if showBoxes and resolved and not na(flipEvent) and flipEvent != 0 and not na(flipLag)
    float extremeClose = close[flipLag]
    color regionColor = flipEvent > 0 ? COLOR_RED : COLOR_GREEN
// Positioned by TIME, not by bar index. A drawing whose x sits more than a
// few hundred bars from the current one is refused with runtime error
// RE10026, and that error takes the whole script's output down, not just
// the drawing. Time carries any distance.
    box drawn = box.new(time[flipLag], math.max(extremeClose, close), time,
         math.min(extremeClose, close), xloc = xloc.bar_time, border_color = regionColor,
         border_style = line.style_dashed, border_width = 1, bgcolor = color.new(regionColor, 90))
    array.push(lagBoxes, drawn)
    if array.size(lagBoxes) > boxCap
        box retired = array.shift(lagBoxes)
        box.delete(retired)

// ─────────────────────────────────────────────────────────────────────────────
// Exported streams
//
// BarState Labs producer stream contract 1.1.0, declared in
// docs/products/data-trust-painter-spec.md §5.1.
//
// The flip is a directional event and carries a signed pulse. The lag is a
// measured quantity in bars and carries a numeric-value with a domain and a
// unit. On a bar with no flip the lag stream is na, not 0: a resolved 0 would
// assert that the colour changed on the bar that set the extreme, which this
// detector can never observe. The extreme lies inside the finished leg and the
// flip is on a later bar, so the smallest measurement is 1.
// ─────────────────────────────────────────────────────────────────────────────
plot(resolved ? float(flipEvent) : na, "HA state flip", display = display.data_window)
plot(resolved and not na(flipLag) ? float(flipLag) : na, "Flip lag, bars", display = display.data_window)

alertcondition(flipEvent == 1, "Heikin Ashi flipped up",
     "Heikin Ashi Lag Meter recorded a flip to a rising state, and boxed the move that preceded it.")
alertcondition(flipEvent == -1, "Heikin Ashi flipped down",
     "Heikin Ashi Lag Meter recorded a flip to a falling state, and boxed the move that preceded it.")

// ─────────────────────────────────────────────────────────────────────────────
// Evidence panel
// ─────────────────────────────────────────────────────────────────────────────
int panelRows = not standardChart ? 1 : panelDensity == "Full" ? 11 : 8
bool inVisibleWindow = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
var float visibleWindowHigh = na
var float visibleWindowLow = na
var float visibleWindowRightClose = na
if inVisibleWindow
    visibleWindowHigh := na(visibleWindowHigh) ? high : math.max(visibleWindowHigh, high)
    visibleWindowLow := na(visibleWindowLow) ? low : math.min(visibleWindowLow, low)
    visibleWindowRightClose := close

float visibleWindowMid = not na(visibleWindowHigh) and not na(visibleWindowLow) ?
     (visibleWindowHigh + visibleWindowLow) / 2.0 : na
string automaticPanelPosition = not na(visibleWindowMid) and visibleWindowRightClose > visibleWindowMid ?
     position.bottom_right : position.top_right
string resolvedPanelPosition = panelPositionInput == "Top right" ? position.top_right :
     panelPositionInput == "Bottom right" ? position.bottom_right :
     panelPositionInput == "Top left" ? position.top_left :
     panelPositionInput == "Bottom left" ? position.bottom_left :
     panelPositionInput == "Top center" ? position.top_center :
     panelPositionInput == "Bottom center" ? position.bottom_center : automaticPanelPosition

var table panel = table.new(position.top_right, 2, panelRows, bgcolor = color.new(COLOR_BG, 3),
     border_color = color.new(COLOR_MUTED, 65), border_width = 1)

if barstate.islast
    table.set_position(panel, resolvedPanelPosition)
    if not standardChart
        table.cell(panel, 0, 0, "BSL / HA LAG · FROZEN", text_color = COLOR_AMBER,
             bgcolor = color.new(COLOR_AMBER, 78), text_size = size.small, text_halign = text.align_left)
        table.cell(panel, 1, 0, f_chart_type() + " BARS ARE SYNTHETIC · NO PAINT, NO BOXES, NO STREAMS",
             text_color = COLOR_TEXT, bgcolor = color.new(COLOR_AMBER, 78), text_size = size.small,
             text_halign = text.align_left)
    else
        bool fullPanel = panelDensity == "Full"
        string status = not configValid ? "CONFIG ERROR" :
             observedBars == 0 ? "WARM-UP · NO CLOSED BARS" :
             barstate.isconfirmed ? "CONFIRMED" : "OPEN BAR · HELD"
        color statusColor = not configValid ? COLOR_RED :
             observedBars == 0 ? COLOR_AMBER :
             barstate.isconfirmed ? COLOR_GREEN : COLOR_AMBER
        string medianText = na(lagMedian) ?
             str.tostring(flipCount) + " FLIPS · FEWER THAN " + str.tostring(minimumFlips) + " · NO MEDIAN" :
             str.tostring(lagMedian, "#.##") + " BARS OVER " + str.tostring(flipCount) + " FLIPS"
        string lastFlipText = na(lastFlipBar) ? "NONE IN LOADED HISTORY" :
             str.tostring(bar_index - lastFlipBar) + " BARS AGO · LAG " + str.tostring(lastFlipLag) + " BARS"

        table.cell(panel, 0, 0, "BSL / HA LAG", text_color = COLOR_TEXT,
             bgcolor = color.new(COLOR_BLUE, 70), text_size = size.small)
        table.cell(panel, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color = COLOR_MUTED,
             bgcolor = color.new(COLOR_BLUE, 70), text_size = size.small)
        table.cell(panel, 0, 1, "MEDIAN LAG", text_color = COLOR_MUTED, text_halign = text.align_left)
        table.cell(panel, 1, 1, medianText, text_color = na(lagMedian) ? COLOR_AMBER : COLOR_TEXT)
        table.cell(panel, 0, 2, "FLIPS UP · DOWN", text_color = COLOR_MUTED, text_halign = text.align_left)
        table.cell(panel, 1, 2, str.tostring(flipUpCount) + " · " + str.tostring(flipDownCount),
             text_color = COLOR_TEXT)
        table.cell(panel, 0, 3, "LAST FLIP", text_color = COLOR_MUTED, text_halign = text.align_left)
        table.cell(panel, 1, 3, lastFlipText, text_color = COLOR_TEXT)
        table.cell(panel, 0, 4, "BOXES DRAWN", text_color = COLOR_MUTED, text_halign = text.align_left)
        table.cell(panel, 1, 4, str.tostring(array.size(lagBoxes)) + " OF " + str.tostring(flipCount) +
             " · CAP " + str.tostring(boxCap), text_color = COLOR_TEXT)
        table.cell(panel, 0, 5, "BARS TESTED", text_color = COLOR_MUTED, text_halign = text.align_left)
        table.cell(panel, 1, 5, str.tostring(observedBars), text_color = COLOR_TEXT)
        table.cell(panel, 0, 6, "STATUS", text_color = COLOR_MUTED, text_halign = text.align_left)
        table.cell(panel, 1, 6, status, text_color = statusColor)
        if fullPanel
            table.cell(panel, 0, 7, "DELAY", text_color = COLOR_MUTED, text_halign = text.align_left)
            table.cell(panel, 1, 7, "0 BARS · KNOWN AT THE FLIP BAR'S CLOSE", text_color = COLOR_TEXT)
            table.cell(panel, 0, 8, "LEG SCAN", text_color = COLOR_MUTED, text_halign = text.align_left)
            table.cell(panel, 1, 8, "AT MOST " + str.tostring(LEG_SCAN_CAP) + " BARS BACK",
                 text_color = COLOR_TEXT)
            table.cell(panel, 0, 9, "UNFINISHED LEG", text_color = COLOR_MUTED, text_halign = text.align_left)
            table.cell(panel, 1, 9, "NOT MEASURED · NO BOX", text_color = COLOR_TEXT)

        int footerRow = fullPanel ? 10 : 7
        table.cell(panel, 0, footerRow, "TRANSFORM LATENCY", text_color = COLOR_MUTED,
             bgcolor = color.new(COLOR_BG, 0), text_size = size.tiny)
        table.cell(panel, 1, footerRow, "MEASURED BACKWARDS · NO OUTCOME CLAIM",
             text_color = COLOR_AMBER, bgcolor = color.new(COLOR_BG, 0), text_size = size.tiny)
````
