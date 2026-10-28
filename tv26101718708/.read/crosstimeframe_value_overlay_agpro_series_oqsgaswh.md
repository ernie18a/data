# Cross-Timeframe Value Overlay [AGPro Series]

- url: https://www.tradingview.com/script/oqSgASWh-Cross-Timeframe-Value-Overlay-AGPro-Series/
- type: indicator
- pine_id: PUB;d93cc8e19c224327b52dc577611ec161
- version: 6.0

## Description

Cross-Timeframe Value Overlay [AGPro Series]

🔷 Overview

Cross-Timeframe Value Overlay projects up to three independent rolling value
bands — one per selected higher timeframe — onto a single chart. Each band
marks the region where price has been accepted on that timeframe over a
configurable lookback window, built from a volume-weighted or mean-based
anchor surrounded by an ATR envelope. A built-in state engine then classifies
the relationship between bands in real time as ALIGNED, OVERLAP, CONFLICT or
NEUTRAL, so multi-timeframe context becomes readable in a single glance.

🔷 What Makes This Different

Most multi-timeframe scripts stack indicators or draw fixed HTF pivots. This
tool builds a *rolling* value envelope on each timeframe and then compares
them structurally rather than numerically.

• Three independent MTF value bands on one chart, each with its own lookback
  context and ATR-sized width.
• Dedicated state engine with four discrete regimes — ALIGNED / OVERLAP /
  CONFLICT / NEUTRAL — based on pairwise band geometry, not on raw price.
• Dynamic z-order rendering that automatically draws the slowest timeframe
  behind faster ones, and an opacity hierarchy that keeps the slowest band
  lightest and the fastest band darkest. Larger structures frame smaller
  ones instead of obscuring them.
• Rank-based label placement that prevents collisions when bands overlap in
  price, so labels remain readable even during OVERLAP or ALIGNED states.
• Box width adaptively capped so a Daily band cannot swallow a 1H chart.
• Dominant-TF tracking that always reports the highest enabled timeframe and
  the price position relative to its band.

🔷 Methodology

For each enabled timeframe the script computes:

• Anchor  = VWAP (volume-weighted HLC3) over the rolling window, or HLC3 SMA
  when volume data is unreliable.
• Half    = ATR(window) multiplied by the configured band-width factor.
• Band    = [anchor + half, anchor − half].

Values are requested with lookahead disabled, so historical band positions
reflect only data that was available at the time.

The state engine then evaluates:

• Pairwise overlap — do any two bands share a price region?
• Alignment — are all enabled band centers clustered within a strictness
  threshold (Loose 1.2 ATR / Standard 0.8 ATR / Strict 0.4 ATR) of their
  mean?
• Disjoint count — how many pairs are fully separated?

These three checks map deterministically to one of four states on every bar.

🔷 Signals and Alerts

Three built-in alert conditions cover the most useful MTF transitions:

• Value Overlap Detected — a new pairwise overlap forms between any two
  enabled timeframes.
• Higher-Timeframe Value Lost — price leaves the dominant HTF value band
  after being inside it on the previous bar.
• Cross-Timeframe Conflict — the state engine transitions into CONFLICT,
  indicating that at least one enabled pair of bands has become fully
  disjoint.

All alerts are wired as alertcondition() entries so they can be combined
with the standard TradingView alert workflow.

🔷 Key Inputs

• Timeframes — enable/disable up to three HTFs and pick any resolution for
  each (defaults 1H / 4H / Daily).
• Rolling Window — 10 to 500 bars for the anchor and ATR.
• Band Width — 0.25 to 3.0 ATR half-width.
• Anchor Method — VWAP + ATR or HLC3 MA + ATR.
• Alignment Strictness — Loose, Standard or Strict threshold for the state
  engine.
• Show Only Overlapping Bands — hides isolated bands to keep confluence
  zones visible.
• Visuals — per-TF color, base opacity, right-edge label toggle, label font
  size.
• Panel — position, font size and master visibility switch.

🔷 How to Use

• Read the state first. ALIGNED = all enabled timeframes agree on a common
  value region; OVERLAP = partial confluence; CONFLICT = disjoint
  timeframes; NEUTRAL = fewer than two active bands or indeterminate.
• Read the Dominant row to see which timeframe currently carries the most
  structural weight.
• Read the per-TF rows to locate price as Above / Inside / Below each band.
• Combine the three in a single pass: for example, price Above a dominant
  HTF band while the state is CONFLICT is a very different context from
  price Inside an ALIGNED stack.
• Pair with your existing entry framework (breakout, mean-reversion, order
  flow, trend-following) — this tool is a context layer, not an entry
  signal generator.

🔷 Limitations and Transparency

• Box-based rendering is capped at three concurrent bands by design to keep
  the chart readable.
• All values are computed with lookahead disabled. Bands update when the
  corresponding HTF bar closes, which is the expected behavior for any MTF
  tool.
