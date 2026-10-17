# AG Pro Structural Momentum Oscillator [AGPro Series]

- url: https://www.tradingview.com/script/uYKpqhaz-AG-Pro-Structural-Momentum-Oscillator-AGPro-Series/
- type: indicator
- pine_id: PUB;39282aac11814816810865a4cf36af82
- version: 8.0

## Description

[b]AG Pro Structural Momentum Oscillator [AGPro Series][/b]

[b]OVERVIEW[/b]

AG Pro Structural Momentum Oscillator evaluates momentum through price structure instead of relying on a standard oscillator formula alone. The goal is not to duplicate a classic RSI, MACD, or stochastic workflow, but to study how price behaves internally: where bars close within their own range, how upper and lower wicks are distributed, how efficiently directional travel develops, and whether pullbacks remain controlled or start to damage the underlying move.

This produces a structure-based momentum reading that is designed to help users distinguish between constructive directional pressure, weak or unstable movement, and transition phases. In practice, the oscillator is intended for traders who want more context than a simple overbought/oversold style reading, while still keeping the visual experience compact and readable in a separate pane.

The model is normalized into a clean oscillator format and supported by an optional panel that exposes the internal components behind the headline score. This makes the script easier to inspect without turning it into a crowded dashboard. The result is a momentum tool that remains chart-friendly while still offering transparency about what is driving the current state.

[image]https://www.tradingview.com/x/TZPZFRm5/[/image]

[b]WHAT THIS SCRIPT DOES[/b]

This script builds a composite momentum score from structural price behavior. Instead of measuring momentum only through smoothed distance or rate-of-change logic, it examines whether bars are closing with quality, whether wick balance supports continuation or rejection, whether the move is advancing efficiently, whether counter-moves are being absorbed, and whether directional pressure is persisting across the selected lookback.

The oscillator is shown in a separate pane so that the price chart remains clean. Stronger bullish conditions push the reading toward the upper zone, stronger bearish conditions push it toward the lower zone, and transitional behavior tends to cluster around the middle band. Optional markers can highlight structural shifts, expansion entries, and midline events, while the panel can display both the current state and the underlying component scores.

[b]UNIQUE EDGE[/b]

The core idea here is structure-based momentum assessment.

This script does not attempt to repackage a traditional oscillator with cosmetic changes. Its momentum reading is built from several structural observations working together:

- close quality within the bar range
- wick pressure balance
- impulse efficiency
- pullback control
- directional persistence

That combination is what makes the oscillator different. It is not asking only whether price moved. It is asking how price moved, whether that movement was internally supportive, and whether the recent sequence of bars reflects constructive continuation or unstable friction.

Because of that design, the oscillator can be useful in situations where traders want additional confirmation around trend continuation, weakening follow-through, or state transitions, without depending on a single legacy oscillator formula.

[b]METHODOLOGY[/b]

The composite score is built from a weighted structural model.

1) Close Quality
This measures where the bar closes relative to its own range. Bars that close with directional conviction contribute more positively or negatively than bars that finish in weak or indecisive positions.

2) Wick Pressure
This evaluates the balance between upper and lower wick behavior. It helps estimate whether rejection pressure is supporting the current direction or working against it.

3) Impulse Efficiency
This compares net directional progress against recent travel. Large movement alone is not treated as strength if the structure is inefficient or overly noisy.

4) Pullback Control
This examines whether counter-direction movement remains contained or begins to undermine the active directional leg.

5) Persistence
This tracks whether structural bias has been holding together across the recent window instead of flipping constantly from bar to bar.

These components are normalized and combined into a structural momentum oscillator score. The separate panel allows users to inspect the same internal drivers individually, which can be helpful when the headline reading is near transition levels.

[b]SIGNALS AND ALERTS[/b]

The oscillator can be used visually or through alerts.

Depending on settings, the script can monitor:

- bullish structural shifts
- bearish structural shifts
- bullish expansion entries
- bearish expansion entries
- midline events

Optional markers can be displayed directly in the oscillator pane. The legend row in the panel explains what each marker type represents. Users who prefer a cleaner presentation can disable markers or legend items from the settings.

As with most technical tools, signals are best interpreted in context. A structural shift is not the same thing as a trade command. It is an analytical event showing that the model detected a meaningful change in the balance of recent price behavior.

[b]KEY INPUTS[/b]

The script includes the following input groups:

- structure length
- persistence window
- pullback window
- smoothing
- expansion thresholds
- panel visibility and font size
- signal marker mode
- marker legend visibility
- marker cooldown

These controls allow the user to keep the oscillator relatively clean by default, or expose more information when deeper inspection is needed.

[b]HOW TO READ IT[/b]

A higher reading generally indicates stronger constructive bullish structure. A lower reading generally indicates stronger constructive bearish structure. Readings near the middle zone typically represent mixed or transitional behavior rather than strong directional consensus.

The panel state labels are designed to summarize that environment in plain language. The component rows below the headline score can help explain why the state is strong, weak, improving, or deteriorating.

In general, the oscillator is most useful when read together with price structure, trend context, and nearby technical levels, rather than in complete isolation.

[b]LIMITATIONS AND TRANSPARENCY[/b]

This script is an analytical aid, not a predictive engine.

