# Liquidity Grab Detector [AGPro Series]

- url: https://www.tradingview.com/script/PEEMkx2o-Liquidity-Grab-Detector-AGPro-Series/
- type: indicator
- pine_id: PUB;7e473545a8c94edfb923d8e901f511a5
- version: 5.0

## Description

🧲 LIQUIDITY GRAB DETECTOR [AGPro Series]

Detects single-bar multi-level liquidity raids — the precise moment price sweeps a cluster of 2 or more distinct liquidity pools within a single candle and immediately reverses. Built for ICT, Smart Money, and institutional order-flow analysis, this engine identifies the liquidity raids that matter most: simultaneous multi-level stop hunts that typically precede the sharpest reversals.

═══════════════════════════════════════

🔹 OVERVIEW

Most liquidity tools either track single sweeps or lifecycle-based breach-and-reclaim patterns. This detector focuses on a different, rarer, and higher-conviction event: the single-bar multi-level raid. When one candle sweeps a cluster of two or more untouched liquidity levels (swing highs/lows, session H/L, previous day H/L, previous week H/L) in a single motion, the odds of a meaningful reversal increase significantly. The engine validates each grab with four independent filters, deduplicates overlapping levels, merges adjacent reversal zones for a clean chart, tiers signals by quality, and projects forward target zones.

One-click preset modes (Aggressive / Balanced / Conservative / Custom) make the detector instantly suitable for any style — from high-frequency scalping to premium-only confluence trading — without manual tuning.

This is not a strategy and makes no directional prediction. It is a detection and visualization engine for a specific institutional order-flow footprint.

═══════════════════════════════════════

🔹 UNIQUE EDGE — HOW THIS DIFFERS

The single-bar multi-level criterion is the defining separator from conventional liquidity tools:

▪ Traditional liquidity sweep detectors flag any single-level sweep. High signal rate, low conviction per signal.

▪ Breach-and-reclaim engines (equal-highs / equal-lows style) require a full lifecycle across multiple bars. Different mechanic, different timing.

▪ This detector requires a cluster of 2+ distinct liquidity levels to be swept in a single candle, within a user-defined ATR proximity. ATR-normalized thresholds adapt across all timeframes and symbols.

▪ ATR-based level deduplication merges coincident sources (e.g. Swing + PDH stacked at the same price) into a single logical level, preventing inflated sweep counts.

▪ Zone overlap-awareness: adjacent same-direction reversal zones are merged into a single extended zone rather than piling multiple boxes on top of each other. Premium, chart-clean visualization.

▪ Strikethrough length clamp keeps historical consumed-level lines from crossing the entire chart, even on long-running indicators.

▪ Preset modes encapsulate calibrated filter stacks, making the detector genuinely plug-and-play.

The combined filter stack (cluster + volume + wick + reversal + cooldown + dedup + zone-merging) produces fewer but significantly higher-quality signals with a clean visual footprint.

═══════════════════════════════════════

🔹 METHODOLOGY

Preset modes calibrate the detection engine with one selection:
  ▪ Aggressive — minimum 2 levels, 0.7 ATR cluster, 1.1× volume, 0.15 ATR wick, 2 bar cooldown.
  ▪ Balanced — minimum 2 levels, 0.45 ATR cluster, 1.5× volume, 0.3 ATR wick, 5 bar cooldown. Default.
  ▪ Conservative — minimum 3 levels, 0.35 ATR cluster, 2.0× volume, 0.45 ATR wick, 10 bar cooldown. Premium-only.
  ▪ Custom — honors manually configured input values.

Level registry with deduplication. The script maintains a live registry of untouched liquidity levels built from four configurable sources. Incoming levels within a configurable ATR tolerance of an existing level are merged. Each level is time-stamped, capped at a configurable maximum count, and pruned once it ages beyond the lookback window or is consumed by a grab.

Cluster detection. On every bar, the engine scans active levels on both sides and classifies a bar as a multi-level sweep candidate when it penetrates the minimum level count whose vertical span fits within the ATR proximity band.

Confirmation layers:
  1. Volume spike — grab bar volume must exceed the rolling SMA by the preset multiplier.
  2. Wick ratio — rejection wick on the grab side must exceed the preset ATR fraction.
  3. Immediate reversal — within a configurable window, price must close back beyond the swept cluster.
  4. Cooldown — after a confirmed grab, new detections are suppressed.

Zone overlap-awareness. When a new grab's reversal zone falls within a configurable ATR distance of a recent same-direction zone, the existing zone is extended rather than drawing a new overlapping box. Aggregate targets stay clean.

Quality tier classification. Confirmed grabs are automatically tiered by level count, with 4-level grabs and 5+ level grabs receiving progressively stronger visual emphasis.

═══════════════════════════════════════

🔹 SIGNALS & VISUALS

Confirmed bullish grab — triangle marker below the bar, "LIQ GRAB · N levels swept" label with tier stars for high-quality grabs, and a forward-projected reversal zone above the cluster with a target micro-label.

Confirmed bearish grab — mirror image with bear coloring.

Stagger-aware label placement. When multiple confirmed grabs occur close together on the chart, their labels are automatically offset vertically to prevent visual overlap.

Clean default visual profile. Swept-level strikethrough lines are disabled by default for a premium chart-clean look; enable them for detailed post-grab review. When enabled, a max-age clamp prevents extremely long lines.

Statistics panel (8 rows) — active level count, total grabs, bars since last grab, last grab source composition (dynamic, e.g. "PDL+Swing"), bullish vs bearish breakdown, reversal success rate, and average levels swept per grab.

Alerts — separate alert conditions for bullish and bearish grab confirmations, triggered on bar close.

═══════════════════════════════════════

🔹 KEY INPUTS

Detection Engine
  ▪ Preset Mode — Aggressive / Balanced / Conservative / Custom.
  ▪ Minimum Levels Swept, Cluster Proximity, Cooldown — honored in Custom mode.
  ▪ Level Deduplication (ATR) — merge tolerance for coincident levels.
  ▪ Level Lookback, Max Active Levels — registry housekeeping.

Liquidity Level Sources — swing highs/lows, session H/L, PDH/PDL, PWH/PWL.

Confirmation Filters — volume multiplier and averaging length, reversal window, minimum wick ratio, ATR length.

