# Aurora SPI

- url: https://www.tradingview.com/script/HRcryObA-Aurora-SPI/
- type: indicator
- pine_id: PUB;e2cc9f84e81340e69e7d64ab19610ffb
- version: 6.0

## Description

█ [b]Aurora Profile[/b]

A session volume profile is often read as a histogram beside the chart: a prominent row, a value area, and perhaps a few obvious gaps. Aurora Profile starts with that same distribution and asks a more detailed question: what is happening inside its peaks, valleys, edges, and smaller corridors while the session is still forming?

The indicator turns the developing profile into a price map. It shows the volume distribution, POC, VAH, VAL, local volume zones, profile row levels, estimated directional participation, and three session based VWAP references together. Its purpose is to make the shape of the session easier to examine, from the broadest area of activity down to an individual price row.

Aurora Profile is designed especially for traders who work with intraday and CFD charts. It treats the profile as changing information. A zone represents a feature of the current distribution, not a permanent support or resistance promise.

█ [b]Reading a session profile as a landscape[/b]

Volume at price describes where the available feed reported activity during the selected session. A large row says activity accumulated at that price. A thin row says comparatively little activity was allocated there. Neither observation, on its own, explains who is in control or what price must do next.

The relationship between neighboring rows gives the profile its structure. A high volume node can be a compact peak or part of a wider concentration. A low volume node can be a narrow gap or a corridor extending through several rows. Even a broad corridor may contain a particularly quiet row, a more active row, or a small pocket worth separating from the surrounding area.

Aurora Profile reads these relationships at several scales. The main profile provides the full session view. Its zones identify local formations above and below the current price. Optional row markers point to the lowest or highest measured volume inside a zone. Smaller areas and outer bands give a closer view of selected corridors. This lets the trader examine both the overall shape and the exact part of that shape price is approaching.

The profile starts at the configured session boundary. The default is 00:00 in Europe/Berlin. As volume arrives or the session high or low changes, the rows are recalculated and the profile zones are reconciled with the new distribution.


█ [b]How activity is placed into price rows[/b]

The current session price range is divided into a configurable number of rows. Each analysis candle allocates its available volume across the rows touched by its high to low range. A candle spanning several rows contributes to each overlapping row rather than placing all of its volume at the close.

[pine]
float overlap = math.max(0.0, math.min(candleHigh, rowTop) - math.max(candleLow, rowBottom))
float rowVolume = candleHigh > candleLow ? candleVolume * overlap / (candleHigh - candleLow) : 0.0
[/pine]

This is a distribution model built from the available candles. It is not a trade by trade reconstruction. Smaller analysis candles can add detail when the feed provides them, while missing or unsuitable lower timeframe data falls back to the chart candle for the profile.

POC marks the price row with the largest allocated volume. The value area grows outward from POC, choosing the more active neighboring row until the selected fraction of session volume is included. VAH and VAL mark its upper and lower boundaries. The default value area target is 70 percent.

These levels are a starting point for reading the session. A trader can first locate the main concentration, then ask how the thinner areas, local peaks, and new activity relate to it.


█ [b]From nodes to areas[/b]

[b]LVN corridors[/b]

An LVN is a local valley relative to the profile rows around it. Aurora compares a potential low row with nearby shoulders, checks the required depth, and can expand the result into a wider low activity corridor. A broad LVN therefore appears as an area rather than a single arbitrary line.

[b]HVN areas[/b]

An HVN is a local peak or concentration. Its prominence and minimum activity must meet the selected thresholds. Nearby active rows can form one compact area. The LVN and HVN scans examine both sides of the current price, so relevant structure can appear above or below the market.

[b]High intensity local lows[/b]

The HIL module looks for a small dip between relatively active shoulders. It is separate from the standard LVN scan and is limited to one, two, or three profile rows. This can reveal a thin seam inside a denser part of the distribution.

[b]High intensity corridor blocks[/b]

The HIB module is a separate search for a wider, multirow valley bounded by active shoulders. It draws the full qualifying block, then optionally marks the lowest volume row, highest volume row, or both within that block. Off, Lowest, Highest, and Both are available as modes. The original short HIL detector remains independent, so the compact dip and the wider corridor can each be assessed on their own terms.

[b]Detail within and around a zone[/b]

A long LVN or HVN can contain a more specific local area. Aurora can shade that smaller area at the right end of the broader zone. Optional beige bands identify exactly one profile row immediately outside the top and bottom of an eligible LVN corridor. These are the edges beside the corridor, not extra LVN detections.

For LVN and HVN zones, dashed row markers can show the lowest and highest volume rows inside the area. The corresponding HIB markers use their own color setting. A line can remain inside its zone or use the longer POC span mode. The block and the row markers answer different questions: where is the whole formation, and where inside it is the selected volume extreme?

█ [b]What a changing zone means[/b]

The profile is a live description of the current session. If new volume changes a valley or peak, the matching zone can adjust. If that feature disappears, its profile zone disappears too; if a new feature develops, Aurora can add it on a later scan. Profile areas are shown as Fresh or Visited. A price crossing does not erase a volume node by itself.

This behavior matters because a session profile is not a collection of fixed historical boxes. It is a distribution whose shape evolves. A zone may be worth examining because price reacts to it, but the profile itself must continue to support that zone as the session develops.

The optional smaller area inside a long zone helps distinguish the broad corridor from the row cluster currently standing out within it. A narrow HIL and a wider HIB can also coexist when their independent rules describe different scales of the same profile.


█ [b]Directional pressure as an additional layer[/b]

The profile histogram can display estimated Buy and Sell portions of the available feed volume. Aurora also looks for a change in estimated directional dominance at the same price rows across two consecutive analysis windows. A Buy takeover requires prior Sell dominance, current Buy dominance, and confirmation from the selected number of recent analysis candles. A Sell takeover reverses those conditions.

Buy and Sell takeover areas are independent of the LVN, HVN, HIL, and HIB detections. A takeover can occur inside a profile node or elsewhere. Their states are Fresh, Touched, and Broken; broken takeover areas can be hidden or retained.

Compact labels identify the area and its volume. Hover over a label for modeled Buy and Sell proportions, approximate delta, zone state, visit information when enabled, and the analysis source. Labels sharing the exact same profile row move into adjacent columns; labels on different rows keep their normal positions.

[pine]
float buyPct = zoneV > 0 ? zoneUp / zoneV * 100.0 : 50.0
float sellPct = 100.0 - buyPct
float estimatedDelta = 2.0 * zoneUp - zoneV
[/pine]

The default directional estimate relates price change to preceding rolling volatility and maps it through an approximate normal distribution. During warmup or when the estimate cannot be formed, the split is neutral. Candle direction and intrabar direction are alternative modes.

For CFDs, the feed may report tick activity or another provider specific volume measure. Aurora cannot verify executed aggressive orders from that series. Buy and Sell here describe modeled participation, not confirmed order flow or exchange footprint data.


█ [b]VWAP references around the profile[/b]

Aurora includes a VWAP from the session start, a VWAP anchored at the latest session high, and a VWAP anchored at the latest session low. When a new high or low is made, the respective extreme anchor restarts.

[pine]
float sessionVWAP = sessionV > 0 ? sessionPV / sessionV : na
float highAnchoredVWAP = highV > 0 ? highPV / highV : na
float lowAnchoredVWAP = lowV > 0 ? lowPV / lowV : na
[/pine]

These paths give a second way to frame location. A low volume corridor near session VWAP is different context from a corridor far from session value. A return into an HVN while an extreme anchored VWAP moves through it can be examined differently from an isolated touch of the same node. VWAP does not change what the profile measured; it helps place that measurement in the session's price path.


█ [b]A practical reading sequence[/b]

1. Define the session and confirm what the chart's volume series represents. The default reset is midnight Europe/Berlin.

2. Read the broad distribution first: POC, VAH, VAL, the main concentrations, and the gaps between them.

3. Inspect the relevant LVN and HVN areas. Ask whether a feature is a single row, a compact cluster, or a corridor.

4. Use HIL for a short local dip and HIB for a wider bounded corridor. In a block, compare the selected lowest and highest volume rows with its full height.

5. Check the smaller local area, any beige LVN edge bands, and the session or extreme anchored VWAP paths. They provide more precise location within the broad structure.

6. Read takeover zones and their tooltips as estimated pressure context. Watch how price interacts with the area; a colored box or a row line is not an entry instruction.


█ [b]Controls and interpretation[/b]

The Profile settings control row resolution, histogram width, POC, value area, and display. Zone Detection controls LVN and HVN thresholds, smoothing, zone width, local areas, and row markers. High Intensity Profile Lows contains both the original short HIL scan and the independent corridor block module, including its row mode, shoulder search, contrast, and block height. The pressure settings control the comparison windows and confirmation. Theme presets are available for light and dark charts, with a custom mode for personal colors.

Aurora displays the latest session. Its profile and profile zones may change while that session develops. Pressure events commit on closed chart candles; live tooltip values can be provisional. Results also depend on timeframe, available lower timeframe candles, and the volume series supplied by the chart provider.

Aurora Profile is a way to read more of the session's volume structure. Use its areas as context for observation, confirmation, and your own risk process rather than as promises about the next price move.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Drizzle_Algo56
//@version=6
indicator("Aurora SPI", shorttitle = "Aurora SPI" ,overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 250, max_polylines_count = 5)


const int MAX_SESSION_BARS = 3000
const int MAX_SESSION_SAMPLES = 20000

string gTheme = "0. Theme"
string themeMode = input.string("Custom", "Theme preset", options = ["Light", "Dark", "Custom"], tooltip = "Light and Dark apply preset colors; the LVN/HVN row-line picker always applies. Custom uses the other color pickers.", group = gTheme)
color customVaColor = input.color(color.rgb(213, 137, 38), "VAH / VAL color", group = gTheme)
color customUpColor = input.color(color.rgb(76, 207, 224), "Estimated Buy~ volume", group = gTheme)
color customDownColor = input.color(color.rgb(255, 116, 171), "Estimated Sell~ volume", group = gTheme)
color customLvnColor = input.color(color.rgb(116, 88, 204), "LVN color", group = gTheme)
color customHvnColor = input.color(color.rgb(53, 133, 206), "HVN color", group = gTheme)
color profileRowLineColor = input.color(color.black, "LVN / HVN highest and lowest lines", group = gTheme)
color customPressureBuyColor = input.color(color.rgb(31, 158, 99), "Buy takeover", group = gTheme)
color customPressureSellColor = input.color(color.rgb(210, 78, 89), "Sell takeover", group = gTheme)
color customOuterColor = input.color(color.rgb(225, 184, 123), "LVN outer rows", group = gTheme)
color customIntensityColor = input.color(color.rgb(35, 196, 210), "High-intensity low zones", group = gTheme)
color customIntensityBlockColor = input.color(color.rgb(188, 147, 99), "High-intensity corridor blocks", group = gTheme)
color intensityBlockLineColor = input.color(color.rgb(240, 152, 42), "High-intensity block row lines", group = gTheme)
color customSessionColor = input.color(color.rgb(40, 44, 46), "Session VWAP / POC", group = gTheme)
color customHighColor = input.color(color.rgb(20, 173, 157), "High-anchored VWAP", group = gTheme)
color customLowColor = input.color(color.rgb(20, 173, 157), "Low-anchored VWAP", group = gTheme)

