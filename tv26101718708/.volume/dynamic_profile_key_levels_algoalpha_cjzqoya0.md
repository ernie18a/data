# Dynamic Profile Key Levels [AlgoAlpha]

- url: https://www.tradingview.com/script/CjZqoYa0-Dynamic-Profile-Key-Levels-AlgoAlpha/
- type: indicator
- pine_id: PUB;31adb543342f43ddad1a33bb2554ec91
- version: 1.0

## Description

🟠 OVERVIEW

Volume profiles show where trading activity is concentrated across different price levels. But a standard volume profile often focuses on the current distribution, making it harder to track how important price levels develop, persist, and react over time.

Dynamic Profile Key Levels [AlgoAlpha] combines a volume profile with volume peaks, troughs, ranked volume levels, and value area boundaries. It identifies areas of high and low trading activity and displays them as price levels or zones directly on the chart.

The indicator also tracks historical levels and identifies price breaks, rejections, and retests. This helps traders study how price responds to areas of previous trading activity without relying only on the latest volume distribution.

🟠 CONCEPTS

[list]
[*] Volume Profile — A distribution of estimated trading volume across price levels within a selected range. Each candle's volume is distributed across its price range, with an option to use lower timeframe data for more detailed estimates.

[*] Point of Control (POC) — The price row with the highest estimated trading volume in the profile. It represents the most active price area within the selected range.

[*] Value Area (VA) — A price range containing a selected percentage of total profile volume, set to 70% by default. It expands outward from the POC toward adjacent rows with higher volume. Value Area High (VAH) and Value Area Low (VAL) mark its upper and lower boundaries.

[*] High Volume Nodes (HVN) — Local peaks in the volume distribution where trading activity is higher than surrounding price rows. These areas can indicate price acceptance or consolidation.

[*] Low Volume Nodes (LVN) — Local troughs where trading activity is lower than surrounding price rows. These areas can indicate prices where less trading occurred and where price may move more quickly.

[*] Ranked Volume Levels — Price rows selected by their relative volume ranking, even when they are not local peaks or troughs. They provide additional reference levels within the distribution.

[*] Dynamic Profile — A volume profile that starts from the latest confirmed price pivot, subject to the lookback limit. Unlike a fixed lookback, its starting point changes when a new pivot is confirmed.

[*] Level Break — An event where price closes on the opposite side of a previously established level or zone.

[*] Level Rejection — An event where price touches a level or zone and closes back on the same side.

[*] Level Retest — An event where price returns to a previously broken level and closes on the breakout side within the selected retest window.
[/list]

🟠 FEATURES

[list]
[*] Adaptive Volume Profile — Displays estimated volume distribution with Fixed and Dynamic lookback modes. Supports directional coloring, separate up/down volume estimates, and relative volume coloring.
[image]https://www.tradingview.com/x/Q6XRzF1j/[/image]

[*] Multiple Key Level Types — Displays POC, VAH, VAL, volume peaks, troughs, and ranked volume rows. Peak, trough, and ranked levels can be shown as horizontal lines or shaded zones.
[image]https://www.tradingview.com/x/gTh0I5Vh/[/image]
[image]https://www.tradingview.com/x/qLBl9eXh/[/image]

[*] Historical Level Tracking — Extends identified levels across future candles and supports historical drawings. POC and value area levels also offer Current, Historical, and Developing display variants.
[image]https://www.tradingview.com/x/tEWsuSpa/[/image]

[*] Price Reaction Signals — Marks bullish and bearish breaks, rejections, and retests on confirmed candles. Includes configurable signal displays and TradingView alert conditions.
[image]https://www.tradingview.com/x/ZW2Cbjal/[/image]

[*] Level Labels and Metrics Table — Displays volume share, row strength, or estimated up-volume percentages alongside selected levels. The metrics table shows value area position, POC distance, nearby levels, and relative volume, with additional information in Detailed mode.
[image]https://www.tradingview.com/x/RqBtDObL/[/image]
[/list]

🟠 HOW TO USE

[list]
[*] Select Fixed mode to analyze a consistent number of recent candles. Use Dynamic mode when you want the profile to follow the latest confirmed swing pivot.

[*] Start with the volume profile and value area boundaries. Observe whether price trades inside the value area, above VAH, or below VAL to understand its position relative to recent trading activity.

[*] Enable the POC to identify the highest-volume price row. Watch how price behaves when it approaches or moves through this level.

[*] Use volume peaks to identify areas of concentrated trading activity. Look for consolidation, repeated reactions, or confirmed breaks around these levels.

[*] Enable volume troughs to locate areas with less historical trading activity. Observe whether price moves through these areas quickly or begins forming new trading activity.

[*] Switch peak or trough levels to Zones when you want to analyze a wider price area instead of a single horizontal level. Adjust Zone Radius to control how many surrounding price rows are included.

[*] Enable Historical Nodes to compare current price action with previous volume concentrations. Use Extend Previous Nodes to keep older levels active after they disappear from the latest profile.

[*] Watch for rejection markers when price tests a level and closes back on its original side. Use nearby levels and market structure to assess whether the reaction has room to continue.

[*] Watch for break markers when price closes through an established level. If you want to analyze subsequent retests, disable Stop Extending On Break and enable Retests.

[*] Use the Minimum RVOL setting to require stronger trading activity before accepting signals. Higher values filter out reactions that occur on relatively low volume.

[*] Check the metrics table to compare the nearest levels above and below price. Their distances are expressed in ATR units, which helps compare spacing across different volatility conditions.

[*] Adjust Profile Resolution and Lookback Limit to suit the instrument and timeframe. Higher resolution creates narrower price rows, while a longer lookback includes more historical trading activity.

[*] Use the optional lower timeframe sampling to improve the detail of the estimated volume distribution when suitable data is available. The profile remains an estimate and does not represent actual exchange bid/ask volume at each price.

[*] Combine level reactions with price structure, trend direction, and risk management before making trading decisions. Volume concentrations identify areas of interest, not guaranteed reversal or breakout points.
[/list]

🟠 CONCLUSION

Dynamic Profile Key Levels [AlgoAlpha] combines volume distribution analysis, historical price levels, and confirmed price reaction signals in one indicator. It gives traders a way to identify areas of concentrated or limited trading activity, track their development over time, and evaluate how price interacts with them.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlgoAlpha

//@version=6 
indicator("Dynamic Profile Key Levels [AlgoAlpha]", "AlgoAlpha - Dynamic Profile", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_polylines_count = 4, max_bars_back = 5000)

// Inputs
componentsGR = "Components"
showProfile = input.bool(true, "Volume Profile", inline = "mainComponents", group = componentsGR)
enablePoc = input.bool(false, "Point of Control", inline = "mainComponents", group = componentsGR, tooltip = "Shows the profile and POC. Select their variants below. Turning POC off also disables fixed POC levels and their signals.")
enableValueArea = input.bool(true, "Value Area Levels", inline = "areaComponents", group = componentsGR)
showBackground = input.bool(false, "Background", inline = "areaComponents", group = componentsGR, tooltip = "Value Area Levels enables VAH and VAL. Background shading is separate. Select Current, Historical, or Developing levels and the background type below.")
showPeaks = input.bool(true, "Volume Peaks", inline = "nodeComponents", group = componentsGR)
showTroughs = input.bool(false, "Volume Troughs", inline = "nodeComponents", group = componentsGR, tooltip = "Enables peak and trough levels. Each has a Lines or Zones variant below. Turning a level type off also disables its level signals.")
showRanked = input.bool(true, "Ranked Volume Rows", inline = "extraComponents", group = componentsGR)
keepHistory = input.bool(false, "Historical Nodes", inline = "extraComponents", group = componentsGR, tooltip = "Ranked rows add high- or low-volume rows that pass the filters. Historical Nodes keeps stopped node drawings. POC and value-area history use their own variants. History is off by default.")
showLevelLabels = input.bool(true, "Level Labels", inline = "infoComponents", group = componentsGR)
showMetrics = input.bool(true, "Metrics Table", inline = "infoComponents", group = componentsGR, tooltip = "Shows spaced labels and a metrics table. Label content, text size, and table layout are set below.")
showAccents = input.bool(true, "Visual Accents", inline = "styleComponents", group = componentsGR)
showCenterLine = input.bool(false, "Zone Center Lines", inline = "styleComponents", group = componentsGR, active = showPeaks or showTroughs or showRanked, tooltip = "Visual Accents adds profile outlines and level highlights. Zone Center Lines adds dotted lines inside enabled zones.")
focusNearby = input.bool(true, "Emphasize Nearby Levels", inline = "detailComponents", group = componentsGR)
showPrices = input.bool(false, "Label Prices", inline = "detailComponents", group = componentsGR, active = showLevelLabels, tooltip = "Near-price emphasis changes drawing contrast only. Label Prices adds the exact price to each visible label.")
showSignals = input.bool(true, "Signal Markers", group = componentsGR, tooltip = "Shows closed-bar signals for enabled fixed level types. This switch hides markers only; alerts still operate. Select the marker style below.")