Visuals
  ▪ Toggle labels, strikethroughs, zones, statistics panel.
  ▪ Label and panel font size (default Normal).
  ▪ Panel position (8 options) and theme (Dark / Light).
  ▪ Zone projection length, zone height, zone transparency.
  ▪ Zone merge distance (ATR-based overlap suppression).
  ▪ Max strikethrough length (bars).

═══════════════════════════════════════

🔹 HOW TO USE

1. Start with Balanced preset on any timeframe. The ATR-based cluster logic adapts automatically, but 15m–4H timeframes on liquid instruments produce the cleanest signal set.

2. Switch to Conservative for premium-only signals at key institutional levels, or Aggressive when scalping intraday liquidity dynamics.

3. Watch for grab labels near well-defined liquidity clusters — session opens, PDH/PDL interactions, and at range edges. Tiered grabs (4+ levels raided in one bar) deserve special attention.

4. Use the reversal projection zone as a reference target area, not a mechanical take-profit. Combine with your existing structure, order blocks, or mean-reversion levels.

5. Check the "Last Sources" panel row to see which specific liquidity pools were raided most recently.

6. For detailed post-grab analysis, enable "Show Swept Level Strikethroughs" in the Visuals group. For a clean chart, leave disabled.

7. For fine-grained control, select Custom mode and adjust each filter manually.

═══════════════════════════════════════

🔹 LIMITATIONS & TRANSPARENCY

▪ No repaint on confirmed signals — grabs are finalized only after the reversal window closes with all filters passing. Swing pivots used as level sources are inherently delayed by the pivot length (standard pivot behavior).

▪ The reversal success metric uses a fixed 1 ATR / 10 bar definition and is provided as context only. It is not a performance claim or win rate.

▪ In strongly trending markets, multi-level sweeps can occur without reversal, producing failed grabs. The filter stack reduces but does not eliminate this.

▪ On very low-liquidity symbols or extremely short timeframes, volume data can be noisy. Consider disabling the volume filter in those conditions.

▪ Session, PDH/PDL, and PWH/PWL levels are derived from the chart symbol's native session definition.

═══════════════════════════════════════

🔹 RISK DISCLOSURE

This indicator is an analytical and visualization tool. It does not generate buy or sell recommendations, does not guarantee any outcome, and is not a trading strategy. All trading decisions are the sole responsibility of the user. Past pattern behavior does not guarantee future results. Always combine indicator output with your own analysis, risk management, and position sizing framework.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Liquidity Grab Detector [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// Detects single-bar multi-level liquidity grabs where price sweeps clustered
// swing, session, previous-day (PDH / PDL) and previous-week (PWH / PWL)
// liquidity pools, then validates each raid with volume expansion, rejection
// wick context and an immediate reversal. Every confirmed grab is scored as a
// 0-100 quality setup with a clear next-action state, a grab-to-target path,
// a projected reversal zone and a persistent reversal-rate proof layer. Built
// for liquidity sweep, stop-hunt, ICT / Smart Money (SMC) analysis - guiding
// what to do after the raid, not just marking another sweep on the chart.
// ─────────────────────────────────────────────────

//@version=6
indicator("Liquidity Grab Detector [AGPro Series]",
     shorttitle = "AG Pro LGD",
     overlay    = true,
     max_lines_count   = 500,
     max_labels_count  = 500,
     max_boxes_count   = 500)

// ═════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════

grpDet = "Detection Engine"
presetMode = input.string("Balanced", "Preset Mode", options = ["Aggressive", "Balanced", "Conservative", "Custom"],
     tooltip = "Quick filter preset. Aggressive produces more signals, Balanced is the default operating profile, Conservative focuses on rarer higher-quality grabs, and Custom honors the manual values below.",
     group = grpDet)
minLevelsSwept = input.int(2, "Minimum Levels Swept (Single Bar)", minval = 2, maxval = 6,
     tooltip = "Minimum number of distinct liquidity levels that must be swept within a single candle to qualify as a multi-level liquidity grab.",
     group = grpDet)
clusterATR = input.float(0.5, "Cluster Proximity (ATR)", minval = 0.1, maxval = 2.0, step = 0.1,
     tooltip = "Maximum distance between swept liquidity levels, measured in ATR units. Levels within this distance are treated as one liquidity cluster.",
     group = grpDet)
levelDedupATR = input.float(0.15, "Level Deduplication (ATR)", minval = 0.0, maxval = 1.0, step = 0.05,
     tooltip = "Merges newly registered liquidity levels when they sit close to existing levels. This prevents double-counting overlapping Swing, session, PDH/PDL, or PWH/PWL references.",
     group = grpDet)
cooldownBars = input.int(3, "Cooldown After Grab (Bars)", minval = 0, maxval = 50,
     tooltip = "Suppresses fresh liquidity-grab detections for the selected number of bars after confirmation.",
     group = grpDet)
levelLookback = input.int(150, "Level Lookback (Bars)", minval = 50, maxval = 1000, step = 50,
     tooltip = "How many bars back active untouched liquidity levels are allowed to remain in the registry.",
     group = grpDet)
maxActiveLevels = input.int(80, "Max Active Levels", minval = 20, maxval = 300,
     tooltip = "Hard cap for the active liquidity registry. Oldest levels are pruned when the cap is exceeded.",
     group = grpDet)

grpSrc = "Liquidity Level Sources"
useSwing = input.bool(true, "Swing Highs / Lows", group = grpSrc,
     tooltip = "Include pivot-based swing highs and lows as liquidity levels.")
swingLen = input.int(5, "Swing Pivot Length", minval = 2, maxval = 20,
     tooltip = "Left/right bars required to confirm a swing pivot. Higher values create fewer but more structural levels.",
     group = grpSrc)
useSession = input.bool(true, "Session High / Low", group = grpSrc,
     tooltip = "Include the current trading session high and low as liquidity references.")
sessionSpec = input.session("0000-2359", "Session Window", group = grpSrc,
     tooltip = "Session time window in exchange timezone. Default covers the full day.")
usePDHPDL = input.bool(true, "Previous Day H / L (PDH / PDL)", group = grpSrc,
     tooltip = "Include previous daily high and low as institutional reference levels.")
usePWHPWL = input.bool(true, "Previous Week H / L (PWH / PWL)", group = grpSrc,
     tooltip = "Include previous weekly high and low as higher-timeframe liquidity references.")

grpConf = "Confirmation Filters"
useVolSpike = input.bool(true, "Require Volume Spike", group = grpConf,
     tooltip = "Require the grab bar to print volume above its moving average baseline.")
volMult = input.float(1.3, "Volume Spike Multiplier", minval = 1.0, maxval = 5.0, step = 0.1,
     tooltip = "Grab bar volume must exceed volume SMA multiplied by this value.",
     group = grpConf)
volLen = input.int(20, "Volume Average Length", minval = 5, maxval = 100,
     tooltip = "Moving average length used as the volume baseline.",
     group = grpConf)
useReversal = input.bool(true, "Require Immediate Reversal", group = grpConf,
     tooltip = "Require price to reverse beyond the swept liquidity cluster within the selected confirmation window.")
reversalBars = input.int(3, "Reversal Window (Bars)", minval = 1, maxval = 10,
     tooltip = "Maximum number of bars allowed for the reversal confirmation after the sweep.",
     group = grpConf)
useWickRatio = input.bool(true, "Require Minimum Wick Ratio", group = grpConf,
     tooltip = "Require a meaningful rejection wick on the grab candle.")
minWickATR = input.float(0.25, "Minimum Wick (ATR units)", minval = 0.1, maxval = 2.0, step = 0.05,
     tooltip = "Minimum rejection wick length as an ATR multiple.",
     group = grpConf)
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 50,
     tooltip = "ATR period used for normalized detection, filters, labels, zones, and path spacing.",
     group = grpConf)
