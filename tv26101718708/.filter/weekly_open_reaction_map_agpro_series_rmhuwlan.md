# Weekly Open Reaction Map [AGPro Series]

- url: https://www.tradingview.com/script/rmHuWlAn-Weekly-Open-Reaction-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;ed8e705a5f404f439637001420beffe2
- version: 3.0

## Description

Weekly Open Reaction Map [AGPro Series]

🔹 OVERVIEW

Weekly Open Reaction Map [AGPro Series] is a focused weekly open overlay built for traders who use the current weekly open as a higher-timeframe anchor.

The weekly open is one of the simplest and most widely watched reference levels on a chart. Many traders mark it manually, but a plain horizontal line does not show whether price is accepting above it, losing it, reclaiming it, or repeatedly reacting through the same area. This script turns the weekly open into a structured reaction map.

The script plots the current weekly open, builds an adaptive reaction band around it, detects accepted behavior above or below the level, marks selective reclaim and loss events, and summarizes the active state in a compact dashboard.

The goal is clarity:

How is price reacting around the current weekly open?

This is not a broad level engine. It is not a full weekly range dashboard. It is not a prior high or prior low tool. It is not a session-open model. It is a single-anchor weekly open reaction framework designed to keep the chart clean while adding practical context.


🔹 WHAT MAKES IT DIFFERENT

Weekly Open Reaction Map is built around one level only: the current weekly open.

Instead of plotting a large set of reference prices, the script focuses all of its logic on the active weekly open and asks whether price is above it, below it, reclaiming it, losing it, or still testing the reaction area.

Key differentiators:

• Single-anchor design centered only on the current weekly open
• Adaptive reaction band instead of a fragile one-tick line
• Acceptance-side model using sustained closes beyond the band
• Reclaim and loss labels designed to stay selective by default
• Concept-native rectangular reaction zones around confirmed weekly open behavior
• Compact panel showing distance, acceptance side, active-week reaction count, weekly bias, and last event
• Cleaner default visual mode tuned for 1H, 4H, and 1D public-chart presentation
• Optional initial acceptance events for users who want more context

The script is intentionally restrained. It does not try to become a full market structure suite. Its value comes from making one simple, popular, and highly searchable level more readable.


🧭 WHY THIS DOES NOT OVERLAP WITH OTHER AGPRO TOOLS

This script was designed to stay separate from existing AGPro public concepts.

It does not overlap with Daily Open Acceptance Map because this script does not reset around the daily open. The weekly open carries context across several trading days, so the logic is built around a multi-day weekly anchor rather than an intraday daily reference.

It does not overlap with Reference Price Operating Map because this script does not compare multiple reference prices. There is no multi-reference framework here. The weekly open is the only operating level.

It does not overlap with Session Reaction Map because this script does not evaluate Asia, London, New York, or session-start behavior. It continuously follows the active week and reads how price behaves around the weekly open over time.

It does not overlap with PDH PDL PWH PWL Engine because this script does not plot previous day highs, previous day lows, previous week highs, previous week lows, or active range corridors. It avoids becoming a prior-period high/low engine.

It does not overlap with generic support and resistance scripts because its boxes are not derived from swing pivots, historical ranges, or broad supply-demand zones. The reaction zones exist only when weekly open behavior is confirmed.

The scope is narrow by design:

Current weekly open.
Acceptance.
Reclaim.
Loss.
Reaction zones.
Weekly bias.


⚙️ METHODOLOGY

The script reads the current weekly open from the weekly timeframe and projects it onto the active chart.

Around that weekly open, it builds a reaction band. This prevents the script from treating the weekly open as an unrealistically perfect single price. The band can be sized by:

• ATR for volatility-adjusted behavior
• Percent for proportional market structure
• Ticks for fixed instrument precision

The acceptance model checks whether price can sustain closes beyond the reaction band. A single close is not enough by default. The user can define how many consecutive closes are required before the script recognizes accepted behavior.

The engine then tracks which side of the weekly open has been established during the active week.

A weekly open reclaim is detected when price had already traded below the weekly open context and then confirms acceptance back above the level after a recent band interaction.

A weekly open loss is detected when price had already traded above the weekly open context and then confirms acceptance below the level after a recent band interaction.

Optional initial acceptance events can also be enabled. These show which side of the weekly open became dominant first after a new week begins. They are disabled by default so the public chart remains cleaner and more focused on reclaim/loss transitions.

Confirmed events can create rectangular reaction zones. These zones preserve the weekly open area where the reaction was confirmed and project it forward for context. They are concept-native zones, not generic support/resistance boxes.


📊 PANEL

The panel gives a fast read of the active weekly open condition.

Distance
Shows how far current price is from the weekly open, including a percent reading.

