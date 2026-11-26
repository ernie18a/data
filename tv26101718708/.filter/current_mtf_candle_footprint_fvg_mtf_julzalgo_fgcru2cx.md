# Current MTF Candle Footprint + FVG MTF| julzALGO

- url: https://www.tradingview.com/script/Fgcru2Cx-Current-MTF-Candle-Footprint-FVG-MTF-julzALGO/
- type: indicator
- pine_id: PUB;6e68cdff8e144fb69981756f0ab928f9
- version: 1.0

## Description

📘 Summary

Current MTF Candle Footprint + FVG MTF is a multi-timeframe market structure and footprint visualization tool designed to display the live development of any higher-timeframe candle directly on lower-timeframe charts.
The indicator reconstructs the current higher-timeframe candle in real time, while simultaneously analyzing lower-timeframe volume participation to build a footprint profile, Point of Control (POC), volume imbalance statistics, and Fair Value Gap (FVG) confirmations.
Unlike traditional MTF candle overlays that only show OHLC levels, this script reveals the internal volume distribution occurring inside the active higher-timeframe candle, helping traders identify where buyers and sellers are actively participating before the candle closes.

📘 Features

✅ Live Multi-Timeframe Candle Overlay
✅ Current Higher-Timeframe Open, High, Low & Close Levels
✅ Real-Time Mini Candle Projection
✅ Lower-Timeframe Footprint Analysis
✅ Buy Volume Calculation
✅ Sell Volume Calculation
✅ Delta Volume Measurement
✅ Volume Imbalance Percentage
✅ Dynamic Footprint Table
✅ Point of Control (POC)
✅ Volume Distribution Nodes
✅ Adjustable Node Resolution
✅ POC Zone Highlighting
✅ Bullish Fair Value Gap Detection
✅ Bearish Fair Value Gap Detection
✅ MTF FVG Confirmation
✅ FVG Volume Imbalance Analysis
✅ Broken FVG Management
✅ Configurable FVG History
✅ Candle Body or Full Range Footprint Modes
✅ Automatic Volume Source Detection
✅ Multi-Timeframe Trading Confirmation Tool

📘 Logic

🔷 Multi-Timeframe Candle Engine

https://www.tradingview.com/x/no5jjf4G/

The indicator continuously reconstructs the currently active higher-timeframe candle using its Open, High, Low, and Close values.

This allows traders on lower-timeframe charts to monitor the live development of larger timeframe candles before they officially close.

Examples:

• Daily Candle on a 1-Minute Chart

• 4-Hour Candle on a 5-Minute Chart

• Weekly Candle on a 15-Minute Chart

🔷 Footprint Engine

https://www.tradingview.com/x/DZNGmnWZ/

Lower-timeframe volume data is retrieved and classified into buying and selling participation.

Buy Volume

• Lower-timeframe bars closing higher contribute volume to buyers.

Sell Volume

• Lower-timeframe bars closing lower contribute volume to sellers.

The accumulated volume is used to build a real-time footprint representation of the active higher-timeframe candle.

🔷 Footprint Nodes

https://www.tradingview.com/x/kNrStb34/

The active higher-timeframe candle is divided into multiple price levels.

Available resolutions:

• 4 Nodes

• 6 Nodes

• 8 Nodes

• 10 Nodes

• 12 Nodes

• 16 Nodes

• 20 Nodes

• 24 Nodes

• 31 Nodes

Each node displays:

• Buy Volume

• Sell Volume

• Delta Dominance

This creates a footprint-style volume ladder beside the higher-timeframe candle.

🔷 Delta Volume

https://www.tradingview.com/x/APD2CA7l/

Delta Volume measures the difference between accumulated Buy Volume and Sell Volume.

Formula:

Delta = Buy Volume − Sell Volume

Positive Delta

• Buyers dominate volume participation.

Negative Delta

• Sellers dominate volume participation.

🔷 Volume Imbalance

Volume Imbalance measures the strength of participation by comparing Delta against Total Volume.

Formula:

Imbalance % = |Buy Volume − Sell Volume| ÷ Total Volume × 100

Higher imbalance values indicate stronger directional conviction from either buyers or sellers.


🔷 Point of Control (POC)

https://www.tradingview.com/x/Qwe8Oc3y/

The Point of Control represents the highest-volume price level within the active higher-timeframe candle.

The POC may act as:

• Highest traded price area

• Volume acceptance zone

• Potential support area

• Potential resistance area

Display options include:

• Footprint Highlight

• Extended POC Box


🔷 Fair Value Gap Confirmation

https://www.tradingview.com/x/0cnWm3hG/

The indicator scans a user-selected timeframe for Fair Value Gaps (FVGs).

Bullish FVG

Low[1] > High[3]

Bearish FVG

High[1] < Low[3]

Detected FVGs are projected directly onto the chart and continuously monitored while active.


🔷 FVG Volume Confirmation

For every detected FVG, the indicator evaluates:

• Buy Volume

• Sell Volume

• Delta Volume

• Imbalance %

This helps evaluate whether the liquidity imbalance responsible for creating the gap was primarily driven by buyers or sellers.

🔷 FVG State Tracking

Each Fair Value Gap is continuously monitored and managed.

Tracked states include:

