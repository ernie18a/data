# Meridian Liquidity Ledger [JOAT]

- url: https://www.tradingview.com/script/z7bRffFR-Meridian-Liquidity-Ledger-JOAT/
- type: indicator
- pine_id: PUB;f8849eb7c8e946eca3b0d3f6497ff903
- version: 1.0

## Description

[b]Meridian Liquidity Ledger [JOAT][/b]

[b]Introduction[/b]

Meridian Liquidity Ledger is an open-source Pine Script v6 indicator that maps directional liquidity shelves across a rolling price window. It separates buy-side and sell-side volume concentration, ranks shelves by relative participation strength, extends the most relevant levels through the chart, and summarizes the current liquidity ledger in an institutional-style dashboard.

The problem this indicator solves is density. A standard volume profile can show where volume accumulated, but it often does not express directional participation clearly enough for traders who want to know whether the market built more inventory above or below a reference anchor. Meridian Liquidity Ledger addresses that by classifying shelves relative to an adaptive reference price and showing whether each shelf behaves more like a buy shelf or a sell shelf.

The script is intended for traders who think in terms of inventory, acceptance, and liquidity stacking. It does not try to replace execution logic. It provides a map of where volume concentrated across the rolling ledger window, where the point of control sits, how dominant the buy-side and sell-side shares are, and how far price has stretched from the anchor and point of control in ATR terms.

Because the heavy rendering happens only on the last visible bar, the indicator aims to deliver rich visual output without turning into an unreadable chart wall. Historical shelf zones, profile bars, dotted spines, the point of control extension, and the dashboard all work together to make the liquidity map readable rather than overwhelming.

[image]https://www.tradingview.com/x/CloQB79l/[/image]

[b]Core Concepts[/b]

[b]1. Adaptive Reference Price[/b]

At the center of the ledger is a reference engine built from an EMA and a deviation adjustment. The script can use a plain EMA reference or a slight adaptive band depending on the user setting.

[pine]
float emaRef = ta.ema(close, referenceLength)
float rangeDev = ta.stdev(close, deviationLength) * referenceBias
float synthetic = close >= emaRef ? emaRef - rangeDev * 0.20 : emaRef + rangeDev * 0.20
[/pine]

This reference acts as the ledger divider. Shelves above the reference are treated as sell-side inventory zones. Shelves below the reference are treated as buy-side inventory zones.

[b]2. Rolling Price-Volume Binning[/b]

The script scans a configurable lookback window, divides the full price range into bins, and accumulates total, buy-side, and sell-side volume in each bin. This creates the ledger foundation.

Instead of looking only at price touches, the indicator asks where actual traded volume concentrated across the window. That gives each shelf more meaning than a simple horizontal line.

[b]3. Shelf Strength Ranking[/b]

Each bin’s relative strength is measured as a percentage of the maximum bin volume in the window. Only shelves above the minimum strength threshold are rendered. That keeps weak background noise from cluttering the chart.

This is important because the point of the ledger is not to show every possible micro shelf. It is to show the shelves that stood out meaningfully within the chosen lookback.

[b]4. Shelf History And Spine Extension[/b]

For each active shelf, the script estimates how far left the midpoint price was last crossed, then draws a historical zone, a profile bar on the right, and an optional dotted spine through the shelf midpoint. This creates both historical and forward reference in a single visual package.

The effect is similar to having a compressed split-profile, a shelf map, and a point-of-interest extension all in one indicator.

[b]5. Point Of Control And Ledger Balance[/b]

The point of control is the strongest single shelf in the active ledger. The script can extend that level to the right and label it. At the same time, the dashboard tracks buy share, sell share, total imbalance, top-shelf concentration, and ATR distance to both the reference and the point of control.

This makes the ledger useful not just visually but quantitatively.

[image]https://www.tradingview.com/x/3MMq3KRF/[/image]

[b]Features[/b]

