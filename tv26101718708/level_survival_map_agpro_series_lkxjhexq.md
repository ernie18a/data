# Level Survival Map [AGPro Series]

- url: https://www.tradingview.com/script/lKXjHExQ-Level-Survival-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;26d4a046e4fc47218afcebf9108903c0
- version: 3.0

## Description

Level Survival Map [AGPro Series]

🔹 Overview

Level Survival Map is a premium support and resistance framework that does not just draw lines on the chart. Every detected level carries a live Survival Score between 0 and 100 that answers one simple question: how well is this level still defending itself right now. The map highlights a single Active Level with an interaction zone and a forward projection ribbon, while nearby weaker levels fade, so traders always know which level actually matters for the current decision.

🔸 Unique Edge

Most support and resistance tools either show static pivots or basic break or retest events. Level Survival Map goes further by measuring the quality of every interaction and turning it into a single composite health score per level. Instead of being left with a wall of equally important lines, the trader sees a ranked structural battlefield with one clearly identified Active Level, a visible interaction zone and a projection ribbon for planning. The Damage State readout, the Fresh and Eroded state semantics, the automatic flip from broken support to new resistance and the cluster fade for crowded weaker levels are designed to work together as one premium, low-noise workflow.

🔹 Methodology

Pivot detection builds the raw candidate levels from swing highs and swing lows using the standard pivot window. A merge filter removes duplicates that sit within a configurable ATR distance of an existing same-type level. Each active level then accumulates four independent components over time. Close Respect rewards closes that respect the level side, for example closes above a support. Penetration Damage penalises wicks and bodies that pierce through the level zone. Reaction Quality rewards strong rejection wicks and bodies moving away from the level after a test. Test Fatigue penalises repeated tests because levels tend to weaken with each new hit. These four components are weighted and combined into a single Survival Score, then clamped between 0 and 100. A structural break caps the score at 35, heavy damage across multiple tests caps it at 28, and a confirmed sequence of opposite-side closes flips the level type while resetting its history. The Active Level is chosen as the closest same-side level to price so that the focus always follows the real decision point.

🔸 Signals and Alerts

The visual output itself is the primary signal. Line colour and thickness communicate level strength at a glance. A focused Active Level is drawn with an interaction zone, a darker core band and a forward projection ribbon so that traders can see the exact price band where reaction is most likely, and how far into the future that band is expected to remain relevant. Labels carry the Survival Score directly, so the ranking of levels is always visible without opening any settings. Broken levels switch to a dashed style and faded colour, and once enough opposite-side closes accumulate they flip type automatically, giving a clear visual signature of structural change.

🔹 Key Inputs

Pivot Left Bars and Pivot Right Bars control how strict the swing detection is. Max Active Levels caps how many concurrent levels are tracked. Level Merge Distance and Interaction Zone are expressed in ATR units so the logic adapts across timeframes and instruments. Scoring weights for Close Respect, Penetration Damage, Reaction Quality and Test Fatigue can be tuned independently, together with the fatigue penalty per extra test and the number of closes required to confirm a flip. Visual inputs cover panel position, label size, line width, focus emphasis, non-focus transparency, cluster fade, focus zone width and projection ribbon length and thickness. A Clean Map Mode is provided for screenshot and publishing workflows where only the Active Level and the nearest valid support and resistance are labelled.

🔸 How to Use

Read the map top down. First, look at the summary panel for the Active Level, its Survival Score, Test Count and Damage State. A Fresh or Strong Active Level defending its side is a high-quality decision point. A Fragile or Eroded Active Level with a Severe Damage State is a warning that the next level below or above is likely to take over. Use the projection ribbon as a planning band for reaction rather than a mechanical entry. Use the ranked non-Active labels to understand where price is likely to travel if the Active Level gives way. The tool is designed to be used as a visual framework, in combination with the trader own execution method, trend context and risk management.

🔹 Limitations and Transparency

This indicator is a visual analytical framework, not a strategy, not a signal service and not financial advice. Survival Score, Damage State and flip logic are deterministic functions of price action and ATR, so different markets and timeframes will produce different characteristic score ranges. Pivot based detection is inherently lagging by the Pivot Right Bars window, which is the expected behaviour of any structural tool and not a defect. The Active Level projection ribbon is a visual planning aid, not a forecast. Past level behaviour does not guarantee future behaviour.

🔸 Risk Disclosure

Trading involves substantial risk and is not suitable for every investor. This script is published for educational and analytical purposes only. Users are solely responsible for their own trading decisions, position sizing and risk management. Always test any tool on your own instruments and timeframes before using it in a live environment.

## Source Code

````pine
// -----------------------------------------------------
// Level Survival Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.9
//
// Adaptive support and resistance map with a per-level Survival Score that
// combines close respect, penetration damage, reaction quality and test
// fatigue. A single Active Level is highlighted with an interaction zone,
// centered ownership badge, and forward projection ribbon while nearby weaker
// levels fade for a premium, low-noise read of structural support and
// resistance behavior. A stop-aware Defense Rate reports how often tested
// levels closed back on the defended side, and an Action read summarizes what
// the current Active Level is doing now.
//
// Version 1.9: luminance-aware text contrast on every badge and label, a
// global Defense Rate proof layer, a decision-oriented panel with an Action
// read, removal of redundant Active-Level labelling, and consistent use of the
// label font-size setting.
// -----------------------------------------------------

