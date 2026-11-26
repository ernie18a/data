# Big Trades Indicator By Revan Blezinsky

- url: https://www.tradingview.com/script/MyLlMsry-Big-Trades-Indicator-By-Revan-Blezinsky/
- type: indicator
- pine_id: PUB;f156e47aaa904f0c906f1b90b510757e
- version: 1.0

## Description

Big Trades Indicator v2 is a custom volume-based indicator designed to help traders identify unusual trading activity, large volume spikes, directional pressure, and potential liquidity clusters directly on the price chart.

The indicator compares current volume against the average volume and marks significant volume events with visual bubbles. The bigger the volume anomaly, the larger and more visible the bubble becomes.

Green bubbles represent estimated buy-side pressure, while red bubbles represent estimated sell-side pressure. Direction is estimated using candle behavior such as Close vs Open, Close vs Midpoint, or Close vs Previous Close.

This script also includes a momentum marker system. When multiple big trades appear in the same direction, the indicator displays a momentum marker to show repeated buying or selling pressure.

Another key feature is Liquidity Cluster Detection. When several large volume events happen within a narrow price range, the indicator highlights the area as a possible liquidity zone. These zones may act as potential support, resistance, accumulation, distribution, or breakout confirmation areas.

Key Features:
- Volume spike detection
- Extreme volume detection
- Buy and sell pressure estimation
- Optional ATR-based dynamic threshold
- Momentum marker for repeated directional pressure
- Liquidity cluster detection
- Smooth bubble opacity scaling
- Real-time information table
- Object management to reduce chart clutter

How to Read:
- Green bubble = estimated buy pressure
- Red bubble = estimated sell pressure
- Bigger bubble = stronger volume anomaly
- Cluster zone = multiple big trades around the same price area
- BUY MOM / SELL MOM = repeated big trades in the same direction

Recommended Usage:
This indicator is best used as a confirmation tool together with support and resistance, market structure, breakout analysis, price action, volume profile, and risk management.

Example:
A large green bubble near support may suggest aggressive buying or accumulation.
A large red bubble near resistance may suggest selling pressure or distribution.
A cluster near a breakout area may suggest strong market participation.

Important:
This indicator does not provide guaranteed buy or sell signals. Buy and sell pressure are estimated from candle behavior and volume, not from real order flow or exchange-level bid/ask data.

Large volume can indicate either continuation or exhaustion depending on market context. Always combine this indicator with proper analysis and risk management.

Suggested Settings for Stocks:
Volume MA Length: 20
Spike Threshold: 2.0
Extreme Threshold: 4.0
Dynamic Threshold: Off
Cluster Lookback: 30
Cluster Price Range: 0.3% - 0.5%

Suggested Settings for Crypto, Gold, or High Volatility Markets:
Volume MA Length: 20
Spike Threshold: 2.5
Extreme Threshold: 5.0
Dynamic Threshold: On
Cluster Lookback: 30 - 50
Cluster Price Range: 0.5% - 1.0%

Disclaimer:
This script is for educational and analytical purposes only. It is not financial advice. Always do your own research and use proper risk management before making any trading decision.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════
// BIG TRADES INDICATOR [Custom] — v2 FIXED
// ───────────────────────────────────────────────────────────────────
// Fixes:
//   ✦ Label & box memory management
//   ✦ Safer momentum logic
//   ✦ Doji-safe direction detection
//   ✦ Safer cluster padding
//   ✦ Cleaner cluster lifecycle
//   ✦ Better input naming
// ═══════════════════════════════════════════════════════════════════

indicator("Big Trades Indicator [Custom] v2 Fixed", shorttitle="BigTrades v2 Fix",
     overlay=true, max_labels_count=500, max_boxes_count=50)

// ═══════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════

grpDetect  = "Detection"
grpDir     = "Direction"
grpMom     = "Momentum"
grpCluster = "Cluster Detection"
grpVis     = "Visual"
grpManage  = "Object Management"

