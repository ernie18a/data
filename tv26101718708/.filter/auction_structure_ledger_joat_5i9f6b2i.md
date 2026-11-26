# Auction Structure Ledger [JOAT]

- url: https://www.tradingview.com/script/5i9F6B2I-Auction-Structure-Ledger-JOAT/
- type: indicator
- pine_id: PUB;ee8e19fd5b4747d7a4b67fe525191fe2
- version: 1.0

## Description

[b]Auction Structure Ledger [JOAT][/b]

[b]Introduction[/b]

Auction Structure Ledger is an open-source Pine Script v6 indicator that transforms confirmed pivot behavior into structured auction zones. Instead of treating every swing high and swing low as equally important, the script looks for clustered defended pivots, measures how much volume-confluence exists at those prices, and converts the result into support and resistance shelves that persist, update, and eventually retire as price accepts or fails them.

The problem this indicator solves is structural ambiguity. Many charts contain repeated pivot noise that does not deserve equal visual weight. A single swing high does not automatically represent meaningful supply, and a single swing low does not automatically represent meaningful demand. Auction Structure Ledger filters pivot activity through clustering logic and local volume-confluence so the chart emphasizes defended areas where auction acceptance and rejection are more likely to matter.

The script is useful for traders who think in terms of accumulation, distribution, acceptance, and failure. It does not attempt to forecast the future from one oscillator reading. It organizes the chart around defended reference zones, tracks how price behaves around them, and summarizes the current auction state in a way that can support discretionary analysis or other rule-based systems.

Because it combines pivot clustering with a volume-confluence layer, the indicator is not simply painting boxes around old highs and lows. It is trying to identify where the market repeatedly acknowledged a price region and whether that region still behaves as support or resistance.

[image]https://www.tradingview.com/x/gcLfQNh2/[/image]

[b]Core Concepts[/b]

[b]1. Pivot Confirmation And Structural Timing[/b]

The script uses `ta.pivothigh()` and `ta.pivotlow()` to confirm swing highs and lows with a symmetric lookback. This means zones are only created after the pivot is actually confirmed, which avoids the false certainty that comes from drawing structure before the right-side bars exist.

[pine]
float pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
float pivotLow = ta.pivotlow(low, pivotLength, pivotLength)
[/pine]

This is deliberate non-repainting behavior. The structure appears later than the original pivot candle, but it appears only after the market has confirmed the swing.

[b]2. Clustered Defense Rather Than Single-Pivot Noise[/b]

Once a pivot appears, the script scans a configurable cluster window to count how many nearby pivots formed within an ATR-based tolerance. That cluster count becomes part of the zone’s strength score.

This is what gives the ledger its auction logic. A zone becomes more meaningful when the market keeps defending the same approximate level rather than printing a one-off pivot and moving on.

[b]3. Volume-Confluence Layer[/b]

The script builds a rolling volume distribution across the current price window and checks how much of that distribution sits at the pivot price. That reading is normalized into a confluence percentage.

In practice, this means a clustered pivot with low local volume-confluence is treated differently from a clustered pivot that sits in a high-activity price region. The first may represent weak structure. The second may represent a more meaningful auction shelf.

[b]4. Support And Resistance Shelf Construction[/b]

When a pivot passes the cluster criteria, the script creates a zone with ATR-based width. Resistance shelves are built above price with an offered profile. Support shelves are built below price with a bid profile. Each shelf contains a body, a spine line through the midpoint, and an information label summarizing the zone.

The shelf width is not arbitrary. It scales with ATR so zones remain proportionate across different volatility conditions and instruments.

[b]5. Acceptance And Failure Tracking[/b]

After a zone is created, the script continues monitoring it. If price trades within the zone and remains inside it, the shelf is counted as accepted. If price closes through the invalidation side of the shelf, it is counted as failed and eventually removed after a short lifecycle buffer.

That behavior matters because the market is not static. A valid shelf today can become irrelevant after repeated acceptance or a decisive failure.

