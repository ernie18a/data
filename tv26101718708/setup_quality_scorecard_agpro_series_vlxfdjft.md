# Setup Quality Scorecard [AGPro Series]

- url: https://www.tradingview.com/script/VLxfdJfT-Setup-Quality-Scorecard-AGPro-Series/
- type: indicator
- pine_id: PUB;5e2fcc3a9eba4e2b809b59ccfa616e2f
- version: 4.0

## Description

Setup Quality Scorecard [AGPro Series]

Setup Quality Scorecard grades every bar on a transparent 0-100 scale across ten independent confluence dimensions. Instead of another signal generator, it is a quality filter: it tells you how strong the current setup is, which factors are firing, and how often similar past setups have followed through. Works on any symbol, any timeframe.

🔹 OVERVIEW

Every trader has the same question before pulling the trigger: "Is this setup actually good, or am I forcing it?" Setup Quality Scorecard answers that question with a single auditable number. The composite score blends ten orthogonal factors — trend, momentum, volume, volatility, structure, S/R proximity, divergence, candle quality, session context, and higher-timeframe alignment — into a weighted 0-100 quality rating. Bars scoring above the A-Tier threshold are marked with support/resistance-style zones on the chart, so high-quality setup regions stay visible even as the market moves on.

🔹 UNIQUE EDGE

Most quality indicators hide their internals behind a black-box algorithm. This one is fully transparent. Every factor exposes its own 0-10 score in the panel, every factor weight is user-adjustable, and every historical signal is evaluated against a forward-looking hit-rate test. There are no secret filters, no proprietary confidence bands, and no cherry-picked backtest. If a setup scores 87, you can see exactly which factors contributed and which did not.

🔹 METHODOLOGY

Each of the ten factors is computed independently on the current bar and normalized to a 0-10 scale:
1. Trend Alignment — EMA 20/50/200 stack plus slope confirmation
2. Momentum — RSI zone position combined with 3-bar RSI delta
3. Volume Context — relative volume versus 20-period SMA, calibrated for real-world distribution
4. Volatility Regime — ATR percentile over the last 100 bars, favoring mid-range regimes
5. Structure — HH/HL or LH/LL confirmation via recent pivots
6. S/R Proximity — ATR-normalized distance to the nearest pivot level
7. Divergence — price-versus-RSI regular divergence captured at pivot time
8. Candle Quality — body-to-range ratio and wick balance
9. Session Context — active trading session weighting (London/NY overlap prioritized)
10. HTF Agreement — graduated higher-timeframe alignment scoring (full stack, partial stack, opposed regimes)
The ten factor scores are weighted by user-adjustable coefficients, summed, and normalized to produce the final 0-100 composite. Tier labels (S / A / B / C / D) are assigned against user-configurable thresholds.

🔹 SIGNALS AND ALERTS

When a bar crosses into A-Tier or higher, a zone is drawn using support/resistance-style geometry (body plus a small ATR cushion). Zones merge automatically when adjacent qualifying setups share the same directional bias, preventing chart clutter. Each zone is labeled with its tier and score in compact A·83 format, with a dotted leader line connecting the label to the zone edge.
Four built-in alert conditions are exposed:
- S-Tier Setup Detected (score crosses the S-Tier threshold)
- A-Tier Setup Detected (score crosses the A-Tier threshold)
- New Bullish Quality Setup (first A-tier bullish bar in a run)
- New Bearish Quality Setup (first A-tier bearish bar in a run)

🔹 KEY INPUTS

- General: Higher timeframe reference, rolling history window, forward evaluation bars
- Thresholds: S / A / B / C tier cutoffs, fully adjustable
- Factor Weights: ten independent sliders, 0.0 to 2.0, tune the scorer to your style
- Zones: adaptive extend (auto or manual), merge window, max height cap in ATR units, maximum age
- Labels: on-chart label mode (A-Tier only, S-Tier only, off), size presets
- Panel: position, size, factor breakdown toggle

🔹 HOW TO USE

Start with defaults and observe for a full session on your chart. Trend traders should raise the Trend and HTF Align weights. Reversal traders should raise Divergence, Structure, and S/R Proximity. Use the Active count in the panel as a quick filter: fewer than three factors above seven generally means a weak setup regardless of composite score. Use the hit-rate number to sanity-check whether your current configuration is performing on this asset and timeframe — if it is below 50 percent on a large sample, revisit your weight assignments.

🔹 LIMITATIONS AND TRANSPARENCY

The hit-rate metric is backward-looking. It measures how often past A-tier signals produced a one-ATR directional move within the next N bars. It is not a forecast of future performance. A hit rate with fewer than twenty signals is flagged with an info marker because the sample size is not yet statistically meaningful. Factor definitions are static — they do not adapt to regime changes automatically. Session weighting assumes standard crypto and equity session times in UTC; adjust if you are trading exotic hours. The script uses pivot-based structure, which lags by the pivot length on the right edge of the chart (a standard trade-off for noise suppression).

🔹 RISK DISCLOSURE

This indicator is an analytical tool, not financial advice. It does not predict future price movements. A high quality score does not guarantee a winning trade. Past performance of any displayed signal does not indicate future results. Always use proper risk management and position sizing. Never trade with capital you cannot afford to lose.

## Source Code