revWindow = input.int(10, "Reversal Success Window (Bars)", minval = 3, maxval = 50,
     tooltip = "Number of bars after a confirmed grab within which price must travel one ATR in the reversal direction to count as a successful reversal in the Reversal Rate proof layer. Grabs that do not follow through in time count as no-reversal, keeping the statistic honest.",
     group = grpConf)

grpVis = "Visuals"
showLabels = input.bool(true, "Show Grab Labels", group = grpVis,
     tooltip = "Display the full liquidity-grab labels on confirmed grabs. The wording is intentionally kept descriptive for educational review.")
showLevels = input.bool(false, "Show Swept Level Strikethroughs", group = grpVis,
     tooltip = "Draw horizontal consumed-liquidity lines at swept levels. Disabled by default to keep the first-glance chart clean.")
levelWidth = input.int(2, "Level Line Width", minval = 1, maxval = 5,
     tooltip = "Stroke width for swept level strikethrough lines.",
     group = grpVis)
maxLevelAge = input.int(30, "Max Strikethrough Length (Bars)", minval = 5, maxval = 200,
     tooltip = "Maximum horizontal length of swept level strikethrough lines.",
     group = grpVis)
showZones = input.bool(true, "Show Reversal Projection Zones", group = grpVis,
     tooltip = "Draw forward-projected target zones after confirmed liquidity grabs.")
zoneBars = input.int(24, "Zone Projection Length (Bars)", minval = 5, maxval = 80,
     tooltip = "How many bars the target zone projects forward from the grab context.",
     group = grpVis)
zoneHeightATR = input.float(2.0, "Zone Height (ATR)", minval = 0.5, maxval = 5.0, step = 0.25,
     tooltip = "Height of the reversal projection zone in ATR units.",
     group = grpVis)
zoneOpacity = input.int(88, "Zone Transparency", minval = 60, maxval = 95,
     tooltip = "Transparency of reversal target zones. Higher values make the zone more transparent.",
     group = grpVis)
zoneMergeATR = input.float(0.8, "Zone Merge Distance (ATR)", minval = 0.0, maxval = 3.0, step = 0.1,
     tooltip = "When a new same-direction target zone is close to a recent zone, the older zone extends instead of drawing a duplicate.",
     group = grpVis)
retireOverlappingZones = input.bool(true, "Retire Overlapping Target Zones", group = grpVis,
     tooltip = "When a fresh target zone overlaps an older still-projected zone in both price and time, the older box, centered badge, and path are removed so the newest liquidity event remains visually clear.")
showTargetBadges = input.bool(true, "Show Centered Target Badges", group = grpVis,
     tooltip = "Adds a centered badge inside each target zone. The badge is a separate label, not box text, for cleaner chart rendering.")
showGrabPath = input.bool(true, "Show Grab-to-Target Path", group = grpVis,
     tooltip = "Draws a bold educational rail from the liquidity grab context toward the projected target zone.")
pathWidth = input.int(3, "Grab Path Width", minval = 1, maxval = 6,
     tooltip = "Stroke width for the educational grab-to-target path.",
     group = grpVis)
showMarkerTriangles = input.bool(false, "Show Triangle Markers", group = grpVis,
     tooltip = "Optional tiny triangle markers for users who prefer additional event anchors. Disabled by default because the label and path already mark the signal.")
maxVisibleVisuals = input.int(24, "Maximum Visual Sets", minval = 5, maxval = 80,
     tooltip = "Limits retained target zones, badges, and path rails so historical charts remain readable.",
     group = grpVis)

grpSize = "Sizes"
labelSizeOpt = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip = "Font size for grab labels and target badges.",
     group = grpSize)
panelSizeOpt = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip = "Font size for the statistics panel.",
     group = grpSize)

grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel,
     tooltip = "Show or hide the AGPro status panel. Enabled by default for publication screenshots.")
panelPos = input.string("Top Right", "Panel Position",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     tooltip = "Screen location of the statistics panel.",
     group = grpPanel)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"],
     tooltip = "Controls the panel color theme while keeping the blue AGPro header unchanged.",
     group = grpPanel)

grpAlert = "Alerts"
alertBull = input.bool(true, "Alert on Bullish Grab", group = grpAlert,
     tooltip = "Trigger alert when a bullish liquidity grab is confirmed.")
alertBear = input.bool(true, "Alert on Bearish Grab", group = grpAlert,
     tooltip = "Trigger alert when a bearish liquidity grab is confirmed.")

// ═════════════════════════════════════════════════
// AGPro Color Palette
// ═════════════════════════════════════════════════
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgDark   = color.rgb(15, 23, 42)
panelBgSlate  = color.rgb(30, 41, 59)
panelBgLight  = color.rgb(245, 247, 250)
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