Acceptance Side
Shows whether price is accepted above the weekly open, accepted below it, or still testing the weekly open band.

Reaction Count
Counts confirmed weekly open reactions for the active week. The panel uses active-week logic, while visual label limits keep historical charts clean.

Weekly Bias
Summarizes the current weekly open state as Bullish Control, Bearish Control, or Neutral Test.

Last Event
Shows the latest confirmed weekly open event, such as WO Reclaim, WO Loss, WO Accept +, or WO Accept -.

The panel includes adjustable location, theme, and font size controls. The first panel row follows the AGPro standard: a single merged blue header row containing only the script name.


🎛️ KEY INPUTS

Show Weekly Open Line
Controls whether the current weekly open line is displayed.

Weekly Open Line Width
Controls the visual weight of the weekly open reference line.

Reaction Band Width Mode
Choose ATR, Percent, or Ticks to define the width of the weekly open reaction area.

ATR Width Multiplier
Controls volatility-adjusted band width when ATR mode is selected.

Percent Width
Controls proportional band width when Percent mode is selected.

Tick Width
Controls fixed band width when Ticks mode is selected.

Acceptance Confirmation Bars
Defines how many consecutive closes are required before price is treated as accepted above or below the weekly open band.

Recent Touch Window
Requires confirmed events to occur near a recent weekly open band interaction.

Show Active Weekly Open Band
Displays the live weekly open reaction corridor.

Show Confirmed Reaction Zones
Draws extended boxes around confirmed weekly open reclaim, loss, or optional initial acceptance behavior.

Reaction Zone Extension Bars
Controls how far confirmed weekly open reaction zones project forward.

Maximum Reaction Zones
Limits the number of historical zones shown on the chart.

Show Reclaim / Loss Labels
Displays selective weekly open reclaim and loss labels.

Show Initial Acceptance Events
Allows first-side weekly open acceptance events to create labels and zones. Disabled by default for a cleaner public view.

Minimum Bars Between Labels
Controls cross-week spacing between event labels, helping avoid historical label clusters.

Maximum Event Labels
Limits visible historical event labels for a cleaner chart.

Label Offset ATR
Moves labels away from candles so they stay readable.

Label Font Size
Controls event label size. Normal is the default.

Panel Location
Moves the dashboard to the preferred chart location.

Panel Theme
Selects Dark, Light, or Auto panel styling.

Panel Font Size
Controls dashboard text size. Normal is the default.


🔍 HOW TO READ IT

Start with the weekly open line.

If price is above the line and the panel shows Above WO, the market is currently accepting above the weekly open band.

If price is below the line and the panel shows Below WO, the market is currently accepting below the weekly open band.

If the panel shows Testing WO, price is still close enough to the reaction band that the weekly open has not resolved clearly.

WO Reclaim
This label means price previously moved below the weekly open context and later confirmed acceptance back above it.

WO Loss
This label means price previously held above the weekly open context and later confirmed acceptance below it.

Reaction Zones
These boxes highlight the weekly open area where a confirmed reaction occurred. They can act as visual memory zones for later retests, pauses, or renewed pressure around the same weekly anchor.

Weekly Bias
The bias reading is not a standalone trade call. It is a context label that tells whether the active week is currently being controlled above the weekly open, below the weekly open, or still near the test area.

Reaction Count
This helps identify whether the week has been clean and directional or has already produced several confirmed weekly open reactions.


🧩 BEST USE CASES

Weekly open context
Use the script to understand whether the active week is being accepted above or below its opening level.

Reclaim tracking
Use WO Reclaim labels to identify when price regains the weekly open after trading below it.

Loss tracking
Use WO Loss labels to identify when price gives up the weekly open after previously holding above it.

Multi-timeframe planning
Use the weekly open as a higher-timeframe anchor while viewing 1H, 4H, or 1D charts.

Clean chart workflow
Use the script when you want one important weekly reference instead of a crowded stack of levels.

Reaction-zone review
Use projected boxes to remember where meaningful weekly open reactions were confirmed.

Public chart publishing
Use the default settings for cleaner TradingView screenshots and a more premium chart layout.


🧠 VISUAL DESIGN PHILOSOPHY

The design philosophy is premium restraint.

The weekly open should be easy to identify, but it should not dominate the chart. Labels should be useful, but not constant. Zones should preserve meaningful reaction areas, but not turn the screen into a grid of boxes.

The default settings are intentionally cleaner:

• Initial acceptance events are off by default
• Reclaim and loss behavior remains the primary visible story
• Label spacing works across weeks, not only inside one week
• Historical label and zone limits are conservative
• The panel uses a compact AGPro dashboard style
• The active weekly open band is visible without overwhelming candles

This helps the script remain practical on 1H, 4H, and 1D views while still giving the chart enough structure to feel complete.


