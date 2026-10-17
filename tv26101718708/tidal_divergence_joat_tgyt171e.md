# Tidal Divergence [JOAT]

- url: https://www.tradingview.com/script/tGYt171E-Tidal-Divergence-JOAT/
- type: indicator
- pine_id: PUB;8349a9389a7d4771b431d275b8973d8a
- version: 1.0

## Description

[b]Tidal Divergence [JOAT][/b]

Tidal Divergence is a composite divergence detector that lives in a sub-pane and projects high-conviction divergence visuals onto the price chart. The composite blends three volume-based oscillators — Money Flow Index, percentile-ranked Cumulative Volume Delta, and z-scored OBV rate-of-change — into a single normalized stream. Both regular and hidden divergences are detected. Persistent zones are drawn at divergence pivots, and zone mitigation is tracked with body / wick / rejection modes.

[image]https://www.tradingview.com/x/HIRrou3I/[/image]

[b]What makes it different[/b]
[list]
[*] Single-oscillator divergence indicators give a single perspective. Tidal Divergence's composite triangulates three independent volume-derived oscillators so a divergence in the composite is supported by three volume readings instead of one.
[*] Hidden divergences (continuation pattern: price higher low plus oscillator lower low for bull) are detected separately from regular divergences (reversal pattern), with distinct line styles on the price chart.
[*] Each detected divergence creates a persistent demand or supply zone with optional FVG-confluence gating, dynamic alpha-by-age (zones fade as they age), and explicit mitigation logic (body / wick / two-close rejection variants).
[*] A composite percentile envelope (5th to 95th percentile of the last 200 bars) is drawn behind the oscillator so absolute readings are easy to interpret in context.
[/list]

[b]How it works[/b]
[list=1]
[*] MFI(14), daily-reset CVD then ta.percentrank(cvd, 100), OBV ROC z-score over a 20-bar mean / stdev. Three legs, each normalized to roughly the same scale.
[*] Composite equals 0.40 times the normalized MFI plus 0.35 times the normalized CVD percentile plus 0.25 times the clamped OBV ROC z. Hull-smoothed and scaled to centi-percent.
[*] Pivots are detected on the composite stream. A regular bull divergence requires a price lower low paired with a composite higher low within a 5-to-60-bar window. Hidden bull requires a price higher low plus composite lower low. Bear variants invert the conditions.
[*] At each divergence pivot, two horizontal lines are drawn (edge equals lowest wick / highest wick. base equals lowest body / highest body), with a linefill between them, on the price chart via force_overlay=true.
[*] Zone mitigation: body mode (close beyond edge) or wick mode (high/low beyond edge), optionally with two-close rejection requirement.
[*] Optional FVG confluence requires a recent 3-bar Fair Value Gap before firing the divergence-final alert.
[/list]

[b]Reading the chart[/b]
[list]
[*] [b]In-pane[/b]: composite line tinted by direction with a smoothed signal line, gradient ribbon between them, breath-modulated zero midline, plus and minus 70 overbought / oversold thresholds, and the percentile envelope as an atmospheric backdrop.
[*] [b]In-pane divergence markers[/b]: regular divergences as solid connector plots, hidden divergences as broken (dashed-equivalent) connectors.
[*] [b]Cross-pane[/b]: price-to-price divergence connector lines on the price chart (regular solid, hidden dashed). Each line has a small REG BULL DIV 4520.50 or HID BEAR DIV label at the current pivot.
[*] [b]Cross-pane zone fills[/b] with age-graded transparency.
[*] Zone edge price labels follow the right edge of each active zone.
[*] Mitigation flash labels print at the bar where a zone is broken.
[*] A cross-pane composite tint paints a soft mint / red background when the composite is clearly above or below plus or minus 30.
[/list]

[b]Signals[/b]
[list]
[*] Regular bullish / bearish divergence
[*] Hidden bullish / bearish divergence (continuation)
[*] Bull / bear zone touch
[*] Bull / bear zone mitigated
[*] Bull / bear stack (three or more active zones plus a fresh regular divergence)
[*] Bull / bear streak (composite above / below zero for N consecutive bars)
[/list]
All gated on barstate.isconfirmed or barstate.ishistory. No future references. No lookahead_on.

[b]Inputs[/b]
[list]
[*] [b]MFI[/b]: MFI length.
[*] [b]Divergence[/b]: pivot lookback left / right, detect hidden divergences toggle.
[*] [b]Zones[/b]: zone extreme length, max zone age, mitigation mode, allow-rejection toggle.
[*] [b]FVG Confluence[/b]: require FVG, FVG lookback bars.
[*] [b]Visual[/b]: bullish / bearish colors.
[*] [b]Cross-pane Visuals[/b]: divergence lines, divergence labels, zone edge labels, composite tint.
[*] [b]Dashboard[/b]: position, size.
[/list]

[b]How traders use this[/b]
[list]
[*] [b]Reversal entries[/b]: a regular bull divergence with the composite leaving an oversold extreme is a high-quality long setup, especially when accompanied by an FVG below the divergence price.
[*] [b]Continuation entries[/b]: a hidden bull divergence during a clearly trending bull regime is a structurally supported add-on entry on a pullback.
[*] [b]Zone trades[/b]: after a divergence prints, treat its zone as an active demand or supply level. Reactions to the zone (touch with rejection candles) are tradable. Mitigation invalidates the level.
[*] [b]Composite filter[/b]: only trade with the composite in agreement (composite above 0 for longs). The cross-pane tint helps you stay aligned without checking the pane.
[/list]

[b]Limitations[/b]
[list]
[*] Divergence detection inherently lags the actual extreme by the right-pivot window.
[*] Composite values are smoothed and need warm-up bars before they stabilize.
[*] Cumulative Volume Delta is a tick-volume proxy, not true level-2 order flow.
[*] A divergence is a probability, not a guarantee. Many divergences fail before completing their implied reversal.
[/list]