It does not know future price direction. It only evaluates the recent structural character of price action according to its own model. Like any momentum-based tool, it can react quickly during strong directional phases and become less reliable during noisy, event-driven, or highly erratic conditions.

Different symbols and timeframes can also produce different structural behavior. Users should expect to adjust settings where appropriate and validate how the oscillator behaves on the markets they follow.

The script is designed to provide a structured interpretation of momentum, but it should not be treated as a guarantee of continuation, reversal, or trade outcome.

[b]RISK DISCLOSURE[/b]

This indicator is provided for chart analysis, research, and educational use only. It does not provide financial advice, investment advice, or guaranteed signals. All trading decisions remain the sole responsibility of the user. Technical indicators should be used with risk management and broader market context, not as standalone certainty tools.

## Source Code

````pine
// -------------------------------------------------
// Structural Momentum Oscillator [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.6
//
// A composite structural momentum oscillator that reads directional control
// from close quality, wick pressure, impulse efficiency, pullback control and
// persistence. The engine converts price-action structure into a clean 0-100
// momentum score, highlights bullish and bearish expansion regimes, and shows
// component alignment for traders who read market structure, trend strength,
// momentum shifts and price-action quality across any symbol or timeframe.
// Includes a plain-language Next Action readout that converts the momentum
// state into a clear focus line.
// -------------------------------------------------
//@version=6
indicator("Structural Momentum Oscillator [AGPro Series]", shorttitle = "AG Pro SMO", overlay = false, precision = 2, max_labels_count = 500, max_boxes_count = 500)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
// Brand
headerBg      = color.rgb(37, 99, 235)      // #2563EB
headerText    = color.rgb(245, 247, 250)    // #F5F7FA
// Panel
panelBg       = color.rgb(15, 23, 42)       // #0F172A
panelBorder   = color.rgb(51, 65, 85)       // #334155
panelLabelCol = color.rgb(148, 163, 184)    // #94A3B8
panelValueCol = color.rgb(226, 232, 240)    // #E2E8F0
// Midnight theme variants
panelBgMid     = color.rgb(8, 13, 24)
panelBorderMid = color.rgb(30, 41, 59)
// Theme-safe panel cells
panelBullCell    = color.rgb(13, 92, 80)
panelBearCell    = color.rgb(118, 43, 79)
panelNeutralCell = color.rgb(101, 74, 28)
panelAccentCell  = color.rgb(67, 70, 136)
panelMutedCell   = color.rgb(30, 41, 59)
// States
bullColor     = color.rgb(34, 197, 166)     // #22C5A6
bearColor     = color.rgb(244, 114, 182)    // #F472B6
neutralColor  = color.rgb(245, 189, 92)     // #F5BD5C
accentColor   = color.rgb(129, 140, 248)    // #818CF8

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(_x, _min, _max) =>
    math.min(math.max(_x, _min), _max)

f_safe_div(_num, _den) =>
    _den != 0.0 ? _num / _den : 0.0

f_scale_100(_x) =>
    50.0 + 50.0 * f_clamp(_x, -1.0, 1.0)

f_state_text(_score, _upper, _lower) =>
    _score >= _upper ? "Strong Bullish" :
     _score > 55.0 ? "Constructive Bullish" :
     _score <= _lower ? "Strong Bearish" :
     _score < 45.0 ? "Constructive Bearish" : "Neutral"

f_state_value(_score, _upper, _lower) =>
    _score >= _upper ? 2 :
     _score > 55.0 ? 1 :
     _score <= _lower ? -2 :
     _score < 45.0 ? -1 : 0

f_bias_text(_score) =>
    _score > 55.0 ? "Bullish" : _score < 45.0 ? "Bearish" : "Neutral"

f_alignment_text(_score) =>
    _score >= 78.0 ? "High" :
     _score >= 64.0 ? "Balanced" :
     _score >= 50.0 ? "Mixed" : "Fragmented"

f_next_action(_stateValue) =>
    _stateValue == 2  ? "Hold Bias - Bull Expansion" :
     _stateValue == 1  ? "Track Bull Momentum" :
     _stateValue == -2 ? "Hold Bias - Bear Expansion" :
     _stateValue == -1 ? "Track Bear Momentum" : "Wait - Compression"

f_rolling_sum(_src, _len) =>
    _cum = ta.cum(_src)
    _cum - nz(_cum[_len], 0.0)

f_text_size(_size) =>
    _size == "Tiny" ? size.tiny :
     _size == "Small" ? size.small :
     _size == "Normal" ? size.normal :
     _size == "Large" ? size.large : size.huge

f_panel_pos(_p) =>
    _p == "Top Right"     ? position.top_right :
     _p == "Top Center"   ? position.top_center :
     _p == "Top Left"     ? position.top_left :
     _p == "Middle Right" ? position.middle_right :
     _p == "Middle Center"? position.middle_center :
     _p == "Middle Left"  ? position.middle_left :
     _p == "Bottom Right" ? position.bottom_right :
     _p == "Bottom Center"? position.bottom_center : position.bottom_left