🔔 ALERTS

The script includes alert conditions for key weekly open events:

Weekly Open Reclaim
Triggers when price confirms a reclaim of the weekly open after previously trading below the weekly open context.

Weekly Open Loss
Triggers when price confirms a loss of the weekly open after previously trading above the weekly open context.

Weekly Open Accepted Above
Triggers when price confirms acceptance above the weekly open band.

Weekly Open Accepted Below
Triggers when price confirms acceptance below the weekly open band.

These alerts are designed for context awareness around the weekly open. They are not intended to replace a complete trading plan or broader market review.


🔹 LIMITATIONS AND TRANSPARENCY

Weekly Open Reaction Map is intentionally focused on one reference level. It does not attempt to map every support/resistance area on the chart.

The script does not include previous day highs, previous day lows, previous week highs, previous week lows, session opens, daily opens, volume profile levels, swing pivots, or order-flow data.

Because the weekly open can behave differently across assets and timeframes, users may need to adjust the reaction band width, confirmation bars, and label spacing for their market.

On very low timeframes, labels can appear more frequently if sensitivity is increased. On higher timeframes, fewer but more meaningful events are expected.

The weekly bias panel is a context tool. It describes the current relationship between price and the weekly open; it does not predict future price movement.

The script is built to stay clean, transparent, and focused. Its strength is not feature volume. Its strength is making one widely used weekly reference level easier to read.


✅ IDEAL USER

This script is ideal for traders who:

• Use the weekly open as a key higher-timeframe reference
• Want a cleaner way to read weekly open acceptance, reclaim, and loss
• Prefer focused tools over crowded multi-level dashboards
• Trade crypto, forex, indices, or liquid stocks where the weekly open is actively watched
• Use 1H, 4H, or 1D charts for market context
• Want reaction zones without turning the chart into a generic support/resistance map
• Publish or review TradingView charts and need a clean visual presentation
• Prefer structured context over excessive labels and visual noise

Weekly Open Reaction Map [AGPro Series] is built for traders who want the weekly open to become more than a line. It turns that level into a readable acceptance and reaction framework while keeping the chart professional, restrained, and publication-ready.

## Source Code

````pine
// -------------------------------------------------
// Weekly Open Reaction Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.1
//
// Weekly Open Reaction Map tracks the current weekly open as a clean higher-timeframe
// anchor, then maps acceptance, reclaim, loss, and reaction-zone behavior around that
// level. The script focuses on weekly open trading context, weekly bias, reclaim labels,
// loss labels, and adaptive reaction zones without becoming a multi-level high/low engine.
// A cumulative Reaction Edge engine measures, on this chart and timeframe, how often
// confirmed reclaim and loss events actually traveled a full ATR before closing back
// through their own weekly open, and a clear next-action line turns the reaction map
// into a decision tool.
// -------------------------------------------------

//@version=6
indicator("Weekly Open Reaction Map [AGPro Series]",
     shorttitle = "AG Pro WOR",
     overlay = true,
     max_lines_count = 20,
     max_labels_count = 100,
     max_boxes_count = 80)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)
color headerText    = color.rgb(245, 247, 250)
color panelBg       = color.rgb(15, 23, 42)
color panelBorder   = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor     = color.rgb(34, 197, 166)
color bearColor     = color.rgb(244, 114, 182)
color neutralColor  = color.rgb(245, 189, 92)
color accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
const string GROUP_CORE = "Weekly Open"
const string GROUP_LOGIC = "Acceptance Logic"
const string GROUP_ZONES = "Reaction Zones"
const string GROUP_LABELS = "Labels"
const string GROUP_PANEL = "Panel"
const string GROUP_ALERTS = "Alerts"

bool showWeeklyOpenLine = input.bool(true, "Show Weekly Open Line", group = GROUP_CORE,
     tooltip = "Displays the current weekly open as the primary higher-timeframe anchor.")
int openLineWidth = input.int(2, "Weekly Open Line Width", minval = 1, maxval = 4, group = GROUP_CORE,
     tooltip = "Controls the visual weight of the weekly open reference line.")

int atrLength = input.int(14, "ATR Length", minval = 1, group = GROUP_LOGIC,
     tooltip = "ATR length used for adaptive reaction-band width and label spacing.")
string bandMode = input.string("ATR", "Reaction Band Width Mode", options = ["ATR", "Percent", "Ticks"], group = GROUP_LOGIC,
     tooltip = "Selects how the weekly open reaction band is sized around the weekly open.")
float bandAtrMult = input.float(0.18, "ATR Width Multiplier", minval = 0.01, step = 0.01, group = GROUP_LOGIC,
     tooltip = "ATR-based half-width of the weekly open reaction band when ATR mode is selected.")
