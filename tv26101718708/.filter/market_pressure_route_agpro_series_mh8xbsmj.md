# Market Pressure Route [AGPro Series]

- url: https://www.tradingview.com/script/Mh8Xbsmj-Market-Pressure-Route-AGPro-Series/
- type: indicator
- pine_id: PUB;8d0126151525404d8ebd31d1ad20f9ad
- version: 5.0

## Description

Market Pressure Route [AGPro Series]

🌊 Overview
─────────────────────────────────────────────────
Market Pressure Route visualizes the directional buying/selling pressure of a market as a flowing route that tracks price from above or below, and classifies the texture of that flow in real time as Clean, Stalling, Exhausted, or Broken. It is a visualization and classification tool built around two original analytics: the Directional Pressure Score (DPS) and the Route Continuity Index (RCI). The route does not predict price — it describes how clean, consistent, and energetic the current pressure is, so you can read the order-flow texture at a glance.


🔹 Unique Edge
─────────────────────────────────────────────────
Most pressure, flow, or delta-style indicators collapse to a single oscillator or histogram and leave the trader to interpret the number. Market Pressure Route takes a different route.

• Dual-layer engine — DPS measures how directional pressure is; RCI measures how consistent that pressure has been over a lookback window. Pressure without continuity is noise; continuity without pressure is drift. Only the combination qualifies as a Clean route.

• Route, not oscillator — the analytic flows as a colored band above or below price. You read the texture of the market in the same place you read price, not in a separate pane.

• Four-state classification — Clean, Stalling, Exhausted, Broken. Every bar lands in exactly one state, driven by a deterministic decision tree. No grey zones, no ambiguous signals.

• Magnitude-gated break detection — a sign flip in pressure only counts as a Broken route when the flip happens with enough energy. This suppresses the low-amplitude zero-line noise that plagues most flow tools.

• Institutional-grade presentation — compact AGPro panel with live state, direction, DPS bar widget, RCI, and a continuity Flow bar. Badges only mark the transitions that change the market story; Stall and Exhaust transitions are conveyed by route color alone.


🔹 Methodology
─────────────────────────────────────────────────
Directional Pressure Score (DPS) — a composite bounded in [-1, +1] blending four bar-level microstructure components:
• Body (45%): closing conviction within the bar range
• Close Location (25%): close position relative to the bar midpoint
• Volume (20%): clamped z-score of volume vs a 50-bar baseline
• Gap (10%): open-to-prior-close gap, ATR-scaled
The raw score is clamped to [-1, +1] and then EMA-smoothed with the Pressure Length.

Route Continuity Index (RCI) — a [0, 1] score combining:
• Persistence (65%): fraction of bars in the lookback whose DPS sign matches the current sign
• Stability (35%): one minus the normalized dispersion of DPS across the window
Stability is calibrated for the bounded [-1, +1] range of DPS so that RCI remains resolute and does not saturate near 1.0 on quiet markets.

State Classification — a deterministic ternary decision tree:
• Broken — the pressure sign has just flipped with magnitude above the Broken Minimum DPS. Held for up to five bars as a cooldown so the transition is visible.
• Clean — qualifies via either a magnitude path (|DPS| above Clean DPS threshold and RCI above Clean RCI threshold) or a continuity path (RCI above 0.75 with minimum pressure above the Stalling DPS threshold). The dual path handles rally/selloff asymmetry.
• Stalling — pressure still present (|DPS| above Stalling threshold) but continuity has weakened (RCI below Clean levels).
• Exhausted — pressure has faded below the Stalling threshold or is losing magnitude.


🔹 Signals & Alerts
─────────────────────────────────────────────────
State transitions are exposed in two places:

On-chart badges:
• CLEAN UP — bullish Clean route has just formed
• CLEAN DOWN — bearish Clean route has just formed
• BROKEN — pressure direction has just flipped with magnitude
Intermediate Stall and Exhaust transitions are conveyed by route color change only, keeping the chart uncluttered. A price-clustering filter suppresses repeated same-type badges in the same zone so sideways markets stay institutional.

Alerts (both alert() calls and alertcondition() entries):
• Clean Bullish Route
• Clean Bearish Route
• Route Stalling
• Route Exhausted
• Route Broken


🔹 Key Inputs
─────────────────────────────────────────────────
Core Analytics:
• Pressure Length — EMA length applied to DPS (default 14)
• Route Smoothing — visual smoothing for the route band only (default 3)
• Route Continuity Lookback — bars used to compute RCI (default 10)
• Strict Route Filter — raises Clean thresholds by 0.10 for higher timeframes