[list]
[*][b]Directional liquidity shelves:[/b] Separates bins into buy-side and sell-side inventory relative to the reference anchor
[*][b]Adaptive reference engine:[/b] Uses EMA and deviation bias to frame the ledger around a contextual central price
[*][b]Rolling volume ledger:[/b] Accumulates total, buy, and sell participation across a user-defined window
[*][b]Shelf strength filter:[/b] Displays only bins strong enough to matter
[*][b]Historical shelf zones:[/b] Shows where active shelves projected through the recent chart history
[*][b]Profile bars on the right edge:[/b] Renders compact shelf bars for immediate strength comparison
[*][b]Shelf spines:[/b] Optional dotted lines extend each shelf midpoint through the chart
[*][b]Point-of-control extension:[/b] Marks and extends the strongest shelf in the current ledger
[*][b]Institutional dashboard:[/b] Displays buy share, sell share, imbalance, POC, concentration, shelf count, and ATR distance metrics
[*][b]Confirmed-bar alerts:[/b] Includes buy dominance, sell dominance, and anchor stretch conditions
[/list]

[b]Visual Elements[/b]

[list]
[*][b]Historical shelf zones:[/b] These show where strong bins projected back through the active ledger window
[*][b]Right-edge profile bars:[/b] Compact bars make it easy to compare shelf strength without reading every label
[*][b]Shelf spines:[/b] Optional dotted midpoint lines extend the key shelf levels through the chart
[*][b]Anchor bands:[/b] Inner and outer reference bands help frame whether price is balanced or stretched
[*][b]POC label and extension:[/b] The strongest shelf remains visible as the primary ledger reference
[/list]

[b]Best Practices[/b]

[list]
[*]Use the ledger to frame where inventory is concentrated before applying your own execution logic
[*]Watch the relationship between price, the anchor, and the point of control to judge balance versus stretch
[*]Favor shelves that remain visually dominant even as the rolling window updates
[*]Remember that shelf color and position are contextual to the current anchor, not absolute predictions of support or resistance
[*]Use the buy-share and sell-share readings to understand ledger skew before reacting to a single shelf in isolation
[/list]

[b]Input Parameters[/b]

[b]Ledger Window:[/b]
[list]
[*]Lookback Bars: Sets the rolling history used to build the ledger
[*]Bin Count: Controls the price segmentation granularity
[*]Profile Width: Controls the maximum width of the profile bars on the right
[*]Shelf Padding: Adjusts the spacing between price and the right-edge profile
[/list]

[b]Reference Engine:[/b]
[list]
[*]Reference EMA Length: Sets the central EMA anchor
[*]Deviation Length: Controls the standard-deviation calculation for adaptive biasing
[*]Reference Bias: Scales the adaptive offset around the EMA
[*]Use Adaptive Anchor Band: Chooses between the synthetic anchor and plain EMA reference
[/list]

[b]Shelf Filters And Display:[/b]
[list]
[*]Minimum Shelf Strength %: Removes shelves below the selected threshold
[*]Show Historical Shelf Zones: Toggles the historical box layer
[*]Extend Point Of Control: Projects the strongest shelf forward
[*]Show Shelf Spines: Enables midpoint extension lines
[*]Show Dashboard: Enables the top-right ledger panel
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Start With Buy Share, Sell Share, And Imbalance[/b]
The dashboard tells you how the rolling ledger is currently distributed. If buy share dominates, the ledger is skewed below or through the anchor in a way that favors buy-side participation. If sell share dominates, the opposite is true.

[b]Step 2: Locate The Point Of Control[/b]
Find the extended POC line. This is the strongest shelf in the current window. It often acts as the most important reference price when judging whether the market is balanced, stretched, or returning to its highest concentration zone.

[b]Step 3: Compare Price To The Reference Anchor[/b]
The reference and its surrounding bands tell you whether price is trading above, below, or far away from the ledger center. This is useful for deciding whether the market is exploring beyond inventory or still trading within its main concentration zone.

[b]Step 4: Focus On The Strongest Shelves[/b]
The most useful shelves are usually the ones with the greatest width, clearest labels, and strongest color intensity. Those are the bins where the rolling window concentrated the most inventory.

[b]Step 5: Use The Ledger As A Context Map[/b]
Meridian Liquidity Ledger is best used as a map of where liquidity stacked and how it is distributed. Pair it with your own entry logic rather than treating any single shelf as an automatic trade signal.