float bandPercent = input.float(0.10, "Percent Width", minval = 0.01, step = 0.01, group = GROUP_LOGIC,
     tooltip = "Percent-based half-width of the weekly open reaction band when Percent mode is selected.")
int bandTicks = input.int(40, "Tick Width", minval = 1, group = GROUP_LOGIC,
     tooltip = "Tick-based half-width of the weekly open reaction band when Ticks mode is selected.")
int confirmBars = input.int(3, "Acceptance Confirmation Bars", minval = 1, maxval = 10, group = GROUP_LOGIC,
     tooltip = "Number of consecutive closes required beyond the weekly open reaction band before acceptance is confirmed.")
int recentTouchWindow = input.int(18, "Recent Touch Window", minval = 1, maxval = 200, group = GROUP_LOGIC,
     tooltip = "Maximum bars allowed between a weekly open band interaction and a confirmed acceptance event.")
float edgeTargetAtr = input.float(1.0, "Reaction Edge Target ATR", minval = 0.25, maxval = 5.0, step = 0.25, group = GROUP_LOGIC,
     tooltip = "Distance, in ATR from the event close, that price must travel in the event direction for the Reaction Edge statistic to count a reclaim or loss as a hit.")
int edgeWindow = input.int(40, "Reaction Edge Window", minval = 5, maxval = 300, group = GROUP_LOGIC,
     tooltip = "Maximum number of bars a Reaction Edge episode may stay open. If neither the target nor a close back through the frozen weekly open band is reached inside this window, the episode counts as a miss.")

bool showReactionBand = input.bool(true, "Show Active Weekly Open Band", group = GROUP_ZONES,
     tooltip = "Shows the active weekly open reaction corridor around the current weekly open.")
bool showReactionZones = input.bool(true, "Show Confirmed Reaction Zones", group = GROUP_ZONES,
     tooltip = "Draws extended boxes around the weekly open when acceptance, reclaim, or loss behavior is confirmed.")
int zoneExtendBars = input.int(48, "Reaction Zone Extension Bars", minval = 10, maxval = 500, group = GROUP_ZONES,
     tooltip = "Number of bars each confirmed weekly open reaction zone projects forward.")
int maxReactionZones = input.int(5, "Maximum Reaction Zones", minval = 1, maxval = 40, group = GROUP_ZONES,
     tooltip = "Limits historical weekly open reaction boxes to keep the chart clean and responsive.")
int zoneTransparency = input.int(88, "Zone Transparency", minval = 60, maxval = 95, group = GROUP_ZONES,
     tooltip = "Controls the opacity of weekly open reaction zones.")

bool showEventLabels = input.bool(true, "Show Reclaim / Loss Labels", group = GROUP_LABELS,
     tooltip = "Displays confirmed weekly open reclaim and loss labels with controlled density.")
bool showInitialAcceptanceEvents = input.bool(false, "Show Initial Acceptance Events", group = GROUP_LABELS,
     tooltip = "Allows first-side weekly open acceptance events to create labels and zones. Disabled by default for a cleaner public chart focused on reclaim and loss behavior.")
int labelCooldownBars = input.int(48, "Minimum Bars Between Labels", minval = 0, maxval = 200, group = GROUP_LABELS,
     tooltip = "Minimum cross-week spacing between weekly open event labels to prevent label clusters on higher timeframes.")
int maxEventLabels = input.int(10, "Maximum Event Labels", minval = 1, maxval = 80, group = GROUP_LABELS,
     tooltip = "Limits the number of visible event labels for a cleaner publication-ready chart.")
float labelOffsetAtr = input.float(0.30, "Label Offset ATR", minval = 0.05, step = 0.05, group = GROUP_LABELS,
     tooltip = "Moves labels away from candles using ATR so reclaim and loss labels remain readable.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_LABELS,
     tooltip = "Controls the size of weekly open event labels. Normal is the default publication setting.")

bool showPanel = input.bool(true, "Show Panel", group = GROUP_PANEL,
     tooltip = "Displays a compact weekly open dashboard with distance, acceptance side, reaction count, weekly bias, and reaction proof.")
string panelLocation = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = GROUP_PANEL,
     tooltip = "Selects where the weekly open reaction panel appears on the chart.")
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light", "Auto"], group = GROUP_PANEL,
     tooltip = "Controls panel colors. Auto adapts to the chart background when possible.")
string panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_PANEL,
     tooltip = "Controls dashboard text size. Normal is the default publication setting.")

