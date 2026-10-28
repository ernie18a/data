# Wyckoff Distribution Phase Map [AGPro Series]

- url: https://www.tradingview.com/script/oq2aQ0AS-Wyckoff-Distribution-Phase-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;608c693303524b9b8dd59c4fcf7ebad2
- version: 2.0

## Description

Wyckoff Distribution Phase Map [AGPro Series]

🔹 OVERVIEW

Wyckoff Distribution Phase Map is a retrospective structural mapping tool built on the classic Wyckoff distribution schematic. It locates and labels the six core distribution events — Preliminary Supply (PSY), Buying Climax (BC), Automatic Reaction (AR), Upthrust (UT), Sign of Weakness (SOW) and Last Point of Supply (LPSY) — only after a bearish Change of Character (CHoCH) confirms that the prior uptrend has structurally broken. The indicator frames the active trading range as a shaded zone, plots BC and AR horizontal references, and tracks the phase state (A, B, C, D, E) in a dedicated info panel with a forming-candidate watchlist before confirmation.

🔹 WHAT MAKES IT DIFFERENT

Most Wyckoff scripts on TradingView label events reactively on every elevated swing, producing dense, often contradictory signals during ranging or trending markets. This indicator takes the opposite approach. During an uptrend, the chart remains completely clean. Rolling trackers silently maintain candidate values for BC, PSY and AR in memory, while a live watchlist row in the panel shows the forming distribution candidate in real time. Events are only drawn on the chart after CHoCH locks the schematic, at which point PSY, BC and AR appear together as a confirmed retrospective bundle. UT, SOW and LPSY then populate as the post-CHoCH structure unfolds. A two-tier expiry system closes both incomplete and fully-played-out distributions, ensuring the active schematic on screen always reflects current market structure — not stale history.

🔹 METHODOLOGY

The engine runs in two coordinated layers. The first layer tracks higher-high and higher-low sequences to qualify an uptrend and rolls candidate values for the Buying Climax (running maximum swing high), Preliminary Supply (last pre-BC elevated swing high) and Automatic Reaction (running minimum after BC). The second layer watches for a structural break below the last confirmed higher-low, which defines the CHoCH. On CHoCH confirmation, the candidate values are snapshotted as BC, PSY and AR labels, the trading range zone is drawn, and the state machine advances to the forward-detection phase. Upthrust, Sign of Weakness and Last Point of Supply are then detected in strict sequence using a combination of price-to-BC, price-to-AR and volume-to-average filters. Volume context is computed against a 20-period moving average baseline with separate climactic, elevated and weak thresholds tuned for crypto and equities alike.

🔹 SIGNALS AND ALERTS

The indicator fires two categories of alerts. The CHoCH Confirmation alert triggers the moment the structural break locks in, including the resolved BC and AR levels. Event alerts fire for each subsequent UT, SOW and LPSY detection. No alert is fired during the forming phase — alerts are reserved for confirmed structural events, keeping notification noise low. A projected markdown line is drawn forward from LPSY using the trading range height as a symmetrical target, purely as a visual reference point rather than a trade signal.

🔹 KEY INPUTS

Core Engine inputs control swing lookback sensitivity, candidate maximum age and the post-CHoCH timeout window. Volume Analysis exposes the moving average length and three multipliers for climactic, elevated and weak volume classification. Visual inputs toggle the trading range zone, BC and AR horizontal levels, the CHoCH dashed break line, the markdown projection, the confidence halo and the floating distribution summary label, with full control over font size, line widths and zone transparency. The info panel can be repositioned to six anchor points and switched between dark and light themes. A Keep Historical Events toggle allows old schematics to remain on the chart after reset, off by default for a clean view.

🔹 HOW TO USE

Apply the indicator to any liquid instrument and any timeframe. During uptrends, observe the Watching row in the panel to monitor the forming BC candidate. When CHoCH prints, the full PSY, BC, AR bundle appears with the trading range shaded. From that point, use the Next Expected row to track what the engine is waiting for. The confidence score progresses from 70 at CHoCH to 97 at LPSY. The floating summary label on the right edge of the chart provides an at-a-glance status even when the primary event labels are scrolled off to the left. The indicator works standalone but is designed to complement any market structure, order flow or supply-and-demand workflow.

🔹 LIMITATIONS AND TRANSPARENCY

This tool is a pattern-recognition and labeling engine, not a strategy or trading signal generator. All events are detected retrospectively after their confirming bar has closed plus the swing lookback period — this is by design to eliminate redrawing. The Wyckoff schematic is a framework, not a deterministic forecast; not every distribution completes the full six-event sequence, and markets frequently fail schematics entirely and resume the prior trend. The volume analysis assumes reliable reported volume, so thin or fragmented markets may produce weaker classification. Confidence scores are internal heuristics tied to event progression, not statistical probabilities. Past schematic completions do not predict future market behavior.