• Volume-weighted anchoring depends on the quality of the instrument's
  volume feed; on markets with unreliable volume, switch to the HLC3 MA
  method.
• This script is an analytical overlay. It is not a strategy, does not
  produce buy/sell signals, and makes no forecasting claim.

🔷 Risk Disclosure

Trading involves substantial risk. This indicator is provided for research
and educational purposes only and does not constitute financial advice.
Past market behavior does not guarantee future results. Always perform your
own due diligence and use proper risk management.

Open-source under Mozilla Public License 2.0.

## Source Code

````pine
// -------------------------------------------------
// Cross-Timeframe Value Overlay [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.13
//
// Cross-Timeframe Value Overlay projects multiple higher-timeframe accepted
// value bands onto one chart and summarizes whether VWAP or HLC3-based value
// is aligned, overlapping, conflicting, or neutral across timeframes. It maps
// cross-timeframe value confluence, dominant value location, price position,
// overlap quality, and a practical review workflow with collision-aware badge
// placement, horizontally separated timeframe tags, and a candle-safe
// confluence badge, without acting as a prediction engine or automated
// strategy. Version 1.13 adds clear breathing room between the confluence
// badge and the horizontally separated timeframe-tag ladder while preserving
// every tag's true value-band level.
// -------------------------------------------------

//@version=6
indicator("Cross-Timeframe Value Overlay [AGPro Series]",
     shorttitle       = "CTV",
     overlay          = true,
     max_boxes_count  = 24,
     max_labels_count = 140,
     max_lines_count  = 20,
     max_bars_back    = 500)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
grpTF = "Timeframes"
tf1En = input.bool(true, "TF 1 Fast", group = grpTF, inline = "tf1",
     tooltip = "Enables the fastest value band. This band is useful for near-term accepted value and tactical reaction areas.")
tf1Res = input.timeframe("60", "", group = grpTF, inline = "tf1")

tf2En = input.bool(true, "TF 2 Mid", group = grpTF, inline = "tf2",
     tooltip = "Enables the mid timeframe value band. This band often carries the most practical intraday-to-swing value context.")
tf2Res = input.timeframe("240", "", group = grpTF, inline = "tf2")

tf3En = input.bool(true, "TF 3 Slow", group = grpTF, inline = "tf3",
     tooltip = "Enables the slowest value band. This band provides the broader structural accepted-value frame.")
tf3Res = input.timeframe("D", "", group = grpTF, inline = "tf3")

grpEngine = "Value Engine"
vbLen = input.int(50, "Rolling Window", minval = 10, maxval = 500, group = grpEngine,
     tooltip = "Bars used on each selected timeframe to calculate the rolling value anchor and ATR band. Higher values create slower, broader value areas.")
vbWidth = input.float(1.0, "Band Width (ATR)", minval = 0.25, maxval = 3.0, step = 0.1, group = grpEngine,
     tooltip = "Half-width of each value band in ATR units around the selected value anchor.")
vbMode = input.string("VWAP + ATR", "Anchor Method", options = ["VWAP + ATR", "HLC3 MA + ATR"], group = grpEngine,
     tooltip = "VWAP + ATR uses volume-weighted value when volume is reliable. HLC3 MA + ATR is volume-independent and can be cleaner on symbols where reported volume is less useful.")

grpState = "State Engine"
strictMode = input.string("Standard", "Alignment Strictness", options = ["Loose", "Standard", "Strict"], group = grpState,
     tooltip = "Controls how tightly timeframe centers must cluster before the overlay classifies value as aligned.")
onlyOverlaps = input.bool(false, "Show Only Overlapping Bands", group = grpState,
     tooltip = "When enabled, isolated timeframe bands are hidden and only bands overlapping at least one other timeframe remain visible.")
scoreSensitivity = input.string("Normal", "Score Sensitivity", options = ["Responsive", "Normal", "Strict"], group = grpState,
     tooltip = "Controls how demanding the 0-100 confluence score is. Responsive rewards partial overlap faster, while Strict requires cleaner center agreement and overlap.")
followWindow = input.int(20, "Break Follow Proof Window (bars)", minval = 4, maxval = 200, group = grpState,
     tooltip = "Number of bars a dominant-value break has to follow through within, for the Break Follow Rate proof. It only measures historical follow-through and is not a forecast.")

grpVisual = "Visuals"
showBands = input.bool(true, "Show Value Bands", group = grpVisual,
     tooltip = "Displays the selected higher-timeframe accepted-value bands.")
showConfluenceZone = input.bool(true, "Show Confluence Zone", group = grpVisual,
     tooltip = "Highlights the shared value area when two or more timeframe bands overlap. The premium label is centered inside the zone.")
showBandTags = input.bool(true, "Show Timeframe Tags", group = grpVisual,
     tooltip = "Shows compact right-edge timeframe tags for visible value bands. Tags are staggered to reduce overlap.")