historyGR = "Level Management"
keepOldActive = input.bool(true, "Extend Previous Nodes", group = historyGR, tooltip = "Keeps old nodes active until break, expiry, or storage removal. The visible-node limit only hides extra drawings; those levels remain tracked. POC and value-area lines always follow the latest profile.")
stopOnBreak = input.bool(true, "Stop Extending On Break", inline = "management", group = historyGR)
preventOverlap = input.bool(true, "Avoid Overlap", inline = "management", group = historyGR, tooltip = "Stop Extending ends a level after a close breaks through it. Disable it for later retests. Avoid Overlap blocks new nodes that overlap active nodes or POC. Value-area lines are exempt.")
showBreaks = input.bool(true, "Breaks", inline = "signalComponents", group = componentsGR, active = showSignals)
showRejections = input.bool(true, "Rejections", inline = "signalComponents", group = componentsGR, active = showSignals)
showRetests = input.bool(true, "Retests", inline = "signalComponents", group = componentsGR, active = showSignals and not stopOnBreak, tooltip = "Select which events receive markers. These switches do not disable alerts. Retests require Stop Extending On Break to be disabled.")
expiryBars = input.int(500, "Level Expiry Bars", minval = 1, maxval = 5000, group = historyGR, display = display.none)
maxLevels = input.int(150, "Maximum Stored Levels", minval = 40, maxval = 250, group = historyGR, display = display.none, tooltip = "Total active and stopped levels retained. Removes the oldest stopped level first, or the oldest active level when all are active.")

calcGR = "Calculation"
profileMode = input.string("Fixed", "Lookback Mode", options = ["Fixed", "Dynamic"], group = calcGR, display = display.none, tooltip = "Fixed uses the selected lookback. Dynamic starts at the latest confirmed pivot, within the lookback limit.")
lookback = input.int(240, "Lookback Limit", minval = 30, maxval = 1500, group = calcGR, display = display.none)
pivotLength = input.int(35, "Pivot Period", minval = 2, maxval = 250, group = calcGR, display = display.none, active = profileMode == "Dynamic", tooltip = "Bars required on each side of a pivot. A new anchor is available only after the pivot is confirmed.")
resolution = input.int(64, "Profile Resolution", minval = 20, maxval = 100, group = calcGR, display = display.none)
refreshBars = input.int(5, "Refresh Every N Bars", minval = 1, maxval = 100, group = calcGR, display = display.none, tooltip = "Rebuilds the profile on every Nth closed chart bar. Signals still use each chart-bar close. Set to 1 for each-bar profile updates.")
valueAreaPercent = input.float(70.0, "Value Area (%)", minval = 1.0, maxval = 100.0, step = 1.0, group = calcGR, display = display.none)

nodeGR = "Key Level Variants"
pocMode = input.string("Current", "POC Variant", options = ["Current", "Historical", "Developing"], group = nodeGR, display = display.none, active = enablePoc, tooltip = "Current keeps the active POC line. Historical also keeps stopped POC lines. Developing shows the POC path without creating fixed POC levels or POC signals.")
valueAreaMode = input.string("Current", "Value Area Variant", options = ["Current", "Historical", "Developing"], group = nodeGR, display = display.none, active = enableValueArea, tooltip = "Controls VAH and VAL. Current keeps active lines. Historical also keeps stopped lines. Developing shows their paths without fixed value-area levels or their signals.")
peakMode = input.string("Zones", "Peak Variant", options = ["Lines", "Zones"], inline = "peaks", group = nodeGR, display = display.none, active = showPeaks)
peakCount = input.int(2, "Max", minval = 1, maxval = 8, inline = "peaks", group = nodeGR, display = display.none, active = showPeaks, tooltip = "Maximum local volume peaks selected per profile. Existing nodes can remain active when Extend Previous Nodes is enabled.")
troughMode = input.string("Lines", "Trough Variant", options = ["Lines", "Zones"], inline = "troughs", group = nodeGR, display = display.none, active = showTroughs)
troughCount = input.int(1, "Max", minval = 1, maxval = 8, inline = "troughs", group = nodeGR, display = display.none, active = showTroughs, tooltip = "Maximum local volume troughs selected per profile. Outer profile rows are excluded.")
rankedMode = input.string("Lines", "Ranked Row Variant", options = ["Lines", "Zones"], group = nodeGR, display = display.none, active = showRanked, tooltip = "Adds ranked volume rows even when they are not local peaks or troughs. Duplicate and overlapping rows can be skipped.")
highestRows = input.int(1, "Highest Rows", minval = 0, maxval = 5, inline = "ranked", group = nodeGR, display = display.none, active = showRanked)
lowestRows = input.int(0, "Lowest Rows", minval = 0, maxval = 5, inline = "ranked", group = nodeGR, display = display.none, active = showRanked, tooltip = "Number of extra high-volume and low-volume rows. Zero excludes that side. Rows must pass the volume and overlap filters.")
zoneRadius = input.int(1, "Zone Radius (Rows)", minval = 0, maxval = 5, group = nodeGR, display = display.none, active = (showPeaks and peakMode == "Zones") or (showTroughs and troughMode == "Zones") or (showRanked and rankedMode == "Zones"), tooltip = "Rows included on each side of a node. A radius of 1 creates a three-row zone. Lines mode uses one row center.")

profileGR = "Profile Display"
profilePlacement = input.string("Right", "Placement", options = ["Right", "Left"], group = profileGR, display = display.none, active = showProfile)
profileColorMode = input.string("Directional", "Color Variant", options = ["Directional", "Up / Down", "Relative Volume"], group = profileGR, display = display.none, active = showProfile, tooltip = "Directional colors each row by estimated up/down volume balance. Up / Down splits rows into two parts. Relative Volume uses one theme-aware color. Row width represents volume, not buying or selling pressure.")
profileWidth = input.int(60, "Width", minval = 5, maxval = 200, inline = "profileSize", group = profileGR, display = display.none, active = showProfile)
profileOffset = input.int(20, "Offset", minval = 0, maxval = 250, inline = "profileSize", group = profileGR, display = display.none, active = showProfile and profilePlacement == "Right", tooltip = "Profile width and right-side offset in chart bars. Left placement starts at the first bar of the latest profile window.")
backgroundMode = input.string("Value Area", "Background Variant", options = ["Value Area", "Profile Range", "Both"], group = profileGR, display = display.none, active = showBackground, tooltip = "Shading for the latest profile only. Value Area shades the range between VAH and VAL.")

