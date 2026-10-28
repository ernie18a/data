# Session Reaction Map [AGPro Series]

- url: https://www.tradingview.com/script/V6nxAoiL-Session-Reaction-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;726cc81296274d9c9aa3994894382623
- version: 6.0

## Description

Session Reaction Map [AGPro Series]

🔷 OVERVIEW

Session Reaction Map is a premium intraday study that maps how price reacts to the most important daily and weekly reference levels right at the opens of the Asia, London and New York sessions. Each session open is evaluated inside a fixed measurement window, and the resulting reaction is broken down into four dimensions: dominant move, close follow-through, wick rejection and counter-move penalty. The output is a single 0-100 reaction score that is then translated into tier-coded labels, premium reaction zones, an active reference band and a compact status panel, so you can instantly read what happened at each session open without scrolling through candles.

The indicator is designed for discretionary traders, systematic traders, SMC and price action practitioners who want a clean, consistent and quantitative way to read session open behaviour around PDH, PDL, PDM, Daily Open and Weekly Open. Reactions are drawn as directional zones (bull zones above the reference and bear zones below), with up or down pointing labels centered on the reaction, so orientation is always unambiguous.


🧭 UNIQUE EDGE

Most session open tools only mark time windows or highlight levels. Session Reaction Map goes further and quantifies the quality of the reaction itself. Four independent dimensions are measured against a fixed ATR-normalized baseline, and the final score determines not only whether a label is shown but also how prominent it is. Elite scores (80+) get the strongest visuals; strong scores (70-79) get a slightly softer treatment; watch scores (55-69) are coded as caution; anything below 55 is filtered out by default.

This separation between detection (a session open near a reference) and evaluation (the reaction quality score) is the core edge. It lets you focus only on the best intraday reactions and discard noise automatically, while still being able to audit every component by adjusting the ATR length, touch tolerance, evaluation window and score thresholds.


⚙️ METHODOLOGY

Session detection uses the chosen timezone and three session windows (Asia, London, New York), each with its own editable open range. When a session open occurs, the script checks whether the open price is within an ATR based touch tolerance of any enabled reference level (Previous Day High, Previous Day Low, Previous Day Mid, Daily Open or Weekly Open). If so, a reaction window is engaged on that bar and tracked for a configurable number of bars.

During the reaction window, the live zone, reference band and dashed reference line are updated in real time. When the window completes, the final score is computed as:

• Dominant move score (up to 45 points) - scaled against 1.20 x ATR
• Close follow-through score (up to 30 points) - scaled against 0.90 x ATR
• Wick rejection score (up to 15 points) - scaled against 0.50 x ATR
• Counter-move penalty (up to -20 points) - scaled against 1.00 x ATR

The sum is clamped into the 0-100 range and mapped into four tiers: Elite, Strong, Watch and Weak. The dominant direction of the reaction (up or down) is determined by comparing the upside excursion from the reference to the downside excursion from the reference during the window.


🎯 SIGNALS AND VISUALS

• Reaction zones - rectangular areas connecting the reference level with the reaction extreme, tier-coded by score and bias
• Active reference band - a thin accent band around the current reference level during a live reaction window
• Dashed reference line - marks the exact reference price while the reaction is being measured
• Tier-coded labels - up-pointing labels below bullish reactions and down-pointing labels above bearish reactions, centered on the reaction window
• Session dots - small colored markers that optionally display only on valid events, keeping the chart clean
• Active measurement highlight - an ultra-soft background shade on bars inside a live reaction window

Labels use a ring buffer overlap check, so dense multi-session conditions do not pile labels on top of each other. When two labels would visually conflict, the higher-scored reaction wins.


🛠️ KEY INPUTS

Sessions - enable/disable and edit Asia, London and New York session windows, each with its own color and timezone.

Reference Levels - individually toggle PDH, PDL, PDM, Daily Open and Weekly Open.

Reaction Logic - ATR length, touch tolerance in ATR, evaluation bars, label score filter, minimum label score, overlap reduction (bars and vertical ATR gap).

Visuals - show/hide reference levels, session dots, dots only on valid events, reaction zones, minimum score for zones, zone transparency and extension, live reaction zone, active reference band with its ATR size and transparency, active measurement highlight, level width, label size, label offset in ATR and label background transparency.

Panel - show/hide, position (six anchor points), Dark or Light theme, font size, optional guide row.

All numerical inputs carry professional English tooltips explaining their role, so the script can be tuned for any symbol, timeframe and trading style.


📘 HOW TO USE

1. Apply the script on an intraday timeframe. It is designed for intraday use and will stay passive on daily/higher timeframes.

2. Recommended starting timeframe is 4H for swing intraday context, and 1H for tactical intraday work. Lower timeframes (15m, 30m) work too but may produce dense output.

3. Start with the default settings. Observe which sessions and which reference levels generate the most Elite and Strong reactions on your symbol.

4. Use the panel to monitor the current state: last session, last reference, bias, score, tier, label filter, zone filter and the active reaction status.

5. Treat Elite (80+) and Strong (70-79) reactions as the main signals. Watch tier is informative and Weak tier is generally discarded.

6. Align with your own confluence: higher timeframe bias, structure, orderflow, or whatever your primary framework is. The script does not issue buy or sell calls - it scores reactions, and you decide.


⚠️ LIMITATIONS AND TRANSPARENCY

• This is not a strategy and does not place orders. No backtest statistics are implied.
• Reaction scores are computed after the evaluation window completes, so they are not repainting but are confirmed with a lag equal to the evaluation window size.
• The live reaction zone updates during the window and is finalized when the window closes.
• Session behavior varies significantly by symbol (crypto vs FX vs equities) and by volatility regime. Inputs should be tuned per symbol.
• Daily and Weekly references use standard request.security with barmerge.lookahead_off to avoid look-ahead bias.
• The script is not a forecasting tool. It is a post-event quantification of how price has just reacted to a known reference level.