Classification Thresholds:
• Clean DPS / Clean RCI — magnitude-path qualification levels
• Stalling DPS — minimum pressure to stay out of Exhausted
• Broken Minimum DPS — magnitude gate for break detection

Visual:
• Show Route Band, Minimal Mode, Price Tint
• Route Band Offset in ATR units
• Show State Badges toggle

Panel:
• Show Panel, Location (five positions), Font Size (Tiny to Large)
• Label Font Size


🔹 How to Use
─────────────────────────────────────────────────
• Context reading — the route color tells you what kind of flow you are in before you take any decision. A bright green or pink route with a strong Flow bar is a clean regime; a grey route is an exhausted regime.
• Transition awareness — BROKEN badges mark moments where the pressure narrative has changed with energy. Use them as context signals, not as entries.
• Higher-timeframe bias — many users enable Strict Route Filter on the daily and weekly to isolate only the strongest Clean routes, then drop to intraday for execution.
• Works on any liquid market with reliable volume: crypto, majors in FX, indices, and large-cap equities. Low-volume pairs dilute the volume component of DPS.


🔹 Limitations & Transparency
─────────────────────────────────────────────────
• This is a classification and visualization tool. It does not forecast price, it does not generate buy or sell orders, and it is not a strategy.
• DPS relies on a reliable volume series. Instruments with synthetic or missing volume will weight the volume component poorly.
• Route color and state describe the current bar's classification and update in real time. Final state for any bar is determined at bar close.
• No indicator identifies every turn in the market. Clean routes can exhaust without breaking; Broken routes do not guarantee a reversal of price.


🔹 Risk Disclosure
─────────────────────────────────────────────────
This script is provided for educational and analytical purposes only. It is not financial advice, not a trading recommendation, and not a solicitation to buy or sell any asset. Trading involves significant risk, including the possible loss of principal. Past performance and historical signal behavior do not guarantee future results. Always perform your own research and risk management, and size your positions according to your own risk tolerance.

## Source Code

````pine
// -------------------------------------------------
// Market Pressure Route [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 3.6
//
// Market Pressure Route visualizes directional buying and selling pressure as
// a clean route above or below price. The engine blends Directional Pressure
// Score (DPS), Route Continuity Index (RCI), pressure momentum, and route-state
// classification to help traders read whether pressure is clean, stalling,
// exhausted, or broken. It is an analytical visualization tool, not a
// prediction engine, not an automated strategy, and not financial advice.
// V3.6 adds a confirmation-anchored proof layer (Follow, Hold, React, Flip
// rates) measuring how often clean routes followed through in their direction,
// and replaces the redundant review row.
// -------------------------------------------------

//@version=6
indicator("Market Pressure Route [AGPro Series]",
     shorttitle       = "AG MPR",
     overlay          = true,
     max_lines_count  = 120,
     max_labels_count = 220,
     max_boxes_count  = 40,
     max_bars_back    = 500)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
grpCore = "Core Analytics"

pressureLength = input.int(14, "Pressure Length",
     minval = 5, maxval = 80, step = 1, group = grpCore,
     tooltip = "EMA length applied to the Directional Pressure Score. Lower values react faster but may create a noisier route; higher values create a cleaner but slower pressure path.")

routeSmoothing = input.int(3, "Route Smoothing",
     minval = 1, maxval = 10, step = 1, group = grpCore,
     tooltip = "Visual smoothing applied to the route band. This affects the drawn path only and does not change the pressure score, continuity score, or state classification.")

continuityLookback = input.int(10, "Route Continuity Lookback",
     minval = 5, maxval = 30, step = 1, group = grpCore,
     tooltip = "Number of bars used to compute the Route Continuity Index. Higher continuity means pressure direction has stayed more consistent across the window.")

strictFilter = input.bool(false, "Strict Route Filter", group = grpCore,
     tooltip = "Raises Clean route qualification thresholds. Use this on higher timeframes or noisy symbols when only stronger pressure routes should be highlighted.")

grpThr = "Classification Thresholds"

cleanDPSThr = input.float(0.18, "Clean DPS Threshold",
     minval = 0.08, maxval = 0.80, step = 0.01, group = grpThr,
     tooltip = "Absolute DPS required to qualify as a Clean route through the pressure-magnitude path. Useful default values are usually between 0.15 and 0.25.")

cleanRCIThr = input.float(0.50, "Clean RCI Threshold",
     minval = 0.30, maxval = 0.95, step = 0.05, group = grpThr,
     tooltip = "Continuity required to qualify as a Clean route through the pressure-magnitude path. Higher values require more consistent one-sided pressure.")