showBandBadges = input.bool(false, "Show Center Band Badges", group = grpVisual,
     tooltip = "Shows compact centered badges inside visible value bands so each higher-timeframe zone explains itself without relying only on right-edge tags.")
showLiveTag = input.bool(false, "Show Live State Tag", group = grpVisual,
     tooltip = "Shows a compact right-edge state tag. Disabled by default because the panel and confluence badge already carry the current state.")
showEventLabels = input.bool(true, "Show Event Labels", group = grpVisual,
     tooltip = "Shows spaced labels for aligned value, new overlap, conflict, and dominant value lost events. Labels are offset away from candles.")
labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = grpVisual,
     tooltip = "Controls the amount of chart annotation. Balanced keeps the chart active without making the value overlay crowded.")
baseOpacity = input.int(91, "Band Opacity", minval = 60, maxval = 94, group = grpVisual,
     tooltip = "Transparency of value bands. Higher values are lighter; lower values are stronger.")
projectionBars = input.int(12, "Right Projection Bars", minval = 5, maxval = 60, group = grpVisual,
     tooltip = "How far value bands and right-edge tags extend beyond the latest bar.")
maxBandHistoryBars = input.int(84, "Band History Bars", minval = 24, maxval = 180, group = grpVisual,
     tooltip = "Caps how far higher-timeframe value bands extend left on the chart. Lower values reduce oversized blocks while keeping the active value map visible.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVisual,
     tooltip = "Controls on-chart label size for event labels, timeframe tags, and centered value-zone badges.")
tf1Col = input.color(color.rgb(245, 189, 92), "TF 1 Color", group = grpVisual, inline = "c1",
     tooltip = "Color for the fastest value band.")
tf2Col = input.color(color.rgb(34, 197, 166), "TF 2 Color", group = grpVisual, inline = "c2",
     tooltip = "Color for the mid timeframe value band.")
tf3Col = input.color(color.rgb(129, 140, 248), "TF 3 Color", group = grpVisual, inline = "c3",
     tooltip = "Color for the slowest value band.")

grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel,
     tooltip = "Shows the compact status panel with workflow, value state, dominant timeframe, confluence score, price location, and overlap map.")
panelPosition = input.string("Top Right", "Panel Position",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpPanel,
     tooltip = "Controls where the panel is anchored on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpPanel,
     tooltip = "Switches the panel color scheme for dark or light chart backgrounds.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel,
     tooltip = "Controls panel text size.")

grpAlerts = "Alerts"
alertOnAligned = input.bool(true, "Alert: Aligned Value", group = grpAlerts,
     tooltip = "Creates an attention marker when selected value bands shift into aligned value.")
alertOnOverlap = input.bool(true, "Alert: Value Overlap", group = grpAlerts,
     tooltip = "Creates an attention marker when a new cross-timeframe value overlap appears.")
alertOnConflict = input.bool(true, "Alert: Value Conflict", group = grpAlerts,
     tooltip = "Creates an attention marker when selected timeframe value bands become disjoint.")
alertOnDominantLost = input.bool(true, "Alert: Dominant Value Lost", group = grpAlerts,
     tooltip = "Creates an attention marker when price leaves the dominant higher-timeframe value band.")

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBgDark = color.rgb(15, 23, 42)
panelBgLight = color.rgb(248, 250, 252)
panelBorderD = color.rgb(51, 65, 85)
panelBorderL = color.rgb(203, 213, 225)
panelLabelD = color.rgb(148, 163, 184)
panelLabelL = color.rgb(71, 85, 105)
panelValueD = color.rgb(226, 232, 240)
panelValueL = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
dangerColor = color.rgb(239, 68, 68)

isLightTheme = panelTheme == "Light"
panelBg = isLightTheme ? panelBgLight : panelBgDark
panelBorder = isLightTheme ? panelBorderL : panelBorderD
panelLabelCol = isLightTheme ? panelLabelL : panelLabelD
panelValueCol = isLightTheme ? panelValueL : panelValueD
panelAltBg = isLightTheme ? color.rgb(241, 245, 249) : color.rgb(24, 35, 55)
darkText = color.rgb(17, 24, 39)

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
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_thr(string m) =>
    switch m
        "Loose" => 1.20
        "Strict" => 0.40
        => 0.80

f_score_weight(string m) =>
    switch m
        "Responsive" => 0.80
        "Strict" => 1.20
        => 1.00

f_tf_short(string tf) =>
    string t = str.upper(tf)
    switch t
        "1" => "1m"
        "3" => "3m"
        "5" => "5m"
        "15" => "15m"
        "30" => "30m"
        "45" => "45m"
        "60" => "1h"
        "120" => "2h"
        "180" => "3h"
        "240" => "4h"
        "360" => "6h"
        "480" => "8h"
        "720" => "12h"
        "D" => "1d"
        "1D" => "1d"
        "W" => "1w"
        "1W" => "1w"
        "M" => "1mo"
        "1M" => "1mo"
        => str.lower(t)

