<!-- tradingview-pine-id: PUB;e7de0e5aa66f4549b5bb3a55ca6779ba -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Relative Volume Breakout Context [Pineify]

Source: https://www.tradingview.com/script/CwRbjtih-Relative-Volume-Breakout-Context-Pineify/

## Description

Relative Volume Breakout Context [Pineify]

Overview
Relative Volume Breakout Context tests an intraday price escape against normal volume at the same exchange-session position, then tracks price acceptance as participation changes.

Problem Definition
Intraday volume has a time-of-day shape: opening, midday and closing bars do not share one natural activity level. A rolling average mixes those positions, making routine opening activity look exceptional or meaningful midday volume look ordinary. A fixed channel break adds price displacement but not time-adjusted participation. A one-bar marker also loses whether price later holds its boundary on sustained or fading volume.

Design Rationale
Each bar is assigned a slot by elapsed minutes from a session start, and volume is compared only with prior observations from that slot. Exponentially weighted statistics let old sessions lose influence, trading stability for responsiveness. A dispersion floor controls unstable Z scores. Price must close beyond a prior range by a minimum ATR fraction. The joint score uses a geometric mean so weak price or volume constrains the result; an additive score could hide that weakness. Freezing the crossed rail adds state, but preserves an auditable acceptance boundary after confirmation.

Key Features

[*]Prior-only same-position volume expectation with sample reliability and a dispersion floor.
[*]ATR-normalized breakout joined with volume surprise in one qualified event.
[*]Frozen acceptance zone, one-shot decay alert, bounded labels and dashboard.

How It Works
Exchange-local bar time becomes elapsed session minutes. On 1-30 minute charts, elapsed time divided by chart interval selects one of 1,440 slots. Each stores a count, exponential volume mean and variance. The current bar reads them before updating, preventing self-inclusion.

After enough samples, dispersion is the larger of observed deviation and a percentage of expected volume. Volume Z is current minus expected volume divided by dispersion, capped at plus or minus five. Relative volume is the current/expected ratio; reliability rises with sample count.

Price rails are the highest high and lowest low of preceding bars. A fresh event closes beyond a rail, exceeds minimum ATR distance and meets volume Z. Volume and distance form a reliability-scaled geometric score with directional sign.

Confirmation freezes the rail. The frontier keeps the greatest high or lowest low while price remains outside. Z falling to the decay threshold creates one thinning alert. Closing through the rail invalidates tracking; age can expire it. Transitions require a completed bar.

How Multiple Indicators Work Together
Slot normalization asks whether participation is unusual now; the prior range asks whether price left an observed boundary; ATR standardizes escape depth; reliability limits warm-up confidence; memory tests later acceptance. Without volume this is a routine breakout, without price it is only RVOL, and without memory it cannot distinguish sustained support from thinning participation.

Trading Ideas and Insights
Treat confirmation as context, not an order. A green or red zone shows accepted extension from the frozen boundary. Amber means price still holds outside while same-position participation has decayed. That can frame questions about consolidation, fragility or absorption, but does not predict failure. Compare events with one instrument, session template and interval.

Unique Aspects
Common RVOL blends unrelated day parts, while common breakout tools stop at the crossing. Here, prior-only per-slot statistics feed a frozen-boundary state. Initiation requires time-adjusted participation and volatility-scaled displacement; continuation separates price acceptance from volume support. The thinning state remains descriptive rather than claiming lower follow-through volume causes reversal.

How to Use
Match session start and length to the regular exchange session and use a standard 1-30 minute chart. Let each slot collect the minimum samples; the dashboard shows WARMING before readiness. Faint lines are candidate rails. A diamond and RVOL label mark confirmation; the band spans frozen rail to frontier. Pane Z explains volume and signed score shows joint context. Set alerts to Once Per Bar Close.

Customization
Short memory adapts faster but is noisier; long memory is steadier but lags change. Minimum samples trades availability for depth. Raise the dispersion floor when quiet history overreacts. Range length and ATR distance control price selectivity; volume Z controls participation. Decay Z sets cooling and event age bounds observation.

Assumptions and Limitations
Bars must align with the configured exchange-local session. Holidays, half days, halts, extended-hours mixing and template errors reduce comparability. Bars use opening minute and may span session end. Missing volume disables scoring; tick volume is not centralized traded volume. Exponential statistics are path-dependent, capped Z is not probability, and ATR or rails lag. The script does not infer order intent, fills, profitability or next direction. Feed revisions and parameters can alter history. Values move intrabar; transitions and alerts commit at close.