🛡️ RISK DISCLOSURE

Trading involves substantial risk. Past reactions, patterns, zones or scores do not guarantee future performance. This script is provided for educational and analytical purposes only and is not financial advice. Always combine any tool with your own research, a defined risk plan and proper position sizing. You are solely responsible for your trading decisions.

## Source Code

````pine
// -------------------------------------------------
// Session Reaction Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.6
//
// Session Reaction Map evaluates how price reacts around daily and weekly
// reference levels during Asia, London, and New York session opens. It scores
// session-open reactions with directional expansion, close follow-through,
// wick rejection, and counter-move pressure, then maps premium reaction zones,
// centered badges, optional live tags, and a compact AG Pro panel for session
// open behavior, liquidity reaction, and intraday reference-level analysis.
// Version 2.6 strengthens confirmed reaction scoring, overlap-aware badge
// retention, non-overlapping Proof sampling, live-state semantics, and object
// lifecycle efficiency while preserving the original session-reaction model.
// -------------------------------------------------

//@version=6
indicator("Session Reaction Map [AGPro Series]",
     shorttitle       = "AG SRM",
     overlay          = true,
     max_labels_count = 140,
     max_lines_count  = 10,
     max_boxes_count  = 70,
     max_bars_back    = 500)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupSess = "Sessions"
string groupRef = "Reference Levels"
string groupLogic = "Reaction Logic"
string groupVisual = "Visuals"
string groupPanel = "Panel"
string groupProof = "Proof"
string groupAlerts = "Alerts"

string sessionTz = input.string("Etc/UTC", "Session Timezone", group = groupSess,
     tooltip = "Timezone used to evaluate session windows. Use Etc/UTC for a global session map, or a regional timezone for local session behavior.")

bool showAsia = input.bool(true, "Asia", group = groupSess, inline = "asia",
     tooltip = "Enables the Asia session reaction window.")
string asiaSess = input.session("0000-0100", "", group = groupSess, inline = "asia")
color asiaColor = input.color(color.rgb(34, 197, 166), "", group = groupSess, inline = "asia")

bool showLondon = input.bool(true, "London", group = groupSess, inline = "lon",
     tooltip = "Enables the London session reaction window.")
string londonSess = input.session("0800-0900", "", group = groupSess, inline = "lon")
color londonColor = input.color(color.rgb(245, 189, 92), "", group = groupSess, inline = "lon")

bool showNewYork = input.bool(true, "New York", group = groupSess, inline = "ny",
     tooltip = "Enables the New York session reaction window.")
string newYorkSess = input.session("1330-1430", "", group = groupSess, inline = "ny")
color newYorkColor = input.color(color.rgb(129, 140, 248), "", group = groupSess, inline = "ny")

bool usePDH = input.bool(true, "Previous Day High", group = groupRef,
     tooltip = "Includes Previous Day High as a candidate reference level.")
bool usePDL = input.bool(true, "Previous Day Low", group = groupRef,
     tooltip = "Includes Previous Day Low as a candidate reference level.")
bool usePDM = input.bool(true, "Previous Day Mid", group = groupRef,
     tooltip = "Includes Previous Day Mid as a candidate reference level.")
bool useDOpen = input.bool(true, "Daily Open", group = groupRef,
     tooltip = "Includes the current Daily Open as a candidate reference level.")
bool useWOpen = input.bool(true, "Weekly Open", group = groupRef,
     tooltip = "Includes the current Weekly Open as a candidate reference level.")

int atrLen = input.int(14, "ATR Length", minval = 1, maxval = 200, group = groupLogic,
     tooltip = "ATR length used to normalize reaction movement, wick behavior, zone sizing, and label spacing.")
float touchAtr = input.float(0.20, "Touch Tolerance ATR", minval = 0.01, maxval = 1.00, step = 0.01, group = groupLogic,
     tooltip = "Maximum ATR distance between the session open price and a reference level before the reaction window can engage.")
int evalBars = input.int(6, "Evaluation Bars", minval = 2, maxval = 50, group = groupLogic,
     tooltip = "Number of bars used to evaluate a reaction after the session window begins.")
int minScoreLabel = input.int(58, "Minimum Label Score", minval = 0, maxval = 100, group = groupLogic,
     tooltip = "Minimum reaction score required for a completed reaction label. The default keeps badges populated while still hiding the weakest reactions.")
int minScoreZone = input.int(52, "Minimum Zone Score", minval = 0, maxval = 100, group = groupLogic,
     tooltip = "Minimum reaction score required to keep a completed reaction zone on the chart. The default is tuned for a populated but not crowded public chart.")

bool showLevels = input.bool(true, "Show Reference Levels", group = groupVisual,
     tooltip = "Plots enabled daily and weekly reference levels. Disabled by default for a cleaner public chart; all level logic remains active.")
bool showSessionDots = input.bool(false, "Show Session Start Dots", group = groupVisual,
     tooltip = "Marks valid session reaction starts with compact dots. Disabled by default to keep the map premium and zone-focused.")
bool dotsOnlyValid = input.bool(true, "Dots Only On Valid Events", group = groupVisual,
     tooltip = "When enabled, session start dots appear only when the session open is near an enabled reference.")
bool showSessionTint = input.bool(true, "Show Session Tint", group = groupVisual,
     tooltip = "Adds a very light background tint while a valid reaction is being measured. Disabled by default because zones already carry the active context.")
bool showReactionZones = input.bool(true, "Show Reaction Zones", group = groupVisual,
     tooltip = "Draws finalized reaction zones when a completed session reaction reaches the minimum zone score.")
