# Multi-Timeframe Volume Profile [AnkeAlgo]

- url: https://www.tradingview.com/script/DG7tRF8O-Multi-Timeframe-Volume-Profile-AnkeAlgo/
- type: indicator
- pine_id: PUB;d463bcc6200f4c3abc47c3c847c7be4c
- version: 1.0

## Description

[image]https://www.tradingview.com/x/obLf1tOw/[/image]

[b]Why This Indicator Changes How You Read the Chart[/b]

Most traders switch between timeframes to understand where volume clustered, but that workflow breaks the visual continuity of price action. You lose the spatial relationship between where price is now and where the big volume sat three timeframes up. Multi-Timeframe Volume Profile [AnkeAlgo] solves that by bringing completed higher timeframe volume profiles directly onto your active chart. Instead of flipping tabs, you see the POC, VAH, and VAL from four different timeframes layered in one view. The result is a single chart that shows you where institutional interest concentrated, where price was rejected or accepted, and which levels matter across multiple trading horizons.

[b]Core Concept[/b]

The indicator works by tracking every bar that belongs to a higher timeframe candle, aggregating the high, low, open, close, and volume data, and then building a volume profile once that candle closes. 
[pine]
//------------------------------------------------------------------------------
// Input Groups
//------------------------------------------------------------------------------
groupPreset = "Theme & Mode"
groupProfile = "Profile"
groupLayout = "Layout"
groupDisplay = "Display"
groupTf1 = "Timeframe 1"
groupTf2 = "Timeframe 2"
groupTf3 = "Timeframe 3"
groupTf4 = "Timeframe 4"
groupStyle = "Custom Colors"

stylePreset = input.string("Lava Pulse", "Theme", options=["Quantum Ice", "Cyber Neon", "Stellar Violet", "Lava Pulse", "Mecha Titanium", "Dark Matter Green", "Supernova Gold", "Custom"], group=groupPreset)
viewMode = input.string("Flagship", "Display Mode", options=["Flagship", "Minimal"], group=groupPreset)
[/pine]
 This means you are always looking at completed data—no repainting, no guessing. Each profile is rendered as a horizontal histogram where the width of each row represents the volume traded at that price level. Bullish volume (closing higher than opening) and bearish volume (closing lower than opening) are tracked separately and drawn in distinct colors, so you can see not just where volume occurred but also the directional bias within each price row.

The Point of Control (POC) is the row with the highest total volume, and the Value Area High (VAH) and Value Area Low (VAL) define the range that contains the percentage of total volume you specify in the Value Area % input. 
[pine]
baseRightBars = input.int(10, "Right Offset Base", minval=0, maxval=120, group=groupLayout)
profileHalfWidth = input.int(7, "Profile Half Width", minval=2, maxval=24, group=groupLayout)
candleGapBars = input.int(2, "Profile to Candle Gap", minval=1, maxval=20, group=groupLayout)
candleBodyHalfWidth = input.int(2, "HTF Candle Half Width", minval=1, maxval=8, group=groupLayout)
levelExtensionBars = input.int(3, "POC/VA Extension", minval=1, maxval=20, group=groupLayout)
topLabelPaddingPct = input.float(2.5, "Top Label Padding %", minval=1.0, maxval=15.0, step=0.5, group=groupLayout)

showTfLabel = input.bool(true, "Show Timeframe Label", group=groupDisplay)
showPanelFrame = input.bool(true, "Show Panel Frame", group=groupDisplay)
showPocHighlight = input.bool(true, "Highlight POC", group=groupDisplay)
showValueAreaLines = input.bool(true, "Show POC / VAH / VAL Lines", group=groupDisplay)
showValueAreaText = input.bool(false, "Show POC / VAH / VAL Text", group=groupDisplay)
showCandle = input.bool(true, "Show HTF Candle", group=groupDisplay)
showSeparator = input.bool(false, "Show Profile Divider", group=groupDisplay)
showAnchorDot = input.bool(false, "Show Left Anchor", group=groupDisplay)
showVisualFx = input.bool(true, "Show Cinematic FX", group=groupDisplay)
[/pine]
 These three levels are extended to the right as lines, giving you clear horizontal references that persist across bars. The higher timeframe candle itself is also drawn, showing the open-to-close body and the full high-to-low wick, so you can see the exact range that the profile covers.

[b]Signal Logic[/b]

This is not a signal generator. There are no buy arrows, sell arrows, or alert conditions. The value comes from visual structure. When price approaches a POC from a higher timeframe, you know that level has seen significant trading activity. When price breaks above VAH or below VAL, you can assess whether the move has conviction by checking if volume on the current timeframe supports the breakout. The indicator gives you the map; you still need to decide the route.

Each of the four timeframes can be enabled independently, and each has its own right offset so you can stagger the profiles horizontally and avoid overlap. The tier system (1 through 4) controls visual prominence: higher tiers get thicker lines, larger labels, more cinematic effects, and less transparency. This creates a natural visual hierarchy where the highest timeframe profile stands out the most.

[b]Key Inputs and What They Control[/b]

The Theme input switches between eight color presets, each with carefully balanced buy/sell colors, panel backgrounds, border tones, and highlight colors. If none of the presets fit your style, the Custom option unlocks individual color inputs for every visual element.

The Display Mode toggles between Flagship and Minimal. Flagship adds cinematic effects like glow boxes, accent lines, header strips, and panel shadows. Minimal strips most of these extras, leaving a cleaner profile with reduced transparency and smaller labels. This is useful if you run multiple indicators or prefer a less busy chart.

Profile Rows controls the vertical resolution of each profile. More rows mean finer price granularity but also more visual elements. The Value Area % determines how much of the total volume is included in the value area. The default of 70% is standard, but you can tighten it to 50% for a narrower range or widen it to 99% for near-full coverage.

The layout inputs—Right Offset Base, Profile Half Width, Profile to Candle Gap, HTF Candle Half Width, and POC/VA Extension—let you fine-tune the horizontal positioning and sizing of every element. These are critical for matching the indicator to your chart's bar spacing and personal visual preference.

[b]Risk Notes and Responsible Use[/b]

Because profiles are drawn only after a higher timeframe candle closes, the data is always historical. There is no forward-looking component. This makes the indicator excellent for identifying established levels but useless for predicting the next tick. The levels you see are reference points, not guarantees.

The indicator also does not account for market profile concepts like initial balance, developing range, or single prints. It is a volume-weighted histogram with a value area calculation, not a full Market Profile implementation. Traders who rely on TPO or letter-based profiles will find this tool complementary but not equivalent.

Visual clutter is a real risk when enabling all four timeframes with Flagship mode and high row counts. Start with one or two timeframes, adjust the offsets, and only add more if the chart remains readable. The Minimal mode helps here, as does reducing the Profile Half Width and disabling the Show Panel Frame option.

[b]Best Use Cases[/b]

