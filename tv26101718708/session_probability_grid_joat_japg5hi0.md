# Session Probability Grid [JOAT]

- url: https://www.tradingview.com/script/jaPG5hI0-Session-Probability-Grid-JOAT/
- type: indicator
- pine_id: PUB;997a23ea80f9429589e3168bd97daaf7
- version: 1.0

## Description

[b]Session Probability Grid [JOAT][/b]

[b]Introduction[/b]

Session Probability Grid is an open-source session auction map. It builds percent-based ladder levels from the active session open, tracks historical hit behavior for those levels, and displays probability-style context for expansion, exhaustion, and unusual session movement.

The problem it solves is session framing. Traders often know the open is important, but they may not know whether a move is normal for the current symbol and timeframe. This script records session outcomes and converts them into visible ladder probabilities.

[image]https://www.tradingview.com/x/6vagttFs/[/image]

[b]Core Concepts[/b]

[b]1. Session Open Ladder[/b]
The script creates six upside and six downside levels from the session open using configurable percentage steps. These levels frame how far price has moved away from the open.

[b]2. Historical Hit Memory[/b]
At the end of each session, the script updates arrays storing hit counts, sample counts, and continuation distance. This creates a rolling sample of how often each ladder has been reached.

[b]3. Opening Range Context[/b]
The first configurable number of bars defines the opening range. The session box and opening range box help distinguish early balance from later expansion.

[b]4. Expansion and Exhaustion States[/b]
Expansion states identify movement through areas with supportive historical behavior. Exhaustion states mark stretched locations where continuation may be less reliable.

[b]5. Session VWAP Gradient[/b]
The optional session VWAP gradient adds a live auction mean reference so ladder movement can be compared against the developing session control line.

[b]Features[/b]

[list]
[*][b]Open-relative ladder:[/b] Six upside and six downside levels based on configurable percent steps.
[*][b]Statistical memory:[/b] Tracks hit count, sample count, and continuation distance from completed sessions.
[*][b]Probability cards:[/b] Right-side cards show ladder behavior without crowding price.
[*][b]Expansion and exhaustion states:[/b] Highlights meaningful session movement conditions.
[*][b]Session and opening range boxes:[/b] Frames current auction development.
[*][b]Session VWAP gradient:[/b] Adds a developing mean reference.
[*][b]Candle coloring:[/b] Bars can be colored by session state.
[*][b]Dashboard:[/b] Shows session state, nearest ladder, hit probability, expected continuation, and range condition.
[*][b]Alerts:[/b] Upside expansion, downside expansion, upper exhaustion, and lower exhaustion.
[/list]

[b]Input Parameters[/b]

[b]Core Session:[/b] Active Session, Opening Range Bars, Stat Sample Cap, Session Range Box, Opening Range Box.

[b]Ladder:[/b] Open-Relative Ladders and Step 1 through Step 6.

[b]Signals and Visuals:[/b] Auction State Zones, State Projection Bars, Continuation Probability Gate, Right Probability Cards, Session Candle Color, Session VWAP Gradient, Dashboard.

[b]How to Use This Indicator[/b]

[b]Step 1: Start from the session open[/b]
The ladder levels are built from the open, so they frame the current session relative to its starting price.

[b]Step 2: Compare price to the ladder[/b]
As price approaches a ladder level, check the probability card and dashboard for historical hit and continuation context.

[b]Step 3: Distinguish expansion from exhaustion[/b]
Expansion and exhaustion states help separate normal auction development from stretched movement.

[b]Indicator Limitations[/b]

[list]
[*]Probabilities are based on the chart's available historical sessions and are not universal statistics.
[*]Session boundaries depend on the selected exchange/session setting.
[*]The script needs enough completed sessions to build useful samples.
[*]Probability context does not predict future price.
[/list]

[b]Originality Statement[/b]

Session Probability Grid is original in its combination of open-relative ladders, rolling hit memory, continuation-distance storage, session VWAP context, opening range framing, and expansion/exhaustion visualization. It is not just a static percent-level tool; it updates its context from completed session behavior.

[b]Disclaimer[/b]

This script is for educational and informational purposes only. It is not financial advice and does not recommend trades. Historical session behavior may not repeat. Use independent analysis and risk management.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Session Probability Grid [JOAT]", shorttitle="SPG [JOAT]", overlay=true, max_lines_count=220, max_boxes_count=120, max_labels_count=100)