signalGR = "Signal Settings"
signalDisplay = input.string("Markers", "Marker Variant", options = ["Markers", "Markers + Text"], group = signalGR, display = display.none, active = showSignals, tooltip = "Markers uses symbols only. Markers + Text also shows the event name. New levels cannot signal on their creation bar.")
signalScope = input.string("Nodes", "Signal Levels", options = ["Nodes", "All Levels"], group = signalGR, display = display.none, tooltip = "Nodes uses peaks, troughs, and ranked rows. All Levels also uses enabled fixed POC and value-area levels. Alerts can use tracked nodes hidden by the visible-node limit.")
signalCooldown = input.int(3, "Signal Cooldown", minval = 0, maxval = 100, group = signalGR, display = display.none, tooltip = "Minimum bar spacing between accepted signals on the same level. Also applies to alerts.")
retestWindow = input.int(30, "Retest Window", minval = 1, maxval = 500, group = signalGR, display = display.none, active = not stopOnBreak, tooltip = "Maximum bars after a break for its first successful retest.")
volumeLength = input.int(20, "Volume Average", minval = 1, maxval = 200, inline = "volumeFilter", group = signalGR, display = display.none)
minimumRelativeVolume = input.float(0.0, "Minimum RVOL", minval = 0.0, maxval = 10.0, step = 0.1, inline = "volumeFilter", group = signalGR, display = display.none, tooltip = "Signal volume divided by the preceding average volume. Zero disables the filter. Also applies to alerts.")
maxSignalLabels = input.int(80, "Signal Label Limit", minval = 10, maxval = 300, group = signalGR, display = display.none, active = showSignals, tooltip = "Maximum stored signal markers. At most one label per direction per bar. Breaks take priority over retests, then rejections.")

appearanceGR = "Appearance"
visualStyle = input.string("Signature", "Accent Variant", options = ["Signature", "Volume Balance"], inline = "design", group = appearanceGR, display = display.none, active = showAccents)
contrastMode = input.string("Bright", "Contrast", options = ["Soft", "Balanced", "Bright", "Custom"], inline = "design", group = appearanceGR, display = display.none, tooltip = "Signature adds node-core shading, edge brackets, and line glow. Volume Balance replaces core shading with an up/down volume strip. Uncheck Visual Accents for plain drawings. Contrast controls transparency.")
maxVisibleNodes = input.int(8, "Visible Active Nodes", minval = 3, maxval = 100, group = appearanceGR, display = display.none, active = showPeaks or showTroughs or showRanked, tooltip = "Limits active node drawings, not stored levels or alerts. Includes one nearest node from each available family, then fills remaining slots by distance to price. POC and value-area lines are separate. History has its own checkbox.")
levelExtension = input.int(5, "Level Extension", minval = 0, maxval = 100, group = appearanceGR, display = display.none)
green = input.color(#00ffbb, "Colors", inline = "colors", group = appearanceGR)
red = input.color(#ff1100, "", inline = "colors", group = appearanceGR)
neut = input.color(color.gray, "", inline = "colors", group = appearanceGR, tooltip = "Bullish, bearish, and neutral colors. POC uses the chart foreground color.")

labelGR = "Label Settings"
labelMetric = input.string("Volume Share", "Label Content", options = ["Name", "Volume Share", "Row Strength", "Up Volume"], group = labelGR, display = display.none, active = showLevelLabels, tooltip = "Volume Share compares the row or zone with total profile volume. Row Strength compares the node row with the POC row. Up Volume uses candle direction, not actual buying volume. Values are fixed at creation and are not win probabilities.")
labelSizeInput = input.string("Tiny", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], inline = "labelSize", group = labelGR, display = display.none, active = showLevelLabels)
maxLevelLabels = input.int(8, "Max", minval = 1, maxval = 18, inline = "labelSize", group = labelGR, display = display.none, active = showLevelLabels, tooltip = "Maximum labels on visible active levels. Labels use one right-side column. Labels too close in price are skipped without moving level prices.")

tableGR = "Metrics Table"
tableMode = input.string("Compact", "Table Variant", options = ["Compact", "Detailed"], group = tableGR, display = display.none, active = showMetrics, tooltip = "Compact shows value-area position, POC distance, nearby visible levels, and relative volume. Detailed adds profile data, volume balance, level counts, and the last signal.")
tableSizeInput = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], inline = "table", group = tableGR, display = display.none, active = showMetrics)
tablePosition = input.string("Top Right", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], inline = "table", group = tableGR, display = display.none, active = showMetrics)

advancedGR = "Advanced Calculation"
peakDetection = input.float(7.0, "Peak Detection (%)", minval = 1.0, maxval = 50.0, step = 1.0, group = advancedGR, display = display.none, active = showPeaks, tooltip = "Neighbor rows checked on each side as a percentage of profile resolution. Larger values select broader peaks.")
troughDetection = input.float(7.0, "Trough Detection (%)", minval = 1.0, maxval = 50.0, step = 1.0, group = advancedGR, display = display.none, active = showTroughs)
minimumNodeVolume = input.float(1.0, "Minimum Node Volume (%)", minval = 0.0, maxval = 100.0, step = 0.5, group = advancedGR, display = display.none, tooltip = "Minimum node-row volume relative to the POC row. Empty rows are excluded.")
smoothing = input.int(1, "Node Smoothing Radius", minval = 0, maxval = 5, group = advancedGR, display = display.none, tooltip = "Smooths row volume for local peak and trough detection only. Set to 0 to disable.")
matchTolerance = input.float(0.75, "Node Match Tolerance (Rows)", minval = 0.0, maxval = 5.0, step = 0.25, group = advancedGR, display = display.none, tooltip = "Keeps an existing node when a new node of the same type is this close. Its price, bounds, and creation statistics stay fixed.")
calculationHistory = input.int(2000, "Calculation History", minval = 100, maxval = 10000, group = advancedGR, display = display.none, tooltip = "Recent chart bars used for historical profile updates and signals. Earlier bars can supply lookback data. A moving start window can change initial level state after reload.")
useLowerTimeframe = input.bool(false, "Use Lower Timeframe", group = advancedGR, tooltip = "Uses lower-timeframe candles when available; otherwise chart candles. Volume is spread uniformly across each candle range. This is estimated volume at price, not exchange bid/ask data.")
intragran = input.int(5, "Bar Granularity", minval = 2, maxval = 20, inline = "lowerTf", group = advancedGR, display = display.none, active = useLowerTimeframe)
allowSeconds = input.bool(false, "Seconds", inline = "lowerTf", group = advancedGR, active = useLowerTimeframe, tooltip = "Requests approximately the chart timeframe divided by Bar Granularity. Seconds data is optional. The Detailed table reports lower-timeframe coverage.")

styleGR = "Custom Transparency"
zoneFillTransparency = input.int(72, "Zone Fill", minval = 0, maxval = 100, inline = "zoneAlpha", group = styleGR, display = display.none, active = contrastMode == "Custom")
zoneBorderTransparency = input.int(48, "Border", minval = 0, maxval = 100, inline = "zoneAlpha", group = styleGR, display = display.none, active = contrastMode == "Custom", tooltip = "Custom zone transparency. Lower values make zones more visible. Near-price emphasis can reduce these values further.")
inactiveTransparency = input.int(78, "History", minval = 0, maxval = 100, inline = "extraAlpha", group = styleGR, display = display.none, active = contrastMode == "Custom" and (keepHistory or (enablePoc and pocMode == "Historical") or (enableValueArea and valueAreaMode == "Historical")))
profileTransparency = input.int(15, "Profile", minval = 0, maxval = 100, inline = "extraAlpha", group = styleGR, display = display.none, active = contrastMode == "Custom" and showProfile, tooltip = "Custom history and profile base transparency. Profile rows with less volume use a softer setting.")