This indicator shines in three scenarios. First, when you want to see whether a current price level aligns with a high-volume node from a higher timeframe—this gives you a natural place to look for support or resistance. Second, when you are analyzing a breakout and want to check if the higher timeframe value area has been breached with conviction. Third, when you trade multiple instruments and need a consistent visual framework for volume structure without customizing each chart individually.

The four independent timeframes also let you build a layered view of market structure. For example, you could use a 30-minute profile for intraday structure, a 60-minute for session structure, a 240-minute for daily structure, and a 720-minute for weekly structure. Each profile sits at its own horizontal offset, creating a timeline of volume activity that flows from left to right as the timeframe increases.

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Volume Profile [AnkeAlgo]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//------------------------------------------------------------------------------
// Input Groups
//------------------------------------------------------------------------------
groupPreset = "Theme & Mode"
groupProfile = "Profile"
groupLayout = "Layout"
groupDisplay = "Display"
groupTf1 = "Timeframe 1"
groupTf2 = "Timeframe 2"
groupTf3 = "Timeframe 3"
groupTf4 = "Timeframe 4"
groupStyle = "Custom Colors"

stylePreset = input.string("Lava Pulse", "Theme", options=["Quantum Ice", "Cyber Neon", "Stellar Violet", "Lava Pulse", "Mecha Titanium", "Dark Matter Green", "Supernova Gold", "Custom"], group=groupPreset)
viewMode = input.string("Flagship", "Display Mode", options=["Flagship", "Minimal"], group=groupPreset)

rows = input.int(24, "Profile Rows", minval=8, maxval=80, group=groupProfile)
valueAreaPct = input.float(70.0, "Value Area %", minval=50.0, maxval=99.0, step=1.0, group=groupProfile)

baseRightBars = input.int(10, "Right Offset Base", minval=0, maxval=120, group=groupLayout)
profileHalfWidth = input.int(7, "Profile Half Width", minval=2, maxval=24, group=groupLayout)
candleGapBars = input.int(2, "Profile to Candle Gap", minval=1, maxval=20, group=groupLayout)
candleBodyHalfWidth = input.int(2, "HTF Candle Half Width", minval=1, maxval=8, group=groupLayout)
levelExtensionBars = input.int(3, "POC/VA Extension", minval=1, maxval=20, group=groupLayout)
topLabelPaddingPct = input.float(2.5, "Top Label Padding %", minval=1.0, maxval=15.0, step=0.5, group=groupLayout)

showTfLabel = input.bool(true, "Show Timeframe Label", group=groupDisplay)
showPanelFrame = input.bool(true, "Show Panel Frame", group=groupDisplay)
showPocHighlight = input.bool(true, "Highlight POC", group=groupDisplay)
showValueAreaLines = input.bool(true, "Show POC / VAH / VAL Lines", group=groupDisplay)
showValueAreaText = input.bool(false, "Show POC / VAH / VAL Text", group=groupDisplay)
showCandle = input.bool(true, "Show HTF Candle", group=groupDisplay)
showSeparator = input.bool(false, "Show Profile Divider", group=groupDisplay)
showAnchorDot = input.bool(false, "Show Left Anchor", group=groupDisplay)
showVisualFx = input.bool(true, "Show Cinematic FX", group=groupDisplay)

tf1Enabled = input.bool(true, "Enable", inline="tf1a", group=groupTf1)
tf1 = input.timeframe("30", "TF", inline="tf1a", group=groupTf1)
tf1Offset = input.int(0, "Right Offset", minval=0, maxval=120, group=groupTf1)

tf2Enabled = input.bool(true, "Enable", inline="tf2a", group=groupTf2)
tf2 = input.timeframe("60", "TF", inline="tf2a", group=groupTf2)
tf2Offset = input.int(16, "Right Offset", minval=0, maxval=140, group=groupTf2)

tf3Enabled = input.bool(true, "Enable", inline="tf3a", group=groupTf3)
tf3 = input.timeframe("240", "TF", inline="tf3a", group=groupTf3)
tf3Offset = input.int(32, "Right Offset", minval=0, maxval=180, group=groupTf3)

tf4Enabled = input.bool(true, "Enable", inline="tf4a", group=groupTf4)
tf4 = input.timeframe("720", "TF", inline="tf4a", group=groupTf4)
tf4Offset = input.int(48, "Right Offset", minval=0, maxval=240, group=groupTf4)

customBuyColor = input.color(color.new(color.rgb(103, 220, 195), 0), "Buy Volume", group=groupStyle)
customSellColor = input.color(color.new(color.rgb(237, 106, 106), 0), "Sell Volume", group=groupStyle)
customProfileBorderColor = input.color(color.new(color.white, 70), "Profile Border", group=groupStyle)
customPanelBgColor = input.color(color.new(color.rgb(20, 26, 38), 82), "Panel Background", group=groupStyle)
customPanelBorderColor = input.color(color.new(color.white, 82), "Panel Border", group=groupStyle)
customPocHighlightColor = input.color(color.new(color.white, 86), "POC Highlight", group=groupStyle)
customTfBadgeBgColor = input.color(color.new(color.rgb(47, 60, 84), 30), "Timeframe Accent", group=groupStyle)
customWickColor = input.color(color.new(color.white, 20), "Candle Wick", group=groupStyle)
customBullBodyColor = input.color(color.new(color.rgb(84, 224, 200), 0), "Bull Candle", group=groupStyle)
customBearBodyColor = input.color(color.new(color.rgb(248, 116, 116), 0), "Bear Candle", group=groupStyle)
customSeparatorColor = input.color(color.new(color.white, 35), "Divider", group=groupStyle)
customPocColor = input.color(color.new(color.white, 0), "POC", group=groupStyle)
customVaColor = input.color(color.new(color.white, 20), "VAH/VAL", group=groupStyle)
customAnchorColor = input.color(color.new(color.white, 0), "Anchor", group=groupStyle)
customLabelTextColor = input.color(color.new(color.white, 0), "Text", group=groupStyle)

//------------------------------------------------------------------------------
// Active Palette
//------------------------------------------------------------------------------
buyColor = customBuyColor
sellColor = customSellColor
profileBorderColor = customProfileBorderColor
panelBgColor = customPanelBgColor
panelBorderColor = customPanelBorderColor
pocHighlightColor = customPocHighlightColor
tfBadgeBgColor = customTfBadgeBgColor
wickColor = customWickColor
bullBodyColor = customBullBodyColor
bearBodyColor = customBearBodyColor
separatorColor = customSeparatorColor
pocColor = customPocColor
vaColor = customVaColor
anchorColor = customAnchorColor
labelTextColor = customLabelTextColor

// Fixed internal defaults for the final release.
tfLabelSize = size.normal
tfLabelTopGapPct = 15.0

