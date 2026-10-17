# Range Migration Persistence Map [Pineify]

- url: https://www.tradingview.com/script/QD8qcarU-Range-Migration-Persistence-Map-Pineify/
- type: indicator
- pine_id: PUB;c6aa406ef54344629ae7bbaae1a31fe8
- version: 1.0

## Description

[b]Range Migration Persistence Map [Pineify][/b]

[b]Overview[/b]
This range migration indicator separates window removal from new-bar arrival. Range rails frame a center ribbon encoding remembered, close-supported migration. Purple strips expose expired extremes.

[b]Problem Definition[/b]
A rolling channel can rise because a new high arrives or an old low disappears. Its center can move without fresh upward acceptance; interpreting each rise as buying pressure confuses sample replacement with price behavior. An unchanged boundary can conceal an old extreme exiting and a new bar replacing it. Attribution must preserve both causes, including cancellation.

[b]Design Rationale[/b]
Removing the oldest bar before adding the current bar gives an exact accounting identity; reversing that order would allocate simultaneous replacement differently. Prior ATR excludes the current shock from the price scale. Closing beyond the previous boundary weights arrival evidence, reducing wick-only migration. Bounded impulses enter separate direction and activity memories. Hysteresis and consecutive closes reduce phase chatter but delay entry and release.

[b]Key Features[/b]
The overlay includes high-low rails, a center persistence halo, survivor tracks and expiry strips. Optional boundary cause dots and phase markers explain changes. A dashboard separates confirmed attribution from current candidates; the Data Window exposes the reconstruction residual.

[b]How It Works[/b]
For N bars, the previous range uses bars 1..N, survivors 1..N-1, and the updated range 0..N-1. Removal is survivor minus previous; arrival is updated minus survivor, for each boundary. Half the sum of upper and lower changes gives each center contribution. Removal plus arrival reconstructs total center movement; all are divided by prior ATR.
Upward arrival is weighted by the close's distance above the previous upper boundary divided by the new extension beyond it, clipped to 0..1. Downward arrival uses the mirrored rule. Half the weighted signed arrival sum gives accepted movement; closing within the old range contributes zero.
Accepted movement x becomes x/(1+abs(x)). With weight 2/(memory length+1), signed and absolute impulses enter separate zero-seeded decays. Coherence is absolute signed memory divided by absolute memory. Direction requires the entry level and coherence gate; an existing phase uses weaker release gates. A different candidate must persist for the configured number of closes.
All N+1 OHLC samples must be present and internally consistent; prior ATR must be positive. Newest ties define extreme ages. Invalid coverage clears memory and plots at close; recovery starts from zero.

[b]How Multiple Indicators Work Together[/b]
Range accounting identifies the cause before close location can qualify arrival. ATR makes accepted price movement comparable across local scales. Signed memory retains direction while absolute memory reveals cancellation, so coherence cannot be inferred from a slope alone. Removing attribution would admit expiry effects; removing close weighting would admit wick excursions; removing magnitude memory would hide opposing accepted arrivals.

[b]Trading Ideas and Insights[/b]
A rising center with purple lower-boundary expiry can be mechanical. Repeated close-supported arrivals offer context for examining migration, not an entry instruction. Compare phase, removal and arrival columns before judging a shift. Expiry contraction alerts report window arithmetic, not future volatility or breakouts.

[b]Unique Aspects[/b]
Relative to a plain rolling channel, the contribution is an ordered, reconstructable removal/arrival decomposition feeding a separate acceptance memory. Mixed replacement remains visible even when net boundary change is zero. Only arrival qualified against the previous range enters persistence; expiry moves remain diagnostic. Coherence and amplitude jointly control a delayed state, rather than renaming channel slope as trend strength.

[b]How to Use[/b]
Use standard OHLC charts, starting with a 24-bar range and 14-bar ATR. Wait for full coverage. Teal means confirmed upward acceptance, coral downward, and theme-aware neutral neither. Purple strips measure removal gaps. Triangles mark phase entries; gold circles mark release. Choose alerts once per bar close.