// ============================================================================
// Session Probability Grid [JOAT]
// Original session auction map:
// - Tracks opening range, session range, and open-relative ladder levels.
// - Builds historical hit probabilities and expected continuation after hits.
// - Highlights normal, expansion, and unusual auction territory.
// - Uses close-confirmed auction state labels and managed objects.
// ============================================================================

// ============================================================================
// Palette
// ============================================================================
color colBull        = color.rgb(48, 214, 198)
color colBullStrong  = color.rgb(109, 255, 207)
color colBear        = color.rgb(255, 90, 158)
color colBearStrong  = color.rgb(255, 38, 129)
color colControl     = color.rgb(245, 199, 85)
color colViolet      = color.rgb(139, 111, 255)
color colNeutral     = color.rgb(132, 143, 165)
color colHud         = color.rgb(18, 24, 33)
color colHudSoft     = color.new(colHud, 76)

// ============================================================================
// Inputs
// ============================================================================
string groupCore = "Core"
string tradeSession = input.session("0930-1600", "Active Session", group=groupCore)
int openingBars = input.int(6, "Opening Range Bars", minval=2, maxval=30, group=groupCore)
int maxHistory = input.int(250, "Stat Sample Cap", minval=25, maxval=1000, group=groupCore)
bool showSessionBox = input.bool(true, "Session Range Box", group=groupCore)
bool showOpeningBox = input.bool(true, "Opening Range Box", group=groupCore)

string groupLadder = "Ladder"
bool showLadders = input.bool(true, "Open-Relative Ladders", group=groupLadder)
float stepOne = input.float(0.25, "Step 1", minval=0.05, maxval=5.0, step=0.05, group=groupLadder)
float stepTwo = input.float(0.50, "Step 2", minval=0.05, maxval=5.0, step=0.05, group=groupLadder)
float stepThree = input.float(0.75, "Step 3", minval=0.05, maxval=5.0, step=0.05, group=groupLadder)
float stepFour = input.float(1.00, "Step 4", minval=0.05, maxval=5.0, step=0.05, group=groupLadder)
float stepFive = input.float(1.25, "Step 5", minval=0.05, maxval=5.0, step=0.05, group=groupLadder)
float stepSix = input.float(1.50, "Step 6", minval=0.05, maxval=5.0, step=0.05, group=groupLadder)

string groupSignals = "Signals"
bool showAuctionStates = input.bool(true, "Auction State Zones", group=groupSignals)
int projectionBars = input.int(24, "State Projection Bars", minval=6, maxval=80, group=groupSignals)
float probabilityGate = input.float(0.48, "Continuation Probability Gate", minval=0.20, maxval=0.90, step=0.01, group=groupSignals)

string groupVisuals = "Visuals"
bool showProbabilityCards = input.bool(true, "Right Probability Cards", group=groupVisuals)
bool colorCandles = input.bool(true, "Session Candle Color", group=groupVisuals)
bool showSessionVwap = input.bool(true, "Session VWAP Gradient", group=groupVisuals)
bool showDashboard = input.bool(true, "Dashboard", group=groupVisuals)

// ============================================================================
// Helpers
// ============================================================================
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(x, hi))

f_prob(int hits, int samples) =>
    samples > 0 ? (hits + 1.0) / (samples + 2.0) : 0.5

f_expected(float moveSum, int hits) =>
    hits > 0 ? moveSum / hits : na

f_trim_boxes(box[] boxes, int maxItems) =>
    while array.size(boxes) > maxItems
        box.delete(array.shift(boxes))

f_trim_labels(label[] labels, int maxItems) =>
    while array.size(labels) > maxItems
        label.delete(array.shift(labels))

f_clear_boxes(box[] boxes) =>
    while array.size(boxes) > 0
        box.delete(array.pop(boxes))

f_clear_labels(label[] labels) =>
    while array.size(labels) > 0
        label.delete(array.pop(labels))

// ============================================================================
// Session state and opening range
// ============================================================================
bool inSession = not na(time(timeframe.period, tradeSession))
bool newSession = inSession and not inSession[1]
bool endedSession = not inSession and inSession[1]
float atr = ta.atr(14)