[image]https://www.tradingview.com/x/70BCqqUs/[/image]

[b]Features[/b]

[list]
[*][b]Cluster-confirmed auction shelves:[/b] Builds zones only when pivots cluster within an ATR-based tolerance
[*][b]Support and resistance separation:[/b] Maintains bid-side and offered-side structure independently
[*][b]Volume-confluence scoring:[/b] Measures how much rolling price-volume concentration supports each shelf
[*][b]ATR-scaled zone width:[/b] Keeps shelf geometry adaptive to volatility instead of fixed-width boxes
[*][b]Acceptance and failure tracking:[/b] Continues scoring shelves after creation as price interacts with them
[*][b]Confluence ribbon:[/b] Displays whether current price is trading in a high-confluence region of the rolling ledger
[*][b]Nearest distance metrics:[/b] Shows the ATR distance to the closest active support and resistance shelves
[*][b]Institutional dashboard:[/b] Summarizes support count, resistance count, acceptance rate, failure rate, bias, and strongest zone
[*][b]Confirmed-bar alert set:[/b] Includes bullish ledger, bearish ledger, fresh support, and fresh resistance alerts
[*][b]Data-window outputs:[/b] Exposes structure counts and confluence values for additional interpretation
[/list]

[b]Visual Elements[/b]

[list]
[*][b]Auction shelves:[/b] Each zone is rendered as a structured body rather than a simple line so the user can read width and tolerance clearly
[*][b]Shelf spine:[/b] A dotted midpoint line marks the internal balance area of each shelf
[*][b]Confluence ribbon:[/b] The ribbon around price shows whether the current location overlaps with strong rolling confluence
[*][b]Responsive color logic:[/b] Support, resistance, touched, and failed states each alter the way the shelf is displayed
[*][b]Compact info labels:[/b] Each zone carries its own context label so the chart remains interpretable without opening settings
[/list]

[b]Best Practices[/b]

[list]
[*]Give more weight to shelves that combine both repeated pivot defense and strong volume-confluence
[*]Watch how price behaves on the first return to a new shelf before assuming the level is strong
[*]Treat accepted zones and failed zones differently because they tell very different auction stories
[*]Use nearest support and resistance ATR distances to understand whether price is extended or structurally balanced
[*]Combine the ledger with your own trigger logic rather than assuming shelf presence alone is a complete trade plan
[/list]

[b]Input Parameters[/b]

[b]Structure Engine:[/b]
[list]
[*]Pivot Length: Sets how many bars are required on each side of a pivot to confirm it
[*]ATR Length: Controls the volatility measure used for zone sizing and tolerance logic
[*]Shelf ATR Width: Sets the width of each auction shelf relative to ATR
[*]Cluster Window: Defines how far back the script scans for repeated nearby pivots
[*]Cluster ATR Tolerance: Determines how close pivots must be to count as the same structural cluster
[/list]

[b]Volume Confluence:[/b]
[list]
[*]Volume Window: Sets the rolling price-volume study range
[*]Volume Bins: Controls the granularity of the confluence distribution
[*]Confluence Strength Threshold: Defines when the ribbon should represent strong price-volume overlap
[*]Show Confluence Ribbon: Toggles the contextual ribbon around price
[/list]

[b]Display:[/b]
[list]
[*]Show Dashboard: Enables the top-right structural summary
[*]Color inputs: Allow independent styling for support, resistance, neutral, and panel colors
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Start With The Bias Row[/b]
The dashboard summarizes whether active support shelves outnumber resistance shelves, whether the market is balanced, and how strong the current ledger looks. This gives immediate context before focusing on individual zones.

[b]Step 2: Identify The Strongest Active Shelf[/b]
Check the strongest zone reading and visually locate the shelf with the most emphasis. This is often the most useful structural reference when price approaches an auction boundary.

[b]Step 3: Watch Acceptance Versus Failure[/b]
Acceptance means price is interacting with the zone without invalidating it. Failure means price has moved through the wrong side of the shelf. A high failure rate weakens the reliability of the current ledger.

