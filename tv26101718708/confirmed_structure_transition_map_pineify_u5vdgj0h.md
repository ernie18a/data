# Confirmed Structure Transition Map [Pineify]

- url: https://www.tradingview.com/script/u5vdgj0h-Confirmed-Structure-Transition-Map-Pineify/
- type: indicator
- pine_id: PUB;07389c55c0ea4ed68cc8544a04ad6110
- version: 1.0

## Description

[b]Confirmed Structure Transition Map [Pineify][/b]

[b]Overview[/b]

This Pine Script v6 indicator separates confirmed swings, break-of-structure events, and direction candidates. A finite state appears as a stepped price corridor.

[b]Problem Definition[/b]

A common baseline finds fractal highs and lows, then labels any crossing BOS or CHoCH. It hides the pivot bar, the later confirmation bar, and the still later break. One level may emit repeated labels, while one counter-break may be called a reversal. Label density replaces a distinction between swing formation, continuation, and transition. This script separates those events and never triggers an earlier break with future information.

[b]Design Rationale[/b]

Confirmed pivots provide stable levels; a moving extreme has no fixed identity. Each high and low becomes a one-use rail. A break with the bias is BOS; the first qualified counter-break is only a potential CHoCH. Bias changes after a fresh rail breaks again in that direction. Crossing the frozen opposite rail or age limit cancels the candidate. This rejects immediate reversal on one counter-break. The tradeoff is lag for explicit evidence. ATR scaling filters tiny overruns but does not estimate probability.

[b]Key Features[/b]

[list]
[*]Optional confirmed HH, LH, HL, and LL labels.
[*]One-use rails that suppress duplicate breaks.
[*]BOS, potential CHoCH, shift, invalidation, and expiry states.
[*]ATR displacement, state corridor, alerts, and dashboard.
[/list]

[b]How It Works[/b]

The script reads chart OHLC and a symmetric pivot window. A pivot is accepted after its right-side bars close. Its price and index are stored, compared with the prior same-type pivot, and armed as a rail. If price already exceeded the required displacement when it became knowable, that rail is consumed without a hindsight event.

Each confirmed bar compares the Close or Wick probe with both rails. Distance beyond a rail is divided by ATR and must meet Minimum Break Displacement. On a two-sided outside bar, the larger normalized wick defines one event. The first event sets bias; a same-direction event is BOS. A counter-event freezes break rail, invalidation rail, displacement, and start bar. Confirmation needs a fresh rail and second break in the candidate direction. Invalidation or expiry ends the candidate. The corridor shows bullish, bearish, pending, or neutral state; early bars stay neutral.

[b]How Multiple Indicators Work Together[/b]

This is one dependent state model, not a mashup. Pivot confirmation supplies stable rails; otherwise levels move while tested. ATR displacement separates a tiny overrun from a range-scaled break. The ordered state machine consumes those qualified breaks; otherwise crossings remain a label stream. The corridor encodes the resulting state instead of adding an unrelated signal.

[b]Trading Ideas and Insights[/b]

Read BOS as evidence that price cleared a rail with the established bias, not as an entry command. Violet marks a candidate; amber shows why it ended. A wide corridor requires a larger absolute move. Apply separate risk, liquidity, and execution rules: the map does not select stops, size positions, or forecast events.

[b]Unique Aspects[/b]

The contribution is an ordered lifecycle. Rails arm only when knowable, each fires once, a counter-break stays provisional, and a second newly armed break is required before bias changes. Invalidation level and age limit freeze at candidate start, so later pivots cannot rewrite the test. One corridor carries bias and transition while labels, wash, bar colors, and table remain optional. This is more than a renamed fractal plot.

[b]How to Use[/b]

Begin with Close and default pivots, then check swing density for the market and timeframe. Read rails first: BOS continues state, P-CH opens a candidate, and SHIFT completes the two-break transition. HH/HL locations are revealed after the right-bar delay, not known on their historical bars. Use BOS and shift alerts only within an existing process.