// Input states
showPoc = enablePoc and pocMode != "Developing"
showValueArea = enableValueArea and valueAreaMode != "Developing"
showRange = showBackground and (backgroundMode == "Profile Range" or backgroundMode == "Both")
showValueAreaFill = showBackground and (backgroundMode == "Value Area" or backgroundMode == "Both")
showSignalText = signalDisplay == "Markers + Text"
zoneAlpha = contrastMode == "Custom" ? zoneFillTransparency : contrastMode == "Bright" ? 72 : contrastMode == "Balanced" ? 78 : 84
borderAlpha = contrastMode == "Custom" ? zoneBorderTransparency : contrastMode == "Bright" ? 48 : contrastMode == "Balanced" ? 58 : 68
historyAlpha = contrastMode == "Custom" ? inactiveTransparency : contrastMode == "Bright" ? 78 : contrastMode == "Balanced" ? 83 : 88
profileAlpha = contrastMode == "Custom" ? profileTransparency : contrastMode == "Bright" ? 15 : contrastMode == "Balanced" ? 28 : 42
lineAlpha = contrastMode == "Bright" or contrastMode == "Custom" ? 4 : contrastMode == "Balanced" ? 12 : 22

// Types
type BarData
    array<float> highs
    array<float> lows
    array<float> volumes
    array<float> upVolumes
    float highPrice
    float lowPrice
    bool lowerData
    bool missingVolume

type Profile
    array<float> volumes
    array<float> upVolumes
    array<float> smoothed
    float bottom
    float step
    float total
    float maximum
    float upTotal
    float poc
    float vah
    float val
    int pocRow
    int vahRow
    int valRow
    int bars
    int left
    int updated
    int lowerBars
    int missingBars
    bool valid = false

type Candidate
    int row
    int kind
    float price
    float top
    float bottom
    float share
    float strength
    float upShare
    bool matched = false

type KeyLevel
    box zone
    line ln
    int kind
    float price
    float top
    float bottom
    float share
    float strength
    float upShare
    int born
    int lastSeen
    int side
    int lastSignal = -100000
    int breakBar = -1
    int breakSide = 0
    int touchSide = 0
    int touches = 0
    bool active = true
    bool touching = false
    bool pendingTouch = false
    bool pendingRetest = false
    bool visible = true

// Variables
var bars = array.new<BarData>()
var levels = array.new<KeyLevel>()
var profileBoxes = array.new_box()
var detailBoxes = array.new_box()
var detailLines = array.new_line()
var profileContours = array.new<polyline>()
var levelLabels = array.new_label()
var signalLabels = array.new_label()
var profile = Profile.new()
var pivotIndex = 0
var lastSignalText = "None"

// Helpers
sizeFromString(txt) =>
    switch txt
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        => size.large

posFromString(txt) =>
    switch txt
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

formatPercent(value) =>
    str.tostring(value, "#.#") + "%"

isNode(kind) =>
    math.abs(kind) == 1 or math.abs(kind) == 3

usesZone(kind) =>
    switch kind
        1 => peakMode == "Zones"
        -1 => troughMode == "Zones"
        3 => rankedMode == "Zones"
        -3 => rankedMode == "Zones"
        => false

preserveHistory(kind) =>
    kind == 0 ? pocMode == "Historical" : math.abs(kind) == 2 ? valueAreaMode == "Historical" : keepHistory

nodeName(kind) =>
    switch kind
        0 => "POC"
        1 => "Peak"
        -1 => "Trough"
        2 => "VAH"
        -2 => "VAL"
        3 => "High Vol"
        => "Low Vol"

sideColor(side) =>
    side == 1 ? green : side == -1 ? red : color.from_gradient(0.3, 0, 1, neut, chart.fg_color)

clampAlpha(value) =>
    math.max(0.0, math.min(100.0, value))

themeTint(col, amount) =>
    color.from_gradient(amount, 0, 1, chart.bg_color, color.new(col, 0))

textInk(col) =>
    lightChart = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114 > 150
    lightChart ? color.from_gradient(0.42, 0, 1, col, chart.fg_color) : color.new(col, 0)

levelColor(kind, side) =>
    kind == 0 ? chart.fg_color : sideColor(side)

levelFocus(top, bottom, price, unit) =>
    distance = math.max(bottom - price, math.max(price - top, 0.0))
    focusNearby ? 1.0 - math.min(1.0, distance / (unit * 4.0)) : 0.0

nodeSymbol(kind) =>
    kind == 0 ? "◆" : kind == 1 or kind == 3 ? "●" : kind == -1 or kind == -3 ? "○" : "─"

levelText(KeyLevel item) =>
    metric = switch labelMetric
        "Volume Share" => "  " + formatPercent(item.share) + " VOL"
        "Row Strength" => "  " + formatPercent(item.strength) + " ROW"
        "Up Volume" => "  " + formatPercent(item.upShare) + " UP"
        => ""
    nodeSymbol(item.kind) + " " + str.upper(nodeName(item.kind)) + metric + (showPrices ? "  ·  " + str.tostring(item.price, format.mintick) : "")

levelTooltip(KeyLevel item) =>
    nodeName(item.kind) + " | " + str.tostring(item.price, format.mintick) + "\nVolume share at creation: " + formatPercent(item.share) + "\nRow strength at creation: " + formatPercent(item.strength) + "\nEstimated up volume at creation: " + formatPercent(item.upShare) + "\nContact episodes: " + str.tostring(item.touches) + "\nAge: " + str.tostring(bar_index - item.born) + " bars\nPercentages are not win probabilities."

addRange(array<float> values, first, last, amount) =>
    values.set(first, values.get(first) + amount)
    values.set(last + 1, values.get(last + 1) - amount)

allocateVolume(array<float> totals, array<float> ups, candleLow, candleHigh, candleVolume, candleUp, base, step) =>
    if candleVolume > 0
        first = math.max(0, math.min(resolution - 1, int(math.floor((candleLow - base) / step))))
        last = math.max(first, math.min(resolution - 1, int(math.floor((candleHigh - base) / step))))
        upRatio = math.max(0.0, math.min(1.0, candleUp / candleVolume))
        if first == last or candleHigh <= candleLow
            addRange(totals, first, first, candleVolume)
            addRange(ups, first, first, candleVolume * upRatio)
        else
            span = candleHigh - candleLow
            firstVolume = candleVolume * math.max(0.0, math.min(1.0, (base + (first + 1) * step - candleLow) / span))
            lastVolume = candleVolume * math.max(0.0, math.min(1.0, (candleHigh - base - last * step) / span))
            addRange(totals, first, first, firstVolume)
            addRange(ups, first, first, firstVolume * upRatio)
            addRange(totals, last, last, lastVolume)
            addRange(ups, last, last, lastVolume * upRatio)
            if last > first + 1
                interior = candleVolume * step / span
                addRange(totals, first + 1, last - 1, interior)
                addRange(ups, first + 1, last - 1, interior * upRatio)

smoothRows(array<float> values) =>
    result = values.copy()
    if smoothing > 0
        prefix = array.new_float(resolution + 1, 0.0)
        for i = 0 to resolution - 1
            prefix.set(i + 1, prefix.get(i) + values.get(i))
        for i = 0 to resolution - 1
            first = math.max(0, i - smoothing)
            last = math.min(resolution - 1, i + smoothing)
            result.set(i, (prefix.get(last + 1) - prefix.get(first)) / (last - first + 1))
    result

nodeAt(array<float> values, index, radius, peak) =>
    value = values.get(index)
    valid = peak or (index > 0 and index < resolution - 1)
    contrast = false
    if valid
        for j = math.max(0, index - radius) to math.min(resolution - 1, index + radius)
            if j != index
                other = values.get(j)
                if (peak ? other > value : other < value) or (other == value and j < index)
                    valid := false
                    break
                contrast := contrast or (peak ? other < value : other > value)
    valid and contrast

