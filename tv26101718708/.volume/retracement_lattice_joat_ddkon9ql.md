# Retracement Lattice [JOAT]

- url: https://www.tradingview.com/script/DDKon9QL-Retracement-Lattice-JOAT/
- type: indicator
- pine_id: PUB;7617598b2fd847c2aae313144483b5f5
- version: 1.0

## Description

[b]JOAT Retracement Lattice [JOAT][/b]

[b]Introduction[/b]

JOAT Retracement Lattice is an open-source retracement and extension framework designed to turn a confirmed swing into a live working map.

It does more than place Fibonacci levels on a chart.

The script manages swing anchors, highlights the OTE pocket, overlays confirmed higher-timeframe retracement structure, shades premium and discount halves, and evaluates response quality inside the active pocket.

The problem it solves is inconsistency.

Manual retracement drawing is useful, but it can also become subjective very quickly.

Anchors are often moved emotionally.

Higher-timeframe confluence is ignored.

The midpoint is overlooked.

The response inside the retracement is treated as equivalent even when it is not.

Retracement Lattice standardizes the active swing and continuously updates the derived structure.

That creates a cleaner framework for pullback analysis, continuation planning, and location-based decision making.

[image]https://www.tradingview.com/x/YkLavd3w/[/image]

[b]Core Concepts[/b]

[b]1. Confirmed Swing Anchor Engine[/b]

The lattice begins with a confirmed swing.

Pivot logic and anchor-state management determine which high and low form the active range.

[pine]
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(low,  pivotLen, pivotLen)
[/pine]

[b]2. Full Retracement Stack[/b]

The script calculates a broad set of retracement and extension levels rather than only the most common ones.

[pine]
fib236 = levelAt(0.236)
fib382 = levelAt(0.382)
fib500 = levelAt(0.500)
fib618 = levelAt(0.618)
fib705 = levelAt(0.705)
fib786 = levelAt(0.786)
[/pine]

[b]3. OTE Pocket Emphasis[/b]

The 0.618 to 0.786 region is emphasized as the main response pocket.

[b]4. Higher-Timeframe Confluence[/b]

A confirmed higher-timeframe lattice is projected alongside the local one.

[b]5. Premium and Discount Shading[/b]

The upper and lower halves of the swing are shaded relative to the midpoint.

[b]6. Extension Objectives[/b]

The active swing also provides continuation targets beyond the range.

[b]7. Response Qualification[/b]

The script evaluates whether price is reacting constructively inside the active pocket.

[b]8. Chart-Edge Guidance[/b]

Labels and projected guide objects keep the live map readable near the right edge of the chart.

[image]https://www.tradingview.com/x/YYPSsgdf/[/image]

[b]Features[/b]

[list]
[*][b]Confirmed anchor-state engine:[/b] stable swing selection using pivot confirmation
[*][b]Expanded retracement stack:[/b] 0.236, 0.382, 0.500, 0.618, 0.705, and 0.786
[*][b]OTE pocket emphasis:[/b] the main response zone is highlighted
[*][b]Extension objectives:[/b] continuation levels project beyond the swing
[*][b]Higher-timeframe confluence:[/b] confirmed HTF lattice is shown
[*][b]Premium / discount shading:[/b] auction halves are visible at a glance
[*][b]Response qualification:[/b] pocket interaction is graded instead of assumed
[*][b]Object-managed edge labels:[/b] the current range stays readable
[*][b]Dashboard:[/b] anchor direction, confluence, and pocket state are summarized
[/list]

[b]Input Parameters[/b]

[b]Swing Anchor:[/b]

[list]
[*]Swing Lookback
[*]Pivot Length
[*]Reverse Orientation
[*]Volume-Validated Pivots
[*]Volume Baseline
[*]Volume Threshold
[/list]

[b]Higher Timeframe / Display:[/b]

[list]
[*]Show Higher Timeframe Grid
[*]Higher Timeframe
[*]Show Classic Retracements
[*]Show Minor Levels
[*]Show OTE Band
[*]Show Extensions
[*]Show Dashboard
[*]Confluence Tolerance
[*]Shade Auction
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Identify the active swing anchor pair.

[b]Step 2:[/b] Check whether price is trading in premium or discount relative to the midpoint.

[b]Step 3:[/b] Focus on the OTE pocket when the broader structure supports it.