var int sessionBars = 0
var int sessionStart = na
var float sessionOpen = na
var float sessionHigh = na
var float sessionLow = na
var float openingHigh = na
var float openingLow = na
var float sessionCumPV = 0.0
var float sessionCumVol = 0.0

// ============================================================================
// Statistical memory
// Arrays store hit count, sample count, and continuation distance for six
// upside and six downside ladder levels.
// ============================================================================
var int[] upHits = array.new_int(6, 0)
var int[] upSamples = array.new_int(6, 0)
var float[] upMoveSum = array.new_float(6, 0.0)
var bool[] upTouched = array.new_bool(6, false)
var float[] upLevelsSaved = array.new_float(6, na)

var int[] dnHits = array.new_int(6, 0)
var int[] dnSamples = array.new_int(6, 0)
var float[] dnMoveSum = array.new_float(6, 0.0)
var bool[] dnTouched = array.new_bool(6, false)
var float[] dnLevelsSaved = array.new_float(6, na)

// Finalize the just-ended session once, using the levels saved from that
// session and the completed session high/low.
if endedSession and not na(sessionHigh) and not na(sessionLow)
    for i = 0 to 5
        int oldUpSamples = array.get(upSamples, i)
        int oldDnSamples = array.get(dnSamples, i)
        bool acceptUpSample = oldUpSamples < maxHistory
        bool acceptDnSample = oldDnSamples < maxHistory
        if acceptUpSample
            array.set(upSamples, i, oldUpSamples + 1)
        if acceptDnSample
            array.set(dnSamples, i, oldDnSamples + 1)

        if acceptUpSample and array.get(upTouched, i)
            float lvl = array.get(upLevelsSaved, i)
            array.set(upHits, i, array.get(upHits, i) + 1)
            array.set(upMoveSum, i, array.get(upMoveSum, i) + math.max(sessionHigh - lvl, 0.0))
        if acceptDnSample and array.get(dnTouched, i)
            float lvl = array.get(dnLevelsSaved, i)
            array.set(dnHits, i, array.get(dnHits, i) + 1)
            array.set(dnMoveSum, i, array.get(dnMoveSum, i) + math.max(lvl - sessionLow, 0.0))

        array.set(upTouched, i, false)
        array.set(dnTouched, i, false)

if newSession
    sessionBars := 0
    sessionStart := bar_index
    sessionOpen := open
    sessionHigh := high
    sessionLow := low
    openingHigh := high
    openingLow := low
    sessionCumPV := 0.0
    sessionCumVol := 0.0

if inSession
    sessionBars += 1
    sessionHigh := na(sessionHigh) ? high : math.max(sessionHigh, high)
    sessionLow := na(sessionLow) ? low : math.min(sessionLow, low)
    sessionCumPV += hlc3 * volume
    sessionCumVol += volume
    if sessionBars <= openingBars
        openingHigh := na(openingHigh) ? high : math.max(openingHigh, high)
        openingLow := na(openingLow) ? low : math.min(openingLow, low)

float sessionVwap = sessionCumVol > 0.0 ? sessionCumPV / sessionCumVol : na
float vwapDistance = not na(sessionVwap) and atr > 0.0 ? f_clamp((close - sessionVwap) / atr, -2.0, 2.0) : 0.0
color vwapGradient = color.from_gradient(vwapDistance, -2.0, 2.0, colBearStrong, colBullStrong)

float openingRange = not na(openingHigh) and not na(openingLow) ? math.max(openingHigh - openingLow, syminfo.mintick) : syminfo.mintick
float sessionRange = not na(sessionHigh) and not na(sessionLow) ? math.max(sessionHigh - sessionLow, syminfo.mintick) : syminfo.mintick
float ladderBase = sessionBars >= openingBars ? openingRange : math.max(sessionRange, syminfo.mintick)

float up1 = sessionOpen + ladderBase * stepOne
float up2 = sessionOpen + ladderBase * stepTwo
float up3 = sessionOpen + ladderBase * stepThree
float up4 = sessionOpen + ladderBase * stepFour
float up5 = sessionOpen + ladderBase * stepFive
float up6 = sessionOpen + ladderBase * stepSix