string alertConfirmation = input.string("Bar Close", "Alert Confirmation", options = ["Bar Close", "Live Updating"], group = GROUP_ALERTS,
     tooltip = "Bar Close waits for a confirmed candle before alerts can trigger. Live Updating allows intrabar attention markers.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string selected) =>
    if selected == "Tiny"
        size.tiny
    else if selected == "Small"
        size.small
    else if selected == "Large"
        size.large
    else
        size.normal

f_panel_position(string selected) =>
    if selected == "Top Left"
        position.top_left
    else if selected == "Bottom Right"
        position.bottom_right
    else if selected == "Bottom Left"
        position.bottom_left
    else if selected == "Middle Right"
        position.middle_right
    else
        position.top_right

f_is_light_chart() =>
    float brightness = color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)
    brightness > 382.5

f_panel_bg(string selected) =>
    if selected == "Light"
        color.rgb(248, 250, 252)
    else if selected == "Auto" and f_is_light_chart()
        color.rgb(248, 250, 252)
    else
        panelBg

f_panel_border(string selected) =>
    if selected == "Light"
        color.rgb(203, 213, 225)
    else if selected == "Auto" and f_is_light_chart()
        color.rgb(203, 213, 225)
    else
        panelBorder

f_panel_label(string selected) =>
    if selected == "Light"
        color.rgb(71, 85, 105)
    else if selected == "Auto" and f_is_light_chart()
        color.rgb(71, 85, 105)
    else
        panelLabelCol

f_panel_value(string selected) =>
    if selected == "Light"
        color.rgb(15, 23, 42)
    else if selected == "Auto" and f_is_light_chart()
        color.rgb(15, 23, 42)
    else
        panelValueCol

f_state_color(bool acceptedAbove, bool acceptedBelow) =>
    if acceptedAbove
        bullColor
    else if acceptedBelow
        bearColor
    else
        neutralColor

// Reaction Edge display helpers. Color follows the same rounded rate
// shown in the panel text, and is applied only once the sample is
// sufficient (n >= 8); below that the value stays neutral so a small
// sample never implies confidence.
f_reText(int _w, int _n) =>
    _n > 0 ? str.tostring(math.round(100.0 * _w / _n)) + "%  (n=" + str.tostring(_n) + ")" : "-  (n=0)"

f_reColor(int _w, int _n, color _fb) =>
    _r = _n > 0 ? math.round(100.0 * _w / _n) : 0
    _n >= 8 ? (_r >= 55 ? bullColor : _r >= 40 ? neutralColor : bearColor) : _fb

// -------------------------------------------------
// Core Weekly Open Engine
// -------------------------------------------------
float weeklyOpen = request.security(syminfo.tickerid, "W", open, barmerge.gaps_off, barmerge.lookahead_on)
bool newWeek = timeframe.change("W") or barstate.isfirst
float atrValue = ta.atr(atrLength)

float rawBandHalf = na
if bandMode == "ATR"
    rawBandHalf := atrValue * bandAtrMult
else if bandMode == "Percent"
    rawBandHalf := math.abs(weeklyOpen) * bandPercent * 0.01
else
    rawBandHalf := syminfo.mintick * bandTicks

float bandHalf = math.max(nz(rawBandHalf, syminfo.mintick), syminfo.mintick)
bool validWeeklyOpen = not na(weeklyOpen)
bool alertBarOk = alertConfirmation == "Live Updating" or barstate.isconfirmed
bool aboveOpen = validWeeklyOpen and close > weeklyOpen + bandHalf
bool belowOpen = validWeeklyOpen and close < weeklyOpen - bandHalf
bool touchingBand = validWeeklyOpen and low <= weeklyOpen + bandHalf and high >= weeklyOpen - bandHalf
int barsSinceTouch = nz(ta.barssince(touchingBand), 100000)
bool recentTouch = barsSinceTouch <= recentTouchWindow

var int aboveStreak = 0
var int belowStreak = 0
if newWeek
    aboveStreak := aboveOpen ? 1 : 0
    belowStreak := belowOpen ? 1 : 0
else
    aboveStreak := aboveOpen ? aboveStreak + 1 : 0
    belowStreak := belowOpen ? belowStreak + 1 : 0

bool acceptedAbove = aboveStreak >= confirmBars
bool acceptedBelow = belowStreak >= confirmBars
bool newAcceptedAbove = not newWeek and acceptedAbove and not (acceptedAbove[1] == true)
bool newAcceptedBelow = not newWeek and acceptedBelow and not (acceptedBelow[1] == true)

var bool weekHadAbove = false
var bool weekHadBelow = false
var int reactionsThisWeek = 0
var int lastEventBar = na
var string lastEvent = "Waiting"
var bool currentWeekHasReactionZone = false

if newWeek
    weekHadAbove := false
    weekHadBelow := false
    reactionsThisWeek := 0
    lastEvent := "New Week"
    currentWeekHasReactionZone := false

bool weekHadAboveBefore = weekHadAbove
bool weekHadBelowBefore = weekHadBelow