[b]Step 4: Use The Nearest ATR Distances[/b]
The dashboard shows the ATR distance to the nearest support and resistance shelves. That helps frame whether price is sitting directly on a structure reference or is trading between meaningful levels.

[b]Step 5: Combine With Your Own Execution Model[/b]
Auction Structure Ledger is most useful as a context layer. It defines where defended structure exists. It does not decide entries or exits for you. Use the zones to frame reactions, continuation decisions, or risk placement inside your own process.

[b]Indicator Limitations[/b]

[list]
[*]Pivot-based structure is inherently delayed because the script waits for right-side confirmation before creating a shelf
[*]A clustered pivot region can still fail immediately if broader market flow overwhelms the local auction structure
[*]Rolling volume-confluence is context-dependent and can shift as the lookback window evolves
[*]Zones are analytical references, not guarantees that support or resistance will hold on the next test
[/list]

[b]Originality Statement[/b]

Auction Structure Ledger is original in the way it turns clustered pivot defense and rolling volume-confluence into a persistent auction map. This is more than a standard support and resistance overlay:

[list]
[*]It requires repeated pivot behavior before treating a level as meaningful structure
[*]It combines cluster count and volume-confluence into a unified strength score for each shelf
[*]It tracks acceptance and failure after creation so zones remain part of a living ledger rather than a static drawing layer
[*]It presents the structure through a bias dashboard and confluence ribbon that helps translate zone behavior into usable chart context
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Support and resistance shelves represent historical auction behavior, not guaranteed future turning points. Markets can accept, reject, or ignore any level without warning. Always use independent judgment and appropriate risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Auction Structure Ledger [JOAT]", shorttitle = "MAP [JOAT]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 200)

//--------------------------------------------------------------------------------------------------
// JOAT Auction Structure Ledger
//--------------------------------------------------------------------------------------------------
// Purpose:
// - Convert defended pivots into structured auction references.
// - Track defended, accepted, and failed structure shelves.
// - Blend pivot clustering, zone persistence, and volume-confluence context.
//--------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------------------------------
string groupStructure = "Structure Engine"
int pivotLength = input.int(6, "Pivot Length", minval = 2, maxval = 20, group = groupStructure)
int shelfAtrLength = input.int(100, "ATR Length", minval = 20, maxval = 250, group = groupStructure)
float shelfAtrWidth = input.float(0.55, "Shelf ATR Width", minval = 0.10, maxval = 2.00, step = 0.05, group = groupStructure)
int clusterWindow = input.int(60, "Cluster Window", minval = 20, maxval = 200, group = groupStructure)
float clusterTolerance = input.float(0.22, "Cluster ATR Tolerance", minval = 0.05, maxval = 1.00, step = 0.01, group = groupStructure)

string groupVolume = "Volume Confluence"
int volumeWindow = input.int(200, "Volume Window", minval = 80, maxval = 400, group = groupVolume)
int volumeBins = input.int(32, "Volume Bins", minval = 12, maxval = 60, group = groupVolume)
float confluenceThreshold = input.float(55.0, "Confluence Strength %", minval = 10.0, maxval = 100.0, step = 0.5, group = groupVolume)
bool showConfluenceRibbon = input.bool(true, "Show Confluence Ribbon", group = groupVolume)

string groupStyle = "Visual Language"
color supportCore = input.color(color.rgb(31, 197, 143), "Support Core", group = groupStyle, inline = "a")
color resistanceCore = input.color(color.rgb(199, 63, 170), "Resistance Core", group = groupStyle, inline = "a")
color supportAccent = input.color(color.rgb(32, 123, 198), "Support Accent", group = groupStyle, inline = "b")
color resistanceAccent = input.color(color.rgb(255, 136, 74), "Resistance Accent", group = groupStyle, inline = "b")
color neutralCore = input.color(color.rgb(137, 146, 160), "Neutral", group = groupStyle)
color panelBg = input.color(color.rgb(14, 20, 30), "Panel Background", group = groupStyle)
bool showDashboard = input.bool(true, "Show Dashboard", group = groupStyle)