````pine
// -------------------------------------------------
// Setup Quality Scorecard [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.2
//
// Setup Quality Scorecard is a chart-first setup readiness engine that grades
// whether the current market context is ready, blocked, or missing a key
// component. It keeps the public Scorecard identity, but adds cleaner decision
// rails, active invalidation mapping, target-room context, compact checklist
// markers, and a 0-100 readiness panel built around bias, location, momentum,
// risk, and next-action clarity. A stop-aware setup-proof
// rate adds an honest, symmetric follow-through track record to the panel.
// -------------------------------------------------

//@version=6
indicator("Setup Quality Scorecard [AGPro Series]",
     shorttitle = "AG Pro SQS",
     overlay = true,
     max_labels_count = 220,
     max_boxes_count = 55,
     max_lines_count = 90)

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
color dangerColor   = color.rgb(239, 68, 68)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttHtf = "Higher timeframe used for the bias confirmation component. The scorecard uses this only to judge setup context, not to create trade instructions."
string ttLookback = "Primary window used for recent pivots, target-room context, and volatility baselines. Higher values make the scorecard slower but more selective."
string ttAtr = "ATR length used for risk distance, target room, label offsets, and readiness pocket geometry."
string ttPivot = "Pivot length used to define the current decision reference, invalidation edge, and nearby target-room levels."
string ttFast = "Fast EMA used for short-term setup support and momentum context."
string ttMid = "Mid EMA used for trend support scoring."
string ttSlow = "Slow EMA used for broader trend support scoring."
string ttSensitivity = "Controls how strict the planner is with location distance and risk distance. Conservative is tighter, Balanced is standard, and Aggressive allows broader setup context."
string ttConfirm = "Close Confirmed waits for a closed bar before labels and alerts are printed. Live Updating lets the panel and active pocket update during the current bar."
string ttReady = "Minimum 0-100 readiness score required for READY state. This is an attention filter, not a trade instruction."
string ttMonitor = "Minimum 0-100 readiness score required for MONITOR state before the setup is strong enough for READY."
string ttRisk = "Maximum ATR-normalized distance between current price and the active invalidation edge before the setup becomes risk-heavy."
string ttIdealRisk = "Preferred ATR-normalized distance from price to invalidation. Scores are lower when risk is too tight or too stretched."
string ttTarget = "Target-room guide expressed as an R multiple from the current invalidation edge when no clean nearby swing target exists."
string ttRoom = "Minimum ATR-normalized target room preferred before a setup can become READY."
string ttVolume = "When enabled, relative volume contributes to the momentum component. Disable it for symbols where volume is unreliable."
string ttPocket = "Shows the active readiness pocket with a centered state badge. The pocket maps the current setup zone between price and the risk side of the plan."
string ttRails = "Shows the setup state rail, invalidation edge, and target-room guide. These are planning references, not trade instructions."
string ttRailLabels = "Shows filled decision, invalidation, and target-room badges on the active planning rails."
string ttChecklist = "Shows optional compact checklist context labels. The publication default keeps them hidden because READY and MONITOR labels already carry the main decision state."
string ttProjection = "Controls how far the active pocket and guide rails extend to the right."
string ttOpacity = "Transparency for the readiness pocket. Higher values make the pocket lighter."
string ttLabels = "Shows compact READY, MONITOR, and INVALIDATED labels with controlled spacing."
string ttContext = "Adds sparse checklist context labels during active setup review. Keep disabled for the cleanest publication preset."
string ttBlockedLabels = "Shows BLOCKED labels on the chart. The publication default keeps them hidden because blocked conditions are already shown in the panel and active pocket."
string ttFollowLabels = "Shows FOLLOW labels after target-room contact. The publication default keeps them hidden so low-score follow-through markers do not clutter the chart."
string ttScoreLabel = "Adds the 0-100 readiness score to chart labels."
string ttCooldown = "Minimum bars between event labels. Higher values reduce repeated labels in fast markets."
string ttContextSpacing = "Minimum bars between sparse checklist labels during ongoing setup review."
string ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first for performance."
string ttOffset = "ATR-based label offset that keeps labels above or below candles."
string ttLabelSize = "Controls all chart labels and centered pocket text. Normal is the recommended publication default."
string ttPanel = "Shows or hides the AG Pro scorecard panel. The default is visible for public-release readability."
string ttPanelLocation = "Moves the AG Pro scorecard panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
string ttPanelFont = "Controls panel text size. Normal is the recommended publication default."
string ttProofWin = "Maximum bars a setup-proof window stays open before it is left uncounted in the proof rate."
string ttProofTgt = "Symmetric follow-through distance, in ATR, measured from the readiness-event close. A proof counts as a win if setup-side follow-through reaches this distance before an equal adverse move occurs."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Setup Quality Engine"
string htfInput = input.timeframe("240", "Higher Timeframe", group = groupEngine, tooltip = ttHtf)
int lookbackBars = input.int(180, "Context Lookback", minval = 50, maxval = 800, group = groupEngine, tooltip = ttLookback)
int atrLength = input.int(14, "ATR Length", minval = 3, maxval = 100, group = groupEngine, tooltip = ttAtr)
int pivotLength = input.int(5, "Decision Pivot Length", minval = 2, maxval = 30, group = groupEngine, tooltip = ttPivot)
int fastEmaLength = input.int(21, "Fast Context EMA", minval = 2, maxval = 200, group = groupEngine, tooltip = ttFast)
int midEmaLength = input.int(50, "Mid Context EMA", minval = 3, maxval = 260, group = groupEngine, tooltip = ttMid)
int slowEmaLength = input.int(200, "Slow Context EMA", minval = 20, maxval = 500, group = groupEngine, tooltip = ttSlow)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = ttSensitivity)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)