// Profile calculation
buildProfile(window) =>
    result = Profile.new()
    rangeHigh = bars.last().highPrice
    rangeLow = bars.last().lowPrice
    for i = 0 to window - 1
        sample = bars.get(bars.size() - 1 - i)
        rangeHigh := math.max(rangeHigh, sample.highPrice)
        rangeLow := math.min(rangeLow, sample.lowPrice)
    step = math.max((rangeHigh - rangeLow) / resolution, syminfo.mintick)
    totals = array.new_float(resolution + 1, 0.0)
    ups = array.new_float(resolution + 1, 0.0)
    lowerBars = 0
    missingBars = 0
    for i = 0 to window - 1
        sample = bars.get(bars.size() - 1 - i)
        lowerBars += sample.lowerData ? 1 : 0
        missingBars += sample.missingVolume ? 1 : 0
        for j = 0 to sample.volumes.size() - 1
            allocateVolume(totals, ups, sample.lows.get(j), sample.highs.get(j), sample.volumes.get(j), sample.upVolumes.get(j), rangeLow, step)
    rowVolumes = array.new_float(resolution, 0.0)
    rowUps = array.new_float(resolution, 0.0)
    runningTotal = 0.0
    runningUp = 0.0
    for i = 0 to resolution - 1
        runningTotal += totals.get(i)
        runningUp += ups.get(i)
        rowVolumes.set(i, math.max(0.0, runningTotal))
        rowUps.set(i, math.max(0.0, math.min(runningTotal, runningUp)))
    total = rowVolumes.sum()
    maximum = rowVolumes.max()
    pocRow = rowVolumes.indexof(maximum)
    lower = pocRow
    upper = pocRow
    areaVolume = rowVolumes.get(pocRow)
    target = total * valueAreaPercent / 100.0
    while areaVolume < target and (lower > 0 or upper < resolution - 1)
        above = upper < resolution - 1 ? rowVolumes.get(upper + 1) : -1.0
        below = lower > 0 ? rowVolumes.get(lower - 1) : -1.0
        if above >= below and upper < resolution - 1
            upper += 1
            areaVolume += rowVolumes.get(upper)
        else
            lower -= 1
            areaVolume += rowVolumes.get(lower)
    result.volumes := rowVolumes
    result.upVolumes := rowUps
    result.smoothed := smoothRows(rowVolumes)
    result.bottom := rangeLow
    result.step := step
    result.total := total
    result.maximum := maximum
    result.upTotal := rowUps.sum()
    result.poc := rangeLow + (pocRow + 0.5) * step
    result.vah := rangeLow + (upper + 1) * step
    result.val := rangeLow + lower * step
    result.pocRow := pocRow
    result.vahRow := upper
    result.valRow := lower
    result.bars := window
    result.left := bar_index - window + 1
    result.updated := bar_index
    result.lowerBars := lowerBars
    result.missingBars := missingBars
    result.valid := total > 0 and maximum > 0
    result

makeCandidate(Profile data, row, kind) =>
    radius = usesZone(kind) ? zoneRadius : 0
    first = math.max(0, row - radius)
    last = math.min(resolution - 1, row + radius)
    price = kind == 2 ? data.vah : kind == -2 ? data.val : data.bottom + (row + 0.5) * data.step
    top = usesZone(kind) ? data.bottom + (last + 1) * data.step : price
    bottom = usesZone(kind) ? data.bottom + first * data.step : price
    vol = 0.0
    up = 0.0
    for i = first to last
        vol += data.volumes.get(i)
        up += data.upVolumes.get(i)
    Candidate.new(row, kind, price, top, bottom, 100.0 * vol / data.total, 100.0 * data.volumes.get(row) / data.maximum, vol > 0 ? 100.0 * up / vol : 0.0)

rowIncluded(array<Candidate> candidates, row) =>
    included = false
    if candidates.size() > 0
        for item in candidates
            if item.row == row and math.abs(item.kind) != 2
                included := true
                break
    included

findCandidates(Profile data) =>
    candidates = array.new<Candidate>()
    if showPoc
        candidates.push(makeCandidate(data, data.pocRow, 0))
    if showValueArea
        candidates.push(makeCandidate(data, data.vahRow, 2))
        candidates.push(makeCandidate(data, data.valRow, -2))
    peakRadius = math.max(1, int(math.round(resolution * peakDetection / 100.0)))
    troughRadius = math.max(1, int(math.round(resolution * troughDetection / 100.0)))
    sorted = data.smoothed.sort_indices(order.descending)
    peaks = 0
    troughs = 0
    for rank = 0 to resolution - 1
        peakRow = sorted.get(rank)
        troughRow = sorted.get(resolution - rank - 1)
        if showPeaks and peaks < peakCount and data.volumes.get(peakRow) > 0 and data.volumes.get(peakRow) / data.maximum * 100.0 >= minimumNodeVolume
            if not rowIncluded(candidates, peakRow) and nodeAt(data.smoothed, peakRow, peakRadius, true)
                candidates.push(makeCandidate(data, peakRow, 1))
                peaks += 1
        if showTroughs and troughs < troughCount and data.volumes.get(troughRow) > 0 and data.volumes.get(troughRow) / data.maximum * 100.0 >= minimumNodeVolume
            if not rowIncluded(candidates, troughRow) and nodeAt(data.smoothed, troughRow, troughRadius, false)
                candidates.push(makeCandidate(data, troughRow, -1))
                troughs += 1
    ranked = data.volumes.sort_indices(order.descending)
    highest = 0
    lowest = 0
    for rank = 0 to resolution - 1
        highRow = ranked.get(rank)
        lowRow = ranked.get(resolution - rank - 1)
        if showRanked and highest < highestRows and data.volumes.get(highRow) > 0 and data.volumes.get(highRow) / data.maximum * 100.0 >= minimumNodeVolume and not rowIncluded(candidates, highRow)
            candidates.push(makeCandidate(data, highRow, 3))
            highest += 1
        if showRanked and lowest < lowestRows and data.volumes.get(lowRow) > 0 and data.volumes.get(lowRow) / data.maximum * 100.0 >= minimumNodeVolume and not rowIncluded(candidates, lowRow)
            candidates.push(makeCandidate(data, lowRow, -3))
            lowest += 1
    candidates

// Level helpers
removeLevel(index) =>
    item = levels.remove(index)
    item.zone.delete()
    item.ln.delete()

pruneHistory() =>
    if levels.size() > 0
        for i = levels.size() - 1 to 0
            item = levels.get(i)
            if not item.active and not preserveHistory(item.kind)
                removeLevel(i)

stopLevel(KeyLevel item) =>
    item.active := false
    if not na(item.zone)
        item.zone.set_right(bar_index)
        item.zone.set_border_color(color.new(chart.fg_color, historyAlpha))
        item.zone.set_bgcolor(color.new(chart.fg_color, clampAlpha(historyAlpha + 9)))
    if not na(item.ln)
        item.ln.set_x2(bar_index)
        item.ln.set_color(color.new(chart.fg_color, historyAlpha))
        item.ln.set_style(line.style_dotted)
        item.ln.set_width(1)

canCreate(Candidate candidate) =>
    allowed = true
    if preventOverlap and isNode(candidate.kind) and levels.size() > 0
        for item in levels
            if item.active and (isNode(item.kind) or item.kind == 0)
                overlap = candidate.top >= item.bottom and candidate.bottom <= item.top
                if overlap
                    allowed := false
                    break
    allowed

newLevel(Candidate candidate) =>
    while levels.size() >= maxLevels
        removeIndex = 0
        for i = 0 to levels.size() - 1
            if not levels.get(i).active
                removeIndex := i
                break
        removeLevel(removeIndex)
    side = close > candidate.top ? 1 : close < candidate.bottom ? -1 : 0
    col = levelColor(candidate.kind, side)
    zone = box(na)
    ln = line(na)
    useZone = usesZone(candidate.kind)
    if useZone
        zone := box.new(bar_index, candidate.top, bar_index + levelExtension, candidate.bottom, border_color = color.new(col, borderAlpha), border_width = 1, border_style = line.style_solid, bgcolor = color.new(col, zoneAlpha))
    if not useZone or showCenterLine
        ln := line.new(bar_index, candidate.price, bar_index + levelExtension, candidate.price, color = color.new(col, useZone ? 24 : lineAlpha), style = useZone ? line.style_dotted : candidate.kind == -1 or candidate.kind == -3 ? line.style_dashed : line.style_solid, width = candidate.kind == 0 ? 3 : useZone ? 1 : 2)
    levels.push(KeyLevel.new(zone, ln, candidate.kind, candidate.price, candidate.top, candidate.bottom, candidate.share, candidate.strength, candidate.upShare, bar_index, bar_index, side))