🔹 RISK DISCLOSURE

This indicator is published for educational and analytical purposes only. It does not constitute financial advice, a trading recommendation or an investment solicitation. Trading any financial instrument involves substantial risk, including the potential loss of principal. Past performance does not guarantee future results. Users are solely responsible for their own trading decisions, risk management and independent research. Always backtest thoroughly and trade within a risk framework you understand.

## Source Code

````pine
// -------------------------------------------------
// Wyckoff Distribution Phase Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.4
//
// Retrospective Wyckoff distribution mapping anchored on a confirmed structural
// break. PSY, BC, AR, UT, SOW and LPSY events are only rendered after a bearish
// Change of Character locks in the schematic, eliminating false positives during
// continuation pullbacks. A Live Watchlist tracks forming candidates in real
// time while the chart stays clean. A markdown follow-rate layer reports how
// often confirmed LPSY events on this chart actually reached the projected
// markdown target before price reclaimed the BC level. Built for traders working with Wyckoff
// method, distribution schematics, supply zones and smart money top formations
// on any asset or timeframe.
// -------------------------------------------------

//@version=6
indicator("Wyckoff Distribution Phase Map [AGPro Series]",
     shorttitle = "AG Pro WDist",
     overlay    = true,
     max_labels_count = 500,
     max_lines_count  = 250,
     max_boxes_count  = 250)

// =================================================
// INPUTS
// =================================================
grpCore   = "Core Engine"
grpVol    = "Volume Analysis"
grpVis    = "Visuals"
grpPanel  = "Info Panel"
grpAlerts = "Alerts"

// Core
swingLen         = input.int(8,   "Swing Lookback",                  minval = 3, maxval = 30,                 group = grpCore, tooltip = "Bars on each side to confirm a swing high/low. Higher values = smoother structure, fewer events.")
maxCandidateAge  = input.int(300, "Candidate Max Age (bars)",       minval = 50, maxval = 600,                group = grpCore, tooltip = "If a forming distribution does not confirm within this many bars, its Watchlist candidate is dropped.")
postCHoCHTimeout = input.int(250, "Post-CHoCH Timeout (bars)",      minval = 50, maxval = 600,                group = grpCore, tooltip = "If UT / SOW / LPSY do not appear within this many bars after CHoCH, the distribution is closed.")

// Volume
volMaLen        = input.int(20,  "Volume MA Length",                 minval = 5, maxval = 100,                group = grpVol,  tooltip = "Moving average length used as the volume baseline.")
climacticMult   = input.float(1.8,"Climactic Volume Multiplier",     minval = 1.2, maxval = 5.0, step = 0.1,  group = grpVol,  tooltip = "Volume must exceed MA x this multiplier to qualify as climactic (tuned for crypto; lower than traditional equities).")
elevatedMult    = input.float(1.3,"Elevated Volume Multiplier",      minval = 1.0, maxval = 3.0, step = 0.1,  group = grpVol,  tooltip = "Minimum volume vs MA for PSY/UT/SOW qualification.")
weakVolMult     = input.float(0.85,"Weak Volume Threshold",          minval = 0.3, maxval = 1.0, step = 0.05, group = grpVol,  tooltip = "Maximum volume vs MA for LPSY confirmation (weak rally).")

// Visuals
showZone        = input.bool(true,"Show Trading Range Zone",                                                  group = grpVis,  tooltip = "Draws the BC-AR trading range as a shaded rectangle.")
showEventLevels = input.bool(true,"Show BC / AR Horizontal Levels",                                           group = grpVis,  tooltip = "Horizontal lines at the Buying Climax high and Automatic Reaction low.")
showProjection  = input.bool(true,"Show Markdown Projection",                                                 group = grpVis,  tooltip = "After LPSY confirmation, projects a markdown path forward.")
showConfluence  = input.bool(true,"Show Confidence Halo on Labels",                                           group = grpVis,  tooltip = "Adds a subtle accent star when confidence is high.")
showCHoCH       = input.bool(true,"Show CHoCH Break Line",                                                    group = grpVis,  tooltip = "Marks the Change of Character break with a dashed line - the structural anchor of the distribution.")
showSummary     = input.bool(true,"Show Distribution Summary Label",                                          group = grpVis,  tooltip = "Floating right-edge label showing the active distribution status. Useful when PSY/BC/AR labels are off-screen to the left. Hides when no distribution is active.")
keepHistorical  = input.bool(false,"Keep Historical Events On Reset",                                         group = grpVis,  tooltip = "If enabled, old PSY/BC/AR labels stay on the chart after a reset. Default OFF for a clean premium view.")
labelFontSize   = input.string("Normal","Label Font Size",
     options = ["Tiny","Small","Normal","Large","Huge"],                                                      group = grpVis,  tooltip = "Font size for all event labels on the chart.")
