# Fibonacci & RSI Aligned Analysis

- url: https://www.tradingview.com/script/jLIlXavw-Fibonacci-RSI-Aligned-Analysis/
- type: indicator
- pine_id: PUB;246253b8d07a420cbf9b4b153eb851ce
- version: 1.0

## Description

Fibonacci & RSI Aligned Analysis
[url=https://www.tradingview.com/u/Michael_Fx_Trader/]https://www.tradingview.com/u/Michael_Fx_Trader/[/url]

What This Indicator Is

Fibonacci & RSI Aligned Analysis is a confluence trading tool that combines two of the most widely used concepts in technical analysis, Fibonacci retracement and RSI divergence, into a single automatic system. Instead of the trader manually drawing Fibonacci levels after every swing and separately hunting for divergence on the RSI, the indicator tracks the market's swing structure on its own, draws and updates the Fibonacci retracement automatically, watches the RSI for genuine divergence at each new swing, and only raises a Buy or Sell signal when both of those elements line up together at the same point in time. It works on any timeframe and any symbol, from Gold to Forex pairs to indices, since every calculation is based on bar counts and price action rather than anything tied to a single timeframe.

[image]https://www.tradingview.com/x/kwi1S1jw/[/image]

Why It Was Built

Fibonacci retracement and RSI divergence are each powerful on their own, but each also produces plenty of false signals when used alone. A retracement to the 61.8 percent level with no momentum confirmation is just a guess, and a divergence forming far away from any meaningful level is just noise. This indicator was built to filter both of those weaknesses out at once, by only calling something a real signal when a proper divergence appears exactly where the market is also sitting inside the golden retracement zone of a still-intact trend leg. The aim is fewer, higher quality signals rather than a constant stream of low confidence alerts.

How It Works

The indicator continuously watches for confirmed swing highs and swing lows using a standard pivot detection method. Rather than redrawing the Fibonacci levels after every single new pivot, which would make the chart flicker and lose its larger context, it keeps track of a proper trend leg. That leg only changes when the market genuinely breaks its structure, either by extending further in the same direction with a new higher high in an uptrend or a new lower low in a downtrend, or by truly reversing when price breaks back past the origin of the current leg. A small pullback pivot that stays inside the current leg's range does not redefine anything, which is exactly what allows a pullback low or high to still be read correctly as part of the larger trend rather than accidentally being treated as a brand new trend on its own.

From that trend leg, the indicator draws the full set of Fibonacci retracement levels, with the twenty three point six, thirty eight point two, fifty, sixty one point eight, seventy eight point six, and one hundred percent lines, and shades the area between sixty one point eight and seventy eight point six as the primary zone of interest, since that is the region where a healthy pullback is expected to end before the original trend resumes. At the same time, every new swing high or swing low is compared against the previous one of the same type on the RSI. A swing low that is lower in price but higher on the RSI is a bullish divergence; a swing high that is higher in price but lower on the RSI is a bearish divergence. A Buy signal only appears when a bullish divergence lines up with price sitting inside the golden zone of an active uptrend leg, and a Sell signal only appears when a bearish divergence lines up with price sitting inside the golden zone of an active downtrend leg. An optional round number filter can be switched on to additionally require price to be near a psychologically significant level, and an optional session filter can restrict full confidence signals to the London and New York sessions, while still showing anything that fires outside those hours at a lower opacity instead of hiding it completely.

How To Read The Chart

Every Fibonacci line is labeled directly with its percentage, and the sixty one point eight and seventy eight point six lines are drawn thicker than the rest so the key zone is easy to spot at a glance. Whenever a fresh divergence is detected, a short connecting line joins the previous swing point to the new one, both on the price chart and on the RSI panel underneath, with a small Bull Div or Bear Div label marking exactly where it happened. When every condition lines up, a clear Buy or Sell label appears directly on the candle where the signal fired, along with the exact price it triggered at, and a small colored marker box highlights that precise price zone. Only the most recent handful of signals are kept visible at any time so the chart never becomes cluttered with old, no longer relevant setups.

How To Use It For Analysis

Start by looking at which direction the current active leg is pointing, since that alone tells you which type of signal the indicator is currently prepared to give. As price pulls back into the shaded sixty one point eight to seventy eight point six zone, watch the RSI panel closely for a divergence line to appear at the same time; that combination is the entire thesis behind every signal this indicator produces. Treat a signal that appears during the London or New York session, or with the round number filter satisfied, with extra weight, and treat one that fires outside those conditions a little more cautiously, especially if you have the session filter turned on and can see it displayed with lower opacity. As always, this indicator maps out a structural and momentum based case for a trade, it does not replace your own trend context, support and resistance reading, or risk management before you actually enter a position.

What The Indicator Shows

On the price chart itself, you will see the current Fibonacci retracement levels for the active leg, the shaded golden zone between sixty one point eight and seventy eight point six, any recent divergence connecting lines, and the Buy or Sell labels for the last few confluence signals, along with an optional light background shading whenever price is near a chosen round number. Underneath, in its own panel, the RSI line is plotted together with the standard seventy and thirty overbought and oversold reference lines, along with the same divergence connecting lines drawn directly on the RSI itself so the exact same event can be confirmed from both views at once.

Settings Worth Knowing Before Use

The pivot sensitivity used to detect swing highs and lows, the RSI length and source, the tolerance percentage that defines how close price needs to be to count as inside the fib zone, the round number step size and tolerance, the London and New York session times, how many recent signals stay visible, and every color used can all be adjusted from the indicator's settings panel to suit different instruments, timeframes, and personal preferences.

Disclaimer

This indicator is a technical analysis tool and does not constitute financial advice. A confluence signal describes a specific combination of Fibonacci and RSI conditions being met at once, not a guarantee of a profitable outcome. All trading involves risk, and past reactions to similar setups do not guarantee future results. Always use proper risk management and combine this tool with your own analysis before entering any trade.

Original Script Declaration

Script Name: Fibonacci & RSI Aligned Analysis
Author: Michael_Fx_Trader
Publisher: Michael_Fx_Trader
Rights: Copyright Michael_Fx_Trader. All rights reserved.

Originality Statement: This is an original work, designed and coded from scratch by Michael_Fx_Trader. The trend leg tracking engine, which only redefines the active Fibonacci leg on a genuine structure break rather than on every minor retracement pivot, the RSI divergence detector, the fib zone plus divergence plus round number confluence signal logic, the session aware signal styling, and the automatic clean chart redraw system where old legs and old signals are removed rather than stacking indefinitely, were all independently conceived and implemented for this publication. No proprietary source code, private scripts, or copyrighted material belonging to any other author has been copied, mashed up, or reused in any part of this script.

Author Verification and Declaration: I, Michael_Fx_Trader, am the sole author and publisher of this script. I hold full authorship rights over its source code, its underlying logic, and its visual presentation. Fibonacci retracement and the Relative Strength Index are both well known, generic public domain technical analysis concepts and are not owned by any individual author; only the specific leg tracking, divergence, confluence, and display logic built around them here is original to this script.

## Source Code

````pine
//@version=6

// =============================================================================
//                         ORIGINAL SCRIPT DECLARATION
// =============================================================================
// Script Name   : Fibonacci & RSI Aligned Analysis
// Author        : Michael_Fx_Trader
// Publisher     : Michael_Fx_Trader
// Rights        : © Michael_Fx_Trader. All rights reserved.
//
// Originality Statement:
//   This is an original work, designed and coded from scratch by
//   Michael_Fx_Trader. The trend-leg tracking engine (which only redefines the
//   active Fibonacci leg on a genuine structure break rather than on every
//   minor retracement pivot), the RSI divergence detector, the fib-zone plus
//   divergence plus round-number confluence signal logic, the session-aware
//   signal styling, and the automatic clean-chart redraw system (old legs and
//   old signals are removed rather than stacking indefinitely) were all
//   independently conceived and implemented for this publication. No
//   proprietary source code, private scripts, or copyrighted material
//   belonging to any other author has been copied, mashed-up, or reused in
//   any part of this script.
//
// Author Verification / Declaration:
//   I, Michael_Fx_Trader, am the sole author and publisher of this script.
//   I hold full authorship rights over its source code, its underlying logic,
//   and its visual presentation. Fibonacci retracement and the Relative
//   Strength Index (RSI) are both well-known, generic public-domain technical
//   analysis concepts and are not owned by any individual author; only the
//   specific leg-tracking, divergence, confluence, and display logic built
//   around them here is original to this script.
// =============================================================================

indicator("Fibonacci & RSI Aligned Analysis", shorttitle = "Fib RSI Aligned", overlay = false,
     max_lines_count = 200, max_labels_count = 200, max_boxes_count = 100)

// =============================================================================
// 9. USER INPUTS
// =============================================================================

grpSwing = "Swing / Fibonacci Settings"
pivotLR       = input.int(5, "Pivot Left/Right Bars", minval = 1, maxval = 50, group = grpSwing,
     tooltip = "How many bars on each side confirm a swing high/low. Works the same on every timeframe since it is bar-count based, not time based.")
fibTolerancePct = input.float(1.5, "Fib Zone Tolerance (%)", minval = 0.1, step = 0.1, group = grpSwing,
     tooltip = "Price is considered 'at' the 61.8/78.6 zone if it is within this percentage of price around either level.")
showFibLines  = input.bool(true, "Show Fibonacci Lines", group = grpSwing)
showFibZoneBox = input.bool(true, "Shade 61.8%-78.6% Zone", group = grpSwing)

grpRsi = "RSI / Divergence Settings"
rsiLength   = input.int(14, "RSI Length", minval = 1, group = grpRsi)
rsiSource   = input.source(close, "RSI Source", group = grpRsi)
showRsiPanel = input.bool(true, "Show RSI Plot + 30/70 Lines", group = grpRsi)
showDivLabels = input.bool(true, "Show Divergence Labels", group = grpRsi)

grpRound = "Round Number Filter (Optional)"
useRoundFilter = input.bool(false, "Require Price Near a Round Number", group = grpRound)
roundStep      = input.float(50, "Round Number Step (e.g. 50 for Gold)", minval = 0.01, group = grpRound)
roundTolerance = input.float(3, "Round Number Tolerance (price units)", minval = 0.0, group = grpRound)
showRoundShading = input.bool(true, "Background Shade Near Round Numbers", group = grpRound)

grpSession = "Session Filter (Optional)"
useSessionFilter = input.bool(false, "Restrict Full-Confidence Signals to Preferred Sessions", group = grpSession,
     tooltip = "Signals outside the preferred sessions are still shown, just with lower opacity, instead of being hidden.")
londonSession = input.session("0700-1030", "London Session (GMT)", group = grpSession)
nySession     = input.session("1300-1600", "New York Session (GMT)", group = grpSession)

grpColors = "Colors"
bullColor = input.color(color.new(color.lime, 0), "Bullish / Buy Color", group = grpColors)
bearColor = input.color(color.new(color.red, 0),  "Bearish / Sell Color", group = grpColors)
fibColor  = input.color(color.new(color.orange, 0), "Fib Line Color", group = grpColors)
zoneColor = input.color(color.new(color.orange, 82), "Fib Zone Fill Color", group = grpColors)

maxSignalsShown = input.int(3, "Max Recent Signals Shown (per side)", minval = 1, maxval = 10, group = grpColors)

// =============================================================================
// 1-2. SWING STRUCTURE DETECTION (timeframe-agnostic via bar-count pivots)
// =============================================================================

rsiValue = ta.rsi(rsiSource, rsiLength)

ph = ta.pivothigh(high, pivotLR, pivotLR)
pl = ta.pivotlow(low, pivotLR, pivotLR)

var float lastSwingHighPrice = na
var int   lastSwingHighBar   = na
var float lastSwingLowPrice  = na
var int   lastSwingLowBar    = na

if not na(ph)
    lastSwingHighPrice := ph
    lastSwingHighBar   := bar_index - pivotLR
if not na(pl)
    lastSwingLowPrice := pl
    lastSwingLowBar   := bar_index - pivotLR

// =============================================================================
// RSI DIVERGENCE DETECTION (compares each new pivot to the previous one of the
// same type)
// =============================================================================

var float prevPivotLowPrice  = na
var float prevPivotLowRsi    = na
var int   prevPivotLowBar    = na
var float prevPivotHighPrice = na
var float prevPivotHighRsi   = na
var int   prevPivotHighBar   = na

bullishDivNow = false
bearishDivNow = false
var float bullDivFromPrice = na
var int   bullDivFromBar   = na
var float bullDivToPrice   = na
var int   bullDivToBar     = na
var float bullDivFromRsi   = na
var float bullDivToRsi     = na
var float bearDivFromPrice = na
var int   bearDivFromBar   = na
var float bearDivToPrice   = na
var int   bearDivToBar     = na
var float bearDivFromRsi   = na
var float bearDivToRsi     = na

if not na(pl)
    curLowPrice = pl
    curLowRsi   = rsiValue[pivotLR]
    curLowBar   = bar_index - pivotLR
    if not na(prevPivotLowPrice) and curLowPrice < prevPivotLowPrice and curLowRsi > prevPivotLowRsi
        bullishDivNow := true
        bullDivFromPrice := prevPivotLowPrice
        bullDivFromBar   := prevPivotLowBar
        bullDivToPrice   := curLowPrice
        bullDivToBar     := curLowBar
        bullDivFromRsi   := prevPivotLowRsi
        bullDivToRsi     := curLowRsi
    prevPivotLowPrice := curLowPrice
    prevPivotLowRsi   := curLowRsi
    prevPivotLowBar   := curLowBar

if not na(ph)
    curHighPrice = ph
    curHighRsi   = rsiValue[pivotLR]
    curHighBar   = bar_index - pivotLR
    if not na(prevPivotHighPrice) and curHighPrice > prevPivotHighPrice and curHighRsi < prevPivotHighRsi
        bearishDivNow := true
        bearDivFromPrice := prevPivotHighPrice
        bearDivFromBar   := prevPivotHighBar
        bearDivToPrice   := curHighPrice
        bearDivToBar     := curHighBar
        bearDivFromRsi   := prevPivotHighRsi
        bearDivToRsi     := curHighRsi
    prevPivotHighPrice := curHighPrice
    prevPivotHighRsi   := curHighRsi
    prevPivotHighBar   := curHighBar

// =============================================================================
// ACTIVE IMPULSE LEG TRACKING
// =============================================================================
// The leg only changes on a genuine structure event: either the trend extends
// (a new higher high in an up leg, a new lower low in a down leg) or the
// trend reverses because price breaks past the ORIGIN of the current leg. A
// retracement pivot that stays within the current leg's range does NOT change
// the leg - this is what lets a pullback's divergence still count as a
// continuation signal for the larger trend instead of constantly redefining
// the leg on every minor wiggle.

var string legDirection  = na   // "up" or "down"
var float  legStartPrice = na
var int    legStartBar   = na
var float  legEndPrice   = na
var int    legEndBar     = na

if na(legDirection) and not na(lastSwingHighPrice) and not na(lastSwingLowPrice)
    if lastSwingHighBar > lastSwingLowBar
        legDirection  := "up"
        legStartPrice := lastSwingLowPrice
        legStartBar   := lastSwingLowBar
        legEndPrice   := lastSwingHighPrice
        legEndBar     := lastSwingHighBar
    else
        legDirection  := "down"
        legStartPrice := lastSwingHighPrice
        legStartBar   := lastSwingHighBar
        legEndPrice   := lastSwingLowPrice
        legEndBar     := lastSwingLowBar

if not na(ph) and not na(legDirection)
    if legDirection == "up"
        if ph > legEndPrice
            legEndPrice := ph
            legEndBar   := bar_index - pivotLR
    else
        if ph > legStartPrice
            legDirection  := "up"
            legStartPrice := legEndPrice
            legStartBar   := legEndBar
            legEndPrice   := ph
            legEndBar     := bar_index - pivotLR

if not na(pl) and not na(legDirection)
    if legDirection == "down"
        if pl < legEndPrice
            legEndPrice := pl
            legEndBar   := bar_index - pivotLR
    else
        if pl < legStartPrice
            legDirection  := "down"
            legStartPrice := legEndPrice
            legStartBar   := legEndBar
            legEndPrice   := pl
            legEndBar     := bar_index - pivotLR

legValid = not na(legDirection)
legIsUp  = legDirection == "up"

// =============================================================================
// 3. FIBONACCI LEVELS - 0% at the most recent extreme, 100% at the leg origin
// =============================================================================

fibPrice(level) =>
    legValid ? legEndPrice + (legStartPrice - legEndPrice) * (level / 100.0) : na

fib0   = fibPrice(0.0)
fib236 = fibPrice(23.6)
fib382 = fibPrice(38.2)
fib50  = fibPrice(50.0)
fib618 = fibPrice(61.8)
fib786 = fibPrice(78.6)
fib100 = fibPrice(100.0)

// =============================================================================
// FIB DRAWING OBJECTS - redrawn only when the active leg actually changes
// =============================================================================

var line[]  fibLines  = array.new_line()
var label[] fibLabels = array.new_label()
var box     fibZoneBox = na

var int prevLegStartBar = na
var int prevLegEndBar   = na

newLegFormed = legValid and (legStartBar != prevLegStartBar or legEndBar != prevLegEndBar)

if newLegFormed
    // ---- clear the previous leg's drawings before drawing the new one ----
    if array.size(fibLines) > 0
        for i = 0 to array.size(fibLines) - 1
            line.delete(array.get(fibLines, i))
        array.clear(fibLines)
    if array.size(fibLabels) > 0
        for i = 0 to array.size(fibLabels) - 1
            label.delete(array.get(fibLabels, i))
        array.clear(fibLabels)
    if not na(fibZoneBox)
        box.delete(fibZoneBox)
        fibZoneBox := na

    if showFibLines
        levels = array.from(0.0, 23.6, 38.2, 50.0, 61.8, 78.6, 100.0)
        for i = 0 to array.size(levels) - 1
            lv = array.get(levels, i)
            lp = fibPrice(lv)
            isKeyLevel = lv == 61.8 or lv == 78.6
            ln = line.new(legStartBar, lp, bar_index, lp, color = fibColor, width = isKeyLevel ? 2 : 1,
                 style = line.style_dashed, extend = extend.right, force_overlay = true)
            array.push(fibLines, ln)
            lb = label.new(bar_index, lp, str.tostring(lv, "#.#") + "%", style = label.style_label_left,
                 color = color.new(color.black, 100), textcolor = fibColor, size = size.small, force_overlay = true)
            array.push(fibLabels, lb)
    if showFibZoneBox
        fibZoneBox := box.new(legStartBar, math.max(fib618, fib786), bar_index, math.min(fib618, fib786),
             border_color = fibColor, bgcolor = zoneColor, extend = extend.right, force_overlay = true)
    prevLegStartBar := legStartBar
    prevLegEndBar   := legEndBar

// =============================================================================
// 5. CONFLUENCE ENGINE
// =============================================================================

fibTolerance = close * fibTolerancePct / 100.0
fibZoneLow  = legValid ? math.min(fib618, fib786) - fibTolerance : na
fibZoneHigh = legValid ? math.max(fib618, fib786) + fibTolerance : na
nearFibZone = legValid and close >= fibZoneLow and close <= fibZoneHigh

isNearRound(price) =>
    remainder = price % roundStep
    dist = math.min(remainder, roundStep - remainder)
    dist <= roundTolerance

roundOk = not useRoundFilter or isNearRound(close)

buyConfluence  = bullishDivNow and legIsUp and nearFibZone and roundOk
sellConfluence = bearishDivNow and not legIsUp and nearFibZone and roundOk

// =============================================================================
// 7. SESSION FILTER (styling only - signals are never hidden by session)
// =============================================================================

inLondon = not na(time(timeframe.period, londonSession, "GMT"))
inNY     = not na(time(timeframe.period, nySession, "GMT"))
inPreferredSession = inLondon or inNY
sessionOk = not useSessionFilter or inPreferredSession

buySignalColor  = sessionOk ? bullColor : color.new(bullColor, 70)
sellSignalColor = sessionOk ? bearColor : color.new(bearColor, 70)

// =============================================================================
// RSI PANE PLOTTING + DIVERGENCE LINES ON THE RSI ITSELF
// =============================================================================

plot(showRsiPanel ? rsiValue : na, "RSI", color = color.new(color.aqua, 0), linewidth = 2)
hline(70, "Overbought", color = color.new(color.red, 50), linestyle = hline.style_dashed)
hline(30, "Oversold", color = color.new(color.green, 50), linestyle = hline.style_dashed)
hline(50, "Midline", color = color.new(color.gray, 70), linestyle = hline.style_dotted)

if bullishDivNow and showDivLabels
    line.new(bullDivFromBar, bullDivFromRsi, bullDivToBar, bullDivToRsi, color = bullColor, width = 2)
    label.new(bullDivToBar, bullDivToRsi, "Bull Div", style = label.style_label_up, color = color.new(bullColor, 0),
         textcolor = color.white, size = size.small)

if bearishDivNow and showDivLabels
    line.new(bearDivFromBar, bearDivFromRsi, bearDivToBar, bearDivToRsi, color = bearColor, width = 2)
    label.new(bearDivToBar, bearDivToRsi, "Bear Div", style = label.style_label_down, color = color.new(bearColor, 0),
         textcolor = color.white, size = size.small)

// =============================================================================
// 6. CHART DRAWINGS FOR SIGNALS + DIVERGENCE MARKERS ON PRICE (force_overlay)
// =============================================================================

if bullishDivNow and showDivLabels
    line.new(bullDivFromBar, bullDivFromPrice, bullDivToBar, bullDivToPrice, color = bullColor, width = 1,
         style = line.style_dotted, force_overlay = true)
    label.new(bullDivToBar, bullDivToPrice, "Bull Div", style = label.style_label_up,
         color = color.new(bullColor, 0), textcolor = color.white, size = size.small, force_overlay = true)

if bearishDivNow and showDivLabels
    line.new(bearDivFromBar, bearDivFromPrice, bearDivToBar, bearDivToPrice, color = bearColor, width = 1,
         style = line.style_dotted, force_overlay = true)
    label.new(bearDivToBar, bearDivToPrice, "Bear Div", style = label.style_label_down,
         color = color.new(bearColor, 0), textcolor = color.white, size = size.small, force_overlay = true)

bgcolor(showRoundShading and useRoundFilter and isNearRound(close) ? color.new(color.yellow, 85) : na,
     title = "Round Number Zone", force_overlay = true)

var label[] buySignalLabels  = array.new_label()
var box[]   buySignalMarkers = array.new_box()
var label[] sellSignalLabels  = array.new_label()
var box[]   sellSignalMarkers = array.new_box()

trimSignals(labArr, boxArr) =>
    if array.size(labArr) > maxSignalsShown
        label.delete(array.shift(labArr))
        box.delete(array.shift(boxArr))

if buyConfluence
    lb = label.new(bar_index, low, "BUY\n" + str.tostring(close, format.mintick), style = label.style_label_up,
         color = color.new(buySignalColor, 0), textcolor = color.white, size = size.small, force_overlay = true)
    bx = box.new(bar_index - 1, close + fibTolerance, bar_index + 1, close - fibTolerance,
         border_color = buySignalColor, bgcolor = color.new(buySignalColor, 80), force_overlay = true)
    array.push(buySignalLabels, lb)
    array.push(buySignalMarkers, bx)
    trimSignals(buySignalLabels, buySignalMarkers)

if sellConfluence
    lb = label.new(bar_index, high, "SELL\n" + str.tostring(close, format.mintick), style = label.style_label_down,
         color = color.new(sellSignalColor, 0), textcolor = color.white, size = size.small, force_overlay = true)
    bx = box.new(bar_index - 1, close + fibTolerance, bar_index + 1, close - fibTolerance,
         border_color = sellSignalColor, bgcolor = color.new(sellSignalColor, 80), force_overlay = true)
    array.push(sellSignalLabels, lb)
    array.push(sellSignalMarkers, bx)
    trimSignals(sellSignalLabels, sellSignalMarkers)

// =============================================================================
// 8. ALERTS
// =============================================================================

nearLevelText = legValid ? (math.abs(close - fib618) <= math.abs(close - fib786) ? "61.8%" : "78.6%") : "n/a"
sessionText   = inPreferredSession ? "inside preferred session" : "outside preferred session (lower confidence)"

alertcondition(buyConfluence, title = "Buy Confluence Signal", message = "Fibonacci & RSI Aligned Analysis: BUY confluence signal.")
alertcondition(sellConfluence, title = "Sell Confluence Signal", message = "Fibonacci & RSI Aligned Analysis: SELL confluence signal.")

if buyConfluence
    alert("Fibonacci & RSI Aligned Analysis - BUY signal. Price: " + str.tostring(close, format.mintick) +
         ". Fib level: " + nearLevelText + ". Session: " + sessionText + ".", alert.freq_once_per_bar)

if sellConfluence
    alert("Fibonacci & RSI Aligned Analysis - SELL signal. Price: " + str.tostring(close, format.mintick) +
         ". Fib level: " + nearLevelText + ". Session: " + sessionText + ".", alert.freq_once_per_bar)
````