if stylePreset == "Quantum Ice"
    buyColor := color.new(color.rgb(112, 242, 229), 0)
    sellColor := color.new(color.rgb(255, 128, 170), 0)
    profileBorderColor := color.new(color.rgb(180, 240, 255), 70)
    panelBgColor := color.new(color.rgb(10, 20, 34), 80)
    panelBorderColor := color.new(color.rgb(115, 182, 255), 78)
    pocHighlightColor := color.new(color.rgb(151, 236, 255), 84)
    tfBadgeBgColor := color.new(color.rgb(34, 76, 130), 28)
    wickColor := color.new(color.rgb(220, 245, 255), 18)
    bullBodyColor := color.new(color.rgb(88, 235, 220), 0)
    bearBodyColor := color.new(color.rgb(255, 120, 156), 0)
    separatorColor := color.new(color.rgb(150, 214, 255), 40)
    pocColor := color.new(color.rgb(240, 250, 255), 0)
    vaColor := color.new(color.rgb(170, 220, 255), 18)
    anchorColor := color.new(color.rgb(190, 240, 255), 0)
    labelTextColor := color.new(color.rgb(232, 248, 255), 0)
else if stylePreset == "Cyber Neon"
    buyColor := color.new(color.rgb(0, 255, 200), 0)
    sellColor := color.new(color.rgb(255, 72, 145), 0)
    profileBorderColor := color.new(color.rgb(170, 255, 235), 62)
    panelBgColor := color.new(color.rgb(15, 10, 28), 78)
    panelBorderColor := color.new(color.rgb(255, 0, 153), 78)
    pocHighlightColor := color.new(color.rgb(255, 255, 255), 88)
    tfBadgeBgColor := color.new(color.rgb(87, 14, 132), 18)
    wickColor := color.new(color.rgb(222, 222, 255), 18)
    bullBodyColor := color.new(color.rgb(0, 255, 204), 0)
    bearBodyColor := color.new(color.rgb(255, 89, 168), 0)
    separatorColor := color.new(color.rgb(255, 90, 208), 45)
    pocColor := color.new(color.rgb(255, 255, 255), 0)
    vaColor := color.new(color.rgb(255, 150, 233), 12)
    anchorColor := color.new(color.rgb(255, 160, 230), 0)
    labelTextColor := color.new(color.rgb(244, 235, 255), 0)
else if stylePreset == "Stellar Violet"
    buyColor := color.new(color.rgb(126, 182, 255), 0)
    sellColor := color.new(color.rgb(194, 114, 255), 0)
    profileBorderColor := color.new(color.rgb(205, 210, 255), 68)
    panelBgColor := color.new(color.rgb(16, 12, 36), 78)
    panelBorderColor := color.new(color.rgb(135, 133, 255), 78)
    pocHighlightColor := color.new(color.rgb(214, 208, 255), 85)
    tfBadgeBgColor := color.new(color.rgb(66, 42, 128), 20)
    wickColor := color.new(color.rgb(235, 236, 255), 18)
    bullBodyColor := color.new(color.rgb(108, 197, 255), 0)
    bearBodyColor := color.new(color.rgb(202, 124, 255), 0)
    separatorColor := color.new(color.rgb(162, 164, 255), 42)
    pocColor := color.new(color.rgb(250, 250, 255), 0)
    vaColor := color.new(color.rgb(196, 190, 255), 15)
    anchorColor := color.new(color.rgb(210, 212, 255), 0)
    labelTextColor := color.new(color.rgb(241, 242, 255), 0)
else if stylePreset == "Lava Pulse"
    buyColor := color.new(color.rgb(255, 163, 92), 0)
    sellColor := color.new(color.rgb(255, 92, 92), 0)
    profileBorderColor := color.new(color.rgb(255, 216, 170), 70)
    panelBgColor := color.new(color.rgb(34, 16, 12), 78)
    panelBorderColor := color.new(color.rgb(255, 142, 83), 78)
    pocHighlightColor := color.new(color.rgb(255, 221, 184), 86)
    tfBadgeBgColor := color.new(color.rgb(112, 47, 17), 18)
    wickColor := color.new(color.rgb(255, 230, 214), 18)
    bullBodyColor := color.new(color.rgb(255, 168, 99), 0)
    bearBodyColor := color.new(color.rgb(255, 93, 93), 0)
    separatorColor := color.new(color.rgb(255, 176, 114), 42)
    pocColor := color.new(color.rgb(255, 248, 240), 0)
    vaColor := color.new(color.rgb(255, 208, 173), 16)
    anchorColor := color.new(color.rgb(255, 220, 196), 0)
    labelTextColor := color.new(color.rgb(255, 241, 232), 0)
else if stylePreset == "Mecha Titanium"
    buyColor := color.new(color.rgb(136, 223, 210), 0)
    sellColor := color.new(color.rgb(255, 145, 145), 0)
    profileBorderColor := color.new(color.rgb(235, 242, 248), 68)
    panelBgColor := color.new(color.rgb(24, 29, 35), 78)
    panelBorderColor := color.new(color.rgb(166, 181, 196), 78)
    pocHighlightColor := color.new(color.rgb(240, 245, 250), 86)
    tfBadgeBgColor := color.new(color.rgb(69, 81, 94), 20)
    wickColor := color.new(color.rgb(245, 247, 250), 18)
    bullBodyColor := color.new(color.rgb(133, 214, 205), 0)
    bearBodyColor := color.new(color.rgb(255, 143, 143), 0)
    separatorColor := color.new(color.rgb(197, 209, 220), 44)
    pocColor := color.new(color.rgb(255, 255, 255), 0)
    vaColor := color.new(color.rgb(210, 219, 228), 18)
    anchorColor := color.new(color.rgb(230, 236, 242), 0)
    labelTextColor := color.new(color.rgb(243, 246, 248), 0)
else if stylePreset == "Dark Matter Green"
    buyColor := color.new(color.rgb(82, 255, 174), 0)
    sellColor := color.new(color.rgb(117, 207, 255), 0)
    profileBorderColor := color.new(color.rgb(185, 255, 218), 65)
    panelBgColor := color.new(color.rgb(8, 24, 20), 78)
    panelBorderColor := color.new(color.rgb(53, 194, 146), 80)
    pocHighlightColor := color.new(color.rgb(200, 255, 225), 86)
    tfBadgeBgColor := color.new(color.rgb(18, 78, 60), 18)
    wickColor := color.new(color.rgb(224, 255, 243), 18)
    bullBodyColor := color.new(color.rgb(77, 246, 170), 0)
    bearBodyColor := color.new(color.rgb(113, 205, 255), 0)
    separatorColor := color.new(color.rgb(106, 232, 190), 42)
    pocColor := color.new(color.rgb(241, 255, 248), 0)
    vaColor := color.new(color.rgb(159, 243, 210), 14)
    anchorColor := color.new(color.rgb(210, 255, 234), 0)
    labelTextColor := color.new(color.rgb(236, 255, 245), 0)