panelIsLight = panelTheme == "Clean Light"
panelBg = panelTheme == "Slate" ? panelBgSlate : panelIsLight ? panelBgLight : panelBgDark
panelBorder = panelIsLight ? panelBorderL : panelBorderD
panelLabelCol = panelIsLight ? panelLabelL : panelLabelD
panelValueCol = panelIsLight ? panelValueL : panelValueD

// ═════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════
f_size(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

f_panelPos(p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Top Right" ? position.top_right :
     p == "Middle Left" ? position.middle_left :
     p == "Middle Center" ? position.middle_center :
     p == "Middle Right" ? position.middle_right :
     p == "Bottom Left" ? position.bottom_left :
     p == "Bottom Center" ? position.bottom_center : position.bottom_right

labelSz = f_size(labelSizeOpt)
panelSz = f_size(panelSizeOpt)

// ═════════════════════════════════════════════════
// CORE DATA
// ═════════════════════════════════════════════════
atr = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)

effMinLevels  = presetMode == "Aggressive" ? 2 : presetMode == "Balanced" ? 2 : presetMode == "Conservative" ? 3 : minLevelsSwept
effClusterATR = presetMode == "Aggressive" ? 0.7 : presetMode == "Balanced" ? 0.45 : presetMode == "Conservative" ? 0.35 : clusterATR
effCooldown   = presetMode == "Aggressive" ? 2 : presetMode == "Balanced" ? 5 : presetMode == "Conservative" ? 10 : cooldownBars
effVolMult    = presetMode == "Aggressive" ? 1.1 : presetMode == "Balanced" ? 1.5 : presetMode == "Conservative" ? 2.0 : volMult
effWickATR    = presetMode == "Aggressive" ? 0.15 : presetMode == "Balanced" ? 0.3 : presetMode == "Conservative" ? 0.45 : minWickATR

phRaw = ta.pivothigh(high, swingLen, swingLen)
plRaw = ta.pivotlow(low, swingLen, swingLen)

inSession = not na(time(timeframe.period, sessionSpec))
var float sessHigh = na
var float sessLow = na
sessStart = inSession and not inSession[1]
if sessStart
    sessHigh := high
    sessLow := low
else if inSession
    sessHigh := math.max(nz(sessHigh, high), high)
    sessLow := math.min(nz(sessLow, low), low)

pdh = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead = barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead = barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead = barmerge.lookahead_on)

// ═════════════════════════════════════════════════
// LEVEL REGISTRY
// ═════════════════════════════════════════════════
var array<float> hiLevels = array.new<float>()
var array<int> hiBars = array.new<int>()
var array<string> hiTags = array.new<string>()
var array<float> loLevels = array.new<float>()
var array<int> loBars = array.new<int>()
var array<string> loTags = array.new<string>()

f_addHiLevel(float price, int barIdx, string tag) =>
    mergeIdx = -1
    if levelDedupATR > 0 and not na(atr) and array.size(hiLevels) > 0
        tol = atr * levelDedupATR
        for i = 0 to array.size(hiLevels) - 1
            if math.abs(array.get(hiLevels, i) - price) <= tol
                mergeIdx := i
                break
    if mergeIdx >= 0
        array.set(hiLevels, mergeIdx, math.max(array.get(hiLevels, mergeIdx), price))
        oldTag = array.get(hiTags, mergeIdx)
        if not str.contains(oldTag, tag)
            array.set(hiTags, mergeIdx, oldTag + "+" + tag)
    else
        array.push(hiLevels, price)
        array.push(hiBars, barIdx)
        array.push(hiTags, tag)

f_addLoLevel(float price, int barIdx, string tag) =>
    mergeIdx = -1
    if levelDedupATR > 0 and not na(atr) and array.size(loLevels) > 0
        tol = atr * levelDedupATR
        for i = 0 to array.size(loLevels) - 1
            if math.abs(array.get(loLevels, i) - price) <= tol
                mergeIdx := i
                break
    if mergeIdx >= 0
        array.set(loLevels, mergeIdx, math.min(array.get(loLevels, mergeIdx), price))
        oldTag = array.get(loTags, mergeIdx)
        if not str.contains(oldTag, tag)
            array.set(loTags, mergeIdx, oldTag + "+" + tag)
    else
        array.push(loLevels, price)
        array.push(loBars, barIdx)
        array.push(loTags, tag)

if useSwing and not na(phRaw)
    f_addHiLevel(phRaw, bar_index - swingLen, "Swing")
if useSwing and not na(plRaw)
    f_addLoLevel(plRaw, bar_index - swingLen, "Swing")

sessEnd = not inSession and inSession[1]
if useSession and sessEnd
    if not na(sessHigh[1])
        f_addHiLevel(sessHigh[1], bar_index - 1, "Session")
    if not na(sessLow[1])
        f_addLoLevel(sessLow[1], bar_index - 1, "Session")

newDay = timeframe.change("D")
if usePDHPDL and newDay and not na(pdh)
    f_addHiLevel(pdh, bar_index, "PDH")
if usePDHPDL and newDay and not na(pdl)
    f_addLoLevel(pdl, bar_index, "PDL")

newWk = timeframe.change("W")
if usePWHPWL and newWk and not na(pwh)
    f_addHiLevel(pwh, bar_index, "PWH")
if usePWHPWL and newWk and not na(pwl)
    f_addLoLevel(pwl, bar_index, "PWL")

if barstate.isconfirmed
    while array.size(hiBars) > 0 and (bar_index - array.get(hiBars, 0)) > levelLookback
        array.shift(hiLevels)
        array.shift(hiBars)
        array.shift(hiTags)
    while array.size(loBars) > 0 and (bar_index - array.get(loBars, 0)) > levelLookback
        array.shift(loLevels)
        array.shift(loBars)
        array.shift(loTags)
    while array.size(hiLevels) > maxActiveLevels
        array.shift(hiLevels)
        array.shift(hiBars)
        array.shift(hiTags)
    while array.size(loLevels) > maxActiveLevels
        array.shift(loLevels)
        array.shift(loBars)
        array.shift(loTags)

// ═════════════════════════════════════════════════
// GRAB DETECTION
// ═════════════════════════════════════════════════
sweptHiCount = 0
sweptHiMax = 0.0
sweptHiMin = 99999999.0
var array<int> sweptHiIdx = array.new<int>()
array.clear(sweptHiIdx)