// -------------------------------------------------
// Inputs - Engine
// -------------------------------------------------
grpCore = "Engine"
structureLen      = input.int(14, "Structure Length", minval = 3, group = grpCore, tooltip = "Primary lookback used to evaluate directional travel efficiency and structural balance.")
persistenceWindow = input.int(8,  "Persistence Window", minval = 3, group = grpCore, tooltip = "Window used to measure how consistently directional structure persists across recent bars.")
pullbackWindow    = input.int(5,  "Pullback Window", minval = 2, group = grpCore, tooltip = "Short-term window used to compare with-flow movement against counter-flow pullbacks.")
flowDeadband      = input.float(0.02, "Flow Direction Deadband", minval = 0.0, maxval = 0.20, step = 0.01, group = grpCore, tooltip = "Keeps near-zero impulse readings direction-neutral so pullback control is not assigned to a bullish or bearish side without a meaningful structural lead.")
smoothingLen      = input.int(3,  "Smoothing", minval = 1, group = grpCore, tooltip = "Applies light EMA smoothing to the composite structural momentum score.")
upperExpansion    = input.float(65.0, "Upper Expansion Level", minval = 50.0, maxval = 100.0, step = 0.5, group = grpCore, tooltip = "Upper structural expansion threshold. Crossing above marks bullish expansion.")
lowerExpansion    = input.float(35.0, "Lower Expansion Level", minval = 0.0,  maxval = 50.0,  step = 0.5, group = grpCore, tooltip = "Lower structural expansion threshold. Crossing below marks bearish expansion.")

// -------------------------------------------------
// Inputs - Oscillator Visuals
// -------------------------------------------------
grpOsc = "Oscillator Visuals"
showSignalLine       = input.bool(true,  "Show Signal Line",       group = grpOsc, tooltip = "Displays a smoothed signal line derived from the structural momentum score.")
showMidlineFill      = input.bool(true,  "Show Midline Fill",      group = grpOsc, tooltip = "Fills the area between the structural momentum line and the 50-line so directional control is easier to read.")
showMomentumCloud    = input.bool(true,  "Show Momentum Cloud",    group = grpOsc, tooltip = "Adds a soft fill between the momentum line and the signal line for faster visual reading.")
showZoneBands        = input.bool(true,  "Show Expansion Bands",   group = grpOsc, tooltip = "Adds subtle upper and lower expansion band shading so key momentum areas are easier to read at a glance.")
showBalanceBand      = input.bool(true,  "Show Balance Band",      group = grpOsc, tooltip = "Adds a quiet center-band reference around the 50-line. This helps users distinguish neutral compression from directional expansion.")
showStateBg          = input.bool(false, "Show State Background",  group = grpOsc, tooltip = "Adds a very light pane-wide tint only during strong expansion states. Off by default to keep the pane clean.")
showEventPulse       = input.bool(true,  "Show Event Pulses",      group = grpOsc, tooltip = "Highlights qualified expansion-entry bars with subtle vertical background pulses. Bias shifts remain visible through their dedicated markers without adding full-height stripes.")
showEndpointDot      = input.bool(true,  "Show Endpoint Dot",      group = grpOsc, tooltip = "Highlights the latest structural momentum reading with a small endpoint marker.")
colorIntensity       = input.string("Balanced", "Color Intensity", options = ["Soft", "Balanced", "Strong"], group = grpOsc, tooltip = "Controls how visible state-based coloring appears across fills, clouds and blocks.")

