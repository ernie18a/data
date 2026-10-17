# Momentum Impulse Wave 

- url: https://www.tradingview.com/script/srmrgpwA-Momentum-Impulse-Wave/
- type: indicator
- pine_id: PUB;c20699249eaf4c2e9fa81771ebd6ab0a
- version: 1.0

## Description

Momentum Impulse Wave
Momentum Impulse Wave combines volatility-normalised momentum, EMA smoothing, momentum acceleration and closed-bar phase confirmation to show which direction price momentum is moving and whether that movement is strengthening or losing force.
It is designed to support continuation analysis, pullback assessment and recognition of fading momentum.
What’s inside
1. Volatility-normalised momentum
The indicator measures the change in closing price over eight bars and divides it by the sum of True Range over those same eight bars. True Range accounts for each bar’s range and gaps from the previous close.
This measures directional progress relative to the amount of price movement occurring along the way. Positive values indicate upward displacement; negative values indicate downward displacement. Readings are ratios, not percentages or probabilities.
2. Adjustable EMA smoothing
A three-period exponential moving average smooths the momentum reading to form the main wave. Increasing the smoothing length produces a steadier wave with more lag. Reducing it makes the wave more responsive; setting it to one removes smoothing.
3. Momentum acceleration
Acceleration is the difference between the current smoothed momentum reading and its reading three bars earlier. It helps distinguish a move that is gaining force from one that remains directional but is slowing.
For example, positive momentum with negative acceleration indicates that upward momentum is braking. It does not mean momentum has already turned bearish.
4. Momentum and acceleration deadbands
Two separate thresholds prevent every small fluctuation from being classified as a directional phase:
- Momentum deadband: ±0.03 by default.
- Acceleration deadband: ±0.01 by default.
Both momentum and acceleration must exceed their respective thresholds to qualify for a directional phase. The additional ±0.10 wave emphasis boundary is a visual reference only; it does not change phase confirmation or filter alerts.
5. Closed-bar phase confirmation
By default, the same candidate phase must occur on two consecutive completed bars before it is confirmed. This applies to Neutral as well as directional phases.
The wave publishes completed-bar readings, and the panel retains the latest closed-bar observation. While a new phase is pending, the panel continues to identify the previous confirmed phase.
The five phases
- Positive strengthening: momentum above +0.03 and acceleration above +0.01.
- Positive braking: momentum above +0.03 and acceleration below −0.01.
- Negative strengthening: momentum below −0.03 and acceleration below −0.01.
- Negative braking: momentum below −0.03 and acceleration above +0.01.
- Neutral: valid readings that do not meet any of those four combinations.
Neutral does not necessarily mean sideways price action. Directional momentum can remain present while acceleration is too small to qualify.
Trading applications
Use the wave alongside price structure, trend direction and key levels:
- Continuation: strengthening momentum can support a setup when price structure agrees with the direction.
- Pullbacks: braking can help identify reduced directional pressure as a move pauses or retraces.
- Momentum recovery: renewed strengthening after a pullback can help assess whether the original direction is regaining force.
- Breakout assessment: expanding momentum can provide context for follow-through, but neither a zero crossing nor a threshold crossing proves that a breakout will hold.
Panel and alerts
The panel displays the confirmed phase, smoothed momentum, acceleration, phase age, pending confirmation progress and the latest completed-bar timestamp.
Optional alerts identify confirmed phase changes. You can select individual phases or receive all confirmed changes. Optional candle colouring and a raw, unsmoothed momentum trace are also included.
Momentum Impulse Wave measures price momentum and its change; it does not predict price or provide standalone buy and sell signals. Acceleration is derived from momentum, so it is not an independent confirmation source. Strong readings do not establish overbought or oversold conditions, and braking does not guarantee a reversal.

## Source Code