bool showLiveReaction = input.bool(true, "Show Live Reaction Zone", group = groupVisual,
     tooltip = "Displays a live reaction zone while the current session reaction is still being evaluated.")
bool showReferenceBand = input.bool(true, "Show Active Reference Band", group = groupVisual,
     tooltip = "Highlights the active reference level during an active reaction window. Disabled by default to reduce chart clutter.")
bool showZoneLabels = input.bool(true, "Show Centered Zone Badges", group = groupVisual,
     tooltip = "Places a compact solid badge in the center of finalized reaction zones.")
bool showLiveTags = input.bool(true, "Show Live State Tags", group = groupVisual,
     tooltip = "Shows compact right-edge tags for the latest session reaction and score. Disabled by default because the panel already carries live context.")
string labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = groupVisual,
     tooltip = "Controls annotation density. Balanced keeps enough context for public screenshots without crowding the chart.")
int boxTransparency = input.int(84, "Zone Transparency", minval = 55, maxval = 96, group = groupVisual,
     tooltip = "Transparency of finalized reaction zones. Higher values are softer.")
int liveBoxTransparency = input.int(90, "Live Zone Transparency", minval = 70, maxval = 98, group = groupVisual,
     tooltip = "Transparency of the live reaction zone.")
int zoneExtendBars = input.int(10, "Zone Extend Right", minval = 0, maxval = 50, group = groupVisual,
     tooltip = "Number of bars finalized reaction zones extend to the right.")
float referenceBandAtr = input.float(0.12, "Reference Band Size ATR", minval = 0.02, maxval = 0.50, step = 0.01, group = groupVisual,
     tooltip = "Half-height of the active reference band in ATR units.")
int levelWidth = input.int(1, "Level Width", minval = 1, maxval = 3, group = groupVisual,
     tooltip = "Line width for plotted reference levels.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Controls on-chart label, badge, and live tag font size.")
int maxFinalZones = input.int(14, "Maximum Final Zones", minval = 4, maxval = 60, group = groupVisual,
     tooltip = "Maximum number of finalized reaction zones and badges retained on the chart.")

bool showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Shows the compact panel with latest session, workflow, score, reference, bias, and active state.")
string panelPosition = input.string("Top Right", "Panel Location",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel,
     tooltip = "Controls where the panel is anchored on the chart.")
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Switches panel colors for dark or light chart backgrounds.")
string panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Controls panel text size.")

bool showProof = input.bool(true, "Show Proof Layer", group = groupProof,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across scored session reactions on the current symbol and timeframe. Follow means a scored reaction continued one risk unit (1R) in its direction before price returned through the reference level. These are historical outcome rates, not predictions.")
int proofHorizonBars = input.int(24, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof,
     tooltip = "Maximum number of bars each scored reaction is tracked for the proof measurement before it resolves at its current outcome.")
int reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof,
     tooltip = "Number of bars after a reaction is scored used to detect an immediate favorable follow-through reaction.")
float reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof,
     tooltip = "Minimum favorable follow-through progress toward the 1R target, within the reaction window, required to count as an early React.")

bool enableAlerts = input.bool(true, "Enable Alerts", group = groupAlerts,
     tooltip = "Master toggle for completed reaction and elite reaction alerts. Alerts are attention markers, not trade instructions.")

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg = color.rgb(37, 99, 235)
color headerText = color.rgb(245, 247, 250)
color panelBgDark = color.rgb(15, 23, 42)
color panelBgLight = color.rgb(248, 250, 252)
color panelBorderD = color.rgb(51, 65, 85)
color panelBorderL = color.rgb(203, 213, 225)
color panelLabelD = color.rgb(148, 163, 184)
color panelLabelL = color.rgb(71, 85, 105)
color panelValueD = color.rgb(226, 232, 240)
color panelValueL = color.rgb(15, 23, 42)
color bullColor = color.rgb(34, 197, 166)
color bearColor = color.rgb(244, 114, 182)
color neutralColor = color.rgb(245, 189, 92)
color accentColor = color.rgb(129, 140, 248)
color darkText = color.rgb(17, 24, 39)

bool isLightTheme = panelTheme == "Light"
color panelBg = isLightTheme ? panelBgLight : panelBgDark
color panelBorder = isLightTheme ? panelBorderL : panelBorderD
color panelLabelCol = isLightTheme ? panelLabelL : panelLabelD
color panelValueCol = isLightTheme ? panelValueL : panelValueD
color panelAltBg = isLightTheme ? color.rgb(241, 245, 249) : color.rgb(24, 35, 55)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(string p) =>
    switch p
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_dir_color(int dir) =>
    dir == 1 ? bullColor : bearColor

f_tier_text(int score) =>
    na(score) ? "-" : score >= 84 ? "Elite" : score >= 74 ? "Strong" : score >= 58 ? "Watch" : "Weak"

f_session_label(string sess) =>
    sess == "New York" ? "New York" : sess == "London" ? "London" : sess == "Asia" ? "Asia" : "-"

f_ref_label(string refName) =>
    refName == "D-Open" ? "D-Open" : refName == "W-Open" ? "W-Open" : refName == "PDH" ? "PDH" : refName == "PDL" ? "PDL" : refName == "PDM" ? "PDM" : "Reference"

f_action_text(int score, bool active, bool intradayOk) =>
    not intradayOk ? "INTRADAY ONLY" :
     active ? "MEASURE REACTION" :
     na(score) ? "WAIT SESSION" :
     score >= 84 ? "REVIEW ELITE" :
     score >= 74 ? "REVIEW REACTION" :
     score >= 58 ? "WATCH CONTEXT" : "WAIT SESSION"