//--------------------------------------------------------------------------------------------------
// Types and state
//--------------------------------------------------------------------------------------------------
type StructureZone
    box body
    line spine
    label info
    float top
    float bottom
    bool resistance
    int createdBar
    float strength

var array<StructureZone> zones = array.new<StructureZone>()
var table dashboard = table.new(position.top_right, 2, 12, frame_color = color.new(color.white, 85), frame_width = 1)

//--------------------------------------------------------------------------------------------------
// Helpers
//--------------------------------------------------------------------------------------------------
safeDiv(float numerator, float denominator) =>
    denominator == 0.0 ? 0.0 : numerator / denominator

clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

zoneEdge(bool resistance, float intensity) =>
    color base = resistance ? resistanceCore : supportCore
    color accent = resistance ? resistanceAccent : supportAccent
    color.from_gradient(intensity, 0, 100, color.new(accent, 72), color.new(base, 0))

zoneFill(bool resistance, float intensity) =>
    color base = resistance ? resistanceCore : supportCore
    color accent = resistance ? resistanceAccent : supportAccent
    color.from_gradient(intensity, 0, 100, color.new(accent, 95), color.new(base, 85))

dashboardCell(int column, int row, string cellText, color bg, color fg) =>
    table.cell(dashboard, column, row, cellText, bgcolor = bg, text_color = fg, text_size = size.small)

deleteZone(StructureZone zone) =>
    box.delete(zone.body)
    line.delete(zone.spine)
    label.delete(zone.info)

zoneOverlaps(float topPrice, float bottomPrice, bool resistance) =>
    bool overlaps = false
    if zones.size() > 0
        for zone in zones
            float midExisting = math.avg(zone.top, zone.bottom)
            float midCandidate = math.avg(topPrice, bottomPrice)
            if zone.resistance == resistance and math.abs(midExisting - midCandidate) <= ta.atr(shelfAtrLength) * clusterTolerance
                overlaps := true
    overlaps

//--------------------------------------------------------------------------------------------------
// Volume confluence layer
//--------------------------------------------------------------------------------------------------
float windowHigh = ta.highest(high, volumeWindow)
float windowLow = ta.lowest(low, volumeWindow)
float windowRange = windowHigh - windowLow
float volumeBinSize = windowRange / volumeBins
int effectiveVolumeWindow = math.min(volumeWindow, bar_index + 1)
array<float> binVolumes = array.new_float(volumeBins, 0.0)

if barstate.islast and windowRange > 0 and effectiveVolumeWindow > 0
    for i = 0 to volumeBins - 1
        binVolumes.set(i, 0.0)
    for offset = 0 to effectiveVolumeWindow - 1
        float basis = close[offset]
        int rawIndex = int(math.floor((basis - windowLow) / volumeBinSize))
        int binIndex = math.max(0, math.min(volumeBins - 1, rawIndex))
        binVolumes.set(binIndex, binVolumes.get(binIndex) + volume[offset])

confluenceStrength(float levelPrice) =>
    if volumeBinSize <= 0
        0.0
    else
        int rawIndex = int(math.floor((levelPrice - windowLow) / volumeBinSize))
        int binIndex = math.max(0, math.min(volumeBins - 1, rawIndex))
        float levelVol = binVolumes.get(binIndex)
        safeDiv(levelVol, math.max(binVolumes.max(), 1.0)) * 100.0

//--------------------------------------------------------------------------------------------------
// Pivot detection and clustering
//--------------------------------------------------------------------------------------------------
float atrValue = ta.atr(shelfAtrLength)
float pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
float pivotLow = ta.pivotlow(low, pivotLength, pivotLength)

int localHighClusters = 0
int localLowClusters = 0
int effectiveClusterWindow = math.min(clusterWindow, bar_index)