string gSession = "1. Session"
string sessionHours = input.session("0000-0000", "Session hours", group = gSession)
string sessionDays = input.string("Every day", "Session days", options = ["Every day", "Weekdays"], group = gSession)
string timezoneInput = input.string("Europe/Berlin", "Timezone (Exchange or IANA name)", tooltip = "Chart timezone is display-only. Default resets at Berlin midnight.", group = gSession)
float source = input.source(hlc3, "VWAP source", group = gSession)

string gProfile = "2. Profile / value area"
bool showProfile = input.bool(true, "Show left volume profile", group = gProfile)
int rows = input.int(200, "Price rows", minval = 30, maxval = 250, group = gProfile)
float profileWidth = input.float(28, "Profile width (% of session)", minval = 5, maxval = 50, group = gProfile)
bool showPOC = input.bool(true, "Show POC", group = gProfile)
bool showVA = input.bool(true, "Show VAH / VAL", group = gProfile)
float vaPercent = input.float(70, "Value area volume (%)", minval = 1, maxval = 100, group = gProfile)
bool showBackdrop = input.bool(false, "Session range background", group = gProfile)

string gZones = "3. Zone detection"
bool showZones = input.bool(true, "Show zones", group = gZones)
bool showProfileZones = input.bool(true, "Show LVN / HVN zones", group = gZones)
string zoneMode = input.string("LVN + HVN", "Zone mode", options = ["LVN", "HVN", "LVN + HVN"], group = gZones)
int maxZones = input.int(20, "Maximum retained zones per type on each side", minval = 1, maxval = 25, group = gZones)
int minimumBars = input.int(20, "Minimum session candles", minval = 5, maxval = 300, group = gZones)
int detectionEvery = input.int(1, "Periodic zone scan (candles)", minval = 1, maxval = 60, tooltip = "Profile zones are reconciled with the current profile on each scan and whenever the session range expands.", group = gZones)
int smoothRadius = input.int(0, "Smoothing radius (rows)", minval = 0, maxval = 4, tooltip = "Zero preserves narrow volume valleys. Increase to suppress noisy nodes.", group = gZones)
int peakWindow = input.int(8, "Side peak / valley search (rows)", minval = 2, maxval = 20, group = gZones)
float minDepth = input.float(25, "Minimum LVN depth / HVN prominence (%)", minval = 5, maxval = 95, group = gZones)
float minHVN = input.float(10, "HVN minimum volume (% of maximum row)", minval = 1, maxval = 100, group = gZones)
float zoneRise = input.float(20, "Zone width (% of node-to-shoulder difference)", minval = 0, maxval = 70, group = gZones)
int maxZoneRows = input.int(4, "Maximum HVN zone thickness (rows)", minval = 1, maxval = 10, group = gZones)
int maxLVNRows = input.int(14, "Maximum LVN corridor thickness (rows)", minval = 2, maxval = 20, group = gZones)
int maxEdgeLVNRows = input.int(2, "Maximum LVN thickness at profile edges (rows)", minval = 1, maxval = 8, group = gZones)
float lvnCorridorRise = input.float(50, "LVN width (% of valley-to-shoulder difference)", minval = 10, maxval = 90, group = gZones)
bool showLVNLowest = input.bool(false, "LVN: show lowest volume row", group = gZones)
bool showLVNHighest = input.bool(false, "LVN: show highest volume row", group = gZones)
bool showHVNLowest = input.bool(false, "HVN: show lowest volume row", group = gZones)
bool showHVNHighest = input.bool(false, "HVN: show highest volume row", group = gZones)
int reactionWidth = input.int(1, "Profile row line thickness", minval = 1, maxval = 4, group = gZones)
string profileLineMode = input.string("Inside zone", "Profile row line mode", options = ["Inside zone", "Full POC span"], group = gZones)
int profileLineBars = input.int(30, "Inside-zone line length (chart candles)", minval = 1, maxval = 500, group = gZones)
bool showCorridorSubzones = input.bool(true, "Highlight local volume areas in long zones", group = gZones)
int corridorMinAge = input.int(30, "Minimum zone length (chart candles)", minval = 5, maxval = 300, group = gZones)
int corridorWidth = input.int(100, "Local area box length at zone right (candles)", minval = 2, maxval = 500, group = gZones)
int corridorRows = input.int(3, "Maximum local area height (profile rows)", minval = 1, maxval = 10, group = gZones)
float corridorThreshold = input.float(70, "Adjacent row minimum (% of local peak)", minval = 10, maxval = 100, group = gZones)

string gOuter = "3a. LVN corridor outer rows"
bool showLVNOuter = input.bool(true, "Show one-row beige bands outside LVN", group = gOuter)
int minOuterCorridorRows = input.int(2, "Minimum LVN corridor height (rows)", minval = 1, maxval = 20, group = gOuter)

string gIntensity = "3b. High-intensity profile lows"
bool showIntensityZones = input.bool(true, "Show high-intensity local lows", group = gIntensity)
int maxIntensityZones = input.int(10, "Maximum zones per side", minval = 1, maxval = 20, group = gIntensity)
int intensitySearch = input.int(5, "Shoulder search (rows)", minval = 2, maxval = 15, group = gIntensity)
float intensityShoulder = input.float(25, "Minimum surrounding activity (% of peak)", minval = 5, maxval = 90, group = gIntensity)
float intensityNodeFloor = input.float(5, "Minimum low-row activity (% of peak)", minval = 0, maxval = 50, group = gIntensity)
float intensityDip = input.float(8, "Minimum local dip (%)", minval = 1, maxval = 70, group = gIntensity)
int intensityMaxRows = input.int(3, "Maximum zone height (rows)", minval = 1, maxval = 3, group = gIntensity)
string intensityBlockMode = input.string("Both", "Corridor block profile rows", options = ["Off", "Lowest", "Highest", "Both"], tooltip = "Independent high-intensity corridor detector. Lowest and Highest refer to volume within the detected block, not candle prices. Off disables this additional module; the original HIL zones remain separate.", group = gIntensity)
int intensityBlockCount = input.int(5, "Corridor blocks per side", minval = 1, maxval = 12, group = gIntensity)
int intensityBlockSearch = input.int(12, "Corridor shoulder search (rows)", minval = 3, maxval = 30, group = gIntensity)
int intensityBlockMinRows = input.int(4, "Minimum block height (rows)", minval = 2, maxval = 12, group = gIntensity)
int intensityBlockMaxRows = input.int(14, "Maximum block height (rows)", minval = 4, maxval = 24, group = gIntensity)
float intensityBlockRise = input.float(55, "Block width (% valley to shoulders)", minval = 10, maxval = 90, group = gIntensity)
float intensityBlockDepth = input.float(20, "Minimum shoulder contrast (%)", minval = 5, maxval = 90, group = gIntensity)

string gPressure = "3c. Pressure takeover zones"
bool showPressureZones = input.bool(true, "Show Buy/Sell takeover zones", group = gPressure)
int pressureWindow = input.int(8, "Analysis candles per comparison window", minval = 2, maxval = 50, group = gPressure)
float pressurePercent = input.float(60, "Required dominant share (%)", minval = 51, maxval = 95, group = gPressure)
int pressureConfirm = input.int(2, "Latest analysis candles must confirm", minval = 1, maxval = 5, group = gPressure)
float pressureMinVolume = input.float(10, "Min row volume (% of strongest current row)", minval = 1, maxval = 100, group = gPressure)
int maxPressureZones = input.int(8, "Maximum retained zones PER SIDE", minval = 1, maxval = 12, group = gPressure)

string gCluster = "3d. Profile cluster edge rows"
bool showClusterEdges = input.bool(true, "Show row immediately beyond a volume cluster", group = gCluster)
string clusterSide = input.string("Below cluster", "Cluster side", options = ["Below cluster", "Above cluster", "Both"], group = gCluster)
float clusterActivity = input.float(25, "Cluster row activity (% of profile peak)", minval = 1, maxval = 90, group = gCluster)
int clusterMinRows = input.int(3, "Minimum consecutive cluster rows", minval = 2, maxval = 20, group = gCluster)
float clusterEdgeDrop = input.float(20, "Minimum volume drop into the next row (%)", minval = 0, maxval = 95, tooltip = "Compares the row just outside the cluster with the neighboring row inside it. No candle, ATR, breakout, or dip condition is used.", group = gCluster)
int clusterMaxCount = input.int(6, "Strongest clusters to mark", minval = 1, maxval = 8, group = gCluster)
int clusterZoneBars = input.int(200, "Right-side zone length (chart candles)", minval = 2, maxval = 500, group = gCluster)
color clusterZoneColor = input.color(color.rgb(140, 105, 190), "Cluster edge row fill", group = gCluster)
color clusterLineColor = input.color(color.rgb(255, 145, 0), "Cluster box border", group = gCluster)

string gStats = "4. Zone labels / states"
bool showZoneLabels = input.bool(false, "Show area / volume labels", group = gStats)
bool showBroken = input.bool(false, "Keep broken takeover zones visible", group = gStats)
int labelOffset = input.int(3, "Value labels: candles to the right", minval = 1, maxval = 50, group = gStats)
int labelColumnBars = input.int(18, "Distance between label columns (candles)", minval = 1, maxval = 100, tooltip = "Only labels sharing a profile price row move into neighboring columns. Increase this distance if horizontal zoom compresses the text.", group = gStats)
float neutralPercent = input.float(5, "Neutral dominance band (+/- percentage points)", minval = 0, maxval = 25, group = gStats)

string gFlow = "5. CFD price / volume model"
string flowMode = input.string("BVC", "Buy/Sell estimation", options = ["BVC", "Intrabar direction", "Candle direction"], group = gFlow)
bool useLowerTF = input.bool(true, "Use smaller candles when available", group = gFlow)
string flowTF = input.timeframe("1", "Analysis timeframe", tooltip = "Default 1 minute. On a 1-minute chart the chart candles are used. Seconds require feed/plan support.", group = gFlow)
int flowLookback = input.int(100, "Volatility history (analysis candles)", minval = 20, maxval = 500, group = gFlow)
int flowWarmup = input.int(20, "Minimum previous price changes", minval = 5, maxval = 100, group = gFlow)
float maxZ = input.float(3, "BVC maximum standardized move", minval = 1, maxval = 5, group = gFlow)
bool showVisit = input.bool(true, "Latest visit stats in tooltip", group = gFlow)
string volumeUnit = input.string("Feed volume", "Volume label unit", options = ["Feed volume", "Tick activity", "Trade volume"], tooltip = "Choose only after verifying the CFD feed. Tick activity counts price updates, not contracts.", group = gFlow)

