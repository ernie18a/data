<!-- tradingview-pine-id: PUB;bb40574b65b74cbf93c298d9cb9ad54c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Warm-Up Curtain [BSL]

Source: https://www.tradingview.com/script/Z2Kg0uSJ-Warm-Up-Curtain-BSL/

## Description

Put a 200-period average on a 300-bar chart and the left third of that line is
made of almost nothing. It is drawn with the same confidence as the rest.

Warm-Up Curtain [BSL] greys out the part of the chart where an indicator you
connected had not yet seen enough data to mean anything, and it draws a
second, lighter band at the right edge for a confirmation lag you tell it
about.

The two edges are drawn differently, and that difference is the point.

THE LEFT EDGE IS SOLID BECAUSE IT WAS SEEN

An indicator that has not warmed up returns nothing at all: not zero, nothing.
The script watches for the bar on which that stops being true, and that bar is
the edge. It was observed happening, on a specific bar, and the boundary is
drawn as a solid line.

Connect up to three indicators and the curtain dims everything before the
LATEST of their three edges, because a chart is only as warmed up as its
slowest input. A three-row panel prints how many bars each one needed.

THE RIGHT EDGE IS DASHED BECAUSE YOU ASSERTED IT

Some tools only confirm a reading several bars after the fact. That delay
cannot be recovered from a chart: in settled history a confirmed value and an
unconfirmed one look identical, and a +1 is a +1 whether it was known on the
day or three days later.

So you type the number in, and the band it produces is bounded by a DASHED
line. Nothing about it was measured. It is your claim, and it is drawn as one.

The lag defaults to zero, which means no band and no dashed edge at all, and
the panel says NONE DECLARED. A non-zero default would be this script
asserting a delay on your behalf, which is exactly the thing the dashed line
exists to prevent.

You can tell the observed edge from the asserted one without reading a word.

CONNECTING, AND SWITCHING OFF WHAT YOU ARE NOT USING

Each of the three slots has its own on/off switch. This is not tidiness, it is
correctness.

An empty connection does not stay empty. TradingView falls back to the chart's
own closing price, which is valid from the very first bar, so a slot you left
connected to nothing would report a warm-up of zero bars, and that would be a
measurement of the fallback rather than of your indicator. A slot you are not
using should be switched off. It then prints OFF and publishes nothing.

Only indicators that are already on the chart appear in the Source dropdown.
If the one you want is missing from the list, add it to the chart first.

DIMMED, NOT HIDDEN

The greyed region stays readable. You can still see the indicator drawn there
and judge it yourself; the curtain tells you how thin the ground under it is,
it does not take the evidence away.

If a connected series never produces a value across the whole loaded history,
the entire chart greys. That is the correct answer rather than a failure:
nothing on this chart has warmed up.

The bar counts are measured from the first LOADED bar, not from the
instrument's first ever bar. Scroll further back and they change.

THE SETTINGS AND THEIR DEFAULTS

- Measure series 1: on, connected to the chart's close
- Measure series 2: off
- Measure series 3: off
- Confirmation lag you declare: 0 bars
- Draw the two boundary lines: on
- Panel position: Bottom center

Any of six positions will do. Bottom center is the starting point by
elimination: the legend and the trading buttons occupy the top left, the
platform's own logo occupies the bottom left, and the price scale owns the
right-hand side.

WHY THIS ONE KEEPS WORKING ON HEIKIN ASHI AND RENKO

Most tools in this family stop on Heikin Ashi, Renko, Kagi, Point & Figure and
Range charts, because each of them measures a property of a bar and a
constructed bar has different properties.

This one does not stop, and the reason is worth stating rather than leaving as
an inconsistency. It does not measure bars at all. It measures when a
connected indicator started producing values, a fact about that indicator, on
whatever bars the chart happens to be made of, and equally true on constructed
ones. The panel names the chart type so you always know what you are looking
at.

WHAT IS PUBLISHED

Three values are published for other indicators to pick up in their Source
setting: the first valid bar for each of the three slots. A slot that is
switched off, or a configuration that does not make sense, publishes nothing
at all. That is not the same as a first valid bar of zero. Nothing means "not
measured". Zero would mean "valid from the very first bar".