if array.size(hiLevels) > 0
    for i = 0 to array.size(hiLevels) - 1
        lvl = array.get(hiLevels, i)
        if high > lvl and high[1] <= lvl
            sweptHiCount += 1
            sweptHiMax := math.max(sweptHiMax, lvl)
            sweptHiMin := math.min(sweptHiMin, lvl)
            array.push(sweptHiIdx, i)

sweptLoCount = 0
sweptLoMax = 0.0
sweptLoMin = 99999999.0
var array<int> sweptLoIdx = array.new<int>()
array.clear(sweptLoIdx)

if array.size(loLevels) > 0
    for i = 0 to array.size(loLevels) - 1
        lvl = array.get(loLevels, i)
        if low < lvl and low[1] >= lvl
            sweptLoCount += 1
            sweptLoMax := math.max(sweptLoMax, lvl)
            sweptLoMin := math.min(sweptLoMin, lvl)
            array.push(sweptLoIdx, i)

hiClusterOK = sweptHiCount >= effMinLevels and (sweptHiMax - sweptHiMin) <= atr * effClusterATR
loClusterOK = sweptLoCount >= effMinLevels and (sweptLoMax - sweptLoMin) <= atr * effClusterATR
volOK = not useVolSpike or volume > volAvg * effVolMult
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
bearWickOK = not useWickRatio or upperWick >= atr * effWickATR
bullWickOK = not useWickRatio or lowerWick >= atr * effWickATR

var int lastConfirmBar = -99999
inCooldown = (bar_index - lastConfirmBar) < effCooldown
rawBearGrab = hiClusterOK and volOK and bearWickOK and not inCooldown
rawBullGrab = loClusterOK and volOK and bullWickOK and not inCooldown

if rawBearGrab and rawBullGrab
    if sweptHiCount >= sweptLoCount
        rawBullGrab := false
    else
        rawBearGrab := false

// ═════════════════════════════════════════════════
// REVERSAL CONFIRMATION  (confirmed-bar gated for non-repaint)
// ═════════════════════════════════════════════════
var array<int> pendBars = array.new<int>()
var array<int> pendDir = array.new<int>()
var array<float> pendRef = array.new<float>()
var array<int> pendCount = array.new<int>()
var array<float> pendClusHi = array.new<float>()
var array<float> pendClusLo = array.new<float>()
var array<string> pendTag = array.new<string>()

f_buildTag(array<int> idxArr, array<string> tagArr) =>
    result = ""
    if array.size(idxArr) > 0
        for i = 0 to array.size(idxArr) - 1
            ix = array.get(idxArr, i)
            if ix < array.size(tagArr)
                t = array.get(tagArr, ix)
                if not str.contains(result, t)
                    result := result == "" ? t : result + "+" + t
    result

if barstate.isconfirmed and rawBearGrab
    array.push(pendBars, bar_index)
    array.push(pendDir, 1)
    array.push(pendRef, (sweptHiMax + sweptHiMin) / 2)
    array.push(pendCount, sweptHiCount)
    array.push(pendClusHi, sweptHiMax)
    array.push(pendClusLo, sweptHiMin)
    array.push(pendTag, f_buildTag(sweptHiIdx, hiTags))

if barstate.isconfirmed and rawBullGrab
    array.push(pendBars, bar_index)
    array.push(pendDir, -1)
    array.push(pendRef, (sweptLoMax + sweptLoMin) / 2)
    array.push(pendCount, sweptLoCount)
    array.push(pendClusHi, sweptLoMax)
    array.push(pendClusLo, sweptLoMin)
    array.push(pendTag, f_buildTag(sweptLoIdx, loTags))

var bool confirmedBearNow = false
var bool confirmedBullNow = false
var int confirmedCountNow = 0
var int confirmedBarNow = 0
var float confirmedClusHi = na
var float confirmedClusLo = na
var string confirmedTagNow = ""

confirmedBearNow := false
confirmedBullNow := false
confirmedCountNow := 0
confirmedTagNow := ""

if barstate.isconfirmed and array.size(pendBars) > 0
    var array<int> toRemove = array.new<int>()
    array.clear(toRemove)
    for i = 0 to array.size(pendBars) - 1
        pb = array.get(pendBars, i)
        pd = array.get(pendDir, i)
        pc = array.get(pendCount, i)
        pch = array.get(pendClusHi, i)
        pcl = array.get(pendClusLo, i)
        ptg = array.get(pendTag, i)
        elapsed = bar_index - pb
        reversed = useReversal ? (pd == 1 ? close < pcl : close > pch) : true
        expired = elapsed >= reversalBars
        if reversed and elapsed <= reversalBars
            confirmedBearNow := pd == 1
            confirmedBullNow := pd == -1
            confirmedCountNow := pc
            confirmedBarNow := pb
            confirmedClusHi := pch
            confirmedClusLo := pcl
            confirmedTagNow := ptg
            array.push(toRemove, i)
        else if expired
            array.push(toRemove, i)
    while array.size(toRemove) > 0
        ri = array.pop(toRemove)
        array.remove(pendBars, ri)
        array.remove(pendDir, ri)
        array.remove(pendRef, ri)
        array.remove(pendCount, ri)
        array.remove(pendClusHi, ri)
        array.remove(pendClusLo, ri)
        array.remove(pendTag, ri)

confirmedAny = confirmedBearNow or confirmedBullNow

// ═════════════════════════════════════════════════
// STATISTICS  (proof layer)
// ═════════════════════════════════════════════════
var int totalGrabs = 0
var int bullGrabs = 0
var int bearGrabs = 0
var int successfulRev = 0
var int totalLevelsSwept = 0
var int lastGrabBar = 0
var bool hasGrabEver = false
var string lastGrabSources = "-"
var string lastGrabSide = "-"
var int lastGrabQuality = na