string gVisual = "6. Session VWAPs"
bool showSessionVWAP = input.bool(true, "Session-start VWAP", group = gVisual)
bool showExtremeVWAPs = input.bool(true, "Session-high / session-low VWAPs", group = gVisual)

f_themeColor(color customColor, color lightPreset, color darkPreset) =>
    themeMode == "Custom" ? customColor : themeMode == "Dark" ? darkPreset : lightPreset

color vaColor = f_themeColor(customVaColor, color.rgb(213, 137, 38), color.rgb(247, 184, 78))
color upColor = f_themeColor(customUpColor, color.rgb(76, 207, 224), color.rgb(66, 180, 196))
color downColor = f_themeColor(customDownColor, color.rgb(255, 116, 171), color.rgb(225, 100, 153))
color lvnColor = f_themeColor(customLvnColor, color.rgb(116, 88, 204), color.rgb(173, 145, 255))
color hvnColor = f_themeColor(customHvnColor, color.rgb(53, 133, 206), color.rgb(108, 187, 255))
color pressureBuyColor = f_themeColor(customPressureBuyColor, color.rgb(31, 158, 99), color.rgb(65, 200, 135))
color pressureSellColor = f_themeColor(customPressureSellColor, color.rgb(210, 78, 89), color.rgb(255, 105, 120))
color outerColor = f_themeColor(customOuterColor, color.rgb(225, 184, 123), color.rgb(238, 199, 140))
color intensityColor = f_themeColor(customIntensityColor, color.rgb(35, 196, 210), color.rgb(75, 221, 230))
color intensityBlockColor = f_themeColor(customIntensityBlockColor, color.rgb(188, 147, 99), color.rgb(215, 176, 124))
color sessionColor = f_themeColor(customSessionColor, color.rgb(40, 44, 46), color.rgb(226, 233, 238))
color highColor = f_themeColor(customHighColor, color.rgb(20, 173, 157), color.rgb(77, 226, 205))
color lowColor = f_themeColor(customLowColor, color.rgb(20, 173, 157), color.rgb(77, 226, 205))
color themeLabelTextColor = themeMode == "Custom" ? chart.fg_color : themeMode == "Dark" ? color.rgb(228, 234, 238) : color.rgb(40, 44, 46)
color themeMutedTextColor = themeMode == "Custom" ? color.gray : themeMode == "Dark" ? color.rgb(150, 160, 170) : color.rgb(125, 130, 136)

// A zone keeps its identity while its price range overlaps the current profile candidate.
type Zone
    float bottom
    float top
    int kind
    int bornBar
    int bornTime
    int side
    int state
    float vol
    float upVol
    float visitVol
    float visitBuy
    int lastTouchBar
    float eventBuyPct
    int lastWinner

type Candidate
    float bottom
    float top
    int kind
    float buyPct

f_sessionKey(int t, string hours, string timezoneName) =>
    int hh = int(str.tonumber(str.substring(hours, 0, 2)))
    int mm = int(str.tonumber(str.substring(hours, 2, 4)))
    int today = timestamp(timezoneName, year(t, timezoneName), month(t, timezoneName), dayofmonth(t, timezoneName), hh, mm)
    t >= today ? today : timestamp(timezoneName, year(t, timezoneName), month(t, timezoneName), dayofmonth(t, timezoneName) - 1, hh, mm)

// Standard normal CDF, polynomial approximation (max absolute error ~8e-8).
f_normalCDF(float z) =>
    float x = math.abs(z)
    float t = 1.0 / (1.0 + 0.2316419 * x)
    float poly = t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    float upper = 1.0 - 0.3989422804014327 * math.exp(-0.5 * x * x) * poly
    z == 0 ? 0.5 : z > 0 ? upper : 1.0 - upper

// Independent rolling state in chart and lower-timeframe request contexts.
// No varip: open-bar updates roll back, preventing repeated volume accumulation.
f_flowSample(string hours, string spec, string timezoneName) =>
    var array<float> changes = array.new<float>()
    var int lastDirection = 0
    // Only one preceding bar is accessed; arrays have separate size limits.
    max_bars_back(time, 1)
    max_bars_back(close, 1)
    bool belongs = not na(time(timeframe.period, spec, timezoneName))
    int key = f_sessionKey(time, hours, timezoneName)
    max_bars_back(key, 1)
    bool contiguous = not na(time[1]) and time - time[1] <= int(timeframe.in_seconds() * 1500)
    bool validChange = belongs and belongs[1] and key == key[1] and contiguous
    float dp = validChange ? close - close[1] : na
    if not validChange
        lastDirection := 0
    if validChange and dp != 0
        lastDirection := dp > 0 ? 1 : -1
    int n = array.size(changes)
    float sigma = flowMode == "BVC" and n > 1 ? array.stdev(changes, false) : na
    bool ready = validChange and n >= math.min(flowWarmup, flowLookback) and not na(sigma) and sigma > syminfo.mintick * 0.01
    float fraction = 0.5
    if flowMode == "Candle direction"
        fraction := close > open ? 1.0 : close < open ? 0.0 : 0.5
    else if flowMode == "Intrabar direction"
        fraction := lastDirection == 1 ? 1.0 : lastDirection == -1 ? 0.0 : 0.5
    else if ready
        float standardized = math.max(-maxZ, math.min(maxZ, dp / sigma))
        fraction := f_normalCDF(standardized)
    // Append AFTER calculating sigma and fraction: current dp cannot normalize itself.
    if flowMode == "BVC" and validChange
        array.push(changes, dp)
        if array.size(changes) > flowLookback
            array.shift(changes)
    bool modelReady = flowMode == "BVC" ? ready : flowMode == "Candle direction" ? true : validChange
    [high, low, math.max(nz(volume, 0), 0), fraction, modelReady, time, belongs, close]

f_overlapVolume(float h, float l, float v, float bottom, float top) =>
    float overlap = math.max(0.0, math.min(h, top) - math.max(l, bottom))
    h > l ? v * overlap / (h - l) : (l >= bottom and l < top ? v : 0.0)

f_binCandle(array<float> totals, array<float> ups, float base, float step, float h, float l, float v, float buyFraction) =>
    int n = array.size(totals)
    int first = math.max(0, math.min(n - 1, int(math.floor((l - base) / step))))
    int last = math.max(0, math.min(n - 1, int(math.floor((h - base) / step))))
    for r = first to last
        float share = h > l ? f_overlapVolume(h, l, v, base + r * step, base + (r + 1) * step) : v
        array.set(totals, r, array.get(totals, r) + share)
        array.set(ups, r, array.get(ups, r) + share * buyFraction)
    0

// Uniform candle allocation: two partial boundary rows and a constant
// interior contribution. Difference arrays replace sample x row loops.
// Small incremental batches retain direct binning to avoid scratch overhead.
f_binSamples(array<float> totals, array<float> ups, array<float> hs, array<float> ls, array<float> vs, array<float> bs, float base, float step, int firstSample, int lastSample) =>
    int n = array.size(totals)
    if firstSample <= lastSample
        if lastSample - firstSample < 4
            for b = firstSample to lastSample
                f_binCandle(totals, ups, base, step, array.get(hs, b), array.get(ls, b), array.get(vs, b), array.get(bs, b))
        else
            array<float> deltaV = array.new<float>(n + 1, 0.0)
            array<float> deltaB = array.new<float>(n + 1, 0.0)
            array<int> deltaActive = array.new<int>(n + 1, 0)
            for b = firstSample to lastSample
                float h = array.get(hs, b)
                float l = array.get(ls, b)
                float v = array.get(vs, b)
                float buy = array.get(bs, b)
                int first = math.max(0, math.min(n - 1, int(math.floor((l - base) / step))))
                int last = math.max(0, math.min(n - 1, int(math.floor((h - base) / step))))
                float firstShare = h > l ? f_overlapVolume(h, l, v, base + first * step, base + (first + 1) * step) : v
                array.set(totals, first, array.get(totals, first) + firstShare)
                array.set(ups, first, array.get(ups, first) + firstShare * buy)
                if last > first
                    float lastShare = f_overlapVolume(h, l, v, base + last * step, base + (last + 1) * step)
                    array.set(totals, last, array.get(totals, last) + lastShare)
                    array.set(ups, last, array.get(ups, last) + lastShare * buy)
                    if last > first + 1
                        float interiorShare = v * step / (h - l)
                        array.set(deltaV, first + 1, array.get(deltaV, first + 1) + interiorShare)
                        array.set(deltaV, last, array.get(deltaV, last) - interiorShare)
                        array.set(deltaB, first + 1, array.get(deltaB, first + 1) + interiorShare * buy)
                        array.set(deltaB, last, array.get(deltaB, last) - interiorShare * buy)
                        array.set(deltaActive, first + 1, array.get(deltaActive, first + 1) + 1)
                        array.set(deltaActive, last, array.get(deltaActive, last) - 1)
            float runningV = 0.0
            float runningB = 0.0
            int active = 0
            for r = 0 to n - 1
                runningV += array.get(deltaV, r)
                runningB += array.get(deltaB, r)
                active += array.get(deltaActive, r)
                // Empty interior intervals must remain exactly zero (LVN detection).
                if active == 0
                    runningV := 0.0
                    runningB := 0.0
                // Mathematical contributions are nonnegative; suppress cancellation dust.
                array.set(totals, r, array.get(totals, r) + math.max(0.0, runningV))
                array.set(ups, r, array.get(ups, r) + math.max(0.0, math.min(runningV, runningB)))
    0

f_smooth(array<float> totals, int radius) =>
    int n = array.size(totals)
    array<float> result = array.copy(totals)
    if radius > 0
        for r = 0 to n - 1
            float weighted = 0.0
            float weights = 0.0
            for k = math.max(0, r - radius) to math.min(n - 1, r + radius)
                float w = radius + 1 - math.abs(k - r)
                weighted += array.get(totals, k) * w
                weights += w
            array.set(result, r, weighted / weights)
    result