stallDPSThr = input.float(0.10, "Stalling DPS Threshold",
     minval = 0.05, maxval = 0.60, step = 0.01, group = grpThr,
     tooltip = "Minimum absolute DPS required to stay in the Stalling state. Below this level, pressure is treated as exhausted.")

brokenMinDPS = input.float(0.12, "Broken Minimum DPS",
     minval = 0.05, maxval = 0.60, step = 0.01, group = grpThr,
     tooltip = "Minimum absolute DPS required at a pressure sign flip before the route can be classified as Broken. This suppresses low-energy zero-line noise.")

grpViz = "Visuals"

showRoute = input.bool(true, "Show Route Band", group = grpViz,
     tooltip = "Displays the flowing pressure route band above or below price.")

showPriceTint = input.bool(false, "Show Price Tint", group = grpViz,
     tooltip = "Applies a subtle state color to candles. Disabled by default for a cleaner publication look.")

showBadges = input.bool(true, "Show Transition Labels", group = grpViz,
     tooltip = "Shows compact labels on meaningful route-state changes. Labels are spaced and capped to keep the chart premium rather than crowded.")

showLiveTags = input.bool(true, "Show Live Route Tags", group = grpViz,
     tooltip = "Shows right-edge live tags for the current route state and pressure quality score.")

labelDensity = input.string("Balanced", "Label Density",
     options = ["Minimal", "Balanced", "Detailed"], group = grpViz,
     tooltip = "Controls historical label density. Minimal shows only major route changes, Balanced keeps enough context for publication screenshots, and Detailed keeps more transition context.")

minimalMode = input.bool(false, "Minimal Route Mode", group = grpViz,
     tooltip = "Draws the route as a single line instead of a filled band. Useful when the chart already contains many overlays.")

atrMult = input.float(0.28, "Route Band Offset (ATR)",
     minval = 0.10, maxval = 1.00, step = 0.05, group = grpViz,
     tooltip = "Distance of the route band from price in ATR units. The default gives labels and the route breathing room around candles.")

routeWidth = input.float(0.20, "Route Band Width (ATR)",
     minval = 0.08, maxval = 0.60, step = 0.02, group = grpViz,
     tooltip = "Thickness of the pressure route band. Wider bands are more visible; narrower bands are more discreet.")

labelOffsetAtr = input.float(1.05, "Transition Label Offset ATR",
     minval = 0.40, maxval = 3.00, step = 0.05, group = grpViz,
     tooltip = "ATR-based vertical offset used to keep transition labels clear of candles and route bands.")

liveTagOffsetBars = input.int(10, "Live Tag Offset Bars",
     minval = 3, maxval = 40, group = grpViz,
     tooltip = "Horizontal offset used to push live route tags away from the latest candle cluster.")

labelSizeInput = input.string("Normal", "Label Font Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = grpViz,
     tooltip = "Controls on-chart transition label and live tag font size.")

grpPanel = "Panel"

showPanel = input.bool(true, "Show Panel", group = grpPanel,
     tooltip = "Displays the compact pressure-route panel with workflow, state, direction, DPS, RCI, momentum, score, and review context.")

panelPosition = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"],
     group = grpPanel,
     tooltip = "Controls where the panel is anchored on the chart, including center positions for cleaner publication layouts.")

panelTheme = input.string("Dark", "Panel Theme",
     options = ["Dark", "Light"], group = grpPanel,
     tooltip = "Switches the panel color scheme for dark or light chart backgrounds.")

panelSizeInput = input.string("Normal", "Panel Font Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel,
     tooltip = "Controls panel text size.")

grpAlerts = "Alerts"

alertOnClean = input.bool(true, "Alert: Clean Route", group = grpAlerts,
     tooltip = "Creates an attention marker when the route enters a Clean state.")

alertOnStall = input.bool(false, "Alert: Stalling Route", group = grpAlerts,
     tooltip = "Creates an attention marker when pressure starts stalling.")

alertOnExhaust = input.bool(true, "Alert: Exhausted Route", group = grpAlerts,
     tooltip = "Creates an attention marker when pressure becomes exhausted.")

alertOnBroken = input.bool(true, "Alert: Broken Route", group = grpAlerts,
     tooltip = "Creates an attention marker when a magnitude-qualified pressure flip breaks the route.")

grpProof = "Proof"