syncLevels(array<Candidate> candidates, step) =>
    created = false
    if candidates.size() > 0 and levels.size() > 0
        for candidate in candidates
            best = -1
            distance = 1e100
            tolerance = isNode(candidate.kind) ? math.max(syminfo.mintick * 0.1, step * matchTolerance) : syminfo.mintick * 0.1
            for i = 0 to levels.size() - 1
                item = levels.get(i)
                gap = math.abs(item.price - candidate.price)
                if item.active and item.kind == candidate.kind and item.lastSeen != bar_index and gap <= tolerance and gap < distance
                    best := i
                    distance := gap
            if best >= 0
                item = levels.get(best)
                item.lastSeen := bar_index
                candidate.matched := true
    if levels.size() > 0
        for item in levels
            if item.active and item.lastSeen != bar_index and (not keepOldActive or not isNode(item.kind))
                stopLevel(item)
    pruneHistory()
    if candidates.size() > 0
        for candidate in candidates
            if not candidate.matched and canCreate(candidate)
                newLevel(candidate)
                created := true
    created

addSignal(bullish, priority, details, padding) =>
    while signalLabels.size() >= maxSignalLabels
        signalLabels.shift().delete()
    name = priority == 3 ? "BREAK" : priority == 2 ? "RETEST" : "REJECT"
    symbol = priority == 2 ? "◆" : bullish ? priority == 1 ? "△" : "▲" : priority == 1 ? "▽" : "▼"
    txt = symbol + (showSignalText ? " " + name : "")
    col = bullish ? green : red
    signalLabels.push(label.new(bar_index, bullish ? low - padding : high + padding, txt, style = label.style_text_outline, color = chart.bg_color, textcolor = textInk(col), size = size.small, tooltip = details))

// Drawing helpers
addDetailLine(x1, y1, x2, y2, col, width, style) =>
    detailLines.push(line.new(x1, y1, x2, y2, color = col, width = width, style = style))

clearDetails() =>
    while profileBoxes.size() > 0
        profileBoxes.pop().delete()
    while detailBoxes.size() > 0
        detailBoxes.pop().delete()
    while detailLines.size() > 0
        detailLines.pop().delete()
    while profileContours.size() > 0
        polyline.delete(profileContours.pop())
    while levelLabels.size() > 0
        levelLabels.pop().delete()

profileRowColor(upRatio) =>
    balance = math.min(1.0, math.abs(upRatio - 0.5) * 5.0)
    col = upRatio >= 0.5 ? green : red
    color.from_gradient(math.sqrt(balance), 0, 1, color.from_gradient(0.6, 0, 1, neut, chart.fg_color), col)

accentLevel(KeyLevel item, unit) =>
    col = levelColor(item.kind, item.side)
    focus = levelFocus(item.top, item.bottom, close, unit)
    right = bar_index + levelExtension
    capStart = math.max(item.born, right - 3)
    if not na(item.zone)
        addDetailLine(right, item.bottom, right, item.top, color.new(col, clampAlpha(26 - focus * 14)), 2, line.style_solid)
        addDetailLine(capStart, item.top, right, item.top, color.new(col, 20), 2, line.style_solid)
        addDetailLine(capStart, item.bottom, right, item.bottom, color.new(col, 20), 2, line.style_solid)
        if visualStyle == "Volume Balance"
            stripLeft = math.max(item.born, right - 2)
            split = item.bottom + (item.top - item.bottom) * item.upShare / 100.0
            if split > item.bottom
                detailBoxes.push(box.new(stripLeft, split, right, item.bottom, border_color = na, bgcolor = color.new(green, 20)))
            if item.top > split
                detailBoxes.push(box.new(stripLeft, item.top, right, split, border_color = na, bgcolor = color.new(red, 20)))
        else
            halfCore = (item.top - item.bottom) / (2.0 * (zoneRadius * 2 + 1))
            detailBoxes.push(box.new(math.max(item.born, right - 28), math.min(item.top, item.price + halfCore), right, math.max(item.bottom, item.price - halfCore), border_color = na, bgcolor = color.new(col, clampAlpha(zoneAlpha - 4 - focus * 6))))
    else
        glowStart = math.max(item.born, right - 50)
        addDetailLine(glowStart, item.price, right, item.price, color.new(col, 88), item.kind == 0 ? 12 : 8, line.style_solid)
        addDetailLine(glowStart, item.price, right, item.price, color.new(col, 74), item.kind == 0 ? 6 : 4, line.style_solid)
        addDetailLine(capStart, item.price, right, item.price, color.new(col, 0), item.kind == 0 ? 3 : 2, line.style_solid)

// Chart data
ph = ta.pivothigh(pivotLength, pivotLength)
pl = ta.pivotlow(pivotLength, pivotLength)
atr = ta.atr(14)
volumeAverage = ta.sma(volume, volumeLength)
relativeVolume = not na(volume) and volumeAverage[1] > 0 ? volume / volumeAverage[1] : float(na)
volumePass = minimumRelativeVolume == 0 or (not na(relativeVolume) and relativeVolume >= minimumRelativeVolume)
chartSeconds = timeframe.in_seconds()
targetSeconds = math.max(1, int(chartSeconds / intragran))
lowerSeconds = allowSeconds ? targetSeconds : math.max(60, targetSeconds)
lowerTimeframe = timeframe.from_seconds(lowerSeconds)
lowerHighs = array.new_float()
lowerLows = array.new_float()
lowerVolumes = array.new_float()
lowerUps = array.new_float()
if useLowerTimeframe and lowerSeconds < chartSeconds
    [h, l, v, u] = request.security_lower_tf(syminfo.tickerid, lowerTimeframe, [high, low, math.max(nz(volume), 0.0), close > open ? math.max(nz(volume), 0.0) : close < open ? 0.0 : math.max(nz(volume), 0.0) * 0.5], ignore_invalid_timeframe = true, calc_bars_count = 100000)
    lowerHighs := h
    lowerLows := l
    lowerVolumes := v
    lowerUps := u

newLevelsAlert = false
bullBreak = false
bearBreak = false
bullRejection = false
bearRejection = false
bullRetest = false
bearRetest = false
bullPriority = 0
bearPriority = 0
bullDetails = ""
bearDetails = ""

// Confirmed level events
if barstate.isconfirmed and levels.size() > 0
    for item in levels
        if item.active and bar_index > item.born
            touched = high >= item.bottom and low <= item.top
            side = close > item.top ? 1 : close < item.bottom ? -1 : 0
            if touched and not item.touching
                item.touches += 1
                item.pendingTouch := true
                item.touchSide := item.side
            broke = item.side != 0 and side != 0 and side != item.side
            retested = not broke and item.pendingRetest and bar_index > item.breakBar and bar_index - item.breakBar <= retestWindow and touched and side == item.breakSide
            rejected = not broke and not retested and item.pendingTouch and item.touchSide != 0 and side == item.touchSide
            event = broke ? 3 : retested ? 2 : rejected ? 1 : 0
            allowed = signalScope == "All Levels" or isNode(item.kind)
            accepted = event > 0 and allowed and volumePass and bar_index - item.lastSignal >= signalCooldown
            if accepted
                item.lastSignal := bar_index
                bullish = side == 1
                bullBreak := bullBreak or (bullish and event == 3)
                bearBreak := bearBreak or (not bullish and event == 3)
                bullRetest := bullRetest or (bullish and event == 2)
                bearRetest := bearRetest or (not bullish and event == 2)
                bullRejection := bullRejection or (bullish and event == 1)
                bearRejection := bearRejection or (not bullish and event == 1)
                eventName = event == 3 ? "Break" : event == 2 ? "Retest" : "Rejection"
                lastSignalText := (bullish ? "Bullish " : "Bearish ") + eventName + " | " + nodeName(item.kind)
                visible = showSignals and (event == 3 ? showBreaks : event == 2 ? showRetests : showRejections)
                if visible
                    details = eventName + " | " + levelTooltip(item)
                    if bullish
                        bullPriority := math.max(bullPriority, event)
                        if str.length(bullDetails) < 8000
                            bullDetails += (bullDetails == "" ? "" : "\n\n") + details
                    else
                        bearPriority := math.max(bearPriority, event)
                        if str.length(bearDetails) < 8000
                            bearDetails += (bearDetails == "" ? "" : "\n\n") + details
            if broke
                item.breakBar := bar_index
                item.breakSide := side
                item.pendingRetest := not stopOnBreak
            else if retested or (item.pendingRetest and bar_index - item.breakBar > retestWindow)
                item.pendingRetest := false
            if broke or retested or (item.pendingTouch and side != 0)
                item.pendingTouch := false
            if side != 0
                item.side := side
            item.touching := touched
            if (broke and stopOnBreak) or bar_index - item.born >= expiryBars
                stopLevel(item)
    pruneHistory()