// Pure profile geometry. A cluster is a contiguous run of active price rows.
// The marked band is exactly ONE row outside the run, never a candle pattern.
// Runs are found in one scan; the small retained-cluster limit bounds selection.
f_clusterEdges(array<float> profile, float base, float step) =>
    int n = array.size(profile)
    array<Candidate> result = array.new<Candidate>()
    array<int> lowerEdges = array.new<int>()
    array<int> upperEdges = array.new<int>()
    array<float> scores = array.new<float>()
    float peak = array.max(profile)
    if peak > 0
        float threshold = peak * clusterActivity / 100
        int r = 0
        while r < n
            if array.get(profile, r) < threshold
                r += 1
            else
                int first = r
                float clusterVolume = 0.0
                while r < n
                    if array.get(profile, r) < threshold
                        break
                    clusterVolume += array.get(profile, r)
                    r += 1
                int last = r - 1
                if last - first + 1 >= clusterMinRows
                    bool lower = clusterSide != "Above cluster" and first > 0 and array.get(profile, first - 1) <= array.get(profile, first) * (1 - clusterEdgeDrop / 100)
                    bool upper = clusterSide != "Below cluster" and last < n - 1 and array.get(profile, last + 1) <= array.get(profile, last) * (1 - clusterEdgeDrop / 100)
                    if lower or upper
                        array.push(lowerEdges, lower ? first - 1 : -1)
                        array.push(upperEdges, upper ? last + 1 : -1)
                        array.push(scores, clusterVolume)
        array<bool> usedRows = array.new<bool>(n, false)
        if array.size(scores) > 0
            for attempt = 0 to clusterMaxCount - 1
                float best = array.max(scores)
                if best <= 0
                    break
                int index = array.indexof(scores, best)
                for side = 0 to 1
                    int edge = side == 0 ? array.get(lowerEdges, index) : array.get(upperEdges, index)
                    if edge >= 0 and not array.get(usedRows, edge)
                        array.push(result, Candidate.new(base + edge * step, base + (edge + 1) * step, 5, 0.5))
                        array.set(usedRows, edge, true)
                array.set(scores, index, 0.0)
    result

// kind -1 = LVN corridor; kind +1 = HVN. Corridors expand to their depth threshold.
f_candidates(array<float> sm, float base, float step, int kind, float currentPrice) =>
    int n = array.size(sm)
    float maximum = array.max(sm)
    array<float> scores = array.new<float>(n, 0.0)
    array<float> shoulders = array.new<float>(n, 0.0)
    array<Candidate> result = array.new<Candidate>()
    if maximum > 0
        for zoneSide = -1 to 1 by 2
            array.fill(scores, 0.0)
            array.fill(shoulders, 0.0)
            for r = 0 to n - 1
                float node = array.get(sm, r)
                float nodePrice = base + (r + 0.5) * step
                bool onSide = zoneSide == -1 ? nodePrice < currentPrice : nodePrice >= currentPrice
                bool extremum = kind == -1 ? (r == 0 ? node <= array.get(sm, 1) : r == n - 1 ? node < array.get(sm, n - 2) : node < array.get(sm, r - 1) and node <= array.get(sm, r + 1)) : (r == 0 ? node >= array.get(sm, 1) : r == n - 1 ? node > array.get(sm, n - 2) : node > array.get(sm, r - 1) and node >= array.get(sm, r + 1))
                if onSide and extremum
                    float left = kind == -1 ? 0.0 : maximum
                    float right = kind == -1 ? 0.0 : maximum
                    if r > 0
                        for k = math.max(0, r - peakWindow) to r - 1
                            left := kind == -1 ? math.max(left, array.get(sm, k)) : math.min(left, array.get(sm, k))
                    if r < n - 1
                        for k = r + 1 to math.min(n - 1, r + peakWindow)
                            right := kind == -1 ? math.max(right, array.get(sm, k)) : math.min(right, array.get(sm, k))
                    float shoulder = r == 0 ? right : r == n - 1 ? left : kind == -1 ? math.min(left, right) : math.max(left, right)
                    float depth = kind == -1 ? (shoulder > 0 ? (shoulder - node) / shoulder : 0.0) : (node > 0 ? (node - shoulder) / node : 0.0)
                    if depth >= minDepth / 100 and (kind == -1 or node >= maximum * minHVN / 100)
                        array.set(scores, r, depth)
                        array.set(shoulders, r, shoulder)
            int selected = 0
            for attempt = 0 to n - 1
                float best = array.max(scores)
                if best <= 0 or selected >= maxZones
                    break
                int center = array.indexof(scores, best)
                float node = array.get(sm, center)
                float shoulder = array.get(shoulders, center)
                float cutoff = kind == -1 ? node + (shoulder - node) * lvnCorridorRise / 100 : node + (shoulder - node) * zoneRise / 100
                int widthLimit = kind == -1 ? (center == 0 or center == n - 1 ? maxEdgeLVNRows : maxLVNRows) : maxZoneRows
                int lo = center
                int hi = center
                while hi - lo + 1 < widthLimit
                    float below = lo > 0 ? array.get(sm, lo - 1) : na
                    float above = hi < n - 1 ? array.get(sm, hi + 1) : na
                    bool canDown = not na(below) and (kind == -1 ? below <= cutoff : below >= cutoff)
                    bool canUp = not na(above) and (kind == -1 ? above <= cutoff : above >= cutoff)
                    if not canDown and not canUp
                        break
                    if canDown and (not canUp or (kind == -1 ? below <= above : below >= above))
                        lo -= 1
                    else
                        hi += 1
                array.push(result, Candidate.new(base + lo * step, base + (hi + 1) * step, kind, 0.5))
                selected += 1
                for k = math.max(0, lo - 1) to math.min(n - 1, hi + 1)
                    array.set(scores, k, 0.0)
    result

// kind +3: local volume lows surrounded by substantial activity, up to three rows.
f_intensityCandidates(array<float> sm, float base, float step, float currentPrice) =>
    int n = array.size(sm)
    float peak = array.max(sm)
    array<Candidate> result = array.new<Candidate>()
    array<float> scores = array.new<float>(n, 0.0)
    array<float> limits = array.new<float>(n, 0.0)
    if peak > 0
        for zoneSide = -1 to 1 by 2
            array.fill(scores, 0.0)
            for r = 1 to n - 2
                float node = array.get(sm, r)
                bool onSide = zoneSide == -1 ? base + (r + 0.5) * step < currentPrice : base + (r + 0.5) * step >= currentPrice
                bool localLow = node < array.get(sm, r - 1) and node <= array.get(sm, r + 1)
                if onSide and localLow and node >= peak * intensityNodeFloor / 100
                    float leftPeak = 0.0
                    float rightPeak = 0.0
                    for k = math.max(0, r - intensitySearch) to r - 1
                        leftPeak := math.max(leftPeak, array.get(sm, k))
                    for k = r + 1 to math.min(n - 1, r + intensitySearch)
                        rightPeak := math.max(rightPeak, array.get(sm, k))
                    float shoulder = math.min(leftPeak, rightPeak)
                    float dip = shoulder > 0 ? (shoulder - node) / shoulder : 0.0
                    if shoulder >= peak * intensityShoulder / 100 and dip >= intensityDip / 100
                        array.set(scores, r, (shoulder - node) / peak)
                        array.set(limits, r, node + (shoulder - node) * 0.5)
            for attempt = 0 to maxIntensityZones - 1
                float best = array.max(scores)
                if best <= 0
                    break
                int center = array.indexof(scores, best)
                int lo = center
                int hi = center
                float limit = array.get(limits, center)
                while hi - lo + 1 < intensityMaxRows
                    float below = lo > 0 ? array.get(sm, lo - 1) : na
                    float above = hi < n - 1 ? array.get(sm, hi + 1) : na
                    bool canDown = not na(below) and below <= limit
                    bool canUp = not na(above) and above <= limit
                    if not canDown and not canUp
                        break
                    if canDown and (not canUp or below <= above)
                        lo -= 1
                    else
                        hi += 1
                array.push(result, Candidate.new(base + lo * step, base + (hi + 1) * step, 3, 0.5))
                for k = math.max(0, lo - 1) to math.min(n - 1, hi + 1)
                    array.set(scores, k, 0.0)
    result

// kind +4: a separate, wider low-activity block bounded by active shoulders.
// Unlike the original HIL detector, this requires a multi-row corridor.
f_intensityBlocks(array<float> sm, float base, float step, float currentPrice) =>
    int n = array.size(sm)
    float peak = array.max(sm)
    array<Candidate> result = array.new<Candidate>()
    array<float> scores = array.new<float>(n, 0.0)
    array<float> cutoffs = array.new<float>(n, 0.0)
    int minHeight = math.min(intensityBlockMinRows, intensityBlockMaxRows)
    if peak > 0
        for zoneSide = -1 to 1 by 2
            array.fill(scores, 0.0)
            for r = 1 to n - 2
                float node = array.get(sm, r)
                float nodePrice = base + (r + 0.5) * step
                bool onSide = zoneSide == -1 ? nodePrice < currentPrice : nodePrice >= currentPrice
                bool localLow = node < array.get(sm, r - 1) and node <= array.get(sm, r + 1)
                if onSide and localLow
                    float leftPeak = 0.0
                    float rightPeak = 0.0
                    for k = math.max(0, r - intensityBlockSearch) to r - 1
                        leftPeak := math.max(leftPeak, array.get(sm, k))
                    for k = r + 1 to math.min(n - 1, r + intensityBlockSearch)
                        rightPeak := math.max(rightPeak, array.get(sm, k))
                    float shoulder = math.min(leftPeak, rightPeak)
                    float depth = shoulder > 0 ? (shoulder - node) / shoulder : 0.0
                    if shoulder >= peak * intensityShoulder / 100 and depth >= intensityBlockDepth / 100
                        array.set(scores, r, (shoulder - node) / peak)
                        array.set(cutoffs, r, node + (shoulder - node) * intensityBlockRise / 100)
            for attempt = 0 to intensityBlockCount - 1
                float best = array.max(scores)
                if best <= 0
                    break
                int center = array.indexof(scores, best)
                int lo = center
                int hi = center
                float cutoff = array.get(cutoffs, center)
                while hi - lo + 1 < intensityBlockMaxRows
                    float below = lo > 0 ? array.get(sm, lo - 1) : na
                    float above = hi < n - 1 ? array.get(sm, hi + 1) : na
                    bool canDown = not na(below) and below <= cutoff
                    bool canUp = not na(above) and above <= cutoff
                    if not canDown and not canUp
                        break
                    if canDown and (not canUp or below <= above)
                        lo -= 1
                    else
                        hi += 1
                bool bounded = lo > 0 and hi < n - 1 and array.get(sm, lo - 1) > cutoff and array.get(sm, hi + 1) > cutoff
                if hi - lo + 1 >= minHeight and bounded
                    array.push(result, Candidate.new(base + lo * step, base + (hi + 1) * step, 4, 0.5))
                for k = math.max(0, lo - 1) to math.min(n - 1, hi + 1)
                    array.set(scores, k, 0.0)
    result