labelStyle      = input.string("Descriptive","Event Label Style",
     options = ["Compact","Descriptive"],                                                                     group = grpVis,  tooltip = "Compact prints the classic Wyckoff codes (BC, AR, UT). Descriptive adds the full event name on a second line, and every label carries an explanatory tooltip on hover.")
lineWidthDom    = input.int(3,   "Dominant Line Width",              minval = 1, maxval = 5,                  group = grpVis,  tooltip = "Line width for the active BC level (dominant reference).")
lineWidthMid    = input.int(2,   "Active Line Width",                minval = 1, maxval = 5,                  group = grpVis,  tooltip = "Line width for the AR level (active reference).")
zoneTransp      = input.int(82,  "Zone Transparency",                minval = 50, maxval = 95,                group = grpVis,  tooltip = "Transparency of the trading range zone (higher = lighter).")

// Panel
showPanel       = input.bool(true,"Show Info Panel",                                                          group = grpPanel, tooltip = "Display the AG Pro info panel with current phase and statistics.")
showWatchlist   = input.bool(true,"Show Live Watchlist Row",                                                  group = grpPanel, tooltip = "Show the forming distribution candidate in real time (before CHoCH confirmation).")
panelPos        = input.string("Top Right","Panel Position",
     options = ["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"],            group = grpPanel, tooltip = "Anchor position of the info panel on the chart.")
panelTheme      = input.string("Dark","Panel Theme",
     options = ["Dark","Light"],                                                                              group = grpPanel, tooltip = "Dark theme (default) or Light theme for the panel.")
panelFontSize   = input.string("Normal","Panel Font Size",
     options = ["Tiny","Small","Normal","Large","Huge"],                                                      group = grpPanel, tooltip = "Font size for the info panel text.")
helpTextSize    = input.string("Normal","Help Text Size",
     options = ["Tiny","Small","Normal","Large","Huge"],                                                      group = grpPanel, tooltip = "Font size for tooltips and help hints (reserved).")

// Alerts
alertOnCHoCH    = input.bool(true,"Alert On CHoCH Confirmation",                                              group = grpAlerts, tooltip = "Fire an alert when the structural break confirms a distribution.")
alertOnEvent    = input.bool(true,"Alert On Each Event",                                                      group = grpAlerts, tooltip = "Fire an alert when a new Wyckoff event is detected.")

// =================================================
// AGPro COLOR PALETTE
// =================================================
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = panelTheme == "Dark" ? color.rgb(15, 23, 42)   : color.rgb(248, 250, 252)
panelBorder   = panelTheme == "Dark" ? color.rgb(51, 65, 85)   : color.rgb(203, 213, 225)
panelLabelCol = panelTheme == "Dark" ? color.rgb(148, 163, 184): color.rgb(71, 85, 105)
panelValueCol = panelTheme == "Dark" ? color.rgb(226, 232, 240): color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
whiteText     = color.rgb(255, 255, 255)

// Helpers
f_toSize(p) =>
    result = size.normal
    if p == "Tiny"
        result := size.tiny
    else if p == "Small"
        result := size.small
    else if p == "Large"
        result := size.large
    else if p == "Huge"
        result := size.huge
    result

f_panelPos(p) =>
    result = position.top_right
    if p == "Top Left"
        result := position.top_left
    else if p == "Middle Right"
        result := position.middle_right
    else if p == "Middle Left"
        result := position.middle_left
    else if p == "Bottom Right"
        result := position.bottom_right
    else if p == "Bottom Left"
        result := position.bottom_left
    result

labelSize = f_toSize(labelFontSize)
panelSize = f_toSize(panelFontSize)

// =================================================
// STRUCTURE ENGINE - HH/HL tracking
// =================================================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow (low,  swingLen, swingLen)

var float lastHigh     = na
var float prevHigh     = na
var float lastLow      = na
var float prevLow      = na
var int   trendState   = 0

if not na(ph)
    prevHigh := lastHigh
    lastHigh := ph

if not na(pl)
    prevLow := lastLow
    lastLow := pl