````pine
//@version=6
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, obtain one at https://mozilla.org/MPL/2.0/.
// Copyright (c) 2026 Glassline
indicator("Momentum Acceleration Wave - Glassline Impulse v1.0", shorttitle="GL Impulse 1.0", overlay=false, precision=4, max_bars_back=500, explicit_plot_zorder=true)

// F03: short-horizon momentum, not Prism's longer-path regime coherence.
// No intrabar publication, lookahead, secondary timeframe or independent confirmation.
string G_ENGINE = "Momentum"
int displacementLength = input.int(8, "Displacement lookback", minval=1, maxval=100, group=G_ENGINE, tooltip="Close displacement divided by the actual sum of true range over this many chart bars, including gaps. Default 8.")
string G_ADV = "Advanced"
int smoothingLength = input.int(3, "Momentum smoothing (EMA; 1 = off)", minval=1, maxval=50, group=G_ADV, tooltip="Default 3. First valid displacement seeds the EMA. Invalid displacement resets it. Length 1 removes smoothing; longer lengths add lag.")
int accelerationLength = input.int(3, "Acceleration comparison bars", minval=1, maxval=50, group=G_ADV, tooltip="vSmooth minus vSmooth this many bars ago. Default 3. No division by the interval and no extra smoothing.")
float momentumBand = input.float(0.03, "Momentum deadband", minval=0.0, maxval=0.5, step=0.005, group=G_ADV, tooltip="Direction must strictly exceed this magnitude. Equality is inside the deadband. Default 0.03.")
float accelerationBand = input.float(0.01, "Acceleration deadband", minval=0.0, maxval=0.5, step=0.005, group=G_ADV, tooltip="Acceleration has its own strict threshold. Never applied to momentum times acceleration. Default 0.01.")
int confirmationBars = input.int(2, "Phase confirmation closes", minval=1, maxval=5, group=G_ADV, tooltip="Same candidate on this many consecutive completed bars, including Neutral. Confirmation occurs on the final qualifying close; never backdated.")
bool diagnostic = input.bool(false, "Diagnostic: raw normalised displacement", group=G_ADV, tooltip="Thin secondary trace of unsmoothed v, for comparison only. Off by default. Does not change the engine or alerts.")
string G_VIEW = "Appearance"
string palette = input.string("Classic", "Palette", options=["Classic", "Crystal", "Arctic", "Aurora", "Cobalt"], group=G_VIEW)
string glow = input.string("Subtle", "Glow", options=["Off", "Subtle", "Neon"], group=G_VIEW, tooltip="Subtle is the lighter default; Neon adds a second halo. All layers copy the same wave, without additional smoothing.")
float waveWidth = input.float(1.5, "Wave line weight", minval=1.0, maxval=4.0, step=0.5, group=G_VIEW, tooltip="Default 1.5 gives a crisp 1px centre plus a half-opacity 2px edge. Pine uses whole-pixel strokes, so half steps blend adjacent widths for an in-between visual weight. Choose 1 for thin or 2–4 for bolder. Appearance only.")
bool showFill = input.bool(true, "Gradient wave fill", group=G_VIEW)
bool tintCandles = input.bool(false, "Colour confirmed candles", group=G_VIEW, tooltip="Main-chart candles only on completed bars with confirmed directional phases. Neutral, pending and unavailable bars retain chart colours.")
string G_PANEL = "Panel"
bool showPanel = input.bool(true, "Show panel", group=G_PANEL)
string panelLocation = input.string("Top right", "Position", options=["Top right", "Top left", "Bottom right", "Bottom left"], group=G_PANEL)
string panelSize = input.string("Compact", "Text size", options=["Compact", "Standard"], group=G_PANEL)
string G_ALERTS = "Alerts"
string alertSelection = input.string("Any confirmed phase change", "Dynamic alert selection", options=["Any confirmed phase change", "Positive strengthening", "Positive braking", "Negative strengthening", "Negative braking", "Neutral", "Off"], group=G_ALERTS, tooltip="For TradingView's Any alert() function call condition. Sends the phase name, symbol and timeframe once at confirmation. Named phase alert conditions are independently selectable. Creating a running alert is optional.")