[b]Step 4:[/b] Compare the local lattice to the confirmed higher-timeframe lattice.

[b]Step 5:[/b] Use the extensions to organize continuation targets after response.

[b]Indicator Limitations[/b]

[list]
[*]Anchors settle only after pivot confirmation, which is intentional non-repainting behavior
[*]Strong trends can continue without deep retracement into the pocket
[*]Confluence improves context but does not force a reaction
[*]Retracement tools provide structure, not certainty
[/list]

[b]Originality Statement[/b]

This script is original in how it turns a retracement tool into an active framework with anchor-state management, OTE response logic, premium-discount shading, higher-timeframe confluence, and extension objectives.

The components are unified around one job:

to make pullback location more structured and less subjective.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

It is not financial advice.

Retracement and extension levels are analytical references and do not guarantee support, resistance, or target completion.

Use risk management and independent judgment at all times.

[b]Best Use Cases[/b]

[list]
[*]Structuring pullback analysis after a confirmed directional swing
[*]Comparing local retracement behavior to confirmed higher-timeframe levels
[*]Locating the OTE pocket inside a stable swing map
[*]Planning continuation targets with extension levels
[/list]

[b]Interpretation Notes[/b]

The midpoint is important because it quickly reveals whether price is trading in the premium or discount half of the current auction.

The OTE pocket is most useful when the broader structural narrative already supports the same directional idea.

Higher-timeframe confluence should be treated as context improvement, not as a guarantee that the level must react.

[b]Publication Notes[/b]

This script is intended to be published with a clean chart showing the active anchor, the highlighted OTE pocket, and the higher-timeframe overlap when it exists.

The chart example should make the active swing easy to understand.

Avoid clutter from unrelated studies or excessive drawings.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Retracement Lattice [JOAT]", shorttitle = "RTL [JOAT]", overlay = true, max_lines_count = 500, max_labels_count = 200, max_boxes_count = 180, max_bars_back = 5000)

string G_ANCHOR = "Anchor Engine"
string G_HTF = "Higher Timeframe"
string G_QUAL = "Qualification"
string G_VIS = "Visual System"

int pivotLen = input.int(8, "Pivot Span", minval = 2, maxval = 40, group = G_ANCHOR)
int anchorLookback = input.int(160, "Fallback Lookback", minval = 40, maxval = 800, group = G_ANCHOR)
bool volumeValidated = input.bool(true, "Volume-Validate Pivots", group = G_ANCHOR)
int volumeLen = input.int(20, "Volume Baseline", minval = 5, maxval = 200, group = G_ANCHOR)
float volumeThreshold = input.float(1.05, "Volume Threshold", minval = 0.50, step = 0.05, group = G_ANCHOR)
bool reverseMap = input.bool(false, "Reverse Orientation", group = G_ANCHOR)
int projectionBars = input.int(28, "Projection Bars", minval = 5, maxval = 120, group = G_ANCHOR)

bool showHtf = input.bool(true, "Show Higher Timeframe Grid", group = G_HTF)
string htfTf = input.timeframe("240", "Anchor Timeframe", group = G_HTF)
int htfLookback = input.int(120, "HTF Lookback", minval = 20, maxval = 600, group = G_HTF)

int atrLen = input.int(14, "ATR Length", minval = 2, group = G_QUAL)
float tolerancePct = input.float(0.16, "Confluence Tolerance %", minval = 0.02, step = 0.01, group = G_QUAL)
int trendLen = input.int(55, "Trend Filter EMA", minval = 5, maxval = 300, group = G_QUAL)
bool useTrendFilter = input.bool(true, "Use Trend Bias Filter", group = G_QUAL)
bool requireHtfAlignment = input.bool(true, "Require HTF Alignment", group = G_QUAL)
bool requireVolumeSponsorship = input.bool(false, "Require Volume Sponsorship", group = G_QUAL)
float responseBufferAtr = input.float(0.18, "Response Buffer ATR", minval = 0.05, step = 0.01, group = G_QUAL)