// --- Detection ---
volLen           = input.int(20, "Volume MA Length", minval=5, group=grpDetect)
spikeThreshold   = input.float(2.0, "Spike Threshold (×avg)", minval=1.1, step=0.1, group=grpDetect)
extremeThreshold = input.float(4.0, "Extreme Threshold (×avg)", minval=2.0, step=0.5, group=grpDetect)

useATRThreshold = input.bool(false, "Dynamic Threshold (ATR-scaled)", group=grpDetect,
     tooltip="Otomatis adjust threshold berdasarkan volatility:\n• Volatile period → threshold lebih tinggi\n• Calm period → threshold lebih rendah")
atrLen = input.int(14, "ATR Length (Dynamic)", minval=5, group=grpDetect)

// --- Direction ---
dirMethod = input.string("Close vs Open", "Direction Method",
     options=["Close vs Open", "Close vs Midpoint", "Close vs Previous Close"], group=grpDir)

// --- Momentum ---
momentumMode = input.string("Big Trade Sequence", "Momentum Mode",
     options=["Big Trade Sequence", "Strict Consecutive Bars"], group=grpMom,
     tooltip="Big Trade Sequence: urutan antar big trade.\nStrict Consecutive Bars: harus candle berurutan tanpa putus.")

momentumLen  = input.int(3, "Momentum Sequence Length", minval=2, maxval=10, group=grpMom)
showMomentum = input.bool(true, "Show Momentum Marker", group=grpMom)

// --- Cluster ---
enableCluster     = input.bool(true, "Enable Cluster Detection", group=grpCluster)
clusterLookback   = input.int(30, "Cluster Lookback (bars)", minval=10, group=grpCluster,
     tooltip="Berapa bar ke belakang dicek buat cari cluster")
clusterMinBubbles = input.int(3, "Min Bubbles for Cluster", minval=2, group=grpCluster,
     tooltip="Minimum bubble dalam range buat dianggap cluster")
clusterRangePct   = input.float(0.3, "Cluster Price Range (%)", minval=0.05, step=0.05, group=grpCluster,
     tooltip="Range harga (% current price) buat group bubble jadi cluster")