[b]Indicator Limitations[/b]

[list]
[*]The ledger is rolling-window dependent, so shelf hierarchy can change as older bars leave the calculation window
[*]A strong shelf does not guarantee support or resistance will hold on the next interaction
[*]Directional buy and sell classification is based on bar-level bullish versus bearish volume attribution, which is an approximation rather than true order-flow data
[*]On illiquid symbols or very small windows, shelf concentration can become unstable and less informative
[/list]

[b]Originality Statement[/b]

Meridian Liquidity Ledger is original in the way it turns a rolling bin-based volume map into a directional liquidity shelf system with adaptive anchoring. It is not a generic profile overlay:

[list]
[*]It separates buy-side and sell-side participation relative to an adaptive reference rather than showing only total profile mass
[*]It combines historical shelf zones, right-edge shelf bars, shelf spines, and POC extension in one integrated view
[*]It frames liquidity through dashboard metrics such as imbalance, concentration, and ATR stretch rather than pure histogram display
[*]It creates a practical shelf map for context instead of relying on a single profile style or one static reference
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Liquidity shelves and point-of-control levels are descriptive references built from rolling historical data. They do not guarantee future support, resistance, or directional continuation. Always use independent judgment and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Meridian Liquidity Ledger [JOAT]", shorttitle = "TID [JOAT]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 200)
//--------------------------------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------------------------------
string groupWindow = "Ledger Window"
int lookbackBars = input.int(220, "Lookback Bars", minval = 80, maxval = 500, group = groupWindow)
int binCount = input.int(42, "Bin Count", minval = 16, maxval = 80, group = groupWindow)
int profileWidth = input.int(34, "Profile Width", minval = 10, maxval = 70, group = groupWindow)
int shelfPadding = input.int(8, "Shelf Padding", minval = 0, maxval = 20, group = groupWindow)

string groupAnchor = "Reference Engine"
int referenceLength = input.int(55, "Reference EMA Length", minval = 10, maxval = 150, group = groupAnchor)
int deviationLength = input.int(34, "Deviation Length", minval = 10, maxval = 100, group = groupAnchor)
float referenceBias = input.float(0.70, "Reference Bias", minval = 0.10, maxval = 2.00, step = 0.05, group = groupAnchor)
bool useAnchorBand = input.bool(true, "Use Adaptive Anchor Band", group = groupAnchor)

string groupFilters = "Shelf Filters"
float minShelfPct = input.float(18.0, "Minimum Shelf Strength %", minval = 1.0, maxval = 100.0, step = 0.5, group = groupFilters)
bool showHistoricalShelves = input.bool(true, "Show Historical Shelf Zones", group = groupFilters)
bool extendPointOfControl = input.bool(true, "Extend Point Of Control", group = groupFilters)
bool showSpines = input.bool(true, "Show Shelf Spines", group = groupFilters)
bool showDashboard = input.bool(true, "Show Dashboard", group = groupFilters)

string groupStyle = "Visual Language"
color buyCore = input.color(color.rgb(19, 202, 156), "Buy Core", group = groupStyle, inline = "a")
color sellCore = input.color(color.rgb(206, 37, 143), "Sell Core", group = groupStyle, inline = "a")
color buyGlow = input.color(color.rgb(22, 109, 183), "Buy Secondary", group = groupStyle, inline = "b")
color sellGlow = input.color(color.rgb(255, 112, 67), "Sell Secondary", group = groupStyle, inline = "b")
color neutralLine = input.color(color.rgb(140, 149, 160), "Neutral", group = groupStyle)
color dashboardBg = input.color(color.rgb(14, 20, 30), "Dashboard Background", group = groupStyle)

//--------------------------------------------------------------------------------------------------
// Types
//--------------------------------------------------------------------------------------------------
type ShelfVisual
    box shelfZone
    box shelfBar
    line spine
    label shelfLabel

