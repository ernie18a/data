# Percentile Stretch Bands [AGPro Series]

- url: https://www.tradingview.com/script/KLPt3Hrt-Percentile-Stretch-Bands-AGPro-Series/
- type: indicator
- pine_id: PUB;787acb117d4f427791dcec46361c2490
- version: 3.0

## Description

Percentile Stretch Bands [AGPro Series]

🔹 OVERVIEW

Percentile Stretch Bands is an empirical, distribution-free overextension map. Instead of plotting standard deviation envelopes that assume a normal distribution of price behavior, this indicator samples the actual historical distance between price and a chosen reference (EMA, VWAP, or Anchored VWAP) and draws context-specific Stretch and Extreme bands directly from the empirical percentile distribution. The result is a visual reference of how stretched price is relative to its own historical behavior, adapted to the asset and timeframe being viewed.


🔹 UNIQUE EDGE

Most "stretch" or "volatility band" tools on the platform rely on parametric assumptions — standard deviation multipliers, ATR multiples, or fixed percentage offsets. These approaches collapse when the underlying return distribution is skewed, fat-tailed, or regime-dependent, which is the rule rather than the exception across crypto and FX assets.

Percentile Stretch Bands takes a different path:

• Distribution-free: bands are drawn from the actual empirical percentile of price-to-reference distance, not from a Gaussian assumption.
• Side-specific sampling: upper and lower distances are collected into separate samples, so asymmetric behavior (trending markets, one-sided regimes) is preserved rather than averaged away.
• Regime-aware rendering: when Focus Active Side is enabled, each bar displays only the side relevant to price position, producing a clean single-story chart without visual competition.
• Readiness gating: bands appear only once a minimum number of observations is reached on the active side, with the status panel clearly indicating the collection stage.


🔹 METHODOLOGY

For every bar in the configured lookback window, the signed percent distance between close and the selected reference is computed and partitioned into two historical samples: positive distances (upper extensions) and negative distances in absolute terms (lower extensions).

Each sample is sorted and two percentile cut-offs are extracted independently:

• Stretch percentile (default 80) — the threshold beyond which a distance is considered materially extended.
• Extreme percentile (default 95) — the threshold beyond which a distance is statistically rare within the chosen lookback.

These cut-offs are then translated from percent-distance back into absolute price bands around the active reference, producing four levels: Upper Stretch, Upper Extreme, Lower Stretch, Lower Extreme. The current distance is also ranked against its side's sample and displayed as an ordinal percentile (for example, "Upper P87") in the status panel.


🔹 SIGNALS AND ALERTS

The indicator is a visual overextension map and does not generate directional trade signals. Four alert conditions are exposed for users who want to be notified of boundary events:

• Upper Stretch Cross — close crosses above the Upper Stretch band.
• Upper Extreme Cross — close crosses above the Upper Extreme band.
• Lower Stretch Cross — close crosses below the Lower Stretch band.
• Lower Extreme Cross — close crosses below the Lower Extreme band.

These alerts mark entries into statistically extended zones relative to the empirical sample. They are contextual flags, not trade recommendations.


🔹 KEY INPUTS

Reference
• Reference Mode — EMA, VWAP, or Anchored VWAP baseline
• EMA Length — smoothing length for the EMA reference
• AVWAP Anchor Time — starting timestamp for Anchored VWAP

Statistics
• Lookback — bars used to build the empirical distribution (default 500)
• Minimum Side Sample — observations required before bands appear
• Stretch Percentile — primary extension threshold (default 80)
• Extreme Percentile — rare-extension threshold (default 95)

Display
• Focus Active Side — regime-aware single-story rendering
• Show Active Stretch Zone Box — right-side zone anchor on the active side
• Zone Forward Projection — forward visibility of the active zone
• Band Color Profile — Soft, Premium, or Bold
• Panel Text Size and Label Text Size — Small, Normal, or Large

Level Tags
• Show Level Tags, Show Reference Tag, Tag Mode, Tag Offset Bars


🔹 HOW TO USE

1. Select a reference that fits the asset and timeframe. EMA is a robust default across all instruments. VWAP is suited to intraday equities and futures. Anchored VWAP is used when a specific event origin (earnings, news, structural low) is relevant.

2. Let the status panel reach the "Ready" state. The panel reports active samples and readiness — bands are intentionally withheld until the side-specific sample is sufficient.

3. Read the current percentile rank in the Zone cell. Values near the center indicate price trading close to the reference; values approaching P95 or above indicate the sample's rare extensions.