clusterColor      = input.color(color.new(#F2A623, 85), "Cluster Zone Color", group=grpCluster)

// --- Visual ---
buyColor           = input.color(color.new(#1A9E5C, 30), "Buy Bubble Base", group=grpVis)
sellColor          = input.color(color.new(#D94545, 30), "Sell Bubble Base", group=grpVis)
continuousOpacity  = input.bool(true, "Continuous Opacity Scaling", group=grpVis,
     tooltip="Opacity bubble di-scale linear ke magnitude")
showVolumeText     = input.bool(false, "Show Volume Number Inside Bubble", group=grpVis)
showTable          = input.bool(true, "Show Info Table", group=grpVis)

// --- Object Management ---
maxKeepBubbleLabels  = input.int(300, "Max Bubble Labels to Keep", minval=50, maxval=500, group=grpManage)
maxKeepSignalLabels  = input.int(100, "Max Signal Labels to Keep", minval=20, maxval=300, group=grpManage)
maxKeepClusterBoxes  = input.int(30, "Max Cluster Boxes to Keep", minval=5, maxval=50, group=grpManage)
maxTrackedBubbles    = input.int(100, "Max Tracked Bubbles", minval=30, maxval=300, group=grpManage)

// ═══════════════════════════════════════════════════════════════════
// CALCULATIONS — Volume & Threshold
// ═══════════════════════════════════════════════════════════════════

avgVol   = ta.sma(volume, volLen)
volRatio = avgVol > 0 ? volume / avgVol : 0.0

atrValue  = ta.atr(atrLen)
atrPct    = close > 0 ? atrValue / close * 100 : 0.0
avgAtrPct = ta.sma(atrPct, 50)

rawVolFactor     = avgAtrPct > 0 ? atrPct / avgAtrPct : 1.0
volatilityFactor = math.max(0.5, math.min(2.0, rawVolFactor))

effSpikeThresh   = useATRThreshold ? spikeThreshold * volatilityFactor   : spikeThreshold
effExtremeThresh = useATRThreshold ? extremeThreshold * volatilityFactor : extremeThreshold

// ═══════════════════════════════════════════════════════════════════
// DIRECTION ESTIMATION — DOJI SAFE
// ═══════════════════════════════════════════════════════════════════

isBuy = switch dirMethod
    "Close vs Open" =>
        close > open ? true : close < open ? false : close >= close[1]

    "Close vs Midpoint" =>
        close > (high + low) / 2 ? true : close < (high + low) / 2 ? false : close >= close[1]

    "Close vs Previous Close" =>
        close > close[1] ? true : close < close[1] ? false : close >= open

    =>
        close > open ? true : close < open ? false : close >= close[1]

// Spike detection
isBigTrade = volRatio >= effSpikeThresh and not na(avgVol)
isExtreme  = volRatio >= effExtremeThresh and not na(avgVol)

// ═══════════════════════════════════════════════════════════════════
// BUBBLE SIZE & OPACITY
// ═══════════════════════════════════════════════════════════════════

bubbleSize = volRatio >= effExtremeThresh        ? size.huge   :
             volRatio >= effSpikeThresh * 2.0    ? size.large  :
             volRatio >= effSpikeThresh * 1.5    ? size.normal :
                                                   size.small

rawRatio      = effExtremeThresh > 0 ? math.min(volRatio / effExtremeThresh, 1.5) : 0.0
scaledOpacity = int(math.max(15, 70 - rawRatio * 50))

dynBuyColor  = color.new(color.rgb(26, 158, 92), scaledOpacity)
dynSellColor = color.new(color.rgb(217, 69, 69), scaledOpacity)

finalBubbleColor = isBuy
     ? (continuousOpacity ? dynBuyColor  : buyColor)
     : (continuousOpacity ? dynSellColor : sellColor)

// ═══════════════════════════════════════════════════════════════════
// OBJECT ARRAYS
// ═══════════════════════════════════════════════════════════════════

var array<label> bubbleLabels  = array.new<label>()
var array<label> signalLabels  = array.new<label>()
var array<box>   clusterBoxes  = array.new<box>()
var array<label> clusterLabels = array.new<label>()

// Helper: delete old bubble labels
if array.size(bubbleLabels) > maxKeepBubbleLabels
    oldBubble = array.shift(bubbleLabels)
    label.delete(oldBubble)

// Helper: delete old signal labels
if array.size(signalLabels) > maxKeepSignalLabels
    oldSignal = array.shift(signalLabels)
    label.delete(oldSignal)

// Helper: delete old cluster boxes
if array.size(clusterBoxes) > maxKeepClusterBoxes
    oldBox = array.shift(clusterBoxes)
    box.delete(oldBox)

// Helper: delete old cluster labels
if array.size(clusterLabels) > maxKeepClusterBoxes
    oldClusterLabel = array.shift(clusterLabels)
    label.delete(oldClusterLabel)

// ═══════════════════════════════════════════════════════════════════
// MOMENTUM SEQUENCE TRACKING
// ═══════════════════════════════════════════════════════════════════

var int consecutiveBuy  = 0
var int consecutiveSell = 0

if momentumMode == "Big Trade Sequence"
    if isBigTrade
        if isBuy
            consecutiveBuy  := consecutiveBuy + 1
            consecutiveSell := 0
        else
            consecutiveSell := consecutiveSell + 1
            consecutiveBuy  := 0

else
    if isBigTrade
        if isBuy
            consecutiveBuy  := consecutiveBuy + 1
            consecutiveSell := 0
        else
            consecutiveSell := consecutiveSell + 1
            consecutiveBuy  := 0
    else
        consecutiveBuy  := 0
        consecutiveSell := 0

momentumBuyTrigger  = consecutiveBuy  == momentumLen
momentumSellTrigger = consecutiveSell == momentumLen

// ═══════════════════════════════════════════════════════════════════
// PLOTTING — BIG TRADE BUBBLES
// ═══════════════════════════════════════════════════════════════════

bubbleY    = (open + close) / 2
bubbleText = showVolumeText ? str.tostring(volume, format.volume) : ""

if isBigTrade
    newBubble = label.new(
         x         = bar_index,
         y         = bubbleY,
         text      = bubbleText,
         style     = label.style_circle,
         color     = finalBubbleColor,
         textcolor = color.white,
         size      = bubbleSize,
         yloc      = yloc.price)

    array.push(bubbleLabels, newBubble)

    if array.size(bubbleLabels) > maxKeepBubbleLabels
        oldBubble = array.shift(bubbleLabels)
        label.delete(oldBubble)

// ═══════════════════════════════════════════════════════════════════
// PLOTTING — MOMENTUM MARKERS
// ═══════════════════════════════════════════════════════════════════

if showMomentum and momentumBuyTrigger
    newBuyMom = label.new(
         x         = bar_index,
         y         = low,
         text      = "▲ MOM",
         style     = label.style_label_up,
         color     = color.new(#1A9E5C, 0),
         textcolor = color.white,
         size      = size.small,
         yloc      = yloc.belowbar)

    array.push(signalLabels, newBuyMom)

    if array.size(signalLabels) > maxKeepSignalLabels
        oldSignal = array.shift(signalLabels)
        label.delete(oldSignal)

if showMomentum and momentumSellTrigger
    newSellMom = label.new(
         x         = bar_index,
         y         = high,
         text      = "▼ MOM",
         style     = label.style_label_down,
         color     = color.new(#D94545, 0),
         textcolor = color.white,
         size      = size.small,
         yloc      = yloc.abovebar)

    array.push(signalLabels, newSellMom)

    if array.size(signalLabels) > maxKeepSignalLabels
        oldSignal = array.shift(signalLabels)
        label.delete(oldSignal)

// ═══════════════════════════════════════════════════════════════════
// CLUSTER DETECTION
// ═══════════════════════════════════════════════════════════════════

var array<float> bubblePrices = array.new<float>()
var array<int>   bubbleBars   = array.new<int>()
var int          lastClusterBar = -1000

if isBigTrade
    array.push(bubblePrices, bubbleY)
    array.push(bubbleBars, bar_index)

    // Cleanup old tracked bubbles
    while array.size(bubbleBars) > 0 and array.get(bubbleBars, 0) < bar_index - clusterLookback
        array.shift(bubblePrices)
        array.shift(bubbleBars)

    // Hard cap tracked bubbles
    while array.size(bubblePrices) > maxTrackedBubbles
        array.shift(bubblePrices)
        array.shift(bubbleBars)

    if enableCluster and array.size(bubblePrices) >= clusterMinBubbles
        matchCount      = 0
        minP            = bubbleY
        maxP            = bubbleY
        minB            = bar_index
        clusterRangeAbs = close * clusterRangePct / 100

        for i = 0 to array.size(bubblePrices) - 1
            bPrice = array.get(bubblePrices, i)
            bBar   = array.get(bubbleBars, i)

            if math.abs(bPrice - bubbleY) <= clusterRangeAbs
                matchCount += 1

                if bPrice < minP
                    minP := bPrice

                if bPrice > maxP
                    maxP := bPrice

                if bBar < minB
                    minB := bBar

        cooldownPassed = (bar_index - lastClusterBar) > math.round(clusterLookback / 2)

        if matchCount >= clusterMinBubbles and cooldownPassed
            zonePadding = math.max((maxP - minP) * 0.15, atrValue * 0.05)

            newClusterBox = box.new(
                 left         = minB,
                 top          = maxP + zonePadding,
                 right        = bar_index + 5,
                 bottom       = minP - zonePadding,
                 border_color = color.new(#F2A623, 40),
                 border_width = 1,
                 bgcolor      = clusterColor)

            array.push(clusterBoxes, newClusterBox)

            if array.size(clusterBoxes) > maxKeepClusterBoxes
                oldBox = array.shift(clusterBoxes)
                box.delete(oldBox)

            newClusterLabel = label.new(
                 x         = math.round((minB + bar_index) / 2),
                 y         = maxP + zonePadding,
                 text      = "⬢ CLUSTER " + str.tostring(matchCount) + " trades",
                 style     = label.style_none,
                 textcolor = #F2A623,
                 size      = size.small,
                 yloc      = yloc.price)

            array.push(clusterLabels, newClusterLabel)

            if array.size(clusterLabels) > maxKeepClusterBoxes
                oldClusterLabel = array.shift(clusterLabels)
                label.delete(oldClusterLabel)

            lastClusterBar := bar_index

// ═══════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════

alertcondition(isBigTrade and isBuy,      "Big Buy Trade",  "Big buy volume detected on {{ticker}} @ {{close}}")
alertcondition(isBigTrade and not isBuy,  "Big Sell Trade", "Big sell volume detected on {{ticker}} @ {{close}}")
alertcondition(isExtreme and isBuy,       "Extreme Buy",    "EXTREME buy volume detected on {{ticker}} @ {{close}}")
alertcondition(isExtreme and not isBuy,   "Extreme Sell",   "EXTREME sell volume detected on {{ticker}} @ {{close}}")
alertcondition(momentumBuyTrigger,        "Buy Momentum",   "Buy momentum sequence triggered on {{ticker}}")
alertcondition(momentumSellTrigger,       "Sell Momentum",  "Sell momentum sequence triggered on {{ticker}}")

// ═══════════════════════════════════════════════════════════════════
// INFO TABLE
// ═══════════════════════════════════════════════════════════════════

var table infoTable = table.new(
     position     = position.top_right,
     columns      = 2,
     rows         = 9,
     bgcolor      = color.new(color.black, 70),
     border_color = color.new(color.gray, 50),
     border_width = 1)

if barstate.islast and showTable
    table.cell(infoTable, 0, 0, "Metric", text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 0, "Value",  text_color=color.gray, text_size=size.small)

    table.cell(infoTable, 0, 1, "Vol ratio", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(volRatio, "#.##") + "×",
         text_color = volRatio >= effExtremeThresh ? color.yellow :
                      volRatio >= effSpikeThresh   ? color.aqua   : color.gray,
         text_size = size.small)

    table.cell(infoTable, 0, 2, "Eff spike", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(effSpikeThresh, "#.##") + "×",
         text_color = useATRThreshold ? color.orange : color.gray,
         text_size = size.small)

    table.cell(infoTable, 0, 3, "Eff extreme", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(effExtremeThresh, "#.##") + "×",
         text_color = useATRThreshold ? color.orange : color.gray,
         text_size = size.small)

    table.cell(infoTable, 0, 4, "Vol factor", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 4, str.tostring(volatilityFactor, "#.##"),
         text_color = volatilityFactor > 1.2 ? color.orange :
                      volatilityFactor < 0.8 ? color.aqua   : color.gray,
         text_size = size.small)

    table.cell(infoTable, 0, 5, "Direction", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 5, isBuy ? "BUY" : "SELL",
         text_color = isBuy ? color.lime : color.red,
         text_size = size.small)

    table.cell(infoTable, 0, 6, "Buy streak", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 6, str.tostring(consecutiveBuy),
         text_color = consecutiveBuy >= momentumLen ? color.lime : color.gray,
         text_size = size.small)

    table.cell(infoTable, 0, 7, "Sell streak", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 7, str.tostring(consecutiveSell),
         text_color = consecutiveSell >= momentumLen ? color.red : color.gray,
         text_size = size.small)

    table.cell(infoTable, 0, 8, "Tracked bubbles", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 8, str.tostring(array.size(bubblePrices)),
         text_color = color.gray,
         text_size = size.small)
````
