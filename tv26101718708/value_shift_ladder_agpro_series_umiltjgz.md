# Value Shift Ladder [AGPro Series]

- url: https://www.tradingview.com/script/UMiltjGZ-Value-Shift-Ladder-AGPro-Series/
- type: indicator
- pine_id: PUB;75564911636f4a5db8d9ed0a236c7c95
- version: 5.0

## Description

Value Shift Ladder [AGPro Series]

🔹 Overview

Value Shift Ladder is a market-structure mapping tool that extracts the most volume-accepted price shelves from a rolling lookback window and arranges them, in creation order, as the rungs of a ladder. Each rung is a volume-weighted zone where the market has recently spent the most time and traded the most contracts. The script then tracks how price interacts with every rung through a full Held → Broken → Reclaimed lifecycle and summarizes the entire chain into one readable ladder state: Rising, Falling, Mixed, Broken, Reclaiming, Building, or Neutral.

The goal is not to predict direction and not to produce buy or sell signals. The goal is to give the chart reader a continuously updated answer to one question: where is the market's current fair-value region, how is that region moving over time, and which prior value shelves are still relevant versus which have been abandoned. This makes the tool useful as a structural reference for volume-profile readers, auction-theory traders, and anyone who builds a bias from accepted-value migration rather than from trend lines or moving averages.


🔸 Unique Edge

Most volume-based tools either draw a single static profile snapshot, or plot every candidate level and leave the reader to filter. Value Shift Ladder does three things differently:

Multi-shelf chronological ladder. Instead of producing one value band, the script maintains a ranked set of up to eight volume-accepted shelves and arranges them in the order they were first registered. This preserves the migration history of accepted value instead of collapsing it into one average.

Proximity-gated visualization. Only shelves within a configurable ATR distance from current price are drawn on the chart, counted in the panel, and fed into the ladder direction state. Distant historical shelves exist in memory but do not clutter the chart or bias the readout — the ladder always reflects the value structure that is actually relevant to the current bar.

Adaptive, confidence-aware breaks. A shelf is not broken on a single close outside its band. Young shelves are strongly protected (3.0 × ATR), maturing shelves require a medium distance (1.5 × ATR), and fully-aged shelves use the user-defined break distance. Shelves that have been re-confirmed multiple times gain a 2× confidence multiplier on top of that, preventing established value regions from being lost to a single volatility spike.


🔸 Methodology

1) Volume Profile Construction
The script divides the rolling lookback window into equal price bins and distributes each bar's volume across every bin it touches, proportional to range coverage. Zero-range bars are assigned to their single bin. This produces a volume-weighted histogram of the lookback period.

2) Shelf Extraction
The top-K bins by volume are selected iteratively. After each pick, the chosen bin and its ATR-neighborhood are zeroed out before the next pick, enforcing a minimum separation between shelves and preventing a single high-volume cluster from dominating every rung. Each surviving bin becomes a shelf, anchored at its bin-center price.

3) Shelf Merging and Confidence
On every refresh, newly extracted shelves are checked against existing ones. If a new shelf falls within the ATR separation of an existing non-broken shelf, the existing shelf's volume is refreshed and its confidence score is incremented. Otherwise a new shelf is registered. Confidence is capped at ten and used downstream to scale break tolerance.

4) Lifecycle State Machine
Each shelf carries one of three states — Held, Broken, or Reclaimed. Held flips to Broken when price closes beyond an adaptive break distance for three recent bars. Broken flips to Reclaimed when price dwells back inside the band for a user-defined number of bars. Reclaimed auto-promotes to Held once the shelf has stabilized past a short age threshold.

5) Ladder Direction
Proximity-filtered active shelves are sorted by creation order. The last one, two, or three rungs are compared to produce a single state: Rising if the sequence is monotonically higher, Falling if lower, Mixed if non-monotonic, plus transient overrides for Broken, Reclaiming, Building, or Neutral conditions.

6) Pruning
Stale broken shelves expire after a timeframe-aware window. A hard cap of ten active shelves is enforced, with broken shelves removed first when the cap is hit.


🔹 Signals and Alerts

The script provides four deterministic state-change alerts, all tied to closed-bar transitions:

— New Ladder Step Formed: fires when a new volume-accepted shelf is first registered.
— Ladder Step Held: fires when an existing shelf is re-confirmed by the rolling profile.
— Ladder Step Broken: fires when a held shelf transitions to broken.
— Ladder Step Reclaimed: fires when a broken shelf transitions back to reclaimed.

These alerts describe structural state changes inside the indicator logic. They are not trade signals and do not imply expected profitability, win rate, or directional certainty.


🔸 Key Inputs

