<!-- tradingview-pine-id: PUB;1101d3f02fbd4bd693666f9538cd12ea -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MYND Fractal Support/Resistance Density Map [v1.4]

Source: https://www.tradingview.com/script/SCcF4BlS-MYND-Fractal-Support-Resistance-Density-Map-v1-4/

## Description

MYND Fractal Support/Resistance Density Map [v1.4]

A decayed, multi-scale support/resistance DENSITY map - not a single pivot-line tool. It detects swing highs/lows at 3 configurable pivot scales, scores every confirmed pivot into a rolling price-bin array (volume-weighted), and decays that score every bar so old, stale levels fade out instead of piling up forever. The Top-N highest-density bins are surfaced as ranked, cluster-merged S/R zones - with early-warning alerts, reject-vs-break classification across all tracked zones, an optional full heatmap view, on-chart labels, and now a dashboard that shows distance-to-#1-zone, the single nearest zone to price, and when a zone's density really represents several folded-together levels.

WHAT IT DOES

Three pivot scales (short/medium/long) independently detect confirmed swing highs and lows. Every confirmed pivot adds a weighted density score to whichever price bin it touches - longer, more significant scales contribute more, and a pivot's own relative volume scales its contribution further. All accumulated density decays by a fixed factor every bar, so a level that mattered years ago but hasn't been touched since gradually fades. Near-adjacent candidate bins fold into one merged zone rather than showing as near-duplicates. The highest-density bins are ranked and surfaced as the tool's Top-N zones.

HOW TO USE IT

Treat higher-density zones as levels more likely to produce SOME reaction - a bounce, a rejection, a pause - not as levels guaranteed to hold. Use the Approaching-Zone alerts (Zone #1-specific or the all-zone aggregate) as your cue to start watching closely, then read the Reject/Break tag once price actually resolves. Check the new Nearest Zone to Price row for what's immediately relevant right now, separate from which zone ranks #1 by density overall. Raise Zone Cluster Merge Distance if nearby zones keep reading as near-duplicates - and watch for the "merged Nx" tag as a reminder that a zone's density may represent several folded levels, not one. Raise Minimum Touches to Show if you only want to act on zones that have already proven themselves. Turn on HTF Confluence for extra cross-timeframe conviction, and the Density Heatmap to see the whole structure at a glance.

KEY FEATURES

A live dashboard showing each Top-N zone's price, density, freshness, merge status, and touch-threshold status, plus distance-to-#1-zone and the single nearest zone to price. On-chart zone price labels. Volume-weighted, cluster-merged density scoring. Fully adjustable zone line width/style/color (per rank), table border width/color, and heatmap color. Full cross-tool export for all 5 possible zones plus distance-to-#1-zone. 10 individual alerts plus 1 combo bundle.

SETTINGS WORTH TUNING FIRST

Per-Bar Decay Rate is the core dial on how fast old levels fade. Enable Volume-Weighted Density is on by default - turn off if a ticker's volume data is unreliable. Zone Cluster Merge Distance controls how aggressively nearby candidates get folded together (and how often you'll see a "merged Nx" tag). Minimum Touches to Show is 0 by default - raise it to filter out unproven levels. Enable HTF Confluence Check is off by default.

WHAT THIS TOOL DELIBERATELY DOES NOT DO

Density is a proxy for level significance, not a guarantee a zone will hold. HTF Confluence compares against the HTF's own recent swing high/low, not a second full density map - a disclosed simplification. The touch count keeps accumulating in the background regardless of the Minimum-Touch filter setting. Zone lines, labels, and the heatmap only reflect the most recent bar's selection, not a full historical record. The new merge-count and nearest-zone-to-price data are dashboard-only - not yet exposed via the Cross-Tool Signal Export plots.

ALERTS