[b]Customization[/b]
Range length changes surviving extremes; ATR length changes normalization. Memory sets decay, entry sets amplitude, coherence gates agreement, and the release ratio sets hysteresis. Confirmation adds delay; the expiry threshold gates contraction alerts. Halo scale changes only memory's visual width. Expiry layers, halo, cause dots, transitions and table have independent switches. Defaults are starting points.

[b]Assumptions and Limitations[/b]
OHLC close location is an acceptance proxy, not traded-volume distribution or proof of demand. ATR lags, gaps can dominate arrival, and results depend on window and threshold choices. Full coverage includes the departing bar; zero ATR blocks output. Current candidates change intrabar while rails, memory, phase and alerts hold confirmed values. Feed revisions and parameter changes can alter history. The halo is a constructed memory width, not a support zone, probability or confidence interval. This script does not estimate execution, returns or future direction.

[b]Conclusion[/b]
Use this range migration persistence map to separate sample expiry from close-supported arrival. Accounting, memory and phase describe distinct aspects of each channel update.

## Source Code

````pine
//@version=6
indicator("Range Migration Persistence Map [Pineify]", overlay=true, max_bars_back=600)

// Independent remove-then-add range attribution. Ages choose the newest tied extreme.
int rangeLength = input.int(24, "Range window", minval=5, maxval=200, group="Calculation")
int atrLength = input.int(14, "Prior ATR length", minval=5, maxval=100, group="Calculation")
int memoryLength = input.int(8, "Acceptance memory", minval=2, maxval=60, group="Calculation")
float entryLevel = input.float(0.04, "Persistence entry", minval=0.005, maxval=0.50, step=0.005, group="State")
float releaseFraction = input.float(0.45, "Release / entry ratio", minval=0.10, maxval=0.90, step=0.05, group="State")
float coherenceLevel = input.float(0.55, "Directional coherence entry", minval=0.10, maxval=0.95, step=0.05, group="State")
int confirmBars = input.int(2, "Consecutive candidate closes", minval=1, maxval=8, group="State")
float expiryThreshold = input.float(0.10, "Expiry contraction / ATR", minval=0.01, maxval=3.0, step=0.01, group="State")
bool showExpiry = input.bool(true, "Expiry strips and survivor tracks", group="Visual")
bool showHalo = input.bool(true, "Persistence halo", group="Visual")
float haloScale = input.float(2.0, "Halo ATR scale", minval=0.25, maxval=4.0, step=0.25, group="Visual")
bool showReasons = input.bool(false, "Boundary cause dots", group="Visual")
bool showTransitions = input.bool(true, "Confirmed phase markers", group="Visual")
bool showTable = input.bool(true, "Attribution dashboard", group="Visual")

float priorATR = ta.atr(atrLength)[1]
float oldUpper = na
float oldLower = na
float survivorUpper = na
float survivorLower = na
float newUpper = na
float newLower = na
int upperAge = 0
int lowerAge = 0
bool complete = bar_index >= rangeLength
for i = 0 to rangeLength
    bool sampleOK = not na(open[i]) and not na(high[i]) and not na(low[i]) and not na(close[i]) and high[i] >= math.max(open[i], close[i]) and low[i] <= math.min(open[i], close[i]) and high[i] >= low[i]
    complete := complete and sampleOK
    if sampleOK
        if i >= 1
            oldUpper := na(oldUpper) ? high[i] : math.max(oldUpper, high[i])
            oldLower := na(oldLower) ? low[i] : math.min(oldLower, low[i])
        if i >= 1 and i < rangeLength
            survivorUpper := na(survivorUpper) ? high[i] : math.max(survivorUpper, high[i])
            survivorLower := na(survivorLower) ? low[i] : math.min(survivorLower, low[i])
        if i < rangeLength
            if na(newUpper) or high[i] > newUpper
                newUpper := high[i]
                upperAge := i
            if na(newLower) or low[i] < newLower
                newLower := low[i]
                lowerAge := i