// Codes: +1 positive strengthening, +2 positive braking; -1 negative
// strengthening, -2 negative braking; 0 Neutral; na unavailable/unconfirmed.
f_phaseName(int phase) =>
    switch phase
        1 => "Positive strengthening"
        2 => "Positive braking"
        -1 => "Negative strengthening"
        -2 => "Negative braking"
        0 => "Neutral"
        => "Unconfirmed"

f_candidate(float momentum, float acceleration) =>
    int result = 0
    if momentum > momentumBand
        result := acceleration > accelerationBand ? 1 : acceleration < -accelerationBand ? 2 : 0
    else if momentum < -momentumBand
        result := acceleration < -accelerationBand ? -1 : acceleration > accelerationBand ? -2 : 0
    result

f_signed(float value) =>
    na(value) ? "UNAVAILABLE" : (value > 0 ? "+" : "") + str.tostring(value, "0.0000")

// ENGINE: evaluated on every execution; Pine rollback discards intrabar state.
// ta.tr(false) requires the prior close; no high-low fallback on missing history.
float actualTR = ta.tr(false)
bool ohlcValid = not na(open) and not na(high) and not na(low) and not na(close)
float strictTR = ohlcValid ? actualTR : na
float denominator = 0.0
// Explicit finite window: an NA anywhere poisons the sum instead of skipping a bar.
for i = 0 to displacementLength - 1
    denominator += strictTR[i]
float rawDisplacement = close - close[displacementLength]
bool displacementValid = not na(rawDisplacement) and not na(denominator) and denominator > 0
float v = displacementValid ? rawDisplacement / denominator : na
float alpha = 2.0 / (smoothingLength + 1.0)
var float vSmooth = na
vSmooth := na(v) ? na : na(vSmooth[1]) ? v : alpha * v + (1.0 - alpha) * vSmooth[1]
var int validRun = 0
validRun := displacementValid ? nz(validRun[1], 0) + 1 : 0
// Require a continuous fresh EMA segment, including all comparison bars.
float a = validRun > accelerationLength ? vSmooth - vSmooth[accelerationLength] : na
bool dataValid = not na(vSmooth) and not na(a)
int candidate = dataValid ? f_candidate(vSmooth, a) : na

// CLOSE-ONLY state. Unavailable data clears the baseline, so recovery cannot alert.
var int confirmedPhase = na
var int candidatePhase = na
var int candidateCount = 0
var int phaseAge = 0
var bool publishedValid = false
var bool pending = false
var float publishedMomentum = na
var float publishedAcceleration = na
var int lastInputTime = na
var string dataReason = "Waiting for a completed bar"
bool phaseChanged = false
if barstate.isconfirmed
    lastInputTime := time_close
    publishedValid := dataValid
    publishedMomentum := dataValid ? vSmooth : na
    publishedAcceleration := dataValid ? a : na
    if not dataValid
        confirmedPhase := na
        candidatePhase := na
        candidateCount := 0
        phaseAge := 0
        pending := false
        dataReason := not displacementValid ? "Missing history / zero TR sum" : "Building acceleration history"
    else
        dataReason := "Completed input"
        if not na(candidatePhase) and candidate == candidatePhase
            candidateCount := math.min(candidateCount + 1, confirmationBars)
        else
            candidatePhase := candidate
            candidateCount := 1
        if not na(confirmedPhase)
            phaseAge += 1
        bool differs = na(confirmedPhase) or candidate != confirmedPhase
        if differs and candidateCount >= confirmationBars
            phaseChanged := not na(confirmedPhase)
            confirmedPhase := candidate
            phaseAge := 1
        pending := na(confirmedPhase) or candidate != confirmedPhase