4. Treat Stretch and Extreme bands as context, not as triggers. A move into the Extreme zone reflects a statistically rare extension on the chosen sample, not a directional signal.

5. Combine with structural tools — trend context, market structure, higher-timeframe bias — before any discretionary decision.


🔹 LIMITATIONS AND TRANSPARENCY

• The indicator is descriptive, not predictive. Percentile bands describe past behavior within the lookback window; they do not forecast future price action.
• Regime shifts can temporarily invalidate historical bands. A sudden volatility expansion will push price beyond extreme levels while the sample re-stabilizes.
• Empirical percentiles require sufficient observations. On very new symbols or short lookbacks, the "Collecting" state is the correct and expected behavior.
• Anchored VWAP mode depends on a meaningful anchor choice. A poorly chosen anchor produces a reference line without structural relevance.
• The active stretch zone box is a visual anchor for screenshots and review, not a projection of future levels.


🔹 RISK DISCLOSURE

This script is a visual analytics tool and is not a strategy, signal service, or financial advice. It does not place orders, manage positions, or recommend directional exposure. Trading involves risk of loss. Users are responsible for their own analysis, risk management, and trading decisions.

## Source Code

````pine
// -----------------------------------------------------
// Percentile Stretch Bands [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.2
//
// Empirical percentile envelopes around a user-selected reference such as
// EMA, VWAP, or Anchored VWAP. The indicator samples the distribution of
// price-to-reference distance, plots Stretch and Extreme bands on the active
// side of price, highlights the current stretch zone with a projected box and
// centered badge, and reports a stop-aware Stretch Reversion Rate plus a clear
// action read inside a compact AGPro status panel.
// -----------------------------------------------------

//@version=6
indicator("Percentile Stretch Bands [AGPro Series]",
     shorttitle       = "AG Pro PSB",
     overlay          = true,
     max_bars_back    = 5000,
     max_labels_count = 120,
     max_boxes_count  = 50)

// -----------------------------------------------------
// Inputs
// -----------------------------------------------------
groupRef   = "Reference"
groupStats = "Statistics"
groupDisp  = "Display"
groupTags  = "Level Tags"
groupPanel = "Panel"

refMode = input.string("EMA", "Reference Mode",
     options = ["EMA", "VWAP", "Anchored VWAP"],
     group   = groupRef,
     tooltip = "Baseline used to measure price extension. EMA is smooth and continuous, VWAP is session-weighted, and Anchored VWAP starts from the selected timestamp.")

emaLen = input.int(50, "EMA Length",
     minval  = 1,
     maxval  = 500,
     group   = groupRef,
     tooltip = "Smoothing length for the EMA reference. Larger values create a slower baseline and wider stretch tolerance.")

emaSrc = input.source(close, "EMA Source",
     group   = groupRef,
     tooltip = "Input series used in the EMA calculation. Close is the standard default for a stable reference.")

vwapSrc = input.source(hlc3, "VWAP / AVWAP Source",
     group   = groupRef,
     tooltip = "Price source used for VWAP and Anchored VWAP. HLC3 is balanced; close is more reactive.")

anchorTs = input.time(timestamp("01 Jan 2026 00:00 +0000"), "AVWAP Anchor Time",
     group   = groupRef,
     tooltip = "Starting timestamp for the Anchored VWAP. Used only when Reference Mode is set to Anchored VWAP.")

lookback = input.int(500, "Lookback",
     minval  = 100,
     maxval  = 3000,
     group   = groupStats,
     tooltip = "Number of historical bars used to build the empirical distance distribution. Larger values increase stability but respond more slowly.")

minSample = input.int(40, "Minimum Side Sample",
     minval  = 10,
     maxval  = 500,
     group   = groupStats,
     tooltip = "Minimum observations required on the active side of the distribution before percentile bands are displayed.")

pStretchI = input.float(80.0, "Stretch Percentile",
     minval  = 50.0,
     maxval  = 99.0,
     step    = 0.5,
     group   = groupStats,
     tooltip = "Threshold for the Stretch band. Distances above this percentile are treated as materially extended relative to the selected reference.")

pExtremeI = input.float(95.0, "Extreme Percentile",
     minval  = 80.0,
     maxval  = 99.5,
     step    = 0.5,
     group   = groupStats,
     tooltip = "Threshold for the Extreme band. Distances beyond this percentile are classified as unusually stretched inside the selected sample.")

reversionWindow = input.int(40, "Reversion Proof Window",
     minval  = 8,
     maxval  = 300,
     group   = groupStats,
     tooltip = "Bars allowed for a Stretch-band touch to either revert toward the reference (counts) or extend to the Extreme band (counts as a miss) before the sample times out uncounted. Used by the Stretch Reversion Rate.")

