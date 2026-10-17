# WizTrader Price Context

- url: https://www.tradingview.com/script/Oocfikri-WizTrader-Price-Context/
- type: indicator
- pine_id: PUB;f42cddb571cc405b808cd409418d98cf
- version: 1.0

## Description

[b]WizTrader Price Context[/b] is an open-source market-context indicator that condenses current price behavior into one directional Context Flow state.

[b]How it works[/b]

Context Flow combines several directly observable price characteristics into one composite score:

[list]
[*]candle body participation
[*]close location within the candle
[*]upper/lower wick pressure
[*]price displacement from the center of the Context Ribbon
[*]slope of the ribbon center
[*]relative range normalization
[/list]

The composite score is smoothed and evaluated with a profile-dependent directional threshold. A small hysteresis zone prevents the state from switching repeatedly around neutral conditions.

The result is one persistent directional state:

[list]
[*][b]Bullish[/b] — blue
[*][b]Bearish[/b] — purple
[*][b]Neutral / transition[/b] — gray
[/list]

[b]Context Ribbon[/b]

The ribbon is a smoothed high/low envelope used as visual price context. Its center contributes to Context Flow through displacement and slope and also acts as a directional side filter: bullish state changes require price on or above the ribbon center, while bearish state changes require price on or below it. The ribbon is rendered as a WizTrader-style gradient with a soft center glow.

[b]Signals[/b]

Primary signals are generated only when Context Flow changes directional state. The first 34 bars are reserved as a warm-up period for the longest profile and range normalization.

That creates a naturally alternating sequence:

BUY-side → SELL-side → BUY-side → SELL-side

There are no duplicate same-side primary signals between two opposite state changes.

[b]Signal Side[/b]

[list]
[*][b]Long Only[/b] — Long entries are shown as full-size blue primary markers. The matching long exit remains visible as a smaller purple marker.
[*][b]Short Only[/b] — Short entries are shown as full-size purple primary markers. The matching short exit remains visible as a smaller blue marker.
[*][b]Long & Short[/b] — Both bullish and bearish Context Flow turns are shown as full-size primary markers.
[/list]

Changing Signal Side therefore changes the visible signal presentation and active directional state while the underlying Context Flow calculation remains unchanged.

[b]Profiles[/b]

[list]
[*][b]Responsive[/b] — quicker response and earlier context turns.
[*][b]Balanced[/b] — balanced default.
[*][b]Trend[/b] — slower response designed to stay with larger directional moves.
[/list]

All three profiles use the same Context Flow model. They only change response speed and the directional turn threshold.

[b]Display[/b]

The indicator includes:

[list]
[*]Context Ribbon
[*]compact directional signal markers
[*]optional bar coloring
[*]a compact but readable dashboard with profile, combined direction/strength, active state, next event and current range condition
[/list]

[b]Originality[/b]

Price Context does not combine several named indicators or switch between separate signal engines. Its public logic is built around one composite Context Flow score derived from candle structure, ribbon displacement, ribbon slope and relative range behavior. Directional signals are state-change events from that single model.

[b]Limitations[/b]

WizTrader Price Context reacts to price behavior; it does not predict future price movements.

Historical behavior does not guarantee future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// WizTrader Price Context
//
// Open-source market-context indicator with an intentionally compact public
// signal model.
//
// PUBLIC ENGINE
//   Context Flow = one composite directional state
//   Primary events = state changes only
//   Sequence       = BUY-side → SELL-side → BUY-side → SELL-side ...
//
// IMPORTANT
// No indicator can predict future price movements or guarantee trading results.

//@version=6
indicator("WizTrader Price Context", shorttitle="WizContext", overlay=true, explicit_plot_zorder=true)

// ─────────────────────────────────────────────────────────────────────────────
// WIZTRADER PALETTE
// ─────────────────────────────────────────────────────────────────────────────

color WIZ_BULL    = color.rgb(85, 134, 219)
color WIZ_BEAR    = color.rgb(172, 68, 203)
color WIZ_NEUTRAL = color.rgb(100, 100, 120)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

groupDisplay = "Display"