f_tf_sec(string tf) =>
    timeframe.in_seconds(tf)

f_place(float h, float l) =>
    na(h) or na(l) ? "-" : close > h ? "Above" : close < l ? "Below" : "Inside"

f_state_color(string s) =>
    s == "ALIGNED" ? bullColor : s == "OVERLAP" ? neutralColor : s == "CONFLICT" ? bearColor : accentColor

f_state_text_color(string s) =>
    s == "OVERLAP" or s == "NEUTRAL" ? darkText : headerText

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_workflow(string s, int score, bool insideDom) =>
    s == "ALIGNED" and score >= 70 and insideDom ? "Review Aligned Value" :
     s == "ALIGNED" ? "Map Alignment" :
     s == "OVERLAP" and insideDom ? "Review Overlap" :
     s == "OVERLAP" ? "Map Overlap" :
     s == "CONFLICT" ? "Wait Clarity" :
     "Wait Value Map"

f_review(string s, int score, int pairs, string loc) =>
    s == "ALIGNED" ? "ALIGNED / " + str.tostring(score) :
     s == "OVERLAP" ? str.tostring(pairs) + " Overlap Pairs" :
     s == "CONFLICT" ? "CONFLICT / " + loc :
     "NEUTRAL / " + loc

f_action_color(string workflow, string s) =>
    str.contains(workflow, "Review") ? f_state_color(s) : str.contains(workflow, "Wait") ? neutralColor : accentColor

f_label_y(float h, float l, int rank, int totalRanks) =>
    float topY = h - (h - l) * 0.22
    float midY = (h + l) / 2.0
    float botY = l + (h - l) * 0.22
    totalRanks <= 1 ? midY : totalRanks == 2 ? (rank == 0 ? topY : botY) : rank == 0 ? topY : rank == 1 ? midY : botY

f_badge_y(float h, float l, int rank) =>
    float span = math.max(h - l, syminfo.mintick)
    rank == 0 ? h - span * 0.16 : rank == 1 ? (h + l) * 0.50 : l + span * 0.16

f_rank_for(float c, bool eA, float cA, bool eB, float cB) =>
    int r = 0
    if eA and cA > c
        r += 1
    if eB and cB > c
        r += 1
    r

f_live_outer_high(bool activeA, float hA, bool activeB, float hB, bool activeC, float hC) =>
    math.max(activeA and not na(hA) ? hA : high, math.max(activeB and not na(hB) ? hB : high, activeC and not na(hC) ? hC : high))

f_live_outer_low(bool activeA, float lA, bool activeB, float lB, bool activeC, float lC) =>
    math.min(activeA and not na(lA) ? lA : low, math.min(activeB and not na(lB) ? lB : low, activeC and not na(lC) ? lC : low))

