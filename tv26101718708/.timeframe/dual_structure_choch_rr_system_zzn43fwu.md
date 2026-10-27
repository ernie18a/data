# Dual Structure CHoCH RR system

- url: https://www.tradingview.com/script/zZn43fwU-Dual-Structure-CHoCH-RR-system/
- type: indicator
- pine_id: PUB;4ddf0463bf8b4a59809601fc35aeec3b
- version: 2.0

## Description

📊 Dual Structure CHoCH RR System

🔷 OVERVIEW
Dual Structure CHoCH RR System is a market structure and trade planning tool designed to detect Change of Character (CHoCH) across two structural layers: Internal Structure and Swing Structure.

The script combines CHoCH detection, automatic risk-reward projection, pivot or ATR-based stop loss logic, candle highlighting, alerts, and a multi-timeframe trend dashboard into one clean workflow.

Instead of only marking structure breaks, this tool helps traders turn structural shifts into organized trade plans with clear entry, stop loss, take profit, and higher-timeframe context.


🔷 CORE CONCEPT
Dual Structure CHoCH RR System is built around CHoCH, or Change of Character.

A CHoCH forms when price breaks a previous structural high or low after trending in the opposite direction. This type of break can suggest that market behavior is changing and that a possible directional shift may be developing.

The script separates CHoCH into two structural layers:

Internal CHoCH — Shorter-term structure shifts using faster pivot detection.

https://www.tradingview.com/x/PvGb7qPP/

Swing CHoCH — Broader structure shifts using larger pivot detection.

https://www.tradingview.com/x/OQhBpnOw/

This dual-structure approach allows traders to compare smaller internal shifts with larger swing-level market transitions.


🔷 HOW IT WORKS
The script continuously scans market structure using two independent pivot systems: one for Internal Structure and one for Swing Structure.

https://www.tradingview.com/x/ijrgBiVE/

Each structure layer stores the most recent valid high and low, then monitors whether price breaks those levels. When a break happens after the opposite structure direction was active, the script identifies it as a CHoCH event.

Internal Structure is designed to react faster to short-term shifts, while Swing Structure filters for broader market transitions. This allows the chart to show both early structure changes and more significant directional shifts without mixing them into one signal type.

Break Confirmation

The script provides two confirmation modes:

• Close Confirmation — the candle must close beyond the previous structure level  
• Wick Confirmation — the candle only needs to trade beyond the previous structure level  

Close confirmation gives stricter structure validation, while wick confirmation provides faster detection of liquidity sweeps or early breaks.

Separate Structure Plotting

Internal and Swing CHoCH events are displayed with different visual styles so traders can quickly identify which type of structure has changed.

• Internal CHoCH highlights faster, more reactive shifts  
• Swing CHoCH highlights larger, more meaningful structure transitions  

This separation helps traders avoid treating every minor structure break the same as a major market shift.


🔷 RR TRADE PLANNING SYSTEM
When a valid CHoCH is detected, the script can automatically build and plot a complete risk-reward setup on the chart.

RR Trigger

Users can choose which CHoCH type activates the RR plotting system:

• Internal — plots RR setups only when an Internal CHoCH is detected  

https://www.tradingview.com/x/S4rKa2Ph/

• Swing — plots RR setups only when a Swing CHoCH is detected  

https://www.tradingview.com/x/xQwoLzHy/

• Both — plots RR setups from either Internal or Swing CHoCH signals  

For each valid setup:

• Entry = current price at CHoCH confirmation  
• Stop Loss = selected pivot level or ATR-based stop  
• Take Profit = calculated using the selected Risk:Reward ratio  

The plotted RR layout includes:

• Entry line and label  
• Stop Loss line and label  
• Take Profit zone and label  
• Risk area between entry and stop loss  

This gives each CHoCH signal a predefined trade structure, helping traders evaluate risk, reward, and invalidation before entering a position.


🔷 STOP LOSS OPTIONS
The script includes two stop loss methods:

Pivot Stop Loss
Uses a previous internal or swing pivot as the invalidation level.

ATR Stop Loss
Uses an ATR-based distance from entry, allowing the stop loss to adapt to current market volatility.

Users can also choose the stop loss pivot source:

• Auto — uses the same structure type that triggered the RR setup  
• Internal — uses internal pivot levels for a tighter structure-based stop  
• Swing — uses swing pivot levels for a broader structure-based stop  

A tick buffer can also be added beyond the selected pivot, giving the stop loss extra spacing from the structure level.


🔷 MULTI-TIMEFRAME DASHBOARD
The MTF Dashboard displays directional bias across multiple timeframes:

https://www.tradingview.com/x/qVRwwgVK/

• 1m  
• 5m  
• 15m  
• 1H  
• 4H  
• 1D  

Each timeframe shows one of three states:

• BULLISH  
• BEARISH  
• NEUTRAL  

The dashboard can use either Internal Structure or Swing Structure as the bias source.

This helps traders compare the current CHoCH signal with broader market direction and avoid taking trades against higher-timeframe structure.


🔷 KEY FEATURES
Dual Structure CHoCH — Detects both internal and swing Change of Character events.

Automatic RR Projection — Builds entry, stop loss, and take profit levels from valid CHoCH signals.

Flexible RR Trigger — Choose whether RR setups are created from Internal CHoCH, Swing CHoCH, or both.

Pivot or ATR Stop Loss — Use structure-based invalidation or volatility-based stop placement.

MTF Bias Dashboard — View bullish, bearish, or neutral structure bias across multiple timeframes.

CHoCH Candle Coloring — Highlight candles where internal or swing CHoCH events occur.

Optional Pivot Levels — Display internal and swing pivot levels for additional structure context.

Custom Visual Styling — Adjust colors for CHoCH lines, candles, RR labels, and dashboard blocks.

Alerts Included — Alert conditions are available for CHoCH signals and RR setups.


🔷 HOW TO USE
A common workflow is:

• Wait for a new Internal or Swing CHoCH  
• Check whether the RR setup gives a clean risk-reward structure  
• Review the stop loss position and invalidation level  
• Use the MTF Dashboard to confirm broader market direction  
• Prefer setups where lower-timeframe CHoCH aligns with higher-timeframe bias  

Example:

https://www.tradingview.com/x/KnjUMeQj/

For 1-minute trading, a bullish Internal CHoCH may carry more weight when the 5m, 15m, and 1H dashboard bias are also bullish.

If the 1-minute chart gives a bullish CHoCH but the 15m and 1H remain bearish, traders may treat the setup more cautiously, since it may only represent a short-term reaction against the broader structure.


🔷 VISUAL LOGIC
Internal CHoCH — Displayed as shorter-term structure shifts.

Swing CHoCH — Displayed as larger structure changes.

Bullish CHoCH — Marks a potential shift from bearish to bullish structure.

Bearish CHoCH — Marks a potential shift from bullish to bearish structure.

Entry Line — Shows the trade reference price.

Stop Loss Line — Shows the invalidation level.

Take Profit Zone — Displays the projected reward area.

Risk Area — Highlights the distance between entry and stop loss.

MTF Dashboard — Shows structure bias across selected timeframes.


🔷 SETTINGS
Internal Pivot Length — Controls sensitivity for internal structure detection.

Swing Pivot Length — Controls sensitivity for broader swing structure detection.

Break Confirmation — Choose Close or Wick confirmation.

RR Trigger — Select Internal, Swing, or Both CHoCH types for RR setups.

Stop Loss Type — Choose Pivot or ATR stop loss.

SL Pivot Source — Select Auto, Internal, or Swing pivot source.

Risk:Reward Ratio — Controls take profit projection.

ATR Multiplier — Adjusts ATR stop loss distance.

MTF Bias Source — Choose whether dashboard bias is based on Internal or Swing structure.

Dashboard Position — Move the MTF table to any chart corner.

Candle Coloring — Enable or disable CHoCH candle highlighting.


🔷 PURPOSE
Dual Structure CHoCH RR System is designed to help traders move from raw structure breaks to organized trade planning.

It helps traders:

• Detect possible market character shifts  
• Separate internal structure from swing structure  
• Build consistent RR-based trade plans  
• Visualize entry, stop loss, and take profit levels  
• Compare signals with multi-timeframe structure bias  
• Improve discipline and consistency in trade evaluation  


🔷 IMPORTANT NOTES
• This indicator does not guarantee profits and should not be used in isolation  
• Market conditions can vary; always apply proper risk management  
• Past performance does not indicate future results  


🔷 DISCLAIMER
This script is for educational and informational purposes only.

It does not constitute financial advice. Always do your own analysis before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © julzALGO

//@version=6
indicator("Dual Structure CHoCH RR system", shorttitle="CHoCH RR", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=5000)

// -----------------------------------------------------------------------------
// Structure Inputs
// -----------------------------------------------------------------------------
grpStructure = "MARKET STRUCTURE"

showInternalChoch = input.bool(true, "Internal CHoCH", inline="i", group=grpStructure)
internalPivotLen  = input.int(10, "", inline="i", minval=2, group=grpStructure)

showSwingChoch = input.bool(true, "Swing CHoCH", inline="s", group=grpStructure)
swingPivotLen  = input.int(50, "", inline="s", minval=2, group=grpStructure)

confirmMode = input.string("Close", "Break Confirmation", options=["Close", "Wick"], group=grpStructure)