uptrendConfirmed = not na(lastHigh) and not na(prevHigh) and not na(lastLow) and not na(prevLow) and lastHigh > prevHigh and lastLow > prevLow
if uptrendConfirmed and trendState != -1
    trendState := 1

// =================================================
// VOLUME ANALYSIS
// =================================================
volMA        = ta.sma(volume, volMaLen)
volRatio     = volMA > 0 and not na(volume) ? volume / volMA : 0.0
climactic    = volRatio >= climacticMult
elevated     = volRatio >= elevatedMult
weakVolume   = volRatio <= weakVolMult

volCtx = volRatio >= climacticMult ? "Climactic" : volRatio >= elevatedMult ? "Elevated" : volRatio <= weakVolMult ? "Weak" : "Normal"
volCtxColor = volRatio >= climacticMult ? bearColor : volRatio >= elevatedMult ? neutralColor : volRatio <= weakVolMult ? accentColor : panelValueCol

barRange  = high - low
wideRange = barRange > ta.sma(barRange, 20) * 1.3
bearBar   = close < open

// =================================================
// CHoCH STATE (declared early so FIX-A expire can reference distActive)
// =================================================
var int   chochBar      = na
var float chochLevel    = na
var bool  distActive    = false
var int   distAnchorBar = na

// =================================================
// ROLLING TRACKERS (updated every bar during uptrend)
// =================================================
var float candBC          = na
var int   candBCBar       = na
var bool  candBCClimactic = false

var float prevElevHigh    = na
var int   prevElevHighBar = na
var float candPSY         = na
var int   candPSYBar      = na

var float candAR          = na
var int   candARBar       = na

// Precompute history references OUTSIDE conditional blocks (required by Pine v6)
phVolRatio    = volMA[swingLen] > 0 ? volume[swingLen] / volMA[swingLen] : 0.0
phIsElevated  = phVolRatio >= elevatedMult
phIsClimactic = phVolRatio >= climacticMult
phBarIdx      = bar_index - swingLen

// BC + PSY tracking during uptrend
if trendState == 1 and not na(ph)
    if na(candBC) or ph > candBC
        if not na(candBC) and candBCClimactic
            prevElevHigh    := candBC
            prevElevHighBar := candBCBar
        candBC          := ph
        candBCBar       := phBarIdx
        candBCClimactic := phIsClimactic or phIsElevated
        candAR          := na
        candARBar       := na
    if phIsElevated and not na(candBC) and ph < candBC and phBarIdx < candBCBar
        prevElevHigh    := ph
        prevElevHighBar := phBarIdx

candPSY    := prevElevHigh
candPSYBar := prevElevHighBar

// AR running tracker after BC is established
if trendState == 1 and not na(candBCBar) and bar_index > candBCBar
    if na(candAR) or low < candAR
        candAR    := low
        candARBar := bar_index

// Watchlist expiry
// [FIX-A v2.2] Expire stale candidate whenever no active distribution exists.
// Previously gated on trendState==1, which left stale trackers alive after a
// distribution reset dropped trendState to 0 but no fresh uptrend had confirmed.
if not na(candBCBar) and (bar_index - candBCBar > maxCandidateAge) and not distActive
    candBC          := na
    candBCBar       := na
    candBCClimactic := false
    prevElevHigh    := na
    prevElevHighBar := na
    candPSY         := na
    candPSYBar      := na
    candAR          := na
    candARBar       := na

// =================================================
// CHoCH - bearish Change of Character
// =================================================
chochAnchor = prevLow
newCHoCH = not distActive and trendState == 1 and not na(chochAnchor) and not na(candBC) and not na(candBCBar) and close < chochAnchor and close[1] >= chochAnchor and bar_index > candBCBar
if newCHoCH
    chochBar      := bar_index
    chochLevel    := chochAnchor
    distActive    := true
    distAnchorBar := bar_index
    trendState    := -1

// =================================================
// RETROSPECTIVE SNAPSHOT at CHoCH
// =================================================
var float bcPrice        = na
var int   bcBar          = na
var float psyPrice       = na
var int   psyBar         = na
var float arPrice        = na
var int   arBar          = na

if newCHoCH
    bcPrice := candBC
    bcBar   := candBCBar
    if not na(candPSY) and not na(candPSYBar)
        psyPrice := candPSY
        psyBar   := candPSYBar
    if not na(candAR) and not na(candARBar)
        arPrice := candAR
        arBar   := candARBar

// =================================================
// FORWARD STATE MACHINE - UT, SOW, LPSY
// =================================================
var int   postPhase    = 0
var float utPrice      = na
var int   utBar        = na
var float sowPrice     = na
var int   sowBar       = na
var float lpsyPrice    = na
var int   lpsyBar      = na
var float confidence   = 0.0
var string lastEvent   = "None"
var int   lastEventBar = na