The alert condition appears in that dropdown as well. It is not a reading.
Nothing else this script draws can be selected, because a shaded region and a
boundary line are not series.

WHAT IT WILL NOT TELL YOU

It makes no claim about the market: not a direction, not an outcome, not a
reading of any kind. It contains no entry, exit, stop or target, because it is
not about trades.

It will not guess your confirmation lag. And it does not judge the chart's own
bars: data holes, frozen prices and defective candles are a separate question,
at a different granularity, with a different remedy, handled by a different
tool.

This tool describes when connected indicators became valid. It does not
predict price, guarantee performance or provide trading advice. Validate the
behaviour on your own symbols, timeframes and execution assumptions before
making decisions.

Open-source Pine Script® v6. Educational use only.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// © BarState Labs
//@version=6
indicator("Warm-Up Curtain [BSL]", shorttitle = "BSL Warm-Up", overlay = true, max_bars_back = 600)

// Warm-Up Curtain greys out the part of the chart where a connected indicator
// had not yet seen enough data to mean anything, and marks a second band for the
// confirmation lag the user declares.
//
// The two boundaries are drawn differently on purpose. The warm-up edge is a
// SOLID line because it was observed: an un-warmed series emits na, so the
// script watched the first valid bar happen. The declared-lag edge is DASHED
// because it was asserted: a +1 looks identical at any lag, so a live lag cannot
// be recovered from settled history and this product never infers one.

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string GROUP_SERIES = "01 · Connected series"
string GROUP_LAG = "02 · Declared lag"
string GROUP_DISPLAY = "03 · Display"

bool useA = input.bool(true, "Measure series 1", group = GROUP_SERIES,
     tooltip = "Leave a slot off when nothing is connected to it. An unconnected input.source() falls back to a built-in price series, which is valid from the first bar, and reporting that as a zero-bar warm-up would be a measurement of the fallback rather than of your indicator.")
float sourceA = input.source(close, "Series 1", group = GROUP_SERIES)
bool useB = input.bool(false, "Measure series 2", group = GROUP_SERIES)
float sourceB = input.source(close, "Series 2", group = GROUP_SERIES)
bool useC = input.bool(false, "Measure series 3", group = GROUP_SERIES)
float sourceC = input.source(close, "Series 3", group = GROUP_SERIES)

int declaredLag = input.int(0, "Confirmation lag you declare, bars", minval = 0, maxval = 500, group = GROUP_LAG,
     tooltip = "Bars at the right edge that your signal cannot confirm yet. The product never infers this number, because a confirmed value and an unconfirmed one look identical in settled history. It is drawn with a dashed edge for that reason: the warm-up edge was measured, this one was typed in.")

bool showBoundaries = input.bool(true, "Draw the two boundary lines", group = GROUP_DISPLAY)
string panelPositionInput = input.string("Bottom center", "Panel position", options = ["Auto", "Top right", "Bottom right", "Top left", "Bottom left", "Top center", "Bottom center"],
     group = GROUP_DISPLAY, tooltip = "Auto keeps the panel opposite the latest price within the visible chart range. Pick a corner by hand when another script already occupies this one.")

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────
color COLOR_BG = color.rgb(11, 14, 13)
color COLOR_TEXT = color.rgb(242, 239, 232)
color COLOR_MUTED = color.rgb(156, 161, 154)
color COLOR_GREEN = color.rgb(82, 211, 151)
color COLOR_AMBER = color.rgb(235, 184, 87)
color COLOR_BLUE = color.rgb(104, 167, 255)
color COLOR_CURTAIN = color.rgb(156, 161, 154)

f_chart_type() =>
    chart.is_heikinashi ? "HEIKIN ASHI" :
     chart.is_renko ? "RENKO" :
     chart.is_kagi ? "KAGI" :
     chart.is_pnf ? "POINT & FIGURE" :
     chart.is_range ? "RANGE" : "NON-STANDARD"