float dn1 = sessionOpen - ladderBase * stepOne
float dn2 = sessionOpen - ladderBase * stepTwo
float dn3 = sessionOpen - ladderBase * stepThree
float dn4 = sessionOpen - ladderBase * stepFour
float dn5 = sessionOpen - ladderBase * stepFive
float dn6 = sessionOpen - ladderBase * stepSix

if inSession
    array.set(upLevelsSaved, 0, up1)
    array.set(upLevelsSaved, 1, up2)
    array.set(upLevelsSaved, 2, up3)
    array.set(upLevelsSaved, 3, up4)
    array.set(upLevelsSaved, 4, up5)
    array.set(upLevelsSaved, 5, up6)
    array.set(dnLevelsSaved, 0, dn1)
    array.set(dnLevelsSaved, 1, dn2)
    array.set(dnLevelsSaved, 2, dn3)
    array.set(dnLevelsSaved, 3, dn4)
    array.set(dnLevelsSaved, 4, dn5)
    array.set(dnLevelsSaved, 5, dn6)

    if barstate.isconfirmed
        if high >= up1
            array.set(upTouched, 0, true)
        if high >= up2
            array.set(upTouched, 1, true)
        if high >= up3
            array.set(upTouched, 2, true)
        if high >= up4
            array.set(upTouched, 3, true)
        if high >= up5
            array.set(upTouched, 4, true)
        if high >= up6
            array.set(upTouched, 5, true)

        if low <= dn1
            array.set(dnTouched, 0, true)
        if low <= dn2
            array.set(dnTouched, 1, true)
        if low <= dn3
            array.set(dnTouched, 2, true)
        if low <= dn4
            array.set(dnTouched, 3, true)
        if low <= dn5
            array.set(dnTouched, 4, true)
        if low <= dn6
            array.set(dnTouched, 5, true)

float upChance1 = f_prob(array.get(upHits, 0), array.get(upSamples, 0))
float upChance2 = f_prob(array.get(upHits, 1), array.get(upSamples, 1))
float upChance3 = f_prob(array.get(upHits, 2), array.get(upSamples, 2))
float upChance4 = f_prob(array.get(upHits, 3), array.get(upSamples, 3))
float upChance5 = f_prob(array.get(upHits, 4), array.get(upSamples, 4))
float upChance6 = f_prob(array.get(upHits, 5), array.get(upSamples, 5))

float dnChance1 = f_prob(array.get(dnHits, 0), array.get(dnSamples, 0))
float dnChance2 = f_prob(array.get(dnHits, 1), array.get(dnSamples, 1))
float dnChance3 = f_prob(array.get(dnHits, 2), array.get(dnSamples, 2))
float dnChance4 = f_prob(array.get(dnHits, 3), array.get(dnSamples, 3))
float dnChance5 = f_prob(array.get(dnHits, 4), array.get(dnSamples, 4))
float dnChance6 = f_prob(array.get(dnHits, 5), array.get(dnSamples, 5))

float upExp4 = f_expected(array.get(upMoveSum, 3), array.get(upHits, 3))
float dnExp4 = f_expected(array.get(dnMoveSum, 3), array.get(dnHits, 3))

// ============================================================================
// Auction state engine
// ============================================================================
float anomalyRaw = atr > 0.0 ? sessionRange / atr : 0.0
float anomalyScore = f_clamp(anomalyRaw / 1.75, 0.0, 2.0)
bool aboveOpen = close > sessionOpen
bool belowOpen = close < sessionOpen
bool upsideExpansion = barstate.isconfirmed and inSession and close > up4 and close[1] <= up4 and upChance4 >= probabilityGate
bool downsideExpansion = barstate.isconfirmed and inSession and close < dn4 and close[1] >= dn4 and dnChance4 >= probabilityGate
bool upsideExhaustion = barstate.isconfirmed and inSession and high >= up6 and close < up5 and anomalyScore > 1.0
bool downsideExhaustion = barstate.isconfirmed and inSession and low <= dn6 and close > dn5 and anomalyScore > 1.0