Conclusion
This indicator replaces mixed-time RVOL with a session-position benchmark and extends a qualified breakout into an acceptance path. It reports escape, participation and thinning as context, not a forecast.

---

## Source Code

````pine
//@version=6
indicator("Relative Volume Breakout Context [Pineify]", shorttitle="RV Breakout [Pineify]", overlay=false, max_labels_count=100)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
string GROUP_SESSION = "Exchange session model"
string GROUP_BASELINE = "Same-position volume baseline"
string GROUP_BREAKOUT = "Breakout context"
string GROUP_VISUALS = "Visual system"

sessionStartHour = input.int(9, "Session start hour", minval=0, maxval=23, group=GROUP_SESSION, tooltip="Hour in the symbol exchange timezone.")
sessionStartMinute = input.int(30, "Session start minute", minval=0, maxval=59, group=GROUP_SESSION, tooltip="Minute in the symbol exchange timezone.")
sessionLength = input.int(390, "Session length (minutes)", minval=30, maxval=1440, group=GROUP_SESSION)

memorySessions = input.int(30, "Baseline memory (sessions)", minval=5, maxval=120, group=GROUP_BASELINE, tooltip="Controls the exponential memory of each same-position volume baseline.")
minimumSamples = input.int(10, "Minimum prior samples", minval=3, maxval=60, group=GROUP_BASELINE)
dispersionFloorPct = input.float(10.0, "Dispersion floor (% of mean)", minval=1.0, maxval=100.0, step=1.0, group=GROUP_BASELINE, tooltip="Prevents a nearly constant volume history from producing unstable Z scores.")
volumeZThreshold = input.float(1.5, "Breakout volume Z threshold", minval=0.25, maxval=5.0, step=0.05, group=GROUP_BASELINE)
decayZThreshold = input.float(0.0, "Post-breakout decay Z threshold", minval=-3.0, maxval=3.0, step=0.1, group=GROUP_BASELINE)

breakoutLength = input.int(30, "Prior price range bars", minval=5, maxval=300, group=GROUP_BREAKOUT)
atrLength = input.int(14, "ATR length", minval=2, maxval=100, group=GROUP_BREAKOUT)
minimumBreakAtr = input.float(0.10, "Minimum close beyond range (ATR)", minval=0.0, maxval=3.0, step=0.05, group=GROUP_BREAKOUT)
trackingBars = input.int(12, "Event tracking bars", minval=2, maxval=100, group=GROUP_BREAKOUT)

showScorePane = input.bool(true, "Show context score", group=GROUP_VISUALS)
showVolumeZ = input.bool(true, "Show relative-volume Z score", group=GROUP_VISUALS)
showCandidateRails = input.bool(true, "Show prior breakout rails", group=GROUP_VISUALS)
showStateWash = input.bool(true, "Show tracked-state wash", group=GROUP_VISUALS)
showEventLabels = input.bool(true, "Show confirmed event labels", group=GROUP_VISUALS)
showDashboard = input.bool(true, "Show context dashboard", group=GROUP_VISUALS)
maximumLabels = input.int(30, "Maximum event labels", minval=5, maxval=100, group=GROUP_VISUALS)

bullColor = input.color(color.rgb(16, 185, 129), "Bullish acceptance", group=GROUP_VISUALS)
bearColor = input.color(color.rgb(239, 92, 118), "Bearish acceptance", group=GROUP_VISUALS)
decayColor = input.color(color.rgb(245, 158, 11), "Participation decay", group=GROUP_VISUALS)
volumeColor = input.color(color.rgb(56, 189, 248), "Relative volume", group=GROUP_VISUALS)
neutralColor = input.color(color.rgb(148, 163, 184), "Neutral / warming", group=GROUP_VISUALS)

//------------------------------------------------------------------------------
// Helpers and bounded same-position storage
//------------------------------------------------------------------------------
int MAX_SESSION_SLOTS = 1440
var array<int> slotCounts = array.new_int(MAX_SESSION_SLOTS, 0)
var array<float> slotMeans = array.new_float(MAX_SESSION_SLOTS, 0.0)
var array<float> slotVariances = array.new_float(MAX_SESSION_SLOTS, 0.0)
var array<label> eventLabels = array.new<label>()

f_clamp(float value, float lower, float upper) =>
    math.min(math.max(value, lower), upper)