// ─────────────────────────────────────────────────────────────────────────────
// The observed warm-up
//
// Per series a var int records the first bar_index at which the value stopped
// being na, and it is never rewritten. That is the whole measurement: the
// product watches the transition happen rather than deducing it.
//
// This product deliberately carries NO chart-type refusal. Its subject is a
// connected series, not the chart's own bars: an indicator that emitted na for
// forty bars emitted na for forty bars whether those bars were standard candles
// or Renko bricks, so refusing here would suppress a true statement. The panel
// names the chart type instead, so a reader knows what the count counts.
// ─────────────────────────────────────────────────────────────────────────────
int enabledCount = (useA ? 1 : 0) + (useB ? 1 : 0) + (useC ? 1 : 0)
bool configValid = enabledCount >= 1 and declaredLag >= 0 and declaredLag <= 500

var int firstA = na
var int firstB = na
var int firstC = na

// The bar TIME of each transition is recorded beside its index. A boundary can
// sit thousands of bars behind the last one, and a drawing positioned by
// `xloc.bar_index` is refused at that distance with a runtime error that takes
// the whole script's output down with it. Time carries any distance.
var int firstTimeA = na
var int firstTimeB = na
var int firstTimeC = na

if configValid
    if useA and na(firstA) and not na(sourceA)
        firstA := bar_index
        firstTimeA := time
    if useB and na(firstB) and not na(sourceB)
        firstB := bar_index
        firstTimeB := time
    if useC and na(firstC) and not na(sourceC)
        firstC := bar_index
        firstTimeC := time

bool pendingAny = configValid and ((useA and na(firstA)) or (useB and na(firstB)) or (useC and na(firstC)))

int contribA = useA and not na(firstA) ? firstA : -1
int contribB = useB and not na(firstB) ? firstB : -1
int contribC = useC and not na(firstC) ? firstC : -1
int knownMax = math.max(contribA, contribB, contribC)

// While any enabled series has still not produced a value the curtain keeps
// painting, so a series that is na across the whole loaded history greys the
// entire chart instead of failing quietly.
bool curtain = configValid and (pendingAny or (knownMax >= 0 and bar_index < knownMax))
int boundary = configValid and not pendingAny and knownMax >= 0 ? knownMax : na

// The same choice, in time. Whichever series produced the binding index also
// produced the binding time, so the two never disagree about which bar the
// boundary sits on.
int boundaryTime = na(boundary) ? na :
     boundary == contribA ? firstTimeA :
     boundary == contribB ? firstTimeB : firstTimeC

// The right-hand band is a different kind of object: it is drawn from the
// declared number alone and is anchored to the chart's last bar, so it is a
// right-edge marker rather than an observation about any particular bar.
int bandStart = declaredLag > 0 ? last_bar_index - declaredLag + 1 : na
int bandStartTime = declaredLag > 0 ? time[math.min(declaredLag - 1, bar_index)] : na
bool lagBand = configValid and declaredLag > 0 and bar_index >= bandStart

// One bgcolor call, two densities. The warm-up wash wins where the two overlap,
// because a bar that has no indicator value yet is the stronger statement.
bgcolor(curtain ? color.new(COLOR_CURTAIN, 82) : lagBand ? color.new(COLOR_CURTAIN, 91) : na,
     title = "Warm-up and declared lag")

// ─────────────────────────────────────────────────────────────────────────────
// Exported streams
//
// BarState Labs producer stream contract 1.1.0, declared in
// docs/products/data-trust-painter-spec.md §5.1. Three numeric-value streams,
// domain nonnegative-integer, units chart bar_index, all delay 0.
//
// na means the product has no opinion yet: the slot is off, the configuration
// is invalid, or that series has not yet produced a value. A consumer must not
// read it as bar 0 or carry it forward with nz().
// ─────────────────────────────────────────────────────────────────────────────
plot(configValid and useA ? float(firstA) : na, "Series 1 first valid bar index", display = display.data_window)
plot(configValid and useB ? float(firstB) : na, "Series 2 first valid bar index", display = display.data_window)
plot(configValid and useC ? float(firstC) : na, "Series 3 first valid bar index", display = display.data_window)

// The alert fires once, on the bar the last pending series produced a value.
// A var latch rather than pendingAny[1], because a bool series has no history
// on the first bar and the alert must not depend on how that reads.
var bool warmUpAnnounced = false
bool justWarmedUp = configValid and not pendingAny and not warmUpAnnounced
if justWarmedUp
    warmUpAnnounced := true

alertcondition(justWarmedUp, "Every connected series has warmed up",
     "Warm-Up Curtain saw the last of its connected series produce a value.")