showProof = input.bool(true, "Show Proof Layer", group = grpProof,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across clean-route entries on the current symbol and timeframe. Follow means price advanced one risk unit in the clean-route direction before giving back the same distance against it. These are historical outcome rates, not predictions.")

proofStopAtr = input.float(1.20, "Proof Risk Unit (ATR)",
     minval = 0.30, maxval = 5.00, step = 0.10, group = grpProof,
     tooltip = "ATR distance used as one risk unit for the proof measurement. The favorable target and the adverse reference are both placed this far from the clean-route entry.")

proofHorizonBars = input.int(40, "Proof Horizon Bars",
     minval = 4, maxval = 300, group = grpProof,
     tooltip = "Maximum number of bars each clean-route entry is tracked for the proof measurement before it resolves at its current outcome.")

reactBars = input.int(3, "Reaction Window Bars",
     minval = 1, maxval = 40, group = grpProof,
     tooltip = "Number of bars after a clean-route entry used to detect an immediate favorable follow-through reaction.")

reactProgressPct = input.float(40.0, "Reaction Progress %",
     minval = 5.0, maxval = 90.0, step = 1.0, group = grpProof,
     tooltip = "Minimum favorable progress toward the risk-unit target, within the reaction window, required to count as an early React.")

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgDark   = color.rgb(15, 23, 42)
panelBgLight  = color.rgb(248, 250, 252)
panelBorderD  = color.rgb(51, 65, 85)
panelBorderL  = color.rgb(203, 213, 225)
panelLabelD   = color.rgb(148, 163, 184)
panelLabelL   = color.rgb(71, 85, 105)
panelValueD   = color.rgb(226, 232, 240)
panelValueL   = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
exhaustColor  = color.rgb(96, 125, 156)
darkText      = color.rgb(17, 24, 39)

isLightTheme = panelTheme == "Light"
panelBg = isLightTheme ? panelBgLight : panelBgDark
panelBorder = isLightTheme ? panelBorderL : panelBorderD
panelLabelCol = isLightTheme ? panelLabelL : panelLabelD
panelValueCol = isLightTheme ? panelValueL : panelValueD
panelAltBg = isLightTheme ? color.rgb(241, 245, 249) : color.rgb(24, 35, 55)
stallColor = neutralColor

// -------------------------------------------------
// Helpers
// -------------------------------------------------
ST_NONE = 0
ST_CLEAN = 1
ST_STALL = 2
ST_EXHAUST = 3
ST_BROKEN = 4

f_size(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(string p) =>
    switch p
        "Top Center" => position.top_center
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        => position.top_right

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_zscore(src, len) =>
    m = ta.sma(src, len)
    s = ta.stdev(src, len)
    s > 0.0 ? (src - m) / s : 0.0

f_state_color(int st, int sgn) =>
    switch st
        ST_CLEAN => sgn >= 0 ? bullColor : bearColor
        ST_STALL => stallColor
        ST_EXHAUST => exhaustColor
        ST_BROKEN => accentColor
        => exhaustColor

f_state_text_color(int st) =>
    st == ST_STALL ? darkText : headerText

f_route_color(int st, int sgn) =>
    switch st
        ST_CLEAN => sgn >= 0 ? bullColor : bearColor
        ST_STALL => neutralColor
        ST_EXHAUST => exhaustColor
        ST_BROKEN => accentColor
        => exhaustColor

f_state_text(int st, int sgn) =>
    switch st
        ST_CLEAN => sgn >= 0 ? "Clean Bull" : "Clean Bear"
        ST_STALL => "Stalling"
        ST_EXHAUST => "Exhausted"
        ST_BROKEN => "Broken"
        => "Waiting"

f_badge_text(int st, int sgn) =>
    switch st
        ST_CLEAN => sgn >= 0 ? "Clean Up" : "Clean Down"
        ST_STALL => "Pressure Stall"
        ST_EXHAUST => "Flow Exhausted"
        ST_BROKEN => "Route Broken"
        => ""

f_live_state_text(int st, int sgn) =>
    switch st
        ST_CLEAN => sgn >= 0 ? "Clean Bull" : "Clean Bear"
        ST_STALL => "Stalling"
        ST_EXHAUST => "Exhausted"
        ST_BROKEN => "Broken"
        => "Waiting"

f_workflow_text(int st, int sgn, float score, float momentum) =>
    switch st
        ST_CLEAN => score >= 70 ? "Track Clean Route" : "Monitor Route"
        ST_STALL => momentum < 0 ? "Review Stall" : "Wait For Expansion"
        ST_EXHAUST => "Wait For Pressure"
        ST_BROKEN => "Reset Route"
        => "Standby"

f_action_text(int st, int sgn) =>
    switch st
        ST_CLEAN => "MONITOR"
        ST_STALL => "WAIT"
        ST_EXHAUST => "WAIT"
        ST_BROKEN => "INVALIDATED"
        => "WAIT"

f_action_color(int st, int sgn) =>
    switch st
        ST_CLEAN => sgn >= 0 ? bullColor : bearColor
        ST_STALL => stallColor
        ST_EXHAUST => exhaustColor
        ST_BROKEN => accentColor
        => panelLabelCol

f_momentum_text(float value) =>
    value > 0.03 ? "Building" : value < -0.03 ? "Fading" : "Stable"

f_score_grade(int scoreValue) =>
    scoreValue >= 88 ? "A+" : scoreValue >= 76 ? "A" : scoreValue >= 64 ? "B" : scoreValue >= 52 ? "C" : "D"

f_score_text(int scoreValue) =>
    str.tostring(scoreValue) + " " + f_score_grade(scoreValue)

f_score_color(int scoreValue) =>
    scoreValue >= 76 ? bullColor : scoreValue >= 52 ? neutralColor : isLightTheme ? exhaustColor : panelValueCol

f_panel_route_text_color(int st, color fallbackColor) =>
    st == ST_EXHAUST and not isLightTheme ? panelValueCol : fallbackColor

f_rate_pct(value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(value) =>
    value >= 55.0 ? bullColor : value >= 40.0 ? neutralColor : bearColor

f_flip_color(value) =>
    value <= 30.0 ? bullColor : value <= 55.0 ? neutralColor : bearColor

panelSize = f_size(panelSizeInput)
labelSize = f_size(labelSizeInput)
maxVisibleBadges = labelDensity == "Detailed" ? 16 : labelDensity == "Balanced" ? 10 : 6

// -------------------------------------------------
// Directional Pressure Score
// -------------------------------------------------
atr14 = ta.atr(14)
rngOk = (high - low) > 0.0

bodyC = rngOk ? (close - open) / (high - low) : 0.0
locC = rngOk ? (close - (high + low) / 2.0) / (high - low) : 0.0
volC = f_clamp(f_zscore(volume, 50) / 3.0, -1.0, 1.0)
gapC = atr14 > 0.0 ? f_clamp((open - nz(close[1], open)) / atr14, -1.0, 1.0) : 0.0

dpsRaw = 0.45 * bodyC + 0.25 * locC + 0.20 * volC + 0.10 * gapC
dps = ta.ema(f_clamp(dpsRaw, -1.0, 1.0), pressureLength)
dpsAbs = math.abs(dps)
dpsSign = dps > 0.0 ? 1 : dps < 0.0 ? -1 : 0
dpsMom = dpsAbs - nz(dpsAbs[3], dpsAbs)

// -------------------------------------------------
// Route Continuity Index
// -------------------------------------------------
float persistSum = 0.0
for i = 0 to continuityLookback - 1
    sgn = dps[i] > 0.0 ? 1 : dps[i] < 0.0 ? -1 : 0
    if sgn == dpsSign and sgn != 0
        persistSum += 1.0

persistence = continuityLookback > 0 ? persistSum / continuityLookback : 0.0
stability = f_clamp(1.0 - ta.stdev(dps, continuityLookback) * 4.0, 0.0, 1.0)
rci = f_clamp(0.65 * persistence + 0.35 * stability, 0.0, 1.0)

// -------------------------------------------------
// Route State Classification
// -------------------------------------------------
effCleanDPS = strictFilter ? cleanDPSThr + 0.10 : cleanDPSThr
effCleanRCI = strictFilter ? cleanRCIThr + 0.10 : cleanRCIThr

var int prevSign = 0
flip = dpsSign != 0 and prevSign != 0 and dpsSign != prevSign
sigFlip = flip and dpsAbs >= brokenMinDPS
if dpsSign != 0
    prevSign := dpsSign

var int brokenBarsLeft = 0
brokenBarsLeft := sigFlip ? 5 : math.max(brokenBarsLeft - 1, 0)
inBroken = brokenBarsLeft > 0

cleanA = dpsAbs >= effCleanDPS and rci >= effCleanRCI
cleanB = rci >= 0.75 and dpsAbs >= stallDPSThr
isClean = cleanA or cleanB
isStall = dpsAbs >= stallDPSThr and rci >= 0.40

int routeState = ST_EXHAUST
routeState := inBroken ? ST_BROKEN :
     isClean ? ST_CLEAN :
     isStall ? ST_STALL :
     ST_EXHAUST

stateColor = f_state_color(routeState, dpsSign)
routeColor = f_route_color(routeState, dpsSign)
stateText = f_state_text(routeState, dpsSign)
actionText = f_action_text(routeState, dpsSign)
actionColor = f_action_color(routeState, dpsSign)

pressureScoreRaw =
     f_clamp(dpsAbs / math.max(effCleanDPS, 0.01), 0.0, 1.0) * 0.45 +
     rci * 0.40 +
     f_clamp((dpsMom + 0.08) / 0.16, 0.0, 1.0) * 0.15
pressureScore = int(math.round(f_clamp(pressureScoreRaw, 0.0, 1.0) * 100.0))
workflowText = f_workflow_text(routeState, dpsSign, pressureScore, dpsMom)
momentumText = f_momentum_text(dpsMom)

// -------------------------------------------------
// Confirmation-anchored proof (clean-route entries: Follow = 1R follow-through in route direction before 1R against)
// -------------------------------------------------
bool enteredCleanConfirmed = barstate.isconfirmed and routeState == ST_CLEAN and routeState[1] != ST_CLEAN and dpsSign != 0

var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false
var bool pFlipped = false

int proofWarmup = math.max(pressureLength, 50) + continuityLookback + 5
if barstate.isconfirmed and bar_index > proofWarmup
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favExc = pEvalDir * (close - pEvalEntry)
        if heldBars >= 1 and heldBars <= reactBars and favExc >= followDist * reactProgressPct / 100.0
            pReacted := true
        bool stopBreached = pEvalDir == 1 ? close < pEvalStop : close > pEvalStop
        bool hitTarget = heldBars >= 1 and favExc >= followDist
        if stopBreached
            pFlipped := true
        bool followNow = hitTarget and not pFlipped
        if followNow
            pFollowed := true
        bool naturalResolve = pFlipped or followNow or heldBars >= proofHorizonBars
        if naturalResolve or enteredCleanConfirmed
            proofTotal := proofTotal + 1
            if pFollowed
                proofFollow := proofFollow + 1
            if not pFlipped
                proofHold := proofHold + 1
            if pReacted
                proofReact := proofReact + 1
            if pFlipped
                proofFlip := proofFlip + 1
            pEvalActive := false
    if enteredCleanConfirmed and not pEvalActive
        float pRisk = math.max(atr14 * proofStopAtr, syminfo.mintick)
        pEvalActive := true
        pEvalDir := dpsSign
        pEvalEntry := close
        pEvalStop := close - dpsSign * pRisk
        pEvalTarget := close + dpsSign * pRisk
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Route Drawing
// -------------------------------------------------
routeSide = dps >= 0.0 ? -1.0 : 1.0
routeCenter = ta.ema(close + atr14 * atrMult * routeSide, routeSmoothing)
routeUpper = routeCenter + atr14 * routeWidth
routeLower = routeCenter - atr14 * routeWidth

pMid = plot(showRoute and not minimalMode ? routeCenter : na,
     title = "Route Center",
     color = color.new(routeColor, 10),
     linewidth = 3)

pUp = plot(showRoute and not minimalMode ? routeUpper : na,
     title = "Route Upper",
     color = color.new(routeColor, 100))

pLo = plot(showRoute and not minimalMode ? routeLower : na,
     title = "Route Lower",
     color = color.new(routeColor, 100))

fill(pUp, pLo, color = showRoute and not minimalMode ? color.new(routeColor, 78) : na, title = "Pressure Route Fill")

plot(showRoute and minimalMode ? routeCenter : na,
     title = "Route Minimal",
     color = color.new(routeColor, 12),
     linewidth = 2)

barcolor(showPriceTint and not minimalMode ? color.new(routeColor, 82) : na, title = "Price Tint")

// -------------------------------------------------
// Transition Labels
// -------------------------------------------------
var array<label> badgeLabels = array.new<label>()
var int lastBadgeBar = na
var int lastBadgeState = ST_NONE
var int lastBadgeStateBar = na
var float lastBadgePrice = na

tfSec = timeframe.in_seconds(timeframe.period)
baseSpacing = tfSec >= 86400 ? 3 : tfSec >= 14400 ? 5 : 10
densitySpacing = labelDensity == "Detailed" ? math.max(3, baseSpacing - 3) : labelDensity == "Balanced" ? baseSpacing : baseSpacing + 8
globalMinGap = labelDensity == "Detailed" ? 3 : labelDensity == "Balanced" ? 5 : 9

majorTransition = (routeState == ST_CLEAN and routeState[1] != ST_CLEAN) or (routeState == ST_BROKEN and routeState[1] != ST_BROKEN)
stallTransition = labelDensity != "Minimal" and routeState != routeState[1] and routeState == ST_STALL
exhaustTransition = labelDensity == "Detailed" and routeState != routeState[1] and routeState == ST_EXHAUST and pressureScore >= 58
textureTransition = stallTransition or exhaustTransition
badgeEvent = showBadges and barstate.isconfirmed and (majorTransition or textureTransition)
badgeTitle = f_badge_text(routeState, dpsSign)
badgeText = badgeTitle == "" ? "" : badgeTitle + "\n" + f_score_text(pressureScore)
badgeTextColor = f_state_text_color(routeState)
badgeOffset = math.max(atr14 * labelOffsetAtr, syminfo.mintick * 30.0)
badgeY = dpsSign >= 0 ? high + badgeOffset : low - badgeOffset
badgeStyle = dpsSign >= 0 ? label.style_label_down : label.style_label_up
sameStateOk = routeState != lastBadgeState or na(lastBadgeStateBar) or bar_index - lastBadgeStateBar >= densitySpacing
globalOk = na(lastBadgeBar) or bar_index - lastBadgeBar >= globalMinGap
priceOk = na(lastBadgePrice) or math.abs(badgeY - lastBadgePrice) >= atr14 * 0.80 or bar_index - nz(lastBadgeBar, bar_index) > 24

if badgeEvent and badgeText != "" and sameStateOk and globalOk and priceOk
    tip = "Market Pressure Route\nState: " + stateText + "\nDPS: " + str.tostring(dps, "0.00") + "\nRCI: " + str.tostring(rci, "0.00") + "\nScore: " + f_score_text(pressureScore) + "\nThis is an attention marker, not a trade instruction."
    lb = label.new(bar_index, badgeY, badgeText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = badgeStyle,
         color = color.new(stateColor, 0),
         textcolor = badgeTextColor,
         size = labelSize,
         textalign = text.align_center,
         tooltip = tip)
    array.push(badgeLabels, lb)
    while array.size(badgeLabels) > maxVisibleBadges
        old = array.shift(badgeLabels)
        if not na(old)
            label.delete(old)
    lastBadgeBar := bar_index
    lastBadgeState := routeState
    lastBadgeStateBar := bar_index
    lastBadgePrice := badgeY

if not showBadges and array.size(badgeLabels) > 0 and barstate.islast
    while array.size(badgeLabels) > 0
        old = array.shift(badgeLabels)
        if not na(old)
            label.delete(old)

// -------------------------------------------------
// Live Right-Edge Tags
// -------------------------------------------------
var label liveStateTag = na
var label liveScoreTag = na

if showLiveTags and barstate.islast
    tagX = bar_index + liveTagOffsetBars
    tagGap = math.max(atr14 * 1.15, close * 0.004)
    stateY = dpsSign >= 0 ? routeLower - tagGap * 0.30 : routeUpper + tagGap * 0.30
    liveStateText = f_live_state_text(routeState, dpsSign) + "\nScore " + f_score_text(pressureScore)
    liveTagTextColor = f_state_text_color(routeState)

    if na(liveStateTag)
        liveStateTag := label.new(tagX, stateY, liveStateText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(stateColor, 0), textcolor = liveTagTextColor, size = labelSize, textalign = text.align_center)
    else
        label.set_xy(liveStateTag, tagX, stateY)
        label.set_text(liveStateTag, liveStateText)
        label.set_color(liveStateTag, color.new(stateColor, 0))
        label.set_textcolor(liveStateTag, liveTagTextColor)
        label.set_size(liveStateTag, labelSize)

    if not na(liveScoreTag)
        label.delete(liveScoreTag)
        liveScoreTag := na
else if not showLiveTags
    if not na(liveStateTag)
        label.delete(liveStateTag)
        liveStateTag := na
    if not na(liveScoreTag)
        label.delete(liveScoreTag)
        liveScoreTag := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
dpsSigned = (dps >= 0.0 ? "+" : "") + str.tostring(dps, "0.00")
rciText = str.tostring(rci, "0.00")
dirTxt = dpsSign > 0 ? "Bullish" : dpsSign < 0 ? "Bearish" : "Neutral"
dirCol = dpsSign > 0 ? bullColor : dpsSign < 0 ? bearColor : exhaustColor
workflowPanelColor = f_panel_route_text_color(routeState, actionColor)
rciPanelColor = f_panel_route_text_color(routeState, routeColor)
proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
int panelRowCount = showProof ? 12 : 7

var table panel = na
var string lastPanelPosition = ""
var string lastPanelTheme = ""
var bool lastPanelVisible = false
var bool lastProofMode = false

panelNeedsRebuild = showPanel and (na(panel) or lastPanelPosition != panelPosition or lastPanelTheme != panelTheme or not lastPanelVisible or lastProofMode != showProof)

if panelNeedsRebuild
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_pos(panelPosition), 2, panelRowCount, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Market Pressure Route", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    lastPanelPosition := panelPosition
    lastPanelTheme := panelTheme
    lastPanelVisible := showPanel
    lastProofMode := showProof

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    lastPanelVisible := false

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_pos(panelPosition))
    table.clear(panel, 0, 1, 1, panelRowCount - 1)

    table.cell(panel, 0, 0, "AG Pro Market Pressure Route", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)

    table.cell(panel, 0, 1, "Workflow", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, workflowText, text_color = workflowPanelColor, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 2, "State", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, stateText, text_color = f_state_text_color(routeState), bgcolor = stateColor, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 3, "Direction", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, dirTxt, text_color = dirCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 4, "DPS", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, dpsSigned, text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 5, "RCI", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, rciText, text_color = rciPanelColor, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 6, "Momentum / Score", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, momentumText + " / " + f_score_text(pressureScore), text_color = f_score_color(pressureScore), bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    if showProof
        table.cell(panel, 0, 7, "Proof @ Confirm", text_color = accentColor, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 7, proofSampleText, text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)
        table.cell(panel, 0, 8, "Follow Rate", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 8, proofTotal > 0 ? f_rate_pct(followRate) : "-", text_color = proofTotal > 0 ? f_rate_color(followRate) : panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)
        table.cell(panel, 0, 9, "Hold Rate", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 9, proofTotal > 0 ? f_rate_pct(holdRate) : "-", text_color = proofTotal > 0 ? f_rate_color(holdRate) : panelValueCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)
        table.cell(panel, 0, 10, "React Rate", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 10, proofTotal > 0 ? f_rate_pct(reactRate) : "-", text_color = proofTotal > 0 ? f_rate_color(reactRate) : panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)
        table.cell(panel, 0, 11, "Flip Rate", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 11, proofTotal > 0 ? f_rate_pct(flipRate) : "-", text_color = proofTotal > 0 ? f_flip_color(flipRate) : panelValueCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
cleanFire = routeState == ST_CLEAN and routeState[1] != ST_CLEAN
stallFire = routeState == ST_STALL and routeState[1] != ST_STALL
exhaustFire = routeState == ST_EXHAUST and routeState[1] != ST_EXHAUST
brokenFire = routeState == ST_BROKEN and routeState[1] != ST_BROKEN

tfLabel = syminfo.ticker + " " + timeframe.period

if alertOnClean and cleanFire
    alert("Market Pressure Route - Clean " + dirTxt + " route on " + tfLabel + ". Attention marker only, not a trade instruction.", alert.freq_once_per_bar_close)

if alertOnStall and stallFire
    alert("Market Pressure Route - Route stalling on " + tfLabel + ". Attention marker only, not a trade instruction.", alert.freq_once_per_bar_close)

if alertOnExhaust and exhaustFire
    alert("Market Pressure Route - Route exhausted on " + tfLabel + ". Attention marker only, not a trade instruction.", alert.freq_once_per_bar_close)

if alertOnBroken and brokenFire
    alert("Market Pressure Route - Route broken on " + tfLabel + ". Attention marker only, not a trade instruction.", alert.freq_once_per_bar_close)

alertcondition(cleanFire and dpsSign >= 0, "Clean Bullish Route", "Market Pressure Route: clean bullish route. This is an attention marker, not a trade instruction.")
alertcondition(cleanFire and dpsSign < 0, "Clean Bearish Route", "Market Pressure Route: clean bearish route. This is an attention marker, not a trade instruction.")
alertcondition(stallFire, "Route Stalling", "Market Pressure Route: route stalling. This is an attention marker, not a trade instruction.")
alertcondition(exhaustFire, "Route Exhausted", "Market Pressure Route: route exhausted. This is an attention marker, not a trade instruction.")
alertcondition(brokenFire, "Route Broken", "Market Pressure Route: route broken. This is an attention marker, not a trade instruction.")

// Hidden reference plots
plot(dps, "Directional Pressure Score", display = display.none)
plot(rci, "Route Continuity Index", display = display.none)
plot(pressureScore, "Pressure Route Score", display = display.none)
plot(followRate, "MPR Follow Rate", display = display.none)
plot(holdRate, "MPR Hold Rate", display = display.none)
plot(reactRate, "MPR React Rate", display = display.none)
plot(flipRate, "MPR Flip Rate", display = display.none)
````