f_row_bg(int row) =>
    bool evenRow = row % 2 == 0
    isLightTheme ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string sizeInput) =>
    color rowBg = f_row_bg(row)
    table.cell(target, 0, row, leftText, text_color = panelLabelCol, bgcolor = rowBg, text_size = f_size(sizeInput), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(sizeInput), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

panelSize = f_size(panelSizeInput)
labelSize = f_size(labelSizeInput)
tagGapBars = labelDensity == "Detailed" ? 7 : labelDensity == "Balanced" ? 10 : 14
maxEventLabels = labelDensity == "Detailed" ? 11 : labelDensity == "Balanced" ? 6 : 4
eventCooldownBars = labelDensity == "Detailed" ? 30 : labelDensity == "Balanced" ? 72 : 96

// -------------------------------------------------
// Value Band Computation
// -------------------------------------------------
f_band() =>
    float src = hlc3
    float rawVol = na(volume) ? 1.0 : volume
    float volBase = math.max(ta.sma(rawVol, vbLen), 1e-10)
    float anchor = vbMode == "VWAP + ATR" ? ta.sma(src * rawVol, vbLen) / volBase : ta.sma(src, vbLen)
    float half = ta.atr(vbLen) * vbWidth
    [anchor, anchor + half, anchor - half]

[c1, h1, l1] = request.security(syminfo.tickerid, tf1Res, f_band(), lookahead = barmerge.lookahead_off)
[c2, h2, l2] = request.security(syminfo.tickerid, tf2Res, f_band(), lookahead = barmerge.lookahead_off)
[c3, h3, l3] = request.security(syminfo.tickerid, tf3Res, f_band(), lookahead = barmerge.lookahead_off)

chartAtr = math.max(nz(ta.atr(math.max(vbLen, 14)), ta.tr(true)), syminfo.mintick)

// -------------------------------------------------
// State Engine
// -------------------------------------------------
ov12 = tf1En and tf2En and not na(h1) and not na(h2) and not (h1 < l2 or h2 < l1)
ov13 = tf1En and tf3En and not na(h1) and not na(h3) and not (h1 < l3 or h3 < l1)
ov23 = tf2En and tf3En and not na(h2) and not na(h3) and not (h2 < l3 or h3 < l2)

enabledN = (tf1En ? 1 : 0) + (tf2En ? 1 : 0) + (tf3En ? 1 : 0)
activeOverlapPairs = (ov12 ? 1 : 0) + (ov13 ? 1 : 0) + (ov23 ? 1 : 0)

thr = f_thr(strictMode) * chartAtr
avgC = ((tf1En ? c1 : 0.0) + (tf2En ? c2 : 0.0) + (tf3En ? c3 : 0.0)) / math.max(enabledN, 1)
d1 = tf1En ? math.abs(c1 - avgC) : 0.0
d2 = tf2En ? math.abs(c2 - avgC) : 0.0
d3 = tf3En ? math.abs(c3 - avgC) : 0.0
maxCenterSpread = math.max(d1, math.max(d2, d3))
isAligned = enabledN >= 2 and maxCenterSpread <= thr
isOverlap = activeOverlapPairs > 0 and not isAligned

disjoint = 0
if tf1En and tf2En and not ov12
    disjoint += 1
if tf1En and tf3En and not ov13
    disjoint += 1
if tf2En and tf3En and not ov23
    disjoint += 1
isConflict = disjoint >= 1 and not isAligned and not isOverlap

state = isAligned ? "ALIGNED" : isOverlap ? "OVERLAP" : isConflict ? "CONFLICT" : "NEUTRAL"
stateColor = f_state_color(state)

s1 = tf1En ? f_tf_sec(tf1Res) : 0
s2 = tf2En ? f_tf_sec(tf2Res) : 0
s3 = tf3En ? f_tf_sec(tf3Res) : 0
domSec = math.max(s1, math.max(s2, s3))
domTF = domSec == s3 and tf3En ? tf3Res : domSec == s2 and tf2En ? tf2Res : tf1Res
domH = domSec == s3 and tf3En ? h3 : domSec == s2 and tf2En ? h2 : h1
domL = domSec == s3 and tf3En ? l3 : domSec == s2 and tf2En ? l2 : l1

p1 = tf1En ? f_place(h1, l1) : "-"
p2 = tf2En ? f_place(h2, l2) : "-"
p3 = tf3En ? f_place(h3, l3) : "-"
domLocation = f_place(domH, domL)

centerTightness = 1.0 - f_clamp(maxCenterSpread / math.max(thr * f_score_weight(scoreSensitivity), syminfo.mintick), 0.0, 1.0)
overlapScore = enabledN >= 2 ? activeOverlapPairs / math.max(enabledN == 3 ? 3.0 : 1.0, 1.0) : 0.0
insideDominant = close >= domL and close <= domH
locationScore = insideDominant ? 1.0 : 0.25
confluenceScore = int(math.round(f_clamp(centerTightness * 0.48 + overlapScore * 0.34 + locationScore * 0.18, 0.0, 1.0) * 100.0))
workflowText = f_workflow(state, confluenceScore, insideDominant)
workflowColor = f_action_color(workflowText, state)
reviewText = f_review(state, confluenceScore, activeOverlapPairs, domLocation)

draw1 = showBands and tf1En and (not onlyOverlaps or ov12 or ov13)
draw2 = showBands and tf2En and (not onlyOverlaps or ov12 or ov23)
draw3 = showBands and tf3En and (not onlyOverlaps or ov13 or ov23)

hasConfluence = activeOverlapPairs > 0
confAllTop = math.min(tf1En and (ov12 or ov13) ? h1 : 1e20, math.min(tf2En and (ov12 or ov23) ? h2 : 1e20, tf3En and (ov13 or ov23) ? h3 : 1e20))
confAllBottom = math.max(tf1En and (ov12 or ov13) ? l1 : -1e20, math.max(tf2En and (ov12 or ov23) ? l2 : -1e20, tf3En and (ov13 or ov23) ? l3 : -1e20))
confAllValid = hasConfluence and confAllTop > confAllBottom and confAllTop < 1e19 and confAllBottom > -1e19

pair12Top = math.min(h1, h2)
pair12Bottom = math.max(l1, l2)
pair13Top = math.min(h1, h3)
pair13Bottom = math.max(l1, l3)
pair23Top = math.min(h2, h3)
pair23Bottom = math.max(l2, l3)
pair12Height = ov12 and pair12Top > pair12Bottom ? pair12Top - pair12Bottom : -1.0
pair13Height = ov13 and pair13Top > pair13Bottom ? pair13Top - pair13Bottom : -1.0
pair23Height = ov23 and pair23Top > pair23Bottom ? pair23Top - pair23Bottom : -1.0
usePair12 = pair12Height >= pair13Height and pair12Height >= pair23Height
usePair13 = not usePair12 and pair13Height >= pair23Height
bestPairTop = usePair12 ? pair12Top : usePair13 ? pair13Top : pair23Top
bestPairBottom = usePair12 ? pair12Bottom : usePair13 ? pair13Bottom : pair23Bottom
bestPairHeight = math.max(pair12Height, math.max(pair13Height, pair23Height))
confTop = confAllValid ? confAllTop : bestPairTop
confBottom = confAllValid ? confAllBottom : bestPairBottom
confValid = confAllValid or bestPairHeight > 0.0

alignedFire = isAligned and not isAligned[1]
overlapFire = activeOverlapPairs > activeOverlapPairs[1]
conflictFire = isConflict and not isConflict[1]
dominantLost = not na(domL[1]) and not na(domH[1]) and close[1] >= domL[1] and close[1] <= domH[1] and (close < domL or close > domH)

// -------------------------------------------------
// Break follow-through proof (Confirm Rate)
// -------------------------------------------------
// When price leaves the dominant value band, does it follow through 0.75 ATR in
// the exit direction (a real break) before closing back inside the band edge it
// left (a false break)? Counted once per exit. Re-entry first, or a window
// expiry with no follow-through, is treated as a not-followed (conservative).
float dvMargin = chartAtr * 0.75
var int   dvTotal = 0
var int   dvWon    = 0
var bool  dvPend    = false
var int   dvDir      = 0
var float dvAnchor    = na
var float dvEdge       = na
var int   dvLeft        = 0

if barstate.isconfirmed
    if dvPend and not na(dvAnchor) and not na(dvEdge)
        bool reentered = dvDir > 0 ? close <= dvEdge : close >= dvEdge
        bool followed = dvDir > 0 ? close >= dvAnchor + dvMargin : close <= dvAnchor - dvMargin
        if reentered
            dvTotal += 1
            dvPend := false
        else if followed
            dvTotal += 1
            dvWon += 1
            dvPend := false
        else
            dvLeft -= 1
            if dvLeft <= 0
                dvTotal += 1
                dvPend := false
    if dominantLost and not dvPend and not na(domH) and not na(domL)
        dvDir := close > domH ? 1 : -1
        dvAnchor := close
        dvEdge := dvDir > 0 ? domH : domL
        dvLeft := followWindow
        dvPend := true

float dvRate = dvTotal > 0 ? dvWon / dvTotal * 100.0 : na
string breakRead = dvTotal > 0 ? str.tostring(math.round(dvRate)) + "% (" + str.tostring(dvTotal) + ")" : "Building"

// -------------------------------------------------
// Visual Rendering
// -------------------------------------------------
chartSec = math.max(timeframe.in_seconds(timeframe.period), 1)
rightX = bar_index + projectionBars

f_left_for(string tf) =>
    int ratio = int(math.round(math.max(1.0, f_tf_sec(tf) / float(chartSec))))
    int adaptiveSpan = int(math.round(18.0 * math.sqrt(ratio)))
    math.max(0, bar_index - math.min(math.max(adaptiveSpan, 24), maxBandHistoryBars))

f_rank_op(int secA, int secB, int secC, bool eA, bool eB, bool eC, int base) =>
    int rA = eA ? secA : 0
    int rB = eB ? secB : 0
    int rC = eC ? secC : 0
    int mx = math.max(rA, math.max(rB, rC))
    int mn = math.min(rA > 0 ? rA : mx, math.min(rB > 0 ? rB : mx, rC > 0 ? rC : mx))
    int oA = eA ? (rA == mx ? math.min(94, base + 6) : rA == mn ? math.max(60, base - 8) : base) : base
    int oB = eB ? (rB == mx ? math.min(94, base + 6) : rB == mn ? math.max(60, base - 8) : base) : base
    int oC = eC ? (rC == mx ? math.min(94, base + 6) : rC == mn ? math.max(60, base - 8) : base) : base
    [oA, oB, oC]

[op1, op2, op3] = f_rank_op(s1, s2, s3, tf1En, tf2En, tf3En, baseOpacity)

totalActive = (draw1 ? 1 : 0) + (draw2 ? 1 : 0) + (draw3 ? 1 : 0)
r1 = draw1 ? f_rank_for(c1, draw2, c2, draw3, c3) : 0
r2 = draw2 ? f_rank_for(c2, draw1, c1, draw3, c3) : 0
r3 = draw3 ? f_rank_for(c3, draw1, c1, draw2, c2) : 0

var box b1 = na
var box b2 = na
var box b3 = na
var label tag1 = na
var label tag2 = na
var label tag3 = na
var label badge1 = na
var label badge2 = na
var label badge3 = na
var box confluenceBox = na
var label confluenceLabel = na
var label liveTag = na
var array<label> eventLabels = array.new<label>()
var int lastEventLabelBar = na

f_draw_band(box b, label lb, label cb, bool enabled, bool shouldDraw, float h, float l, color col, int opacity, string txt, int leftX, int tagX, int rank, int totalRanks) =>
    box nb = b
    label nl = lb
    label nc = cb
    if enabled and shouldDraw and not na(h) and not na(l)
        color bg = color.new(col, opacity)
        color br = color.new(col, math.max(0, opacity - 36))
        if na(nb)
            nb := box.new(leftX, h, rightX, l, xloc = xloc.bar_index, border_color = br, border_width = 1, bgcolor = bg)
        else
            box.set_lefttop(nb, leftX, h)
            box.set_rightbottom(nb, rightX, l)
            box.set_bgcolor(nb, bg)
            box.set_border_color(nb, br)
        if showBandTags and labelDensity != "Minimal"
            float y = f_label_y(h, l, rank, totalRanks)
            if na(nl)
                nl := label.new(tagX, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(col, 7), textcolor = f_text_on(col), size = labelSize)
            else
                label.set_xy(nl, tagX, y)
                label.set_text(nl, txt)
                label.set_color(nl, color.new(col, 7))
                label.set_textcolor(nl, f_text_on(col))
                label.set_size(nl, labelSize)
        else if not na(nl)
            label.delete(nl)
            nl := na
        bool roomForBandBadge = (h - l) >= chartAtr * 0.95
        if showBandBadges and labelDensity != "Minimal" and roomForBandBadge
            int badgeX = int(math.round((leftX + rightX) * 0.50))
            float badgeY = f_badge_y(h, l, rank)
            string badgeText = txt + "\nValue"
            if na(nc)
                nc := label.new(badgeX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(col, 4), textcolor = f_text_on(col), size = labelSize, textalign = text.align_center)
            else
                label.set_xy(nc, badgeX, badgeY)
                label.set_text(nc, badgeText)
                label.set_color(nc, color.new(col, 4))
                label.set_textcolor(nc, f_text_on(col))
                label.set_size(nc, labelSize)
        else if not na(nc)
            label.delete(nc)
            nc := na
    else
        if not na(nb)
            box.delete(nb)
            nb := na
        if not na(nl)
            label.delete(nl)
            nl := na
        if not na(nc)
            label.delete(nc)
            nc := na
    [nb, nl, nc]

eventQualityOk = dominantLost ? confluenceScore >= 30 : conflictFire ? confluenceScore >= 20 : overlapFire ? confluenceScore >= 40 : confluenceScore >= 45

if showEventLabels and eventQualityOk and (alignedFire or overlapFire or conflictFire or dominantLost) and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= eventCooldownBars)
    string eventText = dominantLost ? "Dom Lost " + str.tostring(confluenceScore) : conflictFire ? "Conflict " + str.tostring(confluenceScore) : alignedFire ? "Aligned " + str.tostring(confluenceScore) : "Overlap " + str.tostring(confluenceScore)
    color eventColor = dominantLost ? bearColor : conflictFire ? bearColor : alignedFire ? bullColor : neutralColor
    bool eventAbove = dominantLost or conflictFire or close >= avgC
    float eventY = eventAbove ? high + chartAtr * 1.35 : low - chartAtr * 1.35
    label eventLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, yloc = yloc.price, style = eventAbove ? label.style_label_down : label.style_label_up, color = color.new(eventColor, 6), textcolor = eventColor == neutralColor ? darkText : headerText, size = labelSize)
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, maxEventLabels)
    lastEventLabelBar := bar_index