f_pressureCandidates(array<float> curV, array<float> curB, array<float> oldV, array<float> oldB, array<float> confirmV, array<float> confirmB, float base, float step, int kind) =>
    array<Candidate> result = array.new<Candidate>()
    array<float> scores = array.new<float>(rows, 0.0)
    float peak = array.max(curV)
    float threshold = pressurePercent / 100
    if peak > 0
        for r = 0 to rows - 1
            float cv = array.get(curV, r)
            float ov = array.get(oldV, r)
            if cv >= peak * pressureMinVolume / 100 and ov >= peak * pressureMinVolume / 100
                float current = array.get(curB, r) / cv
                float previous = array.get(oldB, r) / ov
                bool takeover = kind == 2 ? current >= threshold and previous <= 1 - threshold : current <= 1 - threshold and previous >= threshold
                if takeover
                    for k = 0 to pressureConfirm - 1
                        int index = k * rows + r
                        float v = array.get(confirmV, index)
                        float b = array.get(confirmB, index)
                        bool aligned = v > 0 and (kind == 2 ? b / v >= threshold : b / v <= 1 - threshold)
                        takeover := takeover and aligned
                    if takeover
                        array.set(scores, r, cv)
        for attempt = 0 to maxPressureZones - 1
            float best = array.max(scores)
            if best <= 0
                break
            int center = array.indexof(scores, best)
            int lo = center
            int hi = center
            while hi - lo + 1 < maxZoneRows
                float below = lo > 0 ? array.get(scores, lo - 1) : 0.0
                float above = hi < rows - 1 ? array.get(scores, hi + 1) : 0.0
                if below <= 0 and above <= 0
                    break
                if below >= above
                    lo -= 1
                else
                    hi += 1
            float total = 0.0
            float buy = 0.0
            for r = lo to hi
                total += array.get(curV, r)
                buy += array.get(curB, r)
            array.push(result, Candidate.new(base + lo * step, base + (hi + 1) * step, kind, buy / total))
            for r = math.max(0, lo - 1) to math.min(rows - 1, hi + 1)
                array.set(scores, r, 0.0)
    result

// Latest confirmed zone-local activity, rather than cumulative session dominance.
f_winner(int previous, float v, float buy) =>
    float fraction = v > 0 ? buy / v : 0.5
    v <= 0 ? previous : fraction > (50 + neutralPercent) / 100 ? 1 : fraction < (50 - neutralPercent) / 100 ? -1 : previous

// Overlapping profile candidates refresh their zone; broken matches can become fresh again.
f_register(array<Zone> zones, Candidate c, int limit, array<float> hs, array<float> ls, array<float> vs, array<float> bs, int eventIndex, int eventTime, float eventClose, int throughSample) =>
    bool duplicate = false
    int typeCount = 0
    int sideCount = 0
    int replaceSlot = -1
    int oldestSlot = -1
    int oldestSideSlot = -1
    int mergeSlot = -1
    bool pressure = math.abs(c.kind) == 2
    int candidateSide = (c.bottom + c.top) / 2 < eventClose ? -1 : 1
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            Zone z = array.get(zones, i)
            if z.kind == c.kind
                typeCount += 1
                if oldestSlot == -1
                    oldestSlot := i
                int existingSide = (z.bottom + z.top) / 2 < eventClose ? -1 : 1
                bool countsForSide = pressure or existingSide == candidateSide
                if countsForSide
                    sideCount += 1
                    if oldestSideSlot == -1
                        oldestSideSlot := i
                    if z.state == 2 and replaceSlot == -1
                        replaceSlot := i
                bool intersects = c.bottom < z.top and c.top > z.bottom
                if not pressure and intersects and mergeSlot == -1
                    mergeSlot := i
                duplicate := duplicate or (intersects and (not pressure or z.state < 2))
                if pressure and z.state == 2 and replaceSlot == -1
                    replaceSlot := i
    bool accepted = false
    if pressure
        accepted := not duplicate and (typeCount < limit or replaceSlot >= 0)
    else if not pressure and mergeSlot >= 0
        accepted := true
    else if sideCount < limit
        accepted := not duplicate
        if accepted and typeCount >= limit * 2
            replaceSlot := oldestSlot
    else
        if replaceSlot == -1
            replaceSlot := oldestSideSlot
        accepted := not duplicate and replaceSlot >= 0
    if accepted and mergeSlot >= 0
        Zone existing = array.get(zones, mergeSlot)
        bool needsRecount = existing.bottom != c.bottom or existing.top != c.top or existing.state == 2
        existing.bottom := c.bottom
        existing.top := c.top
        if existing.state == 2
            existing.state := 0
            existing.bornBar := eventIndex
            existing.bornTime := eventTime
            existing.side := eventClose > c.top ? 1 : eventClose < c.bottom ? -1 : 0
            existing.visitVol := 0.0
            existing.visitBuy := 0.0
            existing.lastTouchBar := -1
        existing.eventBuyPct := c.buyPct * 100
        if needsRecount
            existing.vol := 0.0
            existing.upVol := 0.0
            existing.lastWinner := 0
            for b = 0 to throughSample
                float share = f_overlapVolume(array.get(hs, b), array.get(ls, b), array.get(vs, b), c.bottom, c.top)
                float buyShare = share * array.get(bs, b)
                existing.vol += share
                existing.upVol += buyShare
                existing.lastWinner := f_winner(existing.lastWinner, share, buyShare)
    if accepted and mergeSlot == -1
        float vol = 0.0
        float buy = 0.0
        int winner = pressure ? (c.kind == 2 ? 1 : -1) : 0
        for b = 0 to throughSample
            float share = f_overlapVolume(array.get(hs, b), array.get(ls, b), array.get(vs, b), c.bottom, c.top)
            vol += share
            buy += share * array.get(bs, b)
            if not pressure
                winner := f_winner(winner, share, share * array.get(bs, b))
        int side = pressure ? (c.kind == 2 ? 1 : -1) : eventClose > c.top ? 1 : eventClose < c.bottom ? -1 : 0
        Zone created = Zone.new(c.bottom, c.top, c.kind, eventIndex, eventTime, side, 0, vol, buy, 0.0, 0.0, -1, c.buyPct * 100, winner)
        if replaceSlot >= 0 and typeCount >= limit * 2
            array.remove(zones, replaceSlot)
        else if typeCount >= limit and replaceSlot >= 0
            array.remove(zones, replaceSlot)
        if pressure and array.size(zones) > 0
            for i = 0 to array.size(zones) - 1
                Zone z = array.get(zones, i)
                if z.kind == -c.kind and c.bottom < z.top and c.top > z.bottom
                    z.state := 2
        array.push(zones, created)
    accepted

f_valueArea(array<float> totals, float fraction) =>
    int n = array.size(totals)
    int poc = array.indexof(totals, array.max(totals))
    int lo = poc
    int hi = poc
    float included = array.get(totals, poc)
    float target = array.sum(totals) * fraction
    while included < target and (lo > 0 or hi < n - 1)
        float below = lo > 0 ? array.get(totals, lo - 1) : -1.0
        float above = hi < n - 1 ? array.get(totals, hi + 1) : -1.0
        bool takeAbove = above > below or (above == below and hi - poc <= poc - lo)
        if takeAbove
            hi += 1
            included += above
        else
            lo -= 1
            included += below
    [poc, lo, hi]

if not timeframe.isintraday or not chart.is_standard
    runtime.error("Use standard time-based intraday candles.")
string tz = timezoneInput == "Exchange" ? syminfo.timezone : timezoneInput
string sessionSpec = sessionHours + (sessionDays == "Weekdays" ? ":23456" : ":1234567")
bool inSession = not na(time(timeframe.period, sessionSpec, tz))
int sessionKey = f_sessionKey(time, sessionHours, tz)
max_bars_back(sessionKey, 1)
// Static [1] boolean references are inferred by Pine.
bool newSession = inSession and (barstate.isfirst or not inSession[1] or sessionKey != sessionKey[1])
[chartH, chartL, chartV, chartBuyFraction, chartReady, chartTime, chartBelongs, chartClose] = f_flowSample(sessionHours, sessionSpec, tz)
[ltfH, ltfL, ltfV, ltfBuy, ltfReady, ltfTime, ltfBelongs, ltfClose] = request.security_lower_tf(syminfo.tickerid, flowTF, f_flowSample(sessionHours, sessionSpec, tz), ignore_invalid_timeframe = true)
bool lowerEligible = useLowerTF and timeframe.in_seconds(flowTF) < timeframe.in_seconds()

var array<int> sessionBarTimes = array.new<int>()
var array<float> sampleHighs = array.new<float>()
var array<float> sampleLows = array.new<float>()
var array<float> sampleVolumes = array.new<float>()
var array<float> sampleBuys = array.new<float>()
var array<float> pressureHighs = array.new<float>()
var array<float> pressureLows = array.new<float>()
var array<float> pressureVolumes = array.new<float>()
var array<float> pressureBuys = array.new<float>()
var array<float> pressureCloses = array.new<float>()
var array<float> pressureRangeHighs = array.new<float>()
var array<float> pressureRangeLows = array.new<float>()
var array<int> pressureTimes = array.new<int>()
var array<Zone> pressureZones = array.new<Zone>()
var float pressureHigh = na
var float pressureLow = na
var int lastPressureStart = 0

var array<float> totals = array.new<float>(rows, 0.0)
var array<float> ups = array.new<float>(rows, 0.0)
var array<Zone> zones = array.new<Zone>()
var array<chart.point> sessionPoints = array.new<chart.point>()
var array<chart.point> highPoints = array.new<chart.point>()
var array<chart.point> lowPoints = array.new<chart.point>()
var float sessionHigh = na
var float sessionLow = na
var float sessionPV = 0.0
var float sessionV = 0.0
var float highPV = 0.0
var float highV = 0.0
var float lowPV = 0.0
var float lowV = 0.0
var int sessionLeft = na
var int sessionRight = na
var int lastZoneCheck = 0
var int lastSampleStart = 0

if newSession
    array.clear(pressureHighs)
    array.clear(pressureLows)
    array.clear(pressureVolumes)
    array.clear(pressureBuys)
    array.clear(pressureCloses)
    array.clear(pressureRangeHighs)
    array.clear(pressureRangeLows)
    array.clear(pressureTimes)
    array.clear(pressureZones)
    pressureHigh := na
    pressureLow := na
    lastPressureStart := 0
    array.clear(sessionBarTimes)
    array.clear(sampleHighs)
    array.clear(sampleLows)
    array.clear(sampleVolumes)
    array.clear(sampleBuys)
    array.clear(zones)
    array.clear(sessionPoints)
    array.clear(highPoints)
    array.clear(lowPoints)
    array.fill(totals, 0.0)
    array.fill(ups, 0.0)
    sessionHigh := na
    sessionLow := na
    sessionPV := 0.0
    sessionV := 0.0
    highPV := 0.0
    highV := 0.0
    lowPV := 0.0
    lowV := 0.0
    lastZoneCheck := 0
    lastSampleStart := 0
    sessionLeft := time