if newCHoCH
    postPhase    := 3
    lastEvent    := "CHoCH"
    lastEventBar := bar_index
    confidence   := 70.0

phValid  = not na(ph)
swingBar = bar_index - swingLen

newUT = postPhase == 3 and phValid and not na(bcPrice) and not na(chochBar) and swingBar > chochBar and high[swingLen] > bcPrice * 1.001 and close[swingLen] < bcPrice and elevated[swingLen]
if newUT
    utPrice        := ph
    utBar          := swingBar
    postPhase      := 4
    lastEvent      := "UT"
    lastEventBar   := bar_index
    confidence     := 82.0

newSOW = postPhase == 4 and not na(arPrice) and not na(utBar) and swingBar > utBar and close[swingLen] < arPrice and elevated[swingLen] and bearBar[swingLen]
if newSOW
    sowPrice       := low[swingLen]
    sowBar         := swingBar
    postPhase      := 5
    lastEvent      := "SOW"
    lastEventBar   := bar_index
    confidence     := 90.0

newLPSY = postPhase == 5 and phValid and not na(bcPrice) and not na(sowBar) and swingBar > sowBar and ph < bcPrice and weakVolume[swingLen]
if newLPSY
    lpsyPrice      := ph
    lpsyBar        := swingBar
    postPhase      := 6
    lastEvent      := "LPSY"
    lastEventBar   := bar_index
    confidence     := 97.0

// Markdown follow-rate layer: each confirmed LPSY is tracked once against
// the same target the projection line draws (AR minus the trading-range
// height). It counts as followed when price reaches that target before
// reclaiming the BC level, and as failed when BC is reclaimed first or the
// tracking window times out. The tracker keeps its own frozen copies of the
// levels, so distribution resets do not disturb an open measurement.
// Resolution runs before registration for conservative same-bar handling.
mdConfirmedNew = barstate.isconfirmed and newLPSY and not na(bcPrice) and not na(arPrice)
var bool mdTrkOn = false
var float mdTrkTgt = na
var float mdTrkInv = na
var int mdTrkStart = na
var int mdFollowW = 0
var int mdFollowN = 0
if mdTrkOn
    mdFollowed = low <= mdTrkTgt
    mdFailed = close > mdTrkInv
    mdTimeout = not na(mdTrkStart) and bar_index - mdTrkStart >= postCHoCHTimeout
    if mdFailed or mdTimeout
        mdFollowN += 1
        mdTrkOn := false
    else if mdFollowed
        mdFollowN += 1
        mdFollowW += 1
        mdTrkOn := false
if mdConfirmedNew and not mdTrkOn
    mdTrkOn := true
    mdTrkTgt := arPrice - (bcPrice - arPrice)
    mdTrkInv := bcPrice
    mdTrkStart := bar_index
mdFollowRate = mdFollowN > 0 ? 100.0 * mdFollowW / mdFollowN : na
mdFollowReady = mdFollowN >= 8

// =================================================
// DRAWING HANDLES (declared before reset block so they can be cleared)
// =================================================
var box   trZone    = na
var line  bcLine    = na
var line  arLine    = na
var line  chochLine = na
var line  projLine  = na
// Labels belonging to the active distribution, so a reset can honor the
// Keep Historical Events setting for labels as well as boxes and lines.
var array<label> distLabels = array.new<label>()

// =================================================
// RESET on expiry
// [FIX-E v2.3] Two expire paths:
//   (1) Incomplete: timeout passed & postPhase < 6 (no LPSY ever came)
//   (2) Completed : postPhase == 6 & LPSY is stale (markdown leg played out)
// Without (2), a fully-formed historical distribution stayed "active" forever,
// which polluted the summary label with ancient BC values on intraday charts
// where the chart's earliest bars contained a complete distribution sequence.
// =================================================
expiredIncomplete = distActive and not na(distAnchorBar) and (bar_index - distAnchorBar > postCHoCHTimeout) and postPhase < 6
expiredCompleted  = distActive and postPhase == 6 and not na(lpsyBar) and (bar_index - lpsyBar > postCHoCHTimeout)
expired = expiredIncomplete or expiredCompleted