— Profile Mode (Auto / Manual): Auto derives lookback and refresh from the chart timeframe. Manual exposes both for full control.
— Manual Lookback (bars): Size of the rolling window used to build the profile.
— Manual Refresh Interval (bars): How often the profile is rebuilt.
— Profile Resolution (bins): Number of price bins the range is divided into.
— Target Shelf Count: Maximum number of shelves kept active.
— Min Volume Ratio: Minimum fraction of the top-bin volume a bin must hold to qualify as a shelf.
— Min Shelf Separation (ATR): Minimum ATR distance between two shelves.
— Break Distance (ATR): Fully-aged break tolerance.
— Reclaim Dwell Bars: Bars needed inside the band to flip Broken to Reclaimed.
— Max Visible Distance (ATR): Proximity gate for drawing and counting shelves.
— Display options: panel position, panel font size, on-chart label size, alerts toggle.


🔹 How to Use

Value Shift Ladder is designed as a structural reference rather than a signal engine. Typical reading workflows include:

— Bias framing. Read the Ladder state first. Rising or Falling indicates a one-sided migration of accepted value; Mixed indicates balance; Broken or Reclaiming highlights an active transition.
— Dominant reference. The Dominant row in the panel highlights the nearest held or reclaimed shelf within two ATR of price. Use it as the closest structural reference for scenario planning, not as an execution level.
— Proximity discipline. Because shelves more than the configured ATR distance away are not drawn, the ladder always reflects value structure that is currently relevant. When no shelves are visible, the market is between value regions — a context in which mean-reversion assumptions weaken.
— Confluence. The tool is designed to be combined with independent confirmation such as session structure, higher-timeframe bias, or volume analysis. It is not meant to stand alone as a decision source.


🔸 Limitations and Transparency

— Volume profile quality depends on the instrument's volume reporting. On symbols with unreliable or synthetic volume, shelf placement may drift.
— The profile is recomputed on the close of refresh bars. Intrabar readings on the current bar can change until the bar closes; state transitions evaluate the last three bars for breaks and the reclaim-dwell window for reclaims, so fresh transitions can flip until those bars close.
— On extremely illiquid sessions or instruments with frequent volatility spikes, the adaptive-break logic can delay transitions by design. This is a tradeoff in favor of stability.
— Past structural behavior at a shelf does not guarantee future behavior. The tool does not forecast direction and is not a trading strategy.


🔹 Risk Disclosure

This script is a structural visualization tool provided for educational and analytical purposes. It is not financial advice, not a trading strategy, and not a signal service. All trading involves risk of loss. Past market behavior is not indicative of future results. Users are fully responsible for their own trading decisions and for independently verifying the tool's behavior on their chosen instruments and timeframes before relying on it for any purpose.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Value Shift Ladder [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.5
//
// Value Shift Ladder maps volume-accepted value shelves across a rolling
// profile window and tracks how each shelf behaves through held, broken,
// and reclaimed states. It connects accepted value rungs into a visual
// ladder, highlights the dominant nearby value band, and summarizes whether
// value is rising, falling, mixed, building, breaking, or reclaiming. V2.5
// locks profile and lifecycle changes to closed bars and clarifies the dominant
// value badge without changing the accepted-value ladder methodology.
// ─────────────────────────────────────────────────

//@version=6
indicator("Value Shift Ladder [AGPro Series]",
     shorttitle       = "AG Pro VSL",
     overlay          = true,
     max_lines_count  = 320,
     max_labels_count = 260,
     max_boxes_count  = 90,
     max_bars_back    = 2000)

// ─────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────
gProfile = "Profile Engine"
profileMode = input.string("Auto", "Profile Mode", options = ["Auto", "Manual"], group = gProfile,
     tooltip = "Auto derives lookback and refresh values from the chart timeframe. Manual uses the custom values below.")
manualLookback = input.int(200, "Manual Lookback (bars)", minval = 50, maxval = 1000, step = 10, group = gProfile,
     tooltip = "Bars used to build the volume profile when Profile Mode is Manual.")
manualRefresh = input.int(10, "Manual Refresh Interval", minval = 1, maxval = 50, group = gProfile,
     tooltip = "How often the profile is rebuilt when Profile Mode is Manual.")
numBins = input.int(40, "Profile Resolution", minval = 20, maxval = 100, step = 5, group = gProfile,
     tooltip = "Number of price bins used for the rolling volume profile. Higher values create finer shelves.")
targetShelves = input.int(5, "Target Shelf Count", minval = 3, maxval = 8, group = gProfile,
     tooltip = "Maximum number of strongest accepted-value shelves selected from each profile build.")
minVolRatio = input.float(0.30, "Minimum Volume Ratio", minval = 0.10, maxval = 1.00, step = 0.05, group = gProfile,
     tooltip = "A shelf must have at least this fraction of the strongest bin's volume to qualify.")
minStepATR = input.float(0.80, "Minimum Shelf Separation (ATR)", minval = 0.30, maxval = 5.00, step = 0.05, group = gProfile,
     tooltip = "Minimum ATR distance between two accepted-value shelves.")