• Active FVGs

• Broken FVGs

• Historical FVGs

Users can:

• Hide broken FVGs

• Display broken FVGs

• Limit the number of stored FVGs


🔷 Volume Source Detection

The indicator automatically determines the quality of the volume source being used.

M1 Source

• Uses actual 1-minute footprint volume data.

Fallback Source

• Uses candle-anatomy volume estimation when lower-timeframe data is unavailable.

The active volume source is displayed directly inside the footprint dashboard.


📘 Usage

🔷 Bullish Setup

Look for:
Bullish Higher-Timeframe Candle
Positive Delta
Strong Buy Imbalance
POC Holding Above Price
Bullish FVG Confirmation
This indicates buyers are controlling the current higher-timeframe candle.

🔷 Bearish Setup

Look for:
Bearish Higher-Timeframe Candle
Negative Delta
Strong Sell Imbalance
POC Acting As Resistance
Bearish FVG Confirmation
This indicates sellers are controlling the current higher-timeframe candle.

🔷 Scalping Workflow

Many traders monitor:
Daily Candle on 1-Minute Chart
4H Candle on 1-Minute Chart
1H Candle on 15-Second Chart
The footprint helps determine:

• Where volume is accumulating

• Whether buyers or sellers are controlling participation

• Whether Fair Value Gap confirmations support directional bias

📘 Settings

🔷 MTF Candle

Candle Timeframe — Select the higher timeframe to reconstruct.
Show TF High / Low — Display current higher-timeframe extremes.
Show TF Open — Display higher-timeframe open.
Show Current TF Close — Display live higher-timeframe close.
Show Mini TF Candle — Draw reconstructed candle on the right side.
Show Price Labels — Show OHLC labels.

🔷 MTF Footprint

Show TF Footprint Table — Display footprint statistics dashboard.
Show TF Footprint Nodes — Display footprint ladder.
Show POC — Highlight Point of Control.
Show POC Box On Bars — Extend POC zone across chart.
Show Volume Source — Display M1 or Fallback source.
POC Box Range — Candle TF or fixed-bar extension.
Node Width Bars — Adjust footprint profile width.
Node Rows — Control profile resolution.
Node Sync — Full candle range or candle body only.
Node Gap Bars — Distance between candle and profile.

🔷 FVG Confirmation

Show FVG — Enable Fair Value Gap detection.
Show FVG In Footprint Table — Show latest FVG status.
FVG Timeframe — Select FVG detection timeframe.
Minimum Gap Ticks — Filter small gaps.
Keep Last FVG — Number of FVGs displayed.
Show Broken FVG — Display invalidated gaps.

🔷 Layout

Candle Right Offset — Horizontal placement of mini candle.
Candle Width — Width of candle body.
Label Offset Bars — Distance of labels.

🔷 Colors

Customize:
Bull Candle
Bear Candle
High
Low
Open
Close
Buy Nodes
Sell Nodes
POC
Bull FVG
Bear FVG
Text

📘 Disclaimer

This indicator is an educational and analytical tool designed to visualize multi-timeframe candle development, footprint volume participation, Point of Control zones, and Fair Value Gap confirmations. It does not provide financial advice, trading recommendations, or guaranteed future results. Traders should combine this tool with proper risk management, market context, and independent analysis before making trading decisions.
Lower-timeframe volume classification and footprint calculations are analytical estimates and should be interpreted within overall market context.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © julzALGO

//@version=6
indicator("Current MTF Candle Footprint + FVG MTF| julzALGO", overlay=true, max_lines_count=50, max_labels_count=100, max_boxes_count=120, max_bars_back=5000)

// -----------------------------------------------------------------------------
// INPUTS
// -----------------------------------------------------------------------------
groupDaily = "MTF Candle"
candleTimeframe = input.timeframe("D", "Candle Timeframe", group=groupDaily)
showHighLow = input.bool(true, "Show TF High / Low", group=groupDaily)
showOpen = input.bool(true, "Show TF Open", group=groupDaily)
showClose = input.bool(true, "Show Current TF Close", group=groupDaily)
showCandle = input.bool(true, "Show Mini TF Candle", group=groupDaily)
showLabels = input.bool(false, "Show Price Labels", group=groupDaily)

groupFootprint = "MTF Footprint"
showFootprintText = input.bool(true, "Show TF Footprint Table", group=groupFootprint)
showFootprintNodes = input.bool(true, "Show TF Footprint Nodes", group=groupFootprint)
showPOC = input.bool(true, "Show POC", group=groupFootprint)
showPOCBox = input.bool(true, "Show POC Box On Bars", group=groupFootprint)
showSourceText = input.bool(true, "Show Volume Source", group=groupFootprint)
pocBoxRangeMode = input.string("Candle TF", "POC Box Range", options=["Candle TF", "Fixed Bars"], group=groupFootprint)
pocBoxBars = input.int(300, "POC Box Bars", minval=1, maxval=5000, group=groupFootprint)
nodeWidthBars = input.int(14, "Node Width Bars", minval=2, maxval=60, group=groupFootprint)
nodeRowsChoice = input.string("31", "Node Rows", options=["4", "6", "8", "10", "12", "16", "20", "24", "31"], group=groupFootprint)
nodeRangeMode = input.string("Live Candle (High/Low)", "Node Sync", options=["Live Candle (High/Low)", "Body (Open/Close)"], group=groupFootprint)
nodeGapBars = input.int(2, "Node Gap Bars", minval=0, maxval=20, group=groupFootprint)
nodeTextClampTicks = input.int(8, "Node Text Clamp (ticks)", minval=1, group=groupFootprint)