if inSession
    if array.size(sessionBarTimes) >= MAX_SESSION_BARS
        runtime.error("Session exceeds 3000 candles. Use a larger timeframe or shorter session.")
    float v = math.max(nz(volume, 0), 0)
    float price = nz(source, hlc3)
    float pv = price * v
    bool newHigh = na(sessionHigh) or high > sessionHigh
    bool newLow = na(sessionLow) or low < sessionLow
    if newHigh
        sessionHigh := high
        highPV := 0.0
        highV := 0.0
        array.clear(highPoints)
    if newLow
        sessionLow := low
        lowPV := 0.0
        lowV := 0.0
        array.clear(lowPoints)
    sessionPV += pv
    sessionV += v
    highPV += pv
    highV += v
    lowPV += pv
    lowV += v
    if sessionV > 0
        array.push(sessionPoints, chart.point.from_time(time, sessionPV / sessionV))
    if highV > 0
        array.push(highPoints, chart.point.from_time(time, highPV / highV))
    if lowV > 0
        array.push(lowPoints, chart.point.from_time(time, lowPV / lowV))
    array.push(sessionBarTimes, time)
    sessionRight := time_close(timeframe.period, sessionSpec, tz)
    int count = array.size(sessionBarTimes)
    float base = sessionLow
    float step = math.max(sessionHigh - base, syminfo.mintick) / rows
    lastSampleStart := array.size(sampleHighs)
    int intrabars = array.size(ltfV)
    float intrabarVolume = intrabars > 0 ? array.sum(ltfV) : 0.0
    bool complete = lowerEligible and intrabars > 0 and intrabarVolume > 0 and v > 0 and math.abs(intrabarVolume - v) / v <= 0.02
    if complete
        for k = 0 to intrabars - 1
            if not array.get(ltfBelongs, k) or array.get(ltfTime, k) < time or array.get(ltfTime, k) >= time_close
                complete := false
    if complete
        if array.size(sampleHighs) + intrabars > MAX_SESSION_SAMPLES
            runtime.error("More than 20000 analysis samples in session. Increase analysis timeframe.")
        float scale = v / intrabarVolume
        for k = 0 to intrabars - 1
            float sv = array.get(ltfV, k) * scale
            array.push(sampleHighs, array.get(ltfH, k))
            array.push(sampleLows, array.get(ltfL, k))
            array.push(sampleVolumes, sv)
            array.push(sampleBuys, array.get(ltfBuy, k))
    else
        // Use one FULL chart candle, never partial LTF + duplicated chart volume.
        if array.size(sampleHighs) >= MAX_SESSION_SAMPLES
            runtime.error("More than 20000 analysis samples in session. Increase analysis timeframe.")
        array.push(sampleHighs, high)
        array.push(sampleLows, low)
        array.push(sampleVolumes, v)
        array.push(sampleBuys, chartBuyFraction)
    lastPressureStart := array.size(pressureHighs)
    int pressureSamples = lowerEligible ? intrabars : 1
    if showZones and showPressureZones and pressureSamples > 0
        for k = 0 to pressureSamples - 1
            int pt = lowerEligible ? array.get(ltfTime, k) : time
            bool belongs = lowerEligible ? array.get(ltfBelongs, k) : chartBelongs
            if belongs and pt >= time and pt < time_close and f_sessionKey(pt, sessionHours, tz) == sessionKey
                if array.size(pressureHighs) >= MAX_SESSION_SAMPLES
                    runtime.error("More than 20000 pressure samples. Increase analysis timeframe.")
                float ph = lowerEligible ? array.get(ltfH, k) : high
                float pl = lowerEligible ? array.get(ltfL, k) : low
                pressureHigh := na(pressureHigh) ? ph : math.max(pressureHigh, ph)
                pressureLow := na(pressureLow) ? pl : math.min(pressureLow, pl)
                array.push(pressureHighs, ph)
                array.push(pressureLows, pl)
                array.push(pressureVolumes, lowerEligible ? array.get(ltfV, k) : chartV)
                array.push(pressureBuys, lowerEligible ? array.get(ltfBuy, k) : chartBuyFraction)
                array.push(pressureCloses, lowerEligible ? array.get(ltfClose, k) : close)
                array.push(pressureTimes, pt)
                array.push(pressureRangeHighs, pressureHigh)
                array.push(pressureRangeLows, pressureLow)
    int sampleCount = array.size(sampleHighs)
    // Rebin on range changes; otherwise allocate only the current candle's samples.
    if newHigh or newLow
        array.fill(totals, 0.0)
        array.fill(ups, 0.0)
    int allocationStart = newHigh or newLow ? 0 : lastSampleStart
    f_binSamples(totals, ups, sampleHighs, sampleLows, sampleVolumes, sampleBuys, base, step, allocationStart, sampleCount - 1)

    // Existing zones update before detection, so creation candle cannot retest itself.
    if barstate.isconfirmed
        if array.size(zones) > 0
            for i = 0 to array.size(zones) - 1
                Zone z = array.get(zones, i)
                float share = 0.0
                float buyShare = 0.0
                for b = lastSampleStart to sampleCount - 1
                    float sv = f_overlapVolume(array.get(sampleHighs, b), array.get(sampleLows, b), array.get(sampleVolumes, b), z.bottom, z.top)
                    share += sv
                    buyShare += sv * array.get(sampleBuys, b)
                    z.lastWinner := f_winner(z.lastWinner, sv, sv * array.get(sampleBuys, b))
                z.vol += share
                z.upVol += buyShare
                bool contact = high >= z.bottom and low <= z.top
                if bar_index > z.bornBar and contact
                    // Consecutive touching candles belong to one visit.
                    if z.lastTouchBar != bar_index - 1
                        z.visitVol := 0.0
                        z.visitBuy := 0.0
                    z.visitVol += share
                    z.visitBuy += buyShare
                    z.lastTouchBar := bar_index
                if bar_index > z.bornBar and contact
                    z.state := 1
        bool profileRangeChanged = newHigh or newLow
        bool detect = showZones and (showProfileZones or showIntensityZones or intensityBlockMode != "Off") and count >= minimumBars and (lastZoneCheck == 0 or count - lastZoneCheck >= detectionEvery or profileRangeChanged) and sessionV > 0
        if detect
            lastZoneCheck := count
            array<float> sm = f_smooth(totals, smoothRadius)
            array<Candidate> profileCandidates = array.new<Candidate>()
            if showProfileZones
                for kind = -1 to 1 by 2
                    bool enabled = kind == -1 ? zoneMode != "HVN" : zoneMode != "LVN"
                    if enabled
                        array<Candidate> candidates = f_candidates(sm, base, step, kind, close)
                        array.concat(profileCandidates, candidates)
            if showIntensityZones
                array<Candidate> intensityCandidates = f_intensityCandidates(sm, base, step, close)
                array.concat(profileCandidates, intensityCandidates)
            if intensityBlockMode != "Off"
                array<Candidate> blockCandidates = f_intensityBlocks(sm, base, step, close)
                array.concat(profileCandidates, blockCandidates)
            // Only the current profile determines which LVN/HVN/intensity zones remain active.
            int oldIndex = array.size(zones) - 1
            while oldIndex >= 0
                Zone oldZone = array.get(zones, oldIndex)
                bool stillPresent = false
                if array.size(profileCandidates) > 0
                    for j = 0 to array.size(profileCandidates) - 1
                        Candidate candidate = array.get(profileCandidates, j)
                        if candidate.kind == oldZone.kind and candidate.bottom < oldZone.top and candidate.top > oldZone.bottom
                            stillPresent := true
                            break
                if not stillPresent
                    array.remove(zones, oldIndex)
                oldIndex -= 1
            if array.size(profileCandidates) > 0
                for j = 0 to array.size(profileCandidates) - 1
                    Candidate candidate = array.get(profileCandidates, j)
                    int candidateLimit = candidate.kind == 4 ? intensityBlockCount : candidate.kind == 3 ? maxIntensityZones : maxZones
                    f_register(zones, candidate, candidateLimit, sampleHighs, sampleLows, sampleVolumes, sampleBuys, bar_index, time, close, sampleCount - 1)


    // The pressure engine counts native analysis samples, never parent chart candles.
    // Each sample uses only its own prefix range/history (no later wick leakage).
    int pressureCount = array.size(pressureHighs)
    if barstate.isconfirmed and pressureCount > lastPressureStart
        for e = lastPressureStart to pressureCount - 1
            float ph = array.get(pressureHighs, e)
            float pl = array.get(pressureLows, e)
            float pc = array.get(pressureCloses, e)
            float pvNative = array.get(pressureVolumes, e)
            float pb = array.get(pressureBuys, e)
            int pt = array.get(pressureTimes, e)
            if array.size(pressureZones) > 0
                for i = 0 to array.size(pressureZones) - 1
                    Zone z = array.get(pressureZones, i)
                    float share = f_overlapVolume(ph, pl, pvNative, z.bottom, z.top)
                    z.vol += share
                    z.upVol += share * pb
                    z.lastWinner := f_winner(z.lastWinner, share, share * pb)
                    bool contact = ph >= z.bottom and pl <= z.top
                    if e > z.bornBar and contact
                        if z.lastTouchBar != e - 1
                            z.visitVol := 0.0
                            z.visitBuy := 0.0
                        z.visitVol += share
                        z.visitBuy += share * pb
                        z.lastTouchBar := e
                    if e > z.bornBar and z.state < 2
                        bool broken = z.side == 1 ? pc < z.bottom : pc > z.top
                        if broken
                            z.state := 2
                        else if contact
                            z.state := 1
            if e + 1 >= math.max(minimumBars, math.max(2 * pressureWindow, pressureConfirm))
                float pBase = array.get(pressureRangeLows, e)
                float pStep = math.max(array.get(pressureRangeHighs, e) - pBase, syminfo.mintick) / rows
                // Reuse storage across native analysis samples. Always clear on execution:
                // normal var rollback semantics remain intact on realtime chart bars.
                var array<float> currentV = array.new<float>(rows, 0.0)
                var array<float> currentB = array.new<float>(rows, 0.0)
                var array<float> previousV = array.new<float>(rows, 0.0)
                var array<float> previousB = array.new<float>(rows, 0.0)
                var array<float> confirmV = array.new<float>(rows * pressureConfirm, 0.0)
                var array<float> confirmB = array.new<float>(rows * pressureConfirm, 0.0)
                array.fill(currentV, 0.0)
                array.fill(currentB, 0.0)
                array.fill(previousV, 0.0)
                array.fill(previousB, 0.0)
                array.fill(confirmV, 0.0)
                array.fill(confirmB, 0.0)
                f_binSamples(currentV, currentB, pressureHighs, pressureLows, pressureVolumes, pressureBuys, pBase, pStep, e - pressureWindow + 1, e)
                f_binSamples(previousV, previousB, pressureHighs, pressureLows, pressureVolumes, pressureBuys, pBase, pStep, e - 2 * pressureWindow + 1, e - pressureWindow)
                for b = e - pressureConfirm + 1 to e
                    int age = e - b
                    float h = array.get(pressureHighs, b)
                    float l = array.get(pressureLows, b)
                    float sv = array.get(pressureVolumes, b)
                    float buyFraction = array.get(pressureBuys, b)
                    if age < pressureConfirm
                        int first = math.max(0, math.min(rows - 1, int(math.floor((l - pBase) / pStep))))
                        int last = math.max(0, math.min(rows - 1, int(math.floor((h - pBase) / pStep))))
                        for r = first to last
                            float share = h > l ? f_overlapVolume(h, l, sv, pBase + r * pStep, pBase + (r + 1) * pStep) : sv
                            int index = age * rows + r
                            array.set(confirmV, index, array.get(confirmV, index) + share)
                            array.set(confirmB, index, array.get(confirmB, index) + share * buyFraction)
                for kind = -2 to 2 by 4
                    array<Candidate> candidates = f_pressureCandidates(currentV, currentB, previousV, previousB, confirmV, confirmB, pBase, pStep, kind)
                    if array.size(candidates) > 0
                        for j = 0 to array.size(candidates) - 1
                            f_register(pressureZones, array.get(candidates, j), maxPressureZones, pressureHighs, pressureLows, pressureVolumes, pressureBuys, e, pt, pc, e)