if confirmedAny
    totalGrabs += 1
    totalLevelsSwept += confirmedCountNow
    lastGrabBar := confirmedBarNow
    lastConfirmBar := bar_index
    hasGrabEver := true
    lastGrabSources := confirmedTagNow == "" ? "-" : confirmedTagNow
    lastGrabSide := confirmedBullNow ? "Bullish Grab" : "Bearish Grab"
    if confirmedBullNow
        bullGrabs += 1
    if confirmedBearNow
        bearGrabs += 1
    // Grab Quality 0-100: levels swept (0-60) + source quality (0-40)
    qLevels = math.min(60, confirmedCountNow * 15)
    qSrc = 0
    qSrc := qSrc + (str.contains(confirmedTagNow, "PW") ? 22 : 0)
    qSrc := qSrc + (str.contains(confirmedTagNow, "PD") ? 14 : 0)
    qSrc := qSrc + (str.contains(confirmedTagNow, "Session") ? 8 : 0)
    qSrc := qSrc + (str.contains(confirmedTagNow, "Swing") ? 6 : 0)
    qSrc := math.min(40, qSrc)
    lastGrabQuality := math.min(100, qLevels + qSrc)

var array<int> succPendBar = array.new<int>()
var array<int> succPendDir = array.new<int>()
var array<float> succPendTgt = array.new<float>()

if confirmedAny
    array.push(succPendBar, bar_index)
    array.push(succPendDir, confirmedBullNow ? -1 : 1)
    array.push(succPendTgt, confirmedBullNow ? close + atr : close - atr)

if barstate.isconfirmed and array.size(succPendBar) > 0
    var array<int> succRemove = array.new<int>()
    array.clear(succRemove)
    for i = 0 to array.size(succPendBar) - 1
        sb = array.get(succPendBar, i)
        sd = array.get(succPendDir, i)
        st = array.get(succPendTgt, i)
        el = bar_index - sb
        hit = el >= 1 and (sd == -1 ? high >= st : low <= st)
        if hit
            successfulRev += 1
            array.push(succRemove, i)
        else if el >= revWindow
            array.push(succRemove, i)
    while array.size(succRemove) > 0
        ri = array.pop(succRemove)
        array.remove(succPendBar, ri)
        array.remove(succPendDir, ri)
        array.remove(succPendTgt, ri)

// ═════════════════════════════════════════════════
// ACTIVE SETUP + NEXT ACTION  (decision layer)
// ═════════════════════════════════════════════════
var int actDir = 0
var int actBar = 0
var float actTarget = na
var bool actHit = false

if barstate.isconfirmed
    if confirmedAny
        actDir := confirmedBullNow ? 1 : -1
        actBar := bar_index
        actTarget := confirmedBullNow ? confirmedClusHi + atr * zoneHeightATR * 0.5 : confirmedClusLo - atr * zoneHeightATR * 0.5
        actHit := false
    else if actDir != 0
        if not actHit and ((actDir == 1 and high >= actTarget) or (actDir == -1 and low <= actTarget))
            actHit := true
        if bar_index - actBar > zoneBars
            actDir := 0
            actHit := false

string actionText = actDir == 0 ? (hasGrabEver ? "Scan Liquidity" : "Building") :
     actHit ? "Target Reached" :
     (bar_index - actBar) <= (reversalBars + 2) ? (actDir == 1 ? "Long Setup" : "Short Setup") :
     "Target In Play"

color actionColor = actionText == "Long Setup" ? bullColor :
     actionText == "Short Setup" ? bearColor :
     actionText == "Target In Play" ? accentColor :
     actionText == "Target Reached" ? neutralColor : panelLabelCol

// ═════════════════════════════════════════════════
// DRAWING: Swept Level Strikethroughs
// ═════════════════════════════════════════════════
if showLevels and confirmedBearNow and array.size(sweptHiIdx) > 0
    for k = 0 to array.size(sweptHiIdx) - 1
        idx = array.get(sweptHiIdx, k)
        if idx < array.size(hiLevels)
            lvl = array.get(hiLevels, idx)
            clampedStart = math.max(array.get(hiBars, idx), bar_index - maxLevelAge)
            line.new(clampedStart, lvl, bar_index, lvl, color = color.new(bearColor, 20), width = levelWidth, style = line.style_dashed)

if showLevels and confirmedBullNow and array.size(sweptLoIdx) > 0
    for k = 0 to array.size(sweptLoIdx) - 1
        idx = array.get(sweptLoIdx, k)
        if idx < array.size(loLevels)
            lvl = array.get(loLevels, idx)
            clampedStart = math.max(array.get(loBars, idx), bar_index - maxLevelAge)
            line.new(clampedStart, lvl, bar_index, lvl, color = color.new(bullColor, 20), width = levelWidth, style = line.style_dashed)

if confirmedBearNow and array.size(sweptHiIdx) > 0
    sortedHi = array.copy(sweptHiIdx)
    array.sort(sortedHi, order.descending)
    for k = 0 to array.size(sortedHi) - 1
        ri = array.get(sortedHi, k)
        if ri < array.size(hiLevels)
            array.remove(hiLevels, ri)
            array.remove(hiBars, ri)
            array.remove(hiTags, ri)

if confirmedBullNow and array.size(sweptLoIdx) > 0
    sortedLo = array.copy(sweptLoIdx)
    array.sort(sortedLo, order.descending)
    for k = 0 to array.size(sortedLo) - 1
        ri = array.get(sortedLo, k)
        if ri < array.size(loLevels)
            array.remove(loLevels, ri)
            array.remove(loBars, ri)
            array.remove(loTags, ri)

// ═════════════════════════════════════════════════
// DRAWING: Grab Labels
// ═════════════════════════════════════════════════
var array<int> recentLabBars = array.new<int>()
var array<int> recentLabStep = array.new<int>()

f_staggerStep(int curBar, int lookback) =>
    step = 0
    if array.size(recentLabBars) > 0
        for i = 0 to array.size(recentLabBars) - 1
            rb = array.get(recentLabBars, i)
            rs = array.get(recentLabStep, i)
            if curBar - rb <= lookback and rs >= step
                step := rs + 1
    step

if showLabels and confirmedBearNow
    staggerIdx = f_staggerStep(confirmedBarNow, 10)
    yBear = high + atr * (0.8 + 0.45 * staggerIdx)
    txt = "LIQ GRAB - " + str.tostring(confirmedCountNow) + " levels swept"
    label.new(confirmedBarNow, yBear, txt, style = label.style_label_down, color = bearColor, textcolor = headerText, size = labelSz, yloc = yloc.price)
    array.push(recentLabBars, confirmedBarNow)
    array.push(recentLabStep, staggerIdx)

