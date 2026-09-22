<!-- tradingview-pine-id: PUB;0d411a0d94784f328daba1001622c824 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Tail Range Percentile Radar [Pineify]

Source: https://www.tradingview.com/script/NBAp559r-Tail-Range-Percentile-Radar-Pineify/

## Description

Tail Range Percentile Radar [Pineify]

Overview
Tail Range Percentile Radar separates candle rarity from candle shape. Four aligned scan lanes compare true range, real body, upper wick and lower wick with their own recent histories. It describes anatomy, not the next move.

Problem Definition
An ATR multiple measures distance from an average, but the same multiple can occur in very different distributions. A long range may also be mostly gap, body or wick. A wick-to-body ratio alone is unstable near a doji and says nothing about historical rarity. Ask two questions: is this component unusual, and does it occupy enough of this candle to matter?

Design Rationale
Separate ranks preserve anatomy hidden by one volatility score. The candidate is excluded from its reference window so an extreme cannot alter its own baseline. Half-weight ties avoid treating repeated tick sizes as distinct observations. A minimum high-low share rejects historically rare but visually trivial parts. Averaging all four ranks was rejected because a large body could mask an exceptional wick; retaining four lanes costs screen space but preserves the reason for each event.

Key Features

[*]Four prior-only percentile populations with explicit zero handling.
[*]Independent range and share-qualified body or wick flags.
[*]A confirmed anatomy strip, three close-only alerts and optional statistics.

How It Works
TR is the largest of high-low, the distance from high to the previous close, and the distance from low to the previous close. Body is absolute close-open; wicks are the distances from the body edges to high and low. Each magnitude is rounded to the symbol's tick size. Its rank is 100 times the count of smaller prior values plus half the equal values, divided by N. Zero parts receive zero. All N preceding bars must have valid OHLC and previous-close data; invalid coverage leaves every lane blank.

A flag needs rank at or above Q. Body and wick flags additionally need their configured share of high-low; a zero high-low gives zero shares. Tail flags do not require extreme TR. The displayed type prioritizes dual tail, upper tail, lower tail, directional body, gap-led range, then range only. Gap-led requires extreme TR and at least 35% of TR outside high-low. Component flags remain independent of this display priority.

How Multiple Indicators Work Together
The four measurements are one candle decomposition, not unrelated trading signals. Rank supplies historical context; share supplies geometric relevance; their conjunction supplies body and tail flags. TR retains total movement, including movement beyond high-low relative to the previous close. Without share, tiny parts can be highlighted; without separate ranks, unusual anatomy disappears inside a single range score.

Trading Ideas and Insights
An upper-tail event identifies an unusually large upper wick, not proven selling pressure or a short entry. A lower tail is equally descriptive. Compare a tail inside ordinary TR with a range event dominated by a body: the patterns answer different anatomy questions. Clusters invite chart review but do not establish reversal odds.

Unique Aspects
Relative to an ATR threshold or candle ratio, the added mechanism is a prior-only, tie-aware four-population comparison with geometric qualification and explicit mixed-tail precedence. It preserves tail rarity even when total range is ordinary. Zero suppression prevents absent wicks from becoming exceptional merely because a reference sample contains many zeros.

How to Use
Read the lanes from top to bottom: gold TR, purple body, orange upper wick, teal lower wick. Each uses its own zero baseline and equal height for 0-100; stacked positions are not a shared numeric axis. Dashed rails mark Q, vivid columns show qualifying components and dots confirm them at close. Use the table or Data Window for actual ranks and anatomy codes. The diamond strip marks the selected closed-bar type.

Customization
Start with N=200, Q=95, wick share=20% and body share=55%; these are design starting points, not optimized settings. Shorter N responds sooner but uses fewer comparisons; higher Q or shares rejects more bars. The statistics window defaults to 100 chart bars. Its rates use eligible closed bars, with sample coverage shown; overlapping flags can sum above 100%. Guides, tips, strip, table and four colors are configurable.

Assumptions and Limitations
Use standard OHLC charts; synthetic candles change the meaning of anatomy. Price scale changes, splits, session gaps, stale bars and regime shifts can distort the raw-size reference. No volume or order-flow data is used. Rank 95 is a sample comparison, not a 5% future probability; it also does not measure how far beyond history a new maximum lies. At least N valid prior observations plus previous-close coverage are needed. Live ranks, shading and table type can change intrabar; tips, strip and alerts require close. Alerts apply to every qualifying closed bar, so consecutive bars can each alert and dual tails can trigger both tail alerts. Choose once per bar close. Parameters, chart history and feed revisions can change results. There is no entry, exit, profitability or reversal model.