[b]Customization[/b]

Pivot Left/Right Bars control granularity and delay: smaller values add noise; larger values add lag. Close requires settlement beyond a rail. Wick uses extremes and resolves outside bars by larger excursion. Minimum Break Displacement sets ATR clearance; Candidate Expiry limits age. Corridor, labels, wash, bar colors, and dashboard are independently configurable.

[b]Assumptions and Limitations[/b]

Pivots need future bars for confirmation, so markers appear on pivot bars only after the right-side delay; breaks and shifts remain on confirmation bars. Probes move live, but state and alerts require bar close. ATR and pivot settings are market-sensitive. Gaps can jump rails, Wick mode reduces an outside bar to one event, and chop can repeat candidates. The model reads chart prices, not order flow, news, higher timeframes, or execution quality. A shift is an ordered event, not a guaranteed reversal or profitable trade.

[b]Conclusion[/b]

The map turns delayed pivots and breaks into an auditable sequence: location, one-use break, provisional counter-break, then confirmation or invalidation. It provides structural context; interpretation and risk remain with the user.

## Source Code

````pine
//@version=6
indicator("Confirmed Structure Transition Map [Pineify]", overlay = true, max_labels_count = 200)

string groupStructure = "Confirmed Structure Engine"
int pivotLeft = input.int(5, "Pivot Left Bars", minval = 2, maxval = 20, group = groupStructure)
int pivotRight = input.int(5, "Pivot Right Bars", minval = 2, maxval = 20, group = groupStructure)
string breakMode = input.string("Close", "Break Confirmation", options = ["Close", "Wick"], group = groupStructure)
int atrLength = input.int(14, "Displacement ATR Length", minval = 2, maxval = 100, group = groupStructure)
float minimumBreakAtr = input.float(0.10, "Minimum Break Displacement (ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = groupStructure)
int maximumCandidateBars = input.int(120, "Potential Transition Expiry Bars", minval = 10, maxval = 500, group = groupStructure)

string groupVisual = "Visual System"
bool showCorridor = input.bool(true, "Show Structure Corridor", group = groupVisual)
bool showSwingLabels = input.bool(false, "Show Confirmed HH/HL Labels", group = groupVisual)
bool showEventLabels = input.bool(true, "Show BOS and Transition Labels", group = groupVisual)
bool showTransitionWash = input.bool(true, "Show Potential Transition Wash", group = groupVisual)
bool colorBars = input.bool(false, "Color Bars by Confirmed Bias", group = groupVisual)
bool showDashboard = input.bool(true, "Show Structure Dashboard", group = groupVisual)

color bullColor = color.rgb(8, 180, 190)
color bullBright = color.rgb(34, 211, 238)
color bearColor = color.rgb(225, 72, 112)
color bearBright = color.rgb(251, 113, 133)
color candidateColor = color.rgb(139, 92, 246)
color neutralColor = color.rgb(148, 163, 184)
color invalidColor = color.rgb(245, 158, 11)

float atr = ta.atr(atrLength)
float atrFloor = math.max(nz(atr), syminfo.mintick)
float breakUpProbe = breakMode == "Close" ? close : high
float breakDownProbe = breakMode == "Close" ? close : low
float confirmedHigh = ta.pivothigh(high, pivotLeft, pivotRight)
float confirmedLow = ta.pivotlow(low, pivotLeft, pivotRight)
bool newPivotHigh = barstate.isconfirmed and not na(confirmedHigh)
bool newPivotLow = barstate.isconfirmed and not na(confirmedLow)

var float structureHigh = na
var float structureLow = na
var int structureHighBar = na
var int structureLowBar = na
var bool highConsumed = true
var bool lowConsumed = true

var int structureBias = 0
var int pendingDirection = 0
var float pendingBreakLevel = na
var float pendingInvalidationLevel = na
var float pendingDisplacement = na
var int pendingStartBar = na
var string lastEventText = "WAITING"
var color lastEventColor = neutralColor

bool bullishBos = false
bool bearishBos = false
bool bullishPotentialTransition = false
bool bearishPotentialTransition = false
bool bullishTransitionConfirmed = false
bool bearishTransitionConfirmed = false
bool candidateInvalidated = false
bool candidateExpired = false

if newPivotHigh
    string highClass = na(structureHigh) ? "H" : confirmedHigh > structureHigh ? "HH" : confirmedHigh < structureHigh ? "LH" : "EH"
    structureHigh := confirmedHigh
    structureHighBar := bar_index - pivotRight
    float confirmationDisplacement = (breakUpProbe - confirmedHigh) / atrFloor
    highConsumed := breakUpProbe > confirmedHigh and confirmationDisplacement >= minimumBreakAtr
    if showSwingLabels
        label.new(structureHighBar, structureHigh, highClass, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(neutralColor, 38), textcolor = color.white, size = size.tiny)

if newPivotLow
    string lowClass = na(structureLow) ? "L" : confirmedLow > structureLow ? "HL" : confirmedLow < structureLow ? "LL" : "EL"
    structureLow := confirmedLow
    structureLowBar := bar_index - pivotRight
    float confirmationDisplacement = (confirmedLow - breakDownProbe) / atrFloor
    lowConsumed := breakDownProbe < confirmedLow and confirmationDisplacement >= minimumBreakAtr
    if showSwingLabels
        label.new(structureLowBar, structureLow, lowClass, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(neutralColor, 38), textcolor = color.white, size = size.tiny)

int candidateAgeBeforeEvent = pendingDirection != 0 and not na(pendingStartBar) ? bar_index - pendingStartBar : 0
bool invalidatedByPrice = barstate.isconfirmed and pendingDirection != 0 and not na(pendingInvalidationLevel) and (pendingDirection == 1 ? breakDownProbe < pendingInvalidationLevel : breakUpProbe > pendingInvalidationLevel)
bool invalidatedByTime = barstate.isconfirmed and pendingDirection != 0 and candidateAgeBeforeEvent > maximumCandidateBars

if invalidatedByPrice or invalidatedByTime
    candidateInvalidated := invalidatedByPrice
    candidateExpired := invalidatedByTime
    lastEventText := invalidatedByPrice ? "CANDIDATE INVALIDATED" : "CANDIDATE EXPIRED"
    lastEventColor := invalidColor
    pendingDirection := 0
    pendingBreakLevel := na
    pendingInvalidationLevel := na
    pendingDisplacement := na
    pendingStartBar := na

float upDisplacement = not na(structureHigh) ? (breakUpProbe - structureHigh) / atrFloor : na
float downDisplacement = not na(structureLow) ? (structureLow - breakDownProbe) / atrFloor : na
bool rawUpBreak = barstate.isconfirmed and not newPivotHigh and not highConsumed and not na(upDisplacement) and breakUpProbe > structureHigh and upDisplacement >= minimumBreakAtr
bool rawDownBreak = barstate.isconfirmed and not newPivotLow and not lowConsumed and not na(downDisplacement) and breakDownProbe < structureLow and downDisplacement >= minimumBreakAtr
int eventDirection = rawUpBreak and rawDownBreak ? (upDisplacement >= downDisplacement ? 1 : -1) : rawUpBreak ? 1 : rawDownBreak ? -1 : 0
float eventLevel = eventDirection == 1 ? structureHigh : eventDirection == -1 ? structureLow : na
float eventDisplacement = eventDirection == 1 ? upDisplacement : eventDirection == -1 ? downDisplacement : na

if eventDirection != 0
    if eventDirection == 1
        highConsumed := true
    else
        lowConsumed := true

    if structureBias == 0
        structureBias := eventDirection
        bullishBos := eventDirection == 1
        bearishBos := eventDirection == -1
        lastEventText := eventDirection == 1 ? "INITIAL BULLISH BOS" : "INITIAL BEARISH BOS"
        lastEventColor := eventDirection == 1 ? bullColor : bearColor
    else if eventDirection == structureBias
        bullishBos := eventDirection == 1
        bearishBos := eventDirection == -1
        lastEventText := eventDirection == 1 ? "BULLISH BOS" : "BEARISH BOS"
        lastEventColor := eventDirection == 1 ? bullColor : bearColor
        pendingDirection := 0
        pendingBreakLevel := na
        pendingInvalidationLevel := na
        pendingDisplacement := na
        pendingStartBar := na
    else if pendingDirection == eventDirection
        structureBias := eventDirection
        bullishTransitionConfirmed := eventDirection == 1
        bearishTransitionConfirmed := eventDirection == -1
        lastEventText := eventDirection == 1 ? "BULLISH SHIFT CONFIRMED" : "BEARISH SHIFT CONFIRMED"
        lastEventColor := eventDirection == 1 ? bullBright : bearBright
        pendingDirection := 0
        pendingBreakLevel := na
        pendingInvalidationLevel := na
        pendingDisplacement := na
        pendingStartBar := na
    else
        pendingDirection := eventDirection
        pendingBreakLevel := eventLevel
        pendingInvalidationLevel := eventDirection == 1 ? structureLow : structureHigh
        pendingDisplacement := eventDisplacement
        pendingStartBar := bar_index
        bullishPotentialTransition := eventDirection == 1
        bearishPotentialTransition := eventDirection == -1
        lastEventText := eventDirection == 1 ? "POTENTIAL BULLISH CHOCH" : "POTENTIAL BEARISH CHOCH"
        lastEventColor := candidateColor

if showEventLabels and eventDirection != 0
    string eventLabelText = bullishTransitionConfirmed or bearishTransitionConfirmed ? "SHIFT" : bullishPotentialTransition or bearishPotentialTransition ? "P-CH" : "BOS"
    color eventLabelColor = bullishTransitionConfirmed ? bullBright : bearishTransitionConfirmed ? bearBright : bullishPotentialTransition or bearishPotentialTransition ? candidateColor : eventDirection == 1 ? bullColor : bearColor
    label.new(bar_index, eventLevel, eventLabelText, xloc = xloc.bar_index, yloc = yloc.price, style = eventDirection == 1 ? label.style_label_up : label.style_label_down, color = color.new(eventLabelColor, 8), textcolor = color.white, size = size.tiny)

int pendingAge = pendingDirection != 0 and not na(pendingStartBar) ? bar_index - pendingStartBar : 0
color biasColor = structureBias == 1 ? bullColor : structureBias == -1 ? bearColor : neutralColor
color corridorColor = pendingDirection != 0 ? candidateColor : biasColor
int candidateTransparency = pendingDirection != 0 and not na(pendingDisplacement) ? int(math.max(78.0, 92.0 - math.min(pendingDisplacement, 2.0) * 6.0)) : 91

highRailPlot = plot(showCorridor ? structureHigh : na, "Confirmed Swing High Rail", color = color.new(pendingDirection == -1 ? candidateColor : bearBright, 24), linewidth = 2, style = plot.style_stepline)
lowRailPlot = plot(showCorridor ? structureLow : na, "Confirmed Swing Low Rail", color = color.new(pendingDirection == 1 ? candidateColor : bullBright, 24), linewidth = 2, style = plot.style_stepline)
fill(highRailPlot, lowRailPlot, color = showCorridor ? color.new(corridorColor, candidateTransparency) : na, title = "Confirmed Structure Corridor")
plot(showCorridor and pendingDirection != 0 ? pendingBreakLevel : na, "Potential Transition Break Rail", color = color.new(candidateColor, 18), linewidth = 3, style = plot.style_linebr)
plot(showCorridor and pendingDirection != 0 ? pendingInvalidationLevel : na, "Potential Transition Invalidation Rail", color = color.new(invalidColor, 30), linewidth = 1, style = plot.style_linebr)

bgcolor(showTransitionWash and pendingDirection != 0 ? color.new(candidateColor, 94) : na, title = "Potential Transition Wash")
barcolor(colorBars ? color.new(biasColor, pendingDirection != 0 ? 24 : 38) : na, title = "Confirmed Structure Bias Bar Color")
plotshape(showEventLabels and candidateInvalidated, title = "Transition Candidate Invalidated", style = shape.xcross, location = location.abovebar, color = invalidColor, size = size.tiny, text = "X")
plotshape(showEventLabels and candidateExpired, title = "Transition Candidate Expired", style = shape.circle, location = location.abovebar, color = invalidColor, size = size.tiny, text = "T")

string stateText = pendingDirection == 1 ? "BULLISH CANDIDATE" : pendingDirection == -1 ? "BEARISH CANDIDATE" : structureBias == 1 ? "CONFIRMED BULL" : structureBias == -1 ? "CONFIRMED BEAR" : "NEUTRAL"
string highRailText = not na(structureHigh) ? str.tostring(structureHigh, format.mintick) : "NA"
string lowRailText = not na(structureLow) ? str.tostring(structureLow, format.mintick) : "NA"
string candidateAgeText = pendingDirection != 0 ? str.tostring(pendingAge) + " / " + str.tostring(maximumCandidateBars) : "NA"
string displacementText = pendingDirection != 0 and not na(pendingDisplacement) ? str.tostring(pendingDisplacement, "#.00") + " ATR" : "NA"

var table dashboard = table.new(position.top_right, 2, 6, frame_color = color.new(neutralColor, 48), frame_width = 1, border_color = color.new(neutralColor, 76), border_width = 1)
if barstate.islast
    if showDashboard
        table.cell(dashboard, 0, 0, "STRUCTURE MAP", text_color = color.white, bgcolor = color.new(corridorColor, 10), text_size = size.small)
        table.cell(dashboard, 1, 0, stateText, text_color = color.white, bgcolor = color.new(corridorColor, 10), text_size = size.small)
        table.cell(dashboard, 0, 1, "Last Event", text_color = neutralColor, bgcolor = color.new(color.black, 84))
        table.cell(dashboard, 1, 1, lastEventText, text_color = lastEventColor, bgcolor = color.new(color.black, 84))
        table.cell(dashboard, 0, 2, "High Rail", text_color = neutralColor, bgcolor = color.new(color.black, 88))
        table.cell(dashboard, 1, 2, highRailText, text_color = bearBright, bgcolor = color.new(color.black, 88))
        table.cell(dashboard, 0, 3, "Low Rail", text_color = neutralColor, bgcolor = color.new(color.black, 84))
        table.cell(dashboard, 1, 3, lowRailText, text_color = bullBright, bgcolor = color.new(color.black, 84))
        table.cell(dashboard, 0, 4, "Candidate Age", text_color = neutralColor, bgcolor = color.new(color.black, 88))
        table.cell(dashboard, 1, 4, candidateAgeText, text_color = pendingDirection != 0 ? candidateColor : neutralColor, bgcolor = color.new(color.black, 88))
        table.cell(dashboard, 0, 5, "Break Displacement", text_color = neutralColor, bgcolor = color.new(color.black, 84))
        table.cell(dashboard, 1, 5, displacementText, text_color = pendingDirection != 0 ? candidateColor : neutralColor, bgcolor = color.new(color.black, 84))
    else
        table.clear(dashboard, 0, 0, 1, 5)

alertcondition(bullishBos, "Confirmed Bullish BOS", "Price confirmed a bullish break of the active structure-high rail.")
alertcondition(bearishBos, "Confirmed Bearish BOS", "Price confirmed a bearish break of the active structure-low rail.")
alertcondition(bullishTransitionConfirmed, "Confirmed Bullish Structure Transition", "A second ordered bullish structure break confirmed a bullish direction transition.")
alertcondition(bearishTransitionConfirmed, "Confirmed Bearish Structure Transition", "A second ordered bearish structure break confirmed a bearish direction transition.")
````