if expired
    distActive      := false
    postPhase       := 0
    candBC          := na
    candBCBar       := na
    candBCClimactic := false
    candPSY         := na
    candPSYBar      := na
    prevElevHigh    := na
    prevElevHighBar := na
    candAR          := na
    candARBar       := na
    trendState      := 0

    if not keepHistorical
        if not na(trZone)
            box.delete(trZone)
            trZone := na
        if not na(bcLine)
            line.delete(bcLine)
            bcLine := na
        if not na(arLine)
            line.delete(arLine)
            arLine := na
        if not na(chochLine)
            line.delete(chochLine)
            chochLine := na
        if not na(projLine)
            line.delete(projLine)
            projLine := na
        while array.size(distLabels) > 0
            label.delete(array.pop(distLabels))

    if keepHistorical
        array.clear(distLabels)

    bcPrice        := na
    bcBar          := na
    arPrice        := na
    arBar          := na
    psyPrice       := na
    psyBar         := na
    utPrice        := na
    utBar          := na
    sowPrice       := na
    sowBar         := na
    lpsyPrice      := na
    lpsyBar        := na
    lastEvent      := "Reset"
    lastEventBar   := bar_index
    confidence     := 0.0

// =================================================
// DERIVED PANEL VALUES
// =================================================
phaseLetter = switch
    not distActive => "-"
    postPhase == 3 => "C (TR)"
    postPhase == 4 => "C/D (UT)"
    postPhase == 5 => "D (SOW)"
    postPhase == 6 => "E (Markdown)"
    => "-"

nextExpected = switch
    not distActive => "CHoCH Break"
    postPhase == 3 => "UT"
    postPhase == 4 => "SOW"
    postPhase == 5 => "LPSY"
    postPhase == 6 => "Markdown Leg"
    => "-"

phaseColor = postPhase == 3 or postPhase == 4 ? neutralColor : postPhase >= 5 ? bearColor : panelValueCol

trStatus      = postPhase >= 3 and postPhase < 6 ? "Active" : postPhase == 6 ? "Broken" : "-"
trStatusColor = trStatus == "Active" ? neutralColor : trStatus == "Broken" ? bearColor : panelValueCol

// [FIX-C v2.2] Events Detected derived from postPhase + PSY presence.
// Pre-CHoCH: 0. On CHoCH: BC+AR (+PSY if found) = 2 or 3. UT->+1, SOW->+1, LPSY->+1.
eventsDetected = switch
    not distActive => 0
    postPhase == 3 => not na(psyPrice) ? 3 : 2
    postPhase == 4 => not na(psyPrice) ? 4 : 3
    postPhase == 5 => not na(psyPrice) ? 5 : 4
    postPhase == 6 => not na(psyPrice) ? 6 : 5
    => 0

// [FIX-C v2.2] Watchlist only shown when NO active distribution - otherwise it's noise.
watchStatus = switch
    distActive => "- (distribution active)"
    not na(candBC) => "High " + str.tostring(candBC, format.mintick) + (candBCClimactic ? "  [Climactic]" : "")
    => "None"
watchColor = switch
    distActive => panelLabelCol
    not na(candBC) => candBCClimactic ? neutralColor : panelValueCol
    => panelLabelCol

// =================================================
// EVENT LABEL COLOR HELPER & DRAWER
// =================================================
f_eventText(e) =>
    switch e
        "PSY"   => "PSY\nPrelim Supply"
        "BC"    => "BC\nBuying Climax"
        "AR"    => "AR\nAuto Reaction"
        "UT"    => "UT\nUpthrust"
        "SOW"   => "SOW\nSign of Weakness"
        "LPSY"  => "LPSY\nLast Pt of Supply"
        => e

f_eventTip(e) =>
    switch e
        "PSY"   => "Preliminary Supply: first elevated-volume rally where large sellers begin distributing into demand."
        "BC"    => "Buying Climax: the climactic high of the advance, where urgent buying is absorbed by supply."
        "AR"    => "Automatic Reaction: the sharp decline after the Buying Climax that defines the lower bound of the trading range."
        "UT"    => "Upthrust: a push above the Buying Climax that fails back inside the range, trapping late buyers."
        "SOW"   => "Sign of Weakness: a decisive close below the Automatic Reaction on elevated volume, showing supply is in control."
        "LPSY"  => "Last Point of Supply: a weak-volume rally that fails below the Buying Climax, the final pause before markdown."
        => ""

f_eventColor(e) =>
    switch e
        "PSY"   => neutralColor
        "BC"    => bearColor
        "AR"    => accentColor
        "UT"    => bearColor
        "SOW"   => bearColor
        "LPSY"  => bearColor
        "CHoCH" => accentColor
        => panelLabelCol

