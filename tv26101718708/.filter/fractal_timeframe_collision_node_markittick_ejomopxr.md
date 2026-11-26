# Fractal Timeframe Collision Node [MarkitTick]

- url: https://www.tradingview.com/script/ejOmopXr-Fractal-Timeframe-Collision-Node-MarkitTick/
- type: indicator
- pine_id: PUB;c626235f6d484599918e235283d18e28
- version: 1.0

## Description

💡 The financial markets operate across multiple interacting timeframes, creating complex structural geometries that cannot be accurately analyzed through a single, isolated lens. The tool presented here acts as a comprehensive multi-timeframe aggregation engine, designed to isolate highly significant structural support and resistance clusters. By evaluating pivot points across four distinct time spans and merging them based on volatility-adjusted proximity, this system identifies high-probability reaction zones where structural exhaustion is most likely to occur. It is built strictly for the modern Pine Script environment, utilizing an entirely non-repainting architecture that respects the highest standards of data integrity and execution logic.

[b]● ✨ Originality and Utility[/b]
Standard pivot or support/resistance scripts typically plot historical swing highs and lows independently. This creates chart clutter and often leaves the analyst guessing which level holds the most technical weight. This tool introduces the concept of "Collision Nodes." Instead of simply drawing every pivot, the algorithm scans higher timeframe data, identifies structural extremes, and clusters them together using a dynamic, adaptive mechanism.
[list]
[*] When multiple higher timeframes project a pivot at the exact same price zone, a structural "Collision Node" is formed.
[*] The utility lies in its objective strength grading: a node formed by the confluence of the 1-hour, 4-hour, and Daily charts mathematically demands more respect than a single localized swing point on a lower timeframe.
[*] By filtering out the noise and only projecting nodes that meet a user-defined minimum strength threshold, the analyst is presented with a remarkably clean chart displaying only the most critical, high-liquidity zones.
[*] Furthermore, the script automatically generates full trade execution parameters (Entry, Stop Loss, and multiple Take Profits) directly on the chart when a valid structural rejection occurs.
[/list]

[b]● 🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/zKuKsbEu/[/image]
[b]• Multi-Timeframe Pivot Extraction[/b]
The core engine relies on detecting localized extrema (Pivot Highs and Pivot Lows) over a user-defined lookback window. The script fetches these pivot values simultaneously from three higher timeframes plus the current chart's timeframe. To ensure absolute data integrity and prevent any future data leakage (repainting), the algorithm strictly requests historical, confirmed data using offset historical referencing.

[b]• Volatility-Normalized Spatial Clustering[/b]
Once the pivots are extracted, the algorithm must determine if they "collide" or overlap. Because absolute price distance is irrelevant across different assets, the script uses a dynamic clustering mechanism normalized by the Average True Range (ATR). 
[list]
[*] A tolerance band is calculated by multiplying the current ATR by a user-defined coefficient.
[*] If a newly discovered higher timeframe pivot falls within this exact tolerance band of an existing pivot cluster, it is merged into that cluster, and the cluster's "strength" rating is incremented.
[*] If it falls outside the tolerance band, a new independent node is registered.
[/list]

[b]• Memory Management and Age Pruning[/b]
Financial markets possess a memory, but structural relevance decays over time. The script incorporates a memory management protocol that continually monitors the age of all registered nodes. If a node has not been tested or updated within a specific bar count limit, it is automatically pruned from the active array, ensuring that only highly relevant, modern liquidity pools are analyzed.

[b]• Automated Signal Validation[/b]
A visual node is not a signal; it is an area of interest. The script validates trade signals by combining spatial location with price action. A valid signal requires the price to close inside the tolerance zone of a high-strength node, accompanied by a rejection candle (where the wick constitutes a significant percentage of the total candle range), and a structural close confirming the directional bias.

[b]● 🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/QdJymxZ8/[/image]
[b]• Collision Nodes[/b]
[list]
[*] [b]Teal Horizontal Lines:[/b] Represent bullish support nodes. The opacity of the line dynamically shifts based on the strength of the node (darker/more solid lines indicate higher timeframe confluence).
[*] [b]Red Horizontal Lines:[/b] Represent bearish resistance nodes. Like the bullish nodes, their visibility scales with structural strength.
[*] [b]Diamond Labels (◆×2, ◆×3):[/b] Attached to the end of the node lines, these labels explicitly display the node's strength rating. A "◆×3" label means three separate timeframes have confirmed a pivot at this exact mathematical level.
[/list]