internalBullColor = input.color(#089981, "Internal Bull", inline="ic", group=grpStructure)
internalBearColor = input.color(#f23646a2, "Internal Bear", inline="ic", group=grpStructure)

swingBullColor = input.color(#089981, "Swing Bull", inline="sc", group=grpStructure)
swingBearColor = input.color(#f23646c4, "Swing Bear", inline="sc", group=grpStructure)

showInternalPivots = input.bool(false, "Show Internal Pivot Levels", group=grpStructure)
showSwingPivots    = input.bool(false, "Show Swing Pivot Levels", group=grpStructure)

maxMarks = input.int(20, "Max CHoCH Marks", minval=10, maxval=300, group=grpStructure)

// -----------------------------------------------------------------------------
// RR Inputs
// -----------------------------------------------------------------------------
grpRR = "RR SYSTEM"

showRR      = input.bool(true, "Show RR On CHoCH", group=grpRR)
rrTrigger   = input.string("Internal", "RR Trigger", options=["Internal", "Swing", "Both"], group=grpRR)
showSignal  = input.bool(true, "Show CHoCH Signals", group=grpRR)

slType             = input.string("Pivot", "Stop Loss Type", options=["ATR", "Pivot"], group=grpRR)
slPivotSource      = input.string("Auto", "SL Pivot Source", options=["Auto", "Internal", "Swing"], group=grpRR)
slPivotBufferTicks = input.int(0, "SL Pivot Buffer (ticks)", minval=0, group=grpRR)

rr          = input.float(2.0, "Risk:Reward", minval=0.1, step=0.1, group=grpRR)
slMult      = input.float(3.0, "ATR Multiplier", minval=0.1, step=0.1, group=grpRR)
labelOffset = input.int(10, "Label Offset Bars", minval=1, group=grpRR)

entryLabelColor = input.color(color.rgb(76, 162, 175), "Entry Label", group=grpRR)
stopColor       = input.color(color.rgb(149, 61, 216), "Stop", group=grpRR)
tpColor         = input.color(color.rgb(76, 162, 175), "TP", group=grpRR)

// -----------------------------------------------------------------------------
// Candle Coloring
// -----------------------------------------------------------------------------
grpCandle = "CANDLE COLOR"

colorChochCandles = input.bool(true, "Color CHoCH Candles", group=grpCandle)
colorInternalCandles = input.bool(true, "Color Internal CHoCH Candles", group=grpCandle)
colorSwingCandles = input.bool(true, "Color Swing CHoCH Candles", group=grpCandle)

internalBullCandleColor = input.color(color.rgb(76, 162, 175), "Internal Bull Candle", group=grpCandle)
internalBearCandleColor = input.color(color.new(#f23646, 25), "Internal Bear Candle", group=grpCandle)

swingBullCandleColor = input.color(color.rgb(76, 162, 175, 42), "Swing Bull Candle", group=grpCandle)
swingBearCandleColor = input.color(color.new(#fa3b3b, 46), "Swing Bear Candle", group=grpCandle)

// -----------------------------------------------------------------------------
// Volumetric Order Block Inputs
// -----------------------------------------------------------------------------
grpFlowZones = "VOLUMETRIC ORDER BLOCKS"
showVolumetricBlocks = input.bool(true, "Show Internal VOB", inline="vz1", group=grpFlowZones)
visibleBlockCount = input.int(10, "", inline="vz1", group=grpFlowZones, minval=1, maxval=10)
showInternalActivity = input.bool(true, "Buy/Sell Activity", inline="vz2", group=grpFlowZones)
activityBuyColor = input.color(color.new(color.rgb(0, 176, 230), 50), "", inline="vz2", group=grpFlowZones)
activitySellColor = input.color(color.new(color.rgb(137, 82, 255), 50), "", inline="vz2", group=grpFlowZones)
internalBlockBullFill = input.color(color.new(color.rgb(0, 176, 230), 90), "Internal Bull VOB", group=grpFlowZones)
internalBlockBearFill = input.color(color.new(color.rgb(137, 82, 255), 90), "Internal Bear VOB", group=grpFlowZones)
blockMitigationMode = input.string("Absolute", "Mitigation", options=["Absolute", "Middle"], group=grpFlowZones)
showZoneMetrics = input.bool(true, "Show Metrics", group=grpFlowZones)
extendedBlockWidth = input.int(15, "VOB Extend Width (bars)", minval=1, group=grpFlowZones)

// -----------------------------------------------------------------------------
// MTF Dashboard Inputs
// -----------------------------------------------------------------------------
grpMTF = "MTF DASHBOARD"

showMTFDashboard = input.bool(true, "Show MTF Dashboard", group=grpMTF)
mtfBiasSource = input.string("Swing", "MTF Bias Source", options=["Internal", "Swing"], group=grpMTF)
mtfDashboardPos = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpMTF)

// -----------------------------------------------------------------------------
// Volumetric Order Block Core
// -----------------------------------------------------------------------------
type bar_t
    float o = open
    float c = close
    float h = high
    float l = low
    float v = volume
    int n = bar_index
    int t = time

type obC
    float[] top
    float[] btm
    int[] left
    float[] avg
    float[] dV
    float[] cV
    int[] wM
    int[] blVP
    int[] brVP
    int[] dir
    float[] h
    float[] l
    int[] n
    float[] buyV
    float[] sellV

type obD
    box[] ob
    box[] eOB
    box[] blB
    box[] brB

bar_t b = bar_t.new()

var int[] lastBullBreakBarInternal = array.new<int>(1, na)
var int[] lastBearBreakBarInternal = array.new<int>(1, na)

fmtVol(v) =>
    float av = math.abs(v)
    av >= 1000000000 ? str.tostring(av / 1000000000, "#.##") + "B" :
     av >= 1000000 ? str.tostring(av / 1000000, "#.##") + "M" :
     av >= 1000 ? str.tostring(av / 1000, "#.#") + "K" :
     str.tostring(av, "#")

method eB(box[] boxes, bool ext, color css) =>
    array.unshift(
         boxes,
         box.new(
             na,
             na,
             na,
             na,
             xloc=xloc.bar_time,
             text_font_family=font.family_monospace,
             extend=ext ? extend.right : extend.none,
             border_color=color.new(color.white, 100),
             bgcolor=css,
             border_width=1
         )
    )

method drawVOB(bool cdn, bool bull, color css, int loc) =>
    int spanBars = 1

    var obC obj = obC.new(
         array.new<float>(), array.new<float>(), array.new<int>(), array.new<float>(), array.new<float>(), array.new<float>(),
         array.new<int>(), array.new<int>(), array.new<int>(), array.new<int>(), array.new<float>(), array.new<float>(), array.new<int>(),
         array.new<float>(), array.new<float>()
    )

    var obD draw = obD.new(array.new<box>(), array.new<box>(), array.new<box>(), array.new<box>())

    if barstate.isfirst
        for i = 0 to visibleBlockCount - 1
            draw.ob.eB(false, css)
            draw.blB.eB(false, activityBuyColor)
            draw.brB.eB(false, activitySellColor)
            draw.eOB.eB(false, css)

    float pos = bull ? high : low

    if cdn and not na(loc)
        array.clear(obj.h)
        array.clear(obj.l)
        array.clear(obj.n)

        int span = math.abs(loc - b.n)
        spanBars := math.min(math.max(1, span - 1), math.min(bar_index, 5000))

        for i = 1 to spanBars
            array.push(obj.h, high[i])
            array.push(obj.l, low[i])
            array.push(obj.n, time[i])

        if array.size(obj.l) > 0
            int iU = array.indexof(obj.l, array.min(obj.l)) + 1
            int iD = array.indexof(obj.h, array.max(obj.h)) + 1

            array.unshift(obj.dir, bull ? (close[iU] > open[iU] ? 1 : -1) : (close[iD] > open[iD] ? 1 : -1))
            array.unshift(obj.top, bull ? pos[iU] : array.max(obj.h))
            array.unshift(obj.btm, bull ? array.min(obj.l) : pos[iD])

            int leftIdx = bull ? array.get(obj.n, array.indexof(obj.l, array.min(obj.l))) : array.get(obj.n, array.indexof(obj.h, array.max(obj.h)))
            array.unshift(obj.left, leftIdx)
            array.unshift(obj.avg, math.avg(array.first(obj.top), array.first(obj.btm)))
            array.unshift(obj.cV, bull ? volume[iU] : volume[iD])

            float zoneBuyV = 0.0
            float zoneSellV = 0.0

            for k = 0 to spanBars
                float trK = math.max(high[k] - low[k], syminfo.mintick)
                float bodyK = close[k] - open[k]
                float upperWickK = high[k] - math.max(open[k], close[k])
                float lowerWickK = math.min(open[k], close[k]) - low[k]
                float totalCandleK = math.max(math.abs(bodyK) + upperWickK + lowerWickK, syminfo.mintick)

                float bodyRatioK = bodyK / trK
                float wickBuyK = lowerWickK / totalCandleK
                float wickSellK = upperWickK / totalCandleK
                float closePosK = (close[k] - low[k]) / trK

                float buyStrengthK = closePosK * 0.6 + wickBuyK * 0.25 + (bodyRatioK > 0 ? bodyRatioK * 0.35 : 0.0)
                float sellStrengthK = (1.0 - closePosK) * 0.6 + wickSellK * 0.25 + (bodyRatioK < 0 ? -bodyRatioK * 0.35 : 0.0)
                float totalStrengthK = buyStrengthK + sellStrengthK

                zoneBuyV += totalStrengthK > 0 ? volume[k] * buyStrengthK / totalStrengthK : 0.0
                zoneSellV += totalStrengthK > 0 ? volume[k] * sellStrengthK / totalStrengthK : 0.0

            array.unshift(obj.buyV, zoneBuyV)
            array.unshift(obj.sellV, zoneSellV)
            array.unshift(obj.blVP, 0)
            array.unshift(obj.brVP, 0)
            array.unshift(obj.wM, 1)

            if array.size(obj.avg) > 1
                int rmP = 0
                bool condOverlap = bull ? array.first(obj.btm) < array.get(obj.top, 1) : array.first(obj.top) > array.get(obj.btm, 1)

                if condOverlap
                    array.remove(obj.wM, rmP)
                    array.remove(obj.cV, rmP)
                    array.remove(obj.dir, rmP)
                    array.remove(obj.top, rmP)
                    array.remove(obj.avg, rmP)
                    array.remove(obj.btm, rmP)
                    array.remove(obj.left, rmP)
                    array.remove(obj.blVP, rmP)
                    array.remove(obj.brVP, rmP)
                    array.remove(obj.buyV, rmP)
                    array.remove(obj.sellV, rmP)

    if barstate.isconfirmed and array.size(obj.avg) > 0
        bool isMiddle = blockMitigationMode == "Middle"

        for i = array.size(obj.avg) - 1 to 0
            float tg = isMiddle ? array.get(obj.avg, i) : bull ? array.get(obj.btm, i) : array.get(obj.top, i)
            bool broke = bull ? close < tg : close > tg

            if broke
                array.remove(obj.wM, i)
                array.remove(obj.cV, i)
                array.remove(obj.dir, i)
                array.remove(obj.top, i)
                array.remove(obj.avg, i)
                array.remove(obj.btm, i)
                array.remove(obj.left, i)
                array.remove(obj.blVP, i)
                array.remove(obj.brVP, i)
                array.remove(obj.buyV, i)
                array.remove(obj.sellV, i)

    if barstate.islast and array.size(obj.avg) > 0
        float totalZoneVol = 0.0
        array.clear(obj.dV)

        int seq = math.min(visibleBlockCount - 1, array.size(obj.avg) - 1)

        for j = 0 to seq
            totalZoneVol += array.get(obj.cV, j)

        if totalZoneVol > 0
            for y = 0 to seq
                float pct = math.floor(array.get(obj.cV, y) / totalZoneVol * 100)
                array.unshift(obj.dV, pct)

            array.reverse(obj.dV)

        for i = 0 to seq
            box dOB = array.get(draw.ob, i)
            box dblB = array.get(draw.blB, i)
            box dbrB = array.get(draw.brB, i)
            box deOB = array.get(draw.eOB, i)

            float topi = array.get(obj.top, i)
            float btmi = array.get(obj.btm, i)
            float avgi = array.get(obj.avg, i)
            int left = array.get(obj.left, i)

            int barMs = math.max(1, nz(time - time[1], 1))
            int rightTime = b.t + barMs * extendedBlockWidth

            box.set_lefttop(dOB, left, topi)
            box.set_rightbottom(dOB, b.t, btmi)

            box.set_lefttop(deOB, b.t, topi)
            box.set_rightbottom(deOB, rightTime, btmi)

            float zoneBuyVDraw = array.size(obj.buyV) > i ? array.get(obj.buyV, i) : 0.0
            float zoneSellVDraw = array.size(obj.sellV) > i ? array.get(obj.sellV, i) : 0.0
            float zoneTotVDraw = math.max(zoneBuyVDraw + zoneSellVDraw, 1.0)

            float buyFracDraw = zoneBuyVDraw / zoneTotVDraw
            float sellFracDraw = zoneSellVDraw / zoneTotVDraw
            float imbalancePctDraw = math.abs(zoneBuyVDraw - zoneSellVDraw) / zoneTotVDraw * 100.0

            if showInternalActivity
                int zoneSpanMsDraw = math.max(1, b.t - left)
                int buyRightDraw = math.max(left + 1, left + int(math.round(zoneSpanMsDraw * buyFracDraw)))
                int sellRightDraw = math.max(left + 1, left + int(math.round(zoneSpanMsDraw * sellFracDraw)))

                box.set_lefttop(dblB, left, topi)
                box.set_rightbottom(dblB, buyRightDraw, avgi)
                box.set_text(dblB, "B: " + fmtVol(zoneBuyVDraw))
                box.set_text_size(dblB, size.tiny)
                box.set_text_halign(dblB, text.align_center)
                box.set_text_valign(dblB, text.align_center)
                box.set_text_color(dblB, chart.fg_color)

                box.set_lefttop(dbrB, left, avgi)
                box.set_rightbottom(dbrB, sellRightDraw, btmi)
                box.set_text(dbrB, "S: " + fmtVol(zoneSellVDraw))
                box.set_text_size(dbrB, size.tiny)
                box.set_text_halign(dbrB, text.align_center)
                box.set_text_valign(dbrB, text.align_center)
                box.set_text_color(dbrB, chart.fg_color)
            else
                box.set_text(dblB, "")
                box.set_text(dbrB, "")

            box.set_bgcolor(deOB, na)
            box.set_border_color(deOB, na)
            box.set_text(deOB, showZoneMetrics ? str.tostring(math.round(imbalancePctDraw)) + "%" : "")
            box.set_text_size(deOB, size.small)
            box.set_text_halign(deOB, text.align_left)
            box.set_text_valign(deOB, text.align_center)
            box.set_text_color(deOB, color.new(css, 0))

// -----------------------------------------------------------------------------
// Pivots
// -----------------------------------------------------------------------------
iH = ta.pivothigh(high, internalPivotLen, internalPivotLen)
iL = ta.pivotlow(low, internalPivotLen, internalPivotLen)

sH = ta.pivothigh(high, swingPivotLen, swingPivotLen)
sL = ta.pivotlow(low, swingPivotLen, swingPivotLen)

var float iLastHigh = na
var float iLastLow = na
var int iLastHighBar = na
var int iLastLowBar = na
var bool iHighTaken = false
var bool iLowTaken = false
var int iTrend = 0

var float sLastHigh = na
var float sLastLow = na
var int sLastHighBar = na
var int sLastLowBar = na
var bool sHighTaken = false
var bool sLowTaken = false
var int sTrend = 0

if not na(iH)
    iLastHigh := iH
    iLastHighBar := bar_index - internalPivotLen
    iHighTaken := false

if not na(iL)
    iLastLow := iL
    iLastLowBar := bar_index - internalPivotLen
    iLowTaken := false

if not na(sH)
    sLastHigh := sH
    sLastHighBar := bar_index - swingPivotLen
    sHighTaken := false

if not na(sL)
    sLastLow := sL
    sLastLowBar := bar_index - swingPivotLen
    sLowTaken := false

// -----------------------------------------------------------------------------
// Break Logic
// -----------------------------------------------------------------------------
iBullCloseBreak = ta.crossover(close, nz(iLastHigh, close + 1e10))
iBearCloseBreak = ta.crossunder(close, nz(iLastLow, close - 1e10))

sBullCloseBreak = ta.crossover(close, nz(sLastHigh, close + 1e10))
sBearCloseBreak = ta.crossunder(close, nz(sLastLow, close - 1e10))

iBullWickBreak = not na(iLastHigh) and high > iLastHigh and high[1] <= iLastHigh
iBearWickBreak = not na(iLastLow) and low < iLastLow and low[1] >= iLastLow

sBullWickBreak = not na(sLastHigh) and high > sLastHigh and high[1] <= sLastHigh
sBearWickBreak = not na(sLastLow) and low < sLastLow and low[1] >= sLastLow

iBullBreak = confirmMode == "Close" ? iBullCloseBreak : iBullWickBreak
iBearBreak = confirmMode == "Close" ? iBearCloseBreak : iBearWickBreak

sBullBreak = confirmMode == "Close" ? sBullCloseBreak : sBullWickBreak
sBearBreak = confirmMode == "Close" ? sBearCloseBreak : sBearWickBreak

iBullChoch = showInternalChoch and iBullBreak and not iHighTaken and iTrend == -1
iBearChoch = showInternalChoch and iBearBreak and not iLowTaken and iTrend == 1

sBullChoch = showSwingChoch and sBullBreak and not sHighTaken and sTrend == -1
sBearChoch = showSwingChoch and sBearBreak and not sLowTaken and sTrend == 1

// -----------------------------------------------------------------------------
// CHoCH Drawing
// -----------------------------------------------------------------------------
var line[] chochLines = array.new<line>()
var label[] chochLabels = array.new<label>()

drawChoch(int x1, float y, bool isBull, bool isSwing) =>
    css = isSwing ? (isBull ? swingBullColor : swingBearColor) : (isBull ? internalBullColor : internalBearColor)
    txt = isSwing ? "Swing CHoCH" : "Internal CHoCH"
    lnStyle = isSwing ? line.style_solid : line.style_dashed
    lnWidth = isSwing ? 2 : 1
    lbSize = isSwing ? size.normal : size.small

    ln = line.new(x1, y, bar_index, y, color=css, width=lnWidth, style=lnStyle)

    lb = label.new(
         int(math.avg(x1, bar_index)),
         y,
         txt,
         color=color.new(color.white, 100),
         textcolor=css,
         style=isBull ? label.style_label_down : label.style_label_up,
         size=lbSize,
         text_font_family=font.family_monospace
    )

    array.push(chochLines, ln)
    array.push(chochLabels, lb)

    if array.size(chochLines) > maxMarks
        line.delete(array.shift(chochLines))

    if array.size(chochLabels) > maxMarks
        label.delete(array.shift(chochLabels))

// -----------------------------------------------------------------------------
// CHoCH Triggers
// -----------------------------------------------------------------------------
if iBullBreak and not iHighTaken
    if iBullChoch and not na(iLastHighBar)
        drawChoch(iLastHighBar, iLastHigh, true, false)
        array.set(lastBullBreakBarInternal, 0, bar_index)

    iTrend := 1
    iHighTaken := true

if iBearBreak and not iLowTaken
    if iBearChoch and not na(iLastLowBar)
        drawChoch(iLastLowBar, iLastLow, false, false)
        array.set(lastBearBreakBarInternal, 0, bar_index)

    iTrend := -1
    iLowTaken := true

if sBullBreak and not sHighTaken
    if sBullChoch and not na(sLastHighBar)
        drawChoch(sLastHighBar, sLastHigh, true, true)
        

    sTrend := 1
    sHighTaken := true

if sBearBreak and not sLowTaken
    if sBearChoch and not na(sLastLowBar)
        drawChoch(sLastLowBar, sLastLow, false, true)
        

    sTrend := -1
    sLowTaken := true

// -----------------------------------------------------------------------------
// RR System
// -----------------------------------------------------------------------------
atrRR = ta.atr(14)

buyInternalRR  = (rrTrigger == "Internal" or rrTrigger == "Both") and iBullChoch
sellInternalRR = (rrTrigger == "Internal" or rrTrigger == "Both") and iBearChoch

buySwingRR  = (rrTrigger == "Swing" or rrTrigger == "Both") and sBullChoch
sellSwingRR = (rrTrigger == "Swing" or rrTrigger == "Both") and sBearChoch

buyRR  = showRR and (buyInternalRR or buySwingRR)
sellRR = showRR and (sellInternalRR or sellSwingRR)

useSwingBuySL =
     slPivotSource == "Swing" ? true :
     slPivotSource == "Internal" ? false :
     buySwingRR

useSwingSellSL =
     slPivotSource == "Swing" ? true :
     slPivotSource == "Internal" ? false :
     sellSwingRR

var float entryPrice = na
var float SL = na
var float TP = na

var line entryLine = na
var line slLine = na
var box tpBox = na

var label entryLbl = na
var label slLbl = na
var label tpLbl = na

var linefill riskFill = na

if buyRR or sellRR
    entryPrice := close

    pivotSL = buyRR ? (useSwingBuySL ? sLastLow : iLastLow) : (useSwingSellSL ? sLastHigh : iLastHigh)
    pivotBuffer = syminfo.mintick * slPivotBufferTicks

    if slType == "ATR"
        SL := buyRR ? entryPrice - atrRR * slMult : entryPrice + atrRR * slMult
    else
        SL := buyRR ? pivotSL - pivotBuffer : pivotSL + pivotBuffer

    validSL = buyRR ? not na(SL) and SL < entryPrice : not na(SL) and SL > entryPrice

    if validSL
        risk = math.abs(entryPrice - SL)
        TP := buyRR ? entryPrice + risk * rr : entryPrice - risk * rr

        if not na(entryLine)
            line.delete(entryLine)
        if not na(slLine)
            line.delete(slLine)
        if not na(tpBox)
            box.delete(tpBox)
        if not na(riskFill)
            linefill.delete(riskFill)

        if not na(entryLbl)
            label.delete(entryLbl)
            entryLbl := na
        if not na(slLbl)
            label.delete(slLbl)
            slLbl := na
        if not na(tpLbl)
            label.delete(tpLbl)
            tpLbl := na

        rrEntryColor = buyRR ? (useSwingBuySL ? swingBullColor : internalBullColor) : (useSwingSellSL ? swingBearColor : internalBearColor)

        entryLine := line.new(bar_index, entryPrice, bar_index, entryPrice, color=rrEntryColor, width=1)
        slLine := line.new(bar_index, SL, bar_index, SL, color=stopColor, width=1)

        tpBox := box.new(
             bar_index, TP + atrRR * 0.20,
             bar_index, TP - atrRR * 0.20,
             bgcolor=color.new(tpColor, 85),
             border_color=color.new(tpColor, 50)
        )

        riskFill := linefill.new(entryLine, slLine, color.new(stopColor, 85))

if barstate.islast
    if not na(entryLine)
        line.set_x2(entryLine, bar_index)

    if not na(slLine)
        line.set_x2(slLine, bar_index)

    if not na(tpBox)
        box.set_right(tpBox, bar_index)

    if not na(entryLine) and not na(entryPrice)
        if na(entryLbl)
            entryLbl := label.new(
                 bar_index + labelOffset,
                 entryPrice,
                 "Entry: " + str.tostring(entryPrice, format.mintick),
                 style=label.style_label_left,
                 color=color.new(entryLabelColor, 40),
                 textcolor=color.white
            )
        else
            label.set_xy(entryLbl, bar_index + labelOffset, entryPrice)

    if not na(slLine) and not na(SL)
        if na(slLbl)
            slLbl := label.new(
                 bar_index + labelOffset,
                 SL,
                 "SL: " + str.tostring(SL, format.mintick),
                 style=label.style_label_left,
                 color=color.new(stopColor, 40),
                 textcolor=color.white
            )
        else
            label.set_xy(slLbl, bar_index + labelOffset, SL)

    if not na(tpBox) and not na(TP)
        if na(tpLbl)
            tpLbl := label.new(
                 bar_index + labelOffset,
                 TP,
                 "TP: " + str.tostring(TP, format.mintick),
                 style=label.style_label_left,
                 color=color.new(tpColor, 40),
                 textcolor=color.white
            )
        else
            label.set_xy(tpLbl, bar_index + labelOffset, TP)

// -----------------------------------------------------------------------------
// Volumetric Order Block Draw Calls
// -----------------------------------------------------------------------------
bool makeInternalBullVOB = showVolumetricBlocks and iBullChoch
bool makeInternalBearVOB = showVolumetricBlocks and iBearChoch

makeInternalBullVOB.drawVOB(true, internalBlockBullFill, iLastHighBar)
makeInternalBearVOB.drawVOB(false, internalBlockBearFill, iLastLowBar)


// -----------------------------------------------------------------------------
// MTF CHoCH Engine
// -----------------------------------------------------------------------------
f_mtfChoch() =>
    miH = ta.pivothigh(high, internalPivotLen, internalPivotLen)
    miL = ta.pivotlow(low, internalPivotLen, internalPivotLen)

    msH = ta.pivothigh(high, swingPivotLen, swingPivotLen)
    msL = ta.pivotlow(low, swingPivotLen, swingPivotLen)

    var float miLastHigh = na
    var float miLastLow = na
    var bool miHighTaken = false
    var bool miLowTaken = false
    var int miTrend = 0

    var float msLastHigh = na
    var float msLastLow = na
    var bool msHighTaken = false
    var bool msLowTaken = false
    var int msTrend = 0

    if not na(miH)
        miLastHigh := miH
        miHighTaken := false

    if not na(miL)
        miLastLow := miL
        miLowTaken := false

    if not na(msH)
        msLastHigh := msH
        msHighTaken := false

    if not na(msL)
        msLastLow := msL
        msLowTaken := false

    miBullCloseBreak = ta.crossover(close, nz(miLastHigh, close + 1e10))
    miBearCloseBreak = ta.crossunder(close, nz(miLastLow, close - 1e10))

    msBullCloseBreak = ta.crossover(close, nz(msLastHigh, close + 1e10))
    msBearCloseBreak = ta.crossunder(close, nz(msLastLow, close - 1e10))

    miBullWickBreak = not na(miLastHigh) and high > miLastHigh and high[1] <= miLastHigh
    miBearWickBreak = not na(miLastLow) and low < miLastLow and low[1] >= miLastLow

    msBullWickBreak = not na(msLastHigh) and high > msLastHigh and high[1] <= msLastHigh
    msBearWickBreak = not na(msLastLow) and low < msLastLow and low[1] >= msLastLow

    miBullBreak = confirmMode == "Close" ? miBullCloseBreak : miBullWickBreak
    miBearBreak = confirmMode == "Close" ? miBearCloseBreak : miBearWickBreak

    msBullBreak = confirmMode == "Close" ? msBullCloseBreak : msBullWickBreak
    msBearBreak = confirmMode == "Close" ? msBearCloseBreak : msBearWickBreak

    miBullChoch = showInternalChoch and miBullBreak and not miHighTaken and miTrend == -1
    miBearChoch = showInternalChoch and miBearBreak and not miLowTaken and miTrend == 1

    msBullChoch = showSwingChoch and msBullBreak and not msHighTaken and msTrend == -1
    msBearChoch = showSwingChoch and msBearBreak and not msLowTaken and msTrend == 1

    if miBullBreak and not miHighTaken
        miTrend := 1
        miHighTaken := true

    if miBearBreak and not miLowTaken
        miTrend := -1
        miLowTaken := true

    if msBullBreak and not msHighTaken
        msTrend := 1
        msHighTaken := true

    if msBearBreak and not msLowTaken
        msTrend := -1
        msLowTaken := true

    [miTrend, msTrend, miBullChoch, miBearChoch, msBullChoch, msBearChoch]


// -----------------------------------------------------------------------------
// Signals
// -----------------------------------------------------------------------------
plotshape(showSignal and iBullChoch, title="Internal Bullish CHoCH", location=location.belowbar, style=shape.triangleup, size=size.tiny, color=internalBullColor)
plotshape(showSignal and iBearChoch, title="Internal Bearish CHoCH", location=location.abovebar, style=shape.triangledown, size=size.tiny, color=internalBearColor)

plotshape(showSignal and sBullChoch, title="Swing Bullish CHoCH", location=location.belowbar, style=shape.triangleup, size=size.small, color=swingBullColor)
plotshape(showSignal and sBearChoch, title="Swing Bearish CHoCH", location=location.abovebar, style=shape.triangledown, size=size.small, color=swingBearColor)

// -----------------------------------------------------------------------------
// Optional Pivot Levels
// -----------------------------------------------------------------------------
plot(showInternalPivots ? iLastHigh : na, "Internal High Pivot", color=color.new(internalBullColor, 70), style=plot.style_linebr)
plot(showInternalPivots ? iLastLow : na, "Internal Low Pivot", color=color.new(internalBearColor, 70), style=plot.style_linebr)

plot(showSwingPivots ? sLastHigh : na, "Swing High Pivot", color=color.new(swingBullColor, 55), style=plot.style_linebr)
plot(showSwingPivots ? sLastLow : na, "Swing Low Pivot", color=color.new(swingBearColor, 55), style=plot.style_linebr)

// -----------------------------------------------------------------------------
// Candle Coloring
// -----------------------------------------------------------------------------
var color trendCandleColor = na

bullColorSignal = colorChochCandles and (
     (colorInternalCandles and iBullChoch) or
     (colorSwingCandles and sBullChoch)
)

bearColorSignal = colorChochCandles and (
     (colorInternalCandles and iBearChoch) or
     (colorSwingCandles and sBearChoch)
)

if bullColorSignal
    trendCandleColor := sBullChoch and colorSwingCandles ? swingBullCandleColor : internalBullCandleColor

if bearColorSignal
    trendCandleColor := sBearChoch and colorSwingCandles ? swingBearCandleColor : internalBearCandleColor

barcolor(colorChochCandles ? trendCandleColor : na)

// -----------------------------------------------------------------------------
// MTF Dashboard
// -----------------------------------------------------------------------------
mtfTableHeaderBg      = input.color(color.rgb(5, 7, 10), "Header BG", group=grpMTF)
mtfTableHeaderText    = input.color(color.white, "Header Text", group=grpMTF)

mtfTableSubHeaderBg   = input.color(color.rgb(22, 24, 30), "Sub Header BG", group=grpMTF)
mtfTableSubHeaderText = input.color(color.silver, "Sub Header Text", group=grpMTF)

mtfTableRowBg         = input.color(color.rgb(12, 14, 18), "TF Row BG", group=grpMTF)
mtfTableRowText       = input.color(color.white, "TF Row Text", group=grpMTF)

mtfTableBullBg        = input.color(color.rgb(16, 82, 74), "Bull Block BG", group=grpMTF)
mtfTableBullText      = input.color(color.rgb(120, 255, 220), "Bull Text", group=grpMTF)

mtfTableBearBg        = input.color(color.rgb(105, 30, 45), "Bear Block BG", group=grpMTF)
mtfTableBearText      = input.color(color.rgb(255, 155, 165), "Bear Text", group=grpMTF)

mtfTableNeutralBg     = input.color(color.rgb(45, 48, 55), "Neutral Block BG", group=grpMTF)
mtfTableNeutralText   = input.color(color.silver, "Neutral Text", group=grpMTF)

[iTrend1, sTrend1, iBull1, iBear1, sBull1, sBear1] = request.security(syminfo.tickerid, "1", f_mtfChoch(), lookahead=barmerge.lookahead_off)
[iTrend5, sTrend5, iBull5, iBear5, sBull5, sBear5] = request.security(syminfo.tickerid, "5", f_mtfChoch(), lookahead=barmerge.lookahead_off)
[iTrend15, sTrend15, iBull15, iBear15, sBull15, sBear15] = request.security(syminfo.tickerid, "15", f_mtfChoch(), lookahead=barmerge.lookahead_off)
[iTrend60, sTrend60, iBull60, iBear60, sBull60, sBear60] = request.security(syminfo.tickerid, "60", f_mtfChoch(), lookahead=barmerge.lookahead_off)
[iTrend240, sTrend240, iBull240, iBear240, sBull240, sBear240] = request.security(syminfo.tickerid, "240", f_mtfChoch(), lookahead=barmerge.lookahead_off)
[iTrendD, sTrendD, iBullD, iBearD, sBullD, sBearD] = request.security(syminfo.tickerid, "D", f_mtfChoch(), lookahead=barmerge.lookahead_off)

f_dirText(dir) =>
    dir == 1 ? "BULLISH" : dir == -1 ? "BEARISH" : "NEUTRAL"

f_dirBg(dir) =>
    dir == 1 ? mtfTableBullBg :
     dir == -1 ? mtfTableBearBg :
     mtfTableNeutralBg

f_dirTxtColor(dir) =>
    dir == 1 ? mtfTableBullText :
     dir == -1 ? mtfTableBearText :
     mtfTableNeutralText

mtfPos =
     mtfDashboardPos == "Top Left" ? position.top_left :
     mtfDashboardPos == "Bottom Right" ? position.bottom_right :
     mtfDashboardPos == "Bottom Left" ? position.bottom_left :
     position.top_right

var table mtfTable = table.new(
     mtfPos,
     2,
     8,
     frame_color=color.new(mtfTableHeaderText, 85),
     frame_width=1,
     border_color=color.new(mtfTableHeaderText, 90),
     border_width=1
)

if barstate.islast and not showMTFDashboard
    table.clear(mtfTable, 0, 0, 1, 7)

if barstate.islast and showMTFDashboard
    table.cell(mtfTable, 0, 0, "DUAL", bgcolor=mtfTableHeaderBg, text_color=mtfTableHeaderText, text_size=size.small)
    table.cell(mtfTable, 1, 0, "CHoCH RR", bgcolor=mtfTableHeaderBg, text_color=mtfTableHeaderText, text_size=size.small)

    table.cell(mtfTable, 0, 1, "TF", bgcolor=mtfTableSubHeaderBg, text_color=mtfTableSubHeaderText, text_size=size.small)
    table.cell(mtfTable, 1, 1, "BIAS", bgcolor=mtfTableSubHeaderBg, text_color=mtfTableSubHeaderText, text_size=size.small)

    dir1 = mtfBiasSource == "Internal" ? iTrend1 : sTrend1
    table.cell(mtfTable, 0, 2, "1m", bgcolor=mtfTableRowBg, text_color=mtfTableRowText, text_size=size.small)
    table.cell(mtfTable, 1, 2, f_dirText(dir1), bgcolor=f_dirBg(dir1), text_color=f_dirTxtColor(dir1), text_size=size.small)

    dir5 = mtfBiasSource == "Internal" ? iTrend5 : sTrend5
    table.cell(mtfTable, 0, 3, "5m", bgcolor=mtfTableRowBg, text_color=mtfTableRowText, text_size=size.small)
    table.cell(mtfTable, 1, 3, f_dirText(dir5), bgcolor=f_dirBg(dir5), text_color=f_dirTxtColor(dir5), text_size=size.small)

    dir15 = mtfBiasSource == "Internal" ? iTrend15 : sTrend15
    table.cell(mtfTable, 0, 4, "15m", bgcolor=mtfTableRowBg, text_color=mtfTableRowText, text_size=size.small)
    table.cell(mtfTable, 1, 4, f_dirText(dir15), bgcolor=f_dirBg(dir15), text_color=f_dirTxtColor(dir15), text_size=size.small)

    dir60 = mtfBiasSource == "Internal" ? iTrend60 : sTrend60
    table.cell(mtfTable, 0, 5, "1H", bgcolor=mtfTableRowBg, text_color=mtfTableRowText, text_size=size.small)
    table.cell(mtfTable, 1, 5, f_dirText(dir60), bgcolor=f_dirBg(dir60), text_color=f_dirTxtColor(dir60), text_size=size.small)

    dir240 = mtfBiasSource == "Internal" ? iTrend240 : sTrend240
    table.cell(mtfTable, 0, 6, "4H", bgcolor=mtfTableRowBg, text_color=mtfTableRowText, text_size=size.small)
    table.cell(mtfTable, 1, 6, f_dirText(dir240), bgcolor=f_dirBg(dir240), text_color=f_dirTxtColor(dir240), text_size=size.small)

    dirD = mtfBiasSource == "Internal" ? iTrendD : sTrendD
    table.cell(mtfTable, 0, 7, "1D", bgcolor=mtfTableRowBg, text_color=mtfTableRowText, text_size=size.small)
    table.cell(mtfTable, 1, 7, f_dirText(dirD), bgcolor=f_dirBg(dirD), text_color=f_dirTxtColor(dirD), text_size=size.small)


// -----------------------------------------------------------------------------
// Alerts
// -----------------------------------------------------------------------------
alertcondition(iBullChoch, "Internal Bullish CHoCH", "Internal bullish CHoCH detected")
alertcondition(iBearChoch, "Internal Bearish CHoCH", "Internal bearish CHoCH detected")
alertcondition(sBullChoch, "Swing Bullish CHoCH", "Swing bullish CHoCH detected")
alertcondition(sBearChoch, "Swing Bearish CHoCH", "Swing bearish CHoCH detected")
alertcondition(buyRR, "Bullish CHoCH RR", "Bullish CHoCH with RR setup")
alertcondition(sellRR, "Bearish CHoCH RR", "Bearish CHoCH with RR setup")
````