f_update_slot(int index, float observation) =>
    int oldCount = array.get(slotCounts, index)
    float oldMean = array.get(slotMeans, index)
    float oldVariance = array.get(slotVariances, index)
    float alpha = oldCount < memorySessions ? 1.0 / float(oldCount + 1) : 2.0 / float(memorySessions + 1)
    float delta = observation - oldMean
    float nextMean = oldCount == 0 ? observation : oldMean + alpha * delta
    float nextVariance = oldCount == 0 ? 0.0 : (1.0 - alpha) * (oldVariance + alpha * delta * delta)
    array.set(slotCounts, index, math.min(oldCount + 1, 1000000))
    array.set(slotMeans, index, nextMean)
    array.set(slotVariances, index, math.max(nextVariance, 0.0))

f_push_label(label eventLabel) =>
    array.push(eventLabels, eventLabel)
    if array.size(eventLabels) > maximumLabels
        label.delete(array.shift(eventLabels))

//------------------------------------------------------------------------------
// Exchange-time session position and prior-only volume expectation
//------------------------------------------------------------------------------
float chartMinutes = float(timeframe.in_seconds()) / 60.0
bool validTimeframe = timeframe.isintraday and chartMinutes >= 1.0 and chartMinutes <= 30.0 and math.abs(chartMinutes - math.round(chartMinutes)) < 0.001
int minuteOfDay = hour(time, syminfo.timezone) * 60 + minute(time, syminfo.timezone)
int sessionStartMinuteOfDay = sessionStartHour * 60 + sessionStartMinute
int elapsedMinute = (minuteOfDay - sessionStartMinuteOfDay + 1440) % 1440
bool inSession = validTimeframe and elapsedMinute < sessionLength
int slotIndex = inSession ? int(math.floor(float(elapsedMinute) / chartMinutes)) : na
bool validSlot = inSession and slotIndex >= 0 and slotIndex < MAX_SESSION_SLOTS
bool volumeValid = validSlot and not na(volume) and volume >= 0.0

int slotSamples = validSlot ? array.get(slotCounts, slotIndex) : 0
float expectedVolume = validSlot and slotSamples > 0 ? array.get(slotMeans, slotIndex) : na
float rawDispersion = validSlot and slotSamples > 1 ? math.sqrt(array.get(slotVariances, slotIndex)) : na
float dispersionFloor = not na(expectedVolume) ? expectedVolume * dispersionFloorPct * 0.01 : na
float effectiveDispersion = not na(rawDispersion) and not na(dispersionFloor) ? math.max(rawDispersion, dispersionFloor) : na
bool baselineReady = volumeValid and slotSamples >= minimumSamples and expectedVolume > 0.0 and effectiveDispersion > 0.0
float volumeZ = baselineReady ? f_clamp((volume - expectedVolume) / effectiveDispersion, -5.0, 5.0) : na
float relativeVolume = baselineReady ? volume / expectedVolume : na
float reliability = baselineReady ? f_clamp(float(slotSamples) / float(minimumSamples * 2), 0.0, 1.0) : 0.0

//------------------------------------------------------------------------------
// Prior range breakout and joint event qualification
//------------------------------------------------------------------------------
float upperRail = ta.highest(high, breakoutLength)[1]
float lowerRail = ta.lowest(low, breakoutLength)[1]
float atr = ta.atr(atrLength)
bool priceReady = not na(upperRail) and not na(lowerRail) and not na(atr) and atr > 0.0
bool bullOutside = priceReady and close > upperRail
bool bearOutside = priceReady and close < lowerRail
bool freshBullBreak = bullOutside and close[1] <= upperRail
bool freshBearBreak = bearOutside and close[1] >= lowerRail
float bullDistanceAtr = bullOutside ? (close - upperRail) / atr : 0.0
float bearDistanceAtr = bearOutside ? (lowerRail - close) / atr : 0.0
float signedBreakDistanceAtr = bullOutside ? bullDistanceAtr : bearOutside ? -bearDistanceAtr : 0.0

float volumeComponent = baselineReady ? f_clamp(math.max(volumeZ, 0.0) / math.max(volumeZThreshold, 0.01), 0.0, 2.0) * 50.0 : 0.0
float distanceComponent = f_clamp(math.abs(signedBreakDistanceAtr) / math.max(minimumBreakAtr, 0.05), 0.0, 2.0) * 50.0
float jointMagnitude = math.sqrt(volumeComponent * distanceComponent) * reliability
float contextScore = bullOutside ? jointMagnitude : bearOutside ? -jointMagnitude : 0.0