10 individual alerts (Price Entered Top-N Zone, Price Exited All Top-N Zones, Top Zone Reshuffled, Price Approaching #1 Zone, Zone #1 Rejected/Bounce, Zone #1 Broken Through, Zone #1 Aligned with HTF Level, Any Zone Approaching, Any Zone Rejected, Any Zone Broken Through) plus 1 combo bundle (ALL Fractal S/R Signals).

FEEDBACK WELCOME

If you've tweaked a setting, found a combination with another indicator that works well, or have an idea for what would make this more useful, I'd genuinely like to hear about it - drop a comment below (it helps other users too), or send a direct message if you'd rather keep the details private.

This tool identifies patterns in past price and structure - it is not a guarantee of future performance. This tool is provided for informational and educational purposes and does not constitute financial advice. Trading involves risk; past performance and historical patterns do not guarantee future results.

---

## Source Code

````pine
//@version=6
indicator(title="MYND Fractal Support/Resistance Density Map [v1.4]", shorttitle="MYND Fractal S/R v1.4", overlay=true, max_lines_count=20, max_labels_count=20, max_boxes_count=60)

// =====================================================================================
// MYND FRACTAL SUPPORT/RESISTANCE DENSITY MAP v1.1  (tool #17)
// A DECAYED, MULTI-SCALE support/resistance DENSITY map, not a single pivot-line tool.
// Detects swing highs/lows at 3 configurable pivot scales (short/medium/long), maintains a
// fixed-size rolling price-bin array anchored near the current price, and adds a "density"
// score to whichever bin each confirmed pivot touches - weighted heavier for pivots from a
// longer/more significant scale, and decayed every bar so old, stale levels fade out rather
// than accumulating forever. The top-N highest-density bins are surfaced as S/R zones.
//
// HONEST SCOPE (disclosed simplification): density is a PROXY for level significance
// (how often, and at how many scales, price has pivoted near a level, discounted by age),
// not a claim that a zone will actually hold - price can and does break through
// high-density zones. The bin array is anchored to a reference price that is periodically
// (or, if price drifts out of the array's covered range, immediately) re-anchored - a
// re-anchor event resets all accumulated density, a disclosed tradeoff for keeping the
// array's bounds always valid without needing to shift/remap array contents. Zone LINES are
// only drawn/updated at the most recent bar (not on every historical bar) to avoid drawing
// thousands of duplicate overlapping objects - the underlying density data is still computed
// every bar so alerts fire correctly in real time. NEW in v1.1: the HTF Density Overlay is a
// simplified confluence check against the HTF's own recent confirmed swing high/low - it is
// NOT a second full density array on the HTF (that would require exporting an entire array
// across request.security(), which is fragile) - a disclosed simplification, not a bug.

// =====================================================================================

// ---------------------------- INPUTS: PIVOT SCALES (Total Control) ----------------------------
grpPiv = "Pivot Scales"
pivotLenShort = input.int(5, "Short Scale Pivot Length", minval=2, group=grpPiv, tooltip="Symmetric left/right bar count for the shortest, most reactive pivot scale.")
pivotLenMedium = input.int(13, "Medium Scale Pivot Length", minval=2, group=grpPiv, tooltip="Symmetric left/right bar count for the middle pivot scale, between the short and long scales.")
pivotLenLong = input.int(34, "Long Scale Pivot Length", minval=2, group=grpPiv, tooltip="The longest, least reactive pivot scale - a confirmed pivot here typically marks a more significant swing.")
weightShort = input.float(1.0, "Short Scale Density Weight", minval=0.0, group=grpPiv, tooltip="How much density a short-scale pivot contributes to its bin. Lower relative to Medium/Long since short-scale pivots are the noisiest.")
weightMedium = input.float(2.0, "Medium Scale Density Weight", minval=0.0, group=grpPiv, tooltip="How much density a medium-scale pivot contributes to its bin.")
weightLong = input.float(3.0, "Long Scale Density Weight", minval=0.0, group=grpPiv, tooltip="Longer-scale pivots contribute more density by default, since they represent more significant swings.")
enableVolumeWeighting = input.bool(true, "Enable Volume-Weighted Density", group=grpPiv, tooltip="Scales each pivot's density contribution by its own relative volume (vs. a moving average), so a swing on high volume counts for more than a thin one - on top of the scale weighting above.")
volAvgLen = input.int(20, "Volume Average Length", minval=1, group=grpPiv, tooltip="Lookback for the average volume used to compute each pivot's relative volume multiplier.")
volWeightCap = input.float(3.0, "Max Volume Weight Multiplier", minval=1.0, group=grpPiv, tooltip="Caps how much a single high-volume pivot can amplify its density contribution, so one extreme print doesn't dominate the map.")

// ---------------------------- INPUTS: DENSITY ENGINE (Total Control) ----------------------------
grpEng = "Density Engine"
decayRate = input.float(0.995, "Per-Bar Decay Rate", minval=0.90, maxval=0.9999, step=0.001, group=grpEng, tooltip="Every bar, all accumulated density is multiplied by this factor. Lower = old levels fade faster.")
binSizeMode = input.string("ATR-Based", "Bin Size Mode", options=["Manual", "ATR-Based"], group=grpEng, tooltip="ATR-Based scales each bin to current volatility automatically; Manual lets you fix an exact price width per bin regardless of volatility.")
manualBinSize = input.float(1.0, "Manual Bin Size", minval=0.0001, group=grpEng, tooltip="Only used when Bin Size Mode is Manual - the fixed price width of one bin.")
atrLenForBin = input.int(14, "ATR Length for Bin Size", minval=1, group=grpEng, tooltip="Only used when Bin Size Mode is ATR-Based - the lookback for the ATR that sets bin width.")
atrMultForBin = input.float(0.5, "ATR Multiplier for Bin Size", minval=0.01, group=grpEng, tooltip="Only used when Bin Size Mode is ATR-Based - bin width = ATR x this multiplier. Smaller = finer/narrower bins.")
maxBinsEachSide = input.int(60, "Max Bins Each Side of Anchor", minval=10, maxval=150, group=grpEng, tooltip="Caps how far the map extends above/below its current anchor price, in bin-size units.")
reanchorIntervalBars = input.int(500, "Re-Anchor Interval (bars)", minval=50, group=grpEng, tooltip="The map periodically re-centers on the current price and resets accumulated density (also triggers immediately if price drifts outside the map's covered range).")

// ---------------------------- INPUTS: ZONES & ALERTS ----------------------------
grpZone = "Zones"
topN = input.int(3, "Top N Zones to Track/Display", minval=1, maxval=5, group=grpZone, tooltip="How many of the highest-density bins to surface as S/R zones (dashboard rows, zone lines, and zone-entry/exit alerts all scale to this count).")
zoneAlertTolerancePct = input.float(0.1, "Zone Alert Tolerance (% of bin size)", minval=0.0, maxval=100.0, group=grpZone, tooltip="How close price must be to a zone's bin range, as a percentage of one bin's size, to count as 'inside' that zone for alert purposes.")
enableClusterMerge = input.bool(true, "Enable Zone Cluster Merge", group=grpZone, tooltip="When two Top-N candidates land within Cluster Merge Distance of each other, folds them into one wider zone (summing their density) instead of showing two near-duplicate lines a few bins apart.")
clusterMergeBins = input.int(2, "Zone Cluster Merge Distance (bins)", minval=0, maxval=20, group=grpZone, tooltip="After selecting a zone, any other candidate bin within this many bins gets folded into it rather than shown separately. 0 disables merging.")
minTouchesToShow = input.int(0, "Minimum Touches to Show a Zone", minval=0, group=grpZone, tooltip="Hides a zone's line/label/alerts until it has been entered at least this many times since its last reset - filters out one-off, unproven levels. 0 = show immediately (matches prior behavior). The touch count itself keeps accumulating in the background either way.")

// ---------------------------- INPUTS: ZONE #1 EARLY WARNING & CLASSIFICATION (NEW) ----------------------------
grpTop1 = "Zone #1 Early Warning & Classification"
approachThresholdATRMult = input.float(1.0, "Approach Warning Distance (x ATR)", minval=0.1, group=grpTop1, tooltip="Fires an early-warning alert when price gets within this many ATRs of a zone but hasn't touched it yet - a heads-up before the actual test. Used both for the #1-zone-specific alert and the all-zone aggregate alert.")

// ---------------------------- INPUTS: MULTI-TIMEFRAME CONFLUENCE (NEW) ----------------------------
grpHtf = "Multi-Timeframe Confluence"
enableHtfDensity = input.bool(false, "Enable HTF Confluence Check", group=grpHtf, tooltip="Compares this chart's #1 zone against the HTF's own recent confirmed swing high/low, and flags when they line up - a simplified confluence check, not a second full density map (see Honest Scope).")
htfTF = input.timeframe("240", "HTF for Confluence Check", group=grpHtf, tooltip="The higher timeframe whose recent swing highs/lows are compared against this chart's #1 zone.")
htfPivLen = input.int(10, "HTF Pivot Length", minval=2, group=grpHtf, tooltip="Symmetric left/right bar count (on the HTF) used to find its own recent confirmed swing highs/lows for comparison.")
htfAlignTolerancePct = input.float(0.5, "HTF Alignment Tolerance (% of price)", minval=0.0, group=grpHtf, tooltip="How close (as a % of current price) this chart's #1 zone must be to the HTF's swing level to count as aligned.")

// ---------------------------- INPUTS: CROSS-TOOL SIGNAL EXPORT (NEW) ----------------------------
grpExport = "Cross-Tool Signal Export"
enableSignalExport = input.bool(true, "Enable Signal Export Plots (for other MYND tools)", group=grpExport, tooltip="Exposes this tool's #1 zone price/density and zone-event signals as invisible plots so other MYND indicators' input.source() dropdowns can reference them directly.")

// ---------------------------- INPUTS: THEME & ACCESSIBILITY ----------------------------
themeMode = input.string("Light", "Theme Preset", options=["Light", "Dark", "Custom"], group="Theme & Accessibility", tooltip="Light/Dark apply a matched palette automatically; Custom uses the color pickers below.")
colorblindMode = input.bool(false, "Colorblind-Safe Signal Colors", group="Theme & Accessibility", tooltip="Swaps the zone/alert-highlight palette for an Okabe-Ito colorblind-safe pair, overriding the theme preset's bullish/bearish colors.")

// ---------------------------- INPUTS: ZONE COLORS (Total Control, NEW) ----------------------------
grpZoneColor = "Zone Colors (Total Control)"
useRankColors = input.bool(true, "Use Per-Rank Zone Colors", group=grpZoneColor, tooltip="When on, each zone rank (1st-5th) gets its own configurable color below, instead of one shared color with an opacity fade for ranks below #1.")
zone1ColorCustom = input.color(color.new(color.red, 0), "Zone #1 Color", group=grpZoneColor)
zone2ColorCustom = input.color(color.new(color.orange, 0), "Zone #2 Color", group=grpZoneColor)
zone3ColorCustom = input.color(color.new(color.yellow, 0), "Zone #3 Color", group=grpZoneColor, tooltip="Only used if Top N Zones to Track/Display is 3 or more.")
zone4ColorCustom = input.color(color.new(color.aqua, 0), "Zone #4 Color", group=grpZoneColor, tooltip="Only used if Top N Zones to Track/Display is 4 or more.")
zone5ColorCustom = input.color(color.new(color.purple, 0), "Zone #5 Color", group=grpZoneColor, tooltip="Only used if Top N Zones to Track/Display is 5.")

// ---------------------------- INPUTS: DISPLAY ----------------------------
grpDisp = "Display"
showZoneLines = input.bool(true, "Plot Top-N Zone Lines", group=grpDisp, tooltip="Draws a horizontal line at each of the Top-N zone prices, updated on the most recent bar.")
zoneLineWidth = input.int(2, "Zone Line Width", minval=1, maxval=10, group=grpDisp, tooltip="Thickness of the Top-N zone lines.")
zoneLineStyleIn = input.string("Solid", "Zone Line Style", options=["Solid", "Dashed", "Dotted"], group=grpDisp, tooltip="Line style for the Top-N zone lines.")
showZoneLabels = input.bool(true, "Show On-Chart Zone Price Labels", group=grpDisp, tooltip="Draws each zone's price/rank directly at the right edge of its line, so you can read it at a glance without checking the dashboard table.")
zoneLabelSizeIn = input.string("Normal", "Zone Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grpDisp, tooltip="Font size for the on-chart zone price labels.")
showTable = input.bool(true, "Show Dashboard Table", group=grpDisp, tooltip="Displays the on-chart dashboard summarizing all zones, touches, and HTF confluence.")
tablePosIn = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpDisp, tooltip="Where the dashboard table anchors on the chart.")
tableSizeIn = input.string("Normal", "Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grpDisp, tooltip="Font size used throughout the dashboard table.")
tableBorderWidthIn = input.int(1, "Table Border Width", minval=0, maxval=5, group=grpDisp, tooltip="Thickness of the dashboard table's outer border and cell gridlines.")
tableBorderColorCustom = input.color(color.new(color.gray, 40), "Table Border Color", group=grpDisp, tooltip="Color of the dashboard table's outer border and cell gridlines.")
headerBgColorCustom = input.color(color.new(color.navy, 0), "Custom Table Header Background", group=grpDisp, tooltip="Only applied when Theme Preset is Custom.")
headerTextColorCustom = input.color(color.new(color.white, 0), "Custom Table Header Text", group=grpDisp, tooltip="Only applied when Theme Preset is Custom.")
bullishColorCustom = input.color(color.new(color.lime, 0), "Custom Zone Line Color", group=grpDisp, tooltip="Only applied when Theme Preset is Custom AND Colorblind-Safe is off AND Use Per-Rank Zone Colors is off.")
bearishColorCustom = input.color(color.new(color.red, 0), "Custom Alert Highlight Color", group=grpDisp, tooltip="Only applied when Theme Preset is Custom AND Colorblind-Safe is off AND Use Per-Rank Zone Colors is off.")

// ---------------------------- INPUTS: DENSITY HEATMAP (Optional Visual, NEW) ----------------------------
grpHeat = "Density Heatmap (Optional Visual)"
showHeatmap = input.bool(false, "Show Density Heatmap Bands", group=grpHeat, tooltip="Draws colored background bands across the WHOLE density map (not just the Top-N zones), shaded by relative density, so you can see the full structure at a glance. Off by default - heavier visual, best used zoomed into the near-term price range.")
heatmapMaxBands = input.int(20, "Max Heatmap Bands", minval=1, maxval=60, group=grpHeat, tooltip="Caps how many of the highest-density bins get drawn as bands, to control visual clutter and stay within the chart's object limits.")
heatmapMinDensity = input.float(0.5, "Minimum Density to Draw a Band", minval=0.0, group=grpHeat, tooltip="Bins with less density than this are skipped entirely, so faint/decayed noise doesn't clutter the heatmap.")
heatmapUseThemeColor = input.bool(true, "Use Theme Color for Heatmap", group=grpHeat, tooltip="When on, heatmap bands use the current Theme Preset's neutral color. Turn off to pick a dedicated Heatmap Color below instead.")
heatmapColorCustom = input.color(color.new(color.blue, 0), "Heatmap Color (Custom)", group=grpHeat, tooltip="Only applied when Use Theme Color for Heatmap is off.")

// =====================================================================================
// THEME RESOLUTION
// =====================================================================================
lightHeaderBg = color.new(color.navy, 0)
lightHeaderText = color.new(color.white, 0)
lightBullish = color.new(color.green, 0)
lightBearish = color.new(color.red, 0)
lightNeutral = color.new(color.gray, 0)

darkHeaderBg = color.new(#1A1F2E, 0)
darkHeaderText = color.new(#E0E0E0, 0)
darkBullish = color.new(#26A69A, 0)
darkBearish = color.new(#EF5350, 0)
darkNeutral = color.new(#787B86, 0)

cbBullish = color.new(#0072B2, 0)
cbBearish = color.new(#E69F00, 0)

headerBgColor = themeMode == "Custom" ? headerBgColorCustom : themeMode == "Dark" ? darkHeaderBg : lightHeaderBg
headerTextColor = themeMode == "Custom" ? headerTextColorCustom : themeMode == "Dark" ? darkHeaderText : lightHeaderText
neutralColor = themeMode == "Dark" ? darkNeutral : lightNeutral
baseBullishColor = themeMode == "Custom" ? bullishColorCustom : themeMode == "Dark" ? darkBullish : lightBullish
baseBearishColor = themeMode == "Custom" ? bearishColorCustom : themeMode == "Dark" ? darkBearish : lightBearish
zoneColor = colorblindMode ? cbBullish : baseBullishColor
alertHighlightColor = colorblindMode ? cbBearish : baseBearishColor

var color[] rankColors = array.new<color>(0)
if array.size(rankColors) == 0
    array.push(rankColors, zone1ColorCustom)
    array.push(rankColors, zone2ColorCustom)
    array.push(rankColors, zone3ColorCustom)
    array.push(rankColors, zone4ColorCustom)
    array.push(rankColors, zone5ColorCustom)

// =====================================================================================
// DENSITY ARRAY / ANCHOR STATE
// =====================================================================================
arrSize = 2 * maxBinsEachSide + 1

var array<float> density = array.new_float(arrSize, 0.0)
var array<int> lastTouchBar = array.new_int(arrSize, -1)
var float anchorPrice = na
var float binSize = na

atrForBin = ta.atr(atrLenForBin)
binSizeCandidate = binSizeMode == "Manual" ? manualBinSize : atrForBin * atrMultForBin

f_binIdx(_price) =>
    int(math.max(0, math.min(arrSize - 1, math.round(maxBinsEachSide + (_price - anchorPrice) / binSize))))

f_binPrice(_idx) =>
    anchorPrice + (_idx - maxBinsEachSide) * binSize

f_volMult(_pivVol, _avgVol) =>
    not enableVolumeWeighting or na(_avgVol) or _avgVol <= 0 or na(_pivVol) ? 1.0 : math.min(volWeightCap, _pivVol / _avgVol)

avgVolForWeight = ta.sma(volume, volAvgLen)

rawIdxNow = na(anchorPrice) or na(binSize) or binSize <= 0 ? na : maxBinsEachSide + (close - anchorPrice) / binSize
outOfBounds = na(rawIdxNow) or rawIdxNow < 0 or rawIdxNow > arrSize - 1
periodicReanchor = bar_index % reanchorIntervalBars == 0
reanchorNeeded = na(anchorPrice) or outOfBounds or periodicReanchor

var array<int> touchCount = array.new_int(arrSize, 0)
var array<bool> wasInsideBin = array.new_bool(arrSize, false)

if reanchorNeeded
    density := array.new_float(arrSize, 0.0)
    lastTouchBar := array.new_int(arrSize, -1)
    touchCount := array.new_int(arrSize, 0)
    wasInsideBin := array.new_bool(arrSize, false)
    anchorPrice := close
    binSize := binSizeCandidate

// Per-bar decay (applied every bar, including a just-reset bar - harmless, 0 * decay = 0)
for i = 0 to arrSize - 1
    array.set(density, i, array.get(density, i) * decayRate)

// Confirmed pivots at each scale (na unless a pivot just confirmed this bar)
pivHighShort = ta.pivothigh(high, pivotLenShort, pivotLenShort)
pivLowShort = ta.pivotlow(low, pivotLenShort, pivotLenShort)
pivHighMedium = ta.pivothigh(high, pivotLenMedium, pivotLenMedium)
pivLowMedium = ta.pivotlow(low, pivotLenMedium, pivotLenMedium)
pivHighLong = ta.pivothigh(high, pivotLenLong, pivotLenLong)
pivLowLong = ta.pivotlow(low, pivotLenLong, pivotLenLong)

if not na(pivHighShort)
    idxHS = f_binIdx(pivHighShort)
    volMultHS = f_volMult(volume[pivotLenShort], avgVolForWeight)
    array.set(density, idxHS, array.get(density, idxHS) + weightShort * volMultHS)
    array.set(lastTouchBar, idxHS, bar_index)
if not na(pivLowShort)
    idxLS = f_binIdx(pivLowShort)
    volMultLS = f_volMult(volume[pivotLenShort], avgVolForWeight)
    array.set(density, idxLS, array.get(density, idxLS) + weightShort * volMultLS)
    array.set(lastTouchBar, idxLS, bar_index)
if not na(pivHighMedium)
    idxHM = f_binIdx(pivHighMedium)
    volMultHM = f_volMult(volume[pivotLenMedium], avgVolForWeight)
    array.set(density, idxHM, array.get(density, idxHM) + weightMedium * volMultHM)
    array.set(lastTouchBar, idxHM, bar_index)
if not na(pivLowMedium)
    idxLM = f_binIdx(pivLowMedium)
    volMultLM = f_volMult(volume[pivotLenMedium], avgVolForWeight)
    array.set(density, idxLM, array.get(density, idxLM) + weightMedium * volMultLM)
    array.set(lastTouchBar, idxLM, bar_index)
if not na(pivHighLong)
    idxHL = f_binIdx(pivHighLong)
    volMultHL = f_volMult(volume[pivotLenLong], avgVolForWeight)
    array.set(density, idxHL, array.get(density, idxHL) + weightLong * volMultHL)
    array.set(lastTouchBar, idxHL, bar_index)
if not na(pivLowLong)
    idxLL = f_binIdx(pivLowLong)
    volMultLL = f_volMult(volume[pivotLenLong], avgVolForWeight)
    array.set(density, idxLL, array.get(density, idxLL) + weightLong * volMultLL)
    array.set(lastTouchBar, idxLL, bar_index)

// =====================================================================================
// TOP-N ZONE SELECTION  (v1.1 REWRITE - working-copy selection, no separate exclusion array;
// v1.3 adds Zone Cluster Merge - nearby candidates fold into the winning bin's density;
// v1.4 adds a per-rank merge COUNT alongside the merge SUM, for the "Merged Nx" dashboard tag)
// =====================================================================================
var array<int> topIdx = array.new_int(topN, -1)
var array<float> topVal = array.new_float(topN, 0.0)
var array<int> topMergeCount = array.new_int(topN, 1)
densityScratch = array.copy(density)

for n = 0 to topN - 1
    bestIdx = -1
    bestVal = -1.0
    for i = 0 to arrSize - 1
        v = array.get(densityScratch, i)
        if v > bestVal
            bestVal := v
            bestIdx := i
    if bestIdx >= 0
        mergedVal = bestVal
        mergeCountN = 1
        array.set(densityScratch, bestIdx, -1.0)
        if enableClusterMerge and clusterMergeBins > 0
            for j = math.max(0, bestIdx - clusterMergeBins) to math.min(arrSize - 1, bestIdx + clusterMergeBins)
                vj = array.get(densityScratch, j)
                if vj > 0
                    mergedVal += vj
                    mergeCountN += 1
                    array.set(densityScratch, j, -1.0)
        array.set(topIdx, n, bestIdx)
        array.set(topVal, n, mergedVal)
        array.set(topMergeCount, n, mergeCountN)
    else
        array.set(topIdx, n, bestIdx)
        array.set(topVal, n, bestVal)
        array.set(topMergeCount, n, 1)

// =====================================================================================
// PRICE-IN-ZONE STATE (for alerts)
// =====================================================================================
tol = binSize * (zoneAlertTolerancePct / 100.0)
insideAnyZone = false
for n = 0 to topN - 1
    idx = array.get(topIdx, n)
    if idx >= 0
        qualifiesN = minTouchesToShow == 0 or array.get(touchCount, idx) >= minTouchesToShow
        zLo = f_binPrice(idx) - binSize / 2 - tol
        zHi = f_binPrice(idx) + binSize / 2 + tol
        if close >= zLo and close <= zHi
            if qualifiesN
                insideAnyZone := true
            if not array.get(wasInsideBin, idx)
                array.set(touchCount, idx, array.get(touchCount, idx) + 1)
            array.set(wasInsideBin, idx, true)
        else
            array.set(wasInsideBin, idx, false)

var bool insideAnyZonePrev = false
enteredZone = insideAnyZone and not insideAnyZonePrev
exitedZone = not insideAnyZone and insideAnyZonePrev

var int top1IdxPrev = -1
top1IdxNow = array.get(topIdx, 0)
top1Reshuffled = top1IdxNow != top1IdxPrev and top1IdxPrev != -1 and top1IdxNow != -1

insideAnyZonePrev := insideAnyZone
top1IdxPrev := top1IdxNow

// =====================================================================================
// ZONE #1 EARLY WARNING & REJECT-VS-BREAK CLASSIFICATION (NEW)
// =====================================================================================
top1Price = top1IdxNow >= 0 ? f_binPrice(top1IdxNow) : na
top1Lo = top1IdxNow >= 0 ? f_binPrice(top1IdxNow) - binSize / 2 - tol : na
top1Hi = top1IdxNow >= 0 ? f_binPrice(top1IdxNow) + binSize / 2 + tol : na
insideTop1 = top1IdxNow >= 0 and close >= top1Lo and close <= top1Hi

var bool insideTop1Prev = false
enteredTop1 = insideTop1 and not insideTop1Prev
exitedTop1 = not insideTop1 and insideTop1Prev

var float top1EntrySide = na
if top1Reshuffled
    top1EntrySide := na
if enteredTop1
    top1EntrySide := close >= top1Price ? 1.0 : -1.0

top1Qualifies = top1IdxNow >= 0 and (minTouchesToShow == 0 or array.get(touchCount, top1IdxNow) >= minTouchesToShow)

exitedTop1Classifiable = exitedTop1 and not na(top1EntrySide)
rejectTop1Raw = exitedTop1Classifiable and ((top1EntrySide > 0 and close >= top1Price) or (top1EntrySide < 0 and close <= top1Price))
rejectTop1 = rejectTop1Raw and top1Qualifies
breakTop1 = exitedTop1Classifiable and not rejectTop1Raw and top1Qualifies

approachDist = atrForBin * approachThresholdATRMult
distToTop1 = na(top1Price) ? na : math.abs(close - top1Price)
approachingTop1 = not na(distToTop1) and not insideTop1 and distToTop1 <= approachDist and top1Qualifies

insideTop1Prev := insideTop1

// =====================================================================================
// ALL-ZONE AGGREGATE TRACKING (NEW - extends Early-Warning/Reject-vs-Break beyond Zone #1)
// =====================================================================================
var array<bool> zoneInsidePrev = array.new_bool(topN, false)
var array<float> zoneEntrySide = array.new_float(topN, na)
var array<int> zoneIdxPrev = array.new_int(topN, -1)

anyZoneApproaching = false
anyZoneRejected = false
anyZoneBroken = false

for n = 0 to topN - 1
    idxZ = array.get(topIdx, n)
    idxZPrev = array.get(zoneIdxPrev, n)
    if idxZ != idxZPrev
        array.set(zoneEntrySide, n, na)
    if idxZ >= 0
        qualifiesZ = minTouchesToShow == 0 or array.get(touchCount, idxZ) >= minTouchesToShow
        zPriceZ = f_binPrice(idxZ)
        zLoZ = zPriceZ - binSize / 2 - tol
        zHiZ = zPriceZ + binSize / 2 + tol
        insideZ = close >= zLoZ and close <= zHiZ
        wasInsideZ = array.get(zoneInsidePrev, n)
        enteredZ = insideZ and not wasInsideZ
        exitedZ = not insideZ and wasInsideZ
        if enteredZ
            array.set(zoneEntrySide, n, close >= zPriceZ ? 1.0 : -1.0)
        entrySideZ = array.get(zoneEntrySide, n)
        if qualifiesZ and exitedZ and not na(entrySideZ)
            rejZ = (entrySideZ > 0 and close >= zPriceZ) or (entrySideZ < 0 and close <= zPriceZ)
            if rejZ
                anyZoneRejected := true
            else
                anyZoneBroken := true
        distZ = math.abs(close - zPriceZ)
        if qualifiesZ and not insideZ and distZ <= approachDist
            anyZoneApproaching := true
        array.set(zoneInsidePrev, n, insideZ)
        array.set(zoneIdxPrev, n, idxZ)
    else
        array.set(zoneInsidePrev, n, false)
        array.set(zoneIdxPrev, n, idxZ)

// =====================================================================================
// MULTI-TIMEFRAME CONFLUENCE (NEW - simplified HTF swing comparison, see Honest Scope)
// =====================================================================================
htfPivHighRaw = request.security(syminfo.tickerid, htfTF, ta.pivothigh(high, htfPivLen, htfPivLen))
htfPivLowRaw = request.security(syminfo.tickerid, htfTF, ta.pivotlow(low, htfPivLen, htfPivLen))

var float htfLastPivHigh = na
var float htfLastPivLow = na
if not na(htfPivHighRaw)
    htfLastPivHigh := htfPivHighRaw
if not na(htfPivLowRaw)
    htfLastPivLow := htfPivLowRaw

htfAlignTol = close * (htfAlignTolerancePct / 100.0)
htfAlignedHigh = enableHtfDensity and not na(htfLastPivHigh) and not na(top1Price) and math.abs(top1Price - htfLastPivHigh) <= htfAlignTol
htfAlignedLow = enableHtfDensity and not na(htfLastPivLow) and not na(top1Price) and math.abs(top1Price - htfLastPivLow) <= htfAlignTol
htfAligned = htfAlignedHigh or htfAlignedLow

// =====================================================================================
// NEAREST ZONE TO PRICE (NEW - independent of density rank; whichever tracked Top-N zone is
// physically closest to price RIGHT NOW, since the #1-by-density zone is not always the one
// most immediately relevant to current price action)
// =====================================================================================
nearestZoneRank = -1
nearestZoneIdx = -1
nearestZoneDist = -1.0
for n = 0 to topN - 1
    idxNZ = array.get(topIdx, n)
    if idxNZ >= 0
        distNZ = math.abs(close - f_binPrice(idxNZ))
        if nearestZoneDist < 0 or distNZ < nearestZoneDist
            nearestZoneDist := distNZ
            nearestZoneIdx := idxNZ
            nearestZoneRank := n

// =====================================================================================
// VISUALS - zone lines drawn/updated only at the most recent bar
// =====================================================================================
zoneLineStyleConst = zoneLineStyleIn == "Dashed" ? line.style_dashed : zoneLineStyleIn == "Dotted" ? line.style_dotted : line.style_solid

zoneLabelSizeConst = zoneLabelSizeIn == "Tiny" ? size.tiny : zoneLabelSizeIn == "Small" ? size.small : zoneLabelSizeIn == "Large" ? size.large : zoneLabelSizeIn == "Huge" ? size.huge : size.normal

var line[] zoneLines = array.new<line>(0)
if array.size(zoneLines) == 0 and showZoneLines
    for n = 0 to topN - 1
        array.push(zoneLines, line.new(bar_index, na, bar_index, na, extend=extend.right, color=zoneColor, width=zoneLineWidth, style=zoneLineStyleConst))

var label[] zoneLabels = array.new<label>(0)
if array.size(zoneLabels) == 0 and showZoneLabels
    for n = 0 to topN - 1
        array.push(zoneLabels, label.new(bar_index, na, "", style=label.style_label_left, size=zoneLabelSizeConst))

if (showZoneLines or showZoneLabels) and barstate.islast
    for n = 0 to topN - 1
        idx = array.get(topIdx, n)
        zoneQualifies = idx >= 0 and (minTouchesToShow == 0 or array.get(touchCount, idx) >= minTouchesToShow)
        rankColor = useRankColors ? array.get(rankColors, n) : color.new(zoneColor, n == 0 ? 0 : 35)
        if showZoneLines
            ln = array.get(zoneLines, n)
            if zoneQualifies
                zPrice = f_binPrice(idx)
                line.set_xy1(ln, bar_index - 200, zPrice)
                line.set_xy2(ln, bar_index, zPrice)
                line.set_color(ln, rankColor)
                line.set_width(ln, zoneLineWidth)
                line.set_style(ln, zoneLineStyleConst)
            else
                line.set_color(ln, color.new(color.gray, 100))
        if showZoneLabels
            lb = array.get(zoneLabels, n)
            if zoneQualifies
                zPriceLb = f_binPrice(idx)
                label.set_xy(lb, bar_index + 3, zPriceLb)
                label.set_text(lb, "#" + str.tostring(n + 1) + "  " + str.tostring(zPriceLb, "#.##"))
                label.set_color(lb, rankColor)
                label.set_textcolor(lb, color.white)
                label.set_size(lb, zoneLabelSizeConst)
            else
                label.set_text(lb, "")

var box[] heatBoxes = array.new<box>(0)
var array<int> heatIdx = array.new_int(0)
var array<float> heatVal = array.new_float(0)
if showHeatmap and array.size(heatBoxes) == 0
    for b = 0 to heatmapMaxBands - 1
        array.push(heatBoxes, box.new(bar_index, na, bar_index, na, border_color=color.new(color.gray, 100), bgcolor=color.new(color.gray, 100)))

if showHeatmap and barstate.islast
    heatScratch = array.copy(density)
    heatIdx := array.new_int(0)
    heatVal := array.new_float(0)
    for h = 0 to heatmapMaxBands - 1
        bestIdxH = -1
        bestValH = -1.0
        for i = 0 to arrSize - 1
            vH = array.get(heatScratch, i)
            if vH > bestValH
                bestValH := vH
                bestIdxH := i
        if bestIdxH >= 0 and bestValH >= heatmapMinDensity
            array.push(heatIdx, bestIdxH)
            array.push(heatVal, bestValH)
            array.set(heatScratch, bestIdxH, -1.0)
    maxHeatV = array.size(heatVal) > 0 ? array.max(heatVal) : 0.0
    heatBaseColor = heatmapUseThemeColor ? neutralColor : heatmapColorCustom
    for b = 0 to heatmapMaxBands - 1
        bx = array.get(heatBoxes, b)
        if b < array.size(heatIdx)
            idxB = array.get(heatIdx, b)
            vB = array.get(heatVal, b)
            pxLo = f_binPrice(idxB) - binSize / 2
            pxHi = f_binPrice(idxB) + binSize / 2
            intensity = maxHeatV > 0 ? vB / maxHeatV : 0.0
            transp = int(math.max(40, 90 - intensity * 50))
            box.set_lefttop(bx, bar_index - 200, pxHi)
            box.set_rightbottom(bx, bar_index, pxLo)
            box.set_bgcolor(bx, color.new(heatBaseColor, transp))
            box.set_border_color(bx, color.new(heatBaseColor, transp))
        else
            box.set_bgcolor(bx, color.new(color.gray, 100))
            box.set_border_color(bx, color.new(color.gray, 100))

// =====================================================================================
// DASHBOARD TABLE
// =====================================================================================
tablePosConst = tablePosIn == "Top Left" ? position.top_left : tablePosIn == "Top Right" ? position.top_right : tablePosIn == "Bottom Left" ? position.bottom_left : position.bottom_right
tableSizeConst = tableSizeIn == "Tiny" ? size.tiny : tableSizeIn == "Small" ? size.small : tableSizeIn == "Large" ? size.large : tableSizeIn == "Huge" ? size.huge : size.normal

var table dash = table.new(tablePosConst, 2, topN + 6, border_width=tableBorderWidthIn, border_color=tableBorderColorCustom, frame_width=tableBorderWidthIn, frame_color=tableBorderColorCustom)

f_cell(_col, _row, _txt, _bg, _txtcol) =>
    table.cell(dash, _col, _row, _txt, bgcolor=_bg, text_color=_txtcol, text_size=tableSizeConst)

if showTable and barstate.islast
    f_cell(0, 0, "MYND Fractal S/R v1.4", headerBgColor, headerTextColor)
    f_cell(1, 0, "Density Map", headerBgColor, headerTextColor)

    for n = 0 to topN - 1
        idx = array.get(topIdx, n)
        zoneQualifiesRow = idx >= 0 and (minTouchesToShow == 0 or array.get(touchCount, idx) >= minTouchesToShow)
        ageBars = idx < 0 ? -1 : array.get(lastTouchBar, idx) < 0 ? -1 : bar_index - array.get(lastTouchBar, idx)
        ageTxt = ageBars >= 0 ? str.tostring(ageBars) + "b ago" : "n/a"
        mergeCountRow = idx < 0 ? 1 : array.get(topMergeCount, n)
        mergeTxt = mergeCountRow > 1 ? ", merged " + str.tostring(mergeCountRow) + "x" : ""
        zTxt = idx < 0 ? "N/A" : not zoneQualifiesRow ? "Below touch threshold" : str.tostring(f_binPrice(idx), "#.####") + "  (d " + str.tostring(array.get(topVal, n), "#.#") + ", " + ageTxt + mergeTxt + ")"
        rowColor = useRankColors ? color.new(array.get(rankColors, n), n == 0 ? 75 : 90) : color.new(n == 0 ? alertHighlightColor : color.gray, n == 0 ? 75 : 90)
        f_cell(0, 1 + n, "Zone #" + str.tostring(n + 1), color.new(color.gray, 85), color.black)
        f_cell(1, 1 + n, zTxt, zoneQualifiesRow ? rowColor : color.new(color.gray, 92), zoneQualifiesRow and n == 0 ? color.white : color.black)

    touch1Txt = top1IdxNow >= 0 ? str.tostring(array.get(touchCount, top1IdxNow)) : "n/a"
    f_cell(0, 1 + topN, "Zone #1 Touches", color.new(color.gray, 85), color.black)
    f_cell(1, 1 + topN, touch1Txt, color.new(color.gray, 90), color.black)

    dist1Txt = na(distToTop1) ? "n/a" : atrForBin > 0 ? str.tostring(distToTop1, "#.####") + "  (" + str.tostring(distToTop1 / atrForBin, "#.##") + "x ATR)" : str.tostring(distToTop1, "#.####")
    f_cell(0, 2 + topN, "Distance to #1 Zone", color.new(color.gray, 85), color.black)
    f_cell(1, 2 + topN, dist1Txt, color.new(color.gray, 90), color.black)

    nearestTxt = nearestZoneIdx < 0 ? "N/A" : "Zone #" + str.tostring(nearestZoneRank + 1) + "  " + str.tostring(f_binPrice(nearestZoneIdx), "#.####") + "  (" + str.tostring(nearestZoneDist, "#.####") + " away)"
    f_cell(0, 3 + topN, "Nearest Zone to Price", color.new(color.gray, 85), color.black)
    f_cell(1, 3 + topN, nearestTxt, color.new(color.gray, 90), color.black)

    htfTxt = not enableHtfDensity ? "Off" : htfAligned ? "Aligned" : "Not Aligned"
    f_cell(0, 4 + topN, "HTF Confluence", color.new(color.gray, 85), color.black)
    f_cell(1, 4 + topN, htfTxt, color.new(htfAligned ? alertHighlightColor : color.gray, htfAligned ? 75 : 90), htfAligned ? color.white : color.black)

    f_cell(0, 5 + topN, "Framing", color.new(color.gray, 85), color.black)
    f_cell(1, 5 + topN, "Density is a proxy for level significance, not a hold guarantee - see Honest Scope", color.new(color.gray, 92), color.black)

// =====================================================================================
// CROSS-TOOL SIGNAL EXPORT (v1.1: Top Zone; v1.3 adds Zones #2-#5, distance-to-#1-zone;
// v1.4's new merge-count/nearest-zone data is dashboard-only, not exported - see change log)
// =====================================================================================
plot(enableSignalExport and top1IdxNow >= 0 ? top1Price : na, title="Export: Top Zone Price", display=display.none)
plot(enableSignalExport and top1IdxNow >= 0 ? array.get(topVal, 0) : na, title="Export: Top Zone Density", display=display.none)
plot(enableSignalExport and enteredZone ? 1 : na, title="Export: Entered Zone Event", display=display.none)
plot(enableSignalExport and exitedZone ? 1 : na, title="Export: Exited Zone Event", display=display.none)
plot(enableSignalExport and top1Reshuffled ? 1 : na, title="Export: Top Zone Reshuffled Event", display=display.none)
plot(enableSignalExport and not na(distToTop1) ? distToTop1 : na, title="Export: Distance to Top Zone (price units)", display=display.none)
plot(enableSignalExport and not na(distToTop1) and atrForBin > 0 ? distToTop1 / atrForBin : na, title="Export: Distance to Top Zone (x ATR)", display=display.none)

zone2Idx = topN >= 2 ? array.get(topIdx, 1) : -1
zone3Idx = topN >= 3 ? array.get(topIdx, 2) : -1
zone4Idx = topN >= 4 ? array.get(topIdx, 3) : -1
zone5Idx = topN >= 5 ? array.get(topIdx, 4) : -1
plot(enableSignalExport and zone2Idx >= 0 ? f_binPrice(zone2Idx) : na, title="Export: Zone #2 Price", display=display.none)
plot(enableSignalExport and zone2Idx >= 0 ? array.get(topVal, 1) : na, title="Export: Zone #2 Density", display=display.none)
plot(enableSignalExport and zone3Idx >= 0 ? f_binPrice(zone3Idx) : na, title="Export: Zone #3 Price", display=display.none)
plot(enableSignalExport and zone3Idx >= 0 ? array.get(topVal, 2) : na, title="Export: Zone #3 Density", display=display.none)
plot(enableSignalExport and zone4Idx >= 0 ? f_binPrice(zone4Idx) : na, title="Export: Zone #4 Price", display=display.none)
plot(enableSignalExport and zone4Idx >= 0 ? array.get(topVal, 3) : na, title="Export: Zone #4 Density", display=display.none)
plot(enableSignalExport and zone5Idx >= 0 ? f_binPrice(zone5Idx) : na, title="Export: Zone #5 Price", display=display.none)
plot(enableSignalExport and zone5Idx >= 0 ? array.get(topVal, 4) : na, title="Export: Zone #5 Density", display=display.none)

// =====================================================================================
// ALERTS
// =====================================================================================
alertcondition(enteredZone, title="Price Entered Top-N Zone", message="MYND Fractal S/R: price ENTERED a top-density zone on {{ticker}} ({{interval}}) at {{close}}.")
alertcondition(exitedZone, title="Price Exited All Top-N Zones", message="MYND Fractal S/R: price EXITED all top-density zones on {{ticker}} ({{interval}}) at {{close}}.")
alertcondition(top1Reshuffled, title="Top Zone Reshuffled", message="MYND Fractal S/R: the #1 highest-density zone changed on {{ticker}} ({{interval}}) - a new dominant level has emerged.")
alertcondition(approachingTop1, title="Price Approaching #1 Zone", message="MYND Fractal S/R: price is approaching the #1 zone on {{ticker}} ({{interval}}) at {{close}} - not yet inside it.")
alertcondition(rejectTop1, title="Zone #1 Rejected (Bounce)", message="MYND Fractal S/R: price entered the #1 zone on {{ticker}} ({{interval}}) and bounced back out the same side - a rejection.")
alertcondition(breakTop1, title="Zone #1 Broken Through", message="MYND Fractal S/R: price entered the #1 zone on {{ticker}} ({{interval}}) and closed out the opposite side - a break-through.")
alertcondition(anyZoneApproaching, title="Any Zone Approaching (All Top-N)", message="MYND Fractal S/R: price is approaching a Top-N zone on {{ticker}} ({{interval}}) at {{close}} - not yet inside it.")
alertcondition(anyZoneRejected, title="Any Zone Rejected (All Top-N)", message="MYND Fractal S/R: price entered a Top-N zone on {{ticker}} ({{interval}}) and bounced back out the same side - a rejection.")
alertcondition(anyZoneBroken, title="Any Zone Broken Through (All Top-N)", message="MYND Fractal S/R: price entered a Top-N zone on {{ticker}} ({{interval}}) and closed out the opposite side - a break-through.")
alertcondition(htfAligned, title="Zone #1 Aligned with HTF Level", message="MYND Fractal S/R: the #1 zone on {{ticker}} ({{interval}}) lines up with a recent HTF swing level.")

comboAllSignals = enteredZone or exitedZone or top1Reshuffled or approachingTop1 or rejectTop1 or breakTop1 or anyZoneApproaching or anyZoneRejected or anyZoneBroken or htfAligned
alertcondition(comboAllSignals, title="ALL Fractal S/R Signals (combo)", message="MYND Fractal S/R: a zone entry/exit, reshuffle, approach, reject/break, or HTF confluence signal fired - check the chart/dashboard for detail.")

// This tool is provided for informational and educational purposes and does not
// constitute financial advice. Trading involves risk; past performance and historical
// patterns do not guarantee future results.
````