groupFVG = "FVG Confirmation"
showFVG = input.bool(true, "Show FVG", group=groupFVG)
showFVGInLabel = input.bool(true, "Show FVG In Footprint Table", group=groupFVG)
fvgTimeframe = input.timeframe("5", "FVG Timeframe", group=groupFVG)
fvgMinTicks = input.int(0, "Min Gap Ticks", minval=0, maxval=500, group=groupFVG)
fvgKeepLast = input.int(10, "Keep Last FVG", minval=1, maxval=20, group=groupFVG)
showBrokenFVG = input.bool(false, "Show Broken FVG", group=groupFVG)

groupLayout = "Layout"
rightOffset = input.int(10, "Candle Right Offset", minval=1, group=groupLayout)
candleWidth = input.int(4, "Candle Width", minval=1, maxval=30, group=groupLayout)
labelOffset = input.int(2, "Label Offset Bars", minval=0, maxval=30, group=groupLayout)

groupColors = "Colors"
bullColor = input.color(color.lime, "Bullish Candle", group=groupColors)
bearColor = input.color(color.red, "Bearish Candle", group=groupColors)
highColor = input.color(color.orange, "TF High", group=groupColors)
lowColor = input.color(color.aqua, "TF Low", group=groupColors)
openColor = input.color(color.yellow, "TF Open", group=groupColors)
closeColor = input.color(color.white, "TF Close", group=groupColors)
buyNodeColor = input.color(color.rgb(0, 176, 230), "Buy Node", group=groupColors)
sellNodeColor = input.color(color.rgb(137, 82, 255), "Sell Node", group=groupColors)
pocColor = input.color(color.orange, "POC", group=groupColors)
bullFvgColor = input.color(color.rgb(0, 176, 230), "Bull FVG", group=groupColors)
bearFvgColor = input.color(color.rgb(137, 82, 255), "Bear FVG", group=groupColors)
textColor = input.color(color.white, "Text", group=groupColors)

// -----------------------------------------------------------------------------
// HELPERS
// -----------------------------------------------------------------------------
fmtVol(float v) =>
    float av = math.abs(v)
    av >= 1e9 ? str.tostring(av / 1e9, "#.##") + "B" :
     av >= 1e6 ? str.tostring(av / 1e6, "#.##") + "M" :
     av >= 1e3 ? str.tostring(av / 1e3, "#.0") + "K" :
     str.tostring(av, "#.##")

fmtSignedVol(float v) =>
    (v >= 0 ? "+" : "-") + fmtVol(v)

fallbackSplit(float _o, float _h, float _l, float _c, float _v) =>
    float rangeSafe = math.max(_h - _l, syminfo.mintick)
    float closePos = (_c - _l) / rangeSafe
    float body = _c - _o
    float upperWick = _h - math.max(_o, _c)
    float lowerWick = math.min(_o, _c) - _l
    float candleTotal = math.max(math.abs(body) + upperWick + lowerWick, syminfo.mintick)

    float buyStrength =
         closePos * 0.55 +
         (lowerWick / candleTotal) * 0.25 +
         (body > 0 ? math.abs(body) / rangeSafe * 0.20 : 0.0)

    float sellStrength =
         (1.0 - closePos) * 0.55 +
         (upperWick / candleTotal) * 0.25 +
         (body < 0 ? math.abs(body) / rangeSafe * 0.20 : 0.0)

    float totalStrength = buyStrength + sellStrength
    float buyV = totalStrength > 0 ? _v * (buyStrength / totalStrength) : _v * 0.5
    float sellV = totalStrength > 0 ? _v * (sellStrength / totalStrength) : _v * 0.5

    [buyV, sellV]

clearBoxes(box[] arr) =>
    int count = array.size(arr)
    if count > 0
        for j = 0 to count - 1
            int i = count - 1 - j
            box.delete(array.get(arr, i))
            array.remove(arr, i)

getNodeRows(string rowChoice) =>
    rowChoice == "4" ? 4 :
     rowChoice == "6" ? 6 :
     rowChoice == "8" ? 8 :
     rowChoice == "10" ? 10 :
     rowChoice == "12" ? 12 :
     rowChoice == "16" ? 16 :
     rowChoice == "20" ? 20 :
     rowChoice == "24" ? 24 :
     31

// -----------------------------------------------------------------------------
// M1 FOOTPRINT PROXY
// -----------------------------------------------------------------------------
float intrabarDir = math.sign(close - open)
[volData, dirData, closeData, prevCloseData, highData, lowData] = request.security_lower_tf(syminfo.tickerid, "1", [volume, intrabarDir, close, close[1], high, low], ignore_invalid_timeframe=true)