var array<box> drawings = array.new<box>()
var array<label> labels = array.new<label>()
var array<line> reactionLines = array.new<line>()
var polyline sessionCurve = na
var polyline highCurve = na
var polyline lowCurve = na
var line pocLine = na
var line vahLine = na
var line valLine = na

if barstate.islast
    while array.size(drawings) > 0
        box.delete(array.pop(drawings))
    while array.size(labels) > 0
        label.delete(array.pop(labels))
    while array.size(reactionLines) > 0
        line.delete(array.pop(reactionLines))
    polyline.delete(sessionCurve)
    polyline.delete(highCurve)
    polyline.delete(lowCurve)
    line.delete(pocLine)
    line.delete(vahLine)
    line.delete(valLine)
    int count = array.size(sessionBarTimes)
    if count > 0
        int right = sessionRight
        int candleMs = int(timeframe.in_seconds() * 1000)
        int textTime = right + labelOffset * candleMs
        float base = sessionLow
        float step = math.max(sessionHigh - base, syminfo.mintick) / rows
        float peakVolume = array.max(totals)
        array<float> markerProfile = f_smooth(totals, smoothRadius)
        // Display the current profile's cluster-edge rows independently of the
        // existing LVN/HVN, intensity, and takeover engines and their states.
        array<Candidate> clusterEdgeRows = array.new<Candidate>()
        if showZones and showClusterEdges and count >= minimumBars and peakVolume > 0
            clusterEdgeRows := f_clusterEdges(markerProfile, base, step)
        if showBackdrop
            array.push(drawings, box.new(sessionLeft, base + rows * step, right, base, xloc = xloc.bar_time, border_color = na, border_width = 0, bgcolor = color.new(upColor, 95)))
        array<Zone> displayZones = array.copy(zones)
        if array.size(pressureZones) > 0
            for i = 0 to array.size(pressureZones) - 1
                array.push(displayZones, array.get(pressureZones, i))
        array<float> centers = array.new<float>()
        if array.size(displayZones) > 0
            for i = 0 to array.size(displayZones) - 1
                Zone z = array.get(displayZones, i)
                array.push(centers, (z.top + z.bottom) / 2)
        array<int> sortedZones = array.sort_indices(centers, order.ascending)
        // Reserve the 500 available boxes for every displayed zone first. The profile
        // remains full resolution for detection; only its drawing rows are combined.
        int reservedBoxes = (showBackdrop ? 1 : 0) + array.size(clusterEdgeRows)
        if showZones and array.size(displayZones) > 0
            for i = 0 to array.size(displayZones) - 1
                Zone budgetZone = array.get(displayZones, i)
                if math.abs(budgetZone.kind) == 1 or showBroken or budgetZone.state != 2
                    bool outerEligible = showLVNOuter and budgetZone.kind == -1 and budgetZone.top - budgetZone.bottom + step * 0.0001 >= minOuterCorridorRows * step
                    reservedBoxes += 1 + (showCorridorSubzones and budgetZone.kind != 3 and budgetZone.kind != 4 ? 1 : 0) + (outerEligible ? 2 : 0)
        // Draw the profile first, so zone fills and local areas stay on top.
        if showProfile and peakVolume > 0
            int maxWidth = math.max(1, int((right - sessionLeft) * profileWidth / 100))
            int availableProfileBoxes = math.max(2, 498 - reservedBoxes)
            int profileStride = math.max(1, int(math.ceil(2.0 * rows / availableProfileBoxes)))
            for r = 0 to rows - 1
                if r % profileStride == 0
                    int groupEnd = math.min(rows, r + profileStride)
                    float groupTotal = 0.0
                    float groupUp = 0.0
                    for j = r to groupEnd - 1
                        groupTotal += array.get(totals, j)
                        groupUp += array.get(ups, j)
                    float total = groupTotal / (groupEnd - r)
                    float up = groupUp / (groupEnd - r)
                    int start = sessionLeft
                    int mid = start + int(maxWidth * up / peakVolume)
                    int end = sessionLeft + int(maxWidth * total / peakVolume)
                    float yTop = base + (groupEnd - 0.07) * step
                    float yBottom = base + (r + 0.07) * step
                    if up > 0 and mid > start
                        array.push(drawings, box.new(start, yTop, mid, yBottom, xloc = xloc.bar_time, border_color = na, border_width = 0, bgcolor = color.new(upColor, 25)))
                    if total > up and end > mid
                        array.push(drawings, box.new(mid, yTop, end, yBottom, xloc = xloc.bar_time, border_color = na, border_width = 0, bgcolor = color.new(downColor, 25)))
        if showZones and array.size(displayZones) > 0
            for i = 0 to array.size(displayZones) - 1
                Zone z = array.get(displayZones, array.get(sortedZones, i))
                if math.abs(z.kind) == 1 or showBroken or z.state != 2
                    color zoneColor = z.kind == 4 ? intensityBlockColor : z.kind == 3 ? intensityColor : z.kind == 2 ? pressureBuyColor : z.kind == -2 ? pressureSellColor : z.kind == -1 ? lvnColor : hvnColor
                    int transparency = z.kind == 4 or z.kind == 3 ? (z.state == 0 ? 58 : 70) : z.state == 0 ? 76 : z.state == 1 ? 85 : 93
                    array.push(drawings, box.new(z.bornTime, z.top, right, z.bottom, xloc = xloc.bar_time, border_color = na, border_width = 0, bgcolor = color.new(zoneColor, transparency)))
                    // Exactly one profile price row immediately outside each eligible LVN.
                    if showLVNOuter and z.kind == -1 and z.top - z.bottom + step * 0.0001 >= minOuterCorridorRows * step
                        float profileTop = base + rows * step
                        if z.top + step <= profileTop + step * 0.0001
                            array.push(drawings, box.new(z.bornTime, z.top + step, right, z.top, xloc = xloc.bar_time, border_color = na, border_width = 0, bgcolor = color.new(outerColor, 76)))
                        if z.bottom - step >= base - step * 0.0001
                            array.push(drawings, box.new(z.bornTime, z.bottom, right, z.bottom - step, xloc = xloc.bar_time, border_color = na, border_width = 0, bgcolor = color.new(outerColor, 76)))
                    // Refine a long corridor to the strongest local profile band.
                    // LVNs use the lowest-volume band; HVNs and takeovers use their
                    // strongest volume/directional-volume band. Detection still uses all rows.
                    if showCorridorSubzones and z.kind != 3 and z.kind != 4 and right - z.bornTime >= corridorMinAge * candleMs
                        int firstRow = math.max(0, math.min(rows - 1, int(math.floor((z.bottom - base) / step))))
                        int lastRow = math.max(0, math.min(rows - 1, int(math.ceil((z.top - base) / step)) - 1))
                        if lastRow > firstRow
                            bool valley = z.kind == -1
                            float localMin = na
                            float localMax = na
                            float bestMetric = na
                            int pivotRow = firstRow
                            for r = firstRow to lastRow
                                float metric = z.kind == 2 ? array.get(ups, r) : z.kind == -2 ? array.get(totals, r) - array.get(ups, r) : array.get(markerProfile, r)
                                localMin := na(localMin) ? metric : math.min(localMin, metric)
                                localMax := na(localMax) ? metric : math.max(localMax, metric)
                                bool better = na(bestMetric) or (valley ? metric < bestMetric : metric > bestMetric)
                                bool centeredTie = not na(bestMetric) and metric == bestMetric and math.abs(r - (firstRow + lastRow) * 0.5) < math.abs(pivotRow - (firstRow + lastRow) * 0.5)
                                if better or centeredTie
                                    bestMetric := metric
                                    pivotRow := r
                            if localMax > 0
                                float cutoff = valley ? localMin + (localMax - localMin) * (100 - corridorThreshold) / 100 : bestMetric * corridorThreshold / 100
                                int subLow = pivotRow
                                int subHigh = pivotRow
                                while subHigh - subLow + 1 < corridorRows
                                    float below = subLow > firstRow ? (z.kind == 2 ? array.get(ups, subLow - 1) : z.kind == -2 ? array.get(totals, subLow - 1) - array.get(ups, subLow - 1) : array.get(markerProfile, subLow - 1)) : na
                                    float above = subHigh < lastRow ? (z.kind == 2 ? array.get(ups, subHigh + 1) : z.kind == -2 ? array.get(totals, subHigh + 1) - array.get(ups, subHigh + 1) : array.get(markerProfile, subHigh + 1)) : na
                                    bool canBelow = not na(below) and (valley ? below <= cutoff : below >= cutoff)
                                    bool canAbove = not na(above) and (valley ? above <= cutoff : above >= cutoff)
                                    if not canBelow and not canAbove
                                        break
                                    if canBelow and (not canAbove or (valley ? below <= above : below >= above))
                                        subLow -= 1
                                    else
                                        subHigh += 1
                                float innerBottom = math.max(z.bottom, base + subLow * step)
                                float innerTop = math.min(z.top, base + (subHigh + 1) * step)
                                int innerLeft = math.max(z.bornTime, right - corridorWidth * candleMs)
                                if innerTop - innerBottom < z.top - z.bottom - step * 0.25 and right > innerLeft
                                    array.push(drawings, box.new(innerLeft, innerTop, right, innerBottom, xloc = xloc.bar_time, border_color = na, border_width = 0, bgcolor = color.new(zoneColor, z.state == 2 ? 82 : 48)))
                    // Mark the lowest and/or highest smoothed profile row inside each profile zone.
                    if z.kind == -1 or z.kind == 1 or z.kind == 4
                        bool zoneIsLVN = z.kind == -1
                        bool blockZone = z.kind == 4
                        bool drawLowest = blockZone ? (intensityBlockMode == "Lowest" or intensityBlockMode == "Both") : zoneIsLVN ? showLVNLowest : showHVNLowest
                        bool drawHighest = blockZone ? (intensityBlockMode == "Highest" or intensityBlockMode == "Both") : zoneIsLVN ? showLVNHighest : showHVNHighest
                        float lowestVolume = na
                        float lowestPrice = na
                        float highestVolume = na
                        float highestPrice = na
                        int markerFirst = math.max(0, math.min(rows - 1, int(math.floor((z.bottom - base) / step)) - 1))
                        int markerLast = math.max(0, math.min(rows - 1, int(math.ceil((z.top - base) / step))))
                        for r = markerFirst to markerLast
                            float rowBottom = base + r * step
                            float rowTop = rowBottom + step
                            bool rowInsideZone = rowTop > z.bottom and rowBottom < z.top
                            float rowVolume = array.get(markerProfile, r)
                            if rowInsideZone
                                if na(lowestVolume) or rowVolume < lowestVolume
                                    lowestVolume := rowVolume
                                    lowestPrice := rowBottom + step * 0.5
                                if na(highestVolume) or rowVolume > highestVolume
                                    highestVolume := rowVolume
                                    highestPrice := rowBottom + step * 0.5
                        int lineLeft = profileLineMode == "Full POC span" ? sessionLeft : math.max(z.bornTime, array.get(sessionBarTimes, math.max(0, array.size(sessionBarTimes) - profileLineBars)))
                        color rowLineColor = blockZone ? intensityBlockLineColor : profileRowLineColor
                        if drawLowest and not na(lowestPrice)
                            array.push(reactionLines, line.new(lineLeft, lowestPrice, right, lowestPrice, xloc = xloc.bar_time, color = rowLineColor, style = line.style_dashed, width = reactionWidth))
                        if drawHighest and not na(highestPrice) and (not drawLowest or highestPrice != lowestPrice)
                            array.push(reactionLines, line.new(lineLeft, highestPrice, right, highestPrice, xloc = xloc.bar_time, color = rowLineColor, style = line.style_dashed, width = reactionWidth))
                    if showZoneLabels
                        float zoneV = z.vol
                        float zoneUp = z.upVol
                        float visitV = z.visitVol
                        float visitBuy = z.visitBuy
                        bool pressure = math.abs(z.kind) == 2
                        bool provisionalVisit = false
                        // Provisional open-candle contribution is display-only, once.
                        if inSession and not barstate.isconfirmed
                            if pressure
                                int displayLastTouch = z.lastTouchBar
                                if array.size(pressureHighs) > lastPressureStart
                                    for b = lastPressureStart to array.size(pressureHighs) - 1
                                        float ph = array.get(pressureHighs, b)
                                        float pl = array.get(pressureLows, b)
                                        float share = f_overlapVolume(ph, pl, array.get(pressureVolumes, b), z.bottom, z.top)
                                        float buyShare = share * array.get(pressureBuys, b)
                                        zoneV += share
                                        zoneUp += buyShare
                                        if b > z.bornBar and ph >= z.bottom and pl <= z.top
                                            provisionalVisit := true
                                            if displayLastTouch != b - 1
                                                visitV := 0.0
                                                visitBuy := 0.0
                                            visitV += share
                                            visitBuy += buyShare
                                            displayLastTouch := b
                            else
                                float share = 0.0
                                float buyShare = 0.0
                                for b = lastSampleStart to array.size(sampleHighs) - 1
                                    float sv = f_overlapVolume(array.get(sampleHighs, b), array.get(sampleLows, b), array.get(sampleVolumes, b), z.bottom, z.top)
                                    share += sv
                                    buyShare += sv * array.get(sampleBuys, b)
                                zoneV += share
                                zoneUp += buyShare
                                if high >= z.bottom and low <= z.top
                                    provisionalVisit := true
                                    if z.lastTouchBar != bar_index - 1
                                        visitV := 0.0
                                        visitBuy := 0.0
                                    visitV += share
                                    visitBuy += buyShare
                        float buyPct = zoneV > 0 ? zoneUp / zoneV * 100 : 50.0
                        float sellPct = 100 - buyPct
                        float delta = 2 * zoneUp - zoneV
                        string dominance = zoneV <= 0 ? "No volume" : buyPct > 50 + neutralPercent ? "Buy~" : buyPct < 50 - neutralPercent ? "Sell~" : "Neutral"
                        string state = pressure ? (z.state == 0 ? "Fresh" : z.state == 1 ? "Touched" : "Broken") : (z.state == 0 ? "Fresh" : "Visited")
                        string zoneName = z.kind == 4 ? "High-intensity corridor block" : z.kind == 3 ? "High-intensity local low" : z.kind == 2 ? "Buy takeover" : z.kind == -2 ? "Sell takeover" : z.kind == -1 ? "LVN" : "HVN"
                        string tip = zoneName + " | " + volumeUnit + " | " + flowMode + " | " + state + " | " + dominance + "\nSession V " + str.tostring(zoneV, format.volume) + " | Buy~ " + str.tostring(buyPct, "#.0") + "% / Sell~ " + str.tostring(sellPct, "#.0") + "% | Delta~ " + str.tostring(delta, format.volume)
                        if pressure
                            tip += "\nAnalysis source: " + (lowerEligible ? flowTF : timeframe.period) + " | Pressure takeover at creation: Buy~ " + str.tostring(z.eventBuyPct, "#.0") + "%"
                        if showVisit
                            string visit = visitV > 0 ? "V " + str.tostring(visitV, format.volume) + " | Buy~ " + str.tostring(visitBuy / visitV * 100, "#.0") + "% | Delta~ " + str.tostring(2 * visitBuy - visitV, format.volume) : "--"
                            tip += "\nLatest visit" + (provisionalVisit ? "*" : "") + ": " + visit
                        tip += "\nBorn: " + str.format_time(z.bornTime, "HH:mm", tz) + ". Estimates, not actual orders. State: closed candle; *: live candle."
                        float center = (z.top + z.bottom) / 2
                        string shortName = z.kind == 4 ? "HIB" : z.kind == 3 ? "HIL" : z.kind == 2 ? "BUY" : z.kind == -2 ? "SELL" : z.kind == -1 ? "LVN" : "HVN"
                        string zoneLabelText = shortName + " | " + str.tostring(zoneV, format.volume)
                        string lastWinnerName = z.lastWinner == 1 ? "Buy~" : z.lastWinner == -1 ? "Sell~" : "None yet"
                        tip += "\nLast confirmed winner: " + lastWinnerName + ". Neutral samples retain the previous winner."
                        int labelTime = textTime
                        array.push(labels, label.new(labelTime, center, zoneLabelText, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = z.state == 2 ? themeMutedTextColor : themeLabelTextColor, size = size.tiny, tooltip = tip))

        // One right-side box per edge row, with a solid border on all four sides.
        // No added text labels; profile changes may relocate these live rows.
        if array.size(clusterEdgeRows) > 0
            int edgeLeft = array.get(sessionBarTimes, math.max(0, count - clusterZoneBars))
            for edge in clusterEdgeRows
                array.push(drawings, box.new(edgeLeft, edge.top, right, edge.bottom, xloc = xloc.bar_time, border_color = clusterLineColor, border_width = reactionWidth, border_style = line.style_solid, bgcolor = color.new(clusterZoneColor, 70)))

        if peakVolume > 0
            [poc, vaLo, vaHi] = f_valueArea(totals, vaPercent / 100)
            if showPOC
                float pocPrice = base + (poc + 0.5) * step
                pocLine := line.new(sessionLeft, pocPrice, right, pocPrice, xloc = xloc.bar_time, color = sessionColor, style = line.style_solid)
                int pocLabelTime = textTime
                array.push(labels, label.new(pocLabelTime, pocPrice, "POC", xloc = xloc.bar_time, style = label.style_label_left, color = na, textcolor = sessionColor, size = size.normal, textalign = text.align_left))
            if showVA
                float vah = base + (vaHi + 1) * step
                float val = base + vaLo * step
                vahLine := line.new(sessionLeft, vah, right, vah, xloc = xloc.bar_time, color = vaColor, style = line.style_solid)
                valLine := line.new(sessionLeft, val, right, val, xloc = xloc.bar_time, color = vaColor, style = line.style_solid)
                // Transparent, right-facing text anchors keep the text to the right of
                // each line endpoint at the exact price, without a visible background.
                array.push(labels, label.new(textTime, vah, "VAH " + str.tostring(vah, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = na, textcolor = vaColor, size = size.normal, textalign = text.align_left))
                array.push(labels, label.new(textTime, val, "VAL " + str.tostring(val, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = na, textcolor = vaColor, size = size.normal, textalign = text.align_left))
        // Only horizontal displacement for labels sharing a profile price row.
        // Keep every label's y coordinate and every singleton's x coordinate.
        // One pass includes profile, pressure, POC, VAH, and VAL text together.
        if array.size(labels) > 0
            array<int> nextLabelColumn = array.new<int>(rows + 1, 0)
            for id in labels
                float price = label.get_y(id)
                int priceRow = math.max(0, math.min(rows, int(math.floor((price - base) / step + 0.0000001))))
                int column = array.get(nextLabelColumn, priceRow)
                if column > 0
                    label.set_x(id, textTime + column * labelColumnBars * candleMs)
                array.set(nextLabelColumn, priceRow, column + 1)

        if showSessionVWAP and array.size(sessionPoints) > 1
            sessionCurve := polyline.new(sessionPoints, xloc = xloc.bar_time, line_color = sessionColor, line_width = 3)
        if showExtremeVWAPs and array.size(highPoints) > 1
            highCurve := polyline.new(highPoints, xloc = xloc.bar_time, line_color = highColor, line_width = 3)
        if showExtremeVWAPs and array.size(lowPoints) > 1
            lowCurve := polyline.new(lowPoints, xloc = xloc.bar_time, line_color = lowColor, line_width = 3)
````