// -------------------------------------------------
// Inputs - Regime Blocks
// -------------------------------------------------
grpBlock = "Regime Blocks"
showRegimeBlocks     = input.bool(true,  "Show Regime Blocks", group = grpBlock, tooltip = "Draws a clean block inside the oscillator pane whenever a strong expansion regime persists. Bullish expansion blocks sit near the top rail, bearish expansion blocks sit near the bottom rail. Built to be read at a glance without distorting the oscillator scale.")
blockMinBars         = input.int(4, "Block Minimum Bars", minval = 2, maxval = 30, group = grpBlock, tooltip = "Minimum number of bars an expansion regime must persist before a block is drawn. Higher values keep only the most decisive regimes.")
blockExtendBars      = input.int(2, "Block Right Padding", minval = 0, maxval = 20, group = grpBlock, tooltip = "How many bars of visual padding are added to the right side of each regime block for breathing room.")
blockTransp          = input.int(70, "Block Transparency", minval = 40, maxval = 92, group = grpBlock, tooltip = "Transparency of regime block fills. Higher values are more subtle.")
showBlockLabel       = input.bool(true, "Show Block Label", group = grpBlock, tooltip = "Shows a centered state label inside each regime block so no active zone is left unidentified.")
blockLabelSize       = input.string("Normal", "Block Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpBlock, tooltip = "Controls the font size of regime block labels.")

// -------------------------------------------------
// Inputs - Markers
// -------------------------------------------------
grpMk = "Markers"
signalMarkers        = input.string("Minimal", "Signal Markers", options = ["Off", "Minimal", "Detailed"], group = grpMk, tooltip = "Off hides event markers. Minimal shows bias-shift and expansion markers. Detailed also shows midline reclaim and midline loss markers.")
markerCooldown       = input.int(6, "Marker Cooldown", minval = 1, maxval = 50, group = grpMk, tooltip = "Minimum number of bars required before the same marker type can print again. Higher values reduce clutter.")
visualMode           = input.string("Showcase", "Visual Mode", options = ["Showcase", "Full"], group = grpMk, tooltip = "Showcase keeps only the highest-quality events visible. Full keeps the denser event view.")
markerFontSize       = input.string("Normal", "Marker Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpMk, tooltip = "Controls the font size of oscillator event labels.")

// -------------------------------------------------
// Inputs - Panel
// -------------------------------------------------
grpPanel = "Panel"
showPanel            = input.bool(true, "Show Panel", group = grpPanel, tooltip = "Displays the AGPro information panel inside the oscillator pane.")
panelPosition        = input.string("Top Right", "Panel Position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpPanel, tooltip = "Controls where the panel is anchored inside the oscillator pane.")
panelTheme           = input.string("Dark", "Panel Theme", options = ["Dark", "Midnight"], group = grpPanel, tooltip = "Panel surface theme. Both options use opaque contrast-safe cells so the panel stays readable on dark and light chart themes.")
panelMode            = input.string("Standard", "Panel Mode", options = ["Standard", "Minimal"], group = grpPanel, tooltip = "Standard shows every component row. Minimal shows only the key state summary.")
panelFontSize        = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpPanel, tooltip = "Controls the font size used inside the information panel.")
showCurrentTag       = input.bool(true, "Show Current State Tag", group = grpPanel, tooltip = "Adds a compact right-edge tag with the latest score and state so the current reading is visible at a glance.")
currentTagSize       = input.string("Normal", "Current Tag Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpPanel, tooltip = "Controls the font size of the current state tag shown at the right edge of the oscillator.")
currentTagOffset     = input.int(4, "Current Tag Offset", minval = 1, maxval = 20, group = grpPanel, tooltip = "Moves the latest state tag a few bars to the right so it does not cover the endpoint marker or the newest oscillator values.")

// -------------------------------------------------
// Core bar structure metrics
// -------------------------------------------------
barRange   = math.max(high - low, syminfo.mintick)
bodySize   = math.abs(close - open)
bodyRatio  = f_clamp(f_safe_div(bodySize, barRange), 0.0, 1.0)
upperWick  = high - math.max(open, close)
lowerWick  = math.min(open, close) - low
closeLoc   = f_clamp(f_safe_div(close - low, barRange), 0.0, 1.0)
closeBias  = closeLoc * 2.0 - 1.0

closeQualityRaw = closeBias * (0.35 + 0.65 * bodyRatio)
wickPressureRaw = f_clamp(f_safe_div(lowerWick - upperWick, barRange), -1.0, 1.0) * (0.30 + 0.70 * math.abs(closeBias))

travelSum            = nz(f_rolling_sum(math.abs(close - close[1]), structureLen), 0.0)
impulseEfficiencyRaw = na(close[structureLen]) ? 0.0 : f_safe_div(close - close[structureLen], math.max(travelSum, syminfo.mintick))
impulseEfficiency    = f_clamp(impulseEfficiencyRaw, -1.0, 1.0)

upTravel           = nz(f_rolling_sum(math.max(close - close[1], 0.0), pullbackWindow), 0.0)
downTravel         = nz(f_rolling_sum(math.max(close[1] - close, 0.0), pullbackWindow), 0.0)
flowDir            = impulseEfficiency > flowDeadband ? 1.0 : impulseEfficiency < -flowDeadband ? -1.0 : 0.0
withFlow           = flowDir > 0.0 ? upTravel : flowDir < 0.0 ? downTravel : 0.0
counterFlow        = flowDir > 0.0 ? downTravel : flowDir < 0.0 ? upTravel : 0.0
pullbackControlRaw = flowDir == 0.0 ? 0.0 : f_safe_div(withFlow - counterFlow, math.max(withFlow + counterFlow, syminfo.mintick))
pullbackControl    = f_clamp(pullbackControlRaw, -1.0, 1.0)

barStructureBias   = closeQualityRaw * 0.65 + wickPressureRaw * 0.35
barDirectionalSign = barStructureBias > 0.10 ? 1.0 : barStructureBias < -0.10 ? -1.0 : 0.0
persistenceRaw     = nz(f_rolling_sum(barDirectionalSign, persistenceWindow), 0.0) / persistenceWindow
persistence        = f_clamp(persistenceRaw, -1.0, 1.0)

structuralMomentumRaw =
     closeQualityRaw   * 0.25 +
     wickPressureRaw   * 0.20 +
     impulseEfficiency * 0.20 +
     pullbackControl   * 0.20 +
     persistence       * 0.15

structuralMomentumSmoothed = smoothingLen > 1 ? ta.ema(structuralMomentumRaw, smoothingLen) : structuralMomentumRaw
structuralMomentumScore    = f_scale_100(structuralMomentumSmoothed)
signalLine                 = ta.ema(structuralMomentumScore, math.max(2, smoothingLen * 2))
signalSpread               = math.abs(structuralMomentumScore - signalLine)

closeQualityScore = f_scale_100(closeQualityRaw)
wickPressureScore = f_scale_100(wickPressureRaw)
impulseScore      = f_scale_100(impulseEfficiency)
pullbackScore     = f_scale_100(pullbackControl)
persistenceScore  = f_scale_100(persistence)

componentDeviation =
     (math.abs(closeQualityScore - structuralMomentumScore) +
      math.abs(wickPressureScore - structuralMomentumScore) +
      math.abs(impulseScore - structuralMomentumScore) +
      math.abs(pullbackScore - structuralMomentumScore) +
      math.abs(persistenceScore - structuralMomentumScore)) / 5.0

componentAlignment = f_clamp(100.0 - componentDeviation, 0.0, 100.0)
alignmentText      = f_alignment_text(componentAlignment)

stateValue = f_state_value(structuralMomentumScore, upperExpansion, lowerExpansion)
stateText  = f_state_text(structuralMomentumScore, upperExpansion, lowerExpansion)
biasText   = f_bias_text(structuralMomentumScore)
nextActionTxt = f_next_action(stateValue)

// -------------------------------------------------
// Transparency profiles
// -------------------------------------------------
strongBgTransp   = colorIntensity == "Soft" ? 96 : colorIntensity == "Balanced" ? 94 : 90
zoneUpperTransp  = colorIntensity == "Soft" ? 96 : colorIntensity == "Balanced" ? 93 : 89
zoneLowerTransp  = colorIntensity == "Soft" ? 96 : colorIntensity == "Balanced" ? 93 : 89
balanceBandTransp= colorIntensity == "Soft" ? 96 : colorIntensity == "Balanced" ? 94 : 90
cloudTransp      = colorIntensity == "Soft" ? 88 : colorIntensity == "Balanced" ? 82 : 74
midFillTransp    = colorIntensity == "Soft" ? 92 : colorIntensity == "Balanced" ? 88 : 82

// -------------------------------------------------
// Dynamic colors
// -------------------------------------------------
lineColor =
     stateValue == 2  ? bullColor :
     stateValue == 1  ? color.new(bullColor, 30) :
     stateValue == -2 ? bearColor :
     stateValue == -1 ? color.new(bearColor, 30) : neutralColor

signalColor =
     stateValue >= 1 ? color.new(panelValueCol, 46) :
     stateValue <= -1 ? color.new(panelLabelCol, 42) : color.new(panelLabelCol, 58)

bgColor =
     stateValue == 2  ? color.new(bullColor, strongBgTransp) :
     stateValue == -2 ? color.new(bearColor, strongBgTransp) : na

zoneUpperColor  = color.new(bullColor, zoneUpperTransp)
zoneLowerColor  = color.new(bearColor, zoneLowerTransp)
balanceBandCol  = color.new(neutralColor, balanceBandTransp)

cloudColor =
     structuralMomentumScore >= signalLine ?
         (stateValue >=  1 ? color.new(bullColor, cloudTransp) : color.new(accentColor, math.min(cloudTransp + 4, 94))) :
         (stateValue <= -1 ? color.new(bearColor, cloudTransp) : color.new(neutralColor, math.min(cloudTransp + 6, 95)))

midFillColor =
     structuralMomentumScore >= 50.0 ?
         (stateValue >=  1 ? color.new(bullColor, midFillTransp) : color.new(accentColor, math.min(midFillTransp + 2, 94))) :
         (stateValue <= -1 ? color.new(bearColor, midFillTransp) : color.new(neutralColor, math.min(midFillTransp + 4, 95)))

// -------------------------------------------------
// Marker logic
// -------------------------------------------------
markerBullShift  = ta.crossover(structuralMomentumScore, 55.0)
markerBearShift  = ta.crossunder(structuralMomentumScore, 45.0)
markerBullExp    = ta.crossover(structuralMomentumScore, upperExpansion)
markerBearExp    = ta.crossunder(structuralMomentumScore, lowerExpansion)
markerMidReclaim = ta.crossover(structuralMomentumScore, 50.0)
markerMidLoss    = ta.crossunder(structuralMomentumScore, 50.0)

showMinimalMarkers = signalMarkers == "Minimal" or signalMarkers == "Detailed"
showDetailedOnly   = signalMarkers == "Detailed"

bullShiftReady = nz(ta.barssince(markerBullShift[1]), 10000) > markerCooldown
bearShiftReady = nz(ta.barssince(markerBearShift[1]), 10000) > markerCooldown
bullExpReady   = nz(ta.barssince(markerBullExp[1]),   10000) > markerCooldown
bearExpReady   = nz(ta.barssince(markerBearExp[1]),   10000) > markerCooldown
midPlusReady   = nz(ta.barssince(markerMidReclaim[1]),10000) > markerCooldown
midMinusReady  = nz(ta.barssince(markerMidLoss[1]),   10000) > markerCooldown

strongBullShift = markerBullShift and bullShiftReady and structuralMomentumScore >= 55.0 and closeQualityScore >= 50.0 and persistenceScore >= 52.0 and signalSpread >= 1.5 and componentAlignment >= 55.0
strongBearShift = markerBearShift and bearShiftReady and structuralMomentumScore <= 45.0 and closeQualityScore <= 50.0 and persistenceScore <= 48.0 and signalSpread >= 1.5 and componentAlignment >= 55.0
strongBullExp   = markerBullExp   and bullExpReady   and impulseScore >= 55.0 and persistenceScore >= 52.0 and closeQualityScore >= 50.0 and componentAlignment >= 58.0
strongBearExp   = markerBearExp   and bearExpReady   and impulseScore <= 45.0 and persistenceScore <= 48.0 and closeQualityScore <= 50.0 and componentAlignment >= 58.0

plotBullShift = visualMode == "Showcase" ? strongBullShift : markerBullShift and bullShiftReady
plotBearShift = visualMode == "Showcase" ? strongBearShift : markerBearShift and bearShiftReady
plotBullExp   = visualMode == "Showcase" ? strongBullExp   : markerBullExp   and bullExpReady
plotBearExp   = visualMode == "Showcase" ? strongBearExp   : markerBearExp   and bearExpReady
plotMidPlus   = visualMode == "Showcase" ? false : markerMidReclaim and midPlusReady
plotMidMinus  = visualMode == "Showcase" ? false : markerMidLoss    and midMinusReady

bullShiftLane = math.min(60.5, upperExpansion - 4.0)
bearShiftLane = math.max(39.5, lowerExpansion + 4.0)
bullExpLane   = math.min(72.0, upperExpansion + 5.0)
bearExpLane   = math.max(28.0, lowerExpansion - 5.0)
midPlusLane   = 52.5
midMinusLane  = 47.5

eventPulseColor =
     plotBullExp   ? color.new(bullColor, 86) :
     plotBearExp   ? color.new(bearColor, 86) : na

combinedBgColor = not na(eventPulseColor) and showEventPulse ? eventPulseColor : showStateBg ? bgColor : na


// -------------------------------------------------
// Oscillator plots
// -------------------------------------------------
hline(50.0, "Midline", color = color.new(panelLabelCol, 58), linestyle = hline.style_dotted)

midFillBasePlot = plot(50.0, "Midline Fill Base", color = na, display = display.none)

momentumPlot   = plot(structuralMomentumScore, "Structural Momentum", color = lineColor, linewidth = 3)
signalPlot     = plot(showSignalLine ? signalLine : na, "Signal Line", color = signalColor, linewidth = 1)
upperLevelPlot = plot(upperExpansion, "Upper Expansion Level", color = color.new(bullColor, 70), linewidth = 1, style = plot.style_line)
lowerLevelPlot = plot(lowerExpansion, "Lower Expansion Level", color = color.new(bearColor, 70), linewidth = 1, style = plot.style_line)

zoneTopPlot      = plot(showZoneBands ? 100.0 : na,          "Upper Zone Top",    color = na, display = display.none)
zoneUpperPlot    = plot(showZoneBands ? upperExpansion : na, "Upper Zone Base",   color = na, display = display.none)
zoneLowerPlot    = plot(showZoneBands ? lowerExpansion : na, "Lower Zone Top",    color = na, display = display.none)
zoneBottomPlot   = plot(showZoneBands ? 0.0 : na,            "Lower Zone Bottom", color = na, display = display.none)
balanceTopPlot   = plot(showBalanceBand ? 55.0 : na,         "Balance Band Top",  color = na, display = display.none)
balanceBotPlot   = plot(showBalanceBand ? 45.0 : na,         "Balance Band Base", color = na, display = display.none)

fill(zoneTopPlot, zoneUpperPlot, color = zoneUpperColor, title = "Upper Expansion Band")
fill(zoneLowerPlot, zoneBottomPlot, color = zoneLowerColor, title = "Lower Expansion Band")
fill(balanceTopPlot, balanceBotPlot, color = balanceBandCol, title = "Balance Band")
fill(momentumPlot, signalPlot, color = showMomentumCloud ? cloudColor : na, title = "Momentum Cloud")
fill(momentumPlot, midFillBasePlot, color = showMidlineFill ? midFillColor : na, title = "Momentum Midline Fill")

plotshape(showEndpointDot and barstate.islast ? structuralMomentumScore : na, title = "Current Momentum Dot", style = shape.circle, location = location.absolute, color = lineColor, size = size.small)

bgcolor(combinedBgColor)

// -------------------------------------------------
// Marker labels
// -------------------------------------------------
mkSize = f_text_size(markerFontSize)

if showMinimalMarkers and plotBullShift and barstate.isconfirmed
    label.new(bar_index, bullShiftLane, "▲", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = accentColor, size = mkSize)
if showMinimalMarkers and plotBearShift and barstate.isconfirmed
    label.new(bar_index, bearShiftLane, "▼", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = neutralColor, size = mkSize)
if showMinimalMarkers and plotBullExp and barstate.isconfirmed
    label.new(bar_index, bullExpLane, "◆", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = bullColor, size = mkSize)
if showMinimalMarkers and plotBearExp and barstate.isconfirmed
    label.new(bar_index, bearExpLane, "◆", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = bearColor, size = mkSize)
if showDetailedOnly and plotMidPlus and barstate.isconfirmed
    label.new(bar_index, midPlusLane, "●", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = color.new(accentColor, 20), size = size.tiny)
if showDetailedOnly and plotMidMinus and barstate.isconfirmed
    label.new(bar_index, midMinusLane, "●", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = color.new(panelLabelCol, 20), size = size.tiny)

// -------------------------------------------------
// Regime Blocks
// -------------------------------------------------
var int  bullRunLen      = 0
var int  bearRunLen      = 0
var bool bullBlockOpen   = false
var bool bearBlockOpen   = false
var box  activeBullBlock = na
var box  activeBearBlock = na
var label activeBullBlockLabel = na
var label activeBearBlockLabel = na

bullRailTop = 99.0
bullRailBot = 95.0
bearRailTop = 5.0
bearRailBot = 1.0

bullRunLen := stateValue == 2  ? bullRunLen + 1 : 0
bearRunLen := stateValue == -2 ? bearRunLen + 1 : 0

lblSize = f_text_size(blockLabelSize)

if showRegimeBlocks and barstate.isconfirmed
    if stateValue == 2
        if not bullBlockOpen and bullRunLen >= blockMinBars
            leftIdx = bar_index - (blockMinBars - 1)
            rightIdx = bar_index + blockExtendBars
            activeBullBlock := box.new(leftIdx, bullRailTop, rightIdx, bullRailBot, border_color = color.new(bullColor, 30), border_width = 1, bgcolor = color.new(bullColor, blockTransp), extend = extend.none)
            if showBlockLabel
                activeBullBlockLabel := label.new(int(math.round((leftIdx + rightIdx) / 2.0)), (bullRailTop + bullRailBot) / 2.0, "Bullish Expansion", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = headerText, color = color.new(bullColor, 8), size = lblSize)
            bullBlockOpen := true
        else if bullBlockOpen and not na(activeBullBlock)
            rightIdx = bar_index + blockExtendBars
            box.set_right(activeBullBlock, rightIdx)
            if showBlockLabel and not na(activeBullBlockLabel)
                label.set_x(activeBullBlockLabel, int(math.round((box.get_left(activeBullBlock) + rightIdx) / 2.0)))
                label.set_y(activeBullBlockLabel, (bullRailTop + bullRailBot) / 2.0)
    else
        if bullBlockOpen
            bullBlockOpen := false
            activeBullBlock := na
            activeBullBlockLabel := na

    if stateValue == -2
        if not bearBlockOpen and bearRunLen >= blockMinBars
            leftIdx = bar_index - (blockMinBars - 1)
            rightIdx = bar_index + blockExtendBars
            activeBearBlock := box.new(leftIdx, bearRailTop, rightIdx, bearRailBot, border_color = color.new(bearColor, 30), border_width = 1, bgcolor = color.new(bearColor, blockTransp), extend = extend.none)
            if showBlockLabel
                activeBearBlockLabel := label.new(int(math.round((leftIdx + rightIdx) / 2.0)), (bearRailTop + bearRailBot) / 2.0, "Bearish Expansion", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = headerText, color = color.new(bearColor, 8), size = lblSize)
            bearBlockOpen := true
        else if bearBlockOpen and not na(activeBearBlock)
            rightIdx = bar_index + blockExtendBars
            box.set_right(activeBearBlock, rightIdx)
            if showBlockLabel and not na(activeBearBlockLabel)
                label.set_x(activeBearBlockLabel, int(math.round((box.get_left(activeBearBlock) + rightIdx) / 2.0)))
                label.set_y(activeBearBlockLabel, (bearRailTop + bearRailBot) / 2.0)
    else
        if bearBlockOpen
            bearBlockOpen := false
            activeBearBlock := na
            activeBearBlockLabel := na

// -------------------------------------------------
// Current state tag
// -------------------------------------------------
var label currentStateTag = na

if barstate.islast
    if not na(currentStateTag)
        label.delete(currentStateTag)
    if showCurrentTag
        tagY = structuralMomentumScore >= signalLine ? math.min(structuralMomentumScore + 4.0, 93.0) : math.max(structuralMomentumScore - 4.0, 7.0)
        tagBg =
             stateValue == 2  ? color.new(bullColor, 10) :
             stateValue == 1  ? color.new(accentColor, 10) :
             stateValue == -2 ? color.new(bearColor, 10) :
             stateValue == -1 ? color.new(neutralColor, 10) : color.new(panelBorder, 10)
        currentStateTag := label.new(bar_index + currentTagOffset, tagY, str.tostring(structuralMomentumScore, "#.0") + " | " + stateText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = tagBg, size = f_text_size(currentTagSize))
    else
        currentStateTag := na

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bullShift     = ta.crossover(structuralMomentumScore, 55.0)
bearShift     = ta.crossunder(structuralMomentumScore, 45.0)
bullExpansion = ta.crossover(structuralMomentumScore, upperExpansion)
bearExpansion = ta.crossunder(structuralMomentumScore, lowerExpansion)

alertcondition(bullShift,     "Structural Momentum Turns Bullish",   "Structural Momentum turned bullish on the confirmed bar close.")
alertcondition(bearShift,     "Structural Momentum Turns Bearish",   "Structural Momentum turned bearish on the confirmed bar close.")
alertcondition(bullExpansion, "Momentum Enters Bullish Expansion",   "Structural Momentum entered the bullish expansion zone on the confirmed bar close.")
alertcondition(bearExpansion, "Momentum Enters Bearish Expansion",   "Structural Momentum entered the bearish expansion zone on the confirmed bar close.")
alertcondition(strongBullExp, "Strong Bullish Expansion Confirmed",  "Qualified bullish expansion with impulse, persistence and component-alignment confirmation.")
alertcondition(strongBearExp, "Strong Bearish Expansion Confirmed",  "Qualified bearish expansion with impulse, persistence and component-alignment confirmation.")

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelSurface = panelTheme == "Midnight" ? panelBgMid : panelBg
panelEdge    = panelTheme == "Midnight" ? panelBorderMid : panelBorder

f_score_cell_bg(_score) =>
    _score >= 65.0 ? panelBullCell :
     _score >= 55.0 ? panelAccentCell :
     _score <= 35.0 ? panelBearCell :
     _score <= 45.0 ? panelNeutralCell : panelMutedCell

f_alignment_cell_bg(_score) =>
    _score >= 78.0 ? panelBullCell :
     _score >= 64.0 ? panelAccentCell :
     _score >= 50.0 ? panelNeutralCell : panelBearCell

f_spread_cell_bg(_spread) =>
    _spread >= 10.0 ? panelBullCell :
     _spread >= 6.0 ? panelAccentCell :
     _spread >= 3.0 ? panelNeutralCell : panelMutedCell

stateBg =
     stateValue == 2  ? panelBullCell :
     stateValue == 1  ? panelAccentCell :
     stateValue == -2 ? panelBearCell :
     stateValue == -1 ? panelNeutralCell : panelMutedCell

var table panel = na
var string activePanelPos = ""
var string activePanelTheme = ""

if barstate.islast
    panelTextSize = f_text_size(panelFontSize)
    needPanel = showPanel and (na(panel) or activePanelPos != panelPosition or activePanelTheme != panelTheme)

    if needPanel
        if not na(panel)
            table.delete(panel)
        panel := table.new(f_panel_pos(panelPosition), 2, 12, border_color = panelEdge, border_width = 1)
        table.merge_cells(panel, 0, 0, 1, 0)
        activePanelPos := panelPosition
        activePanelTheme := panelTheme

    if showPanel and not na(panel)
        table.clear(panel, 0, 0, 1, 11)
        rowBg = color.new(panelSurface, 0)
        labTx = panelLabelCol
        valTx = panelValueCol

        table.cell(panel, 0, 0, "AG Pro Structural Momentum Oscillator", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
        table.cell(panel, 1, 0, "",                            text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
        table.merge_cells(panel, 0, 0, 1, 0)

        table.cell(panel, 0, 1, "State", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
        table.cell(panel, 1, 1, stateText, text_color = valTx, bgcolor = stateBg, text_size = panelTextSize)

        table.cell(panel, 0, 2, "Next Action", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
        table.cell(panel, 1, 2, nextActionTxt, text_color = headerText, bgcolor = panelAccentCell, text_size = panelTextSize)

        table.cell(panel, 0, 3, "Momentum", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
        table.cell(panel, 1, 3, str.tostring(structuralMomentumScore, "#.0"), text_color = valTx, bgcolor = f_score_cell_bg(structuralMomentumScore), text_size = panelTextSize)

        table.cell(panel, 0, 4, "Bias", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
        table.cell(panel, 1, 4, biasText, text_color = valTx, bgcolor = f_score_cell_bg(structuralMomentumScore), text_size = panelTextSize)

        table.cell(panel, 0, 5, "Alignment", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
        table.cell(panel, 1, 5, alignmentText + " " + str.tostring(componentAlignment, "#.0"), text_color = valTx, bgcolor = f_alignment_cell_bg(componentAlignment), text_size = panelTextSize)

        table.cell(panel, 0, 6, "Signal Spread", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
        table.cell(panel, 1, 6, str.tostring(signalSpread, "#.0"), text_color = valTx, bgcolor = f_spread_cell_bg(signalSpread), text_size = panelTextSize)

        if panelMode == "Standard"
            table.cell(panel, 0, 7, "Close Quality", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 1, 7, str.tostring(closeQualityScore, "#.0"), text_color = valTx, bgcolor = f_score_cell_bg(closeQualityScore), text_size = panelTextSize)

            table.cell(panel, 0, 8, "Wick Pressure", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 1, 8, str.tostring(wickPressureScore, "#.0"), text_color = valTx, bgcolor = f_score_cell_bg(wickPressureScore), text_size = panelTextSize)

            table.cell(panel, 0, 9, "Impulse Eff.", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 1, 9, str.tostring(impulseScore, "#.0"), text_color = valTx, bgcolor = f_score_cell_bg(impulseScore), text_size = panelTextSize)

            table.cell(panel, 0, 10, "Pullback Ctrl", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 1, 10, str.tostring(pullbackScore, "#.0"), text_color = valTx, bgcolor = f_score_cell_bg(pullbackScore), text_size = panelTextSize)

            table.cell(panel, 0, 11, "Persistence", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 1, 11, str.tostring(persistenceScore, "#.0"), text_color = valTx, bgcolor = f_score_cell_bg(persistenceScore), text_size = panelTextSize)
        else
            table.cell(panel, 0, 7, "Persistence", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 1, 7, str.tostring(persistenceScore, "#.0"), text_color = valTx, bgcolor = f_score_cell_bg(persistenceScore), text_size = panelTextSize)

            table.cell(panel, 0, 8, "", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 1, 8, "", text_color = valTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 0, 9, "", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 1, 9, "", text_color = valTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 0, 10, "", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 1, 10, "", text_color = valTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 0, 11, "", text_color = labTx, bgcolor = rowBg, text_size = panelTextSize)
            table.cell(panel, 1, 11, "", text_color = valTx, bgcolor = rowBg, text_size = panelTextSize)

    else if not showPanel and not na(panel)
        table.clear(panel, 0, 0, 1, 11)
````