float barBuyVol = 0.0
float barSellVol = 0.0
int m1RowsA = math.min(array.size(volData), array.size(dirData))
int m1RowsB = math.min(array.size(closeData), array.size(prevCloseData))
int m1RowsC = math.min(array.size(highData), array.size(lowData))
int m1Rows = math.min(m1RowsA, math.min(m1RowsB, m1RowsC))

if m1Rows > 0
    for i = 0 to m1Rows - 1
        float rowVol = nz(array.get(volData, i), 0.0)
        float rowDirRaw = array.get(dirData, i)
        float rowClose = array.get(closeData, i)
        float rowPrevClose = array.get(prevCloseData, i)

        int rowDir =
             rowDirRaw > 0 ? 1 :
             rowDirRaw < 0 ? -1 :
             rowClose > rowPrevClose ? 1 :
             rowClose < rowPrevClose ? -1 :
             0

        if rowDir > 0
            barBuyVol += rowVol
        else if rowDir < 0
            barSellVol += rowVol
        else
            barBuyVol += rowVol * 0.5
            barSellVol += rowVol * 0.5
else
    [fallbackBuy, fallbackSell] = fallbackSplit(open, high, low, close, volume)
    barBuyVol := fallbackBuy
    barSellVol := fallbackSell

// -----------------------------------------------------------------------------
// CURRENT MTF CANDLE AND FOOTPRINT
// -----------------------------------------------------------------------------
string candleTfText = candleTimeframe == "" ? timeframe.period : candleTimeframe
bool newDay = timeframe.change(candleTimeframe) or na(close[1])

var float dOpen = na
var float dHigh = na
var float dLow = na
var float dBuyVol = 0.0
var float dSellVol = 0.0
var int dM1Rows = 0
var int dStartBar = na
var float[] dayNodeBuyVol = array.new_float()
var float[] dayNodeSellVol = array.new_float()
var float[] dayNodeHigh = array.new_float()
var float[] dayNodeLow = array.new_float()

if newDay or na(dOpen)
    dOpen := open
    dHigh := high
    dLow := low
    dBuyVol := 0.0
    dSellVol := 0.0
    dM1Rows := 0
    dStartBar := bar_index
    array.clear(dayNodeBuyVol)
    array.clear(dayNodeSellVol)
    array.clear(dayNodeHigh)
    array.clear(dayNodeLow)
else
    dHigh := math.max(nz(dHigh, high), high)
    dLow := math.min(nz(dLow, low), low)

dBuyVol += barBuyVol
dSellVol += barSellVol
dM1Rows += m1Rows

if m1Rows > 0
    for i = 0 to m1Rows - 1
        float rowVol = nz(array.get(volData, i), 0.0)
        float rowDirRaw = array.get(dirData, i)
        float rowClose = array.get(closeData, i)
        float rowPrevClose = array.get(prevCloseData, i)

        int rowDir =
             rowDirRaw > 0 ? 1 :
             rowDirRaw < 0 ? -1 :
             rowClose > rowPrevClose ? 1 :
             rowClose < rowPrevClose ? -1 :
             0

        float rowBuy = rowDir > 0 ? rowVol : rowDir < 0 ? 0.0 : rowVol * 0.5
        float rowSell = rowDir < 0 ? rowVol : rowDir > 0 ? 0.0 : rowVol * 0.5

        array.push(dayNodeBuyVol, rowBuy)
        array.push(dayNodeSellVol, rowSell)
        array.push(dayNodeHigh, nz(array.get(highData, i), high))
        array.push(dayNodeLow, nz(array.get(lowData, i), low))
else
    array.push(dayNodeBuyVol, barBuyVol)
    array.push(dayNodeSellVol, barSellVol)
    array.push(dayNodeHigh, high)
    array.push(dayNodeLow, low)

float dClose = close
bool isBull = dClose >= dOpen
color candleColor = isBull ? bullColor : bearColor

float dTotalVol = dBuyVol + dSellVol
float dDelta = dBuyVol - dSellVol
float dImbalance = dTotalVol > 0 ? math.abs(dDelta) / dTotalVol * 100.0 : 0.0
string volumeSource = dM1Rows > 0 ? "M1" : "Fallback"

// -----------------------------------------------------------------------------
// FVG CONFIRMATION
// -----------------------------------------------------------------------------
type FVGState
    box body
    float buyVol
    float sellVol
    bool bull

var fvgs = array.new<FVGState>()
var string lastFVGText = "WAIT"
string fvgTfText = fvgTimeframe == "" ? timeframe.period : fvgTimeframe

[fvgTime, fvgLeftTime, fvgBullTop, fvgBullBot, fvgBearTop, fvgBearBot, fvgBullGapSize, fvgBearGapSize] = request.security(syminfo.tickerid, fvgTimeframe, [time, time[3], low[1], high[3], low[3], high[1], low[1] - high[3], low[3] - high[1]], lookahead=barmerge.lookahead_off)

int fvgTfTimeChange = ta.change(fvgTime)
bool newFvgTfBar = not na(fvgTime) and fvgTfTimeChange != 0

var float activeFvgBuyVol = 0.0
var float activeFvgSellVol = 0.0
var float completedFvgBuyVol1 = na
var float completedFvgBuyVol2 = na
var float completedFvgBuyVol3 = na
var float completedFvgSellVol1 = na
var float completedFvgSellVol2 = na
var float completedFvgSellVol3 = na