//@version=6
indicator("Level Survival Map [AGPro Series]",
     shorttitle     = "AG Pro LSM",
     overlay        = true,
     max_lines_count  = 300,
     max_labels_count = 300,
     max_boxes_count  = 50,
     max_bars_back    = 500)

// -----------------------------------------------------
// AGPro Color Palette
// -----------------------------------------------------
AGPRO_HEADER_BG     = color.rgb(37, 99, 235)
AGPRO_HEADER_TEXT   = color.rgb(245, 247, 250)
AGPRO_PANEL_BG      = color.rgb(15, 23, 42)
AGPRO_PANEL_BORDER  = color.rgb(51, 65, 85)
AGPRO_LABEL_COL     = color.rgb(148, 163, 184)
AGPRO_VALUE_COL     = color.rgb(226, 232, 240)
AGPRO_BULL          = color.rgb(34, 197, 166)
AGPRO_BEAR          = color.rgb(244, 114, 182)
AGPRO_NEUTRAL       = color.rgb(245, 189, 92)
AGPRO_ACCENT        = color.rgb(129, 140, 248)
AGPRO_DARK_INK      = color.rgb(15, 23, 42)

// -----------------------------------------------------
// Inputs
// -----------------------------------------------------
groupLevels  = "Level Detection"
groupScoring = "Scoring"
groupVisuals = "Visuals"
groupPanel   = "Panel"

leftBars        = input.int(4,  "Pivot Left Bars",  minval = 1, group = groupLevels,
     tooltip = "Bars required to the left of a pivot for it to qualify as a new structural level candidate.")
rightBars       = input.int(4,  "Pivot Right Bars", minval = 1, group = groupLevels,
     tooltip = "Bars required to the right of a pivot for confirmation. Higher values produce fewer, more reliable levels.")
maxActiveLevels = input.int(8,  "Max Active Levels", minval = 2, maxval = 20, group = groupLevels,
     tooltip = "Maximum number of concurrent tracked levels. Oldest levels are dropped when this cap is exceeded.")
mergeAtrMult    = input.float(0.30, "Level Merge Distance (ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = groupLevels,
     tooltip = "New pivots closer than this ATR multiple to an existing same-type level are merged to avoid clutter.")
zoneAtrMult     = input.float(0.18, "Interaction Zone (ATR)", minval = 0.05, maxval = 1.0, step = 0.01, group = groupLevels,
     tooltip = "Half-width of the interaction band around a level, expressed as an ATR multiple. Used for touch, respect and damage calculations.")
atrLength       = input.int(14, "ATR Length", minval = 1, group = groupLevels,
     tooltip = "ATR lookback used for distance, zone width and projection sizing.")

closeRespectWeight   = input.float(0.35, "Weight: Close Respect", minval = 0.05, maxval = 1.0, step = 0.05, group = groupScoring,
     tooltip = "Reward for closes that respect the level's side, such as closes above support or below resistance.")
penetrationWeight    = input.float(0.30, "Weight: Penetration Damage", minval = 0.05, maxval = 1.0, step = 0.05, group = groupScoring,
     tooltip = "Penalty for wicks and bodies that pierce through the level zone.")
reactionWeight       = input.float(0.20, "Weight: Reaction Quality", minval = 0.05, maxval = 1.0, step = 0.05, group = groupScoring,
     tooltip = "Reward for strong rejection wicks and bodies away from the level after a test.")
fatigueWeight        = input.float(0.15, "Weight: Test Fatigue", minval = 0.05, maxval = 1.0, step = 0.05, group = groupScoring,
     tooltip = "Penalty that grows with repeated tests; captures the idea that levels weaken as they are hit again and again.")
fatiguePenaltyPerTest = input.float(14.0, "Fatigue Penalty Per Extra Test", minval = 1.0, maxval = 40.0, step = 1.0, group = groupScoring,
     tooltip = "Points subtracted from the fatigue component for each test beyond the first two.")
flipConfirmCloses    = input.int(2, "Flip Confirm Closes", minval = 1, maxval = 5, group = groupScoring,
     tooltip = "Number of consecutive opposite-side closes required to flip a broken support into resistance or a broken resistance into support.")

publishModeInput     = input.bool(false, "Clean Map Mode", group = groupVisuals,
     tooltip = "Minimal labels: only the Active Level and the nearest valid support and resistance are labelled. Useful for screenshots and publishing.")
showLabelsInput      = input.bool(true,  "Show Labels", group = groupVisuals,
     tooltip = "Master toggle for on-chart level labels.")
lineWidthInput       = input.int(2, "Base Line Width", minval = 1, maxval = 4, group = groupVisuals,
     tooltip = "Base thickness for level lines. Stronger levels and the Active Level receive additional emphasis automatically.")
labelSizeInput       = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisuals,
     tooltip = "Font size for on-chart level labels and active-level badges.")
focusExtraWidth      = input.int(1, "Focus Label Emphasis", minval = 0, maxval = 3, group = groupVisuals,
     tooltip = "Extra line width added specifically to the Active Level to make it stand out.")
nonFocusTransparency = input.int(18, "Non-Focus Transparency", minval = 0, maxval = 90, group = groupVisuals,
     tooltip = "Transparency for levels that are not currently the Active Level.")
