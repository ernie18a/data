# Cumulative Rejection Heatmap [MarkitTick]

- url: https://www.tradingview.com/script/yD0N9Wqr-Cumulative-Rejection-Heatmap-MarkitTick/
- type: indicator
- pine_id: PUB;16e2a574b5644c26aa9bbe8c76bea935
- version: 1.0

## Description

💡 This advanced visual analytics tool is designed to track, aggregate, and display price rejection zones over a rolling historical window. By focusing entirely on market wicks—the footprints of supply and demand absorption—this script constructs a dynamic heatmap that highlights where price has repeatedly struggled to close. Instead of simply looking at volume or closing prices, it isolates the exact microscopic levels where buyers and sellers have historically stepped in to reverse the momentum, providing a crystal-clear map of underlying market mechanics.

[b]● ✨ Originality and Utility[/b]

Traditional technical analysis often relies on closing prices or volume-at-price concepts like the Volume Profile. While valuable, these standard tools can sometimes obscure the specific price extremes where true order absorption occurs. This tool takes an entirely original approach by creating a "Rejection Profile." 

It systematically scans every single bar within a defined historical window, mathematically measures the length of the upper and lower wicks, and compares them against the total range of the bar. When a wick meets a stringent, user-defined threshold, it is classified as a valid rejection. Over time, these individual rejection events are accumulated into specific price bins, forming a dense, visual heatmap. 

The utility here is unparalleled for traders who rely on price action and liquidity concepts. By rendering a visual concentration of wicks, the chart immediately reveals hidden support and resistance walls that might not be evident through standard line-drawing techniques. It removes subjectivity from the process, mathematically proving where the market is consistently refusing to allow price to travel.

[b]● 🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/w3dPXSFD/[/image]
The core engine of this script relies on a rolling matrix computation combined with strict volatility filtering. The methodology can be broken down into several distinct logical phases:

[list]
[*] Volatility Filtering: Before any rejection is considered, the script measures the current bar's true range against a fraction of the Average True Range (ATR). If the bar's range is too small, it is deemed market noise or chop, and is entirely ignored. This prevents tight, low-volatility consolidation from falsely inflating the rejection heatmap.
[*] Wick Ratio Calculation: For valid bars, the script calculates the exact length of the upper wick (High minus the maximum of Open/Close) and the lower wick (minimum of Open/Close minus Low). This value is divided by the total bar range. If this ratio exceeds the minimum wick ratio threshold, a rejection event is triggered.
[*] Price Discretization (Binning): The script continuously tracks the highest high and lowest low of the entire lookback window. It divides this total vertical price space into a user-defined number of equal-sized bins. 
[*] Rolling Matrix Accumulation: Using an advanced matrix data structure, the script logs each rejection event into its corresponding price bin. As the lookback window rolls forward in time, the oldest data is systematically overwritten by the newest data. This ensures the heatmap is constantly adapting to current market conditions without retaining stale historical data that is no longer relevant.
[/list]

[b]● 🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/b7Sv9AvK/[/image]
The script overlays multiple layers of visual intelligence directly onto the main price chart, designed to be quickly readable without cluttering the workspace.

[b]• The Rejection Heatmap[/b]
Projected forward from current price action, a series of horizontal boxes forms the heatmap. The vertical height of each box represents a specific price bin, while the color intensity indicates the density of rejections within that bin. Colors transition dynamically using a custom gradient. Areas with little to no rejection remain dark and transparent, while areas of extreme rejection light up in high-contrast neon tones. Each box contains a subtle text label displaying the exact number of rejection hits and its percentage relative to the most rejected level.

[b]• Support and Resistance (S/R) Lines[/b]
The script automatically identifies the top bins with the absolute highest concentration of historical rejections. It projects dashed horizontal lines across the chart at the exact center of these bins. These lines act as major, mathematically validated support and resistance levels, highlighted in a distinct, user-defined border color.

[b]• Directional Triangles[/b]
When an immediate price rejection occurs on the live chart, a small geometric shape is printed to alert the user:
[list]
[*] A downward-pointing triangle above the bar indicates a significant upper wick rejection, signaling sudden selling pressure or supply absorption.
[*] An upward-pointing triangle below the bar indicates a significant lower wick rejection, signaling sudden buying pressure or demand absorption.
[/list]