// APPEARANCE starts here: no visual input is referenced by the engine above.
color positive = switch palette
    "Crystal" => #77D9FF
    "Arctic" => #35E3FF
    "Aurora" => #5AFFC4
    "Cobalt" => #4D91FF
    => #20F58A
color positiveHighlight = switch palette
    "Crystal" => #DDF7FF
    "Arctic" => #A0F3FF
    "Aurora" => #B0FFE3
    "Cobalt" => #9CC3FF
    => #62FF9C
color negative = switch palette
    "Crystal" => #9A86F7
    "Arctic" => #FF528F
    "Aurora" => #C77DFF
    "Cobalt" => #FF746C
    => #FF304F
color negativeHighlight = switch palette
    "Crystal" => #C2B5FF
    "Arctic" => #FF92B7
    "Aurora" => #E1B6FF
    "Cobalt" => #FFB0A9
    => #FF5C6C
float chartLuma = 0.2126 * color.r(chart.bg_color) + 0.7152 * color.g(chart.bg_color) + 0.0722 * color.b(chart.bg_color)
bool light = chartLuma > 160
// Same hue family, reduced RGB luminance on light backgrounds; exact palette on dark.
f_ink(color hue) =>
    light ? color.rgb(int(color.r(hue) * 0.52), int(color.g(hue) * 0.52), int(color.b(hue) * 0.52)) : hue
color secondary = light ? #536174 : #98A4B3
color primary = light ? #172638 : #E6F1FF
color surface = light ? #F3F6FB : #10151D
color divider = light ? #D0DAE6 : #1F2A3A
color caution = light ? #8A5700 : #FFBD59
// Visual magnitude zones only: the phase engine keeps its configured deadbands.
// Grey includes equality at the momentum deadband. Faint colour includes +/-0.10.
// If the configured momentum deadband exceeds 0.10, grey takes precedence.
bool neutralWave = math.abs(vSmooth) <= momentumBand
bool faintWave = not neutralWave and math.abs(vSmooth) <= 0.10
float waveOpacity = faintWave ? 0.45 : 1.0
color waveHue = neutralWave ? secondary : vSmooth > 0 ? positive : negative
color waveCore = neutralWave ? secondary : vSmooth > 0 ? positiveHighlight : negativeHighlight
f_waveInk(color hue, float transparency) =>
    color ink = neutralWave ? secondary : f_ink(hue)
    color.new(ink, 100.0 - (100.0 - transparency) * waveOpacity)