clusterFilterInput   = input.bool(true, "Fade Crowded Weaker Levels", group = groupVisuals,
     tooltip = "Fade same-type levels that are close to a stronger or more recent peer to keep the map clean.")
clusterAtrMult       = input.float(0.45, "Crowded Level Distance (ATR)", minval = 0.05, maxval = 1.50, step = 0.05, group = groupVisuals,
     tooltip = "ATR distance within which same-type levels are considered a cluster.")
clusterTransparency  = input.int(82, "Crowded Level Transparency", minval = 40, maxval = 95, group = groupVisuals,
     tooltip = "Transparency applied to weaker members of a cluster.")
hideWeakNonFocus     = input.bool(true, "Hide Eroded Non-Focus Labels", group = groupVisuals,
     tooltip = "Hide labels for non-Active levels whose survival score has dropped below 30.")
showFocusZoneInput    = input.bool(true, "Show Focus Zone", group = groupVisuals,
     tooltip = "Draws the interaction band around the Active Level as a filled zone.")
focusZoneWidthMult    = input.float(1.00, "Focus Zone Width Multiplier", minval = 0.50, maxval = 3.0, step = 0.10, group = groupVisuals,
     tooltip = "Multiplier applied to the base interaction zone when drawing the Active Level zone.")
focusZoneTransparency = input.int(86, "Focus Zone Transparency", minval = 60, maxval = 95, group = groupVisuals,
     tooltip = "Transparency of the outer Active Level zone.")
showFocusRibbonInput  = input.bool(true, "Show Focus Ribbon", group = groupVisuals,
     tooltip = "Projects the Active Level's expected reaction band into the future for planning.")
focusRibbonBars       = input.int(25, "Focus Ribbon Projection (bars)", minval = 4, maxval = 80, group = groupVisuals,
     tooltip = "How many bars into the future the ribbon is projected from the last bar.")
focusRibbonAtrMult    = input.float(0.32, "Focus Ribbon Thickness (ATR)", minval = 0.10, maxval = 1.50, step = 0.02, group = groupVisuals,
     tooltip = "Ribbon half-thickness in ATR units.")
focusRibbonTransparency = input.int(76, "Focus Ribbon Transparency", minval = 45, maxval = 92, group = groupVisuals,
     tooltip = "Transparency of the projection ribbon.")
labelRightOffsetBars  = input.int(2, "Label Right Offset (bars)", minval = 0, maxval = 12, group = groupVisuals,
     tooltip = "Horizontal offset for labels so they sit to the right of the last bar and do not overlap price action.")
labelMinGapAtr        = input.float(0.65, "Label Minimum Gap (ATR)", minval = 0.00, maxval = 4.00, step = 0.05, group = groupVisuals,
     tooltip = "Minimum ATR-based vertical spacing between right-side level labels. Close labels are pushed apart so they never overlap, while the lines stay on their true level.")
showFocusBadgeInput = input.bool(true, "Show Active Level Badge", group = groupVisuals,
     tooltip = "Places a separate centered badge inside the Active Level zone or ribbon so the highlighted structural area has clear ownership.")
focusBadgeAnchor = input.float(0.52, "Active Badge Anchor", minval = 0.10, maxval = 0.90, step = 0.01, group = groupVisuals,
     tooltip = "Horizontal placement of the Active Level badge inside the projection ribbon.")

showPanelInput       = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Toggles the summary panel for the current Active Level.")
panelPositionInput   = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"],
     group = groupPanel,
     tooltip = "Anchor position for the summary panel.")
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel,
     tooltip = "Visual theme for the panel. Elite Dark is the AGPro default, Slate is softer, and Clean Light is designed for bright chart backgrounds.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel,
     tooltip = "Font size used inside the panel. Normal is the default publication size.")

// -----------------------------------------------------
// Helpers
// -----------------------------------------------------
clip01(float x) =>
    math.max(0.0, math.min(1.0, x))

// Luminance-aware text color: dark ink on light badges, light text on dark badges.
f_text_on(color _bg) =>
    float _lum = 0.299 * color.r(_bg) + 0.587 * color.g(_bg) + 0.114 * color.b(_bg)
    _lum > 145 ? AGPRO_DARK_INK : AGPRO_HEADER_TEXT

supportColor(float score) =>
    score >= 75 ? AGPRO_BULL :
     score >= 55 ? color.rgb(46, 186, 160) :
     score >= 35 ? AGPRO_NEUTRAL :
     color.rgb(200, 120, 90)

resistanceColor(float score) =>
    score >= 75 ? AGPRO_BEAR :
     score >= 55 ? color.rgb(225, 130, 170) :
     score >= 35 ? AGPRO_NEUTRAL :
     color.rgb(200, 120, 90)

levelColor(int t, float score) =>
    t == 1 ? supportColor(score) : resistanceColor(score)

stateText(float score, int tests) =>
    tests == 0 ? "Fresh" :
     score >= 75 ? "Strong" :
     score >= 55 ? "Holding" :
     score >= 35 ? "Fragile" :
     "Eroded"

damageText(float damageScore) =>
    damageScore >= 75 ? "Low" :
     damageScore >= 50 ? "Moderate" :
     damageScore >= 25 ? "High" :
     "Severe"

levelTypeText(int t) =>
    t == 1 ? "Support" : "Resistance"

levelTypeShortText(int t) =>
    t == 1 ? "SUP" : "RES"

alphaClamp(int x) =>
    math.max(0, math.min(100, x))