f_drawEvent(_bar, _price, _txt, _above) =>
    if not na(_bar) and not na(_price)
        label.new(
             x         = _bar,
             y         = _price,
             text      = labelStyle == "Descriptive" ? f_eventText(_txt) : _txt,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             style     = _above ? label.style_label_down : label.style_label_up,
             color     = f_eventColor(_txt),
             textcolor = whiteText,
             size      = labelSize,
             tooltip   = f_eventTip(_txt))

f_keepEvent(lbl) =>
    if not na(lbl)
        array.push(distLabels, lbl)

// Draw PSY, BC, AR bundle on CHoCH. The PSY label is skipped when its
// pivot sits within one swing length of the BC bar: at that distance the
// two labels stack on top of each other and PSY adds no separate visual
// information.
if newCHoCH
    if not na(psyBar) and not na(bcBar) and math.abs(bcBar - psyBar) > swingLen
        f_keepEvent(f_drawEvent(psyBar, psyPrice, "PSY", true))
    if not na(bcBar)
        f_keepEvent(f_drawEvent(bcBar, bcPrice, "BC", true))
    if not na(arBar)
        f_keepEvent(f_drawEvent(arBar, arPrice, "AR", false))

if newUT
    f_keepEvent(f_drawEvent(utBar, utPrice, "UT", true))
if newSOW
    f_keepEvent(f_drawEvent(sowBar, sowPrice, "SOW", false))
if newLPSY
    f_keepEvent(f_drawEvent(lpsyBar, lpsyPrice, "LPSY", true))

// =================================================
// TR ZONE & LEVELS
// =================================================
if newCHoCH and showZone and not na(bcBar) and not na(bcPrice) and not na(arPrice)
    trZone := box.new(
         left         = bcBar,
         top          = bcPrice,
         right        = bar_index + 10,
         bottom       = arPrice,
         bgcolor      = color.new(neutralColor, zoneTransp),
         border_color = color.new(neutralColor, 60),
         border_width = 1,
         extend       = extend.none)

if distActive and postPhase < 6 and showZone and not na(trZone)
    box.set_right(trZone, bar_index + 10)

// Freeze zone on LPSY - extend slightly beyond LPSY bar, but only once.
// We guard with (postPhase == 6 and newLPSY) so it runs exactly on the LPSY bar,
// when bar_index is close to lpsyBar (no far-history reference).
if newLPSY and showZone and not na(trZone)
    box.set_right(trZone, bar_index + 5)

if newCHoCH and showEventLevels and not na(bcBar) and not na(bcPrice)
    bcLine := line.new(bcBar, bcPrice, bar_index + 25, bcPrice, color = bearColor, width = lineWidthDom, style = line.style_solid)

if newCHoCH and showEventLevels and not na(arBar) and not na(arPrice)
    arLine := line.new(arBar, arPrice, bar_index + 25, arPrice, color = accentColor, width = lineWidthMid, style = line.style_solid)

if not na(bcLine) and distActive and postPhase < 6 and showEventLevels
    line.set_x2(bcLine, bar_index + 25)
if not na(arLine) and distActive and postPhase < 6 and showEventLevels
    line.set_x2(arLine, bar_index + 25)

if newCHoCH and showCHoCH and not na(chochBar) and not na(chochLevel)
    chochLine := line.new(chochBar - 20, chochLevel, bar_index + 15, chochLevel, color = accentColor, width = 1, style = line.style_dashed)

// Markdown projection
if newLPSY and showProjection and not na(bcPrice) and not na(arPrice) and not na(lpsyBar) and not na(lpsyPrice)
    trHeight   = bcPrice - arPrice
    projTarget = arPrice - trHeight
    projLine := line.new(lpsyBar, lpsyPrice, bar_index + 30, projTarget, color = bearColor, width = 1, style = line.style_dotted)
    projLbl = label.new(
         x         = bar_index + 30,
         y         = projTarget,
         text      = "Projected Markdown",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_left,
         color     = color.new(bearColor, 30),
         textcolor = whiteText,
         size      = labelSize)
    f_keepEvent(projLbl)

// Confluence halo
if showConfluence and confidence >= 85 and (newSOW or newLPSY)
    haloLbl = label.new(
         x         = bar_index,
         y         = high,
         text      = "*",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_none,
         textcolor = color.new(accentColor, 0),
         size      = labelSize)
    f_keepEvent(haloLbl)

// =================================================
// INFO PANEL
// =================================================
panelRows = showWatchlist ? 10 : 9