bool mature = complete and not na(priorATR) and priorATR > 0 and syminfo.mintick > 0
float expiryUpper = mature ? survivorUpper - oldUpper : na
float expiryLower = mature ? survivorLower - oldLower : na
float incomingUpper = mature ? newUpper - survivorUpper : na
float incomingLower = mature ? newLower - survivorLower : na
float expiryMove = mature ? (expiryUpper + expiryLower) * 0.5 / priorATR : na
float incomingMove = mature ? (incomingUpper + incomingLower) * 0.5 / priorATR : na
float totalMove = mature ? ((newUpper - oldUpper) + (newLower - oldLower)) * 0.5 / priorATR : na
float residual = mature ? totalMove - expiryMove - incomingMove : na
float expiryWidth = mature ? (expiryLower - expiryUpper) / priorATR : na
float incomingWidth = mature ? (incomingUpper - incomingLower) / priorATR : na
float upperAcceptance = mature ? math.max(0.0, math.min(1.0, (close - oldUpper) / math.max(newUpper - oldUpper, syminfo.mintick))) : na
float lowerAcceptance = mature ? math.max(0.0, math.min(1.0, (oldLower - close) / math.max(oldLower - newLower, syminfo.mintick))) : na
float acceptedMove = mature ? (incomingUpper * upperAcceptance + incomingLower * lowerAcceptance) * 0.5 / priorATR : na
float impulse = mature ? acceptedMove / (1.0 + math.abs(acceptedMove)) : na
bool expiryCandidate = mature and expiryWidth >= expiryThreshold and expiryWidth > incomingWidth
float alpha = 2.0 / (memoryLength + 1.0)

var float persistence = 0.0
var float magnitudeMemory = 0.0
var int phase = 0
var int pendingPhase = 0
var int pendingCount = 0
var bool ready = false
var bool expiryActive = false
var float sUpper = na
var float sLower = na
var float sOldUpper = na
var float sOldLower = na
var float sSurvivorUpper = na
var float sSurvivorLower = na
var float sATR = na
var float sExpiry = na
var float sIncoming = na
var float sTotal = na
var float sResidual = na
var float sAccepted = na
var float sCoherence = na
var int sUpperAge = 0
var int sLowerAge = 0
var float sExpiryUpper = na
var float sExpiryLower = na
var float sIncomingUpper = na
var float sIncomingLower = na

bool phaseUp = false
bool phaseDown = false
bool phaseNeutral = false
bool expiryStart = false
bool coverageLost = false
if barstate.isconfirmed
    int previousPhase = phase
    bool previousReady = ready
    bool previousExpiry = expiryActive
    ready := mature
    if mature
        persistence := (1.0 - alpha) * persistence + alpha * impulse
        magnitudeMemory := (1.0 - alpha) * magnitudeMemory + alpha * math.abs(impulse)
        float coherence = magnitudeMemory > 1e-10 ? math.min(1.0, math.abs(persistence) / magnitudeMemory) : 0.0
        int candidate = 0
        if persistence >= entryLevel and coherence >= coherenceLevel
            candidate := 1
        else if persistence <= -entryLevel and coherence >= coherenceLevel
            candidate := -1
        else if phase == 1 and persistence >= entryLevel * releaseFraction and coherence >= coherenceLevel * 0.75
            candidate := 1
        else if phase == -1 and persistence <= -entryLevel * releaseFraction and coherence >= coherenceLevel * 0.75
            candidate := -1
        if candidate == phase
            pendingPhase := phase
            pendingCount := 0
        else
            pendingCount := candidate == pendingPhase ? pendingCount + 1 : 1
            pendingPhase := candidate
            if pendingCount >= confirmBars
                phase := candidate
                pendingCount := 0
        expiryActive := expiryCandidate
        expiryStart := expiryActive and not previousExpiry
        phaseUp := phase == 1 and previousPhase != 1
        phaseDown := phase == -1 and previousPhase != -1
        phaseNeutral := phase == 0 and previousPhase != 0
        sUpper := newUpper
        sLower := newLower
        sOldUpper := oldUpper
        sOldLower := oldLower
        sSurvivorUpper := survivorUpper
        sSurvivorLower := survivorLower
        sATR := priorATR
        sExpiry := expiryMove
        sIncoming := incomingMove
        sTotal := totalMove
        sResidual := residual
        sAccepted := acceptedMove
        sCoherence := coherence
        sUpperAge := upperAge
        sLowerAge := lowerAge
        sExpiryUpper := expiryUpper
        sExpiryLower := expiryLower
        sIncomingUpper := incomingUpper
        sIncomingLower := incomingLower
    else
        persistence := 0.0
        magnitudeMemory := 0.0
        phase := 0
        pendingPhase := 0
        pendingCount := 0
        expiryActive := false
        sUpper := na
        sLower := na
        sOldUpper := na
        sOldLower := na
        sSurvivorUpper := na
        sSurvivorLower := na
        sATR := na
        sExpiry := na
        sIncoming := na
        sTotal := na
        sResidual := na
        sAccepted := na
        sCoherence := na
        sExpiryUpper := na
        sExpiryLower := na
        sIncomingUpper := na
        sIncomingLower := na
        coverageLost := previousReady