if barstate.islast
    int tagBaseX = rightX + 7
    int tag1X = tagBaseX
    int tag2X = tagBaseX + tagGapBars
    int tag3X = tagBaseX + tagGapBars * 2
    [nb1, nl1, nc1] = f_draw_band(b1, tag1, badge1, tf1En, draw1, h1, l1, tf1Col, op1, "TF1 " + str.upper(f_tf_short(tf1Res)), f_left_for(tf1Res), tag1X, r1, totalActive)
    b1 := nb1
    tag1 := nl1
    badge1 := nc1
    [nb2, nl2, nc2] = f_draw_band(b2, tag2, badge2, tf2En, draw2, h2, l2, tf2Col, op2, "TF2 " + str.upper(f_tf_short(tf2Res)), f_left_for(tf2Res), tag2X, r2, totalActive)
    b2 := nb2
    tag2 := nl2
    badge2 := nc2
    [nb3, nl3, nc3] = f_draw_band(b3, tag3, badge3, tf3En, draw3, h3, l3, tf3Col, op3, "TF3 " + str.upper(f_tf_short(tf3Res)), f_left_for(tf3Res), tag3X, r3, totalActive)
    b3 := nb3
    tag3 := nl3
    badge3 := nc3

    if showConfluenceZone and confValid
        int leftConf = math.max(0, bar_index - 44)
        int rightConf = rightX
        int centerX = int(math.round(bar_index + math.max(2, math.min(projectionBars - 2, 8))))
        float centerY = (confTop + confBottom) / 2.0
        color confBg = color.new(stateColor, state == "CONFLICT" ? 91 : 86)
        color confBorder = color.new(stateColor, 26)
        if na(confluenceBox)
            confluenceBox := box.new(leftConf, confTop, rightConf, confBottom, xloc = xloc.bar_index, bgcolor = confBg, border_color = confBorder, border_width = 1)
        else
            box.set_lefttop(confluenceBox, leftConf, confTop)
            box.set_rightbottom(confluenceBox, rightConf, confBottom)
            box.set_bgcolor(confluenceBox, confBg)
            box.set_border_color(confluenceBox, confBorder)
        if labelDensity != "Minimal"
            string confText = "Confluence\n" + state + " " + str.tostring(confluenceScore)
            if na(confluenceLabel)
                confluenceLabel := label.new(centerX, centerY, confText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 4), textcolor = f_state_text_color(state), size = labelSize, textalign = text.align_center)
            else
                label.set_xy(confluenceLabel, centerX, centerY)
                label.set_text(confluenceLabel, confText)
                label.set_color(confluenceLabel, color.new(stateColor, 4))
                label.set_textcolor(confluenceLabel, f_state_text_color(state))
                label.set_size(confluenceLabel, labelSize)
        else if not na(confluenceLabel)
            label.delete(confluenceLabel)
            confluenceLabel := na
    else
        if not na(confluenceBox)
            box.delete(confluenceBox)
            confluenceBox := na
        if not na(confluenceLabel)
            label.delete(confluenceLabel)
            confluenceLabel := na

    if showLiveTag and labelDensity != "Minimal"
        int liveX = tagBaseX + tagGapBars * 6
        float outerHigh = f_live_outer_high(draw1, h1, draw2, h2, draw3, h3)
        float outerLow = f_live_outer_low(draw1, l1, draw2, l2, draw3, l3)
        bool liveAbove = close >= avgC
        float liveY = liveAbove ? outerHigh + chartAtr * 0.42 : outerLow - chartAtr * 0.42
        liveStyle = liveAbove ? label.style_label_down : label.style_label_up
        string liveText = "Value " + state + " " + str.tostring(confluenceScore)
        if na(liveTag)
            liveTag := label.new(liveX, liveY, liveText, xloc = xloc.bar_index, yloc = yloc.price, style = liveStyle, color = color.new(stateColor, 0), textcolor = f_state_text_color(state), size = labelSize)
        else
            label.set_xy(liveTag, liveX, liveY)
            label.set_text(liveTag, liveText)
            label.set_style(liveTag, liveStyle)
            label.set_color(liveTag, color.new(stateColor, 0))
            label.set_textcolor(liveTag, f_state_text_color(state))
            label.set_size(liveTag, labelSize)
    else if not na(liveTag)
        label.delete(liveTag)
        liveTag := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