//--------------------------------------------------------------------------------------------------
// Persistent containers
//--------------------------------------------------------------------------------------------------
var array<ShelfVisual> shelfVisuals = array.new<ShelfVisual>()
var line pocLine = na
var label pocLabel = na
var float dashboardBuyShare = na
var float dashboardSellShare = na
var float dashboardPocPrice = na
var float dashboardConcentration = na
var table dashboard = table.new(position.top_right, 2, 12, frame_color = color.new(color.white, 85), frame_width = 1)

//--------------------------------------------------------------------------------------------------
// Helper functions
//--------------------------------------------------------------------------------------------------
clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

safeDiv(float numerator, float denominator) =>
    denominator == 0.0 ? 0.0 : numerator / denominator

formatPercent(float value) =>
    str.tostring(value * 0.01, "#.0%")

formatVolume(float value) =>
    str.tostring(value, format.volume)

getReferencePrice() =>
    float emaRef = ta.ema(close, referenceLength)
    float rangeDev = ta.stdev(close, deviationLength) * referenceBias
    float synthetic = close >= emaRef ? emaRef - rangeDev * 0.20 : emaRef + rangeDev * 0.20
    useAnchorBand ? synthetic : emaRef

getShelfColor(bool aboveRef, float intensity) =>
    color primary = aboveRef ? sellCore : buyCore
    color secondary = aboveRef ? sellGlow : buyGlow
    color.from_gradient(intensity, 0, 100, color.new(secondary, 85), color.new(primary, 0))

getShelfFill(bool aboveRef, float intensity) =>
    color primary = aboveRef ? sellCore : buyCore
    color secondary = aboveRef ? sellGlow : buyGlow
    color.from_gradient(intensity, 0, 100, color.new(secondary, 96), color.new(primary, 84))

getMidpointCrossLeft(float shelfPrice) =>
    int effectiveLookback = math.min(lookbackBars, bar_index + 1)
    int resolvedLeft = bar_index - effectiveLookback + 1
    for offset = effectiveLookback - 1 to 0
        bool crossed = high[offset] >= shelfPrice and low[offset] <= shelfPrice
        if crossed
            resolvedLeft := bar_index - offset + 1
    resolvedLeft

clearShelfObjects() =>
    if array.size(shelfVisuals) > 0
        for visual in shelfVisuals
            box.delete(visual.shelfZone)
            box.delete(visual.shelfBar)
            line.delete(visual.spine)
            label.delete(visual.shelfLabel)
    array.clear(shelfVisuals)
    line.delete(pocLine)
    label.delete(pocLabel)

setDashboardCell(int column, int row, string cellText, color bg, color fg) =>
    table.cell(dashboard, column, row, cellText, bgcolor = bg, text_color = fg, text_size = size.small)

//--------------------------------------------------------------------------------------------------
// Core calculations
//--------------------------------------------------------------------------------------------------
float referencePrice = getReferencePrice()
float highestWindow = ta.highest(high, lookbackBars)
float lowestWindow = ta.lowest(low, lookbackBars)
float totalRange = highestWindow - lowestWindow
float binSize = totalRange / binCount
bool validWindow = totalRange > 0 and binSize > 0
int effectiveLookbackBars = math.min(lookbackBars, bar_index + 1)

array<float> totalBins = array.new_float(binCount, 0.0)
array<float> buyBins = array.new_float(binCount, 0.0)
array<float> sellBins = array.new_float(binCount, 0.0)

if barstate.islast and validWindow and effectiveLookbackBars > 0
    for barOffset = 0 to effectiveLookbackBars - 1
        float priceValue = hlc3[barOffset]
        int rawIndex = int(math.floor((priceValue - lowestWindow) / binSize))
        int binIndex = int(clamp(rawIndex, 0, binCount - 1))
        float barVol = volume[barOffset]
        float buyVol = close[barOffset] >= open[barOffset] ? barVol : 0.0
        float sellVol = close[barOffset] < open[barOffset] ? barVol : 0.0

        array.set(totalBins, binIndex, array.get(totalBins, binIndex) + barVol)
        array.set(buyBins, binIndex, array.get(buyBins, binIndex) + buyVol)
        array.set(sellBins, binIndex, array.get(sellBins, binIndex) + sellVol)