f_action_color(string action, int dir) =>
    action == "REVIEW ELITE" ? f_dir_color(dir) :
     action == "MEASURE REACTION" ? accentColor :
     action == "REVIEW REACTION" ? neutralColor :
     action == "WATCH CONTEXT" ? neutralColor :
     action == "INTRADAY ONLY" ? neutralColor : neutralColor

f_zone_top(int dir, float refPrice, float hi, float lo) =>
    dir == 1 ? math.max(hi, refPrice + syminfo.mintick) : math.max(refPrice, lo + syminfo.mintick)

f_zone_bottom(int dir, float refPrice, float hi, float lo) =>
    dir == 1 ? math.min(refPrice, hi - syminfo.mintick) : math.min(lo, refPrice - syminfo.mintick)

f_pick_level(float price, float tol, float pdh, float pdl, float pdm, float dopen, float wopen) =>
    float bestLevel = na
    string bestName = ""
    float bestDist = 1e20
    if usePDH and not na(pdh)
        float d = math.abs(price - pdh)
        if d < bestDist
            bestDist := d
            bestLevel := pdh
            bestName := "PDH"
    if usePDL and not na(pdl)
        float d = math.abs(price - pdl)
        if d < bestDist
            bestDist := d
            bestLevel := pdl
            bestName := "PDL"
    if usePDM and not na(pdm)
        float d = math.abs(price - pdm)
        if d < bestDist
            bestDist := d
            bestLevel := pdm
            bestName := "PDM"
    if useDOpen and not na(dopen)
        float d = math.abs(price - dopen)
        if d < bestDist
            bestDist := d
            bestLevel := dopen
            bestName := "D-Open"
    if useWOpen and not na(wopen)
        float d = math.abs(price - wopen)
        if d < bestDist
            bestDist := d
            bestLevel := wopen
            bestName := "W-Open"
    [not na(bestLevel) and bestDist <= tol, bestName, bestLevel, bestDist]

f_score(int dir, float refPrice, float hi, float lo, float closePrice, float atrBase, float upperWick, float lowerWick) =>
    float upMove = math.max(0.0, hi - refPrice)
    float downMove = math.max(0.0, refPrice - lo)
    float domMove = dir == 1 ? upMove : downMove
    float oppMove = dir == 1 ? downMove : upMove
    float closeAway = dir == 1 ? math.max(0.0, closePrice - refPrice) : math.max(0.0, refPrice - closePrice)
    float wickMove = dir == 1 ? lowerWick : upperWick
    float base = math.max(atrBase, syminfo.mintick * 10.0)
    float domScore = f_clamp((domMove / (base * 1.20)) * 45.0, 0.0, 45.0)
    float closeScore = f_clamp((closeAway / (base * 0.90)) * 30.0, 0.0, 30.0)
    float wickScore = f_clamp((wickMove / (base * 0.50)) * 15.0, 0.0, 15.0)
    float oppPenalty = f_clamp((oppMove / (base * 1.00)) * 20.0, 0.0, 20.0)
    int(math.round(f_clamp(domScore + closeScore + wickScore - oppPenalty, 0.0, 100.0)))

f_panel_row(table panelRef, int row, string leftText, string rightText, color valueColor, string sizeInput) =>
    color rowBg = row % 2 == 0 ? panelAltBg : panelBg
    table.cell(panelRef, 0, row, leftText, text_color = panelLabelCol, bgcolor = rowBg, text_size = f_size(sizeInput), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, text_color = valueColor, bgcolor = rowBg, text_size = f_size(sizeInput), text_halign = text.align_right)

f_trim_reaction_bundles(
     array<box> boxes,
     array<label> labels,
     array<label> markers,
     array<int> labelBars,
     array<float> labelPrices,
     array<int> labelScores,
     int limit) =>
    while array.size(boxes) > limit
        box oldBox = array.shift(boxes)
        label oldLabel = array.shift(labels)
        label oldMarker = array.shift(markers)
        array.shift(labelBars)
        array.shift(labelPrices)
        array.shift(labelScores)
        if not na(oldBox)
            box.delete(oldBox)
        if not na(oldLabel)
            label.delete(oldLabel)
        if not na(oldMarker)
            label.delete(oldMarker)

labelSize = f_size(labelSizeInput)
panelSize = f_size(panelSizeInput)

// -------------------------------------------------
// Reference Levels
// -------------------------------------------------
float pdh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
float pdl = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_off)
float pdm = (pdh + pdl) * 0.5
float dopen = request.security(syminfo.tickerid, "D", open, barmerge.gaps_off, barmerge.lookahead_off)
float wopen = request.security(syminfo.tickerid, "W", open, barmerge.gaps_off, barmerge.lookahead_off)
int effectiveZoneScore = minScoreZone
int effectiveLabelScore = math.max(minScoreLabel, effectiveZoneScore)
int effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))
int engineWarmup = atrLen + 5
bool engineReady = bar_index > engineWarmup
bool proofConfirmedBar = barstate.isconfirmed

float atrRaw = ta.atr(atrLen)
float atr = math.max(nz(atrRaw, high - low), syminfo.mintick)

// -------------------------------------------------
// Session Detection
// -------------------------------------------------
bool intradayOk = timeframe.isintraday
bool inAsia = intradayOk and showAsia and not na(time(timeframe.period, asiaSess, sessionTz))
bool inLondon = intradayOk and showLondon and not na(time(timeframe.period, londonSess, sessionTz))
bool inNewYork = intradayOk and showNewYork and not na(time(timeframe.period, newYorkSess, sessionTz))

bool asiaStart = inAsia and not inAsia[1]
bool londonStart = inLondon and not inLondon[1]
bool newYorkStart = inNewYork and not inNewYork[1]