string groupScore = "Readiness Score Model"
int readyScoreInput = input.int(74, "READY Score", minval = 45, maxval = 95, group = groupScore, tooltip = ttReady)
int monitorScoreInput = input.int(58, "MONITOR Score", minval = 25, maxval = 90, group = groupScore, tooltip = ttMonitor)
float maxRiskDistanceAtrInput = input.float(1.85, "Max Risk Distance ATR", minval = 0.35, maxval = 6.00, step = 0.05, group = groupScore, tooltip = ttRisk)
float idealRiskDistanceAtrInput = input.float(0.95, "Ideal Risk Distance ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupScore, tooltip = ttIdealRisk)
float targetRMultiple = input.float(1.80, "Target Guide R Multiple", minval = 0.50, maxval = 5.00, step = 0.05, group = groupScore, tooltip = ttTarget)
float minTargetRoomAtrInput = input.float(1.15, "Minimum Target Room ATR", minval = 0.20, maxval = 8.00, step = 0.05, group = groupScore, tooltip = ttRoom)
bool useVolumeContext = input.bool(true, "Use Volume Context", group = groupScore, tooltip = ttVolume)
int proofWindowBars = input.int(60, "Proof Window Bars", minval = 10, maxval = 400, group = groupScore, tooltip = ttProofWin)
float proofTargetAtr = input.float(1.0, "Proof Target (x ATR)", minval = 0.20, maxval = 5.00, step = 0.10, group = groupScore, tooltip = ttProofTgt)

string groupVisual = "Chart Visuals"
bool showReadinessPocket = input.bool(true, "Show Readiness Pocket", group = groupVisual, tooltip = ttPocket)
bool showSetupRails = input.bool(true, "Show State / Risk / Target Rails", group = groupVisual, tooltip = ttRails)
bool showRailLabels = input.bool(true, "Show Rail Badges", group = groupVisual, tooltip = ttRailLabels)
bool showChecklistMarkers = input.bool(false, "Show Checklist Markers", group = groupVisual, tooltip = ttChecklist)
int projectionBars = input.int(34, "Forward Render Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
int pocketTransparency = input.int(85, "Readiness Pocket Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttOpacity)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
bool showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
bool showBlockedLabels = input.bool(false, "Show Blocked Labels", group = groupLabels, tooltip = ttBlockedLabels)
bool showFollowLabels = input.bool(false, "Show Follow Labels", group = groupLabels, tooltip = ttFollowLabels)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttScoreLabel)
int labelCooldownBars = input.int(48, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
int contextSpacingBars = input.int(72, "Checklist Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(10, "Max Visible Labels", minval = 5, maxval = 100, group = groupLabels, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupLabels, tooltip = ttOffset)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_text_on(color bg) =>
    float lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

f_norm_high(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high(value, lowValue, idealValue)
    else
        result := f_norm_low(value, idealValue, highValue)
    result

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_score(float value) =>
    na(value) ? "-" : str.tostring(math.round(value))

f_grade(float scoreValue) =>
    string result = "D"
    if scoreValue >= 88.0
        result := "A+"
    else if scoreValue >= 78.0
        result := "A"
    else if scoreValue >= 66.0
        result := "B"
    else if scoreValue >= 55.0
        result := "C"
    result

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    if theme == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_set_row_fill(table target, int row, string leftText, string rightText, color fillColor, string theme, string fontSize) =>
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = f_row_bg(theme, row), text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = f_text_on(fillColor), bgcolor = fillColor, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

f_avoid_overlap(array<label> labels, float desiredY, bool placeAbove, float safe) =>
    float y = desiredY
    float minGap = safe * 1.15
    int n = array.size(labels)
    if n > 0
        bool moved = true
        int guard = 0
        while moved and guard < 16
            moved := false
            for i = 0 to n - 1
                label lb = array.get(labels, i)
                if math.abs(label.get_x(lb) - bar_index) <= 24
                    if math.abs(label.get_y(lb) - y) < minGap
                        y := placeAbove ? y + minGap : y - minGap
                        moved := true
            guard += 1
    y

f_add_label(array<label> labels, int x, float y, string textValue, color bgColor, bool belowPrice, string sizeText, int maxCount, float safe) =>
    float adjY = f_avoid_overlap(labels, y, not belowPrice, safe)
    label newLabel = label.new(x = x, y = adjY, text = textValue, xloc = xloc.bar_index, style = belowPrice ? label.style_label_up : label.style_label_down, color = color.new(bgColor, 4), textcolor = f_text_on(bgColor), size = f_text_size(sizeText))
    array.push(labels, newLabel)
    f_trim_labels(labels, maxCount)

f_missing_component(bool biasOk, float location, float momentum, float risk, float room) =>
    string result = "Bias"
    if biasOk
        result := "Location"
        float lowest = location
        if momentum < lowest
            lowest := momentum
            result := "Momentum"
        if risk < lowest
            lowest := risk
            result := "Risk"
        if room < lowest
            result := "Room"
    result

// -------------------------------------------------
// Core Data
// -------------------------------------------------
float atrValue = ta.atr(atrLength)
float safeAtr = math.max(nz(atrValue, ta.tr(true)), syminfo.mintick)
float emaFast = ta.ema(close, fastEmaLength)
float emaMid = ta.ema(close, midEmaLength)
float emaSlow = ta.ema(close, slowEmaLength)
float rsiValue = ta.rsi(close, 14)
float volumeBase = ta.sma(volume, 30)
float volumeRatio = volumeBase > 0.0 ? volume / volumeBase : 1.0

string htfUsed = htfInput == "" ? timeframe.period : htfInput
float htfClose = request.security(syminfo.tickerid, htfUsed, close, lookahead = barmerge.lookahead_off)
float htfEmaFast = request.security(syminfo.tickerid, htfUsed, ta.ema(close, fastEmaLength), lookahead = barmerge.lookahead_off)
float htfEmaSlow = request.security(syminfo.tickerid, htfUsed, ta.ema(close, slowEmaLength), lookahead = barmerge.lookahead_off)

float pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
float pivotLow = ta.pivotlow(low, pivotLength, pivotLength)

var float lastPivotHigh = na
var float lastPivotLow = na
var int lastPivotHighBar = na
var int lastPivotLowBar = na

if not na(pivotHigh)
    lastPivotHigh := pivotHigh
    lastPivotHighBar := bar_index - pivotLength

if not na(pivotLow)
    lastPivotLow := pivotLow
    lastPivotLowBar := bar_index - pivotLength

bool pivotHighFresh = not na(lastPivotHighBar) and bar_index - lastPivotHighBar <= lookbackBars
bool pivotLowFresh = not na(lastPivotLowBar) and bar_index - lastPivotLowBar <= lookbackBars
float activePivotHigh = pivotHighFresh ? lastPivotHigh : na
float activePivotLow = pivotLowFresh ? lastPivotLow : na

float sensitivityFactor = switch sensitivity
    "Conservative" => 0.86
    "Aggressive" => 1.18
    => 1.0

float maxRiskDistanceAtr = maxRiskDistanceAtrInput * sensitivityFactor
float idealRiskDistanceAtr = idealRiskDistanceAtrInput * sensitivityFactor
float minTargetRoomAtr = minTargetRoomAtrInput / sensitivityFactor
bool confirmReady = confirmationMode == "Live Updating" or barstate.isconfirmed

// -------------------------------------------------
// Bias and Component Scores
// -------------------------------------------------
bool trendBullStack = emaFast > emaMid and emaMid > emaSlow
bool trendBearStack = emaFast < emaMid and emaMid < emaSlow
bool htfBull = htfClose > htfEmaFast and htfEmaFast > htfEmaSlow
bool htfBear = htfClose < htfEmaFast and htfEmaFast < htfEmaSlow
bool slopeBull = emaFast > emaFast[5]
bool slopeBear = emaFast < emaFast[5]
bool candleBull = close > open
bool candleBear = close < open

int bullVotes = (trendBullStack ? 1 : 0) + (htfBull ? 1 : 0) + (slopeBull ? 1 : 0) + (close > emaFast ? 1 : 0) + (candleBull ? 1 : 0)
int bearVotes = (trendBearStack ? 1 : 0) + (htfBear ? 1 : 0) + (slopeBear ? 1 : 0) + (close < emaFast ? 1 : 0) + (candleBear ? 1 : 0)

bool useBullSide = bullVotes > bearVotes
bool useBearSide = bearVotes > bullVotes
bool validSide = useBullSide or useBearSide

float decisionRef = useBullSide ? (na(activePivotLow) ? emaFast : activePivotLow) : useBearSide ? (na(activePivotHigh) ? emaFast : activePivotHigh) : na
float locationDistanceAtr = validSide and not na(decisionRef) ? math.abs(close - decisionRef) / safeAtr : na
bool wrongSideOfRef = useBullSide ? close < decisionRef : useBearSide ? close > decisionRef : true
float locationBaseScore = na(locationDistanceAtr) ? 35.0 : f_norm_low(locationDistanceAtr, 0.18, 2.35 * sensitivityFactor)
float locationScore = wrongSideOfRef ? math.min(locationBaseScore, 28.0) : locationBaseScore

float stackScore = useBullSide ? (trendBullStack ? 100.0 : close > emaMid ? 66.0 : close > emaSlow ? 44.0 : 20.0) :
     useBearSide ? (trendBearStack ? 100.0 : close < emaMid ? 66.0 : close < emaSlow ? 44.0 : 20.0) : 35.0
float htfScore = useBullSide ? (htfBull ? 100.0 : htfClose > htfEmaFast ? 62.0 : 30.0) :
     useBearSide ? (htfBear ? 100.0 : htfClose < htfEmaFast ? 62.0 : 30.0) : 35.0
float slopeScore = useBullSide ? (slopeBull ? 100.0 : 35.0) : useBearSide ? (slopeBear ? 100.0 : 35.0) : 35.0
float trendSupportScore = f_clamp(stackScore * 0.45 + htfScore * 0.35 + slopeScore * 0.20, 0.0, 100.0)

float barRange = high - low
float barBody = math.abs(close - open)
float bodyRatio = barRange > 0.0 ? barBody / barRange : 0.0
float rsiDirectional = useBullSide ? f_norm_high(rsiValue, 48.0, 65.0) : useBearSide ? f_norm_high(52.0 - rsiValue, 0.0, 17.0) : 35.0
float rsiDelta = rsiValue - rsiValue[3]
float rsiDeltaScore = useBullSide ? f_norm_high(rsiDelta, -1.0, 6.0) : useBearSide ? f_norm_high(-rsiDelta, -1.0, 6.0) : 35.0
float candleQualityScore = (useBullSide and candleBull) or (useBearSide and candleBear) ? f_norm_high(bodyRatio, 0.18, 0.72) : f_norm_low(bodyRatio, 0.10, 0.75)
float volumeScore = useVolumeContext ? f_norm_high(volumeRatio, 0.85, 1.65) : 55.0
float momentumScore = f_clamp(rsiDirectional * 0.36 + rsiDeltaScore * 0.22 + candleQualityScore * 0.24 + volumeScore * 0.18, 0.0, 100.0)

float fallbackRisk = safeAtr * idealRiskDistanceAtr
float invalidationEdge = useBullSide ? (na(activePivotLow) ? low - fallbackRisk : activePivotLow - safeAtr * 0.12) :
     useBearSide ? (na(activePivotHigh) ? high + fallbackRisk : activePivotHigh + safeAtr * 0.12) : na
float riskDistance = validSide and not na(invalidationEdge) ? math.abs(close - invalidationEdge) : na
float riskDistanceAtr = not na(riskDistance) ? riskDistance / safeAtr : na
bool invalidated = validSide and ((useBullSide and close <= invalidationEdge) or (useBearSide and close >= invalidationEdge))
float riskFitScore = invalidated or na(riskDistanceAtr) ? 0.0 : f_peak_score(riskDistanceAtr, 0.12, idealRiskDistanceAtr, maxRiskDistanceAtr)

float projectedTargetDistance = nz(riskDistance, safeAtr) * targetRMultiple
float nearbyTarget = useBullSide ? (not na(activePivotHigh) and activePivotHigh > close ? activePivotHigh : close + projectedTargetDistance) :
     useBearSide ? (not na(activePivotLow) and activePivotLow < close ? activePivotLow : close - projectedTargetDistance) : na
float targetRoom = validSide and not na(nearbyTarget) ? math.abs(nearbyTarget - close) : na
float targetRoomAtr = not na(targetRoom) ? targetRoom / safeAtr : na
float targetRoomScore = na(targetRoomAtr) ? 35.0 : f_norm_high(targetRoomAtr, minTargetRoomAtr * 0.45, minTargetRoomAtr * 1.85)

float readinessScore = f_clamp(locationScore * 0.24 + trendSupportScore * 0.22 + momentumScore * 0.22 + riskFitScore * 0.16 + targetRoomScore * 0.16, 0.0, 100.0)

bool biasOk = validSide and trendSupportScore >= 48.0
bool locationOk = locationScore >= 55.0
bool momentumOk = momentumScore >= 55.0
bool riskOk = riskFitScore >= 55.0
bool roomOk = targetRoomScore >= 55.0 and nz(targetRoomAtr, 0.0) >= minTargetRoomAtr
int checklistCount = (biasOk ? 1 : 0) + (locationOk ? 1 : 0) + (momentumOk ? 1 : 0) + (riskOk ? 1 : 0) + (roomOk ? 1 : 0)
string missingComponent = f_missing_component(biasOk, locationScore, momentumScore, riskFitScore, targetRoomScore)

bool blockedByRisk = validSide and not invalidated and (nz(riskDistanceAtr, 99.0) > maxRiskDistanceAtr or nz(targetRoomAtr, 0.0) < minTargetRoomAtr)
bool readyState = validSide and not invalidated and not blockedByRisk and readinessScore >= readyScoreInput and checklistCount >= 4
bool monitorState = validSide and not invalidated and not readyState and readinessScore >= monitorScoreInput and checklistCount >= 3
bool blockedState = validSide and not invalidated and not readyState and not monitorState and (blockedByRisk or checklistCount <= 2)

string stateText = invalidated ? "INVALIDATED" : readyState ? "READY" : blockedState ? "BLOCKED" : monitorState ? "MONITOR" : "WAIT"
string actionText = switch stateText
    "READY" => "Review setup"
    "MONITOR" => "Wait confirm"
    "BLOCKED" => "Fix " + missingComponent
    "INVALIDATED" => "Rebuild"
    => "Missing " + missingComponent

color directionColor = useBullSide ? bullColor : useBearSide ? bearColor : neutralColor
color stateColor = switch stateText
    "READY" => directionColor
    "MONITOR" => accentColor
    "BLOCKED" => neutralColor
    "INVALIDATED" => dangerColor
    => neutralColor

string biasText = useBullSide ? "Bullish" : useBearSide ? "Bearish" : "Neutral"
string sideText = useBullSide ? "LONG" : useBearSide ? "SHORT" : "WAIT"
string locationText = locationOk ? "Valid" : wrongSideOfRef ? "Wrong Side" : "Extended"
string momentumText = momentumScore >= 72.0 ? "Strong" : momentumScore >= 55.0 ? "Building" : "Soft"
string riskText = invalidated ? "Invalidated" : f_fmt(riskDistanceAtr) + " ATR @ " + f_price(invalidationEdge)
string readinessText = stateText + " " + str.tostring(math.round(readinessScore)) + " / " + f_grade(readinessScore)
string checklistText = "B" + (biasOk ? "+" : "-") + " L" + (locationOk ? "+" : "-") + " M" + (momentumOk ? "+" : "-") + " R" + (riskOk ? "+" : "-") + " T" + (roomOk ? "+" : "-")
string checklistLabelText = "CHECK " + str.tostring(checklistCount) + "/5"
string qualityText = str.tostring(math.round(readinessScore)) + " / 100 " + f_grade(readinessScore) + " | " + str.tostring(checklistCount) + "/5"
string riskRoomText = (invalidated ? "INVALID" : f_fmt(riskDistanceAtr) + " ATR") + " | Room " + f_fmt(targetRoomAtr) + " ATR"

// -------------------------------------------------
// Stop-aware setup proof (confirmed-bar gated)
// On each readiness event, measure symmetric follow-through vs adverse move.
// -------------------------------------------------
var int sqsProofTotal = 0
var int sqsProofWins = 0
var bool sqsProofPending = false
var int sqsProofDir = 0
var float sqsProofTarget = na
var float sqsProofStop = na
var int sqsProofStart = na

bool proofReadyBar = barstate.isconfirmed

if proofReadyBar and sqsProofPending
    bool pLoss = sqsProofDir == 1 ? close <= sqsProofStop : close >= sqsProofStop
    bool pWin = sqsProofDir == 1 ? close >= sqsProofTarget : close <= sqsProofTarget
    bool pResolved = false
    if pLoss
        sqsProofTotal += 1
        pResolved := true
    else if pWin
        sqsProofWins += 1
        sqsProofTotal += 1
        pResolved := true
    if not pResolved and not na(sqsProofStart) and bar_index - sqsProofStart >= proofWindowBars
        pResolved := true
    if pResolved
        sqsProofPending := false

bool readinessTrigger = proofReadyBar and validSide and (readyState and not readyState[1] or monitorState and not monitorState[1])
if readinessTrigger and not sqsProofPending
    sqsProofPending := true
    sqsProofDir := useBullSide ? 1 : -1
    sqsProofTarget := close + (useBullSide ? 1 : -1) * safeAtr * proofTargetAtr
    sqsProofStop := close - (useBullSide ? 1 : -1) * safeAtr * proofTargetAtr
    sqsProofStart := bar_index

bool sqsProofReady = sqsProofTotal >= 6
int sqsProofRate = sqsProofReady ? int(math.round(f_clamp(sqsProofWins / sqsProofTotal * 100.0, 0.0, 100.0))) : na
string sqsProofRead = sqsProofReady ? str.tostring(sqsProofRate) + "%  (" + str.tostring(sqsProofTotal) + ")" : "Building (" + str.tostring(sqsProofTotal) + ")"
color sqsProofColor = not sqsProofReady ? neutralColor : sqsProofRate >= 55 ? bullColor : sqsProofRate >= 45 ? neutralColor : bearColor

// -------------------------------------------------
// Chart Objects
// -------------------------------------------------
var box readinessPocket = na
var label pocketBadge = na
var line stateRail = na
var line invalidationLine = na
var line targetLine = na
var label decisionBadge = na
var label invalidationBadge = na
var label targetBadge = na

int leftEdge = bar_index
int rightEdge = bar_index + projectionBars
float pocketDepth = math.min(nz(riskDistanceAtr, idealRiskDistanceAtr), maxRiskDistanceAtr) * safeAtr
float pocketTopRaw = useBullSide ? close + safeAtr * 0.20 : useBearSide ? close + pocketDepth : na
float pocketBottomRaw = useBullSide ? close - pocketDepth : useBearSide ? close - safeAtr * 0.20 : na
float pocketTop = math.max(pocketTopRaw, pocketBottomRaw)
float pocketBottom = math.min(pocketTopRaw, pocketBottomRaw)
string pocketText = validSide ? sideText + " | " + stateText + " | Q" + str.tostring(math.round(readinessScore)) + " " + f_grade(readinessScore) + "\n" + str.tostring(checklistCount) + "/5 | " + actionText : ""

if showReadinessPocket and validSide
    if na(readinessPocket)
        readinessPocket := box.new(left = leftEdge, top = pocketTop, right = rightEdge, bottom = pocketBottom, xloc = xloc.bar_index, border_color = stateColor, bgcolor = color.new(directionColor, pocketTransparency))
    else
        box.set_lefttop(readinessPocket, leftEdge, pocketTop)
        box.set_rightbottom(readinessPocket, rightEdge, pocketBottom)
        box.set_border_color(readinessPocket, stateColor)
        box.set_bgcolor(readinessPocket, color.new(directionColor, pocketTransparency))
    int badgeX = int(math.round((leftEdge + rightEdge) * 0.5))
    float badgeY = (pocketTop + pocketBottom) * 0.5
    if na(pocketBadge)
        pocketBadge := label.new(badgeX, badgeY, pocketText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 0), textcolor = f_text_on(stateColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(pocketBadge, badgeX, badgeY)
        label.set_text(pocketBadge, pocketText)
        label.set_color(pocketBadge, color.new(stateColor, 0))
        label.set_textcolor(pocketBadge, f_text_on(stateColor))
        label.set_size(pocketBadge, f_text_size(labelFontSize))
else
    if not na(readinessPocket)
        box.delete(readinessPocket)
        readinessPocket := na
    if not na(pocketBadge)
        label.delete(pocketBadge)
        pocketBadge := na

if showSetupRails and validSide
    if na(stateRail)
        stateRail := line.new(x1 = leftEdge, y1 = decisionRef, x2 = rightEdge, y2 = decisionRef, xloc = xloc.bar_index, extend = extend.none, color = stateColor, style = line.style_solid, width = 2)
    else
        line.set_xy1(stateRail, leftEdge, decisionRef)
        line.set_xy2(stateRail, rightEdge, decisionRef)
        line.set_color(stateRail, stateColor)
        line.set_style(stateRail, line.style_solid)
        line.set_width(stateRail, 2)

    if na(invalidationLine)
        invalidationLine := line.new(x1 = leftEdge, y1 = invalidationEdge, x2 = rightEdge, y2 = invalidationEdge, xloc = xloc.bar_index, extend = extend.none, color = invalidated ? dangerColor : neutralColor, style = line.style_dashed, width = 2)
    else
        line.set_xy1(invalidationLine, leftEdge, invalidationEdge)
        line.set_xy2(invalidationLine, rightEdge, invalidationEdge)
        line.set_color(invalidationLine, invalidated ? dangerColor : neutralColor)
        line.set_style(invalidationLine, line.style_dashed)
        line.set_width(invalidationLine, 2)

    if na(targetLine)
        targetLine := line.new(x1 = leftEdge, y1 = nearbyTarget, x2 = rightEdge, y2 = nearbyTarget, xloc = xloc.bar_index, extend = extend.none, color = accentColor, style = line.style_dotted, width = 1)
    else
        line.set_xy1(targetLine, leftEdge, nearbyTarget)
        line.set_xy2(targetLine, rightEdge, nearbyTarget)
        line.set_color(targetLine, accentColor)
        line.set_style(targetLine, line.style_dotted)

    if showRailLabels
        string decisionText = "DECISION | " + f_price(decisionRef)
        string invalidationText = "INVALIDATION | " + f_price(invalidationEdge)
        string targetText = "TARGET ROOM | " + f_price(nearbyTarget)
        if na(decisionBadge)
            decisionBadge := label.new(rightEdge, decisionRef, decisionText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(stateColor, 0), textcolor = f_text_on(stateColor), size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(decisionBadge, rightEdge, decisionRef)
            label.set_text(decisionBadge, decisionText)
            label.set_color(decisionBadge, color.new(stateColor, 0))
            label.set_textcolor(decisionBadge, f_text_on(stateColor))
            label.set_size(decisionBadge, f_text_size(labelFontSize))
        if na(invalidationBadge)
            invalidationBadge := label.new(rightEdge, invalidationEdge, invalidationText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 0), textcolor = f_text_on(dangerColor), size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(invalidationBadge, rightEdge, invalidationEdge)
            label.set_text(invalidationBadge, invalidationText)
            label.set_color(invalidationBadge, color.new(dangerColor, 0))
            label.set_textcolor(invalidationBadge, f_text_on(dangerColor))
            label.set_size(invalidationBadge, f_text_size(labelFontSize))
        if na(targetBadge)
            targetBadge := label.new(rightEdge, nearbyTarget, targetText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(targetBadge, rightEdge, nearbyTarget)
            label.set_text(targetBadge, targetText)
            label.set_color(targetBadge, color.new(accentColor, 0))
            label.set_textcolor(targetBadge, f_text_on(accentColor))
            label.set_size(targetBadge, f_text_size(labelFontSize))
    else
        if not na(decisionBadge)
            label.delete(decisionBadge)
            decisionBadge := na
        if not na(invalidationBadge)
            label.delete(invalidationBadge)
            invalidationBadge := na
        if not na(targetBadge)
            label.delete(targetBadge)
            targetBadge := na
else
    if not na(stateRail)
        line.delete(stateRail)
        stateRail := na
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(decisionBadge)
        label.delete(decisionBadge)
        decisionBadge := na
    if not na(invalidationBadge)
        label.delete(invalidationBadge)
        invalidationBadge := na
    if not na(targetBadge)
        label.delete(targetBadge)
        targetBadge := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
var array<label> chartLabels = array.new_label()
var int lastEventLabelBar = na
var int lastContextLabelBar = na

bool readyEvent = confirmReady and readyState and not readyState[1]
bool monitorEvent = confirmReady and monitorState and not monitorState[1]
bool blockedEvent = confirmReady and blockedState and not blockedState[1]
bool invalidationEvent = confirmReady and invalidated and not invalidated[1]
bool followThroughEvent = confirmReady and validSide and (readyState[1] or monitorState[1]) and nz(readinessScore[1], 0.0) >= monitorScoreInput and ((useBullSide and high >= nearbyTarget) or (useBearSide and low <= nearbyTarget))
bool eventCooldownReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
string scoreSuffix = showLabelScore ? " | Q" + str.tostring(math.round(readinessScore)) + " " + f_grade(readinessScore) : ""

if showEventLabels and eventCooldownReady
    if invalidationEvent
        float invalidY = useBullSide ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
        f_add_label(chartLabels, bar_index, invalidY, sideText + " INVALIDATED" + scoreSuffix + " | REBUILD", dangerColor, useBearSide, labelFontSize, maxVisibleLabels, safeAtr)
        lastEventLabelBar := bar_index
    else if followThroughEvent and showFollowLabels
        float followY = useBullSide ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
        f_add_label(chartLabels, bar_index, followY, sideText + " FOLLOW | Q" + str.tostring(math.round(nz(readinessScore[1], readinessScore))) + " | TARGET", accentColor, useBearSide, labelFontSize, maxVisibleLabels, safeAtr)
        lastEventLabelBar := bar_index
    else if readyEvent
        float readyY = useBullSide ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
        f_add_label(chartLabels, bar_index, readyY, sideText + " READY" + scoreSuffix + " | " + str.tostring(checklistCount) + "/5", directionColor, useBullSide, labelFontSize, maxVisibleLabels, safeAtr)
        lastEventLabelBar := bar_index
    else if monitorEvent
        float monitorY = useBullSide ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
        f_add_label(chartLabels, bar_index, monitorY, sideText + " MONITOR" + scoreSuffix + " | NEED " + missingComponent, accentColor, useBullSide, labelFontSize, maxVisibleLabels, safeAtr)
        lastEventLabelBar := bar_index
    else if blockedEvent and showBlockedLabels
        float blockedY = useBullSide ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
        f_add_label(chartLabels, bar_index, blockedY, sideText + " BLOCKED" + scoreSuffix + " | FIX " + missingComponent, neutralColor, useBearSide, labelFontSize, maxVisibleLabels, safeAtr)
        lastEventLabelBar := bar_index

bool contextReady = showChecklistMarkers and showContextLabels and confirmReady and validSide and not invalidated and checklistCount >= 3 and (stateText == "READY" or stateText == "MONITOR" or readinessScore >= monitorScoreInput - 4) and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
if contextReady
    float contextY = useBullSide ? low - safeAtr * (labelOffsetAtr + 0.55) : high + safeAtr * (labelOffsetAtr + 0.55)
    string contextLabelText = sideText + " " + checklistLabelText + " | " + stateText + " Q" + str.tostring(math.round(readinessScore))
    f_add_label(chartLabels, bar_index, contextY, contextLabelText, stateColor, useBullSide, labelFontSize, maxVisibleLabels, safeAtr)
    lastContextLabelBar := bar_index

// -------------------------------------------------
// Panel
// -------------------------------------------------
color panelFrame = f_panel_border(panelTheme)
var table panel = table.new(f_panel_position(panelLocation), 2, 8, bgcolor = f_panel_bg(panelTheme), frame_color = panelFrame, frame_width = 1, border_color = panelFrame, border_width = 1)

if barstate.islast
    table.clear(panel, 0, 0, 1, 7)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Setup Quality Scorecard", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_set_row_fill(panel, 1, "Workflow", stateText + " | " + actionText, stateColor, panelTheme, panelFontSize)
        f_set_row(panel, 2, "Setup Quality", qualityText, stateColor, panelTheme, panelFontSize)
        f_set_row(panel, 3, "Bias", sideText + " | " + biasText, directionColor, panelTheme, panelFontSize)
        f_set_row(panel, 4, "Location", f_score(locationScore) + " | " + locationText, locationOk ? directionColor : neutralColor, panelTheme, panelFontSize)
        f_set_row(panel, 5, "Momentum", f_score(momentumScore) + " | " + momentumText, momentumScore >= 72.0 ? directionColor : momentumScore >= 55.0 ? accentColor : neutralColor, panelTheme, panelFontSize)
        f_set_row(panel, 6, "Risk / Room", riskRoomText, invalidated ? dangerColor : riskOk and roomOk ? directionColor : neutralColor, panelTheme, panelFontSize)
        f_set_row_fill(panel, 7, "Setup Proof", sqsProofRead, sqsProofColor, panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(readyEvent, title = "Setup Quality READY", message = "Setup Quality Scorecard: setup context has reached READY state. This is an attention marker, not a trade instruction.")
alertcondition(monitorEvent, title = "Setup Quality MONITOR", message = "Setup Quality Scorecard: setup context has improved into MONITOR state and requires confirmation. This is an attention marker, not a trade instruction.")
alertcondition(blockedEvent, title = "Setup Quality BLOCKED", message = "Setup Quality Scorecard: setup context is blocked by a missing component or risk issue. This is an attention marker, not a trade instruction.")
alertcondition(invalidationEvent, title = "Setup Quality INVALIDATED", message = "Setup Quality Scorecard: the active invalidation edge has been crossed and context should be rebuilt. This is an attention marker, not a trade instruction.")
alertcondition(followThroughEvent, title = "Setup Quality Follow-Through", message = "Setup Quality Scorecard: price has reached the target-room guide after an active setup review state. This is an attention marker, not a trade instruction.")

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(readinessScore, "Readiness Score", color = color.new(accentColor, 100), display = display.data_window)
plot(locationScore, "Location Score", color = color.new(panelLabelCol, 100), display = display.data_window)
plot(momentumScore, "Momentum Score", color = color.new(panelLabelCol, 100), display = display.data_window)
plot(riskFitScore, "Risk Score", color = color.new(panelLabelCol, 100), display = display.data_window)
plot(targetRoomScore, "Target Room Score", color = color.new(panelLabelCol, 100), display = display.data_window)
````