gState = "State Machine"
breakATR = input.float(0.75, "Break Distance (ATR)", minval = 0.20, maxval = 3.00, step = 0.05, group = gState,
     tooltip = "Distance from a shelf required before the shelf can be classified as broken.")
breakConfirmBars = input.int(3, "Break Confirm Bars", minval = 1, maxval = 5, group = gState,
     tooltip = "Number of recent closes that must remain beyond the break distance before a shelf flips to Broken.")
reclaimDwell = input.int(5, "Reclaim Dwell Bars", minval = 2, maxval = 30, group = gState,
     tooltip = "Minimum bars back around a broken shelf before it can be classified as Reclaimed.")
proximityATR = input.float(8.0, "Max Visible Distance (ATR)", minval = 2.0, maxval = 30.0, step = 0.5, group = gState,
     tooltip = "Only shelves within this ATR distance from price are drawn and counted in the ladder state.")
breakWindow = input.int(20, "Break Follow Proof Window (bars)", minval = 5, maxval = 200, group = gState,
     tooltip = "Number of bars a shelf break has to follow through in the break direction within, for the Break Follow Rate proof. It only measures historical follow-through and is not a forecast.")

gVisual = "Visuals"
showActiveBand = input.bool(true, "Show Dominant Value Band", group = gVisual,
     tooltip = "Highlights the nearest active value shelf as a soft band with a centered premium ladder-state badge.")
showRisers = input.bool(true, "Show Ladder Connectors", group = gVisual,
     tooltip = "Connects visible shelves chronologically so value migration can be read as a ladder.")
showEventLabels = input.bool(true, "Show Event Labels", group = gVisual,
     tooltip = "Shows spaced labels for important shelf events. Default settings keep the chart clean while still leaving enough visual context for publication screenshots.")
showBrokenEventLabels = input.bool(false, "Show Broken Event Labels", group = gVisual,
     tooltip = "When enabled, broken shelf events also receive historical labels. Off by default because broken shelves already remain visible on the right edge and can otherwise crowd the chart.")
labelDensity = input.string("Minimal", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = gVisual,
     tooltip = "Controls how many event labels remain visible. Minimal keeps the default public-release chart compact.")
eventLabelSpacing = input.int(44, "Event Label Spacing", minval = 3, maxval = 120, group = gVisual,
     tooltip = "Minimum bars between event labels.")
eventLabelOffsetATR = input.float(0.85, "Event Label ATR Offset", minval = 0.30, maxval = 3.00, step = 0.05, group = gVisual,
     tooltip = "ATR-based distance used to keep historical event badges clear of candle bodies.")
projectionBars = input.int(28, "Right Projection Bars", minval = 8, maxval = 80, group = gVisual,
     tooltip = "How far shelf lines and right-edge labels extend beyond the latest bar.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gVisual,
     tooltip = "Controls on-chart label and badge size.")

gPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = gPanel,
     tooltip = "Shows the compact ladder panel with workflow, ladder state, active steps, dominant value, confidence, break follow rate, and latest event.")
panelPosition = input.string("Top Right", "Panel Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gPanel,
     tooltip = "Controls where the panel is anchored.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = gPanel,
     tooltip = "Switches the panel color scheme for dark or light chart backgrounds.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gPanel,
     tooltip = "Controls panel font size.")

gAlerts = "Alerts"
enableAlerts = input.bool(true, "Enable Alerts", group = gAlerts,
     tooltip = "Master toggle for new step, held, broken and reclaimed ladder alerts.")

// ─────────────────────────────────────────────────
// AGPro Color Palette
// ─────────────────────────────────────────────────
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

isLightTheme = panelTheme == "Light"
panelBg = isLightTheme ? panelBgLight : panelBgDark
panelBorder = isLightTheme ? panelBorderL : panelBorderD
panelLabelCol = isLightTheme ? panelLabelL : panelLabelD
panelValueCol = isLightTheme ? panelValueL : panelValueD
panelAltBg = isLightTheme ? color.rgb(241, 245, 249) : color.rgb(24, 35, 55)
darkText = color.rgb(17, 24, 39)

// ─────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────
HELD = 0
BROKEN = 1
RECLAIMED = 2
MAX_BINS = 100
MAX_SHELVES = 12
CONFIDENCE_MAX = 10