bool showClassic = input.bool(true, "Show Classic Levels", group = G_VIS)
bool showMinor = input.bool(true, "Show Minor Levels", group = G_VIS)
bool showExtensions = input.bool(true, "Show Extension Ladder", group = G_VIS)
bool showAnchorLeg = input.bool(true, "Show Anchor Leg", group = G_VIS)
bool showLabels = input.bool(true, "Show Edge Labels", group = G_VIS)
bool showDashboard = input.bool(true, "Show Dashboard", group = G_VIS)
bool tintBars = input.bool(true, "Tint Bars", group = G_VIS)
bool shadeAuction = input.bool(true, "Shade Premium / Discount", group = G_VIS)

color bullCore = input.color(color.rgb(19, 199, 150), "Bull Core", group = G_VIS)
color bearCore = input.color(color.rgb(219, 91, 122), "Bear Core", group = G_VIS)
color supportCore = input.color(color.rgb(90, 156, 248), "Secondary", group = G_VIS)
color accentCore = input.color(color.rgb(228, 194, 104), "Accent", group = G_VIS)
color neutralCore = input.color(color.rgb(124, 137, 160), "Neutral", group = G_VIS)
color panelBg = input.color(color.rgb(11, 16, 28), "Dashboard Background", group = G_VIS)
color panelEdge = input.color(color.rgb(42, 57, 79), "Dashboard Border", group = G_VIS)

type AnchorState
    float highPrice
    float lowPrice
    int highBar
    int lowBar
    bool downMove
    bool ready

type FibSlice
    float zero
    float quarter
    float retr236
    float retr382
    float mid
    float retr618
    float retr705
    float retr786
    float full
    float ext1272
    float ext1618
    float ext2000

f_clamp(float value, float lowValue, float highValue) =>
    math.max(lowValue, math.min(highValue, value))

f_near(float a, float b, float tolerance) =>
    not na(a) and not na(b) and math.abs(a - b) <= tolerance

f_ratio(float highValue, float lowValue, float priceValue) =>
    float span = math.max(highValue - lowValue, syminfo.mintick)
    f_clamp((priceValue - lowValue) / span, 0.0, 1.0)

f_pivot_high(series float src, simple int len, series bool gate) =>
    float candidate = src[len]
    bool valid = not na(candidate)
    if valid
        for i = 0 to len * 2
            if i != len and src[i] >= candidate
                valid := false
    valid and gate[len] ? candidate : na

f_pivot_low(series float src, simple int len, series bool gate) =>
    float candidate = src[len]
    bool valid = not na(candidate)
    if valid
        for i = 0 to len * 2
            if i != len and src[i] <= candidate
                valid := false
    valid and gate[len] ? candidate : na

f_slice(float hi, float lo, bool downMove) =>
    float span = math.max(hi - lo, syminfo.mintick)
    float zeroValue = downMove ? lo : hi
    float quarterValue = downMove ? lo + span * 0.250 : hi - span * 0.250
    float retr236Value = downMove ? lo + span * 0.236 : hi - span * 0.236
    float retr382Value = downMove ? lo + span * 0.382 : hi - span * 0.382
    float midValue = downMove ? lo + span * 0.500 : hi - span * 0.500
    float retr618Value = downMove ? lo + span * 0.618 : hi - span * 0.618
    float retr705Value = downMove ? lo + span * 0.705 : hi - span * 0.705
    float retr786Value = downMove ? lo + span * 0.786 : hi - span * 0.786
    float fullValue = downMove ? hi : lo
    float ext1272Value = downMove ? lo + span * 1.272 : hi - span * 1.272
    float ext1618Value = downMove ? lo + span * 1.618 : hi - span * 1.618
    float ext2000Value = downMove ? lo + span * 2.000 : hi - span * 2.000
    FibSlice.new(zeroValue, quarterValue, retr236Value, retr382Value, midValue, retr618Value, retr705Value, retr786Value, fullValue, ext1272Value, ext1618Value, ext2000Value)

f_box_update(box id, int leftValue, int rightValue, float topValue, float bottomValue, color borderColor, color fillColor) =>
    box target = id
    if na(target)
        target := box.new(leftValue, topValue, rightValue, bottomValue, border_color = borderColor, bgcolor = fillColor)
    box.set_left(target, leftValue)
    box.set_right(target, rightValue)
    box.set_top(target, topValue)
    box.set_bottom(target, bottomValue)
    box.set_border_color(target, borderColor)
    box.set_bgcolor(target, fillColor)
    target