if newFvgTfBar
    completedFvgBuyVol3 := completedFvgBuyVol2
    completedFvgBuyVol2 := completedFvgBuyVol1
    completedFvgBuyVol1 := activeFvgBuyVol
    completedFvgSellVol3 := completedFvgSellVol2
    completedFvgSellVol2 := completedFvgSellVol1
    completedFvgSellVol1 := activeFvgSellVol
    activeFvgBuyVol := 0.0
    activeFvgSellVol := 0.0

float fvgBuffer = syminfo.mintick * fvgMinTicks
bool hasFvgVolume =
     not na(completedFvgBuyVol1) and
     not na(completedFvgBuyVol2) and
     not na(completedFvgBuyVol3) and
     not na(completedFvgSellVol1) and
     not na(completedFvgSellVol2) and
     not na(completedFvgSellVol3)
bool bullFVG = showFVG and newFvgTfBar and not na(fvgLeftTime) and fvgBullGapSize >= fvgBuffer
bool bearFVG = showFVG and newFvgTfBar and not na(fvgLeftTime) and fvgBearGapSize >= fvgBuffer

float fvgBuyVol =
     hasFvgVolume ?
     nz(completedFvgBuyVol1, 0.0) +
     nz(completedFvgBuyVol2, 0.0) +
     nz(completedFvgBuyVol3, 0.0) :
     nz(barBuyVol, 0.0) +
     nz(barBuyVol[1], 0.0) +
     nz(barBuyVol[2], 0.0)

float fvgSellVol =
     hasFvgVolume ?
     nz(completedFvgSellVol1, 0.0) +
     nz(completedFvgSellVol2, 0.0) +
     nz(completedFvgSellVol3, 0.0) :
     nz(barSellVol, 0.0) +
     nz(barSellVol[1], 0.0) +
     nz(barSellVol[2], 0.0)

if bullFVG
    box fvgBox = box.new(
         fvgLeftTime,
         fvgBullTop,
         time,
         fvgBullBot,
         xloc=xloc.bar_time,
         bgcolor=color.new(bullFvgColor, 90),
         border_color=color.new(bullFvgColor, 35),
         border_style=line.style_dashed,
         border_width=1
    )

    array.push(fvgs, FVGState.new(fvgBox, fvgBuyVol, fvgSellVol, true))

    float totalFVGVol = fvgBuyVol + fvgSellVol
    float fvgImbalance = totalFVGVol > 0 ? math.abs(fvgBuyVol - fvgSellVol) / totalFVGVol * 100.0 : 0.0
    lastFVGText := "Bull FVG " + str.tostring(fvgImbalance, "#.0") + "%"

if bearFVG
    box fvgBox = box.new(
         fvgLeftTime,
         fvgBearTop,
         time,
         fvgBearBot,
         xloc=xloc.bar_time,
         bgcolor=color.new(bearFvgColor, 90),
         border_color=color.new(bearFvgColor, 35),
         border_style=line.style_dashed,
         border_width=1
    )

    array.push(fvgs, FVGState.new(fvgBox, fvgBuyVol, fvgSellVol, false))

    float totalFVGVol = fvgBuyVol + fvgSellVol
    float fvgImbalance = totalFVGVol > 0 ? math.abs(fvgBuyVol - fvgSellVol) / totalFVGVol * 100.0 : 0.0
    lastFVGText := "Bear FVG " + str.tostring(fvgImbalance, "#.0") + "%"

if array.size(fvgs) > 0
    for i = array.size(fvgs) - 1 to 0
        FVGState fvg = array.get(fvgs, i)

        box.set_right(fvg.body, time)

        float fvgTop = box.get_top(fvg.body)
        float fvgBot = box.get_bottom(fvg.body)
        float totalFVGVol = fvg.buyVol + fvg.sellVol
        float fvgImbalance = totalFVGVol > 0 ? math.abs(fvg.buyVol - fvg.sellVol) / totalFVGVol * 100.0 : 0.0
        color fvgColor = fvg.bull ? bullFvgColor : bearFvgColor

        box.set_text(fvg.body, (fvg.bull ? "Bull FVG" : "Bear FVG") + " " + fvgTfText + " | " + str.tostring(fvgImbalance, "#.0") + "%")
        box.set_text_color(fvg.body, textColor)
        box.set_text_size(fvg.body, size.tiny)
        box.set_text_halign(fvg.body, text.align_right)
        box.set_text_valign(fvg.body, text.align_center)
        box.set_bgcolor(fvg.body, color.new(fvgColor, 90))
        box.set_border_color(fvg.body, color.new(fvgColor, 35))
        box.set_border_style(fvg.body, line.style_dashed)

        bool brokenFVG = fvg.bull ? low <= fvgBot : high >= fvgTop

        if brokenFVG and not showBrokenFVG
            box.delete(fvg.body)
            array.remove(fvgs, i)

while array.size(fvgs) > fvgKeepLast
    FVGState oldFVG = array.shift(fvgs)
    box.delete(oldFVG.body)

activeFvgBuyVol += barBuyVol
activeFvgSellVol += barSellVol