bool newSessionEvent = asiaStart or londonStart or newYorkStart
string eventNameNow = asiaStart ? "Asia" : londonStart ? "London" : newYorkStart ? "New York" : ""
color eventColorNow = asiaStart ? asiaColor : londonStart ? londonColor : newYorkStart ? newYorkColor : neutralColor

// -------------------------------------------------
// Event State
// -------------------------------------------------
var bool eventActive = false
var int eventStartIndex = na
var int eventDir = 0
var float eventRef = na
var string eventRefName = ""
var string eventSession = ""
var color eventColor = neutralColor
var float eventAtr = na
var float eventHigh = na
var float eventLow = na
var float eventUpperWickMax = na
var float eventLowerWickMax = na
var box activeReactionBox = na
var box activeReferenceBand = na
var label liveZoneLabel = na

var int lastScore = na
var string lastSession = "-"
var string lastReference = "-"
var string lastBias = "-"
var string lastTier = "-"
var int lastDirection = 0
var float lastRefPrice = na
var label liveSessionTag = na
var array<box> finalZoneBoxes = array.new<box>()
var array<label> finalZoneLabels = array.new<label>()
var array<label> finalZoneMarkers = array.new<label>()
var array<int> finalLabelBars = array.new_int()
var array<float> finalLabelPrices = array.new_float()
var array<int> finalLabelScores = array.new_int()

bool validAsiaStart = false
bool validLondonStart = false
bool validNewYorkStart = false
bool reactionCompleted = false
bool eliteReaction = false
reactionCompleted := false
eliteReaction := false

float touchTol = atr * touchAtr

// -------------------------------------------------
// Event Creation
// -------------------------------------------------
if newSessionEvent and not eventActive and engineReady
    [isValid, pickedName, pickedLevel, pickedDist] = f_pick_level(open, touchTol, pdh, pdl, pdm, dopen, wopen)
    if isValid
        if not na(activeReactionBox)
            box.delete(activeReactionBox)
        if not na(activeReferenceBand)
            box.delete(activeReferenceBand)
        if not na(liveZoneLabel)
            label.delete(liveZoneLabel)

        eventActive := true
        eventStartIndex := bar_index
        eventRef := pickedLevel
        eventRefName := pickedName
        eventSession := eventNameNow
        eventColor := eventColorNow
        eventAtr := atr
        eventHigh := high
        eventLow := low
        eventDir := close >= pickedLevel ? 1 : -1
        eventUpperWickMax := high - math.max(open, close)
        eventLowerWickMax := math.min(open, close) - low

        validAsiaStart := asiaStart
        validLondonStart := londonStart
        validNewYorkStart := newYorkStart

        if showLiveReaction
            float liveTop = f_zone_top(eventDir, pickedLevel, eventHigh, eventLow)
            float liveBottom = f_zone_bottom(eventDir, pickedLevel, eventHigh, eventLow)
            activeReactionBox := box.new(bar_index, liveTop, bar_index + 2, liveBottom, xloc = xloc.bar_index, bgcolor = color.new(f_dir_color(eventDir), liveBoxTransparency), border_color = color.new(f_dir_color(eventDir), math.max(liveBoxTransparency - 24, 0)), border_width = 1, text = "")

        if showReferenceBand
            float bandHalf = math.max(eventAtr * referenceBandAtr, syminfo.mintick * 2.0)
            activeReferenceBand := box.new(bar_index, pickedLevel + bandHalf, bar_index + 2, pickedLevel - bandHalf, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 90), border_color = color.new(accentColor, 68), border_width = 1, text = "")