f_line_update(line id, int x1, float y1, int x2, float y2, color lineColor, int widthValue, styleValue) =>
    line target = id
    if na(target)
        target := line.new(x1, y1, x2, y2, color = lineColor, width = widthValue, style = styleValue)
    line.set_xy1(target, x1, y1)
    line.set_xy2(target, x2, y2)
    line.set_color(target, lineColor)
    line.set_width(target, widthValue)
    line.set_style(target, styleValue)
    target

f_label_update(label id, int xValue, float yValue, string textValue, color textColor, color fillColor) =>
    label target = id
    if na(target)
        target := label.new(xValue, yValue, textValue, style = label.style_label_left, size = size.small, color = fillColor, textcolor = textColor)
    label.set_xy(target, xValue, yValue)
    label.set_text(target, textValue)
    label.set_textcolor(target, textColor)
    label.set_color(target, fillColor)
    target

float atrValue = ta.atr(atrLen)
float trendBasis = ta.ema(close, trendLen)
float momentum = ta.rsi(close, 14)
float volumeBase = ta.sma(volume, volumeLen)
bool volumeSponsor = volume > volumeBase * volumeThreshold
bool pivotGate = not volumeValidated or volumeSponsor

var AnchorState anchor = AnchorState.new(na, na, na, na, false, false)

float localPivotHigh = f_pivot_high(high, pivotLen, pivotGate)
float localPivotLow = f_pivot_low(low, pivotLen, pivotGate)

if not anchor.ready
    anchor.highPrice := ta.highest(high, anchorLookback)
    anchor.lowPrice := ta.lowest(low, anchorLookback)
    anchor.highBar := bar_index - ta.highestbars(high, anchorLookback)
    anchor.lowBar := bar_index - ta.lowestbars(low, anchorLookback)
    anchor.downMove := anchor.lowBar > anchor.highBar
    anchor.ready := true

if not na(localPivotHigh)
    anchor.highPrice := localPivotHigh
    anchor.highBar := bar_index - pivotLen

if not na(localPivotLow)
    anchor.lowPrice := localPivotLow
    anchor.lowBar := bar_index - pivotLen

anchor.downMove := anchor.lowBar > anchor.highBar
if close > nz(anchor.highPrice, close)
    anchor.downMove := false
if close < nz(anchor.lowPrice, close)
    anchor.downMove := true

bool baseDown = reverseMap ? not anchor.downMove : anchor.downMove
float anchorHigh = nz(anchor.highPrice, high)
float anchorLow = nz(anchor.lowPrice, low)
float anchorSpan = math.max(anchorHigh - anchorLow, syminfo.mintick)
int anchorStartBar = math.min(nz(anchor.highBar, bar_index), nz(anchor.lowBar, bar_index))
int anchorEndBar = math.max(nz(anchor.highBar, bar_index), nz(anchor.lowBar, bar_index))

[htfHigh, htfLow, htfOpen, htfClose, htfAtr] = request.security(
    syminfo.tickerid,
    htfTf,
    [
        ta.highest(high, htfLookback)[1],
        ta.lowest(low, htfLookback)[1],
        open[1],
        close[1],
        ta.atr(atrLen)[1]
    ],
    lookahead = barmerge.lookahead_on
)

bool htfDownBase = htfClose < htfOpen
bool htfDown = reverseMap ? not htfDownBase : htfDownBase
FibSlice localFib = f_slice(anchorHigh, anchorLow, baseDown)
FibSlice htfFib = f_slice(nz(htfHigh, anchorHigh), nz(htfLow, anchorLow), htfDown)

float toleranceAbs = math.max(close * tolerancePct / 100.0, syminfo.mintick) + atrValue * 0.05
bool conf236 = f_near(localFib.retr236, htfFib.retr236, toleranceAbs)
bool conf382 = f_near(localFib.retr382, htfFib.retr382, toleranceAbs)
bool conf500 = f_near(localFib.mid, htfFib.mid, toleranceAbs)
bool conf618 = f_near(localFib.retr618, htfFib.retr618, toleranceAbs)
bool conf705 = f_near(localFib.retr705, htfFib.retr705, toleranceAbs)
bool conf786 = f_near(localFib.retr786, htfFib.retr786, toleranceAbs)
bool conf1272 = f_near(localFib.ext1272, htfFib.ext1272, toleranceAbs)
int confluenceScore = (conf236 ? 1 : 0) + (conf382 ? 1 : 0) + (conf500 ? 1 : 0) + (conf618 ? 1 : 0) + (conf705 ? 1 : 0) + (conf786 ? 1 : 0) + (conf1272 ? 1 : 0)