showFills = input.bool(true, "Show Stretch Fills",
     group   = groupDisp,
     tooltip = "Fills the area between Stretch and Extreme to highlight the primary extension zone.")

focusActiveSide = input.bool(true, "Focus Active Side",
     group   = groupDisp,
     tooltip = "When enabled, only the side of price currently above or below the reference is emphasized for a cleaner single-story chart.")

passiveSideFade = input.string("Strong", "Passive Side Fade",
     options = ["Off", "Soft", "Strong"],
     group   = groupDisp,
     tooltip = "Visual attenuation applied to the non-active side when Focus Active Side is off.")

showActiveZoneBox = input.bool(true, "Show Active Stretch Zone Box",
     group   = groupDisp,
     tooltip = "Draws a right-side zone between Stretch and Extreme on the active side.")

zoneBoxBars = input.int(110, "Active Zone Width (Bars)",
     minval  = 20,
     maxval  = 300,
     group   = groupDisp,
     tooltip = "Horizontal width of the active stretch zone box in bars.")

zoneProjectBars = input.int(25, "Zone Forward Projection (Bars)",
     minval  = 5,
     maxval  = 100,
     group   = groupDisp,
     tooltip = "Number of bars projected to the right of the last bar for the active stretch zone box.")

showZoneBadge = input.bool(true, "Show Active Zone Badge",
     group   = groupDisp,
     tooltip = "Places a separate centered badge inside the active stretch zone so the projected zone has clear ownership without using embedded box text.")

zoneBadgeAnchor = input.float(0.62, "Zone Badge Anchor",
     minval = 0.10,
     maxval = 0.90,
     step = 0.01,
     group = groupDisp,
     tooltip = "Horizontal placement of the active zone badge inside the stretch zone box. Lower values sit toward the left (older) side of the zone; higher values move toward the current bar.")

bandColorProfile = input.string("Premium", "Band Color Profile",
     options = ["Soft", "Premium", "Bold"],
     group   = groupDisp,
     tooltip = "Band saturation and fill opacity. Premium is the balanced publication default.")

lineWRef = input.int(2, "Reference Line Width",
     minval  = 1,
     maxval  = 4,
     group   = groupDisp,
     tooltip = "Thickness of the central reference line.")

lineWBands = input.int(1, "Band Line Width",
     minval  = 1,
     maxval  = 3,
     group   = groupDisp,
     tooltip = "Thickness of the percentile band lines.")

showLevelTags = input.bool(true, "Show Level Tags",
     group   = groupTags,
     tooltip = "Compact right-side guide tags for Stretch and Extreme bands and the reference line.")

showRefTag = input.bool(true, "Show Reference Tag",
     group   = groupTags,
     tooltip = "Keeps the current reference visible as a compact guide label on the right side.")

tagMode = input.string("Active Side", "Tag Mode",
     options = ["Active Side", "Both Sides"],
     group   = groupTags,
     tooltip = "Active Side labels only the relevant side of price. Both Sides labels upper and lower Stretch / Extreme levels together.")

tagOffsetBars = input.int(3, "Tag Offset Bars",
     minval  = 1,
     maxval  = 20,
     group   = groupTags,
     tooltip = "Horizontal offset of guide tags to the right of the latest bar.")

labelTextSizeStr = input.string("Normal", "Label Font Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group   = groupTags,
     tooltip = "Text size used for right-side tags and active-zone badges.")

showInfo = input.bool(true, "Show Panel",
     group   = groupPanel,
     tooltip = "Shows or hides the AGPro status panel.")

boxPos = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"],
     group   = groupPanel,
     tooltip = "Location where the status panel is rendered.")

panelThemeInput = input.string("Elite Dark", "Panel Theme",
     options = ["Elite Dark", "Slate", "Clean Light"],
     group = groupPanel,
     tooltip = "Visual theme for the panel. Elite Dark is the AGPro default, Slate is softer, and Clean Light is designed for bright chart backgrounds.")

panelTextSizeStr = input.string("Normal", "Panel Font Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group   = groupPanel,
     tooltip = "Text size used inside the status panel. Normal is the standard AGPro presentation size.")

// -----------------------------------------------------
// AGPro Color Palette
// -----------------------------------------------------
headerBg       = color.rgb(37, 99, 235)
headerText     = color.rgb(245, 247, 250)
panelBorder    = color.rgb(51, 65, 85)
panelLabelCol  = color.rgb(148, 163, 184)
panelValueCol  = color.rgb(226, 232, 240)
bullColor      = color.rgb(34, 197, 166)
bearColor      = color.rgb(244, 114, 182)
neutralColor   = color.rgb(245, 189, 92)
accentColor    = color.rgb(129, 140, 248)
inkDark        = color.rgb(15, 23, 42)
inkLight       = color.rgb(245, 247, 250)