bool showObservation = barstate.isconfirmed and dataValid
float wave = showObservation ? vSmooth : na
bool strengthening = not na(confirmedPhase) and math.abs(confirmedPhase) == 1
bool braking = not na(confirmedPhase) and math.abs(confirmedPhase) == 2
int fillTransparency = pending ? 95 : strengthening ? 70 : braking ? 90 : 96
color edgeFill = showFill ? f_waveInk(waveHue, fillTransparency) : na
color zeroFill = showFill ? f_waveInk(waveHue, 100) : na
// Keep the user's chart/pane background unchanged; do not paint a backdrop.
hline(0, "Zero", color=color.new(secondary, 25), linestyle=hline.style_solid, editable=false)
hline(momentumBand, "+ momentum deadband", color=color.new(secondary, 65), linestyle=hline.style_dotted, editable=false)
hline(-momentumBand, "- momentum deadband", color=color.new(secondary, 65), linestyle=hline.style_dotted, editable=false)
zeroPlot = plot(showObservation ? 0 : na, "Fill anchor", color=na, display=display.none, editable=false)
fillPlot = plot(wave, "Fill mask", color=na, display=display.none, style=plot.style_linebr, editable=false)
fill(fillPlot, zeroPlot, top_value=math.max(wave, 0), bottom_value=math.min(wave, 0), top_color=wave >= 0 ? edgeFill : zeroFill, bottom_color=wave >= 0 ? zeroFill : edgeFill, title="Directional gradient", fillgaps=false, editable=false)
// Fractional visual weight blends adjacent whole-pixel strokes of the same wave.
int coreWidth = int(math.floor(waveWidth))
float edgeOpacity = waveWidth - coreWidth
plot(wave, "Outer halo", color=glow == "Neon" ? f_waveInk(waveHue, 87) : na, linewidth=coreWidth + 4, style=plot.style_linebr, display=display.pane, editable=false)
plot(wave, "Inner halo", color=glow == "Off" ? na : f_waveInk(waveHue, glow == "Neon" ? 68 : 87), linewidth=coreWidth + 2, style=plot.style_linebr, display=display.pane, editable=false)
plot(wave, "Line weight edge", color=edgeOpacity > 0 ? f_waveInk(light ? waveHue : waveCore, 100.0 * (1.0 - edgeOpacity)) : na, linewidth=coreWidth + 1, style=plot.style_linebr, display=display.pane, editable=false)
plot(wave, "Momentum wave", color=f_waveInk(light ? waveHue : waveCore, 0), linewidth=coreWidth, style=plot.style_linebr, display=display.pane, editable=false)
plot(diagnostic and showObservation ? v : na, "Diagnostic raw normalised displacement", color=color.new(secondary, 35), linewidth=1, style=plot.style_linebr, display=display.pane, editable=false)
color candleInk = showObservation and tintCandles and not pending and not na(confirmedPhase) and confirmedPhase != 0 ? (confirmedPhase > 0 ? positive : negative) : na
barcolor(candleInk, title="Confirmed directional candles", editable=false)

// Data Window uses the bar under the cursor; the open bar has no published values.
plot(showObservation ? rawDisplacement : na, "Raw close displacement (price units)", display=display.data_window)
plot(showObservation ? denominator : na, "True range rolling sum", display=display.data_window)
plot(showObservation ? v : na, "Raw normalised displacement", display=display.data_window)
plot(wave, "Smoothed momentum", display=display.data_window)
plot(showObservation ? math.abs(vSmooth) : na, "Absolute momentum magnitude", display=display.data_window)
plot(showObservation ? a : na, "Acceleration (comparison difference)", display=display.data_window)
plot(showObservation ? confirmedPhase : na, "Confirmed phase code (+1,+2,-1,-2,0)", display=display.data_window)
plot(showObservation ? candidate : na, "Candidate phase code (+1,+2,-1,-2,0)", display=display.data_window)
plot(showObservation and not na(confirmedPhase) ? phaseAge : na, "Confirmed phase age", display=display.data_window)
plot(showObservation and pending ? candidateCount : na, "Pending consecutive closes", display=display.data_window)
plot(barstate.isconfirmed ? (dataValid ? 1 : 0) : na, "Data available (1 yes, 0 no)", display=display.data_window)

string panelPosition = switch panelLocation
    "Top left" => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left" => position.bottom_left
    => position.top_right
int fontSize = panelSize == "Compact" ? 10 : 12
var table panel = table.new(panelPosition, 2, 6, bgcolor=surface, frame_color=divider, frame_width=1, border_color=divider, border_width=1)
f_cell(int column, int row, string value, color ink, string tip) =>
    table.cell(panel, column, row, " " + value + " ", text_color=ink, bgcolor=surface, text_size=fontSize, text_halign=column == 0 ? text.align_left : text.align_right, text_formatting=row == 0 ? text.format_bold : text.format_none, tooltip=tip)