widthFromScore(float score, int baseWidth) =>
    int extra = score >= 90 ? 2 : score >= 85 ? 1 : 0
    math.min(5, baseWidth + extra)

f_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_position(string locationName) =>
    switch locationName
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
    panelThemeInput == "Clean Light" ? color.rgb(248, 250, 252) : panelThemeInput == "Slate" ? color.rgb(30, 41, 59) : AGPRO_PANEL_BG

f_panel_border() =>
    panelThemeInput == "Clean Light" ? color.rgb(203, 213, 225) : AGPRO_PANEL_BORDER

f_panel_label() =>
    panelThemeInput == "Clean Light" ? color.rgb(71, 85, 105) : AGPRO_LABEL_COL

f_panel_value() =>
    panelThemeInput == "Clean Light" ? color.rgb(15, 23, 42) : AGPRO_VALUE_COL

f_focus_badge_text(int levelType, float score, int tests) =>
    "ACTIVE " + levelTypeShortText(levelType) + "\nSURVIVAL " + str.tostring(math.round(score)) + "  ·  " + str.tostring(tests) + (tests == 1 ? " TEST" : " TESTS")

labelSize      = f_size(labelSizeInput)
panelSize      = f_size(panelSizeInput)
atrValue       = ta.atr(atrLength)
int maxLevelsNow = publishModeInput ? math.min(maxActiveLevels, 6) : maxActiveLevels

// -----------------------------------------------------
// State Arrays | type: 1 = support, -1 = resistance
// -----------------------------------------------------
var float[] levelPrices       = array.new_float()
var int[]   levelTypes        = array.new_int()
var int[]   levelTests        = array.new_int()
var float[] levelDamageSum    = array.new_float()
var float[] levelRespectSum   = array.new_float()
var float[] levelReactionSum  = array.new_float()
var float[] levelScores       = array.new_float()
var bool[]  levelInsideZone   = array.new_bool()
var int[]   levelLastTouchBar = array.new_int()
var bool[]  levelBroken       = array.new_bool()
var int[]   levelFlipStreak   = array.new_int()
var line[]  levelLines        = array.new_line()
var label[] levelLabels       = array.new_label()

// Defense Rate proof state (share of confirmed level tests that closed back on the defended side)
var int defenseHeld  = 0
var int defenseTotal = 0

var table panel = na
var box   focusZoneBox   = na
var box   focusCoreBox   = na
var box   focusRibbonBox = na
var label focusBadge     = na

// -----------------------------------------------------
// New pivot levels
// -----------------------------------------------------
pivotLow  = ta.pivotlow(low, leftBars, rightBars)
pivotHigh = ta.pivothigh(high, leftBars, rightBars)

if not na(atrValue)
    if not na(pivotLow) and bar_index > rightBars
        float newSupport = pivotLow
        bool canAddSupport = true

        if array.size(levelPrices) > 0
            for i = 0 to array.size(levelPrices) - 1
                bool sameType = array.get(levelTypes, i) == 1
                bool tooClose = math.abs(array.get(levelPrices, i) - newSupport) <= atrValue * mergeAtrMult
                if sameType and tooClose
                    canAddSupport := false

        if canAddSupport
            int originBar = bar_index - rightBars
            line ln = line.new(originBar, newSupport, bar_index, newSupport, xloc = xloc.bar_index, extend = extend.right, color = color.new(color.gray, 0), width = lineWidthInput)
            label lb = label.new(bar_index, newSupport, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = color.white, color = color.new(color.black, 100), size = labelSize)

            array.push(levelPrices, newSupport)
            array.push(levelTypes, 1)
            array.push(levelTests, 0)
            array.push(levelDamageSum, 0.0)
            array.push(levelRespectSum, 0.0)
            array.push(levelReactionSum, 0.0)
            array.push(levelScores, 85.0)
            array.push(levelInsideZone, false)
            array.push(levelLastTouchBar, 0)
            array.push(levelBroken, false)
            array.push(levelFlipStreak, 0)
            array.push(levelLines, ln)
            array.push(levelLabels, lb)

            if array.size(levelPrices) > maxLevelsNow
                line oldLine = array.shift(levelLines)
                label oldLabel = array.shift(levelLabels)
                array.shift(levelPrices)
                array.shift(levelTypes)
                array.shift(levelTests)
                array.shift(levelDamageSum)
                array.shift(levelRespectSum)
                array.shift(levelReactionSum)
                array.shift(levelScores)
                array.shift(levelInsideZone)
                array.shift(levelLastTouchBar)
                array.shift(levelBroken)
                array.shift(levelFlipStreak)
                line.delete(oldLine)
                label.delete(oldLabel)

    if not na(pivotHigh) and bar_index > rightBars
        float newResistance = pivotHigh
        bool canAddResistance = true

        if array.size(levelPrices) > 0
            for i = 0 to array.size(levelPrices) - 1
                bool sameType = array.get(levelTypes, i) == -1
                bool tooClose = math.abs(array.get(levelPrices, i) - newResistance) <= atrValue * mergeAtrMult
                if sameType and tooClose
                    canAddResistance := false

        if canAddResistance
            int originBar = bar_index - rightBars
            line ln = line.new(originBar, newResistance, bar_index, newResistance, xloc = xloc.bar_index, extend = extend.right, color = color.new(color.gray, 0), width = lineWidthInput)
            label lb = label.new(bar_index, newResistance, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = color.white, color = color.new(color.black, 100), size = labelSize)

            array.push(levelPrices, newResistance)
            array.push(levelTypes, -1)
            array.push(levelTests, 0)
            array.push(levelDamageSum, 0.0)
            array.push(levelRespectSum, 0.0)
            array.push(levelReactionSum, 0.0)
            array.push(levelScores, 85.0)
            array.push(levelInsideZone, false)
            array.push(levelLastTouchBar, 0)
            array.push(levelBroken, false)
            array.push(levelFlipStreak, 0)
            array.push(levelLines, ln)
            array.push(levelLabels, lb)

            if array.size(levelPrices) > maxLevelsNow
                line oldLine = array.shift(levelLines)
                label oldLabel = array.shift(levelLabels)
                array.shift(levelPrices)
                array.shift(levelTypes)
                array.shift(levelTests)
                array.shift(levelDamageSum)
                array.shift(levelRespectSum)
                array.shift(levelReactionSum)
                array.shift(levelScores)
                array.shift(levelInsideZone)
                array.shift(levelLastTouchBar)
                array.shift(levelBroken)
                array.shift(levelFlipStreak)
                line.delete(oldLine)
                label.delete(oldLabel)