else if stylePreset == "Supernova Gold"
    buyColor := color.new(color.rgb(255, 214, 102), 0)
    sellColor := color.new(color.rgb(255, 126, 106), 0)
    profileBorderColor := color.new(color.rgb(255, 236, 180), 66)
    panelBgColor := color.new(color.rgb(28, 20, 10), 76)
    panelBorderColor := color.new(color.rgb(255, 198, 74), 78)
    pocHighlightColor := color.new(color.rgb(255, 242, 203), 84)
    tfBadgeBgColor := color.new(color.rgb(118, 84, 18), 18)
    wickColor := color.new(color.rgb(255, 243, 219), 18)
    bullBodyColor := color.new(color.rgb(255, 212, 100), 0)
    bearBodyColor := color.new(color.rgb(255, 132, 109), 0)
    separatorColor := color.new(color.rgb(255, 213, 122), 42)
    pocColor := color.new(color.rgb(255, 252, 242), 0)
    vaColor := color.new(color.rgb(255, 223, 154), 12)
    anchorColor := color.new(color.rgb(255, 239, 201), 0)
    labelTextColor := color.new(color.rgb(255, 247, 230), 0)

//------------------------------------------------------------------------------
// Drawing State
//------------------------------------------------------------------------------
var box[] drawnBoxes = array.new_box()
var line[] drawnLines = array.new_line()
var label[] drawnLabels = array.new_label()

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
formatTfLabel(tf) =>
    string label = tf
    if str.endswith(tf, "D") or str.endswith(tf, "W") or str.endswith(tf, "M")
        label := tf
    else
        tfMinutes = str.tonumber(tf)
        if na(tfMinutes)
            label := tf
        else if tfMinutes < 60
            label := str.format("{0}m", str.tostring(int(tfMinutes)))
        else if tfMinutes % 60 == 0 and tfMinutes < 1440
            label := str.format("{0}h", str.tostring(int(tfMinutes / 60)))
        else if tfMinutes % 1440 == 0
            label := str.format("{0}D", str.tostring(int(tfMinutes / 1440)))
        else
            label := str.format("{0}m", str.tostring(int(tfMinutes)))
    label

addTransp(baseColor, extraTransp) =>
    color.new(baseColor, int(math.min(100, color.t(baseColor) + extraTransp)))

clearDrawings() =>
    if array.size(drawnBoxes) > 0
        for i = 0 to array.size(drawnBoxes) - 1
            box.delete(array.get(drawnBoxes, i))
    if array.size(drawnLines) > 0
        for i = 0 to array.size(drawnLines) - 1
            line.delete(array.get(drawnLines, i))
    if array.size(drawnLabels) > 0
        for i = 0 to array.size(drawnLabels) - 1
            label.delete(array.get(drawnLabels, i))
    array.clear(drawnBoxes)
    array.clear(drawnLines)
    array.clear(drawnLabels)