[b]• The Analytics Dashboard[/b]
A sleek, customizable table is anchored to a corner of the chart, providing a heads-up display of the current market state. It displays the active asset, the rolling window size, the current ATR, and the exact price level of the highest rejection density. Furthermore, it features a text-based ASCII progress bar showing the peak density relative to historical maximums, and a Bull/Bear Bias metric that calculates the exact ratio of upward versus downward rejections over the entire window.

[b]● 📖 How to Use[/b]
[image]https://www.tradingview.com/x/2tevYz9k/[/image]
Traders can integrate this visual framework into a variety of market approaches, primarily focusing on mean reversion, breakout confirmation, and precise risk management.

[list]
[*] Identifying Liquidity Pools: The brightest zones on the heatmap represent areas where limit orders have historically absorbed market orders. Traders can use these glowing zones as highly probable target areas for taking profits, as price tends to gravitate toward and stall at heavy liquidity.
[*] Validating Breakouts: If price breaks cleanly through a bright red, high-density rejection zone and closes beyond it, it indicates a significant shift in market structure. A zone that previously acted as a ceiling (supply) may now act as a floor (demand) upon a retest.
[*] Stop Loss Placement: The automated S/R lines and high-density bins provide logical areas for stop-loss placement. Placing a stop just outside a heavy rejection bin ensures that the trade is only invalidated if the market successfully chews through a known area of heavy opposition.
[*] Real-Time Execution: The live directional triangles can be used as immediate trigger signals when they align with the broader heatmap context. For example, an upward-pointing triangle printing exactly as price dips into a historically dense lower rejection bin provides a high-probability entry for a long position.
[/list]

[b]● ⚙️ Inputs and Settings[/b]

The script is highly customizable, allowing the user to tailor the mathematical sensitivity and visual output to their specific asset and timeframe.

[b]• Heatmap Configuration[/b]
[list]
[*] Window: The rolling lookback period. A larger window encompasses more macro price action, while a shorter window reacts faster to recent volatility.
[*] Bins: Determines the vertical resolution. More bins create thinner, more granular price slices; fewer bins create wider, more generalized zones.
[*] Min Wick Ratio: The strictness of the rejection criteria. A higher value (e.g., 0.60) requires the wick to make up at least 60% of the entire bar, filtering out weak signals.
[*] Min Range (xATR): Filters out low-volatility bars to prevent tight consolidation from skewing the data.
[*] Heatmap Width %: Controls how far the visual heatmap projects into the future on the right side of the chart.
[/list]

[b]• Dashboard and Visuals[/b]
[list]
[*] Dashboard Pos: Anchors the analytics table to any corner of the chart to prevent obstruction of price action.
[*] Top S/R Levels: Determines how many distinct dashed support/resistance lines are drawn based on the highest-ranking bins.
[*] Use Neon Gradient: Toggles the dynamic color shading of the heatmap boxes.
[/list]

[b]• Alerts Configuration[/b]
[list]
[*] Action Long / Action Short: Custom JSON string inputs that allow the user to format specific payloads for automated trading platforms or webhooks when a live rejection triangle prints.
[/list]

[b]● 🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

At its academic core, this tool is heavily rooted in Auction Market Theory and the statistical discretization of continuous price variables. Auction Market Theory posits that financial markets exist solely to facilitate trade between buyers and sellers, constantly probing upward and downward to find areas of liquidity (fair value). When price extends too far and encounters a massive wall of limit orders, aggressive market orders are absorbed, and price is rapidly driven back in the opposite direction. On a candlestick chart, this aggressive absorption is permanently recorded as a wick.

By systematically isolating wicks, this script is effectively reconstructing the historical limit order book imbalance. It moves away from the continuous nature of time-series data and utilizes statistical binning—a process of dividing a continuous numerical range into discrete, non-overlapping intervals (bins). This is mathematically analogous to constructing a multidimensional probability density histogram. 

The underlying matrix acts as a Markovian state tracker, where the probability of future price rejection at a specific interval is inferred from the historical density of prior absorptions within that exact same interval. The application of the Average True Range (ATR) as a high-pass volatility filter ensures that the statistical sample is robust, eliminating low-amplitude noise and focusing the mathematical weight strictly on statistically significant standard deviation expansions.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Cumulative Rejection Heatmap [MarkitTick]", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ── INPUTS ─────────────────────────────────────────────────────
i_lookback      = input.int(150, "Window", minval=20, maxval=500, group="🔥 Heatmap")
i_binCount      = input.int(40, "Bins", minval=10, maxval=100, group="🔥 Heatmap")
i_wickRatio     = input.float(0.55, "Min Wick Ratio", minval=0.1, maxval=0.95, step=0.05, group="🔥 Heatmap")
i_minRangeATR   = input.float(0.05, "Min Range (xATR)", minval=0.0, step=0.01, group="🔥 Heatmap")
i_heatWidthPct  = input.float(12.0, "Heatmap Width %", minval=2.0, maxval=40.0, group="🔥 Heatmap")
i_maxTriangles  = input.int(20, "Max Triangles Count", minval=1, maxval=500, group="🔥 Heatmap", tooltip="Set the maximum number of triangles shown on the chart")