//--------------------------------------------------------------------------------------------------
// Draw pass
//--------------------------------------------------------------------------------------------------
if barstate.islast and validWindow
    clearShelfObjects()

    float maxVolume = totalBins.max()
    float totalBuy = buyBins.sum()
    float totalSell = sellBins.sum()
    float totalVolume = totalBins.sum()
    float imbalance = safeDiv(totalBuy - totalSell, totalVolume)
    float buyShare = safeDiv(totalBuy, totalVolume)
    float sellShare = safeDiv(totalSell, totalVolume)
    float concentrationRatio = safeDiv(maxVolume, math.max(totalVolume, 1.0))
    float referenceDistanceAtr = safeDiv(close - referencePrice, ta.atr(100))
    float referenceRangeShare = safeDiv(referencePrice - lowestWindow, math.max(highestWindow - lowestWindow, syminfo.mintick)) * 100.0

    int pocIndex = array.indexof(totalBins, maxVolume)
    float pocPrice = lowestWindow + binSize * pocIndex + binSize * 0.5
    dashboardBuyShare := buyShare
    dashboardSellShare := sellShare
    dashboardPocPrice := pocPrice
    dashboardConcentration := concentrationRatio

    for binIndex = 0 to binCount - 1
        float lower = lowestWindow + binSize * binIndex
        float upper = lower + binSize
        float mid = math.avg(lower, upper)
        float volumeValue = array.get(totalBins, binIndex)
        float buyValue = array.get(buyBins, binIndex)
        float sellValue = array.get(sellBins, binIndex)

        float shelfPct = safeDiv(volumeValue, maxVolume) * 100.0
        bool aboveRef = mid >= referencePrice
        bool passesFilter = shelfPct >= minShelfPct

        if passesFilter
            int historyLeft = getMidpointCrossLeft(mid)
            int profileRight = bar_index + profileWidth + shelfPadding
            int profileLeft = bar_index + shelfPadding
            int shelfWidth = int(math.round(safeDiv(volumeValue, maxVolume) * profileWidth))
            int barRight = profileLeft + shelfWidth

            color shelfLineColor = getShelfColor(aboveRef, shelfPct)
            color shelfFillColor = getShelfFill(aboveRef, shelfPct)
            color zoneFillColor = color.new(shelfLineColor, aboveRef ? 92 : 90)

            box zone = box.new(historyLeft, upper, bar_index, lower, bgcolor = showHistoricalShelves ? zoneFillColor : color.new(zoneFillColor, 100), border_color = color.new(shelfLineColor, 60), border_width = 1)
            box profileBarBox = box.new(profileLeft, upper, barRight, lower, bgcolor = shelfFillColor, border_color = color.new(shelfLineColor, 50), border_width = 1)
            line shelfSpine = line.new(bar_index - effectiveLookbackBars + 1, mid, bar_index + profileWidth + shelfPadding, mid, color = showSpines ? color.new(shelfLineColor, 30) : color.new(shelfLineColor, 100), style = line.style_dotted, width = 1)

            float sideBalance = safeDiv(math.abs(buyValue - sellValue), volumeValue)
            string sideTag = aboveRef ? "Sell Shelf" : "Buy Shelf"
            string labelText = sideTag + "\n" + formatVolume(volumeValue) + "\nBias " + formatPercent(sideBalance * 100)
            label shelfInfo = label.new(profileRight + 1, mid, labelText, style = label.style_label_left, color = color.new(dashboardBg, 0), textcolor = shelfLineColor, size = size.tiny)

            array.push(shelfVisuals, ShelfVisual.new(zone, profileBarBox, shelfSpine, shelfInfo))

    if extendPointOfControl
        color pocColor = getShelfColor(pocPrice >= referencePrice, 100.0)
        pocLine := line.new(bar_index - effectiveLookbackBars + 1, pocPrice, bar_index + profileWidth + shelfPadding + 10, pocPrice, color = pocColor, width = 2)
        pocLabel := label.new(bar_index + profileWidth + shelfPadding + 11, pocPrice, "POC\n" + formatVolume(maxVolume), style = label.style_label_left, color = color.new(dashboardBg, 0), textcolor = pocColor, size = size.small)

    if showDashboard
        color panelEdge = imbalance >= 0 ? buyCore : sellCore
        color panelSoft = color.new(panelEdge, 84)
        float pocDistanceAtr = safeDiv(close - pocPrice, ta.atr(100))
        int activeShelfCount = shelfVisuals.size()

        setDashboardCell(0, 0, "Meridian Ledger", panelSoft, color.white)
        setDashboardCell(1, 0, syminfo.ticker, panelSoft, color.white)

        setDashboardCell(0, 1, "Reference", dashboardBg, color.new(neutralLine, 0))
        setDashboardCell(1, 1, str.tostring(referencePrice, format.mintick), dashboardBg, color.white)

        setDashboardCell(0, 2, "Buy Share", dashboardBg, color.new(neutralLine, 0))
        setDashboardCell(1, 2, formatPercent(buyShare * 100), dashboardBg, buyCore)

        setDashboardCell(0, 3, "Sell Share", dashboardBg, color.new(neutralLine, 0))
        setDashboardCell(1, 3, formatPercent(sellShare * 100), dashboardBg, sellCore)

        setDashboardCell(0, 4, "Imbalance", dashboardBg, color.new(neutralLine, 0))
        setDashboardCell(1, 4, formatPercent(imbalance * 100), dashboardBg, imbalance >= 0 ? buyCore : sellCore)

        setDashboardCell(0, 5, "POC", dashboardBg, color.new(neutralLine, 0))
        setDashboardCell(1, 5, str.tostring(pocPrice, format.mintick), dashboardBg, panelEdge)

        setDashboardCell(0, 6, "Ledger Vol", dashboardBg, color.new(neutralLine, 0))
        setDashboardCell(1, 6, formatVolume(totalVolume), dashboardBg, color.white)

        setDashboardCell(0, 7, "Shelf Count", dashboardBg, color.new(neutralLine, 0))
        setDashboardCell(1, 7, str.tostring(activeShelfCount), dashboardBg, panelEdge)

        setDashboardCell(0, 8, "POC Dist ATR", dashboardBg, color.new(neutralLine, 0))
        setDashboardCell(1, 8, str.tostring(pocDistanceAtr, "#.00"), dashboardBg, pocDistanceAtr >= 0 ? buyCore : sellCore)

        setDashboardCell(0, 9, "Top Shelf %", dashboardBg, color.new(neutralLine, 0))
        setDashboardCell(1, 9, formatPercent(concentrationRatio * 100), dashboardBg, panelEdge)

        setDashboardCell(0, 10, "Ref Dist ATR", dashboardBg, color.new(neutralLine, 0))
        setDashboardCell(1, 10, str.tostring(referenceDistanceAtr, "#.00"), dashboardBg, referenceDistanceAtr >= 0 ? buyCore : sellCore)

        setDashboardCell(0, 11, "Ref Range %", dashboardBg, color.new(neutralLine, 0))
        setDashboardCell(1, 11, formatPercent(referenceRangeShare), dashboardBg, referenceRangeShare >= 50 ? sellCore : buyCore)