//------------------------------------------------------------------------------
// Profile Renderer
//------------------------------------------------------------------------------
drawCompletedProfile(tfRaw, enabled, startBar, endBar, periodOpen, periodHigh, periodLow, periodClose, highsArr, lowsArr, opensArr, closesArr, volsArr, offsetBars, tier) =>
    if enabled and not na(startBar) and not na(endBar) and array.size(volsArr) > 0 and not na(periodHigh) and not na(periodLow)
        periodRange = periodHigh - periodLow
        if periodRange > 0
            isMinimal = viewMode == "Minimal"
            isFlagship = viewMode == "Flagship"
            widthFactor = tier == 1 ? 0.72 : tier == 2 ? 0.88 : tier == 3 ? 1.04 : 1.2
            widthFactor := isFlagship and tier >= 3 ? widthFactor + 0.06 : widthFactor
            widthFactor := isMinimal ? math.max(0.6, widthFactor - 0.08) : widthFactor
            effectiveHalfWidth = math.max(3, int(math.round(profileHalfWidth * widthFactor)))
            effectiveCandleHalfWidth = math.max(1, int(math.round(candleBodyHalfWidth * (tier >= 3 ? 1.0 : 0.8))))
            effectiveLevelExtension = math.max(2, int(math.round(levelExtensionBars * (tier >= 3 ? 1.2 : 0.9))))
            tierTrans = tier == 1 ? 24 : tier == 2 ? 12 : tier == 3 ? 4 : 0
            tierTrans := isMinimal ? tierTrans + 8 : tierTrans
            textTrans = tier == 1 ? 45 : tier == 2 ? 25 : tier == 3 ? 10 : 0
            textTrans := isMinimal ? textTrans + 10 : textTrans
            localBuyColor = addTransp(buyColor, tierTrans)
            localSellColor = addTransp(sellColor, tierTrans)
            localProfileBorderColor = addTransp(profileBorderColor, tierTrans)
            localPanelBgColor = addTransp(panelBgColor, tier == 1 ? 6 : tier == 2 ? 2 : 0)
            localPanelBorderColor = addTransp(panelBorderColor, tier == 1 ? 10 : tier == 2 ? 6 : tier == 3 ? 2 : 0)
            localPocHighlightColor = addTransp(pocHighlightColor, tier == 1 ? 6 : tier == 2 ? 3 : 0)
            localWickColor = addTransp(wickColor, tier == 1 ? 22 : tier == 2 ? 12 : tier == 3 ? 6 : 0)
            localBullBodyColor = addTransp(bullBodyColor, tier == 1 ? 16 : tier == 2 ? 8 : tier == 3 ? 3 : 0)
            localBearBodyColor = addTransp(bearBodyColor, tier == 1 ? 16 : tier == 2 ? 8 : tier == 3 ? 3 : 0)
            localSeparatorColor = addTransp(separatorColor, tier == 1 ? 20 : tier == 2 ? 10 : 0)
            localPocColor = addTransp(pocColor, tier == 1 ? 12 : tier == 2 ? 6 : 0)
            localVaColor = addTransp(vaColor, tier == 1 ? 20 : tier == 2 ? 10 : 0)
            localAnchorColor = addTransp(anchorColor, tier == 1 ? 20 : tier == 2 ? 10 : 0)
            localLabelTextColor = addTransp(labelTextColor, textTrans)
            localBadgeColor = addTransp(tfBadgeBgColor, tier == 1 ? 18 : tier == 2 ? 10 : 4)
            tfLabelSizeLocal = size.large
            showPanelLocal = showPanelFrame and (not isMinimal or tier >= 3)
            showPocHighlightLocal = showPocHighlight and (not isMinimal or tier >= 2)
            showCandleLocal = showCandle and (not isMinimal or tier >= 2)
            showSeparatorLocal = showSeparator and (not isMinimal and tier >= 3)
            showAnchorDotLocal = showAnchorDot and (not isMinimal and tier >= 4)
            showValueAreaTextLocal = showValueAreaText and (not isMinimal and tier >= 4)
            showVisualFxLocal = showVisualFx and (not isMinimal or tier >= 2)
            showPanelAuraLocal = showVisualFxLocal and (tier >= 2 or rows <= 48)
            showHeavyFxLocal = showVisualFxLocal and rows <= 56
            pocLineWidth = tier >= 4 ? 3 : 2
            pocGlowWidth = tier >= 4 ? 5 : tier == 3 ? 4 : 3
            showFlagshipTier = isFlagship and tier >= 3
            showFlagshipMajor = isFlagship and tier == 4

            buyBins = array.new_float(rows, 0.0)
            sellBins = array.new_float(rows, 0.0)
            totalBins = array.new_float(rows, 0.0)
            binHeight = periodRange / rows

            for barIdx = 0 to array.size(volsArr) - 1
                barHigh = array.get(highsArr, barIdx)
                barLow = array.get(lowsArr, barIdx)
                barOpen = array.get(opensArr, barIdx)
                barClose = array.get(closesArr, barIdx)
                barVol = array.get(volsArr, barIdx)
                isBull = barClose >= barOpen
                barRange = math.max(barHigh - barLow, syminfo.mintick)
                targetPrice = math.min(math.max(barClose, periodLow), periodHigh - syminfo.mintick)
                targetRow = int(math.floor((targetPrice - periodLow) / binHeight))
                targetRow := math.max(0, math.min(rows - 1, targetRow))

                if barHigh <= barLow
                    if isBull
                        array.set(buyBins, targetRow, array.get(buyBins, targetRow) + barVol)
                    else
                        array.set(sellBins, targetRow, array.get(sellBins, targetRow) + barVol)
                else
                    for row = 0 to rows - 1
                        rowLow = periodLow + row * binHeight
                        rowHigh = row == rows - 1 ? periodHigh : rowLow + binHeight
                        overlap = math.max(0.0, math.min(barHigh, rowHigh) - math.max(barLow, rowLow))
                        if overlap > 0
                            volShare = barVol * overlap / barRange
                            if isBull
                                array.set(buyBins, row, array.get(buyBins, row) + volShare)
                            else
                                array.set(sellBins, row, array.get(sellBins, row) + volShare)

            totalVol = 0.0
            maxBinVol = 0.0
            pocIdx = 0
            for row = 0 to rows - 1
                rowVol = array.get(buyBins, row) + array.get(sellBins, row)
                array.set(totalBins, row, rowVol)
                totalVol += rowVol
                if rowVol > maxBinVol
                    maxBinVol := rowVol
                    pocIdx := row

            vaTarget = totalVol * valueAreaPct * 0.01
            vaCum = array.get(totalBins, pocIdx)
            lowIdx = pocIdx
            highIdx = pocIdx
            while vaCum < vaTarget and (lowIdx > 0 or highIdx < rows - 1)
                nextLowVol = lowIdx > 0 ? array.get(totalBins, lowIdx - 1) : -1.0
                nextHighVol = highIdx < rows - 1 ? array.get(totalBins, highIdx + 1) : -1.0
                if nextHighVol >= nextLowVol
                    if highIdx < rows - 1
                        highIdx += 1
                        vaCum += array.get(totalBins, highIdx)
                    else if lowIdx > 0
                        lowIdx -= 1
                        vaCum += array.get(totalBins, lowIdx)
                else
                    if lowIdx > 0
                        lowIdx -= 1
                        vaCum += array.get(totalBins, lowIdx)
                    else if highIdx < rows - 1
                        highIdx += 1
                        vaCum += array.get(totalBins, highIdx)

            centerX = last_bar_index + baseRightBars + offsetBars
            separatorX = centerX + effectiveHalfWidth + int(math.max(1, math.floor(candleGapBars * 0.5)))
            candleX = centerX + effectiveHalfWidth + candleGapBars
            levelStartX = candleX + effectiveCandleHalfWidth + 1
            levelRightX = levelStartX + effectiveLevelExtension
            anchorX = centerX - effectiveHalfWidth - 1

            pocPrice = periodLow + (pocIdx + 0.5) * binHeight
            vahPrice = periodLow + (highIdx + 1.0) * binHeight
            valPrice = periodLow + lowIdx * binHeight
            midPrice = (periodHigh + periodLow) * 0.5
            panelTop = periodHigh + periodRange * ((topLabelPaddingPct * (tier >= 3 ? 0.62 : 0.5)) * 0.01)
            panelBottom = periodLow - periodRange * (tier >= 3 ? 0.035 : 0.025)
            panelLeft = centerX - effectiveHalfWidth - 1
            panelRight = levelRightX + (tier >= 3 ? 3 : 2)
            pocRowLow = periodLow + pocIdx * binHeight
            pocRowHigh = pocIdx == rows - 1 ? periodHigh : pocRowLow + binHeight
            tfLabelY = panelTop + periodRange * (tfLabelTopGapPct * 0.01)
            vaBoxLeft = panelLeft + 1
            vaBoxRight = centerX + effectiveHalfWidth + 1
            badgeHalfWidth = int(math.max(3, effectiveHalfWidth + (tier >= 3 ? 4 : 3)))
            badgeTop = tfLabelY + periodRange * (tier >= 3 ? 0.04 : 0.032)
            badgeBottom = tfLabelY - periodRange * (tier >= 3 ? 0.028 : 0.022)
            headerStripTop = panelTop - periodRange * 0.014
            headerStripBottom = panelTop - periodRange * 0.03
            panelAuraTop = panelTop + periodRange * 0.025
            panelAuraBottom = panelBottom - periodRange * 0.03
            panelShadowTop = panelTop - periodRange * 0.02
            panelShadowBottom = panelBottom - periodRange * 0.02

            if showPanelLocal
                if showPanelAuraLocal
                    panelAuraBox = box.new(panelLeft - 1, panelAuraTop, panelRight + 1, panelAuraBottom, xloc=xloc.bar_index, bgcolor=addTransp(localBadgeColor, showFlagshipMajor ? 68 : 74), border_color=color.new(color.black, 100))
                    panelShadowBox = box.new(panelLeft + 1, panelShadowTop, panelRight + 1, panelShadowBottom, xloc=xloc.bar_index, bgcolor=color.new(color.black, showFlagshipMajor ? 84 : 88), border_color=color.new(color.black, 100))
                    array.push(drawnBoxes, panelAuraBox)
                    array.push(drawnBoxes, panelShadowBox)
                panelBox = box.new(panelLeft, panelTop, panelRight, panelBottom, xloc=xloc.bar_index, bgcolor=localPanelBgColor, border_color=localPanelBorderColor)
                array.push(drawnBoxes, panelBox)
                if showFlagshipTier
                    panelInnerBox = box.new(panelLeft + 1, panelTop - periodRange * 0.003, panelRight - 1, panelBottom + periodRange * 0.003, xloc=xloc.bar_index, bgcolor=color.new(color.black, 100), border_color=addTransp(localPanelBorderColor, 12))
                    array.push(drawnBoxes, panelInnerBox)
                if showFlagshipMajor
                    panelOuterBox = box.new(panelLeft - 1, panelTop + periodRange * 0.006, panelRight + 1, panelBottom - periodRange * 0.006, xloc=xloc.bar_index, bgcolor=color.new(color.black, 100), border_color=addTransp(localPocColor, 35))
                    array.push(drawnBoxes, panelOuterBox)
                if showVisualFxLocal
                    sellHeaderStrip = box.new(panelLeft + 1, headerStripTop, centerX, headerStripBottom, xloc=xloc.bar_index, bgcolor=addTransp(localSellColor, showFlagshipTier ? 66 : 74), border_color=color.new(color.black, 100))
                    buyHeaderStrip = box.new(centerX, headerStripTop, panelRight - 1, headerStripBottom, xloc=xloc.bar_index, bgcolor=addTransp(localBuyColor, showFlagshipTier ? 66 : 74), border_color=color.new(color.black, 100))
                    array.push(drawnBoxes, sellHeaderStrip)
                    array.push(drawnBoxes, buyHeaderStrip)

            if showFlagshipTier
                vaBandBox = box.new(vaBoxLeft, vahPrice, vaBoxRight, valPrice, xloc=xloc.bar_index, bgcolor=addTransp(localBadgeColor, 66), border_color=color.new(color.black, 100))
                array.push(drawnBoxes, vaBandBox)
                topAccentLine = line.new(panelLeft + 1, panelTop, panelRight - 1, panelTop, xloc=xloc.bar_index, color=addTransp(localPocColor, 35), width=showFlagshipMajor ? 2 : 1)
                rightAccentLine = line.new(panelRight, panelTop - periodRange * 0.004, panelRight, panelBottom + periodRange * 0.004, xloc=xloc.bar_index, color=addTransp(localPocColor, 40), width=showFlagshipMajor ? 2 : 1)
                array.push(drawnLines, topAccentLine)
                array.push(drawnLines, rightAccentLine)

            if showPocHighlightLocal
                pocGlowBox = box.new(panelLeft + 1, pocRowHigh, centerX + effectiveHalfWidth + 1, pocRowLow, xloc=xloc.bar_index, bgcolor=localPocHighlightColor, border_color=addTransp(localPocColor, 55))
                array.push(drawnBoxes, pocGlowBox)
                if showHeavyFxLocal
                    pocCoreHalfWidth = int(math.max(1, int(math.round(effectiveHalfWidth * 0.65))))
                    pocCoreBox = box.new(centerX - pocCoreHalfWidth, pocRowHigh, centerX + pocCoreHalfWidth, pocRowLow, xloc=xloc.bar_index, bgcolor=addTransp(localPocColor, 76), border_color=addTransp(localPocColor, 58))
                    array.push(drawnBoxes, pocCoreBox)

            for row = 0 to rows - 1
                buyVol = array.get(buyBins, row)
                sellVol = array.get(sellBins, row)
                rowLow = periodLow + row * binHeight
                rowHigh = row == rows - 1 ? periodHigh : rowLow + binHeight
                sellWidth = maxBinVol > 0 ? int(math.round(sellVol / maxBinVol * effectiveHalfWidth)) : 0
                buyWidth = maxBinVol > 0 ? int(math.round(buyVol / maxBinVol * effectiveHalfWidth)) : 0

                if sellWidth > 0
                    sellBox = box.new(centerX - sellWidth, rowHigh, centerX, rowLow, xloc=xloc.bar_index, bgcolor=localSellColor, border_color=localProfileBorderColor)
                    array.push(drawnBoxes, sellBox)
                if buyWidth > 0
                    buyBox = box.new(centerX, rowHigh, centerX + buyWidth, rowLow, xloc=xloc.bar_index, bgcolor=localBuyColor, border_color=localProfileBorderColor)
                    array.push(drawnBoxes, buyBox)

            if showAnchorDotLocal
                anchorDot = label.new(anchorX, midPrice, "", xloc=xloc.bar_index, style=label.style_circle, color=localAnchorColor, textcolor=localAnchorColor, size=size.tiny)
                array.push(drawnLabels, anchorDot)

            if showSeparatorLocal
                sepLine = line.new(separatorX, periodHigh, separatorX, periodLow, xloc=xloc.bar_index, color=localSeparatorColor, width=tier >= 4 ? 2 : 1)
                array.push(drawnLines, sepLine)

            if showCandleLocal
                wickLine = line.new(candleX, periodHigh, candleX, periodLow, xloc=xloc.bar_index, color=localWickColor, width=tier >= 4 ? 2 : 1)
                array.push(drawnLines, wickLine)

                rawBodyTop = math.max(periodOpen, periodClose)
                rawBodyBottom = math.min(periodOpen, periodClose)
                bodyTop = rawBodyTop
                bodyBottom = rawBodyBottom
                if rawBodyTop == rawBodyBottom
                    bodyTop += syminfo.mintick * 0.5
                    bodyBottom -= syminfo.mintick * 0.5

                bodyColor = periodClose >= periodOpen ? localBullBodyColor : localBearBodyColor
                if showHeavyFxLocal
                    bodyGlowPadding = math.max(syminfo.mintick, periodRange * 0.006)
                    bodyGlowBox = box.new(candleX - effectiveCandleHalfWidth - 1, bodyTop + bodyGlowPadding, candleX + effectiveCandleHalfWidth + 1, bodyBottom - bodyGlowPadding, xloc=xloc.bar_index, bgcolor=addTransp(bodyColor, 76), border_color=addTransp(bodyColor, 58))
                    array.push(drawnBoxes, bodyGlowBox)
                bodyBox = box.new(candleX - effectiveCandleHalfWidth, bodyTop, candleX + effectiveCandleHalfWidth, bodyBottom, xloc=xloc.bar_index, bgcolor=bodyColor, border_color=bodyColor)
                array.push(drawnBoxes, bodyBox)

            if showTfLabel
                tfLabel = formatTfLabel(tfRaw)
                if showVisualFxLocal
                    if showHeavyFxLocal
                        badgeGlowBox = box.new(centerX - badgeHalfWidth - 1, badgeTop + periodRange * 0.014, centerX + badgeHalfWidth + 1, badgeBottom - periodRange * 0.014, xloc=xloc.bar_index, bgcolor=addTransp(localBadgeColor, 74), border_color=color.new(color.black, 100))
                        array.push(drawnBoxes, badgeGlowBox)
                    badgeBox = box.new(centerX - badgeHalfWidth, badgeTop, centerX + badgeHalfWidth, badgeBottom, xloc=xloc.bar_index, bgcolor=addTransp(localBadgeColor, showFlagshipTier ? 8 : 16), border_color=addTransp(localPocColor, 48))
                    badgeConnector = line.new(centerX, badgeBottom, centerX, panelTop, xloc=xloc.bar_index, color=addTransp(localPocColor, 58), width=1)
                    array.push(drawnBoxes, badgeBox)
                    array.push(drawnLines, badgeConnector)
                tfLab = label.new(centerX, tfLabelY, tfLabel, xloc=xloc.bar_index, style=label.style_none, textcolor=localLabelTextColor, color=color.new(color.black, 100), size=tfLabelSizeLocal)
                array.push(drawnLabels, tfLab)

            if showValueAreaLines
                if showPocHighlightLocal
                    pocGlowLine = line.new(levelStartX - 1, pocPrice, levelRightX + 1, pocPrice, xloc=xloc.bar_index, color=addTransp(localPocColor, 52), width=pocGlowWidth, style=line.style_solid)
                    array.push(drawnLines, pocGlowLine)
                if showHeavyFxLocal and showFlagshipTier
                    vahGlowLine = line.new(levelStartX - 1, vahPrice, levelRightX + 1, vahPrice, xloc=xloc.bar_index, color=addTransp(localVaColor, 64), width=3, style=line.style_solid)
                    valGlowLine = line.new(levelStartX - 1, valPrice, levelRightX + 1, valPrice, xloc=xloc.bar_index, color=addTransp(localVaColor, 64), width=3, style=line.style_solid)
                    array.push(drawnLines, vahGlowLine)
                    array.push(drawnLines, valGlowLine)
                pocLine = line.new(levelStartX, pocPrice, levelRightX, pocPrice, xloc=xloc.bar_index, color=localPocColor, width=pocLineWidth, style=line.style_solid)
                vahLine = line.new(levelStartX, vahPrice, levelRightX, vahPrice, xloc=xloc.bar_index, color=localVaColor, width=1, style=line.style_dotted)
                valLine = line.new(levelStartX, valPrice, levelRightX, valPrice, xloc=xloc.bar_index, color=localVaColor, width=1, style=line.style_dotted)
                array.push(drawnLines, pocLine)
                array.push(drawnLines, vahLine)
                array.push(drawnLines, valLine)
                if showFlagshipTier
                    pocEndCap = line.new(levelRightX + 1, pocPrice + binHeight * 0.28, levelRightX + 1, pocPrice - binHeight * 0.28, xloc=xloc.bar_index, color=localPocColor, width=showFlagshipMajor ? 2 : 1)
                    array.push(drawnLines, pocEndCap)
            if showValueAreaTextLocal
                pocLab = label.new(levelRightX + 1, pocPrice, "POC", xloc=xloc.bar_index, style=label.style_none, textcolor=localLabelTextColor, color=color.new(color.black, 100), size=size.tiny)
                vahLab = label.new(levelRightX + 1, vahPrice, "VAH", xloc=xloc.bar_index, style=label.style_none, textcolor=localLabelTextColor, color=color.new(color.black, 100), size=size.tiny)
                valLab = label.new(levelRightX + 1, valPrice, "VAL", xloc=xloc.bar_index, style=label.style_none, textcolor=localLabelTextColor, color=color.new(color.black, 100), size=size.tiny)
                array.push(drawnLabels, pocLab)
                array.push(drawnLabels, vahLab)
                array.push(drawnLabels, valLab)