// ============================================================================
// Ladder plots with probability gradients
// ============================================================================
plot(showSessionVwap and inSession ? sessionVwap : na, "Session VWAP Glow", color=color.new(vwapGradient, 82), linewidth=7, style=plot.style_linebr)
plot(showSessionVwap and inSession ? sessionVwap : na, "Session VWAP", color=vwapGradient, linewidth=2, style=plot.style_linebr)
plot(inSession ? sessionOpen : na, "Session Open", color=colControl, linewidth=2, style=plot.style_linebr)
plot(showLadders and inSession ? up1 : na, "U25", color=color.from_gradient(upChance1, 0.0, 1.0, colNeutral, colBullStrong), linewidth=1, style=plot.style_linebr)
plot(showLadders and inSession ? up2 : na, "U50", color=color.from_gradient(upChance2, 0.0, 1.0, colNeutral, colBullStrong), linewidth=1, style=plot.style_linebr)
plot(showLadders and inSession ? up3 : na, "U75", color=color.from_gradient(upChance3, 0.0, 1.0, colNeutral, colBullStrong), linewidth=1, style=plot.style_linebr)
plot(showLadders and inSession ? up4 : na, "U100", color=color.from_gradient(upChance4, 0.0, 1.0, colNeutral, colBullStrong), linewidth=2, style=plot.style_linebr)
plot(showLadders and inSession ? up5 : na, "U125", color=color.from_gradient(upChance5, 0.0, 1.0, colNeutral, colBullStrong), linewidth=1, style=plot.style_linebr)
plot(showLadders and inSession ? up6 : na, "U150", color=color.from_gradient(upChance6, 0.0, 1.0, colNeutral, colBullStrong), linewidth=1, style=plot.style_linebr)

plot(showLadders and inSession ? dn1 : na, "D25", color=color.from_gradient(dnChance1, 0.0, 1.0, colNeutral, colBearStrong), linewidth=1, style=plot.style_linebr)
plot(showLadders and inSession ? dn2 : na, "D50", color=color.from_gradient(dnChance2, 0.0, 1.0, colNeutral, colBearStrong), linewidth=1, style=plot.style_linebr)
plot(showLadders and inSession ? dn3 : na, "D75", color=color.from_gradient(dnChance3, 0.0, 1.0, colNeutral, colBearStrong), linewidth=1, style=plot.style_linebr)
plot(showLadders and inSession ? dn4 : na, "D100", color=color.from_gradient(dnChance4, 0.0, 1.0, colNeutral, colBearStrong), linewidth=2, style=plot.style_linebr)
plot(showLadders and inSession ? dn5 : na, "D125", color=color.from_gradient(dnChance5, 0.0, 1.0, colNeutral, colBearStrong), linewidth=1, style=plot.style_linebr)
plot(showLadders and inSession ? dn6 : na, "D150", color=color.from_gradient(dnChance6, 0.0, 1.0, colNeutral, colBearStrong), linewidth=1, style=plot.style_linebr)

// Normal vs unusual auction shading.
color auctionBg = na
auctionBg := inSession and close > up6 ? color.new(colBearStrong, 92) : inSession and close < dn6 ? color.new(colBullStrong, 92) : inSession and close > up4 ? color.new(colBear, 94) : inSession and close < dn4 ? color.new(colBull, 94) : na
bgcolor(auctionBg)

color candleColor = na
float candleStrength = f_clamp(math.abs(vwapDistance) / 2.0 + anomalyScore * 0.12, 0.0, 1.0)
bool aboveVwap = not na(sessionVwap) and close >= sessionVwap
bool belowVwap = not na(sessionVwap) and close < sessionVwap
color bullBlend = color.from_gradient(candleStrength, 0.0, 1.0, colBull, colBullStrong)
color bearBlend = color.from_gradient(candleStrength, 0.0, 1.0, colBear, colBearStrong)
candleColor := colorCandles and upsideExpansion ? color.new(colBullStrong, 0) : colorCandles and downsideExpansion ? color.new(colBearStrong, 0) : colorCandles and upsideExhaustion ? color.new(colBearStrong, 8) : colorCandles and downsideExhaustion ? color.new(colBullStrong, 8) : colorCandles and aboveVwap ? color.new(bullBlend, 18) : colorCandles and belowVwap ? color.new(bearBlend, 18) : colorCandles and aboveOpen ? color.new(colBull, 45) : colorCandles and belowOpen ? color.new(colBear, 45) : na
barcolor(barstate.isconfirmed ? candleColor : na)

// ============================================================================
// Session/opening boxes
// ============================================================================
var box sessionBox = na
var box openingBox = na