// -----------------------------------------------------------------------------
// MTF LEVEL PLOTS
// -----------------------------------------------------------------------------
plot(showHighLow ? dHigh : na, "Current TF High", color=highColor, linewidth=2)
plot(showHighLow ? dLow : na, "Current TF Low", color=lowColor, linewidth=2)
plot(showOpen ? dOpen : na, "Current TF Open", color=openColor, linewidth=2)
plot(showClose ? dClose : na, "Current TF Close", color=closeColor, linewidth=1)

// -----------------------------------------------------------------------------
// RIGHT-SIDE MTF CANDLE + FOOTPRINT
// -----------------------------------------------------------------------------
var box bodyBox = na
var line upperWickLine = na
var line lowerWickLine = na
var label highLbl = na
var label lowLbl = na
var label openLbl = na
var label closeLbl = na
var box pocBarBox = na
var table fpTable = table.new(position.top_right, 2, 7, frame_color=color.new(chart.fg_color, 70), frame_width=1, border_width=1)
var box[] nodeBoxes = array.new<box>()

calcTfPocZone(float topY, float botY, float[] buySamples, float[] sellSamples, float[] highSamples, float[] lowSamples) =>
    int rows = getNodeRows(nodeRowsChoice)
    float zTop = math.max(topY, botY)
    float zBot = math.min(topY, botY)
    float minNodeHeight = syminfo.mintick * math.max(rows, nodeTextClampTicks)

    if zTop - zBot < minNodeHeight
        float mid = math.avg(topY, botY)
        zTop := mid + minNodeHeight * 0.5
        zBot := mid - minNodeHeight * 0.5

    float zHeight = math.max(zTop - zBot, syminfo.mintick)
    float rowHeight = zHeight / rows
    float[] totalBins = array.new_float(rows, 0.0)

    int sampleCount = math.min(array.size(buySamples), math.min(array.size(sellSamples), math.min(array.size(highSamples), array.size(lowSamples))))

    if sampleCount > 0
        for s = 0 to sampleCount - 1
            float sampleBuy = nz(array.get(buySamples, s), 0.0)
            float sampleSell = nz(array.get(sellSamples, s), 0.0)
            float sampleTopRaw = math.max(nz(array.get(highSamples, s), zTop), nz(array.get(lowSamples, s), zBot))
            float sampleBotRaw = math.min(nz(array.get(highSamples, s), zTop), nz(array.get(lowSamples, s), zBot))

            bool overlaps = sampleTopRaw >= zBot and sampleBotRaw <= zTop

            if overlaps
                float sampleTop = math.min(sampleTopRaw, zTop)
                float sampleBot = math.max(sampleBotRaw, zBot)
                int topIndex = int(math.floor((zTop - sampleTop) / rowHeight))
                int botIndex = int(math.floor((zTop - sampleBot) / rowHeight))

                topIndex := math.max(0, math.min(rows - 1, topIndex))
                botIndex := math.max(0, math.min(rows - 1, botIndex))

                int firstIndex = math.min(topIndex, botIndex)
                int lastIndex = math.max(topIndex, botIndex)
                int span = math.max(1, lastIndex - firstIndex + 1)
                float totalPart = (sampleBuy + sampleSell) / span

                for row = firstIndex to lastIndex
                    array.set(totalBins, row, array.get(totalBins, row) + totalPart)

    float maxRowVol = 0.0
    int pocIndex = 0

    for i = 0 to rows - 1
        float rowTotal = array.get(totalBins, i)
        if rowTotal > maxRowVol
            maxRowVol := rowTotal
            pocIndex := i

    float pocTop = maxRowVol > 0 ? zTop - rowHeight * pocIndex : na
    float pocBot = maxRowVol > 0 ? (pocIndex == rows - 1 ? zBot : zTop - rowHeight * (pocIndex + 1)) : na

    [pocTop, pocBot, maxRowVol]