color upColor = #008C82
color downColor = #D34D4D
color expiryColor = #8660C5
color mixedColor = #B17B1F
color neutralColor = color.new(chart.fg_color, 30)
color stateColor = phase == 1 ? upColor : phase == -1 ? downColor : neutralColor
float middle = ready ? (sUpper + sLower) * 0.5 : na
float haloHalfWidth = ready ? sATR * math.abs(persistence) * haloScale : na
pUpper = plot(sUpper, "Confirmed upper range", color.new(stateColor, 15), 2, plot.style_stepline)
pLower = plot(sLower, "Confirmed lower range", color.new(stateColor, 15), 2, plot.style_stepline)
fill(pUpper, pLower, color.new(stateColor, 97), title="Confirmed range field", fillgaps=false)
plot(middle, "Range center / persistence phase", stateColor, 3, plot.style_linebr)
pHaloUpper = plot(showHalo ? middle + haloHalfWidth : na, "Persistence halo upper", color.new(stateColor, 100), style=plot.style_linebr)
pHaloLower = plot(showHalo ? middle - haloHalfWidth : na, "Persistence halo lower", color.new(stateColor, 100), style=plot.style_linebr)
fill(pHaloUpper, pHaloLower, ready ? color.new(stateColor, 88 - int(math.round(20.0 * sCoherence))) : na, title="Accepted persistence magnitude", fillgaps=false)
pOldUpper = plot(showExpiry ? sOldUpper : na, "Previous upper range", color.new(expiryColor, 100), style=plot.style_stepline)
pSurvivorUpper = plot(showExpiry ? sSurvivorUpper : na, "Upper after removal", color.new(expiryColor, 50), 1, plot.style_stepline)
pOldLower = plot(showExpiry ? sOldLower : na, "Previous lower range", color.new(expiryColor, 100), style=plot.style_stepline)
pSurvivorLower = plot(showExpiry ? sSurvivorLower : na, "Lower after removal", color.new(expiryColor, 50), 1, plot.style_stepline)
fill(pOldUpper, pSurvivorUpper, ready and sExpiryUpper < 0 ? color.new(expiryColor, 82) : na, title="Upper boundary expiry strip", fillgaps=false)
fill(pSurvivorLower, pOldLower, ready and sExpiryLower > 0 ? color.new(expiryColor, 82) : na, title="Lower boundary expiry strip", fillgaps=false)
bool upperExpired = ready and sExpiryUpper < 0
bool lowerExpired = ready and sExpiryLower > 0
bool upperAdded = ready and sIncomingUpper > 0
bool lowerAdded = ready and sIncomingLower < 0
plot(showReasons and barstate.isconfirmed and (upperExpired or upperAdded) ? sUpper : na, "Upper cause dot", upperExpired and upperAdded ? mixedColor : upperExpired ? expiryColor : upColor, 3, plot.style_circles)
plot(showReasons and barstate.isconfirmed and (lowerExpired or lowerAdded) ? sLower : na, "Lower cause dot", lowerExpired and lowerAdded ? mixedColor : lowerExpired ? expiryColor : downColor, 3, plot.style_circles)
plotshape(showTransitions and phaseUp ? middle : na, "Upward acceptance confirmed", shape.triangleup, location.absolute, upColor, size=size.tiny)
plotshape(showTransitions and phaseDown ? middle : na, "Downward acceptance confirmed", shape.triangledown, location.absolute, downColor, size=size.tiny)
plotshape(showTransitions and phaseNeutral ? middle : na, "Persistence released", shape.circle, location.absolute, mixedColor, size=size.tiny)
plot(ready ? persistence : na, "Accepted persistence (-1..1)", display=display.data_window)
plot(sCoherence, "Accepted directional coherence", display=display.data_window)
plot(sExpiry, "Expiry center move / ATR", display=display.data_window)
plot(sIncoming, "Incoming center move / ATR", display=display.data_window)
plot(sTotal, "Total center move / ATR", display=display.data_window)
plot(sResidual, "Attribution reconstruction residual", display=display.data_window)