float pocketTop = math.max(localFib.retr786, localFib.retr618)
float pocketBottom = math.min(localFib.retr786, localFib.retr618)
float pocketMid = localFib.retr705
bool inPocket = close <= pocketTop and close >= pocketBottom
bool abovePocket = close > pocketTop
bool belowPocket = close < pocketBottom
bool htfAligned = not showHtf or not requireHtfAlignment or baseDown == htfDown
bool trendAlignedLong = not useTrendFilter or close >= trendBasis
bool trendAlignedShort = not useTrendFilter or close <= trendBasis
bool sponsorAligned = not requireVolumeSponsorship or volumeSponsor

bool inExecutionHalf = baseDown ? close >= localFib.mid : close <= localFib.mid
string auctionText = baseDown ? close >= localFib.mid ? "Premium" : "Discount" : close <= localFib.mid ? "Discount" : "Premium"
color auctionColor = auctionText == "Discount" ? bullCore : auctionText == "Premium" ? bearCore : neutralCore

float distanceFromPocket = close > pocketTop ? close - pocketTop : close < pocketBottom ? pocketBottom - close : 0.0
float responseThreshold = atrValue * responseBufferAtr
bool bullPocketQualified = barstate.isconfirmed and not baseDown and inPocket and htfAligned and trendAlignedLong and sponsorAligned and close >= pocketMid and close > open
bool bearPocketQualified = barstate.isconfirmed and baseDown and inPocket and htfAligned and trendAlignedShort and sponsorAligned and close <= pocketMid and close < open
bool bullReclaim = barstate.isconfirmed and not baseDown and ta.crossover(close, pocketMid) and distanceFromPocket <= responseThreshold and trendAlignedLong
bool bearReclaim = barstate.isconfirmed and baseDown and ta.crossunder(close, pocketMid) and distanceFromPocket <= responseThreshold and trendAlignedShort
bool bullExpansion = barstate.isconfirmed and not baseDown and close > localFib.zero
bool bearExpansion = barstate.isconfirmed and baseDown and close < localFib.zero
bool invalidated = barstate.isconfirmed and (not baseDown and close < localFib.full or baseDown and close > localFib.full)

float locationRatio = f_ratio(anchorHigh, anchorLow, close)
float displayRatio = baseDown ? 1.0 - locationRatio : locationRatio
color rangeGradient = color.from_gradient(displayRatio, 0.0, 1.0, color.new(bearCore, 15), color.new(bullCore, 15))
color pocketGradient = color.from_gradient(f_clamp((close - pocketBottom) / math.max(pocketTop - pocketBottom, syminfo.mintick), 0.0, 1.0), 0.0, 1.0, color.new(accentCore, 10), color.new(supportCore, 10))
color stateColor = bullPocketQualified or bullReclaim ? bullCore : bearPocketQualified or bearReclaim ? bearCore : inPocket ? accentCore : rangeGradient

float invalidationLevel = localFib.full
float objectiveOne = localFib.zero
float objectiveTwo = showExtensions ? localFib.ext1272 : na
float objectiveThree = showExtensions ? localFib.ext1618 : na

plotAnchorTop = plot(localFib.zero, "Anchor Zero", color = baseDown ? color.new(bullCore, 0) : color.new(bearCore, 0), linewidth = 2)
plotAnchorBottom = plot(localFib.full, "Anchor Full", color = baseDown ? color.new(bearCore, 0) : color.new(bullCore, 0), linewidth = 2)
plotMinor236 = plot(showMinor ? localFib.retr236 : na, "Retracement 0.236", color = color.new(supportCore, 45), linewidth = 1, style = plot.style_linebr)
plotMinor382 = plot(showClassic ? localFib.retr382 : na, "Retracement 0.382", color = color.new(supportCore, 20), linewidth = 1, style = plot.style_linebr)
plotMid = plot(showClassic ? localFib.mid : na, "Retracement 0.500", color = color.new(accentCore, 0), linewidth = 1)
plot618 = plot(showClassic ? localFib.retr618 : na, "Retracement 0.618", color = color.new(accentCore, 0), linewidth = 2)
plot705 = plot(showClassic ? localFib.retr705 : na, "Retracement 0.705", color = color.new(stateColor, 0), linewidth = 2)
plot786 = plot(showClassic ? localFib.retr786 : na, "Retracement 0.786", color = color.new(supportCore, 0), linewidth = 1)
plot1272 = plot(showExtensions ? localFib.ext1272 : na, "Extension 1.272", color = color.new(stateColor, 10), linewidth = 1, style = plot.style_linebr)
plot1618 = plot(showExtensions ? localFib.ext1618 : na, "Extension 1.618", color = color.new(stateColor, 0), linewidth = 2, style = plot.style_linebr)
plot2000 = plot(showExtensions ? localFib.ext2000 : na, "Extension 2.000", color = color.new(stateColor, 20), linewidth = 1, style = plot.style_linebr)