// -------------------------------------------------
// Event Update / Finalize
// -------------------------------------------------
if eventActive
    eventHigh := math.max(eventHigh, high)
    eventLow := math.min(eventLow, low)
    float currentUpperWick = high - math.max(open, close)
    float currentLowerWick = math.min(open, close) - low
    eventUpperWickMax := math.max(nz(eventUpperWickMax, currentUpperWick), currentUpperWick)
    eventLowerWickMax := math.max(nz(eventLowerWickMax, currentLowerWick), currentLowerWick)
    float upMove = math.max(0.0, eventHigh - eventRef)
    float downMove = math.max(0.0, eventRef - eventLow)
    eventDir := upMove >= downMove ? 1 : -1

    if showLiveReaction
        float liveTop = f_zone_top(eventDir, eventRef, eventHigh, eventLow)
        float liveBottom = f_zone_bottom(eventDir, eventRef, eventHigh, eventLow)
        int liveCenterX = int(math.round((eventStartIndex + bar_index + 2) * 0.5))
        float liveCenterY = (liveTop + liveBottom) * 0.5
        color liveColor = f_dir_color(eventDir)
        if na(activeReactionBox)
            activeReactionBox := box.new(eventStartIndex, liveTop, bar_index + 2, liveBottom, xloc = xloc.bar_index, bgcolor = color.new(liveColor, liveBoxTransparency), border_color = color.new(liveColor, math.max(liveBoxTransparency - 24, 0)), border_width = 1, text = "")
        else
            box.set_lefttop(activeReactionBox, eventStartIndex, liveTop)
            box.set_rightbottom(activeReactionBox, bar_index + 2, liveBottom)
            box.set_bgcolor(activeReactionBox, color.new(liveColor, liveBoxTransparency))
            box.set_border_color(activeReactionBox, color.new(liveColor, math.max(liveBoxTransparency - 24, 0)))
            box.set_text(activeReactionBox, "")
        if showZoneLabels and labelDensity == "Detailed"
            string liveText = f_session_label(eventSession) + "\nMEASURE"
            if na(liveZoneLabel)
                liveZoneLabel := label.new(liveCenterX, liveCenterY, liveText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(liveColor, 0), textcolor = headerText, size = labelSize, textalign = text.align_center)
            else
                label.set_xy(liveZoneLabel, liveCenterX, liveCenterY)
                label.set_text(liveZoneLabel, liveText)
                label.set_color(liveZoneLabel, color.new(liveColor, 0))
                label.set_textcolor(liveZoneLabel, headerText)
                label.set_size(liveZoneLabel, labelSize)
        else if not na(liveZoneLabel)
            label.delete(liveZoneLabel)
            liveZoneLabel := na

    if showReferenceBand
        float bandHalf = math.max(eventAtr * referenceBandAtr, syminfo.mintick * 2.0)
        if na(activeReferenceBand)
            activeReferenceBand := box.new(eventStartIndex, eventRef + bandHalf, bar_index + 2, eventRef - bandHalf, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 90), border_color = color.new(accentColor, 68), border_width = 1, text = "")
        else
            box.set_lefttop(activeReferenceBand, eventStartIndex, eventRef + bandHalf)
            box.set_rightbottom(activeReferenceBand, bar_index + 2, eventRef - bandHalf)
            box.set_text(activeReferenceBand, "")

    if barstate.isconfirmed and bar_index - eventStartIndex >= evalBars - 1
        int score = f_score(eventDir, eventRef, eventHigh, eventLow, close, eventAtr, eventUpperWickMax, eventLowerWickMax)
        string tier = f_tier_text(score)
        string bias = eventDir == 1 ? "Up" : "Down"
        lastScore := score
        lastSession := eventSession
        lastReference := eventRefName
        lastBias := bias
        lastTier := tier
        lastDirection := eventDir
        lastRefPrice := eventRef
        reactionCompleted := true
        eliteReaction := score >= 84

        float zoneTop = f_zone_top(eventDir, eventRef, eventHigh, eventLow)
        float zoneBottom = f_zone_bottom(eventDir, eventRef, eventHigh, eventLow)
        color zoneColor = f_dir_color(eventDir)
        int finalRight = bar_index + zoneExtendBars

        if showReactionZones and score >= effectiveZoneScore
            int zoneTransp = int(f_clamp(boxTransparency - (score >= 84 ? 12 : score >= 74 ? 6 : 0), 55.0, 96.0))
            int borderTransp = score >= 84 ? 6 : score >= 74 ? 18 : 34
            int borderW = score >= 74 ? 2 : 1

            box newZoneBox = box.new(
                 eventStartIndex,
                 zoneTop,
                 finalRight,
                 zoneBottom,
                 xloc = xloc.bar_index,
                 bgcolor = color.new(zoneColor, zoneTransp),
                 border_color = color.new(zoneColor, borderTransp),
                 border_width = borderW,
                 text = "")

            label newZoneMarker = na
            bool markerQualified = score >= 74 or labelDensity == "Detailed"
            if markerQualified
                int markerX = int(math.round((eventStartIndex + finalRight) * 0.5))
                float markerY = eventDir == 1 ? zoneTop + eventAtr * 0.12 : zoneBottom - eventAtr * 0.12
                newZoneMarker := label.new(
                     markerX,
                     markerY,
                     "",
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = eventDir == 1 ? label.style_triangleup : label.style_triangledown,
                     color = color.new(zoneColor, score >= 84 ? 0 : 22),
                     size = score >= 84 ? size.small : size.tiny)

            label newZoneLabel = na
            int storedLabelBar = -1
            float storedLabelPrice = na
            int storedLabelScore = -1

            bool labelQualified = showZoneLabels and labelDensity != "Minimal" and score >= effectiveLabelScore
            if labelQualified
                float labelPct = eventDir == 1 ? 0.35 : 0.65
                int candidateX = eventStartIndex + int(math.round((finalRight - eventStartIndex) * labelPct))
                float zoneHeight = math.max(zoneTop - zoneBottom, syminfo.mintick)
                float centerY = (zoneTop + zoneBottom) * 0.5
                float labelNudge = math.min(zoneHeight * 0.16, eventAtr * 0.10)
                float candidateY = centerY + (eventDir == 1 ? labelNudge : -labelNudge)

                int overlapBars = labelDensity == "Detailed" ? 7 : 12
                float overlapGap = eventAtr * (labelDensity == "Detailed" ? 0.40 : 0.62)
                int conflictIndex = na

                if array.size(finalZoneLabels) > 0
                    for i = 0 to array.size(finalZoneLabels) - 1
                        label oldLabel = array.get(finalZoneLabels, i)
                        if not na(oldLabel)
                            int oldX = array.get(finalLabelBars, i)
                            float oldY = array.get(finalLabelPrices, i)
                            if math.abs(candidateX - oldX) <= overlapBars and math.abs(candidateY - oldY) <= overlapGap
                                conflictIndex := i
                                break

                bool keepNewLabel = true
                if not na(conflictIndex)
                    int oldScore = array.get(finalLabelScores, conflictIndex)
                    if score > oldScore
                        label oldLabel = array.get(finalZoneLabels, conflictIndex)
                        if not na(oldLabel)
                            label.delete(oldLabel)
                        array.set(finalZoneLabels, conflictIndex, na)
                        array.set(finalLabelBars, conflictIndex, -1)
                        array.set(finalLabelPrices, conflictIndex, na)
                        array.set(finalLabelScores, conflictIndex, -1)
                    else
                        keepNewLabel := false

                if keepNewLabel
                    string labelText = labelDensity == "Detailed" ?
                         f_session_label(eventSession) + "\n" + f_ref_label(eventRefName) + "\n" + str.tostring(score) + "/100" :
                         f_session_label(eventSession) + " " + str.tostring(score)

                    newZoneLabel := label.new(
                         candidateX,
                         candidateY,
                         labelText,
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         style = label.style_label_center,
                         color = color.new(zoneColor, 4),
                         textcolor = headerText,
                         size = labelSize,
                         textalign = text.align_center)

                    storedLabelBar := candidateX
                    storedLabelPrice := candidateY
                    storedLabelScore := score

            array.push(finalZoneBoxes, newZoneBox)
            array.push(finalZoneLabels, newZoneLabel)
            array.push(finalZoneMarkers, newZoneMarker)
            array.push(finalLabelBars, storedLabelBar)
            array.push(finalLabelPrices, storedLabelPrice)
            array.push(finalLabelScores, storedLabelScore)

            f_trim_reaction_bundles(
                 finalZoneBoxes,
                 finalZoneLabels,
                 finalZoneMarkers,
                 finalLabelBars,
                 finalLabelPrices,
                 finalLabelScores,
                 maxFinalZones)

        if not na(activeReactionBox)
            box.delete(activeReactionBox)
            activeReactionBox := na
        if not na(activeReferenceBand)
            box.delete(activeReferenceBand)
            activeReferenceBand := na
        if not na(liveZoneLabel)
            label.delete(liveZoneLabel)
            liveZoneLabel := na

        eventActive := false
        eventStartIndex := na
        eventDir := 0
        eventRef := na
        eventRefName := ""
        eventSession := ""
        eventAtr := na
        eventHigh := na
        eventLow := na
        eventUpperWickMax := na
        eventLowerWickMax := na