// -----------------------------------------------------
// Helpers
// -----------------------------------------------------
// Luminance-aware text color: dark ink on light fills, light ink on dark fills.
f_text_on(color bg) =>
    float r = color.r(bg)
    float g = color.g(bg)
    float b = color.b(bg)
    float lum = 0.299 * r + 0.587 * g + 0.114 * b
    lum > 145 ? inkDark : inkLight

f_clamp(_v, _min, _max) =>
    math.max(_min, math.min(_max, _v))

f_percentile_sorted(_sorted, _pct) =>
    float _out = na
    int _n = array.size(_sorted)
    if _n > 0
        if _n == 1
            _out := array.get(_sorted, 0)
        else
            float _idx = (_pct / 100.0) * (_n - 1)
            int _lo = int(math.floor(_idx))
            int _hi = int(math.ceil(_idx))
            float _loVal = array.get(_sorted, _lo)
            float _hiVal = array.get(_sorted, _hi)
            _out := _lo == _hi ? _loVal : _loVal + (_idx - _lo) * (_hiVal - _loVal)
    _out

f_rank_pct(_arr, _value) =>
    float _rank = na
    int _n = array.size(_arr)
    if _n > 0
        int _countLE = 0
        for _i = 0 to _n - 1
            if array.get(_arr, _i) <= _value
                _countLE += 1
        _rank := (float(_countLE) / float(_n)) * 100.0
    _rank

f_rank_label(_prefix, _rank) =>
    na(_rank) ? _prefix : _rank < 1.0 ? _prefix + " P<1" : _prefix + " P" + str.tostring(math.round(_rank))

f_pct_to_price(_ref, _pct, _isUpper) =>
    float _band = na
    if not na(_ref) and not na(_pct) and _ref != 0
        _band := _isUpper ? _ref * (1.0 + _pct / 100.0) : _ref * (1.0 - _pct / 100.0)
    _band

f_fmt_pct(_v) =>
    na(_v) ? "n/a" : str.tostring(_v, "#.00") + "%"