if barstate.islast
    if showPanel
        string neutralReason = math.abs(publishedMomentum) <= momentumBand ? "Weak momentum: inside momentum deadband" : "Unresolved acceleration: inside acceleration deadband; directional momentum may be strong"
        string phaseText = not publishedValid ? "UNAVAILABLE" : f_phaseName(confirmedPhase)
        color phaseInk = not publishedValid or na(confirmedPhase) or confirmedPhase == 0 ? secondary : f_ink(confirmedPhase > 0 ? positive : negative)
        string ageText = na(confirmedPhase) ? "--" : str.tostring(phaseAge) + " bars"
        string progressText = pending ? " | " + str.tostring(candidateCount) + "/" + str.tostring(confirmationBars) + " pending" : ""
        string pendingTip = pending ? "Pending: " + f_phaseName(candidatePhase) + ". Previous confirmed phase retains its own age." : "No pending transition. Confirmation bar is age 1."
        string inputStamp = na(lastInputTime) ? "--" : str.format_time(lastInputTime, "MM-dd HH:mm", "UTC") + " UTC"
        f_cell(0, 0, "GLASSLINE", primary, "F03 | Short-horizon momentum")
        f_cell(1, 0, "IMPULSE 1.0", primary, "Momentum Acceleration Wave - Glassline Impulse v1.0")
        f_cell(0, 1, "Confirmed phase", secondary, "May differ from the pending candidate. No intrabar preview.")
        f_cell(1, 1, phaseText, phaseInk, publishedValid and confirmedPhase == 0 and not pending ? neutralReason : pendingTip)
        f_cell(0, 2, "Momentum", secondary, "Signed EMA of normalised displacement, latest completed bar.")
        f_cell(1, 2, f_signed(publishedMomentum), publishedMomentum > 0 ? f_ink(positive) : publishedMomentum < 0 ? f_ink(negative) : secondary, publishedValid and candidatePhase == 0 ? neutralReason : "Signed momentum; large magnitude does not establish exhaustion.")
        f_cell(0, 3, "Acceleration", secondary, "Momentum difference across the configured comparison interval; not independent confirmation.")
        f_cell(1, 3, f_signed(publishedAcceleration), primary, publishedValid and candidatePhase == 0 ? neutralReason : "Negative acceleration can mean positive braking or negative strengthening.")
        f_cell(0, 4, "Age / confirmation", secondary, pendingTip)
        f_cell(1, 4, ageText + progressText, pending ? caution : primary, pendingTip)
        f_cell(0, 5, publishedValid ? "Closed input" : "UNAVAILABLE", publishedValid ? secondary : caution, dataReason)
        f_cell(1, 5, inputStamp, secondary, dataReason + ". Timestamp is bar close in UTC. Open bar is excluded.")
    else
        table.clear(panel, 0, 0, 1, 5)

// Optional dynamic route names the new phase. Static routes are independently selectable.
bool selectedChange = alertSelection == "Any confirmed phase change" or alertSelection == f_phaseName(confirmedPhase)
if phaseChanged and barstate.isconfirmed and selectedChange and alertSelection != "Off"
    alert("Glassline Impulse: State change — " + f_phaseName(confirmedPhase) + " | " + syminfo.tickerid + " | " + timeframe.period, alert.freq_once_per_bar_close)
alertcondition(phaseChanged and confirmedPhase == 1, "Impulse: Positive strengthening", "Glassline Impulse: State change — Positive strengthening | {{exchange}}:{{ticker}} | {{interval}}")
alertcondition(phaseChanged and confirmedPhase == 2, "Impulse: Positive braking", "Glassline Impulse: State change — Positive braking | {{exchange}}:{{ticker}} | {{interval}}")
alertcondition(phaseChanged and confirmedPhase == -1, "Impulse: Negative strengthening", "Glassline Impulse: State change — Negative strengthening | {{exchange}}:{{ticker}} | {{interval}}")
alertcondition(phaseChanged and confirmedPhase == -2, "Impulse: Negative braking", "Glassline Impulse: State change — Negative braking | {{exchange}}:{{ticker}} | {{interval}}")
alertcondition(phaseChanged and confirmedPhase == 0, "Impulse: Neutral", "Glassline Impulse: State change — Neutral | {{exchange}}:{{ticker}} | {{interval}}")
````