drawTfNodes(int xLeft, int xRight, float topY, float botY, float[] buySamples, float[] sellSamples, float[] highSamples, float[] lowSamples) =>
    int rows = getNodeRows(nodeRowsChoice)
    float zTop = math.max(topY, botY)
    float zBot = math.min(topY, botY)
    float minNodeHeight = syminfo.mintick * math.max(rows, nodeTextClampTicks)

    if zTop - zBot < minNodeHeight
        float mid = math.avg(topY, botY)
        zTop := mid + minNodeHeight * 0.5
        zBot := mid - minNodeHeight * 0.5

    float zHeight = math.max(zTop - zBot, syminfo.mintick)
    float rowHeight = zHeight / rows
    float[] buyBins = array.new_float(rows, 0.0)
    float[] sellBins = array.new_float(rows, 0.0)
    float[] totalBins = array.new_float(rows, 0.0)

    int sampleCount = math.min(array.size(buySamples), math.min(array.size(sellSamples), math.min(array.size(highSamples), array.size(lowSamples))))

    if sampleCount > 0
        for s = 0 to sampleCount - 1
            float sampleBuy = nz(array.get(buySamples, s), 0.0)
            float sampleSell = nz(array.get(sellSamples, s), 0.0)
            float sampleTopRaw = math.max(nz(array.get(highSamples, s), zTop), nz(array.get(lowSamples, s), zBot))
            float sampleBotRaw = math.min(nz(array.get(highSamples, s), zTop), nz(array.get(lowSamples, s), zBot))

            bool overlaps = sampleTopRaw >= zBot and sampleBotRaw <= zTop

            if overlaps
                float sampleTop = math.min(sampleTopRaw, zTop)
                float sampleBot = math.max(sampleBotRaw, zBot)
                int topIndex = int(math.floor((zTop - sampleTop) / rowHeight))
                int botIndex = int(math.floor((zTop - sampleBot) / rowHeight))

                topIndex := math.max(0, math.min(rows - 1, topIndex))
                botIndex := math.max(0, math.min(rows - 1, botIndex))

                int firstIndex = math.min(topIndex, botIndex)
                int lastIndex = math.max(topIndex, botIndex)
                int span = math.max(1, lastIndex - firstIndex + 1)
                float buyPart = sampleBuy / span
                float sellPart = sampleSell / span

                for row = firstIndex to lastIndex
                    array.set(buyBins, row, array.get(buyBins, row) + buyPart)
                    array.set(sellBins, row, array.get(sellBins, row) + sellPart)
                    array.set(totalBins, row, array.get(totalBins, row) + buyPart + sellPart)

    float maxRowVol = 0.0
    int pocIndex = 0

    for i = 0 to rows - 1
        float rowTotal = array.get(totalBins, i)
        if rowTotal > maxRowVol
            maxRowVol := rowTotal
            pocIndex := i

    int xSpan = math.max(1, xRight - xLeft)
    bool canShowText = rowHeight >= syminfo.mintick * nodeTextClampTicks

    color trackBg = color.new(color.black, 90)

    for i = 0 to rows - 1
        float buyRowVol = array.get(buyBins, i)
        float sellRowVol = array.get(sellBins, i)
        float rowVol = array.get(totalBins, i)
        float rowDelta = buyRowVol - sellRowVol
        float yTop = zTop - rowHeight * i
        float yBot = i == rows - 1 ? zBot : zTop - rowHeight * (i + 1)
        int rowWidth = math.max(1, int(math.round(xSpan * (maxRowVol > 0 ? rowVol / maxRowVol : 0.0))))
        int rowLeft = xRight - rowWidth
        rowLeft := math.max(xLeft, math.min(xRight - 1, rowLeft))

        float rowImbalance = rowVol > 0 ? math.abs(rowDelta) / rowVol * 100.0 : 0.0
        int transp = int(math.max(48, math.min(88, 88 - rowImbalance * 0.38)))
        bool isPocRow = showPOC and maxRowVol > 0 and i == pocIndex
        color rowBg = isPocRow ? color.new(pocColor, 18) : color.new(rowDelta >= 0 ? buyNodeColor : sellNodeColor, transp)
        color rowTextColor = isPocRow ? color.black : textColor
        color rowBorderColor = isPocRow ? pocColor : chart.bg_color
        int rowBorderWidth = isPocRow ? 2 : 1
        string sideTxt = rowDelta >= 0 ? "B:" + fmtVol(buyRowVol) : "S:" + fmtVol(sellRowVol)
        string rowTxt = canShowText and rowVol > 0 ? (isPocRow ? "POC " + fmtVol(rowVol) : sideTxt) : ""

        box track = box.new(xLeft, yTop, xRight, yBot, xloc=xloc.bar_index, bgcolor=trackBg, border_color=chart.bg_color, border_width=1)
        box rowBox = box.new(rowLeft, yTop, xRight, yBot, xloc=xloc.bar_index, bgcolor=rowBg, border_color=rowBorderColor, border_width=rowBorderWidth, text=rowTxt, text_color=rowTextColor, text_size=size.auto, text_halign=text.align_left, text_valign=text.align_center)

        array.push(nodeBoxes, track)
        array.push(nodeBoxes, rowBox)