// -------------------------------------------------
// Confirmation-anchored proof (qualified scored reactions)
// -------------------------------------------------
bool qualifiedReactionEvent = reactionCompleted and not na(lastScore) and lastScore >= effectiveZoneScore

var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var int proofAmbiguous = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false

if proofConfirmedBar and engineReady
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favorableExcursion = pEvalDir == 1 ? high - pEvalEntry : pEvalEntry - low
        bool targetTouched = heldBars >= 1 and favorableExcursion >= followDist
        bool stopTouched = pEvalDir == 1 ? low <= pEvalStop : high >= pEvalStop
        bool ambiguousNow = targetTouched and stopTouched

        if heldBars >= 1 and heldBars <= effectiveReactBars and favorableExcursion >= followDist * reactProgressPct / 100.0
            pReacted := true
        if targetTouched and not stopTouched
            pFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        bool resolveNow = ambiguousNow or targetTouched or stopTouched or horizonDone

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if pFollowed
                    proofFollow := proofFollow + 1
                if not stopTouched
                    proofHold := proofHold + 1
                if pReacted
                    proofReact := proofReact + 1
                if stopTouched
                    proofFlip := proofFlip + 1
            pEvalActive := false

    // Open one non-overlapping Proof evaluation for a qualified completed
    // reaction. Later reactions are ignored until the active sample resolves.
    bool directionStillValid = lastDirection == 1 ? close > lastRefPrice : close < lastRefPrice
    if qualifiedReactionEvent and not pEvalActive and not na(lastRefPrice) and directionStillValid
        pEvalActive := true
        pEvalDir := lastDirection
        pEvalEntry := close
        pEvalStop := lastRefPrice
        float pRiskDistance = math.max(math.abs(close - lastRefPrice), syminfo.mintick)
        pEvalTarget := close + pEvalDir * pRiskDistance
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Plots
// -------------------------------------------------
color levelColMajor = color.new(color.silver, 78)
color levelColMid = color.new(color.gray, 88)
color levelColOpen = color.new(headerBg, 80)
color levelColWeek = color.new(neutralColor, 80)

plot(showLevels and usePDH ? pdh : na, "Previous Day High", color = levelColMajor, linewidth = levelWidth, style = plot.style_linebr)
plot(showLevels and usePDL ? pdl : na, "Previous Day Low", color = levelColMajor, linewidth = levelWidth, style = plot.style_linebr)
plot(showLevels and usePDM ? pdm : na, "Previous Day Mid", color = levelColMid, linewidth = levelWidth, style = plot.style_linebr)
plot(showLevels and useDOpen ? dopen : na, "Daily Open", color = levelColOpen, linewidth = levelWidth, style = plot.style_linebr)
plot(showLevels and useWOpen ? wopen : na, "Weekly Open", color = levelColWeek, linewidth = levelWidth, style = plot.style_linebr)

bool showAsiaDot = showSessionDots and asiaStart and (not dotsOnlyValid or validAsiaStart)
bool showLondonDot = showSessionDots and londonStart and (not dotsOnlyValid or validLondonStart)
bool showNewYorkDot = showSessionDots and newYorkStart and (not dotsOnlyValid or validNewYorkStart)

plotshape(showAsiaDot, title = "Asia Start", style = shape.circle, location = location.abovebar, size = size.tiny, color = color.new(asiaColor, 0))
plotshape(showLondonDot, title = "London Start", style = shape.circle, location = location.abovebar, size = size.tiny, color = color.new(londonColor, 0))
plotshape(showNewYorkDot, title = "New York Start", style = shape.circle, location = location.abovebar, size = size.tiny, color = color.new(newYorkColor, 0))

bgcolor(showSessionTint and eventActive ? color.new(eventColor, 96) : na, title = "Active Measurement Tint")

// -------------------------------------------------
// Hidden Exports
// -------------------------------------------------
plot(followRate, "SRM Follow Rate", display = display.none)
plot(holdRate, "SRM Hold Rate", display = display.none)
plot(reactRate, "SRM React Rate", display = display.none)
plot(flipRate, "SRM Flip Rate", display = display.none)
plot(proofAmbiguous, "SRM Ambiguous Proof Count", display = display.none)
plot(lastScore, "SRM Last Reaction Score", display = display.none)
plot(lastDirection, "SRM Last Reaction Direction", display = display.none)
plot(eventActive ? 1 : 0, "SRM Active Measurement State", display = display.none)
plot(array.size(finalZoneBoxes), "SRM Retained Zone Count", display = display.none)