// -----------------------------------------------------
// Per-bar level maintenance
// -----------------------------------------------------
float focusDistance    = 1000000.0
int   focusIndex       = na
float focusDamageScore = na

int   nearestSupIndex  = na
float nearestSupDist   = 1000000.0
int   nearestResIndex  = na
float nearestResDist   = 1000000.0

if array.size(levelPrices) > 0 and not na(atrValue)
    for i = 0 to array.size(levelPrices) - 1
        float levelPrice    = array.get(levelPrices, i)
        int   levelType     = array.get(levelTypes, i)
        int   tests         = array.get(levelTests, i)
        float damageSum     = array.get(levelDamageSum, i)
        float respectSum    = array.get(levelRespectSum, i)
        float reactionSum   = array.get(levelReactionSum, i)
        bool  insidePrev    = array.get(levelInsideZone, i)
        int   flipStreak    = array.get(levelFlipStreak, i)

        float zone = atrValue * zoneAtrMult
        bool touched  = high >= levelPrice - zone and low <= levelPrice + zone
        bool newTouch = touched and not insidePrev

        if newTouch
            tests += 1

            float rawPen    = levelType == 1 ? math.max(0.0, (levelPrice - zone - low) / atrValue) : math.max(0.0, (high - (levelPrice + zone)) / atrValue)
            float bodyBreak = levelType == 1 ? (close < levelPrice - zone ? 0.50 : 0.0) : (close > levelPrice + zone ? 0.50 : 0.0)
            float damage    = clip01(rawPen + bodyBreak)

            float respect = levelType == 1 ? (close >= levelPrice ? 1.0 : close >= levelPrice - zone ? 0.50 : 0.0) : (close <= levelPrice ? 1.0 : close <= levelPrice + zone ? 0.50 : 0.0)
            float reaction = levelType == 1 ? clip01((close - low) / atrValue) : clip01((high - close) / atrValue)

            damageSum   += damage
            respectSum  += respect
            reactionSum += reaction

            array.set(levelLastTouchBar, i, bar_index)

            // Defense Rate proof: count confirmed tests and how many closed fully on the defended side.
            if barstate.isconfirmed
                defenseTotal += 1
                if respect >= 1.0
                    defenseHeld += 1

        array.set(levelInsideZone, i, touched)

        float avgDamage   = tests > 0 ? damageSum / tests : 0.15
        float avgRespect  = tests > 0 ? respectSum / tests : 0.85
        float avgReaction = tests > 0 ? reactionSum / tests : 0.70

        float closeScore    = clip01(avgRespect) * 100.0
        float damageScore   = (1.0 - clip01(avgDamage)) * 100.0
        float reactionScore = clip01(avgReaction) * 100.0
        float fatigueScore  = math.max(0.0, 100.0 - math.max(0, tests - 2) * fatiguePenaltyPerTest)

        bool structureBroken = levelType == 1 ? close < levelPrice - zone : close > levelPrice + zone

        float survival = closeScore * closeRespectWeight + damageScore * penetrationWeight + reactionScore * reactionWeight + fatigueScore * fatigueWeight

        if structureBroken
            survival := math.min(survival, 35.0)

        if tests >= 4 and avgDamage > 0.55
            survival := math.min(survival, 28.0)

        bool oppositeClose = levelType == 1 ? close < levelPrice - zone : close > levelPrice + zone
        flipStreak := oppositeClose ? flipStreak + 1 : 0

        if flipStreak >= flipConfirmCloses
            levelType   := -levelType
            tests       := 0
            damageSum   := 0.0
            respectSum  := 0.0
            reactionSum := 0.0
            survival    := 68.0
            structureBroken := false
            flipStreak  := 0

        survival := math.max(0.0, math.min(100.0, survival))

        array.set(levelTypes, i, levelType)
        array.set(levelTests, i, tests)
        array.set(levelDamageSum, i, damageSum)
        array.set(levelRespectSum, i, respectSum)
        array.set(levelReactionSum, i, reactionSum)
        array.set(levelScores, i, survival)
        array.set(levelBroken, i, structureBroken)
        array.set(levelFlipStreak, i, flipStreak)

        bool sideMismatch = levelType == 1 ? levelPrice > close : levelPrice < close

        if levelType == 1 and not sideMismatch
            float dSup = math.abs(close - levelPrice)
            if dSup < nearestSupDist
                nearestSupDist  := dSup
                nearestSupIndex := i
        if levelType == -1 and not sideMismatch
            float dRes = math.abs(close - levelPrice)
            if dRes < nearestResDist
                nearestResDist  := dRes
                nearestResIndex := i

        float distanceToPrice = math.abs(close - levelPrice) / atrValue + (sideMismatch ? 1000.0 : 0.0)
        if distanceToPrice < focusDistance
            focusDistance    := distanceToPrice
            focusIndex       := i
            focusDamageScore := damageScore

    // -------------------------------------------------
    // Rendering pass
    // -------------------------------------------------
    label[] visLabels = array.new_label()
    float[] visY      = array.new_float()

    for i = 0 to array.size(levelPrices) - 1
        float levelPrice = array.get(levelPrices, i)
        int   levelType  = array.get(levelTypes, i)
        float survival   = array.get(levelScores, i)
        bool  broken     = array.get(levelBroken, i)
        bool  isFocus    = i == focusIndex
        bool  sideMismatch = levelType == 1 ? levelPrice > close : levelPrice < close

        bool crowdedWeaker = false
        if clusterFilterInput
            for j = 0 to array.size(levelPrices) - 1
                if j != i
                    int   otherType    = array.get(levelTypes, j)
                    float otherPrice   = array.get(levelPrices, j)
                    float otherScore   = array.get(levelScores, j)
                    int   otherTouch   = array.get(levelLastTouchBar, j)
                    int   thisTouch    = array.get(levelLastTouchBar, i)
                    float otherDist    = math.abs(close - otherPrice)
                    float thisDist     = math.abs(close - levelPrice)
                    bool sameType      = otherType == levelType
                    bool tooClose      = math.abs(otherPrice - levelPrice) <= atrValue * clusterAtrMult
                    bool stronger      = otherScore > survival + 0.50
                    bool tieCloser     = math.abs(otherScore - survival) <= 0.50 and otherDist < thisDist
                    bool tieMoreRecent = math.abs(otherScore - survival) <= 0.50 and otherTouch > thisTouch
                    bool tieNewerIdx   = math.abs(otherScore - survival) <= 0.50 and j > i
                    if sameType and tooClose and (stronger or tieCloser or tieMoreRecent or tieNewerIdx)
                        crowdedWeaker := true

        bool weakNonFocus     = hideWeakNonFocus and not isFocus and survival < 30
        int lineTransparency  = sideMismatch ? 92 : isFocus ? 0 : weakNonFocus ? 90 : crowdedWeaker ? alphaClamp(clusterTransparency) : alphaClamp(nonFocusTransparency)
        int scoreWidthNow     = widthFromScore(survival, lineWidthInput)
        int lineWidthNow      = math.min(5, scoreWidthNow + (isFocus ? focusExtraWidth : 0))
        color lineColorNow    = color.new(levelColor(levelType, survival), lineTransparency)

        line ln = array.get(levelLines, i)
        line.set_x2(ln, bar_index)
        line.set_y1(ln, levelPrice)
        line.set_y2(ln, levelPrice)
        line.set_color(ln, lineColorNow)
        line.set_width(ln, lineWidthNow)
        line.set_style(ln, sideMismatch ? line.style_dotted : broken ? line.style_dashed : line.style_solid)

        // The Active Level owns the centered badge, so suppress its redundant right-side label when that badge is shown.
        bool focusBadgeShown = showFocusBadgeInput and (showFocusZoneInput or showFocusRibbonInput)
        label lb = array.get(levelLabels, i)
        bool isKeyLevel    = isFocus or i == nearestSupIndex or i == nearestResIndex
        bool showThisLabel = showLabelsInput and not weakNonFocus and not sideMismatch and (not crowdedWeaker or isFocus) and (not publishModeInput or isKeyLevel) and not (isFocus and focusBadgeShown)

        if showThisLabel
            color levelTone  = levelColor(levelType, survival)
            string labelText = isFocus ? "ACTIVE " + levelTypeShortText(levelType) + " " + str.tostring(math.round(survival)) :
                 publishModeInput ? (levelTypeShortText(levelType) + " " + str.tostring(math.round(survival))) :
                 ((levelType == 1 ? "SUP Score " : "RES Score ") + str.tostring(math.round(survival)))
            int labelTransp  = isFocus ? 0 : crowdedWeaker ? 35 : 0
            int xOffsetNow   = labelRightOffsetBars + (isFocus ? 1 : 0)
            label.set_x(lb, bar_index + xOffsetNow)
            label.set_y(lb, levelPrice)
            label.set_text(lb, labelText)
            label.set_textcolor(lb, f_text_on(levelTone))
            label.set_color(lb, color.new(levelTone, labelTransp))
            label.set_style(lb, label.style_label_left)
            label.set_size(lb, labelSize)
            if barstate.islast
                array.push(visLabels, lb)
                array.push(visY, levelPrice)
        else
            label.set_text(lb, "")
            label.set_color(lb, color.new(color.black, 100))
            label.set_textcolor(lb, color.new(color.white, 100))

    // -------------------------------------------------
    // Right-side label de-collision (last bar): push overlapping labels
    // apart vertically while their lines stay on the true level.
    // -------------------------------------------------
    if barstate.islast and not na(atrValue)
        int visN = array.size(visY)
        if visN > 1
            // sort visible labels bottom -> top by y (selection sort, parallel arrays)
            for a = 0 to visN - 2
                int minI = a
                for b = a + 1 to visN - 1
                    if array.get(visY, b) < array.get(visY, minI)
                        minI := b
                if minI != a
                    float tY = array.get(visY, a)
                    array.set(visY, a, array.get(visY, minI))
                    array.set(visY, minI, tY)
                    label tL = array.get(visLabels, a)
                    array.set(visLabels, a, array.get(visLabels, minI))
                    array.set(visLabels, minI, tL)
            // enforce a minimum vertical gap from the bottom up
            float gapMin = atrValue * labelMinGapAtr
            if gapMin > 0.0
                for a = 1 to visN - 1
                    float prevY = array.get(visY, a - 1)
                    float curY  = array.get(visY, a)
                    if curY - prevY < gapMin
                        array.set(visY, a, prevY + gapMin)
                for a = 0 to visN - 1
                    label.set_y(array.get(visLabels, a), array.get(visY, a))