if showLabels and confirmedBullNow
    staggerIdx = f_staggerStep(confirmedBarNow, 10)
    yBull = low - atr * (0.8 + 0.45 * staggerIdx)
    txt = "LIQ GRAB - " + str.tostring(confirmedCountNow) + " levels swept"
    label.new(confirmedBarNow, yBull, txt, style = label.style_label_up, color = bullColor, textcolor = headerText, size = labelSz, yloc = yloc.price)
    array.push(recentLabBars, confirmedBarNow)
    array.push(recentLabStep, staggerIdx)

if array.size(recentLabBars) > 20
    array.shift(recentLabBars)
    array.shift(recentLabStep)

// ═════════════════════════════════════════════════
// DRAWING: Reversal Projection Zones + Badges + Paths
// ═════════════════════════════════════════════════
var array<box> recentZoneBox = array.new<box>()
var array<label> recentZoneBadge = array.new<label>()
var array<line> recentZoneRail = array.new<line>()
var array<float> recentZoneMid = array.new<float>()
var array<int> recentZoneDir = array.new<int>()
var array<int> recentZoneBar = array.new<int>()

f_retireOverlappingZones(float newTop, float newBot, int newLeft, int newRight, int newDir, bool preserveSameDirection) =>
    if retireOverlappingZones and array.size(recentZoneBox) > 0
        i = array.size(recentZoneBox) - 1
        while i >= 0
            b = array.get(recentZoneBox, i)
            rDir = array.get(recentZoneDir, i)
            priceOverlap = newBot <= box.get_top(b) and newTop >= box.get_bottom(b)
            timeOverlap = newLeft <= box.get_right(b) and newRight >= box.get_left(b)
            retireZone = priceOverlap and timeOverlap and (not preserveSameDirection or rDir != newDir)
            if retireZone
                box.delete(b)
                badge = array.get(recentZoneBadge, i)
                if not na(badge)
                    label.delete(badge)
                rail = array.get(recentZoneRail, i)
                if not na(rail)
                    line.delete(rail)
                array.remove(recentZoneBox, i)
                array.remove(recentZoneBadge, i)
                array.remove(recentZoneRail, i)
                array.remove(recentZoneMid, i)
                array.remove(recentZoneDir, i)
                array.remove(recentZoneBar, i)
            i -= 1

f_tryExtendZone(int newDir, float newMid, int currentBar) =>
    extended = false
    if zoneMergeATR > 0 and not na(atr) and array.size(recentZoneBox) > 0
        tol = atr * zoneMergeATR
        for i = 0 to array.size(recentZoneBox) - 1
            rDir = array.get(recentZoneDir, i)
            rMid = array.get(recentZoneMid, i)
            rBar = array.get(recentZoneBar, i)
            if rDir == newDir and math.abs(rMid - newMid) <= tol and (currentBar - rBar) <= zoneBars
                b = array.get(recentZoneBox, i)
                box.set_right(b, currentBar + zoneBars)
                zoneCenter = (box.get_top(b) + box.get_bottom(b)) * 0.5
                if i < array.size(recentZoneBadge)
                    badge = array.get(recentZoneBadge, i)
                    if not na(badge)
                        label.set_x(badge, int(math.round((box.get_left(b) + box.get_right(b)) * 0.5)))
                        label.set_y(badge, zoneCenter)
                if i < array.size(recentZoneRail)
                    rail = array.get(recentZoneRail, i)
                    if not na(rail)
                        line.set_x2(rail, currentBar + zoneBars)
                        line.set_y2(rail, zoneCenter)
                array.set(recentZoneBar, i, currentBar)
                extended := true
                break
    extended

f_addVisualSet(box b, label badge, line rail, float midZ, int dirZ) =>
    array.push(recentZoneBox, b)
    array.push(recentZoneBadge, badge)
    array.push(recentZoneRail, rail)
    array.push(recentZoneMid, midZ)
    array.push(recentZoneDir, dirZ)
    array.push(recentZoneBar, bar_index)
    while array.size(recentZoneBox) > maxVisibleVisuals
        oldBox = array.shift(recentZoneBox)
        box.delete(oldBox)
        oldBadge = array.shift(recentZoneBadge)
        if not na(oldBadge)
            label.delete(oldBadge)
        oldRail = array.shift(recentZoneRail)
        if not na(oldRail)
            line.delete(oldRail)
        array.shift(recentZoneMid)
        array.shift(recentZoneDir)
        array.shift(recentZoneBar)