if newSession
    if not na(sessionBox)
        box.delete(sessionBox)
    if not na(openingBox)
        box.delete(openingBox)
    if showSessionBox
        sessionBox := box.new(sessionStart, sessionHigh, bar_index, sessionLow, xloc=xloc.bar_index, bgcolor=color.new(colHud, 88), border_color=color.new(colViolet, 55))
    if showOpeningBox
        openingBox := box.new(sessionStart, openingHigh, bar_index, openingLow, xloc=xloc.bar_index, bgcolor=color.new(colControl, 90), border_color=color.new(colControl, 35))

if inSession and not na(sessionBox)
    box.set_right(sessionBox, bar_index)
    box.set_top(sessionBox, sessionHigh)
    box.set_bottom(sessionBox, sessionLow)
    box.set_bgcolor(sessionBox, anomalyScore > 1.10 ? color.new(colBearStrong, 90) : anomalyScore > 0.80 ? color.new(colControl, 92) : color.new(colHud, 88))
    box.set_border_color(sessionBox, anomalyScore > 1.10 ? color.new(colBearStrong, 35) : color.new(colViolet, 55))

if inSession and not na(openingBox)
    box.set_right(openingBox, math.min(bar_index, sessionStart + openingBars))
    box.set_top(openingBox, openingHigh)
    box.set_bottom(openingBox, openingLow)

// ============================================================================
// Managed auction state and probability card objects
// ============================================================================
var box[] stateBoxes = array.new_box()
var label[] stateLabels = array.new_label()
var box[] probabilityBoxes = array.new_box()
var label[] probabilityLabels = array.new_label()