//------------------------------------------------------------------------------
// Timeframe State
//------------------------------------------------------------------------------
// Timeframe 1 state
var int curStart1 = na
var int curEnd1 = na
var float curOpen1 = na
var float curHigh1 = na
var float curLow1 = na
var float curClose1 = na
var int doneStart1 = na
var int doneEnd1 = na
var float doneOpen1 = na
var float doneHigh1 = na
var float doneLow1 = na
var float doneClose1 = na
var float[] curHighs1 = array.new_float()
var float[] curLows1 = array.new_float()
var float[] curOpens1 = array.new_float()
var float[] curCloses1 = array.new_float()
var float[] curVols1 = array.new_float()
var float[] doneHighs1 = array.new_float()
var float[] doneLows1 = array.new_float()
var float[] doneOpens1 = array.new_float()
var float[] doneCloses1 = array.new_float()
var float[] doneVols1 = array.new_float()

// Timeframe 2 state
var int curStart2 = na
var int curEnd2 = na
var float curOpen2 = na
var float curHigh2 = na
var float curLow2 = na
var float curClose2 = na
var int doneStart2 = na
var int doneEnd2 = na
var float doneOpen2 = na
var float doneHigh2 = na
var float doneLow2 = na
var float doneClose2 = na
var float[] curHighs2 = array.new_float()
var float[] curLows2 = array.new_float()
var float[] curOpens2 = array.new_float()
var float[] curCloses2 = array.new_float()
var float[] curVols2 = array.new_float()
var float[] doneHighs2 = array.new_float()
var float[] doneLows2 = array.new_float()
var float[] doneOpens2 = array.new_float()
var float[] doneCloses2 = array.new_float()
var float[] doneVols2 = array.new_float()