//------------------------------------------------------------------------------
// Frozen-boundary acceptance state and participation decay
//------------------------------------------------------------------------------
var int activeDirection = 0
var int eventAge = 0
var float eventRail = na
var float eventFrontier = na
var bool decayLatched = false

bool confirmedBullEvent = barstate.isconfirmed and activeDirection == 0 and baselineReady and freshBullBreak and bullDistanceAtr >= minimumBreakAtr and volumeZ >= volumeZThreshold
bool confirmedBearEvent = barstate.isconfirmed and activeDirection == 0 and baselineReady and freshBearBreak and bearDistanceAtr >= minimumBreakAtr and volumeZ >= volumeZThreshold
bool confirmedBreakoutEvent = confirmedBullEvent or confirmedBearEvent
bool confirmedDecayEvent = false
bool confirmedInvalidation = false

if barstate.isconfirmed
    if confirmedBreakoutEvent
        activeDirection := confirmedBullEvent ? 1 : -1
        eventAge := 0
        eventRail := confirmedBullEvent ? upperRail : lowerRail
        eventFrontier := confirmedBullEvent ? high : low
        decayLatched := false
    else if activeDirection != 0
        eventAge += 1
        eventFrontier := activeDirection > 0 ? math.max(eventFrontier, high) : math.min(eventFrontier, low)
        bool stillAccepted = activeDirection > 0 ? close > eventRail : close < eventRail
        bool expired = eventAge > trackingBars
        bool participationDecayed = baselineReady and volumeZ <= decayZThreshold
        if not stillAccepted or expired
            confirmedInvalidation := not stillAccepted
            activeDirection := 0
            eventAge := 0
            eventRail := na
            eventFrontier := na
            decayLatched := false
        else if participationDecayed and not decayLatched
            confirmedDecayEvent := true
            decayLatched := true

bool activeAccepted = activeDirection != 0 and (activeDirection > 0 ? close > eventRail : close < eventRail)
bool activeDecay = activeAccepted and baselineReady and volumeZ <= decayZThreshold
color directionColor = activeDirection > 0 ? bullColor : activeDirection < 0 ? bearColor : neutralColor
color activeStateColor = activeDecay ? decayColor : directionColor
string activeState = not validTimeframe ? "USE 1m-30m" : not inSession ? "OUTSIDE SESSION" : not volumeValid ? "VOLUME MISSING" : not baselineReady ? "WARMING" : activeDirection == 0 ? "WATCHING" : activeDecay ? "THINNING" : "ACCEPTING"

// Update the selected slot only after all current-bar comparisons are complete.
if barstate.isconfirmed and volumeValid
    f_update_slot(slotIndex, volume)

//------------------------------------------------------------------------------
// Visual system: frozen price acceptance zone plus optional diagnostic pane
//------------------------------------------------------------------------------
candidateUpperPlot = plot(showCandidateRails and priceReady ? upperRail : na, "Prior Upper Rail", color=color.new(neutralColor, 62), linewidth=1, style=plot.style_stepline, force_overlay=true)
candidateLowerPlot = plot(showCandidateRails and priceReady ? lowerRail : na, "Prior Lower Rail", color=color.new(neutralColor, 62), linewidth=1, style=plot.style_stepline, force_overlay=true)
eventRailPlot = plot(activeDirection != 0 ? eventRail : na, "Frozen Event Rail", color=activeStateColor, linewidth=2, style=plot.style_stepline, force_overlay=true)
eventFrontierPlot = plot(activeDirection != 0 ? eventFrontier : na, "Accepted Frontier", color=color.new(activeStateColor, 12), linewidth=2, style=plot.style_stepline, force_overlay=true)
fill(eventRailPlot, eventFrontierPlot, color=activeDirection != 0 ? color.new(activeStateColor, activeDecay ? 84 : 88) : na, title="Breakout Acceptance Zone")

plotshape(confirmedBullEvent ? low : na, title="Confirmed Bullish RVOL Breakout", style=shape.diamond, location=location.absolute, color=bullColor, size=size.small, force_overlay=true)
plotshape(confirmedBearEvent ? high : na, title="Confirmed Bearish RVOL Breakout", style=shape.diamond, location=location.absolute, color=bearColor, size=size.small, force_overlay=true)
plotshape(confirmedDecayEvent ? (activeDirection > 0 ? low : high) : na, title="Confirmed Participation Decay", style=shape.circle, location=location.absolute, color=decayColor, size=size.tiny, force_overlay=true)
plotshape(confirmedInvalidation ? close : na, title="Acceptance Invalidated", style=shape.xcross, location=location.absolute, color=neutralColor, size=size.tiny, force_overlay=true)