f_to_size(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Small" ? size.small : _s == "Large" ? size.large : _s == "Huge" ? size.huge : size.normal

f_position(_pos) =>
    switch _pos
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.top_right

f_panel_bg() =>
    panelThemeInput == "Clean Light" ? color.rgb(248, 250, 252) : panelThemeInput == "Slate" ? color.rgb(30, 41, 59) : color.rgb(15, 23, 42)

f_panel_border() =>
    panelThemeInput == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label() =>
    panelThemeInput == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelThemeInput == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

// Tag fills carry their own opacity; text color is derived from the solid base hue.
f_make_tag(_x, _y, _txt, _bg, _base, _style, _sz) =>
    label.new(_x, _y, _txt, xloc = xloc.bar_index, style = _style, color = _bg, textcolor = f_text_on(_base), size = _sz)

f_zone_badge_text(_isUpper, _zoneText, _distStr) =>
    (_isUpper ? "UPPER STRETCH" : "LOWER STRETCH") + "\n" + _zoneText + " | " + _distStr

// -----------------------------------------------------
// Sanitized percentiles
// -----------------------------------------------------
pStretch = f_clamp(pStretchI, 50.0, 98.5)
pExtreme = f_clamp(pExtremeI, pStretch + 0.5, 99.5)

// -----------------------------------------------------
// Reference engine
// -----------------------------------------------------
emaRef  = ta.ema(emaSrc, emaLen)
vwapRef = ta.vwap(vwapSrc)

avwapNum = ta.cum(time >= anchorTs ? vwapSrc * volume : 0.0)
avwapDen = ta.cum(time >= anchorTs ? volume : 0.0)
avwapRef = avwapDen > 0 ? avwapNum / avwapDen : na

reference = switch refMode
    "EMA" => emaRef
    "VWAP" => vwapRef
    => avwapRef

refName = switch refMode
    "EMA" => "EMA " + str.tostring(emaLen)
    "VWAP" => "VWAP"
    => "AVWAP"

atrValue = ta.atr(14)
safeAtr = math.max(nz(atrValue, ta.tr(true)), syminfo.mintick)

// -----------------------------------------------------
// Signed distance in percent
// -----------------------------------------------------
distPct = not na(reference) and reference != 0 ? 100.0 * (close / reference - 1.0) : na

isUpperActive = not na(distPct) and distPct > 0
isLowerActive = not na(distPct) and distPct < 0

hideUpper = focusActiveSide and isLowerActive
hideLower = focusActiveSide and isUpperActive

passiveLineFadeAdd = passiveSideFade == "Soft" ? 10 : passiveSideFade == "Strong" ? 22 : 0
passiveFillFadeAdd = passiveSideFade == "Soft" ? 6 : passiveSideFade == "Strong" ? 12 : 0

upperLineFade = not focusActiveSide and isLowerActive ? passiveLineFadeAdd : 0
lowerLineFade = not focusActiveSide and isUpperActive ? passiveLineFadeAdd : 0
upperFillFade = not focusActiveSide and isLowerActive ? passiveFillFadeAdd : 0
lowerFillFade = not focusActiveSide and isUpperActive ? passiveFillFadeAdd : 0

// -----------------------------------------------------
// Historical side-specific samples
// -----------------------------------------------------
array<float> posSamples = array.new_float()
array<float> negSamples = array.new_float()

for i = 1 to lookback
    if i <= bar_index
        float d = distPct[i]
        if not na(d)
            if d > 0
                array.push(posSamples, d)
            else if d < 0
                array.push(negSamples, math.abs(d))

posCount = array.size(posSamples)
negCount = array.size(negSamples)

enoughPos = posCount >= minSample
enoughNeg = negCount >= minSample

// -----------------------------------------------------
// Percentile engine
// -----------------------------------------------------
array<float> posSorted = array.new_float()
array<float> negSorted = array.new_float()

if enoughPos
    posSorted := array.copy(posSamples)
    array.sort(posSorted, order.ascending)

if enoughNeg
    negSorted := array.copy(negSamples)
    array.sort(negSorted, order.ascending)

upStretch = enoughPos ? f_percentile_sorted(posSorted, pStretch) : na
upExtreme = enoughPos ? f_percentile_sorted(posSorted, pExtreme) : na

dnStretch = enoughNeg ? f_percentile_sorted(negSorted, pStretch) : na
dnExtreme = enoughNeg ? f_percentile_sorted(negSorted, pExtreme) : na

// Real band prices (independent of focus-side hiding) used by bands, zone, and proof.
upStretchPrice = f_pct_to_price(reference, upStretch, true)
upExtremePrice = f_pct_to_price(reference, upExtreme, true)
dnStretchPrice = f_pct_to_price(reference, dnStretch, false)
dnExtremePrice = f_pct_to_price(reference, dnExtreme, false)

upperStretchBand = not hideUpper ? upStretchPrice : na
upperExtremeBand = not hideUpper ? upExtremePrice : na
lowerStretchBand = not hideLower ? dnStretchPrice : na
lowerExtremeBand = not hideLower ? dnExtremePrice : na

// -----------------------------------------------------
// Classification
// -----------------------------------------------------
float currentRank = na
string zoneText   = "Collecting"

if na(reference)
    zoneText := "n/a"
else if distPct > 0
    float absDist = distPct
    currentRank := enoughPos ? f_rank_pct(posSamples, absDist) : na
    zoneText := enoughPos ? f_rank_label("Upper", currentRank) : "Upper"
else if distPct < 0
    float absDist = math.abs(distPct)
    currentRank := enoughNeg ? f_rank_pct(negSamples, absDist) : na
    zoneText := enoughNeg ? f_rank_label("Lower", currentRank) : "Lower"
else
    zoneText := "Centered"

// -----------------------------------------------------
// Stretch Reversion Rate (stop-aware, confirmed-bar gated, resolve-then-open)
// Of past Stretch-band touches, how many reverted halfway back to the reference
// before extending to the Extreme band. Cross-bar levels are frozen so a moving
// band cannot change a pending sample.
// -----------------------------------------------------
var int revWins = 0
var int revTotal = 0
var bool revPending = false
var int revDir = 0
var float revTarget = na
var float revStop = na
var int revStartBar = na

upCross = enoughPos and not na(upStretchPrice) and ta.crossover(close, upStretchPrice)
dnCross = enoughNeg and not na(dnStretchPrice) and ta.crossunder(close, dnStretchPrice)

if barstate.isconfirmed
    if revPending
        bool reverted = revDir == 1 ? low <= revTarget : high >= revTarget
        bool extended = revDir == 1 ? high >= revStop : low <= revStop
        if reverted
            revWins += 1
            revTotal += 1
            revPending := false
        else if extended
            revTotal += 1
            revPending := false
        else if not na(revStartBar) and bar_index - revStartBar >= reversionWindow
            revPending := false
    if not revPending and (upCross or dnCross) and not na(reference)
        revDir := upCross ? 1 : -1
        revTarget := upCross ? (upStretchPrice + reference) / 2.0 : (dnStretchPrice + reference) / 2.0
        revStop := upCross ? upExtremePrice : dnExtremePrice
        revStartBar := bar_index
        revPending := not na(revTarget) and not na(revStop)

int revPct = revTotal > 0 ? int(math.round(revWins / revTotal * 100.0)) : na
bool revBuilding = revTotal < 6
string revText = revBuilding ? "Building (" + str.tostring(revTotal) + ")" : str.tostring(revPct) + "% (" + str.tostring(revTotal) + ")"
color revColor = revBuilding ? neutralColor : revPct >= 55 ? bullColor : revPct >= 40 ? neutralColor : bearColor

// -----------------------------------------------------
// Styling
// -----------------------------------------------------
isSoft = bandColorProfile == "Soft"
isBold = bandColorProfile == "Bold"

upStretchBase = bearColor
upExtremeBase = bearColor
dnStretchBase = bullColor
dnExtremeBase = bullColor

upSTrans = math.min(100, (isSoft ? 78 : isBold ? 38 : 55) + upperLineFade)
upETrans = math.min(100, (isSoft ? 62 : isBold ? 14 : 26) + upperLineFade)

dnSTrans = math.min(100, (isSoft ? 78 : isBold ? 38 : 55) + lowerLineFade)
dnETrans = math.min(100, (isSoft ? 62 : isBold ? 14 : 26) + lowerLineFade)

fillUpTrans = math.min(100, (isSoft ? 94 : isBold ? 78 : 86) + upperFillFade)
fillDnTrans = math.min(100, (isSoft ? 94 : isBold ? 78 : 86) + lowerFillFade)

colRefMain = color.new(accentColor, 10)
colRefGlow = color.new(accentColor, 85)

colUpS = color.new(upStretchBase, upSTrans)
colUpE = color.new(upExtremeBase, upETrans)
colDnS = color.new(dnStretchBase, dnSTrans)
colDnE = color.new(dnExtremeBase, dnETrans)

fillUp = showFills ? color.new(upStretchBase, fillUpTrans) : color.new(upStretchBase, 100)
fillDn = showFills ? color.new(dnStretchBase, fillDnTrans) : color.new(dnStretchBase, 100)

// -----------------------------------------------------
// Plots
// -----------------------------------------------------
plot(reference, "Reference Underlay", color = colRefGlow, linewidth = lineWRef + 2)
plot(reference, "Reference", color = colRefMain, linewidth = lineWRef)

pUpS = plot(upperStretchBand, "Upper Stretch", color = colUpS, linewidth = lineWBands + 1)
pUpE = plot(upperExtremeBand, "Upper Extreme", color = colUpE, linewidth = lineWBands + 1)

pDnS = plot(lowerStretchBand, "Lower Stretch", color = colDnS, linewidth = lineWBands + 1)
pDnE = plot(lowerExtremeBand, "Lower Extreme", color = colDnE, linewidth = lineWBands + 1)

fill(pUpS, pUpE, color = fillUp, title = "Upper Stretch Fill")
fill(pDnS, pDnE, color = fillDn, title = "Lower Stretch Fill")

// -----------------------------------------------------
// Active stretch zone box and badge
// -----------------------------------------------------
var box zoneBox = na
var label zoneBadge = na

distStr = f_fmt_pct(distPct)

if barstate.islast
    if not na(zoneBox)
        box.delete(zoneBox)
        zoneBox := na
    if not na(zoneBadge)
        label.delete(zoneBadge)
        zoneBadge := na

    if showActiveZoneBox and not na(reference)
        int x1 = math.max(0, bar_index - zoneBoxBars)
        int x2 = bar_index + zoneProjectBars
        int badgeX = x1 + int(math.round((x2 - x1) * zoneBadgeAnchor))
        if isUpperActive and not na(upperStretchBand) and not na(upperExtremeBand)
            zoneBox := box.new(x1, upperExtremeBand, x2, upperStretchBand,
                 xloc = xloc.bar_index,
                 border_color = color.new(upExtremeBase, 10),
                 bgcolor = color.new(upStretchBase, 84),
                 border_width = 3)
            if showZoneBadge
                zoneBadge := label.new(badgeX, (upperStretchBand + upperExtremeBand) / 2.0, f_zone_badge_text(true, zoneText, distStr),
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_label_center,
                     color = color.new(upExtremeBase, 0),
                     textcolor = f_text_on(upExtremeBase),
                     size = f_to_size(labelTextSizeStr))
        else if isLowerActive and not na(lowerStretchBand) and not na(lowerExtremeBand)
            zoneBox := box.new(x1, lowerStretchBand, x2, lowerExtremeBand,
                 xloc = xloc.bar_index,
                 border_color = color.new(dnExtremeBase, 10),
                 bgcolor = color.new(dnStretchBase, 84),
                 border_width = 3)
            if showZoneBadge
                zoneBadge := label.new(badgeX, (lowerStretchBand + lowerExtremeBand) / 2.0, f_zone_badge_text(false, zoneText, distStr),
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_label_center,
                     color = color.new(dnExtremeBase, 0),
                     textcolor = f_text_on(dnExtremeBase),
                     size = f_to_size(labelTextSizeStr))

// -----------------------------------------------------
// Action read
// -----------------------------------------------------
int activeSamples = 0
if distPct > 0
    activeSamples := posCount
else if distPct < 0
    activeSamples := negCount
else
    activeSamples := math.min(posCount, negCount)

bool ready = activeSamples >= minSample
actionText = na(reference) ? "Collecting" :
     not ready ? "Collecting" :
     isUpperActive and not na(currentRank) and currentRank >= pExtreme ? "Watch upper exhaustion" :
     isUpperActive and not na(currentRank) and currentRank >= pStretch ? "Upper stretch active" :
     isLowerActive and not na(currentRank) and currentRank >= pExtreme ? "Watch lower exhaustion" :
     isLowerActive and not na(currentRank) and currentRank >= pStretch ? "Lower stretch active" :
     "Inside range"
color actionColor = na(reference) or not ready ? neutralColor : isUpperActive ? bearColor : isLowerActive ? bullColor : f_panel_value()

// -----------------------------------------------------
// Premium status panel
// -----------------------------------------------------
panelTextSize = f_to_size(panelTextSizeStr)
labelTextSize = f_to_size(labelTextSizeStr)

var table infoBox = na

lookbackStr = str.tostring(lookback)
sampleStr = str.tostring(activeSamples)

if showInfo and barstate.islast
    if na(infoBox)
        infoBox := table.new(
             f_position(boxPos),
             2,
             8,
             bgcolor = f_panel_bg(),
             frame_color = f_panel_border(),
             frame_width = 1,
             border_color = f_panel_border(),
             border_width = 1)
    table.set_position(infoBox, f_position(boxPos))
    table.clear(infoBox, 0, 0, 1, 7)
    table.merge_cells(infoBox, 0, 0, 1, 0)

    table.cell(infoBox, 0, 0, "AG Pro Percentile Stretch Bands",
         text_color = headerText,
         bgcolor = headerBg,
         text_size = panelTextSize,
         text_halign = text.align_center)

    table.cell(infoBox, 0, 1, "Reference", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelTextSize)
    table.cell(infoBox, 1, 1, refName, text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = panelTextSize)

    table.cell(infoBox, 0, 2, "Distance", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelTextSize)
    table.cell(infoBox, 1, 2, distStr, text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = panelTextSize)

    table.cell(infoBox, 0, 3, "Zone", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelTextSize)
    table.cell(infoBox, 1, 3, zoneText, text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = panelTextSize)

    table.cell(infoBox, 0, 4, "Reversion", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelTextSize)
    table.cell(infoBox, 1, 4, revText, text_color = revColor, bgcolor = f_panel_bg(), text_size = panelTextSize)

    table.cell(infoBox, 0, 5, "Samples", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelTextSize)
    table.cell(infoBox, 1, 5, sampleStr, text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = panelTextSize)

    string note = ready ? "Ready" : "Collecting"
    table.cell(infoBox, 0, 6, "State", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelTextSize)
    table.cell(infoBox, 1, 6, note, text_color = ready ? f_panel_value() : neutralColor, bgcolor = f_panel_bg(), text_size = panelTextSize)

    table.cell(infoBox, 0, 7, "Action", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelTextSize)
    table.cell(infoBox, 1, 7, actionText, text_color = actionColor, bgcolor = f_panel_bg(), text_size = panelTextSize)

if not showInfo and not na(infoBox)
    table.delete(infoBox)
    infoBox := na

// -----------------------------------------------------
// Right-side guide tags
// -----------------------------------------------------
var label refTag = na
var label upSTag = na
var label upETag = na
var label dnSTag = na
var label dnETag = na

if barstate.islast
    label.delete(refTag)
    label.delete(upSTag)
    label.delete(upETag)
    label.delete(dnSTag)
    label.delete(dnETag)
    refTag := na
    upSTag := na
    upETag := na
    dnSTag := na
    dnETag := na

    int tagX = bar_index + tagOffsetBars

    bool upperEligible = not hideUpper
    bool lowerEligible = not hideLower

    // When the active-side zone badge is shown it already labels that side, so suppress its
    // Stretch/Extreme tags to avoid stacking on top of the badge.
    bool upperBadgeActive = showActiveZoneBox and showZoneBadge and isUpperActive and not na(upperStretchBand) and not na(upperExtremeBand)
    bool lowerBadgeActive = showActiveZoneBox and showZoneBadge and isLowerActive and not na(lowerStretchBand) and not na(lowerExtremeBand)

    bool showUpperTags = showLevelTags and upperEligible and (tagMode == "Both Sides" or isUpperActive) and not upperBadgeActive
    bool showLowerTags = showLevelTags and lowerEligible and (tagMode == "Both Sides" or isLowerActive) and not lowerBadgeActive

    if showRefTag and not na(reference)
        refTag := f_make_tag(tagX, reference, "Ref - " + refName,
             color.new(accentColor, 20), accentColor, label.style_label_left, labelTextSize)

    if showUpperTags
        if not na(upperStretchBand)
            upSTag := f_make_tag(tagX, upperStretchBand, "Stretch",
                 color.new(upStretchBase, 12), upStretchBase, label.style_label_left, labelTextSize)
        if not na(upperExtremeBand)
            upETag := f_make_tag(tagX, upperExtremeBand, "Extreme",
                 color.new(upExtremeBase, 8), upExtremeBase, label.style_label_left, labelTextSize)

    if showLowerTags
        if not na(lowerStretchBand)
            dnSTag := f_make_tag(tagX, lowerStretchBand, "Stretch",
                 color.new(dnStretchBase, 12), dnStretchBase, label.style_label_left, labelTextSize)
        if not na(lowerExtremeBand)
            dnETag := f_make_tag(tagX, lowerExtremeBand, "Extreme",
                 color.new(dnExtremeBase, 8), dnExtremeBase, label.style_label_left, labelTextSize)

    // De-collision: all guide tags share the same x, so separate them vertically when too close.
    array<label> tagList = array.new_label()
    if not na(refTag)
        array.push(tagList, refTag)
    if not na(upSTag)
        array.push(tagList, upSTag)
    if not na(upETag)
        array.push(tagList, upETag)
    if not na(dnSTag)
        array.push(tagList, dnSTag)
    if not na(dnETag)
        array.push(tagList, dnETag)

    int tn = array.size(tagList)
    if tn > 1
        array<float> tys = array.new_float()
        for ti = 0 to tn - 1
            array.push(tys, label.get_y(array.get(tagList, ti)))
        for a = 0 to tn - 2
            int mi = a
            for b = a + 1 to tn - 1
                if array.get(tys, b) < array.get(tys, mi)
                    mi := b
            if mi != a
                float ty = array.get(tys, a)
                array.set(tys, a, array.get(tys, mi))
                array.set(tys, mi, ty)
                label tl = array.get(tagList, a)
                array.set(tagList, a, array.get(tagList, mi))
                array.set(tagList, mi, tl)
        float gap = safeAtr * 0.6
        for a = 1 to tn - 1
            float py = array.get(tys, a - 1)
            float cy = array.get(tys, a)
            if cy - py < gap
                float ny = py + gap
                array.set(tys, a, ny)
                label.set_y(array.get(tagList, a), ny)

// -----------------------------------------------------
// Alerts
// -----------------------------------------------------
upperStretchCross = ta.crossover(close, upperStretchBand)
upperExtremeCross = ta.crossover(close, upperExtremeBand)
lowerStretchCross = ta.crossunder(close, lowerStretchBand)
lowerExtremeCross = ta.crossunder(close, lowerExtremeBand)

alertcondition(upperStretchCross, "Upper Stretch Cross",
     "AG Pro PSB: price crossed above Upper Stretch band. Overextension zone entered.")
alertcondition(upperExtremeCross, "Upper Extreme Cross",
     "AG Pro PSB: price crossed above Upper Extreme band. Rare upper extension.")
alertcondition(lowerStretchCross, "Lower Stretch Cross",
     "AG Pro PSB: price crossed below Lower Stretch band. Oversold extension zone entered.")
alertcondition(lowerExtremeCross, "Lower Extreme Cross",
     "AG Pro PSB: price crossed below Lower Extreme band. Rare lower extension.")
````