plotHtf382 = plot(showHtf and showMinor ? htfFib.retr382 : na, "HTF 0.382", color = color.new(neutralCore, 65), linewidth = 1, style = plot.style_linebr)
plotHtf500 = plot(showHtf ? htfFib.mid : na, "HTF 0.500", color = color.new(neutralCore, 55), linewidth = 1, style = plot.style_linebr)
plotHtf618 = plot(showHtf ? htfFib.retr618 : na, "HTF 0.618", color = color.new(neutralCore, 25), linewidth = 1, style = plot.style_linebr)
plotHtf705 = plot(showHtf ? htfFib.retr705 : na, "HTF 0.705", color = color.new(neutralCore, 15), linewidth = 1, style = plot.style_linebr)
plotHtf786 = plot(showHtf ? htfFib.retr786 : na, "HTF 0.786", color = color.new(neutralCore, 25), linewidth = 1, style = plot.style_linebr)

fill(plotAnchorTop, plotMid, color = shadeAuction ? (baseDown ? color.new(bullCore, 92) : color.new(bearCore, 92)) : na, title = "Upper Half")
fill(plotMid, plotAnchorBottom, color = shadeAuction ? (baseDown ? color.new(bearCore, 92) : color.new(bullCore, 92)) : na, title = "Lower Half")

fill(plot618, plot786, color = color.new(pocketGradient, 84), title = "OTE Pocket")
fill(plotHtf618, plotHtf786, color = showHtf ? color.new(neutralCore, 93) : na, title = "HTF Pocket")

barcolor(tintBars ? (bullPocketQualified ? bullCore : bearPocketQualified ? bearCore : color.new(stateColor, 22)) : na)
bgcolor(math.abs(close - pocketMid) <= responseThreshold ? color.new(stateColor, 94) : na, title = "Response Backdrop")

var box pocketBox = na
var box overlapBox = na
var line anchorLeg = na
var label edgeLabel = na
var label pocketLabel = na

if barstate.islast
    int rightEdge = bar_index + projectionBars
    if showAnchorLeg
        anchorLeg := f_line_update(anchorLeg, nz(anchor.highBar, bar_index), anchorHigh, nz(anchor.lowBar, bar_index), anchorLow, color.new(stateColor, 20), 2, line.style_solid)
    else if not na(anchorLeg)
        line.delete(anchorLeg)
        anchorLeg := na
    pocketBox := f_box_update(pocketBox, anchorStartBar, rightEdge, pocketTop, pocketBottom, color.new(stateColor, 20), color.new(stateColor, 90))
    if confluenceScore > 0 and showHtf
        float overlapTop = math.max(math.max(localFib.retr618, htfFib.retr618), math.max(localFib.retr705, htfFib.retr705))
        float overlapBottom = math.min(math.min(localFib.retr786, htfFib.retr786), math.min(localFib.retr705, htfFib.retr705))
        overlapBox := f_box_update(overlapBox, anchorStartBar, rightEdge, overlapTop, overlapBottom, color.new(accentCore, 25), color.new(accentCore, 93))
    else if not na(overlapBox)
        box.delete(overlapBox)
        overlapBox := na
    if showLabels
        string edgeText = bullPocketQualified ? "Qualified Long Pocket" : bearPocketQualified ? "Qualified Short Pocket" : inPocket ? "Pocket Active" : auctionText + " Auction"
        edgeLabel := f_label_update(edgeLabel, rightEdge, objectiveOne, edgeText, stateColor, color.new(panelBg, 8))
        string pocketText = "0.705  " + str.tostring(pocketMid, format.mintick)
        pocketLabel := f_label_update(pocketLabel, rightEdge, pocketMid, pocketText, accentCore, color.new(panelBg, 8))
    else
        if not na(edgeLabel)
            label.delete(edgeLabel)
            edgeLabel := na
        if not na(pocketLabel)
            label.delete(pocketLabel)
            pocketLabel := na