// -----------------------------------------------------
// Focus zone and badge
// -----------------------------------------------------
if not na(focusZoneBox)
    box.delete(focusZoneBox)
    focusZoneBox := na

if not na(focusCoreBox)
    box.delete(focusCoreBox)
    focusCoreBox := na

if not na(focusRibbonBox)
    box.delete(focusRibbonBox)
    focusRibbonBox := na

if not na(focusBadge)
    label.delete(focusBadge)
    focusBadge := na

if not na(focusIndex) and focusDistance < 999.0 and not na(atrValue)
    float focusPrice  = array.get(levelPrices, focusIndex)
    int   focusTypeZ  = array.get(levelTypes, focusIndex)
    float focusScoreZ = array.get(levelScores, focusIndex)
    int   focusTestsZ = array.get(levelTests, focusIndex)
    line  focusLineZ  = array.get(levelLines, focusIndex)
    int   leftX       = line.get_x1(focusLineZ)
    int   rightX      = bar_index + 1
    color focusBase   = levelColor(focusTypeZ, focusScoreZ)

    if showFocusZoneInput
        float zoneHalfOuter = atrValue * zoneAtrMult * focusZoneWidthMult
        float zoneHalfCore  = zoneHalfOuter * 0.58
        color zoneColorOuter = color.new(focusBase, focusZoneTransparency)
        color zoneBorderOuter = color.new(focusBase, 92)
        color zoneColorCore  = color.new(focusBase, math.max(35, focusZoneTransparency - 24))
        color zoneBorderCore = color.new(focusBase, 82)
        focusZoneBox := box.new(left = leftX, top = focusPrice + zoneHalfOuter, right = rightX, bottom = focusPrice - zoneHalfOuter, xloc = xloc.bar_index, extend = extend.right, border_color = zoneBorderOuter, bgcolor = zoneColorOuter)
        focusCoreBox := box.new(left = leftX, top = focusPrice + zoneHalfCore, right = rightX, bottom = focusPrice - zoneHalfCore, xloc = xloc.bar_index, extend = extend.right, border_color = zoneBorderCore, bgcolor = zoneColorCore)

    if showFocusRibbonInput
        float ribbonHalf = atrValue * focusRibbonAtrMult
        int   ribbonLeft = bar_index + 1
        int   ribbonRight = bar_index + focusRibbonBars
        color ribbonColor = color.new(focusBase, focusRibbonTransparency)
        color ribbonBorder = color.new(focusBase, 88)
        focusRibbonBox := box.new(left = ribbonLeft, top = focusPrice + ribbonHalf, right = ribbonRight, bottom = focusPrice - ribbonHalf, xloc = xloc.bar_index, extend = extend.none, border_color = ribbonBorder, bgcolor = ribbonColor)

    if showFocusBadgeInput and (showFocusZoneInput or showFocusRibbonInput)
        int badgeX = showFocusRibbonInput ? bar_index + int(math.round(focusRibbonBars * focusBadgeAnchor)) : bar_index + labelRightOffsetBars + 4
        focusBadge := label.new(badgeX, focusPrice, f_focus_badge_text(focusTypeZ, focusScoreZ, focusTestsZ),
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_center,
             color = color.new(focusBase, 0),
             textcolor = f_text_on(focusBase),
             size = labelSize)