// Timeframe 3 state
var int curStart3 = na
var int curEnd3 = na
var float curOpen3 = na
var float curHigh3 = na
var float curLow3 = na
var float curClose3 = na
var int doneStart3 = na
var int doneEnd3 = na
var float doneOpen3 = na
var float doneHigh3 = na
var float doneLow3 = na
var float doneClose3 = na
var float[] curHighs3 = array.new_float()
var float[] curLows3 = array.new_float()
var float[] curOpens3 = array.new_float()
var float[] curCloses3 = array.new_float()
var float[] curVols3 = array.new_float()
var float[] doneHighs3 = array.new_float()
var float[] doneLows3 = array.new_float()
var float[] doneOpens3 = array.new_float()
var float[] doneCloses3 = array.new_float()
var float[] doneVols3 = array.new_float()

// Timeframe 4 state
var int curStart4 = na
var int curEnd4 = na
var float curOpen4 = na
var float curHigh4 = na
var float curLow4 = na
var float curClose4 = na
var int doneStart4 = na
var int doneEnd4 = na
var float doneOpen4 = na
var float doneHigh4 = na
var float doneLow4 = na
var float doneClose4 = na
var float[] curHighs4 = array.new_float()
var float[] curLows4 = array.new_float()
var float[] curOpens4 = array.new_float()
var float[] curCloses4 = array.new_float()
var float[] curVols4 = array.new_float()
var float[] doneHighs4 = array.new_float()
var float[] doneLows4 = array.new_float()
var float[] doneOpens4 = array.new_float()
var float[] doneCloses4 = array.new_float()
var float[] doneVols4 = array.new_float()

//------------------------------------------------------------------------------
// Timeframe Change Detection
//------------------------------------------------------------------------------
newTf1 = ta.change(time(tf1)) != 0
newTf2 = ta.change(time(tf2)) != 0
newTf3 = ta.change(time(tf3)) != 0
newTf4 = ta.change(time(tf4)) != 0