f_number(float x) =>
    na(x) ? "n/a" : str.tostring(x, "#.####")
var table dash = table.new(position.top_right, 3, 9, bgcolor=chart.bg_color, frame_color=color.new(chart.fg_color, 75), frame_width=1)
if barstate.islast
    table.clear(dash, 0, 0, 2, 8)
    if showTable
        string phaseText = not ready ? "Unavailable" : phase == 1 ? "Up acceptance" : phase == -1 ? "Down acceptance" : "Neutral"
        table.cell(dash, 0, 0, "Range attribution", text_color=chart.fg_color)
        table.cell(dash, 1, 0, "Confirmed", text_color=chart.fg_color)
        table.cell(dash, 2, 0, "Candidate", text_color=mixedColor)
        table.cell(dash, 0, 1, "Phase / readiness", text_color=chart.fg_color)
        table.cell(dash, 1, 1, phaseText, text_color=stateColor)
        table.cell(dash, 2, 1, mature ? "Valid sample" : "Not mature", text_color=mixedColor)
        table.cell(dash, 0, 2, "Center move / ATR", text_color=chart.fg_color)
        table.cell(dash, 1, 2, f_number(sTotal), text_color=chart.fg_color)
        table.cell(dash, 2, 2, f_number(totalMove), text_color=mixedColor)
        table.cell(dash, 0, 3, "Removal / arrival", text_color=chart.fg_color)
        table.cell(dash, 1, 3, f_number(sExpiry) + " / " + f_number(sIncoming), text_color=expiryColor)
        table.cell(dash, 2, 3, f_number(expiryMove) + " / " + f_number(incomingMove), text_color=mixedColor)
        table.cell(dash, 0, 4, "Accepted move / ATR", text_color=chart.fg_color)
        table.cell(dash, 1, 4, f_number(sAccepted), text_color=stateColor)
        table.cell(dash, 2, 4, f_number(acceptedMove), text_color=mixedColor)
        table.cell(dash, 0, 5, "Memory / coherence", text_color=chart.fg_color)
        table.cell(dash, 1, 5, ready ? f_number(persistence) + " / " + f_number(sCoherence) : "n/a", text_color=stateColor)
        table.cell(dash, 0, 6, "Upper / lower age", text_color=chart.fg_color)
        table.cell(dash, 1, 6, ready ? str.tostring(sUpperAge) + " / " + str.tostring(sLowerAge) : "n/a", text_color=chart.fg_color)
        table.cell(dash, 0, 7, "Expiry contraction", text_color=chart.fg_color)
        table.cell(dash, 1, 7, not ready ? "n/a" : expiryActive ? "Dominant" : "Below gate", text_color=expiryColor)
        table.cell(dash, 0, 8, "Reconstruction error", text_color=chart.fg_color)
        table.cell(dash, 1, 8, f_number(sResidual), text_color=chart.fg_color)

alertcondition(phaseUp, "Upward range acceptance", "Confirmed upward accepted range migration on {{ticker}} {{interval}}.")
alertcondition(phaseDown, "Downward range acceptance", "Confirmed downward accepted range migration on {{ticker}} {{interval}}.")
alertcondition(phaseNeutral, "Range persistence released", "Accepted range migration persistence returned to neutral on {{ticker}} {{interval}}.")
alertcondition(expiryStart, "Expiry-dominated contraction", "Window removal dominates range contraction on {{ticker}} {{interval}}.")
alertcondition(coverageLost, "Range attribution unavailable", "Complete OHLC coverage or prior ATR scale lost on {{ticker}} {{interval}}.")
````