//--------------------------------------------------------------------------------------------------
// Reference and contextual overlays
//--------------------------------------------------------------------------------------------------
float anchorUpper = referencePrice + ta.stdev(close, deviationLength) * 0.55
float anchorLower = referencePrice - ta.stdev(close, deviationLength) * 0.55
float outerAnchorUpper = referencePrice + ta.stdev(close, deviationLength) * 1.10
float outerAnchorLower = referencePrice - ta.stdev(close, deviationLength) * 1.10

plot(referencePrice, "Reference Price", color = color.new(neutralLine, 10), linewidth = 2)
plot(anchorUpper, "Anchor Upper", color = color.new(sellGlow, 65), linewidth = 1)
plot(anchorLower, "Anchor Lower", color = color.new(buyGlow, 65), linewidth = 1)
plot(outerAnchorUpper, "Outer Anchor Upper", color = color.new(sellCore, 80), linewidth = 1)
plot(outerAnchorLower, "Outer Anchor Lower", color = color.new(buyCore, 80), linewidth = 1)

refUpperPlot = plot(anchorUpper, "", display = display.none)
refLowerPlot = plot(anchorLower, "", display = display.none)
fill(refUpperPlot, refLowerPlot, color = color.new(color.rgb(34, 41, 55), 78))

outerUpperPlot = plot(outerAnchorUpper, "", display = display.none)
outerLowerPlot = plot(outerAnchorLower, "", display = display.none)
fill(outerUpperPlot, refUpperPlot, color = color.new(sellGlow, 95))
fill(refLowerPlot, outerLowerPlot, color = color.new(buyGlow, 95))