[b]Compatibility[/b]
Pine Script v6 open-source indicator (pane plus cross-pane). Any symbol with volume data. Cross-pane elements use force_overlay=true. No request.security calls.

[b]Defaults[/b]
14-bar MFI, 14-left / 5-right pivot, body mitigation, FVG confluence off by default, mint / red palette, top-right medium dashboard. Enable FVG confluence to filter for higher-quality setups.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
// ════════════════════════════════════════════════════════════════════
//   JOAT — Tidal Divergence [JOAT]
//   Author : Jack Of All Trades (@JackOfAllTrades)
//   Stack  : Pine Script v6, pane (overlay=false)
// ════════════════════════════════════════════════════════════════════
indicator("Tidal Divergence [JOAT]", "TDV [JOAT]", overlay=false, explicit_plot_zorder=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════
g_mfi   = "MFI"
g_div   = "Divergence"
g_zone  = "Zones"
g_fvg   = "FVG Confluence"
g_vis   = "Visual"
g_xpane = "Cross-Pane Visuals"
g_dash  = "Dashboard"

mfiLen        = input.int(14, "MFI Length",            minval=2,                group=g_mfi,  tooltip="Lookback for the Money Flow Index — the price*volume component of the composite.")

lookbackLeft  = input.int(14, "Pivot Lookback Left",   minval=1,                group=g_div,  tooltip="Bars required to the LEFT of a pivot for confirmation.")
lookbackRight = input.int(5,  "Pivot Lookback Right",  minval=1,                group=g_div,  tooltip="Bars required to the RIGHT of a pivot for confirmation — also the divergence-line offset.")
detectHidden  = input.bool(true, "Detect Hidden Divergences",                   group=g_div,  tooltip="Enable hidden bullish/bearish divergence detection (trend-continuation signals).")

zoneLen       = input.int(5,    "Zone Extreme Length", minval=2,                group=g_zone, tooltip="Lookback used to find the high/low extreme that anchors a divergence zone.")
expiryAge     = input.int(1000, "Zone Max Age (bars)", minval=10,               group=g_zone, tooltip="Bars after which a divergence zone is force-removed.")
mitigationMode= input.string("body", "Mitigation Mode", options=["body","wick"],group=g_zone, tooltip="Body: zone removed when CLOSE crosses the edge. Wick: zone removed when the bar wick crosses the edge.")
allowRejection= input.bool(false, "Allow Rejection (require 2 closes for body)",group=g_zone, tooltip="When enabled with Body mode, requires two consecutive closes through the zone edge before removal.")

requireFVG    = input.bool(false, "Require FVG Confluence",                     group=g_fvg,  tooltip="Gate divergence alerts behind a recent Fair Value Gap in the matching direction.")
fvgLookback   = input.int(10, "FVG Lookback (bars)",   minval=1, maxval=50,     group=g_fvg,  tooltip="Maximum age (bars) of an FVG for confluence to be considered active.")

bullColor     = input.color(#00ffbb, "Bullish", inline="cBull",                 group=g_vis,  tooltip="Primary bullish color — JOAT brand mint.")
bearColor     = input.color(#ff1100, "Bearish", inline="cBull",                 group=g_vis,  tooltip="Primary bearish color — JOAT brand red.")

showDivPriceLines  = input.bool(true,  "Cross-Pane Div Connector Lines",          group=g_xpane, tooltip="Draw a line on the PRICE chart connecting the two divergent pivot prices (mint for bull, red for bear, dashed for hidden).")
showDivPriceLabels = input.bool(true,  "Cross-Pane Div Pivot Labels",             group=g_xpane, tooltip="Drop a price label at the current pivot end of each divergence with state and price.")
showZoneEdgeLabels = input.bool(true,  "Zone Edge Price Labels",                  group=g_xpane, tooltip="Persistent right-edge labels at each active bull/bear zone with edge price and age.")
showMitigationLabels = input.bool(true,"Mitigation Flash Labels",                 group=g_xpane, tooltip="Drop a persistent label on the price chart when a zone is mitigated.")
showCompositeCluster = input.bool(true,"Pane Composite Cluster",                  group=g_xpane, tooltip="3 persistent labels at the pane right edge showing composite, components, and stack metrics.")
showCompositeTint  = input.bool(true,  "Cross-Pane Composite Tint",               group=g_xpane, tooltip="Subtle background tint on the price chart while composite is strongly positive/negative.")
showZoneFade       = input.bool(true,  "Zone Lifetime Visual Fade",               group=g_xpane, tooltip="Fade zone fill alpha as the zone ages — newer zones louder, older zones fainter.")
showPercentileBand = input.bool(true,  "Composite Percentile Band",               group=g_xpane, tooltip="Faint band behind composite plot showing the 5th-95th percentile range of composite over the last 200 bars.")
showStateStrip     = input.bool(true,  "Pane Right-Edge State Strip",             group=g_xpane, tooltip="4 persistent labels in the pane right edge: last div, bull zones, bear zones, FVG conf.")
divPriceLineMax    = input.int(12, "Max Div Price Lines",       minval=2, maxval=30, group=g_xpane, tooltip="FIFO cap for cross-pane divergence connector lines.")
mitigationLabelMax = input.int(15, "Max Mitigation Labels",     minval=2, maxval=40, group=g_xpane, tooltip="FIFO cap for mitigation flash labels.")

showDash      = input.bool(true, "Show Dashboard",                              group=g_dash, tooltip="Toggle the institutional dashboard panel.")
dashPos       = input.string("top_right", "Dashboard Position",
     options=["top_right","top_center","top_left","middle_right","middle_center","middle_left","bottom_right","bottom_center","bottom_left"],
     group=g_dash, tooltip="Anchor the dashboard to any of the 9 chart positions.")
dashSize      = input.string("Medium", "Dashboard Size",
     options=["Tiny","Small","Medium","Large"],
     group=g_dash, tooltip="Cell text size for the dashboard.")

// ════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════

posFromString(string s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"   ? position.top_center    :
     s == "top_right"    ? position.top_right     :
     s == "middle_left"  ? position.middle_left   :
     s == "middle_center"? position.middle_center :
     s == "middle_right" ? position.middle_right  :
     s == "bottom_left"  ? position.bottom_left   :
     s == "bottom_center"? position.bottom_center :
     position.bottom_right

sizeFromString(string s) =>
    s == "Tiny"   ? size.tiny    :
     s == "Small" ? size.small   :
     s == "Large" ? size.large   :
     size.normal

_inRange(bool cond) =>
    bars = ta.barssince(cond)
    5 <= bars and bars <= 60

f_alpha(float v) =>
    int t = 90 - math.round(math.min(90.0, math.abs(v) * 0.9))
    math.max(5, math.min(95, t))

f_ageAlphaBump(int age) =>
    age < 50  ? 0   :
     age < 200 ? 15 :
     25

f_priceStr(float p) =>
    str.tostring(p, format.mintick)

// ════════════════════════════════════════════════════════════════════
// CORE CALCULATIONS
// ════════════════════════════════════════════════════════════════════
confirmedBar = barstate.isconfirmed or barstate.ishistory

mfi = ta.mfi(close, mfiLen)

newDay = ta.change(time("D")) != 0
delta  = close > open ? volume : close < open ? -volume : 0.0
var float cvd = 0.0
cvd := newDay ? delta : nz(cvd[1]) + delta
cvd_pct = ta.percentrank(cvd, 100)

obv       = ta.obv
obvRoc    = ta.roc(obv, 14)
obvRocSma = ta.sma(obvRoc, 20)
obvRocStd = ta.stdev(obvRoc, 20)
obvRocZ   = (obvRoc - obvRocSma) / math.max(obvRocStd, 1e-8)

mfiNorm        = (mfi - 50.0) / 50.0
cvdNorm        = (cvd_pct - 50.0) / 50.0
obvNorm        = math.max(-1.0, math.min(1.0, obvRocZ / 3.0))
composite_raw  = 0.4 * mfiNorm + 0.35 * cvdNorm + 0.25 * obvNorm
float composite = math.max(-100.0, math.min(100.0, ta.hma(composite_raw, 21) * 100.0))
signal_line    = ta.ema(composite, 14)

compP05 = ta.percentile_linear_interpolation(composite, 200, 5)
compP95 = ta.percentile_linear_interpolation(composite, 200, 95)

var int lastBullFVGBar = -999
var int lastBearFVGBar = -999
if low > high[2]
    lastBullFVGBar := bar_index
if high < low[2]
    lastBearFVGBar := bar_index
bullFVGConf = (bar_index - lastBullFVGBar) <= fvgLookback
bearFVGConf = (bar_index - lastBearFVGBar) <= fvgLookback

// ════════════════════════════════════════════════════════════════════
// DIVERGENCE DETECTION
// ════════════════════════════════════════════════════════════════════

plFound = not na(ta.pivotlow(composite, lookbackLeft, lookbackRight))
phFound = not na(ta.pivothigh(composite, lookbackLeft, lookbackRight))

oscLBR  = composite[lookbackRight]
lowLBR  = low[lookbackRight]
highLBR = high[lookbackRight]

bullZoneEdgePrice = ta.lowest(low, zoneLen)[lookbackRight]
bullZoneBasePrice = ta.lowest(math.min(open, close), zoneLen)[lookbackRight]
bearZoneEdgePrice = ta.highest(high, zoneLen)[lookbackRight]
bearZoneBasePrice = ta.highest(math.max(open, close), zoneLen)[lookbackRight]

oscHL   = oscLBR > ta.valuewhen(plFound, oscLBR, 1) and _inRange(plFound[1])
priceLL = lowLBR < ta.valuewhen(plFound, lowLBR, 1)
regBull = priceLL and oscHL and plFound

oscLH   = oscLBR < ta.valuewhen(phFound, oscLBR, 1) and _inRange(phFound[1])
priceHH = highLBR > ta.valuewhen(phFound, highLBR, 1)
regBear = priceHH and oscLH and phFound

priceHL = lowLBR > ta.valuewhen(plFound, lowLBR, 1)
oscLL   = oscLBR < ta.valuewhen(plFound, oscLBR, 1) and _inRange(plFound[1])
hidBull = detectHidden and priceHL and oscLL and plFound

priceLH = highLBR < ta.valuewhen(phFound, highLBR, 1)
oscHH   = oscLBR > ta.valuewhen(phFound, oscLBR, 1) and _inRange(phFound[1])
hidBear = detectHidden and priceLH and oscHH and phFound

regBullFinal = regBull and (not requireFVG or bullFVGConf) and confirmedBar
regBearFinal = regBear and (not requireFVG or bearFVGConf) and confirmedBar
hidBullFinal = hidBull and (not requireFVG or bullFVGConf) and confirmedBar
hidBearFinal = hidBear and (not requireFVG or bearFVGConf) and confirmedBar

prevPivotLow_price  = ta.valuewhen(plFound, lowLBR,  1)
prevPivotHigh_price = ta.valuewhen(phFound, highLBR, 1)
prevPivotLow_bar    = ta.valuewhen(plFound, bar_index - lookbackRight, 1)
prevPivotHigh_bar   = ta.valuewhen(phFound, bar_index - lookbackRight, 1)

var string lastDivLabel    = "NONE"
var int    barsSinceLastDiv = -1
if barsSinceLastDiv >= 0
    barsSinceLastDiv := barsSinceLastDiv + 1
if regBullFinal
    lastDivLabel := "REG BULL"
    barsSinceLastDiv := 0
if regBearFinal
    lastDivLabel := "REG BEAR"
    barsSinceLastDiv := 0
if hidBullFinal
    lastDivLabel := "HID BULL"
    barsSinceLastDiv := 0
if hidBearFinal
    lastDivLabel := "HID BEAR"
    barsSinceLastDiv := 0

// ════════════════════════════════════════════════════════════════════
// ZONE ARRAYS + MITIGATION ITERATION
// ════════════════════════════════════════════════════════════════════
var array<line>  bullZoneEdge     = array.new<line>()
var array<line>  bullZoneBase     = array.new<line>()
var array<line>  bearZoneEdge     = array.new<line>()
var array<line>  bearZoneBase     = array.new<line>()
var array<linefill> bullZoneFill  = array.new<linefill>()
var array<linefill> bearZoneFill  = array.new<linefill>()
var array<label> bullZoneEdgeLbl  = array.new<label>()
var array<label> bearZoneEdgeLbl  = array.new<label>()

bullZoneMitigated      = false
bearZoneMitigated      = false
bullInFill             = false
bearInFill             = false
float bullMitigatePrice = na
float bearMitigatePrice = na

if (regBullFinal or hidBullFinal)
    xStart = bar_index - lookbackRight
    edgeC  = regBullFinal ? bullColor : color.new(bullColor, 30)
    bullEdge = line.new(xStart, bullZoneEdgePrice, bar_index + 1, bullZoneEdgePrice, color=edgeC, width=1, force_overlay=true)
    bullBase = line.new(xStart, bullZoneBasePrice, bar_index + 1, bullZoneBasePrice, color=color.new(bullColor, 80), width=1, force_overlay=true)
    array.unshift(bullZoneEdge, bullEdge)
    array.unshift(bullZoneBase, bullBase)
    lf = linefill.new(array.first(bullZoneEdge), array.first(bullZoneBase), color.new(bullColor, 82))
    array.unshift(bullZoneFill, lf)
    lbl = label.new(bar_index + 1, bullZoneEdgePrice, "Bull zone " + f_priceStr(bullZoneEdgePrice) + "  age 0",
         color=color.new(bullColor, 70), textcolor=color.white, style=label.style_label_left, size=size.tiny, force_overlay=true)
    label.set_xloc(lbl, bar_index + 1, xloc.bar_index)
    if not showZoneEdgeLabels
        label.set_color(lbl, color.new(color.white, 100))
        label.set_textcolor(lbl, color.new(color.white, 100))
    array.unshift(bullZoneEdgeLbl, lbl)

if (regBearFinal or hidBearFinal)
    xStart = bar_index - lookbackRight
    edgeC  = regBearFinal ? bearColor : color.new(bearColor, 30)
    bearEdge = line.new(xStart, bearZoneEdgePrice, bar_index + 1, bearZoneEdgePrice, color=edgeC, width=1, force_overlay=true)
    bearBase = line.new(xStart, bearZoneBasePrice, bar_index + 1, bearZoneBasePrice, color=color.new(bearColor, 80), width=1, force_overlay=true)
    array.unshift(bearZoneEdge, bearEdge)
    array.unshift(bearZoneBase, bearBase)
    lf = linefill.new(array.first(bearZoneEdge), array.first(bearZoneBase), color.new(bearColor, 82))
    array.unshift(bearZoneFill, lf)
    lbl = label.new(bar_index + 1, bearZoneEdgePrice, "Bear zone " + f_priceStr(bearZoneEdgePrice) + "  age 0",
         color=color.new(bearColor, 70), textcolor=color.white, style=label.style_label_left, size=size.tiny, force_overlay=true)
    label.set_xloc(lbl, bar_index + 1, xloc.bar_index)
    if not showZoneEdgeLabels
        label.set_color(lbl, color.new(color.white, 100))
        label.set_textcolor(lbl, color.new(color.white, 100))
    array.unshift(bearZoneEdgeLbl, lbl)

if array.size(bullZoneEdge) > 0
    for ln = array.size(bullZoneEdge) - 1 to 0
        if ln < array.size(bullZoneEdge)
            cL  = array.get(bullZoneEdge, ln)
            cL_ = array.get(bullZoneBase, ln)
            yL  = line.get_y1(cL)
            x1  = line.get_x1(cL)
            age = bar_index - x1

            sweep_price      = mitigationMode == "body" ? close    : low
            sweep_price_prev = mitigationMode == "body" ? close[1] : low[1]

            bool remove_by_mitigation = false
            if allowRejection and mitigationMode == "body"
                remove_by_mitigation := sweep_price < yL and sweep_price_prev < yL
            else
                remove_by_mitigation := sweep_price < yL

            if remove_by_mitigation or age > expiryAge
                if remove_by_mitigation
                    bullMitigatePrice := yL
                array.remove(bullZoneEdge, ln)
                array.remove(bullZoneBase, ln)
                if ln < array.size(bullZoneFill)
                    array.remove(bullZoneFill, ln)
                if ln < array.size(bullZoneEdgeLbl)
                    label.delete(array.get(bullZoneEdgeLbl, ln))
                    array.remove(bullZoneEdgeLbl, ln)
                bullZoneMitigated := true
            else
                zoneTop = math.max(line.get_y1(cL), line.get_y1(cL_))
                zoneBot = math.min(line.get_y1(cL), line.get_y1(cL_))
                bullInFill := bullInFill or (high >= zoneBot and low <= zoneTop)
                line.set_x2(cL,  bar_index + 1)
                line.set_x2(cL_, bar_index + 1)
                if showZoneFade and ln < array.size(bullZoneFill)
                    fillCol = color.new(bullColor, math.min(95, 82 + f_ageAlphaBump(age)))
                    linefill.set_color(array.get(bullZoneFill, ln), fillCol)
                if ln < array.size(bullZoneEdgeLbl)
                    elbl = array.get(bullZoneEdgeLbl, ln)
                    label.set_xy(elbl, bar_index + 1, yL)
                    if showZoneEdgeLabels
                        label.set_text(elbl, "Bull zone " + f_priceStr(yL) + "  age " + str.tostring(age))
                        label.set_color(elbl, color.new(bullColor, math.min(95, 60 + f_ageAlphaBump(age))))
                        label.set_textcolor(elbl, color.new(color.white, math.min(95, f_ageAlphaBump(age))))
                    else
                        label.set_color(elbl, color.new(color.white, 100))
                        label.set_textcolor(elbl, color.new(color.white, 100))

if array.size(bearZoneEdge) > 0
    for ln = array.size(bearZoneEdge) - 1 to 0
        if ln < array.size(bearZoneEdge)
            cL  = array.get(bearZoneEdge, ln)
            cL_ = array.get(bearZoneBase, ln)
            yL  = line.get_y1(cL)
            x1  = line.get_x1(cL)
            age = bar_index - x1

            sweep_price      = mitigationMode == "body" ? close    : high
            sweep_price_prev = mitigationMode == "body" ? close[1] : high[1]

            bool remove_by_mitigation = false
            if allowRejection and mitigationMode == "body"
                remove_by_mitigation := sweep_price > yL and sweep_price_prev > yL
            else
                remove_by_mitigation := sweep_price > yL

            if remove_by_mitigation or age > expiryAge
                if remove_by_mitigation
                    bearMitigatePrice := yL
                array.remove(bearZoneEdge, ln)
                array.remove(bearZoneBase, ln)
                if ln < array.size(bearZoneFill)
                    array.remove(bearZoneFill, ln)
                if ln < array.size(bearZoneEdgeLbl)
                    label.delete(array.get(bearZoneEdgeLbl, ln))
                    array.remove(bearZoneEdgeLbl, ln)
                bearZoneMitigated := true
            else
                zoneTop = math.max(line.get_y1(cL), line.get_y1(cL_))
                zoneBot = math.min(line.get_y1(cL), line.get_y1(cL_))
                bearInFill := bearInFill or (high >= zoneBot and low <= zoneTop)
                line.set_x2(cL,  bar_index + 1)
                line.set_x2(cL_, bar_index + 1)
                if showZoneFade and ln < array.size(bearZoneFill)
                    fillCol = color.new(bearColor, math.min(95, 82 + f_ageAlphaBump(age)))
                    linefill.set_color(array.get(bearZoneFill, ln), fillCol)
                if ln < array.size(bearZoneEdgeLbl)
                    elbl = array.get(bearZoneEdgeLbl, ln)
                    label.set_xy(elbl, bar_index + 1, yL)
                    if showZoneEdgeLabels
                        label.set_text(elbl, "Bear zone " + f_priceStr(yL) + "  age " + str.tostring(age))
                        label.set_color(elbl, color.new(bearColor, math.min(95, 60 + f_ageAlphaBump(age))))
                        label.set_textcolor(elbl, color.new(color.white, math.min(95, f_ageAlphaBump(age))))
                    else
                        label.set_color(elbl, color.new(color.white, 100))
                        label.set_textcolor(elbl, color.new(color.white, 100))

activeBullZones = array.size(bullZoneEdge)
activeBearZones = array.size(bearZoneEdge)

// ════════════════════════════════════════════════════════════════════
// CROSS-PANE DIVERGENCE PRICE LINES + LABELS
// ════════════════════════════════════════════════════════════════════
var array<line>  divPriceLines  = array.new<line>()
var array<label> divPriceLabels = array.new<label>()

f_pushDivLine(int x1, float y1, int x2, float y2, color c, string lstyle, bool isHidden) =>
    ls = lstyle == "dashed" ? line.style_dashed : line.style_solid
    alpha = isHidden ? 50 : 0
    ln = line.new(x1, y1, x2, y2, color=color.new(c, alpha), width=2, style=ls, force_overlay=true)
    array.unshift(divPriceLines, ln)
    if array.size(divPriceLines) > divPriceLineMax
        old = array.pop(divPriceLines)
        line.delete(old)

f_pushDivLabel(int x, float y, string txt, color c, bool isBull) =>
    lbl = label.new(x, y, txt,
         color=color.new(c, 30),
         textcolor=color.white,
         style=isBull ? label.style_label_up : label.style_label_down,
         size=size.tiny,
         force_overlay=true)
    array.unshift(divPriceLabels, lbl)
    if array.size(divPriceLabels) > divPriceLineMax
        old = array.pop(divPriceLabels)
        label.delete(old)

if showDivPriceLines and regBullFinal and not na(prevPivotLow_price) and not na(prevPivotLow_bar)
    f_pushDivLine(math.round(prevPivotLow_bar), prevPivotLow_price, bar_index - lookbackRight, lowLBR, bullColor, "solid", false)
    if showDivPriceLabels
        f_pushDivLabel(bar_index - lookbackRight, lowLBR, "REG BULL DIV " + f_priceStr(lowLBR), bullColor, true)

if showDivPriceLines and regBearFinal and not na(prevPivotHigh_price) and not na(prevPivotHigh_bar)
    f_pushDivLine(math.round(prevPivotHigh_bar), prevPivotHigh_price, bar_index - lookbackRight, highLBR, bearColor, "solid", false)
    if showDivPriceLabels
        f_pushDivLabel(bar_index - lookbackRight, highLBR, "REG BEAR DIV " + f_priceStr(highLBR), bearColor, false)

if showDivPriceLines and hidBullFinal and not na(prevPivotLow_price) and not na(prevPivotLow_bar)
    f_pushDivLine(math.round(prevPivotLow_bar), prevPivotLow_price, bar_index - lookbackRight, lowLBR, bullColor, "dashed", true)
    if showDivPriceLabels
        f_pushDivLabel(bar_index - lookbackRight, lowLBR, "HID BULL DIV " + f_priceStr(lowLBR), bullColor, true)

if showDivPriceLines and hidBearFinal and not na(prevPivotHigh_price) and not na(prevPivotHigh_bar)
    f_pushDivLine(math.round(prevPivotHigh_bar), prevPivotHigh_price, bar_index - lookbackRight, highLBR, bearColor, "dashed", true)
    if showDivPriceLabels
        f_pushDivLabel(bar_index - lookbackRight, highLBR, "HID BEAR DIV " + f_priceStr(highLBR), bearColor, false)

// ════════════════════════════════════════════════════════════════════
// MITIGATION FLASH LABELS
// ════════════════════════════════════════════════════════════════════
var array<label> mitigationLabels = array.new<label>()

f_pushMitLabel(float p, string txt, color c, bool isBull) =>
    lbl = label.new(bar_index, p, txt,
         color=color.new(c, 40),
         textcolor=color.white,
         style=isBull ? label.style_label_up : label.style_label_down,
         size=size.tiny,
         force_overlay=true)
    array.unshift(mitigationLabels, lbl)
    if array.size(mitigationLabels) > mitigationLabelMax
        old = array.pop(mitigationLabels)
        label.delete(old)

if showMitigationLabels and bullZoneMitigated and not na(bullMitigatePrice)
    f_pushMitLabel(bullMitigatePrice, "Bull mitigated " + f_priceStr(bullMitigatePrice), bullColor, false)

if showMitigationLabels and bearZoneMitigated and not na(bearMitigatePrice)
    f_pushMitLabel(bearMitigatePrice, "Bear mitigated " + f_priceStr(bearMitigatePrice), bearColor, true)

// ════════════════════════════════════════════════════════════════════
// SIGNAL ENGINE
// ════════════════════════════════════════════════════════════════════
bullZoneTouch = bullInFill and close > open and confirmedBar
bearZoneTouch = bearInFill and close < open and confirmedBar

bullStack = activeBullZones >= 3 and regBullFinal
bearStack = activeBearZones >= 3 and regBearFinal

var int streakUp   = 0
var int streakDown = 0
streakUp   := composite > 0 ? streakUp   + 1 : 0
streakDown := composite < 0 ? streakDown + 1 : 0
bullStreak = streakUp   == 5 and confirmedBar
bearStreak = streakDown == 5 and confirmedBar

compPct = ta.percentrank(composite, 100)

compStack = (composite > 0 ? 1 : 0) + (mfi > 50 ? 1 : 0) + (cvd_pct > 50 ? 1 : 0) + (obvRocZ > 0 ? 1 : 0)

// ════════════════════════════════════════════════════════════════════
// VISUALS — PANE
// ════════════════════════════════════════════════════════════════════
noneColor = color.new(color.white, 100)

p_p05 = plot(showPercentileBand ? compP05 : na, "Comp P5",  color=noneColor, display=display.pane, editable=false)
p_p95 = plot(showPercentileBand ? compP95 : na, "Comp P95", color=noneColor, display=display.pane, editable=false)
fill(p_p05, p_p95, color=showPercentileBand ? color.new(chart.fg_color, 92) : noneColor, title="Composite Percentile Band")

compColor = composite >= signal_line
     ? color.from_gradient(math.abs(composite - signal_line), 0.0, 30.0, color.new(bullColor, 80), color.new(bullColor, 0))
     : color.from_gradient(math.abs(composite - signal_line), 0.0, 30.0, color.new(bearColor, 80), color.new(bearColor, 0))

pComp = plot(composite,   "Composite",  color=compColor, linewidth=2)
pSig  = plot(signal_line, "Signal",     color=color.new(chart.fg_color, 70), linewidth=1)
fillAlpha = f_alpha(composite - signal_line)
fill(pComp, pSig, color=color.new(compColor, fillAlpha), title="Composite Fill")

midTransp = 90 - math.min(90, math.round(math.abs(composite) * 0.8))
plot(0, "Mid", color=color.new(composite >= 0 ? bullColor : bearColor, midTransp), linewidth=2)

hline( 70, "Upper Rail", color=color.new(bullColor, 80), linestyle=hline.style_dotted)
hline(-70, "Lower Rail", color=color.new(bearColor, 80), linestyle=hline.style_dotted)

plot(plFound ? oscLBR : na, "Reg Bull Connector", offset=-lookbackRight, linewidth=2, color=regBullFinal ? bullColor : noneColor, display=display.pane)
plot(phFound ? oscLBR : na, "Reg Bear Connector", offset=-lookbackRight, linewidth=2, color=regBearFinal ? bearColor : noneColor, display=display.pane)

plot(plFound and detectHidden ? oscLBR : na, "Hid Bull Connector", offset=-lookbackRight, linewidth=2, color=hidBullFinal ? color.new(bullColor, 40) : noneColor, display=display.pane, style=plot.style_line)
plot(phFound and detectHidden ? oscLBR : na, "Hid Bear Connector", offset=-lookbackRight, linewidth=2, color=hidBearFinal ? color.new(bearColor, 40) : noneColor, display=display.pane, style=plot.style_line)

plotchar(regBullFinal or hidBullFinal ? oscLBR : na, "Bull Pivot Dot", offset=-lookbackRight, char="·", location=location.absolute, color=bullColor, size=size.small)
plotchar(regBearFinal or hidBearFinal ? oscLBR : na, "Bear Pivot Dot", offset=-lookbackRight, char="·", location=location.absolute, color=bearColor, size=size.small)

plotchar(bullZoneTouch ? low  - syminfo.mintick * 4 : na, "Bull Zone Touch", char="·", location=location.absolute, color=bullColor, size=size.tiny, force_overlay=true)
plotchar(bearZoneTouch ? high + syminfo.mintick * 4 : na, "Bear Zone Touch", char="·", location=location.absolute, color=bearColor, size=size.tiny, force_overlay=true)

plotchar(regBullFinal ? lowLBR  : na, "Bull Pivot Price", offset=-lookbackRight, char="·", location=location.absolute, color=bullColor, size=size.tiny, force_overlay=true)
plotchar(regBearFinal ? highLBR : na, "Bear Pivot Price", offset=-lookbackRight, char="·", location=location.absolute, color=bearColor, size=size.tiny, force_overlay=true)

crossPaneTint = not showCompositeTint ? na : composite > 30 ? color.new(bullColor, 96) : composite < -30 ? color.new(bearColor, 96) : na
bgcolor(crossPaneTint, force_overlay=true, title="Composite Cross-Pane Tint")

mitPulseBull = bullZoneMitigated ? color.new(bullColor, 85) : na
mitPulseBear = bearZoneMitigated ? color.new(bearColor, 85) : na
bgcolor(mitPulseBull, force_overlay=true, title="Bull Mitigation Pulse")
bgcolor(mitPulseBear, force_overlay=true, title="Bear Mitigation Pulse")

// ════════════════════════════════════════════════════════════════════
// PANE COMPOSITE CLUSTER (right-edge labels in pane)
// ════════════════════════════════════════════════════════════════════
var label clComp = na
var label clComps = na
var label clObv  = na

if barstate.islast
    if not na(clComp)
        label.delete(clComp)
    if not na(clComps)
        label.delete(clComps)
    if not na(clObv)
        label.delete(clObv)
    clComp  := na
    clComps := na
    clObv   := na

    if showCompositeCluster
        compSign  = composite >= 0
        compTint  = compSign ? color.new(bullColor, 40) : color.new(bearColor, 40)
        compTxt1  = "Composite " + (compSign ? "+" : "") + str.tostring(composite, "0") + "  pct " + str.tostring(compPct, "0") + "%"
        clComp := label.new(bar_index + 5, composite, compTxt1,
             color=compTint, textcolor=color.white,
             style=label.style_label_left, size=size.small)

        compTxt2  = "MFI " + str.tostring(mfi, "0") + "  CVD% " + str.tostring(cvd_pct, "0")
        offsetY1 = math.abs(composite) < 60 ? 14.0 : -14.0
        clComps := label.new(bar_index + 5, composite + offsetY1, compTxt2,
             color=color.new(chart.fg_color, 70), textcolor=color.white,
             style=label.style_label_left, size=size.small)

        obvSign = obvRocZ >= 0
        compTxt3 = "OBV-Z " + (obvSign ? "+" : "") + str.tostring(obvRocZ, "0.0") + "  Stack: " + str.tostring(compStack) + "/4"
        offsetY2 = math.abs(composite) < 60 ? 28.0 : -28.0
        clObv := label.new(bar_index + 5, composite + offsetY2, compTxt3,
             color=obvSign ? color.new(bullColor, 55) : color.new(bearColor, 55),
             textcolor=color.white, style=label.style_label_left, size=size.small)

// ════════════════════════════════════════════════════════════════════
// PANE RIGHT-EDGE STATE STRIP
// ════════════════════════════════════════════════════════════════════
var label stripDiv  = na
var label stripBull = na
var label stripBear = na
var label stripFvg  = na

if barstate.islast
    if not na(stripDiv)
        label.delete(stripDiv)
    if not na(stripBull)
        label.delete(stripBull)
    if not na(stripBear)
        label.delete(stripBear)
    if not na(stripFvg)
        label.delete(stripFvg)
    stripDiv  := na
    stripBull := na
    stripBear := na
    stripFvg  := na

    if showStateStrip
        anchor = -70.0
        divTxt   = "Last div: " + lastDivLabel + (barsSinceLastDiv >= 0 ? "  " + str.tostring(barsSinceLastDiv) + " bars ago" : "")
        divTint  = lastDivLabel == "REG BULL" ? color.new(bullColor, 50) : lastDivLabel == "HID BULL" ? color.new(bullColor, 65) : lastDivLabel == "REG BEAR" ? color.new(bearColor, 50) : lastDivLabel == "HID BEAR" ? color.new(bearColor, 65) : color.new(chart.fg_color, 75)
        stripDiv  := label.new(bar_index + 5, anchor,        divTxt,
             color=divTint, textcolor=color.white,
             style=label.style_label_left, size=size.small)
        stripBull := label.new(bar_index + 5, anchor - 14.0, "Bull zones: " + str.tostring(activeBullZones) + " active",
             color=activeBullZones > 0 ? color.new(bullColor, 55) : color.new(chart.fg_color, 75),
             textcolor=color.white, style=label.style_label_left, size=size.small)
        stripBear := label.new(bar_index + 5, anchor - 28.0, "Bear zones: " + str.tostring(activeBearZones) + " active",
             color=activeBearZones > 0 ? color.new(bearColor, 55) : color.new(chart.fg_color, 75),
             textcolor=color.white, style=label.style_label_left, size=size.small)
        fvgState = not requireFVG ? "OFF" : (bullFVGConf or bearFVGConf) ? "YES" : "NO"
        fvgTint  = not requireFVG ? color.new(chart.fg_color, 75) : (bullFVGConf or bearFVGConf) ? color.new(bullColor, 55) : color.new(bearColor, 55)
        stripFvg := label.new(bar_index + 5, anchor - 42.0, "FVG conf: " + fvgState,
             color=fvgTint, textcolor=color.white,
             style=label.style_label_left, size=size.small)

// ════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════
f_divCellBg(string s) =>
    s == "REG BULL" ? color.new(bullColor, 35) :
     s == "HID BULL" ? color.new(bullColor, 60) :
     s == "REG BEAR" ? color.new(bearColor, 35) :
     s == "HID BEAR" ? color.new(bearColor, 60) :
     color.new(chart.fg_color, 80)

f_fvgCell(bool conf, bool active) =>
    not active ? "—" : conf ? "YES" : "NO"

f_fvgCellBg(bool conf, bool active, color baseCol) =>
    not active   ? color.new(chart.fg_color, 80) :
     conf        ? color.new(baseCol, 50) :
     color.new(bearColor, 70)

f_compCellBg(float v) =>
    v >  30 ? color.new(bullColor, 40) :
     v < -30 ? color.new(bearColor, 40) :
     color.new(chart.fg_color, 80)

f_mfiBg(float m) =>
    m > 70 ? color.new(bullColor, 50) :
     m < 30 ? color.new(bearColor, 50) :
     color.new(chart.fg_color, 80)

f_cvdBg(float p) =>
    p > 70 ? color.new(bullColor, 50) :
     p < 30 ? color.new(bearColor, 50) :
     color.new(chart.fg_color, 80)

f_zBg(float z) =>
    z >  1.5 ? color.new(bullColor, 40) :
     z < -1.5 ? color.new(bearColor, 40) :
     color.new(chart.fg_color, 80)

var table dash = table.new(position.top_right, 2, 11,
     bgcolor      = #111118,
     border_color = #252535,
     border_width = 1,
     frame_color  = #252535,
     frame_width  = 1)

if barstate.islast and showDash
    dash := table.new(posFromString(dashPos), 2, 11,
         bgcolor      = #111118,
         border_color = #252535,
         border_width = 1,
         frame_color  = #252535,
         frame_width  = 1)
    table.clear(dash, 0, 0, 1, 10)
    txtSize = sizeFromString(dashSize)

    table.cell(dash, 0, 0, "Tidal Divergence [JOAT]", text_color=color.white, bgcolor=color.new(bullColor, 30), text_size=txtSize)
    table.cell(dash, 1, 0, "",                        text_color=color.white, bgcolor=color.new(bullColor, 30), text_size=txtSize)
    table.merge_cells(dash, 0, 0, 1, 0)

    compTxt = str.tostring(composite, "0.0") + "  (" + str.tostring(compPct, "0") + "%)"
    table.cell(dash, 0, 1, "Composite", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 1, compTxt,     text_color=color.white,    bgcolor=f_compCellBg(composite), text_size=txtSize)

    table.cell(dash, 0, 2, "MFI",                    text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 2, str.tostring(mfi, "0.0"), text_color=color.white,    bgcolor=f_mfiBg(mfi), text_size=txtSize)

    table.cell(dash, 0, 3, "CVD %",                      text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 3, str.tostring(cvd_pct, "0.0"), text_color=color.white,    bgcolor=f_cvdBg(cvd_pct), text_size=txtSize)

    table.cell(dash, 0, 4, "OBV ROC Z",                    text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 4, str.tostring(obvRocZ, "0.00"),  text_color=color.white,    bgcolor=f_zBg(obvRocZ), text_size=txtSize)

    table.cell(dash, 0, 5, "Last Div",     text_color=chart.fg_color, bgcolor=#1a1a26,             text_size=txtSize)
    table.cell(dash, 1, 5, lastDivLabel,   text_color=color.white,    bgcolor=f_divCellBg(lastDivLabel), text_size=txtSize)

    barsSinceTxt = barsSinceLastDiv < 0 ? "—" : str.tostring(barsSinceLastDiv)
    table.cell(dash, 0, 6, "Bars Since Div",  text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 6, barsSinceTxt,      text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    table.cell(dash, 0, 7, "Active Bull Zones",            text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 7, str.tostring(activeBullZones),  text_color=color.white,    bgcolor=activeBullZones > 0 ? color.new(bullColor, 50) : #1a1a26, text_size=txtSize)

    table.cell(dash, 0, 8, "Active Bear Zones",            text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 8, str.tostring(activeBearZones),  text_color=color.white,    bgcolor=activeBearZones > 0 ? color.new(bearColor, 50) : #1a1a26, text_size=txtSize)

    table.cell(dash, 0, 9, "FVG Conf Bull",                                       text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 9, f_fvgCell(bullFVGConf, requireFVG),                    text_color=color.white,    bgcolor=f_fvgCellBg(bullFVGConf, requireFVG, bullColor), text_size=txtSize)

    table.cell(dash, 0, 10, "@JackOfAllTrades", text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize)
    table.cell(dash, 1, 10, "",                 text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize)
    table.merge_cells(dash, 0, 10, 1, 10)

// ════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════
alertcondition(regBullFinal,                            title="TDV Regular Bull Div",      message="Tidal Divergence [JOAT] — Regular bullish divergence")
alertcondition(regBearFinal,                            title="TDV Regular Bear Div",      message="Tidal Divergence [JOAT] — Regular bearish divergence")
alertcondition(hidBullFinal,                            title="TDV Hidden Bull Div",       message="Tidal Divergence [JOAT] — Hidden bullish divergence")
alertcondition(hidBearFinal,                            title="TDV Hidden Bear Div",       message="Tidal Divergence [JOAT] — Hidden bearish divergence")
alertcondition(bullZoneTouch,                           title="TDV Bull Zone Touch",       message="Tidal Divergence [JOAT] — Bull zone touch")
alertcondition(bearZoneTouch,                           title="TDV Bear Zone Touch",       message="Tidal Divergence [JOAT] — Bear zone touch")
alertcondition(bullZoneMitigated and confirmedBar,      title="TDV Bull Zone Mitigated",   message="Tidal Divergence [JOAT] — Bull zone mitigated")
alertcondition(bearZoneMitigated and confirmedBar,      title="TDV Bear Zone Mitigated",   message="Tidal Divergence [JOAT] — Bear zone mitigated")
alertcondition(bullStack and confirmedBar,              title="TDV Bull Triple Stack",     message="Tidal Divergence [JOAT] — Bull triple stack (3+ active zones + regular bull divergence)")
alertcondition(bearStack and confirmedBar,              title="TDV Bear Triple Stack",     message="Tidal Divergence [JOAT] — Bear triple stack (3+ active zones + regular bear divergence)")
alertcondition(bullStreak,                              title="TDV Bull Composite Streak", message="Tidal Divergence [JOAT] — Composite above zero for 5 bars")
alertcondition(bearStreak,                              title="TDV Bear Composite Streak", message="Tidal Divergence [JOAT] — Composite below zero for 5 bars")
````