bool reclaimEvent = newAcceptedAbove and weekHadBelowBefore and recentTouch
bool lossEvent = newAcceptedBelow and weekHadAboveBefore and recentTouch
bool initialAcceptAboveRaw = newAcceptedAbove and not weekHadBelowBefore and recentTouch
bool initialAcceptBelowRaw = newAcceptedBelow and not weekHadAboveBefore and recentTouch
bool initialAcceptAbove = showInitialAcceptanceEvents and initialAcceptAboveRaw
bool initialAcceptBelow = showInitialAcceptanceEvents and initialAcceptBelowRaw
bool reactionEvent = reclaimEvent or lossEvent or initialAcceptAbove or initialAcceptBelow
bool canPrintEvent = reactionEvent and (na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars)
bool bullishEvent = reclaimEvent or initialAcceptAbove
string eventText = reclaimEvent ? "WO Reclaim" : lossEvent ? "WO Loss" : initialAcceptAbove ? "WO Accept +" : initialAcceptBelow ? "WO Accept -" : "Waiting"

if reactionEvent
    reactionsThisWeek += 1
    lastEvent := eventText

if aboveOpen
    weekHadAbove := true
if belowOpen
    weekHadBelow := true

string acceptanceSide = acceptedAbove ? "Above WO" : acceptedBelow ? "Below WO" : "Testing WO"
color currentStateColor = f_state_color(acceptedAbove, acceptedBelow)

// -------------------------------------------------
// REACTION EDGE ENGINE (cumulative, non-repaint)
// Every confirmed reclaim or loss event opens one tracking episode with
// the event close, ATR, weekly open, and band half-width frozen at the
// event bar. The episode resolves as a HIT when price travels the
// Reaction Edge Target distance in the event direction, and as a MISS
// when price closes back through the frozen weekly open band against
// the event first or the window expires without contact. Episodes open
// and resolve on confirmed bars only, so the statistic never repaints.
// All engine reclaim and loss events are tracked, including those the
// label cooldown keeps off the chart, so the statistic reflects the
// engine rather than the display.
// -------------------------------------------------
var bool  reOn = false
var int   reDir = 0
var float reEntry = na
var float reAtr = na
var float reWoRef = na
var float reBand = na
var int   reStart = na
var int   reWin = 0
var int   reWins = 0
var int   reN = 0

bool reHitEv = false

if reOn and barstate.isconfirmed
    bool reHit = reDir == 1 ? high >= reEntry + reAtr * edgeTargetAtr : low <= reEntry - reAtr * edgeTargetAtr
    bool reLoss = reDir == 1 ? close < reWoRef - reBand : close > reWoRef + reBand
    bool reTimeout = not na(reStart) and bar_index - reStart >= reWin
    if reHit
        reN += 1
        reWins += 1
        reOn := false
        reHitEv := true
    else if reLoss or reTimeout
        reN += 1
        reOn := false

if (reclaimEvent or lossEvent) and barstate.isconfirmed and validWeeklyOpen and not na(atrValue) and atrValue > 0.0
    if reOn
        reN += 1
        reOn := false
    reOn := true
    reDir := reclaimEvent ? 1 : -1
    reEntry := close
    reAtr := atrValue
    reWoRef := weeklyOpen
    reBand := bandHalf
    reStart := bar_index
    reWin := edgeWindow

// Workflow text, always consistent with the acceptance state.
string workflowTxt = "Wait for acceptance"
if acceptedAbove
    workflowTxt := "Hold above WO"
else if acceptedBelow
    workflowTxt := "Hold below WO"
else if touchingBand
    workflowTxt := "Review WO test"

int barsIntoWeek = nz(ta.barssince(newWeek), 0) + 1
string edgeStatus = "Idle"
if reOn
    int edgeAge = math.max(bar_index - reStart, 0)
    edgeStatus := (reDir == 1 ? "Bull " : "Bear ") + str.tostring(edgeAge) + "/" + str.tostring(reWin)

// -------------------------------------------------
// Weekly Open Line and Bands
// -------------------------------------------------
var line weeklyOpenLine = na
if showWeeklyOpenLine and validWeeklyOpen
    if newWeek or na(weeklyOpenLine)
        if not na(weeklyOpenLine)
            line.delete(weeklyOpenLine)
        weeklyOpenLine := line.new(bar_index, weeklyOpen, bar_index + 1, weeklyOpen,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = color.new(accentColor, 15),
             width = openLineWidth,
             style = line.style_dashed)
    else
        line.set_y1(weeklyOpenLine, weeklyOpen)
        line.set_y2(weeklyOpenLine, weeklyOpen)
        line.set_x2(weeklyOpenLine, bar_index + 1)
else if not na(weeklyOpenLine)
    line.delete(weeklyOpenLine)
    weeklyOpenLine := na