// -------------------------------------------------
// Live Tags
// -------------------------------------------------
string actionText = f_action_text(lastScore, eventActive, intradayOk)
color actionColor = f_action_color(actionText, lastDirection == 0 ? 1 : lastDirection)
bool hasSessionContext = eventActive or not na(lastScore)

if barstate.islast
    if showLiveTags and hasSessionContext
        int tagX = bar_index + 8
        float tagY = close + atr * 1.15
        color tagColor = eventActive ? eventColor : lastDirection == 1 ? bullColor : lastDirection == -1 ? bearColor : neutralColor
        string tagText = eventActive ? "Measure " + f_session_label(eventSession) : f_session_label(lastSession) + " " + str.tostring(nz(lastScore, 0))

        if na(liveSessionTag)
            liveSessionTag := label.new(
                 tagX,
                 tagY,
                 tagText,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_left,
                 color = color.new(tagColor, 4),
                 textcolor = headerText,
                 size = labelSize)
        else
            label.set_xy(liveSessionTag, tagX, tagY)
            label.set_text(liveSessionTag, tagText)
            label.set_style(liveSessionTag, label.style_label_left)
            label.set_color(liveSessionTag, color.new(tagColor, 4))
            label.set_textcolor(liveSessionTag, headerText)
            label.set_size(liveSessionTag, labelSize)
    else
        if not na(liveSessionTag)
            label.delete(liveSessionTag)
            liveSessionTag := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
string followTextPanel = proofTotal > 0 ? f_pct(followRate) : "-"
string holdTextPanel = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactTextPanel = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipTextPanel = proofTotal > 0 ? f_pct(flipRate) : "-"
color followColPanel = proofTotal > 0 ? f_rate_color(followRate) : panelValueCol
color holdColPanel = proofTotal > 0 ? f_rate_color(holdRate) : panelValueCol
color reactColPanel = proofTotal > 0 ? f_rate_color(reactRate) : panelValueCol
color flipColPanel = proofTotal > 0 ? f_flip_color(flipRate) : panelValueCol

int panelRowCount = showProof ? 12 : 7
var table panel = na
var string lastPanelPosition = ""
var string lastPanelTheme = ""
var string lastPanelSize = ""
var bool lastPanelVisible = false
var bool lastProofMode = false

bool panelNeedsReset = na(panel) or panelPosition != lastPanelPosition or panelTheme != lastPanelTheme or panelSizeInput != lastPanelSize or showPanel != lastPanelVisible or showProof != lastProofMode
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    if showPanel
        panel := table.new(f_pos(panelPosition), 2, panelRowCount, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
        table.cell(panel, 0, 0, "AG Pro Session Reaction Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        table.merge_cells(panel, 0, 0, 1, 0)
    else
        panel := na
    lastPanelPosition := panelPosition
    lastPanelTheme := panelTheme
    lastPanelSize := panelSizeInput
    lastPanelVisible := showPanel
    lastProofMode := showProof

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 1, 1, panelRowCount - 1)
    table.cell(panel, 0, 0, "AG Pro Session Reaction Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    string scoreText = eventActive ? "Measuring" : na(lastScore) ? "-" : str.tostring(lastScore) + " / 100 " + lastTier
    string sessionText = eventActive ? eventSession : lastSession
    string referenceText = eventActive ? eventRefName : lastReference
    string biasText = eventActive ? (eventDir == 1 ? "Up / Measuring" : "Down / Measuring") : lastBias + " / " + lastTier
    string activeText = eventActive ? eventSession + " / " + eventRefName : "Off"
    f_panel_row(panel, 1, "Workflow", actionText, actionText == "REVIEW ELITE" ? f_dir_color(lastDirection) : actionText == "MEASURE CONTEXT" ? accentColor : actionText == "WATCH CONTEXT" ? neutralColor : panelValueCol, panelSizeInput)
    f_panel_row(panel, 2, "Session", sessionText, panelValueCol, panelSizeInput)
    f_panel_row(panel, 3, "Reaction Score", scoreText, eventActive ? accentColor : na(lastScore) ? panelValueCol : lastScore >= 84 ? f_dir_color(lastDirection) : lastScore >= 74 ? neutralColor : lastScore >= 58 ? accentColor : panelValueCol, panelSizeInput)
    f_panel_row(panel, 4, "Reference", referenceText, panelValueCol, panelSizeInput)
    f_panel_row(panel, 5, "Liquidity Context", biasText, lastBias == "Up" ? bullColor : lastBias == "Down" ? bearColor : panelValueCol, panelSizeInput)
    f_panel_row(panel, 6, "Active Window", activeText, eventActive ? eventColor : panelValueCol, panelSizeInput)
    if showProof
        color proofHeadBg = 7 % 2 == 0 ? panelAltBg : panelBg
        table.cell(panel, 0, 7, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 7, proofSampleText, text_color = panelLabelCol, bgcolor = proofHeadBg, text_size = panelSize, text_halign = text.align_right)
        f_panel_row(panel, 8, "Follow Rate", followTextPanel, followColPanel, panelSizeInput)
        f_panel_row(panel, 9, "Hold Rate", holdTextPanel, holdColPanel, panelSizeInput)
        f_panel_row(panel, 10, "React Rate", reactTextPanel, reactColPanel, panelSizeInput)
        f_panel_row(panel, 11, "Flip Rate", flipTextPanel, flipColPanel, panelSizeInput)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(enableAlerts and reactionCompleted, "Session Reaction Completed", "Session Reaction Map: a session reaction completed. This is an attention marker, not a trade instruction.")
alertcondition(enableAlerts and eliteReaction, "Elite Session Reaction", "Session Reaction Map: an elite session reaction completed. This is an attention marker, not a trade instruction.")
````