f_size(string s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge"  => size.huge
        => size.normal

f_pos(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Middle Right"  => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left"   => position.middle_left
        "Bottom Right"  => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left"   => position.bottom_left
        => position.top_right

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_state_text(int st) =>
    st == BROKEN ? "Broken" : st == RECLAIMED ? "Reclaimed" : "Held"

f_state_short(int st) =>
    st == BROKEN ? "BRK" : st == RECLAIMED ? "RECL" : "HOLD"

f_state_color(int st) =>
    st == BROKEN ? bearColor : st == RECLAIMED ? accentColor : neutralColor

f_ladder_color(string s) =>
    s == "RISING" ? bullColor :
     s == "FALLING" ? bearColor :
     s == "BROKEN" ? bearColor :
     s == "RECLAIMING" ? accentColor :
     s == "MIXED" ? neutralColor :
     neutralColor

f_workflow_text(string s) =>
    s == "RISING" ? "Track value up" :
     s == "FALLING" ? "Track value down" :
     s == "BROKEN" ? "Review break" :
     s == "RECLAIMING" ? "Review reclaim" :
     s == "MIXED" ? "Map rotation" :
     s == "BUILDING" ? "Build ladder" :
     "Wait value"

f_badge_text_color(string s) =>
    s == "BUILDING" or s == "NEUTRAL" or s == "MIXED" ? darkText : headerText

f_auto_lookback(int sec) =>
    sec <= 3600 ? 150 : sec <= 43200 ? 200 : 120

f_auto_refresh(int sec) =>
    sec <= 3600 ? 5 : sec <= 43200 ? 10 : 15

f_auto_expire(int sec) =>
    sec <= 3600 ? 80 : sec <= 43200 ? 60 : 40

panelSize = f_size(panelSizeInput)
labelSize = f_size(labelSizeInput)
maxEventLabels = labelDensity == "Detailed" ? 18 : labelDensity == "Balanced" ? 10 : 6

// ─────────────────────────────────────────────────
// Runtime Series
// ─────────────────────────────────────────────────
tfSec = timeframe.in_seconds(timeframe.period)
isHighTimeframeView = tfSec >= 86400
lookbackBars = profileMode == "Auto" ? f_auto_lookback(tfSec) : manualLookback
refreshBars = profileMode == "Auto" ? f_auto_refresh(tfSec) : manualRefresh
brokenExpireBars = f_auto_expire(tfSec)
atr = ta.atr(14)
proxLimit = atr * proximityATR

// ─────────────────────────────────────────────────
// Shelf Storage
// ─────────────────────────────────────────────────
var array<float> shelfPrice = array.new<float>()
var array<float> shelfVol = array.new<float>()
var array<int> shelfBorn = array.new<int>()
var array<int> shelfState = array.new<int>()
var array<int> shelfOrder = array.new<int>()
var array<int> shelfConf = array.new<int>()

var array<line> shelfLines = array.new<line>()
var array<label> shelfTags = array.new<label>()
var array<line> riserLines = array.new<line>()
var array<label> eventLabels = array.new<label>()

var box dominantBand = na
var label dominantBandLabel = na
var int orderCounter = 0
var int activeIdx = -1

var bool sigNew = false
var bool sigHeld = false
var bool sigBroken = false
var bool sigReclaim = false
var string lastEventText = "Waiting"
var color lastEventColor = panelLabelCol
var int lastEventLabelBar = na

// Break-follow proof state
var int bfTotal = 0
var int bfWon = 0
var bool bfPend = false
var int bfDir = 0
var float bfAnchor = na
var float bfShelf = na
var int bfLeft = 0

f_keep_event_label(label id) =>
    array.push(eventLabels, id)
    while array.size(eventLabels) > maxEventLabels
        old = array.shift(eventLabels)
        if not na(old)
            label.delete(old)

// ─────────────────────────────────────────────────
// Volume Profile Builder
// ─────────────────────────────────────────────────
f_build_profile() =>
    int lbk = math.min(lookbackBars, bar_index)
    array<float> outPrice = array.new<float>()
    array<float> outVol = array.new<float>()
    if lbk >= 20 and not na(atr) and atr > 0
        float hi = -1e20
        float lo = 1e20
        for i = 0 to lbk - 1
            hi := math.max(hi, high[i])
            lo := math.min(lo, low[i])

        float span = hi - lo
        if span > syminfo.mintick
            int bins = math.min(numBins, MAX_BINS)
            float binSize = span / bins
            array<float> binVol = array.new<float>(bins, 0.0)

            for i = 0 to lbk - 1
                h = high[i]
                l = low[i]
                v = nz(volume[i])
                if v > 0
                    int firstBin = math.max(0, math.min(bins - 1, int(math.floor((l - lo) / binSize))))
                    int lastBin = math.max(0, math.min(bins - 1, int(math.floor((h - lo) / binSize))))
                    int touched = math.max(1, lastBin - firstBin + 1)
                    float addVol = v / touched
                    for b = firstBin to lastBin
                        array.set(binVol, b, array.get(binVol, b) + addVol)

            float maxBinVol = 0.0
            for b = 0 to bins - 1
                maxBinVol := math.max(maxBinVol, array.get(binVol, b))

            int needed = math.min(targetShelves, MAX_SHELVES)
            float minGap = atr * minStepATR
            for k = 0 to needed - 1
                float curMax = 0.0
                int curIdx = -1
                for b = 0 to bins - 1
                    bv = array.get(binVol, b)
                    if bv > curMax
                        curMax := bv
                        curIdx := b
                if curIdx < 0 or curMax < maxBinVol * minVolRatio
                    break

                center = lo + (curIdx + 0.5) * binSize
                array.push(outPrice, center)
                array.push(outVol, curMax)

                gapBins = math.max(1, int(math.ceil(minGap / binSize)))
                loBin = math.max(0, curIdx - gapBins)
                hiBin = math.min(bins - 1, curIdx + gapBins)
                for b = loBin to hiBin
                    array.set(binVol, b, 0.0)
    [outPrice, outVol]

// ─────────────────────────────────────────────────
// Rebuild And Merge Shelves
// ─────────────────────────────────────────────────
sigNew := false
sigHeld := false
sigBroken := false
sigReclaim := false

doRebuild = barstate.isconfirmed and bar_index > 0 and bar_index % refreshBars == 0

if doRebuild
    [profilePrices, profileVols] = f_build_profile()
    np = array.size(profilePrices)
    if np > 0
        for k = 0 to np - 1
            pp = array.get(profilePrices, k)
            pv = array.get(profileVols, k)
            found = false
            if array.size(shelfPrice) > 0
                for i = 0 to array.size(shelfPrice) - 1
                    st = array.get(shelfState, i)
                    if st != BROKEN and math.abs(array.get(shelfPrice, i) - pp) <= atr * minStepATR
                        oldPrice = array.get(shelfPrice, i)
                        oldConf = array.get(shelfConf, i)
                        newConf = math.min(CONFIDENCE_MAX, oldConf + 1)
                        blendedPrice = (oldPrice * oldConf + pp) / math.max(newConf, 1)
                        array.set(shelfPrice, i, blendedPrice)
                        array.set(shelfVol, i, pv)
                        array.set(shelfConf, i, newConf)
                        sigHeld := true
                        found := true
                        break
            if not found
                orderCounter += 1
                array.push(shelfPrice, pp)
                array.push(shelfVol, pv)
                array.push(shelfBorn, bar_index)
                array.push(shelfState, HELD)
                array.push(shelfOrder, orderCounter)
                array.push(shelfConf, 1)
                sigNew := true

// ─────────────────────────────────────────────────
// State Transitions
// ─────────────────────────────────────────────────
int barBreakDir = 0
float barBreakPrice = na

if barstate.isconfirmed and array.size(shelfPrice) > 0 and not na(atr)
    for i = 0 to array.size(shelfPrice) - 1
        pp = array.get(shelfPrice, i)
        st = array.get(shelfState, i)
        born = array.get(shelfBorn, i)
        conf = array.get(shelfConf, i)
        age = bar_index - born
        confMult = conf >= 3 ? 1.60 : conf >= 2 ? 1.25 : 1.0
        matureMult = age < 30 ? 1.80 : age < 60 ? 1.30 : 1.0
        brkDist = atr * breakATR * confMult * matureMult
        bandHalf = atr * 0.50

        if st == HELD
            away = 0
            for k = 0 to breakConfirmBars - 1
                if close[k] > pp + brkDist or close[k] < pp - brkDist
                    away += 1
            if away >= breakConfirmBars
                array.set(shelfState, i, BROKEN)
                array.set(shelfBorn, i, bar_index)
                sigBroken := true
                if barBreakDir == 0
                    barBreakDir := close > pp ? 1 : -1
                    barBreakPrice := pp

        if st == BROKEN
            back = 0
            dwellLookback = math.min(reclaimDwell + 3, bar_index + 1)
            for k = 0 to dwellLookback - 1
                if close[k] >= pp - bandHalf and close[k] <= pp + bandHalf
                    back += 1
            if back >= reclaimDwell
                array.set(shelfState, i, RECLAIMED)
                array.set(shelfBorn, i, bar_index)
                sigReclaim := true

        if st == RECLAIMED and age > 10 and close >= pp - bandHalf and close <= pp + bandHalf
            array.set(shelfState, i, HELD)

// ─────────────────────────────────────────────────
// Prune Old Broken Shelves And Hard Cap
// ─────────────────────────────────────────────────
if array.size(shelfPrice) > 0
    i = array.size(shelfPrice) - 1
    while i >= 0
        if array.get(shelfState, i) == BROKEN and bar_index - array.get(shelfBorn, i) > brokenExpireBars
            array.remove(shelfPrice, i)
            array.remove(shelfVol, i)
            array.remove(shelfBorn, i)
            array.remove(shelfState, i)
            array.remove(shelfOrder, i)
            array.remove(shelfConf, i)
        i -= 1

while array.size(shelfPrice) > MAX_SHELVES
    removeIdx = 0
    foundBroken = false
    for i = 0 to array.size(shelfPrice) - 1
        if array.get(shelfState, i) == BROKEN
            removeIdx := i
            foundBroken := true
            break
    array.remove(shelfPrice, removeIdx)
    array.remove(shelfVol, removeIdx)
    array.remove(shelfBorn, removeIdx)
    array.remove(shelfState, removeIdx)
    array.remove(shelfOrder, removeIdx)
    array.remove(shelfConf, removeIdx)
    if not foundBroken and array.size(shelfPrice) <= MAX_SHELVES
        break

// ─────────────────────────────────────────────────
// Break-follow-rate proof (Confirm Rate)
// ─────────────────────────────────────────────────
float bfMargin = nz(atr, syminfo.mintick * 20.0) * 0.75

if barstate.isconfirmed
    if bfPend and not na(bfAnchor)
        bool favHit = bfDir == 1 ? close >= bfAnchor + bfMargin : close <= bfAnchor - bfMargin
        bool reclaimHit = not na(bfShelf) and (bfDir == 1 ? close < bfShelf : close > bfShelf)
        bool advMove = bfDir == 1 ? close <= bfAnchor - bfMargin : close >= bfAnchor + bfMargin
        bool advHit = reclaimHit or advMove
        if favHit
            bfTotal += 1
            bfWon += 1
            bfPend := false
        else if advHit
            bfTotal += 1
            bfPend := false
        else
            bfLeft -= 1
            if bfLeft <= 0
                bfTotal += 1
                bfPend := false
    if sigBroken and barBreakDir != 0 and not bfPend
        bfPend := true
        bfDir := barBreakDir
        bfAnchor := close
        bfShelf := barBreakPrice
        bfLeft := breakWindow

float bfRate = bfTotal > 0 ? bfWon / bfTotal * 100.0 : na

// ─────────────────────────────────────────────────
// Active Shelf And Ladder State
// ─────────────────────────────────────────────────
activeIdx := -1
bestDist = 1e20
if array.size(shelfPrice) > 0
    for i = 0 to array.size(shelfPrice) - 1
        st = array.get(shelfState, i)
        pp = array.get(shelfPrice, i)
        if (st == HELD or st == RECLAIMED) and math.abs(close - pp) <= proxLimit
            d = math.abs(close - pp)
            if d < bestDist
                bestDist := d
                activeIdx := i

var array<float> seqPrice = array.new<float>()
var array<int> seqOrder = array.new<int>()
array.clear(seqPrice)
array.clear(seqOrder)

if array.size(shelfPrice) > 0
    for i = 0 to array.size(shelfPrice) - 1
        st = array.get(shelfState, i)
        pp = array.get(shelfPrice, i)
        if (st == HELD or st == RECLAIMED) and math.abs(close - pp) <= proxLimit
            array.push(seqPrice, pp)
            array.push(seqOrder, array.get(shelfOrder, i))

seqSize = array.size(seqPrice)
if seqSize > 1
    for i = 0 to seqSize - 2
        for k = 0 to seqSize - 2 - i
            if array.get(seqOrder, k) > array.get(seqOrder, k + 1)
                oA = array.get(seqOrder, k)
                oB = array.get(seqOrder, k + 1)
                pA = array.get(seqPrice, k)
                pB = array.get(seqPrice, k + 1)
                array.set(seqOrder, k, oB)
                array.set(seqOrder, k + 1, oA)
                array.set(seqPrice, k, pB)
                array.set(seqPrice, k + 1, pA)

ladderState = "NEUTRAL"
if sigReclaim
    ladderState := "RECLAIMING"
else if sigBroken
    ladderState := "BROKEN"
else if seqSize == 1
    ladderState := "BUILDING"
else if seqSize >= 2
    rises = 0
    falls = 0
    for i = 1 to seqSize - 1
        cur = array.get(seqPrice, i)
        prv = array.get(seqPrice, i - 1)
        if cur > prv
            rises += 1
        else if cur < prv
            falls += 1
    ladderState := rises > 0 and falls == 0 ? "RISING" : falls > 0 and rises == 0 ? "FALLING" : "MIXED"

ladderColor = f_ladder_color(ladderState)
workflowText = f_workflow_text(ladderState)

if sigReclaim
    lastEventText := "Reclaim"
    lastEventColor := accentColor
else if sigNew
    lastEventText := "New step"
    lastEventColor := bullColor
else if sigBroken
    lastEventText := "Break"
    lastEventColor := bearColor
else if sigHeld
    lastEventText := "Held"
    lastEventColor := neutralColor

visibleActive = 0
confidenceSum = 0
if array.size(shelfPrice) > 0
    for i = 0 to array.size(shelfPrice) - 1
        st = array.get(shelfState, i)
        pp = array.get(shelfPrice, i)
        if (st == HELD or st == RECLAIMED) and math.abs(close - pp) <= proxLimit
            visibleActive += 1
            confidenceSum += array.get(shelfConf, i)

avgConfidence = visibleActive > 0 ? int(math.round(confidenceSum / visibleActive)) : 0
domText = activeIdx >= 0 ? str.tostring(array.get(shelfPrice, activeIdx), format.mintick) : "-"
activeText = str.tostring(math.min(visibleActive, targetShelves)) + " / " + str.tostring(targetShelves)
bfRateText = bfTotal > 0 ? str.tostring(math.round(bfRate)) + "% (" + str.tostring(bfTotal) + ")" : "Building"
bfRateColor = na(bfRate) ? panelValueCol : bfRate >= 60.0 ? bullColor : bfRate >= 45.0 ? neutralColor : bearColor

// ─────────────────────────────────────────────────
// Event Labels
// ─────────────────────────────────────────────────
eventLabelOk = showEventLabels and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= eventLabelSpacing)
labelOffset = nz(atr, syminfo.mintick) * eventLabelOffsetATR

if eventLabelOk and sigNew
    lb = label.new(bar_index, low - labelOffset, "NEW STEP", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(bullColor, 5), textcolor = headerText, size = labelSize)
    f_keep_event_label(lb)
    lastEventLabelBar := bar_index

if eventLabelOk and showBrokenEventLabels and sigBroken
    lb = label.new(bar_index, high + labelOffset, "BREAK", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(bearColor, 5), textcolor = headerText, size = labelSize)
    f_keep_event_label(lb)
    lastEventLabelBar := bar_index

if eventLabelOk and sigReclaim
    lb = label.new(bar_index, low - labelOffset, "RECLAIM", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(accentColor, 5), textcolor = headerText, size = labelSize)
    f_keep_event_label(lb)
    lastEventLabelBar := bar_index

// ─────────────────────────────────────────────────
// Visual Rendering
// ─────────────────────────────────────────────────
if barstate.islast
    if array.size(shelfLines) > 0
        for i = 0 to array.size(shelfLines) - 1
            line.delete(array.get(shelfLines, i))
    if array.size(shelfTags) > 0
        for i = 0 to array.size(shelfTags) - 1
            label.delete(array.get(shelfTags, i))
    if array.size(riserLines) > 0
        for i = 0 to array.size(riserLines) - 1
            line.delete(array.get(riserLines, i))
    array.clear(shelfLines)
    array.clear(shelfTags)
    array.clear(riserLines)

    array<int> drawIdx = array.new<int>()
    if array.size(shelfPrice) > 0
        for i = 0 to array.size(shelfPrice) - 1
            if math.abs(close - array.get(shelfPrice, i)) <= proxLimit
                array.push(drawIdx, i)

    drawSize = array.size(drawIdx)
    if drawSize > 1
        for i = 0 to drawSize - 2
            for k = 0 to drawSize - 2 - i
                ia = array.get(drawIdx, k)
                ib = array.get(drawIdx, k + 1)
                if array.get(shelfOrder, ia) > array.get(shelfOrder, ib)
                    array.set(drawIdx, k, ib)
                    array.set(drawIdx, k + 1, ia)

    visLimit = isHighTimeframeView ? 4 : math.min(targetShelves + 1, MAX_SHELVES)
    while array.size(drawIdx) > visLimit
        array.shift(drawIdx)
    drawSize := array.size(drawIdx)

    rightX = bar_index + projectionBars
    tagRightX = rightX + 7

    if drawSize > 0
        for d = 0 to drawSize - 1
            idx = array.get(drawIdx, d)
            pp = array.get(shelfPrice, idx)
            st = array.get(shelfState, idx)
            born = array.get(shelfBorn, idx)
            conf = array.get(shelfConf, idx)
            baseCol = f_state_color(st)
            isActive = idx == activeIdx
            lineWidth = isActive ? 3 : conf >= 3 ? 2 : 1
            lineStyle = st == BROKEN ? line.style_dotted : line.style_solid
            lineCol = st == BROKEN ? color.new(panelLabelCol, 50) : color.new(baseCol, isActive ? 0 : 16)

            ln = line.new(born, pp, tagRightX, pp, xloc = xloc.bar_index, color = lineCol, width = lineWidth, style = lineStyle)
            array.push(shelfLines, ln)

            tagText = (isActive ? "DOM " : f_state_short(st) + " ") + str.tostring(pp, format.mintick)
            tagBg = st == BROKEN ? color.new(panelLabelCol, 35) : color.new(baseCol, isActive ? 0 : 8)
            tagTextCol = st == HELD ? darkText : headerText
            tagLane = isHighTimeframeView ? atr * 0.38 * (d - math.floor(drawSize * 0.5)) : 0.0
            tagY = isActive ? pp + atr * 0.55 : pp + tagLane
            tag = label.new(tagRightX, tagY, tagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = tagBg, textcolor = tagTextCol, size = labelSize)
            array.push(shelfTags, tag)

        if showRisers and drawSize > 1
            for d = 0 to drawSize - 2
                i1 = array.get(drawIdx, d)
                i2 = array.get(drawIdx, d + 1)
                x = array.get(shelfBorn, i2)
                y1 = array.get(shelfPrice, i1)
                y2 = array.get(shelfPrice, i2)
                rCol = y2 > y1 ? color.new(bullColor, 50) : y2 < y1 ? color.new(bearColor, 50) : color.new(panelLabelCol, 60)
                rl = line.new(x, y1, x, y2, xloc = xloc.bar_index, color = rCol, width = 1, style = line.style_dashed)
                array.push(riserLines, rl)

    if showActiveBand and activeIdx >= 0
        domPx = array.get(shelfPrice, activeIdx)
        bandHalf = math.max(atr * 0.35, syminfo.mintick * 20.0)
        leftX = math.max(0, bar_index - math.max(30, projectionBars * 2))
        centerX = int(math.round((leftX + rightX) / 2.0))
        top = domPx + bandHalf
        bottom = domPx - bandHalf
        bandBg = color.new(ladderColor, 88)
        bandBorder = color.new(ladderColor, 35)
        if na(dominantBand)
            dominantBand := box.new(leftX, top, rightX, bottom, xloc = xloc.bar_index, bgcolor = bandBg, border_color = bandBorder, border_width = 1, text = "")
        else
            box.set_lefttop(dominantBand, leftX, top)
            box.set_rightbottom(dominantBand, rightX, bottom)
            box.set_bgcolor(dominantBand, bandBg)
            box.set_border_color(dominantBand, bandBorder)
            box.set_text(dominantBand, "")

        centerText = ladderState + " | C" + str.tostring(avgConfidence) + "\nVALUE " + domText
        labelY = domPx
        if na(dominantBandLabel)
            dominantBandLabel := label.new(centerX, labelY, centerText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(ladderColor, 4), textcolor = f_badge_text_color(ladderState), size = labelSize, textalign = text.align_center)
        else
            label.set_xy(dominantBandLabel, centerX, labelY)
            label.set_text(dominantBandLabel, centerText)
            label.set_color(dominantBandLabel, color.new(ladderColor, 4))
            label.set_textcolor(dominantBandLabel, f_badge_text_color(ladderState))
            label.set_size(dominantBandLabel, labelSize)
    else
        if not na(dominantBand)
            box.delete(dominantBand)
            dominantBand := na
        if not na(dominantBandLabel)
            label.delete(dominantBandLabel)
            dominantBandLabel := na

// ─────────────────────────────────────────────────
// Panel
// ─────────────────────────────────────────────────
var table panel = na
var string lastPanelPosition = ""
var string lastPanelTheme = ""

if barstate.islast
    if showPanel
        if na(panel) or panelPosition != lastPanelPosition or panelTheme != lastPanelTheme
            if not na(panel)
                table.delete(panel)
            panel := table.new(f_pos(panelPosition), 2, 8, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
            lastPanelPosition := panelPosition
            lastPanelTheme := panelTheme
        table.clear(panel, 0, 0, 1, 7)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Value Shift Ladder", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)

        table.cell(panel, 0, 1, "Workflow", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 1, workflowText, text_color = f_badge_text_color(ladderState), bgcolor = ladderColor, text_size = panelSize, text_halign = text.align_right)

        table.cell(panel, 0, 2, "Ladder", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 2, ladderState, text_color = f_badge_text_color(ladderState), bgcolor = ladderColor, text_size = panelSize, text_halign = text.align_right)

        table.cell(panel, 0, 3, "Active Steps", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 3, activeText, text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

        table.cell(panel, 0, 4, "Dominant Value", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 4, domText, text_color = panelValueCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

        table.cell(panel, 0, 5, "Confidence", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 5, str.tostring(avgConfidence) + " / 10", text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

        table.cell(panel, 0, 6, "Break Follow", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 6, bfRateText, text_color = bfRateColor, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

        table.cell(panel, 0, 7, "Last Event", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 7, lastEventText, text_color = lastEventText == "Held" ? darkText : headerText, bgcolor = lastEventColor, text_size = panelSize, text_halign = text.align_right)
    else if not na(panel)
        table.delete(panel)
        panel := na
        lastPanelPosition := ""
        lastPanelTheme := ""

// ─────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────
alertcondition(barstate.isconfirmed and enableAlerts and sigNew, "New Ladder Step Formed", "Value Shift Ladder: new accepted value step formed for review.")
alertcondition(barstate.isconfirmed and enableAlerts and sigHeld, "Ladder Step Held", "Value Shift Ladder: existing accepted value step held.")
alertcondition(barstate.isconfirmed and enableAlerts and sigBroken, "Ladder Step Broken", "Value Shift Ladder: accepted value step broken.")
alertcondition(barstate.isconfirmed and enableAlerts and sigReclaim, "Ladder Step Reclaimed", "Value Shift Ladder: broken value step reclaimed.")

// Hidden reference plot
plot(bfRate, "Break Follow Rate", display = display.none)
````