[b]• Trade Execution Box[/b]
[list]
[*] [b]Dashed Blue Line:[/b] Indicates the exact Entry price upon signal confirmation.
[*] [b]Solid Red Line:[/b] Represents the dynamic Stop Loss, which is placed behind the collision node with an added ATR-based buffer to avoid premature liquidation.
[*] [b]Dashed Teal Lines (TP1, TP2, TP3):[/b] Represent calculated Take Profit levels projected automatically based on the user's defined Risk-to-Reward (RR) multipliers.
[*] [b]Red Background Fill:[/b] Visually maps the total risk zone between the Entry and the Stop Loss.
[*] [b]Teal Background Fill:[/b] Visually maps the total reward zone extending from the Entry up to the final Take Profit target.
[/list]

[b]• Real-time Dashboard[/b]
[list]
[*] Located by default in the top right corner, this data table provides an instant summary of the market structure.
[*] [b]Bias:[/b] Displays the current active signal direction (LONG, SHORT, or NONE).
[*] [b]Active Nodes & Strengths:[/b] Lists the exact price levels of the nearest active bull and bear nodes, accompanied by visual progress bars displaying their respective strengths (Green for high strength, Yellow for medium, Red for low).
[*] [b]Trade Tracking:[/b] Displays the currently active Stop Loss and primary Take Profit levels if a trade configuration is locked on the chart.
[/list]

[b]● 📖 How to Use[/b]
[image]https://www.tradingview.com/x/bmwXeUmE/[/image]
[list=1]
[*] Apply the indicator to your chart and set your three preferred higher timeframes in the settings (e.g., if trading on the 15-minute chart, you might select 1-Hour, 4-Hour, and Daily).
[*] Observe the chart for the formation of high-strength Collision Nodes (look for ◆×3 or ◆×4 labels). These are your primary zones of interest.
[*] Wait for price action to approach these nodes. Do not place blind limit orders.
[*] Allow the script's internal logic to identify a structural rejection. When a valid rejection candle forms and closes at a node, a trade execution box will automatically populate on the chart.
[*] Use the provided Entry, Stop Loss, and Take Profit lines to format your position sizing and manage the trade according to the mapped risk-to-reward parameters.
[*] Optionally, link the script's advanced JSON webhook alerts to an external execution platform for automated trade routing.
[/list]

[b]● ⚙️ Inputs and Settings[/b]
[image]https://www.tradingview.com/x/Hf7VnFji/[/image]
[b]• Core Settings[/b]
[list]
[*] [b]Pivot Lookback:[/b] The structural length required to confirm a swing high or low.
[*] [b]TF 1, TF 2, TF 3:[/b] The three higher timeframes used to scan for structural confluence.
[*] [b]Include Chart TF:[/b] Determines if the current chart's timeframe should also contribute to node strength.
[*] [b]Node Tolerance (×ATR):[/b] The spatial bandwidth used to cluster pivots together, measured as a multiplier of current volatility.
[*] [b]Min Node Strength:[/b] The minimum number of overlapping timeframes required for a node to be rendered on the chart.
[/list]

[b]• Filters[/b]
[list]
[*] [b]Require Rejection Candle:[/b] Enforces strict price action criteria, demanding that signals only fire if the candle displays a prominent rejection wick.
[*] [b]Min Wick % of Range:[/b] The exact percentage of the candle that must be composed of the wick to validate a rejection.
[*] [b]Max Node Age (bars):[/b] The duration a node remains active without being re-tested before being permanently purged from memory.
[/list]

[b]• Trade Tools[/b]
[list]
[*] [b]SL Buffer (×ATR):[/b] Adds a dynamic volatility buffer beyond the structural node to determine the absolute invalidation point.
[*] [b]TP1, TP2, TP3 (×SL Risk):[/b] The respective risk-to-reward multipliers used to dynamically project profit targets.
[*] [b]Lock Current Trade Levels:[/b] Freezes the visual risk/reward box on the chart until the trade hits either the final target or the stop loss, ignoring subsequent signals.
[/list]