color breakColor = na(dvRate) ? panelValueCol : dvRate >= 60.0 ? bullColor : dvRate >= 45.0 ? neutralColor : bearColor
var table panel = na

if showPanel and na(panel)
    panel := table.new(f_pos(panelPosition), 2, 8, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
    table.cell(panel, 0, 0, "AG Pro Cross-Timeframe Value Overlay", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_pos(panelPosition))
    table.set_frame_color(panel, panelBorder)
    table.set_border_color(panel, panelBorder)
    table.clear(panel, 0, 0, 1, 7)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Cross-Timeframe Value Overlay", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    f_panel_row(panel, 1, "Workflow", workflowText, workflowColor, panelSizeInput)
    f_panel_row(panel, 2, "Value State", state, f_state_color(state), panelSizeInput)
    f_panel_row(panel, 3, "Dominant TF", f_tf_short(domTF) + " / " + domLocation, panelValueCol, panelSizeInput)
    f_panel_row(panel, 4, "Confluence Score", str.tostring(confluenceScore) + " / 100", confluenceScore >= 70 ? bullColor : confluenceScore >= 50 ? neutralColor : bearColor, panelSizeInput)
    f_panel_row(panel, 5, "Break Follow", breakRead, breakColor, panelSizeInput)
    f_panel_row(panel, 6, "Price Location", p1 + " / " + p2 + " / " + p3, panelValueCol, panelSizeInput)
    f_panel_row(panel, 7, "Review", reviewText, stateColor, panelSizeInput)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertOnAligned and alignedFire, "Aligned Value Detected", "Cross-Timeframe Value Overlay: selected value bands shifted into aligned value. This is an attention marker, not a trade instruction.")
alertcondition(alertOnOverlap and overlapFire, "Value Overlap Detected", "Cross-Timeframe Value Overlay: a new cross-timeframe value overlap appeared. This is an attention marker, not a trade instruction.")
alertcondition(alertOnConflict and conflictFire, "Cross-Timeframe Conflict", "Cross-Timeframe Value Overlay: selected timeframe value bands became disjoint. Review broader context.")
alertcondition(alertOnDominantLost and dominantLost, "Dominant Value Lost", "Cross-Timeframe Value Overlay: price left the dominant higher-timeframe value band. Review context before acting.")

plot(dvRate, "Break Follow Rate", color = accentColor, display = display.data_window)
````