var box activeBandBox = na
var label activeBandLabel = na
if showReactionBand and validWeeklyOpen and not currentWeekHasReactionZone
    color activeBandColor = color.new(currentStateColor, zoneTransparency)
    if newWeek or na(activeBandBox)
        if not na(activeBandBox)
            box.delete(activeBandBox)
        activeBandBox := box.new(left = bar_index,
             top = weeklyOpen + bandHalf,
             right = bar_index + zoneExtendBars,
             bottom = weeklyOpen - bandHalf,
             xloc = xloc.bar_index,
             bgcolor = activeBandColor,
             border_color = color.new(currentStateColor, 35),
             border_width = 1)
    else
        box.set_top(activeBandBox, weeklyOpen + bandHalf)
        box.set_bottom(activeBandBox, weeklyOpen - bandHalf)
        box.set_right(activeBandBox, bar_index + zoneExtendBars)
        box.set_bgcolor(activeBandBox, activeBandColor)
        box.set_border_color(activeBandBox, color.new(currentStateColor, 35))

    int activeLabelX = bar_index + int(math.floor(zoneExtendBars * 0.5))
    string activeLabelText = "WEEKLY OPEN " + str.tostring(weeklyOpen, format.mintick) + " | " + (acceptedAbove ? "ABOVE" : acceptedBelow ? "BELOW" : "TESTING")
    if newWeek or na(activeBandLabel)
        if not na(activeBandLabel)
            label.delete(activeBandLabel)
        activeBandLabel := label.new(activeLabelX,
             weeklyOpen,
             activeLabelText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_center,
             color = color.new(currentStateColor, 0),
             textcolor = headerText,
             size = f_size(labelSizeInput))
    else
        label.set_x(activeBandLabel, activeLabelX)
        label.set_y(activeBandLabel, weeklyOpen)
        label.set_text(activeBandLabel, activeLabelText)
        label.set_color(activeBandLabel, color.new(currentStateColor, 0))
        label.set_textcolor(activeBandLabel, headerText)
else if not na(activeBandBox)
    box.delete(activeBandBox)
    activeBandBox := na
    if not na(activeBandLabel)
        label.delete(activeBandLabel)
        activeBandLabel := na
else if not showReactionBand and not na(activeBandLabel)
    label.delete(activeBandLabel)
    activeBandLabel := na

// -------------------------------------------------
// Reaction Zones and Labels
// -------------------------------------------------
var array<box> reactionBoxes = array.new<box>()
var array<label> reactionZoneLabels = array.new<label>()
var array<label> eventLabels = array.new<label>()

if canPrintEvent and validWeeklyOpen
    color eventColor = bullishEvent ? bullColor : bearColor

    lastEventBar := bar_index

    if showReactionZones
        box reactionBox = box.new(left = math.max(bar_index - confirmBars + 1, 0),
             top = weeklyOpen + bandHalf,
             right = bar_index + zoneExtendBars,
             bottom = weeklyOpen - bandHalf,
             xloc = xloc.bar_index,
             bgcolor = color.new(eventColor, zoneTransparency),
             border_color = color.new(eventColor, 15),
             border_width = 1)
        array.push(reactionBoxes, reactionBox)
        int reactionLeft = math.max(bar_index - confirmBars + 1, 0)
        int reactionRight = bar_index + zoneExtendBars
        string reactionZoneText = (bullishEvent ? "BULL REACTION" : "BEAR REACTION") + " | WO " + str.tostring(weeklyOpen, format.mintick)
        label reactionZoneLabel = label.new(int(math.floor((reactionLeft + reactionRight) * 0.5)),
             weeklyOpen,
             reactionZoneText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_center,
             color = color.new(eventColor, 0),
             textcolor = headerText,
             size = f_size(labelSizeInput))
        array.push(reactionZoneLabels, reactionZoneLabel)
        currentWeekHasReactionZone := true
        if not na(activeBandBox)
            box.delete(activeBandBox)
            activeBandBox := na
        if not na(activeBandLabel)
            label.delete(activeBandLabel)
            activeBandLabel := na
        if array.size(reactionBoxes) > maxReactionZones
            box oldReactionBox = array.shift(reactionBoxes)
            box.delete(oldReactionBox)
            label oldReactionZoneLabel = array.shift(reactionZoneLabels)
            label.delete(oldReactionZoneLabel)

    bool labelAllowed = showEventLabels
    if labelAllowed
        float labelPadding = nz(atrValue, bandHalf) * labelOffsetAtr
        float labelPrice = bullishEvent ? weeklyOpen - bandHalf - labelPadding : weeklyOpen + bandHalf + labelPadding
        label eventLabel = label.new(bar_index,
             labelPrice,
             eventText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = bullishEvent ? label.style_label_up : label.style_label_down,
             color = color.new(eventColor, 0),
             textcolor = headerText,
             size = f_size(labelSizeInput))
        array.push(eventLabels, eventLabel)
        if array.size(eventLabels) > maxEventLabels
            label oldEventLabel = array.shift(eventLabels)
            label.delete(oldEventLabel)