if upsideExpansion and showAuctionStates
    array.push(stateBoxes, box.new(bar_index, up5, bar_index + projectionBars, up4, xloc=xloc.bar_index, bgcolor=color.new(colBullStrong, 86), border_color=color.new(colBullStrong, 18)))
    array.push(stateLabels, label.new(bar_index + projectionBars, up4, "SPG UPSIDE\nP " + str.tostring(upChance4 * 100.0, "#.0") + "%\nExp " + str.tostring(upExp4, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(colBull, 10), size=size.small))

if downsideExpansion and showAuctionStates
    array.push(stateBoxes, box.new(bar_index, dn4, bar_index + projectionBars, dn5, xloc=xloc.bar_index, bgcolor=color.new(colBearStrong, 86), border_color=color.new(colBearStrong, 18)))
    array.push(stateLabels, label.new(bar_index + projectionBars, dn4, "SPG DOWNSIDE\nP " + str.tostring(dnChance4 * 100.0, "#.0") + "%\nExp " + str.tostring(dnExp4, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(colBear, 10), size=size.small))

if upsideExhaustion and showAuctionStates
    array.push(stateBoxes, box.new(bar_index, high, bar_index + projectionBars, up5, xloc=xloc.bar_index, bgcolor=color.new(colBearStrong, 88), border_color=color.new(colBearStrong, 22)))
    array.push(stateLabels, label.new(bar_index + projectionBars, up5, "SPG FADE\nUpper anomaly", xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(colBearStrong, 12), size=size.small))

if downsideExhaustion and showAuctionStates
    array.push(stateBoxes, box.new(bar_index, dn5, bar_index + projectionBars, low, xloc=xloc.bar_index, bgcolor=color.new(colBullStrong, 88), border_color=color.new(colBullStrong, 22)))
    array.push(stateLabels, label.new(bar_index + projectionBars, dn5, "SPG FADE\nLower anomaly", xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(colBullStrong, 12), size=size.small))

f_trim_boxes(stateBoxes, 16)
f_trim_labels(stateLabels, 16)

if barstate.islast
    f_clear_boxes(probabilityBoxes)
    f_clear_labels(probabilityLabels)
    if showProbabilityCards and inSession
        int cardLeft = bar_index + 10
        int cardRight = bar_index + 17
        float[] levels = array.from(up6, up5, up4, up3, up2, up1, dn1, dn2, dn3, dn4, dn5, dn6)
        float[] probs = array.from(upChance6, upChance5, upChance4, upChance3, upChance2, upChance1, dnChance1, dnChance2, dnChance3, dnChance4, dnChance5, dnChance6)
        for i = 0 to array.size(levels) - 1
            float level = array.get(levels, i)
            float prob = array.get(probs, i)
            bool isUp = i < 6
            float cardTop = level + ladderBase * 0.035
            float cardBot = level - ladderBase * 0.035
            color base = isUp ? color.from_gradient(prob, 0.0, 1.0, colNeutral, colBullStrong) : color.from_gradient(prob, 0.0, 1.0, colNeutral, colBearStrong)
            int alpha = int(f_clamp(93.0 - prob * 42.0, 40.0, 93.0))
            array.push(probabilityBoxes, box.new(cardLeft, cardTop, cardRight, cardBot, xloc=xloc.bar_index, bgcolor=color.new(base, alpha), border_color=color.new(base, 30)))
            if i == 2 or i == 3 or i == 8 or i == 9
                string txt = (isUp ? "U" : "D") + str.tostring(isUp ? 6 - i : i - 5) + " " + str.tostring(prob * 100.0, "#.0") + "%"
                array.push(probabilityLabels, label.new(cardRight, level, txt, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(colHud, 10), size=size.tiny))

// ============================================================================
// Dashboard and alerts
// ============================================================================
if showDashboard and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, border_width=1, frame_color=color.new(colNeutral, 65), frame_width=1)
    string sessionState = upsideExpansion ? "Upside Expansion" : downsideExpansion ? "Downside Expansion" : upsideExhaustion ? "Upper Exhaustion" : downsideExhaustion ? "Lower Exhaustion" : aboveOpen ? "Above Open" : belowOpen ? "Below Open" : "Balanced"
    color stateColor = upsideExpansion ? colBullStrong : downsideExpansion ? colBearStrong : upsideExhaustion ? colBearStrong : downsideExhaustion ? colBullStrong : aboveOpen ? colBull : belowOpen ? colBear : colNeutral
    table.cell(dash, 0, 0, "Session Grid", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 0, sessionState, text_color=stateColor, bgcolor=colHudSoft)
    table.cell(dash, 0, 1, "Open", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 1, str.tostring(sessionOpen, format.mintick), text_color=colControl, bgcolor=colHudSoft)
    table.cell(dash, 0, 2, "OR Range", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 2, str.tostring(openingRange, format.mintick), text_color=colViolet, bgcolor=colHudSoft)
    table.cell(dash, 0, 3, "Sess Range", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 3, str.tostring(sessionRange, format.mintick), text_color=colViolet, bgcolor=colHudSoft)
    table.cell(dash, 0, 4, "Anomaly", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 4, str.tostring(anomalyRaw, "#.00") + " ATR", text_color=anomalyScore > 1.0 ? colBearStrong : colBullStrong, bgcolor=colHudSoft)
    table.cell(dash, 0, 5, "U100 / D100", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 5, str.tostring(upChance4 * 100.0, "#.0") + "% / " + str.tostring(dnChance4 * 100.0, "#.0") + "%", text_color=colControl, bgcolor=colHudSoft)
    table.cell(dash, 0, 6, "Exp Move", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 6, str.tostring(upExp4, format.mintick) + " / " + str.tostring(dnExp4, format.mintick), text_color=colControl, bgcolor=colHudSoft)
    table.cell(dash, 0, 7, "VWAP", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 7, str.tostring(sessionVwap, format.mintick), text_color=vwapGradient, bgcolor=colHudSoft)
    table.cell(dash, 0, 8, "Samples", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 8, str.tostring(array.get(upSamples, 3)) + " / " + str.tostring(array.get(dnSamples, 3)), text_color=colNeutral, bgcolor=colHudSoft)

alertcondition(upsideExpansion, "SPG Upside Expansion [JOAT]", "Session Probability Grid [JOAT]: close-confirmed upside expansion.")
alertcondition(downsideExpansion, "SPG Downside Expansion [JOAT]", "Session Probability Grid [JOAT]: close-confirmed downside expansion.")
alertcondition(upsideExhaustion, "SPG Upper Exhaustion [JOAT]", "Session Probability Grid [JOAT]: upper anomaly exhaustion state.")
alertcondition(downsideExhaustion, "SPG Lower Exhaustion [JOAT]", "Session Probability Grid [JOAT]: lower anomaly exhaustion state.")
````