// ─────────────────────────────────────────────────────────────────────────────
// Boundaries and readout
//
// Two line objects, created once and re-used, against the v6 ceiling of 500 per
// type. Nothing is created on a historical bar, so the budget does not grow with
// history. line.style_dashed genuinely exists for line objects, which is what
// makes the observed / asserted distinction drawable at all.
// ─────────────────────────────────────────────────────────────────────────────
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

var line observedLine = na
var line declaredLine = na

if barstate.islast and showBoundaries
    float lineTop = na(visibleWindowHigh) ? high : visibleWindowHigh
    float lineBottom = na(visibleWindowLow) ? low : visibleWindowLow
    line.delete(observedLine)
    line.delete(declaredLine)
    if not na(boundaryTime) and not na(boundary) and boundary > 0
        // Solid: this edge was observed on a specific bar.
        observedLine := line.new(boundaryTime, lineBottom, boundaryTime, lineTop,
             xloc = xloc.bar_time, extend = extend.both, color = COLOR_GREEN,
             style = line.style_solid, width = 1)
    if not na(bandStartTime) and configValid
        // Dashed: this edge was asserted by the user and cannot be checked.
        declaredLine := line.new(bandStartTime, lineBottom, bandStartTime, lineTop,
             xloc = xloc.bar_time, extend = extend.both, color = COLOR_AMBER,
             style = line.style_dashed, width = 1)

// ─────────────────────────────────────────────────────────────────────────────
// Evidence panel
//
// Six cells, which is the declared budget. Each connected series' warm-up is
// printed as a count, the declared lag is printed beside the word that says who
// asserted it, and the curtain row says what is greyed and that it is dimmed
// rather than hidden.
// ─────────────────────────────────────────────────────────────────────────────
f_series_cell(bool used, int first) =>
    not used ? "OFF" : na(first) ? "NEVER VALID" : str.tostring(first)

var table panel = table.new(position.top_right, 2, 3, bgcolor = color.new(COLOR_BG, 3),
     border_color = color.new(COLOR_MUTED, 65), border_width = 1)

if barstate.islast
    table.set_position(panel, resolvedPanelPosition)
    string warmUpText = f_series_cell(useA, firstA) + " · " + f_series_cell(useB, firstB) + " · " +
         f_series_cell(useC, firstC) + " BARS · OBSERVED"
    string lagText = declaredLag == 0 ? "NONE DECLARED · NO DASHED EDGE" :
         str.tostring(declaredLag) + " BARS · ASSERTED BY YOU · DASHED EDGE"
    string chartNote = chart.is_standard ? "" : " · " + f_chart_type() + " BARS"
    string curtainText = not configValid ? "CONFIG ERROR · CONNECT AT LEAST ONE SERIES" :
         pendingAny ? "WHOLE CHART · A CONNECTED SERIES IS STILL EMPTY" :
         boundary == 0 ? "NOTHING GREYED · EVERY SERIES WAS VALID AT BAR 0" :
         "BARS 0 TO " + str.tostring(boundary - 1) + " · DIMMED, NOT HIDDEN"
    color curtainColor = not configValid ? color.rgb(239, 107, 107) :
         pendingAny ? COLOR_AMBER : boundary == 0 ? COLOR_GREEN : COLOR_TEXT

    table.cell(panel, 0, 0, "BSL / WARM-UP · S1 · S2 · S3", text_color = COLOR_TEXT,
         bgcolor = color.new(COLOR_BLUE, 70), text_size = size.small, text_halign = text.align_left)
    table.cell(panel, 1, 0, warmUpText, text_color = COLOR_GREEN,
         bgcolor = color.new(COLOR_BLUE, 70), text_size = size.small, text_halign = text.align_left)
    table.cell(panel, 0, 1, "DECLARED LAG", text_color = COLOR_MUTED, text_halign = text.align_left)
    table.cell(panel, 1, 1, lagText, text_color = declaredLag == 0 ? COLOR_MUTED : COLOR_AMBER,
         text_halign = text.align_left)
    table.cell(panel, 0, 2, "CURTAIN", text_color = COLOR_MUTED, text_halign = text.align_left)
    table.cell(panel, 1, 2, curtainText + chartNote, text_color = curtainColor, text_halign = text.align_left)
````