// -------------------------------------------------
// Panel - only the blue title row is merged.
// -------------------------------------------------
var table infoPanel = table.new(f_panel_position(panelLocation), 2, 8, border_width = 1, border_color = panelBorder)

if barstate.isfirst
    table.cell(infoPanel, 0, 0, "", bgcolor = headerBg)
    table.cell(infoPanel, 1, 0, "", bgcolor = headerBg)
    table.merge_cells(infoPanel, 0, 0, 1, 0)

if barstate.islast
    if showPanel
        color livePanelBg = f_panel_bg(panelTheme)
        color livePanelBorder = f_panel_border(panelTheme)
        color livePanelLabel = f_panel_label(panelTheme)
        color livePanelValue = f_panel_value(panelTheme)
        string openDistanceText = "n/a"
        if validWeeklyOpen and weeklyOpen != 0.0
            float signedDistance = close - weeklyOpen
            openDistanceText := str.tostring(weeklyOpen, format.mintick) + " | " + (signedDistance >= 0.0 ? "+" : "") + str.tostring(signedDistance, format.mintick) + " / " + str.tostring(signedDistance / weeklyOpen * 100.0, "#.##") + "%"
        string activityText = str.tostring(reactionsThisWeek) + " reactions | " + str.tostring(barsIntoWeek) + " bars"

        table.set_bgcolor(infoPanel, livePanelBg)
        table.set_frame_color(infoPanel, livePanelBorder)
        table.set_frame_width(infoPanel, 1)
        table.set_border_color(infoPanel, livePanelBorder)
        table.set_border_width(infoPanel, 1)
        table.cell(infoPanel, 0, 0, "AG Pro Weekly Open Reaction Map",
             text_color = headerText,
             bgcolor = headerBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_center)
        table.cell(infoPanel, 0, 1, "Workflow",
             text_color = livePanelLabel,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_left)
        table.cell(infoPanel, 1, 1, workflowTxt,
             text_color = currentStateColor,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_right)
        table.cell(infoPanel, 0, 2, "Weekly State",
             text_color = livePanelLabel,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_left)
        table.cell(infoPanel, 1, 2, acceptanceSide,
             text_color = currentStateColor,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_right)
        table.cell(infoPanel, 0, 3, "WO / Distance",
             text_color = livePanelLabel,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_left)
        table.cell(infoPanel, 1, 3, openDistanceText,
             text_color = livePanelValue,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_right)
        table.cell(infoPanel, 0, 4, "Week Activity",
             text_color = livePanelLabel,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_left)
        table.cell(infoPanel, 1, 4, activityText,
             text_color = livePanelValue,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_right)
        table.cell(infoPanel, 0, 5, "Last Event",
             text_color = livePanelLabel,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_left)
        table.cell(infoPanel, 1, 5, lastEvent,
             text_color = livePanelValue,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_right)
        table.cell(infoPanel, 0, 6, "Edge Proof",
             text_color = livePanelLabel,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_left)
        table.cell(infoPanel, 1, 6, f_reText(reWins, reN),
             text_color = f_reColor(reWins, reN, livePanelLabel),
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_right)
        table.cell(infoPanel, 0, 7, "Edge Status",
             text_color = livePanelLabel,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_left)
        table.cell(infoPanel, 1, 7, edgeStatus,
             text_color = reOn ? accentColor : livePanelValue,
             bgcolor = livePanelBg,
             text_size = f_size(panelSizeInput),
             text_halign = text.align_right)
    else
        table.clear(infoPanel, 0, 0, 1, 7)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(reclaimEvent and alertBarOk, "Weekly Open Reclaim", "Weekly Open Reaction Map: weekly open reclaim confirmed on {{ticker}}.")
alertcondition(lossEvent and alertBarOk, "Weekly Open Loss", "Weekly Open Reaction Map: weekly open loss confirmed on {{ticker}}.")
alertcondition(initialAcceptAbove and alertBarOk, "Weekly Open Accepted Above", "Weekly Open Reaction Map: price accepted above the weekly open on {{ticker}}.")
alertcondition(initialAcceptBelow and alertBarOk, "Weekly Open Accepted Below", "Weekly Open Reaction Map: price accepted below the weekly open on {{ticker}}.")
alertcondition(reHitEv and alertBarOk, "Reaction Edge Target Hit", "Weekly Open Reaction Map: a tracked reclaim or loss event reached its Reaction Edge target on {{ticker}}.")
````