for offset = 0 to effectiveClusterWindow
    if not na(pivotHigh[offset]) and not na(pivotHigh) and math.abs(pivotHigh[offset] - pivotHigh) <= atrValue * clusterTolerance
        localHighClusters += 1
    if not na(pivotLow[offset]) and not na(pivotLow) and math.abs(pivotLow[offset] - pivotLow) <= atrValue * clusterTolerance
        localLowClusters += 1

createZone(float pivotPrice, bool resistance, int clusterCount) =>
    float zoneWidth = atrValue * shelfAtrWidth
    float topPrice = resistance ? pivotPrice + zoneWidth : pivotPrice + zoneWidth * 0.40
    float bottomPrice = resistance ? pivotPrice - zoneWidth * 0.40 : pivotPrice - zoneWidth
    float strength = clamp(clusterCount * 16.0 + confluenceStrength(pivotPrice) * 0.65, 0, 100)
    color edge = zoneEdge(resistance, strength)
    color fill = zoneFill(resistance, strength)
    box body = box.new(bar_index - pivotLength, topPrice, bar_index + 2, bottomPrice, bgcolor = fill, border_color = edge, border_width = 1)
    line spine = line.new(bar_index - pivotLength, math.avg(topPrice, bottomPrice), bar_index + 20, math.avg(topPrice, bottomPrice), color = color.new(edge, 15), width = 1, style = line.style_dotted)
    string zoneText = (resistance ? "Offered" : "Bid") + "\nC " + str.tostring(clusterCount) + "\nV " + str.tostring(confluenceStrength(pivotPrice), "#.0") + "%"
    label info = label.new(bar_index + 21, math.avg(topPrice, bottomPrice), zoneText, style = label.style_label_left, color = color.new(panelBg, 0), textcolor = edge, size = size.tiny)
    StructureZone.new(body, spine, info, topPrice, bottomPrice, resistance, bar_index, strength)

if barstate.isconfirmed and not na(pivotHigh) and localHighClusters >= 2 and not zoneOverlaps(pivotHigh, pivotHigh - atrValue * shelfAtrWidth, true)
    zones.push(createZone(high[pivotLength], true, localHighClusters))

if barstate.isconfirmed and not na(pivotLow) and localLowClusters >= 2 and not zoneOverlaps(pivotLow + atrValue * shelfAtrWidth, pivotLow, false)
    zones.push(createZone(low[pivotLength], false, localLowClusters))

if zones.size() > 14
    StructureZone expired = zones.shift()
    deleteZone(expired)

//--------------------------------------------------------------------------------------------------
// Zone maintenance
//--------------------------------------------------------------------------------------------------
int supportCount = 0
int resistanceCount = 0
int acceptedCount = 0
int failedCount = 0
float strongestZone = 0.0
float nearestSupportDistanceAtr = na
float nearestResistanceDistanceAtr = na
array<int> removeIndexes = array.new_int()

if zones.size() > 0
    for index = 0 to zones.size() - 1
        StructureZone zone = zones.get(index)
        float midPrice = math.avg(zone.top, zone.bottom)
        bool touched = high >= zone.bottom and low <= zone.top
        bool failed = zone.resistance ? close > zone.top : close < zone.bottom
        bool accepted = zone.resistance ? close < zone.top and close > zone.bottom : close > zone.bottom and close < zone.top

        strongestZone := math.max(strongestZone, zone.strength)
        zone.body.set_right(bar_index + 12)
        zone.spine.set_x2(bar_index + 20)
        zone.info.set_x(bar_index + 21)

        if zone.resistance
            resistanceCount += 1
            float currentResistanceDistance = safeDiv(midPrice - close, atrValue)
            nearestResistanceDistanceAtr := na(nearestResistanceDistanceAtr) ? currentResistanceDistance : math.min(nearestResistanceDistanceAtr, currentResistanceDistance)
        else
            supportCount += 1
            float currentSupportDistance = safeDiv(close - midPrice, atrValue)
            nearestSupportDistanceAtr := na(nearestSupportDistanceAtr) ? currentSupportDistance : math.min(nearestSupportDistanceAtr, currentSupportDistance)

        if accepted
            acceptedCount += 1
        if failed
            failedCount += 1

        color edge = zoneEdge(zone.resistance, zone.strength)
        color fill = zoneFill(zone.resistance, zone.strength)

        if touched
            fill := color.new(edge, 90)

        if failed
            edge := color.new(edge, 65)
            fill := color.new(edge, 96)

        zone.body.set_bgcolor(fill)
        zone.body.set_border_color(edge)
        zone.spine.set_color(color.new(edge, 10))
        zone.info.set_textcolor(edge)
        zone.info.set_text((zone.resistance ? "Offered" : "Bid") + "\nS " + str.tostring(zone.strength, "#.0"))

        if failed and bar_index - zone.createdBar > 4
            array.push(removeIndexes, index)