[b]• Dashboard & Alerts[/b]
[list]
[*] [b]Show Dashboard:[/b] Toggles the visibility of the real-time data table.
[*] [b]Alert Actions:[/b] Customizable text fields allowing users to define specific JSON payload strings for long, short, and exit triggers.
[/list]

[b]● 🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
The architectural foundation of this algorithm is heavily rooted in the Fractal Market Hypothesis (FMH), which posits that financial markets exhibit self-similar statistical structures across varying scales of time. In practical terms, a distribution pattern on a 5-minute chart mathematically resembles a distribution pattern on a Weekly chart. By aggregating pivot extrema from multiple independent time scales, this script exploits these fractal geometries to identify areas of harmonic resonance—price zones where liquidity pools overlap across different cohorts of market participants.

To resolve the spatial clustering problem, the system utilizes a volatility-normalized one-dimensional grouping algorithm conceptually akin to Density-Based Spatial Clustering of Applications with Noise (DBSCAN). Instead of utilizing fixed scalar distances (which fail as asset prices scale), the algorithm calculates an epsilon distance bounded by the Average True Range (ATR). This ensures that the clustering logic expands and contracts organically with market entropy. The ultimate output is a mathematically objective reduction of structural noise, isolating only the highest-density liquidity nodes that possess the greatest statistical probability of halting directional momentum.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Fractal Timeframe Collision Node [MarkitTick]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)

// ── INPUTS ──────────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core Settings"
i_pivotLen    = input.int(5, "Pivot Lookback", minval=2, maxval=30, group=GRP_CORE)
_mt741a         = input.timeframe("60",  "TF 1", group=GRP_CORE)
i_tf2         = input.timeframe("240", "TF 2", group=GRP_CORE)
i_tf3         = input.timeframe("D",   "TF 3", group=GRP_CORE)
i_useCurrTF   = input.bool(true, "Include Chart TF", group=GRP_CORE)
i_tolMult     = input.float(0.35, "Node Tolerance (×ATR)", minval=0.05, maxval=2.0, step=0.05, group=GRP_CORE)
i_atrLen      = input.int(14, "ATR Length", minval=1, group=GRP_CORE)
i_minStrength = input.int(2, "Min Node Strength", minval=1, maxval=4, group=GRP_CORE)
i_maxNodes    = input.int(1, "Max Nodes Drawn (per side)", minval=1, maxval=20, group=GRP_CORE)
i_nodeExtBars = input.int(30, "Node Line Extension (bars)", minval=5, maxval=200, group=GRP_CORE)

var string GRP_FILT = "🕯️ Filters"
i_useRejection  = input.bool(true, "Require Rejection Candle", group=GRP_FILT)
i_rejWickPct    = input.float(40.0, "Min Wick % of Range", minval=10.0, maxval=90.0, group=GRP_FILT)
i_nodeMaxAge    = input.int(300, "Max Node Age (bars)", minval=20, maxval=2000, group=GRP_FILT)

var string GRP_TRADE = "📐 Trade Tools"
i_slAtrBuf   = input.float(1, "SL Buffer (×ATR)", minval=0.0, maxval=2.0, step=0.05, group=GRP_TRADE)
i_tp1RR      = input.float(1.0, "TP1 (×SL Risk)", minval=0.1, maxval=20.0, step=0.1, group=GRP_TRADE)
i_tp2RR      = input.float(2.0, "TP2 (×SL Risk)", minval=0.1, maxval=20.0, step=0.1, group=GRP_TRADE)
i_tp3RR      = input.float(3.0, "TP3 (×SL Risk)", minval=0.1, maxval=20.0, step=0.1, group=GRP_TRADE)
i_lockLevels = input.bool(false, "Lock Current Trade Levels", group=GRP_TRADE)

var string GRP_VIS = "🎨 Visuals"
i_showNodes     = input.bool(false, "Show Collision Nodes", group=GRP_VIS)
i_showLabels    = input.bool(true, "Show Node Strength Labels", group=GRP_VIS)
i_showTradeBox  = input.bool(true, "Show Trade Levels", group=GRP_VIS)

var string GRP_DASH = "📊 Dashboard"
i_showDash    = input.bool(true, "Show Dashboard", group=GRP_DASH)
i_dashPos     = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_DASH)