// Profile updates
if barstate.isconfirmed
    pivotChanged = not na(ph) or not na(pl)
    if pivotChanged
        pivotIndex := bar_index - pivotLength
    useSamples = useLowerTimeframe and lowerVolumes.size() > 0 and lowerVolumes.sum() > 0
    sampleVolume = math.max(nz(volume), 0.0)
    sampleUp = close > open ? sampleVolume : close < open ? 0.0 : sampleVolume * 0.5
    h = useSamples ? lowerHighs : array.from(high)
    l = useSamples ? lowerLows : array.from(low)
    v = useSamples ? lowerVolumes : array.from(sampleVolume)
    u = useSamples ? lowerUps : array.from(sampleUp)
    bars.push(BarData.new(h, l, v, u, math.max(high, h.max()), math.min(low, l.min()), useSamples, na(volume) and not useSamples))
    while bars.size() > lookback
        bars.shift()
    window = profileMode == "Dynamic" ? math.min(bars.size(), math.max(1, bar_index - pivotIndex + 1)) : bars.size()
    inHistory = bar_index >= last_bar_index - calculationHistory + 1
    refresh = na(profile.updated) or bar_index % refreshBars == 0 or (profileMode == "Dynamic" and pivotChanged)
    if inHistory and window >= 10 and refresh
        profile := buildProfile(window)
        candidates = profile.valid ? findCandidates(profile) : array.new<Candidate>()
        newLevelsAlert := syncLevels(candidates, profile.step)

// Level visuals
visualUnit = math.max(nz(atr, high - low), syminfo.mintick)
if levels.size() > 0
    distances = array.new_float(levels.size(), 1e100)
    for i = 0 to levels.size() - 1
        item = levels.get(i)
        if item.active
            item.visible := not isNode(item.kind)
            distances.set(i, math.max(item.bottom - close, math.max(close - item.top, 0.0)))
    rankedVisible = distances.sort_indices(order.ascending)
    families = array.new_bool(3, false)
    shownNodes = 0
    for index in rankedVisible
        item = levels.get(index)
        if item.active and isNode(item.kind)
            family = item.kind == 1 ? 0 : item.kind == -1 ? 1 : 2
            if not families.get(family)
                item.visible := true
                families.set(family, true)
                shownNodes += 1
    for index in rankedVisible
        item = levels.get(index)
        if item.active and isNode(item.kind) and not item.visible and shownNodes < maxVisibleNodes
            item.visible := true
            shownNodes += 1
    for item in levels
        if item.active
            col = levelColor(item.kind, item.side)
            focus = levelFocus(item.top, item.bottom, close, visualUnit)
            if not na(item.zone)
                item.zone.set_right(bar_index + levelExtension)
                item.zone.set_bgcolor(item.visible ? color.new(col, clampAlpha(zoneAlpha - focus * 6)) : na)
                item.zone.set_border_color(item.visible ? color.new(col, clampAlpha(borderAlpha - focus * 8)) : na)
            if not na(item.ln)
                item.ln.set_x2(bar_index + levelExtension)
                item.ln.set_color(item.visible ? color.new(col, not na(item.zone) ? clampAlpha(24 - focus * 10) : lineAlpha) : na)

if bullPriority > 0
    addSignal(true, bullPriority, bullDetails, math.max(nz(atr, high - low) * 0.2, syminfo.mintick * 2))
if bearPriority > 0
    addSignal(false, bearPriority, bearDetails, math.max(nz(atr, high - low) * 0.2, syminfo.mintick * 2))

// Latest profile visuals
if barstate.islast
    clearDetails()
    rightPlacement = profilePlacement == "Right"
    histogramStart = rightPlacement ? bar_index + profileOffset : nz(profile.left, bar_index)
    histogramWidth = rightPlacement ? profileWidth : math.min(profileWidth, nz(profile.bars, 1))
    histogramEnd = histogramStart + histogramWidth
    if profile.valid
        if showRange
            profileBoxes.push(box.new(profile.left, profile.bottom + resolution * profile.step, bar_index, profile.bottom, border_color = color.new(chart.fg_color, 76), bgcolor = color.new(chart.fg_color, 94)))
        if showValueAreaFill
            profileBoxes.push(box.new(profile.left, profile.vah, bar_index, profile.val, border_color = na, bgcolor = color.new(chart.fg_color, 92)))
        if showProfile
            outline = array.new<chart.point>()
            edgeX = rightPlacement ? histogramEnd : histogramStart
            accent = profileRowColor(profile.upTotal / profile.total)
            for i = 0 to resolution - 1
                vol = profile.volumes.get(i)
                share = vol / profile.maximum
                width = vol > 0 ? math.max(1, int(math.round(share * histogramWidth))) : 0
                left = rightPlacement ? histogramEnd - width : histogramStart
                right = left + width
                rowBottom = profile.bottom + i * profile.step
                rowTop = rowBottom + profile.step
                top = rowTop - profile.step * 0.09
                bottom = rowBottom + profile.step * 0.09
                contourX = rightPlacement ? left : right
                outline.push(chart.point.from_index(contourX, rowBottom))
                outline.push(chart.point.from_index(contourX, rowTop))
                if vol > 0
                    upRatio = math.max(0.0, math.min(1.0, profile.upVolumes.get(i) / vol))
                    inValueArea = i >= profile.valRow and i <= profile.vahRow
                    isPoc = i == profile.pocRow
                    rowAlpha = clampAlpha(profileAlpha + (1.0 - math.sqrt(share)) * 22 + (inValueArea ? 0 : 12))
                    rowCol = profileColorMode == "Relative Volume" ? chart.fg_color : profileRowColor(upRatio)
                    border = isPoc ? color.new(chart.fg_color, 0) : color.new(rowCol, clampAlpha(rowAlpha + 16))
                    if profileColorMode == "Up / Down"
                        split = left + int(math.round(width * upRatio))
                        if split > left
                            profileBoxes.push(box.new(left, top, split, bottom, border_color = isPoc ? border : color.new(green, clampAlpha(rowAlpha + 16)), bgcolor = color.new(green, rowAlpha)))
                        if right > split
                            profileBoxes.push(box.new(split, top, right, bottom, border_color = isPoc ? border : color.new(red, clampAlpha(rowAlpha + 16)), bgcolor = color.new(red, rowAlpha)))
                    else
                        profileBoxes.push(box.new(left, top, right, bottom, border_color = border, border_width = isPoc ? 2 : 1, bgcolor = color.new(rowCol, isPoc ? math.max(0.0, rowAlpha - 8) : rowAlpha)))
            if showAccents
                profileContours.push(polyline.new(outline, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.new(accent, 87), line_width = 5))
                profileContours.push(polyline.new(outline, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.new(accent, 25), line_width = 1))
                addDetailLine(edgeX, profile.bottom, edgeX, profile.bottom + resolution * profile.step, color.new(chart.fg_color, 66), 1, line.style_solid)
                addDetailLine(edgeX, profile.val, edgeX, profile.vah, color.new(accent, 8), 3, line.style_solid)
                tickX = edgeX + (rightPlacement ? 3 : -3)
                tickX := math.max(0, tickX)
                addDetailLine(edgeX, profile.vah, tickX, profile.vah, color.new(accent, 8), 2, line.style_solid)
                addDetailLine(edgeX, profile.val, tickX, profile.val, color.new(accent, 8), 2, line.style_solid)
                addDetailLine(edgeX, profile.poc, tickX, profile.poc, chart.fg_color, 3, line.style_solid)
    if levels.size() > 0
        distances = array.new_float(levels.size(), 1e100)
        for i = 0 to levels.size() - 1
            item = levels.get(i)
            if item.active and item.visible
                distances.set(i, math.max(item.bottom - close, math.max(close - item.top, 0.0)))
        rankedLevels = distances.sort_indices(order.ascending)
        labelPrices = array.new_float()
        detailCount = 0
        labelX = showProfile and rightPlacement ? math.max(bar_index + levelExtension + 4, histogramEnd + 7) : bar_index + levelExtension + 4
        labelGap = math.max(visualUnit * (labelSizeInput == "Tiny" ? 0.3 : labelSizeInput == "Small" ? 0.45 : labelSizeInput == "Normal" ? 0.65 : 0.9), syminfo.mintick * 4)
        for index in rankedLevels
            item = levels.get(index)
            if not item.active or not item.visible
                break
            if showAccents and detailCount < 16
                accentLevel(item, visualUnit)
                detailCount += 1
            if showLevelLabels and labelPrices.size() < maxLevelLabels
                clear = true
                if labelPrices.size() > 0
                    for otherPrice in labelPrices
                        if math.abs(item.price - otherPrice) < labelGap
                            clear := false
                            break
                if clear
                    col = levelColor(item.kind, item.side)
                    addDetailLine(bar_index + levelExtension, item.price, labelX, item.price, color.new(col, 64), 1, line.style_dotted)
                    levelLabels.push(label.new(labelX, item.price, " " + levelText(item) + " ", color = not showAccents ? chart.bg_color : themeTint(col, 0.14), textcolor = textInk(col), style = label.style_label_left, size = sizeFromString(labelSizeInput), tooltip = levelTooltip(item)))
                    labelPrices.push(item.price)