//------------------------------------------------------------------------------
// Aggregation
//------------------------------------------------------------------------------
if barstate.isfirst
    curStart1 := bar_index
    curEnd1 := bar_index
    curOpen1 := open
    curHigh1 := high
    curLow1 := low
    curClose1 := close
    array.push(curHighs1, high)
    array.push(curLows1, low)
    array.push(curOpens1, open)
    array.push(curCloses1, close)
    array.push(curVols1, volume)

    curStart2 := bar_index
    curEnd2 := bar_index
    curOpen2 := open
    curHigh2 := high
    curLow2 := low
    curClose2 := close
    array.push(curHighs2, high)
    array.push(curLows2, low)
    array.push(curOpens2, open)
    array.push(curCloses2, close)
    array.push(curVols2, volume)

    curStart3 := bar_index
    curEnd3 := bar_index
    curOpen3 := open
    curHigh3 := high
    curLow3 := low
    curClose3 := close
    array.push(curHighs3, high)
    array.push(curLows3, low)
    array.push(curOpens3, open)
    array.push(curCloses3, close)
    array.push(curVols3, volume)

    curStart4 := bar_index
    curEnd4 := bar_index
    curOpen4 := open
    curHigh4 := high
    curLow4 := low
    curClose4 := close
    array.push(curHighs4, high)
    array.push(curLows4, low)
    array.push(curOpens4, open)
    array.push(curCloses4, close)
    array.push(curVols4, volume)
else
    if newTf1
        doneStart1 := curStart1
        doneEnd1 := curEnd1
        doneOpen1 := curOpen1
        doneHigh1 := curHigh1
        doneLow1 := curLow1
        doneClose1 := curClose1
        doneHighs1 := array.copy(curHighs1)
        doneLows1 := array.copy(curLows1)
        doneOpens1 := array.copy(curOpens1)
        doneCloses1 := array.copy(curCloses1)
        doneVols1 := array.copy(curVols1)
        array.clear(curHighs1)
        array.clear(curLows1)
        array.clear(curOpens1)
        array.clear(curCloses1)
        array.clear(curVols1)
        curStart1 := bar_index
        curEnd1 := bar_index
        curOpen1 := open
        curHigh1 := high
        curLow1 := low
        curClose1 := close
    else
        curEnd1 := bar_index
        curHigh1 := math.max(curHigh1, high)
        curLow1 := math.min(curLow1, low)
        curClose1 := close
    array.push(curHighs1, high)
    array.push(curLows1, low)
    array.push(curOpens1, open)
    array.push(curCloses1, close)
    array.push(curVols1, volume)

    if newTf2
        doneStart2 := curStart2
        doneEnd2 := curEnd2
        doneOpen2 := curOpen2
        doneHigh2 := curHigh2
        doneLow2 := curLow2
        doneClose2 := curClose2
        doneHighs2 := array.copy(curHighs2)
        doneLows2 := array.copy(curLows2)
        doneOpens2 := array.copy(curOpens2)
        doneCloses2 := array.copy(curCloses2)
        doneVols2 := array.copy(curVols2)
        array.clear(curHighs2)
        array.clear(curLows2)
        array.clear(curOpens2)
        array.clear(curCloses2)
        array.clear(curVols2)
        curStart2 := bar_index
        curEnd2 := bar_index
        curOpen2 := open
        curHigh2 := high
        curLow2 := low
        curClose2 := close
    else
        curEnd2 := bar_index
        curHigh2 := math.max(curHigh2, high)
        curLow2 := math.min(curLow2, low)
        curClose2 := close
    array.push(curHighs2, high)
    array.push(curLows2, low)
    array.push(curOpens2, open)
    array.push(curCloses2, close)
    array.push(curVols2, volume)

    if newTf3
        doneStart3 := curStart3
        doneEnd3 := curEnd3
        doneOpen3 := curOpen3
        doneHigh3 := curHigh3
        doneLow3 := curLow3
        doneClose3 := curClose3
        doneHighs3 := array.copy(curHighs3)
        doneLows3 := array.copy(curLows3)
        doneOpens3 := array.copy(curOpens3)
        doneCloses3 := array.copy(curCloses3)
        doneVols3 := array.copy(curVols3)
        array.clear(curHighs3)
        array.clear(curLows3)
        array.clear(curOpens3)
        array.clear(curCloses3)
        array.clear(curVols3)
        curStart3 := bar_index
        curEnd3 := bar_index
        curOpen3 := open
        curHigh3 := high
        curLow3 := low
        curClose3 := close
    else
        curEnd3 := bar_index
        curHigh3 := math.max(curHigh3, high)
        curLow3 := math.min(curLow3, low)
        curClose3 := close
    array.push(curHighs3, high)
    array.push(curLows3, low)
    array.push(curOpens3, open)
    array.push(curCloses3, close)
    array.push(curVols3, volume)

    if newTf4
        doneStart4 := curStart4
        doneEnd4 := curEnd4
        doneOpen4 := curOpen4
        doneHigh4 := curHigh4
        doneLow4 := curLow4
        doneClose4 := curClose4
        doneHighs4 := array.copy(curHighs4)
        doneLows4 := array.copy(curLows4)
        doneOpens4 := array.copy(curOpens4)
        doneCloses4 := array.copy(curCloses4)
        doneVols4 := array.copy(curVols4)
        array.clear(curHighs4)
        array.clear(curLows4)
        array.clear(curOpens4)
        array.clear(curCloses4)
        array.clear(curVols4)
        curStart4 := bar_index
        curEnd4 := bar_index
        curOpen4 := open
        curHigh4 := high
        curLow4 := low
        curClose4 := close
    else
        curEnd4 := bar_index
        curHigh4 := math.max(curHigh4, high)
        curLow4 := math.min(curLow4, low)
        curClose4 := close
    array.push(curHighs4, high)
    array.push(curLows4, low)
    array.push(curOpens4, open)
    array.push(curCloses4, close)
    array.push(curVols4, volume)

//------------------------------------------------------------------------------
// Final Draw Pass
//------------------------------------------------------------------------------
if barstate.islast
    clearDrawings()
    drawCompletedProfile(tf1, tf1Enabled, doneStart1, doneEnd1, doneOpen1, doneHigh1, doneLow1, doneClose1, doneHighs1, doneLows1, doneOpens1, doneCloses1, doneVols1, tf1Offset, 1)
    drawCompletedProfile(tf2, tf2Enabled, doneStart2, doneEnd2, doneOpen2, doneHigh2, doneLow2, doneClose2, doneHighs2, doneLows2, doneOpens2, doneCloses2, doneVols2, tf2Offset, 2)
    drawCompletedProfile(tf3, tf3Enabled, doneStart3, doneEnd3, doneOpen3, doneHigh3, doneLow3, doneClose3, doneHighs3, doneLows3, doneOpens3, doneCloses3, doneVols3, tf3Offset, 3)
    drawCompletedProfile(tf4, tf4Enabled, doneStart4, doneEnd4, doneOpen4, doneHigh4, doneLow4, doneClose4, doneHighs4, doneLows4, doneOpens4, doneCloses4, doneVols4, tf4Offset, 4)
````