if barstate.islast
    if not na(bodyBox)
        box.delete(bodyBox)
    if not na(upperWickLine)
        line.delete(upperWickLine)
    if not na(lowerWickLine)
        line.delete(lowerWickLine)
    if not na(highLbl)
        label.delete(highLbl)
    if not na(lowLbl)
        label.delete(lowLbl)
    if not na(openLbl)
        label.delete(openLbl)
    if not na(closeLbl)
        label.delete(closeLbl)
    if not na(pocBarBox)
        box.delete(pocBarBox)
        pocBarBox := na

    clearBoxes(nodeBoxes)

    int x1 = bar_index + rightOffset
    int x2 = x1 + candleWidth
    int midX = x1 + int(math.floor(candleWidth * 0.5))
    int labelX = x2 + labelOffset

    float bodyTop = math.max(dOpen, dClose)
    float bodyBot = math.min(dOpen, dClose)
    float nodeTop = nodeRangeMode == "Body (Open/Close)" ? bodyTop : dHigh
    float nodeBot = nodeRangeMode == "Body (Open/Close)" ? bodyBot : dLow
    [pocTop, pocBot, pocVol] = calcTfPocZone(nodeTop, nodeBot, dayNodeBuyVol, dayNodeSellVol, dayNodeHigh, dayNodeLow)

    if showCandle
        if dHigh > bodyTop
            upperWickLine := line.new(
                 midX,
                 dHigh,
                 midX,
                 bodyTop,
                 xloc=xloc.bar_index,
                 color=candleColor,
                 width=2
            )

        if bodyBot > dLow
            lowerWickLine := line.new(
                 midX,
                 bodyBot,
                 midX,
                 dLow,
                 xloc=xloc.bar_index,
                 color=candleColor,
                 width=2
            )

        bodyBox := box.new(
             x1,
             bodyTop,
             x2,
             bodyBot,
             xloc=xloc.bar_index,
             bgcolor=color.new(candleColor, 25),
             border_color=candleColor
        )

    if showFootprintNodes
        int nodeLeft = x2 + nodeGapBars
        int nodeRight = nodeLeft + nodeWidthBars
        drawTfNodes(nodeLeft, nodeRight, nodeTop, nodeBot, dayNodeBuyVol, dayNodeSellVol, dayNodeHigh, dayNodeLow)

    if showPOCBox and showPOC and not na(pocTop) and not na(pocBot) and pocVol > 0
        int tfPocLeft = int(nz(dStartBar, bar_index))
        int fixedPocLeft = int(math.max(0, bar_index - pocBoxBars + 1))
        int pocLeft = pocBoxRangeMode == "Candle TF" ? tfPocLeft : fixedPocLeft
        pocBarBox := box.new(
             pocLeft,
             pocTop,
             bar_index,
             pocBot,
             xloc=xloc.bar_index,
             bgcolor=color.new(pocColor, 84),
             border_color=color.new(pocColor, 0),
             border_width=1,
             text="POC " + fmtVol(pocVol),
             text_color=pocColor,
             text_size=size.tiny,
             text_halign=text.align_right,
             text_valign=text.align_center
        )

    if showLabels
        highLbl := label.new(labelX, dHigh, candleTfText + " High", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=color.white, color=color.new(highColor, 0))
        lowLbl := label.new(labelX, dLow, candleTfText + " Low", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=color.white, color=color.new(lowColor, 0))
        openLbl := label.new(labelX, dOpen, candleTfText + " Open", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=color.black, color=color.new(openColor, 0))
        closeLbl := label.new(labelX, dClose, candleTfText + " Close", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=color.black, color=color.new(closeColor, 0))

    table.clear(fpTable, 0, 0, 1, 6)

    if showFootprintText
        color headerBg = color.new(candleColor, 55)
        color rowBg = color.new(color.black, 78)
        color buyTxtCol = buyNodeColor
        color sellTxtCol = sellNodeColor
        color deltaTxtCol = dDelta >= 0 ? buyNodeColor : sellNodeColor
        color fvgTxtCol = str.contains(lastFVGText, "Bull") ? bullFvgColor : str.contains(lastFVGText, "Bear") ? bearFvgColor : textColor

        table.cell(fpTable, 0, 0, candleTfText + " FP", text_color=textColor, bgcolor=headerBg)
        table.cell(fpTable, 1, 0, isBull ? "BULL" : "BEAR", text_color=textColor, bgcolor=headerBg)
        table.cell(fpTable, 0, 1, "BUY", text_color=buyTxtCol, bgcolor=rowBg)
        table.cell(fpTable, 1, 1, fmtVol(dBuyVol), text_color=buyTxtCol, bgcolor=rowBg)
        table.cell(fpTable, 0, 2, "SELL", text_color=sellTxtCol, bgcolor=rowBg)
        table.cell(fpTable, 1, 2, fmtVol(dSellVol), text_color=sellTxtCol, bgcolor=rowBg)
        table.cell(fpTable, 0, 3, "DELTA", text_color=deltaTxtCol, bgcolor=rowBg)
        table.cell(fpTable, 1, 3, fmtSignedVol(dDelta), text_color=deltaTxtCol, bgcolor=rowBg)
        table.cell(fpTable, 0, 4, "IMB", text_color=deltaTxtCol, bgcolor=rowBg)
        table.cell(fpTable, 1, 4, str.tostring(dImbalance, "#.0") + "%", text_color=deltaTxtCol, bgcolor=rowBg)
        table.cell(fpTable, 0, 5, showFVGInLabel ? "FVG" : "", text_color=fvgTxtCol, bgcolor=showFVGInLabel ? rowBg : color.new(color.black, 100))
        table.cell(fpTable, 1, 5, showFVGInLabel ? lastFVGText + " | TF " + fvgTfText : "", text_color=fvgTxtCol, bgcolor=showFVGInLabel ? rowBg : color.new(color.black, 100))
        table.cell(fpTable, 0, 6, showSourceText ? "SRC" : "", text_color=textColor, bgcolor=showSourceText ? rowBg : color.new(color.black, 100))
        table.cell(fpTable, 1, 6, showSourceText ? volumeSource : "", text_color=textColor, bgcolor=showSourceText ? rowBg : color.new(color.black, 100))

// -----------------------------------------------------------------------------
// ALERTS
// -----------------------------------------------------------------------------
alertcondition(bullFVG, "Bull FVG Confirmation", "Bullish FVG confirmation on {{ticker}}")
alertcondition(bearFVG, "Bear FVG Confirmation", "Bearish FVG confirmation on {{ticker}}")
````