// Developing paths
plot(enablePoc and pocMode == "Developing" and profile.valid ? profile.poc : na, "Developing POC", color = chart.fg_color, linewidth = 3, style = plot.style_stepline)
plot(enableValueArea and valueAreaMode == "Developing" and profile.valid ? profile.vah : na, "Developing VAH", color = color.new(red, lineAlpha + 12), linewidth = 2, style = plot.style_stepline)
plot(enableValueArea and valueAreaMode == "Developing" and profile.valid ? profile.val : na, "Developing VAL", color = color.new(green, lineAlpha + 12), linewidth = 2, style = plot.style_stepline)

// Metrics table
var metrics = showMetrics ? table.new(posFromString(tablePosition), 2, tableMode == "Detailed" ? 12 : 6, bgcolor = themeTint(chart.fg_color, 0.04), border_width = 0, frame_color = color.new(chart.fg_color, 65), frame_width = 1) : table(na)

metricRow(row, title, value, col) =>
    header = row == 0
    background = header ? themeTint(green, 0.18) : themeTint(chart.fg_color, row % 2 == 0 ? 0.055 : 0.025)
    table.cell(metrics, 0, row, "  " + title + "  ", bgcolor = background, text_color = header ? textInk(green) : color.new(chart.fg_color, 12), text_halign = text.align_left, text_size = sizeFromString(tableSizeInput))
    table.cell(metrics, 1, row, "  " + value + "  ", bgcolor = header ? background : themeTint(col, 0.08), text_color = textInk(col), text_halign = text.align_right, text_size = sizeFromString(tableSizeInput))

if barstate.islast
    if showMetrics
        table.clear(metrics, 0, 0, 1, tableMode == "Detailed" ? 11 : 5)
        active = 0
        aboveDistance = float(na)
        belowDistance = float(na)
        aboveText = "None"
        belowText = "None"
        atrUnit = math.max(nz(atr, high - low), syminfo.mintick)
        if levels.size() > 0
            for item in levels
                if item.active
                    active += 1
                    if item.visible and item.bottom > close and (na(aboveDistance) or item.bottom - close < aboveDistance)
                        aboveDistance := item.bottom - close
                        aboveText := nodeName(item.kind) + " " + str.tostring(item.bottom, format.mintick) + " | " + str.tostring(aboveDistance / atrUnit, "#.##") + " ATR"
                    if item.visible and item.top < close and (na(belowDistance) or close - item.top < belowDistance)
                        belowDistance := close - item.top
                        belowText := nodeName(item.kind) + " " + str.tostring(item.top, format.mintick) + " | " + str.tostring(belowDistance / atrUnit, "#.##") + " ATR"
        ready = profile.valid
        positionText = not ready ? "No volume profile" : close > profile.vah ? "Above value" : close < profile.val ? "Below value" : "Inside value"
        balance = ready ? profile.upTotal / profile.total * 100.0 : float(na)
        pocDistance = ready ? (close - profile.poc) / atrUnit : float(na)
        dataText = not ready ? "No positive volume" : useLowerTimeframe ? formatPercent(100.0 * profile.lowerBars / profile.bars) + " LTF coverage" : "Chart candles"
        profileText = na(profile.updated) ? "Waiting for closed bars" : profileMode + " | " + str.tostring(profile.bars) + " bars | age " + str.tostring(bar_index - profile.updated)
        volumeText = ready ? str.tostring(profile.total, format.volume) + (profile.missingBars > 0 ? " | " + str.tostring(profile.missingBars) + " missing" : "") : "N/A"
        metricRow(0, "AlgoAlpha", "DYNAMIC PROFILE", chart.fg_color)
        metricRow(1, "Value area", positionText, not ready ? neut : close > profile.vah ? green : close < profile.val ? red : neut)
        metricRow(2, "POC distance", ready ? (pocDistance >= 0 ? "+" : "") + str.tostring(pocDistance, "#.##") + " ATR" : "N/A", not ready ? neut : pocDistance >= 0 ? green : red)
        metricRow(3, "Nearest above", aboveText, red)
        metricRow(4, "Nearest below", belowText, green)
        metricRow(5, "Relative volume", na(relativeVolume) ? "N/A" : str.tostring(relativeVolume, "#.##") + "x", volumePass ? chart.fg_color : neut)
        if tableMode == "Detailed"
            metricRow(6, "Profile", profileText, chart.fg_color)
            metricRow(7, "Profile volume", volumeText, chart.fg_color)
            metricRow(8, "Sampling", dataText, chart.fg_color)
            metricRow(9, "Up / down estimate", ready ? formatPercent(balance) + " / " + formatPercent(100.0 - balance) : "N/A", not ready ? neut : balance >= 50 ? green : red)
            metricRow(10, "Active / stored", str.tostring(active) + " / " + str.tostring(levels.size()), chart.fg_color)
            metricRow(11, "Last signal", lastSignalText, chart.fg_color)

// Alerts
alertcondition(newLevelsAlert, title = "New Profile Key Level")
alertcondition(bullBreak, title = "Bullish Key Level Break")
alertcondition(bearBreak, title = "Bearish Key Level Break")
alertcondition(bullRejection, title = "Bullish Key Level Rejection")
alertcondition(bearRejection, title = "Bearish Key Level Rejection")
alertcondition(bullRetest, title = "Bullish Key Level Retest")
alertcondition(bearRetest, title = "Bearish Key Level Retest")
alertcondition(bullBreak or bullRejection or bullRetest, title = "Any Bullish Key Level Signal")
alertcondition(bearBreak or bearRejection or bearRetest, title = "Any Bearish Key Level Signal")
````