var string GRP_WH = "🔔 Alerts"
i_actionLong       = input.string("long",        "↑ Long Action",        group=GRP_WH)
i_actionShort      = input.string("short",       "↓ Short Action",       group=GRP_WH)
i_actionCloseLong  = input.string("closelong",   "✕ Close Long Action",  group=GRP_WH)
i_actionCloseShort = input.string("closeshort",  "✕ Close Short Action", group=GRP_WH)

var string GRP_COL = "🌈 Colors"
c_bullNode   = input.color(color.new(#26a69a, 0),  "Bull Node", group=GRP_COL)
c_bearNode   = input.color(color.new(#ef5350, 0),  "Bear Node", group=GRP_COL)
c_nodeLabel  = input.color(color.new(#ffffff, 0),  "Node Label Text", group=GRP_COL)
c_slLine     = input.color(#ef5350, "SL Line", group=GRP_COL)
c_entryLine  = input.color(#2196f3, "Entry Line", group=GRP_COL)
c_tp1Line    = input.color(color.new(#26a69a, 40), "TP1 Line", group=GRP_COL)
c_tp2Line    = input.color(color.new(#26a69a, 20), "TP2 Line", group=GRP_COL)
c_tp3Line    = input.color(color.new(#26a69a, 0),  "TP3 Line", group=GRP_COL)
c_riskFill   = input.color(color.new(#ef5350, 80), "Risk Zone Fill", group=GRP_COL)
c_rewardFill = input.color(color.new(#26a69a, 85), "Reward Zone Fill", group=GRP_COL)
c_dashBg     = input.color(color.new(#0a0f1a, 10), "Dashboard BG", group=GRP_COL)
c_dashHeader = input.color(color.new(#14b5cb, 20), "Dashboard Header", group=GRP_COL)
c_dashLblTxt = input.color(color.new(#ffffff, 30), "Dashboard Label Text", group=GRP_COL)
c_dashLblBg  = input.color(color.new(#0a0f1a, 0),  "Dashboard Label BG", group=GRP_COL)
c_dashValBg  = input.color(color.new(#0d1117, 0),  "Dashboard Value BG", group=GRP_COL)
c_dashValTxt = input.color(#ffffff, "Dashboard Value Text", group=GRP_COL)
c_biasNeut   = input.color(color.gray, "Neutral Bias Text", group=GRP_COL)
c_barGreen   = input.color(color.new(#26a69a, 0), "Progress Bar High", group=GRP_COL)
c_barYellow  = input.color(color.new(#f9a825, 0), "Progress Bar Mid", group=GRP_COL)
c_barRed     = input.color(color.new(#ef5350, 0), "Progress Bar Low", group=GRP_COL)
c_levelLblTxt = input.color(#ffffff, "Trade Level Label Text", group=GRP_COL)

// ── CORE LOGIC ──────────────────────────────────────────────────
f_pivotHigh(_len) =>
    float _ph = high[_len]
    bool _isPivot = true
    for i = 0 to _len - 1
        if high[i] >= _ph or high[_len * 2 - i] >= _ph
            _isPivot := false
    _isPivot ? _ph : na

f_pivotLow(_len) =>
    float _pl = low[_len]
    bool _isPivot = true
    for i = 0 to _len - 1
        if low[i] <= _pl or low[_len * 2 - i] <= _pl
            _isPivot := false
    _isPivot ? _pl : na

atrVal = ta.atr(i_atrLen)
tol = atrVal * i_tolMult

f_getHTFPivots(_tf) =>
    [_ph, _pl] = request.security(syminfo.tickerid, _tf, [f_pivotHigh(i_pivotLen)[1], f_pivotLow(i_pivotLen)[1]], lookahead=barmerge.lookahead_on)
    [_ph, _pl]

[htf1High, htf1Low] = f_getHTFPivots(_mt741a)
[htf2High, htf2Low] = f_getHTFPivots(i_tf2)
[htf3High, htf3Low] = f_getHTFPivots(i_tf3)
curHigh = f_pivotHigh(i_pivotLen)
_mt741b  = f_pivotLow(i_pivotLen)

var float[] nodeHighPrices = array.new_float(0)
var int[]   nodeHighBars   = array.new_int(0)
var int[]   nodeHighStr    = array.new_int(0)
var float[] nodeLowPrices  = array.new_float(0)
var int[]   nodeLowBars    = array.new_int(0)
var int[]   nodeLowStr     = array.new_int(0)

f_registerPivot(float px, bool isHigh) =>
    if not na(px)
        float[] priceArr = isHigh ? nodeHighPrices : nodeLowPrices
        int[]   barArr   = isHigh ? nodeHighBars   : nodeLowBars
        int[]   strArr   = isHigh ? nodeHighStr    : nodeLowStr
        int matchIdx = -1
        if array.size(priceArr) > 0
            for i = 0 to array.size(priceArr) - 1
                if math.abs(array.get(priceArr, i) - px) <= tol
                    matchIdx := i
        if matchIdx >= 0
            array.set(strArr, matchIdx, math.min(array.get(strArr, matchIdx) + 1, 4))
            array.set(barArr, matchIdx, bar_index)
        else
            array.push(priceArr, px)
            array.push(barArr, bar_index)
            array.push(strArr, 1)

if barstate.isconfirmed
    f_registerPivot(htf1High, true)
    f_registerPivot(htf2High, true)
    f_registerPivot(htf3High, true)
    if i_useCurrTF
        f_registerPivot(curHigh, true)

    f_registerPivot(htf1Low, false)
    f_registerPivot(htf2Low, false)
    f_registerPivot(htf3Low, false)
    if i_useCurrTF
        f_registerPivot(_mt741b, false)

f_pruneOld(float[] priceArr, int[] barArr, int[] strArr) =>
    if array.size(barArr) > 0
        for i = array.size(barArr) - 1 to 0
            if bar_index - array.get(barArr, i) > i_nodeMaxAge
                array.remove(priceArr, i)
                array.remove(barArr, i)
                array.remove(strArr, i)

f_pruneOld(nodeHighPrices, nodeHighBars, nodeHighStr)
f_pruneOld(nodeLowPrices, nodeLowBars, nodeLowStr)

f_bestNode(float[] priceArr, int[] strArr, float refPrice, bool above) =>
    float bestPx = na
    int bestStr = 0
    if array.size(priceArr) > 0
        for i = 0 to array.size(priceArr) - 1
            float px = array.get(priceArr, i)
            int st = array.get(strArr, i)
            bool sideOk = above ? px > refPrice : px < refPrice
            if sideOk and st >= i_minStrength
                if na(bestPx) or (above ? px < bestPx : px > bestPx)
                    bestPx := px
                    bestStr := st
    [bestPx, bestStr]

[nearestBearNode, nearestBearStr] = f_bestNode(nodeHighPrices, nodeHighStr, close, true)
[nearestBullNode, nearestBullStr] = f_bestNode(nodeLowPrices, nodeLowStr, close, false)

candleRange = high - low
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
bullRejection = i_useRejection ? (candleRange > 0 and lowerWick / candleRange * 100 >= i_rejWickPct) : true
bearRejection = i_useRejection ? (candleRange > 0 and upperWick / candleRange * 100 >= i_rejWickPct) : true

atBullNode = not na(nearestBullNode) and math.abs(low - nearestBullNode) <= tol
atBearNode = not na(nearestBearNode) and math.abs(high - nearestBearNode) <= tol

longSignal  = atBullNode and bullRejection and close > open
shortSignal = atBearNode and bearRejection and close < open

var float entryPrice = na
var float slPrice = na
var float tp1Price = na
var float tp2Price = na
var float tp3Price = na
var int lastSignalBar = na
var int tradeDir = 0
var bool lockedTradeActive = false
var bool lockedTradeJustClosed = false

if not i_lockLevels
    lockedTradeActive := false

lockedTradeJustClosed := false
if not na(entryPrice) and barstate.isconfirmed
    bool tp3Hit = tradeDir == 1 ? high >= tp3Price : low <= tp3Price
    bool slHit   = tradeDir == 1 ? low <= slPrice : high >= slPrice
    if tp3Hit or slHit
        lockedTradeActive := false
        lockedTradeJustClosed := true

f_findOppositeNodes(bool isLong) =>
    var float[] pxArr = array.new_float(0)
    array.clear(pxArr)
    if isLong
        if array.size(nodeHighPrices) > 0
            for i = 0 to array.size(nodeHighPrices) - 1
                float px = array.get(nodeHighPrices, i)
                int st = array.get(nodeHighStr, i)
                if px > close and st >= i_minStrength
                    array.push(pxArr, px)
    else
        if array.size(nodeLowPrices) > 0
            for i = 0 to array.size(nodeLowPrices) - 1
                float px = array.get(nodeLowPrices, i)
                int st = array.get(nodeLowStr, i)
                if px < close and st >= i_minStrength
                    array.push(pxArr, px)
    if array.size(pxArr) >= 2
        for a = 0 to array.size(pxArr) - 2
            for b = 0 to array.size(pxArr) - 2 - a
                bool outOfOrder = isLong ? array.get(pxArr, b) > array.get(pxArr, b + 1) : array.get(pxArr, b) < array.get(pxArr, b + 1)
                if outOfOrder
                    float tmp = array.get(pxArr, b)
                    array.set(pxArr, b, array.get(pxArr, b + 1))
                    array.set(pxArr, b + 1, tmp)
    pxArr

if longSignal and barstate.isconfirmed and not lockedTradeActive
    entryPrice := close
    slPrice := nearestBullNode - atrVal * i_slAtrBuf
    float origRisk = math.abs(entryPrice - slPrice)
    tp1Price := entryPrice + origRisk * i_tp1RR
    tp2Price := entryPrice + origRisk * i_tp2RR
    tp3Price := entryPrice + origRisk * i_tp3RR
    lastSignalBar := bar_index
    tradeDir := 1
    if i_lockLevels
        lockedTradeActive := true

if shortSignal and barstate.isconfirmed and not lockedTradeActive
    entryPrice := close
    slPrice := nearestBearNode + atrVal * i_slAtrBuf
    float origRisk = math.abs(slPrice - entryPrice)
    tp1Price := entryPrice - origRisk * i_tp1RR
    tp2Price := entryPrice - origRisk * i_tp2RR
    tp3Price := entryPrice - origRisk * i_tp3RR
    lastSignalBar := bar_index
    tradeDir := -1
    if i_lockLevels
        lockedTradeActive := true

// ── ALERTS ──────────────────────────────────────────────────────
string _longInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp":"{5}","strength":"{6}"',
     i_actionLong, syminfo.tickerid, timeframe.period,
     str.tostring(close[1], format.mintick),
     str.tostring(slPrice, format.mintick),
     str.tostring(tp1Price, format.mintick),
     str.tostring(nearestBullStr))
string longPayload = "{" + _longInner + "}"

string _shortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp":"{5}","strength":"{6}"',
     i_actionShort, syminfo.tickerid, timeframe.period,
     str.tostring(close[1], format.mintick),
     str.tostring(slPrice, format.mintick),
     str.tostring(tp1Price, format.mintick),
     str.tostring(nearestBearStr))
string shortPayload = "{" + _shortInner + "}"

string _clInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closelong"',
     i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _clInner + "}"

string _csInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closeshort"',
     i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _csInner + "}"

if longSignal and barstate.isconfirmed and lastSignalBar == bar_index
    alert(longPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed and lastSignalBar == bar_index
    alert(shortPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed and lastSignalBar == bar_index
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if longSignal and barstate.isconfirmed and lastSignalBar == bar_index
    alert(closeShortPayload, alert.freq_once_per_bar_close)

alertcondition(longSignal  and barstate.isconfirmed and lastSignalBar == bar_index, "BUY Signal",         "MarkitTick — BUY Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed and lastSignalBar == bar_index, "SELL Signal",        "MarkitTick — SELL Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed and lastSignalBar == bar_index, "Close Long Signal",  "MarkitTick — Close Long")
alertcondition(longSignal  and barstate.isconfirmed and lastSignalBar == bar_index, "Close Short Signal", "MarkitTick — Close Short")

// ── VISUALS ─────────────────────────────────────────────────────
var line[]  nodeHighLines  = array.new_line(0)
var label[] nodeHighLbls   = array.new_label(0)
var line[]  nodeLowLines   = array.new_line(0)
var label[] nodeLowLbls    = array.new_label(0)

f_clearNodeDrawings(line[] lineArr, label[] lblArr) =>
    if array.size(lineArr) > 0
        for i = 0 to array.size(lineArr) - 1
            line.delete(array.get(lineArr, i))
    if array.size(lblArr) > 0
        for i = 0 to array.size(lblArr) - 1
            label.delete(array.get(lblArr, i))
    array.clear(lineArr)
    array.clear(lblArr)

f_topNodeIndices(int[] strArr) =>
    int[] idxArr = array.new_int(0)
    if array.size(strArr) > 0
        for i = 0 to array.size(strArr) - 1
            if array.get(strArr, i) >= i_minStrength
                array.push(idxArr, i)
        if array.size(idxArr) >= 2
            for a = 0 to array.size(idxArr) - 2
                for b = 0 to array.size(idxArr) - 2 - a
                    if array.get(strArr, array.get(idxArr, b)) < array.get(strArr, array.get(idxArr, b + 1))
                        int tmp = array.get(idxArr, b)
                        array.set(idxArr, b, array.get(idxArr, b + 1))
                        array.set(idxArr, b + 1, tmp)
        while array.size(idxArr) > i_maxNodes
            array.pop(idxArr)
    idxArr

f_drawNode(float[] priceArr, int[] barArr, int[] strArr, bool isHigh, line[] lineArr, label[] lblArr) =>
    f_clearNodeDrawings(lineArr, lblArr)
    if i_showNodes
        int[] topIdx = f_topNodeIndices(strArr)
        if array.size(topIdx) > 0
            for k = 0 to array.size(topIdx) - 1
                int i = array.get(topIdx, k)
                int st = array.get(strArr, i)
                float px = array.get(priceArr, i)
                int bx = array.get(barArr, i)
                int x2 = math.min(bx + i_nodeExtBars, bar_index + i_nodeExtBars)
                color nodeCol = isHigh ? c_bearNode : c_bullNode
                ln = line.new(bx, px, x2, px, color=color.new(nodeCol, 100 - st * 15), width=1)
                array.push(lineArr, ln)
                if i_showLabels
                    lb = label.new(x2, px, "◆×" + str.tostring(st), style=isHigh ? label.style_label_down : label.style_label_up, color=color.new(nodeCol, 20), textcolor=c_nodeLabel, size=size.small)
                    array.push(lblArr, lb)

if barstate.isconfirmed
    f_drawNode(nodeHighPrices, nodeHighBars, nodeHighStr, true, nodeHighLines, nodeHighLbls)
    f_drawNode(nodeLowPrices, nodeLowBars, nodeLowStr, false, nodeLowLines, nodeLowLbls)

var line slLine = na
var line entryLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label slLbl = na
var label entryLbl = na
var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na
var linefill riskFill = na
var linefill rewardFill = na

f_deleteLevels() =>
    line.delete(slLine)
    line.delete(entryLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLbl)
    label.delete(entryLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    linefill.delete(riskFill)
    linefill.delete(rewardFill)

if i_showTradeBox and lockedTradeJustClosed
    f_deleteLevels()

if i_showTradeBox and (longSignal or shortSignal) and barstate.isconfirmed and lastSignalBar == bar_index
    f_deleteLevels()
    int x2 = bar_index + 50
    slLine := line.new(bar_index, slPrice, x2, slPrice, color=c_slLine, width=2)
    entryLine := line.new(bar_index, entryPrice, x2, entryPrice, color=c_entryLine, style=line.style_dashed, width=1)
    tp1Line := line.new(bar_index, tp1Price, x2, tp1Price, color=c_tp1Line, style=line.style_dashed, width=1)
    tp2Line := line.new(bar_index, tp2Price, x2, tp2Price, color=c_tp2Line, style=line.style_dashed, width=1)
    tp3Line := line.new(bar_index, tp3Price, x2, tp3Price, color=c_tp3Line, style=line.style_dashed, width=1)
    slLbl := label.new(x2, slPrice, "✕ SL " + str.tostring(slPrice, format.mintick), style=label.style_label_left, color=c_slLine, textcolor=c_levelLblTxt, size=size.small)
    entryLbl := label.new(x2, entryPrice, "▶ Entry " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=c_entryLine, textcolor=c_levelLblTxt, size=size.small)
    tp1Lbl := label.new(x2, tp1Price, "◆ TP1 " + str.tostring(tp1Price, format.mintick), style=label.style_label_left, color=c_tp1Line, textcolor=c_levelLblTxt, size=size.small)
    tp2Lbl := label.new(x2, tp2Price, "✦ TP2 " + str.tostring(tp2Price, format.mintick), style=label.style_label_left, color=c_tp2Line, textcolor=c_levelLblTxt, size=size.small)
    tp3Lbl := label.new(x2, tp3Price, "◆ TP3 " + str.tostring(tp3Price, format.mintick), style=label.style_label_left, color=c_tp3Line, textcolor=c_levelLblTxt, size=size.small)
    riskFill := linefill.new(slLine, entryLine, c_riskFill)
    rewardFill := linefill.new(entryLine, tp3Line, c_rewardFill)

if i_showTradeBox and not lockedTradeJustClosed and not na(slLine) and not na(lastSignalBar) and (lockedTradeActive or bar_index <= lastSignalBar + 50)
    int _extX = lockedTradeActive ? bar_index + 50 : lastSignalBar + 50
    line.set_x2(slLine, _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line, _extX)
    line.set_x2(tp2Line, _extX)
    line.set_x2(tp3Line, _extX)
    label.set_x(slLbl, _extX)
    label.set_x(entryLbl, _extX)
    label.set_x(tp1Lbl, _extX)
    label.set_x(tp2Lbl, _extX)
    label.set_x(tp3Lbl, _extX)

// ── DASHBOARD ───────────────────────────────────────────────────
f_barColor(float pct) =>
    pct >= 0.66 ? c_barGreen : pct >= 0.33 ? c_barYellow : c_barRed

f_bar(float val, float maxVal) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"

dashPosMap = i_dashPos == "Top Right" ? position.top_right : i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table dash = table.new(dashPosMap, 2, 9, bgcolor=c_dashBg, border_width=1)

if i_showDash and barstate.isconfirmed
    table.cell(dash, 0, 0, "FTCN — MarkitTick", text_color=c_dashValTxt, bgcolor=c_dashHeader, text_size=size.normal)
    table.cell(dash, 1, 0, "", bgcolor=c_dashHeader)

    table.cell(dash, 0, 1, "Bias", text_color=c_dashLblTxt, bgcolor=c_dashLblBg, text_size=size.small)
    biasTxt = tradeDir == 1 ? "▲ LONG" : tradeDir == -1 ? "▼ SHORT" : "— NONE"
    biasCol = tradeDir == 1 ? c_bullNode : tradeDir == -1 ? c_bearNode : c_biasNeut
    table.cell(dash, 1, 1, biasTxt, text_color=biasCol, bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 2, "Bull Node", text_color=c_dashLblTxt, bgcolor=c_dashLblBg, text_size=size.small)
    table.cell(dash, 1, 2, na(nearestBullNode) ? "—" : str.tostring(nearestBullNode, format.mintick), text_color=c_dashValTxt, bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 3, "Bull Strength", text_color=c_dashLblTxt, bgcolor=c_dashLblBg, text_size=size.small)
    bullPct = nearestBullStr / 4.0
    table.cell(dash, 1, 3, f_bar(nearestBullStr, 4.0), text_color=f_barColor(bullPct), bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 4, "Bear Node", text_color=c_dashLblTxt, bgcolor=c_dashLblBg, text_size=size.small)
    table.cell(dash, 1, 4, na(nearestBearNode) ? "—" : str.tostring(nearestBearNode, format.mintick), text_color=c_dashValTxt, bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 5, "Bear Strength", text_color=c_dashLblTxt, bgcolor=c_dashLblBg, text_size=size.small)
    bearPct = nearestBearStr / 4.0
    table.cell(dash, 1, 5, f_bar(nearestBearStr, 4.0), text_color=f_barColor(bearPct), bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 6, "ATR", text_color=c_dashLblTxt, bgcolor=c_dashLblBg, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(atrVal, format.mintick), text_color=c_dashValTxt, bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 7, "Active SL", text_color=c_dashLblTxt, bgcolor=c_dashLblBg, text_size=size.small)
    table.cell(dash, 1, 7, na(slPrice) ? "—" : str.tostring(slPrice, format.mintick), text_color=c_slLine, bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 8, "Active TP1", text_color=c_dashLblTxt, bgcolor=c_dashLblBg, text_size=size.small)
    table.cell(dash, 1, 8, na(tp1Price) ? "—" : str.tostring(tp1Price, format.mintick), text_color=c_tp1Line, bgcolor=c_dashValBg, text_size=size.small)
````