color candleColor =
     close >= referencePrice
     ? color.from_gradient(close - referencePrice, 0, ta.atr(100), color.new(buyCore, 35), color.new(buyCore, 0))
     : color.from_gradient(referencePrice - close, 0, ta.atr(100), color.new(sellCore, 35), color.new(sellCore, 0))

barcolor(candleColor)
plotcandle(open, high, low, close, color = candleColor, wickcolor = candleColor, bordercolor = candleColor, force_overlay = true, title = "Ledger Candles")

//--------------------------------------------------------------------------------------------------
// Confirmed-bar state series for alerts and external interpretation
//--------------------------------------------------------------------------------------------------
float rollingBuyVolume = math.sum(close >= open ? volume : 0.0, lookbackBars)
float rollingSellVolume = math.sum(close < open ? volume : 0.0, lookbackBars)
float ledgerImbalanceSeries = safeDiv(rollingBuyVolume - rollingSellVolume, math.max(rollingBuyVolume + rollingSellVolume, 1.0))
float concentrationSeries = safeDiv(ta.highest(volume, lookbackBars), math.max(math.sum(volume, lookbackBars), 1.0))
float referenceDistanceAtrSeries = safeDiv(close - referencePrice, ta.atr(100))
float referenceRangeShareSeries = safeDiv(referencePrice - lowestWindow, math.max(highestWindow - lowestWindow, syminfo.mintick)) * 100.0
bool buyDominance = barstate.isconfirmed and ledgerImbalanceSeries > 0.12 and close >= referencePrice
bool sellDominance = barstate.isconfirmed and ledgerImbalanceSeries < -0.12 and close <= referencePrice
bool stretchedAboveLedger = barstate.isconfirmed and close > outerAnchorUpper and ledgerImbalanceSeries > 0
bool stretchedBelowLedger = barstate.isconfirmed and close < outerAnchorLower and ledgerImbalanceSeries < 0

alertcondition(buyDominance, "JOAT Meridian Buy Dominance", "Meridian Liquidity Ledger has confirmed buy-side dominance.")
alertcondition(sellDominance, "JOAT Meridian Sell Dominance", "Meridian Liquidity Ledger has confirmed sell-side dominance.")
alertcondition(stretchedAboveLedger, "JOAT Meridian Upper Stretch", "Meridian Liquidity Ledger confirms an upper anchor stretch with positive ledger bias.")
alertcondition(stretchedBelowLedger, "JOAT Meridian Lower Stretch", "Meridian Liquidity Ledger confirms a lower anchor stretch with negative ledger bias.")

plot(ledgerImbalanceSeries, "Ledger Imbalance (Data Window)", color = ledgerImbalanceSeries >= 0 ? buyCore : sellCore, display = display.data_window)
plot(dashboardBuyShare, "Buy Share (Data Window)", color = buyCore, display = display.data_window)
plot(dashboardSellShare, "Sell Share (Data Window)", color = sellCore, display = display.data_window)
plot(dashboardPocPrice, "POC Price (Data Window)", color = neutralLine, display = display.data_window)
plot(nz(dashboardConcentration, concentrationSeries) * 100.0, "Top Shelf Concentration % (Data Window)", color = neutralLine, display = display.data_window)
plot(referenceDistanceAtrSeries, "Reference Distance ATR (Data Window)", color = referenceDistanceAtrSeries >= 0 ? buyCore : sellCore, display = display.data_window)
plot(referenceRangeShareSeries, "Reference Range Share % (Data Window)", color = referenceRangeShareSeries >= 50 ? sellCore : buyCore, display = display.data_window)
````