if showEventLabels and confirmedBreakoutEvent
    string eventText = "RVOL " + str.tostring(relativeVolume, "#.00") + "x\nZ " + str.tostring(volumeZ, "#.00")
    label eventLabel = label.new(x=bar_index, y=confirmedBullEvent ? low : high, text=eventText, xloc=xloc.bar_index, yloc=yloc.price, style=confirmedBullEvent ? label.style_label_up : label.style_label_down, color=color.new(confirmedBullEvent ? bullColor : bearColor, 8), textcolor=color.white, size=size.tiny, force_overlay=true)
    f_push_label(eventLabel)

hline(0.0, "Neutral axis", color=color.new(neutralColor, 68), linestyle=hline.style_dotted)
hline(volumeZThreshold, "Volume confirmation threshold", color=color.new(volumeColor, 55), linestyle=hline.style_dashed)
hline(decayZThreshold, "Volume decay threshold", color=color.new(decayColor, 65), linestyle=hline.style_dotted)
plot(showVolumeZ ? volumeZ : na, "Same-Position Volume Z", color=volumeZ >= volumeZThreshold ? volumeColor : color.new(volumeColor, 38), linewidth=2, style=plot.style_histogram)
plot(showScorePane ? contextScore : na, "Joint Breakout Context", color=contextScore > 0.0 ? bullColor : contextScore < 0.0 ? bearColor : neutralColor, linewidth=3)
bgcolor(showStateWash and activeDirection != 0 ? color.new(activeStateColor, 91) : na, title="Tracked State Wash")

//------------------------------------------------------------------------------
// Dashboard and confirmed alerts
//------------------------------------------------------------------------------
var table dashboard = table.new(position.top_right, 2, 8, border_width=1)
if barstate.islast
    if showDashboard
        color headerColor = activeDirection != 0 ? activeStateColor : neutralColor
        table.cell(dashboard, 0, 0, "RV BREAKOUT", text_color=color.white, bgcolor=color.rgb(34, 40, 52))
        table.cell(dashboard, 1, 0, activeState, text_color=color.white, bgcolor=color.new(headerColor, 18))
        table.cell(dashboard, 0, 1, "Exchange TZ", text_color=color.silver, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 1, 1, syminfo.timezone, text_color=color.white, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 0, 2, "Session slot", text_color=color.silver, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 1, 2, validSlot ? str.tostring(slotIndex + 1) : "n/a", text_color=color.white, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 0, 3, "Prior samples", text_color=color.silver, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 1, 3, validSlot ? str.tostring(slotSamples) : "n/a", text_color=baselineReady ? color.white : neutralColor, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 0, 4, "Expected vol", text_color=color.silver, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 1, 4, not na(expectedVolume) ? str.tostring(expectedVolume, format.volume) : "n/a", text_color=color.white, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 0, 5, "Relative vol", text_color=color.silver, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 1, 5, baselineReady ? str.tostring(relativeVolume, "#.00") + "x" : "n/a", text_color=volumeColor, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 0, 6, "Volume Z", text_color=color.silver, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 1, 6, baselineReady ? str.tostring(volumeZ, "#.00") : "n/a", text_color=volumeZ >= volumeZThreshold ? volumeColor : color.white, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 0, 7, "Event age", text_color=color.silver, bgcolor=color.new(color.black, 18))
        table.cell(dashboard, 1, 7, activeDirection != 0 ? str.tostring(eventAge) + " / " + str.tostring(trackingBars) : "n/a", text_color=activeDirection != 0 ? activeStateColor : neutralColor, bgcolor=color.new(color.black, 18))
    else
        table.clear(dashboard, 0, 0, 1, 7)

alertcondition(confirmedBreakoutEvent, "Confirmed time-adjusted volume breakout", "A completed bar closed beyond the prior range with same-position relative volume above the configured threshold.")
alertcondition(confirmedDecayEvent, "Confirmed post-breakout volume decay", "A tracked breakout remains beyond its frozen boundary, but same-position relative volume has decayed below the configured threshold.")
````