var table dash = table.new(position.top_right, 2, 9, bgcolor = color.new(panelBg, 8), frame_color = panelEdge, frame_width = 1, border_color = panelEdge, border_width = 1)
if showDashboard and barstate.islast
    string directionText = baseDown ? "Descending Auction" : "Ascending Auction"
    string pocketText = inPocket ? "Inside Pocket" : abovePocket ? "Above Pocket" : "Below Pocket"
    string htfText = htfAligned ? "Aligned" : "Split"
    string responseText = bullPocketQualified ? "Long Qualified" : bearPocketQualified ? "Short Qualified" : bullReclaim ? "Bull Reclaim" : bearReclaim ? "Bear Reclaim" : "Monitoring"
    string spanText = str.tostring(anchorSpan, format.mintick)
    string confText = str.tostring(confluenceScore) + " / 7"
    string trendText = useTrendFilter ? close >= trendBasis ? "Above EMA" : "Below EMA" : "Disabled"
    string sponsorText = volumeSponsor ? "Sponsored" : "Neutral"

    table.cell(dash, 0, 0, "Lattice", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dash, 1, 0, directionText, text_color = stateColor, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dash, 0, 1, "Pocket", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 1, pocketText, text_color = inPocket ? accentCore : neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 2, "Auction", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 2, auctionText, text_color = auctionColor, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 3, "HTF", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 3, htfText, text_color = htfAligned ? color.white : accentCore, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 4, "Confluence", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 4, confText, text_color = confluenceScore >= 3 ? accentCore : neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 5, "Response", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 5, responseText, text_color = stateColor, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 6, "Span", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 6, spanText, text_color = supportCore, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 7, "Trend", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 7, trendText, text_color = close >= trendBasis ? bullCore : bearCore, bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 0, 8, "Volume", text_color = color.rgb(166, 179, 203), bgcolor = color.new(panelBg, 0), text_size = size.small)
    table.cell(dash, 1, 8, sponsorText, text_color = volumeSponsor ? supportCore : neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.small)

plot(confluenceScore, "Confluence Score", color = color.new(color.white, 100), display = display.data_window)
plot(anchorSpan, "Anchor Span", color = color.new(color.white, 100), display = display.data_window)
plot(pocketMid, "Pocket Mid", color = color.new(color.white, 100), display = display.data_window)
plot(objectiveOne, "Objective One", color = color.new(color.white, 100), display = display.data_window)
plot(objectiveTwo, "Objective Two", color = color.new(color.white, 100), display = display.data_window)
plot(objectiveThree, "Objective Three", color = color.new(color.white, 100), display = display.data_window)
plot(invalidationLevel, "Invalidation", color = color.new(color.white, 100), display = display.data_window)
plot(momentum, "Momentum", color = color.new(color.white, 100), display = display.data_window)
plot(htfAtr, "HTF ATR", color = color.new(color.white, 100), display = display.data_window)

alertcondition(bullPocketQualified, "RTL Qualified Long", "Retracement Lattice [JOAT] qualified a long pocket on {{ticker}}.")
alertcondition(bearPocketQualified, "RTL Qualified Short", "Retracement Lattice [JOAT] qualified a short pocket on {{ticker}}.")
alertcondition(bullReclaim, "RTL Bull Reclaim", "Retracement Lattice [JOAT] detected a bullish reclaim through the 0.705 pocket midpoint on {{ticker}}.")
alertcondition(bearReclaim, "RTL Bear Reclaim", "Retracement Lattice [JOAT] detected a bearish reclaim through the 0.705 pocket midpoint on {{ticker}}.")
alertcondition(bullExpansion or bearExpansion, "RTL Expansion", "Retracement Lattice [JOAT] detected expansion beyond the local anchor on {{ticker}}.")
alertcondition(invalidated, "RTL Invalidation", "Retracement Lattice [JOAT] invalidation level was breached on {{ticker}}.")
````