if removeIndexes.size() > 0
    for removal = removeIndexes.size() - 1 to 0
        int removeIndex = removeIndexes.get(removal)
        StructureZone doomed = zones.get(removeIndex)
        deleteZone(doomed)
        zones.remove(removeIndex)

//--------------------------------------------------------------------------------------------------
// Confluence ribbon
//--------------------------------------------------------------------------------------------------
float confluenceBasis = ta.ema(close, 21)
float confluenceHi = confluenceBasis + atrValue * 0.30
float confluenceLo = confluenceBasis - atrValue * 0.30
float priceConfluence = confluenceStrength(close)
color ribbonColor =
     priceConfluence >= confluenceThreshold
     ? color.from_gradient(priceConfluence, confluenceThreshold, 100, color.new(supportAccent, 75), color.new(supportCore, 0))
     : color.from_gradient(priceConfluence, 0, confluenceThreshold, color.new(resistanceCore, 0), color.new(resistanceAccent, 75))

ribbonTop = plot(showConfluenceRibbon ? confluenceHi : na, "Confluence High", color = color.new(ribbonColor, 65))
ribbonBot = plot(showConfluenceRibbon ? confluenceLo : na, "Confluence Low", color = color.new(ribbonColor, 65))
fill(ribbonTop, ribbonBot, color = color.new(ribbonColor, 92))

color structureCandle =
     supportCount > resistanceCount
     ? color.from_gradient(float(supportCount), 0, 8, color.new(supportCore, 70), color.new(supportCore, 0))
     : resistanceCount > supportCount
       ? color.from_gradient(float(resistanceCount), 0, 8, color.new(resistanceCore, 70), color.new(resistanceCore, 0))
       : color.new(color.gray, 65)

barcolor(structureCandle)
plotcandle(open, high, low, close, color = structureCandle, wickcolor = structureCandle, bordercolor = structureCandle, force_overlay = true, title = "Structure Candles")