// -----------------------------------------------------
// Premium panel
// -----------------------------------------------------
if showPanelInput and barstate.islast
    if na(panel)
        panel := table.new(f_position(panelPositionInput), 3, 7,
             border_width = 1,
             border_color = f_panel_border(),
             frame_color = f_panel_border(),
             frame_width = 1,
             bgcolor = f_panel_bg())
    table.set_position(panel, f_position(panelPositionInput))

    bool hasFocus = not na(focusIndex) and focusDistance < 999.0

    int   focusTypePanel   = hasFocus ? array.get(levelTypes, focusIndex) : 1
    int   focusTestsPanel  = hasFocus ? array.get(levelTests, focusIndex) : 0
    float focusScorePanel  = hasFocus ? array.get(levelScores, focusIndex) : na
    bool  focusBrokenPanel = hasFocus ? array.get(levelBroken, focusIndex) : false
    color focusAccent      = hasFocus ? levelColor(focusTypePanel, focusScorePanel) : f_panel_label()

    color panelBg          = f_panel_bg()
    color labelTextColor   = f_panel_label()
    color valueTextColor   = f_panel_value()

    color testsAccent      = AGPRO_ACCENT
    color damageAccent     = not hasFocus ? f_panel_label() :
         focusDamageScore >= 75 ? AGPRO_BULL :
         focusDamageScore >= 50 ? AGPRO_NEUTRAL :
         focusDamageScore >= 25 ? color.rgb(245, 130, 100) :
         AGPRO_BEAR

    // Defense Rate proof
    float defensePct = defenseTotal > 0 ? defenseHeld / defenseTotal * 100.0 : na
    bool  defBuilding = defenseTotal < 6
    color defBase = defBuilding ? AGPRO_ACCENT : defensePct >= 60 ? AGPRO_BULL : defensePct >= 45 ? AGPRO_NEUTRAL : AGPRO_BEAR
    string defText = defBuilding ? "Building (" + str.tostring(defenseTotal) + ")" : str.tostring(math.round(defensePct)) + "%  (" + str.tostring(defenseTotal) + ")"

    // Action read for the Active Level
    string actionText = not hasFocus ? "Scanning" :
         focusBrokenPanel ? (focusTypePanel == 1 ? "Support broken" : "Resistance broken") :
         focusScorePanel >= 75 ? (focusTypePanel == 1 ? "Strong support" : "Strong resistance") :
         focusScorePanel >= 55 ? "Holding — watch" :
         focusScorePanel >= 35 ? "Fragile — caution" :
         "Eroded — low trust"
    color actionBase = not hasFocus ? AGPRO_ACCENT :
         focusBrokenPanel ? AGPRO_BEAR :
         focusScorePanel >= 75 ? (focusTypePanel == 1 ? AGPRO_BULL : AGPRO_BEAR) :
         focusScorePanel >= 55 ? AGPRO_BULL :
         focusScorePanel >= 35 ? AGPRO_NEUTRAL :
         AGPRO_BEAR

    color focusValueBg     = color.new(focusAccent, 78)
    color testsValueBg     = color.new(testsAccent, 78)
    color damageValueBg    = color.new(damageAccent, 78)

    string focusLevelText  = hasFocus ? levelTypeText(focusTypePanel) : "None"
    string focusScoreText  = hasFocus ? str.tostring(math.round(focusScorePanel)) + "  " + stateText(focusScorePanel, focusTestsPanel) : "-"
    string testsText       = hasFocus ? str.tostring(focusTestsPanel) : "-"
    string damageTextPanel = hasFocus ? damageText(focusDamageScore) : "-"

    table.clear(panel, 0, 0, 2, 6)
    table.merge_cells(panel, 0, 0, 2, 0)
    table.cell(panel, 0, 0, "AG Pro Level Survival Map", text_color = AGPRO_HEADER_TEXT, bgcolor = AGPRO_HEADER_BG, text_size = panelSize, text_halign = text.align_center)

    table.cell(panel, 0, 1, "", bgcolor = focusAccent)
    table.cell(panel, 1, 1, "Active Level", text_color = labelTextColor, bgcolor = panelBg, text_size = panelSize)
    table.cell(panel, 2, 1, focusLevelText, text_color = focusAccent, bgcolor = focusValueBg, text_size = panelSize)

    table.cell(panel, 0, 2, "", bgcolor = focusAccent)
    table.cell(panel, 1, 2, "Survival Score", text_color = labelTextColor, bgcolor = panelBg, text_size = panelSize)
    table.cell(panel, 2, 2, focusScoreText, text_color = focusAccent, bgcolor = focusValueBg, text_size = panelSize)

    table.cell(panel, 0, 3, "", bgcolor = testsAccent)
    table.cell(panel, 1, 3, "Test Count", text_color = labelTextColor, bgcolor = panelBg, text_size = panelSize)
    table.cell(panel, 2, 3, testsText, text_color = testsAccent, bgcolor = testsValueBg, text_size = panelSize)

    table.cell(panel, 0, 4, "", bgcolor = damageAccent)
    table.cell(panel, 1, 4, "Damage State", text_color = labelTextColor, bgcolor = panelBg, text_size = panelSize)
    table.cell(panel, 2, 4, damageTextPanel, text_color = damageAccent, bgcolor = damageValueBg, text_size = panelSize)

    table.cell(panel, 0, 5, "", bgcolor = defBuilding ? f_panel_border() : defBase)
    table.cell(panel, 1, 5, "Defense Rate", text_color = labelTextColor, bgcolor = panelBg, text_size = panelSize)
    table.cell(panel, 2, 5, defText, text_color = defBuilding ? valueTextColor : defBase, bgcolor = color.new(defBase, 78), text_size = panelSize)

    table.cell(panel, 0, 6, "", bgcolor = actionBase)
    table.cell(panel, 1, 6, "Action", text_color = labelTextColor, bgcolor = panelBg, text_size = panelSize)
    table.cell(panel, 2, 6, actionText, text_color = f_text_on(actionBase), bgcolor = color.new(actionBase, 12), text_size = panelSize)

if not showPanelInput and not na(panel)
    table.delete(panel)
    panel := na
````