Conclusion
The range percentile radar distinguishes unusual total movement from unusual candle parts while keeping rarity and shape separate. Use it as a compact explanation of observed tail volatility, with independent decision rules.

---

## Source Code

````pine
//@version=6
indicator("Tail Range Percentile Radar [Pineify]", overlay = false, max_bars_back = 501, precision = 1)

// Independent implementation. Ranks use only the previous N bars, never the candidate.
// Lane heights are display coordinates, not price, probability or directional forecasts.
int rankLength = input.int(200, "Prior bars in each distribution", minval = 50, maxval = 400, group = "Detection")
float tailThreshold = input.float(95.0, "Extreme percentile", minval = 80.0, maxval = 99.5, step = 0.5, group = "Detection")
float minWickShare = input.float(20.0, "Minimum wick share of high-low (%)", minval = 5.0, maxval = 45.0, step = 1.0, group = "Detection")
float minBodyShare = input.float(55.0, "Minimum body share of high-low (%)", minval = 50.0, maxval = 95.0, step = 1.0, group = "Detection")
int statsLength = input.int(100, "Event statistics: trailing chart bars", minval = 20, maxval = 500, group = "Detection")
bool showGuides = input.bool(true, "Show percentile threshold rails", group = "Visuals")
bool showTips = input.bool(true, "Show confirmed extreme tips", group = "Visuals")
bool showEvents = input.bool(true, "Show confirmed event strip", group = "Visuals")
bool showTable = input.bool(true, "Show component statistics", group = "Visuals")
color rangeColor = input.color(#B88716, "True range / gap", group = "Colors")
color bodyColor = input.color(#8960C8, "Real body", group = "Colors")
color upperColor = input.color(#D15B46, "Upper wick", group = "Colors")
color lowerColor = input.color(#198A97, "Lower wick", group = "Colors")

// Midrank ties receive half weight. A zero-sized component is deliberately ranked zero.
f_priorRank(float value, int length) =>
    float votes = 0.0
    int samples = 0
    if not na(value)
        for i = 1 to length
            float prior = value[i]
            if not na(prior)
                samples += 1
                votes += value > prior ? 1.0 : value == prior ? 0.5 : 0.0
    samples == length ? (value > 0.0 ? 100.0 * votes / length : 0.0) : na

f_shade(color hue, bool extreme) =>
    color.new(hue, extreme ? (barstate.isconfirmed ? 12 : 50) : 78)

f_number(float value) =>
    na(value) ? "--" : str.tostring(value, "#.0")

// Invalid OHLC invalidates all four populations, so partial coverage never masquerades as full.
bool validBar = not na(open) and not na(high) and not na(low) and not na(close) and not na(close[1]) and high >= math.max(open, close) and low <= math.min(open, close) and syminfo.mintick > 0
float span = validBar ? high - low : na
float tr = validBar ? math.max(span, math.max(math.abs(high - close[1]), math.abs(low - close[1]))) : na
float body = validBar ? math.abs(close - open) : na
float upper = validBar ? high - math.max(open, close) : na
float lower = validBar ? math.min(open, close) - low : na
// Compare integer tick magnitudes to avoid floating-point noise in equal candle components.
float trTicks = validBar ? math.round(tr / syminfo.mintick) : na
float bodyTicks = validBar ? math.round(body / syminfo.mintick) : na
float upperTicks = validBar ? math.round(upper / syminfo.mintick) : na
float lowerTicks = validBar ? math.round(lower / syminfo.mintick) : na
float trRank = f_priorRank(trTicks, rankLength)
float bodyRank = f_priorRank(bodyTicks, rankLength)
float upperRank = f_priorRank(upperTicks, rankLength)
float lowerRank = f_priorRank(lowerTicks, rankLength)
bool ready = not na(trRank) and not na(bodyRank) and not na(upperRank) and not na(lowerRank)
float bodyShare = span > 0 ? 100.0 * body / span : 0.0
float upperShare = span > 0 ? 100.0 * upper / span : 0.0
float lowerShare = span > 0 ? 100.0 * lower / span : 0.0
float gapShare = tr > 0 ? 100.0 * math.max(0.0, tr - span) / tr : 0.0
bool rangeExtreme = ready and trTicks > 0 and trRank >= tailThreshold
bool bodyExtreme = ready and bodyTicks > 0 and bodyRank >= tailThreshold and bodyShare >= minBodyShare
bool upperExtreme = ready and upperTicks > 0 and upperRank >= tailThreshold and upperShare >= minWickShare
bool lowerExtreme = ready and lowerTicks > 0 and lowerRank >= tailThreshold and lowerShare >= minWickShare

// Classify anatomy, not next-bar direction. Component flags remain independent of this precedence.
int eventCode = not ready ? -1 : upperExtreme and lowerExtreme ? 1 : upperExtreme ? 2 : lowerExtreme ? 3 : bodyExtreme ? (close >= open ? 4 : 5) : rangeExtreme and gapShare >= 35.0 ? 6 : rangeExtreme ? 7 : 0
string eventName = switch eventCode
    -1 => "WARMUP / DATA"
    1 => "DUAL TAIL"
    2 => "UPPER TAIL"
    3 => "LOWER TAIL"
    4 => "UP BODY"
    5 => "DOWN BODY"
    6 => "GAP-LED RANGE"
    7 => "RANGE ONLY"
    => "ORDINARY"
color eventColor = eventCode == 1 ? chart.fg_color : eventCode == 2 ? upperColor : eventCode == 3 ? lowerColor : eventCode == 4 or eventCode == 5 ? bodyColor : rangeColor

// Four identical 20-unit scan lanes, in table order: TR, body, upper wick, lower wick.
plot(ready ? 84.0 + trRank * 0.2 : na, "TR scan lane", f_shade(rangeColor, rangeExtreme), style = plot.style_columns, histbase = 84, display = display.pane)
plot(ready ? 56.0 + bodyRank * 0.2 : na, "Body scan lane", f_shade(bodyColor, bodyExtreme), style = plot.style_columns, histbase = 56, display = display.pane)
plot(ready ? 28.0 + upperRank * 0.2 : na, "Upper scan lane", f_shade(upperColor, upperExtreme), style = plot.style_columns, histbase = 28, display = display.pane)
plot(ready ? lowerRank * 0.2 : na, "Lower scan lane", f_shade(lowerColor, lowerExtreme), style = plot.style_columns, histbase = 0, display = display.pane)
hline(84, "TR zero", color.new(rangeColor, 60))
hline(56, "Body zero", color.new(bodyColor, 60))
hline(28, "Upper zero", color.new(upperColor, 60))
hline(0, "Lower zero", color.new(lowerColor, 60))
hline(104, "TR 100", color.new(rangeColor, 90))
hline(76, "Body 100", color.new(bodyColor, 90))
hline(48, "Upper 100", color.new(upperColor, 90))
hline(20, "Lower 100", color.new(lowerColor, 90))
hline(84 + tailThreshold * 0.2, "TR threshold", color.new(rangeColor, showGuides ? 35 : 100), hline.style_dashed)
hline(56 + tailThreshold * 0.2, "Body threshold", color.new(bodyColor, showGuides ? 35 : 100), hline.style_dashed)
hline(28 + tailThreshold * 0.2, "Upper threshold", color.new(upperColor, showGuides ? 35 : 100), hline.style_dashed)
hline(tailThreshold * 0.2, "Lower threshold", color.new(lowerColor, showGuides ? 35 : 100), hline.style_dashed)
plot(showTips and barstate.isconfirmed and rangeExtreme ? 84 + trRank * 0.2 : na, "TR confirmed tip", rangeColor, 2, plot.style_circles, display = display.pane)
plot(showTips and barstate.isconfirmed and bodyExtreme ? 56 + bodyRank * 0.2 : na, "Body confirmed tip", bodyColor, 2, plot.style_circles, display = display.pane)
plot(showTips and barstate.isconfirmed and upperExtreme ? 28 + upperRank * 0.2 : na, "Upper confirmed tip", upperColor, 2, plot.style_circles, display = display.pane)
plot(showTips and barstate.isconfirmed and lowerExtreme ? lowerRank * 0.2 : na, "Lower confirmed tip", lowerColor, 2, plot.style_circles, display = display.pane)
plotshape(showEvents and barstate.isconfirmed and eventCode > 0 ? -6.0 : na, "Confirmed anatomy event", shape.diamond, location.absolute, eventColor, size = size.tiny, display = display.pane)

// The Data Window contains true percentile values, never the stacked display coordinates.
plot(ready ? trRank : na, "True range percentile", rangeColor, display = display.data_window)
plot(ready ? bodyRank : na, "Body percentile", bodyColor, display = display.data_window)
plot(ready ? upperRank : na, "Upper wick percentile", upperColor, display = display.data_window)
plot(ready ? lowerRank : na, "Lower wick percentile", lowerColor, display = display.data_window)
plot(ready ? eventCode : na, "Anatomy code: 0 ordinary, 1 dual, 2 upper, 3 lower, 4 up body, 5 down body, 6 gap, 7 range", display = display.data_window)
plot(ready ? gapShare : na, "Outside-range contribution to TR (%)", display = display.data_window)

// Trailing frequencies use eligible closed bars only. No inference of future event probability.
float eligibleTotal = ta.cum(ready ? 1.0 : 0.0)
float rangeTotal = ta.cum(rangeExtreme ? 1.0 : 0.0)
float bodyTotal = ta.cum(bodyExtreme ? 1.0 : 0.0)
float upperTotal = ta.cum(upperExtreme ? 1.0 : 0.0)
float lowerTotal = ta.cum(lowerExtreme ? 1.0 : 0.0)
float eligibleCount = eligibleTotal - nz(eligibleTotal[statsLength])
float rangeCount = rangeTotal - nz(rangeTotal[statsLength])
float bodyCount = bodyTotal - nz(bodyTotal[statsLength])
float upperCount = upperTotal - nz(upperTotal[statsLength])
float lowerCount = lowerTotal - nz(lowerTotal[statsLength])
float closedCount = barstate.isconfirmed ? eligibleCount : nz(eligibleCount[1])
float closedRange = barstate.isconfirmed ? rangeCount : nz(rangeCount[1])
float closedBody = barstate.isconfirmed ? bodyCount : nz(bodyCount[1])
float closedUpper = barstate.isconfirmed ? upperCount : nz(upperCount[1])
float closedLower = barstate.isconfirmed ? lowerCount : nz(lowerCount[1])

f_row(table panel, int row, string name, float rank, float share, float count, float total, color hue) =>
    table.cell(panel, 0, row, name, text_color = hue, text_size = size.small)
    table.cell(panel, 1, row, f_number(rank), text_color = chart.fg_color, text_size = size.small)
    table.cell(panel, 2, row, na(share) ? "--" : f_number(share) + "%", text_color = chart.fg_color, text_size = size.small)
    table.cell(panel, 3, row, total > 0 ? f_number(100.0 * count / total) + "%" : "--", text_color = hue, text_size = size.small)

var table radar = table.new(position.top_right, 4, 7, bgcolor = color.new(chart.bg_color, 8), frame_color = color.new(chart.fg_color, 75), frame_width = 1)
if barstate.islast
    if showTable
        table.cell(radar, 0, 0, "RADAR", text_color = chart.fg_color, text_size = size.small)
        table.cell(radar, 1, 0, "Rank", text_color = chart.fg_color, text_size = size.small)
        table.cell(radar, 2, 0, "H-L share", text_color = chart.fg_color, text_size = size.small)
        table.cell(radar, 3, 0, "Closed rate", text_color = chart.fg_color, text_size = size.small)
        f_row(radar, 1, "TR", ready ? trRank : na, na, closedRange, closedCount, rangeColor)
        f_row(radar, 2, "BODY", ready ? bodyRank : na, ready ? bodyShare : na, closedBody, closedCount, bodyColor)
        f_row(radar, 3, "UPPER", ready ? upperRank : na, ready ? upperShare : na, closedUpper, closedCount, upperColor)
        f_row(radar, 4, "LOWER", ready ? lowerRank : na, ready ? lowerShare : na, closedLower, closedCount, lowerColor)
        table.cell(radar, 0, 5, barstate.isconfirmed ? "CLOSED" : "LIVE", text_color = chart.fg_color, text_size = size.small)
        table.cell(radar, 1, 5, eventName, text_color = ready ? eventColor : chart.fg_color, text_size = size.small)
        table.cell(radar, 2, 5, "N=" + str.tostring(rankLength), text_color = chart.fg_color, text_size = size.small)
        table.cell(radar, 3, 5, "Q" + f_number(tailThreshold), text_color = chart.fg_color, text_size = size.small)
        table.cell(radar, 0, 6, "Rate sample", text_color = chart.fg_color, text_size = size.small)
        table.cell(radar, 1, 6, str.tostring(closedCount, "#") + "/" + str.tostring(statsLength), text_color = chart.fg_color, text_size = size.small)
        table.cell(radar, 2, 6, "Gap/TR", text_color = rangeColor, text_size = size.small)
        table.cell(radar, 3, 6, ready ? f_number(gapShare) + "%" : "--", text_color = rangeColor, text_size = size.small)
    else
        table.clear(radar, 0, 0, 3, 6)

alertcondition(barstate.isconfirmed and rangeExtreme, "Extreme true range confirmed", "Tail Range Percentile Radar: extreme true range confirmed on {{ticker}} {{interval}}.")
alertcondition(barstate.isconfirmed and upperExtreme, "Upper tail confirmed", "Tail Range Percentile Radar: share-qualified upper tail confirmed on {{ticker}} {{interval}}.")
alertcondition(barstate.isconfirmed and lowerExtreme, "Lower tail confirmed", "Tail Range Percentile Radar: share-qualified lower tail confirmed on {{ticker}} {{interval}}.")
````