i_dashPos       = input.string("Top Right", "Dashboard Pos", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="📊 Dashboard")
i_dashBg        = input.color(color.new(#0d1321, 12), "BG", group="📊 Dashboard")
i_dashHeaderBg  = input.color(color.new(#5c6bc0, 25), "Header BG", group="📊 Dashboard")
i_dashLabelClr  = input.color(color.new(#90a4c8, 12), "Label Text", group="📊 Dashboard")
i_dashValueClr  = input.color(color.new(#f4f7fb, 0), "Value Text", group="📊 Dashboard")

var string GRP_WH         = "🔔 Alerts"
i_actionLong              = input.string("long",       "↑ Long Action",        group=GRP_WH)
i_actionShort             = input.string("short",      "↓ Short Action",       group=GRP_WH)
i_actionCloseLong         = input.string("closelong",  "✕ Close Long Action",  group=GRP_WH)
i_actionCloseShort        = input.string("closeshort", "✕ Close Short Action", group=GRP_WH)

i_colMax        = input.color(#ff3d00, "Max Rejection", group="🎨 Colors")
i_colMid        = input.color(#ff9800, "Mid Rejection", group="🎨 Colors")
i_colMin        = input.color(color.new(#0b0f14, 90), "Low/No Rejection", group="🎨 Colors")
i_colSR         = input.color(#00e5c7, "Key S/R Border", group="🎨 Colors")
i_srTopN        = input.int(3, "Top S/R Levels", minval=1, maxval=10, group="🎨 Colors")
i_useGradient   = input.bool(true, "Use Neon Gradient", group="🎨 Colors")
i_dashBorderClr = input.color(color.new(#7e57c2, 30), "Dash Border", group="🎨 Colors")
i_dashFrameClr  = input.color(color.new(#26c6da, 10), "Dash Frame", group="🎨 Colors")
i_dashRowBg     = input.color(color.new(#0d1321, 0), "Dash Row BG", group="🎨 Colors")
i_barGradLow    = input.color(#ff3d00, "Bar Gradient Low", group="🎨 Colors")
i_barGradHigh   = input.color(#00e5c7, "Bar Gradient High", group="🎨 Colors")

// ── CORE LOGIC ─────────────────────────────────────────────────
float atrVal = ta.atr(14)
float barRange = high - low
bool validBar = barRange > atrVal * i_minRangeATR

float upperWick = high - math.max(close, open)
float lowerWick = math.min(close, open) - low
bool rejUp   = validBar and (upperWick / barRange) >= i_wickRatio
bool rejDown = validBar and (lowerWick / barRange) >= i_wickRatio

float rejUpPrice   = rejUp   ? high : na
float rejDownPrice = rejDown ? low  : na

var matrix<float> hitMatrix = matrix.new<float>(i_lookback, i_binCount, 0.0)
var int writeRow = 0

float winHigh = ta.highest(high, i_lookback)
float winLow  = ta.lowest(low, i_lookback)
float binSize = (winHigh - winLow) / i_binCount

f_binIndex(float price) =>
    int idx = na
    if not na(price) and binSize > 0
        idx := int(math.min(math.max(math.floor((price - winLow) / binSize), 0), i_binCount - 1))
    idx

int binUp   = f_binIndex(rejUpPrice)
int binDown = f_binIndex(rejDownPrice)

if barstate.isconfirmed
    for b = 0 to i_binCount - 1
        matrix.set(hitMatrix, writeRow, b, 0.0)
    if not na(binUp)
        matrix.set(hitMatrix, writeRow, binUp, matrix.get(hitMatrix, writeRow, binUp) + 1.0)
    if not na(binDown)
        matrix.set(hitMatrix, writeRow, binDown, matrix.get(hitMatrix, writeRow, binDown) + 1.0)
    writeRow := (writeRow + 1) % i_lookback

array<float> binTotals = array.new_float(i_binCount, 0.0)
for b = 0 to i_binCount - 1
    array.set(binTotals, b, array.sum(matrix.col(hitMatrix, b)))

float maxHit = array.max(binTotals)

f_barColorGrad(float pct) =>
    i_useGradient ? color.from_gradient(pct, 0.0, 1.0, color.new(i_colSR, 0), color.new(i_colMax, 0)) : (pct >= 0.66 ? color.new(i_colMax, 0) : pct >= 0.33 ? color.new(i_colMid, 0) : i_colMin)

f_bar(float val, float maxVal, color clr) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"

f_barColor(float pct) =>
    color.from_gradient(pct, 0.0, 1.0, color.new(i_barGradLow, 0), color.new(i_barGradHigh, 0))

var array<box> heatBoxes = array.new<box>()
var array<label> heatLabels = array.new<label>()
f_clearBoxes() =>
    if array.size(heatBoxes) > 0
        for bx in heatBoxes
            box.delete(bx)
        array.clear(heatBoxes)
    if array.size(heatLabels) > 0
        for lb in heatLabels
            label.delete(lb)
        array.clear(heatLabels)

int heatLeft  = bar_index + 1
int heatRight = bar_index + math.min(math.max(int(math.round(i_lookback * (i_heatWidthPct / 100.0))), 5), 490)

if barstate.isconfirmed
    f_clearBoxes()
    for b = 0 to i_binCount - 1
        float total = array.get(binTotals, b)
        if total > 0 and maxHit > 0
            float pct = total / maxHit
            color cellClr = f_barColorGrad(pct)
            float top = winLow + (b + 1) * binSize
            float bot = winLow + b * binSize
            box hb = box.new(heatLeft, top, heatRight, bot, border_color=na, bgcolor=color.new(cellClr, 100 - int(pct * 60)))
            array.push(heatBoxes, hb)
            label hbLbl = label.new(heatRight, (top + bot) / 2, str.tostring(int(total)) + " (" + str.tostring(math.round(pct * 100)) + "%)", style=label.style_label_left, color=color.new(cellClr, 40), textcolor=i_colSR, size=size.small)
            array.push(heatLabels, hbLbl)

var array<line> srLines = array.new<line>()
var array<label> srLabels = array.new<label>()
f_clearSR() =>
    if array.size(srLines) > 0
        for ln in srLines
            line.delete(ln)
        array.clear(srLines)
    if array.size(srLabels) > 0
        for lb in srLabels
            label.delete(lb)
        array.clear(srLabels)

if barstate.isconfirmed and maxHit > 0
    f_clearSR()
    array<float> sortedTot = array.copy(binTotals)
    array.sort(sortedTot, order.descending)
    int topN = math.min(i_srTopN, array.size(sortedTot))
    for k = 0 to topN - 1
        float thresh = array.get(sortedTot, k)
        for b = 0 to i_binCount - 1
            if array.get(binTotals, b) == thresh and thresh > 0
                float lvl = winLow + b * binSize + binSize / 2
                line srLn = line.new(bar_index - i_lookback, lvl, heatRight, lvl, color=i_colSR, width=1, style=line.style_dashed, extend=extend.none)
                array.push(srLines, srLn)
                label srLbl = label.new(heatRight, lvl, "S/R " + str.tostring(lvl, format.mintick), style=label.style_label_left, color=color.new(i_colSR, 20), textcolor=i_dashValueClr, size=size.small)
                array.push(srLabels, srLbl)

bool longSignal  = rejDown and not rejUp and barstate.isconfirmed
bool shortSignal = rejUp and not rejDown and barstate.isconfirmed

// ── ALERTS ─────────────────────────────────────────────────────
string _longInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}"',
     i_actionLong, syminfo.tickerid, timeframe.period,
     str.tostring(close[1], format.mintick))
string longPayload = "{" + _longInner + "}"

string _shortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}"',
     i_actionShort, syminfo.tickerid, timeframe.period,
     str.tostring(close[1], format.mintick))
string shortPayload = "{" + _shortInner + "}"

string _closeLongInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closelong","entry":"{3}"',
     i_actionCloseLong, syminfo.tickerid, timeframe.period,
     str.tostring(close[1], format.mintick))
string closeLongPayload = "{" + _closeLongInner + "}"

string _closeShortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closeshort","entry":"{3}"',
     i_actionCloseShort, syminfo.tickerid, timeframe.period,
     str.tostring(close[1], format.mintick))
string closeShortPayload = "{" + _closeShortInner + "}"

if longSignal and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if longSignal and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)

alertcondition(longSignal  and barstate.isconfirmed, "BUY Signal",         "MarkitTick — BUY Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "SELL Signal",        "MarkitTick — SELL Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "Close Long Signal",  "MarkitTick — Close Long")
alertcondition(longSignal  and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")

// ── VISUALS ────────────────────────────────────────────────────
var array<label> upTriangles = array.new<label>()
var array<label> downTriangles = array.new<label>()

if rejUp
    label l_up = label.new(bar_index, na, text="▼", style=label.style_none, yloc=yloc.abovebar, textcolor=i_colMax, size=size.small)
    array.push(upTriangles, l_up)
    if array.size(upTriangles) > i_maxTriangles
        label.delete(array.shift(upTriangles))

if rejDown
    label l_dn = label.new(bar_index, na, text="▲", style=label.style_none, yloc=yloc.belowbar, textcolor=i_colSR, size=size.small)
    array.push(downTriangles, l_dn)
    if array.size(downTriangles) > i_maxTriangles
        label.delete(array.shift(downTriangles))

// ── DASHBOARD ──────────────────────────────────────────────────
f_pos(string p) =>
    p == "Top Right" ? position.top_right : p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : position.bottom_left

var table dash = table.new(f_pos(i_dashPos), 2, 8, bgcolor=i_dashBg, border_color=i_dashBorderClr, border_width=1, frame_color=i_dashFrameClr, frame_width=2)

float bestTotal = maxHit
int   bestBin = -1
for b = 0 to i_binCount - 1
    if array.get(binTotals, b) == bestTotal
        bestBin := b

float bestLevel = bestBin >= 0 ? winLow + bestBin * binSize + binSize / 2 : na
var float upRejCount = 0.0
var float downRejCount = 0.0
if barstate.isconfirmed
    upRejCount := rejUp ? upRejCount + 1 : upRejCount
    downRejCount := rejDown ? downRejCount + 1 : downRejCount
float biasSum = upRejCount + downRejCount
float upBiasPct = biasSum > 0 ? upRejCount / biasSum : 0.0

table.cell(dash, 0, 0, "⚡ " + syminfo.ticker, text_color=i_dashValueClr, bgcolor=i_dashHeaderBg, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 0, syminfo.prefix, text_color=color.new(i_dashValueClr, 25), bgcolor=i_dashHeaderBg, text_size=size.small, text_halign=text.align_right)

table.cell(dash, 0, 1, "Window", text_color=i_dashLabelClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 1, str.tostring(i_lookback), text_color=i_dashValueClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_right)

table.cell(dash, 0, 2, "Bins", text_color=i_dashLabelClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 2, str.tostring(i_binCount), text_color=i_dashValueClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_right)

table.cell(dash, 0, 3, "Peak Level", text_color=i_dashLabelClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 3, na(bestLevel) ? "—" : str.tostring(bestLevel, format.mintick), text_color=i_dashValueClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_right)

string barStr = maxHit > 0 ? f_bar(bestTotal, maxHit, f_barColor(1.0)) : f_bar(0.0, 1.0, f_barColor(0.0))
color barClr = maxHit > 0 ? f_barColor(bestTotal / maxHit) : f_barColor(0.0)
table.cell(dash, 0, 4, "Peak Density", text_color=i_dashLabelClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 4, barStr, text_color=barClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_right)

table.cell(dash, 0, 5, "ATR", text_color=i_dashLabelClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 5, str.tostring(atrVal, format.mintick), text_color=i_dashValueClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_right)

table.cell(dash, 0, 6, "Range Hi/Lo", text_color=i_dashLabelClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 6, str.tostring(winHigh, format.mintick) + " / " + str.tostring(winLow, format.mintick), text_color=i_dashValueClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_right)

string biasStr = f_bar(upRejCount, math.max(biasSum, 1.0), f_barColor(upBiasPct))
color biasClr = f_barColor(upBiasPct)
table.cell(dash, 0, 7, "Bull/Bear Bias", text_color=i_dashLabelClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 7, biasStr, text_color=biasClr, bgcolor=i_dashRowBg, text_size=size.small, text_halign=text.align_right)
````