//--------------------------------------------------------------------------------------------------
// Dashboard
//--------------------------------------------------------------------------------------------------
if showDashboard and barstate.islast
    color topPanel = color.new(supportCount >= resistanceCount ? supportCore : resistanceCore, 84)
    float zoneCount = zones.size()
    float acceptanceRatio = safeDiv(acceptedCount, math.max(zoneCount, 1.0)) * 100.0
    float failureRatio = safeDiv(failedCount, math.max(zoneCount, 1.0)) * 100.0
    dashboardCell(0, 0, "Auction Ledger", topPanel, color.white)
    dashboardCell(1, 0, syminfo.ticker, topPanel, color.white)

    dashboardCell(0, 1, "Supports", panelBg, color.new(color.white, 10))
    dashboardCell(1, 1, str.tostring(supportCount), panelBg, supportCore)

    dashboardCell(0, 2, "Resistances", panelBg, color.new(color.white, 10))
    dashboardCell(1, 2, str.tostring(resistanceCount), panelBg, resistanceCore)

    dashboardCell(0, 3, "Accepted", panelBg, color.new(color.white, 10))
    dashboardCell(1, 3, str.tostring(acceptedCount), panelBg, color.white)

    dashboardCell(0, 4, "Failed", panelBg, color.new(color.white, 10))
    dashboardCell(1, 4, str.tostring(failedCount), panelBg, resistanceCore)

    dashboardCell(0, 5, "Confluence", panelBg, color.new(color.white, 10))
    dashboardCell(1, 5, str.tostring(priceConfluence, "#.0") + "%", panelBg, ribbonColor)

    dashboardCell(0, 6, "Strongest", panelBg, color.new(color.white, 10))
    dashboardCell(1, 6, str.tostring(strongestZone, "#.0") + "%", panelBg, color.white)

    dashboardCell(0, 7, "Bias", panelBg, color.new(color.white, 10))
    dashboardCell(1, 7, supportCount > resistanceCount ? "Accumulation" : resistanceCount > supportCount ? "Distribution" : "Balanced", panelBg, supportCount > resistanceCount ? supportCore : resistanceCount > supportCount ? resistanceCore : color.white)

    dashboardCell(0, 8, "Zone Count", panelBg, color.new(color.white, 10))
    dashboardCell(1, 8, str.tostring(zoneCount), panelBg, color.white)

    dashboardCell(0, 9, "Accept %", panelBg, color.new(color.white, 10))
    dashboardCell(1, 9, str.tostring(acceptanceRatio, "#.0") + "%", panelBg, supportCore)

    dashboardCell(0, 10, "Fail %", panelBg, color.new(color.white, 10))
    dashboardCell(1, 10, str.tostring(failureRatio, "#.0") + "%", panelBg, resistanceCore)

    dashboardCell(0, 11, "Nearest ATR", panelBg, color.new(color.white, 10))
    dashboardCell(1, 11, "S " + (na(nearestSupportDistanceAtr) ? "na" : str.tostring(nearestSupportDistanceAtr, "#.00")) + " | R " + (na(nearestResistanceDistanceAtr) ? "na" : str.tostring(nearestResistanceDistanceAtr, "#.00")), panelBg, color.white)

//--------------------------------------------------------------------------------------------------
// Alerts
//--------------------------------------------------------------------------------------------------
bool bullishLedger = barstate.isconfirmed and supportCount > resistanceCount and priceConfluence >= confluenceThreshold
bool bearishLedger = barstate.isconfirmed and resistanceCount > supportCount and priceConfluence < confluenceThreshold
bool freshSupport = barstate.isconfirmed and not na(pivotLow) and localLowClusters >= 2
bool freshResistance = barstate.isconfirmed and not na(pivotHigh) and localHighClusters >= 2

alertcondition(bullishLedger, "JOAT Structure Bullish Ledger", "Auction Structure Ledger confirms accumulation-side structure.")
alertcondition(bearishLedger, "JOAT Structure Bearish Ledger", "Auction Structure Ledger confirms distribution-side structure.")
alertcondition(freshSupport, "JOAT Structure Fresh Support", "Auction Structure Ledger printed a new defended support zone.")
alertcondition(freshResistance, "JOAT Structure Fresh Resistance", "Auction Structure Ledger printed a new defended resistance zone.")

plot(float(array.size(zones)), "Zone Count (Data Window)", color = neutralCore, display = display.data_window)
plot(priceConfluence, "Confluence (Data Window)", color = ribbonColor, display = display.data_window)
plot(float(supportCount - resistanceCount), "Structure Bias (Data Window)", color = supportCount >= resistanceCount ? supportCore : resistanceCore, display = display.data_window)
plot(nearestSupportDistanceAtr, "Nearest Support ATR (Data Window)", color = supportCore, display = display.data_window)
plot(nearestResistanceDistanceAtr, "Nearest Resistance ATR (Data Window)", color = resistanceCore, display = display.data_window)
plot(safeDiv(acceptedCount, math.max(zones.size(), 1.0)) * 100.0, "Acceptance Ratio % (Data Window)", color = supportCore, display = display.data_window)
````