var table infoPanel = na
if showPanel and barstate.islast
    if not na(infoPanel)
        table.delete(infoPanel)
    infoPanel := table.new(
         position     = f_panelPos(panelPos),
         columns      = 2,
         rows         = panelRows,
         bgcolor      = panelBg,
         border_color = panelBorder,
         border_width = 1,
         frame_color  = panelBorder,
         frame_width  = 1)

    table.merge_cells(infoPanel, 0, 0, 1, 0)
    table.cell(infoPanel, 0, 0, "AG Pro Wyckoff Distribution", bgcolor = headerBg, text_color = headerText, text_size = panelSize)

    table.cell(infoPanel, 0, 1, "Current Phase", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSize)
    table.cell(infoPanel, 1, 1, phaseLetter,     bgcolor = panelBg, text_color = phaseColor,    text_size = panelSize)

    table.cell(infoPanel, 0, 2, "Last Event", bgcolor = panelBg, text_color = panelLabelCol,           text_size = panelSize)
    table.cell(infoPanel, 1, 2, lastEvent,    bgcolor = panelBg, text_color = f_eventColor(lastEvent), text_size = panelSize)

    confColor = confidence >= 85 ? bullColor : confidence >= 60 ? neutralColor : panelValueCol
    table.cell(infoPanel, 0, 3, "Confidence", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSize)
    table.cell(infoPanel, 1, 3, str.tostring(confidence, "#") + " / 100", bgcolor = panelBg, text_color = confColor, text_size = panelSize)

    table.cell(infoPanel, 0, 4, "Next Expected", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSize)
    table.cell(infoPanel, 1, 4, nextExpected,    bgcolor = panelBg, text_color = accentColor,   text_size = panelSize)

    table.cell(infoPanel, 0, 5, "Volume Context", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSize)
    table.cell(infoPanel, 1, 5, volCtx + "  (" + str.tostring(volRatio, "#.##") + "x)", bgcolor = panelBg, text_color = volCtxColor, text_size = panelSize)

    table.cell(infoPanel, 0, 6, "TR Status", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSize)
    table.cell(infoPanel, 1, 6, trStatus,    bgcolor = panelBg, text_color = trStatusColor, text_size = panelSize)

    table.cell(infoPanel, 0, 7, "Events Detected", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSize)
    table.cell(infoPanel, 1, 7, str.tostring(eventsDetected) + " / 6", bgcolor = panelBg, text_color = panelValueCol, text_size = panelSize)

    mdFollowText = mdFollowN == 0 ? "-" : str.tostring(int(math.round(mdFollowRate))) + "%  n=" + str.tostring(mdFollowN)
    mdFollowColor = mdFollowReady ? (mdFollowRate >= 55.0 ? bullColor : mdFollowRate >= 40.0 ? neutralColor : bearColor) : panelLabelCol
    table.cell(infoPanel, 0, 8, "Markdown Follow", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSize)
    table.cell(infoPanel, 1, 8, mdFollowText, bgcolor = panelBg, text_color = mdFollowColor, text_size = panelSize)

    if showWatchlist
        table.cell(infoPanel, 0, 9, "Watching",   bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSize)
        table.cell(infoPanel, 1, 9, watchStatus, bgcolor = panelBg, text_color = watchColor,    text_size = panelSize)

// =================================================
// [FIX-D v2.2] DISTRIBUTION SUMMARY LABEL
// Floating label on the right edge of the chart - visible even when the actual
// BC/PSY/AR labels are off-screen to the left. Updated each bar on the last
// rendered candle so the user always knows what phase is active.
// =================================================
var label summaryLabel = na

if barstate.islast
    if not na(summaryLabel)
        label.delete(summaryLabel)
        summaryLabel := na
    if showSummary and distActive and not na(bcPrice)
        summaryTxt = "Distribution Active  |  " + phaseLetter + "\nBC " + str.tostring(bcPrice, format.mintick) + (not na(arPrice) ? "   AR " + str.tostring(arPrice, format.mintick) : "") + "\nNext: " + nextExpected
        summaryCol = postPhase >= 5 ? bearColor : neutralColor
        summaryLabel := label.new(
             x         = bar_index + 15,
             y         = close,
             text      = summaryTxt,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             style     = label.style_label_left,
             color     = color.new(summaryCol, 15),
             textcolor = whiteText,
             size      = labelSize)

// =================================================
// ALERTS
// =================================================
if alertOnCHoCH and newCHoCH
    alert("Wyckoff Distribution - CHoCH confirmed. BC=" + str.tostring(bcPrice) + " | AR=" + str.tostring(arPrice), alert.freq_once_per_bar_close)

if alertOnEvent and (newUT or newSOW or newLPSY)
    alert("Wyckoff Distribution - New Event: " + lastEvent + " at " + str.tostring(close), alert.freq_once_per_bar_close)
````