if showZones and confirmedBearNow
    topZ = confirmedClusLo
    botZ = confirmedClusLo - atr * zoneHeightATR
    midZ = (topZ + botZ) * 0.5
    endB = bar_index + zoneBars
    mergedZone = f_tryExtendZone(1, midZ, bar_index)
    f_retireOverlappingZones(topZ, botZ, confirmedBarNow, endB, 1, mergedZone)
    if not mergedZone
        b = box.new(confirmedBarNow, topZ, endB, botZ, border_color = color.new(bearColor, 38), bgcolor = color.new(bearColor, zoneOpacity), border_width = 2)
        badgeX = int(math.round((confirmedBarNow + endB) * 0.5))
        badge = showTargetBadges ? label.new(badgeX, midZ, "BEARISH\nTARGET ZONE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = bearColor, textcolor = headerText, size = labelSz) : na
        rail = showGrabPath ? line.new(confirmedBarNow, high, endB, midZ, xloc = xloc.bar_index, color = color.new(bearColor, 0), width = pathWidth, style = line.style_solid) : na
        f_addVisualSet(b, badge, rail, midZ, 1)

if showZones and confirmedBullNow
    topZ = confirmedClusHi + atr * zoneHeightATR
    botZ = confirmedClusHi
    midZ = (topZ + botZ) * 0.5
    endB = bar_index + zoneBars
    mergedZone = f_tryExtendZone(-1, midZ, bar_index)
    f_retireOverlappingZones(topZ, botZ, confirmedBarNow, endB, -1, mergedZone)
    if not mergedZone
        b = box.new(confirmedBarNow, topZ, endB, botZ, border_color = color.new(bullColor, 38), bgcolor = color.new(bullColor, zoneOpacity), border_width = 2)
        badgeX = int(math.round((confirmedBarNow + endB) * 0.5))
        badge = showTargetBadges ? label.new(badgeX, midZ, "BULLISH\nTARGET ZONE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = bullColor, textcolor = headerText, size = labelSz) : na
        rail = showGrabPath ? line.new(confirmedBarNow, low, endB, midZ, xloc = xloc.bar_index, color = color.new(bullColor, 0), width = pathWidth, style = line.style_solid) : na
        f_addVisualSet(b, badge, rail, midZ, -1)

// ═════════════════════════════════════════════════
// STATISTICS PANEL  (decision-first)
// ═════════════════════════════════════════════════
var table panel = na
var string panelPosCache = ""
var string panelThemeCache = ""

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosCache := ""
    panelThemeCache := ""

if showPanel and barstate.islast
    needPanel = na(panel) or panelPosCache != panelPos or panelThemeCache != panelTheme
    if needPanel
        if not na(panel)
            table.delete(panel)
        panel := table.new(f_panelPos(panelPos), 2, 10, border_width = 1, border_color = panelBorder, frame_width = 1, frame_color = panelBorder)
        panelPosCache := panelPos
        panelThemeCache := panelTheme
    table.set_position(panel, f_panelPos(panelPos))
    table.clear(panel, 0, 0, 1, 9)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Liquidity Grab Detector", bgcolor = headerBg, text_color = headerText, text_size = panelSz, text_halign = text.align_center)

    activeLvls = array.size(hiLevels) + array.size(loLevels)
    revRate = totalGrabs > 0 ? successfulRev * 100.0 / totalGrabs : 0.0
    avgLvl = totalGrabs > 0 ? totalLevelsSwept * 1.0 / totalGrabs : 0.0
    lastAgoTxt = not hasGrabEver ? "-" : str.tostring(bar_index - lastGrabBar) + " bars ago"
    revCol = revRate >= 60 ? bullColor : revRate >= 40 ? neutralColor : bearColor
    revTxt = totalGrabs > 0 ? str.tostring(revRate, "#.#") + "% (" + str.tostring(totalGrabs) + ")" : "-"
    biasText = totalGrabs == 0 ? "Building" : bullGrabs > bearGrabs ? "Bull Grabs Lead" : bearGrabs > bullGrabs ? "Bear Grabs Lead" : "Balanced"
    biasCol = bullGrabs > bearGrabs ? bullColor : bearGrabs > bullGrabs ? bearColor : neutralColor
    qTxt = na(lastGrabQuality) ? "-" : str.tostring(lastGrabQuality) + " / 100"
    qCol = na(lastGrabQuality) ? panelValueCol : lastGrabQuality >= 70 ? bullColor : lastGrabQuality >= 45 ? neutralColor : panelLabelCol

    table.cell(panel, 0, 1, "Action", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSz, text_halign = text.align_left)
    table.cell(panel, 1, 1, actionText, bgcolor = panelBg, text_color = actionColor, text_size = panelSz, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Grab Quality", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSz, text_halign = text.align_left)
    table.cell(panel, 1, 2, qTxt, bgcolor = panelBg, text_color = qCol, text_size = panelSz, text_halign = text.align_right)
    table.cell(panel, 0, 3, "Grab Side", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSz, text_halign = text.align_left)
    table.cell(panel, 1, 3, lastGrabSide, bgcolor = panelBg, text_color = lastGrabSide == "Bullish Grab" ? bullColor : lastGrabSide == "Bearish Grab" ? bearColor : panelValueCol, text_size = panelSz, text_halign = text.align_right)
    table.cell(panel, 0, 4, "Sources", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSz, text_halign = text.align_left)
    table.cell(panel, 1, 4, lastGrabSources, bgcolor = panelBg, text_color = accentColor, text_size = panelSz, text_halign = text.align_right)
    table.cell(panel, 0, 5, "Last Grab", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSz, text_halign = text.align_left)
    table.cell(panel, 1, 5, lastAgoTxt, bgcolor = panelBg, text_color = panelValueCol, text_size = panelSz, text_halign = text.align_right)
    table.cell(panel, 0, 6, "Reversal Rate", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSz, text_halign = text.align_left)
    table.cell(panel, 1, 6, revTxt, bgcolor = panelBg, text_color = revCol, text_size = panelSz, text_halign = text.align_right)
    table.cell(panel, 0, 7, "Bias", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSz, text_halign = text.align_left)
    table.cell(panel, 1, 7, biasText, bgcolor = panelBg, text_color = biasCol, text_size = panelSz, text_halign = text.align_right)
    table.cell(panel, 0, 8, "Avg Levels", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSz, text_halign = text.align_left)
    table.cell(panel, 1, 8, str.tostring(avgLvl, "#.##"), bgcolor = panelBg, text_color = panelValueCol, text_size = panelSz, text_halign = text.align_right)
    table.cell(panel, 0, 9, "Active Levels", bgcolor = panelBg, text_color = panelLabelCol, text_size = panelSz, text_halign = text.align_left)
    table.cell(panel, 1, 9, str.tostring(activeLvls), bgcolor = panelBg, text_color = panelValueCol, text_size = panelSz, text_halign = text.align_right)

// ═════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════
if alertBull and confirmedBullNow
    alert("Liquidity Grab Detector [AGPro Series]: BULLISH grab confirmed - " + str.tostring(confirmedCountNow) + " lows swept on " + syminfo.ticker, alert.freq_once_per_bar_close)

if alertBear and confirmedBearNow
    alert("Liquidity Grab Detector [AGPro Series]: BEARISH grab confirmed - " + str.tostring(confirmedCountNow) + " highs swept on " + syminfo.ticker, alert.freq_once_per_bar_close)

plotshape(showMarkerTriangles and confirmedBullNow, title = "Bullish Grab Marker", style = shape.triangleup, location = location.belowbar, color = bullColor, size = size.tiny)
plotshape(showMarkerTriangles and confirmedBearNow, title = "Bearish Grab Marker", style = shape.triangledown, location = location.abovebar, color = bearColor, size = size.tiny)

alertcondition(confirmedBullNow, title = "Bullish Liquidity Grab", message = "Bullish liquidity grab confirmed on {{ticker}}")
alertcondition(confirmedBearNow, title = "Bearish Liquidity Grab", message = "Bearish liquidity grab confirmed on {{ticker}}")
````