showRibbon = input.bool(
     true,
     "Context Ribbon",
     tooltip="Shows the visual market-context ribbon. Blue represents bullish context, purple bearish context and gray a neutral state.",
     group=groupDisplay)

showSignals = input.bool(
     true,
     "Signals",
     tooltip="Shows compact mode-aware signals: full-size entries and, in single-direction modes, smaller matching exit markers.",
     group=groupDisplay)

showBarColors = input.bool(
     true,
     "Bar Colors",
     tooltip="Colors candles using the current Context Flow direction.",
     group=groupDisplay)

showDashboard = input.bool(
     true,
     "Dashboard",
     tooltip="Shows a compact summary of profile, direction, strength, active state, next sequence event and current range condition.",
     group=groupDisplay)

dashboardPosition = input.string(
     "Top Right",
     "Dashboard Position",
     options=["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     tooltip="Selects where the dashboard is shown on the chart.",
     group=groupDisplay)

groupSignal = "Signal Behavior"

signalSide = input.string(
     "Long & Short",
     "Signal Side",
     options=["Long & Short", "Long Only", "Short Only"],
     tooltip="Selects the chart signal mode. Long Only shows full-size long entries with smaller matching exits. Short Only shows full-size short entries with smaller matching exits. Long & Short shows both directional turns as full-size primary signals.",
     group=groupSignal)

signalProfile = input.string(
     "Balanced",
     "Profile",
     options=["Responsive", "Balanced", "Trend"],
     tooltip="Controls how quickly Context Flow responds. Responsive reacts earliest, Balanced is the default middle setting, and Trend responds more patiently to larger directional moves.",
     group=groupSignal)

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE CALIBRATION
// ─────────────────────────────────────────────────────────────────────────────
//
// The profiles alter one public Context Flow model. They do not switch between
// different signal engines.
//
// Responsive = shorter response and lower turn threshold.
// Balanced   = balanced default.
// Trend      = slower response and higher turn threshold.

int ribbonResponse =
     signalProfile == "Responsive" ? 13 :
     signalProfile == "Trend" ? 34 :
     21

int flowResponse =
     signalProfile == "Responsive" ? 3 :
     signalProfile == "Trend" ? 7 :
     5

float turnThreshold =
     signalProfile == "Responsive" ? 0.10 :
     signalProfile == "Trend" ? 0.18 :
     0.14

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

clamp(float value, float lower, float upper) =>
    math.max(lower, math.min(upper, value))

dashboardPos(string value) =>
    switch value
        "Top Left"      => position.top_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        => position.top_right

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC CONTEXT RIBBON
// ─────────────────────────────────────────────────────────────────────────────
//
// The ribbon is not a separate signal engine.
// Its center contributes to Context Flow through displacement and slope, and
// also acts as a directional side filter for confirmed state changes.

float ribbonAlpha = 2.0 / (ribbonResponse + 1.0)

var float ribbonHigh = na
var float ribbonLow  = na

float prevRibbonHigh = nz(ribbonHigh[1], high)
float prevRibbonLow  = nz(ribbonLow[1], low)

ribbonHigh := prevRibbonHigh + ribbonAlpha * (high - prevRibbonHigh)
ribbonLow  := prevRibbonLow  + ribbonAlpha * (low  - prevRibbonLow)

float ribbonTop    = ribbonHigh
float ribbonBottom = ribbonLow
float ribbonCenter = math.avg(ribbonTop, ribbonBottom)

// ─────────────────────────────────────────────────────────────────────────────
// CONTEXT FLOW — SINGLE PUBLIC SIGNAL MODEL
// ─────────────────────────────────────────────────────────────────────────────
//
// Context Flow combines:
// • candle body participation
// • close location inside the candle
// • wick pressure
// • displacement from the ribbon center
// • ribbon-center slope
// • mild range normalization
//
// The weighted components feed one composite score.
// A confirmed state change additionally requires price to be on the matching
// side of the ribbon center. This side filter is outside the weighted score.

float candleRange = math.max(high - low, syminfo.mintick)
float candleBody  = math.abs(close - open)
float bodyShare   = candleBody / candleRange

float upperWick = (high - math.max(open, close)) / candleRange
float lowerWick = (math.min(open, close) - low) / candleRange

float candleDirection = close > open ? 1.0 : close < open ? -1.0 : 0.0
float closeLocation   = clamp(((close - low) / candleRange) * 2.0 - 1.0, -1.0, 1.0)
float wickPressure    = clamp(lowerWick - upperWick, -1.0, 1.0)

float candleImpulse =
     candleDirection * bodyShare * 0.50 +
     closeLocation   * 0.32 +
     wickPressure    * 0.18

float atr14 = ta.atr(14)
float atrSafe = na(atr14) or atr14 <= 0.0 ? candleRange : atr14
float trueRange = ta.tr(true)
float rangeRatio = trueRange / atrSafe

float displacement =
     clamp((close - ribbonCenter) / math.max(atrSafe * 1.20, syminfo.mintick), -1.0, 1.0)

float centerSlope =
     clamp((ribbonCenter - nz(ribbonCenter[1], ribbonCenter)) /
          math.max(atrSafe * 0.30, syminfo.mintick), -1.0, 1.0)

float rangeWeight = math.min(0.88 + rangeRatio * 0.12, 1.16)

float flowInput =
     (
          candleImpulse * 0.48 +
          displacement  * 0.34 +
          centerSlope   * 0.18
     ) * rangeWeight

float flowAlpha = 2.0 / (flowResponse + 1.0)

var float flowScore = na
float prevFlowScore = nz(flowScore[1], flowInput)
flowScore := prevFlowScore + flowAlpha * (flowInput - prevFlowScore)

// Hysteresis: the state changes only after the opposite directional threshold
// is actually qualified. Inside the neutral band, the previous state is held.
var int flowState = 0

// Allow the longest public profile and ATR normalization to warm up before
// directional state changes are permitted.
bool engineReady =
     bar_index >= 34 and
     not na(atr14)

bool bullishFlowReady =
     engineReady and
     barstate.isconfirmed and
     flowScore >= turnThreshold and
     close >= ribbonCenter

bool bearishFlowReady =
     engineReady and
     barstate.isconfirmed and
     flowScore <= -turnThreshold and
     close <= ribbonCenter

if bullishFlowReady
    flowState := 1
else if bearishFlowReady
    flowState := -1

bool flowBull = flowState == 1
bool flowBear = flowState == -1

// Primary events are the state changes themselves.
// Because one state can only change to the opposite state, duplicate BUY-side
// or SELL-side primary events cannot occur.
bool buySignal =
     flowBull and
     nz(flowState[1], 0) != 1

bool sellSignal =
     flowBear and
     nz(flowState[1], 0) != -1

// ─────────────────────────────────────────────────────────────────────────────
// MODE-AWARE SIGNAL STATE
// ─────────────────────────────────────────────────────────────────────────────
//
// Context Flow itself is identical in every mode.
// Signal Side controls how those flow turns are interpreted and displayed:
//
// Long Only:
//   BUY-side  = long entry
//   SELL-side = long exit
//
// Short Only:
//   SELL-side = short entry
//   BUY-side  = short exit
//
// Long & Short:
//   BUY-side  = long / bullish turn
//   SELL-side = short / bearish turn
//
// A mode never prints an entry for a direction that is disabled.

const int STATE_FLAT  = 0
const int STATE_LONG  = 1
const int STATE_SHORT = -1

var int signalState = STATE_FLAT

bool modeLong  = signalSide == "Long Only"
bool modeShort = signalSide == "Short Only"

bool longEntrySignal  = false
bool longExitSignal   = false
bool shortEntrySignal = false
bool shortExitSignal  = false
bool dualBuySignal    = false
bool dualSellSignal   = false

if modeLong
    if buySignal and signalState != STATE_LONG
        longEntrySignal := true
        signalState := STATE_LONG
    else if sellSignal and signalState == STATE_LONG
        longExitSignal := true
        signalState := STATE_FLAT

else if modeShort
    if sellSignal and signalState != STATE_SHORT
        shortEntrySignal := true
        signalState := STATE_SHORT
    else if buySignal and signalState == STATE_SHORT
        shortExitSignal := true
        signalState := STATE_FLAT

else
    if buySignal
        dualBuySignal := true
        signalState := STATE_LONG
    else if sellSignal
        dualSellSignal := true
        signalState := STATE_SHORT

// User-facing aggregate events.
// These are mode-aware and therefore change when Signal Side changes.
bool visibleBuySignal =
     dualBuySignal or
     longEntrySignal or
     shortExitSignal

bool visibleSellSignal =
     dualSellSignal or
     shortEntrySignal or
     longExitSignal

// ─────────────────────────────────────────────────────────────────────────────
// DISPLAY CONTEXT
// ─────────────────────────────────────────────────────────────────────────────

color regimeColor =
     flowBull ? WIZ_BULL :
     flowBear ? WIZ_BEAR :
     WIZ_NEUTRAL

string directionText =
     flowBull ? "Bullish" :
     flowBear ? "Bearish" :
     "Neutral"

// Dashboard values stay aligned with the last confirmed directional state on
// a live bar instead of jumping with intrabar range/score changes.
float flowScoreShown =
     barstate.isconfirmed
     ? flowScore
     : nz(flowScore[1], flowScore)

float rangeRatioShown =
     barstate.isconfirmed
     ? rangeRatio
     : nz(rangeRatio[1], rangeRatio)

float alignedFlow = flowScoreShown * flowState

string strengthText =
     flowState == 0                      ? "Soft" :
     alignedFlow >= turnThreshold * 2.00 ? "Strong" :
     alignedFlow >= turnThreshold        ? "Active" :
     alignedFlow >= 0.0                  ? "Soft" :
     "Fading"

color strengthColor =
     strengthText == "Fading"
     ? WIZ_NEUTRAL
     : regimeColor

string rangeText =
     rangeRatioShown >= 1.35 ? "Expanded" :
     rangeRatioShown <= 0.75 ? "Compressed" :
     "Normal"

// ─────────────────────────────────────────────────────────────────────────────
// WIZTRADER VISUAL STATE
// ─────────────────────────────────────────────────────────────────────────────
//
// Rendering only. Nothing in this section changes the signal engine.
//
// Visual hierarchy:
// 1. Context ribbon
// 2. Primary alternating signal markers

float wizBgLuma =
     (
          color.r(chart.bg_color) * 0.299 +
          color.g(chart.bg_color) * 0.587 +
          color.b(chart.bg_color) * 0.114
     ) / 255.0

bool wizDarkBackground = wizBgLuma < 0.50

int wizBarTransparency = wizDarkBackground ? 18 : 36

barcolor(
     showBarColors ? color.new(regimeColor, wizBarTransparency) : na,
     title="WizTrader Price Context")

// ─────────────────────────────────────────────────────────────────────────────
// CONTEXT RIBBON — WIZ STYLE
// ─────────────────────────────────────────────────────────────────────────────

float wizRibbonWidth = math.max(ribbonTop - ribbonBottom, 0.0)

float wizRibbonSpreadStrength =
     clamp(wizRibbonWidth / (atrSafe * 1.60), 0.0, 1.0)

int wizRibbonEdgeTransparency = int(
     wizDarkBackground
     ? 74.0 - wizRibbonSpreadStrength * 22.0
     : 88.0 - wizRibbonSpreadStrength * 10.0)

int wizRibbonFadeTransparency =
     wizDarkBackground ? 95 : 98

int wizRibbonNeutralEdge =
     wizDarkBackground ? 84 : 92

int wizRibbonNeutralFade =
     wizDarkBackground ? 97 : 99

color wizRibbonTopColor =
     not showRibbon
     ? na
     : flowBull
     ? color.new(WIZ_BULL, wizRibbonEdgeTransparency)
     : flowBear
     ? color.new(WIZ_BEAR, wizRibbonFadeTransparency)
     : color.new(WIZ_NEUTRAL, wizRibbonNeutralEdge)

color wizRibbonBottomColor =
     not showRibbon
     ? na
     : flowBull
     ? color.new(WIZ_BULL, wizRibbonFadeTransparency)
     : flowBear
     ? color.new(WIZ_BEAR, wizRibbonEdgeTransparency)
     : color.new(WIZ_NEUTRAL, wizRibbonNeutralFade)

wizRibbonTopAnchor = plot(
     showRibbon ? ribbonTop : na,
     "WizTrader Context Top Anchor",
     color=na,
     linewidth=1,
     style=plot.style_linebr,
     editable=false)

wizRibbonBottomAnchor = plot(
     showRibbon ? ribbonBottom : na,
     "WizTrader Context Bottom Anchor",
     color=na,
     linewidth=1,
     style=plot.style_linebr,
     editable=false)

fill(
     wizRibbonTopAnchor,
     wizRibbonBottomAnchor,
     ribbonTop,
     ribbonBottom,
     wizRibbonTopColor,
     wizRibbonBottomColor,
     title="WizTrader Context Ribbon Gradient",
     editable=false)

// Soft outer rails.
plot(
     showRibbon ? ribbonTop : na,
     "WizTrader Context Upper Edge",
     color=color.new(
          regimeColor,
          wizDarkBackground ? 84 : 92),
     linewidth=1,
     style=plot.style_linebr,
     editable=false)

plot(
     showRibbon ? ribbonBottom : na,
     "WizTrader Context Lower Edge",
     color=color.new(
          regimeColor,
          wizDarkBackground ? 88 : 94),
     linewidth=1,
     style=plot.style_linebr,
     editable=false)

// Center flow: soft glow + crisp core.
plot(
     showRibbon ? ribbonCenter : na,
     "WizTrader Context Flow Glow",
     color=color.new(
          regimeColor,
          wizDarkBackground ? 80 : 91),
     linewidth=4,
     style=plot.style_linebr,
     editable=false)

plot(
     showRibbon ? ribbonCenter : na,
     "WizTrader Context Flow",
     color=color.new(
          regimeColor,
          wizDarkBackground ? 28 : 40),
     linewidth=2,
     style=plot.style_linebr,
     editable=false)

// ─────────────────────────────────────────────────────────────────────────────
// PRIMARY SIGNALS
// ─────────────────────────────────────────────────────────────────────────────
//
// Long & Short: both directional turns are full primary markers.
// Long Only / Short Only: entries remain full primary markers while the matching
// exit is deliberately smaller. This makes the selected mode immediately visible
// on the chart without hiding the exit event.

// LONG & SHORT
plotshape(
     showSignals and dualBuySignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(WIZ_BULL, 8),
     text="▲",
     textcolor=color.white,
     size=size.small,
     editable=false)

plotshape(
     showSignals and dualSellSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(WIZ_BEAR, 8),
     text="▼",
     textcolor=color.white,
     size=size.small,
     editable=false)

// LONG ONLY
plotshape(
     showSignals and longEntrySignal,
     title="Long Entry",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(WIZ_BULL, 8),
     text="▲",
     textcolor=color.white,
     size=size.small,
     editable=false)

plotshape(
     showSignals and longExitSignal,
     title="Long Exit",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(WIZ_BEAR, 28),
     size=size.tiny,
     editable=false)

// SHORT ONLY
plotshape(
     showSignals and shortEntrySignal,
     title="Short Entry",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(WIZ_BEAR, 8),
     text="▼",
     textcolor=color.white,
     size=size.small,
     editable=false)

plotshape(
     showSignals and shortExitSignal,
     title="Short Exit",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(WIZ_BULL, 28),
     size=size.tiny,
     editable=false)

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
//
// Compact 2 x 5 layout with medium readability.
// Position is applied explicitly on the last bar so the dropdown always controls
// the table location.

var table dashboard = table.new(
     position.top_right,
     2,
     5,
     border_width=0,
     frame_width=1,
     frame_color=color.new(WIZ_NEUTRAL, 66))

if barstate.islast
    table.set_position(dashboard, dashboardPos(dashboardPosition))

    if showDashboard
        string stateText =
             signalState == STATE_LONG ? "Long Active" :
             signalState == STATE_SHORT ? "Short Active" :
             "Flat"

        color stateColor =
             signalState == STATE_LONG ? WIZ_BULL :
             signalState == STATE_SHORT ? WIZ_BEAR :
             WIZ_NEUTRAL

        string sequenceText =
             modeLong
             ? (flowState == 1 ? "Exit Next" : flowState == -1 ? "Entry Next" : "Open")
             : modeShort
             ? (flowState == -1 ? "Exit Next" : flowState == 1 ? "Entry Next" : "Open")
             : flowState == 1
             ? "SELL Next"
             : flowState == -1
             ? "BUY Next"
             : "Open"

        color sequenceColor =
             flowState == 1 ? WIZ_BEAR :
             flowState == -1 ? WIZ_BULL :
             WIZ_NEUTRAL

        string contextText = directionText + " · " + strengthText

        table.cell(
             dashboard, 0, 0, "PRICE CONTEXT",
             text_color=color.white,
             text_size=size.small,
             bgcolor=color.new(regimeColor, wizDarkBackground ? 42 : 54))

        table.cell(
             dashboard, 1, 0, signalProfile,
             text_color=color.white,
             text_size=size.small,
             bgcolor=color.new(regimeColor, wizDarkBackground ? 42 : 54))

        table.cell(
             dashboard, 0, 1, "Context",
             text_color=color.white,
             text_size=size.small,
             bgcolor=color.new(WIZ_NEUTRAL, 64))

        table.cell(
             dashboard, 1, 1, contextText,
             text_color=color.white,
             text_size=size.small,
             bgcolor=color.new(strengthColor, 34))

        table.cell(
             dashboard, 0, 2, "State",
             text_color=color.white,
             text_size=size.small,
             bgcolor=color.new(WIZ_NEUTRAL, 64))

        table.cell(
             dashboard, 1, 2, stateText,
             text_color=color.white,
             text_size=size.small,
             bgcolor=color.new(stateColor, 26))

        table.cell(
             dashboard, 0, 3, "Next",
             text_color=color.white,
             text_size=size.small,
             bgcolor=color.new(WIZ_NEUTRAL, 64))

        table.cell(
             dashboard, 1, 3, sequenceText,
             text_color=color.white,
             text_size=size.small,
             bgcolor=color.new(sequenceColor, 32))

        table.cell(
             dashboard, 0, 4, "Range",
             text_color=color.white,
             text_size=size.small,
             bgcolor=color.new(WIZ_NEUTRAL, 64))

        table.cell(
             dashboard, 1, 4, rangeText,
             text_color=color.white,
             text_size=size.small,
             bgcolor=color.new(regimeColor, 44))

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
//
// Two groups:
//
// 1. Mode-independent alerts ("Any ...").
//    These follow whatever is visible on the chart in the selected Signal Side
//    and work in every mode. Use these if unsure.
//
// 2. Mode-specific alerts.
//    Each one fires only in the mode named in its title. In any other mode it
//    stays silent.

// 1. MODE-INDEPENDENT
alertcondition(
     visibleBuySignal,
     "Any BUY-side Signal (all modes)",
     "WizTrader Price Context: BUY-side signal confirmed (bullish turn, long entry or short exit, depending on Signal Side).")

alertcondition(
     visibleSellSignal,
     "Any SELL-side Signal (all modes)",
     "WizTrader Price Context: SELL-side signal confirmed (bearish turn, short entry or long exit, depending on Signal Side).")

alertcondition(
     visibleBuySignal or visibleSellSignal,
     "Any Signal (all modes)",
     "WizTrader Price Context: new signal confirmed. Check the chart for direction.")

// 2. MODE-SPECIFIC
alertcondition(
     dualBuySignal,
     "BUY (Long & Short mode)",
     "WizTrader Price Context: bullish context turn confirmed.")

alertcondition(
     dualSellSignal,
     "SELL (Long & Short mode)",
     "WizTrader Price Context: bearish context turn confirmed.")

alertcondition(
     longEntrySignal,
     "Long Entry (Long Only mode)",
     "WizTrader Price Context: Long Only entry confirmed.")

alertcondition(
     longExitSignal,
     "Long Exit (Long Only mode)",
     "WizTrader Price Context: Long Only exit confirmed.")

alertcondition(
     shortEntrySignal,
     "Short Entry (Short Only mode)",
     "WizTrader Price Context: Short Only entry confirmed.")

alertcondition(
     shortExitSignal,
     "Short Exit (Short Only mode)",
     "WizTrader Price Context: Short Only exit confirmed.")
````
